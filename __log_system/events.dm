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

proc/Log(var/e,var/Info,var/NoPinkText=0, adminLevel = 1)
	if(e=="Admin")
		e="Saves/AdminLogs/[TimeStamp(1)]"
		if(usr)
			if(!(usr.Admin<=4)&&usr.Admin!=null)e="Saves/AdminLogz/Admin Log [TimeStamp(1)]"
			if(usr.Admin<=4)
				if(!NoPinkText)
					AdminMessage(Info, adminLevel)
		else
			if(!NoPinkText)
				AdminMessage(Info, adminLevel)
	if(e=="AdminPM")
		e="Saves/AdminLogs/[TimeStamp(1)]"
	Info=html_encode(Info)
	var/Event/E = new/Event/writeToLog( T = "<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]",
                                        D = "[e]") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
	LOGscheduler.schedule( E, 5 ) // every log to file has a .5 second delay

	//file("[e][numz]")<<"<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]"

proc/TempLog(var/e,var/Info)
	Info=html_encode(Info)
	var/numz=1
	while(length(file("[e]Temp[numz]"))>1024*200)
		numz++

	var/Event/F = new/Event/writeToLog( T = "<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]",
                                        D = "[e]Temp[numz]") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
	LOGscheduler.schedule( F, 5 ) // every log to file has a .5 second delay

proc/ArchiveLog(var/e,var/Info)
	Info=html_encode(Info)
	var/numz=1
	while(length(file("[e]Temp[numz]"))>1024*200)
		numz++

	var/Event/F = new/Event/writeToLog( T = "<br><font color=black>[time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")] [Info]",
                                        D = "[e]Archive[numz]") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
	LOGscheduler.schedule( F, 5 ) // every log to file has a .5 second delay

proc/SkillLog(var/e,var/Info)
	Info=html_encode(Info)
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
	return "Saves/PlayerLogs/[src.key]/[time2text(world.timeofday,"MM-DD-YY")]"


mob/proc/sanitizedChatLog()
	return "Saves/PlayerLogs/[src.key]/sanitized/[time2text(world.timeofday,"MM-DD-YY")]"

/mob/verb/ViewSelfLogs()
	set category = "Other"
	set desc = "View your own logs."
	usr.SegmentLogs("Saves/PlayerLogs/[usr.key]/sanitized/")


mob/proc/SegmentLogs(var/e)
	var/list/entries=flist(e)
	entries -= "sanitized/"

	if(entries.len >= 1)
		if(entries.len > 1)
			entries = sortByDate(entries)
		var/file=input("What one do you want to read?","Rebirth") in entries
		file = file("[e][file]")
		var/ISF=file2text(file)
		var/View={"<html><head><title>Logs</title></head><body>
<font size=3><font color=red>[file]<hr><font size=2><font color=black>[ISF]</body></html>"}
		src<<browse(View,"window=Log;size=500x550")

	else
		src<<"No logs found."

proc/sortByDate(list/l) // mm-dd-yy format.
	var/list/sorted = new()
	var/low_index
	var/high_index
	var/insert_index
	var/midway_calc
	var/current_index
	var/current_item
	var/list/list_bottom
	var/list/date1_split
	var/list/date2_split
	var/date1_comparable
	var/date2_comparable
	var/current_sort
	for (current_sort in l)
		low_index = 1
		high_index = sorted.len
		while (low_index <= high_index)
			midway_calc = (low_index + high_index) / 2
			current_index = round(midway_calc)
			if (midway_calc > current_index)
				current_index++
			current_item = sorted[current_index]

			date1_split = splittext(current_item, "-")
			date2_split = splittext(current_sort, "-")

			date1_comparable = date1_split[3] + date1_split[1] + date1_split[2]
			date2_comparable = date2_split[3] + date2_split[1] + date2_split[2]

			if (date1_comparable > date2_comparable) // if this is < instead, it sorts from earliest to latest.
				high_index = current_index - 1
			else if (date1_comparable < date2_comparable) // u would flip this too
				low_index = current_index + 1
			else
				low_index = current_index
				break

		insert_index = low_index

		if (insert_index > sorted.len)
			sorted += current_sort
			continue

		list_bottom = sorted.Copy(insert_index)
		sorted.Cut(insert_index)
		sorted += current_sort
		sorted += list_bottom
	return sorted

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
			var/View={"<html><head><title>Logs</title></head><body>
<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>[ISF]</body></html>"}
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
			var/View={"<html><head><title>Logs</title></head><body>
<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>[ISF]</body></html>"}
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
			var/View={"<html><head><title>Logs</title></head><body>
<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>[ISF]</body></html>"}
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
				if(glob.IGNORE_NOT_LOGGEDIN_LOGINS)
					return
				title={"<font color=red>logged out.</font color>"}

		var/matches = ""
		for(var/mob/m in players)
			if(m.key == src.key) continue
			if(address == m.client.address)
				matches += "[m.key], "
				continue
			if(computer_id == m.client.computer_id)
				matches += "[m.key], "
				continue
		matches = replacetext(matches, ", ", "", length(matches)-3, 0)
		if(length(matches)>1)
			AdminMessage("[TimeStamp()]<b> [src.key]</b> | Possible Alts: ([matches]) ([title])")
		else
			AdminMessage("[TimeStamp()]<b> [src.key]</b> ([title])")
		var/Event/E = new/Event/writeToLog( T = "<font color=black>[TimeStamp()]<b> [src.key]</b> | [src.address] | [src.computer_id] ([title])<br>",
                                            D = "Saves/LoginLogs/[TimeStamp(1)].txt") // We're explicitly setting the variables to make sure it doesn't take either of these as a reschedule time.
		LOGscheduler.schedule( E, 5 ) // every log to file has a .5 second delay

//		var/ISF=file("Saves/LoginLogs/[TimeStamp(1)].txt")
//		ISF<<"<font color=black>[TimeStamp()]<b> [src.key]</b> | [src.address] | [src.computer_id] ([title])<br>"
