#define ELEV_MAX 8
#define ELEV_DMAX 11
#define ELEV_SAVE_FILE "Saves/Elevation.txt"

turf/var/tmp/elev = 0
turf/var/tmp/elev_ver = 0

var/global/list/elevMap
var/global/elevVer = 1
var/global/elevSavePending = 0

/proc/ElevMapLoad()
	if(elevMap)
		return
	elevMap = list()
	if(!fexists(ELEV_SAVE_FILE))
		return
	var/raw = file2text(ELEV_SAVE_FILE)
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2 || !length(f[1]))
			continue
		var/h = round(text2num(f[2]))
		if(h >= 1)
			elevMap[f[1]] = min(h, ELEV_MAX)
	elevVer++
	ElevGeomChanged()

/proc/ElevMapSaveNow()
	if(!elevMap)
		return
	var/list/lines = list()
	for(var/k in elevMap)
		lines += "[k]\t[elevMap[k]]"
	if(fexists(ELEV_SAVE_FILE))
		fdel(ELEV_SAVE_FILE)
	if(lines.len)
		text2file(jointext(lines, "\n"), ELEV_SAVE_FILE)

/proc/ElevMapSaveSoon()
	set waitfor = FALSE
	if(elevSavePending)
		return
	elevSavePending = 1
	sleep(20)
	elevSavePending = 0
	ElevMapSaveNow()

/proc/ElevAt(turf/T)
	if(!T || !elevMap || !elevMap.len)
		return 0
	if(T.elev_ver != elevVer)
		T.elev = elevMap["[T.x],[T.y],[T.z]"] || 0
		T.elev_ver = elevVer
	return T.elev

/proc/ElevSet(turf/T, h)
	if(!T)
		return
	ElevMapLoad()
	h = clamp(round(h), 0, ELEV_MAX)
	var/k = "[T.x],[T.y],[T.z]"
	if(h > 0)
		elevMap[k] = h
	else
		elevMap -= k
	T.elev = h
	T.elev_ver = elevVer
	ElevCoverInvalidate(list(T))
	ElevMapSaveSoon()

/proc/ElevRaisable(turf/T)
	if(!T || T.density)
		return 0
	if(istype(T, /turf/Waters) || istype(T, /turf/Waterfall))
		return 0
	if(BuildMaterialFor(T) == "Water")
		return 0
	if(BuildIsCliffTurf(T))
		return 0
	return 1

/proc/ElevSameKind(turf/T, datum/build_entry/E, list/fam)
	if(!T || !E || !E.Creates)
		return 0
	if(istype(T, /turf/CustomTurf))
		if(!ispath(E.Creates, /turf/CustomTurf))
			return 0
		return T.icon == E.iconF && "[T.icon_state]" == "[E.icon_state]"
	if(T.type == E.Creates)
		return 1
	if(fam)
		for(var/datum/build_entry/FE in fam)
			if(FE.Creates == T.type)
				return 1
	return 0

var/global/list/buildFixtureTypes
turf/var/custom_def = ""

/proc/BuildFixtureTypesInit()
	if(buildFixtureTypes)
		return
	buildFixtureTypes = list()
	for(var/p in list(/turf/Stairs1, /turf/Stairs2, /turf/Stairs3, /turf/Stairs4, /turf/Stairs5, /turf/Stairs6, /turf/Stairs7, /turf/Stairs8, /turf/Stairs8L, /turf/Stairs8R, /turf/MidgarTiles/MidgarStairs, /turf/KatieTurf/Space/Floors/Floor_11, /turf/KatieTurf/Space/Floors/Floor_12, /turf/KatieTurf/Space/Floors/Floor_13, /turf/KatieTurf/Space/Floors/Floor_14, /turf/KatieTurf/Space/Floors/Floor_15, /turf/KatieTurf/Floor/Floor_23, /turf/IconsX/Icon29, /turf/IconsX/Icon30, /turf/IconsX/Icon31, /turf/IconsX/Icon32, /turf/IconsX/Icon33, /turf/IconsX/Icon34, /turf/IconsX/Icon35, /turf/IconsX/Icon36, /turf/IconsX/Icon37, /turf/IconsX/Icon38, /turf/IconsX/Icon39, /turf/IconsX/Icon40, /turf/IconsX/Icon41, /turf/IconsX/Icon42, /turf/IconsX/Icon43, /turf/IconsX/Icon44, /turf/IconsX/Icon62, /obj/Turfs/IconsX/Icon173, /obj/Turfs/IconsX/Icon174, /obj/Turfs/IconsX/Icon175, /obj/Turfs/IconsX/Icon176, /obj/KatieObj/Misc/Misc_94, /obj/KatieObj/Misc/Misc_95))
		for(var/q in typesof(p))
			buildFixtureTypes[q] = "stairs"
	for(var/p in list(/obj/Turfs/IconsXLBig/Icon46, /obj/Turfs/IconsXLBig/Icon47, /obj/Turfs/IconsXLBig/Icon48, /obj/Turfs/IconsXLBig/Icon49, /obj/KatieObj/Misc/Misc_52))
		for(var/q in typesof(p))
			buildFixtureTypes[q] = "ladder"
	for(var/p in list(/turf/Wood14, /turf/Wood15, /obj/Turfs/IconsX/Icon100, /obj/Turfs/IconsX/Icon108, /obj/Turfs/IconsX/Icon116, /obj/Turfs/IconsX/Icon123, /obj/Turfs/IconsX/Icon133, /obj/Turfs/IconsX/Icon134, /obj/Turfs/IconsX/Icon135, /obj/Turfs/IconsX/Icon136, /obj/Turfs/IconsX/Icon137, /obj/Turfs/IconsX/Icon138, /obj/Turfs/IconsX/Icon139, /obj/Turfs/IconsX/Icon140))
		for(var/q in typesof(p))
			buildFixtureTypes[q] = "bridge"

/proc/BuildFixtureKindOf(atom/A)
	if(!A)
		return ""
	if(istype(A, /turf/CustomTurf))
		var/datum/build_custom_def/D = BuildCustomDefForTurf(A)
		return D ? BuildCustomFixture(D) : ""
	if(istype(A, /obj/Turfs/CustomObj1))
		var/datum/build_custom_def/D2 = BuildCustomDefForObj(A)
		return D2 ? BuildCustomFixture(D2) : ""
	BuildFixtureTypesInit()
	return buildFixtureTypes[A.type] || ""

/proc/BuildFixtureAt(turf/T, kind)
	if(!T)
		return 0
	if(BuildFixtureKindOf(T) == kind)
		return 1
	for(var/obj/O in T)
		if(istype(O, /obj/Turfs) || istype(O, /obj/KatieObj))
			if(BuildFixtureKindOf(O) == kind)
				return 1
	return 0

/proc/BuildWalkableFixtureAt(turf/T)
	if(!T)
		return 0
	if(length(BuildFixtureKindOf(T)))
		return 1
	for(var/obj/O in T)
		if(istype(O, /obj/Turfs) || istype(O, /obj/KatieObj))
			if(length(BuildFixtureKindOf(O)))
				return 1
	return 0

/proc/BuildBridgeAt(turf/T)
	return BuildFixtureAt(T, "bridge")

/proc/ElevLadderAt(turf/T)
	return BuildFixtureAt(T, "ladder")

/proc/ElevStairTurf(turf/T)
	var/k = BuildFixtureKindOf(T)
	return (k == "stairs" || k == "ladder") ? 1 : 0

/proc/ElevStairsAt(turf/T)
	if(!T)
		return 0
	if(ElevStairTurf(T))
		return 1
	for(var/obj/O in T)
		if(istype(O, /obj/Turfs) || istype(O, /obj/KatieObj))
			var/k = BuildFixtureKindOf(O)
			if(k == "stairs" || k == "ladder")
				return 1
	return 0

/proc/ElevFaceTop(turf/G)
	if(!G || !elevMap || !elevMap.len)
		return 0
	var/turf/U = ElevCoverOf(G)
	return U ? ElevAt(U) : 0

/proc/ElevMoverExempt(mob/M)
	if(M.Flying || M.Incorporeal || M.MapperWalk || M.IgnoreFlyOver || M.Skimming)
		return 1
	if(M.passive_handler?.Get("Skimming"))
		return 1
	return 0

/proc/ElevMobUnderFace(mob/M)
	if(!M || M.Flying)
		return 0
	var/turf/T = M.loc
	if(!isturf(T))
		return 0
	if(!ElevCoverOf(T))
		return 0
	return ElevStairsAt(T) ? 0 : 1

turf/Enter(atom/movable/O, atom/oldloc)
	. = ..()
	if(!. && ismob(O) && BuildWalkableFixtureAt(src))
		. = 1
	if(!. || !ismob(O) || !elevMap || !elevMap.len)
		return
	if(!isturf(oldloc) || oldloc.z != z)
		return
	var/mob/M = O
	if(ElevMoverExempt(M))
		return
	var/covered = ElevFaceTop(src) ? 1 : 0
	if(!covered && ElevAt(src) == ElevAt(oldloc))
		return
	if(ElevStairsAt(src))
		return
	if(!covered && ElevStairsAt(oldloc))
		return
	return 0

/proc/ElevTouchedBlock(list/turfs)
	var/list/out = list()
	for(var/turf/T in turfs)
		for(var/dx = -2 to 2)
			for(var/dy = -(ELEV_DMAX + 2) to (ELEV_DMAX + 2))
				var/turf/T2 = locate(T.x + dx, T.y + dy, T.z)
				if(T2 && !out[T2])
					out[T2] = 1
	return out

/proc/ElevRefreshAround(list/turfs)
	if(!turfs || !turfs.len)
		return
	ElevVisualRefresh(turfs)
	BuildEdgeSmoothAround(turfs, 1)

/proc/ElevVisualRefresh(list/turfs)
	if(!turfs || !turfs.len)
		return
	ElevCoverInvalidate(turfs)
	var/list/blk = ElevTouchedBlock(turfs)
	var/n = 0
	for(var/turf/T in blk)
		Hd2dInvalidateColumn(T)
		ElevVisualUpdate(T)
		for(var/mob/M in T)
			M.UpdateStandingLayer()
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)

/proc/ElevExportSidecar(x1, y1, x2, y2, z, fname)
	ElevMapLoad()
	var/cf = "[copytext(fname, 1, -4)]_elev.txt"
	if(fexists(cf))
		fdel(cf)
	var/list/out = list()
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			var/h = elevMap["[x],[y],[z]"]
			if(h)
				out += "[x - x1]\t[y - y1]\t[h]"
	if(!out.len)
		return 0
	text2file(jointext(out, "\n"), cf)
	return out.len

/proc/ElevImportSidecar(fname, ox, oy, oz, cols, rowsN)
	ElevMapLoad()
	var/cf = "[copytext(fname, 1, -4)]_elev.txt"
	var/list/touched = list()
	for(var/y = oy to oy + rowsN - 1)
		for(var/x = ox to ox + cols - 1)
			var/k = "[x],[y],[oz]"
			if(elevMap[k])
				elevMap -= k
				var/turf/T0 = locate(x, y, oz)
				if(T0)
					touched += T0
	var/n = 0
	if(fexists(cf))
		var/raw = file2text(cf)
		for(var/line in splittext(raw, "\n"))
			var/list/f = splittext(line, "\t")
			if(f.len < 3)
				continue
			var/dx = text2num(f[1])
			var/dy = text2num(f[2])
			var/h = round(text2num(f[3]))
			if(isnull(dx) || isnull(dy) || h < 1)
				continue
			elevMap["[ox + dx],[oy + dy],[oz]"] = min(h, ELEV_MAX)
			var/turf/T1 = locate(ox + dx, oy + dy, oz)
			if(T1)
				touched += T1
			n++
	elevVer++
	ElevGeomChanged()
	ElevMapSaveSoon()
	if(touched.len)
		ElevRefreshAround(touched)
	return n

/proc/ElevBootPass()
	set waitfor = FALSE
	set background = TRUE
	ElevMapLoad()
	if(!elevMap.len)
		return
	var/list/hit = list()
	for(var/k in elevMap)
		var/list/c = splittext(k, ",")
		if(c.len < 3)
			continue
		var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
		if(T)
			hit += T
	ElevRefreshAround(hit)
	Log("Mapper", "Elevation boot pass rebuilt around [hit.len] raised tiles.", 1)
