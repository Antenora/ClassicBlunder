transformation
	makaioshin
		falldown_mode
			passives = list("HellPower" = 0.1, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 0.5)
			autoAnger = 1
			unlock_potential = 50
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			strength = 1 //will clean this up in between wipes
			speed = 1
			offense = 1
			defense = 1
			force = 1
			endurance = 1
			transformation_message = "usrName has resolved their contradictory nature! Darkness and light, once wandering through creation, gather together and open the door to truth!"
			adjust_transformation_visuals(mob/user)
				if(!form_hair_icon&&user.Hair_Base)
					var/icon/x=new(user.Hair_Base)
					form_hair_icon = x
					form_icon_2_icon = x
				..()
			transform(mob/user, forceTrans)
				var/was_active = is_active
				..()
				if(!was_active && is_active)
					var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da
					for(var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/candidate in user)
						if(user.BuffOn(candidate))
							da = candidate
							break
					if(!da)
						da = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
					if(da)
						da.applyDTIcons(user)
			revert(mob/user)
				var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da
				for(var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/candidate in user)
					if(user.BuffOn(candidate))
						da = candidate
						break
				if(!da)
					da = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
				if(da)
					da.revertDTIcons(user)
				..()
			mastery_boons(mob/user)
				strength = 1
				speed = 1
				offense = 1
				defense = 1
				force = 1
				endurance = 1
				enduranceadd = 0.25
				offenseadd = 0.25
				defenseadd = 0.25
				strengthadd = 0.25
				forceadd = 0.25
				speedadd = 0.25
				if(user.Potential>=40&&mastery<25)
					mastery=25
				if(user.Potential>=50&&mastery<50)
					mastery=50
				if(user.Potential>=65&&mastery<75)
					mastery=75
				if(user.Potential>=80&&mastery<100)
					mastery=100
				if(mastery >= 25)
					passives = list("GodKi" = 0.15, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 1, "HellRisen" = 0.25)
					enduranceadd = 0.35
					offenseadd = 0.35
					defenseadd = 0.35
					strengthadd = 0.35
					forceadd = 0.35
					speedadd = 0.35
				if(mastery >= 50)
					passives = list("GodKi" = 0.25, "AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 4, "FluidForm" = 1, "Juggernaut" = 1.5, "HellRisen" = 0.5)
					enduranceadd = 0.5
					offenseadd = 0.5
					defenseadd = 0.5
					strengthadd = 0.5
					forceadd = 0.5
					speedadd = 0.5
				if(mastery >= 75)
					passives = list("GodKi" = 0.35, "AngerAdaptiveForce" = 0.75,"TechniqueMastery" = 6, "FluidForm" = 1.5, "Juggernaut" = 2,"HellRisen" = 0.75)
					enduranceadd = 0.5
					offenseadd = 0.5
					defenseadd = 0.5
					strengthadd = 0.5
					forceadd = 0.5
					speedadd = 0.5
				if(mastery >= 100)
					passives = list("GodKi" = 0.5, "AngerAdaptiveForce" = 1,"TechniqueMastery" = 8, "FluidForm" = 2, "Juggernaut" = 3,"HellRisen" = 1)
					enduranceadd = 1
					offenseadd = 1
					defenseadd = 1
					strengthadd = 1
					forceadd = 1
					speedadd = 1
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveBloodlust.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2
		satan_mode
			passives = list("GodKi" = 0.75, "HolyMod" = 10, "AbyssMod" = 10, "SpiritPower" = 2, "PhysPleroma" = 3, "Purity" = 1, "BeyondPurity" = 1)
			autoAnger = 1
			unlock_potential = 90
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			enduranceadd = 1
			offenseadd = 1
			defenseadd = 1
			strengthadd = 1
			forceadd = 1
			speedadd = 1
			transformation_message = "Between Heaven and Hell... usrName appears from Purgatory."
			transform(mob/user, forceTrans)
				var/was_active = is_active
				..()
				if(!locate(/obj/Skills/AutoHit/Purgatorial_Flame) in user)
					user.AddSkill(new/obj/Skills/AutoHit/Purgatorial_Flame)
				if(!locate(/obj/Skills/Projectile/Beams/Divine_Atonement) in user)
					user.AddSkill(new/obj/Skills/Projectile/Beams/Divine_Atonement)
				if(!was_active && is_active)
					var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da
					for(var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/candidate in user)
						if(user.BuffOn(candidate))
							da = candidate
							break
					if(!da)
						da = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
					if(da)
						da.applyDTIcons(user)
			revert(mob/user)
				var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da
				for(var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/candidate in user)
					if(user.BuffOn(candidate))
						da = candidate
						break
				if(!da)
					da = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
				if(da)
					da.revertDTIcons(user)
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
				LightningStrike2(user)
				DarknessFlash(user, SetTime=5)
