globalTracker/var
    SPELL_RANGE_EPT = 1;//flat tile bonus to spell range Per Tick of the passive

passiveInfo/SpellRange
    setLines()
        lines = list("Increases the maximum range of spells you cast.",\
"Each tick of the passive is worth [glob.outputVariableInfo("SPELL_RANGE_EPT")] additional tile of spell range.");

mob/proc/
    getSpellRange()
        . = 0
        . += passive_handler.Get("SpellRange");
    getSpellRangeBonus()
        . = getSpellRange() * glob.SPELL_RANGE_EPT;
