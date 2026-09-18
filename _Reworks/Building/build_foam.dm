globalTracker/var/SHORE_FOAM = 1

var/global/list/foamStates
var/global/list/shoreMeanCache = list()
var/global/list/shoreFoamOffs = list(list(0, 1), list(1, 1), list(1, 0), list(1, -1), list(0, -1), list(-1, -1), list(-1, 0), list(-1, 1))

/proc/ShoreFoamWater(turf/W)
	if(!W || W.Lava)
		return 0
	BuildMaterialTypeInit()
	if(buildNoFoamTypes && buildNoFoamTypes[W.type])
		return 0
	if(istype(W, /turf/Waterfall) || istype(W, /turf/Waters/WaterFall))
		return 0
	return 1

/proc/ShoreWaterMean(turf/W)
	var/k = "[W.icon]|[W.icon_state]"
	var/res = shoreMeanCache[k]
	if(res)
		return res
	var/icon/I = icon(W.icon, W.icon_state, SOUTH, 1)
	var/r = 0
	var/g = 0
	var/b = 0
	var/n = 0
	for(var/yy = 1 to 32)
		for(var/xx = 1 to 32)
			var/c = I.GetPixel(xx, yy)
			if(!c)
				continue
			var/list/v = rgb2num(c)
			r += v[1]
			g += v[2]
			b += v[3]
			n++
	res = n ? rgb(round(r / n), round(g / n), round(b / n)) : "#343e71"
	shoreMeanCache[k] = res
	return res

var/global/list/stripStates = list()

/proc/ShoreWaterConfig(turf/T, m, th)
	var/cbit = (m == "Water") ? 1 : 0
	var/cfg = cbit ? 256 : 0
	var/i = 0
	for(var/list/o in shoreFoamOffs)
		i++
		var/mo = BuildMatFor(T, locate(T.x + o[1], T.y + o[2], T.z), th)
		var/b = mo ? ((mo == "Water") ? 1 : 0) : cbit
		if(b)
			cfg |= (1 << (i - 1))
	return cfg

/proc/ShoreWaterTile(turf/T, m, th)
	if(m == "Water")
		return T
	var/turf/S = locate(T.x, T.y - 1, T.z)
	if(BuildMatFor(T, S, th) == "Water")
		return S
	for(var/list/o in shoreFoamOffs)
		var/turf/O = locate(T.x + o[1], T.y + o[2], T.z)
		if(BuildMatFor(T, O, th) == "Water")
			return O
	return null

/proc/ShoreStripFile(style)
	switch(style)
		if("wall7")
			return 'Mapping/EdgeOrg/strip_wall7.dmi'
		if("wall12")
			return 'Mapping/EdgeOrg/strip_wall12.dmi'
		if("wall13")
			return 'Mapping/EdgeOrg/strip_wall13.dmi'
		if("wall14")
			return 'Mapping/EdgeOrg/strip_wall14.dmi'
		if("wall15")
			return 'Mapping/EdgeOrg/strip_wall15.dmi'
		if("wall16")
			return 'Mapping/EdgeOrg/strip_wall16.dmi'
		if("wall29")
			return 'Mapping/EdgeOrg/strip_wall29.dmi'
		if("wall36")
			return 'Mapping/EdgeOrg/strip_wall36.dmi'
		if("wall37")
			return 'Mapping/EdgeOrg/strip_wall37.dmi'
		if("wall38")
			return 'Mapping/EdgeOrg/strip_wall38.dmi'
		if("wall56")
			return 'Mapping/EdgeOrg/strip_wall56.dmi'
		if("wall99")
			return 'Mapping/EdgeOrg/strip_wall99.dmi'
	return 'Mapping/EdgeOrg/strip_default.dmi'

/proc/ShoreStripStates(ic)
	var/k = "[ic]"
	var/list/s = stripStates[k]
	if(!s)
		s = ElevStateSet(ic)
		stripStates[k] = s
	return s

/proc/ShoreStripAdd(cfg, style, list/fresh)
	var/st = "s[cfg]"
	var/image/CI
	if(ElevStyleGeneric(style))
		var/list/art = ElevStyleArt(style)
		if(art)
			BuildOrgSheetInit()
			CI = image(art[1], null, art[2])
			CI.filters = filter(type = "alpha", icon = buildOrgSheets["os"], x = BuildOrgSheetX(cfg), y = BuildOrgSheetY(cfg))
	if(!CI)
		var/ic = ShoreStripFile(style)
		var/list/ss = ShoreStripStates(ic)
		if(!ss[st])
			ic = 'Mapping/EdgeOrg/strip_default.dmi'
			ss = ShoreStripStates(ic)
			if(!ss[st])
				return
		CI = image(ic, null, st)
	CI.layer = 2.9
	fresh += CI

/proc/ShoreFoamAdd(turf/T, m, list/fresh)
	if(!m)
		return
	var/th = ElevAt(T)
	var/cfg = ShoreWaterConfig(T, m, th)
	if(cfg == 0 || cfg == 511)
		return
	var/turf/WT = ShoreWaterTile(T, m, th)
	if(!WT)
		return
	var/style = BuildCliffStyleAt(WT)
	var/v = (style == "none") ? "s" : "r"
	if(v == "r")
		ShoreStripAdd(cfg, style, fresh)
	if(!glob || !glob.SHORE_FOAM)
		return
	if(!ShoreFoamWater(WT) || BuildFoamOffAt(WT))
		return
	if(!foamStates)
		foamStates = ElevStateSet('Mapping/Elevation/foam.dmi')
	var/key = "[v][cfg]"
	if(foamStates["fc[key]"])
		var/image/C = image('Mapping/Elevation/foam.dmi', null, "fc[key]")
		C.layer = 2.9
		C.color = ShoreWaterMean(WT)
		fresh += C
	if(foamStates["ft[key]"])
		var/image/TI = image('Mapping/Elevation/foam.dmi', null, "ft[key]")
		TI.layer = 2.9
		fresh += TI
	if(foamStates["fo[key]"])
		var/image/FI = image('Mapping/Elevation/foam.dmi', null, "fo[key]")
		FI.layer = 2.9
		fresh += FI

/mob/Admin3/verb/Toggle_Shore_Foam()
	set category = "Mapper"
	glob.SHORE_FOAM = !glob.SHORE_FOAM
	usr << "Shoreline foam is now [glob.SHORE_FOAM ? "ON" : "OFF"]. Rebuilding shore edges in the background."
	Log("Admin", "[usr] ([usr.ckey]) toggled shoreline foam [glob.SHORE_FOAM ? "on" : "off"].", 1)
	BuildEdgeBootPass()
	ElevBootPass()
