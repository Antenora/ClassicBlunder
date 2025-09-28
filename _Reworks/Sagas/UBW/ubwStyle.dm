/obj/Skills/Buffs/NuStyle/SwordStyle/Sword_Savant
    BuffName = "Sword Savant Style"
    Copyable = 0
    SagaSignature = 1
    StyleActive = "Sword Savant"
    passives = list("SwordPunching" = 1, "SwordDamage" = 1, "NeedsSword" = 0)
    NeedsSword = 0
    Mastery = 4
    StyleStr = 1.15
    StyleOff = 1.15
    StyleDef = 1.15
    StyleSpd = 1.15
    Cooldown = 0
    Finisher="/obj/Skills/Queue/Finisher/UBW_finisher"
    adjust(mob/p)
        passives = list("SwordPunching" = 1, "SwordDamage" = 1, "NeedsSword" = 0, "Sword Master" = 1)
    proc/swap_stance(version, sagaLevel)
        switch(version)
            if("Striking")
                StyleStr = 1.15 + (0.05 * sagaLevel)
                StyleSpd = 1.15 + (0.05 * sagaLevel)
                StyleOff = 1.15 + (0.05 * sagaLevel)
                StyleDef = 1
                StyleEnd = 1
            if("Defensive")
                StyleEnd = 1.15 + (0.05 * sagaLevel)
                StyleSpd = 1.15 + (0.05 * sagaLevel)
                StyleDef = 1.15 + (0.05 * sagaLevel)
                StyleStr = 1
                StyleOff = 1
            if("Neutral")
                StyleStr = 1.1 + (0.05 * sagaLevel)
                StyleOff = 1.1 + (0.05 * sagaLevel)
                StyleDef = 1.1 + (0.05 * sagaLevel)
                StyleSpd = 1.1 + (0.05 * sagaLevel)
                StyleEnd = 1.1 + (0.05 * sagaLevel)
            if("Default")
                StyleStr = 1.15 + (0.05 * sagaLevel)
                StyleOff = 1.15 + (0.05 * sagaLevel)
                StyleDef = 1.15 + (0.05 * sagaLevel)
                StyleSpd = 1.15 + (0.05 * sagaLevel)
                StyleEnd = 1


    verb/Striking_Stance()
        set category = "Stances"
        if(usr.BuffOn(src))
            turnOff(usr)
        swap_stance("Striking", usr.SagaLevel)
        src.Trigger(usr, 1)
        giveBackTension(usr)
    verb/Defensive_Stance()
        set category = "Stances"
        if(usr.BuffOn(src))
            turnOff(usr)
        swap_stance("Defensive", usr.SagaLevel)
        src.Trigger(usr, 1)
        giveBackTension(usr)
    verb/Neutral_Stance()
        set category = "Stances"
        if(usr.BuffOn(src))
            turnOff(usr)
        swap_stance("Neutral", usr.SagaLevel)
        src.Trigger(usr, 1)
        giveBackTension(usr)
    verb/Default_Stance()
        set category = "Stances"
        if(usr.BuffOn(src))
            turnOff(usr)
        swap_stance("Default", usr.SagaLevel)
        src.Trigger(usr, 1)
        giveBackTension(usr)





/obj/Skills/Queue/Finisher/UBW_finisher
    InstantStrikes = 6
    DamageMult = 0.75
    FollowUp="/obj/Skills/AutoHit/UBW_FollowUP"
    BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Stunted"
    BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Sword_Flow"



/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Stunted
    IconLock='SweatDrop.dmi'
    IconApart=1
    StrMult=0.8
    OffMult=0.8
    SpdMult=0.8
    DefMult=0.8
    EndMult=0.8
    CrippleAffected = 2
    ActiveMessage="has been overwhelmed by the onslaught!"
    OffMessage="regains their composure!"


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Sword_Flow
    passives = list("ManaGeneration" = 5, "Brutalize" = 1.5, "Flow" = 1, "Instinct" = 1, "Warping" = 4)
    Warping=4
    TimerLimit=45
    ActiveMessage="is in the flow of battle!"
    OffMessage="loses their focus!"

/obj/Skills/AutoHit/UBW_FollowUP
    Area="Target"
    NoLock=1
    NoAttackLock=1
    Distance=3
    Instinct=4
    DamageMult=2
    Rounds=4
    StrOffense=1
    ActiveMessage="sends a barrage of swords at their enemy!"
    HitSparkIcon='Slash - Zan.dmi'
    HitSparkX=-16
    HitSparkY=-16
    HitSparkSize=2
    HitSparkTurns=1
    HitSparkLife=10
    IconTime=10
    Cooldown=4