/mob/proc/GetCallousedHands()
	. = scalingEldritchPower() / 10
	. = clamp(., 0, 1)
