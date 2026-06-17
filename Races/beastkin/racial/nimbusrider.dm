/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin
	Nimbus_Rider
		BuffName="Nimbus Rider"
		IconLock='Flying Nimbus.dmi'
		LockY=-10
		UnrestrictedBuff=1
		Steady=1
		passives = list("BlurringStrikes" = 1, "Steady" = 1, "Brutalize" = 0.5)
		TimerLimit=5
		Cooldown=10
		adjust(mob/p)
			if(altered) return
			Steady=p.AscensionsAcquired
			TimerLimit=1+(3*p.AscensionsAcquired)
			passives = list("BlurringStrikes" = p.passive_handler["Nimbus"], "Steady" = p.passive_handler["Nimbus"], "Brutalize" = (p.passive_handler["Nimbus"]/2))