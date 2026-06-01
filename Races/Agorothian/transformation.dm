transformation
	agorothian
		var/tier = 0
		aether_surge
			tier = 1
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			//This should be apped for around 25 pot and unlocked automatically by 30pot
			unlock_potential = 30
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "PureDamage" = 1, "PureReduction" = 1)
			

			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.MapColors(0.2,0.2,0.2, 0.39,0.39,0.39, 0.07,0.07,0.07, 0.69,0.69,0)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
				form_glow.blend_mode=BLEND_ADD
				form_glow.alpha=40
				form_glow.color=list(1,0,0, 0,0.8,0, 0,0,0, 0.2,0.2,0.2)
				form_icon_2.blend_mode=BLEND_MULTIPLY
				form_icon_2.alpha=125
				form_icon_2.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)

			mastery_boons(mob/user)
				if(user.Potential>=22&&mastery<25)
					mastery=25
				if(user.Potential>=27&&mastery<50)
					mastery=50
				if(user.Potential>=30&&mastery<75)
					mastery=75
				if(user.Potential>=35&&mastery<100)
					mastery=100
				if(user.Potential>=45&&user.transUnlocked<2)
					user.transUnlocked=2
					if(mastery >= 50)
					if(mastery >= 100)
					passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "PureDamage" = 2, "PureReduction" = 2,)
				class_boons(mob/user)
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/eserthen)
					class_passives = list("AttackSpeed" = 3, "Instinct" = 2, "Flow" = 2)
					speedadd = 1
					enduranceadd = 0.3
					offenseadd = 0.5
					defenseadd = 0.5
					strengthadd = 0.3
					forceadd = 0.3
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/aethirian)
					class_passives = list("SwordDamage" = 2, "KillerInstinct" =0.2, "MovementMastery" = 10,)
					speedadd = 0.5
					offenseadd = 0.25
					defenseadd = 0.5
					strengthadd = 1
					forceadd = 1
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/isorth)
					class_passives = list("Rage" = 2, "CallousedHands" = 0.2,  "CallousedFeet" = 0.2)
					speedadd = 0.5
					enduranceadd = 1
					offenseadd = 0.3
					strengthadd = 0.5
					
		aether_resonance
			tier = 2
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ2"
			form_aura_x = -32
			form_icon_2_icon = 'SS2Sparks.dmi'
			//Autounlocked at 55, intended to be unlocked around 45 potential
			unlock_potential = 55
			autoAnger = TRUE
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2, "PureDamage" = 2, "PureReduction" = 2, "agorothianPower2"=0.5)
			PUSpeedModifier = 1.5
			
				mastery_boons(mob/user)
				if(user.Potential>=22&&mastery<25)
					mastery=25
				if(user.Potential>=27&&mastery<50)
					mastery=50
				if(user.Potential>=30&&mastery<75)
					mastery=75
				if(user.Potential>=35&&mastery<100)
					mastery=100
				if(user.Potential>=45&&user.transUnlocked<2)
					user.transUnlocked=2
					if(mastery >= 50)
					if(mastery >= 100)
					passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "PureDamage" = 2, "PureReduction" = 2)
				class_boons(mob/user)
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/eserthen)
					class_passives = list("AttackSpeed" = 3, "Instinct" = 2, "Flow" = 2)
					speedadd = 1
					enduranceadd = 0.3
					offenseadd = 0.5
					defenseadd = 0.5
					strengthadd = 0.3
					forceadd = 0.3
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/aethirian)
					class_passives = list("SwordDamage" = 2, "KillerInstinct" =0.2, "MovementMastery" = 10,)
					speedadd = 0.5
					offenseadd = 0.25
					defenseadd = 0.5
					strengthadd = 1
					forceadd = 1
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/isroth)
					class_passives = list("Rage" = 2, "CallousedHands" = 0.2,  "CallousedFeet" = 0.2)
					speedadd = 0.5
					enduranceadd = 1
					offenseadd = 0.3
					strengthadd = 0.5
			

		aether_soverign
			tier = 3
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ2"
			form_aura_x = -32
			form_icon_2_icon = 'SS3Sparks.dmi'
			form_hair_icon = 'Hair_SSj3.dmi'
			form_icon_1_icon = 'Hair_SSj3.dmi'
			passives = list("Flicker" = 1, "Pursuer" = 1, "PureDamage" = 2, "PureReduction" = 2)
			unlock_potential = 75   Can app for it as early as 65 pot
			
			enduranceadd = 0.5
			offenseadd = 0.5
			defenseadd = 0.5
			strengthadd = 0.5
			forceadd = 0.5
				class_boons(mob/user)
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/eserthen)
					class_passives = list("AttackSpeed" = 3, "Instinct" = 2, "LikeWater" = 3)
					speedadd = 1
					enduranceadd = 0.3
					offenseadd = 0.5
					defenseadd = 0.5
					strengthadd = 0.3
					forceadd = 0.3
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/aethirian)
					class_passives = list("" = 2, "KillerInstinct" =0.2, "MovementMastery" = 10,)
					speedadd = 0.5
					offenseadd = 0.25
					defenseadd = 0.5
					strengthadd = 1
					forceadd = 1
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/isorth)
					class_passives = list("Rage" = 2, "CallousedHands" = 0.2,  "CallousedFeet" = 0.2)
					speedadd = 0.5
					enduranceadd = 1
					offenseadd = 0.3
					strengthadd = 0.5

			

		

		aether_singularity
			tier = 4
			unlock_potential = 150, //endgameish trans
			passives = list("Flicker" = 1, "Pursuer" = 1, "PureDamage" = 2, "PureReduction" = 2, "Deicide" = 5, "EndlessNine" = 5)
			class_boons(mob/user)
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/eserthen)
					class_passives = list("AttackSpeed" = 3, "Instinct" = 2, "Flow" = 2, "To Govern Strength" = 1)
					speedadd = 1
					enduranceadd = 0.3
					offenseadd = 0.5
					defenseadd = 0.5
					strengthadd = 0.3
					forceadd = 0.3
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/aethirian)
					class_passives = list("SwordDamage" = 3, "KillerInstinct" =0.2, "MovementMastery" = 10)
					speedadd = 0.5
					offenseadd = 0.25
					defenseadd = 0.5
					strengthadd = 1
					forceadd = 1
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/agorothian/isorth)
					class_passives = list("Rage" = 2, "CallousedHands" = 0.2,  "CallousedFeet" = 0.2 ,)
					speedadd = 0.5
					enduranceadd = 1
					offenseadd = 0.3
					strengthadd = 0.5
			