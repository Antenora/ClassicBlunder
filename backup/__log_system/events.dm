/* logging_system
 *
 * file:   events.dm
 * author: Valekor
 * date:   June 3rd 2014
 * description:
 * This file should contain all the procs related to logging.
 * Most importantly these files should contain the procs that are called when something is logged to file
 * _main_.dm in this same folder handles the actual logging TO a file.
 *
 * The Eventscheduler is used to log things to file, lessening the constant load on CPU.
 * All scheduled events fire only once. In order to have the trigger repeatedly, they would have to have a time added at the end.
*/

proc/Log(var/e,var/Info, adminLevel = 1)
	if(e=="Admin")
		e="Saves/AdminLogs/Log"
		if(usr)
			if(!(usr.Admin<=4)&&usr.Admin!=null)e="Saves/AdminLogz/Log"
			if(usr.Admin<=4)AdminMessage(Info, adminLevel)
		else
			AdminMessage(Info, adminLevel)
	if(e=="FunnyAdmin")
		e="Saves/AdminLogs/Log"
		if(usr)
			if(!(usr.Admin<=4)&&usr.Admin!=null)e="Saves/AdminLogz/Log"
			if(usr.Admin<=4)FunnyAdminMessage(Info)
		else
			FunnyAdminMessage(Info)
	if(e=="AdminPM")
		e="Saves/AdminLogs/Log"
	var/numz=1
	while(length(file("[e][numz]"))>1024*200)
		numz++

	var/Event/E = new/Event/writeToLog( T = "<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]",
                                        D = "[e][numz]") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
	LOGscheduler.schedule( E, 5 ) // every log to file has a .5 second delay

	//file("[e][numz]")<<"<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]"
proc/TempLog(var/e,var/Info)
	var/numz=1
	while(length(file("[e]Temp[numz]"))>1024*200)
		numz++

	var/Event/F = new/Event/writeToLog( T = "<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]",
                                        D = "[e]Temp[numz]") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
	LOGscheduler.schedule( F, 5 ) // every log to file has a .5 second delay

proc/ArchiveLog(var/e,var/Info)
	var/numz=1
	while(length(file("[e]Temp[numz]"))>1024*200)
		numz++

	var/Event/F = new/Event/writeToLog( T = "<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]",
                                        D = "[e]Archive[numz]") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
	LOGscheduler.schedule( F, 5 ) // every log to file has a .5 second delay

proc/SkillLog(var/e,var/Info)
	var/numz=1
	while(length(file("[e]Skill[numz]"))>1024*200)
		numz++

	var/Event/G = new/Event/writeToLog( T = "<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]",
                                        D = "[e]Skill[numz]") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
	LOGscheduler.schedule( G, 5 ) // every log to file has a .5 second delay

mob/proc/ChatLog()
/*
 * ChatLog simply returns the location for player logs and the players respective key as a folder
*/
	return "Saves/PlayerLogs/[src.key]/Log"

mob/proc/SegmentLogs(var/e)
	var/wtf=0
	var/list/Blah=new
	LOLWTF
	wtf+=1
	var/XXX=file("[e][wtf]")
	if(fexists(XXX))
		Blah.Add(XXX)
		goto LOLWTF
	else

		if(Blah&&wtf>1)
			var/lawl=input("What one do you want to read?","Rebirth") in Blah
			var/ISF=file2text(lawl)
			var/View={"<html><head><title>Logs</title><body>
<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>[ISF]"}
			src<<browse(View,"window=Log;size=500x550")

		else
			src<<"No logs found."

mob/proc/SegmentTempLogs(var/e)
	var/wtf=0
	var/list/Blah=new
	LOLWTF
	wtf+=1
	var/XXX=file("[e]Temp[wtf]")
	if(fexists(XXX))
		Blah.Add(XXX)
		goto LOLWTF
	else

		if(Blah&&wtf>1)
			var/lawl=input("What one do you want to read?","Rebirth") in Blah
			var/ISF=file2text(lawl)
			var/View={"<html><head><title>Logs</title><body>
<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>[ISF]"}
			src<<browse(View,"window=Log;size=500x550")

		else
			src<<"No logs found."

mob/proc/SegmentArchiveLogs(var/e)
	var/wtf=0
	var/list/Blah=new
	LOLWTF
	wtf+=1
	var/XXX=file("[e]Archive[wtf]")
	if(fexists(XXX))
		Blah.Add(XXX)
		goto LOLWTF
	else

		if(Blah&&wtf>1)
			var/lawl=input("What one do you want to read?","Rebirth") in Blah
			var/ISF=file2text(lawl)
			var/View={"<html><head><title>Logs</title><body>
<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>[ISF]"}
			src<<browse(View,"window=Log;size=500x550")

		else
			src<<"No logs found."

mob/proc/SegmentSkillLogs(var/e)
	var/wtf=0
	var/list/Blah=new
	LOLWTF
	wtf+=1
	var/XXX=file("[e]Skill[wtf]")
	if(fexists(XXX))
		Blah.Add(XXX)
		goto LOLWTF
	else

		if(Blah&&wtf>1)
			var/lawl=input("What one do you want to read?","Rebirth") in Blah
			var/ISF=file2text(lawl)
			var/View={"<html><head><title>Logs</title><body>
<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>[ISF]"}
			src<<browse(View,"window=Log;size=500x550")

		else
			src<<"No logs found."

proc/TimeStamp(var/Z)
	if(Z==1)
		return time2text(world.timeofday,"MM-DD-YY")
	else
		return time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")


client/proc/LoginLog(var/title=null)
	if(src)
		if(title=="LOGOUT")
			if(src.mob)
				title={"<font color=red>logged out.</font color>([src.mob.name])"}
			else
				title={"<font color=red>logged out.</font color>"}

		AdminMessage("[TimeStamp()]<b> [src.key]</b> | [src.address] | [src.computer_id] ([title])")

		var/Event/E = new/Event/writeToLog( T = "<font color=black>[TimeStamp()]<b> [src.key]</b> | [src.address] | [src.computer_id] ([title])<br>",
                                            D = "Saves/LoginLogs/[TimeStamp(1)].txt") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
		LOGscheduler.schedule( E, 5 ) // every log to file has a .5 second delay

//		var/ISF=file("Saves/LoginLogs/[TimeStamp(1)].txt")
//		ISF<<"<font color=black>[TimeStamp()]<b> [src.key]</b> | [src.address] | [src.computer_id] ([title])<br>"
