
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/
    NeedsPassword=1//all triggered by buffself queues
    TimerLimit=60
    AlwaysOn=1
    Cooldown=4

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Resisted
    TimerLimit = 30
    CrippleAffected = 1
    OffMult = 0.8
    DefMult = 0.8
    passives = list("Flow" = -1, "FluidForm" = -1)
    ActiveMessage = "resists most of the effects of the King's Will!"
    OffMessage = "regains their will to fight!"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Shaken
    TimerLimit = 60
    OffMult = 0.8
    DefMult = 0.8
    StrMult = 0.8
    CrippleAffected = 1
    passives = list("PureReduction" = -1, "Flow" = -1, "FluidForm" = -1)
    ActiveMessage = "is shaken by the King's Will!"
    OffMessage = "regains their will to fight!"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Destroyed_Will
    TimerLimit = 180
    OffMult = 0.6
    DefMult = 0.6
    StrMult = 0.6
    CrippleAffected = 1
    passives = list("PureReduction" = -2, "Flow" = -2, "FluidForm" = -2)
    ActiveMessage = "is completely overwhelmed by the King's Will!"
    OffMessage = "regains their will to fight!"

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HakiDebuffs/Unconscious
    TimerLimit = 1
    HealthDrain = 99
    ActiveMessage = "is knocked out by unfathomable willpower!"
    

