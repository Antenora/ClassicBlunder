#define NAMEK_DARKNESS_BONUS 0.05
#define NAMEK_NIGHT_DARKNESS 0.5

/obj/Skills/Projectile/Namekian/Darkness_Eye_Beam
	name = "Darkness Eye Beam"
	desc = "Two thin violet beams from the eyes."
	Copyable = 0
	DamageMult = 0.6
	Blasts = 2
	Delay = 0
	Distance = 12
	Cooldown = 7
	EnergyCost = 1
	Knockback = 0
	Variation = 6
	IconLock = 'Blast - Small.dmi'
	ActiveMessage = "fires twin violet beams from their eyes!"

	verb/Darkness_Eye_Beam()
		set name = "Darkness Eye Beam"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Utility/Namekian/Psycho_Pull
	name = "Psycho Pull"
	desc = "Seize your target with telekinesis and drag them three tiles toward you, dazing them for half a second."
	Copyable = 0
	Cooldown = 18
	EnergyCost = 2
	var/PullRange = 7
	var/PullTiles = 3
	var/PullDaze = 0.5

	verb/Psycho_Pull()
		set name = "Psycho Pull"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		User.NamekCastPsychoPull(src)

/mob/proc/NamekCastPsychoPull(obj/Skills/Utility/Namekian/Psycho_Pull/M)
	if(!M || !src.CanUseSkill(M))
		return
	var/mob/T = src.Target
	if(!NamekFoeInReach(T, M.PullRange, M))
		return
	M.Cooldown(1, null, src)
	NamekPayEnergy(M)
	src.OMessage(10, "[src] seizes [T] with telekinesis and drags them in!", "<font color=red>[src]([src.key]) uses Psycho Pull on [T]([T.key]).")
	T.PullToward(src, M.PullTiles, 1)
	Stun(T, M.PullDaze)

/obj/Skills/Utility/Namekian/Mind_Read
	name = "Mind Read"
	desc = "See their current stats, health and energy, and for eight seconds dodge their attacks more easily."
	Copyable = 0
	Cooldown = 30
	EnergyCost = 1
	var/ReadRange = 10
	var/ReadDuration = 80
	var/ReadDodge = 15

	verb/Mind_Read()
		set name = "Mind Read"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		User.NamekCastMindRead(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Mind_Read
	name = "Mind Read"
	BuffName = "Mind Read"
	TimerLimit = 8
	CooldownStatic = 1
	Cooldown = 0
	Copyable = 0
	ActiveMessage = "reads their foe's every move."
	OffMessage = "loses the thread of their foe's thoughts."

/mob/proc/NamekCastMindRead(obj/Skills/Utility/Namekian/Mind_Read/M)
	if(!M || !src.CanUseSkill(M))
		return
	var/mob/T = src.Target
	if(!NamekFoeInReach(T, M.ReadRange, M))
		return
	M.Cooldown(1, null, src)
	NamekPayEnergy(M)
	src << "<font color=#a58cff>[T]'s mind lies open: Strength [round(T.GetStr(), 0.01)], Endurance [round(T.GetEnd(), 0.01)], Force [round(T.GetFor(), 0.01)], Offense [round(T.GetOff(), 0.01)], Defense [round(T.GetDef(), 0.01)], Speed [round(T.GetSpd(), 0.01)]; Health [round(T.HealthPct())] percent, Energy [round(T.Energy / max(1, T.EnergyMax) * 100)] percent.</font>"
	src.dodge_vs_mob = T
	src.dodge_vs_until = world.time + M.ReadDuration
	src.dodge_vs_amt = M.ReadDodge
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Mind_Read/B = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Mind_Read)
	if(B)
		B.TimerLimit = M.ReadDuration / 10
		if(src.BuffOn(B))
			B.Timer = 0
		else
			B.Trigger(src, TRUE)
	src.OMessage(10, "[src] stares into [T]'s mind.", "<font color=red>[src]([src.key]) uses Mind Read on [T]([T.key]).")

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Energy_Shield
	name = "Energy Shield"
	BuffName = "Energy Shield"
	desc = "Wrap yourself in a shell of energy for ten seconds: ranged attacks deal 20 percent less damage to you."
	Copyable = 0
	TimerLimit = 10
	Cooldown = 40
	EnergyCost = 2
	passives = list("RangedResist" = 2)
	ActiveMessage = "wraps themselves in a shell of dark energy!"
	OffMessage = "lets their energy shield fade."

	verb/Energy_Shield()
		set name = "Energy Shield"
		set category = "Skills"
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Namekian_Giant_Form/Conqueror
	name = "Conqueror's Giant Form"
	desc = "The Conqueror's giant form, bigger than any other: stronger and tougher but slower, and more vulnerable to stuns and blinding flashes. You can still dodge."
	Enlarge = 3
	DefMult = 0.85
	passives = list("GiantForm" = 1, "Juggernaut" = -1, "EnergyLeak" = 1)

/proc/NamekIsNight()
	return DnDarknessFrac() >= NAMEK_NIGHT_DARKNESS

/mob/proc/NamekDarknessWanted()
	if(!NamekIsNamek() || src.NamekPath != NAMEK_PATH_CONQUEROR || src.AscensionsAcquired < 4)
		return 0
	return NamekIsNight()

/mob/proc/NamekSyncDarkness()
	var/target = NamekDarknessWanted() ? NAMEK_DARKNESS_BONUS : 0
	var/delta = target - src.NamekDarknessApplied
	if(delta)
		NamekMoveMagnified(delta)
		src.NamekDarknessApplied = target

/mob/proc/NamekReleaseDarkness()
	if(src.NamekDarknessApplied)
		NamekMoveMagnified(-src.NamekDarknessApplied)
		src.NamekDarknessApplied = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Power_of_Darkness
	name = "Power of Darkness"
	BuffName = "Power of Darkness"
	desc = "At night your power swells: all six of your stats rise while it is dark."
	AlwaysOn = 1
	doNotDelete = 1
	Cooldown = 0
	Copyable = 0
	var/DarknessEvery = 100
	var/tmp/darkness_next = 0

	GainLoop(mob/source)
		..()
		if(source && world.time >= darkness_next)
			darkness_next = world.time + DarknessEvery
			source.NamekSyncDarkness()

	Trigger(mob/User, Override = 0)
		. = ..()
		if(!User)
			return
		if(User.BuffOn(src))
			darkness_next = 0
		else
			User.NamekReleaseDarkness()

/obj/Skills/Projectile/Beams/Big/Namekian/Darkness_Blaster
	name = "Darkness Blaster"
	desc = "The giant's beam. Hold to charge it, release to pour it out."
	Copyable = 0
	DamageMult = 0.45
	Cooldown = 30
	EnergyCost = 4
	BeamTime = 10
	HeldSkill = TRUE
	HeldBeam = TRUE
	ChargePeriod = 3
	CritEffectiveness = 0
	ActiveMessage = "unleashes the Darkness Blaster!"

	verb/Darkness_Blaster()
		set name = "Darkness Blaster"
		set category = "Skills"
		usr.BeginHeldSkill(src)
