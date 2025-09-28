

/obj/Skills/Queue/Finisher
    Dark_Dragon_Commandment
        Combo=5
        DamageMult=0.5
        Instinct=2
        InstantStrikes = 5
        FollowUp="/obj/Skills/AutoHit/One_Inch_Finisher"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Wing_Chun_Essence"

    Dim_Mak
        BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Death_Mark"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Contempt_for_the_Weak"
        //TODO: finisher this
        DamageMult=2
    Leg_Grab
        Instinct=2
        Grapple=1
        KBMult=0.001
        SweepStrike=1
        Crushing = 5
        DamageMult = 2.5
        UnarmedOnly=1
        GrabTrigger="/obj/Skills/Grapple/Giant_Swing"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Iron_Muscle"
        HitMessage="grabs hold of their enemy!"
    Mouton_Shot
        KBMult=0.001
        Crippling=30
        DamageMult=2.5
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Diable_Jambe"
        HitMessage="springs into a handstand, launching a destructive kick from below!"
        FollowUp="/obj/Skills/AutoHit/Flamberge_Shot"
    Heavenly_Dragons_Omniscient_Surge
        Warp = 10
        Bolt = 1
        Shining = 1
        Explosive = 1
        Shocking = 4
        Shattering = 4
        Instinct = 2
        PushOut=2
        PushOutWaves=2
        Decider = 4
        DamageMult=0.33
        KBAdd = 3
        InstantStrikes=10
        FollowUp="/obj/Skills/AutoHit/Heavenly_Dragon_Violet_Ponds_Annihilation_of_the_Nine_Realms"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Heavenly_Dragons_Transient_Enlightenment"
        HitMessage="Summons the boundless might of their martial arts, entering into a breakthrough by pure technique alone. Roars that turn into unstoppable torrent of energy erupt from their body while it soars through the battlefield, unleashing a symphony of cataclysmic destruction paired with ethereal grace. They have unlocked the ultimate testament to the Heavenly Dragon Stance, a dance of power and honor that surpasses the mortal plane, from the divine heights of the quasi-god realm, they descend as the Heavenly Dragon. Harnessing the boundless force of the Nine converging Realms, they unleash a relentless storm of peerless strength, devastating the battle field."



    Behemoth_Typhoon
        Steady = 4
        WeaponBreaker = 2
        Crushing = 20
        Finisher = 1
        DamageMult = 1
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Arena_Champion"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Finisher/QueueBuff/Marked"
        HitMessage="BEHEMOTH TYPHOOOOOOONNNNN"
        FollowUp="/obj/Skills/AutoHit/Giga_Impact"
    Rashomon
        DamageMult=2
        Warp=3
        SpeedStrike=3
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shredded"
        HitMessage=""
        FollowUp="/obj/Skills/AutoHit/Rashomon"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Nito_Ichi_Style"
    Roppon_me_Morote_Tsuki
        InstantStrikes = 3
        DamageMult = 1
        SpeedStrike = 2
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shredded"
        HitMessage=""
        FollowUp="/obj/Skills/Queue/Finisher/Body_Flicker_Technique"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Iai"
    Body_Flicker_Technique
        Combo=20
        DamageMult = 0.15
        HitMessage="rips through their opponent with countless slashes!"
        BuffSelf=0
        HitSparkIcon = 'Slash_Multi.dmi'
    Moon_Fall
        DamageMult=2
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Guard_Break"
        HitMessage=""
        FollowUp="/obj/Skills/AutoHit/The_Moon"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Crescent_Blessing"
    Zwerchhau
        HarderTheyFall = 1
        DamageMult = 2
        Decider = 2
        DrawIn = 3
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Fimbulwinter"
        HitMessage=""
        FollowUp="/obj/Skills/AutoHit/Great_Cleave"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Zwercopter"
    



    Major_Eruption
        FollowUp="/obj/Skills/Projectile/Meteor_Volcano"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Magma_Fist"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Crumbling"
        DamageMult = 2
    Ice_Time
        Stunner = 4
        DamageMult = 2
        FollowUp="/obj/Skills/Projectile/Two_Thorn_Pikes"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Chilled"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Cool_Guy"
    Stormweaver
        DamageMult = 2
        FollowUp="/obj/Skills/AutoHit/Orb_of_Storms"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Buffered"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Conduit"
    Sunshine_Flame
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Flame_Fist"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ignited"
        FollowUp="/obj/Skills/Projectile/Precept_Flame_Emperor"
        DamageMult = 2
    
    Bloodcurdle
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Bloodsurge"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Itchy_Blood"
        FollowUp="/obj/Skills/AutoHit/Hemoplague"
        DamageMult = 2
    Maxima_Press
        DamageMult=3
        Launcher=3
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Forced_Mechanize"
        HitMessage="drags their opponent by their face, launching them up with a magnetic charge!"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Reversal_Mastery"