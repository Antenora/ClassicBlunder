/mob/proc/MClass2Rate(option, _Class)
    . = LOW_RATE
    switch(_Class)
        if("Super")
            return BALANCED_RATE
        if("Innocent")
            return option == "Reduction" ? FULL_RATE : 0
        if("Unhinged")
            return option == "Damage" ? FULL_RATE : 0
/mob/proc/getMajinRates(option)
    if(!isRace(MAJIN))
        return 1
    var/class = Class
    var/redRate = MClass2Rate("Reduction", class)
    var/dmgRate = MClass2Rate("Damage", class)
    if(!option)
        return list(redRate, dmgRate)
    else
        return option == "Reduction" ? redRate : dmgRate

/mob/proc/getMajinMedRate()
    var/base = 1.2 // 20% faster than others
    var/totalAscensions = AscensionsAcquired
    if(totalAscensions > 0)
        base += 0.2 * totalAscensions
    //total ascensions = 5, 1.2 + 0.2 * 5 = 2.2 aka 220% faster
    return base

