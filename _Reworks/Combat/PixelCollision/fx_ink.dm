#define FXI_BANG 1
#define FXI_BOLT 2
#define FXI_SPARK 3
#define FXI_RING 4
#define FXI_IMAGE 5
#define FXI_ALPHA_MIN 102

mob/var/tmp/datum/ink_family/ink_cast

obj/AutoHitter/var/tmp
	datum/ink_family/ink_family
	ink_hold = 0
	ink_group = 0
	ink_kind = 0
	ink_melee = 0
	ink_dormant = 0

obj/Effects/var/tmp
	fx_t0 = 0
	fx_rot = 0
	fx_size = 1
	fx_vanish = 0
	fx_dx = 0
	fx_dy = 0

proc/FxInkAlphaMin()
	return FXI_ALPHA_MIN

proc/FxInkManualRing(iconFile)
	var/datum/fxink/s = new
	s.kind = FXI_RING
	s.manual = 1
	s.Setup(iconFile, null, 0)
	return s

proc/FxKindName(k)
	switch(k)
		if(FXI_BANG) return "bang"
		if(FXI_BOLT) return "bolt"
		if(FXI_SPARK) return "spark"
		if(FXI_RING) return "ring"
		if(FXI_IMAGE) return "image"
	return "fx"

proc/FxMaskKeyFor(key, state, d)
	if(!key) return null
	var/dc = d ? Dir2HitboxChar(d) : null
	if(state)
		if(dc && BAKED_MASKS["[key]~[state]:[dc]"]) return "[key]~[state]:[dc]"
		if(BAKED_MASKS["[key]~[state]"]) return "[key]~[state]"
	if(dc && BAKED_MASKS["[key]:[dc]"]) return "[key]:[dc]"
	if(BAKED_MASKS[key]) return key
	return null

proc/FxRectFor(key, state, d)
	if(!key) return null
	var/dc = d ? Dir2HitboxChar(d) : null
	if(state)
		if(dc && BAKED_HITBOXES["[key]~[state]:[dc]"]) return BAKED_HITBOXES["[key]~[state]:[dc]"]
		if(BAKED_HITBOXES["[key]~[state]"]) return BAKED_HITBOXES["[key]~[state]"]
	if(dc && BAKED_HITBOXES["[key]:[dc]"]) return BAKED_HITBOXES["[key]:[dc]"]
	return BAKED_HITBOXES[key]

proc/BodyInkProbe(mob/m)
	if(!m) return null
	var/list/cell = IconCellDims(m.icon)
	var/cw = cell[1]
	var/ch = cell[2]
	var/tx = 1
	var/ty = 1
	if(m.transform)
		var/matrix/T = m.transform
		tx = MatrixScaleX(T)
		ty = MatrixScaleY(T)
		if(tx <= 0.01) tx = 1
		if(ty <= 0.01) ty = 1
	var/list/AM = GetBakedMask(m.icon, m.dir)
	var/list/br
	if(!AM)
		br = GetBakedHitbox(m.icon, m.dir)
		if(!br)
			AM = GetRuntimeMask(m.icon, m.dir)
			if(!AM)
				br = GetRuntimeRect(m.icon, m.dir)
	if(!AM && !br)
		br = list(0, 0, 32, 32)
	return list(1 + (m.x-1)*32 + m.step_x, 1 + (m.y-1)*32 + m.step_y, cw, ch, tx, ty, AM, br)

proc/BodyInkHitL(list/P, wx, wy)
	var/ux = P[3]/2 + (wx - (P[1] + P[3]/2)) / P[5]
	var/uy = P[4]/2 + (wy - (P[2] + P[4]/2)) / P[6]
	var/list/AM = P[7]
	if(AM) return MaskBitAt(AM, ux, uy)
	var/list/br = P[8]
	return (ux >= br[1] && ux < br[1] + br[3] && uy >= br[2] && uy < br[2] + br[4])

proc/BodyInkRectL(list/P)
	var/list/AM = P[7]
	var/list/br = P[8]
	var/rl = 0
	var/rb = 0
	var/rw
	var/rh
	if(AM)
		rw = AM[1]*4
		rh = AM[2]*4
	else
		rl = br[1]
		rb = br[2]
		rw = br[3]
		rh = br[4]
	var/cxw = P[1] + P[3]/2
	var/cyw = P[2] + P[4]/2
	return list(cxw + (rl - P[3]/2) * P[5], cyw + (rb - P[4]/2) * P[6], rw * P[5], rh * P[6])

proc/BodyInkNear(list/P, wx, wy, pad)
	if(BodyInkHitL(P, wx, wy)) return 1
	if(pad <= 0) return 0
	if(BodyInkHitL(P, wx + pad, wy)) return 1
	if(BodyInkHitL(P, wx - pad, wy)) return 1
	if(BodyInkHitL(P, wx, wy + pad)) return 1
	if(BodyInkHitL(P, wx, wy - pad)) return 1
	var/dp = pad * 0.71
	if(BodyInkHitL(P, wx + dp, wy + dp)) return 1
	if(BodyInkHitL(P, wx - dp, wy + dp)) return 1
	if(BodyInkHitL(P, wx + dp, wy - dp)) return 1
	if(BodyInkHitL(P, wx - dp, wy - dp)) return 1
	return 0

proc/BodyInkTouchAt(list/P, ax, ay, list/Q, pad, facing)
	if(!P || !Q) return 0
	var/list/P2 = P.Copy()
	P2[1] = ax
	P2[2] = ay
	var/list/A = BodyInkRectL(P2)
	var/list/B = BodyInkRectL(Q)
	if(facing)
		var/mcx = A[1] + A[3]/2
		var/mcy = A[2] + A[4]/2
		var/ocx = B[1] + B[3]/2
		var/ocy = B[2] + B[4]/2
		var/ok = 0
		if(facing & NORTH && ocy > mcy) ok = 1
		if(facing & SOUTH && ocy < mcy) ok = 1
		if(facing & EAST && ocx > mcx) ok = 1
		if(facing & WEST && ocx < mcx) ok = 1
		if(!ok) return 0
	var/al = A[1] - pad
	var/ab = A[2] - pad
	var/ar = A[1] + A[3] + pad
	var/at = A[2] + A[4] + pad
	var/bl = B[1]
	var/bb = B[2]
	var/br = B[1] + B[3]
	var/bt = B[2] + B[4]
	if(!(al < br && bl < ar && ab < bt && bb < at)) return 0
	var/wl = max(al, bl)
	var/wb = max(ab, bb)
	var/wr = min(ar, br)
	var/wt = min(at, bt)
	for(var/wy = wb + 0.5, wy < wt, wy += 2)
		for(var/wx = wl + 0.5, wx < wr, wx += 2)
			if(!BodyInkHitL(Q, wx, wy)) continue
			if(!BodyInkNear(P2, wx, wy, pad)) continue
			return 1
	return 0

datum/fxink
	var/tmp
		datum/ink_family/family
		obj/AutoHitter/root
		kind = 0
		group = 0
		atom/movable/art
		mob/anchor
		file
		key
		state
		d = 0
		cx = 0
		cy = 0
		px = 0
		py = 0
		pz = 0
		pzfall = 0
		rot = 0
		t0 = 0
		size = 1
		vanish = 0
		dx = 0
		dy = 0
		life = 0
		cw = 32
		ch = 32
		z = 0
		list/rect
		list/mask
		list/fmasks
		list/fends
		fcycle = 0
		floop = 0
		manual = 0
		mscale = 1
		malpha = 255
		list/hit

	proc/Setup(iconFile, st, dd)
		file = iconFile
		key = iconFile ? lowertext("[iconFile]") : null
		state = st
		d = dd
		hit = list()
		var/list/cell = IconCellDims(iconFile)
		cw = cell[1]
		ch = cell[2]
		rect = FxRectFor(key, state, d)
		var/mk = FxMaskKeyFor(key, state, d)
		if(mk)
			mask = BAKED_MASKS[mk]
			var/list/fr = BAKED_FRAMES[mk]
			if(fr && fr.len >= 2 && fr[fr.len] > 0)
				floop = fr[1]
				fends = fr.Copy(2)
				fcycle = fends[fends.len]
				fmasks = list()
				for(var/i = 1, i <= fends.len, i++)
					fmasks += list(BAKED_MASKS["[mk]@[i]"])
		else if(!rect && iconFile)
			mask = GetRuntimeMask(iconFile, d, 0)
			rect = GetRuntimeRect(iconFile, d, 0)
		if(!rect) rect = list(0, 0, cw, ch)

	proc/MaskAt(t)
		if(!fmasks || !fends || !fends.len) return mask
		var/el = t
		if(el < 0) el = 0
		if(floop && el >= fcycle * floop) return fmasks[fmasks.len]
		el -= fcycle * round(el / fcycle)
		for(var/i = 1, i <= fends.len, i++)
			if(el < fends[i]) return fmasks[i]
		return fmasks[fmasks.len]

	proc/Scale(t)
		if(manual) return mscale
		switch(kind)
			if(FXI_BANG)
				if(t < 2)
					var/u = t / 2
					return 0.5 + (size - 0.5) * (1 - (1 - u) * (1 - u))
				return size * (1 + (t - 2) / max(vanish, 0.01))
			if(FXI_RING)
				if(t < 1) return 0.1
				var/u = (t - 1) / max(life, 0.01)
				if(u > 1) u = 1
				return 0.1 + (size - 0.1) * (1 - (1 - u) * (1 - u))
		return size

	proc/Alpha(t)
		if(manual) return malpha
		switch(kind)
			if(FXI_BANG)
				if(t < 2) return 255
				return 255 * (1 - (t - 2) / max(vanish, 0.01))
			if(FXI_RING)
				if(t < 1) return 255
				var/u = (t - 1) / max(life, 0.01)
				if(u > 1) return 0
				return 255 * (1 - u) * (1 - u)
			if(FXI_SPARK)
				if(t < 1 || life <= 0) return 255
				return 255 * (1 - (t - 1) / life)
			if(FXI_IMAGE)
				var/ia = 255
				if(t < 2) ia = 255 * t / 2
				if(t >= life) ia = min(ia, 255 * (1 - (t - life) / 2))
				return ia
		return 255

	proc/Expired(t)
		if(manual) return 0
		switch(kind)
			if(FXI_BANG) return t >= 2 + vanish
			if(FXI_BOLT) return t >= 3.5
			if(FXI_RING) return t >= 1 + life
			if(FXI_SPARK) return t >= 1 + life
			if(FXI_IMAGE) return t >= 2 + life
		return 1

	proc/Dead(t)
		if(Expired(t)) return 1
		if(art && !art.loc && !(art.vis_locs && art.vis_locs.len)) return 1
		if(anchor && !anchor.loc) return 1
		return 0

	proc/CenterX(t)
		var/bx = cx
		if(anchor) bx = 1 + (anchor.x-1)*32 + anchor.step_x + px + cw/2
		if(kind == FXI_BANG && t > 2) bx += dx * min(1, (t - 2) / max(vanish, 0.01))
		return bx

	proc/CenterY(t)
		var/by = cy
		if(anchor) by = 1 + (anchor.y-1)*32 + anchor.step_y + py + ch/2
		if(kind == FXI_BANG && t > 2) by += dy * min(1, (t - 2) / max(vanish, 0.01))
		if(kind == FXI_IMAGE && pz)
			if(pzfall)
				var/f = (t - 2) / max(life, 0.01)
				if(f < 0) f = 0
				if(f > 1) f = 1
				by += pz * (1 - f)
			else
				by += pz
		return by

	proc/Reach(t)
		var/s = Scale(t)
		return (max(rect[3], rect[4]) * s) * 0.71 + abs(rect[1] + rect[3]/2 - cw/2) * s + abs(rect[2] + rect[4]/2 - ch/2) * s + max(abs(dx), abs(dy))

	proc/Hits(mob/m, t, list/P, list/B = null)
		var/s = Scale(t)
		if(s <= 0.001) return 0
		var/ccx = CenterX(t)
		var/ccy = CenterY(t)
		var/list/M = MaskAt(t)
		var/rl = rect[1]
		var/rb = rect[2]
		var/rw = rect[3]
		var/rh = rect[4]
		var/hx0 = (rl + rw/2 - cw/2) * s
		var/hy0 = (rb + rh/2 - ch/2) * s
		var/hw = rw * s / 2
		var/hh = rh * s / 2
		if(M)
			hw += 4 * s
			hh += 4 * s
		var/c = cos(rot)
		var/sn = sin(rot)
		var/rcx = ccx + hx0*c + hy0*sn
		var/rcy = ccy - hx0*sn + hy0*c
		var/bw = abs(hw*c) + abs(hh*sn)
		var/bh = abs(hw*sn) + abs(hh*c)
		var/al = rcx - bw
		var/ar = rcx + bw
		var/ab = rcy - bh
		var/at = rcy + bh
		if(!B) B = BodyInkRectL(P)
		var/bl = B[1]
		var/bb = B[2]
		var/br = B[1] + B[3]
		var/bt = B[2] + B[4]
		if(!(al < br && bl < ar && ab < bt && bb < at)) return 0
		var/wl = max(al, bl)
		var/wb = max(ab, bb)
		var/wr = min(ar, br)
		var/wt = min(at, bt)
		if(glob.PIXEL_DEBUG)
			world.log << "FXM: [FxKindName(kind)] [key][state ? "~[state]" : ""] vs [m] t=[t] s=[s] a=[round(Alpha(t))] win=([round(wl)]..[round(wr)], [round(wb)]..[round(wt)]) fm=[M ? "y" : "n"] am=[P[7] ? "y" : "rect"]"
		for(var/wy = wb + 1, wy < wt, wy += 2)
			for(var/wx = wl + 1, wx < wr, wx += 2)
				var/ox = wx - ccx
				var/oy = wy - ccy
				var/lx = (ox*c - oy*sn) / s
				var/ly = (ox*sn + oy*c) / s
				var/ux = cw/2 + lx
				var/uy = ch/2 + ly
				if(M)
					if(!MaskBitAt(M, ux, uy)) continue
				else if(ux < rl || ux >= rl + rw || uy < rb || uy >= rb + rh)
					continue
				if(!BodyInkHitL(P, wx, wy)) continue
				return 1
		return 0

datum/ink_family
	var/tmp
		mob/caster
		obj/Skills/AutoHit/Z
		list/roots
		obj/AutoHitter/root
		obj/AutoHitter/rush_root
		list/sources
		list/pending
		list/groups
		list/tickhit
		looping = 0
		next_group = 1
		cast_art = 0

	New(mob/m, obj/Skills/AutoHit/z)
		caster = m
		Z = z
		roots = list()
		sources = list()
		pending = list()
		groups = list()
		tickhit = list()

	proc/NewGroup()
		return next_group++

	proc/AddRoot(obj/AutoHitter/r)
		roots += r
		root = r
		r.ink_family = src
		if(rush_root && rush_root != r)
			if(rush_root.AlreadyHit && rush_root.AlreadyHit.len)
				if(!r.AlreadyHit) r.AlreadyHit = list()
				r.AlreadyHit |= rush_root.AlreadyHit
			for(var/datum/fxink/s in sources)
				if(s.root == rush_root) s.root = r
			for(var/datum/fxink/s in pending)
				if(s.root == rush_root) s.root = r
			RushEnd()
		for(var/datum/fxink/s in pending)
			s.root = r
			sources += s
		pending.Cut()
		if(sources.len) StartLoop()

	proc/RushStart()
		if(rush_root) return rush_root
		var/obj/AutoHitter/r = new(owner = caster, Z = Z, dormant = 1)
		rush_root = r
		return r

	proc/RushEnd()
		var/obj/AutoHitter/r = rush_root
		rush_root = null
		if(!r) return
		if(HoldsRoot(r))
			r.ink_hold = 1
			return
		roots -= r
		r.InkTeardown()

	proc/Register(datum/fxink/s, obj/AutoHitter/r, g)
		s.family = src
		s.group = g
		s.root = r ? r : root
		if(!s.root)
			pending += s
			return s
		sources += s
		if(glob.PIXEL_DEBUG)
			world.log << "FXI: register [FxKindName(s.kind)] [s.key][s.state ? "~[s.state]" : ""] at ([round(s.cx)],[round(s.cy)]) rot=[s.rot] size=[s.size] mask=[s.mask ? "y" : "n"] frames=[s.fmasks ? s.fmasks.len : 0] root=[s.root]"
		StartLoop()
		return s

	proc/RegisterBang(obj/Effects/E, obj/AutoHitter/r, g)
		if(!E || !E.loc) return null
		var/datum/fxink/s = new
		s.kind = FXI_BANG
		s.art = E
		s.Setup(E.icon, E.icon_state, 0)
		s.rot = E.fx_rot
		s.size = E.fx_size
		s.vanish = E.fx_vanish
		s.dx = E.fx_dx
		s.dy = E.fx_dy
		s.t0 = E.fx_t0 ? E.fx_t0 : world.time
		s.cx = 1 + (E.x-1)*32 + E.step_x + E.pixel_x + s.cw/2
		s.cy = 1 + (E.y-1)*32 + E.step_y + E.pixel_y + s.ch/2
		s.z = E.z
		return Register(s, r, g)

	proc/RegisterBolt(obj/Effects/S, obj/AutoHitter/r, g)
		if(!S || !S.loc) return null
		var/datum/fxink/s = new
		s.kind = FXI_BOLT
		s.art = S
		s.Setup(S.icon, "Strike", 0)
		s.t0 = world.time + 1
		s.cx = 1 + (S.x-1)*32 + S.step_x + S.pixel_x + s.cw/2
		s.cy = 1 + (S.y-1)*32 + S.step_y + S.pixel_y + s.ch/2
		s.z = S.z
		return Register(s, r, g)

	proc/RegisterSpark(obj/Effects/HE, obj/AutoHitter/r, g)
		if(!HE) return null
		var/turf/T = get_turf(HE)
		if(!T && HE.Target) T = get_turf(HE.Target)
		if(!T) return null
		var/datum/fxink/s = new
		s.kind = FXI_SPARK
		s.art = HE
		s.Setup(HE.icon, HE.icon_state, HE.dir)
		s.rot = HE.fx_rot
		s.size = HE.fx_size ? HE.fx_size : 1
		s.life = HE.Lifetime > 0 ? HE.Lifetime : 10
		s.t0 = HE.fx_t0 ? HE.fx_t0 : world.time
		s.cx = 1 + (T.x-1)*32 + HE.pixel_x + s.cw/2
		s.cy = 1 + (T.y-1)*32 + HE.pixel_y + s.ch/2
		s.z = T.z
		return Register(s, r, g)

	proc/RegisterRing(obj/Effects/S, obj/AutoHitter/r, g)
		if(!S || !S.loc || !S.icon) return null
		var/datum/fxink/s = new
		s.kind = FXI_RING
		s.art = S
		s.Setup(S.icon, null, 0)
		s.size = S.Size ? S.Size : 1
		s.life = S.Lifetime > 0 ? S.Lifetime : 12
		s.t0 = world.time
		s.cx = 1 + (S.x-1)*32 + S.step_x + S.pixel_x + s.cw/2
		s.cy = 1 + (S.y-1)*32 + S.step_y + S.pixel_y + s.ch/2
		s.z = S.z
		return Register(s, r, g)

	proc/RegisterImage(iconFile, mob/anchor, turf/T, PX, PY, PZ, Size, Time, Dir, falling, obj/AutoHitter/r, g)
		if(!iconFile) return null
		if(!anchor && !T) return null
		var/datum/fxink/s = new
		s.kind = FXI_IMAGE
		s.Setup(iconFile, null, Dir)
		s.size = Size ? Size : 1
		s.life = Time
		s.pz = PZ
		s.pzfall = falling
		s.t0 = world.time
		if(anchor)
			s.anchor = anchor
			s.px = PX
			s.py = PY
			s.z = anchor.z
		else
			s.cx = 1 + (T.x-1)*32 + PX + s.cw/2
			s.cy = 1 + (T.y-1)*32 + PY + s.ch/2
			s.z = T.z
		return Register(s, r, g)

	proc/StartLoop()
		if(looping) return
		looping = 1
		spawn() Loop()

	proc/Loop()
		set waitfor = FALSE
		while(sources.len)
			Sweep()
			sleep(world.tick_lag)
		looping = 0
		ReleaseHeld()

	proc/HoldsRoot(obj/AutoHitter/r)
		for(var/datum/fxink/s in sources)
			if(s.root == r) return 1
		for(var/datum/fxink/s in pending)
			if(s.root == r) return 1
		return 0

	proc/ReleaseHeld()
		for(var/obj/AutoHitter/r in roots.Copy())
			if(r.ink_hold && !HoldsRoot(r))
				r.ink_hold = 0
				roots -= r
				r.InkTeardown()

	proc/CanHit(obj/AutoHitter/r, mob/m, g)
		if(r.IgnoreAlreadyHit)
			var/list/gl = groups[m]
			return !(gl && gl["[g]"])
		if(tickhit[m] == world.time) return 0
		return !r.InkAlreadyHit(m)

	proc/MarkHit(obj/AutoHitter/r, mob/m, g)
		if(r.IgnoreAlreadyHit)
			var/list/gl = groups[m]
			if(!gl)
				gl = list()
				groups[m] = gl
			gl["[g]"] = 1
		else
			tickhit[m] = world.time

	proc/Dispatch(obj/AutoHitter/r, mob/m, datum/fxink/s, t)
		if(glob.PIXEL_DEBUG)
			world.log << "FXI: [FxKindName(s.kind)] [s.key][s.state ? "~[s.state]" : ""] hits [m] t=[t] s=[s.Scale(t)] a=[round(s.Alpha(t))] via [r] group=[s.group]"
		spawn()
			if(r && r.Owner) r.Damage(m)
		if(r.NoPierce && r.loc) r.Distance = 0

	proc/Sweep()
		var/now = world.time
		var/list/live = list()
		var/list/zs = list()
		var/minx = 0
		var/maxx = 0
		var/miny = 0
		var/maxy = 0
		var/any = 0
		for(var/datum/fxink/s in sources.Copy())
			var/t = now - s.t0
			if(s.Dead(t) || !s.root || !s.root.Owner)
				sources -= s
				continue
			if(t < 0) continue
			if(s.Alpha(t) < FXI_ALPHA_MIN)
				if(!s.manual && s.kind != FXI_IMAGE) sources -= s
				continue
			var/r = s.Reach(t)
			var/ccx = s.CenterX(t)
			var/ccy = s.CenterY(t)
			live += list(list(s, t, ccx, ccy, r))
			if(!any)
				minx = ccx - r
				maxx = ccx + r
				miny = ccy - r
				maxy = ccy + r
				any = 1
			else
				minx = min(minx, ccx - r)
				maxx = max(maxx, ccx + r)
				miny = min(miny, ccy - r)
				maxy = max(maxy, ccy + r)
			zs |= s.z
		ReleaseHeld()
		if(!any) return
		var/tcx = round(((minx + maxx) / 2 - 1) / 32) + 1
		var/tcy = round(((miny + maxy) / 2 - 1) / 32) + 1
		tcx = max(1, min(world.maxx, tcx))
		tcy = max(1, min(world.maxy, tcy))
		var/R = round(max(maxx - minx, maxy - miny) / 64) + 2
		var/list/cands = list()
		for(var/z in zs)
			var/turf/T = locate(tcx, tcy, z)
			if(!T) continue
			for(var/mob/m in range(R, T))
				if(!m.density) continue
				cands |= m
		for(var/mob/m in cands)
			var/list/P
			var/list/B
			for(var/list/e in live)
				var/datum/fxink/s = e[1]
				if(m.z != s.z) continue
				if(s.hit[m]) continue
				if(!P)
					P = BodyInkProbe(m)
					B = BodyInkRectL(P)
				var/reach = e[5]
				if(e[3] + reach < B[1] || e[3] - reach > B[1] + B[3] || e[4] + reach < B[2] || e[4] - reach > B[2] + B[4]) continue
				var/obj/AutoHitter/r = s.root
				if(!r || !r.Owner) continue
				if(m == r.Owner && !r.hitSelf) continue
				if(!CanHit(r, m, s.group)) continue
				if(!s.Hits(m, e[2], P, B)) continue
				s.hit[m] = 1
				MarkHit(r, m, s.group)
				Dispatch(r, m, s, e[2])

obj/AutoHitter
	proc/InkJoinFamily(mob/owner, obj/Skills/AutoHit/Z)
		var/datum/ink_family/f = owner ? owner.ink_cast : null
		if(!f || f.Z != Z) f = new(owner, Z)
		f.AddRoot(src)
		ink_group = f.NewGroup()
		InkClassify()

	proc/InkHasCauseArt()
		if(TurfErupt || TurfIce || TurfFog || TurfStrike || Bolt || Erupt) return 1
		if(ink_family && ink_family.cast_art) return 1
		return 0

	proc/InkClassify()
		ink_kind = 0
		ink_melee = 0
		if(ObjIcon)
			ink_kind = 1
			return
		if(InkHasCauseArt())
			ink_kind = 2
			return
		if(!Target && !TargetLoc && DistanceMax <= 1)
			ink_melee = 1

	proc/InkInheritKind(obj/AutoHitter/AH)
		ink_family = AH.ink_family
		ink_kind = AH.ink_kind
		ink_group = AH.ink_group
		ink_melee = 0

	proc/InkNoBox()
		vhb_w = 0
		vhb_h = 0

	proc/InkNewGroup()
		ink_group = ink_family ? ink_family.NewGroup() : ink_group + 1
		return ink_group

	proc/InkAlreadyHit(mob/m)
		if(!m) return 0
		if(AlreadyHit && (m in AlreadyHit)) return 1
		if(AHOwner && AHOwner.AlreadyHit && (m in AHOwner.AlreadyHit)) return 1
		if(autohitChildren)
			for(var/obj/AutoHitter/ah in autohitChildren)
				if(ah.AlreadyHit && (m in ah.AlreadyHit)) return 1
		return 0

	proc/InkBang(obj/Effects/E)
		if(E && ink_family) ink_family.RegisterBang(E, src, ink_group)
		return E

	proc/InkRegisterSpark(obj/Effects/HE, g)
		if(HE && ink_family) ink_family.RegisterSpark(HE, src, g)

	proc/InkStrikeAt(turf/t, px = 0, py = 0)
		var/g = ink_group
		spawn()
			for(var/s = TurfStrike, s > 0, s--)
				if(!Owner) break
				Owner.HitEffect(t, UnarmedTech, SwordTech, PX = px, PY = py, ink_root = src, ink_group = g)
				sleep(1)

	proc/InkCallDown(mob/m, g)
		if(!m || !ink_family) return
		if(Bolt)
			var/obj/Effects/S = LightningBolt(m, Bolt, BoltOffset)
			if(S) ink_family.RegisterBolt(S, src, g)
		if(Erupt)
			var/obj/Effects/S = EruptEffect(m, Erupt, EruptOffset)
			if(S) ink_family.RegisterBolt(S, src, g)

	proc/InkMeleeStrike()
		if(!Owner) return
		var/list/P = BodyInkProbe(Owner)
		var/pad = max(1, glob ? glob.MOB_REACH_PAD : 2)
		var/facing = Circle ? 0 : Owner.dir
		var/reach = max(3, HURT_REACH_MAX)
		for(var/mob/m in range(reach, Owner))
			if(m == Owner || !m.density) continue
			if(m.z != Owner.z) continue
			var/list/Q = BodyInkProbe(m)
			if(!BodyInkTouchAt(P, P[1], P[2], Q, pad, facing)) continue
			if(glob.PIXEL_DEBUG) world.log << "FXI: melee [src] touches [m]"
			spawn() Damage(m)

	proc/AH_ZoneMobs(atom/epicenter, R, annulus = FALSE, los = TRUE, square = FALSE)
		var/list/out = list()
		if(!epicenter || R < 0) return out
		var/turf/e = get_turf(epicenter)
		if(!e) return out
		var/cx = (e.x-1)*32 + 16
		var/cy = (e.y-1)*32 + 16
		for(var/mob/m in (los ? view(R+1, epicenter) : range(R+1, epicenter)))
			if(!hitSelf && m == Owner) continue
			if(square)
				if(!SquareHitsBounds(cx, cy, 32*R, m)) continue
				if(annulus && R > 1 && SquareHitsBounds(cx, cy, 32*(R-1), m)) continue
			else
				if(!CircleHitsBounds(cx, cy, 32*R, m)) continue
				if(annulus && R > 1 && CircleHitsBounds(cx, cy, 32*(R-1), m)) continue
			out += m
		return out

	proc/AH_ZoneStrike(atom/epicenter, R, annulus = FALSE, los = TRUE, square = FALSE)
		var/g = ink_group
		if(Bolt || Erupt)
			for(var/mob/m in AH_ZoneMobs(epicenter, R, annulus, los, square))
				InkCallDown(m, g)
			return
		if(ink_kind || ink_melee) return
		AH_ZoneDamage(epicenter, R, annulus, los, square)

	proc/InkTargetStrike(mob/m)
		if(!m) return
		if(Bolt || Erupt)
			InkCallDown(m, InkNewGroup())
			return
		Damage(m)

	proc/InkTeardown()
		set waitfor = FALSE
		walk(src, 0)
		animate(src)
		if(AHOwner)
			AHOwner.autohitChildren -= src
		AHOwner = null
		AlreadyHit = null
		autohitChildren = null
		Owner = null
		ticking_generic -= src
		loc = null
		sleep(10)
		del src

mob/proc/InkWorldX()
	return 1 + (x-1)*32 + step_x

mob/proc/InkWorldY()
	return 1 + (y-1)*32 + step_y

mob/proc/InkRushSweep(obj/AutoHitter/r, ox, oy)
	if(!r || !r.Owner) return
	var/nx = InkWorldX()
	var/ny = InkWorldY()
	var/ddx = nx - ox
	var/ddy = ny - oy
	var/dist = max(abs(ddx), abs(ddy))
	var/steps = 1
	if(dist > 8) steps = round(dist / 8) + 1
	var/list/P = BodyInkProbe(src)
	var/pad = max(1, glob ? glob.MOB_REACH_PAD : 2)
	var/reach = max(3, HURT_REACH_MAX) + round(dist / 32) + 1
	for(var/mob/m in range(reach, src))
		if(m == src || !m.density) continue
		if(m == r.Owner) continue
		if(m.z != z) continue
		if(r.InkAlreadyHit(m)) continue
		var/list/Q = BodyInkProbe(m)
		var/touched = 0
		for(var/i = 0, i <= steps, i++)
			var/f = i / steps
			if(BodyInkTouchAt(P, ox + ddx * f, oy + ddy * f, Q, pad, dir))
				touched = 1
				break
		if(!touched) continue
		if(glob.PIXEL_DEBUG) world.log << "FXI: rush [src] sweeps [m] via [r]"
		spawn()
			if(r && r.Owner) r.Damage(m)
