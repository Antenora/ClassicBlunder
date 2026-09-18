#define ELEV_KMAX 1.2
#define ELEV_TOP_LAYER 2.05
#define ELEV_FOAM_LAYER 2.899

turf/var/tmp/list/elevOverlays
turf/var/tmp/elev_pit = 0
turf/var/tmp/elev_pitv = 0
turf/var/tmp/turf/elev_cov
turf/var/tmp/elev_covv = 0

var/global/elevPitVer = 1
var/global/elevGeomVer = 1
var/global/list/elevTexCache = list()
var/global/list/elevMaskCache = list()
var/global/list/elevFaceStates
var/global/list/elevBaseStates
var/global/list/elevLipStates
var/global/list/elevPitStates
var/global/list/elevFoamStates
var/global/list/elevLipSlots = list("v", "h", "d")
var/global/list/elevFaceStyleStates = list()
var/global/list/elevShadeStates
var/global/elevWallCtxL = 0

/proc/ElevGeomChanged()
	elevGeomVer++
	elevPitVer++

/proc/ElevCoverInvalidate(list/turfs)
	if(!turfs)
		return
	for(var/turf/T in turfs)
		for(var/dx = -2 to 2)
			for(var/dy = -(ELEV_MAX + ELEV_DMAX) to ELEV_MAX)
				var/turf/B = locate(T.x + dx, T.y + dy, T.z)
				if(B)
					B.elev_covv = 0
	elevPitVer++

/proc/ElevFoamTrio(prefix, key, turf/WT, lay, list/fresh)
	if(!glob || !glob.SHORE_FOAM || !WT || BuildFoamOffAt(WT))
		return
	if(elevFoamStates["[prefix]c[key]"])
		var/image/C = image('Mapping/Elevation/elev_foam.dmi', null, "[prefix]c[key]")
		C.layer = lay
		C.color = ShoreWaterMean(WT)
		fresh += C
	if(elevFoamStates["[prefix]t[key]"])
		fresh += ElevPlain('Mapping/Elevation/elev_foam.dmi', "[prefix]t[key]", lay)
	if(elevFoamStates["[prefix]a[key]"])
		fresh += ElevPlain('Mapping/Elevation/elev_foam.dmi', "[prefix]a[key]", lay)

/proc/ElevLayer(L, part)
	return 2.91 + (L - 1) * 0.005 + part * 0.0005

/proc/ElevStateSet(ic)
	var/list/s = list()
	for(var/n in icon_states(ic))
		s[n] = 1
	return s

/proc/ElevStatesInit()
	if(elevFaceStates)
		return
	elevFaceStates = ElevStateSet('Mapping/Elevation/elev_face.dmi')
	elevBaseStates = ElevStateSet('Mapping/Elevation/elev_base.dmi')
	elevLipStates = ElevStateSet('Mapping/Elevation/elev_lip.dmi')
	elevPitStates = ElevStateSet('Mapping/Elevation/elev_pit.dmi')
	elevFoamStates = ElevStateSet('Mapping/Elevation/elev_foam.dmi')
	elevShadeStates = ElevStateSet('Mapping/Elevation/elev_face_shade.dmi')

/proc/ElevTexIcon(turf/T, h)
	if(!T)
		return null
	if(h <= 0)
		return T.icon
	var/k = "[T.icon]|[T.icon_state]|[h]"
	var/icon/I = elevTexCache[k]
	if(!I)
		I = icon(T.icon, T.icon_state)
		var/dx = (7 * h) % 32
		var/dy = (24 * h) % 32
		if(dx)
			I.Shift(EAST, dx, 1)
		if(dy)
			I.Shift(SOUTH, dy, 1)
		elevTexCache[k] = I
	return I

/proc/ElevTexState(turf/T, h)
	return (h > 0) ? "" : T.icon_state

/proc/ElevMaskIcon(ic, st)
	var/k = "[ic]|[st]"
	var/icon/I = elevMaskCache[k]
	if(!I)
		I = icon(ic, st)
		elevMaskCache[k] = I
	return I

/proc/ElevPlain(ic, st, lay)
	var/image/I = image(ic, null, st)
	I.layer = lay
	return I

/proc/ElevTexPiece(turf/S, ic, st, lay, bright)
	var/h = ElevAt(S)
	var/image/I = image(ElevTexIcon(S, h), null, ElevTexState(S, h))
	I.dir = S.dir
	I.layer = lay
	if(bright)
		I.color = list(ELEV_KMAX, 0, 0, 0, ELEV_KMAX, 0, 0, 0, ELEV_KMAX)
	I.filters = filter(type = "alpha", icon = ElevMaskIcon(ic, st))
	return I

/proc/ElevFaceFile(style)
	switch(style)
		if("wall7")
			return 'Mapping/Elevation/elev_face_wall7.dmi'
		if("wall12")
			return 'Mapping/Elevation/elev_face_wall12.dmi'
		if("wall13")
			return 'Mapping/Elevation/elev_face_wall13.dmi'
		if("wall14")
			return 'Mapping/Elevation/elev_face_wall14.dmi'
		if("wall15")
			return 'Mapping/Elevation/elev_face_wall15.dmi'
		if("wall16")
			return 'Mapping/Elevation/elev_face_wall16.dmi'
		if("wall29")
			return 'Mapping/Elevation/elev_face_wall29.dmi'
		if("wall36")
			return 'Mapping/Elevation/elev_face_wall36.dmi'
		if("wall37")
			return 'Mapping/Elevation/elev_face_wall37.dmi'
		if("wall56")
			return 'Mapping/Elevation/elev_face_wall56.dmi'
		if("wall99")
			return 'Mapping/Elevation/elev_face_wall99.dmi'
	return 'Mapping/Elevation/elev_face.dmi'

var/global/list/elevStyleArtCache = list()

/proc/ElevStyleGeneric(style)
	if(length(style) <= 2)
		return 0
	var/pre = copytext(style, 1, 3)
	return (pre == "i:" || pre == "t:") ? 1 : 0

/proc/ElevStyleArtFromBuilds(key, st, byType)
	if(!Builds || !Builds.len)
		Add_Builds()
	for(var/obj/Others/Build/B in Builds)
		if(byType ? ("[B.Creates]" == key) : ("[B.icon]" == key))
			if("[B.icon_state]" == "[st]")
				return list(B.icon, B.icon_state)
	return null

/proc/ElevStyleArt(style)
	if(!ElevStyleGeneric(style))
		return null
	var/hit = elevStyleArtCache[style]
	if(hit)
		return (hit == "none") ? null : hit
	var/p = findtext(style, "|")
	var/path = p ? copytext(style, 3, p) : copytext(style, 3)
	var/st = p ? copytext(style, p + 1) : ""
	var/list/art = null
	if(copytext(style, 1, 3) == "t:")
		art = ElevStyleArtFromBuilds(path, st, 1)
	else if(length(path) && fexists(path))
		art = list(file(path), st)
	else
		art = ElevStyleArtFromBuilds(path, st, 0)
	elevStyleArtCache[style] = art ? art : "none"
	return art

/proc/ElevFacePiece(style, st, lay)
	if(style == "custom" || ElevStyleGeneric(style) || !elevFaceStates[st])
		return null
	var/ic = ElevFaceFile(style)
	if(style != "wall38")
		var/list/ss = elevFaceStyleStates[style]
		if(!ss)
			ss = ElevStateSet(ic)
			elevFaceStyleStates[style] = ss
		if(!ss[st])
			ic = 'Mapping/Elevation/elev_face.dmi'
	return ElevPlain(ic, st, lay)

/proc/ElevWrapEnd(turf/T, list/fi, dx)
	var/code = (dx < 0) ? fi[4] : fi[5]
	if(code == "e")
		return "x"
	if(code != "f")
		return code
	var/list/nf = ElevFaceInfo(locate(T.x + dx, T.y, T.z))
	if(nf && nf[3] < nf[2])
		return "j"
	return "f"

/proc/ElevShadePiece(st, lay)
	if(!elevShadeStates || !elevShadeStates[st])
		return null
	return ElevPlain('Mapping/Elevation/elev_face_shade.dmi', st, lay)

/proc/ElevNaturalTop(turf/CT)
	if(!CT)
		return 1
	var/m = BuildMaterialFor(CT)
	return (m == "Grass" || m == "Dirt" || m == "Water" || m == "Sand" || m == "Ice") ? 1 : 0

/proc/ElevFaceFlat(turf/CT, fsty)
	if(fsty == "custom")
		return 0
	if(ElevStyleGeneric(fsty))
		return 1
	return ElevNaturalTop(CT) ? 0 : 1

/proc/ElevFlatArt(style)
	if(ElevStyleGeneric(style))
		return ElevStyleArt(style)
	if(length(style) > 4 && copytext(style, 1, 5) == "wall")
		return list('Icons/Turfs/Walls.dmi', "Wall[copytext(style, 5)]")
	return null

/proc/ElevCliffTurfStyle(turf/T)
	if(!T)
		return null
	switch(T.type)
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
	return null

/proc/ElevFaceStyleFor(turf/faceTile, turf/CT)
	if(faceTile && ElevAt(faceTile) <= 0 && BuildIsCliffTurf(faceTile))
		var/cs = ElevCliffTurfStyle(faceTile)
		return cs ? cs : "custom"
	return ElevFaceStyleAt(faceTile, CT)

/proc/ElevFaceStyleAt(turf/G, turf/CT)
	BuildCliffPaintLoad()
	var/s = CT ? cliffPaintMap["[CT.x],[CT.y],[CT.z]"] : null
	if(!s || s == "default" || s == "none")
		s = cliffPaintMap["[G.x],[G.y],[G.z]"]
	if(!s || s == "default" || s == "none")
		return "wall38"
	return s

/proc/ElevCoverCalc(turf/G)
	var/hg = ElevAt(G)
	for(var/k = 1 to ELEV_MAX)
		var/turf/U = locate(G.x, G.y + k, G.z)
		if(!U)
			break
		var/top = ElevAt(U)
		if(top - ElevAt(locate(G.x, G.y + k - 1, G.z)) >= k && hg < top)
			return U
	if(hg <= 0 && BuildIsCliffTurf(G))
		var/turf/N = locate(G.x, G.y + 1, G.z)
		if(!N)
			return null
		var/turf/CU = ElevCoverOf(N)
		if(CU)
			return (CU.y - G.y <= ELEV_DMAX) ? CU : null
		if(!BuildIsCliffTurf(N) && BuildMaterialFor(N) != "Water")
			return N
	return null

/proc/ElevCoverOf(turf/G)
	if(!G)
		return null
	if(G.elev_covv == elevGeomVer)
		return G.elev_cov
	var/turf/res = ElevCoverCalc(G)
	G.elev_cov = res
	G.elev_covv = elevGeomVer
	return res

/proc/ElevChain(turf/G)
	var/turf/CT = ElevCoverOf(G)
	if(!CT)
		return null
	var/turf/B = G
	for(var/i = 1 to ELEV_DMAX)
		if(CT.y - B.y >= ELEV_DMAX)
			break
		var/turf/S = locate(B.x, B.y - 1, B.z)
		if(!S || ElevCoverOf(S) != CT)
			break
		B = S
	var/top = ElevAt(CT)
	if(top <= 0)
		top = CT.y - B.y
	return list(top, CT.y - B.y, CT.y - G.y, CT)

/proc/ElevRunEnd(turf/G, dx, list/ch)
	var/turf/N = locate(G.x + dx, G.y, G.z)
	if(!N)
		return "f"
	var/list/nc = ElevChain(N)
	if(nc && nc[1] == ch[1] && nc[2] == ch[2] && nc[3] == ch[3])
		return "c"
	if(BuildIsCliffTurf(G))
		if(BuildIsCliffTurf(N) || nc)
			return "f"
		if(ElevManualTopHeight(N) >= 1)
			return "f"
		var/turf/WCT = ch[4]
		var/turf/EB = locate(N.x, WCT.y, N.z)
		if(BuildEdgeObjSideways(WCT) || BuildEdgeObjSideways(EB))
			return "e"
		return "x"
	var/turf/CT = ch[4]
	var/hn = max(ElevAt(locate(G.x + dx, CT.y, G.z)), ElevAt(locate(G.x + dx, CT.y - 1, G.z)))
	if(hn >= ch[1] - ch[3] + 1)
		return "f"
	return "x"

/proc/ElevFaceInfo(turf/G)
	var/list/ch = ElevChain(G)
	if(!ch)
		return null
	return list(ch[1], ch[2], ch[3], ElevRunEnd(G, -1, ch), ElevRunEnd(G, 1, ch), ch[4])

/proc/ElevWrapSrc(turf/faceTile, turf/below)
	if(faceTile && !BuildIsCliffTurf(faceTile) && BuildMaterialFor(faceTile))
		return faceTile
	return below

/proc/ElevFrays(turf/S)
	if(!S)
		return 0
	var/m = BuildMaterialFor(S)
	if(!m || m == "Water")
		return 0
	var/st = BuildEdgeStyleFor(m)
	return (st == "wispy" || st == "crumbly" || st == "soft") ? 1 : 0

/proc/ElevStyleCode(turf/T)
	if(!T)
		return "w"
	var/m = BuildMaterialFor(T)
	if(!m)
		return ""
	if(m == "Water")
		return "a"
	switch(BuildEdgeStyleFor(m))
		if("crumbly")
			return "c"
		if("soft")
			return "s"
		if("jagged")
			return "j"
		if("hard")
			return "h"
	return "w"

/proc/ElevIsPit(turf/G)
	if(!G)
		return 0
	if(G.elev_pitv == elevPitVer)
		return G.elev_pit
	var/lim = ElevAt(G)
	var/list/seen = list()
	seen[G] = 1
	var/list/st = list(G)
	var/esc = 0
	while(st.len && !esc)
		var/turf/C = st[1]
		st.Cut(1, 2)
		for(var/dd in CARDINAL_DIRECTIONS)
			var/turf/Q = get_step(C, dd)
			if(!Q)
				esc = 1
				break
			if(seen[Q] || ElevAt(Q) > lim)
				continue
			seen[Q] = 1
			if(seen.len > 400)
				esc = 1
				break
			st += Q
	var/res = esc ? 0 : 1
	for(var/turf/V in seen)
		if(ElevAt(V) == lim)
			V.elev_pit = res
			V.elev_pitv = elevPitVer
	return res

/proc/ElevSurface(turf/G, L)
	var/list/fi = ElevFaceInfo(G)
	if(fi)
		return (fi[1] <= L) ? "f" : null
	if(BuildMaterialFor(G) == "Water")
		return "w"
	if(ElevIsPit(G))
		return "p"
	return "g"

/proc/ElevLipState(turf/T, L)
	var/v = ElevAt(T)
	if(ElevCoverOf(T))
		return (v < L) ? "c" : ((v == L) ? "k" : "a")
	if(elevWallCtxL && T && v <= 0 && L == elevWallCtxL)
		if(ElevManualTopHeight(T) >= 1)
			return "t"
	return (v < L) ? "o" : ((v == L) ? "t" : "a")

/proc/ElevPitClass(turf/T, g)
	if(!T)
		return "o"
	if(ElevAt(T) > g)
		return "w"
	var/list/fi = ElevFaceInfo(T)
	if(fi && fi[1] > g)
		return "f"
	return "o"

/proc/ElevLipKey(turf/G, gh, L, q, list/srcs, eside = 0)
	var/dx = (q == 1 || q == 3) ? 1 : -1
	var/dy = (q < 2) ? 1 : -1
	var/turf/TV = locate(G.x, G.y + dy, G.z)
	var/turf/TH = locate(G.x + dx, G.y, G.z)
	var/turf/TD = locate(G.x + dx, G.y + dy, G.z)
	var/gs = (gh == L) ? "t" : "o"
	var/V = ElevLipState(TV, L)
	var/H = ElevLipState(TH, L)
	var/D = ElevLipState(TD, L)
	if(eside && dx == eside && dy > 0 && V == "t" && gs == "o")
		H = "c"
		D = "t"
	if(gs == "o" && V != "t" && H != "t" && D != "t")
		return null
	if(gs == "t" && V != "o" && H != "o" && D != "o")
		return null
	var/scode = "-"
	var/vis = "0"
	if(gs == "o")
		var/sc = ElevSurface(G, L)
		if(!sc)
			return null
		scode = sc
		if(q < 2)
			vis = (D != "o") ? "1" : "0"
		else
			vis = (H != "o" && ElevLipState(locate(G.x + dx, G.y + 1, G.z), L) != "o") ? "1" : "0"
	if(srcs)
		if(V == "t")
			srcs["v"] = TV
		if(H == "t")
			srcs["h"] = TH
		if(D == "t")
			srcs["d"] = TD
	return "[q][gs][V][H][D][scode][vis]"

/proc/ElevManualTopHeight(turf/T)
	if(!T || ElevAt(T) > 0 || BuildIsCliffTurf(T) || ElevCoverOf(T) || BuildMaterialFor(T) == "Water")
		return 0
	for(var/k = 1 to ELEV_DMAX)
		var/turf/Q = locate(T.x, T.y - k, T.z)
		if(!Q || ElevAt(Q) > 0 || BuildMaterialFor(Q) == "Water")
			return 0
		if(BuildIsCliffTurf(Q))
			if(ElevCoverOf(Q) != locate(T.x, T.y - k + 1, T.z))
				return 0
			var/list/qch = ElevChain(Q)
			return qch ? qch[1] : 0
		if(ElevCoverOf(Q))
			return 0
	return 0

/proc/ElevLipWidth(obj/O)
	if(!O)
		return 8
	if(O.icon == 'Icons/Objects/EdgesDir.dmi')
		return 5
	if(O.icon == 'grayrockedges.dmi')
		return 7
	switch(O.icon_state)
		if("1", "2")
			return 7
		if("3")
			return 8
		if("4", "5", "7")
			return 9
		if("6")
			return 10
	return 8

/proc/ElevAddLipPosts(turf/T, list/fi, fsty, fst, list/fresh)
	if(!fi || fi[3] != 1 || fsty == "custom" || !BuildIsCliffTurf(T))
		return
	var/obj/EO = BuildEdgeObjOn(fi[6])
	if(!EO || !(EO.dir == EAST || EO.dir == WEST))
		return
	var/pw = ElevLipWidth(EO)
	for(var/side in list("L", "R"))
		if(fi[(side == "L") ? 4 : 5] != "e")
			continue
		var/image/PP = ElevFacePiece(fsty, fst, ElevLayer(fi[1], 9))
		if(!PP)
			continue
		PP.filters = filter(type = "alpha", icon = ElevMaskIcon('Mapping/Elevation/elev_post.dmi', "p[pw][side]"))
		fresh += PP

/proc/ElevFaceEnd(code)
	return (code == "e") ? "x" : code

/proc/ElevWallCtxFor(turf/G)
	if(!G || !BuildIsCliffTurf(G))
		return 0
	var/list/wch = ElevChain(G)
	if(!wch)
		return 0
	var/turf/WCT = wch[4]
	if(!WCT || ElevAt(WCT) > 0)
		return 0
	return wch[1]

/proc/ElevEdgeSide(turf/G)
	if(!G || !BuildIsCliffTurf(G))
		return 0
	var/list/gfi = ElevFaceInfo(G)
	if(!gfi)
		return 0
	if(gfi[4] == "e")
		return -1
	if(gfi[5] == "e")
		return 1
	return 0

/proc/ElevLipsSkippable(turf/G, gh)
	for(var/dx = -1 to 1)
		for(var/dy = -1 to 1)
			if(!dx && !dy)
				continue
			var/turf/N = locate(G.x + dx, G.y + dy, G.z)
			if(!N)
				return 0
			if(ElevAt(N) != gh || ElevCoverOf(N))
				return 0
	return 1

/proc/ElevAddLips(turf/G, gh, list/fresh)
	var/gcov = ElevCoverOf(G) ? 1 : 0
	if(!gcov && ElevLipsSkippable(G, gh))
		return
	elevWallCtxL = gcov ? ElevWallCtxFor(G) : 0
	var/eside = elevWallCtxL ? ElevEdgeSide(G) : 0
	for(var/L = max(1, gh), L <= ELEV_MAX, L++)
		if(gcov && gh == L)
			continue
		for(var/q = 0 to 3)
			var/list/srcs = list()
			var/key = ElevLipKey(G, gh, L, q, srcs, eside)
			if(!key)
				continue
			var/drew = 0
			for(var/sn in elevLipSlots)
				var/turf/S = srcs[sn]
				if(!S || !ElevFrays(S) || ElevOrgStyle(S))
					continue
				if(elevLipStates["m[sn][key]"])
					fresh += ElevTexPiece(S, 'Mapping/Elevation/elev_lip.dmi', "m[sn][key]", ElevLayer(L, 6), 0)
					drew = 1
				if(elevLipStates["b[sn][key]"])
					fresh += ElevTexPiece(S, 'Mapping/Elevation/elev_lip.dmi', "b[sn][key]", ElevLayer(L, 7), 1)
					drew = 1
			if(gh == L && ElevFrays(G) && !ElevOrgStyle(G) && elevLipStates["bg[key]"])
				fresh += ElevTexPiece(G, 'Mapping/Elevation/elev_lip.dmi', "bg[key]", ElevLayer(L, 7), 1)
				drew = 1
			if(drew && elevLipStates["d[key]"])
				fresh += ElevPlain('Mapping/Elevation/elev_lip.dmi', "d[key]", ElevLayer(L, 8))
			var/hst = copytext(key, 4, 5)
			if(copytext(key, 6, 7) == "w" && hst != "c" && hst != "k" && hst != "a")
				ElevFoamTrio("q", key, G, ELEV_FOAM_LAYER, fresh)
	elevWallCtxL = 0

/proc/ElevAddFaceParts(turf/T, list/fresh)
	var/list/fi = ElevFaceInfo(T)
	if(fi && !ElevStairTurf(T))
		var/top = fi[1]
		var/fst = "f[fi[2]]_[fi[3]][ElevFaceEnd(fi[4])][ElevFaceEnd(fi[5])]"
		var/fsty = ElevFaceStyleFor(T, fi[6])
		var/flat = ElevFaceFlat(fi[6], fsty)
		var/org = ElevOrgStyle(fi[6]) ? 1 : 0
		var/image/FP
		if(org)
			FP = null
		else if(fsty == "custom")
			FP = ElevShadePiece("fs[fi[2]]_[fi[3]][ElevFaceEnd(fi[4])][ElevFaceEnd(fi[5])]", ElevLayer(top, 0))
		else if(flat)
			var/list/art = ElevFlatArt(fsty)
			if(art)
				fresh += ElevPlain(art[1], art[2], ElevLayer(top, 0))
				FP = ElevShadePiece("fw[fi[2]]_[fi[3]][ElevFaceEnd(fi[4])][ElevFaceEnd(fi[5])]", ElevLayer(top, 0) + 0.0001)
			else
				FP = ElevFacePiece("wall38", fst, ElevLayer(top, 0))
		else
			FP = ElevFacePiece(fsty, fst, ElevLayer(top, 0))
		if(FP)
			fresh += FP
		if(!flat && !org)
			ElevAddLipPosts(T, fi, fsty, fst, fresh)
		if(fi[3] == fi[2])
			var/turf/S = locate(T.x, T.y - 1, T.z)
			if(S)
				var/turf/WS = ElevWrapSrc(T, S)
				var/bkey = "[ElevStyleCode(WS)][T.x % 3][ElevWrapEnd(T, fi, -1)][ElevWrapEnd(T, fi, 1)]"
				if(!org && elevBaseStates["bm[bkey]"])
					fresh += ElevTexPiece(WS, 'Mapping/Elevation/elev_base.dmi', "bm[bkey]", ElevLayer(top, 2), 0)
				if(!org && elevBaseStates["bb[bkey]"])
					fresh += ElevTexPiece(WS, 'Mapping/Elevation/elev_base.dmi', "bb[bkey]", ElevLayer(top, 3), 1)
				if(!org && elevBaseStates["bd[bkey]"])
					fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "bd[bkey]", ElevLayer(top, 4))
				if(copytext(bkey, 1, 2) == "a")
					ElevFoamTrio("b", bkey, WS, ElevLayer(top, 9), fresh)
	for(var/side in list("R", "L"))
		var/turf/NB = locate(T.x + (side == "R" ? 1 : -1), T.y, T.z)
		var/list/nf = ElevFaceInfo(NB)
		if(!nf || nf[(side == "R") ? 4 : 5] != "x")
			continue
		var/nsty = ElevFaceStyleFor(NB, nf[6])
		if(ElevFaceFlat(nf[6], nsty) || ElevOrgStyle(nf[6]))
			continue
		var/ntop = nf[1]
		var/sst = "s[nf[2]]_[nf[3]][side]"
		var/image/SP = ElevFacePiece(nsty, sst, ElevLayer(ntop, 0))
		if(SP)
			fresh += SP
		if(nf[3] != nf[2])
			if(!fi && elevBaseStates["tk[side]"])
				fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "tk[side]", ElevLayer(ntop, 4))
			if(!fi && ElevStyleCode(T) == "a")
				var/inr = ElevBelowFoot(T)
				ElevFoamTrio(inr ? ((nf[3] == 1) ? "g" : "h") : ((nf[3] == 1) ? "k" : "m"), "a[T.x % 3][side]", T, ElevLayer(ntop, 9), fresh)
			continue
		var/turf/S2 = locate(T.x, T.y - 1, T.z)
		if(!S2)
			continue
		var/turf/WS2 = ElevWrapSrc(T, S2)
		var/tkey = "[ElevStyleCode(WS2)][T.x % 3][side]"
		if(elevBaseStates["tm[tkey]"])
			fresh += ElevTexPiece(WS2, 'Mapping/Elevation/elev_base.dmi', "tm[tkey]", ElevLayer(ntop, 2), 0)
		if(elevBaseStates["tb[tkey]"])
			fresh += ElevTexPiece(WS2, 'Mapping/Elevation/elev_base.dmi', "tb[tkey]", ElevLayer(ntop, 3), 1)
		if(!fi && elevBaseStates["td[tkey]"])
			fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "td[tkey]", ElevLayer(ntop, 4))
		if(!fi && copytext(tkey, 1, 2) == "a")
			var/inb = ElevBelowFoot(T)
			ElevFoamTrio(inb ? ((nf[2] == 1) ? "i" : "j") : ((nf[2] == 1) ? "t" : "s"), tkey, WS2, ElevLayer(ntop, 9), fresh)
	for(var/side in list("R", "L"))
		var/turf/DF = locate(T.x + (side == "R" ? 1 : -1), T.y - 1, T.z)
		var/list/df = ElevFaceInfo(DF)
		if(!df || df[3] != 1 || df[(side == "R") ? 4 : 5] != "x" || ElevAt(df[6]) <= 0)
			continue
		var/dsty = ElevFaceStyleFor(DF, df[6])
		if(ElevFaceFlat(df[6], dsty) || ElevOrgStyle(df[6]))
			continue
		var/image/WP = ElevFacePiece(dsty, "u[df[2]][side]", ElevLayer(df[1], 0))
		if(WP)
			fresh += WP

var/global/list/elevOrgSheets
var/global/list/elevOrgShade
var/global/list/elevOrgDark
var/global/list/elevOrgKeyFiles
var/global/list/elevOrgIndexFiles
var/global/list/elevOrgClasses
var/global/list/elevOrgKeyLines = list()
var/global/list/elevOrgIndexText = list()
var/global/list/elevOrgParsed = list()
var/global/list/elevOrgFTCache = list()
var/global/list/elevOrgBotCache = list()
var/global/list/elevOrgConvCache = list()
var/global/elevOrgConvVer = -1
var/global/list/elevOrgOffs = list(list(0, 1), list(0, -1), list(-1, 0), list(1, 0), list(1, 1), list(1, -1), list(-1, -1), list(-1, 1))

/proc/ElevOrgSheetInit()
	if(elevOrgSheets)
		return
	elevOrgSheets = list(
		"tw00" = 'Mapping/EdgeOrg/et_w00.png',
		"tw01" = 'Mapping/EdgeOrg/et_w01.png',
		"tw02" = 'Mapping/EdgeOrg/et_w02.png',
		"tw03" = 'Mapping/EdgeOrg/et_w03.png',
		"tw10" = 'Mapping/EdgeOrg/et_w10.png',
		"tw11" = 'Mapping/EdgeOrg/et_w11.png',
		"tw12" = 'Mapping/EdgeOrg/et_w12.png',
		"tw13" = 'Mapping/EdgeOrg/et_w13.png',
		"tw20" = 'Mapping/EdgeOrg/et_w20.png',
		"tw21" = 'Mapping/EdgeOrg/et_w21.png',
		"tw22" = 'Mapping/EdgeOrg/et_w22.png',
		"tw23" = 'Mapping/EdgeOrg/et_w23.png',
		"tw30" = 'Mapping/EdgeOrg/et_w30.png',
		"tw31" = 'Mapping/EdgeOrg/et_w31.png',
		"tw32" = 'Mapping/EdgeOrg/et_w32.png',
		"tw33" = 'Mapping/EdgeOrg/et_w33.png',
		"tc00" = 'Mapping/EdgeOrg/et_c00.png',
		"tc01" = 'Mapping/EdgeOrg/et_c01.png',
		"tc02" = 'Mapping/EdgeOrg/et_c02.png',
		"tc03" = 'Mapping/EdgeOrg/et_c03.png',
		"tc10" = 'Mapping/EdgeOrg/et_c10.png',
		"tc11" = 'Mapping/EdgeOrg/et_c11.png',
		"tc12" = 'Mapping/EdgeOrg/et_c12.png',
		"tc13" = 'Mapping/EdgeOrg/et_c13.png',
		"tc20" = 'Mapping/EdgeOrg/et_c20.png',
		"tc21" = 'Mapping/EdgeOrg/et_c21.png',
		"tc22" = 'Mapping/EdgeOrg/et_c22.png',
		"tc23" = 'Mapping/EdgeOrg/et_c23.png',
		"tc30" = 'Mapping/EdgeOrg/et_c30.png',
		"tc31" = 'Mapping/EdgeOrg/et_c31.png',
		"tc32" = 'Mapping/EdgeOrg/et_c32.png',
		"tc33" = 'Mapping/EdgeOrg/et_c33.png',
		"ts00" = 'Mapping/EdgeOrg/et_s00.png',
		"ts01" = 'Mapping/EdgeOrg/et_s01.png',
		"ts02" = 'Mapping/EdgeOrg/et_s02.png',
		"ts03" = 'Mapping/EdgeOrg/et_s03.png',
		"ts10" = 'Mapping/EdgeOrg/et_s10.png',
		"ts11" = 'Mapping/EdgeOrg/et_s11.png',
		"ts12" = 'Mapping/EdgeOrg/et_s12.png',
		"ts13" = 'Mapping/EdgeOrg/et_s13.png',
		"ts20" = 'Mapping/EdgeOrg/et_s20.png',
		"ts21" = 'Mapping/EdgeOrg/et_s21.png',
		"ts22" = 'Mapping/EdgeOrg/et_s22.png',
		"ts23" = 'Mapping/EdgeOrg/et_s23.png',
		"ts30" = 'Mapping/EdgeOrg/et_s30.png',
		"ts31" = 'Mapping/EdgeOrg/et_s31.png',
		"ts32" = 'Mapping/EdgeOrg/et_s32.png',
		"ts33" = 'Mapping/EdgeOrg/et_s33.png',
		"lw00" = 'Mapping/EdgeOrg/el_w00.png',
		"lw01" = 'Mapping/EdgeOrg/el_w01.png',
		"lw02" = 'Mapping/EdgeOrg/el_w02.png',
		"lw03" = 'Mapping/EdgeOrg/el_w03.png',
		"lw10" = 'Mapping/EdgeOrg/el_w10.png',
		"lw11" = 'Mapping/EdgeOrg/el_w11.png',
		"lw12" = 'Mapping/EdgeOrg/el_w12.png',
		"lw13" = 'Mapping/EdgeOrg/el_w13.png',
		"lw20" = 'Mapping/EdgeOrg/el_w20.png',
		"lw21" = 'Mapping/EdgeOrg/el_w21.png',
		"lw22" = 'Mapping/EdgeOrg/el_w22.png',
		"lw23" = 'Mapping/EdgeOrg/el_w23.png',
		"lw30" = 'Mapping/EdgeOrg/el_w30.png',
		"lw31" = 'Mapping/EdgeOrg/el_w31.png',
		"lw32" = 'Mapping/EdgeOrg/el_w32.png',
		"lw33" = 'Mapping/EdgeOrg/el_w33.png',
		"lc00" = 'Mapping/EdgeOrg/el_c00.png',
		"lc01" = 'Mapping/EdgeOrg/el_c01.png',
		"lc02" = 'Mapping/EdgeOrg/el_c02.png',
		"lc03" = 'Mapping/EdgeOrg/el_c03.png',
		"lc10" = 'Mapping/EdgeOrg/el_c10.png',
		"lc11" = 'Mapping/EdgeOrg/el_c11.png',
		"lc12" = 'Mapping/EdgeOrg/el_c12.png',
		"lc13" = 'Mapping/EdgeOrg/el_c13.png',
		"lc20" = 'Mapping/EdgeOrg/el_c20.png',
		"lc21" = 'Mapping/EdgeOrg/el_c21.png',
		"lc22" = 'Mapping/EdgeOrg/el_c22.png',
		"lc23" = 'Mapping/EdgeOrg/el_c23.png',
		"lc30" = 'Mapping/EdgeOrg/el_c30.png',
		"lc31" = 'Mapping/EdgeOrg/el_c31.png',
		"lc32" = 'Mapping/EdgeOrg/el_c32.png',
		"lc33" = 'Mapping/EdgeOrg/el_c33.png',
		"ls00" = 'Mapping/EdgeOrg/el_s00.png',
		"ls01" = 'Mapping/EdgeOrg/el_s01.png',
		"ls02" = 'Mapping/EdgeOrg/el_s02.png',
		"ls03" = 'Mapping/EdgeOrg/el_s03.png',
		"ls10" = 'Mapping/EdgeOrg/el_s10.png',
		"ls11" = 'Mapping/EdgeOrg/el_s11.png',
		"ls12" = 'Mapping/EdgeOrg/el_s12.png',
		"ls13" = 'Mapping/EdgeOrg/el_s13.png',
		"ls20" = 'Mapping/EdgeOrg/el_s20.png',
		"ls21" = 'Mapping/EdgeOrg/el_s21.png',
		"ls22" = 'Mapping/EdgeOrg/el_s22.png',
		"ls23" = 'Mapping/EdgeOrg/el_s23.png',
		"ls30" = 'Mapping/EdgeOrg/el_s30.png',
		"ls31" = 'Mapping/EdgeOrg/el_s31.png',
		"ls32" = 'Mapping/EdgeOrg/el_s32.png',
		"ls33" = 'Mapping/EdgeOrg/el_s33.png')
	elevOrgShade = list(
		"w" = list(
			'Mapping/EdgeOrg/es_w_0.png',
			'Mapping/EdgeOrg/es_w_1.png',
			'Mapping/EdgeOrg/es_w_2.png',
			'Mapping/EdgeOrg/es_w_3.png',
			'Mapping/EdgeOrg/es_w_4.png',
			'Mapping/EdgeOrg/es_w_5.png',
			'Mapping/EdgeOrg/es_w_6.png',
			'Mapping/EdgeOrg/es_w_7.png',
			'Mapping/EdgeOrg/es_w_8.png',
			'Mapping/EdgeOrg/es_w_9.png',
			'Mapping/EdgeOrg/es_w_10.png',
			'Mapping/EdgeOrg/es_w_11.png',
			'Mapping/EdgeOrg/es_w_12.png',
			'Mapping/EdgeOrg/es_w_13.png',
			'Mapping/EdgeOrg/es_w_14.png',
			'Mapping/EdgeOrg/es_w_15.png',
			'Mapping/EdgeOrg/es_w_16.png',
			'Mapping/EdgeOrg/es_w_17.png',
			'Mapping/EdgeOrg/es_w_18.png',
			'Mapping/EdgeOrg/es_w_19.png',
			'Mapping/EdgeOrg/es_w_20.png',
			'Mapping/EdgeOrg/es_w_21.png',
			'Mapping/EdgeOrg/es_w_22.png',
			'Mapping/EdgeOrg/es_w_23.png',
			'Mapping/EdgeOrg/es_w_24.png',
			'Mapping/EdgeOrg/es_w_25.png',
			'Mapping/EdgeOrg/es_w_26.png',
			'Mapping/EdgeOrg/es_w_27.png',
			'Mapping/EdgeOrg/es_w_28.png',
			'Mapping/EdgeOrg/es_w_29.png',
			'Mapping/EdgeOrg/es_w_30.png',
			'Mapping/EdgeOrg/es_w_31.png',
			'Mapping/EdgeOrg/es_w_32.png',
			'Mapping/EdgeOrg/es_w_33.png',
			'Mapping/EdgeOrg/es_w_34.png',
			'Mapping/EdgeOrg/es_w_35.png',
			'Mapping/EdgeOrg/es_w_36.png',
			'Mapping/EdgeOrg/es_w_37.png',
			'Mapping/EdgeOrg/es_w_38.png',
			'Mapping/EdgeOrg/es_w_39.png',
			'Mapping/EdgeOrg/es_w_40.png',
			'Mapping/EdgeOrg/es_w_41.png',
			'Mapping/EdgeOrg/es_w_42.png',
			'Mapping/EdgeOrg/es_w_43.png',
			'Mapping/EdgeOrg/es_w_44.png',
			'Mapping/EdgeOrg/es_w_45.png'),
		"c" = list(
			'Mapping/EdgeOrg/es_c_0.png',
			'Mapping/EdgeOrg/es_c_1.png',
			'Mapping/EdgeOrg/es_c_2.png',
			'Mapping/EdgeOrg/es_c_3.png',
			'Mapping/EdgeOrg/es_c_4.png',
			'Mapping/EdgeOrg/es_c_5.png',
			'Mapping/EdgeOrg/es_c_6.png',
			'Mapping/EdgeOrg/es_c_7.png',
			'Mapping/EdgeOrg/es_c_8.png',
			'Mapping/EdgeOrg/es_c_9.png',
			'Mapping/EdgeOrg/es_c_10.png',
			'Mapping/EdgeOrg/es_c_11.png',
			'Mapping/EdgeOrg/es_c_12.png',
			'Mapping/EdgeOrg/es_c_13.png',
			'Mapping/EdgeOrg/es_c_14.png',
			'Mapping/EdgeOrg/es_c_15.png',
			'Mapping/EdgeOrg/es_c_16.png',
			'Mapping/EdgeOrg/es_c_17.png',
			'Mapping/EdgeOrg/es_c_18.png',
			'Mapping/EdgeOrg/es_c_19.png',
			'Mapping/EdgeOrg/es_c_20.png',
			'Mapping/EdgeOrg/es_c_21.png',
			'Mapping/EdgeOrg/es_c_22.png',
			'Mapping/EdgeOrg/es_c_23.png',
			'Mapping/EdgeOrg/es_c_24.png',
			'Mapping/EdgeOrg/es_c_25.png',
			'Mapping/EdgeOrg/es_c_26.png',
			'Mapping/EdgeOrg/es_c_27.png',
			'Mapping/EdgeOrg/es_c_28.png',
			'Mapping/EdgeOrg/es_c_29.png',
			'Mapping/EdgeOrg/es_c_30.png',
			'Mapping/EdgeOrg/es_c_31.png',
			'Mapping/EdgeOrg/es_c_32.png',
			'Mapping/EdgeOrg/es_c_33.png',
			'Mapping/EdgeOrg/es_c_34.png',
			'Mapping/EdgeOrg/es_c_35.png',
			'Mapping/EdgeOrg/es_c_36.png',
			'Mapping/EdgeOrg/es_c_37.png',
			'Mapping/EdgeOrg/es_c_38.png',
			'Mapping/EdgeOrg/es_c_39.png',
			'Mapping/EdgeOrg/es_c_40.png',
			'Mapping/EdgeOrg/es_c_41.png',
			'Mapping/EdgeOrg/es_c_42.png',
			'Mapping/EdgeOrg/es_c_43.png',
			'Mapping/EdgeOrg/es_c_44.png',
			'Mapping/EdgeOrg/es_c_45.png'),
		"s" = list(
			'Mapping/EdgeOrg/es_s_0.png',
			'Mapping/EdgeOrg/es_s_1.png',
			'Mapping/EdgeOrg/es_s_2.png',
			'Mapping/EdgeOrg/es_s_3.png',
			'Mapping/EdgeOrg/es_s_4.png',
			'Mapping/EdgeOrg/es_s_5.png',
			'Mapping/EdgeOrg/es_s_6.png',
			'Mapping/EdgeOrg/es_s_7.png',
			'Mapping/EdgeOrg/es_s_8.png',
			'Mapping/EdgeOrg/es_s_9.png',
			'Mapping/EdgeOrg/es_s_10.png',
			'Mapping/EdgeOrg/es_s_11.png',
			'Mapping/EdgeOrg/es_s_12.png',
			'Mapping/EdgeOrg/es_s_13.png',
			'Mapping/EdgeOrg/es_s_14.png',
			'Mapping/EdgeOrg/es_s_15.png',
			'Mapping/EdgeOrg/es_s_16.png',
			'Mapping/EdgeOrg/es_s_17.png',
			'Mapping/EdgeOrg/es_s_18.png',
			'Mapping/EdgeOrg/es_s_19.png',
			'Mapping/EdgeOrg/es_s_20.png',
			'Mapping/EdgeOrg/es_s_21.png',
			'Mapping/EdgeOrg/es_s_22.png',
			'Mapping/EdgeOrg/es_s_23.png',
			'Mapping/EdgeOrg/es_s_24.png',
			'Mapping/EdgeOrg/es_s_25.png',
			'Mapping/EdgeOrg/es_s_26.png',
			'Mapping/EdgeOrg/es_s_27.png',
			'Mapping/EdgeOrg/es_s_28.png',
			'Mapping/EdgeOrg/es_s_29.png',
			'Mapping/EdgeOrg/es_s_30.png',
			'Mapping/EdgeOrg/es_s_31.png',
			'Mapping/EdgeOrg/es_s_32.png',
			'Mapping/EdgeOrg/es_s_33.png',
			'Mapping/EdgeOrg/es_s_34.png',
			'Mapping/EdgeOrg/es_s_35.png',
			'Mapping/EdgeOrg/es_s_36.png',
			'Mapping/EdgeOrg/es_s_37.png',
			'Mapping/EdgeOrg/es_s_38.png',
			'Mapping/EdgeOrg/es_s_39.png',
			'Mapping/EdgeOrg/es_s_40.png',
			'Mapping/EdgeOrg/es_s_41.png',
			'Mapping/EdgeOrg/es_s_42.png',
			'Mapping/EdgeOrg/es_s_43.png',
			'Mapping/EdgeOrg/es_s_44.png',
			'Mapping/EdgeOrg/es_s_45.png'))
	elevOrgDark = list(
		"w" = list(
			'Mapping/EdgeOrg/ed_w_0.png',
			'Mapping/EdgeOrg/ed_w_1.png',
			'Mapping/EdgeOrg/ed_w_2.png',
			'Mapping/EdgeOrg/ed_w_3.png',
			'Mapping/EdgeOrg/ed_w_4.png',
			'Mapping/EdgeOrg/ed_w_5.png',
			'Mapping/EdgeOrg/ed_w_6.png',
			'Mapping/EdgeOrg/ed_w_7.png',
			'Mapping/EdgeOrg/ed_w_8.png',
			'Mapping/EdgeOrg/ed_w_9.png',
			'Mapping/EdgeOrg/ed_w_10.png',
			'Mapping/EdgeOrg/ed_w_11.png',
			'Mapping/EdgeOrg/ed_w_12.png',
			'Mapping/EdgeOrg/ed_w_13.png',
			'Mapping/EdgeOrg/ed_w_14.png',
			'Mapping/EdgeOrg/ed_w_15.png',
			'Mapping/EdgeOrg/ed_w_16.png',
			'Mapping/EdgeOrg/ed_w_17.png',
			'Mapping/EdgeOrg/ed_w_18.png',
			'Mapping/EdgeOrg/ed_w_19.png',
			'Mapping/EdgeOrg/ed_w_20.png',
			'Mapping/EdgeOrg/ed_w_21.png',
			'Mapping/EdgeOrg/ed_w_22.png',
			'Mapping/EdgeOrg/ed_w_23.png',
			'Mapping/EdgeOrg/ed_w_24.png',
			'Mapping/EdgeOrg/ed_w_25.png',
			'Mapping/EdgeOrg/ed_w_26.png',
			'Mapping/EdgeOrg/ed_w_27.png',
			'Mapping/EdgeOrg/ed_w_28.png',
			'Mapping/EdgeOrg/ed_w_29.png',
			'Mapping/EdgeOrg/ed_w_30.png',
			'Mapping/EdgeOrg/ed_w_31.png',
			'Mapping/EdgeOrg/ed_w_32.png',
			'Mapping/EdgeOrg/ed_w_33.png',
			'Mapping/EdgeOrg/ed_w_34.png',
			'Mapping/EdgeOrg/ed_w_35.png',
			'Mapping/EdgeOrg/ed_w_36.png',
			'Mapping/EdgeOrg/ed_w_37.png',
			'Mapping/EdgeOrg/ed_w_38.png',
			'Mapping/EdgeOrg/ed_w_39.png',
			'Mapping/EdgeOrg/ed_w_40.png',
			'Mapping/EdgeOrg/ed_w_41.png',
			'Mapping/EdgeOrg/ed_w_42.png',
			'Mapping/EdgeOrg/ed_w_43.png',
			'Mapping/EdgeOrg/ed_w_44.png',
			'Mapping/EdgeOrg/ed_w_45.png',
			'Mapping/EdgeOrg/ed_w_46.png',
			'Mapping/EdgeOrg/ed_w_47.png',
			'Mapping/EdgeOrg/ed_w_48.png',
			'Mapping/EdgeOrg/ed_w_49.png',
			'Mapping/EdgeOrg/ed_w_50.png',
			'Mapping/EdgeOrg/ed_w_51.png',
			'Mapping/EdgeOrg/ed_w_52.png',
			'Mapping/EdgeOrg/ed_w_53.png',
			'Mapping/EdgeOrg/ed_w_54.png',
			'Mapping/EdgeOrg/ed_w_55.png',
			'Mapping/EdgeOrg/ed_w_56.png',
			'Mapping/EdgeOrg/ed_w_57.png',
			'Mapping/EdgeOrg/ed_w_58.png',
			'Mapping/EdgeOrg/ed_w_59.png',
			'Mapping/EdgeOrg/ed_w_60.png',
			'Mapping/EdgeOrg/ed_w_61.png',
			'Mapping/EdgeOrg/ed_w_62.png',
			'Mapping/EdgeOrg/ed_w_63.png',
			'Mapping/EdgeOrg/ed_w_64.png',
			'Mapping/EdgeOrg/ed_w_65.png',
			'Mapping/EdgeOrg/ed_w_66.png',
			'Mapping/EdgeOrg/ed_w_67.png',
			'Mapping/EdgeOrg/ed_w_68.png',
			'Mapping/EdgeOrg/ed_w_69.png',
			'Mapping/EdgeOrg/ed_w_70.png',
			'Mapping/EdgeOrg/ed_w_71.png',
			'Mapping/EdgeOrg/ed_w_72.png',
			'Mapping/EdgeOrg/ed_w_73.png',
			'Mapping/EdgeOrg/ed_w_74.png',
			'Mapping/EdgeOrg/ed_w_75.png',
			'Mapping/EdgeOrg/ed_w_76.png',
			'Mapping/EdgeOrg/ed_w_77.png',
			'Mapping/EdgeOrg/ed_w_78.png',
			'Mapping/EdgeOrg/ed_w_79.png',
			'Mapping/EdgeOrg/ed_w_80.png',
			'Mapping/EdgeOrg/ed_w_81.png'),
		"c" = list(
			'Mapping/EdgeOrg/ed_c_0.png',
			'Mapping/EdgeOrg/ed_c_1.png',
			'Mapping/EdgeOrg/ed_c_2.png',
			'Mapping/EdgeOrg/ed_c_3.png',
			'Mapping/EdgeOrg/ed_c_4.png',
			'Mapping/EdgeOrg/ed_c_5.png',
			'Mapping/EdgeOrg/ed_c_6.png',
			'Mapping/EdgeOrg/ed_c_7.png',
			'Mapping/EdgeOrg/ed_c_8.png',
			'Mapping/EdgeOrg/ed_c_9.png',
			'Mapping/EdgeOrg/ed_c_10.png',
			'Mapping/EdgeOrg/ed_c_11.png',
			'Mapping/EdgeOrg/ed_c_12.png',
			'Mapping/EdgeOrg/ed_c_13.png',
			'Mapping/EdgeOrg/ed_c_14.png',
			'Mapping/EdgeOrg/ed_c_15.png',
			'Mapping/EdgeOrg/ed_c_16.png',
			'Mapping/EdgeOrg/ed_c_17.png',
			'Mapping/EdgeOrg/ed_c_18.png',
			'Mapping/EdgeOrg/ed_c_19.png',
			'Mapping/EdgeOrg/ed_c_20.png',
			'Mapping/EdgeOrg/ed_c_21.png',
			'Mapping/EdgeOrg/ed_c_22.png',
			'Mapping/EdgeOrg/ed_c_23.png',
			'Mapping/EdgeOrg/ed_c_24.png',
			'Mapping/EdgeOrg/ed_c_25.png',
			'Mapping/EdgeOrg/ed_c_26.png',
			'Mapping/EdgeOrg/ed_c_27.png',
			'Mapping/EdgeOrg/ed_c_28.png',
			'Mapping/EdgeOrg/ed_c_29.png',
			'Mapping/EdgeOrg/ed_c_30.png',
			'Mapping/EdgeOrg/ed_c_31.png',
			'Mapping/EdgeOrg/ed_c_32.png',
			'Mapping/EdgeOrg/ed_c_33.png',
			'Mapping/EdgeOrg/ed_c_34.png',
			'Mapping/EdgeOrg/ed_c_35.png',
			'Mapping/EdgeOrg/ed_c_36.png',
			'Mapping/EdgeOrg/ed_c_37.png',
			'Mapping/EdgeOrg/ed_c_38.png',
			'Mapping/EdgeOrg/ed_c_39.png',
			'Mapping/EdgeOrg/ed_c_40.png',
			'Mapping/EdgeOrg/ed_c_41.png',
			'Mapping/EdgeOrg/ed_c_42.png',
			'Mapping/EdgeOrg/ed_c_43.png',
			'Mapping/EdgeOrg/ed_c_44.png',
			'Mapping/EdgeOrg/ed_c_45.png',
			'Mapping/EdgeOrg/ed_c_46.png',
			'Mapping/EdgeOrg/ed_c_47.png',
			'Mapping/EdgeOrg/ed_c_48.png',
			'Mapping/EdgeOrg/ed_c_49.png',
			'Mapping/EdgeOrg/ed_c_50.png',
			'Mapping/EdgeOrg/ed_c_51.png',
			'Mapping/EdgeOrg/ed_c_52.png',
			'Mapping/EdgeOrg/ed_c_53.png',
			'Mapping/EdgeOrg/ed_c_54.png',
			'Mapping/EdgeOrg/ed_c_55.png',
			'Mapping/EdgeOrg/ed_c_56.png',
			'Mapping/EdgeOrg/ed_c_57.png',
			'Mapping/EdgeOrg/ed_c_58.png',
			'Mapping/EdgeOrg/ed_c_59.png',
			'Mapping/EdgeOrg/ed_c_60.png',
			'Mapping/EdgeOrg/ed_c_61.png',
			'Mapping/EdgeOrg/ed_c_62.png',
			'Mapping/EdgeOrg/ed_c_63.png',
			'Mapping/EdgeOrg/ed_c_64.png',
			'Mapping/EdgeOrg/ed_c_65.png',
			'Mapping/EdgeOrg/ed_c_66.png',
			'Mapping/EdgeOrg/ed_c_67.png',
			'Mapping/EdgeOrg/ed_c_68.png',
			'Mapping/EdgeOrg/ed_c_69.png',
			'Mapping/EdgeOrg/ed_c_70.png',
			'Mapping/EdgeOrg/ed_c_71.png',
			'Mapping/EdgeOrg/ed_c_72.png',
			'Mapping/EdgeOrg/ed_c_73.png',
			'Mapping/EdgeOrg/ed_c_74.png',
			'Mapping/EdgeOrg/ed_c_75.png',
			'Mapping/EdgeOrg/ed_c_76.png',
			'Mapping/EdgeOrg/ed_c_77.png',
			'Mapping/EdgeOrg/ed_c_78.png',
			'Mapping/EdgeOrg/ed_c_79.png',
			'Mapping/EdgeOrg/ed_c_80.png',
			'Mapping/EdgeOrg/ed_c_81.png',
			'Mapping/EdgeOrg/ed_c_82.png'),
		"s" = list(
			'Mapping/EdgeOrg/ed_s_0.png',
			'Mapping/EdgeOrg/ed_s_1.png',
			'Mapping/EdgeOrg/ed_s_2.png',
			'Mapping/EdgeOrg/ed_s_3.png',
			'Mapping/EdgeOrg/ed_s_4.png',
			'Mapping/EdgeOrg/ed_s_5.png',
			'Mapping/EdgeOrg/ed_s_6.png',
			'Mapping/EdgeOrg/ed_s_7.png',
			'Mapping/EdgeOrg/ed_s_8.png',
			'Mapping/EdgeOrg/ed_s_9.png',
			'Mapping/EdgeOrg/ed_s_10.png',
			'Mapping/EdgeOrg/ed_s_11.png',
			'Mapping/EdgeOrg/ed_s_12.png',
			'Mapping/EdgeOrg/ed_s_13.png',
			'Mapping/EdgeOrg/ed_s_14.png',
			'Mapping/EdgeOrg/ed_s_15.png',
			'Mapping/EdgeOrg/ed_s_16.png',
			'Mapping/EdgeOrg/ed_s_17.png',
			'Mapping/EdgeOrg/ed_s_18.png',
			'Mapping/EdgeOrg/ed_s_19.png',
			'Mapping/EdgeOrg/ed_s_20.png',
			'Mapping/EdgeOrg/ed_s_21.png',
			'Mapping/EdgeOrg/ed_s_22.png',
			'Mapping/EdgeOrg/ed_s_23.png',
			'Mapping/EdgeOrg/ed_s_24.png',
			'Mapping/EdgeOrg/ed_s_25.png',
			'Mapping/EdgeOrg/ed_s_26.png',
			'Mapping/EdgeOrg/ed_s_27.png',
			'Mapping/EdgeOrg/ed_s_28.png',
			'Mapping/EdgeOrg/ed_s_29.png',
			'Mapping/EdgeOrg/ed_s_30.png',
			'Mapping/EdgeOrg/ed_s_31.png',
			'Mapping/EdgeOrg/ed_s_32.png',
			'Mapping/EdgeOrg/ed_s_33.png',
			'Mapping/EdgeOrg/ed_s_34.png',
			'Mapping/EdgeOrg/ed_s_35.png',
			'Mapping/EdgeOrg/ed_s_36.png',
			'Mapping/EdgeOrg/ed_s_37.png',
			'Mapping/EdgeOrg/ed_s_38.png',
			'Mapping/EdgeOrg/ed_s_39.png',
			'Mapping/EdgeOrg/ed_s_40.png',
			'Mapping/EdgeOrg/ed_s_41.png',
			'Mapping/EdgeOrg/ed_s_42.png',
			'Mapping/EdgeOrg/ed_s_43.png',
			'Mapping/EdgeOrg/ed_s_44.png',
			'Mapping/EdgeOrg/ed_s_45.png',
			'Mapping/EdgeOrg/ed_s_46.png',
			'Mapping/EdgeOrg/ed_s_47.png',
			'Mapping/EdgeOrg/ed_s_48.png',
			'Mapping/EdgeOrg/ed_s_49.png',
			'Mapping/EdgeOrg/ed_s_50.png',
			'Mapping/EdgeOrg/ed_s_51.png',
			'Mapping/EdgeOrg/ed_s_52.png',
			'Mapping/EdgeOrg/ed_s_53.png',
			'Mapping/EdgeOrg/ed_s_54.png',
			'Mapping/EdgeOrg/ed_s_55.png'))
	elevOrgKeyFiles = list("w" = 'Mapping/EdgeOrg/ek_w.txt', "c" = 'Mapping/EdgeOrg/ek_c.txt', "s" = 'Mapping/EdgeOrg/ek_s.txt')
	elevOrgIndexFiles = list(
		"m1w" = 'Mapping/EdgeOrg/ix_m1_w.txt',
		"m1c" = 'Mapping/EdgeOrg/ix_m1_c.txt',
		"m1s" = 'Mapping/EdgeOrg/ix_m1_s.txt',
		"m2w" = 'Mapping/EdgeOrg/ix_m2_w.txt',
		"m2c" = 'Mapping/EdgeOrg/ix_m2_c.txt',
		"m2s" = 'Mapping/EdgeOrg/ix_m2_s.txt',
		"mx1w" = 'Mapping/EdgeOrg/ix_mx1_w.txt',
		"mx1c" = 'Mapping/EdgeOrg/ix_mx1_c.txt',
		"mx1s" = 'Mapping/EdgeOrg/ix_mx1_s.txt',
		"mx2w" = 'Mapping/EdgeOrg/ix_mx2_w.txt',
		"mx2c" = 'Mapping/EdgeOrg/ix_mx2_c.txt',
		"mx2s" = 'Mapping/EdgeOrg/ix_mx2_s.txt',
		"k1D1w" = 'Mapping/EdgeOrg/ix_k1D1_w.txt',
		"k1D1c" = 'Mapping/EdgeOrg/ix_k1D1_c.txt',
		"k1D1s" = 'Mapping/EdgeOrg/ix_k1D1_s.txt',
		"k2D1w" = 'Mapping/EdgeOrg/ix_k2D1_w.txt',
		"k2D1c" = 'Mapping/EdgeOrg/ix_k2D1_c.txt',
		"k2D1s" = 'Mapping/EdgeOrg/ix_k2D1_s.txt',
		"nD1w" = 'Mapping/EdgeOrg/ix_nD1_w.txt',
		"nD1c" = 'Mapping/EdgeOrg/ix_nD1_c.txt',
		"nD1s" = 'Mapping/EdgeOrg/ix_nD1_s.txt',
		"k1D2w" = 'Mapping/EdgeOrg/ix_k1D2_w.txt',
		"k1D2c" = 'Mapping/EdgeOrg/ix_k1D2_c.txt',
		"k1D2s" = 'Mapping/EdgeOrg/ix_k1D2_s.txt',
		"k2D2w" = 'Mapping/EdgeOrg/ix_k2D2_w.txt',
		"k2D2c" = 'Mapping/EdgeOrg/ix_k2D2_c.txt',
		"k2D2s" = 'Mapping/EdgeOrg/ix_k2D2_s.txt',
		"k3D2w" = 'Mapping/EdgeOrg/ix_k3D2_w.txt',
		"k3D2c" = 'Mapping/EdgeOrg/ix_k3D2_c.txt',
		"k3D2s" = 'Mapping/EdgeOrg/ix_k3D2_s.txt',
		"nD2w" = 'Mapping/EdgeOrg/ix_nD2_w.txt',
		"nD2c" = 'Mapping/EdgeOrg/ix_nD2_c.txt',
		"nD2s" = 'Mapping/EdgeOrg/ix_nD2_s.txt',
		"i3w" = 'Mapping/EdgeOrg/ix_i3_w.txt',
		"i3c" = 'Mapping/EdgeOrg/ix_i3_c.txt',
		"i3s" = 'Mapping/EdgeOrg/ix_i3_s.txt',
		"ni3w" = 'Mapping/EdgeOrg/ix_ni3_w.txt',
		"ni3c" = 'Mapping/EdgeOrg/ix_ni3_c.txt',
		"ni3s" = 'Mapping/EdgeOrg/ix_ni3_s.txt')
	elevOrgClasses = list(
		"m1" = list(0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 13),
		"m2" = list(0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 13),
		"mx1" = list(0, 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 14),
		"mx2" = list(0, 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 14),
		"k1D1" = list(0, 1, 2, 3, 5, 6, 8, 9, 10, 11),
		"k2D1" = list(0, 1, 2, 3, 5, 6, 8, 9, 11),
		"nD1" = list(0, 2, 3, 5, 6, 8, 9, 10, 11),
		"k1D2" = list(0, 2, 3, 4, 5, 6, 8, 9, 11, 12, 14),
		"k2D2" = list(0, 1, 2, 3, 5, 6, 8, 9, 11, 12, 13, 14),
		"k3D2" = list(0, 1, 2, 3, 5, 6, 8, 9, 11, 12, 14),
		"nD2" = list(0, 2, 3, 5, 6, 8, 9, 11, 12, 13, 14),
		"i3" = list(0, 1, 2, 3, 5, 6, 8, 9, 11, 12, 14),
		"ni3" = list(0, 2, 3, 5, 6, 8, 9, 11, 12, 13, 14))

/proc/ElevOrgStyle(turf/S)
	if(!S || ElevAt(S) <= 0 || !ElevNaturalTop(S) || ElevStairTurf(S))
		return ""
	if(ElevFaceFlat(S, ElevFaceStyleAt(S, S)))
		return ""
	var/turf/B = locate(S.x, S.y - 1, S.z)
	if(B && ElevAt(B) <= 0 && BuildIsCliffTurf(B))
		return ""
	switch(BuildEdgeStyleFor(BuildMaterialFor(S)))
		if("wispy")
			return "w"
		if("crumbly")
			return "c"
		if("soft")
			return "s"
	return ""

/proc/ElevOrgCfg(turf/G, L)
	var/cbit = (ElevAt(G) >= L) ? 1 : 0
	var/cfg = cbit ? 256 : 0
	var/i = 0
	for(var/list/o in shoreFoamOffs)
		i++
		var/turf/O = locate(G.x + o[1], G.y + o[2], G.z)
		var/b = O ? ((ElevAt(O) >= L) ? 1 : 0) : cbit
		if(b)
			cfg |= (1 << (i - 1))
	return cfg

/proc/ElevOrgFilter(sset, sty, turf/G, cfg, inv = 0)
	ElevOrgSheetInit()
	var/F = elevOrgSheets["[sset][sty][BuildOrgWindowX(G)][BuildOrgWindowY(G)]"]
	if(!F)
		return null
	return filter(type = "alpha", icon = F, x = BuildOrgSheetX(cfg), y = BuildOrgSheetY(cfg), flags = inv ? MASK_INVERSE : 0)

/proc/ElevOrgCellFilter(list/sheets, id)
	if(!sheets || id <= 0)
		return null
	var/s = round((id - 1) / 512) + 1
	if(s > sheets.len)
		return null
	var/ci = (id - 1) % 512
	return filter(type = "alpha", icon = sheets[s], x = BuildOrgSheetX(ci), y = BuildOrgSheetY(ci))

/proc/ElevOrgMem(turf/T, L)
	return (T && ElevAt(T) >= L) ? 1 : 0

/proc/ElevOrgKey(sty, wx, wy, cfg)
	if(cfg <= 0)
		return null
	var/pk = "[sty][wx][wy]|[cfg]"
	var/list/P = elevOrgParsed[pk]
	if(P)
		return P.len ? P : null
	ElevOrgSheetInit()
	var/list/lines = elevOrgKeyLines[sty]
	if(!lines)
		var/kf = elevOrgKeyFiles[sty]
		lines = kf ? splittext(file2text(kf), "\n") : list()
		elevOrgKeyLines[sty] = lines
	var/li = (wy * 4 + wx) * 512 + cfg + 1
	var/line = (li <= lines.len) ? lines[li] : ""
	P = list()
	if(length(line) >= 33)
		var/list/parts = splittext(line, "|")
		if(parts.len >= 4 && length(parts[4]) >= 30)
			var/list/runs = list()
			var/rs = parts[1]
			for(var/i = 1, i + 10 <= length(rs), i += 11)
				var/xv = text2ascii(rs, i) - 48
				runs += xv & 31
				runs += text2ascii(rs, i + 1) - 48
				runs += text2ascii(rs, i + 2) - 48
				runs += (xv >> 5) & 1
				runs += (text2ascii(rs, i + 3) - 48) | ((text2ascii(rs, i + 4) - 48) << 6) | ((text2ascii(rs, i + 5) - 48) << 12)
				runs += (text2ascii(rs, i + 6) - 48) | ((text2ascii(rs, i + 7) - 48) << 6) | ((text2ascii(rs, i + 8) - 48) << 12)
				runs += (text2ascii(rs, i + 9) - 48) | ((text2ascii(rs, i + 10) - 48) << 6)
			var/list/deltas = list()
			var/ds = parts[2]
			for(var/i = 1, i + 3 <= length(ds), i += 4)
				deltas += text2ascii(ds, i) - 48
				deltas += text2ascii(ds, i + 1) - 48
				deltas += text2ascii(ds, i + 2) - 48
				deltas += text2ascii(ds, i + 3) - 48
			var/list/trims = list()
			var/ts = parts[3]
			for(var/i = 1, i + 3 <= length(ts), i += 4)
				trims += text2ascii(ts, i) - 48
				trims += text2ascii(ts, i + 1) - 48
				trims += text2ascii(ts, i + 2) - 48
				trims += text2ascii(ts, i + 3) - 48
			var/list/masks = list()
			var/ms = parts[4]
			for(var/m = 0 to 4)
				var/p = m * 6 + 1
				var/c0 = text2ascii(ms, p) - 48
				var/c1 = text2ascii(ms, p + 1) - 48
				var/c2 = text2ascii(ms, p + 2) - 48
				var/c3 = text2ascii(ms, p + 3) - 48
				var/c4 = text2ascii(ms, p + 4) - 48
				var/c5 = text2ascii(ms, p + 5) - 48
				masks += c0 | (c1 << 6) | ((c2 & 15) << 12)
				masks += (c2 >> 4) | (c3 << 2) | (c4 << 8) | ((c5 & 3) << 14)
			P = list(runs, deltas, masks, trims)
	elevOrgParsed[pk] = P
	return P.len ? P : null

/proc/ElevOrgBit(list/P, m, x)
	if(!P)
		return 0
	var/list/masks = P[3]
	if(x < 16)
		return (masks[m * 2 + 1] & (1 << x)) ? 1 : 0
	return (masks[m * 2 + 2] & (1 << (x - 16))) ? 1 : 0

/proc/ElevOrgKeyAt(turf/A, L, sty)
	if(!A)
		return null
	var/cfg = ElevOrgCfg(A, L)
	if(!cfg)
		return null
	return ElevOrgKey(sty, BuildOrgWindowX(A), BuildOrgWindowY(A), cfg)

/proc/ElevOrgDepthAt(turf/G, L)
	if(!G)
		return 1
	var/list/fi = ElevFaceInfo(G)
	if(fi && fi[1] == L)
		return fi[2]
	var/turf/B = locate(G.x, G.y - 1, G.z)
	if(ElevAt(G) >= L && B && ElevAt(B) < L)
		var/list/fb = ElevFaceInfo(B)
		if(fb && fb[1] == L)
			return fb[2]
		return max(1, min(ELEV_DMAX, L - ElevAt(B)))
	for(var/list/o in list(list(-1, 0), list(1, 0), list(0, 1), list(-1, 1), list(1, 1), list(-1, -1), list(1, -1)))
		var/list/nf = ElevFaceInfo(locate(G.x + o[1], G.y + o[2], G.z))
		if(nf && nf[1] == L)
			return nf[2]
	var/low = ElevAt(G)
	if(low >= L)
		for(var/list/o in elevOrgOffs)
			var/turf/O = locate(G.x + o[1], G.y + o[2], G.z)
			if(O && ElevAt(O) < low)
				low = ElevAt(O)
	return max(1, min(ELEV_DMAX, L - low))

/proc/ElevOrgGScale(k, D, kv, vD)
	var/gt = 0.5 + 0.5 * min(1, (32 * (k - 1) + 16) / (32 * D))
	var/gv = 0.5 + 0.5 * min(1, (32 * (kv - 1) + 16) / (32 * vD))
	return gt / gv

/proc/ElevOrgClassify(turf/G, L, D)
	var/k = -1
	for(var/kk = 0 to D + 1)
		if(ElevOrgMem(locate(G.x, G.y + kk, G.z), L))
			k = kk
			break
	var/cls
	var/list/rows
	var/dph = 0
	var/gs = 1
	if(k == 0)
		if(ElevOrgMem(locate(G.x, G.y - 1, G.z), L) && ElevOrgMem(locate(G.x, G.y - 2, G.z), L))
			cls = (D <= 1) ? "mx1" : "mx2"
		else
			cls = (D <= 1) ? "m1" : "m2"
		rows = list(2, 1, 0, -1, -2)
	else if(k == 1)
		if(D <= 1)
			cls = "k1D1"
			rows = list(2, 1, 0, -1)
		else
			cls = "k1D2"
			rows = list(3, 2, 1, 0, -1)
			gs = ElevOrgGScale(1, D, 1, 2)
	else if(k > 1)
		if(k == D + 1)
			if(D == 2)
				cls = "k3D2"
				rows = list(4, 3, 2, 1, 0, -1)
			else
				cls = "k2D1"
				rows = list(k + 1, k, 1, 0, -1)
				dph = k - 2
		else if(k == D)
			cls = "k2D2"
			rows = list(k + 1, k, 1, 0, -1)
			dph = k - 2
			gs = ElevOrgGScale(k, D, 2, 2)
		else
			cls = "i3"
			rows = list(k + 1, k, 1, 0, -1)
			dph = k - 2
			gs = ElevOrgGScale(k, D, 2, 3)
	else if(D <= 1)
		cls = "nD1"
		rows = list(2, 1, 0, -1)
	else if(D == 2)
		cls = "nD2"
		rows = list(3, 2, 1, 0, -1)
	else
		var/ks = -1
		for(var/kk = 0 to D + 1)
			if(ElevOrgMem(locate(G.x - 1, G.y + kk, G.z), L) || ElevOrgMem(locate(G.x + 1, G.y + kk, G.z), L))
				ks = kk
				break
		if(ks < 0)
			return null
		if(ks <= 1)
			cls = "nD2"
			rows = list(3, 2, 1, 0, -1)
			gs = ElevOrgGScale(max(ks, 1), D, max(ks, 1), 2)
		else if(ks < D)
			cls = "ni3"
			rows = list(ks + 1, ks, 1, 0, -1)
			dph = ks - 2
			gs = ElevOrgGScale(ks, D, 2, 3)
		else if(ks == D)
			cls = "nD2"
			rows = list(ks + 1, ks, 1, 0, -1)
			dph = ks - 2
			gs = ElevOrgGScale(ks, D, 2, 2)
		else
			cls = "nD2"
			rows = list(ks, 2, 1, 0, -1)
			dph = ks - 3
	ElevOrgSheetInit()
	var/list/free = elevOrgClasses[cls]
	if(!free)
		return null
	var/idx = 0
	var/any = 0
	var/bi = 0
	for(var/pos in free)
		var/rw = round(pos / 3)
		var/cl = pos % 3
		if(ElevOrgMem(locate(G.x + cl - 1, G.y + rows[rw + 1], G.z), L))
			idx |= (1 << bi)
			any = 1
		bi++
	if(!any && k < 0)
		return null
	return list(cls, idx, dph, gs, free.len)

/proc/ElevOrgCtxIds(cls, sty, w, idx, nbits)
	var/ik = "[cls][sty]"
	var/txt = elevOrgIndexText[ik]
	if(!txt)
		var/f = elevOrgIndexFiles[ik]
		if(!f)
			return null
		txt = file2text(f)
		elevOrgIndexText[ik] = txt
	var/pos = (w * (1 << nbits) + idx) * 6 + 1
	if(pos + 5 > length(txt))
		return null
	var/a = (text2ascii(txt, pos) - 48) + (text2ascii(txt, pos + 1) - 48) * 64 + (text2ascii(txt, pos + 2) - 48) * 4096
	var/b = (text2ascii(txt, pos + 3) - 48) + (text2ascii(txt, pos + 4) - 48) * 64 + (text2ascii(txt, pos + 5) - 48) * 4096
	return list(a, b)

/proc/ElevOrgSourceRun(list/K, x, atop)
	if(!K)
		return 0
	var/list/rr = K[1]
	var/best = 0
	var/bb = -1
	for(var/q = 1, q + 6 <= rr.len, q += 7)
		if(rr[q] == x && rr[q + 1] <= atop && rr[q + 1] > bb)
			bb = rr[q + 1]
			best = q
	return best

/proc/ElevOrgEdgeRun(list/K, x, top)
	if(!K)
		return 0
	var/list/rr = K[1]
	for(var/q = 1, q + 6 <= rr.len, q += 7)
		if(rr[q] != x)
			continue
		if(top ? (rr[q + 2] == 0) : (rr[q + 1] == 32))
			return q
	return 0

/proc/ElevOrgSameCliff(o1, o2, j)
	for(var/i1 = 0 to 8)
		if(!(o1 & (1 << i1)))
			continue
		var/c1 = i1 % 3
		var/r1 = round(i1 / 3)
		for(var/i2 = 0 to 8)
			if(!(o2 & (1 << i2)))
				continue
			if(abs(c1 - (i2 % 3)) + abs(r1 - (round(i2 / 3) - j)) <= 1)
				return 1
	return 0

/proc/ElevOrgConvOn(turf/A, L, sty)
	if(!A)
		return null
	if(elevOrgConvVer != elevGeomVer)
		elevOrgConvCache = list()
		elevOrgConvVer = elevGeomVer
	var/ck = "[A.x],[A.y],[A.z],[L],[sty]"
	var/list/hit = elevOrgConvCache[ck]
	if(hit)
		return hit
	var/list/on = list()
	var/list/K = ElevOrgKeyAt(A, L, sty)
	if(K)
		var/list/runs = K[1]
		var/D = 0
		for(var/i = 1, i + 6 <= runs.len, i += 7)
			var/emlo = runs[i + 4]
			var/emhi = runs[i + 5]
			if(!emlo && !emhi)
				continue
			var/x = runs[i]
			var/b = runs[i + 1]
			var/a = runs[i + 2]
			var/total = b - a
			var/up = 0
			var/atop = a
			var/rown = runs[i + 6]
			var/list/KT = K
			var/curA = a
			while(curA == 0 && total <= 48)
				var/list/KU = ElevOrgKeyAt(locate(A.x, A.y + up + 1, A.z), L, sty)
				var/uq = ElevOrgEdgeRun(KU, x, 0)
				if(!uq)
					break
				var/list/ur = KU[1]
				up++
				total += 32 - ur[uq + 2]
				curA = ur[uq + 2]
				atop = curA
				rown = ur[uq + 6]
				KT = KU
			var/dn = 0
			var/curB = b
			while(curB == 32 && total <= 48)
				var/list/KD = ElevOrgKeyAt(locate(A.x, A.y - dn - 1, A.z), L, sty)
				var/dq = ElevOrgEdgeRun(KD, x, 1)
				if(!dq)
					break
				var/list/dr = KD[1]
				dn++
				total += dr[dq + 1]
				curB = dr[dq + 1]
			if(total > 48)
				continue
			var/sown = -1
			var/sj = 0
			var/sq = ElevOrgSourceRun(KT, x, atop)
			if(sq)
				var/list/tr = KT[1]
				sown = tr[sq + 6]
			else
				if(!D)
					D = ElevOrgDepthAt(A, L)
				for(var/j = 1 to D + 1)
					var/turf/AJ = locate(A.x, A.y + up + j, A.z)
					if(!AJ)
						break
					var/list/KJ = ElevOrgKeyAt(AJ, L, sty)
					var/jq = ElevOrgSourceRun(KJ, x, 32)
					if(!jq)
						continue
					var/list/jr = KJ[1]
					if(atop + 32 * j - jr[jq + 1] <= 32 * ElevOrgDepthAt(AJ, L))
						sown = jr[jq + 6]
						sj = j
					break
			if(sown < 0 || !ElevOrgSameCliff(rown, sown, sj))
				continue
			on["r[x],[a]"] = 1
			for(var/bi = 0 to b - a - 1)
				if((bi < 16) ? (emlo & (1 << bi)) : (emhi & (1 << (bi - 16))))
					on["[x],[a + bi]"] = 1
	elevOrgConvCache[ck] = on
	return on

/proc/ElevOrgBotIcon(D, k)
	var/bk = "[D]_[k]"
	var/icon/B = elevOrgBotCache[bk]
	if(B)
		return B
	B = icon('Mapping/EdgeOrg/org_cols.dmi', "white")
	for(var/y = 0 to 31)
		var/f = min(1, (32 * (k - 1) + y + 1) / (32 * D))
		var/t = max(0, min(1, (min(f, 0.9) - 0.45) / 0.45))
		var/b = 1 - 0.28 * t * t * (3 - 2 * t)
		if(f > 0.9)
			b += (f - 0.9) / 0.1 * 0.16
		var/g = max(0, min(255, round(b * 255, 1)))
		if(g < 255)
			B.DrawBox(rgb(g, g, g), 1, 32 - y, 32, 32 - y)
	elevOrgBotCache[bk] = B
	return B

/proc/ElevOrgTexLayer(icon/F, turf/S, ic, st, bright)
	if(!S)
		return
	var/h = ElevAt(S)
	var/icon/Tx = icon(ElevTexIcon(S, h), ElevTexState(S, h), S.dir, 1)
	if(bright)
		Tx.MapColors(ELEV_KMAX, 0, 0, 0, ELEV_KMAX, 0, 0, 0, ELEV_KMAX)
	var/icon/M = icon(ic, st)
	M.MapColors(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0)
	Tx.Blend(M, ICON_MULTIPLY)
	F.Blend(Tx, ICON_OVERLAY)

/proc/ElevOrgFT(turf/A, turf/S, L, D)
	if(!A || !S || D < 1)
		return null
	ElevStatesInit()
	var/turf/F1 = locate(A.x, A.y - 1, A.z)
	var/turf/FD = locate(A.x, A.y - D, A.z)
	var/turf/BL = locate(A.x, A.y - D - 1, A.z)
	var/fsty = ElevFaceStyleFor(F1, S)
	if(fsty == "custom" || ElevStyleGeneric(fsty))
		fsty = "wall38"
	var/turf/WS = ElevWrapSrc(FD, BL)
	var/v = A.x % 3
	var/fk = "[fsty]|[D]|[v]|[S.icon]|[S.icon_state]|[S.dir]|[ElevAt(S)]|[WS ? "[WS.icon]|[WS.icon_state]|[WS.dir]|[ElevAt(WS)]|[ElevStyleCode(WS)]" : "-"]"
	var/hit = elevOrgFTCache[fk]
	if(hit)
		return hit
	var/fic = ElevFaceFile(fsty)
	if(fsty != "wall38")
		var/list/ss = elevFaceStyleStates[fsty]
		if(!ss)
			ss = ElevStateSet(fic)
			elevFaceStyleStates[fsty] = ss
		if(!ss["f[D]_1cc"])
			fic = 'Mapping/Elevation/elev_face.dmi'
	var/icon/R = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
	var/mrow = 16 * D - 1
	var/mtile = round(mrow / 32) + 1
	for(var/k = 1 to D)
		var/fst = "f[D]_[k]cc"
		if(!elevFaceStates[fst])
			continue
		var/icon/F = icon(fic, fst)
		if(k == D && WS)
			var/bkey = "[ElevStyleCode(WS)][v]cc"
			if(elevBaseStates["bm[bkey]"])
				ElevOrgTexLayer(F, WS, 'Mapping/Elevation/elev_base.dmi', "bm[bkey]", 0)
			if(elevBaseStates["bb[bkey]"])
				ElevOrgTexLayer(F, WS, 'Mapping/Elevation/elev_base.dmi', "bb[bkey]", 1)
			if(elevBaseStates["bd[bkey]"])
				F.Blend(icon('Mapping/Elevation/elev_base.dmi', "bd[bkey]"), ICON_OVERLAY)
		if(k == 1 && ElevFrays(S))
			var/drew = 0
			for(var/q = 0 to 1)
				if(elevLipStates["mv[q]otctf1"])
					ElevOrgTexLayer(F, S, 'Mapping/Elevation/elev_lip.dmi', "mv[q]otctf1", 0)
					drew = 1
			for(var/q = 0 to 1)
				if(elevLipStates["bv[q]otctf1"])
					ElevOrgTexLayer(F, S, 'Mapping/Elevation/elev_lip.dmi', "bv[q]otctf1", 1)
					drew = 1
			if(drew)
				for(var/q = 0 to 1)
					if(elevLipStates["d[q]otctf1"])
						F.Blend(icon('Mapping/Elevation/elev_lip.dmi', "d[q]otctf1"), ICON_OVERLAY)
		F.Blend(ElevOrgBotIcon(D, k), ICON_MULTIPLY)
		for(var/x = 0 to 31)
			var/icon/C = icon(F)
			C.Blend(icon('Mapping/EdgeOrg/org_cols.dmi', "[x]"), ICON_MULTIPLY)
			R.Insert(C, "k[k]x[x]")
		if(k == mtile)
			for(var/x = 0 to 31)
				var/col = F.GetPixel(x + 1, 32 - (mrow % 32))
				if(!col)
					continue
				var/icon/PX = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
				PX.DrawBox(col, x + 1, 1)
				R.Insert(PX, "m[x]")
	var/res = fcopy_rsc(R)
	elevOrgFTCache[fk] = res
	return res

/proc/ElevOrgGroundSrc(turf/G, L)
	for(var/list/o in list(list(0, -1), list(1, 0), list(-1, 0), list(0, 1), list(1, -1), list(-1, -1), list(1, 1), list(-1, 1)))
		var/turf/O = locate(G.x + o[1], G.y + o[2], G.z)
		if(O && ElevAt(O) < L)
			return O
	return null

/proc/ElevOrgTurfImage(turf/S, lay)
	var/h = ElevAt(S)
	var/image/I
	if(h > 0 && !ElevOrgStyle(S))
		I = image(ElevTexIcon(S, h), null, ElevTexState(S, h))
	else
		I = image(S.icon, null, S.icon_state)
	I.dir = S.dir
	I.layer = lay
	return I

/proc/ElevOrgLevel(turf/G, L, turf/S, list/fresh)
	var/sty = ElevOrgStyle(S)
	if(!sty)
		return
	var/mem = ElevOrgMem(G, L)
	if(mem && !ElevOrgStyle(G))
		return
	ElevOrgSheetInit()
	var/cfg = ElevOrgCfg(G, L)
	var/list/K = cfg ? ElevOrgKey(sty, BuildOrgWindowX(G), BuildOrgWindowY(G), cfg) : null
	var/D = ElevOrgDepthAt(G, L)
	var/base = ElevLayer(L, 0)
	if(mem && K && cfg != 511)
		var/turf/GS = ElevOrgGroundSrc(G, L)
		var/GF = ElevOrgFilter("t", sty, G, cfg, 1)
		if(GS && GF)
			var/image/GI = ElevOrgTurfImage(GS, ELEV_TOP_LAYER)
			GI.filters = GF
			fresh += GI
	var/list/cl = ElevOrgClassify(G, L, D)
	var/list/ids = null
	if(cl)
		var/w = ((BuildOrgWindowY(G) - cl[3] + 40) % 4) * 4 + BuildOrgWindowX(G)
		ids = ElevOrgCtxIds(cl[1], sty, w, cl[2], cl[5])
	if(ids && ids[1])
		var/SF = ElevOrgCellFilter(elevOrgShade[sty], ids[1])
		if(SF)
			var/image/SI = image('Mapping/EdgeOrg/black.png')
			SI.layer = base + 0.0001
			SI.filters = SF
			fresh += SI
	var/slay = base + 0.0002 + (world.maxy - G.y) * (0.0007 / max(1, world.maxy))
	var/list/lim = new/list(32)
	for(var/i = 1 to 32)
		lim[i] = 31
	var/open = 32
	var/list/pieces = list()
	for(var/j = 0 to min(ELEV_DMAX, D + 1))
		if(open <= 0)
			break
		var/turf/A = locate(G.x, G.y + j, G.z)
		if(!A)
			break
		var/cfgA = (j == 0) ? cfg : ElevOrgCfg(A, L)
		if(!cfgA)
			continue
		if(cfgA == 511)
			break
		var/list/KA = (j == 0) ? K : ElevOrgKey(sty, BuildOrgWindowX(A), BuildOrgWindowY(A), cfgA)
		if(!KA)
			continue
		var/DA = ElevOrgDepthAt(A, L)
		var/list/runs = KA[1]
		var/FT = null
		for(var/i = runs.len - 6, i >= 1, i -= 7)
			var/x = runs[i]
			if(lim[x + 1] < 0)
				continue
			var/bp = runs[i + 1] - 32 * j
			var/lo = max(bp, 0)
			var/hi = min(lim[x + 1], bp + 32 * DA - 1)
			if(!runs[i + 3] && lo <= hi)
				for(var/t = 1 to DA)
					var/y0 = bp + 32 * (t - 1)
					if(y0 + 31 < lo || y0 > hi)
						continue
					if(!FT)
						FT = ElevOrgFT(A, S, L, DA)
					if(FT)
						pieces += list(list(FT, x, y0, t))
			var/na = runs[i + 2] - 32 * j - 1
			if(na < lim[x + 1])
				lim[x + 1] = na
				if(na < 0)
					open--
	for(var/pi = pieces.len, pi >= 1, pi--)
		var/list/PC = pieces[pi]
		var/image/SP = image(PC[1], null, "k[PC[4]]x[PC[2]]")
		SP.layer = slay
		SP.pixel_y = -PC[3]
		fresh += SP
	if(!K)
		if(ids && ids[2])
			ElevOrgDarkPiece(sty, ids[2], cl[4], base, fresh)
		return
	var/list/on = ElevOrgConvOn(G, L, sty)
	var/list/holes = list()
	var/list/trims = K[4]
	for(var/i = 1, i + 3 <= trims.len, i += 4)
		if(on && on["r[trims[i + 2]],[trims[i + 3]]"])
			holes["[trims[i]],[trims[i + 1]]"] = 1
	if(cfg != 511)
		var/TF = ElevOrgFilter("t", sty, G, cfg)
		if(TF)
			var/image/TP = ElevOrgTurfImage(mem ? G : S, ElevLayer(L, 5))
			TP.filters = TF
			for(var/hk in holes)
				var/hc = findtext(hk, ",")
				var/hx = text2num(copytext(hk, 1, hc))
				var/hy = text2num(copytext(hk, hc + 1))
				TP.filters += filter(type = "alpha", icon = ElevMaskIcon('Mapping/EdgeOrg/org_cols.dmi', "lippx"), x = hx, y = 31 - hy, flags = MASK_INVERSE)
				if(mem)
					var/turf/HS = ElevOrgGroundSrc(G, L)
					if(HS)
						var/image/HG = ElevOrgTurfImage(HS, ELEV_TOP_LAYER)
						HG.filters = filter(type = "alpha", icon = ElevMaskIcon('Mapping/EdgeOrg/org_cols.dmi', "lippx"), x = hx, y = 31 - hy)
						fresh += HG
			fresh += TP
	if(cfg != 511)
		var/LF = ElevOrgFilter("l", sty, G, cfg)
		if(LF)
			var/image/LI = image('Mapping/EdgeOrg/org_cols.dmi', null, "lip")
			LI.layer = ElevLayer(L, 6)
			LI.alpha = 150
			LI.filters = LF
			for(var/hk in holes)
				var/hc = findtext(hk, ",")
				LI.filters += filter(type = "alpha", icon = ElevMaskIcon('Mapping/EdgeOrg/org_cols.dmi', "lippx"), x = text2num(copytext(hk, 1, hc)), y = 31 - text2num(copytext(hk, hc + 1)), flags = MASK_INVERSE)
			fresh += LI
	var/list/lipset = list()
	var/list/deltas = K[2]
	for(var/i = 1, i + 3 <= deltas.len, i += 4)
		if(on && on["r[deltas[i + 2]],[deltas[i + 3]]"])
			lipset["[deltas[i]],[deltas[i + 1]]"] = 1
	for(var/side = 1 to 4)
		var/turf/NB
		switch(side)
			if(1)
				NB = locate(G.x, G.y + 1, G.z)
			if(2)
				NB = locate(G.x, G.y - 1, G.z)
			if(3)
				NB = locate(G.x - 1, G.y, G.z)
			if(4)
				NB = locate(G.x + 1, G.y, G.z)
		var/list/non = ElevOrgConvOn(NB, L, sty)
		if(!non || !non.len)
			continue
		for(var/pk in non)
			if(text2ascii(pk, 1) == 114)
				continue
			var/cp = findtext(pk, ",")
			var/px = text2num(copytext(pk, 1, cp))
			var/py = text2num(copytext(pk, cp + 1))
			switch(side)
				if(1)
					if(py == 31 && ElevOrgBit(K, 1, px))
						lipset["[px],0"] = 1
				if(2)
					if(py == 0 && ElevOrgBit(K, 2, px))
						lipset["[px],31"] = 1
				if(3)
					if(px == 31 && ElevOrgBit(K, 3, py))
						lipset["0,[py]"] = 1
				if(4)
					if(px == 0 && ElevOrgBit(K, 4, py))
						lipset["31,[py]"] = 1
	for(var/pk in lipset)
		if(on && on[pk])
			continue
		var/cp = findtext(pk, ",")
		var/image/LP = image('Mapping/EdgeOrg/org_cols.dmi', null, "lippx")
		LP.layer = ElevLayer(L, 6)
		LP.alpha = 150
		LP.pixel_x = text2num(copytext(pk, 1, cp))
		LP.pixel_y = 31 - text2num(copytext(pk, cp + 1))
		fresh += LP
	if(on && on.len)
		var/FTG = ElevOrgFT(G, S, L, D)
		if(FTG)
			for(var/pk in on)
				if(text2ascii(pk, 1) == 114 || holes[pk])
					continue
				var/cp = findtext(pk, ",")
				var/px = text2num(copytext(pk, 1, cp))
				var/image/CPX = image(FTG, null, "m[px]")
				CPX.layer = ElevLayer(L, 7)
				CPX.pixel_y = 31 - text2num(copytext(pk, cp + 1))
				fresh += CPX
	if(ids && ids[2])
		ElevOrgDarkPiece(sty, ids[2], cl[4], base, fresh)

/proc/ElevOrgDarkPiece(sty, id, gs, base, list/fresh)
	var/DF = ElevOrgCellFilter(elevOrgDark[sty], id)
	if(!DF)
		return
	var/image/DI = image('Mapping/EdgeOrg/black.png')
	DI.layer = base + 0.004
	DI.alpha = max(0, min(255, round(51 * gs, 1)))
	DI.filters = DF
	fresh += DI

/proc/ElevOrgBuild(turf/G, list/fresh)
	var/hg = ElevAt(G)
	var/list/levels = list()
	if(hg > 0 && ElevOrgStyle(G))
		levels["[hg]"] = G
	for(var/list/o in elevOrgOffs)
		var/turf/O = locate(G.x + o[1], G.y + o[2], G.z)
		if(!O)
			continue
		var/ho = ElevAt(O)
		if(ho <= hg || levels["[ho]"] || !ElevOrgStyle(O))
			continue
		levels["[ho]"] = O
	for(var/list/o in list(list(0, 0), list(0, 1), list(-1, 0), list(1, 0), list(-1, 1), list(1, 1)))
		var/list/fi = ElevFaceInfo(locate(G.x + o[1], G.y + o[2], G.z))
		if(!fi)
			continue
		var/turf/CT = fi[6]
		if(!CT || ElevAt(CT) <= hg || levels["[ElevAt(CT)]"] || !ElevOrgStyle(CT))
			continue
		levels["[ElevAt(CT)]"] = CT
	for(var/lk in levels)
		ElevOrgLevel(G, text2num(lk), levels[lk], fresh)

/proc/ElevBelowFoot(turf/T)
	if(!T)
		return 0
	var/list/af = ElevFaceInfo(locate(T.x, T.y + 1, T.z))
	return (af && af[3] == af[2]) ? 1 : 0

/proc/ElevInnerCorner(turf/T)
	if(!T || ElevFaceInfo(T))
		return 0
	for(var/side in list("R", "L"))
		var/turf/NB = locate(T.x + ((side == "R") ? 1 : -1), T.y, T.z)
		var/list/nf = ElevFaceInfo(NB)
		if(!nf || nf[(side == "R") ? 4 : 5] != "x")
			continue
		if(!ElevFaceFlat(nf[6], ElevFaceStyleFor(NB, nf[6])))
			return 1
	return 0

/proc/ElevAddUnder(turf/T, list/fresh)
	var/turf/N = locate(T.x, T.y + 1, T.z)
	if(!N)
		return
	var/list/ft = ElevFaceInfo(T)
	var/list/fn = ElevFaceInfo(N)
	var/tw = (BuildMaterialFor(T) == "Water")
	var/pit = (tw || ft) ? 0 : ElevIsPit(T)
	if(fn && fn[3] == fn[2])
		var/turf/WS = ElevWrapSrc(N, T)
		var/ww = (BuildMaterialFor(WS) == "Water")
		var/ukey = "[ElevStyleCode(WS)][N.x % 3][ElevWrapEnd(N, fn, -1)][ElevWrapEnd(N, fn, 1)]"
		if(ww)
			if(tw && !ElevInnerCorner(T))
				ElevFoamTrio("x", ukey, T, ELEV_FOAM_LAYER, fresh)
		else if(!pit && elevBaseStates["bu[ukey]"] && !ElevOrgStyle(fn[6]))
			fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "bu[ukey]", ElevLayer(fn[1], 4))
		return
	if(ft)
		return
	for(var/side in list("R", "L"))
		var/turf/NB = locate(N.x + (side == "R" ? 1 : -1), N.y, N.z)
		var/list/nf = ElevFaceInfo(NB)
		if(!nf || nf[(side == "R") ? 4 : 5] != "x" || nf[3] != nf[2])
			continue
		if(ElevFaceFlat(nf[6], ElevFaceStyleFor(NB, nf[6])))
			continue
		var/turf/WS2 = ElevWrapSrc(N, T)
		var/ww2 = (BuildMaterialFor(WS2) == "Water")
		var/tkey = "[ElevStyleCode(WS2)][N.x % 3][side]"
		if(ww2)
			if(tw)
				ElevFoamTrio("y", tkey, T, ELEV_FOAM_LAYER, fresh)
		else if(!pit && elevBaseStates["tu[tkey]"] && !ElevOrgStyle(nf[6]))
			fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "tu[tkey]", ElevLayer(nf[1], 4))

/proc/ElevAddPit(turf/G, gh, list/fresh)
	if(BuildMaterialFor(G) == "Water" || !ElevIsPit(G) || ElevFaceInfo(G))
		return
	for(var/q = 0 to 3)
		var/dx = (q == 1 || q == 3) ? 1 : -1
		var/dy = (q < 2) ? 1 : -1
		var/V = ElevPitClass(locate(G.x, G.y + dy, G.z), gh)
		var/H = ElevPitClass(locate(G.x + dx, G.y, G.z), gh)
		var/D = ElevPitClass(locate(G.x + dx, G.y + dy, G.z), gh)
		var/extra = "-"
		if(V == "f" && q < 2)
			extra = "[ElevStyleCode(ElevWrapSrc(locate(G.x, G.y + 1, G.z), G))][G.x % 3]"
		else if(H == "f" && q >= 2)
			extra = "[ElevStyleCode(ElevWrapSrc(locate(G.x + dx, G.y, G.z), locate(G.x + dx, G.y - 1, G.z)))][(G.x + dx) % 3]"
		var/pst = "pd[q][V][H][D][extra]"
		if(elevPitStates[pst])
			fresh += ElevPlain('Mapping/Elevation/elev_pit.dmi', pst, ElevLayer(min(gh + 1, ELEV_MAX), 4))

/proc/ElevVisualUpdate(turf/T)
	if(!T)
		return
	if(T.elevOverlays)
		T.overlays -= T.elevOverlays
		T.elevOverlays = null
	ElevMapLoad()
	ElevStatesInit()
	var/list/fresh = list()
	var/h = ElevAt(T)
	if(h > 0)
		if(!ElevOrgStyle(T))
			var/image/TI = image(ElevTexIcon(T, h), null, "")
			TI.dir = T.dir
			TI.layer = ELEV_TOP_LAYER
			fresh += TI
		if(!ElevNaturalTop(T))
			for(var/side in list("W", "E"))
				var/turf/SN = locate(T.x + ((side == "W") ? -1 : 1), T.y, T.z)
				if(SN && ElevAt(SN) < h)
					var/image/EP = ElevShadePiece("fe[side]", ELEV_TOP_LAYER + 0.001)
					if(EP)
						fresh += EP
	ElevAddFaceParts(T, fresh)
	ElevAddUnder(T, fresh)
	ElevAddPit(T, h, fresh)
	ElevAddLips(T, h, fresh)
	ElevOrgBuild(T, fresh)
	if(!fresh.len)
		return
	T.overlays += fresh
	T.elevOverlays = fresh

mob/Mapper/verb/Elev_Debug()
	set category = "Mapper"
	var/turf/T = usr.loc
	if(!isturf(T))
		usr << "Stand on a tile first."
		return
	ElevMapLoad()
	ElevStatesInit()
	var/h = ElevAt(T)
	usr << "ELEV DEBUG @ ([T.x],[T.y],[T.z]) - height [h], [elevMap.len] raised tiles on record. Piece library: face [elevFaceStates.len], lip [elevLipStates.len], base [elevBaseStates.len], pit [elevPitStates.len], foam [elevFoamStates.len]."
	var/turf/CV = ElevCoverOf(T)
	usr << "  covered by: [CV ? "([CV.x],[CV.y]) at level [ElevAt(CV)]" : "nothing"]. material [BuildMaterialFor(T)], cliff turf [BuildIsCliffTurf(T)], pit [ElevIsPit(T)]"
	if(h > 0)
		var/osty = ElevOrgStyle(T)
		usr << "  organic rim: [osty ? "yes (style [osty], config [ElevOrgCfg(T, h)], window [BuildOrgWindowX(T)],[BuildOrgWindowY(T)], depth [ElevOrgDepthAt(T, h)])" : "no (flat top, stairs or custom wall art - square rim)"]"
	if(ElevStairsAt(T))
		usr << "  stairs: [ElevStairTurf(T) ? "stairs turf - no face drawn here, walkable between heights, repaint never raises it" : "stairs object - walkable between heights"]"
	var/list/fi = ElevFaceInfo(T)
	if(fi)
		var/fst = "f[fi[2]]_[fi[3]][ElevFaceEnd(fi[4])][ElevFaceEnd(fi[5])]"
		var/fsty = ElevFaceStyleFor(T, fi[6])
		var/flat = ElevFaceFlat(fi[6], fsty)
		var/list/fart = flat ? ElevFlatArt(fsty) : null
		var/image/FP = (fsty == "custom") ? ElevShadePiece("fs[fi[2]]_[fi[3]][ElevFaceEnd(fi[4])][ElevFaceEnd(fi[5])]", 0) : (flat ? (fart ? ElevPlain(fart[1], fart[2], 0) : null) : ElevFacePiece(fsty, fst, 0))
		usr << "  face: top [fi[1]], [fi[2]] rows, this is row [fi[3]], ends [fi[4]]/[fi[5]], wrap ends [ElevWrapEnd(T, fi, -1)]/[ElevWrapEnd(T, fi, 1)], style [fsty], state [fst] [flat ? (FP ? "OK (flat wall art plus bottom shade - [BuildMaterialFor(fi[6]) ? "[BuildMaterialFor(fi[6])]" : "unflagged"] tops use flat walls)" : "MISSING (wall art not found here, default rock used)") : (FP ? (("[FP.icon]" == "[ElevFaceFile(fsty)]") ? "OK" : "OK (default rock, style file lacks it)") : "MISSING")]"
	var/gcov = CV ? 1 : 0
	elevWallCtxL = gcov ? ElevWallCtxFor(T) : 0
	if(elevWallCtxL)
		usr << "  manual cliff column, [elevWallCtxL] rows: the tile above counts as its top for the rim drape."
	for(var/L = max(1, h), L <= ELEV_MAX, L++)
		if(gcov && h == L)
			continue
		for(var/q = 0 to 3)
			var/list/srcs = list()
			var/key = ElevLipKey(T, h, L, q, srcs, elevWallCtxL ? ElevEdgeSide(T) : 0)
			if(!key)
				continue
			var/rep = ""
			for(var/sn in elevLipSlots)
				if(!srcs[sn])
					continue
				rep += " m[sn]:[elevLipStates["m[sn][key]"] ? "ok" : "MISSING"]"
			if(h == L)
				rep += " bg:[elevLipStates["bg[key]"] ? "ok" : "none"]"
			rep += " d:[elevLipStates["d[key]"] ? "ok" : "none"]"
			usr << "  lip L[L] q[q] [key]:[rep]"
	elevWallCtxL = 0
	usr << "  elevation overlays on this tile: [T.elevOverlays ? T.elevOverlays.len : 0]"
