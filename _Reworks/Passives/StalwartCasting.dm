passiveInfo/StalwartCasting
    setLines()
        lines = list("A casting style that channels Endurance into magickal power.",\
"Each tick of this passive adds 1 point of your Endurance stat to the damage of every spell you cast.",\
"Stacks additively with other Casting passives, but only one full Casting type may be selected per element pinnacle.");

mob/proc/
    getStalwartCasting()
        . = 0
        . += passive_handler.Get("StalwartCasting");
    getStalwartCastingBonus()
        . = 0
        var/ticks = getStalwartCasting();
        if(ticks <= 0) return 0;
        . = src.GetEnd() * ticks;
