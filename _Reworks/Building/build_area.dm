#define BUILD_CAT_ZONES "ZONES"
#define BUILD_COMMIT_CHUNK 400
#define AREA_PAINT_FILE "Saves/AreaPaint.txt"

var/global/list/areaPaintMap
var/global/list/zoneDefs
var/global/list/zoneDefsByName
var/global/list/zoneDefsByUid

area/var/zone_wind_mult = 1

area/MapperZone
	name = "mapper zone"

area/MapperZone/var/zoneKey = ""

/datum/build_zone_def
	var
		name = ""
		uid = ""
		creator = ""
		sees_sky = 1
		wx_kind = ""
		profile = "default"
		windMult = 1
		dnMode = ""
		moon = 0
		area/MapperZone/inst

/proc/BuildZoneUid()
	return "u[copytext(md5("[world.realtime]|[world.time]|[rand(100000, 999999)]"), 1, 9)]"

/proc/BuildZoneSanitizeName(nm)
	nm = replacetext(nm, "\t", " ")
	nm = replacetext(nm, "\n", " ")
	return trimtext(nm)

/proc/BuildZoneWxWanted(datum/build_zone_def/D)
	if(!D || !D.sees_sky || !length(D.wx_kind))
		return null
	return D.wx_kind

/proc/BuildZoneWxRestore(area/MapperZone/MZ)
	if(!MZ || !zoneDefsByUid)
		return
	var/datum/build_zone_def/D = zoneDefsByUid[MZ.zoneKey]
	if(!D || D.inst != MZ)
		return
	var/wantWx = BuildZoneWxWanted(D)
	if(MZ.wx_kind != wantWx || (wantWx && !MZ.wx_tint))
		WxSet(MZ, wantWx)

/proc/BuildZoneApply(datum/build_zone_def/D)
	if(!length(D.uid))
		D.uid = BuildZoneUid()
	if(!D.inst)
		D.inst = new
	D.inst.zoneKey = D.uid
	D.inst.name = D.name
	D.inst.sees_sky = D.sees_sky
	D.inst.env_profile_id = D.profile
	D.inst.zone_wind_mult = D.windMult
	var/dnOld = D.inst.dn_fixed
	var/moonOld = D.inst.zone_moon
	D.inst.dn_fixed = D.sees_sky ? D.dnMode : ""
	D.inst.zone_moon = (D.sees_sky && D.moon) ? 1 : 0
	GfxWindChanged()
	DnManageArea(D.inst, D.sees_sky)
	if(dnOld != D.inst.dn_fixed || moonOld != D.inst.zone_moon)
		DnZoneLightingChanged(D.inst)
		if(D.inst.zone_moon && !moonOld)
			BuildZoneMoonTriggerInside(D.inst)
	var/wantWx = BuildZoneWxWanted(D)
	if(D.inst.wx_kind != wantWx || (wantWx && !D.inst.wx_tint))
		WxSet(D.inst, wantWx)
	for(var/client/CC)
		CC.gfx_env_profile_id = null

/proc/BuildZoneTimeValid(m)
	if(m == "day" || m == "dusk" || m == "night" || m == "dawn" || m == "indoor")
		return m
	return ""

/proc/BuildZoneTimeLabel(mode)
	switch(mode)
		if("day")
			return "ALWAYS DAY"
		if("dusk")
			return "ALWAYS DUSK"
		if("night")
			return "ALWAYS NIGHT"
		if("dawn")
			return "ALWAYS DAWN"
		if("indoor")
			return "INDOORS (no day-night tint)"
	return "WORLD CLOCK"

/proc/BuildZoneMoonTriggerInside(area/A)
	if(!A)
		return
	for(var/mob/Players/P in players)
		var/turf/T = P.loc
		if(isturf(T) && T.loc == A)
			spawn P.MoonTrigger()

area/MapperZone/Entered(atom/movable/O, atom/oldloc)
	..()
	if(zone_moon && istype(O, /mob/Players))
		var/mob/Players/P = O
		spawn P.MoonTrigger()

/proc/BuildZonesLoad()
	if(zoneDefs)
		return zoneDefs
	zoneDefs = list()
	zoneDefsByName = list()
	zoneDefsByUid = list()
	if(!fexists("Saves/MapperZones.txt"))
		return zoneDefs
	var/t = file2text("Saves/MapperZones.txt")
	for(var/line in splittext(t, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 6)
			continue
		var/datum/build_zone_def/D = new
		D.name = BuildDmmUnescape(f[1])
		D.creator = f[2]
		D.sees_sky = text2num(f[3]) || 0
		D.wx_kind = BuildDmmUnescape(f[4])
		D.profile = BuildDmmUnescape(f[5])
		var/wm = text2num(f[6])
		D.windMult = isnull(wm) ? 1 : wm
		if(f.len >= 7 && length(f[7]))
			D.uid = f[7]
		else
			D.uid = D.name
		if(f.len >= 8)
			D.dnMode = BuildZoneTimeValid(f[8])
		if(f.len >= 9)
			D.moon = text2num(f[9]) || 0
		BuildZoneApply(D)
		zoneDefs += D
		zoneDefsByName[D.name] = D
		zoneDefsByUid[D.uid] = D
	return zoneDefs

/proc/BuildZonesSave()
	if(!zoneDefs)
		return
	var/list/lines = list()
	for(var/datum/build_zone_def/D in zoneDefs)
		lines += jointext(list(BuildDmmEscape(D.name), D.creator, "[D.sees_sky]", BuildDmmEscape(D.wx_kind), BuildDmmEscape(D.profile), "[D.windMult]", D.uid, D.dnMode, "[D.moon]"), "\t")
	if(fexists("Saves/MapperZones.txt"))
		fdel("Saves/MapperZones.txt")
	text2file(jointext(lines, "\n"), "Saves/MapperZones.txt")

/proc/BuildZoneFind(nm)
	BuildZonesLoad()
	return zoneDefsByName[nm]

/proc/BuildZoneEntry(datum/build_zone_def/D)
	var/datum/build_entry/E = new
	E.name = "-ZONE: [D.name]-"
	E.iconF = 'HUD/build_white.png'
	E.Creates = /area/MapperZone
	E.category = BUILD_CAT_ZONES
	E.isZone = 1
	E.zoneRef = D
	var/h = md5("zone[D.name]")
	E.swatchColor = "#[copytext(h, 1, 7)]"
	return E

/proc/BuildZoneCreate(nm, ck, refresh = 1)
	BuildZonesLoad()
	nm = BuildZoneSanitizeName(nm)
	if(!length(nm))
		return null
	if(zoneDefsByName[nm])
		return zoneDefsByName[nm]
	var/datum/build_zone_def/D = new
	D.name = nm
	D.creator = ck
	BuildZoneApply(D)
	zoneDefs += D
	zoneDefsByName[nm] = D
	zoneDefsByUid[D.uid] = D
	BuildZonesSave()
	if(buildPalette)
		buildPalette += BuildZoneEntry(D)
	if(refresh)
		BuildCustomRefreshSessions()
	return D

/proc/BuildAreaIdOf(area/A)
	if(istype(A, /area/MapperZone))
		var/area/MapperZone/MZ = A
		return "[A.type]#[MZ.zoneKey]"
	return "[A?.type]"

/proc/BuildAreaResolve(idt)
	var/h = findtext(idt, "#")
	if(h)
		var/key = copytext(idt, h + 1)
		BuildZonesLoad()
		var/datum/build_zone_def/D = zoneDefsByUid[key]
		if(!D)
			D = zoneDefsByName[key]
		return D?.inst
	var/tp = text2path(idt)
	if(!tp || !ispath(tp, /area))
		return null
	return BuildAreaInstance(tp)

/proc/BuildAreaSetId(turf/T, idt)
	var/area/AR = BuildAreaResolve(idt)
	if(!T || !AR)
		return 0
	if(T.loc == AR)
		return 0
	AR.contents += T
	return 1

/proc/BuildZoneName(p)
	var/t = "[p]"
	if(t == "/area")
		return "NO ZONE (base)"
	if(copytext(t, 1, 7) == "/area/")
		return copytext(t, 7)
	return t

/proc/BuildAreaPaintLoad()
	if(areaPaintMap)
		return areaPaintMap
	areaPaintMap = list()
	if(!fexists(AREA_PAINT_FILE))
		return areaPaintMap
	var/t = file2text(AREA_PAINT_FILE)
	for(var/line in splittext(t, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		areaPaintMap[f[1]] = f[2]
	return areaPaintMap

/proc/BuildAreaPaintSave()
	if(!areaPaintMap)
		return
	var/list/lines = list()
	var/chunkCount = 0
	for(var/k in areaPaintMap)
		lines += "[k]\t[areaPaintMap[k]]"
		if(++chunkCount % 5000 == 0)
			sleep(world.tick_lag)
	if(fexists(AREA_PAINT_FILE))
		fdel(AREA_PAINT_FILE)
	text2file(jointext(lines, "\n"), AREA_PAINT_FILE)

/proc/BuildAreaExisting(path)
	var/area/AR = locate(path)
	if(AR && AR.type != path)
		AR = null
		for(var/area/A2 in world)
			if(A2.type == path)
				return A2
	return AR

/proc/BuildAreaInstance(path)
	var/area/AR = BuildAreaExisting(path)
	if(!AR)
		AR = new path
		DnRegisterNewArea(AR)
	return AR

/proc/BuildAreaSet(turf/T, path)
	if(!T || !ispath(path, /area))
		return 0
	var/curp = T.loc?.type
	if(curp == path)
		return 0
	var/area/AR = BuildAreaInstance(path)
	AR.contents += T
	return 1

var/global/list/zoneProfileMap

/proc/BuildZoneProfileLoad()
	if(zoneProfileMap)
		return zoneProfileMap
	zoneProfileMap = list()
	if(!fexists("Saves/ZoneProfiles.txt"))
		return zoneProfileMap
	var/t = file2text("Saves/ZoneProfiles.txt")
	for(var/line in splittext(t, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		zoneProfileMap[f[1]] = f[2]
	return zoneProfileMap

/proc/BuildZoneProfileSave()
	if(!zoneProfileMap)
		return
	var/list/lines = list()
	for(var/k in zoneProfileMap)
		lines += "[k]\t[zoneProfileMap[k]]"
	if(fexists("Saves/ZoneProfiles.txt"))
		fdel("Saves/ZoneProfiles.txt")
	text2file(jointext(lines, "\n"), "Saves/ZoneProfiles.txt")

/proc/BuildZoneProfileRecord(areatype, pid)
	BuildZoneProfileLoad()
	zoneProfileMap["[areatype]"] = pid
	BuildZoneProfileSave()

/proc/BuildZoneProfileApplyBoot()
	BuildZoneProfileLoad()
	if(!zoneProfileMap.len)
		return
	var/applied = 0
	for(var/k in zoneProfileMap)
		if(findtext(k, "/area/MapperZone"))
			continue
		var/tp = text2path(k)
		if(!tp)
			continue
		var/area/A = BuildAreaExisting(tp)
		if(!A)
			continue
		A.env_profile_id = zoneProfileMap[k]
		applied++
	if(applied)
		Log("Mapper", "Zone environment profiles restored on [applied] areas at boot.", 1)
		for(var/client/CC)
			CC.gfx_env_profile_id = null

mob/Mapper/verb/Create_Zone()
	set category = "Mapper"
	spawn
		var/nm = usr.HUDTextPrompt("Name the new zone", "")
		if(isnull(nm) || !length(nm))
			return
		BuildZonesLoad()
		var/datum/build_zone_def/EX = zoneDefsByName[nm]
		if(EX)
			usr << "A zone named \"[nm]\" already exists (by [EX.creator])."
			return
		var/datum/build_zone_def/D = BuildZoneCreate(nm, usr.ckey)
		usr << "Zone \"[D.name]\" created - paint it from the ZONES palette, tune it with Zone_Settings."
		Log("Mapper", "[usr] ([usr.ckey]) created zone \"[D.name]\".", 1)

mob/Mapper/verb/Zone_Settings()
	set category = "Mapper"
	BuildZonesLoad()
	var/list/mine = list()
	for(var/datum/build_zone_def/D in zoneDefs)
		if(D.creator == usr.ckey || usr.Admin)
			mine["[D.name] (by [D.creator])"] = D
	if(!mine.len)
		usr << "You have no zones. Create_Zone makes one."
		return
	var/pick = Ask(usr, "Which zone?", "Zone Settings", null, "pick", mine, 1)
	if(!pick)
		return
	var/datum/build_zone_def/D = mine[pick]
	while(D)
		var/sky = D.sees_sky ? "OUTDOOR" : "INDOOR/CAVE"
		var/wx = length(D.wx_kind) ? D.wx_kind : "clear"
		var/tm = BuildZoneTimeLabel(D.dnMode)
		var/fm = D.moon ? "ON" : "OFF"
		var/list/menu = list("Sky: [sky]", "Time: [tm]", "Full moon: [fm]", "Weather: [wx]", "Profile: [D.profile]", "Wind: [D.windMult * 100]%", "Rename", "Done")
		var/choice = Ask(usr, "Zone \"[D.name]\" - pick a setting.", "Zone Settings", null, "pick", menu, 1)
		if(!choice || choice == "Done")
			break
		if(choice == "Sky: [sky]")
			D.sees_sky = !D.sees_sky
			usr << "\"[D.name]\" is now [D.sees_sky ? "OUTDOOR (sky, day/night, weather)" : "INDOOR/CAVE (no sky effects)"]."
		else if(choice == "Time: [tm]")
			var/list/times = list("World clock" = "", "Always day" = "day", "Always dusk" = "dusk", "Always night" = "night", "Always dawn" = "dawn", "Indoors - no day-night tint, keeps weather, wind and profile effects" = "indoor")
			var/t = Ask(usr, "Lighting for \"[D.name]\" (only applies while Sky is OUTDOOR).", "Zone Time", null, "pick", times, 1)
			if(!t)
				continue
			D.dnMode = times[t]
		else if(choice == "Full moon: [fm]")
			D.moon = !D.moon
			usr << "\"[D.name]\" full moon [D.moon ? "ON - a permanent moonlit night in this zone; Saiyans who look at the moon transform when they enter (needs Sky: OUTDOOR)" : "OFF"]."
		else if(choice == "Weather: [wx]")
			var/list/kinds = list("clear", "rain", "storm", "snow", "blizzard", "dust")
			var/k = Ask(usr, "Weather in \"[D.name]\" (static for this zone).", "Zone Weather", null, "pick", kinds, 1)
			if(!k)
				continue
			D.wx_kind = (k == "clear") ? "" : k
		else if(choice == "Profile: [D.profile]")
			var/list/options = list()
			for(var/id in _env_profiles)
				var/datum/environment_profile/EP = _env_profiles[id]
				options["[EP.display_name] ([id])"] = id
			var/p = Ask(usr, "Environment profile for \"[D.name]\".", "Zone Profile", null, "pick", options, 1)
			if(!p)
				continue
			D.profile = options[p]
		else if(choice == "Wind: [D.windMult * 100]%")
			spawn
				var/w = usr.HUDNumPrompt("Wind percent (100 = normal)", D.windMult * 100)
				if(isnull(w))
					return
				D.windMult = clamp(w, 0, 500) / 100
				BuildZoneApply(D)
				BuildZonesSave()
				usr << "\"[D.name]\" wind set to [D.windMult * 100]%."
				Log("Mapper", "[usr] ([usr.ckey]) set zone \"[D.name]\" wind to [D.windMult * 100]%.", 1)
			break
		else if(choice == "Rename")
			spawn
				var/nn = usr.HUDTextPrompt("New name", D.name)
				if(isnull(nn) || !length(nn))
					return
				nn = BuildZoneSanitizeName(nn)
				if(!length(nn) || nn == D.name)
					return
				if(zoneDefsByName[nn])
					usr << "A zone named \"[nn]\" already exists."
					return
				zoneDefsByName -= D.name
				var/wasName = D.name
				D.name = nn
				zoneDefsByName[nn] = D
				BuildZoneApply(D)
				BuildZonesSave()
				buildPalette = null
				BuildPaletteInit()
				BuildCustomRefreshSessions()
				usr << "Zone renamed to \"[nn]\"."
				Log("Mapper", "[usr] ([usr.ckey]) renamed zone \"[wasName]\" to \"[nn]\".", 1)
			break
		BuildZoneApply(D)
		BuildZonesSave()
		Log("Mapper", "[usr] ([usr.ckey]) updated zone \"[D.name]\": [choice].", 1)

/proc/BuildZoneCanPaint(area/MapperZone/MZ, mob/M)
	if(!MZ || !M)
		return 0
	if(M.Admin)
		return 1
	BuildZonesLoad()
	var/datum/build_zone_def/D = zoneDefsByUid[MZ.zoneKey]
	if(!D)
		D = zoneDefsByName[MZ.zoneKey]
	return (D && D.inst == MZ && D.creator == M.ckey) ? 1 : 0

/proc/BuildAreaSampleOutdoor(turf/T, mob/painter = null)
	var/fallback = null
	var/blocked = 0
	for(var/r = 1 to 8)
		for(var/dx = -r to r)
			for(var/dy = -r to r)
				if(max(abs(dx), abs(dy)) != r)
					continue
				var/turf/T2 = locate(T.x + dx, T.y + dy, T.z)
				if(!T2)
					continue
				var/area/A2 = T2.loc
				if(!A2 || A2.type == /area/Inside)
					continue
				if(istype(A2, /area/MapperZone))
					if(!painter || !A2.sees_sky)
						continue
					if(BuildZoneCanPaint(A2, painter))
						return BuildAreaIdOf(A2)
					blocked = 1
					continue
				if(A2.sees_sky)
					return "[A2.type]"
				if(!fallback)
					fallback = "[A2.type]"
	return blocked ? "" : fallback

/proc/BuildZoneDelete(datum/build_zone_def/D, mob/M)
	set waitfor = FALSE
	set background = TRUE
	BuildZonesLoad()
	BuildAreaPaintLoad()
	var/list/tiles = list()
	if(D.inst)
		for(var/turf/T in D.inst)
			tiles += T
	var/moved = 0
	var/n = 0
	for(var/turf/T in tiles)
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
		var/newid = BuildAreaSampleOutdoor(T)
		if(!newid)
			newid = "/area"
		if(BuildAreaSetId(T, newid))
			moved++
		areaPaintMap["[T.x],[T.y],[T.z]"] = newid
	zoneDefs -= D
	zoneDefsByName -= D.name
	zoneDefsByUid -= D.uid
	BuildZonesSave()
	BuildAreaPaintSave()
	if(buildPalette)
		for(var/datum/build_entry/E in buildPalette)
			if(E.zoneRef == D)
				buildPalette -= E
				break
	for(var/client/C)
		var/datum/build_session/S = C.bsession
		if(S?.brush && S.brush.zoneRef == D)
			S.brush = null
			BuildHUDRefreshHand(S)
	BuildCustomRefreshSessions()
	if(D.inst?.wx_kind)
		WxSet(D.inst, null)
	_dn_sky_areas -= D.inst
	_dn_indoor_areas -= D.inst
	D.inst = null
	M << "Zone \"[D.name]\" deleted; [moved] tiles moved to the areas around it."
	Log("Mapper", "[M] ([M.ckey]) deleted zone \"[D.name]\" ([moved] tiles rezoned).", 1)

mob/Mapper/verb/Delete_Zone()
	set category = "Mapper"
	BuildZonesLoad()
	var/list/mine = list()
	for(var/datum/build_zone_def/D in zoneDefs)
		if(D.creator == usr.ckey || usr.Admin)
			mine["[D.name] (by [D.creator])"] = D
	if(!mine.len)
		usr << "You have no zones to delete."
		return
	var/pick = Ask(usr, "Delete which zone?", "Delete Zone", null, "pick", mine, 1)
	if(!pick)
		return
	var/datum/build_zone_def/D = mine[pick]
	var/tiles = 0
	if(D.inst)
		for(var/turf/T in D.inst)
			tiles++
	usr << "Deleting \"[D.name]\" moves its [tiles] tiles to the nearest outdoor area within 8 tiles, else the area around it, else NO ZONE (base). This is NOT undoable."
	spawn
		sleep(3)
		var/confirm = usr.HUDTextPrompt("Type YES to delete the zone", "")
		if(confirm != "YES")
			usr << "Zone deletion canceled."
			return
		BuildZoneDelete(D, usr)

/proc/BuildAreaPaintApplyBoot()
	set waitfor = FALSE
	set background = TRUE
	BuildZonesLoad()
	BuildAreaPaintLoad()
	if(!areaPaintMap.len)
		return
	var/applied = 0
	var/n = 0
	for(var/k in areaPaintMap)
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
		var/list/c = splittext(k, ",")
		if(c.len < 3)
			continue
		var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
		if(T && BuildAreaSetId(T, areaPaintMap[k]))
			applied++
	if(applied)
		Log("Mapper", "Area paint restored on [applied] tiles at boot.", 1)

/proc/BuildAreaFindLabel(id)
	var/h = findtext(id, "#")
	if(h)
		BuildZonesLoad()
		var/key = copytext(id, h + 1)
		var/datum/build_zone_def/D = zoneDefsByUid[key]
		if(!D)
			D = zoneDefsByName[key]
		return "zone [D ? D.name : key]"
	var/p = text2path(id)
	return p ? BuildZoneName(p) : id

/proc/BuildAreaFindCounts()
	BuildAreaPaintLoad()
	var/list/counts = list()
	var/n = 0
	for(var/k in areaPaintMap)
		if(++n % 2000 == 0)
			sleep(-1)
		var/list/c = splittext(k, ",")
		if(c.len < 3)
			continue
		var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
		if(!T)
			continue
		var/id = BuildAreaIdOf(T.loc)
		if(id == "/area")
			continue
		counts[id] = (counts[id] || 0) + 1
	return counts

/proc/BuildAreaFindGroups(id)
	BuildAreaPaintLoad()
	var/list/cells = list()
	var/n = 0
	for(var/k in areaPaintMap)
		if(++n % 2000 == 0)
			sleep(-1)
		var/list/c = splittext(k, ",")
		if(c.len < 3)
			continue
		var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
		if(T && BuildAreaIdOf(T.loc) == id)
			cells["[T.x],[T.y],[T.z]"] = 1
	var/list/groups = list()
	for(var/k in cells)
		if(cells[k] != 1)
			continue
		var/list/c0 = splittext(k, ",")
		var/z = text2num(c0[3])
		var/x1 = text2num(c0[1])
		var/y1 = text2num(c0[2])
		var/x2 = x1
		var/y2 = y1
		var/list/members = list()
		var/list/stack = list(k)
		cells[k] = 2
		while(stack.len)
			var/cur = stack[stack.len]
			stack.len--
			members += cur
			var/list/cc = splittext(cur, ",")
			var/cx = text2num(cc[1])
			var/cy = text2num(cc[2])
			x1 = min(x1, cx)
			y1 = min(y1, cy)
			x2 = max(x2, cx)
			y2 = max(y2, cy)
			for(var/dx = -1 to 1)
				for(var/dy = -1 to 1)
					var/nk = "[cx + dx],[cy + dy],[z]"
					if(cells[nk] == 1)
						cells[nk] = 2
						stack += nk
			if(++n % 2000 == 0)
				sleep(-1)
		var/list/g = list(z, x1, y1, x2, y2, members)
		var/pos = groups.len + 1
		for(var/i = 1 to groups.len)
			var/list/o = groups[i]
			var/list/om = o[6]
			if(members.len > om.len)
				pos = i
				break
		groups.Insert(pos, null)
		groups[pos] = g
	return groups

/proc/BuildAreaGroupText(list/g)
	var/list/m = g[6]
	var/where = (g[2] == g[4] && g[3] == g[5]) ? "([g[2]],[g[3]])" : "([g[2]],[g[3]]) to ([g[4]],[g[5]])"
	return "z[g[1]] [where], [m.len] tile[m.len == 1 ? "" : "s"]"

/proc/BuildAreaGroupCenter(list/g)
	var/list/m = g[6]
	var/cx = (g[2] + g[4]) / 2
	var/cy = (g[3] + g[5]) / 2
	var/best = null
	var/bestD = 1e9
	for(var/k in m)
		var/list/c = splittext(k, ",")
		var/d = abs(text2num(c[1]) - cx) + abs(text2num(c[2]) - cy)
		if(d < bestD)
			bestD = d
			best = c
	return best ? locate(text2num(best[1]), text2num(best[2]), text2num(best[3])) : null

mob/Mapper/verb/Find_Area()
	set category = "Mapper"
	var/list/counts = BuildAreaFindCounts()
	if(!counts.len)
		usr << "No painted areas found. The whole map is NO ZONE (base)."
		return
	var/list/menu = list()
	for(var/id in counts)
		menu["[BuildAreaFindLabel(id)] - [counts[id]] tile[counts[id] == 1 ? "" : "s"]"] = id
	var/pick = Ask(usr, "Find which area? Only painted areas are listed; everything else is NO ZONE (base).", "Find Area", null, "pick", menu, 1)
	if(!pick)
		return
	var/id = menu[pick]
	var/label = BuildAreaFindLabel(id)
	var/list/groups = BuildAreaFindGroups(id)
	if(!groups.len)
		usr << "[label] has no tiles left."
		return
	usr << "<b>[label]</b>: [groups.len] patch[groups.len == 1 ? "" : "es"], largest first."
	var/list/jump = list()
	for(var/list/g in groups)
		if(jump.len >= 25)
			usr << "  ...and [groups.len - 25] smaller patch[groups.len - 25 == 1 ? "" : "es"]."
			break
		var/txt = BuildAreaGroupText(g)
		usr << "  [txt]"
		jump[txt] = g
	var/go = Ask(usr, "Jump to a patch of [label]?", "Find Area", null, "pick", jump, 1)
	if(!go)
		return
	var/turf/T = BuildAreaGroupCenter(jump[go])
	if(!T)
		return
	usr.loc = T
	Log("Admin", "[ExtractInfo(usr)] jumped to [label] at ([T.x],[T.y],[T.z]) with Find Area.")

mob/Mapper/verb/Remove_Area()
	set category = "Mapper"
	var/list/counts = BuildAreaFindCounts()
	var/list/menu = list()
	for(var/id in counts)
		if(findtext(id, "#"))
			continue
		menu["[BuildAreaFindLabel(id)] - [counts[id]] tile[counts[id] == 1 ? "" : "s"]"] = id
	if(!menu.len)
		usr << "No painted areas to remove. Zones are removed with Delete Zone."
		return
	var/pick = Ask(usr, "Remove which area? Its tiles go back to NO ZONE (base).", "Remove Area", null, "pick", menu, 1)
	if(!pick)
		return
	var/id = menu[pick]
	var/label = BuildAreaFindLabel(id)
	var/list/groups = BuildAreaFindGroups(id)
	if(!groups.len)
		usr << "[label] has no tiles left."
		return
	var/total = 0
	for(var/list/g in groups)
		var/list/m = g[6]
		total += m.len
	var/list/which = list()
	which["All of [label], [total] tile[total == 1 ? "" : "s"]"] = 0
	var/i = 0
	for(var/list/g in groups)
		if(++i > 40)
			break
		which["Only [BuildAreaGroupText(g)]"] = i
	var/scope = Ask(usr, "Remove all of [label], or one patch?", "Remove Area", null, "pick", which, 1)
	if(!scope)
		return
	var/idx = which[scope]
	var/list/keys = list()
	if(idx)
		var/list/g = groups[idx]
		keys += g[6]
	else
		for(var/list/g in groups)
			keys += g[6]
	var/ok = Ask(usr, "Move [keys.len] tile[keys.len == 1 ? "" : "s"] of [label] to NO ZONE (base)? Their lighting and weather will follow the base area. This is NOT undoable.", "Remove Area", null, "confirm", null, 1, "Remove", "Cancel")
	if(ok != "Remove")
		return
	BuildAreaPaintLoad()
	var/moved = 0
	var/n = 0
	for(var/k in keys)
		if(++n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
		var/list/c = splittext(k, ",")
		var/turf/T = locate(text2num(c[1]), text2num(c[2]), text2num(c[3]))
		if(!T || BuildAreaIdOf(T.loc) != id)
			continue
		if(BuildAreaSetId(T, "/area"))
			moved++
			areaPaintMap[k] = "/area"
	BuildAreaPaintSave()
	usr << "Moved [moved] tile[moved == 1 ? "" : "s"] of [label] to NO ZONE (base)."
	Log("Mapper", "[usr] ([usr.ckey]) moved [moved] tiles of [label] to NO ZONE (base) with Remove Area.", 1)
