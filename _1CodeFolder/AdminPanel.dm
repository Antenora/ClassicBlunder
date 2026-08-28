#define APANEL_W 176                          // widened 160->176 for the scrollbar gutter
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
#define ADMIN_TRACK_X 148                     // gutter right of the buttons
#define ADMIN_TRACK_PY 52                     // panel-local py of the track bottom = band bottom
#define ADMIN_TRACK_H 224                     // = ADMIN_BAND_H
#define ADMIN_THUMB_H 36

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

// routes the jump to the admin or atom strip's list
/atom/movable/shud/admintrack
	layer = APANEL_LAYER + 0.15
	mouse_opacity = 2
	var/kind = "admin"
	Click(location, control, params)
		if(usr) usr.client.AdminTrackTo(kind, params)
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.AdminTrackTo(kind, params)

/atom/movable/shud/adminthumb
	layer = APANEL_LAYER + 0.16
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	var/kind = "admin"
	MouseDrag(over, src_loc, over_loc, src_ctrl, over_ctrl, params)
		if(usr) usr.client.AdminTrackTo(kind, params)

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
		atom/movable/shud/adminthumb/admin_thumb

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
	admin_thumb = null
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

	var/atom/movable/shud/admintrack/tr = new
	tr.icon = 'HUD/scroll_track_224.png'
	tr.screen_loc = APLoc(ADMIN_TRACK_X, ADMIN_TRACK_PY)
	admin_panel_objs += tr
	admin_thumb = new
	admin_thumb.icon = 'HUD/scroll_thumb.png'
	admin_panel_objs += admin_thumb

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
	if(admin_thumb)
		if(maxpx <= 0)
			admin_thumb.alpha = 80
			admin_thumb.screen_loc = APLoc(ADMIN_TRACK_X + 1, ADMIN_TRACK_PY + ADMIN_TRACK_H - ADMIN_THUMB_H)
		else
			admin_thumb.alpha = 255
			var/off = round((admin_px / maxpx) * (ADMIN_TRACK_H - ADMIN_THUMB_H))
			admin_thumb.screen_loc = APLoc(ADMIN_TRACK_X + 1, ADMIN_TRACK_PY + ADMIN_TRACK_H - ADMIN_THUMB_H - off)

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

// track click/drag jumps the list to the cursor; kind picks which strip's state
client/proc/AdminTrackTo(kind, params)
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
	var/top_py = ADMIN_TRACK_PY + ADMIN_TRACK_H
	if(kind == "stack")
		if(!stack_panel_open || !stack_list) return
		var/maxpx = max(0, stack_list.len * ABTN_RH - ADMIN_BAND_H)
		if(maxpx <= 0) return
		var/local_py = (row - 1) * 32 + py - (atomp_row - 1) * 32 - atomp_poff - pp_pan_y
		var/frac = clamp((top_py - local_py) / ADMIN_TRACK_H, 0, 1)
		stackp_px = round(frac * maxpx)
		stackp_target_px = stackp_px
		RefreshStackBtns()
	else if(kind == "atom")
		if(!atom_panel_open || !atom_cmd_list) return
		var/maxpx = max(0, atom_cmd_list.len * ABTN_RH - ADMIN_BAND_H)
		if(maxpx <= 0) return
		var/local_py = (row - 1) * 32 + py - (atomp_row - 1) * 32 - atomp_poff - pp_pan_y
		var/frac = clamp((top_py - local_py) / ADMIN_TRACK_H, 0, 1)
		atomp_px = round(frac * maxpx)
		atomp_target_px = atomp_px           // cancel any running wheel glide
		RefreshAtomBtns()
	else
		if(!admin_panel_open || !admin_cmd_list) return
		var/maxpx = max(0, admin_cmd_list.len * ABTN_RH - ADMIN_BAND_H)
		if(maxpx <= 0) return
		var/local_py = (row - 1) * 32 + py - (pp_row - 1) * 32 - pp_poff - pp_pan_y
		var/frac = clamp((top_py - local_py) / ADMIN_TRACK_H, 0, 1)
		admin_px = round(frac * maxpx)
		admin_target_px = admin_px           // cancel any running wheel glide
		RefreshAdminBtns()

client/proc/AdminInvoke(ident, atom/T)
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

/atom/movable/shud/atompanelbg
	layer = APANEL_LAYER
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr) usr.client.ATPanelStart(params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr) usr.client.ATPanelMove(params)
	MouseUp(location, control, params)
		if(usr) usr.client.ATPanelEnd()
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr) usr.client.HideAtomPanel()

// adminbtn child so it inherits the label plumbing, only the dispatch differs
/atom/movable/shud/adminbtn/atombtn
	Click(location, control, params)
		if(usr && action) usr.client.AtomPanelAction(action)

client
	var/tmp
		list/atom_panel_objs
		list/atom_btn_objs
		list/atom_cmd_list
		atom/atom_panel_target
		atom_panel_open = FALSE
		atomp_px = 0
		atomp_target_px = 0
		atomp_anim = FALSE
		atomp_tile = 1
		atomp_xpix = 0
		atomp_row = 1
		atomp_poff = 0
		atom/movable/shud/adminthumb/atomp_thumb

// per-target list. hascall gates by what the mob actually has
client/proc/AtomCommandList(atom/A)
	var/list/L = list()
	if(mob.Admin)
		if(hascall(mob, "Edit"))        L += list(list("a_edit",   "Edit"))
		if(hascall(mob, "AdminRename")) L += list(list("a_rename", "Rename"))
		if(hascall(mob, "Delete"))      L += list(list("a_delete", "Delete"))
	if(mob.Mapper)
		if(hascall(mob, "Mapper_Edit")) L += list(list("m_edit", "Mapper Edit"))
		if(hascall(mob, "Mapper_Fade")) L += list(list("m_fade", "Mapper Fade"))
		// Mapper_Delete only touches custom build objects
		if((istype(A, /obj/Turfs) || istype(A, /obj/KatieObj)) && hascall(mob, "Mapper_Delete"))
			L += list(list("m_delete", "Mapper Delete"))
	// surface-profile tools (Mapper category), hascall carries the permission
	if(hascall(mob, "Surface_Inspect"))          L += list(list("s_inspect", "Surface Inspect"))
	if(hascall(mob, "Surface_Set_Profile"))      L += list(list("s_profile", "Set Profile"))
	if(hascall(mob, "Surface_Set_Type_Profile")) L += list(list("s_tprofile", "Set Type Profile"))
	if(hascall(mob, "Surface_Set_Occlusion"))    L += list(list("s_occlude", "Set Occlusion"))
	if(isobj(A) && hascall(mob, "Surface_Set_Light")) L += list(list("s_light", "Set Light"))
	if(isobj(A) && hascall(mob, "Surface_Set_Wind"))  L += list(list("s_wind", "Set Wind"))
	if(hascall(mob, "Surface_Clear_Overrides"))  L += list(list("s_clear", "Clear Overrides"))
	return L

client/proc/ComputeAtomPanelAnchor()
	// same right-margin dock as the player panel, sized for the 160px strip
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return 0
	var/tw = text2num(v[1]); var/th = text2num(v[2])
	if(!tw || !th) return 0
	var/leftpx = tw * 32 - 44 - APANEL_W
	atomp_tile = (leftpx - leftpx % 32) / 32 + 1
	atomp_xpix = leftpx % 32
	var/ptop = max(0, round((th * 32 - APANEL_H) / 2))
	var/pbot = ptop + APANEL_H
	var/ptiles = round(pbot / 32)
	if(ptiles * 32 < pbot) ptiles++
	atomp_row = max(th - ptiles + 1, 1)
	atomp_poff = (th - atomp_row + 1) * 32 - pbot
	return 1

client/proc/ATPLoc(px, py)
	// shares the player panel's saved drag offset so both dock at the same spot (might change this to be closer to actual right click loc)
	return "[atomp_tile]:[atomp_xpix + px + pp_pan_x],[atomp_row]:[atomp_poff + py + pp_pan_y]"

client/proc/ATPanelBounds()
	var/list/vd = splittext("[view]", "x")
	var/vw = (vd.len >= 1) ? text2num(vd[1]) : 20
	var/vh = (vd.len >= 2) ? text2num(vd[2]) : 15
	var/left = (atomp_tile - 1) * 32 + atomp_xpix
	var/right = left + APANEL_W
	var/bot = (atomp_row - 1) * 32 + atomp_poff
	var/top = bot + APANEL_H
	var/minx = -left
	if(minx > 0) minx = 0
	var/maxx = vw * 32 - right
	if(maxx < 0) maxx = 0
	var/miny = -bot
	if(miny > 0) miny = 0
	var/maxy = vh * 32 - top
	if(maxy < 0) maxy = 0
	return list(minx, maxx, miny, maxy)

client/proc/ATPanelStart(params)
	pp_pan_dragged = FALSE
	var/list/m = MouseAbs(params)
	if(!m) return
	pp_pan_mx = m[1]; pp_pan_my = m[2]
	pp_pan_ox = pp_pan_x; pp_pan_oy = pp_pan_y

client/proc/ATPanelMove(params)
	if(!atom_panel_objs) return
	var/list/m = MouseAbs(params)
	if(!m) return
	var/list/b = ATPanelBounds()
	var/wantx = clamp(pp_pan_ox + (m[1] - pp_pan_mx), b[1], b[2])
	var/wanty = clamp(pp_pan_oy + (m[2] - pp_pan_my), b[3], b[4])
	var/dx = wantx - pp_pan_x
	var/dy = wanty - pp_pan_y
	if(!dx && !dy) return
	pp_pan_x = wantx; pp_pan_y = wanty
	pp_pan_dragged = TRUE
	PanShift(atom_panel_objs, dx, dy)

client/proc/ATPanelEnd()
	if(!pp_pan_dragged) return
	pp_pan_dragged = FALSE
	setPref("ppPanX", pp_pan_x)
	setPref("ppPanY", pp_pan_y)

client/proc/HideAtomPanel()
	atom_panel_open = FALSE
	atom_panel_target = null
	atom_btn_objs = null
	atom_cmd_list = null
	atomp_thumb = null
	if(atom_panel_objs)
		while(atom_panel_objs.len)
			var/atom/movable/o = atom_panel_objs[atom_panel_objs.len]
			atom_panel_objs.len--
			screen -= o
			del o
		atom_panel_objs = null

client/proc/ShowAtomPanel(atom/A)
	if(!A || !mob) return
	if(!mob.Admin && !mob.Mapper) return
	if(!isturf(A) && !(isobj(A) && A.loc)) return   // map atoms only, screen objs keep their own handlers
	var/list/cmds = AtomCommandList(A)
	if(!cmds.len) return
	HidePlayerPanel()   // shared dock. also clears the admin strip + any old atom panel
	if(!ComputeAtomPanelAnchor()) return
	pp_pan_x = getPref("ppPanX"); if(isnull(pp_pan_x)) pp_pan_x = 0
	pp_pan_y = getPref("ppPanY"); if(isnull(pp_pan_y)) pp_pan_y = 0
	var/list/pb = ATPanelBounds()
	pp_pan_x = clamp(pp_pan_x, pb[1], pb[2])
	pp_pan_y = clamp(pp_pan_y, pb[3], pb[4])
	atom_panel_objs = list()
	atom_btn_objs = list()
	atom_cmd_list = cmds
	atom_panel_target = A
	atom_panel_open = TRUE
	atomp_px = 0
	atomp_target_px = 0

	var/atom/movable/shud/atompanelbg/bg = new
	bg.icon = 'HUD/admin_panel.png'
	bg.screen_loc = ATPLoc(0, 0)
	atom_panel_objs += bg

	var/icon/btnicon = AdminBtnIcon(ABTN_W)
	for(var/k = 1 to ADMIN_ROWS)
		var/atom/movable/shud/adminbtn/atombtn/b = new
		b.icon = btnicon
		atom_btn_objs += b
		atom_panel_objs += b

	// interior-colored cover strips clip rows that scroll past the band edges
	var/atom/movable/shud/tcov = new
	tcov.icon = AdminCoverIcon(136, 30)
	tcov.mouse_opacity = 0
	tcov.layer = APANEL_LAYER + 0.2
	tcov.screen_loc = ATPLoc(12, 276)
	atom_panel_objs += tcov
	var/atom/movable/shud/bcov = new
	bcov.icon = AdminCoverIcon(136, 30)
	bcov.mouse_opacity = 0
	bcov.layer = APANEL_LAYER + 0.2
	bcov.screen_loc = ATPLoc(12, 22)
	atom_panel_objs += bcov

	var/atom/movable/shud/admintrack/tr = new
	tr.kind = "atom"
	tr.icon = 'HUD/scroll_track_224.png'
	tr.screen_loc = ATPLoc(ADMIN_TRACK_X, ADMIN_TRACK_PY)
	atom_panel_objs += tr
	atomp_thumb = new
	atomp_thumb.kind = "atom"
	atomp_thumb.icon = 'HUD/scroll_thumb.png'
	atom_panel_objs += atomp_thumb

	// target readout over the top cover strip so staff can see what they grabbed
	var/atom/movable/shud/adminlbl/nm = new
	nm.layer = APANEL_LAYER + 0.3
	nm.maptext_width = 152
	nm.maptext_height = 30
	nm.screen_loc = ATPLoc(12, 278)
	nm.maptext = "<center><span style=\"[APANEL_FONT]; color:#8be9ff\">[html_encode("[A.name]")]</span></center>"
	atom_panel_objs += nm

	RefreshAtomBtns()
	for(var/atom/movable/o in atom_panel_objs)
		screen += o
	KineticEntrance(atom_panel_objs)

client/proc/RefreshAtomBtns()
	if(!atom_btn_objs || !atom_cmd_list) return
	var/total = atom_cmd_list.len
	var/maxpx = max(0, total * ABTN_RH - ADMIN_BAND_H)
	atomp_px = clamp(atomp_px, 0, maxpx)
	var/sub = atomp_px % ABTN_RH
	var/first = (atomp_px - sub) / ABTN_RH
	for(var/k = 1 to atom_btn_objs.len)
		var/atom/movable/shud/adminbtn/b = atom_btn_objs[k]
		b.screen_loc = ATPLoc(ABTN_X, ADMIN_Y0 - (k - 1) * ABTN_RH + sub)
		var/idx = first + k
		if(idx <= total)
			var/list/cmd = atom_cmd_list[idx]
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
	if(atomp_thumb)
		if(maxpx <= 0)
			atomp_thumb.alpha = 80
			atomp_thumb.screen_loc = ATPLoc(ADMIN_TRACK_X + 1, ADMIN_TRACK_PY + ADMIN_TRACK_H - ADMIN_THUMB_H)
		else
			atomp_thumb.alpha = 255
			var/off = round((atomp_px / maxpx) * (ADMIN_TRACK_H - ADMIN_THUMB_H))
			atomp_thumb.screen_loc = ATPLoc(ADMIN_TRACK_X + 1, ADMIN_TRACK_PY + ADMIN_TRACK_H - ADMIN_THUMB_H - off)

client/proc/AnimateAtomScroll()
	set waitfor = 0
	atomp_anim = TRUE
	while(atom_panel_open && atom_btn_objs && atomp_px != atomp_target_px)
		var/diff = atomp_target_px - atomp_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1
		atomp_px += stepp
		RefreshAtomBtns()
		sleep(world.tick_lag)
	atomp_anim = FALSE

client/proc/AtomWheelScroll(delta_y)
	if(!atom_panel_open || !atom_cmd_list || !atom_cmd_list.len) return 0
	var/maxpx = max(0, atom_cmd_list.len * ABTN_RH - ADMIN_BAND_H)
	if(maxpx > 0)
		var/dir = (delta_y > 0) ? -1 : 1
		atomp_target_px = clamp(atomp_target_px + dir * ABTN_RH, 0, maxpx)
		if(!atomp_anim) AnimateAtomScroll()
	return 1

client/proc/AtomPanelAction(action)
	if(!mob || (!mob.Admin && !mob.Mapper)) return
	var/atom/T = atom_panel_target
	if(!T) return
	switch(action)
		if("a_edit")   AdminInvoke("Edit", T)
		if("a_rename") AdminInvoke("AdminRename", T)
		if("a_delete")
			AdminInvoke("Delete", T)
			HideAtomPanel()
		if("m_edit")   AdminInvoke("Mapper_Edit", T)
		if("m_fade")   AdminInvoke("Mapper_Fade", T)
		if("m_delete")
			AdminInvoke("Mapper_Delete", T)
			HideAtomPanel()
		if("s_inspect")  AdminInvoke("Surface_Inspect", T)
		if("s_profile")  AdminInvoke("Surface_Set_Profile", T)
		if("s_tprofile") AdminInvoke("Surface_Set_Type_Profile", T)
		if("s_occlude")  AdminInvoke("Surface_Set_Occlusion", T)
		if("s_light")    AdminInvoke("Surface_Set_Light", T)
		if("s_wind")     AdminInvoke("Surface_Set_Wind", T)
		if("s_clear")    AdminInvoke("Surface_Clear_Overrides", T)


/atom/movable/shud/stackpanelbg
	layer = APANEL_LAYER
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr) usr.client.HideStackPicker()

/atom/movable/shud/adminbtn/stackbtn
	var/pick_idx = 0
	Click(location, control, params)
		if(!usr || !usr.client) return
		if(params && findtext(params, "right=1"))
			usr.client.HideStackPicker()
			return
		usr.client.StackPick(pick_idx)

client
	var/tmp
		list/stack_panel_objs
		list/stack_btn_objs
		list/stack_list
		stack_panel_open = FALSE
		stackp_px = 0
		stackp_target_px = 0
		stackp_anim = FALSE
		atom/movable/shud/adminthumb/stackp_thumb

client/proc/StackLabel(atom/A)
	if(!A) return "?"
	var/n = "[A.name]"
	if(length(n) > 22) n = "[copytext(n, 1, 20)]..."
	return html_encode(n)

client/proc/RightClickOpen(atom/A)
	HideStackPicker()
	if(!A) return
	if(istype(A, /mob/Players))
		ShowPlayerPanel(A)
		return
	if(isturf(A) || (isobj(A) && A.loc))
		ShowAtomPanel(A)

client/proc/RightClickUsable(atom/A)
	if(!A || !mob) return 0
	if(istype(A, /mob/Players)) return 1
	if(isturf(A) || (isobj(A) && A.loc))
		if(!mob.Admin && !mob.Mapper) return 0
		return AtomCommandList(A).len ? 1 : 0
	return 0

client/proc/RightClickTurf(atom/A, atom/location)
	if(isturf(A)) return A
	if(isturf(location)) return location
	if(A && isturf(A.loc)) return A.loc
	return null

client/proc/StackSortByLayer(list/L)
	var/list/out = list()
	for(var/atom/A in L)
		var/placed = 0
		for(var/i = 1 to out.len)
			var/atom/B = out[i]
			if(A.layer > B.layer)
				out.Insert(i, A)
				placed = 1
				break
		if(!placed) out += A
	return out

client/proc/RightClickCandidates(turf/T, atom/A)
	var/list/out = list()
	if(!mob) return out
	if(T)
		for(var/atom/movable/M in T)
			if(!M.mouse_opacity) continue
			if(M.invisibility > mob.see_invisible) continue
			if(!RightClickUsable(M)) continue
			out += M
		if(RightClickUsable(T)) out += T
	if(A && !(A in out) && RightClickUsable(A)) out += A
	return StackSortByLayer(out)

client/proc/HideStackPicker()
	stack_panel_open = FALSE
	stack_list = null
	stack_btn_objs = null
	stackp_thumb = null
	if(stack_panel_objs)
		while(stack_panel_objs.len)
			var/atom/movable/o = stack_panel_objs[stack_panel_objs.len]
			stack_panel_objs.len--
			screen -= o
			del o
		stack_panel_objs = null

client/proc/ShowStackPicker(list/cands)
	HideStackPicker()
	if(!mob || !cands || cands.len < 2) return
	DismissPopupsOutside(null)
	if(!ComputeAtomPanelAnchor()) return
	pp_pan_x = getPref("ppPanX"); if(isnull(pp_pan_x)) pp_pan_x = 0
	pp_pan_y = getPref("ppPanY"); if(isnull(pp_pan_y)) pp_pan_y = 0
	var/list/pb = ATPanelBounds()
	pp_pan_x = clamp(pp_pan_x, pb[1], pb[2])
	pp_pan_y = clamp(pp_pan_y, pb[3], pb[4])
	stack_panel_objs = list()
	stack_btn_objs = list()
	stack_list = cands.Copy()
	stack_panel_open = TRUE
	stackp_px = 0
	stackp_target_px = 0

	var/atom/movable/shud/stackpanelbg/bg = new
	bg.icon = 'HUD/admin_panel.png'
	bg.screen_loc = ATPLoc(0, 0)
	stack_panel_objs += bg

	var/icon/btnicon = AdminBtnIcon(ABTN_W)
	for(var/k = 1 to ADMIN_ROWS)
		var/atom/movable/shud/adminbtn/stackbtn/b = new
		b.icon = btnicon
		stack_btn_objs += b
		stack_panel_objs += b

	var/atom/movable/shud/tcov = new
	tcov.icon = AdminCoverIcon(136, 30)
	tcov.mouse_opacity = 0
	tcov.layer = APANEL_LAYER + 0.2
	tcov.screen_loc = ATPLoc(12, 276)
	stack_panel_objs += tcov
	var/atom/movable/shud/bcov = new
	bcov.icon = AdminCoverIcon(136, 30)
	bcov.mouse_opacity = 0
	bcov.layer = APANEL_LAYER + 0.2
	bcov.screen_loc = ATPLoc(12, 22)
	stack_panel_objs += bcov

	var/atom/movable/shud/admintrack/tr = new
	tr.kind = "stack"
	tr.icon = 'HUD/scroll_track_224.png'
	tr.screen_loc = ATPLoc(ADMIN_TRACK_X, ADMIN_TRACK_PY)
	stack_panel_objs += tr
	stackp_thumb = new
	stackp_thumb.kind = "stack"
	stackp_thumb.icon = 'HUD/scroll_thumb.png'
	stack_panel_objs += stackp_thumb

	var/atom/movable/shud/adminlbl/nm = new
	nm.layer = APANEL_LAYER + 0.3
	nm.maptext_width = 152
	nm.maptext_height = 30
	nm.screen_loc = ATPLoc(12, 278)
	nm.maptext = "<center><span style=\"[APANEL_FONT]; color:#8be9ff\">SELECT TARGET</span></center>"
	stack_panel_objs += nm

	RefreshStackBtns()
	for(var/atom/movable/o in stack_panel_objs)
		screen += o
	KineticEntrance(stack_panel_objs)

client/proc/RefreshStackBtns()
	if(!stack_btn_objs || !stack_list) return
	var/total = stack_list.len
	var/maxpx = max(0, total * ABTN_RH - ADMIN_BAND_H)
	stackp_px = clamp(stackp_px, 0, maxpx)
	var/sub = stackp_px % ABTN_RH
	var/first = (stackp_px - sub) / ABTN_RH
	for(var/k = 1 to stack_btn_objs.len)
		var/atom/movable/shud/adminbtn/stackbtn/b = stack_btn_objs[k]
		b.screen_loc = ATPLoc(ABTN_X, ADMIN_Y0 - (k - 1) * ABTN_RH + sub)
		var/idx = first + k
		if(idx <= total)
			b.pick_idx = idx
			b.alpha = 255
			b.mouse_opacity = 2
			b.lbl.maptext = "<center><span style=\"[APANEL_FONT]; color:#ffffff\">[StackLabel(stack_list[idx])]</span></center>"
			b.lbl.alpha = 255
		else
			b.pick_idx = 0
			b.alpha = 0
			b.mouse_opacity = 0
			b.lbl.maptext = ""
			b.lbl.alpha = 0
	if(stackp_thumb)
		if(maxpx <= 0)
			stackp_thumb.alpha = 80
			stackp_thumb.screen_loc = ATPLoc(ADMIN_TRACK_X + 1, ADMIN_TRACK_PY + ADMIN_TRACK_H - ADMIN_THUMB_H)
		else
			stackp_thumb.alpha = 255
			var/off = round((stackp_px / maxpx) * (ADMIN_TRACK_H - ADMIN_THUMB_H))
			stackp_thumb.screen_loc = ATPLoc(ADMIN_TRACK_X + 1, ADMIN_TRACK_PY + ADMIN_TRACK_H - ADMIN_THUMB_H - off)

client/proc/AnimateStackScroll()
	set waitfor = 0
	stackp_anim = TRUE
	while(stack_panel_open && stack_btn_objs && stackp_px != stackp_target_px)
		var/diff = stackp_target_px - stackp_px
		var/stepp = round(diff * 0.5)
		if(!stepp) stepp = (diff > 0) ? 1 : -1
		stackp_px += stepp
		RefreshStackBtns()
		sleep(world.tick_lag)
	stackp_anim = FALSE

client/proc/StackWheelScroll(delta_y)
	if(!stack_panel_open || !stack_list || !stack_list.len) return 0
	var/maxpx = max(0, stack_list.len * ABTN_RH - ADMIN_BAND_H)
	if(maxpx > 0)
		var/dir = (delta_y > 0) ? -1 : 1
		stackp_target_px = clamp(stackp_target_px + dir * ABTN_RH, 0, maxpx)
		if(!stackp_anim) AnimateStackScroll()
	return 1

client/proc/StackPick(idx)
	if(!stack_list || idx < 1 || idx > stack_list.len) return
	var/atom/A = stack_list[idx]
	RightClickOpen(A)
