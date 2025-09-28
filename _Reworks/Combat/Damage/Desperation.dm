/mob/proc/desperationCheck()
	var/bonus = 1
	if(passive_handler.Get("UnderDog") && !HasInjuryImmune())
		// they are able to get the bonus
		bonus += Saga == "King of Braves" ? 0.15 : 0
		bonus += isRace(HUMAN) ? 0.15 : 0
		return bonus
	return FALSE

/mob/proc/GetDesperationBonus(mob/defender)
	var/bonusRatio = desperationCheck()
	var/defBonusRatio = defender ? defender.desperationCheck() : 0
	var/atkVal = 0.1
	var/defVal = 0.05
	var/injuries = TotalInjury/100
	var/defInjuries = defender ? defender.TotalInjury/100 : 0
	. = 0
	if(bonusRatio)
		. +=  round(((atkVal * bonusRatio) * passive_handler.Get("UnderDog")) * injuries, 0.01) * glob.UNDERDOG_DMG_MULTIPLER
	if(defBonusRatio)
		. -=  round(((defVal * defBonusRatio) * defender.passive_handler.Get("UnderDog")) * defInjuries, 0.01) * glob.UNDERDOG_RED_MULTIPLER
