#define NAMEK_CURSE_HP_PCT 2
#define NAMEK_STEAL_LIFE_PCT 2
#define NAMEK_STEAL_LIFE_EVERY 20

/obj/Skills/Utility/Namekian/Draconic_Taunt
	name = "Draconic Taunt"
	desc = "Force a foe within 8 tiles to lock onto you for 3 seconds; they cannot change targets until it ends. Counts as hard crowd control for immunity."
	Copyable = 0
	Cooldown = 22
	EnergyCost = 1
	var/TauntRange = 8
	var/TauntSeconds = 3

	verb/Draconic_Taunt()
		set name = "Draconic Taunt"
		set category = "Skills"
		usr.NamekCastTaunt(src)

/mob/proc/NamekCastTaunt(obj/Skills/Utility/Namekian/Draconic_Taunt/S)
	var/mob/T = NamekKitTarget(S.TauntRange)
	if(!T || !CanUseSkill(S))
		return
	if(T.NamekLockBlocked())
		src << "<font color='red'>[T] cannot be taunted again yet.</font>"
		return
	if(!T.NamekTargetLock(src, S.TauntSeconds))
		src << "<font color='red'>[T] ignores your challenge.</font>"
		return
	NamekPayCast(S)
	OMsg(src, "<b>[src] roars a draconic challenge at [T]!</b>")

/obj/Skills/Queue/Namekian/Bold_Strike
	name = "Bold Strike"
	desc = "Queue a bold cut that leaves your foe bleeding."
	Copyable = 0
	DamageMult = 5.17
	AccuracyMult = 1
	Duration = 5
	Bloodletting = 2
	Cooldown = 10
	EnergyCost = 1
	HitMessage = "carves a bold strike into their foe!"

	verb/Bold_Strike()
		set name = "Bold Strike"
		set category = "Skills"
		usr.SetQueue(src)

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Intense_Concentration
	name = "Intense Concentration"
	desc = "Focus for 20 seconds: Defense rises by 15 percent and blocked hits are softened further (Critical Block 0.1)."
	Copyable = 0
	DefMult = 1.15
	passives = list("CriticalBlock" = 0.1)
	TimerLimit = 20
	Cooldown = 24
	EnergyCost = 1
	ActiveMessage = "narrows their focus to a razor's edge!"
	OffMessage = "lets their concentration ease."

	verb/Intense_Concentration()
		set name = "Intense Concentration"
		set category = "Skills"
		src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Deceived
	name = "Deceived"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 10
	ForMult = 0.9
	ActiveMessage = "is thrown off by a deception!"
	OffMessage = "sees through the deception."

/obj/Skills/AutoHit/Namekian/Deception
	name = "Deception"
	desc = "A feinting burst around you: every foe it strikes is locked onto you for 2 seconds and loses 10 percent Force for 10 seconds."
	Copyable = 0
	Area = "Circle"
	Distance = 2
	StrScaling = 1
	DamageMult = 0.3
	Cooldown = 30
	EnergyCost = 2
	TurfStrike = 1
	ActiveMessage = "feints in every direction at once!"
	var/DeceptionLockSeconds = 2
	var/DeceptionDebuffSeconds = 10

	OnSkillHit(mob/caster, mob/m, atom/hitter, dealt)
		if(!ismob(caster) || !ismob(m) || m == caster || m.KO)
			return
		m.NamekTargetLock(caster, DeceptionLockSeconds)
		m.NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Deceived, DeceptionDebuffSeconds)

	verb/Deception()
		set name = "Deception"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Curse
	name = "Cursed"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 16
	ActiveMessage = "is cursed: every technique now costs them blood!"
	OffMessage = "is freed from the curse."

/obj/Skills/Utility/Namekian/Curse
	name = "Curse"
	desc = "Curse a foe within 8 tiles for 16 seconds: every skill they use costs them 2 percent of their maximum health."
	Copyable = 0
	Cooldown = 60
	EnergyCost = 2
	var/CurseRange = 8
	var/CurseSeconds = 16

	verb/Curse()
		set name = "Curse"
		set category = "Skills"
		usr.NamekCastCurse(src)

/mob/proc/NamekCastCurse(obj/Skills/Utility/Namekian/Curse/S)
	var/mob/T = NamekKitTarget(S.CurseRange)
	if(!T || !CanUseSkill(S))
		return
	T.NamekCurseUntil = world.time + S.CurseSeconds * 10
	T.NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Curse, S.CurseSeconds)
	NamekPayCast(S)
	OMsg(src, "<b>[src] lays a dark curse on [T]!</b>")

/mob/proc/NamekCurseTick()
	if(src.NamekCurseUntil <= world.time)
		return
	if(src.last_skill_fire_time != world.time || src.NamekCursePaidAt == world.time)
		return
	src.NamekCursePaidAt = world.time
	src.LoseHealth(src.PctToHP(NAMEK_CURSE_HP_PCT))

/mob/Players/StartGCD(obj/Skills/Z)
	NamekCurseTick()
	..()

/mob/Player/StartGCD(obj/Skills/Z)
	NamekCurseTick()
	..()

/obj/Skills/AutoHit/Namekian/Self_Destruction_Wave
	name = "Self Destruction Wave"
	desc = "Burn 15 percent of your own health into a blast that rocks everything within 2 tiles. Deals 50 percent more to a foe struck from behind."
	Copyable = 0
	Area = "Circle"
	Distance = 2
	ForScaling = 1
	DamageMult = 8.72
	Cooldown = 18
	HealthCost = 15
	BonusFromBehind = 0.5
	TurfStrike = 1
	ActiveMessage = "tears their own body open in a Self Destruction Wave!"

	verb/Self_Destruction_Wave()
		set name = "Self Destruction Wave"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Utility/Namekian/Fear
	name = "Fear"
	desc = "Terrify a foe within 6 tiles for 3 seconds: they cannot step or dash toward you and walk at a quarter speed, but can still act."
	Copyable = 0
	Cooldown = 54
	EnergyCost = 3
	var/FearRange = 6
	var/FearSeconds = 3

	verb/Fear()
		set name = "Fear"
		set category = "Skills"
		usr.NamekCastFear(src)

/mob/proc/NamekCastFear(obj/Skills/Utility/Namekian/Fear/S)
	var/mob/T = NamekKitTarget(S.FearRange)
	if(!T || !CanUseSkill(S))
		return
	if(T.NamekFearBlocked())
		src << "<font color='red'>[T] cannot be frightened right now.</font>"
		return
	if(!T.NamekFear(src, S.FearSeconds))
		return
	NamekPayCast(S)
	OMsg(src, "<b>[src] bares a terrifying presence at [T]!</b>")

/obj/Skills/Queue/Namekian/Violent_Slice
	name = "Violent Slice"
	desc = "Queue a vicious cut that stuns for 0.8 seconds. Deals 50 percent more to a foe struck from behind."
	Copyable = 0
	DamageMult = 3.48
	AccuracyMult = 1
	Duration = 5
	Stunner = 0.8
	BonusFromBehind = 0.5
	Cooldown = 10
	EnergyCost = 2
	HitMessage = "rips into their foe with a violent slice!"

	verb/Violent_Slice()
		set name = "Violent Slice"
		set category = "Skills"
		usr.SetQueue(src)

/obj/Skills/Utility/Namekian/Dragons_Oath
	name = "Dragon's Oath"
	desc = "Swear an oath over your target if they are a party member within 8 tiles, otherwise over yourself: immune to Fear, Charm and target locks for 20 seconds."
	Copyable = 0
	Cooldown = 120
	EnergyCost = 1
	var/OathRange = 8
	var/OathSeconds = 20

	verb/Dragons_Oath()
		set name = "Dragons Oath"
		set category = "Skills"
		usr.NamekCastOath(src)

/mob/proc/NamekCastOath(obj/Skills/Utility/Namekian/Dragons_Oath/S)
	if(!CanUseSkill(S))
		return
	var/mob/A = src
	var/mob/T = src.Target
	if(ismob(T) && T != src && T.z == src.z && get_dist(src, T) <= S.OathRange && T.ckey && src.inParty(T.ckey))
		A = T
	A.NamekOathUntil = world.time + S.OathSeconds * 10
	A.NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Namekian_Oath, S.OathSeconds)
	NamekPayCast(S)
	if(A == src)
		OMsg(src, "<b>[src] swears a dragon's oath!</b>")
	else
		OMsg(src, "<b>[src] swears a dragon's oath over [A]!</b>")

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Steal_Life
	name = "Life Drained"
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 10
	ActiveMessage = "feels their life being drained away!"
	OffMessage = "stops losing their life."

/obj/Skills/Utility/Namekian/Steal_Life
	name = "Steal Life"
	desc = "Latch onto a foe within 6 tiles: for 10 seconds, every 2 seconds they lose 2 percent of their health and you heal 2 percent of yours."
	Copyable = 0
	Cooldown = 40
	EnergyCost = 3
	var/StealRange = 6
	var/StealSeconds = 10

	verb/Steal_Life()
		set name = "Steal Life"
		set category = "Skills"
		usr.NamekCastStealLife(src)

/mob/proc/NamekCastStealLife(obj/Skills/Utility/Namekian/Steal_Life/S)
	var/mob/T = NamekKitTarget(S.StealRange)
	if(!T || !CanUseSkill(S))
		return
	if(!T.NamekStealLife(src, S.StealSeconds))
		return
	NamekPayCast(S)
	OMsg(src, "<b>[src] latches onto [T]'s life force!</b>")

/mob/proc/NamekStealLife(mob/knight, seconds)
	if(!ismob(knight) || knight == src || src.KO)
		return 0
	var/until = world.time + seconds * 10
	src.NamekStealLifeUntil = until
	NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Steal_Life, seconds)
	spawn()
		NamekStealLifeLoop(knight, until, round(seconds * 10 / NAMEK_STEAL_LIFE_EVERY))
	return 1

/mob/proc/NamekStealLifeLoop(mob/knight, until, ticks)
	for(var/i = 1, i <= ticks, i++)
		sleep(NAMEK_STEAL_LIFE_EVERY)
		if(!src || !knight || src.NamekStealLifeUntil != until)
			return
		if(src.KO || knight.KO || knight.z != src.z)
			continue
		src.LoseHealth(src.PctToHP(NAMEK_STEAL_LIFE_PCT))
		knight.HealHealth(NAMEK_STEAL_LIFE_PCT)

/obj/Skills/Queue/Namekian/Cleave
	name = "Cleave"
	desc = "Queue a wide cut that strikes your target and the two tiles beside it."
	Copyable = 0
	DamageMult = 3.71
	AccuracyMult = 1
	Duration = 5
	CleaveArc = 1
	Cooldown = 8
	EnergyCost = 2
	HitMessage = "cleaves through everything in front of them!"

	verb/Cleave()
		set name = "Cleave"
		set category = "Skills"
		usr.SetQueue(src)
