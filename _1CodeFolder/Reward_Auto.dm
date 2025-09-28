#define DAILY_REWARD_TIME Hour(10) // THIS IS 6 PM ANY DAY
// IF IT WAS 6 PM RN REALTIME WOULD U DAYTIME
//	PotentialLastDailyGain - if they have triggered a reward today
//	RewardsLastGained - what day was it when they last gained rewards, this should b 3 for everyone

/globalTracker/var/economy_charge_mult = 1

/mob/proc/getDailyCheckTimer()
	var/currentHour = time2text(world.realtime, "hh", "EST")
	currentHour = text2num(currentHour)
	var/zeroHour = world.realtime - currentHour HOURS
	// this is when it was 0
	var/checktime = zeroHour + DAILY_REWARD_TIME
	if(world.realtime > checktime)
		return TRUE
	else
		return FALSE

/proc/time2days(pastTime, currentTime)
	var/currentDay = time2text(currentTime, "dd", "EST")
	currentDay = text2num(currentDay)
	var/pastDay = time2text(pastTime, "dd", "EST")
	pastDay = text2num(pastDay)
	return (currentDay - pastDay)

mob
	proc
		reward_auto()
			/*
				if it is past 6pm
					check to see when the last day they gained something was
						if the day is lower than the days of wipe go to the next check

						give a difference in daily pot based on how many days are different, generally 1
						then set the rewards last gained to the current day

			*/
			if(RewardsLastGained < DaysOfWipe())
				var/Dif=((glob.progress.DaysOfWipe-RewardsLastGained))
				Dif=round(Dif)
				if(DEBUGGING)
					Dif = 1
				if(Dif > glob.progress.DaysOfWipe)
					Dif=glob.progress.DaysOfWipe
				var/Statement=1
				while(Dif>0)
					src << "Gaining routine RPP for [Statement] day\s."
					reward_self()
					Statement++
					Dif--
				RewardsLastGained=glob.progress.DaysOfWipe
		reward_self()
			var/AddRPP=glob.progress.RPPDaily/6
			var/YourRPP=AddRPP
			DaysOfWipe()//mak sure globalrpp set.

			if(YourRPP>0)
				var/EMult=glob.progress.RPPBaseMult
				EMult*=src.GetRPPMult()
				YourRPP*=EMult

				GiveRPP(round(YourRPP))

			if((src.EraBody!="Child"||!src.EraBody)&&!src.Dead)
				src << "You gain money from routine tasks."
				var/extraMoney = 0
				if(!information)
					information = new()
				if(information.rankingTier == "Ranker" || information.rankingTier == "Top Ranker")
					var/currentRanking = information.rankingNumber
					// 10,000 at 30 pot, only count intervals of 10
					var/currentPot = round(glob.progress.totalPotentialToDate,10)
					var/baseSupporterMoney = 500
					extraMoney = baseSupporterMoney * currentPot - ((currentRanking-1) * 1000)
					if(extraMoney > 0)
						src << "PLACEHOLDER: You gain [extraMoney] money from your ranking."
					else
						extraMoney = 0
				src.GiveMoney(max(0,round(glob.progress.EconomyIncome*src.EconomyMult*src.Intelligence)) + extraMoney)

			moneyGrindedDaily = 0