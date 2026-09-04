#define AR_W 576
#define AR_H 421
#define AR_FLIP_H 477
#define AR_FLIP_H_SHORT 448
#define AR_FOOT_W 588
#define AR_LAYER (FLY_LAYER + 3.75)
#define AR_FONT "font-family:'Fantasypixelfont'; font-size:12pt"
#define AR_INK "#3c1e0a"
#define AR_INK_SOFT "#6e5032"
#define AR_INK_RED "#96281e"
#define AR_INK_GREEN "#287828"
#define AR_INK_GOLD "#b06e28"
#define AR_LX 40
#define AR_LY 19
#define AR_RX 302
#define AR_RY 20
#define AR_PW 234
#define AR_PB 366
#define AR_LINE 18
#define AR_ROW_H 36
#define AR_ROWS_LEFT 7
#define AR_ROWS_PER_SPREAD 15
#define AR_ROW_X 41
#define AR_TAB_Y0 28
#define AR_TAB_STEP 40
#define AR_FLIP_STEP 1.4

var/list/AR_CHAPTERS = list("Spells", "Path", "Acquire", "Craft", "Learn")
var/list/AR_TAB_DEPTHS = list(549, 556, 552, 554, 549)
var/list/AR_FRAMES
var/AR_FONT_RESOURCE = '_Reworks/Arcane/Icons/book/Fantasypixelfont.ttf'

proc/ArcaneFrameFile(i)
	switch(i)
		if(2) return '_Reworks/Arcane/Icons/book/InventoryBook_02.png'
		if(3) return '_Reworks/Arcane/Icons/book/InventoryBook_03.png'
		if(4) return '_Reworks/Arcane/Icons/book/InventoryBook_04.png'
	return '_Reworks/Arcane/Icons/book/InventoryBook_01.png'

proc/ArcaneFrame(i, h)
	if(i == 1) h = AR_H
	if(!AR_FRAMES) AR_FRAMES = list()
	var/key = "[i]x[h]"
	if(!AR_FRAMES[key])
		var/icon/I = icon(ArcaneFrameFile(i))
		I.Crop(1, 1, AR_W, h)
		AR_FRAMES[key] = I
	return AR_FRAMES[key]

proc/ArcaneTabGlyph(chapter)
	switch(chapter)
		if("Spells") return '_Reworks/Arcane/Icons/book/F_UI_Skill03.png'
		if("Path") return '_Reworks/Arcane/Icons/book/F_UI_Skill08.png'
		if("Acquire") return '_Reworks/Arcane/Icons/book/F_UI_Skill38.png'
		if("Craft") return '_Reworks/Arcane/Icons/book/F_UI_Skill34.png'
	return '_Reworks/Arcane/Icons/book/F_UI_Skill49.png'

client/var/tmp
	armenu_open = 0
	ar_chapter = "Spells"
	ar_spread = 1
	ar_spreads = 1
	ar_atx = 1
	ar_aty = 1
	ar_pan_x = 0
	ar_pan_y = 0
	ar_pan_mx = 0
	ar_pan_my = 0
	ar_pan_ox = 0
	ar_pan_oy = 0
	ar_pan_dragged = FALSE
	ar_flipping = FALSE
	ar_open_seq = 0
	ar_drag_ghost = FALSE
	ar_pick
	ar_marker_dy = 0
	ar_flip_h = 448
	atom/movable/shud/arframe/ar_frame
	list/ar_objs
	list/ar_tabs
	list/ar_rows
	list/ar_page_objs
	atom/movable/shud/artext/ar_pick_label
	atom/movable/shud/arpic/ar_marker
	atom/movable/shud/menubtn/btn_arcane
	atom/movable/shud/menulabel/btn_arcane_label

/atom/movable/shud/arframe
	layer = AR_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr && usr.client) usr.client.ARPanStart(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr && usr.client) usr.client.ARPanMove(params)
	MouseUp(location, control, params)
		if(usr && usr.client) usr.client.ARPanEnd()
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.CloseArcaneMenu()
			return
		if(usr.client.ar_pan_dragged) return
		var/list/pl = params2list(params)
		var/ix = text2num(pl["icon-x"])
		if(isnull(ix)) return
		usr.client.ArcanePageFlip(ix < 288 ? -1 : 1)

/atom/movable/shud/artext
	layer = AR_LAYER + 0.3
	mouse_opacity = 0
	maptext_height = 16

/atom/movable/shud/arpic
	layer = AR_LAYER + 0.25
	mouse_opacity = 0

/atom/movable/shud/artab
	layer = AR_LAYER + 0.5
	mouse_opacity = 2
	var/chapter
	var/atom/movable/shud/arglyph/glyph
	New()
		..()
		glyph = new
		glyph.pixel_x = 5
		glyph.pixel_y = 6
		vis_contents += glyph
	Del()
		if(glyph)
			vis_contents -= glyph
			del glyph
		..()
	MouseUp(location, control, params)
		if(usr && usr.client) usr.client.ARPanEnd()
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.CloseArcaneMenu()
			return
		usr.client.ArcaneChapter(chapter)

/atom/movable/shud/arglyph
	layer = AR_LAYER + 0.55
	mouse_opacity = 0

/atom/movable/shud/arbtn
	layer = AR_LAYER + 0.4
	mouse_opacity = 2
	var/action
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#e0b060")
	MouseExited(location, control, params)
		filters = null
	MouseUp(location, control, params)
		if(usr && usr.client) usr.client.ARPanEnd()
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		usr.client.ArcaneAction(action)

/atom/movable/shud/arelbtn
	layer = AR_LAYER + 0.4
	mouse_opacity = 2
	var/element
	MouseEntered(location, control, params)
		if(usr && usr.client) usr.client.ArcaneHoverElement(element)
	MouseExited(location, control, params)
		if(usr && usr.client) usr.client.ArcaneHoverElement(null)
	MouseUp(location, control, params)
		if(usr && usr.client) usr.client.ARPanEnd()
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		usr.client.ArcaneAction("pick:[element]")

/atom/movable/shud/arrow
	layer = AR_LAYER + 0.35
	mouse_opacity = 0
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/Skills/skill
	var/side = 1
	var/atom/movable/shud/artext/nametext
	var/atom/movable/shud/artext/righttext
	New()
		..()
		nametext = new
		nametext.maptext_x = 40
		nametext.maptext_y = 7
		nametext.maptext_width = 108
		vis_contents += nametext
		righttext = new
		righttext.maptext_x = 148
		righttext.maptext_y = 7
		righttext.maptext_width = 84
		vis_contents += righttext
	Del()
		for(var/atom/movable/c in list(nametext, righttext))
			if(c)
				vis_contents -= c
				del c
		..()
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			if(!skill)
				usr.client.CloseArcaneMenu()
			else if(usr.client.skinfo_skill == skill)
				usr.client.CloseSkillInfo()
			else if(istype(skill, /obj/Skills/Buffs))
				usr.client.ShowBuffInfo(skill)
			else
				usr.client.ShowSkillInfo(skill)
			return
		if(usr.client.ar_pan_dragged) return
		usr.client.ArcanePageFlip(side)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr && usr.client && skill) usr.client.ArcaneDragGhost(TRUE)
	MouseUp(location, control, params)
		if(usr && usr.client)
			usr.client.ArcaneDragGhost(FALSE)
			usr.client.ARPanEnd()
	MouseDrop(atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
		if(usr && usr.client) usr.client.ArcaneDragGhost(FALSE)
		if(!usr || !skill) return
		if(!istype(over_object, /atom/movable/shud/slot)) return
		usr.initShortcuts()
		var/atom/movable/shud/slot/tgt = over_object
		for(var/i = 1 to HOTBAR_SLOTS)
			if(usr.shortcuts.vars["shortcut[i]"] == skill)
				usr.shortcuts.vars["shortcut[i]"] = null
		var/obj/Skills/B = usr.shortcuts.vars["shortcut[tgt.slot_index]"]
		if(B && (B.Using || B.cooldown_remaining))
			usr << "<font color='#ff6b6b'>[B.name] is on cooldown.</font>"
			return
		usr.shortcuts.vars["shortcut[tgt.slot_index]"] = skill
		usr.client?.RefreshHotbar()

mob/proc/GetSpellPages()
	var/list/out = list()
	for(var/obj/Skills/S in Skills)
		if(!S.IsSpell || !S.PageKey) continue
		var/rank = ELEMENT_LIST.Find(S.SpellElement)
		if(!rank) rank = ELEMENT_LIST.len + 1
		var/key = rank * 100 + clamp(S.SpellTier, 0, 9) * 10
		var/pos = out.len + 1
		for(var/i = 1 to out.len)
			var/obj/Skills/O = out[i]
			var/orank = ELEMENT_LIST.Find(O.SpellElement)
			if(!orank) orank = ELEMENT_LIST.len + 1
			var/okey = orank * 100 + clamp(O.SpellTier, 0, 9) * 10
			if(key < okey || (key == okey && sorttext(S.name, O.name) > 0))
				pos = i
				break
		out.Insert(pos, S)
	return out

client/proc/ARloc(dx, dyTop, h = 0)
	var/py = AR_H - dyTop - h
	var/ax = dx + ar_pan_x
	var/ay = py + ar_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[ar_atx + (ax - axp) / 32]:[axp],[ar_aty + (ay - ayp) / 32]:[ayp]"

client/proc/InitArcaneButton()
	btn_arcane = new('HUD/ui_icon_skills.png')
	btn_arcane.btn_id = "arcane"
	btn_arcane.screen_loc = "EAST:-4,NORTH:-356"
	shud_parts += btn_arcane
	btn_arcane_label = new
	btn_arcane_label.maptext_width = 48
	btn_arcane_label.SetText("Arcane")
	btn_arcane_label.pixel_x = -54
	btn_arcane_label.pixel_y = 8
	btn_arcane.label = btn_arcane_label
	btn_arcane.vis_contents += btn_arcane_label

client/proc/ResetArcaneHUD()
	CloseArcaneAcquire(0)
	CloseArcaneMenu()
	btn_arcane = null
	btn_arcane_label = null

client/proc/ToggleArcaneMenu()
	if(armenu_open) CloseArcaneMenu()
	else OpenArcaneMenu()

client/proc/ARPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/lx = (ar_atx - 1) * 32
	var/by = (ar_aty - 1) * 32
	var/minx = -lx
	var/maxx = vw * 32 - AR_FOOT_W - lx
	var/miny = -by
	var/maxy = vh * 32 - ar_flip_h - by
	if(maxx < minx)
		var/tx = minx
		minx = maxx
		maxx = tx
	if(maxy < miny)
		var/ty = miny
		miny = maxy
		maxy = ty
	return list(minx, maxx, miny, maxy)

client/proc/OpenArcaneMenu()
	if(armenu_open || !mob) return
	CloseMenu()
	CloseInventory()
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	CloseLifeSkillsMenu()
	CloseStationMenu()
	CloseArcaneAcquire(0)
	armenu_open = 1
	ar_open_seq++
	ar_flipping = FALSE
	ar_drag_ghost = FALSE
	ar_pick = null
	ar_spread = 1
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(AR_FOOT_W / 32)
	if(mtw * 32 < AR_FOOT_W) mtw++
	var/mth = round(AR_H / 32)
	if(mth * 32 < AR_H) mth++
	ar_atx = max(1, round((vw - mtw) / 2) + 1)
	ar_aty = max(1, round((vh - mth) / 2) + 1)
	ar_aty = max(ar_aty, min(4, vh - mth + 1))
	ar_flip_h = ((vh - ar_aty + 1) * 32 >= AR_FLIP_H) ? AR_FLIP_H : AR_FLIP_H_SHORT
	ar_pan_x = getPref("arPanX")
	if(isnull(ar_pan_x)) ar_pan_x = 0
	ar_pan_y = getPref("arPanY")
	if(isnull(ar_pan_y)) ar_pan_y = 0
	var/list/b = ARPanBounds()
	ar_pan_x = clamp(ar_pan_x, b[1], b[2])
	ar_pan_y = clamp(ar_pan_y, b[3], b[4])
	var/ch = getPref("arChapter")
	ar_chapter = (ch in AR_CHAPTERS) ? ch : "Spells"
	if(ar_chapter == "Acquire" && mob.IsMage()) ar_chapter = "Spells"
	if(btn_arcane)
		btn_arcane.icon = 'HUD/ui_slot_unavailable.png'
		btn_arcane.SetGlyphDimmed(TRUE)
	if(btn_arcane_label) btn_arcane_label.alpha = 0
	BuildArcaneBook()
	var/list/all = ar_objs.Copy()
	all += ar_tabs
	KineticEntrance(all)

client/proc/CloseArcaneMenu()
	if(!armenu_open && !ar_objs) return
	armenu_open = 0
	ar_flipping = FALSE
	ar_drag_ghost = FALSE
	CloseSkillInfo()
	ClearList(ar_page_objs)
	ar_page_objs = null
	ClearList(ar_rows)
	ar_rows = null
	ClearList(ar_tabs)
	ar_tabs = null
	ClearList(ar_objs)
	ar_objs = null
	ar_frame = null
	ar_pick_label = null
	ar_marker = null
	if(btn_arcane)
		btn_arcane.icon = 'HUD/ui_slot_available.png'
		btn_arcane.SetGlyphDimmed(FALSE)

client/proc/ArcaneLiveObjs()
	var/list/all = list()
	if(ar_objs) all += ar_objs
	if(ar_tabs) all += ar_tabs
	if(ar_rows) all += ar_rows
	if(ar_page_objs) all += ar_page_objs
	return all

client/proc/ArcaneShiftLive(dpx, dpy)
	ShiftScreenLocs(ArcaneLiveObjs(), dpx, dpy)

client/proc/ARPanStart(params)
	ar_pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	ar_pan_mx = m[1]
	ar_pan_my = m[2]
	ar_pan_ox = ar_pan_x
	ar_pan_oy = ar_pan_y

client/proc/ARPanMove(params)
	if(!armenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = ARPanBounds()
	var/wantx = clamp(ar_pan_ox + (m[1] - ar_pan_mx), b[1], b[2])
	var/wanty = clamp(ar_pan_oy + (m[2] - ar_pan_my), b[3], b[4])
	var/dx = wantx - ar_pan_x
	var/dy = wanty - ar_pan_y
	if(!dx && !dy) return
	ar_pan_x = wantx
	ar_pan_y = wanty
	ar_pan_dragged = TRUE
	ArcaneShiftLive(dx, dy)

client/proc/ARPanEnd()
	ArcaneDragGhost(FALSE)
	if(!ar_pan_dragged) return
	setPref("arPanX", ar_pan_x)
	setPref("arPanY", ar_pan_y)
	spawn(1) ar_pan_dragged = FALSE

client/proc/ArLine(txt, dx, dyTop, w = AR_PW, color = AR_INK)
	var/atom/movable/shud/artext/t = new
	t.maptext_width = w
	t.maptext_height = 16
	t.screen_loc = ARloc(dx, dyTop, 16)
	t.maptext = "<center><span style=\"[AR_FONT]; color:[color]\">[txt]</span></center>"
	ar_page_objs += t
	screen += t
	return t

client/proc/ArPic(file, dx, dyTop, h)
	var/atom/movable/shud/arpic/p = new
	p.icon = file
	p.screen_loc = ARloc(dx, dyTop, h)
	ar_page_objs += p
	screen += p
	return p

client/proc/ArPlate(txt, boxX, dyTop)
	var/wide = (length(txt) > 17)
	var/pw = wide ? 147 : 131
	var/ph = wide ? 26 : 24
	var/px = boxX + round((AR_PW - pw) / 2)
	ArPic(wide ? '_Reworks/Arcane/Icons/book/TitleA_03.png' : '_Reworks/Arcane/Icons/book/TitleA_01.png', px, dyTop, ph)
	var/atom/movable/shud/artext/t = new
	t.maptext_width = pw
	t.maptext_height = 16
	t.screen_loc = ARloc(px, dyTop + round((ph - 16) / 2) + 1, 16)
	t.maptext = "<center><span style=\"[AR_FONT]; color:[AR_INK]\">[txt]</span></center>"
	ar_page_objs += t
	screen += t
	return dyTop + ph + 8

client/proc/ArBtn(action, label, boxX, dyTop, primary = 1)
	var/bw = primary ? 122 : 110
	var/bh = primary ? 26 : 34
	var/bx = boxX + round((AR_PW - bw) / 2)
	var/atom/movable/shud/arbtn/b = new
	b.icon = primary ? '_Reworks/Arcane/Icons/book/GoldBtnA_02.png' : '_Reworks/Arcane/Icons/book/GoldBtnD_02.png'
	b.action = action
	b.screen_loc = ARloc(bx, dyTop, bh)
	ar_page_objs += b
	screen += b
	var/atom/movable/shud/artext/t = new
	t.layer = AR_LAYER + 0.45
	t.maptext_width = bw
	t.maptext_height = 16
	t.screen_loc = ARloc(bx, dyTop + round((bh - 16) / 2) + 1, 16)
	t.maptext = "<center><span style=\"[AR_FONT]; color:[AR_INK]\">[label]</span></center>"
	ar_page_objs += t
	screen += t
	return b

client/proc/BuildArcaneBook()
	ar_objs = list()
	ar_tabs = list()
	ar_rows = list()
	ar_page_objs = list()
	ar_frame = new
	ar_frame.icon = ArcaneFrame(1, AR_H)
	ar_frame.screen_loc = ARloc(0, 0, AR_H)
	ar_objs += ar_frame
	screen += ar_frame
	var/i = 0
	for(var/ch in AR_CHAPTERS)
		i++
		var/atom/movable/shud/artab/t = new
		t.chapter = ch
		t.glyph.icon = ArcaneTabGlyph(ch)
		t.screen_loc = ARloc(AR_TAB_DEPTHS[i], AR_TAB_Y0 + (i - 1) * AR_TAB_STEP, 32)
		ar_tabs += t
		screen += t
	for(var/k = 1 to AR_ROWS_PER_SPREAD)
		var/atom/movable/shud/arrow/r = new
		r.alpha = 0
		r.mouse_opacity = 0
		r.side = (k <= AR_ROWS_LEFT) ? -1 : 1
		if(k <= AR_ROWS_LEFT)
			r.screen_loc = ARloc(AR_ROW_X, 55 + (k - 1) * AR_ROW_H, 32)
		else
			r.screen_loc = ARloc(AR_RX + 1, AR_RY + 40 + (k - AR_ROWS_LEFT - 1) * AR_ROW_H, 32)
		ar_rows += r
		screen += r
	RefreshArcaneTabLook()
	BuildArcaneChapter()

client/proc/RefreshArcaneTabLook()
	if(!ar_tabs) return
	for(var/atom/movable/shud/artab/t in ar_tabs)
		var/active = (t.chapter == ar_chapter)
		t.icon = active ? '_Reworks/Arcane/Icons/book/InventoryChapter_On.png' : '_Reworks/Arcane/Icons/book/InventoryChapter_Off.png'
		if(t.glyph) t.glyph.color = active ? null : "#999999"

client/proc/ArcaneChapter(chapter)
	if(!armenu_open || ar_flipping) return
	if(!(chapter in AR_CHAPTERS)) return
	if(chapter == "Acquire" && mob && mob.IsMage())
		OpenArcaneAcquire(mob.MageElement)
		return
	if(chapter == ar_chapter) return
	var/dir = (AR_CHAPTERS.Find(chapter) > AR_CHAPTERS.Find(ar_chapter)) ? 1 : -1
	ar_chapter = chapter
	ar_spread = 1
	ar_pick = null
	setPref("arChapter", chapter)
	RefreshArcaneTabLook()
	ArcaneFlip(dir)

client/proc/ArcanePageFlip(dir)
	if(!armenu_open || ar_flipping) return
	if(ar_spreads <= 1) return
	var/np = clamp(ar_spread + dir, 1, ar_spreads)
	if(np == ar_spread) return
	ar_spread = np
	ArcaneFlip(dir)

client/proc/ArcaneFlip(dir)
	set waitfor = 0
	if(ar_flipping || !ar_frame) return
	var/seq_id = ar_open_seq
	ar_flipping = TRUE
	CloseSkillInfo()
	ClearList(ar_page_objs)
	ar_page_objs = list()
	ar_pick_label = null
	ar_marker = null
	ArcaneHideRows()
	var/list/seq = (dir < 0) ? list(4, 3, 2) : list(2, 3, 4)
	for(var/f in seq)
		if(!armenu_open || !ar_frame || ar_open_seq != seq_id) return
		ar_frame.icon = ArcaneFrame(f, ar_flip_h)
		sleep(AR_FLIP_STEP)
	if(!armenu_open || !ar_frame || ar_open_seq != seq_id) return
	ar_frame.icon = ArcaneFrame(1, AR_H)
	ar_flipping = FALSE
	BuildArcaneChapter()

client/proc/ArcaneHideRows()
	if(!ar_rows) return
	for(var/atom/movable/shud/arrow/r in ar_rows)
		r.skill = null
		r.icon = null
		r.alpha = 0
		r.mouse_opacity = 0
		r.nametext.maptext = ""
		r.righttext.maptext = ""

client/proc/BuildArcaneChapter()
	if(!armenu_open || !mob) return
	ClearList(ar_page_objs)
	ar_page_objs = list()
	ar_pick_label = null
	ar_marker = null
	ArcaneHideRows()
	ar_spreads = 1
	switch(ar_chapter)
		if("Spells")
			BuildArcaneSpells()
		if("Path")
			BuildArcanePath()
		if("Acquire")
			ArLine("Walk the Path first.", AR_LX, AR_LY + 10, AR_PW, AR_INK_SOFT)
			ArLine("A mage's pages await here.", AR_LX, AR_LY + 10 + AR_LINE, AR_PW, AR_INK_SOFT)
		else
			ArLine("This chapter is not yet written.", AR_LX, AR_LY + 10, AR_PW, AR_INK_SOFT)
	var/list/fade = ar_page_objs.Copy()
	if(ar_rows)
		for(var/atom/movable/shud/arrow/r in ar_rows)
			if(r.skill) fade += r
	KineticEntrance(fade)

client/proc/BuildArcaneSpells()
	var/list/L = mob.GetSpellPages()
	ar_spreads = max(1, -round(-L.len / AR_ROWS_PER_SPREAD))
	ar_spread = clamp(ar_spread, 1, ar_spreads)
	ArPlate("Pages", AR_LX, AR_LY + 4)
	if(!L.len)
		ArLine("No pages yet.", AR_LX, AR_LY + 44, AR_PW, AR_INK_SOFT)
		if(!mob.IsMage())
			ArLine("The Path chapter awaits.", AR_LX, AR_LY + 44 + AR_LINE, AR_PW, AR_INK_SOFT)
	else
		var/start = (ar_spread - 1) * AR_ROWS_PER_SPREAD
		for(var/k = 1 to AR_ROWS_PER_SPREAD)
			var/idx = start + k
			if(idx > L.len) break
			var/obj/Skills/S = L[idx]
			var/atom/movable/shud/arrow/r = ar_rows[k]
			r.skill = S
			r.icon = SkillMenuIcon(S)
			r.icon_state = SkillMenuIconState(S)
			r.nametext.maptext = "<span style=\"[AR_FONT]; color:[AR_INK]\">[S.name]</span>"
			r.righttext.maptext = "<span style=\"[AR_FONT]; color:[AR_INK_GOLD]; text-align:right\">[S.SpellElement] T[S.SpellTier]</span>"
			r.alpha = 255
			r.mouse_opacity = 2
		if(ar_spreads > 1)
			ArLine("[ar_spread] / [ar_spreads]", AR_RX, AR_PB - 20, AR_PW, AR_INK_SOFT)
	if(mob.IsMage())
		ArBtn("grimoire", "Tome", AR_LX, AR_PB - 34, 0)

client/proc/BuildArcanePath()
	var/y = ArPlate("The Mage's Path", AR_LX, AR_LY + 4)
	if(mob.IsMage())
		ArLine("Mage Tier [mob.SagaLevel]", AR_LX, y)
		y += AR_LINE
		ArLine(jointext(mob.MageElements(), " and "), AR_LX, y, AR_PW, AR_INK_GOLD)
		y += AR_LINE + 6
		var/gate = mob.MageNextGate()
		if(isnull(gate))
			ArLine("The Arcane Stage is yours.", AR_LX, y, AR_PW, AR_INK_GREEN)
		else
			ArLine("Next: [gate] Potential, [mob.MageNextFee()] RPP", AR_LX, y, AR_PW, mob.Potential >= gate ? AR_INK_GREEN : AR_INK_RED)
		y += AR_LINE + 6
		var/cap = round((mob.ManaMax - mob.TotalCapacity) * mob.GetManaCapMult() + mob.MageManaBonus())
		ArLine("Mana [round(mob.ManaAmount)] / [cap]", AR_LX, y)
		if(!isnull(gate))
			ArBtn("tierup", "Tier Up", AR_LX, AR_PB - 34, 1)
	else
		var/why = mob.CanBecomeMage()
		if(why)
			for(var/line in WrapDescLines(why, 26))
				ArLine(line, AR_LX, y, AR_PW, AR_INK_RED)
				y += AR_LINE
		else
			ArLine("Take up the path of the Mage?", AR_LX, y)
			y += AR_LINE
			ArLine("It bars every Saga and all", AR_LX, y, AR_PW, AR_INK_RED)
			y += AR_LINE
			ArLine("Signature techniques. Forever.", AR_LX, y, AR_PW, AR_INK_RED)
			y += AR_LINE + 10
			ArLine("Choose your element", AR_LX, y)
			y += AR_LINE + 4
			var/x0 = AR_LX + round((AR_PW - 222) / 2)
			var/i = 0
			for(var/e in ELEMENT_PHYSICAL)
				var/atom/movable/shud/arelbtn/b = new
				b.element = e
				b.icon = MageElementIcon(e)
				if(!MageElementHasArt(e)) b.color = FxElementColor(e)
				b.screen_loc = ARloc(x0 + i * 38, y, 32)
				ar_page_objs += b
				screen += b
				i++
			ar_marker_dy = y + 34
			ar_marker = ArPic('_Reworks/Arcane/Icons/book/F_U_Detail3.png', x0 + 7, ar_marker_dy, 19)
			ar_marker.alpha = 0
			ar_pick_label = ArLine("", AR_LX, y + 34 + 22, AR_PW, AR_INK_GOLD)
			ArcaneRefreshPick()
			ArBtn("become", "Begin", AR_LX, AR_PB - 34, 1)
	y = ArPlate("The Seven Tiers", AR_RX, AR_RY + 4)
	var/list/what = list("Grimoire and first pages", "Tier 2 pages, Mana Skin", "Tier 3 pages", "The fork", "Tier 4 pages", "The pinnacle page", "The Arcane Stage")
	for(var/lvl = 1 to glob.MAGE_MAX_LEVEL)
		var/col = (mob.IsMage() && mob.SagaLevel == lvl) ? AR_INK_GOLD : AR_INK
		ArLine("Tier [lvl]&nbsp;&nbsp;&nbsp;[glob.MAGE_POT_GATES[lvl]] Pot&nbsp;&nbsp;&nbsp;[glob.MAGE_TIER_FEES[lvl]] RPP", AR_RX, y, AR_PW, col)
		y += AR_LINE
		ArLine(what[lvl], AR_RX, y, AR_PW, AR_INK_SOFT)
		y += AR_LINE + 2

client/proc/ArcaneRefreshPick()
	if(!ar_page_objs) return
	if(ar_marker)
		var/slot = ELEMENT_PHYSICAL.Find(ar_pick)
		if(slot)
			var/x0 = AR_LX + round((AR_PW - 222) / 2)
			ar_marker.screen_loc = ARloc(x0 + (slot - 1) * 38 + 7, ar_marker_dy, 19)
			ar_marker.alpha = 255
		else
			ar_marker.alpha = 0
	if(ar_pick_label)
		ar_pick_label.maptext = ar_pick ? "<center><span style=\"[AR_FONT]; color:[AR_INK_GOLD]\">[ar_pick]</span></center>" : ""

client/proc/ArcaneHoverElement(e)
	if(!ar_pick_label) return
	if(e)
		ar_pick_label.maptext = "<center><span style=\"[AR_FONT]; color:[AR_INK_GOLD]\">[e]</span></center>"
	else
		ArcaneRefreshPick()

client/proc/ArcaneDragGhost(on)
	if(!armenu_open) return
	if(on == ar_drag_ghost) return
	ar_drag_ghost = on
	if(ar_frame) ar_frame.mouse_opacity = on ? 0 : 2
	if(ar_tabs)
		for(var/atom/movable/shud/artab/t in ar_tabs)
			t.mouse_opacity = on ? 0 : 2
	if(ar_rows)
		for(var/atom/movable/shud/arrow/r in ar_rows)
			if(r.skill) r.mouse_opacity = on ? 0 : 2
	if(ar_page_objs)
		for(var/atom/movable/shud/arbtn/b in ar_page_objs)
			b.mouse_opacity = on ? 0 : 2

client/MouseUp(object, location, control, params)
	if(ar_drag_ghost) ArcaneDragGhost(FALSE)
	..()

client/MouseDown(object, location, control, params)
	if(ar_drag_ghost) ArcaneDragGhost(FALSE)
	..()

client/proc/ArcaneAction(action)
	if(!armenu_open || !mob || ar_flipping) return
	if(copytext(action, 1, 6) == "pick:")
		ar_pick = copytext(action, 6)
		ArcaneRefreshPick()
		return
	switch(action)
		if("become")
			if(!ar_pick)
				mob << "<font color=#ff6464>Choose an element first.</font>"
				return
			var/e = ar_pick
			spawn()
				if(mob && mob.BecomeMage(e) && armenu_open)
					BuildArcaneChapter()
		if("tierup")
			spawn()
				if(mob && mob.MageTierUp() && armenu_open)
					BuildArcaneChapter()
		if("grimoire")
			var/obj/Skills/Buffs/SlotlessBuffs/MageGrimoire/G = locate() in mob
			if(!G) return
			spawn()
				G.Trigger(mob)
				if(armenu_open) BuildArcaneChapter()
