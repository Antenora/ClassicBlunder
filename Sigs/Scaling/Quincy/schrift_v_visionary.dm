#define QUINCY_V_CADENCE 30
#define QUINCY_V_CADENCE_FORM 20
#define QUINCY_V_HAND 3
#define QUINCY_V_HAND_WIDE 5
#define QUINCY_V_DEAL_LIFE 80
#define QUINCY_V_BLESS_TIME 30
#define QUINCY_V_BLESS_KEEP 320
#define QUINCY_V_BLESS_TRIES 5
#define QUINCY_V_STRIKE_KEEP 100
#define QUINCY_V_CURSE 100
#define QUINCY_V_CURSE_SECONDS 5
#define QUINCY_V_CURSE_STUN 3
#define QUINCY_V_STEEL 100
#define QUINCY_V_STEEL_TIME 100
#define QUINCY_V_CLONE_TIME 300
#define QUINCY_V_VOID_RANGE 4
#define QUINCY_V_VOID_SLOW 5
#define QUINCY_V_VOID_DRAIN 5
#define QUINCY_V_VOID_SECONDS 5
#define QUINCY_V_OVERREACH 20
#define QUINCY_V_SLEEP 600

mob/var/tmp/VisionarySleepUntil = 0
mob/var/tmp/list/VisionaryClones
mob/var/tmp/list/VisionaryCards
mob/var/tmp/list/VisionaryBlessings
mob/var/tmp/VisionaryDeal = 0
mob/var/tmp/VisionaryDealLive = 0
mob/var/tmp/VisionaryDeckGen = 0
mob/var/tmp/VisionaryCombatSecs = 0

var/list/VisionaryBlessingCache
var/list/VisionaryStrikeCache

/obj/QuincyCard
	name = "Vision"
	icon = QUINCY_CARD_ICON
	icon_state = "backA_1"
	plane = HUD_PLANE
	layer = 3
	mouse_opacity = 1
	var/category
	var/mob/holder
	var/deal = 0
	var/card_w = 100
	var/card_h = 155
	var/card_gap = 8
	var/card_top = 12
	var/card_nudge = 16
	var/flip_ticks = 1
	var/burn_ticks = 5
	var/list/back_order = list(1, 2, 3, 4)
	var/list/face_order = list(1, 2, 3, 4)

	Click(location, control, params)
		var/mob/u = usr
		if(!ismob(u) || u != src.holder)
			return
		u.VisionaryPick(src)

	proc/CardLoc(i, n)
		var/total = n * src.card_w + (n - 1) * src.card_gap
		var/dx = src.card_nudge - round(total / 2) + (i - 1) * (src.card_w + src.card_gap)
		var/rows = -round(-(src.card_top + src.card_h) / 32)
		var/dy = rows * 32 - src.card_top - src.card_h
		return "CENTER:[dx],TOP-[rows - 1]:[dy]"

	proc/CardFrame(f)
		if(f <= src.back_order.len)
			return "[QUINCY_CARD_BACK]_[src.back_order[f]]"
		return "[QuincyCardFace(src.category)]_[src.face_order[f - src.back_order.len]]"

/proc/VisionaryWeights()
	return list("Blessing" = 20, "Strike" = 20, "Curse" = 15, "Meteor" = 10, "Steel Body" = 8, "Healed" = 7, "Clone" = 7, "Void" = 8, "Overreach" = 5)

/proc/VisionaryDraw(n)
	var/list/pool = VisionaryWeights()
	var/list/out = list()
	while(out.len < n && pool.len)
		var/total = 0
		for(var/k in pool)
			total += pool[k]
		var/r = rand() * total
		var/got
		for(var/k in pool)
			r -= pool[k]
			if(r < 0)
				got = k
				break
		if(!got)
			got = pool[pool.len]
		out += got
		pool -= got
	return out

/proc/VisionaryUsable(T)
	. = 0
	try
		var/obj/Skills/S = new T
		. = SkillHasSkillVerb(S)
		del S
	catch
		. = 0

/proc/VisionaryBlessingPool()
	if(VisionaryBlessingCache)
		return VisionaryBlessingCache
	var/list/out = list()
	var/list/skip = list(/obj/Skills/Buffs/ActiveBuffs, /obj/Skills/Buffs/SlotlessBuffs, /obj/Skills/Buffs/SlotlessBuffs/Letzt_Stil, /obj/Skills/Buffs/SlotlessBuffs/Auswahlen_Surge)
	for(var/T in typesof(/obj/Skills/Buffs/ActiveBuffs) + typesof(/obj/Skills/Buffs/SlotlessBuffs))
		if(T in skip)
			continue
		var/obj/Skills/Buffs/B = T
		if(!(initial(B.TimerLimit) > 0) || initial(B.SignatureTechnique) >= 3)
			continue
		var/ts = "[T]/"
		if(findtext(ts, "/Autonomous/") || findtext(ts, "/Cursed/"))
			continue
		if(!VisionaryUsable(T))
			continue
		out += T
	VisionaryBlessingCache = out
	return out

/proc/VisionaryStrikePool()
	if(VisionaryStrikeCache)
		return VisionaryStrikeCache
	var/list/out = list()
	var/list/areas = list("Target", "Around Target")
	for(var/T in typesof(/obj/Skills/AutoHit) - /obj/Skills/AutoHit)
		var/obj/Skills/AutoHit/A = T
		if(!(initial(A.Area) in areas))
			continue
		if(initial(A.Cooldown) < 0 || initial(A.SignatureTechnique) >= 3)
			continue
		if(initial(A.Grapple) || initial(A.HeldSkill) || initial(A.WindUp) > 2)
			continue
		if(initial(A.IsSnowgrave) || initial(A.HahaWhoops) || initial(A.AwakeningSkill))
			continue
		if(ispath(T, /obj/Skills/AutoHit/I_Want_To_Be_Like_You))
			continue
		var/ts = "[T]/"
		if(findtext(ts, "/Namekian/") || findtext(ts, "/Hollow/") || findtext(ts, "/Ginto/"))
			continue
		if(!VisionaryUsable(T))
			continue
		out += T
	VisionaryStrikeCache = out
	return out

/mob/proc/VisionaryFoeTarget()
	var/mob/t = src.Target
	if(!ismob(t) || t == src || t.z != src.z || !QuincyAreaFoe(t, src))
		return null
	return t

/mob/proc/VisionaryHolds(T)
	if(locate(T) in src)
		return 1
	var/obj/Skills/Buffs/B = T
	var/bn = initial(B.BuffName) ? initial(B.BuffName) : initial(B.name)
	if(bn && src.SlotlessBuffs && src.SlotlessBuffs["[bn]"])
		return 1
	return 0

/mob/proc/VisionaryCloneAlive()
	if(!src.VisionaryClones)
		return 0
	var/list/keep = list()
	for(var/mob/c in src.VisionaryClones)
		if(c.loc)
			keep += c
	src.VisionaryClones = keep.len ? keep : null
	return keep.len

/mob/proc/VisionaryCadence()
	return QuincyVollstandigOnNow() ? QUINCY_V_CADENCE_FORM : QUINCY_V_CADENCE

/mob/proc/VisionaryHandSize()
	return (QuincyVollstandigOnNow() || VisionaryCloneAlive()) ? QUINCY_V_HAND_WIDE : QUINCY_V_HAND

/mob/proc/VisionaryDeckLoop(obj/Skills/Buffs/B)
	set waitfor = 0
	var/gen = ++src.VisionaryDeckGen
	src.VisionaryCombatSecs = 0
	while(src && B && B.SlotlessOn && B.loc == src && src.VisionaryDeckGen == gen)
		sleep(10)
		if(!src || !B || !B.SlotlessOn || B.loc != src || src.VisionaryDeckGen != gen)
			break
		if(src.KO || !src.client || src.VisionaryDealLive || src.VisionarySleepUntil > world.time)
			continue
		if(!QuincyGloveInCombat())
			continue
		src.VisionaryCombatSecs++
		if(src.VisionaryCombatSecs < VisionaryCadence())
			continue
		src.VisionaryCombatSecs = 0
		VisionaryDealNow(VisionaryHandSize())
	if(src && src.VisionaryDeckGen == gen)
		VisionaryBurn()

/mob/proc/VisionaryDealNow(n)
	if(!src.client || src.VisionaryDealLive)
		return 0
	var/list/cats = VisionaryDraw(n)
	if(!cats.len)
		return 0
	var/deal = ++src.VisionaryDeal
	src.VisionaryDealLive = deal
	var/list/cards = list()
	for(var/i = 1 to cats.len)
		var/obj/QuincyCard/c = new
		c.category = cats[i]
		c.holder = src
		c.deal = deal
		c.screen_loc = c.CardLoc(i, cats.len)
		cards += c
	src.VisionaryCards = cards
	src.client.screen += cards
	VisionaryFlip(deal)
	VisionaryExpire(deal)
	return deal

/mob/proc/VisionaryFlip(deal)
	set waitfor = 0
	var/obj/QuincyCard/first = src.VisionaryCards[1]
	var/frames = first.back_order.len + first.face_order.len
	var/wait = world.tick_lag * max(1, first.flip_ticks)
	for(var/f = 1 to frames)
		if(!src || src.VisionaryDealLive != deal)
			return
		for(var/obj/QuincyCard/c in src.VisionaryCards)
			c.icon_state = c.CardFrame(f)
		sleep(wait)

/mob/proc/VisionaryExpire(deal)
	set waitfor = 0
	sleep(QUINCY_V_DEAL_LIFE)
	if(src && src.VisionaryDealLive == deal)
		VisionaryBurn()

/mob/proc/VisionaryBurn()
	var/list/L = src.VisionaryCards
	src.VisionaryCards = null
	src.VisionaryDealLive = 0
	if(!L || !L.len)
		return
	var/ticks = 1
	for(var/obj/QuincyCard/c in L)
		ticks = max(1, c.burn_ticks)
		animate(c, alpha = 0, time = world.tick_lag * ticks)
	VisionaryBurnDrop(L, world.tick_lag * ticks)

/mob/proc/VisionaryBurnDrop(list/L, wait)
	set waitfor = 0
	sleep(wait + 1)
	for(var/obj/QuincyCard/c in L)
		if(src && src.client)
			src.client.screen -= c
		c.holder = null
		del c

/mob/proc/VisionaryPick(obj/QuincyCard/c)
	if(!c || c.holder != src || !c.deal || c.deal != src.VisionaryDealLive || src.KO)
		return
	var/cat = c.category
	VisionaryBurn()
	VisionaryResolve(cat)

/mob/proc/VisionaryResolve(cat)
	switch(cat)
		if("Blessing")
			return VisionaryBlessing()
		if("Strike")
			return VisionaryStrike()
		if("Curse")
			return VisionaryCurse()
		if("Meteor")
			return VisionaryMeteor()
		if("Steel Body")
			return VisionarySteel()
		if("Healed")
			return VisionaryHealed()
		if("Clone")
			return VisionaryClone()
		if("Void")
			return VisionaryVoid()
		if("Overreach")
			return VisionaryOverreach()
	return 0

/mob/proc/VisionaryBlessing()
	var/list/all = VisionaryBlessingPool()
	var/list/pool = all.Copy()
	for(var/i = 1 to QUINCY_V_BLESS_TRIES)
		var/T
		while(pool.len && !T)
			var/p = pick(pool)
			pool -= p
			if(!VisionaryHolds(p))
				T = p
		if(!T)
			break
		var/obj/Skills/Buffs/B = new T
		B.Slotless = 1
		B.ActiveSlot = 0
		B.SpecialSlot = 0
		B.TimerLimit = QUINCY_V_BLESS_TIME
		B.Timer = 0
		B.Cooldown = 0
		B.ManaCost = 0
		B.EnergyCost = 0
		B.Copied = TRUE
		B.copiedBy = "The Visionary"
		B.Trigger(src, 1)
		if(!src)
			return 0
		if(B.SlotlessOn)
			B.TimerLimit = QUINCY_V_BLESS_TIME
			if(!src.VisionaryBlessings)
				src.VisionaryBlessings = list()
			src.VisionaryBlessings += B
			OMsg(src, "[src] imagines: [B.BuffName ? B.BuffName : B.name].")
			VisionaryBlessingEnd(B)
			return 1
		if(src.ActiveBuff == B || src.SpecialBuff == B)
			B.Trigger(src, 1)
		del B
	src << "The vision slips away before it takes shape."
	return 0

/mob/proc/VisionaryBlessingEnd(obj/Skills/Buffs/B)
	set waitfor = 0
	sleep(QUINCY_V_BLESS_KEEP)
	VisionaryBlessingDrop(B)

/mob/proc/VisionaryBlessingDrop(obj/Skills/Buffs/B)
	if(!B)
		return
	if(src.VisionaryBlessings)
		src.VisionaryBlessings -= B
	if(B.SlotlessOn)
		B.Trigger(src, 1)
	del B

/mob/proc/VisionaryStrike()
	var/mob/t = VisionaryFoeTarget()
	var/list/pool = VisionaryStrikePool()
	if(!t || !pool.len)
		src << "Nothing to strike."
		return 0
	var/T = pick(pool)
	var/obj/Skills/AutoHit/A = new T
	A.Copied = TRUE
	A.copiedBy = "The Visionary"
	A.Cooldown = 0
	A.ManaCost = 0
	A.EnergyCost = 0
	A.FatigueCost = 0
	A.HealthCost = 0
	A.WoundCost = 0
	A.ManaCostAll = 0
	A.CorruptionCost = 0
	A.ResourceCost = null
	VisionaryFreeStrike(A)
	OMsg(src, "[src] imagines: [A.name].")
	src.Activate(A, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE, noAdjust = TRUE)
	VisionaryStrikeDrop(A)
	return 1

/mob/proc/VisionaryFreeStrike(obj/Skills/AutoHit/A)
	A.NeedsHealth = 0
	A.ABuffNeeded = null
	A.SBuffNeeded = null
	A.StanceNeeded = null
	A.StyleNeeded = null
	A.GateNeeded = 0
	A.ClassNeeded = null
	A.RequiresWill = 0
	if(A.NeedsSword && !src.EquippedSword() && !src.HasBladeFisting() && !src.UsingBattleMage())
		A.NeedsSword = 0
	if(A.UnarmedOnly && (src.UsingBattleMage() || (src.EquippedSword() && !src.HasBladeFisting())))
		A.UnarmedOnly = 0
	if(A.NeedsGun && !src.EquippedGun())
		A.NeedsGun = 0
	if(A.NoGun && src.EquippedGun())
		A.NoGun = 0
	if(A.MagicNeeded && !src.HasLimitlessMagic() && (src.HasMechanized() || src.HasMagicTaken() || !src.HasSpellFocus(A)))
		A.MagicNeeded = 0

/mob/proc/VisionaryStrikeDrop(obj/Skills/A)
	set waitfor = 0
	sleep(QUINCY_V_STRIKE_KEEP)
	if(A)
		del A

/mob/proc/VisionaryCurse()
	var/mob/t = VisionaryFoeTarget()
	if(!t)
		src << "Nothing to curse."
		return 0
	var/c = pick("Bleed", "Poison", "Burn", "Shock", "Terror", "Snare", "Charm", "Stun")
	switch(c)
		if("Bleed")
			t.AddBleed(QUINCY_V_CURSE, src)
		if("Poison")
			t.AddPoison(QUINCY_V_CURSE, src)
		if("Burn")
			t.AddBurn(QUINCY_V_CURSE, src)
		if("Shock")
			t.AddShock(QUINCY_V_CURSE, src)
		if("Terror")
			t.AddTerrifying(QUINCY_V_CURSE, src)
		if("Snare")
			t.applySnare(QUINCY_V_CURSE_SECONDS)
		if("Charm")
			t.applyCharmed(src, QUINCY_V_CURSE_SECONDS)
		if("Stun")
			Stun(t, QUINCY_V_CURSE_STUN)
	OMsg(src, "[src] imagines a curse upon [t].")
	return c

/mob/proc/VisionaryMeteor()
	if(!VisionaryFoeTarget())
		src << "Nothing to strike."
		return 0
	var/obj/Skills/Projectile/Quincy/Visionary_Meteor/M = new
	spawn()
		if(src)
			src.UseProjectile(M, noGCD = TRUE)
	return 1

/mob/proc/VisionarySteel()
	set waitfor = 0
	var/base = max(0, src.VaizardHealth)
	src.VaizardHealth += QUINCY_V_STEEL
	OMsg(src, "[src] imagines a body that cannot be cut.")
	. = 1
	sleep(QUINCY_V_STEEL_TIME)
	if(!src)
		return
	src.VaizardHealth -= clamp(src.VaizardHealth - base, 0, QUINCY_V_STEEL)

/mob/proc/VisionaryHealed()
	src.SetHealthPct(100)
	src.MaxHealth()
	src.Bleed = 0
	src.Burn = 0
	src.SilentBurnAmount = 0
	src.Poison = 0
	src.SilentPoisonAmount = 0
	src.Shock = 0
	OMsg(src, "[src] imagines their wounds away.")
	return 1

/mob/proc/VisionaryClone()
	var/list/before = src.MonkeySoldiers.monkeySoldiers.Copy()
	summonShadowClones(1, 1, QUINCY_V_CLONE_TIME)
	var/list/made = src.MonkeySoldiers.monkeySoldiers - before
	if(!made.len)
		return 0
	if(!src.VisionaryClones)
		src.VisionaryClones = list()
	src.VisionaryClones += made
	OMsg(src, "[src] imagines a second self.")
	return 1

/mob/proc/VisionaryVoid()
	var/list/hit = list()
	for(var/mob/m in range(QUINCY_V_VOID_RANGE, src))
		if(m.KO || !QuincyAreaFoe(m, src))
			continue
		hit += m
	for(var/mob/m in hit)
		m.AddSlow(QUINCY_V_VOID_SLOW, src)
	OMsg(src, "[src] imagines a void.")
	VisionaryVoidDrain(hit)
	return hit.len

/mob/proc/VisionaryVoidDrain(list/hit)
	set waitfor = 0
	for(var/i = 1 to QUINCY_V_VOID_SECONDS)
		sleep(10)
		if(!src || src.KO)
			return
		for(var/mob/m in hit)
			m.LoseEnergy(QUINCY_V_VOID_DRAIN)

/mob/proc/VisionaryOverreach()
	src.SetHealthPct(max(1, src.HealthPct() - QUINCY_V_OVERREACH))
	src.VisionarySleepUntil = world.time + QUINCY_V_SLEEP
	OMsg(src, "[src] imagined a power their body could not hold.")
	return 1

/mob/proc/VisionaryVanish()
	VisionaryBurn()
	if(src.VisionaryClones)
		for(var/mob/MonkeySoldier/c in src.VisionaryClones.Copy())
			c.EndMonkey(src)
		src.VisionaryClones = null
	if(src.VisionaryBlessings)
		for(var/obj/Skills/Buffs/B in src.VisionaryBlessings.Copy())
			VisionaryBlessingDrop(B)
		src.VisionaryBlessings = null

/mob/proc/VisionaryLoginSweep()
	for(var/k in src.SlotlessBuffs.Copy())
		var/obj/Skills/Buffs/B = src.SlotlessBuffs[k]
		if(!istype(B) || B.copiedBy != "The Visionary")
			continue
		if(B.SlotlessOn)
			B.Trigger(src, 1)
		src.SlotlessBuffs -= k
		del B
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/V_The_Visionary/V = locate() in src
	if(V && V.SlotlessOn)
		VisionaryDeckLoop(V)

/mob/Players/AllSkillsAdd(var/obj/Skills/Buffs/B)
	. = ..()
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/V_The_Visionary))
		VisionaryDeckLoop(B)

/mob/Players/Login()
	..()
	spawn(40)
		if(src)
			VisionaryLoginSweep()

/strikeHook/quincyVisionaryKO
	stage = "ko"
	fire(strike/S)
		var/mob/d = S ? S.defender : null
		if(!d)
			return
		if(d.VisionaryDealLive || d.VisionaryCards || d.VisionaryClones || d.VisionaryBlessings)
			d.VisionaryVanish()

/mob/Admin3/verb/Visionary_Test()
	set category = "Admin"
	set name = "Visionary Test"
	var/list/opts = list()
	for(var/k in VisionaryWeights())
		opts += k
	var/pick = Ask(usr, "Which vision do you draw?", "Visionary Test", null, "pick", opts, 1)
	if(isnull(pick))
		return
	usr.VisionaryResolve(pick)
	Log("Admin", "[ExtractInfo(usr)] tested the Visionary card [pick].")

/obj/Skills/Projectile/Quincy/Visionary_Meteor
	name = "Meteor"
	ZoneAttack = 1
	ZoneAttackX = 0
	ZoneAttackY = 0
	FireFromEnemy = 1
	FireFromSelf = 0
	Blasts = 1
	Hover = 20
	StormFall = 1
	HyperHoming = 1
	ignoreBetterAim = TRUE
	Speed = 1
	Distance = 20
	DropDistance = 18
	Explode = 3
	DamageMult = 4
	Dodgeable = 1
	Copyable = 0
	IconLock = 'Icons/Blasts/Boulder Normal2.dmi'
	LockX = -33
	LockY = -33
	Variation = 0
	ActiveMessage = "imagines a meteor falling from the sky!"
