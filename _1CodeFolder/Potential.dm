/var/POTENTIAL_GAIN_RATE = 5 // 25% MORE POTENTIAL GAIN
/var/MAX_POTENTIAL_PER_KILL = 1 // 50% OF WIPE POTENTIAL PER KILL

/mob/Admin3/verb/Change_Extra_Potential_Gain()
	set category = "Admin"
	set name = "Change Extra Potential Gain"
	MAX_POTENTIAL_PER_KILL = input("How much potential should be gained per kill? (Default: 50% of wipe's days)") as num
	world<< "[src] has changed the potential gain per kill to [MAX_POTENTIAL_PER_KILL] potential."


mob
	var/ECCHARACTER = FALSE
	proc
		potential_gain(val, npc=0)
			if(ECCHARACTER) return
			potential_max()
			if(Potential < PotentialCap && PotentialStatus != "Caught Up")
				if(npc)
					switch(PotentialStatus)
						if("Average")
							val *= 2.5
						if("Focused")
							val *= 5
					if(party)
						if(party.highest_potential > Potential)
							val*=(party.members.len)//stop reducing pot gain
							val*=(party.highest_potential / Potential)


				if(MAX_POTENTIAL_PER_KILL <= 0) MAX_POTENTIAL_PER_KILL = 1
				val = min(val * (1 + PotentialRate), MAX_POTENTIAL_PER_KILL)
				Potential += val
				if(val > 0)
					if(isRace(ANDROID)) HealthCut += (val / 100)
					if(isRace(DEMIFIEND))
						refreshMagatama()
						if(SagaLevel < 3 && Potential >= 20)  // ASCENSION_ONE_POTENTIAL + 10
							while(SagaLevel < 3)
								SagaLevel++
								tierUpSaga("Devil Summoner")
						if(SagaLevel < 5 && Potential >= 35)  // ASCENSION_TWO_POTENTIAL + 5
							while(SagaLevel < 5)
								SagaLevel++
								tierUpSaga("Devil Summoner")
						if(SagaLevel < 7 && Potential >= 50)  // ASCENSION_THREE_POTENTIAL + 10
							while(SagaLevel < 7)
								SagaLevel++
								tierUpSaga("Devil Summoner")

				if(Potential > PotentialCap && PotentialRate > 0) Potential = PotentialCap

			potential_max()
			potential_ascend()

		potential_max()
			if(ECCHARACTER) return
			var/Max = glob.progress.totalPotentialToDate
			if(Max < PotentialHeadStart) Max = PotentialHeadStart
			PotentialCap = Max
			Max = round(Max)
			if(Potential >= Max && PotentialRate > 0)//ecs will have potentialrate 0 and so they can be any level
				Potential = Max
				PotentialStatus="Caught Up"
			else if(Potential > Max * 0.8 && Potential < Max) PotentialStatus = "Average"
			else PotentialStatus="Focused"

		SpendRPP(val, Purchase=0, Training=0)//Purchase is a variable that holds whatever you're trying to buy.  Optional.
			var/TotalSpend = GetRPPSpendable()
			if(TotalSpend >= val)
				var/Remaining = val;
				if(Remaining > 0)
					RPPSpent += Remaining
					RPPSpendable -= Remaining
					Remaining = 0
				if(Purchase)
					if(Training)
						potential_gain(val / glob.progress.RPPDaily)
					src << "You purchase [Purchase] for [Commas(val)] RPP!"
				return 1
			else
				if(Purchase) src << "You don't have enough RPP to buy [Purchase]! ([TotalSpend] / [val])"
				else src << "You don't have enough RPP! ([TotalSpend] / [val])"
				return 0

		CheckAscensions()
			if(AscensionsAcquired == null || AscensionsAcquired <= 0 || !AscensionsAcquired) AscensionsAcquired = 0;
			potential_max();
			AscAvailable(race);

		potential_ascend()
			if(Potential >= 10)
				if(passive_handler.Get("KiControlMastery") < 1)
					passive_handler.Set("KiControlMastery", 1);
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution, src))
				var/obj/Skills/Buffs/SlotlessBuffs/d = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution)
				if(d.last_evo_gain == 0) d.last_evo_gain = world.realtime
				if(d.last_evo_gain + 24 HOURS < world.realtime)
					if(d.evolution_charges < 1)
						d.last_evo_gain = world.realtime
						d.evolution_charges++
			if(Potential>=15 && SagaLevel < 2 && Saga) saga_up_self()
			if(Potential >= 35 && SagaLevel < 3 && Saga) saga_up_self()

globalTracker
	var/list/POTENTIAL_POWER_VALS = list(1.5,//10 potential
		2,//20 potential
		3,//30 potential
		5,//40 potential
		7.5,//50 potential
		10,//60 potential
		15,//70 potential
		25,//80 potential
		40,//90 potential
		50,//100 potential
		75,//110 potential
		125,//120 potential
		200,//130 potential
		300,//140 potential
		400);//150 potential

	proc/resetPotentialPowerVals()//dumb workaround for assigning lists to global variables
		var/list/defaultPowerVals = list(1.5,//10 potential
		2,//20 potential
		3,//30 potential
		5,//40 potential
		7.5,//50 potential
		10,//60 potential
		15,//70 potential
		25,//80 potential
		40,//90 potential
		50,//100 potential
		75,//110 potential
		125,//120 potential
		200,//130 potential
		300,//140 potential
		400);//150 potential
		POTENTIAL_POWER_VALS = defaultPowerVals;


proc/potential_power(mob/m)
	if(m.get_potential()==m.potential_last_checked) return//don't keep getting potential power if the potential hasn't changed
	
	var/maxThreshold = glob.POTENTIAL_POWER_VALS.len;//what is the maximum value defined for powervals?
	var/currentThreshold = min(maxThreshold, round(m.get_potential()/10));//find out what is the highest Tens threshold we can satisfy
	var/powerFraction = min(10, (m.get_potential() % 10));//get the remainder that is left over towards the next Tens threshold
	
	if(currentThreshold == 0) m.potential_power_mult = 0;
	else m.potential_power_mult=glob.POTENTIAL_POWER_VALS[currentThreshold];

	if(currentThreshold != maxThreshold) m.potential_power_mult += potential_fraction(powerFraction, currentThreshold);

	m.potential_power_mult = round(m.potential_power_mult, 0.05);

	m.potential_last_checked=m.get_potential()

proc/potential_fraction(sparePotential, potentialBracket)
	if(potentialBracket == glob.POTENTIAL_POWER_VALS.len) return 0;//this proc should only be called if you are not at the max threshold, but we'll state it again anyway
	var/lastThresholdValue = 0;
	var/currentlySatisfiedThreshold = potentialBracket;
	if(currentlySatisfiedThreshold) lastThresholdValue = glob.POTENTIAL_POWER_VALS[currentlySatisfiedThreshold];//only set this if it is above 0
	var/nextThresholdValue = glob.POTENTIAL_POWER_VALS[potentialBracket+1];
	var/gap = nextThresholdValue - lastThresholdValue;//the difference between the next potential threshold value and this one
	gap /= 10;//there are 10 potentials between each threshold
	return (sparePotential * gap); //return the appropriate value for your progress towards the next threshold
