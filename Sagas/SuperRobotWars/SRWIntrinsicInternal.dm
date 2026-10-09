//Real

//Mobile Suit Gundam
obj/Items/MechPart/Internal/IntrinsicLearningComputer
	name = "Learning Computer"
	desc = "Internal Slot. Increases Piloting XP gained by 20%, until it has provided 700 bonus XP."
	intrinsic_template_id = "learning_computer"
	Grabbable = 0


datum/mech_intrinsic_part/LearningComputer
	id = "learning_computer"
	name = "Learning Computer"
	description = "Internal Slot. Increases Piloting XP gained by 20%, until it has provided 700 bonus XP."
	slot_family = "Internal"
	part_type = /obj/Items/MechPart/Internal/IntrinsicLearningComputer
	pilot_requires_unlock = FALSE

	var/xp_gain_mult = 1.2
	var/xp_cap_index = 3
	var/cap_warning_delay = 50 // Five seconds in deciseconds.

	proc/PilotXPBonusCap()
		if(!glob.MECH_PROWESS_XP || !glob.MECH_PROWESS_XP.len)
			return 0
		var/index = clamp(xp_cap_index, 1, glob.MECH_PROWESS_XP.len)
		return glob.MECH_PROWESS_XP[index]

	ModifyPilotXPGain(mob/User, obj/Items/Mech/R, amount, list/state)
		if(!User || amount <= 0)
			return amount
		var/bonus_cap = PilotXPBonusCap()
		var/remaining = max(bonus_cap - User.LearningComputerPilotXPGained, 0)
		if(remaining <= 0)
			return amount
		var/bonus = amount * (xp_gain_mult - 1)
		bonus = min(bonus, remaining)
		User.LearningComputerPilotXPGained += bonus
		return amount + bonus

	OnTick(mob/User, obj/Items/Mech/R, dt, list/state)
		if(!User || !R || !islist(state))
			return
		var/bonus_cap = PilotXPBonusCap()
		if(User.LearningComputerPilotXPGained < bonus_cap)
			state["cap_warning_elapsed"] = 0
			return
		var/warned_cap = state["warned_cap"]
		if(isnum(warned_cap) && warned_cap >= bonus_cap)
			return
		var/elapsed = state["cap_warning_elapsed"]
		if(!isnum(elapsed))
			elapsed = 0
		elapsed += max(dt, 0)
		state["cap_warning_elapsed"] = elapsed
		if(elapsed < cap_warning_delay)
			return
		state["warned_cap"] = bonus_cap
		state["cap_warning_elapsed"] = 0
		User << "<b>The Learning Computer has reached its maximum training capacity. It can now be safely removed from [R].</b>"