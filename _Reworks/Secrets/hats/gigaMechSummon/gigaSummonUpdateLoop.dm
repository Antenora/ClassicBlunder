/mob/Player/AI/GIGASpiritSummon/proc/isDead()
    if(!ai_owner)
        EndLife(0)
        return TRUE
    if(src.Health<=0 || src.KO)
        if(!src.KO) Unconscious(null, "implodes into a burst of energy!")
        sleep(1)
        EndLife(0)
        return TRUE

/mob/Player/AI/GIGASpiritSummon/proc/handleDecisionMaking()
    var/list/choices = list("attack" = list("melee", "ranged", "dash"), \
    "defend" = list("shield","reverse_dash"), \
    "assist" = list("heal_buff","speed_buff","damage_buff"))
    var/list/weights = list("attack" = 1, "defend" = 1, "assist" = 1)
    var/list/extendedWeights = list("melee" = 1, "ranged" = 1, "dash" = 1, \
    "shield" = 1, "reverse_dash" = 1, "heal_buff" = 1, \
    "speed_buff" = 1, "damage_buff" = 1)
    var/dist_to_owner = getdist(src,ai_owner)
    var/dist_to_enemy = 0
    if(ai_owner.Target)
        dist_to_enemy = getdist(src, ai_owner.Target)
    if(ai_owner.Health < 25 && last_decision != "assist")
        weights["assist"] += 3

    if(dist_to_owner > 5 && dist_to_enemy < 2)
        if(Health < 50)
            weights["defend"] += 1
        else
            weights["attack"] += 1
        weights["defend"] += 1
    
    if(dist_to_enemy >= 5)
        if(last_decision == "ranged")
            weights["attack"] += 1
            extendedWeights["dash"] += 1
        else
            weights["attack"] += 1
            extendedWeights["ranged"] += 1
    var/total_weights = 0
    var/list/barrel = list()
    for(var/weight in weights)
        for(var/i in 1 to weights[weight])
            barrel.Add(weight)
            total_weights ++
    var/decision = barrel[rand(1, total_weights)]
    last_decision = decision
    total_weights = 0
    barrel = list()
    for(var/weight in choices[decision]) // choices["attack"] = list("melee", "ranged", "dash")
        for(var/i in 1 to extendedWeights[weight]) // extendedWeights["melee"] = 1
            barrel.Add(weight)
            total_weights++
    decision = barrel[rand(1, total_weights)]
    last_decision_extended = decision

/mob/Player/AI/GIGASpiritSummon/Update()
    set waitfor=0
    if(isDead())
        return
    if(last_decision == "idle")
        handleDecisionMaking()
    
    switch(last_decision)
        if("attack")
            switch(last_decision_extended)
                if("melee")
                    if(getdist(src, ai_owner.Target) < 2)
                        melee(ai_owner.Target)
                    else
                        dash(ai_owner.Target)
                if("ranged")
                    ranged(ai_owner.Target)
                if("dash")
                    dash(ai_owner.Target)
        if("defend")
            switch(last_decision_extended)
                if("shield")
                    shield()
                if("reverse_dash")
                    reverse_dash()
        if("assist")
            switch(last_decision_extended)
                if("heal_buff")
                    heal_buff()
                if("speed_buff")
                    speed_buff()
                if("damage_buff")
                    damage_buff()
    sleep(1)
    
