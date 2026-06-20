transformation
	saiyan
		heavenborn_super_saiyan
			tier = 6
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "Demi"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			unlock_potential = 45
			passives = list("CalmAnger"=1, "Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "PureDamage" = 1, "PureReduction" = -4,  "HolyMod" = 1, "SaiyanPower"=1, "SaiyanPower1"=0.5)
			speedadd = 0.6
			enduranceadd = 0.6
			offenseadd = 0.6
			defenseadd = 0.6
			strengthadd = 0.6
			forceadd = 0.6
			mastery_boons(mob/user)
				if(user.Potential>=37&&mastery<25)
					mastery=25
				if(user.Potential>=39&&mastery<50)
					mastery=50
				if(user.Potential>=41&&mastery<75)
					mastery=75
				if(user.Potential>=43&&mastery<100)
					mastery=100
				var/MasteryBoost=round(mastery/25, 1)
				passives = list("CalmAnger"=1, "Instinct" = 1+(MasteryBoost/4), "Flow" = 1+(MasteryBoost/4), "Flicker" = 1+(MasteryBoost/4), "Pursuer" = 2,  "PureDamage" = 3+(MasteryBoost/2), "PureReduction" = -2+MasteryBoost,  "HolyMod" = 1+MasteryBoost, "SaiyanPower"=1, "SaiyanPower1"=0.8)
				if(user.Potential>=27)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade2, user)&&user.isRace(SAIYAN))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade2)
						user << "You can draw out greater power from your mastery over super Saiyan - Grade 2 unlocked!"
				if(user.Potential>=30)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade3, user)&&user.isRace(SAIYAN))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SuperSaiyanGrade3)
						user << "You can strain past the limits of your Super Saiyan form! Grade 3 Unlocked!"
				if(mastery >= 100)
					passives = list("CalmAnger"=1, "Instinct" = 1+(MasteryBoost/2), "Flow" = 1+(MasteryBoost/2), "Flicker" = 1+(MasteryBoost/2), "Pursuer" = 2,  "PureDamage" = 3+(MasteryBoost/2), "PureReduction" = -2+MasteryBoost, "HolyMod" = 1+MasteryBoost, "SaiyanPower"=1, "SaiyanPower1"=1.75)
				if(user.Potential>=35)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SaiyanPurity, user))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SaiyanPurity)
						user << "You have unlocked a new Signature buff! (Saiyan Purity)"
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/Sickle_of_Sorrow, user))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Sickle_of_Sorrow)
						user << "You can manifest your rage and sorrow into a powerful weapon! (Sickle of Sorrow)"
				speedadd = 0.6+(mastery/100)
				enduranceadd = 0.6+(mastery/100)
				offenseadd = 0.6+(mastery/100)
				defenseadd = 0.6+(mastery/100)
				strengthadd = 0.6+(mastery/100)
				forceadd = 0.6+(mastery/100)
			class_boons(mob/user) //pride stats as a baseline no matter what
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					class_passives = list("EnergyGeneration" = 3, "Instinct" = 2, "Flow" = 2)
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					class_passives = list("PureDamage" = 1.5, "Flicker" = 2, "Pursuer" = 1)
				if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					class_passives = list("PureReduction" = 1.5, "Flow" = 2, "EnergyGeneration" = 3)
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
		super_saiyan_rose // MORTAAAAAAAAAAAAAAAAAAAALS
			unlock_potential = 70 //based on hellspawn ssj2 too
			form_aura_icon = 'AurasBig.dmi'
			form_aura_x = -32
			form_aura_icon_state = "Toji"
			autoAnger = 1
			speedadd = 3.5
			enduranceadd = 4.5
			offenseadd = 3.5
			defenseadd = 3.5
			strengthadd = 4.5
			forceadd = 3.5
			passives = list("Purity" = 1, "BeyondPurity" = 1, "GodKi" = 0.5, "SweepingStrike" = 1, "Brutalize" = 3, "PureDamage" = 9, "EnergyGeneration" = 5, "AllOutAttack" = 1, "SaiyanPower4"=1.5, "TrueZenkai" = 1, "HolyMod" = 5)
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.MapColors(1.75, 0, 0, 0, 0, 1.08, 0, 0, 0, 0, 1.60, 0, 0, 0, 0, 1, 0.28, 0.12, 0.24, 0)
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
				user.Quake(30)

				animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1,0.9,0.2), time=5)
				spawn(5)
					animate(user, color = null, time=5)
			//	if(user.TotalInjury<50)
			//		user.TotalInjury=50
				sleep(2)