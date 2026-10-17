/obj/Skills/Buffs/SlotlessBuffs/Racial/Nobody_Legendary
	CyberSignature = 1
	Copyable = 0
	NeedsSword = 1
	ElementalOffense = "Fire"
	ElementalDefense = "Fire"
	ExclusiveFamily = /obj/Skills/Buffs/SlotlessBuffs/Racial/Nobody_Legendary
	Legacy_of_Ashes
		BuffName = "Legacy of Ashes"
		passives = list("Godspeed" = 1, "Momentum" = 1, "Kindling" = 0.5, "Combustion" = 30, "Ashen One" = 1)
		verb/Legacy_of_Ashes()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Sunslammer
		BuffName = "Legacy of the Sunslammer"
		passives = list("Godspeed" = 2, "Momentum" = 1, "Kindling" = 0.5, "Combustion" = 30, "Ashen One" = 1)
		verb/Sunslammer()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Heir_of_Grief
		BuffName = "Heir of Grief"
		passives = list("Godspeed" = 2, "Momentum" = 1, "Kindling" = 0.5, "Combustion" = 30, "Ashen One" = 1)
		verb/Heir_of_Grief()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Overture
		BuffName = "Overture"
		passives = list("Godspeed" = 3, "Momentum" = 2, "Kindling" = 1.5, "Combustion" = 30, "Ashen One" = 1)
		verb/Overture()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
