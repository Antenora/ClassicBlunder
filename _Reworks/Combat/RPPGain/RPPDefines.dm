/mob/Admin3/verb/GetExactTime()
    DaysOfWipe()
    var/day = 24 HOURS
    var/days = (world.realtime / day) - (glob.progress.WipeStart / day)
    src<<(world.realtime / day)
    src<<(glob.progress.WipeStart / day)
    src<<days/day
    src<< "Days since wipe: [days]"
    src<<time2text(days, "DD:MM:YYYY hh:mm:ss")


/mob/proc/GetRPPSpendable()
    var/Total=0
    Total+=src.RPPSpendable
    return Total
/mob/proc/GetRPP()
    var/Total=0
    Total+=src.RPPSpendable
    Total+=src.RPPSpent
    return Total

/proc/getMaxRPP()
    var/max = glob.progress.totalRPPToDate
    if(max > glob.progress.RPPLimit)
        max = glob.progress.RPPLimit
    // this should be the max rpp ppl can have, im p sure
    return max

/mob/proc/setMaxRPP()
    var/max = getMaxPlayerRPP()
    RPPCurrent = max


/mob/proc/getMaxPlayerRPP()
    var/globalMax = getMaxRPP()
    var/Mult = GetRPPMult()
    globalMax *= Mult
    return globalMax // this should be the max rpp a player can have, im p sure

/mob/proc/setStartingRPP()
    if(RPPSpendable+RPPSpent < glob.progress.RPPStarting)
        RPPSpendable = glob.progress.RPPStarting - (RPPSpent)
        RPPCurrent = getMaxPlayerRPP()
    if(RPPCurrent < getMaxPlayerRPP())
        RPPCurrent = getMaxPlayerRPP()
        RPPSpendable = glob.progress.RPPStarting
        RPPSpent = 0

/mob/proc/GiveRPP(amount)
    var/maxRPP = getMaxPlayerRPP()
    RPPCurrent = maxRPP
    if(amount+RPPSpendable+RPPSpent > maxRPP)
        RPPSpendable += maxRPP - (RPPSpendable+RPPSpent)
        src<<"You've been given [maxRPP - (RPPSpendable+RPPSpent)] RPP."
    else
        RPPSpendable += amount
        src<<"You've been given [amount] RPP."