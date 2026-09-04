globalTracker/var
    ICE_RESIST_EPT = 0.10;
    ICE_RESIST_MIN = 0;
    ICE_RESIST_MAX = 5;

passiveInfo/IceResist
    setLines()
        lines = list("Reduces the damage you take from skills with the Ice element (SpellElement or ElementalClass).",\
"Each tick of the passive is worth [glob.outputVariableInfo("ICE_RESIST_EPT")]% damage reduction against a Ice-element source.",\
"Minimum number of ticks: [glob.outputVariableInfo("ICE_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("ICE_RESIST_MAX")]");

#define FULL_ICE_AMT 1
mob/proc/
    getIceResistValue()
        . = FULL_ICE_AMT
        . -= (getIceResist() * glob.ICE_RESIST_EPT);
        . = clamp(., getMaxIceResistValue(), getMinIceResistValue());
    getIceResist()
        . = 0
        . += passive_handler.Get("IceResist");
        . = clamp(., glob.ICE_RESIST_MIN, glob.ICE_RESIST_MAX);
    getMinIceResistValue()
        . = FULL_ICE_AMT - (glob.ICE_RESIST_MIN * glob.ICE_RESIST_EPT)
    getMaxIceResistValue()
        . = FULL_ICE_AMT - (glob.ICE_RESIST_MAX * glob.ICE_RESIST_EPT)
