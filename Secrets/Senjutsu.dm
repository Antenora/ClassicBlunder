var/MANAOVERLOADMULT = 1
var/senjutsuOverloadAlert = FALSE
/mob/proc/diedFromSenjutsuOverload()
    if(Secret == "Senjutsu" && (CheckSlotless("Senjutsu Focus") || CheckSlotless("Sage Mode")))
        if(icon_state == "Meditate") return
        var/maxMana = ((ManaMax) * GetManaCapMult()) + MageManaBonus()
        if(ManaAmount > maxMana)
            if(senjutsuOverloadAlert == FALSE)
                senjutsuOverloadAlert = TRUE
            ManaDeath = 1
            return FALSE
    return FALSE

