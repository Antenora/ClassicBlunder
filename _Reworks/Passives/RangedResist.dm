globalTracker/var
    RANGED_RESIST_EPT = 0.1;
    RANGED_RESIST_MIN = -10;
    RANGED_RESIST_MAX = 5;

passiveInfo/RangedResist
    setLines()
        lines = list("Modifies the amount of damage projectiles and beams deal to you. Positive numbers mean taking less damage, and negative numbers mean taking more.",\
"Each tick of the passive is worth [glob.outputVariableInfo("RANGED_RESIST_EPT")]% modification of your projectile and beam damage taken.",\
"Minimum number of ticks: [glob.outputVariableInfo("RANGED_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("RANGED_RESIST_MAX")]");

#define FULL_RANGED_DMG 1
mob/proc/
    getRangedResistValue()
        . = FULL_RANGED_DMG;
        . -= (getRangedResist() * glob.RANGED_RESIST_EPT);
        . = clamp(., getMaxRangedResistValue(), getMinRangedResistValue());
        DEBUGMSG("using [.] as ranged resist multiplier (should be clamped between [getMaxRangedResistValue()] and [getMinRangedResistValue()])");
    getRangedResist()
        . = 0;
        . += passive_handler.Get("RangedResist");
        . = clamp(., glob.RANGED_RESIST_MIN, glob.RANGED_RESIST_MAX);
    getMaxRangedResistValue()
        . = (glob.RANGED_RESIST_EPT * glob.RANGED_RESIST_MAX);
    getMinRangedResistValue()
        . = FULL_RANGED_DMG - (glob.RANGED_RESIST_EPT * glob.RANGED_RESIST_MIN);