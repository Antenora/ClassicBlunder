passiveInfo/ElementalLock
    setLines()
        lines = list("ElementalLock holds a list of potential Magic elements.",
        "If an element is contained within your ElementalLock passive list, then you are expressly forbidden from purchasing that magic element tree",
        "regardless of RPP or Progression points, and you cannot even use skills of that class.",
        "However, if you have the SAME element contained in ElementalLock and ElementalMastery, then ElementalMastery will supercede this passive.");
    setBalanceNote()
        balanceNote = {"The intent behind this passive is to let the character feel like their energy is charged with, or at least completely opposed to, 
another element. After all, unless someone <i>specifically</i> trained to handle both water and fire at the same time, it would feel a bit strange to 
allow these things, if those powers came from your own bloodline, y'know?"};

//TODO: add this in to the magic acquisition code once shane is done with it
//shit b changin !!
//TODO: also add it in to skill code for queues, autohits and projectiles, to assess Elemental Class and prevent usage of forbidden techniques
//(unless elementalmastery is also present for those techniques)
mob/proc
    GetElementalLockList()
        var/list/eLock = passive_handler.Get("ElementalLock");

        //NO
        if(!eLock) return 0;//if there are no elements in the passive, just say no
        if(eLock.len <= 0) return 0;

        //YES
        return eLock;
        