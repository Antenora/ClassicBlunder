var/MANAOVERLOADMULT = 1
var/senjutsuOverloadAlert = FALSE
/mob/proc/diedFromSenjutsuOverload()
    if(Secret == "Senjutsu" && (CheckSlotless("Senjutsu Focus") || CheckSlotless("Sage Mode")))
        if(icon_state == "Meditate") return
        var/maxMana = ((ManaMax) * GetManaCapMult())
        if(ManaAmount > maxMana)
            if(senjutsuOverloadAlert == FALSE)
                senjutsuOverloadAlert = TRUE
                src << "You have drawn in too much natural energy and started to turn to stone!" 
            ManaDeath = 1
            return TRUE
    return FALSE


/mob/proc/getManaStatsBoon()
    var/manaStatPerc = GetManaStats() // 1 per tick
    var/maxStatBoon = 1.25
    var/baseBoon = glob.MANA_STATS_BASE_BOON // 0.1 extra stat for 1 mana stat
    if(isRace(YOKAI))
        baseBoon = glob.racials.YOKAI_MANA_STATS_BASE_BOON
        manaStatPerc *= 1.25
        maxStatBoon = 2
    if(ManaMax >= 100 && manaStatPerc > 1 && Secret == "Senjutsu") // essentially senjutsu
        maxStatBoon = 4
    var/manaMissing = (ManaAmount / 100) 
    var/bonus = (baseBoon * manaMissing) * manaStatPerc >= maxStatBoon ? maxStatBoon : (baseBoon * manaMissing) * manaStatPerc
    return bonus