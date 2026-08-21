passiveInfo/SacredArts
    setLines()
        lines = list("Sacred Arts is a binary toggle of a passive.",
        "If it is flagged, then all of your magic attacks are NOT counted as magic attacks, if that would be to your benefit.",
        "Similarly, all unarmed, sword, and spirit attacks ARE counted as magic attacks, if that would be to your benefit.",
        "Importantly, this does not allow the ability to use skills you wouldn't normally (through lack of sword, or magic focus),",
        "it only treats your damage calculation from passives as if it were the ideal type of attack.");
    setBalanceNote()
        balanceNote = {"The intent behind this passive is to capture the feeling of madra being a foreign energy system distinct from ki.
Since magic and madra is basically the same thing, and madra and ki are also pretty much the same thing within that universe,
it's simply treated as whichever is more convenient for a TFF character."};

//TODO: add this check in to various unarmed/sword/spirit/magic damage calculation
//Shit b changing, etc etc
mob/proc
    hasSacredArts()
        . = 0;
        if(passive_handler.Get("SacredArts")) . = 1;