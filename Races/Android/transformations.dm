transformation
	android
		super_android
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "Agoro"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_icon_1_icon = 'Trucker_Hat.dmi'
			form_glow_x = -32
			form_glow_y = -32
			unlock_potential = 30
			mastery_boons(mob/user)
				var/list/chippassives = list("Godspeed" = round(user.EnhancedSpeed/6, 1))
				var/list/basepassives
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ripper_Mode, user.contents))
					basepassives = list("LifeSteal" = 20)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Overdrive,user.contents))
					basepassives = list( "ManaGeneration" = 2)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Hilbert_Effect,user.contents))
					basepassives = list()
				if(user.InfinityModule)
					basepassives = list("ManaGeneration" = 1)
				passives=chippassives+basepassives
			transform_animation(mob/user)
				LightningStrike2(user)
				user.Quake(10)
			transform(mob/user)
				if(user.SuperAndroid)
					..()
				else return 0