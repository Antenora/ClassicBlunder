/obj/Skills/Queue
    JawStrike//t1
        name="Ryushosen"
        StyleNeeded="Hiten Mitsurugi"
        DamageMult=2
        AccuracyMult = 4
        SpeedStrike=2
        KBMult=0.0001
        Launcher=3
        Rapid=1
        Duration=5
        Cooldown=30
        EnergyCost=2
        HitMessage="strikes their opponent in the jaw with the flat of their sword!"
        verb/Ryushosen()
            set category="Skills"
            usr.SetQueue(src)
    FallingBlade//t1
        name="Ryutsuisen"
        StyleNeeded="Hiten Mitsurugi"
        DamageMult=2.5
        AccuracyMult = 4
        SpeedStrike=2
        Dunker=2
        Rapid=1
        Duration=5
        Cooldown=30
        EnergyCost=2
        HitMessage="jumps up and brings their blade down to add momentum to their strike!"
        verb/Ryutsuisen()
            set category="Skills"
            usr.SetQueue(src)
    Twin_Dragon_Slash//T3
        name="Souryusen"
        StyleNeeded="Hiten Mitsurugi"
        DamageMult=5
        AccuracyMult = 4
        KBMult=0.0001
        SpeedStrike=2
        Duration=5
        Instinct=3
        Cooldown=120
        Rapid=1
        EnergyCost=5
        HitMessage="strikes with their blade faster than the eye can see!"
        HitStep=/obj/Skills/Queue/Sheath_Strike
        MissStep=/obj/Skills/Queue/Sheath_Strike
        verb/Souryusen()
            set category="Skills"
            usr.SetQueue(src)
    Sheath_Strike//T3
        HitMessage="whips their sheath to follow up with their blade!"
        DamageMult=1
        AccuracyMult = 4
        KBMult=2
        SpeedStrike=4
        Warp=3
        Shattering=5
        Stunner=2
        Duration=5
        NeedsSword=1
        Instinct=4
        Rapid=1
        HitSparkIcon='Hit Effect.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkSize=1.5
    Nine_Dragons_Strike//T5
        name="Kuzuryusen"
        StyleNeeded="Hiten Mitsurugi"
        DamageMult=1
        AccuracyMult = 4
        KBMult=0.00001
        SpeedStrike=6
        InstantStrikes=9
        InstantStrikesDelay=1
        //do the combo message thing
        Warp=10
        Duration=20
        Finisher=1
        Cooldown=180
        HitSparkIcon='Hit Effect Ripple.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkSize=4
        HitSparkDispersion=1
        PushOut=1
        Rapid=1
        PushOutIcon='BLANK.dmi'
        Instinct=4
        EnergyCost=5
        verb/Kuzuryusen()
            set category="Skills"
            usr.SetQueue(src)
    Heavenly_Dragon_Flash//T6
        name="Amakakeru Ryuu no Hirameki"
        StyleNeeded="Hiten Mitsurugi"
        Duration=8
        DamageMult=8
        SpeedStrike=15
        AccuracyMult=4
        KBMult=0.00001
        Warp=10
        Instinct=4
        DrawIn=4
        Determinator=1
        Finisher=1
        Rapid=1
        Counter=1
        NoWhiff=1
        AntiSunyata=1
        Cooldown=-1
        HitSparkIcon='Slash - Power.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkSize=2
        PushOut=5
        AllOutAttack=1
        PushOutIcon='BLANK.dmi'
        HitStep=/obj/Skills/Queue/Heavenly_Dragon_Claw
        MissStep=/obj/Skills/Queue/Heavenly_Dragon_Claw
        ActiveMessage="grips the handle of their blade tightly!"
        HitMessage="utilizes a stutter-step to surpass godspeed with a single blow!"
        MissMessage="generates a powerful vacuum as their slash is blocked, drawing the opponent in!!!"
        verb/Amakakeru_Ryuu_no_Hirameki()
            set category="Skills"
            usr.SetQueue(src)
    Heavenly_Dragon_Claw//T6
        StyleNeeded="Hiten Mitsurugi"
        Duration=10
        DamageMult=8 // but gimp damage since u will be doing 3x
        SpeedStrike=15 // p much get all ur speed
        AccuracyMult=20
        KBAdd=10
        Warp=10
        Instinct=10
        Quaking=10
        Rapid=1
        Counter=1
        NoWhiff=1
        Determinator=1
        AntiSunyata=1
        Decider=1
        Finisher=1
        HitSparkIcon='Slash - Power.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkSize=3
        HitMessage="throws all of their momentum into a centrifugal force-powered finishing blow!!!"

/obj/Skills/AutoHit/
    NestedSlash//T2
        name="Ryusousen"
        StyleNeeded="Hiten Mitsurugi"
        Area="Arc"
        StrOffense=1
        DamageMult = 3
        Launcher = 2
        ComboMaster = 1
        EnergyCost=2
        Rush=3
        ControlledRush=1
        Cooldown=60
        Icon='Nest Slash.dmi'
        IconTime=0.7
        IconX=-16
        IconY=-16
        Size=0.8
        HitSparkIcon='Slash.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkSize=0.8
        HitSparkTurns=1
        HitSparkCount=10
        NoLock=1
        NoAttackLock=1
        ActiveMessage="throws countless sword strikes in an endless flurry!"
        verb/Ryusousen()
            set category="Skills"
            usr.Activate(src)
    CoiledSlash//T2
        name="Ryukansen"
        NeedsSword=1
        StyleNeeded="Hiten Mitsurugi"
        Area="Wave"
        ComboMaster = 1;
        StrOffense=1
        DamageMult=5
        ChargeTech=1
        SpeedStrike = 2
        Crippling = 50
        PassThrough = 1
        ChargeTime=0
        DelayTime=0
        Cooldown=60
        Distance = 3
        Size=1
        Rounds=6
        Icon='Air Slash.dmi'
        IconX=-8
        IconY=-8
        HitSparkIcon='Slash.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkSize=0.8
        HitSparkTurns=1
        TurfStrike=1
        EnergyCost=2
        NoLock=1
        NoAttackLock=1
        ActiveMessage="bursts forward, performing a whirling slash!"
        verb/Ryukansen()
            set category="Skills"
            usr.Activate(src)

    Sonic_Sheath//T4
        name="Ryumeisen"
        Area="Circle"
        StrOffense=1
        StyleNeeded="Hiten Mitsurugi"
        DamageMult=10
        Distance=7
        GuardBreak = 1
        PassThrough=1
        Stunner=5
        PreShockwave=1
        Shockwave=5
        Shockwaves=5
        PostShockwave=0
        Cooldown=180
        NoLock=1
        NoAttackLock=1
        HitSparkIcon='BLANK.dmi'
        ActiveMessage="sheathes their sword with stunning authority!"
        verb/Ryumeisen()
            set category="Skills"
            usr.Activate(src)

/obj/Skills/Projectile/Sword/
    Hiten_Mitsurugi
        StyleNeeded="Hiten Mitsurugi"
        Earth_Dragon_Flash//T3
            name="Doryusen"
            Distance=5
            AccMult = 1.25
            DamageMult=2
            Blasts=5
            Radius=1
            Slashing=0
            Striking=1
            Crushing=2
            Crippling=2
            EnergyCost=5
            Cooldown=90
            Stream=2
            IconLock='Boulder Normal2.dmi'
            IconSize=0.2
            LockX=-36
            LockY=-36
            Variation=12
            verb/Doryusen()
                set category="Skills"
                usr.UseProjectile(src)
/obj/Skills/Buffs/SlotlessBuffs/
    Dance_Of_The_Full_Moon//T4
        StyleNeeded="Hiten Mitsurugi"
        NeedsSecondSword=1
        StrMult = 1.2
        SpdMult = 1.3
        OffMult = 1.3
        passives = list("DoubleStrike" = 2, "Reversal" = 0.5, "Deflection" = 3, "Flow" = 4)
        ActiveMessage="draws a second blade in display of mastery of their style!"
        OffMessage="sheathes their second blade..."
        verb/Dance_Of_The_Full_Moon()
            set category="Skills"
            src.Trigger(usr)
    Autonomous
        Hitokiri_Battosai//T4
            StyleNeeded="Hiten Mitsurugi"
            SpecialBuffLock=1
            NeedsHealth=50
            TooMuchHealth=75
            StrMult = 1.5
            SpdMult = 1.5
            passives = list("TripleStrike" = 0.25, "MovementMastery"=5, "Instinct" = 1, "AutoAnger"=1, "EndlessAnger"=1, "Curse" = 1)
            IconLock='SlayerEyes.dmi'
            LockX=0
            LockY=0
            Cooldown=-1
            TextColor=rgb(215, 0, 0)
            BuffName="Battosai"
            ActiveMessage="becomes the embodiment of battoujutsu, an unstoppable manslayer Battosai!"
            OffMessage="restrains their nature as a killer..."
            Trigger(mob/User, Override = FALSE)
                if(!User.BuffOn(src))
                    Mastery = (User.SagaLevel-3);
                    passives["TripleStrike"] = (0.25*Mastery);
                    passives["MovementMastery"] = max(5, 2.5*Mastery);
                    passives["Instinct"] = Mastery;
                    if(Mastery>=4) passives["TechniqueMastery"]=5;
                    NeedsHealth = min(90, 50 + ((Mastery-1) * 12.5));
                    TooMuchHealth = min(100, 75 + ((Mastery-1) * 6.25));
                ..()
