globalTracker/var
    GOOD_RESIST_EPT = 0.10;//10% damage reduction Effect Per Tick when struck by a Good-aligned attacker
    GOOD_RESIST_MIN = 0;
    GOOD_RESIST_MAX = 5;

passiveInfo/GoodResist
    setLines()
        lines = list("Reduces the damage you take from attackers with the Good alignment.",\
"Each tick of the passive is worth [glob.outputVariableInfo("GOOD_RESIST_EPT")]% damage reduction against a Good-aligned source.",\
"Minimum number of ticks: [glob.outputVariableInfo("GOOD_RESIST_MIN")]",\
"Maximum number of ticks: [glob.outputVariableInfo("GOOD_RESIST_MAX")]");

#define FULL_GOOD_AMT 1
mob/proc/
    getGoodResistValue()
        . = FULL_GOOD_AMT
        . -= (getGoodResist() * glob.GOOD_RESIST_EPT);
        . = clamp(., getMaxGoodResistValue(), getMinGoodResistValue());
    getGoodResist()
        . = 0
        . += passive_handler.Get("GoodResist");
        . = clamp(., glob.GOOD_RESIST_MIN, glob.GOOD_RESIST_MAX);
    getMinGoodResistValue()
        . = FULL_GOOD_AMT - (glob.GOOD_RESIST_MIN * glob.GOOD_RESIST_EPT)
    getMaxGoodResistValue()
        . = FULL_GOOD_AMT - (glob.GOOD_RESIST_MAX * glob.GOOD_RESIST_EPT)
