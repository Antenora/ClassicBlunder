turf/var/tmp/list/edgeOverlays
turf/var/EdgeOptOut = 0

var/global/list/buildMaterialPriority = list("Grass" = 20, "Dirt" = 30, "Sand" = 40, "Ice" = 60, "Wood" = 70, "Stone" = 80, "Water" = 100)
var/global/list/buildMaterialNames = list("Grass", "Dirt", "Sand", "Water", "Stone", "Wood", "Ice")

var/global/list/buildMaterialTypeOverride
var/global/list/buildNoFoamTypes

/proc/BuildMaterialTypeInit()
	if(buildMaterialTypeOverride)
		return
	buildMaterialTypeOverride = list()
	buildMaterialTypeOverride[/turf/IconsX/Icon9] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon27] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon52] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon57] = "Grass"
	buildMaterialTypeOverride[/turf/IconsX/Icon5] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon6] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon7] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon10] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon11] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon12] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon55] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon56] = "Dirt"
	buildMaterialTypeOverride[/turf/IconsX/Icon58] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc3] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc4] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc5] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc6] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc7] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc8] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc9] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc10] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc11] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc12] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc13] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc14] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc15] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc16] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Floor/Floor_16] = "Grass"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_79] = "Grass"
	buildMaterialTypeOverride[/turf/KatieTurf/Floor/Floor_4] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Floor/Floor_9] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Floor/Floor_27] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Floor/Floor_21] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_126] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_127] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_198] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_199] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_200] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_201] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_202] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_203] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_204] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_205] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_206] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_207] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_208] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_209] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_210] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_211] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_212] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_266] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_267] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_268] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_269] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_270] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_271] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_272] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_273] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_274] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_275] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_276] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_277] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_278] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_280] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_281] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_282] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_283] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_284] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_285] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_286] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_287] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_288] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_289] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_290] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_291] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_292] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_293] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_294] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_300] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_301] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_302] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_328] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_329] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_331] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_332] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_330] = "Dirt"
	buildMaterialTypeOverride[/turf/KatieTurf/Space/Floors/Floor_279] = "Water"
	buildNoFoamTypes = list()
	buildNoFoamTypes[/turf/KatieTurf/Space/Floors/Floor_279] = 1
	buildMaterialTypeOverride[/turf/Misc17] = "Dirt"
	buildMaterialTypeOverride[/turf/Misc18] = "Dirt"
	buildMaterialTypeOverride[/turf/Waters/WaterU1] = "none"
	buildMaterialTypeOverride[/turf/Waters/WaterU2] = "none"
	buildMaterialTypeOverride[/turf/Waters/WaterU3] = "none"

var/global/list/buildMaterialByType = list()

/proc/BuildMaterialFor(turf/T)
	if(!T)
		return null
	if(!buildMaterialTypeOverride)
		BuildMaterialTypeInit()
	var/ov = buildMaterialTypeOverride[T.type]
	if(ov)
		return (ov == "none") ? null : ov
	if(istype(T, /turf/Waters) || istype(T, /turf/Waterfall))
		return "Water"
	if(istype(T, /turf/CustomTurf))
		return BuildCustomMaterialForTurf(T)
	var/st = T.SecondaryTurfType
	if(st && (st in buildMaterialNames))
		return st
	var/pt = "[T.type]"
	var/memo = buildMaterialByType[pt]
	if(memo)
		return (memo == "none") ? null : memo
	for(var/nm2 in buildMaterialNames)
		if(findtext(pt, "/[nm2]"))
			buildMaterialByType[pt] = nm2
			return nm2
	buildMaterialByType[pt] = "none"
	return null

/proc/BuildMaterialForType(p)
	if(!p)
		return null
	BuildMaterialTypeInit()
	var/ov = buildMaterialTypeOverride[p]
	if(ov)
		return (ov == "none") ? null : ov
	if(ispath(p, /turf/Waters) || ispath(p, /turf/Waterfall))
		return "Water"
	var/pt = "[p]"
	for(var/nm2 in buildMaterialNames)
		if(findtext(pt, "/[nm2]"))
			return nm2
	return null

/proc/BuildMaterialPriority(id)
	if(!id)
		return 0
	var/p = buildMaterialPriority[id]
	if(p)
		return p
	return 50

var/global/list/buildEdgeStyles = list("Grass" = "wispy", "Dirt" = "crumbly", "Sand" = "soft", "Ice" = "soft", "Stone" = "jagged", "Wood" = "hard", "Water" = "crisp")

/proc/BuildEdgeStyleFor(id)
	if(!id)
		return "wispy"
	var/s = buildEdgeStyles[id]
	if(s)
		return s
	return "wispy"

var/global/list/buildOrgSheets

/proc/BuildOrgSheetInit()
	if(buildOrgSheets)
		return
	buildOrgSheets = list()
	buildOrgSheets["w00"] = 'Mapping/EdgeOrg/om_w00.png'
	buildOrgSheets["w01"] = 'Mapping/EdgeOrg/om_w01.png'
	buildOrgSheets["w02"] = 'Mapping/EdgeOrg/om_w02.png'
	buildOrgSheets["w03"] = 'Mapping/EdgeOrg/om_w03.png'
	buildOrgSheets["w10"] = 'Mapping/EdgeOrg/om_w10.png'
	buildOrgSheets["w11"] = 'Mapping/EdgeOrg/om_w11.png'
	buildOrgSheets["w12"] = 'Mapping/EdgeOrg/om_w12.png'
	buildOrgSheets["w13"] = 'Mapping/EdgeOrg/om_w13.png'
	buildOrgSheets["w20"] = 'Mapping/EdgeOrg/om_w20.png'
	buildOrgSheets["w21"] = 'Mapping/EdgeOrg/om_w21.png'
	buildOrgSheets["w22"] = 'Mapping/EdgeOrg/om_w22.png'
	buildOrgSheets["w23"] = 'Mapping/EdgeOrg/om_w23.png'
	buildOrgSheets["w30"] = 'Mapping/EdgeOrg/om_w30.png'
	buildOrgSheets["w31"] = 'Mapping/EdgeOrg/om_w31.png'
	buildOrgSheets["w32"] = 'Mapping/EdgeOrg/om_w32.png'
	buildOrgSheets["w33"] = 'Mapping/EdgeOrg/om_w33.png'
	buildOrgSheets["c00"] = 'Mapping/EdgeOrg/om_c00.png'
	buildOrgSheets["c01"] = 'Mapping/EdgeOrg/om_c01.png'
	buildOrgSheets["c02"] = 'Mapping/EdgeOrg/om_c02.png'
	buildOrgSheets["c03"] = 'Mapping/EdgeOrg/om_c03.png'
	buildOrgSheets["c10"] = 'Mapping/EdgeOrg/om_c10.png'
	buildOrgSheets["c11"] = 'Mapping/EdgeOrg/om_c11.png'
	buildOrgSheets["c12"] = 'Mapping/EdgeOrg/om_c12.png'
	buildOrgSheets["c13"] = 'Mapping/EdgeOrg/om_c13.png'
	buildOrgSheets["c20"] = 'Mapping/EdgeOrg/om_c20.png'
	buildOrgSheets["c21"] = 'Mapping/EdgeOrg/om_c21.png'
	buildOrgSheets["c22"] = 'Mapping/EdgeOrg/om_c22.png'
	buildOrgSheets["c23"] = 'Mapping/EdgeOrg/om_c23.png'
	buildOrgSheets["c30"] = 'Mapping/EdgeOrg/om_c30.png'
	buildOrgSheets["c31"] = 'Mapping/EdgeOrg/om_c31.png'
	buildOrgSheets["c32"] = 'Mapping/EdgeOrg/om_c32.png'
	buildOrgSheets["c33"] = 'Mapping/EdgeOrg/om_c33.png'
	buildOrgSheets["s00"] = 'Mapping/EdgeOrg/om_s00.png'
	buildOrgSheets["s01"] = 'Mapping/EdgeOrg/om_s01.png'
	buildOrgSheets["s02"] = 'Mapping/EdgeOrg/om_s02.png'
	buildOrgSheets["s03"] = 'Mapping/EdgeOrg/om_s03.png'
	buildOrgSheets["s10"] = 'Mapping/EdgeOrg/om_s10.png'
	buildOrgSheets["s11"] = 'Mapping/EdgeOrg/om_s11.png'
	buildOrgSheets["s12"] = 'Mapping/EdgeOrg/om_s12.png'
	buildOrgSheets["s13"] = 'Mapping/EdgeOrg/om_s13.png'
	buildOrgSheets["s20"] = 'Mapping/EdgeOrg/om_s20.png'
	buildOrgSheets["s21"] = 'Mapping/EdgeOrg/om_s21.png'
	buildOrgSheets["s22"] = 'Mapping/EdgeOrg/om_s22.png'
	buildOrgSheets["s23"] = 'Mapping/EdgeOrg/om_s23.png'
	buildOrgSheets["s30"] = 'Mapping/EdgeOrg/om_s30.png'
	buildOrgSheets["s31"] = 'Mapping/EdgeOrg/om_s31.png'
	buildOrgSheets["s32"] = 'Mapping/EdgeOrg/om_s32.png'
	buildOrgSheets["s33"] = 'Mapping/EdgeOrg/om_s33.png'
	buildOrgSheets["j00"] = 'Mapping/EdgeOrg/om_j00.png'
	buildOrgSheets["j01"] = 'Mapping/EdgeOrg/om_j01.png'
	buildOrgSheets["j02"] = 'Mapping/EdgeOrg/om_j02.png'
	buildOrgSheets["j03"] = 'Mapping/EdgeOrg/om_j03.png'
	buildOrgSheets["j10"] = 'Mapping/EdgeOrg/om_j10.png'
	buildOrgSheets["j11"] = 'Mapping/EdgeOrg/om_j11.png'
	buildOrgSheets["j12"] = 'Mapping/EdgeOrg/om_j12.png'
	buildOrgSheets["j13"] = 'Mapping/EdgeOrg/om_j13.png'
	buildOrgSheets["j20"] = 'Mapping/EdgeOrg/om_j20.png'
	buildOrgSheets["j21"] = 'Mapping/EdgeOrg/om_j21.png'
	buildOrgSheets["j22"] = 'Mapping/EdgeOrg/om_j22.png'
	buildOrgSheets["j23"] = 'Mapping/EdgeOrg/om_j23.png'
	buildOrgSheets["j30"] = 'Mapping/EdgeOrg/om_j30.png'
	buildOrgSheets["j31"] = 'Mapping/EdgeOrg/om_j31.png'
	buildOrgSheets["j32"] = 'Mapping/EdgeOrg/om_j32.png'
	buildOrgSheets["j33"] = 'Mapping/EdgeOrg/om_j33.png'
	buildOrgSheets["ow"] = 'Mapping/EdgeOrg/ow.png'
	buildOrgSheets["os"] = 'Mapping/EdgeOrg/os.png'

/proc/BuildOrgStyleCode(mat)
	switch(BuildEdgeStyleFor(mat))
		if("crumbly")
			return "c"
		if("soft")
			return "s"
		if("jagged")
			return "j"
		if("hard")
			return "h"
		if("crisp")
			return "a"
	return "w"

/proc/BuildOrgWindowX(turf/T)
	return T.x % 4

/proc/BuildOrgWindowY(turf/T)
	return (4 - (T.y % 4)) % 4

/proc/BuildOrgLayerId(turf/O, mat, doBlend)
	var/ps = "[BuildMaterialPriority(mat)]"
	while(length(ps) < 3)
		ps = "0[ps]"
	if(!doBlend)
		return "[ps]|[mat]"
	return "[ps]|[mat]|[O.type]|[O.icon]|[O.icon_state]"

/proc/BuildOrgSheetX(cell)
	return 496 - 32 * (cell % 32)

/proc/BuildOrgSheetY(cell)
	return 240 - 32 * round(cell / 32)

/proc/BuildOrgMask(cfg, xm, baseMat, wx, wy, inv = 0)
	BuildOrgSheetInit()
	var/cbit = (cfg & 256) ? 1 : 0
	if(xm == "Wood" || baseMat == "Wood")
		return inv ? !cbit : cbit
	var/sheet
	if(xm == "Water")
		sheet = buildOrgSheets["ow"]
	else
		sheet = buildOrgSheets["[BuildOrgStyleCode(baseMat)][wx][wy]"]
	if(!sheet)
		return inv ? !cbit : cbit
	return filter(type = "alpha", icon = sheet, x = BuildOrgSheetX(cfg), y = BuildOrgSheetY(cfg), flags = inv ? MASK_INVERSE : 0)

/proc/BuildOrgConfig(X, own, list/nb)
	var/cbit = (own >= X) ? 1 : 0
	var/cfg = cbit ? 256 : 0
	for(var/i = 1 to 8)
		var/nid = nb[i]
		var/b = nid ? ((nid >= X) ? 1 : 0) : cbit
		if(b)
			cfg |= (1 << (i - 1))
	return cfg

/proc/BuildOrgMaskFor(X, xm, own, list/nb, baseMat, wx, wy, inv = 0)
	if(xm == "Wood")
		var/c = (own == X) ? 1 : 0
		return inv ? !c : c
	return BuildOrgMask(BuildOrgConfig(X, own, nb), xm, baseMat, wx, wy, inv)

/proc/BuildEdgeImage(turf/S)
	var/eh = ElevAt(S)
	var/image/I = image(ElevTexIcon(S, eh), null, ElevTexState(S, eh))
	I.layer = 2.9
	return I

/proc/BuildOrgLayers(turf/T, m, th, doBlend, list/present, list/srcs, list/nb)
	var/own = BuildOrgLayerId(T, m, doBlend)
	present[own] = m
	srcs[own] = T
	var/i = 0
	for(var/list/o in shoreFoamOffs)
		i++
		var/turf/O = locate(T.x + o[1], T.y + o[2], T.z)
		var/mo = BuildMatFor(T, O, th)
		if(!mo)
			continue
		var/id = BuildOrgLayerId(O, mo, doBlend)
		nb[i] = id
		if(!present[id])
			present[id] = mo
			srcs[id] = O
	return own

/proc/BuildOrgOrder(list/present)
	var/list/order = list()
	for(var/id in present)
		var/k = 1
		while(k <= order.len && order[k] < id)
			k++
		order.Insert(k, id)
	return order

/proc/BuildOrgGround(turf/T, m, th, doBlend, list/fresh)
	var/list/present = list()
	var/list/srcs = list()
	var/list/nb = new/list(8)
	var/own = BuildOrgLayers(T, m, th, doBlend, present, srcs, nb)
	if(present.len < 2)
		return
	var/list/order = BuildOrgOrder(present)
	var/baseMat = present[order[1]]
	var/wx = BuildOrgWindowX(T)
	var/wy = BuildOrgWindowY(T)
	var/ownIdx = order.Find(own)
	if(ownIdx > 1)
		var/ownInv = BuildOrgMaskFor(own, m, own, nb, baseMat, wx, wy, 1)
		if(!isnum(ownInv) || ownInv)
			for(var/k = 1 to ownIdx - 1)
				var/L = order[k]
				var/image/PI = BuildEdgeImage(srcs[L])
				if(k > 1)
					var/LM = BuildOrgMaskFor(L, present[L], own, nb, baseMat, wx, wy, 0)
					if(isnum(LM))
						if(!LM)
							continue
					else
						PI.filters += LM
				if(!isnum(ownInv))
					PI.filters += BuildOrgMaskFor(own, m, own, nb, baseMat, wx, wy, 1)
				fresh += PI
	for(var/k = ownIdx + 1 to order.len)
		var/M = order[k]
		var/MM = BuildOrgMaskFor(M, present[M], own, nb, baseMat, wx, wy, 0)
		if(isnum(MM))
			if(!MM)
				continue
			fresh += BuildEdgeImage(srcs[M])
			continue
		var/image/HI = BuildEdgeImage(srcs[M])
		HI.filters += MM
		fresh += HI

/proc/BuildMatSameH(turf/O, th)
	return (O && ElevAt(O) == th) ? BuildMaterialFor(O) : null

/proc/BuildIsEdgeObj(obj/O)
	if(!O || !istype(O, /obj/Turfs))
		return 0
	if(O.icon == 'Edges.dmi' || O.icon == 'grayrockedges.dmi' || O.icon == 'Icons/Objects/EdgesDir.dmi')
		return 1
	return 0

/proc/BuildEdgeObjOn(turf/T)
	if(!T)
		return null
	for(var/obj/Turfs/O in T)
		if(BuildIsEdgeObj(O))
			return O
	return null

/proc/BuildEdgeObjSideways(turf/T)
	var/obj/O = BuildEdgeObjOn(T)
	if(!O)
		return 0
	return (O.dir == EAST || O.dir == WEST) ? 1 : 0

/proc/BuildMatFor(turf/T, turf/O, th)
	if(!O || O.EdgeOptOut || BuildEdgeObjOn(O))
		return null
	return BuildMatSameH(O, th)

/proc/BuildNoEdgeExportSidecar(x1, y1, x2, y2, z, fname)
	var/cf = "[copytext(fname, 1, -4)]_noedge.txt"
	if(fexists(cf))
		fdel(cf)
	var/list/out = list()
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			var/turf/T = locate(x, y, z)
			if(T && T.EdgeOptOut)
				out += "[x - x1]\t[y - y1]"
	if(!out.len)
		return 0
	text2file(jointext(out, "\n"), cf)
	return out.len

/proc/BuildNoEdgeImportSidecar(fname, ox, oy, oz)
	var/cf = "[copytext(fname, 1, -4)]_noedge.txt"
	if(!fexists(cf))
		return 0
	var/raw = file2text(cf)
	var/n = 0
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		var/dx = text2num(f[1])
		var/dy = text2num(f[2])
		if(isnull(dx) || isnull(dy))
			continue
		var/turf/T = locate(ox + dx, oy + dy, oz)
		if(T)
			T.EdgeOptOut = 1
			n++
	return n

var/global/list/buildLipCrawlStates

/proc/BuildIsRockLip(obj/O)
	if(!O)
		return 0
	if(O.icon == 'grayrockedges.dmi')
		return 1
	if(O.icon == 'Edges.dmi' && (O.icon_state in list("1", "2", "3", "4", "5", "6", "7")))
		return 1
	return 0

/proc/BuildLipCrawl(turf/T, obj/EO, list/fresh)
	if(!T || !EO || !(EO.dir == EAST || EO.dir == WEST) || !BuildIsRockLip(EO))
		return
	var/m = BuildMaterialFor(T)
	if(!m || m == "Water")
		return
	var/sty = BuildEdgeStyleFor(m)
	if(sty != "wispy" && sty != "crumbly" && sty != "soft")
		return
	if(!buildLipCrawlStates)
		buildLipCrawlStates = ElevStateSet('Mapping/Elevation/elev_lipcrawl.dmi')
	var/st = "lc_[sty]_[(EO.dir == WEST) ? "L" : "R"]_[ElevLipWidth(EO)]"
	if(!buildLipCrawlStates[st])
		return
	var/eh = ElevAt(T)
	var/image/I = image(ElevTexIcon(T, eh), null, ElevTexState(T, eh))
	I.layer = EO.layer + 0.01
	I.filters = filter(type = "alpha", icon = ElevMaskIcon('Mapping/Elevation/elev_lipcrawl.dmi', st))
	fresh += I

/proc/BuildEdgePiece(turf/src_turf, mask)
	var/eh = ElevAt(src_turf)
	var/image/I = image(ElevTexIcon(src_turf, eh), null, ElevTexState(src_turf, eh))
	I.layer = 2.9
	I.filters = filter(type = "alpha", icon = mask)
	return I


var/global/list/buildCliffTurfTypes
var/global/list/cliffPaintMap

/proc/BuildCliffTypesInit()
	if(buildCliffTurfTypes)
		return
	buildCliffTurfTypes = list()
	buildCliffTurfTypes[/turf/Wall7] = 1
	buildCliffTurfTypes[/turf/Wall12] = 1
	buildCliffTurfTypes[/turf/Wall13] = 1
	buildCliffTurfTypes[/turf/Wall14] = 1
	buildCliffTurfTypes[/turf/Wall15] = 1
	buildCliffTurfTypes[/turf/Wall16] = 1
	buildCliffTurfTypes[/turf/Wall29] = 1
	buildCliffTurfTypes[/turf/Wall36] = 1
	buildCliffTurfTypes[/turf/Wall37] = 1
	buildCliffTurfTypes[/turf/Wall38] = 1
	buildCliffTurfTypes[/turf/Wall56] = 1
	buildCliffTurfTypes[/turf/Wall99] = 1

/proc/BuildIsCliffTurf(turf/T)
	if(!T)
		return 0
	BuildCliffTypesInit()
	if(buildCliffTurfTypes[T.type])
		return 1
	if(istype(T, /turf/CustomTurf))
		var/datum/build_custom_def/D = BuildCustomDefForTurf(T)
		if(D && D.cliff)
			return 1
	return 0

/proc/BuildCliffPaintLoad()
	if(cliffPaintMap)
		return
	cliffPaintMap = list()
	if(!fexists("Saves/CliffPaint.txt"))
		return
	var/raw = file2text("Saves/CliffPaint.txt")
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		if(!length(f[1]) || !length(f[2]))
			continue
		cliffPaintMap[f[1]] = f[2]

/proc/BuildCliffPaintSave()
	if(!cliffPaintMap)
		return
	var/list/lines = list()
	for(var/k in cliffPaintMap)
		lines += "[k]\t[cliffPaintMap[k]]"
	if(fexists("Saves/CliffPaint.txt"))
		fdel("Saves/CliffPaint.txt")
	text2file(jointext(lines, "\n"), "Saves/CliffPaint.txt")

/proc/BuildCliffStyleAt(turf/T)
	if(!T)
		return "default"
	BuildCliffPaintLoad()
	var/s = cliffPaintMap["[T.x],[T.y],[T.z]"]
	return s ? s : "default"

/proc/BuildCliffPaintRegion(x1, y1, x2, y2, z, style)
	BuildCliffPaintLoad()
	var/list/hit = list()
	var/n = 0
	for(var/turf/T in TurfSquare(x1, y1, x2, y2, z, 0))
		var/k = "[T.x],[T.y],[T.z]"
		if(style == "default")
			cliffPaintMap -= k
		else
			cliffPaintMap[k] = style
		hit += T
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
	BuildCliffPaintSave()
	if(hit.len)
		BuildEdgeSmoothAround(hit, 1)
		if(elevMap && elevMap.len)
			ElevVisualRefresh(hit)
	return n

/proc/BuildCliffExportSidecar(x1, y1, x2, y2, z, fname)
	BuildCliffPaintLoad()
	var/cf = "[copytext(fname, 1, -4)]_cliffs.txt"
	if(fexists(cf))
		fdel(cf)
	var/list/out = list()
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			var/st = cliffPaintMap["[x],[y],[z]"]
			if(st)
				out += "[x - x1]\t[y - y1]\t[st]"
	if(!out.len)
		return 0
	text2file(jointext(out, "\n"), cf)
	return out.len

/proc/BuildCliffImportSidecar(fname, ox, oy, oz)
	var/cf = "[copytext(fname, 1, -4)]_cliffs.txt"
	if(!fexists(cf))
		return 0
	BuildCliffPaintLoad()
	var/raw = file2text(cf)
	var/n = 0
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 3)
			continue
		var/dx = text2num(f[1])
		var/dy = text2num(f[2])
		if(isnull(dx) || isnull(dy) || !length(f[3]))
			continue
		cliffPaintMap["[ox + dx],[oy + dy],[oz]"] = f[3]
		n++
	if(n)
		BuildCliffPaintSave()
	return n

var/global/list/foamPaintMap

/proc/BuildFoamPaintLoad()
	if(foamPaintMap)
		return
	foamPaintMap = list()
	if(!fexists("Saves/FoamPaint.txt"))
		return
	var/raw = file2text("Saves/FoamPaint.txt")
	for(var/line in splittext(raw, "\n"))
		var/k = copytext(line, 1, findtext(line, "\t") || 0)
		if(length(k))
			foamPaintMap[k] = "off"

/proc/BuildFoamPaintSave()
	if(!foamPaintMap)
		return
	var/list/lines = list()
	for(var/k in foamPaintMap)
		lines += "[k]\toff"
	if(fexists("Saves/FoamPaint.txt"))
		fdel("Saves/FoamPaint.txt")
	text2file(jointext(lines, "\n"), "Saves/FoamPaint.txt")

/proc/BuildFoamOffAt(turf/T)
	if(!T)
		return 0
	BuildFoamPaintLoad()
	return foamPaintMap["[T.x],[T.y],[T.z]"] ? 1 : 0

/proc/BuildFoamPaintRegion(x1, y1, x2, y2, z, off)
	BuildFoamPaintLoad()
	var/list/hit = list()
	var/n = 0
	var/cnt = 0
	for(var/turf/T in TurfSquare(x1, y1, x2, y2, z, 0))
		var/k = "[T.x],[T.y],[T.z]"
		if(off)
			foamPaintMap[k] = "off"
		else
			foamPaintMap -= k
		hit += T
		if(BuildMaterialFor(T) == "Water")
			cnt++
		n++
		if(n % BUILD_COMMIT_CHUNK == 0)
			sleep(-1)
	BuildFoamPaintSave()
	if(hit.len)
		BuildEdgeSmoothAround(hit, 1)
		ElevVisualRefresh(hit)
	return cnt

/proc/BuildFoamExportSidecar(x1, y1, x2, y2, z, fname)
	BuildFoamPaintLoad()
	var/cf = "[copytext(fname, 1, -4)]_foam.txt"
	if(fexists(cf))
		fdel(cf)
	var/list/out = list()
	for(var/y = y1 to y2)
		for(var/x = x1 to x2)
			if(foamPaintMap["[x],[y],[z]"])
				out += "[x - x1]\t[y - y1]\toff"
	if(!out.len)
		return 0
	text2file(jointext(out, "\n"), cf)
	return out.len

/proc/BuildFoamImportSidecar(fname, ox, oy, oz)
	var/cf = "[copytext(fname, 1, -4)]_foam.txt"
	if(!fexists(cf))
		return 0
	BuildFoamPaintLoad()
	var/raw = file2text(cf)
	var/n = 0
	for(var/line in splittext(raw, "\n"))
		var/list/f = splittext(line, "\t")
		if(f.len < 2)
			continue
		var/dx = text2num(f[1])
		var/dy = text2num(f[2])
		if(isnull(dx) || isnull(dy))
			continue
		foamPaintMap["[ox + dx],[oy + dy],[oz]"] = "off"
		n++
	if(n)
		BuildFoamPaintSave()
	return n

/proc/BuildCliffCurveSides(turf/T)
	if(!BuildIsCliffTurf(T))
		return 0
	if(BuildIsCliffTurf(locate(T.x, T.y - 1, T.z)))
		return 0
	var/s = 0
	var/turf/W = locate(T.x - 1, T.y, T.z)
	var/turf/E = locate(T.x + 1, T.y, T.z)
	if(W && !BuildIsCliffTurf(W) && !BuildIsCliffTurf(locate(T.x - 1, T.y - 1, T.z)))
		s |= 1
	if(E && !BuildIsCliffTurf(E) && !BuildIsCliffTurf(locate(T.x + 1, T.y - 1, T.z)))
		s |= 2
	return s

/proc/BuildCliffCurve(turf/T, list/fresh)
	var/s = BuildCliffCurveSides(T)
	if(!s || ElevFaceInfo(T))
		return
	if(s & 1)
		fresh += BuildEdgePiece(locate(T.x - 1, T.y, T.z), 'Mapping/EdgeMasks/cc_l.png')
	if(s & 2)
		fresh += BuildEdgePiece(locate(T.x + 1, T.y, T.z), 'Mapping/EdgeMasks/cc_r.png')

/proc/BuildEdgeApply(turf/T, list/fresh)
	if(!fresh || !fresh.len)
		return
	for(var/img in fresh)
		T.overlays += img
	T.edgeOverlays = fresh

var/global/buildBootPassMark = 0

/proc/BuildBootPassYield()
	var/d = world.timeofday - buildBootPassMark
	if(d < 0)
		d += 864000
	if(d < BUILD_BOOT_PUMP)
		return 0
	sleep(world.tick_lag)
	buildBootPassMark = world.timeofday
	return 1

/proc/BuildEdgeQuietTile(turf/T)
	if(istype(T, /turf/CustomTurf))
		return 0
	var/tp = T.type
	var/st = T.SecondaryTurfType
	var/ic = T.icon
	var/ist = T.icon_state
	var/th = ElevAt(T)
	var/x = T.x
	var/y = T.y
	var/z = T.z
	for(var/dy = -1 to 1)
		for(var/dx = -1 to 1)
			if(!dx && !dy)
				continue
			var/turf/O = locate(x + dx, y + dy, z)
			if(!O || O.type != tp || O.SecondaryTurfType != st || O.icon != ic || O.icon_state != ist || O.EdgeOptOut || ElevAt(O) != th)
				return 0
	for(var/dy = -1 to 1)
		for(var/dx = -1 to 1)
			if(BuildEdgeObjOn(locate(x + dx, y + dy, z)))
				return 0
	return 1

/proc/BuildEdgeUpdate(turf/T, doBlend = 1)
	if(!T)
		return
	if(T.edgeOverlays)
		for(var/img in T.edgeOverlays)
			T.overlays -= img
	T.edgeOverlays = null
	if(T.EdgeOptOut || BuildEdgeQuietTile(T))
		return
	var/list/fresh = list()
	var/obj/EO = BuildEdgeObjOn(T)
	if(EO)
		BuildLipCrawl(T, EO, fresh)
		BuildEdgeApply(T, fresh)
		return
	BuildCliffCurve(T, fresh)
	var/m = BuildMaterialFor(T)
	if(!m)
		BuildEdgeApply(T, fresh)
		return
	var/th = ElevAt(T)
	BuildOrgGround(T, m, th, doBlend, fresh)
	ShoreFoamAdd(T, m, fresh)
	BuildEdgeApply(T, fresh)

/proc/BuildEdgeSmoothAround(list/turfs, doBlend = 1, bootPump = 0)
	var/list/seen = list()
	var/n = 0
	for(var/turf/T in turfs)
		for(var/dx = -1 to 1)
			for(var/dy = -1 to 1)
				var/turf/T2 = locate(T.x + dx, T.y + dy, T.z)
				if(!T2 || seen[T2])
					continue
				seen[T2] = 1
				BuildEdgeUpdate(T2, doBlend)
				n++
				if(n % BUILD_COMMIT_CHUNK == 0)
					if(!bootPump || !BuildBootPassYield())
						sleep(-1)

/proc/BuildEdgeBootPass()
	set waitfor = FALSE
	set background = TRUE
	var/t0 = world.timeofday
	var/list/all = list()
	for(var/turf/T in Turfs)
		all += T
	for(var/turf/T in CustomTurfs)
		all += T
	if(!all.len)
		return
	buildBootPassMark = world.timeofday
	BuildEdgeSmoothAround(all, 1, 1)
	Log("Mapper", "Auto-edge boot pass smoothed around [all.len] registered turfs.", 1)
	var/list/cliffs = list()
	var/scanned = 0
	for(var/turf/T in all)
		if(++scanned % BUILD_COMMIT_CHUNK == 0)
			BuildBootPassYield()
		if(BuildIsCliffTurf(T))
			cliffs += T
	if(cliffs.len)
		ElevVisualRefresh(cliffs, 1)
		Log("Mapper", "Cliff boot pass dressed [cliffs.len] placed cliff turfs.", 1)
	world.log << "BOOT edge pass finished: [BootSeconds(t0)] s ([all.len] registered turfs, [cliffs.len] cliffs)"

var/global/list/buildCliffPickerEntries

/proc/BuildCliffCodeForPath(path)
	switch(path)
		if(/turf/Wall7)
			return "wall7"
		if(/turf/Wall12)
			return "wall12"
		if(/turf/Wall13)
			return "wall13"
		if(/turf/Wall14)
			return "wall14"
		if(/turf/Wall15)
			return "wall15"
		if(/turf/Wall16)
			return "wall16"
		if(/turf/Wall29)
			return "wall29"
		if(/turf/Wall36)
			return "wall36"
		if(/turf/Wall37)
			return "wall37"
		if(/turf/Wall38)
			return "wall38"
		if(/turf/Wall56)
			return "wall56"
		if(/turf/Wall99)
			return "wall99"
	return ""

/proc/BuildCliffStyleCodeFor(datum/build_entry/E)
	if(!E || !E.iconF)
		return ""
	var/c = BuildCliffCodeForPath(E.Creates)
	if(length(c))
		return c
	if(E.isCustom)
		return "i:[E.iconF]|[E.icon_state]"
	return "t:[E.Creates]|[E.icon_state]"

/proc/BuildCliffPickerEntries()
	if(buildCliffPickerEntries)
		return buildCliffPickerEntries
	BuildPaletteInit()
	var/list/out = list()
	var/datum/build_entry/DE = new
	DE.name = "-DEFAULT ROCK: WALL38 FACES, WALL29 WATER STRIPS-"
	DE.styleCode = "default"
	for(var/datum/build_entry/E in buildPalette)
		if(E.Creates == /turf/Wall38)
			DE.iconF = E.iconF
			DE.icon_state = E.icon_state
			DE.thumb = E.thumb
			break
	out += DE
	var/datum/build_entry/NE = new
	NE.name = "-NO ROCK STRIP UNDER WATER (FACES: DEFAULT ROCK)-"
	NE.styleCode = "none"
	NE.iconF = 'HUD/build_white.png'
	NE.swatchColor = "#3b7dd8"
	out += NE
	for(var/datum/build_entry/E in buildPalette)
		if(E.isZone || E.category == BUILD_CAT_SPECIAL || !ispath(E.Creates, /turf) || !E.iconF)
			continue
		var/take = 0
		if(E.isCustom)
			var/datum/build_custom_def/D = length(E.cDef) ? BuildCustomFindByName(E.cDef) : BuildCustomDefForIcon(E.iconF, E.icon_state)
			take = (D && D.cliff) ? 1 : 0
		else if(findtext(lowertext("[E.Creates]"), "wall") || findtext(lowertext(E.name), "wall"))
			take = 1
		if(!take)
			continue
		E.styleCode = BuildCliffStyleCodeFor(E)
		out += E
	buildCliffPickerEntries = out
	return out

/proc/BuildCliffStyleLabel(code)
	if(!length(code) || code == "default")
		return "DEFAULT ROCK"
	if(code == "none")
		return "NO ROCK STRIP UNDER WATER"
	for(var/datum/build_entry/E in BuildCliffPickerEntries())
		if(E.styleCode == code)
			return E.name
	if(copytext(code, 1, 5) == "wall")
		return "WALL [copytext(code, 5)]"
	var/p = findtext(code, "|")
	return p ? copytext(code, p + 1) : code

/proc/BuildCliffStyleStamp(turf/T, style)
	if(!T || !length(style))
		return 0
	BuildCliffPaintLoad()
	var/k = "[T.x],[T.y],[T.z]"
	if(style == "default")
		if(!cliffPaintMap[k])
			return 0
		cliffPaintMap -= k
		return 1
	if(cliffPaintMap[k] == style)
		return 0
	cliffPaintMap[k] = style
	return 1

/proc/BuildCliffPickEnter(datum/build_session/S)
	if(!S?.active)
		return
	S.CancelPending()
	S.pickPrevCat = S.category
	S.stylePick = 1
	S.filter = ""
	S.RefreshFiltered()
	BuildHUDRefreshGrid(S)
	BuildHUDRefreshDrop(S)
	BuildHUDRefreshSearch(S)
	BuildHUDSetSelName(S, "CLIFF STYLE: CLICK A WALL (NOW: [BuildCliffStyleLabel(S.cliffStyleSel)])")
	S.C.mob << "CLIFF STYLE: the drawer now lists every wall. Click one - from then on every tile you raise wears it as its cliff face and water you place gets it as its rock strip, until you pick another. Current: [BuildCliffStyleLabel(S.cliffStyleSel)]. Pick a category from the drop-down to leave without changing it."

/proc/BuildCliffPickExit(datum/build_session/S)
	if(!S?.stylePick)
		return
	S.stylePick = 0
	if(length(S.pickPrevCat))
		S.category = S.pickPrevCat
	S.RefreshFiltered()
	BuildHUDRefreshGrid(S)
	BuildHUDRefreshDrop(S)

/proc/BuildCliffPickChoose(datum/build_session/S, datum/build_entry/E)
	if(!S || !E)
		return
	var/code = length(E.styleCode) ? E.styleCode : BuildCliffStyleCodeFor(E)
	if(!length(code))
		return
	S.cliffStyleSel = code
	S.C?.setPref("cliffStyle", code)
	BuildCliffPickExit(S)
	BuildHUDSetSelName(S, "CLIFF STYLE: [BuildCliffStyleLabel(code)]")
	S.C?.mob << "Cliff style: [BuildCliffStyleLabel(code)]. Raised terrain and placed water use it from now on."
	Log("Mapper", "[S.C?.mob] ([S.C?.ckey]) set cliff style [code].", 1)

mob/Mapper/verb/Paint_Cliff_Style()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	BuildCliffPickEnter(S)

mob/Mapper/verb/Paint_Foam_Off()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.regionSel = "foam:off"
	S.cliffStage = 1
	usr << "FOAM OFF: click the FIRST corner of the region. Water tiles inside it lose their shore foam. Right-click cancels."

mob/Mapper/verb/Paint_Foam_On()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.regionSel = "foam:on"
	S.cliffStage = 1
	usr << "FOAM ON: click the FIRST corner of the region. Water tiles inside it get their shore foam back. Right-click cancels."

mob/Mapper/verb/Edge_Debug()
	set category = "Mapper"
	var/turf/T = usr.loc
	if(!isturf(T))
		usr << "Stand on a tile first."
		return
	BuildOrgSheetInit()
	usr << "EDGE DEBUG @ ([T.x],[T.y],[T.z]) - [buildOrgSheets.len] organic mask sheets compiled in, window [BuildOrgWindowX(T)],[BuildOrgWindowY(T)]."
	var/m = BuildMaterialFor(T)
	usr << "  HERE: [T.type] -> [m ? "[m] (style [BuildEdgeStyleFor(m)], priority [BuildMaterialPriority(m)])" : "NO MATERIAL (will not edge)"]"
	usr << "  tracked edge overlays on this tile: [T.edgeOverlays ? T.edgeOverlays.len : 0]"
	usr << "  auto-edging for this tile: [T.EdgeOptOut ? "OFF (placed with auto-edge off; neighbours ignore it)" : "on"][BuildEdgeObjOn(T) ? ", edge object present (no auto pieces, lip crawl only)" : ""]"
	var/list/dirs = list("N" = list(0, 1), "S" = list(0, -1), "E" = list(1, 0), "W" = list(-1, 0))
	for(var/d in dirs)
		var/list/o = dirs[d]
		var/turf/T2 = locate(T.x + o[1], T.y + o[2], T.z)
		if(!T2)
			continue
		var/m2 = BuildMaterialFor(T2)
		usr << "  [d]: [T2.type] -> [m2 ? "[m2] (style [BuildEdgeStyleFor(m2)], priority [BuildMaterialPriority(m2)])" : "NO MATERIAL (will not edge)"]"
	if(m)
		var/list/present = list()
		var/list/srcs = list()
		var/list/nb = new/list(8)
		var/own = BuildOrgLayers(T, m, ElevAt(T), 1, present, srcs, nb)
		var/list/order = BuildOrgOrder(present)
		usr << "  layers in the 3x3 (lowest first, base style [BuildEdgeStyleFor(present[order[1]])]):"
		for(var/id in order)
			usr << "    [id == own ? "HERE " : ""][present[id]] config [BuildOrgConfig(id, own, nb)] - [id]"

mob/Mapper/verb/Smooth_Region()
	set category = "Mapper"
	var/datum/build_session/S = usr.client?.bsession
	if(!S?.active)
		usr << "Turn on Build Mode first (ToggleBuildMode), then run this again."
		return
	S.CancelPending()
	S.smoothStage = 1
	usr << "SMOOTH: click the FIRST corner of the region to auto-edge. Right-click cancels."
