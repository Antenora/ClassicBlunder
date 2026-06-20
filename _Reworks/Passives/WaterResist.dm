globalTracker/var
    WATER_RESIST_EPT = 0.10;//10% damage reduction Effect Per Tick when struck by a Water-element skill
    WATER_RESIST_MIN = 0;
    WATER_RESIST_MAX = 5;

passiveInfo/WaterResist
    setLines()
        lines = list("Reduces the damage you take from skills with the Water element (SpellElement or ElementalClass).",\
"Each tick of the passive is worth [glob.outputVariableInfo("WATER_RESIST_EPT")]% damage reduction against a Water-element source.",\
"Minimum number of ticks: [glob.outputVariableInfo("WATER_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("WATER_RESIST_MAX")]");

#define FULL_WATER_AMT 1
mob/proc/
    getWaterResistValue()
        . = FULL_WATER_AMT
        . -= (getWaterResist() * glob.WATER_RESIST_EPT);
        . = clamp(., getMaxWaterResistValue(), getMinWaterResistValue());
    getWaterResist()
        . = 0
        . += passive_handler.Get("WaterResist");
        . = clamp(., glob.WATER_RESIST_MIN, glob.WATER_RESIST_MAX);
    getMinWaterResistValue()
        . = FULL_WATER_AMT - (glob.WATER_RESIST_MIN * glob.WATER_RESIST_EPT)
    getMaxWaterResistValue()
        . = FULL_WATER_AMT - (glob.WATER_RESIST_MAX * glob.WATER_RESIST_EPT)
