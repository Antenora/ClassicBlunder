obj/Items/Armor/Plated_Armor/Noble_Armor
	Ascended = 2
	Element = "Ultima"
	Destructable = 0
	Unobtainable = 1
	Cost = 0
	TechType=null
	SubType=null

obj/Skills/Buffs/SlotlessBuffs/Noble_Shield
	passives = list("Deflection" = 3, "VoidField" = 3, "DeathField" = 3)
	VaizardHealth = 5
	VaizardShatter = 1
	TimerLimit = 30 
	Cooldown = 90
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The King")
			passives = list("Deflection" = 3, "VoidField" = 10, "DeathField" = 10)
			VaizardHealth = 10
			VaizardShatter = 1
			TimerLimit = 30
			Cooldown = 90
		else
			passives = list("Deflection" = 3, "VoidField" = 3, "DeathField" = 3)
			VaizardHealth = 5
			VaizardShatter = 1
			TimerLimit = 30
			Cooldown = 90
	verb/Noble_Shield()
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)