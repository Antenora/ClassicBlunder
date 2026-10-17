#define NAMEK_REINCARNATION_REALTIME 864000
#define NAMEK_EGG_HATCH_TIME 300
#define NAMEK_EGG_ORPHAN_GRACE 100
#define NAMEK_EGG_HEALTH_SHARE 0.5
#define NAMEK_HATCH_HEALTH_PCT 25
#define NAMEK_NEWBORN_SECONDS 300
#define NAMEK_NEWBORN_MULT 0.75

mob/var/tmp/obj/NamekEgg/NamekEggPending
mob/var/tmp/turf/NamekEggTurf

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Newborn
	name = "Namekian Newborn"
	BuffName = "Namekian Newborn"
	TimerLimit = NAMEK_NEWBORN_SECONDS
	CooldownStatic = 1
	Cooldown = 0
	Copyable = 0
	StrMult = NAMEK_NEWBORN_MULT
	EndMult = NAMEK_NEWBORN_MULT
	ForMult = NAMEK_NEWBORN_MULT
	OffMult = NAMEK_NEWBORN_MULT
	DefMult = NAMEK_NEWBORN_MULT
	SpdMult = NAMEK_NEWBORN_MULT
	ActiveMessage = "is still growing into a newborn body."
	OffMessage = "has grown into their new body."

/obj/NamekEgg
	name = "Namekian Egg"
	Savable = 0
	Grabbable = 0
	density = 0
	invisibility = 101
	mouse_opacity = 0
	var/tmp/mob/egg_owner
	var/tmp/mob/Player/AI/Namekian_Egg_Shell/egg_shell
	var/tmp/mob/Body/egg_corpse
	var/tmp/egg_broken = 0
	var/tmp/egg_hatch_at = 0

	proc/NamekEggSetup(mob/owner, mob/Body/corpse)
		egg_owner = owner
		egg_corpse = corpse
		if(corpse)
			corpse.density = 0
		egg_hatch_at = world.time + NAMEK_EGG_HATCH_TIME
		egg_shell = new(loc)
		egg_shell.NamekShellSetup(owner, src)
		spawn(NAMEK_EGG_HATCH_TIME + NAMEK_EGG_ORPHAN_GRACE)
			if(src)
				NamekEggClear()

	proc/NamekEggBreak(mob/P)
		if(egg_broken)
			return
		egg_broken = 1
		if(egg_shell)
			egg_shell.OMessage(15, "The egg cracks apart!", "<font color=red>[egg_owner]'s Reincarnation Egg was destroyed by [P].")

	proc/NamekEggHome()
		if(egg_shell && isturf(loc) && egg_shell.loc != loc)
			egg_shell.loc = loc
			egg_shell.step_x = 0
			egg_shell.step_y = 0

	proc/NamekEggClear()
		var/mob/Player/AI/Namekian_Egg_Shell/S = egg_shell
		if(egg_corpse)
			egg_corpse.density = initial(egg_corpse.density)
		egg_shell = null
		egg_owner = null
		egg_corpse = null
		if(S)
			S.shell_of = null
			S.loc = null
			spawn() del S
		loc = null
		del src

/mob/Player/AI/Namekian_Egg_Shell
	name = "Namekian Egg"
	desc = "A large, warm egg. Something inside it is moving."
	icon = 'Egg.dmi'
	density = 1
	Savable = 0
	ai_hostility = 0
	ai_wander = 0
	ai_team_fire = 0
	ko_death = 0
	var/tmp/obj/NamekEgg/shell_of
	var/tmp/shell_max_hp = 1

	New()
		..()
		ticking_ai -= src
		ai_state = "Idle"

	Update()
		return

	MaxHP()
		return shell_max_hp

	Unconscious(mob/P, text)
		if(shell_of)
			shell_of.NamekEggBreak(P)

	Death(mob/P, text, SuperDead = 0, NoRemains = 0, extraChance, fakeDeath)
		if(shell_of)
			shell_of.NamekEggBreak(P)

	proc/NamekShellSetup(mob/owner, obj/NamekEgg/E)
		shell_of = E
		shell_max_hp = max(1, owner.MaxHP() * NAMEK_EGG_HEALTH_SHARE)
		Health = shell_max_hp
		EndMod = owner.GetEnd()
		DefMod = 0.1
		SpdMod = 0.1
		Potential = owner.Potential
		potential_power_mult = owner.potential_power_mult
		ai_alliances = list()
		if(owner.ckey)
			ai_alliances += "[owner.ckey]"
		if(owner.party && owner.party.members)
			for(var/mob/m in owner.party.members)
				if(m.ckey)
					ai_alliances |= "[m.ckey]"
		passive_handler.Increase("NoDodge", 1)
		AIAvailablePower()
		ApplyPixelBounds()
		ApplyHurtbox()

/mob/proc/NamekReincarnationReady()
	if(!src.NamekReincarnationAt || src.NamekReincarnationAt > world.realtime)
		return 1
	return world.realtime >= src.NamekReincarnationAt + NAMEK_REINCARNATION_REALTIME

/mob/proc/NamekCanReincarnate(SuperDead, NoRemains, fakeDeath)
	if(!NamekIsNamek() || src.NamekPath != NAMEK_PATH_DEMON_KING || src.AscensionsAcquired < 3)
		return 0
	if(fakeDeath || SuperDead || NoRemains == 2 || src.NoVoid || src.Dead)
		return 0
	if(!isturf(src.loc) || !glob || !glob.VOID_LOCATION)
		return 0
	return NamekReincarnationReady()

/mob/proc/NamekFreshCorpse(turf/T)
	for(var/mob/Body/B in T)
		if(B.DeathKillerTargets == src.key && B.name == "Corpse of [src]")
			. = B

/mob/proc/NamekLayEgg(mob/P, text)
	var/turf/fell = src.loc
	var/by = P ? "[P]" : text
	src.OMessage(20, "[src] was just killed by [by]!", "<font color=red>[src] was just killed by [by]!")
	LogEvent("death", src, "[src] was killed by [text]", list(src, P), null, list("killer" = P ? "[P]" : "", "kkey" = (P && P.ckey) ? P.ckey : ""))
	if(src.IsGrabbed())
		src.IsGrabbed().Grab_Release()
	if(src.Grab)
		src.Grab_Release()
	FireKillHook(P)
	src.makeCorpse(fell)
	var/mob/Body/corpse = NamekFreshCorpse(fell)
	src.HollowWipeStatuses()
	src.NamekReincarnationAt = world.realtime
	src.MortallyWounded = 0
	src.KOTimer = 0
	src.KO = 0
	src.icon_state = ""
	src.SetHealthPct(NAMEK_HATCH_HEALTH_PCT)
	var/obj/NamekEgg/E = new(fell)
	E.NamekEggSetup(src, corpse)
	src.NamekEggPending = E
	src.NamekEggTurf = fell
	src.OMessage(20, "...but with their last breath, [src] spits out an egg!", "<font color=red>[src]([src.key]) lays a Reincarnation Egg.")
	src.loc = locate(glob.VOID_LOCATION[1], glob.VOID_LOCATION[2], glob.VOID_LOCATION[3])
	src.step_x = 0
	src.step_y = 0
	src << "<font color=#77cc77>Your old body is gone. Your egg hatches in [NAMEK_EGG_HATCH_TIME / 10] seconds unless someone destroys it.</font>"
	return E

/mob/proc/NamekAwaitEgg(obj/NamekEgg/E)
	while(E && !E.egg_broken && world.time < E.egg_hatch_at)
		E.NamekEggHome()
		sleep(2)
	if(E && !E.egg_broken)
		NamekEggHatch(E)
		return 0
	NamekEggLost(E)
	return 1

/mob/proc/NamekApplyNewborn()
	if(src.CheckSlotless("Namekian Newborn"))
		return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Newborn/B = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Newborn)
	if(!B || B.Using)
		return
	B.Trigger(src)

/mob/proc/NamekEggHatch(obj/NamekEgg/E)
	var/turf/T = get_turf(E)
	if(!T)
		T = src.NamekEggTurf
	src.NamekEggPending = null
	src.NamekEggTurf = null
	E.NamekEggClear()
	if(T)
		src.loc = T
		src.step_x = 0
		src.step_y = 0
	src.SetHealthPct(NAMEK_HATCH_HEALTH_PCT)
	src.MaxHealth()
	if(isplayer(src))
		src:move_speed = src.MovementSpeed()
	NamekApplyNewborn()
	NamekRegrowFX()
	src.OMessage(20, "[src] bursts out of the egg, reborn!", "<font color=red>[src]([src.key]) hatches from the Reincarnation Egg.")

/mob/proc/NamekEggLost(obj/NamekEgg/E)
	var/turf/T = E ? get_turf(E) : null
	if(!T)
		T = src.NamekEggTurf
	var/mob/Body/C = E ? E.egg_corpse : null
	src.NamekEggPending = null
	src.NamekEggTurf = null
	if(E)
		E.NamekEggClear()
	if(T)
		src.loc = T
		src.step_x = 0
		src.step_y = 0
	if(src.client && C)
		for(var/obj/Items/I in C)
			I.loc = src
		del C
	src.OMessage(20, "[src]'s egg is destroyed before it can hatch!", "<font color=red>[src]([src.key])'s Reincarnation Egg was destroyed.")

/mob/Players/Death(mob/P, var/text, var/SuperDead = 0, var/NoRemains = 0, extraChance, fakeDeath)
	if(src.NamekEggPending)
		return
	if(!NamekCanReincarnate(SuperDead, NoRemains, fakeDeath))
		return ..()
	var/obj/NamekEgg/E = NamekLayEgg(P, text)
	spawn()
		if(NamekAwaitEgg(E))
			..(P, text, SuperDead, NoRemains, extraChance, fakeDeath)
