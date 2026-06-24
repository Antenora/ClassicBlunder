#define CMENU_W 624
#define CMENU_H 344
#define CMENU_FONT "font-family:'monogram'; font-size:12pt"
#define CMENU_LAYER (FLY_LAYER + 3.6)
#define CMENU_VY 10
#define PASS_VISIBLE 11
#define PASS_ROWS 12       // one extra buffer row for smooth scrolling
#define PASS_Y0 122
#define PASS_RH 18
#define PASS_BAND_H 198    // PASS_VISIBLE * PASS_RH
#define PASS_TRACK_Y 120
#define PASS_TRACK_H 206
#define PASS_THUMB_H 36
#define GEAR_COLS 6
#define GEAR_ROWS 5
#define GEAR_CW 44
#define GEAR_RH 40
#define GEAR_X0 316
#define GEAR_Y0 120
#define GEAR_TRACK_Y 120
#define GEAR_TRACK_H 200
#define GEAR_THUMB_H 36
#define CUST_VISROWS 11
#define CUST_ROWS 12        // one extra buffer row for smooth scrolling
#define CUST_RH 18
#define CUST_Y0 122
#define CUST_BAND_H 198     // CUST_VISROWS * CUST_RH
#define CUST_TRACK_Y 120
#define CUST_TRACK_H 206   // scroll_track.png height. 200 left the thumb 6px short
#define CUST_THUMB_H 36

/var/CMENU_BARFILL_RESOURCE = 'HUD/bar_fill74.png'
/var/CMENU_R0 = 'HUD/charmenu_stats.png'
/var/CMENU_R1 = 'HUD/charmenu_passives.png'
/var/CMENU_R2 = 'HUD/scroll_thumb.png'
/var/CMENU_R3 = 'HUD/desc_panel.png'
/var/CMENU_RG = 'HUD/charmenu_gear.png'
/var/CMENU_RC = 'HUD/charmenu_custom.png'
/var/CMENU_RPE = 'HUD/charmenu_personal.png'
/var/list/CUSTOM_DESC = list(
	"Hair" = "Choose a built-in hairstyle",
	"Clothes" = "Choose built-in clothing",
	"Customize" = "Blasts, auras & charge effects",
	"Customize: Hair" = "Upload a custom hair sprite",
	"Customize: Hair Details" = "Hair underlay & overlay offset",
	"Customize: Icon" = "Replace your body sprite",
	"Customize: Forms" = "Per-transformation looks",
	"Customize: Ki Charge" = "Charge-up effect",
	"Customize: Skills" = "Skill icons, messages & looks",
	"Customize: PU Charging" = "Custom power-up line"
)
/var/list/CUST_SPRITE_CFG = list(
	"Customize: Hair" = list("spr" = "Hair_Base", "col" = "Hair_Color", "ox" = "HairX", "oy" = "HairY", "apply" = "hair"),
	"Customize: Hair Details" = list("spr" = "Hair_Base", "ox" = "HairX", "oy" = "HairY", "apply" = "hair"),
	"Customize: Icon" = list("spr" = "icon", "ox" = "pixel_x", "oy" = "pixel_y", "apply" = "icon", "posoffset" = 1)
)
/var/list/CUST_ITEM_CFG = list("spr" = "EquipIcon", "ox" = "pixel_x", "oy" = "pixel_y", "col" = "color", "apply" = "item")

/proc/IsCustomizableItem(obj/Items/it)
	return istype(it, /obj/Items/Sword) || istype(it, /obj/Items/Armor) || istype(it, /obj/Items/Enchantment/Staff) || istype(it, /obj/Items/Wearables)

/proc/CanBeHat(obj/Items/it)
	return istype(it, /obj/Items/Sword) || istype(it, /obj/Items/Enchantment/Staff) || istype(it, /obj/Items/Wearables) || istype(it, /obj/Items/Armor)

/proc/StripBalanceNote(d)
	if(!d) return d
	var/cut = findtext(d, "<hr>")
	if(cut) return copytext(d, 1, cut)
	return d
/var/list/CUST_SWATCHES = list("#e84a4a", "#f0c040", "#5fc05f", "#5b9be8", "#ffffff", "#202028")
/mob/var/list/cust_recent_colors

/var/list/HAT_TGL_OFF = list('HUD/toggle_off_1.png', 'HUD/toggle_off_2.png', 'HUD/toggle_off_3.png', 'HUD/toggle_off_4.png', 'HUD/toggle_off_5.png')
/var/list/HAT_TGL_ON  = list('HUD/toggle_on_1.png', 'HUD/toggle_on_2.png', 'HUD/toggle_on_3.png', 'HUD/toggle_on_4.png', 'HUD/toggle_on_5.png')

client/proc/CMloc(dx, dy)
	var/py = CMENU_H - dy
	return "[cm_atx + (dx - dx % 32) / 32]:[dx % 32],[cm_aty + (py - py % 32) / 32]:[py % 32]"

/atom/movable/shud/cmframe
	layer = CMENU_LAYER
	mouse_opacity = 2
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.HideDescPanel()
			return
		var/list/pl = params2list(params)
		var/ix = text2num(pl["icon-x"]); var/iy = text2num(pl["icon-y"])
		if(isnull(ix) || isnull(iy)) return
		var/dy = CMENU_H - iy
		if(dy >= 16 && dy <= 50)
			for(var/i = 0 to 4)
				var/tx = 300 + i * 34
				if(ix >= tx && ix <= tx + 30)
					usr.client.CharMenuTab(i)
					return

/atom/movable/shud/cmtext
	layer = CMENU_LAYER + 0.3
	mouse_opacity = 0
	maptext_height = 16
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/cmval
	layer = CMENU_LAYER + 0.3
	mouse_opacity = 0
	maptext_height = 16
	var/text_align = "right"
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/cmfill
	layer = CMENU_LAYER + 0.2
	mouse_opacity = 0

/atom/movable/shud/cmportrait
	layer = CMENU_LAYER + 0.3
	mouse_opacity = 1
	New()
		..()
		filters = filter(type="outline", size=1, color="#5bc0e8")
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=2, color="#bfefff")
	MouseExited(location, control, params)
		filters = filter(type="outline", size=1, color="#5bc0e8")
	Click(location, control, params)
		if(usr) spawn() usr.ChoosePortrait()

/atom/movable/shud/cmpron
	layer = CMENU_LAYER + 0.4
	mouse_opacity = 2
	maptext_height = 16
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	Click(location, control, params)
		if(usr) spawn() usr.ChooseMenuPronouns()

/atom/movable/shud/cmbuff
	layer = CMENU_LAYER + 0.35
	mouse_opacity = 1
	var/buff_name

/atom/movable/shud/cmpassrow
	layer = CMENU_LAYER + 0.3
	mouse_opacity = 2
	maptext_height = 16
	var/pass_name
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	Click(location, control, params)
		if(!usr || !pass_name) return
		if(params && findtext(params, "right=1"))
			usr.client.ShowPassDesc(pass_name)

/atom/movable/shud/cmtrack
	layer = CMENU_LAYER + 0.35
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.ScrollTrackDispatch(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr) usr.client.ScrollTrackDispatch(params)

/atom/movable/shud/cmscroll
	layer = CMENU_LAYER + 0.4
	mouse_opacity = 0

/atom/movable/shud/cmmask
	layer = CMENU_LAYER + 0.5
	mouse_opacity = 0

/atom/movable/shud/cmgearslot
	layer = CMENU_LAYER + 0.35
	mouse_opacity = 2
	var/slot_idx
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=1, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click(location, control, params)
		if(!usr) return
		if(params && findtext(params, "right=1"))
			usr.client.ShowGearDetail(usr.GetGearItem(slot_idx))
		else
			usr.client.SelectGearSlot(slot_idx)

/atom/movable/shud/cmcustrow
	layer = CMENU_LAYER + 0.3
	mouse_opacity = 2
	maptext_height = 16
	var/idx
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=1, color="#8be9ff")   // cyan glow on hover. filters affect maptext, color does not
	MouseExited(location, control, params)
		filters = filter(type="outline", size=1, color="#000000")
	Click(location, control, params)
		if(usr && idx) usr.client.SelectCustOption(idx)

/atom/movable/shud/cmcustbtn
	layer = CMENU_LAYER + 0.4
	mouse_opacity = 2
	maptext_height = 16
	var/action
	Click(location, control, params)
		if(usr) usr.client.CustButtonAction(action)

/atom/movable/shud/cmpersbtn
	layer = CMENU_LAYER + 0.4
	mouse_opacity = 2
	var/action
	Click(location, control, params)
		if(usr) usr.client.PersonalButtonAction(action)

/atom/movable/shud/hattoggle
	mouse_opacity = 2
	var/obj/Items/item
	var/ctx
	Click(location, control, params)
		if(usr && item) usr.client.ToggleHatClick(src)

/atom/movable/shud/cmgearclick
	parent_type = /atom/movable/shud/cmdtext
	layer = CMENU_LAYER + 0.72
	mouse_opacity = 2
	var/obj/Items/git
	var/gact   // "passive" or "layer"
	var/pname
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=1, color="#8be9ff")
	MouseExited(location, control, params)
		filters = filter(type="outline", size=1, color="#000000")
	Click(location, control, params)
		if(!usr) return
		var/rc = (params && findtext(params, "right=1"))
		if(gact == "passive")
			if(rc && pname) usr.client.ShowGearPassiveInfo(pname)
		else if(gact == "layer")
			if(rc) usr.client.HideDescPanel()
			else if(git) usr.client.GearLayerPrompt(git)
		else if(gact == "rename")
			if(rc) usr.client.HideDescPanel()
			else if(git) usr.client.RenameItem(git, "gear")

/atom/movable/shud/gearpasspanel
	layer = CMENU_LAYER + 0.8
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr) usr.client.HideGearPassiveInfo()
/atom/movable/shud/gearpasstext
	layer = CMENU_LAYER + 0.82
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/cmswatch
	layer = CMENU_LAYER + 0.4
	mouse_opacity = 2
	var/swcolor
	Click(location, control, params)
		if(usr) usr.client.SetCustColor(swcolor)

/atom/movable/shud/cmpreview
	layer = CMENU_LAYER + 0.45
	mouse_opacity = 2
	MouseDown(location, control, params)
		if(usr) usr.client.CustDragStart(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr) usr.client.CustDragMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.CustDragEnd()

/atom/movable/shud/cmgeargrid
	layer = CMENU_LAYER + 0.35
	mouse_opacity = 2
	var/obj/Items/gitem
	MouseEntered(location, control, params)
		if(gitem) filters = filter(type="outline", size=1, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click(location, control, params)
		if(!usr || !gitem) return
		if(params && findtext(params, "right=1"))
			usr.client.ShowGearDetail(gitem)
		else
			spawn() usr.client.EquipGearItem(gitem)

/atom/movable/shud/cmdesc
	layer = CMENU_LAYER + 0.6
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr) usr.client.HideDescPanel()

/atom/movable/shud/cmdtext
	layer = CMENU_LAYER + 0.7
	mouse_opacity = 0
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

//////////////////////////////////////////////////////////////////
// Client state + lifecycle
//////////////////////////////////////////////////////////////////

client
	var/tmp
		cmenu_open = FALSE
		cmenu_tab = 0
		cm_atx = 0
		cm_aty = 0
		list/cmenu_objs
		list/cmenu_vals
		list/cmenu_fills
		list/cmenu_buffs
		list/cmenu_desc_objs
		list/cmenu_gearpass_objs
		list/cmenu_pass_list
		list/cmenu_pass_rows
		cmenu_pass_px = 0
		cmenu_pass_target = 0
		cmenu_pass_anim = FALSE
		atom/movable/shud/cmscroll/cmenu_thumb
		atom/movable/shud/cmtrack/cmenu_track
		cmenu_gear_sel = 1
		gear_scroll_row = 0
		list/cmenu_gvals
		list/cmenu_gslots
		list/cmenu_gear_list
		list/cmenu_gear_grid
		list/cmenu_gear_badges
		atom/movable/shud/cmmask/cmenu_gsel_hl
		atom/movable/shud/cmtext/cmenu_gdmglbl
		atom/movable/shud/cmtext/cmenu_gacclbl
		atom/movable/shud/cmtext/cmenu_gspdlbl
		atom/movable/shud/cmtrack/cmenu_geartrack
		atom/movable/shud/cmscroll/cmenu_gearthumb
		list/cmenu_cust_list
		list/cmenu_cust_rows
		cust_px = 0
		cust_scroll_target = 0
		cust_anim = 0
		cust_sel = 1
		atom/movable/shud/cmtrack/cmenu_custtrack
		atom/movable/shud/cmscroll/cmenu_custthumb
		atom/movable/shud/cmmask/cmenu_custmask_t
		atom/movable/shud/cmmask/cmenu_custmask_b
		list/cmenu_cust_panel
		cust_panel_opt
		atom/movable/shud/cmpreview/cmenu_cust_preview
		atom/movable/shud/cmmask/cmenu_cust_sprite
		atom/movable/shud/cmmask/cmenu_cust_elem
		atom/movable/shud/cmmask/cmenu_cust_hair
		cust_base_cox = 0
		cust_base_coy = 0
		cust_crop_x = 0
		cust_crop_y = 0
		atom/movable/shud/cmcustbtn/cmenu_cust_offset
		atom/cust_target
		cust_drag_ox = 0
		cust_drag_oy = 0
		cust_drag_mx = 0
		cust_drag_my = 0
		atom/movable/shud/menubtn/btn_character
		atom/movable/shud/menulabel/btn_character_label
		atom/movable/shud/cmtext/cm_name
		atom/movable/shud/cmtext/cm_ident
		atom/movable/shud/cmtext/cm_pot
		atom/movable/shud/cmtext/cm_focus
		atom/movable/shud/cmpron/cm_pron
		atom/movable/shud/cmtext/cm_rp
		atom/movable/shud/cmtext/cm_rpused
		atom/movable/shud/cmportrait/cm_portrait

client/proc/InitCharacterMenuButton()
	btn_character = new('HUD/ui_icon_profile.png')
	btn_character.btn_id = "character"
	btn_character.screen_loc = "EAST:-4,NORTH:-176"   // pushed down, target card sits top-right
	shud_parts += btn_character
	btn_character_label = new
	btn_character_label.maptext_width = 72
	btn_character_label.SetText("Character")
	btn_character_label.pixel_x = -78
	btn_character_label.pixel_y = 8
	btn_character.label = btn_character_label
	btn_character.vis_contents += btn_character_label

client/proc/ToggleCharacterMenu()
	if(cmenu_open) CloseCharacterMenu()
	else OpenCharacterMenu()

client/proc/ClearCMenuObjs()
	HideDescPanel()
	ClearCustPanel()
	if(cmenu_objs)
		while(cmenu_objs.len)
			var/atom/movable/o = cmenu_objs[cmenu_objs.len]
			cmenu_objs.len--
			screen -= o
			del o
	cmenu_objs = list()
	cmenu_vals = list()
	cmenu_fills = list()
	cmenu_buffs = list()
	cmenu_pass_list = null
	cmenu_pass_rows = null
	cmenu_thumb = null
	cm_name = null; cm_ident = null; cm_pot = null; cm_focus = null; cm_pron = null
	cm_rp = null; cm_rpused = null; cm_portrait = null

client/proc/CloseCharacterMenu()
	cmenu_open = FALSE
	ClearCMenuObjs()
	cmenu_objs = null
	if(btn_character)
		btn_character.icon = 'HUD/ui_slot_available.png'
		btn_character.SetGlyphDimmed(FALSE)

client/proc/OpenCharacterMenu()
	if(cmenu_open || !mob) return
	CloseInventory()
	CloseMenu()
	CloseSkillMenu()
	cmenu_open = TRUE
	cmenu_tab = 0
	// tile-anchor the frame so it stays inside the view
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/mtw = round(CMENU_W / 32); if(mtw * 32 < CMENU_W) mtw++
	var/mth = round(CMENU_H / 32); if(mth * 32 < CMENU_H) mth++
	cm_atx = max(1, round((vw - mtw) / 2) + 1)
	cm_aty = max(1, round((vh - mth) / 2) + 1)
	if(btn_character)
		btn_character.icon = 'HUD/ui_slot_unavailable.png'
		btn_character.SetGlyphDimmed(TRUE)
		if(btn_character_label) btn_character_label.alpha = 0
	ClearCMenuObjs()
	BuildCharacterMenu(TRUE)

client/proc/CharMenuTab(idx)
	if(idx == cmenu_tab) return
	cmenu_tab = idx
	ClearCMenuObjs()
	BuildCharacterMenu()

client/proc/CMTabBg()
	switch(cmenu_tab)
		if(1) return CMENU_R1
		if(2) return CMENU_RC
		if(3) return CMENU_RG
		if(4) return CMENU_RPE
	return CMENU_R0

client/proc/MkVal(key, dx, dy, w, align = "right")
	var/atom/movable/shud/cmval/v = new
	v.maptext_width = w
	v.text_align = align
	v.screen_loc = CMloc(dx, dy + CMENU_VY)
	cmenu_vals[key] = v
	cmenu_objs += v

client/proc/MkRow(lbl, key, dx, dy, w)
	var/atom/movable/shud/cmtext/L = new
	L.maptext_width = w
	L.screen_loc = CMloc(dx, dy + CMENU_VY)
	L.maptext = "<span style=\"[CMENU_FONT]; color:#8be9ff\">[lbl]</span>"
	cmenu_objs += L
	MkVal(key, dx, dy, w, "right")

client/proc/MkAttr(lbl, key, cx)
	var/atom/movable/shud/cmtext/L = new
	L.maptext_width = 94
	L.screen_loc = CMloc(cx - 47, 116 + CMENU_VY)
	L.maptext = "<span style=\"[CMENU_FONT]; color:#8be9ff; text-align:center\">[lbl]</span>"
	cmenu_objs += L
	MkVal(key, cx - 47, 132, 94, "center")
	var/atom/movable/shud/cmfill/Fl = new
	Fl.screen_loc = CMloc(cx - 37, 146 + 2)
	cmenu_fills += Fl
	cmenu_objs += Fl

client/proc/BuildCharacterMenu(fade = FALSE)
	if(!mob) return
	var/atom/movable/shud/cmframe/F = new
	F.icon = CMTabBg()
	F.screen_loc = CMloc(0, CMENU_H)
	cmenu_objs += F
	BuildHeaderOverlays()
	switch(cmenu_tab)
		if(0) BuildStatsContent()
		if(1) BuildPassivesContent()
		if(2) BuildCustomContent()
		if(3) BuildGearContent()
		if(4) BuildPersonalContent()
	for(var/atom/movable/o in cmenu_objs)
		screen += o
	UpdateCharacterMenu()
	if(fade)
		KineticEntrance(cmenu_objs)   // first open only, no fade on tab switch

client/proc/BuildHeaderOverlays()
	cm_portrait = new
	cm_portrait.icon = mob.GetPortrait()
	cm_portrait.screen_loc = CMloc(560, 24 + 36)
	cmenu_objs += cm_portrait
	cm_name = new;  cm_name.maptext_width = 320;  cm_name.screen_loc = CMloc(26, 60 + CMENU_VY); cmenu_objs += cm_name
	cm_ident = new; cm_ident.maptext_width = 320; cm_ident.screen_loc = CMloc(26, 74 + CMENU_VY); cmenu_objs += cm_ident
	var/atom/movable/shud/cmtext/pl = new; pl.maptext_width = 80; pl.screen_loc = CMloc(360, 60 + CMENU_VY)
	pl.maptext = "<span style=\"[CMENU_FONT]; color:#96c3e1\">POTENTIAL</span>"; cmenu_objs += pl
	cm_pot = new;   cm_pot.maptext_width = 60;   cm_pot.screen_loc = CMloc(440, 60 + CMENU_VY); cmenu_objs += cm_pot
	cm_focus = new; cm_focus.maptext_width = 90; cm_focus.screen_loc = CMloc(500, 60 + CMENU_VY); cmenu_objs += cm_focus
	var/atom/movable/shud/cmtext/prl = new; prl.maptext_width = 80; prl.screen_loc = CMloc(360, 74 + CMENU_VY)
	prl.maptext = "<span style=\"[CMENU_FONT]; color:#96c3e1\">PRONOUNS</span>"; cmenu_objs += prl
	cm_pron = new;  cm_pron.maptext_width = 120; cm_pron.screen_loc = CMloc(440, 74 + CMENU_VY); cmenu_objs += cm_pron
	cm_rp = new;     cm_rp.maptext_width = 200;     cm_rp.screen_loc = CMloc(136, 60 + CMENU_VY); cmenu_objs += cm_rp
	cm_rpused = new; cm_rpused.maptext_width = 200; cm_rpused.screen_loc = CMloc(136, 75 + CMENU_VY); cmenu_objs += cm_rpused

client/proc/BuildStatsContent()
	MkAttr("STR", "str", 68);  MkAttr("END", "end", 164); MkAttr("SPD", "spd", 260)
	MkAttr("FOR", "for", 356); MkAttr("OFF", "off", 452); MkAttr("DEF", "def", 548)
	var/list/prows = list("Current Power"="power","From Potential"="frompot","From Buffs"="frombuffs","Base"="base","Power Mult"="powermult","Anger (Max)"="angermax","Current Anger"="curanger","Current BP"="bp")
	var/i = 0
	for(var/lbl in prows)
		MkRow(lbl, prows[lbl], 28, 182 + i * 18, 170); i++
	var/list/crows = list("Damage Boost"="dboost","Damage Reduction"="dred","Energy"="energy","Recovery"="recov")
	i = 0
	for(var/lbl in crows)
		MkRow(lbl, crows[lbl], 224, 182 + i * 18, 182); i++
	MkRow("God Ki", "godki", 224, 290, 182)
	MkRow("Maou Ki", "maouki", 224, 308, 182)
	var/list/grows = list("Avg Stats"="avg","Magic Lv"="magic","Trans Pot"="transpot","Chips"="chips")
	i = 0
	for(var/lbl in grows)
		MkRow(lbl, grows[lbl], 428, 182 + i * 18, 170); i++
	for(var/j = 1 to 5)
		var/atom/movable/shud/cmbuff/b = new
		b.screen_loc = CMloc(428 + (j - 1) * 32, 286 + 28)
		b.alpha = 0
		cmenu_buffs += b
		cmenu_objs += b

client/proc/BuildPersonalContent()
	var/list/btns = list(
		list("Check AI Kills", "ailogs"),
		list("View Self Logs", "selflogs"),
		list("Maim History", "maimhist"),
		list("Annotate Maim", "annotate")
	)
	var/bx = 237
	var/i = 0
	for(var/list/b in btns)
		var/topy = 138 + i * 40
		var/atom/movable/shud/cmpersbtn/btn = new
		btn.icon = 'HUD/cust_button.png'
		btn.action = b[2]
		btn.screen_loc = CMloc(bx, topy + 26)
		cmenu_objs += btn
		var/atom/movable/shud/cmtext/L = new
		L.maptext_width = 150
		L.layer = CMENU_LAYER + 0.5
		L.screen_loc = CMloc(bx, (topy + 8) + CMENU_VY)
		L.maptext = gspan(b[1], "#ffffff", "center")
		cmenu_objs += L
		i++

// spawn + output to mob, a direct usr<<browse from the Click silently did not show
client/proc/PersonalButtonAction(action)
	if(!mob) return
	var/mob/Players/p = mob   // these verbs live on /mob/Players
	switch(action)
		if("ailogs")  spawn() ShowAIKills()
		if("selflogs") spawn() ShowSelfLogs()
		if("maimhist")
			if(istype(p)) spawn() p.View_Maim_History()
		if("annotate")
			if(istype(p)) spawn() p.Annotate_Maim()

client/proc/ShowAIKills()
	if(!mob) return
	var/html = "<html><head><title>AI Kills</title></head><body bgcolor=#0a0f1a text=#cfe7ff style='font-family:sans-serif;padding:8px'>"
	html += "<h3 style='color:#8be9ff;margin:2px 0 8px 0'>AI Kills</h3>"
	if(mob.killed_AI && mob.killed_AI.len)
		html += "<table cellspacing=0 cellpadding=2>"
		for(var/k in mob.killed_AI)
			html += "<tr><td>[k]</td><td style='color:#ffd278'>&nbsp;&nbsp;[mob.killed_AI[k]]</td></tr>"
		html += "</table>"
	else
		html += "<p style='color:#9bb3c2'>You have no AI kills on record.</p>"
	html += "</body></html>"
	mob << browse(html, "window=AIKills;size=320x420")

client/proc/ShowSelfLogs()
	if(!mob) return
	var/dir = "Saves/PlayerLogs/[mob.key]/sanitized/"
	var/list/entries = flist(dir)
	if(entries) entries -= "sanitized/"
	if(!entries || !entries.len)
		mob << browse("<html><body bgcolor=#0a0f1a text=#cfe7ff style='font-family:sans-serif;padding:10px'>You have no logs on record.</body></html>", "window=SelfLogs;size=320x120")
		return
	var/sel = input(mob, "Which log do you want to read?", "Self Logs") as null|anything in entries
	if(!sel) return
	// logger html_encodes messages, decode so the <font> colors render. light bg suits them
	var/content = html_decode(file2text(file("[dir][sel]")))
	mob << browse("<html><head><title>Log: [sel]</title></head><body bgcolor=#f4f1e8 text=#101010 style='font-family:sans-serif;padding:6px'><b style='color:#b00000'>[sel]</b><hr>[content]</body></html>", "window=Log;size=560x600")

client/proc/BuildPassivesContent()
	cmenu_pass_list = mob.GetMenuPassives()
	cmenu_pass_px = 0
	cmenu_pass_target = 0
	cmenu_pass_rows = list()
	for(var/i = 1 to PASS_ROWS)
		var/atom/movable/shud/cmpassrow/r = new
		r.maptext_width = 545
		cmenu_pass_rows += r
		cmenu_objs += r
	cmenu_track = new
	cmenu_track.icon = 'HUD/scroll_track.png'
	cmenu_track.screen_loc = CMloc(588, PASS_TRACK_Y + PASS_TRACK_H)
	cmenu_objs += cmenu_track
	cmenu_thumb = new
	cmenu_thumb.icon = CMENU_R2
	cmenu_objs += cmenu_thumb
	var/atom/movable/shud/cmmask/mt = new
	mt.icon = 'HUD/passmask_top.png'
	mt.screen_loc = CMloc(0, 90 + 26)
	cmenu_objs += mt
	var/atom/movable/shud/cmmask/mb = new
	mb.icon = 'HUD/passmask_bottom.png'
	mb.screen_loc = CMloc(0, 312 + 32)
	cmenu_objs += mb
	RefreshPassRows()

client/proc/RefreshPassRows()
	if(!cmenu_pass_list || !cmenu_pass_rows) return
	var/total = cmenu_pass_list.len
	var/maxpx = max(0, total * PASS_RH - PASS_BAND_H)
	cmenu_pass_px = clamp(cmenu_pass_px, 0, maxpx)
	var/sub = cmenu_pass_px % PASS_RH
	var/first = (cmenu_pass_px - sub) / PASS_RH
	for(var/j = 1 to cmenu_pass_rows.len)
		var/atom/movable/shud/cmpassrow/r = cmenu_pass_rows[j]
		r.screen_loc = CMloc(26, (PASS_Y0 + (j - 1) * PASS_RH - sub) + CMENU_VY)
		var/idx = first + j
		if(idx <= total)
			r.pass_name = cmenu_pass_list[idx]
			var/pv = (mob.passive_handler && mob.passive_handler.passives) ? mob.passive_handler.passives[r.pass_name] : null
			var/vtxt = isnull(pv) ? "" : " - [pv]"
			r.maptext = "<span style=\"[CMENU_FONT]; color:#ffffff\">&#9670; [r.pass_name]<span style=\"color:#ffd278\">[vtxt]</span></span>"
			r.alpha = 255
		else
			r.pass_name = null
			r.maptext = ""
			r.alpha = 0
	if(cmenu_thumb)
		if(maxpx <= 0)
			cmenu_thumb.alpha = (total > 0) ? 80 : 0
			cmenu_thumb.screen_loc = CMloc(589, PASS_TRACK_Y + PASS_THUMB_H)
		else
			cmenu_thumb.alpha = 255
			var/off = round((cmenu_pass_px / maxpx) * (PASS_TRACK_H - PASS_THUMB_H))
			cmenu_thumb.screen_loc = CMloc(589, PASS_TRACK_Y + off + PASS_THUMB_H)

client/proc/SetPassPx(px)
	if(!cmenu_pass_list) return
	var/maxpx = max(0, cmenu_pass_list.len * PASS_RH - PASS_BAND_H)
	cmenu_pass_px = clamp(px, 0, maxpx)
	cmenu_pass_target = cmenu_pass_px   // drag/click cancels any running wheel glide
	RefreshPassRows()

client/proc/ScrollTrackTo(params)
	if(!cmenu_pass_list) return
	var/maxpx = max(0, cmenu_pass_list.len * PASS_RH - PASS_BAND_H)
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
	var/local_h = (row - 1) * 32 + py - (cm_aty - 1) * 32
	var/frac = ((CMENU_H - PASS_TRACK_Y) - local_h) / PASS_TRACK_H
	frac = clamp(frac, 0, 1)
	SetPassPx(round(frac * maxpx))

// real sig is 6 args. use only the sign, the OS reports big magnitudes (120/notch)
client/MouseWheel(object, delta_x, delta_y, location, control, params)
	if(cmenu_open && cmenu_tab == 1 && cmenu_pass_list)
		var/maxpx = max(0, cmenu_pass_list.len * PASS_RH - PASS_BAND_H)
		var/dir = (delta_y > 0) ? -1 : 1
		cmenu_pass_target = clamp(cmenu_pass_target + dir * PASS_RH, 0, maxpx)
		if(!cmenu_pass_anim) AnimatePassScroll()
		return
	if(cmenu_open && cmenu_tab == 3 && cmenu_gear_list)
		SetGearRow(gear_scroll_row + ((delta_y > 0) ? -1 : 1))
		return
	if(cmenu_open && cmenu_tab == 2 && cmenu_cust_list)
		var/maxpx = CustMaxPx()
		var/dir = (delta_y > 0) ? -1 : 1
		cust_scroll_target = clamp(cust_scroll_target + dir * CUST_RH, 0, maxpx)
		if(!cust_anim) AnimateCustScroll()
		return
	..()

client/proc/ScrollTrackDispatch(params)
	if(cmenu_tab == 3) ScrollGearTrack(params)
	else if(cmenu_tab == 2) ScrollCustTrack(params)
	else ScrollTrackTo(params)

client/proc/AnimatePassScroll()
	set waitfor = 0
	cmenu_pass_anim = TRUE
	while(cmenu_open && cmenu_tab == 1 && cmenu_pass_list && cmenu_pass_px != cmenu_pass_target)
		var/diff = cmenu_pass_target - cmenu_pass_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1   // always close the last pixels
		cmenu_pass_px += stepp
		RefreshPassRows()
		sleep(world.tick_lag)
	cmenu_pass_anim = FALSE

client/proc/UpdateCharacterMenu()
	if(!cmenu_open || !mob) return
	var/list/D = mob.GetCharMenuData()
	for(var/k in cmenu_vals)
		var/atom/movable/shud/cmval/v = cmenu_vals[k]
		v.maptext = "<span style=\"[CMENU_FONT]; color:#ffffff; text-align:[v.text_align]\">[D[k]]</span>"
	if(cmenu_tab == 0)
		var/list/fk = list("fstr","fend","fspd","ffor","foff","fdef")
		for(var/i = 1 to cmenu_fills.len)
			var/atom/movable/shud/cmfill/fl = cmenu_fills[i]
			var/icon/ic = icon(CMENU_BARFILL_RESOURCE)
			ic.Scale(max(1, round(74 * D[fk[i]])), 2)
			fl.icon = ic
		var/list/buffs = mob.GetMenuBuffs()
		for(var/i = 1 to cmenu_buffs.len)
			var/atom/movable/shud/cmbuff/b = cmenu_buffs[i]
			if(i <= buffs.len)
				var/obj/Skills/sk = buffs[i]
				b.icon = sk.icon
				b.icon_state = sk.icon_state
				b.buff_name = sk.name
				b.alpha = 255
			else
				b.alpha = 0
				b.buff_name = null
	cm_name.maptext = "<span style=\"[CMENU_FONT]; color:#ffffff\">[uppertext(mob.name)]</span>"
	cm_ident.maptext = "<span style=\"[CMENU_FONT]; color:#96c3e1\">[D["identity"]]</span>"
	cm_pot.maptext = "<span style=\"[CMENU_FONT]; color:#ffd278\">[D["potential"]]</span>"
	var/fc = (mob.PotentialStatus == "Focused") ? "#5af078" : "#5bb0ff"
	cm_focus.maptext = "<span style=\"[CMENU_FONT]; color:[fc]\">[uppertext(mob.PotentialStatus)]</span>"
	cm_pron.maptext = "<span style=\"[CMENU_FONT]; color:#8be9ff\">[D["pronouns"]]</span>"
	cm_rp.maptext = "<span style=\"[CMENU_FONT]; text-align:right; color:#96c3e1\">REWARD POINTS <span style=\"color:#ffffff\">[D["rp"]]</span></span>"
	cm_rpused.maptext = "<span style=\"[CMENU_FONT]; text-align:right; color:#96c3e1\">REWARD POINTS USED <span style=\"color:#ffffff\">[D["rpused"]]</span></span>"

//////////////////////////////////////////////////////////////////
// Passive description popup
//////////////////////////////////////////////////////////////////

client/proc/HideDescPanel()
	HideGearPassiveInfo()
	if(cmenu_desc_objs)
		while(cmenu_desc_objs.len)
			var/atom/movable/o = cmenu_desc_objs[cmenu_desc_objs.len]
			cmenu_desc_objs.len--
			screen -= o
			del o
		cmenu_desc_objs = null

client/proc/HideGearPassiveInfo()
	if(cmenu_gearpass_objs)
		while(cmenu_gearpass_objs.len)
			var/atom/movable/o = cmenu_gearpass_objs[cmenu_gearpass_objs.len]
			cmenu_gearpass_objs.len--
			screen -= o
			del o
		cmenu_gearpass_objs = null

client/proc/ShowGearPassiveInfo(name)
	HideGearPassiveInfo()
	if(!name || !cmenu_open) return
	cmenu_gearpass_objs = list()
	var/atom/movable/shud/gearpasspanel/P = new
	P.icon = CMENU_R3
	P.screen_loc = CMloc(122, 70 + 168)
	cmenu_gearpass_objs += P
	var/atom/movable/shud/gearpasstext/T = new
	T.maptext_width = 350
	T.screen_loc = CMloc(136, 82 + CMENU_VY)
	T.maptext = gspan(name, "#ffd278", "left")
	cmenu_gearpass_objs += T
	var/atom/movable/shud/gearpasstext/B = new
	B.maptext_width = 352
	B.maptext_height = 130
	B.screen_loc = CMloc(136, 106 + CMENU_VY)
	var/d = (global.PassiveInfo && (name in global.PassiveInfo)) ? StripBalanceNote(global.PassiveInfo[name]) : "No description available."
	B.maptext = gspan(d, "#ffffff", "left")
	cmenu_gearpass_objs += B
	var/atom/movable/shud/gearpasstext/H = new
	H.maptext_width = 352
	H.screen_loc = CMloc(136, 222 + CMENU_VY)
	H.maptext = gspan("right-click to close", "#7a9bb5", "left")
	cmenu_gearpass_objs += H
	for(var/atom/movable/o in cmenu_gearpass_objs)
		screen += o
	KineticEntrance(cmenu_gearpass_objs)

// ctx picks which panel to refresh after, "gear" or "inv"
client/proc/RenameItem(obj/Items/it, ctx)
	set waitfor = 0
	if(!istype(it) || !mob) return
	var/nn = input(mob, "Enter a new name for [it.name].", "Rename", it.name) as text|null
	if(isnull(nn) || !length(nn)) return
	it.name = nn
	if(ctx == "gear")
		ShowGearDetail(it)
	else
		BuildInvPage()
		ShowItemDesc(it)

client/proc/GearLayerPrompt(obj/Items/it)
	set waitfor = 0
	if(!istype(it) || !mob) return
	var/np = input(mob, "Set the draw layer for [it.name].\n0 = default (front-most). Higher numbers sit further BEHIND other layers.", "Layer Priority", it.LayerPriority) as num|null
	if(isnull(np)) return
	it.LayerPriority = np
	if(findtext(it.suffix, "Equipped"))
		mob.AppearanceOff()
		mob.AppearanceOn()
	ShowGearDetail(it)

client/proc/ShowPassDesc(name)
	HideDescPanel()
	if(!name || !cmenu_open) return
	cmenu_desc_objs = list()
	var/atom/movable/shud/cmdesc/P = new
	P.icon = CMENU_R3
	P.screen_loc = CMloc(122, 110 + 168)
	cmenu_desc_objs += P
	var/atom/movable/shud/cmdtext/T = new
	T.maptext_width = 350
	T.screen_loc = CMloc(136, 122 + CMENU_VY)
	T.maptext = "<span style=\"[CMENU_FONT]; color:#ffd278\">[name]</span>"
	cmenu_desc_objs += T
	var/atom/movable/shud/cmdtext/B = new
	B.maptext_width = 352
	B.maptext_height = 130
	B.screen_loc = CMloc(136, 146 + CMENU_VY)
	var/d = (global.PassiveInfo && (name in global.PassiveInfo)) ? StripBalanceNote(global.PassiveInfo[name]) : "No description available."
	B.maptext = "<span style=\"[CMENU_FONT]; color:#ffffff\">[d]</span>"
	cmenu_desc_objs += B
	var/atom/movable/shud/cmdtext/H = new
	H.maptext_width = 352
	H.screen_loc = CMloc(136, 262 + CMENU_VY)
	H.maptext = "<span style=\"[CMENU_FONT]; color:#7a9bb5\">right-click to close</span>"
	cmenu_desc_objs += H
	for(var/atom/movable/o in cmenu_desc_objs)
		screen += o
	KineticEntrance(cmenu_desc_objs)

//////////////////////////////////////////////////////////////////
// Gear tab
//////////////////////////////////////////////////////////////////

client/proc/gspan(txt, col, align = "left")
	return "<span style=\"[CMENU_FONT]; color:[col]; text-align:[align]\">[txt]</span>"

client/proc/MkGVal(key, dx, dy, w, align)
	var/atom/movable/shud/cmval/v = new
	v.maptext_width = w
	v.text_align = align
	v.screen_loc = CMloc(dx, dy + CMENU_VY)
	cmenu_gvals[key] = v
	cmenu_objs += v

client/proc/MkGLabel(txt, dx, dy, w, col, align)
	var/atom/movable/shud/cmtext/L = new
	L.maptext_width = w
	L.screen_loc = CMloc(dx, dy + CMENU_VY)
	L.maptext = gspan(txt, col, align)
	cmenu_objs += L
	return L

// fit any item icon into a centered box-px square, ignoring its own size/offsets
// autocropped icons cached by "[icon]_[state]" so the pixel scan runs once per sprite
/var/list/CroppedIconCache = list()

/proc/FitIconToBox(atom/movable/disp, atom/source, box)
	disp.overlays = null
	disp.underlays = null
	if(!source || !source.icon)
		disp.icon = null
		disp.alpha = 0
		return
	var/ckey = "[source.icon]_[source.icon_state]"
	var/icon/base = CroppedIconCache[ckey]
	if(!base)
		base = icon(source.icon, source.icon_state)
		// trim transparent padding so we center the visible sprite, not the icon box
		var/w = base.Width()
		var/h = base.Height()
		var/minx = 0
		var/miny = 0
		var/maxx = 0
		var/maxy = 0
		var/found = 0
		for(var/x = 1 to w)
			for(var/y = 1 to h)
				if(base.GetPixel(x, y) != null)
					if(!found)
						minx = x; maxx = x; miny = y; maxy = y; found = 1
					else
						if(x < minx) minx = x
						if(x > maxx) maxx = x
						if(y < miny) miny = y
						if(y > maxy) maxy = y
		if(found)
			base.Crop(minx, miny, maxx, maxy)
		CroppedIconCache[ckey] = base
	var/icon/I = icon(base)   // copy before scaling so the cached base stays intact
	var/iw = I.Width()
	var/ih = I.Height()
	var/m = max(iw, ih)
	if(m > box)
		var/sc = box / m
		I.Scale(max(1, round(iw * sc)), max(1, round(ih * sc)))
		iw = I.Width(); ih = I.Height()
	// center by padding into a box canvas. screen_loc repaints HUD icons here, pixel_x/y does not
	var/cox = round((box - iw) / 2)
	var/coy = round((box - ih) / 2)
	I.Crop(1 - cox, 1 - coy, box - cox, box - coy)
	disp.icon = I
	disp.icon_state = ""
	disp.color = source.color
	disp.pixel_x = 0
	disp.pixel_y = 0
	disp.alpha = 255

/proc/GearCat(obj/Items/it)
	if(istype(it, /obj/Items/Armor)) return "Armor"
	if(istype(it, /obj/Items/Enchantment/Staff)) return "Catalyst"
	return "Weapon"

/var/list/IconVisCache = list()
/proc/IconVisCenter(ic, state)
	if(!ic) return null
	var/key = "[ic]_[state]"
	var/list/c = IconVisCache[key]
	if(c) return c
	var/icon/I = icon(ic, state)
	var/w = I.Width()
	var/h = I.Height()
	var/minx = 0
	var/miny = 0
	var/maxx = 0
	var/maxy = 0
	var/found = 0
	for(var/x = 1 to w)
		for(var/y = 1 to h)
			if(I.GetPixel(x, y) != null)
				if(!found)
					minx = x; maxx = x; miny = y; maxy = y; found = 1
				else
					if(x < minx) minx = x
					if(x > maxx) maxx = x
					if(y < miny) miny = y
					if(y > maxy) maxy = y
	c = found ? list((minx + maxx) / 2, (miny + maxy) / 2) : list(w / 2, h / 2)
	IconVisCache[key] = c
	return c

// flatten body + overlays into one icon (BYOND has no getFlatIcon). exclude_icon skips one overlay
/proc/GetFlatIcon(atom/A, exclude_icon)
	if(!A || !A.icon) return null
	var/icon/flat = icon(A.icon, A.icon_state, SOUTH)
	if(A.color) flat.Blend(A.color, ICON_MULTIPLY)
	var/list/sorted = list()
	for(var/image/O in A.overlays)
		if(!O.icon) continue
		if(exclude_icon && O.icon == exclude_icon) continue
		var/placed = 0
		for(var/i = 1 to sorted.len)
			var/image/S = sorted[i]
			if(O.layer < S.layer)
				sorted.Insert(i, O)
				placed = 1
				break
		if(!placed) sorted += O
	for(var/image/O in sorted)
		var/icon/oi = icon(O.icon, O.icon_state, (O.dir ? O.dir : SOUTH))
		if(O.color) oi.Blend(O.color, ICON_MULTIPLY)
		flat.Blend(oi, ICON_OVERLAY, O.pixel_x + 1, O.pixel_y + 1)
	return flat

// like FitIconToBox but takes a raw icon ref and RETURNS the centering offsets
/proc/FitIconToBoxIcon(atom/movable/disp, iconref, state, box, nocache = 0)
	disp.overlays = null
	disp.underlays = null
	if(!iconref)
		disp.icon = null
		disp.alpha = 0
		return list(round(box / 2), round(box / 2))
	var/ckey = "[iconref]_[state]"
	var/icon/base = nocache ? null : CroppedIconCache[ckey]
	if(!base)
		base = icon(iconref, state)
		var/w = base.Width()
		var/h = base.Height()
		var/minx = 0
		var/miny = 0
		var/maxx = 0
		var/maxy = 0
		var/found = 0
		for(var/x = 1 to w)
			for(var/y = 1 to h)
				if(base.GetPixel(x, y) != null)
					if(!found)
						minx = x; maxx = x; miny = y; maxy = y; found = 1
					else
						if(x < minx) minx = x
						if(x > maxx) maxx = x
						if(y < miny) miny = y
						if(y > maxy) maxy = y
		if(found)
			base.Crop(minx, miny, maxx, maxy)
		if(!nocache) CroppedIconCache[ckey] = base
	var/icon/I = icon(base)
	var/iw = I.Width()
	var/ih = I.Height()
	var/m = max(iw, ih)
	if(m > box)
		var/sc = box / m
		I.Scale(max(1, round(iw * sc)), max(1, round(ih * sc)))
		iw = I.Width(); ih = I.Height()
	disp.icon = I
	disp.icon_state = ""
	disp.alpha = 255
	return list(round((box - iw) / 2), round((box - ih) / 2))

// composite a mob look into one flat icon. mob.overlays cant be read, so rebuild from items + hair
/proc/FlattenCharacter(mob/M, obj/Items/skip_item, skip_hair)
	var/icon/flat = icon(M.icon, M.icon_state, SOUTH, 1)   // frame 1 only, no walk animation
	if(M.color) flat.Blend(M.color, ICON_MULTIPLY)
	var/list/worn = list()
	for(var/obj/Items/I in M)
		if(!findtext(I.suffix, "Equipped")) continue
		if(skip_item && I == skip_item) continue
		if(I.EquipIcon || I.icon) worn += I
	// higher LayerPriority renders further back, so blend those first
	var/list/sorted = list()
	for(var/obj/Items/I in worn)
		var/placed = 0
		for(var/k = 1 to sorted.len)
			var/obj/Items/S = sorted[k]
			if(I.LayerPriority > S.LayerPriority)
				sorted.Insert(k, I)
				placed = 1
				break
		if(!placed) sorted += I
	for(var/obj/Items/I in sorted)
		var/icon/ov = icon(I.EquipIcon ? I.EquipIcon : I.icon, "", SOUTH, 1)
		if(I.color) ov.Blend(I.color, ICON_MULTIPLY)
		flat.Blend(ov, ICON_OVERLAY, 1 + I.pixel_x, 1 + I.pixel_y)
	if(!skip_hair && M.Hair_Base)
		var/icon/h = icon(M.Hair_Base, "", SOUTH, 1)
		flat.Blend(h, ICON_OVERLAY, 1 + M.HairX, 1 + M.HairY)
	return flat

/proc/FlatVisCenter(icon/I)
	var/w = I.Width()
	var/h = I.Height()
	var/minx = 0
	var/miny = 0
	var/maxx = 0
	var/maxy = 0
	var/found = 0
	for(var/x = 1 to w)
		for(var/y = 1 to h)
			if(I.GetPixel(x, y) != null)
				if(!found)
					minx = x; maxx = x; miny = y; maxy = y; found = 1
				else
					if(x < minx) minx = x
					if(x > maxx) maxx = x
					if(y < miny) miny = y
					if(y > maxy) maxy = y
	return found ? list((minx + maxx) / 2, (miny + maxy) / 2) : list(w / 2, h / 2)

client/proc/BuildGearContent()
	cmenu_gvals = list()
	cmenu_gslots = list()
	if(cmenu_gear_sel < 1 || cmenu_gear_sel > 3) cmenu_gear_sel = 1
	var/list/slotlabels = list("WEAPON", "CATALYST", "ARMOR")
	var/list/namekeys = list("wname", "cname", "aname")
	for(var/i = 1 to 3)
		var/sy = 120 + (i - 1) * 48
		var/atom/movable/shud/cmgearslot/s = new
		s.slot_idx = i
		s.screen_loc = CMloc(26, sy + 42)
		cmenu_gslots += s
		cmenu_objs += s
		MkGLabel(slotlabels[i], 78, sy + 4, 140, "#96c3e1", "left")
		MkGVal(namekeys[i], 78, sy + 22, 214, "left")
	cmenu_gsel_hl = new
	cmenu_gsel_hl.icon = 'HUD/slot_sel.png'
	cmenu_gsel_hl.layer = CMENU_LAYER + 0.34
	cmenu_gsel_hl.mouse_opacity = 0
	cmenu_objs += cmenu_gsel_hl
	cmenu_gdmglbl = MkGLabel("Damage", 26, 290, 170, "#8be9ff", "left"); MkGVal("edmg", 26, 290, 264, "right")
	cmenu_gacclbl = MkGLabel("Accuracy", 26, 306, 130, "#8be9ff", "left"); MkGVal("eacc", 26, 306, 264, "right")
	cmenu_gspdlbl = MkGLabel("Speed", 26, 322, 130, "#8be9ff", "left");    MkGVal("espd", 26, 322, 264, "right")
	cmenu_gear_list = mob.InvItemsFor("Gear")
	gear_scroll_row = 0
	cmenu_gear_grid = list()
	cmenu_gear_badges = list()
	for(var/r = 0 to GEAR_ROWS - 1)
		for(var/c = 0 to GEAR_COLS - 1)
			var/cx = GEAR_X0 + c * GEAR_CW
			var/cy = GEAR_Y0 + r * GEAR_RH
			var/atom/movable/shud/cmgeargrid/cell = new
			cell.screen_loc = CMloc(cx + 2, cy + 38)
			cmenu_gear_grid += cell
			cmenu_objs += cell
			var/atom/movable/shud/cmtext/badge = new
			badge.maptext_width = 14
			badge.maptext = gspan("E", "#8be9ff", "left")
			badge.layer = CMENU_LAYER + 0.45
			badge.screen_loc = CMloc(cx + 28, cy + 40)
			badge.alpha = 0
			cmenu_gear_badges += badge
			cmenu_objs += badge
	cmenu_geartrack = new
	cmenu_geartrack.icon = 'HUD/scroll_track.png'
	cmenu_geartrack.screen_loc = CMloc(582, GEAR_TRACK_Y + GEAR_TRACK_H)
	cmenu_objs += cmenu_geartrack
	cmenu_gearthumb = new
	cmenu_gearthumb.icon = CMENU_R2
	cmenu_objs += cmenu_gearthumb
	UpdateGearLeft()
	SelectGearSlot(cmenu_gear_sel)
	RefreshGearGrid()

client/proc/UpdateGearLeft()
	if(!mob) return
	var/list/nk = list("wname", "cname", "aname")
	for(var/i = 1 to 3)
		var/obj/Items/it = mob.GetGearItem(i)
		var/atom/movable/shud/cmgearslot/s = cmenu_gslots[i]
		FitIconToBox(s, it, 40)
		var/atom/movable/v = cmenu_gvals[nk[i]]
		v.maptext = it ? gspan(it.name, "#ffffff", "left") : gspan("(empty)", "#7a9bb5", "left")

client/proc/SelectGearSlot(idx)
	if(idx < 1 || idx > 3) return
	cmenu_gear_sel = idx
	if(cmenu_gsel_hl)
		var/sy = 120 + (idx - 1) * 48
		cmenu_gsel_hl.screen_loc = CMloc(24, sy + 44)
		cmenu_gsel_hl.alpha = 255
	UpdateGearEff(idx)

client/proc/UpdateGearEff(idx)
	if(!mob || !cmenu_gvals) return
	var/obj/Items/it = mob.GetGearItem(idx)
	var/a = it ? 255 : 0   // empty slot hides the whole block
	if(cmenu_gdmglbl)
		cmenu_gdmglbl.maptext = gspan((idx == 3) ? "Damage Reduction" : "Damage", "#8be9ff", "left")
		cmenu_gdmglbl.alpha = a
	if(cmenu_gacclbl) cmenu_gacclbl.alpha = a
	if(cmenu_gspdlbl) cmenu_gspdlbl.alpha = a
	cmenu_gvals["edmg"].alpha = a
	cmenu_gvals["eacc"].alpha = a
	cmenu_gvals["espd"].alpha = a
	if(!it) return
	var/list/E = mob.GetGearEff(it)
	cmenu_gvals["edmg"].maptext = gspan("[round(E["dmg"], 0.01)]x", "#ffffff", "right")
	cmenu_gvals["eacc"].maptext = gspan("[round(E["acc"], 0.01)]x", "#ffffff", "right")
	cmenu_gvals["espd"].maptext = gspan("[round(E["spd"], 0.01)]x", "#ffffff", "right")

client/proc/GearMaxRow()
	if(!cmenu_gear_list) return 0
	var/totrows = round((cmenu_gear_list.len + GEAR_COLS - 1) / GEAR_COLS)
	return max(0, totrows - GEAR_ROWS)

client/proc/RefreshGearGrid()
	if(!cmenu_gear_grid) return
	var/total = cmenu_gear_list ? cmenu_gear_list.len : 0
	for(var/r = 0 to GEAR_ROWS - 1)
		for(var/c = 0 to GEAR_COLS - 1)
			var/ci = r * GEAR_COLS + c + 1
			var/atom/movable/shud/cmgeargrid/cell = cmenu_gear_grid[ci]
			var/atom/movable/badge = cmenu_gear_badges[ci]
			var/idx = (gear_scroll_row + r) * GEAR_COLS + c + 1
			if(idx <= total)
				var/obj/Items/it = cmenu_gear_list[idx]
				cell.gitem = it
				FitIconToBox(cell, it, 36)
				badge.alpha = findtext(it.suffix, "Equipped") ? 255 : 0
			else
				cell.gitem = null
				cell.icon = null
				cell.alpha = 0
				badge.alpha = 0
	if(cmenu_gearthumb)
		var/maxrow = GearMaxRow()
		if(maxrow <= 0)
			cmenu_gearthumb.alpha = 0
		else
			cmenu_gearthumb.alpha = 255
			var/off = round((gear_scroll_row / maxrow) * (GEAR_TRACK_H - GEAR_THUMB_H))
			cmenu_gearthumb.screen_loc = CMloc(583, GEAR_TRACK_Y + off + GEAR_THUMB_H)

client/proc/SetGearRow(row)
	gear_scroll_row = clamp(row, 0, GearMaxRow())
	RefreshGearGrid()

client/proc/ScrollGearTrack(params)
	var/maxrow = GearMaxRow()
	if(maxrow <= 0) return
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
	var/local_h = (row - 1) * 32 + py - (cm_aty - 1) * 32
	var/frac = ((CMENU_H - GEAR_TRACK_Y) - local_h) / GEAR_TRACK_H
	frac = clamp(frac, 0, 1)
	SetGearRow(round(frac * maxrow))

client/proc/EquipGearItem(obj/Items/it)
	if(!it || !mob) return
	it.Click()
	cmenu_gear_list = mob.InvItemsFor("Gear")
	UpdateGearLeft()
	SelectGearSlot(cmenu_gear_sel)
	RefreshGearGrid()

client/proc/AddDescLine(txt, dx, dy, w)
	var/atom/movable/shud/cmdtext/L = new
	L.maptext_width = w
	L.maptext_height = 16
	L.screen_loc = CMloc(dx, dy + CMENU_VY)
	L.maptext = txt
	cmenu_desc_objs += L

client/proc/ShowGearDetail(obj/Items/it)
	HideDescPanel()
	if(!it || !cmenu_open) return
	cmenu_desc_objs = list()
	var/atom/movable/shud/cmdesc/P = new
	P.icon = 'HUD/geardetail.png'
	P.screen_loc = CMloc(120, 32 + 280)
	cmenu_desc_objs += P
	var/cat = GearCat(it)
	var/ly = 50
	AddDescLine(gspan(uppertext(it.name), "#ffd278", "center"), 134, ly, 356); ly += 22
	var/sub = cat
	if(it.Class in list("Light", "Medium", "Heavy")) sub += " - [it.Class]"
	AddDescLine(gspan(sub, "#96c3e1", "left"), 140, ly, 344); ly += 22
	var/list/SL = mob.GearStatList(it)
	for(var/lbl in SL)
		var/val = SL[lbl]
		AddDescLine(gspan(lbl, "#cfe7ff", "left"), 140, ly, 160)
		AddDescLine(gspan("[val > 0 ? "+" : ""][val]", (val >= 0) ? "#5af078" : "#ff6b6b", "right"), 140, ly, 344)
		ly += 16
	ly += 4
	if(it.Repairable)
		AddDescLine(gspan("Durability", "#8be9ff", "left"), 140, ly, 160)
		AddDescLine(gspan("[round(it.ShatterCounter)] / [round(it.ShatterMax)]", "#ffffff", "right"), 140, ly, 344)
		ly += 18
	var/eo = "None"; var/ed = "None"
	if(it.Element)
		if(cat == "Armor") ed = "[it.Element]"
		else eo = "[it.Element]"
	AddDescLine(gspan("Elemental Offense", "#8be9ff", "left"), 140, ly, 200)
	AddDescLine(gspan(eo, (eo == "None") ? "#9fb4c7" : "#ff9a4d", "right"), 140, ly, 344); ly += 16
	AddDescLine(gspan("Elemental Defense", "#8be9ff", "left"), 140, ly, 200)
	AddDescLine(gspan(ed, (ed == "None") ? "#9fb4c7" : "#ff9a4d", "right"), 140, ly, 344); ly += 22
	if(CanBeHat(it))
		AddDescLine(gspan("Toggle Hat", "#8be9ff", "left"), 140, ly, 120)
		var/atom/movable/shud/hattoggle/sw = new
		sw.item = it
		sw.ctx = "gear"
		sw.layer = CMENU_LAYER + 0.72
		sw.icon = it.IsHat ? HAT_TGL_ON[5] : HAT_TGL_OFF[5]
		sw.screen_loc = CMloc(218, ly - 2 + CMENU_VY)
		cmenu_desc_objs += sw
	var/atom/movable/shud/cmgearclick/lc = new
	lc.git = it
	lc.gact = "layer"
	lc.maptext_width = 164
	lc.maptext_height = 16
	lc.screen_loc = CMloc(320, ly + CMENU_VY)
	lc.maptext = gspan("&#8693; Layer: [it.LayerPriority]", "#8be9ff", "right")
	cmenu_desc_objs += lc
	ly += 20
	var/atom/movable/shud/cmgearclick/rn = new
	rn.git = it
	rn.gact = "rename"
	rn.maptext_width = 110
	rn.maptext_height = 16
	rn.screen_loc = CMloc(140, ly + CMENU_VY)
	rn.maptext = gspan("&#9998; Rename", "#8be9ff", "left")
	cmenu_desc_objs += rn
	ly += 20
	if(it.passives && it.passives.len)
		AddDescLine(gspan("PASSIVES", "#8be9ff", "left"), 140, ly, 200); ly += 16
		var/pn = 0
		for(var/p in it.passives)
			if(pn >= 5) break
			var/atom/movable/shud/cmgearclick/pr = new
			pr.git = it
			pr.gact = "passive"
			pr.pname = p
			pr.maptext_width = 340
			pr.maptext_height = 16
			pr.screen_loc = CMloc(146, ly + CMENU_VY)
			pr.maptext = gspan("&#9670; [p] <span style=\"color:#ffd278\">- [it.passives[p]]</span>", "#ffffff", "left")
			cmenu_desc_objs += pr
			ly += 16
			pn++
	AddDescLine(gspan("left-click an item to equip - right-click to close", "#7a9bb5", "center"), 134, 282, 356)
	for(var/atom/movable/o in cmenu_desc_objs)
		screen += o
	KineticEntrance(cmenu_desc_objs)

//////////////////////////////////////////////////////////////////
// Customization tab, scrollable list of customization verbs
//////////////////////////////////////////////////////////////////

client/proc/BuildCustomContent()
	cmenu_cust_list = (mob && mob.hud_customize_verbs) ? mob.hud_customize_verbs.Copy() : list()
	// pin the Reset_* verbs to the bottom of the list
	if(cmenu_cust_list.len)
		var/list/resets = list()
		for(var/vp in cmenu_cust_list.Copy())
			if(findtext("[vp:name]", "Reset") == 1)
				cmenu_cust_list -= vp
				resets += vp
		cmenu_cust_list += resets
	cust_px = 0
	cust_scroll_target = 0
	if(mob && !mob.cust_recent_colors) mob.cust_recent_colors = CUST_SWATCHES.Copy()
	if(cust_sel < 1 || cust_sel > cmenu_cust_list.len) cust_sel = 1
	cmenu_cust_rows = list()
	for(var/i = 1 to CUST_ROWS)
		var/atom/movable/shud/cmcustrow/r = new
		r.maptext_width = 250
		cmenu_cust_rows += r
		cmenu_objs += r
	cmenu_custtrack = new
	cmenu_custtrack.icon = 'HUD/scroll_track.png'
	cmenu_custtrack.screen_loc = CMloc(288, CUST_TRACK_Y + CUST_TRACK_H)
	cmenu_objs += cmenu_custtrack
	cmenu_custthumb = new
	cmenu_custthumb.icon = CMENU_R2
	cmenu_objs += cmenu_custthumb
	cmenu_custmask_t = new
	cmenu_custmask_t.icon = 'HUD/custmask_top.png'
	cmenu_custmask_t.screen_loc = CMloc(0, 90 + 26)
	cmenu_objs += cmenu_custmask_t
	cmenu_custmask_b = new
	cmenu_custmask_b.icon = 'HUD/custmask_bottom.png'
	cmenu_custmask_b.screen_loc = CMloc(0, 312 + 32)
	cmenu_objs += cmenu_custmask_b
	RefreshCustRows()
	BuildCustPanel()

client/proc/CustMaxPx()
	if(!cmenu_cust_list) return 0
	return max(0, cmenu_cust_list.len * CUST_RH - CUST_BAND_H)

client/proc/RefreshCustRows()
	if(!cmenu_cust_rows) return
	var/total = cmenu_cust_list ? cmenu_cust_list.len : 0
	var/maxpx = CustMaxPx()
	cust_px = clamp(cust_px, 0, maxpx)
	var/sub = cust_px % CUST_RH
	var/first = (cust_px - sub) / CUST_RH
	for(var/j = 1 to cmenu_cust_rows.len)
		var/atom/movable/shud/cmcustrow/r = cmenu_cust_rows[j]
		r.screen_loc = CMloc(26, (CUST_Y0 + (j - 1) * CUST_RH - sub) + CMENU_VY)
		var/idx = first + j
		if(idx <= total)
			var/vp = cmenu_cust_list[idx]
			r.idx = idx
			var/col = (idx == cust_sel) ? "#8be9ff" : "#ffffff"
			r.maptext = "<span style=\"[CMENU_FONT]; color:[col]\">&#9670; [vp:name]</span>"
			r.alpha = 255
		else
			r.idx = null
			r.maptext = ""
			r.alpha = 0
	if(cmenu_custthumb)
		if(maxpx <= 0)
			cmenu_custthumb.alpha = (total > 0) ? 80 : 0
			cmenu_custthumb.screen_loc = CMloc(289, CUST_TRACK_Y + CUST_THUMB_H)
		else
			cmenu_custthumb.alpha = 255
			var/off = round((cust_px / maxpx) * (CUST_TRACK_H - CUST_THUMB_H))
			cmenu_custthumb.screen_loc = CMloc(289, CUST_TRACK_Y + off + CUST_THUMB_H)

client/proc/SetCustPx(px)
	if(!cmenu_cust_list) return
	cust_px = clamp(px, 0, CustMaxPx())
	cust_scroll_target = cust_px   // drag/click cancels any running wheel glide
	RefreshCustRows()

client/proc/AnimateCustScroll()
	set waitfor = 0
	cust_anim = TRUE
	while(cmenu_open && cmenu_tab == 2 && cmenu_cust_list && cust_px != cust_scroll_target)
		var/diff = cust_scroll_target - cust_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1   // always close the last pixels
		cust_px += stepp
		RefreshCustRows()
		sleep(world.tick_lag)
	cust_anim = FALSE

client/proc/ScrollCustTrack(params)
	var/maxpx = CustMaxPx()
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
	var/local_h = (row - 1) * 32 + py - (cm_aty - 1) * 32
	var/frac = ((CMENU_H - CUST_TRACK_Y) - local_h) / CUST_TRACK_H
	frac = clamp(frac, 0, 1)
	SetCustPx(round(frac * maxpx))

//////////////////////////////////////////////////////////////////
// Customization, right-hand panel per selected option
//////////////////////////////////////////////////////////////////

client/proc/SelectCustOption(idx)
	if(!cmenu_cust_list || idx < 1 || idx > cmenu_cust_list.len) return
	cust_sel = idx
	cust_target = null
	RefreshCustRows()
	BuildCustPanel()

// open Customization straight onto an item (inventory right-click shortcut)
client/proc/CustomizeItem(obj/Items/it)
	if(!it || !mob || !IsCustomizableItem(it)) return
	CloseInventory()
	if(!cmenu_open) OpenCharacterMenu()
	if(cmenu_tab != 2) CharMenuTab(2)
	for(var/i = 1 to cmenu_cust_list.len)
		var/vp = cmenu_cust_list[i]
		if("[vp:name]" == "Customize")
			cust_sel = i
			break
	cust_target = it
	RefreshCustRows()
	BuildCustPanel()

client/proc/ClearCustPanel()
	cmenu_cust_preview = null
	cmenu_cust_sprite = null
	cmenu_cust_offset = null
	if(cmenu_cust_panel)
		while(cmenu_cust_panel.len)
			var/atom/movable/o = cmenu_cust_panel[cmenu_cust_panel.len]
			cmenu_cust_panel.len--
			screen -= o
			del o
		cmenu_cust_panel = null

client/proc/CPanelText(txt, dx, dy, w, col, align)
	var/atom/movable/shud/cmtext/L = new
	L.maptext_width = w
	L.screen_loc = CMloc(dx, dy + CMENU_VY)
	L.maptext = gspan(txt, col, align)
	cmenu_cust_panel += L
	return L

client/proc/BuildCustPanel()
	ClearCustPanel()
	if(!mob || !cmenu_cust_list || cust_sel < 1 || cust_sel > cmenu_cust_list.len) return
	cmenu_cust_panel = list()
	var/vp = cmenu_cust_list[cust_sel]
	var/opt = "[vp:name]"
	cust_panel_opt = opt
	var/hdr = (opt == "Customize" && istype(cust_target, /obj/Items)) ? "CUSTOMIZE: [cust_target:name]" : opt
	CPanelText(hdr, 314, 102, 284, "#ffd278", "center")
	var/list/cfg = CUST_SPRITE_CFG[opt]
	if(opt == "Customize")
		if(istype(cust_target, /obj/Items))
			BuildCustSprite(CUST_ITEM_CFG)
		else
			BuildCustomizeIntro()
	else if(cfg)
		cust_target = mob
		BuildCustSprite(cfg)
	else if(opt == "Reset Appearance" || opt == "Reset Overlays")
		BuildCustConfirm(opt)
	else
		BuildCustVerb(opt)
	for(var/atom/movable/o in cmenu_cust_panel)
		screen += o

client/proc/CurrentCustCfg()
	if(cust_panel_opt == "Customize") return CUST_ITEM_CFG
	return CUST_SPRITE_CFG[cust_panel_opt]

client/proc/BuildCustomizeIntro()
	CPanelText("Retexture a piece of gear or clothing", 318, 152, 280, "#cfe7ff", "left")
	CPanelText("with your own image.", 318, 170, 280, "#cfe7ff", "left")
	var/atom/movable/shud/cmcustbtn/b = new
	b.icon = 'HUD/cust_button.png'
	b.action = "pickitem"
	b.screen_loc = CMloc(380, 210 + 26)
	cmenu_cust_panel += b
	var/atom/movable/pl = CPanelText("Choose Item...", 380, 218, 150, "#ffffff", "center")
	pl.layer = CMENU_LAYER + 0.5

// these run instantly, no window, so just a Confirm button
client/proc/BuildCustConfirm(opt)
	CPanelText("Run [opt] now?", 314, 158, 284, "#cfe7ff", "center")
	var/atom/movable/shud/cmcustbtn/b = new
	b.icon = 'HUD/cust_button.png'
	b.action = "open"
	b.screen_loc = CMloc(380, 232 + 26)
	cmenu_cust_panel += b
	var/atom/movable/ol = CPanelText("Confirm", 380, 240, 150, "#ffffff", "center")
	ol.layer = CMENU_LAYER + 0.5

client/proc/BuildCustVerb(opt)
	var/desc = (opt in CUSTOM_DESC) ? CUSTOM_DESC[opt] : "Opens this customization."
	CPanelText(desc, 318, 152, 280, "#cfe7ff", "left")
	CPanelText("This option opens in its own window.", 318, 176, 280, "#7a9bb5", "left")
	var/atom/movable/shud/cmcustbtn/b = new
	b.icon = 'HUD/cust_button.png'
	b.action = "open"
	b.screen_loc = CMloc(380, 232 + 26)
	cmenu_cust_panel += b
	var/atom/movable/ol = CPanelText("Open", 380, 240, 150, "#ffffff", "center")
	ol.layer = CMENU_LAYER + 0.5

client/proc/BuildCustSprite(cfg)
	var/atom/movable/shud/cmpreview/fr = new
	fr.icon = 'HUD/cust_preview.png'
	fr.screen_loc = CMloc(404, 128 + 104)
	cmenu_cust_preview = fr
	cmenu_cust_panel += fr
	cmenu_cust_sprite = new   // base passes clicks through to the frame
	cmenu_cust_sprite.layer = CMENU_LAYER + 0.46
	cmenu_cust_sprite.mouse_opacity = 0
	cmenu_cust_sprite.screen_loc = CMloc(412, 224)
	cmenu_cust_panel += cmenu_cust_sprite
	cmenu_cust_elem = new
	cmenu_cust_elem.layer = CMENU_LAYER + 0.47
	cmenu_cust_elem.mouse_opacity = 0
	cmenu_cust_elem.screen_loc = CMloc(412, 224)
	cmenu_cust_panel += cmenu_cust_elem
	cmenu_cust_hair = new   // hair above the edited piece, only shown when the item sits behind the hair
	cmenu_cust_hair.layer = CMENU_LAYER + 0.48
	cmenu_cust_hair.mouse_opacity = 0
	cmenu_cust_hair.alpha = 0
	cmenu_cust_hair.screen_loc = CMloc(412, 224)
	cmenu_cust_panel += cmenu_cust_hair
	CPanelText("drag on the preview to position", 310, 240, 292, "#7a9bb5", "center")
	cmenu_cust_offset = new
	cmenu_cust_offset.maptext_width = 292
	cmenu_cust_offset.action = "offset"
	cmenu_cust_offset.screen_loc = CMloc(310, 258 + CMENU_VY)
	cmenu_cust_panel += cmenu_cust_offset
	var/atom/movable/shud/cmcustbtn/b = new
	b.icon = 'HUD/cust_button.png'
	b.action = "browse"
	b.screen_loc = CMloc(330, 280 + 26)
	cmenu_cust_panel += b
	var/atom/movable/bl = CPanelText("Browse Image...", 330, 288, 150, "#ffffff", "center")
	bl.layer = CMENU_LAYER + 0.5
	if(cfg["col"])
		var/atom/movable/shud/cmcustbtn/cb = new
		cb.maptext_width = 60
		cb.action = "colorpick"
		cb.screen_loc = CMloc(486, 288 + CMENU_VY)
		cb.maptext = gspan("Color", "#8be9ff", "left")
		cmenu_cust_panel += cb
		var/list/sws = (mob && mob.cust_recent_colors) ? mob.cust_recent_colors : CUST_SWATCHES
		for(var/j = 1 to min(6, sws.len))
			var/atom/movable/shud/cmswatch/sw = new
			sw.icon = 'HUD/swatch_base.png'
			sw.swcolor = sws[j]
			sw.color = sws[j]
			sw.screen_loc = CMloc(486 + (j - 1) * 19, 326)
			cmenu_cust_panel += sw
	if(cfg["apply"] == "item")
		var/obj/Items/it = cust_target
		// spaced a full row apart so click regions never overlap (was the Change-item / Layer mix-up)
		var/atom/movable/shud/cmcustbtn/ci = new
		ci.maptext_width = 120
		ci.action = "pickitem"
		ci.screen_loc = CMloc(312, 140 + CMENU_VY)
		ci.maptext = gspan("&#8635; Change item", "#8be9ff", "left")
		cmenu_cust_panel += ci
		var/atom/movable/shud/cmcustbtn/lp = new
		lp.maptext_width = 150
		lp.action = "layerpriority"
		lp.screen_loc = CMloc(312, 172 + CMENU_VY)
		lp.maptext = gspan("&#8693; Layer: [istype(it) ? it.LayerPriority : 0]", "#8be9ff", "left")
		cmenu_cust_panel += lp
		if(CanBeHat(it))
			CPanelText("Toggle Hat", 312, 200, 90, "#8be9ff", "left")
			var/atom/movable/shud/hattoggle/sw = new
			sw.item = it
			sw.ctx = "cust"
			sw.layer = CMENU_LAYER + 0.5
			sw.icon = it.IsHat ? HAT_TGL_ON[5] : HAT_TGL_OFF[5]
			sw.screen_loc = CMloc(380, 198 + CMENU_VY)
			cmenu_cust_panel += sw
	RefreshCustPreview()

// re-flatten the character minus the edited piece. discrete edits only
client/proc/RebuildCustBase()
	if(!cmenu_cust_sprite || !cust_panel_opt || !mob) return
	var/list/cfg = CurrentCustCfg()
	if(!cfg) return
	var/atom/tgt = cust_target ? cust_target : mob
	var/obj/Items/edititem = (cfg["apply"] == "item" && istype(tgt, /obj/Items)) ? tgt : null
	var/itembehind = (edititem && !edititem.IsHat)   // item sits behind the hair, draw hair on its own layer on top
	var/icon/base
	if(cfg["apply"] == "hair")
		base = FlattenCharacter(mob, null, 1)
	else if(cfg["apply"] == "item")
		base = FlattenCharacter(mob, tgt, itembehind ? 1 : 0)
	else
		base = FlattenCharacter(mob, null, 0)
	// autocrop then center the character. FlatVisCenter mis-centers large custom icons, cropping fixes it
	var/w = base.Width()
	var/h = base.Height()
	var/minx = 0
	var/miny = 0
	var/maxx = 0
	var/maxy = 0
	var/found = 0
	for(var/x = 1 to w)
		for(var/y = 1 to h)
			if(base.GetPixel(x, y) != null)
				if(!found)
					minx = x; maxx = x; miny = y; maxy = y; found = 1
				else
					if(x < minx) minx = x
					if(x > maxx) maxx = x
					if(y < miny) miny = y
					if(y > maxy) maxy = y
	cust_crop_x = 0
	cust_crop_y = 0
	if(found)
		base.Crop(minx, miny, maxx, maxy)
		cust_crop_x = minx - 1
		cust_crop_y = miny - 1
	// position via screen_loc not pixel_x. pixel_x does not repaint a live HUD object, screen_loc does
	cust_base_cox = 412 + round((88 - base.Width()) / 2)
	cust_base_coy = 224 - round((88 - base.Height()) / 2)
	cmenu_cust_sprite.icon = base
	cmenu_cust_sprite.icon_state = ""
	cmenu_cust_sprite.color = null
	cmenu_cust_sprite.pixel_x = 0
	cmenu_cust_sprite.pixel_y = 0
	cmenu_cust_sprite.screen_loc = CMloc(cust_base_cox, cust_base_coy)
	cmenu_cust_sprite.alpha = 255
	if(cfg["apply"] == "icon")
		cmenu_cust_elem.icon = null
		cmenu_cust_elem.alpha = 0
	else
		var/elemicon
		if(tgt == mob)
			elemicon = mob.vars[cfg["spr"]]
			cmenu_cust_elem.color = null
		else
			var/obj/Items/it = tgt
			elemicon = it.EquipIcon ? it.EquipIcon : it.icon
			cmenu_cust_elem.color = it.color
		cmenu_cust_elem.icon = elemicon ? icon(elemicon, "", SOUTH, 1) : null
		cmenu_cust_elem.icon_state = ""
		cmenu_cust_elem.alpha = (elemicon ? 255 : 0)
	// when the item sits behind the hair, draw hair on top so the preview matches the real layering
	if(cmenu_cust_hair)
		if(itembehind && mob.Hair_Base)
			cmenu_cust_hair.icon = icon(mob.Hair_Base, "", SOUTH, 1)
			cmenu_cust_hair.icon_state = ""
			cmenu_cust_hair.color = null
			cmenu_cust_hair.alpha = 255
			cmenu_cust_hair.screen_loc = CMloc(cust_base_cox - cust_crop_x + mob.HairX, cust_base_coy + cust_crop_y - mob.HairY)
		else
			cmenu_cust_hair.alpha = 0
	RefreshCustElement()

// just reposition the edited piece. uses screen_loc not pixel_x so the move repaints
client/proc/RefreshCustElement()
	if(!cmenu_cust_elem || !cust_panel_opt || !mob) return
	var/list/cfg = CurrentCustCfg()
	if(!cfg) return
	var/atom/tgt = cust_target ? cust_target : mob
	var/ox = tgt.vars[cfg["ox"]]; if(isnull(ox)) ox = 0
	var/oy = tgt.vars[cfg["oy"]]; if(isnull(oy)) oy = 0
	if(cfg["apply"] == "icon")
		cmenu_cust_sprite.screen_loc = CMloc(cust_base_cox + ox, cust_base_coy - oy)
	else
		cmenu_cust_elem.pixel_x = 0
		cmenu_cust_elem.pixel_y = 0
		cmenu_cust_elem.screen_loc = CMloc(cust_base_cox - cust_crop_x + ox, cust_base_coy + cust_crop_y - oy)
	if(cmenu_cust_offset)
		cmenu_cust_offset.maptext = gspan("Offset    X: [ox]    Y: [oy]", "#8be9ff", "center")

client/proc/RefreshCustPreview()
	RebuildCustBase()

client/proc/CustButtonAction(action)
	switch(action)
		if("open")
			if(cmenu_cust_list && cust_sel >= 1 && cust_sel <= cmenu_cust_list.len)
				var/vp = cmenu_cust_list[cust_sel]
				spawn() call(usr, vp)()
		if("browse")
			CustBrowse()
		if("colorpick")
			CustColorPick()
		if("offset")
			CustOffsetInput()
		if("pickitem")
			OpenCustItemPicker()
		if("layerpriority")
			CustSetLayerPriority()

client/proc/ToggleHatClick(atom/movable/shud/hattoggle/sw)
	set waitfor = 0
	if(!sw || !mob) return
	var/obj/Items/it = sw.item
	if(!istype(it)) return
	it.IsHat = !it.IsHat
	if(findtext(it.suffix, "Equipped"))   // re-equip rebuilds overlays at the new layer
		mob.AppearanceOff()
		mob.AppearanceOn()
	AnimateHatToggle(sw, it.IsHat)
	if(sw.ctx == "cust") RebuildCustBase()

client/proc/AnimateHatToggle(atom/movable/shud/hattoggle/sw, on)
	set waitfor = 0
	var/list/frames = on ? HAT_TGL_ON : HAT_TGL_OFF
	for(var/f = 1 to frames.len)
		if(!sw) return
		sw.icon = frames[f]
		sleep(0.8)

// custom draw layer, mainly for gear that cant be slot-ordered
client/proc/CustSetLayerPriority()
	set waitfor = 0
	var/obj/Items/it = cust_target
	if(!istype(it) || !mob) return
	var/np = input(mob, "Set the draw layer for [it.name].\n0 = default (front-most). Higher numbers sit further BEHIND other layers.", "Layer Priority", it.LayerPriority) as num|null
	if(isnull(np)) return
	it.LayerPriority = np
	if(findtext(it.suffix, "Equipped"))
		mob.AppearanceOff()
		mob.AppearanceOn()
	BuildCustPanel()

client/proc/OpenCustItemPicker()
	set waitfor = 0
	if(!mob) return
	var/list/items = list()
	for(var/obj/Items/I in mob)
		if(IsCustomizableItem(I)) items += I
	if(!items.len)
		mob << "You have no customizable gear or clothing."
		return
	var/obj/Items/pick = input(mob, "Choose an item to customize.", "Customize") as null|anything in items
	if(!pick) return
	cust_target = pick
	BuildCustPanel()

client/proc/CustColorPick()
	set waitfor = 0
	if(!cust_panel_opt || !mob) return
	var/col = input(mob, "Choose a color.", "Color") as color|null
	if(col) SetCustColor(col)

client/proc/CustOffsetInput()
	set waitfor = 0
	var/list/cfg = CurrentCustCfg()
	var/atom/tgt = cust_target ? cust_target : mob
	if(!cfg || !tgt) return
	var/cx = tgt.vars[cfg["ox"]]; if(isnull(cx)) cx = 0
	var/cy = tgt.vars[cfg["oy"]]; if(isnull(cy)) cy = 0
	var/nx = input(mob, "Pixel X offset.", "Offset X", cx) as num|null
	var/ny = input(mob, "Pixel Y offset.", "Offset Y", cy) as num|null
	if(cfg["apply"] == "hair") mob.Hairz("Remove")   // remove old hair first so it cant duplicate
	if(!isnull(nx)) tgt.vars[cfg["ox"]] = nx
	if(!isnull(ny)) tgt.vars[cfg["oy"]] = ny
	ApplyCustOption()
	RefreshCustElement()

client/proc/CustBrowse()
	set waitfor = 0
	var/list/cfg = CurrentCustCfg()
	var/atom/tgt = cust_target ? cust_target : mob
	if(!cfg || !tgt) return
	var/Z = input(mob, "Choose an image.", "Browse Image") as icon|null
	if(!Z) return
	if(length(Z) > 102400)
		mob << "That file exceeds 100KB and can't be used."
		return
	switch(cfg["apply"])
		if("hair")
			mob.Hair_BaseRaw = Z
			var/Color = input(mob, "Choose a hair color, or cancel for none.", "Hair Color") as color|null
			var/icon/I = icon(Z)
			if(Color) I += Color
			mob.Hair_Base = I
			mob.Hair_Color = Color
			mob.Hairz("Add")
		if("item")
			var/obj/Items/it = tgt
			it.EquipIcon = Z
			it.icon = Z
			ApplyCustOption()
		else
			mob.icon = Z
	RefreshCustPreview()

client/proc/SetCustColor(col)
	var/list/cfg = CurrentCustCfg()
	var/atom/tgt = cust_target ? cust_target : mob
	if(!cfg || !cfg["col"] || !tgt) return
	tgt.vars[cfg["col"]] = col
	// move this color to the front of the recents. stored on the mob so it survives relog
	if(!mob.cust_recent_colors) mob.cust_recent_colors = CUST_SWATCHES.Copy()
	mob.cust_recent_colors -= col
	mob.cust_recent_colors.Insert(1, col)
	if(mob.cust_recent_colors.len > 6) mob.cust_recent_colors.Cut(7)
	if(cfg["apply"] == "hair")
		var/base = mob.Hair_BaseRaw ? mob.Hair_BaseRaw : mob.Hair_Base
		if(base)
			var/icon/I = icon(base)
			if(col) I += col
			mob.Hair_Base = I
			mob.Hairz("Add")
	else if(cfg["apply"] == "item")
		ApplyCustOption()
	BuildCustPanel()

client/proc/ApplyCustOption()
	var/list/cfg = CurrentCustCfg()
	if(!cfg || !mob) return
	if(cfg["apply"] == "hair")
		mob.Hairz("Add")
	else if(cfg["apply"] == "item")
		var/obj/Items/it = cust_target
		if(istype(it) && findtext(it.suffix, "Equipped"))
			mob.AppearanceOff()
			mob.AppearanceOn()

client/proc/MouseAbs(params)
	var/list/pl = params2list(params)
	var/sl = pl["screen-loc"]
	if(!sl) return null
	var/list/cm = splittext(sl, ",")
	if(cm.len < 2) return null
	var/list/xp = splittext(cm[1], ":")
	var/list/yp = splittext(cm[2], ":")
	if(xp.len < 2 || yp.len < 2) return null
	var/cx = text2num(xp[1]); var/px = text2num(xp[2])
	var/cy = text2num(yp[1]); var/py = text2num(yp[2])
	if(isnull(cx) || isnull(cy)) return null
	return list((cx - 1) * 32 + px, (cy - 1) * 32 + py)

client/proc/CustDragStart(params)
	var/list/cfg = CurrentCustCfg()
	var/atom/tgt = cust_target ? cust_target : mob
	if(!cfg || !tgt) return
	if(cfg["apply"] == "hair") mob.Hairz("Remove")   // remove old hair now so it cant duplicate
	cust_drag_ox = tgt.vars[cfg["ox"]]; if(isnull(cust_drag_ox)) cust_drag_ox = 0
	cust_drag_oy = tgt.vars[cfg["oy"]]; if(isnull(cust_drag_oy)) cust_drag_oy = 0
	var/list/m = MouseAbs(params)
	if(m)
		cust_drag_mx = m[1]; cust_drag_my = m[2]

client/proc/CustDragMove(params)
	var/list/cfg = CurrentCustCfg()
	var/atom/tgt = cust_target ? cust_target : mob
	if(!cfg || !tgt) return
	var/list/m = MouseAbs(params)
	if(!m) return
	tgt.vars[cfg["ox"]] = cust_drag_ox + (m[1] - cust_drag_mx)
	tgt.vars[cfg["oy"]] = cust_drag_oy + (m[2] - cust_drag_my)
	RefreshCustElement()

client/proc/CustDragEnd()
	ApplyCustOption()

//////////////////////////////////////////////////////////////////
// Data
//////////////////////////////////////////////////////////////////

mob/proc/GetGearItem(slot)
	switch(slot)
		if(1) return EquippedSword()
		if(2) return EquippedStaff()
		if(3) return EquippedArmor()
	return null

mob/proc/GetGearEff(obj/Items/it)
	var/list/D = list()
	D["dmg"] = (it && it.DamageEffectiveness) ? it.DamageEffectiveness : 1
	D["acc"] = (it && it.AccuracyEffectiveness) ? it.AccuracyEffectiveness : 1
	D["spd"] = (it && it.SpeedEffectiveness) ? it.SpeedEffectiveness : 1
	return D

mob/proc/GearStatList(obj/Items/it)
	var/list/out = list()
	if(!it) return out
	if(it.strAdd) out["Strength"] = it.strAdd
	if(it.endAdd) out["Endurance"] = it.endAdd
	if(it.spdAdd) out["Speed"] = it.spdAdd
	if(it.forAdd) out["Force"] = it.forAdd
	if(it.offAdd) out["Offense"] = it.offAdd
	if(it.defAdd) out["Defense"] = it.defAdd
	return out

mob/proc/GetMenuPassives()
	var/list/out = list()
	if(passive_handler && passive_handler.passives)
		for(var/p in passive_handler.passives)
			if(passive_handler.passives[p])
				out += p
	return out

mob/proc/GetCharMenuData()
	var/list/D = list()
	var/EffectiveAnger = Anger
	if(Anger)
		if(AngerMult > 1)
			EffectiveAnger = (EffectiveAnger - 1) * AngerMult + 1
		if(AngerThreshold && EffectiveAnger < AngerThreshold)
			EffectiveAnger = AngerThreshold
		if(DefianceCounter > 0 && !CheckSlotless("Great Ape"))
			EffectiveAnger += DefianceCounter * 0.05
		if(CyberCancel > 0)
			EffectiveAnger -= (EffectiveAnger - 1) * CyberCancel
			if(EffectiveAnger < 1) EffectiveAnger = 1
		if(PhylacteryNerf)
			EffectiveAnger -= EffectiveAnger * PhylacteryNerf
	var/BaseDisplay = HasPowerReplacement() ? GetPowerReplacement() * PowerBoost * RPPower : potential_power_mult * PowerBoost * RPPower
	var/PotPow = GetPowerReplacement() ? GetPowerReplacement() : potential_power_mult
	var/denom = PowerBoost * RPPower * round(potential_power_mult, 0.05)
	var/PDam = 1 + ((HasPureDamage() / 10) * glob.PURE_MODIFIER)
	var/PRed = 1 + ((HasPureReduction() / 10) * glob.PURE_MODIFIER)
	var/gk = (HasGodKi() && !passive_handler.Get("Utterly Powerless")) ? GetGodKi() : 0
	if(passive_handler.Get("God")) gk = "?"
	var/mk = (HasMaouKi() && !passive_handler.Get("Utterly Powerless")) ? GetMaouKi() : 0
	D["power"] = "[Power]"
	D["frompot"] = "[round(PotPow, 0.05)]"
	D["frombuffs"] = "x[Power_Multiplier]"
	D["base"] = "[round(BaseDisplay, 0.05)] / [round(denom, 0.05)]"
	D["powermult"] = "[round(potential_power_mult, 0.05) + PowerBoost]%"
	D["angermax"] = "[(AngerMax + AngerAdd) * 100]%"
	D["curanger"] = "[round((EffectiveAnger + AngerAdd) * 100)]%"
	D["bp"] = "[Commas(Get_Scouter_Reading(src))]"
	D["godki"] = "x[gk]"
	D["maouki"] = "x[mk]"
	D["energy"] = "[Commas(round(EnergyMax))]"
	D["str"] = "[round(GetStr(), 0.01)] ([round(BaseStr() + GetEquippedWeaponStrAdd(), 0.01)])"
	D["end"] = "[round(GetEnd(), 0.01)] ([round(BaseEnd() + GetEquippedWeaponEndAdd(), 0.01)])"
	D["spd"] = "[round(GetSpd(), 0.01)] ([round(BaseSpd() + GetEquippedWeaponSpdAdd(), 0.01)])"
	D["for"] = "[round(GetFor(), 0.01)] ([round(BaseFor() + GetEquippedWeaponForAdd(), 0.01)])"
	D["off"] = "[round(GetOff(), 0.01)] ([round(BaseOff() + GetEquippedWeaponOffAdd(), 0.01)])"
	D["def"] = "[round(GetDef(), 0.01)] ([round(BaseDef() + GetEquippedWeaponDefAdd(), 0.01)])"
	D["dboost"] = "x[PDam] ([PDam * 100]%)"
	D["dred"] = "x[PRed] ([PRed * 100]%)"
	D["recov"] = "[round(GetRecov(), 0.01)] ([BaseRecov()])"
	D["avg"] = "[round((GetStr() + GetEnd() + GetSpd() + GetFor() + GetOff() + GetDef()) / 6, 0.05)]"
	D["magic"] = "[getTotalMagicLevel()]"
	D["transpot"] = "[potential_trans]/100"
	D["chips"] = "[EnhanceChips]/[EnhanceChipsMax]"
	D["potential"] = "[passive_handler.Get("God") ? "?" : Potential]"
	D["pronouns"] = "[subjectpronoun()] / [objectpronoun()]"
	var/mx = max(GetStr(), GetEnd(), GetSpd(), GetFor(), GetOff(), GetDef(), 0.0001)
	D["fstr"] = GetStr() / mx; D["fend"] = GetEnd() / mx; D["fspd"] = GetSpd() / mx
	D["ffor"] = GetFor() / mx; D["foff"] = GetOff() / mx; D["fdef"] = GetDef() / mx
	var/list/parts = list()
	if(race && race.name) parts += race.name
	if(Secret)
		parts += secretDatum ? "[Secret] Tier [secretDatum.currentTier]" : "[Secret]"
	if(Saga) parts += "[Saga] Tier [SagaLevel]"
	D["identity"] = jointext(parts, " - ")
	D["rp"] = "[round(RPPSpendable)]"
	D["rpused"] = "[round(RPPSpent)]"
	return D

mob/proc/GetMenuBuffs()
	var/list/out = list()
	if(ActiveBuff) out += ActiveBuff
	if(SpecialBuff) out += SpecialBuff
	if(StanceBuff) out += StanceBuff
	if(StyleBuff) out += StyleBuff
	if(SlotlessBuffs)
		for(var/sb in SlotlessBuffs)
			var/obj/Skills/b = SlotlessBuffs[sb]
			if(b) out += b
	return out

mob/proc/ChooseMenuPronouns()
	set waitfor = 0
	if(!client) return
	var/subj = input(src, "Subject pronoun (He/She/They/It):", "Pronouns", subjectpronoun()) as null|anything in list("He", "She", "They", "It")
	if(!subj) return
	var/objp = input(src, "Object pronoun (Him/Her/Them/It):", "Pronouns", objectpronoun()) as null|anything in list("Him", "Her", "Them", "It")
	if(!objp) return
	information.pronouns = list(subj, objp)
	client.UpdateCharacterMenu()
	src << "Pronouns set to [subj] / [objp]."
