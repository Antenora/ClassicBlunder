// human oriented saiyan transformations

/transformation/half_saiyan/human/potential_release // move this to asc 1 maybe, depends on how trans works
	unlock_potential = 20
	passives = list()



/transformation/half_saiyan/human/ultimate_mode
	form_aura_icon = 'ultimate_aura.dmi'
	form_aura_x = -28
	form_icon_2_icon = 'ultimate_elec.dmi'
	unlock_potential = 65
	pot_trans = 5
	passives = list("Mystic" = 1, "PUSpike" = 65, "Godspeed" = 1.5, "Adaptation" = 4, \
						"Brutalize" = 2, "LikeWater" = 6, "BuffMastery" = 2)
	strength = 1.15
	speed = 1.2
	force = 1.15
	offense = 1.2
	proc/shockwaves(mob/p)
		set waitfor = 0
		for(var/wav=25, wav>0, wav--)
			KKTShockwave(p, icon='fevKiai.dmi', Size=4, Time=16)
			sleep(4)
	proc/rocks(mob/p)
		set waitfor = 0
		for(var/turf/t in Turf_Circle(p, 18))
			if(prob(25))
				var/icon/i = icon('RisingRocks.dmi')
				t.overlays+=i
				spawn(rand(40, 80))
					t.overlays-=i
	proc/hair_anim(mob/user)
		set waitfor = 0
		var/image/HF=image(icon=user.Hair_Base, pixel_x=user.HairX, pixel_y=user.HairY, loc = user)
		world<<HF
		HF.appearance_flags=KEEP_APART | NO_CLIENT_COLOR | RESET_ALPHA | RESET_COLOR
		HF.color=null
		animate(HF, alpha=0, time = 0, flags = ANIMATION_PARALLEL)
		animate(HF,alpha=210, time=5, flags = ANIMATION_PARALLEL)
		sleep(5)
		animate(HF,alpha=0, time=10, flags = ANIMATION_PARALLEL)
		sleep(10)
		animate(HF,alpha=210, time=5, flags = ANIMATION_PARALLEL)
		sleep(5)
		animate(HF,alpha=0, time=5, flags = ANIMATION_PARALLEL)
		sleep(5)
		animate(HF,alpha=210, time=25, flags = ANIMATION_PARALLEL)
		sleep(40)
		del HF
	// one of these was holding it up
	mastery_boons(mob/user)
		// apply scaling passives here
		passives = list("Mystic" = 1,"PUSpike" = user.Potential + round(mastery/2, 10), "Godspeed" = 1.5, "Adaptation" = 4, \
						"Brutalize" = 1.5, "LikeWater" = 6 + round(user.Potential/25, 1), "BuffMastery" = 2)
		pot_trans = max(65, 65 + ((glob.progress.PotentialDaily * 10)- user.Potential))
	adjust_transformation_visuals(mob/user)
		if(user.Hair_Base && !form_hair_icon)
			var/icon/x=new(user.Hair_Base)
			form_hair_icon=x
		..()


	transform_animation(mob/user)
		Crater(user)
		for(var/transformation/trans in user.race.transformations)
			if(trans == src)
				break
			user.overlays -= trans.form_aura
			user.underlays -= trans.form_aura_underlay
		user.Auraz("Remove")
		shockwaves(user)
		rocks(user)
		hair_anim(user)
		KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=70, Time = 45)
		user.Earthquake(60,-8,8,-8,8,999)

/transformation/half_saiyan/human/beast_mode // XD

	form_aura_icon = 'Super Amazing Beast Aura.dmi'
	form_aura_x = -32
	passives = list("Hidden Potential" = 1, "Mystic" = 1, "PUSpike" = 1, "BuffMastery" = 1, \
					"LikeWater" = 1, "Brutalize"= 1, "Momentum" = 1, "Rupture" = 1, "Overwhelming" = 1,"Heavy Attack" = "Beast Mode")
	// Rupture applies a debuff that causes bleed damage, overwhelming applies a debuff that increases damage dealt
	mastery_boons(mob/user)
		var/pot = user.Potential
		passives = list("Hidden Potential" = 1, "Mystic" = 1, "PUSpike" = round(pot) + round(mastery/2, 10), "BuffMastery" = 4, \
					"LikeWater" = 8 + round(pot/25, 1), "Brutalize" = 4, "Momentum" = 10, "Rupture" = 1, "Overwhelming" = glob.BEAST_OVERHWELMING_STATIC,"Heavy Attack" = "Beast", \
					"TechniqueMastery" = 5)
		pot_trans = 90


