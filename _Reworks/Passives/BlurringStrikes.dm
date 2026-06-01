/mob/proc/GetBlurringStrikes()
    var/b = passive_handler.Get("BlurringStrikes") //This stores stuff from sources of BlurringStrikes... yay.
    b += scalingEldritchPower();
    b += GetMangLevel()/2
    b = clamp(b, 0, 15);
    if(b) return b
    return 0
