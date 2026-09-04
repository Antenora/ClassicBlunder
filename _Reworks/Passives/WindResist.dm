globalTracker/var
    WIND_RESIST_EPT = 0.10;
    WIND_RESIST_MIN = 0;
    WIND_RESIST_MAX = 5;

passiveInfo/WindResist
    setLines()
        lines = list("Reduces the damage you take from skills with the Wind element (SpellElement or ElementalClass).",\
"Each tick of the passive is worth [glob.outputVariableInfo("WIND_RESIST_EPT")]% damage reduction against a Wind-element source.",\
"Minimum number of ticks: [glob.outputVariableInfo("WIND_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("WIND_RESIST_MAX")]");

#define FULL_WIND_AMT 1
mob/proc/
    getWindResistValue()
        . = FULL_WIND_AMT
        . -= (getWindResist() * glob.WIND_RESIST_EPT);
        . = clamp(., getMaxWindResistValue(), getMinWindResistValue());
    getWindResist()
        . = 0
        . += passive_handler.Get("WindResist");
        . = clamp(., glob.WIND_RESIST_MIN, glob.WIND_RESIST_MAX);
    getMinWindResistValue()
        . = FULL_WIND_AMT - (glob.WIND_RESIST_MIN * glob.WIND_RESIST_EPT)
    getMaxWindResistValue()
        . = FULL_WIND_AMT - (glob.WIND_RESIST_MAX * glob.WIND_RESIST_EPT)
