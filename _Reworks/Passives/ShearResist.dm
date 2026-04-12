globalTracker/var
    SHEAR_RESIST_EPT = 0.2;//20% shear negation Effect Per Tick
    SHEAR_RESIST_MIN = -5;
    SHEAR_RESIST_MAX = 5;

passiveInfo/ShearResist
    setLines()
        lines = list("Modifies the amount of Shear debuff you take. Positive numbers mean taking less Shear, and negative numbers mean taking more Shear.",\
"Each tick of the passive is worth [glob.outputVariableInfo("SHEAR_RESIST_EPT")]% modification of your Shear debuff taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("SHEAR_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("SHEAR_RESIST_MAX")]");

#define FULL_SHEAR_AMT 1
mob/proc/
    getShearResistValue()
        . = FULL_SHEAR_AMT
        . -= (getShearResist() * glob.SHEAR_RESIST_EPT);
        . = clamp(., getMaxShearResistValue(), getMinShearResistValue());//reversed min/max order is correct for negative value
        DEBUGMSG("using [.] as shear resistance multiplier (should be clamped between [getMaxShearResistValue()] and [getMinShearResistValue()])");
    getShearResist()
        . = 0
        . += passive_handler.Get("ShearResist");
        . = clamp(., glob.SHEAR_RESIST_MIN, glob.SHEAR_RESIST_MAX);
    getMinShearResistValue()
        . = FULL_SHEAR_AMT - (glob.SHEAR_RESIST_MIN * glob.SHEAR_RESIST_EPT)
    getMaxShearResistValue()
        . = FULL_SHEAR_AMT - (glob.SHEAR_RESIST_MAX * glob.SHEAR_RESIST_EPT)
