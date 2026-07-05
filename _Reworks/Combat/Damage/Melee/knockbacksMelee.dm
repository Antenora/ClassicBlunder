/mob/proc/getMeleeKnockback(mob/enemy)
    var/knockDistance = 0
    knockDistance += passive_handler.Get("KBAdd")
    if(Grab==enemy)
        knockDistance += 5
        Grab=null
    if(passive_handler.Get("Meaty Paws") && !HasSword())
        knockDistance += passive_handler.Get("Meaty Paws") * 0.5
    if(UsingCriticalImpact())
        knockDistance *= 1.25

