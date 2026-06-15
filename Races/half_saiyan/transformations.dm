// human oriented saiyan transformations

/transformation/half_saiyan/human/potential_release // move this to asc 1 maybe, depends on how trans works
	unlock_potential = 20
	passives = list()



/transformation/half_saiyan/human/ultimate_mode
	form_aura_icon = 'ultimate_aura.dmi'
	form_aura_x = -28
	form_icon_2_icon = 'ultimate_elec.dmi'
	unlock_potential = 65
	passives = list("Mystic" = 1, "PUSpike" = 65, "Godspeed" = 1.5, "Adaptation" = 4, \
						"Brutalize" = 2, "LikeWater" = 6, "BuffMastery" = 2)
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
		passives = list("Mystic" = 1,"MovementMastery" = (user.AscensionsAcquired*1.5), "Godspeed" = 1.5, "Adaptation" = 4, \
						"Brutalize" = 1.5, "LikeWater" = 6 + round(user.Potential/25, 1), "SaiyanPower3"=0.35)
		speedadd = 1 //these are additive. base is 1, so 0.3=1.3x
		enduranceadd = 1
		offenseadd = 1
		defenseadd = 1
		strengthadd = 1
		forceadd = 1
	adjust_transformation_visuals(mob/user)
		if(user.Hair_Base && !form_hair_icon)
			var/icon/x=new(user.Hair_Base)
			form_hair_icon=x
		. = ..()


	transform_animation(mob/user)
		if(mastery < 50)
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
		else
			KenShockwave2(user, icon='KenShockwaveGold.dmi', Size=70, Time = 45)
			animate(user, color = list(1,0,0, 0,1,0, 0,0,1, 1.5,0.9,0.1), time=5)
			spawn(5)
				spawn(50)
					if(!user.HasKiControl()&&!user.PoweringUp)
						user.Auraz("Remove")
				animate(user, color = null, time=5)


/transformation/half_saiyan/human/beast_mode // XD

	form_aura_icon = 'Super Amazing Beast Aura.dmi'
	form_aura_x = -32
	unlock_potential = 90
	passives = list("Hidden Potential" = 1, "Mystic" = 1, "PUSpike" = 1, "BuffMastery" = 1, \
					"LikeWater" = 1, "Brutalize"= 1, "Momentum" = 1, "Overwhelming" = 1,"Heavy Attack" = "Beast Mode")
	// Rupture applies a debuff that causes bleed damage, overwhelming applies a debuff that increases damage dealt
	mastery_boons(mob/user)
		var/pot = user.Potential
		passives = list("Hidden Potential" = 1, "Mystic" = 1, "PUSpike" = round(pot) + round(mastery/2, 50), "BuffMastery" = 9, \
					"LikeWater" = 8 + round(pot/25, 1), "Brutalize" = 4, "Momentum" = 10, "Overwhelming" = glob.BEAST_OVERHWELMING_STATIC,"Heavy Attack" = "Beast", \
					"TechniqueMastery" = 5)
		unlock_potential=90
	transform_animation(mob/user)
		if(first_time)
			user.CutsceneMode()
			user.BeastAnimation()
	adjust_transformation_visuals(mob/user)
		if(user.Hair_Base && !form_hair_icon)
			var/icon/x=new(user.Hair_Base)
			form_hair_icon=x
		. = ..()

/transformation/half_saiyan/saiyan/super_saiyan_rage

	form_aura_icon = 'SSBGlow.dmi'
	form_aura_x = -32
	form_aura_y = -32
	passives = list("GodKi" = 0.25, "Instinct" = 4, "Brutalize" = 1.5, "Steady" = 3,  "BuffMastery" = 4, "MovementMastery" = 3, \
					"PureDamage" = 2, "PureReduction" = 1, "EnergyLeak" = 3)
	strength = 1.5
	speed = 1.5
	force = 1.5
	unlock_potential = 80
	mastery_boons(mob/user)
		var/pot = user.Potential
		if(mastery<50)
			passives = list("GodKi" = 0.25, "Instinct" = 4, "Brutalize" = 1.5 + (pot/50), "Steady" = 2 + round(pot/25),  "BuffMastery" = 5, "MovementMastery" = 3 + (pot/50), \
					"PureDamage" = 4, "PureReduction" = 1.5, "EnergyLeak" = 3)
		if(mastery>=50)
			passives = list("GodKi" = 0.5, "Instinct" = 4, "Brutalize" = 1.5 + (pot/50), "Steady" = 2 + round(pot/25),  "BuffMastery" = 5, "MovementMastery" = 3 + (pot/50), \
					"PureDamage" = 4, "PureReduction" = 1.5, "EnergyLeak" = 2)
		if(mastery==100)
			passives = list("GodKi" = 0.75, "Instinct" = 4, "Brutalize" = 1.5 + (pot/50), "Steady" = 2 + round(pot/25),  "BuffMastery" = 5, "MovementMastery" = 3 + (pot/50), \
					"PureDamage" = 4, "PureReduction" = 1.5, "EnergyLeak" = 1)

		strength = 1.5
		speed = 1.5
		force = 1.5
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
	adjust_transformation_visuals(mob/user)
		if(user.Hair_Base && !form_hair_icon)
			var/icon/x=new(user.Hair_Base)
			if(x)
				x.Blend(rgb(160,130,0),ICON_ADD)
				form_hair_icon=x
		if(!form_icon_1)
			form_icon_1 = image(user.Hair_SSJ2)
			form_icon_1.blend_mode=BLEND_MULTIPLY
			form_icon_1.alpha=125
			form_icon_1.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)
		..()

