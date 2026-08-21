passiveInfo/ElementalMastery
    setLines()
        lines = list("ElementalMastery holds a list of potential Magic elements.",
        "With this, you are treated as if you are proficient (TKWIP: actually clarify these mechanics once we know if there are tomes or anything still existant!)",
        "with the elements contained within the passive's list. If it is an Advanced element (Light, Dark, Space, Time) then you do not need to spend",
        "a T3 progression point in order to unlock the element. If it is a Basic element, then you are simply allowed to purchase it without regard for",
        "how many elements you already wield.");
    setBalanceNote()
        balanceNote = "The intent behind this passive is to ensure that the user <b>FEELS</b> skilled in a particular element, and is rewarded for using things that align with their powerset.";

//TODO: add this in to the magic acquisition code once shane is done with it
//shit b changin !!
mob/proc
    GetElementalMasteryList()
        var/list/eMaster = passive_handler.Get("ElementalMastery");

        //NO
        if(!eMaster) return 0;//if there are no elements in the passive, just say no
        if(eMaster.len <= 0) return 0;

        //YES
        return eMaster;
        