/mob/var/datum/statHolder/statArchive = new()
mob/proc/RacialStats(statsinquestion)
	if(statsinquestion)
		statArchive.reset(statsinquestion)
	else
		statArchive.reset(race)
	displayStats()
mob/proc/displayStats()
	var/StatDisplay=1//statArchive.calc_stat(statArchive.vars[x])
	var/InvestedPoints=1//statArchive.calc_invested(statArchive.vars[x])
	for(var/x in list("Strength","Endurance","Force","Offense","Defense","Speed","Vitality"))
		winset(src, "Finalize_Screen.[x]", "text=[statArchive.calc_stat(statArchive.vars[x])]")
		StatDisplay=src.statArchive.calc_stat(statArchive.vars[x])
		InvestedPoints=(src.statArchive.calc_invested(statArchive.vars[x])*glob.progress.STAT_PER_POINT)
		var/TotalDisplay=StatDisplay+InvestedPoints
		winset(src, "Finalize_Screen.[x]", "text=[TotalDisplay]")


/mob/proc/setAllStats()
	for(var/x in list("Strength","Endurance","Force","Offense","Defense","Speed","Vitality"))
		var/org = x
		if(x == "Speed")
			x = "Spd"
		vars["[copytext(x,1,4)]Mod"] = statArchive.calc_stat(statArchive.vars[org])
		vars["[org]Invest"] = statArchive.calc_invested(statArchive.vars[org])

mob/verb/Skill_Points(type as text,skill as text)
	set name=".Skill_Points"
	set hidden=1
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	if(race_selecting) return
	var/Increase=1
	var/StatDisplay=src.statArchive.calc_stat(statArchive.vars[skill])
	var/InvestedPoints=(src.statArchive.calc_invested(statArchive.vars[skill])*glob.progress.STAT_PER_POINT)
	var/TotalDisplay=StatDisplay+InvestedPoints
	if(type == "-")
		if(Points==Max_Points) return
		Increase = -1
	else
		if(type == "+")
			Increase = 1
			if(Points==0) return
	if(!(skill in list("Strength","Endurance","Force","Offense","Defense","Speed","Vitality")))return
	if(!statArchive.adjust(type, skill))
		src << "You can't."
	else
		StatDisplay=src.statArchive.calc_stat(statArchive.vars[skill])
		InvestedPoints=(src.statArchive.calc_invested(statArchive.vars[skill])*glob.progress.STAT_PER_POINT)
		TotalDisplay=StatDisplay+InvestedPoints
		winset(src,"Finalize_Screen.[skill]","text=[TotalDisplay]")
		Points-=Increase
		winset(src,"Finalize_Screen.Points Remaining","text=[Points]")
	setAllStats()
	return

obj/Redo_Stats
	var/LoginUse
	proc/RedoStats(mob/m)
		m.Redo_Stats()
		del src
	verb/Redo_Stats()
		set category="Other"
		set hidden = 1
		RedoStats(usr)


proc/Define_Average(var/i=1)
	return i
/*	if(i<1)
		return "Low"
	else if(i>=1&&i<1.5)
		return "Average"
	else if(i>=1.5&&i<2)
		return "High"
	else if(i>=2&&i<2.5)
		return "Genius"
	else if(i>=2.5)
		return "Absurd"*/

mob/proc/Redo_Stats()
	set category="Other"
	set hidden = 1
	Redoing_Stats=1
	RacialStats()
	UpdateBio()
	// Grant a fresh stat-point pool sourced from the race template. Without
	// this, /obj/Redo_Stats reopens the Finalize screen with whatever Points
	// the player happens to have (usually 0 mid-game), and admins had to edit
	// Points=10 by hand. The newer mob/stat_redo path already does this; mirror
	// it here so the legacy redo object behaves the same.
	var/pointPool = race ? race.statPoints : 10
	if(race && race.type)
		var/race/template = GetRaceInstanceFromType(race.type)
		if(template)
			pointPool = template.statPoints
	SetStatPoints(pointPool)
	var/mob/Creation/C = new
	C.NextStep2(src)
	del C

mob/proc/PerkDisplay()
	winset(src,"Finalize_Screen.Points Remaining","text=[Points]")
	winset(src,"RaceBP","text=\"[Define_Average(PotentialRate)]x Power Rate\"")
	winset(src,"Race RPP","text=\"[Define_Average(RPPMult)]x RPP Mult\"")
	winset(src,"Race Intellect", "text=\"[Define_Average(Intelligence)]x Intellect\"")
	winset(src,"RaceGrowthRate", "text=\"[Define_Average(GrowthRate)]x Growth Rate\"")
	displayStats()
	winset(src,"Anger","text=[AngerMax*100]%")

mob/proc/SetStatPoints(Amount=0)
	src.Points=Amount
	src.Max_Points=Amount


mob/proc/GetIncrements()



mob/var/tmp/Redoing_Stats
mob/var/tmp/Points=0
mob/var/tmp/Max_Points=10
mob/proc/SetStat(Stat,Amount=1)
	if(Stat=="Power")
		PotentialRate=Amount
	if(Stat=="Speed")
		SpdMod=Amount
	if(Stat=="Strength")
		StrMod=Amount
	if(Stat=="Endurance")
		EndMod=Amount
	if(Stat=="Vitality")
		VitMod=Amount
	if(Stat=="Force")
		ForMod=Amount
	if(Stat=="Offense")
		OffMod=Amount
	if(Stat=="Defense")
		DefMod=Amount
	if(Stat=="Recovery")
		RecovMod=Amount
	if(Stat=="Anger")
		AngerMax=Amount
	if(Stat=="Learning")
		RPPMult=Amount
	if(Stat=="Intellect")
		Intelligence=Amount
	if(Stat=="Imagination")
		Imagination=Amount
	if(Stat=="Growth")
		GrowthRate=Amount

mob/verb/Skill_Points_Done()
	set name=".Skill_Points_Done"
	set hidden=1
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	if(race_selecting) return
	if(Points)
		src<<"You still have points!"
		return

	if(assigningStats)
		assigningStats=0
	if(stat_redoing)
		stat_redoing = FALSE
		race_selecting = TRUE
	winshow(src,"Finalize_Screen",0)
	Health=MaxHP()
	if(!usr.Savable)
		usr.NewMob()