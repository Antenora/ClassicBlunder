transformation
	celestial
		Master_of_Arms
			passives = list("Heavy Strike" = "Warp Strike", "Parry" = 2, "ManaGeneration" = 5, "Iaijutsu" = 4, "Deflection" = 5, "MovingCharge" = 1)
			unlock_potential = 55
			speedadd = 0.1
			enduranceadd = 0.1
			offenseadd = 0.1
			defenseadd = 0.1
			strengthadd = 0.1
			forceadd = 0.1
			transformation_message = "<b>usrName invokes their Divine Armory!</b>"

			proc/get_divine_armory_count(mob/user)
				var/count = 0
				for(var/obj/Items/Sword/Celestial/S in user)
					if(S.suffix == "*Equipped (Armory)*")
						count++
				for(var/obj/Items/Enchantment/Staff/Celestial/S in user)
					if(S.suffix == "*Equipped (Armory)*")
						count++
				return count

			transform(mob/user, forceTrans)
				var/armory_count = get_divine_armory_count(user)
				var/add_per_stat = 0.4 + (armory_count * 0.6)
				strengthadd = add_per_stat
				enduranceadd = add_per_stat
				forceadd = add_per_stat
				offenseadd = add_per_stat
				defenseadd = add_per_stat
				speedadd = add_per_stat
				..()
			var/list/orbit_weapon_data
			var/list/orbit_overlay_images
			var/orbiting = FALSE
			var/orbit_current_angle = 0
			var/orbit_rotation_angle = 0

			transform_animation(mob/user)
				if(!locate(/obj/Skills/Projectile/Warp_Strike_MasterOfArms, user))
					user.AddSkill(new/obj/Skills/Projectile/Warp_Strike_MasterOfArms)
				if(!locate(/obj/Skills/Grapple/Flashback, user))
					user.AddSkill(new/obj/Skills/Grapple/Flashback)
				LightningStrike2(user, Offset=0)
				spawn(5)
					LightningStrike2(user, Offset=1)
				spawn(1)
					LightningStrike2(user, Offset=1)
				spawn(2)
					LightningStrike2(user, Offset=1)
				spawn(1)
					LightningStrike2(user, Offset=1)
				spawn(2)
					LightningStrike2(user, Offset=1)
				spawn(1)
					LightningStrike2(user, Offset=1)
				sleep(1)
				var/ShockSize = 5
				for(var/wav = 5, wav > 0, wav--)
					KenShockwave(user, icon='KenShockwaveDivine.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize /= 2

				var/list/armory_weapons = list()
				for(var/obj/Items/Sword/Celestial/S in user)
					if(S.suffix == "*Equipped (Armory)*")
						armory_weapons += S
				for(var/obj/Items/Enchantment/Staff/Celestial/S in user)
					if(S.suffix == "*Equipped (Armory)*")
						armory_weapons += S

				if(!armory_weapons.len) return

				orbit_weapon_data = list()
				orbit_overlay_images = list()
				var/n = armory_weapons.len
				var/R = 20
				var/list/base_angles = get_orbit_angles(n)
				var/placement = FLOAT_LAYER - 3

				for(var/i = 1 to n)
					var/obj/Items/W = armory_weapons[i]
					var/list/dat = list("icon" = W.icon, "base_angle" = base_angles[i])
					if(W.icon_state) dat["icon_state"] = W.icon_state
					orbit_weapon_data += list(dat)

				var/float_ticks = 15
				var/fade_ticks = 10
				for(var/tick = 0 to float_ticks - 1)
					if(!user || !orbit_weapon_data) return
					remove_orbit_overlays(user)
					var/t = (tick + 1) / float_ticks
					var/white = 1
					for(var/i = 1 to n)
						var/list/dat = orbit_weapon_data[i]
						var/px = round(t * cos(dat["base_angle"]) * R)
						var/py = round(t * sin(dat["base_angle"]) * R)
						var/image/im = image(icon=dat["icon"], pixel_x=px, pixel_y=py, layer=placement)
						if(dat["icon_state"]) im.icon_state = dat["icon_state"]
						if(user.ArmamentGlow) im.filters += user.ArmamentGlow
						if(white > 0)
							im.color = list(1,0,0, 0,1,0, 0,0,1, white, white, white)
						user.overlays += im
						orbit_overlay_images += im
					sleep(1)

				for(var/tick = 0 to fade_ticks - 1)
					if(!user || !orbit_weapon_data) return
					remove_orbit_overlays(user)
					var/white = 1 - ((tick + 1) / fade_ticks)
					if(white < 0) white = 0
					for(var/i = 1 to n)
						var/list/dat = orbit_weapon_data[i]
						var/px = round(cos(dat["base_angle"]) * R)
						var/py = round(sin(dat["base_angle"]) * R)
						var/image/im = image(icon=dat["icon"], pixel_x=px, pixel_y=py, layer=placement)
						if(dat["icon_state"]) im.icon_state = dat["icon_state"]
						if(user.ArmamentGlow) im.filters += user.ArmamentGlow
						if(white > 0)
							im.color = list(1,0,0, 0,1,0, 0,0,1, white, white, white)
						user.overlays += im
						orbit_overlay_images += im
					sleep(1)

				start_orbit(user)

			proc/remove_orbit_overlays(mob/user)
				if(user && orbit_overlay_images)
					for(var/image/im in orbit_overlay_images)
						user.overlays -= im
					orbit_overlay_images = list()

			proc/get_orbit_angles(n)
				switch(n)
					if(1) return list(90)
					if(2) return list(90, 45)
					if(3) return list(90, 45, 135)
					if(4) return list(90, 45, 135, 0)
					if(5) return list(90, 45, 135, 0, 180)
					else
						var/list/a = list()
						for(var/i = 0 to n-1)
							a += 90 + (i * 360 / n)
						return a

			proc/start_orbit(mob/user)
				if(!orbit_weapon_data || !orbit_weapon_data.len) return
				orbiting = TRUE
				var/n = orbit_weapon_data.len
				var/R = 20
				var/step_time = 2
				var/orbit_speed = 15
				var/rotation_speed = 45
				orbit_current_angle = 0
				orbit_rotation_angle = 0
				var/placement = FLOAT_LAYER - 3
				spawn()
					while(src.orbiting && user && orbit_weapon_data && orbit_weapon_data.len)
						remove_orbit_overlays(user)
						orbit_current_angle += orbit_speed
						if(orbit_current_angle >= 360) orbit_current_angle -= 360
						orbit_rotation_angle += rotation_speed
						if(orbit_rotation_angle >= 360) orbit_rotation_angle -= 360
						for(var/i = 1 to n)
							var/list/dat = orbit_weapon_data[i]
							var/angle = dat["base_angle"] + orbit_current_angle
							var/px = round(cos(angle) * R)
							var/py = round(sin(angle) * R)
							var/image/im = image(icon=dat["icon"], pixel_x=px, pixel_y=py, layer=placement)
							if(dat["icon_state"]) im.icon_state = dat["icon_state"]
							im.transform = matrix().Turn(orbit_rotation_angle)
							if(user.ArmamentGlow) im.filters += user.ArmamentGlow
							user.overlays += im
							orbit_overlay_images += im
						sleep(step_time)

			proc/stop_orbit(mob/user)
				orbiting = FALSE
				remove_orbit_overlays(user)
				orbit_weapon_data = null
				orbit_overlay_images = null

			revert_animation(mob/user)
				if(!user || !orbit_weapon_data || !orbit_weapon_data.len) return
				orbiting = FALSE
				sleep(1)
				var/n = orbit_weapon_data.len
				var/R = 20
				var/placement = FLOAT_LAYER - 3
				var/flash_ticks = 3
				var/vanish_ticks = 12
				for(var/tick = 0 to flash_ticks - 1)
					if(!user || !orbit_weapon_data) return
					remove_orbit_overlays(user)
					for(var/i = 1 to n)
						var/list/dat = orbit_weapon_data[i]
						var/angle = dat["base_angle"] + orbit_current_angle
						var/px = round(cos(angle) * R)
						var/py = round(sin(angle) * R)
						var/image/im = image(icon=dat["icon"], pixel_x=px, pixel_y=py, layer=placement)
						if(dat["icon_state"]) im.icon_state = dat["icon_state"]
						im.transform = matrix().Turn(orbit_rotation_angle)
						im.color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1)
						if(user.ArmamentGlow) im.filters += user.ArmamentGlow
						user.overlays += im
						orbit_overlay_images += im
					sleep(1)
				for(var/tick = 0 to vanish_ticks - 1)
					if(!user || !orbit_weapon_data) return
					remove_orbit_overlays(user)
					var/alpha_val = 255 - round((tick + 1) * 255 / vanish_ticks)
					if(alpha_val <= 0) break
					for(var/i = 1 to n)
						var/list/dat = orbit_weapon_data[i]
						var/angle = dat["base_angle"] + orbit_current_angle
						var/px = round(cos(angle) * R)
						var/py = round(sin(angle) * R)
						var/image/im = image(icon=dat["icon"], pixel_x=px, pixel_y=py, layer=placement)
						if(dat["icon_state"]) im.icon_state = dat["icon_state"]
						im.transform = matrix().Turn(orbit_rotation_angle)
						im.color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1)
						im.alpha = alpha_val
						if(user.ArmamentGlow) im.filters += user.ArmamentGlow
						user.overlays += im
						orbit_overlay_images += im
					sleep(1)

			revert(mob/user)
				revert_animation(user)
				stop_orbit(user)
				..()
		Celestial_Devil_Trigger
			passives = list("HellRisen" = 0.25, "DemonicDurability" = 2, "PureDamage" = 1, "PureReduction" = 1, "Brutalize" = 2, "Smokin'!" = 1)
			speedadd = 0.5
			enduranceadd = 0.5
			offenseadd = 0.5
			defenseadd = 0.5
			strengthadd = 0.5
			forceadd = 0.5
			autoAnger = 1
			unlock_potential = 55
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			transformation_message = "usrName pulls their Devil Trigger."
			transform(mob/user, forceTrans)
				if(!forceTrans && user.StyleRating < 5)
					user << "You need at least an S Style Rating to pull your Devil Trigger!"
					return
				..()
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			mastery_boons(mob/user)
				if(user.Potential>=40&&mastery<25)
					mastery=25
				if(user.Potential>=50&&mastery<50)
					mastery=50
				if(user.Potential>=65&&mastery<75)
					mastery=75
				if(user.Potential>=80&&mastery<100)
					mastery=100
				if(mastery >= 25)
					passives = list("GodKi" = 0.15, "HellPower" = 0.25, "HellRisen" = 0.5, "DemonicDurability" = 4, "Brutalize" = 1, "PureDamage" = 3, "PureReduction" = 3, "Smokin'!" = 1)
				if(mastery >= 50)
					passives = list("GodKi" = 0.35, "HellPower" = 0.5, "HellRisen" = 0.75, "DemonicDurability" = 6, "Brutalize" = 2, "PureDamage" = 5, "PureReduction" = 5, "MovementMastery" = 3, "BuffMastery"= 3, "Smokin'!" = 1)
				if(mastery >= 75)
					passives = list("GodKi" = 0.5, "HellPower" = 0.75, "HellRisen" = 0.75, "DemonicDurability" = 6, "Brutalize" = 3, "PureDamage" = 6, "PureReduction" = 6, "MovementMastery" = 6, "TechniqueMastery" = 3, "Steady" = 3, "BuffMastery"= 6, "Smokin'!" = 1)
				if(mastery >= 100)
					passives = list("GodKi" = 1, "HellPower" = 1, "HellRisen" = 1, "DemonicDurability" = 6, "Brutalize" = 6, "PureDamage" = 6, "PureReduction" = 6, "MovementMastery" = 6, "TechniqueMastery" = 6, "Steady" = 6, "ManaStats" = 6, "BuffMastery"= 6, "Smokin'!" = 1)
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveBloodlust.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2
		Celestial_Sin_Devil_Trigger
			passives = list("Smokin' Sick Style!!!" = 1, "HellPower" = 1, "AbyssMod" = 6, "Scorching" = 6, "Poisoning" = 6, "DemonicInfusion" = 1, "CriticalChance" = 36, "CriticalDamage" = 0.6)
			speedadd = 2.5
			enduranceadd = 2.5
			offenseadd = 2.5
			defenseadd = 2.5
			strengthadd = 2.5
			forceadd = 2.5
			autoAnger = 1
			unlock_potential = 90
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			transformation_message = "usrName pulls their Sin Devil Trigger."
			transform(mob/user, forceTrans)
				if(!forceTrans && user.StyleRating < 7)
					user << "You need an SSS Style Rating to pull your Sin Devil Trigger!"
					return
				..()
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveBloodlust.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2
