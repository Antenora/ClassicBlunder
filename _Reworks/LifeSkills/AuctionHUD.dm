// Auction House trading floor menu. Bulk all lives in auction.dm.

#define AH_LAYER (FLY_LAYER + 3.9)
#define AH_W 624
#define AH_H 344
#define AH_ROWS 8
#define AH_ROW_Y 106
#define AH_ROW_P 24
#define AH_FONT "font-family:'monogram'; font-size:12pt"
#define AH_FONT_BODY "font-family:'Pixel Operator 8'; font-size:6pt"
#define AH_C_HINT "#7a9bb5"
#define AH_C_GOLD "#ffd86b"
#define AH_C_OK "#78eb78"
#define AH_C_BAD "#ff6464"
#define AH_C_TXT "#cfe3f5"
#define AH_C_CYAN "#8be9ff"
#define AH_DUR_12H 432000
#define AH_DUR_24H 864000
#define AH_DUR_48H 1728000

/atom/movable/shud/ahbg
	layer = AH_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr && usr.client) usr.client.AhPanelStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr && usr.client) usr.client.AhPanelMove(params)
	MouseUp(location, control, params)
		if(usr && usr.client) usr.client.AhPanelEnd()

/atom/movable/shud/ahpic
	layer = AH_LAYER + 0.3
	mouse_opacity = 0

/atom/movable/shud/ahtext
	layer = AH_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/ahbtn
	layer = AH_LAYER + 0.6
	mouse_opacity = 2
	var/action
	var/arg
	var/atom/movable/shud/ahtext/lbl
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.AhButton(action, arg)

/atom/movable/shud/ahrow
	layer = AH_LAYER + 0.35
	mouse_opacity = 2
	var/rkind = ""             // listing | pick | sellitem | selllot
	var/rid = 0                // listing id / pick option index
	var/obj/Items/ritem
	var/rmc = ""
	var/rq = 0
	var/issel = 0
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = issel ? filter(type="drop_shadow", x=0, y=0, size=2, color="#ffd86b") : null
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.AhRowInspect(src)
			return
		usr.client.AhRowClick(src)

/atom/movable/shud/ahwidget          // pressable close X
	parent_type = /atom/movable/shud/pressbtn
	layer = AH_LAYER + 0.65
	mouse_opacity = 2
	DoAction()
		if(usr && usr.client) usr.client.AhButton(action, null)

/atom/movable/shud/ahconfirm
	layer = AH_LAYER + 1.1
	mouse_opacity = 2
	var/act
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.AhOverlayAction(act)

// read-only gear popup, click it to close
/atom/movable/shud/ahdesc
	layer = AH_LAYER + 1.3
	mouse_opacity = 2
	Click()
		if(usr && usr.client) usr.client.AhInspectClose()

/atom/movable/shud/ahdesctext
	layer = AH_LAYER + 1.35
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

client
	var/tmp
		ahmenu_open = 0
		obj/AuctionHouse/ah_hall
		ah_mode = "browse"         // browse | sell | mine | bids | trends
		ah_pick = ""               // cat | qual | metal | gem | mmat | sort
		ah_sel = 0
		ah_scroll = 0
		ah_f_cat = ""
		ah_f_qual = 0
		ah_f_metal = ""
		ah_f_gem = ""
		ah_f_mmat = ""
		ah_f_search = ""
		ah_sort = 1
		ah_trend_pkey = ""
		ah_trend_label = ""
		ah_prev_mode = "browse"
		ah_flow = 0
		ah_atx = 1
		ah_aty = 1
		ah_pan_x = 0
		ah_pan_y = 0
		ah_pan_mx = 0
		ah_pan_my = 0
		ah_pan_ox = 0
		ah_pan_oy = 0
		ah_pan_dragged = 0
		list/ah_chrome
		list/ah_page
		list/ah_modebtns
		list/ah_confirm_objs
		ah_confirm_kind = ""
		list/ah_confirm_a
		list/ah_type_objs
		ah_pend_mode = ""
		obj/Items/ah_pend_item
		ah_pend_mc = ""
		ah_pend_q = 0
		ah_pend_n = 0
		ah_pend_ask = 0
		list/ah_desc_objs

client/proc/AHloc(dx, dyTop, h = 0)
	var/py = AH_H - dyTop - h
	var/ax = dx + ah_pan_x
	var/ay = py + ah_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[ah_atx + (ax - axp) / 32]:[axp],[ah_aty + (ay - ayp) / 32]:[ayp]"

client/proc/AhAdd(atom/movable/o, chrome = 0)
	if(chrome)
		if(!ah_chrome) ah_chrome = list()
		ah_chrome += o
	else
		if(!ah_page) ah_page = list()
		ah_page += o
	screen += o

client/proc/AhText(dx, dyTop, w, h, txt, chrome = 0, lay = 0.6)
	var/atom/movable/shud/ahtext/T = new
	T.layer = AH_LAYER + lay
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = AHloc(dx, dyTop, h)
	T.maptext = txt
	AhAdd(T, chrome)
	return T

client/proc/AhBtn(label, action, arg, dx, dyTop, w, h = 18, tcol = "#8be9ff")
	var/atom/movable/shud/ahbtn/b = new
	var/ic = LogBtnIcon(w, h)
	if(!ic && w == 100 && h == 24) ic = 'HUD/np_btn.png'
	b.icon = ic ? ic : AqCoverIcon(w, h)
	b.action = action
	b.arg = arg
	b.screen_loc = AHloc(dx, dyTop, h)
	AhAdd(b, 0)
	AhText(dx, dyTop + round((h - 8) / 2) - 5, w, 14, "<center><span style=\"[AH_FONT_BODY]; color:[tcol]\">[label]</span></center>", 0, 0.62)
	return b

// open / close

client/proc/OpenAhMenu(obj/AuctionHouse/hall)
	if(ahmenu_open) CloseAhMenu()
	if(!mob) return
	CloseMenu()
	CloseInventory()
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	CloseStationMenu()
	CloseLifeSkillsMenu()
	CloseLogMenu()
	AuctionHouseLoad()
	ahmenu_open = 1
	ah_hall = hall
	ah_mode = "browse"
	ah_pick = ""
	ah_sel = 0
	ah_scroll = 0
	ah_flow = 0

	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(AH_W / 32); if(mtw * 32 < AH_W) mtw++
	var/mth = round(AH_H / 32); if(mth * 32 < AH_H) mth++
	ah_atx = max(1, round((vw - mtw) / 2) + 1)
	ah_aty = max(1, round((vh - mth) / 2) + 1)
	ah_pan_x = getPref("ahPanX"); if(isnull(ah_pan_x)) ah_pan_x = 0
	ah_pan_y = getPref("ahPanY"); if(isnull(ah_pan_y)) ah_pan_y = 0
	var/list/b = AHPanBounds()
	ah_pan_x = clamp(ah_pan_x, b[1], b[2])
	ah_pan_y = clamp(ah_pan_y, b[3], b[4])

	BuildAhChrome()
	RefreshAhPage()
	var/list/all = ah_chrome.Copy()
	if(ah_page) all += ah_page
	KineticEntrance(all)

client/proc/CloseAhMenu()
	if(!ahmenu_open && !ah_chrome) return
	ahmenu_open = 0
	ah_hall = null
	ah_flow = 0
	AhHideOverlay()
	AhHideTypeOverlay()
	AhInspectClose()
	ClearList(ah_page); ah_page = null
	ClearList(ah_chrome); ah_chrome = null
	ah_modebtns = null

client/proc/ResetAhHUD()
	CloseAhMenu()

client/proc/AhRangeOK()
	if(!ahmenu_open || !mob) return 0
	if(ah_hall && get_dist(mob, ah_hall) > 3)
		mob << "You've wandered from the auction hall."
		CloseAhMenu()
		return 0
	return 1

// chrome

client/proc/BuildAhChrome()
	ah_chrome = list()
	ah_modebtns = list()
	AhBG('HUD/tech_panel.png', 0, 0, AH_H, 0, 1)
	var/atom/movable/shud/ahpic/tp = new
	tp.icon = 'HUD/tech_titleplate.png'
	tp.layer = AH_LAYER + 0.3
	tp.screen_loc = AHloc(212, 6, 32)
	AhAdd(tp, 1)
	AhText(212, 12, 200, 16, "<center><span style=\"[AH_FONT]; color:#ffffff\">AUCTION HOUSE</span></center>", 1)
	var/atom/movable/shud/ahwidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.action = "close"
	X.screen_loc = AHloc(590, 12, 24)
	AhAdd(X, 1)
	// mode tabs
	var/tx = 18
	for(var/m in list("browse", "sell", "mine", "bids"))
		var/atom/movable/shud/ahbtn/b = new
		b.icon = 'HUD/log_tab.png'
		b.action = "mode"
		b.arg = m
		b.screen_loc = AHloc(tx, 44, 32)
		AhAdd(b, 1)
		ah_modebtns[m] = b
		var/atom/movable/shud/ahtext/L = new
		L.layer = AH_LAYER + 0.62
		L.maptext_width = 58
		L.maptext_height = 16
		L.screen_loc = AHloc(tx, 50, 16)
		AhAdd(L, 1)
		b.lbl = L
		tx += 60
	RefreshAhTabs()

client/proc/AhBG(icon_file, dx, dyTop, h, lay = 0.15, chrome = 0)
	var/atom/movable/shud/ahbg/o = new
	o.icon = icon_file
	o.layer = AH_LAYER + lay
	o.screen_loc = AHloc(dx, dyTop, h)
	AhAdd(o, chrome)
	return o

/proc/AhModeName(m)
	switch(m)
		if("browse") return "BROWSE"
		if("sell") return "SELL"
		if("mine") return "MINE"
		if("bids") return "BIDS"
	return uppertext(m)

client/proc/RefreshAhTabs()
	if(!ah_modebtns) return
	for(var/m in ah_modebtns)
		var/atom/movable/shud/ahbtn/b = ah_modebtns[m]
		if(!b) continue
		var/on = (ah_mode == m || (ah_mode == "trends" && m == ah_prev_mode))
		b.icon = on ? 'HUD/log_tab_on.png' : 'HUD/log_tab.png'
		if(b.lbl) b.lbl.maptext = "<center><span style=\"[AH_FONT]; color:[on ? "#06283b" : "#cfe3f5"]\">[AhModeName(m)]</span></center>"

// page refresh

client/proc/RefreshAhPage()
	ClearList(ah_page); ah_page = list()
	if(!ahmenu_open || !mob) return
	AuctionHouseLoad()
	AhText(18, 14, 200, 16, "<span style=\"[AH_FONT]; color:[AH_C_GOLD]\">GOLD $[Commas(AhMoneyOf(mob))]</span>", 0)
	var/list/BX = AuctionHouse.boxes[mob.ckey]
	AhBtn(BX && BX.len ? "BOX ([BX.len])" : "BOX", "box", null, 466, 10, 96, 24, BX && BX.len ? AH_C_GOLD : "#8be9ff")
	switch(ah_mode)
		if("browse") AhBuildBrowse()
		if("sell") AhBuildSell()
		if("mine") AhBuildMine()
		if("bids") AhBuildBids()
		if("trends") AhBuildTrends()

#define AH_RTY(y) ((y) + 2)   // band-row text baseline

client/proc/AhRowPlate(y)
	var/atom/movable/shud/ahpic/p = new
	p.icon = 'HUD/ah_band.png'
	p.layer = AH_LAYER + 0.32
	p.mouse_opacity = 0
	p.screen_loc = AHloc(20, y + 2, 18)
	AhAdd(p, 0)
	return p

client/proc/AhRowObj(y, rkind, rid = 0, obj/Items/ritem = null, rmc = "", rq = 0)
	var/atom/movable/shud/ahrow/r = new
	r.icon = 'HUD/ah_band.png'
	r.rkind = rkind
	r.rid = rid
	r.ritem = ritem
	r.rmc = rmc
	r.rq = rq
	r.screen_loc = AHloc(20, y + 2, 18)
	if(rkind == "listing" && rid && rid == ah_sel)
		r.issel = 1
		r.filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#ffd86b")
	AhAdd(r, 0)
	return r

client/proc/AhRowIcon(y, f, state, tint = null)
	var/atom/movable/shud/ahpic/ic = new
	ic.icon = StIcon16(f, state)
	if(tint) ic.color = tint
	ic.layer = AH_LAYER + 0.45
	ic.screen_loc = AHloc(28, y + 3, 16)
	AhAdd(ic, 0)
	return ic

// BROWSE

client/proc/AhChipLabel(kind)
	switch(kind)
		if("cat")
			if(!ah_f_cat) return "CAT"
			if(ah_f_cat == "Gear") return "GEAR"
			if(ah_f_cat == "Items") return "ITEMS"
			return AhTrunc(uppertext(ah_f_cat), 11)
		if("qual") return ah_f_qual ? uppertext(QualityName(ah_f_qual)) : "QUALITY"
		if("metal") return ah_f_metal ? AhTrunc(uppertext(LIFE_METAL_NAME[ah_f_metal]), 11) : "METAL"
		if("gem") return ah_f_gem ? AhTrunc(uppertext(LIFE_GEM_CLASS[ah_f_gem]), 11) : "GEM"
		if("mmat")
			if(!ah_f_mmat) return "ESSENCE"
			var/datum/monster_mat_def/d = LifeMonsterMatDef(ah_f_mmat)
			return d ? AhTrunc(uppertext(d.name), 11) : "ESSENCE"
		if("sort")
			switch(ah_sort)
				if(2) return "SORT: $"
				if(3) return "SORT: TIME"
				if(4) return "SORT: NEW"
			return "SORT: $/U"
	return ""

client/proc/AhBuildBrowse()
	// search bar
	var/atom/movable/shud/ahbtn/sb = new
	sb.icon = 'HUD/log_row_btn.png'
	sb.action = "search"
	sb.screen_loc = AHloc(306, 51, 18)
	AhAdd(sb, 0)
	AhText(316, 53, 264, 14, "<span style=\"[AH_FONT_BODY]; color:[ah_f_search ? "#ffffff" : AH_C_HINT]\">[ah_f_search ? "SEARCH: [html_encode(AhTrunc(uppertext(ah_f_search), 24))]" : "SEARCH THE BLOCK..."]</span>", 0)   // encode last or truncation splits entities
	// filter chips
	var/cx = 18
	for(var/k in list("cat", "qual", "metal", "gem", "mmat", "sort"))
		var/active = 0
		switch(k)
			if("cat") active = (ah_f_cat != "")
			if("qual") active = (ah_f_qual != 0)
			if("metal") active = (ah_f_metal != "")
			if("gem") active = (ah_f_gem != "")
			if("mmat") active = (ah_f_mmat != "")
			if("sort") active = (ah_sort != 1)
		AhBtn(AhChipLabel(k), "chip", k, cx, 82, 66, 18, (ah_pick == k) ? "#ffffff" : (active ? AH_C_GOLD : "#8be9ff"))
		cx += 72
	AhBtn("CLEAR", "clear", null, cx, 82, 66, 18, AH_C_BAD)

	if(ah_pick)
		AhBuildPickPage()
		return

	var/list/E = AhBrowseList()
	AhText(468, 84, 138, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]; text-align:right\">[E.len] LISTED</span>", 0)
	var/maxscroll = max(0, E.len - AH_ROWS)
	ah_scroll = clamp(ah_scroll, 0, maxscroll)
	var/shown = min(E.len - ah_scroll, AH_ROWS)
	if(!E.len)
		AhText(20, 180, 584, 16, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">Nothing on the block matches. Loosen the filters, or be the first to list.</span></center>", 0)
	for(var/i = 1 to shown)
		var/datum/ah_listing/L = E[ah_scroll + i]
		var/y = AH_ROW_Y + (i - 1) * AH_ROW_P
		AhListingRow(L, y)

	// bottom strip
	var/datum/ah_listing/S = AhSelListing()
	if(S)
		AhText(24, 312, 352, 14, "<span style=\"[AH_FONT_BODY]; color:#ffffff\">[AhTrunc(S.Label(), 44)] <span style=\"color:[AH_C_HINT]\">- [S.seller_name]</span></span>", 0)
		if(S.is_auction) AhBtn("BID", "bid", null, 382, 306, 100, 24, AH_C_GOLD)
		else AhBtn("BUY", "buy", null, 382, 306, 100, 24, AH_C_OK)
		AhBtn("TRENDS", "trends", null, 490, 306, 100, 24)
	else
		AhText(24, 312, 460, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">left-click a listing - right-click inspects gear / charts a lot - wheel scrolls</span>", 0)
		if(maxscroll > 0)
			AhText(468, 312, 138, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]; text-align:right\">rows [ah_scroll + 1]-[ah_scroll + shown] / [E.len]</span>", 0)

client/proc/AhListingRow(datum/ah_listing/L, y)
	AhRowObj(y, "listing", L.id)
	if(L.kind == "item" && L.item)
		AhRowIcon(y, L.item.icon, L.item.icon_state, L.item.color)
	else if(L.kind == "lot")
		var/datum/matdef/d = LifeMatDef(L.matclass)
		if(d) AhRowIcon(y, d.icon, d.icon_state)
	var/ncol = "#ffffff"
	if(L.kind == "lot") ncol = QualityColor(L.mquality)
	else if(L.item && L.item.metal_id && L.item.CraftQuality) ncol = QualityColor(L.item.CraftQuality)
	AhText(50, AH_RTY(y), 240, 14, "<span style=\"[AH_FONT_BODY]; color:[ncol]\">[AhTrunc(L.Label(), 30)]</span>", 0, 0.5)
	AhText(296, AH_RTY(y), 96, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">[AhTrunc(L.seller_name, 12)]</span>", 0, 0.5)
	AhText(394, AH_RTY(y), 64, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_TXT]\">[AhLeftTxt(L.end_rt - world.realtime)]</span>", 0, 0.5)
	var/ptxt
	if(L.is_auction)
		ptxt = L.cur_bid ? "<span style=\"color:[AH_C_GOLD]\">BID $[Commas(L.cur_bid)]</span>" : "<span style=\"color:[AH_C_TXT]\">OPEN $[Commas(L.start_bid)]</span>"
	else if(L.kind == "lot" && L.mcount > 1)
		ptxt = "<span style=\"color:[AH_C_OK]\">$[Commas(L.price)] <span style=\"color:[AH_C_HINT]\">($[Commas(AhUnitPrice(L))] ea)</span></span>"
	else
		ptxt = "<span style=\"color:[AH_C_OK]\">$[Commas(L.price)]</span>"
	AhText(452, AH_RTY(y), 144, 14, "<span style=\"[AH_FONT_BODY]; text-align:right\">[ptxt]</span>", 0, 0.5)

// filter + sort

/proc/AhUnitPrice(datum/ah_listing/L)
	var/base = L.is_auction ? (L.cur_bid ? L.cur_bid : L.start_bid) : L.price
	if(L.kind == "lot" && L.mcount > 0) return max(1, round(base / L.mcount))
	return base

client/proc/AhMatch(datum/ah_listing/L)
	if(!L) return 0
	if(ah_f_search)
		if(!findtext("[L.Label()] [L.seller_name]", ah_f_search)) return 0
	if(ah_f_cat)
		if(ah_f_cat == "Gear")
			if(L.kind != "item" || !L.item || mob.InvClassify(L.item) != "Gear") return 0
		else if(ah_f_cat == "Items")
			if(L.kind != "item" || !L.item || mob.InvClassify(L.item) == "Gear") return 0
		else
			if(L.kind != "lot") return 0
			if(!(L.matclass in LifeMatsInCategory(ah_f_cat))) return 0
	if(ah_f_qual)
		if(L.kind == "lot")
			if(L.mquality != ah_f_qual) return 0
		else
			if(!L.item || L.item.CraftQuality != ah_f_qual) return 0
	if(ah_f_metal)
		if(L.kind != "item" || !L.item || L.item.metal_id != ah_f_metal) return 0
	if(ah_f_gem)
		if(L.kind != "item" || !L.item || L.item.gem_id != ah_f_gem) return 0
	if(ah_f_mmat)
		if(L.kind != "item" || !L.item || L.item.mmat_id != ah_f_mmat) return 0
	return 1

client/proc/AhSortKey(datum/ah_listing/L)
	switch(ah_sort)
		if(2) return L.is_auction ? (L.cur_bid ? L.cur_bid : L.start_bid) : L.price
		if(3) return L.end_rt - world.realtime
		if(4) return -L.listed_rt
	return AhUnitPrice(L)

client/proc/AhBrowseList()
	var/list/E = list()
	var/list/K = list()
	for(var/k in AuctionHouse.listings)
		var/datum/ah_listing/L = AuctionHouse.listings[k]
		if(!AhMatch(L)) continue
		var/key = AhSortKey(L)
		var/placed = 0
		for(var/j = 1 to E.len)
			if(key < K[j])
				E.Insert(j, L)
				K.Insert(j, key)
				placed = 1
				break
		if(!placed)
			E += L
			K += key
	return E

// pick pages

client/proc/AhPickOptions()
	var/list/opts = list()
	switch(ah_pick)
		if("cat")
			opts += list(list("", "ANY CATEGORY"))
			opts += list(list("Gear", "GEAR (FORGED)"))
			opts += list(list("Items", "ITEMS"))
			for(var/c in LifeMatCategories)
				opts += list(list(c, "[uppertext(c)] (LOTS)"))
		if("qual")
			opts += list(list(0, "ANY QUALITY"))
			for(var/q = QUAL_POOR to QUAL_LEGENDARY)
				opts += list(list(q, uppertext(QualityName(q))))
		if("metal")
			opts += list(list("", "ANY METAL"))
			for(var/mid in LIFE_METAL_NAME)
				opts += list(list(mid, uppertext(LIFE_METAL_NAME[mid])))
		if("gem")
			opts += list(list("", "ANY SOCKET"))
			for(var/gid in LIFE_GEM_CLASS)
				opts += list(list(gid, uppertext(LIFE_GEM_CLASS[gid])))
		if("mmat")
			opts += list(list("", "ANY ESSENCE"))
			RegisterMonsterMats()
			for(var/mmid in LifeMonsterMatDefs)
				var/datum/monster_mat_def/d = LifeMonsterMatDefs[mmid]
				opts += list(list(mmid, "[uppertext(d.name)] <span style=\"color:[AH_C_HINT]\">- [d.passive_label]</span>"))
		if("sort")
			opts += list(list(1, "CHEAPEST PER UNIT"))
			opts += list(list(2, "CHEAPEST TOTAL"))
			opts += list(list(3, "ENDING SOONEST"))
			opts += list(list(4, "NEWEST FIRST"))
	return opts

client/proc/AhPickTitle()
	switch(ah_pick)
		if("cat") return "PICK A CATEGORY"
		if("qual") return "PICK A QUALITY"
		if("metal") return "PICK A METAL"
		if("gem") return "PICK A SOCKETED GEM"
		if("mmat") return "PICK A WORKED ESSENCE"
		if("sort") return "SORT LISTINGS BY"
	return ""

client/proc/AhPickCurrent()
	switch(ah_pick)
		if("cat") return ah_f_cat
		if("qual") return ah_f_qual
		if("metal") return ah_f_metal
		if("gem") return ah_f_gem
		if("mmat") return ah_f_mmat
		if("sort") return ah_sort
	return ""

client/proc/AhBuildPickPage()
	var/list/opts = AhPickOptions()
	AhText(24, 108, 400, 16, "<span style=\"[AH_FONT]; color:#ffffff\">[AhPickTitle()]</span>", 0)
	var/vis = 7
	var/maxscroll = max(0, opts.len - vis)
	ah_scroll = clamp(ah_scroll, 0, maxscroll)
	var/shown = min(opts.len - ah_scroll, vis)
	var/cur = AhPickCurrent()
	for(var/i = 1 to shown)
		var/list/o = opts[ah_scroll + i]
		var/y = 130 + (i - 1) * AH_ROW_P
		var/atom/movable/shud/ahrow/r = AhRowObj(y, "pick", ah_scroll + i)
		r.rmc = "[o[1]]"
		var/hit = ("[o[1]]" == "[cur]")
		AhText(50, AH_RTY(y), 460, 14, "<span style=\"[AH_FONT_BODY]; color:[hit ? AH_C_GOLD : "#ffffff"]\">[hit ? "&#9670; " : ""][o[2]]</span>", 0, 0.5)
	if(maxscroll > 0)
		AhText(468, 312, 138, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]; text-align:right\">[ah_scroll + 1]-[ah_scroll + shown] / [opts.len]</span>", 0)
	AhText(24, 312, 300, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">click an option - wheel scrolls</span>", 0)

client/proc/AhPickSet(val)
	switch(ah_pick)
		if("cat") ah_f_cat = val
		if("qual") ah_f_qual = text2num("[val]")
		if("metal") ah_f_metal = val
		if("gem") ah_f_gem = val
		if("mmat") ah_f_mmat = val
		if("sort") ah_sort = text2num("[val]")
	ah_pick = ""
	ah_scroll = 0
	ah_sel = 0
	RefreshAhPage()

// SELL

client/proc/AhBuildSell()
	var/mob/M = mob
	AhText(24, 86, 370, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">FEE [AH_FEE_PCT * 100]% OF ASK (MIN $[AH_FEE_MIN]) - HOUSE KEEPS [AH_CUT * 100]% OF THE SALE</span>", 0)
	AhText(400, 86, 206, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_GOLD]; text-align:right\">LISTINGS [M.AhListingCount()] / [AH_MAX_LISTINGS]</span>", 0)

	var/list/rows = list()
	rows += list(list("hdr", "FROM YOUR PACK <span style=\"color:[AH_C_HINT]\">(equipped and bound gear can't be consigned)</span>"))
	var/packn = 0
	for(var/obj/Items/I in M)
		if(istype(I, /obj/Money) || istype(I, /obj/Items/mineral)) continue
		if(AhCanList(M, I)) continue
		rows += list(list("item", I))
		packn++
	if(!packn) rows += list(list("note", "nothing consignable in your pack"))
	rows += list(list("hdr", "FROM YOUR COLLECTION LOG"))
	var/lotn = 0
	for(var/c in LifeMatCategories)
		for(var/mc in LifeMatsInCategory(c))
			for(var/q = QUAL_LEGENDARY to QUAL_POOR step -1)
				var/n = M.MatLogCountQ(mc, q)
				if(n <= 0) continue
				rows += list(list("lot", mc, q, n))
				lotn++
	if(!lotn) rows += list(list("note", "your log holds nothing to sell"))

	var/maxscroll = max(0, rows.len - AH_ROWS)
	ah_scroll = clamp(ah_scroll, 0, maxscroll)
	var/shown = min(rows.len - ah_scroll, AH_ROWS)
	for(var/i = 1 to shown)
		var/list/rw = rows[ah_scroll + i]
		var/y = AH_ROW_Y + (i - 1) * AH_ROW_P
		var/t = rw[1]
		if(t == "hdr")
			AhText(24, AH_RTY(y), 560, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_CYAN]\">[rw[2]]</span>", 0, 0.5)
		else if(t == "note")
			AhRowPlate(y)
			AhText(50, AH_RTY(y), 460, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">[rw[2]]</span>", 0, 0.5)
		else if(t == "item")
			var/obj/Items/I = rw[2]
			AhRowObj(y, "sellitem", 0, I)
			AhRowIcon(y, I.icon, I.icon_state, I.color)
			var/ncol = (I.metal_id && I.CraftQuality) ? QualityColor(I.CraftQuality) : "#ffffff"
			AhText(50, AH_RTY(y), 360, 14, "<span style=\"[AH_FONT_BODY]; color:[ncol]\">[AhTrunc(I.name, 40)]</span>", 0, 0.5)
			AhText(452, AH_RTY(y), 144, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_OK]; text-align:right\">LIST &gt;</span>", 0, 0.5)
		else if(t == "lot")
			var/mc = rw[2]
			var/q = rw[3]
			var/n = rw[4]
			AhRowObj(y, "selllot", 0, null, mc, q)
			var/datum/matdef/d = LifeMatDef(mc)
			if(d) AhRowIcon(y, d.icon, d.icon_state)
			AhText(50, AH_RTY(y), 360, 14, "<span style=\"[AH_FONT_BODY]; color:[QualityColor(q)]\">[n]x [QualityName(q)] [d ? d.name : mc]</span>", 0, 0.5)
			AhText(452, AH_RTY(y), 144, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_OK]; text-align:right\">LIST &gt;</span>", 0, 0.5)
	if(maxscroll > 0)
		AhText(468, 312, 138, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]; text-align:right\">rows [ah_scroll + 1]-[ah_scroll + shown] / [rows.len]</span>", 0)
	AhText(24, 312, 430, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">click a row to set price and list - right-click gear to inspect</span>", 0)

// MINE

client/proc/AhBuildMine()
	var/list/E = list()
	for(var/k in AuctionHouse.listings)
		var/datum/ah_listing/L = AuctionHouse.listings[k]
		if(L && L.seller_ckey == mob.ckey) E += L
	AhText(24, 84, 400, 16, "<span style=\"[AH_FONT]; color:#ffffff\">MY LISTINGS</span>", 0)
	AhText(400, 86, 206, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_GOLD]; text-align:right\">[E.len] / [AH_MAX_LISTINGS] SLOTS USED</span>", 0)
	if(!E.len)
		AhText(20, 180, 584, 16, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">Nothing consigned. The SELL tab puts goods on the block.</span></center>", 0)
	var/maxscroll = max(0, E.len - AH_ROWS)
	ah_scroll = clamp(ah_scroll, 0, maxscroll)
	var/shown = min(E.len - ah_scroll, AH_ROWS)
	for(var/i = 1 to shown)
		var/datum/ah_listing/L = E[ah_scroll + i]
		var/y = AH_ROW_Y + (i - 1) * AH_ROW_P
		AhRowObj(y, "listing", L.id)
		if(L.kind == "item" && L.item) AhRowIcon(y, L.item.icon, L.item.icon_state, L.item.color)
		else if(L.kind == "lot")
			var/datum/matdef/d = LifeMatDef(L.matclass)
			if(d) AhRowIcon(y, d.icon, d.icon_state)
		AhText(50, AH_RTY(y), 260, 14, "<span style=\"[AH_FONT_BODY]; color:#ffffff\">[AhTrunc(L.Label(), 32)]</span>", 0, 0.5)
		var/st
		if(L.is_auction)
			st = L.cur_bidder_ckey ? "<span style=\"color:[AH_C_GOLD]\">BID $[Commas(L.cur_bid)] ([AhTrunc(L.cur_bidder_name, 10)])</span>" : "<span style=\"color:[AH_C_HINT]\">NO BIDS YET</span>"
		else
			st = "<span style=\"color:[AH_C_OK]\">ASK $[Commas(L.price)]</span>"
		AhText(310, AH_RTY(y), 200, 14, "<span style=\"[AH_FONT_BODY]\">[st]</span>", 0, 0.5)
		AhText(512, AH_RTY(y), 84, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_TXT]; text-align:right\">[AhLeftTxt(L.end_rt - world.realtime)]</span>", 0, 0.5)
	var/datum/ah_listing/S = AhSelListing()
	if(S && S.seller_ckey == mob.ckey)
		AhText(24, 312, 340, 14, "<span style=\"[AH_FONT_BODY]; color:#ffffff\">[AhTrunc(S.Label(), 40)]</span>", 0)
		AhBtn("PULL IT", "cancel_listing", null, 382, 306, 100, 24, AH_C_BAD)
		AhBtn("TRENDS", "trends", null, 490, 306, 100, 24)
	else if(E.len)
		AhText(24, 312, 460, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">click a listing to manage it - a live bid locks it to the hammer</span>", 0)

// BIDS

client/proc/AhBuildBids()
	var/list/E = list()
	var/escrow = 0
	for(var/k in AuctionHouse.listings)
		var/datum/ah_listing/L = AuctionHouse.listings[k]
		if(L && L.is_auction && L.cur_bidder_ckey == mob.ckey)
			E += L
			escrow += L.cur_bid
	AhText(24, 84, 300, 16, "<span style=\"[AH_FONT]; color:#ffffff\">MY BIDS</span>", 0)
	AhText(340, 86, 266, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_GOLD]; text-align:right\">ESCROW OUT $[Commas(escrow)]</span>", 0)
	if(!E.len)
		AhText(20, 180, 584, 16, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">No live bids. When you're outbid, your gold comes straight back.</span></center>", 0)
	var/maxscroll = max(0, E.len - AH_ROWS)
	ah_scroll = clamp(ah_scroll, 0, maxscroll)
	var/shown = min(E.len - ah_scroll, AH_ROWS)
	for(var/i = 1 to shown)
		var/datum/ah_listing/L = E[ah_scroll + i]
		var/y = AH_ROW_Y + (i - 1) * AH_ROW_P
		AhRowObj(y, "listing", L.id)
		if(L.kind == "item" && L.item) AhRowIcon(y, L.item.icon, L.item.icon_state, L.item.color)
		else if(L.kind == "lot")
			var/datum/matdef/d = LifeMatDef(L.matclass)
			if(d) AhRowIcon(y, d.icon, d.icon_state)
		AhText(50, AH_RTY(y), 260, 14, "<span style=\"[AH_FONT_BODY]; color:#ffffff\">[AhTrunc(L.Label(), 32)]</span>", 0, 0.5)
		AhText(310, AH_RTY(y), 200, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_GOLD]\">MY BID $[Commas(L.cur_bid)]</span>", 0, 0.5)
		AhText(512, AH_RTY(y), 84, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_TXT]; text-align:right\">[AhLeftTxt(L.end_rt - world.realtime)]</span>", 0, 0.5)
	AhText(24, 312, 560, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">you hold the top bid on these - the hammer decides at the clock, win or refund</span>", 0)

// TRENDS

client/proc/AhOpenTrends(pkey, label)
	if(!pkey) return
	ah_trend_pkey = pkey
	ah_trend_label = label
	if(ah_mode != "trends") ah_prev_mode = ah_mode
	ah_mode = "trends"
	ah_scroll = 0
	RefreshAhTabs()
	RefreshAhPage()

client/proc/AhBuildTrends()
	AhText(24, 84, 560, 16, "<span style=\"[AH_FONT]; color:#ffffff\">PRICE HISTORY - [AhTrunc(uppertext(ah_trend_label), 40)]</span>", 0)
	var/med = AhMedianPrice(ah_trend_pkey)
	var/vol = AhSaleCount(ah_trend_pkey)
	var/cheap = AhCheapestLive(ah_trend_pkey)
	AhText(24, 108, 300, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_GOLD]\">MEDIAN $[Commas(med)] <span style=\"color:[AH_C_HINT]\">(LAST [min(vol, 20)] OF [vol], PER UNIT)</span></span>", 0)
	AhText(340, 108, 266, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_OK]; text-align:right\">[cheap ? "CHEAPEST LIVE $[Commas(cheap)]" : "NONE LISTED NOW"]</span>", 0)
	var/list/H = AuctionHouse.history[ah_trend_pkey]
	if(!H || !H.len)
		AhText(20, 180, 584, 16, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">No recorded sales yet. The first hammer writes the book.</span></center>", 0)
	else
		var/shown = min(H.len, 7)
		for(var/i = 1 to shown)
			var/list/rec = H[H.len - i + 1]
			var/y = 130 + (i - 1) * 22
			AhRowPlate(y)
			AhText(50, AH_RTY(y), 200, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_TXT]\">[AhAgoTxt(rec[1])]</span>", 0, 0.5)
			AhText(340, AH_RTY(y), 244, 14, "<span style=\"[AH_FONT_BODY]; color:[AH_C_GOLD]; text-align:right\">$[Commas(rec[2])]</span>", 0, 0.5)
	AhBtn("&lt; BACK", "back", null, 490, 306, 100, 24)

// click

client/proc/AhSelListing()
	if(!ah_sel) return null
	return AuctionHouse.listings["[ah_sel]"]

client/proc/AhRowClick(atom/movable/shud/ahrow/r)
	if(!ahmenu_open || !r) return
	if(ah_confirm_objs || ah_type_objs) return
	switch(r.rkind)
		if("listing")
			ah_sel = (ah_sel == r.rid) ? 0 : r.rid
			RefreshAhPage()
		if("pick")
			AhPickSet(r.rmc)
		if("sellitem")
			if(r.ritem) AhSellFlowItem(r.ritem)
		if("selllot")
			if(r.rmc) AhSellFlowLot(r.rmc, r.rq)

client/proc/AhRowInspect(atom/movable/shud/ahrow/r)
	if(!ahmenu_open || !r) return
	if(r.rkind == "listing")
		var/datum/ah_listing/L = AuctionHouse.listings["[r.rid]"]
		if(!L) return
		if(L.kind == "item" && L.item) AhInspect(L.item)
		else if(L.kind == "lot") AhOpenTrends(L.pkey, L.Label())
	else if(r.ritem)
		AhInspect(r.ritem)

client/proc/AhButton(action, arg)
	if(!ahmenu_open) return
	if((ah_confirm_objs || ah_type_objs || ah_flow) && action != "close") return   // an open prompt owns the floor
	switch(action)
		if("close")
			CloseAhMenu()
		if("box")
			if(!AhRangeOK()) return
			mob.AhClaimBox()
			RefreshAhPage()
		if("mode")
			if(ah_confirm_objs || ah_type_objs) return
			ah_mode = arg
			ah_pick = ""
			ah_sel = 0
			ah_scroll = 0
			RefreshAhTabs()
			RefreshAhPage()
		if("chip")
			if(ah_confirm_objs || ah_type_objs) return
			ah_pick = (ah_pick == arg) ? "" : arg
			ah_scroll = 0
			RefreshAhPage()
		if("clear")
			ah_f_cat = ""
			ah_f_qual = 0
			ah_f_metal = ""
			ah_f_gem = ""
			ah_f_mmat = ""
			ah_f_search = ""
			ah_sort = 1
			ah_pick = ""
			ah_scroll = 0
			RefreshAhPage()
		if("search")
			AhSearchFlow()
		if("buy")
			AhBuyFlow()
		if("bid")
			AhBidFlow()
		if("trends")
			var/datum/ah_listing/S = AhSelListing()
			if(S) AhOpenTrends(S.pkey, S.Label())
		if("back")
			ah_mode = ah_prev_mode
			ah_scroll = 0
			RefreshAhTabs()
			RefreshAhPage()
		if("cancel_listing")
			var/datum/ah_listing/S = AhSelListing()
			if(!S || S.seller_ckey != mob.ckey) return
			if(S.is_auction && S.cur_bidder_ckey)
				mob << "<font color=#ff6464>There's a live bid on it - the hammer decides now.</font>"
				return
			AhShowConfirm("cancel", list(S.id), "PULL IT BACK", "Take [S.Label()] off the block?<br>The listing fee is spent either way.")

// buy / bid flows

client/proc/AhBuyFlow()
	var/datum/ah_listing/S = AhSelListing()
	if(!S || S.is_auction || ah_flow) return
	if(!AhRangeOK()) return
	if(AhSameOwner(mob, S))
		mob << "The house won't broker a sale back to its own seller."
		return
	if(S.kind == "lot" && S.mcount > 1)
		ah_flow = 1
		spawn()
			var/n = mob.HUDNumPrompt("HOW MANY? (OF [S.mcount])", S.mcount)
			ah_flow = 0
			if(isnull(n) || !ahmenu_open) return
			n = clamp(round(n), 1, S.mcount)
			var/cost = (n >= S.mcount) ? S.price : max(1, -round(-(S.price * n / S.mcount)))
			AhShowConfirm("buy", list(S.id, (n >= S.mcount) ? 0 : n), "SEAL THE DEAL", "Buy [n]x [QualityName(S.mquality)] [LifeMatName(S.matclass)]<br>for <font color=[AH_C_GOLD]>$[Commas(cost)]</font>?")
	else
		AhShowConfirm("buy", list(S.id, 0), "SEAL THE DEAL", "Buy [S.Label()]<br>for <font color=[AH_C_GOLD]>$[Commas(S.price)]</font>?")

client/proc/AhBidFlow()
	var/datum/ah_listing/S = AhSelListing()
	if(!S || !S.is_auction || ah_flow) return
	if(!AhRangeOK()) return
	if(AhSameOwner(mob, S))
		mob << "The house won't take your bid on your own consignment."
		return
	if(S.cur_bidder_ckey == mob.ckey)
		mob << "You're already the top bid."
		return
	ah_flow = 1
	spawn()
		var/minb = mob.AhMinBid(S)
		var/amt = mob.HUDNumPrompt("YOUR BID (MIN [minb])", minb)
		ah_flow = 0
		if(isnull(amt) || !ahmenu_open) return
		amt = round(amt)
		if(amt < minb)
			mob << "The bid must be at least $[Commas(minb)]."
			return
		AhShowConfirm("bid", list(S.id, amt), "PLACE THE BID", "Escrow <font color=[AH_C_GOLD]>$[Commas(amt)]</font> on [S.Label()]?<br>Outbid = instant refund.")

// sell flows

client/proc/AhSellFlowItem(obj/Items/I)
	if(ah_flow || !mob) return
	if(!AhRangeOK()) return
	var/why = AhCanList(mob, I)
	if(why)
		mob << "<font color=#ff6464>[why]</font>"
		return
	if(mob.AhListingCount() >= AH_MAX_LISTINGS)
		mob << "You already have [AH_MAX_LISTINGS] listings up."
		return
	ah_flow = 1
	spawn()
		var/med = AhMedianPrice(AhPriceKeyItem(I))
		var/ask = mob.HUDNumPrompt("ASKING PRICE", med ? med : 1000)
		if(isnull(ask) || !ahmenu_open)
			ah_flow = 0
			return
		ask = round(ask)
		if(ask < 1 || ask > AH_PRICE_MAX)
			mob << "The house takes prices from $1 to $[Commas(AH_PRICE_MAX)]."
			ah_flow = 0
			return
		ah_pend_mode = "item"
		ah_pend_item = I
		ah_pend_ask = ask
		AhShowTypeOverlay(I.name, AhPriceKeyItem(I), ask)

client/proc/AhSellFlowLot(mc, q)
	if(ah_flow || !mob) return
	if(!AhRangeOK()) return
	var/have = mob.MatLogCountQ(mc, q)
	if(have <= 0) return
	if(mob.AhListingCount() >= AH_MAX_LISTINGS)
		mob << "You already have [AH_MAX_LISTINGS] listings up."
		return
	ah_flow = 1
	spawn()
		var/n = mob.HUDNumPrompt("HOW MANY? (HAVE [have])", have)
		if(isnull(n) || !ahmenu_open)
			ah_flow = 0
			return
		n = clamp(round(n), 1, have)
		var/medu = AhMedianPrice(AhPriceKeyLot(mc, q))
		if(!medu) medu = max(1, LifeSellPrice(mob, mc, q) * 2)
		var/ask = mob.HUDNumPrompt("PRICE FOR THE LOT", min(AH_PRICE_MAX, medu * n))
		if(isnull(ask) || !ahmenu_open)
			ah_flow = 0
			return
		ask = round(ask)
		if(ask < 1 || ask > AH_PRICE_MAX)
			mob << "The house takes prices from $1 to $[Commas(AH_PRICE_MAX)]."
			ah_flow = 0
			return
		ah_pend_mode = "lot"
		ah_pend_mc = mc
		ah_pend_q = q
		ah_pend_n = n
		ah_pend_ask = ask
		AhShowTypeOverlay("[n]x [QualityName(q)] [LifeMatName(mc)]", AhPriceKeyLot(mc, q), ask, n)

// fixed vs auction picker. ah_flow stays up until this resolves
client/proc/AhShowTypeOverlay(label, pkey, ask, units = 0)
	AhHideTypeOverlay()
	ah_type_objs = list()
	var/atom/movable/shud/ahpic/P = new
	P.icon = 'HUD/farm_panel.png'
	P.layer = AH_LAYER + 1.0
	P.mouse_opacity = 2
	P.screen_loc = AHloc(182, 72, 200)
	ah_type_objs += P
	var/med = AhMedianPrice(pkey)
	var/vol = AhSaleCount(pkey)
	var/cheap = AhCheapestLive(pkey)
	var/fee = AhListingFee(ask)
	AhOvText(194, 84, 236, 16, "<center><span style=\"[AH_FONT]; color:#ffffff\">[AhTrunc(uppertext(label), 26)]</span></center>")
	AhOvText(194, 108, 236, 14, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_GOLD]\">ASK $[Commas(ask)][units > 1 ? " ($[Commas(max(1, round(ask / units)))] EA)" : ""]</span></center>")
	AhOvText(194, 122, 236, 14, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">[med ? "MEDIAN $[Commas(med)][units ? " EA" : ""] ([min(vol, 20)] SALES)" : "NO SALE HISTORY YET"]</span></center>")
	AhOvText(194, 136, 236, 14, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_HINT]\">[cheap ? "CHEAPEST LIVE $[Commas(cheap)][units ? " EA" : ""]" : "NOTHING ELSE LISTED"]</span></center>")
	AhOvText(194, 150, 236, 14, "<center><span style=\"[AH_FONT_BODY]; color:[AH_C_BAD]\">FEE $[Commas(fee)] NOW - HOUSE CUT 20%</span></center>")
	AhOvBtn("FIXED - 7D", "type_fixed", 192, 172, AH_C_OK)
	AhOvBtn("AUCTION 12H", "type_a12", 332, 172, AH_C_GOLD)
	AhOvBtn("AUCTION 24H", "type_a24", 192, 200, AH_C_GOLD)
	AhOvBtn("AUCTION 48H", "type_a48", 332, 200, AH_C_GOLD)
	AhOvBtn("CANCEL", "type_cancel", 262, 228, AH_C_BAD)
	for(var/atom/movable/o in ah_type_objs)
		screen += o

client/proc/AhOvText(dx, dyTop, w, h, txt)
	var/atom/movable/shud/ahtext/T = new
	T.layer = AH_LAYER + 1.15
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = AHloc(dx, dyTop, h)
	T.maptext = txt
	ah_type_objs += T
	return T

client/proc/AhOvBtn(label, act, dx, dyTop, tcol)
	var/atom/movable/shud/ahconfirm/B = new
	B.icon = 'HUD/np_btn.png'
	B.act = act
	B.screen_loc = AHloc(dx, dyTop, 24)
	ah_type_objs += B
	var/atom/movable/shud/ahtext/L = new
	L.layer = AH_LAYER + 1.2
	L.maptext_width = 100
	L.maptext_height = 16
	L.screen_loc = AHloc(dx, dyTop + 4, 16)
	L.maptext = "<center><span style=\"[AH_FONT]; color:[tcol]\">[label]</span></center>"
	ah_type_objs += L
	return B

client/proc/AhHideTypeOverlay()
	if(ah_type_objs)
		for(var/atom/movable/o in ah_type_objs)
			screen -= o
			del o
	ah_type_objs = null

client/proc/AhShowConfirm(kind, list/a, title, body)
	AhHideOverlay()
	ah_confirm_kind = kind
	ah_confirm_a = a
	ah_confirm_objs = list()
	var/atom/movable/shud/ahpic/P = new
	P.icon = 'HUD/party_prompt.png'
	P.layer = AH_LAYER + 1.0
	P.mouse_opacity = 2
	P.screen_loc = AHloc(200, 100, 140)
	ah_confirm_objs += P
	var/atom/movable/shud/ahtext/T = new
	T.layer = AH_LAYER + 1.15
	T.maptext_width = 200
	T.maptext_height = 48
	T.screen_loc = AHloc(212, 112, 48)
	T.maptext = "<center><span style=\"[AH_FONT_BODY]; color:#ffffff\"><b>[title]</b><br>[body]</span></center>"
	ah_confirm_objs += T
	var/atom/movable/shud/ahconfirm/Y = new
	Y.icon = 'HUD/np_btn.png'
	Y.act = "yes"
	Y.screen_loc = AHloc(208, 184, 24)
	ah_confirm_objs += Y
	var/atom/movable/shud/ahtext/YL = new
	YL.layer = AH_LAYER + 1.2
	YL.maptext_width = 100
	YL.maptext_height = 16
	YL.screen_loc = AHloc(208, 188, 16)
	YL.maptext = "<center><span style=\"[AH_FONT]; color:[AH_C_OK]\">YES</span></center>"
	ah_confirm_objs += YL
	var/atom/movable/shud/ahconfirm/N = new
	N.icon = 'HUD/np_btn.png'
	N.act = "no"
	N.screen_loc = AHloc(316, 184, 24)
	ah_confirm_objs += N
	var/atom/movable/shud/ahtext/NL = new
	NL.layer = AH_LAYER + 1.2
	NL.maptext_width = 100
	NL.maptext_height = 16
	NL.screen_loc = AHloc(316, 188, 16)
	NL.maptext = "<center><span style=\"[AH_FONT]; color:[AH_C_BAD]\">NO</span></center>"
	ah_confirm_objs += NL
	for(var/atom/movable/o in ah_confirm_objs)
		screen += o

client/proc/AhHideOverlay()
	ah_confirm_kind = ""
	ah_confirm_a = null
	if(ah_confirm_objs)
		for(var/atom/movable/o in ah_confirm_objs)
			screen -= o
			del o
	ah_confirm_objs = null

// yes/no and the type_* picks both land here
client/proc/AhOverlayAction(act)
	if(!mob) return
	switch(act)
		if("yes")
			var/kind = ah_confirm_kind
			var/list/a = ah_confirm_a
			AhHideOverlay()
			if(!ahmenu_open || !a || !AhRangeOK()) return
			switch(kind)
				if("buy") mob.AhBuy(a[1], a.len >= 2 ? a[2] : 0)
				if("bid") mob.AhBid(a[1], a[2])
				if("cancel") mob.AhCancel(a[1])
			ah_sel = 0
			RefreshAhPage()
		if("no")
			AhHideOverlay()
		if("type_cancel")
			AhHideTypeOverlay()
			AhPendClear()
		if("type_fixed") AhTypeCommit(0, 0)
		if("type_a12") AhTypeCommit(1, AH_DUR_12H)
		if("type_a24") AhTypeCommit(1, AH_DUR_24H)
		if("type_a48") AhTypeCommit(1, AH_DUR_48H)

client/proc/AhPendClear()
	ah_flow = 0
	ah_pend_mode = ""
	ah_pend_item = null
	ah_pend_mc = ""
	ah_pend_q = 0
	ah_pend_n = 0
	ah_pend_ask = 0

client/proc/AhTypeCommit(is_auction, dur)
	AhHideTypeOverlay()
	if(!ahmenu_open || !mob || !ah_pend_mode)
		AhPendClear()
		return
	if(!AhRangeOK())
		AhPendClear()
		return
	if(ah_pend_mode == "item" && ah_pend_item)
		mob.AhListItem(ah_pend_item, ah_pend_ask, is_auction, dur ? dur : AH_DUR_24H)
	else if(ah_pend_mode == "lot")
		mob.AhListLot(ah_pend_mc, ah_pend_q, ah_pend_n, ah_pend_ask, is_auction, dur ? dur : AH_DUR_24H)
	AhPendClear()
	RefreshAhPage()

// search

client/proc/AhSearchFlow()
	if(ah_flow || !mob) return
	ah_flow = 1
	spawn()
		var/t = mob.HUDTextPrompt("SEARCH THE BLOCK", ah_f_search)
		ah_flow = 0
		if(isnull(t) || !ahmenu_open) return
		if(length(t) > 24) t = copytext(t, 1, 25)
		ah_f_search = t
		ah_scroll = 0
		ah_sel = 0
		RefreshAhPage()

// gear inspection popup

client/proc/AhInspectClose()
	if(ah_desc_objs)
		for(var/atom/movable/o in ah_desc_objs)
			screen -= o
			del o
	ah_desc_objs = null

client/proc/AhDescLine(txt, dx, dyTop, w)
	var/atom/movable/shud/ahdesctext/T = new
	T.maptext_width = w
	T.maptext_height = 16
	T.screen_loc = AHloc(dx, dyTop, 16)
	T.maptext = txt
	ah_desc_objs += T

client/proc/AhInspect(obj/Items/it)
	AhInspectClose()
	if(!it || !ahmenu_open) return
	ah_desc_objs = list()
	var/atom/movable/shud/ahdesc/P = new
	P.icon = 'HUD/geardetail.png'
	P.screen_loc = AHloc(120, -12, 368)
	ah_desc_objs += P
	var/cat = GearCat(it)
	var/ly = 6   // offsets are panel-relative, the panel top sits at dyTop -12
	AhDescLine(gspan(uppertext(it.name), "#ffd278", "center"), 134, ly, 356); ly += 22
	var/sub = cat
	if(it.Class in list("Light", "Medium", "Heavy")) sub += " - [it.Class]"
	AhDescLine(gspan(sub, "#96c3e1", "left"), 140, ly, 344); ly += 22
	var/gisw = istype(it, /obj/Items/Sword)
	if(it.metal_id)
		var/qn = (it.CraftQuality && it.CraftQuality != QUAL_NORMAL) ? "[QualityName(it.CraftQuality)] " : ""
		var/asc = (it.Ascended > 0) ? " &#183; Asc [it.Ascended]" : ""
		AhDescLine(gspan("[qn][LIFE_METAL_NAME[it.metal_id]]-forged[asc]", QualityColor(it.CraftQuality), "left"), 140, ly, 344); ly += 16
	if(gisw || istype(it, /obj/Items/Armor) || istype(it, /obj/Items/Enchantment/Staff))
		AhDescLine(gspan("[gisw ? "DMG" : "ABSORB"] x[round(it.DamageEffectiveness, 0.01)]  ACC x[round(it.AccuracyEffectiveness, 0.01)]  SPD x[round(it.SpeedEffectiveness, 0.01)]", "#bfe6ff", "left"), 140, ly, 344); ly += 16
	if(it.metal_id && it.CraftQuality == QUAL_LEGENDARY && !it.Destructable)
		AhDescLine(gspan("Unbreakable", "#ffd278", "left"), 140, ly, 344); ly += 16
	if(it.gem_id)
		AhDescLine(gspan("Socket: [LIFE_GEM_CLASS[it.gem_id]] [GemStatLine(it.gem_id, it.gem_quality)]", QualityColor(it.gem_quality), "left"), 140, ly, 344); ly += 16
	if(it.mmat_id)
		AhDescLine(gspan("Essence: [LifeMonsterMatLine(it.mmat_id, it.mmat_quality)]", "#8be9ff", "left"), 140, ly, 344); ly += 16
	if(it.metal_id && it.CreatorName)
		AhDescLine(gspan("Forged by [it.CreatorName]", "#9fb4c7", "left"), 140, ly, 344); ly += 16
	var/list/SL = mob.GearStatList(it)
	for(var/lbl in SL)
		var/val = SL[lbl]
		AhDescLine(gspan(lbl, "#cfe7ff", "left"), 140, ly, 160)
		AhDescLine(gspan("[val > 0 ? "+" : ""][val]", (val >= 0) ? "#5af078" : "#ff6b6b", "right"), 140, ly, 344)
		ly += 16
	ly += 4
	if(it.Repairable)
		AhDescLine(gspan("Durability", "#8be9ff", "left"), 140, ly, 160)
		AhDescLine(gspan("[round(it.ShatterCounter)] / [round(it.ShatterMax)]", "#ffffff", "right"), 140, ly, 344)
		ly += 18
	var/eo = "None"; var/ed = "None"
	if(it.Element)
		if(cat == "Armor") ed = "[it.Element]"
		else eo = "[it.Element]"
	AhDescLine(gspan("Elemental Offense", "#8be9ff", "left"), 140, ly, 200)
	AhDescLine(gspan(eo, (eo == "None") ? "#9fb4c7" : "#ff9a4d", "right"), 140, ly, 344); ly += 16
	AhDescLine(gspan("Elemental Defense", "#8be9ff", "left"), 140, ly, 200)
	AhDescLine(gspan(ed, (ed == "None") ? "#9fb4c7" : "#ff9a4d", "right"), 140, ly, 344); ly += 22
	if(it.passives && it.passives.len)
		AhDescLine(gspan("PASSIVES", "#8be9ff", "left"), 140, ly, 200); ly += 16
		var/pn = 0
		for(var/p in it.passives)
			if(pn >= 5) break
			AhDescLine(gspan("&#9670; [p] <span style=\"color:#ffd278\">- [it.passives[p]]</span>", "#ffffff", "left"), 146, ly, 340)
			ly += 16
			pn++
	AhDescLine(gspan("click anywhere on the panel to close", "#7a9bb5", "center"), 134, 304, 356)
	for(var/atom/movable/o in ah_desc_objs)
		screen += o
	KineticEntrance(ah_desc_objs)

// wheel + drag

client/proc/AhWheelScroll(delta_y)
	if(!ahmenu_open) return 0
	if(!ah_confirm_objs && !ah_type_objs && !ah_desc_objs)
		ah_scroll += (delta_y > 0 ? -1 : 1)
		RefreshAhPage()   // builders re-clamp
	return 1

client/proc/AHPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (ah_atx - 1) * 32
	var/by = (ah_aty - 1) * 32
	var/minx = -bx; if(minx > 0) minx = 0
	var/maxx = vw * 32 - AH_W - bx; if(maxx < 0) maxx = 0
	var/miny = -by; if(miny > 0) miny = 0
	var/maxy = vh * 32 - AH_H - by; if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/AhShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	if(ah_chrome)
		for(var/atom/movable/o in ah_chrome)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(ah_page)
		for(var/atom/movable/o in ah_page)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(ah_confirm_objs)
		for(var/atom/movable/o in ah_confirm_objs)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(ah_type_objs)
		for(var/atom/movable/o in ah_type_objs)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(ah_desc_objs)
		for(var/atom/movable/o in ah_desc_objs)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/AhPanelStart(params)
	ah_pan_dragged = 0
	var/list/m = MouseAbs(params)
	if(!m) return
	ah_pan_mx = m[1]; ah_pan_my = m[2]
	ah_pan_ox = ah_pan_x; ah_pan_oy = ah_pan_y

client/proc/AhPanelMove(params)
	if(!ahmenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = AHPanBounds()
	var/wantx = clamp(ah_pan_ox + (m[1] - ah_pan_mx), b[1], b[2])
	var/wanty = clamp(ah_pan_oy + (m[2] - ah_pan_my), b[3], b[4])
	var/dx = wantx - ah_pan_x
	var/dy = wanty - ah_pan_y
	if(!dx && !dy) return
	ah_pan_x = wantx; ah_pan_y = wanty
	ah_pan_dragged = 1
	AhShiftLive(dx, dy)

client/proc/AhPanelEnd()
	if(!ah_pan_dragged) return
	ah_pan_dragged = 0
	setPref("ahPanX", ah_pan_x)
	setPref("ahPanY", ah_pan_y)

proc/AhMoneyOf(mob/M)
	if(!M) return 0
	for(var/obj/Money/m in M)
		return round(m.Level)
	return 0

proc/AhTrunc(t, n)
	if(length(t) <= n) return t
	return "[copytext(t, 1, n - 1)].."

proc/AhLeftTxt(ds)
	if(ds <= 0) return "due"
	var/d = round(ds / 864000)
	var/h = round((ds % 864000) / 36000)
	var/m = round((ds % 36000) / 600)
	if(d) return "[d]d [h]h"
	if(h) return "[h]h [m]m"
	if(m) return "[m]m"
	return "<1m"

proc/AhAgoTxt(rt)
	var/ds = world.realtime - rt
	if(ds < 600) return "just now"
	return "[AhLeftTxt(ds)] ago"

proc/AhCheapestLive(pkey)
	AuctionHouseLoad()
	var/best = 0
	for(var/k in AuctionHouse.listings)
		var/datum/ah_listing/L = AuctionHouse.listings[k]
		if(!L || L.pkey != pkey) continue
		var/u = AhUnitPrice(L)
		if(!best || u < best) best = u
	return best
