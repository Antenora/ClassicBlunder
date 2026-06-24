// Menu HUD. CollectMenuVerbs() removes Other/Utility verbs from the verbs list
#define MHUD_LAYER (FLY_LAYER+3)
#define MHUD_PRESS_STEP 1
#define MHUD_PAGE_SIZE 12        // 2 columns x 6 rows
#define MHUD_PANEL_W 336
#define MHUD_PANEL_H 256
#define MHUD_COL1_X -140
#define MHUD_COL2_X 22
// monogram's native grid is 16px = 12pt, other sizes degrade pixel fonts
#define MHUD_FONT "font-family:'monogram'; font-size:12pt"

// referencing the font here bundles it into the rsc for maptext
/var/MHUD_FONT_RESOURCE = 'HUD/monogram.ttf'

// verbs that stay typeable even though their category matches, players type
// these with arguments
/var/list/MENU_VERB_EXCLUDE = list("OOC", "Say", "Emote", "Think", "Whisper")

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
	var/list/toremove = list()   // strip after the loop, don't mutate verbs mid-iterate
	for(var/p in verbs)
		if(!p) continue
		if(p:hidden) continue
		if(p:category != "Other" && p:category != "Utility") continue
		var/pn = "[p:name]"
		if(pn in MENU_VERB_REMOVE)
			toremove += p
			continue
		if(pn in MENU_VERB_EXCLUDE) continue
		// these go to the Character menu's Customization tab instead of Options
		var/is_cust = (pn == "Hair" || pn == "Clothes" || pn == "Reset Overlays" || pn == "Reset Appearance" || findtext(pn, "Customize"))
		var/list/target = is_cust ? hud_customize_verbs : hud_menu_verbs
		var/inserted = FALSE
		for(var/i = 1 to target.len)
			var/q = target[i]
			if(sorttext(p:name, q:name) == 1)
				target.Insert(i, p)
				inserted = TRUE
				break
		if(!inserted)
			target += p
	for(var/v in toremove)
		verbs -= v
	for(var/v in hud_menu_verbs)
		verbs -= v
	for(var/v in hud_customize_verbs)
		verbs -= v

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
	var/active = (b.btn_id == "options" && menu_open == "options") || (b.btn_id == "inventory" && inv_open) || (b.btn_id == "character" && cmenu_open) || (b.btn_id == "skills" && skmenu_open)
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

client/proc/OpenOptionsMenu()
	if(menu_open || !mob) return
	if(!mob.hud_menu_verbs || !mob.hud_menu_verbs.len) return
	CloseInventory() // never both big panels open at once
	CloseCharacterMenu()
	CloseSkillMenu()
	menu_open = "options"
	menu_page = 1
	btn_options.icon = 'HUD/ui_slot_unavailable.png'
	btn_options.SetGlyphDimmed(TRUE)
	btn_options_label.alpha = 0
	menu_objs = list()
	menu_entry_objs = list()

	var/atom/movable/shud/menupanel/P = new
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

	// chat channel toggles (replaces the Toggle Channels verb), fixed at the panel bottom on every page
	var/atom/movable/shud/menutext/chh = new
	chh.maptext_width = MHUD_PANEL_W
	chh.maptext_height = 18
	chh.maptext = "<center><span style=\"[MHUD_FONT]; color:#8be9ff\">CHAT</span></center>"
	chh.screen_loc = "CENTER:[-MHUD_PANEL_W/2],CENTER:-62"   // clears the last verb row
	menu_objs += chh
	var/list/togs = list("OOC" = "ShowOOC", "All Tab OOC" = "AllTabOOC", "IC Tab LOOC" = "LOOCinIC", "All Tab LOOC" = "LOOCinAll")
	var/ti = 0
	for(var/lbl in togs)
		var/tcol = ti % 2
		var/trow = (ti - tcol) / 2
		var/tx = tcol ? MHUD_COL2_X : MHUD_COL1_X
		var/ty = -75 - 22 * trow   // leaves room above for the CHAT header
		var/atom/movable/shud/menutext/tl = new
		tl.maptext_width = 110
		tl.maptext_height = 20
		tl.maptext = "<span style=\"[MHUD_FONT]; color:#ffffff\">[lbl]</span>"
		tl.screen_loc = "CENTER:[tx],CENTER:[ty]"
		menu_objs += tl
		var/atom/movable/shud/menutoggle/sw = new
		sw.pref = togs[lbl]
		sw.icon = getPref(togs[lbl]) ? HAT_TGL_ON[5] : HAT_TGL_OFF[5]
		sw.screen_loc = "CENTER:[tx + 88],CENTER:[ty + 3]"   // pulled left so the col-2 switch clears the edge grid
		menu_objs += sw
		ti++

	for(var/atom/movable/o in menu_objs)
		screen += o
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
	var/pages = max(1, -round(-L.len / MHUD_PAGE_SIZE)) // ceil division
	menu_page = min(max(menu_page, 1), pages)
	menu_pagetext.maptext = "<center><span style=\"[MHUD_FONT]; color:#ffffff\">[menu_page]/[pages]</span></center>"
	var/start = (menu_page - 1) * MHUD_PAGE_SIZE
	for(var/k = 1 to MHUD_PAGE_SIZE)
		var/idx = start + k
		if(idx > L.len) break
		var/atom/movable/shud/menuentry/E = new
		E.vpath = L[idx]
		E.SetLabel(FALSE)
		var/col = round((k - 1) / 6)
		var/row = (k - 1) % 6
		E.screen_loc = "CENTER:[col ? MHUD_COL2_X : MHUD_COL1_X],CENTER:[64 - 22 * row]"
		menu_entry_objs += E
		screen += E
	if(fade)
		KineticEntrance(menu_entry_objs)
