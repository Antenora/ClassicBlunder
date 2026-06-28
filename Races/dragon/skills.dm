/obj/Skills/Buffs/SlotlessBuffs/Autonomous/DragonDebuff
	NeedsPassword = 1
	TimerLimit = 1
	Cooldown = 4
	AlwaysOn = 1
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/DragonDebuff/WeakenedByRadiance
    CrippleAffected = 3
    StrMult = 0.6
    ForMult = 0.6
    OffMult = 0.6
    passives = list("FatigueLeak" = 1, "PureDamage" = -1)
    TimerLimit = 20;

/obj/Skills/AutoHit/Dragon_Roar
    Area="Circle"
    AdaptRate=1
    DamageMult=0.1
    Rounds=1
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
    adjust(mob/p)
        var/asc = p.AscensionsAcquired
        switch(p.Class)
            if("Wind")
                Knockback = 0.25
                Distance = 8 + (asc * 5)
                Paralyzing = 8 + (8 * asc)
                DamageMult = 6 + (asc * 1)
                Rounds = 8 + (asc * 2)
                DamageMult = DamageMult/Rounds
            if("Fire")
                Area="Arc"
                TurfErupt=1
                SpecialAttack=1
                AdaptRate=1
                Distance = 2 + (asc * 2)
                Size = 2 + (asc * 1 )
                Scorching = 8 + (8 * asc)
                DamageMult = 12 + (asc * 2)
                Rounds = 4 + (asc)
                DelayTime = 3
                DamageMult = DamageMult/Rounds
            if("Dark")
                TurfErupt=1
                Stunner = 5 + asc
                Distance = 4 + asc
                Rounds = 1
                DamageMult = 0.25 + (asc * 1)
            if("Gold")
                TurfErupt=1
                Distance = 4 + asc
                Rounds = 1
                DamageMult = 4 + (asc * 1)
            if("Light")
                TurfErupt=1
                ElementalClass="Light"
                Distance = 6 + asc
                BuffAffected ="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/DragonDebuff/WeakenedByRadiance"
                Rounds = 1
                DamageMult = 1 + (asc * 1.5)
    verb/Dragon_Roar()
        set category="Skills"
        adjust(usr)
        usr.Activate(src)