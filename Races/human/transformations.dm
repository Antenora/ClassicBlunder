transformation
	human
		super_saiyan
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ"
			form_aura_x = -32
			form_glow_icon = 'Ripple Radiance.dmi'
			form_glow_x = -32
			form_glow_y = -32
			speedadd = 0.25
			enduranceadd = 0.25
			offenseadd = 0.25
			defenseadd = 0.25
			strengthadd = 0.25
			forceadd = 0.25
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
		super_saiyan_2
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "SSJ2"
			form_aura_x = -32
			form_icon_2_icon = 'SS2Sparks.dmi'
			speedadd = 0.25
			enduranceadd = 0.25
			offenseadd = 0.25
			defenseadd = 0.25
			strengthadd = 0.25
			forceadd = 0.25
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
			speedadd = 0.25
			enduranceadd = 0.25
			offenseadd = 0.25
			defenseadd = 0.25
			strengthadd = 0.25
			forceadd = 0.25
			adjust_transformation_visuals(mob/user)
				..()
				form_icon_1 = image(user.Hair_SSJ3)
				form_icon_1.blend_mode=BLEND_MULTIPLY
				form_icon_1.alpha=125
				form_icon_1.color=list(1,0,0, 0,0.82,0, 0,0,0, -0.26,-0.26,-0.26)
			transform_animation(mob/user)
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
		super_saiyan_4
			speedadd = 0.25
			enduranceadd = 0.25
			offenseadd = 0.25
			defenseadd = 0.25
			strengthadd = 0.25
			forceadd = 0.25
			var/previousTailIcon
			var/previousTailUnderlayIcon
			var/previousTailWrappedIcon
			var/tailIcon = 'saiyantail_ssj4.dmi'
			var/tailUnderlayIcon = 'saiyantail_ssj4_under.dmi'
			var/tailWrappedIcon = 'saiyantail-wrapped_ssj4.dmi'
			form_icon_1_icon = 'GokentoMaleBase_SSJ4.dmi'
			form_icon_1_layer = FLOAT_LAYER-3
			adjust_transformation_visuals(mob/user)
				if(user.Hair_Base && !form_hair_icon)
					var/icon/x=new(user.Hair_Base)
					x.Blend(rgb(150,-10,-10),ICON_ADD)
					form_hair_icon=x
				..()
			transform(mob/user)
				. = ..()
				previousTailIcon = user.TailIcon
				previousTailUnderlayIcon = user.TailIconUnderlay
				previousTailWrappedIcon = user.TailIconWrapped
				user.TailIcon = tailIcon
				user.TailIconUnderlay = tailUnderlayIcon
				user.TailIconWrapped = tailWrappedIcon
				user.Tail(1)

			revert(mob/user)
				. = ..()
				if(!is_active || !user.CanRevert()) return
				user.TailIcon = previousTailIcon
				user.TailIconUnderlay = previousTailUnderlayIcon
				user.TailIconWrapped = previousTailWrappedIcon
				previousTailIcon = null
				previousTailUnderlayIcon = null
				previousTailWrappedIcon = null
				user.Tail(1)
/*		high_tension
			passives = list("Conductor" = 10, "HighTension"=1,"TensionPowered"=0.25,"TechniqueMastery"=1)
			pot_trans = 2
			transformation_message = "usrName raises their tension!"
			detrans_message = "usrName lowers their tension to normal..."
			mastery_boons(mob/user)
				if(mastery >= 0)
					passives = list("Conductor" = 10, "HighTension"=1,"TensionPowered"=0.375,"TechniqueMastery"=1,  "UnderDog"=0.3,"Tenacity"=2)
					pot_trans = 2
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwavePurple.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2
		high_tension_MAX
			passives = list("Conductor"= 10, "HighTension"=-0.125,"TensionPowered"=0.5,  "TechniqueMastery"=1)
			pot_trans = 3
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "HT2"
			form_aura_x = -32
			transformation_message = "usrName maximizes their tension!"
			detrans_message = "usrName descends from their peak of tension..."
			mastery_boons(mob/user)
				if(mastery >= 0)
					pot_trans=3
					passives = list("Conductor"= 10, "HighTension"=-0.125,"TensionPowered"=0.375,  "TechniqueMastery"=1,"UnderDog"=0.3,"Tenacity"=2)
				if(!user.isMazokuPathHuman())
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Activate_High_Tension, user))
						var/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Activate_High_Tension/s=new/obj/Skills/Buffs/SlotlessBuffs/Racial/Human/Activate_High_Tension
						user.AddSkill(s)

			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.Blend(rgb(150,-10,150),ICON_ADD)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwavePurple.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2
		super_high_tension
			pot_trans = 3
			form_aura_icon = 'SpiralAura.dmi'
			form_aura_x = -32
			passives = list("Conductor" = 10, "HighTension"=-0.125,"TensionPowered"=0.125, "SuperHighTension" = 1,  "TechniqueMastery"=3)
			transformation_message = "usrName pushes their tension beyond its limits, becoming everything they could ever be!"
			mastery_boons(mob/user)
				if(mastery >= 0)
					pot_trans = 3
					passives = list("Conductor"= 10, "HighTension"=-0.125, "TensionPowered"=0.125, "SuperHighTension" = 1,  "TechniqueMastery"=3, "UnderDog"=0.4,"Tenacity"=3)
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.Blend(rgb(-10,150,50),ICON_ADD)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveLegend.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize*=2
		super_high_tension_MAX
			passives = list("Conductor" = 10, "TensionPowered"=0.125, "SuperHighTension" = 1,  "TechniqueMastery"=5, "DoubleHelix" = 1)
			pot_trans = 5
			transformation_message = "usrName maximizes the very limits of their potential, evolving beyond the person they were a minute before!"
			mastery_boons(mob/user)
				if(mastery >= 0)
					passives = list("Conductor"= 10, "TensionPowered"=0.125, "SuperHighTension" = 1,  "TechniqueMastery"=5, "DoubleHelix" = 1,"UnderDog"=1,"Tenacity"=10)
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					if(x)
						x.Blend(rgb(-10,150,50),ICON_ADD)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			transform_animation(mob/user)
				var/ShockSize=5
				LightningStrike2(user, Offset=0)
				spawn(10)
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveLegend.dmi', Size=ShockSize, Blend=2, Time=8)
		unlimited_high_tension
			passives = list("Conductor"= 10, "UnlimitedHighTension" = 1, "CreateTheHeavens" = 1)
			pot_trans = 15
			transformation_message = "usrName shatters through heaven and earth, becoming equal to the Gods!!"
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			transform(mob/user)
				user.TotalFatigue=0
				user.Energy=user.EnergyMax
				..()
			transform_animation(mob/user)
				var/ShockSize=5
				LightningStrike2(user, Offset=0)
				spawn(10)
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveDivine.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2*/