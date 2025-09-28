/mob/proc/MultiStrike(secondStrike, thirdStrike)
    if(!AttackQueue)
        var/dblProb = glob.DOUBLESTRIKECHANCE * GetDoubleStrike()
        var/tripleProb = glob.TRIPLESTRIKECHANCE * GetTripleStrike()
        if(HasDoubleStrike())
            if(prob(dblProb + tripleProb) && !secondStrike)
                #if DEBUG_MELEE
                log2text("Double Strike", "Double Strike proc'd", "damageDebugs.txt", "[ckey]/[name]")
                #endif
                Melee1(SecondStrike=1)
            if(HasTripleStrike())
                if(prob(tripleProb) && !thirdStrike && secondStrike)
                    #if DEBUG_MELEE
                    log2text("Triple Strike", "Triple Strike proc'd", "damageDebugs.txt", "[ckey]/[name]")
                    #endif
                    Melee1(SecondStrike=1, ThirdStrike=1) // TODO come back to this, this is odd