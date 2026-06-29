// Menu HUD. CollectMenuVerbs() removes Other/Utility verbs from the verbs list
#define MHUD_LAYER (FLY_LAYER+3)
#define MHUD_PRESS_STEP 1
#define MHUD_PAGE1_ROWS 5        // page 1 reserves the bottom for the Audio switch + CHAT toggles
#define MHUD_FULL_ROWS 8         // later pages have no fixed footer, so they fill the panel
#define MHUD_PAGE1_SIZE (MHUD_PAGE1_ROWS * 2)
#define MHUD_FULL_SIZE (MHUD_FULL_ROWS * 2)
#define MHUD_PANEL_W 336
#define MHUD_PANEL_H 256
#define MHUD_COL1_X -140
#define MHUD_COL2_X 22
// monogram's native grid is 16px = 12pt, other sizes degrade pixel fonts
#define MHUD_FONT "font-family:'monogram'; font-size:12pt"

// referencing the font here bundles it into the rsc for maptext
/var/MHUD_FONT_RESOURCE = 'HUD/monogram.ttf'

// verbs kept out of the Options menu. The verbs stay typeable
/var/list/MENU_VERB_EXCLUDE = list("OOC", "Say", "Emote", "Think", "Whisper", \
	"Check AI Kills", "Clear Skill Shortcut", "Ping", "Set Skill Shortcuts", "Toggle Channels", "ViewSelfLogs")

// stripped from the mob entirely, handled by the Character menu or other UI now
/var/list/MENU_VERB_REMOVE = list("Change Pronouns", "Character Sheet", "Enable Old Zanzoken", \
	"View Current Passives", "Toggle Pronouns", "Skill Descriptions", "Set Catchline", "Hide Information")

mob/var/tmp/list/hud_menu_verbs
mob/var/tmp/list/hud_customize_verbs

/datum/__verbmeta_compile_helper/var/hidden

client/Click(atom/A, location, control, params)
	if(params && findtext(params, "right=1"))
		if(istype(A, /atom/movable/shud))
			return ..()
		if(istype(A, /mob/Players))
			ShowPlayerPanel(A)
			return
		return
	return ..()

mob/proc/CollectMenuVerbs()
	hud_menu_verbs = list()
	hud_customize_verbs = list()
	CollectMenuVerbsFrom(verbs, TRUE)              // own verbs (allowed to strip MENU_VERB_REMOVE)
	if(client) CollectMenuVerbsFrom(client.verbs, FALSE)
	for(var/obj/o in contents)
		if(istype(o, /obj/Skills)) continue   // skills are hotbar/keybind-driven
		CollectMenuVerbsFrom(o.verbs, FALSE)

mob/proc/CollectMenuVerbsFrom(list/vlist, can_remove)
	if(!vlist) return
	var/list/toremove = list()   // strip after the loop
	for(var/p in vlist)
		if(!p) continue
		if(p:category != "Other" && p:category != "Utility") continue
		var/pn = "[p:name]"
		if(can_remove && (pn in MENU_VERB_REMOVE))
			toremove += p
			continue
		if(pn in MENU_VERB_EXCLUDE) continue
		// these go to the Character menu's Customization tab instead of Options
		var/is_cust = (pn == "Hair" || pn == "Clothes" || pn == "Reset Overlays" || pn == "Reset Appearance" || findtext(pn, "Customize"))
		var/list/target = is_cust ? hud_customize_verbs : hud_menu_verbs
		if(p in target) continue   // guard against dupes
		var/inserted = FALSE
		for(var/i = 1 to target.len)
			var/q = target[i]
			if(sorttext("[p:name]", "[q:name]") == 1)
				target.Insert(i, p)
				inserted = TRUE
				break
		if(!inserted)
			target += p
	for(var/v in toremove)
		vlist -= v

// shared top-bar button (gear=Options, backpack=Inventory), glyph and id set
// per instance
/atom/movable/shud/menubtn
	icon = 'HUD/ui_slot_available.png'
	mouse_opacity = 1
	layer = MHUD_LAYER
	var/atom/movable/shud/orbpart/glyph
	var/btn_id = "options"
	var/atom/movable/shud/menulabel/label
	New(glyph_icon = 'HUD/ui_icon_gear.png')
		..()
		glyph = new
		glyph.icon = glyph_icon
		glyph.pixel_x = 8
		glyph.pixel_y = 8
		// above the button face at rest, drops below the translucent Unavailable
		// face when the panel opens so it dims with the button
		glyph.layer = MHUD_LAYER + 0.01
		vis_contents += glyph
	Del()
		if(glyph)
			vis_contents -= glyph
			del glyph
		if(label)
			vis_contents -= label
			del label
		..()
	proc/SetGlyphDimmed(dimmed)
		if(glyph)
			glyph.layer = MHUD_LAYER + (dimmed ? -0.01 : 0.01)
	MouseEntered(location, control, params)
		usr?.client?.BtnHover(src, TRUE)
	MouseExited(location, control, params)
		usr?.client?.BtnHover(src, FALSE)
	Click()
		switch(btn_id)
			if("options")
				usr?.client?.ToggleOptionsMenu()
			if("inventory")
				usr?.client?.ToggleInventory()
			if("character")
				usr?.client?.ToggleCharacterMenu()
			if("skills")
				usr?.client?.ToggleSkillMenu()
			if("tech")
				usr?.client?.ToggleTechMenu()


/atom/movable/shud/menulabel
	layer = MHUD_LAYER + 0.1
	alpha = 0
	maptext_width = 64
	maptext_height = 20
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	proc/SetText(t)
		maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[t]</span></center>"

/atom/movable/shud/menupanel
	icon = 'HUD/ui_panel_options.png'
	layer = MHUD_LAYER + 0.2
	mouse_opacity = 2 // block clicks from reaching the map under the menu

/atom/movable/shud/menupanel/draggable
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.PanelDragStart(src, params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr) usr.client.PanelDragMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.PanelDragEnd()

/atom/movable/shud/menutext
	layer = MHUD_LAYER + 0.4
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

// chrome button (cross/arrows), plays a large > medium >small press animation
// and only runs its action once the press has fully played
/atom/movable/shud/pressbtn
	mouse_opacity = 1
	var/action
	var/widget_kind = "cross" // "cross" | "arrow_left" | "arrow_right"
	var/tmp/pressing = FALSE
	proc/DoAction()
		return
	proc/PressFrames()
		switch(widget_kind)
			if("arrow_left")
				return list('HUD/ui_arrow_left_1.png', 'HUD/ui_arrow_left_2.png', 'HUD/ui_arrow_left_3.png')
			if("arrow_right")
				return list('HUD/ui_arrow_right_1.png', 'HUD/ui_arrow_right_2.png', 'HUD/ui_arrow_right_3.png')
			else
				return list('HUD/ui_cross_1.png', 'HUD/ui_cross_2.png', 'HUD/ui_cross_3.png')
	Click()
		if(pressing) return
		pressing = TRUE
		var/list/f = PressFrames()
		icon = f[2]
		sleep(MHUD_PRESS_STEP)
		icon = f[3]
		sleep(MHUD_PRESS_STEP)
		var/closes = (action == "close")
		if(usr && usr.client)
			DoAction()
		if(!closes)
			icon = f[1]
			pressing = FALSE

/atom/movable/shud/menuwidget
	parent_type = /atom/movable/shud/pressbtn
	layer = MHUD_LAYER + 0.4
	DoAction()
		switch(action)
			if("close")
				usr?.client?.CloseMenu()
			if("prev")
				usr?.client?.MenuFlipPage(-1)
			if("next")
				usr?.client?.MenuFlipPage(1)

/atom/movable/shud/menuentry
	icon = 'HUD/ui_hit_entry.png' // transparent 150x22 hit box
	layer = MHUD_LAYER + 0.3
	mouse_opacity = 2
	maptext_width = 150
	maptext_height = 22
	maptext_y = 2
	var/vpath
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")
	proc/SetLabel(hovered)
		var/c = hovered ? "#8be9ff" : "#ffffff"
		maptext = "<span style=\"[MHUD_FONT]; color:[c]\">[vpath ? vpath:name : ""]</span>"
	MouseEntered(location, control, params)
		SetLabel(TRUE)
	MouseExited(location, control, params)
		SetLabel(FALSE)
	Click()
		if(!vpath || !usr || usr.client?.menu_open != "options") return
		// spawn so verbs that open input() prompts don't block the click chain
		spawn() call(usr, vpath)()

// chat channel toggle switch in the Options menu
/atom/movable/shud/menutoggle
	layer = MHUD_LAYER + 0.5
	mouse_opacity = 1
	var/pref
	MouseEntered(location, control, params)
		filters = filter(type="outline", size=1, color="#8be9ff")
	MouseExited(location, control, params)
		filters = null
	Click()
		if(usr) usr.client.ToggleOptPref(src)

client/proc/ToggleOptPref(atom/movable/shud/menutoggle/sw)
	set waitfor = 0
	if(!sw || !sw.pref || menu_open != "options") return
	togglePref(sw.pref)
	if(sw.pref == "soundOn") ApplyAudioPref()
	if(sw.pref == "zoom2x") ApplyZoomPref()
	AnimateOptToggle(sw, getPref(sw.pref))

// reuses the hat-toggle sprite set, frames 1>5
client/proc/AnimateOptToggle(atom/movable/sw, on)
	set waitfor = 0
	var/list/frames = on ? HAT_TGL_ON : HAT_TGL_OFF
	for(var/f = 1 to frames.len)
		if(!sw) return
		sw.icon = frames[f]
		sleep(0.8)

client
	var/tmp
		menu_open = null // menu id string or null, one menu at a time
		menu_page = 1
		list/menu_objs
		list/menu_entry_objs
		atom/movable/shud/menubtn/btn_options
		atom/movable/shud/menulabel/btn_options_label
		atom/movable/shud/menutext/menu_pagetext
		// draggable-panel state
		pan_active = null
		pan_dragged = FALSE
		pan_drag_mx = 0
		pan_drag_my = 0
		pan_drag_ox = 0
		pan_drag_oy = 0
		pan_bminx = 0
		pan_bmaxx = 0
		pan_bminy = 0
		pan_bmaxy = 0
		opt_pan_x = 0
		opt_pan_y = 0
		inv_pan_x = 0
		inv_pan_y = 0
		sk_pan_x = 0
		sk_pan_y = 0
		desc_pan_x = 0
		desc_pan_y = 0

// called from InitSkillHUD, button lives in shud_parts so the skill HUD owns it
client/proc/InitMenuButton()
	btn_options = new('HUD/ui_icon_gear.png')
	btn_options.btn_id = "options"
	btn_options.screen_loc = "EAST:-4,NORTH:-104"   // below the target card's reserved top-right spot
	shud_parts += btn_options
	btn_options_label = new
	btn_options_label.maptext_width = 48
	btn_options_label.SetText("Options")
	btn_options_label.pixel_x = -54 // -(48 block + 6 gap)
	btn_options_label.pixel_y = 8
	btn_options.label = btn_options_label
	btn_options.vis_contents += btn_options_label

// called from ClearSkillHUD, the button objects are deleted with shud_parts
client/proc/ResetMenuHUD()
	CloseMenu()
	btn_options = null
	btn_options_label = null

// hover highlight, dims while that button's own panel is open
client/proc/BtnHover(atom/movable/shud/menubtn/b, over)
	if(!b) return
	var/active = (b.btn_id == "options" && menu_open == "options") || (b.btn_id == "inventory" && inv_open) || (b.btn_id == "character" && cmenu_open) || (b.btn_id == "skills" && skmenu_open) || (b.btn_id == "tech" && tmenu_open)
	if(active)
		b.icon = 'HUD/ui_slot_unavailable.png'
		if(b.label) b.label.alpha = 0
		return
	b.icon = over ? 'HUD/ui_slot_selected.png' : 'HUD/ui_slot_available.png'
	if(b.label) b.label.alpha = over ? 255 : 0

client/proc/ToggleOptionsMenu()
	if(menu_open == "options")
		CloseMenu()
	else if(!menu_open)
		OpenOptionsMenu()

client/proc/CloseMenu()
	menu_open = null
	if(menu_entry_objs)
		while(menu_entry_objs.len)
			var/atom/movable/o = menu_entry_objs[menu_entry_objs.len]
			menu_entry_objs.len--
			screen -= o
			del o
		menu_entry_objs = null
	if(menu_objs)
		while(menu_objs.len)
			var/atom/movable/o = menu_objs[menu_objs.len]
			menu_objs.len--
			screen -= o
			del o
		menu_objs = null
	menu_pagetext = null
	if(btn_options)
		btn_options.icon = 'HUD/ui_slot_available.png'
		btn_options.SetGlyphDimmed(FALSE)

client/proc/KineticEntrance(list/objs, time = 3)
	if(!objs || !objs.len) return
	var/list/snap = objs.Copy()
	var/list/atgt = list()
	for(var/atom/movable/o in snap)
		atgt[o] = o.alpha
		o.alpha = 0
	spawn(1)
		for(var/atom/movable/o in snap)
			if(o) animate(o, alpha = atgt[o], time = time, easing = SINE_EASING)

client/proc/PanAxis(part, d)
	var/list/p = splittext(part, ":")
	var/apx
	var/pix
	if(p.len >= 2)
		var/base = text2num(p[1])
		if(isnull(base))
			return "[p[1]]:[text2num(p[2]) + d]"          
		apx = (base - 1) * 32 + text2num(p[2]) + d        
		pix = ((apx % 32) + 32) % 32
		return "[(apx - pix) / 32 + 1]:[pix]"
	var/num = text2num(part)
	if(isnull(num)) return "[part]:[d]"                   
	apx = (num - 1) * 32 + d
	pix = ((apx % 32) + 32) % 32
	return "[(apx - pix) / 32 + 1]:[pix]"

client/proc/PanLoc(sl, dpx, dpy)
	if(!sl) return sl
	var/list/cm = splittext(sl, ",")
	if(cm.len < 2) return sl
	return "[PanAxis(cm[1], dpx)],[PanAxis(cm[2], dpy)]"

client/proc/PanShift(list/objs, dpx, dpy)
	if((!dpx && !dpy) || !objs) return
	for(var/atom/movable/o in objs)
		if(o.screen_loc) o.screen_loc = PanLoc(o.screen_loc, dpx, dpy)

client/proc/PanBounds(menu, atom/movable/panel)
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/vwpx = vw * 32
	var/vhpx = vh * 32
	var/W = 32
	var/H = 32
	var/bx = 0   // panel default bottom-left, absolute px
	var/by = 0
	switch(menu)
		if("options", "skills")             // centered panel, 336x256
			W = MHUD_PANEL_W
			H = MHUD_PANEL_H
			bx = vwpx / 2 - W / 2
			by = vhpx / 2 - H / 2
		if("inventory")                     // X tile-anchored at InvXLoc(-144)=6, Y at CENTER:-160
			if(panel && panel.icon)
				var/icon/ic = icon(panel.icon)
				W = ic.Width()
				H = ic.Height()
			bx = 6
			by = vhpx / 2 - 160
		if("invdesc")                       // item-desc popup: X at InvXLoc(152)=302, Y at CENTER:-150
			if(panel && panel.icon)
				var/icon/ic = icon(panel.icon)
				W = ic.Width()
				H = ic.Height()
			bx = 302
			by = vhpx / 2 - 150
	var/M = 20
	var/minx = -bx + M
	if(minx > 0) minx = 0
	var/maxx = vwpx - W - bx - M
	if(maxx < 0) maxx = 0
	var/miny = -by + M
	if(miny > 0) miny = 0
	var/maxy = vhpx - H - by - M
	if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/PanelDragStart(atom/movable/panel, params)
	pan_active = null
	if(istype(panel, /atom/movable/shud/invdescpanel)) pan_active = "invdesc"   // the item-desc popup, by type
	else if(menu_open == "options") pan_active = "options"
	else if(inv_open) pan_active = "inventory"
	else if(skmenu_open) pan_active = "skills"
	if(!pan_active) return
	pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m)
		pan_active = null
		return
	pan_drag_mx = m[1]
	pan_drag_my = m[2]
	switch(pan_active)
		if("options")
			pan_drag_ox = opt_pan_x
			pan_drag_oy = opt_pan_y
		if("inventory")
			pan_drag_ox = inv_pan_x
			pan_drag_oy = inv_pan_y
		if("skills")
			pan_drag_ox = sk_pan_x
			pan_drag_oy = sk_pan_y
		if("invdesc")
			pan_drag_ox = desc_pan_x
			pan_drag_oy = desc_pan_y
	var/list/b = PanBounds(pan_active, panel)
	pan_bminx = b[1]
	pan_bmaxx = b[2]
	pan_bminy = b[3]
	pan_bmaxy = b[4]

client/proc/PanelDragMove(params)
	if(!pan_active) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/wantx = clamp(pan_drag_ox + (m[1] - pan_drag_mx), pan_bminx, pan_bmaxx)
	var/wanty = clamp(pan_drag_oy + (m[2] - pan_drag_my), pan_bminy, pan_bmaxy)
	var/cx = 0
	var/cy = 0
	switch(pan_active)
		if("options")
			cx = opt_pan_x
			cy = opt_pan_y
		if("inventory")
			cx = inv_pan_x
			cy = inv_pan_y
		if("skills")
			cx = sk_pan_x
			cy = sk_pan_y
		if("invdesc")
			cx = desc_pan_x
			cy = desc_pan_y
	var/dx = wantx - cx
	var/dy = wanty - cy
	if(!dx && !dy) return
	pan_dragged = TRUE
	switch(pan_active)
		if("options")
			opt_pan_x = wantx
			opt_pan_y = wanty
			PanShift(menu_objs, dx, dy)
			PanShift(menu_entry_objs, dx, dy)
		if("inventory")
			inv_pan_x = wantx
			inv_pan_y = wanty
			PanShift(inv_objs, dx, dy)
			PanShift(inv_item_objs, dx, dy)
		if("skills")
			sk_pan_x = wantx
			sk_pan_y = wanty
			PanShift(skmenu_objs, dx, dy)        // skmenu_objs already contains the tabs
			PanShift(skmenu_icon_objs, dx, dy)
		if("invdesc")
			desc_pan_x = wantx
			desc_pan_y = wanty
			PanShift(inv_desc_objs, dx, dy)

client/proc/PanelDragEnd()
	if(!pan_active) return
	if(pan_dragged)
		switch(pan_active)
			if("options")
				setPref("optPanX", opt_pan_x)
				setPref("optPanY", opt_pan_y)
			if("inventory")
				setPref("invPanX", inv_pan_x)
				setPref("invPanY", inv_pan_y)
			if("skills")
				setPref("skPanX", sk_pan_x)
				setPref("skPanY", sk_pan_y)
			if("invdesc")
				setPref("descPanX", desc_pan_x)
				setPref("descPanY", desc_pan_y)
	pan_active = null
	pan_dragged = FALSE

client/proc/OpenOptionsMenu()
	if(menu_open || !mob) return
	mob.CollectMenuVerbs()   // refresh so Other/Utility verbs granted since login
	if(!mob.hud_menu_verbs || !mob.hud_menu_verbs.len) return
	CloseInventory() // never both big panels open at once
	CloseCharacterMenu()
	CloseSkillMenu()
	CloseTechMenu()
	menu_open = "options"
	menu_page = 1
	btn_options.icon = 'HUD/ui_slot_unavailable.png'
	btn_options.SetGlyphDimmed(TRUE)
	btn_options_label.alpha = 0
	menu_objs = list()
	menu_entry_objs = list()
	// restore saved drag position, clamped to the current view
	opt_pan_x = getPref("optPanX"); if(isnull(opt_pan_x)) opt_pan_x = 0
	opt_pan_y = getPref("optPanY"); if(isnull(opt_pan_y)) opt_pan_y = 0
	var/list/ob = PanBounds("options", null)
	opt_pan_x = clamp(opt_pan_x, ob[1], ob[2])
	opt_pan_y = clamp(opt_pan_y, ob[3], ob[4])

	var/atom/movable/shud/menupanel/draggable/P = new
	P.screen_loc = "CENTER:[-MHUD_PANEL_W/2],CENTER:[-MHUD_PANEL_H/2]"
	menu_objs += P

	var/atom/movable/shud/menutext/title = new
	title.maptext_width = MHUD_PANEL_W
	title.maptext_height = 20
	title.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">OPTIONS</span></center>"
	title.screen_loc = "CENTER:[-MHUD_PANEL_W/2],CENTER:100"
	menu_objs += title

	var/atom/movable/shud/menuwidget/X = new
	X.icon = 'HUD/ui_cross.png'
	X.action = "close"
	X.widget_kind = "cross"
	X.screen_loc = "CENTER:132,CENTER:96"
	menu_objs += X

	var/atom/movable/shud/menuwidget/AL = new
	AL.icon = 'HUD/ui_arrow_left.png'
	AL.action = "prev"
	AL.widget_kind = "arrow_left"
	AL.screen_loc = "CENTER:-64,CENTER:-122"
	menu_objs += AL

	var/atom/movable/shud/menuwidget/AR = new
	AR.icon = 'HUD/ui_arrow_right.png'
	AR.action = "next"
	AR.widget_kind = "arrow_right"
	AR.screen_loc = "CENTER:32,CENTER:-122"
	menu_objs += AR

	menu_pagetext = new
	menu_pagetext.maptext_width = 60
	menu_pagetext.maptext_height = 20
	menu_pagetext.screen_loc = "CENTER:-30,CENTER:-116"
	menu_objs += menu_pagetext

	// Audio switch + CHAT toggles are built in BuildMenuPage on page 1 only

	for(var/atom/movable/o in menu_objs)
		screen += o
	PanShift(menu_objs, opt_pan_x, opt_pan_y)
	KineticEntrance(menu_objs)
	BuildMenuPage(TRUE)

client/proc/MenuFlipPage(dir)
	if(menu_open != "options") return
	menu_page += dir
	BuildMenuPage()

client/proc/BuildMenuPage(fade = FALSE)
	if(!mob || menu_open != "options") return
	while(menu_entry_objs.len)
		var/atom/movable/o = menu_entry_objs[menu_entry_objs.len]
		menu_entry_objs.len--
		screen -= o
		del o
	var/list/L = mob.hud_menu_verbs
	// page 1 holds fewer verbs (bottom reserved for the Audio switch + CHAT), later pages fill the whole panel
	var/extra = max(0, L.len - MHUD_PAGE1_SIZE)
	var/pages = 1 - round(-extra / MHUD_FULL_SIZE)   // 1 + ceil(extra / full)
	menu_page = min(max(menu_page, 1), pages)
	menu_pagetext.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[menu_page]/[pages]</span></center>"
	var/rows = (menu_page == 1) ? MHUD_PAGE1_ROWS : MHUD_FULL_ROWS
	var/page_size = rows * 2
	var/start = (menu_page == 1) ? 0 : (MHUD_PAGE1_SIZE + (menu_page - 2) * MHUD_FULL_SIZE)
	for(var/k = 1 to page_size)
		var/idx = start + k
		if(idx > L.len) break
		var/atom/movable/shud/menuentry/E = new
		E.vpath = L[idx]
		E.SetLabel(FALSE)
		var/col = round((k - 1) / rows)
		var/row = (k - 1) % rows
		E.screen_loc = "CENTER:[col ? MHUD_COL2_X : MHUD_COL1_X],CENTER:[64 - 22 * row]"
		menu_entry_objs += E
		screen += E
	if(menu_page == 1)
		BuildOptionsExtras()
	PanShift(menu_entry_objs, opt_pan_x, opt_pan_y)
	if(fade)
		KineticEntrance(menu_entry_objs)

// audio switch + chat toggles, page 1 only, fixed below the verb grid. kept in menu_entry_objs so a page flip clears them
client/proc/BuildOptionsExtras()
	var/atom/movable/shud/menutext/al = new
	al.maptext_width = 110
	al.maptext_height = 20
	al.maptext = "<span style=\"[MHUD_FONT]; color:#ffffff\">Audio</span>"
	al.screen_loc = "CENTER:[MHUD_COL1_X],CENTER:-46"
	menu_entry_objs += al
	screen += al
	var/atom/movable/shud/menutoggle/asw = new
	asw.pref = "soundOn"
	asw.icon = getPref("soundOn") ? HAT_TGL_ON[5] : HAT_TGL_OFF[5]
	asw.screen_loc = "CENTER:[MHUD_COL1_X + 88],CENTER:-44"
	menu_entry_objs += asw
	screen += asw
	var/atom/movable/shud/menutext/zl = new
	zl.maptext_width = 110
	zl.maptext_height = 20
	zl.maptext = "<span style=\"[MHUD_FONT]; color:#ffffff\">Zoom 2x</span>"
	zl.screen_loc = "CENTER:[MHUD_COL2_X],CENTER:-46"
	menu_entry_objs += zl
	screen += zl
	var/atom/movable/shud/menutoggle/zsw = new
	zsw.pref = "zoom2x"
	zsw.icon = getPref("zoom2x") ? HAT_TGL_ON[5] : HAT_TGL_OFF[5]
	zsw.screen_loc = "CENTER:[MHUD_COL2_X + 88],CENTER:-44"
	menu_entry_objs += zsw
	screen += zsw
	// chat toggles continue the same 22px grid (Audio is row 5), so the bottom row lands at -90 like a full page
	var/list/togs = list("OOC" = "ShowOOC", "All Tab OOC" = "AllTabOOC", "IC Tab LOOC" = "LOOCinIC", "All Tab LOOC" = "LOOCinAll")
	var/ti = 0
	for(var/lbl in togs)
		var/tcol = ti % 2
		var/trow = (ti - tcol) / 2
		var/tx = tcol ? MHUD_COL2_X : MHUD_COL1_X
		var/ty = -68 - 22 * trow
		var/atom/movable/shud/menutext/tl = new
		tl.maptext_width = 110
		tl.maptext_height = 20
		tl.maptext = "<span style=\"[MHUD_FONT]; color:#ffffff\">[lbl]</span>"
		tl.screen_loc = "CENTER:[tx],CENTER:[ty]"
		menu_entry_objs += tl
		screen += tl
		var/atom/movable/shud/menutoggle/sw = new
		sw.pref = togs[lbl]
		sw.icon = getPref(togs[lbl]) ? HAT_TGL_ON[5] : HAT_TGL_OFF[5]
		sw.screen_loc = "CENTER:[tx + 88],CENTER:[ty + 2]"
		menu_entry_objs += sw
		screen += sw
		ti++
