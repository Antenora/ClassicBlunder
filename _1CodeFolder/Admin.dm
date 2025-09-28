var/list
	CodedAdmins=list("Sunshine Jesse"=4, "Nightmare Zarkus"=4, "Niezan2" = 4, "IroquoisRedgrave" = 4, "Dream Whisperer" = 4, "Awwlie" = 4)
	Admins=new
	Mappers=new
	Punishments=new

var/obj/viewmobcontents/viewmobcontents = new

obj/viewmobcontents
	name = "Admin View Contents"
	Click()
		..()
		usr.AdminContentsView = !usr.AdminContentsView
		if(usr.AdminContentsView) usr << "You will now view the contents of any mob you have selected."
		else usr << "You will no longer view the contents of any mob you have selected."


mob/var
	tmp/Admin=0
	tmp/AdminContentsView=0

mob
	var
		MakeUngrabbable=TRUE

mob/verb
	GetPingSound()
		set category = "Other"
		set name = "Toggle Ping Sound"
		if(usr.PingSound)
			usr.PingSound = 0
			usr << "Ping Sound Disabled."
		else
			usr.PingSound = 1
			usr << "Ping Sound Enabled."
	SetPingVolume()
		set category = "Other"
		set name = "Set Ping Volume"
		var/n = input(src, "What volume?") as num
		if(n > 100 || n < 0)
			src << " too high or low "
		else
			PingVolume = n

/mob/Admin3/verb/CreateSwapMap()
	set hidden = 1
	var/whichMap = input(usr, "What would you like to call it?") as null|text
	if(!whichMap) return
	if(fexists("Maps/map_[whichMap].sav"))
		var/overwrite = alert(usr, "A map already exists with the name [whichMap]! Do you want to override it?",, "Yes", "No")
		if(overwrite=="Yes") return
	var/firstX = input(usr, "X1?") as null|num
	var/firstY = input(usr, "Y1?") as null|num
	var/secondX = input(usr, "X2?") as null|num
	var/secondY = input(usr, "Y2?") as null|num
	var/Z = input(usr, "Z?") as null|num
	SwapMaps_SaveChunk(whichMap, locate(firstX,firstY,Z), locate(secondX, secondY,Z))
	SwapMaps_Save(whichMap)
	usr << "Saved!"

mob/Admin3/verb/LoadSwapMap()
	set hidden = 1
	var/whichMap = input(usr, "What would you like to call it?") as null|text
	if(!whichMap) return
	if(!fexists("Maps/map_[whichMap].sav"))
		usr << "[whichMap] doesn't exist."
		return
	var/swapmap/newMap = SwapMaps_CreateFromTemplate(whichMap)
	var/turf/center = newMap.CenterTile()
	var/goToCenter = alert(usr, "Would you like to teleport to the center of the loaded map?",,"Yes","No")
	if(goToCenter=="Yes")
		usr.PrevX = usr.x
		usr.PrevY = usr.y
		usr.PrevZ = usr.z
		usr.loc = center
	else
		usr << "The swapmap was created and centered at [center.x], [center.y], [center.z]."
	usr << "The UID for the new map is [newMap.UID]. Please remember this if you want to close it."

/mob/Admin3/verb/ForceCloseSwapMap()
	set hidden = 1
	var/whichMap = input(usr, "Input a map UID.") as null|num
	if(!whichMap) return
	for(var/swapmap/map in swapmaps_loaded)
		if(map.UID == whichMap)
			for(var/mob/m in block(map.x1, map.y1, map.z1, map.x2, map.y2))
				m.x = m.PrevX
				m.y = m.PrevY
				m.z = m.PrevZ
				m.PrevX = null
				m.PrevY = null
				m.PrevZ = null
				map.Del()
			break

/mob/Admin3/verb/ForceSaveSwapMap()
	set hidden = 1
	var/whichMap = input(usr, "Which map?") as null|text
	if(!whichMap) return
	SwapMaps_Save(whichMap)


/mob/Admin3/verb/Reboot()
	if(Alert("You sure you want to shutdown the server?"))
		var/skip = input(src, "Do you want to skip saving?") in list("Yes", "No")
		if(skip == "No")
			sleep(1)
			for(var/mob/Players/Q in players)
				if(Q.Savable)
					Q.client.SaveChar()
			BootWorld("Save")
			Log("Admin","<font color=blue>[ExtractInfo(usr)] is shutting down the server in 40 seconds.")
			world<<"<font size=2><font color=#FFFF00>Shutting down in 60 seconds. Please stop all actions at this time."
			sleep(800)
		world<<"we get past it all"
		world<<"SNARE IS CURRENTLY 0"
		sleep(10)
		world.Reboot()

/*
/mob/Admin3/verb/Stop_All_AI()
	for(var/obj/AI_Spot/a in world)
		a.ai_limit = 0
	for(var/mob/Player/AI/ai in ticking_ai)
		ai.EndLife(0)*/

/mob/Admin2/verb/PrivateNarrate(mob/m in players)
	set category="Admin"
	var/message = input(usr,"What do you want to whisper to them?","Cursespeak") as message | null
	if(message)
		message = "<i><font color='#F82D2D'>[message]</font></i>"
		Log("Admin","[ExtractInfo(usr)] cursespeaked [m] the following: [message]", 0, 3)
		usr << "You sent: [message]"
		m << "[message]"
		m << output("[message]", "icchat")
		spawn()Log(m.ChatLog(),"<font color=#CC3300>*Cursespeak: [html_decode(message)]*")
		spawn()TempLog(m.ChatLog(),"<font color=#CC3300>*Cursespeak: [html_decode(message)]*")

mob/Admin2/verb
	EditAllSpawners()
		for(var/obj/AI_Spot/ai in world)
			Edit(ai)

	Wound_Lightly(var/mob/m in players)
		set category="Admin"
		var/Time=RawHours(2)
		Time/=m.GetRecov()
		m.BPPoisonTimer=Time
		m.BPPoison=0.9
		Log("Admin","[ExtractInfo(usr)] gave [ExtractInfo(m)] light wounds.")
		m << "You've been lightly wounded!"
	Wound_Heavily(var/mob/m in players)
		set category="Admin"
		var/Time=RawHours(4)
		Time/=m.GetRecov()
		m.BPPoisonTimer=Time
		m.BPPoison=0.7
		Log("Admin","[ExtractInfo(usr)] gave [ExtractInfo(m)] heavy wounds.")
		m << "You've been heavily wounded!"
	Wound_Maim(var/mob/m in players)
		set category="Admin"
		var/Time=RawHours(6)
		Time/=m.GetRecov()
		m.Maimed+=1
		if(m.Maimed>4)
			m.Maimed=4
		m.BPPoisonTimer=Time
		m.BPPoison=0.5
		Log("Admin","[ExtractInfo(usr)] gave [ExtractInfo(m)] a maim wound.")
		m << "You have been maimed!"
	Wound_Remove(var/mob/m in players)
		set category="Admin"
		m.BPPoison=1
		m.BPPoisonTimer=0
		Log("Admin","[ExtractInfo(usr)] removed [ExtractInfo(m)]'s wounds.")
		m << "Your wounds have been reduced."
	Wound_Remove_Maim(var/mob/m in players)
		set category="Admin"
		m.Maimed-=1
		if(m.Maimed<0)
			m.Maimed=0
		Log("Admin","[ExtractInfo(usr)] repaired [ExtractInfo(m)]'s maim wound.")
		m << "Your maim wound has been repaired!"

	EditPassiveHandler(mob/m in world)
		set category = "Admin"
		usr:Edit(m.passive_handler)

	ViewPassives(mob/m in world)
		set category = "Admin"
		var/html = "<body bgcolor=#000000 text=#339999><b>Current Passives:</b><br>"
		for(var/passive in m.passive_handler.passives)
			if(m.passive_handler.passives[passive])
				html += "<b>[passive] : [m.passive_handler.passives[passive]]</b><br>"
		usr<<browse(html,"window=[m]'s Passives;size=450x600")

mob/Admin3/verb
	RuntimesView()
		var/View={"<html><head><title>Logs</title><body>
<font size=3><font color=red>Runtime Errors<hr><font size=2><font color=black>"}
		var/ISF=file2text("debug_log.txt")
		View+=ISF
		usr<<browse(View,"window=Log;size=500x350")
	RuntimesDelete()
		world.log=file("RuntimesTEMP.log")
		fdel("debug_log.txt")
		world.log=file("debug_log.txt")
		fdel("RuntimesTEMP.log")

	PrayerMute()
		set category = "Admin"
		switch(usr.PrayerMute)
			if(TRUE)
				usr.PrayerMute = FALSE
				usr << "You will now hear prayers."
			if(FALSE)
				usr.PrayerMute = TRUE
				usr << "You no longer hear prayers."
	WipeWorldAI()
		set category="Admin"
		var/list/active_ais = list()
		for(var/mob/Player/AI/a in world)
			if(!istype(a, /mob/Player/AI/Nympharum)) active_ais += a

		switch(input("There are currently [active_ais.len] active ai in the world. Would you like to delete them all?") in list("Yes","No"))
			if("Yes")
				var/len=active_ais.len
				for(var/mob/Player/AI/a in active_ais)
					a.EndLife(0)
				usr << "You've wiped [len] AIs from the world."
				ai_loop.updaters = list()
				for(var/mob/Player/AI/a in world) ai_loop.Add(a)

		//Run simple cleaning no matter what to remove null entries.
		ai_loop.updaters = list()
		for(var/mob/Player/AI/a in world)
			if(!a.loc)
				a.EndLife(0)
				continue
			else
				ai_loop.Add(a)

	ToggleContentsViewing()
		set category="Admin"
		AdminContentsView = !AdminContentsView
		if(AdminContentsView) usr << "You will now view the contents of any mob you have selected."
		else usr << "You will no longer view the contents of any mob you have selected."

	Potential_Boost(var/mob/m in players, var/val as num|null)
		set category="Admin"
		if(val&&m)
			m.Potential+=val
			m.PotentialCap+=val
			Log("Admin", "[ExtractInfo(src)] boosted [ExtractInfo(m)]'s potential by [val].")
			m << "You feel yourself grow more experienced!"

	SetDeadSpawn()
		set category="Admin"
		var/turf/NewLoc
		var/X=input(src, "New X for dead spawn?", "Set Dead Spawn X") as num|null
		var/Y=input(src, "New Y for dead spawn?", "Set Dead Spawn Y") as num|null
		var/Z=input(src, "New Z for dead spawn?", "Set Dead Spawn Z") as num|null
		if(X<0)
			X=0
		if(Y<0)
			Y=0
		if(Z<0)
			Z=0
		if(!X||!Y||!Z)
			return
		NewLoc=locate(X, Y, Z)
		if(NewLoc)
			glob.DEATH_LOCATION[1]=X
			glob.DEATH_LOCATION[2]=Y
			glob.DEATH_LOCATION[3]=Z
			Log("Admin", "[ExtractInfo(usr)] set the new dead spawn to ([glob.DEATH_LOCATION[1]], [glob.DEATH_LOCATION[2]], [glob.DEATH_LOCATION[3]])")
		else
			src << "That tile doesn't exist."

	ForceResetMultis()
		set category="Admin"
		for(var/mob/Players/m in players)
			if(m.ActiveBuff)
				if(m.CheckActive("Eight Gates"))
					m.ActiveBuff:Stop_Cultivation()
				else
					m.ActiveBuff.Trigger(m)
			if(m.SpecialBuff)
				m.SpecialBuff.Trigger(m)
			for(var/sb in m.SlotlessBuffs)
				var/obj/Skills/Buffs/b = m.SlotlessBuffs[sb]
				if(b)
					b.Trigger(m)
			m.Reset_Multipliers()

	FormMastery(mob/p in players)
		if(!length(p.race.transformations))
			usr << "[p] doesn't have any transformations!"
			return
		var/transformation/chosenTrans = input(usr, "Pick a transformation to boost the mastery of!") in p.race.transformations
		if(!chosenTrans) return
		var/chosenMastery = input(usr, "What mastery level do you want [chosenTrans] at? Currently [chosenTrans.mastery] out of 100.") as num|null
		if(isnull(chosenMastery)) return
		chosenTrans.mastery = chosenMastery

	Wound_Remove_Mass()
		set category="Admin"
		for(var/mob/m in players)
			if(m.BPPoison<1)
				m.BPPoison=1
				m.BPPoisonTimer=0
				m << "Your wounds healed over time."
			if(!m.ManaSealed)
				m.TotalCapacity=0
				m << "Your magical force recovers completely."
			m.TotalFatigue=0
			m.TotalInjury=0
			m.HealHealth(100)
			m.HealEnergy(100)
			m.StrTax=0
			m.EndTax=0
			m.SpdTax=0
			m.ForTax=0
			m.OffTax=0
			m.DefTax=0
			m.RecovTax=0
		Log("Admin","[ExtractInfo(usr)] globally removed wounds.")

	Mappers()
		set category="Admin"
		var/list/mappers=new
		mappers.Add(global.Mappers)
		for(var/x in mappers)
			for(var/mob/M in players)
				if(M.client)
					if(M.key==x)
						usr<<"[x] | Mapper<font color=green> (Online)</font color>"
						mappers.Remove(x)
		for(var/y in mappers)
			usr<<"[y] | Mapper<font color=red> (Offline)</font color>"

mob/proc/Alert(var/blah)
	switch(alert(src,blah,"Alert","Yes","No"))
		if("Yes")
			return 1

mob/proc/Admin(var/blah,var/Z,var/H)
	Z=text2num(Z)
	switch(blah)
		if("Check")
			if(src.key in CodedAdmins)
				src.Admin("Give",CodedAdmins[src.key],1)
				admins |= src
			else if(src.key in Admins)
				src.Admin("Give",Admins[src.key])
				admins |= src
			if(src.key in Mappers)
				src.Admin("GiveMapper")
		if("Give")
			src.Admin("Remove")
			src.Admin=Z
			if(Z>=1)src.verbs+=typesof(/mob/Admin1/verb)
			if(Z>=2)src.verbs+=typesof(/mob/Admin2/verb)
			if(Z>=3)src.verbs+=typesof(/mob/Admin3/verb)
			if(Z>=4)src.verbs+=typesof(/mob/Admin4/verb)
			if(Z<5&&Z>0&&!H)
				if(CodedAdmins.Find(src.key))return
				Admins.Add(params2list("[src.key]=[text2num(Z)]"))
		if("GiveMapper")
			src.verbs-=typesof(/mob/Mapper/verb)
			src.verbs+=typesof(/mob/Mapper/verb)
			src.Mapper=1
			Mappers.Remove("[src.key]")
			Mappers.Add("[src.key]")
			src << "Mapper verbs granted."
			if(!locate(/obj/Skills/Fly, src))
				src.AddSkill(new/obj/Skills/Fly)
		if("RemoveMapper")
			src.verbs-=typesof(/mob/Mapper/verb)
			src.Mapper=0
			Mappers.Remove("[src.key]")
			src << "Mapper verbs removed."
		if("Remove")
			if(CodedAdmins.Find(src.key))return
			if(src in admins)
				admins -= src
			src.verbs-=typesof(/mob/Admin1/verb,/mob/Admin2/verb,/mob/Admin3/verb,/mob/Admin4/verb)
			Admins.Remove(src.key)
			src.Admin=0

mob/proc/CheckPunishment(var/z)
	if(CodedAdmins.Find(src.key))return 0
	for(var/x in Punishments)
		if(x["Punishment"]=="[z]")
			if(x["Key"]==src.key||x["IP"]==src.client.address||x["ComputerID"]==src.client.computer_id)
			 //	if(text2num(x["Duration"])<world.realtime)
			//		Punishments.Remove(list(x))
			//	else
				if(x["Punishment"]=="Ban")
					src<<"You are Banned!"
					spawn()del(src)
				if(x["Punishment"]=="Mute")
					src<<"You are Muted!"
			//	src<<"<br>By: [x["User"]]<br>Reason: [x["Reason"]]<br>TimeStamp: [x["Time"]]<br>Will be lifted in [ConvertTime((text2num(x["Duration"])-world.realtime)/10)]!"
				src<<"<br>By: [x["User"]]<br>Reason: [x["Reason"]]<br>TimeStamp: [x["Time"]]!"
				return 1

proc/AdminMessage(var/msg, adminLevel = 1)
	for(var/mob/Players/M in admins)
		if(M.Admin<adminLevel) continue
		M<<"<b><font color=red>(Admin)</b><font color=fuchsia> [msg]"

proc/Punishment(var/z)
	z=params2list(z)
	if(z["Action"]=="Add")
		Punishments.Add(list(params2list("Punishment=[z["Punishment"]]&Key=[z["Key"]]&IP=[z["IP"]]&ComputerID=[z["ComputerID"]]&Duration=[z["Duration"]]&User=[z["User"]]&Reason=[z["Reason"]]&Time=[z["Time"]]")))
	if(z["Action"]=="Remove")
		for(var/w in Punishments)
			if(z["Punishment"]==w["Punishment"])
				if(z["IP"]==w["IP"])
					w["IP"]=null
				if(z["Key"]==w["Key"])
					w["Key"]=null
				if(z["ComputerID"]==w["ComputerID"])
					w["ComputerID"]=null
				if(w["ComputerID"]==null&&w["IP"]==null&&w["Key"]==null)
					Punishments.Remove(list(z))
	for(var/mob/M in world)
		if(M.client)
			M.CheckPunishment("Ban")

proc/ConvertTime(var/amount)
	var/size=text2num(amount)
	var/ending="Second"
	if(size>=60)
		size/=60
		ending="Minute"
		if(size>=60)
			size/=60
			ending="Hour"
			if(size>=24)
				size/=24
				ending="Day"
	var/end=round(size)
	return "[Value(end,1)] [ending]\s"

proc/ExtractInfo(var/x)
	if(istype(x,/mob))
		if(x:client)
			return "[x:key]</a href>([x])"
	return "[x]([x:type])"


Admin_Help_Object
	var
		Character_Key
		Character_Name
		AdminHelp_Message
		AdminHelp_UniqueID

mob/proc/ViewList()
		var/View={"         <script type="text/javascript">
					var user;
					function choose(choice){
						user = choice;
					}

					function DisplayScreen(Key, Name, Message, src, ID){
						var newMessage = Message.replace(/_/g , " ");
					  	document.getElementById('CharacterKey').innerHTML = "<div align='center'> " + Key + "</div>";
						document.getElementById('CharacterName').innerHTML = "<div align='center'> " + Name + "</div>";
						document.getElementById('CharacterMessage').innerHTML = "<div align='center'> " + newMessage + "</div>";
						document.getElementById('ReplyButton').innerHTML = "<a href=?" + src + ";action=MasterControl;do=PM;ID=" + ID + ";">Reply</a href>"

					}
					</script> <html><head><title>Admin Helps</title><body><font size=3><font color=red>Admin Help List:<hr><font size=2><font color=black>"}
		View+={"
					<TABLE BORDER="3" CELLPADDING="10" CELLSPACING="10">
					<TD>
					<div style="height:380px;width:170px;border:1px solid #ccc;font:16px/26px Georgia, Garamond, Serif;overflow:auto;">
					<TABLE width="150" BORDER="3" CELLPADDING="3" CELLSPACING="3">
		   			<TD width="210"><font size=2>
			 		<div align="center">Ahelps</div></TD><TR>
		"}
		var/Admin_Help_Object/p
		for(p in AdminHelps)
				View+={"<TR>
		   					<TD><div align="center"><font size=2><button type="button" onClick="DisplayScreen('[p.Character_Key]','[p.Character_Name]','[p.AdminHelp_Message]','src=\ref[p.Character_Name]]')">[p.Character_Key]
		   					</button></div>
			 				<div align="center"></div></TD></TR>"}

				//AdminHelps.Remove(p)
		View+={"</TABLE></DIV>
				</TD>
				<TD VALIGN=TOP><div style="height:380px;width:320px;border:1px solid #ccc;font:16px/26px Georgia, Garamond, Serif;overflow:auto;"><table width="300" border="0"align="Top">
  				<tbody>
				<tr VALIGN=TOP>
	  			<td><div align="center"><B><U>Character Key</B></U></div></td>
				</tr>
				<tr VALIGN=TOP>
	  			<td id="CharacterKey"><div align="center">Key</div></td>
				</tr>
				<tr VALIGN=TOP>
	  			<td><div align="center"><B><U>Character Name</B></U></div></td>
				</tr>
				<tr VALIGN=TOP>
	  			<td id="CharacterName"><div align="center">Name</div></td>
				</tr>
				<tr VALIGN=TOP>
	  			<td><div align="center"><B><U>Message</B></U></div></td>
				</tr>
				<tr VALIGN=TOP>
	  			<td id="CharacterMessage"><div align="center">Message </div></td>
				</tr>
					<tr VALIGN=BOTTOM>
	  <td id="ReplyButton"><div align="center"></div></td>
	</tr>
  				</tbody>
				</table></DIV></TD>
				</TABLE>"}
		usr<<browse("[View]","window=Logrw;size=600x500")
		View+={"</table"><br>"}

//var/AdminHelps[0]

mob/proc/PM(var/mob/who, var/AhelpMessage, var/AhelpKey)
	var/whoKey = who.DisplayKey ? who.DisplayKey : who.key
	var/UserInput=input("What do you want to say to [whoKey]?") as text|null
	var/key = DisplayKey ? DisplayKey : src.key
	if(UserInput)
		for(var/mob/Players/Q in admins)
			if(Q?:PingSound)
				who << sound('Sounds/Ping.ogg', volume = Q?:PingVolume)
			if(Q!=src&&Q!=who)
				Q<<"<font color=#00FF99><b>(Admin PM)</b></font> <a href=?src=\ref[src];action=MasterControl;do=PM2;>[key]</a href> to <a href=?src=\ref[who];action=MasterControl;do=PM2>[who.key]</a href> :[UserInput]"
		src<<"<font color=#00FF99><b>(Admin PM)</b></font>- To  <a href=?src=\ref[who];action=MasterControl;do=PM2;>[whoKey]</a href> :[UserInput]"
		who<<"<font color=#00FF99><b>(Admin PM)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=PM2;>[key]</a href> :[UserInput]"
		for(var/Admin_Help_Object/M in AdminHelps)
			if( (M.AdminHelp_Message == AhelpMessage) && (M.Character_Key == AhelpKey) )
				AdminHelps.Remove(M)

mob/proc/PM2(var/mob/who)
	var/whoKey = who.DisplayKey ? who.DisplayKey : who.key
	var/UserInput=input("What do you want to say to [whoKey]?") as text|null
	var/key = DisplayKey ? DisplayKey : src.key
	if(UserInput&&who)
		for(var/mob/Players/Q in admins)
			if(Q?:PingSound && who == Q)
				Q << sound('Sounds/Ping.ogg',volume = Q?:PingVolume)
			if(Q!=src&&Q!=who)
				Q<<"<font color=#00FF99><b>(Admin PM)</b></font> <a href=?src=\ref[src];action=MasterControl;do=PM2;>[key]</a href> to <a href=?src=\ref[who];action=MasterControl;do=PM2;>[who.key]</a href> :[UserInput]"
		Log("AdminPM","(Admin PM from [key] to [whoKey]): [UserInput]")
		src<<output("<font color=#00FF99><b>(Admin PM)</b></font>- To  <a href=?src=\ref[who];action=MasterControl;do=PM2;>[whoKey]</a href> :[UserInput]", "output")
		who<<output("<font color=#00FF99><b>(Admin PM)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=PM2;>[key]</a href> :[UserInput]", "output")
		src<<output("<font color=#00FF99><b>(Admin PM)</b></font>- To  <a href=?src=\ref[who];action=MasterControl;do=PM2;>[whoKey]</a href> :[UserInput]", "oocchat")
		who<<output("<font color=#00FF99><b>(Admin PM)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=PM2;>[key]</a href> :[UserInput]", "oocchat")
		src<<output("<font color=#00FF99><b>(Admin PM)</b></font>- To  <a href=?src=\ref[who];action=MasterControl;do=PM2;>[whoKey]</a href> :[UserInput]", "icchat")
		who<<output("<font color=#00FF99><b>(Admin PM)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=PM2;>[key]</a href> :[UserInput]", "icchat")
		src<<output("<font color=#00FF99><b>(Admin PM)</b></font>- To  <a href=?src=\ref[who];action=MasterControl;do=PM2;>[whoKey]</a href> :[UserInput]", "loocchat")
		who<<output("<font color=#00FF99><b>(Admin PM)</b></font>- From  <a href=?src=\ref[src];action=MasterControl;do=PM2;>[key]</a href> :[UserInput]", "loocchat")
		winset(who, "mainwindow", "flash=-1")


/mob/var/PingSound = TRUE
/mob/var/PingVolume = 30

mob/Admin3/verb
	editRace(mob/Players/m in players)
		set category = "Admin"
		usr:Edit(m.race)
		for(var/ascensions/a in m.race.ascensions)
			usr:Edit(a)
	editInformation(mob/Players/m in players)
		set category = "Admin"
		usr:Edit(m.information)

	Tech_Unlock(mob/Players/m in players)
		set category="Admin"
		var/Mode=input(usr, "Are you adding, removing, or viewing [m]'s unlocked technology?", "Tech Unlock") in list("Cancel", "Add", "Remove", "View")
		if(Mode=="Cancel")
			return
		switch(Mode)
			if("Add")
				var/list/Options=list("Cancel",
				"Weapons", "Armor", "Weighted Clothing", "Smelting", "Locksmithing",
				"Molecular Technology", "Light Alloys", "Shock Absorbers", "Advanced Plating", "Modular Weaponry",
				"Medkits", "Fast Acting Medicine", "Enhancers", "Anesthetics", "Automated Dispensers",
				"Regenerator Tanks", "Prosthetic Limbs", "Genetic Manipulation", "Regenerative Medicine", "Revival Protocol",
				"Wide Area Transmissions", "Espionage Equipment", "Surveilance", "Drones", "Local Range Devices",
				"Scouters", "Obfuscation Equipment", "Satellite Surveilance", "Combat Scanning", "EM Wave Projectors",
				"Hazard Suits", "Force Shielding", "Jet Propulsion", "Power Generators", "Space Travel",
				"Android Creation", "Conversion Modules", "Enhancement Chips", "Involuntary Implantation", "Self Augmentation",
				"Assault Weaponry", "Missile Weaponry", "Melee Weaponry", "Thermal Weaponry", "Blast Shielding",
				"Powered Armor Specialization", "Armorpiercing Weaponry", "Impact Weaponry", "Hydraulic Weaponry","Vehicular Power Armor",
				"Healing Herbs", "Refreshment Herbs", "Magic Herbs", "Toxic Herbs", "Philter Herbs",
				"Stimulant Herbs", "Relaxant Herbs", "Numbing Herbs", "Distillation Process", "Mutagenic Herbs",
				"Spell Focii", "Artifact Manufacturing", "Magical Communication", "Magical Vehicles", "Warding Glyphs",
				"Tome Cleansing", "Tome Security", "Tome Translation", "Tome Binding", "Tome Excerpts",
				"Turf Sealing", "Object Sealing", "Power Sealing", "Mobility Sealing", "Command Sealing",
				"Teleportation", "Dimensional Manipulation", "Retrieval", "Bilocation", "Dimensional Restriction",
				"Transmigration", "Lifespan Extension", "Temporal Displacement", "Temporal Acceleration", "Temporal Rewinding", "Ritual Magic", "Introductory Ritual Magics")
				for(var/o in m.knowledgeTracker.learnedKnowledge)
					Options.Remove(o)
				var/Choice=input(usr, "What breakthrough do you want to grant to [m]?", "Tech Unlock") in Options
				if(Choice=="Cancel")
					return
				m.knowledgeTracker.learnedKnowledge.Add(Choice)
				Log("Admin", "[ExtractInfo(usr)] unlocked [Choice] knowledge breakthrough from [ExtractInfo(m)]!")
			if("Remove")
				var/list/Options=list("Cancel")
				for(var/o in m.knowledgeTracker.learnedKnowledge)
					Options.Add(o)
				if(Options.len<2)
					src << "[m] doesn't have any technology unlocks to remove!"
					return
				var/Choice=input(src, "What breakthrough are you removing from [m]?", "Tech Lock") in Options
				if(Choice=="Cancel")
					return
				m.knowledgeTracker.learnedKnowledge.Remove(Choice)
				Log("Admin", "[ExtractInfo(m)] removed [Choice] knowledge breakthrough from [ExtractInfo(m)]!")
			if("View")
				src << "[m]'s Unlocked Breakthroughs:"
				for(var/o in m.knowledgeTracker.learnedKnowledge)
					src << "[o]"

	FPSControl(fpsadjust as num)
		set category="Admin"
		set hidden = 1
		world.fps=fpsadjust
		Log("Admin","World FPS adjusted to [fpsadjust] by [ExtractInfo(usr)].")


mob/Admin2/verb

	TurfFlythru()
		set category="Admin"
		if(usr.IgnoreFlyOver)
			usr.IgnoreFlyOver=0
			Log("Admin","[ExtractInfo(usr)] has disabled their Ignore FlyOverAble flag.")
		else
			usr.IgnoreFlyOver=1
			Log("Admin","[ExtractInfo(usr)] has enabled their Ignore FlyOverAble flag.")
	ToggleOverview()
		set category="Admin"
		if(usr.Overview==1)
			usr.Overview=0
			usr<<"Personal Overview disabled."
		else if(usr.Overview==0)
			usr.Overview=1
			usr<<"Personal Overview enabled."

	AdminInviso()
		set category="Admin"
		if(usr.AdminInviso)
			usr<<"<font color=red>Admin Inviso off."
			usr.AdminInviso=0
			usr.invisibility=0
			usr.see_invisible=0
			usr.Incorporeal=0
			usr.density=1
			usr.passive_handler.Decrease("AdminVision", 1)
			usr.Grabbable=1
			animate(src,alpha=255,time=10)
		else
			usr<<"<font color=green>Admin Inviso on."
			usr.AdminInviso=1
			usr.invisibility=100
			usr.see_invisible=101
			usr.Incorporeal=1
			usr.passive_handler.Increase("AdminVision", 1)
			usr.density=0
			usr.Grabbable=0
			animate(src,alpha=50,time=10)

	AdminAssess(var/mob/M in world)
		set category="Admin"
		usr<<browse(M.GetAssess(),"window=Assess;size=275x650")


	Alerts()
		set category="Admin"
		set name="(Un)Mute Admin Alerts"
		usr.client.togglePref("AdminAlerts")
		usr << "Admin Alerts will now[usr.client.getPref("AdminAlerts") ? "" : " not"] show."

	AdminPM(mob/M in players)
		set category="Admin"
		usr.PM(M)


	AdminChat(c as text)
		set category = "Admin"
		Log("Admin", "<b><font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=cyan>Admin Chat:<font color=white>[usr.DisplayKey ? "[usr.DisplayKey]([usr.key])": "([usr.key])"]:</b><font color=green> [c]", NoPinkText=1)
		for(var/mob/Players/M in admins)
			if(M.Timestamp)
				M<<"<b><font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]<font color=cyan>Admin Chat:<font color=white>[usr.DisplayKey ? "[usr.DisplayKey]([usr.key])": "([usr.key])"]:</b><font color=green> [c]"
			else
				M<<"<b><font color=cyan>Admin Chat:<font color=white>[usr.DisplayKey ? "[usr.DisplayKey]([usr.key])": "([usr.key])"]:</b><font color=green> [c]"

	Observe_(atom/A as mob|obj in world)
		set category="Admin"
		set name="AObserve"
		Observify(usr,A)
		if(A!=src)
			src.Observing=2
			Log("Admin","[ExtractInfo(usr)] observed [A].")
		else
			src.Observing=0

	Delete(atom/A in world)
		set category="Admin"

		if(istype(A,/area/))
			usr<<"You can't delete Areas."
			return
		Log("Admin","[ExtractInfo(usr)] has deleted [A]([A.type]).")
		if(ismob(A))
			if(A:client)
				Log("Admin","[ExtractInfo(usr)] booted [ExtractInfo(A)].")
				world<<"<font color=#FFFF00>[A] has been booted"
				del(A:client)
		del(A)


	Message_Z_Plane(msg as message)
		set category="Admin"
		for(var/mob/Players/p in world)
			if(p.z==src.z)
				p << output("<font size=2><font color=red><b>[msg]", "output")
				p << output("<font size=2><font color=red><b>[msg]", "icchat")
				p << output("<font size=2><font color=red><b>[msg]", "oocchat")
				if(p.Admin)p<<"[usr] used message (Z plane)."

	Message_Global(msg as message)
		set category="Admin"

		var discord_output = msg
		msg = replacetext(msg, "```","")
		world << output("<font size=2><font color=green><b>[msg]", "output")
		world << output("<font size=2><font color=green><b>[msg]", "icchat")
		world << output("<font size=2><font color=green><b>[msg]", "oocchat")

		switch(input("Should this message be sent to an Announcements Discord aswell?") in list("Yes","No"))
			if("Yes")
				discord_output = replacetext(discord_output, "<b>","**")
				discord_output = replacetext(discord_output, "</b>","**")
				discord_output = replacetext(discord_output, "<br>","")
				discord_output = "@everyone [discord_output]"
				switch(input("IC Announcement or OOC Announcement?") in list("IC", "OOC"))
					if("IC")
						if(glob.discordICAnnounceWebhookURL)
							usr.client.HttpPost(
								"[glob.discordICAnnounceWebhookURL]",
								list(
									content = discord_output,
									username = "Story Announcement"
								)
							)
						else
							usr << "The OOCAnnounce webhook wasn't set up!"
					if("OOC")
						if(glob.discordOOCAnnounceWebhookURL)
							usr.client.HttpPost(
								"[glob.discordOOCAnnounceWebhookURL]",
								list(
									content = discord_output,
									username = "OOC Announcement"
								)
							)
						else
							usr << "The OOCAnnounce webhook wasn't set up!"

		for(var/mob/M in admins) M<<"[usr] used message (global)."

	Teleport(mob/M as mob|obj in world)
		set category="Admin"
		usr.PrevX=usr.x
		usr.PrevY=usr.y
		usr.PrevZ=usr.z
		loc=M.loc
		Log("Admin","[ExtractInfo(usr)] teleported to [M].")
	Unteleport(mob/M as mob|obj in world)
		set category="Admin"
		if(!M.PrevX)
			usr<<"This mob/obj has not been teleported or summoned, and thus has no previous XYZ data."
			return
		else
			M.x=M.PrevX
			M.y=M.PrevY
			M.z=M.PrevZ
			M.PrevX=null
			M.PrevY=null
			M.PrevZ=null
			usr<<"Returned [M] to previous coordinates."
			M<<"You have been returned to your previous coordinates by admins."
	XYZTeleport(var/mob/M in world)
		var/x=input("x","[M]") as num
		var/y=input("y","[M]") as num
		var/z=input("z","[M]") as num
		set category="Admin"
		M.PrevX=M.x
		M.PrevY=M.y
		M.PrevZ=M.z
		M.loc=locate(x,y,z)
		Log("Admin","[ExtractInfo(usr)] teleported [ExtractInfo(M)] to [x],[y],[z].")

	globallyIndestructable()
		set category = "Admin"
		set hidden = 1
		for(var/obj/Turfs/t in world)
			t.Destructable = FALSE
			t.Grabbable = FALSE

	AdminRename(atom/A in world)
		set category="Admin"
		var/Old_Name=A.name
		A.name=input("Renaming [A]") as text
		if(!A.name)
			A.name=Old_Name
		else
			Log("Admin","[ExtractInfo(usr)] renamed [ExtractInfo(A)] from [Old_Name].")
			if(isplayer(A))
				glob.IDs[A:UniqueID] = "[A.name]"


	Warper(_x as num,_y as num,_z as num)
		set category="Admin"
		src.MakeWarper(_x, _y, _z)

	SendToSpawnz(mob/A in players)
		set name="Send To Spawn"
		set category="Admin"
		MoveToSpawn(A)
		Log("Admin","[ExtractInfo(usr)] sent [ExtractInfo(A)] to spawn.")
	AdminKill(mob/A in world)
		set category="Admin"
		var/confirm = alert(usr, "Are you sure you wanna admin kill [A.name]?",, "Yes", "No")
		if(confirm == "No") return
		var/customDeath = input(usr, "What do you want the death message to say? The format is 'name has been killed by INPUT', where input is what you put here. Entering nothing defaults to ADMIN.") as text|null
		if(!customDeath)
			customDeath = "ADMIN"
		A.Death(null,customDeath, SuperDead=1)
		Log("Admin","<font color=red>[ExtractInfo(usr)] admin-killed [ExtractInfo(A)].")
	DoDamagez(mob/A in world)
		set category="Admin"
		set name="DoDamage"
		var/DamageType=input("What type of damage? Be careful with poison and burning due to their nature.") in list("Cancel","True Damage","Poison","Burning", "Normal Damage")
		if(DamageType=="Cancel")
			return
		var/Damage=input("Inflict how much [DamageType]? Put in zero to cancel.") as null|num
		if(Damage!=null)
			if(istext(A.Health))
				A.Health=100
				Log("Admin","<font color=red>[A]'s Health variable was text for some reason! Resetting to 100.")
			if(DamageType=="True Damage")
				A.Health-=Damage
			else if(DamageType=="Poison")
				A.AddPoison(Damage)
			else if(DamageType=="Burning")
				A.AddBurn(Damage)
			else if(DamageType=="Normal Damage")
				usr.DoDamage(A, Damage)
			Log("Admin","<font color=red>[ExtractInfo(usr)] did [Damage] [DamageType] to [ExtractInfo(A)].")
		else
			return
	ReMeditate(mob/A in players)
		set category="Admin"
		if(A.icon_state!="Meditate")
			A << "You've been made to meditate by a admin."
			A.icon_state = "Meditate"
			A.dir=SOUTH
			A.AfterImageStrike=0
			A.Grounded=0
			A.Meditation()
			Log("Admin","<font color=red>[ExtractInfo(usr)] made [ExtractInfo(A)] meditate.")
		else
			usr << "They're already meditating."
			return


	AdminKO(mob/A in world)
		set category="Admin"
		if(!A.KO)
			A.Unconscious(null,"ADMIN")
			Log("Admin","<font color=red>[ExtractInfo(usr)] admin-KOed [ExtractInfo(A)].")

	AdminHeal(mob/A in world)
		set category="Admin"
		if(A.KO)
			A.Conscious()
		A.Health=100
		A.Energy=A.EnergyMax
		A.ManaAmount=A.ManaMax*A.GetManaCapMult()
		A.Burn=0
		A.Poison=0
		A.Slow=0
		A.Shock=0
		A.HealthAnnounce25=0
		A.HealthAnnounce10=0
		A.seventhSenseTriggered = 0
		Log("Admin","<font color=aqua>[ExtractInfo(usr)] admin-healed [ExtractInfo(A)].")
	AdminHealComplete(mob/A in world)
		set category="Admin"
		if(A.KO)
			A.Conscious()
		A.Health=100
		A.Energy=A.EnergyMax
		A.ManaAmount=A.ManaMax*A.GetManaCapMult()
		A.Burn=0
		A.Poison=0
		A.Slow=0
		A.Shock=0
		A.Shatter=0
		A.HealthAnnounce25=0
		A.HealthAnnounce10=0
		A.seventhSenseTriggered = 0
		A.TotalFatigue=0
		A.TotalInjury=0
		A.BPPoison=1
		A.BPPoisonTimer=0
//		A.TotalCapacity=0
		A.InjuryAnnounce=0
		Log("Admin","<font color=aqua>[ExtractInfo(usr)] complete-admin-healed [ExtractInfo(A)].")
	AdminHealCapacity(var/mob/m in players)
		set category="Admin"
		m.TotalCapacity=0
		Log("Admin","<font color=aqua>[ExtractInfo(usr)] admin-restored capacity for [ExtractInfo(m)].")
	AdminHealFatigue(var/mob/m in players)
		set category="Admin"
		m.TotalFatigue=0
		Log("Admin","<font color=aqua>[ExtractInfo(usr)] admin-healed fatigue for [ExtractInfo(m)].")
	AdminHealInjury(var/mob/m in players)
		set category="Admin"
		m.TotalInjury=0
		m.InjuryAnnounce=0
		Log("Admin","<font color=aqua>[ExtractInfo(usr)] admin-healed injury for [ExtractInfo(m)].")
	AdminRevive(mob/A in players)
		set category="Admin"
		Log("Admin","[usr.key] revived [A.key].")
		A.Revive()


	Narrate(msg as message)
		set category="Admin"
		view(20)<< output("<font color=yellow>[msg]", "output")
		view(20)<< output("<font color=yellow>[msg]", "icchat")
		for(var/mob/m in view(20))
			if(m.BeingObserved.len>0)
				for(var/mob/mo in m.BeingObserved)
					mo << output("<b>(OBSERVE)</b><font color=yellow>[msg]", "icchat")
					mo << output("<b>(OBSERVE)</b><font color=yellow>[msg]", "output")

		Log("Admin", "[ExtractInfo(usr)] narrated ([msg]).", 0, 3)

	Summon(mob/M as mob|obj in world)
		set category="Admin"
		if(istype(M, /mob))
			M.PrevX=M.x
			M.PrevY=M.y
			M.PrevZ=M.z
		M.loc=loc
		Log("Admin","[ExtractInfo(usr)] summoned [ExtractInfo(M)].")


	Event_Character_Setup(mob/Players/M in players)
		set category="Admin"
		var/EMult=glob.progress.RPPBaseMult
		EMult*=M.GetRPPMult()
		M.RPPSpendable=getMaxPlayerRPP()
		M.PotentialRate=0
		M.Potential=input(src, "What potential do you want to set [M] to?", "Set Potential") as num
		M.ECCHARACTER=TRUE
		Log("Admin", "[ExtractInfo(src)] triggered [ExtractInfo(M)]'s event character setup!")



	Edit(atom/A in world)
		set category = "Admin"

		if(A.type in typesof(/obj/Items))
			if (A?:Augmented)
				A?:EditAll(src)
		else if (A.type in typesof(/obj/Skills))
			if (length(A?:possible_skills) > 1)
				A?:EditAll(src)
		else if (istype(A, /obj/AI_Spot))
			A?:EditAI(src)

		var/Edit = "<html><Edit><body bgcolor=#000000 text=#339999 link=#99FFFF>"
		Edit += "[A]<br>[A.type]"
		Edit += "<table width=10%>"

		var/list/B = A.vars
		var/list/exclude = list("Package", "bound_x", "bound_y", "step_x", "step_y", "Admin", "Profile", "GimmickDesc",
								"NoVoid", "BaseProfile", "Form1Profile", "Form2Profile", "Form3Profile", "Form4Profile",
								"Form5Profile", "ai_owner")

		if (usr.Admin <= 3)
			exclude += list("passive_handler", "race")

		for (var/C in B)
			if (C in exclude)
				continue

			var/value = Value(A.vars[C])
			var/row = "<tr><td><a href='byond://?src=\ref[A];action=edit;var=[C]'>[C]</a></td>"
			if (isdatum(A.vars[C]))
				row += "<td><a href='byond://?src=\ref[A.vars[C]];action=edit;var=[C]'>[value]</a></td></tr>"
			else
				row += "<td>[value]</td></tr>"

			Edit += row

			CHECK_TICK

		Edit += "</table></html>"

		usr << browse(Edit, "window=[A];size=450x600")

mob/Admin3/verb
	ToggleOOCWorld()
		set category="Admin"
		Allow_OOC=!Allow_OOC
		if(Allow_OOC)
			world<<"OOC Channel is <font color=green>enabled</font color>!"
		else
			world<<"OOC Channel is <font color=red>disabled</font color>!"
		Log("Admin","[ExtractInfo(usr)] toggled global OOC!")

	AdminLogs()
		set category="Admin"
		usr.SegmentLogs("Saves/AdminLogs/")

	PlayerLog(mob/Players/M in players)
		set category="Admin"
		usr.SegmentLogs("Saves/PlayerLogs/[M.key]/")

	Announce(msg as text)
		set category="Admin"
		var/display = usr.key
		if(DisplayKey)
			display = DisplayKey
		world<<"<hr><center><b>[display]</b> announces:<br>[msg]<br><hr>"
	Mute(mob/M in players)
		set category="Admin"
		if(!M.client)
			return
		var/Reason=input("Why are you muting [M]?")as text
		var/Duration=input("Mute Duration?(IN MINUTES)","Rebirth")as num
		if(Alert("Are you sure you want to mute [M] for [Duration] Minutes?"))
			Duration=Value(world.realtime+(Duration*600))
			Punishment("Action=Add&Punishment=Mute&Key=[M.key]&IP=[M.client.address]&ComputerID=[M.client.computer_id]&Duration=[Duration]&User=[usr.key]&Reason=[Reason]&Time=[TimeStamp()]")
			Log("Admin","[ExtractInfo(usr)] muted [M.key]|[M.client.address]|[M.client.computer_id] for [Reason].")
	UnMute()
		set category="Admin"
		var/list/people=list("Cancel")
		var/blah=input("What do you want to unmute?","Rebirth")in list("Entire List","Key","IP","ComputerID","Cancel")
		if(blah=="Cancel")return
		if(blah=="Entire List")
			for(var/x in Punishments)
				if(x["Punishment"]=="Mute")
					people.Add(x["Key"])
			var/person=input("Completely Unmute who?","Rebirth") in people
			if(person=="Cancel")return
			for(var/x in Punishments)
				if(x["Punishment"]=="Mute")
					if(x["Key"]==person)
						Punishments.Remove(list(x))
						Log("Admin","[ExtractInfo(usr)] unmuted(all) [person].")

		else
			for(var/x in Punishments)
				if(x["Punishment"]=="Mute")
					people.Add(x["[blah]"])
			var/person=input("[blah] Unmute who?","Rebirth") in people
			if(person=="Cancel")return
			Punishment("Action=Remove&Punishment=Mute&[blah]=[person]")
			Log("Admin","[ExtractInfo(usr)] unmuted [person].")

	UnlockAscension(var/mob/m in players)
		set category="Admin"
		if(m.passive_handler.Get("Piloting"))
			m.findMecha().Level = input("Unlock what level? (This is for their mech.)", "([m.findMecha().Level] unlocked)") as num
			Log("Admin","[ExtractInfo(usr)] unlocked [ExtractInfo(m)]'s mecha([m.findMecha().Level])")
			return
		if(m.client)
			m.AscensionsUnlocked=input("Unlock what ascension?", "([m.AscensionsUnlocked] unlocked)") as num
			Log("Admin","[ExtractInfo(usr)] unlocked [ExtractInfo(m)]'s ascension([m.AscensionsUnlocked])")
	UnlockForm(var/mob/M in players)
		set category="Admin"
		if(M.client)
			var/blah=input("Unlock to what form?") as num | null
			if(!blah) return
			if(isRace(SAIYAN) && blah == 4)
				var/godor4 = input("SSJ God or SSJ4?") in list("SSJ God", "SSJ4")
				if(godor4 == "SSJ4")
					for(var/transformation/saiyan/ssj in M.race.transformations)
						if(istype(ssj, /transformation/saiyan/super_saiyan_god) || istype(ssj, /transformation/saiyan/super_saiyan_blue))
							M.race.transformations -= ssj
							del ssj
					M.AddSkill(new/obj/Skills/False_Moon)
				else
					for(var/transformation/saiyan/ssj in M.race.transformations)
						if(istype(ssj, /transformation/saiyan/super_saiyan_4))
							M.race.transformations -= ssj
							del ssj
			M.transUnlocked = blah
			Log("Admin","[ExtractInfo(usr)] unlocked [ExtractInfo(M)] 's form([blah])")

	Ban(mob/M in players)
		set category="Admin"
		var/Reason=input("Why are you banning [M]?")as text
		var/Duration=input("Ban Duration?(IN HOURS)","Rebirth")as num
		if(Alert("Are you sure you want to ban [M] for [Duration] Hours?"))
			Duration=Value(world.realtime+(Duration*600*60))
			Punishment("Action=Add&Punishment=Ban&Key=[M.key]&IP=[M.client.address]&ComputerID=[M.client.computer_id]&Duration=[Duration]&User=[usr.key]&Reason=[Reason]&Time=[TimeStamp()]")
			world<<"[M.key] was banned for [Reason]."
			Log("Admin","[ExtractInfo(usr)] banned [M.key]|[M.client.address]|[M.client.computer_id] for [Reason].")
		//	spawn(10)M.CheckPunishment("Ban")
	UnBan()
		set category="Admin"
		var/list/people=list("Cancel")
		var/blah=input("What do you want to unban?","Rebirth")in list("Entire List","Key","IP","ComputerID","Cancel")
		if(blah=="Cancel")return
		if(blah=="Entire List")
			for(var/x in Punishments)
				if(x["Punishment"]=="Ban")
					people.Add(x["Key"])
			var/person=input("Completely Unban who?","Rebirth") in people
			if(person=="Cancel")return
			for(var/x in Punishments)
				if(x["Punishment"]=="Ban")
					if(x["Key"]==person)
						Punishments.Remove(list(x))
						Log("Admin","[ExtractInfo(usr)] unbanned(all) [person].")
		else
			for(var/x in Punishments)
				if(x["Punishment"]=="Ban")
					people.Add(x["[blah]"])
			var/person=input("[blah] Unban who?","Rebirth") in people
			if(person=="Cancel")return
			Punishment("Action=Remove&Punishment=Ban&[blah]=[person]")
			Log("Admin","[ExtractInfo(usr)] unbanned [person].")


	RPP_Set_Starting(var/val as num|null)
		set category="Admin"
		if(val==null || !val)
			val=input(usr, "What is the starting RPP value?", "Starting RPP") as num|null
		if(val<=0 || val==null)
			return
		glob.progress.RPPStarting=val
		Log("Admin", "[ExtractInfo(usr)] set the global RPP starting value to [glob.progress.RPPStarting]. It will be acquired in [glob.progress.RPPStartingDays] days after making a new character.")
	RPP_Set_Starting_Days(var/val as num|null)
		set category="Admin"
		if(val==null || !val)
			val=input(usr, "What is the number of days it takes to reach the starting RPP value?", "Starting RPP Days") as num|null
		if(val<=0 || val==null)
			return
		glob.progress.RPPStartingDays=val
		Log("Admin", "[ExtractInfo(usr)] set the global RPP starting value to [glob.progress.RPPStarting]. It will be acquired in [glob.progress.RPPStartingDays] days after making a new character.")

	RPP_Set(mob/Players/P in players)
		set category="Admin"
		set hidden=1

		var/EMult=glob.progress.RPPBaseMult
		EMult*=P.GetRPPMult()

		var/OldRPP=P.RPPSpent+P.GetRPPSpendable()
		var/NewRPP=input(usr,"Set the value that [P]'s RPP should be at.  They currently have [Commas(P.GetRPPSpendable())] with [Commas(P.RPPSpent)] RPP spent for [Commas(OldRPP)] total. (x[EMult] RPP Mult)") as num|null
		NewRPP*=EMult

		NewRPP-=P.RPPSpent
		if(NewRPP>=0)
			P.RPPSpendable=NewRPP
			Log("Admin","[ExtractInfo(usr)] set [ExtractInfo(P)]'s total RPP (Spent and Unused) from [Commas(OldRPP)] to [Commas(NewRPP)]. (RPP mult of x[EMult])")


	RPP_Refund(mob/Players/P in players)
		set category="Admin"
		if(P.refunding)
			usr << "Something is already being refunded!"
			return
		P.refunding = TRUE

		var/refunding_skill = pick_refund_skill(P)

		if(!refunding_skill)
			P.refunding = FALSE
			return

		P.refund_skill(refunding_skill)

		P.refunding = FALSE


	RPP_Everyone()
		set category="Admin"
		set hidden=1
		var/AddRPP=glob.progress.RPPDaily
		for(var/mob/Players/P in players)
			var/YourRPP=AddRPP
			if(YourRPP>0)
				if(locate(/obj/Skills/Utility/Teachz, P))
					var/ElderMult=0.5
					if(P.EraBody=="Senile"||P.isRace(SHINJIN))
						ElderMult=1
					P.RPPDonate+=(YourRPP*ElderMult*P.RPPMult*glob.progress.RPPBaseMult)
					P << "You have gained knowledge on how to help further other's development!"

				var/EMult=glob.progress.RPPBaseMult
				EMult*=P.GetRPPMult()
				YourRPP*=EMult

				P.RPPSpendable+=YourRPP
			if((P.EraBody!="Child"||!P.EraBody)&&!P.Dead)
				P << "You gain money from routine tasks."
				var/AgeMult=1
				P.GiveMoney(round(glob.progress.EconomyIncome*P.EconomyMult*P.Intelligence*AgeMult))
		glob.progress.RPPStarting+=AddRPP
		Log("Admin", "[ExtractInfo(src)] triggered routine RPP gains of [Commas(AddRPP)].")

	RPP_Routine(mob/Players/P in players)
		set category="Admin"
		set hidden=1
		var/AddRPP=glob.progress.RPPDaily
		var/YourRPP=AddRPP
		if(YourRPP>0)
			if(locate(/obj/Skills/Utility/Teachz, P))
				var/ElderMult=0.5
				if(P.EraBody=="Senile"||P.isRace(SHINJIN))
					ElderMult=1
				P.RPPDonate+=(YourRPP*ElderMult*P.RPPMult*glob.progress.RPPBaseMult)
				P << "You have gained knowledge on how to help further other's development!"

			var/EMult=glob.progress.RPPBaseMult
			EMult*=P.GetRPPMult()
			YourRPP*=EMult
//TODO COME BACK HERE
			P.RPPSpendable+=round(YourRPP)
		if((P.EraBody!="Child"||!P.EraBody)&&!P.Dead)
			var/AgeMult=1
			if(P.EraBody=="Youth"||P.EraBody=="Elder")
				AgeMult=0.5
			if(P.EraBody=="Senile")
				AgeMult=0.25
			P.GiveMoney(round(glob.progress.EconomyIncome*P.EconomyMult*P.Intelligence*AgeMult))
		Log("Admin", "[ExtractInfo(src)] triggered [ExtractInfo(P)]'s routine RPP gains of [Commas(AddRPP)].")

	RPP_Equalize_Everyone()
		set category="Admin"
		set hidden=1
		var/Cap=input(usr,"Input the RPP value everyone will be brought to.") as num
		for(var/mob/Players/P in players)
			var/YourRPP=Cap
			if(YourRPP>0)
				if(locate(/obj/Skills/Utility/Teachz, P))
					var/ElderMult=0.5
					if(P.EraBody=="Senile"||P.isRace(SHINJIN))
						ElderMult=1
					P.RPPDonate=(Cap*ElderMult*P.RPPMult*glob.progress.RPPBaseMult)
					P << "You have gained knowledge on how to help further other's development!"

				var/EMult=glob.progress.RPPBaseMult
				EMult*=P.GetRPPMult()
				YourRPP*=EMult

				P.RPPSpendable=YourRPP-P.RPPSpent

		glob.progress.RPPStarting=Cap
		Log("Admin", "[ExtractInfo(src)] triggered RPP equalization.")

	RPP_Equalize_Target(mob/Players/P in players)
		set category="Admin"
		set hidden=1
		var/Cap=input(usr,"Input the RPP value target will be brought to.") as num
		var/YourRPP=Cap
		if(YourRPP>0)
			if(locate(/obj/Skills/Utility/Teachz, P))
				var/ElderMult=0.5
				if(P.EraBody=="Senile"||P.isRace(SHINJIN))
					ElderMult=1
				P.RPPDonate=(Cap*ElderMult*P.RPPMult*glob.progress.RPPBaseMult)
				P << "You have gained knowledge on how to help further other's development!"

			var/EMult=glob.progress.RPPBaseMult
			EMult*=P.GetRPPMult()
			YourRPP*=EMult

			P.RPPSpendable=YourRPP-P.RPPSpent

		Log("Admin", "[ExtractInfo(src)] triggered RPP equalization for [P].")

	New_Character_Setup(mob/Players/M in players)
		set category="Admin"
		if(locate(/obj/Skills/Utility/Teachz, M))
			var/ElderMult=0.5
			if(M.EraBody=="Senile"||M.isRace(SHINJIN))
				ElderMult=1
			M.RPPDonate+=(glob.progress.RPPStarting*ElderMult*M.RPPMult*glob.progress.RPPBaseMult)
			M << "You have gained knowledge on how to help further other's development!"

		var/EMult=glob.progress.RPPBaseMult
		EMult*=M.GetRPPMult()
		if(M.RPPCurrent < glob.progress.RPPStarting)
			M.RPPCurrent = setMaxRPP()
		M.RPPSpendable = glob.progress.RPPStarting * M.GetRPPMult()-M.RPPSpent
		M << "You have been given [M.RPPCurrent-M.RPPSpent]"
		Log("Admin", "[ExtractInfo(src)] triggered [ExtractInfo(M)]'s starter rewards!")


	Give_Mapper(var/mob/m in players)
		set category="Admin"
		m.Admin("GiveMapper")
		Log("Admin", "[ExtractInfo(usr)] has made [ExtractInfo(m)] into a mapper!")
	Remove_Mapper(var/mob/m in players)
		set category="Admin"
		m.Admin("RemoveMapper")
		Log("Admin", "[ExtractInfo(usr)] has removed [ExtractInfo(m)]'s mapper powers!")

	Give_Money(var/mob/m in players, var/num as num)
		set category="Admin"
		set name="Give Money"
		var/Highest=glob.progress.EconomyMult
		if(m.EconomyMult>Highest)
			Highest=m.EconomyMult
		m.GiveMoney(num*Highest)
		Log("Admin","[ExtractInfo(usr)] increased [m]'s money by [Commas(num)] (x[Highest] economy mult).")

	Adminize(mob/z in players)
		set category="Admin"
		var/x=input("What level?(0-3)","0-3",z.Admin)as num
		if(x>=0&&x<=3)
			Log("Admin","[ExtractInfo(usr)] set [ExtractInfo(z)]'s admin level to [x].")
			if(x==0)
				z.Admin("Remove")
			else
				z.Admin("Give",x)

	ManuallyBan()
		set category="Admin"
		var/x=input("Input the desired Key to manual ban.","Rebirth")as text|null
		var/y=input("Input the desired IP Address to manual ban.","Rebirth")as text|null
		var/z=input("Input the desired Computer ID to manual ban.","Rebirth")as text|null
		var/Reason=input("Why are you banning them?")as text
		var/Duration=10000000000//=input("Ban Duration?(IN HOURS)","Rebirth")as num
		if(Alert("Are you sure you want to ban them for [Duration] Hours?"))
			Duration=Value(world.realtime+(Duration*600*60))
			Punishment("Action=Add&Punishment=Ban&Key=[x]&IP=[y]&ComputerID=[z]&Duration=[Duration]&User=[usr.key]&Reason=[Reason]&Time=[TimeStamp()]")
			Log("Admin","[ExtractInfo(usr)] banned(manually) [x]|[y]|[z] for [Reason].")

	MassSummon()
		set category="Admin"
		if(Alert("You sure you want to mass summon? You require express permission from no one in order to use this."))
			Log("Admin","<font color=blue>[ExtractInfo(usr)] mass summoned!")
			switch(input("Summon who?", "", text) in list ("Players","Monsters","Both","Cancel",))
				if("Players") for(var/mob/Players/M)  M.loc=locate(x+rand(-10,10),y+rand(-10,10),z)
				if("Monsters") for(var/mob/M) if(!M.client) M.loc=locate(x+rand(-10,10),y+rand(-10,10),z)
				if("Both") for(var/mob/M) M.loc=locate(x,y,z)

	DeleteSave(mob/Players/M in players)
		set category="Admin"
		switch(input(usr,"Delete [M]'s save?") in list("No","Yes"))
			if("Yes")
				var/reason=input("For what reason?") as text
				M.Savable=0
				if(istype(M, /mob/Players))
					fdel("Saves/Players/[M.ckey]")
				Log("Admin","<font color=blue>[ExtractInfo(usr)] SAVE DELETED [ExtractInfo(M)] for [reason].")
				del(M)

	Shutdown()
		set category="Admin"
		if(Alert("You sure you want to shutdown the server?"))
			sleep(1)
			for(var/mob/Players/Q in players)
				if(Q.Savable)
					Q.client.SaveChar()
			BootWorld("Save")
			Log("Admin","<font color=blue>[ExtractInfo(usr)] is shutting down the server in 60 seconds.")
			world<<"<font size=2><font color=#FFFF00>Shutting down in 60 seconds. Please stop all actions at this time."
			sleep(600)
			world<<"we get past it all"
			world<<"SNARE IS CURRENTLY 0"
			shutdown()

	SaveWorld()
		set category="Admin"
		BootWorld("Save")
		for(var/mob/Players/Q in players)
			if(Q.Savable)
				Q.client.SaveChar()

	SaveTurfsObjs()
		set category="Admin"
		spawn() find_savableObjects()
		spawn() Save_Turfs()
		spawn() Save_Objects()
		Log("Admin","<font color=blue>[ExtractInfo(usr)] has saved turfs and objects in world.")
	Set_Base()
		set category="Admin"
		var/NewBase=input(usr,"Set base battle power to what?  Currently [Commas(glob.WorldBaseAmount)]") as num
		glob.WorldBaseAmount=NewBase
		for(var/mob/Players/P in players)
			P.Base=glob.WorldBaseAmount
		Log("Admin","[ExtractInfo(usr)] set EVERYONE to [NewBase](*BPM)")


	SetGetUpSpeed()
		set category="Admin"
		var/Speedz=input("Current: [glob.GetUpVar]x") as null|num
		if(Speedz)
			glob.GetUpVar=Speedz
			Log("Admin","<font color=blue>[ExtractInfo(usr)] adjusted the GetUpVar to [Speedz]x.")

mob/Admin4/verb
	Push_Forward()
		set category = "Admin"
		glob.progress.WipeStart -= 24 HOURS
		DaysOfWipe()
		Log("Admin", "[ExtractInfo(src)] pushed the wipe forward by 24 hours.")

	Wipe_Start()
		set category="Admin"
		switch(alert(usr, "Are you sure you want to set the start time of the wipe to midnight today?", "Are you sure you want to suffer through another wipe?", "No", "Hell No", "I guess"))
			if("No")
				return
			if("Hell No")
				return
		glob.progress.DaysOfWipe=0
		glob.progress.WipeStart=world.realtime-world.timeofday
		Log("Admin", "[ExtractInfo(src)] has set the official start date of the wipe.")
	Wipe_Restart()
		set category="Admin"
		var/val=input(src, "What day of the wipe are you currently on?", "Wipe Restart") as num|null
		if(val&&val>0)
			glob.progress.DaysOfWipe=0
			glob.progress.WipeStart=Today()-Day(val)
			Log("Admin", "[ExtractInfo(src)] has reset the official wipe start date. It is now day [val] of the wipe.")
	Potential_Daily_Set()
		set category="Admin"
		var/val=input(src, "How much potential is gained daily?", "Potential Daily") as num|null
		if(val&&val>0)
			glob.progress.PotentialDaily=val
			Log("Admin", "[ExtractInfo(src)] has set the daily potential rate to [glob.progress.PotentialDaily].")
	Era_Set(var/val as num)
		set category="Admin"
		glob.progress.Era=val
		Log("Admin", "[ExtractInfo(src)] set the Era to [glob.progress.Era].")
	RPP_Limit_Set(var/val as num)
		glob.progress.RPPLimit = val
	RPP_Base_Mult_Set(var/val as num)
		set category="Admin"
		glob.progress.RPPBaseMult=val
		Log("Admin", "[ExtractInfo(src)] set the RPP Base Mult to [glob.progress.RPPBaseMult]x.")
	RPP_Daily_Set(var/val as num)
		set category="Admin"
		glob.progress.RPPDaily=val
		Log("Admin", "[ExtractInfo(src)] set the daily RPP increment to [Commas(glob.progress.RPPDaily)].")
	Rename_Money()
		set category="Admin"
		var/NewMoney=input(usr, "What should money be called?  Currently known as: [glob.progress.MoneyName]", "Rename Money") as text|null
		if(NewMoney)
			Log("Admin", "[ExtractInfo(usr)] renamed the currency from [glob.progress.MoneyName] to [NewMoney].")
			glob.progress.MoneyName=NewMoney
	Common_Toggle()
		set category="Admin"
		var/list/Races=list("Cancel", "Half Saiyan", "Elite", "Giant", "Shinjin", "Demon", "Majin", "Dragon", "Makyo", "Changeling")
		var/Mode=alert(usr, "You can set a normally rare race to be common, or strip that same status with this verb.  Which do you want to do?", "Common Toggle", "Make Common", "Make Rare")
		if(Mode=="Make Common")
			var/list/Choices=Races
			for(var/x in Choices)
				if(x in glob.CustomCommons)
					Races.Remove(x)
			var/Choice=input(usr, "Which rare do you want to designate as common?", "Make Common") in Races
			if(Choice!="Cancel")
				var/Confirm=alert(usr, "Are you sure you want to make [Choice] common?", "Make Common", "Yes", "No")
				if(Confirm=="Yes")
					glob.CustomCommons.Add(Choice)
					Log("Admin", "[ExtractInfo(usr)] made [Choice] common!")
		else if(Mode=="Make Rare")
			var/list/Choices=list()
			for(var/x in glob.CustomCommons)
				Choices.Add(x)
			var/Choice=input(usr, "Which rare do you want to strip common status from?", "Make Rare") in Choices
			if(Choice!="Cancel")
				var/Confirm=alert(usr, "Are you sure you want to make [Choice] rare again?", "Make Rare", "Yes", "No")
				if(Confirm=="Yes")
					glob.CustomCommons.Remove(Choice)
					Log("Admin", "[ExtractInfo(usr)] made [Choice] rare again!")
	NoVoid(var/mob/m in players)
		set hidden=1
		if(m.NoVoid)
			m.NoVoid=0
			usr << "You let [m] void again..."
			return
		m.NoVoid=1
		usr << "[m] is not gonna void anymore."
	SetVoidChance()
		set category="Admin"
		var/m=input(src, "What do you want to set Void Chance to? (currently [glob.VoidChance]%)", "Void Chance") as num
		glob.VoidChance=m
		world << "<font color='green'>Void Chance set to [m]%!</font color>"
		Log("Admin", "[ExtractInfo(src)] set Void Chance to [m]%!")
	ToggleVoid()
		set category="Admin"
		if(glob.VoidsAllowed)
			glob.VoidsAllowed=0
			world << "<font color='red'>Voiding from death has been disabled.</font>"
		else
			glob.VoidsAllowed=1
			world << "<font color='green'>Voiding from death has been enabled.</font>"
	ChangeVoidLocation()
		set category = "Admin"
		var/x = input(usr, "X for void?") as num|null
		var/y = input(usr, "Y for void?") as num|null
		var/z = input(usr, "Z for void?") as num|null
		if(!x || !y || !z) return
		glob.VOID_LOCATION = list(x,y,z)
mob/Admin3/verb

	SetGlobalDamage()
		set category="Admin"
		set name = "Set global "
		var/m=input(src, "What do you want to set the global damage multiplier to? (currently x[glob.WorldDamageMult])", "World Damage Multiplier") as num
		glob.WorldDamageMult=m
		Log("Admin", "[ExtractInfo(src)] set Global Damage Mult to [m]!")
	SetDefaultAccuracy()
		set category="Admin"
		set name = "World Accuracy"
		var/m=input(src, "What do you want to set the default accuracy to? (currently [glob.WorldDefaultAcc]%)", "World Default Accuracy") as num
		glob.WorldDefaultAcc=m
		Log("Admin", "[ExtractInfo(src)] set default accuracy to [m]%!")
	SetWhiffRate()
		set category="Admin"
		set name = "Whiff Rate"
		var/m=input(src, "What do you want the amount of full-powered strikes to be? (currently [glob.WorldWhiffRate]%)", "World Whiff Rate") as num
		glob.WorldWhiffRate=m
		Log("Admin", "[ExtractInfo(src)] set whiff rate to [m]%!")

	SetCCDamageMod()
		set category="Admin"
		set name = "CC Damage Modifier"
		var/m=input(src, "What do you want the damage reduction on damage while stunned/launched to be? (currently [glob.CCDamageModifier]x)", "CC Damage Modifier") as num
		glob.CCDamageModifier=m
		Log("Admin", "[ExtractInfo(src)] set CC Damage Modifier to [m]x!")


	SetItemAscensionScaling()
		set category="Admin"
		set name = "Item Ascension Scaling"
		var/m=input(src, "What do you want to adjust?(0.05 = 5% 'better') \n\n Staff: \nDamage per Ascension:[glob.StaffAscDamage]\nAccuracy per Ascension: [glob.StaffAscAcc]\nDrain per Ascension: [glob.StaffAscDelay]\n\nSword: \nDamage per Ascension:[glob.SwordAscDamage]\nAccuracy per Ascension: [glob.SwordAscAcc]\nDelay per Ascension: [glob.SwordAscDelay]\n\nArmor: \nDamage Reduc per Ascension:[glob.ArmorAscDamage]\nAccuracy per Ascension: [glob.ArmorAscAcc]\nDrain per Ascension: [glob.ArmorAscDelay]", "Item Ascension Scaling") in list("Staff","Sword","Armor", "Cancel")
		var/changing
		switch(m)
			if("Staff")
				changing=input(src, "What do you want to adjust?(0.05 = 5% increase) \n\n Staff: \nDamage per Ascension:[glob.StaffAscDamage]\nAccuracy per Ascension: [glob.StaffAscAcc]\nDrain per Ascension: [glob.StaffAscDelay]", "Item Ascension Scaling") in list("Damage", "Accuracy", "Drain", "Cancel")
			if("Armor")
				changing=input(src, "What do you want to adjust?(0.05 = 5% increase) \n\n Armor: \nDamage per Ascension:[glob.ArmorAscDamage]\nAccuracy per Ascension: [glob.ArmorAscAcc]\nDrain per Ascension: [glob.ArmorAscDelay]", "Item Ascension Scaling") in list("Damage", "Accuracy", "Drain", "Cancel")
			if("Sword")
				changing=input(src, "What do you want to adjust?(0.05 = 5% increase) \n\n Sword: \nDamage per Ascension:[glob.SwordAscDamage]\nAccuracy per Ascension: [glob.SwordAscAcc]\nDelay per Ascension: [glob.SwordAscDelay]", "Item Ascension Scaling") in list("Damage", "Accuracy", "Delay", "Cancel")
			if("Cancel")
				return
		if(changing=="Cancel") return
		var/changeto = input(src, "What do you want to change [m]'s [changing] ascension scaling to?") as num|null
		if(changeto == null) return
		switch(m)
			if("Staff")
				switch(changing)
					if("Damage")
						glob.StaffAscDamage = changeto
					if("Accuracy")
						glob.StaffAscAcc = changeto
					if("Drain")
						glob.StaffAscDelay = changeto
			if("Armor")
				switch(changing)
					if("Damage")
						glob.ArmorAscDamage = changeto
					if("Accuracy")
						glob.ArmorAscAcc = changeto
					if("Drain")
						glob.ArmorAscDelay = changeto
			if("Sword")
				switch(changing)
					if("Damage")
						glob.SwordAscDamage = changeto
					if("Accuracy")
						glob.SwordAscAcc = changeto
					if("Delay")
						glob.SwordAscDelay = changeto

		Log("Admin", "[ExtractInfo(src)] set [m]'s [y] to [changeto] increase per ascension!")


	// Nox_Claim()
	// 	set category="Admin"
	// 	var/list/Noxes=list("Cancel", "Yukianesa", "Bolverk", "Ookami")
	// 	var/Choice=input(usr, "Which Nox Nyctores are you toggling the status of?", "Nox Claim") in Noxes
	// 	switch(Choice)
	// 		if("Yukianesa")
	// 			if(global.YukianesaMade)
	// 				global.YukianesaMade=0
	// 				Log("Admin", "[ExtractInfo(usr)] toggled the status of [Choice] (<font color='green'>Not Made</font color>).")
	// 			else
	// 				global.YukianesaMade=1
	// 				Log("Admin", "[ExtractInfo(usr)] toggled the status of [Choice] (<font color='red'>Made</font color>).")
	// 		if("Bolverk")
	// 			if(global.BolverkMade)
	// 				global.BolverkMade=0
	// 				Log("Admin", "[ExtractInfo(usr)] toggled the status of [Choice] (<font color='green'>Not Made</font color>).")
	// 			else
	// 				global.BolverkMade=1
	// 				Log("Admin", "[ExtractInfo(usr)] toggled the status of [Choice] (<font color='red'>Made</font color>).")
	// 		if("Ookami")
	// 			if(global.OokamiMade)
	// 				global.OokamiMade=0
	// 				Log("Admin", "[ExtractInfo(usr)] toggled the status of [Choice] (<font color='green'>Not Made</font color>).")
	// 			else
	// 				global.OokamiMade=1
	// 				Log("Admin", "[ExtractInfo(usr)] toggled the status of [Choice] (<font color='red'>Made</font color>).")

	moon_toggle_admin(var/Z as num)
		set category="Admin"
		CallMoon(Z)
		Log("Admin", "[ExtractInfo(src)] forced the moon to shine for z-plane ([Z]).")
	Moon_Message()
		set category="Admin"
		var/NewMsg=input(usr, "What do you want to make the new moon message?", "Moon Message", global.MoonMessage) as message|null
		if(!NewMsg&&NewMsg==null)
			return
		global.MoonMessage=NewMsg
		Log("Admin", "[ExtractInfo(usr)] made the moon message: ([global.MoonMessage])")
		var/NewSetMsg=input(usr, "What do you want to make the new moon setting message?", "Moon Set Message", global.MoonSetMessage) as message|null
		if(!NewSetMsg&&NewSetMsg==null)
			return
		global.MoonSetMessage=NewSetMsg
		Log("Admin", "[ExtractInfo(usr)] made the moon setting message: ([global.MoonSetMessage])")
	Makyo_Toggle(var/Z as num)
		set category="Admin"
		CallStar(Z)
		Log("Admin", "[ExtractInfo(src)] forced the Makyo Star to shine for z-plane ([Z]).")
	Makyo_Message()
		set category="Admin"
		var/NewMsg=input(usr, "What do you want to make the new Star arrival message?", "Star Arrival", global.MakyoMessage) as message|null
		if(!NewMsg&&NewMsg==null)
			return
		global.MakyoMessage=NewMsg
		Log("Admin", "[ExtractInfo(usr)] made the Star arrival message: ([global.MakyoMessage])")
		var/NewSetMsg=input(usr, "What do you want to make the new Star departure message?", "Star Departure", global.MakyoSetMessage) as message|null
		if(!NewSetMsg&&NewSetMsg==null)
			return
		global.MakyoSetMessage=NewSetMsg
		Log("Admin", "[ExtractInfo(usr)] made the Star departure message: ([global.MakyoSetMessage])")


	AdminLogz()
		set hidden=1
		usr.SegmentLogs("Saves/AdminLogz/Log")
	SetWorldPUDrain()
		set category="Admin"
		var/Speedz=input("Current: [glob.WorldPUDrain]x") as null|num
		if(Speedz)
			glob.WorldPUDrain=Speedz
			Log("Admin","<font color=blue>[ExtractInfo(usr)] ajusted the WorldPUDrain to [glob.WorldPUDrain].")


	ManuallyRemoveAdmin(var/x as text)
		set category="Admin"
		if(Admins)
			if(Admins.Find(x))
				Admins.Remove(x)

	TickLag()
		set category="Admin"
		var/Speedz=input("Current Tick Lag [world.tick_lag]") as null|num
		if(Speedz)
			world.tick_lag=Speedz
			Log("Admin","<font color=blue>[ExtractInfo(usr)] adjusted the Tick Lag to [Speedz]%.")

mob/Admin4/verb
	PlayerLoginLogs()
		set category="Admin"
		var/list/files=new
		for(var/File in flist("Saves/LoginLogs/"))
			files.Add(File)
		files.Add("Cancel")
		var/lawl=input("What one do you want to read?","Rebirth") in files
		if(lawl=="Cancel")
			return
		var/ISF=file2text(file("Saves/LoginLogs/[lawl]"))
		var/View={"<html><head><title>Logs</title><body>
				<font size=3><font color=red>[lawl]<hr><font size=2><font color=black>"}
		View+=ISF
		View += "</html>"
		src<<browse(View,"window=Log;size=500x300")

	DownloadSaves()
		set category="Admin"
		usr << ftp("Saves/Players/")

datum/Topic(A, B[])
	if (B["action"] == "edit")
		if (!usr.Admin && !usr.Mapper && !glob.TESTER_MODE)
			return

		var/variable = B["var"]
		if (!variable || variable == "Admin") return

		var/class
		var/list/options = list("Number", "Text", "File", "Null")
		if(usr.Admin)
			options += list("Type", "Reference", "List", "New Matrix", "Color Matrix", "New Type")
		if(istype(src, /datum))
			options += "Open Edit Sheet"
		class = input("[variable]: Select type", "") as null|anything in options
		if (!class) return
		if(class == "Open Edit Sheet")
			usr:Edit(src)
			return
		var/old_value = vars[variable]
		if (class == "Null")
			if(!isnull(vars[variable]))
				var/confirm = input("This variable is currently NOT null. Continue?") in list("No", "Yes")
				if (confirm == "No") return
			vars[variable] = null
		else if (class == "Text")
			if (isnum(vars[variable]))
				var/confirm = input("This variable is currently a number. Continue?") in list("No", "Yes")
				if (confirm == "No") return
			vars[variable] = input("Enter text", "", vars[variable]) as text
		else if (class == "Number")
			if(!isnum(vars[variable]))
				var/confirm = input("This variable is currently not a number. Continue?") in list("No", "Yes")
				if (confirm == "No") return
			vars[variable] = input("Enter number", "", vars[variable]) as num
		else if (class == "File")
			vars[variable] = input("Select file", "", vars[variable]) as file
		else if (class == "Type")
			vars[variable] = input("Enter type", "Type", vars[variable]) in typesof(/atom)
		else if (class == "Reference")
			vars[variable] = input("Select reference", "Reference", vars[variable]) as mob|obj|turf|area in world
		else if (class == "List")
			var/list/l = vars[variable]
			if (!istype(l, /list))
				if (input("Convert [variable] to a list?") in list("No", "Yes") == "Yes")
					l = new
					vars[variable] = l
				else return
			usr.list_view(l, "[variable]")
		else if (class == "New Matrix")
			if (input("Set [variable] as a new matrix? (a-f components)") in list("Yes", "No") == "Yes")
				vars[variable] = matrix(
					input("a") as num, input("b") as num, input("c") as num,
					input("d") as num, input("e") as num, input("f") as num
				)
		else if (class == "Color Matrix")
			var/mode = input("Set [variable] as a color matrix?") in list("RGB-Only", "RGBA", "Cancel")
			if (mode == "RGB-Only")
				vars[variable] = list(
					input("rr") as num, input("rg") as num, input("rb") as num,
					input("gr") as num, input("gg") as num, input("gb") as num,
					input("br") as num, input("bg") as num, input("bb") as num,
					input("cr") as num, input("cg") as num, input("cb") as num
				)
			else if (mode == "RGBA")
				vars[variable] = list(
					input("rr") as num, input("rg") as num, input("rb") as num, input("ra") as num,
					input("gr") as num, input("gg") as num, input("gb") as num, input("ga") as num,
					input("br") as num, input("bg") as num, input("bb") as num, input("ba") as num,
					input("ar") as num, input("ag") as num, input("ab") as num, input("aa") as num,
					input("cr") as num, input("cg") as num, input("cb") as num, input("ca") as num
				)
		else if (class == "New Type")
			vars[variable] = new (input("Enter type:", "Type", vars[variable]) in typesof(/datum))

		if (vars[variable] != old_value)
			Log("Admin", "[ExtractInfo(usr)] EDITED [variable] to [vars[variable]] on [ExtractInfo(src)] (was [old_value]).")
		usr:Edit(src)

	else if (B["action"] == "companionskill")
		if (usr.Admin < 1) return
		var/variable = B["var"]
		if (input("Give [variable]?") in list("Yes", "No") == "Yes" && istype(src, /obj/Skills/Companion))
			var/obj/Skills/Companion/c = src
			c.companion_techniques += "[variable]"
			Log("Admin", "[ExtractInfo(usr)] created a [variable] and assigned it to [ExtractInfo(src)].")

	.=..()



atom/Topic(A,B[])/*
	if(B["action"]=="edit")
		if(!usr.Admin&&!usr.Mapper)
			if(!glob.TESTER_MODE)
				return
		var/variable=B["var"]
		var/oldvariable=vars[variable]
		var/class
		if(usr.Mapper && !usr.Admin)
			class=input("[variable]","") as null|anything in list("Number","Text","File","Null")
		else if(usr.Admin || glob.TESTER_MODE)
			class=input("[variable]","") as null|anything in list("Number","Text","File","Type","Reference","Null","List","New Matrix","Color Matrix", "New Type")
		if(!class) return
		if(variable=="Admin")
			return
		switch(class)
			if("Null") vars[variable]=null
			if("Text")
				if(isnum(vars[variable]))
					var/confirm=input("This variable is currently a number and probably shouldn't be text. Continue anyways?") in list("No","Yes")
					if(confirm=="No")
						return
				vars[variable]=input("","",vars[variable]) as message
			if("Number")
				vars[variable]=input("","",vars[variable]) as num
			if("File") vars[variable]=input("","",vars[variable]) as file
			if("Type")
				vars[variable] = input("Enter type:","Type",vars[variable]) in typesof(/atom)
			if("Reference")
				vars[variable] = input("Select reference:","Reference", vars[variable]) as mob|obj|turf|area in world
			if("List")
				var/list/l = vars[variable]
				if(!istype(l, /list))
					switch(input("Would you like to set [variable] as a list?") in list("Yes","No"))
						if("Yes")
							l = new
							vars[variable]=l
						if("No") return
				usr.list_view(l,"[variable]")
			if("New Matrix")
				switch(input("Are you sure you would like to set [variable] as a new matrix? a - f components") in list("Yes","No"))
					if("Yes")
						var/matrix/m = matrix(
							input("a") as num,\
							input("b") as num,\
							input("c") as num,\
							input("d") as num,\
							input("e") as num,\
							input("f") as num\
						)
						vars[variable] = m
			if("New Type")
				var/datum/d = input("Enter type:","Type",vars[variable]) in typesof(/datum)
				vars[variable] = new d
			if("Color Matrix")
				switch(input("Are you sure you would like to set [variable] as a new color matrix?") in list("RGB-Only","RGBA","Cancel"))
					if("RGB-Only")
						var/list/l = list(
							input("rr") as num,\
							input("rg") as num,\
							input("rb") as num,\
							input("gr") as num,\
							input("gg") as num,\
							input("gb") as num,\
							input("br") as num,\
							input("bg") as num,\
							input("bb") as num,\
							input("cr") as num,\
							input("cg") as num,\
							input("cb") as num\
						)
						vars[variable]=l
					if("RGBA")
						var/list/l = list(
							input("rr") as num,\
							input("rg") as num,\
							input("rb") as num,\
							input("ra") as num,\
							input("gr") as num,\
							input("gg") as num,\
							input("gb") as num,\
							input("ga") as num,\
							input("br") as num,\
							input("bg") as num,\
							input("bb") as num,\
							input("ba") as num,\
							input("ar") as num,\
							input("ag") as num,\
							input("ab") as num,\
							input("aa") as num,\
							input("cr") as num,\
							input("cg") as num,\
							input("cb") as num,\
							input("ca") as num\
						)
						vars[variable]=l

		if(class!="View List")

			Log("Admin","[ExtractInfo(usr)] EDITED [variable] to [vars[variable]] on [ExtractInfo(src)] from [oldvariable].")
		usr:Edit(src)*/
	if(B["action"]=="companionskill")
		if(usr.Admin<1) return
		var/variable=B["var"]
		switch(input("Give [variable]?") in list("Yes","No"))
			if("No") return
			if("Yes")
				if(istype(src, /obj/Skills/Companion))
					var/obj/Skills/Companion/c = src
					c.companion_techniques += "[variable]"
					Log("Admin","[ExtractInfo(usr)] created a [variable], and gave to/placed under/near [ExtractInfo(src)].")
	if(B["action"]=="magic")
		if(usr.Admin<1 && !glob.TESTER_MODE) return

		var/MagicX
		var/MagicY
		var/MagicZ
		var/variable=B["var"]
		var/class=input("[variable]","") as null|anything in list("Give To","Make Under","Independant XYZ","Cancel")
		if(class=="Cancel"||class==null||!class)
			return
		switch(class)
			if("Give To")
				src.contents+=new variable
				if(istype(variable, /obj/Skills))
					var/mob/m = src
					if(istype(variable, /obj/Skills/Queue))
						m.Queues.Add(variable)
					else if(istype(variable, /obj/Skills/AutoHit))
						m.AutoHits.Add(variable)
					else if(istype(variable, /obj/Skills/Projectile))
						m.Projectiles.Add(variable)
					else if(istype(variable, /obj/Skills/Buffs)) //IS TYPE DOESNT DO CHILDREN KILLS NIEZAN
						m.Buffs.Add(variable)
					m.Skills.Add(variable)
			if("Make Under")
				var/XYZMode=input("Would you like to place this object relative to the person it's being placed under?","") as null|anything in list("Yes","No")
				switch(XYZMode)
					if("No")
						new variable(src.loc)
					if("Yes")
						MagicX=input("Input Relative X.") as num
						MagicY=input("Input Relative Y.") as num
						var/RelativeX=(src.x+MagicX)
						var/RelativeY=(src.y+MagicY)
						new variable(locate(RelativeX,RelativeY,src.z))
			if("Independant XYZ")
				MagicX=input("Input X.") as num
				MagicY=input("Input Y.") as num
				MagicZ=input("Input Z.") as num
				new variable(locate(MagicX,MagicY,MagicZ))
		Log("Admin","[ExtractInfo(usr)] created a [variable], and gave to/placed under/near [ExtractInfo(src)].")
	.=..()
mob/Topic(href,href_list[])
	if(Admin)
		switch(href_list["action"])
			if("listview")
				if(!Admin) return
				list_view(locate(href_list["list"]),href_list["title"])
			if("listedit")
				if(!Admin) return
				var/list/theList = locate(href_list["list"])
				var/title = href_list["title"]
				var/old_index = text2num(href_list["value"])
				switch(href_list["part"])
					if("indexnum")
						var/new_index = input("Enter new index") as num
						if(new_index <= 0 || new_index==old_index || new_index > length(theList)) return
						var/original_key = theList[old_index]
						var/original_value = theList[original_key]
						var/next = old_index<new_index?1:-1 //Either going forward or backward
						for(var/i = old_index, i!=new_index, i+= next)
							var/new_key = theList[i+next]
							var/new_value = theList[new_key]
							theList[i] = new_key
							theList[i+next] = null //So that there aren't two identical keys in the list
							theList[new_key] = new_value
						theList[new_index] = original_key
						theList[original_key] = original_value
					if("key")
						var/old_value = theList[theList[old_index]]
						var/list/options = list("text","num","type","reference","icon","file","list","restore to default")
						try
							if(istype(theList[old_index], /datum))
								options += "Open Edit Sheet"
						catch()
						var/class = input(usr,"Change [theList[old_index]] to what?","Variable Type") as null|anything \
							in options
						if(!class) return

						switch(class)
							if("restore to default")
								theList[old_index] = initial(theList[old_index])
							if("text")
								theList[old_index] = input("Enter new text:","Text",theList[old_index]) as text
							if("num")
								theList[old_index] = input("Enter new number:","Num",theList[old_index]) as num
							if("type")
								theList[old_index] = input("Enter type:","Type",theList[old_index]) \
									in typesof(/atom)
							if("reference")
								theList[old_index] = input("Select reference:","Reference", \
									theList[old_index]) as mob|obj|turf|area in world
							if("file")
								theList[old_index] = input("Pick file:","File",theList[old_index]) \
									as file
							if("icon")
								theList[old_index] = input("Pick icon:","Icon",theList[old_index]) \
									as icon
							if("list")
								var/l = list()
								theList[old_index] = l
								usr.list_view(l,"[title]\[[old_index]]")
							if("true")
								theList[old_index] = 1
							if("false")
								theList[old_index] = null
							if("Open Edit Sheet")
								usr:Edit(theList[old_index])
						theList[theList[old_index]] = old_value
					if("value")
						var/old_key = theList[old_index]
						var/list/options = list("text","num","type","reference","icon","file","list","restore to default")
						try
							if(isdatum(theList[old_index]))
								if(theList[old_index]?:type)
									options += "Open Edit Sheet"
						catch()
						var/class = input(usr,"Change [theList[old_index]] to what?","Variable Type") as null|anything \
							in options
						if(!class) return
						switch(class)

							if("restore to default")
								theList[old_key] = initial(theList[old_key])
							if("text")
								theList[old_key] = input("Enter new text:","Text",theList[old_key]) as text
							if("num")
								theList[old_key] = input("Enter new number:","Num",theList[old_key]) as num
							if("type")
								theList[old_key] = input("Enter type:","Type",theList[old_key]) \
									in typesof(/atom)
							if("reference")
								theList[old_key] = input("Select reference:","Reference", \
									theList[old_key]) as mob|obj|turf|area in world
							if("file")
								theList[old_key] = input("Pick file:","File",theList[old_key]) \
									as file
							if("icon")
								theList[old_key] = input("Pick icon:","Icon",theList[old_key]) \
									as icon
							if("list")
								var/l = list()
								theList[old_key] = l
								usr.list_view(l,"[title]\[[old_key]]")
							if("true")
								theList[old_key] = 1
							if("false")
								theList[old_key] = null
							if("Open Edit Sheet")
								usr:Edit(theList[old_key])
					if("add")
						theList += null
					if("delete")
						theList -= theList[old_index]

				usr.list_view(theList,title)
	.=..()
proc/Value(A)
	if(isnull(A)) return "Nothing"
	else if(isnum(A)) return "[num2text(round(A,0.01),20)]"
	else return "[A]"

mob/proc/list_view(aList,title)
	if(!aList || !IsList(aList))
		return//CRASH("List null or incorrect type")
	if(!Admin) return
	var/html = {"<html><body bgcolor=gray text=#CCCCCC link=white vlink=white alink=white>
	[title]
	<table><tr><td><u>Index #</u></td><td><u>Index</u></td><td><u>Value</u></td><td><u>Delete</u></td></tr>"}
	for(var/i=1,i<=length(aList),i++)
		#define LISTEDIT_LINK "href=byond://?src=\ref[src];title=[title];action=listedit;list=\ref[aList]"
		html += "<tr><td><a [LISTEDIT_LINK];part=indexnum;value=[i]>[i]</a></td>"
		html += "<td><a [LISTEDIT_LINK];part=key;value=[i]>[aList[i]]([DetermineVarType(aList[i])][AddListLink(aList[i],title,i)])</td>"
		html += "<td><a [LISTEDIT_LINK];part=value;value=[i]>[aList[aList[i]]]([DetermineVarType(aList[aList[i]])][AddListLink(aList[aList[i]],title,i)])</a></td>"
		html += "<td><a [LISTEDIT_LINK];part=delete;value=[i]><font color=red>X</font></a></td></tr>"
	html += "</table><br><br><a [LISTEDIT_LINK];part=add>\[Add]</a></body></html>"
	if(title)
		src << browse(html,"window=[title]")
	else
		src << browse(html)
mob/proc/AddListLink(variable,listname,index)
	if(!Admin) return
	if(IsList(variable))
		return "<a href=byond://?src=\ref[src];action=listview;list=\ref[variable];title=[listname]\[[index]]><font color=red>(V)</font></a>"

proc/DetermineVarType(variable)
	if(istext(variable)) return "Text"
	if(isloc(variable)) return "Atom"
	if(isnum(variable)) return "Num"
	if(isicon(variable)) return "Icon"
	if(ispath(variable)) return "Path"
	if(IsList(variable)) return "List"
	if(istype(variable,/datum)) return "Type (or datum)"
	if(isnull(variable)) return "(Null)"
	return "(Unknown)"