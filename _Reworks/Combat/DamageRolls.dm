proc/randValue(min,max,divider=10)
	return rand(min*divider,max*divider)/divider

/mob/proc/GetDamageMod()
	var/val
	if(glob.USE_FIXED_DAMAGE_ROLL)
		val = glob.FIXED_DAMAGE_ROLL	
	else
		val = randValue(glob.min_damage_roll, glob.max_damage_roll)
	val += Judgment && !Oozaru ? (glob.min_damage_roll/2)*AscensionsAcquired : 0
	return clamp(val, glob.min_damage_roll, glob.max_damage_roll);