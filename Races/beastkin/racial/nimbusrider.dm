/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin
	Nimbus_Rider
		BuffName="Nimbus Rider"
		IconLock='Flying Nimbus.dmi'
		LockY=-10
		UnrestrictedBuff=1
		Steady=1
		TimerLimit=5
		Cooldown=10
		adjust(mob/p)
			if(altered) return
			Steady=p.AscensionsAcquired
			TimerLimit=1+(3*p.AscensionsAcquired)
