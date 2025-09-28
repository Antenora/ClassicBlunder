

mob/proc/Controlz(mob/M)
	if(src.Admin)
		return "(<a href=?src=\ref[M];action=MasterControl>x</a href>)"

var/Allow_OOC=1

mob/proc/checkInvisibilityBreaking()
	if(CheckSlotless("Camouflage"))
		var/obj/Skills/Buffs/SlotlessBuffs/Camouflage/C = GetSlotless("Camouflage")
		if(C.Invisible)
			C.Trigger(src)
		src << "Your camouflage is broken!"
	if(CheckSlotless("Invisibility"))
		var/obj/Skills/Buffs/SlotlessBuffs/Magic/Magic_Show/I = GetSlotless("Magic Show")
		if(I.Invisible)
			I.Trigger(src)
		src << "You reveal yourself!"

mob/proc/CheckAFK()
	if(AFKTimer==0)
		overlays -= AFKIcon

	AFKTimer = AFKTimeLimit

mob/var/ShowOOC = TRUE
mob/var/LOOCinIC = FALSE
mob/var/AllTabOOC = TRUE
mob/var/LOOCinAll = TRUE
Options/var/ShowOOC = TRUE
Options/var/LOOCinIC = FALSE
Options/var/AllTabOOC = TRUE
Options/var/LOOCinAll = TRUE
Options/var/AdminAlerts = TRUE

client/proc/outputToChat(text, list/channels)
	if(!src) return
	for(var/channel as anything in channels)
		src << output(text, channel)

client/verb/Toggle_Channels()
	set category="Other"
	var/selection=input("Select a toggle option.")in list("Toggle OOC","Toggle All Tab OOC","Toggle IC Tab LOOC","Toggle All Tab LOOC")
	switch(selection)
		if("Toggle OOC")
			togglePref("ShowOOC")
			usr << "You turn your OOC [getPref("ShowOOC") ? "<font color=green>on</font color>." : "<font color=red>off</font color>."]"
		if("Toggle All Tab OOC")
			togglePref("AllTabOOC")
			usr << "OOC messages will[getPref("AllTabOOC") ? "" : " not"] display in the All tab."
		if("Toggle IC Tab LOOC")
			togglePref("LOOCinIC")
			usr << "LOOC messages will[getPref("LOOCinIC") ? "" : " not"] display in the IC tab."
		if("Toggle All Tab LOOC")
			togglePref("LOOCinAll")
			usr << "LOOC messages will[getPref("LOOCinAll") ? "" : " not"] display in the All tab."

client/verb/OOC(T as text)
	set category = "Other"
	if(!T||length(T)<1) return
	if(!OOC_Check(T)) return
	if(!usr.Admin) T=copytext(T,1,700)
	if(SpamCheck(usr,T))return

	var/keyjack=usr.key
	if(usr.DisplayKey)
		keyjack=usr.DisplayKey

	var/timestamp = "<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")]</font>"
	var/OOCHeader = "<font color=lime><b>OOC:</b><font color=[usr.OOC_Color]> <b>[keyjack]</b>"
	var/timestampOOCHeader = "[timestamp][OOCHeader]"
	var/finalMessage = ": <font color=white>[html_encode(T)]"

	for(var/mob/Players/P in players)
		if(!P.client) continue
		if(!P.client.getPref("ShowOOC")) continue

		if(P.Timestamp)
			if(P.client.getPref("AllTabOOC"))
				P << output("[timestampOOCHeader][P.Controlz(usr)][finalMessage]", "output")
			P << output("[timestampOOCHeader][P.Controlz(usr)][finalMessage]", "oocchat")
		else
			if(P.client.getPref("AllTabOOC"))
				P << output("[OOCHeader][P.Controlz(usr)][finalMessage]", "output")
			P << output("[OOCHeader][P.Controlz(usr)][finalMessage]", "oocchat")

client/verb/Say(T as text)
	set category="Roleplay"

	sayProc(T, null)

client/proc/sayProc(T, mode = null)
	if(!T||length(T)<1) return

	usr.checkInvisibilityBreaking()

	T = usr.redactBannedWords(T)

	var/radius = SAY_RADIUS
	var/sayNoun = "says:"

	if(findtext(T,LOOCRegex))
		sayNoun = "LOOCs:"
	else if(findtext(T, whisperSlashRegex))
		T = replacetext(T, whisperSlashRegex, "")
		Whisper(T)
		return
	else if(findtext(T,yellRegex)||mode==YELL||findtext(T,yellSlashRegex))
		radius = YELL_RADIUS
		sayNoun = pick(YELL_NOUNS)
		if(findtext(T,yellSlashRegex))
			T = replacetext(T, yellSlashRegex, "")
	else if(findtext(T,questionRegex))
		sayNoun = pick(QUESTION_NOUNS)

	if(sayNoun != "LOOCs:")
		if(usr.SenseRobbed >= 3)
			T="---"

	var/list/transmitTo = hearers(radius,usr)
	var/header = "<font color=[usr.Text_Color]>[usr.name]"
	var/message = "[html_encode(T)]"
	var/broadcastMessage = "[usr.name]: [message]"

	if(radius == YELL_RADIUS)
		message = "<b>[message]</b>"

	for(var/mob/hearer as anything in transmitTo) //hearers always returns a list of mobs; free performance.
		if(!hearer.client) continue
		if(!hearer.Admin && sayNoun != "LOOCs:" && hearer.Mapper && hearer.invisibility) continue
		if(sayNoun == "LOOCs:")
			hearer?.client.outputToChat("[header][hearer.Controlz(usr)] [sayNoun] [message]", LOOC_OUTPUT)
		else
			if(hearer.SenseRobbed<4)
				hearer?.client.outputToChat("[header][hearer.Controlz(usr)] [sayNoun] [message]", IC_OUTPUT)

		Log(hearer.ChatLog(),"<font color=green>[usr.name]([usr.key]) [sayNoun] [message]")
		Log(hearer.sanitizedChatLog(),"<font color=green>[usr.name] [sayNoun] [message]")

		if(hearer.BeingObserved.len>0)
			for(var/mob/m as anything in hearer.BeingObserved)
				m?.client.outputToChat("[OBSERVE_HEADER][header][m.Controlz(usr)] [sayNoun] [message]", IC_OUTPUT)

		for(var/obj/Items/Tech/Planted_Wiretap/WT in hearer)
			WT.broadcastToListeners(broadcastMessage)

	for(var/obj/Items/Tech/Security_Camera/F in view(11,usr)) //This for loop detects Security Cameras around those that use the say verb.
		F.broadcastToListeners(broadcastMessage)

	usr.Say_Spark()
	usr.CheckAFK()

client/verb/Yell(T as text)
	set category="Roleplay"
	set hidden = 1

	sayProc(T, YELL)

client/verb/Whisper(T as text)
	set category="Roleplay"

	var/list/transmitTo = hearers(SAY_RADIUS, usr)
	var/header = "<font color=[usr.Text_Color]>[usr.name]"
	var/message = html_encode(T)
	message = "<i>[message]</i>"
	if(usr.SenseRobbed>=3)
		T="---"

	for(var/mob/E as anything in transmitTo)
		if(!E.client) continue
		if(!E.Admin && E.Mapper && E.invisibility) continue
		if(E.Secret == "Heavenly Restriction" && E.secretDatum?:hasRestriction("Senses"))
			continue
		if(E.EnhancedHearing)
			E?.client.outputToChat("[header][E.Controlz(usr)] whispers: [message]", IC_OUTPUT)
			Log(E.ChatLog(),"[header]([usr.key]) WHISPERS: [message]")
			Log(E.sanitizedChatLog(),"[header] WHISPERS: [message]")

			if(E.BeingObserved.len>0)
				for(var/mob/m as anything in E.BeingObserved)
					m?.client.outputToChat("[OBSERVE_HEADER][header][m.Controlz(usr)] whispers: [message]", IC_OUTPUT)
		else
			if(get_dist(usr, E) <= WHISPER_RADIUS)
				E?.client.outputToChat("[header][E.Controlz(usr)] whispers: [message]", IC_OUTPUT)
				Log(E.ChatLog(),"[header]([usr.key]) WHISPERS: [message]")
				Log(E.sanitizedChatLog(),"[header] WHISPERS: [message]")

				if(E.BeingObserved.len>0)
					for(var/mob/m as anything in E.BeingObserved)
						m?.client.outputToChat("[OBSERVE_HEADER][header][m.Controlz(usr)] whispers: [message]", IC_OUTPUT)
			else
				E?.client.outputToChat("[header][E.Controlz(usr)] whispers...", IC_OUTPUT)
				if(E.BeingObserved.len>0)
					for(var/mob/m as anything in E.BeingObserved)
						m?.client.outputToChat("[header][m.Controlz(usr)] whispers...", IC_OUTPUT)

	usr.CheckAFK()


client/verb/Think(T as text)
	set category="Roleplay"

	var/header = "<i><font color=[usr.Text_Color]>[usr.name]</i>"
	var/message = html_encode(T)
	outputToChat("[header][usr.Controlz(usr)] thinks: [message]", IC_OUTPUT)

	Log(usr.ChatLog(),"<font color=green>[usr.name]([usr.key]) THOUGHT: [message]")
	Log(usr.sanitizedChatLog(),"<font color=green>[usr.name] THOUGHT: [message]")

	if(usr.BeingObserved.len>0)
		for(var/mob/m in usr.BeingObserved)
			if(m.HearThoughts&&m.HasTelepathy())
				m?.client.outputToChat("[OBSERVE_HEADER][header][m.Controlz(usr)] thinks: [message]", IC_OUTPUT)

	for(var/mob/m as anything in ohearers(20,usr))
		if(!m.client) continue
		if(m.HearThoughts&&m.HasTelepathy())
			if(usr.Timestamp)
				m?.client.outputToChat("<font color=red>[time2text(world.timeofday,"(hh:mm:ss)")][header][m.Controlz(usr)] thinks: [message]", IC_OUTPUT)

			else
				m?.client.outputToChat("[header][m.Controlz(usr)] thinks: [message]", IC_OUTPUT)
			Log(m.ChatLog(),"<font color=green>[usr.name]([usr.key]) THOUGHT: [message]")
			Log(m.sanitizedChatLog(),"<font color=green>[usr.name] THOUGHT: [message]")

	usr.CheckAFK()
/*	
client/verb/Prayer(T as text)
	set category="Roleplay"

	if(!T) return

	usr << "You prayed...[T]"

	for(var/mob/m in admins)
		if(!m.PrayerMute&&m.Admin>2)
			m << "A prayer reaches your eyes from [usr]...<br>[T]"

	usr.CheckAFK()
*/
client/verb/Emote()
	set category="Roleplay"

	if(usr.rping) return

	usr.rping = TRUE

	usr.checkInvisibilityBreaking()

	usr.CheckAFK()

	var/image/em=new('Emoting.dmi')
	em.appearance_flags=66
	em.layer=EFFECTS_LAYER
	em.pixel_x=0
	em.pixel_y=0
	usr.emoteBubble = em
	usr.overlays += usr.emoteBubble

	if(fexists("Saved Roleplays/[usr.key].txt"))
		var/a = file2text("Saved Roleplays/[usr.key].txt")
		a = replacetext(a, "\\\"", "\"")
		a = replacetext(a, "\\'", "\'")


		winset(usr, "RPWindow.rpbox","text='[a]'")
	spawn(5)
		fdel("Saved Roleplays/[usr.key].txt")

	winset(usr, "RPWindow","is-visible=true")
	winset(usr, "RPWindow.rpbox","focus=true")
	usr.RPLoop()

obj/Communication
	var/ShowOOC=1
	var/LOOCinIC=0
	var/AllTabOOC=1
	var/LOOCinAll=1
	var/AdminAlerts=1
	var/Logins = 1
	var/RewardAlerts=1
	var/Telepathy_Enabled=1


	verb/OOC(T as text)

	verb/Say(T as text)

	verb/Yell(T as text)

	verb/Whisper(T as text)


	verb/Think(T as text)

/*
	verb/Prayer(T as text)
*/

	verb/Emote()