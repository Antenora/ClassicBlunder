passiveInfo/ElementalTechnique
    setLines()
        lines = list("ElementalTechnique holds a list of potential Magic elements.",
        "For [glob.outputVariableInfo("ELEMENTAL_TECHNIQUE_ACTIVE_TIME")] second\s after using a queue, projectile, or autohit,",
        "a character will be treated as if they have the ElementalOffense and ElementalDefense of all of the elements contained in ElementalTechnique's list.");

globalTracker/var
    ELEMENTAL_TECHNIQUE_ACTIVE_TIME = 2;

//TODO: add this in to queue, projectile, and autohit code when pushed to main
//idk how those skill structures have changed :3
//TODO: Add decrement of ElementalTechniqueActive 
mob/var/tmp/
    ElementalTechniqueActive = 0;//when a queue, projectile, or autohit is used, this is flagged for 2 seconds

mob/proc
    GetElementalTechnique()
        var/list/eTech = passive_handler.Get("ElementalTechnique");

        //NO
        if(!eTech) return 0;//if there are no elements in the passive, just say no
        if(eTech.len <= 0) return 0;

        //YES
        if(ElementalTechniqueActive > 0) return eTech;//if technique is active, then return the list of elements
        return 1;//otherwise, just acknowledge that there IS a list of elements, but don't return it
        