#define ST_LAYER (FLY_LAYER + 3.9)
#define ST_ROW_H 26
#define ST_VISIBLE 8
#define ST_ROWS 9            // one buffer row for smooth scrolling
#define ST_ROW_Y0 104
#define ST_BAND_H 208        // ST_VISIBLE * ST_ROW_H
#define ST_TRACK_X 592
#define ST_TRACK_Y 102
#define ST_TRACK_H 206
#define ST_THUMB_H 36

/datum/stentry
	var/kind = "note"      // header | note | smelt | recipe | repair | salvage | metal | gempick | mmatpick | back | mat
	var/label = ""
	var/right = ""
	var/name_col = "#ffffff"
	var/right_col = "#7a9bb5"
	var/icon_file
	var/icon_state = ""
	var/icon_tint
	var/locked = 0
	var/ref

var/list/ST_ICON16 = list()
/proc/StIcon16(f, state)
	if(!f) return null
	var/key = "[f]:[state]"
	if(!ST_ICON16[key])
		var/icon/I = icon(f, state)
		I.Scale(16, 16)
		ST_ICON16[key] = I
	return ST_ICON16[key]

/atom/movable/shud/stbg
	layer = ST_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.STPanelStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.STPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.STPanelEnd()

/atom/movable/shud/stpic
	layer = ST_LAYER + 0.3
	mouse_opacity = 0

/atom/movable/shud/sttext
	layer = ST_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/strowpart
	layer = ST_LAYER + 0.4
	mouse_opacity = 0

/atom/movable/shud/strowtext
	layer = ST_LAYER + 0.42
	mouse_opacity = 0
	maptext_height = 18
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/strow
	icon = 'HUD/tt_rowhit.png'
	layer = ST_LAYER + 0.35
	mouse_opacity = 2
	var/entry_idx = 0
	var/atom/movable/shud/strowpart/band
	var/atom/movable/shud/strowpart/icn
	var/atom/movable/shud/strowtext/nametext
	var/atom/movable/shud/strowtext/righttext
	New()
		..()
		band = new
		band.icon = 'HUD/tt_band.png'
		band.layer = ST_LAYER + 0.36
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
		nametext.maptext_x = 40
		nametext.maptext_y = 4
		nametext.maptext_width = 330
		vis_contents += nametext
		righttext = new
		righttext.maptext_x = 340
		righttext.maptext_y = 6
		righttext.maptext_width = 215
		vis_contents += righttext
	Del()
		for(var/atom/movable/c in list(band, icn, nametext, righttext))
			if(c)
				vis_contents -= c
				del c
		..()
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(!usr.client.StClickInBand(params)) return   // row slivers under the cover strips aren't clickable
		usr.client.StRowClick(entry_idx)

/atom/movable/shud/stbtn
	layer = ST_LAYER + 0.6
	mouse_opacity = 2
	var/action
	var/arg
	var/atom/movable/shud/sttext/lbl
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr) usr.client.StationButton(action, arg)

/atom/movable/shud/stwidget
	parent_type = /atom/movable/shud/pressbtn
	layer = ST_LAYER + 0.65
	mouse_opacity = 2
	DoAction()
		if(usr && usr.client) usr.client.StationButton(action, null)

/atom/movable/shud/sttrack
	layer = ST_LAYER + 0.55
	mouse_opacity = 2
	Click(location, control, params)
		if(usr) usr.client.StScrollTrackTo(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.StScrollTrackTo(params)

/atom/movable/shud/stthumb
	layer = ST_LAYER + 0.56
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.StScrollTrackTo(params)

/atom/movable/shud/stslot        // workbench slot chip
	layer = ST_LAYER + 0.45
	mouse_opacity = 2
	var/arg
	var/locked = 0
	MouseEntered(location, control, params)
		if(!locked) filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(!locked && usr && usr.client) usr.client.StationButton("slot", arg)

/atom/movable/shud/stconfirmbg   // salvage / legendary prompt; right-click dismisses
	layer = ST_LAYER + 1.0
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr && usr.client) usr.client.StPromptAction("no")

/atom/movable/shud/stconfirmbtn
	layer = ST_LAYER + 1.15
	mouse_opacity = 2
	var/action
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.StPromptAction(action)

client
	var/tmp
		stmenu_open = 0
		st_kind = "forge"
		st_tab = "craft"
		st_mode = "list"
		st_scroll_px = 0
		st_scroll_target = 0
		st_scroll_anim = FALSE
		st_atx = 1
		st_aty = 1
		st_pan_x = 0
		st_pan_y = 0
		st_pan_mx = 0
		st_pan_my = 0
		st_pan_ox = 0
		st_pan_oy = 0
		st_pan_dragged = FALSE
		obj/LifeSkills/Station/st_station
		datum/craft_recipe/life/st_recipe
		obj/Items/st_item
		list/st_chrome
		list/st_rows
		list/st_entries
		list/st_tabbtns
		atom/movable/shud/stthumb/st_thumb
		// workbench state
		list/st_bench
		st_metal
		st_metal_q = 0         // chosen ingot quality bucket
		st_proj_scroll = 0     // PROJECTED panel wheel offset
		list/st_gem            // list(gid, quality)
		list/st_mmat           // list(mmid, quality)
		st_pick_slot
		atom/movable/shud/sttext/st_proj_text
		atom/movable/shud/sttext/st_req_text
		atom/movable/shud/stbtn/st_forge_btn
		// confirm / naming
		list/st_confirm_objs
		st_confirm_kind
		obj/Items/st_confirm_item
		obj/Items/st_legend_item
		obj/LifeSkills/Station/st_reopen_station
		datum/craft_recipe/life/st_reopen_recipe
		st_reopen_kind
		st_reopen_metal
		st_reopen_metal_q = 0
		list/st_reopen_gem
		list/st_reopen_mmat

client/proc/STloc(dx, dyTop, h = 0)
	var/py = LS_H - dyTop - h
	var/ax = dx + st_pan_x
	var/ay = py + st_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[st_atx + (ax - axp) / 32]:[axp],[st_aty + (ay - ayp) / 32]:[ayp]"

client/proc/OpenStationMenu(kind, obj/LifeSkills/Station/S)
	if(!mob) return
	if(stmenu_open) CloseStationMenu()
	CloseMenu()
	CloseInventory()
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	CloseLifeSkillsMenu()
	CloseArcaneMenu()
	CloseArcaneAcquire(0)
	stmenu_open = 1
	st_kind = kind
	st_station = S
	st_tab = "craft"
	st_mode = "list"
	st_scroll_px = 0
	st_scroll_target = 0
	st_recipe = null
	st_item = null
	st_metal = null
	st_metal_q = 0
	st_proj_scroll = 0
	st_gem = null
	st_mmat = null
	st_pick_slot = null

	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(LS_W / 32); if(mtw * 32 < LS_W) mtw++
	var/mth = round(LS_H / 32); if(mth * 32 < LS_H) mth++
	st_atx = max(1, round((vw - mtw) / 2) + 1)
	st_aty = max(1, round((vh - mth) / 2) + 1)
	st_pan_x = getPref("stPanX"); if(isnull(st_pan_x)) st_pan_x = 0
	st_pan_y = getPref("stPanY"); if(isnull(st_pan_y)) st_pan_y = 0
	var/list/b = STPanBounds()
	st_pan_x = clamp(st_pan_x, b[1], b[2])
	st_pan_y = clamp(st_pan_y, b[3], b[4])

	BuildStationChrome()
	RefreshStationMenu()
	var/list/all = st_chrome.Copy()
	all += st_rows
	KineticEntrance(all)

client/proc/CloseStationMenu()
	if(!stmenu_open && !st_chrome) return
	stmenu_open = 0
	if(st_confirm_kind == "legname") st_legend_item = null   // an abandoned naming can't block later reopens
	HideStConfirm()
	ClearList(st_bench); st_bench = null
	ClearList(st_rows); st_rows = null
	ClearList(st_chrome); st_chrome = null
	st_entries = null
	st_tabbtns = null
	st_thumb = null
	st_station = null
	st_recipe = null
	st_item = null
	st_metal = null
	st_gem = null
	st_mmat = null
	st_proj_text = null
	st_req_text = null
	st_forge_btn = null

client/proc/ResetStationHUD()
	CloseStationMenu()

client/proc/StMakeTab(tabname, dxLeft)
	var/atom/movable/shud/stbtn/b = new
	b.icon = 'HUD/ui_tab_idle.png'
	b.action = "tab"
	b.arg = tabname
	b.screen_loc = STloc(dxLeft, 44, 32)
	st_chrome += b
	var/atom/movable/shud/sttext/L = new
	L.layer = ST_LAYER + 0.62
	L.maptext_width = 84
	L.maptext_height = 16
	L.screen_loc = STloc(dxLeft, 50, 16)
	st_chrome += L
	b.lbl = L
	st_tabbtns[tabname] = b
	return b

client/proc/BuildStationChrome()
	st_chrome = list()
	st_tabbtns = list()

	var/atom/movable/shud/stbg/P = new
	P.icon = 'HUD/tech_panel.png'
	P.screen_loc = STloc(0, 0, LS_H)
	st_chrome += P

	var/atom/movable/shud/stpic/tp = new
	tp.icon = 'HUD/tech_titleplate.png'
	tp.screen_loc = STloc(212, 6, 32)
	st_chrome += tp
	var/atom/movable/shud/sttext/title = new
	title.maptext_width = 200
	title.maptext_height = 16
	title.screen_loc = STloc(212, 12, 16)
	title.maptext = "<center><span style=\"[LS_FONT]; color:#ffffff\">[uppertext(st_kind == "forge" ? "Forge" : "Anvil")]</span></center>"
	st_chrome += title

	var/atom/movable/shud/stwidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.action = "close"
	X.screen_loc = STloc(590, 12, 24)
	st_chrome += X

	StMakeTab("craft", 18)
	StMakeTab("mats", 116)

	// interior strips clip rows scrolling out of the band
	var/atom/movable/shud/stpic/ct = new
	ct.icon = AqCoverIcon(574, 26)
	ct.layer = ST_LAYER + 0.5
	ct.screen_loc = STloc(18, ST_ROW_Y0 - 26, 26)
	st_chrome += ct
	var/atom/movable/shud/stpic/cb = new
	cb.icon = AqCoverIcon(574, 22)
	cb.layer = ST_LAYER + 0.5
	cb.screen_loc = STloc(18, ST_ROW_Y0 + ST_BAND_H, 22)
	st_chrome += cb

	// no scroll bar
	st_thumb = null

	for(var/atom/movable/o in st_chrome)
		screen += o

	st_rows = list()
	for(var/j = 1 to ST_ROWS)
		var/atom/movable/shud/strow/r = new
		r.screen_loc = STloc(18, ST_ROW_Y0 + (j - 1) * ST_ROW_H, ST_ROW_H)
		r.alpha = 0
		st_rows += r
		screen += r

client/proc/StHeader(t)
	var/datum/stentry/e = new
	e.kind = "header"
	e.label = t
	e.name_col = "#8be9ff"
	st_entries += e

client/proc/StNote(t)
	var/datum/stentry/e = new
	e.kind = "note"
	e.label = t
	e.name_col = LS_C_HINT
	st_entries += e

client/proc/StBuildEntries()
	st_entries = list()
	var/mob/M = mob
	if(!M) return
	InitLifeOreDefs()
	RegisterLifeSkillRecipes()
	var/rank = M.LifeRank("Smithing")

	if(st_tab == "mats")
		StHeader("YOUR MATERIALS")
		RegisterLifeMaterials()
		var/found = 0
		for(var/cat in LifeMatCategories)
			var/catshown = 0
			for(var/mc in LifeMatsInCategory(cat))
				var/total = M.MatLogCount(mc)
				if(total <= 0) continue
				if(!catshown)
					StHeader(uppertext(cat))
					catshown = 1
				var/datum/matdef/d = LifeMatDef(mc)
				var/breakdown = ""
				for(var/q = QUAL_LEGENDARY to QUAL_POOR step -1)
					var/n = M.MatLogCountQ(mc, q)
					if(n) breakdown += "[breakdown ? " &#183; " : ""]<font color=[QualityColor(q)]>[n] [QualityName(q)]</font>"
				var/datum/stentry/e = new
				e.kind = "mat"
				e.label = d ? d.name : mc
				e.right = breakdown ? breakdown : "x[total]"
				e.right_col = LS_C_COST
				e.icon_file = d ? d.icon : null
				e.icon_state = d ? d.icon_state : ""
				st_entries += e
				found++
		if(!found) StNote("Nothing gathered yet. Go crack a vein open.")
		return

	if(st_mode == "bench")
		return   // the bench is a fixed page, no rows

	if(st_mode == "pick" || st_mode == "repairmetal")
		var/datum/stentry/b = new
		b.kind = "back"
		b.label = "< BACK"
		b.name_col = LS_C_HINT
		st_entries += b
		if(st_mode == "pick" && st_recipe && st_pick_slot == "metal")
			StHeader("FORGE [uppertext(st_recipe.label)] FROM...")
			var/mfound = 0
			for(var/mid in LIFE_METALS)
				if(LIFE_METAL_TIER[mid] < st_recipe.metal_min_tier) continue
				if(st_recipe.fixed_metal && mid != st_recipe.fixed_metal) continue
				for(var/mq = QUAL_LEGENDARY to QUAL_POOR step -1)
					var/n = LifeCountExact(M, LIFE_METAL_NAME[mid], mq)
					if(n <= 0) continue
					var/datum/stentry/e = new
					e.kind = "metalpick"
					e.ref = list(mid, mq)
					e.label = "[QualityName(mq)] [LIFE_METAL_NAME[mid]] Ingot (x[n])"
					e.name_col = QualityColor(mq)
					e.icon_file = 'Icons/LifeSkills/Materials.dmi'
					e.icon_state = "ingot_[mid]"
					e.right = "need [st_recipe.ingot_count]"
					e.right_col = (n >= st_recipe.ingot_count) ? LS_C_OK : LS_C_NOFUND
					e.locked = (n < st_recipe.ingot_count)
					st_entries += e
					mfound++
			if(!mfound) StNote("No eligible ingots in your log. Smelt some first.")
		else if(st_mode == "pick" && st_pick_slot == "gem")
			StHeader("SOCKET A GEM")
			var/datum/stentry/none = new
			none.kind = "gemclear"
			none.label = "NONE - leave the socket empty"
			none.name_col = LS_C_HINT
			st_entries += none
			var/found = 0
			for(var/gid in LIFE_GEM_CLASS)
				var/cls = LIFE_GEM_CLASS[gid]
				var/datum/matdef/d = LifeMatDef(cls)
				for(var/q = QUAL_LEGENDARY to QUAL_POOR step -1)
					var/n = LifeCountExact(M, cls, q)
					if(n <= 0) continue
					var/datum/stentry/e = new
					e.kind = "gempick"
					e.ref = list(gid, q)
					e.label = "[QualityName(q)] [d ? d.name : gid] (x[n])"
					e.name_col = QualityColor(q)
					e.right = GemStatLine(gid, q)
					e.icon_file = d ? d.icon : 'Icons/LifeSkills/Materials.dmi'
					e.icon_state = d ? d.icon_state : "gem_[gid]"
					st_entries += e
					found++
			if(!found) StNote("No gems in your log. Crack some veins open.")
		else if(st_mode == "pick" && st_pick_slot == "mmat")
			StHeader("WORK IN A MONSTER MATERIAL")
			var/datum/stentry/none = new
			none.kind = "mmatclear"
			none.label = "NONE - plain steelwork"
			none.name_col = LS_C_HINT
			st_entries += none
			var/found = 0
			for(var/mc in LifeMatsInCategory("Monster Parts"))
				var/datum/matdef/d = LifeMatDef(mc)
				for(var/q = QUAL_LEGENDARY to QUAL_POOR step -1)
					var/n = LifeCountExact(M, mc, q)
					if(n <= 0) continue
					var/datum/stentry/e = new
					e.kind = "mmatpick"
					e.ref = list(mc, q)
					e.label = "[QualityName(q)] [d ? d.name : mc] (x[n])"
					e.name_col = QualityColor(q)
					e.right = LifeMonsterMatLine(mc, q)
					e.icon_file = d ? d.icon : 'Icons/LifeSkills/Materials.dmi'
					e.icon_state = d ? d.icon_state : ""
					st_entries += e
					found++
			if(!found) StNote("Nothing from the hunt yet. Hunting brings these.")
		else if(st_mode == "repairmetal" && st_item)
			StHeader("REPAIR [uppertext("[st_item]")] WITH...")
			for(var/mid in LIFE_METALS)
				if(CountMaterial(M, LIFE_METAL_NAME[mid]) < 2) continue
				var/datum/stentry/e = new
				e.kind = "metal"
				e.ref = mid
				e.label = "[LIFE_METAL_NAME[mid]] Ingot"
				e.right = "have [CountMaterial(M, LIFE_METAL_NAME[mid])]"
				e.right_col = LS_C_OK
				e.icon_file = 'Icons/LifeSkills/Materials.dmi'
				e.icon_state = "ingot_[mid]"
				st_entries += e
		return

	if(st_kind == "forge")
		StHeader("SMELT - BATCHES OF [max(1, M.SmithingLevel())]")
		var/cap = LifeTierCap(rank)
		for(var/mid in LIFE_METALS)
			var/t = LIFE_METAL_TIER[mid]
			var/datum/stentry/e = new
			e.kind = "smelt"
			e.ref = mid
			e.label = "[LIFE_METAL_NAME[mid]] Ingot"
			e.icon_file = 'Icons/LifeSkills/Materials.dmi'
			e.icon_state = "ingot_[mid]"
			if(t > cap)
				e.locked = 1
				e.name_col = LS_C_LOCKED
				e.right = "Smithing rank [t * 2 - 1]"
				e.right_col = LS_C_LOCKED
			else
				var/can = LifeCanSmelt(M, mid)
				e.right = LifeSmeltReqText(M, mid)
				e.right_col = can ? LS_C_OK : LS_C_NOFUND
				if(!can) e.name_col = LS_C_LOCKED
			st_entries += e
		return

	// anvil
	StHeader("FORGE")
	for(var/datum/craft_recipe/life/R in LifeRecipeRegistry)
		var/datum/stentry/e = new
		e.kind = "recipe"
		e.ref = R
		e.label = R.label
		var/list/disp = StRecipeIcon(R)
		e.icon_file = disp[1]
		e.icon_state = disp[2]
		if(R.rank_req > rank)
			e.locked = 1
			e.name_col = LS_C_LOCKED
			e.right = "Smithing rank [R.rank_req]"
			e.right_col = LS_C_LOCKED
		else
			var/money = R.money_cost ? round(R.money_cost * glob.progress.EconomyCost) : 0
			if(R.fixed_metal)
				e.right = "[R.ingot_count]x [LIFE_METAL_NAME[R.fixed_metal]] ingot[R.wood_count ? " + [R.wood_count]x wood" : ""]"
				e.right_col = (LifeEligibleMetals(mob, R).len && (!R.wood_count || LifeCountAnyWood(mob) >= R.wood_count)) ? LS_C_OK : LS_C_NOFUND
			else
				e.right = "[R.ingot_count]x tier [R.metal_min_tier]+ ingots[money ? " + $[Commas(money)]" : ""]"
				e.right_col = LifeEligibleMetals(mob, R).len ? LS_C_OK : LS_C_NOFUND
		st_entries += e
	var/list/broken = LifeRepairableItems(M)
	if(broken.len && rank < 3)
		StNote("Smith Repair unlocks at Smithing rank 3.")
	else if(broken.len)
		StHeader("REPAIR - 2 INGOTS + [LIFE_REFORGE_LS_COST] STAMINA + 25% COST")
		for(var/obj/Items/I in broken)
			var/datum/stentry/e = new
			e.kind = "repair"
			e.ref = I
			e.label = "[I.name]"
			e.icon_file = I.icon
			e.icon_state = I.icon_state
			e.right = "$[Commas(round(ReforgeCostFor(M, I) * 0.25, 1))]"
			e.right_col = LS_C_COST
			st_entries += e
	var/list/scrap = LifeSalvageableItems(M)
	if(scrap.len && rank >= LIFE_SALVAGE_RANK)
		StHeader("SALVAGE - BARS BACK, A GRADE DULLER")
		for(var/obj/Items/I in scrap)
			var/n = max(1, round(max(1, I.craft_ingots) * min(0.75, 0.25 + 0.05 * rank)))
			if(I.Broken) n = max(1, round(n / 2))
			var/datum/stentry/e = new
			e.kind = "salvage"
			e.ref = I
			e.label = "[I.name]"
			e.icon_file = I.icon
			e.icon_state = I.icon_state
			e.icon_tint = I.color
			e.right = "[n]x [LIFE_METAL_NAME[I.metal_id]] Ingot ([QualityName(max(QUAL_POOR, I.CraftQuality - 1))])"
			e.right_col = LS_C_COST
			st_entries += e
	var/list/upg = LifeAscendableItems(M)
	if(upg.len)
		var/wcap = LifeAscendCeiling(M, null)
		StHeader("ASCEND - CAP [wcap][wcap > 4 ? " (ARMOR 4)" : ""]")
		for(var/obj/Items/I in upg)
			var/datum/stentry/e = new
			e.kind = "ascend"
			e.ref = I
			e.label = "[I.name]"
			e.icon_file = I.icon
			e.icon_state = I.icon_state
			e.icon_tint = I.color
			var/acost = LifeAscendCost(I)
			e.right = "Asc [I.Ascended] > [I.Ascended + 1] - $[Commas(acost)]"
			e.right_col = M.HasMoney(acost) ? LS_C_COST : LS_C_NOFUND
			st_entries += e

/proc/StRecipeIcon(datum/craft_recipe/life/R)
	if(R.tool_kind)
		return list('Icons/LifeSkills/Tools.dmi', "[lowertext(R.tool_kind)]_iron")
	var/obj/Items/T = new R.result_type
	var/list/out = list(T.icon, T.icon_state)
	del T
	return out

client/proc/RefreshStationMenu()
	if(!stmenu_open || !mob) return
	StBuildEntries()
	RefreshStationRows()
	if(st_mode == "bench")
		RefreshBenchPage()
	else
		ClearList(st_bench)
		st_bench = null
	RefreshStTabLook()

client/proc/StBenchAdd(atom/movable/o)
	if(!st_bench) st_bench = list()
	st_bench += o
	screen += o

client/proc/StBenchText(dx, dyTop, w, h, txt, lay = 0.6)
	var/atom/movable/shud/sttext/T = new
	T.layer = ST_LAYER + lay
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = STloc(dx, dyTop, h)
	T.maptext = txt
	StBenchAdd(T)
	return T

// a themed frame/panel background, low layer, drag-enabled like the main panel
client/proc/StBenchBG(icon_file, dx, dyTop, h, lay = 0.15)
	var/atom/movable/shud/stbg/o = new
	o.icon = icon_file
	o.layer = ST_LAYER + lay
	o.screen_loc = STloc(dx, dyTop, h)
	StBenchAdd(o)
	return o

client/proc/RefreshBenchPage()
	ClearList(st_bench)
	st_bench = list()
	if(!st_recipe || !mob) return
	var/mob/M = mob
	var/datum/craft_recipe/life/R = st_recipe
	var/rank = M.LifeRank("Smithing")
	var/gear = (ispath(R.result_type, /obj/Items/Sword) || ispath(R.result_type, /obj/Items/Armor))

	// selections must still exist in the log
	if(st_metal && LifeCountExact(M, LIFE_METAL_NAME[st_metal], st_metal_q) <= 0)
		st_metal = null
		st_metal_q = 0
	if(!st_metal)
		var/list/ap = StAutoPickMetal(M, R)
		if(ap)
			st_metal = ap[1]
			st_metal_q = ap[2]
	if(st_gem && st_gem.len >= 2 && !LifeCountExact(M, LIFE_GEM_CLASS[st_gem[1]], st_gem[2])) st_gem = null
	if(st_mmat && st_mmat.len >= 2 && !LifeCountExact(M, st_mmat[1], st_mmat[2])) st_mmat = null

	// frames: container, header bar, left + right sub-panels
	StBenchBG('HUD/frame_forgecont.png', 14, 78, 250, 0.1)
	StBenchBG('HUD/frame_forgehdr.png', 24, 86, 30, 0.15)
	StBenchBG('HUD/frame_forgesub.png', 24, 122, 194, 0.15)
	StBenchBG('HUD/frame_forgesub.png', 316, 122, 194, 0.15)

	// header: recipe icon + name (left), BACK chip (right, clear of the CRAFT/MATERIALS tabs)
	var/obj/Items/T = LifeRecipeTemplate(R)
	var/atom/movable/shud/stpic/ric = new
	ric.icon = StIcon16(R.tool_kind ? 'Icons/LifeSkills/Tools.dmi' : T.icon, R.tool_kind ? "[lowertext(R.tool_kind)]_iron" : T.icon_state)
	ric.layer = ST_LAYER + 0.6
	ric.screen_loc = STloc(32, 90, 16)
	StBenchAdd(ric)
	StBenchText(56, 90, 300, 18, "<span style=\"[LS_FONT]; color:#8be9ff\">[uppertext(R.label)]</span>")
	var/atom/movable/shud/stbtn/back = new
	back.icon = 'HUD/st_backhit.png'   // baked strip, the icon is the click box
	back.action = "benchback"
	back.screen_loc = STloc(526, 88, 22)
	StBenchAdd(back)
	StBenchText(526, 90, 64, 16, "<center><span style=\"[LS_FONT]; color:#8be9ff\">&lt; BACK</span></center>", 0.62)

	// LEFT sub-panel: MATERIALS
	StBenchText(38, 128, 200, 16, "<span style=\"[LS_FONT]; color:#8be9ff\">MATERIALS</span>")
	StBenchChip("metal", 150, st_metal ? "METAL: [QualityName(st_metal_q)] [LIFE_METAL_NAME[st_metal]]" : "METAL: pick one", st_metal ? "[LifeCountExact(M, LIFE_METAL_NAME[st_metal], st_metal_q)]/[R.ingot_count]" : "", st_metal ? ((LifeCountExact(M, LIFE_METAL_NAME[st_metal], st_metal_q) >= R.ingot_count) ? LS_C_OK : LS_C_NOFUND) : LS_C_NOFUND, st_metal ? StIcon16('Icons/LifeSkills/Materials.dmi', "ingot_[st_metal]") : null, 0)
	if(gear)
		if(rank >= LIFE_MAT_SLOT_RANK)
			var/datum/matdef/mmd = st_mmat ? LifeMatDef(st_mmat[1]) : null
			StBenchChip("mmat", 180, st_mmat ? "MATERIAL: [QualityName(st_mmat[2])] [mmd ? mmd.name : st_mmat[1]]" : "MONSTER MAT: none", "", LS_C_HINT, mmd ? StIcon16(mmd.icon, mmd.icon_state) : null, 0)
		else
			StBenchChip("mmat", 180, "MONSTER MAT", "rank [LIFE_MAT_SLOT_RANK]", LS_C_LOCKED, null, 1)
		if(rank >= LIFE_GEM_SLOT_RANK)
			var/datum/matdef/gmd = st_gem ? LifeMatDef(LIFE_GEM_CLASS[st_gem[1]]) : null
			StBenchChip("gem", 210, st_gem ? "GEM: [QualityName(st_gem[2])] [gmd ? gmd.name : st_gem[1]]" : "GEM: empty socket", "", LS_C_HINT, gmd ? StIcon16(gmd.icon, gmd.icon_state) : null, 0)
		else
			StBenchChip("gem", 210, "GEM SOCKET", "rank [LIFE_GEM_SLOT_RANK]", LS_C_LOCKED, null, 1)

	// requirements strip (inside the left panel)
	var/cost = R.money_cost ? round(R.money_cost * glob.progress.EconomyCost) : 0
	var/have = st_metal ? LifeCountExact(M, LIFE_METAL_NAME[st_metal], st_metal_q) : 0
	var/req = ""
	if(st_metal)
		req += "<font color=[(have >= R.ingot_count) ? LS_C_OK : LS_C_NOFUND]>[R.ingot_count]x [QualityName(st_metal_q)] [LIFE_METAL_NAME[st_metal]] (have [have])</font>"
	else
		req += "<font color=[LS_C_NOFUND]>pick a metal</font>"
	if(R.wood_count) req += " <font color=[(LifeCountAnyWood(M) >= R.wood_count) ? LS_C_OK : LS_C_NOFUND]>+ [R.wood_count]x wood</font>"
	if(cost) req += " <font color=[M.HasMoney(cost) ? LS_C_OK : LS_C_NOFUND]>+ $[Commas(cost)]</font>"
	req += " <font color=[(M.LifeStamina >= LIFE_COST_CRAFT) ? LS_C_OK : LS_C_NOFUND]>+ [LIFE_COST_CRAFT] Stam</font>"
	StBenchText(38, 246, 258, 30, "<span style=\"[LS_FONT_BODY]\">[req]</span>")

	// FORGE button (bottom of the left panel)
	var/blocker = null
	if(!st_metal) blocker = "PICK A METAL"
	else if(have < R.ingot_count) blocker = "NEED INGOTS"
	else if(R.wood_count && LifeCountAnyWood(M) < R.wood_count) blocker = "NEED WOOD"
	else if(cost && !M.HasMoney(cost)) blocker = "NEED $"
	else if(M.LifeStamina < LIFE_COST_CRAFT) blocker = "WORN OUT"
	st_forge_btn = new
	st_forge_btn.icon = 'HUD/log_btn_md.png'
	st_forge_btn.alpha = blocker ? 150 : 255
	st_forge_btn.action = "forge"
	st_forge_btn.screen_loc = STloc(76, 282, 24)
	StBenchAdd(st_forge_btn)
	var/atom/movable/shud/stbtn/fl = new
	fl.icon = null
	fl.action = "forge"
	fl.maptext_width = 180
	fl.maptext_height = 16
	fl.maptext = "<center><span style=\"[LS_FONT]; color:[blocker ? LS_C_LOCKED : "#78eb78"]\">[blocker ? blocker : "FORGE"]</span></center>"
	fl.layer = ST_LAYER + 0.62
	fl.screen_loc = STloc(76, 285, 16)
	StBenchAdd(fl)

	// RIGHT sub-panel: PROJECTED (stats sit right under the header now)
	var/D = st_metal ? LIFE_GEAR_DIFF(LIFE_METAL_TIER[st_metal], R.shape_diff) : 0
	StBenchText(330, 128, 258, 16, "<span style=\"[LS_FONT]; color:#8be9ff\">PROJECTED[D ? "<font color=[LS_C_HINT]> - diff [D][D - rank >= 4 ? " (deep)" : ""]</font>" : ""]</span>")
	var/body
	if(!st_metal)
		body = "<font color=[LS_C_HINT]>Pick a metal to see what it makes of this.</font>"
	else if(gear)
		body = LifeProjectGearStats(M, R, st_metal, st_gem, st_mmat, st_metal_q)
	else
		body = "<font color=[LS_C_HINT]>Quality [QualityName(LIFE_QFLOOR_BY_RANK[clamp(rank, 1, LIFE_MAX_RANK)])] - [QualityName(LifeQualityCap(rank))], rolled from your bars and your hands.</font>"
	var/list/plines = list()
	for(var/pl in splittext(body, "<br>"))
		if(length(pl)) plines += pl
	var/pshow = 9
	var/pmax = max(0, plines.len - pshow)
	st_proj_scroll = clamp(st_proj_scroll, 0, pmax)
	var/py = 148
	for(var/i = st_proj_scroll + 1 to min(plines.len, st_proj_scroll + pshow))
		StBenchText(330, py, 258, 16, "<span style=\"[LS_FONT_BODY]; color:#cfe3f5\">[plines[i]]</span>")
		py += 17
	if(pmax)
		StBenchText(330, 302, 258, 12, "<span style=\"[LS_FONT_BODY]; color:[LS_C_HINT]\">scroll - [st_proj_scroll + 1]-[min(plines.len, st_proj_scroll + pshow)] / [plines.len]</span>")

client/proc/StAutoPickMetal(mob/M, datum/craft_recipe/life/R)
	var/list/best
	var/bestscore = -1
	for(var/mid in LIFE_METALS)
		if(LIFE_METAL_TIER[mid] < R.metal_min_tier) continue
		if(R.fixed_metal && mid != R.fixed_metal) continue
		for(var/mq = QUAL_LEGENDARY to QUAL_POOR step -1)
			var/n = LifeCountExact(M, LIFE_METAL_NAME[mid], mq)
			if(n <= 0) continue
			var/score = (n >= R.ingot_count ? 1000 : 0) + LIFE_METAL_TIER[mid] * 10 + mq
			if(score > bestscore)
				bestscore = score
				best = list(mid, mq)
	return best

client/proc/StBenchChip(slotname, dyTop, label, right, right_col, chipicon, locked)
	var/cx = 36, cw = 262
	var/atom/movable/shud/stslot/c = new
	c.icon = 'HUD/st_chiphit.png'   
	c.arg = slotname
	c.locked = locked
	c.screen_loc = STloc(cx, dyTop, 26)
	StBenchAdd(c)
	var/tx = cx + 8
	if(chipicon)
		var/atom/movable/shud/stpic/gi = new
		gi.icon = chipicon
		gi.layer = ST_LAYER + 0.5
		gi.screen_loc = STloc(cx + 6, dyTop + 5, 16)
		StBenchAdd(gi)
		tx = cx + 28
	StBenchText(tx, dyTop + 5, 170, 16, "<span style=\"[LS_FONT]; color:[locked ? LS_C_LOCKED : "#ffffff"]\">[label]</span>")
	if(right)
		StBenchText(cx + cw - 90, dyTop + 7, 84, 16, "<span style=\"[LS_FONT_BODY]; color:[right_col]; text-align:right\">[right]</span>")

client/proc/StPaintRow(atom/movable/shud/strow/r, idx)
	var/datum/stentry/e = st_entries[idx]
	r.entry_idx = idx
	r.alpha = 255
	r.mouse_opacity = (e.kind == "header" || e.kind == "note") ? 0 : 2
	r.band.alpha = (e.kind == "header") ? 255 : 0
	if(e.kind == "header" || e.kind == "note")
		// label rides centered inside the band strip
		r.icn.alpha = 0
		r.nametext.maptext_x = 0
		r.nametext.maptext_width = 560
		r.nametext.maptext_y = (e.kind == "header") ? 7 : 9
		r.nametext.maptext = "<center><span style=\"[e.kind == "header" ? LS_FONT : LS_FONT_BODY]; color:[e.name_col]\">[e.label]</span></center>"
		r.righttext.maptext = ""
		return
	if(e.icon_file)
		r.icn.icon = StIcon16(e.icon_file, e.icon_state)
		r.icn.color = e.icon_tint
		r.icn.alpha = 255
	else
		r.icn.alpha = 0
	r.nametext.maptext_x = 40
	r.nametext.maptext_width = 330
	r.nametext.maptext_y = 4
	r.nametext.maptext = "<span style=\"[LS_FONT]; color:[e.name_col]\">[e.label]</span>"
	r.righttext.maptext = "<span style=\"[LS_FONT_BODY]; color:[e.right_col]; text-align:right\">[e.right]</span>"

// virtualized band scroller, same shape as RefreshAcquireRows
client/proc/RefreshStationRows()
	if(!st_rows || !st_entries) return
	var/total = st_entries.len
	var/maxpx = max(0, total * ST_ROW_H - ST_BAND_H)
	st_scroll_px = clamp(st_scroll_px, 0, maxpx)
	st_scroll_target = clamp(st_scroll_target, 0, maxpx)
	var/sub = st_scroll_px % ST_ROW_H
	var/first = (st_scroll_px - sub) / ST_ROW_H
	for(var/j = 1 to st_rows.len)
		var/atom/movable/shud/strow/r = st_rows[j]
		var/dyTop = ST_ROW_Y0 + (j - 1) * ST_ROW_H - sub
		r.screen_loc = STloc(18, dyTop, ST_ROW_H)
		var/idx = first + j
		if(idx <= total && dyTop < ST_ROW_Y0 + ST_BAND_H - 4)
			StPaintRow(r, idx)
		else
			r.entry_idx = 0
			r.alpha = 0
			r.band.alpha = 0
			r.icn.alpha = 0
			r.nametext.maptext = ""
			r.righttext.maptext = ""
	if(st_thumb)
		if(maxpx <= 0)
			st_thumb.alpha = (total > 0) ? 80 : 0
			st_thumb.screen_loc = STloc(ST_TRACK_X + 1, ST_TRACK_Y, ST_THUMB_H)
		else
			st_thumb.alpha = 255
			var/off = round((st_scroll_px / maxpx) * (ST_TRACK_H - ST_THUMB_H))
			st_thumb.screen_loc = STloc(ST_TRACK_X + 1, ST_TRACK_Y + off, ST_THUMB_H)

client/proc/RefreshStTabLook()
	if(!st_tabbtns) return
	for(var/tabname in st_tabbtns)
		var/atom/movable/shud/stbtn/b = st_tabbtns[tabname]
		if(!b) continue
		b.icon = (st_tab == tabname) ? 'HUD/ui_tab_active.png' : 'HUD/ui_tab_idle.png'
		if(b.lbl)
			b.lbl.maptext = "<center><span style=\"[LS_FONT]; color:[st_tab == tabname ? "#06283b" : "#cfe3f5"]\">[tabname == "craft" ? "CRAFT" : "MATERIALS"]</span></center>"

client/proc/StationButton(action, arg)
	if(!stmenu_open) return
	switch(action)
		if("close")
			CloseStationMenu()
		if("tab")
			if(st_confirm_kind && st_confirm_kind != "legname") StPromptAction("no")   // navigation drops any open prompt except a pending naming
			st_tab = arg
			st_mode = "list"
			st_recipe = null
			st_scroll_px = 0
			st_scroll_target = 0
			RefreshStationMenu()
		if("slot")
			if(st_mode != "bench") return
			if(st_confirm_kind && st_confirm_kind != "legname") StPromptAction("no")
			st_pick_slot = arg
			st_mode = "pick"
			st_scroll_px = 0
			st_scroll_target = 0
			RefreshStationMenu()
		if("benchback")
			if(st_confirm_kind && st_confirm_kind != "legname") StPromptAction("no")
			st_mode = "list"
			st_recipe = null
			st_metal = null
			st_gem = null
			st_mmat = null
			RefreshStationMenu()
		if("forge")
			if(st_mode != "bench" || !st_recipe || !mob) return
			var/mob/M = mob
			var/datum/craft_recipe/life/R = st_recipe
			if(!st_metal)
				M << "Pick a metal first."
				return
			var/cost = R.money_cost ? round(R.money_cost * glob.progress.EconomyCost) : 0
			if(LifeCountExact(M, LIFE_METAL_NAME[st_metal], st_metal_q) < R.ingot_count)
				M << "You need [R.ingot_count]x [QualityName(st_metal_q)] [LIFE_METAL_NAME[st_metal]] ingots."
				return
			if(R.wood_count && LifeCountAnyWood(M) < R.wood_count)
				M << "You need [R.wood_count]x wood of any kind for the haft."
				return
			if(cost && !M.HasMoney(cost))
				M << "You need $[Commas(cost)] for supplies."
				return
			if(M.LifeStamina < LIFE_COST_CRAFT)
				M << "You're too worn out to craft. ([LIFE_COST_CRAFT] Life Stamina needed)"
				return
			var/obj/LifeSkills/Station/S = st_station
			var/mid = st_metal
			var/list/gem = st_gem
			var/list/mmat = st_mmat
			st_reopen_station = S
			st_reopen_recipe = R
			st_reopen_kind = st_kind
			st_reopen_metal = mid
			st_reopen_metal_q = st_metal_q
			st_reopen_gem = gem
			st_reopen_mmat = mmat
			CloseStationMenu()
			spawn() M.DoForge(S, R, mid, gem, mmat, st_metal_q)

client/proc/StWheelScroll(delta_y)
	if(!stmenu_open) return 0
	if(st_mode == "bench" && st_recipe)
		st_proj_scroll += (delta_y > 0 ? -1 : 1)
		RefreshStationMenu()
		return 1
	if(!st_entries) return 0
	var/maxpx = max(0, st_entries.len * ST_ROW_H - ST_BAND_H)
	var/dir = (delta_y > 0) ? -1 : 1
	st_scroll_target = clamp(st_scroll_target + dir * ST_ROW_H * 2, 0, maxpx)
	if(!st_scroll_anim) AnimateStScroll()
	return 1

client/proc/AnimateStScroll()
	set waitfor = 0
	st_scroll_anim = TRUE
	while(stmenu_open && st_entries && st_scroll_px != st_scroll_target)
		var/diff = st_scroll_target - st_scroll_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1
		st_scroll_px += stepp
		RefreshStationRows()
		sleep(world.tick_lag)
	st_scroll_anim = FALSE

client/proc/StScrollTrackTo(params)
	if(!stmenu_open || !st_entries) return
	var/maxpx = max(0, st_entries.len * ST_ROW_H - ST_BAND_H)
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
	var/local_h = (row - 1) * 32 + py - (st_aty - 1) * 32 - st_pan_y
	var/frac = ((LS_H - ST_TRACK_Y) - local_h) / ST_TRACK_H
	frac = clamp(frac, 0, 1)
	st_scroll_px = round(frac * maxpx)
	st_scroll_target = st_scroll_px          // cancel any running wheel glide
	RefreshStationRows()

client/proc/StClickInBand(params)
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
	var/dyTop = LS_H - ((row - 1) * 32 + py - (st_aty - 1) * 32 - st_pan_y)
	return (dyTop >= ST_ROW_Y0 && dyTop <= ST_ROW_Y0 + ST_BAND_H)

client/proc/StRowClick(idx)
	if(!stmenu_open || !mob || !st_entries) return
	if(idx < 1 || idx > st_entries.len) return
	// any row click drops an open prompt - except a pending legendary naming, that one waits for its answer
	if(st_confirm_kind && st_confirm_kind != "legname") StPromptAction("no")
	var/datum/stentry/e = st_entries[idx]
	var/mob/M = mob
	switch(e.kind)
		if("back")
			st_mode = (st_mode == "pick" && st_recipe) ? "bench" : "list"
			if(st_mode == "list")
				st_recipe = null
			st_item = null
			st_pick_slot = null
			RefreshStationMenu()
		if("smelt")
			if(e.locked) return
			var/mid = e.ref
			// the menu comes down so the minigame isn't buried under it, then walks back in
			var/obj/LifeSkills/Station/S = st_station
			st_reopen_station = S
			st_reopen_recipe = null
			st_reopen_kind = st_kind
			CloseStationMenu()
			spawn() M.DoSmelt(S, mid)
		if("recipe")
			if(e.locked) return
			st_recipe = e.ref
			st_mode = "bench"
			st_metal = null
			st_gem = null
			st_mmat = null
			RefreshStationMenu()
		if("repair")
			var/obj/Items/I = e.ref
			var/list/mids = list()
			for(var/mid in LIFE_METALS)
				if(CountMaterial(M, LIFE_METAL_NAME[mid]) >= 2) mids += mid
			if(!mids.len)
				M << "You need 2 ingots of one metal to smith-repair."
				return
			if(mids.len == 1)
				spawn() M.DoSmithRepair(st_station, I, mids[1])
			else
				st_mode = "repairmetal"
				st_item = I
				st_scroll_px = 0
				st_scroll_target = 0
				RefreshStationMenu()
		if("salvage")
			var/obj/Items/I = e.ref
			if(!I)
				RefreshStationMenu()
				return
			ShowStConfirm("salvage", I, "SALVAGE?", "[e.right][I.gem_id ? " - <font color=#ff6464>the [LIFE_GEM_CLASS[I.gem_id]] is lost</font>" : ""]")
		if("ascend")
			var/obj/Items/I = e.ref
			if(!I)
				RefreshStationMenu()
				return
			ShowStConfirm("ascend", I, "ASCEND?", "[I.name]<br>Ascension [I.Ascended] > [I.Ascended + 1] - $[Commas(LifeAscendCost(I))]")
		if("metalpick")
			if(e.locked) return
			var/list/mr = e.ref
			st_metal = mr[1]
			st_metal_q = mr[2]
			st_mode = "bench"
			RefreshStationMenu()
		if("metal")
			var/mid = e.ref
			if(st_mode == "repairmetal" && st_item)
				var/obj/Items/I = st_item
				st_mode = "list"
				st_item = null
				RefreshStationMenu()
				spawn() M.DoSmithRepair(st_station, I, mid)
		if("gempick")
			st_gem = e.ref
			st_mode = "bench"
			RefreshStationMenu()
		if("gemclear")
			st_gem = null
			st_mode = "bench"
			RefreshStationMenu()
		if("mmatpick")
			st_mmat = e.ref
			st_mode = "bench"
			RefreshStationMenu()
		if("mmatclear")
			st_mmat = null
			st_mode = "bench"
			RefreshStationMenu()

client/proc/STPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (st_atx - 1) * 32
	var/by = (st_aty - 1) * 32
	var/minx = -bx
	if(minx > 0) minx = 0
	var/maxx = vw * 32 - LS_W - bx
	if(maxx < 0) maxx = 0
	var/miny = -by
	if(miny > 0) miny = 0
	var/maxy = vh * 32 - LS_H - by
	if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/STShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	for(var/atom/movable/o in st_chrome)
		if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(st_rows)
		for(var/atom/movable/o in st_rows)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(st_bench)
		for(var/atom/movable/o in st_bench)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(st_confirm_objs)
		for(var/atom/movable/o in st_confirm_objs)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/STPanelStart(params)
	st_pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	st_pan_mx = m[1]; st_pan_my = m[2]
	st_pan_ox = st_pan_x; st_pan_oy = st_pan_y

client/proc/STPanelMove(params)
	if(!stmenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = STPanBounds()
	var/wantx = clamp(st_pan_ox + (m[1] - st_pan_mx), b[1], b[2])
	var/wanty = clamp(st_pan_oy + (m[2] - st_pan_my), b[3], b[4])
	var/dx = wantx - st_pan_x
	var/dy = wanty - st_pan_y
	if(!dx && !dy) return
	st_pan_x = wantx; st_pan_y = wanty
	st_pan_dragged = TRUE
	STShiftLive(dx, dy)

client/proc/STPanelEnd()
	if(!st_pan_dragged) return
	st_pan_dragged = FALSE
	RefreshStationRows()          // re-sync rows/thumb to the baked pan
	setPref("stPanX", st_pan_x)
	setPref("stPanY", st_pan_y)

// ---------------- themed confirm + legendary naming ----------------

client/proc/StMkPromptBtn(action, label, color, dx, dyTop)
	var/atom/movable/shud/stconfirmbtn/b = new
	b.icon = 'HUD/pbtn.png'
	b.action = action
	b.screen_loc = STloc(dx, dyTop, 24)
	st_confirm_objs += b
	screen += b
	var/atom/movable/shud/sttext/L = new
	L.layer = ST_LAYER + 1.2
	L.maptext_width = 80
	L.maptext_height = 24
	L.maptext_y = 6
	L.screen_loc = STloc(dx, dyTop, 24)
	L.maptext = "<center><span style=\"[LS_FONT]; color:[color]\">[label]</span></center>"
	st_confirm_objs += L
	screen += L

client/proc/ShowStConfirm(kind, obj/Items/I, title, line, yestext = "Yes", notext = "No")
	if(st_confirm_kind == "legname" && kind != "legname") return   // the naming prompt holds until it's answered
	HideStConfirm()
	st_confirm_kind = kind
	st_confirm_item = I
	st_confirm_objs = list()

	var/atom/movable/shud/stconfirmbg/bg = new
	bg.icon = 'HUD/party_prompt.png'
	bg.screen_loc = STloc(200, 102, 140)
	st_confirm_objs += bg
	screen += bg

	var/atom/movable/shud/sttext/nm = new
	nm.layer = ST_LAYER + 1.2
	nm.maptext_width = 208
	nm.maptext_height = 32
	nm.screen_loc = STloc(208, 132, 32)
	nm.maptext = "<center><span style=\"[LS_FONT]; color:[LS_C_COST]\">[title]</span></center>"
	st_confirm_objs += nm
	screen += nm

	var/atom/movable/shud/sttext/q = new
	q.layer = ST_LAYER + 1.2
	q.maptext_width = 208
	q.maptext_height = 32
	q.screen_loc = STloc(208, 168, 32)
	q.maptext = "<center><span style=\"[LS_FONT_BODY]; color:#bfefff\">[line]</span></center>"
	st_confirm_objs += q
	screen += q

	StMkPromptBtn("yes", yestext, LS_C_OK, 220, 205)
	StMkPromptBtn("no", notext, LS_C_NOFUND, 324, 205)
	KineticEntrance(st_confirm_objs)

client/proc/HideStConfirm()
	ClearList(st_confirm_objs)
	st_confirm_objs = null
	st_confirm_kind = null
	st_confirm_item = null

client/proc/StPromptAction(action)
	var/kind = st_confirm_kind
	var/obj/Items/I = st_confirm_item
	HideStConfirm()
	if(!mob) return
	switch(kind)
		if("salvage")
			if(action == "yes" && stmenu_open && I)
				var/mob/M = mob
				spawn() M.DoSmithSalvage(st_station, I)
		if("ascend")
			if(action == "yes" && stmenu_open && I)
				var/mob/M = mob
				spawn() M.DoSmithAscend(st_station, I)
		if("legname")
			if(action == "yes")
				StOpenLegendNameInput()
			else
				st_legend_item = null

// after the forge chain ends: refresh if the menu survived, otherwise walk back to the bench
client/proc/StForgeDone()
	if(stmenu_open)
		RefreshStationMenu()
		return
	var/obj/LifeSkills/Station/S = st_reopen_station
	var/datum/craft_recipe/life/R = st_reopen_recipe
	var/kind = st_reopen_kind ? st_reopen_kind : "anvil"
	var/mid = st_reopen_metal
	var/mq = st_reopen_metal_q
	var/list/gem = st_reopen_gem
	var/list/mmat = st_reopen_mmat
	st_reopen_station = null
	st_reopen_recipe = null
	st_reopen_kind = null
	st_reopen_metal = null
	st_reopen_metal_q = 0
	st_reopen_gem = null
	st_reopen_mmat = null
	if(!S || !mob || mob.KO || mob.Dead || get_dist(mob, S) > 1) return
	if(st_confirm_objs || st_legend_item) return   // don't stomp a legendary prompt
	OpenStationMenu(kind, S)
	if(R)
		st_recipe = R
		st_mode = "bench"
		st_metal = mid          // the picks come back; the bench validation clears anything consumed
		st_metal_q = mq
		st_gem = gem
		st_mmat = mmat
		RefreshStationMenu()

client/proc/ShowLegendNamePrompt(obj/Items/I)
	if(!I) return
	st_legend_item = I
	ShowStConfirm("legname", I, "A LEGENDARY WORK", "<font color=[QualityColor(QUAL_LEGENDARY)]>[I.name]</font><br>Name it for the ages?", "NAME IT", "LET IT BE")

client/proc/StOpenLegendNameInput()
	if(!st_legend_item) return
	var/list/wl = splittext(winget(src, null, "windows"), ";")
	if(!wl.len) return
	var/list/sz = splittext(winget(src, wl[1], "size"), "x")
	var/wx = (sz.len >= 1 && text2num(sz[1])) ? text2num(sz[1]) : 800
	var/wy = (sz.len >= 2 && text2num(sz[2])) ? text2num(sz[2]) : 600
	winset(src, "st_legname", "parent=[wl[1]];type=input;pos=[round(wx / 2 - 120)],[round(wy / 2 - 11)];size=240x22;is-visible=true;border=sunken;command=Set-Legend-Name;focus=true")
	mob << "Type the name and press Enter."

mob/verb/Set_Legend_Name(t as text)
	set name = "Set Legend Name"
	set hidden = 1
	if(!client) return
	winset(client, "st_legname", "is-visible=false")
	client.MapFocus()  
	var/obj/Items/I = client.st_legend_item
	if(!I || I.CraftQuality != QUAL_LEGENDARY)
		client.st_legend_item = null
		return
	if(length(t) > 32) t = copytext(t, 1, 33)   // cut the raw text so an encoded entity can't be split
	t = html_encode(t)
	if(!length(t))
		client.ShowLegendNamePrompt(I)   // an empty enter doesn't forfeit the naming
		return
	client.st_legend_item = null
	I.name = t
	src << "<font color=#ffd86b>[t] will be remembered.</font>"
