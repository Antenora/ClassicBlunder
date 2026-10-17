/obj/Skills/Buffs/SlotlessBuffs/Autonomous/SlotlessUI/Mortal
	Copyable = 0
	NeedsSword = 0
	NoSword = 1
	IconLock = 'AuraMysticBig.dmi'
	AuraArt = 1
	IconLockBlend = 4
	LockX = -32
	LockY = -32
	ExclusiveFamily = /obj/Skills/Buffs/SlotlessBuffs/Autonomous/SlotlessUI/Mortal
	passives = list()
	proc/StagePassives(mob/p)
		return list()
	proc/HybridPassives(mob/p)
		var/asc = p.AscensionsAcquired
		var/divine = p.isRace(ANGEL) || p.isRace(MAKAIOSHIN)
		switch(p.HybridChoice)
			if("Sword")
				if(asc < 2 || (asc == 2 && p.isRace(ANGEL)) || (asc >= 3 && divine))
					return list("Momentum" = 1, "PUSpike" = 10)
			if("Grappling")
				if(asc >= 3)
					return list("Momentum" = divine ? 2 : 2.5, "UnarmedDamage" = 2)
				if(asc == 2)
					return list("Momentum" = 1.5)
				return list("Momentum" = 1)
			if("Mystic")
				return list("Amplify" = 1, "WaveDancer" = 1, "Burning" = 1, "Freezing" = 1, "Shocking" = 1, "Shattering" = 1, "PUSpike" = 15)
			if("Martial")
				if(asc >= 3)
					return list("Momentum" = 2, "UnarmedDamage" = 2)
				if(asc == 2 && !p.isRace(ANGEL))
					return list("Momentum" = 1)
				return list("Momentum" = 1.5, "UnarmedDamage" = 1)
		return list()
	adjust(mob/p)
		passives = StagePassives(p)
		var/list/H = HybridPassives(p)
		for(var/k in H)
			if(!(k in passives))
				passives[k] = H[k]

	Mortal_Instinct
		BuffName = "Mortal Instinct (Incomplete)"
		StagePassives(mob/p)
			return list("UnarmedDamage" = 2)
		verb/Mortal_Instinct()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)

	Incomplete_Mortal_Ultra_Instinct
		BuffName = "Mortal Ultra Instinct (In-Training)"
		StagePassives(mob/p)
			return list("UnarmedDamage" = 3)
		verb/Incomplete_Mortal_Ultra_Instinct()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)

	Mortal_Ultra_Instinct
		BuffName = "Mortal Ultra Instinct"
		IconLock = 'GentleDivine.dmi'
		StagePassives(mob/p)
			if(p.isRace(CELESTIAL))
				return list("UnarmedDamage" = 4)
			return list("Godspeed" = 1, "UnarmedDamage" = 4)
		verb/Mortal_Ultra_Instinct()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)

	Perfected_Mortal_Ultra_Instinct
		BuffName = "Perfected Ultra Instinct"
		IconLock = 'GentleDivine.dmi'
		PUSpike = 25
		StagePassives(mob/p)
			if(p.isRace(CELESTIAL))
				return list("UnarmedDamage" = 5)
			return list("Godspeed" = 1, "PUSpike" = 25, "UnarmedDamage" = 5)
		verb/Perfected_Mortal_Ultra_Instinct()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
