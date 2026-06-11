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
		potential_gain(var/val, var/npc=0)
			if(ECCHARACTER) return

			src.potential_max()

			if(src.Potential<src.PotentialCap && src.PotentialStatus!="Caught Up")

				if(npc)
					switch(src.PotentialStatus)
						if("Average")
							val*=2.5
						if("Focused")
							val*=5
					// if(src.SteadyRace())
					// 	var/eff=min(100, src.Potential)
					// 	eff=round(eff, 10)
					// 	eff/=10
					// 	reduce=eff
					// 	reduce+=1
					// if(src.TransRace())
					// 	var/trans=src.TransUnlocked()
					// 	if(src.Race=="Changeling")
					// 		trans-=3
					// 	reduce=2**(trans)
					// if(src.Potential>100)
					// 	var/eff=src.Potential-100
					// 	reduce+=round(eff/20)//every 20 potential over 100 increases reduction by 1
					// if(src.CyberCancel)
					// 	if(reduce)
					// 		reduce*=(1+src.CyberCancel)
					// if(reduce)
					// 	val/=reduce
					if(src.party)
						if(src.party.highest_potential>src.Potential)
							val*=(src.party.members.len)//stop reducing pot gain
							val*=(src.party.highest_potential/src.Potential)


				val *= 1 + src.PotentialRate
				if(MAX_POTENTIAL_PER_KILL<=0)
					MAX_POTENTIAL_PER_KILL = 1
				if(val > MAX_POTENTIAL_PER_KILL)
					val=MAX_POTENTIAL_PER_KILL
				src.Potential+=val
				if(val>0)
					if(isRace(ANDROID))
						src.HealthCut+=(val/100)
					if(isRace(/race/demi_fiend))
						src.refreshMagatama()
						if(src.SagaLevel < 3 && src.Potential >= 20)  // ASCENSION_ONE_POTENTIAL + 10
							while(src.SagaLevel < 3)
								src.SagaLevel++
								src.tierUpSaga("Devil Summoner")
						if(src.SagaLevel < 5 && src.Potential >= 35)  // ASCENSION_TWO_POTENTIAL + 5
							while(src.SagaLevel < 5)
								src.SagaLevel++
								src.tierUpSaga("Devil Summoner")
						if(src.SagaLevel < 7 && src.Potential >= 50)  // ASCENSION_THREE_POTENTIAL + 10
							while(src.SagaLevel < 7)
								src.SagaLevel++
								src.tierUpSaga("Devil Summoner")

				if(src.Potential>src.PotentialCap && src.PotentialRate>0)
					src.Potential=src.PotentialCap

			potential_max()
			potential_ascend()

		potential_max()
			if(ECCHARACTER) return
			var/Max=glob.progress.totalPotentialToDate
			if(Max<PotentialHeadStart)
				Max=PotentialHeadStart
			PotentialCap = Max
			// Max+=src.PotentialRate
			Max=round(Max)
			if(src.Potential>=Max && src.PotentialRate>0)//ecs will have potentialrate 0 and so they can be any level
				src.Potential=Max
				src.PotentialStatus="Caught Up"
			else if(src.Potential>Max*0.8 && src.Potential<Max)
				src.PotentialStatus="Average"
			else
				src.PotentialStatus="Focused"

			if(isRace(SHINJIN))
				var/Cap=Max/100

				if(src.AscensionsAcquired>0&&src.ShinjinAscension=="Makai")
					Cap+=0.5

				if(src.ShinjinAscension=="Kai"&&!src.AscensionsAcquired)
					Cap/=2

				if(src.GodKi>Cap && src.PotentialRate>0)
					src.GodKi=Cap

		SpendRPP(var/val, var/Purchase=0, var/Training=0)//Purchase is a variable that holds whatever you're trying to buy.  Optional.
			var/TotalSpend=src.GetRPPSpendable()
			if(TotalSpend>=val)
				var/Remaining=val
				if(Remaining>0)
					src.RPPSpent+=Remaining
					src.RPPSpendable-=Remaining
					Remaining=0
				if(Purchase)
					if(Training)
						src.potential_gain(val/glob.progress.RPPDaily)
					src << "You purchase [Purchase] for [Commas(val)] RPP!"
				return 1
			else
				if(Purchase)
					src << "You don't have enough RPP to buy [Purchase]! ([TotalSpend] / [val])"
				else
					src << "You don't have enough RPP! ([TotalSpend] / [val])"
				return 0
		CheckAscensions()
			if(AscensionsAcquired == null||AscensionsAcquired <= 0||!AscensionsAcquired) AscensionsAcquired = 0;
			potential_max();
			AscAvailable(race);



		potential_ascend()
		//	if(secretDatum.nextTierUp != 999 && Secret)
		//		secretDatum.checkTierUp(src)
			/*if(isRace(DEMON))
				var/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/d = race:findTrueForm(src)
				if(d.last_charge_gain == 0) d.last_charge_gain = world.realtime
				if(d.last_charge_gain + 24 HOURS < world.realtime)
					if(d.current_charges < AscensionsAcquired)
						d.last_charge_gain = world.realtime
						d.current_charges++*/
			/*if(isRace(MAKAIOSHIN))
				var/obj/Skills/Buffs/SlotlessBuffs/Falldown_Mode/Makaioshin/d = race:findFalldown(src)
				if(d.last_charge_gain == 0) d.last_charge_gain = world.realtime
				if(d.last_charge_gain + 24 HOURS < world.realtime)
					if(d.current_charges < AscensionsAcquired)
						d.last_charge_gain = world.realtime
						d.current_charges++*/
			if(Potential>=10)
				if(passive_handler.Get("KiControlMastery") < 1)
					passive_handler.Set("KiControlMastery", 1);
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution, src))
				var/obj/Skills/Buffs/SlotlessBuffs/d = src.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution)
				if(d.last_evo_gain == 0) d.last_evo_gain = world.realtime
				if(d.last_evo_gain + 24 HOURS < world.realtime)
					if(d.evolution_charges < 1)
						d.last_evo_gain = world.realtime
						d.evolution_charges++
			//todo: actually unlock transformation if above potential
			if(Potential>=15)
				if(SagaLevel < 2 && Saga)
					saga_up_self()
			if(Potential >= 35 && SagaLevel < 3 && Saga)
				saga_up_self()

globalTracker
	var/list/POTENTIAL_POWER_VALS = list(10,//10 potential
		20,//20 potential
		30,//30 potential
		50,//40 potential
		100,//50 potential
		150,//60 potential
		300,//70 potential
		500,//80 potential
		900,//90 potential
		1500,//100 potential
		2500,//110 potential
		4750,//120 potential
		8250,//130 potential
		14500,//140 potential. oh gosh it's over nine thousand, and this isn't even the last tier
		25000);//150 potential

	proc/resetPotentialPowerVals()//dumb workaround for assigning lists to global variables
		var/list/defaultPowerVals = list(10,//10 potential
		20,//20 potential
		30,//30 potential
		50,//40 potential
		100,//50 potential
		150,//60 potential
		300,//70 potential
		500,//80 potential
		900,//90 potential
		1500,//100 potential
		2500,//110 potential
		4750,//120 potential
		8250,//130 potential
		14500,//140 potential. oh gosh it's over nine thousand, and this isn't even the last tier
		25000);//150 potential
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
