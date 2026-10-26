obj/Items/Sword/Medium/Legendary/Arrancar/Zanpakuto
	name = "Zanpakuto"
	icon = 'Goemon Katana Unsheathed.dmi'
	pixel_x = -16
	pixel_y = -16
	Ascended = 2
	Destructable = 0
	Stealable = 0
	ShatterTier = 0
	PermEquip = 1
	Cost = 0
	Unobtainable = 1

mob
	var
		tmp/image/HollowMaskImage
		HollowMaskState = ""
		HollowMaskX = 0
		HollowMaskY = 0
		HollowMaskLayer = 0

/proc/HollowMaskIcon()
	return 'Bone_Mask.dmi'

/mob/proc/HollowBuildMaskImage()
	if(!src.HollowArrancar)
		return null
	if(src.HollowMaskImage)
		return src.HollowMaskImage
	src.HollowMaskImage = image(icon = HollowMaskIcon(), icon_state = src.HollowMaskState, pixel_x = src.HollowMaskX, pixel_y = src.HollowMaskY, layer = FLOAT_LAYER - src.HollowMaskLayer)
	return src.HollowMaskImage

/mob/proc/HollowApplyMask()
	var/image/im = src.HollowBuildMaskImage()
	if(!im)
		return
	src.overlays -= im
	src.overlays += im

/mob/Players/AppearanceOn()
	..()
	if(src.HollowArrancar)
		src.HollowApplyMask()

/mob/proc/HollowBodyChoices()
	var/list/out = list()
	if(!src.race)
		return out
	for(var/race/R in races)
		if(!R || R.removed)
			continue
		if(R.name != "Human")
			continue
		var/n = 0
		for(var/i in R.icon_male)
			n++
			out["Male [n]"] = i
		n = 0
		for(var/i in R.icon_female)
			n++
			out["Female [n]"] = i
	return out

/mob/proc/HollowPickBody()
	var/list/choices = src.HollowBodyChoices()
	if(!choices.len)
		return 0
	var/pick_label = Ask(src, "Your Hollow body unravels. What shape does it settle into?", "Arrancar Body", null, "pick", choices, 1)
	if(isnull(pick_label))
		return 0
	src.icon = choices[pick_label]
	src.icon_state = ""
	src.AppearanceOn()
	return 1

/mob/proc/HollowGiveZanpakuto()
	for(var/obj/Items/Sword/Medium/Legendary/Arrancar/Zanpakuto/had in src)
		return had
	var/cls = Ask(src, "The fragment of mask left in your hand hardens into a blade. What form does it take?", "Zanpakuto Class", null, "pick", list("Light", "Medium", "Heavy"), 0)
	var/obj/Items/Sword/Medium/Legendary/Arrancar/Zanpakuto/z = new(src)
	z.Class = cls
	z.setStatLine()
	return z

/mob/proc/HollowConvertBody()
	if(!src.HollowArrancar)
		return
	src.HollowPickBody()
	src.HollowApplyMask()
	src.HollowGiveZanpakuto()
	src.HollowGrantHierro()
	src.HollowSyncSkills()
	OMsg(src, "<b><font color=#e8e8e8>[src] tears its mask away.</font></b>")

/mob/HollowStageSkillSet()
	. = ..()
	if(!islist(.))
		return .
	if(src.HollowArrancar)
		. += /obj/Skills/Projectile/Arrancar/Bala
		. += /obj/Skills/Arrancar/Sonido
		. += /obj/Skills/Buffs/SlotlessBuffs/Regeneration/High_Speed_Regeneration
		. += /obj/Skills/Hollow/Customize_Body
		if(src.AscensionsAcquired >= 4 && !src.HollowSpec)
			. += /obj/Skills/Hollow/Specialize
	else if(HollowStageOrder(src.HollowStage) >= 2)
		. += /obj/Skills/Hollow/Rip_Mask

/obj/Skills/Hollow/Rip_Mask
	name = "Rip Mask"
	desc = "Tear the rest of your mask away and become an Arrancar."

	verb/Rip_Mask()
		set name = "Rip Mask"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(!User.HollowIsHollow() || User.HollowArrancar)
			return
		if(HollowStageOrder(User.HollowStage) < 2)
			User << "<font color=red>A Menos Grande cannot tear its own mask off.</font>"
			return
		var/warn = "Tear off your mask and become an Arrancar? You take a humanoid body, a Zanpakuto, Hierro, High-Speed Regeneration, Sonido and Bala."
		if(!User.HollowVastoRolled)
			warn += " Your evolution stops here for good, and you give up your chance at Vasto Lorde."
		else
			warn += " Your evolution stops here for good."
		var/choice = Ask(User, warn, "Rip Mask", null, "confirm", null, 1, "Rip It Off", "Not yet")
		if(choice != "Rip It Off")
			return
		spawn()
			if(!User || User.HollowArrancar)
				return
			if(!User.HollowBecomeArrancar(HOLLOW_ARRANCAR_NATURAL))
				return
			User.HollowConvertBody()

/obj/Skills/Hollow/Customize_Body
	name = "Customize Body"
	desc = "Settle into a different humanoid shape."

	verb/Customize_Body()
		set name = "Customize Body"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(!User.HollowIsHollow() || !User.HollowArrancar)
			return
		spawn()
			if(User.HollowPickBody())
				User.HollowApplyMask()
