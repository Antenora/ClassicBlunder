//counter-hit: tag someone mid-commitment and it lands heavier + feeds tension
mob/var/tmp
	guard_broken_until = 0
	ChargingEnergy = 0

//committed = locked into something punishable
mob/proc/isCommitted()
	if(PoweringUp) return 1
	if(Beaming) return 1
	if(WindingUp) return 1
	if(BuffingUp) return 1
	if(held_skill) return 1
	if(splat_stagger_until > world.time) return 1
	if(world.time < guard_broken_until) return 1
	if(ChargingEnergy) return 1
	return 0

proc/CounterHitReward(mob/attacker, mob/victim, weight)
	if(!glob.COUNTER_HIT) return
	attacker.gainTension(glob.COUNTER_HIT_TENSION)
	HitStop(attacker, victim, max(weight, glob.HIT_STOP_MIN), glob.COUNTER_HIT_STOP_BONUS)
