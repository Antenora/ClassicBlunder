passiveInfo/AgileCasting
    setLines()
        lines = list("A casting style that channels Speed into magickal power.",\
"Each tick of this passive adds 1 point of your Speed stat to the damage of every spell you cast.",\
"Stacks additively with other Casting passives, but only one full Casting type may be selected per element pinnacle.");

mob/proc/
    getAgileCasting()
        . = 0
        . += passive_handler.Get("AgileCasting");
    getAgileCastingBonus()
        . = 0
        var/ticks = getAgileCasting();
        if(ticks <= 0) return 0;
        . = src.GetSpd() * ticks;
