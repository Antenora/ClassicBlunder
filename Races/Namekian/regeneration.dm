/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Regeneration
	name = "Namekian Regeneration"
	AlwaysOn = 1
	doNotDelete = 1
	Cooldown = 0
	Copyable = 0
	var/RegenQuiet = 80
	var/RegenEvery = 10
	var/RegenHealPct = 1
	var/RegenWoundPct = 0.1
	var/tmp/regen_next = 0

	GainLoop(mob/source)
		..()
		if(source && world.time >= regen_next)
			regen_next = world.time + RegenEvery
			source.NamekRegenTick(src)

/mob/proc/NamekQuietSince()
	return max(src.last_damaged_time, src.lastHit, src.combat_until - glob.COMBAT_WINDOW)

/mob/proc/NamekRegenTick(obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Regeneration/B)
	if(!B || !NamekIsNamek() || src.KO || src.Dead)
		return
	if(world.time < NamekQuietSince() + B.RegenQuiet)
		return
	if(src.Health < src.HealthCeiling())
		src.HealPct(B.RegenHealPct)
		src.MaxHealth()
	if(src.TotalInjury > 0)
		src.HealWounds(B.RegenWoundPct)

/mob/proc/NamekRegrowFX()
	KenShockwave(src, Size = 0.5)

/obj/Skills/Utility/Namekian

/obj/Skills/Utility/Namekian/Regrow
	name = "Regrow"
	desc = "Channel for three seconds to regrow your body: heals, clears every maim, and costs energy and fatigue. Only hard crowd control breaks the channel."
	Copyable = 0
	Cooldown = 60
	EnergyCost = 15
	FatigueCost = 10
	var/RegrowChannel = 30
	var/RegrowBasePct = 20
	var/RegrowPerAscPct = 5

	verb/Regrow()
		set name = "Regrow"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		src.adjust(User)
		User.NamekRegrowStart(src)

/mob/proc/NamekRegrowStart(obj/Skills/Utility/Namekian/Regrow/R)
	if(!R || R.Using || R.cooldown_remaining)
		return
	if(src.KO || src.Dead)
		return
	if(src.ccActive())
		src << "You cannot regrow while you are held down."
		return
	if(src.Energy < R.EnergyCost)
		src << "You lack the energy to regrow."
		return
	R.Using = 1
	src.OMessage(10, "[src] begins to regrow their body...", "<font color=red>[src]([src.key]) begins Regrow.")
	spawn()
		NamekRegrowChannel(R)

/mob/proc/NamekRegrowChannel(obj/Skills/Utility/Namekian/Regrow/R)
	var/until = world.time + R.RegrowChannel
	while(world.time < until)
		if(!src || !R)
			return
		if(src.KO || src.ccActive())
			R.Using = 0
			src << "Your regrowth is interrupted!"
			return
		sleep(1)
	if(!src || !R)
		return
	R.Using = 0
	src.LoseEnergy(R.EnergyCost)
	src.GainFatigue(R.FatigueCost)
	src.HealPct(R.RegrowBasePct + R.RegrowPerAscPct * src.AscensionsAcquired)
	src.MaxHealth()
	src.MaimClearAll()
	NamekRegrowFX()
	src.OMessage(10, "[src]'s body knits itself whole again!", "<font color=red>[src]([src.key]) finishes Regrow.")
	R.Cooldown(1, null, src)

/mob/proc/NamekReconstituteReady()
	if(!src.NamekReconstituteAt || src.NamekReconstituteAt > world.time)
		return 1
	return world.time >= src.NamekReconstituteAt + NAMEK_RECONSTITUTE_COOLDOWN

/mob/proc/NamekCanReconstitute(mob/P)
	if(!NamekIsNamek() || src.KO || src.mech)
		return 0
	if(!ismob(P) || P == src || P.Lethal)
		return 0
	if(src.NoVoid)
		return 0
	if(src.Energy < src.EnergyMax * NAMEK_RECONSTITUTE_ENERGY_PCT / 100)
		return 0
	return NamekReconstituteReady()

/mob/proc/NamekReconstitute(mob/P)
	src.NamekReconstituteAt = world.time
	src.Energy = max(0, src.Energy - src.EnergyMax * NAMEK_RECONSTITUTE_ENERGY_PCT / 100)
	src.SetHealthPct(NAMEK_RECONSTITUTE_HEALTH_PCT)
	src.MaxHealth()
	src.OMessage(15, "...but [src] reconstitutes their body and stays on their feet!", "<font color=red>[src]([src.key]) reconstitutes against [P]([P.key]).")
	NamekRegrowFX()

/mob/Players/Unconscious(mob/P, text)
	if(NamekCanReconstitute(P))
		NamekReconstitute(P)
		return
	return ..()
