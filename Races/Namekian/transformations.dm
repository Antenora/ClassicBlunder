/proc/NamekFormBand(potential)
	if(potential >= 65)
		return 3
	if(potential >= 55)
		return 2
	if(potential >= NAMEK_FORM_POTENTIAL)
		return 1
	return 0

/proc/NamekResyncHatchling(mob/user)
	if(!user || !user.NamekHatchling)
		return
	if(hascall(user.NamekHatchling, "NamekHatchResync"))
		call(user.NamekHatchling, "NamekHatchResync")()

transformation
	namekian
		unlock_potential = NAMEK_FORM_POTENTIAL
		pot_trans = 5
		form_icon_1_layer = FLOAT_LAYER - 2
		var
			clan
			tmp
				band = 0
				list/band_passives = list(list(), list(), list())

				list/look_aura = list(null, null, null)
				list/look_aura_state = list(null, null, null)
				look_aura_x = -32
				look_aura_y = 0
				list/look_glow = list(0, 0, 0)
				look_glow_icon = 'Icons/Aura/Ripple Radiance.dmi'
				look_glow_x = -32
				look_glow_y = -32
				look_glow_alpha = 40
				list/look_glow_color
				list/look_eyes = list(null, null, null)
				list/look_mark = list(null, null, null)
				list/look_mark_state = list(null, null, null)
				look_mark_x = -32
				look_mark_y = -32
				list/look_body = list(null, null, null)
				look_body_x = 0
				look_body_y = 0
				list/look_flash = list(list(1, 0.9, 0.2), list(1, 0.9, 0.2), list(1, 0.9, 0.2))
				list/look_quake = list(10, 20, 30)
				list/look_strike = list(0, 0, 0)

		mastery_boons(mob/user)
			band = NamekFormBand(user.Potential)
			var/add = NamekShare(user) * NamekLadderForm(user.Potential)
			strengthadd = add
			enduranceadd = add
			forceadd = add
			offenseadd = add
			defenseadd = add
			speedadd = add
			if(band)
				var/list/p = band_passives[band]
				passives = p.Copy()
			else
				passives = list()
			NamekBandLook(user, clamp(band, 1, 3))

		proc/NamekBandLook(mob/user, look)
			form_aura_icon = look_aura[look]
			form_aura_icon_state = look_aura_state[look]
			form_aura_x = look_aura_x
			form_aura_y = look_aura_y
			form_aura_underlay_icon = null
			form_aura_underlay_icon_state = null
			if(!form_aura_icon)
				for(var/obj/Skills/Power_Control/M in user)
					if(user.AuraLockedUnder == 1)
						form_aura_underlay_icon = M.sicon
						form_aura_underlay_icon_state = M.sicon_state
						form_aura_underlay_x = M.pixel_x
						form_aura_underlay_y = M.pixel_y
					else
						form_aura_icon = M.sicon
						form_aura_icon_state = M.sicon_state
						form_aura_x = M.pixel_x
						form_aura_y = M.pixel_y
					break
			form_glow_icon = look_glow[look] ? look_glow_icon : null
			form_glow_icon_state = null
			form_glow_x = look_glow_x
			form_glow_y = look_glow_y
			form_icon_1_icon = look_eyes[look]
			form_icon_1_icon_state = null
			form_underlay_1_icon = look_mark[look]
			form_underlay_1_icon_state = look_mark_state[look]
			form_underlay_1_x = look_mark_x
			form_underlay_1_y = look_mark_y

		proc/form_strike(mob/user, offset)
			LightningStrike2(user, Offset = offset)

		adjust_transformation_visuals(mob/user)
			..()
			if(form_glow_icon && look_glow_color)
				form_glow.blend_mode = BLEND_ADD
				form_glow.alpha = look_glow_alpha
				form_glow.color = look_glow_color

		apply_visuals(mob/user, aura = 1, hair = 1, extra = 1)
			..(user, aura, 0, extra)
			if(hair && user)
				var/icon/h = user.Hair_Base ? icon(user.Hair_Base) : null
				if(h && user.Hair_Color)
					h.Blend(user.Hair_Color, ICON_ADD)
				user.Hair = image(icon = h, pixel_x = user.HairX, pixel_y = user.HairY, layer = FLOAT_LAYER - 2)

		transform_animation(mob/user)
			var/look = clamp(band, 1, 3)
			if(first_time)
				DarknessFlash(user)
				sleep()
				form_strike(user, 4)
				user.Quake(10)
				sleep(20)
				form_strike(user, 4)
				user.Quake(20)
				sleep(30)
				form_strike(user, 4)
				user.Quake(30)
				user.Quake(50)
				spawn(1) form_strike(user, 2)
				spawn(3) form_strike(user, 2)
				spawn(5) form_strike(user, 2)
			else
				user.Quake(look_quake[look])
				if(look_strike[look])
					form_strike(user, 2)
			var/list/f = look_flash[look]
			animate(user, color = list(1,0,0, 0,1,0, 0,0,1, f[1],f[2],f[3]), time = 5)
			animate(color = user.MobColor, time = 5)
			sleep(5)
			if(is_active && look_body[look] && !stored_base)
				stored_base = user.icon
				stored_base_x = user.pixel_x
				stored_base_y = user.pixel_y
				user.icon = look_body[look]
				user.pixel_x = look_body_x
				user.pixel_y = look_body_y

		super_namekian
			clan = NAMEK_CLAN_WARRIOR
			angerFloor = 50
			band_passives = list(\
				list("Flicker" = 1, "Pursuer" = 1),\
				list("Flicker" = 1, "Pursuer" = 1, "TechniqueMastery" = 1, "Juggernaut" = 1),\
				list("Flicker" = 1, "Pursuer" = 1, "TechniqueMastery" = 1, "Juggernaut" = 1, "Orange Namekian" = 1, "Harden" = 2))
			look_aura = list('Icons/Aura/Amazing Super Namekian Aura.dmi', 'Icons/Aura/NamekAurasBig.dmi', 'Icons/Aura/NamekAurasBig.dmi')
			look_glow = list(0, 1, 1)
			look_glow_color = list(1,0,0, 0,0.8,0, 0,0,0, 0.2,0.2,0.2)
			look_eyes = list(null, null, 'Icons/Hair/Eyes/EyesSSG.dmi')
			look_body = list(null, null, 'Icons/Characters/Namek/Orange Namek.dmi')
			look_flash = list(list(0.5, 0.7, 1), list(1, 0.9, 0.2), list(1, 0.5, 0.1))

		demon_clan_release
			clan = NAMEK_CLAN_DEMON
			angerFloor = 50
			band_passives = list(\
				list("Fury" = 1),\
				list("Fury" = 1, "Momentum" = 1, "Flicker" = 1),\
				list("Fury" = 1, "Momentum" = 1, "Flicker" = 1, "DeathField" = 2))
			look_aura = list('Icons/Aura/AurasBig.dmi', 'Icons/Aura/Aura Red.dmi', 'Icons/Aura/AuraUnholy.dmi')
			look_aura_state = list("Demon", null, null)
			look_glow = list(0, 1, 1)
			look_glow_color = list(1,0,0, 0,0.1,0, 0,0,0.1, 0.25,0,0)
			look_eyes = list(null, null, 'Icons/Hair/Eyes/EyesSSG.dmi')
			look_mark = list('Icons/NSE/Aura/Heaven_Kanji_for_Ansat_Aura.dmi', 'Icons/NSE/Aura/Heaven_Kanji_for_Ansat_Aura.dmi', 'Icons/NSE/Aura/Heaven_Kanji_for_Ansat_Aura.dmi')
			look_flash = list(list(0.7, 0.1, 0.5), list(1, 0.1, 0.1), list(0.5, 0, 0.1))
			look_strike = list(0, 1, 1)

			form_strike(mob/user, offset)
				LightningStrikeRed(user, Offset = offset)

		dragon_awakening
			clan = NAMEK_CLAN_DRAGON
			angerFloor = 0
			band_passives = list(\
				list("QuickCast" = 1, "ManaGeneration" = 1),\
				list("QuickCast" = 1, "ManaGeneration" = 1, "TechniqueMastery" = 1),\
				list("QuickCast" = 1, "ManaGeneration" = 1, "TechniqueMastery" = 1, "LifeGeneration" = 1))
			look_aura = list(null, null, 'Icons/Aura/AurasBig.dmi')
			look_aura_state = list(null, null, "SSJ")
			look_eyes = list('Icons/Hair/Eyes/EyesSSG.dmi', 'Icons/Hair/Eyes/EyesSSB.dmi', 'Icons/Hair/Eyes/EyesSSB.dmi')
			look_mark = list(null, null, 'Icons/Enchantment/Grimoire/Dragonballs.dmi')
			look_mark_state = list(null, null, "4")
			look_mark_x = 0
			look_mark_y = 14
			look_flash = list(list(1, 0.2, 0.2), list(0.2, 1, 0.8), list(1, 0.9, 0.2))

			transform(mob/user, forceTrans)
				var/was = is_active
				..()
				if(was != is_active)
					NamekResyncHatchling(user)

			revert(mob/user)
				var/was = is_active
				..()
				if(was != is_active)
					NamekResyncHatchling(user)
