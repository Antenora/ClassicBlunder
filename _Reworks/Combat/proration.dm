mob/var/tmp/cc_combo_hits = 0

//staggered = burst window, full damage, no counting
mob/proc/ccActive(includeSuspended = 0)
	if(passive_handler.Get("Staggered!")) return 0
	return (Stunned || Launched || (includeSuspended && Suspended))

mob/proc/ccFloor(skillCM = 0, dunk = 0)
	var/f = glob.PRORATION_FLOOR
	var/cm = max(skillCM, passive_handler.Get("ComboMaster"))
	f += cm * glob.PRORATION_CM_FLOOR_BONUS
	if(passive_handler.Get("HotHundred") || passive_handler["Speed Force"] >= 2)
		f += glob.PRORATION_LIGHT_FLOOR_BONUS
	if(dunk) f = max(f, glob.PRORATION_DUNK_FLOOR)
	return min(f, 1)

mob/proc/ccProrationMult(mob/attacker, includeSuspended = 0, skillCM = 0, dunk = 0)
	if(!ccActive(includeSuspended)) return 1
	var/cm = max(skillCM, attacker.passive_handler.Get("ComboMaster"))
	var/decay = max(0, glob.PRORATION_DECAY - cm * glob.PRORATION_CM_DECAY_CUT)
	return max(attacker.ccFloor(skillCM, dunk), 1 - decay * cc_combo_hits)

mob/proc/ccCountHit(includeSuspended = 0)
	if(ccActive(includeSuspended)) cc_combo_hits++
