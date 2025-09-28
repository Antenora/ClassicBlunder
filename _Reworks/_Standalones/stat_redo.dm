mob/var/stat_redoing = FALSE

mob/proc/stat_redo()
	stat_redoing = TRUE

	winshow(src,"Finalize_Screen",1)
	statArchive = new()
	statArchive.reset(list(1,1,1,1,1,1))
	race_selecting=0
	Class = race.classes[race.current_class]
	winset(src, "Finalize_Screen.className", "text=\"[race.classes[race.current_class]]\"")
	winshow(src,"Finalize_Screen",1)
	if(length(race.stats_per_class) > 0)
		src.RacialStats(race.stats_per_class[race.getClass()])
	else
		src.RacialStats(race)
	src.UpdateBio()
	src.dir = SOUTH
	src.screen_loc = "IconUpdate:1,1"
	client.screen += src
	SetStatPoints(race.statPoints)
	src.UpdateBio()
	src.GetIncrements()
	race_selecting = FALSE

mob/Admin3/verb/Assign_Stat_Redo(mob/m in players)
	if(!m) return
	m << "You've been assigned a stat redo!"
	usr << "You've assigned [m] a stat redo!"
	m.stat_redo()