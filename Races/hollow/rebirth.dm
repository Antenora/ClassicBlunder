datum
	hollow_shell
		var
			id
			label
			body_icon
			skill_path

		fishbone
			id = "fishbone"
			label = "Fishbone"
			body_icon = 'Zombie.dmi'
			skill_path = /obj/Skills/Grapple/Hollow/Bone_Crusher

		acidwire
			id = "acidwire"
			label = "Acidwire"
			body_icon = 'Snake.dmi'
			skill_path = /obj/Skills/AutoHit/Hollow/Acid_Lash

		shrieker
			id = "shrieker"
			label = "Shrieker"
			body_icon = 'Bat.dmi'
			skill_path = /obj/Skills/Projectile/Hollow/Leech_Bombs

		fisher
			id = "fisher"
			label = "Grand Fisher"
			body_icon = 'WildHound.dmi'
			skill_path = /obj/Skills/AutoHit/Hollow/Hair_Spears

		hexapod
			id = "hexapod"
			label = "Hexapodus"
			body_icon = 'Devil_Imp.dmi'
			skill_path = /obj/Skills/AutoHit/Hollow/Pounce

		bulbous
			id = "bulbous"
			label = "Bulbous"
			body_icon = 'Bone Kobold.dmi'
			skill_path = /obj/Skills/AutoHit/Hollow/Burrow_Strike

var/global/list/hollow_shell_registry = list()

/proc/HollowShellRegistry()
	if(!hollow_shell_registry.len)
		for(var/T in subtypesof(/datum/hollow_shell))
			var/datum/hollow_shell/S = new T
			if(S.id)
				hollow_shell_registry[S.id] = S
	return hollow_shell_registry

/proc/HollowShellDatum(id)
	if(!id)
		return null
	var/list/R = HollowShellRegistry()
	return R[id]

/mob/proc/HollowRollShell()
	if(!HollowIsHollow())
		return
	var/list/R = HollowShellRegistry()
	var/list/pool = list()
	for(var/k in R)
		if(k != src.HollowShell)
			pool += k
	if(!pool.len)
		return
	var/datum/hollow_shell/old = HollowShellDatum(src.HollowShell)
	if(old && old.skill_path)
		var/obj/Skills/gone = locate(old.skill_path, src)
		if(gone)
			src.DeleteSkill(gone)
	src.HollowShell = pick(pool)
	var/datum/hollow_shell/fresh = HollowShellDatum(src.HollowShell)
	if(fresh && fresh.skill_path && !locate(fresh.skill_path, src))
		src.AddSkill(new fresh.skill_path)
	src.HollowApplyBody()

/mob/proc/HollowWipeStatuses()
	src.Poison = 0
	src.SilentPoisonAmount = 0
	src.Burn = 0
	src.SilentBurnAmount = 0
	src.Bleed = 0
	src.Slow = 0
	src.Shatter = 0
	src.HardenAccumulated = 0
	src.Shock = 0
	src.Drenched = 0
	src.Exposed = 0
	src.Sheared = 0
	src.Crippled = 0
	src.HealthCut = 0
	src.EnergyCut = 0
	src.TotalInjury = 0
	src.TotalFatigue = 0
	src.OverClockNerf = 0
	src.OverClockTime = 0
	src.BPPoison = 1
	src.BPPoisonTimer = 0
	src.MortallyWounded = 0
	src.StrTax = 0
	src.StrCut = 0
	src.StrStolen = 0
	src.StrEroded = 0
	src.EndTax = 0
	src.EndCut = 0
	src.EndStolen = 0
	src.EndEroded = 0
	src.SpdTax = 0
	src.SpdCut = 0
	src.SpdStolen = 0
	src.SpdEroded = 0
	src.ForTax = 0
	src.ForCut = 0
	src.ForStolen = 0
	src.ForEroded = 0
	src.OffTax = 0
	src.OffCut = 0
	src.OffStolen = 0
	src.OffEroded = 0
	src.DefTax = 0
	src.DefCut = 0
	src.DefStolen = 0
	src.DefEroded = 0
	src.RecovTax = 0
	src.RecovCut = 0

/mob/proc/HollowMoveToNest()
	var/list/nests = list()
	for(var/obj/HollowNest/N in world)
		if(isturf(N.loc))
			nests += N
	if(!nests.len)
		return 0
	var/obj/HollowNest/pick_nest = pick(nests)
	src.loc = pick_nest.loc
	src.step_x = 0
	src.step_y = 0
	return 1

/mob/proc/HollowApplyNewborn()
	if(!HollowIsHollow())
		return
	if(src.CheckSlotless("Newborn"))
		return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hollow_Newborn/B = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hollow_Newborn)
	if(!B || B.Using)
		return
	B.Trigger(src)

/mob/proc/HollowIsNewborn()
	return src.CheckSlotless("Newborn")

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Hollow_Newborn
	BuffName = "Newborn"
	TimerLimit = HOLLOW_NEWBORN_SECONDS
	CooldownStatic = 1
	Cooldown = 0
	StrMult = HOLLOW_NEWBORN_MULT
	EndMult = HOLLOW_NEWBORN_MULT
	ForMult = HOLLOW_NEWBORN_MULT
	OffMult = HOLLOW_NEWBORN_MULT
	DefMult = HOLLOW_NEWBORN_MULT
	SpdMult = HOLLOW_NEWBORN_MULT
	ActiveMessage = "pulls itself together, raw and half formed."
	OffMessage = "has finished forming."

/mob/Players/Death(mob/P, var/text, var/SuperDead = 0, var/NoRemains = 0, extraChance, fakeDeath)
	if(!src.HollowIsHollow() || !src.HollowDeathRegen || fakeDeath || SuperDead || src.NoVoid)
		return ..()
	if(src.HollowReforming)
		return
	src.HollowReforming = 1
	src.OMessage(20, "[src] was just killed by [text]!", "<font color=red>[src] was just killed by [text]!")
	src.HollowCountDeath(P)
	var/turf/fell = src.loc
	if(isturf(fell))
		src.makeCorpse(fell)
	sleep(20)
	if(!src)
		return
	src.MortallyWounded = 0
	src.KOTimer = 0
	src.KO = 0
	src.icon_state = ""
	src.Conscious()
	src.HollowWipeStatuses()
	if(!src.HollowMoveToNest())
		Log("Admin", "[ExtractInfo(src)] had no Hollow Nest has been placed in the world.", 1)
		sleep(HOLLOW_NO_NEST_DELAY)
		if(!src)
			return
	src.HealWounds(99999)
	src.SetHealthPct(100)
	src.MaxHealth()
	src.Energy = src.EnergyMax
	src.MaxEnergy()
	src.ManaAmount = src.ManaCap()
	src.MaxMana()
	if(src.HollowStage == HOLLOW_STAGE_BASE)
		src.HollowRollShell()
	src.HollowApplyNewborn()
	src.HollowSyncSkills()
	src.HollowReforming = 0
	OMsg(src, "<b><font color=#9b59b6>[src] drags itself out of the sand.</font></b>")

mob/var/tmp/HollowReforming = 0
