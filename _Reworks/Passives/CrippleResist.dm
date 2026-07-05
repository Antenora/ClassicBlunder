globalTracker/var
    CRIPPLE_RESIST_EPT = 0.2;//20% cripple negation Effect Per Tick
    CRIPPLE_RESIST_MIN = -5;
    CRIPPLE_RESIST_MAX = 5;

passiveInfo/CrippleResist
    setLines()
        lines = list("Modifies the amount of Cripple debuff you take. Positive numbers mean taking less Cripple, and negative numbers mean taking more Cripple.",\
"Each tick of the passive is worth [glob.outputVariableInfo("CRIPPLE_RESIST_EPT")]% modification of your Cripple debuff taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("CRIPPLE_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("CRIPPLE_RESIST_MAX")]");

#define FULL_CRIPPLE_AMT 1
mob/proc/
    getCrippleResistValue()
        . = FULL_CRIPPLE_AMT
        . -= (getCrippleResist() * glob.CRIPPLE_RESIST_EPT);
        . = clamp(., getMaxCrippleResistValue(), getMinCrippleResistValue());//reversed min/max order is correct for negative value
        DEBUGMSG("using [.] as cripple resistance multiplier (should be clamped between [getMaxCrippleResistValue()] and [getMinCrippleResistValue()])");
    getCrippleResist()
        . = 0
        . += passive_handler.Get("CrippleResist");
        . = clamp(., glob.CRIPPLE_RESIST_MIN, glob.CRIPPLE_RESIST_MAX);
    getMinCrippleResistValue()
        . = FULL_CRIPPLE_AMT - (glob.CRIPPLE_RESIST_MIN * glob.CRIPPLE_RESIST_EPT)
    getMaxCrippleResistValue()
        . = FULL_CRIPPLE_AMT - (glob.CRIPPLE_RESIST_MAX * glob.CRIPPLE_RESIST_EPT)
