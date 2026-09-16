#define PROMPT_CTL "mapwindow.promptoverlay"
#define NP_MAXLEN 4096
#define NP_MSGLEN 32768
#define NP_CHUNK 1000

client
	var/tmp
		np_open = 0
		np_mode = "num"
		np_result
		np_seq = 0
		list/np_answers = list()
		np_fail = ""
		np_shown = 0
		np_made = 0
		np_loaded = 0
		np_ready = 0
		np_restack = 0
		np_assets = 0
		np_title = ""
		np_msg = ""
		np_initial = ""
		np_nullable = 1
		np_default
		list/np_choices
		list/np_labels
		list/np_buttons

#define SHEET_MAX 6
#define SHEET_CHUNK 250
#define SHEET_DOC_CHUNK 8000

/datum/sheetwin
	var/id = 0
	var/ctl = ""
	var/loaded = 0
	var/ready = 0
	var/open = 0
	var/key = ""
	var/seq = 0
	var/shown = 0
	var/stamp = 0
	var/cas = 0
	var/list/pending = null
	var/list/rows = null
	var/html = null

client
	var/tmp
		list/sh_wins = list()
		sh_stamp = 0

client/proc/SheetWin(id)
	for(var/datum/sheetwin/W in sh_wins)
		if(W.id == id)
			return W
	return null

client/proc/SheetNewWin()
	var/datum/sheetwin/W = new
	W.id = sh_wins.len + 1
	W.ctl = "mapwindow.sheetoverlay[W.id]"
	winset(src, "sheetoverlay[W.id]", "parent=mapwindow;type=browser;pos=0,0;size=840x1000;anchor1=-1,-1;anchor2=-1,-1;is-visible=false")
	if(!length(winget(src, W.ctl, "type")))
		return null
	sh_wins += W
	PromptRestackSoon()
	return W

client/proc/SheetSlot(key)
	var/top = 0
	for(var/datum/sheetwin/W in sh_wins)
		if(W.open && W.key == key)
			return W
		if(W.open && W.id > top)
			top = W.id
	var/datum/sheetwin/best = null
	for(var/datum/sheetwin/W in sh_wins)
		if(!W.open && W.id > top && (!best || W.id < best.id))
			best = W
	if(best)
		return best
	if(sh_wins.len < SHEET_MAX)
		best = SheetNewWin()
		if(best)
			return best
	for(var/datum/sheetwin/W in sh_wins)
		if(!W.open && (!best || W.id > best.id))
			best = W
	if(best)
		return best
	for(var/datum/sheetwin/W in sh_wins)
		if(!best || W.stamp < best.stamp)
			best = W
	return best

client/proc/SheetShow(key, tab, title, sub, list/rows, hint = "", list/actions = null)
	PanelShow(key, "rows", tab, title, sub, rows, hint, actions, null)

client/proc/TableShow(key, tab, title, sub, list/cols, list/rows, hint = "", list/actions = null, list/opts = null)
	var/list/x = list("cols" = cols)
	if(islist(opts))
		for(var/o in opts)
			x[o] = opts[o]
	PanelShow(key, "table", tab, title, sub, rows, hint, actions, x)

client/proc/DocShow(key, tab, title, html, style = "theme", sub = "", w = 0, h = 0, list/nav = null, font = "read", hint = "", onclose = "")
	PanelShow(key, "doc", tab, title, sub, null, hint, null, list("html" = "[html]", "style" = "[style]", "w" = w, "h" = h, "nav" = nav, "font" = "[font]", "onclose" = "[onclose]"))

client/proc/PanelClose(key)
	for(var/datum/sheetwin/W in sh_wins)
		if(W.open && W.key == "[key]")
			W.pending = null
			W.rows = null
			W.html = null
			W.open = 0
			src << output("", "[W.ctl]:hideSheet")
			winset(src, W.ctl, "is-visible=false")

client/proc/PanelShow(key, mode, tab, title, sub, list/rows, hint, list/actions, list/extra)
	if(!mob)
		return
	key = "[key]"
	if(!rows)
		rows = list()
	var/datum/sheetwin/W = SheetSlot(key)
	if(!W)
		world.log << "\[sheet] native fallback for [ckey]: the sheet control could not be created"
		SheetNative(key, mode, title, sub, rows, actions, extra)
		return
	if(!(W.open && W.key == key))
		var/list/used = list()
		for(var/datum/sheetwin/O in sh_wins)
			if(O.open && O != W)
				used += O.cas
		var/k = 0
		while(k in used)
			k++
		W.cas = k
	W.key = key
	W.seq++
	sh_stamp++
	W.stamp = sh_stamp
	var/cut = findtext(key, ":")
	var/list/pk = list("seq" = W.seq, "key" = key, "kind" = cut ? copytext(key, 1, cut) : key, "mode" = "[mode]", "tab" = "[tab]", "title" = "[title]", "sub" = "[sub]", "hint" = "[hint]", "actions" = actions ? actions : list(), "cas" = W.cas)
	W.html = null
	if(islist(extra))
		for(var/x in extra)
			if(x == "html")
				W.html = extra[x]
			else
				pk[x] = extra[x]
	W.pending = pk
	W.rows = rows
	var/seq = W.seq
	spawn(100)
		if(src)
			SheetCheckShown(W, seq, key, mode, title, sub, rows, actions, extra)
	if(!W.loaded)
		SheetBoot(W)
		return
	if(W.ready)
		SheetPush(W)

client/proc/SheetBoot(datum/sheetwin/W)
	if(W.loaded)
		return
	PromptPageSendAssets()
	W.loaded = 1
	winset(src, W.ctl, "inner-background-color=transparent")
	src << browse(SheetPageHTML(W.id), "window=[W.ctl]")

client/proc/SheetPush(datum/sheetwin/W)
	if(!W.pending)
		return
	var/list/r = PanelViewRect()
	var/list/pk = W.pending
	var/list/rows = W.rows ? W.rows : list()
	var/html = W.html
	W.pending = null
	W.rows = null
	W.html = null
	var/z = r ? r[5] : (chatpanel_zoom ? chatpanel_zoom : 1)
	pk["z"] = z
	pk["op"] = chatpanel_opacity
	pk["x0"] = r ? r[1] : 0
	pk["y0"] = r ? r[2] : 0
	pk["x1"] = r ? r[3] : 0
	pk["y1"] = r ? r[4] : 0
	pk["px"] = getPref("shPanX")
	pk["py"] = getPref("shPanY")
	pk["sizes"] = getPref("shSizes")
	if(isnum(pk["w"]) && pk["w"] > 0)
		pk["w"] = round(pk["w"] / max(1, z))
	if(isnum(pk["h"]) && pk["h"] > 0)
		pk["h"] = round(pk["h"] / max(1, z))
	if(pk["mode"] == "doc")
		src << output("", "[W.ctl]:docBegin")
		var/t = "[html]"
		var/n = length_char(t)
		var/i = 1
		while(i <= n)
			var/j = min(i + SHEET_DOC_CHUNK, n + 1)
			src << output(list2params(list(url_encode(copytext_char(t, i, j)))), "[W.ctl]:docAdd")
			i = j
	else
		src << output("", "[W.ctl]:rowsBegin")
		var/i = 1
		while(i <= rows.len)
			var/j = min(i + SHEET_CHUNK - 1, rows.len)
			src << output(list2params(list(url_encode(json_encode(rows.Copy(i, j + 1))))), "[W.ctl]:rowsAdd")
			i = j + 1
	src << output(list2params(list(url_encode(json_encode(pk)))), "[W.ctl]:setSheet")
	if(pk["mode"] != "doc")
		winset(src, W.ctl, W.open ? "is-visible=true" : "is-visible=true;focus=true")
	W.open = 1

client/proc/SheetHide(datum/sheetwin/W)
	W.open = 0
	winset(src, W.ctl, "is-visible=false")
	MapFocus()

client/proc/SheetCheckShown(datum/sheetwin/W, seq, key, mode, title, sub, list/rows, list/actions, list/extra)
	if(!W || W.seq != seq || W.shown >= seq)
		return
	var/why = W.ready ? "the sheet did not appear within 10 seconds" : "the sheet page was not ready after 10 seconds"
	world.log << "\[sheet] native fallback for [ckey]: [why]"
	if(mob && (mob.Admin || (glob && glob.TESTER_MODE)))
		src << "<font color=#ff9a8a>Sheet panel fell back to a BYOND window: [why]</font>"
	if(!W.ready)
		W.loaded = 0
	W.open = 0
	W.pending = null
	W.rows = null
	W.html = null
	winset(src, W.ctl, "is-visible=false")
	SheetNative(key, mode, title, sub, rows, actions, extra)

client/proc/SheetNative(key, mode, title, sub, list/rows, list/actions, list/extra)
	var/win = "window=sheet[ckey(key)]"
	if(mode == "doc" && islist(extra))
		var/w = isnum(extra["w"]) && extra["w"] > 0 ? extra["w"] : 600
		var/h = isnum(extra["h"]) && extra["h"] > 0 ? extra["h"] : 600
		src << browse("[extra["html"]]", "[win];size=[w]x[h]")
		return
	var/out = "<html><body bgcolor=#000000 text=#339999 link=#99FFFF>[html_encode("[title]")]<br>[html_encode("[sub]")]<table width=10%>"
	if(mode == "table" && islist(extra) && islist(extra["cols"]))
		out += "<tr>"
		for(var/list/c in extra["cols"])
			out += "<th>[html_encode("[c["l"]]")]</th>"
		out += "</tr>"
	for(var/list/r in rows)
		if(mode == "table")
			if(r["sec"])
				out += "<tr><td><b>[html_encode("[r["sec"]]")]</b></td></tr>"
				continue
			var/t = html_encode("[r["t"]][r["tn"] ? " [r["tn"]]" : ""]")
			if(r["h"])
				t = "<a href='[r["h"]]'>[t]</a>"
			if(r["t2"])
				t += "<br>[html_encode("[r["t2"]]")]"
			out += "<tr><td>[t]</td>"
			var/list/cells = r["c"]
			if(islist(cells))
				for(var/v in cells)
					out += "<td>[html_encode("[v]")]</td>"
			out += "</tr>"
			CHECK_TICK
			continue
		var/n = html_encode("[r["n"]]")
		var/v = html_encode("[r["v"]]")
		if(r["nh"])
			n = "<a href='[r["nh"]]'>[n]</a>"
		if(r["vh"])
			v = "<a href='[r["vh"]]'>[v]</a>"
		var/x = ""
		var/list/xs = r["x"]
		if(islist(xs))
			for(var/list/q in xs)
				x += " <a href='[q[2]]'>[html_encode("[q[1]]")]</a>"
		out += "<tr><td>[n]</td><td>[v]</td><td>[x]</td></tr>"
		CHECK_TICK
	out += "</table>"
	if(islist(actions))
		for(var/list/a in actions)
			out += "<br><a href='[a[2]]'>[html_encode("[a[1]]")]</a>"
	out += "</body></html>"
	src << browse(out, "[win];size=450x600")

client/proc/SheetTopic(list/href_list)
	var/datum/sheetwin/W = SheetWin(text2num(href_list["w"]))
	if(!W)
		return
	switch(href_list["sheetpage"])
		if("ready")
			W.ready = 1
			if(W.pending)
				SheetPush(W)
		if("shown")
			var/s = text2num(href_list["seq"])
			if(!isnull(s) && s > W.shown)
				W.shown = s
		if("close")
			SheetHide(W)
		if("pan")
			var/px = text2num(href_list["x"])
			var/py = text2num(href_list["y"])
			if(!isnull(px) && !isnull(py))
				setPref("shPanX", round(px))
				setPref("shPanY", round(py))
		if("size")
			var/k = "[href_list["k"]]"
			var/sw = text2num(href_list["sw"])
			var/sh = text2num(href_list["sh"])
			if(length(k) && length(k) <= 40 && !isnull(sw) && !isnull(sh))
				var/list/p = params2list("[getPref("shSizes")]")
				if(p.len < 40 || p[k])
					p[k] = "[clamp(round(sw), 360, 1200)]x[clamp(round(sh), 96, 1200)]"
					setPref("shSizes", list2params(p))
		if("link")
			var/u = "[href_list["url"]]"
			if(length(u) <= 2048 && (findtext(u, "http://") == 1 || findtext(u, "https://") == 1))
				src << link(u)

client/proc/PromptRestackSoon()
	if(!np_made)
		return
	if(np_open || (np_loaded && !np_ready))
		np_restack = 1
		return
	PromptRestack()

client/proc/PromptRestack()
	np_restack = 0
	if(!np_made || np_open)
		return
	winset(src, PROMPT_CTL, "parent=none")
	np_made = 0
	np_loaded = 0
	np_ready = 0
	PromptPageBoot()

/proc/SheetVarRows(datum/A, list/names, list/exclude = null, links = 1)
	var/list/rows = list()
	if(!A || !names)
		return rows
	for(var/C in names)
		if(exclude && (C in exclude))
			continue
		var/val = A.vars[C]
		var/list/row = list("n" = "[C]", "v" = "[Value(val)]", "nh" = "byond://?src=\ref[A];action=edit;var=[C]")
		if(links && isdatum(val))
			row["vh"] = "byond://?src=\ref[val];action=edit;var=[C]"
		rows[++rows.len] = row
		CHECK_TICK
	return rows

/proc/SheetTypeRows(list/paths, prefix)
	var/list/rows = list()
	for(var/p in paths)
		var/t = "[p]"
		var/cut = findlasttext(t, "/")
		rows[++rows.len] = list("n" = copytext(t, cut + 1), "v" = copytext(t, 1, cut + 1), "nh" = "[prefix][t]", "g" = 1)
		CHECK_TICK
	return rows

client/proc/MapFocus()
	winset(src, "mapwindow.map", "focus=true")

/proc/Ask(M, message, title = "", default = null, kind = "text", list/choices = null, nullable = 0, b1 = "Ok", b2 = null, b3 = null)
	var/client/C = null
	if(istype(M, /client))
		C = M
	else if(ismob(M))
		var/mob/mm = M
		C = mm.client
	else if(!isnull(M) && ismob(usr))
		var/mob/um = usr
		C = um.client
	var/list/buttons = null
	if(kind == "confirm")
		buttons = list("[b1]")
		if(!isnull(b2) && length("[b2]")) buttons += "[b2]"
		if(!isnull(b3) && length("[b3]")) buttons += "[b3]"
	var/fallback = (kind == "confirm") ? null : (nullable ? null : default)
	if(kind == "pick" && (!choices || !choices.len))
		return fallback
	while(C && C.np_open)
		sleep(1)
	if(!C)
		return fallback
	if(!C.mob)
		return fallback
	if(!C.NumPromptOpen(message, default, kind, title, choices, nullable, buttons))
		C.PromptFallbackNote()
		return AskNative(C, message, title, default, kind, choices, nullable, buttons)
	var/key = "[C.np_seq]"
	var/waited = 0
	while(C && !(key in C.np_answers))
		if("[C.np_seq]" == key && !C.np_open)
			C.PromptFallbackNote()
			return AskNative(C, message, title, default, kind, choices, nullable, buttons)
		if(C.np_open && "[C.np_seq]" == key && C.np_shown != C.np_seq)
			waited++
			if(waited > 100)
				C.np_fail = C.np_ready ? "the panel did not appear within 10 seconds" : "the panel page was not ready after 10 seconds"
				C.NumPromptAbandon()
				C.PromptFallbackNote()
				return AskNative(C, message, title, default, kind, choices, nullable, buttons)
		sleep(1)
	if(!C)
		return fallback
	. = C.np_answers[key]
	C.np_answers -= key

/proc/AskNative(client/C, message, title, default, kind, list/choices, nullable, list/buttons)
	if(!C)
		return null
	switch(kind)
		if("confirm")
			var/n = buttons ? buttons.len : 0
			if(n >= 3)
				return alert(C, message, title, buttons[1], buttons[2], buttons[3])
			if(n == 2)
				return alert(C, message, title, buttons[1], buttons[2])
			return alert(C, message, title, n ? buttons[1] : "Ok")
		if("pick")
			if(nullable)
				return input(C, message, title, default) as null|anything in choices
			return input(C, message, title, default) as anything in choices
		if("num", "uint")
			if(nullable)
				return input(C, message, title, default) as null|num
			return input(C, message, title, default) as num
		if("message")
			if(nullable)
				return input(C, message, title, default) as null|message
			return input(C, message, title, default) as message
		if("password")
			if(nullable)
				return input(C, message, title, default) as null|password
			return input(C, message, title, default) as password
		if("color")
			if(nullable)
				return input(C, message, title, default) as null|color
			return input(C, message, title, default) as color
	if(nullable)
		return input(C, message, title, default) as null|text
	return input(C, message, title, default) as text

/proc/PromptOf(list/L, types)
	var/list/out = list()
	if(isturf(L))
		var/turf/TT = L
		L = TT.contents
	if(!islist(L))
		return out
	var/list/T = splittext("[types]", "|")
	for(var/x in L)
		if(ismob(x))
			if("mob" in T) out += x
		else if(isobj(x))
			if("obj" in T) out += x
		else if(isturf(x))
			if("turf" in T) out += x
		else if(isarea(x))
			if("area" in T) out += x
		else if(istext(x))
			if("text" in T) out += x
		else if(isnum(x))
			if("num" in T) out += x
	return out

/proc/PromptWorld(types)
	var/list/out = list()
	var/list/T = splittext("[types]", "|")
	if("mob" in T)
		for(var/mob/m in world)
			out += m
	if("obj" in T)
		for(var/obj/o in world)
			out += o
	if("turf" in T)
		for(var/turf/t in world)
			out += t
	if("area" in T)
		for(var/area/a in world)
			out += a
	return out

/proc/PromptAtomChoices(mob/M, range = null, types = "obj|turf")
	var/list/out = list()
	if(!M)
		return out
	var/list/T = splittext("[types]", "|")
	var/list/seen = isnull(range) ? view(M) : view(range, M)
	var/list/found = list()
	var/far = 0
	for(var/atom/a in seen)
		if(ismob(a))
			if(!("mob" in T)) continue
		else if(isobj(a))
			if(!("obj" in T)) continue
		else if(isturf(a))
			if(!("turf" in T)) continue
		else if(isarea(a))
			if(!("area" in T)) continue
		else
			continue
		var/d = get_dist(M, a)
		if(d > far) far = d
		found += a
		found[a] = d
	for(var/d = 0 to far)
		for(var/atom/a in found)
			if(found[a] != d)
				continue
			var/base = "[a.name][isturf(a) ? " (tile)" : ""] ([a.x],[a.y])"
			var/label = base
			var/j = 2
			while(out[label])
				label = "[base] #[j]"
				j++
			out[label] = a
	return out

/proc/PromptVerbAtom(mob/M, list/a, title = "", range = null, types = "obj|turf")
	if(islist(a) && a.len && istype(a[1], /atom))
		return a[1]
	var/list/L = PromptAtomChoices(M, range, types)
	if(!L.len)
		if(M) M << "Nothing in view to pick."
		return null
	var/k = Ask(M, "Pick a target in view.", title, null, "pick", L, 1)
	if(isnull(k))
		return null
	return L[k]

/proc/PromptLabelAtoms(list/L, plain = 0)
	var/list/out = list()
	for(var/atom/a in L)
		var/base = "[a.name]"
		if(!plain)
			if(isturf(a))
				base = "[base] (tile) ([a.x],[a.y],[a.z])"
			else if(isturf(a.loc))
				base = "[base] ([a.x],[a.y],[a.z])"
			else if(a.loc)
				var/atom/lc = a.loc
				base = "[base] (in [lc.name])"
		var/label = base
		var/j = 2
		while(out[label])
			label = "[base] #[j]"
			j++
		out[label] = a
	return out

/proc/PromptSpecList(mob/M, spec)
	var/list/p = splittext("[spec]", ":")
	var/head = p.len ? p[1] : ""
	if(head == "players")
		var/list/pl = list()
		for(var/mob/P in players)
			pl += P
		if(M && M.Admin)
			var/list/keyed = list()
			for(var/mob/P2 in pl)
				var/base = P2.key ? "[P2.name] ([P2.key])" : "[P2.name]"
				var/label = base
				var/j = 2
				while(keyed[label])
					label = "[base] #[j]"
					j++
				keyed[label] = P2
			return keyed
		return PromptLabelAtoms(pl, 1)
	if(head == "view")
		var/r = (p.len >= 2 && length(p[2])) ? text2num(p[2]) : null
		return PromptAtomChoices(M, r, (p.len >= 3 && length(p[3])) ? p[3] : "mob|obj")
	if(head == "world")
		var/sel = (p.len >= 2) ? p[2] : "mob|obj"
		if(copytext(sel, 1, 2) == "/")
			var/path = text2path(sel)
			var/list/found = list()
			if(ispath(path, /mob))
				for(var/mob/x in world)
					if(istype(x, path)) found += x
			else if(ispath(path, /obj))
				for(var/obj/y in world)
					if(istype(y, path)) found += y
			else if(ispath(path, /turf))
				for(var/turf/z in world)
					if(istype(z, path)) found += z
			return PromptLabelAtoms(found)
		return PromptLabelAtoms(PromptWorld(sel))
	if(head == "worldview")
		var/list/out = PromptLabelAtoms(PromptWorld((p.len >= 2) ? p[2] : "mob|obj"))
		var/list/near = PromptAtomChoices(M, null, (p.len >= 3) ? p[3] : "turf")
		for(var/k in near)
			if(!out[k]) out[k] = near[k]
		return out
	return list()

/proc/PromptArg(mob/M, list/a, i, title, spec, auto1 = 0)
	if(islist(a) && a.len >= i && !isnull(a[i]))
		return a[i]
	if(!M)
		return null
	var/list/L = PromptSpecList(M, spec)
	if(!L.len)
		M << "Nothing to pick for [title]."
		return null
	if(auto1 && L.len == 1)
		return L[L[1]]
	var/k = Ask(M, "Pick a target.", title, null, "pick", L, 1)
	if(isnull(k))
		return null
	return L[k]

/proc/PromptArgList(mob/M, list/a, i, title, list/L)
	if(islist(a) && a.len >= i && !isnull(a[i]))
		return a[i]
	if(!M)
		return null
	if(!islist(L) || !L.len)
		M << "Nothing to pick for [title]."
		return null
	var/atoms = 1
	for(var/x in L)
		if(!istype(x, /atom))
			atoms = 0
			break
	if(atoms)
		var/list/lab = PromptLabelAtoms(L)
		var/k = Ask(M, "Pick a target.", title, null, "pick", lab, 1)
		return isnull(k) ? null : lab[k]
	return Ask(M, "Pick one.", title, null, "pick", L, 1)

/proc/PromptKnownKey(mob/M, title, use_ckey = 1)
	if(!M)
		return null
	var/list/labels = list()
	var/list/seen = list()
	var/list/names = list()
	var/dbok = use_ckey && LogDbOpen()
	if(dbok)
		var/database/query/q = new
		if(LogDbExec(q, "SELECT ckey, name FROM logins WHERE id IN (SELECT max(id) FROM logins GROUP BY ckey) LIMIT 5000"))
			while(q.NextRow())
				var/list/row = q.GetRowData()
				var/rk = "[row["ckey"]]"
				if(length(rk))
					names[rk] = "[row["name"]]"
	for(var/mob/Players/P in players)
		if(!P.key)
			continue
		var/k = use_ckey ? P.ckey : P.key
		if(seen[k])
			continue
		seen[k] = 1
		labels["[k] - [P.name] (online)"] = k
	if(use_ckey)
		for(var/f in flist("Saves/Players/"))
			var/k2 = "[f]"
			if(copytext(k2, length(k2)) == "/")
				continue
			k2 = ckey(k2)
			if(!length(k2) || seen[k2])
				continue
			seen[k2] = 1
			labels[length(names[k2]) ? "[k2] - [names[k2]] (saved)" : "[k2] (saved)"] = k2
		for(var/k3 in names)
			if(seen[k3])
				continue
			seen[k3] = 1
			labels["[k3] - [names[k3]] (seen in login logs)"] = k3
	var/other = "Type a key that is not listed"
	labels[other] = ""
	var/pick = Ask(M, "Pick a key.", title, null, "pick", labels, 1)
	if(isnull(pick))
		return null
	if(pick == other)
		return Ask(M, "Type the key.", title, null, "text", null, 1)
	return labels[pick]

/proc/PromptLoginValue(mob/M, key, column, title)
	if(!M)
		return null
	var/what = (column == "ip") ? "IP address" : "computer ID"
	var/list/labels = list()
	var/list/have = list()
	var/k = ckey("[key]")
	if(length(k))
		for(var/mob/Players/P in players)
			if(P.ckey != k || !P.client)
				continue
			var/cur = (column == "ip") ? "[P.client.address]" : "[P.client.computer_id]"
			if(length(cur) && !have[cur])
				have[cur] = 1
				labels["[cur] (online now)"] = cur
		if(LogDbOpen())
			var/database/query/q = new
			if(LogDbExec(q, "SELECT [column] AS v, max(t) AS lt FROM logins WHERE ckey=? GROUP BY [column] ORDER BY lt DESC LIMIT 50", k))
				while(q.NextRow())
					var/list/row = q.GetRowData()
					var/v = "[row["v"]]"
					if(!length(v) || have[v])
						continue
					have[v] = 1
					labels["[v] (last seen [row["lt"]])"] = v
	var/none = "None"
	var/other = "Type a value that is not listed"
	labels[none] = ""
	labels[other] = ""
	var/pick = Ask(M, "Pick the [what] to ban.", title, null, "pick", labels, 1)
	if(isnull(pick) || pick == none)
		return null
	if(pick == other)
		return Ask(M, "Type the [what].", title, null, "text", null, 1)
	return labels[pick]

/proc/PromptArgValue(mob/M, list/a, i, title, kind)
	if(islist(a) && a.len >= i && !isnull(a[i]))
		return a[i]
	if(!M)
		return null
	return Ask(M, (kind == "num") ? "Enter a number." : "Enter the text.", title, null, kind, null, 1)

mob/proc/HUDNumPrompt(title, default = "")
	return Ask(src, title, "", default, "uint", null, 1)

mob/proc/HUDTextPrompt(title, default = "")
	return Ask(src, title, "", default, "text", null, 1)

client/proc/PromptPageEnsureControl()
	if(np_made)
		return 1
	winset(src, "promptoverlay", "parent=mapwindow;type=browser;pos=0,0;size=576x400;anchor1=-1,-1;anchor2=-1,-1;is-visible=false")
	if(!length(winget(src, PROMPT_CTL, "type")))
		return 0
	np_made = 1
	return 1

client/proc/PromptPageSendAssets()
	if(np_assets)
		return
	np_assets = 1
	ChatPanelSendAssets()
	src << browse_rsc('HUD/chatpanel/lc_tabw_on.png', "lc_tabw_on.png")
	src << browse_rsc('HUD/chatpanel/lc_band.png', "lc_band.png")
	src << browse_rsc('HUD/chatpanel/lc_btn.png', "lc_btn.png")
	src << browse_rsc('HUD/chatpanel/lc_btn_down.png', "lc_btn_down.png")
	src << browse_rsc('HUD/chatpanel/lc_search.png', "lc_search.png")
	src << browse_rsc('HUD/chatpanel/lc_car_u.png', "lc_car_u.png")
	src << browse_rsc('HUD/chatpanel/lc_car_d.png', "lc_car_d.png")
	src << browse_rsc('HUD/chatpanel/lc_car_r.png', "lc_car_r.png")

client/proc/PromptPageBoot()
	if(np_loaded)
		return
	if(!PromptPageEnsureControl())
		return
	PromptPageSendAssets()
	np_loaded = 1
	winset(src, PROMPT_CTL, "inner-background-color=transparent")
	src << browse(PromptPageHTML(), "window=[PROMPT_CTL]")

client/proc/PromptPageHTML()
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 html,body{margin:0;padding:0;background:transparent;overflow:hidden;width:100%;height:100%}
 body{font:16px/16px 'monogram';color:#eaf5ff;user-select:none;-webkit-user-select:none}
 #shell{position:absolute;left:0;top:0;width:288px;image-rendering:pixelated;outline:0}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #hdr{position:relative;height:44px}
 #tab{position:absolute;top:8px;left:16px;width:84px;height:32px;background:url('lc_tabw_on.png') no-repeat;line-height:32px;text-align:center;color:#06283b}
 #ttl{position:absolute;left:108px;right:56px;top:16px;height:16px;color:#bfe6ff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
 #close{position:absolute;top:8px;right:16px;width:32px;height:32px;background:url('lc_slot.png') no-repeat;cursor:pointer}
 #close img{position:absolute;left:0;top:0;width:32px;height:32px}
 #body{position:relative;margin:0 16px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box;padding:8px}
 #msg{color:#bfe6ff;white-space:pre-wrap;word-wrap:break-word;line-height:16px;margin:0 2px 8px 2px}
 .fld{border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .tin{position:absolute;left:2px;top:-1px;right:0;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 #cw{position:relative;height:30px}
 .m-pick #cw,.m-message #cw,.m-confirm #cw{display:none}
 #fld{position:absolute;left:0;right:0;top:0;height:30px}
 .m-color #fld{right:102px}
 #sw{position:absolute;right:0;top:0;width:96px;height:30px;display:none}
 .m-color #sw{display:block}
 .m-color #cw{margin-top:-30px;margin-left:222px}
 #swc{position:absolute;left:-2px;top:-2px;right:-2px;bottom:-2px}
 #cp{display:none}
 .m-color #cp{display:block}
 .csub{color:#7ec8f0;margin:2px 2px 6px 2px}
 #cgridf{padding:0}
 #cgrid,#crec{display:grid;grid-template-columns:repeat(8,24px);grid-auto-rows:18px;gap:4px;padding:1px 2px}
 .csw{width:24px;height:18px;box-sizing:border-box;border:1px solid #06283b;cursor:pointer}
 .csw.on{box-shadow:0 0 0 2px #7ef2ff}
 #ctop{display:flex;gap:12px}
 #cleft{flex:0 0 240px}
 #cright{flex:1 1 auto;min-width:0}
 #crecw{display:none;margin-top:8px}
 #cspec{position:relative;height:146px}
 #csq{position:absolute;left:0;top:0;right:26px;height:146px;box-sizing:border-box;border:1px solid #06283b;background:linear-gradient(to bottom,rgba(255,255,255,0),#fff),linear-gradient(to right,#f00,#ff0,#0f0,#0ff,#00f,#f0f,#f00)}
 #csqd{position:absolute;left:0;top:0;right:0;bottom:0;background:#000;opacity:0;pointer-events:none}
 #csqm{position:absolute;width:9px;height:9px;margin:-5px 0 0 -5px;box-sizing:border-box;border:1px solid #fff;box-shadow:0 0 0 1px #000;border-radius:50%;pointer-events:none}
 #cbar{position:absolute;right:0;top:0;width:18px;height:146px;box-sizing:border-box;border:1px solid #06283b;background:linear-gradient(to bottom,#fff,#000)}
 #cbarm{position:absolute;left:-4px;right:-4px;height:3px;margin-top:-2px;background:#fff;box-shadow:0 0 0 1px #000;pointer-events:none}
 #crgb{display:flex;gap:6px;margin-top:8px;width:216px}
 #crgb .fld{position:relative;flex:1 1 0;height:30px}
 #crgb .lb{position:absolute;left:2px;top:-1px;color:#7ec8f0}
 #crgb .tin{left:14px}
 #grip{position:absolute;right:5px;bottom:5px;width:12px;height:12px;display:none;background:linear-gradient(135deg,transparent 0,transparent 45%,#7ec8f0 45%,#7ec8f0 52%,transparent 52%,transparent 64%,#7ec8f0 64%,#7ec8f0 71%,transparent 71%,transparent 83%,#7ec8f0 83%,#7ec8f0 90%,transparent 90%)}
 .m-message #grip{display:block}
 #flt{position:relative;height:30px;display:none}
 #flt img{position:absolute;left:2px;top:0;width:16px;height:16px}
 #fin{left:22px}
 #fin::placeholder{color:#6096c8}
 #list{position:relative;height:181px;margin-top:8px;padding-top:1px;overflow-y:scroll;overflow-x:hidden;box-sizing:border-box;outline:0;display:none}
 .m-pick #list{display:block}
 #list.nof{margin-top:0}
 #list::-webkit-scrollbar,#ta::-webkit-scrollbar{width:14px}
 #list::-webkit-scrollbar-track,#ta::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 #ta::-webkit-scrollbar-track{margin:4px 0}
 #list::-webkit-scrollbar-thumb,#ta::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 #lsp{position:relative}
 .it{position:absolute;left:0;right:0;height:18px;line-height:16px;white-space:nowrap;cursor:pointer}
 .it .pl{position:absolute;left:0;top:-1px;right:4px;height:18px;display:none;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;box-sizing:border-box}
 .it:hover .pl{display:block;opacity:0.45}
 .it.sel .pl{display:block;opacity:1}
 .it .nm{position:absolute;left:8px;top:0;right:10px;overflow:hidden;text-overflow:ellipsis}
 #tafld{position:relative;height:258px;display:none}
 .m-message #tafld{display:block}
 #ta{position:absolute;left:2px;top:-1px;right:0;height:242px;margin:0;padding:0 2px 0 0;background:transparent;border:0;outline:0;resize:none;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff;overflow-y:scroll;overflow-x:hidden;white-space:pre-wrap;word-wrap:break-word;box-sizing:border-box}
 #row{display:flex;justify-content:space-between;column-gap:8px;margin:10px 4px 0 4px;min-height:24px}
 .m-confirm #row{margin-top:2px}
 #row.one{justify-content:center}
 #row.stack{flex-direction:column;row-gap:6px}
 .use{position:relative;flex:0 0 auto;min-width:104px;height:24px;line-height:24px;padding:0 8px;text-align:center;cursor:pointer;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;box-sizing:border-box}
 #row.three .use{min-width:60px;flex:1 0 auto}
 #row.stack .use{width:100%}
 .use .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box;pointer-events:none}
 .use span{position:relative;top:0}
 .use:hover .bg{filter:brightness(1.2)}
 .use:active .bg{border-image-source:url('lc_btn_down.png');filter:none}
 .use:active span{top:1px}
 .use.ok{color:#78eb78}
 .use.mid{color:#eaf5ff}
 .use.no{color:#ff6464}
 .use.cur{color:#06283b}
 .use.cur .bg{border-image-source:url('lc_btn_down.png')}
 #foot{position:relative;margin:6px 16px 14px 16px;height:18px;white-space:nowrap;overflow:hidden}
 #foot .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box;pointer-events:none}
 #foot .t{position:absolute;left:8px;right:8px;top:2px;overflow:hidden;white-space:nowrap}
 #foot .k{color:#7ec8f0}
 #foot .dv{display:inline-block;width:1px;height:8px;background:#6096c8;margin:0 9px 0 8px;vertical-align:top;position:relative;top:4px}
 #foot .ci{width:10px;height:10px;vertical-align:top;position:relative;top:3px;image-rendering:pixelated}
 #foot .ci+.ci{margin-left:2px}
 #foot .ci.l{transform:scaleX(-1)}
 :root{--cur:url('lc_cur_neutral.png') 2 0, auto;--cur-text:url('lc_cur_ibeam.png') 2 5, text;--cur-drag:url('lc_cur_drag.png') 4 5, move}
 *{cursor:var(--cur) !important}
 input,textarea{cursor:var(--cur-text) !important}
 #grip{cursor:nwse-resize !important}
 #csq,#cbar{cursor:crosshair !important}
 .csw{cursor:pointer !important}
 #hdr{cursor:var(--cur-drag) !important}
 </style></head><body>
 <div id='shell' tabindex='-1'>
  <div id='frame'></div>
  <div id='hdr'><div id='tab'>PROMPT</div><div id='ttl'></div><div id='close' title='cancel'><img src='lc_cross.png' alt=''></div></div>
  <div id='body'>
   <div id='msg'></div>
   <div id='cp'><div id='ctop'><div id='cleft'><div class='csub'>Presets</div><div id='cgridf' class='fld'><div id='cgrid'></div></div><div id='crecw'><div class='csub'>Recent</div><div class='fld' style='padding:0'><div id='crec'></div></div></div></div><div id='cright'><div class='csub'>Custom</div><div id='cspec'><div id='csq'><div id='csqd'></div><div id='csqm'></div></div><div id='cbar'><div id='cbarm'></div></div></div></div></div><div id='crgb'><div class='fld'><span class='lb'>R</span><input id='cr' class='tin' type='text' autocomplete='off' spellcheck='false' maxlength='3'></div><div class='fld'><span class='lb'>G</span><input id='cg' class='tin' type='text' autocomplete='off' spellcheck='false' maxlength='3'></div><div class='fld'><span class='lb'>B</span><input id='cb' class='tin' type='text' autocomplete='off' spellcheck='false' maxlength='3'></div></div></div>
   <div id='cw'><div id='fld' class='fld'><input id='in' class='tin' type='text' autocomplete='off' spellcheck='false' maxlength='4096'></div><div id='sw' class='fld'><div id='swc'></div></div></div>
   <div id='flt' class='fld'><img src='lc_search.png' alt=''><input id='fin' class='tin' type='text' autocomplete='off' spellcheck='false' placeholder='type to filter'></div>
   <div id='list' tabindex='-1'><div id='lsp'></div></div>
   <div id='tafld' class='fld'><textarea id='ta' spellcheck='false' maxlength='32768'></textarea></div>
   <div id='row'></div>
  </div>
  <div id='foot'><div class='bg'></div><div class='t' id='ft'></div></div>
  <div id='grip'></div>
 </div>
 <script>
 var shell=document.getElementById('shell'), hdr=document.getElementById('hdr'), tab=document.getElementById('tab'), ttl=document.getElementById('ttl'), msg=document.getElementById('msg'), inp=document.getElementById('in'), fin=document.getElementById('fin'), flt=document.getElementById('flt'), list=document.getElementById('list'), ta=document.getElementById('ta'), swc=document.getElementById('swc'), row=document.getElementById('row'), ft=document.getElementById('ft'), frame=document.getElementById('frame');
 var CTL='mapwindow.promptoverlay', Z=2, OP=0.85, B=null, P={x:0,y:0}, C={x:0,y:0}, G={x:0,y:0,w:576,h:400}, SEQ=0, MODE='text', busy=true, showing=false, live=false;
 var cp=document.getElementById('cp'), cgrid=document.getElementById('cgrid'), crec=document.getElementById('crec'), crecw=document.getElementById('crecw'), csq=document.getElementById('csq'), csqd=document.getElementById('csqd'), csqm=document.getElementById('csqm'), cbar=document.getElementById('cbar'), cbarm=document.getElementById('cbarm'), cr=document.getElementById('cr'), cg=document.getElementById('cg'), cb=document.getElementById('cb'), tafld=document.getElementById('tafld'), grip=document.getElementById('grip');
 var PRESETS=\['#ff8080','#ffff80','#80ff80','#00ff80','#80ffff','#0080ff','#ff80c0','#ff80ff','#ff0000','#ffff00','#80ff00','#00ff40','#00ffff','#0080c0','#8080c0','#ff00ff','#804040','#ff8040','#00ff00','#008080','#004080','#8080ff','#800040','#ff0080','#800000','#ff8000','#008000','#008040','#0000ff','#0000a0','#800080','#8000ff','#400000','#804000','#004000','#004040','#000080','#000040','#400040','#400080','#000000','#808000','#808040','#808080','#408080','#c0c0c0','#ffffc0','#ffffff'];
 var HUE=0, SAT=0, VAL=1, MW=520, MH=258, BASEW=288;
 var pend=null, labels=new Array(), lower=new Array(), vis=new Array(), RH=18, rq=false, lsp=document.getElementById('lsp'), sel=0, buttons=new Array(), btns=new Array(), cur=0, stacked=false, NUL=1;
 var TABS={text:'PROMPT',num:'NUMBER',uint:'NUMBER',password:'PASSWORD',message:'MESSAGE',pick:'CHOOSE',confirm:'CONFIRM',color:'COLOR'};
 function ws(p){ if(window.BYOND) BYOND.winset(CTL,p); }
 function topic(p){ p.npage=p.npage||''; if(window.BYOND) BYOND.topic(p); }
 function dec(v){ try{ return decodeURIComponent(String(v).split('+').join(' ')); }catch(e){ return String(v); } }
 function applyCursor(){ var two=(Z>=2); var r=document.documentElement.style; r.setProperty('--cur',two?"url('lc_cur_neutral2.png') 5 1, auto":"url('lc_cur_neutral.png') 2 0, auto"); r.setProperty('--cur-text',two?"url('lc_cur_ibeam2.png') 5 11, text":"url('lc_cur_ibeam.png') 2 5, text"); r.setProperty('--cur-drag',two?"url('lc_cur_drag2.png') 9 11, move":"url('lc_cur_drag.png') 4 5, move"); }
 function clampNum(v,lo,hi){ if(hi<lo) hi=lo; if(v<lo) return lo; if(v>hi) return hi; return v; }
 function size(){ var k=hdr.getBoundingClientRect().height/44; if(!(k>0)) k=1; var r=shell.getBoundingClientRect(); return {w:Math.round(r.width/k*Z), h:Math.round(r.height/k*Z)}; }
 function place(){
  document.body.style.zoom=Z; applyCursor(); frame.style.opacity=OP;
  var s=size();
  if(B){ C.x=B.x0+Math.round(((B.x1-B.x0)-s.w)/2); C.y=B.y0+Math.round(((B.y1-B.y0)-s.h)/2); } else { C.x=0; C.y=0; }
  var x=C.x+Math.round(P.x*Z), y=C.y+Math.round(P.y*Z);
  if(B){ x=clampNum(x,B.x0,B.x1-s.w); y=clampNum(y,B.y0,B.y1-s.h); }
  G={x:x,y:y,w:s.w,h:s.h};
  ws({pos:G.x+','+G.y, size:G.w+'x'+G.h});
 }
 function digits(v){ var o=''; for(var i=0;i<v.length;i++){ var c=v.charCodeAt(i); if(c>=48&&c<=57) o+=v.charAt(i); } return o; }
 function numf(v){ var o='', dot=false; for(var i=0;i<v.length;i++){ var c=v.charCodeAt(i); if(c>=48&&c<=57) o+=v.charAt(i); else if(c===45&&o.length===0) o+='-'; else if(c===46&&!dot){ dot=true; o+='.'; } } return o; }
 function hexf(v){ if(!v.length) return ''; var o=''; v=v.toLowerCase(); for(var i=0;i<v.length&&o.length<6;i++){ var c=v.charCodeAt(i); if((c>=48&&c<=57)||(c>=97&&c<=102)) o+=v.charAt(i); } return '#'+o; }
 function hexfull(h){ var s=(h.charAt(0)==='#')?h.substring(1):h; if(s.length===3) s=s.charAt(0)+s.charAt(0)+s.charAt(1)+s.charAt(1)+s.charAt(2)+s.charAt(2); return (s.length===6)?('#'+s):''; }
 function swatch(){ var f=hexfull(inp.value); swc.style.background=f?f:'transparent'; }
 function hx2(n){ var q=Math.max(0,Math.min(255,Math.round(n))).toString(16); return (q.length<2)?('0'+q):q; }
 function rgbHex(r,g,b){ return '#'+hx2(r)+hx2(g)+hx2(b); }
 function hexRgb(h){ var f=hexfull(h); if(!f) return null; return {r:parseInt(f.substring(1,3),16),g:parseInt(f.substring(3,5),16),b:parseInt(f.substring(5,7),16)}; }
 function hsvRgb(h,s2,v2){ var hh=(h%360)/60, i=Math.floor(hh), f=hh-i, p=v2*(1-s2), q=v2*(1-f*s2), t=v2*(1-(1-f)*s2), r=0, g=0, b=0;
  if(i===0){ r=v2; g=t; b=p; } else if(i===1){ r=q; g=v2; b=p; } else if(i===2){ r=p; g=v2; b=t; } else if(i===3){ r=p; g=q; b=v2; } else if(i===4){ r=t; g=p; b=v2; } else { r=v2; g=p; b=q; }
  return {r:r*255,g:g*255,b:b*255}; }
 function rgbHsv(r,g,b){ r/=255; g/=255; b/=255; var mx=Math.max(r,g,b), mn=Math.min(r,g,b), d=mx-mn, h=HUE;
  if(d>0){ if(mx===r) h=60*(((g-b)/d)%6); else if(mx===g) h=60*((b-r)/d+2); else h=60*((r-g)/d+4); if(h<0) h+=360; }
  return {h:h,s:(mx>0)?(d/mx):0,v:mx}; }
 function setFromHex(h){ var c=hexRgb(h); if(!c) return false; var o=rgbHsv(c.r,c.g,c.b); HUE=o.h; SAT=o.s; VAL=o.v; return true; }
 function markColor(){ csqm.style.left=(HUE/360*100)+'%'; csqm.style.top=((1-SAT)*100)+'%'; csqd.style.opacity=String(1-VAL); var tp=hsvRgb(HUE,SAT,1); cbar.style.background='linear-gradient(to bottom,'+rgbHex(tp.r,tp.g,tp.b)+',#000)'; cbarm.style.top=((1-VAL)*100)+'%'; }
 function ringSwatches(hex){ var l=String(hex).toLowerCase(), k=cp.querySelectorAll('.csw'); for(var i=0;i<k.length;i++){ if(k.item(i).getAttribute('data-c')===l) k.item(i).classList.add('on'); else k.item(i).classList.remove('on'); } }
 function paintColor(skip){ var c=hsvRgb(HUE,SAT,VAL), hex=rgbHex(c.r,c.g,c.b); if(skip!=='hex') inp.value=hex; if(skip!=='rgb'){ cr.value=String(Math.round(c.r)); cg.value=String(Math.round(c.g)); cb.value=String(Math.round(c.b)); } swatch(); markColor(); ringSwatches(skip==='hex'?hexfull(inp.value):hex); }
 function addSwatch(box,hex){ var d=el('div','csw'); d.style.background=hex; d.setAttribute('data-c',String(hex).toLowerCase()); box.appendChild(d); }
 function buildPresets(){ if(cgrid.childNodes.length) return; for(var i=0;i<PRESETS.length;i++) addSwatch(cgrid,PRESETS\[i]); }
 function buildRecent(s2){ clear(crec); var a=String(s2||'').split(','), n=0; for(var i=0;i<a.length&&n<8;i++){ var f=hexfull(a\[i]); if(f){ addSwatch(crec,f); n++; } } crecw.style.display=n?'block':'none'; }
 var LW=0, IW=0, BTW=0, meas=null, MAXW=1200;
 function kz(){ var k=hdr.offsetHeight/44; return (k>0)?k:1; }
 function measure(t){ if(!meas){ meas=el('span'); meas.style.cssText='position:absolute;left:-99999px;top:0;white-space:nowrap;visibility:hidden'; document.body.appendChild(meas); } meas.textContent=t; return meas.offsetWidth/kz(); }
 function clip(t){ t=String(t); return (t.length>400)?t.substring(0,400):t; }
 function widestOf(a){ var n=a.length, L=-1, li=-1, i; for(i=0;i<n;i++){ if(String(a\[i]).length>L){ L=String(a\[i]).length; li=i; } } if(li<0) return 0; var best=measure(clip(a\[li])), cut=Math.floor(L*0.75), c=0; for(i=0;i<n&&c<160;i++){ if(i!==li&&String(a\[i]).length>=cut){ c++; var w=measure(clip(a\[i])); if(w>best) best=w; } } return best; }
 function maxW(){ var m=MAXW; if(B){ var av=Math.floor((B.x1-B.x0)/Z)-16; if(av<m) m=av; } return m; }
 function inputMode(){ return MODE==='text'||MODE==='num'||MODE==='uint'||MODE==='password'; }
 function remeasure(){ LW=(MODE==='pick')?widestOf(labels):0; BTW=(MODE==='confirm')?widestOf(buttons):0; IW=0; if(inputMode()&&inp.value.length){ IW=(MODE==='password')?measure(clip(new Array(inp.value.length+1).join(String.fromCharCode(8226)))):measure(clip(inp.value)); } }
 function deficit(){ var k=kz(), d=0; ttl.style.right='auto'; var tw=ttl.scrollWidth/k; ttl.style.right=''; d=Math.max(d,tw+4-ttl.clientWidth/k); if(MODE==='pick'&&labels.length) d=Math.max(d,LW+20-list.clientWidth/k); if(IW>0) d=Math.max(d,IW+6-inp.clientWidth/k); return d; }
 function fitAll(){
  var bw=(MODE==='message')?MW:BASEW, mx=Math.max(maxW(),bw), w=bw, k=kz();
  shell.style.width=w+'px';
  var d=deficit(); if(d>0){ w=Math.min(mx,Math.ceil(w+d)); shell.style.width=w+'px'; }
  if(MODE==='confirm'){
   var c=cur; buildButtons(); cur=Math.min(c,btns.length-1); paintCur();
   var bd=stacked?(BTW+20-row.clientWidth/k):((row.scrollWidth-row.clientWidth)/k);
   if(bd>0){ w=Math.min(mx,Math.ceil(w+bd+2)); shell.style.width=w+'px'; buildButtons(); cur=Math.min(c,btns.length-1); paintCur(); }
  }
  footer();
  var fd=(ft.scrollWidth-ft.clientWidth)/k; if(fd>0){ w=Math.min(mx,Math.ceil(w+fd+2)); shell.style.width=w+'px'; footer(); }
 }
 function refit(){ if(!showing) return; remeasure(); fitAll(); if(MODE==='pick') renderRows(); place(); }
 function fontsCheck(){ try{ if(document.fonts&&document.fonts.check&&!document.fonts.check("16px 'monogram'")) document.fonts.load("16px 'monogram'").then(refit); }catch(e){} }
 function el(tag,cls){ var d=document.createElement(tag); if(cls) d.className=cls; return d; }
 function clear(n){ while(n.firstChild) n.removeChild(n.firstChild); }
 function txt(s){ return document.createTextNode(s); }
 function key(k){ var s=el('span','k'); s.textContent=k; return s; }
 function dv(){ return el('span','dv'); }
 function caret(n,l){ var i=el('img','ci'+(l?' l':'')); i.src=n; i.alt=''; return i; }
 function over(){ return ft.scrollWidth>ft.clientWidth; }
 function footer(){
  clear(ft);
  if(MODE==='pick'){ ft.appendChild(caret('lc_car_u.png')); ft.appendChild(caret('lc_car_d.png')); ft.appendChild(txt(' move')); ft.appendChild(dv()); ft.appendChild(key('ENTER')); ft.appendChild(txt(' confirm')); if(NUL){ ft.appendChild(dv()); ft.appendChild(key('ESC')); ft.appendChild(txt(' cancel')); } return; }
  if(MODE==='confirm'){
   var n=buttons.length, mv=null;
   if(n>1){ ft.appendChild(caret('lc_car_r.png',true)); ft.appendChild(caret('lc_car_r.png')); mv=txt(' move'); ft.appendChild(mv); ft.appendChild(dv()); }
   ft.appendChild(key('ENTER')); ft.appendChild(txt(' '+buttons\[cur])); var ei=escIdx(); if(ei>=0){ ft.appendChild(dv()); ft.appendChild(key('ESC')); ft.appendChild(txt(' '+buttons\[ei])); }
   if(n>1&&over()){ ft.removeChild(mv); }
   if(n>1&&over()){ ft.removeChild(ft.firstChild); ft.removeChild(ft.firstChild); ft.removeChild(ft.firstChild); }
   if(over()){ clear(ft); ft.appendChild(key('ENTER')); ft.appendChild(txt((n>1)?' choose':' continue')); if(n>1&&ei>=0){ ft.appendChild(dv()); ft.appendChild(key('ESC')); ft.appendChild(txt(' refuse')); } }
   return;
  }
  ft.appendChild(key((MODE==='message')?'CTRL+ENTER':'ENTER')); ft.appendChild(txt(' confirm')); if(NUL){ ft.appendChild(dv()); ft.appendChild(key('ESC')); ft.appendChild(txt(' cancel')); }
 }
 function buildOkNo(){
  clear(row); btns=new Array(); stacked=false; row.className=NUL?'two':'one';
  var a=el('div','use ok'); a.appendChild(el('div','bg')); var s1=el('span'); s1.textContent='CONFIRM'; a.appendChild(s1); a.setAttribute('data-i','ok');
  row.appendChild(a);
  if(!NUL) return;
  var b=el('div','use no'); b.appendChild(el('div','bg')); var s2=el('span'); s2.textContent='CANCEL'; b.appendChild(s2); b.setAttribute('data-i','no');
  row.appendChild(b);
 }
 var NEGW=\['no','cancel','deny','refuse','decline','keep','back','nevermind','never mind','abort','not now','exit','leave','close'];
 function isNeg(t){ var l=String(t).toLowerCase().trim(); if(l==='hell no') return true; for(var i=0;i<NEGW.length;i++){ var w=NEGW\[i]; if(l===w||l.indexOf(w+' ')===0||l.indexOf(w+',')===0||l.indexOf(w+'.')===0||l.indexOf(w+'!')===0) return true; } return false; }
 function escIdx(){ var n=buttons.length; if(n===1) return 0; for(var i=n-1;i>=0;i--){ if(isNeg(buttons\[i])) return i; } return -1; }
 function paintCur(){ var n=btns.length, ei=escIdx(); for(var i=0;i<n;i++){ var c='use'; if(i===cur) c+=' cur'; else if(i===ei&&n>1) c+=' no'; else if(i===0) c+=' ok'; else c+=' mid'; btns\[i].className=c; } }
 function buildButtons(){
  clear(row); btns=new Array(); stacked=false; cur=0;
  var n=buttons.length;
  for(var i=0;i<n;i++){ var b=el('div','use'); b.appendChild(el('div','bg')); var s=el('span'); s.textContent=buttons\[i]; b.appendChild(s); b.setAttribute('data-i',String(i)); row.appendChild(b); btns.push(b); }
  row.className=(n===1)?'one':((n===3)?'three':'two');
  if(n>1&&row.scrollWidth>row.clientWidth+1){ row.className+=' stack'; stacked=true; }
  paintCur();
 }
 function moveCur(d){ if(!btns.length) return; cur=clampNum(cur+d,0,btns.length-1); paintCur(); footer(); }
 function renderRows(){
  var top=list.scrollTop, h=list.clientHeight||180;
  var a=Math.max(0,Math.floor(top/RH)-4), b=Math.min(vis.length,Math.ceil((top+h)/RH)+4);
  clear(lsp); lsp.style.height=(vis.length*RH)+'px';
  for(var p=a;p<b;p++){ var li=vis\[p]; var r=el('div',((li+1)===sel)?'it sel':'it'); r.style.top=(p*RH)+'px'; r.setAttribute('data-i',String(li+1)); r.appendChild(el('div','pl')); var nm=el('div','nm'); nm.textContent=labels\[li]; nm.setAttribute('title',labels\[li]); r.appendChild(nm); lsp.appendChild(r); }
 }
 function paintSel(){ var k=lsp.children; for(var i=0;i<k.length;i++){ if((+k\[i].getAttribute('data-i'))===sel) k\[i].classList.add('sel'); else k\[i].classList.remove('sel'); } }
 function posOf(s){ var li=s-1; for(var p=0;p<vis.length;p++){ if(vis\[p]===li) return p; } return -1; }
 function buildList(){
  var n=labels.length;
  lower=new Array(n); vis=new Array(n);
  for(var i=0;i<n;i++){ lower\[i]=labels\[i].toLowerCase(); vis\[i]=i; }
  if(sel<0||sel>n) sel=0;
  var f=(n>8); flt.style.display=f?'block':'none'; list.className=f?'':'nof'; fin.value='';
  list.style.height=(Math.min(10,n)*RH+1)+'px'; list.style.overflowY=(n>10)?'scroll':'hidden';
  list.scrollTop=0;
  renderRows();
  applySel();
 }
 function applySel(){
  var st=list.scrollTop;
  if(sel){ var p=posOf(sel); if(p>=0){ var t=p*RH, bt=t+RH; if(t<st) list.scrollTop=t; else if(bt>st+(list.clientHeight||180)) list.scrollTop=bt-(list.clientHeight||180); } }
  if(list.scrollTop!==st) renderRows(); else paintSel();
 }
 function applyFilter(){
  var q=fin.value.toLowerCase(); vis=new Array();
  for(var i=0;i<labels.length;i++){ if(q===''||lower\[i].indexOf(q)>=0) vis.push(i); }
  if(sel&&posOf(sel)<0) sel=0;
  if(!sel&&q!==''&&vis.length) sel=vis\[0]+1;
  list.scrollTop=0;
  renderRows();
  applySel();
 }
 function moveSel(d){
  if(!vis.length) return;
  var p=sel?posOf(sel):-1;
  if(p<0){ sel=vis\[(d>0)?0:(vis.length-1)]+1; } else { p=clampNum(p+d,0,vis.length-1); sel=vis\[p]+1; }
  applySel();
 }
 function pickBegin(){ pend=new Array(); }
 function pickAdd(j){ if(!pend) pend=new Array(); var a=null; try{ a=JSON.parse(dec(j)); }catch(e){ a=null; } if(a&&a.length){ for(var i=0;i<a.length;i++) pend.push(String(a\[i])); } }
 function setPrompt(pk){
  var o=null; try{ o=JSON.parse(dec(pk)); }catch(e){ o=null; } if(!o) return;
  SEQ=+o.seq; MODE=String(o.mode); Z=+o.z; OP=+o.op; NUL=(o.nul===undefined||MODE==='confirm')?1:((+o.nul)?1:0);
  document.getElementById('close').style.display=NUL?'':'none';
  B=null; if((+o.x1)>(+o.x0)&&(+o.y1)>(+o.y0)) B={x0:+o.x0,y0:+o.y0,x1:+o.x1,y1:+o.y1};
  P={x:(+o.px)||0,y:(+o.py)||0};
  shell.className='m-'+MODE;
  tab.textContent=TABS\[MODE]||'PROMPT';
  var t=o.title?String(o.title):'', m=o.msg?String(o.msg):'', v=o.init?String(o.init):'';
  ttl.textContent=t; msg.textContent=m; msg.style.display=m.length?'':'none';
  flt.style.display='none';
  BASEW=(MODE==='color')?464:288;
  if(MODE==='message'){ MW=Math.max(360,Math.min(1200,(+o.mw)||520)); MH=Math.max(96,Math.min(900,(+o.mh)||258)); tafld.style.height=MH+'px'; ta.style.height=(MH-16)+'px'; }
  shell.style.width=((MODE==='message')?MW:BASEW)+'px';
  sel=0; labels=pend||new Array(); pend=null; buttons=new Array();
  if(MODE==='pick'){ sel=(+v)||0; buildList(); buildOkNo(); }
  else if(MODE==='confirm'){ var bb=o.btns||new Array(); for(var i=0;i<bb.length;i++) buttons.push(String(bb\[i])); if(!buttons.length) buttons.push('Ok'); buildButtons(); document.getElementById('close').style.display=(escIdx()>=0)?'':'none'; }
  else if(MODE==='message'){ ta.value=v; buildOkNo(); }
  else {
   inp.type=(MODE==='password')?'password':'text'; inp.maxLength=(MODE==='color')?7:4096;
   if(MODE==='num') v=numf(v); else if(MODE==='uint') v=digits(v); else if(MODE==='color') v=hexf(v);
   inp.value=v;
   if(MODE==='color'){ buildPresets(); buildRecent(o.recent); if(v&&setFromHex(v)){ paintColor('hex'); } else { HUE=0; SAT=0; VAL=1; cr.value=''; cg.value=''; cb.value=''; swatch(); markColor(); ringSwatches(''); } }
   buildOkNo();
  }
  remeasure();
  fitAll();
  busy=false; showing=true;
  place();
  fontsCheck();
  focusInput();
  topic({npage:'shown',seq:SEQ});
 }
 function focusInput(){ try{
  if(MODE==='pick'){ if(flt.style.display!=='none') fin.focus(); else list.focus(); }
  else if(MODE==='confirm'){ shell.focus(); }
  else if(MODE==='message'){ ta.focus(); ta.selectionStart=ta.value.length; ta.selectionEnd=ta.value.length; }
  else { inp.focus(); inp.select(); }
 }catch(e){} }
 function submitOk(){
  if(busy||!showing) return;
  var v='';
  if(MODE==='pick'){ if(sel<1) return; v=String(sel); }
  else if(MODE==='confirm'){ v=String(cur+1); }
  else if(MODE==='message'){ v=ta.value; }
  else { v=inp.value; if(MODE==='num') v=numf(v); else if(MODE==='uint') v=digits(v); else if(MODE==='color') v=hexf(v); }
  busy=true; showing=false; topic({npage:'ok',seq:SEQ,v:v});
 }
 function fire(i){ if(busy||!showing) return; if(i<0||i>=btns.length) return; cur=i; busy=true; showing=false; topic({npage:'ok',seq:SEQ,v:String(i+1)}); }
 function submitNo(){ if(MODE==='confirm'){ var ei=escIdx(); if(ei>=0) fire(ei); return; } if(!NUL) return; if(busy||!showing) return; busy=true; showing=false; topic({npage:'no',seq:SEQ}); }
 inp.addEventListener('input',function(){ if(MODE==='num'){ var d=numf(inp.value); if(d!==inp.value) inp.value=d; } else if(MODE==='uint'){ var d2=digits(inp.value); if(d2!==inp.value) inp.value=d2; } else if(MODE==='color'){ var h=hexf(inp.value); if(h!==inp.value) inp.value=h; swatch(); if(setFromHex(inp.value)) paintColor('hex'); } });
 function rgbTyped(){ var r=parseInt(digits(cr.value)||'0',10), g=parseInt(digits(cg.value)||'0',10), b=parseInt(digits(cb.value)||'0',10); if(cr.value!==digits(cr.value)) cr.value=digits(cr.value); if(cg.value!==digits(cg.value)) cg.value=digits(cg.value); if(cb.value!==digits(cb.value)) cb.value=digits(cb.value); if(setFromHex(rgbHex(Math.min(255,r),Math.min(255,g),Math.min(255,b)))) paintColor('rgb'); }
 cr.addEventListener('input',rgbTyped); cg.addEventListener('input',rgbTyped); cb.addEventListener('input',rgbTyped);
 cp.addEventListener('click',function(e){ var d=e.target.closest('.csw'); if(!d) return; if(setFromHex(d.getAttribute('data-c'))) paintColor(''); });
 var pick2=null;
 function pickAt(e){ var r=pick2.el.getBoundingClientRect(); var fx=(r.width>0)?Math.max(0,Math.min(1,(e.clientX-r.left)/r.width)):0, fy=(r.height>0)?Math.max(0,Math.min(1,(e.clientY-r.top)/r.height)):0; if(pick2.el===csq){ HUE=Math.min(359.9,fx*360); SAT=1-fy; } else { VAL=1-fy; } paintColor(''); }
 function pickDown(e){ if(e.button!==0) return; pick2={el:e.currentTarget}; try{ pick2.el.setPointerCapture(e.pointerId); }catch(err){} pickAt(e); e.preventDefault(); }
 function pickMove(e){ if(pick2) pickAt(e); }
 function pickUp(e){ if(pick2){ pickAt(e); pick2=null; } }
 csq.addEventListener('pointerdown',pickDown); csq.addEventListener('pointermove',pickMove); csq.addEventListener('pointerup',pickUp);
 cbar.addEventListener('pointerdown',pickDown); cbar.addEventListener('pointermove',pickMove); cbar.addEventListener('pointerup',pickUp);
 var rsz=null;
 grip.addEventListener('pointerdown',function(e){ if(e.button!==0) return; rsz={sx:e.screenX,sy:e.screenY,w:MW,h:MH}; try{ grip.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 grip.addEventListener('pointermove',function(e){ if(!rsz) return; MW=Math.max(360,Math.min(1200,Math.round(rsz.w+(e.screenX-rsz.sx)/Z))); MH=Math.max(96,Math.min(900,Math.round(rsz.h+(e.screenY-rsz.sy)/Z))); tafld.style.height=MH+'px'; ta.style.height=(MH-16)+'px'; fitAll(); var sz=size(); G.w=sz.w; G.h=sz.h; ws({size:G.w+'x'+G.h}); });
 grip.addEventListener('pointerup',function(e){ if(!rsz) return; rsz=null; var sz=size(); G.w=sz.w; G.h=sz.h; if(B){ C.x=B.x0+Math.round(((B.x1-B.x0)-G.w)/2); C.y=B.y0+Math.round(((B.y1-B.y0)-G.h)/2); } P={x:Math.round((G.x-C.x)/Z),y:Math.round((G.y-C.y)/Z)}; topic({npage:'msgsize',w:MW,h:MH}); topic({npage:'pan',x:P.x,y:P.y}); focusInput(); });
 fin.addEventListener('input',function(){ applyFilter(); });
 list.addEventListener('scroll',function(){ if(rq) return; rq=true; requestAnimationFrame(function(){ rq=false; renderRows(); }); });
 list.addEventListener('click',function(e){ var r=e.target.closest('.it'); if(!r) return; sel=+r.getAttribute('data-i'); applySel(); if(flt.style.display!=='none'){ try{ fin.focus(); }catch(err){} } });
 list.addEventListener('dblclick',function(e){ var r=e.target.closest('.it'); if(!r) return; sel=+r.getAttribute('data-i'); applySel(); submitOk(); });
 row.addEventListener('click',function(e){ var b=e.target.closest('.use'); if(!b) return; var d=b.getAttribute('data-i'); if(d==='ok') submitOk(); else if(d==='no') submitNo(); else fire(+d); });
 document.getElementById('close').addEventListener('click',function(){ submitNo(); });
 document.addEventListener('keydown',function(e){
  var k=e.key;
  if(k==='Escape'){ submitNo(); e.preventDefault(); return; }
  if(MODE==='message'){ if(k==='Enter'&&e.ctrlKey){ submitOk(); e.preventDefault(); } return; }
  if(MODE==='pick'){
   if(k==='ArrowDown'){ moveSel(1); e.preventDefault(); } else if(k==='ArrowUp'){ moveSel(-1); e.preventDefault(); } else if(k==='Enter'){ submitOk(); e.preventDefault(); }
   return;
  }
  if(MODE==='confirm'){
   if(k==='ArrowLeft'||(k==='Tab'&&e.shiftKey)||(stacked&&k==='ArrowUp')){ moveCur(-1); e.preventDefault(); }
   else if(k==='ArrowRight'||k==='Tab'||(stacked&&k==='ArrowDown')){ moveCur(1); e.preventDefault(); }
   else if(k==='Enter'){ fire(cur); e.preventDefault(); }
   else if(k==='1'||k==='2'||k==='3'){ var n=(+k)-1; if(n<btns.length){ fire(n); e.preventDefault(); } }
   return;
  }
  if(k==='Enter'){ submitOk(); e.preventDefault(); }
 });
 document.addEventListener('contextmenu',function(e){ e.preventDefault(); });
 var drag=null, pending=false;
 function flush(){ pending=false; if(B){ G.x=clampNum(G.x,B.x0,B.x1-G.w); G.y=clampNum(G.y,B.y0,B.y1-G.h); } ws({pos:G.x+','+G.y}); }
 function sched(){ if(!pending){ pending=true; requestAnimationFrame(flush); } }
 hdr.addEventListener('pointerdown',function(e){ if(e.button!==0) return; if(e.target.closest('#close')) return; drag={sx:e.screenX,sy:e.screenY,x:G.x,y:G.y}; try{ hdr.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 hdr.addEventListener('pointermove',function(e){ if(!drag) return; G.x=drag.x+(e.screenX-drag.sx); G.y=drag.y+(e.screenY-drag.sy); sched(); });
 hdr.addEventListener('pointerup',function(e){ if(!drag) return; drag=null; flush(); P={x:Math.round((G.x-C.x)/Z),y:Math.round((G.y-C.y)/Z)}; topic({npage:'pan',x:P.x,y:P.y}); focusInput(); });
 if(document.fonts&&document.fonts.ready){ document.fonts.ready.then(refit); }
 function boot(){ live=true; topic({npage:'ready'}); }
 if(window.BYOND){ boot(); } else { window.addEventListener('byond-ready',boot); }
 </script></body></html>
"}

/proc/PromptLabel(x)
	if(isnull(x)) return ""
	if(istext(x)) return x
	if(istype(x, /atom))
		var/atom/a = x
		return "[a.name]"
	return "[x]"

client/proc/NumPromptOpen(message, initial, mode = "num", title = "", list/choices = null, nullable = 1, list/buttons = null)
	if(np_open || !mob) return 0
	if(!PromptPageEnsureControl())
		np_fail = "the panel control could not be created"
		return 0
	np_open = 1
	np_mode = mode
	np_seq++
	np_shown = 0
	np_title = "[title]"
	np_msg = "[message]"
	np_nullable = nullable
	np_default = initial
	np_choices = null
	np_labels = null
	np_buttons = buttons
	np_initial = ""
	switch(mode)
		if("text", "password")
			np_initial = copytext("[initial]", 1, NP_MAXLEN + 1)
		if("message")
			np_initial = copytext("[initial]", 1, NP_MSGLEN + 1)
		if("num")
			var/n = text2num("[initial]")
			np_initial = isnull(n) ? "" : num2text(n, 12)
		if("uint")
			var/n = text2num("[initial]")
			np_initial = (!isnull(n) && n > 0) ? num2text(round(n), 12) : ""
		if("color")
			var/c = PromptCleanColor(initial)
			np_initial = isnull(c) ? "" : c
		if("pick")
			np_choices = choices
			np_labels = list()
			var/i = 0
			var/sel = 0
			for(var/x in choices)
				i++
				np_labels += PromptLabel(x)
				if(!sel && !isnull(initial) && x == initial) sel = i
			np_initial = "[sel]"
	NumPromptMacros()
	if(!np_loaded)
		PromptPageBoot()
		if(!np_loaded)
			np_fail = "the panel page could not load"
			NumPromptAbandon()
			return 0
		return 1
	if(!np_ready)
		return 1
	PromptPagePush()
	return 1

client/proc/PromptRememberColor(hex)
	var/list/cur = splittext("[getPref("npRecentColors")]", ",")
	var/list/out = list("[hex]")
	for(var/c in cur)
		if(length(c) == 7 && c != hex && out.len < 8)
			out += c
	setPref("npRecentColors", jointext(out, ","))

client/proc/PromptFallbackNote()
	var/why = length(np_fail) ? np_fail : "unknown reason"
	world.log << "\[prompt] native fallback for [ckey]: [why]"
	if(mob && (mob.Admin || (glob && glob.TESTER_MODE)))
		src << "<font color=#ff9a8a>Prompt panel fell back to the BYOND dialog: [why]</font>"
	np_fail = ""

client/proc/NumPromptAbandon()
	if(!np_open)
		return
	np_open = 0
	np_choices = null
	np_labels = null
	np_buttons = null
	np_default = null
	winset(src, PROMPT_CTL, "is-visible=false")
	NumPromptUnmacros()
	MapFocus()
	if(np_restack)
		PromptRestack()

client/proc/PromptPagePush()
	var/list/r = PanelViewRect()
	var/x0 = 0
	var/y0 = 0
	var/x1 = 0
	var/y1 = 0
	var/z = chatpanel_zoom ? chatpanel_zoom : 1
	if(r)
		x0 = r[1]
		y0 = r[2]
		x1 = r[3]
		y1 = r[4]
		z = r[5]
	var/px = getPref("npPanX")
	if(isnull(px)) px = 0
	var/py = getPref("npPanY")
	if(isnull(py)) py = 0
	if(np_mode == "pick" && np_labels)
		src << output("", "[PROMPT_CTL]:pickBegin")
		var/i = 1
		while(i <= np_labels.len)
			var/j = min(i + NP_CHUNK - 1, np_labels.len)
			src << output(list2params(list(url_encode(json_encode(np_labels.Copy(i, j + 1))))), "[PROMPT_CTL]:pickAdd")
			i = j + 1
	var/list/pk = list("mw" = getPref("npMsgW"), "mh" = getPref("npMsgH"), "recent" = getPref("npRecentColors"), "seq" = np_seq, "mode" = np_mode, "nul" = ((np_nullable || np_mode == "confirm") ? 1 : 0), "title" = np_title, "msg" = np_msg, "init" = np_initial, "z" = z, "op" = chatpanel_opacity, "x0" = x0, "y0" = y0, "x1" = x1, "y1" = y1, "px" = px, "py" = py)
	if(np_mode == "confirm" && np_buttons)
		pk["btns"] = np_buttons
	src << output(list2params(list(url_encode(json_encode(pk)))), "[PROMPT_CTL]:setPrompt")
	winset(src, PROMPT_CTL, "is-visible=true;focus=true")
	src << output("", "[PROMPT_CTL]:focusInput")

/proc/PromptCleanText(v)
	var/t = "[v]"
	var/out = ""
	for(var/i = 1 to length(t))
		var/ch = copytext(t, i, i + 1)
		if(text2ascii(ch) < 32)
			continue
		out += ch
	return copytext(out, 1, NP_MAXLEN + 1)

/proc/PromptCleanMessage(v)
	var/t = "[v]"
	var/out = ""
	for(var/i = 1 to length(t))
		var/ch = copytext(t, i, i + 1)
		var/a = text2ascii(ch)
		if(a == 13)
			continue
		if(a < 32 && a != 10)
			continue
		out += ch
	return copytext(out, 1, NP_MSGLEN + 1)

/proc/PromptCleanUint(v)
	var/t = "[v]"
	var/out = ""
	for(var/i = 1 to length(t))
		var/ch = copytext(t, i, i + 1)
		if(ch >= "0" && ch <= "9")
			out += ch
	if(!length(out))
		return null
	return text2num(copytext(out, 1, NP_MAXLEN + 1))

/proc/PromptCleanNum(v)
	var/t = "[v]"
	var/out = ""
	var/dot = 0
	for(var/i = 1 to length(t))
		var/ch = copytext(t, i, i + 1)
		if(ch >= "0" && ch <= "9")
			out += ch
		else if(ch == "-" && !length(out))
			out += ch
		else if(ch == "." && !dot)
			dot = 1
			out += ch
	if(!length(out) || out == "-" || out == "." || out == "-.")
		return null
	return text2num(copytext(out, 1, NP_MAXLEN + 1))

/proc/PromptCleanColor(v)
	var/t = lowertext("[v]")
	var/out = ""
	for(var/i = 1 to length(t))
		var/ch = copytext(t, i, i + 1)
		if((ch >= "0" && ch <= "9") || (ch >= "a" && ch <= "f"))
			out += ch
		if(length(out) >= 6)
			break
	if(length(out) == 3)
		out = copytext(out, 1, 2) + copytext(out, 1, 2) + copytext(out, 2, 3) + copytext(out, 2, 3) + copytext(out, 3, 4) + copytext(out, 3, 4)
	if(length(out) != 6)
		return null
	return "#" + out

client/proc/NumPromptClose(confirmed, v)
	if(!np_open) return
	var/res = null
	if(confirmed)
		switch(np_mode)
			if("text", "password")
				res = PromptCleanText(v)
			if("message")
				res = PromptCleanMessage(v)
			if("num")
				res = PromptCleanNum(v)
			if("uint")
				res = PromptCleanUint(v)
			if("color")
				res = PromptCleanColor(v)
				if(res)
					PromptRememberColor(res)
			if("pick")
				var/i = text2num("[v]")
				if(np_choices && !isnull(i) && i == round(i) && i >= 1 && i <= np_choices.len)
					res = np_choices[i]
			if("confirm")
				var/i = text2num("[v]")
				if(np_buttons && np_buttons.len)
					res = (!isnull(i) && i == round(i) && i >= 1 && i <= np_buttons.len) ? np_buttons[i] : np_buttons[1]
		if(isnull(res) && !np_nullable && np_mode != "confirm")
			if(np_mode == "num" || np_mode == "uint")
				var/dn = text2num("[np_default]")
				res = isnull(dn) ? 0 : dn
			else
				res = np_default
	else
		if(np_mode == "confirm")
			res = (np_buttons && np_buttons.len) ? np_buttons[np_buttons.len] : null
		else
			res = np_nullable ? null : np_default
	np_result = res
	np_answers["[np_seq]"] = res
	np_open = 0
	np_choices = null
	np_labels = null
	np_buttons = null
	np_default = null
	winset(src, PROMPT_CTL, "is-visible=false")
	NumPromptUnmacros()
	MapFocus()
	if(np_restack)
		PromptRestack()

client/proc/PromptPageTopic(list/href_list)
	switch(href_list["npage"])
		if("ready")
			np_ready = 1
			if(np_open)
				PromptPagePush()
			else if(np_restack)
				PromptRestack()
		if("shown")
			if(np_open && text2num(href_list["seq"]) == np_seq)
				np_shown = np_seq
		if("ok")
			if(np_open && text2num(href_list["seq"]) == np_seq)
				NumPromptClose(1, href_list["v"])
		if("no")
			if(np_open && text2num(href_list["seq"]) == np_seq && np_nullable && np_mode != "confirm")
				NumPromptClose(0)
		if("msgsize")
			var/mw = text2num(href_list["w"])
			var/mh = text2num(href_list["h"])
			if(!isnull(mw) && !isnull(mh))
				setPref("npMsgW", clamp(round(mw), 360, 1200))
				setPref("npMsgH", clamp(round(mh), 96, 900))
		if("pan")
			var/px = text2num(href_list["x"])
			var/py = text2num(href_list["y"])
			if(!isnull(px) && !isnull(py))
				setPref("npPanX", round(px))
				setPref("npPanY", round(py))

mob/verb/NumPromptOk()
	set hidden = 1
	if(!client || !client.np_open) return
	if(client.np_mode == "message") return
	client << output("", "[PROMPT_CTL]:submitOk")

mob/verb/NumPromptOkCtrl()
	set hidden = 1
	if(!client || !client.np_open) return
	client << output("", "[PROMPT_CTL]:submitOk")

mob/verb/NumPromptNo()
	set hidden = 1
	if(!client || !client.np_open) return
	if(client.np_mode == "confirm")
		client << output("", "[PROMPT_CTL]:submitNo")
		return
	if(!client.np_nullable) return
	client.NumPromptClose(0)

/proc/NpKeys()
	var/list/L = list("RETURN", "ESCAPE", "BACK", "SPACE", "NORTH", "SOUTH", "EAST", "WEST", "DELETE", "CTRL+Z", "CTRL+Y", "CTRL+R", "CTRL+X", "CTRL+C", "CTRL+V", "CTRL+F", "CTRL+B", "CTRL+I")
	for(var/i = 0 to 9)
		L += "[i]"
		L += "NUMPAD[i]"
		L += "SHIFT+[i]"
	for(var/c = 97 to 122)
		L += uppertext(ascii2text(c))
		L += "SHIFT+[uppertext(ascii2text(c))]"
	for(var/k in list("-", "=", ",", ".", "'", ";", "/"))
		L += k
		L += "SHIFT+[k]"
	return L

client/proc/NpMacroSet()
	for(var/k in params2list(winget(src, null, "macro")))
		return k
	return "macro"

client/proc/NumPromptMacros()
	var/set_name = NpMacroSet()
	var/list/npkeys = NpKeys()
	if(mob)
		mob.initShortcuts()
		BuildKeybindRegistry()
		for(var/datum/keyaction/a in keybind_registry)
			for(var/s = 1 to 2)
				var/key = mob.KeybindKey(a.id, s)
				if(key && (uppertext(key) in npkeys))
					KbClearKey(set_name, key)
		if(mob.shortcuts && mob.shortcuts.keybinds)
			for(var/sk in mob.shortcuts.keybinds)
				if(copytext(sk, 1, 6) != "misc:") continue
				var/key = mob.shortcuts.keybinds[sk]
				if(!key || !(uppertext(key) in npkeys)) continue
				KbClearKey(set_name, key)
	ApplyOneBind(set_name, "np_ret", "RETURN", "NumPromptOk", 0, null)
	ApplyOneBind(set_name, "np_cret", "CTRL+RETURN", "NumPromptOkCtrl", 0, null)
	ApplyOneBind(set_name, "np_esc", "ESCAPE", "NumPromptNo", 0, null)

client/proc/NumPromptUnmacros()
	var/set_name = NpMacroSet()
	ApplyOneBind(set_name, "np_ret", "", null, 0, null)
	ApplyOneBind(set_name, "np_cret", "", null, 0, null)
	ApplyOneBind(set_name, "np_esc", "", null, 0, null)
	ApplyKeybinds()

client/proc/SheetPageHTML(id)
	return {"<!DOCTYPE html><html><head><meta charset='utf-8'><style>
 @font-face{font-family:'monogram';src:url('monogram.ttf')}
 html,body{margin:0;padding:0;background:transparent;overflow:hidden;width:100%;height:100%}
 body{font:16px/16px 'monogram';color:#eaf5ff;user-select:none;-webkit-user-select:none}
 a{-webkit-user-drag:none}
 #shell{position:absolute;left:0;top:0;width:420px;image-rendering:pixelated;outline:0}
 #frame{position:absolute;left:0;top:0;right:0;bottom:0;border:16px solid transparent;border-image:url('lc_cover.png') 16 fill stretch;pointer-events:none}
 #hdr{position:relative;height:44px}
 #tab{position:absolute;top:8px;left:16px;width:84px;height:32px;background:url('lc_tabw_on.png') no-repeat;line-height:32px;text-align:center;color:#06283b}
 #ttl{position:absolute;left:108px;right:56px;top:16px;height:16px;color:#bfe6ff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
 #close{position:absolute;top:8px;right:16px;width:32px;height:32px;background:url('lc_slot.png') no-repeat}
 #close img{position:absolute;left:0;top:0;width:32px;height:32px}
 #body{position:relative;margin:0 16px;border:6px solid transparent;border-image:url('lc_forgesub.png') 6 fill stretch;box-sizing:border-box;padding:8px}
 #sub{color:#7ec8f0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin:0 2px 8px 2px}
 .fld{border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 #nav{display:none;flex-wrap:wrap;gap:4px;margin:0 0 8px 0}
 .chip{position:relative;display:block;flex:0 0 auto;height:24px;line-height:24px;padding:0 10px;color:#eaf5ff;text-decoration:none;white-space:nowrap}
 .chip .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box;pointer-events:none}
 .chip span{position:relative}
 .chip:hover .bg{filter:brightness(1.2)}
 .chip.on{color:#06283b}
 .chip.on .bg{border-image-source:url('lc_btn_down.png');filter:none}
 #flt{position:relative;height:30px}
 .nof #flt{display:none}
 #flt img{position:absolute;left:2px;top:0;width:16px;height:16px}
 #fin{position:absolute;left:22px;top:-1px;right:0;height:16px;margin:0;padding:0;background:transparent;border:0;outline:0;font:16px/16px 'monogram';color:#eaf5ff;caret-color:#eaf5ff}
 #fin::placeholder{color:#6096c8}
 #thead{position:relative;height:18px;margin-top:8px;display:none}
 .hh #thead{display:block}
 .nof #thead{margin-top:0}
 .band{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box;pointer-events:none}
 #thead .band{right:14px}
 .hc{position:absolute;top:1px;color:#7ec8f0;white-space:nowrap}
 .hc.on{color:#eaf5ff}
 .hc img{width:10px;height:10px;position:relative;top:3px;image-rendering:pixelated}
 .hc.r img{margin-right:4px}
 .hc.l img{margin-left:4px}
 #list{position:relative;height:397px;margin-top:8px;padding-top:1px;overflow-y:scroll;overflow-x:hidden;box-sizing:border-box;outline:0}
 .hh #list{margin-top:2px}
 .nof #list{margin-top:0}
 .m-doc #flt,.m-doc #thead,.m-doc #list{display:none}
 #list::-webkit-scrollbar{width:14px}
 #list::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:6px 0}
 #list::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}
 #lsp{position:relative}
 #empty{position:absolute;left:8px;top:4px;color:#6096c8;display:none}
 .it{position:absolute;left:0;right:0;height:18px;line-height:16px;white-space:nowrap}
 .it .pl{position:absolute;left:0;top:-1px;right:4px;height:18px;display:none;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;box-sizing:border-box;opacity:0.45;pointer-events:none}
 .it:hover .pl{display:block}
 .nm{position:absolute;left:8px;top:0;width:var(--nw,44%);overflow:hidden;text-overflow:ellipsis;color:#8be9ff;text-decoration:none}
 span.nm{color:#eaf5ff}
 .va{position:absolute;left:var(--vl,48%);right:10px;top:0;overflow:hidden;text-overflow:ellipsis;color:#bfe6ff;text-decoration:none}
 .it.xs .va{right:var(--xr,96px)}
 a.va{color:#8be9ff;text-decoration:underline}
 a.nm:hover,.xl a:hover{text-decoration:underline}
 .it.gv .nm{color:#eaf5ff}
 .it.gv .va{color:#6f93b3;direction:rtl;text-align:left}
 .xl{position:absolute;right:10px;top:0}
 .xl a{color:#7ec8f0;text-decoration:none;margin-left:8px}
 .xl a.del{color:#ff6464}
 .xl a.sub{color:#ff9a8a}
 .tr{position:absolute;left:0;right:0;height:18px;white-space:nowrap}
 .tr.two{height:36px}
 .tr .pl{position:absolute;left:0;top:0;right:4px;bottom:0;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;box-sizing:border-box;opacity:0;pointer-events:none}
 .tr.alt .pl{opacity:0.16}
 .tr.lk:hover .pl{opacity:0.6}
 .tt{position:absolute;left:8px;top:1px;overflow:hidden;text-overflow:ellipsis;color:#eaf5ff}
 .tr.lk .tt{color:#8be9ff}
 .tt .tn{color:#eaf5ff;margin-left:10px}
 .t2{position:absolute;left:8px;top:19px;overflow:hidden;text-overflow:ellipsis;color:#6f93b3}
 .tc{position:absolute;top:1px;text-align:right;overflow:hidden;text-overflow:ellipsis;color:#eaf5ff}
 .tc.l{text-align:left}
 .tc.dim{color:#6f93b3}
 .tr.two .tc{top:10px}
 .kr{position:absolute;left:0;right:0;height:22px;white-space:nowrap}
 .kr .pl{position:absolute;left:0;top:0;right:4px;bottom:0;border:6px solid transparent;border-image:url('lc_rowplate.png') 6 fill stretch;box-sizing:border-box;opacity:0;pointer-events:none}
 .kr:hover .pl{opacity:0.45}
 .kr .tt{top:3px}
 .kb{position:absolute;top:1px;height:20px;border:6px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .kb span{position:absolute;left:-2px;right:-2px;top:-5px;height:16px;line-height:16px;text-align:center;color:#eaf5ff;overflow:hidden;text-overflow:ellipsis}
 .kb.none span{color:#6096c8}
 .kb.cap{border-image-source:url('lc_btn_down.png')}
 .kb.cap span{color:#06283b}
 .kb:hover{filter:brightness(1.2)}
 .ku{position:absolute;top:3px;width:12px;text-align:center;color:#ff6464}
 .ko{position:absolute;top:3px;color:#7ec8f0}
 .ku:hover,.ko:hover{text-decoration:underline}
 .tr.sec .band{top:1px;bottom:1px}
 .tr.sec .hc{top:2px}
 #docf{position:relative;display:none;height:300px;border:8px solid transparent;border-image:url('lc_field.png') 8 fill stretch;box-sizing:border-box}
 .m-doc #docf{display:block}
 #doc{position:absolute;left:0;top:0;width:100%;height:100%;border:0;background:transparent;display:block}
 #doc.paper{background:#ffffff}
 #acts{display:none;gap:8px;margin:10px 4px 0 4px;height:24px}
 .use{position:relative;display:block;flex:0 0 auto;min-width:104px;height:24px;line-height:24px;padding:0 8px;text-align:center;color:#eaf5ff;text-decoration:none;box-sizing:border-box;white-space:nowrap}
 .use .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:8px solid transparent;border-image:url('lc_btn.png') 8 fill stretch;box-sizing:border-box;pointer-events:none}
 .use span{position:relative;top:0}
 .use:hover .bg{filter:brightness(1.2)}
 .use:active .bg{border-image-source:url('lc_btn_down.png');filter:none}
 .use:active span{top:1px}
 #foot{position:relative;margin:6px 16px 14px 16px;height:18px;white-space:nowrap;overflow:hidden}
 #foot .bg{position:absolute;left:0;top:0;right:0;bottom:0;border:6px solid transparent;border-image:url('lc_band.png') 6 fill stretch;box-sizing:border-box;pointer-events:none}
 #foot .t{position:absolute;left:8px;right:8px;top:2px;overflow:hidden;white-space:nowrap}
 #foot .k{color:#7ec8f0}
 #foot .dv{display:inline-block;width:1px;height:8px;background:#6096c8;margin:0 9px 0 8px;vertical-align:top;position:relative;top:4px}
 #grip{position:absolute;right:5px;bottom:5px;width:12px;height:12px;background:linear-gradient(135deg,transparent 0,transparent 45%,#7ec8f0 45%,#7ec8f0 52%,transparent 52%,transparent 64%,#7ec8f0 64%,#7ec8f0 71%,transparent 71%,transparent 83%,#7ec8f0 83%,#7ec8f0 90%,transparent 90%)}
 :root{--cur:url('lc_cur_neutral.png') 2 0, auto;--cur-text:url('lc_cur_ibeam.png') 2 5, text;--cur-drag:url('lc_cur_drag.png') 4 5, move}
 *{cursor:var(--cur) !important}
 input{cursor:var(--cur-text) !important}
 #grip{cursor:nwse-resize !important}
 #hdr{cursor:var(--cur-drag) !important}
 </style></head><body>
 <div id='shell' tabindex='-1'>
  <div id='frame'></div>
  <div id='hdr'><div id='tab'>SHEET</div><div id='ttl'></div><div id='close' title='close'><img src='lc_cross.png' alt=''></div></div>
  <div id='body'>
   <div id='sub'></div>
   <div id='nav'></div>
   <div id='flt' class='fld'><img src='lc_search.png' alt=''><input id='fin' type='text' autocomplete='off' spellcheck='false' placeholder='type to filter'></div>
   <div id='thead'></div>
   <div id='list' tabindex='-1'><div id='lsp'></div><div id='empty'></div></div>
   <div id='docf'><iframe id='doc' sandbox='allow-same-origin'></iframe></div>
   <div id='acts'></div>
  </div>
  <div id='foot'><div class='bg'></div><div class='t' id='ft'></div></div>
  <div id='grip'></div>
 </div>
 <script>
 var shell=document.getElementById('shell'), hdr=document.getElementById('hdr'), tab=document.getElementById('tab'), ttl=document.getElementById('ttl'), sub=document.getElementById('sub'), nav=document.getElementById('nav'), fin=document.getElementById('fin'), thead=document.getElementById('thead'), list=document.getElementById('list'), lsp=document.getElementById('lsp'), empty=document.getElementById('empty'), docf=document.getElementById('docf'), doc=document.getElementById('doc'), acts=document.getElementById('acts'), ft=document.getElementById('ft'), frame=document.getElementById('frame'), grip=document.getElementById('grip');
 var CTL='mapwindow.sheetoverlay[id]', WID=[id], Z=2, OP=0.85, B=null, P={x:0,y:0}, C={x:0,y:0}, G={x:0,y:0,w:840,h:1000}, KEY='', KIND='', SEQ=0, MODE='rows', HINT='', SW=420, LH=397, SIZED=false, RH=18, rq=false, pend=null, rows=new Array(), lower=new Array(), vis=new Array(), showing=false, live=false, LRM=String.fromCharCode(8206);
 var COLS=new Array(), CW=new Array(), CX=new Array(), TWO=false, NOSORT=false, NOFILT=false, SORT={c:-1,d:1}, DSTYLE='theme', DFONT='read', DOCBUF='', DSEQ=0, DOCY=0, SPANW=0, ONCLOSE='';
 var NW=0, VW=0, XW=0, meas=null, MAXW=1200, KREF='', CAP=null, BW=96, RW=40, KX={ro:10,x2:0,b2:0,x1:0,b1:0,c0:40,lw:300};
 var SBCSS="::-webkit-scrollbar{width:14px;height:14px}::-webkit-scrollbar-track{background:url('lc_track.png') no-repeat;background-size:100% 100%;margin:4px 0}::-webkit-scrollbar-thumb{border-left:1px solid transparent;border-right:1px solid transparent;background-clip:padding-box;background-origin:padding-box;background:url('lc_thumb_top.png') left top no-repeat,url('lc_thumb_bot.png') left bottom no-repeat,url('lc_thumb_mid.png') left center no-repeat,url('lc_thumb_col.png') left top repeat-y;background-size:12px 6px,12px 6px,12px 11px,12px 1px;min-height:24px}::-webkit-scrollbar-corner{background:transparent}";
 var THEMECSS="@font-face{font-family:'monogram';src:url('monogram.ttf')}html,body{margin:0;padding:0;background:transparent !important}body{color:#d6ecfa !important;font:15px/19px Calibri,'Segoe UI',Arial,sans-serif;padding:6px 10px 8px 10px;word-wrap:break-word;user-select:text;-webkit-user-select:text}a{color:#8be9ff}a:hover{color:#eaf5ff}h1,h2,h3,h4,h5{font-family:'monogram',monospace;font-weight:normal;font-size:16px;line-height:18px;margin:12px 0 6px 0;color:#7ec8f0}h1{color:#8be9ff;margin-top:4px}hr{border:0;border-top:1px solid #2e6682;margin:8px 0}table{border-collapse:collapse}td,th{padding:2px 6px;vertical-align:top}th{color:#7ec8f0;text-align:left;font-weight:normal}li::marker{color:#7ec8f0}font\[color=black i],font\[color='#000000' i],font\[color='#000' i]{color:#d6ecfa !important}";
 var TEXTCSS=".txt{white-space:pre-wrap;word-wrap:break-word}.f-pixel{font:16px/18px 'monogram',monospace;color:#bfe6ff}.f-mono{font:13px/16px Consolas,'Cascadia Mono',monospace;color:#d6ecfa}.f-read{font:15px/19px Calibri,'Segoe UI',Arial,sans-serif;color:#d6ecfa}";
 var AUTHCSS="body{user-select:text;-webkit-user-select:text}";
 function ws(p){ if(window.BYOND) BYOND.winset(CTL,p); }
 function topic(p){ p.w=WID; if(window.BYOND) BYOND.topic(p); }
 function dec(v){ try{ return decodeURIComponent(String(v).split('+').join(' ')); }catch(e){ return String(v); } }
 function txt(x){ return (x===undefined||x===null)?'':String(x); }
 function esc(t){ return String(t).split('&').join('&amp;').split('<').join('&lt;').split('>').join('&gt;'); }
 function applyCursor(){ var two=(Z>=2); var r=document.documentElement.style; r.setProperty('--cur',two?"url('lc_cur_neutral2.png') 5 1, auto":"url('lc_cur_neutral.png') 2 0, auto"); r.setProperty('--cur-text',two?"url('lc_cur_ibeam2.png') 5 11, text":"url('lc_cur_ibeam.png') 2 5, text"); r.setProperty('--cur-drag',two?"url('lc_cur_drag2.png') 9 11, move":"url('lc_cur_drag.png') 4 5, move"); }
 function clampNum(v,lo,hi){ if(hi<lo) hi=lo; if(v<lo) return lo; if(v>hi) return hi; return v; }
 function size(){ var k=hdr.getBoundingClientRect().height/44; if(!(k>0)) k=1; var r=shell.getBoundingClientRect(); return {w:Math.round(r.width/k*Z), h:Math.round(r.height/k*Z)}; }
 function place(){
  document.body.style.zoom=Z; applyCursor(); frame.style.opacity=OP;
  var s=size();
  if(B){ C.x=B.x0+Math.round(((B.x1-B.x0)-s.w)/2); C.y=B.y0+Math.round(((B.y1-B.y0)-s.h)/2); } else { C.x=0; C.y=0; }
  var x=C.x+Math.round(P.x*Z), y=C.y+Math.round(P.y*Z);
  if(B){ x=clampNum(x,B.x0,B.x1-s.w); y=clampNum(y,B.y0,B.y1-s.h); }
  G={x:x,y:y,w:s.w,h:s.h};
  ws({pos:G.x+','+G.y, size:G.w+'x'+G.h});
 }
 function el(tag,cls){ var d=document.createElement(tag); if(cls) d.className=cls; return d; }
 function clear(n){ while(n.firstChild) n.removeChild(n.firstChild); }
 function key(k){ var s=el('span','k'); s.textContent=k; return s; }
 function dv(){ return el('span','dv'); }
 function kz(){ var k=hdr.offsetHeight/44; return (k>0)?k:1; }
 function measure(t){ if(!meas){ meas=el('span'); meas.style.cssText='position:absolute;left:-99999px;top:0;white-space:nowrap;visibility:hidden'; document.body.appendChild(meas); } meas.textContent=t; return meas.offsetWidth/kz(); }
 function clip(t){ t=String(t); return (t.length>400)?t.substring(0,400):t; }
 function widestOf(get,n){ var L=-1, li=-1, i, t; for(i=0;i<n;i++){ t=get(i); if(t.length>L){ L=t.length; li=i; } } if(li<0||L<=0) return 0; var best=measure(clip(get(li))), cut=Math.floor(L*0.75), c=0; for(i=0;i<n&&c<160;i++){ if(i===li) continue; t=get(i); if(t.length>=cut){ c++; var w=measure(clip(t)); if(w>best) best=w; } } return best; }
 function maxW(){ var m=MAXW; if(B){ var av=Math.floor((B.x1-B.x0)/Z)-16; if(av<m) m=av; } return m; }
 function availH(box){ var m=2000; if(B) m=Math.floor((B.y1-B.y0)/Z)-24; var k=kz(); return m-(shell.offsetHeight/k-box.offsetHeight/k); }
 function capH(box,def){ if(SIZED) return LH; return Math.max(96,Math.min(def,availH(box))); }
 function rowsBegin(){ pend=new Array(); }
 function rowsAdd(j){ if(!pend) pend=new Array(); var a=null; try{ a=JSON.parse(dec(j)); }catch(e){ a=null; } if(a&&a.length){ for(var i=0;i<a.length;i++) pend.push(a\[i]); } }
 function docBegin(){ DOCBUF=''; }
 function docAdd(j){ DOCBUF+=dec(j); }
 function parseSizes(s){ var o={}; var a=String(s||'').split('&'); for(var i=0;i<a.length;i++){ var p=a\[i].split('='); if(p.length===2){ var d=dec(p\[1]).split('x'); if(d.length===2) o\[dec(p\[0])]={w:+d\[0],h:+d\[1]}; } } return o; }
 function footer(){
  var parts=new Array();
  if(HINT) parts.push(\['CLICK',' '+HINT,0]);
  if(MODE==='table'&&!NOSORT) parts.push(\['CLICK',' a heading to sort',1]);
  if(MODE==='doc') parts.push(\['SCROLL',' read',2]);
  parts.push(\['DRAG CORNER',' resize',3]);
  parts.push(\['ESC',' close',-1]);
  var drop=\[3,1,2];
  for(var rd=0;rd<=drop.length;rd++){
   clear(ft); var first=true;
   for(var i=0;i<parts.length;i++){ var p=parts\[i]; if(p\[2]>=0&&drop.slice(0,rd).indexOf(p\[2])>=0) continue; if(!first) ft.appendChild(dv()); first=false; ft.appendChild(key(p\[0])); ft.appendChild(document.createTextNode(p\[1])); }
   if(ft.scrollWidth<=ft.clientWidth+1) return;
  }
 }
 function chromeDeficit(k){ ttl.style.right='auto'; var tw=ttl.scrollWidth/k; ttl.style.right=''; return Math.max(tw+4-ttl.clientWidth/k, (sub.scrollWidth-sub.clientWidth)/k, (ft.scrollWidth-ft.clientWidth)/k, (acts.scrollWidth-acts.clientWidth)/k, 0); }
 function remeasure(){
  var n=rows.length, i, j;
  if(MODE==='rows'){
   NW=widestOf(function(q){ return txt(rows\[q].n); },n);
   VW=widestOf(function(q){ return txt(rows\[q].v); },n);
   var L=-1, li=-1;
   for(i=0;i<n;i++){ var xs=rows\[i].x; if(xs&&xs.length){ var t=0; for(j=0;j<xs.length;j++) t+=txt(xs\[j]\[0]).length+2; if(t>L){ L=t; li=i; } } }
   XW=0; if(li>=0){ var xs2=rows\[li].x; for(j=0;j<xs2.length;j++) XW+=measure(txt(xs2\[j]\[0]))+8; }
   return;
  }
  if(MODE==='keys'){
   CW=new Array(1);
   CW\[0]=Math.max(measure('ACTION'),widestOf(function(q){ var r=rows\[q]; return r.sec?txt(r.sec):txt(r.t); },n));
   var bw=Math.max(measure('press a key'),measure('(unbound)'),measure('SECONDARY'));
   for(i=0;i<n;i++){ var kr=rows\[i]; if(!kr.k) continue; for(j=0;j<2;j++){ var kt=dk(kr.k\[j]); if(kt.length>=11){ var kw=measure(kt); if(kw>bw) bw=kw; } } }
   BW=Math.ceil(bw)+16; RW=Math.ceil(measure('reset'));
   return;
  }
  if(MODE==='table'){
   var nc=COLS.length; CW=new Array(nc);
   for(j=0;j<nc;j++) CW\[j]=measure(txt(COLS\[j].l))+(NOSORT?0:14);
   var w0=widestOf(function(q){ var r=rows\[q]; return r.sec?'':(txt(r.t)+(r.tn?'  '+txt(r.tn):'')); },n);
   var w2=widestOf(function(q){ return rows\[q].sec?'':txt(rows\[q].t2); },n);
   var ws0=widestOf(function(q){ return rows\[q].sec?txt(rows\[q].sec):''; },n);
   if(nc) CW\[0]=Math.max(CW\[0],w0,w2,ws0);
   for(j=1;j<nc;j++){ CW\[j]=Math.max(CW\[j],colWidest(j,n)); }
   SPANW=widestOf(function(q){ var r=rows\[q]; return (r.w&&r.c&&r.c.length)?txt(r.c\[0]):''; },n);
  }
 }
 function colWidest(jj,n){ return widestOf(function(q){ var r=rows\[q]; if(r.sec) return (r.cl&&r.cl\[jj-1]!==undefined)?txt(r.cl\[jj-1]):''; if(r.w) return ''; return (r.c&&r.c\[jj-1]!==undefined)?txt(r.c\[jj-1]):''; },n); }
 function tableNeed(){ var c0=(CW.length?CW\[0]:0), need=8+c0; for(var j=1;j<CW.length;j++) need+=16+CW\[j]; return Math.max(need+10, 8+c0+16+SPANW+10); }
 function dk(k){ if(!k) return '(unbound)'; k=String(k); k=k.replace('North','Arrow Up'); k=k.replace('South','Arrow Down'); k=k.replace('West','Arrow Left'); k=k.replace('East','Arrow Right'); k=k.replace('Subtract','Numpad -'); k=k.replace('Multiply','Numpad *'); k=k.replace('Divide','Numpad /'); k=k.replace('Decimal','Numpad .'); k=k.replace('Add','Numpad +'); k=k.replace('Back','Backspace'); return k; }
 function mk(e){ var c=e.keyCode; if(c===16||c===17||c===18||c===91||c===92||c===93||c===20||c===144) return ''; if(c===27) return 'CANCEL'; var b=''; if(c>=65&&c<=90) b=String.fromCharCode(c); else if(c>=48&&c<=57) b=String.fromCharCode(c); else if(c>=96&&c<=105) b='Numpad'+(c-96); else if(c>=112&&c<=123) b='F'+(c-111); else { var m={32:'Space',9:'Tab',13:'Return',8:'Back',37:'West',38:'North',39:'East',40:'South',45:'Insert',46:'Delete',106:'Multiply',107:'Add',109:'Subtract',111:'Divide',110:'Decimal',186:';',187:'=',188:',',189:'-',190:'.',191:'/',192:'`'}; b=m\[c]||''; } if(b==='') return ''; var p=''; if(e.ctrlKey) p+='CTRL+'; if(e.shiftKey) p+='SHIFT+'; if(e.altKey) p+='ALT+'; return p+b; }
 function keysNeed(){ return 8+(CW.length?CW\[0]:0)+12+BW+14+12+BW+14+12+RW+10; }
 function layoutKeys(k){ var lw=list.clientWidth/k; KX.ro=10; KX.x2=KX.ro+RW+12; KX.b2=KX.x2+14; KX.x1=KX.b2+BW+12; KX.b1=KX.x1+14; KX.c0=Math.max(40,lw-8-(KX.b1+BW)-12); KX.lw=lw; }
 function buildKeysHead(){ clear(thead); thead.appendChild(el('div','band')); var a=el('span','hc l'); a.textContent='ACTION'; a.style.left='8px'; thead.appendChild(a); var labs=\[\['PRIMARY',KX.b1],\['SECONDARY',KX.b2]]; for(var i=0;i<2;i++){ var h=el('span','hc'); h.textContent=labs\[i]\[0]; h.style.left=Math.round(KX.lw-labs\[i]\[1]-BW+(BW-measure(labs\[i]\[0]))/2)+'px'; thead.appendChild(h); } }
 function keyRow(r,p){
  var d;
  if(r.sec){ d=el('div','tr sec'); d.style.top=(p*RH)+'px'; d.style.height=RH+'px'; d.appendChild(el('div','band')); var s0=el('span','hc'); s0.textContent=txt(r.sec); s0.style.left='8px'; s0.style.top='4px'; d.appendChild(s0); return d; }
  d=el('div','kr'); d.style.top=(p*RH)+'px'; d.appendChild(el('div','pl'));
  var tt=el('span','tt'); tt.style.maxWidth=KX.c0+'px'; tt.textContent=txt(r.t); tt.setAttribute('title',txt(r.t)); d.appendChild(tt);
  for(var s=0;s<2;s++){
   var raw=(r.k&&r.k\[s])?String(r.k\[s]):'';
   var capd=!!(CAP&&CAP.r===r&&CAP.slot===s+1);
   var b=el('div','kb'+(capd?' cap':(raw?'':' none'))); b.style.right=(s===0?KX.b1:KX.b2)+'px'; b.style.width=BW+'px'; b.setAttribute('data-s',String(s+1)); b.setAttribute('title',dk(raw));
   var sp=el('span'); sp.textContent=capd?'press a key':dk(raw); b.appendChild(sp); d.appendChild(b);
   var u=el('span','ku'); u.textContent='x'; u.style.right=(s===0?KX.x1:KX.x2)+'px'; u.setAttribute('data-s',String(s+1)); u.setAttribute('title','clear'); d.appendChild(u);
  }
  var ro=el('span','ko'); ro.textContent='reset'; ro.style.right=KX.ro+'px'; d.appendChild(ro);
  d.kbrow=r;
  return d;
 }
 function keyTopic(p){ p.src=KREF; if(window.BYOND) BYOND.topic(p); }
 var TLW=300;
 function layoutTable(k){ var lw=list.clientWidth/k, x=10; TLW=lw; CX=new Array(COLS.length); for(var j=COLS.length-1;j>=1;j--){ CX\[j]=x; x+=CW\[j]+16; } CX\[0]=Math.max(40,lw-8-x+6); }
 function fitAll(){
  var k=kz(), mx=Math.max(maxW(),SW), w=SW;
  shell.style.width=w+'px';
  if(MODE==='doc'){ fitDoc(k,mx); return; }
  var want=Math.max(37,rows.length*RH+1);
  list.style.height=Math.min(want,capH(list,(MODE==='rows')?397:600))+'px';
  footer();
  var d=chromeDeficit(k);
  if(MODE==='rows'){ var xw=(XW>0)?(XW+8):0; d=Math.max(d,(8+NW+16+VW+xw+10)-list.clientWidth/k); }
  else if(MODE==='table'){ d=Math.max(d,tableNeed()-list.clientWidth/k); }
  else if(MODE==='keys'){ d=Math.max(d,keysNeed()-list.clientWidth/k); }
  if(d>0){ w=Math.min(mx,Math.ceil(w+d+1)); shell.style.width=w+'px'; footer(); }
  list.style.height=Math.min(want,capH(list,(MODE==='rows')?397:600))+'px';
  if(MODE==='rows'){
   var xw2=(XW>0)?(XW+8):0, room=list.clientWidth/k-18-xw2, nw=NW;
   if(NW+16+VW>room){ nw=Math.min(NW,Math.max(Math.floor(room*0.6),room-16-VW)); }
   nw=Math.max(0,Math.floor(nw));
   lsp.style.setProperty('--nw',nw+'px'); lsp.style.setProperty('--vl',(8+nw+16)+'px'); lsp.style.setProperty('--xr',(xw2+10)+'px');
  } else if(MODE==='table'){ layoutTable(k); buildHead(); }
  else if(MODE==='keys'){ layoutKeys(k); buildKeysHead(); }
 }
 function fitDoc(k,mx){
  var w=SW;
  footer();
  var d=chromeDeficit(k);
  if(d>0){ w=Math.min(mx,Math.ceil(w+d+1)); shell.style.width=w+'px'; footer(); }
  var dd=null; try{ dd=doc.contentDocument; }catch(e){ dd=null; }
  if(dd&&dd.documentElement){
   var de=dd.documentElement, bd=dd.body;
   docf.style.height=Math.min(LH,capH(docf,640))+'px';
   var over=Math.max(de.scrollWidth,bd?bd.scrollWidth:0)-de.clientWidth;
   if(over>1){ w=Math.min(mx,Math.ceil(w+over+2)); shell.style.width=w+'px'; footer(); }
   docf.style.height='40px';
   var ch=Math.max(de.scrollHeight,bd?bd.scrollHeight:0);
   docf.style.height=Math.max(96,Math.min(ch+18,capH(docf,640)))+'px';
  }
 }
 function renderRows(){
  var top=list.scrollTop, h=list.clientHeight||LH;
  var a=Math.max(0,Math.floor(top/RH)-4), b=Math.min(vis.length,Math.ceil((top+h)/RH)+4);
  clear(lsp); lsp.style.height=(vis.length*RH)+'px'; empty.style.display=vis.length?'none':'block';
  for(var p=a;p<b;p++){
   var r=rows\[vis\[p]];
   if(MODE==='table'){ lsp.appendChild(tableRow(r,p)); continue; }
   if(MODE==='keys'){ lsp.appendChild(keyRow(r,p)); continue; }
   var d=el('div',r.g?'it gv':'it'); d.style.top=(p*RH)+'px'; d.appendChild(el('div','pl'));
   var n=el(r.nh?'a':'span','nm'); n.textContent=txt(r.n); n.setAttribute('title',txt(r.n)); if(r.nh) n.setAttribute('href',txt(r.nh)); d.appendChild(n);
   var vt=txt(r.v), v=el(r.vh?'a':'span','va'); v.textContent=r.g?(LRM+vt+LRM):vt; v.setAttribute('title',vt); if(r.vh) v.setAttribute('href',txt(r.vh)); d.appendChild(v);
   lsp.appendChild(d);
   var xs=r.x; if(xs&&xs.length){ var xl=el('span','xl'); for(var j=0;j<xs.length;j++){ var l=el('a',txt(xs\[j]\[2])); l.textContent=txt(xs\[j]\[0]); l.setAttribute('href',txt(xs\[j]\[1])); xl.appendChild(l); } d.appendChild(xl); d.classList.add('xs'); }
  }
 }
 function tableRow(r,p){
  var d, j;
  if(r.sec){
   d=el('div','tr sec'); d.style.top=(p*RH)+'px'; d.style.height=RH+'px'; d.appendChild(el('div','band'));
   var s0=el('span','hc'); s0.textContent=txt(r.sec); s0.style.left='8px'; d.appendChild(s0);
   if(r.cl){ for(j=1;j<COLS.length;j++){ if(r.cl\[j-1]===undefined) continue; var s1=el('span','hc'); s1.textContent=txt(r.cl\[j-1]); s1.style.right=CX\[j]+'px'; d.appendChild(s1); } }
   return d;
  }
  d=el('div','tr'+(TWO?' two':'')+((p%2)?' alt':'')+(r.h?' lk':'')); d.style.top=(p*RH)+'px'; if(r.h) d.setAttribute('data-h',txt(r.h));
  d.appendChild(el('div','pl'));
  var tt=el('span','tt'); tt.style.maxWidth=CX\[0]+'px'; tt.appendChild(document.createTextNode(txt(r.t))); if(r.tn){ var tn=el('span','tn'); tn.textContent=txt(r.tn); tt.appendChild(tn); } tt.setAttribute('title',txt(r.t)+(r.tn?'  '+txt(r.tn):'')); d.appendChild(tt);
  if(TWO&&r.t2){ var t2=el('span','t2'); t2.style.maxWidth=CX\[0]+'px'; t2.textContent=txt(r.t2); t2.setAttribute('title',txt(r.t2)); d.appendChild(t2); }
  if(r.w&&COLS.length>1){ var sv=(r.c&&r.c.length)?txt(r.c\[0]):''; var sp=el('span','tc'); sp.textContent=sv; sp.style.right=CX\[COLS.length-1]+'px'; sp.style.width=Math.max(0,TLW-8-CW\[0]-16-CX\[COLS.length-1])+'px'; sp.setAttribute('title',sv); d.appendChild(sp); return d; }
  for(j=1;j<COLS.length;j++){ var v=(r.c&&r.c\[j-1]!==undefined)?txt(r.c\[j-1]):''; var tc=el('span','tc'+(COLS\[j].a==='l'?' l':'')+(COLS\[j].d?' dim':'')); tc.textContent=v; tc.style.right=CX\[j]+'px'; tc.style.width=CW\[j]+'px'; tc.setAttribute('title',v); d.appendChild(tc); }
  return d;
 }
 function buildHead(){
  clear(thead); thead.appendChild(el('div','band'));
  for(var j=0;j<COLS.length;j++){
   var h=el('span','hc '+(j===0?'l':'r')+(SORT.c===j?' on':'')); h.setAttribute('data-c',String(j));
   var lab=document.createTextNode(txt(COLS\[j].l));
   var im=null; if(!NOSORT&&SORT.c===j){ im=el('img'); im.src=(SORT.d>0)?'lc_car_d.png':'lc_car_u.png'; im.alt=''; }
   if(j===0){ h.appendChild(lab); if(im) h.appendChild(im); h.style.left='8px'; }
   else { if(im) h.appendChild(im); h.appendChild(lab); h.style.right=(CX\[j]+14)+'px'; }
   thead.appendChild(h);
  }
 }
 function sortKey(r,c){ if(c===0) return (txt(r.t)+' '+txt(r.tn)).toLowerCase(); var s=(r.s&&r.s\[c-1]!==undefined)?r.s\[c-1]:((r.c&&r.c\[c-1]!==undefined)?r.c\[c-1]:''); var n=parseFloat(String(s).split(',').join('')); return isNaN(n)?String(s).toLowerCase():n; }
 function sortVis(){ if(MODE!=='table'||SORT.c<0) return; var c=SORT.c, dir=SORT.d; vis.sort(function(x,y){ var a=sortKey(rows\[x],c), b=sortKey(rows\[y],c); if(typeof a==='number'&&typeof b==='number') return (a-b)*dir; a=String(a); b=String(b); return (a<b?-1:(a>b?1:0))*dir; }); }
 function applyFilter(st){ var q=fin.value.toLowerCase(); vis=new Array(); for(var i=0;i<rows.length;i++){ if(q===''||(!rows\[i].sec&&lower\[i].indexOf(q)>=0)) vis.push(i); } sortVis(); empty.textContent=rows.length?'no matches':'empty'; lsp.style.height=(vis.length*RH)+'px'; list.scrollTop=st||0; renderRows(); }
 function buildActs(ax){ clear(acts); if(!ax||!ax.length){ acts.style.display='none'; return; } acts.style.display='flex'; for(var i=0;i<ax.length;i++){ var b=el('a','use'); b.setAttribute('href',txt(ax\[i]\[1])); b.appendChild(el('div','bg')); var s=el('span'); s.textContent=txt(ax\[i]\[0]); b.appendChild(s); acts.appendChild(b); } }
 function buildNav(nv){ clear(nav); if(!nv||!nv.length){ nav.style.display='none'; return; } nav.style.display='flex'; for(var i=0;i<nv.length;i++){ var c=el('a','chip'+(nv\[i]\[2]?' on':'')); c.setAttribute('href',txt(nv\[i]\[1])); c.appendChild(el('div','bg')); var s=el('span'); s.textContent=txt(nv\[i]\[0]); c.appendChild(s); nav.appendChild(c); } }
 function setSheet(pk){
  var o=null; try{ o=JSON.parse(dec(pk)); }catch(e){ o=null; } if(!o) return;
  var same=showing&&(txt(o.key)===KEY);
  KEY=txt(o.key); KIND=txt(o.kind)||'sheet'; SEQ=(+o.seq)||0; Z=(+o.z)||1; OP=+o.op; MODE=txt(o.mode)||'rows'; HINT=txt(o.hint);
  B=null; if((+o.x1)>(+o.x0)&&(+o.y1)>(+o.y0)) B={x0:+o.x0,y0:+o.y0,x1:+o.x1,y1:+o.y1};
  if(!same){ var cs=((+o.cas)||0)*24; P={x:((+o.px)||0)+cs,y:((+o.py)||0)+cs}; var szs=parseSizes(o.sizes), sz=szs\[KIND]; SIZED=!!sz; SW=clampNum(sz?sz.w:((+o.w)||420),360,1200); LH=clampNum(sz?sz.h:((+o.h)||((MODE==='doc')?640:(MODE==='rows'?397:600))),96,1200); SORT={c:-1,d:1}; }
  NOFILT=!!o.nofilter||MODE==='doc'; NOSORT=!!o.nosort||MODE==='keys'; COLS=o.cols||new Array(); TWO=!!o.two; RH=(MODE==='table'&&TWO)?36:((MODE==='keys')?22:18); ONCLOSE=txt(o.onclose); KREF=txt(o.kref); if(!same) CAP=null;
  shell.className='m-'+MODE+(NOFILT?' nof':'')+(((MODE==='table'&&!o.nohead)||MODE==='keys')?' hh':'');
  tab.textContent=txt(o.tab)||'SHEET'; ttl.textContent=txt(o.title);
  sub.textContent=txt(o.sub); sub.style.display=txt(o.sub).length?'':'none';
  buildNav(o.nav);
  buildActs(o.actions);
  if(MODE==='doc'){ setDoc(o,same); return; }
  rows=pend||new Array(); pend=null;
  lower=new Array(rows.length);
  for(var i=0;i<rows.length;i++){ var r=rows\[i]; if(MODE==='table') lower\[i]=(txt(r.t)+' '+txt(r.tn)+' '+txt(r.t2)+' '+(r.c?r.c.join(' '):'')).toLowerCase(); else if(MODE==='keys') lower\[i]=(txt(r.t)+' '+(r.k?dk(r.k\[0])+' '+dk(r.k\[1]):'')).toLowerCase(); else lower\[i]=(r.g?(txt(r.v)+txt(r.n)+' '+txt(r.n)):(txt(r.n)+' '+txt(r.v))).toLowerCase(); }
  remeasure(); fitAll();
  var st=same?list.scrollTop:0;
  if(!same) fin.value='';
  applyFilter(st);
  showing=true;
  place();
  fontsCheck();
  topic({sheetpage:'shown',seq:SEQ});
  if(!same&&!NOFILT){ try{ fin.focus(); }catch(e){} }
 }
 function setDoc(o,same){
  DSTYLE=txt(o.style)||'theme'; DFONT=txt(o.font)||'read';
  var html=DOCBUF; DOCBUF='';
  var css=SBCSS+((DSTYLE==='author')?AUTHCSS:((DSTYLE==='game')?'':THEMECSS));
  if(DSTYLE==='text'){ css+=TEXTCSS; html="<div class='txt f-"+DFONT+"'>"+esc(html)+"</div>"; }
  doc.className=(DSTYLE==='author')?'paper':'';
  DOCY=0; try{ if(same&&doc.contentWindow) DOCY=doc.contentWindow.scrollY||0; }catch(e){ DOCY=0; }
  DSEQ++; var mine=DSEQ;
  doc.onload=function(){ if(mine===DSEQ) docLoaded(same); };
  doc.srcdoc="<!DOCTYPE html><html><head><meta charset='utf-8'><style>"+css+"</style></head><body>"+html+"</body></html>";
 }
 function docLoaded(same){
  var d=null; try{ d=doc.contentDocument; }catch(e){ d=null; }
  if(d){
   d.addEventListener('click',docClick,true);
   d.addEventListener('auxclick',function(e){ e.preventDefault(); },true);
   d.addEventListener('keydown',function(e){ if(e.key==='Escape'){ closeSheet(); e.preventDefault(); } },true);
   d.addEventListener('contextmenu',function(e){ e.preventDefault(); },true);
   d.addEventListener('dragstart',function(e){ e.preventDefault(); },true);
   d.addEventListener('submit',function(e){ e.preventDefault(); },true);
  }
  fitAll();
  showing=true;
  place();
  if(DOCY){ try{ doc.contentWindow.scrollTo(0,DOCY); }catch(e){} }
  ws(same?{'is-visible':'true'}:{'is-visible':'true','focus':'true'});
  fontsCheck();
  topic({sheetpage:'shown',seq:SEQ});
 }
 function docClick(e){
  var a=(e.target&&e.target.closest)?e.target.closest('a'):null; if(!a) return;
  var h=a.getAttribute('href')||''; e.preventDefault();
  if(h.charAt(0)==='#'){ var dd=a.ownerDocument, id=h.substring(1), t=dd.getElementById(id)||dd.getElementsByName(id).item(0); if(t&&t.scrollIntoView) t.scrollIntoView(); return; }
  var hl=h.toLowerCase();
  if(hl.indexOf('http://')===0||hl.indexOf('https://')===0){ topic({sheetpage:'link',url:h}); return; }
  if(DSTYLE==='author'||DSTYLE==='safe') return;
  if(hl.indexOf('byond://')===0||h.charAt(0)==='?'){ var p=hrefParams(h); if(p&&window.BYOND) BYOND.topic(p); }
 }
 function closeSheet(){ if(!showing) return; showing=false; if(ONCLOSE){ var oc=hrefParams(ONCLOSE); if(oc&&window.BYOND) BYOND.topic(oc); } topic({sheetpage:'close'}); }
 function hideSheet(){ showing=false; }
 function hrefParams(h){ var q=h.indexOf('?'); if(q<0) return null; var o={}, s=h.substring(q+1).split('&').join(';').split(';'); for(var i=0;i<s.length;i++){ if(!s\[i]) continue; var k=s\[i].indexOf('='); if(k<0) o\[dec(s\[i])]=''; else o\[dec(s\[i].substring(0,k))]=dec(s\[i].substring(k+1)); } return o; }
 document.addEventListener('click',function(e){ var a=e.target.closest('a'); if(a){ e.preventDefault(); var p=hrefParams(a.getAttribute('href')||''); if(p&&window.BYOND) BYOND.topic(p); return; } var tr=e.target.closest('.tr.lk'); if(tr){ var p2=hrefParams(tr.getAttribute('data-h')||''); if(p2&&window.BYOND) BYOND.topic(p2); } });
 document.addEventListener('auxclick',function(e){ if(e.target.closest('a')) e.preventDefault(); });
 thead.addEventListener('click',function(e){ var h=e.target.closest('.hc'); if(!h||NOSORT) return; var c=+h.getAttribute('data-c'); if(SORT.c===c) SORT.d=-SORT.d; else { SORT.c=c; SORT.d=(c===0)?1:-1; } buildHead(); applyFilter(0); });
 fin.addEventListener('input',function(){ applyFilter(0); });
 list.addEventListener('scroll',function(){ if(rq) return; rq=true; requestAnimationFrame(function(){ rq=false; renderRows(); }); });
 document.getElementById('close').addEventListener('click',function(){ closeSheet(); });
 document.addEventListener('keydown',function(e){
  if(MODE==='keys'&&CAP){ e.preventDefault(); e.stopPropagation(); var k=mk(e); if(k==='') return; var c=CAP; CAP=null; if(k==='CANCEL'){ renderRows(); return; } for(var i=0;i<rows.length;i++){ var r=rows\[i]; if(!r.k) continue; for(var s=0;s<2;s++){ if(r.k\[s]===k&&!(r===c.r&&s===c.slot-1)) r.k\[s]=''; } } c.r.k\[c.slot-1]=k; renderRows(); keyTopic({action:'rebind',id:txt(c.r.id),slot:String(c.slot),key:k}); return; }
  if(e.key==='Escape'){ closeSheet(); e.preventDefault(); }
 });
 lsp.addEventListener('click',function(e){
  if(MODE!=='keys') return; var kr=e.target.closest('.kr'); if(!kr||!kr.kbrow) return; var r=kr.kbrow;
  var kb=e.target.closest('.kb'); if(kb){ var s=+kb.getAttribute('data-s'); CAP=(CAP&&CAP.r===r&&CAP.slot===s)?null:{r:r,slot:s}; renderRows(); return; }
  var ku=e.target.closest('.ku'); if(ku){ var s2=+ku.getAttribute('data-s'); if(r.k) r.k\[s2-1]=''; CAP=null; renderRows(); keyTopic({action:'unbind',id:txt(r.id),slot:String(s2)}); return; }
  if(e.target.closest('.ko')){ CAP=null; keyTopic({action:'resetone',id:txt(r.id)}); }
 });
 document.addEventListener('contextmenu',function(e){ e.preventDefault(); });
 var drag=null, pending=false, rsz=null;
 function flush(){ pending=false; if(B){ G.x=clampNum(G.x,B.x0,B.x1-G.w); G.y=clampNum(G.y,B.y0,B.y1-G.h); } ws({pos:G.x+','+G.y}); }
 function sched(){ if(!pending){ pending=true; requestAnimationFrame(flush); } }
 hdr.addEventListener('pointerdown',function(e){ if(e.button!==0) return; if(e.target.closest('#close')) return; drag={sx:e.screenX,sy:e.screenY,x:G.x,y:G.y}; try{ hdr.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 hdr.addEventListener('pointermove',function(e){ if(!drag) return; G.x=drag.x+(e.screenX-drag.sx); G.y=drag.y+(e.screenY-drag.sy); sched(); });
 hdr.addEventListener('pointerup',function(e){ if(!drag) return; drag=null; flush(); P={x:Math.round((G.x-C.x)/Z),y:Math.round((G.y-C.y)/Z)}; topic({sheetpage:'pan',x:P.x,y:P.y}); });
 grip.addEventListener('pointerdown',function(e){ if(e.button!==0) return; var box=(MODE==='doc')?docf:list; rsz={sx:e.screenX,sy:e.screenY,w:shell.offsetWidth/kz(),h:box.offsetHeight/kz()}; SIZED=true; try{ grip.setPointerCapture(e.pointerId); }catch(err){} e.preventDefault(); });
 grip.addEventListener('pointermove',function(e){ if(!rsz) return; SW=clampNum(Math.round(rsz.w+(e.screenX-rsz.sx)/Z),360,1200); LH=clampNum(Math.round(rsz.h+(e.screenY-rsz.sy)/Z),96,1200); fitAll(); if(MODE!=='doc') renderRows(); var sz=size(); G.w=sz.w; G.h=sz.h; ws({size:G.w+'x'+G.h}); });
 grip.addEventListener('pointerup',function(e){ if(!rsz) return; rsz=null; var sz=size(); G.w=sz.w; G.h=sz.h; if(B){ C.x=B.x0+Math.round(((B.x1-B.x0)-G.w)/2); C.y=B.y0+Math.round(((B.y1-B.y0)-G.h)/2); } P={x:Math.round((G.x-C.x)/Z),y:Math.round((G.y-C.y)/Z)}; topic({sheetpage:'size',k:KIND,sw:SW,sh:LH}); topic({sheetpage:'pan',x:P.x,y:P.y}); });
 function refit(){ if(!showing) return; remeasure(); fitAll(); if(MODE!=='doc') renderRows(); place(); }
 function fontsCheck(){ try{ if(document.fonts&&document.fonts.check&&!document.fonts.check("16px 'monogram'")) document.fonts.load("16px 'monogram'").then(refit); }catch(e){} }
 if(document.fonts&&document.fonts.ready){ document.fonts.ready.then(refit); }
 function boot(){ live=true; topic({sheetpage:'ready'}); }
 if(window.BYOND){ boot(); } else { window.addEventListener('byond-ready',boot); }
 </script></body></html>
"}
