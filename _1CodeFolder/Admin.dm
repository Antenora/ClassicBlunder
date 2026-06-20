var/list
	CodedAdmins=list("NWKY"=3, "Masterdarwin88"=4, "Sunshine Jesse"=4, "Nightmare Zarkus"=4, "NeoGalaxyEyesPhotonDragon"=4, "Lanni.k"=4, "Antenora Luxuria"=4, "Admindred"=4, "Hadoke"=3, "Ghost66"=4)
	Admins=list()
	Mappers=list()
	Punishments=list()

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
	tmp/mob/AdminTrackTarget    // Overwatch: mob currently being auto-followed
	tmp/AdminFullStealth=0      // Overwatch: hard stealth flag (alpha 0, untargetable)
	tmp/AdminListenMode=0       // Overwatch: receive all chat broadcasts globally
	tmp/AdminOverwatchActive=0  // Overwatch: protection mode — immortal, no density, click-teleport
	list/AdminWatchList         // Overwatch: persistent list of player keys to alert on login/logout
	tmp/list/AdminSnapshotData  // Overwatch: saved snapshot for compare
	tmp/list/CombatLog          // Overwatch: per-mob combat event ring buffer (max 30)

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
		if(overwrite!="Yes") return
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
		world<<"araki upscale"
		sleep(10)
		world.Reboot()

/*
/mob/Admin3/verb/Stop_All_AI()
	for(var/obj/AI_Spot/a in world)
		a.ai_limit = 0
	for(var/mob/Player/AI/ai in ticking_ai)
		ai.EndLife(0)*/

// Read-only browser view of all the potential thresholds for Style and Sig
// development, with one table per tier listing every type at that tier and the
// key balance vars on each (Style: Str/For/End/Spd/Off/Def + passives; Sig:
// Cooldown/ManaCost/EnergyCost/DamageMult). Useful for double-checking pot
// reqs against the progression curve and for spotting outliers in tier values.
/mob/Admin3/verb/View_Style_Sig_Reqs()
	set category = "Admin"
	set name = "View Style/Sig Reqs"
	set desc = "Chat dump + browser view of pot reqs and tier balance vars on every Style/Sig."

	usr << "<b><font color='#ffaa00'>=== Style/Sig Pot Reqs ===</font></b>"
	usr << "<font color='#88ccff'>Pot Thresholds:</font>"
	usr << "  T1 Style: 1st=[glob.progress.T1_STYLES[1]], 2nd=[glob.progress.T1_STYLES[2]]"
	usr << "  T2 Style: 1st=[glob.progress.T2_STYLES[1]], 2nd=[glob.progress.T2_STYLES[2]]"
	usr << "  T3 Style: 1st=[glob.progress.T3_STYLES[1]]"
	usr << "  T1 Sig: 1st=[glob.progress.T1_SIGS[1]], 2nd=[glob.progress.T1_SIGS[2]], 3rd=[glob.progress.T1_SIGS[3]]"
	usr << "  T2 Sig: 1st=[glob.progress.T2_SIGS[1]], 2nd=[glob.progress.T2_SIGS[2]]"

	// Single pass through NuStyle subtypes — bucket by tier
	var/list/stylesByTier = list("1" = list(), "2" = list(), "3" = list())
	for(var/T in subtypesof(/obj/Skills/Buffs/NuStyle))
		if(!ispath(T))
			continue
		var/obj/Skills/Buffs/NuStyle/probe = new T
		if(!probe)
			continue
		var/sig = probe.SignatureTechnique
		if(sig == 1 || sig == 2 || sig == 3)
			var/displayName = probe.name ? probe.name : "[T]"
			var/passText = ""
			if(probe.passives && probe.passives.len)
				for(var/p in probe.passives)
					passText += "[p]=[probe.passives[p]] "
			var/list/row = list(
				"name" = displayName,
				"path" = "[T]",
				"str"  = probe.StyleStr,
				"for"  = probe.StyleFor,
				"end"  = probe.StyleEnd,
				"spd"  = probe.StyleSpd,
				"off"  = probe.StyleOff,
				"def"  = probe.StyleDef,
				"passives" = passText
			)
			stylesByTier["[sig]"] += list(row)
		del probe

	// Single pass through Tier1 / Tier2 sig lists — bucket by tier
	var/list/sigsByTier = list("1" = list(), "2" = list())
	for(var/tierKey in list("1", "2"))
		var/list/srcList = (tierKey == "1") ? Tier1 : Tier2
		for(var/k in srcList)
			var/v = srcList[k]
			if(istext(v))
				var/p = text2path(v)
				if(!ispath(p))
					continue
				var/obj/Skills/probe = new p
				if(!probe)
					continue
				var/list/row = list(
					"name" = k,
					"path" = "[p]",
					"cooldown"   = probe.vars["Cooldown"],
					"manacost"   = probe.vars["ManaCost"],
					"energycost" = probe.vars["EnergyCost"],
					"damagemult" = probe.vars["DamageMult"]
				)
				sigsByTier[tierKey] += list(row)
				del probe
			else if(istype(v, /list))
				var/list/bundle = v
				var/list/row = list("name" = k, "path" = "(bundle of [bundle.len] skills)", "cooldown" = null, "manacost" = null, "energycost" = null, "damagemult" = null)
				sigsByTier[tierKey] += list(row)

	// Chat output of styles
	for(var/tier in 1 to 3)
		var/list/rows = stylesByTier["[tier]"]
		usr << "<font color='#88ccff'>T[tier] Styles ([rows.len]):</font>"
		if(!rows.len)
			usr << "  (none)"
		else
			for(var/list/r in rows)
				usr << "  [r["name"]] | Str=[r["str"] || "—"] For=[r["for"] || "—"] End=[r["end"] || "—"] Spd=[r["spd"] || "—"] Off=[r["off"] || "—"] Def=[r["def"] || "—"] | [r["passives"] || "no passives"]"

	// Chat output of sigs
	for(var/tierKey in list("1", "2"))
		var/list/rows = sigsByTier[tierKey]
		usr << "<font color='#88ccff'>T[tierKey] Sigs ([rows.len]):</font>"
		if(!rows.len)
			usr << "  (none)"
		else
			for(var/list/r in rows)
				usr << "  [r["name"]] | CD=[r["cooldown"] || "—"] Mana=[r["manacost"] || "—"] Energy=[r["energycost"] || "—"] DmgMult=[r["damagemult"] || "—"]"

	// Build browser html as bonus (chat output above is the source of truth)
	var/html = "<html><head><title>Style/Sig Pot Reqs</title><style>"
	html += "body{background:#1a1a1a;color:#ddd;font-family:monospace;padding:10px;font-size:12px}"
	html += "h2{color:#ffaa00;border-bottom:1px solid #444;padding-bottom:4px;margin-top:18px}"
	html += "h3{color:#88ccff;margin-top:14px;margin-bottom:6px}"
	html += "table{border-collapse:collapse;margin:6px 0;width:100%}"
	html += "th{background:#333;color:#ffcc66;padding:4px 8px;text-align:left;border:1px solid #555}"
	html += "td{padding:3px 8px;border:1px solid #2c2c2c;color:#ccc;vertical-align:top}"
	html += "td.path{color:#777;font-size:11px}"
	html += "td.val{color:#aaffaa;text-align:right}"
	html += "td.muted{color:#555;text-align:right}"
	html += "td.passives{color:#cc99ff;font-size:11px}"
	html += "</style></head><body>"
	html += "<h2>Potential Requirements (from glob.progress)</h2>"
	html += "<table><tr><th>Unlock</th><th>Pot Req</th></tr>"
	html += "<tr><td>1st T1 Style</td><td class='val'>[glob.progress.T1_STYLES[1]]</td></tr>"
	html += "<tr><td>2nd T1 Style</td><td class='val'>[glob.progress.T1_STYLES[2]]</td></tr>"
	html += "<tr><td>1st T2 Style</td><td class='val'>[glob.progress.T2_STYLES[1]]</td></tr>"
	html += "<tr><td>2nd T2 Style</td><td class='val'>[glob.progress.T2_STYLES[2]]</td></tr>"
	html += "<tr><td>1st T3 Style</td><td class='val'>[glob.progress.T3_STYLES[1]]</td></tr>"
	html += "<tr><td>1st T1 Sig</td><td class='val'>[glob.progress.T1_SIGS[1]]</td></tr>"
	html += "<tr><td>2nd T1 Sig</td><td class='val'>[glob.progress.T1_SIGS[2]]</td></tr>"
	html += "<tr><td>3rd T1 Sig</td><td class='val'>[glob.progress.T1_SIGS[3]]</td></tr>"
	html += "<tr><td>1st T2 Sig</td><td class='val'>[glob.progress.T2_SIGS[1]]</td></tr>"
	html += "<tr><td>2nd T2 Sig</td><td class='val'>[glob.progress.T2_SIGS[2]]</td></tr>"
	html += "</table>"
	html += "<h2>Styles by Tier</h2>"
	for(var/tier in 1 to 3)
		html += "<h3>T[tier] Styles ([stylesByTier["[tier]"].len])</h3>"
		html += "<table><tr><th>Name</th><th>Type Path</th><th>Str</th><th>For</th><th>End</th><th>Spd</th><th>Off</th><th>Def</th><th>Passives</th></tr>"
		var/list/rows = stylesByTier["[tier]"]
		if(!rows.len)
			html += "<tr><td colspan=9 class='muted'>(no entries)</td></tr>"
		else
			for(var/list/r in rows)
				html += "<tr>"
				html += "<td>[r["name"]]</td>"
				html += "<td class='path'>[r["path"]]</td>"
				html += r["str"] ? "<td class='val'>[r["str"]]</td>" : "<td class='muted'>—</td>"
				html += r["for"] ? "<td class='val'>[r["for"]]</td>" : "<td class='muted'>—</td>"
				html += r["end"] ? "<td class='val'>[r["end"]]</td>" : "<td class='muted'>—</td>"
				html += r["spd"] ? "<td class='val'>[r["spd"]]</td>" : "<td class='muted'>—</td>"
				html += r["off"] ? "<td class='val'>[r["off"]]</td>" : "<td class='muted'>—</td>"
				html += r["def"] ? "<td class='val'>[r["def"]]</td>" : "<td class='muted'>—</td>"
				html += r["passives"] ? "<td class='passives'>[r["passives"]]</td>" : "<td class='muted'>—</td>"
				html += "</tr>"
		html += "</table>"
	html += "<h2>Sigs by Tier</h2>"
	for(var/tierKey in list("1", "2"))
		html += "<h3>T[tierKey] Sigs ([sigsByTier[tierKey].len])</h3>"
		html += "<table><tr><th>Name</th><th>Type Path</th><th>Cooldown</th><th>ManaCost</th><th>EnergyCost</th><th>DamageMult</th></tr>"
		var/list/rows = sigsByTier[tierKey]
		if(!rows.len)
			html += "<tr><td colspan=6 class='muted'>(no entries)</td></tr>"
		else
			for(var/list/r in rows)
				html += "<tr>"
				html += "<td>[r["name"]]</td>"
				html += "<td class='path'>[r["path"]]</td>"
				html += isnum(r["cooldown"]) ? "<td class='val'>[r["cooldown"]]</td>" : "<td class='muted'>—</td>"
				html += isnum(r["manacost"]) && r["manacost"] ? "<td class='val'>[r["manacost"]]</td>" : "<td class='muted'>—</td>"
				html += isnum(r["energycost"]) && r["energycost"] ? "<td class='val'>[r["energycost"]]</td>" : "<td class='muted'>—</td>"
				html += isnum(r["damagemult"]) && r["damagemult"] ? "<td class='val'>[r["damagemult"]]</td>" : "<td class='muted'>—</td>"
				html += "</tr>"
		html += "</table>"
	html += "</body></html>"
	src << browse(html, "window=StyleSigReqs;size=900x900")
	usr << "<font color='#aaffaa'>(Browser window also opened — if you don't see it, this chat dump has the same data.)</font>"

// Live-tweak a stat var on a T1/T2/T3 Style template or T1/T2 Sig template.
// Picks a category, lets the admin pick a specific type, then a scalar var on
// that type, then a new value. Updates the var on every live instance of that
// type currently in world contents. Note: not persisted across reboots — the
// compile-time default is restored when the world starts. Re-run after reboot
// or after balance is finalized in code.
/mob/Admin3/verb/Tweak_Style_Sig_Var()
	set category = "Admin"
	set name = "Tweak Style/Sig Var"
	set desc = "Edit a scalar var on a T1/T2/T3 Style or T1/T2 Sig template + propagate to live instances."
	var/category = input(usr, "Pick a category to tweak.", "Tweak Style/Sig") as null|anything in list("T1 Style", "T2 Style", "T3 Style", "T1 Sig", "T2 Sig")
	if(!category)
		return
	var/list/typeChoices = list()
	if(category == "T1 Style" || category == "T2 Style" || category == "T3 Style")
		var/wantTier = 1
		if(category == "T2 Style")
			wantTier = 2
		else if(category == "T3 Style")
			wantTier = 3
		for(var/T in subtypesof(/obj/Skills/Buffs/NuStyle))
			if(!ispath(T))
				continue
			var/obj/Skills/Buffs/NuStyle/probe = new T
			if(probe.SignatureTechnique == wantTier)
				typeChoices["[T]"] = T
			del probe
	else if(category == "T1 Sig")
		for(var/k in Tier1)
			var/v = Tier1[k]
			if(istext(v))
				var/p = text2path(v)
				if(ispath(p))
					typeChoices["[k] ([p])"] = p
	else if(category == "T2 Sig")
		for(var/k in Tier2)
			var/v = Tier2[k]
			if(istext(v))
				var/p = text2path(v)
				if(ispath(p))
					typeChoices["[k] ([p])"] = p
	if(!typeChoices.len)
		usr << "No types found in [category]."
		return
	var/pickedKey = input(usr, "Pick a type from [category].", "Tweak Type") as null|anything in typeChoices
	if(!pickedKey)
		return
	var/path = typeChoices[pickedKey]
	if(!ispath(path))
		usr << "Invalid type."
		return
	var/obj/Skills/probe = new path
	if(!probe)
		usr << "Could not instantiate [path]."
		return
	var/list/varChoices = list()
	var/list/exclude = list("type", "parent_type", "loc", "x", "y", "z", "contents", "vars", "verbs", "overlays", "underlays", "transform", "appearance", "filters", "color", "alpha", "mouse_opacity", "icon", "icon_state", "pixel_x", "pixel_y", "Initialized", "tag", "gender", "density", "opacity", "layer", "plane", "dir")
	for(var/v in probe.vars)
		if(v in exclude)
			continue
		var/val = probe.vars[v]
		if(istype(val, /list))
			continue
		if(!isnum(val) && !istext(val))
			continue
		varChoices["[v] = [val]"] = v
	if(!varChoices.len)
		usr << "No editable scalar vars found on [pickedKey]."
		del probe
		return
	var/varKey = input(usr, "Which var to edit on [pickedKey]?", "Tweak Var") as null|anything in varChoices
	if(!varKey)
		del probe
		return
	var/varName = varChoices[varKey]
	var/curVal = probe.vars[varName]
	var/newVal
	if(isnum(curVal))
		newVal = input(usr, "Current [varName] = [curVal]. New numeric value?", "Tweak", curVal) as null|num
	else
		newVal = input(usr, "Current [varName] = \"[curVal]\". New text value?", "Tweak", curVal) as null|text
	if(isnull(newVal))
		del probe
		return
	var/count = 0
	for(var/obj/Skills/S in world)
		if(S.type == path)
			S.vars[varName] = newVal
			count++
	Log("Admin", "[ExtractInfo(usr)] tweaked [path].[varName] from [curVal] to [newVal]. [count] live instances updated.")
	usr << "Set [path].[varName] from [curVal] to [newVal]. Updated [count] live instance\s. Note: change is in-memory only — compile-time default returns on world reboot."
	del probe

// Live-edit potential thresholds for Style/Sig tier unlocks. These live in
// glob.progress (T1_STYLES, T2_STYLES, T3_STYLES, T1_SIGS, T2_SIGS) and are
// what req_pot() and styles_available() check against. Note: in-memory only —
// reverts on world reboot, same as Tweak_Style_Sig_Var.
/mob/Admin3/verb/Tweak_Pot_Reqs()
	set category = "Admin"
	set name = "Tweak Pot Reqs"
	set desc = "Edit potential threshold for a Style/Sig tier unlock slot in glob.progress."
	var/list/slots = list(
		"1st T1 Style" = list("T1_STYLES", 1),
		"2nd T1 Style" = list("T1_STYLES", 2),
		"3rd T1 Style" = list("T1_STYLES", 3),
		"4th T1 Style" = list("T1_STYLES", 4),
		"1st T2 Style" = list("T2_STYLES", 1),
		"2nd T2 Style" = list("T2_STYLES", 2),
		"3rd T2 Style" = list("T2_STYLES", 3),
		"4th T2 Style" = list("T2_STYLES", 4),
		"1st T3 Style" = list("T3_STYLES", 1),
		"1st T1 Sig"   = list("T1_SIGS", 1),
		"2nd T1 Sig"   = list("T1_SIGS", 2),
		"3rd T1 Sig"   = list("T1_SIGS", 3),
		"1st T2 Sig"   = list("T2_SIGS", 1),
		"2nd T2 Sig"   = list("T2_SIGS", 2)
	)
	var/list/labels = list()
	for(var/k in slots)
		var/list/info = slots[k]
		var/listName = info[1]
		var/idx = info[2]
		var/list/targetList = glob.progress.vars[listName]
		var/curVal = (targetList && idx <= targetList.len) ? targetList[idx] : "?"
		labels["[k] (current: [curVal])"] = k
	var/pickedLabel = input(usr, "Pick a threshold to tweak.", "Tweak Pot Reqs") as null|anything in labels
	if(!pickedLabel)
		return
	var/pickedKey = labels[pickedLabel]
	var/list/info = slots[pickedKey]
	var/listName = info[1]
	var/idx = info[2]
	var/list/targetList = glob.progress.vars[listName]
	if(!targetList)
		usr << "Could not access glob.progress.[listName]."
		return
	if(idx > targetList.len)
		usr << "Index [idx] out of range for [listName] (len=[targetList.len])."
		return
	var/curVal = targetList[idx]
	var/newVal = input(usr, "Current [pickedKey] = [curVal]. New potential value?", "Tweak Pot Req", curVal) as null|num
	if(isnull(newVal))
		return
	targetList[idx] = newVal
	Log("Admin", "[ExtractInfo(usr)] tweaked glob.progress.[listName]\[[idx]\] from [curVal] to [newVal] ([pickedKey]).")
	usr << "Set [pickedKey] from [curVal] to [newVal]. Note: in-memory only — reverts on world reboot."

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

	GiveWound(var/mob/m in players)
		set category="Admin"
		set name="Give Wound"
		var/choice = input(usr, "What kind of wound for [m]?", "Give Wound") as null|anything in list("Light", "Heavy", "Maim", "Cancel")
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Light")
				var/Time = RawHours(2)
				Time /= m.GetRecov()
				m.BPPoisonTimer = Time
				m.BPPoison = 0.9
				Log("Admin", "[ExtractInfo(usr)] gave [ExtractInfo(m)] light wounds.")
				m << "You've been lightly wounded!"
			if("Heavy")
				var/Time = RawHours(4)
				Time /= m.GetRecov()
				m.BPPoisonTimer = Time
				m.BPPoison = 0.7
				Log("Admin", "[ExtractInfo(usr)] gave [ExtractInfo(m)] heavy wounds.")
				m << "You've been heavily wounded!"
			if("Maim")
				var/Time = RawHours(6)
				Time /= m.GetRecov()
				m.Maimed += 1
				if(m.Maimed > 4)
					m.Maimed = 4
				m.BPPoisonTimer = Time
				m.BPPoison = 0.5
				m.recordMaim(usr, "Admin")
				Log("Admin", "[ExtractInfo(usr)] gave [ExtractInfo(m)] a maim wound.")
				m << "You have been maimed!"
	EditPassiveHandler(mob/m in world)
		set category = "Admin"
		if(m.passive_handler.Get("Rank-Down Protection") && !usr.passive_handler.Get("True Edit"))
			m.OMessage(15, "<b><font color=[m.Text_Color]><font size=+1>[m] was protected from the effects of Rank Magic!</b></font color></font size>", "<font color=blue>[m]([m.key]) cannot be Edited.")
			return
		src.Edit(m.passive_handler)

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

	Potential_Boost(mob/m in players, val as num)
		set category="Admin"
		if(val&&m)
			m.Potential+=val
			m.PotentialCap+=val
			if(m.isRace(/race/demi_fiend))
				m.refreshMagatama()
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
	SetStartingProgressValues()
		set category="Admin"
		var/X=input(src, "Starting RPP", "Set spawn RPP") as num|null
		var/Y=input(src, "Starting Potential", "Set spawn Potential") as num|null
		if(X<0)
			X=0
		if(Y<0)
			Y=0
		if(!X||!Y)
			return
		glob.progress.MinRPP = X
		glob.progress.MinPotential = Y
		Log("Admin", "[ExtractInfo(usr)] set the new min RPP to ([glob.progress.MinRPP], and min Potential to [glob.progress.MinPotential]")

	ForceResetMultis()
		set category="Admin"
		for(var/mob/Players/m in players)
			if(m.ActiveBuff)
				if(m.CheckActive("Eight Gates"))
					var/obj/Skills/Buffs/ActiveBuffs/Eight_Gates/eg = m.ActiveBuff
					eg.Stop_Cultivation()
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
			else
				// Strip stale admin verbs persisted in the mob savefile from a prior
				// admin session. BYOND saves /verbs/ by default, and the original Check
				// only added verbs for current admins - it never removed them when a
				// player was demoted, so right-click menus on other mobs kept showing
				// admin commands (Admin: Jump To, Admin: Summon, etc.). Calling Remove
				// is safe for an actual non-admin: CodedAdmin guard on the inside short
				// circuits coded keys, and the rest are no-ops on a clean mob.
				src.Admin("Remove")
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
	if(CodedAdmins && CodedAdmins.Find(src.key))return 0
	if(!Punishments) return 0
	for(var/x in Punishments)
		if(x["Punishment"]=="[z]")
			if(x["Key"]==src.key || (src.client && (x["IP"]==src.client.address||x["ComputerID"]==src.client.computer_id)))
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

// Shared admin helpers — called from the consolidated dropdown verbs
// (AdminKill, Punish) and from the MasterControl popup in Guides.dm.
// Single source of truth so both entry points stay in sync.
mob/proc/AdminDoBan(mob/M)
	if(!M || !M.client) return
	var/Reason = input(src, "Why are you banning [M]?") as text
	var/Duration = input(src, "Ban Duration?(IN HOURS)", "Rebirth") as num
	if(!src.Alert("Are you sure you want to ban [M] for [Duration] Hours?")) return
	Duration = Value(world.realtime + (Duration * 600 * 60))
	Punishment("Action=Add&Punishment=Ban&Key=[M.key]&IP=[M.client.address]&ComputerID=[M.client.computer_id]&Duration=[Duration]&User=[src.key]&Reason=[Reason]&Time=[TimeStamp()]")
	world << "[M.key] was banned for [Reason]."
	Log("Admin", "[ExtractInfo(src)] banned [M.key]|[M.client.address]|[M.client.computer_id] for [Reason].")

mob/proc/AdminDoMute(mob/M)
	if(!M || !M.client) return
	var/Reason = input(src, "Why are you muting [M]?") as text
	var/Duration = input(src, "Mute Duration?(IN MINUTES)", "Rebirth") as num
	if(!src.Alert("Are you sure you want to mute [M] for [Duration] Minutes?")) return
	Duration = Value(world.realtime + (Duration * 600))
	Punishment("Action=Add&Punishment=Mute&Key=[M.key]&IP=[M.client.address]&ComputerID=[M.client.computer_id]&Duration=[Duration]&User=[src.key]&Reason=[Reason]&Time=[TimeStamp()]")
	Log("Admin", "[ExtractInfo(src)] muted [M.key]|[M.client.address]|[M.client.computer_id] for [Reason].")

mob/proc/AdminDoKill(mob/A)
	if(!A) return
	var/confirm = alert(src, "Are you sure you wanna admin kill [A.name]?",, "Yes", "No")
	if(confirm == "No") return
	var/customDeath = input(src, "What do you want the death message to say? The format is 'name has been killed by INPUT', where input is what you put here. Entering nothing defaults to ADMIN.") as text|null
	if(!customDeath)
		customDeath = "ADMIN"
	A.Death(null, customDeath, SuperDead=1)
	Log("Admin", "<font color=red>[ExtractInfo(src)] admin-killed [ExtractInfo(A)].")

mob/proc/AdminDoKO(mob/A)
	if(!A) return
	if(!A.KO)
		if(A.passive_handler.Get("Our Future"))
			A.OMessage(20, "[A] was just knocked out by ADMIN!", "<font color=red>[A] was just knocked out by ADMIN!")
			sleep(20)
			src << "<b><font color='green'>...but [A] is no longer playing by your rules!</b></font color>"
			A.OMessage(15, "<b><font color=[A.Text_Color]><font size=+1>...but [A] refuses to allow their story to end here!</b></font color></font size>", "<font color=blue>[A]([A.key]) denies death.")
			if(A.hasDeathEvolution())
				var/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution/de = locate(/obj/Skills/Buffs/SlotlessBuffs/Death_Evolution, A)
				if(locate(/obj/Skills/Buffs/SlotlessBuffs/X_Evolution, A))
					var/obj/Skills/Buffs/SlotlessBuffs/B = A.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/X_Evolution)
					if(B.Using) B.Trigger(A, 1)
				A.RPModeSwitch()
				src << "<b><font color='purple'>...and [A] never was to begin with.</b></font color>"
				sleep(30)
				world << "<font color=red><b>When gathering souls become one, a new future will bring about a true Rebirth.</b></font>"
				sleep(30)
				world << "<font color=red><b>[A] becomes the path its darkness advances upon.</b></font>"
				sleep(30)
				world << "<font color=red><b>Shinka no Yami.</b></font>"
				A.HealAllCutTax()
				A.FullRestore()
				sleep(30)
				A.DeathEvolutionEffects()
				A.Conscious()
				world << "<font color=red><b>Death-X-Evolution...</b></font>"
				de.Trigger(A)
			return
		if(A.passive_handler.Get("Rank-Down Protection"))
			A.OMessage(20, "[A] was just knocked out by ADMIN!", "<font color=red>[A] was just knocked out by ADMIN!")
			sleep(20)
			src << "<b><font color='green'>...but [A]'s fate is not for you to shepherd!</b></font color>"
			A.OMessage(15, "<b><font color=[A.Text_Color]><font size=+1>...but [A] was protected by the Lord's Grace!</b></font color></font size>", "<font color=blue>[A]([A.key]) denies death.")
			return
		A.Unconscious(null, "ADMIN")
		Log("Admin", "<font color=red>[ExtractInfo(src)] admin-KOed [ExtractInfo(A)].")

// Should fix targeting your own shit if deleting/editing someone else's items/skills in Admin View Contents

mob/proc/AdminResolveTargetedContent(atom/A)
	if(!A) return null
	if(!src.AdminContentsView) return A
	if(!src.Target || src.Target == src) return A
	if(!isobj(A)) return A
	if(A in src.Target.contents) return A
	if(!(A in src.contents)) return A

	var/obj/firstTypeMatch = null
	for(var/obj/O in src.Target.contents)
		if(O.type != A.type) continue
		if(!firstTypeMatch) firstTypeMatch = O
		if(O.name == A.name)
			return O
	return firstTypeMatch ? firstTypeMatch : A

// Overwatch helpers — used by /mob/Admin4/verb/Overwatch dropdown.
// Tier 4 only. Designed for an observer/balance role: silently watch
// players, follow them, snapshot their state, all without breaking RP.
mob/proc/AdminFullStealthEnable()
	src.AdminFullStealth = 1
	src.AdminInviso = 1
	src.invisibility = 100
	src.see_invisible = 101
	src.density = 0
	src.Incorporeal = 1
	src.Grabbable = 0
	src.passive_handler.Increase("AdminVision", 1)
	animate(src, alpha = 0, time = 5)
	// Drop any aggro currently held on us
	for(var/mob/M in world)
		if(M.Target == src)
			M.RemoveTarget()
	src << "<font color=green><b>Overwatch:</b> Full Stealth ON. You are invisible, intangible, and untargettable."

mob/proc/AdminFullStealthDisable()
	src.AdminFullStealth = 0
	src.AdminInviso = 0
	src.invisibility = 0
	src.see_invisible = 0
	src.density = 1
	src.Incorporeal = 0
	src.Grabbable = 1
	src.passive_handler.Decrease("AdminVision", 1)
	animate(src, alpha = 255, time = 5)
	src << "<font color=red><b>Overwatch:</b> Full Stealth OFF. You are visible again."

mob/proc/AdminPlayerSnapshot(mob/M)
	if(!M)
		src << "<font color=red>Overwatch Snapshot: target is null."
		return
	var/area/A = null
	if(M.loc)
		A = M.loc.loc
	var/areaName = (A && istype(A, /area)) ? A.name : "??"
	var/raceName = (M.race && M.race.name) ? M.race.name : "??"
	var/targetName = M.Target ? "[M.Target] ([M.Target.key])" : "none"
	var/connInfo = "offline"
	if(M.client)
		connInfo = "[M.client.address] | CID [M.client.computer_id]"
	src << "<font color=cyan><b>=== Overwatch Snapshot: [M.name] ([M.key]) ===</b></font>"
	src << "<font color=white>DisplayKey: [M.DisplayKey ? M.DisplayKey : "(none)"]"
	src << "Race: [raceName] | Ascensions: [M.AscensionsAcquired] | Class: [M.Class ? M.Class : "??"]"
	src << "Power: [Get_Scouter_Reading(M)] | Anger: [M.Anger] | KO: [M.KO] | Dead: [M.Dead]"
	src << "Health: [round(M.Health, 0.1)]% (HealthCut [round(M.HealthCut*100, 0.1)]%) | Energy: [round(M.Energy, 0.1)]% | Mana: [round(M.ManaAmount, 0.1)]%"
	src << "Capacity: [round(M.TotalCapacity, 0.1)]% | Fatigue: [round(M.TotalFatigue, 0.1)]% | Injury: [round(M.TotalInjury, 0.1)]% | Maims: [M.Maimed]"
	src << "Location: [M.x],[M.y],[M.z] | Area: [areaName]"
	src << "Target: [targetName]"
	src << "ActiveBuff: [M.ActiveBuff ? M.ActiveBuff.BuffName : "none"] | SpecialBuff: [M.SpecialBuff ? M.SpecialBuff.BuffName : "none"]"
	src << "Connection: [connInfo]"
	src << "<font color=cyan><b>=== End Snapshot ===</b></font>"

mob/proc/AdminTrackLoop()
	set waitfor = 0
	while(src.AdminTrackTarget)
		var/mob/T = src.AdminTrackTarget
		if(!T || !T.client)
			src << "<font color=red>Overwatch Track: target lost. Stopping."
			src.AdminTrackTarget = null
			return
		if(T.loc && T.z == src.z)
			if(get_dist(src, T) > 0)
				src.loc = T.loc
		else if(T.loc)
			src.loc = T.loc
		sleep(5)

// Per-mob combat event ring buffer. Cheap, called from DoDamage hot path.
// Max 30 entries, FIFO. Used by Overwatch "Combat Log" view.
mob/proc/RecordCombatEvent(text)
	if(!src.CombatLog)
		src.CombatLog = list()
	src.CombatLog += "[time2text(world.timeofday,"hh:mm:ss")] [text]"
	while(src.CombatLog.len > 30)
		src.CombatLog.Cut(1, 2)

// Listen Mode: send a copy of a chat line to every admin with listen on.
// Hooked into: MSay (helper_procs.dm), sayProc/OOC/Whisper/Think
// (Chat_Rework/communication_rework.dm), SkinPM2 + AdminHelp
// (AdminHelp_System.dm). OMessage (combat narration) is deliberately NOT
// hooked — combat spam drowns real chat.
proc/AdminListenBroadcast(mob/source, text)
	if(!source) return
	for(var/mob/Players/A in admins)
		if(!A.client) continue
		if(!A.AdminListenMode) continue
		if(A == source) continue
		A << "<font color=#9999ff>\[LISTEN [source.name]\]</font> [text]"

// Watch list helpers — personal per-admin alert list of player keys.
// Fired by OverwatchNotifyLogin from Creation.dm Login/Logout.
mob/proc/AdminWatchAdd(targetKey)
	if(!src.AdminWatchList)
		src.AdminWatchList = list()
	if(targetKey in src.AdminWatchList)
		src << "<font color=red>[targetKey] is already on your watchlist."
		return
	src.AdminWatchList += targetKey
	src << "<font color=green><b>Overwatch:</b> Added [targetKey] to watchlist. ([src.AdminWatchList.len] total)"

mob/proc/AdminWatchRemove(targetKey)
	if(!src.AdminWatchList || !(targetKey in src.AdminWatchList))
		src << "<font color=red>[targetKey] is not on your watchlist."
		return
	src.AdminWatchList -= targetKey
	src << "<font color=green><b>Overwatch:</b> Removed [targetKey] from watchlist. ([src.AdminWatchList.len] total)"

proc/OverwatchNotifyLogin(mob/M, status)
	if(!M) return
	for(var/mob/Players/A in admins)
		if(!A.client) continue
		if(!A.AdminWatchList || !A.AdminWatchList.len) continue
		if(M.key in A.AdminWatchList)
			A << "<font color=#ffaa00><b>\[WATCH\]</b> [M.key] has [status]."

// Var Inspector — dump filtered vars from any mob to admin chat.
// Filter is a substring match on var name (case-insensitive).
// Pass "" to dump all (long, ~300+ entries on a player mob — use carefully).
mob/proc/AdminVarInspect(mob/M, filter)
	if(!M)
		src << "<font color=red>Var Inspector: target is null."
		return
	src << "<font color=cyan><b>=== Var Inspector: [M] ([M.key]) | filter: [filter ? filter : "(all)"] ===</b></font>"
	var/lowerFilter = lowertext(filter ? filter : "")
	var/count = 0
	for(var/v in M.vars)
		if(lowerFilter && !findtext(lowertext(v), lowerFilter))
			continue
		var/value = M.vars[v]
		if(istype(value, /list))
			var/list/L = value
			src << "<font color=white>[v]</font> = list(len=[L.len])"
		else if(value == null)
			src << "<font color=white>[v]</font> = null"
		else
			src << "<font color=white>[v]</font> = [value]"
		count++
		if(count >= 200)
			src << "<font color=red>(Truncated at 200 entries — use a more specific filter.)</font>"
			break
	src << "<font color=cyan><b>=== End Inspector ([count] vars shown) ===</b></font>"

// Snapshot Save/Compare — capture key combat-relevant fields from a target,
// then on second invocation diff against current values.
mob/proc/AdminSnapshotSave(mob/M)
	if(!M)
		src << "<font color=red>Snapshot Save: target is null."
		return
	src.AdminSnapshotData = list(
		"key" = M.key,
		"name" = M.name,
		"power" = src.Get_Scouter_Reading(M),
		"health" = M.Health,
		"healthcut" = M.HealthCut,
		"energy" = M.Energy,
		"mana" = M.ManaAmount,
		"capacity" = M.TotalCapacity,
		"fatigue" = M.TotalFatigue,
		"injury" = M.TotalInjury,
		"maims" = M.Maimed,
		"asc" = M.AscensionsAcquired,
		"x" = M.x,
		"y" = M.y,
		"z" = M.z,
		"time" = world.realtime
	)
	src << "<font color=green><b>Overwatch:</b> Snapshot of [M] saved. Use 'Snapshot Compare' to diff later."

mob/proc/AdminSnapshotCompareRun(mob/M)
	if(!src.AdminSnapshotData || !src.AdminSnapshotData.len)
		src << "<font color=red>No snapshot saved. Use 'Snapshot Save' first."
		return
	if(!M)
		src << "<font color=red>Snapshot Compare: target is null."
		return
	if(M.key != src.AdminSnapshotData["key"])
		src << "<font color=red>Snapshot was for [src.AdminSnapshotData["key"]], not [M.key]."
		return
	var/elapsed = round((world.realtime - src.AdminSnapshotData["time"]) / 600, 0.1)
	src << "<font color=cyan><b>=== Snapshot Diff: [M] ([elapsed] minutes elapsed) ===</b></font>"
	var/list/fields = list("power", "health", "energy", "mana", "capacity", "fatigue", "injury", "maims", "asc")
	var/list/current = list(
		"power" = src.Get_Scouter_Reading(M),
		"health" = M.Health,
		"energy" = M.Energy,
		"mana" = M.ManaAmount,
		"capacity" = M.TotalCapacity,
		"fatigue" = M.TotalFatigue,
		"injury" = M.TotalInjury,
		"maims" = M.Maimed,
		"asc" = M.AscensionsAcquired
	)
	for(var/f in fields)
		var/oldVal = src.AdminSnapshotData[f]
		var/newVal = current[f]
		var/delta = newVal - oldVal
		var/sign = delta > 0 ? "+" : ""
		var/color = "white"
		if(delta > 0) color = "lime"
		if(delta < 0) color = "red"
		src << "<font color=white>[f]:</font> [oldVal] -> [newVal] (<font color=[color]>[sign][round(delta, 0.01)]</font>)"
	src << "<font color=cyan><b>=== End Diff ===</b></font>"

// AFK Detector — list players with client.inactivity > threshold (minutes).
mob/proc/AdminAFKCheck(threshold)
	if(threshold <= 0) threshold = 5
	var/thresholdTicks = threshold * 600  // 1 minute = 600 deciseconds
	src << "<font color=cyan><b>=== AFK Players (> [threshold] min idle) ===</b></font>"
	var/count = 0
	for(var/mob/Players/M in players)
		if(!M.client) continue
		if(M.client.inactivity >= thresholdTicks)
			var/idle = round(M.client.inactivity / 600, 0.1)
			src << "<font color=white>[M.name] ([M.key])</font> — idle [idle] min"
			count++
	if(!count)
		src << "<font color=white>(none)</font>"
	src << "<font color=cyan><b>=== [count] AFK ===</b></font>"

// Display CombatLog ring buffer of any mob to the admin.
mob/proc/AdminViewCombatLog(mob/M)
	if(!M)
		src << "<font color=red>Combat Log: target is null."
		return
	src << "<font color=cyan><b>=== Combat Log: [M] ([M.key]) ===</b></font>"
	if(!M.CombatLog || !M.CombatLog.len)
		src << "<font color=white>(empty)</font>"
	else
		for(var/entry in M.CombatLog)
			src << "<font color=white>[entry]</font>"
	src << "<font color=cyan><b>=== End ([M.CombatLog ? M.CombatLog.len : 0] events) ===</b></font>"

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

proc/ExtractInfo(var/atom/x)
	if(istype(x, /mob))
		var/mob/mx = x
		if(mx.client)
			return "[mx.key]</a href>([mx])"
	return "[x]([x.type])"


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

// Opt-out flag for buffs that force Anger on activation (Jinchuuriki M<3,
// Vaizard Mask, Wrathful, Hellbornfury, etc — anything with AutoAnger=1 or
// passives["AutoAnger"]=1). Read in _BuffX.dm at the BuffOn/BuffOff handlers.
// Default 0 = original behavior preserved for everyone.
/mob/var/AutoBerserkOptOut = 0

mob/verb
	Toggle_Auto_Berserk()
		set category = "Other"
		set name = "Toggle Auto Berserk"
		if(usr.AutoBerserkOptOut)
			usr.AutoBerserkOptOut = 0
			usr << "Auto Berserk re-enabled. Buffs that force Anger (Jinchuuriki, Vaizard Mask, Wrathful, etc.) will trigger it normally."
		else
			usr.AutoBerserkOptOut = 1
			usr << "Auto Berserk disabled. Buffs with the Auto Anger flag will no longer force you into the Anger state on activation."

mob/Admin3/verb
	editRace(mob/Players/m in players)
		set category = "Admin"
		var/mob/Admin2/adminSelf = usr
		adminSelf.Edit(m.race)
		for(var/ascension/a in m.race.ascensions)
			adminSelf.Edit(a)
	editInformation(mob/Players/m in players)
		set category = "Admin"
		var/mob/Admin2/adminSelf = usr
		adminSelf.Edit(m.information)

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
				Log("Admin", "[ExtractInfo(src)] removed [Choice] knowledge breakthrough from [ExtractInfo(m)]!")
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


	Test_Mode(mob/M in players)
		set category = "Admin"
		set name = "Test Mode"
		set desc = "Toggle off skill cooldowns on a player (applies TestMode passive)."
		if(!M.passive_handler)
			M.passive_handler = new
		if(M.HasTestMode())
			M.passive_handler.Set("TestMode", 0, TRUE)
			Log("Admin", "[ExtractInfo(usr)] disabled Test Mode on [ExtractInfo(M)].")
			usr << "Test Mode is now OFF for [M]."
			if(M.client)
				M << "Admin Test Mode is now OFF. Skill cooldowns are normal."
		else
			M.passive_handler.Set("TestMode", 1, TRUE)
			Log("Admin", "[ExtractInfo(usr)] enabled Test Mode on [ExtractInfo(M)].")
			usr << "Test Mode is now ON for [M]."
			if(M.client)
				M << "Admin Test Mode is now ON. Your skill cooldowns are effectively zero."

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
		/*if(istype(A, /mob))
			var/mob/M = A
			if(M.passive_handler.Get("Anti-Scrying") && M.passive_handler.Get("Rank-Down Protection"))
				var/antiscry = 1
				if(usr.passive_handler.Get("God's Gaze"))
					antiscry = 0
				else if(usr.HasGodKi())
					if(usr.passive_handler.Get("GodKi") > M.passive_handler.Get("GodKi"))
						antiscry = 0
				if(antiscry)
					usr << "<b><font color=[M.Text_Color]><font size=+1>[M] reflects your attempt at Scrying!</b></font color></font size>"
					M << "<b>A metaphysical entity has attempted to observe you!</b>"
					return*/
		Observify(usr,A)
		if(A!=src)
			src.Observing=2
			Log("Admin","[ExtractInfo(usr)] observed [A].")
		else
			src.Observing=0

	Delete(atom/A in world)
		set category="Admin"
		A = src.AdminResolveTargetedContent(A)

		if(istype(A,/area/))
			usr<<"You can't delete Areas."
			return
		Log("Admin","[ExtractInfo(usr)] has deleted [A]([A.type]).")
		if(ismob(A))
			var/mob/mob_a = A
			if(mob_a.client)
				Log("Admin","[ExtractInfo(usr)] booted [ExtractInfo(A)].")
				world<<"<font color=#FFFF00>[A] has been booted"
				del(mob_a.client)
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
				discord_output = "<@&1455270598635950333> [discord_output]"
				switch(input("IC Announcement or OOC Announcement?") in list("IC", "OOC"))
					if("IC")
						if(glob.discordICAnnounceWebhookURL)
							for(var/mob/M in admins) M<<"[usr] used message (global)."
							world.Export("[glob.discordICAnnounceWebhookURL]", list("content" = discord_output), 0, null, "POST")
						else
							usr << "The ICAnnounce webhook wasn't set up!"
					if("OOC")
						if(glob.discordOOCAnnounceWebhookURL)
							for(var/mob/M in admins) M<<"[usr] used message (global)."
							world.Export("[glob.discordOOCAnnounceWebhookURL]", list("content" = discord_output), 0, null, "POST")
						else
							usr << "The OOCAnnounce webhook wasn't set up!"
	Teleport(mob/M as mob|obj in world)
		set category="Admin"
		usr.PrevX=usr.x
		usr.PrevY=usr.y
		usr.PrevZ=usr.z
		loc=M.loc
		Log("Admin","[ExtractInfo(usr)] teleported to [M].")
	Summon(mob/M as mob|obj in world)
		set category="Admin"
		if(istype(M, /mob))
			M.PrevX=M.x
			M.PrevY=M.y
			M.PrevZ=M.z
		M.loc=loc
		Log("Admin","[ExtractInfo(usr)] summoned [ExtractInfo(M)].")
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
	SendToSpawnz(mob/A in players)
		set name="Send To Spawn"
		set category="Admin"
		MoveToSpawn(A)
		Log("Admin","[ExtractInfo(usr)] sent [ExtractInfo(A)] to spawn.")
/*	Teleport()
		set category="Admin"
		set name="Teleport"
		var/list/actions = list(
			"Jump to target",
			"Summon target to me",
			"Send target back (Unteleport)",
			"Teleport target to XYZ",
			"Send target to spawn"
		)
		if(usr.Admin >= 3)
			actions += "Mass Summon"
		actions += "Cancel"
		var/choice = input(usr, "Teleport action:", "Teleport") as null|anything in actions
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Jump to target")
				var/atom/M = AdminPickTarget("Jump to whom/what?", "Jump To", 1)
				if(!M) return
				usr.PrevX = usr.x
				usr.PrevY = usr.y
				usr.PrevZ = usr.z
				usr.loc = M.loc
				Log("Admin", "[ExtractInfo(usr)] teleported to [M].")
			if("Summon target to me")
				var/atom/movable/M = AdminPickTarget("Summon whom/what?", "Summon", 1)
				if(!M) return
				if(istype(M, /mob))
					var/mob/Mm = M
					Mm.PrevX = Mm.x
					Mm.PrevY = Mm.y
					Mm.PrevZ = Mm.z
				M.loc = usr.loc
				Log("Admin", "[ExtractInfo(usr)] summoned [ExtractInfo(M)].")
			if("Send target back (Unteleport)")
				var/mob/M = AdminPickTarget("Return whom?", "Send Back", 0)
				if(!M) return
				if(!M.PrevX)
					usr << "This mob/obj has not been teleported or summoned, and thus has no previous XYZ data."
					return
				M.x = M.PrevX
				M.y = M.PrevY
				M.z = M.PrevZ
				M.PrevX = null
				M.PrevY = null
				M.PrevZ = null
				usr << "Returned [M] to previous coordinates."
				M << "You have been returned to your previous coordinates by admins."
			if("Teleport target to XYZ")
				var/mob/M = AdminPickTarget("Teleport whom?", "Teleport to XYZ", 0)
				if(!M) return
				var/x = input(usr, "x", "[M]") as num|null
				if(isnull(x)) return
				var/y = input(usr, "y", "[M]") as num|null
				if(isnull(y)) return
				var/z = input(usr, "z", "[M]") as num|null
				if(isnull(z)) return
				M.PrevX = M.x
				M.PrevY = M.y
				M.PrevZ = M.z
				M.loc = locate(x, y, z)
				Log("Admin", "[ExtractInfo(usr)] teleported [ExtractInfo(M)] to [x],[y],[z].")
			if("Send target to spawn")
				var/mob/A = input(usr, "Send whom to spawn?", "Teleport") in players
				if(!A) return
				MoveToSpawn(A)
				Log("Admin", "[ExtractInfo(usr)] sent [ExtractInfo(A)] to spawn.")
			if("Mass Summon")
				if(usr.Admin < 3) return
				if(!usr.Alert("You sure you want to mass summon? You require express permission from no one in order to use this.")) return
				Log("Admin", "<font color=blue>[ExtractInfo(usr)] mass summoned!")
				var/who = input(usr, "Summon who?", "Mass Summon") as null|anything in list("Players", "Monsters", "Both", "Cancel")
				if(!who || who == "Cancel") return
				switch(who)
					if("Players")
						for(var/mob/Players/P in world)
							if(P.z == MAJIN_ABSORB_Z) continue
							P.loc = locate(usr.x + rand(-10,10), usr.y + rand(-10,10), usr.z)
					if("Monsters")
						for(var/mob/P in world)
							if(P.z == MAJIN_ABSORB_Z) continue
							if(!P.client)
								P.loc = locate(usr.x + rand(-10,10), usr.y + rand(-10,10), usr.z)
					if("Both")
						for(var/mob/P in world)
							if(P.z == MAJIN_ABSORB_Z) continue
							P.loc = locate(usr.x, usr.y, usr.z)*/

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
				var/mob/Players/pa = A
				glob.IDs[pa.UniqueID] = "[A.name]"


	Warper(_x as num,_y as num,_z as num)
		set category="Admin"
		src.MakeWarper(_x, _y, _z)

	AdminKill(mob/A in world)
		set category="Admin"
		set name="Admin Kill/KO"
		var/choice = input(usr, "Action on [A]:", "Admin Kill") as null|anything in list("Kill", "KO", "Cancel")
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Kill")
				usr.AdminDoKill(A)
			if("KO")
				usr.AdminDoKO(A)
	AdminDoDamage(mob/A in world)
		set category="Admin"
		set name="Do Damage"
		var/DamageType = input(usr, "What type of damage? Be careful with poison and burning due to their nature.") in list("Cancel", "True Damage", "Poison", "Burning", "Normal Damage")
		if(DamageType == "Cancel") return
		var/Damage = input(usr, "Inflict how much [DamageType]? Put in zero to cancel.") as null|num
		if(Damage == null) return
		if(istext(A.Health))
			A.Health = 100
			Log("Admin", "<font color=red>[A]'s Health variable was text for some reason! Resetting to 100.")
		if(DamageType == "True Damage")
			A.Health -= Damage
		else if(DamageType == "Poison")
			A.AddPoison(Damage)
		else if(DamageType == "Burning")
			A.AddBurn(Damage)
		else if(DamageType == "Normal Damage")
			usr.DoDamage(A, Damage)
		Log("Admin", "<font color=red>[ExtractInfo(usr)] did [Damage] [DamageType] to [ExtractInfo(A)].")
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


	AdminHeal(mob/A in world)
		set category="Admin"
		set name="Admin Heal"
		var/choice = input(usr, "Heal what on [A]?", "Admin Heal") as null|anything in list(
			"Basic (HP/Energy/Mana/Statuses)",
			"Full Restore",
			"Reset Capacity",
			"Reset Fatigue",
			"Reset Injury",
			"Remove Wounds",
			"Remove 1 Maim",
			"Cancel"
		)
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Basic (HP/Energy/Mana/Statuses)")
				if(A.KO)
					A.Conscious()
				A.Health = 100
				A.Energy = A.EnergyMax
				A.ManaAmount = A.ManaMax * A.GetManaCapMult()
				A.Burn = 0
				A.Poison = 0
				A.Slow = 0
				A.Shock = 0
				A.HealthAnnounce25 = 0
				A.HealthAnnounce10 = 0
				A.seventhSenseTriggered = 0
				Log("Admin", "<font color=aqua>[ExtractInfo(usr)] admin-healed [ExtractInfo(A)].")
			if("Full Restore")
				A.FullRestore()
				Log("Admin", "<font color=aqua>[ExtractInfo(usr)] complete-admin-healed [ExtractInfo(A)].")
			if("Reset Capacity")
				A.TotalCapacity = 0
				Log("Admin", "<font color=aqua>[ExtractInfo(usr)] admin-restored capacity for [ExtractInfo(A)].")
			if("Reset Fatigue")
				A.TotalFatigue = 0
				Log("Admin", "<font color=aqua>[ExtractInfo(usr)] admin-healed fatigue for [ExtractInfo(A)].")
			if("Reset Injury")
				A.TotalInjury = 0
				A.InjuryAnnounce = 0
				Log("Admin", "<font color=aqua>[ExtractInfo(usr)] admin-healed injury for [ExtractInfo(A)].")
			if("Remove Wounds")
				A.BPPoison = 1
				A.BPPoisonTimer = 0
				Log("Admin", "[ExtractInfo(usr)] removed [ExtractInfo(A)]'s wounds.")
				A << "Your wounds have been reduced."
			if("Remove 1 Maim")
				A.Maimed -= 1
				if(A.Maimed < 0)
					A.Maimed = 0
				Log("Admin", "[ExtractInfo(usr)] repaired [ExtractInfo(A)]'s maim wound.")
				A << "Your maim wound has been repaired!"
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

	Event_Character_Setup(mob/Players/M in players)
		set category="Admin"
		var/EMult=glob.progress.RPPBaseMult
		EMult*=M.GetRPPMult()
		M.RPPSpendable=getMaxPlayerRPP()
		M.PotentialRate=0
		M.Potential=input(src, "What potential do you want to set [M] to?", "Set Potential") as num
		if(M.isRace(/race/demi_fiend))
			M.refreshMagatama()
		M.ECCHARACTER=TRUE
		Log("Admin", "[ExtractInfo(src)] triggered [ExtractInfo(M)]'s event character setup!")
	Head_Start_Setup(mob/Players/M in players)
		set category="Admin"
		M.PotentialHeadStart=input(src, "What potential do you want to set [M] to?", "Set Head Start Potential") as num
		M.Potential=M.PotentialHeadStart
		M.RPPHeadStart=input(src, "What RPP cap do you want to set [M] to?", "Set Head RPP ") as num
		M.RPPHeadStart*=src.RPPMult
		M.RPPCurrent=M.RPPHeadStart
		if(M.isRace(/race/demi_fiend))
			M.refreshMagatama()
		Log("Admin", "[ExtractInfo(src)] triggered [ExtractInfo(M)]'s event character setup!")



	Edit(atom/A in world)
		set category = "Admin"
		A = src.AdminResolveTargetedContent(A)
		if(istype(A, /mob))
			var/mob/M = A
			if(M.passive_handler.Get("Rank-Down Protection") && !usr.passive_handler.Get("True Edit"))
				M.OMessage(15, "<b><font color=[M.Text_Color]><font size=+1>[M] was protected from the effects of Rank Magic!</b></font color></font size>", "<font color=blue>[M]([M.key]) cannot be Edited.")
				return

		var/list/browserOptions = list()
		browserOptions.Add("+find");
		winset(usr, null, list2params(browserOptions));
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
	Punish()
		set category="Admin"
		set name="Punish"
		var/choice = input(usr, "Punishment action:", "Punish") as null|anything in list(
			"Ban (target)",
			"Ban (manual — Key/IP/CID)",
			"UnBan",
			"Mute (target)",
			"UnMute",
			"Cancel"
		)
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Ban (target)")
				var/mob/M = input(usr, "Ban who?", "Punish") in players
				if(!M) return
				usr.AdminDoBan(M)
			if("Mute (target)")
				var/mob/M = input(usr, "Mute who?", "Punish") in players
				if(!M) return
				usr.AdminDoMute(M)
			if("Ban (manual — Key/IP/CID)")
				var/x = input(usr, "Input the desired Key to manual ban.", "Rebirth") as text|null
				var/y = input(usr, "Input the desired IP Address to manual ban.", "Rebirth") as text|null
				var/z = input(usr, "Input the desired Computer ID to manual ban.", "Rebirth") as text|null
				var/Reason = input(usr, "Why are you banning them?") as text
				var/Duration = 10000000000
				if(!usr.Alert("Are you sure you want to ban them for [Duration] Hours?")) return
				Duration = Value(world.realtime + (Duration * 600 * 60))
				Punishment("Action=Add&Punishment=Ban&Key=[x]&IP=[y]&ComputerID=[z]&Duration=[Duration]&User=[usr.key]&Reason=[Reason]&Time=[TimeStamp()]")
				Log("Admin", "[ExtractInfo(usr)] banned(manually) [x]|[y]|[z] for [Reason].")
			if("UnBan")
				var/list/people = list("Cancel")
				var/blah = input(usr, "What do you want to unban?", "Rebirth") in list("Entire List", "Key", "IP", "ComputerID", "Cancel")
				if(blah == "Cancel") return
				if(blah == "Entire List")
					for(var/x in Punishments)
						if(x["Punishment"] == "Ban")
							people.Add(x["Key"])
					var/person = input(usr, "Completely Unban who?", "Rebirth") in people
					if(person == "Cancel") return
					for(var/x in Punishments)
						if(x["Punishment"] == "Ban")
							if(x["Key"] == person)
								Punishments.Remove(list(x))
								Log("Admin", "[ExtractInfo(usr)] unbanned(all) [person].")
				else
					for(var/x in Punishments)
						if(x["Punishment"] == "Ban")
							people.Add(x["[blah]"])
					var/person = input(usr, "[blah] Unban who?", "Rebirth") in people
					if(person == "Cancel") return
					Punishment("Action=Remove&Punishment=Ban&[blah]=[person]")
					Log("Admin", "[ExtractInfo(usr)] unbanned [person].")
			if("UnMute")
				var/list/people = list("Cancel")
				var/blah = input(usr, "What do you want to unmute?", "Rebirth") in list("Entire List", "Key", "IP", "ComputerID", "Cancel")
				if(blah == "Cancel") return
				if(blah == "Entire List")
					for(var/x in Punishments)
						if(x["Punishment"] == "Mute")
							people.Add(x["Key"])
					var/person = input(usr, "Completely Unmute who?", "Rebirth") in people
					if(person == "Cancel") return
					for(var/x in Punishments)
						if(x["Punishment"] == "Mute")
							if(x["Key"] == person)
								Punishments.Remove(list(x))
								Log("Admin", "[ExtractInfo(usr)] unmuted(all) [person].")
				else
					for(var/x in Punishments)
						if(x["Punishment"] == "Mute")
							people.Add(x["[blah]"])
					var/person = input(usr, "[blah] Unmute who?", "Rebirth") in people
					if(person == "Cancel") return
					Punishment("Action=Remove&Punishment=Mute&[blah]=[person]")
					Log("Admin", "[ExtractInfo(usr)] unmuted [person].")
	FixSSJTransformations(mob/M in players)
		set category="Admin"
		set name="Fix SSJ Transformations"
		if(!M.client)
			return
		var/choice = input(usr, "Which transformation set to apply to [M]?", "Fix SSJ Transformations") as null|anything in list("SSJ1-4 + Limit Breaker", "SSJ1-3 + God + Blue", "Add SSJ5", "Cancel")
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("SSJ1-4 + Limit Breaker")
				for(var/transformation/saiyan/ssj in M.race.transformations)
					M.race.transformations -= ssj
					del ssj
				M.race.transformations += new /transformation/saiyan/super_saiyan()
				M.race.transformations += new /transformation/saiyan/super_saiyan_2()
				M.race.transformations += new /transformation/saiyan/super_saiyan_3()
				M.race.transformations += new /transformation/saiyan/super_saiyan_4()
				M.race.transformations += new /transformation/saiyan/super_full_power_saiyan_4_limit_breaker()
				M << "<b>Your transformations have been fixed!!! You'll have to ask an admin to remaster them.</b>"
			if("SSJ1-3 + God + Blue")
				for(var/transformation/saiyan/ssj in M.race.transformations)
					M.race.transformations -= ssj
					del ssj
				M.race.transformations += new /transformation/saiyan/super_saiyan()
				M.race.transformations += new /transformation/saiyan/super_saiyan_2()
				M.race.transformations += new /transformation/saiyan/super_saiyan_3()
				M.race.transformations += new /transformation/saiyan/super_saiyan_god()
				M.race.transformations += new /transformation/saiyan/super_saiyan_blue()
				M.race.transformations += new /transformation/saiyan/super_saiyan_blue_evolved()
				M << "<b>Your transformations have been fixed!!! You'll have to ask an admin to remaster them.</b>"
			if("Add SSJ5")
				for(var/transformation/saiyan/super_saiyan_5/ssj in M.race.transformations)
					M.race.transformations -= ssj
					del ssj
				M.race.transformations += new /transformation/saiyan/super_saiyan_5()
				M << "You have been granted Super Saiyan 5."
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
	/*		if(isRace(SAIYAN) && blah == 1 && M.oozaru_type=="Demonic")
				for(var/transformation/saiyan/hellspawn/hellspawn_super_saiyan/ssj in M.race.transformations)
					race.transformations += ssj
			if(isRace(SAIYAN) && blah == 2 && M.oozaru_type=="Demonic")
				for(var/transformation/saiyan/hellspawn/hellspawn_super_saiyan_2/ssj2 in M.race.transformations)
					race.transformations += ssj2*/
			if(M.isRace(CELESTIAL) && M.CelestialAscension == "Angel" && blah == 1)
				if(!locate(/transformation/celestial/Master_of_Arms) in M.race.transformations)
					M.race.transformations += new/transformation/celestial/Master_of_Arms
			if(M.isRace(CELESTIAL) && M.CelestialAscension == "Demon" && blah == 1)
				if(!locate(/transformation/celestial/Celestial_Devil_Trigger) in M.race.transformations)
					M.race.transformations += new/transformation/celestial/Celestial_Devil_Trigger
			if(M.isRace(CELESTIAL) && M.CelestialAscension == "Demon" && blah == 2)
				if(!locate(/transformation/celestial/Celestial_Sin_Devil_Trigger) in M.race.transformations)
					M.race.transformations += new/transformation/celestial/Celestial_Sin_Devil_Trigger
			if(M.isRace(SAIYAN) && blah == 4)
				var/godor4 = input("SSJ God or SSJ4?") in list("Daima SSJ4", "GT SSJ4")
				if(godor4 == "GT SSJ4")
					for(var/transformation/saiyan/ssj in M.race.transformations)
						if(istype(ssj, /transformation/saiyan/super_saiyan_god) || istype(ssj, /transformation/saiyan/super_saiyan_blue)|| istype(ssj, /transformation/saiyan/super_saiyan_blue_evolved)|| istype(ssj, /transformation/saiyan/super_saiyan_4_daima))
							M.race.transformations -= ssj
							del ssj
					M.AddSkill(new/obj/Skills/False_Moon)
				else
					for(var/transformation/saiyan/ssj in M.race.transformations)
						if(istype(ssj, /transformation/saiyan/super_saiyan_4)||istype(ssj, /transformation/saiyan/super_full_power_saiyan_4_limit_breaker))
							M.race.transformations -= ssj
							del ssj
			if(M.isRace(HALFSAIYAN) && blah == 4)
				var/godor4 = input("SSJ Rage or SSJ4?") in list("SSJ Rage/Beast", "SSJ4")
				if(godor4 == "SSJ4")
					for(var/transformation/saiyan/ssj in M.race.transformations)
						if(istype(ssj, /transformation/half_saiyan/human/beast_mode))
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

	RPP()
		set category="Admin"
		set name="RPP"
		var/list/actions = list(
			"Set target's total RPP",
			"Refund target's skill",
			"Trigger routine gain for target",
			"Equalize target to value",
			"Trigger routine gain for EVERYONE",
			"Equalize EVERYONE to value",
			"Set starting RPP value (new chars)",
			"Set starting RPP days (new chars)"
		)
		if(usr.Admin >= 4)
			actions += list(
				"Set RPP limit (Owner)",
				"Set RPP base multiplier (Owner)",
				"Set daily RPP increment (Owner)"
			)
		actions += "Cancel"
		var/choice = input(usr, "RPP action:", "RPP") as null|anything in actions
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Set target's total RPP")
				var/mob/Players/P = input(usr, "Set whose RPP?", "RPP") in players
				if(!P) return
				var/EMult = glob.progress.RPPBaseMult
				EMult *= P.GetRPPMult()
				var/OldRPP = P.RPPSpent + P.GetRPPSpendable()
				var/NewRPP = input(usr, "Set the value that [P]'s RPP should be at.  They currently have [Commas(P.GetRPPSpendable())] with [Commas(P.RPPSpent)] RPP spent for [Commas(OldRPP)] total. (x[EMult] RPP Mult)") as num|null
				NewRPP *= EMult
				NewRPP -= P.RPPSpent
				if(NewRPP >= 0)
					P.RPPSpendable = NewRPP
					Log("Admin", "[ExtractInfo(usr)] set [ExtractInfo(P)]'s total RPP (Spent and Unused) from [Commas(OldRPP)] to [Commas(NewRPP)]. (RPP mult of x[EMult])")
			if("Refund target's skill")
				var/mob/Players/P = input(usr, "Refund whose skill?", "RPP") in players
				if(!P) return
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
			if("Trigger routine gain for target")
				var/mob/Players/P = input(usr, "Routine gain for whom?", "RPP") in players
				if(!P) return
				var/AddRPP = glob.progress.RPPDaily
				var/YourRPP = AddRPP
				if(YourRPP > 0)
					if(locate(/obj/Skills/Utility/Teachz, P))
						var/ElderMult = 0.5
						if(P.EraBody == "Senile" || P.isRace(SHINJIN))
							ElderMult = 1
						P.RPPDonate += (YourRPP * ElderMult * P.RPPMult * glob.progress.RPPBaseMult)
						P << "You have gained knowledge on how to help further other's development!"
					var/EMult = glob.progress.RPPBaseMult
					EMult *= P.GetRPPMult()
					YourRPP *= EMult
					P.RPPSpendable += round(YourRPP)
				if((P.EraBody != "Child" || !P.EraBody) && !P.Dead)
					var/AgeMult = 1
					if(P.EraBody == "Youth" || P.EraBody == "Elder")
						AgeMult = 0.5
					if(P.EraBody == "Senile")
						AgeMult = 0.25
					P.GiveMoney(round(glob.progress.EconomyIncome * P.EconomyMult * P.Intelligence * AgeMult))
				Log("Admin", "[ExtractInfo(src)] triggered [ExtractInfo(P)]'s routine RPP gains of [Commas(AddRPP)].")
			if("Equalize target to value")
				var/mob/Players/P = input(usr, "Equalize whose RPP?", "RPP") in players
				if(!P) return
				var/Cap = input(usr, "Input the RPP value target will be brought to.") as num
				var/YourRPP = Cap
				if(YourRPP > 0)
					if(locate(/obj/Skills/Utility/Teachz, P))
						var/ElderMult = 0.5
						if(P.EraBody == "Senile" || P.isRace(SHINJIN))
							ElderMult = 1
						P.RPPDonate = (Cap * ElderMult * P.RPPMult * glob.progress.RPPBaseMult)
						P << "You have gained knowledge on how to help further other's development!"
					var/EMult = glob.progress.RPPBaseMult
					EMult *= P.GetRPPMult()
					YourRPP *= EMult
					P.RPPSpendable = YourRPP - P.RPPSpent
				Log("Admin", "[ExtractInfo(src)] triggered RPP equalization for [P].")
			if("Trigger routine gain for EVERYONE")
				var/AddRPP = glob.progress.RPPDaily
				for(var/mob/Players/P in players)
					var/YourRPP = AddRPP
					if(YourRPP > 0)
						if(locate(/obj/Skills/Utility/Teachz, P))
							var/ElderMult = 0.5
							if(P.EraBody == "Senile" || P.isRace(SHINJIN))
								ElderMult = 1
							P.RPPDonate += (YourRPP * ElderMult * P.RPPMult * glob.progress.RPPBaseMult)
							P << "You have gained knowledge on how to help further other's development!"
						var/EMult = glob.progress.RPPBaseMult
						EMult *= P.GetRPPMult()
						YourRPP *= EMult
						P.RPPSpendable += YourRPP
					if((P.EraBody != "Child" || !P.EraBody) && !P.Dead)
						P << "You gain money from routine tasks."
						var/AgeMult = 1
						P.GiveMoney(round(glob.progress.EconomyIncome * P.EconomyMult * P.Intelligence * AgeMult))
				glob.progress.RPPStarting += AddRPP
				Log("Admin", "[ExtractInfo(src)] triggered routine RPP gains of [Commas(AddRPP)].")
			if("Equalize EVERYONE to value")
				var/Cap = input(usr, "Input the RPP value everyone will be brought to.") as num
				for(var/mob/Players/P in players)
					var/YourRPP = Cap
					if(YourRPP > 0)
						if(locate(/obj/Skills/Utility/Teachz, P))
							var/ElderMult = 0.5
							if(P.EraBody == "Senile" || P.isRace(SHINJIN))
								ElderMult = 1
							P.RPPDonate = (Cap * ElderMult * P.RPPMult * glob.progress.RPPBaseMult)
							P << "You have gained knowledge on how to help further other's development!"
						var/EMult = glob.progress.RPPBaseMult
						EMult *= P.GetRPPMult()
						YourRPP *= EMult
						P.RPPSpendable = YourRPP - P.RPPSpent
				glob.progress.RPPStarting = Cap
				Log("Admin", "[ExtractInfo(src)] triggered RPP equalization.")
			if("Set starting RPP value (new chars)")
				var/val = input(usr, "What is the starting RPP value?", "Starting RPP") as num|null
				if(val <= 0 || val == null) return
				glob.progress.RPPStarting = val
				Log("Admin", "[ExtractInfo(usr)] set the global RPP starting value to [glob.progress.RPPStarting]. It will be acquired in [glob.progress.RPPStartingDays] days after making a new character.")
			if("Set starting RPP days (new chars)")
				var/val = input(usr, "What is the number of days it takes to reach the starting RPP value?", "Starting RPP Days") as num|null
				if(val <= 0 || val == null) return
				glob.progress.RPPStartingDays = val
				Log("Admin", "[ExtractInfo(usr)] set the global RPP starting value to [glob.progress.RPPStarting]. It will be acquired in [glob.progress.RPPStartingDays] days after making a new character.")
			if("Set RPP limit (Owner)")
				if(usr.Admin < 4) return
				var/val = input(usr, "RPP limit?", "RPP Limit") as num|null
				if(isnull(val)) return
				glob.progress.RPPLimit = val
			if("Set RPP base multiplier (Owner)")
				if(usr.Admin < 4) return
				var/val = input(usr, "RPP base multiplier?", "RPP Base Mult") as num|null
				if(isnull(val)) return
				glob.progress.RPPBaseMult = val
				Log("Admin", "[ExtractInfo(src)] set the RPP Base Mult to [glob.progress.RPPBaseMult]x.")
			if("Set daily RPP increment (Owner)")
				if(usr.Admin < 4) return
				var/val = input(usr, "Daily RPP increment?", "Daily RPP") as num|null
				if(isnull(val)) return
				glob.progress.RPPDaily = val
				Log("Admin", "[ExtractInfo(src)] set the daily RPP increment to [Commas(glob.progress.RPPDaily)].")
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

	Give_Currency(mob/p in players)
		set category="Admin"
		set name="Give Currency"
		var/choice = input(usr, "Give what to [p]?", "Give Currency") as null|anything in list("Money", "Fragments", "Cancel")
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Money")
				var/num = input(usr, "How much money?", "Give Money") as num|null
				if(isnull(num)) return
				var/Highest = glob.progress.EconomyMult
				if(p.EconomyMult > Highest)
					Highest = p.EconomyMult
				p.GiveMoney(num * Highest)
				Log("Admin", "[ExtractInfo(usr)] increased [p]'s money by [Commas(num)] (x[Highest] economy mult).")
			if("Fragments")
				if(!p.client) return
				var/obj/Items/mineral/m = locate() in p
				if(!m)
					m = new()
					m.Move(p)
				m.checkDuplicate(p)
				var/num = input(usr, "How many fragments?", "Give Fragments") as num|null
				if(isnull(num)) return
				m.value += num
				m.assignState(num)
				Log("Admin", "[ExtractInfo(usr)] gave [p] [num] mineral fragments.")

	Adminize(mob/z in players)
		set category="Admin"
		var/x=input("What level?(0-3)","0-3",z.Admin)as num
		if(x>=0&&x<=3)
			Log("Admin","[ExtractInfo(usr)] set [ExtractInfo(z)]'s admin level to [x].")
			if(x==0)
				z.Admin("Remove")
			else
				z.Admin("Give",x)



	DeleteSave(mob/Players/M in players)
		set category="Admin"
		switch(input(usr,"Delete [M]'s save?") in list("No","Yes"))
			if("Yes")
				var/reason=input("For what reason?") as text
				M.Savable=0
				// Free the Majin's absorb room (and release any victims)
				if(M.isRace(MAJIN))
					M.MajinCleanupOnDeletion()
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
			world<<"araki upscale"
			shutdown()

	SaveWorld()
		set category="Admin"
		BootWorld("Save")
		for(var/mob/Players/Q in players)
			if(Q.Savable)
				Q.client.SaveChar()

	SaveTurfsObjs()
		set category="Admin"
		find_savableObjects()
		Save_Turfs()
		Save_Objects()
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
	Overwatch()
		set category="Admin"
		set name="Overwatch"
		var/list/categories = list(
			"Stealth & Movement",
			"View & Observe",
			"Inspection",
			"Watch & Listen",
			"Combat Log",
			"Give Resources",
			"Give All Skills",
			"Restore all defaults",
			"Cancel"
		)
		var/category = input(usr, "Overwatch category:", "Overwatch") as null|anything in categories
		if(!category || category == "Cancel") return
		if(!usr.AdminOverwatchActive && category != "Restore all defaults")
			usr.AdminOverwatchActive = 1
			usr.density = 0
			usr.NoDeath = 1
			usr << "<font color=green><b>Overwatch:</b> Protection ON — immortal, no-clip, click-teleport."
		switch(category)
			if("Stealth & Movement")
				var/list/actions = list(
					"Toggle Full Stealth",
					"Quick Jump to player",
					"Track player (auto-follow)",
					"Stop tracking",
					"Cancel"
				)
				var/choice = input(usr, "Stealth & Movement:", "Overwatch") as null|anything in actions
				if(!choice || choice == "Cancel") return
				switch(choice)
					if("Toggle Full Stealth")
						if(usr.AdminFullStealth)
							usr.AdminFullStealthDisable()
						else
							usr.AdminFullStealthEnable()
					if("Quick Jump to player")
						var/mob/M = input(usr, "Jump to whom?", "Overwatch") as null|mob in players
						if(!M) return
						if(!M.loc)
							usr << "<font color=red>[M] has no location."
							return
						usr.loc = M.loc
						usr << "<font color=green><b>Overwatch:</b> Jumped to [M]'s location."
						Log("Admin", "[ExtractInfo(usr)] Overwatch-jumped to [ExtractInfo(M)].")
					if("Track player (auto-follow)")
						var/mob/M = input(usr, "Track whom?", "Overwatch") as null|mob in players
						if(!M) return
						if(!M.client)
							usr << "<font color=red>[M] has no client."
							return
						usr.AdminTrackTarget = M
						usr << "<font color=green><b>Overwatch:</b> Now auto-following [M]. Use 'Stop tracking' to release."
						Log("Admin", "[ExtractInfo(usr)] Overwatch-tracking [ExtractInfo(M)].")
						usr.AdminTrackLoop()
					if("Stop tracking")
						if(usr.AdminTrackTarget)
							usr << "<font color=green><b>Overwatch:</b> Stopped tracking [usr.AdminTrackTarget]."
							usr.AdminTrackTarget = null
						else
							usr << "<font color=red>You are not tracking anyone."

			if("View & Observe")
				var/list/actions = list(
					"Silent Observe (view target's screen)",
					"Return camera to self",
					"Cancel"
				)
				var/choice = input(usr, "View & Observe:", "Overwatch") as null|anything in actions
				if(!choice || choice == "Cancel") return
				switch(choice)
					if("Silent Observe (view target's screen)")
						var/mob/M = input(usr, "Whose screen do you want to view?", "Overwatch") as null|mob in players
						if(!M) return
						if(!M.client)
							usr << "<font color=red>[M] has no client."
							return
						if(usr.client.perspective == MOB_PERSPECTIVE)
							usr.client.perspective = EYE_PERSPECTIVE
						usr.client.eye = M
						usr << "<font color=green><b>Overwatch:</b> You now see through [M]'s screen. They have not been notified."
						Log("Admin", "[ExtractInfo(usr)] silently observing [ExtractInfo(M)] (Overwatch).")
					if("Return camera to self")
						usr.client.perspective = MOB_PERSPECTIVE
						usr.client.eye = usr
						usr << "<font color=green><b>Overwatch:</b> Camera returned to self."

			if("Inspection")
				var/list/actions = list(
					"Player Snapshot",
					"Var Inspector (filtered)",
					"Snapshot Save (capture state)",
					"Snapshot Compare (diff vs saved)",
					"AFK Check",
					"Cancel"
				)
				var/choice = input(usr, "Inspection:", "Overwatch") as null|anything in actions
				if(!choice || choice == "Cancel") return
				switch(choice)
					if("Player Snapshot")
						var/mob/M = input(usr, "Snapshot whom?", "Overwatch") as null|mob in players
						if(!M) return
						usr.AdminPlayerSnapshot(M)
					if("Var Inspector (filtered)")
						var/mob/M = input(usr, "Inspect whom?", "Overwatch") as null|mob in players
						if(!M) return
						var/filter = input(usr, "Filter substring (e.g. 'health', 'mana', or empty for all):", "Overwatch") as text|null
						usr.AdminVarInspect(M, filter ? filter : "")
					if("Snapshot Save (capture state)")
						var/mob/M = input(usr, "Save snapshot of whom?", "Overwatch") as null|mob in players
						if(!M) return
						usr.AdminSnapshotSave(M)
					if("Snapshot Compare (diff vs saved)")
						var/mob/M = input(usr, "Compare against current state of whom?", "Overwatch") as null|mob in players
						if(!M) return
						usr.AdminSnapshotCompareRun(M)
					if("AFK Check")
						var/threshold = input(usr, "AFK threshold in minutes (default 5):", "Overwatch") as num|null
						usr.AdminAFKCheck(threshold ? threshold : 5)

			if("Watch & Listen")
				var/list/actions = list(
					"Toggle Listen Mode (all chat)",
					"Add player to watchlist",
					"Remove player from watchlist",
					"Show watchlist",
					"Clear watchlist",
					"Cancel"
				)
				var/choice = input(usr, "Watch & Listen:", "Overwatch") as null|anything in actions
				if(!choice || choice == "Cancel") return
				switch(choice)
					if("Toggle Listen Mode (all chat)")
						if(usr.AdminListenMode)
							usr.AdminListenMode = 0
							usr << "<font color=red><b>Overwatch:</b> Listen Mode OFF."
						else
							usr.AdminListenMode = 1
							usr << "<font color=green><b>Overwatch:</b> Listen Mode ON. You will receive a copy of all OMessage and MSay broadcasts globally."
					if("Add player to watchlist")
						var/mob/M = input(usr, "Add whom to watchlist?", "Overwatch") as null|mob in players
						if(!M) return
						usr.AdminWatchAdd(M.key)
					if("Remove player from watchlist")
						if(!usr.AdminWatchList || !usr.AdminWatchList.len)
							usr << "<font color=red>Your watchlist is empty."
							return
						var/targetKey = input(usr, "Remove which key?", "Overwatch") as null|anything in usr.AdminWatchList
						if(!targetKey) return
						usr.AdminWatchRemove(targetKey)
					if("Show watchlist")
						if(!usr.AdminWatchList || !usr.AdminWatchList.len)
							usr << "<font color=cyan><b>Overwatch:</b> Watchlist is empty."
							return
						usr << "<font color=cyan><b>=== Overwatch Watchlist ([usr.AdminWatchList.len]) ===</b></font>"
						for(var/k in usr.AdminWatchList)
							usr << "<font color=white>[k]</font>"
					if("Clear watchlist")
						usr.AdminWatchList = list()
						usr << "<font color=green><b>Overwatch:</b> Watchlist cleared."

			if("Combat Log")
				var/list/actions = list(
					"View player combat log",
					"Clear player combat log",
					"Cancel"
				)
				var/choice = input(usr, "Combat Log:", "Overwatch") as null|anything in actions
				if(!choice || choice == "Cancel") return
				switch(choice)
					if("View player combat log")
						var/mob/M = input(usr, "View whose combat log?", "Overwatch") as null|mob in players
						if(!M) return
						usr.AdminViewCombatLog(M)
					if("Clear player combat log")
						var/mob/M = input(usr, "Clear whose combat log?", "Overwatch") as null|mob in players
						if(!M) return
						M.CombatLog = list()
						usr << "<font color=green><b>Overwatch:</b> Cleared combat log of [M]."

			if("Give Resources")
				var/mob/M = input(usr, "Give resources to whom?", "Overwatch — Give") as null|mob in players
				if(!M) return
				var/list/resources = list(
					"RPP (Spendable)",
					"Money (Zenni)",
					"Potential",
					"Power Level",
					"Health",
					"Energy (Current)",
					"Energy (Max)",
					"Mana (Current)",
					"Mana (Max)",
					"Saga Level",
					"Cancel"
				)
				var/res = input(usr, "What resource to give to [M]?", "Overwatch — Give") as null|anything in resources
				if(!res || res == "Cancel") return
				var/amount = input(usr, "How much [res]?", "Overwatch — Give") as null|num
				if(!amount) return
				switch(res)
					if("RPP (Spendable)")
						M.RPPSpendable += amount
						M.RPPCurrent += amount
					if("Money (Zenni)")
						M.GiveMoney(amount)
					if("Potential")
						M.Potential += amount
					if("Power Level")
						M.Power += amount
					if("Health")
						M.Health += amount
					if("Energy (Current)")
						M.Energy += amount
					if("Energy (Max)")
						M.EnergyMax += amount
					if("Mana (Current)")
						M.ManaAmount += amount
					if("Mana (Max)")
						M.ManaMax += amount
					if("Saga Level")
						M.SagaLevel += amount
				usr << "<font color=green><b>Overwatch:</b> Gave [amount] [res] to [M]."

			if("Give All Skills")
				var/mob/M = input(usr, "Give all skills to whom?", "Overwatch — Give All Skills") as null|mob in players
				if(!M) return
				var/count = 0
				for(var/T in subtypesof(/obj/Skills))
					if(!ispath(T)) continue
					if(locate(T) in M) continue
					var/obj/Skills/S = new T
					if(S)
						M.AddSkill(S)
						count++
				usr << "<font color=green><b>Overwatch:</b> Gave [count] skills to [M]."

			if("Restore all defaults")
				if(usr.AdminFullStealth)
					usr.AdminFullStealthDisable()
				if(usr.AdminTrackTarget)
					usr.AdminTrackTarget = null
				if(usr.AdminListenMode)
					usr.AdminListenMode = 0
				if(usr.AdminOverwatchActive)
					usr.AdminOverwatchActive = 0
					usr.density = initial(usr.density)
					usr.NoDeath = 0
				usr.client.perspective = MOB_PERSPECTIVE
				usr.client.eye = usr
				usr << "<font color=green><b>Overwatch:</b> All defaults restored. Stealth/track/listen/protection off, camera on self. Watchlist preserved."

	Wipe()
		set category="Admin"
		set name="Wipe"
		var/choice = input(usr, "Wipe action:", "Wipe") as null|anything in list(
			"Start wipe (set today as Day 1)",
			"Restart wipe (to specific day)",
			"Push forward 24h",
			"Cancel"
		)
		if(!choice || choice == "Cancel") return
		switch(choice)
			if("Start wipe (set today as Day 1)")
				switch(alert(usr, "Are you sure you want to set the start time of the wipe to midnight today?", "Are you sure you want to suffer through another wipe?", "Yes", "Hell Fucking Yes", "No"))
					if("No")
						return
					if("Hell No")
						return
				glob.progress.DaysOfWipe = 1
			//	glob.progress.totalPotentialToDate = 1
				glob.progress.WipeStart = world.realtime - world.timeofday
				Log("Admin", "[ExtractInfo(src)] has set the official start date of the wipe.")
			if("Restart wipe (to specific day)")
				var/val = input(src, "What day of the wipe are you currently on?", "Wipe Restart") as num|null
				if(val && val > 0)
					glob.progress.DaysOfWipe = 0
					glob.progress.WipeStart = Today() - Day(val)
					Log("Admin", "[ExtractInfo(src)] has reset the official wipe start date. It is now day [val] of the wipe.")
			if("Push forward 24h")
				glob.progress.WipeStart -= 24 HOURS
				DaysOfWipe()
				Log("Admin", "[ExtractInfo(src)] pushed the wipe forward by 24 hours.")
	Potential_Daily_Set()
		set category="Admin"
		var/val=input(src, "How much potential is gained daily?", "Potential Daily") as num|null
		if(val&&val>0)
			glob.progress.PotentialDaily=val
			Log("Admin", "[ExtractInfo(src)] has set the daily potential rate to [glob.progress.PotentialDaily].")
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
	Give_Rare_Race(mob/Players/P in players)
		set category="Admin"
		set name="Give Rare Race"
		if(!P || !P.ckey)
			usr << "<font color=red>Invalid target."
			return
		var/list/rares = list()
		for(var/race/r in races)
			if(!r) continue
			if(r.removed) continue
			if(!r.locked) continue
			rares += r.name
		if(!rares.len)
			usr << "<font color=red>No rare races are currently marked as locked."
			return
		var/Choice = input(usr, "Which rare race do you want to give [P]?", "Give Rare Race") as null|anything in rares
		if(!Choice) return
		var/race/selected
		for(var/race/r in races)
			if(r.name == Choice)
				selected = r
				break
		if(!selected)
			usr << "<font color=red>Could not resolve race [Choice]."
			return
		var/Confirm = alert(usr, "Change [P]'s race to [Choice] and unlock it for their key?", "Give Rare Race", "Yes", "No")
		if(Confirm != "Yes") return
		glob.LockedRaces[P.ckey] = Choice
		P.setRace(selected.type, FALSE)
		P << "<font color=yellow>An admin has changed your race to [Choice]."
		Log("Admin", "[ExtractInfo(usr)] changed [ExtractInfo(P)]'s race to [Choice].")

	Make_True_Demon(mob/Players/target in players)
		set category = "Admin"
		set name = "Make True Demon"

		if(!target || !target.ckey)
			src << "<font color=red>Invalid target.</font>"
			return

		if(!target.isRace(/race/demi_fiend))
			src << "<font color=red>[target] is not a Demi-fiend.</font>"
			return

		if(!target.race || !target.race.ascensions || target.race.ascensions.len < 1)
			src << "<font color=red>[target] has not yet taken their first ascension.</font>"
			return

		var/ascension/asc_one = target.race.ascensions[1]
		if(!asc_one || !asc_one.applied)
			src << "<font color=red>[target]'s first ascension has not been applied yet.</font>"
			return

		if(asc_one.choiceSelected == /ascension/sub_ascension/demi_fiend/true_demon)
			src << "<font color=orange>[target] is already on the True Demon path.</font>"
			return

		var/confirm = alert(src, "Place [target] on the True Demon path? Their current Reason passive will be removed and all equipped Magatama will be unequipped.", "Make True Demon", "Yes", "No")
		if(confirm != "Yes") return

		// Unequip all Magatama before the swap, mostly for Shijima
		for(var/obj/Items/Magatama/M in target)
			if(M.suffix == "*Equipped*")
				M.unequipMagatama(target)
		// Clear any Shijima-set swap cooldowns
		target.magatama_cooldown_until = 0
		target.magatama_allowed_set = list()

		// Revert the existing Reason sub-ascension, if any
		if(asc_one.choiceSelected)
			var/ascension/old_asc = new asc_one.choiceSelected
			old_asc.applied = TRUE
			old_asc.revertAscension(target)

		// Apply True Demon sub-ascension
		asc_one.choiceSelected = /ascension/sub_ascension/demi_fiend/true_demon
		var/ascension/sub_ascension/demi_fiend/true_demon/new_asc = new
		new_asc.onAscension(target)

		// Recalculate Magatama passives now that the Reason has changed
		target.refreshMagatama()

		target << "<font color='#cc0000'><b>The chains of Reason have been cast aside. You walk the True Demon path.</b></font>"
		Log("Admin", "[ExtractInfo(src)] placed [ExtractInfo(target)] on the True Demon path.")
		src << "<font color=yellow>[target] is now on the True Demon path.</font>"

	Give_Demon(mob/Players/target in players)
		set category = "Admin"
		set name = "Give Demon"

		if(!target || !target.ckey)
			src << "<font color=red>Invalid target.</font>"
			return

		if(target.Saga != "Devil Summoner")
			src << "<font color=red>[target] does not have the Devil Summoner Saga.</font>"
			return

		if(!DEMON_DB || !DEMON_DB.len)
			src << "<font color=red>Demon database is empty.</font>"
			return

		var/list/demon_choices = list()
		for(var/dname in DEMON_DB)
			var/datum/demon_data/dd = DEMON_DB[dname]
			if(!dd) continue
			demon_choices["[dname] (Lv[dd.demon_lvl] [dd.demon_race])"] = dname

		if(!demon_choices.len)
			src << "<font color=red>No valid demons found in the database.</font>"
			return

		var/choice = input(src, "Select a demon to give [target]. If their party is full, it will be recorded in their Compendium instead.", "Give Demon") as null|anything in demon_choices
		if(!choice) return

		var/demon_name = demon_choices[choice]
		if(!demon_name) return

		if(target.DemonInParty(demon_name))
			src << "<font color=red>[target] already has [demon_name] in their party.</font>"
			return

		if(target.demon_party && target.demon_party.len >= target.demon_party_cap)
			if(target.demon_compendium && (demon_name in target.demon_compendium))
				src << "<font color=red>[target]'s party is full and [demon_name] is already in their compendium.</font>"
				return

		target.AddDemonToRoster(demon_name)
		Log("Admin", "[ExtractInfo(src)] gave [ExtractInfo(target)] demon [demon_name].")

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

		Log("Admin", "[ExtractInfo(src)] set [m]'s [changing] to [changeto] increase per ascension!")


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
/*	Makyo_Toggle(var/Z as num)
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
		Log("Admin", "[ExtractInfo(usr)] made the Star departure message: ([global.MakyoSetMessage])") */


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

		var/mob/Admin2/adminSelf = usr
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
			adminSelf.Edit(src)
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
		adminSelf.Edit(src)

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
	if(B["action"]=="giveobj")
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
	if(href_list["action"] == "GetInfo")
		if(href_list["passe"] in PassiveInfo) usr.OutputPassiveInfo(href_list["passe"]);

	if(Admin)
		var/mob/Admin2/adminSelf = usr
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
						if(istype(theList[old_index], /datum))
							options += "Open Edit Sheet"
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
								adminSelf.Edit(theList[old_index])
						theList[theList[old_index]] = old_value
					if("value")
						var/old_key = theList[old_index]
						var/list/options = list("text","num","type","reference","icon","file","list","restore to default")
						if(isdatum(theList[old_index]))
							var/datum/d = theList[old_index]
							if(d && d.type)
								options += "Open Edit Sheet"
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
								adminSelf.Edit(theList[old_key])
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

// Right-click admin teleport verbs — only added to admin mobs via typesof() in the admin grant proc

mob/Admin1/verb/Admin_Jump_To()
	set src in oview()
	set name = "Admin: Jump To"
	set category = null
	var/mob/Players/admin = usr
	if(!istype(admin)) return
	if(!admin.Admin) return
	admin.PrevX = admin.x
	admin.PrevY = admin.y
	admin.PrevZ = admin.z
	admin.loc = src.loc
	admin << "Jumped to [src]."
	Log("Admin", "[ExtractInfo(admin)] jumped to [src].")

mob/Admin1/verb/Admin_Summon_Here()
	set src in oview()
	set name = "Admin: Summon"
	set category = null
	var/mob/Players/admin = usr
	if(!istype(admin)) return
	if(!admin.Admin) return
	var/mob/target = src
	target.PrevX = target.x
	target.PrevY = target.y
	target.PrevZ = target.z
	target.loc = admin.loc
	admin << "Summoned [target] to you."
	Log("Admin", "[ExtractInfo(admin)] summoned [ExtractInfo(target)].")

mob/Admin1/verb/Admin_Send_Back()
	set src in oview()
	set name = "Admin: Send Back"
	set category = null
	var/mob/Players/admin = usr
	if(!istype(admin)) return
	if(!admin.Admin) return
	var/mob/target = src
	if(!target.PrevX)
		admin << "[target] has no previous location stored."
		return
	target.x = target.PrevX
	target.y = target.PrevY
	target.z = target.PrevZ
	target.PrevX = null
	target.PrevY = null
	target.PrevZ = null
	admin << "Sent [target] back to their previous location."
	target << "You have been returned to your previous location."
	Log("Admin", "[ExtractInfo(admin)] sent [ExtractInfo(target)] back.")

mob/Admin1/verb/Admin_Send_To_Spawn()
	set src in oview()
	set name = "Admin: Send to Spawn"
	set category = null
	var/mob/Players/admin = usr
	if(!istype(admin)) return
	if(!admin.Admin) return
	var/mob/target = src
	MoveToSpawn(target)
	admin << "Sent [target] to spawn."
	Log("Admin", "[ExtractInfo(admin)] sent [ExtractInfo(target)] to spawn.")

// Admin teleport category picker — builds a filtered target list
// include_objects: if 1, shows the Objects category option
mob/proc/AdminPickTarget(var/prompt, var/title, var/include_objects = 0)
	var/list/categories = list("Players", "NPCs")
	if(include_objects)
		categories += "Objects"
	categories += "Cancel"
	var/category = input(src, "Category:", title) as null|anything in categories
	if(!category || category == "Cancel") return null
	var/list/targets = list()
	switch(category)
		if("Players")
			for(var/mob/Players/P in world)
				if(P.client)
					targets += P
		if("NPCs")
			for(var/mob/M in world)
				if(!M.client && M.name)
					targets += M
		if("Objects")
			for(var/obj/O in world)
				if(isturf(O.loc) && O.name)
					targets += O
	if(!targets.len)
		src << "No targets found in that category."
		return null
	var/atom/target = input(src, prompt, title) as null|anything in targets
	return target
