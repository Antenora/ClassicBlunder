globalTracker/var
    CHILL_RESIST_EPT = 0.2;//20% chill negation Effect Per Tick
    CHILL_RESIST_MIN = -5;
    CHILL_RESIST_MAX = 5;

passiveInfo/ChillResist
    setLines()
        lines = list("Modifies the amount of Chill debuff you take. Positive numbers mean taking less Chill, and negative numbers mean taking more Chill.",\
"Each tick of the passive is worth [glob.outputVariableInfo("CHILL_RESIST_EPT")]% modification of your Chill debuff taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("CHILL_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("CHILL_RESIST_MAX")]");

#define FULL_CHILL_AMT 1
mob/proc/
    getChillResistValue()
        . = FULL_CHILL_AMT
        . -= (getChillResist() * glob.CHILL_RESIST_EPT);
        . = clamp(., getMaxChillResistValue(), getMinChillResistValue());//reversed min/max order is correct for negative value
        DEBUGMSG("using [.] as chill resistance multiplier (should be clamped between [getMaxChillResistValue()] and [getMinChillResistValue()])");
    getChillResist()
        . = 0
        . += passive_handler.Get("ChillResist");
        . = clamp(., glob.CHILL_RESIST_MIN, glob.CHILL_RESIST_MAX);
    getMinChillResistValue()
        . = FULL_CHILL_AMT - (glob.CHILL_RESIST_MIN * glob.CHILL_RESIST_EPT)
    getMaxChillResistValue()
        . = FULL_CHILL_AMT - (glob.CHILL_RESIST_MAX * glob.CHILL_RESIST_EPT)
