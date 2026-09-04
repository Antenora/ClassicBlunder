globalTracker/var
    LIGHTNING_RESIST_EPT = 0.10;
    LIGHTNING_RESIST_MIN = 0;
    LIGHTNING_RESIST_MAX = 5;

passiveInfo/LightningResist
    setLines()
        lines = list("Reduces the damage you take from skills with the Lightning element (SpellElement or ElementalClass).",\
"Each tick of the passive is worth [glob.outputVariableInfo("LIGHTNING_RESIST_EPT")]% damage reduction against a Lightning-element source.",\
"Minimum number of ticks: [glob.outputVariableInfo("LIGHTNING_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("LIGHTNING_RESIST_MAX")]");

#define FULL_LIGHTNING_AMT 1
mob/proc/
    getLightningResistValue()
        . = FULL_LIGHTNING_AMT
        . -= (getLightningResist() * glob.LIGHTNING_RESIST_EPT);
        . = clamp(., getMaxLightningResistValue(), getMinLightningResistValue());
    getLightningResist()
        . = 0
        . += passive_handler.Get("LightningResist");
        . = clamp(., glob.LIGHTNING_RESIST_MIN, glob.LIGHTNING_RESIST_MAX);
    getMinLightningResistValue()
        . = FULL_LIGHTNING_AMT - (glob.LIGHTNING_RESIST_MIN * glob.LIGHTNING_RESIST_EPT)
    getMaxLightningResistValue()
        . = FULL_LIGHTNING_AMT - (glob.LIGHTNING_RESIST_MAX * glob.LIGHTNING_RESIST_EPT)
