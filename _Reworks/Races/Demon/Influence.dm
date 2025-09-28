/datum/DemonRacials

/mob/var/datum/DemonRacials/demon = new()
/datum/DemonRacials/var/icon_to_use = 'LavaRock2.dmi'
/datum/DemonRacials/var/states_to_use = list("")
/datum/DemonRacials/var/layer_to_use = MOB_LAYER-0.5
/datum/DemonRacials/var/list/BuffPassives = list()
/datum/DemonRacials/var/list/DebuffPassives = list()


/datum/DemonRacials/proc/handlePassive(list/theList, input, option)
    . = TRUE
    if(vars["[option]Passives"][input])
        if(vars["[option]Passives"][input] + theList[input][1] > theList[input][2])
            return FALSE
        vars["[option]Passives"][input] += theList[input][1]
    else
        vars["[option]Passives"][input] = theList[input][1]


/datum/DemonRacials/proc/applyDebuffs(mob/p, mob/a, nerf = FALSE)
    var/reduction = 1
    if(nerf)
        reduction = 6 - (p.AscensionsAcquired ? p.AscensionsAcquired : 1)
    for(var/x in DebuffPassives)
        if(x in list("Def", "End", "Str"))
            if(p.vars["[x]Eroded"]<=DebuffPassives[x]/5)
                p.vars["[x]Eroded"]+=glob.racials.DEMON_ERODE_DEBUFF_INTENSITY
        else if(x in list("Poison", "Burn", "Slow"))
            call(p, "Add[x]")((DebuffPassives[x] * glob.racials.DEMON_DOT_DEBUFF_INTENSITY) / reduction, a)
        else
            call(p, "Lose[x]")((DebuffPassives[x] * glob.racials.DEMON_RESOURCE_DEBUFF_INTENSITY) / reduction)


/datum/DemonRacials/proc/selectPassive(mob/p, type, option, starting = FALSE)
    p << "Listing [option] Passives"
    p << jointext(vars["[option]Passives"], " ,")
    var/list/passives =  getJSONInfo(getPassiveTier(p),"[type]")
    if(starting)
        passives = getJSONInfo(list("I"), "[type]")
    var/list/choices = list()
    for(var/a in passives)
        choices += "[a]"
    var/correct = FALSE
    var/attempts = 0
    while(correct == FALSE)
        var/input = input(p, "What do you want to add to your [option] passives?") in choices
        if(attempts >=3)
            p << "You tried too many times, alert an admin"
            break
        if(!handlePassive(passives, input, option))
            p << "Too much passive value"
            correct = FALSE // have them go again
        else
            correct = TRUE
        attempts++
