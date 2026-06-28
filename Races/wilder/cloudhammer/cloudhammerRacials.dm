/mob/proc/isCloudhammer()
    if(!isRace(WILDER)) return 0;
    if(Class != "Cloudhammer") return 0;
    return 1;

/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Feather_Cowl
    EnergyCost = 5
    WoundCost = 1
    Cooldown = 180
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        VaizardHealth = ((100-p.Health) * (0.1 + (glob.racials.COWLSHIELDVAL * asc) ) )
        passives = list("Harden" = clamp(asc, 1, 5), "Deflection" = 0.5 + (asc * 0.5), "Reversal" = 0.1 + (asc * 0.1))
        VaizardShatter = 1
        Cooldown = 180 - (asc * 15)

    verb/Feather_Cowl()
        set category = "Skills"
        Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Clean_Cuts
    IconLock = 'Innovator Wings.dmi'
    HitScanIcon = 'feathers.dmi'
    HitScanHitSpark = 'Slash_-_Ragna.dmi'
    EnergyCost = 3
    EnergyDrain = 0.05
    TimerLimit = 30
    Cooldown = 120
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        passives = list("Hit Scan" = 1 + (asc/2), "Momentum" = 2 + asc/2, "Fury" = 1 + asc/2, "Relentlessness" = 1, "Tossing" = clamp(asc/2, 0, 2.5),"AttackSpeed" = 1+asc,"BlurringStrikes" = 3+asc, "Flow" = asc, "Instinct" = asc)
        TimerLimit = 30 + (glob.racials.FEATHERDUR * asc)
        Cooldown = 120 - ((glob.racials.FEATHERDUR*2) * asc)
        EnergyDrain = 0.05 - (asc/100)
        if(EnergyDrain<0)
            EnergyDrain=0
    verb/Clean_Cuts()
        set category = "Skills"
        Trigger(usr)