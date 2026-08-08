/mob/proc/GetBlurringStrikes()
    var/b = 0
    b += scalingEldritchPower();
    b += max(GetMangLevel(), 3)
    b = clamp(b, 0, 15);
    if(b) return b
    return 0
