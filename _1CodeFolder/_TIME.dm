


proc
	Milisecond(var/Times=1)
		return round(1*Times)
	Second(var/Times=1)
		return round(Milisecond(10)*Times)
	Minute(var/Times=1)
		return round(Second(60)*Times)
	Hour(var/Times=1)
		return round(Minute(60)*Times)
	Day(var/Times=1)
		return round(Hour(24)*Times)

	RawSeconds(var/Times=1)
		return round(1*Times)
	RawMinutes(var/Times=1)
		return RawSeconds(60*Times)
	RawHours(var/Times=1)
		return RawMinutes(60*Times)
	RawDays(var/Times=1)
		return RawHours(24*Times)