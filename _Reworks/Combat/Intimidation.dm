// NEW VARS
/mob/var/IntimidationMult // a very important part that multiplies intim so it can remain a normal value

// NEW PROCS
/mob/proc/getSSIntim(mob/defender, val) // get Saiyan Soul Intim
	if(!defender) return
	if(defender.CheckSlotless("Saiyan Soul") && !defender.Target.CheckSlotless("Saiyan Soul"))
		if(val < defender.Target.GetIntimidation())
			return defender.Target.GetIntimidation()
	return val
// NEW MAIN FUNCTIONS
/mob/proc/getIntimDMGReduction(mob/defender)
	var/defIntim = defender.GetIntimidation()
	var/atkIntim = GetIntimidation()
	var/atkIntimIgnore = GetIntimidationIgnore(defender)
	var/defIntimIgnore = defender.GetIntimidationIgnore(src)
	var/val = defIntim // the intimidation as it stands
	var/totalMult = 0 // return value

	//def intim = 5, atk intim = 0, intim ignore = 0


	val = getSSIntim(defender, val)
	if(val > 1)
		atkIntim -= (atkIntim*defIntimIgnore)
	if(val > 1)
		val -= (val*atkIntimIgnore)
	if(val == 1 && atkIntim == 1)
		return 0
	if(val <=0)
		val = 1
	if(glob.NEWINTIMCALC)
		if(val > atkIntim)
			totalMult = -((val - atkIntim) / glob.INTIMRATIO)
		else
			totalMult = ((atkIntim - val) / glob.INTIMRATIO)
	if(totalMult >= 10)
		totalMult = 10
	if(totalMult <= -10)
		totalMult = -10
	return totalMult




/mob/proc/getVampireIntim()
	if(Secret != "Vampire")
		return 0
	var/obj/Skills/Buffs/SlotlessBuffs/v = GetSlotless("Vampire")
	var/obj/Skills/Buffs/SlotlessBuffs/w = GetSlotless("Wassil")
	var/obj/Skills/Buffs/SlotlessBuffs/r = GetSlotless("Rotshreck")
	if(r)
		return round((1 + (getSecretLevel() * 0.5)) * (1 + secretDatum:getBloodPowerRatio()), 0.05)
	else if(w)
		return round((1 + (getSecretLevel()  * 0.25)) * (1 + secretDatum:getHungerRatio()), 0.05)
	else if(v)
		return 1.25 + round((getSecretLevel() * 0.125) * (1 + secretDatum:getBloodPowerRatio()), 0.05)



/mob/proc/GetIntimidation()
	var/Effective=src.Intimidation
	if(src.ShinjinAscension=="Makai")
		Effective*=src.GetGodKi()*50
	if(isRace(DEMON) || src.CheckSlotless("Majin"))
		Effective*=1 + (src.Potential/25)
	if(isRace(DRAGON))
		Effective += AscensionsAcquired * 25
	Effective *= 1 + passive_handler.Get("Mythical")
	if(src.isRace(MAJIN))
		var/unhingedBoon = Class == "Unhinged" ? 1 : 0
		if(unhingedBoon)
			unhingedBoon = abs(src.Health - 100)/40
		switch(src.AscensionsAcquired)
			if(1)
				Effective*= 1.5 + unhingedBoon
			if(2)
				Effective*= 3 + unhingedBoon
			if(3)
				Effective*= 4.5 + unhingedBoon
			if(4)
				Effective*= 6 + unhingedBoon
			if(5)
				Effective*= 8 + unhingedBoon

	if(src.isRace(MAKYO)&&src.ActiveBuff&&src.AscensionsAcquired&&!src.CyberCancel)
		Effective *= 1.25 + (AscensionsAcquired*0.25)

	if(src.CheckActive("Mobile Suit")||src.CheckSlotless("Battosai")||src.CheckSlotless("Susanoo"))
		Effective+=5
		if(Effective<15)
			Effective=15
			if(src.CheckActive("Mobile Suit"))
				for(var/obj/Items/Gear/Mobile_Suit/ms in src)
					Effective*=ms.Level
	if(src.Health<(10-src.HealthCut)&&src.HealthAnnounce10&&src.Saga=="King of Braves"&&src.SpecialBuff)
		var/modifier = 1 - (Health / 10)
		if(src.SpecialBuff.BuffName=="Broken Brave")
			Effective*= (SagaLevel/2) + modifier
		else if(src.SpecialBuff.BuffName=="Genesic Brave")
			Effective *= SagaLevel + modifier
	var/ShonenPower = ShonenPowerCheck(src)
	if(ShonenPower)
		Effective*=GetSPScaling(ShonenPower)
	if(src.HasHellPower())
		Effective*=src.GetHellScaling()
	if(src.KaiokenBP>1)
		Effective*=src.KaiokenBP
	Effective+=src.getVampireIntim()
	if(src.IntimidationMult)
		Effective*=src.IntimidationMult
	if(Effective<0)
		Effective=1
	return Effective