
globalTracker/var/list/IGNORE_POWER_CLAMP_PASSIVES = list("Wrathful", "LimitBroken", "Star Surge", "Kaioken")


/mob/proc/ignoresPowerClamp(mob/defender)
    if(!defender) return
    if(istype(src, /mob/Player/AI) || istype(defender, /mob/Player/AI))
        return TRUE
    if(!src.passive_handler || !defender.passive_handler)
        return FALSE
    if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Power"))
        return TRUE
    for(var/passive in glob.IGNORE_POWER_CLAMP_PASSIVES)
        if(passive_handler|=passive)
            return TRUE
    if(isRace(MAKYO))
        if((StarPowered || passive_handler.Get("HellPower")) && Health <= 10)
            return TRUE
    if(isRace(DEMON))
        if(CheckSlotless("Corrupt Self"))
            return TRUE
        if(Health <= 15 + (AscensionsAcquired*5))
            if(CheckSlotless("True Form"))
                return TRUE
    var/godKi = GetGodKi()
    var/defenderGodKi = defender.GetGodKi()
    if(!defenderGodKi)
        if(godKi )
            return TRUE
    else
        if(godKi)
            if((godKi > defenderGodKi) && godKi - defenderGodKi >= 0.5)
                return TRUE
    return FALSE