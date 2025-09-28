/mob/proc/FindSkill(typePath)
    if(ispath(typePath) || istext(typePath))
        if(ispath(typePath))
            return locate(typePath, src)
        for(var/obj/Skills/skill in src)
            if("[skill.type]" == "[typePath]")
                return skill
    else
        if(typePath in src)
            return typePath
    return FALSE


/mob/proc/hasTarget()
    if(Target && Target != src)
        return TRUE
    return FALSE

/mob/proc/getHealth()
    return Health*(1-HealthCut)

proc/aboveThreshold(val1, val2, thres)
    if(val1 - val2 >= thres)
        return TRUE
    return FALSE




/mob/proc/isDominating(mob/target)
    if(!ismob(target))
        return FALSE
    var/asc = AscensionsAcquired
    var/dominatingThreshold = 2 // a 5 hp difference atleast
    var/neededHealth = 50 // they need to be above 75% health
    neededHealth -= clamp((asc * 10),10,40) // for every ascension, they need 5% less health
    if(getHealth() >= neededHealth)
        if(aboveThreshold(getHealth(), target.getHealth(), dominatingThreshold))
            return TRUE
    return FALSE

var/GLOBAL_AI_DAMAGE = 2

/mob/Admin3/verb/Change_AI_Damage()
    var/num = input("Enter a number ") as num
    if(num)
        GLOBAL_AI_DAMAGE = num
        src << "AI damage is now set to [num]"

/mob/Admin3/verb/Check_AI_Damage()
    src << "AI damage is currently set to [GLOBAL_AI_DAMAGE]"
