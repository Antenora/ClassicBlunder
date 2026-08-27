globalTracker
	var/tmp
		BEAM_V2 = TRUE //master switch; off = legacy conveyor
		BEAM_HIT_INTERVAL = 0.5
		BEAM_MAX_LEN = 60 //hard cap on segments in one beam, whatever the skill asks
		BEAM_DMG_DEBUG = FALSE

/mob/Admin2/verb/Beam_Damage_Debug()
	set category = "Admin"
	set name = "Beam Damage Debug"
	glob.BEAM_DMG_DEBUG = !glob.BEAM_DMG_DEBUG
	src << "Beam damage trace: [glob.BEAM_DMG_DEBUG ? "ON (world.log)" : "OFF"]."

proc/BeamDbg(msg)
	if(glob.BEAM_DMG_DEBUG) world.log << "BEAMDMG: [msg]"

/mob/Admin2/verb/Beam_System_Toggle()
	set category = "Admin"
	set name = "Beam System Toggle"
	glob.BEAM_V2 = !glob.BEAM_V2
	src << "Beam system: [glob.BEAM_V2 ? "V2 (owned geometry)" : "LEGACY (conveyor)"]."
	Log("Admin", "[ExtractInfo(src)] set beam system to [glob.BEAM_V2 ? "V2" : "legacy"].")

obj/Skills/Projectile/_Projectile/var/tmp/datum/beam/beam_owner //set = this segment is drawn by a beam datum, it does not drive itself
mob/var/tmp/list/beams //live beam datums this caster owns

/datum/beam
	var/tmp
		mob/owner
		obj/Skills/Projectile/skill
		bdir = 0
		turf/anchor //tile the tail currently sits on
		length = 0 //segments currently drawn
		maxlen = 10 //furthest the head may reach from where it was fired
		travelled = 0 //tiles the anchor has advanced since release
		firing = 1
		fixed_dir = 0 //volley arms hold their heading; a normal beam follows the caster
		frozen = 0 //a clash owns the geometry while set
		dying = 0
		list/parts = list() //index 1 = tail ... index length = head
		list/hit_at = list() //mob -> world.time, damage gating lives on the beam
		charge = 0.5
		speed = 0.5
		blocked = 0 //head is up against something solid
		ox = 0
		oy = 0
		laid_dir = 0 //the heading this column was last drawn along
		victor = 0 //0 none, 1 armed (breakthrough pending), 2 spent
		mob/pierce //the defeated caster whose remnants we sweep aside
		win_mult = 1 //damage bonus carried by every part, including ones spawned later
		prism_split = 0
		obj/Skills/Projectile/_Projectile/glow_part

/datum/beam/New(mob/M, obj/Skills/Projectile/Z, d)
	owner = M
	skill = Z
	bdir = d ? d : M.dir
	speed = max(Z.Speed, world.tick_lag)
	maxlen = clamp(Z.Distance ? Z.Distance : 10, 1, glob.BEAM_MAX_LEN)
	charge = M.BeamCharging ? M.BeamCharging : 0.5
	anchor = get_step(get_turf(M), bdir)
	if(!M.beams) M.beams = list()
	M.beams += src
	spawn() Loop()

/datum/beam/proc/Release()
	firing = 0

/datum/beam/proc/Die()
	if(dying) return
	dying = 1
	firing = 0
	if(glow_part)
		FxDetachLight(glow_part)
		glow_part._fx_glowed = 0
		glow_part = null
	var/list/ps = parts.Copy()
	parts.Cut()
	if(owner && owner.beams) owner.beams -= src
	owner = null
	skill = null
	if(!glob.FLASH_STATES || ps.len < 3)
		for(var/obj/Skills/Projectile/_Projectile/p in ps)
			if(p) p.clash_lock = null
			DropPart(p)
		return
	spawn() DieDrain(ps)

/datum/beam/proc/DieDrain(list/ps)
	var/n = ps.len
	for(var/i = 1, i < n, i++)
		var/obj/Skills/Projectile/_Projectile/p = ps[i]
		if(!p) continue
		p.clash_lock = null
		p.Explode = 0
		DropPart(p)
		if(i % 6 == 0)
			sleep(1)
	var/obj/Skills/Projectile/_Projectile/h = ps[n]
	if(h)
		h.clash_lock = null
		DropPart(h)

/datum/beam/proc/Loop()
	set waitfor = 0
	while(!dying)
		sleep(speed * SlowMoDelayMult(owner))
		if(dying) break
		try
			Tick()
		catch(var/exception/e)
			world.log << "BEAM V2: tick failed ([e])"
			Die()
			break

/datum/beam/proc/Tick()
	if(!owner || !owner.loc)
		Die()
		return
	if(firing && owner.Beaming != 2)
		Release()
	if(frozen) //a clash owns us; it drives Layout() itself
		return
	if(firing)
		if(skill && skill.HomingBeam && owner.Target && owner.Target != owner && owner.Target.z == owner.z)
			bdir = get_dir(owner, owner.Target) || bdir
		else if(!fixed_dir && owner.dir)
			bdir = owner.dir
		anchor = get_step(get_turf(owner), bdir) //stay welded to the muzzle
		if(PmActive()) //track the muzzle's sub-tile position too, or the beam sits off the caster
			ox = owner.step_x
			oy = owner.step_y
		if(!anchor)
			Die()
			return
		if(length < maxlen && !blocked)
			length++
	else
		//the tail flies forward; once the head is spent the beam shortens into nothing
		if(travelled + length - 1 < maxlen && !blocked)
			var/turf/nx = get_step(anchor, bdir)
			if(!nx)
				Die()
				return
			anchor = nx
			travelled++
		else
			length--
			var/turf/nx = get_step(anchor, bdir)
			if(nx)
				anchor = nx
				travelled++
			if(length <= 0)
				Die()
				return
	Layout()
	Sweep()

/datum/beam/proc/Layout()
	if(!anchor) return
	for(var/obj/Skills/Projectile/_Projectile/p in parts.Copy())
		if(!p || !p.loc || p.Distance < 0 || p.Killed) //already dead: just forget it
			parts -= p
			if(p) p.beam_owner = null
			continue
		if(laid_dir && p.dir != laid_dir && p.pc_lastdir)
			parts -= p
			DropPart(p)
	length = clamp(length, 0, glob.BEAM_MAX_LEN)
	while(parts.len > length) //shed surplus from the front
		var/obj/Skills/Projectile/_Projectile/p = parts[parts.len]
		parts.Cut(parts.len, 0)
		DropPart(p)
	while(parts.len < length)
		var/obj/Skills/Projectile/_Projectile/p = MakePart()
		if(!p)
			length = parts.len
			break
		parts += p
	var/turf/T = anchor
	blocked = 0
	for(var/i = 1, i <= parts.len, i++)
		var/obj/Skills/Projectile/_Projectile/p = parts[i]
		if(!p) continue
		if(!T)
			length = i - 1
			break
		var/turf/was = get_turf(p)
		p.loc = T
		p.step_x = ox //one shared offset across the whole column: rigid, and aligned
		p.step_y = oy
		p.dir = bdir
		p.layer = (i == parts.len) ? 5 : 4
		p.icon_state = PartState(i)
		p.Distance = max(1, maxlen - (travelled + i - 1))
		if(victor || win_mult != 1) StampPart(p) //riders follow whichever part is the head now
		if(was != T) PartMoved(p, was)
		if(i != parts.len && p._fx_glowed) p._fx_glowed = 0
		var/turf/nx = get_step(T, bdir)
		if(i == parts.len && HeadStopped(p, nx)) blocked = 1
		T = nx
	laid_dir = bdir //what the hijack check compares against next tick
	HeadGlow()

/datum/beam/proc/HeadGlow()
	var/obj/Skills/Projectile/_Projectile/head = parts.len ? parts[parts.len] : null
	if(head == glow_part) return
	var/moved = 0
	if(glow_part)
		glow_part._fx_glowed = 0
		moved = head ? FxMoveLight(glow_part, head) : 0
		if(!moved) FxDetachLight(glow_part)
	glow_part = head
	if(!head) return
	head._fx_glowed = 1
	if(!moved) FxAttachLight(head, null)

/datum/beam/proc/PartMoved(obj/Skills/Projectile/_Projectile/p, turf/was)
	if(!p || !p.loc) return
	if(p.Trail)
		if(p.MultiTrail)
			WaveTrail(p.Trail, p.VariationX+p.TrailX, p.VariationY+p.TrailY, p.dir, p.loc, p.TrailDuration, p.TrailSize)
		else
			LeaveTrail(p.Trail, p.VariationX+p.TrailX, p.VariationY+p.TrailY, p.dir, p.loc, p.TrailDuration, p.TrailSize)
	if(p.MiniDivide && istype(p.loc, /turf))
		Destroy(p.loc, 9001)
	if(p.Divide)
		for(var/turf/t in view(p.Divide, p))
			Destroy(t, 9001)
	if(was) GfxProjectileWaterMove(p, was)

/datum/beam/proc/HeadStopped(obj/Skills/Projectile/_Projectile/head, turf/nx)
	if(!nx) return 1
	if(nx.density) return 1
	if(head && head.loc && !head.Piercing && head.BeamAheadBlocked()) return 1
	return 0

/datum/beam/proc/PartState(i)
	var/obj/Skills/Projectile/_Projectile/p = parts[i]
	if(i == 1) //the tail: welded to the caster while firing, capped once released
		return BeamState(p, firing ? "origin" : "end", "tail")
	if(i == parts.len)
		return BeamState(p, blocked ? "struggle" : "head", "tail")
	return "tail"

/datum/beam/proc/MakePart()
	if(!owner || !skill) return null
	var/obj/Skills/Projectile/_Projectile/p = owner.Blast(skill, owner, 0, 0, bdir, BeamOwner = src)
	if(!p) return null
	p.beam_owner = src //its own Life loop stands down on this
	StampPart(p)
	if(p.chain)
		p.chain.segments -= p
		p.chain = null
	walk(p, 0)
	if(glob.FLASH_STATES)
		var/wscale = clamp(0.85 + 0.3 * (charge - 0.5), 0.85, 1.3)
		if(abs(wscale - 1) > 0.02)
			var/ang = FlashDirAngle(bdir)
			var/matrix/wm = matrix()
			wm.Turn(-ang)
			wm.Scale(wscale, 1)
			wm.Turn(ang)
			p.transform = p.transform * wm
		animate(p, alpha = 235, time = 5, loop = -1, flags = ANIMATION_PARALLEL)
		animate(alpha = 255, time = 5)
	return p

/datum/beam/proc/DropPart(obj/Skills/Projectile/_Projectile/p)
	if(!p) return
	p.beam_owner = null
	p.clash_lock = null //ProjectileFinish refuses to bury a locked part; never strand one
	p.clash_victor = 0 //a rider must never outlive the beam's control of the part
	p.clash_pierce = null
	p.Distance = 0
	if(p.Owner) p.Owner.active_projectiles -= p
	p.ProjectileFinish()

/datum/beam/proc/Sweep()
	if(!parts.len || !owner) return
	var/obj/Skills/Projectile/_Projectile/head = parts[parts.len]
	if(!head || !head.loc) return
	var/dbg_cand = 0
	var/dbg_gated = 0
	var/dbg_nolap = 0
	var/dbg_hit = 0
	for(var/obj/Skills/Projectile/_Projectile/p in parts)
		if(!p || !p.loc) continue
		for(var/mob/m in range(p.HitboxSweepRange(), p))
			if(m == owner || !m.loc || !m.density) continue
			dbg_cand++
			if(hit_at[m] && world.time - hit_at[m] < glob.BEAM_HIT_INTERVAL)
				dbg_gated++
				continue
			if(!HitboxesOverlap(p, m))
				dbg_nolap++
				continue
			dbg_hit++
			hit_at[m] = world.time
			try
				p.Hit(m)
			catch(var/exception/e)
				world.log << "BEAM V2: Hit failed on [m] ([m.type]) from [skill] - [e] @ [e.file]:[e.line]"
				continue
			if(!prism_split && istype(skill, /obj/Skills/Projectile/Beams/Shine_Ray))
				prism_split = 1
				var/turf/pt = get_step(get_turf(m), bdir)
				if(!pt)
					pt = get_turf(m)
				if(pt)
					for(var/pd in list(turn(bdir, 45), turn(bdir, -45)))
						var/obj/Skills/Projectile/Beams/Shine_Ray_Prism/PZ = new
						PZ.SpawnPosition = pt
						new /obj/Skills/Projectile/_Projectile(owner, PZ, pt, owner.BeamCharging, 0, 0, pd)
	SweepReport(dbg_cand, dbg_gated, dbg_nolap, dbg_hit)
	for(var/obj/Skills/Projectile/_Projectile/other in range(2, head))
		if(other.Owner == owner || other == head) continue
		if(!HitboxesOverlap(head, other)) continue
		if(glob.BEAM_DMG_DEBUG) BeamDbg("clash [skill] vs [other.SkillPath]")
		try
			head.Hit(other)
		catch(var/exception/e)
			world.log << "BEAM V2: clash Hit failed from [skill] - [e] @ [e.file]:[e.line]"
		break

/datum/beam/proc/SweepReport(c, g, n, h)
	if(!glob.BEAM_DMG_DEBUG) return
	if(!c && !h) return
	BeamDbg("sweep [skill] len=[parts.len] blocked=[blocked] cand=[c] gated=[g] nolap=[n] hit=[h] ox=[ox] oy=[oy]")

/datum/beam/proc/PartTouching(mob/m)
	for(var/obj/Skills/Projectile/_Projectile/p in parts)
		if(!p || !p.loc) continue
		if(get_dist(p, m) > 1) continue
		if(HitboxesOverlap(p, m)) return p
	return null

/datum/beam/proc/ClashFreeze()
	frozen = 1

/datum/beam/proc/ClashRelease()
	frozen = 0
	for(var/obj/Skills/Projectile/_Projectile/p in parts) //the freeze must not outlive the struggle
		if(p) p.clash_lock = null

/datum/beam/proc/ClashSetLength(n)
	length = clamp(round(n), 1, glob.BEAM_MAX_LEN)
	Layout()

/datum/beam/proc/HeadPart()
	return parts.len ? parts[parts.len] : null

/datum/beam/proc/Alive()
	return (!dying && parts.len) ? 1 : 0

/datum/beam/proc/HeadTurf()
	var/obj/Skills/Projectile/_Projectile/h = HeadPart()
	return h ? get_turf(h) : null

/datum/beam/proc/ArmVictor(mob/loser, mult)
	if(victor == 1) return 0 //one pending breakthrough at a time; a SPENT one may re-arm
	                          //so a beam that wins a second struggle still gets its due
	victor = 1
	pierce = loser
	if(mult) win_mult *= mult
	StampParts()
	return 1

/datum/beam/proc/StampParts()
	for(var/obj/Skills/Projectile/_Projectile/p in parts)
		if(!p) continue
		StampPart(p)

/datum/beam/proc/StampPart(obj/Skills/Projectile/_Projectile/p)
	if(!p) return
	var/is_head = (parts.len && p == parts[parts.len])
	p.clash_victor = (is_head && victor == 1) ? 1 : 0
	p.clash_pierce = (is_head && victor == 1) ? pierce : null
	if(win_mult != 1 && !p.clash_boosted) //once per part - the bonus must not compound
		p.clash_boosted = 1
		p.DamageMult *= win_mult

mob/proc/BeamFor(obj/Skills/Projectile/Z, d)
	if(!beams) beams = list()
	for(var/datum/beam/B in beams)
		if(B.skill == Z && B.bdir == d && B.firing && !B.dying)
			return B
	return new/datum/beam(src, Z, d)

mob/proc/BeamChannelLive()
	if(beams)
		for(var/datum/beam/B in beams)
			if(B && !B.dying) return 1
	for(var/obj/Skills/Projectile/P in src)
		if(P.Area == "Beam" && P.Charging) return 1
	return 0

mob/proc/BeamsRelease(obj/Skills/Projectile/Z)
	if(!beams) return
	for(var/datum/beam/B in beams.Copy())
		if(!Z || B.skill == Z) B.Release()

mob/proc/BeamsKill()
	if(!beams) return
	for(var/datum/beam/B in beams.Copy())
		B.Die()
	beams = null
