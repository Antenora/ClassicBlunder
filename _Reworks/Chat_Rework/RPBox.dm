mob/proc
	RPLoop()
		while(rping)
			sleep(150)
			savedRoleplay = "[winget(src, "RPWindow.rpbox","text")]"
			savedRoleplay = replacetext(savedRoleplay, "\'", "\\\\'")
			savedRoleplay = replacetext(savedRoleplay, "\"", "\\\"")

mob/var/tmp/lastRPTime = 0

mob/verb/
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

mob
	proc
		SubmitRoleplay(msg)
			if(length(msg)==0)
				overlays -= emoteBubble
				return

			var/format = "default"

			if(findtext(msg, "//",1,3) || findtext(msg,"||", 1,3))
				msg = replacetext(msg, "//", "", 1, 3)
				msg = replacetext(msg, "||", "", 1, 3)
				format = "thirdperson"

			var/regex/quotationTextColor = new(@{""[^"]*""}, "g")
			if(findtext(msg, quotationTextColor))
				msg = quotationTextColor.Replace(msg, "<font color=\"[Text_Color]\">$0</font>")

			var/list/hearers = hearers(20,src)

			var/formattedMessage

			if(format=="default")
				formattedMessage = "<font color=[Text_Color]>*[name]<font color=[Emote_Color]> [html_decode(msg)]</font>*"
			else if(format == "thirdperson")
				formattedMessage = "<font color=[Text_Color]>*<font color=[Emote_Color]>[html_decode(msg)]</font>\n\n([name])*"

			for(var/mob/E as anything in hearers)
				if(!E.client) continue
				if(!E.Admin && E.Mapper && E.invisibility) continue
				E.client.outputToChat("[E.Controlz(src)][formattedMessage]", IC_OUTPUT)

				Log(E.ChatLog(),"<font color=red>*[name]([key]) [html_decode(formattedMessage)]*")
				Log(E.sanitizedChatLog(),"<font color=red>*[name] [html_decode(formattedMessage)]*")
				if(E.BeingObserved.len>0)
					for(var/mob/m in E.BeingObserved)
						m.client.outputToChat("[OBSERVE_HEADER][m.Controlz(src)][formattedMessage]", IC_OUTPUT)

			Say_Spark()
			CheckAFK()
			overlays-=emoteBubble