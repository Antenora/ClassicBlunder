/obj/Skills/Queue/Finisher
    Be_Water
        Stunner = 3
        HarderTheyFall = 4
        SweepStrike = 4
        Finisher = 2
        Combo = 25
        Instinct = 2
        InstantStrikes=2
        DamageMult = 0.2
        Quaking=25
        FollowUp="/obj/Skills/AutoHit/True_One_Inch_Punch"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Intercepting_Fist"
        BuffAffected = "/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Death_Mark"
        HitMessage="looks <i>locked in</i>."
    
    Big_Boot
        Instinct=2
        Grapple=1
        KBMult=0.001
        SweepStrike=6
        Crushing = 100
        Stunner = 2
        DamageMult = 6
        UnarmedOnly=1
        GrabTrigger="/obj/Skills/Grapple/Tombstone_Piledriver"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/The_8th_Wonder_Of_The_World"
        HitMessage="places their foot to the face of their fellow wrestler!"

    Soul_Seller
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/True_Form/Demon"
        FollowUp="/obj/Skills/AutoHit/Minor_Reality_Corruption"
        HitMessage = "sells their soul for a brief boost to power!"
    Atomic_Dismantling
        FollowUp="/obj/Skills/AutoHit/Atomic_Dismantling"
        BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Dismantled"
        BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Magnetism"
        HitMessage = "takes apart their foe's defense atomically!"