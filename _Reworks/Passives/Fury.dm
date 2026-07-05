/globalTracker/var/
    FURY_MIN = 0;//minimum value of passive
    FURY_MAX = 2;//maximum value of passive
    //will probably squint at the below variables
    BASE_FURY_CHANCE = 50
    MAX_FURY_STACKS = 32
    FURY_DIVISOR = 4
    FURY_MAX_BOON = 4
    FURY_MAX_ADD = 0.5;
    FURY_ANGER_EFFECT = 2;

/mob/var/
    FuryAccumulated=0;
//todo: write help file

/mob/proc
    getFuryValue()
        . = 0;
        . += passive_handler.Get("Fury");
        . = clamp(., glob.FURY_MIN, glob.FURY_MAX);
    //This is used in GetSpd()
    getFuryMult()
        if(!src.passive_handler.Get("Fury")) return 1;//Just for safety, this math shouldn't happen if you don't have the fury passive
        var/maxFuryAdd = (src.passive_handler.Get("Fury") * src.getMaxFuryMult());
        var/addPerStack = (maxFuryAdd / glob.MAX_FURY_STACKS / glob.FURY_ANGER_EFFECT);
        if(src.Anger) addPerStack *= glob.FURY_ANGER_EFFECT;
        if(src.passive_handler.Get("Relentlessness")) addPerStack*=1.25
        . = 1;
        . += (FuryAccumulated * addPerStack);
    getMaxFuryMult()
        . = (glob.FURY_MAX_ADD/glob.FURY_MAX_BOON)

    //This is used in handlePostDamage()
    FuryAccumulate(acu)//acu is the enemy's accupuncture passive
        if(acu && prob(acu * glob.ACUPUNCTURE_BASE_CHANCE))
            FuryAccumulated = clamp(FuryAccumulated - acu/glob.ACUPUNCTURE_DIVISOR, 0 , passive_handler["Relentlessness"] ? 50 : glob.MAX_FURY_STACKS)
        else
            var/_fury = getFuryValue();
            if(prob(glob.BASE_FURY_CHANCE * _fury))
                FuryAccumulated = clamp(FuryAccumulated + 1 + _fury/glob.FURY_DIVISOR, 0, passive_handler["Relentlessness"] ? 50 : glob.MAX_FURY_STACKS)
