/obj/Skills/Buffs/var/IconState = ""
// If set on a buff, its TimerLimit countdown does not advance while the target is
// in RP Mode. Lives on the /obj/Skills/Buffs base so the generic tick loops can
// read it off any buff type
/obj/Skills/Buffs/var/PauseInRP = 0
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff
	NeedsPassword = 1
	TimerLimit = 1
	Cooldown = 4
	AlwaysOn = 1
	LockX=0
	LockY=0
	var/max_stacks = 1
	var/total_stacks = 0
	Trigger(mob/User, Override, reseting = FALSE)
		..()
		if(!reseting)
			// this fades off
			total_stacks = 0
	proc/do_effect()
	proc/add_stack(mob/p, mob/dealer)
		if(total_stacks + 1 < max_stacks)
			var/stacks = total_stacks + 1
			if(p.BuffOn(src))
				Trigger(p, TRUE, TRUE)
			Trigger(p, TRUE, TRUE)
			total_stacks = stacks
		else
			// max stacks
			TimerLimit = 1
			do_effect(p, dealer)
			total_stacks = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Over_Exerted
	adjust(mob/p)
		SpdMult = 0.75
		passives = list("Drained" = 6 - round(p.Potential/25, 1), "EnergyLeak" = 1)
		CrippleAffected = 1
		TimerLimit = 30 - round(p.Potential/5)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare
	AlwaysOn = 0
	NeedsPassword = 0
	IconLock = 'root.dmi'
	passives = list("Snared" = 1)
	adjust(mob/p, limit = null, _icon = null)
		if(limit)
			TimerLimit = limit
		if(_icon)
			IconLock = _icon
		..()
	New(limit, icon)
		. = ..()
		TimerLimit = limit
		IconLock = icon
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Soul_Drained
	TimerLimit = 30
	AlwaysOn = 0
	NeedsPassword = 0
	IconLock='drained.dmi'
	max_stacks = 4
	do_effect(mob/defender, mob/attacker)
		attacker.HealHealth(total_stacks * glob.racials.SOULDRAINHEAL)
		defender.LoseHealth((total_stacks * glob.racials.SOULDRAINHEAL)/2)
		OMsg(defender, "[attacker] drains [defender]'s life force.")

	adjust(mob/attacker)
		IconState = "[total_stacks]"
		TimerLimit = 25 + (5 * attacker.AscensionsAcquired)
		max_stacks = glob.racials.SOULDRAINMAX + attacker.AscensionsAcquired
		passives = list("Drained" = glob.racials.SOULDRAINPER * total_stacks)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Marked_Prey
	HealthDrain = 0.005
	TimerLimit = 30
	AlwaysOn = 0
	NeedsPassword = 0
	IconLock='marked.dmi'
	IconState = "1"
	max_stacks = 4
	ActiveMessage = "has been marked!"
	do_effect(mob/defender, mob/attacker)
		var/obj/Skills/s = attacker.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Thrill_of_the_Hunt)
		s.adjust(attacker)
		s.Password = attacker.name
		OMsg(defender, "[attacker] starts to hunt [defender].")

	adjust(mob/attacker)
		total_stacks = clamp(total_stacks, 1, 10)
		IconState = num2text(total_stacks)
		TimerLimit = 25 + (5 * attacker.AscensionsAcquired)
		max_stacks = glob.racials.MARKEDPREYBASESTACKS + attacker.AscensionsAcquired
		endAdd = -(glob.racials.MARKEDPREYENDREDUC + (glob.racials.MARKEDPREYENDREDUC * attacker.AscensionsAcquired)) * total_stacks
		passives = list("PureReduction" = (-glob.racials.MARKEDPREYPURERED + (glob.racials.MARKEDPREYPURERED * attacker.AscensionsAcquired)) * total_stacks)


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Festered_Wound
	HealthDrain = 0.1
	TimerLimit = 5
	AlwaysOn = 0
	NeedsPassword = 0
	IconLock='Bleed.dmi'
	max_stacks = 10
	ActiveMessage = "has started to bleed!"
	OffMessage = "has stopped bleeding..."
	do_effect(mob/defender, mob/attacker)

	adjust(mob/attacker, mob/defender)
		var/ratio = clamp(defender.Health / 100, 0.1, 0.9)
		HealthDrain = glob.SERRATED_DAMAGE * ratio
		PoisonAffected = 5 * ratio
		TimerLimit = round(5 + (2.5 * ratio), 1)
		// higher health = better


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Rupture
	HealthDrain = 0.01
	TimerLimit = 25
	IconLock='Bleed.dmi'
	max_stacks = 3
	do_effect(mob/defender, mob/attacker)
		defender.LoseHealth(attacker.passive_handler["Rupture"] * glob.RUPTURE_BASE_DAMAGE)
		OMsg(defender, "[defender]'s wound fully ruptures, causing massive damage!")
	adjust(mob/p)
		switch(total_stacks)
			if(1)
				IconState = "1"
				HealthDrain = 0.025
				ShearAffected = 1
			if(2)
				IconState = "2"
				HealthDrain = 0.05
				ShearAffected = 2
				CrippleAffected = 2

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Judged
	TimerLimit = 120
	AlwaysOn = 0
	NeedsPassword = 0
	IconLock = 'marked.dmi'
	passives = list("Judged" = 1)
	ActiveMessage = "has been judged!"
	adjust(mob/p, limit = 120)
		if(limit)
			TimerLimit = limit
		..()
	// Target takes 25% increased damage from compatible Angel Magic spells (checked in damage flow).

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Sentenced
	TimerLimit = 60
	AlwaysOn = 0
	NeedsPassword = 0
	IconLock = 'marked.dmi'
	passives = list("PureReduction" = -3, "PureDamage" = -3, "BuffMastery" = -5)
	PowerMult = 0.9
	StrMult = 0.9
	EndMult = 0.9
	OffMult = 0.9
	DefMult = 0.9
	ForMult = 0.9
	ActiveMessage = "has been sentenced!"
	// -3 PureReduction, -3 PureDamage, -5 BuffMastery, all stats x0.9

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Cornered
	passives = list("PureReduction" = 0.05, "Flow" = -0.1)
	TimerLimit = 10
	IconLock='Cornered.dmi'
	do_effect(mob/defender, mob/attacker)
		Stun(defender, 8, 1)
		defender.Shatter = glob.OVERHWELMING_SHATTER_APPLY
		OMsg(defender, "[defender] completely shuts down, becoming defenseless.")
	adjust(mob/p, mob/attacker)
		max_stacks = attacker.passive_handler["Overwhelming"]
		if(total_stacks > 2)
			IconState = 2
		else
			IconState = "[total_stacks]"
		passives = list("PureReduction" = -glob.OVERHWELMING_BASE_PR_NERF * total_stacks, "Flow" = -glob.OVERHWELMING_BASE_FLOW * total_stacks)
		endAdd = -glob.OVERHWELMING_BASE_END_NERF * total_stacks

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed
	TimerLimit = 5
	AlwaysOn = 0
	NeedsPassword = 0
	PauseInRP = 1
	ActiveMessage = "has been Charmed!"
	OffMessage = "is no longer Charmed..."
	var/mob/charmer

	GainLoop(mob/source)
		if(source.PureRPMode)
			return
		..()

	Trigger(mob/User, Override = FALSE)
		..()
		if(src.SlotlessOn && charmer && User)
			var/mob/target = User
			spawn()
				target:move_disabled = 1
				while(src && src.SlotlessOn && charmer && charmer.loc && target && target.loc)
					var/rp_pause = target.PureRPMode || (charmer && charmer.PureRPMode)
					if(rp_pause)
						target:move_disabled = 0
						sleep(world.tick_lag * 4)
						continue
					target:move_disabled = 1
					if(get_dist(target, charmer) >= 2)
						step_towards(target, charmer)
					sleep(world.tick_lag * 4)
				if(target)
					target:move_disabled = 0
				if(src && src.SlotlessOn && target && target.BuffOn(src))
					src.Trigger(target, Override = TRUE)
