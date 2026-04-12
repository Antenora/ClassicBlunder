globalTracker/var
    BURN_RESIST_EPT = 0.2;//20% burn negation Effect Per Tick
    BURN_RESIST_MIN = -5;
    BURN_RESIST_MAX = 5;

passiveInfo/BurnResist
    setLines()
        lines = list("Modifies the amount of Burn debuff you take. Positive numbers mean taking less Burn, and negative numbers mean taking more Burn.",\
"Each tick of the passive is worth [glob.outputVariableInfo("BURN_RESIST_EPT")]% modification of your Burn debuff taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("BURN_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("BURN_RESIST_MAX")]");

#define FULL_BURN_AMT 1
mob/proc/
    getBurnResistValue()
        . = FULL_BURN_AMT
        . -= (getBurnResist() * glob.BURN_RESIST_EPT);
        . = clamp(., getMaxBurnResistValue(), getMinBurnResistValue());//reversed min/max order is correct for negative value
        DEBUGMSG("using [.] as burn resistance multiplier (should be clamped between [getMaxBurnResistValue()] and [getMinBurnResistValue()])");
    getBurnResist()
        . = 0
        . += passive_handler.Get("BurnResist");
        . = clamp(., glob.BURN_RESIST_MIN, glob.BURN_RESIST_MAX);
    getMinBurnResistValue()
        . = FULL_BURN_AMT - (glob.BURN_RESIST_MIN * glob.BURN_RESIST_EPT)
    getMaxBurnResistValue()
        . = FULL_BURN_AMT - (glob.BURN_RESIST_MAX * glob.BURN_RESIST_EPT)
