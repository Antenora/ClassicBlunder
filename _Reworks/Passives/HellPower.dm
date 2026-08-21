globalTracker/var
    HELLPOWER_MAX = 1;
    BASE_HELL_SCALING_RATIO = 0.01
    HELL_SCALING_MULT = 1.5

passiveInfo/AngerAdaptiveForce
    setLines()
        lines = list("HellPower affects your effective base stats for strength and force.",\
"It also impacts your power as your health decreases.",\
"If you have a full tick of Hell Power, you get a greater effect from it.",\
"If you have less a full tick of Hell Power, it will offer an additive multiplier of (HellPower * 0.2).",\
"A full tick of Hell Power will offer an additive multiplier of (HellPower * 0.5)");

/mob/proc/GetHellPower()
    if(passive_handler.Get("ZenkaiPower") || passive_handler.Get("SunStricken")) return 0;
    . = passive_handler.Get("HellPower");
    if(CheckSlotless("Satsui no Hado") && SagaLevel >= 6) .++;// could probably be updated to have a proc check used for satsui
    if(isRace(DEMON) || oozaru_type == "Demonic" || isCSDT()) . = glob.HELLPOWER_MAX;
    return clamp(., 0, glob.HELLPOWER_MAX);

/mob/proc/GetHellScaling()
    . = 1;
    var/hellP = GetHellPower();
    if(!hellP) return 1;

    var/Mult = hellP / glob.HELL_SCALING_MULT
    if(hellP == glob.HELLPOWER_MAX)
        Mult *= glob.HELL_SCALING_MULT
        Mult += round(get_potential() / 100, 0.05)

    var/HealthLost = abs(Health-100);
    . = 1 + (((glob.BASE_HELL_SCALING_RATIO * HealthLost) * Mult) ** (1/2));

/mob/proc/GetHellStats()//Hell stats are a multiplier to base stats. (hopy shit)
    . = 1;
    var/hellp = GetHellPower();
    if(!hellp) return 1;
    if(. < glob.HELLPOWER_MAX) . += (0.2 * hellp);
    else . += (0.5 * hellp);