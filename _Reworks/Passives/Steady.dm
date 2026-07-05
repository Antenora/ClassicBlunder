globalTracker/var
    STEADY_EPT = 0.05;
    MYTHICAL_UNNERVE_INNATE = 2;
    ZORNHAU_ARMOR_EFFECT = 2;

/passiveInfo/Steady
    setLines()
        lines = list("Adds a flat value to your damage roll. Each tick is worth <u>([glob.outputVariableInfo("STEADY_EPT")])</u> damage value currently.",\
        "Countered directly by Unnerve, which reduces one tick of Steady per tick of Unnerve.",\
        "Zornhau also contributes to Steady passive, counting as 2 ticks if your target has armor equipped.",\
        "Shin (a Secret), has a state called Mang. Mang Level is also added directly to your overall Steady value.");
    setBalanceNote()
        balanceNote="Steady does not allow a character to break the upper and lower limits of damage rolls. Currently they are [glob.outputVariableInfo("min_damage_roll")] to [glob.outputVariableInfo("max_damage_roll")].";
/passiveInfo/Unnerve
    setLines()
        lines = list("Directly counters Steady by reducing damage roll values. Each tick is worth [glob.outputVariableInfo("STEADY_EPT")] damage value currently.",\
        "If a character already has a source of Unnerve, the Mythical passive also contributes to the calculation of Unnerve's effect.",\
        "Each tick of Mythical is worth [glob.outputVariableInfo("MYTHICAL_UNNERVE_INNATE")] currently.");
    setBalanceNote()
        balanceNote="Unnerve does not allow a character to break the upper and lower limits of damage rolls. Currently they are [glob.outputVariableInfo("min_damage_roll")]</u> to [glob.outputVariableInfo("max_damage_roll")]."
/passiveInfo/Zornhau
    setLines()
        lines = list("Functions mostly the same as Steady passive with a little extra, and the limitation of needing a sword in order to trigger the passive.",\
        "Adds a flat value to your damage roll. Each tick is worth [glob.outputVariableInfo("STEADY_EPT")] damage value currently.",\
        "Zornhau counts as having double the amount of passive ticks when the user's target has armor equipped.");
    setBalanceNote()
        balanceNote=" Zornhau does not allow a character to break the upper and lower limits of damage rolls. Currently they are [glob.outputVariableInfo("min_damage_roll")] to [glob.outputVariableInfo("max_damage_roll")].";

/mob/proc/
    getSteadyValue()
        return (getSteady() * glob.STEADY_EPT);
    getSteady()
        . = 0;
        . += passive_handler.Get("Steady");
        . += getZornhau();
        . += getMangSteady();
        . -= getUnnerve();
    getZornhau()
        if(!equippedSword) return 0;
        . = passive_handler.Get("Zornhau");
        if(hasZornhauTarget()) . *= glob.ZORNHAU_ARMOR_EFFECT;
    hasZornhauTarget()
        if(Target && Target.equippedArmor) return 1;
        return 0;
    getUnnerve()
        . = Target ? Target.passive_handler.Get("Unnerve") : 0;
        if(.) . += (HasMythical() * glob.MYTHICAL_UNNERVE_INNATE)
    getMangSteady()
        if(hasSecret("Shin")) return 0;
        if(!CheckSlotless("Mang Resonance")) return 0;
        . = GetMangLevel();
    //mayb add shin radiance to unnerve