/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Death_Mark
    passives = list("Dim Mak" = 1)
    TimerLimit = 30
    Level = 1
    IconLock='death_mark.dmi'
    ActiveMessage = "has been marked for death!"
    OffMessage = "takes internal damage from the Death Mark!"
    adjust(timer, lvl)
        TimerLimit = timer
        Level = lvl
    Trigger(mob/User, Override)
        if(User.BuffOn(src))
            // we r calling an end to it
            var/damage2do = User.passive_handler["Dim Mak"]
            User.passive_handler.Set("Dim Mak", 1)
            damage2do *= clamp((15*Level)/100, 0.1, 1)// applier's style tier
            OMsg(User, "[User]'s Death Mark implodes!")
            User.LoseHealth(damage2do)
        ..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
    Wing_Chun_Essence
        IconLock='SweatDrop.dmi'
        IconApart=1
        StyleNeeded = "Wing Chun"
        SpdMult = 1.3
        OffMult = 1.2
        passives = list("Relentlessness" = 1, "Fury" = 4, "BuffMastery" = 2, "StyleMastery" = 2, "DebuffResistance" = 2, "TensionLock" = 1)
        ActiveMessage = "showcases the essence of Wing Chun!"
    Contempt_for_the_Weak
        IconLock='SweatDrop.dmi'
        IconApart=1
        StyleNeeded = "Tai Chi"
        DefMult=0.8
        EndMult=0.8
        StrMult=1.3 // 0.3 so far
        OffMult=1.3 // freebie
        SpdMult=1.3 // other .2
        // flip flop the stats
        passives = list("BuffMastery" = 1, "StyleMastery" = 2, "Brutalize" = 1, "TensionLock" = 1)
    Iron_Muscle
        IconLock='SweatDrop.dmi'
        IconApart=1
        StyleNeeded = "Red Cyclone"
        VaizardHealth = 1.5
        DefMult = 0.3
        SpdMult = 0.5
        StrMult = 1.5
        EndMult = 1.5
        passives = list("Muscle Power" = 2, "TechniqueMastery" = 3, "Juggernaut"= 2, "KBRes"= 2, "TensionLock" = 1)
    Diable_Jambe
        IconLock='SweatDrop.dmi'
        IconApart=1
        StyleNeeded="Black Leg"
        StrMult=1.25
        ForMult=1.25
        passives = list("TensionLock" = 1, "SpiritHand" = 1, "Pursuer" = 2, "Instinct" = 2, "TensionLock" = 1)
        ActiveMessage="ignites their legs!"
        OffMessage="burns out..."
    Heavenly_Dragons_Transient_Enlightenment
        StyleNeeded="Heavenly Dragon Stance"
        IconLock='SweatDrop.dmi'
        IconApart=1
        StrMult=1.25
        EndMult=1.25
        passives = list("TensionLock" = 1, "Deflection" = 0.5, "Disorienting" = 2,"Momentum" = 2, "MovementMastery" = 3, "TensionLock" = 1)
        ActiveMessage="achieves the peak of their breakthrough..."
        OffMessage="comes back down to mortal level..."
    

    Nito_Ichi_Style
        IconLock='SweatDrop.dmi'
        IconApart=1
        StyleSpd=1.25
        StyleStr=1.25
        passives = list("TensionLock" = 1, "Momentum" = 1, "DoubleStrike" = 1,\
                        "Steady" = 2, "Instinct" = 2, "TensionLock" = 1)
        
    Iai
        IconLock='SweatDrop.dmi'
        IconApart=1
        StyleSpd = 1.5
        StyleStr = 0.75
        StyleOff = 1.25
        passives = list("AfterImages" = 4, "TensionLock" = 1, "Speed Force" = 1, "Iaijutsu" = 1, "Relentlessness" = 1, "Fury" = 3, "TensionLock" = 1)
    
    Guard_Break
        IconLock='Stun.dmi'
        IconApart=1
        EndMult=0.8
        DefMult=0.8
        ActiveMessage="can't mount a counter attack!"
        OffMessage="shakes off their anxiety!"
    Crescent_Blessing
        IconLock='SweatDrop.dmi'
        IconApart=1
        passives = list("Tossing" = 1.5, "SlayerMod" = 1, "FavoredPrey" = "Races", "Hit Scan" = 2 , "TensionLock" = 1) // not sure 
        StyleOff = 1.2
        StyleStr = 1.2
        StyleSpd = 1.1
        HitScanIcon = 'standard_shuriken.dmi'
        HitScanHitSpark = 'Hit_Effect_KanjuriKanKan.dmi'

    Fimbulwinter
        IconLock='SweatDrop.dmi'
        IconApart=1
        passives = list("PureReduction" = -0.5)
        CrippleAffected = 2
        SlowAffected = 2

    Zwercopter
        IconLock='Ice_Aura_2.dmi'
        IconApart=1
        passives = list("Half-Sword" = 0.5, "Zornhau" = 0.5, "Momentum" = 2, "HeavyHitter" = 1, "CheapShot" = 1,\
                     "HardStyle" = 1, "TensionLock" = 1)
        StrMult=1.3
        OffMult=1.2
        DefMult=1.2
        SpdMult=0.8
    
    Magma_Fist
        ForMult=1.3
        EndMult=1.2
        passives = list("Hardening" = 2, "BlockChance" = 25, "CriticalBlock" = 0.15, "Burning" = 3, "Crushing" = 5, "TensionLock" = 1)

    Cool_Guy
        OffMult=1.15
        ForMult=1.15
        EndMult=1.2
        passives = list("Freezing" = 5, "Shattering" = 3, "Hardening" = 2, "Steady" = 2, "TensionLock" = 1)

    Conduit
        SpdMult=1.2
        ForMult=1.2
        OffMult=1.1
        passives = list("Paralyzing" = 5, "Chilling" = 3, "Steady" = 1, "Flicker" = 2, "Pursuer" = 2, "TensionLock" = 1)

    Fire_Fist
        passives = list("SpiritHand" = 1, "Scorching" = 5, "Shocking" = 3, "Flicker" = 1, "Pursuer" = 1, "TensionLock" = 1)
        ForMult=1.3
        StrMult=1.2
    
    Bloodsurge
        passives = list("LifeSteal" = 5, "Toxic" = 3, "TensionLock" = 1, "Godspeed" = 2, "TechniqueMastery" = 3, "Hustle" = 1)
        ForMult = 1.3
        SpdMult = 1.2
    Itchy_Blood
        passives = list("Godspeed" = -1)
        ConfuseAffected = 5
        ShearAffected = 5
        PoisonAffected=5