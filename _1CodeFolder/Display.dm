#define DISPLAY_ZOOM_ON 2       // zoom when the player's Zoom 2x option is on; off = 1x (native)
#define DISPLAY_MIN_VIEW 7
#define DISPLAY_BASE_MAX_VIEW 31
// bottom HUD's native width in view px: SkillHUD's SHUD_ORB_LEFT_X..SHUD_ORB_RIGHT_X+SHUD_ORB_D
// (-267..267). Keep in sync if the orb layout moves.
#define DISPLAY_HUD_SPAN 534

var/CLIENT_FPS_DEFAULT = 40 //client render rate; server tick stays world.fps

mob/proc/EffectiveClientFPS()
	return ChosenFPS || CLIENT_FPS_DEFAULT

client
	var/tmp
		view_fit_enabled = FALSE
		view_fit_queued = FALSE
		view_fit_watching = FALSE
		view_fit_last_pw = 0
		view_fit_last_ph = 0
		view_fit_last_zoom = 0
		atom/movable/cutscene_hud_hider
		cutscene_active = FALSE

client/proc/CurrentZoom()
	return getPref("zoom2x") ? DISPLAY_ZOOM_ON : 1

client/proc/EffectiveZoom(pw = 0)
	var/z = CurrentZoom()
	if(z <= 1) return 1
	if(!pw)
		var/list/parts = splittext(winget(src, "mapwindow.map", "size"), "x")
		if(parts.len >= 2) pw = text2num(parts[1])
	if(pw && pw < DISPLAY_HUD_SPAN * z) return 1
	return z

client/proc/ApplyMapZoom(z)
	view_fit_last_zoom = z
	winset(src, "mapwindow.map", "zoom=[z];zoom-mode=distort;letterbox=true")

mob/proc/MaxViewCap()
	return DISPLAY_BASE_MAX_VIEW

mob/proc/UserMaxView()
	if(!ScreenSize) return 0
	var/list/parts = splittext("[ScreenSize]", "x")
	var/n = text2num(parts[1])
	return n ? n : 0

client/proc/SetupGameDisplay()
	if(!mob) return
	ApplyMapZoom(EffectiveZoom())
	view_fit_enabled = TRUE
	FitViewNow()
	StartViewFitWatchdog()

client/proc/SetupTitleDisplay()
	view_fit_enabled = FALSE
	view_fit_last_zoom = 0
	winset(src, "mapwindow.map", "zoom=0;zoom-mode=normal;letterbox=true")

client/proc/ApplyZoomPref()
	if(!mob) return
	var/z = EffectiveZoom()
	ApplyMapZoom(z)
	if(z < CurrentZoom()) 
		src << "Zoom 2x needs a wider game window, showing 1x until there's room for the HUD."
	FitViewNow()

// alpha-0 plane master blanks the whole HUD plane without touching any element's own state
/atom/movable/cutscene_hud_hider
	plane = HUD_PLANE
	appearance_flags = PLANE_MASTER
	alpha = 0
	screen_loc = "1,1"
	mouse_opacity = 0

// cutscenes
client/proc/SetupCutsceneDisplay()
	view_fit_enabled = FALSE
	view_fit_last_zoom = 0
	winset(src, "mapwindow.map", "zoom=0;zoom-mode=distort;letterbox=true")
	view = "21x21"
	if(!cutscene_hud_hider)
		cutscene_hud_hider = new /atom/movable/cutscene_hud_hider()
		screen += cutscene_hud_hider
	cutscene_active = TRUE
	CutsceneApplyFx()

client/proc/EndCutsceneDisplay()
	ApplyMapZoom(EffectiveZoom())
	view_fit_enabled = TRUE
	if(cutscene_hud_hider)
		screen -= cutscene_hud_hider
		cutscene_hud_hider = null
	cutscene_active = FALSE
	CutsceneApplyFx()
	FitViewNow()

// turn bloom off for cutscenes
client/proc/CutsceneApplyFx()
	if(client_plane_master) CpmApply(src) 
	else FxApplyBloom(src)                

client/verb/FitView()
	set hidden = 1
	set name = "FitView"
	QueueViewFit()

client/proc/QueueViewFit()
	if(!view_fit_enabled || view_fit_queued) return
	view_fit_queued = TRUE
	spawn(3)
		view_fit_queued = FALSE
		FitViewNow()

// display change fix
client/proc/StartViewFitWatchdog()
	if(view_fit_watching) return
	view_fit_watching = TRUE
	spawn()
		while(src)
			sleep(25)
			if(!view_fit_enabled || !mob) continue
			var/list/parts = splittext(winget(src, "mapwindow.map", "size"), "x")
			if(parts.len < 2) continue
			var/pw = text2num(parts[1])
			var/ph = text2num(parts[2])
			if(!pw || !ph) continue
			if(pw != view_fit_last_pw || ph != view_fit_last_ph)
				FitViewNow()

client/proc/FitViewNow()
	if(!view_fit_enabled || !mob) return
	var/list/parts = splittext(winget(src, "mapwindow.map", "size"), "x")
	if(parts.len < 2) return
	var/pw = text2num(parts[1])
	var/ph = text2num(parts[2])
	if(!pw || !ph) return
	view_fit_last_pw = pw
	view_fit_last_ph = ph
	var/z = EffectiveZoom(pw)
	if(z != view_fit_last_zoom) // pane crossed the width the HUD needs at 2x
		ApplyMapZoom(z)
	var/ref_tile = world.icon_size * DISPLAY_ZOOM_ON
	var/cap = mob.MaxViewCap()
	var/pref = mob.UserMaxView()
	var/maxtiles = pref ? min(pref, cap) : cap
	var/ref_tw = min(max(round(pw / ref_tile), DISPLAY_MIN_VIEW), maxtiles)
	var/ref_th = min(max(round(ph / ref_tile), DISPLAY_MIN_VIEW), maxtiles)
	var/zmul = DISPLAY_ZOOM_ON / z
	var/tw = round(ref_tw * zmul)
	var/th = round(ref_th * zmul)
	view = "[tw]x[th]"
	GfxResizeScreenOverlays(src, pw, ph)
	PositionSkillHUD()
	Hd2dApplyClient(src) // shaft transform + farblur masks re-fit to the new view
	PositionCharacterCard() // re-anchor card to new view height, no-op if no card
	if(party_invite_from) ShowPartyInvite(party_invite_from) // re-center an open invite prompt on resize

mob/verb
	Max_View()
		set category = "Other"
		set name = "Max View"
		set hidden = 1
		if(!(world.time > verb_delay)) return
		verb_delay = world.time + 1
		var/cap = MaxViewCap()
		var/n = input(usr, "Maximum tiles of view ([DISPLAY_MIN_VIEW]-[cap]). Enter 0 to always fill the window (up to [cap]).", "Max View", UserMaxView()) as null|num
		if(isnull(n)) return
		if(n <= 0)
			ScreenSize = null
		else
			ScreenSize = "[min(max(round(n), DISPLAY_MIN_VIEW), cap)]"
		client?.FitViewNow()
