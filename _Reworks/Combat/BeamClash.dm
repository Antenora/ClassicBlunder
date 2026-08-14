globalTracker
	var/tmp
		BEAM_CLASH = FALSE //master switch
		CLASH_DEBUG = FALSE
		CLASH_BASE_RATE = 0.125 //meter/sec at total power mismatch, before the stat weight
		CLASH_STAT_W = 0.55 //beam power's share of the outcome; surges carry the other 45
		CLASH_POWER_SPAN = 0.75 //how fast the power ratio saturates drift: (R - 1/R)/span, ~1.5x = full
		CLASH_SURGE_SCALE = 1.29 //surge trim: 45/35 of the old value, for the 55/45 tune
		CLASH_JAB = 0.02
		CLASH_HEAVY = 0.1
		CLASH_BRACED_HEAVY = 0.025 //what a braced heavy still pushes
		CLASH_REBOUND = 0.03 //what the attacker eats for swinging into a brace
		CLASH_JAB_COST = 2
		CLASH_HEAVY_COST = 8
		CLASH_FEINT_COST = 1
		CLASH_BRACE_COST = 4
		CLASH_RESERVE = 12 //no surging below this Energy - the beam itself auto-dies at 5
		CLASH_TAP_MAX = 3 //ds; release under this = jab
		CLASH_HVY_TELE = 3 //ds held before the windup telegraphs
		CLASH_HVY_MIN = 8 //ds held to launch a heavy on release; between tele and this = feint
		CLASH_HVY_TRAVEL = 2 //ds from release to impact
		CLASH_JAB_CD = 4 //ds between jabs
		CLASH_STAGGER = 5 //ds of dead inputs after eating an unbraced heavy
		CLASH_OT_START = 120 //ds; overtime - costs and drift ramp so it MUST end
		CLASH_CAP = 180 //ds; forced resolution
		CLASH_DRAW_BAND = 0.1 //|p| under this at cap = double KO
		CLASH_WIN_MULT = 1.25 //victor beam damage bonus riding through
		CLASH_WIN_KB = 4 //victor beam knockback tiles
		CLASH_MAX_ACTIVE = 6 //sanity cap on simultaneous struggles
		CLASH_RECLASH_CD = 50 //ds both casters sit out after a struggle - kills cycle storms
		CLASH_PUSH_PX = 96 //pressure-to-distance: 96px = 3 tiles of shove at a full meter
		CLASH_PUSH_MAX = 4 //tiles either beam can be driven from where it met
		CLASH_KICK_JAB = 8
		CLASH_KICK_HEAVY = 26
		CLASH_KICK_DECAY = 0.82

/mob/Admin2/verb/Beam_Clash_Toggle()
	set category = "Admin"
	set name = "Beam Clash Toggle"
	glob.BEAM_CLASH = !glob.BEAM_CLASH
	src << "Beam clashes: [glob.BEAM_CLASH ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set beam clash to [glob.BEAM_CLASH].")

obj/Skills/Projectile/_Projectile/var/tmp
	datum/beam_clash/clash_lock //frozen mid-struggle while set
	clash_victor = 0 //1 = rode through a won clash
	clash_boosted = 0 //WIN_MULT applied once per segment, never compounds across chained wins
	mob/clash_pierce //defeated caster whose collapsing remnants this victor head passes through

mob/var/tmp
	datum/beam_clash/beam_clash //set on both casters for the duration
	clash_stagger_until = 0
	clash_cd_until = 0 //no fresh struggle for either caster right after one ends
	clash_resume_noaim = 0 //TurningCharge: ignore still-held struggle keys for BeamTurnDir until released

var/_beam_clash_active = 0

//entry from Hit(): TRUE = a struggle owns this contact, skip the legacy eat
proc/BeamClashTry(obj/Skills/Projectile/_Projectile/A, obj/Skills/Projectile/_Projectile/B)
	if(!A || !B) return FALSE
	//frozen beams swallow EVERY projectile contact, blasts included - a stray eat would
	//punch gaps in a locked chain or snipe a clash head mid-struggle. support fire = v2.
	//this sits ABOVE the master switch: toggling it off mid-struggle must not suddenly
	//make live locked segments edible
	if(A.clash_lock || B.clash_lock) return TRUE
	if(!glob || !glob.BEAM_CLASH) return FALSE
	if(A.Area != "Beam" || B.Area != "Beam") return FALSE
	if(_beam_clash_active >= glob.CLASH_MAX_ACTIVE) return FALSE
	var/mob/ca = A.Owner
	var/mob/cb = B.Owner
	if(!ca || !cb || ca == cb) return FALSE
	if(ca.Beaming != 2 || cb.Beaming != 2) return FALSE //both still pouring, else the eat resolves it
	if(ca.beam_clash || cb.beam_clash) return FALSE //one struggle per caster
	if(world.time < ca.clash_cd_until || world.time < cb.clash_cd_until) return FALSE //no instant rematches
	//head-on only: crossing beams and side-brushes keep the legacy eat. front segments wear head/struggle
	if(!(B.icon_state == "head" || B.icon_state == "struggle" || B.icon_state == "origin")) return FALSE
	if(!(A.icon_state == "head" || A.icon_state == "struggle" || A.icon_state == "origin")) return FALSE
	if(A.Distance <= 1 || B.Distance <= 1) return FALSE //spent heads: SideBroken would trip instantly, let the eat finish it
	var/rel = dir2angle(A.dir) - dir2angle(B.dir)
	while(rel < 0) rel += 360
	if(rel < 135 || rel > 225) return FALSE
	//near-contact is enough. requiring PERFECT row/column alignment meant two beams that
	//visibly clipped into each other refused to clash, fell through to the legacy eat,
	//chewed holes in each other and stalled - if they touch head-on, they struggle
	//1 tile of slop = beams that visibly clip still struggle, but they never lock up
	//two tiles apart looking detached from each other
	if(abs(A.x - B.x) > 1 || abs(A.y - B.y) > 1) return FALSE
	new/datum/beam_clash(A, B)
	return TRUE

//one side of the struggle
/datum/clash_side
	var
		mob/caster
		obj/Skills/Projectile/_Projectile/head
		obj/Skills/Projectile/Z //the skill, for the release path
		P = 1 //snapshot power = the damage this beam would do to the OTHER caster
		sign = 1 //+1 pushes p up, -1 down
		toward = 0 //dir that leans INTO the clash
		back = 0
		prev_in = 0 //last polled input dir-state: 1 toward / -1 back / 0
		hold_start = 0
		telegraphed = 0
		jab_ready = 0 //world.time gate
		heavy_land = 0 //impact stamp; 0 = none in flight
		obj/clash_root/anchor //FX carrier parked on the head TILE - segment identity churns
		list/cone_objs //directional cone LIGHT at the beam head
		list/bulb_objs //round light pool at the head
		base_len = 0 //tiles from caster to head at freeze; the shove works off this
		skill_path //cached: segment lookup must still work after the head ref goes
		beam_chain/chain_ref
		datum/beam/beam_ref //V2: the beam datum that owns this side's geometry
		seg_tick = -1 //per-tick memo for the segment union
		list/seg_cache
		list/ordered //the frozen column, head first - stable, nothing spawns or dies mid-struggle
		ai_next = 0
		ai_hold = 0 //synthesized dir-state for clientless casters
		ai_hold_until = 0

/datum/clash_side/New(obj/Skills/Projectile/_Projectile/h, s)
	head = h
	caster = h.Owner
	sign = s
	toward = h.dir
	back = turn(h.dir, 180)
	skill_path = h.SkillPath
	chain_ref = h.chain
	beam_ref = h.beam_owner
	if(h.SkillPath)
		Z = locate(h.SkillPath) in caster
	if(caster && h.loc)
		base_len = get_dist(get_turf(caster), get_turf(h))

//the struggle controller
/datum/beam_clash
	var
		datum/clash_side/a
		datum/clash_side/b
		p = 0 //-1..+1, +1 = side a breaks through
		t0 = 0
		tier = -1 //escalation stage 0..3
		kick = 0 //transient shove from the last input, springs back
		push_tiles = 0 //current whole-tile displacement of the contact
		done = 0
		ended = 0 //End() re-entry guard
		ot_announced = 0
		obj/clash_root/root
		list/core_objs //white-hot contact light riding the sliding anchor
		turf/mid
		mix_col = "#ffffff"

/datum/beam_clash/New(obj/Skills/Projectile/_Projectile/A, obj/Skills/Projectile/_Projectile/B)
	_beam_clash_active++
	a = new(A, 1)
	b = new(B, -1)
	try
		a.P = ClashPower(A, b.caster)
		b.P = ClashPower(B, a.caster)
		t0 = world.time
		a.caster.beam_clash = src
		b.caster.beam_clash = src
		a.caster.Frozen = 1
		b.caster.Frozen = 1
		LockSide(a)
		LockSide(b)
		BuildFx() //anchors first - RebuildColumn parks them on the head tile
		RebuildColumn(a, a.base_len) //repairs any hole the beams arrived with
		RebuildColumn(b, b.base_len)
		//entry punch, moved here from Hit()'s drama block (the hook now runs before it)
		spawn()
			a.caster?.Earthquake()
			b.caster?.Earthquake()
		if(root) KenShockwave(root, Size=2)
		OMsg(a.caster, "<b><font color='#ffd34d'>[a.caster] and [b.caster]'s beams collide and lock in a struggle!!</font></b>")
		if(glob.CLASH_DEBUG) world.log << "CLASH: start [a.caster]([num2text(a.P,6)]) vs [b.caster]([num2text(b.P,6)])"
	catch(var/exception/e) //an exception after LockSide would freeze both beams forever
		if(glob.CLASH_DEBUG) world.log << "CLASH: setup died ([e]) - unwinding"
		if(a) UnlockSide(a)
		if(b) UnlockSide(b)
		End()
		return
	spawn() Loop()

//EVERY live segment of this side's beam. the chain alone is not authoritative: it is
//keyed per travel dir (TurningCharge casters strand segments in other chains) and a
//segment spawned in the same tick the clash formed registers after the snapshot.
//active_projectiles is the caster's own ledger - union both, filter by skill
/datum/beam_clash/proc/SideSegments(datum/clash_side/S)
	if(!S) return list()
	if(S.beam_ref) //V2: the datum IS the authority, no reconstruction needed
		return S.beam_ref.parts.Copy()
	if(S.seg_tick == world.time && S.seg_cache) return S.seg_cache //memo: the Loop asks twice a tick
	var/list/out = list()
	//keyed off CACHED skill/chain/dir, never off S.head - a lost head ref must not
	//make the whole beam unfindable (that is how a side became uncollapsible)
	if(S.chain_ref?.segments)
		out |= S.chain_ref.segments
	if(S.head?.chain?.segments)
		out |= S.head.chain.segments
	if(S.caster?.active_projectiles)
		for(var/obj/Skills/Projectile/_Projectile/pr in S.caster.active_projectiles)
			if(pr.Area != "Beam") continue
			if(pr.clash_lock == src) //already ours: never lose track of something we froze
				out |= pr
				continue
			if(pr.SkillPath != S.skill_path) continue
			//same beam only: a volley/FixedDirections arm of the SAME skill firing
			//another way must not be frozen and then annihilated with this one
			if((S.chain_ref && pr.chain == S.chain_ref) || pr.dir == S.toward)
				out |= pr
	S.seg_tick = world.time
	S.seg_cache = out
	return out

/datum/beam_clash/proc/SpawnFiller(datum/clash_side/S, dist)
	if(!S?.Z || !S.caster) return null
	var/obj/Skills/Projectile/_Projectile/pr = S.caster.Blast(S.Z, S.caster, 0, 0, S.toward)
	if(!pr) return null
	pr.clash_lock = src
	pr.Distance = dist
	walk(pr, 0)
	return pr

/datum/beam_clash/proc/RebuildColumn(datum/clash_side/S, want)
	if(S?.beam_ref) 
		S.beam_ref.ClashSetLength(want)
		S.ordered = S.beam_ref.parts.Copy()
		var/obj/Skills/Projectile/_Projectile/nh = S.beam_ref.HeadPart()
		if(nh)
			S.head = nh
			nh.clash_lock = src
			if(S.anchor) S.anchor.loc = get_turf(nh)
		for(var/obj/Skills/Projectile/_Projectile/pr in S.ordered)
			pr.clash_lock = src
		return
	if(!S?.caster) return
	var/turf/C = get_turf(S.caster)
	if(!C) return
	want = clamp(round(want), 1, 60) 
	var/list/pool = list()
	for(var/obj/Skills/Projectile/_Projectile/pr in SideSegments(S))
		if(pr.clash_lock == src)
			pool += pr
	var/list/order = list()
	var/obj/Skills/Projectile/_Projectile/newhead
	var/turf/T = C
	for(var/i = 1, i <= want, i++)
		if(!T) break
		var/obj/Skills/Projectile/_Projectile/pr
		if(pool.len)
			pr = pool[1]
			pool.Cut(1, 2)
		else
			pr = SpawnFiller(S, 1)
		if(!pr) break
		pr.loc = T
		pr.step_x = 0 //tile-quantised and rigid: no sub-tile drift anywhere in the column
		pr.step_y = 0
		pr.dir = S.toward
		pr.Distance = max(1, (pr.DistanceMax ? pr.DistanceMax : 50) - (i - 1))
		pr.layer = (i == want) ? 5 : 4
		if(i == 1)
			pr.icon_state = "origin"
		else if(i == want)
			pr.icon_state = "struggle"
		else
			pr.icon_state = "tail"
		order.Insert(1, pr) //head-first
		newhead = pr
		T = get_step(T, S.toward)
	for(var/obj/Skills/Projectile/_Projectile/pr in pool) //the beam shrank: retire the surplus
		pr.clash_lock = null
		pr.Distance = 0
	S.ordered = order
	if(newhead)
		S.head = newhead
		if(S.anchor) S.anchor.loc = get_turf(newhead) //FX ride the tile, not the segment

/datum/beam_clash/proc/LockSide(datum/clash_side/S)
	if(S.beam_ref) S.beam_ref.ClashFreeze() //V2: the datum stops driving; we do
	for(var/obj/Skills/Projectile/_Projectile/pr in SideSegments(S))
		if(!pr.clash_lock)
			pr.clash_lock = src
			walk(pr, 0)
	if(S.head)
		S.head.icon_state = "struggle" //graphics loops are frozen too, pin the front art ourselves
		S.head.layer = 5

/datum/beam_clash/proc/UnlockSide(datum/clash_side/S)
	if(S?.beam_ref) S.beam_ref.ClashRelease() //V2: hand the wheel back
	for(var/obj/Skills/Projectile/_Projectile/pr in SideSegments(S))
		if(pr.clash_lock == src)
			pr.clash_lock = null
	if(S?.caster?.active_projectiles)
		for(var/obj/Skills/Projectile/_Projectile/pr in S.caster.active_projectiles)
			if(pr.clash_lock == src) //catch-all: never strip another struggle's freeze
				pr.clash_lock = null

/datum/beam_clash/proc/CollapseSide(datum/clash_side/S)
	ReleaseCaster(S)
	if(S?.beam_ref) //V2: one call takes the whole beam with it, segments included
		S.beam_ref.ClashRelease()
		S.beam_ref.Die()
		S.ordered = null
		return
	var/list/segs = SideSegments(S)
	UnlockSide(S)
	spawn()
		var/n = 0
		for(var/obj/Skills/Projectile/_Projectile/pr in segs)
			if(!pr) continue
			if(!pr.clash_lock) //never touch a segment a newer struggle now owns
				pr.Distance = 0
			if(++n % 8 == 0)
				sleep(world.tick_lag)

/datum/beam_clash/proc/ReleaseCaster(datum/clash_side/S)
	var/mob/c = S?.caster
	if(!c || c.Beaming != 2) return
	if(S.Z)
		c.BeamStop(S.Z) //Beaming=0 + cooldown; the paused fire loop exits clean
	else
		c.Beaming = 0 //skill ref lost: still end the channel

/datum/beam_clash/proc/_dx(d)
	return ((d & EAST) ? 1 : 0) - ((d & WEST) ? 1 : 0)
/datum/beam_clash/proc/_dy(d)
	return ((d & NORTH) ? 1 : 0) - ((d & SOUTH) ? 1 : 0)

/datum/beam_clash/proc/ClashPower(obj/Skills/Projectile/_Projectile/S, mob/enemy)
	. = 1
	try
		var/mob/O = S.Owner
		if(!O || !enemy) return 1
		var/str = S.StrScaling ? O.GetStr(S.StrScaling) : 0
		var/force = S.ForScaling ? O.GetFor(S.ForScaling) : 0
		if(S.AdaptRate)
			if(O.GetStr(1) > O.GetFor(1))
				str = O.GetStr(S.AdaptRate)
			else
				force = O.GetFor(S.AdaptRate)
		var/powerDif = O.Power / max(enemy.Power, 1)
		if(glob.CLAMP_POWER && !O.ignoresPowerClamp(enemy))
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
		var/EndEffectiveness = S.EndEffectiveness
		if(O.isSuperCharged(O))
			EndEffectiveness -= clamp(glob.SUPERCHARGERATE * O.passive_handler["SuperCharge"], 0, 1)
		if(O.passive_handler["Atomizer"])
			EndEffectiveness = clamp(EndEffectiveness - (EndEffectiveness * (O.passive_handler["Atomizer"] * glob.ATOMIZERRATE)), 0.0001, 2)
		var/def = enemy.getEndStat(1) * EndEffectiveness
		var/atk = 0
		if(force) atk += force
		if(str) atk += str
		if(atk < 1) atk = 1
		var/D = strikeCoreDamage(powerDif, atk, def)
		D *= S.DamageMult
		D = ProjectileDamage(D)
		if(O.HasUnarmedDamage() && !O.EquippedSword() && !O.EquippedStaff())
			D *= 1 + (O.GetUnarmedDamage()/glob.UNARMED_DAMAGE_DIVISOR)
		else if(O.HasMagicSword())
			D *= 1 + (O.GetMagicSwordAscension()/glob.UNARMED_DAMAGE_DIVISOR)
		if(S.Primordial)
			D *= 1 + (((S.Primordial*glob.PRIMORDIAL_EFFECTIVENESS) * (100-enemy.Health))/100)
		if(O.RippleActive() && O.Oxygen >= S.BreathCost)
			D *= (1+(0.25*O.GetRipple()*max(1, O.PoseEnhancement*2)))
		D *= max(S.BeamCharge, 0.5)
		. = max(D, 0.01)
	catch(var/exception/e)
		if(glob.CLASH_DEBUG) world.log << "CLASH: power snapshot fell back ([e])"
		. = max(S.DamageMult * max(S.BeamCharge, 0.5), 0.01)

/datum/beam_clash/proc/Loop()
	set waitfor = 0
	try
		var/R = a.P / max(b.P, 0.01)
		var/powerTerm = clamp((R - 1/R) / glob.CLASH_POWER_SPAN, -1, 1)
		while(!done)
			sleep(world.tick_lag)
			if(CheckSides()) break
			var/el = world.time - t0
			var/rate_mult = 1
			var/cost_mult = 1
			if(el >= glob.CLASH_OT_START)
				var/ot = 1.5 + 0.25 * round((el - glob.CLASH_OT_START) / 20)
				rate_mult = ot
				cost_mult = ot
				if(!ot_announced)
					ot_announced = 1
					OMsg(a.caster, "<b><font color='#ff6a3d'>The clash surges out of control!!</font></b>")
					KenShockwave(root ? root : a.head, Size=2)
			a.caster.Frozen = 1
			b.caster.Frozen = 1
			LockSide(a)
			LockSide(b)
			PollInput(a, cost_mult)
			PollInput(b, cost_mult)
			LandHeavies(cost_mult)
			p += powerTerm * glob.CLASH_STAT_W * glob.CLASH_BASE_RATE * rate_mult * (world.tick_lag / 10)
			p = clamp(p, -1, 1)
			kick *= glob.CLASH_KICK_DECAY //the shove springs back
			if(abs(kick) < 0.5) kick = 0
			PushTiles() //beams visibly advance/withdraw a tile at a time
			UpdateFx(el)
			if(p >= 1)
				Resolve(a, b)
			else if(p <= -1)
				Resolve(b, a)
			else if(el >= glob.CLASH_CAP)
				if(abs(p) < glob.CLASH_DRAW_BAND)
					DoubleKO()
				else
					Resolve(p > 0 ? a : b, p > 0 ? b : a)
	catch(var/exception/e)
		if(glob.CLASH_DEBUG) world.log << "CLASH: loop died ([e]), failsafe release"
	if(!ended)
		if(a) UnlockSide(a)
		if(b) UnlockSide(b)
	End()

//a side dying to anything outside the struggle ends it: KO, CC, grab-freeze, beam gone
/datum/beam_clash/proc/SideBroken(datum/clash_side/S)
	var/mob/c = S.caster
	if(!c || c.KO || c.Knockbacked || c.Stunned || c.Launched) return TRUE
	if(c.Beaming != 2) return TRUE //beam released/killed through any outside path
	if(!S.head || !S.head.loc || S.head.Distance <= 0) return TRUE
	return FALSE

/datum/beam_clash/proc/CheckSides()
	var/ba = SideBroken(a)
	var/bb = SideBroken(b)
	if(!ba && !bb) return FALSE
	if(ba && bb)
		DoubleKO()
	else if(ba)
		OMsg(a.caster, "<b>[a.caster]'s beam falters!!</b>")
		Resolve(b, a)
	else
		OMsg(b.caster, "<b>[b.caster]'s beam falters!!</b>")
		Resolve(a, b)
	return TRUE

//dir-state: 1 = leaning in, -1 = bracing, 0 = neutral
/datum/beam_clash/proc/InputDir(datum/clash_side/S)
	if(!S.caster.client)
		return AIThink(S)
	var/hd = S.caster.heldDir()
	if(hd == S.toward) return 1
	if(hd == S.back) return -1
	return 0

/datum/beam_clash/proc/CanSpend(datum/clash_side/S, cost)
	return S.caster.Energy >= glob.CLASH_RESERVE + cost

/datum/beam_clash/proc/Spend(datum/clash_side/S, cost)
	S.caster.LoseEnergy(cost)

/datum/beam_clash/proc/PollInput(datum/clash_side/S, cost_mult)
	if(world.time < S.caster.clash_stagger_until)
		S.prev_in = 0
		if(S.telegraphed) CancelTelegraph(S)
		return
	var/now_in = InputDir(S)
	if(now_in == 1 && S.prev_in != 1) //press in
		S.hold_start = world.time
	if(now_in == 1 && !S.telegraphed && world.time - S.hold_start >= glob.CLASH_HVY_TELE)
		Telegraph(S) //the bulge the other side reads
	if(now_in != 1 && S.prev_in == 1) //release
		var/held = world.time - S.hold_start
		if(S.heavy_land)
			//already committed nothing - release just resets
		else if(held <= glob.CLASH_TAP_MAX)
			Jab(S, cost_mult)
		else if(held >= glob.CLASH_HVY_MIN)
			LaunchHeavy(S, cost_mult)
		else
			Feint(S, cost_mult)
		if(S.telegraphed && !S.heavy_land) CancelTelegraph(S)
	S.prev_in = now_in

/datum/beam_clash/proc/Jab(datum/clash_side/S, cost_mult)
	if(world.time < S.jab_ready) return
	var/cost = glob.CLASH_JAB_COST * cost_mult
	if(!CanSpend(S, cost)) return
	Spend(S, cost)
	S.jab_ready = world.time + glob.CLASH_JAB_CD
	Push(S.sign * glob.CLASH_JAB * glob.CLASH_SURGE_SCALE)
	kick += S.sign * glob.CLASH_KICK_JAB //instant visible shove - the answer to a press
	FxSurge(S, 0)

/datum/beam_clash/proc/LaunchHeavy(datum/clash_side/S, cost_mult)
	var/cost = glob.CLASH_HEAVY_COST * cost_mult
	if(!CanSpend(S, cost))
		CancelTelegraph(S)
		return
	Spend(S, cost)
	S.heavy_land = world.time + glob.CLASH_HVY_TRAVEL

/datum/beam_clash/proc/Feint(datum/clash_side/S, cost_mult)
	var/cost = glob.CLASH_FEINT_COST * cost_mult
	if(!CanSpend(S, cost)) return
	Spend(S, cost)

/datum/beam_clash/proc/LandHeavies(cost_mult)
	for(var/datum/clash_side/S in list(a, b))
		if(!S.heavy_land || world.time < S.heavy_land) continue
		S.heavy_land = 0
		CancelTelegraph(S)
		var/datum/clash_side/E = (S == a) ? b : a
		var/braced = (InputDir(E) == -1) && CanSpend(E, glob.CLASH_BRACE_COST)
		if(braced)
			Spend(E, glob.CLASH_BRACE_COST * cost_mult)
			Push(S.sign * glob.CLASH_BRACED_HEAVY * glob.CLASH_SURGE_SCALE)
			Push(-S.sign * glob.CLASH_REBOUND * glob.CLASH_SURGE_SCALE)
			kick -= S.sign * glob.CLASH_KICK_JAB //absorbed and thrown back
			FxSurge(S, 1)
		else
			Push(S.sign * glob.CLASH_HEAVY * glob.CLASH_SURGE_SCALE)
			kick += S.sign * glob.CLASH_KICK_HEAVY
			E.caster.clash_stagger_until = world.time + glob.CLASH_STAGGER
			FxSurge(S, 2)
			HitStop(S.caster, E.caster, 6)

/datum/beam_clash/proc/Push(amt)
	p = clamp(p + amt, -1, 1)

/datum/beam_clash/proc/PushTiles()
	var/t = clamp(round((p * glob.CLASH_PUSH_PX + kick) / 32), -glob.CLASH_PUSH_MAX, glob.CLASH_PUSH_MAX)
	if(t == push_tiles) return
	push_tiles = t
	RebuildColumn(a, a.base_len + t) //winner lengthens...
	RebuildColumn(b, b.base_len - t) //...loser is driven back
	if(root && a.head) root.loc = get_turf(a.head)

/datum/beam_clash/proc/AIThink(datum/clash_side/S)
	var/datum/clash_side/E = (S == a) ? b : a
	//react to a telegraph: sometimes pull back into a brace
	if(E.telegraphed && S.ai_hold != -1 && prob(4))
		S.ai_hold = -1
		S.ai_hold_until = world.time + 12
	if(S.ai_hold && world.time >= S.ai_hold_until)
		S.ai_hold = 0
	if(!S.ai_hold && world.time >= S.ai_next)
		S.ai_next = world.time + rand(10, 22)
		if(prob(30)) //wind a heavy: hold in long enough to launch
			S.ai_hold = 1
			S.ai_hold_until = world.time + glob.CLASH_HVY_MIN + 2
		else //jab: dip in for a tick
			S.ai_hold = 1
			S.ai_hold_until = world.time + 1
	return S.ai_hold

/datum/beam_clash/proc/Resolve(datum/clash_side/W, datum/clash_side/L)
	if(done) return
	done = 1
	OMsg(W.caster, "<b><font color='#ffd34d'>[W.caster]'s beam overwhelms [L.caster]'s and breaks through!!</font></b>")
	var/tint = FxBlastTint(W.head)
	var/arm_watcher = FALSE
	if(W.beam_ref)
		arm_watcher = W.beam_ref.ArmVictor(L.caster, glob.CLASH_WIN_MULT)
	else
		//legacy: the riders live per-segment - once each, chained wins don't compound
		for(var/obj/Skills/Projectile/_Projectile/pr in SideSegments(W))
			if(!pr.clash_boosted)
				pr.clash_boosted = 1
				pr.DamageMult *= glob.CLASH_WIN_MULT
		if(W.head && !W.head.clash_victor) //never re-arm a spent victor or stack watchers
			W.head.clash_victor = 1
			W.head.clash_pierce = L.caster
			arm_watcher = TRUE
	UnlockSide(W)
	CollapseSide(L)
	//terminal blast wherever the victor's beam ends its path, in the beam's own colour
	if(arm_watcher)
		var/datum/beam/WB = W.beam_ref
		spawn()
			var/obj/Skills/Projectile/_Projectile/h = W.head
			var/turf/last = WB ? WB.HeadTurf() : (h ? get_turf(h) : mid)
			while(WB ? WB.Alive() : (h && h.loc && h.Distance > 0))
				var/turf/cur = WB ? WB.HeadTurf() : get_turf(h)
				if(cur) last = cur
				sleep(1) //tight poll: a 5ds poll sampled up to 10 tiles stale and banged mid-beam
			if(last)
				Bang(last, Size = 2.5, Offset = 0, color_override = tint)
				FxLightPulse(last, 2.5, tint, 0.85)
	End()

/datum/beam_clash/proc/DoubleKO()
	if(done) return
	done = 1
	OMsg(a.caster, "<b><font color='#ff6a3d'>Both beams detonate in the deadlock!!</font></b>")
	var/ta = FxBlastTint(a.head)
	var/tb = FxBlastTint(b.head)
	var/turf/ground = root ? get_turf(root) : mid
	CollapseSide(a)
	CollapseSide(b)
	if(ground)
		Bang(ground, Size = 2.5, Offset = 0, PX = -8, color_override = ta)
		Bang(ground, Size = 2.5, Offset = 0, PX = 8, color_override = tb)
		FxLightPulse(ground, 3, ta, 0.85)
	a.caster.clash_stagger_until = world.time + 10
	b.caster.clash_stagger_until = world.time + 10
	End()

/datum/beam_clash/proc/End()
	done = 1
	if(ended) return
	ended = 1
	_beam_clash_active = max(0, _beam_clash_active - 1)
	if(a?.caster)
		a.caster.beam_clash = null
		a.caster.Frozen = 0
		a.caster.clash_cd_until = world.time + glob.CLASH_RECLASH_CD
		a.caster.clash_resume_noaim = 1
	if(b?.caster)
		b.caster.beam_clash = null
		b.caster.Frozen = 0
		b.caster.clash_cd_until = world.time + glob.CLASH_RECLASH_CD
		b.caster.clash_resume_noaim = 1
	TearDownFx()

/obj/clash_root //invisible anchor at the contact turf; the core light rides it
	mouse_opacity = 0
	Savable = 0 
	gfx_transient_visual = 1 //boot stale-sweep purges any orphan that slips into a save anyway

/datum/beam_clash/proc/SideColor(datum/clash_side/S)
	if(!S?.head || !S.head.icon) return "#dff0ff"
	var/c = FxIconColor(S.head.icon, "tail")
	if(!c) c = FxIconColor(S.head.icon, S.head.icon_state)
	return c || "#dff0ff"

/datum/beam_clash/proc/BlendCol(c1, c2)
	//cheap hex mix for the orb/light colour
	. = "#ffffff"
	try
		var/r = (text2num("0x[copytext(c1, 2, 4)]") + text2num("0x[copytext(c2, 2, 4)]")) / 2
		var/g = (text2num("0x[copytext(c1, 4, 6)]") + text2num("0x[copytext(c2, 4, 6)]")) / 2
		var/bl = (text2num("0x[copytext(c1, 6, 8)]") + text2num("0x[copytext(c2, 6, 8)]")) / 2
		. = rgb(r, g, bl)
	catch()

//cone scale for a tier: the wedge grows as the struggle escalates
/datum/beam_clash/proc/ConeScale()
	return 2.4 + 0.45 * max(tier, 0)

/datum/beam_clash/proc/BuildFx()
	var/ca = SideColor(a)
	var/cb = SideColor(b)
	mix_col = BlendCol(ca, cb)
	for(var/datum/clash_side/S in list(a, b))
		if(!S.head) continue
		S.anchor = new
		S.anchor.loc = get_turf(S.head)
		var/col = (S == a) ? ca : cb
		S.cone_objs = FxAttachConeLight(S.anchor, turn(S.toward, 180), col, ConeScale())
		S.bulb_objs = FxAttachRoundLight(S.anchor, col, 1.5, 1) //ray churn at the head
	//white-hot contact core
	mid = get_turf(a.head)
	if(mid)
		root = new
		root.loc = mid
		core_objs = FxAttachRoundLight(root, "#ffffff", 1.2, 1)
		//world light + moving shadows follow the struggle
		FxRegisterLight(root, null, glob.LIGHT_SHADOW_RADIUS, mix_col)

/datum/beam_clash/proc/Telegraph(datum/clash_side/S)
	S.telegraphed = 1
	var/matrix/M = FxConeAim(turn(S.toward, 180), ConeScale() + 0.7)
	for(var/obj/O in S.cone_objs)
		animate(O, transform = M, time = 3, flags = ANIMATION_PARALLEL)
	for(var/obj/O in S.bulb_objs)
		animate(O, transform = matrix() * 1.9, time = 3, flags = ANIMATION_PARALLEL)

/datum/beam_clash/proc/CancelTelegraph(datum/clash_side/S)
	if(!S.telegraphed) return
	S.telegraphed = 0
	var/matrix/M = FxConeAim(turn(S.toward, 180), ConeScale())
	for(var/obj/O in S.cone_objs)
		animate(O, transform = M, time = 3, flags = ANIMATION_PARALLEL)
	for(var/obj/O in S.bulb_objs)
		animate(O, transform = matrix() * (1.5 + 0.2 * max(tier, 0)), time = 3, flags = ANIMATION_PARALLEL)

//kind: 0 jab, 1 braced heavy, 2 clean heavy
/datum/beam_clash/proc/FxSurge(datum/clash_side/S, kind)
	var/turf/ground = root ? get_turf(root) : mid
	if(!ground) return
	switch(kind)
		if(0)
			FxLightPulse(ground, 0.9, SideColor(S), 0.85)
		if(1)
			FxLightPulse(ground, 1.2, mix_col, 0.85)
		if(2)
			FxLightPulse(ground, 1.8, SideColor(S), 0.85)
			for(var/obj/O in core_objs)
				animate(O, transform = matrix() * (1.7 + 0.2 * max(tier, 0)), time = 1)
				animate(transform = matrix() * (1.2 + 0.2 * max(tier, 0)), time = 4, easing = QUAD_EASING)

/datum/beam_clash/var/tmp
	next_pulse = 0
	next_slide = 0
	next_surge_fx = 0 

/datum/beam_clash/proc/UpdateFx(el)
	if(root)
		var/off = p * glob.CLASH_PUSH_PX + kick
		root.pixel_x = round(_dx(a.toward) * off)
		root.pixel_y = round(_dy(a.toward) * off)
		if(world.time >= next_pulse) //breathing arena light, capped inside FxLightPulse
			next_pulse = world.time + 8
			FxLightPulse(get_turf(root), 1 + 0.35 * max(tier, 0), mix_col, 0.85)
	//escalation: cone lights and pools swell as it drags on or swings hard
	var/newtier = min(3, round((el / glob.CLASH_OT_START) * 2 + abs(p) * 1.5))
	if(newtier == tier) return
	tier = newtier
	for(var/datum/clash_side/S in list(a, b))
		if(S.telegraphed) continue //a windup owns this side's tween right now
		var/matrix/M = FxConeAim(turn(S.toward, 180), ConeScale())
		for(var/obj/O in S.cone_objs) //PARALLEL or this wipes the ray shimmer's looping alpha chain
			animate(O, transform = M, time = 5, easing = QUAD_EASING, flags = ANIMATION_PARALLEL)
		for(var/obj/O in S.bulb_objs)
			animate(O, transform = matrix() * (1.5 + 0.2 * tier), time = 5, easing = QUAD_EASING, flags = ANIMATION_PARALLEL)
	for(var/obj/O in core_objs)
		animate(O, transform = matrix() * (1.2 + 0.2 * tier), time = 5, flags = ANIMATION_PARALLEL)

/datum/beam_clash/proc/TearDownFx()
	if(root)
		root.loc = null
		FxDropLights(root, core_objs)
	core_objs = null
	root = null
	for(var/datum/clash_side/S in list(a, b))
		if(!S) continue
		FxDropLights(S.anchor, S.cone_objs)
		FxDropLights(S.anchor, S.bulb_objs)
		if(S.anchor)
			S.anchor.loc = null
			S.anchor = null
		S.cone_objs = null
		S.bulb_objs = null
		S.ordered = null
		S.seg_cache = null
