globalTracker/var/
    ANGER_ADAPTIVE_RANGE = 0.75;//If Stat1 is multiplied by THISVALUE and it is still higher than Stat2, consider the user fully invested in that stat for AA purposes
    ANGER_ADAPTIVE_EPT = 0.1;//Each full 1 value of AA is worth this much mult for a fully invested stat

passiveInfo/AngerAdaptiveForce
    setLines()
        lines = list("When in anger, your strength, force, or both will have a higher multiplier.",\
"If your strength is greater than your force, this passive impacts your strength.",\
"If your force is greater than your strength, this passive impacts your force.",\
"If strength and force are within x[glob.outputVariableInfo("ANGER_ADAPTIVE_EPT")] of each other, then both stats are impacted at half rate.",\
"Each tick of the passive is worth x[glob.outputVariableInfo("ANGER_ADAPTIVE_RANGE")] additive multiplier to your relevant stats.");

/mob/proc/GetAngerAdaptiveStr()
    var/aa = passive_handler.Get("AngerAdaptiveForce");
    if(!aa) return 0;
    if(BaseFor() * glob.ANGER_ADAPTIVE_RANGE > BaseStr()) return 0;//Too much force to get any str gains
    if(BaseStr() * glob.ANGER_ADAPTIVE_RANGE > BaseFor()) . = (aa * glob.ANGER_ADAPTIVE_EPT);
    else . = ((aa * glob.ANGER_ADAPTIVE_EPT) / 2);//Halfrate adaptation
    
/mob/proc/GetAngerAdaptiveFor()
    var/aa = passive_handler.Get("AngerAdaptiveForce");
    if(!aa) return 0;
    if(BaseStr() * glob.ANGER_ADAPTIVE_RANGE > BaseFor()) return 0;//Too much strength to get any for gains
    if(BaseFor() * glob.ANGER_ADAPTIVE_RANGE > BaseStr()) . = (aa * glob.ANGER_ADAPTIVE_EPT);
    else . = ((aa * glob.ANGER_ADAPTIVE_EPT) / 2);//Halfrate adaptation