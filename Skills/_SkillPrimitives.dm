mob/var/tmp/list/skill_hit_ledger
mob/var/tmp/last_ranged_hit_time = 0
mob/var/tmp/last_skill_fire_time = 0
mob/var/tmp/perfect_guard_until = 0
mob/var/tmp/last_ranged_hit_power = 0
mob/var/tmp/phantom_mark_until = 0
mob/var/tmp/mob/phantom_mark_by
mob/var/tmp/phantom_mark_damage = 0
mob/var/tmp/pre_weave_sdtl = 0
mob/var/tmp/last_combo_warp_dist = 0
mob/var/tmp/rush_vuln_until = 0
mob/var/tmp/last_damaged_time = 0
mob/var/tmp/pain_amount = 0
mob/var/tmp/pain_stamp = 0
mob/var/tmp/nerve_weaken = 0
mob/var/tmp/nerve_weaken_until = 0
mob/var/tmp/proj_immune_until = 0
mob/var/tmp/cc_immune_until = 0
mob/var/tmp/openings_hits = 0
mob/var/tmp/openings_expire = 0
mob/var/tmp/mob/openings_target
mob/var/tmp/splat_bonus = 0
mob/var/tmp/splat_bonus_until = 0
mob/var/tmp/mob/last_attacker

mob/var/tmp/image/phantom_mark_fx
mob/var/tmp/wall_cling_until = 0

mob/proc/RushWallCling()
	dir = turn(dir, 180)
	wall_cling_until = world.time + 5
	var/cling_end = world.time + 5
	while(world.time < cling_end)
		if(KO || Stunned || (Stasis > 0) || Suspended)
			wall_cling_until = 0
			return FALSE
		sleep(1)
	wall_cling_until = 0
	return TRUE

proc/applySilence(mob/target, duration)
	if(!target || !target.passive_handler)
		return
	target.passive_handler.Increase("Silenced", 1)
	spawn(duration)
		if(target && target.passive_handler)
			target.passive_handler.Decrease("Silenced", 1)

proc/applyPhantomMarkFX(mob/target, duration)
	if(!target)
		return
	clearPhantomMarkFX(target)
	var/image/I = image(icon = target.icon, icon_state = target.icon_state)
	I.color = "#8a2be2"
	I.alpha = 100
	I.pixel_y = 10
	I.appearance_flags = RESET_COLOR | RESET_ALPHA
	target.phantom_mark_fx = I
	target.overlays += I
	spawn(duration)
		if(target && target.phantom_mark_fx == I)
			clearPhantomMarkFX(target)

proc/clearPhantomMarkFX(mob/target)
	if(!target || !target.phantom_mark_fx)
		return
	target.overlays -= target.phantom_mark_fx
	target.phantom_mark_fx = null

proc/applyCursedWounds(mob/target, duration)
	if(!target || !target.passive_handler)
		return
	target.passive_handler.Increase("CursedWounds", 1)
	spawn(duration)
		if(target && target.passive_handler)
			target.passive_handler.Decrease("CursedWounds", 1)

obj/Skills
	var/SustainPour = 0
	var/tmp/sustain_pour_bank = 0
	var/tmp/list/recharge_ends
	var/RushCarry = 0
	var/RushProjImmune = 0
	var/RushTally = 0
	var/tmp/list/rush_passed_mobs
	var/BonusVsStunned = 0
	var/BonusVsSlowed = 0
	var/EnergyBurn = 0
	var/ApplySlow = 0
	var/FollowTarget = 0
	var/CCImmuneCast = 0
	var/QueueWindup = 0
	var/RiposteOnDodge = 0
	var/GrandOpenings = 0
	var/SplatBonus = 0
	var/SquareArea = 0
	var/SequenceStrokes = 1
	var/PassStrikes = 0
	var/RushBounce = 0
	var/tmp/rush_bounced = 0
	var/DrainToSelf = 0
	var/SlowPinAt = 0
	var/EraseProjectiles = 0
	var/ChainBlockStop = 0
	var/tmp/mob/chain_victim
	var/PairBonusSkill
	var/PairBonusWindow = 40
	var/PairBonusMult = 2
	var/PhantomMark = 0
	var/PerfectGuard = 0
	var/WoundRider = 0
	var/ShatterRider = 0
	var/LedgerCashoutPer = 0
	var/LedgerCashoutCap = 5
	var/FinaleDouble = 0
	var/MashExtend = 0
	var/WeaveDodge = 0
	var/BankedRelease = 0
	var/DashScaling = 0
	var/ExecuteMortal = 0
	var/WeakenRider = 0
	var/CrescendoRider = 0
	var/JuggleBonus = 0
	var/KillCounter = 0
	var/StoredPain = 0
	var/RootRider = 0
	var/tmp/strokes_landed = 0
	var/tmp/finale_rounds = 0
	var/tmp/mash_pending = 0
	var/tmp/mash_extends = 0
	var/tmp/flurry_live = 0
	var/tmp/bank_stacks = 0
	var/tmp/kill_stacks = 0
	var/tmp/kill_stamp = 0
	var/tmp/chain_until = 0
	var/tmp/recast_count = 0

obj/Skills/Projectile
	var/EmitChild
	var/EmitCount = 0
	var/EmitEvery = 1
	var/HomingBeam = 0
	var/BlendAdd = 0
	var/FollowFacing = 0
	var/ArcShot = 0
	var/BackfireShot = 0

obj/SkillPillar
	icon = 'RisingRocks.dmi'
	density = 1
	Savable = 0
	layer = 4
	New()
		. = ..()
		spawn(40)
			src.loc = null

obj/Skills/Projectile/Infinity_Trap_Snare
	Area = "Blast"
	Static = 1
	Blasts = 1
	DamageMult = 0.4
	MultiHit = 4
	StrScaling = 1
	AccMult = 1.5
	Deflectable = 0
	Distance = 100
	Radius = 1
	IconLock = 'BLANK.dmi'
	Slashing = 1

obj/Skills/Projectile
	var/BlastRamp = 0
	var/BlastRampFloor = 1
	var/PushBack = 0
	var/KBRamp = 0
	var/CounterNova = 0
	var/ClashBonus = 0
	var/tmp/sustain_clash = 0
	var/DartAtAttacker = 0
	var/WarpResetCD = 0

obj/Skills/Projectile/_Projectile
	var/tmp/pushback_taken = 0
	var/tmp/storm_dropped = 0

proc/ProjectilePushBack(obj/Skills/Projectile/_Projectile/nova, obj/Skills/Projectile/_Projectile/other)
	if(!nova || nova.Killed || !nova.loc)
		return
	var/fwd = nova.dir
	step(nova, turn(fwd, 180))
	nova.dir = fwd
	nova.pushback_taken++
	if(nova.pushback_taken >= nova.PushBack)
		var/mob/orig = nova.Owner
		var/mob/pusher = other ? other.Owner : null
		if(!pusher || pusher == orig)
			return
		nova.pushback_taken = 0
		if(orig)
			orig.active_projectiles -= nova
		nova.Owner = pusher
		pusher.active_projectiles |= nova
		nova.Homing = orig
		nova.forcedTarget = orig
		nova.HyperHoming = 1
		nova.Distance = max(nova.Distance, 20)
		OMsg(pusher, "<b>[pusher] forces the [nova] back upon its caster!</b>")

proc/SlamWaveLeapArmed(mob/u)
	if(!u)
		return null
	var/obj/Skills/AutoHit/Slam_Wave/sw = locate(/obj/Skills/AutoHit/Slam_Wave, u.contents)
	if(sw && sw.LeapArmed > world.time && !sw.Using && !sw.cooldown_remaining)
		return sw
	return null

obj/Skills/Projectile/EBF_Splash
	Area = "Blast"
	Static = 1
	Blasts = 1
	DamageMult = 1
	StrScaling = 1
	ForScaling = 0.5
	AccMult = 2
	Deflectable = 0
	Distance = 1
	Radius = 1
	IconLock = 'BLANK.dmi'

mob/var/tmp/mud_slow_next = 0

/obj/leftOver/MudField
	density = 0
	lifetime = 4 SECONDS
	var/slow_power = 3
	var/slow_interval = 10
	New(turf/_loc, mob/p)
		..()
		init(p)
		for(var/mob/m in tick_on)
			apply_mud(m)
	proc/apply_mud(mob/m)
		if(!m || m == owner || m.KO) return
		if(owner && owner.inParty(m.ckey)) return
		if(world.time < m.mud_slow_next)
			return
		m.mud_slow_next = world.time + slow_interval
		m.AddSlow(slow_power, owner)
	on_tick()
		for(var/mob/m in tick_on)
			apply_mud(m)
	Cross(atom/movable/O)
		. = ..()
		if(ismob(O) && O != owner)
			apply_mud(O)

proc/SuplexSwap(mob/User, mob/Trg)
	if(!User || !Trg || User.z != Trg.z)
		return
	var/turf/ut = get_turf(User)
	var/turf/tt = get_turf(Trg)
	if(!ut || !tt || ut == tt)
		return
	if(ut.density || tt.density)
		return
	for(var/mob/o in ut)
		if(o != User && o != Trg && o.density)
			return
	for(var/mob/o in tt)
		if(o != User && o != Trg && o.density)
			return
	var/usx = User.step_x
	var/usy = User.step_y
	var/tsx = Trg.step_x
	var/tsy = Trg.step_y
	User.loc = tt
	User.step_x = tsx
	User.step_y = tsy
	Trg.loc = ut
	Trg.step_x = usx
	Trg.step_y = usy
	Trg.dir = User.dir

mob/proc/SkillLedgerKey(mob/attacker, skill_path)
	return "\ref[attacker]|[skill_path]"

mob/proc/NoteSkillHit(mob/attacker, skill_path)
	if(!attacker || !skill_path)
		return
	if(!skill_hit_ledger)
		skill_hit_ledger = list()
	skill_hit_ledger[SkillLedgerKey(attacker, skill_path)] = world.time
	if(skill_hit_ledger.len > 64)
		skill_hit_ledger.Cut(1, skill_hit_ledger.len - 47)

mob/proc/RecentSkillHitBy(mob/attacker, skill_path, window)
	if(!attacker || !skill_hit_ledger)
		return 0
	var/t = skill_hit_ledger[SkillLedgerKey(attacker, skill_path)]
	if(!t)
		return 0
	return (world.time - t <= window)

mob/proc/DistinctRecentSkillHitsBy(mob/attacker, window)
	if(!attacker || !skill_hit_ledger)
		return 0
	var/prefix = "\ref[attacker]|"
	. = 0
	for(var/k in skill_hit_ledger)
		if(world.time - skill_hit_ledger[k] > window)
			continue
		if(findtext(k, prefix) == 1)
			.++
