var/list/MASTERY_TYPES = list("Uses", "Hits", "HitsTaken", "Dmg", "Hurt", "WoundsDealt", "WoundsTaken", "MortalWoundsDealt",
"MortalWoundsTaken", "MaimsDealt");//not a globally tracked variable because it should not need to be changed at runtime
var/list/SPECIAL_MASTERY_TYPES = list("MortalWoundsDealt", "MortalWoundsTaken", "MaimsDealt");//these are not tracked in masteryTotal

globalTracker
    var/list/ADVANCE_MASTERY_WEIGHTS = list("Uses" = 5, "Hits" = 0.25, "HitsTaken" = 0.5, "Dmg" = 1, "Hurt" = 2, "WoundsDealt" = 1, "WoundsTaken" = 1, "MortalWoundsDealt" = 1,
    "MortalWoundsTaken" = 1, "MaimsDealt" = 1);

obj/Skills
    var/advanceSpecs/advanceData = new();

advanceSpecs
    var/tmp/mob/owner;//hi mom
    var/tmp/obj/Skills/skillOrigin;//hi dad

    //overall logic
    var/advancementStage = 1;//all skills start at advancement 1
    var/advancementStageMax = 1;//if a skill has reached its max then there is no need for further advancement
    
    //potential/level vars
    var/levelNeeded = 0;//level (potential) needed for advancement to trigger

    //mastery vars
    var/list/masteryTypes = list();//"Uses", "Hits", "HitsTaken", "Dmg", "Hurt"
    //Uses : does mastery proc off activating the skill?
    //Hits : does mastery proc off of hits?
    //HitsTaken : does mastery proc off receiving hits from others?
    //Dmg: does mastery proc off dmg?
    //Hurt: does mastery proc off taking dmg?
    
    //types of masteries that do not get factored into masteryTotal
    //"MortalWoundsDealt" : yk
    //"MortalWoundsTaken" : yk
    //"MaimsDealt" : yk
    //"Stage" : does mastery need to be gained THIS stage? if this is flagged, the skill will only look at masteryFromThisStage    
    
    var/list/mastery = list();//"[masteryType]" as key, value of masteryType as index; only masteryTypes that have been initialized will be used
    
    var/masteryTotal = 0;//sum of all masteries
    var/masteryNeeded = 0;//how much total mastery is needed?
    var/masteryFromThisStage = 0;//tracks how much mastery was gained THIS advancement stage only
    var/list/masterySpecialNeeded = list();

    proc
        youCanNotAdvance()
            if(masteryTypes.len <= 0 && levelNeeded <= 0) return 1;
            if(advancementStage >= advancementStageMax) return 1;
            return 0;

        validateAddMastery(type)
            var/errors = 0;
            if(!(type in global.MASTERY_TYPES))
                liveDebugMsg("[owner]'s [skillOrigin] advance data is attempting to add invalid Mastery Type (\"[type]\"). This Mastery Type does not exist.");
                var/secondMsg = "Did they mean: ";
                for(var/x in global.MASTERY_TYPES)
                    if(x != global.MASTERY_TYPES[global.MASTERY_TYPES.len]) secondMsg += ", ";
                    else secondMsg += "or ";
                    secondMsg += "[x]";
                secondMsg += "?";
                liveDebugMsg(secondMsg);
                errors++;
            if(!glob.ADVANCE_MASTERY_WEIGHTS.Find(type))
                liveDebugMsg("[owner]'s [skillOrigin] is seeking to add mastery for Mastery Type (\"[type]\"). This Mastery Type does not have a globally tracked ADVANCE_MASTERY_WEIGHT.");
                errors++;
            if(errors) return 0;
            return 1;

        addMastery(type, amt)
            if(!validateAddMastery(type)) return//debug messages
            if(!masteryTypes.Find(type)) return//if this skill does not list the type as a mastery type, then simply end the proc

            if(!mastery[type]) mastery[type] = 0;//initialize as a number
            var/effGain = (amt * glob.ADVANCE_MASTERY_WEIGHTS[type]);
            mastery["[type]"] += effGain;
            addMasteryTotals(type, effGain);

        addMasteryTotals(type, amt)
            if(type in global.SPECIAL_MASTERY_TYPES) return
            masteryFromThisStage += amt;
            masteryTotal += amt;

        setMasteryTotal()//mostly recorded for debugging purposes
            masteryTotal = 0;
            for(var/x in mastery)
                var/val = mastery[x];
                if(val > 0) masteryTotal += mastery[x];
        
        resetMasteryFromThisStage()
            masteryFromThisStage = 0;
        
        checkLevel()
            if(!levelNeeded) return 1;
            if(owner.Potential > levelNeeded) return 1;
            return 0;

        hasEnoughMastery()
            if(!hasEnoughSpecialMastery()) return 0;
            if(mastery["Stage"]) return hasEnoughMasteryFromThisStage();
            if(masteryTotal >= masteryNeeded) return 1;
            
            return 0;
        
        hasEnoughMasteryFromThisStage()
            if(masteryFromThisStage >= masteryNeeded) return 1;
            return 0;

        hasEnoughSpecialMastery()
            if(specialMasteryNeeded.len <= 0) return 1;
            for(var/sMastery in global.SPECIAL_MASTERY_TYPES)
                var/has = mastery[sMastery];
                var/needs = specialMasteryNeeded[sMastery];
                if(needs)
                    if(has < needs) return 0;
            return 1;

        canAdvance()
            if(!checkLevel()) return 0;
            if(!hasEnoughMastery()) return 0;

            return 1;

mob
    var/tmp/list/advanceDataFromSkills = list();//skill name is key, advanceData from that skill is index
    proc
        KnowYourMaker(advanceSpecs/advData, obj/Skills/s)
            advData.owner = src;
            advData.skillOrigin = s;
            advanceDataFromSkills["[parsePathText(s)]"] = advData;

        CheckSkillAdvancement()
            for(var/obj/Skills/s in src)
                var/advanceSpecs/advData = s.advanceData;
                KnowYourMaker(advData, s);
                if(advData.youCanNotAdvance()) continue //do not enter the robot, shinji
                if(!advData.canAdvance()) continue
                //if all goes well
                advanceAdjust(s);

        advanceAdjust(obj/Skills/s)
            //perform functions on mob
            
            //perform adjustments to advancement data
            s.advanceData.advanceAdjust(src);
            
            //perform functions on skill
            s.advanceAdjust(src);

obj/Skills/proc/advanceAdjust(mob/owner)
advanceSpecs/proc/advanceAdjust(mob/owner)
    advancementStage++;
    setMasteryTotal();
    resetMasteryFromThisStage();

            