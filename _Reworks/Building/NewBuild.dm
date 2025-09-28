
#define NOT_AN_ICON 1
#define DIMENSIONS 2
#define FILE_SIZE 3
proc/TickMult(n=1)
	if(n<=0) return 0
	var/rounded=round(n,world.tick_lag)
	if(rounded>n) rounded-=world.tick_lag
	var/decimals=n-rounded
	if(prob(decimals * 100 / world.tick_lag)) rounded+=world.tick_lag

	rounded -= 0.001 //eliminate floating point errors test August 22nd 2017 dunno if it will work but its to stop missed frames

	return rounded

mob/var/hudColor = "#f98e36"
mob/proc/SetHUDColor()
	var/c = input(src, "Pick a color", "Targeting Color") as color
	if(!c) return
	hudColor = c

turf/proc/CanBuildOver(mob/M)
	return M.Admin || M.Mapper

proc/IsBuildEligible(mob/M)
	return M.Admin || M.Mapper

client
	var
		buildMode = 0
		buildTool = BUILD_PAINT
		buildType = BUILD_TURFS
		painting = 0
		buildDir = SOUTH
		list/paintedTurfs
		list/selectedObjects
		obj/highlight
		list/highlightedAtoms = list()
		buildX = 1
		buildY = 1
		paintLock = 0
		lastBrushUpdate = 0
		turf/mouseTurf

	proc
		BuildModeToggle()
			buildMode = !buildMode
			if(buildMode) ActivateBuildMode()
			else DisableBuildMode()

		ActivateBuildMode()
			if(!highlight) CreateHighlight()
			UpdateHighlightColor()
			sleep(world.tick_lag)
			buildTool = BUILD_PAINT
			ClearSelection()
			mob.GenerateHUD()

		DisableBuildMode()
			mob.RemoveTarget()
			mouseTurf = null
			ClearHighlights()
			mob.GenerateHUD()

		CreateHighlight()
			highlight = new()
			highlight.icon = 'outline.dmi'
			highlight.invisibility = 2
			highlight.layer = 10
			highlight.pixel_w = -1
			highlight.pixel_z = -1
			highlight.plane = 3

		UpdateHighlightColor()
			highlight.color = mob?.hudColor

		AddHighlight(atom/A)
			if(!A || (!isturf(A) && !istype(A, /obj/Turfs))) return
			A:vis_contents += highlight
			highlightedAtoms |= A

		RemoveHighlight(atom/A)
			if(!A || (!isturf(A) && !istype(A, /obj/Turfs))) return
			A:vis_contents.Remove(highlight)
			highlightedAtoms.Remove(A)

		ClearHighlights()
			for(var/atom/A in highlightedAtoms)
				A:vis_contents -= highlight

		CanPaintTurfs()
			return buildMode && mob.Target && !paintLock && islist(paintedTurfs)

		CancelBuild()
			buildMode = 0
			mob.RemoveTarget()
			PaintTurfs()
			ClearSelection()
			buildMode = 1

		ClearSelection()
			selectedObjects = list()

		OffsetSelections(axis, direction)
			for(var/obj/Turfs/O in selectedObjects)
				if(axis == "x")
					O.pixel_x += 1 * direction
				else
					O.pixel_y += 1 * direction

		IsValidTurf(turf/T)
			return T && isturf(T) && T.CanBuildOver(mob)

		IsValidObject(obj/O)
			return O && istype(O, /obj/Turfs) && (mob.Admin || O:Builder == ckey)

		PaintTurfs()
			set waitfor = FALSE
			set background = TRUE
			while(paintLock) sleep(world.tick_lag)
			ClearSelection()
			if(buildMode)
				paintLock = 1
				for(var/turf/T in paintedTurfs)
					if(mob.Target&&istype(mob.Target,/obj/Others/Build))
						Build_Lay(mob.Target, mob, T.x, T.y, T.z)
				paintLock = 0
			ClearHighlights()
			ClearSelection()
			paintedTurfs = list()

	MouseDown(object, location, control, params)
		if(IsValidObject(object))
			var/obj/Turfs/O = object
			if(buildTool == BUILD_SELECT)
				selectedObjects |= O
				AddHighlight(O)
				return
		if(CanPaintTurfs() && IsValidTurf(location))
			lastBrushUpdate = world.time
			var/turf/T = location
			mouseTurf = T
			RemoveHighlight(T)
			paintedTurfs = list()
			buildX = T.x
			buildY = T.y
			if(buildTool == BUILD_FILL)
				paintLock = 1
				spawn
					paintedTurfs = TurfSpanFill(T, BUILD_MAX_DIM, mob)
					paintLock = 0
			else if(buildTool in list(BUILD_PAINT, BUILD_RECT, BUILD_RECT_HOLLOW, BUILD_LINE))
				paintLock = 1
				paintedTurfs.Add(T)
				AddHighlight(T)
				paintLock = 0
			else if(buildTool == BUILD_PICK)
				var/obj/Others/Build/B=new
				B.Creates=T.type
				B.name="-[T.name]-"
				if(istype(T,/turf/CustomTurf))
					usr.CustomTurfIcon=T.icon
					usr.CustomTurfState=T.icon_state
					usr.CustomTurfRoof = T:Roof
					usr.CustomTurfDensity=T.density
					usr.CustomTurfOpacity=T.opacity
				else
					B.icon=T.icon
					B.icon_state=T.icon_state
				usr.RemoveTarget()
				usr.Target=B
				return

		..()

	MouseUp(object, location, control, params)
		if(buildMode)
			if(IsValidObject(object))
				var/obj/Turfs/O = object
				if(buildTool == BUILD_PICK)
					var/obj/Others/Build/B=new
					B.Creates=O
					B.name="-[O.name]-"
					if(istype(O,/obj/Turfs/CustomObj1))
						usr.CustomObj1Icon=O.icon
						usr.CustomObj1State=O.icon_state
						usr.CustomObj1Layer=O.layer
						usr.CustomObj1Density=O.density
						usr.CustomObj1X=O.pixel_x
						usr.CustomObj1Y=O.pixel_y
						usr.CustomObjEdge = O:edge
					else
						B.icon=O.icon
						B.icon_state=O.icon_state
					mob.Target = B
				return
			if(buildTool != BUILD_SELECT)
				PaintTurfs()
		..()

	MouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
		if(buildMode)
			if(IsValidObject(over_object))
				var/obj/Turfs/O = over_object
				if(buildTool == BUILD_SELECT)
					selectedObjects |= O
					AddHighlight(O)
					return
			var/turf/T = over_location

			if(CanPaintTurfs() && IsValidTurf(T) && mouseTurf != T)
				mouseTurf = T
				if(!paintedTurfs || !islist(paintedTurfs)) paintedTurfs = list()
				var/x2 = clamp(clamp(T.x, buildX - BUILD_MAX_DIM, buildX + BUILD_MAX_DIM), 1, world.maxx)
				var/y2 = clamp(clamp(T.y, buildY - BUILD_MAX_DIM, buildY + BUILD_MAX_DIM), 1, world.maxy)
				if(buildTool == BUILD_PAINT && !(T in paintedTurfs))
					paintLock = 1
					paintedTurfs.Add(T)
					AddHighlight(T)
					paintLock = 0
				else if(buildTool == BUILD_RECT || buildTool == BUILD_RECT_HOLLOW)
					paintLock = 1
					spawn
						var/isHollow = (buildTool == BUILD_RECT_HOLLOW)
						ClearHighlights()
						paintedTurfs = TurfSquare(buildX, buildY, x2, y2, T.z, isHollow)
						for(var/turf/T2 in paintedTurfs)
							if(T2.CanBuildOver(mob))
								AddHighlight(T2)
							else paintedTurfs.Remove(T2)
						paintLock = 0
				else if(buildTool == BUILD_LINE)
					paintLock = 1
					spawn
						ClearHighlights()
						paintedTurfs = TurfLine(buildX, buildY, x2, y2, T.z, mob)
						paintLock = 0
				else if(buildTool == BUILD_ELLIPSE)
					paintLock = 1
					spawn
						ClearHighlights()
						if(buildX == x2 || buildY == y2)
							paintedTurfs = TurfLine(buildX, buildY, x2, y2, T.z, mob)
						else
							paintedTurfs = TurfEllipse(buildX, buildY, T.x, T.y, T.z, 0, mob)
						paintLock = 0
		..()

	MouseEntered(object, location, control, params)
		if(buildMode && isturf(location) && mouseTurf != location)
			mouseTurf = location
			AddHighlight(location)
		..()

	MouseExited(object, location, control, params)
		if(buildMode&&!paintLock)
			ClearHighlights()
		..()