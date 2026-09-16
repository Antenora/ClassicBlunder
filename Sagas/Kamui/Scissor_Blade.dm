obj
	Items
		Sword
			Medium
				Scissor_Blade
					name="Scissor Blade"
					icon='scissorcasetilted.dmi'
					UnderlayIcon = 'scissorcasetilted_under.dmi'
					passives = list("Shearing" = 1)
					ShatterTier=0
					Destructable=0
					iconAlt='Scissor_blade_decap.dmi'
					iconAltX=-32
					iconAltY=-32
					ClassAlt="Heavy"
					Cost = 0
					LegendaryItem = 1
					Ascended= 3
					Saga = "Kamui"
					TierTechniques=list(null, list("/obj/Skills/Buffs/SlotlessBuffs/WeaponSystems/Decapitation_Mode", "/obj/Skills/Queue/Sen_I_Soshitsu", "/obj/Skills/AutoHit/Life_Fiber_Weave"), null, null, null, null)
					icon = 'scissor_blade.dmi'
					pixel_x = -16
					pixel_y = -16

					verb/Set_Sword_Class()
						if(usr.Saga == "Kamui" && usr.SagaLevel < 3)
							usr << "You don't know how to use this aspect of your scissor blade yet!"
							return
						if(usr.Saga != "Kamui")
							usr << "You don't know how to modify the scissor blade!"
							return
						Class = Ask(usr, "What class would you like to set the Scissor Blade to?", "", null, "pick", list("Light", "Medium", "Heavy"), 0)
						setStatLine()

					verb/Set_Alternate_Sword_Class()
						if(usr.Saga == "Kamui" && usr.SagaLevel < 3)
							usr << "You don't know how to use this aspect of your scissor blade yet!"
							return
						if(usr.Saga != "Kamui" || !usr.Saga)
							usr << "You don't know how to modify the scissor blade!"
							return
						ClassAlt = Ask(usr, "What class would you like to set the Scissor Blade to?", "", null, "pick", list("Light", "Medium", "Heavy"), 0)

					verb/Restyle_Scissor_Blade_Case()
						var/caseType = Ask(usr, "What type of Case would you like?", "", null, "pick", list("Slanted", "Straight"), 0)
						if(caseType == "Slanted")
							UnderlayIcon = 'scissorcasetilted_under.dmi'
							icon = 'scissorcasetilted.dmi'
						else if(caseType == "Straight")
							UnderlayIcon = 'scissorcase_under.dmi'
							icon = 'scissorcase.dmi'