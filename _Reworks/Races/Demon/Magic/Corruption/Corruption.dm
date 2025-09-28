/obj/Skills/AutoHit/Magic/Corruption/Corrupt_Reality
	scalingValues = list("Primordial" = list(0.3,0.6,1,1.25,1.5,2), "DamageMult" = list(0.01,0.05,0.075,0.1,0.1,0.12))
	Area= "Target"
	SpecialAttack=1
	AdaptRate = 1
	Distance = 10
	// Corrupt = 1
	CanBeBlocked=0
	CanBeDodged=0
	EndDefense = 0.0001
	Bang = 3
	CorruptionCost = 25
	Cooldown = -1
	adjust(mob/p)
		scalingValues = /obj/Skills/AutoHit/Magic/Corruption/Corrupt_Reality::scalingValues
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
		for(var/x in scalingValues)
			vars[x] = scalingValues[x][asc]
	Trigger(mob/p)
		adjust(usr)
		ManaCost = usr.ManaAmount
		DamageMult = 1 + (ManaCost * DamageMult)
		if(Using || cooldown_remaining || !(p.Target.Health <= 50))
			p << "On cd, being used, or target is above 50."
			return FALSE
		var/aaa = p.Activate(src)
		return aaa

	verb/Corrupt_Reality()
		set category = "Skills"
		adjust(usr)
		ManaCost = usr.ManaAmount
		DamageMult = 1 + (ManaCost * DamageMult)
		usr.Activate(src)


/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Space
	makSpace = new/spaceMaker/Demon
	Cooldown = -1
	TimerLimit = 300
	CorruptionCost = 25
	scalingValues = list("toDeath" = list(150,250,300,600,1200), "range" = list(8,15,20,25,30, 30))
	adjust(mob/p)
		scalingValues = /obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Space::scalingValues
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
		makSpace.configuration = "Fill"
		for(var/variable in scalingValues)
			makSpace.vars[variable] = scalingValues[variable][asc]
		passives = p.demon.BuffPassives
		TimerLimit = scalingValues["toDeath"][asc]/10
	Trigger(mob/User, Override)
		. = 0
		if(!User.BuffOn(src))
			adjust(User)
		else
			if(!Override && User.BuffingUp)
				return 0
			if(!Override)
				User.BuffingUp++
			if(Sealed && !Override)
				User << "This spell is sealed!"
				return 0
			if(src.DashCountLimit)
				src.DashCount=0
			User.UseBuff(src, Override)
			User.BuffingUp=0
			if(!src.BuffName)
				src.BuffName="[src.name]"
			return 1
		if(!Using)
			if(User.Corruption - CorruptionCost < 0)
				User << "Not enough corruption"
				return 0
			else
				User.Corruption -= CorruptionCost
				makSpace.makeSpace(User, User.demon)
			. = ..()



/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Time
	var/timer = list(15, 25, 40 , 60, 120)
	CorruptionCost = 25
	Cooldown = -1
	Trigger(mob/p)
		if(CorruptionCost)
			if(p.Corruption - CorruptionCost < 0)
				p << "You don't have enough Corruption to activate [src]"
				return FALSE
		if(Using || cooldown_remaining != 0)
			p << "This is on cooldown"
			return
		Cooldown(1, null, p)
		if(CorruptionCost)
			p.gainCorruption(-CorruptionCost)
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired : 1
		var/image/i = image('Caja.dmi')
		world<<i
		missile(i,p,p.Target)
		sleep(10)
		i.loc=p.Target.loc
		i.icon_state="Active"
		p.Target.density=0
		p.Target.Grabbable=0
		p.Target.Incorporeal=1
		p.Target.invisibility=90
		p.Target.SetStasis(timer[asc])
		p.Target.StasisSpace=1
		spawn()animate(p.Target.client, color = list(-1,0,0, 0,-1,0, 0,0,-1, 0,1,1), time = 5)
		OMsg(usr, "[usr] locks [usr.Target] in an isolated space!")
		spawn(timer[asc]*10)
			del i


/obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Self
	Cooldown = -1
	scalingValues = list("LifeGeneration" = list(1,1,1.5,2,2,2.5), "DebuffResistance" = list(0.25,0.5,0.75,1,1,1), \
	"TechniqueMastery" = list(2,3,5,5,8), "Godspeed" = list(1,2,3,4,5), "Adrenaline" = list(1,2,2,3,3,3), "IdealStrike" = list(1,1,1,1,1,1), \
	"FullyEffecient" = list(1,1,1,1,1,1), "CoolerAfterImages" = list(3,4,4,4,4,4), "CorruptAffected" = list(1,1,1,1,1,1))
	AutoAnger = 1
	HealthThreshold = 0.1
	KenWave=3
	KenWaveIcon='KenShockwaveDivine.dmi'
	AuraLock='BLANK.dmi'
	FlashChange=1
	HairLock=1
	IconLock='zekkai.dmi'
	IconLockBlend = BLEND_MULTIPLY
	HitSpark = 'Black Flash Alt.dmi'
	KenWaveSize=3
	ManaGlow="#472951"
	ManaGlowSize=2
	CorruptionCost = 75
	var/enableAfterimages
	adjust(mob/p)
		SpdMult = 1
		EndMult = 1
		passives = list()
		scalingValues = /obj/Skills/Buffs/SlotlessBuffs/Magic/Corruption/Corrupt_Self::scalingValues
		var/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/d = p.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/)
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
		var/pacts = p.demon.PactsTaken
		var/boon = (pacts * 0.05) + (0.05 * (asc - 1))
		if(!d)
			p << "Error in setting up Corrupt Self pls gmhelp"
		passives = d.passives.Copy()
		for(var/x in scalingValues)
			passives[x] = scalingValues[x][asc]
		if(p.GetSpd() > p.GetEnd())
			passives["BlurringStrikes"] = asc
			SpdMult = 1.1 + boon
		else
			passives["CallousedHands"] = asc/5
			EndMult = 1.1 + boon
		PowerMult = 1.05 + boon
		TimerLimit = 60 + (pacts * 15) + (asc * 15)
		if(!enableAfterimages)
			passives["CoolerAfterImages"] = 0
		// put it on cd
	verb/Adjust_Name()
		set category = "Utility"
		NameFake = input(usr, "What name?") as text
	verb/Impose_Will()
		set category = "Skills"
		set desc = "Bring forth your true form without alerting others."
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr, FALSE)

	Trigger(mob/User, Override)
		..()
		var/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/d = User.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/)
		if(User.BuffOn(src))
			if(User.BuffOn(d))
				d.Trigger(User, 1)
				// jump out of true form
			d.Cooldown()
