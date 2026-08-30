mob
	var/tmp/obj/Effects/ShiftAuraEffect/shiftAura

obj/Effects/ShiftAuraEffect
	icon = 'FocusShiftAura.dmi'
	icon_state = "Force"
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	mouse_opacity = 0
	pixel_x = -16
	pixel_y = -16
	Lifetime = -1

	New(var/shift_type)
		..()

		if(shift_type == "STR")
			color = "#FF0000"

		filters += filter(
			type = "drop_shadow",
			x = 0,
			y = 0,
			size = 6,
			offset = 0,
			color = shift_type == "STR" ? "#FF4040" : "#FFEE83"
		)


mob/proc/UpdateShiftAura(type)
	if(!FocusShiftActive)
		HideShiftAura()
		return

	if(!shiftAura)
		for(var/obj/Effects/ShiftAuraEffect/B in vis_contents)
			if(!shiftAura)
				shiftAura = B
			else
				vis_contents -= B
				del B

		if(!shiftAura)

			shiftAura = new /obj/Effects/ShiftAuraEffect(type)
			vis_contents += shiftAura

mob/proc/HideShiftAura()
	if(shiftAura)
		vis_contents -= shiftAura
		del shiftAura
		shiftAura = null

mob/proc/ActivateFocusShift(type, multiplier, timer, identity)
	if(!identity) return //STR/FOR only
	var/bonusMult = passive_handler.Get("FocusShiftBurst")
	var/bonusTime = passive_handler.Get("FocusShiftMastery")
	if(FocusShiftActive)
		src << "FocusShift is already up! (Type: [FocusShiftType])"
		return
	if(FocusShiftCooldown > 0)
		src << "FocusShift is still on cooldown! (CD: [FocusShiftCooldown/2])"
		return

	FocusShiftActive = TRUE
	if(type != "None")
		FocusShiftType = type
	else
		FocusShiftType = identity == "STR" ? "FOR" : "STR"
	FocusShiftBoost = multiplier + (0 + bonusMult)
	FocusShiftTimer = timer + (0 + bonusTime*2)
	if(FocusShiftActive && passive_handler.Get("Fox Spirit")) // Fox Spirit Doubles boost, halves power
		FocusShiftBoost = (multiplier + (0 + bonusMult)) * 2
		FocusShiftTimer = (timer + (0 + bonusTime*2)) / 2
	src << "<b>FocusShift activated!</b> (Type: [FocusShiftType]. Boost: [FocusShiftBoost])"
	UpdateShiftAura(FocusShiftType)

mob/proc/FocusShiftScaling(identity, statType, scale)
	//active shift + matching skill identity = that stat's scaling is boosted, floored at 1.5. Zero scaling still gets the floor.
	if(!FocusShiftActive || FocusShiftType != statType || identity != statType) return scale
	return max(scale * FocusShiftBoost, 1.5)