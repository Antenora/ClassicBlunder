#define BASE_SORCERER_RPP_COST = 30

mob/verb/DebugSorcererTree()
    set category = "Debug"
    set name = "Debug Sorcerer Tree"
    if(!SorcererDatum)
        liveDebugMsg("[usr] does not have a Sorcerer Datum")
        return
    usr << "Here are the Sorcerer Saga Skills:"
    for(var/SorcererSagaSkills in SorcererDatum.SorcererSkills)
        usr << "[SorcererSagaSkills]"
mob/var/Portfolio/Sorcerer/SorcererDatum = new()

Portfolio/Sorcerer
    // TECHNIQUE TIER DETERMINATION
    var/list/TierThreeTechniques["Shrine", "Limitless"]
    var/list/TierTwoTechniques["Blood Manipulation", "Disaster Flames", "Disaster Tides", "Disaster Plants"]
    var/list/TierOneTechniques["Ratio", "Ice Formation"]
    proc/TechniqueTier(mob/P)
        if(P.CursedTechnique in TierThreeTechniques)
            return 3
        if(P.CursedTechnique in TierTwoTechniques)
            return 2
        if(P.CursedTechnique in TierOneTechniques)
            return 1
    // INFORMATION
    var
        RPPSpent = 0
        NodesAcquired = 0
    // SKILL POPULATION - AKA HOW WE ADD THE SKILLS TO OUR PLAYERS
    var/list/SorcererSkills = []
    proc/PopulateTechniqueSkills(mob/P)
        switch(P.CursedTechnique)
            if("Limitless")
                SorcereSkills[LimitlessTechniques]
    // TREE BUILDING - UI REQUIRED
    proc/BuildSorcererTree(mob/P)
        var/choice = input(P, "Choose a Skill", "Portfolio Debug") in SorcererSkills
    
