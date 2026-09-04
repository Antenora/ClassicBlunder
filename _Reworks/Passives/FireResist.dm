globalTracker/var
    FIRE_RESIST_EPT = 0.10;
    FIRE_RESIST_MIN = 0;
    FIRE_RESIST_MAX = 5;

passiveInfo/FireResist
    setLines()
        lines = list("Reduces the damage you take from skills with the Fire element (SpellElement or ElementalClass).",\
"Each tick of the passive is worth [glob.outputVariableInfo("FIRE_RESIST_EPT")]% damage reduction against a Fire-element source.",\
"Minimum number of ticks: [glob.outputVariableInfo("FIRE_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("FIRE_RESIST_MAX")]");

#define FULL_FIRE_AMT 1
mob/proc/
    getFireResistValue()
        . = FULL_FIRE_AMT
        . -= (getFireResist() * glob.FIRE_RESIST_EPT);
        . = clamp(., getMaxFireResistValue(), getMinFireResistValue());
    getFireResist()
        . = 0
        . += passive_handler.Get("FireResist");
        . = clamp(., glob.FIRE_RESIST_MIN, glob.FIRE_RESIST_MAX);
    getMinFireResistValue()
        . = FULL_FIRE_AMT - (glob.FIRE_RESIST_MIN * glob.FIRE_RESIST_EPT)
    getMaxFireResistValue()
        . = FULL_FIRE_AMT - (glob.FIRE_RESIST_MAX * glob.FIRE_RESIST_EPT)
