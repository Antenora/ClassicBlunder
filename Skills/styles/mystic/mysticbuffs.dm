/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Aura
    AlwaysOn = 1
    TimerLimit = 0
    NeedsPassword = 1
    var/skillToToss = null
    var/TossSkill = 1
    GainLoop(mob/source)
        ..()
        if(!glob.AURASPELLONATTACK)
            if(!source.AttackQueue&&TossSkill)
                if((source.last_aura_toss - ((source.passive_handler["Familiar"]-1) * glob.FAMILIAR_CD_REDUCTION)) + glob.FAMILIAR_SKILL_CD < world.time && (source.Target && source.Target != source))
                    source.last_aura_toss = world.time
                    source.throwFollowUp(skillToToss)

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
