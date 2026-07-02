#ifndef TT_SHAPE_ROUND
#define TT_SHAPE_ROUND   "round"
#define TT_SHAPE_DIAMOND "diamond"
#define TT_SHAPE_LARGE   "large"
#define TT_FAM_FORGE     "forge"
#define TT_FAM_CYBER     "cyber"
#define TT_FAM_MED       "medicine"
#define TT_FAM_TELE      "telecom"
#define TT_FAM_MIL       "military"
#define TT_FAM_MISC      "misc"
#endif

#define TT_W 624
#define TT_H 344
#define TT_FONT      "font-family:'monogram'; font-size:12pt"          // headers/labels (native 16px)
#define TT_FONT_BODY "font-family:'Pixel Operator 8'; font-size:6pt"   // dense body (native 8px)
#define TT_LAYER (FLY_LAYER + 3.7)

/var/TT_MONO_RSC = 'HUD/monogram.ttf'
/var/TT_PO8_RSC  = 'HUD/PixelOperator8.ttf'

// node-canvas viewport (pixels from the panel's top-left)
#define TT_VP_L 18
#define TT_VP_T 50
#define TT_VP_R 606
#define TT_VP_B 238
#define TT_MARGIN 40
#define TT_COL_W 92
#define TT_ROW_H 50
#define TT_NODE 22
#define TT_NODE_LG 30
#define TT_SEL 22
#define TT_SEL_LG 34
#define TT_PAN_STEP 4

// info bar (Tree tab) — sits below the viewport on the main grid
#define TT_BAR_T 246          // top of the header band
#define TT_BAND_H 24

var/list/TT_FAM_COLOR = list(
	TT_FAM_FORGE = "#ff9a3c", TT_FAM_CYBER = "#b46bff", TT_FAM_MED = "#5bd75b",
	TT_FAM_TELE = "#37c4ff", TT_FAM_MIL = "#ff5a5a", TT_FAM_MISC = "#cfe3f5")
#define TT_LOCKED_COLOR "#5a6a82"
#define TT_LINE_LIT  "#37e0ff"
#define TT_LINE_DIM  "#3c5478"
#define TT_SEP_COLOR "#37c4ff"

/proc/TTCoverIcon(w, h)        
	var/icon/I = icon('BLANK.dmi')
	I.Scale(w, h)
	I.DrawBox("#28365a", 1, 1, w, h)
	return I

/proc/TTHitIcon(w, h)          
	var/icon/I = icon('BLANK.dmi')
	I.Scale(w, h)
	I.DrawBox("#000000", 1, 1, w, h)
	return I

/proc/TTBandIcon(w, h)         
	var/icon/I = icon('BLANK.dmi')
	I.Scale(w, h)
	I.DrawBox("#16223e", 1, 1, w, h)
	return I

/atom/movable/shud/ttbg            // panel / band / cover
	layer = TT_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.TTPanelStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.TTPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.TTPanelEnd()

/atom/movable/shud/ttpic           // decorative sprite (icon, money, separator)
	layer = TT_LAYER + 0.45
	mouse_opacity = 0

/atom/movable/shud/tttext          // outlined text (floats on the grid)
	layer = TT_LAYER + 0.5
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/ttlabel
	layer = TT_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/ttpan
	icon = 'HUD/tt_panhit.png'
	layer = TT_LAYER + 0.48
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.TechPanStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.TechPanMove(params)

/atom/movable/shud/ttline
	layer = TT_LAYER + 0.25
	mouse_opacity = 0
	var/ccx = 0
	var/ccy = 0
	var/cw = 0
	var/ch = 0
	var/horiz = 0
	var/base_alpha = 255

/atom/movable/shud/ttnode
	layer = TT_LAYER + 0.5
	mouse_opacity = 2
	var/node_name
	var/node_col = 0
	var/node_row = 0
	var/decorated = 0   // 1 while this node carries the selection reticle overlay
	MouseEntered(location, control, params)
		if(usr) usr.client.TechNodeHover(src, TRUE)
	MouseExited(location, control, params)
		if(usr) usr.client.TechNodeHover(src, FALSE)
	Click(location, control, params)
		if(usr) usr.client.TechSelectNode(node_name)

/atom/movable/shud/ttsel           // animated diamond reticle, parked over a node
	layer = TT_LAYER + 0.55
	mouse_opacity = 0

/atom/movable/shud/ttbtn           // clickable plate
	layer = TT_LAYER + 0.45
	mouse_opacity = 2
	var/action
	var/arg
	var/atom/movable/shud/ttlabel/lbl
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr) usr.client.TechButton(action, arg)

/atom/movable/shud/ttwidget
	parent_type = /atom/movable/shud/pressbtn
	layer = TT_LAYER + 0.6
	mouse_opacity = 2
	var/ttarg = 0
	DoAction()
		if(usr && usr.client) usr.client.TechButton(action, ttarg)
	Click()
		if(pressing) return
		pressing = TRUE
		var/list/f = PressFrames()
		icon = f[2]
		sleep(MHUD_PRESS_STEP)
		icon = f[3]
		sleep(MHUD_PRESS_STEP)
		DoAction()

/atom/movable/shud/ttcraftrow      // craft list row hit area
	layer = TT_LAYER + 0.42
	mouse_opacity = 2
	var/obj/Items/catalog
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.ShowCraftDesc(catalog)
			return
		usr.client.TechCraftMake(catalog)

/atom/movable/shud/craftdescpanel
	layer = TT_LAYER + 1.0
	mouse_opacity = 2
	Click(location, control, params)
		if(usr && params && findtext(params, "right=1")) usr.client.HideCraftDesc()

client
	var/tmp
		tmenu_open = 0
		tmenu_tab = "tree"
		tt_atx = 1
		tt_aty = 1
		list/tmenu_chrome
		list/tmenu_tabobjs
		list/tmenu_nodes
		list/craft_desc_objs
		obj/Items/craft_desc_item
		atom/movable/shud/ttsel/tmenu_selobj
		atom/movable/shud/tttext/tmenu_rpp_label
		atom/movable/shud/tttext/tmenu_money_label
		atom/movable/shud/tttext/tmenu_infoname
		atom/movable/shud/tttext/tmenu_info
		atom/movable/shud/ttbtn/tmenu_learn
		atom/movable/shud/ttlabel/tmenu_learn_lbl
		atom/movable/shud/ttbtn/tmenu_tab_tree
		atom/movable/shud/ttbtn/tmenu_tab_craft
		atom/movable/shud/ttlabel/tmenu_tab_tree_lbl
		atom/movable/shud/ttlabel/tmenu_tab_craft_lbl
		tmenu_panx = 0
		tmenu_pany = 0
		tmenu_lastpanx = 0
		tmenu_lastpany = 0
		tmenu_drag_mx = 0
		tmenu_drag_my = 0
		tmenu_drag_px = 0
		tmenu_drag_py = 0
		tt_pan_x = 0    // whole-panel drag offset (px); separate from the canvas pan above
		tt_pan_y = 0
		tt_pan_mx = 0
		tt_pan_my = 0
		tt_pan_ox = 0
		tt_pan_oy = 0
		tt_pan_dragged = FALSE
		tmenu_sel
		tmenu_filter = "all"
		tmenu_craftpage = 1
		tmenu_selanim = 0
		atom/movable/shud/menubtn/btn_tech
		atom/movable/shud/menulabel/btn_tech_label

client/proc/TTloc(dx, dyTop, h = 0)
	var/py = TT_H - dyTop - h
	var/ax = dx + tt_pan_x
	var/ay = py + tt_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[tt_atx + (ax - axp) / 32]:[axp],[tt_aty + (ay - ayp) / 32]:[ayp]"


client/proc/InitTechButton()
	btn_tech = new('HUD/ui_icon_skills.png')
	btn_tech.btn_id = "tech"
	btn_tech.screen_loc = "EAST:-4,NORTH:-248"
	shud_parts += btn_tech
	btn_tech_label = new
	btn_tech_label.maptext_width = 48
	btn_tech_label.SetText("Tech")
	btn_tech_label.pixel_x = -54
	btn_tech_label.pixel_y = 8
	btn_tech.label = btn_tech_label
	btn_tech.vis_contents += btn_tech_label

client/proc/ResetTechHUD()
	CloseTechMenu()
	btn_tech = null
	btn_tech_label = null

client/proc/ToggleTechMenu()
	if(tmenu_open) CloseTechMenu()
	else OpenTechMenu()

client/proc/OpenTechMenu(start_tab = "tree")
	if(tmenu_open || !mob) return
	if(length(TechnologyTree) < 1) fillOutTechTree()
	CloseMenu(); CloseInventory(); CloseCharacterMenu(); CloseSkillMenu(); CloseAcquireMenu()
	tmenu_open = 1
	tmenu_tab = start_tab

	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(TT_W / 32); if(mtw * 32 < TT_W) mtw++
	var/mth = round(TT_H / 32); if(mth * 32 < TT_H) mth++
	tt_atx = max(1, round((vw - mtw) / 2) + 1)
	tt_aty = max(1, round((vh - mth) / 2) + 1)
	// restore saved panel position, clamped to the current view
	tt_pan_x = getPref("ttPanX"); if(isnull(tt_pan_x)) tt_pan_x = 0
	tt_pan_y = getPref("ttPanY"); if(isnull(tt_pan_y)) tt_pan_y = 0
	var/list/tb = TTPanBounds()
	tt_pan_x = clamp(tt_pan_x, tb[1], tb[2])
	tt_pan_y = clamp(tt_pan_y, tb[3], tb[4])

	if(btn_tech)
		btn_tech.icon = 'HUD/ui_slot_unavailable.png'
		btn_tech.SetGlyphDimmed(TRUE)
	if(btn_tech_label) btn_tech_label.alpha = 0

	BuildTechChrome()
	ShowTechTab(tmenu_tab)
	KineticEntrance(tmenu_chrome)

client/proc/CloseTechMenu()
	tmenu_open = 0
	HideCraftDesc()
	ClearList(tmenu_tabobjs); tmenu_tabobjs = null
	ClearList(tmenu_chrome); tmenu_chrome = null
	tmenu_nodes = null
	tmenu_selobj = null
	tmenu_rpp_label = null
	tmenu_money_label = null
	tmenu_infoname = null
	tmenu_info = null
	tmenu_learn = null
	tmenu_learn_lbl = null
	tmenu_tab_tree = null
	tmenu_tab_craft = null
	tmenu_tab_tree_lbl = null
	tmenu_tab_craft_lbl = null
	if(btn_tech)
		btn_tech.icon = 'HUD/ui_slot_available.png'
		btn_tech.SetGlyphDimmed(FALSE)

client/proc/ClearList(list/L)
	if(!L) return
	while(L.len)
		var/atom/movable/o = L[L.len]
		L.len--
		screen -= o
		del o

client/proc/MakeTabBtn(list/store, action, dxLeft, dyTop, w, h, labeltxt)
	var/atom/movable/shud/ttbtn/b = new
	b.icon = 'HUD/ui_tab_idle.png'
	b.action = action
	b.screen_loc = TTloc(dxLeft, dyTop, h)
	store += b
	var/atom/movable/shud/ttlabel/L = new
	L.maptext_width = w
	L.maptext_height = 16
	L.screen_loc = TTloc(dxLeft, dyTop + round((h - 16) / 2) - 2, 16)
	L.maptext = "<center><span style=\"[TT_FONT]; color:#ffffff\">[labeltxt]</span></center>"
	store += L
	b.lbl = L
	return b

// thin cyan separator
client/proc/AddSeparator(list/store, dxLeft, dyCenter, width)
	var/atom/movable/shud/ttpic/s = new
	s.icon = 'HUD/tt_conn_h.png'
	s.color = TT_SEP_COLOR
	s.layer = TT_LAYER + 0.3
	s.transform = matrix(width / 16, 0, 0, 0, 1, 0)
	s.screen_loc = TTloc(dxLeft + round(width / 2) - 8, dyCenter - 8, 16)
	store += s

client/proc/BuildTechChrome()
	tmenu_chrome = list()

	var/atom/movable/shud/ttbg/P = new
	P.icon = 'HUD/tech_panel.png'
	P.screen_loc = TTloc(0, 0, TT_H)
	tmenu_chrome += P

	var/atom/movable/shud/ttbg/tp = new
	tp.icon = 'HUD/tech_titleplate.png'
	tp.layer = TT_LAYER + 0.3
	tp.mouse_opacity = 0
	tp.screen_loc = TTloc(212, 6, 32)
	tmenu_chrome += tp
	var/atom/movable/shud/ttlabel/title = new
	title.maptext_width = 200
	title.maptext_height = 16
	title.screen_loc = TTloc(212, 12, 16)
	title.maptext = "<center><span style=\"[TT_FONT]; color:#ffffff\">TECHNOLOGY</span></center>"
	tmenu_chrome += title

	tmenu_tab_tree = MakeTabBtn(tmenu_chrome, "tab_tree", 16, 8, 84, 32, "Tree")
	tmenu_tab_tree_lbl = tmenu_tab_tree.lbl
	tmenu_tab_craft = MakeTabBtn(tmenu_chrome, "tab_craft", 104, 8, 84, 32, "Craft")
	tmenu_tab_craft_lbl = tmenu_tab_craft.lbl

	var/atom/movable/shud/ttwidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.action = "close"
	X.screen_loc = TTloc(590, 12, 24)
	tmenu_chrome += X

	// balance: RPP   [money icon] count
	tmenu_rpp_label = new
	tmenu_rpp_label.maptext_width = 80
	tmenu_rpp_label.maptext_height = 16
	tmenu_rpp_label.screen_loc = TTloc(426, 14, 16)
	tmenu_chrome += tmenu_rpp_label

	var/icon/mi = icon('money.dmi'); mi.Scale(16, 16)
	var/atom/movable/shud/ttpic/micon = new
	micon.icon = mi
	micon.layer = TT_LAYER + 0.5
	micon.screen_loc = TTloc(500, 14, 16)
	tmenu_chrome += micon

	tmenu_money_label = new
	tmenu_money_label.maptext_width = 76
	tmenu_money_label.maptext_height = 16
	tmenu_money_label.screen_loc = TTloc(520, 14, 16)
	tmenu_chrome += tmenu_money_label

	for(var/atom/movable/o in tmenu_chrome)
		screen += o
	RefreshBalance()
	RefreshTabLook()

client/proc/RefreshTabLook()
	if(tmenu_tab_tree)
		tmenu_tab_tree.icon = (tmenu_tab == "tree") ? 'HUD/ui_tab_active.png' : 'HUD/ui_tab_idle.png'
	if(tmenu_tab_craft)
		tmenu_tab_craft.icon = (tmenu_tab == "craft") ? 'HUD/ui_tab_active.png' : 'HUD/ui_tab_idle.png'
	if(tmenu_tab_tree_lbl)
		tmenu_tab_tree_lbl.maptext = "<center><span style=\"[TT_FONT]; color:[tmenu_tab == "tree" ? "#06283b" : "#cfe3f5"]\">Tree</span></center>"
	if(tmenu_tab_craft_lbl)
		tmenu_tab_craft_lbl.maptext = "<center><span style=\"[TT_FONT]; color:[tmenu_tab == "craft" ? "#06283b" : "#cfe3f5"]\">Craft</span></center>"

client/proc/RefreshBalance()
	if(tmenu_rpp_label)
		tmenu_rpp_label.maptext = "<span style=\"[TT_FONT]; color:#ffd86b\">RPP [round(mob.GetRPPSpendable())]</span>"
	if(tmenu_money_label)
		var/money = 0
		for(var/obj/Money/mo in mob) money += mo.Level
		tmenu_money_label.maptext = "<span style=\"[TT_FONT]; color:#9be7a0\">[Commas(round(money))]</span>"

client/proc/ShowTechTab(tab)
	if(!tmenu_open) return
	HideCraftDesc()
	tmenu_tab = tab
	ClearList(tmenu_tabobjs)
	tmenu_tabobjs = list()
	tmenu_selobj = null
	tmenu_infoname = null
	tmenu_info = null
	tmenu_learn = null
	tmenu_learn_lbl = null
	tmenu_nodes = null
	RefreshTabLook()
	if(tab == "tree")
		BuildTree()
	else
		if(tmenu_sel) tmenu_filter = TechNodeFamily(tmenu_sel)
		tmenu_craftpage = 1
		BuildCraft()
	KineticEntrance(tmenu_tabobjs)

client/proc/TechButton(action, arg)
	switch(action)
		if("close") CloseTechMenu()
		if("tab_tree") ShowTechTab("tree")
		if("tab_craft") ShowTechTab("craft")
		if("learn") TechLearnSelected()
		if("craftpage")
			tmenu_craftpage += arg
			BuildCraft()
		if("filter")
			tmenu_filter = arg
			tmenu_craftpage = 1
			BuildCraft()

client/proc/TTOriginDx()  return TT_VP_L + TT_MARGIN - tmenu_panx
client/proc/TTOriginDyT() return TT_VP_T + TT_MARGIN - tmenu_pany

client/proc/BuildTree()
	tmenu_nodes = list()

	var/atom/movable/shud/ttbg/ibox = new
	ibox.icon = 'HUD/tech_infobar.png'
	ibox.layer = TT_LAYER + 0.32
	ibox.mouse_opacity = 0
	ibox.screen_loc = TTloc(14, TT_BAR_T - 6, 86)
	tmenu_tabobjs += ibox

	var/atom/movable/shud/ttbg/band = new
	band.icon = 'HUD/tt_band.png'
	band.alpha = 200
	band.layer = TT_LAYER + 0.4
	band.mouse_opacity = 0
	band.screen_loc = TTloc(22, TT_BAR_T + 4, TT_BAND_H)
	tmenu_tabobjs += band

	tmenu_infoname = new           // name + cost
	tmenu_infoname.maptext_width = 400
	tmenu_infoname.maptext_height = 16
	tmenu_infoname.screen_loc = TTloc(30, TT_BAR_T + 8, 16)
	tmenu_tabobjs += tmenu_infoname

	tmenu_info = new               // requires/unlocks/desc
	tmenu_info.maptext_width = 560
	tmenu_info.maptext_height = 40
	tmenu_info.screen_loc = TTloc(30, TT_BAR_T + 34, 40)
	tmenu_tabobjs += tmenu_info

	// Learn plate + label
	tmenu_learn = new
	tmenu_learn.icon = 'HUD/cust_button.png'
	tmenu_learn.action = "learn"
	tmenu_learn.layer = TT_LAYER + 0.45
	tmenu_learn.screen_loc = TTloc(444, TT_BAR_T + 3, 26)
	tmenu_tabobjs += tmenu_learn
	tmenu_learn_lbl = new
	tmenu_learn_lbl.maptext_width = 150
	tmenu_learn_lbl.maptext_height = 16
	tmenu_learn_lbl.screen_loc = TTloc(444, TT_BAR_T + 8, 16)
	tmenu_tabobjs += tmenu_learn_lbl

	var/atom/movable/shud/ttpan/pan = new
	pan.screen_loc = TTloc(TT_VP_L, TT_VP_T, TT_VP_B - TT_VP_T)
	tmenu_tabobjs += pan

	// nodes
	for(var/n in TechnologyTree)
		var/knowledgePaths/tech/t = TechnologyTree[n]
		if(t.name == "Not Obtainable") continue
		var/list/e = TechTreeLayout[t.name]
		var/col
		var/row
		if(e)
			col = e[1]; row = e[2]
		else
			col = tmenu_nodes.len % 8
			row = 35 + round(tmenu_nodes.len / 8)
			world.log << "TechTree: node '[t.name]' has no layout entry; auto-placed."
		var/atom/movable/shud/ttnode/nd = new
		nd.node_name = t.name
		nd.node_col = col
		nd.node_row = row
		StyleNode(nd, t)
		tmenu_nodes[t.name] = nd
		tmenu_tabobjs += nd

	// connectors
	for(var/n in TechnologyTree)
		var/knowledgePaths/tech/t = TechnologyTree[n]
		if(t.name == "Not Obtainable") continue
		var/list/ce = TechTreeLayout[t.name]
		if(!ce) continue
		var/owned_child = (t.name in mob.knowledgeTracker.learnedKnowledge)
		for(var/req in t.requires)
			var/list/pe = TechTreeLayout[req]
			if(!pe) continue
			var/lit = owned_child || (req in mob.knowledgeTracker.learnedKnowledge)
			BuildConnector(pe[1], pe[2], ce[1], ce[2], lit)

	for(var/atom/movable/o in tmenu_tabobjs)
		if(o in screen) continue
		screen += o

	tmenu_lastpanx = tmenu_panx
	tmenu_lastpany = tmenu_pany
	RepositionTree()
	if(tmenu_sel) SetSelector(tmenu_sel)
	RefreshInfoBar()

client/proc/BuildTreeCovers()
	var/list/strips = list(
		list(TT_VP_L, TT_VP_T - 18, TT_VP_R - TT_VP_L, 18),
		list(TT_VP_L, TT_VP_B, TT_VP_R - TT_VP_L, 6),
		list(TT_VP_L - 16, TT_VP_T - 18, 16, (TT_VP_B - TT_VP_T) + 24),
		list(TT_VP_R, TT_VP_T - 18, 16, (TT_VP_B - TT_VP_T) + 24))
	for(var/list/s in strips)
		var/atom/movable/shud/ttbg/c = new
		c.icon = TTCoverIcon(s[3], s[4])
		c.layer = TT_LAYER + 0.3
		c.mouse_opacity = 0
		c.screen_loc = TTloc(s[1], s[2], s[4])
		tmenu_tabobjs += c

client/proc/StyleNode(atom/movable/shud/ttnode/nd, knowledgePaths/tech/t)
	var/shape = TechNodeShape(t)
	var/owned = (t.name in mob.knowledgeTracker.learnedKnowledge)
	var/avail = t.meetsReqs(mob.knowledgeTracker.learnedKnowledge)
	var/famcol = TT_FAM_COLOR[TechNodeFamily(t.name)]
	var/ic
	switch(shape)
		if(TT_SHAPE_LARGE) ic = owned ? 'HUD/tt_large.png' : 'HUD/tt_large_off.png'
		if(TT_SHAPE_DIAMOND) ic = owned ? 'HUD/tt_sharp.png' : 'HUD/tt_sharp_off.png'
		else ic = owned ? 'HUD/tt_round.png' : 'HUD/tt_round_off.png'
	nd.icon = ic
	if(owned)
		nd.color = famcol
		nd.alpha = 255
	else if(avail)
		nd.color = famcol
		nd.alpha = (mob && mob.CanAffordTechNode(t)) ? 235 : 140
	else
		nd.color = TT_LOCKED_COLOR
		nd.alpha = 110

client/proc/BuildConnector(pcol, prow, ccol, crow, lit)
	var/x1 = pcol * TT_COL_W, y1 = prow * TT_ROW_H
	var/x2 = ccol * TT_COL_W, y2 = crow * TT_ROW_H
	if(x1 != x2) AddSeg((x1 + x2) / 2, y1, abs(x2 - x1), 1, lit)
	if(y1 != y2) AddSeg(x2, (y1 + y2) / 2, abs(y2 - y1), 0, lit)

client/proc/AddSeg(ccx, ccy, len, horizontal, lit)
	var/atom/movable/shud/ttline/L = new
	if(horizontal)
		L.icon = 'HUD/tt_conn_h.png'
		L.transform = matrix(len / 16, 0, 0, 0, 1, 0)
		L.cw = len ; L.ch = 16
	else
		L.icon = 'HUD/tt_conn_v.png'
		L.transform = matrix(1, 0, 0, 0, len / 16, 0)
		L.cw = 16 ; L.ch = len
	L.color = lit ? TT_LINE_LIT : TT_LINE_DIM
	L.alpha = lit ? 255 : 150
	L.base_alpha = L.alpha
	L.ccx = ccx ; L.ccy = ccy ; L.horiz = horizontal
	tmenu_tabobjs += L

client/proc/RepositionTree()
	if(!tmenu_open || tmenu_tab != "tree") return
	var/odx = TTOriginDx(), odyt = TTOriginDyT()
	var/park = TTloc(4, 4, 0)   // safe in-view park for culled objects: never anchors off-view (no spill / HUD shift)
	for(var/atom/movable/shud/ttline/L in tmenu_tabobjs)
		var/scx = odx + L.ccx, scy = odyt + L.ccy
		if(L.horiz)
			if(scy < TT_VP_T || scy > TT_VP_B)
				L.alpha = 0
				L.screen_loc = park
				continue
			var/cl = max(scx - L.cw / 2, TT_VP_L), cr = min(scx + L.cw / 2, TT_VP_R)
			if(cr <= cl)
				L.alpha = 0
				L.screen_loc = park
				continue
			L.alpha = L.base_alpha
			L.transform = matrix((cr - cl) / 16, 0, 0, 0, 1, 0)
			L.screen_loc = TTloc(round((cl + cr) / 2) - 8, scy - 8, 16)
		else
			if(scx < TT_VP_L || scx > TT_VP_R)
				L.alpha = 0
				L.screen_loc = park
				continue
			var/ct = max(scy - L.ch / 2, TT_VP_T), cb = min(scy + L.ch / 2, TT_VP_B)
			if(cb <= ct)
				L.alpha = 0
				L.screen_loc = park
				continue
			L.alpha = L.base_alpha
			L.transform = matrix(1, 0, 0, 0, (cb - ct) / 16, 0)
			L.screen_loc = TTloc(scx - 8, round((ct + cb) / 2) - 8, 16)
	for(var/name in tmenu_nodes)
		var/atom/movable/shud/ttnode/nd = tmenu_nodes[name]
		var/cx = odx + nd.node_col * TT_COL_W
		var/cy = odyt + nd.node_row * TT_ROW_H
		// 16px inset so a node never half-bleeds past the viewport (no covers)
		if(cx < TT_VP_L + 16 || cx > TT_VP_R - 16 || cy < TT_VP_T + 16 || cy > TT_VP_B - 16)
			nd.alpha = 0
			nd.mouse_opacity = 0
			nd.screen_loc = park
			continue
		nd.mouse_opacity = 2
		var/sz = (TechNodeShape(TechnologyTree[name]) == TT_SHAPE_LARGE) ? TT_NODE_LG : TT_NODE
		nd.screen_loc = TTloc(cx - sz / 2, cy - sz / 2, sz)
		StyleNode(nd, TechnologyTree[name])
	DecorateSelected()

client/proc/DecorateSelected()
	if(!tmenu_nodes) return
	var/atom/movable/shud/ttnode/target
	if(tmenu_sel && (tmenu_sel in tmenu_nodes))
		target = tmenu_nodes[tmenu_sel]
	for(var/nm in tmenu_nodes)
		var/atom/movable/shud/ttnode/nd = tmenu_nodes[nm]
		if(nd.decorated && nd != target)
			nd.overlays = null
			nd.filters = null
			nd.decorated = 0
	if(!target || target.decorated) return
	var/shape = TechNodeShape(TechnologyTree[tmenu_sel])
	var/nodeW = (shape == TT_SHAPE_LARGE) ? TT_NODE_LG : ((shape == TT_SHAPE_DIAMOND) ? 21 : 22)
	var/retW  = (shape == TT_SHAPE_LARGE) ? TT_SEL_LG : TT_SEL
	var/off = round((nodeW - retW) / 2)   // centre the reticle on the node icon
	var/image/ret = image((shape == TT_SHAPE_LARGE) ? 'HUD/tt_sel_lg.png' : 'HUD/tt_sel.png')
	ret.color = "#8be9ff"
	ret.pixel_x = off
	ret.pixel_y = off
	ret.appearance_flags = KEEP_APART | RESET_COLOR
	target.overlays += ret
	target.filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	target.decorated = 1

client/proc/SetSelector(name)
	tmenu_sel = name
	DecorateSelected()

client/proc/TechNodeHover(atom/movable/shud/ttnode/nd, over)
	if(!nd || nd.decorated) return   // the selected node keeps its reticle glow
	nd.filters = over ? filter(type="drop_shadow", x=0, y=0, size=3, color="#8be9ff") : null

client/proc/TechSelectNode(name)
	if(!name) return
	SetSelector(name)
	RefreshInfoBar()

client/proc/RefreshInfoBar()
	if(!tmenu_infoname || !tmenu_info) return
	if(!tmenu_sel || !(tmenu_sel in TechnologyTree))
		tmenu_infoname.maptext = "<span style=\"[TT_FONT]; color:#9fb3cc\">Select a technology</span>"
		tmenu_info.maptext = ""
		if(tmenu_learn) tmenu_learn.alpha = 60
		if(tmenu_learn_lbl) tmenu_learn_lbl.maptext = ""
		return
	var/knowledgePaths/tech/t = TechnologyTree[tmenu_sel]
	var/owned = (t.name in mob.knowledgeTracker.learnedKnowledge)
	var/avail = t.meetsReqs(mob.knowledgeTracker.learnedKnowledge)
	var/cost = mob.TechNodeCost(t)
	var/famcol = TT_FAM_COLOR[TechNodeFamily(t.name)]
	var/reqs = t.requires.len ? jointext(t.requires, ", ") : "None"
	var/unlocks = t.unlocks ? t.unlocks : "Nothing further"
	var/status
	if(owned) status = "<span style=\"color:#9be7a0\">LEARNED</span>"
	else if(!avail) status = "<span style=\"color:#ff7a7a\">LOCKED</span>"
	else status = "<span style=\"color:#ffd86b\">[cost] RPP</span>"
	tmenu_infoname.maptext = "<span style=\"[TT_FONT]; color:[famcol]\">[t.name]</span> &nbsp;&nbsp; <span style=\"[TT_FONT]\">[status]</span>"
	tmenu_info.maptext = "<span style=\"[TT_FONT_BODY]; color:#bcd0e8\">Requires: [reqs]<br>Unlocks: [unlocks]<br>[t.description]</span>"
	if(tmenu_learn)
		var/can = (!owned && avail && mob.CanAffordTechNode(t))
		tmenu_learn.alpha = can ? 255 : 110
		tmenu_learn_lbl.maptext = "<center><span style=\"[TT_FONT]; color:[can ? "#8be9ff" : "#5a6a82"]\">[owned ? "LEARNED" : "LEARN"]</span></center>"

client/proc/TechLearnSelected()
	if(!tmenu_sel || !(tmenu_sel in TechnologyTree)) return
	var/knowledgePaths/tech/t = TechnologyTree[tmenu_sel]
	if(t.name in mob.knowledgeTracker.learnedKnowledge) return
	spawn()
		if(mob.BuyTechNode(t))
			ShowTechTab("tree")
			RefreshBalance()

// panning
client/proc/TechPanStart(params)
	var/list/m = MouseAbs(params)
	if(!m) return
	tmenu_drag_mx = m[1]; tmenu_drag_my = m[2]
	tmenu_drag_px = tmenu_panx; tmenu_drag_py = tmenu_pany

client/proc/TechPanMove(params)
	var/list/m = MouseAbs(params)
	if(!m) return
	tmenu_panx = clamp(tmenu_drag_px - (m[1] - tmenu_drag_mx), 0, TT_CanvasW())
	tmenu_pany = clamp(tmenu_drag_py + (m[2] - tmenu_drag_my), 0, TT_CanvasH())
	if(abs(tmenu_panx - tmenu_lastpanx) < TT_PAN_STEP && abs(tmenu_pany - tmenu_lastpany) < TT_PAN_STEP) return
	tmenu_lastpanx = tmenu_panx
	tmenu_lastpany = tmenu_pany
	RepositionTree()

client/proc/TTPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (tt_atx - 1) * 32   // panel default bottom-left, absolute px
	var/by = (tt_aty - 1) * 32
	var/minx = -bx
	if(minx > 0) minx = 0
	var/maxx = vw * 32 - TT_W - bx
	if(maxx < 0) maxx = 0
	var/miny = -by
	if(miny > 0) miny = 0
	var/maxy = vh * 32 - TT_H - by
	if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/TTShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	// chrome + an open craft popup are small and always visible
	for(var/atom/movable/o in tmenu_chrome)
		if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(craft_desc_objs)
		for(var/atom/movable/o in craft_desc_objs)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(tmenu_tabobjs)
		for(var/atom/movable/o in tmenu_tabobjs)
			if(o.alpha && o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/TTPanelStart(params)
	tt_pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	tt_pan_mx = m[1]; tt_pan_my = m[2]
	tt_pan_ox = tt_pan_x; tt_pan_oy = tt_pan_y

client/proc/TTPanelMove(params)
	if(!tmenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = TTPanBounds()
	var/wantx = clamp(tt_pan_ox + (m[1] - tt_pan_mx), b[1], b[2])
	var/wanty = clamp(tt_pan_oy + (m[2] - tt_pan_my), b[3], b[4])
	var/dx = wantx - tt_pan_x
	var/dy = wanty - tt_pan_y
	if(!dx && !dy) return
	tt_pan_x = wantx; tt_pan_y = wanty
	tt_pan_dragged = TRUE
	TTShiftLive(dx, dy)

client/proc/TTPanelEnd()
	if(!tt_pan_dragged) return
	tt_pan_dragged = FALSE
	RepositionTree()   // self-guards to the tree tab; re-syncs the culled/off-view nodes to the new position
	setPref("ttPanX", tt_pan_x)
	setPref("ttPanY", tt_pan_y)

client/proc/TT_CanvasW()
	var/maxc = 0
	for(var/n in TechTreeLayout)
		var/list/e = TechTreeLayout[n]
		if(e[1] > maxc) maxc = e[1]
	return maxc * TT_COL_W

client/proc/TT_CanvasH()
	var/maxr = 0
	for(var/n in TechTreeLayout)
		var/list/e = TechTreeLayout[n]
		if(e[2] > maxr) maxr = e[2]
	return maxr * TT_ROW_H

client/proc/CraftSectionsFor(filter)
	var/list/out = list()
	var/list/learned = mob.knowledgeTracker.learnedKnowledge
	if(filter == "all" || filter == TT_FAM_MISC)
		out += list(CraftSection("Basic Technology", BasicTechnology_List, learned, 1))
	if(filter == "all" || filter == TT_FAM_FORGE)
		out += list(CraftSection("Forging", Forging_List, learned, mob.ForgingUnlocked))
		out += list(CraftSection("Repair & Conversion", RepairAndConversion_List, learned, mob.RepairAndConversionUnlocked))
		out += list(CraftSection("Engineering", Engineering_List, learned, mob.EngineeringUnlocked))
	if(filter == "all" || filter == TT_FAM_CYBER)
		out += list(CraftSection("Cyber Engineering", CyberEngineering_List, learned, mob.CyberEngineeringUnlocked))
	if(filter == "all" || filter == TT_FAM_MED)
		out += list(CraftSection("Medicine", Medicine_List, learned, mob.MedicineUnlocked))
		out += list(CraftSection("Improved Medical", ImprovedMedicalTechnology_List, learned, mob.ImprovedMedicalTechnologyUnlocked))
	if(filter == "all" || filter == TT_FAM_TELE)
		out += list(CraftSection("Telecommunications", Telecommunications_List, learned, mob.TelecommunicationsUnlocked))
		out += list(CraftSection("Adv. Transmission", AdvancedTransmissionTechnology_List, learned, mob.AdvancedTransmissionTechnologyUnlocked))
	if(filter == "all" || filter == TT_FAM_MIL)
		out += list(CraftSection("Military Technology", MilitaryTechnology_List, learned, mob.MilitaryTechnologyUnlocked))
		out += list(CraftSection("Military Engineering", MilitaryEngineering_List, learned, mob.MilitaryEngineeringUnlocked))
	if(filter == "all" || filter == TT_FAM_FORGE || filter == TT_FAM_MIL)
		out += list(CraftSection("Power Packs", PowerPack_List, learned, (mob.EngineeringUnlocked || mob.MilitaryTechnologyUnlocked)))
	var/list/clean = list()
	for(var/list/sec in out)
		if(sec["items"].len) clean += list(sec)
	return clean

client/proc/CraftSection(label, list/src_list, list/learned, unlocked)
	var/list/items = list()
	if(unlocked && src_list)
		for(var/obj/Items/it in src_list)
			if(it.Unobtainable) continue
			if(it.SubType == "Any" || isnull(it.SubType) || (it.SubType in learned))
				items += it
	return list("label" = label, "items" = items)

#define TT_CRAFT_ROWS 8
#define TT_CRAFT_RH 26
client/proc/BuildCraft()
	ClearList(tmenu_tabobjs)
	tmenu_tabobjs = list()
	tmenu_selobj = null
	tmenu_infoname = null
	tmenu_info = null
	tmenu_learn = null
	tmenu_nodes = null

	BuildCraftChips()

	// framed list box
	var/atom/movable/shud/ttbg/lbox = new
	lbox.icon = 'HUD/tech_listpanel.png'
	lbox.layer = TT_LAYER + 0.3
	lbox.mouse_opacity = 0
	lbox.screen_loc = TTloc(14, 84, 250)
	tmenu_tabobjs += lbox

	var/list/sections = CraftSectionsFor(tmenu_filter)
	var/list/rows = list()
	for(var/list/sec in sections)
		rows += list(list("type" = "head", "label" = sec["label"]))
		for(var/obj/Items/it in sec["items"])
			rows += list(list("type" = "item", "obj" = it))

	var/pages = 1
	while(pages * TT_CRAFT_ROWS < rows.len) pages++
	tmenu_craftpage = clamp(tmenu_craftpage, 1, pages)
	var/start = (tmenu_craftpage - 1) * TT_CRAFT_ROWS

	var/y = 98
	for(var/k = 1 to TT_CRAFT_ROWS)
		var/idx = start + k
		if(idx > rows.len) break
		var/list/r = rows[idx]
		if(r["type"] == "head")
			var/atom/movable/shud/tttext/h = new
			h.maptext_width = 560
			h.maptext_height = 16
			h.screen_loc = TTloc(30, y + 2, 16)
			h.maptext = "<span style=\"[TT_FONT]; color:#8be9ff\">[r["label"]]</span>"
			tmenu_tabobjs += h
		else
			var/obj/Items/it = r["obj"]
			var/atom/movable/shud/ttcraftrow/row = new
			row.catalog = it
			row.icon = 'HUD/tt_rowhit.png'
			row.screen_loc = TTloc(30, y, TT_CRAFT_RH)
			tmenu_tabobjs += row
			var/icon/icn = icon(it.icon, it.icon_state)
			icn.Scale(16, 16)
			var/atom/movable/shud/ttpic/ic = new
			ic.icon = icn
			ic.layer = TT_LAYER + 0.46
			ic.screen_loc = TTloc(38, y + 5, 16)
			tmenu_tabobjs += ic
			var/atom/movable/shud/tttext/nm = new
			nm.maptext_width = 300
			nm.maptext_height = 16
			nm.screen_loc = TTloc(62, y + 5, 16)
			nm.maptext = "<span style=\"[TT_FONT]; color:#ffffff\">[it.name]</span>"
			tmenu_tabobjs += nm
			var/datum/craft_recipe/rec = GetTechRecipe(it)
			var/atom/movable/shud/tttext/ct = new
			ct.maptext_width = 140
			ct.maptext_height = 16
			ct.screen_loc = TTloc(470, y + 5, 16)
			ct.maptext = "<span style=\"[TT_FONT]; color:#9be7a0\">[Commas(round(rec.MoneyCost(mob, it)))]</span>"
			tmenu_tabobjs += ct
		y += TT_CRAFT_RH

	BuildCraftPager(pages)

	for(var/atom/movable/o in tmenu_tabobjs)
		if(o in screen) continue
		screen += o
	RefreshBalance()

client/proc/BuildCraftChips()
	var/list/fams = list("all" = "All", TT_FAM_FORGE = "Forge", TT_FAM_CYBER = "Cyber", \
		TT_FAM_MED = "Medicine", TT_FAM_TELE = "Telecom", TT_FAM_MIL = "Military", TT_FAM_MISC = "Basic")
	var/cx = 18
	for(var/key in fams)
		var/atom/movable/shud/ttbtn/chip = new
		chip.icon = (tmenu_filter == key) ? 'HUD/ui_tab_active.png' : 'HUD/ui_tab_idle.png'
		chip.action = "filter"
		chip.arg = key
		chip.screen_loc = TTloc(cx, 50, 32)
		tmenu_tabobjs += chip
		var/atom/movable/shud/ttlabel/cl = new
		cl.maptext_width = 84
		cl.maptext_height = 16
		cl.screen_loc = TTloc(cx, 56, 16)
		cl.maptext = "<center><span style=\"[TT_FONT]; color:[tmenu_filter == key ? "#06283b" : "#cfe3f5"]\">[fams[key]]</span></center>"
		tmenu_tabobjs += cl
		cx += 84

client/proc/BuildCraftPager(pages)
	if(pages <= 1) return
	var/atom/movable/shud/ttwidget/prev = new
	prev.widget_kind = "arrow_left"
	prev.icon = 'HUD/ui_arrow_left_1.png'
	prev.action = "craftpage"; prev.ttarg = -1
	prev.screen_loc = TTloc(258, 312, 18)
	tmenu_tabobjs += prev
	var/atom/movable/shud/ttlabel/pt = new
	pt.maptext_width = 60
	pt.maptext_height = 16
	pt.screen_loc = TTloc(282, 314, 16)
	pt.maptext = "<center><span style=\"[TT_FONT]; color:#ffffff\">[tmenu_craftpage]/[pages]</span></center>"
	tmenu_tabobjs += pt
	var/atom/movable/shud/ttwidget/nxt = new
	nxt.widget_kind = "arrow_right"
	nxt.icon = 'HUD/ui_arrow_right_1.png'
	nxt.action = "craftpage"; nxt.ttarg = 1
	nxt.screen_loc = TTloc(348, 312, 18)
	tmenu_tabobjs += nxt

client/proc/TechCraftMake(obj/Items/catalog)
	if(!catalog) return
	spawn()
		var/datum/craft_recipe/rec = GetTechRecipe(catalog)
		var/cost = rec.MoneyCost(mob, catalog)
		var/confirm = alert(mob, "Craft [catalog.name] for [Commas(round(cost))]?", "Craft", "Craft", "Cancel")
		if(confirm != "Craft") return
		mob.CraftTechItem(catalog)
		RefreshBalance()
		if(tmenu_open && tmenu_tab == "craft") BuildCraft()

client/proc/ShowCraftDesc(obj/Items/I)
	HideCraftDesc()
	if(!I || !tmenu_open) return
	craft_desc_objs = list()
	craft_desc_item = I

	var/atom/movable/shud/craftdescpanel/P = new
	P.icon = 'HUD/inv_desc.png'
	P.screen_loc = TTloc(212, 22, 300)
	craft_desc_objs += P

	var/icon/pi = icon(I.icon, I.icon_state)
	pi.Scale(36, 36)
	var/atom/movable/shud/ttpic/pic = new
	pic.icon = pi
	pic.color = I.color
	pic.layer = TT_LAYER + 1.1
	pic.screen_loc = TTloc(294, 48, 36)
	craft_desc_objs += pic

	var/atom/movable/shud/ttlabel/nm = new
	nm.layer = TT_LAYER + 1.1
	nm.maptext_width = 176
	nm.maptext_height = 16
	nm.screen_loc = TTloc(224, 92, 16)
	nm.maptext = "<center><span style=\"[TT_FONT]; color:#ffffff\">[I.name]</span></center>"
	craft_desc_objs += nm

	if(I.UpdatesDescription) I:Update_Description()
	var/body = I.desc ? I.desc : "No description."
	var/atom/movable/shud/tttext/T = new
	T.layer = TT_LAYER + 1.1
	T.maptext_width = 168
	T.maptext_height = 190
	T.screen_loc = TTloc(228, 114, 190)
	T.maptext = "<span style=\"[TT_FONT_BODY]; color:#dbe6f5\">[body]</span>"
	craft_desc_objs += T

	for(var/atom/movable/o in craft_desc_objs)
		screen += o
	KineticEntrance(craft_desc_objs)

client/proc/HideCraftDesc()
	craft_desc_item = null
	if(craft_desc_objs)
		while(craft_desc_objs.len)
			var/atom/movable/o = craft_desc_objs[craft_desc_objs.len]
			craft_desc_objs.len--
			screen -= o
			del o
		craft_desc_objs = null
