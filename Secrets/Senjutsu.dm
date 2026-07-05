var/MANAOVERLOADMULT = 1
var/senjutsuOverloadAlert = FALSE
/mob/proc/diedFromSenjutsuOverload()
    if(Secret == "Senjutsu" && (CheckSlotless("Senjutsu Focus") || CheckSlotless("Sage Mode")))
        if(icon_state == "Meditate") return
        var/maxMana = ((ManaMax) * GetManaCapMult())
        if(ManaAmount > maxMana)
            if(senjutsuOverloadAlert == FALSE)
                senjutsuOverloadAlert = TRUE
            ManaDeath = 1
            return FALSE
    return FALSE


/mob/proc/getManaStatsBoon()
    var/manaStatPerc = GetManaStats() * glob.MANA_STATS_EFF_MULT // 1 per tick * EFF Mult
    var/maxStatBoon = glob.MANA_STATS_MAX_BOON
    var/baseBoon = glob.MANA_STATS_BASE_BOON // 0.1 extra stat for 1 mana stat
    if(Class=="Trickster")
        baseBoon = glob.racials.YOKAI_MANA_STATS_BASE_BOON
        manaStatPerc *= 1.5
        maxStatBoon = glob.MANA_STATS_MAX_BOON + 2
    if(ManaMax >= 100 && manaStatPerc > 1 && Secret == "Senjutsu") // essentially senjutsu
        maxStatBoon = glob.MANA_STATS_MAX_BOON + 4
    var/manaMissing = (ManaAmount / 100)
    var/bonus = (baseBoon * manaMissing) * manaStatPerc >= maxStatBoon ? maxStatBoon : (baseBoon * manaMissing) * manaStatPerc
    return bonus