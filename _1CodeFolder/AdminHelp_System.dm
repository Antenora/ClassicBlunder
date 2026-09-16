
var/AdminApplys[0]
var/AdminHelps[0]

mob/Admin1/verb/showAdminHelpList()
	set category = "Admin"
	set name = "Show Admin Helps"
	winshow(usr,"AdminHelpWindow",1)
	usr.RefreshListAhelp()


mob/verb/SkinPM2()
	set hidden = 1
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	var/mobIntendedKey = winget(usr,"Help_Character_Key","text")
	var/mob/target
	var/UserInput = Ask(usr, "What do you want to say to [mobIntendedKey]?", "", null, "text", null, 1)
	if(UserInput)
		for(var/mob/Q in players)
			if(Q.key == mobIntendedKey)
				target = Q
				Q <<"<font color=#00FF99><b>(Admin PM)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=PM2;>[src.key]</a href> :[UserInput]"
			if(Q.Admin)
				if(Q!=src&&Q!=target)
					Q<<"<font color=#00FF99><b>(Admin PM)</b></font> <a href=?src=\ref[src];action=MasterControl;do=PM2;>[src.key]</a href> to <a href=?src=\ref[mobIntendedKey];action=MasterControl;do=PM2;>[mobIntendedKey]</a href> :[UserInput]"
		if(target)
			Log("AdminPM","(Admin PM from [src.key] to [target.key]): [UserInput]")
			src<<"<font color=#00FF99><b>(Admin PM)</b></font>- To  <a href=?src=\ref[target];action=MasterControl;do=PM2;>[target.key]</a href> :[UserInput]"
			// Overwatch Listen Mode — copy Admin PM to admins regardless.
			AdminListenBroadcast(src, "(Admin PM) [src.key] to [target.key]: [html_encode(UserInput)]")



obj/Admin_Apply_Object/
	name = "Test Name"
	var/
		Character_Key = "New Key"
		Character_Name = "New Name"
		Apply_Subject = "Apply Subject"
		IC_Reason = "IC Reason Here"
		OOC_Reason = "OOC Reason Here"
		Accepts = 0
		Denies = 0
		UniqueID = "Unique ID"
	Click()
		usr.submitPApply(src)

mob/verb/AdminHelpAction()
		set hidden = 1
		if(!(world.time > verb_delay)) return
		verb_delay=world.time+1
		var/mobIntendedKey = winget(usr,"Help_Character_Key","text")
		var/mob/target
		for(var/mob/Q in players)
				if(Q.key == mobIntendedKey)
						target = Q
		if(!target)
				return
		usr.client?.ShowPlayerControls(target)

obj/Admin_Help_Object/
	name = "Test Name"
	var/
		Character_Key = "New Key"
		Character_Name = "New Name"
		AdminHelp_Message = "IC Reason Here"
		UniqueID = "Unique ID"
	Click()
		usr.submitAhelp(src)


mob/verb/AdminHelp()
	set name = "Admin Help"
	set category="Other"
	set hidden = 1
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	var/txt = (args.len && !isnull(args[1])) ? args[1] : Ask(usr, "Describe what you need help with.", "Admin Help", null, "message", null, 1)
	if(!txt || length(txt) <= 0) return
	//var/obj/Admin_Help_Object/A_Apply = new()
	var/obj/Admin_Help_Object/AHelp = new()
	AHelp.name = "[usr.key]     "
	AHelp.Character_Key = usr.key
	AHelp.Character_Name = usr.name
	AHelp.UniqueID = "ID[rand(0, 999999)]"
	usr<<"Message sent!"
	txt=html_encode(txt)
	txt=copytext(txt,1,10000)
	AHelp.AdminHelp_Message = txt
	AdminHelps.Add(AHelp)
	for(var/mob/Players/M in admins)
		if(M.Admin)
			M <<"<font color=red>(PLAYER HELP)</font color> <a href=?src=\ref[usr];action=MasterControl;do=PM;ID=[AHelp.UniqueID]>[usr.key]</a href>[M.Controlz(usr)] : [txt]"
			M.RefreshListAhelp()
			if(M.client.getPref("AdminAlerts"))
				winset(M, "mainwindow", "flash=-1")
	Log("AdminPM","(Admin Help from [usr.key]): [txt]")
	// Overwatch Listen Mode — copy PHELP broadcasts to admins with listen on.
	AdminListenBroadcast(usr, "(PLAYER HELP) [usr.key]: [txt]")
	usr<<"Your message:\n\n[txt]\n\nhas been sent to the admin!"
	if(glob.discordAdminHelpWebhookURL)
		world.Export("[glob.discordAdminHelpWebhookURL]", list("content" = "**[usr.key]'s AHelp:** ```"+txt+"```"), 0, null, "POST")


mob/verb/DeleteAdminHelp()
	set hidden=1
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	if(!Admin) return
	var/inID = winget(usr,"Help_Unique_ID","text")
	for(var/obj/Admin_Help_Object/O in AdminHelps)
		if(O.UniqueID == "[inID]")
			AdminHelps.Remove(O)
	usr.RefreshListAhelp()
	src << output(null, "Help_Character_Key")
	src << output(null, "Help_Character_Name")
	src << output(null, "Help_Message")
	src << output(null, "Help_Unique_ID")


mob/
	proc/
		submitAhelp(var/obj/Admin_Help_Object/O)
			src << output(null, "Help_Message")
			src << output(O.Character_Key, "Help_Character_Key")
			src << output(O.Character_Name, "Help_Character_Name")
			src << output(O.AdminHelp_Message, "Help_Message")
			src << output(O.UniqueID, "Help_Unique_ID")

mob/
	proc/
		submitPApply(var/obj/Admin_Apply_Object/O)
			src << output(null, "IC_Reason")
			src << output(null, "OOC_Reacon")
			src << output(O.IC_Reason, "IC_Reason")
			src << output(O.OOC_Reason, "OOC_Reacon")
			src << output(O.Character_Name, "Character_Name")
			src << output(O.Character_Key, "Character_Key")
			src << output(O.Apply_Subject, "Apply_Subject")
			src << output(O.Accepts, "Accepts")
			src << output(O.Denies, "Denies")
			src << output(O.UniqueID, "ID")

client/verb/submitApplication()
	set hidden=1
	if(!(world.time > mob.verb_delay)) return
	mob.verb_delay=world.time+1
	var/obj/Admin_Apply_Object/A_Apply = new()
	A_Apply.OOC_Reason = winget(usr,"OOC_Reason_Input","text")
	A_Apply.IC_Reason = winget(usr,"IC_Reason_Input","text")
	A_Apply.Apply_Subject = winget(usr,"Apply_Select_Input","text")
	AdminApplys.Add(A_Apply)


mob/verb/RefreshList()
	set hidden=1
	var/items = 0
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	for(var/obj/Admin_Apply_Object/O in AdminApplys)
		winset(src, "OutPutMessages", "current-cell=[++items]")
		usr << output(O, "OutPutMessages")
	winset(src, "OutPutMessages", "cells=[items]")

mob/verb/RefreshListAhelp()
	set hidden=1
	var/items = 0
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
	winset(usr,"Help_OutPutMessages","cells=0x0")
	for(var/obj/Admin_Help_Object/O in AdminHelps)
		winset(src, "Help_OutPutMessages", "current-cell=[++items]")
		usr << output(O, "Help_OutPutMessages")
	winset(src, "Help_OutPutMessages", "cells=[items]")

client/proc/ShowPlayerControls(mob/T)
	if(!T || !mob)
		return
	var/list/acts = list("Promote/Demote Admin" = "Adminize", "CurseSpeak" = "Cursespeak", "Mute" = "Mute", "Admin PM" = "PM", "Observe" = "Observe", "Send to Spawn" = "SendToSpawn", "Assess" = "Assess", "Give" = "Give", "Kill" = "Kill", "Knockout" = "KO", "Heal" = "Heal", "Revive" = "Revive", "Check Log" = "Log", "Edit" = "Edit", "Summon" = "Summon", "Teleport to" = "Teleport", "XYZ Teleport" = "XYZTeleport", "Boot" = "Boot", "Ban" = "Ban")
	var/list/rows = list()
	for(var/label in acts)
		rows[++rows.len] = list("n" = "[label]", "v" = "", "nh" = "?src=\ref[T];action=MasterControl;do=[acts[label]]")
	SheetShow("controls:\ref[T]", "PLAYER", "[T.key]", "[T.name]", rows, "an action")
