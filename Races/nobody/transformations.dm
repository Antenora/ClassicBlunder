transformation
	nobody
		var/tier = 0
		void_super_saiyan //temp
			tier = 1
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "Demi"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			unlock_potential = 30
			speedadd = 0.25
			enduranceadd = 0.25
			offenseadd = 0.25
			defenseadd = 0.25
			strengthadd = 0.25
			forceadd = 0.25
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "BuffMastery" = 3, "PureDamage" = 1, "PureReduction" = 1, "SaiyanPower" = 1, "SaiyanPowerVoid" = 1, "ZenkaiPower" = 0.5)
			angerPoint = 75

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
				var/asc = usr.AscensionsAcquired
				var/mdivP = mastery/100
				speed=1
				endurance=1
				offense=1
				defense=1
				strength=1
				force=1
				if(mastery >= 25 && asc > 2)
					speedadd = 0.35 * asc
					enduranceadd = 0.35 * asc
					offenseadd = 0.35 * asc
					defenseadd = 0.35 * asc
					strengthadd = 0.35 * asc
					forceadd = 0.35 * asc
					passives = list("Instinct" = 1+(mdivP*12), "Flow" = 1+(mdivP*10), "Flicker" = 1+(mdivP*10), "Pursuer" = 2+(mdivP*10), "PureDamage" = 1+(2*asc), "PureReduction" = 1+(2*asc), "SaiyanPower" = 1, "SaiyanPowerVoid" = 1+(1.5*asc), "ZenkaiPower" = 0.5+(0.25*asc))

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


		spectral_tension // temp
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "BuffMastery" = 3, "PureDamage" = 1, "PureReduction" = 1)
			speedadd = 0.35
			enduranceadd = 0.35
			offenseadd = 0.35
			defenseadd = 0.35
			strengthadd = 0.35
			forceadd = 0.35
			pot_trans = 20
			transformation_message = "usrName manifests the true nature of their body!"
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon = x
					form_icon_2_icon = x
				..()

			mastery_boons(mob/user)
				speed=1
				endurance=1
				offense=1
				defense=1
				strength=1
				force=1
				var/asc = usr.AscensionsAcquired
				var/mdivP = mastery/100
				if(mastery >= 25 && asc > 2)
					speedadd = 0.45 + (0.35 * asc)
					enduranceadd = 0.45 + (0.35 * asc)
					offenseadd = 0.45 + (0.35 * asc)
					defenseadd = 0.45 + (0.35 * asc)
					strengthadd = 0.45 + (0.35 * asc)
					forceadd = 0.45 + (0.35 * asc)
					passives = list("Instinct" = 1+(mdivP*14), "Flow" = 1+(mdivP*11), "Flicker" = 1+(mdivP*11), "Pursuer" = 2+(mdivP*12), "PureDamage" = 1+(2.5*asc), "PureReduction" = 1+(2.5*asc))

			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwavePurple.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2