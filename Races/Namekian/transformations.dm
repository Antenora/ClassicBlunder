transformation
	namekian
		Potential_Unleashed
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "Heran"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			passives = list("Instinct" = 2, "Flow" = 2, "Flicker" = 2, "Pursuer" = 3,  "PureDamage" = 2, "PureReduction" = 2)
			speedadd = 0.25
			enduranceadd = 0.25
			offenseadd = 0.25
			defenseadd = 0.25
			strengthadd = 0.25
			forceadd = 0.25
			mastery_boons(mob/user)
				user.transUnlocked=2
				if(user.Potential>=20)
					if(!locate(/obj/Skills/Buffs/SpecialBuffs/SuperNamekian, user))
						user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/SuperNamekian)
						user << "You have ascended past the limits of a normal Namekian, unlocking Super Namekian!"
		Orange_Namekian//you can thank piccolo for this one, I'm very sorry. LMFAO.
			transform(mob/user, forceTrans)
				if(is_active) return
				if(!user) return
				if(user.Potential<45)
					if(user.Health>=(20+user.Potential/4)) return
				if(user.Class=="Demon") return
				passives = list("Instinct" = round(max(user.AscensionsAcquired/3, 1)), "Flow" = round(max(user.AscensionsAcquired/3, 1)), "Flicker" = round(max(user.AscensionsAcquired, 2)), "Pursuer" = round(max(user.AscensionsAcquired/3, 1)),  "BuffMastery" = round(max(user.AscensionsAcquired*1.25, 1)), "PureDamage" = round(max(user.AscensionsAcquired/2, 1)), "PureReduction" = round(max(user.AscensionsAcquired/2, 1)))
				..()
			mastery_boons(mob/user)
				switch(user.Potential)
					if(0 to 30)
						passives = list("Instinct" = round(max(user.AscensionsAcquired/3, 1)), "Flow" = round(max(user.AscensionsAcquired/3, 1)), "Flicker" = round(max(user.AscensionsAcquired, 2)), \
						"Pursuer" = round(max(user.AscensionsAcquired/3, 1)),  "BuffMastery" = round(max(user.AscensionsAcquired*1.25, 1)),\
						"PureDamage" = round(max(user.AscensionsAcquired/2, 1)), "PureReduction" = round(max(user.AscensionsAcquired/2, 1)))
						speedadd = 0.6
						offenseadd = 0.5
						defenseadd = 0.5
						strengthadd = 0.5
						forceadd = 0.5
						enduranceadd = 0.5
					if(31 to 60)
						passives = list("Instinct" = round(max(user.AscensionsAcquired, 1)), "Flow" = round(max(user.AscensionsAcquired, 1)), "Flicker" = round(max(user.AscensionsAcquired*1.5, 2)), \
							"Pursuer" = round(max(user.AscensionsAcquired, 1)),  "BuffMastery" = round(max(user.AscensionsAcquired*1.25, 1)),\
							"PureDamage" = round(max(user.AscensionsAcquired, 1)), "PureReduction" = round(max(user.AscensionsAcquired, 1)),  "MovementMastery" = round(max(user.AscensionsAcquired*1.5, 1)), "Orange Namekian"=1)
						speedadd = 0.75
						offenseadd = 0.75
						defenseadd = 0.75
						strengthadd = 0.75
						forceadd = 0.75
						enduranceadd = 0.75

					if(61 to 100)
						passives = list("Instinct" = round(max(user.AscensionsAcquired*1.5, 1)), "Flow" = round(max(user.AscensionsAcquired*1.5, 1)), "Flicker" = round(max(user.AscensionsAcquired*1.5, 2)), \
							"Pursuer" = round(max(user.AscensionsAcquired, 1)),  "BuffMastery" = round(max(user.AscensionsAcquired*1.5, 1)),\
							"PureDamage" = round(max(user.AscensionsAcquired*1.5, 1)), "PureReduction" = round(max(user.AscensionsAcquired, 1)),  "MovementMastery" = round(max(user.AscensionsAcquired*1.5, 1)), "Orange Namekian"=1)
						speedadd = 1.5
						offenseadd = 1.5
						defenseadd = 1.5
						strengthadd = 1.5
						forceadd = 1.5
						enduranceadd = 1.5
		//	autoAnger = 1
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "Heran"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			unlock_potential = ASCENSION_FIVE_POTENTIAL

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
				sleep(2)
