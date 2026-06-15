// Frenzy debuff: Dark Dragon players gain offensive stats, others get DoT, wounds, and shear
//TODO: make these all-caps like most glob variables for clarity sake
//it would have to be updated in the debuff.dm page as well since that is using vars[]
globalTracker/var/maxFrenzyDamage = 0.015
globalTracker/var/FrenzyStackDivisor = 5
globalTracker/var/FrenzyNerf = 1

/mob/proc/IsDarkDragonPlayer()
	return istype(src, /mob/Players) && isRace(DRAGON) && Class == "Dark"

/// hostile Frenzy counts like Sheared stacks
/mob/proc/GetEffectiveShearForStackingEffects()
	if(IsDarkDragonPlayer()) return Sheared
	return max(Sheared, Frenzy)

/mob/proc/AddFrenzy(Value)
	if(Stasis) return
	if(Value <= 0) return
	Value /= 1 + GetDebuffResistance()
	Value *= (1 - (Frenzy / glob.DEBUFF_STACK_RESISTANCE))
	Frenzy += Value
	if(Frenzy > glob.DEBUFF_STACK_MAX) Frenzy = glob.DEBUFF_STACK_MAX
	if(Frenzy < 0) Frenzy = 0

/mob/proc/AddFrenzyFromCombatDamage(amount)
	if(amount <= 0) return
	AddFrenzy(amount*10/glob.FrenzyStackDivisor)

/mob/proc/ReduceHostileFrenzyAttackTick()
	if(IsDarkDragonPlayer()) return
	if(Frenzy <= 0) return
	var/base = clamp(Frenzy / glob.BASE_DEBUFF_REDUCTION_DIVISOR, glob.BASE_DEBUFF_REDUCTION_DIVISOR_LOWER, glob.BASE_DEBUFF_REDUCTION_DIVISOR_UPPER)
	var/reduction = base  * (1 + (GetDebuffResistance() / 4));
	if(Frenzy) Frenzy = clamp(Frenzy - reduction, 0, 100);

/mob/proc/ClearHostileFrenzyFromMeditate()
	if(IsDarkDragonPlayer()) return
	if(Frenzy <= 0) return
	Frenzy = 0

/mob/proc/ClearFrenzyOnKO()
	Frenzy = 0

/mob/proc/ApplyFrenzyCombatHooks(mob/defender, damage, UnarmedAttack, SwordAttack, SpiritAttack)
	if(!defender) return
	if(damage <= 0) return
	if(!(UnarmedAttack || SwordAttack || SpiritAttack)) return
	if(IsDarkDragonPlayer()) AddFrenzyFromCombatDamage(damage)
	if(defender.IsDarkDragonPlayer()) defender.AddFrenzyFromCombatDamage(damage)
	if(defender.passive_handler && defender.passive_handler.Get("FrenzyCarrier")) AddFrenzyFromCombatDamage(damage)
	if(passive_handler && passive_handler.Get("FrenzyCarrier"))
		defender.AddFrenzyFromCombatDamage(damage)
		AddFrenzyFromCombatDamage(damage)
	if(Frenzy > 0 && !IsDarkDragonPlayer()) ReduceHostileFrenzyAttackTick()
