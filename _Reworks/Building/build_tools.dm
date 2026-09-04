/datum/build_session
	proc
		ResolveTurf(object, location)
			if(isturf(location))
				return location
			if(isobj(object))
				var/obj/O = object
				var/turf/T = O.loc
				if(isturf(T))
					return T
			return null

		ExpandThickness(list/base)
			if(brushSize <= 1 || !base)
				return base
			var/list/seen = list()
			var/list/out = list()
			for(var/turf/T in base)
				for(var/turf/T2 in BrushDisc(T))
					if(seen[T2])
						continue
					seen[T2] = 1
					out += T2
			return out

		ComputeShape(turf/T)
			var/x2 = clamp(clamp(T.x, anchorX - BUILD_MAX_DIM, anchorX + BUILD_MAX_DIM), 1, world.maxx)
			var/y2 = clamp(clamp(T.y, anchorY - BUILD_MAX_DIM, anchorY + BUILD_MAX_DIM), 1, world.maxy)
			switch(tool)
				if(BUILD_RECT)
					return TurfSquare(anchorX, anchorY, x2, y2, T.z, 0)
				if(BUILD_RECT_HOLLOW)
					return ExpandThickness(TurfSquare(anchorX, anchorY, x2, y2, T.z, 1))
				if(BUILD_LINE)
					return ExpandThickness(TurfLine(anchorX, anchorY, x2, y2, T.z, C.mob))
				if(BUILD_CURVE)
					return ExpandThickness(TurfLine(anchorX, anchorY, x2, y2, T.z, C.mob))
				if(BUILD_ELLIPSE)
					if(anchorX == x2 || anchorY == y2)
						return ExpandThickness(TurfLine(anchorX, anchorY, x2, y2, T.z, C.mob))
					return ExpandThickness(TurfEllipse(anchorX, anchorY, x2, y2, T.z, 0, C.mob))
			return list(T)

		ComputeCurve(turf/ctrl)
			var/list/seen = list()
			var/list/out = list()
			var/cx = 2 * ctrl.x - (anchorX + curveX2) / 2
			var/cy = 2 * ctrl.y - (anchorY + curveY2) / 2
			var/steps = clamp(3 * max(abs(curveX2 - anchorX), abs(curveY2 - anchorY)), 8, 240)
			for(var/i = 0 to steps)
				var/t = i / steps
				var/omt = 1 - t
				var/bx = omt * omt * anchorX + 2 * omt * t * cx + t * t * curveX2
				var/by = omt * omt * anchorY + 2 * omt * t * cy + t * t * curveY2
				var/turf/T = locate(clamp(round(bx + 0.5), 1, world.maxx), clamp(round(by + 0.5), 1, world.maxy), anchorZ)
				if(!T || seen[T])
					continue
				seen[T] = 1
				out += T
			return ExpandThickness(out)

		CaptureBrush(atom/A)
			var/datum/build_entry/E = new
			E.name = "-[A.name]-"
			E.Creates = A.type
			E.dirBase = A.dir
			E.iconF = A.icon
			E.icon_state = A.icon_state
			E.category = BuildCategorize(A.type)
			if(istype(A, /turf/CustomTurf))
				var/turf/CustomTurf/CT = A
				E.isCustom = 1
				E.cDensity = CT.density
				E.cOpacity = CT.opacity
				E.cRoof = CT.Roof
			else if(istype(A, /obj/Turfs/CustomObj1))
				var/obj/Turfs/CustomObj1/O = A
				E.isCustom = 1
				E.cDensity = O.density
				E.cOpacity = O.opacity
				E.cLayer = O.layer
				E.cPixelX = O.pixel_x
				E.cPixelY = O.pixel_y
			BuildEntryFit(E)
			SetBrush(E)
			C.mob << "Picked [E.name]."

		HandleDown(object, location, control, params)
			if(istype(object, /atom/movable/shud))
				return
			var/list/plist = params2list(params)
			if(plist["right"] == "1")
				if(fillPending || dragging || curveStage || pasteMode || exportStage || importStage || smoothStage || warpStage || cpActive)
					CancelPending()
					UpdateGhost()
					C.mob << "Cancelled."
				return
			var/turf/T = ResolveTurf(object, location)
			if(!T)
				return
			if(cpActive)
				if(plist["ctrl"] == "1" || C.macros?.IsPressed("Ctrl"))
					BuildCustomFinish(C)
					return
				cpIdx = (cpIdx % cpStates.len) + 1
				BuildHUDSetSelName(src, "STATE [cpIdx]/[cpStates.len]: [cpStates[cpIdx]]")
				UpdateCustomPickGhost(T)
				return
			if(pasteMode)
				BuildPasteStamp(C, T)
				return
			if(exportStage == 1)
				exportX1 = T.x
				exportY1 = T.y
				anchorZ = T.z
				exportStage = 2
				ShowHighlightSet(list(T))
				C.mob << "EXPORT: corner set. Now click the OPPOSITE corner of the region."
				return
			if(exportStage == 2)
				if(T.z != anchorZ)
					C.mob << "Both corners must be on the same z level."
					return
				exportStage = 0
				var/ex1 = exportX1
				var/ey1 = exportY1
				var/ex2 = T.x
				var/ey2 = T.y
				var/ez = T.z
				ShowHighlightSet(TurfSquare(min(ex1, ex2), min(ey1, ey2), max(ex1, ex2), max(ey1, ey2), ez, 1))
				var/w = abs(ex2 - ex1) + 1
				var/h = abs(ey2 - ey1) + 1
				C.mob << "Region is [w]x[h]; the file lands in [exportPrefab ? "Prefabs" : "Exports"]/."
				var/exdir = exportPrefab ? "Prefabs" : "Exports"
				exportPrefab = 0
				spawn
					sleep(3)
					var/nm = C.mob.HUDTextPrompt(exdir == "Prefabs" ? "Name this prefab" : "Name this export", "export1")
					if(isnull(nm) || !length(nm))
						ClearPreviews()
						UpdateGhost()
						C.mob << "Export cancelled."
						return
					var/fname = "[exdir]/[ckey(nm)].dmm"
					if(busy)
						C.mob << "Build engine is busy; try again in a moment."
						ClearPreviews()
						return
					busy = 1
					C.mob << "Exporting..."
					var/rep
					try
						rep = BuildExportRegion(ex1, ey1, ex2, ey2, ez, fname)
					catch(var/exception/e)
						rep = "Export failed with a runtime error: [e]"
					busy = 0
					C.mob << rep
					if(fexists(fname))
						var/repfile = "[exdir]/[ckey(nm)]_report.txt"
						if(fexists(repfile))
							fdel(repfile)
						text2file(rep, repfile)
					Log("Mapper", "[C.mob] ([C.ckey]) exported map region: [rep]", 1)
					ClearPreviews()
					UpdateGhost()
				return
			if(smoothStage == 1)
				smoothX1 = T.x
				smoothY1 = T.y
				anchorZ = T.z
				smoothStage = 2
				ShowHighlightSet(list(T))
				C.mob << "SMOOTH: corner set. Now click the OPPOSITE corner."
				return
			if(smoothStage == 2)
				if(T.z != anchorZ)
					C.mob << "Both corners must be on the same z level."
					return
				smoothStage = 0
				var/sx1 = min(smoothX1, T.x)
				var/sy1 = min(smoothY1, T.y)
				var/sx2 = max(smoothX1, T.x)
				var/sy2 = max(smoothY1, T.y)
				ShowHighlightSet(TurfSquare(sx1, sy1, sx2, sy2, T.z, 1))
				var/sz = T.z
				spawn
					if(busy)
						C.mob << "Build engine is busy; try again in a moment."
						ClearPreviews()
						return
					busy = 1
					C.mob << "Smoothing [(sx2 - sx1 + 1)]x[(sy2 - sy1 + 1)] region..."
					try
						BuildEdgeSmoothAround(TurfSquare(sx1, sy1, sx2, sy2, sz, 0), 1)
					catch(var/exception/e)
						Log("Mapper", "Smooth region runtime error: [e] on [e.file]:[e.line]", 1)
					busy = 0
					ClearPreviews()
					UpdateGhost()
					C.mob << "Region smoothed."
					Log("Mapper", "[C.mob] ([C.ckey]) smoothed region ([sx1],[sy1])-([sx2],[sy2]) z[sz].", 1)
				return
			if(warpStage == 1)
				warpX = T.x
				warpY = T.y
				warpZ = T.z
				warpStage = 2
				ShowHighlightSet(list(T))
				C.mob << "WARPER: placement set at ([T.x],[T.y],[T.z]). Now click the DESTINATION tile - travel there first if you need to (bookmarks and teleport both work)."
				return
			if(warpStage == 2)
				warpStage = 0
				var/turf/WA = locate(warpX, warpY, warpZ)
				ClearPreviews()
				UpdateGhost()
				if(!WA)
					C.mob << "The warper's placement tile no longer exists. Wizard cancelled."
					return
				if(WA == T)
					C.mob << "The destination can't be the warper's own tile. Wizard cancelled."
					return
				BuildMakeWarperPair(C.mob, WA, T)
				return
			if(importStage)
				var/ox = T.x
				var/oy = T.y
				var/oz = T.z
				if(ox + importW - 1 > world.maxx || oy + importH - 1 > world.maxy)
					C.mob << "The [importW]x[importH] map does not fit there - it would run past the world edge. Pick a spot further down-left."
					return
				importStage = 0
				var/fname = importFile
				ShowHighlightSet(TurfSquare(ox, oy, ox + importW - 1, oy + importH - 1, oz, 1))
				C.mob << "Placing [fname] ([importW]x[importH]) with its bottom-left corner at ([ox],[oy]) z[oz] - the outline shows its footprint."
				spawn
					sleep(3)
					var/confirm = C.mob.HUDTextPrompt("Type YES to import", "")
					if(confirm != "YES")
						ClearPreviews()
						UpdateGhost()
						C.mob << "Import cancelled."
						return
					if(busy)
						C.mob << "Build engine is busy; try again in a moment."
						ClearPreviews()
						return
					busy = 1
					C.mob << "Importing..."
					var/rep
					try
						rep = BuildImportDMM(fname, ox, oy, oz, C.mob)
					catch(var/exception/e)
						rep = "Import failed with a runtime error: [e]"
					busy = 0
					C.mob << rep
					Log("Mapper", "[C.mob] ([C.ckey]) imported map file: [rep]", 1)
					ClearPreviews()
					UpdateGhost()
				return
			switch(tool)
				if(BUILD_PICK)
					if(isobj(object) && !istype(object, /atom/movable/shud))
						CaptureBrush(object)
					else
						CaptureBrush(T)
				if(BUILD_SELECT)
					dragging = 1
					anchorX = T.x
					anchorY = T.y
					anchorZ = T.z
					mouseTurf = T
					selDownObj = null
					selShift = (plist["shift"] == "1")
					if(isobj(object) && (istype(object, /obj/Turfs) || istype(object, /obj/KatieObj)))
						selDownObj = object
				if(BUILD_CURVE)
					if(!brush)
						C.mob << "Pick a tile from the palette first."
						return
					if(curveStage)
						var/list/todo = ComputeCurve(T)
						curveStage = 0
						ClearPreviews()
						BuildCommitSet(C, todo, "curve")
						UpdateGhost()
						return
					dragging = 1
					anchorX = T.x
					anchorY = T.y
					anchorZ = T.z
					mouseTurf = T
					ShowPreviewSet(list(T))
				if(BUILD_PAINT, BUILD_SPRAY)
					if(!brush)
						C.mob << "Pick a tile from the palette first."
						return
					dragging = 1
					anchorZ = T.z
					if(tool == BUILD_SPRAY)
						strokeSet = list()
						strokeRolled = list()
						for(var/turf/T2 in SprayDisc(T))
							strokeRolled[T2] = 1
							if(prob(sprayDensity))
								strokeSet += T2
						if(!strokeSet.len)
							strokeSet += T
					else
						strokeSet = BrushDisc(T)
					mouseTurf = T
					ShowPreviewSet(strokeSet)
				if(BUILD_FILL)
					if(!brush)
						C.mob << "Pick a tile from the palette first."
						return
					if(fillPending && (T in fillPending))
						var/list/todo = fillPending
						var/datum/build_entry/fb = fillBrush
						CancelPending()
						BuildCommitSet(C, todo, "fill", useBrush = fb)
						UpdateGhost()
						return
					CancelPending()
					var/list/found = TurfSpanFill(T, BUILD_MAX_DIM, C.mob)
					if(!found || !found.len)
						return
					fillPending = found
					fillOrigin = T
					fillBrush = brush
					ShowPreviewSet(found)
					ShowChip(T, "[found.len] TILES")
					C.mob << "Fill: [found.len] tiles. Click inside the highlight to confirm, right-click to cancel."
				else
					if(!brush)
						C.mob << "Pick a tile from the palette first."
						return
					dragging = 1
					anchorX = T.x
					anchorY = T.y
					anchorZ = T.z
					mouseTurf = T
					ShowPreviewSet(list(T))

		HandleDrag(over_object, over_location)
			if(!dragging)
				return
			var/turf/T = isturf(over_location) ? over_location : null
			if(!T || T == mouseTurf)
				return
			if(T.z != anchorZ)
				return
			mouseTurf = T
			BuildHUDSetCoord(src, T)
			if(tool == BUILD_PAINT || tool == BUILD_SPRAY)
				var/added = 0
				if(tool == BUILD_SPRAY)
					for(var/turf/T2 in SprayDisc(T))
						if(strokeRolled[T2])
							continue
						strokeRolled[T2] = 1
						if(!prob(sprayDensity))
							continue
						strokeSet += T2
						added = 1
				else
					for(var/turf/T2 in BrushDisc(T))
						if(T2 in strokeSet)
							continue
						strokeSet += T2
						added = 1
				if(added)
					ShowPreviewSet(strokeSet)
			else if(tool == BUILD_SELECT)
				var/x2 = clamp(clamp(T.x, anchorX - BUILD_MAX_DIM, anchorX + BUILD_MAX_DIM), 1, world.maxx)
				var/y2 = clamp(clamp(T.y, anchorY - BUILD_MAX_DIM, anchorY + BUILD_MAX_DIM), 1, world.maxy)
				ShowHighlightSet(TurfSquare(anchorX, anchorY, x2, y2, anchorZ, 1))
			else
				ShowPreviewSet(ComputeShape(T))

		HandleUp(object, location)
			if(!dragging)
				return
			dragging = 0
			var/turf/T = isturf(location) ? location : mouseTurf
			if(T && T.z != anchorZ)
				T = null
			if(tool == BUILD_SELECT)
				SelectRelease(T)
				return
			if(tool == BUILD_CURVE)
				if(T && (T.x != anchorX || T.y != anchorY))
					curveX2 = T.x
					curveY2 = T.y
					curveStage = 1
					C.mob << "Move the cursor to bend the curve, click to place it, right-click to cancel."
				else
					ClearPreviews()
					UpdateGhost()
				return
			var/list/todo
			var/tname = "paint"
			if(tool == BUILD_PAINT || tool == BUILD_SPRAY)
				if(tool == BUILD_SPRAY)
					tname = "spray"
				todo = strokeSet
			else
				tname = lowertext(tool)
				todo = T ? ComputeShape(T) : null
			strokeSet = null
			strokeRolled = null
			ClearPreviews()
			if(todo && todo.len)
				BuildCommitSet(C, todo, tname)
			UpdateGhost()

		SelectRelease(turf/T)
			ClearPreviews()
			var/additive = C.macros?.IsPressed("Ctrl")
			if(selShift)
				selShift = 0
				selDownObj = null
				var/turf/AT = locate(anchorX, anchorY, anchorZ)
				if(!AT)
					return
				if(!additive)
					ClearTurfSelection()
					ClearSelection()
				var/added
				if(!T || (T.x == anchorX && T.y == anchorY))
					added = AddTurfSelection(TurfSpanFill(AT, BUILD_MAX_DIM, C.mob))
				else
					var/x2 = clamp(clamp(T.x, anchorX - BUILD_MAX_DIM, anchorX + BUILD_MAX_DIM), 1, world.maxx)
					var/y2 = clamp(clamp(T.y, anchorY - BUILD_MAX_DIM, anchorY + BUILD_MAX_DIM), 1, world.maxy)
					var/list/match = list()
					for(var/turf/T2 in TurfSquare(anchorX, anchorY, x2, y2, anchorZ, 0))
						if(BuildSameTurf(T2, AT))
							match += T2
					added = AddTurfSelection(match)
				if(selectedTurfs.len >= BUILD_SELECT_CAP)
					C.mob << "Selection capped at [BUILD_SELECT_CAP] tiles."
				BuildHUDSetSelName(src, "TILES: [selectedTurfs.len] (CTRL+F FILLS)")
				C.mob << "Selected [added] [AT.name] tiles ([selectedTurfs.len] total). Ctrl+F fills them with the tile in hand."
				return
			if(selectedTurfs.len && !additive)
				ClearTurfSelection()
			if(!T || (T.x == anchorX && T.y == anchorY))
				var/obj/target = selDownObj
				selDownObj = null
				if(!target)
					var/turf/AT = locate(anchorX, anchorY, anchorZ)
					if(AT)
						for(var/obj/O2 in AT)
							if(istype(O2, /obj/Turfs) || istype(O2, /obj/KatieObj))
								target = O2
				if(additive)
					if(target)
						ToggleSelect(target)
				else if(target && (target in selectedObjs))
					ToggleSelect(target)
				else
					var/had = selectedObjs.len
					ClearSelection()
					if(target)
						ToggleSelect(target)
					else if(!had)
						C.mob << "Nothing selectable on that tile. SELECT works on placed objects; hold Ctrl to add to a selection."
				BuildHUDSetSelName(src, selectedObjs.len ? "SELECTED: [selectedObjs.len] (DEL REMOVES)" : (brush ? brush.name : ""))
				return
			selDownObj = null
			if(!additive)
				ClearSelection()
			var/x2 = clamp(clamp(T.x, anchorX - BUILD_MAX_DIM, anchorX + BUILD_MAX_DIM), 1, world.maxx)
			var/y2 = clamp(clamp(T.y, anchorY - BUILD_MAX_DIM, anchorY + BUILD_MAX_DIM), 1, world.maxy)
			var/before = selectedObjs.len
			for(var/turf/T2 in TurfSquare(anchorX, anchorY, x2, y2, anchorZ, 0))
				for(var/obj/O2 in T2)
					if(istype(O2, /obj/Turfs) || istype(O2, /obj/KatieObj))
						AddSelect(O2)
			var/got = selectedObjs.len - before
			if(selectedObjs.len >= BUILD_SELECT_CAP)
				C.mob << "Selection capped at [BUILD_SELECT_CAP] objects."
			BuildHUDSetSelName(src, "SELECTED: [selectedObjs.len] (DEL REMOVES)")
			C.mob << "Box-selected [got] objects ([selectedObjs.len] total)."

		HandleEntered(location)
			if(!isturf(location))
				return
			BuildHUDSetCoord(src, location)
			if(cpActive)
				var/turf/T = location
				if(mouseTurf != T)
					mouseTurf = T
					UpdateCustomPickGhost(T)
				return
			if(pasteMode)
				var/turf/T = location
				if(mouseTurf != T)
					mouseTurf = T
					UpdatePasteGhost(T)
				return
			if(tool == BUILD_CURVE && curveStage)
				var/turf/T = location
				if(T.z == anchorZ && mouseTurf != T)
					mouseTurf = T
					ShowPreviewSet(ComputeCurve(T))
				return
			if(mouseTurf == location && ghostImg)
				return
			mouseTurf = location
			UpdateGhost()

		HandleExited(location)
			if(dragging || fillPending || curveStage || pasteMode || cpActive)
				return
			if(mouseTurf == location)
				mouseTurf = null
				ClearGhost()
				ClearPreviews()

		WalkPaint()
			if(tool != BUILD_PAINT)
				return
			if(!brush || dragging || fillPending)
				return
			var/turf/T = C.mob?.loc
			if(!isturf(T))
				return
			BuildCommitSet(C, list(T), "walk", 1)

client
	MouseDown(object, location, control, params)
		if(bsession?.active)
			bsession.HandleDown(object, location, control, params)
		..()

	MouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
		if(bsession?.active)
			bsession.HandleDrag(over_object, over_location)
		..()

	MouseUp(object, location, control, params)
		if(bsession?.active)
			bsession.HandleUp(object, location)
		..()

	MouseEntered(object, location, control, params)
		if(bsession?.active)
			bsession.HandleEntered(location)
		..()

	MouseExited(object, location, control, params)
		if(bsession?.active)
			bsession.HandleExited(location)
		..()

client/proc/BuildSessionToggle()
	if(!bsession)
		bsession = new(src)
	bsession.Toggle()

mob/verb/Build_Undo()
	set hidden = 1
	if(client?.bsession?.active)
		BuildUndo(client)

mob/verb/Build_Redo()
	set hidden = 1
	if(client?.bsession?.active)
		BuildRedo(client)

mob/verb/Build_Rotate()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.RotateBrush()

mob/verb/Build_Cancel()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.CancelPending()
		client.bsession.UpdateGhost()

mob/verb/Build_Delete_Selected()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.DeleteSelected()

mob/verb/Build_Fill_Selection()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.FillSelection()

mob/verb/Build_Favorite()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.ToggleFavorite()

mob/verb/Build_Copy()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.CopySelection()

mob/verb/Build_Paste()
	set hidden = 1
	if(client?.bsession?.active)
		client.bsession.StartPaste()
