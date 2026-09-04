/datum/build_session
	proc
		MakePreviewImage(turf/T)
			var/image/I = image(brush.iconF, T, brush.icon_state)
			if(ispath(brush.Creates, /obj))
				I.dir = BuildPlacedDir(brush, dirv)
			I.plane = BUILD_PREVIEW_PLANE
			I.layer = BUILD_PREVIEW_LAYER
			I.alpha = 150
			if(length(brush.swatchColor))
				I.color = brush.swatchColor
				I.alpha = 110
			I.mouse_opacity = 0
			I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
			return I

		UpdateGhost()
			if(!active || !brush || !mouseTurf || dragging || fillPending)
				ClearGhost()
				if(!dragging && !fillPending)
					ClearPreviews()
				return
			var/image/I = MakePreviewImage(mouseTurf)
			var/valid = mouseTurf.CanBuildOver(C.mob)
			I.filters = filter(type = "outline", size = 1, color = valid ? "#54ff9f" : "#ff5a5a")
			C.images += I
			if(ghostImg)
				C.images -= ghostImg
			ghostImg = I
			if(tool == BUILD_SPRAY)
				var/list/disc = SprayDisc(mouseTurf)
				disc -= mouseTurf
				ShowHighlightSet(disc)
			else if(tool == BUILD_PAINT && brushSize > 1)
				var/list/disc = BrushDisc(mouseTurf)
				disc -= mouseTurf
				ShowPreviewSet(disc)
			else
				ClearPreviews()

		ClearGhost()
			if(ghostImg)
				C?.images -= ghostImg
				ghostImg = null

		ShowPreviewSet(list/turfs)
			var/n = 0
			for(var/turf/T in turfs)
				n++
			if(n > BUILD_PREVIEW_ART_CAP)
				for(var/image/I in previewImgs)
					C.images -= I
				previewImgs = list()
				ShowHighlightSet(turfs)
				return
			var/list/fresh = list()
			for(var/turf/T in turfs)
				if(!T.CanBuildOver(C.mob))
					continue
				var/image/I = MakePreviewImage(T)
				fresh += I
			for(var/image/I in fresh)
				C.images += I
			for(var/image/I in previewImgs)
				C.images -= I
			previewImgs = fresh
			ClearHighlightSet()

		MakeHighlightObj()
			if(highlightObj)
				return
			highlightObj = new
			highlightObj.icon = 'HUD/build_white.png'
			highlightObj.color = "#54ff9f"
			highlightObj.alpha = 70
			highlightObj.mouse_opacity = 0
			highlightObj.density = 0
			highlightObj.plane = BUILD_PREVIEW_PLANE
			highlightObj.layer = BUILD_PREVIEW_LAYER
			highlightObj.Savable = 0
			highlightObj.gfx_transient_visual = 1
			highlightObj.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART

		ShowHighlightSet(list/turfs)
			MakeHighlightObj()
			var/list/freshMap = list()
			for(var/turf/T in turfs)
				if(!T.CanBuildOver(C.mob))
					continue
				freshMap[T] = 1
			for(var/turf/T in highlightTurfs)
				if(freshMap[T])
					freshMap[T] = 2
				else
					T.vis_contents -= highlightObj
			var/list/fresh = list()
			for(var/turf/T in freshMap)
				fresh += T
				if(freshMap[T] == 1)
					T.vis_contents += highlightObj
			highlightTurfs = fresh

		ClearHighlightSet()
			if(highlightObj)
				for(var/turf/T in highlightTurfs)
					T.vis_contents -= highlightObj
			highlightTurfs = list()

		ClearPreviews()
			for(var/image/I in previewImgs)
				C?.images -= I
			previewImgs = list()
			ClearHighlightSet()

		ShowChip(turf/T, txt)
			var/image/I = image('HUD/build_chip.png', T)
			I.plane = BUILD_PREVIEW_PLANE
			I.layer = BUILD_PREVIEW_LAYER
			I.pixel_y = 36
			I.pixel_x = -28
			I.mouse_opacity = 0
			I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
			I.maptext_width = 88
			I.maptext_height = 20
			I.maptext_x = 0
			I.maptext_y = 3
			I.maptext = "<center><span style=\"font-family:'monogram'; font-size:12pt; color:#e6f0ff\">[txt]</span></center>"
			C.images += I
			if(chipImg)
				C.images -= chipImg
			chipImg = I

		ClearChip()
			if(chipImg)
				C?.images -= chipImg
				chipImg = null

		UpdateCustomPickGhost(turf/T)
			if(!cpActive || !T || !cpStates)
				return
			var/image/I = image(file(cpFname), T, cpStates[cpIdx])
			I.plane = BUILD_PREVIEW_PLANE
			I.layer = BUILD_PREVIEW_LAYER
			I.alpha = 220
			I.mouse_opacity = 0
			I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
			I.filters = filter(type = "outline", size = 1, color = "#8be9ff")
			C.images += I
			if(ghostImg)
				C.images -= ghostImg
			ghostImg = I
			ShowChip(T, "[cpIdx]/[cpStates.len]")

		UpdatePasteGhost(turf/T)
			if(!pasteMode || !T)
				return
			var/ax = T.x - round(clipW / 2)
			var/ay = T.y - round(clipH / 2)
			if(clipboardTurfs.len)
				var/list/foot = list()
				for(var/list/rec in clipboardTurfs)
					var/fx = ax + rec["dx"]
					var/fy = ay + rec["dy"]
					if(fx < 1 || fy < 1 || fx > world.maxx || fy > world.maxy)
						continue
					var/turf/FT = locate(fx, fy, T.z)
					if(FT)
						foot += FT
				ShowHighlightSet(foot)
			var/list/fresh = list()
			for(var/list/rec in clipboard)
				var/gx = ax + rec["dx"]
				var/gy = ay + rec["dy"]
				if(gx < 1 || gy < 1 || gx > world.maxx || gy > world.maxy)
					continue
				var/turf/TT = locate(gx, gy, T.z)
				if(!TT)
					continue
				var/image/I = image(rec["icon"], TT, rec["state"])
				I.dir = rec["dir"]
				I.pixel_x = rec["px"]
				I.pixel_y = rec["py"]
				I.plane = BUILD_PREVIEW_PLANE
				I.layer = BUILD_PREVIEW_LAYER
				I.alpha = 150
				I.mouse_opacity = 0
				I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
				if(!TT.CanBuildOver(C.mob))
					I.color = "#ff5a5a"
				fresh += I
			for(var/image/I in fresh)
				C.images += I
			for(var/image/I in previewImgs)
				C.images -= I
			previewImgs = fresh

		SprayDisc(turf/T)
			var/r = (brushSize == 1) ? 2 : ((brushSize == 3) ? 3 : 4)
			var/list/out = list()
			for(var/dx = -r to r)
				for(var/dy = -r to r)
					if(dx * dx + dy * dy > r * r + 1)
						continue
					var/turf/T2 = locate(T.x + dx, T.y + dy, T.z)
					if(T2)
						out += T2
			return out

		BrushDisc(turf/T)
			var/list/out = list(T)
			if(brushSize <= 1)
				return out
			var/r = (brushSize == 3) ? 1 : 2
			for(var/dx = -r to r)
				for(var/dy = -r to r)
					if(dx == 0 && dy == 0)
						continue
					if(brushSize == 5 && abs(dx) == 2 && abs(dy) == 2)
						continue
					var/turf/T2 = locate(T.x + dx, T.y + dy, T.z)
					if(T2)
						out += T2
			return out
