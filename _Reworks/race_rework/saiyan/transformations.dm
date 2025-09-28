transformation
	saiyan
		super_saiyan
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ"
			form_aura_x = -32
			form_icon_1_icon = 'SS2Sparks.dmi'
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			unlock_potential = 40
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2,  "BuffMastery" = 3, "PureDamage" = 1, "PureReduction" = 1)
			angerPoint = 75

			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.MapColors(0.2,0.2,0.2, 0.39,0.39,0.39, 0.07,0.07,0.07, 0.69,0.42,0)
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

		super_saiyan_2
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ2"
			form_aura_x = -32
			form_icon_2_icon = 'SS2Sparks.dmi'
			unlock_potential = 55
			autoAnger = TRUE
			passives = list("Instinct" = 1, "Flow" = 1, "Flicker" = 1, "Pursuer" = 2, "BuffMastery" = 1, "PureDamage" = 1, "PureReduction" = 1)
			PUSpeedModifier = 1.5
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
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ2"
			form_aura_x = -32
			form_icon_2_icon = 'SS3Sparks.dmi'
			form_hair_icon = 'Hair_SSj3.dmi'
			form_icon_1_icon = 'Hair_SSj3.dmi'
			passives = list("Flicker" = 1, "Pursuer" = 1, "BuffMastery" = 2, "PureDamage" = 1, "PureReduction" = 1)
			unlock_potential = 65

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