mob/var/tmp
	Guarding = 0
	GuardMeter = 0
	alpha_counter_ready_at = 0
	charge_started_at = 0
	charge_hits_taken = 0
	charge_lockout_until = 0

mob/proc/IsGuarding()
	return glob.GUARD_SYSTEM && Guarding

mob/proc/IsGuardBroken()
	return glob.GUARD_SYSTEM && world.time < guard_broken_until

mob/proc/IsChargingEnergy()
	return glob.ACTIVE_ENERGY_CHARGE && ChargingEnergy

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
	if(!glob.GUARD_SYSTEM || Guarding) return
	if(KO || Stunned || Launched || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen || Airborne) return
	if(grabbed || istype(loc, /mob)) return
	if(Beaming || BusterCharging || PoweringUp || ChargingEnergy) return
	if(icon_state == "Meditate" || icon_state == "Train" || icon_state == "KB") return
	if(IsGuardBroken()) return
	if(splat_stagger_until > world.time) return
	Guarding = 1
	KenShockwave(src, icon = 'KenShockwaveFocus.dmi', Size = 0.3, Blend = 2, Time = 2)

mob/proc/GuardStop(broken = 0)
	if(!Guarding && !broken) return
	Guarding = 0
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
	src.OMessage(10, "[src] repels their attackers with a burst of ki!", "[src] alpha counters")
	for(var/mob/m in orange(glob.ALPHA_COUNTER_RANGE, src))
		if(m == src || m.KO || m.Stasis) continue
		if(inParty(m.ckey)) continue
		src.Knockback(glob.ALPHA_COUNTER_KB, m, Direction = get_dir(src, m), Forced = 1)

mob/proc/ChargeStart()
	if(!glob.ACTIVE_ENERGY_CHARGE || ChargingEnergy) return
	if(world.time < charge_lockout_until) return
	if(KO || Stunned || Launched || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen || Airborne) return
	if(grabbed || istype(loc, /mob)) return
	if(Beaming || BusterCharging || PoweringUp || Guarding) return
	if(icon_state == "Meditate") return
	if(Energy >= 100 - TotalFatigue) return
	ChargingEnergy = 1
	charge_started_at = world.time
	charge_hits_taken = 0
	Auraz("Add")

mob/proc/ChargeStop()
	if(!ChargingEnergy) return
	ChargingEnergy = 0
	Auraz("Remove")
