/obj/Skills/Queue/Finisher
    Command_Grab
        Instinct=2
        Grapple=1
        KBMult=0.001
        SweepStrike=2
        Crushing = 20
        DamageMult = 4
        UnarmedOnly=1
        GrabTrigger="/obj/Skills/Grapple/Heavenly_Potemkin_Buster"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Potemkin_Buster"
        HitMessage="grabs hold of their enemy!"


    // same style

    Zetsuei // defensive
		// make animation that makes a clone rapidly strike at from angles, not 2 hard
        InstantStrikes = 13
        InstantStrikesDelay = 0.5
        DamageMult = 0.2
        MortalBlow = 0.5
        FollowUp="/obj/Skills/AutoHit/Shitenketsu"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Cruel_Shadow"
        BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Death_Mark"
    Teiga // damage
        InstantStrikes = 11
        InstantStrikesDelay = 1
        DamageMult = 0.35
        MortalBlow = 1
        Grapple=1
        GrabTrigger="/obj/Skills/Grapple/Ryukoha"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Cruel_Shadow"
        BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Death_Mark"
    // same style 

    Jarret_Jarret
        SweepStrike=4
        SpeedStrike=2
        Bolt=1
        Quaking=5
        PushOut=1
        PushOutWaves=2
        DamageMult=2
        KBAdd=0.001
        FollowUp="/obj/Skills/AutoHit/Jarret_Jarret"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Feng_Shui_Engine"

    // end unarmed


    King_of_Hell
        
        SpeedStrike = 2
        SweepStrike = 2
        Quaking=5
        PushOut=1
        DamageMult = 2
        FollowUp=/obj/Skills/Queue/Finisher/Kokujo_O_Tatsumaki
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Firefox_Style
        BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Shredded
        HitMessage = "breaks off into a relentless pursuit!"
    Kokujo_O_Tatsumaki
        Combo=25
        DamageMult = 0.1
        HitMessage="rips through their opponent with countless slashes!"
        BuffSelf=0
        HitSparkIcon = 'Slash_Multi.dmi'

    Dragon_Slayer
        HarderTheyFall=4
        Stunner=4
        KBMult = 0.0001
        FollowUp=/obj/Skills/AutoHit/Divide_Effect
        DamageMult = 3
        Decider = 4
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Indomitable_Will
        BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Fimbulwinter
        HitMessage = "sends a massive cleaving sword strike forward!"
    Hunt
        Dominator = 1
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Righteous_Crusade
        BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Staked
        DamageMult = 3
        Stunner = 2
        KBMult = 3
        HitMessage = "prepares the hunt by pinning their prey to the ground!"
        FollowUp=/obj/Skills/AutoHit/Pinning_Stake
        

    Divine_Finisher
        name = "Heavenly Demon's Radiant Divine Palm that Shatters the Nine Heavens and Illuminates the Eternal Night"
        Warp = 10
        Bolt = 1
        Shining = 1
        Explosive = 1
        Instinct = 2
        PushOut=1
        PushOutWaves=4
        SweepStrike=2
        Decider=4
        DamageMult=3
        KBAdd = 0.01
        FollowUp="/obj/Skills/AutoHit/The_Heavenly_Demons_Fist_That_Cleaves_Through_Heaven_And_Divides_The_Sea"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Emergent_Demon_Breakthrough"

    Bauf_Burst // ifrit
        KBMult=0.001
        Crippling=15
        Scorching=15
        DamageMult=3
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ifrit_Jambe
        HitMessage="springs into a handstand, launching a destructive kick from below!"
        FollowUp=/obj/Skills/AutoHit/Beef_Burst



    Icy_Glare
        Stunner=8
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Time_Skip
        BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Time_Freeze
        DamageMult = 3
        Explosive = 1
        KBMult = 0.0001
        HitMessage = "unleashes a barrage of punches so fast it is like they stopped time..."
        // FollowUp=/obj/Skills/AutoHit/Deadly_Intent
    Alpha_Strike
        SpeedStrike = 2
        SweepStrike = 2
        Quaking=5
        PushOut=1
        DamageMult = 2
        FollowUp=/obj/Skills/Queue/Finisher/Wuju
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Alpha_Strike
        HitMessage = "breaks off into a relentless pursuit!"
    Blood_Rite
        Crippling=100
        Quaking=2
        PushOut=1
        DamageMult=1
        FollowUp=/obj/Skills/AutoHit/Rupture
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Bloodrage
        BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Silence



    Wuju
        Combo=10
        DamageMult = 0.1
        BuffSelf=0
        HitSparkIcon = 'Slash_Multi.dmi'

    Psycho_Barrage
        BuffSelf=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Reversal_Mastery

    // end hybird?

    Deal_with_the_Devil
        FollowUp = "/obj/Skills/AutoHit/Dantes_Inferno"
        BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/In_the_Details"
        DamageMult = 1.1
        AdaptRate = 1 
    Mega_Arm
        FollowUp = "/obj/Skills/Projectile/Super_Mega_Buster"
        BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/X_Buster"
        BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Plasma_Burned" // pure red 
        DamageMult = 1.1
        AdaptRate = 1 
    Frostfist
        Freezing = 255
        DamageMult = 2
        FollowUp = "/obj/Skills/AutoHit/Ice_Ply"
        BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Frozen_Summit"
        AdaptRate = 1 
    Phosphor
        FollowUp = "/obj/Skills/Projectile/Coldflame_Pale_Blade"
        BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Cooled_Down" 
        DamageMult = 1.1
        AdaptRate = 1 
    Jet_Kindling
        FollowUp = "/obj/Skills/AutoHit/Flashfire_Fist"
        BuffSelf = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Heated_Up" 
        DamageMult = 1.1
        AdaptRate = 1 