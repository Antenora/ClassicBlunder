
/transformation/saiyan/super_saiyan_god
	passives = list("GodKi" = 0.5, "EnergyGeneration" = 1, "Godspeed" = 4, "Flow" = 4, "BackTrack" = 2, "StunningStrike" = 1, "Sunyata" = 1 )
	unlock_potential = 80
	form_aura_icon = 'SSBGlow.dmi'
	form_aura_x = -32
	form_aura_y = -32
	// at full mastery, give the saiyan beyond god buff, then remove ssjgod, and replace it with ssjgb
	mastery_boons(mob/user)
		passives = list("GodKi" = 0.5, "EnergyGeneration" = 5 * (mastery/100), "Godspeed" = 4, "Flow" = 1 + round(mastery/25, 1), \
						 "BackTrack" = round(mastery/50, 1) , "StunningStrike" = 2.5 * (mastery/100), "Sunyata" = 5 * (mastery/100))
	// in order to do first transformation, 4 saiyans need to be giving energy (this is troll, but who cares)
	adjust_transformation_visuals(mob/user)
		if(user.Hair_Base && !form_hair_icon)
			var/icon/x=new(user.Hair_Base)
			if(x)
				x.Blend(rgb(159, 27, 51),ICON_ADD)
			form_hair_icon=x
		..()
	transform_animation(mob/user)
		if(mastery < 75)
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
		if(mastery>=100)
			user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/SaiyanBeyondGod)
			user << "You are able to use your god boons in base form (Beyond God Buff)"
			user.race.transformations-=src
			del src
		else
			..()


/transformation/saiyan/super_saiyan_blue
	passives = list("GodKi" = 1, "Instinct" = 4, "Brutalize" = 1)
	unlock_potential = 80
	autoAnger = 1
	form_aura_icon = 'SSBGlow.dmi'
	form_aura_x = -32
	form_aura_y = -32
	strength = 1.3
	speed = 1.3
	offense = 1.2
	defense = 1.2
	force = 1.3
	mastery_boons(mob/user)
		passives = list("GodKi" = 0.75, "Instinct" = 4, "Brutalize" = 1.5, "Steady" = 3,  "BuffMastery" = 6, "MovementMastery" = 5, \
						"PureDamage" = 2, "PureReduction" = 1)
		
		if(mastery >= 100)
			// perfected
			passives = list("GodKi" = 1, "Instinct" = 4, "Brutalize" = 3, "BuffMastery" = 8, "Steady" = 6, "MovementMastery" = 10, \
							"EnergyGeneration" = 3,  "PureDamage" = 2, "PureReduction" = 2, "Godspeed" = 4, "LikeWater" = 8, \
							"BackTrack" = 1 , "StunningStrike" = 2, "Sunyata" = 3)
			if(user.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride) // ssgsse
				passives = list("GodKi" = 1.25, "Brutalize" = 5, "BuffMastery" = 8, "MovementMastery" = 15, "EnergyLeak" = 3, \
						 	"PureDamage" = 3, "PureReduction" = 1, "Godspeed" = 4, "LikeWater" = 10, \
							"Sunyata" = 6)
				strength = 2
				speed = 2
				force = 2

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
		if(user.CheckSlotless("Beyond God"))
			..()
		else return 0
	
	transform_animation(mob/user)
		user.SlotlessBuffs["Beyond God"].Trigger(user, TRUE)
		// disable
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
		user.transActive = 1
		..()
	//UBuffNeeded