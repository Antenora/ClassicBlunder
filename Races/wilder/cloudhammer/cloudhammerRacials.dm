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
        passives = list("Hit Scan" = 1 + (asc/2), "Momentum" = 2 + asc/2, "Fury" = 1 + asc/2, "Relentlessness" = 1, "Tossing" = clamp(asc/2, 0, 2.5),"AttackSpeed" = 1+asc)
        //passives were kill: blurringstrikes, instinct, flow
        TimerLimit = 30 + (glob.racials.FEATHERDUR * asc)
        Cooldown = 120 - ((glob.racials.FEATHERDUR*2) * asc)
        EnergyDrain = 0.05 - (asc/100)
        if(EnergyDrain<0)
            EnergyDrain=0
    verb/Clean_Cuts()
        set category = "Skills"
        Trigger(usr)

/obj/Skills/AutoHit/Wind_Roar
    Area="Circle"
    AdaptRate=1
    TurfDirt=1
    ShockIcon='KenShockwave.dmi'
    Shockwave=4
    Shockwaves=1
    PostShockwave=1
    PreShockwave=0
    Cooldown=-1
    Earthshaking=20
    Instinct=1
    WindupMessage="ROARRRR"
    ActiveMessage="ROARRRSSS"
    ComboMaster = 1
    Knockback = 0.25;
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        Distance = 8 + (asc * 5)
        Paralyzing = 8 + (8 * asc)
        DamageMult = 6 + asc 
        Rounds = 8 + (asc * 2)
        DamageMult = DamageMult / Rounds;
    verb/Wind_Roar()
        set category="Skills"
        if(Using) adjust(usr)
        usr.Activate(src)

/obj/Skills/Projectile/Beam/Static_Stream
    Dodgeable=0
    Distance=20
    StrRate=0.5
    EndRate=1
    ForRate=0.5
    Delay=1
    Blasts=1
    Stream=1
    IconLock='LightningWave.dmi'
    adjust(mob/p)
        var/asc = p.AscensionsAcquired;
        Radius = clamp(asc, 1, 5);
        DamageMult = 5 + (3 * asc);
        Paralyzing = 2 + (0.5 * asc);
        Cooldown = 60 - (5 * asc);
        BeamTime = 5 + (5 * asc);
    verb/Static_Stream()
        set category="Skills"
        if(!Using) adjust(usr);
        usr.UseProjectile(src)

/obj/Skills/Buffs/SlotlessBuff/Autonomous/Dragon_Rage/Wind_Supremacy
    ActiveMessage = "takes to the skies as the very winds heed their call!"
    OffMessage = "finally graces the earth once again with their presence..."
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        ..(p);
        spdAdd = 0.15 * asc
        ElementalOffense = "Wind"
        ElementalDefense = "Wind"
        passives = list("DoubleStrike" = asc/2, "TripleStrike" = asc/3, "ThunderHerald" = 1, \
            "Pursuer" = 1 + (asc/2), "Flicker" = 1 + (asc/2), "CriticalDamage" = asc*0.05, "CriticalChance" = asc*5, \
            "Shocking" = (clamp(asc*0.5, 1, 3)))
    Trigger(mob/User, Override = FALSE)
        if(!User.BuffOn(src)) adjust(User)
        ..()