/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura
    AlwaysOn = 1
    TimerLimit = 0
    NeedsPassword = 1
    var/skillToToss = null
    var/TossSkill = 1
    GainLoop(mob/source)
        ..()

    Water
        skillToToss = "/obj/Skills/Projectile/Bubblebeam"
    Fire
        skillToToss = "/obj/Skills/Projectile/Fire_Blast"
    Earth
        skillToToss = "/obj/Skills/AutoHit/Earthquake"
    Wind
        skillToToss = "/obj/Skills/AutoHit/Hurricane"
    
    Poison
        skillToToss="/obj/Skills/AutoHit/Blood_Whips"
