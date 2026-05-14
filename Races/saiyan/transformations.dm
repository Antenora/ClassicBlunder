transformation
	saiyan
		var/tier = 0
		super_saiyan
			tier = 1
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			//Automatically unlocked at 25, intended to be unlocked around 20
			unlock_potential = 25
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "PureDamage" = 1, "PureReduction" = 1, "SaiyanPower"=1, "SaiyanPower1"=0.4)
			angerPoint = 75
			speedadd = 0.3 //these are additive. base is 1, so 0.3=1.3x
			enduranceadd = 0.3
			offenseadd = 0.3
			defenseadd = 0.3
			strengthadd = 0.3
			forceadd = 0.3

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
				if(mastery >= 50)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade2, user))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade2)
						user << "You can draw out greater power from your mastery over super Saiyan - Grade 2 unlocked!"
				if(mastery >= 75)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade3, user))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade3)
						user << "You can strain past the limits of your Super Saiyan form! Grade 3 Unlocked!"
				if(mastery >= 100)
					passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "PureDamage" = 2, "PureReduction" = 2, "SaiyanPower"=1, "SaiyanPower1"=0.5)
					if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
						if(!locate(/obj/Skills/Buffs/SpecialBuffs/SaiyanFervor, user))
							user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SaiyanFervor)
							user << "You have fully mastered Super Saiyan, rendering the Grades obsolete and unlocking a new Signature buff! (Saiyan Fervor)"
					if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
						if(!locate(/obj/Skills/Buffs/SpecialBuffs/RoyalLineage, user))
							user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/RoyalLineage)
							user << "You have fully mastered Super Saiyan, rendering the Grades obsolete and unlocking a new Signature buff! (Royal Lineage)"
					if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
						if(!locate(/obj/Skills/Buffs/SpecialBuffs/SaiyanRoar, user))
							user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SaiyanRoar)
							user << "You have fully mastered Super Saiyan, rendering the Grades obsolete and unlocking a new Signature buff! (Saiyan Roar)"
			class_boons(mob/user)
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					class_passives = list("EnergyGeneration" = 3, "Instinct" = 2, "Flow" = 2)
					speedadd = 0.45
					enduranceadd = 0.3
					offenseadd = 0.45
					defenseadd = 0.45
					strengthadd = 0.3
					forceadd = 0.3
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					class_passives = list("PureDamage" = 1.5, "Flicker" = 2, "Pursuer" = 1)
					speedadd = 0.3
					enduranceadd = 0.3
					offenseadd = 0.45
					defenseadd = 0.3
					strengthadd = 0.4
					forceadd = 0.4
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					class_passives = list("PureReduction" = 1.5, "Flow" = 2, "EnergyGeneration" = 3)
					speedadd = 0.3
					enduranceadd = 0.5
					offenseadd = 0.3
					defenseadd = 0.5
					strengthadd = 0.3
					forceadd = 0.3
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/adaptive)
					class_passives = list("PureReduction" = 1, "KiControlMastery" = 1, "Instinct" = 1, "Flow" = 1)
					speedadd = 0.4
					enduranceadd = 0.35
					offenseadd = 0.4
					defenseadd = 0.4
					strengthadd = 0.3
					forceadd = 0.3
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/dominating)
					class_passives = list("PureDamage" = 1, "Flicker" = 2, "Pursuer" = 1)
					speedadd = 0.3
					enduranceadd = 0.3
					offenseadd = 0.3
					defenseadd = 0.3
					strengthadd = 0.45
					forceadd = 0.45

			transform_animation(mob/user)
				if(first_time && mastery<25)
					DarknessFlash(user)
					sleep()
					LightningStrike2(user, Offset=4)
					user.Quake(10)
					sleep(20)
					LightningStrike2(user, Offset=4)
					user.Quake(20)
					sleep(30)
					LightningStrike2(user, Offset=4)
					user.Quake(30)
					user.Quake(50)
					spawn(1)
						LightningStrike2(user, Offset=2)
					spawn(3)
						LightningStrike2(user, Offset=2)
					spawn(5)
						LightningStrike2(user, Offset=2)
				else
					switch(mastery)
						if(50 to 99)
							user.Quake(10)

						if(25 to 49)
							sleep()
							user.Quake(10)
							user.Quake(20)

						if(0 to 24)
							sleep()
							user.Quake(10)
							sleep(20)
							user.Quake(20)
							sleep(30)
							user.Quake(30)

				animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=5)
				spawn(5)
					animate(user, color = null, time=5)
				sleep(2)

		super_saiyan_2
			tier = 2
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ2"
			form_aura_x = -32
			form_icon_2_icon = 'SS2Sparks.dmi'
			//Autounlocked at 55, intended to be unlocked around 35
			unlock_potential = 55
			autoAnger = TRUE
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2, "PureDamage" = 2, "PureReduction" = 2, "SaiyanPower2"=0.5)
			PUSpeedModifier = 1.5
			speedadd = 0.35
			enduranceadd = 0.35
			offenseadd = 0.35
			defenseadd = 0.35
			strengthadd = 0.35
			forceadd = 0.35
			mastery_boons(mob/user)
				if(user.Potential>=37&&mastery<25)
					mastery=25
				if(user.Potential>=39&&mastery<50)
					mastery=50
				if(user.Potential>=41&&mastery<75)
					mastery=75
				if(user.Potential>=43&&mastery<100)
					mastery=100
				if(mastery >= 100 && user.Class == "Justice")
					if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/adaptive)
						if(mastery >= 100)
							user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/SuperSaiyan2Enhanced)
							user << "You have pushed your Super Saiyian Two form to its absolute limits!"
			adjust_transformation_visuals(mob/user)
				if(user.Hair_Base && !form_hair_icon)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.Blend(rgb(160,130,0),ICON_ADD)
					form_hair_icon=x
				..()
				if(!form_icon_1)
					form_icon_1 = image(user.Hair_SSJ2)
					form_icon_1.blend_mode=BLEND_MULTIPLY
					form_icon_1.alpha=125
					form_icon_1.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)

			transform_animation(mob/user)
				switch(mastery)
					if(25 to 99)
						user.Quake(10)
					if(10 to 24)
						for(var/mob/Players/T in view(18,user))
							spawn()
								T.Quake(25)
					/*	for(var/turf/T in Turf_Circle(user,3))
							spawn(4)
								new/turf/Dirt1(locate(T.x,T.y,T.z))
							spawn(4)
								Destroy(T)*/
					if(0 to 9)
						for(var/mob/Players/T in view(18,user))
							spawn()
								T.Quake(50)
					/*	for(var/turf/T in Turf_Circle(user,6))
							if(prob(1))
								sleep(0.005)
							spawn(4)
								new/turf/Dirt1(locate(T.x,T.y,T.z))
							spawn(4)
								Destroy(T)*/
				animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=5)
				spawn(5)
					animate(user, color = null, time=5)
				sleep(2)

		super_saiyan_3
			tier = 3
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ2"
			form_aura_x = -32
			form_icon_2_icon = 'SS3Sparks.dmi'
			form_hair_icon = 'Hair_SSj3.dmi'
			form_icon_1_icon = 'Hair_SSj3.dmi'
			passives = list("Flicker" = 1, "Pursuer" = 1, "PureDamage" = 1, "PureReduction" = 1, "SaiyanPower3"=0.7)
			//Autounlocked at 65, intended to be unlocked at 45
			unlock_potential = 65
			speedadd = 0.5 //these are additive. base is 1, so 0.3=1.3x
			enduranceadd = 0.5
			offenseadd = 0.5
			defenseadd = 0.5
			strengthadd = 0.5
			forceadd = 0.5

			adjust_transformation_visuals(mob/user)
				..()
				form_icon_1 = image(user.Hair_SSJ3)
				form_icon_1.blend_mode=BLEND_MULTIPLY
				form_icon_1.alpha=125
				form_icon_1.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)

			transform_animation(mob/user)
				if(mastery < 50)
					user.icon_state=""
					var/image/HF=image(icon=user.race.transformations[2].form_hair, pixel_x=user.race.transformations[2].form_hair_x, pixel_y=user.race.transformations[2].form_hair_y, loc = user)
					HF.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
					HF.color=list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2)
					animate(HF, alpha=0)
					spawn()
						user.Quake(40)
					animate(HF, alpha=210, time=5)
					sleep(5)
					animate(HF, alpha=0, time=5)
					sleep(5)
					animate(HF, alpha=210, time=5)
					sleep(5)
					animate(HF, alpha=0, time=5)
					sleep(5)
					animate(HF, alpha=210, time=5)
					sleep(5)
					animate(HF, alpha=0, time=5)
					sleep(5)
					animate(HF, alpha=210, time=5)
					sleep(5)
					animate(HF, alpha=0, time=5)
					sleep(5)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					spawn()
						user.Earthquake(10,8,24,8,24,999)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					spawn()
						user.Earthquake(10,8,24,8,24,999)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					spawn()
						user.Earthquake(10,8,24,8,24,999)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					spawn()
						user.Earthquake(30,8,24,8,24,999)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					spawn()
						user.Earthquake(60,8,24,8,24,999)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					LightningStrike2(user, Offset=4)
					animate(HF, alpha=210, time=5)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					sleep(5)
					animate(HF, alpha=0, time=5)
					animate(user, color = user.MobColor, time=5)
					sleep(5)
					spawn()
						user.Earthquake(30,16,48,16,48,user.z)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					del HF
					var/ShockSize=5
					for(var/wav=5, wav>0, wav--)
						KenShockwave(user, icon='KenShockwaveGold.dmi', Size=ShockSize, Blend=2, Time=8)
						ShockSize/=2
					spawn(10)
						animate(user, color = user.MobColor, time=30)
				else
					sleep()
					user.Quake(40)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=10)
					var/ShockSize=5
					for(var/wav=5, wav>0, wav--)
						KenShockwave(user, icon='KenShockwaveGold.dmi', Size=ShockSize, Blend=2, Time=8)
						ShockSize/=2
					spawn(10)
						animate(user, color = user.MobColor, time=30)
					sleep(2)

		super_saiyan_4_daima
			tier = 4
			unlock_potential = 70 //intended to be unlocked at around 55 potential
			autoAnger = 1
			speedadd = 0.5
			enduranceadd = 0.5
			offenseadd = 0.5
			defenseadd = 0.5
			strengthadd = 0.5
			forceadd = 0.5
			var/previousTailIcon
			var/previousTailUnderlayIcon
			var/previousTailWrappedIcon
			var/tailIcon = 'saiyantail_ssj4.dmi'
			var/tailUnderlayIcon = 'saiyantail_ssj4_under.dmi'
			var/tailWrappedIcon = 'saiyantail-wrapped_ssj4.dmi'
			form_icon_1_icon = 'GokentoMaleBase_SSJ4.dmi'
			form_icon_1_layer = FLOAT_LAYER-3
			passives = list("GiantForm" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "PureDamage" = 5, "EnergyGeneration" = 5, "AllOutAttack" = 1, "SaiyanPower4"=0.5, "TrueZenkai" = 1)
			adjust_transformation_visuals(mob/user)
				if(user.Hair_Base && !form_hair_icon)
					var/icon/x=new(user.Hair_Base)
					x.Blend(rgb(150,-10,-10),ICON_ADD)
					form_hair_icon=x
				..()
			transform(mob/user)
				. = ..()
				previousTailIcon = user.TailIcon
				previousTailUnderlayIcon = user.TailIconUnderlay
				previousTailWrappedIcon = user.TailIconWrapped
				user.TailIcon = tailIcon
				user.TailIconUnderlay = tailUnderlayIcon
				user.TailIconWrapped = tailWrappedIcon
				user.Tail(1)

			revert(mob/user)
				. = ..()
				if(!is_active || !user.CanRevert()) return
				user.TailIcon = previousTailIcon
				user.TailIconUnderlay = previousTailUnderlayIcon
				user.TailIconWrapped = previousTailWrappedIcon
				previousTailIcon = null
				previousTailUnderlayIcon = null
				previousTailWrappedIcon = null
				user.Tail(1)

			transform_animation(mob/user)
				if(first_time)
					user.CutsceneMode() // store the pre-form appearance and then the post-form appearance before calling the animation. also remove the hair set on overlay afterwards since it's not supposed to be an overlay
					var/appearance1 = user.appearance
					user.overlays += form_icon_1
					user.overlays += form_icon_2
					user.overlays += form_glow
					user.overlays += form_aura
					user.underlays += form_aura_underlay
					user.overlays += form_hair
					var/appearance2 = user.appearance
					user.HellSSJ4Animation1(appearance1, appearance2, user)
					user.overlays -= form_hair
		//Golden Oozaru is intended to be unlocked about 10 potential before SSj4!
		super_saiyan_4
			tier = 4
			//Autounlocked at 90, intended to be unlocked at around 70 potential
			unlock_potential = 90
			autoAnger = 1
			speedadd = 3
			enduranceadd = 3
			offenseadd = 3
			defenseadd = 3
			strengthadd = 3
			forceadd = 3
			revertToTrans = 0
			var/previousTailIcon
			var/previousTailUnderlayIcon
			var/previousTailWrappedIcon
			var/tailIcon = 'saiyantail_ssj4.dmi'
			var/tailUnderlayIcon = 'saiyantail_ssj4_under.dmi'
			var/tailWrappedIcon = 'saiyantail-wrapped_ssj4.dmi'
			form_icon_1_icon = 'GokentoMaleBase_SSJ4.dmi'
			form_icon_1_layer = FLOAT_LAYER-3
			passives = list("DisableGodKi" = 1,"GiantForm" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 3, "PureReduction" = 5, "LifeGeneration" = 5, "Unstoppable" = 1, "AllOutAttack" = 1, "Reversal" = 0.3)
			adjust_transformation_visuals(mob/user)
				if(user.Hair_Base && !form_hair_icon)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon=x
				..()

			mastery_boons(mob/user)
				passives = list("GiantForm" = 1, "Juggernaut" = 1+(mastery/25), "BuffMastery" = 5 + (mastery/10), "SweepingStrike" = 1, "Brutalize" = 3,\
				"Meaty Paws" = 2 + (mastery/50), "KiControlMastery" = 3 + (mastery/50), "PureReduction" = 5 + (mastery/10),\
				"LifeGeneration" = 1 + round(mastery/50,1), "Unstoppable" = 1, "AllOutAttack" = 1, "Reversal" = 0.1 + (mastery/200),\
				"Flow" = 4, "Instinct" = 4, "Transformation Power" = clamp(user.AscensionsAcquired * 3, 1, 20), "Deicide" = 10,\
				"Flicker" = 5, "Pursuer" = 5, "PureDamage"= 4 + (mastery/10),"SSJ4" = 1,"EndlessNine"=0.25, "SaiyanPower"=1, "SaiyanPower4"=2.5)
				autoAnger = 1
				angerPoint = 99 // funny fix for golden ooz stopping endless anger

			transform(mob/user)
				. = ..()
				previousTailIcon = user.TailIcon
				previousTailUnderlayIcon = user.TailIconUnderlay
				previousTailWrappedIcon = user.TailIconWrapped
				user.TailIcon = tailIcon
				user.TailIconUnderlay = tailUnderlayIcon
				user.TailIconWrapped = tailWrappedIcon
				user.Tail(1)

			revert(mob/user)
				. = ..()
				if(!is_active || !user.CanRevert()) return
				user.transActive = 0
				user.TailIcon = previousTailIcon
				user.TailIconUnderlay = previousTailUnderlayIcon
				user.TailIconWrapped = previousTailWrappedIcon
				previousTailIcon = null
				previousTailUnderlayIcon = null
				previousTailWrappedIcon = null
				user.Tail(1)

			transform_animation(mob/user)
				/*if(first_time) // store the pre-form appearance and then the post-form appearance before calling the animation. also remove the hair set on overlay afterwards since it's not supposed to be an overlay
					var/appearance1 = user.appearance
					world << "app1 is [appearance1]"
					user.overlays += form_icon_1
					user.overlays += form_icon_2
					user.overlays += form_glow
					user.overlays += form_aura
					user.underlays += form_aura_underlay
					world << "[form_hair_icon]"
					user.overlays += form_hair
					world << "[user.Hair]"
					var/appearance2 = user.appearance
					world << "app2 is [appearance2]"
					user.HellSSJ4Animation1(appearance1, appearance2)
					user.overlays -= form_hair*/
				user.Quake(40)
				user.Frozen=1
				KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=10)
				for(var/turf/t in Turf_Circle(user, 18))
					if(prob(50))
						spawn(rand(2,6))
							var/icon/i = icon('RisingRocks.dmi')
							t.overlays+=i
							spawn(rand(20, 60))
								t.overlays-=i
				spawn(10)
					KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=10)
				user.Frozen=0
				animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=20)
				sleep(20)

				var/ShockSize = 5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveGold.dmi', Size=ShockSize, Blend=2, Time=10)
					ShockSize/=2
				spawn(10)
					animate(user, color = user.MobColor, time=20)
		super_full_power_saiyan_4_limit_breaker
			tier = 5
			//Intended to be unlocked at around 80 potential, autounlocked at 100
			//Probably the in game reason for people going beyond 100 potential. Rolls eyes in seiyn
			unlock_potential = 100
			autoAnger = 1
			speedadd = 0.25
			enduranceadd = 0.25
			offenseadd = 0.25
			defenseadd = 0.25
			strengthadd = 0.25
			forceadd = 0.25
			var/previousTailIcon
			var/previousTailUnderlayIcon
			var/previousTailWrappedIcon
			var/tailIcon = 'saiyantail_ssj4.dmi'
			var/tailUnderlayIcon = 'saiyantail_ssj4_under.dmi'
			var/tailWrappedIcon = 'saiyantail-wrapped_ssj4.dmi'
			form_icon_1_icon = 'GokentoMaleBase_SSJ4.dmi'
			form_icon_1_layer = FLOAT_LAYER-3
			passives = list("DisableGodKi" = 1,"GiantForm" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 3, "PureReduction" = 5, "LifeGeneration" = 5, "Unstoppable" = 1, "AllOutAttack" = 1, "Reversal" = 0.3)
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.Blend(rgb(150,-10,-10),ICON_ADD)
				..()

			mastery_boons(mob/user)
				passives = list("BuffMastery" = 2, "SweepingStrike" = 1, "Brutalize" = 3,\
				"KiControlMastery" = 4, "PureReduction" = 3, "EnergyGeneration" = 5, \
				"Flow" = 4, "Instinct" = 4, "Deicide" = 10,\
				"Flicker" = 5, "Pursuer" = 5, "PureDamage"= 3,"EndlessNine"=0.25,"SSJ4LimitBreaker"=1, "SaiyanPower4"=0.5)

			transform(mob/user)
				. = ..()
				previousTailIcon = user.TailIcon
				previousTailUnderlayIcon = user.TailIconUnderlay
				previousTailWrappedIcon = user.TailIconWrapped
				user.TailIcon = tailIcon
				user.TailIconUnderlay = tailUnderlayIcon
				user.TailIconWrapped = tailWrappedIcon
				user.Tail(1)

			revert(mob/user)
				. = ..()
				if(!is_active || !user.CanRevert()) return
				user.TailIcon = previousTailIcon
				user.TailIconUnderlay = previousTailUnderlayIcon
				user.TailIconWrapped = previousTailWrappedIcon
				previousTailIcon = null
				previousTailUnderlayIcon = null
				previousTailWrappedIcon = null
				user.Tail(1)

			transform_animation(mob/user)
				user.Quake(40)
				user.Frozen=1
				KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=10)
				for(var/turf/t in Turf_Circle(user, 18))
					if(prob(50))
						spawn(rand(2,6))
							var/icon/i = icon('RisingRocks.dmi')
							t.overlays+=i
							spawn(rand(20, 60))
								t.overlays-=i
				spawn(10)
					KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=10)
				user.Frozen=0
				animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=20)
				sleep(20)

				var/ShockSize = 5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveGold.dmi', Size=ShockSize, Blend=2, Time=10)
					ShockSize/=2
				spawn(10)
					animate(user, color = user.MobColor, time=20)
		super_saiyan_god
			tier = 4
			passives = list("GodKi" = 0.5, "EnergyGeneration" = 1, "Godspeed" = 4, "Flow" = 4, "BackTrack" = 2, "StunningStrike" = 1, "Sunyata" = 1 )
			//Meant to be unlocked around the same time as Golden Oozaru
			//Which is to say, intended at 60 potential, but autogranted at 80.
			unlock_potential = 80
			form_aura_icon = 'SSBGlow.dmi'
			form_aura_x = -32
			form_aura_y = -32
			speedadd = 1.25
			enduranceadd = 1.25
			offenseadd = 1.25
			defenseadd = 1.25
			strengthadd = 1.25
			forceadd = 1.25
			// at full mastery, give the saiyan beyond god buff, then remove ssjgod, and replace it with ssjgb
			mastery_boons(mob/user)
				autoAnger = TRUE
				passives = list("GodKi" = 0.5, "EnergyGeneration" = 3 + round(mastery/10, 1), "Godspeed" = 4, "Flow" = 4 + round(mastery/25, 1),"TechniqueMastery" = 3 + round(mastery/15, 1), \
								"Instinct" = 4,"Pursuer"= 4 , "BackTrack" = 2 + round(mastery/50, 1), \
								"MovementMastery" = 4+round(mastery/25, 1), "StunningStrike" = 1 + round(mastery/50, 0.1), "Sunyata" = 1 + round(mastery/20 ,1),"GodlyCalm"=1,\
								"Flicker" = 4, "PureDamage"=2, "BuffMastery" = 1 + (mastery/25), "SaiyanPower" = 1, "SaiyanPower1"=1)
			adjust_transformation_visuals(mob/user)
				if(user.Hair_Base && !form_hair_icon)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.Blend(rgb(159, 27, 51),ICON_ADD)
					form_hair_icon=x
				..()
			transform_animation(mob/user)
				if(mastery < 20)
					mastery=20
					sleep(10)
				//src.Transforming=1
					user.Frozen=2

					user.OMessage(15,"[user] is fully revitalized, as their entire body is surrounded by a gentle aura.","<font color=red>[user]([user.key]) unlocked Super Saiyan Divinity.")
					var/image/GG=image('GodGlow.dmi',pixel_x=-32,pixel_y=-32, loc = user, layer=MOB_LAYER-0.5)
					GG.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
					GG.color=list(1,0,0, 0,1,0, 0,0,1, 0.2,0.2,0.4)
					GG.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(190, 34, 55, 37), size = 5)
					animate(GG, alpha=0, transform=matrix()*0.7)
					world << GG
					animate(GG, alpha=255, time=30, transform=matrix()*1)
					animate(user, color = list(0.45,0.6,0.75, 0.64,0.88,1, 0.16,0.21,0.27, 0,0,0), pixel_y=32, time=30)
					sleep(40)

					var/image/GO=image('GodOrb.dmi',pixel_x=-16,pixel_y=-16, loc = user, layer=EFFECTS_LAYER+0.5)
					GO.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
					GO.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(190, 34, 55, 156), size = 3)
					animate(GO, alpha=0)
					world << GO
					animate(GO, alpha=255, time=40)
					for(var/mob/Players/T in view(31, user))
						animate(T.client, color=list(0.5,0,0, 0,0.5,0, 0,0,0.5, 0,0,0.1), time = 40)
						spawn(40)
							animate(T.client, color=null, time = 40)
					spawn(10)
						KenShockwave(user, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
						animate(GO, color=list(1,0,0, 0,1,0, 0,0,1, 0.8,0.8,0.8), time=30)
					spawn(20)
						KenShockwave(user, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
					spawn(30)
						KenShockwave(user, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
					spawn(40)
						KenShockwave(user, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
					spawn(50)
						KenShockwave(user, icon='KenShockwaveDivine.dmi', PixelY=24, Size=5, Blend=2)
					sleep(50)
					animate(user, color = null)
					sleep(30)
					user.Hairz("Add")
					GG.filters-=filter(type = "drop_shadow", x=0, y=0, color=rgb(190, 34, 55, 37), size = 5)
					GG.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(51, 220, 243), size = 1)

					animate(GO, alpha=0, time=10)
					sleep(10)
					animate(user, pixel_y=0, time=30)
					animate(GG, alpha=0, time=50)
					spawn(50)
						GO.filters=null
						del GO
						GG.filters=null
						del GG

					user.Frozen=0
				//user.Transforming=0
				else
					KenShockwave(user, icon='SparkleOrange.dmi', Size=3, PixelX=105, PixelY=100, Blend=2)
					animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1.5,0.9,0.1), time=5)
					spawn(5)
						spawn(50)
							if(!user.HasKiControl()&&!user.PoweringUp)
								user.Auraz("Remove")
						animate(user, color = null, time=5)

			transform(mob/user)
				if(user.CheckSlotless("Beyond God"))
					return
				if(mastery>=100)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/SaiyanBeyondGod, user))
						user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/SaiyanBeyondGod)
						user << "You are able to use your god boons in base form (Beyond God Buff)"
						return
					else
						..()
				//	user.race.transformations-=src
				//	del src
				else
					..()


		super_saiyan_blue
			passives = list("GodKi" = 1, "Instinct" = 4, "Brutalize" = 1)
			//Parity with SSj4
			//Intended for 70 potential, autounlocked at 90.
			unlock_potential = 90
			tier = 5
			autoAnger = 1
			form_aura_icon = 'SSBGlow.dmi'
			form_aura_x = -32
			form_aura_y = -32
			speedadd = 1.75
			enduranceadd = 1.75
			offenseadd = 1.75
			defenseadd = 1.75
			strengthadd = 1.75
			forceadd = 1.75
			revertToTrans = 0

			mastery_boons(mob/user)
				passives = list("GodKi" = 0.75, "Instinct" = 4, "Brutalize" = 3, "Steady" = 5,  "BuffMastery" = 8, "MovementMastery" = 8, \
								"PureDamage" = 5, "PureReduction" = 4, "InBlue" = 1, "Godspeed" = 4, "Pursuer" = 4, "LikeWater"=6,"Flicker"=4, "SaiyanPower" = 1, "SaiyanPower1"=1)
				speedadd = 1.75
				enduranceadd = 1.75
				offenseadd = 1.75
				defenseadd = 1.75
				strengthadd = 1.75
				forceadd = 1.75
				if(mastery >= 100)
					passives = list("GodKi" = 1, "Instinct" = 4, "Brutalize" = 3, "Steady" = 5,  "BuffMastery" = 8, "MovementMastery" = 10, \
									"PureDamage" = 5, "PureReduction" = 4, "InBlue" = 1, "Godspeed" = 4, "Pursuer" = 4, "LikeWater"=6,"Flicker"=4, "SaiyanPower" = 1, "SaiyanPower1"=1)

			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.MapColors(0.2,0.2,0.2, 0.4,0.4,0.4, 0.07,0.07,0.07, 0.25,0.64,0.89)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
				if(mastery >= 100)
					form_aura_icon = null



			transform(mob/user)
				if(user.transActive==1&&user.transUnlocked>=5)
					user.Revert()
					user.transActive = 1
					..()
				else return 0

			transform_animation(mob/user)
				if(user.CheckSlotless("Beyond God"))
					user.SlotlessBuffs["Beyond God"].Trigger(user, TRUE)
				// disable
				if(!user.passive_handler.Get("GodlyCalm"))
					if(mastery<25)
						user.appearance_flags+=16
						animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 0.9,1,1), time=5)
						user.icon_state=""
						var/image/GG=image('SSBGlow.dmi',pixel_x=-32, pixel_y=-32)
						GG.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
						GG.blend_mode=BLEND_ADD
						GG.color=list(1,0,0, 0,1,0, 0,0,1, 0,0,0)
						GG.alpha=110
						sleep(5)
						user.filters+=filter(type = "blur", size = 0)
						animate(user, color=list(-1.2,-1.2,-1, 1,1,1, -1.4,-1.4,-1.2,  1,1,1), time=3, flags=ANIMATION_END_NOW)
						animate(user.filters[user.filters.len], size = 0.35, time = 3)
						user.overlays+=GG
						spawn()DarknessFlash(user, SetTime=60)
						sleep()
						var/image/GO=image('GodOrb.dmi',pixel_x=-16,pixel_y=-16, loc = user, layer=MOB_LAYER+0.5)
						GO.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
						GO.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(0, 255, 0, 44), size = 3)
						animate(GO, alpha=0, transform=matrix(), color=rgb(0, 255, 0, 134))
						world << GO
						animate(GO, alpha=210, time=1)
						sleep(1)
						animate(GO, transform=matrix()*3, time=60, easing=BOUNCE_EASING | EASE_IN | EASE_OUT, flags=ANIMATION_END_NOW)
						user.Quake(20)
						sleep(20)
						user.Quake(40)
						sleep(20)
						user.Quake(60)
						sleep(20)

						sleep(10)
						user.filters-=filter(type = "blur", ,size = 0.35)
						animate(user, color=list(0,0,0, 0,0,0, 0,0,0, 0.5,0.95,1), time=5, easing=QUAD_EASING)
						sleep(5)
						animate(user, color=null, time=20, easing=CUBIC_EASING)
						sleep(20)
						animate(GO, alpha=0, time=5)
						spawn(5)
							user.overlays-=GG
							GO.filters=null
							del GO
							user.appearance_flags-=16

			revert(mob/user)
		//		user.transActive = 1
				..()
				user.transActive = 0
			//UBuffNeeded
		super_saiyan_blue_evolved
			passives = list("GodKi" = 1, "Instinct" = 4, "Brutalize" = 1)
			//Parity with SSj4 Limit Breaker
			//Intended to be unlocked around 80
			//Autounlocks at 100 potential
			unlock_potential = 100
			tier = 6
			autoAnger = 1
			form_aura_icon = 'SSBGlow.dmi'
			form_aura_x = -32
			form_aura_y = -32
			mastery_boons(mob/user)
				mastery = 100 //true end stage for saiyans, mastery would be superfluous
				// perfected: sustainable version of the form, strict upgrade over blue
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					passives = list("GodKi" = 0.25, "Instinct" = 4, "Brutalize" = 3, "Steady" = 1, "MovementMastery" = 2, \
									"EnergyGeneration" = 3,  "PureDamage" = 3, "PureReduction" = 2, "LikeWater" = 2, \
									"BackTrack" = 1 , "StunningStrike" = 2, "Sunyata" = 3, "InBlueEvolved" = 1,"Flow"=4)
					speedadd = 0.35
					enduranceadd = 0.35
					offenseadd = 0.35
					defenseadd = 0.35
					strengthadd = 0.35
					forceadd = 0.35
				//evolved: high risk high reward. glass cannon stage that drains heavily
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					passives = list("GodKi" = 0.5, "Brutalize" = 2, "MovementMastery" = 7, "EnergyLeak" = 3, "FatigueLeak"=1,\
							 	"PureDamage" = 9, "PureReduction" = -2,"LikeWater" = 4, \
								"Sunyata" = 6, "InBlueEvolved" = 1, "Pursuer" = 2)
					speedadd = 0.5
					offenseadd = 0.25
					strengthadd = 0.65
					forceadd = 0.65
				//enraged: draw out fights, anger makes user stronger but wounds put a limit on it
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					passives = list("GodKi" = 0.25, "Brutalize" = 2, "MovementMastery" = 5, \
							 	"PureDamage" = 2,"PureReduction" = 5, "LikeWater" = 4, "BleedHit"=0.25, \
								"Persistence" = 3, "InBlueEvolved" = 1, "UnderDog" = 5, "Flicker" = 3)
					speedadd = 0.25
					enduranceadd = 0.75
					defenseadd = 0.75
					strengthadd = 0.15
					forceadd = 0.15

			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.MapColors(0.2,0.2,0.2, 0.4,0.4,0.4, 0.07,0.07,0.07, 0.25,0.64,0.89)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
				if(mastery >= 100)
					form_aura_icon = null



			transform(mob/user)
				if(user.transUnlocked>=6)
					..()
				else return 0

			transform_animation(mob/user)
				user.appearance_flags+=16
				animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 0.9,1,1), time=5)
				user.icon_state=""
				var/image/GG=image('SSBGlow.dmi',pixel_x=-32, pixel_y=-32)
				GG.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
				GG.blend_mode=BLEND_ADD
				GG.color=list(1,0,0, 0,1,0, 0,0,1, 0,0,0)
				GG.alpha=110
				sleep(5)
				user.filters+=filter(type = "blur", size = 0)
				animate(user, color=list(-1.2,-1.2,-1, 1,1,1, -1.4,-1.4,-1.2,  1,1,1), time=3, flags=ANIMATION_END_NOW)
				animate(user.filters[user.filters.len], size = 0.35, time = 3)
				user.overlays+=GG
				spawn()DarknessFlash(user, SetTime=60)
				sleep()
				var/image/GO=image('GodOrb.dmi',pixel_x=-16,pixel_y=-16, loc = user, layer=MOB_LAYER+0.5)
				GO.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
				GO.filters+=filter(type = "drop_shadow", x=0, y=0, color=rgb(0, 255, 0, 44), size = 3)
				animate(GO, alpha=0, transform=matrix(), color=rgb(0, 255, 0, 134))
				world << GO
				animate(GO, alpha=210, time=1)
				sleep(1)
				animate(GO, transform=matrix()*3, time=60, easing=BOUNCE_EASING | EASE_IN | EASE_OUT, flags=ANIMATION_END_NOW)
				user.Quake(20)
				sleep(20)
				user.Quake(40)
				sleep(20)
				user.Quake(60)
				sleep(20)

				sleep(10)
				user.filters-=filter(type = "blur", ,size = 0.35)
				animate(user, color=list(0,0,0, 0,0,0, 0,0,0, 0.5,0.95,1), time=5, easing=QUAD_EASING)
				sleep(5)
				animate(user, color=null, time=20, easing=CUBIC_EASING)
				sleep(20)
				animate(GO, alpha=0, time=5)
				spawn(5)
					user.overlays-=GG
					GO.filters=null
					del GO
					user.appearance_flags-=16

			revert(mob/user)
				..()
			//UBuffNeeded
		super_saiyan_5
			unlock_potential = 150
			autoAnger = 1
			form_hair_icon = 'Hair_SSJ5.dmi'
			form_icon_1_icon = 'Hair_SSJ5.dmi'
			passives = list("The Unstoppable Force" = 1, "The Immovable Object" = 1, "To Govern Strength" = 1)
			speed = 4
			endurance = 4
			offense = 4
			defense = 4
			strength = 4
			force = 4
			mastery_boons(mob/user)
				mastery=100
			transform_animation(mob/user)
				user.BeastAnimation()
