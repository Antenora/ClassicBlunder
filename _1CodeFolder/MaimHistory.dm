// Per-player log of maim events. Players can view their own history and add
// short IC notes; admins can view any player's history. Entries are appended
// chronologically and capped at 20 — newest displayed first.

/mob
	var/list/MaimHistory = list()

	proc/recordMaim(mob/source, kind, desc = "")
		if(!MaimHistory)
			MaimHistory = list()
		var/list/entry = list()
		entry["when"] = "[time2text(world.realtime, "MMM DD YYYY hh:mm")]"
		var/area/A = null
		if(src.loc)
			A = src.loc.loc
		entry["where"] = (A && istype(A, /area)) ? A.name : "Unknown location"
		if(source && source != src)
			entry["by"] = source.key ? "[source.key] ([source.name])" : "[source.name]"
		else if(source && source == src)
			entry["by"] = "Self"
		else
			entry["by"] = "Unknown"
		entry["type"] = kind ? "[kind]" : "Unknown"
		entry["desc"] = "[desc]"
		MaimHistory += list(entry)
		if(MaimHistory.len > 20)
			MaimHistory.Cut(1, 2)

	proc/maimHistoryHtml()
		var/html = "<html><head><title>Maim History</title></head>"
		html += "<body bgcolor=#1a0a0a text=#e0d0d0>"
		html += "<h2 style='color:#ff8888;margin-bottom:4px'>Maim History</h2>"
		html += "<p style='color:#bbbbbb;margin-top:0'>Newest first. Up to 20 entries are kept; older events fall off as new ones are recorded.</p>"
		if(!MaimHistory || !MaimHistory.len)
			html += "<p><i>No maim events recorded.</i></p>"
		else
			html += "<table border=1 cellpadding=4 cellspacing=0 width=100% bordercolor=#552222>"
			html += "<tr style='background-color:#330000;color:#ffcccc'>"
			html += "<th>When</th><th>Type</th><th>By</th><th>Where</th><th>IC Notes</th>"
			html += "</tr>"
			for(var/i = MaimHistory.len, i >= 1, i--)
				var/list/e = MaimHistory[i]
				if(!istype(e))
					continue
				html += "<tr>"
				html += "<td>[e["when"]]</td>"
				html += "<td>[e["type"]]</td>"
				html += "<td>[e["by"]]</td>"
				html += "<td>[e["where"]]</td>"
				var/note = e["desc"]
				if(!note || note == "")
					html += "<td><i style='color:#888888'>(none)</i></td>"
				else
					html += "<td>[note]</td>"
				html += "</tr>"
			html += "</table>"
		html += "<br><p style='color:#999999;font-size:smaller'><i>Use the Annotate_Maim verb to attach an IC description to one of the entries.</i></p>"
		html += "</body></html>"
		return html

/mob/Players/verb
	View_Maim_History()
		set category = "Roleplay"
		set hidden = 1
		set name = "Maim History"
		usr << browse(usr.maimHistoryHtml(), "window=MaimHistory;size=620x520")

	Annotate_Maim()
		set category = "Roleplay"
		set hidden = 1
		set name = "Annotate Maim"
		if(!MaimHistory || !MaimHistory.len)
			usr << "You have no maim events on record."
			return
		var/list/labels = list()
		for(var/i = MaimHistory.len, i >= 1, i--)
			var/list/e = MaimHistory[i]
			if(!istype(e))
				continue
			labels += "[i]: [e["when"]] - [e["type"]] (by [e["by"]])"
		labels += "Cancel"
		var/picked = input(usr, "Pick a maim entry to annotate:", "Annotate Maim") in labels
		if(!picked || picked == "Cancel")
			return
		var/colon = findtext(picked, ":")
		if(!colon)
			return
		var/idx = text2num(copytext(picked, 1, colon))
		if(!idx || idx < 1 || idx > MaimHistory.len)
			return
		var/list/entry = MaimHistory[idx]
		if(!istype(entry))
			return
		var/note = input(usr, "Brief IC description for this maim. Keep it short — what happened in-character.", "Annotate Maim", entry["desc"]) as message|null
		if(isnull(note))
			return
		entry["desc"] = "[note]"
		usr << "Annotation saved."

/mob/Admin1/verb
	View_Player_Maim_History(mob/Players/p in players)
		set category = "Admin"
		set name = "View Maim History"
		if(!p)
			return
		usr << browse(p.maimHistoryHtml(), "window=MaimHistory_[p.key];size=620x520")
