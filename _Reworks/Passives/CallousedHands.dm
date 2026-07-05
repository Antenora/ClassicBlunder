/mob/proc/GetCallousedHands()
	. = passive_handler.Get("CallousedHands")
	. += scalingEldritchPower() / 10
	. = clamp(., 0, 1)
