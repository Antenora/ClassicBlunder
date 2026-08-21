proc/randValue(min,max,divider=10)
	return rand(min*divider,max*divider)/divider

//the one damage formula. every stat acts as stat+10, End is %DR. str10 mirror melee lands 6.075
globalTracker/var
	STRIKE_MITIGATION_K = 10
	STRIKE_DAMAGE_SCALE = 0.75
	STRIKE_ATK_BASE = 10
	HP_PER_VIT = 100
	HP_STAT_BASE = 10

/proc/strikeCoreDamage(powerDif, atk, def)
	if(atk < 0) atk = 0
	if(def < 0) def = 0
	atk += glob.STRIKE_ATK_BASE
	return glob.STRIKE_DAMAGE_SCALE * (powerDif ** glob.DMG_POWER_EXPONENT) * atk * (glob.STRIKE_MITIGATION_K / (glob.STRIKE_MITIGATION_K + def))

/mob/proc/strikeJudgmentMult() //what the old damage-roll Judgment bonus capped out at
	return (Judgment && !Oozaru && AscensionsAcquired) ? 1.3333 : 1
