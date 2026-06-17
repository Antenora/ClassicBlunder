/obj/Skills/Queue/Finisher
//Hiten Finisher
    Flash_Strike
        DamageMult=T2_DMG_MULT/2
        Counter=1
        Warp=10
        SpeedStrike=4
        FollowUp="/obj/Skills/AutoHit/Shunshin_Massacre"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shunshin"
    True_Flash_Strike
        DamageMult=T4_DMG_MULT/2
        Counter=1
        Warp=10
        SpeedStrike=8
        FollowUp="/obj/Skills/AutoHit/Shunshin_Massacre"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Godspeed_Assaulted"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shunshin_Shin"
/obj/Skills/AutoHit/Shunshin_Massacre
    Area="Target"
    NoLock=1
    NoAttackLock=1
    Distance=10
    Instinct=4
    DamageMult = T3_DMG_MULT / 2 / 5;
    Rounds=5
    DelayTime=30
    GuardBreak=1
    StrOffense=1
    EndDefense=1
    PassThrough=1
    ActiveMessage="rips through their opponent with rapid godspeed slashes!"
    HitSparkIcon='Slash - Zan.dmi'
    HitSparkX=-16
    HitSparkY=-16
    HitSparkSize=2
    HitSparkTurns=1
    HitSparkLife=10
    IconTime=10
    Cooldown=4
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff
    Godspeed_Assaulted//debuff
        IconLock='SweatDrop.dmi'
        IconApart=1
        Afterimages=1
        SpdMult=0.5
        DefMult=0.5
        EndMult=0.8
        passives = list("NoDodge" = 1)
        ActiveMessage="fears for their life against a hyperspeed opponent!"
        OffMessage="regains courage!"
    //hiten
    Finisher
        Shunshin//buff
            SpdMult=1.25
            passives = list("TensionLock" = 1,"Warping" = 2, "HotHundred" = 1, "Godspeed" = 2, "BlurringStrikes" = 1)
            TimerLimit=10
            ActiveMessage="moves at godspeed for a rapid attack!"
            OffMessage="restrains their godspeed..."
        Shunshin_Shin//more buff
            SpdMult=1.5
            passives = list("TensionLock" = 1, "Warping" = 3, "Godspeed"=4, "HotHundred" = 2, "PureDamage" = 2, "Steady" = 4, "BlurringStrikes" = 2, "CoolerAfterimages"=2)
            TimerLimit=15
            ActiveMessage="unleashes their godspeed for a short burst!"
            OffMessage="falls back in step..."
