mob/proc
	RPLoop()
		while(rping)
			sleep(150)
			savedRoleplay = "[winget(src, "RPWindow.rpbox","text")]"
			savedRoleplay = replacetext(savedRoleplay, "\'", "\\\\'")
			savedRoleplay = replacetext(savedRoleplay, "\"", "\\\"")

mob/var/tmp/lastRPTime = 0

mob/verb/
	EmoteColorPicker()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		var/color = input(src, "Choose a text color.", "Text Color") as color|null
		if(!color)
			return
		msg += "<font color=[color]></color>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))
	BoldEmote()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		msg += "<b></b>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))
	ItaEmote()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		msg += "<i></i>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))
	UnderEmote()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		msg += "<u></u>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))
	CenterEmote()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		msg += "<center></center>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))
	StrikeEmote()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		msg += "<s></s>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))
	LargeEmote()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		msg += "<h2></h2>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))
	MassiveEmote()
		set hidden = 1
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		msg += "<h1></h1>"
		winset(src, "RPWindow.rpbox", list2params(list(
			"text" = msg
		)))

	SubmitRP()
		set hidden = 1
		set instant = 1
		if(!rping) return
		if(lastRPTime >= world.time) return
		lastRPTime = world.time + 10
		usr.overlays -= usr.emoteBubble
		winset(usr, "RPWindow", "is-visible=false")
		var/msg = winget(usr, "RPWindow.rpbox", "text")

		winset(usr, "RPWindow.rpbox", "text=")

		rping = FALSE

		if(length(msg) == 0) return

		SubmitRoleplay(msg)

	RPPreview()
		set hidden = 1
		set instant = 1
		if(!rping) return
		var/msg = winget(usr, "RPWindow.rpbox", "text")
		if(length(msg)==0) return
		previewRoleplay(msg)

	CloseRP()
		set hidden = 1
		set instant = 1

		usr.overlays -= usr.emoteBubble
		var/msg = "[winget(usr, "RPWindow.rpbox","text")]"

		msg = replacetext(msg, "�\\","'")
		msg = replacetext(msg, "�\\","")
		msg = replacetext(msg, "�\\","'")
		msg = replacetext(msg, "\'", "\\\\'")
		msg = replacetext(msg, "\"", "\\\"")

		savedRoleplay = null
		if(length(msg) >= 45)
			if(fexists("Saved Roleplays/[usr.key].txt"))
				fdel("Saved Roleplays/[usr.key].txt")
				text2file(msg, "Saved Roleplays/[usr.key].txt")
			else
				text2file(msg, "Saved Roleplays/[usr.key].txt")
		winset(usr, "RPWindow","is-visible=false")
		winset(usr, "RPWindow.rpbox","text=")
		rping = 0

mob/proc/FixCenterLeak(t as text)
	var/close_tag = "</center>"
	var/reset_tag = "<center></center>"
	var/out = ""
	var/pos = 1

	while(TRUE)
		var/found = findtext(lowertext(t), close_tag, pos)

		if(!found)
			out += copytext(t, pos)
			break

		var/after = found + length(close_tag)
		out += copytext(t, pos, after)
		if(length(copytext(t, after)))
			out += reset_tag

		pos = after

	return out

mob
	proc
		applyRoleplayParsing(msg)

			var/format = "default"

			if(findtext(msg, "//",1,3) || findtext(msg,"||", 1,3))
				msg = replacetext(msg, "//", "", 1, 3)
				msg = replacetext(msg, "||", "", 1, 3)
				format = "thirdperson"

			msg = replacetext(msg, "\n", "<br>")

			msg = replacetext(msg, "</center><br>", "</center>")
			msg = replacetext(msg, "</CENTER><br>", "</CENTER>")

			msg = FixCenterLeak(msg)

			var/regex/quotationTextColor = new(@{""[^"]*""}, "g")
			if(findtext(msg, quotationTextColor))
				msg = quotationTextColor.Replace(msg, "<font color=\"[Text_Color]\">$0</font>")

			var/formattedMessage

			if(format=="default")
				formattedMessage = "<font color=[Text_Color]>*[name]<font color=[Emote_Color]> [html_decode(msg)]</font>*"
			else if(format == "thirdperson")
				formattedMessage = "<font color=[Text_Color]>*<font color=[Emote_Color]>[html_decode(msg)]</font><br><br>([name])*"

			return formattedMessage

		previewRoleplay(msg)
			msg = applyRoleplayParsing(msg)
			msg = "<body style=\"background-color: black;\">[msg]</body>"
			src << output(null, "rp-preview")
			winset(src, "previewrp", "is-visible=true")
			src << output(msg, "rp-preview")

		SubmitRoleplay(msg)
			if(length(msg)==0)
				overlays -= emoteBubble
				return

			var/log_msg = msg

			msg = applyRoleplayParsing(msg)

			var/list/hearers = hearers(20,src)

			for(var/mob/E as anything in hearers)
				if(!E.client) continue
				if(!E.Admin && E.Mapper && E.invisibility) continue
				E.client.outputToChat("[E.Controlz(src)][msg]", IC_OUTPUT)

				Log(E.ChatLog(),"<font color=red>*[name]([key]) [html_decode(log_msg)]*")
				Log(E.sanitizedChatLog(),"<font color=red>*[name] [html_decode(log_msg)]*")
				if(E.BeingObserved.len>0)
					for(var/mob/m in E.BeingObserved)
						m.client.outputToChat("[OBSERVE_HEADER][m.Controlz(src)][msg]", IC_OUTPUT)

			Say_Spark()
			CheckAFK()
			overlays-=emoteBubble