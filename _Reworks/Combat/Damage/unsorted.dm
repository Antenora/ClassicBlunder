
globalTracker/var/list/IGNORE_POWER_CLAMP_PASSIVES = list("Star Surge", "The Flame of Youth")


/mob/proc/ignoresPowerClamp(mob/defender)
    if(!defender) return
    if(istype(src, /mob/Player/AI) || istype(defender, /mob/Player/AI))
        return TRUE
    if(!passive_handler || !defender.passive_handler)
        return FALSE
    if(passive_handler.Get("Justice") || defender.passive_handler.Get("Justice"))
        return FALSE
    if(isRace(MAJIN))
        return TRUE
    if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Power"))
        return TRUE
    for(var/passive in glob.IGNORE_POWER_CLAMP_PASSIVES)
        if(passive_handler|=passive)
            return TRUE
    if(passive_handler.Get("WrathFactor") && Health <= 50 && demonDevilTriggerSinMastery())
        return TRUE
    if(passive_handler.Get("Kaioken") && (Health<=20 || Kaioken>=5))
        return TRUE
    if(isRace(POPO) || defender.isRace(POPO))
        return TRUE
    if(isRace(MAKAIOSHIN))
        if(CheckSlotless("Corrupt Self"))
            return TRUE
        if(Health <= 15 + (AscensionsAcquired*5))
            return TRUE
    var/godKi = !HasNullTarget() ? GetGodKi() : 0;
    var/defenderGodKi = !defender.HasNullTarget() ? defender.GetGodKi() : 0;
    if(!defenderGodKi && godKi)
        return TRUE
    else
        if(godKi > defenderGodKi && (godKi - defenderGodKi) >= 0.5)
            return TRUE
    return FALSE
