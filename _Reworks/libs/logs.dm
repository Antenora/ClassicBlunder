/globalTracker/var/SHAR_COPY_ALL = FALSE // just fuck it
/globalTracker/var/SHAR_COPY_EQUAL_OR_LOWER = TRUE // 1 tier behind
/globalTracker/var/SHAR_COPY_MANUAL = FALSE // lol put a gun to ur brain
/globalTracker/var/SHAR_COPY_PLUS = FALSE // +1 would be tier = tier in terms of saga:skill, +2 higher


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