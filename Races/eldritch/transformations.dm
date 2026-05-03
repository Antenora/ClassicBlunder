transformation
	eldritch
		partial_manifestation
			passives = list("Unreality" = 0.1, "Half Manifestation" = 1, "PureDamage"=2, "PureReduction"=2,"DebuffResistance"=0.1, "BuffMastery"=3)
			form_icon_1_icon = 'tentacles_overlay.dmi'
			form_icon_1_x = -32
			form_icon_1_y = -32
			form_underlay_1_icon = 'tenacles_underlay.dmi'
			form_underlay_1_x = -32;
			form_underlay_1_y = -32;
			transformation_message = "Reality begins to fray around usrName. Comprehension eludes you."
			mastery_boons(mob/user)
				enduranceadd = 0.05*user.AscensionsAcquired
				offenseadd = 0.05*user.AscensionsAcquired
				defenseadd = 0.05*user.AscensionsAcquired
				strengthadd = 0.05*user.AscensionsAcquired
				forceadd = 0.05*user.AscensionsAcquired
			transform_animation(mob/user)
				LightningStrike2(user)
				DarknessFlash(user, SetTime=5)
		full_manifestation
			passives = list("Unreality" = 0.9, "Full Manifestation" = 1, "PureDamage"=3, "PureReduction"=3,"DebuffResistance"=0.1, "BuffMastery"=3)
			transformation_message = "usrName reveals itself to the detriment of all!"
			mastery_boons(mob/user)
				enduranceadd = 0.125*user.AscensionsAcquired
				offenseadd = 0.125*user.AscensionsAcquired
				defenseadd = 0.125*user.AscensionsAcquired
				strengthadd = 0.125*user.AscensionsAcquired
				forceadd = 0.125*user.AscensionsAcquired
			transform_animation(mob/user)
				LightningStrike2(user)
				DarknessFlash(user, SetTime=5)

/mob/proc/HandleManifestation(Stat)
	var/CA=AscensionsAcquired
	var/TA=3
	var/Total
	if(passive_handler.Get("Full Manifestation"))
		TA=6
	if(CA<3)
		Total=PullAscensionStats(CA, TA, Stat)
	else if(CA>=3 && CA<6)
		Total=PullAscensionStats(CA, CA+1, Stat)
	else
		Total=PullAscensionStats(CA, TA, Stat)
	return Total