/globalTracker/var/SAIYAN_DEFIANCE_THRESHOLD_1 = 0.75
/globalTracker/var/SAIYAN_DEFIANCE_THRESHOLD_2 = 1.25
/globalTracker/var/SAIYAN_DEFIANCE_THRESHOLD_3 = 2

/mob/var/last_defiance_proc = 0
/mob/proc/DefianceCalcs(val, mob/attcker)
    var/asc = AscensionsAcquired // its dividing by 0 before
    if(DefianceCounter < 10)
        if(val >= glob.SAIYAN_DEFIANCE_THRESHOLD_1/asc && val < glob.SAIYAN_DEFIANCE_THRESHOLD_2 / asc)
            DefianceCounter += 1
            if(Tail)
                OMessage(10, "<font color=red>[src]'s defiance sparks!","Defiance (1) passive.")
        else if(val >= glob.SAIYAN_DEFIANCE_THRESHOLD_2 / asc && val < glob.SAIYAN_DEFIANCE_THRESHOLD_3 / asc)
            DefianceCounter += 2
            if(Tail)
                OMessage(10, "<font color=red>[src] grows more defiant!","Defiance (2) passive.")
        else if(val >= glob.SAIYAN_DEFIANCE_THRESHOLD_3 / asc)
            DefianceCounter += 3
            if(Tail)
                OMessage(10, "<font color=red>[src] roars in complete defiance of odds!","Defiance (3) passive.")
        if(DefianceCounter>=10)
            DefianceCounter = 10
            if(Tail)
                OMessage(10, "<font color=red>[src]'s defiance reaches its peak!","Defiance (10) passive.")
        if(FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Grit).cooldown_remaining < 1)
            if(Health <= 5) // hasnt been used and they r obligated to get their shit
            // might make this too easy a mechanic
                DefianceCounter = 10