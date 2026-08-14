/*/mob/Admin3/verb/testhellScaling()
    set category = "Debug"
    for(var/x in 1 to 8)
        x /= 4
        src.passive_handler.Set("HellPower", x)
        var/f = file("Saves/testLogs/hellPowerTesting.txt")
        for(var/y in 1 to 100)
            Health = y
            setRace(HUMAN)
            f << "for a human at [y] health, and [x] hell power. hellscaling is [GetHellScaling()]"
            setRace(DEMON)
            f << "for a demon at [y] health, and [x] hell power. hellscaling is [GetHellScaling()]"
            for(var/a in 1 to 50)
                Potential = a
                f << "for a demon at [a] pot, [y] health, and [x] hell power. hellscaling is [GetHellScaling()]"*/
proc/getSharCopyLevel(sagaLevel)
    return sagaLevel




/mob/proc/log2text(attribute, value, filename, src_key)
    var/cont = FALSE
    if(!glob.TESTER_MODE)
        if(glob.LIVE_TESTING)
            cont = TRUE
    else
        cont = TRUE
    if(!cont)
        return
    if(!src_key)
        return
    var/f = file("Saves/damageLogs/[time2text(world.realtime, "MM-DD-YYYY")]/[src.ckey]/[filename]")
    if(f)
        f << "[time2text(world.realtime, "MM-DD-YYYY")]|[world.time] - [src_key] - [attribute] - [value]\n"
    else
        world.log<<"Error! Could not open file!"