/obj/Skills/Buffs/NuStyle/MysticStyle

	Magma_Walker
		SignatureTechnique = 1
		passives = list("SpiritFlow" = 2, "Familiar" = 1, "Burning" = 2.5, "Shattering" = 2.5, \
						"Combustion" = 30, "Hardening" = 1)
		StyleActive = "Magma"
		StyleFor = 1.2
		StyleEnd = 1.2
		Finisher = "/obj/Skills/Queue/Finisher/Major_Eruption"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Earth"
		IconLock = 'SpriteG.dmi'
		AuraLock = 'Terra Might.dmi'
		LockX=-16
		LockY=16
		AuraX=-8
		AuraY=-10
		BuffTechniques = list("/obj/Skills/Buffs/SlotlessBuffs/Magmic_Shield") 
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Plasma_Style",\
								"/obj/Skills/Buffs/NuStyle/MysticStyle/Inferno"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Hellfire", \
								"/obj/Skills/Buffs/NutStyle/UnarmedStyle/_Any" = /obj/Skills/Buffs/NuStyle/UnarmedStyle/Ifrit_Jambe)
		ElementalOffense = "Fire"
		ElementalDefense = "Earth"
		ElementalClass = "Fire"
		verb/Magma_Walker()
			set hidden=1
			src.Trigger(usr)
	Ice_Dancing
		SignatureTechnique = 1
		passives = list("SpiritFlow" = 2, "Familiar" = 1, "IceAge" = 50, "Chilling" = 4, "Shattering" = 1, \
						"Harden" = 1, "WaveDancer" = 1.5)
		StyleActive = "Ice"
		StyleOff = 1.15
		StyleEnd = 1.15
		StyleFor = 1.15
		Finisher = "/obj/Skills/Queue/Finisher/Ice_Time"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Water"
		IconLock = 'SpriteC.dmi'
		AuraLock = 'Terra Might.dmi'
		LockX=-16
		LockY=16
		AuraX=-8
		AuraY=-10
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/MysticStyle/Stormbringer"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Blizzard_Bringer",\
								"/obj/Skills/Buffs/NuStyle/MysticStyle/Inferno" = "/obj/Skills/Buffs/NuStyle/MysticStyle/Hot_n_Cold")
		ElementalOffense = "Water"
		ElementalDefense = "Earth"
		ElementalClass = "Water"
		verb/Ice_Dancing()
			set hidden=1
			src.Trigger(usr)
	Stormbringer
		SignatureTechnique = 1
		passives = list("SpiritFlow" = 2, "Familiar" = 1, "ThunderHerald" = 1, "CriticalChance" = 15, "CriticalDamage" = 0.1, \
						"Rain" = 5, "Godspeed" = 1, "AirBend"= 1.5, "WaveDancer" = 1)
		StyleActive = "Storm"
		StyleSpd = 1.15
		StyleOff = 1.15
		StyleFor = 1.15
		Finisher = "/obj/Skills/Queue/Finisher/Stormweaver"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Wind"
		IconLock = 'SpriteY.dmi'
		AuraLock = 'Terra Might.dmi'
		LockX=-16
		LockY=16
		AuraX=-8
		AuraY=-10
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker" = "/obj/Skills/Buffs/NuStyle/MysticStyle/Plasma_Style",\
								"/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing" = "/obj/Skills/Buffs/NuStyle/MysticStyle/Blizzard_Bringer", \
								/obj/Skills/Buffs/NuStyle/SwordStyle/Iaido_Style = /obj/Skills/Buffs/NuStyle/SwordStyle/Art_of_Order)
		ElementalOffense = "Wind"
		ElementalDefense = "Water"
		ElementalClass = "Wind"
		verb/Stormbringer()
			set hidden=1
			src.Trigger(usr)
	Inferno
		SignatureTechnique = 1
		passives = list("SpiritFlow" = 2, "Familiar" = 1, "Combustion" = 45, "Heavy Strike" = "Inferno",\
						 "Shocking" = 2, "Burning" = 3)
		StyleActive = "Inferno"
		StyleFor = 1.3
		StyleSpd = 1.15
		Finisher="/obj/Skills/Queue/Finisher/Sunshine_Flame"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Fire"
		IconLock = 'SpriteR.dmi'
		AuraLock = 'Terra Might.dmi'
		LockX=-16
		LockY=16
		AuraX=-8
		AuraY=-10
		StyleComboUnlock = list("/obj/Skills/Buffs/NuStyle/MysticStyle/Magma_Walker"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Hellfire",\
								"/obj/Skills/Buffs/NuStyle/MysticStyle/Ice_Dancing"= "/obj/Skills/Buffs/NuStyle/MysticStyle/Hot_n_Cold")
		ElementalOffense = "Wind"
		ElementalDefense = "Fire"
		ElementalClass = "Fire"
		verb/Inferno()
			set hidden=1
			src.Trigger(usr)
	Bloodmancer
		SignatureTechnique = 1
		passives = list("Familiar" = 1, "SpiritFlow" = 2, "Poisoning" = 3, "BlindingVenom" = 1.5, "Rusting" = 2, \
					"BloodEruption" = 1, "LingeringPoison" = 1)
		StyleActive = "Bloodmancer"
		StyleFor = 1.3
		StyleOff = 1.15
		ElementalOffense="Poison"
		ElementalDefense="Water"
		ElementalClass = "Poison"
		Finisher="/obj/Skills/Queue/Finisher/Bloodcurdle"
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura/Poison"
		StyleComboUnlock =  list("/obj/Skills/Buffs/NuStyle/SwordStyle/_Any" = /obj/Skills/Buffs/NuStyle/SwordStyle/Bloodseeker)
		IconLock = 'SpriteR.dmi'
		AuraLock = 'Terra Might.dmi'
		LockX=-16
		LockY=16
		AuraX=-8
		AuraY=-10
		verb/Bloodmancer()
			set hidden=1
			src.Trigger(usr)