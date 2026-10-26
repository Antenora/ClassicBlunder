/obj/Skills/Buffs/SpecialBuffs/Gamma
	BuffName = "Gamma"
	SpecialSlot = 0
	Slotless = 1
	passives = list()
	ElementalClass = "Fire"
	ElementalOffense = "Fire"
	ElementalDefense = "Fire"
	BuffTechniques = list("/obj/Skills/Gamma_Evolution/Slide_Evolution",\
		"/obj/Skills/Gamma_Evolution/Dark_Evolution")
	var/GammaStance = "Betel"
	var/lastSlide = 0
	var/gulusActive = 0
	var/swapping = 0
	var/slideTickerActive = 0
	verb/Gamma()
		set category = "Skills"
		set hidden = 1
		src.Trigger(usr)
	Trigger(mob/User, Override)
		if(User && !swapping && !User.BuffOn(src))
			swap_stance("betel")
			gulusActive = 0
		return ..()
	proc/turnOff(mob/p)
		Trigger(p, 1)
		cooldown_remaining = 0
	proc/swap_stance(o)
		switch(o)
			if("betel")
				GammaStance = "Betel"
				ElementalClass = "Fire"
				ElementalOffense = "Fire"
				ElementalDefense = "Fire"
				passives = list("Scorching" = 2, "Combustion" = 60, "Heavy Strike" = "Inferno", "Momentum" = 4)
			if("kaus")
				GammaStance = "Kaus"
				ElementalClass = "Wind"
				ElementalOffense = "Wind"
				ElementalDefense = "Wind"
				passives = list("Shocking" = 3, "Flicker" = 4, "Speed Force" = 1, "AttackSpeed" = 2, "Fury" = 4, "Skimming" = 2)
			if("wezen")
				GammaStance = "Wezen"
				ElementalClass = "Earth"
				ElementalOffense = "Earth"
				ElementalDefense = "Earth"
				passives = list("Harden" = 5, "Blubber" = 4, "GiantForm" = 1, "Juggernaut" = 4, "Shattering" = 5)
			if("gulus")
				GammaStance = "Gulus"
				ElementalClass = "Dark"
				ElementalOffense = "Dark"
				ElementalDefense = "Dark"
				passives = list("HellPower" = 0.25, "AbyssMod" = 5, "HellRisen" = 0.5, "Scorching" = 5, "Poisoning" = 5)
	proc/doSlideEvolution(mob/owner)
		if(!owner) return
		if(GammaStance == "Gulus")
			owner << "Slide Evolution is sealed while in Gulus."
			return
		if(lastSlide + (30 SECONDS) > world.time)
			var/remaining = round((lastSlide + (30 SECONDS) - world.time) / 10, 0.1)
			if(remaining>30)
				remaining=0
			else
				owner << "Slide Evolution is on cooldown: [remaining]s remaining."
				return
		var/next_stance
		switch(GammaStance)
			if("Betel")
				next_stance = "kaus"
			if("Kaus")
				next_stance = "wezen"
			if("Wezen")
				next_stance = "betel"
			else
				next_stance = "betel"
		swapping = 1
		if(owner.BuffOn(src))
			turnOff(owner)
		swap_stance(next_stance)
		Trigger(owner, 1)
		swapping = 0
		lastSlide = world.time
		animate(owner, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
		animate(color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=10)
		OMsg(owner, "Slide Evolution! [owner] evolves into [GammaStance]!")
		startSlideCooldownTicker(owner)
	proc/startSlideCooldownTicker(mob/owner)
		if(slideTickerActive) return
		slideTickerActive = 1
		spawn(0)
			while(owner && lastSlide + (30 SECONDS) > world.time)
				sleep(1 SECONDS)
				if(!owner) break
				if(owner.PureRPMode)
					lastSlide += 1 SECONDS
			slideTickerActive = 0
	proc/doDarkEvolution(mob/owner)
		if(!owner) return
		if(GammaStance == "Gulus")
			owner << "You are already in Gulus."
			return
		if(owner.HealthPct() > 25)
			owner << "Dark Evolution can only be invoked at 25% Health or less."
			return
		var/obj/Skills/Gamma_Dark_Evolution_Lock/lock = owner.FindSkill(/obj/Skills/Gamma_Dark_Evolution_Lock)
		if(!lock)
			lock = new /obj/Skills/Gamma_Dark_Evolution_Lock
			owner.AddSkill(lock)
		if(lock.Using)
			owner << "Dark Evolution has already been invoked this fight. You must meditate to restore it."
			return
		swapping = 1
		if(owner.BuffOn(src))
			turnOff(owner)
		swap_stance("gulus")
		Trigger(owner, 1)
		swapping = 0
		lock.Using = 1
		gulusActive = 1
		animate(owner, color = list(0,0,0, 0,0,0, 0,0,0, 0,0,0))
		animate(color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=10)
		OMsg(owner, "[owner] gives into the power of Dark Evolution...")
		spawn(0)
			var/remaining = 60 SECONDS
			while(remaining > 0)
				sleep(1 SECONDS)
				if(!gulusActive) return
				if(!owner) return
				if(GammaStance != "Gulus") return
				if(!owner.BuffOn(src)) return
				if(owner.PureRPMode) continue
				remaining -= 1 SECONDS
			if(!gulusActive) return
			gulusActive = 0
			if(!owner) return
			if(GammaStance != "Gulus") return
			if(!owner.BuffOn(src)) return
			swapping = 1
			turnOff(owner)
			swap_stance("betel")
			Trigger(owner, 1)
			swapping = 0
			animate(owner, color = list(1,0,0, 0,1,0, 0,0,1, 1,1,1))
			animate(color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time=10)
			owner << "Gulus fades; you return to Betel."

/obj/Skills/Gamma_Dark_Evolution_Lock
	name = "Dark Evolution"
	Cooldown = -1

/obj/Skills/Gamma_Evolution
	name = "Gamma Evolution"
	Slide_Evolution
		name = "Slide Evolution"
		verb/Slide_Evolution()
			set category="Skills"
			set hidden = 1
			var/obj/Skills/Buffs/SpecialBuffs/Gamma/gs = locate(/obj/Skills/Buffs/SpecialBuffs/Gamma) in usr
			if(!gs || !usr.BuffOn(gs))
				usr << "You must be in Gamma to use Slide Evolution."
				return
			gs.doSlideEvolution(usr)
	Dark_Evolution
		name = "Dark Evolution"
		verb/Dark_Evolution()
			set category="Skills"
			set hidden = 1
			var/obj/Skills/Buffs/SpecialBuffs/Gamma/gs = locate(/obj/Skills/Buffs/SpecialBuffs/Gamma) in usr
			if(!gs || !usr.BuffOn(gs))
				usr << "You must be in Gamma to use Dark Evolution."
				return
			gs.doDarkEvolution(usr)
