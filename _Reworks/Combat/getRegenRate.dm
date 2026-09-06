/globalTracker/var
    REJUVENATION_RATE = 2;//how much does having "rejuvenation" assist your regen?

passiveInfo/Rejuvenation
    setLines()
        lines = list("Rejuvenation increases the recovery of your health and injury by x[glob.outputVariableInfo("REJUVENATION_RATE")].");
passiveInfo/TaxingRejuvenation
    setLines()
        lines = list("Taxing Rejuvenation operates like Rejuvenation, in that it increases the recovery of your health and injury by x[glob.outputVariableInfo("REJUVENATION_RATE")].",
"However, while your health is below 100% and your energy is above 10%, it prevents you from healing energy through the Recover proc (typically used by Meditate) and infact saps your energy.");
    setBalanceNote()
        balanceNote = "The idea behind this passive is that you are using your energy unconsciously to heal yourself faster, even at the cost of your energy itself.";

mob/proc
    getHealthRegenRate()
        . = 1;
        if(isRace(HUMAN)) . += (TotalInjury / 50);
        if(isRace(MAJIN)) . *= getMajinMedRate();
        if(hasRejuvenation()) . *= glob.REJUVENATION_RATE;
    getEnergyRegenRate()//we simply do not fuck with this for now
        . = 1;
        if(hasTaxingRejuvenation())
            if(HealthPct() < 100)
                . = 0;
    
    hasRejuvenation()
        if(passive_handler.Get("Rejuvenation")) return 1;
        if(hasTaxingRejuvenation()) return 1;
        return 0;
    hasTaxingRejuvenation()
        if(passive_handler.Get("TaxingRejuvenation"))
            if(HealthPct() < 100)
                if(Energy > 10)
                    return 1;
        return 0;