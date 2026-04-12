passiveInfo/PowerfulCasting
    setLines()
        lines = list("A casting style that channels Strength into magickal power.",\
"Each tick of this passive adds 1 point of your Strength stat to the damage of every spell you cast.",\
"Stacks additively with other Casting passives, but only one full Casting type may be selected per element pinnacle.");

mob/proc/
    getPowerfulCasting()
        . = 0
        . += passive_handler.Get("PowerfulCasting");
    getPowerfulCastingBonus()
        . = 0
        var/ticks = getPowerfulCasting();
        if(ticks <= 0) return 0;
        . = src.GetStr() * ticks;
