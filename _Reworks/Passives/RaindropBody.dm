passiveInfo/RaindropBody
    setLines()
        lines = list("RaindropBody will make it so that you are not affected negatively by combat slow.",
        "Specifically, if your initial delay (from raw speed) is less than your final delay, then you will use your raw speed instead.");

/mob/proc
    hasRaindropBody()
        if(passive_handler.Get("RaindropBody")) return 1;
        return 0;