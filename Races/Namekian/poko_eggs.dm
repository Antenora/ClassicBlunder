#define NAMEK_POKO_HATCH_FACTOR 0.55
#define NAMEK_POKO_HATCH_SHARE 0.35
#define NAMEK_POKO_EGG_CHANNEL 20
#define NAMEK_POKO_EGG_HATCH 30
#define NAMEK_POKO_LEASH 12
#define NAMEK_POKO_THINK 10

/proc/NamekPokoLadder(mob/P)
	if(!P)
		return 1
	var/ladder = NamekLadderBody(P.Potential)
	if(P.NamekPokoFormActive())
		ladder += NamekLadderForm(P.Potential)
	return 1 + NAMEK_POKO_HATCH_SHARE * ladder

/proc/NamekPokoPowerMult(mob/P)
	temp_potential_power(P)
	return P.potential_power_mult * NAMEK_POKO_HATCH_FACTOR

/proc/NamekPokoOpenTurf(turf/T)
	if(!T || T.density)
		return 0
	for(var/atom/movable/A in T)
		if(A.density)
			return 0
	return 1

/mob/proc/NamekPokoFormActive()
	if(!src.race || !islist(src.race.transformations))
		return 0
	for(var/transformation/namekian/t in src.race.transformations)
		if(t.is_active)
			return 1
	return 0

/mob/proc/NamekPokoEggSpot()
	var/list/dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	if(src.dir)
		dirs.Insert(1, src.dir)
	for(var/d in dirs)
		var/turf/T = get_step(src, d)
		if(NamekPokoOpenTurf(T))
			return T
	return null

/mob/proc/NamekPokoAlliances()
	var/list/out = list()
	if(src.ckey)
		out += "[src.ckey]"
	if(src.party && src.party.members)
		for(var/mob/m in src.party.members)
			if(m.ckey)
				out |= "[m.ckey]"
	return out

/mob/proc/NamekPokoOwnerFit()
	if(src.KO || src.Dead)
		return 0
	if(!src.client && src.key)
		return 0
	return 1

/mob/proc/NamekPokoMode()
	var/obj/Skills/Companion/C = locate(/obj/Skills/Companion/Namekian/Hatchling_Commands) in src
	if(C && C.companion_mode == "Manual")
		return "Manual"
	return "Auto"

/mob/proc/NamekPokoDismiss(quiet = 0)
	var/mob/Player/AI/Namek_Hatchling/H = src.NamekHatchling
	if(!istype(H))
		src.NamekHatchling = null
		return 0
	H.NamekPokoDespawn(quiet ? null : "[H] fades back into ki.")
	return 1

/mob/proc/NamekPokoEggStart(obj/Skills/Companion/Namekian/Hatchling/S)
	if(!NamekCastReady(S))
		return
	var/drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	if(src.Energy < S.PokoEggEnergy(src))
		src << "You don't have enough energy to use [S]."
		return
	if(!NamekPokoEggSpot())
		src << "There is no open ground beside you to lay [S]."
		return
	S.Using = 1
	spawn()
		NamekPokoEggCast(S)

/mob/proc/NamekPokoEggCast(obj/Skills/Companion/Namekian/Hatchling/S)
	src.OMessage(10, "[src] gathers ki into a glowing egg...", "<font color=green>[src]([src.key]) begins [S].")
	if(!NamekChannel(S, NAMEK_POKO_EGG_CHANNEL, null))
		return
	var/drain = NamekManaDrain(S)
	if(!NamekHasMana(S, drain))
		return
	var/energy = S.PokoEggEnergy(src)
	if(src.Energy < energy)
		src << "You don't have enough energy to use [S]."
		return
	var/turf/T = NamekPokoEggSpot()
	if(!T)
		src << "There is no open ground beside you to lay [S]."
		return
	NamekSpendMana(drain)
	src.LoseEnergy(energy)
	S.Cooldown(1, null, src)
	var/obj/NamekEgg/Poko/E = new(T)
	E.PokoEggSetup(src, S)
	src.OMessage(10, "[src] spits out an egg!", "<font color=green>[src]([src.key]) lays a [S.PokoHatchName] egg with [S].")

/mob/Players/CheckAscensions()
	..()
	if(src.NamekHatchling)
		NamekResyncHatchling(src)

/obj/NamekEgg/Poko
	name = "Poko Egg"
	desc = "A warm egg spat out by a Poko Priest. Something inside is about to hatch."
	icon = 'Icons/Characters/Special/Egg.dmi'
	density = 1
	invisibility = 0
	mouse_opacity = 1
	Attackable = 1
	Destructable = 0
	Health = 1
	var/tmp/mob/poko_owner
	var/tmp/obj/Skills/Companion/Namekian/Hatchling/poko_skill
	var/tmp/poko_done = 0

	proc/PokoEggSetup(mob/P, obj/Skills/Companion/Namekian/Hatchling/S)
		poko_owner = P
		poko_skill = S
		autohit_obj_listeners |= src
		spawn(NAMEK_POKO_EGG_HATCH)
			if(src)
				PokoEggHatch()

	proc/PokoEggGone()
		poko_done = 1
		autohit_obj_listeners -= src
		poko_owner = null
		poko_skill = null
		loc = null

	proc/PokoEggFoe(mob/A)
		if(!ismob(A))
			return 0
		var/mob/P = poko_owner
		if(!ismob(P))
			return 1
		if(A == P || P.NamekIsAlly(A))
			return 0
		if(istype(A, /mob/Player/AI))
			var/mob/Player/AI/ai = A
			if(ai.ai_owner && (ai.ai_owner == P || P.NamekIsAlly(ai.ai_owner)))
				return 0
		return 1

	proc/PokoEggCrack(mob/A)
		if(poko_done)
			return 0
		var/mob/P = poko_owner
		if(loc)
			KenShockwave(loc, Size = 0.3)
		if(ismob(P))
			P.OMessage(10, "[A] smashes [P]'s egg before it can hatch!", "<font color=red>[A] destroyed [P]([P.key])'s egg.")
		PokoEggGone()
		return 1

	proc/PokoEggHatch()
		if(poko_done || !loc)
			return
		var/mob/P = poko_owner
		var/obj/Skills/Companion/Namekian/Hatchling/S = poko_skill
		var/turf/T = get_turf(src)
		PokoEggGone()
		if(!ismob(P) || !S || !T || S.loc != P || !P.NamekPokoOwnerFit())
			if(ismob(P))
				P << "Your egg crumbles before it can hatch."
			return
		P.NamekPokoDismiss(1)
		S.PokoHatch(P, T)

	onBumped(atom/Obstacle)
		if(istype(Obstacle, /obj/Skills/Projectile/_Projectile))
			var/obj/Skills/Projectile/_Projectile/B = Obstacle
			if(poko_done || B.Killed || B.Distance < 0 || !PokoEggFoe(B.Owner))
				return
			PokoEggCrack(B.Owner)
			B.ProjectileFinish()
			return
		..()

	StruckByMelee(mob/A, dmg)
		if(poko_done || !PokoEggFoe(A))
			return 0
		return PokoEggCrack(A)

	StruckByAutoHit(mob/A)
		if(poko_done || !PokoEggFoe(A))
			return 0
		return PokoEggCrack(A)

/obj/Skills/Companion/Namekian

/obj/Skills/Companion/Namekian/Hatchling_Commands
	name = "Hatchling Commands"
	desc = "Command your hatchling: Attack, Stop, Follow, Focus Target, Mode, Def, Stay and Dismiss. One hatchling at most is ever out."
	Copyable = 0

	New()
		..()
		verbs -= /obj/Skills/Companion/verb/Companion_Summon
		verbs -= /obj/Skills/Companion/verb/CustomizeCompanion

	verb/Companion_Dismiss()
		set src in usr
		set category = "Companion"
		set name = "Companion Dismiss"
		var/mob/User = usr
		if(!User.NamekPokoDismiss())
			User << "You have no hatchling out."

/obj/Skills/Companion/Namekian/Hatchling
	Copyable = 0
	Cooldown = 90
	ManaCost = 25
	companion_team_fire = 0
	var/tmp/PokoEnergyPct = 10
	var/tmp/PokoHatchName = "Hatchling"
	var/tmp/list/PokoProfile = list(1, 1, 1, 1, 1, 1)
	var/tmp/list/PokoTechniques = list()
	var/tmp/list/PokoPassives = list()
	var/tmp/PokoIcon = 'Icons/NPCS/Dragons/Green Dragon.dmi'
	var/tmp/PokoIconState = ""
	var/tmp/PokoPixelX = 0
	var/tmp/PokoPixelY = 0

	New()
		..()
		verbs -= list(/obj/Skills/Companion/verb/Companion_Summon, /obj/Skills/Companion/verb/Companion_Attack, /obj/Skills/Companion/verb/Companion_Stop, /obj/Skills/Companion/verb/Companion_Follow, /obj/Skills/Companion/verb/Companion_Focus_Target, /obj/Skills/Companion/verb/Companion_Mode, /obj/Skills/Companion/verb/Companion_Def, /obj/Skills/Companion/verb/Companion_Stay, /obj/Skills/Companion/verb/CustomizeCompanion)

	proc/PokoEggEnergy(mob/P)
		return P.EnergyMax * PokoEnergyPct / 100

	proc/PokoHatch(mob/P, turf/T)
		var/mob/Player/AI/Namek_Hatchling/a = new
		ticking_ai.Remove(a)
		a.alpha = 0
		a.loc = T
		animate(a, alpha = 255, time = 10)
		a.ai_owner = P
		a.poko_skill = src
		a.ai_follow = 1
		a.name = PokoHatchName
		a.icon = PokoIcon
		a.icon_state = PokoIconState
		a.pixel_x = PokoPixelX
		a.pixel_y = PokoPixelY
		a.NamekPokoApplyMode(P.NamekPokoMode())
		a.companion_def_mode = 0
		a.prev_owner_health = P.Health
		a.ai_spammer = companion_skill_aggression
		a.ko_death = companion_ko_death
		a.Timeless = 1
		a.ai_team_fire = companion_team_fire
		a.ai_alliances = P.NamekPokoAlliances()
		P.ai_followers += a
		P.NamekHatchling = a
		companion_ais += a
		for(var/path in PokoTechniques)
			if(ispath(path))
				a.AddSkill(new path)
		if(PokoPassives.len)
			a.passive_handler.increaseList(PokoPassives)
		a.NamekHatchResync(1)
		a.aiGain()
		P.OMessage(10, "[a] hatches and leaps to [P]'s side!", "<font color=green>[P]([P.key]) hatched a [a].")

/obj/Skills/Companion/Namekian/Hatchling/land_dragon
	name = "Dragon God's Fury"
	desc = "Channel for two seconds, then spit an egg beside you. Three seconds later a Land Dragon hatches: a sturdy tank that provokes your foes and washes debuffs off you. A hit on the egg breaks it, and only one hatchling is ever out."
	PokoHatchName = "Land Dragon"
	PokoProfile = list(1, 1.2, 0.6, 0.9, 1.2, 0.8)
	PokoTechniques = list(/obj/Skills/Utility/Namekian/Hatchling/Provoke, /obj/Skills/Utility/Namekian/Hatchling/Cleanse_Owner)
	PokoPassives = list("Harden" = 2)
	PokoIcon = 'Icons/NPCS/Dragons/Green Dragon.dmi'

	verb/Dragon_Gods_Fury()
		set name = "Dragon Gods Fury"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoEggStart(src)

/obj/Skills/Companion/Namekian/Hatchling/sky_dragon
	name = "Dragon God's Rage"
	desc = "Channel for two seconds, then spit an egg beside you. Three seconds later a Sky Dragon hatches: a winged damage dealer with a mouth wave, a diving strike and a battle cry. A hit on the egg breaks it, and only one hatchling is ever out."
	PokoHatchName = "Sky Dragon"
	PokoProfile = list(0.9, 0.8, 1.2, 1.1, 0.8, 1.1)
	PokoTechniques = list(/obj/Skills/Projectile/Namekian/Hatchling/Mouth_Energy_Wave, /obj/Skills/AutoHit/Namekian/Hatchling/Dive, /obj/Skills/Utility/Namekian/Hatchling/Battle_Cry)
	PokoIcon = 'Icons/NPCS/Dragons/Red Dragon.dmi'

	verb/Dragon_Gods_Rage()
		set name = "Dragon Gods Rage"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoEggStart(src)

/obj/Skills/Companion/Namekian/Hatchling/tambourine
	name = "Dark Vassal's Hunt"
	desc = "Channel for two seconds, then spit an egg beside you. Three seconds later a Tambourine-type hatches: a winged assassin that marks your target to take more damage from you both. A hit on the egg breaks it, and only one hatchling is ever out."
	PokoHatchName = "Tambourine"
	PokoProfile = list(1, 0.7, 0.9, 1.2, 0.7, 1.3)
	PokoTechniques = list(/obj/Skills/Utility/Namekian/Hatchling/Demon_Mark, /obj/Skills/Projectile/Namekian/Hatchling/Mouth_Energy_Wave, /obj/Skills/Queue/Namekian/Hatchling/Super_Marengeki)
	PokoIcon = 'Icons/NPCS/Horrors/Devil_Imp.dmi'

	verb/Dark_Vassals_Hunt()
		set name = "Dark Vassals Hunt"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoEggStart(src)

/obj/Skills/Companion/Namekian/Hatchling/cymbal
	name = "Dark Vassal's Storm"
	desc = "Channel for two seconds, then spit an egg beside you. Three seconds later a Cymbal-type hatches: a ranged dragon that fires stunning shocks and bursts of ki bullets. A hit on the egg breaks it, and only one hatchling is ever out."
	PokoHatchName = "Cymbal"
	PokoProfile = list(0.7, 0.9, 1.3, 1, 1, 0.9)
	PokoTechniques = list(/obj/Skills/Projectile/Namekian/Hatchling/Electric_Shock_Wave, /obj/Skills/Projectile/Namekian/Hatchling/Energy_Bullets)
	PokoIcon = 'Icons/NPCS/Dragons/Blue Dragon.dmi'

	verb/Dark_Vassals_Storm()
		set name = "Dark Vassals Storm"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoEggStart(src)

/obj/Skills/Companion/Namekian/Hatchling/drum
	name = "Dark Vassal's Wrath"
	desc = "Channel for two seconds, then spit an egg beside you. Three seconds later a Drum-type hatches: a brute bodyguard that plants itself in front of you and crushes your foes. A hit on the egg breaks it, and only one hatchling is ever out."
	PokoHatchName = "Drum"
	PokoProfile = list(1.3, 1.2, 0.5, 1, 1.1, 0.8)
	PokoTechniques = list(/obj/Skills/Queue/Namekian/Hatchling/Crushing_Blow, /obj/Skills/Utility/Namekian/Hatchling/Body_Block)
	PokoPassives = list("Juggernaut" = 2)
	PokoIcon = 'Icons/NPCS/Monster/Kobold King.dmi'

	verb/Dark_Vassals_Wrath()
		set name = "Dark Vassals Wrath"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoEggStart(src)

/mob/Player/AI/Namek_Hatchling
	var/tmp/obj/Skills/Companion/Namekian/Hatchling/poko_skill
	var/tmp/poko_next_think = 0
	var/tmp/poko_last_tick = 0
	var/tmp/poko_gone = 0

	Update()
		set waitfor = 0
		if(poko_gone)
			return
		if(!NamekPokoKeeps())
			NamekPokoDespawn(KO ? "[src] collapses and fades into ki." : "[src] fades back into ki.")
			return
		NamekPokoTickBuffs()
		NamekPokoLeash()
		if(world.time >= poko_next_think)
			poko_next_think = world.time + NAMEK_POKO_THINK
			NamekPokoThink()
		..()

	Del()
		var/mob/P = ai_owner
		if(P)
			P.ai_followers -= src
			if(P.NamekHatchling == src)
				P.NamekHatchling = null
		companion_ais -= src
		..()

	Chase()
		if(!Target)
			ai_state = "Idle"
			return
		if(!isAI(Target))
			return ..()
		if(!NamekPokoFightsAI(Target))
			RemoveTarget()
			ai_state = "Idle"
			return
		if(isCrowdControlled())
			return
		ai_state = "Chase"
		if(Target.KO || Target.Dead)
			RemoveTarget()
			ai_state = "Idle"
			return
		if(Target.WindingUp || Target.AutoHitting)
			Flee()
			return
		fleeing = FALSE
		var/dist = get_dist(src, Target)
		GoAfterTarget()
		if(dist <= 10)
			dir = get_dir(src, Target)
			Attack(dist <= 1 ? "melee" : "ranged")
			last_activity = world.time
			return
		if(dist >= ai_vision * 5 && last_activity + 300 < world.time)
			RemoveTarget()
			ai_state = "Idle"
			return
		Attack("ranged")
		last_activity = world.time

	AIAvailablePower()
		var/mob/P = ai_owner
		..()
		if(!ismob(P))
			return
		var/used = potential_power_mult
		var/want = NamekPokoPowerMult(P)
		if(used > 0)
			Power *= want / used
		potential_power_mult = want

	MechDealtMult(mob/defender, strike/S)
		. = ..()
		var/mob/P = ai_owner
		if(P && defender && defender.mark_vuln_by == P && defender.mark_vuln_until > world.time)
			. *= 1 + defender.mark_vuln_amp

	proc/NamekPokoFightsAI(mob/Player/AI/A)
		if(!istype(A) || A.ai_owner)
			return 0
		return !AllianceCheck(A)

	proc/NamekPokoApplyMode(mode)
		if(mode == "Manual")
			ai_hostility = 0
			ai_focus_owner_target = 0
			ai_protection = 0
		else
			ai_hostility = 1
			ai_focus_owner_target = 1
			ai_protection = 20

	proc/NamekPokoKeeps()
		var/mob/P = ai_owner
		if(!ismob(P) || P.NamekHatchling != src || !P.NamekPokoOwnerFit())
			return 0
		if(KO || Dead || !loc)
			return 0
		if(!poko_skill || poko_skill.loc != P)
			return 0
		return 1

	proc/NamekPokoDespawn(msg)
		if(poko_gone)
			return
		poko_gone = 1
		var/mob/P = ai_owner
		if(P)
			P.ai_followers -= src
			if(P.NamekHatchling == src)
				P.NamekHatchling = null
			if(msg)
				P.OMessage(10, msg, "<font color=green>[P]([P.key])'s [src] is gone.")
		companion_ais -= src
		ticking_ai -= src
		ai_owner = null
		RemoveTarget()
		animate(src, alpha = 0, time = 10)
		spawn(10)
			if(src)
				del src

	proc/NamekPokoTickBuffs()
		var/now = world.time
		var/dt = poko_last_tick ? (now - poko_last_tick) / 10 : 0
		poko_last_tick = now
		if(dt <= 0 || !SlotlessBuffs || !SlotlessBuffs.len)
			return
		for(var/sb in SlotlessBuffs.Copy())
			var/obj/Skills/Buffs/B = SlotlessBuffs[sb]
			if(!istype(B) || !B.TimerLimit || !B.SlotlessOn)
				continue
			if(!isnum(B.Timer))
				B.Timer = 0
			B.Timer += dt
			if(B.Timer >= B.TimerLimit)
				B.Trigger(src, Override = 1)

	proc/NamekPokoLeash()
		var/mob/P = ai_owner
		if(hold_position)
			return
		if(P.z == z && get_dist(src, P) <= NAMEK_POKO_LEASH)
			return
		var/turf/T = P.NamekPokoEggSpot()
		if(!T)
			T = get_turf(P)
		if(!T)
			return
		loc = T
		step_x = 0
		step_y = 0
		RemoveTarget()
		ai_state = "Idle"

	proc/NamekPokoThink()
		var/mob/P = ai_owner
		ai_alliances = P.NamekPokoAlliances()
		if(KO || isCrowdControlled())
			return
		for(var/obj/Skills/Utility/Namekian/Hatchling/S in src)
			if(S.Using || S.cooldown_remaining)
				continue
			if(S.HatchAct(src))
				return

	proc/NamekHatchResync(fresh = 0)
		var/mob/P = ai_owner
		var/obj/Skills/Companion/Namekian/Hatchling/S = poko_skill
		if(!ismob(P) || !S)
			return
		var/pct = fresh ? 100 : HealthPct()
		var/scale = NAMEK_POKO_HATCH_FACTOR * NamekPokoLadder(P)
		var/list/prof = S.PokoProfile
		StrMod = round(scale * (P.StrMod + P.StrAscension) * prof[1], 0.001)
		EndMod = round(scale * (P.EndMod + P.EndAscension) * prof[2], 0.001)
		ForMod = round(scale * (P.ForMod + P.ForAscension) * prof[3], 0.001)
		OffMod = round(scale * (P.OffMod + P.OffAscension) * prof[4], 0.001)
		DefMod = round(scale * (P.DefMod + P.DefAscension) * prof[5], 0.001)
		SpdMod = round(scale * (P.SpdMod + P.SpdAscension) * prof[6], 0.001)
		VitMod = EndMod
		RecovMod = P.RecovMod
		AngerMax = P.AngerMax
		Potential = P.Potential
		ai_alliances = P.NamekPokoAlliances()
		SetHealthPct(pct)
		AIAvailablePower()
		last_powercheck = world.time
