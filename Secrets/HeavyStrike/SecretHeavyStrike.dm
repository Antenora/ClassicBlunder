//this is defined as a separate type from heavy strike so that we can inherit the default heavy strike behavior, but DON'T inherit the heavy strike verb
/obj/Skills/Queue/Secret_Heavy_Strike
    Duration=5
    DamageMult=2
    AccuracyMult=1
    KBAdd=5
    KBMult=3
    Cooldown=15


//ELDRITCH
#define ELDRITCH_BOON_VARS list("Scorching"=3, "Freezing"=3, "Paralyzing"=3, "Shattering"=3, "Toxic"=3)
/obj/Skills/Queue/Secret_Heavy_Strike
    Maleific_Strike
        DamageMult=3;
        AccuracyMult=3;
        KBAdd=2;
        KBMult=1.5;
        Ooze=1;
        Cooldown=30;
        adjust(mob/p)
            var/maliceValue = (p.getProgressionLevel()*2);
            for(var/v in ELDRITCH_BOON_VARS)
                vars[v] = maliceValue+ELDRITCH_BOON_VARS[v];

//SENJUTSU
/obj/Skills/Queue/Secret_Heavy_Strike
    Sage_Energy_Strike
        AccuracyMult=1.1;
        Cooldown=30;
        ActiveMessage="focuses natural energy in their fist!"
        Scorching=3;
        Freezing=3;
        Shattering=3;
        Paralyzing=3;

//HAKI
/obj/Skills/Queue/Secret_Heavy_Strike/Haki
    AccuracyMult=1.15;
    NoForcedWhiff=1;
    Cooldown=20;
    adjust(mob/p)
        p.AddHaki("Armament");
        p.HakiArmamentOn();
        p.HakiObservationOff();

    BusoKoka
        name="Bosu: Koka"
        KBAdd=10;
        ActiveMessage="darkens their arms in preparation for a devastating attack!"
        HitSparkSize=2;
        IconLock='BusoKoka.dmi'
        adjust(mob/p)
            ..();//do normal haki strike things
            DamageMult = 1 + p.secretDatum.currentTier;
    Armament_Strike
        ActiveMessage="focuses their will into their fist!"

//RIPPLE
/obj/Skills/Queue/Secret_Heavy_Strike/Hamon
    Cooldown=20;
    AccuracyMult=1.15;
    IconLock='Ultima Arm.dmi';

    Ripple_Overdrive
        DamageMult=1;
        HitMessage="channels the Ripple through their strikes: <b>Ripple Overdrive!!</b>";

    Metal_Silver_Overdrive
        Cooldown=30;
        Warp=2;
        HitMessage="channels the Ripple through metal: <b>Metal Silver Overdrive!!</b>";

    Sendo_Ripple_Overdrive
        DamageMult=3;
        AccuracyMult=1.1;
        KBAdd=10;
        KBMult=5;
        Shattering=10;
        HitMessage="channels the Ripple through solid rock: <b>Sendo Ripple Overdrive!!</b>";

    Tornado_Overdrive
        Paralyzing=10;
        Warp=3;
        Rapid=1;
        HitMessage="channels the Ripple through a spinning kick: <b>Tornado Overdrive!!</b>"

    Scarlet_Overdrive
        DamageMult=3;
        AccuracyMult=1.1;
        Scorching=10;
        HitMessage="channels the Ripple into fire: <b>Scarlet Overdrive!!</b>";

    Turqoiuse_Blue_Overdrive
        Freezing=10;
        HitMessage="channels the Ripple through water: <b>Turqoise Blue Overdrive!!</b>";

    Overdrive_Barrage
        DamageMult=1;
        KBAdd=1;
        KBMult=1;
        Cooldown=30;
        Combo=5;
        Warp=5;
        IconLock='Ripple Arms.dmi'
        HitMessage="channels the Ripple for multiple powerful hits: <b>OVERDRIVE BARRAGE!!</b>";

    Flaming_Scarlet_Overdrive//and i do mean flaming
        DamageMult=4;
        Cooldown=30;
        Scorching=20;
        Shattering=20;
        Warp=2;
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/ScarletOverdriven";
        HitMessage="channels the Ripple through razor-sharp heat: <b>Flaming Scarlet Overdrive!!!</b>";

//VAMPIRE
/obj/Skills/Queue/Secret_Heavy_Strike/Vampire
    name="Vampiric Strike"
    AccuracyMult=1.1;
    KBMult=0.0001;
    Cooldown=20;
    LifeSteal=100;
    HitSparkX=-32
    HitSparkY=-32

    Vampire_Strike
        HitSparkIcon='Hit Effect Vampire.dmi'
        HitSparkTurns=0;
        HitSparkSize=1;
        HitMessage="rips out their opponent's life force with a powerful strike!";
    Enhanced_Vampire_Strike
        DamageMult=3;
        AccuracyMult=1.15;
        KBAdd=5;
        HitSparkIcon='Slash - Vampire.dmi'
        HitSparkTurns=1;
        HitSparkSize=2;
        HitMessage="rips their opponent to shreds!";

//WEREWOLF
/obj/Skills/Queue/Secret_Heavy_Strike
    Rip_and_Tear
        AccuracyMult=1.1
        KBAdd=0;
        KBMult=5;
        Cooldown=20;
        HitMessage="digs their claws 🤤 into their opponent to deal crippling wounds!";
        Crippling=3;
        HitSparkIcon='WolfFF.dmi'
        HitSparkX=0
        HitSparkY=0
        HitSparkTurns=1
        HitSparkSize=2

//WITCH
/obj/Skills/Queue/Secret_Heavy_Strike
    Soulsap_Strike
        DamageMult=1.5;
        AccuracyMult=1.15;
        KBAdd=0;
        KBMult=1;
        Cooldown=20;
        Freezing=1;
        Crippling=15;
        CursedWounds=1;
        Decider=1;
        Warp=2;
        HitSparkIcon='Icons/NSE/spells/debuff/holywaterflow.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkTurns=1
        HitSparkSize=1
        ActiveMessage="weaves their hands towards their enemy's centre!";
        HitMessage="grasps hold of their opponent's soul to sap away its energy!";

//ZOMBIE
//why is this so cracked lmao
/obj/Skills/Queue/Secret_Heavy_Strike
    Death_Grasp
        DamageMult=2.5;
        AccuracyMult=1.15;
        KBAdd=0;
        KBMult=1;
        Cooldown=20;
        Toxic=25;
        Shearing=25;
        Crippling=15;
        CursedWounds=1;
        Decider=1;
        Grapple=1;
        HitSparkIcon='Hit Effect Wind.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkTurns=1
        HitSparkSize=1
        HitMessage="grasps hold of their opponent with necrotic energy!";

//HEAVENLY RESTRICTION
#define HEAVENLY_BOON_VARS list("DamageMult"=2, "PushOutWaves"=0, "PushOut"=0, "AccuracyMult"=1, "KBAdd"=5, "KBMult"=1, "Dunker"=0, "Launcher"=0)
/obj/Skills/Queue/Secret_Heavy_Strike
    Heavenly_Strike
        adjust(mob/p)
            var/SecretInformation/HeavenlyRestriction/hs = p.secretDatum;
            var/dunkValue = hs.getBoon(p, "Heavy Strike");
            for(var/v in HEAVENLY_BOON_VARS)
                var/boonedValue = dunkValue + HEAVENLY_BOON_VARS[v];
                vars[v] = boonedValue;
            if(p.Target)
                if(p.Target.Launched)//if they are launched, dunk
                    Dunker = dunkValue;
                else//if they are not launched, launch
                    Launcher = dunkValue;

//SHIN
/obj/Skills/Queue/Secret_Heavy_Strike/Shin
    Duration=10;

    Shin_Strike
        Cooldown=30;
        ActiveMessage="channels Shin into their next strike...";
        HitMessage="delivers a blow radiating with power!";
        adjust(mob/p)
            ManaGain=clamp(p.ShinSecretLevel()*5, 10, 30) // Tier 1/2= 10 tier 3 = 15, Tier 4 = 20 Tier 5 = 25 tier 6 = 30
    Mang_Strike
        Cooldown=40;
        ActiveMessage="concentrates their Mang...";
        KBAdd = 25
        KBMult = 5
        adjust(mob/p)
            DamageMult=clamp(p.GetMangLevel() * 2, 3, 10);
            HitMessage="strikes with the power of [p.GetMangLevel()] Mang Ring\s!!";



//BLACK FLASH
/obj/Skills/Queue/Secret_Heavy_Strike/Black_Flash
    Cooldown=15;
    Duration=5;
    Divergent_Fist
        ActiveMessage="'s own energy lags behind...!"
        HitMessage="'s impact is doubled up from their energy lagging behind!"
        DamageMult=2
        HitSparkIcon='CE Hitspark.dmi'
        HitSparkTurns=1
        HitSparkSize=1
        AccuracyMult=1
        KBAdd=5
        KBMult=3
    Black_Flash_Strike
        TextColor = "#DC143C";
        ActiveMessage="'s fists sparks black...!"
        HitMessage="lands a <b>BLACK FLASH!!</b>"
        DamageMult = (2 ** 2.5)
        AccuracyMult = 10
        KBAdd = 10
        Duration=4
        PushOut=2
        HitSparkX=-14
        HitSparkY=-12
        HitSparkSize=2
        PushOutWaves=3
        PushOutIcon='DarkKiai.dmi'
        HitSparkIcon='Black_Flash_Hitspark_1.dmi'
        HitSparkTurns=1
        HitSparkSize=4
        KBMult = 10
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/BlackFlash_Potential"
        adjust(mob/p)
            var/SecretInformation/BlackFlash/bf = p.secretDatum
            var/sparks = p.passive_handler.Get("Sparks of Black")
            if (sparks == 1)
                if (prob(50))
                    p.JJKNarrate("-- And the momentum is kept. [p]'s retain their current chance to land a Black Flash!!")
                else
                    bf.BlackFlashChance = bf.BlackFlashBaseChance
            else
                bf.BlackFlashChance = bf.BlackFlashBaseChance

//SPIRAL
/obj/Skills/Queue/Secret_Heavy_Strike/
    Spiral_Drill
        DamageMult=2
        AccuracyMult=3
        KBMult=0.1
        Shattering=30
        Cooldown=15
        HitSparkIcon='Spiral_Hitspark.dmi'
        HitSparkX=-32
        HitSparkY=-32
        HitSparkTurns=1
        HitSparkSize=1
        HitMessage="smashes into the wall standing in their way!";
        adjust(mob/p)
            if(p.secretDatum.currentTier>=5)
                BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Spiral/Arc_Evolution"
            if(p.passive_handler.Get("SpiralPowerUnlocked")>=2||p.Health<=50)
                KBMult=3
                KBAdd=25
                FollowUp="/obj/Skills/AutoHit/Spiral/Lagann_Impact2"
            else
                KBMult=3
                KBAdd=25
                FollowUp="/obj/Skills/AutoHit/Spiral/Lagann_Impact"
