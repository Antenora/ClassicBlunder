#define BUILD_PREVIEW_PLANE HUD_PLANE
#define BUILD_PREVIEW_LAYER 1
#define BUILD_HISTORY_CAP 50
#define BUILD_SAVE_COOLDOWN 600
#define BUILD_PREVIEW_ART_CAP 300
#define BUILD_SELECT_CAP 500
#define BUILD_CAT_TERRAIN "TERRAIN"
#define BUILD_CAT_FLOORS "FLOORS"
#define BUILD_CAT_WALLS "WALLS"
#define BUILD_CAT_OBJECTS "OBJECTS"
#define BUILD_CAT_SPECIAL "SPECIAL"
#define BUILD_CAT_CUSTOM "CUSTOM"
#define BUILD_CAT_FAVS "FAVS"
#define BUILD_CAT_ALL "ALL"

var/global/list/buildCategories = list(BUILD_CAT_TERRAIN, BUILD_CAT_FLOORS, BUILD_CAT_WALLS, BUILD_CAT_OBJECTS, BUILD_CAT_SPECIAL, BUILD_CAT_CUSTOM, BUILD_CAT_ZONES, BUILD_CAT_FAVS, BUILD_CAT_ALL)
var/global/list/buildPalette
var/global/list/buildFamilies
var/global/list/buildFavs

turf/proc/CanBuildOver(mob/M)
	return M.Admin || M.Mapper

proc/IsBuildEligible(mob/M)
	return M.Admin || M.Mapper

/datum/build_entry
	var
		name
		iconF
		icon_state
		Creates
		category
		isCustom = 0
		cDensity
		cOpacity
		cRoof
		cLayer
		cPixelX = 0
		cPixelY = 0
		icon/thumb
		pxOff = 0
		pyOff = 0
		isZone = 0
		zoneSmart = 0
		datum/build_zone_def/zoneRef
		swatchColor = ""
		famKey = ""
		dirBase = SOUTH

/proc/BuildEntryFit(datum/build_entry/E)
	if(!E.iconF)
		return
	var/w = GetWidth(E.iconF)
	var/h = GetHeight(E.iconF)
	if(w <= 32 && h <= 32)
		return
	var/f = 32 / max(w, h)
	var/tw = max(1, round(w * f))
	var/th = max(1, round(h * f))
	var/icon/I = new(E.iconF, E.icon_state)
	I.Scale(tw, th)
	E.thumb = I
	E.pxOff = round((32 - tw) / 2)
	E.pyOff = round((32 - th) / 2)

/proc/BuildCategorize(path)
	if(ispath(path, /obj))
		return BUILD_CAT_OBJECTS
	if(ispath(path, /turf/CustomTurf))
		return BUILD_CAT_CUSTOM
	if(ispath(path, /turf/Special))
		return BUILD_CAT_SPECIAL
	var/pt = "[path]"
	if(findtext(pt, "/KatieTurf"))
		if(findtext(pt, "Wall") || findtext(pt, "Roof"))
			return BUILD_CAT_WALLS
		return BUILD_CAT_FLOORS
	return BUILD_CAT_TERRAIN

/proc/BuildPaletteInit()
	if(buildPalette)
		return buildPalette
	buildPalette = list()
	BuildCustomLoad()
	for(var/datum/build_custom_def/D in customDefs)
		buildPalette += BuildCustomEntry(D)
	for(var/obj/Others/Build/B in Builds)
		if(!B.Creates || !ispath(B.Creates))
			continue
		var/datum/build_entry/E = new
		E.name = B.name
		E.iconF = B.icon
		E.icon_state = B.icon_state
		E.Creates = B.Creates
		E.dirBase = B.dir
		E.category = BuildCategorize(B.Creates)
		E.isCustom = ispath(B.Creates, /turf/CustomTurf) || ispath(B.Creates, /obj/Turfs/CustomObj1)
		BuildEntryFit(E)
		buildPalette += E
	for(var/obj/Others/Build/B in AdminBuilds)
		if(!B.Creates || !ispath(B.Creates))
			continue
		var/datum/build_entry/E = new
		E.name = B.name
		E.iconF = B.icon
		E.icon_state = B.icon_state
		E.Creates = B.Creates
		E.dirBase = B.dir
		E.category = BUILD_CAT_SPECIAL
		BuildEntryFit(E)
		buildPalette += E
	BuildAreaPaintLoad()
	var/datum/build_entry/ZI = new
	ZI.name = "-INDOOR-"
	ZI.iconF = 'HUD/build_white.png'
	ZI.Creates = /area/Inside
	ZI.category = BUILD_CAT_ZONES
	ZI.isZone = 1
	ZI.swatchColor = "#2b4a8f"
	buildPalette += ZI
	var/datum/build_entry/ZO = new
	ZO.name = "-OUTDOOR (MATCH)-"
	ZO.iconF = 'HUD/build_white.png'
	ZO.Creates = /area
	ZO.category = BUILD_CAT_ZONES
	ZO.isZone = 1
	ZO.zoneSmart = 1
	ZO.swatchColor = "#3fae5a"
	buildPalette += ZO
	BuildZonesLoad()
	for(var/datum/build_zone_def/ZD in zoneDefs)
		buildPalette += BuildZoneEntry(ZD)
	var/list/zpaths = list(/area) + subtypesof(/area)
	for(var/p in zpaths)
		if(p == /area/MapperZone)
			continue
		var/datum/build_entry/E = new
		E.name = "-[BuildZoneName(p)]-"
		E.iconF = 'HUD/build_white.png'
		E.Creates = p
		E.category = BUILD_CAT_ZONES
		E.isZone = 1
		var/h = md5("[p]")
		E.swatchColor = "#[copytext(h, 1, 7)]"
		buildPalette += E
	BuildFamiliesInit()
	return buildPalette

/proc/BuildFamPrefix(path)
	var/pt = "[path]"
	var/slash = 0
	for(var/i = length(pt) to 1 step -1)
		if(copytext(pt, i, i + 1) == "/")
			slash = i
			break
	if(!slash)
		return ""
	var/seg = copytext(pt, slash + 1)
	var/cut = length(seg)
	while(cut > 0)
		var/ch = text2ascii(seg, cut)
		if(ch < 48 || ch > 57)
			break
		cut--
	if(cut == length(seg) || cut < 1)
		return ""
	return "[copytext(pt, 1, slash + 1)][copytext(seg, 1, cut + 1)]"

/proc/BuildFamiliesInit()
	buildFamilies = list()
	for(var/datum/build_entry/E in buildPalette)
		E.famKey = ""
		if(E.isZone || E.isCustom || E.category == BUILD_CAT_SPECIAL || !ispath(E.Creates, /turf))
			continue
		var/pre = BuildFamPrefix(E.Creates)
		if(!length(pre))
			continue
		var/k = "[pre]|[BuildMaterialForType(E.Creates)]"
		E.famKey = k
		var/list/fam = buildFamilies[k]
		if(!fam)
			fam = list()
			buildFamilies[k] = fam
		fam += E
	var/list/prune = list()
	for(var/k in buildFamilies)
		var/list/fam = buildFamilies[k]
		if(fam.len < 2)
			for(var/datum/build_entry/E in fam)
				E.famKey = ""
			prune += k
	for(var/k in prune)
		buildFamilies -= k

/proc/BuildFavKey(datum/build_entry/E)
	return "[E.Creates]|[E.name]|[E.icon_state]"

/proc/BuildFavsLoad()
	if(buildFavs)
		return
	buildFavs = list()
	if(!fexists("Saves/BuildFavs.txt"))
		return
	var/raw = file2text("Saves/BuildFavs.txt")
	for(var/line in splittext(raw, "\n"))
		var/list/parts = splittext(line, "\t")
		if(parts.len < 2)
			continue
		var/list/keys = list()
		for(var/i = 2 to parts.len)
			if(length(parts[i]))
				keys += parts[i]
		buildFavs[parts[1]] = keys

/proc/BuildFavsSave()
	if(!buildFavs)
		return
	var/out = ""
	for(var/ck in buildFavs)
		var/list/keys = buildFavs[ck]
		if(!keys || !keys.len)
			continue
		var/line = ck
		for(var/k in keys)
			line += "\t[k]"
		out += "[line]\n"
	if(fexists("Saves/BuildFavs.txt"))
		fdel("Saves/BuildFavs.txt")
	text2file(out, "Saves/BuildFavs.txt")

/proc/BuildFavsFor(ck)
	BuildFavsLoad()
	var/list/keys = buildFavs[ck]
	if(!keys)
		keys = list()
		buildFavs[ck] = keys
	return keys

client/var/datum/build_session/bsession

/datum/build_session
	var
		client/C
		active = 0
		tool = BUILD_PAINT
		datum/build_entry/brush
		brushSize = 1
		sprayDensity = 50
		dirv = SOUTH
		dirty = 0
		list/history = list()
		list/redoStack = list()
		dragging = 0
		list/strokeRolled
		anchorX = 0
		anchorY = 0
		anchorZ = 0
		curveStage = 0
		curveX2 = 0
		curveY2 = 0
		wheelHover = 0
		lastSave = 0
		dragPan = 0
		panLastX = 0
		panLastY = 0
		panDX = 0
		panDY = 0
		list/strokeSet
		list/fillPending
		turf/fillOrigin
		datum/build_entry/fillBrush
		turf/mouseTurf
		list/selectedObjs = list()
		list/selectionImgs = list()
		obj/selDownObj
		list/clipboard = list()
		list/clipboardTurfs = list()
		clipW = 0
		clipH = 0
		pasteMode = 0
		exportStage = 0
		exportPrefab = 0
		exportX1 = 0
		exportY1 = 0
		importStage = 0
		importFile = ""
		importW = 0
		importH = 0
		warpStage = 0
		warpX = 0
		warpY = 0
		warpZ = 0
		autoEdge = 1
		blendEdges = 1
		varied = 0
		selShift = 0
		list/selectedTurfs = list()
		obj/selTurfObj
		smoothStage = 0
		smoothX1 = 0
		smoothY1 = 0
		cpActive = 0
		cpKind = ""
		cpFname = ""
		cpHash = ""
		list/cpStates
		cpIdx = 1
		image/ghostImg
		image/chipImg
		list/previewImgs = list()
		obj/highlightObj
		list/highlightTurfs = list()
		category = BUILD_CAT_TERRAIN
		filter = ""
		scrollRow = 0
		list/filteredEntries = list()
		busy = 0

	New(client/_C)
		C = _C
		..()

	proc
		Toggle()
			if(active)
				Deactivate()
			else
				Activate()

		Activate()
			if(!C?.mob || !IsBuildEligible(C.mob))
				return
			active = 1
			BuildPaletteInit()
			tool = BUILD_PAINT
			RefreshFiltered()
			BuildHUDShow(src)
			C.mob << "Build mode ON."
			BuildPresenceRoster(C, 1)

		Deactivate(disconnect = 0)
			active = 0
			BuildPresenceRoster(C, 0)
			CancelPending()
			ClearGhost()
			ClearSelection()
			ClearTurfSelection()
			BuildHUDHide(src)
			if(dirty > 0)
				dirty = 0
				if(disconnect)
					spawn BuildSaveOrphan("[C?.ckey]")
				else
					spawn BuildSaveMap(C, 1)
			if(!disconnect)
				C?.mob << "Build mode OFF."

		SetTool(t)
			CancelPending()
			tool = t
			BuildHUDRefreshTools(src)

		SetBrush(datum/build_entry/E)
			if(fillPending || dragging || curveStage)
				CancelPending()
			brush = E
			UpdateGhost()
			BuildHUDRefreshHand(src)

		CycleBrushSize(d)
			var/i = (brushSize == 1) ? 1 : ((brushSize == 3) ? 2 : 3)
			i += d
			if(i > 3)
				i = 1
			if(i < 1)
				i = 3
			brushSize = (i == 1) ? 1 : ((i == 2) ? 3 : 5)
			BuildHUDRefreshDigit(src)
			UpdateGhost()

		CycleSprayDensity()
			switch(sprayDensity)
				if(25)
					sprayDensity = 50
				if(50)
					sprayDensity = 75
				else
					sprayDensity = 25

		RotateBrush()
			switch(dirv)
				if(SOUTH)
					dirv = WEST
				if(WEST)
					dirv = NORTH
				if(NORTH)
					dirv = EAST
				else
					dirv = SOUTH
			var/ang = -BuildRotAngle(dirv)
			C?.mob << (ang ? "Brush rotated [ang] degrees clockwise." : "Brush rotation reset.")
			UpdateGhost()

		CancelPending()
			dragging = 0
			curveStage = 0
			pasteMode = 0
			exportStage = 0
			exportPrefab = 0
			importStage = 0
			smoothStage = 0
			warpStage = 0
			cpActive = 0
			cpStates = null
			strokeSet = null
			strokeRolled = null
			fillPending = null
			fillOrigin = null
			fillBrush = null
			ClearPreviews()
			ClearChip()

		RefreshFiltered()
			filteredEntries = list()
			var/mob/M = C?.mob
			var/list/favKeys
			if(category == BUILD_CAT_FAVS)
				favKeys = BuildFavsFor(C?.ckey)
			for(var/datum/build_entry/E in buildPalette)
				if(E.category == BUILD_CAT_SPECIAL && !M?.Admin)
					continue
				if(favKeys)
					if(!(BuildFavKey(E) in favKeys))
						continue
				else if(category != BUILD_CAT_ALL && E.category != category)
					continue
				if(length(filter) && !findtext(E.name, filter))
					continue
				filteredEntries += E
			scrollRow = 0

		ToggleFavorite()
			if(!brush)
				C.mob << "Pick a tile from the palette first - Ctrl+B bookmarks the tile in hand."
				return
			var/list/keys = BuildFavsFor(C.ckey)
			var/k = BuildFavKey(brush)
			if(k in keys)
				keys -= k
				C.mob << "[brush.name] removed from FAVS."
			else
				keys += k
				C.mob << "[brush.name] added to FAVS ([keys.len] saved)."
			BuildFavsSave()
			if(category == BUILD_CAT_FAVS)
				RefreshFiltered()
				BuildHUDRefreshGrid(src)

		ClearTurfSelection()
			for(var/turf/T in selectedTurfs)
				if(selTurfObj)
					T.vis_contents -= selTurfObj
			selectedTurfs = list()

		MakeSelTurfObj()
			if(selTurfObj)
				return
			selTurfObj = new
			selTurfObj.icon = 'HUD/build_white.png'
			selTurfObj.color = "#ffd24a"
			selTurfObj.alpha = 60
			selTurfObj.mouse_opacity = 0
			selTurfObj.density = 0
			selTurfObj.plane = BUILD_PREVIEW_PLANE
			selTurfObj.layer = BUILD_PREVIEW_LAYER
			selTurfObj.Savable = 0
			selTurfObj.gfx_transient_visual = 1
			selTurfObj.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART

		AddTurfSelection(list/turfs)
			MakeSelTurfObj()
			var/added = 0
			for(var/turf/T in turfs)
				if(selectedTurfs.len >= BUILD_SELECT_CAP)
					break
				if(T in selectedTurfs)
					continue
				if(!T.CanBuildOver(C.mob))
					continue
				selectedTurfs += T
				T.vis_contents += selTurfObj
				added++
			return added

		FillSelection()
			if(!selectedTurfs.len)
				C.mob << "No tiles selected. With the SELECT tool: Shift+click wand-selects matching tiles, Shift+drag box-selects by type."
				return
			if(!brush)
				C.mob << "Pick a tile from the palette first."
				return
			if(busy)
				C.mob << "Still applying the previous edit..."
				return
			var/list/todo = selectedTurfs.Copy()
			ClearTurfSelection()
			BuildHUDSetSelName(src, brush ? brush.name : "")
			BuildCommitSet(C, todo, "replace")
			UpdateGhost()

		ClearSelection()
			for(var/image/I in selectionImgs)
				C?.images -= I
			selectionImgs = list()
			selectedObjs = list()

		AddSelect(obj/O)
			if(O in selectedObjs)
				return
			if(selectedObjs.len >= BUILD_SELECT_CAP)
				return
			ToggleSelect(O)

		ToggleSelect(obj/O)
			if(O in selectedObjs)
				var/i = selectedObjs.Find(O)
				selectedObjs.Cut(i, i + 1)
				var/image/old = selectionImgs[i]
				C?.images -= old
				selectionImgs.Cut(i, i + 1)
			else
				selectedObjs += O
				var/image/I = image(O.icon, O, O.icon_state)
				I.plane = BUILD_PREVIEW_PLANE
				I.layer = BUILD_PREVIEW_LAYER
				I.color = "#54ff9f"
				I.alpha = 150
				I.mouse_opacity = 0
				I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
				I.filters = filter(type = "outline", size = 1, color = "#54ff9f")
				I.pixel_x = O.pixel_x
				I.pixel_y = O.pixel_y
				selectionImgs += I
				C?.images += I

		DeleteSelected()
			if(!selectedObjs.len)
				return
			BuildDeleteObjs(C, selectedObjs.Copy())
			ClearSelection()

		CopySelection()
			if(selectedTurfs.len)
				CopyTurfRegion()
				return
			if(!selectedObjs.len)
				C.mob << "Nothing selected to copy. Use the SELECT tool first (Shift+click/drag selects tiles)."
				return
			var/minx = 30000
			var/miny = 30000
			var/maxx = 0
			var/maxy = 0
			clipboard = list()
			clipboardTurfs = list()
			var/n = 0
			for(var/obj/O in selectedObjs)
				if(!O.loc)
					continue
				n++
				if(n > BUILD_PREVIEW_ART_CAP)
					break
				minx = min(minx, O.x)
				miny = min(miny, O.y)
				maxx = max(maxx, O.x)
				maxy = max(maxy, O.y)
				clipboard += list(list("type" = O.type, "icon" = O.icon, "state" = O.icon_state, "dir" = O.dir, "px" = O.pixel_x, "py" = O.pixel_y, "density" = O.density, "opacity" = O.opacity, "layer" = O.layer, "grab" = O.Grabbable, "x" = O.x, "y" = O.y))
			for(var/list/rec in clipboard)
				rec["dx"] = rec["x"] - minx
				rec["dy"] = rec["y"] - miny
			clipW = maxx - minx
			clipH = maxy - miny
			if(n > BUILD_PREVIEW_ART_CAP)
				C.mob << "Copy capped at [BUILD_PREVIEW_ART_CAP] objects."
			C.mob << "Copied [clipboard.len] objects. Ctrl+V to paste, click to stamp, right-click to stop."

		CopyTurfRegion()
			var/minx = 30000
			var/miny = 30000
			var/maxx = 0
			var/maxy = 0
			for(var/turf/T in selectedTurfs)
				minx = min(minx, T.x)
				miny = min(miny, T.y)
				maxx = max(maxx, T.x)
				maxy = max(maxy, T.y)
			clipboard = list()
			clipboardTurfs = list()
			var/objN = 0
			for(var/turf/T in selectedTurfs)
				var/list/rec = list("dx" = T.x - minx, "dy" = T.y - miny, "type" = T.type, "icon" = T.icon, "state" = T.icon_state)
				if(istype(T, /turf/CustomTurf))
					var/turf/CustomTurf/CT = T
					rec["cRoof"] = CT.Roof
					rec["cDensity"] = CT.density
					rec["cOpacity"] = CT.opacity
				clipboardTurfs += list(rec)
				for(var/obj/O in T)
					if(!istype(O, /obj/Turfs) && !istype(O, /obj/KatieObj))
						continue
					objN++
					if(objN > BUILD_PREVIEW_ART_CAP)
						continue
					clipboard += list(list("type" = O.type, "icon" = O.icon, "state" = O.icon_state, "dir" = O.dir, "px" = O.pixel_x, "py" = O.pixel_y, "density" = O.density, "opacity" = O.opacity, "layer" = O.layer, "grab" = O.Grabbable, "dx" = T.x - minx, "dy" = T.y - miny))
			clipW = maxx - minx
			clipH = maxy - miny
			if(objN > BUILD_PREVIEW_ART_CAP)
				C.mob << "Region copy kept the first [BUILD_PREVIEW_ART_CAP] objects."
			C.mob << "Copied a [clipW + 1]x[clipH + 1] region: [clipboardTurfs.len] tiles + [clipboard.len] objects. Ctrl+V to stamp, right-click to stop."

		StartPaste()
			if(!clipboard.len && !clipboardTurfs.len)
				C.mob << "Clipboard is empty. Select objects (or tiles with Shift) and Ctrl+C first."
				return
			CancelPending()
			pasteMode = 1
			ClearGhost()
			if(mouseTurf)
				UpdatePasteGhost(mouseTurf)
			BuildHUDSetSelName(src, clipboardTurfs.len ? "PASTE: [clipboardTurfs.len] TILES + [clipboard.len] OBJS" : "PASTE: [clipboard.len] OBJS")
