//asc 1 choices
/ascension/sub_ascension/beastkin/edge
    passives = list("LifeSteal" = 5);
    strength = 0.5;
    endurance = 0.5;
/ascension/sub_ascension/beastkin/buck
    passives = list("LifeGeneration" = 0.5);
    endurance = 1;
/ascension/sub_ascension/beastkin/infi
    passives = list("EnergyHeal" = 1);
    force = 0.5;
    endurance = 0.5;

//asc 2 choices
/ascension/sub_ascension/beastkin/ira
    passives = list("AttackSpeed" = 1, "Iaijutsu" = 1);
    speed = 1;
    offense = 0.5;
/ascension/sub_ascension/beastkin/rus
    passives = list("Godspeed" = 1, "ChillResistance" = 1);
    speed = 1.5;
/ascension/sub_ascension/beastkin/mer
    passives = list("Deflection" = 1, "ControlResist" = 1);
    endurance = 0.5;
    speed = 0.5;
    defense = 0.5;
/ascension/sub_ascension/beastkin/mil
    passives=list("Unnerve" = 1, "MeleeResist" = 1);
    endurance = 1;
    speed = 0.5;

//asc 3,4,5,6 choices
/ascension/sub_ascension/beastkin/frostchain
    strength = 0.5
    endurance = 0.5
    speed = 1
    passives = list("AttackSpeed" = 2, "PureDamage" = 2, "Gum Gum" = 1, "Extend" = 1, "Freezing" = 2)
/ascension/sub_ascension/beastkin/kingsblood
    strength = 0.5
    endurance = 1.5
    passives = list("CallousedHands" = 0.3, "DemonicDurability"=0.3, "PureReduction" = 2, "Rage" = 2)
/ascension/sub_ascension/beastkin/overreach
    endurance = 1;
    defense = 1;
    passives = list("PureReduction" = 2, "Steady" = 2, "Unnerve" = 2, "DebuffResistance" = 0.2)
/ascension/sub_ascension/beastkin/matchless
    strength = 1;
    endurance = 1;
    passives = list("TechniqueMastery" = 3, "UnarmedDamage" = 3, "The Way" = 1, "BladeFisting" = 1)
/ascension/sub_ascension/beastkin/wargob
    endurance = 2;
    passives = list("Restoration" = 1, "Harden" = 4, "DemonicDurability" = 0.5, "LifeGeneration" = 3)
/ascension/sub_ascension/beastkin/triad
    strength = 0.5;
    speed = 0.5;
    endurance = 0.5;
    force = 0.5;
    passives = list("SpiritSword" = 0.5, "SpiritHand" = 1, "SpiritFlow" = 1, "BlurringStrikes" = 1, "CallousedHands" = 0.1)
/ascension/sub_ascension/beastkin/firstlight
    strength = 0.75;
    endurance = 0.75;
    offense = 0.5;
    passives = list("CriticalChance" = 10, "BlockChance"=10, "CriticalDamage"=0.15, "CriticalBlock"=0.15)
/ascension/sub_ascension/beastkin/felglass
    strength = 0.75;
    offense = 0.75;
    endurance = 0.5;
    passives = list("PureDamage" = 2, "Fury" = 2, "Brutalize"=2, "Extend"=2, "SwordDamage"=6)
/ascension/sub_ascension/beastkin/phantomflicker
    strength = 1.25;
    offense = 0.375;
    endurance = 0.375;
    passives = list("AttackSpeed" = 3, "Iaijutsu" = 3, "DoubleStrike" = 1, "SoulSteal" = 0.1)
/ascension/sub_ascension/beastkin/deadlight
    strength = 2;
    passives = list("TechniqueMastery" = 3, "Void" = 1, "Brutalize" = 2, "HardStyle" = 2)
/ascension/sub_ascension/beastkin/demonsong
    strength = 1.5;
    speed = 0.5;
    passives = list("SpiritHand" = 1, "SpiritFlow" = 1, "GiantSwings" = 1, "LifeSteal" = 10)
/ascension/sub_ascension/beastkin/worldwhisper
    endurance = 1;
    defense = 1;
    passives = list("Freezing" = 2, "Paralyzing" = 2, "IceHerald" = 1, "ThunderHerald" = 1)
/ascension/sub_ascension/beastkin/godword
    force = 0.5;
    offense = 0.5;
    defense = 1;
    passives = list("PureReduction" = 5, "PureDamage" = -2, "Shattering" = 2, "EarthHerald" = 1, "Deflection" = 2, "Siphon" = 2)

#define ASC1_SUBASCENSIONS list(/ascension/sub_ascension/beastkin/edge, /ascension/sub_ascension/beastkin/buck, /ascension/sub_ascension/beastkin/infi)
#define ASC2_SUBASCENSIONS list(/ascension/sub_ascension/beastkin/ira, /ascension/sub_ascension/beastkin/rus, /ascension/sub_ascension/beastkin/mer, /ascension/sub_ascension/beastkin/mil)
/mob/proc/getRiftAscensionOptions()
    var/list/availableOptions = subtypesof(/ascension/sub_ascension/beastkin);
    var/list/removeOptions = list();
    removeOptions |= ASC1_SUBASCENSIONS
    removeOptions |= ASC2_SUBASCENSIONS
    for(var/x in removeOptions)
        availableOptions.Remove(x);
    for(var/ascension/a in race.ascensions)
        if(availableOptions.Find(a.choiceSelected)) availableOptions.Remove(a.choiceSelected);
    . = list();
    var/list/Return = list()
    for(var/o in availableOptions)
        var/optionName = copytext("[o]", findLastSlash("[o]"))
        optionName = "[uppertext(copytext(optionName, 1, 2))][copytext(optionName, 2)]"
        Return["[optionName]"] = o;
    return Return;