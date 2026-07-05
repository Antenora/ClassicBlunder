globalTracker/var
    SHATTER_RESIST_EPT = 0.2;//20% shatter negation Effect Per Tick
    SHATTER_RESIST_MIN = -5;
    SHATTER_RESIST_MAX = 5;

passiveInfo/ShatterResist
    setLines()
        lines = list("Modifies the amount of Shatter debuff you take. Positive numbers mean taking less Shatter, and negative numbers mean taking more Shatter.",\
"Each tick of the passive is worth [glob.outputVariableInfo("SHATTER_RESIST_EPT")]% modification of your Shatter debuff taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("SHATTER_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("SHATTER_RESIST_MAX")]");

#define FULL_SHATTER_AMT 1
mob/proc/
    getShatterResistValue()
        . = FULL_SHATTER_AMT
        . -= (getShatterResist() * glob.SHATTER_RESIST_EPT);
        . = clamp(., getMaxShatterResistValue(), getMinShatterResistValue());//reversed min/max order is correct for negative value
        DEBUGMSG("using [.] as shatter resistance multiplier (should be clamped between [getMaxShatterResistValue()] and [getMinShatterResistValue()])");
    getShatterResist()
        . = 0
        . += passive_handler.Get("ShatterResist");
        . = clamp(., glob.SHATTER_RESIST_MIN, glob.SHATTER_RESIST_MAX);
    getMinShatterResistValue()
        . = FULL_SHATTER_AMT - (glob.SHATTER_RESIST_MIN * glob.SHATTER_RESIST_EPT)
    getMaxShatterResistValue()
        . = FULL_SHATTER_AMT - (glob.SHATTER_RESIST_MAX * glob.SHATTER_RESIST_EPT)
