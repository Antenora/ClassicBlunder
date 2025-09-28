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

			if(src.Potential<src.PotentialCap && src.PotentialStatus!="Distracted")

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

				if(src.Potential>src.PotentialCap && src.PotentialRate>0)
					src.Potential=src.PotentialCap

			src.potential_max()

			if(src.Potential>=15)
				if(passive_handler.Get("KiControlMastery")<1)
					passive_handler.Set("KiControlMastery", 1)


			src.potential_ascend()

		potential_max()
			if(ECCHARACTER) return
			var/Max=glob.progress.totalPotentialToDate
			PotentialCap = Max
			// Max+=src.PotentialRate
			Max=round(Max)
			if(src.Potential>=Max && src.PotentialRate>0)//ecs will have potentialrate 0 and so they can be any level
				src.Potential=Max
				src.PotentialStatus="Distracted"
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
			if(src.AscensionsAcquired<=0||src.AscensionsAcquired==null||!src.AscensionsAcquired)
				src.AscensionsAcquired=0
			src.potential_max()
			src.AscAvailable(src.race)



		potential_ascend(var/Silent=0)
		//	if(secretDatum.nextTierUp != 999 && Secret)
		//		secretDatum.checkTierUp(src)
			if(isRace(DEMON))
				var/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/d = race:findTrueForm(src)
				if(d.last_charge_gain == 0) d.last_charge_gain = world.realtime
				if(d.last_charge_gain + 24 HOURS < world.realtime)
					if(d.current_charges < AscensionsAcquired)
						d.last_charge_gain = world.realtime
						d.current_charges++

			if(Potential>=15)
				if(SagaLevel < 2 && Saga)
					saga_up_self()
			if(Potential >= 35 && SagaLevel < 3 && Saga)
				saga_up_self()

proc
	potential_power(var/mob/m)
		if(m.get_potential()==m.potential_last_checked)
			return//don't keep getting potential power if the potential hasn't changed

		var/tier_rem=min(10, (m.get_potential()/10))
		var/max_tier = min(10,round((glob.progress.totalPotentialToDate*1.25)/10))
		var/prev_tier= min(max_tier, round(m.get_potential()/10))
		var/list/power_vals=list(5,10,25,50,100,150,200,300,400,500)
		//100 potential = 500 bpm
		//90 potential = 400 bpm
		//80 potential = 300 bpm
		//70 potential = 200 bpm
		//60 potential = 150 bpm
		//50 potential = 100 bpm
		//40 potential = 50 bpm
		//30 potential = 25 bpm
		//20 potential = 10 bpm
		//10 potential = 5 bpm
		if(prev_tier==0)
			m.potential_power_mult=1
		else
			m.potential_power_mult=power_vals[prev_tier]

		if(prev_tier!=10)
			m.potential_power_mult+=potential_fraction(tier_rem-prev_tier, prev_tier)

		if(m.get_potential()>100)
			m.potential_power_mult+=((m.get_potential()-100)*25)//potential > 100 gives you an extra 25 bp every % of potential

		m.potential_last_checked=m.get_potential()

	potential_fraction(var/val, var/last_tier)
		switch(last_tier)
			if(0)
				return val*4//5
			if(1)
				return val*5//10
			if(2)
				return val*15//25
			if(3)
				return val*25//50
			if(4)
				return val*50//100
			if(5)
				return val*50//150
			if(6)
				return val*50//200
			if(7)
				return val*100//300
			if(8)
				return val*100//400
			if(9)
				return val*100//500
			//10 doesnt get fractions