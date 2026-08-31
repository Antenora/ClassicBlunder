mob/var/tmp
	Guarding = 0
	GuardMeter = 0
	alpha_counter_ready_at = 0
	charge_started_at = 0
	charge_hits_taken = 0
	charge_lockout_until = 0
	charge_power_stress = 0

mob/proc/IsGuarding()
	return Guarding

mob/proc/IsGuardBroken()
	return world.time < guard_broken_until

mob/proc/IsChargingEnergy()
	return ChargingEnergy

mob/Players
	verb
		Guard()
			set hidden = 1
			set instant = 1
			src.GuardStart()
		Guard_up()
			set hidden = 1
			set instant = 1
			src.GuardStop()
		Charge()
			set hidden = 1
			set instant = 1
			src.ChargeStart()
		Charge_up()
			set hidden = 1
			set instant = 1
			src.ChargeStop()

mob/proc/GuardStart()
	if(CancelChargingBeam())
		return

	if(Guarding) return
	if(KO || Stunned || Launched || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen || Airborne) return
	if(grabbed || istype(loc, /mob)) return
	if(Beaming || BusterCharging || PoweringUp || ChargingEnergy) return
	if(icon_state == "Meditate" || icon_state == "Train" || icon_state == "KB") return
	if(IsGuardBroken()) return
	if(splat_stagger_until > world.time) return
	Guarding = 1
	KenShockwave(src, icon = 'KenShockwaveFocus.dmi', Size = 0.3, Blend = 2, Time = 2)
	FlashGuardPlate(1)

mob/proc/GuardStop(broken = 0)
	if(!Guarding && !broken) return
	Guarding = 0
	FlashGuardPlate(broken ? 2 : 0)
	if(broken)
		guard_broken_until = world.time + glob.GUARD_BREAK_DS
		GuardMeter = 0
		flick("KB", src)
		KenShockwave(src, Size = 1, Time = 4)
		src.Earthquake(8, -4,4,-4,4, 0, 0)
		OMsg(src, "<b>[src]'s guard is shattered!</b>")

//mini kiai
mob/proc/AlphaCounter()
	if(!IsGuarding()) return
	if(world.time < alpha_counter_ready_at) return
	if(Tension < glob.ALPHA_COUNTER_TENSION)
		src << "Not enough tension!"
		return
	Tension = max(0, Tension - glob.ALPHA_COUNTER_TENSION)
	alpha_counter_ready_at = world.time + glob.ALPHA_COUNTER_CD_DS
	KenShockwave(src, icon = 'fevKiai.dmi', Size = 1, Blend = 2, Time = 4)
	FlashAlphaCounter(src)
	src.OMessage(10, "[src] repels their attackers with a burst of ki!", "[src] alpha counters")
	for(var/mob/m in orange(glob.ALPHA_COUNTER_RANGE, src))
		if(m == src || m.KO || m.Stasis) continue
		if(inParty(m.ckey)) continue
		var/mob/rv = m
		spawn(clamp(round(bounds_dist(src, rv) / 48), 0, 4))
			if(rv) KenShockwave(rv, Size = 0.4, Blend = 2, Time = 3)
		src.Knockback(glob.ALPHA_COUNTER_KB, m, Direction = get_dir(src, m), Forced = 1)

mob/proc/ChargeStart()
	if(ChargingEnergy) return
	if(world.time < charge_lockout_until) return
	if(KO || Stunned || Launched || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen || Airborne) return
	if(grabbed || istype(loc, /mob)) return
	if(Beaming || BusterCharging || PoweringUp || Guarding) return
	if(icon_state == "Meditate") return
	//if(Energy >= 100 - TotalFatigue) return   -- disabling so you can charge even at full energy for the sake of Power Stress activation
	ChargingEnergy = 1
	charge_started_at = world.time
	charge_hits_taken = 0
	Auraz("Add")
	FlashChargeTick(src, 0)

mob/proc/ChargeStop()
	if(!ChargingEnergy) return
	ChargingEnergy = 0
	charge_power_stress = 0
	Auraz("Remove")

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

//counter-hit: tag someone mid-commitment and it lands heavier + feeds tension
mob/var/tmp
	guard_broken_until = 0
	ChargingEnergy = 0

//committed = locked into something punishable
mob/proc/isCommitted()
	if(PoweringUp) return 1
	if(Beaming) return 1
	if(WindingUp) return 1
	if(BuffingUp) return 1
	if(held_skill) return 1
	if(splat_stagger_until > world.time) return 1
	if(world.time < guard_broken_until) return 1
	if(ChargingEnergy) return 1
	return 0

proc/CounterHitReward(mob/attacker, mob/victim, weight)
	attacker.gainTension(glob.COUNTER_HIT_TENSION)
	var/froze = HitStop(attacker, victim, max(weight, glob.HIT_STOP_MIN), glob.COUNTER_HIT_STOP_BONUS)
	FlashCounterMoment(attacker, victim, froze)


mob/proc/CancelChargingBeam()
	var/obj/Skills/Z = held_skill

	if(!Z || !Z.HeldBeam)
		return FALSE

	if(passive_handler.Get("BeamHoldMastery"))
		FizzleHeldSkill(Z, TRUE)
	else
		FizzleHeldSkill(Z, FALSE)
	return TRUE