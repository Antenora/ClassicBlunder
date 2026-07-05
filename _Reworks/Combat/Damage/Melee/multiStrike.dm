/mob/proc/MultiStrike(secondStrike, thirdStrike, asuraStrike)
    if(!AttackQueue)
        var/doubleStrikeChance = GetDoubleStrike()
        if(prob(min(doubleStrikeChance, 100)) && !secondStrike)
            #if DEBUG_MELEE
            log2text("Double Strike", "Double Strike proc'd", "damageDebugs.txt", "[ckey]/[name]")
            #endif
            Melee1(SecondStrike=1)
            var/tripleStrikeChance = GetTripleStrike()
            if(prob(min(tripleStrikeChance, 100)) && !thirdStrike && secondStrike)
                #if DEBUG_MELEE
                log2text("Triple Strike", "Triple Strike proc'd", "damageDebugs.txt", "[ckey]/[name]")
                #endif
                Melee1(SecondStrike=1, ThirdStrike=1) // TODO come back to this, this is odd
                var/asuraStrikeChance = GetAsuraStrike()
                if(prob(min(asuraStrikeChance, 100)) && !asuraStrike && thirdStrike && secondStrike)
                    #if DEBUG_MELEE
                    log2text("Asura Strike", "Asura Strike proc'd", "damageDebugs.txt", "[ckey]/[name]")
                    #endif
                    Melee1(SecondStrike=1, ThirdStrike=1, AsuraStrike=1)