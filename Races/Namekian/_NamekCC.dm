/obj/Skills/Buffs/SlotlessBuffs/Autonomous/var/tmp/namek_applied_at = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Target_Lock
	name = "Taunted"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 3
	ActiveMessage = "is locked onto their challenger!"
	OffMessage = "breaks free of the taunt."

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Fear
	name = "Feared"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 3
	ActiveMessage = "is gripped by fear!"
	OffMessage = "steadies their nerve."
	var/tmp/mob/fearer

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Oath
	name = "Dragon's Oath"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 20
	ActiveMessage = "is sworn under a dragon's oath!"
	OffMessage = "is no longer sworn under the oath."

/mob/proc/NamekApplyTimedBuff(path, seconds)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/B = src.findOrAddSkill(path)
	if(!istype(B))
		return null
	if(src.BuffOn(B))
		B.Trigger(src, TRUE)
	B.TimerLimit = seconds
	B.Trigger(src, TRUE)
	var/stamp = world.time
	B.namek_applied_at = stamp
	spawn(round(seconds * 10) + 1)
		if(src && B && B.namek_applied_at == stamp && src.BuffOn(B))
			B.Trigger(src, TRUE)
	return B

/mob/proc/NamekOathActive()
	return src.NamekOathUntil > world.time

/mob/proc/NamekLockBlocked()
	if(NamekOathActive())
		return 1
	if(src.cc_immune_until > world.time)
		return 1
	return src.NamekTargetLockImmuneUntil > world.time

/mob/proc/NamekTargetLock(mob/locker, seconds)
	if(!ismob(locker) || locker == src || src.KO)
		return 0
	if(NamekLockBlocked())
		return 0
	var/mod = src.passive_handler ? src.passive_handler.Get("Juggernaut") * 0.25 : 0
	var/ticks = seconds * 10 / max(0.1, 1 + mod)
	src.NamekTargetLockTo = locker
	src.NamekTargetLockUntil = world.time + ticks
	var/held_block = src.target_lock_block_until
	src.target_lock_block_until = 0
	src.SetTarget(locker)
	src.target_lock_block_until = held_block
	if(src.Target != locker)
		src.NamekTargetLockTo = null
		src.NamekTargetLockUntil = 0
		return 0
	src.NamekTargetLockImmuneUntil = src.NamekTargetLockUntil + glob.STUN_IMMUNE_TIMER * (1 + mod)
	NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Target_Lock, ticks / 10)
	src << "<font color=#ff6666>[locker] forces your attention onto them!</font>"
	return 1

/mob/proc/NamekFearBlocked()
	if(NamekOathActive())
		return 1
	return src.cc_immune_until > world.time

/mob/proc/NamekFear(mob/fearer, seconds)
	if(!ismob(fearer) || fearer == src || src.KO)
		return 0
	if(NamekFearBlocked())
		return 0
	src.NamekFearFrom = fearer
	src.NamekFearUntil = world.time + seconds * 10
	src.AddTerrifying(100, fearer)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Fear/F = NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Fear, seconds)
	if(F)
		F.fearer = fearer
	src << "<font color=#ff6666>Terror of [fearer] grips you: you cannot bring yourself to step toward them!</font>"
	return 1

/mob/Player/AI/GoAfterTarget()
	if(NamekFeared())
		NamekFleeStep()
		return
	..()

/mob/Player/AI/proc/NamekFleeStep()
	if(!Move_Requirements() || next_move >= world.time)
		return
	step_away(src, src.NamekFearFrom, 20, PmActive() ? 0 : 32 * (5 / (AI_SPEED_TOTAL * (AI_MOVE_SPEED))))
	if(ismob(src.Target))
		dir = get_dir(src, src.Target)
	next_move = world.time + NamekFearMoveMult()

/mob/Players/applyCharmed(mob/charmer, limit = 5)
	if(NamekOathActive())
		return FALSE
	return ..()

/mob/proc/NamekKitTarget(range)
	var/mob/T = src.Target
	if(!ismob(T) || T == src || T.z != src.z || get_dist(src, T) > range)
		src << "<font color='red'>You need a target within [range] tiles.</font>"
		return null
	if(T.ckey && src.inParty(T.ckey))
		src << "<font color='red'>You cannot use that on an ally.</font>"
		return null
	return T

/mob/proc/NamekPayCast(obj/Skills/S)
	S.Cooldown(1, null, src)
	if(S.EnergyCost)
		var/drain = src.passive_handler["Drained"] ? S.EnergyCost * (1 + src.passive_handler["Drained"]/10) : S.EnergyCost
		src.LoseEnergy(drain)
