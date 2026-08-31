#define BUILD_MARKS_FILE "Saves/BuildMarks.txt"

var/global/list/buildMarks

mob/verb/Build_Inspect()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.InspectTile()

/datum/build_session/proc/InspectTile()
	var/turf/T = mouseTurf
	if(!T)
		C.mob << "Hover a map tile, then press Ctrl+I."
		return
	var/list/out = list()
	out += "<b>TILE ([T.x],[T.y],[T.z])</b> - [T.name] ([T.type])"
	var/mat = BuildMaterialFor(T)
	out += "material: [mat ? mat : "none"] | icon [T.icon] \"[T.icon_state]\""
	out += "density [T.density] | opacity [T.opacity] | shallow [T.Shallow] | flyover [T.FlyOverAble] | destructable [T.Destructable] | builder [length(T.Builder) ? T.Builder : "map"]"
	if(istype(T, /turf/CustomTurf))
		var/turf/CustomTurf/CT = T
		out += "custom turf | roof [CT.Roof]"
	var/area/AR = T.loc
	if(istype(AR, /area/MapperZone))
		var/area/MapperZone/MZ = AR
		out += "zone \"[MZ.name]\" | sky [MZ.sees_sky] | profile [MZ.env_profile_id] | wind [MZ.zone_wind_mult * 100]%[length(MZ.wx_kind) ? " | weather [MZ.wx_kind]" : ""]"
	else if(AR)
		out += "area [AR.name] ([AR.type])"
	var/n = 0
	for(var/obj/O in T)
		if(O.gfx_transient_visual)
			continue
		n++
		if(n > 12)
			out += "  ...and more objects."
			break
		var/line = "  obj [O.name] ([O.type]) state \"[O.icon_state]\" layer [O.layer]"
		if(istype(O, /obj/Special/Teleporter2))
			var/obj/Special/Teleporter2/TP = O
			line += " -> warps to ([TP.gotoX],[TP.gotoY],[TP.gotoZ])"
		if(length(O.Builder))
			line += " by [O.Builder]"
		out += line
	if(!n)
		out += "no objects on this tile."
	C.mob << jointext(out, "\n")

/proc/BuildHUDSetCoord(datum/build_session/S, turf/T)
	if(!S?.coordObj || !T)
		return
	S.coordObj.maptext = "<span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#7f909f\">X [T.x]  Y [T.y]  Z [T.z]</span>"

/proc/BuildMarksLoad()
	if(buildMarks)
		return
	buildMarks = list()
	if(!fexists(BUILD_MARKS_FILE))
		return
	var/raw = file2text(BUILD_MARKS_FILE)
	for(var/line in splittext(raw, "\n"))
		var/list/parts = splittext(line, "\t")
		if(parts.len < 2)
			continue
		var/list/marks = list()
		for(var/i = 2 to parts.len)
			var/list/f = splittext(parts[i], "|")
			if(f.len < 4)
				continue
			var/mx = text2num(f[2])
			var/my = text2num(f[3])
			var/mz = text2num(f[4])
			if(!mx || !my || !mz)
				continue
			marks[f[1]] = list(mx, my, mz)
		buildMarks[parts[1]] = marks

/proc/BuildMarksSave()
	if(!buildMarks)
		return
	var/out = ""
	for(var/ck in buildMarks)
		var/list/marks = buildMarks[ck]
		if(!marks || !marks.len)
			continue
		var/line = ck
		for(var/nm in marks)
			var/list/p = marks[nm]
			line += "\t[nm]|[p[1]]|[p[2]]|[p[3]]"
		out += "[line]\n"
	if(fexists(BUILD_MARKS_FILE))
		fdel(BUILD_MARKS_FILE)
	text2file(out, BUILD_MARKS_FILE)

/proc/BuildMarksFor(ck)
	BuildMarksLoad()
	var/list/marks = buildMarks[ck]
	if(!marks)
		marks = list()
		buildMarks[ck] = marks
	return marks

mob/Mapper/verb/Bookmark_Here()
	set category = "Mapper"
	spawn
		var/nm = usr.HUDTextPrompt("Name this bookmark", "")
		if(isnull(nm) || !length(nm))
			return
		nm = replacetext(replacetext(nm, "|", "/"), "\t", " ")
		var/list/marks = BuildMarksFor(usr.ckey)
		marks[nm] = list(usr.x, usr.y, usr.z)
		BuildMarksSave()
		usr << "Bookmarked \"[nm]\" at ([usr.x],[usr.y],[usr.z]) - [marks.len] saved."

mob/Mapper/verb/Go_To_Bookmark()
	set category = "Mapper"
	var/list/marks = BuildMarksFor(usr.ckey)
	if(!marks.len)
		usr << "No bookmarks yet. Bookmark_Here saves your current spot."
		return
	var/list/menu = list()
	for(var/nm in marks)
		var/list/p = marks[nm]
		menu["[nm] ([p[1]],[p[2]],[p[3]])"] = nm
	var/pick = input(usr, "Jump where?", "Bookmarks") as null|anything in menu
	if(!pick)
		return
	var/list/p = marks[menu[pick]]
	if(!p)
		return
	var/turf/T = locate(p[1], p[2], p[3])
	if(!T)
		usr << "That spot no longer exists."
		return
	usr.loc = T
	Log("Admin", "[ExtractInfo(usr)] jumped to bookmark \"[menu[pick]]\" ([p[1]],[p[2]],[p[3]]).")

mob/Mapper/verb/Delete_Bookmark()
	set category = "Mapper"
	var/list/marks = BuildMarksFor(usr.ckey)
	if(!marks.len)
		usr << "No bookmarks to delete."
		return
	var/list/menu = list()
	for(var/nm in marks)
		var/list/p = marks[nm]
		menu["[nm] ([p[1]],[p[2]],[p[3]])"] = nm
	var/pick = input(usr, "Delete which bookmark?", "Bookmarks") as null|anything in menu
	if(!pick)
		return
	marks -= menu[pick]
	BuildMarksSave()
	usr << "Deleted bookmark \"[menu[pick]]\" ([marks.len] left)."

/proc/BuildMakeWarperPair(mob/M, turf/at, turf/dest)
	var/obj/Special/Teleporter2/q = new(at)
	var/obj/Special/Teleporter2/q2 = new(dest)
	q.Savable = 1
	q.Destructable = 0
	q.gotoX = dest.x
	q.gotoY = dest.y
	q.gotoZ = dest.z
	q.AssociatedWarper = q2
	q2.Savable = 1
	q2.Destructable = 0
	q2.gotoX = at.x
	q2.gotoY = at.y
	q2.gotoZ = at.z
	q2.AssociatedWarper = q
	global.worldObjectList += q
	global.worldObjectList += q2
	M << "Warper pair created: ([at.x],[at.y],[at.z]) <-> ([dest.x],[dest.y],[dest.z])."
	Log("Admin", "[ExtractInfo(M)] made a warper pair at [at.x],[at.y],[at.z] <-> [dest.x],[dest.y],[dest.z] (wizard).")

mob/Mapper/verb/Make_Warper_Wizard()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.warpStage = 1
	usr << "WARPER: click the tile where the warper goes. Right-click cancels."

mob/Mapper/verb/Build_Options()
	set category = "Mapper"
	while(usr?.client)
		var/list/menu = list(
			"Overwrite objs: [usr.BuildOverwrite ? "ON" : "OFF"]",
			"Overwrite warpers: [usr.WarperOverwrite ? "ON" : "OFF"]",
			"Indestructible turfs: [usr.TurfInvincible ? "ON" : "OFF"]",
			"Unflyable turfs: [usr.UnFlyable ? "ON" : "OFF"]",
			"Shallow water: [usr.ShallowMode ? "ON" : "OFF"]",
			"Ungrabbable objs: [usr.MakeUngrabbable ? "ON" : "OFF"]",
			"Mapper sight: [usr.MapperSight ? "ON" : "OFF"]",
			"Mapper walk: [usr.MapperWalk ? "ON" : "OFF"]",
			"Water walk: [usr.MapperWaterWalk ? "ON" : "OFF"]",
			"Fly through: [usr.IgnoreFlyOver ? "ON" : "OFF"]",
			"Binoculars: [usr.Bino ? "ON" : "OFF"]",
			"Invisibility: [usr.AdminInviso ? "ON" : "OFF"]",
			"Teleport to X,Y,Z",
			"Done")
		var/choice = input(usr, "Build options - pick one to flip.", "Build Options") as null|anything in menu
		if(!choice || choice == "Done")
			return
		if(findtext(choice, "Overwrite objs"))
			usr.BuildOverwrite = !usr.BuildOverwrite
			usr << "Placing turfs [usr.BuildOverwrite ? "WILL" : "will NOT"] delete objects under them."
			BuildHUDRefreshOverwrite(usr.client?.bsession)
		else if(findtext(choice, "Overwrite warpers"))
			usr.WarperOverwrite = !usr.WarperOverwrite
			usr << "Placing turfs [usr.WarperOverwrite ? "WILL" : "will NOT"] delete warpers under them."
		else if(findtext(choice, "Indestructible turfs"))
			usr.TurfInvincible = !usr.TurfInvincible
			usr << "Your placed turfs are now [usr.TurfInvincible ? "INDESTRUCTIBLE" : "destructible"]."
		else if(findtext(choice, "Unflyable turfs"))
			usr.UnFlyable = !usr.UnFlyable
			usr << "Your placed turfs are now [usr.UnFlyable ? "UNFLYABLE (dense)" : "flyable"]."
		else if(findtext(choice, "Shallow water"))
			usr.ShallowMode = !usr.ShallowMode
			usr << "Your placed water is now [usr.ShallowMode ? "SHALLOW (no energy drain)" : "deep (drains energy)"]."
		else if(findtext(choice, "Ungrabbable objs"))
			usr.MakeUngrabbable = !usr.MakeUngrabbable
			usr << "Your placed objects are now [usr.MakeUngrabbable ? "UNGRABBABLE" : "grabbable"] by default."
		else if(findtext(choice, "Mapper sight"))
			if(!usr.MapperSight)
				usr.sight |= SEE_THRU
				usr.MapperSight = 1
				usr << "Mapper Sight ON."
			else
				usr.sight = null
				usr.MapperSight = 0
				usr << "Mapper Sight OFF."
		else if(findtext(choice, "Mapper walk"))
			usr.MapperWalk = !usr.MapperWalk
			usr << "Mapper Walk [usr.MapperWalk ? "ON" : "OFF"]."
		else if(findtext(choice, "Water walk"))
			if(!usr.MapperWaterWalk)
				usr.passive_handler.Increase("WaterWalk")
				usr.MapperWaterWalk = TRUE
				usr << "Water walking ON."
			else
				usr.passive_handler.Decrease("WaterWalk")
				usr.MapperWaterWalk = FALSE
				usr << "Water walking OFF."
		else if(findtext(choice, "Fly through"))
			usr.IgnoreFlyOver = !usr.IgnoreFlyOver
			usr << "Fly through [usr.IgnoreFlyOver ? "ON" : "OFF"]."
		else if(findtext(choice, "Binoculars"))
			if(!usr.Bino)
				usr.client.view = "69x69"
				usr.Bino = 1
				usr << "Binoculars ON."
			else
				usr.client.FitViewNow()
				usr.Bino = 0
				usr << "Binoculars OFF."
		else if(findtext(choice, "Invisibility"))
			if(usr.AdminInviso)
				usr << "<font color='red'>You are no longer invisible.</font color>"
				usr.AdminInviso = 0
				usr.invisibility = 0
				usr.see_invisible = 0
				animate(usr, alpha = 255, time = 10)
			else
				usr << "<font color=green>You are now invisible.</font color>"
				usr.AdminInviso = 1
				usr.invisibility = 85
				usr.see_invisible = 86
				animate(usr, alpha = 50, time = 10)
		else if(findtext(choice, "Teleport"))
			var/tx = usr.HUDNumPrompt("Teleport X", "[usr.x]")
			if(isnull(tx))
				continue
			var/ty = usr.HUDNumPrompt("Teleport Y", "[usr.y]")
			if(isnull(ty))
				continue
			var/tz = usr.HUDNumPrompt("Teleport Z", "[usr.z]")
			if(isnull(tz))
				continue
			var/turf/T = locate(clamp(round(tx), 1, world.maxx), clamp(round(ty), 1, world.maxy), clamp(round(tz), 1, world.maxz))
			if(!T)
				usr << "No tile at those coordinates."
				continue
			usr.loc = T
			Log("Admin", "[ExtractInfo(usr)] teleported to [T.x],[T.y],[T.z].")

/proc/BuildPresenceRoster(client/C, on)
	var/who = "[C?.mob || C?.ckey]"
	for(var/client/K)
		if(K == C)
			continue
		if(K.bsession?.active && K.mob)
			K.mob << "<font color=#78969f>[who] is [on ? "now" : "no longer"] in build mode.</font>"

/proc/BuildPresencePing(client/C, x1, y1, x2, y2, zz, toolname, fresh)
	if(!fresh)
		return
	var/turf/T = locate(clamp(round((x1 + x2) / 2), 1, world.maxx), clamp(round((y1 + y2) / 2), 1, world.maxy), zz)
	if(!T)
		return
	for(var/client/K)
		if(K == C)
			continue
		var/datum/build_session/KS = K.bsession
		if(!KS?.active || !K.mob)
			continue
		if(K.mob.z != zz)
			continue
		var/image/I = image('HUD/build_white.png', T)
		I.color = "#54c8ff"
		I.alpha = 90
		I.plane = BUILD_PREVIEW_PLANE
		I.layer = BUILD_PREVIEW_LAYER
		I.mouse_opacity = 0
		I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
		I.maptext_width = 96
		I.maptext_height = 16
		I.maptext_x = -32
		I.maptext_y = 34
		I.maptext = "<center><span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#54c8ff\">[C.mob] · [uppertext(toolname)]</span></center>"
		K.images += I
		spawn(25)
			if(K)
				K.images -= I
