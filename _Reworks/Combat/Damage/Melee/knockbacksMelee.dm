/mob/proc/getMeleeKnockback(mob/enemy)
    var/knockDistance = 0
    if(Grab==enemy)
        knockDistance += 5
        Grab=null
    if(UsingCriticalImpact())
        knockDistance *= 1.25
    return knockDistance

