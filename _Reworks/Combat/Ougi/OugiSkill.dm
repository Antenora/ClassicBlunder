/obj/Skills/AutoHit/OugiStrike
	name = "Ougi Strike"
	Area = "Target"
	Distance = 30
	DamageMult = 0
	StrScaling = 0
	ForScaling = 0
	NoLock = 1
	NoAttackLock = 1
	CanBeDodged = 0
	CanBeBlocked = 0
	GuardBreak = 1
	Instinct = 1
	Cooldown = 0
	CooldownStatic = 1
	NoGCD = 1

/obj/Skills/Ougi
	name = "Ougi"
	canBeShortcut = 0
	Cooldown = 0
	var
		OugiCategory = "Energy"
		OugiScene
		OugiStage = "void"
		OugiGround
		OugiStrBlend = 0
		OugiForBlend = 1
		OugiSecondary
		OugiRange = 7
		SagaOugi
		BurstFinisherScene
		tmp/obj/Skills/AutoHit/OugiStrike/ougi_strike

	New()
		..()
		OugiGetStrike()
		OugiBuildDescription()
		if(!SecretOugi && !SagaOugi && glob) SkillCost = glob.OUGI_RPP_COST

	proc/OugiGetStrike()
		if(!ougi_strike)
			ougi_strike = new /obj/Skills/AutoHit/OugiStrike
			ougi_strike.loc = null
		ougi_strike.name = name
		ougi_strike.StrScaling = OugiStrBlend
		ougi_strike.ForScaling = OugiForBlend
		ougi_strike.Shearing = OugiShearing
		ougi_strike.Crippling = OugiCrippling
		ougi_strike.Scorching = OugiBurning
		ougi_strike.Using = 0
		return ougi_strike

	proc/OugiSagaRefusal(mob/M)
		return OugiSagaRefusalFor(type, M)

	proc/OugiGearRefusal(mob/M)
		switch(OugiCategory)
			if("Armed")
				if(!M.EquippedSword()) return "This Ougi needs a sword equipped."
			if("Gun")
				if(!M.EquippedGun()) return "This Ougi needs a gun equipped."
			if("Unarmed")
				if(M.EquippedSword() || M.EquippedGun() || M.EquippedStaff()) return "This Ougi needs empty hands."
		return null

	proc/OugiClimaxMult(mob/M)
		var/mult = glob.OUGI_DAMAGE_MULT
		if(OugiCategory == "Gun")
			var/obj/Items/Gun/G = M.EquippedGun()
			if(G) mult *= G.ClassDamage()
		return mult

	Unarmed
		OugiCategory = "Unarmed"
		OugiRange = 2
		OugiStrBlend = 1
		OugiForBlend = 0
		OugiStage = "mountain_dusk"
		OugiGround = /turf/OugiStage/Ground/Grass
		Dragon_Fist_Explosion
			name = "Dragon Fist Explosion"
			OugiScene = "dragon_fist_explosion"
			OugiStrBlend = 0.6
			OugiForBlend = 0.4
			OugiSecondary = "knock-up, Stunner 2"
			OugiLaunch = 2
			OugiStunner = 2
		Hokuto_Hyakuretsu_Ken
			name = "Hokuto Hyakuretsu Ken"
			OugiScene = "hokuto_hyakuretsu_ken"
			OugiSecondary = "delayed Bleed"
			OugiDelayedBleed = 20
		Final_Atomic_Buster
			name = "Final Atomic Buster"
			OugiScene = "final_atomic_buster"
			OugiSecondary = "Shearing 1, long knockdown"
			OugiShearing = 1
			OugiStunner = 3
		Jajanken_Rock
			name = "Jajanken: Rock"
			OugiScene = "jajanken_rock"
			OugiStage = "forest_night"
			OugiStrBlend = 0.8
			OugiForBlend = 0.2
			OugiSecondary = "Shearing 1; self Fury 1 for 6 s"
			OugiShearing = 1
			OugiAfterglowPassives = list("Fury" = 1)
			OugiAfterglowSeconds = 6
		Hell_Memories
			name = "Hell Memories"
			OugiScene = "hell_memories"
			OugiStrBlend = 0.8
			OugiForBlend = 0.2
			OugiSecondary = "Burning 3"
			OugiBurning = 3

	Armed
		OugiCategory = "Armed"
		OugiRange = 2
		OugiStrBlend = 1
		OugiForBlend = 0
		OugiStage = "mountain_dusk"
		OugiGround = /turf/OugiStage/Ground/Dirt
		MenuIcon = "CrossSlash"
		Omnislash_Version_5
			name = "Omnislash Version 5"
			OugiScene = "omnislash_version_5"
			OugiSecondary = "self AttackSpeed 1 for 6 s"
			OugiAfterglowPassives = list("AttackSpeed" = 1)
			OugiAfterglowSeconds = 6
		Hinokami_Kagura
			name = "Hinokami Kagura"
			OugiScene = "hinokami_kagura"
			OugiStrBlend = 0.6
			OugiForBlend = 0.4
			OugiSecondary = "Burning 3"
			OugiBurning = 3
		Great_Aether
			name = "Great Aether"
			OugiScene = "great_aether"
			OugiStrBlend = 0.8
			OugiForBlend = 0.2
			OugiSecondary = "lifesteal"
			OugiLifeSteal = 25
		Final_Hope_Slash
			name = "Final Hope Slash"
			OugiScene = "final_hope_slash"
			OugiStrBlend = 0.3
			OugiForBlend = 0.7
			OugiSecondary = "Shearing 2"
			OugiShearing = 2
		Lionheart_Ougi
			name = "Lionheart"
			OugiScene = "lionheart"
			OugiStrBlend = 0.7
			OugiForBlend = 0.3
			OugiSecondary = "Crippling 2"
			OugiCrippling = 2

	Gun
		OugiCategory = "Gun"
		OugiRange = 7
		OugiStrBlend = 0
		OugiForBlend = 1
		OugiStage = "mountain_dusk"
		OugiGround = /turf/OugiStage/Ground/Dirt
		MenuIcon = "Rifle"
		MenuIconFile = 'Icons/Other/Guns.dmi'
		High_Noon
			name = "High Noon"
			OugiScene = "high_noon"
			OugiSecondary = "Mark: your next hit within 6 s +15 percent"
			OugiMark = 1
		Bullet_Dance
			name = "Bullet Dance"
			OugiScene = "bullet_dance"
			OugiSecondary = "Burning 2"
			OugiBurning = 2
		Shootdodge
			name = "Shootdodge"
			OugiScene = "shootdodge"
			OugiSecondary = "self: dodge the next attack within 5 s"
			OugiSureDodge = 1
		Ricochet_Rounds
			name = "Ricochet Rounds"
			OugiScene = "ricochet_rounds"
			OugiSecondary = "Crippling 1"
			OugiCrippling = 1
		Long_Shot_Hecate
			name = "Long Shot: Hecate"
			OugiScene = "long_shot_hecate"
			OugiSecondary = "Shearing 1"
			OugiShearing = 1

	Energy
		OugiCategory = "Energy"
		OugiRange = 7
		OugiStrBlend = 0
		OugiForBlend = 1
		OugiStage = "mountain_dusk"
		OugiGround = /turf/OugiStage/Ground/Grass
		MenuIcon = "BlasterShell"
		Heat_Dome_Attack
			name = "Heat Dome Attack"
			OugiScene = "heat_dome_attack"
			OugiSecondary = "Stunner 2"
			OugiStunner = 2
		Power_Impact
			name = "Power Impact"
			OugiScene = "power_impact"
			OugiStrBlend = 0.3
			OugiForBlend = 0.7
			OugiSecondary = "Shearing 2"
			OugiShearing = 2
		Spirit_Wave
			name = "Spirit Wave"
			OugiScene = "spirit_wave"
			OugiStrBlend = 0.2
			OugiForBlend = 0.8
			OugiSecondary = "Disorienting 2"
			OugiDisorienting = 2
		Burning_Attack
			name = "Burning Attack"
			OugiScene = "burning_attack"
			OugiSecondary = "Burning 2"
			OugiBurning = 2
		Collapsing_Star_Roaring_Cannon
			name = "Collapsing Star Roaring Cannon"
			OugiScene = "collapsing_star_roaring_cannon"
			OugiSecondary = "Burning 2, knockback"
			OugiBurning = 2
			OugiKnockback = 5

	Secret
		SecretOugi = 1
		SkillCost = 0
		Instant_Kamehameha
			name = "Instant Kamehameha"
			OugiCategory = "Energy"
			OugiRange = 7
			OugiStrBlend = 0
			OugiForBlend = 1
			OugiStage = "mountain_dusk"
			OugiGround = /turf/OugiStage/Ground/Grass
			MenuIcon = "BlasterShell"
			OugiScene = "instant_kamehameha"
			OugiSecondary = "Stunner 1"
			OugiStunner = 1
			RequiredSkills = list(/obj/Skills/Teleport/Instant_Transmission, /obj/Skills/Projectile/Beams/Kamehameha)

mob/Players/verb/Use_Ougi()
	set name = "Use Ougi"
	set hidden = 1
	usr.UseOugi()

mob/var/tmp/obj/Skills/Ougi/ougi_equipped_ref
mob/var/tmp/ougi_equipped_key

mob/proc/OugiEquipped()
	if(!EquippedOugi)
		ougi_equipped_ref = null
		return null
	if(ougi_equipped_ref && ougi_equipped_key == EquippedOugi && ougi_equipped_ref.loc == src) return ougi_equipped_ref
	ougi_equipped_key = EquippedOugi
	var/T = text2path("[EquippedOugi]")
	ougi_equipped_ref = T ? (locate(T) in src) : null
	return ougi_equipped_ref

mob/proc/OugiIsGrabbed()
	for(var/mob/M in range(2, src))
		if(M != src && M.Grab == src) return 1
	return 0

mob/proc/OugiInCutscene()
	if(OugiLock) return 1
	if(CutsceneWatch) return 1
	if(client && client.cutscene_active) return 1
	return 0

proc/OugiSagaRefusalFor(T, mob/M)
	if(!ispath(T, /obj/Skills/Ougi) || !M) return null
	var/obj/Skills/Ougi/P = T
	var/saga = initial(P.SagaOugi)
	if(!saga || M.Saga == saga) return null
	return "[initial(P.name)] belongs to the [saga] Saga."

mob/proc/OugiPressRefusal(obj/Skills/Ougi/O)
	var/saga = O.OugiSagaRefusal(src)
	if(saga) return saga
	var/gear = O.OugiGearRefusal(src)
	if(gear) return gear
	if(Tension < getTensionCap()) return "Your Tension is not full yet."
	if(HasTensionLock()) return "Your Tension is locked right now."
	var/mob/T = Target
	if(!ismob(T) || T == src) return "You need a target."
	if(T.KO || T.Stasis || T.PureRPMode || T.OugiInCutscene()) return "Your target cannot be hit right now."
	if(T.z != z) return "Your target is somewhere else."
	if(get_dist(src, T) > O.OugiRange) return "Your target is too far away."
	if(in_tmp_map || T.in_tmp_map) return "An Ougi cannot be used here."
	if(KO || Stunned || Launched || Knockbacked || Airborne || OugiIsGrabbed() || OugiInCutscene() || PureRPMode) return "You cannot use an Ougi right now."
	if(world.time < ougi_cd_until) return "Your Ougi is not ready yet ([round((ougi_cd_until - world.time) / 10)]s)."
	if(GCDBlocked(O)) return "You are still recovering."
	if(!CanAttack(-1)) return "You cannot attack right now."
	return null

proc/OugiWouldWatch(mob/A, mob/T, range_tiles)
	var/list/L = list()
	if(A) L += A
	if(T) L |= T
	for(var/mob/M in range(range_tiles, A))
		if(OugiCanWatch(M)) L |= M
	if(T)
		for(var/mob/M in range(range_tiles, T))
			if(OugiCanWatch(M)) L |= M
	return L

proc/OugiCanWatch(mob/M)
	if(!M) return 0
	if(!istype(M, /mob/Players) && !istype(M, /mob/Player/AI)) return 0
	if(M.Observing == 2) return 0
	return 1

mob/proc/UseOugi()
	if(OugiChainOffer()) return 1
	var/obj/Skills/Ougi/O = OugiEquipped()
	if(!O)
		src << "Equip an Ougi first."
		return 0
	var/why = OugiPressRefusal(O)
	if(why)
		src << why
		return 0
	var/datum/ougi_scene/S = OugiSceneById(O.OugiScene)
	if(!S)
		src << "This Ougi has no scene yet."
		return 0
	var/mob/T = Target
	var/list/watch = OugiWouldWatch(src, T, glob.OUGI_LOCK_RANGE)
	for(var/mob/M in watch)
		if(M.OugiLock)
			src << "Wait for the current Ougi to end."
			return 0
	var/datum/ougi_room/R = OugiRoomAcquire(O.OugiStage, O.OugiGround)
	if(!R)
		src << "Wait for the current Ougi to end."
		return 0
	return OugiCommit(O, S, T, R, watch)

mob/proc/OugiCommit(obj/Skills/Ougi/O, datum/ougi_scene/template, mob/T, datum/ougi_room/R, list/watch, preview = 0)
	var/datum/ougi_scene/S = new template.type
	S.attacker = src
	S.target = T
	S.ougi = O
	S.room = R
	S.preview = preview
	S.watchers = watch
	S.climax_mult = preview ? 0 : O.OugiClimaxMult(src)
	S.run_prelude = preview ? 0 : OugiTensionWouldTransform()
	var/list/live = OugiLiveList()
	live += S
	if(!preview)
		Tension = 0
		tempTensionLock = glob.OUGI_TENSION_LOCK_S
		StartGCD(null)
	O.Using = 1
	if(!preview) OMessage(10, "<b>[src] unleashes [O.name] on [T]!</b>", "[src] used the Ougi [O.name] on [T]")
	S.Begin()
	return 1

mob/proc/OugiTensionWouldTransform()
	if(Secret == "Spiral" && CheckSlotless("Evolution Power"))
		for(var/obj/Skills/Buffs/SlotlessBuffs/Spiral/Arc_Evolution/ae in src)
			if(!ae.SlotlessOn) return 1
		for(var/obj/Skills/Buffs/SlotlessBuffs/Spiral/Super_Galaxy_Evolution/sge in src)
			if(!sge.SlotlessOn) return 1
	if(!isRace(HUMAN) && !isRace(CELESTIAL)) return 0
	if(isMazokuPathHuman()) return 0
	if(canHT() || canSHT()) return 1
	return 0

mob/proc/OugiTensionChecks()
	if(Secret == "Spiral" && CheckSlotless("Evolution Power"))
		for(var/obj/Skills/Buffs/SlotlessBuffs/Spiral/Arc_Evolution/ae in src)
			if(!ae.SlotlessOn)
				ae.Trigger(src)
		for(var/obj/Skills/Buffs/SlotlessBuffs/Spiral/Super_Galaxy_Evolution/sge in src)
			if(!sge.SlotlessOn)
				sge.Trigger(src)
	tryIncreaseTension()

mob/proc/OugiGuardStops(mob/T)
	if(!T || !T.IsGuarding()) return 0
	if(getBackSide(src, T) && !(T.HasSpecialGuard() == 1 && T.Will >= 110)) return 0
	return 1

mob/proc/OugiFizzleRefund(obj/Skills/Ougi/O)
	Tension = getTensionCap() * glob.OUGI_REFUND_PCT / 100
	ougi_cd_until = world.time + glob.OUGI_COOLDOWN_S * 5
	splat_stagger_until = max(splat_stagger_until, world.time + 10)
	if(O) O.Using = 0

/obj/Skills/Ougi/var/SecretGrantedByAdmin = 0

/obj/Skills/Ougi/proc/OugiBlendLine()
	if(OugiCategory == "Gun") return "Scales [round(OugiForBlend * 100)] percent with Force, times your gun's damage"
	var/list/parts = list()
	if(OugiStrBlend) parts += "[round(OugiStrBlend * 100)] percent with Strength"
	if(OugiForBlend) parts += "[round(OugiForBlend * 100)] percent with Force"
	return "Scales [jointext(parts, " and ")]"

/obj/Skills/Ougi/proc/OugiBlendShort()
	var/list/parts = list()
	if(OugiStrBlend) parts += "Str [OugiStrBlend]"
	if(OugiForBlend) parts += "For [OugiForBlend][OugiCategory == "Gun" ? " x gun" : ""]"
	return jointext(parts, " / ")

/obj/Skills/Ougi/proc/OugiSecondaryLines()
	var/list/L = list()
	if(OugiLaunch) L += "Knock-up: the target is launched when the scene ends."
	if(OugiStunner) L += "Stun ([OugiStunner] s): Unable to act, can be cleansed with After Image Strike."
	if(OugiShearing) L += "Sheared ([OugiShearing]): Reduces incoming healing."
	if(OugiCrippling) L += "Cripple ([OugiCrippling]): Reduces movement speed."
	if(OugiBurning) L += "Burn ([OugiBurning]): Deals damage over time."
	if(OugiDelayedBleed) L += "Bleed, two seconds after the scene: Deals damage over time, increases injury with each step taken."
	if(OugiDisorienting) L += "Confuse ([OugiDisorienting]): Chance to move in a random direction on movement."
	if(OugiKnockback) L += "Knockback: the target is thrown back when the scene ends."
	if(OugiLifeSteal) L += "Lifesteal: the climax heals you for [OugiLifeSteal] percent of its damage."
	if(OugiMark) L += "Mark: your next hit on the target within [OUGI_MARK_WINDOW_DS / 10] seconds deals [round(OUGI_MARK_AMP * 100)] percent more damage."
	if(OugiSureDodge) L += "Shootdodge: you dodge the next attack within [OUGI_SUREDODGE_DS / 10] seconds."
	if(OugiAfterglowPassives)
		for(var/p in OugiAfterglowPassives)
			L += "Afterglow: [p] [OugiAfterglowPassives[p]] for [OugiAfterglowSeconds] seconds."
	return L

/obj/Skills/Ougi/proc/OugiBuildDescription()
	var/list/sec = OugiSecondaryLines()
	description = "[SecretOugi ? "Secret " : ""][OugiCategory] Ougi. [OugiBlendLine()]. [sec.len ? jointext(sec, " ") : ""]"
	Desc = description

/obj/Skills/Ougi/InfoPanelLines()
	var/list/L = list()
	L += "[SecretOugi ? "Secret " : ""][OugiCategory] Ougi"
	L += "[OugiBlendLine()]."
	for(var/s in OugiSecondaryLines())
		L += WrapDescLines(s, 47)
	if(SecretOugi && RequiredSkills)
		var/list/n = list()
		for(var/R in RequiredSkills)
			n += AqNiceName("[R]")
		L += WrapDescLines("Unlocked by owning [jointext(n, " and ")].", 47)
	L += "Cooldown: [glob.OUGI_COOLDOWN_S]s, shared by every Ougi"
	return L

/obj/Skills/Ougi/proc/OugiGateNote(mob/M)
	switch(OugiCategory)
		if("Armed")
			if(!M.EquippedSword()) return "needs a sword"
		if("Gun")
			if(!M.EquippedGun()) return "needs a gun"
		if("Unarmed")
			if(M.EquippedSword() || M.EquippedGun() || M.EquippedStaff()) return "needs empty hands"
	return null

/obj/Skills/Ougi/proc/OugiAfterScene(mob/A, mob/T)
	if(!A) return
	if(OugiAfterglowPassives && OugiAfterglowSeconds) A.OugiAfterglow(OugiAfterglowPassives, OugiAfterglowSeconds)
	if(OugiSureDodge) A.OugiGrantSureDodge()
	if(!T || !T.loc) return
	if(OugiMark)
		T.ougi_mark_by = A
		T.ougi_mark_until = world.time + OUGI_MARK_WINDOW_DS
	if(OugiStunner) Stun(T, OugiStunner)
	if(OugiLaunch) spawn() applyLaunch(T, OugiLaunch)
	if(OugiKnockback && A.loc && T.z == A.z) A.Knockback(OugiKnockback, T, Direction = get_dir(A, T), Forced = 1)
	if(OugiDelayedBleed)
		var/amt = OugiDelayedBleed
		spawn(OUGI_BLEED_DELAY_DS)
			if(T && T.loc) T.AddBleed(amt, A)

mob/proc/OugiAfterglow(list/P, secs)
	var/obj/Skills/Buffs/SlotlessBuffs/OugiAfterglow/B = locate() in src
	if(!B)
		B = new
		AddSkill(B)
	if(BuffOn(B)) B.Trigger(src, Override = 1)
	B.passives = P.Copy()
	B.TimerLimit = secs
	B.Trigger(src, Override = 1)

mob/proc/OugiGrantSureDodge()
	SureDodge = 1
	ougi_suredodge_until = world.time + OUGI_SUREDODGE_DS
	var/until = ougi_suredodge_until
	spawn(OUGI_SUREDODGE_DS)
		if(src && ougi_suredodge_until == until)
			ougi_suredodge_until = 0
			SureDodge = 0

mob/proc/OugiMarkLive(mob/defender)
	return defender && defender != src && defender.ougi_mark_by == src && world.time < defender.ougi_mark_until

mob/proc/OugiMarkSpent(mob/defender, dealt)
	if(dealt > 0 && defender)
		defender.ougi_mark_by = null
		defender.ougi_mark_until = 0

/mob/Players/newDoDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, list/dmgTypes, strike/S = null)
	if(!OugiMarkLive(defender)) return ..()
	. = ..(defender, val * (1 + OUGI_MARK_AMP), unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, dmgTypes, S)
	OugiMarkSpent(defender, .)

/mob/Player/AI/newDoDamage(mob/defender, val, unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, list/dmgTypes, strike/S = null)
	if(!OugiMarkLive(defender)) return ..()
	. = ..(defender, val * (1 + OUGI_MARK_AMP), unarmed, sword, secondhit, thirdhit, trueMult, spiritAtk, destructive, autohit, dmgTypes, S)
	OugiMarkSpent(defender, .)

/datum/ougi_scene/stand_in
	stage = "mountain_dusk"
	length_ds = 50
	climax_ds = 25

/datum/ougi_scene/stand_in/proc/B(at, op, list/a)
	beats += list(list(at, op, a))

/datum/ougi_scene/stand_in/proc/Open()
	beats = list()
	B(0, "actor_face", list("who" = "attacker"))
	B(0, "actor_face", list("who" = "target"))

/datum/ougi_scene/stand_in/proc/Rush(at, time = 2, dx = -24)
	B(at, "cut")
	B(at, "actor_move", list("who" = "attacker", "to" = "target", "dx" = dx, "time" = time))

/datum/ougi_scene/stand_in/proc/Ring(at, who = "target", scale = 0.5, life = 6)
	B(at, "fx", list("at" = who, "icon" = OUGI_RING_ICON, "x" = -105, "y" = -105, "scale" = scale, "life" = life, "blend" = BLEND_ADD))

/datum/ougi_scene/stand_in/proc/Climax(at, flash = "#ffffff", shake = 6)
	B(at - 3, "flash", list("color" = flash, "in" = 1, "hold" = 1, "out" = 3))
	B(at, "hit")
	B(at, "cam_shake", list("strength" = shake, "time" = 4))
	Ring(at)
	B(at + 1, "actor_state", list("who" = "target", "state" = "KB"))

/datum/ougi_scene/stand_in/proc/Return(at)
	B(at, "actor_move", list("who" = "attacker", "to" = "attacker", "time" = 4))
	B(at + 4, "actor_state", list("who" = "attacker", "state" = ""))

mob/proc/OugiSecretSync()
	if(OugiLock) return
	for(var/T in subtypesof(/obj/Skills/Ougi/Secret))
		var/obj/Skills/Ougi/tpl = OugiSecretTemplate(T)
		if(!tpl) continue
		var/met = 1
		for(var/R in tpl.RequiredSkills)
			if(!(locate(R) in src))
				met = 0
				break
		var/obj/Skills/Ougi/have = locate(T) in src
		if(met && !have)
			var/obj/Skills/Ougi/O = new T
			AddSkill(O)
			src << "<font color=#ffd278><b>You have unlocked a Secret Ougi: [O.name]!</b></font>"
		else if(!met && have && !have.SecretGrantedByAdmin)
			if(EquippedOugi == "[T]") EquippedOugi = null
			src << "<font color=#ffd278>You no longer hold the skills [have.name] needs, so the Secret Ougi is gone.</font>"
			DeleteSkill(have)
	if(client) client.UpdateGuardBar()

var/list/ougi_secret_templates = list()

proc/OugiSecretTemplate(T)
	var/obj/Skills/Ougi/O = ougi_secret_templates["[T]"]
	if(!O)
		O = new T
		O.loc = null
		ougi_secret_templates["[T]"] = O
	return O

/mob/Players/CheckAscensions()
	..()
	OugiSecretSync()

mob/proc/OugiBuyRefusal(obj/Skills/Ougi/O)
	if(!O) return "That is not an Ougi."
	if(O.SecretOugi || O.SagaOugi) return "[O.name] cannot be bought."
	if(Saga) return "Saga characters receive their Ougi through their Saga."
	if(Potential < glob.OUGI_POTENTIAL) return "Ougis open at Potential [glob.OUGI_POTENTIAL]."
	return null

mob/proc/OugiAfterBuy(obj/Skills/Ougi/O)
	if(!O) return
	if(!EquippedOugi || !OugiEquipped())
		EquippedOugi = "[O.type]"
		src << "<font color=#ffd278>[O.name] is now your equipped Ougi.</font>"
	if(client) client.UpdateGuardBar()

mob/proc/OugiEquip(obj/Skills/Ougi/O)
	if(!O || O.loc != src) return 0
	if(OugiLock)
		src << "You cannot change your Ougi during an Ougi."
		return 0
	var/saga = O.OugiSagaRefusal(src)
	if(saga)
		src << saga
		return 0
	EquippedOugi = "[O.type]"
	if(client) client.UpdateGuardBar()
	return 1

/obj/Skills/Ougi/Saga
	OugiStage = "void"

/obj/Skills/Ougi/Saga/Example_Saga_Ougi
	name = "Example Saga Ougi"
	SagaOugi = "Shinigami"
	OugiCategory = "Energy"
	OugiScene = "saga_example"
	BurstFinisherScene = "saga_example_finisher"
	OugiStrBlend = 0.5
	OugiForBlend = 0.5

/datum/ougi_scene/stand_in/saga_example
	id = "saga_example"
	stage = "void"
	category = "Energy"

/datum/ougi_scene/stand_in/saga_example/Build()
	Open()
	Rush(4)
	B(7, "actor_state", list("who" = "attacker", "state" = "Attack"))
	Ring(9, "target", 0.3, 4)
	Climax(16)
	Return(24)
	B(30, "hold")

/datum/ougi_scene/saga_example_finisher
	id = "saga_example_finisher"
	stage = "burst"
	category = "Energy"
	length_ds = 30
	climax_ds = 17

/datum/ougi_scene/saga_example_finisher/Build()
	beats = list()
	beats += list(list(0, "actor_face", list("who" = "self")))
	beats += list(list(2, "actor_state", list("who" = "self", "state" = "Blast")))
	beats += list(list(4, "fx", OugiBurstRing("self", 0.3, 6)))
	beats += list(list(12, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3)))
	beats += list(list(15, "cut"))
	beats += list(list(15, "actor_move", list("who" = "self", "to" = "target", "dx" = -20, "time" = 2)))
	beats += list(list(17, "hit"))
	beats += list(list(17, "cam_shake", list("strength" = 6, "time" = 4)))
	beats += list(list(17, "fx", OugiBurstRing("target", 0.6, 6)))
	beats += list(list(18, "actor_state", list("who" = "target", "state" = "KB")))
	beats += list(list(23, "actor_move", list("who" = "self", "to" = "self", "time" = 4)))
	beats += list(list(27, "actor_state", list("who" = "self", "state" = "")))
	beats += list(list(30, "hold"))
