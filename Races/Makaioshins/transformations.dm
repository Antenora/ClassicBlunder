transformation
	makaioshin
		falldown_mode
			passives = list("HellPower" = 0.1, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 0.5)
			autoAnger = 1
			unlock_potential = 50
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			strength = 1.2
			speed = 1.2
			offense = 1.2
			defense = 1.2
			force = 1.2
			endurance = 1.2
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
				if(mastery >= 25)
					passives = list("GodKi" = 0.15, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "Juggernaut" = 1, "HellRisen" = 0.25)
					strength = 1.3
					speed = 1.3
					offense = 1.3
					defense = 1.3
					force = 1.3
					endurance = 1.3
				if(mastery >= 50)
					passives = list("GodKi" = 0.35, "AngerAdaptiveForce" = 0.5,"TechniqueMastery" = 4, "FluidForm" = 1, "Juggernaut" = 1.5, "HellRisen" = 0.5)
					strength = 1.4
					speed = 1.4
					offense = 1.4
					defense = 1.4
					force = 1.4
					endurance = 1.4
				if(mastery >= 75)
					passives = list("GodKi" = 0.5, "AngerAdaptiveForce" = 0.75,"TechniqueMastery" = 6, "FluidForm" = 1.5, "Juggernaut" = 2,"HellRisen" = 0.75)
					strength = 1.5
					speed = 1.5
					offense = 1.5
					defense = 1.5
					force = 1.5
					endurance = 1.5
				if(mastery >= 100)
					passives = list("GodKi" = 1, "AngerAdaptiveForce" = 1,"TechniqueMastery" = 8, "FluidForm" = 2, "Juggernaut" = 3,"HellRisen" = 1)
					strength = 1.6
					speed = 1.6
					offense = 1.6
					defense = 1.6
					force = 1.6
					endurance = 1.6
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveBloodlust.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2
		satan_mode
			passives = list("GodKi" = 1, "HolyMod" = 10, "AbyssMod" = 10, "SpiritPower" = 2, "PhysPleroma" = 3, "Purity" = 1, "BeyondPurity" = 1)
			autoAnger = 1
			unlock_potential = 90
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			strength = 2
			speed = 2
			offense = 2
			defense = 2
			force = 2
			endurance = 2
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
				for(var/mob/M in view(user))
					if(M.client)
						ScreenShatter(M)
					if(user.client)
						ScreenShatter(user)
