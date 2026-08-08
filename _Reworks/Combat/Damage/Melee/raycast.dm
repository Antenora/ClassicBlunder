/mob/proc/getEnemies(forcehit = null)
    var/list/mob/people = list()
    if(forcehit)
        people+=forcehit
    var/obj/Skills/Queue/q = AttackQueue

    // normally get the block in front and return anybody on it
    if(passive_handler["Hit Scan"])
        var/hs = 1 + passive_handler["Hit Scan"]
        if(get_dist(get_turf(src), get_turf(Target)) <= hs || InBodyReach(Target, 32*(hs-1))) //-1: the base tile is the body edge itself
            people += Target
            if(!(Target in get_step(src,dir)) && !InBodyReach(Target))
                NextAttack+=glob.HIT_SCAN_DELAY
    if(q && q.PrecisionStrike)
        if(get_dist(get_turf(src), get_turf(Target)) <= q.PrecisionStrike || InBodyReach(Target, 32*(q.PrecisionStrike-1)))
            people += Target
            if(!(Target in get_step(src,dir)) && !InBodyReach(Target))
                NextAttack+=10
    else if(HasSweepingStrike() && !q)
        var/range = passive_handler.Get("SweepingStrike")
        range = max(range, 1);
        for(var/mob/M in oview(range, src))
            if(M != src && M.density)
                if(istype(M, /mob/irlNPC))
                    continue
                people += M
        for(var/mob/M in BodyReachMobs(32*(range-1)))
            if(M in people) continue
            if(istype(M, /mob/irlNPC)) continue
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
            for(var/mob/M in BodyReachMobs())
                if(M in people) continue
                if(istype(M, /mob/irlNPC)) continue
                people += M
    else
        for(var/mob/M in get_step(src, dir))
            if(M != src && M.density)
                if(istype(M, /mob/irlNPC))
                    continue
                people += M
        //a giant's loc tile is one corner of its art: also take anything whose BODY we can reach
        for(var/mob/M in BodyReachMobs())
            if(M in people) continue
            if(istype(M, /mob/irlNPC)) continue
            people += M
    if(Grab)
        people += Grab
    if(party)
        people.Remove(party.members)
    if(glob.MELEE_DEBUG && client)
        var/td = Target ? get_dist(get_turf(src), get_turf(Target)) : -1
        src << "melee-dbg: dir=[dir] tdist=[td] bodyreach=[Target ? InBodyReach(Target) : "no target"] hitscan=[passive_handler["Hit Scan"]] sweep=[HasSweepingStrike()] prec=[q ? q.PrecisionStrike : 0] warp=[getWarpingStrike()] hits=[people.len]"
    return people

/mob/Admin2/verb/Melee_Debug_Toggle()
    set category = "Admin"
    set name = "Melee Debug Toggle"
    glob.MELEE_DEBUG = !glob.MELEE_DEBUG
    src << "Melee debug: [glob.MELEE_DEBUG ? "ON - every swing prints which branch acquired the target and at what distance" : "OFF"]."