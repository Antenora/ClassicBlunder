/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
    Cruel_Shadow
        OffMult=1.3
        SpdMult=1.3
        EndMult=0.8
        StrMult=1.3
        DefMult=0.8
        passives = list("Brutalize" = 1.5, "StyleMastery" = 2, "BuffMastery" = 2,\
                        "Relentlessness" = 1, "Fury" = 6, "DebuffResistance" = 2, "TensionLock" = 1)
    
    Potemkin_Buster
        StyleNeeded = "Ubermensch"
        VaizardHealth = 2
        DefMult = 0.75
        SpdMult = 0.75
        StrMult = 1.5
        EndMult = 1.5
        passives = list("Muscle Power" = 2, "TechniqueMastery" = 3, "DeathField" = 7, "Juggernaut"= 5, "KBRes"= 5, "TensionLock" = 1)
    Emergent_Demon_Breakthrough
        StyleNeeded="Divine Arts of The Heavenly Demon"
        passives = list("Hardening" = 1.5, "Deflection" = 2, "UnarmedDamage" = 2, "Momentum" = 2, "Unnerve" = 2, "TensionLock" = 1)  //TODO come back 2 this perhaps
        StrMult=1.3
        SpdMult=1.2
        ActiveMessage="presses on the cusp of the Ultimate Heavenly Demon Realm!"
        OffMessage="fails their tribulation..."

    Feng_Shui_Engine
        SpdMult=1.3
        DefMult=1.3
        StrMult=1.3
        EndMult=0.6
        passives = list("ComboMaster" = 1, "Gum Gum" = 1, "Relentlessness" = 1, "Momentum" = 2, "Flow" = 2,\
                        "BuffMastery" = 3, "Brutalize" = 1.5, "MovementMastery" = 3, "TensionLock" = 1)
    


    Cooled_Down
        EndMult = 1.5
        SpdMult = 0.75
        ForMult = 1.25
        passives = list("CallousedHands" = 0.15, "Freezing" = 10, "Juggernaut" = 2.5, "KBRes" = 2.5, \
                        "Shattering" = 10, "Steady" = 4, "Hardening" = 2, "TensionLock" = 1)
    Heated_Up
        ForMult = 1.5
        EndMult = 0.75
        SpdMult = 1.25
        passives = list("SpiritHand" = 1, "Scorching" = 10, "BlurringStrikes" = 0.25, "Godspeed" = 2, \
                        "Shattering" = 10, "Flicker" = 2, "Pursuer" = 2, "Momentum" = 2, "TensionLock" = 1)

    X_Buster
        passives = list("Hit Scan" = 2, "SpiritStrike" = 1, "EnergyGeneration" = 2.5, "MovingCharge" = 1, "QuickCast" = 1, \
                        "SpiritFlow" = 1, "Paralyzing" = 10, "Shattering" = 10, "SuperCharge" = 1, "TensionLock" = 1)
        HitScanIcon = 'Plasma1.dmi'
        HitScanHitSpark = 'Trail - Plasma.dmi'
        ForMult = 1.3
        SpdMult = 1.2


    Plasma_Burned
        passives = list("PureReduction" = -1, "Flow" = -2, "Godspeed" = -1)
        


    In_the_Details
        passives = list("KillerInstinct" = 0.1, "HellPower" = 0.5, "Godspeed" = 2, "DebuffResistance" = 0.25, \
                        "Steady" = 2, "Scorching" = 15, "Toxic" = 10, "CursedWounds" = 1, "TensionLock" = 1)
        HealthDrain = 0.033
        DefMult = 0.75
        EndMult = 0.75
        StrMult = 1.5
        ForMult = 1.5
        TimerLimit = 30

    Frozen_Summit
        passives = list("BlockChance" = 25, "CriticalBlock" = 0.25, \
                        "MovingCharge" = 1, "QuickCast" = 1, "Freezing" = 10, "Shattering" = 10, "LifeGeneration" = 0.5, \
                        "LikeWater" = 4, "TensionLock" = 1)
        EndMult=1.2
        ForMult=1.2
        DefMult=1.2
    
    Firefox_Style
        passives = list("AfterImages" = 4, "Speed Force" = 2, "Iaijutsu" = 1, "Relentlessness" = 1, \
                        "Fury" = 4, "TripleStrike" = 0.5, "Momentum" = 1.5, \
                        "TensionLock" = 1)
        SpdMult=1.5
        IconLock='SweatDrop.dmi'
        IconApart=1
    Alpha_Strike
        passives = list("AfterImages" = 4, "Godspeed" = 4, "Speed Force" = 2, "Iaijutsu" = 1, "Rain" = 5,\
                         "CriticalChance" = 33, "TensionLock" = 1)
        SpdMult=1.5
        TimerLimit = 10
        IconLock='SweatDrop.dmi'
        IconApart=1
    Indomitable_Will
        IconLock='SweatDrop.dmi'
        IconApart=1
        passives = list("Duelist" = 2, "Half-Sword" = 1, "Zornhau" = 1, "NoDodge" = 1, "LifeGeneration" = 1, \
                        "KBRes" = 4, "Hardening" = 3, "Unnerve" = 2, "Pressure" = 1, "TensionLock" = 1)
        StrMult=1.35
        EndMult=1.35
        SpdMult=0.75
        VaizardHealth=2
    

    Righteous_Crusade
        IconLock='SweatDrop.dmi'
        IconApart=1
        passives = list("Tossing" = 2, "SlayerMod" = 1, "FavoredPrey" = "All",  "Hit Scan" = 2 , "HolyMod" = 2,  \
        "TensionLock" = 1) // not sure 
        StyleOff = 1.2
        StyleStr = 1.2
        StyleSpd = 1.1
        HitScanIcon = 'stake.dmi'
        HitScanHitSpark = 'Hit_Effect_KanjuriKanKan.dmi'
    Staked
        passives = list("Staked" = 1, "Godspeed" = -2, "Flow" = -1)
        CrippleAffected = 3
        HealthDrain = 0.025
        SpdMult=0.75
        DefMult=0.8
    Ifrit_Jambe
        IconLock='SweatDrop.dmi'
        IconApart=1
        StrMult=1.25
        ForMult=1.25
        passives = list("TensionLock" = 1, "SpiritHand" = 0.5, "Flicker" = 2, "Pursuer" = 2, "Instinct" = 2, "Momentum" = 2, \
                        "Scorching" = 5, "SpiritFlow" = 0.5)
        ActiveMessage="ignites their legs!"
        OffMessage="burns out..."
    

    Time_Skip
        IconLock='SweatDrop.dmi'
        IconApart=1
        StrMult=1.2
        SpdMult=1.2
        OffMult=1.1
        passives = list("Backshot" = 2.5, "Flicker" = 4, "Tossing" = 2, "TensionLock" = 1, "SlayerMod" = 2, "FavoredPrey" = "All", \
                        "ComboMaster" = 1)

    Time_Freeze
        IconLock='Stun.dmi'
        passives = list("Shellshocked" = 1, "NoDodge" = 1)
    

    Silence
        IconLock='SweatDrop.dmi'
        passives = list("Silence" = 1)
        TimerLimit = 3
    Bloodrage
        StrMult=1.5
        SpdMult=1.5
        EndMult=0.5
        AngerMult=1.25
        passives = list("NoDodge" = 1, "Flicker" = 2, "Pursuer" = 2, "PureDamage" = 0.5, "Instinct" = 2, \
         "Speed Force" = 1 , "Sajire Rush" = 1, "Poisoning" = 5, "Enrage" = 1)
    Ruptured
        IconLock='Bleed.dmi'
        IconState = "1"
        passives = list("Don't Move" = 1)
        TimerLimit = 10

