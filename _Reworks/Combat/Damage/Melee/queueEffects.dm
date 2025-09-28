/mob/proc/doQueueEffects(mob/enemy)
    if(!AttackQueue)
        return
    if(AttackQueue?.SpecialEffect)
        var/specialEffect = AttackQueue.SpecialEffect
        var/list/turf/T = Turf_Circle(enemy, AttackQueue.SpecialEffectRange)
        var/image/i
        if(specialEffect == "Darkness")
            i = image(icon='Night.dmi', layer=MOB_LAYER+1)
            for(var/turf/turf in T)
                spawn(rand(2,8))
                    turf.overlays += i
                    spawn(20)
                        turf.overlays -= i
        else
            for(var/turf/turf in T)
                spawn(rand(4,8))

                switch(specialEffect)
                    if("Ice")
                        new/turf/Ice1(locate(turf.x,turf.y,turf.z))
                    if("Fire")
                        new/turf/Waters/Water7(locate(turf.x,turf.y,turf.z))
                spawn(rand(4,8))
                    Destroy(turf)

            if(specialEffect=="Thunder")
                LightningBolt(enemy, AttackQueue.SpecialEffectRange)
            if(specialEffect=="Smash")
                for(var/turf/turf in T)
                    sleep(-1)
                    Dust(turf)
    if(AttackQueue.Grapple)
        Grab_Mob(enemy, Forced=1)
    if(istype(AttackQueue, /obj/Skills/Queue/Heavy_Strike))
        if(passive_handler["Heavy Strike"] == "Unseen Predator")
            applyDebuff(enemy, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Marked_Prey, FALSE, FALSE, FALSE)
        if(passive_handler["Heavy Strike"] == "Fox Fire")
            applyDebuff(enemy, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Soul_Drained, FALSE, FALSE, FALSE)
    if(AttackQueue.Explosive)
        Bang(enemy.loc, AttackQueue.Explosive)
    if(AttackQueue.Shining)
        KenShockwave(enemy,icon='fevKiai.dmi',Size=4)
    if(AttackQueue.MultiHit)
        AttackQueue.HitsUsed++
        if(AttackQueue.InstantStrikes)
            AttackQueue.InstantStrikesPerformed=0
        if(AttackQueue.HitsUsed >= AttackQueue.MultiHit)
            AttackQueue.HitsUsed = 0
            ClearQueue()
            sleep()
    else
        if(!AttackQueue.Combo)
            ClearQueue()
            sleep()
        else if(AttackQueue.Combo)
            if(AttackQueue.InstantStrikes)
                AttackQueue.InstantStrikesPerformed=0
            if(AttackQueue.HitsUsed >= AttackQueue.Combo)
                ClearQueue()
                sleep()

