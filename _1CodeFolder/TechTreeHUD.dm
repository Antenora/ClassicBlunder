#ifndef TT_SHAPE_ROUND
#define TT_SHAPE_ROUND   "round"
#define TT_SHAPE_DIAMOND "diamond"
#define TT_SHAPE_LARGE   "large"
#define TT_FAM_ENGINEER  "engineer"
#define TT_FAM_OPERATIVE "operative"
#define TT_FAM_GUNSMITH  "gunsmith"
#define TT_FAM_MECHANIST "mechanist"
#define TT_FAM_CYBER     "cyber"
#define TT_FAM_MEDIC     "medic"
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
	TT_FAM_ENGINEER = "#ff9a3c", TT_FAM_OPERATIVE = "#37c4ff", TT_FAM_GUNSMITH = "#ff5a5a",
	TT_FAM_MECHANIST = "#ffd86b", TT_FAM_CYBER = "#b46bff", TT_FAM_MEDIC = "#5bd75b")
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
	var/tmp/seg_req
	var/tmp/seg_child

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
		tmenu_pan_init = 0
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
		tmenu_selanim = 0
		atom/movable/shud/menubtn/btn_tech
		atom/movable/shud/menulabel/btn_tech_label
		atom/movable/shud/panelholder/tt_holder
		atom/movable/shud/panelholder/tt_tree_page
		atom/movable/shud/panelholder/tt_craft_page
		list/tmenu_treeobjs
		list/tmenu_craftobjs
		atom/movable/shud/ttbtn/tmenu_bench
		atom/movable/shud/tttext/tmenu_craft_body

client/proc/TTloc(dx, dyTop, h = 0)
	var/py = TT_H - dyTop - h
	var/ax = dx + tt_pan_x
	var/ay = py + tt_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[tt_atx + (ax - axp) / 32]:[axp],[tt_aty + (ay - ayp) / 32]:[ayp]"

client/proc/TTput(atom/movable/H, atom/movable/o, dx, dyTop, h = 0)
	o.pixel_x = dx
	o.pixel_y = TT_H - dyTop - h
	if(H) H.vis_contents += o

client/proc/TTmove(atom/movable/o, dx, dyTop, h = 0)
	var/py = TT_H - dyTop - h
	if(o.pixel_x != dx) o.pixel_x = dx
	if(o.pixel_y != py) o.pixel_y = py

client/proc/TTholderSync()
	PanelMoveTo(tt_holder, (tt_atx - 1) * 32 + tt_pan_x, (tt_aty - 1) * 32 + tt_pan_y)


client/proc/InitTechButton()
	btn_tech = new('HUD/ui_icon_skills.png')
	btn_tech.btn_id = "tech"
	RepositionTopStrip()
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
	CloseMenu(); CloseInventory(); CloseCharacterMenu(); CloseSkillMenu(); CloseAcquireMenu(); CloseLifeSkillsMenu(); CloseStationMenu()
	CloseArcaneMenu()
	CloseArcaneAcquire(0)
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
	if(!tmenu_pan_init)
		tmenu_pan_init = 1
		TechDefaultPan()

	if(btn_tech)
		btn_tech.icon = 'HUD/ui_slot_unavailable.png'
		btn_tech.SetGlyphDimmed(TRUE)
	if(btn_tech_label) btn_tech_label.alpha = 0

	tt_holder = PanelHolderNew(TT_LAYER)
	TTholderSync()
	BuildTechChrome()
	ShowTechTab(tmenu_tab, FALSE)
	screen += tt_holder
	PanelFade(tt_holder)

client/proc/CloseTechMenu()
	tmenu_open = 0
	HideCraftDesc()
	PanelRelease(tt_tree_page)
	PanelRelease(tt_craft_page)
	PanelRelease(tt_holder)
	tt_holder = null
	tt_tree_page = null
	tt_craft_page = null
	tmenu_treeobjs = null
	tmenu_craftobjs = null
	tmenu_bench = null
	tmenu_craft_body = null
	tmenu_tabobjs = null
	tmenu_chrome = null
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
	TTput(tt_holder, b, dxLeft, dyTop, h)
	store += b
	var/atom/movable/shud/ttlabel/L = new
	L.maptext_width = w
	L.maptext_height = 16
	TTput(tt_holder, L, dxLeft, dyTop + round((h - 16) / 2) - 2, 16)
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
	TTput(tt_holder, P, 0, 0, TT_H)
	tmenu_chrome += P

	var/atom/movable/shud/ttbg/tp = new
	tp.icon = 'HUD/tech_titleplate.png'
	tp.layer = TT_LAYER + 0.3
	tp.mouse_opacity = 0
	TTput(tt_holder, tp, 212, 6, 32)
	tmenu_chrome += tp
	var/atom/movable/shud/ttlabel/title = new
	title.maptext_width = 200
	title.maptext_height = 16
	TTput(tt_holder, title, 212, 12, 16)
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
	TTput(tt_holder, X, 590, 12, 24)
	tmenu_chrome += X

	// balance: RPP   [money icon] count
	tmenu_rpp_label = new
	tmenu_rpp_label.maptext_width = 80
	tmenu_rpp_label.maptext_height = 16
	TTput(tt_holder, tmenu_rpp_label, 426, 14, 16)
	tmenu_chrome += tmenu_rpp_label

	var/icon/mi = icon('money.dmi'); mi.Scale(16, 16)
	var/atom/movable/shud/ttpic/micon = new
	micon.icon = mi
	micon.layer = TT_LAYER + 0.5
	TTput(tt_holder, micon, 500, 14, 16)
	tmenu_chrome += micon

	tmenu_money_label = new
	tmenu_money_label.maptext_width = 76
	tmenu_money_label.maptext_height = 16
	TTput(tt_holder, tmenu_money_label, 520, 14, 16)
	tmenu_chrome += tmenu_money_label

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

client/proc/ShowTechTab(tab, fade = TRUE)
	if(!tmenu_open) return
	HideCraftDesc()
	tmenu_tab = tab
	tmenu_selobj = null
	RefreshTabLook()
	if(tt_tree_page) tt_holder.vis_contents -= tt_tree_page
	if(tt_craft_page) tt_holder.vis_contents -= tt_craft_page
	var/atom/movable/page = (tab == "tree") ? BuildTree() : BuildCraft()
	tt_holder.vis_contents += page
	if(fade) PanelFade(page)

client/proc/TechButton(action, arg)
	switch(action)
		if("close") CloseTechMenu()
		if("tab_tree") ShowTechTab("tree")
		if("tab_craft") ShowTechTab("craft")
		if("learn") TechLearnSelected()
		if("field")
			CloseTechMenu()
			TechFieldCraftOpen()
		if("bench")
			var/obj/LifeSkills/Station/Workbench/W = TechAdjacentWorkbench()
			if(!W)
				if(mob) mob << "You need to be next to a Workbench."
				return
			CloseTechMenu()
			LifeCraftOpen(W)

client/proc/TTOriginDx()  return TT_VP_L + TT_MARGIN - tmenu_panx
client/proc/TTOriginDyT() return TT_VP_T + TT_MARGIN - tmenu_pany

client/proc/TechFirstNode()
	var/best
	var/bc = 0
	var/br = 0
	for(var/n in TechTreeLayout)
		var/list/e = TechTreeLayout[n]
		if(!e) continue
		if(isnull(best) || e[1] < bc || (e[1] == bc && e[2] < br))
			best = n; bc = e[1]; br = e[2]
	return best

client/proc/TechDefaultPan()
	var/list/e = TechTreeLayout[TechFirstNode()]
	if(!e) return
	tmenu_panx = clamp(TT_VP_L + TT_MARGIN + e[1] * TT_COL_W - round((TT_VP_L + TT_VP_R) / 2), 0, TT_CanvasW())
	tmenu_pany = clamp(TT_VP_T + TT_MARGIN + e[2] * TT_ROW_H - round((TT_VP_T + TT_VP_B) / 2), 0, TT_CanvasH())

client/proc/BuildTree()
	if(tt_tree_page)
		for(var/nm in tmenu_nodes)
			StyleNode(tmenu_nodes[nm], TechnologyTree[nm])
		RefreshConnectors()
	else
		tt_tree_page = PanelHolderNew(TT_LAYER)
		tmenu_treeobjs = list()
		tmenu_nodes = list()

		var/atom/movable/shud/ttbg/ibox = new
		ibox.icon = 'HUD/tech_infobar.png'
		ibox.layer = TT_LAYER + 0.32
		ibox.mouse_opacity = 0
		TTput(tt_tree_page, ibox, 14, TT_BAR_T - 6, 86)
		tmenu_treeobjs += ibox

		var/atom/movable/shud/ttbg/band = new
		band.icon = 'HUD/tt_band.png'
		band.alpha = 200
		band.layer = TT_LAYER + 0.4
		band.mouse_opacity = 0
		TTput(tt_tree_page, band, 22, TT_BAR_T + 4, TT_BAND_H)
		tmenu_treeobjs += band

		tmenu_infoname = new
		tmenu_infoname.maptext_width = 400
		tmenu_infoname.maptext_height = 16
		TTput(tt_tree_page, tmenu_infoname, 30, TT_BAR_T + 8, 16)
		tmenu_treeobjs += tmenu_infoname

		tmenu_info = new
		tmenu_info.maptext_width = 560
		tmenu_info.maptext_height = 40
		TTput(tt_tree_page, tmenu_info, 30, TT_BAR_T + 34, 40)
		tmenu_treeobjs += tmenu_info

		tmenu_learn = new
		tmenu_learn.icon = 'HUD/cust_button.png'
		tmenu_learn.action = "learn"
		tmenu_learn.layer = TT_LAYER + 0.45
		TTput(tt_tree_page, tmenu_learn, 444, TT_BAR_T + 3, 26)
		tmenu_treeobjs += tmenu_learn
		tmenu_learn_lbl = new
		tmenu_learn_lbl.maptext_width = 150
		tmenu_learn_lbl.maptext_height = 16
		TTput(tt_tree_page, tmenu_learn_lbl, 444, TT_BAR_T + 8, 16)
		tmenu_treeobjs += tmenu_learn_lbl

		var/atom/movable/shud/ttpan/pan = new
		TTput(tt_tree_page, pan, TT_VP_L, TT_VP_T, TT_VP_B - TT_VP_T)
		tmenu_treeobjs += pan

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
			tmenu_treeobjs += nd
			tt_tree_page.vis_contents += nd

		for(var/n in TechnologyTree)
			var/knowledgePaths/tech/t = TechnologyTree[n]
			if(t.name == "Not Obtainable") continue
			var/list/ce = TechTreeLayout[t.name]
			if(!ce) continue
			var/owned_child = (t.name in mob.knowledgeTracker.learnedKnowledge)
			for(var/req in (t.requires + t.requires_any))
				var/list/pe = TechTreeLayout[req]
				if(!pe) continue
				var/lit = owned_child || (req in mob.knowledgeTracker.learnedKnowledge)
				BuildConnector(pe[1], pe[2], ce[1], ce[2], lit, req, t.name)

	tmenu_tabobjs = tmenu_treeobjs
	tmenu_lastpanx = tmenu_panx
	tmenu_lastpany = tmenu_pany
	RepositionTree()
	if(tmenu_sel) SetSelector(tmenu_sel)
	RefreshInfoBar()
	return tt_tree_page

client/proc/RefreshConnectors()
	var/list/learned = mob.knowledgeTracker.learnedKnowledge
	for(var/atom/movable/shud/ttline/L in tmenu_treeobjs)
		var/lit = (L.seg_child in learned) || (L.seg_req in learned)
		L.color = lit ? TT_LINE_LIT : TT_LINE_DIM
		L.base_alpha = lit ? 255 : 150

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

client/proc/BuildConnector(pcol, prow, ccol, crow, lit, req, child)
	var/x1 = pcol * TT_COL_W, y1 = prow * TT_ROW_H
	var/x2 = ccol * TT_COL_W, y2 = crow * TT_ROW_H
	if(x1 != x2) AddSeg((x1 + x2) / 2, y1, abs(x2 - x1), 1, lit, req, child)
	if(y1 != y2) AddSeg(x2, (y1 + y2) / 2, abs(y2 - y1), 0, lit, req, child)

client/proc/AddSeg(ccx, ccy, len, horizontal, lit, req, child)
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
	L.seg_req = req
	L.seg_child = child
	tmenu_treeobjs += L
	tt_tree_page.vis_contents += L

client/proc/RepositionTree()
	if(!tmenu_open || tmenu_tab != "tree") return
	var/odx = TTOriginDx(), odyt = TTOriginDyT()
	var/park = 4
	for(var/atom/movable/shud/ttline/L in tmenu_treeobjs)
		var/scx = odx + L.ccx, scy = odyt + L.ccy
		if(L.horiz)
			if(scy < TT_VP_T || scy > TT_VP_B)
				if(L.alpha) L.alpha = 0
				TTmove(L, park, park, 0)
				continue
			var/cl = max(scx - L.cw / 2, TT_VP_L), cr = min(scx + L.cw / 2, TT_VP_R)
			if(cr <= cl)
				if(L.alpha) L.alpha = 0
				TTmove(L, park, park, 0)
				continue
			if(L.alpha != L.base_alpha) L.alpha = L.base_alpha
			L.transform = matrix((cr - cl) / 16, 0, 0, 0, 1, 0)
			TTmove(L, round((cl + cr) / 2) - 8, scy - 8, 16)
		else
			if(scx < TT_VP_L || scx > TT_VP_R)
				if(L.alpha) L.alpha = 0
				TTmove(L, park, park, 0)
				continue
			var/ct = max(scy - L.ch / 2, TT_VP_T), cb = min(scy + L.ch / 2, TT_VP_B)
			if(cb <= ct)
				if(L.alpha) L.alpha = 0
				TTmove(L, park, park, 0)
				continue
			if(L.alpha != L.base_alpha) L.alpha = L.base_alpha
			L.transform = matrix(1, 0, 0, 0, (cb - ct) / 16, 0)
			TTmove(L, scx - 8, round((ct + cb) / 2) - 8, 16)
	for(var/name in tmenu_nodes)
		var/atom/movable/shud/ttnode/nd = tmenu_nodes[name]
		var/cx = odx + nd.node_col * TT_COL_W
		var/cy = odyt + nd.node_row * TT_ROW_H
		// 16px inset so a node never half-bleeds past the viewport (no covers)
		if(cx < TT_VP_L + 16 || cx > TT_VP_R - 16 || cy < TT_VP_T + 16 || cy > TT_VP_B - 16)
			nd.alpha = 0
			nd.mouse_opacity = 0
			TTmove(nd, park, park, 0)
			continue
		nd.mouse_opacity = 2
		var/sz = (TechNodeShape(TechnologyTree[name]) == TT_SHAPE_LARGE) ? TT_NODE_LG : TT_NODE
		TTmove(nd, cx - sz / 2, cy - sz / 2, sz)
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
	var/need = mob.TechNodeRankNeeded(t)
	var/hasrank = (mob.LifeRank("Technology") >= need)
	var/famcol = TT_FAM_COLOR[TechNodeFamily(t.name)]
	var/reqs = (t.requires.len || t.requires_any.len) ? t.ReqLine() : "None"
	var/unlocks = t.unlocks ? t.unlocks : "Nothing further"
	var/status
	if(owned) status = "<span style=\"color:#9be7a0\">LEARNED</span>"
	else if(!avail) status = "<span style=\"color:#ff7a7a\">LOCKED</span>"
	else status = "<span style=\"color:#ffd86b\">[cost] RPP</span> &nbsp; <span style=\"color:[hasrank ? "#9be7a0" : "#ff7a7a"]\">RANK [need]</span>"
	tmenu_infoname.maptext = "<span style=\"[TT_FONT]; color:[famcol]\">[t.name]</span> &nbsp;&nbsp; <span style=\"[TT_FONT]\">[status]</span>"
	tmenu_info.maptext = "<span style=\"[TT_FONT_BODY]; color:#bcd0e8\">[t.bench] &middot; Requires: [reqs]<br>Unlocks: [unlocks]<br>[t.description]</span>"
	if(tmenu_learn)
		var/can = (!owned && avail && hasrank && mob.CanAffordTechNode(t))
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
	TTholderSync()

client/proc/TTPanelEnd()
	if(!tt_pan_dragged) return
	tt_pan_dragged = FALSE
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

client/proc/TechFieldCraftOpen(recipe_id)
	if(mob) mob << "Field crafting is not ready yet."

client/proc/TechAdjacentWorkbench()
	if(!mob) return null
	for(var/obj/LifeSkills/Station/Workbench/W in range(1, mob))
		return W
	return null

client/proc/BuildCraft()
	if(!tt_craft_page)
		tt_craft_page = PanelHolderNew(TT_LAYER)
		tmenu_craftobjs = list()

		var/atom/movable/shud/ttbg/lbox = new
		lbox.icon = 'HUD/tech_listpanel.png'
		lbox.layer = TT_LAYER + 0.3
		lbox.mouse_opacity = 0
		TTput(tt_craft_page, lbox, 14, 84, 250)
		tmenu_craftobjs += lbox

		var/atom/movable/shud/tttext/h = new
		h.maptext_width = 560
		h.maptext_height = 16
		TTput(tt_craft_page, h, 30, 100, 16)
		h.maptext = "<span style=\"[TT_FONT]; color:#8be9ff\">Craft at a Workbench</span>"
		tmenu_craftobjs += h

		tmenu_craft_body = new
		tmenu_craft_body.maptext_width = 560
		tmenu_craft_body.maptext_height = 48
		TTput(tt_craft_page, tmenu_craft_body, 30, 124, 48)
		tmenu_craftobjs += tmenu_craft_body

		TTCraftButton("field", "FIELD CRAFTS", 30, 184, TRUE)
		tmenu_bench = TTCraftButton("bench", "OPEN WORKBENCH", 196, 184, FALSE)
	tmenu_craft_body.maptext = "<span style=\"[TT_FONT_BODY]; color:#dbe6f5\">Everything Technology makes is built at a Workbench. Stand next to one and press [mob.InteractKeyName()], or click it.<br>Field crafts need no bench and are made in batches anywhere.</span>"
	var/bench_shown = (tmenu_bench in tt_craft_page.vis_contents)
	if(TechAdjacentWorkbench())
		if(!bench_shown)
			tt_craft_page.vis_contents += tmenu_bench
			tt_craft_page.vis_contents += tmenu_bench.lbl
	else if(bench_shown)
		tt_craft_page.vis_contents -= tmenu_bench
		tt_craft_page.vis_contents -= tmenu_bench.lbl
	tmenu_tabobjs = tmenu_craftobjs
	RefreshBalance()
	return tt_craft_page

client/proc/TTCraftButton(action, label, dx, dyTop, show)
	var/atom/movable/shud/ttbtn/b = new
	b.icon = 'HUD/cust_button.png'
	b.action = action
	TTput(show ? tt_craft_page : null, b, dx, dyTop, 26)
	tmenu_craftobjs += b
	var/atom/movable/shud/ttlabel/L = new
	L.maptext_width = 150
	L.maptext_height = 16
	TTput(show ? tt_craft_page : null, L, dx, dyTop + 5, 16)
	L.maptext = "<center><span style=\"[TT_FONT]; color:#8be9ff\">[label]</span></center>"
	tmenu_craftobjs += L
	b.lbl = L
	return b

client/proc/HideCraftDesc()
	craft_desc_item = null
	if(craft_desc_objs)
		while(craft_desc_objs.len)
			var/atom/movable/o = craft_desc_objs[craft_desc_objs.len]
			craft_desc_objs.len--
			screen -= o
			del o
		craft_desc_objs = null
