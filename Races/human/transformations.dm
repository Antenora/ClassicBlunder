transformation
	human
		high_tension
			passives = list("Conductor" = 10, "HighTension"=1,"TensionPowered"=0.25,"TechniqueMastery"=1, "BuffMastery" = 2, "PureReduction"=2, "PureDamage"=2)
			pot_trans = 2
			transformation_message = "usrName raises their tension!"
			detrans_message = "usrName lowers their tension to normal..."
			mastery_boons(mob/user)
				if(mastery >= 0)
					passives = list("Conductor" = 10, "HighTension"=1,"TensionPowered"=0.375,"TechniqueMastery"=1, "BuffMastery" = 2, "PureReduction"=2, "PureDamage"=2,"UnderDog"=0.3,"Tenacity"=2)
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
			passives = list("Conductor"= 10, "HighTension"=-0.125,"TensionPowered"=0.5, "StyleMastery" = 2, "BuffMastery" = 2,"TechniqueMastery"=1)
			pot_trans = 3
			form_aura_icon = 'AurasBig.dmi'
			form_aura_icon_state = "HT2"
			form_aura_x = -32
			transformation_message = "usrName maximizes their tension!"
			detrans_message = "usrName descends from their peak of tension..."
			mastery_boons(mob/user)
				if(mastery >= 0)
					pot_trans=3
					passives = list("Conductor"= 10, "HighTension"=-0.125,"TensionPowered"=0.375, "StyleMastery" = 2, "BuffMastery" = 2,"TechniqueMastery"=1,"UnderDog"=0.3,"Tenacity"=2)
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
			passives = list("Conductor" = 10, "HighTension"=-0.125,"TensionPowered"=0.125, "SuperHighTension" = 1, "StyleMastery" = 2, "BuffMastery" = 2,"TechniqueMastery"=3, "PureReduction"=2, "PureDamage"=2)
			transformation_message = "usrName pushes their tension beyond its limits, becoming everything they could ever be!"
			mastery_boons(mob/user)
				if(mastery >= 0)
					pot_trans = 3
					passives = list("Conductor"= 10, "HighTension"=-0.125, "TensionPowered"=0.125, "SuperHighTension" = 1, "StyleMastery" = 2, "BuffMastery" = 2,"TechniqueMastery"=3, "PureReduction"=2, "PureDamage"=2,"UnderDog"=0.4,"Tenacity"=3)
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
			passives = list("Conductor" = 10, "TensionPowered"=0.125, "SuperHighTension" = 1, "StyleMastery" = 2, "BuffMastery" = 2,"TechniqueMastery"=5, "DoubleHelix" = 1)
			pot_trans = 5
			transformation_message = "usrName maximizes the very limits of their potential, evolving beyond the person they were a minute before!"
			mastery_boons(mob/user)
				if(mastery >= 0)
					passives = list("Conductor"= 10, "TensionPowered"=0.125, "SuperHighTension" = 1, "StyleMastery" = 2, "BuffMastery" = 2,"TechniqueMastery"=5, "DoubleHelix" = 1,"UnderDog"=1,"Tenacity"=10)
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
					ShockSize/=2