transformation
	saiyan
		hellspawn_super_saiyan
			tier = 6//full transparency this does functionally nothing for hellspawns, but it's a bandaid for our special regular saiyans hahaha
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "Kaioken"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			unlock_potential = 45
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "PureDamage" = 1, "PureReduction" = -4, "SaiyanPower"=1, "SaiyanPower1"=0.5)
			speedadd = 0.3 //these are additive. base is 1, so 0.3=1.3x
			enduranceadd = 0.3
			offenseadd = 0.3
			defenseadd = 0.3
			strengthadd = 0.3
			forceadd = 0.3
			mastery_boons(mob/user)
				var/MasteryBoost=round(mastery/4, 25)
				passives = list("Instinct" = 1+(MasteryBoost/4), "Flow" = 1+(MasteryBoost/4), "Flicker" = 1+(MasteryBoost/4), "Pursuer" = 2,  "PureDamage" = 3+(MasteryBoost/2), "PureReduction" = -4+MasteryBoost, "SaiyanPower"=1, "SaiyanPower1"=0.5)
				if(mastery >= 50)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade2, user)&&user.isRace(SAIYAN))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade2)
						user << "You can draw out greater power from your mastery over super Saiyan - Grade 2 unlocked!"
				if(mastery >= 75)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade3, user)&&user.isRace(SAIYAN))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade3)
						user << "You can strain past the limits of your Super Saiyan form! Grade 3 Unlocked!"
			if(mastery >= 100)
				passives = list("Instinct" = 1+(MasteryBoost/2), "Flow" = 1+(MasteryBoost/2), "Flicker" = 1+(MasteryBoost/2), "Pursuer" = 2,  "PureDamage" = 3+(MasteryBoost/2), "PureReduction" = -4+MasteryBoost, "SaiyanPower"=1, "SaiyanPower1"=0.5)
				
			class_boons(mob/user) //pride stats as a baseline no matter what
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					class_passives = list("EnergyGeneration" = 3, "Instinct" = 2, "Flow" = 2)
					speedadd = 0.3
					enduranceadd = 0.1
					offenseadd = 0.45
					defenseadd = 0.15
					strengthadd = 0.4
					forceadd = 0.4
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					class_passives = list("PureDamage" = 1.5, "Flicker" = 2, "Pursuer" = 1)
					speedadd = 0.3
					enduranceadd = 0.1
					offenseadd = 0.45
					defenseadd = 0.15
					strengthadd = 0.4
					forceadd = 0.4
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					class_passives = list("PureReduction" = 1.5, "Flow" = 2, "EnergyGeneration" = 3)
					speedadd = 0.3
					enduranceadd = 0.1
					offenseadd = 0.45
					defenseadd = 0.15
					strengthadd = 0.4
					forceadd = 0.4
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

			transform_animation(mob/user)
				if(first_time)
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
			//	if(user.TotalInjury<50)
			//		user.TotalInjury=50
				sleep(2)

			transform(mob/user)
				if(user.CheckSlotless("Beyond God")||user.passive_handler.Get("InBlue"))
					return
				else
					..()
		hellspawn_super_saiyan_2 //now based on daima
			unlock_potential = 70 //intended to be unlocked at around 55 potential
			autoAnger = 1
			speedadd = 1.5
			enduranceadd = 0.5
			offenseadd = 1.5
			defenseadd = 0.5
			strengthadd = 1.5
			forceadd = 1.5
			var/previousTailIcon
			var/previousTailUnderlayIcon
			var/previousTailWrappedIcon
			var/tailIcon = 'saiyantail_ssj4.dmi'
			var/tailUnderlayIcon = 'saiyantail_ssj4_under.dmi'
			var/tailWrappedIcon = 'saiyantail-wrapped_ssj4.dmi'
			form_icon_1_icon = 'GokentoMaleBase_SSJ4.dmi'
			form_icon_1_layer = FLOAT_LAYER-3
			passives = list("GiantForm" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "PureDamage" = 9, "EnergyGeneration" = 5, "AllOutAttack" = 1, "SaiyanPower4"=1.5, "TrueZenkai" = 1)
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
				if(first_time) // store the pre-form appearance and then the post-form appearance before calling the animation. also remove the hair set on overlay afterwards since it's not supposed to be an overlay
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
					user.overlays -= form_hair
		hellspawn_super_full_power_saiyan_2_limit_breaker //it's super saiyan 5
			tier = 8
			unlock_potential = 90
			autoAnger = 1
			speed = 1.5
			endurance = 1.5
			offense = 1.5
			defense = 1.5
			strength = 1.3
			force = 1.3
			revertToTrans = 0
			var/previousTailIcon
			var/previousTailUnderlayIcon
			var/previousTailWrappedIcon
			var/tailIcon = 'saiyantail_ssj4.dmi'
			var/tailUnderlayIcon = 'saiyantail_ssj4_under.dmi'
			var/tailWrappedIcon = 'saiyantail-wrapped_ssj4.dmi'
			passives = list("GiantForm" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 3, "PureReduction" = 5, "LifeGeneration" = 5, "Unstoppable" = 1, "AllOutAttack" = 1, "Reversal" = 0.3)
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.Blend(rgb(150,-10,-10),ICON_ADD)
				..()

			mastery_boons(mob/user)
				passives = list("Juggernaut" = 1+(mastery/25), "BuffMastery" = 2, "SweepingStrike" = 1, "Brutalize" = 3,\
				"KiControlMastery" = 4, "PureReduction" = 3, "Reversal" = 0.1 + (mastery/200),\
				"Flow" = 4, "Instinct" = 4, "Deicide" = 10,\
				"Flicker" = 5, "Pursuer" = 5, "PureDamage"= 3,"EndlessNine"=0.25,"SSJ4LimitBreaker"=1)
				speed = 1.25 + (mastery/400)
				endurance = 1.25 + (mastery/400)
				offense = 1.25 + (mastery/400)
				defense = 1.25 + (mastery/400)
				strength = 1.25 + (mastery/400)
				force = 1.25 + (mastery/400)

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
			transform(mob/user)
				if(user.CheckSlotless("Beyond God")||user.passive_handler.Get("InBlue"))
					return
				else
					..()
