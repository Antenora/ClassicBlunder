mob
	var
		HollowStage
		HollowArrancar = 0
		HollowDeathRegen = 0
		HollowShell
		HollowEvoApplied = 0
		HollowPoints = 0
		HollowCountedDeaths = 0
		HollowCountedDevours = 0
		HollowLastCountedAt = 0
		list/HollowKillerLog = list()
		HollowVastoRolled = 0
		HollowResId
		HollowSpec

/mob/proc/HollowIsHollow()
	return src.race && src.isRace(HOLLOW)

/mob/proc/HollowSyncPower()
	if(!HollowIsHollow())
		return
	var/target = HollowClassShare(src) * HollowEvolutionLadder(src.Potential)
	var/delta = target - src.HollowEvoApplied
	if(!delta)
		return
	var/list/move = list("MagnifiedStr" = delta, "MagnifiedEnd" = delta, "MagnifiedFor" = delta, "MagnifiedSpd" = delta, "MagnifiedOff" = delta, "MagnifiedDef" = delta)
	src.passive_handler.increaseList(move)
	src.HollowEvoApplied = target

/mob/proc/HollowSyncSkills()
	if(!HollowIsHollow())
		return
	var/list/want = src.HollowStageSkillSet()
	var/list/owned = list()
	for(var/T in HollowManagedSkillTypes())
		var/obj/Skills/have = locate(T, src)
		if(have)
			owned += T
		if((T in want) && !have)
			src.AddSkill(new T)
		else if(!(T in want) && have)
			src.DeleteSkill(have)
	if(src.client)
		src.client.RefreshHotbar()

/proc/HollowManagedSkillTypes()
	var/list/out = list()
	var/list/abstract = list(/obj/Skills/AutoHit/Hollow, /obj/Skills/Grapple/Hollow, /obj/Skills/Projectile/Hollow, /obj/Skills/Projectile/Beams/Big/Hollow, /obj/Skills/Hollow)
	for(var/T in typesof(/obj/Skills/AutoHit/Hollow, /obj/Skills/Grapple/Hollow, /obj/Skills/Projectile/Hollow, /obj/Skills/Projectile/Beams/Big/Hollow, /obj/Skills/Hollow))
		if(T in abstract)
			continue
		out += T
	return out

/mob/proc/HollowSetStage(id)
	if(!HollowIsHollow() || !id || src.HollowStage == id)
		return
	var/was = src.HollowStage
	src.HollowStage = id
	if(id == HOLLOW_STAGE_VASTO && was != HOLLOW_STAGE_VASTO)
		src.StrMod += HOLLOW_VASTO_MOD_ENTRY
		src.EndMod += HOLLOW_VASTO_MOD_ENTRY
		src.ForMod += HOLLOW_VASTO_MOD_ENTRY
		src.OffMod += HOLLOW_VASTO_MOD_ENTRY
		src.DefMod += HOLLOW_VASTO_MOD_ENTRY
		src.SpdMod += HOLLOW_VASTO_MOD_ENTRY
		src.PotentialRate = HOLLOW_VASTO_POWER
		var/steps = max(0, src.AscensionsAcquired - 3)
		if(steps)
			var/bonus = HOLLOW_VASTO_MOD_STEP * steps
			src.StrMod += bonus
			src.EndMod += bonus
			src.ForMod += bonus
			src.OffMod += bonus
			src.DefMod += bonus
			src.SpdMod += bonus
	src.HollowApplyBody()
	src.HollowSyncPower()
	src.HollowSyncSkills()
	src.MaxHealth()
	src.MaxEnergy()
	src.MaxMana()

/mob/proc/HollowBecomeArrancar(kind)
	if(!HollowIsHollow() || src.HollowArrancar)
		return 0
	src.HollowArrancar = kind
	src.HollowDeathRegen = 0
	src.HollowVastoRolled = 1
	src.HollowSyncPower()
	src.HollowSyncSkills()
	return 1

/mob/proc/HollowApplyBody()
	if(!HollowIsHollow())
		return
	var/icon/want = HollowBodyIcon(src)
	if(want && src.icon != want)
		src.icon = want
		src.AppearanceOn()

/proc/HollowBodyIcon(mob/m)
	if(!m)
		return null
	switch(m.HollowStage)
		if(HOLLOW_STAGE_GILLIAN)
			return 'Deep_One.dmi'
		if(HOLLOW_STAGE_ADJUCHAS)
			return 'WolfBeast.dmi'
		if(HOLLOW_STAGE_VASTO)
			return 'Chaos_Chosen.dmi'
	var/datum/hollow_shell/S = HollowShellDatum(m.HollowShell)
	if(S && S.body_icon)
		return S.body_icon
	return 'Zombie.dmi'

/mob/Players/CheckAscensions()
	..()
	if(HollowIsHollow())
		HollowSyncPower()
		HollowSyncSkills()

/obj/Skills/Hollow/Awaken
	name = "Awaken"
	desc = "Gain sapience and become an Adjuchas."

	verb/Awaken()
		set name = "Awaken"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(!User.HollowIsHollow())
			return
		if(!User.HollowDeathRegen)
			User << "<font color=red>You have already awoken.</font>"
			return
		if(User.AscensionsAcquired < 2)
			User << "<font color=red>You are not hollow enough yet. Ascend further first.</font>"
			return
		var/choice = Ask(User, "Awaken as an Adjuchas? You gain a true mind and a true self, and the Menos horde loses its hold on you. In exchange your endless rebirth ends here: from this moment your death permanent.", "Awaken", null, "confirm", null, 1, "Awaken", "Not yet")
		if(choice != "Awaken")
			return
		spawn()
			if(!User || !User.HollowDeathRegen)
				return
			User.HollowDeathRegen = 0
			OMsg(User, "<b><font color=#9b59b6>[User]'s mask splits and reknits into something that thinks.</font></b>")
			User.HollowSetStage(HOLLOW_STAGE_ADJUCHAS)
			User.HollowVastoRollCheck()
