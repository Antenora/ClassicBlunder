/obj/Skills/Projectile/Magic/DarkMagic
	MagicNeeded = 0
/obj/Skills/Projectile/Magic/DarkMagic/Shadow_Ball
	scalingValues = list("Blasts" = list(2,2,3,3,4,4), "DamageMult" = list(0.75,1.25,1.5,2.5,3,4), "EndRate" = list(0.75, 0.6, 0.45, 0.3, 0.25, 0.2), "IconSize" = list(1, 1.15,1.25,1.5,2))
	DamageMult = 3
	AdaptRate = 1
	IconLock='shadowflameball.dmi'
	Trail='shadowfire.dmi'
	TrailDuration=30
	TrailSize=1
	TrailX=-8
	TrailY=-8
	AccMult = 4
	Speed = 1.25
	ManaCost = 5
	Deviation = 240
	ZoneAttack = 1
	ZoneAttackX = 3
	ZoneAttackY = 3
	Cooldown = 60
	CorruptionGain = 1
	proc/returnToInit()
		if(!altered)
			scalingValues = /obj/Skills/Projectile/Magic/DarkMagic/Shadow_Ball::scalingValues
	adjust(mob/p)
		returnToInit()
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1

		for(var/x in scalingValues)
			vars[x] = scalingValues[x][asc]
		if(p.getTotalMagicLevel() >= 10 || p.isRace(DEMON))
			Homing = 1
			Speed = 0.75
	verb/Shadow_Ball()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)

/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind
	var/corruptionGain = list(6,8,12,14,16,20)
	Range = 25
	ManaCost = 5
	AffectTarget = 1
	Cooldown = 60
	TimerLimit = 10
	ShatterAffected = 100
	ShockAffected = 100
	applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind_Apply
	adjust(mob/p)
		if(p.isRace(DEMON) && applyToTarget.type != /obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind_Apply/Demon)
			applyToTarget = new/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind_Apply/Demon

	Trigger(var/mob/User, Override=0)
		if(!altered)
			adjust(User)
			applyToTarget?:adjust(User)
		. = ..()
		if(.)
			var/asc = User.AscensionsAcquired ? User.AscensionsAcquired + 1 : 1
			User.Target.Darkness(10 * asc, 7-asc)
			User.Target.RemoveTarget()
			User.Target.Grab_Release()
			if(User.isRace(DEMON))
				if(asc < 1)
					asc = 1
				User.gainCorruption(corruptionGain[asc] * glob.CORRUPTION_GAIN)


/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind_Apply
	BuffName = "Dominate Mind Applied"
	MagicNeeded = 0
	StunAffected = 10
	ConfuseAffected = 100
	InstantAffect = 1
	TimerLimit = 10
	adjust(mob/p)
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
		var/list/timers = list(2,4,4,5,6,6)
		if(asc == 0)
			StunAffected = 2
		else
			StunAffected = timers[asc]



/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind_Apply/Demon
	MagicNeeded = 0
	BuffName = "Mind Dominated"

/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Soul_Leech // switch this to a speed boost, similar to haste or a shield
	scalingValues = list("TimerLimit" = list(25,30,35,40,50,60), "Godspeed" = list(1,2,3,4,5,6), "AfterImages" = list(1,2,3,4,5,6), "VaizardHealth" = list(1,2,3,4,5,5), \
							"VaizardShatter"= list(1,1,1,1,1,1), "Flicker" = list(1,2,3,3,4,4,5), "Flow" = list(0.25,0.5,1,1.25,1.5,2))
	Cooldown = 60
	name = "Soul Surge"
	BuffName ="Soul Surge"
	ActiveMessage = "surges through reality!"
	OffMessage = "stops surging..."
	Trigger(var/mob/User, Override=0)
		if(!altered)
			adjust(User)
		. = ..()
	adjust(mob/p)
		scalingValues = /obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Soul_Leech::scalingValues
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired + 1 : 1
		VaizardHealth = scalingValues["VaizardHealth"][asc]
		VaizardShatter = 1
		for(var/x in scalingValues)
			vars[x] = scalingValues[x][asc]
		SpdMult = 1 + (0.05 * asc)

	verb/Soul_Surge()
		set category = "Skills"
		if(!altered)
			adjust(usr)
		Trigger(usr)
/obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Soul_Leech_Apply
	scalingValues = list("TimerLimit" = list(12,10,8,5,5,4), "ManaHeal" = list(-10,-15,-20,-20,-25,-30), "HealthHeal" = list(-1,-1,-2,-2,-3,-3), "EnergyHeal" = list(-4,-6,-8,-8,-10,-12))
	StableHeal = 1
	DeleteOnRemove = 1
	MagicNeeded = 0
	Cooldown = 0
	adjust(mob/p)
		var/asc = p.AscensionsAcquired ? p.AscensionsAcquired : 1
		for(var/x in scalingValues)
			vars[x] = scalingValues[x][asc]
		ManaHeal = (ManaHeal / TimerLimit) * world.tick_lag
		HealthHeal = (HealthHeal / TimerLimit) * world.tick_lag
		EnergyHeal = (EnergyHeal / TimerLimit) * world.tick_lag
	Trigger(mob/User, Override = 0 )
		var/aa = ..()
		if(aa)
			User.SlotlessBuffs.Add(src)
		. = 1
