#define PPANEL_W 208
#define PPANEL_H 316
#define PPANEL_LAYER (FLY_LAYER + 3)            
#define PPANEL_FONT "font-family:'monogram'; font-size:12pt"
#define PPANEL_MARGIN 44

/atom/movable/shud/playerpanel
	layer = PPANEL_LAYER
	mouse_opacity = 2
	Click(location, control, params)
		if(params && findtext(params, "right=1"))
			if(usr) usr.client.HidePlayerPanel()

/atom/movable/shud/playerbtn
	layer = PPANEL_LAYER + 0.2
	mouse_opacity = 2
	var/action
	Click(location, control, params)
		if(usr) usr.client.PlayerPanelAction(action)

client
	var/tmp
		list/player_panel_objs
		mob/player_panel_target
		pp_tile = 1   // cached panel anchor, bottom-left tile/pixel x and row/offset y
		pp_xpix = 0
		pp_row = 1
		pp_poff = 0

client/proc/ComputePlayerPanelAnchor()
	var/list/v = splittext("[view]", "x")
	if(v.len < 2) return 0
	var/tw = text2num(v[1]); var/th = text2num(v[2])
	if(!tw || !th) return 0
	var/leftpx = tw * 32 - PPANEL_MARGIN - PPANEL_W          // panel left edge in px from view left
	pp_tile = (leftpx - leftpx % 32) / 32 + 1
	pp_xpix = leftpx % 32
	var/ptop = max(0, round((th * 32 - PPANEL_H) / 2))       
	var/pbot = ptop + PPANEL_H
	var/ptiles = round(pbot / 32)
	if(ptiles * 32 < pbot) ptiles++                          // ceil to whole tiles
	pp_row = max(th - ptiles + 1, 1)
	pp_poff = (th - pp_row + 1) * 32 - pbot                  // slide up so panel bottom lands at pbot
	return 1

client/proc/PPLoc(px, py)
	return "[pp_tile]:[pp_xpix + px],[pp_row]:[pp_poff + py]"

client/proc/HidePlayerPanel()
	HideAdminPanel()   
	player_panel_target = null
	if(player_panel_objs)
		while(player_panel_objs.len)
			var/atom/movable/o = player_panel_objs[player_panel_objs.len]
			player_panel_objs.len--
			screen -= o
			del o
		player_panel_objs = null

// px/py are panel-local from bottom-left
client/proc/MkPlayerBtn(action, label, px, py)
	var/atom/movable/shud/playerbtn/b = new
	b.icon = 'HUD/pbtn.png'
	b.action = action
	b.screen_loc = PPLoc(px, py)
	player_panel_objs += b
	var/atom/movable/shud/cardtext/L = new   // cardtext gives the 1px outline and click-through
	L.layer = PPANEL_LAYER + 0.3
	L.maptext_width = 80
	L.maptext_height = 24
	L.maptext_y = 4
	L.screen_loc = PPLoc(px, py)
	L.maptext = "<center><span style=\"[PPANEL_FONT]; color:#ffffff\">[label]</span></center>"
	player_panel_objs += L

client/proc/MkPlayerInfo(txt, py)
	var/atom/movable/shud/cardtext/L = new
	L.layer = PPANEL_LAYER + 0.3
	L.maptext_width = PPANEL_W - 24
	L.maptext_height = 16
	L.screen_loc = PPLoc(12, py)
	L.maptext = "<center><span style=\"[PPANEL_FONT]; color:#cfe7ff\">[txt]</span></center>"
	player_panel_objs += L

// examine readouts mirror the old Current Target
mob/proc/PanelTrgCrazy(mob/T)   // mirror of TrgIsBatshitCrazy() but for an explicit target
	if(!T || !T.passive_handler) return 0
	if(T.HasGodKi()) return 1
	if(T.HasMaouKi()) return 1
	if(T.passive_handler.Get("Heart of Darkness")) return 1
	if(T.passive_handler.Get("Sense Replacement")) return 1
	if(T.passive_handler.Get("Void")) return 1
	if(T.HasMechanized()) return 1
	if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Senses")) return 1
	return 0

client/proc/GetPanelPower(mob/T)
	if(!mob || !T) return "?"
	if(T.passive_handler)
		if(T.passive_handler.Get("Masquerade")) return "...Really now?"
		if(T.passive_handler.Get("Heart of Darkness")) return "Boundless"
		if(T.passive_handler.Get("Sense Replacement")) return "[T.SenseReplacement]"
	if(T.HasVoid()) return "..."
	if(mob.PanelTrgCrazy(T) && !mob.hasClearSight()) return "Incomprehensible"
	return mob.Get_Sense_Reading(T)

client/proc/GetPanelOrigin(mob/T)
	if(!T) return "?"
	if(T.passive_handler)
		if(T.passive_handler.Get("Masquerade")) return "..."
		if(T.passive_handler.Get("Obfuscated Origin")) return "Unknowable"
	return "[T.SpawnArea]"

client/proc/GetPanelScent(mob/T)   // null unless the viewer can smell them
	if(!mob || !mob.EnhancedSmell || !T) return null
	if(T.passive_handler && T.passive_handler.Get("Void")) return null
	return T.custom_scent ? T.custom_scent : "Plain"

client/proc/ShowPlayerPanel(mob/Players/P)
	HidePlayerPanel()
	if(!P || !mob) return
	if(!ComputePlayerPanelAnchor()) return   // keeps the panel inside the view so the HUD doesn't expand
	player_panel_objs = list()
	player_panel_target = P
	var/self = (P == mob)

	var/atom/movable/shud/playerpanel/bg = new
	bg.icon = 'HUD/player_panel.png'
	bg.screen_loc = PPLoc(0, 0)
	player_panel_objs += bg

	var/icon/comp = icon('HUD/portrait_frame.png')
	var/icon/p = icon(P.GetPortrait())
	p.Blend(icon('HUD/portrait_mask.png'), ICON_MULTIPLY)
	comp.Blend(p, ICON_OVERLAY, 14, 14)     // 38px portrait centered in the 64px frame
	var/atom/movable/shud/pic = new
	pic.icon = comp
	pic.layer = PPANEL_LAYER + 0.1
	pic.mouse_opacity = 0
	pic.screen_loc = PPLoc(72, PPANEL_H - 78)   // 72 = (208-64)/2 to center the frame
	player_panel_objs += pic

	var/atom/movable/shud/cardtext/nm = new
	nm.layer = PPANEL_LAYER + 0.3
	nm.maptext_width = PPANEL_W
	nm.maptext_height = 18
	nm.screen_loc = PPLoc(0, PPANEL_H - 86)
	nm.maptext = "<center><span style=\"[PPANEL_FONT]; color:#ffffff\">[P.name]</span></center>"
	player_panel_objs += nm
	var/tag = ""
	if(P.information) tag = P.information.catchline
	var/atom/movable/shud/cardtext/tl = new   // 32px box so a long tagline wraps to 2 lines without clipping
	tl.layer = PPANEL_LAYER + 0.3
	tl.maptext_width = PPANEL_W - 28
	tl.maptext_height = 32
	tl.screen_loc = PPLoc(14, PPANEL_H - 128)
	tl.maptext = "<center><span style=\"[PPANEL_FONT]; color:#8be9ff\">[tag ? "\"[tag]\"" : ""]</span></center>"
	player_panel_objs += tl

	// py is measured from the panel bottom, higher = nearer the top
	var/list/btns
	var/btop
	if(self)
		btns = list(list("set_tagline","Set Tagline"), list("edit_profile","Edit Profile"), list("view_own","Own Profile"), list("save_profile","Save Profile"), list("swap_profile","Swap Profile"), list("roll","Roll Dice"), list("pray","Pray"))
		btop = 158
	else
		MkPlayerInfo("Power: [GetPanelPower(P)]", 162)
		MkPlayerInfo("Origin: [GetPanelOrigin(P)]", 144)
		var/sc = GetPanelScent(P)
		if(sc) MkPlayerInfo("Scent: [sc]", 126)
		btns = list(list("view_profile","View Profile"), list("ping","Ping"))
		btop = 96
	if(mob.Admin || glob.TESTER_MODE)
		btns += list(list("admin_view_contents", "Admin View"))   // admin only, works on self and others
	var/bi = 0
	for(var/list/b in btns)
		var/col = bi % 2
		var/r = (bi - col) / 2
		MkPlayerBtn(b[1], b[2], (col == 0) ? 20 : 108, btop - r * 30)
		bi++

	for(var/atom/movable/o in player_panel_objs)
		screen += o
	KineticEntrance(player_panel_objs)

	if(mob.Admin)
		ShowAdminPanel(P)   

client/proc/PlayerPanelAction(action)
	if(!mob) return
	var/mob/Players/p = mob
	var/mob/T = player_panel_target
	switch(action)
		if("edit_profile")
			if(istype(p)) spawn() p.Character_Description()
		if("set_tagline")
			if(mob.information) spawn() mob.information.setCatchLine()
		if("view_own")
			ShowProfileWindow(mob)
		if("roll")
			if(istype(p)) spawn() p.Roll_Dice()
		if("pray")
			spawn() mob.PrayForTheDeath()
		if("save_profile")
			spawn() mob.Save_Profile()
		if("swap_profile")
			spawn() mob.Swap_Profiles()
		if("ping")
			if(T) spawn() mob.Ping(T)
		if("view_profile")
			ShowProfileWindow(T)
		if("admin_view_contents")
			if(!T || !(mob.Admin || glob.TESTER_MODE)) return
			ShowAdminContents(T)

client/proc/ShowProfileWindow(mob/T)
	if(!T || !mob) return
	var/profileHTML = "<html>"
	if(T.transActive())
		profileHTML += T.ReturnProfile(T.transActive())
	if(locate(/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form, T.contents))
		for(var/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form/SF in T.contents)
			if(SF.SlotlessOn)
				profileHTML = T.ReturnProfile(1)
	if(profileHTML == "<html>")
		profileHTML += T.Profile
	profileHTML += "</html>"
	mob << browse(profileHTML, "window=[T];size=900x650")
