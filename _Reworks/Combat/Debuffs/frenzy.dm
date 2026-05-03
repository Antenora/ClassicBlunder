// Frenzy debuff: Dark Dragon players gain offensive stats, others get DoT, wounds, and shear
globalTracker/var/maxFrenzyDamage = 0.015
globalTracker/var/FrenzyStackDivisor = 25
globalTracker/var/FrenzyNerf = 1

/mob/proc/IsDarkDragonPlayer()
	return istype(src, /mob/Players) && isRace(DRAGON) && Class == "Dark"

/// hostile Frenzy counts like Sheared stacks
/mob/proc/GetEffectiveShearForStackingEffects()
	if(src.IsDarkDragonPlayer())
		return src.Sheared
	return max(src.Sheared, src.Frenzy)

/mob/proc/AddFrenzy(var/Value, var/mob/Attacker=null)
	if(src.Stasis)
		return
	if(Value <= 0)
		return
	Value /= 1 + src.GetDebuffResistance()
	Value *= (1 - (src.Frenzy / glob.DEBUFF_STACK_RESISTANCE))
	src.Frenzy += Value
	if(src.Frenzy > glob.DEBUFF_STACK_MAX)
		src.Frenzy = glob.DEBUFF_STACK_MAX
	if(src.Frenzy < 0)
		src.Frenzy = 0

/mob/proc/AddFrenzyFromCombatDamage(var/amount)
	if(amount <= 0)
		return
	src.AddFrenzy(amount)

/mob/proc/ReduceHostileFrenzyAttackTick()
	if(src.IsDarkDragonPlayer())
		return
	if(src.Frenzy <= 0)
		return
	var/base = clamp(src.Frenzy / glob.BASE_DEBUFF_REDUCTION_DIVISOR, glob.BASE_DEBUFF_REDUCTION_DIVISOR_LOWER, glob.BASE_DEBUFF_REDUCTION_DIVISOR_UPPER)
	var/reduction = base + ((src.GetEnd(0.15) + src.GetStr(0.15)) * (1 + (src.GetDebuffResistance() / 4)))
	src.Frenzy -= reduction
	if(src.Frenzy < 0)
		src.Frenzy = 0

/mob/proc/ClearHostileFrenzyFromMeditate()
	if(src.IsDarkDragonPlayer())
		return
	if(src.Frenzy <= 0)
		return
	src.Frenzy = 0

/mob/proc/ClearFrenzyOnKO()
	src.Frenzy = 0

/mob/proc/ApplyFrenzyCombatHooks(mob/defender, var/damage, var/UnarmedAttack, var/SwordAttack, var/SpiritAttack)
	if(!defender)
		return
	if(damage <= 0)
		return
	if(!(UnarmedAttack || SwordAttack || SpiritAttack))
		return
	if(src.IsDarkDragonPlayer())
		src.AddFrenzyFromCombatDamage(damage)
	if(defender.IsDarkDragonPlayer())
		defender.AddFrenzyFromCombatDamage(damage)
	if(defender.passive_handler && defender.passive_handler.Get("FrenzyCarrier"))
		src.AddFrenzyFromCombatDamage(damage)
	if(src.passive_handler && src.passive_handler.Get("FrenzyCarrier"))
		defender.AddFrenzyFromCombatDamage(damage)
		src.AddFrenzyFromCombatDamage(damage)
	if(src.Frenzy > 0 && !src.IsDarkDragonPlayer())
		src.ReduceHostileFrenzyAttackTick()
