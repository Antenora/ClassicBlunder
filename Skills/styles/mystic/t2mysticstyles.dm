/obj/Skills/Buffs/NuStyle/MysticStyle
	Hellfire
		passives = list("SpiritFlow" = 3, "Familiar" = 2, "Combustion" = 60, "Heavy Strike" = "Inferno",\
						"Scorching" = 4)
		ElementalOffense = "HellFire"
		ElementalDefense = "Fire"
		ElementalClass = "Fire"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Fire"
		StyleFor = 1.6
		Finisher="/obj/Skills/Queue/Finisher/Deal_with_the_Devil"
		var/obj/Skills/demonSkill = FALSE
		Trigger(mob/User, Override)
			if(!demonSkill)
				var/inp = input(User, "What demon skill do you want?") in list("/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm", "/obj/Skills/Projectile/Magic/HellFire/Hellpyre", "/obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat")
				BuffTechniques = list(inp)
				demonSkill = inp
			sleep(2)
			..()
		StyleActive = "Hellfire"
		SignatureTechnique = 2
		verb/Hellfire()
			set hidden=1
			src.Trigger(usr)
	Plasma_Style
		ElementalOffense = "Wind"
		ElementalDefense = "Fire"
		ElementalClass = list("Fire","Wind")
		StyleFor = 1.3
		StyleSpd = 1.3
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Earth"
		passives = list("SuperCharge" = 1,"Familiar" = 2, "SpiritFlow" = 3, "ThunderHerald" = 1, "CriticalChance" = 20, "CriticalDamage" = 0.1, \
						"Godspeed" = 2, "AirBend" = 1.5, "Hardening" = 2, "Burning" = 2, "Shattering" = 5, "Shocking" = 2, "Chilling" = 2)
		Finisher="/obj/Skills/Queue/Finisher/Mega_Arm" // Super_mega_buster
		StyleActive = "Plasma"
		SignatureTechnique = 2
		verb/Plasma_Style()
			set hidden=1
			src.Trigger(usr)
	Blizzard_Bringer
		ElementalOffense = "Water"
		ElementalDefense = "Wind"
		ElementalClass = list("Wind","Water")
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Water"
		passives = list("IceHerald" = 1,"IceAge" = 40, "Familiar" = 2, "ThunderHerald" = 1, "CriticalChance" = 25, "CriticalDamage" = 0.2,\
						"SpiritFlow" = 3, "Hardening" = 2,"Freezing" = 8, "Rain" = 8, "AirBend" = 2, "WaveDancer" = 1.5, "Godspeed" = 2)
		Finisher="/obj/Skills/Queue/Finisher/Frostfist"
		StyleActive = "Blizzard"
		StyleOff=1.15
		StyleSpd=1.15
		StyleFor=1.3
		SignatureTechnique = 2
		verb/Blizzard_Bringer()
			set hidden=1
			src.Trigger(usr)
	Hot_n_Cold
		var/hotCold = 0 // -100 is 100% cold, 100 is 100% hot
		StyleActive = "Hot Style"
		ElementalOffense = "Fire"
		ElementalDefense = "Water"
		ElementalClass = list("Fire")
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Fire"
		passives = list("HeatingUp" = 1,"Familiar" = 2, "Amplify" = 2, "Heavy Strike" = "Inferno", "Scorching" = 10, "Combustion" = 60, "SpiritFlow" = 3, "SpiritHand" = 1)
		StyleFor = 1.45
		StyleOff = 1.15
		StyleActive = "Hot Style"
		SignatureTechnique = 2
		verb/Hot_n_Cold()
			set hidden=1
			src.Trigger(usr)
		proc/swap_stance()
			if(StyleActive == "Hot Style")
				StyleActive = "Cold Style"
				StyleEnd = 1.45
				StyleFor = 1.15
				ElementalOffense = "Water"
				ElementalDefense = "Fire"
				ElementalClass = "Water"
				BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Water"
				passives = list("CoolingDown" = 1,"Familiar" = 2, "Amplify" = 2, "Hardening" = 3, "Freezing" = 10, "IceAge" = 50, "SpiritFlow" = 3, "WaveDancer" = 2)

				Finisher="/obj/Skills/Queue/Finisher/Phosphor" 
			else
				StyleActive = "Hot Style"
				ElementalOffense = "Fire"
				ElementalDefense = "Water"
				ElementalClass = "Fire"
				StyleFor = 1.45
				StyleOff = 1.15
				BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Fire"
				passives = list("HeatingUp" = 1,"Familiar" = 2, "Amplify" = 2, "Heavy Strike" = "Inferno", "Scorching" = 10, "Combustion" = 50, "SpiritFlow" = 3, "SpiritHand" = 1)

				Finisher="/obj/Skills/Queue/Finisher/Jet_Kindling" 
		verb/Swap_Stance()
			set category="Skills"
			if(usr.BuffOn(src))
				turnOff(usr)
			swap_stance()
			Trigger(usr, 1)
			giveBackTension(usr)
