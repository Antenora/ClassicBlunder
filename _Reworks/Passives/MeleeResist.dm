globalTracker/var
    MELEE_RESIST_EPT = 0.1;//10% normal attack / queue negation Effect Per Tick
    MELEE_RESIST_MIN = -10;
    MELEE_RESIST_MAX = 5;

passiveInfo/MeleeResist
    setLines()
        lines = list("Modifies the amount of damage normal attacks and queues deal to you. Positive numbers mean taking less damage, and negative numbers mean taking more.",\
"Each tick of the passive is worth [glob.outputVariableInfo("MELEE_RESIST_EPT")]% modification of your melee taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("MELEE_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("MELEE_RESIST_MAX")]");

#define FULL_MELEE_DMG 1
mob/proc/
    getMeleeResistValue()
        . = FULL_MELEE_DMG;
        . -= (getMeleeResist() * glob.MELEE_RESIST_EPT);//ranges from -1 to 0.5 in 0.1 increments
        . = clamp(., getMaxMeleeResistValue(), getMinMeleeResistValue());//reversed order is correct for negative value
        DEBUGMSG("using [.] as melee resist multiplier (should be clamped between [getMaxMeleeResistValue()] and [getMinMeleeResistValue()])");
    getMeleeResist()
        . = 0;
        . += passive_handler.Get("MeleeResist");
        . = clamp(., glob.MELEE_RESIST_MIN, glob.MELEE_RESIST_MAX);
    getMaxMeleeResistValue()
        . = (glob.MELEE_RESIST_EPT * glob.MELEE_RESIST_MAX);
    getMinMeleeResistValue()
        . = FULL_MELEE_DMG - (glob.MELEE_RESIST_EPT * glob.MELEE_RESIST_MIN);