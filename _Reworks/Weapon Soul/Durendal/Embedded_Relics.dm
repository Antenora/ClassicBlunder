obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics
	NeedsSword = 1

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Tooth
	CantHaveTheseBuffs = list("Saints Blood", "Saints Hair", "Saints Raiment")
	HealthDrain = 0.05
	HealthThreshold = 1
	ManaGlow = "#dadada"
	ManaGlowSize = 1
	TimerLimit = 30
	Cooldown = 90
	passives = list("PureDamage" = 4, "HolyMod" = 3)
	ActiveMessage = "'s legendary weapon edges itself with the Teeth of a Saint!"
	OffMessage = "'s legendary weapon no longer edges itself with teeth..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			HealthDrain = 0.025
			Cooldown = 1
			TimerLimit = null
		else
			HealthDrain = 0.05
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Tooth()
		set name = "Durendal: Saint's Tooth"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Blood
	EnergyDrain = 0.05
	EnergyThreshold = 10
	ManaGlow = "#cb2323"
	ManaGlowSize = 1
	TimerLimit = 30
	Cooldown = 90
	CantHaveTheseBuffs = list("Saints Tooth", "Saints Hair", "Saints Raiment")
	passives = list("LifeSteal" = 10, "LifeGeneration" = 5)
	ActiveMessage = "'s legendary weapon drips with the Blood of a Saint."
	OffMessage = "'s legendary weapon no longer drips with holy blood..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			EnergyDrain = 0.025
			Cooldown = 1
			TimerLimit = null
		else
			EnergyDrain = 0.05
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Blood()
		set name = "Durendal: Saint's Blood"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Hair
	CantHaveTheseBuffs = list("Saints Blood", "Saints Tooth", "Saints Raiment")
	ManaDrain = 0.05
	ManaThreshold = 1
	ManaGlow = "#486edf"
	ManaGlowSize = 1
	TimerLimit = 30
	Cooldown = 90
	passives = list("EnergySteal" = 2, "SoftStyle" = 3, "HolyMod" = 2)
	ActiveMessage = "'s legendary weapon hardens with the Hair of a Saint."
	OffMessage = "'s legendary weapon no longer steels itself with holy fibers..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			ManaDrain = 0.025
			Cooldown = 1
			TimerLimit = null
		else
			ManaDrain = 0.05
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Hair()
		set name = "Durendal: Saint's Hair"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Buffs/SlotlessBuffs/Durendal_Relics/Saints_Raiment
	TimerLimit = 30
	Cooldown = 90
	ManaGlow = "#48df66"
	ManaGlowSize = 1
	CantHaveTheseBuffs = list("Saints Tooth", "Saints Blood", "Saints Hair")
	passives = list("PureReduction" = 4, "PureDamage" = -2, "DebuffResistance" = 0.5)
	ActiveMessage = "'s legendary weapon coils up their arm with the Raiment of a Saint."
	OffMessage = "'s legendary weapon releases their wielder's arm..."
	adjust(mob/p)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: The Saint")
			Cooldown = 1
			TimerLimit = null
		else
			TimerLimit = 30
			Cooldown = 90
	verb/Saints_Raiment()
		set name = "Durendal: Saint's Raiment"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)