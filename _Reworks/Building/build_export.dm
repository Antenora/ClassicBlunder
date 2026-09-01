#define BUILD_EXPORT_MAX_DIM 200
#define BUILD_EXPORT_MAX_CELLS 40000
var/global/list/buildDmmAlphabet = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")

/proc/BuildDmmEscape(t)
	t = replacetext(t, "\\", "\\\\")
	t = replacetext(t, "\"", "\\\"")
	t = replacetext(t, "\n", "\\n")
	t = replacetext(t, "\t", "\\t")
	t = replacetext(t, "\[", "\\\[")
	t = replacetext(t, "\]", "\\\]")
	return t

/proc/BuildDmmValue(v)
	if(isnum(v))
		return "[v]"
	if(istext(v))
		return "\"[BuildDmmEscape(v)]\""
	if(isfile(v))
		if(findtext("[v]", "'"))
			return null
		if(!fexists("[v]"))
			return null
		return "'[v]'"
	return null

/proc/BuildDmmKey(i, L)
	var/t = ""
	var/n = i - 1
	for(var/p = 1 to L)
		t = "[buildDmmAlphabet[(n % 52) + 1]]" + t
		n = round(n / 52)
	return t

/datum/build_export_report
	var
		cells = 0
		objs = 0
		recoveredIcons = 0
		skippedIcons = 0
		list/skippedIconSpots = list()
		list/skippedObjTypes = list()

/proc/BuildExportOverride(list/parts, name, v, datum/build_export_report/R, atom/A)
	var/enc = BuildDmmValue(v)
	if(isnull(enc))
		R.skippedIcons++
		if(R.skippedIconSpots.len < 20)
			R.skippedIconSpots += "[A.type] @ ([A.x],[A.y],[A.z]) var [name]"
		return
	parts += "[name] = [enc]"

/proc/BuildExportAtomSpec(atom/A, datum/build_export_report/R)
	var/list/parts = list()
	var/isCust = istype(A, /turf/CustomTurf) || istype(A, /obj/Turfs/CustomObj1)
	if(isCust)
		var/ip = BuildCustomIconPath(A)
		if(!ip)
			ip = BuildCustomRecoverIcon(A)
			if(ip)
				R.recoveredIcons++
		if(ip)
			BuildExportOverride(parts, "icon", file(ip), R, A)
		else
			R.skippedIcons++
			if(R.skippedIconSpots.len < 20)
				R.skippedIconSpots += "[A.type] @ ([A.x],[A.y],[A.z]) - custom art could not be read from the tile"
	else if(A.icon != initial(A.icon))
		BuildExportOverride(parts, "icon", A.icon, R, A)
	if(A.icon_state != initial(A.icon_state))
		BuildExportOverride(parts, "icon_state", A.icon_state, R, A)
	if(A.dir != initial(A.dir))
		BuildExportOverride(parts, "dir", A.dir, R, A)
	if(A.density != initial(A.density))
		BuildExportOverride(parts, "density", A.density, R, A)
	if(A.opacity != initial(A.opacity))
		BuildExportOverride(parts, "opacity", A.opacity, R, A)
	if(isturf(A))
		var/turf/T = A
		if(T.Shallow != initial(T.Shallow))
			BuildExportOverride(parts, "Shallow", T.Shallow, R, A)
		if(T.FlyOverAble != initial(T.FlyOverAble))
			BuildExportOverride(parts, "FlyOverAble", T.FlyOverAble, R, A)
		if(T.Destructable != initial(T.Destructable))
			BuildExportOverride(parts, "Destructable", T.Destructable, R, A)
		if(T.isOutside != initial(T.isOutside))
			BuildExportOverride(parts, "isOutside", T.isOutside, R, A)
		if(T.isUnderwater != initial(T.isUnderwater))
			BuildExportOverride(parts, "isUnderwater", T.isUnderwater, R, A)
		if(istype(T, /turf/CustomTurf))
			var/turf/CustomTurf/CT = T
			if(CT.Roof != initial(CT.Roof))
				BuildExportOverride(parts, "Roof", CT.Roof, R, A)
	if(isobj(A))
		var/obj/O = A
		if(O.pixel_x != initial(O.pixel_x))
			BuildExportOverride(parts, "pixel_x", O.pixel_x, R, A)
		if(O.pixel_y != initial(O.pixel_y))
			BuildExportOverride(parts, "pixel_y", O.pixel_y, R, A)
		if(O.layer != initial(O.layer))
			BuildExportOverride(parts, "layer", O.layer, R, A)
		if(O.desc != initial(O.desc))
			BuildExportOverride(parts, "desc", O.desc, R, A)
		if(istype(O, /obj/Special/Teleporter2))
			var/obj/Special/Teleporter2/TP = O
			if(TP.gotoX != initial(TP.gotoX))
				BuildExportOverride(parts, "gotoX", TP.gotoX, R, A)
			if(TP.gotoY != initial(TP.gotoY))
				BuildExportOverride(parts, "gotoY", TP.gotoY, R, A)
			if(TP.gotoZ != initial(TP.gotoZ))
				BuildExportOverride(parts, "gotoZ", TP.gotoZ, R, A)
	if(!parts.len)
		return "[A.type]"
	return "[A.type]{[jointext(parts, "; ")]}"

/proc/BuildExportCellSpec(turf/T, datum/build_export_report/R)
	var/list/entries = list()
	for(var/obj/O in T)
		if(O.gfx_transient_visual)
			continue
		if(!istype(O, /obj/Turfs) && !istype(O, /obj/KatieObj) && !istype(O, /obj/Special))
			var/tp = "[O.type]"
			R.skippedObjTypes[tp] = (R.skippedObjTypes[tp] || 0) + 1
			continue
		entries += BuildExportAtomSpec(O, R)
		R.objs++
	entries += BuildExportAtomSpec(T, R)
	entries += BuildExportAreaSpec(T.loc)
	return jointext(entries, ",")

/proc/BuildExportAreaSpec(area/AR)
	if(!AR)
		return "/area"
	if(istype(AR, /area/MapperZone))
		var/area/MapperZone/MZ = AR
		var/list/parts = list()
		parts += "name = \"[BuildDmmEscape(MZ.name)]\""
		parts += "sees_sky = [MZ.sees_sky]"
		parts += "env_profile_id = \"[BuildDmmEscape(MZ.env_profile_id)]\""
		parts += "zone_wind_mult = [MZ.zone_wind_mult]"
		if(MZ.wx_kind)
			parts += "wx_kind = \"[BuildDmmEscape(MZ.wx_kind)]\""
		return "/area/MapperZone{[jointext(parts, "; ")]}"
	return "[AR.type]"

/proc/BuildExportRegion(x1, y1, x2, y2, z, fname)
	set waitfor = FALSE
	set background = TRUE
	if(x1 > x2)
		var/t = x1
		x1 = x2
		x2 = t
	if(y1 > y2)
		var/t = y1
		y1 = y2
		y2 = t
	x1 = clamp(x1, 1, world.maxx)
	x2 = clamp(x2, 1, world.maxx)
	y1 = clamp(y1, 1, world.maxy)
	y2 = clamp(y2, 1, world.maxy)
	var/w = x2 - x1 + 1
	var/h = y2 - y1 + 1
	if(w > BUILD_EXPORT_MAX_DIM || h > BUILD_EXPORT_MAX_DIM || w * h > BUILD_EXPORT_MAX_CELLS)
		return "Export refused: region [w]x[h] exceeds [BUILD_EXPORT_MAX_DIM]x[BUILD_EXPORT_MAX_DIM] / [BUILD_EXPORT_MAX_CELLS] cells."
	var/datum/build_export_report/R = new
	var/list/dict = list()
	var/list/gridIdx = list()
	var/n = 0
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			var/turf/T = locate(x, y, z)
			var/spec = T ? BuildExportCellSpec(T, R) : "/turf,/area"
			var/idx = dict[spec]
			if(!idx)
				dict[spec] = dict.len + 1
				idx = dict.len
			gridIdx["[x],[y]"] = idx
			R.cells++
			n++
			if(n % 2000 == 0)
				sleep(-1)
	var/L = 1
	var/cap = 52
	while(dict.len > cap)
		L++
		cap *= 52
	var/list/lines = list()
	var/i = 0
	for(var/spec in dict)
		i++
		lines += "\"[BuildDmmKey(i, L)]\" = ([spec])"
	lines += ""
	lines += "(1,1,1) = {\""
	for(var/y = y2, y >= y1, y--)
		var/row = ""
		for(var/x = x1 to x2)
			row += BuildDmmKey(gridIdx["[x],[y]"], L)
		lines += row
	lines += "\"}"
	if(fexists(fname))
		fdel(fname)
	text2file(jointext(lines, "\n"), fname)
	var/list/rep = list()
	rep += "Exported [w]x[h] region ([x1],[y1])-([x2],[y2]) z[z] -> [fname]"
	rep += "[R.cells] cells, [dict.len] unique, [R.objs] objects."
	if(R.recoveredIcons)
		rep += "[R.recoveredIcons] unregistered custom icons were extracted into Mapping/Custom/ (rec_*.png) so this file stays complete."
	if(R.skippedIcons)
		rep += "SKIPPED [R.skippedIcons] runtime-composed icon values (cannot go in a .dmm):"
		for(var/s in R.skippedIconSpots)
			rep += "  [s]"
	for(var/tp in R.skippedObjTypes)
		rep += "Skipped obj type [tp] x[R.skippedObjTypes[tp]] (not a map-object family)."
	return jointext(rep, "\n")

mob/Mapper/verb/Export_Map_Region()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.exportStage = 1
	usr << "EXPORT: click the FIRST corner tile of the region you want to export. Right-click cancels."

mob/Mapper/verb/Save_Prefab()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.exportStage = 1
	S.exportPrefab = 1
	usr << "PREFAB: click the FIRST corner tile of the region to save as a stamp. Right-click cancels."
