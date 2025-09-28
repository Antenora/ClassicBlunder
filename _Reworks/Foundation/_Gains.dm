z/mob/proc/checkHealthAlert()
	//50% injury check
	var/exhaustedMessage = SpecialBuff ? SpecialBuff.ExhaustedMessage : ExhaustedMessage
	var/desperateMessage = SpecialBuff ? SpecialBuff.DesperateMessage : BarelyStandingMessage
	if(TotalInjury > 50 && !src.InjuryAnnounce && !passive_handler["Beefy"])
		OMessage(10, "[src] [BeatenMessage]!")
		InjuryAnnounce = 1

	// Nanite Check
	if(NanoBoost && Health<=glob.gains.NANOHEALTH*(1-HealthCut)&&!NanoAnnounce)
		OMsg(src, "<font color='green'>[src]'s nanites respond to their physical trauma, bolstering their cybernetic power!</font color>")
		NanoAnnounce = 1
	// 25% health check
	if(Health < 25*(1-HealthCut) && !HealthAnnounce25)
		if(!passive_handler["Beefy"])
			if(!ExhaustedColor)
				OMessage(10, "<font color=#F07E1F>[src] [exhaustedMessage]!", "[src]([src.key]) has 25% health left.</font>")
			else
				OMessage(10,"font color='[ExhaustedColor]'> [src] [exhaustedMessage]!", "[src]([src.key]) has 25% health left.</font>")
			HealthAnnounce25 = 1
		var/shonenMoment = ShonenPowerCheck(src)
		if(shonenMoment)
			VaizardHealth += triggerPlotArmor(shonenMoment, HasUnstoppable())
			src.OMessage(10, "<font color=#c3b329>[src]'s will to be a HERO gives them a second wind!</font>", "[src]([src.key]) has triggered plot armor.")

	// 10% health check
	if(Health < 10*(1-HealthCut) && !HealthAnnounce10)
		if(!passive_handler["Beefy"])
			if(!BarelyStandingColor)
				OMessage(10, "<font color=#F07E1F>[src] [desperateMessage]!", "[src]([src.key]) has 10% health left.</font>")
			else
				OMessage(10,"font color='[BarelyStandingColor]'>[src] [desperateMessage]!", "[src]([src.key]) has 10% health left.</font>")
			HealthAnnounce10 = 1
//**TESTED AND WORKS */
/mob/proc/reduceErodeStolen()
	var/list/stats = list("Str","Spd","For", "End","Off","Def")
	for(var/x in stats)
		if(vars["[x]Stolen"])
			vars["[x]Stolen"] = max(vars["[x]Stolen"] - (0.1*world.tick_lag), 0)
		if(vars["[x]Eroded"])
			vars["[x]Eroded"] = max(vars["[x]Eroded"] - (0.1*world.tick_lag),0)
	if(PowerEroded>0)
		PowerEroded = PowerEroded - (0.02 * world.tick_lag)



/mob/proc/meditationChecks()
	var/tick_second = world.tick_lag SECOND
	if(icon_state == "Meditate")
		MeditateTime += tick_second
		if(Corruption>MinCorruption&&isRace(DEMON))
			Corruption -= (5 * tick_second) - (AscensionsAcquired/2)
			Corruption = max(MinCorruption, Corruption)
		if(Secret == "Eldritch")
			var/SecretInfomation/Eldritch/s = secretDatum
			s.releaseMadness(src)

		if(Health>=75*(1-HealthCut) && Anger!=0)
			calmcounter -= tick_second
		else
			calmcounter = 5 

		if(Secret == "Vampire" && MeditateTime == 10 SECONDS)
			var/obj/Skills/Buffs/SlotlessBuffs/R = GetSlotless("Rotshreck")
			if(R && R.NeedsHealth == 0)
				R.NeedsHealth = 25
				R.TooMuchHealth = 50
				R:adjust(src)
				src<<"You no longer fear for your life..."
		if(MeditateTime >= 5 SECONDS)
			for(var/obj/Skills/Queue/Finisher/Cycle_of_Samsara/cos in src)
				cos.Mastery = 0
			for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Samsara/s in SlotlessBuffs)
				s.Timer = 400


		if(MeditateTime >= 15 SECONDS) 
			reduceErodeStolen()

		if(MeditateTime == 15 SECONDS)
			if(isRace(MAJIN))
				majinPassive.resetVariables(src)
			for(var/obj/Skills/s in Skills)
				if(s.possible_skills)
					for(var/index in s.possible_skills)
						if(s.possible_skills[index].Cooldown<0 && s.possible_skills[index].Using)
							src << "One or more of your skills will be made available to you again when you stop meditating."
				if(s.Cooldown<0 && s.Using)
					src << "One or more of your skills will be made available to you again when you stop meditating."
				break

		if(MeditateTime == 40 SECONDS)
			if(SpecialBuff)
				if(SpecialBuff.BuffName == "Ripper Mode")
					SpecialBuff?:sandevistanUsages = 0
					src << "Your Sandevistan Usages has been reset."
		if(Secret == "Zombie" && MeditateTime == 70 SECONDS)
			zombieGetUps = 0
			src << "Your get ups have been reset"

		if(calmcounter<=0)
			calmcounter=5
			if(Anger)
				Calm()
		if(CheckSpecial("Jinchuuriki") || CheckSpecial("Vaizard Mask"))
			if(SpecialBuff.Mastery <= 1)
				SpecialBuff.Trigger(src, Override=1)
	else
		MeditateTime=0
//**TESTED AND WORKS **/
/mob/proc/drainTransformations(trans, transMastery)
	// TRANS / TRANSMASTERY FOR CHANGIE 4TH FORM
	var/drain
	if(trans && transMastery <= 75)
		drain = round(30 - ((transMastery - 5) * 30) / (75 - 5), 1)
		if(drain < 0)
			drain = 0
		if(Energy < drain && !HasNoRevert() && !Dead && !HasMystic())

			Revert()
			LoseEnergy(drain)
			src<<"The strain of your transformation forced you to revert."

	if(trans==4 && transMastery < 100 && isRace(CHANGELING))
		drain = round(30 - (40 * log(1 + transMastery / 100)), 1)
		if(drain < 0)
			drain = 1
		if(Energy < drain && !HasNoRevert())
			GainFatigue(drain)
			Revert()
			src<<"The strain of Golden Form forced you to revert!"

/mob/proc/doLoopTimers()
	if(Lethal)
		Lethal-= world.tick_lag
		if(Lethal <= 0)
			Lethal = 0
			OMsg(src, "<font color='grey'>[src] will no longer deal lethal damage.</font color>")
	// Move this to a different loop, most likely
	if(TsukiyomiTime)
		TsukiyomiTime-= world.tick_lag
		if(TsukiyomiTime<= 0 && TsukiyomiTime)
			TsukiyomiTime = 0
			animate(client, color=null, time=1)
			OMsg(src, "<font color='grey'>[src] is no longer trapped in Tsukiyomi.</font color>")

	if(warperTimeLock>0)
		warperTimeLock-= world.tick_lag
		warperTimeLock = max(0, warperTimeLock)

	if(TimeStop)
		var/obj/Skills/Buffs/SlotlessBuffs/Grimoire/Time_Stop/book = new
		book = locate() in src
		LoseHealth(0.5/book.Mastery)
		book:TimeStopped+= world.tick_lag
		if(book:TimeStopped>book.Mastery+1)
			SkillX("Time Stop",x)
	var/obj/Skills/Devils_Deal/dd = findDevilsDeal(src)
	if(dd)
		if(CurrentlySummoned)
			dd.incrementSummonReturnTime(world.tick_lag)
			if(dd.getSummonReturnTime() >= dd.getHomeTime())
				dd.returnToOrg(src)
				OMsg(src, "<font color='grey'>[src] is no longer being summoned.</font color>")


/mob/proc/newGainLoop()
	set waitfor = 0

	// var/mob/players/M = null
	// var/val = 0

	if(!client)
		gain_loop.Remove(src)
		return
	if(KO&&icon_state!="KO")
		icon_state="KO"
	if(PureRPMode)
		if(!Stasis)
			Stasis=1
		// return 
	if(!PureRPMode)
		checkHealthAlert()
		meditationChecks()
		if(MovementCharges < GetMaxMovementCharges())
			MovementChargeBuildUp()

		drainTransformations(transActive, race.transformations[transActive].mastery)

		if(Grab) Grab_Update()
		EnergyMax = 100

		doLoopTimers()
		// Tick based activity / Timers

		Update_Stat_Labels()

