globalTracker/var
    EARTH_RESIST_EPT = 0.10;
    EARTH_RESIST_MIN = 0;
    EARTH_RESIST_MAX = 5;

passiveInfo/EarthResist
    setLines()
        lines = list("Reduces the damage you take from skills with the Earth element (SpellElement or ElementalClass).",\
"Each tick of the passive is worth [glob.outputVariableInfo("EARTH_RESIST_EPT")]% damage reduction against a Earth-element source.",\
"Minimum number of ticks: [glob.outputVariableInfo("EARTH_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("EARTH_RESIST_MAX")]");

#define FULL_EARTH_AMT 1
mob/proc/
    getEarthResistValue()
        . = FULL_EARTH_AMT
        . -= (getEarthResist() * glob.EARTH_RESIST_EPT);
        . = clamp(., getMaxEarthResistValue(), getMinEarthResistValue());
    getEarthResist()
        . = 0
        . += passive_handler.Get("EarthResist");
        . = clamp(., glob.EARTH_RESIST_MIN, glob.EARTH_RESIST_MAX);
    getMinEarthResistValue()
        . = FULL_EARTH_AMT - (glob.EARTH_RESIST_MIN * glob.EARTH_RESIST_EPT)
    getMaxEarthResistValue()
        . = FULL_EARTH_AMT - (glob.EARTH_RESIST_MAX * glob.EARTH_RESIST_EPT)
