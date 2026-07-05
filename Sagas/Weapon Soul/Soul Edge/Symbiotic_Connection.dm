obj/Skills/Buffs/SlotlessBuffs/Symbiotic_Edge
	passives = list("Unstoppable" = 1, "PureDamage" = 3, "Instinct" = 4, "Curse" = 1, "UnderDog" = 2)
	WoundCost = 10
	TimerLimit = 60
	Cooldown = 160
	ActiveMessage = "is overtaken by the power of Soul Edge as flesh wriggles across their sword arm!"
	OffMessage = "is released from the whims of Soul Edge..."

	adjust(mob/p)
		TimerLimit = 60 + (p.SagaLevel * 5)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: Chaos Armament")
			passives = list("Unstoppable" = 1, "PureDamage" = 5, "Instinct" = 8, "Curse" = 1, "UnderDog" = 6, "HardStyle" = 3, "Brutalize" = 2, "EnhancedSmell" = 1, "EnhancedHearing" = 1)
		else
			passives = list("Unstoppable" = 1, "PureDamage" = 3, "Instinct" = 4, "Curse" = 1, "UnderDog" = 2)

	verb/Symbiotic_Edge()
		set category = "Skills"
		adjust(usr)
		Trigger(usr)
