globalTracker/var
    CHAOS_RESIST_EPT = 0.10;
    CHAOS_RESIST_MIN = 0;
    CHAOS_RESIST_MAX = 5;

passiveInfo/ChaosResist
    setLines()
        lines = list("Reduces the damage you take from attackers aligned Good or Evil, but increases the damage you take from every unaligned source by the same amount.",\
"Each tick of the passive is worth [glob.outputVariableInfo("CHAOS_RESIST_EPT")]% damage reduction against a Good- or Evil-aligned source and [glob.outputVariableInfo("CHAOS_RESIST_EPT")]% extra damage taken from any unaligned source.",\
"Minimum number of ticks: [glob.outputVariableInfo("CHAOS_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("CHAOS_RESIST_MAX")]");

#define FULL_CHAOS_AMT 1
mob/proc/
    getChaosResistValue()
        . = FULL_CHAOS_AMT
        . -= (getChaosResist() * glob.CHAOS_RESIST_EPT);
        . = clamp(., getMaxChaosResistValue(), getMinChaosResistValue());
    getChaosResistVulnValue()
        . = FULL_CHAOS_AMT
        . += (getChaosResist() * glob.CHAOS_RESIST_EPT);
    getChaosResist()
        . = 0
        . += passive_handler.Get("ChaosResist");
        . = clamp(., glob.CHAOS_RESIST_MIN, glob.CHAOS_RESIST_MAX);
    getMinChaosResistValue()
        . = FULL_CHAOS_AMT - (glob.CHAOS_RESIST_MIN * glob.CHAOS_RESIST_EPT)
    getMaxChaosResistValue()
        . = FULL_CHAOS_AMT - (glob.CHAOS_RESIST_MAX * glob.CHAOS_RESIST_EPT)
