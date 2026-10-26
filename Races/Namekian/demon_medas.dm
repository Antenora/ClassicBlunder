mob/var/tmp/list/NamekMedas

/obj/Skills/Utility/Namekian/Medas
	name = "Medas"
	desc = "Spit out four tiny clones of yourself that latch onto your target for ten seconds, draining its energy and nipping at it while they cling to it."
	Copyable = 0
	Cooldown = 60
	EnergyCost = 3
	var/MedaCount = 4
	var/MedaRange = 10
	var/MedaStatShare = 0.1
	var/MedaLifetime = 100
	var/MedaDrainPct = 3
	var/MedaDrainEvery = 10
	var/MedaStepDelay = 1
	var/MedaScale = 0.5

	verb/Medas()
		set name = "Medas"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			return
		User.NamekCastMedas(src)

/obj/Skills/AutoHit/Namekian/Meda_Bite
	name = "Meda Bite"
	Copyable = 0
	Area = "Target"
	Distance = 1
	StrScaling = 1
	DamageMult = 0.15
	Knockback = 0
	Cooldown = 1

/mob/proc/NamekCastMedas(obj/Skills/Utility/Namekian/Medas/M)
	if(!M || !src.CanUseSkill(M))
		return
	var/mob/T = src.Target
	if(!NamekFoeInReach(T, M.MedaRange, M))
		return
	M.Cooldown(1, null, src)
	NamekPayEnergy(M)
	NamekDismissMedas()
	src.OMessage(10, "[src] spits out a brood of tiny clones!", "<font color=red>[src]([src.key]) uses Medas on [T]([T.key]).")
	for(var/i = 1, i <= M.MedaCount, i++)
		var/mob/Player/AI/Namekian_Meda/D = new(src.loc)
		D.MedaInit(src, T, M)

/mob/proc/NamekDismissMedas()
	if(!src.NamekMedas)
		return
	for(var/mob/Player/AI/Namekian_Meda/D in src.NamekMedas.Copy())
		D.MedaVanish()
	src.NamekMedas = null

/mob/Player/AI/Namekian_Meda
	name = "Meda"
	density = 0
	Savable = 0
	ai_hostility = 0
	ai_wander = 0
	ai_team_fire = 0
	ko_death = 0
	var/tmp/mob/meda_target
	var/tmp/meda_until = 0
	var/tmp/meda_next_drain = 0
	var/tmp/meda_drain_pct = 0
	var/tmp/meda_drain_every = 10
	var/tmp/meda_step = 1
	var/tmp/obj/Skills/AutoHit/Namekian/Meda_Bite/meda_bite

	New()
		..()
		ticking_ai -= src
		ai_state = "Idle"

	Update()
		return

	Unconscious(mob/P, text)
		MedaVanish()

	Death(mob/P, text, SuperDead = 0, NoRemains = 0, extraChance, fakeDeath)
		MedaVanish()

	proc/MedaInit(mob/owner, mob/target, obj/Skills/Utility/Namekian/Medas/M)
		ai_owner = owner
		ai_alliances = list()
		if(owner.ckey)
			ai_alliances += "[owner.ckey]"
		meda_target = target
		meda_until = world.time + M.MedaLifetime
		meda_drain_pct = M.MedaDrainPct
		meda_drain_every = M.MedaDrainEvery
		meda_step = M.MedaStepDelay
		name = "[owner.name]'s Meda"
		icon = owner.icon
		overlays = owner.overlays
		var/matrix/S = matrix()
		S.Scale(M.MedaScale)
		transform = S
		StrMod = owner.StrMod * M.MedaStatShare
		EndMod = owner.EndMod * M.MedaStatShare
		ForMod = owner.ForMod * M.MedaStatShare
		OffMod = owner.OffMod * M.MedaStatShare
		DefMod = owner.DefMod * M.MedaStatShare
		SpdMod = owner.SpdMod * M.MedaStatShare
		VitMod = EndMod
		Potential = owner.Potential
		potential_power_mult = owner.potential_power_mult
		NextAttack = 0
		AIAvailablePower()
		SetHealthPct(100)
		meda_bite = new
		contents += meda_bite
		ApplyPixelBounds()
		ApplyHurtbox()
		SetTarget(target)
		if(!owner.NamekMedas)
			owner.NamekMedas = list()
		owner.NamekMedas += src
		owner.ai_followers += src
		spawn() MedaLoop()

	proc/MedaHolds()
		if(world.time >= meda_until || !ai_owner || ai_owner.KO || ai_owner.Dead)
			return 0
		if(!meda_target || !meda_target.loc || meda_target.Dead || meda_target.z != z)
			return 0
		return 1

	proc/MedaLoop()
		set waitfor = 0
		while(src && loc)
			if(!MedaHolds())
				MedaVanish()
				return
			if(get_dist(src, meda_target) > 1)
				step_to(src, meda_target, 1)
			else
				MedaLatch()
			sleep(meda_step)

	proc/MedaLatch()
		if(meda_target.KO || world.time < meda_next_drain)
			return
		meda_next_drain = world.time + meda_drain_every
		meda_target.LoseEnergy(meda_target.EnergyMax * meda_drain_pct / 100)
		if(meda_bite && !meda_bite.Using && !meda_bite.cooldown_remaining)
			if(Target != meda_target)
				SetTarget(meda_target)
			Activate(meda_bite)

	proc/MedaVanish()
		if(ai_owner)
			ai_owner.ai_followers -= src
			if(ai_owner.NamekMedas)
				ai_owner.NamekMedas -= src
		ai_owner = null
		meda_target = null
		loc = null
		spawn() del src
