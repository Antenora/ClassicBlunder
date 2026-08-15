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

	New()
		..()
		filters += filter(
			type = "drop_shadow",
			x = 0,
			y = 0,
			size = 6,
			offset = 0,
			color = "#FFEE83"
		)


mob/proc/UpdateShiftAura()
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
			shiftAura = new /obj/Effects/ShiftAuraEffect
			vis_contents += shiftAura

mob/proc/HideShiftAura()
	if(shiftAura)
		vis_contents -= shiftAura
		del shiftAura
		shiftAura = null

mob/proc/ActivateFocusShift(type, multiplier, timer, strScale, forScale)
	if(FocusShiftActive)
		src << "FocusShift is already up! (Type: [FocusShiftType])"
		return
	if(FocusShiftCooldown > 0)
		src << "FocusShift is still on cooldown! (CD: [FocusShiftCooldown])"
		return
	var/autoSelectedType
	if(strScale > forScale)
		autoSelectedType = "FOR"
	else
		autoSelectedType = "STR"

	FocusShiftActive = TRUE
	if(type != "None")
		FocusShiftType = type
	else
		FocusShiftType = autoSelectedType
	FocusShiftBoost = multiplier
	FocusShiftTimer = timer
	src << "<b>FocusShift activated!</b> (Type: [FocusShiftType])"
	UpdateShiftAura()

