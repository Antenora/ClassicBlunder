globalTracker/var
    EVIL_RESIST_EPT = 0.10;//10% damage reduction Effect Per Tick when struck by an Evil-aligned attacker
    EVIL_RESIST_MIN = 0;
    EVIL_RESIST_MAX = 5;

passiveInfo/EvilResist
    setLines()
        lines = list("Reduces the damage you take from attackers with the Evil alignment.",\
"Each tick of the passive is worth [glob.outputVariableInfo("EVIL_RESIST_EPT")]% damage reduction against an Evil-aligned source.",\
"Minimum number of ticks: [glob.outputVariableInfo("EVIL_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("EVIL_RESIST_MAX")]");

#define FULL_EVIL_AMT 1
mob/proc/
    getEvilResistValue()
        . = FULL_EVIL_AMT
        . -= (getEvilResist() * glob.EVIL_RESIST_EPT);
        . = clamp(., getMaxEvilResistValue(), getMinEvilResistValue());
    getEvilResist()
        . = 0
        . += passive_handler.Get("EvilResist");
        . = clamp(., glob.EVIL_RESIST_MIN, glob.EVIL_RESIST_MAX);
    getMinEvilResistValue()
        . = FULL_EVIL_AMT - (glob.EVIL_RESIST_MIN * glob.EVIL_RESIST_EPT)
    getMaxEvilResistValue()
        . = FULL_EVIL_AMT - (glob.EVIL_RESIST_MAX * glob.EVIL_RESIST_EPT)
