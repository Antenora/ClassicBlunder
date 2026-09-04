#define AC_W 624
#define AC_H 416
#define AC_BORDER 12
#define AC_VW 600
#define AC_VH 392
#define AC_STEP 16
#define AC_CANVAS_H 664
#define AC_LAYER (FLY_LAYER + 3.78)
#define AC_FONT "font-family:'Fantasypixelfont'; font-size:12pt"
#define AC_INK "#3c1e0a"
#define AC_CREAM "#f0dcaa"
#define AC_SOFT "#c8af82"
#define AC_GOLD "#ffd17d"
#define AC_GREEN "#78eb78"
#define AC_RED "#ff6464"
#define AC_TIP_W 196
#define AC_TIP_H 88
#define AC_CONF_W 280
#define AC_CONF_H 120

var/list/AC_CROPS

proc/ArcaneCanvasCrop(element, scroll)
	if(!AC_CROPS) AC_CROPS = list()
	var/key = "[element]#[scroll]"
	if(!AC_CROPS[key])
		var/f = ArcaneTreeFile(element)
		if(!f) return null
		var/icon/I = icon(f)
		I.Crop(1, 664 - (scroll + AC_VH) + 1, AC_VW, 664 - scroll)
		AC_CROPS[key] = I
	return AC_CROPS[key]

var/list/AC_NODE_CROPS

proc/ArcaneNodeCrop(file, cut_top, cut_bot)
	if(!cut_top && !cut_bot) return file
	if(!AC_NODE_CROPS) AC_NODE_CROPS = list()
	var/key = "[file]#[cut_top]#[cut_bot]"
	if(!AC_NODE_CROPS[key])
		var/icon/I = icon(file)
		I.Crop(1, 1 + cut_bot, 32, 32 - cut_top)
		AC_NODE_CROPS[key] = I
	return AC_NODE_CROPS[key]

client/var/tmp
	acmenu_open = 0
	ac_element
	ac_scroll = 0
	ac_atx = 1
	ac_aty = 1
	ac_drag_my = 0
	ac_drag_s0 = 0
	ac_dragging = FALSE
	ac_pan_dragged = FALSE
	ac_pan_x = 0
	ac_pan_y = 0
	ac_win_mx = 0
	ac_win_my = 0
	ac_win_ox = 0
	ac_win_oy = 0
	ac_win_dragging = FALSE
	ac_win_dragged = FALSE
	ac_confirm_key
	list/ac_objs
	list/ac_nodes
	list/ac_tip_objs
	list/ac_confirm_objs
	atom/movable/shud/accanvas/ac_canvas
	atom/movable/shud/actext/ac_rpp
	atom/movable/shud/actext/ac_pages

/atom/movable/shud/acframe
	layer = AC_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseEntered(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorHover(src, "draggable")
	MouseExited(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorLeave(src)
	MouseDown(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		CursorGrabDown(src)
		usr.client.ACWinStart(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr && usr.client) usr.client.ACWinMove(params)
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.CloseArcaneAcquire(1)

/atom/movable/shud/acgrip
	layer = AC_LAYER + 0.45
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseEntered(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorHover(src, "draggable")
	MouseExited(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorLeave(src)
	MouseDown(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		CursorGrabDown(src)
		usr.client.ACWinStart(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr && usr.client) usr.client.ACWinMove(params)

/atom/movable/shud/accanvas
	layer = AC_LAYER + 0.1
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseEntered(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorHover(src, "draggable")
	MouseExited(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorLeave(src)
	MouseDown(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		if(usr.client.ac_confirm_objs) return
		CursorGrabDown(src)
		usr.client.ACPanStart(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr && usr.client) usr.client.ACPanMove(params)
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.CloseArcaneAcquire(1)
			return
		usr.client.HideAcquireTip()

/atom/movable/shud/acnode
	layer = AC_LAYER + 0.3
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	var/node_key
	var/state = "locked"
	proc/CursorKey()
		switch(state)
			if("buy") return "scroll"
			if("owned") return "draggable"
		return "blocked"
	MouseEntered(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorHover(src, CursorKey())
		usr.client.ShowAcquireTip(node_key)
	MouseExited(location, control, params)
		if(!usr || !usr.client || usr.client.ac_dragging || usr.client.ac_win_dragging) return
		CursorLeave(src)
		usr.client.HideAcquireTip()
	MouseDown(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		if(usr.client.ac_confirm_objs) return
		CursorGrabDown(src)
		usr.client.ACPanStart(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr && usr.client) usr.client.ACPanMove(params)
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		usr.client.AcquireNodeClick(node_key)

/atom/movable/shud/actext
	layer = AC_LAYER + 0.5
	mouse_opacity = 0
	maptext_height = 16

/atom/movable/shud/acpic
	layer = AC_LAYER + 0.45
	mouse_opacity = 0

/atom/movable/shud/acconfirmbg
	layer = AC_LAYER + 0.8
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		return
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		return
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.HideAcquireConfirm()

/atom/movable/shud/acbtn
	layer = AC_LAYER + 0.6
	mouse_opacity = 2
	var/action
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#e0b060")
	MouseExited(location, control, params)
		filters = null
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1")) return
		usr.client.AcquireAction(action)

/atom/movable/shud/acbtntext
	layer = AC_LAYER + 0.65
	mouse_opacity = 0
	maptext_height = 16

mob/proc/ArcaneOwnedCount(element)
	var/n = 0
	for(var/obj/Skills/S in Skills)
		if(S.IsSpell && S.PageKey && S.SpellElement == element) n++
	return n

mob/proc/ArcaneOwnsNode(element, key)
	var/p = ArcanePagePath(element, key)
	if(!p) return 0
	return (locate(p) in src) ? 1 : 0

mob/proc/ArcaneNodeReason(element, key)
	var/list/nodes = ArcaneTreeNodes(element)
	if(!nodes || !nodes[key]) return "Unknown page."
	var/list/N = nodes[key]
	var/tier = N[3]
	if(!ArcanePagePath(element, key)) return "This page is not yet written."
	if(!IsMage()) return "Walk the Path first."
	if(!MageOwnsElement(element)) return "You do not command [element]."
	var/need = glob.MAGE_PAGE_LEVEL[tier]
	if(SagaLevel < need) return "Opens at Mage Tier [need]."
	if(tier >= 5 && IsAdvancedElement(element) && !MageLockedIn) return "The pinnacle needs the lock-in."
	var/invest = glob.MAGE_TIER_INVEST[tier]
	var/owned = ArcaneOwnedCount(element)
	if(owned < invest) return "Needs [invest] [element] pages learned."
	if(key != "ENTRY" && copytext(key, 1, 7) != "SHELF_")
		var/linked = 0
		for(var/nk in ArcaneNodeNeighbours(element, key))
			if(ArcaneOwnsNode(element, nk))
				linked = 1
				break
		if(!linked) return "Learn a linked page first."
	return null

client/proc/ACloc(dx, dyTop, h = 0)
	var/py = AC_H - dyTop - h
	var/ax = dx + ac_pan_x
	var/ay = py + ac_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[ac_atx + (ax - axp) / 32]:[axp],[ac_aty + (ay - ayp) / 32]:[ayp]"

client/proc/ACPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/lx = (ac_atx - 1) * 32
	var/by = (ac_aty - 1) * 32
	var/minx = -lx
	var/maxx = vw * 32 - AC_W - lx
	var/miny = -by
	var/maxy = vh * 32 - AC_H - by
	if(maxx < minx)
		var/tx = minx
		minx = maxx
		maxx = tx
	if(maxy < miny)
		var/ty = miny
		miny = maxy
		maxy = ty
	return list(minx, maxx, miny, maxy)

client/proc/ShiftScreenLocs(list/L, dpx, dpy)
	if(!L || (!dpx && !dpy)) return
	for(var/atom/movable/o in L)
		var/sl = o.screen_loc
		if(!sl) continue
		var/list/cm = splittext(sl, ",")
		if(cm.len < 2) continue
		var/list/xp = splittext(cm[1], ":")
		var/list/yp = splittext(cm[2], ":")
		if(xp.len < 2 || yp.len < 2) continue
		var/xt = text2num(xp[1])
		var/yt = text2num(yp[1])
		if(isnull(xt) || isnull(yt)) continue
		var/ax = (xt - 1) * 32 + text2num(xp[2]) + dpx
		var/ay = (yt - 1) * 32 + text2num(yp[2]) + dpy
		var/axp = ((ax % 32) + 32) % 32
		var/ayp = ((ay % 32) + 32) % 32
		o.screen_loc = "[(ax - axp) / 32 + 1]:[axp],[(ay - ayp) / 32 + 1]:[ayp]"

client/proc/AcquireLiveObjs()
	var/list/all = list()
	if(ac_objs) all += ac_objs
	if(ac_nodes) all += ac_nodes
	if(ac_tip_objs) all += ac_tip_objs
	if(ac_confirm_objs) all += ac_confirm_objs
	return all

client/proc/ACWinStart(params)
	if(!acmenu_open || ac_dragging) return
	ac_win_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	ac_win_mx = m[1]
	ac_win_my = m[2]
	ac_win_ox = ac_pan_x
	ac_win_oy = ac_pan_y
	ac_win_dragging = TRUE
	HideAcquireTip()

client/proc/ACWinMove(params)
	if(!acmenu_open || !ac_win_dragging) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = ACPanBounds()
	var/wantx = clamp(ac_win_ox + (m[1] - ac_win_mx), b[1], b[2])
	var/wanty = clamp(ac_win_oy + (m[2] - ac_win_my), b[3], b[4])
	var/dx = wantx - ac_pan_x
	var/dy = wanty - ac_pan_y
	if(!dx && !dy) return
	ac_pan_x = wantx
	ac_pan_y = wanty
	ac_win_dragged = TRUE
	ShiftScreenLocs(AcquireLiveObjs(), dx, dy)

client/proc/ACWinEnd()
	if(!ac_win_dragging) return
	ac_win_dragging = FALSE
	if(!ac_win_dragged) return
	ac_win_dragged = FALSE
	setPref("acPanX", ac_pan_x)
	setPref("acPanY", ac_pan_y)

client/proc/AcText(txt, dx, dyTop, w, color = AC_CREAM, align = "center", into = null)
	var/atom/movable/shud/actext/t = new
	t.maptext_width = w
	t.maptext_height = 16
	t.screen_loc = ACloc(dx, dyTop, 16)
	if(align == "center")
		t.maptext = "<center><span style=\"[AC_FONT]; color:[color]\">[txt]</span></center>"
	else
		t.maptext = "<span style=\"[AC_FONT]; color:[color]; text-align:[align]\">[txt]</span>"
	var/list/L = into ? into : ac_objs
	L += t
	screen += t
	return t

client/proc/AcBtn(action, label, dx, dyTop, into = null, dim = 0, lay = 0)
	var/atom/movable/shud/acbtn/b = new
	b.icon = '_Reworks/Arcane/Icons/book/GoldBtnA_02.png'
	b.action = action
	b.screen_loc = ACloc(dx, dyTop, 26)
	if(lay) b.layer = lay
	var/list/L = into ? into : ac_objs
	L += b
	screen += b
	var/atom/movable/shud/acbtntext/t = new
	t.maptext_width = 122
	t.screen_loc = ACloc(dx, dyTop + 6, 16)
	if(lay) t.layer = lay + 0.01
	t.maptext = "<center><span style=\"[AC_FONT]; color:[dim ? "#8a6a48" : AC_INK]\">[label]</span></center>"
	L += t
	screen += t
	return b

client/proc/ToggleArcaneAcquire(element)
	if(acmenu_open) CloseArcaneAcquire(1)
	else OpenArcaneAcquire(element)

client/proc/OpenArcaneAcquire(element)
	if(!mob) return
	if(!element || !ARCANE_TREES[element]) element = mob.MageElement
	if(!element || !ARCANE_TREES[element]) return
	if(acmenu_open && ac_element == element) return
	if(acmenu_open) CloseArcaneAcquire(0)
	CloseMenu()
	CloseInventory()
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	CloseLifeSkillsMenu()
	CloseStationMenu()
	CloseArcaneMenu()
	acmenu_open = 1
	ac_element = element
	ac_scroll = 0
	ac_dragging = FALSE
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(AC_W / 32)
	if(mtw * 32 < AC_W) mtw++
	var/mth = round(AC_H / 32)
	if(mth * 32 < AC_H) mth++
	ac_atx = max(1, round((vw - mtw) / 2) + 1)
	ac_aty = max(1, round((vh - mth) / 2) + 1)
	ac_aty = max(ac_aty, min(4, vh - mth + 1))
	ac_pan_x = getPref("acPanX")
	if(isnull(ac_pan_x)) ac_pan_x = 0
	ac_pan_y = getPref("acPanY")
	if(isnull(ac_pan_y)) ac_pan_y = 0
	var/list/b = ACPanBounds()
	ac_pan_x = clamp(ac_pan_x, b[1], b[2])
	ac_pan_y = clamp(ac_pan_y, b[3], b[4])
	ac_win_dragging = FALSE
	ac_win_dragged = FALSE
	BuildArcaneAcquire()
	var/list/all = ac_objs.Copy()
	all += ac_nodes
	KineticEntrance(all)

client/proc/CloseArcaneAcquire(reopen = 0)
	if(!acmenu_open && !ac_objs) return
	acmenu_open = 0
	ac_dragging = FALSE
	ac_pan_dragged = FALSE
	ac_win_dragging = FALSE
	ac_win_dragged = FALSE
	CursorNeutral(src)
	HideAcquireTip()
	HideAcquireConfirm()
	ClearList(ac_nodes)
	ac_nodes = null
	ClearList(ac_objs)
	ac_objs = null
	ac_canvas = null
	ac_rpp = null
	ac_pages = null
	if(reopen && mob)
		setPref("arChapter", "Spells")
		OpenArcaneMenu()

client/proc/BuildArcaneAcquire()
	ac_objs = list()
	ac_nodes = list()
	var/atom/movable/shud/acframe/f = new
	f.icon = '_Reworks/Arcane/Icons/book/AcquireFrame.png'
	f.screen_loc = ACloc(0, 0, AC_H)
	ac_objs += f
	screen += f
	ac_canvas = new
	ac_canvas.icon = ArcaneCanvasCrop(ac_element, ac_scroll)
	ac_canvas.screen_loc = ACloc(AC_BORDER, AC_BORDER, AC_VH)
	ac_objs += ac_canvas
	screen += ac_canvas
	var/atom/movable/shud/acgrip/plate = new
	plate.icon = '_Reworks/Arcane/Icons/book/TitleA_01.png'
	plate.screen_loc = ACloc(round((AC_W - 131) / 2), 2, 24)
	ac_objs += plate
	screen += plate
	AcText("[ac_element] Pages", round((AC_W - 131) / 2), 2 + 5, 131, AC_INK)
	ac_rpp = AcText("", AC_W - AC_BORDER - 8 - 120, 18, 120, AC_GOLD, "right")
	ac_pages = AcText("", AC_W - AC_BORDER - 8 - 260, 34, 260, AC_SOFT, "right")
	RefreshAcquireRpp()
	var/atom/movable/shud/acbtn/x = new
	x.icon = '_Reworks/Arcane/Icons/book/F_UI_MenuIcons_A3.png'
	x.action = "close"
	x.screen_loc = ACloc(AC_W - 4 - 16, 4, 16)
	ac_objs += x
	screen += x
	var/list/els = mob.MageElements()
	if(els.len > 1)
		var/i = 0
		for(var/e in els)
			AcBtn("element:[e]", e, AC_BORDER + 4 + i * 126, 16, null, (e != ac_element))
			i++
	var/list/nodes = ArcaneTreeNodes(ac_element)
	for(var/k in nodes)
		var/atom/movable/shud/acnode/n = new
		n.node_key = k
		ac_nodes += n
		screen += n
	RefreshAcquireNodes()

client/proc/RefreshAcquireRpp()
	if(!ac_rpp || !mob) return
	ac_rpp.maptext = "<span style=\"[AC_FONT]; color:[AC_GOLD]; text-align:right\">[round(mob.GetRPPSpendable())] RPP</span>"
	if(!ac_pages) return
	var/list/nodes = ArcaneTreeNodes(ac_element)
	var/owned = mob.ArcaneOwnedCount(ac_element)
	var/next = mob.MageNextMilestone(ac_element)
	var/tail = next ? ", next milestone at [next]" : ", every milestone reached"
	ac_pages.maptext = "<span style=\"[AC_FONT]; color:[AC_SOFT]; text-align:right\">[owned] of [nodes ? nodes.len : 0] pages[tail]</span>"

client/proc/AcquireNodeState(key)
	if(!mob) return "locked"
	if(!ArcanePagePath(ac_element, key)) return "unwritten"
	if(mob.ArcaneOwnsNode(ac_element, key)) return "owned"
	if(!mob.ArcaneNodeReason(ac_element, key)) return "buy"
	return "locked"

client/proc/RefreshAcquireNodes()
	if(!ac_nodes || !mob) return
	var/list/nodes = ArcaneTreeNodes(ac_element)
	var/park = ACloc(4, 4, 0)
	var/accent = ArcaneTreeAccent(ac_element)
	for(var/atom/movable/shud/acnode/n in ac_nodes)
		var/list/N = nodes[n.node_key]
		var/x = N[1]
		var/y = N[2] - ac_scroll
		var/kind = N[4]
		if(y + 32 <= 0 || y >= AC_VH)
			n.alpha = 0
			n.mouse_opacity = 0
			n.screen_loc = park
			continue
		var/cut_top = max(0, -y)
		var/cut_bot = max(0, y + 32 - AC_VH)
		n.state = AcquireNodeState(n.node_key)
		var/file
		switch(n.state)
			if("owned")
				file = ArcanePoweredIcon(ac_element)
				n.filters = filter(type="outline", size=1, color=accent)
			if("buy")
				file = ArcaneKindIcon(ac_element, kind)
				n.filters = null
			else
				file = ArcaneLockedIcon(kind)
				n.filters = null
		n.icon = ArcaneNodeCrop(file, cut_top, cut_bot)
		n.alpha = 255
		n.mouse_opacity = 2
		n.screen_loc = ACloc(AC_BORDER + x, AC_BORDER + y + cut_top, 32 - cut_top - cut_bot)

client/proc/ACPanStart(params)
	ac_pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	ac_drag_my = m[2]
	ac_drag_s0 = ac_scroll
	ac_dragging = TRUE

client/proc/ACPanEnd(atom/over)
	ac_dragging = FALSE
	ACWinEnd()
	if(!acmenu_open) return
	if(istype(over, /atom/movable/shud/accanvas) || istype(over, /atom/movable/shud/acframe) || istype(over, /atom/movable/shud/acgrip))
		CursorHover(over, "draggable")
	else if(istype(over, /atom/movable/shud/acnode))
		var/atom/movable/shud/acnode/n = over
		CursorHover(n, n.CursorKey())
	else
		CursorNeutral(src)

client/MouseUp(object, location, control, params)
	if(acmenu_open && (ac_dragging || ac_win_dragging || cursor_dyn == ac_canvas || istype(cursor_dyn, /atom/movable/shud/acnode) || istype(cursor_dyn, /atom/movable/shud/acframe) || istype(cursor_dyn, /atom/movable/shud/acgrip)))
		ACPanEnd(object)
	..()

client/proc/ACPanMove(params)
	if(!acmenu_open || !ac_dragging) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/want = ac_drag_s0 + (m[2] - ac_drag_my)
	want = round(want / AC_STEP) * AC_STEP
	want = clamp(want, 0, AC_CANVAS_H - AC_VH)
	if(want == ac_scroll) return
	ac_scroll = want
	ac_pan_dragged = TRUE
	HideAcquireTip()
	if(ac_canvas) ac_canvas.icon = ArcaneCanvasCrop(ac_element, ac_scroll)
	RefreshAcquireNodes()

client/proc/AcquireTipLines(key)
	var/list/nodes = ArcaneTreeNodes(ac_element)
	var/list/N = nodes[key]
	var/tier = N[3]
	var/kind = N[4]
	var/p = ArcanePagePath(ac_element, key)
	var/name = "Unwritten page"
	if(p)
		var/obj/Skills/T = AqTemplate("[p]")
		if(T) name = T.name
	var/state = AcquireNodeState(key)
	var/line3
	var/col3
	switch(state)
		if("owned")
			line3 = "Learned"
			col3 = AC_GREEN
		if("buy")
			line3 = "Learn for [mob.MagePageCost(tier, ac_element)] RPP"
			col3 = AC_GOLD
		if("unwritten")
			line3 = "Not yet written"
			col3 = AC_SOFT
		else
			line3 = mob.ArcaneNodeReason(ac_element, key)
			col3 = AC_RED
	return list(name, "Tier [tier] [kind]", line3, col3)

client/proc/ShowAcquireTip(key)
	HideAcquireTip()
	if(!acmenu_open || !mob || ac_confirm_objs) return
	var/list/nodes = ArcaneTreeNodes(ac_element)
	if(!nodes || !nodes[key]) return
	var/list/N = nodes[key]
	var/cx = N[1] + 16
	var/cy = N[2] - ac_scroll + 16
	var/tx = min(AC_BORDER + cx + 24, AC_W - AC_BORDER - AC_TIP_W)
	var/ty = min(max(AC_BORDER, AC_BORDER + cy - 10), AC_H - AC_BORDER - AC_TIP_H)
	ac_tip_objs = list()
	var/atom/movable/shud/acpic/bg = new
	bg.icon = '_Reworks/Arcane/Icons/book/AcquireTip.png'
	bg.layer = AC_LAYER + 0.7
	bg.screen_loc = ACloc(tx, ty, AC_TIP_H)
	ac_tip_objs += bg
	screen += bg
	var/list/L = AcquireTipLines(key)
	var/atom/movable/shud/actext/t1 = AcText(L[1], tx + 8, ty + 10, AC_TIP_W - 16, AC_CREAM, "center", ac_tip_objs)
	var/atom/movable/shud/actext/t2 = AcText(L[2], tx + 8, ty + 30, AC_TIP_W - 16, AC_SOFT, "center", ac_tip_objs)
	var/atom/movable/shud/actext/t3 = AcText(L[3], tx + 8, ty + 50, AC_TIP_W - 16, L[4], "center", ac_tip_objs)
	t1.layer = AC_LAYER + 0.75
	t2.layer = AC_LAYER + 0.75
	t3.layer = AC_LAYER + 0.75

client/proc/HideAcquireTip()
	ClearList(ac_tip_objs)
	ac_tip_objs = null

client/proc/AcquireNodeClick(key)
	if(!acmenu_open || !mob) return
	if(ac_pan_dragged)
		ac_pan_dragged = FALSE
		return
	if(ac_confirm_objs) return
	HideAcquireTip()
	var/state = AcquireNodeState(key)
	if(state == "buy")
		ShowAcquireConfirm(key)
		return
	var/why = (state == "owned") ? "You already hold that page." : ((state == "unwritten") ? "That page is not yet written." : mob.ArcaneNodeReason(ac_element, key))
	mob << "<font color=#ff6464>[why]</font>"

client/proc/ShowAcquireConfirm(key)
	HideAcquireConfirm()
	ac_confirm_key = key
	ac_confirm_objs = list()
	var/cx0 = round((AC_W - AC_CONF_W) / 2)
	var/cy0 = round((AC_H - AC_CONF_H) / 2)
	var/atom/movable/shud/acconfirmbg/bg = new
	bg.icon = '_Reworks/Arcane/Icons/book/AcquireConfirm.png'
	bg.screen_loc = ACloc(cx0, cy0, AC_CONF_H)
	ac_confirm_objs += bg
	screen += bg
	var/list/L = AcquireTipLines(key)
	var/list/nodes = ArcaneTreeNodes(ac_element)
	var/list/N = nodes[key]
	var/atom/movable/shud/actext/t1 = AcText("Learn [L[1]]?", cx0 + 8, cy0 + 14, AC_CONF_W - 16, AC_CREAM, "center", ac_confirm_objs)
	var/atom/movable/shud/actext/t2 = AcText("Tier [N[3]] page, [mob.MagePageCost(N[3], ac_element)] RPP", cx0 + 8, cy0 + 34, AC_CONF_W - 16, AC_GOLD, "center", ac_confirm_objs)
	t1.layer = AC_LAYER + 0.85
	t2.layer = AC_LAYER + 0.85
	var/by = cy0 + AC_CONF_H - 26 - 12
	var/bgap = 12
	var/bx = cx0 + round((AC_CONF_W - 122 * 2 - bgap) / 2)
	AcBtn("learn", "Learn", bx, by, ac_confirm_objs, 0, AC_LAYER + 0.86)
	AcBtn("back", "Back", bx + 122 + bgap, by, ac_confirm_objs, 0, AC_LAYER + 0.86)
	KineticEntrance(ac_confirm_objs)

client/proc/HideAcquireConfirm()
	ac_confirm_key = null
	ClearList(ac_confirm_objs)
	ac_confirm_objs = null

client/proc/AcquireAction(action)
	if(!acmenu_open || !mob) return
	if(action == "close")
		CloseArcaneAcquire(1)
		return
	if(action == "back")
		HideAcquireConfirm()
		return
	if(action == "learn")
		var/key = ac_confirm_key
		HideAcquireConfirm()
		if(!key) return
		var/p = ArcanePagePath(ac_element, key)
		if(!p) return
		spawn()
			if(mob && mob.MageBuyPage(p) && acmenu_open)
				RefreshAcquireNodes()
				RefreshAcquireRpp()
		return
	if(copytext(action, 1, 9) == "element:")
		var/e = copytext(action, 9)
		if(e != ac_element && mob.MageOwnsElement(e))
			OpenArcaneAcquire(e)
