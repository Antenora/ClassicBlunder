/mob/var/tmp/last_swing = 0
/mob/var/tmp/riposte_armed = 0
/mob/var/tmp/riposte_count = 0
/mob/var/tmp/riposte_first = 0

/mob/proc/SwordPassive(name)
	if(!passive_handler)
		return 0
	return passive_handler.Get(name)

/mob/SheathedDraw()
	. = ..()
	var/v = SwordPassive("Sheathed")
	if(v > 0 && world.time - last_swing >= SWORDP_SHEATHED_IDLE && EquippedSword())
		. = SWORDP_SHEATHED_DMG * v
	last_swing = world.time

/mob/ParryLanded()
	..()
	if(SwordPassive("Parry Riposte") <= 0)
		return
	if(!riposte_count || world.time - riposte_first > SWORDP_RIPOSTE_WINDOW)
		riposte_count = 0
		riposte_first = world.time
	riposte_count++
	if(riposte_count < SWORDP_RIPOSTE_PARRIES)
		return
	riposte_count = 0
	if(!riposte_armed)
		riposte_armed = 1
		src << "<b>Riposte ready!</b>"

/mob/RiposteReady()
	return ..() || (riposte_armed && SwordPassive("Parry Riposte") > 0)

/mob/RiposteConsume(obj/Skills/Queue/Q)
	..()
	if(!riposte_armed || !Q)
		return
	riposte_armed = 0
	if(SwordPassive("Parry Riposte") <= 0)
		return
	Q.unparryable = 1
	Q.energy_free = 1
	src << "<b>Riposte!</b>"

/mob/OverheadIgnores(mob/attacker)
	. = ..()
	if(. || !attacker || !attacker.AttackQueue)
		return
	if(attacker.SwordPassive("Overhead") > 0)
		return 1

/mob/OverheadSwordHit(reversal = 0)
	. = ..()
	if(.)
		return
	var/v = SwordPassive("Overhead")
	if(v <= 0 || (reversal && v < SWORDP_OVERHEAD_REVERSAL))
		return 0
	return 1

/mob/DashCrossStep(mob/Trg, list/cut)
	..()
	if(!cut || AttackQueue || !EquippedSword())
		return
	var/v = SwordPassive("Battojutsu")
	if(v <= 0)
		return
	var/list/found = list()
	for(var/mob/M in obounds(src))
		found |= M
	if(v >= SWORDP_BATTO_ARC && isturf(loc))
		for(var/side in list(turn(dir, 90), turn(dir, -90)))
			var/turf/T = get_step(loc, side)
			if(!T)
				continue
			for(var/mob/M in bounds(T))
				found |= M
	for(var/mob/M in found)
		if(M == src || M == Trg || !M.density || (M in cut))
			continue
		cut += M
		DashCrossed(M)

/mob/proc/DashCrossed(mob/M)
	set waitfor = 0
	if(!M || M.KO || M.z != z)
		return
	var/mob/held = Target
	Target = M
	Melee1(forcedTarget = M, BreakAttackRate = 1)
	if(Target == M)
		Target = held
