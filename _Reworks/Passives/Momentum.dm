/globalTracker/var/
    MOMENTUM_MIN = 0;//minimum value of passive
    MOMENTUM_MAX = 2;//maximum value of passive
    //will probably squint at the below variables
    //located in otherPassives.dm BASE_MOMENTUM_CHANCE = 50
    // MAX_MOMENTUM_STACKS = 32
    // MOMENTUM_DIVISOR = 4
    // MOMENTUM_MAX_BOON = 4
    MOMENTUM_MAX_ADD = 1;

//todo: write help file

/mob/proc
    getMomentumValue()
        . = 0;
        . += passive_handler.Get("Momentum");
        . = clamp(., glob.MOMENTUM_MIN, glob.MOMENTUM_MAX);
    //This is used in GetSpd()
    getMomentumMult()
        if(!src.passive_handler.Get("Momentum")) return 1;//Just for safety, this math shouldn't happen if you don't have the fury passive
        var/maxMomentumAdd = (passive_handler.Get("Momentum") * src.getMaxMomentumMult());
        var/addPerStack = (maxMomentumAdd / glob.MAX_MOMENTUM_STACKS);
        if(src.passive_handler.Get("Relentlessness")) addPerStack*=1.25
        . = 1;
        . += (Momentum * addPerStack);
    getMaxMomentumMult()
        . = (glob.MOMENTUM_MAX_ADD/glob.MOMENTUM_MAX_BOON)

    //This is used in handlePostDamage()
    MomentumAccumulate(acu)//acu is the enemy's accupuncture passive
        if(acu && prob(acu * glob.ACUPUNCTURE_BASE_CHANCE))
            Momentum = clamp(Momentum - acu/glob.ACUPUNCTURE_DIVISOR, 0 , passive_handler["Relentlessness"] ? 50 : glob.MAX_MOMENTUM_STACKS)
        else
            var/_momentum = getMomentumValue();
            if(prob(glob.BASE_MOMENTUM_CHANCE * _momentum))
                Momentum = clamp(Momentum + 1 + _momentum/glob.MOMENTUM_DIVISOR, 0, passive_handler["Relentlessness"] ? 50 : glob.MAX_MOMENTUM_STACKS)
