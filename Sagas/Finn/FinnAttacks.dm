/obj/Skills/var/altered = FALSE
/obj/Skills/Queue/High_Five_Dude
    Explosive = 1
    Cooldown = 30
    Dominator = 1
    Dunker = 1 
    PushOut = 3
    DamageMult = 0.1
    PridefulRage = 1
    Duration = 4
    HitMessage = "high fives their opponent!"
    ActiveMessage = "sets up a high five!"
    AccuracyMult = 5
    EnergyCost = 2
    proc/init(mob/p)
        if(altered) return
        var/sagaLevel = p.SagaLevel
        PushOut = 1 + sagaLevel / 2
        DamageMult = 0.2 + (0.1 * sagaLevel)
        AccuracyMult = 5 + (sagaLevel)
        Dunker = 1 + sagaLevel / 4
        Explosive = 1 + sagaLevel / 4
        Dominator = 1 + sagaLevel / 4
    verb/High_Five_Dude()
        set category = "Skills"
        init(usr)
        usr.SetQueue(src)



/obj/Skills/AutoHit/Bombastic_Dive
    Cooldown = 80
    NeedsSword = 1
    Area = "Circle"
    Rush = 1
    ControlledRush = 1
    Rounds = 10
    ComboMaster = 1
    DamageMult = 0.1
    Size = 0.5
    Knockback = 0.01
    Icon='CircleWind.dmi'
    IconX=-32
    IconY=-32
    HitSparkIcon='Slash.dmi'
    HitSparkX=-16
    HitSparkY=-16
    HitSparkTurns=1
    HitSparkSize=1
    HitSparkDispersion=1
    TurfStrike=1
    ActiveMessage="spins for glory!"
    StrOffense = 1
    proc/init(mob/p)
        if(altered) return
        var/sagaLevel = p.SagaLevel
        Rounds = 10 + sagaLevel * 2
        Rush = 5 + sagaLevel * 2
        Size = 0.75 + (0.1 * sagaLevel)
        Knockback = 0.01 + (sagaLevel / 16)
        DamageMult = 0.2 + (0.05 * sagaLevel)
    verb/Bombastic_Dive()
        set category = "Skills"
        init(usr)
        usr.Activate(src)

/obj/Skills/AutoHit/Mathematical_Dash
    Cooldown = 60
    NeedsSword = 1
    Area = "Arc"
    Rush = 1
    ControlledRush = 1
    Distance = 2
    DamageMult = 0.15
    Rounds = 5
    RoundMovement = 0
    Size = 0.75
    TurfStrike = 1
    TurfShift = 'Dirt1.dmi'
    TurfShiftDuration = 1
    Icon='Nest Slash.dmi'
    IconX=-16
    IconY=-16
    HitSparkIcon='Slash.dmi'
    HitSparkX=-32
    HitSparkY=-32
    HitSparkTurns=1
    HitSparkSize=1
    HitSparkDispersion=1
    EnergyCost = 5
    StrOffense = 0.8
    Knockback = 3
    proc/init(mob/p)
        if(altered) return
        var/sagaLevel = p.SagaLevel
        Rush = 5 + sagaLevel * 2
        Distance = 2 + (sagaLevel / 4)
        Size = 0.125 + (0.125 * (sagaLevel))
        Rounds = 4 + (2 * sagaLevel) 
        Knockback = 3 + sagaLevel / 2
        DamageMult = 0.15 + (0.01 * sagaLevel)
        StrOffense = 0.8 + (0.1 * sagaLevel/2)
    verb/Mathematical_Dash()
        set category = "Skills"
        init(usr)
        usr.Activate(src)