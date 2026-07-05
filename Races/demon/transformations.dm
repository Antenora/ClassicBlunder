transformation
	demon
		devil_trigger
			passives = list("HellRisen" = 0.25, "DemonicDurability" = 2, "PureDamage" = 1, "PureReduction" = 1, "Brutalize" = 2)
			autoAnger = 1
			unlock_potential = 80
			form_aura_icon = 'Amazing Super Demon Aura.dmi'
			form_aura_x = -32
			strength = 1
			speed = 1
			offense = 1
			defense = 1
			force = 1
			endurance = 1
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
				strength = 1
				speed = 1
				offense = 1
				defense = 1
				force = 1
				endurance = 1
				enduranceadd = 0.5
				offenseadd = 0.5
				defenseadd = 0.5
				strengthadd = 0.5
				forceadd = 0.5
				speedadd = 0.5
				if(user.Potential>=40&&mastery<25)
					mastery=25
				if(user.Potential>=55&&mastery<50)
					mastery=50
				if(user.Potential>=70&&mastery<75)
					mastery=75
				if(user.Potential>=85&&mastery<100)
					mastery=100
				if(mastery >= 25)
					passives = list("HellRisen" = 0.5, "DemonicDurability" = 2, "Brutalize" = 2, "PureDamage" = 3, "PureReduction" = 3)
					enduranceadd = 0.5
					offenseadd = 0.5
					defenseadd = 0.5
					strengthadd = 0.5
					forceadd = 0.5
					speedadd = 0.5
				if(mastery >= 50)
					passives = list("HellRisen" = 0.75, "DemonicDurability" = 3, "Brutalize" = 2, "PureDamage" = 6, "PureReduction" = 6, "MovementMastery" = 6)
					enduranceadd = 0.75
					offenseadd = 0.75
					defenseadd = 0.75
					strengthadd = 0.75
					forceadd = 0.75
					speedadd = 0.75
				if(mastery >= 75)
					passives = list("GodKi" = 0.5, "HellRisen" = 0.75, "DemonicDurability" = 4, "Brutalize" = 2, "PureDamage" = 6, "PureReduction" = 6, "MovementMastery" = 6, "TechniqueMastery" = 3, "Steady" = 3)
					enduranceadd = 1
					offenseadd = 1
					defenseadd = 1
					strengthadd = 1
					forceadd = 1
					speedadd = 1
				if(mastery >= 100)
					passives = list("GodKi" = 0.75, "HellRisen" = 1, "DemonicDurability" = 6, "Brutalize" = 6, "PureDamage" = 6, "PureReduction" = 6, "MovementMastery" = 6, "TechniqueMastery" = 6, "Steady" = 6, "ManaStats" = 6)
					enduranceadd = 2
					offenseadd = 2
					defenseadd = 2
					strengthadd = 2
					forceadd = 2
					speedadd = 2
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

