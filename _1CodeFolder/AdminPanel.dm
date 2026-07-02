#define APANEL_W 160
#define APANEL_H 316
#define APANEL_GAP 8                          // gap between the admin strip and the player panel
#define APANEL_LAYER (FLY_LAYER + 3)
#define APANEL_FONT "font-family:'monogram'; font-size:12pt" 
#define ABTN_W 132
#define ABTN_H 24                             // native pbtn height
#define ABTN_X 14                             // (160-132)/2, centers the button in the strip
#define ABTN_RH 28                            // row pitch
#define ADMIN_VISIBLE 8
#define ADMIN_ROWS 9                          // visible + 1 buffer row for smooth scroll
#define ADMIN_BAND_H (ADMIN_VISIBLE * ABTN_RH)
#define ADMIN_Y0 252                          // panel-local py (from bottom) of the top row's bottom edge (AH-40-24)
#define ADMIN_FILL "#213050"                  // panel interior color, cover strips clip scrolling rows

/atom/movable/shud/adminpanelbg
	layer = APANEL_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.PPanelStart(params)   // drags the player panel + admin strip together
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr) usr.client.PPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.PPanelEnd()
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr) usr.client.HidePlayerPanel()   // right-click either panel closes both

/atom/movable/shud/adminlbl
	mouse_opacity = 0                          // clicks fall through to the button
	New()
		..()
		filters = filter(type="outline", size=1, color="#000000")

/atom/movable/shud/adminbtn
	layer = APANEL_LAYER + 0.1
	mouse_opacity = 2
	var/action
	var/atom/movable/shud/adminlbl/lbl
	New()
		..()
		lbl = new
		lbl.layer = APANEL_LAYER + 0.15
		lbl.maptext_width = ABTN_W
		lbl.maptext_height = ABTN_H
		lbl.maptext_y = 6                     
		vis_contents += lbl
	Del()
		if(lbl)
			vis_contents -= lbl
			del lbl
		..()
	Click(location, control, params)
		if(usr && action) usr.client.AdminPanelAction(action)

client
	var/tmp
		list/admin_panel_objs
		list/admin_btn_objs                    // the ADMIN_ROWS windowed button objects
		list/admin_cmd_list                    // ordered list(action, label)
		mob/admin_panel_target
		admin_panel_open = FALSE
		admin_px = 0
		admin_target_px = 0
		admin_anim = FALSE
		ap_tile = 1                            // horizontal anchor
		ap_xpix = 0

/proc/AdminCommandList()
	return list(
		list("aobserve",  "AObserve"),
		list("heal",      "Admin Heal"),
		list("punish",    "Punish"),
		list("pm",        "Admin PM"),
		list("mute",      "Mute"),
		list("boot",      "Boot"),
		list("ban",       "Ban"),
		list("spawn",     "Send to Spawn"),
		list("summon",    "Summon"),
		list("teleto",    "Teleport To"),
		list("xyz",       "XYZTeleport"),
		list("log",       "Check Log"),
		list("givemake",  "Give/Make"),
		list("assess",    "Assess"),
		list("rename",    "Admin Rename"),
		list("edit",      "Edit"),
		list("editph",    "Edit Passives"),   // EditPassiveHandler is abbreviated to fit the thin button at 12pt
		list("viewp",     "View Passives"),
		list("dodmg",     "Do Damage")
	)

/proc/AdminCoverIcon(w, h)
	var/icon/I = icon('BLANK.dmi')
	I.Scale(w, h)
	I.DrawBox(ADMIN_FILL, 1, 1, w, h)
	return I

/proc/AdminBtnIcon(w)
	var/cap = 8
	var/icon/out = icon('HUD/pbtn.png')        // 80 x 24, opaque
	out.Scale(w, 24)
	var/icon/pb = icon('HUD/pbtn.png')
	var/icon/left = icon(pb);  left.Crop(1, 1, cap, 24)
	var/icon/right = icon(pb); right.Crop(80 - cap + 1, 1, 80, 24)
	out.Blend(left, ICON_OVERLAY, 1, 1)
	out.Blend(right, ICON_OVERLAY, w - cap + 1, 1)
	return out

client/proc/ComputeAdminPanelAnchor()
	// anchor off the player panel's already-computed left edge (pp_tile/pp_xpix are plain
	// vars, so this doesn't depend on PlayerPanel.dm's #defines / include order)
	var/pleft = (pp_tile - 1) * 32 + pp_xpix           // player panel's left edge in px
	var/aleft = pleft - APANEL_GAP - APANEL_W          // admin strip sits just left of it
	if(aleft < 0) aleft = 0
	ap_tile = (aleft - aleft % 32) / 32 + 1
	ap_xpix = aleft % 32
	return 1

client/proc/APLoc(px, py)
	// shares the player panel's drag offset so both move as one unit
	return "[ap_tile]:[ap_xpix + px + pp_pan_x],[pp_row]:[pp_poff + py + pp_pan_y]"

client/proc/HideAdminPanel()
	admin_panel_open = FALSE
	admin_panel_target = null
	admin_btn_objs = null
	admin_cmd_list = null
	if(admin_panel_objs)
		while(admin_panel_objs.len)
			var/atom/movable/o = admin_panel_objs[admin_panel_objs.len]
			admin_panel_objs.len--
			screen -= o
			del o
		admin_panel_objs = null

client/proc/ShowAdminPanel(mob/P)
	HideAdminPanel()
	if(!P || !mob || !mob.Admin) return
	if(!ComputeAdminPanelAnchor()) return
	admin_panel_objs = list()
	admin_btn_objs = list()
	admin_cmd_list = AdminCommandList()
	admin_panel_target = P
	admin_panel_open = TRUE
	admin_px = 0
	admin_target_px = 0

	var/atom/movable/shud/adminpanelbg/bg = new
	bg.icon = 'HUD/admin_panel.png'
	bg.screen_loc = APLoc(0, 0)
	admin_panel_objs += bg

	var/icon/btnicon = AdminBtnIcon(ABTN_W)
	for(var/k = 1 to ADMIN_ROWS)
		var/atom/movable/shud/adminbtn/b = new
		b.icon = btnicon
		admin_btn_objs += b
		admin_panel_objs += b

	// interior-colored cover strips clip rows that scroll past the band edges
	var/atom/movable/shud/tcov = new
	tcov.icon = AdminCoverIcon(136, 30)
	tcov.mouse_opacity = 0
	tcov.layer = APANEL_LAYER + 0.2
	tcov.screen_loc = APLoc(12, 276)
	admin_panel_objs += tcov
	var/atom/movable/shud/bcov = new
	bcov.icon = AdminCoverIcon(136, 30)
	bcov.mouse_opacity = 0
	bcov.layer = APANEL_LAYER + 0.2
	bcov.screen_loc = APLoc(12, 22)
	admin_panel_objs += bcov

	RefreshAdminBtns()
	for(var/atom/movable/o in admin_panel_objs)
		screen += o
	KineticEntrance(admin_panel_objs)

client/proc/RefreshAdminBtns()
	if(!admin_btn_objs || !admin_cmd_list) return
	var/total = admin_cmd_list.len
	var/maxpx = max(0, total * ABTN_RH - ADMIN_BAND_H)
	admin_px = clamp(admin_px, 0, maxpx)
	var/sub = admin_px % ABTN_RH
	var/first = (admin_px - sub) / ABTN_RH
	for(var/k = 1 to admin_btn_objs.len)
		var/atom/movable/shud/adminbtn/b = admin_btn_objs[k]
		b.screen_loc = APLoc(ABTN_X, ADMIN_Y0 - (k - 1) * ABTN_RH + sub)
		var/idx = first + k
		if(idx <= total)
			var/list/cmd = admin_cmd_list[idx]
			b.action = cmd[1]
			b.alpha = 255
			b.mouse_opacity = 2
			b.lbl.maptext = "<center><span style=\"[APANEL_FONT]; color:#ffffff\">[cmd[2]]</span></center>"
			b.lbl.alpha = 255
		else
			b.action = null
			b.alpha = 0
			b.mouse_opacity = 0
			b.lbl.maptext = ""
			b.lbl.alpha = 0

client/proc/AnimateAdminScroll()
	set waitfor = 0
	admin_anim = TRUE
	while(admin_panel_open && admin_btn_objs && admin_px != admin_target_px)
		var/diff = admin_target_px - admin_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1
		admin_px += stepp
		RefreshAdminBtns()
		sleep(world.tick_lag)
	admin_anim = FALSE

client/proc/AdminWheelScroll(delta_y)
	if(!admin_panel_open || !admin_cmd_list || !admin_cmd_list.len) return 0
	var/maxpx = max(0, admin_cmd_list.len * ABTN_RH - ADMIN_BAND_H)
	if(maxpx > 0)
		var/dir = (delta_y > 0) ? -1 : 1
		admin_target_px = clamp(admin_target_px + dir * ABTN_RH, 0, maxpx)
		if(!admin_anim) AnimateAdminScroll()
	return 1

client/proc/AdminInvoke(ident, mob/T)
	if(!mob) return
	if(!hascall(mob, ident))
		mob << "<font color=red>You don't have permission for that command (or it's unavailable).</font>"
		return
	spawn()
		if(T) call(mob, ident)(T)
		else  call(mob, ident)()

client/proc/AdminBoot(mob/T)
	if(!mob || mob.Admin < 2)
		mob << "<font color=red>You don't have permission to boot.</font>"
		return
	if(!T) return
	if(!T.client)
		mob << "[T] has no client to boot."
		return
	Log("Admin", "[ExtractInfo(mob)] booted [ExtractInfo(T)].")
	world << "<font color=#FFFF00>[T] has been booted"
	del(T.client)

client/proc/AdminPanelAction(action)
	if(!mob || !mob.Admin) return
	var/mob/T = admin_panel_target
	if(!T) return
	switch(action)
		if("aobserve") AdminInvoke("Observe_", T)
		if("heal")     AdminInvoke("AdminHeal", T)
		if("punish")   AdminInvoke("Punish", null)        
		if("pm")       AdminInvoke("AdminPM", T)
		if("mute")     AdminInvoke("AdminDoMute", T)
		if("boot")     AdminBoot(T)                        
		if("ban")      AdminInvoke("AdminDoBan", T)
		if("spawn")    AdminInvoke("SendToSpawnz", T)
		if("summon")   AdminInvoke("Summon", T)
		if("teleto")   AdminInvoke("Teleport", T)
		if("xyz")      AdminInvoke("XYZTeleport", T)
		if("log")      AdminInvoke("PlayerLog", T)
		if("givemake") AdminInvoke("Give_Make", T)
		if("assess")   AdminInvoke("AdminAssess", T)
		if("rename")   AdminInvoke("AdminRename", T)
		if("edit")     AdminInvoke("Edit", T)
		if("editph")   AdminInvoke("EditPassiveHandler", T)
		if("viewp")    AdminInvoke("ViewPassives", T)
		if("dodmg")    AdminInvoke("AdminDoDamage", T)
