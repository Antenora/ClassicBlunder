// Collection Log menu, the home for materials (they live in the log, not the inventory).
// grid of quality-bordered slots per category + a detail panel with per-quality withdraw-to-trade.

#define LOG_LAYER (FLY_LAYER + 3.87)
#define LOG_W 624
#define LOG_H 376
#define LOG_COLS 4
#define LOG_ROWS 4
#define LOG_CELL 60
#define LOG_PITCH_X 70
#define LOG_PITCH_Y 74
#define LOG_GX 16
#define LOG_GY 76

/atom/movable/shud/logbg
	layer = LOG_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.LogPanelStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.LogPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.LogPanelEnd()

/atom/movable/shud/logpic
	layer = LOG_LAYER + 0.3
	mouse_opacity = 0

/atom/movable/shud/logtext
	layer = LOG_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/logbtn
	layer = LOG_LAYER + 0.6
	mouse_opacity = 2
	var/action
	var/arg
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr) usr.client.LogButton(action, arg)

/atom/movable/shud/logslot
	layer = LOG_LAYER + 0.35
	mouse_opacity = 2
	var/matclass
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && matclass) usr.client.LogSlotClick(matclass)

/atom/movable/shud/logwidget          // pressable close X (presses, not just glows)
	parent_type = /atom/movable/shud/pressbtn
	layer = LOG_LAYER + 0.65
	mouse_opacity = 2
	DoAction()
		if(usr && usr.client) usr.client.LogButton(action, null)

client
	var/tmp
		logmenu_open = 0
		log_cat = "Ores"
		log_sel = ""
		log_wd_class = ""
		log_wd_quality = 0
		log_wd_amount = 1
		log_atx = 1
		log_aty = 1
		log_pan_x = 0
		log_pan_y = 0
		log_pan_mx = 0
		log_pan_my = 0
		log_pan_ox = 0
		log_pan_oy = 0
		log_pan_dragged = 0
		list/log_chrome
		list/log_page
		list/log_tabbtns

client/proc/LOGloc(dx, dyTop, h = 0)
	var/py = LOG_H - dyTop - h
	var/ax = dx + log_pan_x
	var/ay = py + log_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[log_atx + (ax - axp) / 32]:[axp],[log_aty + (ay - ayp) / 32]:[ayp]"

client/proc/LogAdd(atom/movable/o, chrome = 0)
	if(chrome)
		if(!log_chrome) log_chrome = list()
		log_chrome += o
	else
		if(!log_page) log_page = list()
		log_page += o
	screen += o

client/proc/LogText(dx, dyTop, w, h, txt, chrome = 0, lay = 0.6)
	var/atom/movable/shud/logtext/T = new
	T.layer = LOG_LAYER + lay
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = LOGloc(dx, dyTop, h)
	T.maptext = txt
	LogAdd(T, chrome)
	return T

client/proc/LogBG(icon_file, dx, dyTop, h, lay = 0.15, chrome = 0)
	var/atom/movable/shud/logbg/o = new
	o.icon = icon_file
	o.layer = LOG_LAYER + lay
	o.screen_loc = LOGloc(dx, dyTop, h)
	LogAdd(o, chrome)
	return o

/proc/LogColorBox(w, h, col)
	var/icon/I = icon('BLANK.dmi')
	I.Scale(w, h)
	I.DrawBox(col, 1, 1, w, h)
	return I

client/proc/LogBtn(label, action, arg, dx, dyTop, w, h = 18, fill = null, tcol = "#8be9ff")
	var/atom/movable/shud/logbtn/b = new
	b.icon = fill ? LogColorBox(w, h, fill) : AqCoverIcon(w, h)
	b.action = action
	b.arg = arg
	b.screen_loc = LOGloc(dx, dyTop, h)
	LogAdd(b, 0)
	LogText(dx, dyTop + round((h - 12) / 2), w, 14, "<center><span style=\"[LS_FONT_BODY]; color:[tcol]\">[label]</span></center>", 0, 0.62)
	return b

client/proc/ToggleLogMenu()
	if(logmenu_open) CloseLogMenu()
	else OpenLogMenu()

client/proc/OpenLogMenu()
	if(logmenu_open || !mob) return
	CloseMenu()
	CloseInventory()
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	CloseStationMenu()
	CloseLifeSkillsMenu()
	logmenu_open = 1
	log_cat = "Ores"
	log_sel = ""

	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(LOG_W / 32); if(mtw * 32 < LOG_W) mtw++
	var/mth = round(LOG_H / 32); if(mth * 32 < LOG_H) mth++
	log_atx = max(1, round((vw - mtw) / 2) + 1)
	log_aty = max(1, round((vh - mth) / 2) + 1)
	log_pan_x = getPref("logPanX"); if(isnull(log_pan_x)) log_pan_x = 0
	log_pan_y = getPref("logPanY"); if(isnull(log_pan_y)) log_pan_y = 0
	var/list/b = LOGPanBounds()
	log_pan_x = clamp(log_pan_x, b[1], b[2])
	log_pan_y = clamp(log_pan_y, b[3], b[4])

	BuildLogChrome()
	RefreshLogPage()
	var/list/all = log_chrome.Copy()
	if(log_page) all += log_page
	KineticEntrance(all)

client/proc/CloseLogMenu()
	if(!logmenu_open && !log_chrome) return
	logmenu_open = 0
	ClearList(log_page); log_page = null
	ClearList(log_chrome); log_chrome = null
	log_tabbtns = null

client/proc/ResetLogHUD()
	CloseLogMenu()

client/proc/BuildLogChrome()
	log_chrome = list()
	log_tabbtns = list()
	LogBG('HUD/log_bg.png', 0, 0, LOG_H, 0, 1)
	LogText(16, 8, 280, 18, "<span style=\"[LS_FONT]; color:#8be9ff\">COLLECTION LOG</span>", 1)
	var/atom/movable/shud/logwidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.action = "close"
	X.screen_loc = LOGloc(590, 12, 24)
	LogAdd(X, 1)
	// category tabs
	var/tx = 16
	for(var/cat in LifeMatCategories)
		var/atom/movable/shud/logbtn/b = new
		b.icon = AqCoverIcon(116, 24)
		b.action = "cat"
		b.arg = cat
		b.screen_loc = LOGloc(tx, 40, 24)
		LogAdd(b, 1)
		log_tabbtns[cat] = b
		var/atom/movable/shud/logtext/L = new
		L.layer = LOG_LAYER + 0.62
		L.maptext_width = 116
		L.maptext_height = 16
		L.screen_loc = LOGloc(tx, 46, 16)
		LogAdd(L, 1)
		b.vars["lbl"] = L
		tx += 120
	RefreshLogTabs()

client/proc/RefreshLogTabs()
	if(!log_tabbtns) return
	for(var/cat in log_tabbtns)
		var/atom/movable/shud/logbtn/b = log_tabbtns[cat]
		if(!b) continue
		var/sel = (cat == log_cat)
		var/atom/movable/shud/logtext/L = b.vars["lbl"]
		if(L) L.maptext = "<center><span style=\"[LS_FONT]; color:[sel ? "#8be9ff" : LS_C_HINT]\">[uppertext(cat)]</span></center>"

client/proc/RefreshLogPage()
	ClearList(log_page); log_page = list()
	if(!mob) return
	var/mob/M = mob
	RegisterLifeMaterials()
	var/list/mats = LifeMatsInCategory(log_cat)
	// mapping progress in this category
	var/mapped = 0
	for(var/mc in mats)
		if(M.MatLogLifetime(mc) > 0) mapped++
	LogText(330, 12, 250, 16, "<span style=\"[LS_FONT_BODY]; color:[LS_C_HINT]; text-align:right\">[log_cat] mapped [mapped] / [mats.len]</span>", 0)

	// slot grid (first LOG_COLS*LOG_ROWS)
	var/shown = min(mats.len, LOG_COLS * LOG_ROWS)
	for(var/i = 1 to shown)
		var/mc = mats[i]
		var/col = (i - 1) % LOG_COLS
		var/row = round((i - 1) / LOG_COLS)
		var/x = LOG_GX + col * LOG_PITCH_X
		var/y = LOG_GY + row * LOG_PITCH_Y
		var/datum/matdef/d = LifeMatDef(mc)
		var/have = M.MatLogCount(mc)
		var/best = M.MatLogBest(mc)
		var/owned = M.MatLogLifetime(mc) > 0
		var/atom/movable/shud/logslot/s = new
		s.icon = owned ? 'HUD/log_slot.png' : 'HUD/log_slot_off.png'
		s.matclass = mc
		s.screen_loc = LOGloc(x, y, LOG_CELL)
		LogAdd(s, 0)
		if(owned && best)
			var/atom/movable/shud/logpic/rng = new
			rng.icon = 'HUD/log_ring.png'
			rng.color = QualityColor(best)
			rng.layer = LOG_LAYER + 0.4
			rng.mouse_opacity = 0
			rng.screen_loc = LOGloc(x, y, LOG_CELL)
			LogAdd(rng, 0)
		var/atom/movable/shud/logpic/ic = new
		ic.icon = d ? StIcon16(d.icon, d.icon_state) : null
		ic.layer = LOG_LAYER + 0.45
		ic.screen_loc = LOGloc(x + LOG_CELL / 2 - 8, y + 8, 16)
		if(!owned) ic.alpha = 60
		LogAdd(ic, 0)
		LogText(x, y + LOG_CELL - 26, LOG_CELL, 16, "<center><span style=\"[LS_FONT_BODY]; color:[owned ? "#ffffff" : LS_C_HINT]\">[owned ? "[d ? d.name : mc]" : "???"]</span></center>", 0, 0.5)
		if(owned)
			LogText(x, y + LOG_CELL - 14, LOG_CELL, 14, "<center><span style=\"[LS_FONT_BODY]; color:[LS_C_COST]\">[have]</span></center>", 0, 0.5)
	if(mats.len > shown)
		LogText(LOG_GX, LOG_GY + LOG_ROWS * LOG_PITCH_Y, 280, 14, "<span style=\"[LS_FONT_BODY]; color:[LS_C_HINT]\">+[mats.len - shown] more (scroll coming with Hunting)</span>", 0)

	// detail panel (right side, with breathing room from the grid)
	LogBG('HUD/log_detail.png', 298, 72, 286, 0.15, 0)
	if(log_wd_class)
		LogDrawWithdraw()
		return
	if(!log_sel || !(log_sel in mats))
		LogText(312, 190, 280, 40, "<center><span style=\"[LS_FONT_BODY]; color:[LS_C_HINT]\">Pick a material to inspect it.</span></center>", 0)
		return
	var/datum/matdef/sd = LifeMatDef(log_sel)
	var/atom/movable/shud/logpic/di = new
	di.icon = sd ? StIcon16(sd.icon, sd.icon_state) : null
	di.layer = LOG_LAYER + 0.45
	di.screen_loc = LOGloc(312, 88, 16)
	LogAdd(di, 0)
	LogText(336, 86, 250, 18, "<span style=\"[LS_FONT]; color:#ffffff\">[sd ? sd.name : log_sel]</span>", 0)
	LogText(336, 108, 250, 14, "<span style=\"[LS_FONT_BODY]; color:[LS_C_HINT]\">[log_cat]</span>", 0)
	var/dy = 136
	LogText(312, dy, 240, 14, "<span style=\"[LS_FONT]; color:#8be9ff\">HELD - click to withdraw</span>", 0); dy += 20
	var/anyq = 0
	for(var/q = QUAL_LEGENDARY to QUAL_POOR step -1)
		var/n = M.MatLogCountQ(log_sel, q)
		if(n <= 0) continue
		anyq = 1
		var/atom/movable/shud/logbtn/wb = new
		wb.icon = AqCoverIcon(284, 18)
		wb.action = "wd_start"
		wb.arg = list(log_sel, q)
		wb.screen_loc = LOGloc(312, dy, 18)
		LogAdd(wb, 0)
		LogText(320, dy + 2, 140, 14, "<span style=\"[LS_FONT_BODY]; color:[QualityColor(q)]\">[QualityName(q)]</span>", 0)
		LogText(472, dy + 2, 120, 14, "<span style=\"[LS_FONT_BODY]; color:#ffffff; text-align:right\">x[n]  &gt;</span>", 0)
		dy += 22
	if(!anyq)
		LogText(312, dy, 260, 14, "<span style=\"[LS_FONT_BODY]; color:[LS_C_HINT]\">none held right now</span>", 0); dy += 22
	dy += 8
	LogText(312, dy, 160, 14, "<span style=\"[LS_FONT]; color:#8be9ff\">LIFETIME</span>", 0)
	LogText(452, dy, 140, 14, "<span style=\"[LS_FONT]; color:[LS_C_COST]; text-align:right\">[Commas(M.MatLogLifetime(log_sel))]</span>", 0); dy += 24
	LogText(312, dy, 160, 14, "<span style=\"[LS_FONT]; color:#8be9ff\">BEST QUALITY</span>", 0)
	var/bq = M.MatLogBest(log_sel)
	LogText(452, dy, 140, 14, "<span style=\"[LS_FONT]; color:[bq ? QualityColor(bq) : LS_C_HINT]; text-align:right\">[bq ? QualityName(bq) : "-"]</span>", 0)

// the withdraw quantity chooser, drawn into the detail panel
client/proc/LogDrawWithdraw()
	var/mob/M = mob
	if(!M) return
	var/held = M.MatLogCountQ(log_wd_class, log_wd_quality)
	if(held <= 0)
		log_wd_class = ""
		RefreshLogPage()
		return
	log_wd_amount = clamp(log_wd_amount, 1, held)
	var/datum/matdef/d = LifeMatDef(log_wd_class)
	LogText(312, 86, 284, 18, "<span style=\"[LS_FONT]; color:#ffffff\">WITHDRAW</span>", 0)
	LogText(312, 108, 284, 16, "<span style=\"[LS_FONT_BODY]; color:[QualityColor(log_wd_quality)]\">[QualityName(log_wd_quality)] [d ? d.name : log_wd_class] &nbsp;-&nbsp; held [held]</span>", 0)
	LogText(312, 146, 284, 32, "<center><span style=\"font-family:'monogram'; font-size:24pt; color:[LS_C_COST]\">[log_wd_amount]</span></center>", 0)
	// steppers
	LogBtn("-10", "wd_adj", -10, 312, 190, 66)
	LogBtn("-1",  "wd_adj", -1,  384, 190, 66)
	LogBtn("+1",  "wd_adj", 1,   456, 190, 66)
	LogBtn("+10", "wd_adj", 10,  528, 190, 66)
	// presets
	LogBtn("1",   "wd_set", 1,    312, 214, 66)
	LogBtn("10",  "wd_set", 10,   384, 214, 66)
	LogBtn("100", "wd_set", 100,  456, 214, 66)
	LogBtn("MAX", "wd_set", held, 528, 214, 66)
	// confirm / cancel
	LogBtn("WITHDRAW", "wd_ok", null, 312, 248, 180, 24, "#1f7a52", "#eafff0")
	LogBtn("CANCEL", "wd_cancel", null, 500, 248, 96, 24, "#4a2a2a", "#ffbcbc")

client/proc/LogSlotClick(mc)
	if(!logmenu_open) return
	log_sel = mc
	log_wd_class = ""
	RefreshLogPage()

client/proc/LogButton(action, arg)
	if(!logmenu_open) return
	switch(action)
		if("close")
			CloseLogMenu()
		if("cat")
			log_cat = arg
			log_sel = ""
			log_wd_class = ""
			RefreshLogTabs()
			RefreshLogPage()
		if("wd_start")
			if(islist(arg))
				var/list/wl = arg
				if(wl.len >= 2)
					log_wd_class = wl[1]
					log_wd_quality = wl[2]
					log_wd_amount = 1
					RefreshLogPage()
		if("wd_adj")
			log_wd_amount += arg
			RefreshLogPage()
		if("wd_set")
			log_wd_amount = arg
			RefreshLogPage()
		if("wd_ok")
			if(mob && log_wd_class)
				mob.DoLogWithdraw(log_wd_class, log_wd_quality, log_wd_amount)
				log_wd_class = ""
				RefreshLogPage()
		if("wd_cancel")
			log_wd_class = ""
			RefreshLogPage()

// pull `amount` of a material quality out of the log as a tradeable ground stack; pickup re-deposits it
mob/proc/DoLogWithdraw(matclass, quality, amount)
	if(!matclass || amount <= 0) return
	quality = QualityClamp(quality)
	var/datum/matdef/d = LifeMatDef(matclass)
	if(!d) return
	amount = min(amount, MatLogCountQ(matclass, quality), INV_STACK_MAX)
	var/taken = MatLogTakeQ(matclass, quality, amount)
	if(taken <= 0) return
	var/turf/T = get_step(src, dir)
	var/obj/Items/Material/w = new d.mtype (T ? T : loc)
	w.CraftQuality = quality
	w.TotalStack = taken
	w.suffix = "[taken]"
	if(quality != QUAL_NORMAL) w.name = "[QualityName(quality)] [w.name]"
	src << "<font color=#78eb78>You set down [taken]x [w.name] to trade. Anyone who picks it up banks it in their log.</font>"

client/proc/LOGPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (log_atx - 1) * 32
	var/by = (log_aty - 1) * 32
	var/minx = -bx; if(minx > 0) minx = 0
	var/maxx = vw * 32 - LOG_W - bx; if(maxx < 0) maxx = 0
	var/miny = -by; if(miny > 0) miny = 0
	var/maxy = vh * 32 - LOG_H - by; if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/LogShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	if(log_chrome)
		for(var/atom/movable/o in log_chrome)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(log_page)
		for(var/atom/movable/o in log_page)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/LogPanelStart(params)
	log_pan_dragged = 0
	var/list/m = MouseAbs(params)
	if(!m) return
	log_pan_mx = m[1]; log_pan_my = m[2]
	log_pan_ox = log_pan_x; log_pan_oy = log_pan_y

client/proc/LogPanelMove(params)
	if(!logmenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = LOGPanBounds()
	var/wantx = clamp(log_pan_ox + (m[1] - log_pan_mx), b[1], b[2])
	var/wanty = clamp(log_pan_oy + (m[2] - log_pan_my), b[3], b[4])
	var/dx = wantx - log_pan_x
	var/dy = wanty - log_pan_y
	if(!dx && !dy) return
	log_pan_x = wantx; log_pan_y = wanty
	log_pan_dragged = 1
	LogShiftLive(dx, dy)

client/proc/LogPanelEnd()
	if(!log_pan_dragged) return
	log_pan_dragged = 0
	setPref("logPanX", log_pan_x)
	setPref("logPanY", log_pan_y)
