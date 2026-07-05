proc/randValue(min,max,divider=10)
	return rand(min*divider,max*divider)/divider

/mob/proc/GetDamageMod()
	var/val = randValue(glob.min_damage_roll, glob.max_damage_roll)
	val += Judgment && !Oozaru ? (glob.min_damage_roll/2)*AscensionsAcquired : 0
	val += getSteadyValue();
	return clamp(val, glob.min_damage_roll, glob.max_damage_roll);