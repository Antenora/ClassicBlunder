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
				var/list/chippassives = list("PureDamage" = round((user.EnhancedStrength/3)+(user.EnhancedForce/3),1), "PureReduction" = round(user.EnhancedEndurance/3, 1),\
				"Instinct"= round(user.EnhancedAggression/3, 1), "Flow" = round(user.EnhancedReflexes/3, 1), "Godspeed" = round(user.EnhancedSpeed/6, 1))
				var/list/basepassives
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ripper_Mode, user.contents))
					basepassives = list("LifeSteal" = 20)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Armstrong_Augmentation, user.contents))
					basepassives = list("CallousedHands" = 0.3)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ray_Gear, user.contents))
					basepassives = list("SpiritHand" = 0.5, "SpiritSword" = 0.5)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Overdrive,user.contents))
					basepassives = list("MovementMastery" = 6, "ManaGeneration" = 2)
				if(locate(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Hilbert_Effect,user.contents))
					basepassives = list("Deicide" = 5, "EndlessNine" = 0.2)
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