#define AQ_W 624
#define AQ_H 344
#define AQ_LAYER (FLY_LAYER + 3.8)
#define AQ_FONT      "font-family:'monogram'; font-size:12pt"          // native 16px
#define AQ_FONT_BODY "font-family:'Pixel Operator 8'; font-size:6pt"   // native 8px
#define AQ_ROW_H 38
#define AQ_VISIBLE 8
#define AQ_ROWS 9            // one buffer row for smooth scrolling
#define AQ_ROW_Y0 104        // band top, px from the panel top
#define AQ_BAND_H 208        // AQ_VISIBLE * AQ_ROW_H
#define AQ_TRACK_X 592
#define AQ_TRACK_Y 102
#define AQ_TRACK_H 206
#define AQ_THUMB_H 36

// row text colors
#define AQ_C_HEADER "#8be9ff"
#define AQ_C_NAME   "#ffffff"
#define AQ_C_OWNED  "#78eb78"
#define AQ_C_COST   "#ffd86b"
#define AQ_C_NOFUND "#ff6464"
#define AQ_C_LOCKED "#6b7a8d"
#define AQ_C_COMBO  "#8be9ff"
#define AQ_C_HINT   "#7a9bb5"

var/list/AQ_TAB_ORDER = list("Unarmed", "Blast", "Magic", "Sword", "Styles", "Signature")

// template cache
var/list/AQ_TEMPLATES = list()
var/list/AQ_ICON16 = list()

/proc/AqTemplate(pathtext)
	var/obj/Skills/o = AQ_TEMPLATES["[pathtext]"]
	if(!o)
		var/p = text2path("[pathtext]")
		if(!p) return null
		o = new p
		AQ_TEMPLATES["[pathtext]"] = o
	return o

/proc/AqIcon16(obj/Skills/T)
	if(!T) return null
	var/f = SkillMenuIcon(T)
	var/st = SkillMenuIconState(T)
	var/key = "[f]#[st]"
	if(!AQ_ICON16[key])
		var/icon/I = icon(f, st)
		I.Scale(32, 32)
		AQ_ICON16[key] = I
	return AQ_ICON16[key]

/proc/AqNiceName(pathtext)
	var/t = "[pathtext]"
	var/list/segs = splittext(t, "/")
	if(!segs.len) return t
	var/last = segs[segs.len]
	if(last == "_Any" && segs.len >= 2)                      // wildcard combo parents read as a category
		return "Any [replacetext(segs[segs.len - 1], "Style", " Style")]"
	return replacetext(last, "_", " ")

/proc/AqCoverIcon(w, h)          // interior-color strip that clips scrolling rows (tech panel interior)
	var/icon/I = icon('BLANK.dmi')
	I.Scale(w, h)
	I.DrawBox("#28365a", 1, 1, w, h)
	return I

mob/proc/AqStyleThresholds(t)
	switch(t)
		if(1) return glob.progress.T1_STYLES
		if(2) return glob.progress.T2_STYLES
		if(3) return glob.progress.T3_STYLES
		if(4) return glob.progress.T4_STYLES
	return null

mob/proc/AqSigThresholds(t)
	switch(t)
		if(1) return glob.progress.T1_SIGS
		if(2) return glob.progress.T2_SIGS
		if(3) return glob.progress.T3_SIGS
	return null

mob/proc/AqSlotsPassed(list/L)
	if(!L) return 0
	var/n = 0
	for(var/v in L)
		if(Potential >= v) n++
	return n

// saga characters use the saga signature system; mainframes keep cyber sigs
mob/proc/AqStylePicksLeft(t)
	if(Saga) return 0
	if(CyberneticMainframe && t >= 3) return 0
	return max(0, AqSlotsPassed(AqStyleThresholds(t)) - CountStyles(t))

mob/proc/AqSigPicksLeft(t)
	if(Saga) return 0
	if(CyberneticMainframe) return 0
	return max(0, AqSlotsPassed(AqSigThresholds(t)) - CountSigs(t))

mob/proc/AqNextPickPot(list/L, used)
	if(!L || used + 1 > L.len) return null   // every slot at this tier is already earned
	var/v = L[used + 1]
	return (Potential >= v) ? null : v

// interim T4 requirement
/proc/AqStyleCategory(obj/Skills/Buffs/NuStyle/S)
	if(istype(S, /obj/Skills/Buffs/NuStyle/UnarmedStyle)) return /obj/Skills/Buffs/NuStyle/UnarmedStyle
	if(istype(S, /obj/Skills/Buffs/NuStyle/SwordStyle)) return /obj/Skills/Buffs/NuStyle/SwordStyle
	if(istype(S, /obj/Skills/Buffs/NuStyle/MysticStyle)) return /obj/Skills/Buffs/NuStyle/MysticStyle
	return /obj/Skills/Buffs/NuStyle

/proc/AqStyleCategoryName(cat)
	switch(cat)
		if(/obj/Skills/Buffs/NuStyle/UnarmedStyle) return "Unarmed"
		if(/obj/Skills/Buffs/NuStyle/SwordStyle) return "Sword"
		if(/obj/Skills/Buffs/NuStyle/MysticStyle) return "Elemental"
	return "Any"

mob/proc/AqT4Ready(obj/Skills/Buffs/NuStyle/T)
	if(!T) return 0
	var/cat = AqStyleCategory(T)
	for(var/obj/Skills/Buffs/NuStyle/s in src)
		if(istype(s, cat) && s.SignatureTechnique >= 3)
			return 1
	return 0

// something in a T4 bucket is actually pickable (for the meditate reminder)
mob/proc/AqAnyT4StylePickable()
	for(var/key in list("UnarmedStylesT4", "SwordStylesT4", "HybridStylesT4", "ElementalStylesT4"))
		var/list/bucket = SkillTree[key]
		if(!bucket) continue
		for(var/pathtext in bucket)
			var/obj/Skills/Buffs/NuStyle/T = AqTemplate(pathtext)
			if(!T || !istype(T)) continue
			if(locate(T.type) in src) continue
			if(T.name in SignatureSelected) continue
			if(AqT4Ready(T)) return 1
	return 0

mob/proc/AqMissingPrereqs(obj/Skills/s)
	if(!s || !s.PreRequisite || !s.PreRequisite.len) return null
	var/list/prereqs = s.PreRequisite.Copy()
	for(var/obj/Skills/o in src)
		prereqs -= "[o.type]"
	if(!prereqs.len) return null
	var/text
	for(var/inn in prereqs)
		var/nice = replacetext(copytext("[inn]", 1 + findlasttext("[inn]", "/")), "_", " ")
		text = text ? "[text], [nice]" : nice
	return text

/datum/aqentry
	var/kind = "skill"       // header | skill | style | combo | recipe | sig | sigpart | note
	var/name = ""
	var/name_col = AQ_C_NAME
	var/right = ""
	var/right_col = AQ_C_COST
	var/path = null          // text path; info + buy target
	var/cost = 0
	var/can_buy = 0
	var/can_pick = 0         // free signature/style pick (potential-threshold slots)
	var/pick_tier = 0
	var/list/paths = null    // all granted paths (sig bundles grant several)
	var/lock_reason = null
	var/icon/icn = null

/atom/movable/shud/aqbg
	layer = AQ_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.AQPanelStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.AQPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.AQPanelEnd()

/atom/movable/shud/aqpic                 // decorative sprite
	layer = AQ_LAYER + 0.3
	mouse_opacity = 0

/atom/movable/shud/aqtext                // outlined floating text
	layer = AQ_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/aqrowpart             // row icon child
	layer = AQ_LAYER + 0.4
	mouse_opacity = 0

/atom/movable/shud/aqrowtext             // row text child
	layer = AQ_LAYER + 0.42
	mouse_opacity = 0
	maptext_height = 18
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/aqrow                 // pooled list row: transparent hit plate + children
	layer = AQ_LAYER + 0.35
	mouse_opacity = 2
	var/entry_idx = 0
	var/atom/movable/shud/aqpic/band          // tier-header backing band
	var/atom/movable/shud/aqrowpart/icn
	var/atom/movable/shud/aqrowtext/nametext
	var/atom/movable/shud/aqrowtext/righttext
	New()
		..()
		var/icon/hitplate = icon('HUD/tt_rowhit.png')
		hitplate.Scale(574, AQ_ROW_H)
		icon = hitplate
		band = new
		band.icon = 'HUD/tt_band.png'
		band.layer = AQ_LAYER + 0.36
		band.pixel_x = 68
		band.pixel_y = 1
		band.alpha = 0
		vis_contents += band
		icn = new
		icn.pixel_x = 16
		icn.pixel_y = 5
		icn.alpha = 0
		vis_contents += icn
		nametext = new
		nametext.maptext_x = 56
		nametext.maptext_y = 16
		nametext.maptext_width = 390
		vis_contents += nametext
		righttext = new
		righttext.maptext_x = 430
		righttext.maptext_y = 16
		righttext.maptext_width = 120
		vis_contents += righttext
	Del()
		for(var/atom/movable/c in list(band, icn, nametext, righttext))
			if(c)
				vis_contents -= c
				del c
		..()
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(!usr.client.AqClickInBand(params)) return   // row slivers hidden under the cover strips aren't clickable
		if(params && findtext(params, "right=1"))
			usr.client.AqRowInfo(entry_idx)
			return
		usr.client.AqRowClick(entry_idx)

/atom/movable/shud/aqbtn                 // tab plate
	layer = AQ_LAYER + 0.6
	mouse_opacity = 2
	var/action
	var/arg
	var/atom/movable/shud/aqtext/lbl
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr) usr.client.AcquireButton(action, arg)

/atom/movable/shud/aqwidget              // close X, shared press animation
	parent_type = /atom/movable/shud/pressbtn
	layer = AQ_LAYER + 0.65
	mouse_opacity = 2
	DoAction()
		if(usr && usr.client) usr.client.AcquireButton(action, null)

/atom/movable/shud/aqtrack
	layer = AQ_LAYER + 0.55
	mouse_opacity = 2
	Click(location, control, params)
		if(usr) usr.client.AqScrollTrackTo(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.AqScrollTrackTo(params)

/atom/movable/shud/aqthumb
	layer = AQ_LAYER + 0.56
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.AqScrollTrackTo(params)

/atom/movable/shud/aqconfirmbg            // learn-confirm prompt; right-click dismisses (= No)
	layer = AQ_LAYER + 1.0
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr && usr.client) usr.client.AqPromptAction("no")

/atom/movable/shud/aqconfirmbtn
	layer = AQ_LAYER + 1.15
	mouse_opacity = 2
	var/action
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.AqPromptAction(action)

client
	var/tmp
		aqmenu_open = 0
		aq_tab = "Unarmed"
		aq_atx = 1
		aq_aty = 1
		aq_pan_x = 0
		aq_pan_y = 0
		aq_pan_mx = 0
		aq_pan_my = 0
		aq_pan_ox = 0
		aq_pan_oy = 0
		aq_pan_dragged = FALSE
		list/aq_chrome
		list/aq_rows
		list/aq_entries
		list/aq_tabbtns
		aq_scroll_px = 0
		aq_scroll_target = 0
		aq_scroll_anim = FALSE
		aq_buying = FALSE
		atom/movable/shud/aqthumb/aq_thumb
		atom/movable/shud/aqtext/aq_rpp_label
		list/aq_confirm_objs
		datum/aqentry/aq_confirm_entry
		atom/movable/shud/menubtn/btn_acquire
		atom/movable/shud/menulabel/btn_acquire_label

client/proc/AQloc(dx, dyTop, h = 0)
	var/py = AQ_H - dyTop - h
	var/ax = dx + aq_pan_x
	var/ay = py + aq_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[aq_atx + (ax - axp) / 32]:[axp],[aq_aty + (ay - ayp) / 32]:[ayp]"

client/proc/InitAcquireButton()
	btn_acquire = new('HUD/ui_icon_skills.png')
	btn_acquire.btn_id = "acquire"
	btn_acquire.screen_loc = "EAST:-4,NORTH:-284"
	shud_parts += btn_acquire
	btn_acquire_label = new
	btn_acquire_label.maptext_width = 64
	btn_acquire_label.SetText("Acquire")
	btn_acquire_label.pixel_x = -70
	btn_acquire_label.pixel_y = 8
	btn_acquire.label = btn_acquire_label
	btn_acquire.vis_contents += btn_acquire_label

client/proc/ResetAcquireHUD()
	CloseAcquireMenu()
	btn_acquire = null
	btn_acquire_label = null

client/proc/ToggleAcquireMenu()
	if(aqmenu_open) CloseAcquireMenu()
	else OpenAcquireMenu()

client/proc/OpenAcquireMenu()
	if(aqmenu_open || !mob) return
	CloseMenu()          // one big panel at a time
	CloseInventory()
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseLifeSkillsMenu()
	CloseStationMenu()
	aqmenu_open = 1
	aq_tab = "Unarmed"
	aq_scroll_px = 0
	aq_scroll_target = 0
	// aq_buying deliberately NOT reset here, prevents dupe skill buying

	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(AQ_W / 32); if(mtw * 32 < AQ_W) mtw++
	var/mth = round(AQ_H / 32); if(mth * 32 < AQ_H) mth++
	aq_atx = max(1, round((vw - mtw) / 2) + 1)
	aq_aty = max(1, round((vh - mth) / 2) + 1)
	aq_pan_x = getPref("aqPanX"); if(isnull(aq_pan_x)) aq_pan_x = 0
	aq_pan_y = getPref("aqPanY"); if(isnull(aq_pan_y)) aq_pan_y = 0
	var/list/b = AQPanBounds()
	aq_pan_x = clamp(aq_pan_x, b[1], b[2])
	aq_pan_y = clamp(aq_pan_y, b[3], b[4])

	if(btn_acquire)
		btn_acquire.icon = 'HUD/ui_slot_unavailable.png'
		btn_acquire.SetGlyphDimmed(TRUE)
	if(btn_acquire_label) btn_acquire_label.alpha = 0

	BuildAcquireChrome()
	AqBuildEntries()
	RefreshAcquireRows()
	RefreshAqTabLook()
	var/list/all = aq_chrome.Copy()
	all += aq_rows
	KineticEntrance(all)

client/proc/CloseAcquireMenu()
	if(!aqmenu_open && !aq_chrome) return
	aqmenu_open = 0
	CloseSkillInfo()                     // info popups opened from our rows
	HideAqConfirm()
	ClearList(aq_rows); aq_rows = null
	ClearList(aq_chrome); aq_chrome = null
	aq_entries = null
	aq_tabbtns = null
	aq_thumb = null
	aq_rpp_label = null
	if(btn_acquire)
		btn_acquire.icon = 'HUD/ui_slot_available.png'
		btn_acquire.SetGlyphDimmed(FALSE)

client/proc/AqMakeTab(tabname, dxLeft)
	var/atom/movable/shud/aqbtn/b = new
	b.icon = 'HUD/ui_tab_idle.png'
	b.action = "tab"
	b.arg = tabname
	b.screen_loc = AQloc(dxLeft, 44, 32)
	aq_chrome += b
	var/atom/movable/shud/aqtext/L = new
	L.layer = AQ_LAYER + 0.62
	L.maptext_width = 84
	L.maptext_height = 16
	L.screen_loc = AQloc(dxLeft, 44 + 6, 16)
	aq_chrome += L
	b.lbl = L
	aq_tabbtns[tabname] = b
	return b

client/proc/BuildAcquireChrome()
	aq_chrome = list()
	aq_tabbtns = list()

	var/atom/movable/shud/aqbg/P = new
	P.icon = 'HUD/tech_panel.png'
	P.screen_loc = AQloc(0, 0, AQ_H)
	aq_chrome += P

	var/atom/movable/shud/aqpic/tp = new
	tp.icon = 'HUD/tech_titleplate.png'
	tp.screen_loc = AQloc(212, 6, 32)
	aq_chrome += tp
	var/atom/movable/shud/aqtext/title = new
	title.maptext_width = 200
	title.maptext_height = 16
	title.screen_loc = AQloc(212, 12, 16)
	title.maptext = "<center><span style=\"[AQ_FONT]; color:#ffffff\">ACQUIRE SKILLS</span></center>"
	aq_chrome += title

	aq_rpp_label = new
	aq_rpp_label.maptext_width = 110
	aq_rpp_label.maptext_height = 16
	aq_rpp_label.screen_loc = AQloc(478, 14, 16)
	aq_chrome += aq_rpp_label

	var/atom/movable/shud/aqwidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.action = "close"
	X.screen_loc = AQloc(590, 12, 24)
	aq_chrome += X

	for(var/i = 1 to AQ_TAB_ORDER.len)
		AqMakeTab(AQ_TAB_ORDER[i], 18 + (i - 1) * 98)

	// interior-color strips clip rows scrolling past the band; hint rides the top strip
	var/atom/movable/shud/aqpic/ct = new
	ct.icon = AqCoverIcon(574, 26)
	ct.layer = AQ_LAYER + 0.5
	ct.screen_loc = AQloc(18, AQ_ROW_Y0 - 26, 26)
	aq_chrome += ct
	var/atom/movable/shud/aqpic/cb = new
	cb.icon = AqCoverIcon(574, 22)
	cb.layer = AQ_LAYER + 0.5
	cb.screen_loc = AQloc(18, AQ_ROW_Y0 + AQ_BAND_H, 22)
	aq_chrome += cb
	var/atom/movable/shud/aqtext/hint = new
	hint.layer = AQ_LAYER + 0.55
	hint.maptext_width = 574
	hint.maptext_height = 12
	hint.screen_loc = AQloc(18, AQ_ROW_Y0 - 20, 12)
	hint.maptext = "<center><span style=\"[AQ_FONT_BODY]; color:[AQ_C_HINT]\">LEFT-CLICK TO LEARN &#183; RIGHT-CLICK FOR DETAILS</span></center>"
	aq_chrome += hint

	var/atom/movable/shud/aqtrack/tr = new
	tr.icon = 'HUD/scroll_track.png'
	tr.screen_loc = AQloc(AQ_TRACK_X, AQ_TRACK_Y, AQ_TRACK_H)
	aq_chrome += tr
	aq_thumb = new
	aq_thumb.icon = 'HUD/scroll_thumb.png'
	aq_thumb.screen_loc = AQloc(AQ_TRACK_X + 1, AQ_TRACK_Y, AQ_THUMB_H)
	aq_chrome += aq_thumb

	for(var/atom/movable/o in aq_chrome)
		screen += o

	aq_rows = list()
	for(var/j = 1 to AQ_ROWS)
		var/atom/movable/shud/aqrow/r = new
		r.screen_loc = AQloc(18, AQ_ROW_Y0 + (j - 1) * AQ_ROW_H, AQ_ROW_H)
		r.alpha = 0
		aq_rows += r
		screen += r

	AqRefreshBalance()

client/proc/AqRefreshBalance()
	if(aq_rpp_label && mob)
		aq_rpp_label.maptext = "<span style=\"[AQ_FONT]; color:[AQ_C_COST]\">RPP [round(mob.GetRPPSpendable())]</span>"

client/proc/RefreshAqTabLook()
	if(!aq_tabbtns) return
	for(var/tabname in aq_tabbtns)
		var/atom/movable/shud/aqbtn/b = aq_tabbtns[tabname]
		if(!b) continue
		b.icon = (aq_tab == tabname) ? 'HUD/ui_tab_active.png' : 'HUD/ui_tab_idle.png'
		if(b.lbl)
			b.lbl.maptext = "<center><span style=\"[AQ_FONT]; color:[aq_tab == tabname ? "#06283b" : "#cfe3f5"]\">[uppertext(tabname)]</span></center>"

client/proc/AcquireButton(action, arg)
	if(!aqmenu_open) return
	switch(action)
		if("close")
			CloseAcquireMenu()
		if("tab")
			AcquireTab(arg)

client/proc/AcquireTab(tabname)
	if(!aqmenu_open || !(tabname in AQ_TAB_ORDER)) return
	HideAqConfirm()                     // don't leave a learn prompt floating over another tab
	aq_tab = tabname
	aq_scroll_px = 0
	aq_scroll_target = 0
	AqBuildEntries()
	RefreshAcquireRows()
	RefreshAqTabLook()

client/proc/AqHeader(t)
	var/datum/aqentry/E = new
	E.kind = "header"
	E.name = t
	E.name_col = AQ_C_HEADER
	aq_entries += E

client/proc/AqNote(t)
	var/datum/aqentry/E = new
	E.kind = "note"
	E.name = t
	E.name_col = AQ_C_HINT
	aq_entries.Insert(1, E)

client/proc/AqBuildEntries()
	aq_entries = list()
	if(!mob) return
	switch(aq_tab)
		if("Unarmed", "Blast", "Magic", "Sword")
			AqBuildSkillTab(aq_tab)
		if("Styles")
			AqBuildStylesTab()
		if("Signature")
			AqBuildSigTab()
	AqRefreshBalance()

client/proc/AqBuildSkillTab(cat)
	var/list/costs = list(TIER_1_COST, TIER_2_COST, TIER_3_COST, TIER_4_COST, TIER_5_COST)
	for(var/t = 1 to 5)
		var/list/bucket = SkillTree["[cat]T[t]"]
		if(!bucket || !bucket.len) continue
		AqHeader("TIER [t]  &#183;  [costs[t]] RPP")
		for(var/pathtext in bucket)
			AqAddBuyable(pathtext, costs[t], "skill")

// shared for tree skills and 0-RPP base styles
client/proc/AqAddBuyable(pathtext, cost, kind)
	var/obj/Skills/T = AqTemplate(pathtext)
	if(!T) return
	var/datum/aqentry/E = new
	E.kind = kind
	E.path = "[pathtext]"
	E.cost = cost
	E.name = AqNiceName(pathtext)
	E.icn = AqIcon16(T)
	var/bypass = (mob.Saga == "Weapon Soul" && T.NeedsSword)
	if(locate(T.type) in mob)
		E.name_col = "#cfe3f5"
		E.right = "OWNED"
		E.right_col = AQ_C_OWNED
	else if((T.type in mob.SkillsLocked) && !bypass)
		E.name_col = AQ_C_LOCKED
		E.right = "LOCKED"
		E.right_col = AQ_C_NOFUND
		E.lock_reason = "[E.name] is a prerequisite to a skill you've already upgraded."
	else
		var/lockname = null
		if(!bypass)
			for(var/lp in T.LockOut)
				var/p3 = text2path("[lp]")
				if(p3 && (locate(p3) in mob))
					lockname = AqNiceName("[lp]")
					break
		if(lockname)
			E.name_col = AQ_C_LOCKED
			E.right = "LOCKED"
			E.right_col = AQ_C_NOFUND
			E.lock_reason = "You cannot learn [E.name] while you possess [lockname]."
		else
			var/needname = null
			for(var/pp in T.PreRequisite)
				var/p2 = text2path("[pp]")
				if(p2 && !(locate(p2) in mob))
					needname = AqNiceName("[pp]")
					break
			if(needname)
				E.name_col = AQ_C_LOCKED
				E.right = "LOCKED"
				E.right_col = AQ_C_NOFUND
				E.lock_reason = "[E.name] requires [needname] first."
			else
				E.can_buy = 1
				E.right = "[cost] RPP"
				E.right_col = (mob.GetRPPSpendable() >= cost) ? AQ_C_COST : AQ_C_NOFUND
	aq_entries += E

// recipe sublines
client/proc/AqAddRecipes(obj/Skills/Buffs/NuStyle/T)
	if(!T || !T.StyleComboUnlock) return
	for(var/px in T.StyleComboUnlock)
		var/partnertext = "[px]"
		var/resulttext = "[T.StyleComboUnlock[px]]"
		var/checktext = partnertext
		if(findtext(partnertext, "/_Any"))
			checktext = copytext(partnertext, 1, findtext(partnertext, "/_Any"))
		var/ptype = text2path(checktext)          // for _Any this is the category parent
		var/rtype = text2path(resulttext)
		if(!ptype || !rtype) continue
		var/datum/aqentry/E = new
		E.kind = "recipe"
		E.path = resulttext
		var/powned = 0
		if(findtext(partnertext, "/_Any"))
			var/obj/Skills/rT = AqTemplate(resulttext)
			if(rT)
				for(var/obj/Skills/Buffs/NuStyle/style in mob)
					if(istype(style, ptype) && style.SignatureTechnique >= rT.SignatureTechnique - 1)
						powned = 1
						break
		else if(locate(ptype) in mob)
			powned = 1
		var/pcol = powned ? AQ_C_OWNED : AQ_C_HINT
		var/rcol = (locate(rtype) in mob) ? AQ_C_OWNED : AQ_C_HINT
		E.name = "&#160;&#160;&#160;&#160;+ <span style=\"color:[pcol]\">[AqNiceName(partnertext)]</span>  =  <span style=\"color:[rcol]\">[AqNiceName(resulttext)]</span>"
		E.name_col = AQ_C_HINT
		aq_entries += E

client/proc/AqAddComboStyle(pathtext, tier)
	var/obj/Skills/T = AqTemplate(pathtext)
	if(!T) return
	var/datum/aqentry/E = new
	E.kind = "combo"
	E.path = "[pathtext]"
	E.pick_tier = tier
	E.name = AqNiceName(pathtext)
	E.icn = AqIcon16(T)
	if(locate(T.type) in mob)
		E.name_col = "#cfe3f5"
		E.right = "OWNED"
		E.right_col = AQ_C_OWNED
	else
		var/unlocked
		if(tier >= 4)
			unlocked = mob.AqT4Ready(T) && !(T.name in mob.SignatureSelected)
		else
			unlocked = (T.name in mob.SignatureStyles) && !(T.name in mob.SignatureSelected)
		var/left = mob.AqStylePicksLeft(tier)
		var/smissing = (unlocked && left > 0) ? mob.AqMissingPrereqs(T) : null
		if(unlocked && left > 0 && smissing)
			E.name_col = AQ_C_LOCKED
			E.right = "LOCKED"
			E.right_col = AQ_C_NOFUND
			E.lock_reason = "You still need to learn [smissing] first."
		else if(unlocked && left > 0)
			E.can_pick = 1
			E.name_col = AQ_C_NAME
			E.right = "PICK"
			E.right_col = AQ_C_COST
		else if(unlocked)
			E.name_col = "#cfe3f5"
			E.right = "UNLOCKED"
			E.right_col = AQ_C_COMBO
			if(mob.Saga)
				E.lock_reason = "Saga characters develop saga styles and signatures instead of standard picks."
			else if(mob.CyberneticMainframe && tier >= 3)
				E.lock_reason = "Cybernetic Mainframes cannot take Tier [tier] style picks."
			else
				var/np = mob.AqNextPickPot(mob.AqStyleThresholds(tier), mob.CountStyles(tier))
				E.lock_reason = np ? "You've unlocked [E.name], your next Tier [tier] style pick comes at Potential [np]." : "You've unlocked [E.name], but no Tier [tier] style picks remain."
		else
			E.name_col = "#cfe3f5"
			E.right_col = AQ_C_COMBO
			if(tier >= 4)
				E.right = "NEEDS T3"
				E.lock_reason = "Requires any Tier 3 [AqStyleCategoryName(AqStyleCategory(T))] style first."
			else
				E.right = "VIA COMBO"
				E.lock_reason = "Combine the listed styles to unlock [E.name], then pick it here once you reach the potential threshold."
	aq_entries += E
	if(tier >= 4 && istype(T, /obj/Skills/Buffs/NuStyle))   // synthetic requirement line (T4 has no recipe data)
		var/datum/aqentry/R = new
		R.kind = "recipe"
		R.path = "[pathtext]"
		var/pcol2 = mob.AqT4Ready(T) ? AQ_C_OWNED : AQ_C_HINT
		var/rcol2 = (locate(T.type) in mob) ? AQ_C_OWNED : AQ_C_HINT
		R.name = "&#160;&#160;&#160;&#160;+ <span style=\"color:[pcol2]\">Any Tier 3 [AqStyleCategoryName(AqStyleCategory(T))] Style</span>  =  <span style=\"color:[rcol2]\">[E.name]</span>"
		R.name_col = AQ_C_HINT
		aq_entries += R
	AqAddRecipes(T)

client/proc/AqBuildStylesTab()
	for(var/obj/Skills/Buffs/NuStyle/os in mob)   // refresh combo unlocks so new picks show without a meditate
		mob.StyleUnlock(os)
	var/pline = "STYLE PICKS"
	for(var/t = 1 to 4)
		pline += "  &#183;  T[t] [mob.CountStyles(t)]/[mob.AqSlotsPassed(mob.AqStyleThresholds(t))]"
	AqHeader(pline)
	var/list/fams = list("UNARMED" = "UnarmedStyles", "ELEMENTAL" = "ElementalStyles", "SWORD" = "SwordStyles", "HYBRID" = "HybridStyles")
	for(var/famname in fams)
		var/basekey = fams[famname]
		AqHeader("[famname] STYLES")
		var/list/base = SkillTree[basekey]
		if(base)
			for(var/pathtext in base)
				AqAddBuyable(pathtext, SkillTree[basekey][pathtext], "style")
				var/obj/Skills/T = AqTemplate(pathtext)
				if(istype(T, /obj/Skills/Buffs/NuStyle)) AqAddRecipes(T)
		for(var/t = 1 to 4)
			var/list/bucket = SkillTree["[basekey]T[t]"]
			if(!bucket || !bucket.len) continue
			for(var/pathtext in bucket)
				AqAddComboStyle(pathtext, t)
	AqNote("ADVANCED STYLES UNLOCK THROUGH COMBINATIONS - PICK THEM HERE AT EACH POTENTIAL THRESHOLD")

client/proc/AqSigOwned(entryval)
	var/firsttext = istext(entryval) ? entryval : (length(entryval) ? entryval[1] : null)
	if(!firsttext) return 0
	var/p = text2path("[firsttext]")
	if(!p) return 0
	return (locate(p) in mob) ? 1 : 0

client/proc/AqAddSigEntry(signame, entryval, t)
	var/firsttext = istext(entryval) ? entryval : (length(entryval) ? entryval[1] : null)
	if(!firsttext) return
	var/obj/Skills/T = AqTemplate(firsttext)
	var/datum/aqentry/E = new
	E.kind = "sig"
	E.path = "[firsttext]"
	E.pick_tier = t
	var/list/comps = entryval               // typed alias so .Copy() resolves on list values
	E.paths = istext(entryval) ? list("[entryval]") : comps.Copy()
	E.name = signame
	E.icn = T ? AqIcon16(T) : null
	if(AqSigOwned(entryval) || (signame in mob.SignatureSelected))
		E.name_col = "#cfe3f5"
		E.right = "PICKED"
		E.right_col = AQ_C_OWNED
	else
		var/left = mob.AqSigPicksLeft(t)
		if(left > 0)
			var/missing = null
			for(var/ct in E.paths)
				var/obj/Skills/CT = AqTemplate(ct)
				if(!CT) continue
				missing = mob.AqMissingPrereqs(CT)
				if(missing) break
			if(!missing)
				E.can_pick = 1
				E.name_col = AQ_C_NAME
				E.right = "PICK"
				E.right_col = AQ_C_COST
			else
				E.name_col = AQ_C_LOCKED
				E.right = "LOCKED"
				E.right_col = AQ_C_NOFUND
				E.lock_reason = "You still need to learn [missing] first."
		else
			E.name_col = AQ_C_NAME
			if(mob.Saga)
				E.lock_reason = "Saga characters develop saga signatures instead of standard picks."
			else if(mob.CyberneticMainframe)
				E.lock_reason = "Cybernetic Mainframes cannot take standard signature picks."
			else
				var/np = mob.AqNextPickPot(mob.AqSigThresholds(t), mob.CountSigs(t))
				if(np)
					E.right = "POT [np]"
					E.right_col = AQ_C_HINT
					E.lock_reason = "Your next Tier [t] signature pick comes at Potential [np]."
				else
					E.lock_reason = "No Tier [t] signature picks remain."
	aq_entries += E
	if(!istext(entryval))                       // bundle: list the components, each right-clickable
		for(var/comptext in entryval)
			if(!text2path("[comptext]")) continue
			var/datum/aqentry/C = new
			C.kind = "sigpart"
			C.path = "[comptext]"
			C.name = "&#160;&#160;&#160;&#160;&#187; [AqNiceName(comptext)]"
			C.name_col = AQ_C_HINT
			aq_entries += C

client/proc/AqBuildSigTab()
	var/list/tiers = list(Tier1, Tier2, Tier3)
	for(var/t = 1 to 3)
		var/list/pool = tiers[t]
		if(!pool || !pool.len) continue
		AqHeader("TIER [t]  &#183;  PICKS [mob.CountSigs(t)]/[mob.AqSlotsPassed(mob.AqSigThresholds(t))]")
		for(var/signame in pool)
			AqAddSigEntry(signame, pool[signame], t)
	AqNote("SIGNATURE PICKS UNLOCK AS YOUR POTENTIAL PASSES EACH TIER'S THRESHOLDS")

client/proc/RefreshAcquireRows()
	if(!aq_rows || !aq_entries) return
	var/total = aq_entries.len
	var/maxpx = max(0, total * AQ_ROW_H - AQ_BAND_H)
	aq_scroll_px = clamp(aq_scroll_px, 0, maxpx)
	aq_scroll_target = clamp(aq_scroll_target, 0, maxpx)   // a rebuild that shrinks the list must not strand a wheel glide
	var/sub = aq_scroll_px % AQ_ROW_H
	var/first = (aq_scroll_px - sub) / AQ_ROW_H
	for(var/j = 1 to aq_rows.len)
		var/atom/movable/shud/aqrow/r = aq_rows[j]
		var/dyTop = AQ_ROW_Y0 + (j - 1) * AQ_ROW_H - sub
		r.screen_loc = AQloc(18, dyTop, AQ_ROW_H)
		var/idx = first + j
		if(idx <= total && dyTop < AQ_ROW_Y0 + AQ_BAND_H - 4)
			AqPaintRow(r, idx)
		else
			r.entry_idx = 0
			r.alpha = 0
			r.band.alpha = 0
			r.icn.alpha = 0
			r.nametext.maptext = ""
			r.righttext.maptext = ""
	if(aq_thumb)
		if(maxpx <= 0)
			aq_thumb.alpha = (total > 0) ? 80 : 0
			aq_thumb.screen_loc = AQloc(AQ_TRACK_X + 1, AQ_TRACK_Y, AQ_THUMB_H)
		else
			aq_thumb.alpha = 255
			var/off = round((aq_scroll_px / maxpx) * (AQ_TRACK_H - AQ_THUMB_H))
			aq_thumb.screen_loc = AQloc(AQ_TRACK_X + 1, AQ_TRACK_Y + off, AQ_THUMB_H)

client/proc/AqPaintRow(atom/movable/shud/aqrow/r, idx)
	var/datum/aqentry/E = aq_entries[idx]
	r.entry_idx = idx
	r.alpha = 255
	if(E.kind == "header" || E.kind == "note")
		r.band.alpha = (E.kind == "header") ? 255 : 0
		r.icn.alpha = 0
		r.nametext.maptext_x = 0
		r.nametext.maptext_width = 560
		if(E.kind == "note")
			// this looks slightly better, may still play around with it
			r.nametext.maptext_y = 9
			r.nametext.maptext = "<center><span style=\"[AQ_FONT_BODY]; color:[E.name_col]\">[E.name]</span></center>"
		else
			r.nametext.maptext_y = 7      // centers the label in the tt_band strip (band spans row py 1..25)
			r.nametext.maptext = "<center><span style=\"[AQ_FONT]; color:[E.name_col]\">[E.name]</span></center>"
		r.righttext.maptext = ""
		return
	r.band.alpha = 0
	r.nametext.maptext_y = 16
	if(E.icn)
		r.icn.icon = E.icn
		r.icn.alpha = 255
	else
		r.icn.alpha = 0
	r.nametext.maptext_x = 56
	r.nametext.maptext_width = 374
	r.nametext.maptext = "<span style=\"[AQ_FONT]; color:[E.name_col]\">[E.name]</span>"
	r.righttext.maptext = "<span style=\"[AQ_FONT]; color:[E.right_col]; text-align:right\">[E.right]</span>"

client/proc/AqWheelScroll(delta_y)
	if(!aqmenu_open || !aq_entries) return 0
	var/maxpx = max(0, aq_entries.len * AQ_ROW_H - AQ_BAND_H)
	var/dir = (delta_y > 0) ? -1 : 1
	aq_scroll_target = clamp(aq_scroll_target + dir * AQ_ROW_H * 2, 0, maxpx)
	if(!aq_scroll_anim) AnimateAqScroll()
	return 1

client/proc/AnimateAqScroll()
	set waitfor = 0
	aq_scroll_anim = TRUE
	while(aqmenu_open && aq_entries && aq_scroll_px != aq_scroll_target)
		var/diff = aq_scroll_target - aq_scroll_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1
		aq_scroll_px += stepp
		RefreshAcquireRows()
		sleep(world.tick_lag)
	aq_scroll_anim = FALSE

client/proc/AqScrollTrackTo(params)
	if(!aqmenu_open || !aq_entries) return
	var/maxpx = max(0, aq_entries.len * AQ_ROW_H - AQ_BAND_H)
	if(maxpx <= 0) return
	var/list/pl = params2list(params)
	var/sl = pl["screen-loc"]
	if(!sl) return
	var/list/cm = splittext(sl, ",")
	if(cm.len < 2) return
	var/list/yp = splittext(cm[2], ":")
	if(yp.len < 2) return
	var/row = text2num(yp[1])
	var/py = text2num(yp[2])
	if(isnull(row) || isnull(py)) return
	var/local_h = (row - 1) * 32 + py - (aq_aty - 1) * 32 - aq_pan_y
	var/frac = ((AQ_H - AQ_TRACK_Y) - local_h) / AQ_TRACK_H
	frac = clamp(frac, 0, 1)
	aq_scroll_px = round(frac * maxpx)
	aq_scroll_target = aq_scroll_px          // cancel any running wheel glide
	RefreshAcquireRows()

client/proc/AqClickInBand(params)
	if(!params) return 0
	var/list/pl = params2list(params)
	var/sl = pl["screen-loc"]
	if(!sl) return 0
	var/list/cm = splittext(sl, ",")
	if(cm.len < 2) return 0
	var/list/yp = splittext(cm[2], ":")
	if(yp.len < 2) return 0
	var/row = text2num(yp[1])
	var/py = text2num(yp[2])
	if(isnull(row) || isnull(py)) return 0
	var/dyTop = AQ_H - ((row - 1) * 32 + py - (aq_aty - 1) * 32 - aq_pan_y)
	return (dyTop >= AQ_ROW_Y0 && dyTop <= AQ_ROW_Y0 + AQ_BAND_H)

client/proc/AqRowClick(idx)
	if(!aqmenu_open || !aq_entries || idx < 1 || idx > aq_entries.len || !mob) return
	var/datum/aqentry/E = aq_entries[idx]
	if(E.can_buy)
		spawn() AqTryBuy(E)
	else if(E.can_pick)
		spawn() AqTryPick(E)
	else if(E.lock_reason)
		mob << "<font color=#8be9ff>[E.lock_reason]</font>"

client/proc/AqRowInfo(idx)
	if(!aqmenu_open || !aq_entries || idx < 1 || idx > aq_entries.len || !mob) return
	var/datum/aqentry/E = aq_entries[idx]
	if(!E.path) return
	var/p = text2path("[E.path]")
	if(!p) return
	var/obj/Skills/target = (locate(p) in mob)         // owned instance shows live values
	if(!target) target = AqTemplate(E.path)
	if(!target) return
	if(skinfo_skill == target)
		CloseSkillInfo()
	else if(istype(target, /obj/Skills/Buffs))
		ShowBuffInfo(target)
	else
		ShowSkillInfo(target)

client/proc/AqMkPromptBtn(action, label, color, dx, dyTop)
	var/atom/movable/shud/aqconfirmbtn/b = new
	b.icon = 'HUD/pbtn.png'
	b.action = action
	b.screen_loc = AQloc(dx, dyTop, 24)
	aq_confirm_objs += b
	screen += b
	var/atom/movable/shud/aqtext/L = new
	L.layer = AQ_LAYER + 1.2
	L.maptext_width = 80
	L.maptext_height = 24
	L.maptext_y = 4
	L.screen_loc = AQloc(dx, dyTop, 24)
	L.maptext = "<center><span style=\"[AQ_FONT]; color:[color]\">[label]</span></center>"
	aq_confirm_objs += L
	screen += L

client/proc/ShowAqConfirm(datum/aqentry/E)
	HideAqConfirm()
	if(!E) return
	aq_confirm_entry = E
	aq_confirm_objs = list()

	var/atom/movable/shud/aqconfirmbg/bg = new
	bg.icon = 'HUD/party_prompt.png'
	bg.screen_loc = AQloc(200, 102, 140)
	aq_confirm_objs += bg
	screen += bg

	var/obj/Skills/T = AqTemplate(E.path)
	if(T)
		var/atom/movable/shud/aqpic/ic = new
		ic.icon = SkillMenuIcon(T)
		ic.icon_state = SkillMenuIconState(T)
		ic.layer = AQ_LAYER + 1.1
		ic.screen_loc = AQloc(200 + 96, 102 + 14, 32)
		aq_confirm_objs += ic
		screen += ic

	var/atom/movable/shud/aqtext/nm = new
	nm.layer = AQ_LAYER + 1.2
	nm.maptext_width = 208
	nm.maptext_height = 16
	nm.screen_loc = AQloc(200 + 8, 102 + 52, 16)
	nm.maptext = "<center><span style=\"[AQ_FONT]; color:[AQ_C_COST]\">[E.name]</span></center>"
	aq_confirm_objs += nm
	screen += nm

	var/atom/movable/shud/aqtext/q = new
	q.layer = AQ_LAYER + 1.2
	q.maptext_width = 208
	q.maptext_height = 16
	q.screen_loc = AQloc(200 + 8, 102 + 74, 16)
	var/qline = "Learn for free?"
	if(E.can_pick) qline = "Use a Tier [E.pick_tier] pick?"
	else if(E.cost > 0) qline = "Learn for [E.cost] RPP?"
	q.maptext = "<center><span style=\"[AQ_FONT]; color:#bfefff\">[qline]</span></center>"
	aq_confirm_objs += q
	screen += q

	AqMkPromptBtn("yes", "Yes", "#78eb78", 200 + 20, 102 + 103)
	AqMkPromptBtn("no", "No", "#ff6464", 200 + 124, 102 + 103)

	KineticEntrance(aq_confirm_objs)

client/proc/HideAqConfirm()
	aq_confirm_entry = null
	ClearList(aq_confirm_objs)
	aq_confirm_objs = null

client/proc/AqPromptAction(action)
	var/datum/aqentry/E = aq_confirm_entry
	HideAqConfirm()
	if(action != "yes" || !E || !aqmenu_open) return
	if(E.can_pick)
		spawn() AqFinalizePick(E)
	else
		spawn() AqFinalizeBuy(E)

client/proc/AqTryBuy(datum/aqentry/E)
	if(!mob || !E || !E.can_buy || !E.path) return
	var/p = text2path("[E.path]")
	if(!p) return
	if(locate(p) in mob)
		mob << "You already know [AqNiceName(E.path)]!"
		return
	ShowAqConfirm(E)

client/proc/AqTryPick(datum/aqentry/E)
	if(!mob || !E || !E.can_pick) return
	ShowAqConfirm(E)

client/proc/AqFinalizeBuy(datum/aqentry/E)
	if(aq_buying)
		if(mob) mob << "Finish your current purchase first."
		return
	aq_buying = TRUE
	AqFinalizeBuyInner(E)
	aq_buying = FALSE

client/proc/AqFinalizeBuyInner(datum/aqentry/E)
	if(!mob || !E || !E.can_buy || !E.path) return
	var/p = text2path("[E.path]")
	if(!p) return
	var/mob/M = mob
	var/obj/Skills/s = new p
	if(s.SignatureTechnique >= 1)          // never sold here
		M << "[s] is a signature technique, it can't be bought with RPP."
		del s
		return
	if(locate(p) in M)
		M << "You've already learned [s]."
		del s
		return
	var/bypass = (M.Saga == "Weapon Soul" && s.NeedsSword)
	if((s.type in M.SkillsLocked) && !bypass)
		M << "You cannot buy [s] because it is a prerequisite to a skill that you've already upgraded!"
		del s
		return
	if(!bypass)
		for(var/lp in s.LockOut)
			var/p3 = text2path("[lp]")
			if(p3 && (locate(p3) in M))
				M << "You cannot buy [s] when you already possess [AqNiceName("[lp]")]!"
				del s
				return
	for(var/pp in s.PreRequisite)
		var/p2 = text2path("[pp]")
		if(p2 && !(locate(p2) in M))
			M << "You need to buy [AqNiceName("[pp]")] before [s]!"
			del s
			return

	if(M.SpendRPP(E.cost, "[s]", Training = 1))
		M.AddSkill(s)
		if(s.type == /obj/Skills/Power_Control)
			if(!locate(/obj/Skills/Buffs/ActiveBuffs/Ki_Control, M))
				M.PoweredFormSetup()
	else
		del s
	if(aqmenu_open)
		AqBuildEntries()
		RefreshAcquireRows()

client/proc/AqFinalizePick(datum/aqentry/E)
	if(aq_buying)
		if(mob) mob << "Finish your current purchase first."
		return
	aq_buying = TRUE
	AqFinalizePickInner(E)
	aq_buying = FALSE

client/proc/AqFinalizePickInner(datum/aqentry/E)
	if(!mob || !E || !E.can_pick) return
	var/mob/M = mob
	var/t = E.pick_tier
	if(E.kind == "combo")                     // advanced style pick
		if(M.AqStylePicksLeft(t) < 1)
			M << "You don't have a Tier [t] style pick available."
			return
		var/p = text2path("[E.path]")
		if(!p) return
		if(locate(p) in M)
			M << "You already know [E.name]."
			return
		var/obj/Skills/Buffs/NuStyle/s = new p
		var/sunlocked
		if(t >= 4)                            // T4 interim gate: any T3 style of the same category
			sunlocked = M.AqT4Ready(s) && !(s.name in M.SignatureSelected)
		else
			sunlocked = (s.name in M.SignatureStyles) && !(s.name in M.SignatureSelected)
		if(!sunlocked)
			M << "[s] isn't unlocked for picking yet."
			del s
			return
		var/missing = M.AqMissingPrereqs(s)
		if(missing)
			M << "You do not meet the requirements for [s]. You still need to learn [missing]."
			del s
			return
		M.AddSkill(s)
		var/Name = s.SignatureName ? s.SignatureName : s.name
		M.SignatureSelected.Add("[Name]")
		s.SignatureTechnique = t
		M << "<font color=#78eb78>You obtained [s]!</font>"
	else                                      // signature pick (single or bundle)
		if(M.AqSigPicksLeft(t) < 1)
			M << "You don't have a Tier [t] signature pick available."
			return
		if(E.name in M.SignatureSelected)     // a pick stays burned even if the skill was later removed
			M << "You've already used a pick on [E.name]."
			return
		if(!E.paths || !E.paths.len) return
		var/list/toadd = list()               // validate everything before granting anything
		for(var/ct in E.paths)
			var/p2 = text2path("[ct]")
			if(!p2) continue
			if(locate(p2) in M)
				M << "You've already learned [AqNiceName("[ct]")]."
				while(toadd.len)
					var/obj/Skills/junk = toadd[toadd.len]
					toadd.len--
					del junk
				return
			var/obj/Skills/s2 = new p2
			var/missing2 = M.AqMissingPrereqs(s2)
			if(missing2)
				M << "You do not meet the requirements for [s2]. You still need to learn [missing2]."
				del s2
				while(toadd.len)
					var/obj/Skills/junk = toadd[toadd.len]
					toadd.len--
					del junk
				return
			toadd += s2
		if(!toadd.len) return
		for(var/obj/Skills/s3 in toadd)
			M.AddSkill(s3)
			var/Name = s3.SignatureName ? s3.SignatureName : s3.name
			M.SignatureSelected.Add("[Name]")
			M << "<font color=#78eb78>You obtained [s3]!</font>"
	if(aqmenu_open)
		AqBuildEntries()
		RefreshAcquireRows()

client/proc/AQPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (aq_atx - 1) * 32
	var/by = (aq_aty - 1) * 32
	var/minx = -bx
	if(minx > 0) minx = 0
	var/maxx = vw * 32 - AQ_W - bx
	if(maxx < 0) maxx = 0
	var/miny = -by
	if(miny > 0) miny = 0
	var/maxy = vh * 32 - AQ_H - by
	if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/AQShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	for(var/atom/movable/o in aq_chrome)
		if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(aq_rows)
		for(var/atom/movable/o in aq_rows)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(aq_confirm_objs)
		for(var/atom/movable/o in aq_confirm_objs)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/AQPanelStart(params)
	aq_pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	aq_pan_mx = m[1]; aq_pan_my = m[2]
	aq_pan_ox = aq_pan_x; aq_pan_oy = aq_pan_y

client/proc/AQPanelMove(params)
	if(!aqmenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = AQPanBounds()
	var/wantx = clamp(aq_pan_ox + (m[1] - aq_pan_mx), b[1], b[2])
	var/wanty = clamp(aq_pan_oy + (m[2] - aq_pan_my), b[3], b[4])
	var/dx = wantx - aq_pan_x
	var/dy = wanty - aq_pan_y
	if(!dx && !dy) return
	aq_pan_x = wantx; aq_pan_y = wanty
	aq_pan_dragged = TRUE
	AQShiftLive(dx, dy)

client/proc/AQPanelEnd()
	if(!aq_pan_dragged) return
	aq_pan_dragged = FALSE
	RefreshAcquireRows()          // re-sync rows/thumb to the baked pan
	setPref("aqPanX", aq_pan_x)
	setPref("aqPanY", aq_pan_y)