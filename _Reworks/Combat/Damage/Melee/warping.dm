/mob/proc/getWarpingStrike()
	. = 0
	if(AttackQueue && !AttackQueue.NoWarp)
		if(AttackQueue.Warp)
			if(!AttackQueue.InstantStrikes)
				. = AttackQueue.Warp
			else
				. = AttackQueue.Warp
				if(AttackQueue.InstantStrikesDelay<2)
					AttackQueue.NoWarp=1
	if(passive_handler["Speed Force"] >= 3)
		return  passive_handler["Speed Force"] * 1.5