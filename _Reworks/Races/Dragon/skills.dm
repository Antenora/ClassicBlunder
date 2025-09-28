/obj/Skills/Buffs/SlotlessBuffs/Autonomous/DragonDebuff
	NeedsPassword = 1
	TimerLimit = 1
	Cooldown = 4
	AlwaysOn = 1
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/DragonDebuff/Rattled
    CrippleAffected = 3
    EndMult = 0.9
    DefMult = 0.4
    SpdMult = 0.3
    passives = list("PureReduction" =  -1, "Godspeed" = -3)
    TimerLimit = 20

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
            if("Metal")
                TurfErupt=1
                Stunner = 2 + asc
                BuffAffected ="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/DragonDebuff/Rattled"
                Distance = 2 + (asc)
                Rounds = 1
                DamageMult = 0.5 + (asc * 1)
                EndDefense = 0.5
            if("Water")
                ElementalClass="Water"
                Distance = 10 + (asc * 2)
                PullIn = Distance + (4 * asc)
                Deluge = (300 + (300 * asc)) // 30 seconds + 30 each as
                DamageMult = 12 + (asc * 2)
                NoLock = 1
                WindUp=0.25
                WindupMessage="brings forth the rain..."
                ActiveMessage="swarms the area with a flood!"
                TurfReplace='PlainWater.dmi'
                Area="Circle"
				SpecialAttack=1
				HitSparkIcon='Hit Effect Pearl.dmi'
				HitSparkX=-32
				HitSparkY=-32
				HitSparkTurns=1
				HitSparkSize=1
				TurfStrike=1
    verb/Dragon_Roar()
        set category="Skills"
        adjust(usr)
        usr.Activate(src)