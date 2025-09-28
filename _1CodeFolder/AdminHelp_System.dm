
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
	var/UserInput = input("What do you want to say to [mobIntendedKey]?") as text|null
	if(UserInput)
		for(var/mob/Q in players)
			if(Q.key == mobIntendedKey)
				target = Q
				Q <<"<font color=#00FF99><b>(Admin PM)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=PM2;>[src.key]</a href> :[UserInput]"
			if(Q.Admin)
				if(Q!=src&&Q!=target)
					Q<<"<font color=#00FF99><b>(Admin PM)</b></font> <a href=?src=\ref[src];action=MasterControl;do=PM2;>[src.key]</a href> to <a href=?src=\ref[mobIntendedKey];action=MasterControl;do=PM2;>[mobIntendedKey]</a href> :[UserInput]"
		Log("AdminPM","(Admin PM from [src.key] to [target.key]): [UserInput]")
		src<<"<font color=#00FF99><b>(Admin PM)</b></font>- To  <a href=?src=\ref[target];action=MasterControl;do=PM2;>[target.key]</a href> :[UserInput]"



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
		var/View={"<html><head><title>Player Control [target.key]</title><body>
					<font size=3><font color=red>[target.name]<hr><font size=2><font color=black>"}
		View+={"

			\[ <a href=?src=\ref[target];action=MasterControl;do=Adminize>Promote/Demote Admin</a href> | <a href=?src=\ref[target];action=MasterControl;do=Cursespeak>CurseSpeak</a href> |<a href=?src=\ref[target];action=MasterControl;do=Mute>Mute</a href> | <a href=?src=\ref[target];action=MasterControl;do=PM>Admin PM</a href> | <a href=?src=\ref[target];action=MasterControl;do=Observe>Observe</a href> | <a href=?src=\ref[target];action=MasterControl;do=SendToSpawn>Send to Spawn</a href> | <a href=?src=\ref[target];action=MasterControl;do=Assess>Assess | <a href=?src=\ref[target];action=MasterControl;do=Give>Give</a href> | <a href=?src=\ref[target];action=MasterControl;do=Kill>Kill</a href> | <a href=?src=\ref[target];action=MasterControl;do=KO>Knockout</a href> | <a href=?src=\ref[target];action=MasterControl;do=Heal>Heal<a href> | <a href=?src=\ref[target];action=MasterControl;do=Revive>Revive</a href> | <a href=?src=\ref[target];action=MasterControl;do=Log>Check Log</a href>  | <a href=?src=\ref[target];action=MasterControl;do=TempLog>Check Temp Log</a href> | <a href=?src=\ref[target];action=MasterControl;do=SkillLog>Check Skill log</a href> | <a href=?src=\ref[target];action=MasterControl;do=Reward>Reward</a href>  | <a href=?src=\ref[target];action=MasterControl;do=Edit>Edit</a href> | <a href=?src=\ref[target];action=MasterControl;do=Summon>Summon</a href> | <a href=?src=\ref[target];action=MasterControl;do=Teleport>Teleport to</a href>  | <a href=?src=\ref[target];action=MasterControl;do=XYZTeleport>XYZ Teleport</a href> | <a href=?src=\ref[target];action=MasterControl;do=Boot>Boot</a href> | <a href=?src=\ref[target];action=MasterControl;do=Ban>Ban</a href> \]
					</html>"}
		usr<<browse(View,"window=Person;size=500x135")

obj/Admin_Help_Object/
	name = "Test Name"
	var/
		Character_Key = "New Key"
		Character_Name = "New Name"
		AdminHelp_Message = "IC Reason Here"
		UniqueID = "Unique ID"
	Click()
		usr.submitAhelp(src)


mob/verb/AdminHelp(var/txt as message)
	set name = "Admin Help"
	set category="Other"
	if(!(world.time > verb_delay)) return
	verb_delay=world.time+1
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
	if(glob.discordAdminHelpWebhookURL)
		usr.client.HttpPost(
			"[glob.discordAdminHelpWebhookURL]",
			list(
				content = "	**[usr.key]'s AHelp:** ```"+txt+"```",
				username = "AdminHelp"
			)
		)
	for(var/mob/Players/M in admins)
		if(M.Admin)
			M <<"<font color=red>(PLAYER HELP)</font color> <a href=?src=\ref[usr];action=MasterControl;do=PM;ID=[AHelp.UniqueID]>[usr.key]</a href>[M.Controlz(usr)] : [txt]"
			M.RefreshListAhelp()
			if(M.client.getPref("AdminAlerts"))
				if(M.PingSound)
					M << sound('Sounds/Ping.ogg')
				winset(M, "mainwindow", "flash=-1")
	Log("AdminPM","(Admin Help from [usr.key]): [txt]")
	usr<<"Your message:\n\n[txt]\n\nhas been sent to the admin!"


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
		++items
		usr << output(O, "Help_OutPutMessages")
	winset(src, "Help_OutPutMessages", "cells=[items]")



