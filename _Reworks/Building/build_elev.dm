#define ELEV_MAX 8
#define ELEV_DMAX 11
#define ELEV_SAVE_FILE "Saves/Elevation.txt"
#define MAPVIS_VERSION 2
#define MAPVIS_DIR "Saves/MapVisuals/"
#define MAPVIS_CHUNK 16
#define MAPVIS_SPOT 200

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
			if(isnull(elevMap[f[1]]))
				elevMap += f[1]
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

var/global/list/elevRoofTypes

/proc/ElevRoofTypesInit()
	if(elevRoofTypes)
		return
	elevRoofTypes = list()
	for(var/p in typesof(/turf))
		var/pt = "[p]"
		if(findtext(pt, "/turf/Roof") == 1 || findtext(pt, "/turf/KatieTurf/Roof") == 1)
			elevRoofTypes[p] = 1

/proc/ElevRoofTurf(turf/T)
	if(!T)
		return 0
	if(istype(T, /turf/CustomTurf))
		var/turf/CustomTurf/CT = T
		return CT.Roof ? 1 : 0
	ElevRoofTypesInit()
	return elevRoofTypes[T.type] ? 1 : 0

/proc/ElevRaisable(turf/T)
	if(!T || BuildIsCliffTurf(T))
		return 0
	if(ElevRoofTurf(T))
		return 1
	if(T.density)
		return 0
	if(istype(T, /turf/Waterfall) || istype(T, /turf/Waters/WaterFall))
		return 0
	if(istype(T, /turf/Waters/WaterU1) || istype(T, /turf/Waters/WaterU2) || istype(T, /turf/Waters/WaterU3))
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
					out += T2
					out[T2] = 1
	return out

/proc/ElevRefreshAround(list/turfs)
	if(!turfs || !turfs.len)
		return
	ElevVisualRefresh(turfs)
	BuildEdgeSmoothAround(turfs, 1)

/proc/ElevVisualRefresh(list/turfs, bootPump = 0)
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
			if(!bootPump || !BuildBootPassYield())
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
	var/t0 = world.timeofday
	ElevMapLoad()
	if(!elevMap.len)
		MapVisPassDone(2)
		return
	var/list/hit = list()
	for(var/k in elevMap)
		var/list/c = splittext(k, ",")
		if(c.len < 3)
			continue
		var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
		if(T)
			hit += T
	if(!hit.len)
		MapVisPassDone(2)
		return
	buildBootPassMark = world.timeofday
	ElevVisualRefresh(hit, 1)
	var/list/regs = list()
	for(var/turf/R in Turfs)
		regs += R
	for(var/turf/R in CustomTurfs)
		regs += R
	var/list/cov = BuildBitGrid(regs, 1)
	for(var/turf/R in regs)
		var/list/rb = cov["[R.z]"]
		var/list/rf = rb[5]
		for(var/dx = -1 to 1)
			var/rx = R.x + dx
			if(rx < rb[1] || rx > rb[3])
				continue
			for(var/dy = -1 to 1)
				var/ry = R.y + dy
				if(ry < rb[2] || ry > rb[4])
					continue
				var/ri = (ry - rb[2]) * rb[6] + (rx - rb[1])
				rf[(ri >> 4) + 1] |= 1 << (ri & 15)
	var/list/sg = BuildBitGrid(hit, 1)
	var/list/rebuilt = list()
	var/n = 0
	var/skipped = 0
	for(var/turf/T in hit)
		var/list/sb = sg["[T.z]"]
		var/list/sf = sb[5]
		var/list/cb = cov["[T.z]"]
		for(var/dx = -1 to 1)
			var/x2 = T.x + dx
			if(x2 < sb[1] || x2 > sb[3])
				continue
			for(var/dy = -1 to 1)
				var/y2 = T.y + dy
				if(y2 < sb[2] || y2 > sb[4])
					continue
				var/si = (y2 - sb[2]) * sb[6] + (x2 - sb[1])
				var/sbit = 1 << (si & 15)
				if(sf[(si >> 4) + 1] & sbit)
					continue
				sf[(si >> 4) + 1] |= sbit
				if(cb && x2 >= cb[1] && x2 <= cb[3] && y2 >= cb[2] && y2 <= cb[4])
					var/list/cf = cb[5]
					var/ci = (y2 - cb[2]) * cb[6] + (x2 - cb[1])
					if(cf[(ci >> 4) + 1] & (1 << (ci & 15)))
						skipped++
						continue
				var/turf/T2 = locate(x2, y2, T.z)
				if(!T2)
					continue
				BuildEdgeUpdate(T2, 1)
				rebuilt += T2
				n++
				if(n % BUILD_COMMIT_CHUNK == 0)
					if(!BuildBootPassYield())
						sleep(-1)
	BuildEdgeCleanFlecks(rebuilt, 1, 1)
	Log("Mapper", "Elevation boot pass rebuilt around [hit.len] raised tiles.", 1)
	world.log << "BOOT elevation pass finished: [BootSeconds(t0)] s ([hit.len] raised tiles, [n] edge updates, [skipped] already covered by the edge pass)"
	MapVisPassDone(2)

turf/var/tmp/mapvis_in = 0

var/global/mapVisReady = 0
var/global/mapVisPassBits = 0
var/global/mapVisSerial = 0
var/global/mapVisWriting = 0
var/global/mapVisPending = 0
var/global/mapVisSaveCount = 0
var/global/list/mapVisTiles = list()
var/global/list/mapVisIconIds = list()

/proc/MapVisReg(turf/T)
	mapVisSerial++
	if(T && !T.mapvis_in)
		T.mapvis_in = 1
		mapVisTiles += T

/proc/MapVisYield()
	if(world.tick_usage > 60)
		sleep(world.tick_lag)

/proc/MapVisChunkKey(x, y, z)
	return "[z],[round((x - 1) / MAPVIS_CHUNK)],[round((y - 1) / MAPVIS_CHUNK)]"

/proc/MapVisLines(path)
	if(!fexists(path))
		return null
	var/raw = file2text(path)
	if(!raw)
		return list()
	raw = replacetext(raw, ascii2text(13), "")
	var/list/L = splittext(raw, "\n")
	while(L.len && !length(L[L.len]))
		L.len--
	return L

/proc/MapVisPassesStart()
	mapVisReady = 0
	mapVisPassBits = 0

/proc/MapVisPassDone(bit)
	mapVisPassBits |= bit
	if((mapVisPassBits & 3) == 3 && !mapVisReady)
		mapVisReady = 1
		world.log << "MAPVIS boot passes complete; saving the map visuals"
		MapVisSaveSoon()

/proc/MapVisBoot()
	if(MapVisRestore())
		return
	MapVisPassesStart()
	BuildEdgeBootPass()
	sleep(world.tick_lag)
	ElevBootPass()

/proc/MapVisScopeAdd(list/S, k)
	if(isnull(S[k]))
		S += k
		S[k] = 1

/proc/MapVisCoreScope(list/tiles)
	var/list/S = list()
	for(var/turf/T in Turfs)
		MapVisScopeAdd(S, MapVisChunkKey(T.x, T.y, T.z))
	for(var/turf/T in CustomTurfs)
		MapVisScopeAdd(S, MapVisChunkKey(T.x, T.y, T.z))
	for(var/turf/T in tiles)
		MapVisScopeAdd(S, MapVisChunkKey(T.x, T.y, T.z))
	for(var/list/M in list(elevMap, cliffPaintMap, foamPaintMap))
		for(var/k in M)
			var/list/c = splittext(k, ",")
			if(c.len >= 3)
				MapVisScopeAdd(S, MapVisChunkKey(text2num(c[1]), text2num(c[2]), text2num(c[3])))
	for(var/obj/O in worldObjectList)
		if(isturf(O.loc) && (istype(O, /obj/Turfs) || istype(O, /obj/KatieObj)))
			MapVisScopeAdd(S, MapVisChunkKey(O.x, O.y, O.z))
	var/cxm = round((world.maxx - 1) / MAPVIS_CHUNK)
	var/cym = round((world.maxy - 1) / MAPVIS_CHUNK)
	var/list/out = list()
	for(var/k in S)
		var/list/c = splittext(k, ",")
		var/z = text2num(c[1])
		var/cx = text2num(c[2])
		var/cy = text2num(c[3])
		for(var/dx = -1 to 1)
			var/nx = cx + dx
			if(nx < 0 || nx > cxm)
				continue
			for(var/dy = -1 to 1)
				var/ny = cy + dy
				if(ny < 0 || ny > cym)
					continue
				MapVisScopeAdd(out, "[z],[nx],[ny]")
	return out

/proc/MapVisDefSig(datum/build_custom_def/D, list/defSigs)
	if(!D)
		return "-"
	var/rk = "\ref[D]"
	var/s = defSigs[rk]
	if(s)
		return s
	s = "[D.kind]|[D.name]|[D.fname]|[D.icon_state]|[D.density]|[D.opacity]|[D.roof]|[D.layerv]|[D.pixelX]|[D.pixelY]|[D.edge]|[D.hash]|[D.material]|[D.cliff]|[D.stairs]|[D.profile]|[D.fixture]"
	defSigs += rk
	defSigs[rk] = s
	return s

/proc/MapVisTileSig(turf/T, list/defSigs)
	var/s = "[T.type]|[T.icon]|[T.icon_state]|[T.dir]|[T.SecondaryTurfType]|[T.EdgeOptOut]|[T.Lava]|[T.Water]|[T.Shallow]"
	if(istype(T, /turf/CustomTurf))
		var/turf/CustomTurf/CT = T
		s += "|R[CT.Roof]|[MapVisDefSig(BuildCustomDefForTurf(CT), defSigs)]"
	var/list/os = null
	for(var/obj/O in T)
		if(!istype(O, /obj/Turfs) && !istype(O, /obj/KatieObj))
			continue
		var/o = "[O.type]|[O.icon]|[O.icon_state]|[O.dir]|[O.pixel_x]|[O.pixel_y]|[O.step_x]|[O.step_y]"
		if(istype(O, /obj/Turfs/CustomObj1))
			o += "|[MapVisDefSig(BuildCustomDefForObj(O), defSigs)]"
		if(!os)
			os = list()
		var/at = os.len + 1
		for(var/i = 1 to os.len)
			if(sorttextEx(o, os[i]) > 0)
				at = i
				break
		os.Insert(at, o)
	if(os)
		s += "|o[jointext(os, "|o")]"
	return s

/proc/MapVisPaintBuckets(list/S)
	var/list/B = list()
	var/list/maps = list(elevMap, cliffPaintMap, foamPaintMap)
	var/list/tags = list("e", "c", "f")
	for(var/m = 1 to 3)
		var/list/M = maps[m]
		if(!M)
			continue
		var/tg = tags[m]
		for(var/k in M)
			var/list/c = splittext(k, ",")
			if(c.len < 3)
				continue
			var/x = text2num(c[1])
			var/y = text2num(c[2])
			var/z = text2num(c[3])
			if(!x || !y || !z)
				continue
			var/ck = MapVisChunkKey(x, y, z)
			if(!S[ck])
				continue
			var/list/b = B[ck]
			if(!b)
				b = list()
				B += ck
				B[ck] = b
			b += ((y - 1) % MAPVIS_CHUNK) * MAPVIS_CHUNK + ((x - 1) % MAPVIS_CHUNK) + 1
			b += "|[tg][M[k]]"
	return B

/proc/MapVisHashChunks(list/S)
	set background = TRUE
	var/list/H = list()
	var/list/defSigs = list()
	var/list/B = MapVisPaintBuckets(S)
	var/n = 0
	for(var/k in S)
		var/list/c = splittext(k, ",")
		var/z = text2num(c[1])
		var/x0 = text2num(c[2]) * MAPVIS_CHUNK
		var/y0 = text2num(c[3]) * MAPVIS_CHUNK
		var/list/slots = new/list(MAPVIS_CHUNK * MAPVIS_CHUNK)
		for(var/dy = 0 to MAPVIS_CHUNK - 1)
			var/y = y0 + dy + 1
			if(y > world.maxy)
				break
			for(var/dx = 0 to MAPVIS_CHUNK - 1)
				var/x = x0 + dx + 1
				if(x > world.maxx)
					break
				var/turf/T = locate(x, y, z)
				if(T)
					slots[dy * MAPVIS_CHUNK + dx + 1] = MapVisTileSig(T, defSigs)
		var/list/b = B[k]
		if(b)
			for(var/i = 1, i < b.len, i += 2)
				slots[b[i]] += b[i + 1]
		for(var/i = 1 to slots.len)
			slots[i] = isnull(slots[i]) ? "--------" : copytext(md5(slots[i]), 1, 9)
		H += k
		H[k] = jointext(slots, "")
		if(++n % 64 == 0)
			MapVisYield()
	return H

/proc/MapVisIconId(res)
	if(!res)
		return ""
	if(istype(res, /icon))
		res = fcopy_rsc(res)
	var/rk = "\ref[res]"
	var/id = mapVisIconIds[rk]
	if(id)
		return id
	var/tp = MAPVIS_DIR + "icon_tmp.dmi"
	fdel(tp)
	if(!fcopy(res, tp))
		return null
	id = md5(file(tp))
	if(!id)
		return null
	var/dst = MAPVIS_DIR + "icons/[id].dmi"
	if(!fexists(dst) && !fcopy(tp, dst))
		return null
	mapVisIconIds += rk
	mapVisIconIds[rk] = id
	return id

/proc/MapVisNum(v)
	return num2text(v, 12)

/proc/MapVisRecord(image/I)
	var/mutable_appearance/MA = new(I)
	var/ic = MapVisIconId(MA.icon)
	if(isnull(ic))
		return null
	var/col = ""
	var/c = MA.color
	if(islist(c))
		var/list/cl = list()
		for(var/v in c)
			cl += MapVisNum(v)
		col = "m[jointext(cl, ",")]"
	else if(c)
		col = "[c]"
	var/tr = ""
	var/matrix/M = MA.transform
	if(M && (M.a != 1 || M.b != 0 || M.c != 0 || M.d != 0 || M.e != 1 || M.f != 0))
		tr = "[MapVisNum(M.a)],[MapVisNum(M.b)],[MapVisNum(M.c)],[MapVisNum(M.d)],[MapVisNum(M.e)],[MapVisNum(M.f)]"
	var/list/fl = list()
	for(var/f in MA.filters)
		if(f:type != "alpha" || f:render_source)
			return null
		var/fi = MapVisIconId(f:icon)
		if(isnull(fi))
			return null
		fl += "[f:x],[f:y],[fi],[f:flags]"
	return "[ic]\t[MA.icon_state]\t[MA.dir]\t[MapVisNum(MA.layer)]\t[MA.plane]\t[MA.pixel_x]\t[MA.pixel_y]\t[MA.pixel_w]\t[MA.pixel_z]\t[MA.alpha]\t[MA.blend_mode]\t[MA.appearance_flags]\t[col]\t[tr]\t[jointext(fl, ";")]"

/proc/MapVisPalIndex(image/I, list/pal, list/lines)
	var/r = MapVisRecord(I)
	if(isnull(r))
		return 0
	var/i = pal[r]
	if(i)
		return i
	lines += r
	i = lines.len
	pal += r
	pal[r] = i
	return i

/proc/MapVisFinText(list/fin)
	var/list/rows = list()
	for(var/r = 0 to 31)
		var/list/cs = list()
		for(var/x = 1 to 32)
			var/v = fin[r * 32 + x]
			if(isnull(v))
				cs += "!"
				continue
			if(!isnum(v) || v < 0 || v > 78 || v != round(v))
				return null
			cs += ascii2text(48 + v)
		rows += jointext(cs, "")
	return jointext(rows, "")

/proc/MapVisFinList(t)
	if(length(t) != 1024)
		return null
	var/list/fin = new/list(1024)
	for(var/r = 0 to 31)
		var/row = copytext(t, r * 32 + 1, r * 32 + 33)
		for(var/x = 1 to 32)
			var/a = text2ascii(row, x)
			if(a != 33)
				fin[r * 32 + x] = a - 48
	return fin

/proc/MapVisSaveSoon()
	set waitfor = FALSE
	if(!mapVisReady)
		return
	if(mapVisWriting)
		mapVisPending = 1
		return
	mapVisWriting = 1
	var/ok = 0
	try
		ok = MapVisSave()
	catch(var/exception/e)
		world.log << "MAPVIS save runtime error: [e] on [e.file]:[e.line]"
	mapVisWriting = 0
	if(ok < 0 || mapVisPending)
		mapVisPending = 0
		spawn(600)
			MapVisSaveSoon()

/proc/MapVisSave()
	set background = TRUE
	if(!mapVisReady)
		return 0
	var/t0 = world.timeofday
	var/s0 = mapVisSerial
	ElevMapLoad()
	BuildCliffPaintLoad()
	BuildFoamPaintLoad()
	var/list/tiles = list()
	var/list/seen = list()
	for(var/turf/T in mapVisTiles)
		if(seen[T])
			continue
		seen += T
		seen[T] = 1
		if(length(T.elevOverlays) || length(T.edgeOverlays) || buildOrgFinal[T])
			tiles += T
		else
			T.mapvis_in = 0
	mapVisTiles = tiles.Copy()
	var/list/S = MapVisCoreScope(tiles)
	var/list/H = MapVisHashChunks(S)
	var/t1 = world.timeofday
	var/list/pal = list()
	var/list/palLines = list()
	var/list/tileLines = list()
	var/n = 0
	for(var/turf/T in tiles)
		var/list/ei = list()
		for(var/image/I in T.elevOverlays)
			var/p = MapVisPalIndex(I, pal, palLines)
			if(!p)
				world.log << "MAPVIS save refused: an elevation overlay on [T.x],[T.y],[T.z] cannot be stored"
				return 0
			ei += p
		var/list/gi = list()
		for(var/image/I2 in T.edgeOverlays)
			var/p2 = MapVisPalIndex(I2, pal, palLines)
			if(!p2)
				world.log << "MAPVIS save refused: an edge overlay on [T.x],[T.y],[T.z] cannot be stored"
				return 0
			gi += p2
		var/ft = ""
		var/list/fin = buildOrgFinal[T]
		if(fin)
			ft = MapVisFinText(fin)
			if(isnull(ft))
				world.log << "MAPVIS save refused: the fleck state on [T.x],[T.y],[T.z] cannot be stored"
				return 0
		tileLines += "[T.x],[T.y],[T.z]\t[jointext(ei, ",")]\t[jointext(gi, ",")]\t[ft]"
		if(++n % 200 == 0)
			MapVisYield()
	if(mapVisSerial != s0)
		world.log << "MAPVIS save postponed: the map changed while it was being captured"
		return -1
	var/gen = 1
	var/list/cur = MapVisLines(MAPVIS_DIR + "current.txt")
	var/oldDir = null
	if(cur && cur.len && length(cur[1]))
		oldDir = cur[1]
		gen = (text2num(copytext(oldDir, 2)) || 0) + 1
	var/gd = MAPVIS_DIR + "g[gen]/"
	fdel(gd)
	var/list/chunkLines = list()
	for(var/k in H)
		chunkLines += "[k]\t[H[k]]"
	var/list/hdr = list("version\t[MAPVIS_VERSION]", "maxx\t[world.maxx]", "maxy\t[world.maxy]", "maxz\t[world.maxz]", "foam\t[glob && glob.SHORE_FOAM ? 1 : 0]", "tiles\t[tileLines.len]", "palette\t[palLines.len]", "chunks\t[chunkLines.len]")
	text2file(jointext(palLines, "\n"), gd + "palette.txt")
	text2file(jointext(tileLines, "\n"), gd + "tiles.txt")
	text2file(jointext(chunkLines, "\n"), gd + "chunks.txt")
	text2file(jointext(hdr, "\n"), gd + "header.txt")
	if(!fexists(gd + "header.txt") || !fexists(gd + "tiles.txt"))
		world.log << "MAPVIS save failed: could not write [gd]"
		return 0
	fdel(MAPVIS_DIR + "current.txt")
	text2file("g[gen]", MAPVIS_DIR + "current.txt")
	if(oldDir && oldDir != "g[gen]")
		fdel(MAPVIS_DIR + oldDir + "/")
	MapVisIconGC(palLines)
	mapVisSaveCount++
	world.log << "MAPVIS saved g[gen]: [tileLines.len] tiles, [palLines.len] appearances, [chunkLines.len] chunks; fingerprints [(t1 - t0) / 10] s, capture [(world.timeofday - t1) / 10] s"
	return 1

/proc/MapVisIconGC(list/palLines)
	var/list/keep = list()
	for(var/r in palLines)
		var/list/f = splittext(r, "\t")
		if(length(f[1]) && isnull(keep[f[1]]))
			keep += f[1]
			keep[f[1]] = 1
		if(f.len >= 15 && length(f[15]))
			for(var/fs in splittext(f[15], ";"))
				var/list/p = splittext(fs, ",")
				if(p.len >= 3 && length(p[3]) && isnull(keep[p[3]]))
					keep += p[3]
					keep[p[3]] = 1
	var/dropped = 0
	for(var/fn in flist(MAPVIS_DIR + "icons/"))
		var/id = copytext(fn, 1, -4)
		if(!keep[id])
			fdel(MAPVIS_DIR + "icons/[fn]")
			dropped++
	if(dropped)
		var/list/ids = list()
		for(var/rk in mapVisIconIds)
			var/id2 = mapVisIconIds[rk]
			if(keep[id2])
				ids += rk
				ids[rk] = id2
		mapVisIconIds = ids

/proc/MapVisHeader(list/lines)
	var/list/h = list()
	for(var/l in lines)
		var/list/f = splittext(l, "\t")
		if(f.len >= 2)
			h[f[1]] = f[2]
	return h

/proc/MapVisFail(why)
	world.log << "MAPVIS full rebuild: [why]"
	Log("Mapper", "Map visuals rebuild in full this boot: [why].", 1)
	return 0

/proc/MapVisRestore()
	set background = TRUE
	var/t0 = world.timeofday
	var/list/cur = MapVisLines(MAPVIS_DIR + "current.txt")
	if(!cur || !cur.len || !length(cur[1]))
		return MapVisFail("no saved map visuals")
	var/gd = MAPVIS_DIR + cur[1] + "/"
	var/list/h = MapVisHeader(MapVisLines(gd + "header.txt"))
	if(text2num(h["version"]) != MAPVIS_VERSION)
		return MapVisFail("saved visuals are from generator version [h["version"]], this build is [MAPVIS_VERSION]")
	if(text2num(h["maxx"]) != world.maxx || text2num(h["maxy"]) != world.maxy || text2num(h["maxz"]) != world.maxz)
		return MapVisFail("the map size changed")
	if(text2num(h["foam"]) != (glob && glob.SHORE_FOAM ? 1 : 0))
		return MapVisFail("the shoreline foam setting changed")
	var/list/palLines = MapVisLines(gd + "palette.txt")
	var/list/tileLines = MapVisLines(gd + "tiles.txt")
	var/list/chunkLines = MapVisLines(gd + "chunks.txt")
	if(!palLines || !tileLines || !chunkLines)
		return MapVisFail("the saved visuals are incomplete")
	ElevMapLoad()
	BuildCliffPaintLoad()
	BuildFoamPaintLoad()
	var/list/stored = list()
	for(var/l in chunkLines)
		var/list/f = splittext(l, "\t")
		if(f.len >= 2 && isnull(stored[f[1]]))
			stored += f[1]
			stored[f[1]] = f[2]
	var/list/snapTiles = list()
	for(var/l in tileLines)
		var/ci = findtext(l, "\t")
		var/list/c = splittext(copytext(l, 1, ci), ",")
		if(c.len >= 3)
			var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
			if(T)
				snapTiles += T
	var/list/S = MapVisCoreScope(snapTiles)
	for(var/k in stored)
		MapVisScopeAdd(S, k)
	var/list/H = MapVisHashChunks(S)
	var/list/dirty = list()
	var/list/dirtyTiles = list()
	for(var/k in H)
		var/sv = stored[k]
		var/hv = H[k]
		if(sv == hv)
			continue
		dirty += k
		dirty[k] = 1
		var/list/c = splittext(k, ",")
		var/z = text2num(c[1])
		var/x0 = text2num(c[2]) * MAPVIS_CHUNK
		var/y0 = text2num(c[3]) * MAPVIS_CHUNK
		for(var/i = 1 to MAPVIS_CHUNK * MAPVIS_CHUNK)
			var/a = (i - 1) * 8 + 1
			if(sv && copytext(sv, a, a + 8) == copytext(hv, a, a + 8))
				continue
			var/turf/T = locate(x0 + ((i - 1) % MAPVIS_CHUNK) + 1, y0 + round((i - 1) / MAPVIS_CHUNK) + 1, z)
			if(T)
				dirtyTiles += T
	var/t1 = world.timeofday
	var/list/icons = list()
	var/list/pal = new/list(palLines.len)
	for(var/i = 1 to palLines.len)
		var/list/f = splittext(palLines[i], "\t")
		if(f.len < 15)
			return MapVisFail("a saved appearance is damaged")
		var/res = MapVisIconLoad(f[1], icons)
		if(res == 0)
			return MapVisFail("saved icon [f[1]] is missing")
		var/image/I = image(res, null, f[2])
		I.dir = text2num(f[3])
		I.layer = text2num(f[4])
		I.plane = text2num(f[5])
		I.pixel_x = text2num(f[6])
		I.pixel_y = text2num(f[7])
		I.pixel_w = text2num(f[8])
		I.pixel_z = text2num(f[9])
		I.alpha = text2num(f[10])
		I.blend_mode = text2num(f[11])
		I.appearance_flags = text2num(f[12])
		if(length(f[13]))
			if(copytext(f[13], 1, 2) == "m")
				var/list/cm = list()
				for(var/v in splittext(copytext(f[13], 2), ","))
					cm += text2num(v)
				I.color = cm
			else
				I.color = f[13]
		if(length(f[14]))
			var/list/tm = splittext(f[14], ",")
			I.transform = matrix(text2num(tm[1]), text2num(tm[2]), text2num(tm[3]), text2num(tm[4]), text2num(tm[5]), text2num(tm[6]))
		if(length(f[15]))
			for(var/fs in splittext(f[15], ";"))
				var/list/p = splittext(fs, ",")
				var/fres = MapVisIconLoad(p[3], icons)
				if(fres == 0)
					return MapVisFail("saved mask icon [p[3]] is missing")
				I.filters += filter(type = "alpha", icon = fres, x = text2num(p[1]), y = text2num(p[2]), flags = text2num(p[4]))
		pal[i] = I
		if(i % 500 == 0)
			MapVisYield()
	var/t2 = world.timeofday
	for(var/turf/T in mapVisTiles)
		MapVisClearTile(T)
	mapVisTiles = list()
	buildOrgFinal = list()
	var/list/restored = list()
	for(var/l in tileLines)
		var/list/f = splittext(l, "\t")
		if(f.len < 4)
			continue
		var/list/c = splittext(f[1], ",")
		var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
		if(!T)
			continue
		MapVisClearTile(T)
		if(length(f[2]))
			var/list/el = list()
			for(var/v in splittext(f[2], ","))
				el += pal[text2num(v)]
			T.overlays += el
			T.elevOverlays = el
		if(length(f[3]))
			var/list/gl = list()
			for(var/v in splittext(f[3], ","))
				var/image/G = pal[text2num(v)]
				gl += G
				T.overlays += G
			T.edgeOverlays = gl
		if(length(f[4]))
			var/list/fin = MapVisFinList(f[4])
			if(fin)
				buildOrgFinal += T
				buildOrgFinal[T] = fin
		MapVisReg(T)
		restored += T
	var/t3 = world.timeofday
	var/bad = MapVisSpotCheck(restored, dirty)
	if(bad)
		for(var/turf/T in mapVisTiles)
			MapVisClearTile(T)
		mapVisTiles = list()
		buildOrgFinal = list()
		return MapVisFail("the spot check found a changed tile ([bad])")
	var/t4 = world.timeofday
	world.log << "MAPVIS restored [cur[1]]: [restored.len] tiles, [palLines.len] appearances, [icons.len] icons; [dirtyTiles.len] changed tiles in [dirty.len] of [H.len] chunks; fingerprints [(t1 - t0) / 10] s, palette [(t2 - t1) / 10] s, tiles [(t3 - t2) / 10] s, spot check [(t4 - t3) / 10] s"
	Log("Mapper", "Map visuals restored from the save ([restored.len] tiles); [dirtyTiles.len] changed tiles rebuild in the background.", 1)
	if(dirtyTiles.len)
		MapVisDirtyRebuild(dirtyTiles)
	else
		mapVisReady = 1
	return 1

/proc/MapVisIconLoad(id, list/icons)
	if(!length(id))
		return null
	var/res = icons[id]
	if(res)
		return res
	var/p = MAPVIS_DIR + "icons/[id].dmi"
	if(!fexists(p))
		return 0
	res = fcopy_rsc(file(p))
	if(!res)
		return 0
	icons += id
	icons[id] = res
	var/rk = "\ref[res]"
	if(isnull(mapVisIconIds[rk]))
		mapVisIconIds += rk
	mapVisIconIds[rk] = id
	return res

/proc/MapVisClearTile(turf/T)
	if(T.elevOverlays)
		T.overlays -= T.elevOverlays
		T.elevOverlays = null
	if(T.edgeOverlays)
		for(var/img in T.edgeOverlays)
			T.overlays -= img
		T.edgeOverlays = null
	T.mapvis_in = 0

/proc/MapVisSig(turf/T)
	var/list/e = list()
	for(var/image/I in T.elevOverlays)
		e += MapVisRecord(I)
	var/list/g = list()
	for(var/image/I2 in T.edgeOverlays)
		g += MapVisRecord(I2)
	return "[jointext(e, "#")]@[jointext(g, "#")]"

/proc/MapVisSpotCheck(list/restored, list/dirty)
	var/list/pool = list()
	for(var/turf/T in restored)
		var/cx = round((T.x - 1) / MAPVIS_CHUNK)
		var/cy = round((T.y - 1) / MAPVIS_CHUNK)
		var/near = 0
		for(var/dx = -1 to 1)
			for(var/dy = -1 to 1)
				if(dirty["[T.z],[cx + dx],[cy + dy]"])
					near = 1
		if(!near)
			pool += T
	if(!pool.len)
		return null
	var/stride = max(1, round(pool.len / MAPVIS_SPOT))
	for(var/i = 1, i <= pool.len, i += stride)
		var/turf/T = pool[i]
		var/before = MapVisSig(T)
		ElevVisualUpdate(T)
		var/list/fin = buildOrgFinal[T]
		if(fin)
			buildOrgOverride = list()
			buildOrgOverride[T] = fin
		BuildEdgeUpdate(T, 1)
		buildOrgOverride = null
		var/after = MapVisSig(T)
		if(before != after)
			world.log << "MAPVIS spot check mismatch at [T.x],[T.y],[T.z]"
			world.log << "MAPVIS   saved:   [copytext(before, 1, 600)]"
			world.log << "MAPVIS   rebuilt: [copytext(after, 1, 600)]"
			return "[T.x],[T.y],[T.z]"
		MapVisYield()
	return null

/proc/MapVisWaitWrite(limit = 600)
	var/t = 0
	while(mapVisWriting && t < limit)
		sleep(10)
		t += 10

/proc/MapVisDirtyRebuild(list/dt)
	set waitfor = FALSE
	set background = TRUE
	var/t0 = world.timeofday
	mapVisReady = 0
	buildBootPassMark = world.timeofday
	ElevVisualRefresh(dt, 1)
	BuildEdgeSmoothAround(dt, 1, 1)
	world.log << "MAPVIS rebuilt around [dt.len] changed tiles in [(world.timeofday - t0) / 10] s"
	mapVisReady = 1
	MapVisSaveSoon()
