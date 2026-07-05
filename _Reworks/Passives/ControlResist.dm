globalTracker/var
    CONTROL_RESIST_EPT = 0.2;//20% CC negation Effect Per Tick
    CONTROL_RESIST_MIN = 0;
    CONTROL_RESIST_MAX = 4;

passiveInfo/ControlResist
    setLines()
        lines = list("Modifies the amount of Launched and Stunned you take. Positive numbers mean taking less CC.",\
"Each tick of the passive is worth [glob.outputVariableInfo("CONTROL_RESIST_EPT")]% modification of your crowd control effects taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("CONTROL_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("CONTROL_RESIST_MAX")]");

#define FULL_CC_DURATION 1
mob/proc/
    getControlResistValue()
        . = FULL_CC_DURATION;
        . -= (getControlResist() * glob.CONTROL_RESIST_EPT);//ranges from 0 to 0.8 in 0.2 increments
        . = max(., getMaxControlResistValue());
        DEBUGMSG("using [.] as control resist value (should be higher than [getMaxControlResistValue()])")
    getControlResist()
        . = 0;
        . += passive_handler.Get("ControlResist");
        . = clamp(., glob.CONTROL_RESIST_MIN, glob.CONTROL_RESIST_MAX);
    getMaxControlResistValue()
        . = FULL_CC_DURATION - (glob.CONTROL_RESIST_EPT * glob.CONTROL_RESIST_MAX);