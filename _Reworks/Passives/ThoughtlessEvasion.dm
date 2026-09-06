globalTracker/var
    THOUGHTLESS_EVASION_CHANCE = 10;

passiveInfo/ThoughtlessEvasion
    setLines()
        lines = list("Each pip of ThoughtlessEvasion gives you a chance (currently set to [glob.outputVariableInfo("THOUGHTLESS_EVASION_CHANCE")]) to avoid most projectile class attacks.");


mob/proc
    canThoughtlessEvasion()
        . = 0;
        . += passive_handler.Get("ThoughtlessEvasion");
        . *= glob.THOUGHTLESS_EVASION_CHANCE;
        if(. > 0)
            if(prob(.))
                return TRUE;
        return FALSE;