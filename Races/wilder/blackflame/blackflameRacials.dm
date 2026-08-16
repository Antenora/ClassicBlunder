/mob/proc/isBlackflame()
    if(!isRace(WILDER)) return 0;
    if(Class != "Blackflame") return 0;
    return 1;

/obj/Skills/AutoHit/Wilder
    Blackflame_Breath
        Area = "Wave";
        DamageMult = 1.5;
        Rounds = 3;
        Slow = 0.1;
        TurfErupt = 1;
        
        StrScaling = 0.5;
        ForScaling = 0.5;
        EndEffectiveness = 0.75;
        Scorching = 5;
        Toxic = 5;
        FrenzyDebuff = 5;
        Stunner = 1;
        ComboMaster = 1;
        //Notably does not have grab master
        //Do not give it grab master
        //🔫
        adjust(mob/p)



/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage
    TooMuchHealth = 35
    NeedsHealth = 10
    Cooldown = -1
    SpdMult=1.5
    DefMult=0.5
    EndMult=0.9
    ActiveMessage = "is too angry to die!"
    adjust(mob/p)
        TooMuchHealth = 35
        TimerLimit = 10 + (glob.racials.UNDYINGRAGE_DURATION * (p.AscensionsAcquired))
        passives = list("Undying Rage" = 1, "Fury" = 1 + p.AscensionsAcquired, "Godspeed" = 3, "Relentlessness" = 1, "ShearImmunity" = 1, "Adrenaline" = 3, "LifeSteal" = 50 + (25 * p.AscensionsAcquired), \
                         "Rage" = p.AscensionsAcquired)
    Trigger(mob/User, Override)
        . = ..()
        if(!User.BuffOn(src))
            adjust(User)


/obj/Skills/AutoHit/Darkness_Roar
    Area="Circle"
    DamageMult=0.1
    Rounds=1
    TurfDirt=1
    TurfErupt=1
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
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        Stunner = 5 + asc
        Distance = 4 + asc
        DamageMult = 0.25 + asc
    verb/Darkness_Roar()
        set category="Skills"
        if(!Using) adjust(usr)
        usr.Activate(src)


/obj/Skills/AutoHit/Flame_Roar
    Area="Arc"
    DamageMult=0.1
    Rounds=1
    TurfDirt=1
    TurfErupt=1
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
    SpecialAttack = 1
    DelayTime = 3
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        Distance = 2 + (asc * 2)
        Size = 2 + asc
        Scorching = 8 + (8 * asc)
        DamageMult = 12 + (asc * 2)
        Rounds = 4 + asc
        DamageMult = (DamageMult / Rounds)
    verb/Flame_Roar()
        set category="Skills"
        if(!Using) adjust(usr)
        usr.Activate(src)

/obj/Skills/AutoHit/Fire_Breath
    ElementalClass="Fire"
    SpecialAttack=1
    Scorching=30
    TurfErupt=1
    WindUp=0.5
    WindupMessage="breathes deeply..."
    ActiveMessage="lets loose an enormous breath infused with fire!"
    Slow=1
    Area="Arc"
    adjust(mob/p)
        var/asc = p.AscensionsAcquired;
        DamageMult = 3 + (1.5 * asc)
        Cooldown = 60 - (5 * asc)
        Distance = 6 + (3 * asc)
        ForScaling = 0.3 + (0.1 * asc)
        StrScaling = 0.3 + (0.1 * asc)
    verb/Fire_Breath()
        set category="Skills"
        if(!Using) adjust(usr);
        usr.Activate(src);

/obj/Skills/AutoHit/Frenzy_Breath
    ElementalClass="Dark"
    SpecialAttack=1
    WindUp=0.5
    Area="Arc"
    ObjIcon=1
    Size=1.5
    Rounds=1
    DelayTime=2
    HitSparkIcon='fevExplosion - Hellfire.dmi'
    HitSparkX=-32
    HitSparkY=-32
    HitSparkTurns=1
    HitSparkSize=1
    HitSparkDispersion=1
    TurfStrike=1
    adjust(mob/p)
        var/asc = usr.AscensionsAcquired;
        DamageMult = 6 + (1.5 * asc)
        Cooldown = 60 - (5 * asc)
        Distance = 6 + (4 * asc)
        StrScaling = 1 + (0.25 * asc)
        FrenzyDebuff = 40 + (10 * asc)
    verb/Frenzy_Breath()
        set category="Skills"
        if(!Using) adjust(usr);
        usr.Activate(src)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Frenzy_Mantle
    ActiveMessage = "adorns themselves in a mantle of dark energy... has your shadow always been this prominent?"
    OffMessage = "releases their mantle of darkness..."
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        ..(p);
        strAdd = 0.075 * asc
        spdAdd = 0.075 * asc
        ElementalOffense = "Dark"
        ElementalDefense = "Dark"
        NeedsHealth = 50 + (5*asc);
        TooMuchHealth = min(95, 75 + (5*asc));
        passives = list( "AbyssMod" = asc/2, "HellPower" = asc/6, "HellRisen" = asc/4,  "FrenzyCarrier" = 1)
    Trigger(mob/User, Override = FALSE)
        if(!User.BuffOn(src)) adjust(User)
        ..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Heat_Of_Passion
    ActiveMessage = "ignites themselves in a blaze of passion!"
    OffMessage = "calms their fiery passion..."
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        ..(p);
        strAdd = 0.15 * asc
        ElementalOffense = "Fire"
        ElementalDefense = "Fire"
        passives = list("Scorching" = (clamp(asc*0.5, 1, 3)) , "SoulFire" = asc,  \
                         "PureDamage" = asc + 1)
    Trigger(mob/User, Override = FALSE)
        if(!User.BuffOn(src)) adjust(User)
        ..()