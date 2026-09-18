GrindTracker
    var/list/TimeGatedSkills = list();//skilltype + "Start" or "End" will track the level needed to advance
    var/list/TimeGatedMastery = list();//skillType is the key; the TotalMastery level is recorded when the time gate begins and the recorded amount is disregarded

    proc
        SetTimeGate(skillTypePath, advanceLvl, startingLvl)
            if(TimeGatedSkills["[skillTypePath]Start"] && TimeGatedSkills["[skillTypePath]End"])
                liveDebugMsg("The GrindTracker > [skillTypePath] TimeGate variables for a particular player being set before being cleared. Investigate?");
                return;
            TimeGatedSkills["[skillTypePath]Start"] = startingLvl;
            TimeGatedSkills["[skillTypePath]End"] = advanceLvl;
            TimeGatedMastery["[skillTypePath]"] = SetMasteryTotal(skillTypePath);
        
        ClearTimeGate(skillTypePath)
            if(!TimeGatedSkills["[skillTypePath]Start"] || !TimeGatedSkills["[skillTypePath]End"])
                liveDebugMsg("The GrindTracker > [skillTypePath] TimeGate variables for a particular player are not both set, but they are being attempted to be cleared. Investigate?");
                return;
            TimeGatedSkills.Remove("[skillTypePath]Start");
            TimeGatedSkills.Remove("[skillTypePath]End");
            if(TimeGatedMastery["[skillTypePath]"]) TimeGatedMastery.Remove("[skillTypePath]");
        
        CheckTimeGate(skillTypePath, currentLvl)
            if(!TimeGatedSkills["[skillTypePath]Start"] || !TimeGatedSkills["[skillTypePath]End"])
                liveDebugMsg("The GrindTracker > [skillTypePath] TimeGate variables for a particular player are not both set, but they are being checked for progression. Investigate?");
                return;
            var/advanceLvl = TimeGatedSkills["[skillTypePath]End"];
            var/dif = advanceLvl - currentLvl;
            if(dif <= 0) return 1;
            return 0;
        
        CheckTimedMastery(skillTypePath, masteryReq)
            var/totalSubTime = (SetMasteryTotal(skillTypePath) - TimeGatedMastery["[skillTypePath]"]);
            if(totalSubTime >= masteryReq) return 1;
            return 0;

        CanAdvanceTimeGate(skillTypePath, currentLvl, masteryReq = 0)
            if(CheckTimeGate(skillTypePath, currentLvl))
                if(masteryReq)
                    if(!CheckTimedMastery(skillTypePath, masteryReq)) return 0;
                ClearTimeGate(skillTypePath);
                return 1;
            return 0;
        
        


mob/proc/CheckTimeGateSkills()
    for(var/obj/Skills/s in src)
        if(s.youCanNotAdvance()) continue;
        //passes in skill type, user's potential, the skill's advancement stipulations
        //if(!Grindables.CanAdvance("[s.type]", Potential, s.isOnlyTimeGated() ? 0 : s.PostTimeGateMasteryNeeded))
        s.advance_adjustment(src);