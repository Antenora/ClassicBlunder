passiveInfo/ForcefulCasting
    setLines()
        lines = list("A casting style that channels Force into magickal power.",\
"Each tick of this passive adds 1 point of your Force stat to the damage of every spell you cast.",\
"Stacks additively with other Casting passives, but only one full Casting type may be selected per element pinnacle.");

mob/proc/
    getForcefulCasting()
        . = 0
        . += passive_handler.Get("ForcefulCasting");
    getForcefulCastingBonus()
        . = 0
        var/ticks = getForcefulCasting();
        if(ticks <= 0) return 0;
        . = src.GetFor() * ticks;
