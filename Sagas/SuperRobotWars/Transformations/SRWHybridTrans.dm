datum/mech_transformation/SuperMode
	id = "super_mode"
	name = "Super Mode"
	description = "Martial prowess and a clear mind brings out the full potential of your mech."
	requires_install = FALSE
	required_will = 130
	required_heat_below = 80
	activation_heat = 20
	transform_color_space = FILTER_COLOR_HSL
	transform_glow = TRUE
	transform_color = list(
		0, 0,    0, 0,
		0, 0.65, 0, 0,
		0, 0,    1, 0,
		0, 0,    0, 1,
		0.12, 0.35, 0.03, 0
	)
	granted_passives = list(
		"SuperMode" = 1,
		"MechNoStagger" = 1
	)
	granted_skills = list()
	ModifyStat(mob/User, obj/Items/Mech/Mech, stat, amount)
		switch(stat)
			if("Str")
				amount *= 1.10
			if("For")
				amount *= 1.10
			if("Spd")
				amount *= 1.10
			if("End")
				amount *= 1.15
		return amount

	ModifyHeatCost(mob/User, obj/Items/Mech/Mech, amount, obj/source)
		return amount * 1.25
	OnTransform(mob/User, obj/Items/Mech/Mech)
		FlashTransformMoment(User)
		User.OMessage(10,"<b>[User]'s fighting spirit manifests as a golden glow, and their machine enters Super Mode!</b>")
	OnRevert(mob/User, obj/Items/Mech/Mech)
		User.OMessage(10,"<b>[User]'s mech returns to its normal configuration.</b>")