
globalTracker/var/MAX_KILLER_INSTINCT_BOON = 1.5

/mob/proc/GetKillerInstinct()
    . = 0
    if(passive_handler.Get("KillerInstinct") && Health <= 50)
        var/missingHealth = 100 - Health
        var/boon = log(10, missingHealth)
        boon *= passive_handler.Get("KillerInstinct")
        if(boon >= glob.MAX_KILLER_INSTINCT_BOON)
            boon = glob.MAX_KILLER_INSTINCT_BOON
        . = clamp(boon, 0.05, glob.MAX_KILLER_INSTINCT_BOON)