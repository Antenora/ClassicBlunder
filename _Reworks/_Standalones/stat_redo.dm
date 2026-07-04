mob/var/stat_redoing = FALSE

mob/proc/stat_redo()
	stat_redoing = TRUE

	winshow(src,"Finalize_Screen",1)
	statArchive = new()
	statArchive.reset(list(1,1,1,1,1,1))
	race_selecting=0
	// Keep ascension / special classes
	if(race && length(race.classes))
		if(Class in race.classes)
			var/idx = 0
			for(var/cname in race.classes)
				idx++
				if(cname == Class)
					race.current_class = idx
					break
			Class = race.classes[race.current_class]
		else if(!Class)
			Class = race.classes[race.current_class]
	winset(src, "Finalize_Screen.className", "text=\"[Class]\"")
	winshow(src,"Finalize_Screen",1)
	if(length(race.stats_per_class) > 0)
		if(race.stats_per_class[Class])
			src.RacialStats(race.stats_per_class[Class])
		else
			src.RacialStats(race)
	else
		src.RacialStats(race)
	src.UpdateBio()
	src.dir = SOUTH
	src.screen_loc = "IconUpdate:1,1"
	client.screen += src
	var/pointPool = race.statPoints
	if(race.type)
		var/race/template = GetRaceInstanceFromType(race.type)
		if(template)
			pointPool = template.statPoints
	SetStatPoints(pointPool)
	src.UpdateBio()
	src.GetIncrements()
	race_selecting = FALSE
mob/proc/stat_retwo()
	stat_redoing = TRUE

	winshow(src,"Finalize_Screen",1)
	statArchive = new()
	statArchive.reset(list(1,1,1,1,1,1))
	race_selecting=0
	if(race && length(race.classes))
		if(Class in race.classes)
			var/idx = 0
			for(var/cname in race.classes)
				idx++
				if(cname == Class)
					race.current_class = idx
					break
			Class = race.classes[race.current_class]
		else if(!Class)
			Class = race.classes[race.current_class]
	winset(src, "Finalize_Screen.className", "text=\"[Class]\"")
	winshow(src,"Finalize_Screen",1)
	if(length(race.stats_per_class) > 0)
		if(race.stats_per_class[Class])
			src.RacialStats(race.stats_per_class[Class])
		else
			src.RacialStats(race)
	else
		src.RacialStats(race)
	src.UpdateBio()
	src.dir = SOUTH
	src.screen_loc = "IconUpdate:1,1"
	client.screen += src
	var/pool = race.statPoints
	if(race.type)
		var/race/rtp = GetRaceInstanceFromType(race.type)
		if(rtp)
			pool = rtp.statPoints
	SetStatPoints(pool)
	src.UpdateBio()
	src.GetIncrements()
	src.passive_handler = null
	race_selecting = FALSE

mob/Admin3/verb/Assign_Stat_Redo(mob/m in players)
	if(!m) return
	if(!src.Alert("Are you sure you want to assign a stat redo?")) return
	m << "You've been assigned a stat redo!"
	usr << "You've assigned [m] a stat redo!"
	m.stat_redo()