/mob/var/tmp/
    tempTensionLock=0;

/mob/proc/
    setTempTensionLock()
        if(tempTensionLock) return;//don't double tap
        tempTensionLock=5;

    canGainTension()
        if(src.HasTensionLock())
            return 0;
        if(tempTensionLock)
            return 0;
        return 1;

    gainTension(val)
        var/maxTension = src.getMaxTensionValue();
        var/ants = passive_handler.Get("Antsy")/10;

        var/tensionGain = val * glob.TENSION_MULTIPLIER;
        if(isRace(HUMAN) && Class=="Underdog")
            tensionGain *= glob.UNDERDOG_HUMAN_TENSION_MULT
        if(hasHighTensionMult())
            tensionGain *= getHighTensionMult();

        if(ants) tensionGain += ants;
        if(passive_handler.Get("Ashen One"))
            tensionGain*=1+(Burn/glob.ASHEN_TENSION_DIVISOR)
        if(passive_handler.Get("Heavensent"))
            tensionGain*=1+(passive_handler.Get("Heavensent")/10)
        src.addTension(tensionGain, maxTension);

    addTension(val, maxVal)
        if(val==maxVal) return
        var/diff = maxVal - src.Tension;
        src.Tension += min(diff, val);

    hasHighTensionMult()
        if(!src.passive_handler.Get("HighTension")) return 0;
        if(src.transActive >= src.transUnlocked) return 0;//if you are at your max level, you don't need to hit tension again to transform so it stops gaining so fast
        if(src.transActive < 3) return 1; //this is the last HT that needs to be tension'd into
        return 0;
    getHighTensionMult()
        return (1+passive_handler.Get("HighTension"));
    getMaxTensionValue()
        var/conductor = 0 + src.passive_handler.Get("Conductor");
        . = max(glob.MIN_TENSION, 100 - conductor);
    tryIncreaseTension()
        if(!isRace(HUMAN) && !isRace(CELESTIAL)) return 0;
        //they have to be human or celestial to get this far
        if(isMazokuPathHuman()) return 0;
        if(canHT())
            race.transformations[1].transform(src, TRUE);
            return;
        if(canSHT())
            race.transformations[3].transform(src, TRUE);
            return;
    canHT()
        if(isMazokuPathHuman()) return 0;
        if(transActive >= 1) return 0;
        if(KO) return 0;
        if(transUnlocked >= 1 || HumanHTException()) return 1;
        return 0;
    HumanHTException()
        if(isRace(HUMAN) && Potential>=10) return 1;
        return 0;
    canHTM()
        if(isMazokuPathHuman()) return 0;
        if(icon_state=="Meditate") return 0;
        if(!isRace(HUMAN) && !isRace(CELESTIAL)) return 0;
        if(transUnlocked < 2) return 0;
        if(transActive >= 2) return 0;
        if(KO) return 0;
        if(Tension >= getMaxTensionValue()/2) return 1;
        return 0;
    canSHT()
        if(isMazokuPathHuman()) return 0;
        if(transActive != 2) return 0;
        if(KO) return 0;
        if(transUnlocked >= 3) return 1;
        return 0;
    canSHTM()
        if(isMazokuPathHuman()) return 0;
        if(!isRace(HUMAN) && !isRace(CELESTIAL)) return 0;
        if(KO) return 0;
        if(passive_handler.Get("FullTensionLock") && isRace(CELESTIAL))
            src << "You cannot use this until the Full Tension Lock from Activate High Tension subsites."
            return 0
        if(transActive == 3 && transUnlocked>=4) return 1;
        return 0;
    shouldRevertHT()
        if(transActive() <= 0) return 0;
        if(!isRace(HUMAN) && !isRace(CELESTIAL)) return 0;
        if(!(icon_state in list("Meditate", "KO"))) return 0;
        return 1;
    isHumanInTransform()
        if(!isRace(HUMAN) && !isRace(CELESTIAL)) return 0;
        if(transActive <= 0) return 0;
        return 1;
