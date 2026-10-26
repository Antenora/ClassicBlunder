/mob/proc/HollowCountKey()
	return "[round(world.realtime / 864000)]"

/mob/proc/HollowCanCount(mob/other)
	if(!HollowIsHollow() || !src.HollowDeathRegen)
		return 0
	if(src.HollowIsNewborn())
		return 0
	if(!other || other == src || !other.client)
		return 0
	if(!istype(other, /mob/Players))
		return 0
	if(src.HollowLastCountedAt && world.realtime < src.HollowLastCountedAt + HOLLOW_COUNT_GAP_SECONDS * 10)
		return 0
	if(!islist(src.HollowKillerLog))
		src.HollowKillerLog = list()
	var/stamp = "[other.key]@[src.HollowCountKey()]"
	if(stamp in src.HollowKillerLog)
		return 0
	return stamp

/mob/proc/HollowAwardPoint(stamp)
	src.HollowLastCountedAt = world.realtime
	src.HollowKillerLog += stamp
	if(src.HollowPoints < HOLLOW_POINT_CAP)
		src.HollowPoints++

/mob/proc/HollowCountDeath(mob/killer)
	var/stamp = src.HollowCanCount(killer)
	if(!stamp)
		return 0
	src.HollowCountedDeaths++
	src.HollowAwardPoint(stamp)
	return 1

/mob/proc/HollowCountDevour(mob/victim)
	var/stamp = src.HollowCanCount(victim)
	if(!stamp)
		return 0
	src.HollowCountedDevours++
	src.HollowAwardPoint(stamp)
	return 1

/mob/HollowOnDevour(mob/victim)
	..()
	src.HollowCountDevour(victim)

/mob/proc/HollowVastoRollCheck()
	if(!HollowIsHollow() || src.HollowVastoRolled)
		return 0
	if(src.AscensionsAcquired < 3)
		return 0
	if(src.HollowStage != HOLLOW_STAGE_ADJUCHAS || src.HollowArrancar)
		return 0
	src.HollowVastoRolled = 1
	if(glob.VastoLordeCount >= glob.VastoLordeLimit)
		Log("Admin", "[ExtractInfo(src)] reached the Vasto Lorde roll with [src.HollowPoints] point(s), but the server is at its natural Vasto Lorde limit ([glob.VastoLordeCount]/[glob.VastoLordeLimit]).", 1)
		return 0
	var/chance = HOLLOW_VASTO_BASE_CHANCE + src.HollowPoints
	if(!prob(chance))
		Log("Admin", "[ExtractInfo(src)] rolled for Vasto Lorde at [chance] percent and failed.", 1)
		return 0
	glob.VastoLordeCount++
	src.HollowSetStage(HOLLOW_STAGE_VASTO)
	Log("Admin", "[ExtractInfo(src)] rolled for Vasto Lorde at [chance] percent and SUCCEEDED ([glob.VastoLordeCount]/[glob.VastoLordeLimit] natural).", 1)
	return 1
