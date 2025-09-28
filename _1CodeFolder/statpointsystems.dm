/mob/var/datum/statHolder/statArchive = new()
mob/proc/RacialStats(statsinquestion)
	if(statsinquestion)
		statArchive.reset(statsinquestion)
	else
		statArchive.reset(race)
	displayStats()
mob/proc/displayStats()
	for(var/x in list("Strength","Endurance","Force","Offense","Defense","Speed"))
		winset(src, "Finalize_Screen.[x]", "text=[statArchive.calc_stat(statArchive.vars[x])]")

/mob/proc/setAllStats()
	for(var/x in list("Strength","Endurance","Force","Offense","Defense","Speed"))
		var/org = x
		if(x == "Speed")
			x = "Spd"
		vars["[copytext(x,1,4)]Mod"] = statArchive.calc_stat(statArchive.vars[org])

mob/verb/Skill_Points(type as text,skill as text)
	set name=".Skill_Points"
	set hidden=1
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	if(race_selecting) return
	var/Increase=1
	if(type == "-")
		if(Points==Max_Points) return
		Increase = -1
	else
		if(type == "+")
			Increase = 1
			if(Points==0) return
	if(!(skill in list("Strength","Endurance","Force","Offense","Defense","Speed")))return
	if(!statArchive.adjust(type, skill))
		src << "You can't."
	else
		winset(src,"Finalize_Screen.[skill]","text=[statArchive.calc_stat(statArchive.vars[skill])]")
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
		RedoStats(usr)


proc/Define_Average(var/i=1)
	if(i<1)
		return "Low"
	else if(i>=1&&i<1.5)
		return "Average"
	else if(i>=1.5&&i<2)
		return "High"
	else if(i>=2&&i<2.5)
		return "Genius"
	else if(i>=2.5)
		return "Absurd"

mob/proc/Redo_Stats()
	set category="Other"
	Redoing_Stats=1
	RacialStats()
	UpdateBio()
	var/mob/Creation/C = new
	C.NextStep2(src)
	del C

mob/proc/PerkDisplay()
	winset(src,"Finalize_Screen.Points Remaining","text=[Points]")
	winset(src,"RaceBP","text=\"[Define_Average(PotentialRate)] Power Rate\"")
	winset(src,"Race RPP","text=\"[Define_Average(RPPMult)] RPP Mult\"")
	winset(src,"Race Intellect", "text=\"[Define_Average(Intelligence)] Intellect\"")
	winset(src,"Race Imagination", "text=\"[Define_Average(Intelligence*Imagination)] Enchanting\"")
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
	if(!usr.Savable)
		usr.NewMob()