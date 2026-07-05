globalTracker/var
    DENKO_SEKKA_CHARGE_PER_LEVEL = 1;
    DENKO_SEKKA_CRIT_CHANCE_PER_LEVEL = 5;
    DENKO_SEKKA_CRIT_DAMAGE_PER_LEVEL = 0.1;
    DENKO_SEKKA_MIN = 0;
    DENKO_SEKKA_MAX = 10;

passiveInfo/DenkoSekka
    setLines()
        lines = list("Grants +[glob.outputVariableInfo("DENKO_SEKKA_CHARGE_PER_LEVEL")] maximum Zanzoken charge per level of this passive.",\
"After a Zanzoken, grants +[glob.outputVariableInfo("DENKO_SEKKA_CRIT_CHANCE_PER_LEVEL")] CriticalChance per level to the next attack.",\
"If that attack crits, additionally grants +[glob.outputVariableInfo("DENKO_SEKKA_CRIT_DAMAGE_PER_LEVEL")] CriticalDamage per level for the crit.",\
"Minimum level: [glob.outputVariableInfo("DENKO_SEKKA_MIN")]",\
"Maximum level: [glob.outputVariableInfo("DENKO_SEKKA_MAX")]");
    setBalanceNote()
        balanceNote = "The crit window only lasts for the next normal or queue attack."

mob/var/tmp/
    DenkoSekkaCharged = 0

mob/proc/
    getDenkoSekka()
        . = passive_handler.Get("DenkoSekka");
        . = clamp(., glob.DENKO_SEKKA_MIN, glob.DENKO_SEKKA_MAX);

    DenkoSekkaZanzoFade(savedPixelZ)
        set waitfor = 0
        animate(src, pixel_z = savedPixelZ + 48, time = 5, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
        animate(src, color = "#FFD700", alpha = 140, time = 3)
        sleep(3)
        animate(src, alpha = 0, time = 2)

    DenkoSekkaZanzoLand(savedColor, savedPixelZ)
        set waitfor = 0
        src.pixel_z = savedPixelZ
        LightningStrike2(src)
        animate(src, color = savedColor, alpha = 255, time = 3)
        sleep(3)
        animate(src)
        src.color = savedColor
        src.alpha = 255
        src.pixel_z = savedPixelZ
