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
		if(usr)
			if(usr.Admin<=4)
				if(!NoPinkText)
					AdminMessage(Info, adminLevel)
		else
			if(!NoPinkText)
				AdminMessage(Info, adminLevel)
		LogAdminProse(usr, Info, null)
		return
	if(e=="FunnyAdmin")
		if(usr)
			if(usr.Admin<=4)FunnyAdminMessage(Info)
		else
			FunnyAdminMessage(Info)
		LogAdminProse(usr, Info, "world")
		return
	if(e=="AdminPM")
		LogAdminProse(usr, Info, "ahelp")
		return
	LogLegacy(e, Info)

proc/FunnyAdminMessage(var/msg)
	for(var/mob/Players/M in world)
		M<<"<b><font color=red>(???)</b><font color=fuchsia> [msg]"

proc/TempLog(var/e,var/Info)
	LogLegacy(e, Info)

mob/proc/ChatLog()
/*
 * ChatLog simply returns the location for player logs and the players respective key as a folder
*/
	return "Saves/PlayerLogs/[src.key]/[time2text(world.timeofday,"MM-DD-YY")]"


mob/proc/sanitizedChatLog()
	return "Saves/PlayerLogs/[src.key]/sanitized/[time2text(world.timeofday,"MM-DD-YY")]"

proc/TimeStamp(var/Z)
	if(Z==1)
		return time2text(world.timeofday,"MM-DD-YY")
	else
		return time2text(world.timeofday,"MM/DD/YY(hh:mm:ss)")


client/proc/LoginLog(var/title=null)
	if(src)
		var/ev = "in"
		if(title=="LOGOUT")
			if(src.mob)
				title={"<font color=red>logged out.</font color>([src.mob.name])"}
				ev = "out"
			else
				return

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
		LogLoginEvent(src, ev, length(matches) > 1 ? "possible alts: [matches]" : "")
