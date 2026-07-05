/mob/proc/checkOtherAngelMacros(obj/Skills/Buffs/SlotlessBuffs/AngelMagic/org)
	for(var/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/am in src)
		if(am == org) continue
		if(am.keyMacro != null)
			if(am.keyMacro == org.keyMacro)
				return am
	return TRUE

/mob/proc/isAngelMagicCasting(checkType = null)
	if(!client?.keyQueue) return FALSE
	if(!client.keyQueue.TRIGGERED) return FALSE
	if(checkType)
		return client.keyQueue.initType == checkType
	return TRUE

/mob/proc/endAngelMagicCast()
	if(!client?.keyQueue) return
	client.keyQueue.clearInfo()

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic
	var/keyMacro = null
	var/KEYWORD = "error"
	possible_skills = list()
	TimerLimit = 1
	Cooldown = 120

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/proc/resetToInital()

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/proc/EditAll(mob/p)
	if(!possible_skills) return
	if(p.Admin)
		for(var/i in possible_skills)
			if(!possible_skills[i])
				p << "possible skill lacking somewhere, setting to inital and breaking"
				possible_skills[i]?:resetToInital()
			p?:Edit(possible_skills[i])

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Cooldown(modify, Time, mob/p, t)
	for(var/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/am in p)
		if("[am.type]" == "[t]")
			for(var/x in am.possible_skills)
				if(am.possible_skills[x])
					if(am.possible_skills[x].cooldown_remaining)
						continue
					am.possible_skills[x].Using = 0
					am.possible_skills[x].Cooldown(modify, Time, p)
					p << "[am.possible_skills[x]] has been put on cooldown."

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/proc/setUpMacro(mob/p)
	keyMacro = null
	p << "The next button you press will be the macro for this. There will be an alert, give it a second."
	p.client.trackingMacro = src

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/proc/fakeTrigger(mob/p)
	if(p.client.keyQueue.TRIGGERED && p.client.keyQueue.LAST_CAST + 300 < world.time)
		p.client.keyQueue.TRIGGERED = null
		p << "Far too late."
		p.client.keyQueue.LAST_CAST = world.time
		return
	Trigger(p, 0)

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Trigger(mob/User, Override = 0)
	var/datum/queueTracker/keyQ = User.client.keyQueue
	if(isnull(keyQ.TRIGGERED))
		if(keyQ.LAST_CAST + 15 < world.time)
			keyQ.trigger(type)
			User << "You have started to cast [src]."
			User.castAnimation()
			Cooldown = 0
			keyQ.LAST_CAST = world.time
	else
		var/initType = keyQ.initType
		var/result = keyQ.detectInput(10)
		var/perfect = FALSE
		if(result == 2)
			perfect = TRUE
			result = 1
		switch(result)
			if(1)
				// Cross-combo: DemonMagic was pressed first, AngelMagic pressed second
				if(findtext("[initType]", "/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/"))
					if(User.passive_handler.Get("ChaosRuler"))
						var/list/initParts = splittext("[initType]", "/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/")
						var/list/curParts = splittext("[type]", "/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/")
						var/initName = initParts.len >= 2 ? initParts[2] : ""
						var/curName = curParts.len >= 2 ? curParts[2] : ""
						if(initName == "DarkMagic" && curName == "Light")
							var/obj/Skills/AutoHit/Chaos_Degrade/cd = locate(/obj/Skills/AutoHit/Chaos_Degrade) in User
							if(cd)
								User.Activate(cd)
								spawn(2)
									if(User.isRace(MAKAIOSHIN) && User.passive_handler && User.passive_handler.Get("Limited Rank-Up"))
										// Rank-Up
										return
									User.cooldownAllChaosSkills()
							else
								User << "You lack the knowledge to complete this technique."
					if(perfect)
						User.Quake(5, 0)
					keyQ.TRIGGERED = null
					return
				User << "You have used your [KEYWORD] spell."
				var/trueType = splittext("[initType]", "/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/")
				var/obj/Skills/theSkill = possible_skills[trueType[2]]
				if(possible_skills[trueType[2]].cooldown_remaining > 0)
					User << "This is on cooldown"
					return
				var/triggered = theSkill?:Trigger(User, 0)
				if(triggered)
					Cooldown(1, null, User, type)
				if(perfect)
					User.Quake(5, 0)
				keyQ.TRIGGERED = null
			if(0)
				User << "Too Soon..."
			if(-1)
				User << "You took too long."
				keyQ.TRIGGERED = null

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Light
	name = "Light"
	KEYWORD = "damage"
	verb/Light()
		set category = "Skills"
		fakeTrigger(usr)
	possible_skills = list("Light" = new/obj/Skills/Projectile/Magic/AngelMagic/Radiant_Lance, "Divinity" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Revelation, "Order" = new/obj/Skills/AutoHit/Magic/AngelMagic/Dazzle)
	New()
		..()
		resetToInital()
	resetToInital()
		possible_skills = list("Light" = new/obj/Skills/Projectile/Magic/AngelMagic/Radiant_Lance, "Divinity" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Revelation, "Order" = new/obj/Skills/AutoHit/Magic/AngelMagic/Dazzle)

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Divinity
	name = "Divinity"
	KEYWORD = "utility"
	verb/Divinity()
		set category = "Skills"
		fakeTrigger(usr)
	possible_skills = list("Light" = new/obj/Skills/AutoHit/Magic/AngelMagic/Consecration, "Divinity" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Zeal, "Order" = new/obj/Skills/AutoHit/Magic/AngelMagic/Chains_of_Purity)
	New()
		..()
		resetToInital()
	resetToInital()
		possible_skills = list("Light" = new/obj/Skills/AutoHit/Magic/AngelMagic/Consecration, "Divinity" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Zeal, "Order" = new/obj/Skills/AutoHit/Magic/AngelMagic/Chains_of_Purity)

/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Order
	name = "Order"
	KEYWORD = "crowd control"
	verb/Order()
		set category = "Skills"
		fakeTrigger(usr)
	possible_skills = list("Light" = new/obj/Skills/AutoHit/Magic/AngelMagic/Divine_Verdict, "Divinity" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Aegis, "Order" = new/obj/Skills/AutoHit/Magic/AngelMagic/Divine_Sentence)
	New()
		..()
		resetToInital()
	resetToInital()
		possible_skills = list("Light" = new/obj/Skills/AutoHit/Magic/AngelMagic/Divine_Verdict, "Divinity" = new/obj/Skills/Buffs/SlotlessBuffs/Magic/AngelMagic/Aegis, "Order" = new/obj/Skills/AutoHit/Magic/AngelMagic/Divine_Sentence)
