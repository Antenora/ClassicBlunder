/knowledgeTracking
    var/list/learnedKnowledge = list() // set learnedKnowledge["Path"] = 1
    var/list/learnedMagic = list() 


/mob/var/knowledgeTracking/knowledgeTracker = new()



/mob/proc/addUnlockedTech(n, ty)
    switch(ty)
        if("Technology")
            if(n in knowledgeTracker.learnedKnowledge)
                return
            knowledgeTracker.learnedKnowledge += n

/mob/proc/removeUnlockedTech(n, ty)
    switch(ty)
        if("Technology")
            if(n in knowledgeTracker.learnedKnowledge)
                knowledgeTracker.learnedKnowledge -= n
