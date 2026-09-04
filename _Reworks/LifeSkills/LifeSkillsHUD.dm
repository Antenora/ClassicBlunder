#define LS_W 624
#define LS_H 344
#define LS_LAYER (FLY_LAYER + 3.85)
#define LS_FONT      "font-family:'monogram'; font-size:12pt"
#define LS_FONT_BODY "font-family:'Pixel Operator 8'; font-size:6pt"
#define LS_BAR_W 158

#define LS_C_NAME   "#ffffff"
#define LS_C_COST   "#ffd86b"
#define LS_C_NOFUND "#ff6464"
#define LS_C_OK     "#78eb78"
#define LS_C_LOCKED "#6b7a8d"
#define LS_C_HINT   "#7a9bb5"

/atom/movable/shud/lsbg
	layer = LS_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.LSPanelStart(params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.LSPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.LSPanelEnd()

/atom/movable/shud/lspic
	layer = LS_LAYER + 0.3
	mouse_opacity = 0

/atom/movable/shud/lstext
	layer = LS_LAYER + 0.6
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/lsbtn
	layer = LS_LAYER + 0.6
	mouse_opacity = 2
	var/action
	var/arg
	var/atom/movable/shud/lstext/lbl
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr) usr.client.LifeSkillsButton(action, arg)

/atom/movable/shud/lswidget
	parent_type = /atom/movable/shud/pressbtn
	layer = LS_LAYER + 0.65
	mouse_opacity = 2
	DoAction()
		if(usr && usr.client) usr.client.LifeSkillsButton(action, null)

/atom/movable/shud/lsconfirmbg            // rank-up prompt; right-click dismisses
	layer = LS_LAYER + 1.0
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr && usr.client) usr.client.LsPromptAction("no")

/atom/movable/shud/lsconfirmbtn
	layer = LS_LAYER + 1.15
	mouse_opacity = 2
	var/action
	MouseEntered(location, control, params)
		filters = filter(type="drop_shadow", x=0, y=0, size=2, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr && usr.client) usr.client.LsPromptAction(action)

client
	var/tmp
		lsmenu_open = 0
		ls_tab = 1
		ls_atx = 1
		ls_aty = 1
		ls_pan_x = 0
		ls_pan_y = 0
		ls_pan_mx = 0
		ls_pan_my = 0
		ls_pan_ox = 0
		ls_pan_oy = 0
		ls_pan_dragged = FALSE
		list/ls_chrome
		list/ls_page
		list/ls_tabbtns
		list/ls_confirm_objs
		atom/movable/shud/menubtn/btn_lifeskills
		atom/movable/shud/menulabel/btn_lifeskills_label

client/proc/LSloc(dx, dyTop, h = 0)
	var/py = LS_H - dyTop - h
	var/ax = dx + ls_pan_x
	var/ay = py + ls_pan_y
	var/axp = ((ax % 32) + 32) % 32
	var/ayp = ((ay % 32) + 32) % 32
	return "[ls_atx + (ax - axp) / 32]:[axp],[ls_aty + (ay - ayp) / 32]:[ayp]"

client/proc/InitLifeSkillsButton()
	btn_lifeskills = new('HUD/ui_icon_lifeskills.png')
	btn_lifeskills.btn_id = "lifeskills"
	btn_lifeskills.screen_loc = "EAST:-4,NORTH:-320"
	shud_parts += btn_lifeskills
	btn_lifeskills_label = new
	btn_lifeskills_label.maptext_width = 80
	btn_lifeskills_label.SetText("Life Skills")
	btn_lifeskills_label.pixel_x = -86
	btn_lifeskills_label.pixel_y = 8
	btn_lifeskills.label = btn_lifeskills_label
	btn_lifeskills.vis_contents += btn_lifeskills_label

client/proc/ResetLifeSkillsHUD()
	CloseLifeSkillsMenu()
	btn_lifeskills = null
	btn_lifeskills_label = null

client/proc/ToggleLifeSkillsMenu()
	if(lsmenu_open) CloseLifeSkillsMenu()
	else OpenLifeSkillsMenu()

client/proc/OpenLifeSkillsMenu()
	if(lsmenu_open || !mob) return
	CloseMenu()
	CloseInventory()
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	CloseAcquireMenu()
	CloseStationMenu()
	CloseArcaneMenu()
	CloseArcaneAcquire(0)
	CloseOppMenu()
	lsmenu_open = 1

	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	if(isnull(vw)) vw = 20
	if(isnull(vh)) vh = 15
	var/mtw = round(LS_W / 32); if(mtw * 32 < LS_W) mtw++
	var/mth = round(LS_H / 32); if(mth * 32 < LS_H) mth++
	ls_atx = max(1, round((vw - mtw) / 2) + 1)
	ls_aty = max(1, round((vh - mth) / 2) + 1)
	ls_pan_x = getPref("lsPanX"); if(isnull(ls_pan_x)) ls_pan_x = 0
	ls_pan_y = getPref("lsPanY"); if(isnull(ls_pan_y)) ls_pan_y = 0
	var/list/b = LSPanBounds()
	ls_pan_x = clamp(ls_pan_x, b[1], b[2])
	ls_pan_y = clamp(ls_pan_y, b[3], b[4])

	if(btn_lifeskills)
		btn_lifeskills.icon = 'HUD/ui_slot_unavailable.png'
		btn_lifeskills.SetGlyphDimmed(TRUE)
	if(btn_lifeskills_label) btn_lifeskills_label.alpha = 0

	BuildLifeSkillsChrome()
	RefreshLifeSkillsPage()
	RefreshLsTabLook()
	var/list/all = ls_chrome.Copy()
	if(ls_page) all += ls_page
	KineticEntrance(all)

client/proc/CloseLifeSkillsMenu()
	if(!lsmenu_open && !ls_chrome) return
	lsmenu_open = 0
	HideLsConfirm()
	ClearList(ls_page); ls_page = null
	ClearList(ls_chrome); ls_chrome = null
	ls_tabbtns = null
	if(btn_lifeskills)
		btn_lifeskills.icon = 'HUD/ui_slot_available.png'
		btn_lifeskills.SetGlyphDimmed(FALSE)

client/proc/LsMakeTab(i, tabname)
	var/atom/movable/shud/lsbtn/b = new
	b.icon = 'HUD/ui_tab_idle.png'
	b.action = "tab"
	b.arg = i
	b.screen_loc = LSloc(10, 44 + (i - 1) * 32, 32)
	ls_chrome += b
	var/atom/movable/shud/lstext/L = new
	L.layer = LS_LAYER + 0.62
	L.maptext_width = 84
	L.maptext_height = 16
	L.screen_loc = LSloc(10, 44 + (i - 1) * 32 + 6, 16)
	ls_chrome += L
	b.lbl = L
	ls_tabbtns["[i]"] = b
	return b

client/proc/BuildLifeSkillsChrome()
	ls_chrome = list()
	ls_tabbtns = list()

	var/atom/movable/shud/lsbg/P = new
	P.icon = 'HUD/tech_panel.png'
	P.screen_loc = LSloc(0, 0, LS_H)
	ls_chrome += P

	var/atom/movable/shud/lspic/tp = new
	tp.icon = 'HUD/tech_titleplate.png'
	tp.screen_loc = LSloc(212, 6, 32)
	ls_chrome += tp
	var/atom/movable/shud/lstext/title = new
	title.maptext_width = 200
	title.maptext_height = 16
	title.screen_loc = LSloc(212, 12, 16)
	title.maptext = "<center><span style=\"[LS_FONT]; color:#ffffff\">LIFE SKILLS</span></center>"
	ls_chrome += title

	var/atom/movable/shud/lswidget/X = new
	X.widget_kind = "cross"
	X.icon = 'HUD/ui_cross_1.png'
	X.action = "close"
	X.screen_loc = LSloc(590, 12, 24)
	ls_chrome += X

	var/atom/movable/shud/lsbtn/logb = new
	logb.icon = 'HUD/log_entry_btn.png'
	logb.action = "collog"
	logb.screen_loc = LSloc(462, 10, 24)
	ls_chrome += logb
	var/atom/movable/shud/lstext/logl = new
	logl.layer = LS_LAYER + 0.62
	logl.maptext_width = 120
	logl.maptext_height = 16
	logl.screen_loc = LSloc(462, 13, 16)
	logl.maptext = "<center><span style=\"[LS_FONT]; color:#8be9ff\">COLLECTION LOG</span></center>"
	ls_chrome += logl

	var/atom/movable/shud/lsbtn/oppb = new
	oppb.icon = 'HUD/log_entry_btn.png'
	oppb.action = "oppboard"
	oppb.screen_loc = LSloc(18, 10, 24)
	ls_chrome += oppb
	var/atom/movable/shud/lstext/oppl = new
	oppl.layer = LS_LAYER + 0.62
	oppl.maptext_width = 120
	oppl.maptext_height = 16
	oppl.screen_loc = LSloc(18, 13, 16)
	oppl.maptext = "<center><span style=\"[LS_FONT]; color:#8be9ff\">OPPORTUNITIES</span></center>"
	ls_chrome += oppl

	for(var/i = 1 to LIFE_SKILL_IDS.len)
		LsMakeTab(i, LIFE_SKILL_IDS[i])

	for(var/atom/movable/o in ls_chrome)
		screen += o

client/proc/RefreshLsTabLook()
	if(!ls_tabbtns) return
	for(var/k in ls_tabbtns)
		var/atom/movable/shud/lsbtn/b = ls_tabbtns[k]
		if(!b) continue
		var/i = text2num(k)
		b.icon = (ls_tab == i) ? 'HUD/ui_tab_active.png' : 'HUD/ui_tab_idle.png'
		if(b.lbl)
			var/nm = LIFE_SKILL_IDS[i]
			if(length(nm) > 10) nm = copytext(nm, 1, 7)
			b.lbl.maptext = "<center><span style=\"[LS_FONT]; color:[ls_tab == i ? "#06283b" : "#cfe3f5"]\">[uppertext(nm)]</span></center>"

client/proc/LsAddText(dx, dyTop, w, h, txt)
	var/atom/movable/shud/lstext/T = new
	T.maptext_width = w
	T.maptext_height = h
	T.screen_loc = LSloc(dx, dyTop, h)
	T.maptext = txt
	ls_page += T
	screen += T
	return T

// tbar art: track 160x11, fill/mask 158x9 - fill sits 1px inside the track frame
client/proc/LsAddBar(dx, dyTop, fillicon, frac)
	var/atom/movable/shud/lspic/tr = new
	tr.icon = 'HUD/tbar_track.png'
	tr.layer = LS_LAYER + 0.35
	tr.screen_loc = LSloc(dx, dyTop, 11)
	ls_page += tr
	screen += tr
	var/atom/movable/shud/lspic/f = new
	f.icon = fillicon
	f.layer = LS_LAYER + 0.36
	f.screen_loc = LSloc(dx + 1, dyTop + 1, 9)
	f.filters = filter(type="alpha", icon='HUD/tbar_mask.png', x = round(LS_BAR_W * clamp(frac, 0, 1)) - LS_BAR_W)
	ls_page += f
	screen += f

// per-skill page: rank line, xp bar, shared stamina, rank-up button, skill blurb
client/proc/RefreshLifeSkillsPage()
	if(!lsmenu_open || !mob) return
	ClearList(ls_page)
	ls_page = list()
	var/id = LIFE_SKILL_IDS[ls_tab]
	var/datum/lifeskill/S = mob.GetLifeSkill(id)
	mob.CheckLifeStaminaRefill()

	LsAddText(130, 48, 340, 18, "<span style=\"[LS_FONT]; color:#8be9ff\">[uppertext(id)]</span>")
	LsAddText(130, 66, 340, 18, "<span style=\"[LS_FONT]; color:[LS_C_NAME]\">Rank [S.rank] - [S.Title()]</span>")

	var/nxt = S.NextXP()
	var/frac = 1
	if(S.rank < LIFE_MAX_RANK)
		var/prev = LIFE_RANK_XP[max(S.rank, 1)]
		if(S.rank < 1) prev = 0
		frac = (nxt > prev) ? (S.xp - prev) / (nxt - prev) : 0
	LsAddBar(130, 96, 'HUD/tbar_fill_en.png', frac)
	LsAddText(300, 94, 200, 16, "<span style=\"[LS_FONT_BODY]; color:[LS_C_NAME]\">XP [Commas(S.xp)] / [S.rank < LIFE_MAX_RANK ? Commas(nxt) : "MAX"]</span>")

	LsAddBar(130, 126, 'HUD/tbar_fill_hp.png', mob.LifeStamina / LIFE_STAMINA_MAX)
	LsAddText(300, 124, 260, 16, "<span style=\"[LS_FONT_BODY]; color:[LS_C_NAME]\">Life Stamina [mob.LifeStamina] / [LIFE_STAMINA_MAX] (shared by all life skills)</span>")

	if(S.rank < LIFE_MAX_RANK)
		var/can = S.CanRankUp(mob)
		var/atom/movable/shud/lsbtn/rb = new
		rb.icon = 'HUD/ui_tab_idle.png'
		rb.action = "rankup"
		rb.screen_loc = LSloc(470, 60, 32)
		ls_page += rb
		screen += rb
		var/atom/movable/shud/lstext/rl = new
		rl.layer = LS_LAYER + 0.62
		rl.maptext_width = 84
		rl.maptext_height = 16
		rl.screen_loc = LSloc(470, 66, 16)
		rl.maptext = "<center><span style=\"[LS_FONT]; color:[can ? LS_C_OK : (S.xp >= nxt ? LS_C_NOFUND : LS_C_LOCKED)]\">RANK UP</span></center>"
		ls_page += rl
		screen += rl
	else
		LsAddText(452, 66, 130, 18, "<span style=\"[LS_FONT]; color:[LS_C_COST]\">MASTER</span>")

	// mining capstone toggle
	if(id == "Mining" && S.rank >= LIFE_MAX_RANK)
		var/used = (mob.LifeCapstoneGemDay == DaysOfWipe())
		var/atom/movable/shud/lsbtn/cb = new
		cb.icon = 'HUD/ui_tab_idle.png'
		cb.action = "gemcapstone"
		cb.screen_loc = LSloc(470, 100, 32)
		ls_page += cb
		screen += cb
		var/atom/movable/shud/lstext/cl = new
		cl.layer = LS_LAYER + 0.62
		cl.maptext_width = 96
		cl.maptext_height = 32
		cl.screen_loc = LSloc(464, 100, 32)
		cl.maptext = "<center><span style=\"[LS_FONT_BODY]; color:[used ? LS_C_LOCKED : (mob.LifeGemArmed ? LS_C_COST : LS_C_OK)]\">[used ? "GEM USED" : (mob.LifeGemArmed ? "GEM ARMED" : "ARM GEM")]</span></center>"
		ls_page += cl
		screen += cl

	LsAddText(130, 160, 460, 170, LifeSkillPageBody(mob, id))

client/proc/LifeSkillsButton(action, arg)
	if(!lsmenu_open || !mob) return
	switch(action)
		if("close")
			CloseLifeSkillsMenu()
		if("collog")
			CloseLifeSkillsMenu()
			OpenLogMenu()
		if("oppboard")
			OpenOppMenu()
		if("tab")
			if(isnum(arg) && arg >= 1 && arg <= LIFE_SKILL_IDS.len)
				HideLsConfirm()
				ls_tab = arg
				RefreshLifeSkillsPage()
				RefreshLsTabLook()
		if("rankup")
			ShowLsConfirm()
		if("gemcapstone")
			if(mob.LifeCapstoneGemDay == DaysOfWipe())
				mob << "You've already cracked a gem loose today."
			else
				mob.LifeGemArmed = !mob.LifeGemArmed
				mob << (mob.LifeGemArmed ? "Prospector's Instinct armed. Your next mining strike will shake a gem loose." : "Prospector's Instinct disarmed.")
			RefreshLifeSkillsPage()

// per-skill blurb + collection/recipe readout. phase 1 fills mining/smithing; the rest tease :3
proc/LifeSkillPageBody(mob/M, id)
	var/body = ""
	switch(id)
		if("Mining")
			var/datum/lifeskill/S = M.GetLifeSkill(id)
			body = "Crack ore veins in the wild. Face a vein and press [M.InteractKeyName()], or click it.<br>Harder veins swing faster bars - rank up to slow them down.<br><br>"
			var/found = S.collection_log ? S.collection_log.len : 0
			body += "Collection log: [found] material[found == 1 ? "" : "s"] discovered."
			if(S.rank >= LIFE_MAX_RANK)
				body += "<br>Capstone: one guaranteed gem per day (arm it above)."
		if("Smithing")
			body = "Smelt ore into ingots at a forge, hammer gear out at an anvil.<br><br>[LifeSmithingRecipeLines(M)]"
		if("Hunting")
			var/datum/lifeskill/S = M.GetLifeSkill(id)
			body = "Slain monsters leave carveable remains. Face them and press [M.InteractKeyName()], or click them, then saw up and down to work the carcass.<br>Tougher monsters (higher Potential) yield higher-tier parts - rank up to carve them cleanly.<br><br>"
			var/found = S.collection_log ? S.collection_log.len : 0
			body += "Collection log: [found] monster part[found == 1 ? "" : "s"] discovered."
			if(S.rank >= LIFE_MAX_RANK)
				body += "<br>Capstone: Trophy Extraction - one bonus pristine trophy per day."
		if("Foraging")
			var/datum/lifeskill/S = M.GetLifeSkill(id)
			body = "Gather herbs, flowers and mushrooms from wild patches, and chop trees for wood and fruit. Face a patch or tree and press [M.InteractKeyName()], or click it.<br>Patches want a steady hand; trees want an axe-swing rhythm. Richer growth (higher tier) needs more rank.<br><br>"
			var/found = S.collection_log ? S.collection_log.len : 0
			body += "Collection log: [found] plant[found == 1 ? "" : "s"] discovered."
			if(S.rank >= LIFE_MAX_RANK)
				body += "<br>Capstone: Botanist's Eye - one bonus rare specimen per day."
		if("Fishing")
			var/datum/lifeskill/S = M.GetLifeSkill(id)
			body = "Cast at fishing spots on the water. Face the spot and press [M.InteractKeyName()], or click it, then wait for a bite.<br>Reel it in: hold [M.InteractKeyName()] to raise the marker and keep it over the fish. Different fish fight differently - deeper waters hold tougher, rarer fish.<br><br>"
			var/found = S.collection_log ? S.collection_log.len : 0
			body += "Collection log: [found] fish discovered."
			if(S.rank >= LIFE_MAX_RANK)
				body += "<br>Capstone: Legend of the Deep - one legendary catch per day."
		if("Farming")
			var/datum/lifeskill/S = M.GetLifeSkill(id)
			body = "Forge a Hoe and Watering Can, click the hoe to till soil plots on grass or dirt, then plant seeds from a seed stall.<br>Hold [M.InteractKeyName()] at your plot to water it - crops grow one stage per watered day. Miss [FARM_WILT_DAYS] days straight and the crop wilts.<br><br>"
			var/found = S.collection_log ? S.collection_log.len : 0
			body += "Collection log: [found] crop[found == 1 ? "" : "s"] harvested."
			if(S.rank >= LIFE_MAX_RANK)
				body += "<br>Capstone: Green Colossus - your first planting each day is guaranteed giant (when the crop has a giant form)."
		if("Cooking", "Thaumaturgy", "Technology")
			body = "Coming soon."
	return "<span style=\"[LS_FONT_BODY]; color:[LS_C_HINT]\">[body]</span>"

client/proc/LsMkPromptBtn(action, label, color, dx, dyTop)
	var/atom/movable/shud/lsconfirmbtn/b = new
	b.icon = 'HUD/pbtn.png'
	b.action = action
	b.screen_loc = LSloc(dx, dyTop, 24)
	ls_confirm_objs += b
	screen += b
	var/atom/movable/shud/lstext/L = new
	L.layer = LS_LAYER + 1.2
	L.maptext_width = 80
	L.maptext_height = 24
	L.maptext_y = 6
	L.screen_loc = LSloc(dx, dyTop, 24)
	L.maptext = "<center><span style=\"[LS_FONT]; color:[color]\">[label]</span></center>"
	ls_confirm_objs += L
	screen += L

client/proc/ShowLsConfirm()
	HideLsConfirm()
	if(!mob) return
	var/datum/lifeskill/S = mob.GetLifeSkill(LIFE_SKILL_IDS[ls_tab])
	if(S.rank >= LIFE_MAX_RANK) return
	ls_confirm_objs = list()

	var/atom/movable/shud/lsconfirmbg/bg = new
	bg.icon = 'HUD/party_prompt.png'
	bg.screen_loc = LSloc(200, 102, 140)
	ls_confirm_objs += bg
	screen += bg

	var/atom/movable/shud/lstext/nm = new
	nm.layer = LS_LAYER + 1.2
	nm.maptext_width = 208
	nm.maptext_height = 16
	nm.screen_loc = LSloc(208, 132, 16)
	nm.maptext = "<center><span style=\"[LS_FONT]; color:[LS_C_COST]\">[uppertext(S.id)] RANK [S.rank + 1]</span></center>"
	ls_confirm_objs += nm
	screen += nm

	var/atom/movable/shud/lstext/q = new
	q.layer = LS_LAYER + 1.2
	q.maptext_width = 208
	q.maptext_height = 16
	q.screen_loc = LSloc(208, 176, 16)
	var/rcost = S.RankUpRPP(mob)
	var/rnote = (rcost < S.NextRPP()) ? " <font color=[LS_C_OK]>(aptitude discount)</font>" : ""
	q.maptext = "<center><span style=\"[LS_FONT]; color:#bfefff\">Advance for [rcost] RPP?[rnote]</span></center>"
	ls_confirm_objs += q
	screen += q

	LsMkPromptBtn("yes", "Yes", LS_C_OK, 220, 205)
	LsMkPromptBtn("no", "No", LS_C_NOFUND, 324, 205)

	KineticEntrance(ls_confirm_objs)

client/proc/HideLsConfirm()
	ClearList(ls_confirm_objs)
	ls_confirm_objs = null

client/proc/LsPromptAction(action)
	HideLsConfirm()
	if(action != "yes" || !lsmenu_open || !mob) return
	var/datum/lifeskill/S = mob.GetLifeSkill(LIFE_SKILL_IDS[ls_tab])
	S.TryRankUp(mob)
	RefreshLifeSkillsPage()

client/proc/LSPanBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/bx = (ls_atx - 1) * 32
	var/by = (ls_aty - 1) * 32
	var/minx = -bx
	if(minx > 0) minx = 0
	var/maxx = vw * 32 - LS_W - bx
	if(maxx < 0) maxx = 0
	var/miny = -by
	if(miny > 0) miny = 0
	var/maxy = vh * 32 - LS_H - by
	if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/LSShiftLive(dpx, dpy)
	if(!dpx && !dpy) return
	for(var/atom/movable/o in ls_chrome)
		if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(ls_page)
		for(var/atom/movable/o in ls_page)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)
	if(ls_confirm_objs)
		for(var/atom/movable/o in ls_confirm_objs)
			if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/LSPanelStart(params)
	ls_pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	ls_pan_mx = m[1]; ls_pan_my = m[2]
	ls_pan_ox = ls_pan_x; ls_pan_oy = ls_pan_y

client/proc/LSPanelMove(params)
	if(!lsmenu_open) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = LSPanBounds()
	var/wantx = clamp(ls_pan_ox + (m[1] - ls_pan_mx), b[1], b[2])
	var/wanty = clamp(ls_pan_oy + (m[2] - ls_pan_my), b[3], b[4])
	var/dx = wantx - ls_pan_x
	var/dy = wanty - ls_pan_y
	if(!dx && !dy) return
	ls_pan_x = wantx; ls_pan_y = wanty
	ls_pan_dragged = TRUE
	LSShiftLive(dx, dy)

client/proc/LSPanelEnd()
	if(!ls_pan_dragged) return
	ls_pan_dragged = FALSE
	setPref("lsPanX", ls_pan_x)
	setPref("lsPanY", ls_pan_y)
