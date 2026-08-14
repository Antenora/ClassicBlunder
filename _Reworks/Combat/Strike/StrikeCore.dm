proc/randValue(min,max,divider=10)
	return rand(min*divider,max*divider)/divider

//the one damage formula. atk is linear, End is %DR. str10 mirror melee lands 0.162
globalTracker/var
	STRIKE_MITIGATION_K = 30
	STRIKE_DAMAGE_SCALE = 0.0266667

/proc/strikeCoreDamage(powerDif, atk, def)
	if(atk < 1) atk = 1
	if(def < 0) def = 0
	return glob.STRIKE_DAMAGE_SCALE * (powerDif ** glob.DMG_POWER_EXPONENT) * atk * (glob.STRIKE_MITIGATION_K / (glob.STRIKE_MITIGATION_K + def))

/mob/proc/strikeJudgmentMult() //what the old damage-roll Judgment bonus capped out at
	return (Judgment && !Oozaru && AscensionsAcquired) ? 1.3333 : 1
