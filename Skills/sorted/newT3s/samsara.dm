// runtimes
/obj/Skills/Buffs/var/Powerhouse
/obj/Skills/Buffs/var/Conductor
/obj/Skills/Buffs/var/Antsy
//runtimes

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara
    StyleNeeded="Heavenly Demon's Chaotic Way of Shattered Realms"
    TensionLock = 0
    TimerLimit = 450
    Cooldown = 0
    StrMult=1.1
    ForMult=1.1
    SpdMult=1.1
    EndMult=1.1
    OffMult=1.1
    DefMult=1.1
    ActiveMessage = "enters the next realm of Samsara."
    
    Naraka
        passives = list("Conductor" = -15, "Hardening" = 1, "Momentum" = 1, "Pressure" = 2)
    Preta
        passives = list("Antsy" = -2, "Hardening" = 2, "Momentum" = 1, "UnarmedDamage" = 3, "Deflection" = 2, \
                        "Pressure" = 1)
    Tiryag
        passives = list("Conductor" = -25, "Antsy" = -2, "Hardening" = 2, "Momentum" = 2, "Deflection" = 1, \
                        "Pressure" = 1)
        StrMult=1.2
        ForMult=1.2
        SpdMult=1.2
        EndMult=1.2
        OffMult=1.2
        DefMult=1.2
    Asura
        passives = list("Conductor" = -25, "Momentum" = 2, "LikeWater" = 8, "Antsy" = -3, \
                        "Pressure" = 1)
        offAdd = 0.25
        defAdd = 0.25
        spdAdd = 0.25
        forAdd = 0.25
        strAdd = 0.25
        endAdd = 0.25
        SureDodgeTimerLimit = 15
        SureHitTimerLimit = 15
    Mansuya
        passives = list("Tenacity" = 3, "Persistence" = 3, "UnderDog" = 3, "DemonicDurability" = 2, "Pressure" = 2)
    Deva
        passives = list("Deicide" = 5, "Momentum" = 4, "UnarmedDamage" = 2, "Deflection" = 2, "Hardening" = 5)
    Buddha
        passives = list("GodKi" = 0.5, "UnarmedDamage" = 5, "Deflection" = 5, "PureReduction" = -20, "NoDodge" = 1, "NoMiss" = 1)
        TimerLimit = 60
        StrMult=2
        ForMult=2
        SpdMult=2
        EndMult=0.5
        OffMult=2
        strAdd = 0.75
        endAdd = -0.5
        spdAdd = 0.75
        forAdd = 0.75
        offAdd = 0.75
        SureDodgeTimerLimit = 5
        SureHitTimerLimit = 5
        