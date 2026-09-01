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
		area/MapperZone/inst

/proc/BuildZoneUid()
	return "u[copytext(md5("[world.realtime]|[world.time]|[rand(100000, 999999)]"), 1, 9)]"

/proc/BuildZoneSanitizeName(nm)
	nm = replacetext(nm, "\t", " ")
	nm = replacetext(nm, "\n", " ")
	return trimtext(nm)

/proc/BuildZoneApply(datum/build_zone_def/D)
	if(!length(D.uid))
		D.uid = BuildZoneUid()
	if(!D.inst)
		D.inst = new
	D.inst.zoneKey = D.uid
	D.inst.name = D.name
	D.inst.sees_sky = D.sees_sky
	D.inst.wx_kind = length(D.wx_kind) ? D.wx_kind : null
	D.inst.env_profile_id = D.profile
	D.inst.zone_wind_mult = D.windMult
	if(D.sees_sky)
		_dn_sky_areas |= D.inst
	else
		_dn_sky_areas -= D.inst
	for(var/client/CC)
		CC.gfx_env_profile_id = null

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
		lines += jointext(list(BuildDmmEscape(D.name), D.creator, "[D.sees_sky]", BuildDmmEscape(D.wx_kind), BuildDmmEscape(D.profile), "[D.windMult]", D.uid), "\t")
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
	for(var/k in areaPaintMap)
		lines += "[k]\t[areaPaintMap[k]]"
	if(fexists(AREA_PAINT_FILE))
		fdel(AREA_PAINT_FILE)
	text2file(jointext(lines, "\n"), AREA_PAINT_FILE)

/proc/BuildAreaInstance(path)
	var/area/AR = locate(path)
	if(!AR)
		AR = new path
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
		var/area/A = locate(tp)
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
	var/pick = input(usr, "Which zone?", "Zone Settings") as null|anything in mine
	if(!pick)
		return
	var/datum/build_zone_def/D = mine[pick]
	while(D)
		var/sky = D.sees_sky ? "OUTDOOR" : "INDOOR/CAVE"
		var/wx = length(D.wx_kind) ? D.wx_kind : "clear"
		var/list/menu = list("Sky: [sky]", "Weather: [wx]", "Profile: [D.profile]", "Wind: [D.windMult * 100]%", "Rename", "Done")
		var/choice = input(usr, "Zone \"[D.name]\" - pick a setting.", "Zone Settings") as null|anything in menu
		if(!choice || choice == "Done")
			break
		if(choice == "Sky: [sky]")
			D.sees_sky = !D.sees_sky
			usr << "\"[D.name]\" is now [D.sees_sky ? "OUTDOOR (sky, day/night, weather)" : "INDOOR/CAVE (no sky effects)"]."
		else if(choice == "Weather: [wx]")
			var/list/kinds = list("clear", "rain", "storm", "snow", "blizzard", "dust")
			var/k = input(usr, "Weather in \"[D.name]\" (static for this zone).", "Zone Weather") as null|anything in kinds
			if(!k)
				continue
			D.wx_kind = (k == "clear") ? "" : k
		else if(choice == "Profile: [D.profile]")
			var/list/options = list()
			for(var/id in _env_profiles)
				var/datum/environment_profile/EP = _env_profiles[id]
				options["[EP.display_name] ([id])"] = id
			var/p = input(usr, "Environment profile for \"[D.name]\".", "Zone Profile") as null|anything in options
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

/proc/BuildAreaSampleOutdoor(turf/T, excludeZones = 0)
	for(var/r = 1 to 8)
		for(var/dx = -r to r)
			for(var/dy = -r to r)
				if(max(abs(dx), abs(dy)) != r)
					continue
				var/turf/T2 = locate(T.x + dx, T.y + dy, T.z)
				if(!T2)
					continue
				var/area/A2 = T2.loc
				if(!A2?.sees_sky)
					continue
				if(excludeZones && istype(A2, /area/MapperZone))
					continue
				return A2.type
	return null

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
		var/apath = BuildAreaSampleOutdoor(T, 1)
		if(!apath)
			apath = /area/Inside
		var/newid = "[apath]"
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
	_dn_sky_areas -= D.inst
	D.inst = null
	M << "Zone \"[D.name]\" deleted; [moved] tiles rezoned (outdoor-match, Inside fallback)."
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
	var/pick = input(usr, "Delete which zone?", "Delete Zone") as null|anything in mine
	if(!pick)
		return
	var/datum/build_zone_def/D = mine[pick]
	var/tiles = 0
	if(D.inst)
		for(var/turf/T in D.inst)
			tiles++
	usr << "Deleting \"[D.name]\" rezones its [tiles] tiles (nearest outdoor zone, Inside as fallback). This is NOT undoable."
	spawn
		sleep(3)
		var/confirm = usr.HUDTextPrompt("Type YES to delete the zone", "")
		if(confirm != "YES")
			usr << "Zone deletion cancelled."
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
