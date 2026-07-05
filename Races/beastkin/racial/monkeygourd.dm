/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin
	Monkey_Gourd
		BuffName="Monkey Gourd"
		UnrestrictedBuff=1
		Cooldown=1
		CooldownStatic=1
		TimerLimit=1
		ActiveMessage = "takes a sip from their trusty gourd."
		HealthHeal = 9 //for some reason 3 healed only 1%???
		StableHeal = 1 // don't take recov into account
		EnergyHeal = 25
		var/monkeyUsed = 0
		var/monkeyUsageMax = 1
		adjust(mob/p)
			monkeyUsageMax = p.AscensionsAcquired
		verb/Monkey_Gourd()
			set category="Skills"
			adjust(usr)
			if(!usr.CheckSlotless("Monkey Gourd"))
				if(monkeyUsed < monkeyUsageMax)
					src.Trigger(usr)
					monkeyUsed++
				else
					usr << "Your gourd is empty."