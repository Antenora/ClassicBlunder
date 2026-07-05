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
/globalTracker/var/SHAR_COPY_ALL = FALSE // just fuck it
/globalTracker/var/SHAR_COPY_EQUAL_OR_LOWER = TRUE // 1 tier behind
/globalTracker/var/SHAR_COPY_MANUAL = FALSE // lol put a gun to ur brain
/globalTracker/var/SHAR_COPY_PLUS = FALSE // +1 would be tier = tier in terms of saga:skill, +2 higher


proc/getSharCopyLevel(sagaLevel)
    if(glob.SHAR_COPY_ALL)
        return 10
    if(glob.SHAR_COPY_MANUAL)
        return glob.SHAR_COPY_MANUAL
    if(glob.SHAR_COPY_PLUS)
        return sagaLevel + glob.SHAR_COPY_PLUS
    if(glob.SHAR_COPY_EQUAL_OR_LOWER)
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