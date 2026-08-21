passiveInfo/SacredBody
    setLines()
        lines = list("Sacred Body is a binary toggle of a passive.",
        "If it is flagged, then all of your sword and spirit attacks are counted as if they are Unarmed, IF that would be to your benefit.",
        "The same is not true in reverse; if you hit someone with your fist, they should react as if you fisted them.",
        "Plus, it would be a headache to determine if an unarmed hit was meant to be a sword attack or a spirit attack.",
        "Importantly, this does NOT allow you to use skills you otherwise would not be able to use:",
        "For that, you'd need Bladefisting. Totally different trope.");
    setBalanceNote()
        balanceNote = {"The intent behind this passive is to capture the feeling of sacred arts being an extension of the user.
In the same way that \"a sword is an extension of the artist's body\", madra and madra techniques are meant to act as an expression of will,
more than simply an attack. Grandiose cultivation nonsense, I know."};

//TODO: add this check in to various unarmed/sword/spirit damage calculation
//Shit b changing, etc etc
mob/proc
    hasSacredBody()
        . = 0;
        if(passive_handler.Get("SacredBody")) . = 1;