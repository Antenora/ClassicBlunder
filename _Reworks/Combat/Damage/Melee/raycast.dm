/mob/proc/getEnemies(forcehit = null)
    var/list/mob/people = list()
    if(forcehit)
        people+=forcehit
    var/obj/Skills/Queue/q = AttackQueue

    // normally get the block in front and return anybody on it
    if(passive_handler["Hit Scan"])
        if(get_dist(src, Target) <= 1 + passive_handler["Hit Scan"])
            people += Target
            if(!(Target in get_step(src,dir)))
                NextAttack+=glob.HIT_SCAN_DELAY
    if(q && q.PrecisionStrike)
        if(get_dist(src, Target) <= q.PrecisionStrike)
            people += Target
            if(!(Target in get_step(src,dir)))
                NextAttack+=10
    else if((HasSweepingStrike() || passive_handler.Get("GiantSwings")) && !q)
        var/range = passive_handler.Get("GiantSwings") ? passive_handler.Get("GiantSwings") : 1
        for(var/mob/M in oview(range, src))
            if(M != src && M.density)
                if(istype(M, /mob/irlNPC))
                    continue
                people += M
    else if(passive_handler.Get("PowerPole"))
        var/distance = passive_handler.Get("PowerPole")
        var/totalDist
        switch(dir)
            if(NORTH)
                if(y+distance>world.maxy)
                    totalDist = world.maxy
                else
                    totalDist = y+distance
                for(var/turf/T in block(locate(x,y,z), locate(x, totalDist, z)))
                    for(var/mob/M in T.contents)
                        if(M != src && M.density)
                            if(istype(M, /mob/irlNPC))
                                continue
                            people += M
            if(SOUTH)
                if(y-distance<0)
                    totalDist = 0
                else
                    totalDist = y-distance
                for(var/turf/T in block(locate(x,y,z), locate(x, totalDist, z)))
                    for(var/mob/M in T.contents)
                        if(M != src && M.density)
                            if(istype(M, /mob/irlNPC))
                                continue
                            people += M
            if(EAST)
                if(x+distance>world.maxx)
                    totalDist = world.maxx
                else
                    totalDist = x+distance
                for(var/turf/T in block(locate(x,y,z), locate(totalDist, y, z)))
                    for(var/mob/M in T.contents)
                        if(M != src && M.density)
                            if(istype(M, /mob/irlNPC))
                                continue
                            people += M
            if(WEST)
                if(x-distance<0)
                    totalDist = 0
                else
                    totalDist = x-distance
                for(var/turf/T in block(locate(x,y,z), locate(totalDist, y, z)))
                    for(var/mob/M in T.contents)
                        if(M != src && M.density)
                            if(istype(M, /mob/irlNPC))
                                continue
                            people += M
        if(dir in list(NORTHWEST,NORTHEAST, SOUTHWEST, SOUTHEAST))
            for(var/mob/M in get_step(src, dir))
                if(M != src && M.density)
                    if(istype(M, /mob/irlNPC))
                        continue
                    people += M
    else
        for(var/mob/M in get_step(src, dir))
            if(M != src && M.density)
                if(istype(M, /mob/irlNPC))
                    continue
                people += M
    if(Grab)
        people += Grab
    if(party)
        people.Remove(party.members)
    return people