
/globalTracker/var/BASE_MOMENTUM_CHANCE = 50
/globalTracker/var/MAX_HARDEN_STACKS = 32
/globalTracker/var/MAX_GRIT_STACKS = 100
/globalTracker/var/HARDEN_DIVISOR = 2
/globalTracker/var/MAX_MOMENTUM_STACKS = 32
/globalTracker/var/MOMENTUM_DIVISOR = 2
/globalTracker/var/ACUPUNCTURE_BASE_CHANCE = 8
/globalTracker/var/ACUPUNCTURE_DIVISOR = 2

/globalTracker/var/MOMENTUM_BASE_BOON = 0.0005
/globalTracker/var/MOMENTUM_MAX_BOON = 4

/mob/proc/applySoftCC(mob/defender, val)
    if(defender.getHarden())
        var/acu = passive_handler["Acupuncture"]
        defender.HardenAccumulate(acu);
    if(passive_handler["SoulTug"] && (defender.CyberCancel||defender.Mechanized))
        defender.AddConfusing(passive_handler["SoulTug"]*glob.SOULTUGMULT)
    if(HasDisorienting())
        if(prob(GetDisorienting()*25))
            defender.AddConfusing(clamp(val, 1,10) * 1.25)
    if(HasStunningStrike())
        if(!defender.Stunned)
            if(prob(clamp(GetStunningStrike() * 10, 10, 70)))
                Stun(defender, 3)
/mob/proc/applyAdditonalDebuffs(mob/defender, value)
    var/list/debuffs = list("Shearing", "Confusing","Crippling", "Attracting", "Terrifying", "Pacifying", "Enraging","Doom")
    for(var/debuff in debuffs)
        if(passive_handler.Get("[debuff]"))
            call(defender, "Add[debuff]")(passive_handler.Get("[debuff]") * clamp(value, 0.1, 1))


/mob/proc/finalModifiers(mob/defender)
    if(defender.GetWeaponSoulType() == "Soul Calibur")
        . -= 2

