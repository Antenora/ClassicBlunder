/obj/Skills/Queue/Infestation
	DamageMult = 1.5
	AccuracyMult = 5
	Cooldown = 80
	adjust(mob/p)
		// make it scale per ascen, alter how it works between warrior / dragon
		DamageMult = 3 + (p.AscensionsAcquired)
		Cooldown = clamp(120 - (80 * p.AscensionsAcquired), 30, 80)
		switch(p.Class)
			if("Dragon")
				ManaGain = 5 + (p.AscensionsAcquired * 3)
				Paralyzing = 10 * p.AscensionsAcquired
				SpiritHand = 1 * p.AscensionsAcquired
			if("Warrior")
				Crippling = 2.5 * p.AscensionsAcquired
				Toxic = 5 * p.AscensionsAcquired
				Combo = 2 * p.AscensionsAcquired
				DamageMult = (1.5 + (p.AscensionsAcquired)) / Combo

			if("Demon")
				PridefulRage = 1
				Burning = 5 * p.AscensionsAcquired
				Toxic = 5 * p.AscensionsAcquired


	verb/Infestation()
		set category="Skills"
		adjust(usr)
		usr.SetQueue(src)

mob
	proc
		inParty(keyLooking)
			if(isRace(CHANGELING) && Anger) return null
			if(party)
				for(var/mob/Players/p in party.members)
					if(p.ckey == keyLooking)
						return p
			return null

proc
	findPlayer(keyLooking)
		for(var/mob/Players/p in players)
			if(p.ckey == keyLooking)
				return p
//TODO: add inParty & findPlayer
