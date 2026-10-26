/obj/Skills/AutoHit/Namekian/Whirlwind
	name = "Whirlwind"
	desc = "Spin with your claws out, raking every foe around you."
	Copyable = 0
	Area = "Circle"
	Distance = 1
	StrScaling = 1
	DamageMult = 4.29
	Cooldown = 10
	EnergyCost = 2
	TurfStrike = 1
	ActiveMessage = "spins into a whirlwind!"
	HitSparkIcon = 'Slash.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkTurns = 1
	HitSparkSize = 1
	HitSparkDispersion = 1

	verb/Whirlwind()
		set name = "Whirlwind"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Queue/Namekian/Deep_Strike
	name = "Deep Strike"
	desc = "Queue a driving blow that sinks deep into your foe."
	Copyable = 0
	DamageMult = 4.37
	AccuracyMult = 1
	Duration = 5
	Cooldown = 8
	EnergyCost = 1
	HitMessage = "drives a deep strike into their foe!"

	verb/Deep_Strike()
		set name = "Deep Strike"
		set category = "Skills"
		usr.SetQueue(src)

/obj/Skills/AutoHit/Namekian/Dragons_Punishment
	name = "Dragon's Punishment"
	desc = "Tear into every foe around you and heal for half of the damage you deal."
	Copyable = 0
	Area = "Circle"
	Distance = 1
	StrScaling = 1
	DamageMult = 16.63
	Cooldown = 45
	EnergyCost = 4
	TurfStrike = 1
	ActiveMessage = "feeds on their foes with Dragon's Punishment!"
	HitSparkIcon = 'Slash.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkTurns = 1
	HitSparkSize = 1
	HitSparkDispersion = 1
	var/PunishmentHeal = 0.5

	OnSkillHit(mob/caster, mob/m, atom/hitter, dealt)
		if(!ismob(caster) || !ismob(m) || m == caster || dealt <= 0)
			return
		caster.HealHealth(m.HPToPct(dealt) * PunishmentHeal)

	verb/Dragons_Punishment()
		set name = "Dragons Punishment"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Cyclone
	name = "Cyclone Daze"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 8
	OffMult = 0.9
	ActiveMessage = "is dazed by the cyclone!"
	OffMessage = "regains their bearings."

/obj/Skills/AutoHit/Namekian/Cyclone
	name = "Cyclone"
	desc = "Whip up a cyclone around you; every foe it strikes loses 10 percent Offense for 8 seconds."
	Copyable = 0
	Area = "Circle"
	Distance = 1
	StrScaling = 1
	DamageMult = 5.61
	Cooldown = 14
	EnergyCost = 2
	TurfStrike = 1
	ActiveMessage = "whips up a cyclone!"
	var/CycloneSeconds = 8

	OnSkillHit(mob/caster, mob/m, atom/hitter, dealt)
		if(!ismob(m) || m == caster || m.KO)
			return
		m.NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Cyclone, CycloneSeconds)

	verb/Cyclone()
		set name = "Cyclone"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Dragons_Pledge
	name = "Dragon's Pledge"
	desc = "Passive. When a blow drops you below 30 percent health, your Defense rises by 30 percent for 10 seconds. Once every 90 seconds."
	Copyable = 0
	DefMult = 1.3
	TimerLimit = 10
	Cooldown = 0
	ActiveMessage = "refuses to fall, honoring the Dragon's Pledge!"
	OffMessage = "lets the Dragon's Pledge settle."
	var/PledgeHealth = 30
	var/PledgeEvery = 900

/strikeHook/namekDragonsPledge
	stage = "post"
	fire(strike/S)
		var/mob/d = S.defender
		if(!d || d.KO || d.NamekPath != NAMEK_PATH_DARK_WARRIOR)
			return
		if(world.time < d.NamekPledgeReadyAt)
			return
		var/obj/Skills/Buffs/SlotlessBuffs/Namekian/Dragons_Pledge/P = locate() in d
		if(!P || d.BuffOn(P) || d.HealthPct() >= P.PledgeHealth)
			return
		d.NamekPledgeReadyAt = world.time + P.PledgeEvery
		P.Trigger(d, TRUE)

/obj/Skills/Projectile/Namekian/Demon_Wave
	name = "Demon Wave"
	desc = "Loose a piercing wave of dark ki that leaves every foe it passes through bleeding."
	Copyable = 0
	DamageMult = 4.97
	Distance = 12
	Piercing = 1
	Bloodletting = 2
	Cooldown = 20
	EnergyCost = 3
	ActiveMessage = "looses a Demon Wave!"
	IconLock = 'Blast - Small.dmi'
	IconSize = 1.5
	LockX = 0
	LockY = 0
	Variation = 0

	verb/Demon_Wave()
		set name = "Demon Wave"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Queue/Namekian/Dragon_Strike
	name = "Dragon Strike"
	desc = "Queue the heavy finishing blow of the Dark Warrior line."
	Copyable = 0
	DamageMult = 9.03
	AccuracyMult = 1
	Duration = 5
	Cooldown = 15
	EnergyCost = 3
	HitMessage = "lands a devastating Dragon Strike!"

	verb/Dragon_Strike()
		set name = "Dragon Strike"
		set category = "Skills"
		usr.SetQueue(src)

/obj/Skills/Projectile/Namekian/Energy_Siege
	name = "Energy Siege"
	desc = "Compress your ki into a dense shot and fire it."
	Copyable = 0
	DamageMult = 4.88
	Distance = 12
	Cooldown = 15
	EnergyCost = 3
	ActiveMessage = "fires a dense Energy Siege!"
	IconLock = 'Blast - Small.dmi'
	IconSize = 1.5
	LockX = 0
	LockY = 0
	Variation = 0

	verb/Energy_Siege()
		set name = "Energy Siege"
		set category = "Skills"
		usr.UseProjectile(src)
