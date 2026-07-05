stat
	var
		name = "Stat"
		value = 0
		min_value = 0
		max_value = 0
		multiplier = 1

	New()
		multipliers = list()

	proc
		getRawStat()
			return value

		getStat()

	operator*=(mult)
		multiplier *= mult
	
	operator/=(mult)
		multiplier /= mult
	
	operator+=(add)
		value += add
		value = clamp(min_value, value, max_value)
	
	operator-=(subtract)
		value -= subtract
		value = clamp(min_value, value, max_value)