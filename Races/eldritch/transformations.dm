transformation
	eldritch
		partial_manifestation
			passives = list("Unreality" = 0.1, "Half Manifestation" = 1, "PureDamage"=2, "PureReduction"=2,"DebuffResistance"=0.1)
			form_icon_1_icon = 'tentacles_overlay.dmi'
			form_icon_1_x = -32
			form_icon_1_y = -32
			form_underlay_1_icon = 'tenacles_underlay.dmi'
			form_underlay_1_x = -32;
			form_underlay_1_y = -32;
			transformation_message = "Reality begins to fray around usrName. Comprehension eludes you."
			detrans_message = "usrName becomes fully real once more..."
			mastery_boons(mob/user)
				if(user.AscensionsAcquired < 3)
					user << "<font color='red'>This vessel strains to hold even half of your true Manifestation. Some boons will be lost to you.</font color>"
					passives = list("Unreality" = 0.1, "Half Manifestation" = 1, "PureDamage"=2, "PureReduction"=2,"DebuffResistance"=0.1)
				else
					passives = list("Unreality" = 0.1, "Half Manifestation" = 1)
					passives += user.PullAscensionPassives(user.AscensionsAcquired, min(user.AscensionsAcquired+1, 6));
				enduranceadd = 0.05*user.AscensionsAcquired
				offenseadd = 0.05*user.AscensionsAcquired
				defenseadd = 0.05*user.AscensionsAcquired
				strengthadd = 0.05*user.AscensionsAcquired
				forceadd = 0.05*user.AscensionsAcquired
			transform_animation(mob/user)
				LightningStrike2(user)
				DarknessFlash(user, SetTime=5)
				if(user.hasSecret("Eldritch (Shrouded)"))
					user.MobColor = list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
					animate(user, color = user.MobColor, time = 10, flags=ANIMATION_PARALLEL)
					var/image/eyes = image('AntiEyes.dmi');
					eyes.appearance_flags+=70
					user.overlays += eyes;
			revert_animation(mob/user)
				if(user.hasSecret("Eldritch (Shrouded)"))
					user.MobColor=null;
					animate(user, color = null, time = 10, flags=ANIMATION_PARALLEL)
					user.overlays -= image('AntiEyes.dmi');

		full_manifestation
			passives = list("Unreality" = 0.9, "Full Manifestation" = 1, "PureDamage"=3, "PureReduction"=3,"DebuffResistance"=0.1)
			transformation_message = "usrName reveals itself to the detriment of all!"
			detrans_message = "usrName bottles up the unreality... halfway a person..."
			mastery_boons(mob/user)
				if(user.AscensionsAcquired < 3)
					user << "<font color='red'>This vessel cannot handle the full strain of your Manifestation yet, and some boons are unavailable.</font color>"
					enduranceadd = 0
					offenseadd = 0
					defenseadd = 0
					strengthadd = 0
					forceadd = 0
					passives = list("Unreality" = 0.9, "Full Manifestation" = 1, "PureDamage"=3, "PureReduction"=3,"DebuffResistance"=0.1)
				else 
					enduranceadd = 0.1*user.AscensionsAcquired
					offenseadd = 0.1*user.AscensionsAcquired
					defenseadd = 0.1*user.AscensionsAcquired
					strengthadd = 0.1*user.AscensionsAcquired
					forceadd = 0.1*user.AscensionsAcquired
					passives = list("Unreality" = 0.9, "Full Manifestation" = 1)
					passives += user.PullAscensionPassives(min(user.AscensionsAcquired+1, 6), 6);
			transform_animation(mob/user)
				if(user.hasSecret("Eldritch (Shrouded)"))
					user.MobColor=null;
					animate(user, color = null, time = 10, flags=ANIMATION_PARALLEL)
					var/image/eyes = image('AntiEyes.dmi');
					eyes.appearance_flags+=70
					user.overlays -= eyes;
				LightningStrike2(user)
				DarknessFlash(user, SetTime=5)
			revert_animation(mob/user)
				if(user.hasSecret("Eldritch (Shrouded)"))
					user.MobColor=null;
					animate(user, color = null, time = 10, flags=ANIMATION_PARALLEL)
					var/image/eyes = image('AntiEyes.dmi');
					eyes.appearance_flags+=70
					user.overlays -= eyes;


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
