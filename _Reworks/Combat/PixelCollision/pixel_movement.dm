//engine pixel movement build switch
//everything else keys off PmActive() at runtime

world/movement_mode = PIXEL_MOVEMENT_MODE //the switch

globalTracker
	var/tmp
		//tmp on purpose - glob is saved at shutdown, a non-tmp debug flag would boot back ON
		PIXEL_DEBUG = FALSE //log pixel-collision contact decisions + draw hitbox/hurtbox overlays
		PM_CLIENT_FPS = 40 //client fps while in a pixel-movement build; live-tunable
		PM_DASH_MAX_PX = 64 //smoothness ceiling for pixel dashes (px/tick); lower = smoother/slower, higher = faster/chunkier
		PIXEL_MOB_BOUNDS = 0 //sub-tile mob collision (shelved for now, off by default)
		MOB_BOUND_SCALE = 1.0 //tightness of the body box: 1.0 = hugs the opaque body exactly (mobs touch, never overlap); <1 = a little body overlap for tighter packing
		PIXEL_MOB_HURTBOX = 1 //mob-vs-mob stops on the measured body, turfs/objs not affected 0 = off
		MOB_HURT_SCALE = 1.0 //1.0 = bodies touch exactly; <1 lets bodies overlap a little
		MOB_REACH_PAD = 2 //px of melee past the body edge; 2 covers float truncation, 32 = old full-tile reach
		MELEE_DEBUG = FALSE //swing prints from getEnemies, toggled by the admin verb
		DRAGON_CLASH_DEBUG = FALSE
		MOB_INK_COLLIDE = 0 //oversized bodies block/get reached on their per-row ink strips, not the dir-union box; 0 = old AABB
		MOB_TALL_SOLID = 40 //bodies this tall+ block walking on their bottom half only

proc/PmActive()
	return world.movement_mode == PIXEL_MOVEMENT_MODE

//scale magnitudes are the COLUMNS (a,d)/(b,e) - reading rows pulls translation in and identity reports 0
proc/MatrixScaleX(matrix/m)
	if(!m) return 1
	return sqrt(m.a*m.a + m.d*m.d)

proc/MatrixScaleY(matrix/m)
	if(!m) return 1
	return sqrt(m.b*m.b + m.e*m.e)

//size the engine collision box to the measured opaque body so mobs stop at visible contact, not tile edges
mob/proc/ApplyPixelBounds()
	if(!PmActive() || !glob || !glob.PIXEL_MOB_BOUNDS)
		if(bound_width != 32 || bound_height != 32 || bound_x || bound_y) //feature off: restore full-tile blocking
			bound_width = 32
			bound_height = 32
			bound_x = 0
			bound_y = 0
		return
	var/list/rect = GetBakedHitbox(icon) //dir-union opaque body rect [x,y,w,h] in icon-cell px (stable across turns)
	if(!rect) rect = GetRuntimeRect(icon) //unbaked custom icon: kicks a one-time bg ink scan, null until ready
	if(!rect) return //not measured yet (or no icon): keep current/full-tile bounds; the ~1.5s _PmWatcher retry self-heals
	var/list/cell = IconCellDims(icon)
	var/cw = cell[1]
	var/ch = cell[2]
	var/tx = 1 //transform scale magnitude (Oozaru, Expand, etc)
	var/ty = 1
	if(transform)
		var/matrix/m = transform
		tx = MatrixScaleX(m)
		ty = MatrixScaleY(m)
	var/f = glob.MOB_BOUND_SCALE
	var/rx = rect[1]
	var/ry = rect[2]
	var/rw = rect[3]
	var/rh = rect[4]
	var/w = max(4, round(rw * tx * f))
	var/h = max(4, round(rh * ty * f))
	var/bx = round(pixel_x + cw/2 + (rx + rw/2 - cw/2) * tx - w/2) //box hugs the ink; transform scales about the icon center
	var/by = round(pixel_y + ch/2 + (ry + rh/2 - ch/2) * ty - h/2)
	if(bound_width == w && bound_height == h && bound_x == bx && bound_y == by) return
	bound_width = w
	bound_height = h
	bound_x = bx
	bound_y = by

mob/proc/PmDashPx(mult = 1.25)
	var/delay = glob.BASE_LOOP_DELAY + MovementSpeed()
	return max(2, round(mult * 32 * glob.PLAYER_SPEED_MULT / max(1, -round(-delay))))

//one glided dash step per tick toward Trg (away=1 flips it); returns px actually stepped, 0 if blocked
mob/proc/PmDashStep(atom/Trg, px, away = 0)
	var/d = Trg ? (away ? get_dir(Trg, src) : get_dir(src, Trg)) : dir
	if(!d) return 0
	var/use = max(1, min(px, glob.PM_DASH_MAX_PX))
	if(!away && ismob(Trg))
		var/gap = ClashPxDist(Trg) - 32
		if(gap < use)
			use = round(max(gap, 0))
		if(use <= 0)
			return 0
	var/bx = (x-1)*32 + step_x //measure real displacement - Move()'s return can't tell moved from blocked here
	var/by = (y-1)*32 + step_y
	var/oss = step_size
	step_size = use
	glide_size = use //actual per-tick px so the dash doesn't rubber-band
	step(src, d)
	step_size = oss
	return max(abs((x-1)*32 + step_x - bx), abs((y-1)*32 + step_y - by))

var/HURT_REACH_MAX = 2 //broad-phase radius, tiles; global because a big body's loc can sit tiles away and still overlap you

mob
	var/tmp
		hurt_w = 0 //body box, world px, transform-scaled. 0 = unmeasured -> mob keeps today's tile blocking
		hurt_h = 0
		hurt_ox = 0 //box left/bottom relative to the TILE ORIGIN (never pixel_x, matching InkOverlap)
		hurt_oy = 0
		hurt_reach = 1
		hurt_key //icon+scale+ink-flag signature; re-measure only when it changes
		hurt_pending = 0 //wants strips, bg ink scan not landed yet
		list/hurt_spans //dir-union per-row ink strips, unscaled cell px. null = AABB (normal-size, scaled, flag off, or unmeasured)

proc/HurtboxOn()
	return PmActive() && glob && glob.PIXEL_MOB_HURTBOX

var/list/HURT_SPAN_CACHE = list()

//bounding box of the strip stack, unscaled cell px: list(ox, oy, w, h); null = no ink
proc/HurtSpanBBox(list/S)
	if(!S) return null
	var/list/RS = S[3]
	var/lo = -1
	var/hi = -1
	var/r0 = -1
	var/r1 = -1
	for(var/r = 0, r < S[2], r++)
		var/k = r*2 + 1
		if(RS[k] < 0) continue
		if(lo < 0 || RS[k] < lo) lo = RS[k]
		if(RS[k+1] > hi) hi = RS[k+1]
		if(r0 < 0) r0 = r
		r1 = r
	if(r0 < 0) return null
	return list(lo, r0*4, hi - lo, (r1 + 1 - r0)*4)

//RS holds px (lo inclusive, hi exclusive) so a query never multiplies; -1 = empty row.
proc/BuildHurtSpans(list/M)
	var/mw = M[1]
	var/mh = M[2]
	var/list/RS = new/list(mh*2)
	for(var/r = 0, r < mh, r++)
		var/lo = -1
		var/hi = -1
		for(var/c = 0, c < mw, c++)
			if(!MaskBitAt(M, c*4, r*4)) continue
			if(lo < 0) lo = c
			hi = c
		RS[r*2+1] = (lo < 0) ? -1 : lo*4
		RS[r*2+2] = (lo < 0) ? -1 : (hi+1)*4
	return list(mw, mh, RS)

//d=0 is the dir-UNION mask on purpose - per-dir spans would resize on turn and pop mobs apart
//positive-only cache so an icon still waiting on its bg scan gets re-asked, not negative-cached
proc/GetHurtSpans(iconFile)
	if(!iconFile) return null
	var/key = lowertext("[iconFile]")
	var/list/S = HURT_SPAN_CACHE[key]
	if(S) return S
	var/list/M = GetBakedMask(iconFile)
	if(!M) M = GetRuntimeMask(iconFile)
	if(!M) return null
	S = BuildHurtSpans(M)
	HURT_SPAN_CACHE[key] = S
	return S

proc/HurtInkF(mob/A, al, ab, aw, ah, dx, dy, mob/O)
	var/mxdx = max(0, dx)
	var/mndy = min(0, dy)
	var/mxdy = max(0, dy)
	var/sal = al + min(0, dx)
	var/sar = al + aw + mxdx
	var/sab = ab + mndy
	var/sat = ab + ah + mxdy
	var/bl = O.HurtL()
	var/bb = O.HurtB()
	var/bh = HurtSolidH(O.hurt_h) //blocker's walkable height; ah arrives pre-clipped from Move
	//free pre-reject: the box is derived from the spans, so a swept-AABB miss proves an ink miss
	if(!(sal < bl + O.hurt_w && bl < sar && sab < bb + bh && bb < sat)) return 1
	var/list/SO = O.hurt_spans
	var/list/SA = A.hurt_spans
	var/list/RSb = SO ? SO[3] : null
	var/list/RSa = SA ? SA[3] : null
	var/box = bl - O.hurt_ox //mask cell-px origin = tile origin + step_x, what MaskBitAt anchors to
	var/boy = bb - O.hurt_oy
	var/aox = al - A.hurt_ox
	var/aoy = ab - A.hurt_oy
	var/j0 = 0
	var/j1 = 0
	if(SO) //only the blocker strips the mover's swept y-band can reach
		j0 = max(0, round((sab - boy) / 4))
		j1 = min(SO[2] - 1, round((sat - 1 - boy) / 4))
		j1 = min(j1, round((O.hurt_oy + bh - 1) / 4)) //rows above the walkable half don't block
	var/f = 1
	for(var/j = j0, j <= j1, j++)
		var/rl
		var/rb
		var/rw
		var/rh
		if(SO)
			var/k = j*2 + 1
			var/lo = RSb[k]
			if(lo < 0) continue //empty row
			rl = box + lo
			rw = RSb[k+1] - lo
			rb = boy + j*4
			rh = 4
		else
			rl = bl
			rb = bb
			rw = O.hurt_w
			rh = bh
		var/i0 = 0
		var/i1 = 0
		if(SA) //mover strips whose own swept y-band can meet this blocker strip
			i0 = max(0, round((rb - aoy - 4 - mxdy) / 4) + 1)
			i1 = min(SA[2] - 1, round((rb + rh - mndy - aoy - 1) / 4))
			i1 = min(i1, round((A.hurt_oy + ah - 1) / 4)) //mover's own top half sweeps nothing either
		for(var/i = i0, i <= i1, i++)
			var/ml
			var/mb
			var/mw
			var/mh
			if(SA)
				var/k = i*2 + 1
				var/lo = RSa[k]
				if(lo < 0) continue
				ml = aox + lo
				mw = RSa[k+1] - lo
				mb = aoy + i*4
				mh = 4
			else
				ml = al
				mb = ab
				mw = aw
				mh = ah
			//the escape: ink already inside ink means something loc'd us here - free the whole body or the other strips weld you in
			if(ml < rl + rw && rl < ml + mw && mb < rb + rh && rb < mb + mh) return 1
			if(!f) continue //fully blocked already; keep walking the strips so an escape can still fire
			var/nf = HurtSweep(ml, mb, mw, mh, dx, dy, rl, rb, rw, rh)
			if(nf < f) f = nf
	return f

//TRUE if A's box (grown by reach pad) touches O's ink - the same strips the clamp stops on, so reach never falls short
proc/HurtInkTouch(mob/O, ml, mb, mw, mh)
	var/list/S = O.hurt_spans
	var/bl = O.HurtL()
	var/bb = O.HurtB()
	if(!(ml < bl + O.hurt_w && bl < ml + mw && mb < bb + O.hurt_h && bb < mb + mh)) return FALSE //free pre-reject
	var/list/RS = S[3]
	var/ox = bl - O.hurt_ox
	var/oy = bb - O.hurt_oy
	var/r0 = max(0, round((mb - oy) / 4))
	var/r1 = min(S[2] - 1, round((mb + mh - 1 - oy) / 4))
	for(var/r = r0, r <= r1, r++) //every row in r0..r1 already overlaps in y; only x is left to test
		var/k = r*2 + 1
		var/lo = RS[k]
		if(lo < 0) continue
		if(ml < ox + RS[k+1] && ox + lo < ml + mw) return TRUE
	return FALSE

//dir-union rect shared by Move()'s clamp and InBodyReach; skills still hit the per-dir mask, tighter on purpose
mob/proc/ApplyHurtbox()
	if(!HurtboxOn())
		if(hurt_w)
			hurt_w = 0
			hurt_spans = null
			hurt_key = null
			hurt_pending = 0
		return
	var/tx = round(MatrixScaleX(transform), 0.01)
	var/ty = round(MatrixScaleY(transform), 0.01)
	var/f = glob.MOB_HURT_SCALE
	var/ink = glob.MOB_INK_COLLIDE
	//ink lives in the key or flipping MOB_INK_COLLIDE live never re-measures
	var/key = "[icon]:[tx]:[ty]:[f]:[ink]"
	if(hurt_key == key)
		if(!hurt_pending) return
		//pending re-ask is a cheap span-cache lookup, never the full re-measure
		var/list/PS = GetHurtSpans(icon)
		if(!PS) return
		hurt_spans = PS
		HurtAdoptSpans()
		hurt_pending = 0
		return
	var/list/r = GetBakedHitbox(icon)
	if(!r) r = GetRuntimeRect(icon) //custom base: kicks a one-time bg scan, null until it lands
	if(!r) //unmeasured: stay out of it entirely rather than guess a tile box
		hurt_w = 0
		hurt_spans = null
		hurt_key = null
		hurt_pending = 0
		return
	var/list/cell = IconCellDims(icon)
	hurt_w = max(2, round(r[3] * tx * f))
	hurt_h = max(2, round(r[4] * ty * f))
	hurt_ox = round(cell[1]/2 + (r[1] + r[3]/2 - cell[1]/2) * tx - hurt_w/2) //scale about the icon center
	hurt_oy = round(cell[2]/2 + (r[2] + r[4]/2 - cell[2]/2) * ty - hurt_h/2)
	//spans are unscaled cell px, so any transform scale breaks the mask correspondence - scaled giants stay AABB
	var/want = (ink && tx == 1 && ty == 1 && f == 1 && HurtOversized())
	var/list/SP = want ? GetHurtSpans(icon) : null
	hurt_spans = SP
	if(SP) HurtAdoptSpans() //publishes reach; may null hurt_spans if the mask carries no ink at all
	else HurtSetReach()
	//key always commits; hurt_pending carries "no mask yet" ("mask exists but empty" counts as settled)
	hurt_pending = (want && !SP)
	hurt_key = key

//the AABB is derived FROM the strips - the exact-pixel rect can sit inside the 4px-cell mask and would break the pre-reject
mob/proc/HurtAdoptSpans()
	var/list/bb = HurtSpanBBox(hurt_spans)
	if(!bb) //mask with no ink at all: there is no shape to collide with, keep the rect box
		hurt_spans = null
		HurtSetReach()
		return
	hurt_ox = bb[1]
	hurt_oy = bb[2]
	hurt_w = bb[3]
	hurt_h = bb[4]
	HurtSetReach()

//reach derives from the FINAL box and publishes here, never at a call site - the span box can outgrow the rect box
var/HURT_REACH_GEN = 0 //bumped on any change, so the watcher can tell nobody grew while it re-derived

mob/proc/HurtSetReach()
	var/nr = max(1, round((max(abs(hurt_ox) + hurt_w, abs(hurt_oy) + hurt_h) + 32) / 32) + 1)
	if(nr != hurt_reach) HURT_REACH_GEN++
	hurt_reach = nr
	if(hurt_reach > HURT_REACH_MAX)
		HURT_REACH_MAX = hurt_reach //raise-only; _PmWatcher recomputes the decay

mob/proc/HurtL()
	return 1 + (x-1)*32 + step_x + hurt_ox

mob/proc/HurtB()
	return 1 + (y-1)*32 + step_y + hurt_oy

//"next to it" for melee: body vs body, since a giant's loc tile is just one corner of its art
//abstains for 32x32 bases - this must never widen normal PvP range
mob/proc/HurtOversized()
	return hurt_w > 0 && (hurt_ox < 0 || hurt_oy < 0 || hurt_ox + hurt_w > 32 || hurt_oy + hurt_h > 32)

//extra = px of reach BEYOND touching, for the range passives; 0 = plain melee = edge-to-edge.
mob/proc/InBodyReach(mob/O, extra = 0)
	if(!HurtboxOn() || !ismob(O) || O == src) return FALSE
	if(O.z != z || !isturf(loc) || !isturf(O.loc)) return FALSE
	ApplyHurtbox()
	O.ApplyHurtbox()
	if(hurt_w <= 0 || O.hurt_w <= 0) return FALSE //unmeasured: the caller's tile check stands
	//facing gate: their body center vs mine on the axis I'm looking down; diagonals pass on either bit
	var/mcx = HurtL() + hurt_w / 2
	var/mcy = HurtB() + hurt_h / 2
	var/ocx = O.HurtL() + O.hurt_w / 2
	var/ocy = O.HurtB() + O.hurt_h / 2
	var/facing = FALSE
	if(dir & NORTH && ocy > mcy) facing = TRUE
	if(dir & SOUTH && ocy < mcy) facing = TRUE
	if(dir & EAST && ocx > mcx) facing = TRUE
	if(dir & WEST && ocx < mcx) facing = TRUE
	if(!facing) return FALSE
	//floor 1: the clamp parks you at gap exactly 0 and the test is strict <, so pad 0 can't hit a flush body
	var/pad = max(1, glob ? glob.MOB_REACH_PAD : 6) + extra
	var/al = HurtL() - pad
	var/ab = HurtB() - pad
	var/ar = HurtL() + hurt_w + pad
	var/at = HurtB() + hurt_h + pad
	if(O.hurt_spans && glob.MOB_INK_COLLIDE) //the same strips the clamp stops on: reach can't fall short of it
		return HurtInkTouch(O, al, ab, ar - al, at - ab)
	return (al < O.HurtL() + O.hurt_w) && (O.HurtL() < ar) && (ab < O.HurtB() + O.hurt_h) && (O.HurtB() < at)

//bodies in melee reach whose loc tile isn't the one in front of us
mob/proc/BodyReachMobs(extra = 0)
	if(!HurtboxOn()) return null
	var/list/found
	for(var/mob/O in range(HURT_REACH_MAX, src))
		if(O == src || !O.density) continue
		if(!InBodyReach(O, extra)) continue
		if(!found) found = list()
		found += O
	return found

mob/proc/HurtboxBlockedBy(mob/O)
	if(O == src) return 0
	if(!density || !O.density) return 0 //Incorporeal / afterimages / non-blocking mobs
	if(Incorporeal || O.Incorporeal) return 0
	if(hurt_w <= 0 || O.hurt_w <= 0) return 0 //either side unmeasured: today's behavior
	if(O.z != z) return 0
	if(Grab == O || O.Grab == src) return 0 //carrying a co-located victim
	if(grabbed == O || O.grabbed == src) return 0
	if(Dodging) return 0 //MY dodge only - exempting O.Dodging lets me walk inside a mob while it dodges
	if(ai_followers && (O in ai_followers)) return 0
	if(O.ai_followers && (src in O.ai_followers)) return 0
	return 1

//fraction of (dx,dy) A can travel before touching B; 1 = free
//already overlapping = 1 on purpose: anything loc'd into a body can always walk out, never back in
proc/HurtSweep(al, ab, aw, ah, dx, dy, bl, bb, bw, bh)
	var/ovx = (al < bl+bw) && (bl < al+aw)
	var/ovy = (ab < bb+bh) && (bb < ab+ah)
	if(ovx && ovy) return 1
	var/txe = 0
	var/txx = 1
	var/tye = 0
	var/tyx = 1
	if(!dx)
		if(!ovx) return 1
	else
		var/t1 = (bl - (al+aw)) / dx
		var/t2 = ((bl+bw) - al) / dx
		txe = min(t1, t2)
		txx = max(t1, t2)
	if(!dy)
		if(!ovy) return 1
	else
		var/t1 = (bb - (ab+ah)) / dy
		var/t2 = ((bb+bh) - ab) / dy
		tye = min(t1, t2)
		tyx = max(t1, t2)
	var/tin = max(txe, tye)
	//>= not > - flush contact reads entry==exit==0, and > would weld every body to whatever it touched
	if(tin >= min(txx, tyx) || tin >= 1 || tin < 0) return 1
	return max(0, tin)

proc/HurtTrunc(v) //round() is floor in DM; truncate toward zero so a clamp can never overshoot
	return (v >= 0) ? round(v) : -round(-v)

proc/HurtSolidH(h)
	var/t = glob ? glob.MOB_TALL_SOLID : 0
	if(t > 0 && h >= t) return h - round(h / 2)
	return h

mob/Cross(atom/movable/O)
	if(HurtboxOn() && ismob(O)) return 1 //let bodies close; Move()'s clamp does the real stopping
	return ..()

mob/Move(atom/NewLoc, Dir = 0, sx = 0, sy = 0)
	if(!HurtboxOn() || !Dir || !isturf(loc) || !isturf(NewLoc))
		return ..()
	var/turf/T = NewLoc
	if(T.z != z || get_dist(loc, T) > 1) return ..() //real teleport / z-change: never clamped
	ApplyHurtbox() //self-heals the mover; early-outs on an unchanged key
	if(hurt_w <= 0) return ..()
	var/dx = (T.x - x)*32 + sx - step_x //world px: T == loc is the slide, T adjacent is the aligned stride
	var/dy = (T.y - y)*32 + sy - step_y
	if(!dx && !dy) return ..()
	var/al = HurtL()
	var/ab = HurtB()
	var/ash = HurtSolidH(hurt_h)
	var/f = 1
	var/ink = glob.MOB_INK_COLLIDE
	for(var/mob/O in range(HURT_REACH_MAX, src))
		if(!HurtboxBlockedBy(O)) continue
		//EITHER side oversized -> strips, or a giant mover reads a flush player as overlapping and walks through them
		var/nf = (ink && (O.hurt_spans || hurt_spans)) ? \
			HurtInkF(src, al, ab, hurt_w, ash, dx, dy, O) : \
			HurtSweep(al, ab, hurt_w, ash, dx, dy, O.HurtL(), O.HurtB(), O.hurt_w, HurtSolidH(O.hurt_h))
		if(nf < f)
			f = nf
			if(!f) break
	//re-expressed against loc so truncation shortens the TRAVEL - shortening NewLoc's offset rounds you 1px INTO the blocker
	if(f < 1)
		return ..(loc, Dir, step_x + HurtTrunc(dx * f), step_y + HurtTrunc(dy * f))
	return ..()

mob/Players
	var/tmp
		pm_owed = 0
		pm_crossed = FALSE

	proc/PmMovementTick()
		pm_crossed = FALSE
		move_speed = MovementSpeed()
		var/diag = (dir==NORTHEAST||dir==NORTHWEST||dir==SOUTHEAST||dir==SOUTHWEST)
		var/delay = glob.BASE_LOOP_DELAY
		if(diag)
			delay *= glob.DIAG_LOOP_DELAY
		delay += move_speed
		if(held_skill?.HeldBeam && !HasMovingCharge())
			delay *= glob.HELD_BEAM_MOVE_PENALTY
		if(held_skill && held_skill.HeldMoveMult > 0 && held_skill.HeldMoveMult != 1)
			delay /= held_skill.HeldMoveMult
		if(src.Crippled)
			var/debuffRev = src.GetDebuffReversal()
			if(debuffRev)
				delay /= (1 + ((glob.MAX_CRIPPLE_MULT * (Crippled / glob.CRIPPLE_DIVISOR) / 2) * debuffRev))
			else
				delay *= (1 + (glob.MAX_CRIPPLE_MULT * (Crippled / glob.CRIPPLE_DIVISOR)))
		delay *= SlowMoDelayMult(src)
		pm_owed = min(pm_owed + 32 * glob.PLAYER_SPEED_MULT / max(1, -round(-delay)), 32)
		var/px = round(pm_owed)
		if(px < 1) return
		step_size = px //stepDiagonal's step() moves step_size px (the engine ignores step()'s px arg)
		glide_size = diag ? round(px * 1.41421) : px //actual per-tick px so movement doesn't rubber-band; a diagonal step moves px in BOTH axes so the glide needs sqrt2 more
		var/turf/pre = loc
		if(stepDiagonal())
			pm_owed -= px
			if(loc != pre)
				pm_crossed = TRUE
				if(Afterimages() && prob(40*Afterimages())) //per tile-crossing; the MovementSpeed() getter side-effect is PmActive-gated off
					if(passive_handler.Get("AfterImageSkin") != "Rainbow")
						FlashImage(src)
				var/ai_skin = passive_handler.Get("AfterImageSkin")
				if(ai_skin)
					var/ai_count = passive_handler.Get("AfterImages")
					if(ai_count)
						switch(ai_skin)
							if("Cooler") coolerFlashImage(src, ai_count)
							if("Rainbow") rainbowFlashImage(src, ai_count)
				if(passive_handler["Don't Move"])
					LoseHealth(PctToHP(glob.RUPTURED_MOVE_DMG * passive_handler["Don't Move"]))
					animate(src, color = "#850000")
					animate(src, color = src.MobColor, time = world.tick_lag * delay)
		else
			pm_owed = 0 //blocked: no banking pixels against a wall
		step_size = 32 //restore so Rush/DashTo/knockback strides stay full-size (and saves stay clean)

var/_pm_boot = _PmWatcherBoot()

proc/_PmWatcherBoot()
	spawn(20)
		_PmWatcher()
	return 1

proc/_PmWatcher()
	set waitfor = 0
	set background = 1
	if(!PmActive()) return
	world.log << "PXW: pixel-movement build"
	var/tick = 0
	while(1)
		if(glob) //glob is replaced by the boot savefile load; dereference fresh
			for(var/client/C)
				if(C.fps != glob.PM_CLIENT_FPS)
					C.fps = glob.PM_CLIENT_FPS
			if(tick % 3 == 0) //~1.5s: keep every mob's collision boxes current (new/transformed mobs + live glob tuning)
				//accumulate local, publish once - this yields, and zeroing the live max mid-pass un-enumerates giants
				for(var/mob/M)
					M.ApplyPixelBounds()
					M.ApplyHurtbox() //stationary blockers never call Move(), so refresh them here
				//tight re-derive so the radius decays when a big body despawns; GEN says nobody grew mid-pass
				var/gen = HURT_REACH_GEN
				var/mx = 2
				for(var/mob/M)
					if(M.hurt_reach > mx) mx = M.hurt_reach
				if(HURT_REACH_GEN == gen || mx > HURT_REACH_MAX) HURT_REACH_MAX = mx
		tick++
		sleep(10)
