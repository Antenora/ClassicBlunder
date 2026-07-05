/mob/proc/adjustDelay(delay)
    #if DEBUG_MELEE
    log2text("Delay", "Delay start of adjustments", "damageDebugs.txt", "[ckey]/[name]")
    log2text("Delay", delay, "damageDebugs.txt", "[ckey]/[name]")
    #endif
    delay *= getAttackSpeedValue();
    #if DEBUG_MELEE
    log2text("Delay", "Delay end of adjustments", "damageDebugs.txt", "[ckey]/[name]")
    log2text("Delay", delay, "damageDebugs.txt", "[ckey]/[name]")
    #endif

    return delay
