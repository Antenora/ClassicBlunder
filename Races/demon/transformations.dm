transformation
	demon
		devil_trigger
			passives = list("HellRisen" = 0.25, "DemonicDurability" = 2, "PureDamage" = 1, "PureReduction" = 1, "Brutalize" = 2)
			autoAnger = 1
			unlock_potential = 80
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			strength = 1.1
			speed = 1.2
			offense = 1.2
			defense = 1.2
			force = 1.1
			endurance = 1.2
			transformation_message = "usrName pulls their Devil Trigger."
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
					var/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Disguise/D = locate() in user
					if(D && user.BuffOn(D))
						D.Trigger(user, TRUE)
						user << "<i>Your Devil Trigger shatters your disguise.</i>"
					var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da
					for(var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/candidate in user)
						if(user.BuffOn(candidate))
							da = candidate
							break
					if(!da)
						da = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
					if(da)
						da.applyDTIcons(user)

			mastery_boons(mob/user)
				if(mastery >= 25)
					passives = list("GodKi" = 0.15, "HellRisen" = 0.5, "DemonicDurability" = 4, "Brutalize" = 1, "PureDamage" = 3, "PureReduction" = 3)
					strength = 1.15
					speed = 1.25
					offense = 1.25
					defense = 1.25
					force = 1.15
					endurance = 1.25
				if(mastery >= 50)
					passives = list("GodKi" = 0.35, "HellRisen" = 0.75, "DemonicDurability" = 6, "Brutalize" = 2, "PureDamage" = 4, "PureReduction" = 4, "MovementMastery" = 3, "BuffMastery"=3)
					strength = 1.2
					speed = 1.3
					offense = 1.3
					defense = 1.3
					force = 1.2
					endurance = 1.3
				if(mastery >= 75)
					passives = list("GodKi" = 0.5, "HellRisen" = 0.75, "DemonicDurability" = 6, "Brutalize" = 4, "PureDamage" = 6, "PureReduction" = 6, "MovementMastery" = 6, "TechniqueMastery" = 3, "Steady" = 3, "BuffMastery"=6)
					strength = 1.25
					speed = 1.35
					offense = 1.35
					defense = 1.35
					force = 1.25
					endurance = 1.35
				if(mastery >= 100)
					passives = list("GodKi" = 1, "HellRisen" = 1, "DemonicDurability" = 6, "Brutalize" = 6, "PureDamage" = 6, "PureReduction" = 6, "MovementMastery" = 6, "TechniqueMastery" = 6, "Steady" = 6, "ManaStats" = 6, "BuffMastery"=6)
					strength = 1.3
					speed = 1.4
					offense = 1.4
					defense = 1.4
					force = 1.3
					endurance = 1.4
			transform_animation(mob/user)
				var/ShockSize=5
				for(var/wav=5, wav>0, wav--)
					KenShockwave(user, icon='KenShockwaveBloodlust.dmi', Size=ShockSize, Blend=2, Time=8)
					ShockSize/=2

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
				if(!user || user.isInDemonDevilTrigger()) return
				user.resetDevilTriggerSinBonuses()

