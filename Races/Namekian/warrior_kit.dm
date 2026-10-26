/obj/Skills/Queue/Namekian

/obj/Skills/Buffs/SlotlessBuffs/Namekian

/obj/Skills/Projectile/Beams/Big/Namekian

/obj/Skills/Projectile/Namekian/Masenko
	name = "Masenko"
	desc = "Raise both palms overhead and fire a bright blast of ki."
	Copyable = 0
	DamageMult = 2.36
	Distance = 12
	Cooldown = 8
	EnergyCost = 1
	ActiveMessage = "raises both palms overhead and fires a Masenko!"
	IconLock = 'Blast - Small.dmi'
	IconSize = 1.25
	LockX = 0
	LockY = 0
	Variation = 0

	verb/Masenko()
		set name = "Masenko"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Queue/Namekian/Charging_Fist
	name = "Charging Fist"
	desc = "Queue a punch that dashes you up to five tiles into your target."
	Copyable = 0
	DamageMult = 6.3
	AccuracyMult = 1
	Duration = 5
	Warp = 5
	Cooldown = 12
	EnergyCost = 1
	HitMessage = "charges in behind a driving fist!"

	verb/Charging_Fist()
		set name = "Charging Fist"
		set category = "Skills"
		usr.SetQueue(src)

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Draconic_Protection
	name = "Draconic Protection"
	desc = "Harden your hide for 20 seconds: Harden 2 and Melee Resist 1."
	Copyable = 0
	passives = list("Harden" = 2, "MeleeResist" = 1)
	TimerLimit = 20
	Cooldown = 60
	EnergyCost = 1
	ActiveMessage = "hardens their hide with draconic protection!"
	OffMessage = "lets their draconic protection fade."

	verb/Draconic_Protection()
		set name = "Draconic Protection"
		set category = "Skills"
		src.Trigger(usr)

/obj/Skills/Projectile/Beams/Big/Namekian/Charged_Masenko
	name = "Charged Masenko"
	desc = "Hold to charge, release to pour a Masenko down a line. Deals 50 percent more to a foe struck from behind."
	Copyable = 0
	AllOutAttack = 0
	Radius = 0
	Dodgeable = 1
	DamageMult = 0.45
	BeamTime = 10
	Cooldown = 14
	EnergyCost = 2
	HeldSkill = TRUE
	HeldBeam = TRUE
	ChargePeriod = 2
	CritEffectiveness = 0
	BonusFromBehind = 0.5
	ActiveMessage = "pours a charged Masenko down a line!"

	verb/Charged_Masenko()
		set name = "Charged Masenko"
		set category = "Skills"
		usr.BeginHeldSkill(src)

/obj/Skills/Queue/Namekian/Draconic_Overpowering
	name = "Draconic Overpowering"
	desc = "Queue a crushing blow that stuns its target for one second."
	Copyable = 0
	DamageMult = 8.19
	AccuracyMult = 1
	Duration = 5
	Stunner = 1
	Cooldown = 20
	EnergyCost = 2
	HitMessage = "overpowers their foe with a crushing draconic blow!"

	verb/Draconic_Overpowering()
		set name = "Draconic Overpowering"
		set category = "Skills"
		usr.SetQueue(src)

/obj/Skills/Projectile/Beams/Big/Namekian/Special_Beam_Cannon
	name = "Special Beam Cannon"
	desc = "Two fingers to the forehead: hold to charge a drilling beam that pierces every foe in its path. You take 25 percent more damage while charging."
	Copyable = 0
	AllOutAttack = 0
	Radius = 0
	Dodgeable = 1
	Knockback = 0
	DamageMult = 0.67
	Distance = 50
	BeamTime = 10
	Cooldown = 25
	EnergyCost = 2
	Piercing = 1
	HeldSkill = TRUE
	HeldBeam = TRUE
	ChargePeriod = 3
	HeldVulnerability = 0.25
	CritEffectiveness = 0
	ActiveMessage = "fires the Special Beam Cannon!"
	IconLock = EFX92_HIT_PIERCER

	verb/Special_Beam_Cannon()
		set name = "Special Beam Cannon"
		set category = "Skills"
		usr.BeginHeldSkill(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Draconic_Curse
	name = "Draconic Curse"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 10
	EndMult = 0.85
	DefMult = 0.85
	ActiveMessage = "is weakened by a draconic curse!"
	OffMessage = "shakes off the draconic curse."

/obj/Skills/Projectile/Namekian/Draconic_Curse
	name = "Draconic Curse"
	desc = "Fire a cursed bolt: the foe it strikes loses 15 percent Endurance and Defense for 10 seconds."
	Copyable = 0
	DamageMult = 0
	Distance = 12
	Cooldown = 30
	EnergyCost = 2
	OnMobHit = "/proc/NamekDraconicCurseHit"
	ActiveMessage = "hurls a cursed bolt!"
	IconLock = 'Blast - Small.dmi'
	IconSize = 0.75
	LockX = 0
	LockY = 0
	Variation = 0
	var/CurseSeconds = 10

	verb/Draconic_Curse()
		set name = "Draconic Curse"
		set category = "Skills"
		usr.UseProjectile(src)

/proc/NamekDraconicCurseHit(mob/target, obj/Skills/Projectile/_Projectile/proj)
	if(!ismob(target) || !proj || target == proj.Owner || target.KO)
		return
	var/secs = 10
	var/obj/Skills/Projectile/Namekian/Draconic_Curse/S = proj.from_skill
	if(istype(S))
		secs = S.CurseSeconds
	target.NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Draconic_Curse, secs)

/obj/Skills/Projectile/Namekian/Hellzone_Grenade
	parent_type = /obj/Skills/Projectile/Zone_Attacks/Hellzone_Grenade
	name = "Hellzone Grenade"
	desc = "Surround your target with twelve hanging blasts that converge on them."
	Copyable = 0
	SignatureTechnique = 0
	DamageMult = 0.56
	Cooldown = 20
	EnergyCost = 4

	Hellzone_Grenade()
		set name = "Hellzone Grenade"
		set category = "Skills"
		usr.NamekHellzone(src)

/mob/proc/NamekHellzone(obj/Skills/Projectile/Namekian/Hellzone_Grenade/S)
	var/mob/T = src.Target
	if(!ismob(T) || T == src || T.z != src.z)
		src << "<font color='red'>You need a target to encircle.</font>"
		return
	if(!CanUseSkill(S))
		return
	NamekPayCast(S)
	OMsg(src, "<b><font color='[S.ActiveColor]'>[src] [S.ActiveMessage]</font color></b>")
	var/turf/c = get_turf(T)
	if(!c)
		return
	for(var/d in list(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST))
		var/turf/t1 = get_step(c, d)
		var/turf/t2 = t1 ? get_step(t1, d) : null
		if(!t2 || t2.density)
			continue
		NamekHellzoneBlast(S, T, t2, c)
	for(var/d in list(NORTH, EAST, SOUTH, WEST))
		var/turf/t1 = get_step(c, d)
		var/turf/t2 = t1 ? get_step(t1, d) : null
		var/turf/t3 = t2 ? get_step(t2, d) : null
		if(!t3 || t3.density)
			continue
		NamekHellzoneBlast(S, T, t3, c)

/mob/proc/NamekHellzoneBlast(obj/Skills/Projectile/S, mob/T, turf/at, turf/c)
	var/obj/Skills/Projectile/HZ = new S.type
	HZ.SpawnPosition = at
	var/obj/Skills/Projectile/_Projectile/pj = new /obj/Skills/Projectile/_Projectile(src, HZ, at, 0.5, 0, 0, get_dir(at, c) || NORTH)
	if(pj)
		pj.Homing = T

/obj/Skills/Projectile/Namekian/Light_Grenade
	name = "Light Grenade"
	desc = "Gather ki between both hands and hurl a dense, blazing orb."
	Copyable = 0
	DamageMult = 10.81
	Distance = 15
	Cooldown = 30
	EnergyCost = 5
	ActiveMessage = "hurls a blazing Light Grenade!"
	IconLock = 'Blast - Small.dmi'
	IconSize = 2
	LockX = 0
	LockY = 0
	Variation = 0

	verb/Light_Grenade()
		set name = "Light Grenade"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Beams/Big/Namekian/Masenko_Beam_Cannon
	name = "Masenko Beam Cannon"
	desc = "Fire the Masenko and the Special Beam Cannon together as one wide beam. Hold to charge, release to fire."
	Copyable = 0
	AllOutAttack = 0
	DamageMult = 0.94
	BeamTime = 10
	Cooldown = 35
	EnergyCost = 4
	HeldSkill = TRUE
	HeldBeam = TRUE
	ChargePeriod = 3
	CritEffectiveness = 0
	ActiveMessage = "fires the Masenko and the Special Beam Cannon as one!"

	verb/Masenko_Beam_Cannon()
		set name = "Masenko Beam Cannon"
		set category = "Skills"
		usr.BeginHeldSkill(src)
