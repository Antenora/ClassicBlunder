/mob/proc/GetBlurringStrikes()
    var/b = passive_handler.Get("BlurringStrikes") //This stores stuff from sources of BlurringStrikes... yay.
    b += scalingEldritchPower();
    b += max(GetMangLevel(), 3)
    b = clamp(b, 0, 15);
    if(b) return b
    return 0
