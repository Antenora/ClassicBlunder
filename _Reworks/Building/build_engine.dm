#define BUILD_MERGE_CAP 300
#define BUILD_JOURNAL "Saves/BuildJournal.txt"

/proc/BuildJournalIconPath(ic)
	if(!ic || !isfile(ic))
		return ""
	var/p = "[ic]"
	if(!fexists(p))
		return ""
	return p

/proc/BuildJournalTurfLine(list/rec, revert)
	var/pre = revert ? "old" : "new"
	var/tp = rec["[pre]Type"]
	if(!tp)
		return ""
	var/roof = rec["[pre]Roof"]
	return jointext(list("TS", "[rec["x"]]", "[rec["y"]]", "[rec["z"]]", "[tp]", BuildJournalIconPath(rec["[pre]Icon"]), BuildDmmEscape("[rec["[pre]State"]]"), "[rec["[pre]Density"] || 0]", "[rec["[pre]Opacity"] || 0]", "[roof || 0]", "[rec["[pre]FlyOver"] || 0]", "[rec["[pre]Destructable"] || 0]", "[rec["[pre]Shallow"] || 0]", BuildDmmEscape("[rec["[pre]Builder"] || ""]")), "\t")

/proc/BuildJournalObjLine(atom/movable/O, x, y, z, remove)
	if(!O)
		return ""
	if(remove)
		return jointext(list("OD", "[x]", "[y]", "[z]", "[O.type]", BuildDmmEscape("[O.icon_state]")), "\t")
	var/obj/OB = O
	return jointext(list("OC", "[x]", "[y]", "[z]", "[O.type]", BuildJournalIconPath(O.icon), BuildDmmEscape("[O.icon_state]"), "[O.dir]", "[OB.pixel_x]", "[OB.pixel_y]", "[OB.layer]", "[O.density]", "[O.opacity]", "[OB.Grabbable]", BuildDmmEscape("[OB.Builder || ""]")), "\t")

/proc/BuildJournalAction(datum/build_action/A, revert = 0)
	if(!A || !A.count)
		return
	var/list/lines = list()
	for(var/list/rec in A.turfRecs)
		var/l = BuildJournalTurfLine(rec, revert)
		if(length(l))
			lines += l
		for(var/list/krec in rec["killed"])
			var/atom/movable/O = krec["obj"]
			var/l2 = BuildJournalObjLine(O, krec["x"], krec["y"], krec["z"], !revert)
			if(length(l2))
				lines += l2
	for(var/list/rec in A.createdObjs)
		var/atom/movable/O = rec["obj"]
		var/l = BuildJournalObjLine(O, rec["x"], rec["y"], rec["z"], revert)
		if(length(l))
			lines += l
	for(var/list/rec in A.deletedObjs)
		var/atom/movable/O = rec["obj"]
		var/l = BuildJournalObjLine(O, rec["x"], rec["y"], rec["z"], !revert)
		if(length(l))
			lines += l
	for(var/list/rec in A.areaRecs)
		var/p = revert ? rec["oldArea"] : rec["newArea"]
		if(length("[p]"))
			lines += jointext(list("AS", "[rec["x"]]", "[rec["y"]]", "[rec["z"]]", "[p]"), "\t")
	if(!lines.len)
		return
	text2file(jointext(lines, "\n"), BUILD_JOURNAL)

/proc/BuildJournalReplay()
	set waitfor = FALSE
	set background = TRUE
	if(!fexists(BUILD_JOURNAL))
		return
	var/t = file2text(BUILD_JOURNAL)
	if(!t || !length(t))
		fdel(BUILD_JOURNAL)
		return
	var/applied = 0
	var/skipped = 0
	var/n = 0
	for(var/line in splittext(t, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 6)
			continue
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
		var/x = text2num(f[2])
		var/y = text2num(f[3])
		var/z = text2num(f[4])
		var/turf/T = locate(x, y, z)
		if(!T)
			skipped++
			continue
		if(f[1] == "AS")
			BuildAreaPaintLoad()
			if(BuildAreaSetId(T, f[5]))
				applied++
			areaPaintMap["[x],[y],[z]"] = f[5]
			continue
		var/tp = text2path(f[5])
		if(!tp)
			skipped++
			continue
		if(f[1] == "TS" && f.len >= 14)
			BuildUntrackTurf(T)
			var/turf/NT = new tp(T)
			if(length(f[6]) && fexists(f[6]))
				NT.icon = file(f[6])
			var/st = BuildDmmUnescape(f[7])
			if(length(st))
				NT.icon_state = st
			NT.density = text2num(f[8]) || 0
			NT.opacity = text2num(f[9]) || 0
			if(istype(NT, /turf/CustomTurf))
				var/turf/CustomTurf/CT = NT
				CT.Roof = text2num(f[10]) || 0
				CT.InitialType = "/turf/CustomTurf"
			NT.FlyOverAble = text2num(f[11]) || 0
			NT.Destructable = text2num(f[12]) || 0
			NT.Shallow = text2num(f[13]) || 0
			NT.Builder = BuildDmmUnescape(f[14])
			if(NT.Builder)
				if(istype(NT, /turf/CustomTurf))
					CustomTurfs += NT
				else
					Turfs += NT
			LightingRecomputeNear(NT)
			applied++
		else if(f[1] == "OC" && f.len >= 15)
			var/obj/O = new tp(T)
			if(length(f[6]) && fexists(f[6]))
				O.icon = file(f[6])
			O.icon_state = BuildDmmUnescape(f[7])
			O.dir = text2num(f[8]) || SOUTH
			O.pixel_x = text2num(f[9]) || 0
			O.pixel_y = text2num(f[10]) || 0
			O.layer = text2num(f[11]) || initial(O.layer)
			O.density = text2num(f[12]) || 0
			O.opacity = text2num(f[13]) || 0
			O.Grabbable = text2num(f[14]) || 0
			O.Builder = BuildDmmUnescape(f[15])
			O.Savable = 1
			worldObjectList += O
			GfxRefreshStructureMetadata(O)
			applied++
		else if(f[1] == "OD")
			var/st = BuildDmmUnescape(f[6])
			for(var/obj/O2 in T)
				if(O2.type == tp && (!length(st) || O2.icon_state == st))
					if(O2 in worldObjectList)
						worldObjectList -= O2
					O2.loc = null
					applied++
					break
	var/list/touched = list()
	for(var/line in splittext(t, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len >= 5 && f[1] == "TS")
			var/turf/TT = locate(text2num(f[2]), text2num(f[3]), text2num(f[4]))
			if(TT)
				touched += TT
	if(touched.len)
		BuildEdgeSmoothAround(touched, 1)
	Log("Mapper", "Build journal replayed after unclean shutdown: [applied] entries applied, [skipped] skipped.", 1)
	world << "<small>Server: recovered [applied] unsaved build edits from the journal."
	BuildSaveWorldData()
	if(fexists(BUILD_JOURNAL))
		fdel(BUILD_JOURNAL)

/datum/build_action
	var
		name = ""
		mergeKey = ""
		count = 0
		undone = 0
		list/turfRecs = list()
		list/createdObjs = list()
		list/deletedObjs = list()
		list/areaRecs = list()

/proc/BuildLimboRec(atom/movable/O)
	var/list/rec = list("obj" = O, "x" = O.x, "y" = O.y, "z" = O.z)
	O.loc = null
	return rec

/proc/BuildRestoreRec(list/rec)
	var/atom/movable/O = rec["obj"]
	if(O)
		O.loc = locate(rec["x"], rec["y"], rec["z"])

/proc/BuildUntrackTurf(turf/T)
	if(!T || !T.Builder)
		return
	if(istype(T, /turf/CustomTurf))
		CustomTurfs -= T
	else
		Turfs -= T

/proc/BuildCaptureTurf(turf/T)
	var/list/rec = list()
	rec["x"] = T.x
	rec["y"] = T.y
	rec["z"] = T.z
	rec["oldType"] = T.type
	rec["oldDensity"] = T.density
	rec["oldOpacity"] = T.opacity
	rec["oldBuilder"] = T.Builder
	rec["oldShallow"] = T.Shallow
	rec["oldFlyOver"] = T.FlyOverAble
	rec["oldDestructable"] = T.Destructable
	if(istype(T, /turf/CustomTurf))
		var/turf/CustomTurf/CT = T
		rec["oldIcon"] = CT.icon
		rec["oldState"] = CT.icon_state
		rec["oldRoof"] = CT.Roof
	return rec

/proc/BuildApplyTurf(client/C, list/rec, datum/build_entry/E)
	var/mob/M = C.mob
	var/turf/T = locate(rec["x"], rec["y"], rec["z"])
	if(M.BuildOverwrite)
		for(var/obj/Turfs/O in T)
			if(!istype(O, /obj/Special/Teleporter2))
				rec["killed"] += list(BuildLimboRec(O))
		for(var/obj/KatieObj/O in T)
			rec["killed"] += list(BuildLimboRec(O))
	if(M.WarperOverwrite)
		for(var/obj/Special/Teleporter2/O in T)
			rec["killed"] += list(BuildLimboRec(O))
	BuildUntrackTurf(T)
	var/turf/C2 = new E.Creates(T)
	if(istype(C2, /turf/CustomTurf))
		var/turf/CustomTurf/CT = C2
		CT.InitialType = "/turf/CustomTurf"
		if(E.iconF)
			CT.icon = E.iconF
		if(E.icon_state)
			CT.icon_state = E.icon_state
		CT.Roof = E.cRoof
		CT.density = E.cDensity
		CT.opacity = E.cOpacity
	if(istype(C2, /turf/Special/EventStars))
		C2.icon_state = "[rand(1, 2500)]"
	C2.Builder = M.ckey
	if(M.UnFlyable)
		C2.FlyOverAble = FALSE
		C2.density = TRUE
	else
		C2.FlyOverAble = 1
	C2.Destructable = M.TurfInvincible ? 0 : 1
	if(M.ShallowMode)
		C2.Shallow = 1
	if(istype(C2, /turf/CustomTurf))
		CustomTurfs += C2
	else
		Turfs += C2
	rec["newRef"] = C2
	rec["newType"] = C2.type
	rec["newIcon"] = C2.icon
	rec["newState"] = C2.icon_state
	rec["newDensity"] = C2.density
	rec["newOpacity"] = C2.opacity
	rec["newBuilder"] = C2.Builder
	rec["newShallow"] = C2.Shallow
	rec["newFlyOver"] = C2.FlyOverAble
	rec["newDestructable"] = C2.Destructable
	if(istype(C2, /turf/CustomTurf))
		var/turf/CustomTurf/CT = C2
		rec["newRoof"] = CT.Roof
	LightingRecomputeNear(C2)
	return C2

/proc/BuildReapplyTurf(list/rec)
	var/turf/T = locate(rec["x"], rec["y"], rec["z"])
	BuildUntrackTurf(T)
	var/tp = rec["newType"]
	var/turf/C2 = new tp(T)
	C2.icon = rec["newIcon"]
	C2.icon_state = rec["newState"]
	C2.density = rec["newDensity"]
	C2.opacity = rec["newOpacity"]
	C2.Builder = rec["newBuilder"]
	C2.Shallow = rec["newShallow"]
	C2.FlyOverAble = rec["newFlyOver"]
	C2.Destructable = rec["newDestructable"]
	if(istype(C2, /turf/CustomTurf))
		var/turf/CustomTurf/CT = C2
		CT.Roof = rec["newRoof"]
		CT.InitialType = "/turf/CustomTurf"
		CustomTurfs += C2
	else
		Turfs += C2
	for(var/list/krec in rec["killed"])
		var/atom/movable/O = krec["obj"]
		if(O)
			O.loc = null
	rec["newRef"] = C2
	LightingRecomputeNear(C2)

/proc/BuildRevertTurf(list/rec)
	var/turf/T = locate(rec["x"], rec["y"], rec["z"])
	BuildUntrackTurf(T)
	var/tp = rec["oldType"]
	var/turf/old = new tp(T)
	old.density = rec["oldDensity"]
	old.opacity = rec["oldOpacity"]
	old.Builder = rec["oldBuilder"]
	old.Shallow = rec["oldShallow"]
	old.FlyOverAble = rec["oldFlyOver"]
	old.Destructable = rec["oldDestructable"]
	if(istype(old, /turf/CustomTurf))
		var/turf/CustomTurf/CT = old
		if(rec["oldIcon"])
			CT.icon = rec["oldIcon"]
		if(rec["oldState"])
			CT.icon_state = rec["oldState"]
		CT.Roof = rec["oldRoof"]
	if(rec["oldBuilder"])
		if(istype(old, /turf/CustomTurf))
			CustomTurfs += old
		else
			Turfs += old
	rec["newRef"] = null
	for(var/list/krec in rec["killed"])
		BuildRestoreRec(krec)
	LightingRecomputeNear(old)

/proc/BuildRotAngle(dirv)
	switch(dirv)
		if(WEST)
			return -90
		if(NORTH)
			return -180
		if(EAST)
			return -270
	return 0

/proc/BuildPlacedDir(datum/build_entry/E, dirv)
	var/base = E.dirBase || SOUTH
	var/ang = BuildRotAngle(dirv)
	return ang ? turn(base, ang) : base

/proc/BuildPlaceObj(client/C, turf/T, datum/build_action/A, datum/build_entry/E)
	var/mob/M = C.mob
	var/obj/O = new E.Creates(T)
	if(E.iconF)
		O.icon = E.iconF
	if(E.icon_state)
		O.icon_state = E.icon_state
	O.dir = BuildPlacedDir(E, C.bsession.dirv)
	if(E.isCustom)
		if(E.cLayer)
			O.layer = E.cLayer
		O.density = E.cDensity
		O.opacity = E.cOpacity
		O.pixel_x = E.cPixelX
		O.pixel_y = E.cPixelY
	O.Builder = M.ckey
	O.Savable = 1
	worldObjectList += O
	if(M.MakeUngrabbable)
		O.Grabbable = 0
	GfxRefreshStructureMetadata(O)
	A.createdObjs += list(list("obj" = O, "x" = T.x, "y" = T.y, "z" = T.z))
	return O

/proc/BuildCommitSet(client/C, list/turfs, toolname, merge = 0, datum/build_entry/useBrush = null)
	var/datum/build_session/S = C?.bsession
	if(!S?.active)
		return
	if(S.busy)
		C.mob << "Still applying the previous edit..."
		return
	var/datum/build_entry/B = useBrush || S.brush
	if(!B)
		return
	S.busy = 1
	try
		BuildCommitInner(C, S, B, turfs, toolname, merge)
	catch(var/exception/e)
		Log("Mapper", "Build commit runtime error: [e] on [e.file]:[e.line]", 1)
	S.busy = 0

/proc/BuildCommitInner(client/C, datum/build_session/S, datum/build_entry/B, list/turfs, toolname, merge)
	var/list/valid = list()
	for(var/turf/T in turfs)
		if(T.CanBuildOver(C.mob))
			valid += T
	if(!valid.len)
		return
	var/mkey = "[toolname]|\ref[B]"
	var/datum/build_action/A
	if(merge && S.history.len)
		var/datum/build_action/last = S.history[S.history.len]
		if(last.name == toolname && last.mergeKey == mkey && !last.undone && last.count < BUILD_MERGE_CAP)
			A = last
	var/fresh = 0
	if(!A)
		A = new
		A.name = toolname
		A.mergeKey = mkey
		fresh = 1
	var/recStart = A.turfRecs.len
	var/objStart = A.createdObjs.len
	var/areaStart = A.areaRecs.len
	var/isObj = ispath(B.Creates, /obj)
	var/x1 = 30000
	var/y1 = 30000
	var/x2 = 0
	var/y2 = 0
	var/zz = 0
	var/placed = 0
	var/did = 0
	if(B.isZone)
		BuildAreaPaintLoad()
		var/misses = 0
		if(B.zoneRef)
			var/datum/build_zone_def/ZD = B.zoneRef
			if(ZD.creator != C.ckey && !C.mob.Admin)
				C.mob << "Zone \"[ZD.name]\" belongs to [ZD.creator] - you can only paint your own zones."
				return
		for(var/turf/T in valid)
			placed++
			if(placed % BUILD_COMMIT_CHUNK == 0)
				sleep(-1)
			var/newid
			if(B.zoneRef)
				var/datum/build_zone_def/ZD = B.zoneRef
				newid = "/area/MapperZone#[ZD.uid]"
			else if(B.zoneSmart)
				var/apath = BuildAreaSampleOutdoor(T)
				if(!apath)
					misses++
					continue
				newid = "[apath]"
			else
				newid = "[B.Creates]"
			var/oldid = BuildAreaIdOf(T.loc)
			if(oldid == newid)
				continue
			if(!BuildAreaSetId(T, newid))
				continue
			areaPaintMap["[T.x],[T.y],[T.z]"] = newid
			A.areaRecs += list(list("x" = T.x, "y" = T.y, "z" = T.z, "oldArea" = oldid, "newArea" = newid))
			x1 = min(x1, T.x)
			y1 = min(y1, T.y)
			x2 = max(x2, T.x)
			y2 = max(y2, T.y)
			zz = T.z
			did++
		if(misses)
			C.mob << "[misses] tiles had no outdoor zone within 8 tiles to match; they were left unchanged."
		if(!did)
			if(!misses)
				C.mob << "Those tiles are already in that zone."
			return
	else
		var/list/fam
		if(S.varied && !isObj && length(B.famKey))
			fam = buildFamilies?[B.famKey]
			if(fam && fam.len < 2)
				fam = null
		var/list/placedTurfs = list()
		for(var/turf/T in valid)
			x1 = min(x1, T.x)
			y1 = min(y1, T.y)
			x2 = max(x2, T.x)
			y2 = max(y2, T.y)
			zz = T.z
			if(isObj)
				BuildPlaceObj(C, T, A, B)
			else
				var/list/rec = BuildCaptureTurf(T)
				rec["killed"] = list()
				var/datum/build_entry/useE = B
				if(fam)
					useE = pick(fam)
					if(!istype(useE) || ispath(useE.Creates, /obj))
						useE = B
				var/turf/NT = BuildApplyTurf(C, rec, useE)
				A.turfRecs += list(rec)
				placedTurfs += NT
			placed++
			if(placed % BUILD_COMMIT_CHUNK == 0)
				sleep(-1)
		did = valid.len
		if(placedTurfs.len && S.autoEdge)
			BuildEdgeSmoothAround(placedTurfs, S.blendEdges)
	A.count += did
	if(fresh)
		BuildClearRedo(S)
		S.history += A
		if(S.history.len > BUILD_HISTORY_CAP)
			var/datum/build_action/old = S.history[1]
			S.history.Cut(1, 2)
			BuildReapAction(old)
	S.dirty += did
	BuildHUDRefreshDirty(S)
	Log("Mapper", "[C.mob] ([C.ckey]) [toolname] [B.name] x[did] @ ([x1],[y1])-([x2],[y2]) z[zz]", 1)
	BuildPresencePing(C, x1, y1, x2, y2, zz, toolname, fresh)
	var/datum/build_action/JA = new
	JA.count = did
	JA.turfRecs = A.turfRecs.Copy(recStart + 1)
	JA.createdObjs = A.createdObjs.Copy(objStart + 1)
	JA.areaRecs = A.areaRecs.Copy(areaStart + 1)
	BuildJournalAction(JA)
	JA.turfRecs = list()
	JA.createdObjs = list()
	JA.areaRecs = list()

/proc/BuildDeleteObjs(client/C, list/objs)
	var/datum/build_session/S = C?.bsession
	if(!S?.active || S.busy)
		return
	var/mob/M = C.mob
	var/datum/build_action/A = new
	A.name = "delete"
	for(var/obj/O in objs)
		if(!M.Admin && O.Builder != C.ckey)
			continue
		if(O in worldObjectList)
			worldObjectList -= O
		A.deletedObjs += list(BuildLimboRec(O))
		A.count++
	if(!A.count)
		C.mob << "Nothing deletable selected."
		return
	BuildClearRedo(S)
	S.history += A
	if(S.history.len > BUILD_HISTORY_CAP)
		var/datum/build_action/old = S.history[1]
		S.history.Cut(1, 2)
		BuildReapAction(old)
	S.dirty += A.count
	BuildHUDRefreshDirty(S)
	Log("Mapper", "[C.mob] ([C.ckey]) deleted [A.count] objects via build select.", 1)
	BuildJournalAction(A)

/proc/BuildUndo(client/C)
	var/datum/build_session/S = C?.bsession
	if(!S?.active || S.busy)
		return
	if(!S.history.len)
		C.mob << "Nothing to undo."
		return
	S.busy = 1
	try
		BuildUndoInner(C, S)
	catch(var/exception/e)
		Log("Mapper", "Build undo runtime error: [e] on [e.file]:[e.line]", 1)
	S.busy = 0

/proc/BuildUndoInner(client/C, datum/build_session/S)
	var/datum/build_action/A = S.history[S.history.len]
	S.history.Cut(S.history.len, 0)
	for(var/i = A.turfRecs.len, i >= 1, i--)
		BuildRevertTurf(A.turfRecs[i])
	BuildAreaPaintLoad()
	for(var/i = A.areaRecs.len, i >= 1, i--)
		var/list/rec = A.areaRecs[i]
		var/turf/T = locate(rec["x"], rec["y"], rec["z"])
		if(T && BuildAreaSetId(T, rec["oldArea"]))
			areaPaintMap["[rec["x"]],[rec["y"]],[rec["z"]]"] = rec["oldArea"]
	for(var/list/rec in A.createdObjs)
		var/atom/movable/O = rec["obj"]
		if(O)
			if(O in worldObjectList)
				worldObjectList -= O
			O.loc = null
	for(var/list/rec in A.deletedObjs)
		BuildRestoreRec(rec)
		var/obj/O = rec["obj"]
		if(O)
			worldObjectList += O
	var/list/touched = list()
	for(var/list/rec in A.turfRecs)
		var/turf/TT = locate(rec["x"], rec["y"], rec["z"])
		if(TT)
			touched += TT
	if(touched.len)
		BuildEdgeSmoothAround(touched, 1)
	A.undone = 1
	S.redoStack += A
	S.dirty = max(0, S.dirty - A.count)
	BuildHUDRefreshDirty(S)
	BuildJournalAction(A, 1)
	C.mob << "Undid [A.name] ([A.count] tiles)."

/proc/BuildRedo(client/C)
	var/datum/build_session/S = C?.bsession
	if(!S?.active || S.busy)
		return
	if(!S.redoStack.len)
		C.mob << "Nothing to redo."
		return
	S.busy = 1
	try
		BuildRedoInner(C, S)
	catch(var/exception/e)
		Log("Mapper", "Build redo runtime error: [e] on [e.file]:[e.line]", 1)
	S.busy = 0

/proc/BuildRedoInner(client/C, datum/build_session/S)
	var/datum/build_action/A = S.redoStack[S.redoStack.len]
	S.redoStack.Cut(S.redoStack.len, 0)
	for(var/list/rec in A.turfRecs)
		BuildReapplyTurf(rec)
	BuildAreaPaintLoad()
	for(var/list/rec in A.areaRecs)
		var/turf/T = locate(rec["x"], rec["y"], rec["z"])
		if(T && BuildAreaSetId(T, rec["newArea"]))
			areaPaintMap["[rec["x"]],[rec["y"]],[rec["z"]]"] = rec["newArea"]
	for(var/list/rec in A.createdObjs)
		BuildRestoreRec(rec)
		var/obj/O = rec["obj"]
		if(O)
			worldObjectList += O
	for(var/list/rec in A.deletedObjs)
		var/atom/movable/O = rec["obj"]
		if(O)
			if(O in worldObjectList)
				worldObjectList -= O
			O.loc = null
	var/list/touched = list()
	for(var/list/rec in A.turfRecs)
		var/turf/TT = locate(rec["x"], rec["y"], rec["z"])
		if(TT)
			touched += TT
	if(touched.len)
		BuildEdgeSmoothAround(touched, 1)
	A.undone = 0
	S.history += A
	S.dirty += A.count
	BuildHUDRefreshDirty(S)
	BuildJournalAction(A)
	C.mob << "Redid [A.name] ([A.count] tiles)."

/proc/BuildPushAction(datum/build_session/S, datum/build_action/A)
	BuildClearRedo(S)
	S.history += A
	if(S.history.len > BUILD_HISTORY_CAP)
		var/datum/build_action/old = S.history[1]
		S.history.Cut(1, 2)
		BuildReapAction(old)
	S.dirty += A.count
	BuildHUDRefreshDirty(S)

/proc/BuildPasteStamp(client/C, turf/T)
	var/datum/build_session/S = C?.bsession
	if(!S?.active || (!S.clipboard.len && !S.clipboardTurfs.len))
		return
	if(S.busy)
		C.mob << "Still applying the previous edit..."
		return
	S.busy = 1
	try
		BuildPasteInner(C, S, T)
	catch(var/exception/e)
		Log("Mapper", "Build paste runtime error: [e] on [e.file]:[e.line]", 1)
	S.busy = 0

/proc/BuildPasteInner(client/C, datum/build_session/S, turf/T)
	var/mob/M = C.mob
	var/ax = T.x - round(S.clipW / 2)
	var/ay = T.y - round(S.clipH / 2)
	var/datum/build_action/A = new
	A.name = "paste"
	var/list/placedTurfs = list()
	var/placed = 0
	for(var/list/rec in S.clipboardTurfs)
		var/tx = ax + rec["dx"]
		var/ty = ay + rec["dy"]
		if(tx < 1 || ty < 1 || tx > world.maxx || ty > world.maxy)
			continue
		var/turf/TT = locate(tx, ty, T.z)
		if(!TT || !TT.CanBuildOver(M))
			continue
		var/list/trec = BuildCaptureTurf(TT)
		trec["killed"] = list()
		var/datum/build_entry/E = new
		E.Creates = rec["type"]
		E.iconF = rec["icon"]
		E.icon_state = rec["state"]
		if(!isnull(rec["cRoof"]))
			E.cRoof = rec["cRoof"]
			E.cDensity = rec["cDensity"]
			E.cOpacity = rec["cOpacity"]
		var/turf/NT = BuildApplyTurf(C, trec, E)
		A.turfRecs += list(trec)
		placedTurfs += NT
		A.count++
		placed++
		if(placed % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
	for(var/list/rec in S.clipboard)
		var/ox = ax + rec["dx"]
		var/oy = ay + rec["dy"]
		if(ox < 1 || oy < 1 || ox > world.maxx || oy > world.maxy)
			continue
		var/turf/TT = locate(ox, oy, T.z)
		if(!TT || !TT.CanBuildOver(M))
			continue
		var/tp = rec["type"]
		var/obj/O = new tp(TT)
		O.icon = rec["icon"]
		O.icon_state = rec["state"]
		O.dir = rec["dir"]
		O.pixel_x = rec["px"]
		O.pixel_y = rec["py"]
		O.density = rec["density"]
		O.opacity = rec["opacity"]
		O.layer = rec["layer"]
		O.Grabbable = rec["grab"]
		O.Builder = M.ckey
		O.Savable = 1
		worldObjectList += O
		GfxRefreshStructureMetadata(O)
		A.createdObjs += list(list("obj" = O, "x" = TT.x, "y" = TT.y, "z" = TT.z))
		A.count++
	if(!A.count)
		C.mob << "Nowhere to paste there."
		return
	if(placedTurfs.len && S.autoEdge)
		BuildEdgeSmoothAround(placedTurfs, S.blendEdges)
	BuildPushAction(S, A)
	Log("Mapper", "[C.mob] ([C.ckey]) pasted [placedTurfs.len] tiles + [A.createdObjs.len] objects @ ([ax],[ay]) z[T.z]", 1)
	BuildJournalAction(A)
	C.mob << "Pasted [placedTurfs.len ? "[placedTurfs.len] tiles + " : ""][A.createdObjs.len] objects. Click to stamp again, right-click to stop."

/proc/BuildClearRedo(datum/build_session/S)
	for(var/datum/build_action/A in S.redoStack)
		BuildReapAction(A)
	S.redoStack = list()

/proc/BuildReapAction(datum/build_action/A)
	for(var/list/rec in A.createdObjs)
		var/atom/movable/O = rec["obj"]
		if(O && !O.loc)
			O.Savable = 0
		rec["obj"] = null
	for(var/list/rec in A.deletedObjs)
		var/atom/movable/O = rec["obj"]
		if(O && !O.loc)
			O.Savable = 0
		rec["obj"] = null
	for(var/list/rec in A.turfRecs)
		for(var/list/krec in rec["killed"])
			var/atom/movable/O = krec["obj"]
			if(O && !O.loc)
				O.Savable = 0
			krec["obj"] = null
	A.turfRecs = list()
	A.createdObjs = list()
	A.deletedObjs = list()
	A.areaRecs = list()

/proc/BuildSaveWorldData()
	find_savableObjects()
	Save_Turfs(quiet = 1)
	Save_Custom_Turfs(quiet = 1)
	Save_Objects(quiet = 1)
	BuildAreaPaintSave()
	if(fexists(BUILD_JOURNAL))
		fdel(BUILD_JOURNAL)

/proc/BuildSaveOrphan(who)
	set waitfor = FALSE
	set background = TRUE
	BuildSaveWorldData()
	Log("Mapper", "[who] disconnected with unsaved build edits; map auto-saved.", 1)

/proc/BuildSaveMap(client/C, force = 0)
	var/datum/build_session/S = C?.bsession
	if(!S || S.busy)
		return
	if(!force && world.time - S.lastSave < BUILD_SAVE_COOLDOWN)
		C.mob << "Map was saved [round((world.time - S.lastSave) / 10)]s ago; wait [round((BUILD_SAVE_COOLDOWN - (world.time - S.lastSave)) / 10)]s."
		return
	S.lastSave = world.time
	S.busy = 1
	C.mob << "Saving map..."
	try
		BuildSaveWorldData()
		S.dirty = 0
		BuildHUDRefreshDirty(S)
		Log("Mapper", "[C.mob] ([C.ckey]) saved the map from build mode.", 1)
		C?.mob << "Map saved."
	catch(var/exception/e)
		Log("Mapper", "Build save runtime error: [e] on [e.file]:[e.line]", 1)
	S.busy = 0
