#define QUINCY_Q_SEAL_TIME 100
#define QUINCY_Q_NAG 10

mob/var/tmp/QuestionSealedType
mob/var/tmp/QuestionSealedUntil = 0
mob/var/tmp/mob/QuestionBy
mob/var/tmp/QuestionNagAt = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/Q_The_Question/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Objection)

/mob/proc/QuestionClear()
	src.QuestionSealedType = null
	src.QuestionSealedUntil = 0
	src.QuestionBy = null

/mob/proc/QuestionObjectedNow()
	if(!src.QuestionSealedType)
		return 0
	if(src.QuestionSealedUntil <= world.time || !ismob(src.QuestionBy))
		QuestionClear()
		return 0
	return 1

/mob/proc/QuestionSealedName()
	var/obj/Skills/S = src.QuestionSealedType
	return ispath(S, /obj/Skills) ? "[initial(S.name)]" : "that skill"

/mob/proc/QuestionRefuses(obj/Skills/Z)
	if(!Z || !QuestionObjectedNow() || Z.type != src.QuestionSealedType)
		return 0
	if(src.QuestionNagAt <= world.time)
		src.QuestionNagAt = world.time + QUINCY_Q_NAG
		src << "<font color=#ffd23a><b>Objection!</b></font> [Z] is sealed."
	return 1

/mob/proc/QuestionStamp(obj/Skills/Z)
	if(!Z || !QuestionObjectedNow())
		return null
	return list(Z.cooldown_start_wt, Z.Charges, Z.Using ? 1 : 0, src.last_skill_fire_time)

/mob/proc/QuestionUsed(obj/Skills/Z, list/st)
	if(!islist(st) || !Z)
		return 0
	if(src.last_skill_fire_time != st[4])
		return 1
	if(Z.cooldown_start_wt != st[1])
		return 1
	if(Z.MaxCharges > 0 && Z.Charges < st[2])
		return 1
	return Z.Using && !st[3]

/mob/proc/QuestionCharge(obj/Skills/Z)
	if(!Z || !QuestionObjectedNow() || Z.type == src.QuestionSealedType)
		return 0
	if(istype(Z, /obj/Skills/Projectile/Gunfire))
		return 0
	var/paid = 0
	if(Z.ManaCost && !HasDrainlessMana())
		var/m = Z.ManaCost * ChakraCostMult(Z) * SpellCostMult(Z)
		if(m <= 0)
			m = 0.5
		LoseMana(m)
		paid = 1
	if(Z.EnergyCost)
		var/drained = src.passive_handler ? src.passive_handler["Drained"] : 0
		LoseEnergy(drained ? Z.EnergyCost * (1 + drained / 10) : Z.EnergyCost)
		paid = 1
	if(Z.FatigueCost)
		GainFatigue(Z.FatigueCost)
		paid = 1
	return paid

/mob/proc/QuestionAfter(obj/Skills/Z, list/st)
	if(st && QuestionUsed(Z, st))
		QuestionCharge(Z)

/mob/proc/QuestionBuffAfter(obj/Skills/Buffs/B, Override, wasOn)
	if(!B || Override || wasOn || !QuestionObjectedNow())
		return
	if(BuffOn(B))
		QuestionCharge(B)

/mob/proc/QuestionObject(mob/t)
	var/sealed = QuincyLastSkillType(t)
	if(!sealed)
		return 0
	t.QuestionSealedType = sealed
	t.QuestionSealedUntil = world.time + QUINCY_Q_SEAL_TIME
	t.QuestionBy = src
	var/sname = t.QuestionSealedName()
	OMsg(src, "<font color=#ffd23a><b>[src]: Objection!</b></font>")
	src << "<font color=#ffd23a>You object to [t]'s [sname]. It is sealed for [QUINCY_Q_SEAL_TIME / 10] seconds, and their every other skill costs double until they answer you with a hit.</font>"
	t << "<font color=#ffd23a>[src] objects to your [sname]. It is sealed for [QUINCY_Q_SEAL_TIME / 10] seconds, and every other skill costs you double until you land a hit on [src].</font>"
	return 1

/obj/Skills/Quincy/Objection
	name = "Objection"
	desc = "Object to the last skill your target used: it is sealed for 10 seconds, and every other skill they use costs double until they land a hit on you. A silenced voice cannot object, and a deafened target cannot hear it."
	Cooldown = 20
	ManaCost = 4
	Copyable = 0

	verb/Objection()
		set name = "Objection"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		ObjectFire(User)

	proc/ObjectCost(mob/User)
		if(User.HasDrainlessMana())
			return 0
		var/c = src.ManaCost * User.ChakraCostMult(src) * User.SpellCostMult(src)
		if(c <= 0)
			c = 0.5
		return c

	proc/ObjectFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("Q"))
			User << "Only the bearer of The Question can object."
			return 0
		if(User.passive_handler && User.passive_handler.Get("Silenced"))
			User << "You are silenced. You cannot object."
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/mob/t = User.XAxisTarget()
		if(!t)
			User << "You need a target."
			return 0
		if(t.DeafenedUntil > world.time)
			User << "[t] is deafened and cannot hear your objection."
			return 0
		if(!QuincyLastSkillType(t))
			User << "They have done nothing to object to."
			return 0
		var/cost = ObjectCost(User)
		if(cost && User.ManaAmount < cost)
			User << "You don't have enough mana to use [src]."
			return 0
		if(!User.QuestionObject(t))
			return 0
		if(cost)
			User.LoseMana(cost)
		src.Cooldown(1, null, User)
		return 1

/strikeHook/quincyQuestionAnswer
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0 || a.QuestionBy != d)
			return
		if(!a.QuestionObjectedNow())
			return
		a.QuestionClear()
		OMsg(a, "<font color=#ffd23a>Objection answered.</font>")

/mob/Players/Activate(var/obj/Skills/AutoHit/Z, ignoreCuck = FALSE, ignoreAttackLock = FALSE, noGCD = FALSE, noAdjust = FALSE)
	if(QuestionRefuses(Z))
		return 0
	var/list/st = QuestionStamp(Z)
	. = ..()
	QuestionAfter(Z, st)

/mob/Players/UseProjectile(var/obj/Skills/Projectile/Z, noGCD = FALSE)
	if(QuestionRefuses(Z))
		return 0
	var/list/st = QuestionStamp(Z)
	. = ..()
	QuestionAfter(Z, st)

/mob/Players/SetQueue(var/obj/Skills/Queue/Q, noGCD = FALSE)
	if(QuestionRefuses(Q))
		return 0
	var/list/st = QuestionStamp(Q)
	. = ..()
	QuestionAfter(Q, st)

/mob/Players/BeginHeldSkill(var/obj/Skills/Z)
	if(QuestionRefuses(Z))
		return 0
	return ..()

/mob/Players/UseBuff(var/obj/Skills/Buffs/B, var/Override, noGCD = FALSE)
	if(!Override && QuestionRefuses(B))
		return 0
	var/wasOn = B ? BuffOn(B) : 0
	. = ..()
	QuestionBuffAfter(B, Override, wasOn)

/mob/Players/FireGun(obj/Items/Gun/g)
	if(QuestionObjectedNow() && src.QuestionSealedType == /obj/Skills/Projectile/Gunfire)
		if(src.QuestionNagAt <= world.time)
			src.QuestionNagAt = world.time + QUINCY_Q_NAG
			src << "<font color=#ffd23a><b>Objection!</b></font> Your gun is sealed."
		return 0
	return ..()

/mob/Player/AI/Activate(var/obj/Skills/AutoHit/Z, ignoreCuck = FALSE, ignoreAttackLock = FALSE, noGCD = FALSE, noAdjust = FALSE)
	if(QuestionRefuses(Z))
		return 0
	var/list/st = QuestionStamp(Z)
	. = ..()
	QuestionAfter(Z, st)

/mob/Player/AI/UseProjectile(var/obj/Skills/Projectile/Z, noGCD = FALSE)
	if(QuestionRefuses(Z))
		return 0
	var/list/st = QuestionStamp(Z)
	. = ..()
	QuestionAfter(Z, st)

/mob/Player/AI/SetQueue(var/obj/Skills/Queue/Q, noGCD = FALSE)
	if(QuestionRefuses(Q))
		return 0
	var/list/st = QuestionStamp(Q)
	. = ..()
	QuestionAfter(Q, st)

/mob/Player/AI/BeginHeldSkill(var/obj/Skills/Z)
	if(QuestionRefuses(Z))
		return 0
	return ..()

/mob/Player/AI/UseBuff(var/obj/Skills/Buffs/B, var/Override, noGCD = FALSE)
	if(!Override && QuestionRefuses(B))
		return 0
	var/wasOn = B ? BuffOn(B) : 0
	. = ..()
	QuestionBuffAfter(B, Override, wasOn)

/mob/Player/AI/FireGun(obj/Items/Gun/g)
	if(QuestionObjectedNow() && src.QuestionSealedType == /obj/Skills/Projectile/Gunfire)
		return 0
	return ..()

/proc/QuincyTestStepsQ()
	return list("Object to target", "Seal check", "Answer", "Show")

/mob/proc/QuincyTestQ(step, mob/t)
	switch(step)
		if("Object to target")
			if(!t)
				return "no target"
			if(!QuincyLastSkillType(t))
				return "the target has used nothing yet"
			return "objected [QuestionObject(t)]: [t.QuestionSealedName()]"
		if("Seal check")
			if(!t)
				return "no target"
			return "objected [t.QuestionObjectedNow()] sealed [t.QuestionSealedType]"
		if("Answer")
			if(!t)
				return "no target"
			t.QuestionClear()
			return "answered"
		if("Show")
			if(!t)
				return "no target"
			return "ring [jointext(QuincyLastSkillTypes(t), ", ")]"
	return "unknown step"
