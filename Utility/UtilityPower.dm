//this proc returns ascension level or transformation level, whatever is higher
//used in some secrets like Eldritch which may be used by trans or asc races
/mob/proc/getProgressionLevel()
    var/asc = AscensionsAcquired;
    DEBUGMSG("[src]'s ascension level is read as [asc]");
    var/trans = transActive;
    DEBUGMSG("[src]'s transformation level is read as [trans]")
    var/r = max(0, max(asc, trans))
    DEBUGMSG("returning [r]");
    return r;