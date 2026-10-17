/mob/proc/NamekPokoNewestDebuff()
	if(!src.SlotlessBuffs || !src.SlotlessBuffs.len)
		return null
	for(var/i = src.SlotlessBuffs.len, i >= 1, i--)
		var/obj/Skills/Buffs/B = src.SlotlessBuffs[src.SlotlessBuffs[i]]
		if(!istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff) || !B.SlotlessOn)
			continue
		return B
	return null

/mob/proc/NamekPokoCleanse(obj/Skills/Buffs/B)
	if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Target_Lock))
		src.NamekTargetLockUntil = 0
		src.NamekTargetLockTo = null
	else if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Fear))
		src.NamekFearUntil = 0
		src.NamekFearFrom = null
	else if(istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Demon_Mark) || istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Poko_Mark))
		src.mark_vuln_until = 0
	B.Trigger(src, Override = 1)

/obj/Skills/Utility/Namekian/Hatchling
	Copyable = 0
	var/tmp/PokoRange = 8

	proc/HatchAct(mob/Player/AI/Namek_Hatchling/H)
		return 0

	proc/HatchFoe(mob/Player/AI/Namek_Hatchling/H)
		var/mob/T = H.Target
		if(!ismob(T) || T == H || T.KO || T.Dead || T.z != H.z)
			return null
		if(H.AllianceCheck(T) || get_dist(H, T) > PokoRange)
			return null
		return T

/obj/Skills/Utility/Namekian/Hatchling/Provoke
	name = "Provoke"
	desc = "The hatchling bellows at its target, locking their attention onto it for two seconds."
	Cooldown = 20
	PokoRange = 6
	var/tmp/ProvokeSeconds = 2

	HatchAct(mob/Player/AI/Namek_Hatchling/H)
		var/mob/T = HatchFoe(H)
		if(!T || T.Target == H)
			return 0
		if(!T.NamekTargetLock(H, ProvokeSeconds))
			return 0
		Cooldown(1, null, H)
		H.OMessage(10, "[H] bellows at [T], daring them to fight!", "<font color=red>[H] provokes [T]([T.key]).")
		return 1

/obj/Skills/Utility/Namekian/Hatchling/Cleanse_Owner
	name = "Cleanse Owner"
	desc = "The hatchling washes the newest debuff off its priest."
	Cooldown = 30

	HatchAct(mob/Player/AI/Namek_Hatchling/H)
		var/mob/P = H.ai_owner
		if(!ismob(P) || P.z != H.z || get_dist(H, P) > PokoRange)
			return 0
		var/obj/Skills/Buffs/B = P.NamekPokoNewestDebuff()
		if(!B)
			return 0
		var/what = "[B]"
		P.NamekPokoCleanse(B)
		Cooldown(1, null, H)
		H.NamekSupportFX(P)
		H.OMessage(10, "[H] washes [what] off [P]!", "<font color=green>[H] cleanses [what] from [P]([P.key]).")
		return 1

/obj/Skills/Utility/Namekian/Hatchling/Battle_Cry
	name = "Battle Cry"
	desc = "The hatchling roars, raising its own Force by 15 percent for ten seconds."
	Cooldown = 40
	PokoRange = 10
	var/tmp/CryMult = 1.15
	var/tmp/CrySeconds = 10

	HatchAct(mob/Player/AI/Namek_Hatchling/H)
		if(!HatchFoe(H))
			return 0
		var/obj/Skills/Buffs/B = NamekEffect(/obj/Skills/Buffs/SlotlessBuffs/Namekian/Hatchling_Battle_Cry, CrySeconds)
		B.ForMult = CryMult
		H.NamekGiveEffect(H, B)
		Cooldown(1, null, H)
		return 1

/obj/Skills/Utility/Namekian/Hatchling/Demon_Mark
	name = "Demon Mark"
	desc = "The hatchling brands its target for eight seconds: they take 15 percent more damage from the hatchling and its priest."
	Cooldown = 20
	PokoRange = 10
	var/tmp/MarkAmp = 0.15
	var/tmp/MarkSeconds = 8

	HatchAct(mob/Player/AI/Namek_Hatchling/H)
		var/mob/T = HatchFoe(H)
		var/mob/P = H.ai_owner
		if(!T || !ismob(P))
			return 0
		if(T.mark_vuln_by == P && T.mark_vuln_until > world.time)
			return 0
		T.mark_vuln_by = P
		T.mark_vuln_until = world.time + MarkSeconds * 10
		T.mark_vuln_amp = MarkAmp
		T.NamekApplyTimedBuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Poko_Mark, MarkSeconds)
		Cooldown(1, null, H)
		H.OMessage(10, "[H] brands [T] with a demon mark!", "<font color=red>[H] marks [T]([T.key]) for [P]([P.key]).")
		return 1

/obj/Skills/Utility/Namekian/Hatchling/Body_Block
	name = "Body Block"
	desc = "In Auto mode the hatchling plants itself between its priest and the priest's target."

	HatchAct(mob/Player/AI/Namek_Hatchling/H)
		if(H.ai_hostility && !H.companion_def_mode)
			H.companion_def_mode = 1
		return 0

/obj/Skills/Buffs/SlotlessBuffs/Namekian/Hatchling_Battle_Cry
	name = "Battle Cry"
	BuffName = "Hatchling Battle Cry"
	Copyable = 0
	Cooldown = 0
	SilentCast = 1
	TimerLimit = 10
	ForMult = 1.15
	ActiveMessage = "lets loose a battle cry!"
	OffMessage = "catches its breath."

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Namekian_Poko_Mark
	name = "Demon Mark"
	BuffName = "Poko Demon Mark"
	AlwaysOn = 0
	NeedsPassword = 0
	Cooldown = 0
	TimerLimit = 8
	Copyable = 0
	ActiveMessage = "is branded by a hatchling's demon mark!"
	OffMessage = "is no longer branded."

/obj/Skills/Projectile/Namekian/Hatchling

/obj/Skills/Projectile/Namekian/Hatchling/Mouth_Energy_Wave
	name = "Mouth Energy Wave"
	desc = "The hatchling spits a thin beam of ki from its mouth."
	Copyable = 0
	DamageMult = 2.36
	Distance = 12
	Cooldown = 8
	Knockback = 0
	Variation = 0
	IconLock = 'Blast - Small.dmi'
	ActiveMessage = "spits a thin beam of ki!"

	verb/Mouth_Energy_Wave()
		set name = "Mouth Energy Wave"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Namekian/Hatchling/Electric_Shock_Wave
	name = "Electric Shock Wave"
	desc = "The hatchling looses a crackling bolt that stuns its target for half a second."
	Copyable = 0
	DamageMult = 2.5
	Stunner = 0.5
	Distance = 12
	Cooldown = 10
	Knockback = 0
	Variation = 0
	IconLock = 'Blast - Small.dmi'
	ActiveMessage = "looses a crackling bolt!"

	verb/Electric_Shock_Wave()
		set name = "Electric Shock Wave"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Namekian/Hatchling/Energy_Bullets
	name = "Energy Bullets"
	desc = "The hatchling fires a burst of four ki bullets."
	Copyable = 0
	DamageMult = 0.94
	Blasts = 4
	Delay = 1
	Distance = 12
	Cooldown = 12
	Knockback = 0
	IconLock = 'Blast - Basic.dmi'
	ActiveMessage = "fires a burst of ki bullets!"

	verb/Energy_Bullets()
		set name = "Energy Bullets"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/AutoHit/Namekian/Hatchling

/obj/Skills/AutoHit/Namekian/Hatchling/Dive
	name = "Dive"
	desc = "The hatchling swoops at its target from up to eight tiles away and slams into them."
	Copyable = 0
	Area = "Target"
	Distance = 8
	Rush = 6
	ControlledRush = 1
	StrScaling = 1
	DamageMult = 5.66
	Cooldown = 12
	Knockback = 0
	ActiveMessage = "dives at its target!"

	verb/Dive()
		set name = "Dive"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Queue/Namekian/Hatchling

/obj/Skills/Queue/Namekian/Hatchling/Super_Marengeki
	name = "Super Marengeki"
	desc = "The hatchling drives a burning thrust into its target."
	Copyable = 0
	DamageMult = 9.03
	AccuracyMult = 1
	Duration = 5
	Cooldown = 15
	HitMessage = "drives a burning thrust into its foe!"

	verb/Super_Marengeki()
		set name = "Super Marengeki"
		set category = "Skills"
		usr.SetQueue(src)

/obj/Skills/Queue/Namekian/Hatchling/Crushing_Blow
	name = "Crushing Blow"
	desc = "The hatchling brings down a crushing blow that knocks its target back two tiles."
	Copyable = 0
	DamageMult = 7
	AccuracyMult = 1
	KBAdd = 2
	Duration = 5
	Cooldown = 12
	HitMessage = "brings down a crushing blow!"

	verb/Crushing_Blow()
		set name = "Crushing Blow"
		set category = "Skills"
		usr.SetQueue(src)
