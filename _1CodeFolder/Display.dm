#define DISPLAY_ZOOM_ON 2       // zoom when the player's Zoom 2x option is on; off = 1x (native)
#define DISPLAY_MIN_VIEW 7
#define DISPLAY_BASE_MAX_VIEW 31

client
	var/tmp
		view_fit_enabled = FALSE
		view_fit_queued = FALSE

client/proc/CurrentZoom()
	return getPref("zoom2x") ? DISPLAY_ZOOM_ON : 1

mob/proc/MaxViewCap()
	return DISPLAY_BASE_MAX_VIEW

mob/proc/UserMaxView()
	if(!ScreenSize) return 0
	var/list/parts = splittext("[ScreenSize]", "x")
	var/n = text2num(parts[1])
	return n ? n : 0

client/proc/SetupGameDisplay()
	if(!mob) return
	winset(src, "mapwindow.map", "zoom=[CurrentZoom()];zoom-mode=distort;letterbox=true")
	view_fit_enabled = TRUE
	FitViewNow()

client/proc/SetupTitleDisplay()
	view_fit_enabled = FALSE
	winset(src, "mapwindow.map", "zoom=0;zoom-mode=normal;letterbox=true")

client/proc/ApplyZoomPref()
	if(!mob) return
	winset(src, "mapwindow.map", "zoom=[CurrentZoom()];zoom-mode=distort;letterbox=true")
	FitViewNow()

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

client/proc/FitViewNow()
	if(!view_fit_enabled || !mob) return
	var/list/parts = splittext(winget(src, "mapwindow.map", "size"), "x")
	if(parts.len < 2) return
	var/pw = text2num(parts[1])
	var/ph = text2num(parts[2])
	if(!pw || !ph) return
	var/ref_tile = world.icon_size * DISPLAY_ZOOM_ON
	var/cap = mob.MaxViewCap()
	var/pref = mob.UserMaxView()
	var/maxtiles = pref ? min(pref, cap) : cap
	var/ref_tw = min(max(round(pw / ref_tile), DISPLAY_MIN_VIEW), maxtiles)
	var/ref_th = min(max(round(ph / ref_tile), DISPLAY_MIN_VIEW), maxtiles)
	var/zmul = DISPLAY_ZOOM_ON / CurrentZoom()
	var/tw = round(ref_tw * zmul)
	var/th = round(ref_th * zmul)
	view = "[tw]x[th]"
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
