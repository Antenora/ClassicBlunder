/mob/proc/NamekPokoAttack(obj/Skills/S)
	var/ready = !S.Using && !S.cooldown_remaining
	if(istype(S, /obj/Skills/Projectile))
		src.UseProjectile(S)
	else if(istype(S, /obj/Skills/AutoHit))
		src.Activate(S)
	if(ready && (S.Using || S.cooldown_remaining))
		NamekPokoRetreatEnd()

/mob/proc/NamekPokoPay(obj/Skills/S, mob/T)
	var/drain = NamekManaDrain(S, ismob(T) && T.IsEvil())
	if(!NamekHasMana(S, drain))
		return 0
	NamekSpendMana(drain)
	return 1

/mob/proc/NamekPokoRetreatEnd()
	if(!src.NamekUntargetableUntil)
		return
	src.NamekUntargetableUntil = 0
	var/obj/Skills/Buffs/B = src.SlotlessBuffs ? src.SlotlessBuffs["Kami's Retreat"] : null
	if(B)
		B.Trigger(src, Override = 1)
	else
		src << "You step out of Kami's Retreat."

/strikeHook/namekPokoRetreat
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		if(!a || a == S.defender || a.NamekUntargetableUntil <= world.time)
			return
		a.NamekPokoRetreatEnd()

/obj/Skills/Projectile/Namekian/First_Law_of_the_Hearthstone
	name = "First Law of the Hearthstone"
	desc = "Hurl a bolt of demon stone at your target."
	Copyable = 0
	DamageMult = 1.71
	Distance = 15
	Cooldown = 6
	EnergyCost = 1
	Knockback = 0
	Variation = 0
	IconLock = 'Blast - Charged.dmi'
	ActiveMessage = "hurls a bolt of demon stone!"

	verb/First_Law_of_the_Hearthstone()
		set name = "First Law of the Hearthstone"
		set category = "Skills"
		usr.NamekPokoAttack(src)

/obj/Skills/AutoHit/Namekian/Hearthstone_Flash
	name = "Hearthstone Flash"
	desc = "Detonate a flash of demon stone on your target, striking everyone within a tile of them."
	Copyable = 0
	Area = "Around Target"
	Distance = 10
	DistanceAround = 1
	ForScaling = 1
	DamageMult = 4.29
	Cooldown = 10
	EnergyCost = 2
	Knockback = 0
	TurfStrike = 1
	ActiveMessage = "detonates a flash of demon stone!"

	verb/Hearthstone_Flash()
		set name = "Hearthstone Flash"
		set category = "Skills"
		usr.NamekPokoAttack(src)

/obj/Skills/AutoHit/Namekian/Second_Law_of_the_Hearthstone
	name = "Second Law of the Hearthstone"
	desc = "Burst demon stone out around you, striking every foe within a tile and leaving them bleeding."
	Copyable = 0
	Area = "Circle"
	Distance = 1
	ForScaling = 1
	DamageMult = 4.84
	Bloodletting = 2
	Cooldown = 12
	EnergyCost = 2
	Knockback = 0
	TurfStrike = 1
	ActiveMessage = "bursts demon stone out around them!"

	verb/Second_Law_of_the_Hearthstone()
		set name = "Second Law of the Hearthstone"
		set category = "Skills"
		usr.NamekPokoAttack(src)

/obj/Skills/AutoHit/Namekian/Poko_Frenzy
	name = "Poko Frenzy"
	desc = "Unleash a frenzy of ki in a cone three tiles ahead of you."
	Copyable = 0
	Area = "Cone"
	Distance = 3
	ForScaling = 1
	DamageMult = 7.44
	Cooldown = 16
	EnergyCost = 3
	Knockback = 0
	TurfStrike = 1
	ActiveMessage = "unleashes a frenzy of ki!"

	verb/Poko_Frenzy()
		set name = "Poko Frenzy"
		set category = "Skills"
		usr.NamekPokoAttack(src)

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Escort_Effect
	name = "Kami's Escort"
	BuffName = "Kami's Escort"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 600
	DefMult = 1.15
	ActiveMessage = "is guarded by Kami's Escort!"
	OffMessage = "is no longer guarded by Kami's Escort."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Blitz_Effect
	name = "Kami's Blitz"
	BuffName = "Kami's Blitz"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 60
	SpdMult = 1.1
	ActiveMessage = "is quickened by Kami's Blitz!"
	OffMessage = "slows as Kami's Blitz fades."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Determination_Effect
	name = "Kami's Determination"
	BuffName = "Kami's Determination"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 600
	StrMult = 1.1
	ActiveMessage = "is steeled by Kami's Determination!"
	OffMessage = "feels Kami's Determination fade."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Awakening_Effect
	name = "Kami's Awakening"
	BuffName = "Kami's Awakening"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 90
	DefMult = 1.3
	ActiveMessage = "awakens to Kami's power!"
	OffMessage = "settles as Kami's Awakening fades."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Protection_Effect
	name = "Kami's Protection"
	BuffName = "Kami's Protection"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 52
	VaizardHealth = 15
	ActiveMessage = "is wrapped in Kami's Protection!"
	OffMessage = "loses the shelter of Kami's Protection."

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Retreat_Effect
	name = "Kami's Retreat"
	BuffName = "Kami's Retreat"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 10
	ActiveMessage = "slips into Kami's Retreat!"
	OffMessage = "steps out of Kami's Retreat."

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Poko_Curse
	name = "Poko Curse"
	BuffName = "Poko Curse"
	AlwaysOn = 0
	NeedsPassword = 0
	Cooldown = 0
	TimerLimit = 20
	Copyable = 0
	ActiveMessage = "is weighed down by a Poko Curse!"
	OffMessage = "shakes off the Poko Curse."

/obj/Skills/Utility/Namekian/Kamis_Escort
	name = "Kami's Escort"
	desc = "Guard your targeted party member or hatchling, or yourself: their Defense rises by 15 percent for ten minutes. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 4
	Cooldown = 10
	var/tmp/EscortMult = 1.15
	var/tmp/EscortTime = 600
	var/tmp/SupportRange = 10

	verb/Kamis_Escort()
		set name = "Kamis Escort"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoEscort(src)

/mob/proc/NamekPokoEscort(obj/Skills/Utility/Namekian/Kamis_Escort/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	if(!NamekPokoPay(S, T))
		return
	var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Escort_Effect, S.EscortTime)
	B.DefMult = S.EscortMult
	NamekGiveEffect(T, B)
	NamekSupportFX(T)
	src.OMessage(10, "[src] sets Kami's Escort around [T == src ? "themselves" : T]!", "<font color=green>[src]([src.key]) casts [S] on [T].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Epoch
	name = "Kami's Epoch"
	desc = "Heal your targeted party member or hatchling, or yourself, for 25 percent of their health. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 6
	Cooldown = 19
	var/tmp/EpochPct = 25
	var/tmp/SupportRange = 10

	verb/Kamis_Epoch()
		set name = "Kamis Epoch"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoEpoch(src)

/mob/proc/NamekPokoEpoch(obj/Skills/Utility/Namekian/Kamis_Epoch/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	if(!NamekPokoPay(S, T))
		return
	T.HealHealth(S.EpochPct)
	NamekSupportFX(T)
	src.OMessage(10, "[src] restores [T == src ? "themselves" : T] with Kami's Epoch!", "<font color=green>[src]([src.key]) heals [T] with [S].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Blitz
	name = "Kami's Blitz"
	desc = "Quicken your targeted party member or hatchling, or yourself: Attack Speed 1 and Speed up 10 percent for sixty seconds. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 6
	Cooldown = 22
	var/tmp/BlitzSpeed = 1.1
	var/tmp/BlitzAttackSpeed = 1
	var/tmp/BlitzTime = 60
	var/tmp/SupportRange = 10

	verb/Kamis_Blitz()
		set name = "Kamis Blitz"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoBlitz(src)

/mob/proc/NamekPokoBlitz(obj/Skills/Utility/Namekian/Kamis_Blitz/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	if(!NamekPokoPay(S, T))
		return
	var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Blitz_Effect, S.BlitzTime, list("AttackSpeed" = S.BlitzAttackSpeed))
	B.SpdMult = S.BlitzSpeed
	NamekGiveEffect(T, B)
	NamekSupportFX(T)
	src.OMessage(10, "[src] quickens [T == src ? "themselves" : T] with Kami's Blitz!", "<font color=green>[src]([src.key]) casts [S] on [T].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Determination
	name = "Kami's Determination"
	desc = "Steel your targeted party member or hatchling, or yourself: Strength up 10 percent and critical chance up 5 for ten minutes. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 4
	Cooldown = 60
	var/tmp/DeterminationMult = 1.1
	var/tmp/DeterminationCrit = 5
	var/tmp/DeterminationTime = 600
	var/tmp/SupportRange = 10

	verb/Kamis_Determination()
		set name = "Kamis Determination"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoDetermination(src)

/mob/proc/NamekPokoDetermination(obj/Skills/Utility/Namekian/Kamis_Determination/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	if(!NamekPokoPay(S, T))
		return
	var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Determination_Effect, S.DeterminationTime, list("CriticalChance" = S.DeterminationCrit))
	B.StrMult = S.DeterminationMult
	NamekGiveEffect(T, B)
	NamekSupportFX(T)
	src.OMessage(10, "[src] steels [T == src ? "themselves" : T] with Kami's Determination!", "<font color=green>[src]([src.key]) casts [S] on [T].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Poko_Curse
	name = "Poko Curse"
	desc = "Curse your target: they lose 20 percent of their energy, and their maximum health drops by 10 percent for twenty seconds."
	Copyable = 0
	ManaCost = 8
	Cooldown = 90
	var/tmp/CurseRange = 10
	var/tmp/CurseEnergyPct = 20
	var/tmp/CurseVigorShare = -0.1
	var/tmp/CurseTime = 20

	verb/Poko_Curse()
		set name = "Poko Curse"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoCurse(src)

/mob/proc/NamekPokoCurse(obj/Skills/Utility/Namekian/Poko_Curse/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = src.Target
	if(!NamekFoeInReach(T, S.CurseRange, S))
		return
	if(T.KO || NamekIsAlly(T))
		src << "You cannot curse [T]."
		return
	if(!NamekPokoPay(S, null))
		return
	S.Cooldown(1, null, src)
	NamekPokoRetreatEnd()
	T.LoseEnergy(T.EnergyMax * S.CurseEnergyPct / 100)
	T.NamekPokoCurseOn(T.NamekVigorFor(S.CurseVigorShare), S.CurseTime)
	src.OMessage(10, "[src] lays a Poko Curse on [T]!", "<font color=red>[src]([src.key]) curses [T]([T.key]) with [S].")

/mob/proc/NamekPokoCurseOn(vigor, seconds)
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/B = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Poko_Curse)
	if(!istype(B))
		return
	if(src.BuffOn(B))
		B.Trigger(src, TRUE)
	B.passives = list("Vigor" = vigor)
	B.TimerLimit = seconds
	B.Trigger(src, TRUE)
	var/stamp = world.time
	B.namek_applied_at = stamp
	spawn(round(seconds * 10) + 1)
		if(src && B && B.namek_applied_at == stamp && src.BuffOn(B))
			B.Trigger(src, TRUE)

/obj/Skills/Utility/Namekian/Kamis_Awakening
	name = "Kami's Awakening"
	desc = "Awaken your hatchling: its Defense rises by 30 percent and it gains Attack Speed 2 for ninety seconds."
	Copyable = 0
	ManaCost = 10
	Cooldown = 120
	var/tmp/AwakeningMult = 1.3
	var/tmp/AwakeningAttackSpeed = 2
	var/tmp/AwakeningTime = 90
	var/tmp/SupportRange = 10

	verb/Kamis_Awakening()
		set name = "Kamis Awakening"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoAwakening(src)

/mob/proc/NamekPokoAwakening(obj/Skills/Utility/Namekian/Kamis_Awakening/S)
	if(!NamekCastReady(S))
		return
	var/mob/H = src.NamekHatchling
	if(!ismob(H) || H.z != src.z || get_dist(src, H) > S.SupportRange)
		src << "You need your hatchling within [S.SupportRange] tiles to use [S]."
		return
	if(!NamekPokoPay(S, H))
		return
	var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Awakening_Effect, S.AwakeningTime, list("AttackSpeed" = S.AwakeningAttackSpeed))
	B.DefMult = S.AwakeningMult
	NamekGiveEffect(H, B)
	NamekSupportFX(H)
	src.OMessage(10, "[src] awakens [H] with Kami's power!", "<font color=green>[src]([src.key]) casts [S] on [H].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Protection
	name = "Kami's Protection"
	desc = "Shield your targeted party member or hatchling, or yourself, for 52 seconds: a barrier worth 15 percent of their health, and Death Field 2 that wounds whoever strikes them. Costs double mana on an evil heart."
	Copyable = 0
	ManaCost = 8
	Cooldown = 60
	var/tmp/ProtectionPct = 15
	var/tmp/ProtectionField = 2
	var/tmp/ProtectionTime = 52
	var/tmp/SupportRange = 10

	verb/Kamis_Protection()
		set name = "Kamis Protection"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoProtection(src)

/mob/proc/NamekPokoProtection(obj/Skills/Utility/Namekian/Kamis_Protection/S)
	if(!NamekCastReady(S))
		return
	var/mob/T = NamekSupportTarget(S.SupportRange)
	if(!NamekPokoPay(S, T))
		return
	var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Protection_Effect, S.ProtectionTime, list("DeathField" = S.ProtectionField))
	B.VaizardHealth = S.ProtectionPct
	NamekGiveEffect(T, B)
	NamekSupportFX(T)
	src.OMessage(10, "[src] wraps [T == src ? "themselves" : T] in Kami's Protection!", "<font color=green>[src]([src.key]) casts [S] on [T].")
	S.Cooldown(1, null, src)

/obj/Skills/Utility/Namekian/Kamis_Retreat
	name = "Kami's Retreat"
	desc = "Vanish from your foes' sight for ten seconds: no foe can target you, and foes already targeting you lose you. Your party and hatchling still can. Your first landed hit or Hearthstone attack ends it early."
	Copyable = 0
	ManaCost = 12
	Cooldown = 300
	var/tmp/RetreatTime = 10

	verb/Kamis_Retreat()
		set name = "Kamis Retreat"
		set category = "Skills"
		var/mob/User = usr
		if(ismob(User))
			User.NamekPokoRetreat(src)

/mob/proc/NamekPokoRetreat(obj/Skills/Utility/Namekian/Kamis_Retreat/S)
	if(!NamekCastReady(S))
		return
	if(!NamekPokoPay(S, null))
		return
	S.Cooldown(1, null, src)
	var/until = world.time + S.RetreatTime * 10
	src.NamekUntargetableUntil = until
	if(islist(src.BeingTargetted))
		for(var/mob/m in src.BeingTargetted.Copy())
			if(m.Target == src && !NamekIsAlly(m))
				m.RemoveTarget()
	NamekGiveEffect(src, NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Kamis_Retreat_Effect, S.RetreatTime))
	src.OMessage(10, "[src] slips into Kami's Retreat and fades from their foes' sight!", "<font color=green>[src]([src.key]) uses [S].")
	spawn(S.RetreatTime * 10)
		if(src && src.NamekUntargetableUntil == until)
			NamekPokoRetreatEnd()
