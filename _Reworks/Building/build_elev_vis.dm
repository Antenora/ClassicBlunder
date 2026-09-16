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
				if(!S || !ElevFrays(S))
					continue
				if(elevLipStates["m[sn][key]"])
					fresh += ElevTexPiece(S, 'Mapping/Elevation/elev_lip.dmi', "m[sn][key]", ElevLayer(L, 6), 0)
					drew = 1
				if(elevLipStates["b[sn][key]"])
					fresh += ElevTexPiece(S, 'Mapping/Elevation/elev_lip.dmi', "b[sn][key]", ElevLayer(L, 7), 1)
					drew = 1
			if(gh == L && ElevFrays(G) && elevLipStates["bg[key]"])
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
		var/image/FP
		if(fsty == "custom")
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
		if(!flat)
			ElevAddLipPosts(T, fi, fsty, fst, fresh)
		if(fi[3] == fi[2])
			var/turf/S = locate(T.x, T.y - 1, T.z)
			if(S)
				var/turf/WS = ElevWrapSrc(T, S)
				var/bkey = "[ElevStyleCode(WS)][T.x % 3][ElevWrapEnd(T, fi, -1)][ElevWrapEnd(T, fi, 1)]"
				if(elevBaseStates["bm[bkey]"])
					fresh += ElevTexPiece(WS, 'Mapping/Elevation/elev_base.dmi', "bm[bkey]", ElevLayer(top, 2), 0)
				if(elevBaseStates["bb[bkey]"])
					fresh += ElevTexPiece(WS, 'Mapping/Elevation/elev_base.dmi', "bb[bkey]", ElevLayer(top, 3), 1)
				if(elevBaseStates["bd[bkey]"])
					fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "bd[bkey]", ElevLayer(top, 4))
				if(copytext(bkey, 1, 2) == "a")
					ElevFoamTrio("b", bkey, WS, ElevLayer(top, 9), fresh)
	for(var/side in list("R", "L"))
		var/turf/NB = locate(T.x + (side == "R" ? 1 : -1), T.y, T.z)
		var/list/nf = ElevFaceInfo(NB)
		if(!nf || nf[(side == "R") ? 4 : 5] != "x")
			continue
		var/nsty = ElevFaceStyleFor(NB, nf[6])
		if(ElevFaceFlat(nf[6], nsty))
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
				ElevFoamTrio((nf[3] == 1) ? "k" : "m", "a[T.x % 3][side]", T, ElevLayer(ntop, 9), fresh)
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
			ElevFoamTrio((nf[2] == 1) ? "t" : "s", tkey, WS2, ElevLayer(ntop, 9), fresh)
	for(var/side in list("R", "L"))
		var/turf/DF = locate(T.x + (side == "R" ? 1 : -1), T.y - 1, T.z)
		var/list/df = ElevFaceInfo(DF)
		if(!df || df[3] != 1 || df[(side == "R") ? 4 : 5] != "x" || ElevAt(df[6]) <= 0)
			continue
		var/dsty = ElevFaceStyleFor(DF, df[6])
		if(ElevFaceFlat(df[6], dsty))
			continue
		var/image/WP = ElevFacePiece(dsty, "u[df[2]][side]", ElevLayer(df[1], 0))
		if(WP)
			fresh += WP

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
			if(tw)
				ElevFoamTrio("x", ukey, T, ELEV_FOAM_LAYER, fresh)
		else if(!pit && elevBaseStates["bu[ukey]"])
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
		else if(!pit && elevBaseStates["tu[tkey]"])
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
