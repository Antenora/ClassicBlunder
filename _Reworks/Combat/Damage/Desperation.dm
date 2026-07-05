/mob/proc/desperationCheck()
	var/bonus = 1
	if(passive_handler.Get("UnderDog") && !HasInjuryImmune()||passive_handler.Get("Determination(Orange)") && !HasInjuryImmune()||passive_handler.Get("Determination(White)") && !HasInjuryImmune())
		// they are able to get the bonus
		bonus += Saga == "King of Braves" ? 0.35 : 0
		bonus += Saga == "Kamui" ? 0.35 : 0
		bonus += Secret == "Spiral" ? 0.35 : 0
		bonus += isRace(HUMAN) ? 0.35 : 0
		bonus += isRace(HALFSAIYAN) ? 0.35 : 0
		bonus += isRace(POPO) ? 0.35 : 0
		bonus += passive_handler.Get("Determination(Orange)") ? (ManaAmount/250) : 0
		bonus += passive_handler.Get("Determination(White)") ? (ManaAmount/250) : 0
		return bonus
	return FALSE

/mob/proc/GetDesperationBonus(mob/defender)
	var/bonusRatio = desperationCheck()
	var/defBonusRatio = defender ? defender.desperationCheck() : 0
	var/atkVal = 0.15
	var/defVal = 0.075
	var/PopoVal=1
	if(isRace(POPO))
		PopoVal*=GetPowerUpRatio()
	var/injuries = TotalInjury/100
	var/defInjuries = defender ? defender.TotalInjury/100 : 0
	var/UnderDet= passive_handler.Get("Determination(Orange)") ? 1 : 0
	UnderDet += passive_handler.Get("Determination(White)") ? 1 : 0
	. = 0
	if(bonusRatio)
		. +=  round(((atkVal * bonusRatio) * (UnderDet+passive_handler.Get("UnderDog"))) * injuries, 0.01) * glob.UNDERDOG_DMG_MULTIPLER * PopoVal
	if(defBonusRatio)
		. -=  round(((defVal * defBonusRatio) * (UnderDet+defender.passive_handler.Get("UnderDog"))) * defInjuries, 0.01) * glob.UNDERDOG_RED_MULTIPLER * PopoVal
