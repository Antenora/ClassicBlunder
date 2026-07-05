// UNARMED
/obj/Skills/Queue/Finisher
    Hold
        Instinct=2
        Grapple=1
        KBMult=0.001
        SweepStrike=1
        DamageMult = 1
        UnarmedOnly=1
        GrabTrigger="/obj/Skills/Grapple/Muscle_Buster"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Anger_Of_The_Beast"
        HitMessage="grabs hold of their enemy!"
    Heavenly_Storm_Dragon_Emergence
        Warp = 10
        Bolt = 1
        Shining = 1
        Explosive = 1
        Shocking = 3
        Shattering = 3
        Instinct = 1
        PushOut=2
        PushOutWaves=3
        Decider = 2
        DamageMult=0.25
        InstantStrikes=10
        FollowUp="/obj/Skills/Queue/Finisher/Heavenly_Dragon_Raging_Tempest"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Heavenly_Dragon_Ascendant_Zenith"
        HitMessage="taps into their ancestral arts! With a roar that echoes through the realms, the force quakes the earth and tears through the skies! The tempest of its fury is a celestial ballet, weaving destruction and honor into the fabric of existence. The path of the Heavenly Dragon has descended upon the mortal realms from the quasi-god realm! Their very presence shakes and alters the fragile reality they reside in! A maelstrom of everlasting power continues to surge, ascending higher and higher! Until the peak of Murim Martial Arts conquers all! That is the Zenith... A god among man!"
    Heavenly_Dragon_Raging_Tempest
        Warp = 3
        Combo=10
        DamageMult = 0.15
        Bolt = 1
        Shining = 1
        Explosive = 1
        KBAdd = 0.001
        PushOut=1
        PushOutWaves=1
        BuffSelf=0
    
    Merciful_Thousand_Leaves_Hand
        FollowUp="/obj/Skills/AutoHit/Arhats_Palm"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shaolin_Step"
        Warp = 5
        Combo = 3
        DamageMult = 5
        KBAdd = 3
        PushOut=1
        PushOutWaves=1
        HitMessage="channels the force of Arhat!"
    
    Four_Virtues
        FollowUp="/obj/Skills/Queue/Finisher/Tranquility"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Unlocked_Potential"
        Warp = 3
        DamageMult = 1.5
        Launcher = 5
        PushOut=1
        PushOutWaves=1
        HitMessage="starts that there combo!"

    Tranquility
        FollowUp="/obj/Skills/Queue/Finisher/Ultimate_Fist"
        BuffSelf=null
        Warp = 3
        DamageMult = 1.5
        Dunker = 1
        PushOut=1
        PushOutWaves=1
        HitMessage="leads into it"
    
    Ultimate_Fist
        DamageMult = 1.5
        KBAdd = 3
        Projectile="/obj/Skills/Projectile/Beams/The_Original_Kamehameha"
        ProjectileBeam=1
        BuffSelf=null



// WEAPON
    Shishi_Sonson
        InstantStrikes = 11
        DamageMult = 0.15
        Instinct = 4
        AccuracyMult = 3
        FollowUp="/obj/Skills/AutoHit/Shishi_Sonson"
        HitMessage="rapidly charges into their target!"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shredded"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Kiri_Otoshi"
    
    La_Rapiere_des_Sorel
        DamageMult = 0.75
        InstantStrikes = 2
        Shocking = 25
        FollowUp="/obj/Skills/AutoHit/Royal_Poison"
        HitMessage="decimates their opponent with an onslaught of blows!"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Guard_Break"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Critical_Edge"
    
    Skofnung


        FollowUp="/obj/Skills/AutoHit/Mjolnir"
        HitMessage="decimates their opponent with an onslaught of blows!"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ragnarok"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Tyrfing"
    
    Challenge
        Warp=10
        DamageMult = 2
        KBMult=0.001
        Instinct = 1
        FollowUp="/obj/Skills/AutoHit/Duel"
        HitMessage="darts at their enemy!"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Champion_Pride"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Finisher/QueueBuff/Marked"

    Grand_Cross
        InstantStrikes = 4
        DamageMult = 0.75
        HolyMod = 1
        FollowUp="/obj/Skills/AutoHit/Uppercut"
        HitMessage=""
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Emperor_Time"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Judgment_Chain"



    Unstoppable_Force
        DamageMult=1.5
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Stone_Fist_Technique"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Crumbling"
        HitMessage="decimates with an Earth-empowered elbow strike to the sternum!"
        FollowUp = "/obj/Skills/AutoHit/Rock_Trail"
    Whirlwind
        DamageMult=1.5
        KBAdd = 3
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Wind_Empowerment"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Buffered"
        HitMessage="steps forward, dropping their Wind-empowered fist like a bolt of lightning!"
        FollowUp = "/obj/Skills/Projectile/Blades_of_Wind"
    Dancing_Flame_Attack
        DamageMult=1.5
        Scorching = 25
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Burning_Hands"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ignited"
        HitMessage="ducks, spins, and delivers an explosive Fire-empowered backhand slam!"
        FollowUp = "/obj/Skills/AutoHit/Great_Fire_Annihilation"
    Surfing_Stream
        DamageMult=1.5
        
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Water_Empowerment"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Chilled"
        HitMessage="crashes down like a wave with a Water-empowered wheel kick!"
        FollowUp = "/obj/Skills/AutoHit/Azure_Dragon_Palm"
    

    Acid_Rain
        DamageMult = 1.5
        Toxic = 25
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Poison_Fist"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Poisoned"
        HitMessage="brings down the acid rain!"
        FollowUp = "/obj/Skills/AutoHit/Toxic_Wheel"
    
    Rusting_Wake
        DamageMult = 1.5
        Toxic = 25
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Wire_Puller"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Rusted"
        HitMessage="envokes the power of rust!"
        FollowUp = "/obj/Skills/AutoHit/Toxic_Wheel"