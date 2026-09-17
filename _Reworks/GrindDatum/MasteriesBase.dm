globalTracker/var
    MASTERY_ON_HIT_WEIGHT = 1;
    MASTERY_ON_DMG_WEIGHT = 0.25;
    MASTERY_ON_HURT_WEIGHT = 4;

mob/var/GrindTracker/Grindables = new();

GrindTracker
    var/list/MasteryOnHit = list();
    var/list/MasteryOnDmg = list();
    var/list/MasteryOnHurt = list();
    var/list/MasteryTotal = list();

    proc
        SetMasteryTotal(skillTypePath)
            . = 0;
            . += (GetMasteryOnHit(skillTypePath) * glob.MASTERY_ON_HIT_WEIGHT);
            . += (GetMasteryOnDmg(skillTypePath) * glob.MASTERY_ON_DMG_WEIGHT);
            . += (GetMasteryOnHurt(skillTypePath) * glob.MASTERY_ON_HURT_WEIGHT);
        
        AddMasteryOnHit(skillTypePath)
            if(!MasteryOnHit["[skillTypePath]"]) MasteryOnHit["[skillTypePath]"] = 0;//initialize
            MasteryOnHit["[skillTypePath]"] += 1;
            MasteryTotal["[skillTypePath]"] = SetMasteryTotal(skillTypePath);
        AddMasteryOnDmg(skillTypePath, amt)
            if(!MasteryOnDmg["[skillTypePath]"]) MasteryOnDmg["[skillTypePath]"] = 0;//initialize
            MasteryOnDmg["[skillTypePath]"] += amt;
            MasteryTotal["[skillTypePath]"] = SetMasteryTotal(skillTypePath);
        AddMasteryOnHurt(skillTypePath, amt)
            if(!MasteryOnHurt["[skillTypePath]"]) MasteryOnHurt["[skillTypePath]"] = 0;//initialize
            MasteryOnHurt["[skillTypePath]"] += amt;
            MasteryTotal["[skillTypePath]"] = SetMasteryTotal(skillTypePath);

        GetMasteryOnHit(skillTypePath)
            if(!MasteryOnHit["[skillTypePath]"]) return 0;
            . = MasteryOnHit["[skillTypePath]"];
        GetMasteryOnDmg(skillTypePath)
            if(!MasteryOnDmg["[skillTypePath]"]) return 0;
            . = MasteryOnDmg["[skillTypePath]"];
        GetMasteryOnHurt(skillTypePath)
            if(!MasteryOnHurt["[skillTypePath]"]) return 0;
            . = MasteryOnHurt["[skillTypePath]"];
        
        RemoveMasteryOnHit(skillTypePath)
            MasteryOnHit.Remove("[skillTypePath]");
        RemoveMasteryOnDmg(skillTypePath)
            MasteryOnDmg.Remove("[skillTypePath]");
        RemoveMasteryOnHurt(skillTypePath)
            MasteryOnHurt.Remove("[skillTypePath]");
        