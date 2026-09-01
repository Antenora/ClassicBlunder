#define BUILD_LAYER (FLY_LAYER + 3.95)
#define BFONT "font-family:'monogram'; font-size:12pt"
#define BFONT_SM "font-family:'Pixel Operator 8'; font-size:6pt"
#define BR_X 4
#define BR_Y 40
#define BSLOT_X (BR_X + 8)
#define BD_X 58
#define BD_Y 24
#define BGRID_COLS 5
#define BGRID_ROWS 8

/proc/BuildSL(x, d, h)
	var/m = round(x / 32)
	var/q = x - m * 32
	var/D = d + h
	var/kp = round((D + 31) / 32)
	var/p = kp * 32 - D
	return "WEST+[m]:[q],NORTH-[kp - 1]:[p]"

/datum/build_session
	var
		list/hudObjs
		list/swatchObjs
		list/toolBtns
		atom/movable/shud/bhud/handSlot
		atom/movable/shud/bhud/digitObj
		atom/movable/shud/bhud/unsavedObj
		atom/movable/shud/bhud/selnameObj
		atom/movable/shud/bhud/dropObj
		atom/movable/shud/bhud/thumbObj
		atom/movable/shud/bhud/toggleObj
		atom/movable/shud/bhud/coordObj
		list/toggleObjs

/atom/movable/shud/bhud
	layer = BUILD_LAYER

	MouseEntered(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S)
			S.wheelHover = 1
		..()

	MouseExited(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S)
			S.wheelHover = 0
		..()

/atom/movable/shud/bhud/bpanel
	mouse_opacity = 1

	MouseDown(location, control, params)
		usr?.client?.bsession?.PanStart(params)
		..()

	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		usr?.client?.bsession?.PanMove(params)
		..()

	MouseUp(location, control, params)
		usr?.client?.bsession?.PanEnd()
		..()

/datum/build_session
	proc
		PanStart(params)
			var/list/a = C.MouseAbs(params)
			panLastX = a[1]
			panLastY = a[2]
			dragPan = 1

		PanMove(params)
			if(!dragPan || !hudObjs)
				return
			var/list/a = C.MouseAbs(params)
			var/dx = a[1] - panLastX
			var/dy = a[2] - panLastY
			if(!dx && !dy)
				return
			panLastX = a[1]
			panLastY = a[2]
			panDX += dx
			panDY += dy
			C.PanShift(hudObjs, dx, dy)

		PanEnd()
			if(!dragPan)
				return
			dragPan = 0
			C.setPref("bpanX", panDX)
			C.setPref("bpanY", panDY)

/atom/movable/shud/bhud/btool
	icon = 'HUD/ui_slot_available.png'
	mouse_opacity = 1
	var/tool

	Click()
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active)
			return
		if(tool == BUILD_SPRAY && S.tool == BUILD_SPRAY)
			S.CycleSprayDensity()
			BuildHUDSetSelName(S, "SPRAY DENSITY [S.sprayDensity]%")
			return
		S.SetTool(tool)

	MouseEntered(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			if(tool == BUILD_SPRAY)
				BuildHUDSetSelName(S, "SPRAY [S.sprayDensity]%: CLICK AGAIN = DENSITY")
			else
				BuildHUDSetSelName(S, BuildToolHint(tool))
		..()

	MouseExited(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, S.brush ? S.brush.name : "")
		..()

/proc/BuildToolHint(tool)
	switch(tool)
		if(BUILD_PAINT)
			return "PAINT: DRAG. BRUSH SIZE APPLIES"
		if(BUILD_SPRAY)
			return "SPRAY: SCATTER. CLICK AGAIN = DENSITY"
		if(BUILD_LINE)
			return "LINE: DRAG START TO END"
		if(BUILD_CURVE)
			return "CURVE: DRAG, MOVE TO BEND, CLICK"
		if(BUILD_RECT)
			return "RECT: DRAG A BOX"
		if(BUILD_RECT_HOLLOW)
			return "HOLLOW RECT: DRAG A BOX"
		if(BUILD_ELLIPSE)
			return "ELLIPSE: DRAG"
		if(BUILD_FILL)
			return "FILL: CLICK TWICE TO CONFIRM"
		if(BUILD_PICK)
			return "PICK: COPY A TILE OR OBJECT"
		if(BUILD_SELECT)
			return "SELECT: CLICK/BOX. DEL, CTRL+C"
	return "[tool]"

/atom/movable/shud/bhud/bhand
	icon = 'HUD/ui_slot_selected.png'

/atom/movable/shud/bhud/bdigit
	icon = 'HUD/build_digit.png'
	mouse_opacity = 1

	Click()
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active)
			return
		S.CycleBrushSize(1)
		BuildHUDSetSelName(S, "BRUSH SIZE [S.brushSize]")

	MouseEntered(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, "BRUSH SIZE [S.brushSize] - CLICK TO CYCLE")
		..()

	MouseExited(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, S.brush ? S.brush.name : "")
		..()

/atom/movable/shud/bhud/barrow
	mouse_opacity = 1
	var/redo = 0

	Click()
		var/client/CC = usr?.client
		if(!CC?.bsession?.active)
			return
		if(redo)
			BuildRedo(CC)
		else
			BuildUndo(CC)

	MouseEntered(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, redo ? "REDO ([S.redoStack.len])" : "UNDO ([S.history.len])")
		..()

	MouseExited(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, S.brush ? S.brush.name : "")
		..()

/atom/movable/shud/bhud/bdrop
	icon = 'HUD/build_dropdown.png'
	mouse_opacity = 1

	Click()
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active)
			return
		var/i = buildCategories.Find(S.category)
		i = (i % buildCategories.len) + 1
		S.category = buildCategories[i]
		S.RefreshFiltered()
		BuildHUDRefreshGrid(S)
		BuildHUDRefreshDrop(S)

/atom/movable/shud/bhud/bsearch
	icon = 'HUD/build_search.png'
	mouse_opacity = 1

	Click(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active)
			return
		var/list/plist = params2list(params)
		if(plist["right"] == "1")
			S.filter = ""
			S.RefreshFiltered()
			BuildHUDRefreshGrid(S)
			BuildHUDRefreshSearch(S)
			return
		spawn
			var/t = S.C.mob.HUDTextPrompt("Search tiles", S.filter)
			if(isnull(t))
				return
			S.filter = t
			S.RefreshFiltered()
			BuildHUDRefreshGrid(S)
			BuildHUDRefreshSearch(S)

/atom/movable/shud/bhud/bswatch
	mouse_opacity = 1
	var/datum/build_entry/entry

	Click()
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active || !entry)
			return
		S.SetBrush(entry)
		BuildHUDRefreshGrid(S)

	MouseEntered(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active && entry)
			BuildHUDSetSelName(S, entry.name)
		..()

	MouseExited(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, S.brush ? S.brush.name : "")
		..()

/atom/movable/shud/bhud/btrack
	icon = 'HUD/scroll_track.png'
	mouse_opacity = 1

	Click(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active)
			return
		var/list/plist = params2list(params)
		var/iy = text2num(plist["icon-y"])
		if(isnull(iy))
			return
		var/rows = -round(-(S.filteredEntries.len / BGRID_COLS))
		var/maxRow = max(0, rows - BGRID_ROWS)
		S.scrollRow = clamp(round((1 - iy / 206) * maxRow), 0, maxRow)
		BuildHUDRefreshGrid(S)

/atom/movable/shud/bhud/btoggle
	icon = 'HUD/toggle_off_5.png'
	mouse_opacity = 1
	var/mode = "overwrite"

	Click()
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active)
			return
		var/mob/M = S.C.mob
		switch(mode)
			if("overwrite")
				M.BuildOverwrite = !M.BuildOverwrite
			if("autoedge")
				S.autoEdge = !S.autoEdge
			if("blend")
				S.blendEdges = !S.blendEdges
			if("varied")
				S.varied = !S.varied
		BuildHUDRefreshToggles(S)

	MouseEntered(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			switch(mode)
				if("overwrite")
					BuildHUDSetSelName(S, "OVERWRITE: PLACING DELETES OBJS")
				if("autoedge")
					BuildHUDSetSelName(S, "AUTO-EDGE: SMOOTH MY PLACEMENTS")
				if("blend")
					BuildHUDSetSelName(S, "BLEND: MELT SAME-FAMILY TILES")
				if("varied")
					BuildHUDSetSelName(S, "VARIED: SCATTER TILE VARIANTS")
		..()

	MouseExited(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, S.brush ? S.brush.name : "")
		..()

/proc/BuildHUDRefreshToggles(datum/build_session/S)
	if(!S?.toggleObjs)
		return
	for(var/atom/movable/shud/bhud/btoggle/TG in S.toggleObjs)
		var/on = 0
		switch(TG.mode)
			if("overwrite")
				on = S.C?.mob?.BuildOverwrite
			if("autoedge")
				on = S.autoEdge
			if("blend")
				on = S.blendEdges
			if("varied")
				on = S.varied
		TG.icon = on ? 'HUD/toggle_on_5.png' : 'HUD/toggle_off_5.png'

/proc/BuildHUDRefreshOverwrite(datum/build_session/S)
	BuildHUDRefreshToggles(S)

/atom/movable/shud/bhud/bsave
	icon = 'HUD/pbtn.png'
	mouse_opacity = 1

	Click()
		var/datum/build_session/S = usr?.client?.bsession
		if(!S?.active)
			return
		spawn BuildSaveMap(S.C)

/atom/movable/shud/bhud/bnewcustom
	icon = 'HUD/pbtn.png'
	mouse_opacity = 1

	Click()
		var/client/CC = usr?.client
		if(!CC?.bsession?.active)
			return
		spawn BuildCustomDesigner(CC)

	MouseEntered(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, "CREATE A SHARED CUSTOM TILE/OBJECT")
		..()

	MouseExited(location, control, params)
		var/datum/build_session/S = usr?.client?.bsession
		if(S?.active)
			BuildHUDSetSelName(S, S.brush ? S.brush.name : "")
		..()

/proc/BuildHUDAdd(datum/build_session/S, atom/movable/shud/bhud/O, x, d, h)
	O.screen_loc = BuildSL(x, d, h)
	S.hudObjs += O
	S.C.screen += O
	return O

/proc/BuildHUDShow(datum/build_session/S)
	BuildHUDHide(S)
	S.hudObjs = list()
	S.swatchObjs = list()
	S.toolBtns = list()
	var/atom/movable/shud/bhud/O
	O = new/atom/movable/shud/bhud/bpanel
	O.icon = 'HUD/build_rail.png'
	BuildHUDAdd(S, O, BR_X, BR_Y, 506)
	var/ry = BR_Y + 8
	S.handSlot = new/atom/movable/shud/bhud/bhand
	BuildHUDAdd(S, S.handSlot, BSLOT_X, ry, 32)
	ry += 40
	var/list/tools = list(BUILD_PAINT, BUILD_SPRAY, BUILD_LINE, BUILD_CURVE, BUILD_RECT, BUILD_RECT_HOLLOW, BUILD_ELLIPSE, BUILD_FILL, BUILD_PICK, BUILD_SELECT)
	var/list/glyphs = list("paint", "spray", "line", "curve", "rect_fill", "rect_hollow", "ellipse", "fill", "dropper", "select")
	for(var/i = 1 to tools.len)
		var/atom/movable/shud/bhud/btool/B = new
		B.tool = tools[i]
		if(glyphs[i] == "curve")
			B.overlays += image('HUD/build_curve.png', pixel_x = 8, pixel_y = 8)
		else if(glyphs[i] == "spray")
			B.overlays += image('HUD/build_spray.png', pixel_x = 8, pixel_y = 8)
		else
			B.overlays += image('build mode buttons.dmi', icon_state = glyphs[i], pixel_x = 8, pixel_y = 8)
		BuildHUDAdd(S, B, BSLOT_X, ry, 32)
		S.toolBtns += B
		ry += 36
	ry += 2
	S.digitObj = new/atom/movable/shud/bhud/bdigit
	BuildHUDAdd(S, S.digitObj, BR_X + 12, ry, 12)
	ry += 22
	var/atom/movable/shud/bhud/barrow/AU = new
	AU.icon = 'HUD/ui_arrow_left.png'
	BuildHUDAdd(S, AU, BSLOT_X, ry, 32)
	ry += 34
	var/atom/movable/shud/bhud/barrow/AR = new
	AR.redo = 1
	AR.icon = 'HUD/ui_arrow_right.png'
	BuildHUDAdd(S, AR, BSLOT_X, ry, 32)
	O = new/atom/movable/shud/bhud/bpanel
	O.icon = 'HUD/build_drawer.png'
	BuildHUDAdd(S, O, BD_X, BD_Y, 472)
	O = new
	O.icon = 'HUD/build_title.png'
	O.maptext_width = 140
	O.maptext_height = 32
	O.maptext_y = 10
	O.maptext = "<center><span style=\"[BFONT]; -dm-text-outline: 1px #000000; color:#e6f0ff\">BUILD PALETTE</span></center>"
	BuildHUDAdd(S, O, BD_X + 16, BD_Y + 10, 32)
	var/atom/movable/shud/bhud/bnewcustom/NC = new
	NC.maptext_width = 80
	NC.maptext_height = 24
	NC.maptext_y = 5
	NC.maptext = "<center><span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#e6f0ff\">NEW CUSTOM</span></center>"
	BuildHUDAdd(S, NC, BD_X + 164, BD_Y + 14, 24)
	S.dropObj = new/atom/movable/shud/bhud/bdrop
	S.dropObj.maptext_width = 110
	S.dropObj.maptext_height = 18
	S.dropObj.maptext_y = 6
	BuildHUDAdd(S, S.dropObj, BD_X + 16, BD_Y + 46, 18)
	O = new/atom/movable/shud/bhud/bsearch
	O.maptext_width = 104
	O.maptext_height = 18
	O.maptext_y = 6
	BuildHUDAdd(S, O, BD_X + 130, BD_Y + 46, 18)
	BuildHUDRefreshSearchObj(O, S)
	for(var/r = 0 to BGRID_ROWS - 1)
		for(var/c = 0 to BGRID_COLS - 1)
			var/atom/movable/shud/bhud/bswatch/W = new
			BuildHUDAdd(S, W, BD_X + 16 + c * 40, BD_Y + 72 + r * 40, 32)
			S.swatchObjs += W
	var/atom/movable/shud/bhud/btrack/TR = new
	BuildHUDAdd(S, TR, BD_X + 212, BD_Y + 72, 206)
	S.thumbObj = new
	S.thumbObj.icon = 'HUD/scroll_thumb.png'
	BuildHUDAdd(S, S.thumbObj, BD_X + 213, BD_Y + 74, 36)
	S.selnameObj = new
	S.selnameObj.maptext_width = 200
	S.selnameObj.maptext_height = 16
	S.selnameObj.maptext = ""
	BuildHUDAdd(S, S.selnameObj, BD_X + 16, BD_Y + 392, 16)
	S.toggleObjs = list()
	var/list/chipDefs = list("autoedge" = "AUTO-EDGE", "blend" = "BLEND", "varied" = "VARIED", "overwrite" = "OVERWRITE")
	var/ci = 0
	for(var/cm in chipDefs)
		var/atom/movable/shud/bhud/btoggle/TG = new
		TG.mode = cm
		TG.maptext_width = 100
		TG.maptext_height = 12
		TG.maptext_x = 28
		TG.maptext = "<span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#b9c3cd\">[chipDefs[cm]]</span>"
		BuildHUDAdd(S, TG, BD_X + 16, BD_Y + 409 + ci * 14, 9)
		S.toggleObjs += TG
		ci++
	var/atom/movable/shud/bhud/bsave/SV = new
	SV.maptext_width = 80
	SV.maptext_height = 24
	SV.maptext_y = 5
	SV.maptext = "<center><span style=\"[BFONT]; color:#e6f0ff\">SAVE MAP</span></center>"
	BuildHUDAdd(S, SV, BD_X + 152, BD_Y + 413, 24)
	S.unsavedObj = new
	S.unsavedObj.maptext_width = 110
	S.unsavedObj.maptext_height = 14
	BuildHUDAdd(S, S.unsavedObj, BD_X + 152, BD_Y + 441, 14)
	S.coordObj = new
	S.coordObj.maptext_width = 110
	S.coordObj.maptext_height = 14
	BuildHUDAdd(S, S.coordObj, BD_X + 152, BD_Y + 455, 14)
	BuildHUDRefreshToggles(S)
	BuildHUDRefreshTools(S)
	BuildHUDRefreshHand(S)
	BuildHUDRefreshDigit(S)
	BuildHUDRefreshDirty(S)
	BuildHUDRefreshDrop(S)
	BuildHUDRefreshGrid(S)
	S.panDX = text2num("[S.C.getPref("bpanX")]") || 0
	S.panDY = text2num("[S.C.getPref("bpanY")]") || 0
	if(S.panDX || S.panDY)
		S.C.PanShift(S.hudObjs, S.panDX, S.panDY)
	BuildKineticEntrance(S.hudObjs)

/proc/BuildHUDHide(datum/build_session/S)
	if(!S.hudObjs)
		return
	var/client/C = S.C
	for(var/atom/movable/O in S.hudObjs)
		C?.screen -= O
	S.hudObjs = null
	S.swatchObjs = null
	S.toolBtns = null
	S.handSlot = null
	S.digitObj = null
	S.unsavedObj = null
	S.selnameObj = null
	S.dropObj = null
	S.thumbObj = null
	S.toggleObj = null
	S.coordObj = null
	S.toggleObjs = null
	S.wheelHover = 0
	S.dragPan = 0

/proc/BuildKineticEntrance(list/objs)
	for(var/atom/movable/O in objs)
		var/a = O.alpha
		O.alpha = 0
		animate(O, alpha = a, time = 3)

/proc/BuildHUDRefreshTools(datum/build_session/S)
	if(!S.toolBtns)
		return
	for(var/atom/movable/shud/bhud/btool/B in S.toolBtns)
		if(B.tool == S.tool)
			B.icon = 'HUD/ui_slot_selected.png'
			B.filters = filter(type = "outline", size = 1, color = "#f98e36")
		else
			B.icon = 'HUD/ui_slot_available.png'
			B.filters = null

/proc/BuildHUDRefreshHand(datum/build_session/S)
	if(!S.handSlot)
		return
	S.handSlot.overlays = null
	if(S.brush)
		var/image/I
		if(S.brush.thumb)
			I = image(S.brush.thumb, pixel_x = S.brush.pxOff, pixel_y = S.brush.pyOff)
		else
			I = image(S.brush.iconF, icon_state = S.brush.icon_state)
			var/matrix/M = matrix()
			M.Scale(0.75)
			I.transform = M
		S.handSlot.overlays += I
	BuildHUDSetSelName(S, S.brush ? S.brush.name : "")

/proc/BuildHUDRefreshDigit(datum/build_session/S)
	if(!S.digitObj)
		return
	S.digitObj.maptext_width = 24
	S.digitObj.maptext_height = 12
	S.digitObj.maptext_y = 2
	S.digitObj.maptext = "<center><span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#f98e36\">[S.brushSize]</span></center>"

/proc/BuildHUDRefreshDirty(datum/build_session/S)
	if(!S.unsavedObj)
		return
	if(S.dirty > 0)
		S.unsavedObj.maptext = "<span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#f98e36\">UNSAVED: [S.dirty]</span>"
	else
		S.unsavedObj.maptext = "<span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#7f909f\">SAVED</span>"

/proc/BuildHUDRefreshDrop(datum/build_session/S)
	if(!S.dropObj)
		return
	S.dropObj.maptext = "<center><span style=\"[BFONT_SM]; -dm-text-outline: 1px #000000; color:#f98e36\">[S.category]</span></center>"

/proc/BuildHUDRefreshSearch(datum/build_session/S)
	for(var/atom/movable/shud/bhud/bsearch/O in S.hudObjs)
		BuildHUDRefreshSearchObj(O, S)

/proc/BuildHUDRefreshSearchObj(atom/movable/shud/bhud/bsearch/O, datum/build_session/S)
	if(length(S.filter))
		O.maptext = "<center><span style=\"[BFONT_SM]; color:#e6f0ff\">[S.filter]</span></center>"
	else
		O.maptext = "<center><span style=\"[BFONT_SM]; color:#78969f\">SEARCH...</span></center>"

/proc/BuildHUDSetSelName(datum/build_session/S, txt)
	if(!S.selnameObj)
		return
	S.selnameObj.maptext = "<span style=\"[BFONT]; -dm-text-outline: 1px #000000; color:#f98e36\">[txt]</span>"

/proc/BuildHUDRefreshGrid(datum/build_session/S)
	if(!S.swatchObjs)
		return
	var/i = 0
	for(var/atom/movable/shud/bhud/bswatch/W in S.swatchObjs)
		i++
		var/idx = S.scrollRow * BGRID_COLS + i
		if(idx <= S.filteredEntries.len)
			var/datum/build_entry/E = S.filteredEntries[idx]
			W.entry = E
			if(E.thumb)
				W.icon = E.thumb
				W.icon_state = null
			else
				W.icon = E.iconF
				W.icon_state = E.icon_state
			W.color = length(E.swatchColor) ? E.swatchColor : null
			W.alpha = 255
			W.mouse_opacity = 1
			W.pixel_x = E.pxOff
			W.pixel_y = E.pyOff
			if(E == S.brush)
				W.filters = filter(type = "outline", size = 1, color = "#f98e36")
			else
				W.filters = null
		else
			W.entry = null
			W.icon = null
			W.alpha = 0
			W.mouse_opacity = 0
			W.pixel_x = 0
			W.pixel_y = 0
			W.filters = null
	var/rows = -round(-(S.filteredEntries.len / BGRID_COLS))
	var/maxRow = max(0, rows - BGRID_ROWS)
	var/frac = maxRow ? (S.scrollRow / maxRow) : 0
	if(S.thumbObj)
		S.thumbObj.screen_loc = BuildSL(BD_X + 213, BD_Y + 73 + round(frac * 168), 36)
		if(S.panDX || S.panDY)
			S.C.PanShift(list(S.thumbObj), S.panDX, S.panDY)

client/proc/BuildWheelScroll(delta_y)
	var/datum/build_session/S = bsession
	if(!S?.active || !S.swatchObjs || !S.wheelHover)
		return 0
	var/rows = -round(-(S.filteredEntries.len / BGRID_COLS))
	var/maxRow = max(0, rows - BGRID_ROWS)
	if(maxRow <= 0)
		return 1
	S.scrollRow = clamp(S.scrollRow + ((delta_y > 0) ? -1 : 1), 0, maxRow)
	BuildHUDRefreshGrid(S)
	return 1
