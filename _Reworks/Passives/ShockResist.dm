globalTracker/var
    SHOCK_RESIST_EPT = 0.2;//20% shock negation Effect Per Tick
    SHOCK_RESIST_MIN = -5;
    SHOCK_RESIST_MAX = 5;

passiveInfo/ShockResist
    setLines()
        lines = list("Modifies the amount of Shock debuff you take. Positive numbers mean taking less Shock, and negative numbers mean taking more Shock.",\
"Each tick of the passive is worth [glob.outputVariableInfo("SHOCK_RESIST_EPT")]% modification of your Shock debuff taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("SHOCK_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("SHOCK_RESIST_MAX")]");

#define FULL_SHOCK_AMT 1
mob/proc/
    getShockResistValue()
        . = FULL_SHOCK_AMT
        . -= (getShockResist() * glob.SHOCK_RESIST_EPT);
        . = clamp(., getMaxShockResistValue(), getMinShockResistValue());//reversed min/max order is correct for negative value
        DEBUGMSG("using [.] as shock resistance multiplier (should be clamped between [getMaxShockResistValue()] and [getMinShockResistValue()])");
    getShockResist()
        . = 0
        . += passive_handler.Get("ShockResist");
        . = clamp(., glob.SHOCK_RESIST_MIN, glob.SHOCK_RESIST_MAX);
    getMinShockResistValue()
        . = FULL_SHOCK_AMT - (glob.SHOCK_RESIST_MIN * glob.SHOCK_RESIST_EPT)
    getMaxShockResistValue()
        . = FULL_SHOCK_AMT - (glob.SHOCK_RESIST_MAX * glob.SHOCK_RESIST_EPT)
