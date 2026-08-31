/datum/build_import_ctx
	var
		text = ""
		pos = 1
		len = 0
		keyLen = 0
		list/dict = list()
		list/rows = list()
		list/unknownPaths = list()
		list/skippedVars = list()
		multiZ = 0
		varErrors = 0

/proc/BuildDmmUnescape(s)
	var/out = ""
	var/L = length(s)
	var/i = 1
	while(i <= L)
		var/ch = copytext(s, i, i + 1)
		if(ch == "\\" && i < L)
			var/nx = copytext(s, i + 1, i + 2)
			switch(nx)
				if("n")
					out += "\n"
				if("t")
					out += "\t"
				else
					out += nx
			i += 2
			continue
		out += ch
		i++
	return out

/proc/BuildImportParseValue(t)
	t = trimtext(t)
	if(!length(t))
		return list("ok" = 0, "v" = null, "why" = "empty value")
	var/first = copytext(t, 1, 2)
	if(first == "\"")
		return list("ok" = 1, "v" = BuildDmmUnescape(copytext(t, 2, length(t))))
	if(first == "'")
		var/p = copytext(t, 2, length(t))
		if(fexists(p))
			return list("ok" = 1, "v" = file(p))
		return list("ok" = 0, "v" = null, "why" = "missing file [p]")
	if(t == "null")
		return list("ok" = 1, "v" = null)
	var/n = text2num(t)
	if(isnull(n))
		return list("ok" = 0, "v" = null, "why" = "unparseable [copytext(t, 1, min(length(t), 30) + 1)]")
	return list("ok" = 1, "v" = n)

/proc/BuildImportSplitTop(t, sep)
	var/list/out = list()
	var/depth = 0
	var/inq = 0
	var/start = 1
	var/L = length(t)
	for(var/i = 1 to L)
		var/ch = copytext(t, i, i + 1)
		if(inq)
			if(ch == "\\")
				i++
			else if(ch == inq)
				inq = 0
			continue
		if(ch == "\"" || ch == "'")
			inq = ch
			continue
		if(ch == "{" || ch == "(")
			depth++
			continue
		if(ch == "}" || ch == ")")
			depth--
			continue
		if(ch == sep && depth == 0)
			out += copytext(t, start, i)
			start = i + 1
	out += copytext(t, start, L + 1)
	return out

/proc/BuildImportParseEntry(t, datum/build_import_ctx/ctx)
	t = trimtext(t)
	var/list/overrides = list()
	var/brace = findtext(t, "{")
	var/pathtext = t
	if(brace)
		pathtext = trimtext(copytext(t, 1, brace))
		var/inner = copytext(t, brace + 1, length(t))
		for(var/pair in BuildImportSplitTop(inner, ";"))
			pair = trimtext(pair)
			if(!length(pair))
				continue
			var/eq = findtext(pair, "=")
			if(!eq)
				continue
			var/vn = trimtext(copytext(pair, 1, eq))
			var/list/pv = BuildImportParseValue(copytext(pair, eq + 1))
			if(pv["ok"])
				overrides[vn] = pv["v"]
			else
				var/sk = "[pathtext].[vn]: [pv["why"]]"
				ctx.skippedVars[sk] = (ctx.skippedVars[sk] || 0) + 1
	var/path = text2path(pathtext)
	if(!path)
		ctx.unknownPaths[pathtext] = (ctx.unknownPaths[pathtext] || 0) + 1
		return null
	return list("path" = path, "vars" = overrides)

/proc/BuildImportParse(fname)
	var/t = file2text(fname)
	if(!t)
		return null
	var/datum/build_import_ctx/ctx = new
	ctx.text = t
	ctx.len = length(t)
	var/pos = 1
	while(1)
		var/q1 = findtext(t, "\"", pos)
		if(!q1)
			return null
		var/q2 = findtext(t, "\"", q1 + 1)
		if(!q2)
			return null
		var/key = copytext(t, q1 + 1, q2)
		if(findtext(key, "\n"))
			return null
		var/par = findtext(t, "(", q2)
		if(!par)
			return null
		var/depth = 1
		var/inq = 0
		var/i = par + 1
		while(depth > 0 && i <= ctx.len)
			var/ch = copytext(t, i, i + 1)
			if(inq)
				if(ch == "\\")
					i++
				else if(ch == inq)
					inq = 0
			else if(ch == "\"" || ch == "'")
				inq = ch
			else if(ch == "(")
				depth++
			else if(ch == ")")
				depth--
			i++
		var/body = copytext(t, par + 1, i - 1)
		if(!ctx.keyLen)
			ctx.keyLen = length(key)
		var/list/entries = list()
		for(var/et in BuildImportSplitTop(body, ","))
			var/list/E = BuildImportParseEntry(et, ctx)
			if(E)
				entries += list(E)
		ctx.dict[key] = entries
		pos = i
		var/nq = findtext(t, "\"", pos)
		var/gh = findtext(t, "(1,1,1)", pos)
		if(!gh)
			gh = findtext(t, "\n(", pos)
		if(gh && (!nq || gh < nq))
			break
		if(!nq)
			break
	var/gs = findtext(t, "{\"", pos)
	if(!gs)
		return null
	var/ge = findtext(t, "\"}", gs + 2)
	if(!ge)
		return null
	var/grid = copytext(t, gs + 2, ge)
	for(var/row in splittext(grid, "\n"))
		row = trimtext(row)
		if(length(row))
			ctx.rows += row
	if(findtext(t, "{\"", ge + 2))
		ctx.multiZ = 1
	return ctx

/proc/BuildImportDMM(fname, ox, oy, oz, mob/M)
	var/datum/build_import_ctx/ctx = BuildImportParse(fname)
	if(!ctx)
		return "Import failed: could not parse [fname]."
	if(!ctx.rows.len || !ctx.keyLen)
		return "Import failed: no grid rows in [fname]."
	var/cols = round(length(ctx.rows[1]) / ctx.keyLen)
	var/rowsN = ctx.rows.len
	if(ox < 1 || oy < 1 || oz < 1 || oz > world.maxz || ox + cols - 1 > world.maxx || oy + rowsN - 1 > world.maxy)
		return "Import refused: [cols]x[rowsN] at ([ox],[oy]) z[oz] exceeds world bounds."
	var/placedCells = 0
	var/placedObjs = 0
	var/n = 0
	for(var/j = 1 to rowsN)
		var/row = ctx.rows[j]
		var/y = oy + (rowsN - j)
		for(var/i = 1 to cols)
			var/key = copytext(row, (i - 1) * ctx.keyLen + 1, i * ctx.keyLen + 1)
			var/list/entries = ctx.dict[key]
			if(!entries)
				continue
			var/x = ox + i - 1
			var/turf/T = locate(x, y, oz)
			if(!T)
				continue
			var/list/objEntries = list()
			var/list/turfEntry = null
			var/list/areaEntry = null
			for(var/list/E in entries)
				var/p = E["path"]
				if(ispath(p, /area))
					areaEntry = E
				else if(ispath(p, /turf))
					turfEntry = E
				else if(ispath(p, /obj))
					objEntries += list(E)
			if(turfEntry)
				BuildUntrackTurf(T)
				var/tp = turfEntry["path"]
				var/turf/NT = new tp(T)
				BuildImportApplyVars(NT, turfEntry["vars"], ctx)
				if(istype(NT, /turf/CustomTurf))
					var/turf/CustomTurf/CT = NT
					CT.InitialType = "/turf/CustomTurf"
				if(M)
					NT.Builder = M.ckey
					if(istype(NT, /turf/CustomTurf))
						CustomTurfs += NT
					else
						Turfs += NT
				T = NT
				LightingRecomputeNear(T)
			for(var/list/E in objEntries)
				var/tp2 = E["path"]
				var/obj/O = new tp2(T)
				BuildImportApplyVars(O, E["vars"], ctx)
				if(M)
					O.Builder = M.ckey
					O.Savable = 1
					worldObjectList += O
				GfxRefreshStructureMetadata(O)
				placedObjs++
			if(areaEntry && areaEntry["path"] != /area)
				var/aid = ""
				var/apath = areaEntry["path"]
				if(apath == /area/MapperZone)
					var/list/ov = areaEntry["vars"]
					var/znm = ov["name"]
					if(istext(znm) && length(znm))
						var/datum/build_zone_def/ZD = BuildZoneFind(znm)
						if(!ZD)
							ZD = BuildZoneCreate(znm, M ? M.ckey : "import", 0)
							if(!isnull(ov["sees_sky"]))
								ZD.sees_sky = ov["sees_sky"]
							if(istext(ov["wx_kind"]))
								ZD.wx_kind = ov["wx_kind"]
							if(istext(ov["env_profile_id"]))
								ZD.profile = ov["env_profile_id"]
							if(isnum(ov["zone_wind_mult"]))
								ZD.windMult = ov["zone_wind_mult"]
							BuildZoneApply(ZD)
							BuildZonesSave()
						aid = "/area/MapperZone#[ZD.name]"
				else
					aid = "[apath]"
				if(length(aid) && BuildAreaSetId(T, aid) && M)
					BuildAreaPaintLoad()
					areaPaintMap["[T.x],[T.y],[T.z]"] = aid
			placedCells++
			n++
			if(n % BUILD_COMMIT_CHUNK == 0)
				sleep(-1)
	if(placedCells)
		BuildEdgeSmoothAround(TurfSquare(ox, oy, ox + cols - 1, oy + rowsN - 1, oz, 0), 1)
		BuildCustomRefreshSessions()
	if(M && placedCells)
		spawn BuildSaveWorldData()
	var/list/rep = list()
	rep += "Imported [fname]: [placedCells] cells, [placedObjs] objects at ([ox],[oy]) z[oz] ([cols]x[rowsN])."
	if(ctx.multiZ)
		rep += "WARNING: file contains multiple z-level blocks; only the FIRST was imported."
	for(var/pt in ctx.unknownPaths)
		rep += "Unknown type skipped: [pt] x[ctx.unknownPaths[pt]]"
	for(var/sk in ctx.skippedVars)
		rep += "Skipped override [sk] x[ctx.skippedVars[sk]]"
	if(ctx.varErrors)
		rep += "[ctx.varErrors] var assignments failed."
	return jointext(rep, "\n")

/proc/BuildImportApplyVars(atom/A, list/overrides, datum/build_import_ctx/ctx)
	for(var/vn in overrides)
		try
			A.vars[vn] = overrides[vn]
		catch
			ctx.varErrors++

mob/Mapper/verb/Import_Map_File()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	usr << "IMPORT: type the file name only (it looks in Exports/, no extension)."
	spawn
		var/nm = HUDTextPrompt("Import which file?", "")
		if(isnull(nm) || !length(nm))
			return
		var/fname = "Exports/[ckey(nm)].dmm"
		BuildBeginImport(usr, S, fname)

mob/Mapper/verb/Place_Prefab()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	var/list/names = list()
	for(var/f in flist("Prefabs/"))
		if(copytext(f, length(f) - 3) == ".dmm")
			names += copytext(f, 1, length(f) - 3)
	if(!names.len)
		usr << "No prefabs saved yet - use Save Prefab to stamp a region into Prefabs/."
		return
	usr << "PREFABS: [jointext(names, ", ")]"
	spawn
		var/nm = HUDTextPrompt("Place which prefab?", names[1])
		if(isnull(nm) || !length(nm))
			return
		BuildBeginImport(usr, S, "Prefabs/[ckey(nm)].dmm")

/proc/BuildBeginImport(mob/M, datum/build_session/S, fname)
	if(!fexists(fname))
		M << "No such file: [fname]"
		return
	var/datum/build_import_ctx/ctx = BuildImportParse(fname)
	if(!ctx || !ctx.rows.len || !ctx.keyLen)
		M << "Could not parse [fname]."
		return
	S.CancelPending()
	S.importFile = fname
	S.importW = round(length(ctx.rows[1]) / ctx.keyLen)
	S.importH = ctx.rows.len
	S.importStage = 1
	M << "IMPORT: [fname] is [S.importW]x[S.importH] tiles. ONE click places the whole map - click where its BOTTOM-LEFT corner should land. Right-click cancels."
