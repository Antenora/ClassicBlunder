obj/Skills/Buffs/SlotlessBuffs/Blessed_Guard
	passives = list("PureDamage"=-2)
	VaizardHealth = 10
	VaizardShatter = 1
	TimerLimit = 30
	Cooldown = 160
	CooldownStatic = 1
	adjust(mob/p)
		TimerLimit = 20 + (p.SagaLevel * 5)
		if(p.SpecialBuff&&p.SpecialBuff.name == "Heavenly Regalia: Blessed Blade")
			passives = list("PureDamage"=-2, "SoulFire" = 5 + p.SagaLevel, "DebuffResistance" = 2)
		else
			passives = list("PureDamage"=-2)
	verb/Blessed_Guard()
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)