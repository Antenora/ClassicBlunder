globalTracker/var/SHORE_FOAM = 1

var/global/list/foamStates
var/global/list/shoreMeanCache = list()
var/global/list/shoreFoamOffs = list(list(0, 1), list(1, 1), list(1, 0), list(1, -1), list(0, -1), list(-1, -1), list(-1, 0), list(-1, 1))

/proc/ShoreStyleCode(mid)
	switch(BuildEdgeStyleFor(mid))
		if("crumbly")
			return "c"
		if("soft")
			return "s"
		if("jagged")
			return "j"
		if("hard")
			return "h"
	return "w"

/proc/ShoreFoamWater(turf/W)
	if(!W || W.Lava)
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

/proc/ShoreFoamAdd(turf/T, m, list/fresh)
	if(!glob || !glob.SHORE_FOAM || !m)
		return
	if(!foamStates)
		foamStates = ElevStateSet('Mapping/Elevation/foam.dmi')
	var/th = ElevAt(T)
	var/bits = ""
	var/sc
	var/key
	var/turf/WT
	if(m == "Water")
		if(!ShoreFoamWater(T))
			return
		for(var/list/o in shoreFoamOffs)
			var/om = BuildMatSameH(locate(T.x + o[1], T.y + o[2], T.z), th)
			var/isLand = (om && om != "Water")
			bits += isLand ? "1" : "0"
			if(isLand && !sc)
				sc = ShoreStyleCode(om)
		if(!sc)
			return
		key = "[bits][sc]"
		if(copytext(bits, 1, 2) == "1" && BuildCliffStyleAt(T) == "none")
			key = "N[bits][sc]"
		WT = T
	else
		WT = locate(T.x, T.y + 1, T.z)
		if(BuildMatSameH(WT, th) != "Water" || !ShoreFoamWater(WT))
			return
		for(var/list/o in shoreFoamOffs)
			bits += (BuildMatSameH(locate(T.x + o[1], T.y + o[2], T.z), th) == "Water") ? "1" : "0"
		key = "L[bits][ShoreStyleCode(m)]"
	if(BuildFoamOffAt(WT))
		return
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
		var/image/F = image('Mapping/Elevation/foam.dmi', null, "fo[key]")
		F.layer = 2.9
		fresh += F

/mob/Admin3/verb/Toggle_Shore_Foam()
	set category = "Mapper"
	glob.SHORE_FOAM = !glob.SHORE_FOAM
	usr << "Shoreline foam is now [glob.SHORE_FOAM ? "ON" : "OFF"]. Rebuilding shore edges in the background."
	Log("Admin", "[usr] ([usr.ckey]) toggled shoreline foam [glob.SHORE_FOAM ? "on" : "off"].", 1)
	BuildEdgeBootPass()
	ElevBootPass()
