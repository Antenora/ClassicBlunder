	//LABEL: ACCURACY FORMULA
//one contest for everything that rolls to-hit. stats are linear, Power is its own axis
/proc/Accuracy_Formula(mob/Offender, mob/Defender, AccMult=1, BaseChance=glob.WorldDefaultAcc, Backfire=0, IgnoreNoDodge=0)
	return RollToHit(Offender, Defender, AccMult, BaseChance, Backfire, IgnoreNoDodge, deflection = 0)

/proc/Deflection_Formula(mob/Offender, mob/Defender, AccMult=1, BaseChance=glob.WorldDefaultAcc, Backfire=0)
	return RollToHit(Offender, Defender, AccMult, BaseChance, Backfire, IgnoreNoDodge = 1, deflection = 1)

/proc/RollToHit(mob/Offender, mob/Defender, AccMult, BaseChance, Backfire, IgnoreNoDodge, deflection)
	if(!Offender || !Defender)
		return MISS
	if(Defender.Frozen == 3)
		return MISS
	if(Offender.HasNoMiss())
		return HIT
	if((Defender.HasNoDodge() || Defender.IsGuarding()) && !IgnoreNoDodge)
		return HIT //guard trades the dodge layer for the DR
	if(Backfire && Offender == Defender)
		if(!deflection)
			return HIT
		AccMult *= 0.8 //your own blast is awkward to parry
	if(Defender.SureDodge && !Defender.passive_handler.Get("NoDodge"))
		Defender.SureDodge = 0
		if(Offender.SureHit)
			return deflection ? HIT : WHIFF
		return MISS
	if(Offender.SureHit)
		Offender.SureHit = 0
		return HIT
	if(Defender.Stunned || Defender.Launched || Defender.PoweringUp)
		return HIT
	if(!deflection && Offender.Grab == Defender)
		return HIT

	if(getBackSide(Offender, Defender))
		if(prob(0.5))
			// smirk
			OMsg(Defender, "[Defender] is getting Ashton'd.")
		AccMult *= 1.2
	if(!deflection && Offender.UsingCriticalImpact())
		AccMult *= 1.15
	if(deflection && (Defender.Beaming || Defender.BusterTech))
		AccMult *= 1.15
	if(Defender.HasRefractivePlating() || Defender.HasPlatedWeights())
		AccMult *= 1.15 //plating trades dodge for armor
	if(!deflection && Offender.AttackQueue)
		AccMult *= Offender.QueuedAccuracy()
	if(Offender.SenseRobbed >= 4 && (Offender.SenseUnlocked <= Offender.SenseRobbed && Offender.SenseUnlocked > 5))
		AccMult *= max(0, 1 - (Offender.SenseRobbed * 0.1))
	if(Defender.SenseRobbed >= 4 && (Defender.SenseUnlocked <= Defender.SenseRobbed && Defender.SenseUnlocked > 5))
		AccMult /= max(0.1, 1 - (Defender.SenseRobbed * 0.1))

	//perception pulls hostile modifiers back toward neutral - never past it
	var/offCorrection = ((Offender.HasClarity() ? glob.PERCEPTION_CORRECTION_LEVELS : 0) + (Offender.HasIntuition() ? glob.PERCEPTION_CORRECTION_LEVELS : 0)) * glob.PERCEPTION_CORRECTION_RATE
	if(offCorrection && AccMult < 1)
		AccMult = min(1, AccMult + offCorrection * AccMult)
	var/defCorrection = ((Defender.HasClarity() ? glob.PERCEPTION_CORRECTION_LEVELS : 0) + (Defender.HasIntuition() ? glob.PERCEPTION_CORRECTION_LEVELS : 0)) * glob.PERCEPTION_CORRECTION_RATE
	if(defCorrection && AccMult > 1)
		AccMult = max(1, AccMult - defCorrection)

	//Power fights on its own axis - low stats and high Power still find the mark
	var/OffenseAdvantage = Offender.GetEffectivePower() / max(Defender.GetEffectivePower(), 0.01)
	var/DefenseAdvantage = Defender.GetEffectivePower() / max(Offender.GetEffectivePower(), 0.01)
	if(glob.CLAMP_POWER)
		if(!Offender.ignoresPowerClamp(Defender))
			OffenseAdvantage = clamp(OffenseAdvantage, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
		if(!Defender.ignoresPowerClamp(Offender))
			DefenseAdvantage = clamp(DefenseAdvantage, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
	if(!deflection)
		if(Offender.passive_handler.Get("Justice") && DefenseAdvantage > OffenseAdvantage)
			OffenseAdvantage = 1
			DefenseAdvantage = 1
		if(Defender.passive_handler.Get("Justice") && OffenseAdvantage > DefenseAdvantage)
			OffenseAdvantage = 1
			DefenseAdvantage = 1

	var/atkRating = (Offender.GetOff(glob.ACC_OFF) + Offender.GetSpd(glob.ACC_OFF_SPD)) * AccMult
	if(deflection)
		atkRating += Offender.GetFor(glob.FOR_BLAST_DENSITY) //dense blasts are hard to swat
	var/defRating = Defender.GetDef(glob.ACC_DEF) + Defender.GetSpd(glob.ACC_DEF_SPD)
	var/TotalAccuracy = BaseChance + (atkRating - defRating) * glob.ACC_POINT + (OffenseAdvantage - DefenseAdvantage) * glob.POWER_ACC_POINT
	TotalAccuracy = clamp(TotalAccuracy, glob.LOWEST_ACC, 100)
	if(glob.DEBUG_MESSAGES_ACCURACY)
		Offender << "--------------------"
		Offender << "atkRating: [atkRating] (AccMult [AccMult])"
		Offender << "defRating: [defRating]"
		Offender << "powerTerm: [(OffenseAdvantage - DefenseAdvantage) * glob.POWER_ACC_POINT]"
		Offender << "TotalAccuracy: [TotalAccuracy] (whiff band +[glob.WHIFF_BAND])"
		Offender << "--------------------"
	if(TotalAccuracy <= glob.LOWEST_ACC)
		Offender.minhitroll++

	var/roll = rand() * 100 //float roll - fractional accuracy counts
	if(roll < TotalAccuracy)
		return HIT
	if(roll < TotalAccuracy + glob.WHIFF_BAND)
		return WHIFF
	return MISS

