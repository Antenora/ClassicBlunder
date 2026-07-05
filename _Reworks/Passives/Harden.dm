globalTracker/var/
    HARDEN_MAX_ADD = 0.5;
    HARDEN_MAX_STACKS = 20;
    HARDEN_MIN = 0;
    HARDEN_MAX = 5;
    BASE_HARDEN_CHANCE = 50

/mob/var/
    HardenAccumulated=0;

mob/proc/
    getHarden()
        . = 0;
        . += passive_handler.Get("Harden");
        . += scalingEldritchPower();
        . = clamp(., glob.HARDEN_MIN, glob.HARDEN_MAX);
    //This is used in GetEnd()
    getHardenMult()
        var/hard = getHarden();//i know you are but what am i
        if(!hard) return 1;//Just for safety; this math shouldn't happen if you don't have the Harden passive, so return 1 (to not mult the value; NOT a boolean "yes")
        var/peakHarden = getPeakHarden(hard);//gets the max value that could be added with this level of harden if stacks were maxed
        var/addPerStack = (peakHarden / glob.MAX_HARDEN_STACKS);
        . = 1;
        . += (HardenAccumulated * addPerStack);
    getPeakHarden(currentHardenQuality)
        . = currentHardenQuality * (glob.HARDEN_MAX_ADD / glob.HARDEN_MAX);
    
    //This is used in applySoftCC()
    HardenAccumulate(acu)//acu is the enemy's accupuncture passive
        if(acu && prob(acu * glob.ACUPUNCTURE_BASE_CHANCE))
            HardenAccumulated = clamp(HardenAccumulated - acu/glob.ACUPUNCTURE_DIVISOR, 0 , passive_handler["Relentlessness"] ? 100 : glob.MAX_HARDEN_STACKS)
        else
            var/hard = getHarden();
            if(prob(glob.BASE_HARDEN_CHANCE * hard))
                HardenAccumulated = clamp(HardenAccumulated + 1 + hard / glob.HARDEN_DIVISOR, 0, passive_handler["Relentlessness"] ? 100 : glob.MAX_HARDEN_STACKS)