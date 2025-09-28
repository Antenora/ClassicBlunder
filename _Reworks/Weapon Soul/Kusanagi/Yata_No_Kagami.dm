obj/Skills/Buffs/SlotlessBuffs/Yata_no_Kagami/Mirror_Protection
	// VaizardShatter = TRUE
	// var/tmp/secondActivation = FALSE
	// var/tmp/storedMana = 0
	passives = list("TotalDeflection" = 1, "TotalReversal" = 1, "Blubber" = 4)
	ManaCost = 10
	Cooldown = 160
	adjust(mob/p)
		TimerLimit = 10 + (p.SagaLevel * 5)
		VaizardHealth = 5 + (2.5 * p.SagaLevel)
		Cooldown = 160 - (p.SagaLevel * 5)
		ManaCost = 10 + (p.SagaLevel  * 2)

	/* wasn't working
	adjust(mob/p)
		VaizardHealth = storedMana/150
		storedMana = 0

	Trigger(mob/User, Override = 0)
		if(!secondActivation)
			secondActivation = TRUE
			spawn while(!User.BuffOn(src))
				if(User.ManaAmount > 0)
					if(User.SpecialBuff&&User.SpecialBuff.name == "Heavenly Regalia: The Three Treasures")
						storedMana += 1 // store double the mana for the same cost
					storedMana += 1
					storedMana = clamp(0, storedMana, 15*User.SagaLevel)
					User.LoseMana(1,1)
					if(storedMana == 15*User.SagaLevel)
						Trigger(User)
				sleep(2)
		else
			if(!User.BuffOn(src))
				adjust(User)
			..()
			if(User.BuffOn(src))
				secondActivation = FALSE
*/
	verb/Mirror_Protection()
		set name = "Yata no Kagami: Mirror Protection"
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr)
		Trigger(usr)

obj/Skills/Yata_no_Kagami/Mirror_Prison
	Distance = 10
	Cooldown = 240
	var/mirrorTime = 20 SECONDS

	proc/getArea(mob/user)
		var/list/one = block(user.x-(Distance/2)+1, user.y-(Distance/2)+1, user.z, user.x+(Distance/2)-1, user.y+(Distance/2)-1)
		var/list/two = block(user.x-(Distance/2)+2, user.y-(Distance/2)+2, user.z, user.x+(Distance/2)-2, user.y+(Distance/2)-2)
		one -= two
		return one

	proc/spawnMirrors(list/area, timer)
		for(var/turf/T in area)
			var/obj/Mirror/mirror = new(T)
			mirror.onSpawn(timer)

	verb/Mirror_Prison()
		set name = "Yata no Kagami: Mirror Prison"
		set category = "Skills"
		if(usr.KO||usr.Stunned||usr.AutoHitting||usr.Frozen>=2)
			return
		if(usr.Stasis)
			return
		if(src.Using)
			return
		if(usr.SpecialBuff&&usr.SpecialBuff.name == "Heavenly Regalia: The Three Treasures")
			mirrorTime = 30 SECONDS
			Distance = 15
		else
			mirrorTime = 20 SECONDS
			Distance = 10
		Cooldown()
		spawnMirrors(getArea(usr), mirrorTime)

obj/Mirror
	density = 1
	Destructable = FALSE
	Grabbable = FALSE
	icon = 'Yata_no_Kagami Mirror.dmi'
	proc/onSpawn(timer)
		spawn(timer)
			loc = null
			del src
	onBumped(atom/Obstacle)
		..()
		if(istype(Obstacle,/obj/Skills/Projectile/_Projectile))
			Obstacle:Backfire = 1
			Obstacle.dir = turn(Obstacle.dir, pick(45, -45, 90, 180,-90))