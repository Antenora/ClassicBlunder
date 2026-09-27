#define ELEV_KMAX 1.2
#define ELEV_TOP_LAYER 2.05
#define ELEV_FOAM_LAYER 2.899

turf/var/tmp/list/elevOverlays
turf/var/tmp/elev_pit = 0
turf/var/tmp/elev_pitv = 0
turf/var/tmp/turf/elev_cov
turf/var/tmp/elev_covv = 0

var/global/elevPitVer = 1
var/global/list/elevPitFlips = list()
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
	elevOrgConvCache = list()
	elevOrgCtxCache = list()
	elevOrgFeetCache = list()

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
	if(h <= 0 || ElevRoofTurf(T))
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
	return (h > 0 && !ElevRoofTurf(T)) ? "" : T.icon_state

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
	return ElevPitFlood(G, ElevAt(G), null)

/proc/ElevPitFlood(turf/G, lim, list/mark)
	var/list/seen = list()
	seen[G] = 1
	var/list/st = list(G)
	var/i = 1
	var/esc = 0
	while(i <= st.len && !esc)
		var/turf/C = st[i]
		i++
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
		if(mark)
			mark[V] = 1
		if(ElevAt(V) == lim)
			if(V.elev_pitv ? (V.elev_pit != res) : res)
				elevPitFlips[V] = 1
			V.elev_pit = res
			V.elev_pitv = elevPitVer
	return res

/proc/ElevPitOldAt(turf/T, list/old)
	var/o = old[T]
	return isnull(o) ? ElevAt(T) : o

/proc/ElevPitFloodOld(turf/G, lim, list/mark, list/old)
	var/list/seen = list()
	seen[G] = 1
	mark[G] = 1
	var/list/st = list(G)
	var/i = 1
	while(i <= st.len)
		var/turf/C = st[i]
		i++
		for(var/dd in CARDINAL_DIRECTIONS)
			var/turf/Q = get_step(C, dd)
			if(!Q)
				return null
			if(seen[Q] || ElevPitOldAt(Q, old) > lim)
				continue
			seen[Q] = 1
			mark[Q] = 1
			if(seen.len > 400)
				return null
			st += Q
	return seen

/proc/ElevPitSweep()
	if(!elevPitDirty.len)
		return
	var/list/old = elevPitDirty
	elevPitDirty = list()
	var/list/doneNew = list()
	var/list/doneOld = list()
	for(var/L = 0 to ELEV_MAX)
		doneNew += list(list())
		doneOld += list(list())
	for(var/turf/T in old)
		var/a = old[T]
		var/b = ElevAt(T)
		if(a == b)
			continue
		var/list/seeds = list(T)
		for(var/dd in CARDINAL_DIRECTIONS)
			var/turf/N = get_step(T, dd)
			if(N)
				seeds += N
		for(var/L = min(a, b), L < max(a, b), L++)
			var/list/dn = doneNew[L + 1]
			var/list/dol = doneOld[L + 1]
			for(var/turf/S in seeds)
				if(!dn[S] && ElevAt(S) <= L)
					ElevPitFlood(S, L, dn)
				if(!dol[S] && ElevPitOldAt(S, old) <= L)
					var/list/oc = ElevPitFloodOld(S, L, dol, old)
					if(oc)
						for(var/turf/V in oc)
							if(!dn[V] && ElevAt(V) == L)
								ElevPitFlood(V, L, dn)

/proc/ElevPitFlush(list/skip, bootPump = 0)
	var/n = 0
	while(elevPitFlips.len)
		var/list/fl = elevPitFlips
		elevPitFlips = list()
		for(var/turf/P in fl)
			if(skip && skip[P])
				continue
			ElevVisualUpdate(P)
			n++
			if(n % BUILD_COMMIT_CHUNK == 0)
				if(!bootPump || !BuildBootPassYield())
					sleep(-1)

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
				var/qorg = 0
				for(var/sq in elevLipSlots)
					var/turf/QS = srcs[sq]
					if(QS && ElevOrgStyle(QS))
						qorg = 1
						break
				ElevFoamTrio(qorg ? "oq" : "q", key, G, ELEV_FOAM_LAYER, fresh)
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
					if(org)
						ElevFoamTrio("ob", "[ElevStyleCode(WS)][T.x % 3][ElevOrgWrapEnd(T, fi, -1)][ElevOrgWrapEnd(T, fi, 1)]", WS, ElevLayer(top, 9), fresh)
					else
						ElevFoamTrio("b", bkey, WS, ElevLayer(top, 9), fresh)
	for(var/side in list("R", "L"))
		var/turf/NB = locate(T.x + (side == "R" ? 1 : -1), T.y, T.z)
		var/list/nf = ElevFaceInfo(NB)
		if(!nf || nf[(side == "R") ? 4 : 5] != "x")
			continue
		var/nsty = ElevFaceStyleFor(NB, nf[6])
		if(ElevFaceFlat(nf[6], nsty))
			continue
		var/norg = ElevOrgStyle(nf[6]) ? 1 : 0
		var/fpre = norg ? "o" : ""
		var/ntop = nf[1]
		if(!norg)
			var/sst = "s[nf[2]]_[nf[3]][side]"
			var/image/SP = ElevFacePiece(nsty, sst, ElevLayer(ntop, 0))
			if(SP)
				fresh += SP
		if(nf[3] != nf[2])
			if(!norg && !fi && elevBaseStates["tk[side]"])
				fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "tk[side]", ElevLayer(ntop, 4))
			if(!fi && ElevStyleCode(T) == "a")
				var/inr = ElevBelowFoot(T)
				var/rx = (norg && inr) ? ElevOrgInnerSuffix(T, side, ntop, 1) : ""
				ElevFoamTrio("[fpre][inr ? ((nf[3] == 1) ? "g" : "h") : ((nf[3] == 1) ? "k" : "m")]", "a[T.x % 3][side][rx]", T, ElevLayer(ntop, 9), fresh)
			continue
		var/turf/S2 = locate(T.x, T.y - 1, T.z)
		if(!S2)
			continue
		var/turf/WS2 = ElevWrapSrc(T, S2)
		var/tkey = "[ElevStyleCode(WS2)][T.x % 3][side]"
		if(!norg && elevBaseStates["tm[tkey]"])
			fresh += ElevTexPiece(WS2, 'Mapping/Elevation/elev_base.dmi', "tm[tkey]", ElevLayer(ntop, 2), 0)
		if(!norg && elevBaseStates["tb[tkey]"])
			fresh += ElevTexPiece(WS2, 'Mapping/Elevation/elev_base.dmi', "tb[tkey]", ElevLayer(ntop, 3), 1)
		if(!norg && !fi && elevBaseStates["td[tkey]"])
			fresh += ElevPlain('Mapping/Elevation/elev_base.dmi', "td[tkey]", ElevLayer(ntop, 4))
		if(!fi && copytext(tkey, 1, 2) == "a")
			var/inb = ElevBelowFoot(T)
			var/bx = (norg && inb) ? ElevOrgInnerSuffix(T, side, ntop, (nf[2] == 1) ? 0 : 1) : ""
			ElevFoamTrio("[fpre][inb ? ((nf[2] == 1) ? "i" : "j") : ((nf[2] == 1) ? "t" : "s")]", "[tkey][bx]", WS2, ElevLayer(ntop, 9), fresh)
	for(var/side in list("R", "L"))
		var/turf/DF = locate(T.x + (side == "R" ? 1 : -1), T.y - 1, T.z)
		var/list/df = ElevFaceInfo(DF)
		if(!df || df[3] != 1 || df[(side == "R") ? 4 : 5] != "x" || ElevAt(df[6]) <= 0)
			continue
		var/dsty = ElevFaceStyleFor(DF, df[6])
		if(ElevFaceFlat(df[6], dsty) || ElevOrgStyle(df[6]) || !ElevFrays(df[6]))
			continue
		var/image/WP = ElevFacePiece(dsty, "u[df[2]][side]", ElevLayer(df[1], 0))
		if(WP)
			fresh += WP

var/global/list/elevOrgSheets
var/global/list/elevOrgShade
var/global/list/elevOrgDark
var/global/list/elevOrgLift
var/global/list/elevOrgBev
var/global/list/elevOrgBevMid
var/global/list/elevOrgRing
var/global/list/elevOrgDrape
var/global/list/elevOrgUnder
var/global/list/elevOrgLow
var/global/list/elevOrgKeyFiles
var/global/list/elevOrgIndexFiles
var/global/list/elevOrgIndexYFiles
var/global/list/elevOrgIndexBFiles
var/global/list/elevOrgIndexZFiles
var/global/list/elevOrgRecFiles
var/global/list/elevOrgClasses
var/global/list/elevOrgMat
var/global/list/elevOrgKeyLines = list()
var/global/list/elevOrgIndexText = list()
var/global/list/elevOrgRecLines = list()
var/global/list/elevOrgParsed = list()
var/global/list/elevOrgFTCache = list()
var/global/list/elevOrgBotCache = list()
var/global/list/elevOrgBotShadeCache = list()
var/global/list/elevOrgStripCache = list()
var/global/list/elevOrgContactCache = list()
var/global/list/elevOrgBevCache = list()
var/global/list/elevOrgPalCache = list()
var/global/list/elevOrgFTStates = list()
var/global/list/elevOrgToothRows
var/global/list/elevOrgMColCache = list()
var/global/list/elevOrgConvCache = list()
var/global/elevOrgConvVer = -1
var/global/list/elevOrgCtxCache = list()
var/global/list/elevOrgFeetCache = list()
var/global/elevOrgCtxVer = -1
var/global/list/elevOrgContactLong = list(0.3, 0.2001, 0.12, 0.0501)
var/global/list/elevOrgContactShort = list(0.3, 0.165, 0.06)
var/global/list/elevOrgContactBlur = list(0.00026386508, 0.10645077, 0.78657072, 0.10645077, 0.00026386508)
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
		"tn00" = 'Mapping/EdgeOrg/et_n00.png',
		"tn01" = 'Mapping/EdgeOrg/et_n01.png',
		"tn02" = 'Mapping/EdgeOrg/et_n02.png',
		"tn03" = 'Mapping/EdgeOrg/et_n03.png',
		"tn10" = 'Mapping/EdgeOrg/et_n10.png',
		"tn11" = 'Mapping/EdgeOrg/et_n11.png',
		"tn12" = 'Mapping/EdgeOrg/et_n12.png',
		"tn13" = 'Mapping/EdgeOrg/et_n13.png',
		"tn20" = 'Mapping/EdgeOrg/et_n20.png',
		"tn21" = 'Mapping/EdgeOrg/et_n21.png',
		"tn22" = 'Mapping/EdgeOrg/et_n22.png',
		"tn23" = 'Mapping/EdgeOrg/et_n23.png',
		"tn30" = 'Mapping/EdgeOrg/et_n30.png',
		"tn31" = 'Mapping/EdgeOrg/et_n31.png',
		"tn32" = 'Mapping/EdgeOrg/et_n32.png',
		"tn33" = 'Mapping/EdgeOrg/et_n33.png',
		"ti00" = 'Mapping/EdgeOrg/et_i00.png',
		"ti01" = 'Mapping/EdgeOrg/et_i01.png',
		"ti02" = 'Mapping/EdgeOrg/et_i02.png',
		"ti03" = 'Mapping/EdgeOrg/et_i03.png',
		"ti10" = 'Mapping/EdgeOrg/et_i10.png',
		"ti11" = 'Mapping/EdgeOrg/et_i11.png',
		"ti12" = 'Mapping/EdgeOrg/et_i12.png',
		"ti13" = 'Mapping/EdgeOrg/et_i13.png',
		"ti20" = 'Mapping/EdgeOrg/et_i20.png',
		"ti21" = 'Mapping/EdgeOrg/et_i21.png',
		"ti22" = 'Mapping/EdgeOrg/et_i22.png',
		"ti23" = 'Mapping/EdgeOrg/et_i23.png',
		"ti30" = 'Mapping/EdgeOrg/et_i30.png',
		"ti31" = 'Mapping/EdgeOrg/et_i31.png',
		"ti32" = 'Mapping/EdgeOrg/et_i32.png',
		"ti33" = 'Mapping/EdgeOrg/et_i33.png')
	elevOrgShade = list(
		"w" = list(
			'Mapping/EdgeOrg/eh_w_0.png',
			'Mapping/EdgeOrg/eh_w_1.png',
			'Mapping/EdgeOrg/eh_w_2.png',
			'Mapping/EdgeOrg/eh_w_3.png',
			'Mapping/EdgeOrg/eh_w_4.png',
			'Mapping/EdgeOrg/eh_w_5.png',
			'Mapping/EdgeOrg/eh_w_6.png',
			'Mapping/EdgeOrg/eh_w_7.png',
			'Mapping/EdgeOrg/eh_w_8.png',
			'Mapping/EdgeOrg/eh_w_9.png',
			'Mapping/EdgeOrg/eh_w_10.png',
			'Mapping/EdgeOrg/eh_w_11.png',
			'Mapping/EdgeOrg/eh_w_12.png',
			'Mapping/EdgeOrg/eh_w_13.png',
			'Mapping/EdgeOrg/eh_w_14.png',
			'Mapping/EdgeOrg/eh_w_15.png',
			'Mapping/EdgeOrg/eh_w_16.png',
			'Mapping/EdgeOrg/eh_w_17.png',
			'Mapping/EdgeOrg/eh_w_18.png',
			'Mapping/EdgeOrg/eh_w_19.png',
			'Mapping/EdgeOrg/eh_w_20.png',
			'Mapping/EdgeOrg/eh_w_21.png',
			'Mapping/EdgeOrg/eh_w_22.png',
			'Mapping/EdgeOrg/eh_w_23.png',
			'Mapping/EdgeOrg/eh_w_24.png',
			'Mapping/EdgeOrg/eh_w_25.png',
			'Mapping/EdgeOrg/eh_w_26.png',
			'Mapping/EdgeOrg/eh_w_27.png',
			'Mapping/EdgeOrg/eh_w_28.png',
			'Mapping/EdgeOrg/eh_w_29.png',
			'Mapping/EdgeOrg/eh_w_30.png',
			'Mapping/EdgeOrg/eh_w_31.png',
			'Mapping/EdgeOrg/eh_w_32.png',
			'Mapping/EdgeOrg/eh_w_33.png',
			'Mapping/EdgeOrg/eh_w_34.png',
			'Mapping/EdgeOrg/eh_w_35.png',
			'Mapping/EdgeOrg/eh_w_36.png'),
		"c" = list(
			'Mapping/EdgeOrg/eh_c_0.png',
			'Mapping/EdgeOrg/eh_c_1.png',
			'Mapping/EdgeOrg/eh_c_2.png',
			'Mapping/EdgeOrg/eh_c_3.png',
			'Mapping/EdgeOrg/eh_c_4.png',
			'Mapping/EdgeOrg/eh_c_5.png',
			'Mapping/EdgeOrg/eh_c_6.png',
			'Mapping/EdgeOrg/eh_c_7.png',
			'Mapping/EdgeOrg/eh_c_8.png',
			'Mapping/EdgeOrg/eh_c_9.png',
			'Mapping/EdgeOrg/eh_c_10.png',
			'Mapping/EdgeOrg/eh_c_11.png',
			'Mapping/EdgeOrg/eh_c_12.png',
			'Mapping/EdgeOrg/eh_c_13.png',
			'Mapping/EdgeOrg/eh_c_14.png',
			'Mapping/EdgeOrg/eh_c_15.png',
			'Mapping/EdgeOrg/eh_c_16.png',
			'Mapping/EdgeOrg/eh_c_17.png',
			'Mapping/EdgeOrg/eh_c_18.png',
			'Mapping/EdgeOrg/eh_c_19.png',
			'Mapping/EdgeOrg/eh_c_20.png',
			'Mapping/EdgeOrg/eh_c_21.png',
			'Mapping/EdgeOrg/eh_c_22.png',
			'Mapping/EdgeOrg/eh_c_23.png',
			'Mapping/EdgeOrg/eh_c_24.png',
			'Mapping/EdgeOrg/eh_c_25.png',
			'Mapping/EdgeOrg/eh_c_26.png',
			'Mapping/EdgeOrg/eh_c_27.png',
			'Mapping/EdgeOrg/eh_c_28.png',
			'Mapping/EdgeOrg/eh_c_29.png',
			'Mapping/EdgeOrg/eh_c_30.png',
			'Mapping/EdgeOrg/eh_c_31.png',
			'Mapping/EdgeOrg/eh_c_32.png',
			'Mapping/EdgeOrg/eh_c_33.png',
			'Mapping/EdgeOrg/eh_c_34.png',
			'Mapping/EdgeOrg/eh_c_35.png',
			'Mapping/EdgeOrg/eh_c_36.png',
			'Mapping/EdgeOrg/eh_c_37.png',
			'Mapping/EdgeOrg/eh_c_38.png',
			'Mapping/EdgeOrg/eh_c_39.png',
			'Mapping/EdgeOrg/eh_c_40.png'),
		"s" = list(
			'Mapping/EdgeOrg/eh_s_0.png',
			'Mapping/EdgeOrg/eh_s_1.png',
			'Mapping/EdgeOrg/eh_s_2.png',
			'Mapping/EdgeOrg/eh_s_3.png',
			'Mapping/EdgeOrg/eh_s_4.png',
			'Mapping/EdgeOrg/eh_s_5.png',
			'Mapping/EdgeOrg/eh_s_6.png',
			'Mapping/EdgeOrg/eh_s_7.png',
			'Mapping/EdgeOrg/eh_s_8.png',
			'Mapping/EdgeOrg/eh_s_9.png',
			'Mapping/EdgeOrg/eh_s_10.png',
			'Mapping/EdgeOrg/eh_s_11.png',
			'Mapping/EdgeOrg/eh_s_12.png',
			'Mapping/EdgeOrg/eh_s_13.png',
			'Mapping/EdgeOrg/eh_s_14.png',
			'Mapping/EdgeOrg/eh_s_15.png',
			'Mapping/EdgeOrg/eh_s_16.png',
			'Mapping/EdgeOrg/eh_s_17.png',
			'Mapping/EdgeOrg/eh_s_18.png',
			'Mapping/EdgeOrg/eh_s_19.png',
			'Mapping/EdgeOrg/eh_s_20.png',
			'Mapping/EdgeOrg/eh_s_21.png',
			'Mapping/EdgeOrg/eh_s_22.png',
			'Mapping/EdgeOrg/eh_s_23.png',
			'Mapping/EdgeOrg/eh_s_24.png',
			'Mapping/EdgeOrg/eh_s_25.png',
			'Mapping/EdgeOrg/eh_s_26.png',
			'Mapping/EdgeOrg/eh_s_27.png',
			'Mapping/EdgeOrg/eh_s_28.png',
			'Mapping/EdgeOrg/eh_s_29.png',
			'Mapping/EdgeOrg/eh_s_30.png',
			'Mapping/EdgeOrg/eh_s_31.png',
			'Mapping/EdgeOrg/eh_s_32.png',
			'Mapping/EdgeOrg/eh_s_33.png'),
		"n" = list(
			'Mapping/EdgeOrg/eh_n_0.png',
			'Mapping/EdgeOrg/eh_n_1.png',
			'Mapping/EdgeOrg/eh_n_2.png',
			'Mapping/EdgeOrg/eh_n_3.png',
			'Mapping/EdgeOrg/eh_n_4.png',
			'Mapping/EdgeOrg/eh_n_5.png',
			'Mapping/EdgeOrg/eh_n_6.png',
			'Mapping/EdgeOrg/eh_n_7.png',
			'Mapping/EdgeOrg/eh_n_8.png',
			'Mapping/EdgeOrg/eh_n_9.png',
			'Mapping/EdgeOrg/eh_n_10.png',
			'Mapping/EdgeOrg/eh_n_11.png',
			'Mapping/EdgeOrg/eh_n_12.png',
			'Mapping/EdgeOrg/eh_n_13.png',
			'Mapping/EdgeOrg/eh_n_14.png',
			'Mapping/EdgeOrg/eh_n_15.png',
			'Mapping/EdgeOrg/eh_n_16.png',
			'Mapping/EdgeOrg/eh_n_17.png',
			'Mapping/EdgeOrg/eh_n_18.png',
			'Mapping/EdgeOrg/eh_n_19.png',
			'Mapping/EdgeOrg/eh_n_20.png',
			'Mapping/EdgeOrg/eh_n_21.png',
			'Mapping/EdgeOrg/eh_n_22.png',
			'Mapping/EdgeOrg/eh_n_23.png',
			'Mapping/EdgeOrg/eh_n_24.png',
			'Mapping/EdgeOrg/eh_n_25.png',
			'Mapping/EdgeOrg/eh_n_26.png',
			'Mapping/EdgeOrg/eh_n_27.png',
			'Mapping/EdgeOrg/eh_n_28.png',
			'Mapping/EdgeOrg/eh_n_29.png',
			'Mapping/EdgeOrg/eh_n_30.png',
			'Mapping/EdgeOrg/eh_n_31.png',
			'Mapping/EdgeOrg/eh_n_32.png',
			'Mapping/EdgeOrg/eh_n_33.png',
			'Mapping/EdgeOrg/eh_n_34.png',
			'Mapping/EdgeOrg/eh_n_35.png',
			'Mapping/EdgeOrg/eh_n_36.png',
			'Mapping/EdgeOrg/eh_n_37.png',
			'Mapping/EdgeOrg/eh_n_38.png',
			'Mapping/EdgeOrg/eh_n_39.png'),
		"i" = list(
			'Mapping/EdgeOrg/eh_i_0.png',
			'Mapping/EdgeOrg/eh_i_1.png',
			'Mapping/EdgeOrg/eh_i_2.png',
			'Mapping/EdgeOrg/eh_i_3.png',
			'Mapping/EdgeOrg/eh_i_4.png',
			'Mapping/EdgeOrg/eh_i_5.png',
			'Mapping/EdgeOrg/eh_i_6.png',
			'Mapping/EdgeOrg/eh_i_7.png',
			'Mapping/EdgeOrg/eh_i_8.png',
			'Mapping/EdgeOrg/eh_i_9.png',
			'Mapping/EdgeOrg/eh_i_10.png',
			'Mapping/EdgeOrg/eh_i_11.png',
			'Mapping/EdgeOrg/eh_i_12.png',
			'Mapping/EdgeOrg/eh_i_13.png',
			'Mapping/EdgeOrg/eh_i_14.png',
			'Mapping/EdgeOrg/eh_i_15.png',
			'Mapping/EdgeOrg/eh_i_16.png',
			'Mapping/EdgeOrg/eh_i_17.png',
			'Mapping/EdgeOrg/eh_i_18.png',
			'Mapping/EdgeOrg/eh_i_19.png',
			'Mapping/EdgeOrg/eh_i_20.png',
			'Mapping/EdgeOrg/eh_i_21.png',
			'Mapping/EdgeOrg/eh_i_22.png',
			'Mapping/EdgeOrg/eh_i_23.png',
			'Mapping/EdgeOrg/eh_i_24.png',
			'Mapping/EdgeOrg/eh_i_25.png',
			'Mapping/EdgeOrg/eh_i_26.png',
			'Mapping/EdgeOrg/eh_i_27.png',
			'Mapping/EdgeOrg/eh_i_28.png',
			'Mapping/EdgeOrg/eh_i_29.png',
			'Mapping/EdgeOrg/eh_i_30.png',
			'Mapping/EdgeOrg/eh_i_31.png',
			'Mapping/EdgeOrg/eh_i_32.png',
			'Mapping/EdgeOrg/eh_i_33.png',
			'Mapping/EdgeOrg/eh_i_34.png',
			'Mapping/EdgeOrg/eh_i_35.png',
			'Mapping/EdgeOrg/eh_i_36.png',
			'Mapping/EdgeOrg/eh_i_37.png',
			'Mapping/EdgeOrg/eh_i_38.png',
			'Mapping/EdgeOrg/eh_i_39.png',
			'Mapping/EdgeOrg/eh_i_40.png'))
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
			'Mapping/EdgeOrg/ed_c_82.png',
			'Mapping/EdgeOrg/ed_c_83.png',
			'Mapping/EdgeOrg/ed_c_84.png',
			'Mapping/EdgeOrg/ed_c_85.png',
			'Mapping/EdgeOrg/ed_c_86.png',
			'Mapping/EdgeOrg/ed_c_87.png',
			'Mapping/EdgeOrg/ed_c_88.png',
			'Mapping/EdgeOrg/ed_c_89.png'),
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
			'Mapping/EdgeOrg/ed_s_46.png'),
		"n" = list(
			'Mapping/EdgeOrg/ed_n_0.png',
			'Mapping/EdgeOrg/ed_n_1.png',
			'Mapping/EdgeOrg/ed_n_2.png',
			'Mapping/EdgeOrg/ed_n_3.png',
			'Mapping/EdgeOrg/ed_n_4.png',
			'Mapping/EdgeOrg/ed_n_5.png',
			'Mapping/EdgeOrg/ed_n_6.png',
			'Mapping/EdgeOrg/ed_n_7.png',
			'Mapping/EdgeOrg/ed_n_8.png',
			'Mapping/EdgeOrg/ed_n_9.png',
			'Mapping/EdgeOrg/ed_n_10.png',
			'Mapping/EdgeOrg/ed_n_11.png',
			'Mapping/EdgeOrg/ed_n_12.png',
			'Mapping/EdgeOrg/ed_n_13.png',
			'Mapping/EdgeOrg/ed_n_14.png',
			'Mapping/EdgeOrg/ed_n_15.png',
			'Mapping/EdgeOrg/ed_n_16.png',
			'Mapping/EdgeOrg/ed_n_17.png',
			'Mapping/EdgeOrg/ed_n_18.png',
			'Mapping/EdgeOrg/ed_n_19.png',
			'Mapping/EdgeOrg/ed_n_20.png',
			'Mapping/EdgeOrg/ed_n_21.png',
			'Mapping/EdgeOrg/ed_n_22.png',
			'Mapping/EdgeOrg/ed_n_23.png',
			'Mapping/EdgeOrg/ed_n_24.png',
			'Mapping/EdgeOrg/ed_n_25.png',
			'Mapping/EdgeOrg/ed_n_26.png',
			'Mapping/EdgeOrg/ed_n_27.png',
			'Mapping/EdgeOrg/ed_n_28.png',
			'Mapping/EdgeOrg/ed_n_29.png',
			'Mapping/EdgeOrg/ed_n_30.png',
			'Mapping/EdgeOrg/ed_n_31.png',
			'Mapping/EdgeOrg/ed_n_32.png',
			'Mapping/EdgeOrg/ed_n_33.png',
			'Mapping/EdgeOrg/ed_n_34.png',
			'Mapping/EdgeOrg/ed_n_35.png',
			'Mapping/EdgeOrg/ed_n_36.png',
			'Mapping/EdgeOrg/ed_n_37.png',
			'Mapping/EdgeOrg/ed_n_38.png',
			'Mapping/EdgeOrg/ed_n_39.png',
			'Mapping/EdgeOrg/ed_n_40.png',
			'Mapping/EdgeOrg/ed_n_41.png',
			'Mapping/EdgeOrg/ed_n_42.png',
			'Mapping/EdgeOrg/ed_n_43.png',
			'Mapping/EdgeOrg/ed_n_44.png',
			'Mapping/EdgeOrg/ed_n_45.png',
			'Mapping/EdgeOrg/ed_n_46.png',
			'Mapping/EdgeOrg/ed_n_47.png',
			'Mapping/EdgeOrg/ed_n_48.png',
			'Mapping/EdgeOrg/ed_n_49.png',
			'Mapping/EdgeOrg/ed_n_50.png',
			'Mapping/EdgeOrg/ed_n_51.png',
			'Mapping/EdgeOrg/ed_n_52.png',
			'Mapping/EdgeOrg/ed_n_53.png',
			'Mapping/EdgeOrg/ed_n_54.png',
			'Mapping/EdgeOrg/ed_n_55.png',
			'Mapping/EdgeOrg/ed_n_56.png',
			'Mapping/EdgeOrg/ed_n_57.png',
			'Mapping/EdgeOrg/ed_n_58.png',
			'Mapping/EdgeOrg/ed_n_59.png',
			'Mapping/EdgeOrg/ed_n_60.png',
			'Mapping/EdgeOrg/ed_n_61.png',
			'Mapping/EdgeOrg/ed_n_62.png',
			'Mapping/EdgeOrg/ed_n_63.png',
			'Mapping/EdgeOrg/ed_n_64.png',
			'Mapping/EdgeOrg/ed_n_65.png',
			'Mapping/EdgeOrg/ed_n_66.png',
			'Mapping/EdgeOrg/ed_n_67.png',
			'Mapping/EdgeOrg/ed_n_68.png'),
		"i" = list(
			'Mapping/EdgeOrg/ed_i_0.png',
			'Mapping/EdgeOrg/ed_i_1.png',
			'Mapping/EdgeOrg/ed_i_2.png',
			'Mapping/EdgeOrg/ed_i_3.png',
			'Mapping/EdgeOrg/ed_i_4.png',
			'Mapping/EdgeOrg/ed_i_5.png',
			'Mapping/EdgeOrg/ed_i_6.png',
			'Mapping/EdgeOrg/ed_i_7.png',
			'Mapping/EdgeOrg/ed_i_8.png',
			'Mapping/EdgeOrg/ed_i_9.png',
			'Mapping/EdgeOrg/ed_i_10.png',
			'Mapping/EdgeOrg/ed_i_11.png',
			'Mapping/EdgeOrg/ed_i_12.png',
			'Mapping/EdgeOrg/ed_i_13.png',
			'Mapping/EdgeOrg/ed_i_14.png',
			'Mapping/EdgeOrg/ed_i_15.png',
			'Mapping/EdgeOrg/ed_i_16.png',
			'Mapping/EdgeOrg/ed_i_17.png',
			'Mapping/EdgeOrg/ed_i_18.png',
			'Mapping/EdgeOrg/ed_i_19.png',
			'Mapping/EdgeOrg/ed_i_20.png',
			'Mapping/EdgeOrg/ed_i_21.png',
			'Mapping/EdgeOrg/ed_i_22.png',
			'Mapping/EdgeOrg/ed_i_23.png',
			'Mapping/EdgeOrg/ed_i_24.png',
			'Mapping/EdgeOrg/ed_i_25.png',
			'Mapping/EdgeOrg/ed_i_26.png',
			'Mapping/EdgeOrg/ed_i_27.png',
			'Mapping/EdgeOrg/ed_i_28.png',
			'Mapping/EdgeOrg/ed_i_29.png',
			'Mapping/EdgeOrg/ed_i_30.png',
			'Mapping/EdgeOrg/ed_i_31.png',
			'Mapping/EdgeOrg/ed_i_32.png',
			'Mapping/EdgeOrg/ed_i_33.png',
			'Mapping/EdgeOrg/ed_i_34.png',
			'Mapping/EdgeOrg/ed_i_35.png',
			'Mapping/EdgeOrg/ed_i_36.png',
			'Mapping/EdgeOrg/ed_i_37.png',
			'Mapping/EdgeOrg/ed_i_38.png',
			'Mapping/EdgeOrg/ed_i_39.png',
			'Mapping/EdgeOrg/ed_i_40.png',
			'Mapping/EdgeOrg/ed_i_41.png',
			'Mapping/EdgeOrg/ed_i_42.png',
			'Mapping/EdgeOrg/ed_i_43.png',
			'Mapping/EdgeOrg/ed_i_44.png',
			'Mapping/EdgeOrg/ed_i_45.png',
			'Mapping/EdgeOrg/ed_i_46.png',
			'Mapping/EdgeOrg/ed_i_47.png',
			'Mapping/EdgeOrg/ed_i_48.png',
			'Mapping/EdgeOrg/ed_i_49.png',
			'Mapping/EdgeOrg/ed_i_50.png',
			'Mapping/EdgeOrg/ed_i_51.png',
			'Mapping/EdgeOrg/ed_i_52.png',
			'Mapping/EdgeOrg/ed_i_53.png',
			'Mapping/EdgeOrg/ed_i_54.png',
			'Mapping/EdgeOrg/ed_i_55.png',
			'Mapping/EdgeOrg/ed_i_56.png',
			'Mapping/EdgeOrg/ed_i_57.png',
			'Mapping/EdgeOrg/ed_i_58.png',
			'Mapping/EdgeOrg/ed_i_59.png',
			'Mapping/EdgeOrg/ed_i_60.png',
			'Mapping/EdgeOrg/ed_i_61.png',
			'Mapping/EdgeOrg/ed_i_62.png',
			'Mapping/EdgeOrg/ed_i_63.png',
			'Mapping/EdgeOrg/ed_i_64.png'))
	elevOrgLift = list(
		"w" = list(
			'Mapping/EdgeOrg/ef_w_0.png',
			'Mapping/EdgeOrg/ef_w_1.png',
			'Mapping/EdgeOrg/ef_w_2.png',
			'Mapping/EdgeOrg/ef_w_3.png',
			'Mapping/EdgeOrg/ef_w_4.png',
			'Mapping/EdgeOrg/ef_w_5.png',
			'Mapping/EdgeOrg/ef_w_6.png',
			'Mapping/EdgeOrg/ef_w_7.png',
			'Mapping/EdgeOrg/ef_w_8.png',
			'Mapping/EdgeOrg/ef_w_9.png',
			'Mapping/EdgeOrg/ef_w_10.png',
			'Mapping/EdgeOrg/ef_w_11.png',
			'Mapping/EdgeOrg/ef_w_12.png',
			'Mapping/EdgeOrg/ef_w_13.png',
			'Mapping/EdgeOrg/ef_w_14.png'),
		"c" = list(
			'Mapping/EdgeOrg/ef_c_0.png',
			'Mapping/EdgeOrg/ef_c_1.png',
			'Mapping/EdgeOrg/ef_c_2.png',
			'Mapping/EdgeOrg/ef_c_3.png',
			'Mapping/EdgeOrg/ef_c_4.png',
			'Mapping/EdgeOrg/ef_c_5.png',
			'Mapping/EdgeOrg/ef_c_6.png',
			'Mapping/EdgeOrg/ef_c_7.png',
			'Mapping/EdgeOrg/ef_c_8.png',
			'Mapping/EdgeOrg/ef_c_9.png',
			'Mapping/EdgeOrg/ef_c_10.png',
			'Mapping/EdgeOrg/ef_c_11.png',
			'Mapping/EdgeOrg/ef_c_12.png',
			'Mapping/EdgeOrg/ef_c_13.png',
			'Mapping/EdgeOrg/ef_c_14.png'),
		"s" = list(
			'Mapping/EdgeOrg/ef_s_0.png',
			'Mapping/EdgeOrg/ef_s_1.png',
			'Mapping/EdgeOrg/ef_s_2.png',
			'Mapping/EdgeOrg/ef_s_3.png',
			'Mapping/EdgeOrg/ef_s_4.png',
			'Mapping/EdgeOrg/ef_s_5.png',
			'Mapping/EdgeOrg/ef_s_6.png',
			'Mapping/EdgeOrg/ef_s_7.png',
			'Mapping/EdgeOrg/ef_s_8.png',
			'Mapping/EdgeOrg/ef_s_9.png'),
		"n" = list(
			'Mapping/EdgeOrg/ef_n_0.png',
			'Mapping/EdgeOrg/ef_n_1.png',
			'Mapping/EdgeOrg/ef_n_2.png',
			'Mapping/EdgeOrg/ef_n_3.png',
			'Mapping/EdgeOrg/ef_n_4.png',
			'Mapping/EdgeOrg/ef_n_5.png',
			'Mapping/EdgeOrg/ef_n_6.png',
			'Mapping/EdgeOrg/ef_n_7.png',
			'Mapping/EdgeOrg/ef_n_8.png',
			'Mapping/EdgeOrg/ef_n_9.png',
			'Mapping/EdgeOrg/ef_n_10.png',
			'Mapping/EdgeOrg/ef_n_11.png',
			'Mapping/EdgeOrg/ef_n_12.png',
			'Mapping/EdgeOrg/ef_n_13.png'),
		"i" = list(
			'Mapping/EdgeOrg/ef_i_0.png',
			'Mapping/EdgeOrg/ef_i_1.png',
			'Mapping/EdgeOrg/ef_i_2.png',
			'Mapping/EdgeOrg/ef_i_3.png',
			'Mapping/EdgeOrg/ef_i_4.png',
			'Mapping/EdgeOrg/ef_i_5.png',
			'Mapping/EdgeOrg/ef_i_6.png',
			'Mapping/EdgeOrg/ef_i_7.png',
			'Mapping/EdgeOrg/ef_i_8.png',
			'Mapping/EdgeOrg/ef_i_9.png',
			'Mapping/EdgeOrg/ef_i_10.png',
			'Mapping/EdgeOrg/ef_i_11.png',
			'Mapping/EdgeOrg/ef_i_12.png',
			'Mapping/EdgeOrg/ef_i_13.png',
			'Mapping/EdgeOrg/ef_i_14.png'))
	elevOrgBev = list(
		"wg" = list(
			'Mapping/EdgeOrg/eb_wg_0.png',
			'Mapping/EdgeOrg/eb_wg_1.png',
			'Mapping/EdgeOrg/eb_wg_2.png',
			'Mapping/EdgeOrg/eb_wg_3.png',
			'Mapping/EdgeOrg/eb_wg_4.png',
			'Mapping/EdgeOrg/eb_wg_5.png',
			'Mapping/EdgeOrg/eb_wg_6.png',
			'Mapping/EdgeOrg/eb_wg_7.png',
			'Mapping/EdgeOrg/eb_wg_8.png',
			'Mapping/EdgeOrg/eb_wg_9.png',
			'Mapping/EdgeOrg/eb_wg_10.png',
			'Mapping/EdgeOrg/eb_wg_11.png',
			'Mapping/EdgeOrg/eb_wg_12.png',
			'Mapping/EdgeOrg/eb_wg_13.png',
			'Mapping/EdgeOrg/eb_wg_14.png',
			'Mapping/EdgeOrg/eb_wg_15.png',
			'Mapping/EdgeOrg/eb_wg_16.png',
			'Mapping/EdgeOrg/eb_wg_17.png',
			'Mapping/EdgeOrg/eb_wg_18.png',
			'Mapping/EdgeOrg/eb_wg_19.png',
			'Mapping/EdgeOrg/eb_wg_20.png',
			'Mapping/EdgeOrg/eb_wg_21.png',
			'Mapping/EdgeOrg/eb_wg_22.png',
			'Mapping/EdgeOrg/eb_wg_23.png',
			'Mapping/EdgeOrg/eb_wg_24.png',
			'Mapping/EdgeOrg/eb_wg_25.png',
			'Mapping/EdgeOrg/eb_wg_26.png',
			'Mapping/EdgeOrg/eb_wg_27.png',
			'Mapping/EdgeOrg/eb_wg_28.png',
			'Mapping/EdgeOrg/eb_wg_29.png',
			'Mapping/EdgeOrg/eb_wg_30.png'),
		"cd" = list(
			'Mapping/EdgeOrg/eb_cd_0.png',
			'Mapping/EdgeOrg/eb_cd_1.png',
			'Mapping/EdgeOrg/eb_cd_2.png',
			'Mapping/EdgeOrg/eb_cd_3.png',
			'Mapping/EdgeOrg/eb_cd_4.png',
			'Mapping/EdgeOrg/eb_cd_5.png',
			'Mapping/EdgeOrg/eb_cd_6.png',
			'Mapping/EdgeOrg/eb_cd_7.png',
			'Mapping/EdgeOrg/eb_cd_8.png',
			'Mapping/EdgeOrg/eb_cd_9.png',
			'Mapping/EdgeOrg/eb_cd_10.png',
			'Mapping/EdgeOrg/eb_cd_11.png',
			'Mapping/EdgeOrg/eb_cd_12.png',
			'Mapping/EdgeOrg/eb_cd_13.png',
			'Mapping/EdgeOrg/eb_cd_14.png',
			'Mapping/EdgeOrg/eb_cd_15.png',
			'Mapping/EdgeOrg/eb_cd_16.png',
			'Mapping/EdgeOrg/eb_cd_17.png',
			'Mapping/EdgeOrg/eb_cd_18.png',
			'Mapping/EdgeOrg/eb_cd_19.png',
			'Mapping/EdgeOrg/eb_cd_20.png',
			'Mapping/EdgeOrg/eb_cd_21.png',
			'Mapping/EdgeOrg/eb_cd_22.png',
			'Mapping/EdgeOrg/eb_cd_23.png',
			'Mapping/EdgeOrg/eb_cd_24.png',
			'Mapping/EdgeOrg/eb_cd_25.png',
			'Mapping/EdgeOrg/eb_cd_26.png',
			'Mapping/EdgeOrg/eb_cd_27.png'),
		"sa" = list(
			'Mapping/EdgeOrg/eb_sa_0.png',
			'Mapping/EdgeOrg/eb_sa_1.png',
			'Mapping/EdgeOrg/eb_sa_2.png',
			'Mapping/EdgeOrg/eb_sa_3.png',
			'Mapping/EdgeOrg/eb_sa_4.png',
			'Mapping/EdgeOrg/eb_sa_5.png',
			'Mapping/EdgeOrg/eb_sa_6.png',
			'Mapping/EdgeOrg/eb_sa_7.png',
			'Mapping/EdgeOrg/eb_sa_8.png',
			'Mapping/EdgeOrg/eb_sa_9.png',
			'Mapping/EdgeOrg/eb_sa_10.png',
			'Mapping/EdgeOrg/eb_sa_11.png',
			'Mapping/EdgeOrg/eb_sa_12.png',
			'Mapping/EdgeOrg/eb_sa_13.png',
			'Mapping/EdgeOrg/eb_sa_14.png',
			'Mapping/EdgeOrg/eb_sa_15.png',
			'Mapping/EdgeOrg/eb_sa_16.png',
			'Mapping/EdgeOrg/eb_sa_17.png'),
		"nn" = list(),
		"ii" = list(
			'Mapping/EdgeOrg/eb_ii_0.png',
			'Mapping/EdgeOrg/eb_ii_1.png',
			'Mapping/EdgeOrg/eb_ii_2.png',
			'Mapping/EdgeOrg/eb_ii_3.png',
			'Mapping/EdgeOrg/eb_ii_4.png',
			'Mapping/EdgeOrg/eb_ii_5.png',
			'Mapping/EdgeOrg/eb_ii_6.png',
			'Mapping/EdgeOrg/eb_ii_7.png',
			'Mapping/EdgeOrg/eb_ii_8.png',
			'Mapping/EdgeOrg/eb_ii_9.png',
			'Mapping/EdgeOrg/eb_ii_10.png',
			'Mapping/EdgeOrg/eb_ii_11.png',
			'Mapping/EdgeOrg/eb_ii_12.png',
			'Mapping/EdgeOrg/eb_ii_13.png',
			'Mapping/EdgeOrg/eb_ii_14.png',
			'Mapping/EdgeOrg/eb_ii_15.png',
			'Mapping/EdgeOrg/eb_ii_16.png',
			'Mapping/EdgeOrg/eb_ii_17.png',
			'Mapping/EdgeOrg/eb_ii_18.png',
			'Mapping/EdgeOrg/eb_ii_19.png'))
	elevOrgBevMid = list(
		"wg" = list(
			'Mapping/EdgeOrg/ec_wg_0.png',
			'Mapping/EdgeOrg/ec_wg_1.png',
			'Mapping/EdgeOrg/ec_wg_2.png',
			'Mapping/EdgeOrg/ec_wg_3.png',
			'Mapping/EdgeOrg/ec_wg_4.png',
			'Mapping/EdgeOrg/ec_wg_5.png',
			'Mapping/EdgeOrg/ec_wg_6.png',
			'Mapping/EdgeOrg/ec_wg_7.png',
			'Mapping/EdgeOrg/ec_wg_8.png',
			'Mapping/EdgeOrg/ec_wg_9.png',
			'Mapping/EdgeOrg/ec_wg_10.png',
			'Mapping/EdgeOrg/ec_wg_11.png',
			'Mapping/EdgeOrg/ec_wg_12.png',
			'Mapping/EdgeOrg/ec_wg_13.png',
			'Mapping/EdgeOrg/ec_wg_14.png',
			'Mapping/EdgeOrg/ec_wg_15.png',
			'Mapping/EdgeOrg/ec_wg_16.png',
			'Mapping/EdgeOrg/ec_wg_17.png',
			'Mapping/EdgeOrg/ec_wg_18.png',
			'Mapping/EdgeOrg/ec_wg_19.png',
			'Mapping/EdgeOrg/ec_wg_20.png',
			'Mapping/EdgeOrg/ec_wg_21.png',
			'Mapping/EdgeOrg/ec_wg_22.png',
			'Mapping/EdgeOrg/ec_wg_23.png',
			'Mapping/EdgeOrg/ec_wg_24.png',
			'Mapping/EdgeOrg/ec_wg_25.png',
			'Mapping/EdgeOrg/ec_wg_26.png',
			'Mapping/EdgeOrg/ec_wg_27.png',
			'Mapping/EdgeOrg/ec_wg_28.png',
			'Mapping/EdgeOrg/ec_wg_29.png',
			'Mapping/EdgeOrg/ec_wg_30.png'),
		"cd" = list(
			'Mapping/EdgeOrg/ec_cd_0.png',
			'Mapping/EdgeOrg/ec_cd_1.png',
			'Mapping/EdgeOrg/ec_cd_2.png',
			'Mapping/EdgeOrg/ec_cd_3.png',
			'Mapping/EdgeOrg/ec_cd_4.png',
			'Mapping/EdgeOrg/ec_cd_5.png',
			'Mapping/EdgeOrg/ec_cd_6.png',
			'Mapping/EdgeOrg/ec_cd_7.png',
			'Mapping/EdgeOrg/ec_cd_8.png',
			'Mapping/EdgeOrg/ec_cd_9.png',
			'Mapping/EdgeOrg/ec_cd_10.png',
			'Mapping/EdgeOrg/ec_cd_11.png',
			'Mapping/EdgeOrg/ec_cd_12.png',
			'Mapping/EdgeOrg/ec_cd_13.png',
			'Mapping/EdgeOrg/ec_cd_14.png',
			'Mapping/EdgeOrg/ec_cd_15.png',
			'Mapping/EdgeOrg/ec_cd_16.png',
			'Mapping/EdgeOrg/ec_cd_17.png',
			'Mapping/EdgeOrg/ec_cd_18.png',
			'Mapping/EdgeOrg/ec_cd_19.png',
			'Mapping/EdgeOrg/ec_cd_20.png',
			'Mapping/EdgeOrg/ec_cd_21.png',
			'Mapping/EdgeOrg/ec_cd_22.png',
			'Mapping/EdgeOrg/ec_cd_23.png',
			'Mapping/EdgeOrg/ec_cd_24.png',
			'Mapping/EdgeOrg/ec_cd_25.png',
			'Mapping/EdgeOrg/ec_cd_26.png',
			'Mapping/EdgeOrg/ec_cd_27.png'),
		"sa" = list(
			'Mapping/EdgeOrg/ec_sa_0.png',
			'Mapping/EdgeOrg/ec_sa_1.png',
			'Mapping/EdgeOrg/ec_sa_2.png',
			'Mapping/EdgeOrg/ec_sa_3.png',
			'Mapping/EdgeOrg/ec_sa_4.png',
			'Mapping/EdgeOrg/ec_sa_5.png',
			'Mapping/EdgeOrg/ec_sa_6.png',
			'Mapping/EdgeOrg/ec_sa_7.png',
			'Mapping/EdgeOrg/ec_sa_8.png',
			'Mapping/EdgeOrg/ec_sa_9.png',
			'Mapping/EdgeOrg/ec_sa_10.png',
			'Mapping/EdgeOrg/ec_sa_11.png',
			'Mapping/EdgeOrg/ec_sa_12.png',
			'Mapping/EdgeOrg/ec_sa_13.png',
			'Mapping/EdgeOrg/ec_sa_14.png',
			'Mapping/EdgeOrg/ec_sa_15.png',
			'Mapping/EdgeOrg/ec_sa_16.png',
			'Mapping/EdgeOrg/ec_sa_17.png'),
		"nn" = list(),
		"ii" = list(
			'Mapping/EdgeOrg/ec_ii_0.png',
			'Mapping/EdgeOrg/ec_ii_1.png',
			'Mapping/EdgeOrg/ec_ii_2.png',
			'Mapping/EdgeOrg/ec_ii_3.png',
			'Mapping/EdgeOrg/ec_ii_4.png',
			'Mapping/EdgeOrg/ec_ii_5.png',
			'Mapping/EdgeOrg/ec_ii_6.png',
			'Mapping/EdgeOrg/ec_ii_7.png',
			'Mapping/EdgeOrg/ec_ii_8.png',
			'Mapping/EdgeOrg/ec_ii_9.png',
			'Mapping/EdgeOrg/ec_ii_10.png',
			'Mapping/EdgeOrg/ec_ii_11.png',
			'Mapping/EdgeOrg/ec_ii_12.png',
			'Mapping/EdgeOrg/ec_ii_13.png',
			'Mapping/EdgeOrg/ec_ii_14.png',
			'Mapping/EdgeOrg/ec_ii_15.png',
			'Mapping/EdgeOrg/ec_ii_16.png',
			'Mapping/EdgeOrg/ec_ii_17.png',
			'Mapping/EdgeOrg/ec_ii_18.png',
			'Mapping/EdgeOrg/ec_ii_19.png'))
	elevOrgRing = list(
		"wg" = list(
			'Mapping/EdgeOrg/eg_wg_0.png',
			'Mapping/EdgeOrg/eg_wg_1.png',
			'Mapping/EdgeOrg/eg_wg_2.png',
			'Mapping/EdgeOrg/eg_wg_3.png',
			'Mapping/EdgeOrg/eg_wg_4.png',
			'Mapping/EdgeOrg/eg_wg_5.png',
			'Mapping/EdgeOrg/eg_wg_6.png',
			'Mapping/EdgeOrg/eg_wg_7.png',
			'Mapping/EdgeOrg/eg_wg_8.png',
			'Mapping/EdgeOrg/eg_wg_9.png',
			'Mapping/EdgeOrg/eg_wg_10.png',
			'Mapping/EdgeOrg/eg_wg_11.png',
			'Mapping/EdgeOrg/eg_wg_12.png',
			'Mapping/EdgeOrg/eg_wg_13.png',
			'Mapping/EdgeOrg/eg_wg_14.png',
			'Mapping/EdgeOrg/eg_wg_15.png',
			'Mapping/EdgeOrg/eg_wg_16.png',
			'Mapping/EdgeOrg/eg_wg_17.png',
			'Mapping/EdgeOrg/eg_wg_18.png',
			'Mapping/EdgeOrg/eg_wg_19.png',
			'Mapping/EdgeOrg/eg_wg_20.png',
			'Mapping/EdgeOrg/eg_wg_21.png',
			'Mapping/EdgeOrg/eg_wg_22.png',
			'Mapping/EdgeOrg/eg_wg_23.png',
			'Mapping/EdgeOrg/eg_wg_24.png',
			'Mapping/EdgeOrg/eg_wg_25.png',
			'Mapping/EdgeOrg/eg_wg_26.png',
			'Mapping/EdgeOrg/eg_wg_27.png',
			'Mapping/EdgeOrg/eg_wg_28.png',
			'Mapping/EdgeOrg/eg_wg_29.png',
			'Mapping/EdgeOrg/eg_wg_30.png',
			'Mapping/EdgeOrg/eg_wg_31.png',
			'Mapping/EdgeOrg/eg_wg_32.png',
			'Mapping/EdgeOrg/eg_wg_33.png',
			'Mapping/EdgeOrg/eg_wg_34.png',
			'Mapping/EdgeOrg/eg_wg_35.png',
			'Mapping/EdgeOrg/eg_wg_36.png',
			'Mapping/EdgeOrg/eg_wg_37.png',
			'Mapping/EdgeOrg/eg_wg_38.png',
			'Mapping/EdgeOrg/eg_wg_39.png',
			'Mapping/EdgeOrg/eg_wg_40.png',
			'Mapping/EdgeOrg/eg_wg_41.png',
			'Mapping/EdgeOrg/eg_wg_42.png',
			'Mapping/EdgeOrg/eg_wg_43.png'),
		"cd" = list(
			'Mapping/EdgeOrg/eg_cd_0.png',
			'Mapping/EdgeOrg/eg_cd_1.png',
			'Mapping/EdgeOrg/eg_cd_2.png',
			'Mapping/EdgeOrg/eg_cd_3.png',
			'Mapping/EdgeOrg/eg_cd_4.png',
			'Mapping/EdgeOrg/eg_cd_5.png',
			'Mapping/EdgeOrg/eg_cd_6.png',
			'Mapping/EdgeOrg/eg_cd_7.png',
			'Mapping/EdgeOrg/eg_cd_8.png',
			'Mapping/EdgeOrg/eg_cd_9.png',
			'Mapping/EdgeOrg/eg_cd_10.png',
			'Mapping/EdgeOrg/eg_cd_11.png',
			'Mapping/EdgeOrg/eg_cd_12.png',
			'Mapping/EdgeOrg/eg_cd_13.png',
			'Mapping/EdgeOrg/eg_cd_14.png',
			'Mapping/EdgeOrg/eg_cd_15.png',
			'Mapping/EdgeOrg/eg_cd_16.png',
			'Mapping/EdgeOrg/eg_cd_17.png',
			'Mapping/EdgeOrg/eg_cd_18.png',
			'Mapping/EdgeOrg/eg_cd_19.png',
			'Mapping/EdgeOrg/eg_cd_20.png',
			'Mapping/EdgeOrg/eg_cd_21.png',
			'Mapping/EdgeOrg/eg_cd_22.png',
			'Mapping/EdgeOrg/eg_cd_23.png',
			'Mapping/EdgeOrg/eg_cd_24.png',
			'Mapping/EdgeOrg/eg_cd_25.png',
			'Mapping/EdgeOrg/eg_cd_26.png',
			'Mapping/EdgeOrg/eg_cd_27.png',
			'Mapping/EdgeOrg/eg_cd_28.png',
			'Mapping/EdgeOrg/eg_cd_29.png',
			'Mapping/EdgeOrg/eg_cd_30.png',
			'Mapping/EdgeOrg/eg_cd_31.png',
			'Mapping/EdgeOrg/eg_cd_32.png',
			'Mapping/EdgeOrg/eg_cd_33.png',
			'Mapping/EdgeOrg/eg_cd_34.png',
			'Mapping/EdgeOrg/eg_cd_35.png',
			'Mapping/EdgeOrg/eg_cd_36.png',
			'Mapping/EdgeOrg/eg_cd_37.png',
			'Mapping/EdgeOrg/eg_cd_38.png',
			'Mapping/EdgeOrg/eg_cd_39.png',
			'Mapping/EdgeOrg/eg_cd_40.png',
			'Mapping/EdgeOrg/eg_cd_41.png',
			'Mapping/EdgeOrg/eg_cd_42.png',
			'Mapping/EdgeOrg/eg_cd_43.png',
			'Mapping/EdgeOrg/eg_cd_44.png',
			'Mapping/EdgeOrg/eg_cd_45.png'),
		"sa" = list(
			'Mapping/EdgeOrg/eg_sa_0.png',
			'Mapping/EdgeOrg/eg_sa_1.png',
			'Mapping/EdgeOrg/eg_sa_2.png',
			'Mapping/EdgeOrg/eg_sa_3.png',
			'Mapping/EdgeOrg/eg_sa_4.png',
			'Mapping/EdgeOrg/eg_sa_5.png',
			'Mapping/EdgeOrg/eg_sa_6.png',
			'Mapping/EdgeOrg/eg_sa_7.png',
			'Mapping/EdgeOrg/eg_sa_8.png',
			'Mapping/EdgeOrg/eg_sa_9.png',
			'Mapping/EdgeOrg/eg_sa_10.png',
			'Mapping/EdgeOrg/eg_sa_11.png',
			'Mapping/EdgeOrg/eg_sa_12.png',
			'Mapping/EdgeOrg/eg_sa_13.png',
			'Mapping/EdgeOrg/eg_sa_14.png',
			'Mapping/EdgeOrg/eg_sa_15.png',
			'Mapping/EdgeOrg/eg_sa_16.png',
			'Mapping/EdgeOrg/eg_sa_17.png',
			'Mapping/EdgeOrg/eg_sa_18.png',
			'Mapping/EdgeOrg/eg_sa_19.png',
			'Mapping/EdgeOrg/eg_sa_20.png',
			'Mapping/EdgeOrg/eg_sa_21.png',
			'Mapping/EdgeOrg/eg_sa_22.png',
			'Mapping/EdgeOrg/eg_sa_23.png',
			'Mapping/EdgeOrg/eg_sa_24.png',
			'Mapping/EdgeOrg/eg_sa_25.png',
			'Mapping/EdgeOrg/eg_sa_26.png',
			'Mapping/EdgeOrg/eg_sa_27.png',
			'Mapping/EdgeOrg/eg_sa_28.png',
			'Mapping/EdgeOrg/eg_sa_29.png',
			'Mapping/EdgeOrg/eg_sa_30.png',
			'Mapping/EdgeOrg/eg_sa_31.png',
			'Mapping/EdgeOrg/eg_sa_32.png',
			'Mapping/EdgeOrg/eg_sa_33.png',
			'Mapping/EdgeOrg/eg_sa_34.png',
			'Mapping/EdgeOrg/eg_sa_35.png',
			'Mapping/EdgeOrg/eg_sa_36.png',
			'Mapping/EdgeOrg/eg_sa_37.png',
			'Mapping/EdgeOrg/eg_sa_38.png'),
		"nn" = list(
			'Mapping/EdgeOrg/eg_nn_0.png',
			'Mapping/EdgeOrg/eg_nn_1.png',
			'Mapping/EdgeOrg/eg_nn_2.png',
			'Mapping/EdgeOrg/eg_nn_3.png',
			'Mapping/EdgeOrg/eg_nn_4.png',
			'Mapping/EdgeOrg/eg_nn_5.png',
			'Mapping/EdgeOrg/eg_nn_6.png',
			'Mapping/EdgeOrg/eg_nn_7.png',
			'Mapping/EdgeOrg/eg_nn_8.png',
			'Mapping/EdgeOrg/eg_nn_9.png',
			'Mapping/EdgeOrg/eg_nn_10.png',
			'Mapping/EdgeOrg/eg_nn_11.png',
			'Mapping/EdgeOrg/eg_nn_12.png',
			'Mapping/EdgeOrg/eg_nn_13.png',
			'Mapping/EdgeOrg/eg_nn_14.png',
			'Mapping/EdgeOrg/eg_nn_15.png',
			'Mapping/EdgeOrg/eg_nn_16.png',
			'Mapping/EdgeOrg/eg_nn_17.png',
			'Mapping/EdgeOrg/eg_nn_18.png',
			'Mapping/EdgeOrg/eg_nn_19.png',
			'Mapping/EdgeOrg/eg_nn_20.png',
			'Mapping/EdgeOrg/eg_nn_21.png',
			'Mapping/EdgeOrg/eg_nn_22.png',
			'Mapping/EdgeOrg/eg_nn_23.png',
			'Mapping/EdgeOrg/eg_nn_24.png',
			'Mapping/EdgeOrg/eg_nn_25.png',
			'Mapping/EdgeOrg/eg_nn_26.png',
			'Mapping/EdgeOrg/eg_nn_27.png',
			'Mapping/EdgeOrg/eg_nn_28.png',
			'Mapping/EdgeOrg/eg_nn_29.png',
			'Mapping/EdgeOrg/eg_nn_30.png',
			'Mapping/EdgeOrg/eg_nn_31.png',
			'Mapping/EdgeOrg/eg_nn_32.png',
			'Mapping/EdgeOrg/eg_nn_33.png',
			'Mapping/EdgeOrg/eg_nn_34.png',
			'Mapping/EdgeOrg/eg_nn_35.png',
			'Mapping/EdgeOrg/eg_nn_36.png',
			'Mapping/EdgeOrg/eg_nn_37.png',
			'Mapping/EdgeOrg/eg_nn_38.png',
			'Mapping/EdgeOrg/eg_nn_39.png',
			'Mapping/EdgeOrg/eg_nn_40.png',
			'Mapping/EdgeOrg/eg_nn_41.png',
			'Mapping/EdgeOrg/eg_nn_42.png'),
		"ii" = list(
			'Mapping/EdgeOrg/eg_ii_0.png',
			'Mapping/EdgeOrg/eg_ii_1.png',
			'Mapping/EdgeOrg/eg_ii_2.png',
			'Mapping/EdgeOrg/eg_ii_3.png',
			'Mapping/EdgeOrg/eg_ii_4.png',
			'Mapping/EdgeOrg/eg_ii_5.png',
			'Mapping/EdgeOrg/eg_ii_6.png',
			'Mapping/EdgeOrg/eg_ii_7.png',
			'Mapping/EdgeOrg/eg_ii_8.png',
			'Mapping/EdgeOrg/eg_ii_9.png',
			'Mapping/EdgeOrg/eg_ii_10.png',
			'Mapping/EdgeOrg/eg_ii_11.png',
			'Mapping/EdgeOrg/eg_ii_12.png',
			'Mapping/EdgeOrg/eg_ii_13.png',
			'Mapping/EdgeOrg/eg_ii_14.png',
			'Mapping/EdgeOrg/eg_ii_15.png',
			'Mapping/EdgeOrg/eg_ii_16.png',
			'Mapping/EdgeOrg/eg_ii_17.png',
			'Mapping/EdgeOrg/eg_ii_18.png',
			'Mapping/EdgeOrg/eg_ii_19.png',
			'Mapping/EdgeOrg/eg_ii_20.png',
			'Mapping/EdgeOrg/eg_ii_21.png',
			'Mapping/EdgeOrg/eg_ii_22.png',
			'Mapping/EdgeOrg/eg_ii_23.png',
			'Mapping/EdgeOrg/eg_ii_24.png',
			'Mapping/EdgeOrg/eg_ii_25.png',
			'Mapping/EdgeOrg/eg_ii_26.png',
			'Mapping/EdgeOrg/eg_ii_27.png',
			'Mapping/EdgeOrg/eg_ii_28.png',
			'Mapping/EdgeOrg/eg_ii_29.png',
			'Mapping/EdgeOrg/eg_ii_30.png',
			'Mapping/EdgeOrg/eg_ii_31.png',
			'Mapping/EdgeOrg/eg_ii_32.png',
			'Mapping/EdgeOrg/eg_ii_33.png',
			'Mapping/EdgeOrg/eg_ii_34.png',
			'Mapping/EdgeOrg/eg_ii_35.png',
			'Mapping/EdgeOrg/eg_ii_36.png',
			'Mapping/EdgeOrg/eg_ii_37.png',
			'Mapping/EdgeOrg/eg_ii_38.png',
			'Mapping/EdgeOrg/eg_ii_39.png',
			'Mapping/EdgeOrg/eg_ii_40.png',
			'Mapping/EdgeOrg/eg_ii_41.png',
			'Mapping/EdgeOrg/eg_ii_42.png',
			'Mapping/EdgeOrg/eg_ii_43.png',
			'Mapping/EdgeOrg/eg_ii_44.png'))
	elevOrgDrape = list(
		"c" = list(
			'Mapping/EdgeOrg/ep_c_0.png',
			'Mapping/EdgeOrg/ep_c_1.png',
			'Mapping/EdgeOrg/ep_c_2.png',
			'Mapping/EdgeOrg/ep_c_3.png',
			'Mapping/EdgeOrg/ep_c_4.png'),
		"s" = list(
			'Mapping/EdgeOrg/ep_s_0.png',
			'Mapping/EdgeOrg/ep_s_1.png',
			'Mapping/EdgeOrg/ep_s_2.png'),
		"n" = list(
			'Mapping/EdgeOrg/ep_n_0.png',
			'Mapping/EdgeOrg/ep_n_1.png',
			'Mapping/EdgeOrg/ep_n_2.png',
			'Mapping/EdgeOrg/ep_n_3.png'),
		"i" = list(
			'Mapping/EdgeOrg/ep_i_0.png',
			'Mapping/EdgeOrg/ep_i_1.png',
			'Mapping/EdgeOrg/ep_i_2.png',
			'Mapping/EdgeOrg/ep_i_3.png',
			'Mapping/EdgeOrg/ep_i_4.png'))
	elevOrgUnder = list(
		"c" = list(
			'Mapping/EdgeOrg/eu_c_0.png',
			'Mapping/EdgeOrg/eu_c_1.png',
			'Mapping/EdgeOrg/eu_c_2.png',
			'Mapping/EdgeOrg/eu_c_3.png',
			'Mapping/EdgeOrg/eu_c_4.png',
			'Mapping/EdgeOrg/eu_c_5.png',
			'Mapping/EdgeOrg/eu_c_6.png',
			'Mapping/EdgeOrg/eu_c_7.png',
			'Mapping/EdgeOrg/eu_c_8.png',
			'Mapping/EdgeOrg/eu_c_9.png',
			'Mapping/EdgeOrg/eu_c_10.png',
			'Mapping/EdgeOrg/eu_c_11.png',
			'Mapping/EdgeOrg/eu_c_12.png',
			'Mapping/EdgeOrg/eu_c_13.png',
			'Mapping/EdgeOrg/eu_c_14.png',
			'Mapping/EdgeOrg/eu_c_15.png',
			'Mapping/EdgeOrg/eu_c_16.png',
			'Mapping/EdgeOrg/eu_c_17.png',
			'Mapping/EdgeOrg/eu_c_18.png',
			'Mapping/EdgeOrg/eu_c_19.png',
			'Mapping/EdgeOrg/eu_c_20.png',
			'Mapping/EdgeOrg/eu_c_21.png',
			'Mapping/EdgeOrg/eu_c_22.png',
			'Mapping/EdgeOrg/eu_c_23.png',
			'Mapping/EdgeOrg/eu_c_24.png',
			'Mapping/EdgeOrg/eu_c_25.png',
			'Mapping/EdgeOrg/eu_c_26.png',
			'Mapping/EdgeOrg/eu_c_27.png',
			'Mapping/EdgeOrg/eu_c_28.png',
			'Mapping/EdgeOrg/eu_c_29.png',
			'Mapping/EdgeOrg/eu_c_30.png',
			'Mapping/EdgeOrg/eu_c_31.png',
			'Mapping/EdgeOrg/eu_c_32.png',
			'Mapping/EdgeOrg/eu_c_33.png',
			'Mapping/EdgeOrg/eu_c_34.png',
			'Mapping/EdgeOrg/eu_c_35.png',
			'Mapping/EdgeOrg/eu_c_36.png',
			'Mapping/EdgeOrg/eu_c_37.png',
			'Mapping/EdgeOrg/eu_c_38.png',
			'Mapping/EdgeOrg/eu_c_39.png',
			'Mapping/EdgeOrg/eu_c_40.png',
			'Mapping/EdgeOrg/eu_c_41.png',
			'Mapping/EdgeOrg/eu_c_42.png',
			'Mapping/EdgeOrg/eu_c_43.png',
			'Mapping/EdgeOrg/eu_c_44.png',
			'Mapping/EdgeOrg/eu_c_45.png',
			'Mapping/EdgeOrg/eu_c_46.png',
			'Mapping/EdgeOrg/eu_c_47.png',
			'Mapping/EdgeOrg/eu_c_48.png',
			'Mapping/EdgeOrg/eu_c_49.png',
			'Mapping/EdgeOrg/eu_c_50.png',
			'Mapping/EdgeOrg/eu_c_51.png',
			'Mapping/EdgeOrg/eu_c_52.png',
			'Mapping/EdgeOrg/eu_c_53.png',
			'Mapping/EdgeOrg/eu_c_54.png',
			'Mapping/EdgeOrg/eu_c_55.png',
			'Mapping/EdgeOrg/eu_c_56.png',
			'Mapping/EdgeOrg/eu_c_57.png',
			'Mapping/EdgeOrg/eu_c_58.png',
			'Mapping/EdgeOrg/eu_c_59.png',
			'Mapping/EdgeOrg/eu_c_60.png',
			'Mapping/EdgeOrg/eu_c_61.png',
			'Mapping/EdgeOrg/eu_c_62.png',
			'Mapping/EdgeOrg/eu_c_63.png'),
		"s" = list(
			'Mapping/EdgeOrg/eu_s_0.png',
			'Mapping/EdgeOrg/eu_s_1.png',
			'Mapping/EdgeOrg/eu_s_2.png',
			'Mapping/EdgeOrg/eu_s_3.png',
			'Mapping/EdgeOrg/eu_s_4.png',
			'Mapping/EdgeOrg/eu_s_5.png',
			'Mapping/EdgeOrg/eu_s_6.png',
			'Mapping/EdgeOrg/eu_s_7.png',
			'Mapping/EdgeOrg/eu_s_8.png',
			'Mapping/EdgeOrg/eu_s_9.png',
			'Mapping/EdgeOrg/eu_s_10.png',
			'Mapping/EdgeOrg/eu_s_11.png',
			'Mapping/EdgeOrg/eu_s_12.png',
			'Mapping/EdgeOrg/eu_s_13.png',
			'Mapping/EdgeOrg/eu_s_14.png',
			'Mapping/EdgeOrg/eu_s_15.png',
			'Mapping/EdgeOrg/eu_s_16.png',
			'Mapping/EdgeOrg/eu_s_17.png',
			'Mapping/EdgeOrg/eu_s_18.png',
			'Mapping/EdgeOrg/eu_s_19.png',
			'Mapping/EdgeOrg/eu_s_20.png',
			'Mapping/EdgeOrg/eu_s_21.png',
			'Mapping/EdgeOrg/eu_s_22.png',
			'Mapping/EdgeOrg/eu_s_23.png',
			'Mapping/EdgeOrg/eu_s_24.png',
			'Mapping/EdgeOrg/eu_s_25.png',
			'Mapping/EdgeOrg/eu_s_26.png',
			'Mapping/EdgeOrg/eu_s_27.png',
			'Mapping/EdgeOrg/eu_s_28.png',
			'Mapping/EdgeOrg/eu_s_29.png',
			'Mapping/EdgeOrg/eu_s_30.png'),
		"n" = list(
			'Mapping/EdgeOrg/eu_n_0.png',
			'Mapping/EdgeOrg/eu_n_1.png',
			'Mapping/EdgeOrg/eu_n_2.png',
			'Mapping/EdgeOrg/eu_n_3.png',
			'Mapping/EdgeOrg/eu_n_4.png',
			'Mapping/EdgeOrg/eu_n_5.png',
			'Mapping/EdgeOrg/eu_n_6.png',
			'Mapping/EdgeOrg/eu_n_7.png',
			'Mapping/EdgeOrg/eu_n_8.png',
			'Mapping/EdgeOrg/eu_n_9.png',
			'Mapping/EdgeOrg/eu_n_10.png',
			'Mapping/EdgeOrg/eu_n_11.png',
			'Mapping/EdgeOrg/eu_n_12.png',
			'Mapping/EdgeOrg/eu_n_13.png',
			'Mapping/EdgeOrg/eu_n_14.png',
			'Mapping/EdgeOrg/eu_n_15.png',
			'Mapping/EdgeOrg/eu_n_16.png',
			'Mapping/EdgeOrg/eu_n_17.png',
			'Mapping/EdgeOrg/eu_n_18.png',
			'Mapping/EdgeOrg/eu_n_19.png',
			'Mapping/EdgeOrg/eu_n_20.png',
			'Mapping/EdgeOrg/eu_n_21.png',
			'Mapping/EdgeOrg/eu_n_22.png',
			'Mapping/EdgeOrg/eu_n_23.png',
			'Mapping/EdgeOrg/eu_n_24.png',
			'Mapping/EdgeOrg/eu_n_25.png',
			'Mapping/EdgeOrg/eu_n_26.png',
			'Mapping/EdgeOrg/eu_n_27.png',
			'Mapping/EdgeOrg/eu_n_28.png',
			'Mapping/EdgeOrg/eu_n_29.png',
			'Mapping/EdgeOrg/eu_n_30.png',
			'Mapping/EdgeOrg/eu_n_31.png',
			'Mapping/EdgeOrg/eu_n_32.png',
			'Mapping/EdgeOrg/eu_n_33.png',
			'Mapping/EdgeOrg/eu_n_34.png',
			'Mapping/EdgeOrg/eu_n_35.png',
			'Mapping/EdgeOrg/eu_n_36.png'),
		"i" = list(
			'Mapping/EdgeOrg/eu_i_0.png',
			'Mapping/EdgeOrg/eu_i_1.png',
			'Mapping/EdgeOrg/eu_i_2.png',
			'Mapping/EdgeOrg/eu_i_3.png',
			'Mapping/EdgeOrg/eu_i_4.png',
			'Mapping/EdgeOrg/eu_i_5.png',
			'Mapping/EdgeOrg/eu_i_6.png',
			'Mapping/EdgeOrg/eu_i_7.png',
			'Mapping/EdgeOrg/eu_i_8.png',
			'Mapping/EdgeOrg/eu_i_9.png',
			'Mapping/EdgeOrg/eu_i_10.png',
			'Mapping/EdgeOrg/eu_i_11.png',
			'Mapping/EdgeOrg/eu_i_12.png',
			'Mapping/EdgeOrg/eu_i_13.png',
			'Mapping/EdgeOrg/eu_i_14.png',
			'Mapping/EdgeOrg/eu_i_15.png',
			'Mapping/EdgeOrg/eu_i_16.png',
			'Mapping/EdgeOrg/eu_i_17.png',
			'Mapping/EdgeOrg/eu_i_18.png',
			'Mapping/EdgeOrg/eu_i_19.png',
			'Mapping/EdgeOrg/eu_i_20.png',
			'Mapping/EdgeOrg/eu_i_21.png',
			'Mapping/EdgeOrg/eu_i_22.png',
			'Mapping/EdgeOrg/eu_i_23.png',
			'Mapping/EdgeOrg/eu_i_24.png',
			'Mapping/EdgeOrg/eu_i_25.png',
			'Mapping/EdgeOrg/eu_i_26.png',
			'Mapping/EdgeOrg/eu_i_27.png',
			'Mapping/EdgeOrg/eu_i_28.png',
			'Mapping/EdgeOrg/eu_i_29.png',
			'Mapping/EdgeOrg/eu_i_30.png',
			'Mapping/EdgeOrg/eu_i_31.png',
			'Mapping/EdgeOrg/eu_i_32.png',
			'Mapping/EdgeOrg/eu_i_33.png',
			'Mapping/EdgeOrg/eu_i_34.png',
			'Mapping/EdgeOrg/eu_i_35.png',
			'Mapping/EdgeOrg/eu_i_36.png',
			'Mapping/EdgeOrg/eu_i_37.png',
			'Mapping/EdgeOrg/eu_i_38.png',
			'Mapping/EdgeOrg/eu_i_39.png',
			'Mapping/EdgeOrg/eu_i_40.png',
			'Mapping/EdgeOrg/eu_i_41.png',
			'Mapping/EdgeOrg/eu_i_42.png',
			'Mapping/EdgeOrg/eu_i_43.png'))
	elevOrgLow = list(
		"c" = list(),
		"s" = list(),
		"n" = list(
			'Mapping/EdgeOrg/ev_n_0.png',
			'Mapping/EdgeOrg/ev_n_1.png'),
		"i" = list())
	elevOrgKeyFiles = list("w" = 'Mapping/EdgeOrg/ek_w.txt', "c" = 'Mapping/EdgeOrg/ek_c.txt', "s" = 'Mapping/EdgeOrg/ek_s.txt', "n" = 'Mapping/EdgeOrg/ek_n.txt', "i" = 'Mapping/EdgeOrg/ek_i.txt')
	elevOrgIndexFiles = list(
		"m1w" = 'Mapping/EdgeOrg/ix_m1_w.txt',
		"m1c" = 'Mapping/EdgeOrg/ix_m1_c.txt',
		"m1s" = 'Mapping/EdgeOrg/ix_m1_s.txt',
		"m1n" = 'Mapping/EdgeOrg/ix_m1_n.txt',
		"m1i" = 'Mapping/EdgeOrg/ix_m1_i.txt',
		"m2w" = 'Mapping/EdgeOrg/ix_m2_w.txt',
		"m2c" = 'Mapping/EdgeOrg/ix_m2_c.txt',
		"m2s" = 'Mapping/EdgeOrg/ix_m2_s.txt',
		"m2n" = 'Mapping/EdgeOrg/ix_m2_n.txt',
		"m2i" = 'Mapping/EdgeOrg/ix_m2_i.txt',
		"mx1w" = 'Mapping/EdgeOrg/ix_mx1_w.txt',
		"mx1c" = 'Mapping/EdgeOrg/ix_mx1_c.txt',
		"mx1s" = 'Mapping/EdgeOrg/ix_mx1_s.txt',
		"mx1n" = 'Mapping/EdgeOrg/ix_mx1_n.txt',
		"mx1i" = 'Mapping/EdgeOrg/ix_mx1_i.txt',
		"mx2w" = 'Mapping/EdgeOrg/ix_mx2_w.txt',
		"mx2c" = 'Mapping/EdgeOrg/ix_mx2_c.txt',
		"mx2s" = 'Mapping/EdgeOrg/ix_mx2_s.txt',
		"mx2n" = 'Mapping/EdgeOrg/ix_mx2_n.txt',
		"mx2i" = 'Mapping/EdgeOrg/ix_mx2_i.txt',
		"k1D1w" = 'Mapping/EdgeOrg/ix_k1D1_w.txt',
		"k1D1c" = 'Mapping/EdgeOrg/ix_k1D1_c.txt',
		"k1D1s" = 'Mapping/EdgeOrg/ix_k1D1_s.txt',
		"k1D1n" = 'Mapping/EdgeOrg/ix_k1D1_n.txt',
		"k1D1i" = 'Mapping/EdgeOrg/ix_k1D1_i.txt',
		"k2D1w" = 'Mapping/EdgeOrg/ix_k2D1_w.txt',
		"k2D1c" = 'Mapping/EdgeOrg/ix_k2D1_c.txt',
		"k2D1s" = 'Mapping/EdgeOrg/ix_k2D1_s.txt',
		"k2D1n" = 'Mapping/EdgeOrg/ix_k2D1_n.txt',
		"k2D1i" = 'Mapping/EdgeOrg/ix_k2D1_i.txt',
		"nD1w" = 'Mapping/EdgeOrg/ix_nD1_w.txt',
		"nD1c" = 'Mapping/EdgeOrg/ix_nD1_c.txt',
		"nD1s" = 'Mapping/EdgeOrg/ix_nD1_s.txt',
		"nD1n" = 'Mapping/EdgeOrg/ix_nD1_n.txt',
		"nD1i" = 'Mapping/EdgeOrg/ix_nD1_i.txt',
		"k1D2w" = 'Mapping/EdgeOrg/ix_k1D2_w.txt',
		"k1D2c" = 'Mapping/EdgeOrg/ix_k1D2_c.txt',
		"k1D2s" = 'Mapping/EdgeOrg/ix_k1D2_s.txt',
		"k1D2n" = 'Mapping/EdgeOrg/ix_k1D2_n.txt',
		"k1D2i" = 'Mapping/EdgeOrg/ix_k1D2_i.txt',
		"k2D2w" = 'Mapping/EdgeOrg/ix_k2D2_w.txt',
		"k2D2c" = 'Mapping/EdgeOrg/ix_k2D2_c.txt',
		"k2D2s" = 'Mapping/EdgeOrg/ix_k2D2_s.txt',
		"k2D2n" = 'Mapping/EdgeOrg/ix_k2D2_n.txt',
		"k2D2i" = 'Mapping/EdgeOrg/ix_k2D2_i.txt',
		"k3D2w" = 'Mapping/EdgeOrg/ix_k3D2_w.txt',
		"k3D2c" = 'Mapping/EdgeOrg/ix_k3D2_c.txt',
		"k3D2s" = 'Mapping/EdgeOrg/ix_k3D2_s.txt',
		"k3D2n" = 'Mapping/EdgeOrg/ix_k3D2_n.txt',
		"k3D2i" = 'Mapping/EdgeOrg/ix_k3D2_i.txt',
		"nD2w" = 'Mapping/EdgeOrg/ix_nD2_w.txt',
		"nD2c" = 'Mapping/EdgeOrg/ix_nD2_c.txt',
		"nD2s" = 'Mapping/EdgeOrg/ix_nD2_s.txt',
		"nD2n" = 'Mapping/EdgeOrg/ix_nD2_n.txt',
		"nD2i" = 'Mapping/EdgeOrg/ix_nD2_i.txt',
		"i3w" = 'Mapping/EdgeOrg/ix_i3_w.txt',
		"i3c" = 'Mapping/EdgeOrg/ix_i3_c.txt',
		"i3s" = 'Mapping/EdgeOrg/ix_i3_s.txt',
		"i3n" = 'Mapping/EdgeOrg/ix_i3_n.txt',
		"i3i" = 'Mapping/EdgeOrg/ix_i3_i.txt',
		"ni3w" = 'Mapping/EdgeOrg/ix_ni3_w.txt',
		"ni3c" = 'Mapping/EdgeOrg/ix_ni3_c.txt',
		"ni3s" = 'Mapping/EdgeOrg/ix_ni3_s.txt',
		"ni3n" = 'Mapping/EdgeOrg/ix_ni3_n.txt',
		"ni3i" = 'Mapping/EdgeOrg/ix_ni3_i.txt')
	elevOrgIndexYFiles = list(
		"m1w" = 'Mapping/EdgeOrg/iy_m1_w.txt',
		"m1c" = 'Mapping/EdgeOrg/iy_m1_c.txt',
		"m1s" = 'Mapping/EdgeOrg/iy_m1_s.txt',
		"m1n" = 'Mapping/EdgeOrg/iy_m1_n.txt',
		"m1i" = 'Mapping/EdgeOrg/iy_m1_i.txt',
		"m2w" = 'Mapping/EdgeOrg/iy_m2_w.txt',
		"m2c" = 'Mapping/EdgeOrg/iy_m2_c.txt',
		"m2s" = 'Mapping/EdgeOrg/iy_m2_s.txt',
		"m2n" = 'Mapping/EdgeOrg/iy_m2_n.txt',
		"m2i" = 'Mapping/EdgeOrg/iy_m2_i.txt',
		"mx1w" = 'Mapping/EdgeOrg/iy_mx1_w.txt',
		"mx1c" = 'Mapping/EdgeOrg/iy_mx1_c.txt',
		"mx1s" = 'Mapping/EdgeOrg/iy_mx1_s.txt',
		"mx1n" = 'Mapping/EdgeOrg/iy_mx1_n.txt',
		"mx1i" = 'Mapping/EdgeOrg/iy_mx1_i.txt',
		"mx2w" = 'Mapping/EdgeOrg/iy_mx2_w.txt',
		"mx2c" = 'Mapping/EdgeOrg/iy_mx2_c.txt',
		"mx2s" = 'Mapping/EdgeOrg/iy_mx2_s.txt',
		"mx2n" = 'Mapping/EdgeOrg/iy_mx2_n.txt',
		"mx2i" = 'Mapping/EdgeOrg/iy_mx2_i.txt',
		"k1D1w" = 'Mapping/EdgeOrg/iy_k1D1_w.txt',
		"k1D1c" = 'Mapping/EdgeOrg/iy_k1D1_c.txt',
		"k1D1s" = 'Mapping/EdgeOrg/iy_k1D1_s.txt',
		"k1D1n" = 'Mapping/EdgeOrg/iy_k1D1_n.txt',
		"k1D1i" = 'Mapping/EdgeOrg/iy_k1D1_i.txt',
		"k2D1w" = 'Mapping/EdgeOrg/iy_k2D1_w.txt',
		"k2D1c" = 'Mapping/EdgeOrg/iy_k2D1_c.txt',
		"k2D1s" = 'Mapping/EdgeOrg/iy_k2D1_s.txt',
		"k2D1n" = 'Mapping/EdgeOrg/iy_k2D1_n.txt',
		"k2D1i" = 'Mapping/EdgeOrg/iy_k2D1_i.txt',
		"nD1w" = 'Mapping/EdgeOrg/iy_nD1_w.txt',
		"nD1c" = 'Mapping/EdgeOrg/iy_nD1_c.txt',
		"nD1s" = 'Mapping/EdgeOrg/iy_nD1_s.txt',
		"nD1n" = 'Mapping/EdgeOrg/iy_nD1_n.txt',
		"nD1i" = 'Mapping/EdgeOrg/iy_nD1_i.txt',
		"k1D2w" = 'Mapping/EdgeOrg/iy_k1D2_w.txt',
		"k1D2c" = 'Mapping/EdgeOrg/iy_k1D2_c.txt',
		"k1D2s" = 'Mapping/EdgeOrg/iy_k1D2_s.txt',
		"k1D2n" = 'Mapping/EdgeOrg/iy_k1D2_n.txt',
		"k1D2i" = 'Mapping/EdgeOrg/iy_k1D2_i.txt',
		"k2D2w" = 'Mapping/EdgeOrg/iy_k2D2_w.txt',
		"k2D2c" = 'Mapping/EdgeOrg/iy_k2D2_c.txt',
		"k2D2s" = 'Mapping/EdgeOrg/iy_k2D2_s.txt',
		"k2D2n" = 'Mapping/EdgeOrg/iy_k2D2_n.txt',
		"k2D2i" = 'Mapping/EdgeOrg/iy_k2D2_i.txt',
		"k3D2w" = 'Mapping/EdgeOrg/iy_k3D2_w.txt',
		"k3D2c" = 'Mapping/EdgeOrg/iy_k3D2_c.txt',
		"k3D2s" = 'Mapping/EdgeOrg/iy_k3D2_s.txt',
		"k3D2n" = 'Mapping/EdgeOrg/iy_k3D2_n.txt',
		"k3D2i" = 'Mapping/EdgeOrg/iy_k3D2_i.txt',
		"nD2w" = 'Mapping/EdgeOrg/iy_nD2_w.txt',
		"nD2c" = 'Mapping/EdgeOrg/iy_nD2_c.txt',
		"nD2s" = 'Mapping/EdgeOrg/iy_nD2_s.txt',
		"nD2n" = 'Mapping/EdgeOrg/iy_nD2_n.txt',
		"nD2i" = 'Mapping/EdgeOrg/iy_nD2_i.txt',
		"i3w" = 'Mapping/EdgeOrg/iy_i3_w.txt',
		"i3c" = 'Mapping/EdgeOrg/iy_i3_c.txt',
		"i3s" = 'Mapping/EdgeOrg/iy_i3_s.txt',
		"i3n" = 'Mapping/EdgeOrg/iy_i3_n.txt',
		"i3i" = 'Mapping/EdgeOrg/iy_i3_i.txt',
		"ni3w" = 'Mapping/EdgeOrg/iy_ni3_w.txt',
		"ni3c" = 'Mapping/EdgeOrg/iy_ni3_c.txt',
		"ni3s" = 'Mapping/EdgeOrg/iy_ni3_s.txt',
		"ni3n" = 'Mapping/EdgeOrg/iy_ni3_n.txt',
		"ni3i" = 'Mapping/EdgeOrg/iy_ni3_i.txt')
	elevOrgIndexBFiles = list(
		"m1wg" = 'Mapping/EdgeOrg/ib_m1_wg.txt',
		"m1cd" = 'Mapping/EdgeOrg/ib_m1_cd.txt',
		"m1sa" = 'Mapping/EdgeOrg/ib_m1_sa.txt',
		"m1nn" = 'Mapping/EdgeOrg/ib_m1_nn.txt',
		"m1ii" = 'Mapping/EdgeOrg/ib_m1_ii.txt',
		"m2wg" = 'Mapping/EdgeOrg/ib_m2_wg.txt',
		"m2cd" = 'Mapping/EdgeOrg/ib_m2_cd.txt',
		"m2sa" = 'Mapping/EdgeOrg/ib_m2_sa.txt',
		"m2nn" = 'Mapping/EdgeOrg/ib_m2_nn.txt',
		"m2ii" = 'Mapping/EdgeOrg/ib_m2_ii.txt',
		"mx1wg" = 'Mapping/EdgeOrg/ib_mx1_wg.txt',
		"mx1cd" = 'Mapping/EdgeOrg/ib_mx1_cd.txt',
		"mx1sa" = 'Mapping/EdgeOrg/ib_mx1_sa.txt',
		"mx1nn" = 'Mapping/EdgeOrg/ib_mx1_nn.txt',
		"mx1ii" = 'Mapping/EdgeOrg/ib_mx1_ii.txt',
		"mx2wg" = 'Mapping/EdgeOrg/ib_mx2_wg.txt',
		"mx2cd" = 'Mapping/EdgeOrg/ib_mx2_cd.txt',
		"mx2sa" = 'Mapping/EdgeOrg/ib_mx2_sa.txt',
		"mx2nn" = 'Mapping/EdgeOrg/ib_mx2_nn.txt',
		"mx2ii" = 'Mapping/EdgeOrg/ib_mx2_ii.txt',
		"k1D1wg" = 'Mapping/EdgeOrg/ib_k1D1_wg.txt',
		"k1D1cd" = 'Mapping/EdgeOrg/ib_k1D1_cd.txt',
		"k1D1sa" = 'Mapping/EdgeOrg/ib_k1D1_sa.txt',
		"k1D1nn" = 'Mapping/EdgeOrg/ib_k1D1_nn.txt',
		"k1D1ii" = 'Mapping/EdgeOrg/ib_k1D1_ii.txt',
		"k2D1wg" = 'Mapping/EdgeOrg/ib_k2D1_wg.txt',
		"k2D1cd" = 'Mapping/EdgeOrg/ib_k2D1_cd.txt',
		"k2D1sa" = 'Mapping/EdgeOrg/ib_k2D1_sa.txt',
		"k2D1nn" = 'Mapping/EdgeOrg/ib_k2D1_nn.txt',
		"k2D1ii" = 'Mapping/EdgeOrg/ib_k2D1_ii.txt',
		"nD1wg" = 'Mapping/EdgeOrg/ib_nD1_wg.txt',
		"nD1cd" = 'Mapping/EdgeOrg/ib_nD1_cd.txt',
		"nD1sa" = 'Mapping/EdgeOrg/ib_nD1_sa.txt',
		"nD1nn" = 'Mapping/EdgeOrg/ib_nD1_nn.txt',
		"nD1ii" = 'Mapping/EdgeOrg/ib_nD1_ii.txt',
		"k1D2wg" = 'Mapping/EdgeOrg/ib_k1D2_wg.txt',
		"k1D2cd" = 'Mapping/EdgeOrg/ib_k1D2_cd.txt',
		"k1D2sa" = 'Mapping/EdgeOrg/ib_k1D2_sa.txt',
		"k1D2nn" = 'Mapping/EdgeOrg/ib_k1D2_nn.txt',
		"k1D2ii" = 'Mapping/EdgeOrg/ib_k1D2_ii.txt',
		"k2D2wg" = 'Mapping/EdgeOrg/ib_k2D2_wg.txt',
		"k2D2cd" = 'Mapping/EdgeOrg/ib_k2D2_cd.txt',
		"k2D2sa" = 'Mapping/EdgeOrg/ib_k2D2_sa.txt',
		"k2D2nn" = 'Mapping/EdgeOrg/ib_k2D2_nn.txt',
		"k2D2ii" = 'Mapping/EdgeOrg/ib_k2D2_ii.txt',
		"k3D2wg" = 'Mapping/EdgeOrg/ib_k3D2_wg.txt',
		"k3D2cd" = 'Mapping/EdgeOrg/ib_k3D2_cd.txt',
		"k3D2sa" = 'Mapping/EdgeOrg/ib_k3D2_sa.txt',
		"k3D2nn" = 'Mapping/EdgeOrg/ib_k3D2_nn.txt',
		"k3D2ii" = 'Mapping/EdgeOrg/ib_k3D2_ii.txt',
		"nD2wg" = 'Mapping/EdgeOrg/ib_nD2_wg.txt',
		"nD2cd" = 'Mapping/EdgeOrg/ib_nD2_cd.txt',
		"nD2sa" = 'Mapping/EdgeOrg/ib_nD2_sa.txt',
		"nD2nn" = 'Mapping/EdgeOrg/ib_nD2_nn.txt',
		"nD2ii" = 'Mapping/EdgeOrg/ib_nD2_ii.txt',
		"i3wg" = 'Mapping/EdgeOrg/ib_i3_wg.txt',
		"i3cd" = 'Mapping/EdgeOrg/ib_i3_cd.txt',
		"i3sa" = 'Mapping/EdgeOrg/ib_i3_sa.txt',
		"i3nn" = 'Mapping/EdgeOrg/ib_i3_nn.txt',
		"i3ii" = 'Mapping/EdgeOrg/ib_i3_ii.txt',
		"ni3wg" = 'Mapping/EdgeOrg/ib_ni3_wg.txt',
		"ni3cd" = 'Mapping/EdgeOrg/ib_ni3_cd.txt',
		"ni3sa" = 'Mapping/EdgeOrg/ib_ni3_sa.txt',
		"ni3nn" = 'Mapping/EdgeOrg/ib_ni3_nn.txt',
		"ni3ii" = 'Mapping/EdgeOrg/ib_ni3_ii.txt')
	elevOrgIndexZFiles = list(
		"m1c" = 'Mapping/EdgeOrg/iz_m1_c.txt',
		"m1s" = 'Mapping/EdgeOrg/iz_m1_s.txt',
		"m1n" = 'Mapping/EdgeOrg/iz_m1_n.txt',
		"m1i" = 'Mapping/EdgeOrg/iz_m1_i.txt',
		"m2c" = 'Mapping/EdgeOrg/iz_m2_c.txt',
		"m2s" = 'Mapping/EdgeOrg/iz_m2_s.txt',
		"m2n" = 'Mapping/EdgeOrg/iz_m2_n.txt',
		"m2i" = 'Mapping/EdgeOrg/iz_m2_i.txt',
		"mx1c" = 'Mapping/EdgeOrg/iz_mx1_c.txt',
		"mx1s" = 'Mapping/EdgeOrg/iz_mx1_s.txt',
		"mx1n" = 'Mapping/EdgeOrg/iz_mx1_n.txt',
		"mx1i" = 'Mapping/EdgeOrg/iz_mx1_i.txt',
		"mx2c" = 'Mapping/EdgeOrg/iz_mx2_c.txt',
		"mx2s" = 'Mapping/EdgeOrg/iz_mx2_s.txt',
		"mx2n" = 'Mapping/EdgeOrg/iz_mx2_n.txt',
		"mx2i" = 'Mapping/EdgeOrg/iz_mx2_i.txt',
		"k1D1c" = 'Mapping/EdgeOrg/iz_k1D1_c.txt',
		"k1D1s" = 'Mapping/EdgeOrg/iz_k1D1_s.txt',
		"k1D1n" = 'Mapping/EdgeOrg/iz_k1D1_n.txt',
		"k1D1i" = 'Mapping/EdgeOrg/iz_k1D1_i.txt',
		"k2D1c" = 'Mapping/EdgeOrg/iz_k2D1_c.txt',
		"k2D1s" = 'Mapping/EdgeOrg/iz_k2D1_s.txt',
		"k2D1n" = 'Mapping/EdgeOrg/iz_k2D1_n.txt',
		"k2D1i" = 'Mapping/EdgeOrg/iz_k2D1_i.txt',
		"nD1c" = 'Mapping/EdgeOrg/iz_nD1_c.txt',
		"nD1s" = 'Mapping/EdgeOrg/iz_nD1_s.txt',
		"nD1n" = 'Mapping/EdgeOrg/iz_nD1_n.txt',
		"nD1i" = 'Mapping/EdgeOrg/iz_nD1_i.txt',
		"k1D2c" = 'Mapping/EdgeOrg/iz_k1D2_c.txt',
		"k1D2s" = 'Mapping/EdgeOrg/iz_k1D2_s.txt',
		"k1D2n" = 'Mapping/EdgeOrg/iz_k1D2_n.txt',
		"k1D2i" = 'Mapping/EdgeOrg/iz_k1D2_i.txt',
		"k2D2c" = 'Mapping/EdgeOrg/iz_k2D2_c.txt',
		"k2D2s" = 'Mapping/EdgeOrg/iz_k2D2_s.txt',
		"k2D2n" = 'Mapping/EdgeOrg/iz_k2D2_n.txt',
		"k2D2i" = 'Mapping/EdgeOrg/iz_k2D2_i.txt',
		"k3D2c" = 'Mapping/EdgeOrg/iz_k3D2_c.txt',
		"k3D2s" = 'Mapping/EdgeOrg/iz_k3D2_s.txt',
		"k3D2n" = 'Mapping/EdgeOrg/iz_k3D2_n.txt',
		"k3D2i" = 'Mapping/EdgeOrg/iz_k3D2_i.txt',
		"nD2c" = 'Mapping/EdgeOrg/iz_nD2_c.txt',
		"nD2s" = 'Mapping/EdgeOrg/iz_nD2_s.txt',
		"nD2n" = 'Mapping/EdgeOrg/iz_nD2_n.txt',
		"nD2i" = 'Mapping/EdgeOrg/iz_nD2_i.txt',
		"i3c" = 'Mapping/EdgeOrg/iz_i3_c.txt',
		"i3s" = 'Mapping/EdgeOrg/iz_i3_s.txt',
		"i3n" = 'Mapping/EdgeOrg/iz_i3_n.txt',
		"i3i" = 'Mapping/EdgeOrg/iz_i3_i.txt',
		"ni3c" = 'Mapping/EdgeOrg/iz_ni3_c.txt',
		"ni3s" = 'Mapping/EdgeOrg/iz_ni3_s.txt',
		"ni3n" = 'Mapping/EdgeOrg/iz_ni3_n.txt',
		"ni3i" = 'Mapping/EdgeOrg/iz_ni3_i.txt')
	elevOrgRecFiles = list("w" = 'Mapping/EdgeOrg/er_w.txt', "c" = 'Mapping/EdgeOrg/er_c.txt', "s" = 'Mapping/EdgeOrg/er_s.txt', "n" = 'Mapping/EdgeOrg/er_n.txt', "i" = 'Mapping/EdgeOrg/er_i.txt')
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
	elevOrgMat = list(
		"grass" = list("#0e2803", 36, 100, 8, 0, list(0, 0, 0, 0, 0, 0, 0, 0, 622, 0, 0, 0, 798, 529, 0, 0, 1394, 1546, 0, 0, 0, 2125, 0, 0, 1523, 1523, 0, 1618, 0, 2763, 0, 0, 0, 1900, 46, 2455, 1180, 0, 0, 328, 1315, 160, 2292, 0, 0, 2299, 1013, 0, 1752, 536, 0, 0, 0, 1755, 0, 748, 1655, 0, 784, 0, 0, 0, 0, 1245, 0, 0, 0, 2342, 531, 0, 0, 2329, 1115, 0, 0, 155, 1006, 0, 0, 2231, 1269, 0, 992, 1250, 0, 0, 530, 512, 0, 784, 2823, 0, 0, 0, 474, 1011, 0, 0, 889, 0, 0, 0, 2083, 0, 0, 2223, 31, 0, 0, 175, 1818, 0, 0, 752, 1461, 0, 2325, 0, 0, 0, 1940, 610, 0, 0, 1033, 2369, 0, 0, 1179, 1705, 0, 1002, 1577, 0, 0, 0, 2223, 598, 0, 0, 2739, 1114, 0, 429, 1319, 495, 2424, 0, 0, 0, 2698, 901, 0, 49, 1809, 129, 2812, 1579, 0, 0, 65, 1787, 0, 0, 3395, 0, 739, 1910, 0, 0, 650, 368, 0, 32, 3590, 357, 2083, 0, 0, 0, 2821, 0, 163, 1263, 0, 556, 569, 0, 0, 1488, 1790, 0, 1133, 1887, 0, 0, 0, 725, 514, 0, 0, 3046, 0, 222, 1417, 0, 0, 0, 1190, 292, 0, 1082, 1085, 0, 988, 713, 0, 0, 0, 3675, 0, 0, 871, 331, 0, 152, 2465, 0, 2344, 1759, 0, 0, 2381, 510, 0, 1599, 717, 0, 628, 1598, 0, 0, 0, 657, 2230, 0, 0, 612, 264, 689, 836, 0, 0, 3182, 516, 0, 1064, 2216, 0, 0, 0, 3663, 0, 0, 263, 573, 0, 0, 1286, 1241, 0, 0, 1887, 452, 0, 361, 710, 0, 0, 2527, 855, 0, 1239, 468, 0, 0, 975, 711, 0, 0, 1171, 0, 0, 221, 584, 0, 0, 526, 306, 408, 574, 0, 0, 0, 1244, 164, 1666, 1101, 0, 2293, 503, 0, 2227, 856, 728, 2529, 0, 1719, 346, 0, 0, 817, 1180, 0, 0, 1127, 311, 0, 0, 2555, 1055, 143, 1666, 0, 0, 2064, 0, 0, 2231, 323, 0, 206, 1587, 0, 0, 0, 1758, 0, 0, 0, 797, 1133, 0, 293, 760, 0, 1438, 0, 0, 0, 657, 814, 0, 0, 0, 2465, 551, 2257, 620, 1499, 0, 0, 0, 808, 137, 1092, 2526, 0, 0, 3483, 144, 0, 156, 907, 0, 0, 0, 1319, 0, 2169, 11, 0, 1048, 570, 0, 297, 2849, 0, 0, 0, 1086, 479, 192, 231, 0, 1521, 760, 0, 228, 1764, 0, 2932, 11, 0, 530, 868, 0, 2117, 0, 0, 0, 776, 1267, 0, 2817, 0, 0, 0, 56, 1025, 0, 200, 769, 0, 0, 2834, 930, 0, 0, 152, 859, 0, 451, 0, 1000, 740, 0, 1696, 0, 0, 0, 0, 1085, 236, 0, 0, 966, 0, 0, 0, 77, 3260, 0, 1741, 1881, 103, 1292, 0, 0, 1434, 0, 0, 0, 940, 252, 0, 2377, 296, 0, 0, 1069, 858, 0, 0, 970, 1810, 0, 0, 1871, 99, 0, 0, 968, 2712, 0, 0, 2044, 875, 0, 0, 1766, 0, 0, 88, 1161, 0, 1810, 1154, 0, 0, 3336, 0), 1000, 0, 4, 1.2, 0.95, 0.75, 115, 195, 50, 46, 120, 20),
		"snow" = list("#444a54", 170, 186, 210, 1, list(1000, 1000, 1000, 1000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 3000, 3000, 2000, 2000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 2000, 1000, 1000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 2000, 2000, 2000), 3000, 1, 4, 1.25, 1.05, 0.7, -1, -1, -1, 205, 216, 228),
		"dirt" = list("#110802", 42, 20, 4, 0, list(1000, 1000, 1000, 1000, 1594, 1939, 2083, 2108, 2188, 2483, 2596, 2569, 2393, 1990, 2558, 2808, 2743, 2318, 1000, 2651, 3301, 3317, 3100, 3347, 3402, 3280, 2947, 2489, 2802, 2713, 2347, 2948, 3223, 3293, 3178, 2843, 2294, 2366, 2348, 2237, 2433, 2839, 3009, 3004, 2824, 2402, 1956, 2020, 1937, 2082, 2552, 2762, 2805, 2696, 2610, 2911, 3022, 2977, 3099, 3330, 3395, 3308, 3049, 2534, 2154, 1951, 2134, 2887, 3082, 2901, 2179, 1000, 2419, 2967, 3023, 2639, 1000, 2025, 2310, 2325, 2082, 1000, 1322, 2017, 2224, 2479, 3019, 3258, 3293, 3134, 3151, 3202, 2993, 2414, 1982, 2217, 2223, 2000, 1028, 2526, 3207, 3441, 3362, 2935, 2413, 3003, 3252, 3275, 3080, 2588, 2304, 2563, 2582, 2371, 2595, 2867, 2979, 2960, 2805, 2981, 3001, 2720, 2002, 2837, 3221, 3384, 3370, 3178, 2749, 2919, 3205, 3093, 2495, 2352, 2920, 3113, 3039, 2664, 2448, 3122, 3282, 3052, 2232, 1306, 1849, 2042, 2091, 2017, 1786, 1876, 2076, 2083, 1943, 2293, 2432, 2423, 2263, 1871, 1000, 2788, 3202, 3165, 2645, 2507, 2704, 2709, 2678, 3327, 3423, 3046, 2638, 2778, 2703, 2938, 3103, 3058, 2788, 2144, 1890, 2077, 2633, 3090, 3312, 3367, 3267, 2988, 2429, 2648, 2892, 2879, 2604, 1840, 1000, 2648, 3023, 2858, 1892, 2062, 2354, 2457, 2414, 2209, 2347, 2716, 2846, 2791, 2530, 2194, 2662, 2829, 2781, 2499, 1780, 2199, 2389, 2443, 2376, 2605, 3133, 3375, 3417, 3271, 2895, 2348, 2443, 2435, 2530, 3174, 3415, 3378, 3049, 2207, 1672, 2332, 2544, 2510, 2694, 3170, 3110, 2448, 2659, 2855, 2562, 1000, 1100, 2272, 2509, 2409, 1862, 1000, 1976, 2249, 2327, 2246, 2800, 3128, 3110, 2734, 1440, 2443, 3322, 3404, 2804, 2808, 3000, 2872, 2334, 2550, 2889, 2787, 2446, 2767, 2854, 2742, 2384, 1276, 2011, 2608, 2706, 2415, 1000, 2854, 3280, 3284, 2869, 1864, 2009, 2038, 1960, 1743, 1417, 2325, 2563, 2622, 3105, 3316, 3328, 3147, 2711, 2863, 3266, 3324, 3067, 2323, 2070, 2002, 2224, 2757, 2874, 2666, 2802, 2967, 2982, 2851, 2536, 2021, 2089, 2058, 1915, 2232, 2610, 2795, 2847, 2778, 2570, 2736, 2755, 2293, 2835, 3384, 3352, 2705, 2257, 2265, 2099, 1636, 1738, 2443, 2666, 2621, 2279, 2131, 2134, 2056, 1879, 2062, 2093, 2527, 2822, 2942, 2922, 2754, 2389, 2575, 2782, 2848, 2789, 2591, 2186, 2441, 2507, 2337, 1789, 1951, 2179, 2243, 2170, 2588, 2883, 2931, 2752, 2254, 1939, 2279, 2267, 1958, 2263, 2390, 2394, 3015, 3265, 3268, 3027, 2421, 2235, 2036, 1222, 1000, 2311, 2602, 2530, 2022, 2311, 2544, 2610, 2531, 2279, 2276, 2407, 2349, 2073, 2061, 3122, 3388, 3175, 2258, 2183, 2123, 1890, 1000, 2557, 2978, 2857, 2014, 1789, 2119, 2244, 2228, 2065, 2057, 2160, 2157, 2315, 3137, 3377, 3229, 2591, 1000, 2791, 3351, 3297, 2566, 2323, 2302, 1982, 2223, 2465, 2526, 2430, 2136, 2262, 2189, 2580, 2924, 3072, 3069, 2912, 2557, 1763, 2544, 2900, 2873, 2442, 2002, 2303, 2982, 3321, 3464, 3446, 3262, 2866, 3039, 3024, 2674, 2164, 2378, 2418, 2300, 1967, 2765, 3210, 3344, 3223, 2799, 2539, 2955, 3108, 3058, 2789, 2153, 1000, 2211, 2515, 2415, 1764, 1000, 1374, 2405, 2625, 2463, 2430, 2969, 3190, 3191, 2974, 2745, 3105, 3256, 3240, 3055, 3081, 3209, 3110, 2747, 2850, 3055, 2917, 2331, 1787, 2608, 2825, 2690), 2500, 1, 4, 0.9, 1.0, 1.1, 172, 120, 62, 62, 34, 10),
		"sand" = list("#402f1c", 160, 118, 70, 1, list(4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 4000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 4000, 4000, 4000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 1000, 1000, 2000, 3000, 4000, 4000, 4000, 3000, 3000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 3000, 3000, 4000, 4000, 4000, 4000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 4000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 4000, 4000, 4000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 1000, 1000, 1000, 2000, 3000, 3000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 1000, 1000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 1000, 1000, 1000, 1000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 1000, 1000, 3000, 3000, 4000, 4000, 4000, 4000, 3000, 3000, 2000, 2000, 2000, 3000, 3000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 2000, 2000, 2000, 2000, 3000, 3000, 3000, 3000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 3000, 4000, 4000, 3000, 3000, 2000, 1000, 1000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 3000), 3000, 1, 5, 0.85, 1.0, 1.15, 255, 232, 170, 196, 152, 98),
		"ice" = list("#172844", 58, 100, 170, 0, list(1888, 1839, 1790, 1741, 1692, 1642, 1593, 1753, 1912, 2072, 2231, 2391, 2550, 2710, 2870, 2697, 2525, 2353, 2181, 2009, 1837, 1665, 1778, 1892, 2005, 2119, 2233, 2346, 2468, 2590, 2712, 2833, 2955, 2908, 2861, 2813, 2766, 2554, 2342, 2130, 1918, 1706, 1494, 1282, 1515, 1749, 1982, 2215, 2449, 2682, 2499, 2315, 2131, 1947, 1763, 1862, 1961, 2060, 2159, 2258, 2357, 2169, 1980, 1792, 1603, 1608, 1614, 1619, 1625, 1630, 1636, 1641, 1647, 1819, 1991, 2164, 2336, 2508, 2681, 2645, 2609, 2573, 2537, 2501, 2465, 2430, 2398, 2366, 2335, 2303, 2272, 2240, 2209, 2134, 2060, 1985, 1911, 1836, 1762, 1688, 1683, 1679, 1675, 1670, 1666, 1633, 1600, 1567, 1534, 1502, 1505, 1508, 1511, 1515, 1518, 1459, 1399, 1340, 1280, 1221, 1278, 1336, 1393, 1451, 1509, 1566, 1624, 1597, 1571, 1544, 1518, 1491, 1557, 1623, 1690, 1756, 1771, 1786, 1801, 1816, 1832, 1847, 1862, 1877, 1993, 2109, 2225, 2341, 2457, 2574, 2543, 2512, 2481, 2450, 2420, 2353, 2286, 2220, 2153, 2087, 2020, 1953, 2083, 2212, 2342, 2471, 2446, 2421, 2395, 2370, 2345, 2320, 2294, 2269, 2289, 2310, 2330, 2350, 2371, 2391, 2411, 2432, 2256, 2081, 1906, 1730, 1555, 1379, 1204, 1333, 1462, 1591, 1721, 1850, 1979, 2108, 2204, 2301, 2397, 2493, 2590, 2686, 2693, 2700, 2707, 2714, 2721, 2727, 2734, 2741, 2617, 2494, 2370, 2246, 2122, 1998, 1875, 1906, 1937, 1969, 2000, 2031, 2062, 2094, 2018, 1942, 1867, 1791, 1715, 1639, 1563, 1591, 1618, 1646, 1673, 1701, 1728, 1933, 2138, 2343, 2548, 2587, 2627, 2667, 2707, 2488, 2268, 2049, 1830, 1956, 2083, 2209, 2335, 2461, 2512, 2562, 2613, 2663, 2713, 2764, 2814, 2705, 2595, 2486, 2377, 2267, 2158, 2278, 2398, 2518, 2638, 2759, 2879, 2810, 2741, 2672, 2603, 2534, 2465, 2397, 2328, 2406, 2484, 2562, 2640, 2718, 2796, 2874, 2564, 2254, 1944, 1634, 1324, 1307, 1290, 1273, 1257, 1240, 1223, 1206, 1190, 1396, 1603, 1809, 2016, 2222, 2429, 2351, 2272, 2194, 2115, 2037, 1959, 1880, 1802, 1659, 1516, 1374, 1231, 1088, 1146, 1204, 1263, 1321, 1379, 1580, 1781, 1982, 2183, 2385, 2586, 2605, 2624, 2643, 2663, 2682, 2701, 2566, 2430, 2295, 2160, 2025, 1889, 1754, 1619, 1667, 1716, 1764, 1813, 1852, 1891, 1930, 1970, 2009, 2154, 2299, 2445, 2590, 2500, 2410, 2320, 2230, 2140, 2050, 1960, 2087, 2214, 2341, 2468, 2596, 2723, 2850, 2797, 2745, 2692, 2639, 2587, 2534, 2481, 2429, 2191, 1953, 1714, 1476, 1238, 1000, 1221, 1441, 1662, 1882, 2103, 2323, 2544, 2764, 2759, 2755, 2750, 2745, 2740, 2736, 2731, 2545, 2359, 2174, 1988, 1802, 1973, 2144, 2314, 2485, 2656, 2827, 2997, 2801, 2604, 2407, 2210, 2257, 2304, 2350, 2397, 2444, 2491, 2537, 2584, 2549, 2514, 2480, 2445, 2410, 2467, 2524, 2582, 2639, 2697, 2754, 2740, 2726, 2712, 2698, 2683, 2667, 2652, 2636, 2621, 2606, 2590, 2575, 2498, 2421, 2344, 2267, 2190, 2113, 2036, 1959, 2103, 2248, 2392, 2536, 2680, 2824, 2482, 2140, 1798, 1455, 1113, 1313, 1512, 1712, 1911, 2111, 2239, 2368, 2496, 2624, 2752, 2608, 2463, 2319, 2175, 2030, 1886, 1741, 1811, 1881, 1951, 2021, 2091, 1948, 1806, 1663, 1520, 1377, 1542, 1708, 1873, 2039, 2204, 2369, 2535, 2586, 2637, 2688, 2739, 2791, 2727, 2662, 2598, 2534, 2470, 2406), 1500, 1, 3, 1.2, 1.0, 0.8, 236, 246, 255, 82, 130, 194),
		"stone" = list("#130d07", 48, 32, 18, 0, list(1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000), 0, 1, 1, 1.0, 1.0, 1.05, 186, 166, 132, 70, 54, 36),
		"none" = list("#000000", -1, -1, -1, 0, list(1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000), 0, 1, 1, 1.0, 1.0, 1.0, -1, -1, -1, -1, -1, -1))

/proc/ElevOrgStyle(turf/S)
	if(!S || ElevAt(S) <= 0 || !ElevNaturalTop(S) || ElevStairTurf(S))
		return ""
	if(ElevFaceFlat(S, ElevFaceStyleAt(S, S)))
		return ""
	var/turf/B = locate(S.x, S.y - 1, S.z)
	if(B && ElevAt(B) <= 0 && BuildIsCliffTurf(B))
		return ""
	switch(ElevEdgeMat(S))
		if("snow")
			return "n"
		if("ice")
			return "i"
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

/proc/ElevOrgBotShade(D, k)
	var/bk = "[D]_[k]"
	var/res = elevOrgBotShadeCache[bk]
	if(res)
		return res
	var/icon/I = icon(ElevOrgBotIcon(D, k))
	I.MapColors(0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
	res = fcopy_rsc(I)
	elevOrgBotShadeCache[bk] = res
	return res

/proc/ElevStairShade(turf/G, lay, list/fresh)
	var/list/fi = ElevFaceInfo(G)
	if(!fi)
		return
	var/turf/CT = fi[6]
	var/fam = ElevFaceFlat(CT, ElevFaceStyleFor(G, CT)) ? "fw" : "fs"
	var/image/SP = ElevShadePiece("[fam][fi[2]]_[fi[3]]cc", lay + 0.00002)
	if(SP)
		fresh += SP
	if(ElevOrgStyle(CT))
		var/image/BI = image(ElevOrgBotShade(fi[2], fi[3]))
		BI.layer = lay + 0.00004
		fresh += BI

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

/proc/ElevOrgCutLayer(icon/F, ic, st)
	var/icon/M = icon(ic, st)
	M.MapColors(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 1, 1, 1, 1)
	F.Blend(M, ICON_MULTIPLY)

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
	if(WS && BuildMaterialFor(WS) != "Water")
		WS = null
	var/v = WS ? A.x % 3 : 0
	var/fk ="[fsty]|[D]|[v]|[S.icon]|[S.icon_state]|[S.dir]|[ElevAt(S)]|[WS ? "[WS.icon]|[WS.icon_state]|[WS.dir]|[ElevAt(WS)]|[ElevStyleCode(WS)]" : "-"]"
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
	var/lipk = 0
	var/list/teeth = ElevOrgToothRows()
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
				ElevOrgCutLayer(F, 'Mapping/Elevation/elev_base.dmi', "bm[bkey]")
			if(elevBaseStates["bb[bkey]"])
				ElevOrgTexLayer(F, WS, 'Mapping/Elevation/elev_base.dmi', "bb[bkey]", 1)
			if(elevBaseStates["bd[bkey]"])
				F.Blend(icon('Mapping/Elevation/elev_base.dmi', "bd[bkey]"), ICON_OVERLAY)
		if(k == 1 && ElevFrays(S) && ElevEdgeMat(S) == "grass")
			var/drew = 0
			lipk = 1
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
			if(k == 1 && lipk && teeth[x + 1] > 0)
				var/icon/N = icon(C)
				N.DrawBox(null, 1, 33 - teeth[x + 1], 32, 32)
				R.Insert(N, "n1x[x]")
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

/proc/ElevOrgConvLedge(turf/A, L, sty, x, y)
	var/n = 1
	for(var/sd in list(-1, 1))
		var/turf/T = A
		var/cx = x
		var/list/on = ElevOrgConvOn(T, L, sty)
		while(n < 3)
			cx += sd
			if(cx < 0 || cx > 31)
				T = locate(T.x + sd, T.y, T.z)
				if(!T)
					break
				on = ElevOrgConvOn(T, L, sty)
				cx = (cx < 0) ? 31 : 0
			if(!on || !on["[cx],[y]"])
				break
			n++
	return n

/proc/ElevOrgToothRows()
	if(elevOrgToothRows)
		return elevOrgToothRows
	ElevStatesInit()
	var/list/t = new/list(32)
	for(var/x = 1 to 32)
		t[x] = 0
	for(var/q = 0 to 1)
		for(var/pre in list("mv", "bv"))
			var/st = "[pre][q]otctf1"
			if(!elevLipStates[st])
				continue
			var/icon/I = icon('Mapping/Elevation/elev_lip.dmi', st)
			for(var/x = 1 to 32)
				for(var/y = 1 to 32)
					var/c = I.GetPixel(x, y)
					if(!c || (length(c) >= 9 && copytext(c, 8) == "00"))
						continue
					if(33 - y > t[x])
						t[x] = 33 - y
	elevOrgToothRows = t
	return t

/proc/ElevOrgFTHas(FT, st)
	var/fk = "\ref[FT]"
	var/list/ss = elevOrgFTStates[fk]
	if(!ss)
		ss = ElevStateSet(FT)
		elevOrgFTStates[fk] = ss
	return ss[st] ? 1 : 0

/proc/ElevOrgCellMask(list/sheets, id)
	if(!sheets || id <= 0)
		return null
	var/s = round((id - 1) / 512) + 1
	if(s > sheets.len)
		return null
	var/ci = (id - 1) % 512
	return BuildBakeMask(sheets[s], BuildOrgSheetX(ci), BuildOrgSheetY(ci), 0, 32, 32)

/proc/ElevOrgRowTile(turf/G, yy)
	var/dy = (yy < 0) ? 1 : -round(yy / 32)
	return locate(G.x, G.y + dy, G.z)

/proc/ElevOrgFootFx(turf/G, L, sty, turf/S)
	var/list/holes = list()
	var/list/paint = list()
	var/list/bnc = list()
	for(var/dy = 0 to 1)
		var/turf/T = locate(G.x, G.y - dy, G.z)
		if(!T)
			continue
		var/list/ft = ElevOrgFeet(T, L, sty, S)
		if(!ft || !ft.len)
			continue
		var/turf/PS = ElevOrgMem(T, L) ? T : S
		for(var/list/f in ft)
			var/x = f[1]
			var/y = f[2] + dy * 32
			var/he = f[5]
			for(var/q = 0 to he - 1)
				var/yy = y - 1 - q
				if(yy < 0 || yy > 31)
					continue
				if(f[3])
					paint["[x],[yy]"] = PS
				else
					holes["[x],[yy]"] = 1
			if(he < f[6] && (he || !f[3]))
				var/yb = y - he
				var/turf/RT = ElevOrgRowTile(G, yb)
				var/list/BM = ElevOrgMatInfo(ElevEdgeMat(RT))
				if(BM[2] >= 0)
					var/list/BP = ElevOrgPal(RT)
					var/br = BP ? BP[7] : BM[2]
					var/bg = BP ? BP[8] : BM[3]
					var/bb = BP ? BP[9] : BM[4]
					if(yb - 1 >= 0 && yb - 1 <= 31)
						bnc["[x],[yb - 1]"] = rgb(br, bg, bb, 77)
					if(he + 2 <= f[6] && yb - 2 >= 0 && yb - 2 <= 31)
						bnc["[x],[yb - 2]"] = rgb(br, bg, bb, 36)
	return list(holes, paint, bnc)

/proc/ElevOrgFaceImages(turf/G, L, sty, list/pieces, list/cpx, list/ctx, list/fx, slay, list/fresh, turf/S)
	if(!pieces.len && !cpx.len)
		return
	var/did = (ctx && ctx.len >= 12) ? ctx[10] : 0
	var/uid = (ctx && ctx.len >= 12) ? ctx[11] : 0
	var/vid = (ctx && ctx.len >= 12) ? ctx[12] : 0
	if(!S || !S.icon)
		did = 0
	var/list/holes = fx[1]
	var/list/paint = fx[2]
	var/list/bnc = fx[3]
	var/edid = ctx ? ctx[2] : 0
	var/lid = ctx ? ctx[3] : 0
	var/ka = ctx ? max(0, min(255, round(51 * ctx[5] + 0.5))) : 51
	var/list/kp = list()
	for(var/list/PC in pieces)
		kp += "\ref[PC[1]]:[PC[4]]:[PC[2]]:[PC[3]]:[PC[5]]"
	for(var/pk in cpx)
		kp += "c[pk]=[cpx[pk]]"
	kp += "e[edid]:[ka]:l[lid]:g[G.icon]|[G.icon_state]|[G.dir]"
	kp += "z[did]:[uid]:[vid]:[did ? "[S.icon]|[S.icon_state]|[S.dir]" : "-"]"
	for(var/hk in holes)
		kp += "h[hk]"
	for(var/pk in paint)
		var/turf/PS = paint[pk]
		kp += "p[pk]=[PS.icon]|[PS.icon_state]|[PS.dir]"
	for(var/bk in bnc)
		kp += "b[bk]=[bnc[bk]]"
	var/ck = md5(jointext(kp, ";"))
	var/list/res = elevOrgStripCache[ck]
	if(!res)
		var/icon/C = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
		for(var/pi = pieces.len, pi >= 1, pi--)
			var/list/PC = pieces[pi]
			var/st = "k[PC[4]]x[PC[2]]"
			if(PC[5] && ElevOrgFTHas(PC[1], "n1x[PC[2]]"))
				st = "n1x[PC[2]]"
			if(ElevOrgFTHas(PC[1], st))
				C.Blend(icon(PC[1], st), ICON_OVERLAY, 1, 1 - PC[3])
		for(var/pk in cpx)
			var/cp = findtext(pk, ",")
			C.DrawBox(cpx[pk], text2num(copytext(pk, 1, cp)) + 1, 32 - text2num(copytext(pk, cp + 1)))
		var/icon/CA = icon(C)
		CA.MapColors(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0)
		if(edid > 0 && ka > 0)
			var/icon/E = ElevOrgCellMask(elevOrgDark[sty], edid)
			if(E)
				E.MapColors(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ka / 255, 0, 0, 0, 0)
				E.Blend(CA, ICON_MULTIPLY)
				C.Blend(E, ICON_OVERLAY)
		if(uid > 0)
			var/icon/UM = ElevOrgCellMask(elevOrgUnder[sty], uid)
			if(UM)
				UM.MapColors(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
				UM.Blend(CA, ICON_MULTIPLY)
				C.Blend(UM, ICON_OVERLAY)
		if(did > 0)
			var/icon/DMK = ElevOrgCellMask(elevOrgDrape[sty], did)
			if(DMK)
				var/icon/DT = icon(S.icon, S.icon_state, S.dir, 1)
				var/lit = ElevOrgDrapeLit(ElevEdgeMat(S))
				if(lit != 1)
					DT.MapColors(lit, 0, 0, 0, lit, 0, 0, 0, lit)
				DT.Blend(DMK, ICON_MULTIPLY)
				C.Blend(DT, ICON_OVERLAY)
		if(vid > 0)
			var/icon/VM = ElevOrgCellMask(elevOrgLow[sty], vid)
			if(VM)
				VM.Blend(rgb(183, 201, 215), ICON_MULTIPLY)
				VM.MapColors(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0.8, 0, 0, 0, 0)
				C.Blend(VM, ICON_OVERLAY)
		if(bnc.len)
			var/icon/BB = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
			for(var/bk in bnc)
				var/cp = findtext(bk, ",")
				BB.DrawBox(bnc[bk], text2num(copytext(bk, 1, cp)) + 1, 32 - text2num(copytext(bk, cp + 1)))
			BB.Blend(CA, ICON_MULTIPLY)
			C.Blend(BB, ICON_OVERLAY)
		var/icon/LM = (lid > 0) ? ElevOrgCellMask(elevOrgLift[sty], lid) : null
		var/list/cut = list()
		var/list/srcs = list()
		for(var/pk in paint)
			var/turf/PS = paint[pk]
			var/sk = "[PS.icon]|[PS.icon_state]|[PS.dir]"
			var/list/grp = srcs[sk]
			if(!grp)
				grp = list(PS)
				srcs[sk] = grp
			grp += pk
		for(var/hk in holes)
			var/lifted = 0
			if(LM)
				var/cp = findtext(hk, ",")
				var/lc = LM.GetPixel(text2num(copytext(hk, 1, cp)) + 1, 32 - text2num(copytext(hk, cp + 1)))
				if(lc && (length(lc) < 9 || copytext(lc, 8) != "00"))
					lifted = 1
			if(!lifted)
				cut += hk
				continue
			var/sk = "[G.icon]|[G.icon_state]|[G.dir]"
			var/list/grp = srcs[sk]
			if(!grp)
				grp = list(G)
				srcs[sk] = grp
			grp += hk
		for(var/sk in srcs)
			var/list/grp = srcs[sk]
			var/turf/PS = grp[1]
			if(!PS.icon)
				continue
			var/icon/PM = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
			for(var/gi = 2 to grp.len)
				var/pk = grp[gi]
				var/cp = findtext(pk, ",")
				PM.DrawBox("#ffffff", text2num(copytext(pk, 1, cp)) + 1, 32 - text2num(copytext(pk, cp + 1)))
			var/icon/TI = icon(PS.icon, PS.icon_state, PS.dir, 1)
			TI.Blend(PM, ICON_MULTIPLY)
			C.Blend(TI, ICON_OVERLAY)
		if(LM)
			var/icon/CL = icon(C)
			CL.MapColors(1.25, 0, 0, 0, 1.25, 0, 0, 0, 1.25, 8 / 255, 8 / 255, 8 / 255)
			CL.Blend(LM, ICON_MULTIPLY)
			C.Blend(CL, ICON_OVERLAY)
		if(cut.len)
			var/icon/HM = icon('Mapping/EdgeOrg/org_cols.dmi', "white")
			for(var/hk in cut)
				var/cp = findtext(hk, ",")
				HM.DrawBox(null, text2num(copytext(hk, 1, cp)) + 1, 32 - text2num(copytext(hk, cp + 1)))
			C.Blend(HM, ICON_MULTIPLY)
		var/cres = null
		if(cpx.len)
			var/icon/CM = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
			var/icon/NM = icon('Mapping/EdgeOrg/org_cols.dmi', "white")
			for(var/pk in cpx)
				var/cp = findtext(pk, ",")
				var/px = text2num(copytext(pk, 1, cp)) + 1
				var/py = 32 - text2num(copytext(pk, cp + 1))
				CM.DrawBox("#ffffff", px, py)
				NM.DrawBox(null, px, py)
			var/icon/CC = icon(C)
			CC.Blend(CM, ICON_MULTIPLY)
			cres = fcopy_rsc(CC)
			C.Blend(NM, ICON_MULTIPLY)
		res = list(pieces.len ? fcopy_rsc(C) : null, cres)
		elevOrgStripCache[ck] = res
	if(res[1])
		var/image/SP = image(res[1])
		SP.layer = slay
		fresh += SP
	if(res[2])
		var/image/CI = image(res[2])
		CI.layer = ElevLayer(L, 7)
		fresh += CI

/proc/ElevOrgPixMap(list/K, list/pieces, list/on, list/trims)
	var/list/pm = new/list(1024)
	for(var/i = 1 to 1024)
		pm[i] = 0
	for(var/list/PC in pieces)
		var/x = PC[2]
		for(var/y = max(0, PC[3]) to min(31, PC[3] + 31))
			pm[y * 32 + x + 1] = 1
	if(K)
		var/list/runs = K[1]
		for(var/i = 1, i + 6 <= runs.len, i += 7)
			var/x = runs[i]
			for(var/y = runs[i + 2] to runs[i + 1] - 1)
				pm[y * 32 + x + 1] = 2
	if(on)
		for(var/pk in on)
			if(text2ascii(pk, 1) == 114)
				continue
			var/cp = findtext(pk, ",")
			var/x = text2num(copytext(pk, 1, cp))
			var/y = text2num(copytext(pk, cp + 1))
			pm[y * 32 + x + 1] = (trims && trims[pk]) ? 0 : 1
	return pm

/proc/ElevOrgMColor(FT, px)
	var/mk = "\ref[FT]:[px]"
	if(mk in elevOrgMColCache)
		return elevOrgMColCache[mk]
	var/c = null
	if(ElevOrgFTHas(FT, "m[px]"))
		var/icon/M = icon(FT, "m[px]")
		c = M.GetPixel(px + 1, 1)
	elevOrgMColCache[mk] = c
	return c

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
			ElevOrgSidePaint(G, L, sty, cfg, GS, fresh)
	var/list/ctx = ElevOrgTileCtx(G, L, sty)
	if(ctx && ctx[1])
		var/SF = ElevOrgCellFilter(elevOrgShade[sty], ctx[1])
		if(SF)
			var/list/HM = ElevOrgMatInfo(ElevEdgeMat(G))
			var/list/HP = ElevOrgPal(G)
			var/image/SI = image('Mapping/EdgeOrg/org_cols.dmi', null, "white")
			SI.color = HP ? rgb(round(HP[7] * 0.4 + 0.5), round(HP[8] * 0.4 + 0.5), round(HP[9] * 0.4 + 0.5)) : HM[1]
			SI.layer = base + 0.0001
			SI.filters = SF
			fresh += SI
	var/slay = base + 0.0002 + (world.maxy - G.y) * (0.0007 / max(1, world.maxy))
	var/list/lim = new/list(32)
	for(var/i = 1 to 32)
		lim[i] = 31
	var/open = 32
	var/list/pieces = list()
	var/turf/SB = locate(G.x, G.y - 1, G.z)
	var/nostrip = (mem && SB && ElevStairTurf(SB)) ? 1 : 0
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
		if(ElevOrgMem(A, L) && !ElevOrgStyle(A))
			break
		var/list/KA = (j == 0) ? K : ElevOrgKey(sty, BuildOrgWindowX(A), BuildOrgWindowY(A), cfgA)
		if(!KA)
			continue
		var/DA = ElevOrgDepthAt(A, L)
		var/list/runs = KA[1]
		var/FT = null
		var/list/onA = ElevOrgConvOn(A, L, sty)
		for(var/i = runs.len - 6, i >= 1, i -= 7)
			var/x = runs[i]
			if(lim[x + 1] < 0)
				continue
			var/bp = runs[i + 1] - 32 * j
			var/lo = max(bp, 0)
			var/hi = min(lim[x + 1], bp + 32 * DA - 1)
			var/cv = (onA && onA["r[x],[runs[i + 2]]"] && ElevOrgConvLedge(A, L, sty, x, runs[i + 1] - 1) >= 3) ? 1 : 0
			if(!runs[i + 3] && lo <= hi && !(nostrip && j == 0))
				for(var/t = 1 to DA)
					var/y0 = bp + 32 * (t - 1)
					if(y0 + 31 < lo || y0 > hi)
						continue
					if(!FT)
						FT = ElevOrgFT(A, S, L, DA)
					if(FT)
						pieces += list(list(FT, x, y0, t, (cv && t == 1) ? 1 : 0))
			var/na = runs[i + 2] - 32 * j - 1
			if(cv)
				var/list/teeth = ElevOrgToothRows()
				na = bp + teeth[x + 1] - 1
			if(na < lim[x + 1])
				lim[x + 1] = na
				if(na < 0)
					open--
	var/list/cpx = list()
	var/list/pmap = null
	if(K)
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
		if(on && on.len)
			var/FTG = ElevOrgFT(G, S, L, D)
			if(FTG)
				for(var/pk in on)
					if(text2ascii(pk, 1) == 114 || holes[pk])
						continue
					var/cp = findtext(pk, ",")
					var/c = ElevOrgMColor(FTG, text2num(copytext(pk, 1, cp)))
					if(c)
						cpx[pk] = c
		pmap = ElevOrgPixMap(K, pieces, on, holes)
	else
		pmap = ElevOrgPixMap(null, pieces, null, null)
	var/list/fx = ElevOrgFootFx(G, L, sty, S)
	ElevOrgFaceImages(G, L, sty, pieces, cpx, ctx, fx, slay, fresh, S)
	ElevOrgContactImage(G, L, sty, S, pmap, fx, fresh)
	ElevOrgBevImage(G, L, sty, S, ctx, fresh)

/proc/ElevOrgSidePaint(turf/G, L, sty, cfg, turf/GS, list/fresh)
	for(var/list/o in list(list(0, 1, "gn"), list(1, 0, "ge"), list(-1, 0, "gw"), list(0, -1, "gs")))
		var/turf/O = locate(G.x + o[1], G.y + o[2], G.z)
		if(!O || O == GS || ElevAt(O) >= L)
			continue
		var/SF = ElevOrgFilter("t", sty, G, cfg, 1)
		if(!SF)
			continue
		var/image/SI = ElevOrgTurfImage(O, ELEV_TOP_LAYER + 0.0001)
		SI.filters = SF
		SI.filters += filter(type = "alpha", icon = ElevMaskIcon('Mapping/EdgeOrg/org_cols.dmi', o[3]))
		fresh += SI

/proc/ElevEdgeMat(turf/T)
	if(!T)
		return "none"
	switch(BuildMaterialFor(T))
		if("Grass")
			if(T.icon_state == "Grass19" || T.icon_state == "Grass20")
				return "snow"
			return "grass"
		if("Dirt")
			return "dirt"
		if("Sand")
			return "sand"
		if("Ice")
			return "ice"
		if("Stone")
			return "stone"
		if("Water")
			return "water"
	return "none"

/proc/ElevOrgMatInfo(mat)
	ElevOrgSheetInit()
	var/list/M = elevOrgMat[mat]
	return M ? M : elevOrgMat["none"]

/proc/ElevOrgApronH(mat, gx, oq)
	var/list/A = ElevOrgMatInfo(mat)
	var/list/tab = A[6]
	var/v2 = 510 * tab[(gx % tab.len) + 1] + 2 * A[7] * oq - 255 * A[7]
	v2 = max(A[8] * 510000, min(A[9] * 510000, v2))
	return round((v2 + 255000) / 510000)

/proc/ElevOrgRecords(sty, rid)
	if(rid <= 0)
		return null
	var/list/lines = elevOrgRecLines[sty]
	if(!lines)
		var/f = elevOrgRecFiles[sty]
		lines = f ? splittext(file2text(f), "\n") : list()
		elevOrgRecLines[sty] = lines
	return (rid <= lines.len) ? lines[rid] : null

/proc/ElevOrgCtxIdsY(cls, sty, w, idx, nbits)
	var/ik = "y[cls][sty]"
	var/txt = elevOrgIndexText[ik]
	if(!txt)
		var/f = elevOrgIndexYFiles["[cls][sty]"]
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

/proc/ElevOrgCtxIdsZ(cls, sty, w, idx, nbits)
	var/ik = "z[cls][sty]"
	var/txt = elevOrgIndexText[ik]
	if(!txt)
		var/f = elevOrgIndexZFiles ? elevOrgIndexZFiles["[cls][sty]"] : null
		if(!f)
			return null
		txt = file2text(f)
		elevOrgIndexText[ik] = txt
	var/pos = (w * (1 << nbits) + idx) * 9 + 1
	if(pos + 8 > length(txt))
		return null
	var/a = (text2ascii(txt, pos) - 48) + (text2ascii(txt, pos + 1) - 48) * 64 + (text2ascii(txt, pos + 2) - 48) * 4096
	var/b = (text2ascii(txt, pos + 3) - 48) + (text2ascii(txt, pos + 4) - 48) * 64 + (text2ascii(txt, pos + 5) - 48) * 4096
	var/c = (text2ascii(txt, pos + 6) - 48) + (text2ascii(txt, pos + 7) - 48) * 64 + (text2ascii(txt, pos + 8) - 48) * 4096
	return list(a, b, c)

/proc/ElevOrgDrapeLit(mat)
	switch(mat)
		if("sand")
			return 1.05
		if("snow")
			return 1.03
		if("ice")
			return 1.1
	return 1

/proc/ElevOrgBevId(cls, sty, bm, w, idx, nbits)
	var/ik = "b[cls][sty][bm]"
	var/txt = elevOrgIndexText[ik]
	if(!txt)
		var/f = elevOrgIndexBFiles["[cls][sty][bm]"]
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

/proc/ElevOrgTileCtx(turf/T, L, sty)
	if(!T)
		return null
	if(elevOrgCtxVer != elevGeomVer)
		elevOrgCtxCache = list()
		elevOrgFeetCache = list()
		elevOrgCtxVer = elevGeomVer
	var/ck = "[T.x],[T.y],[T.z],[L],[sty]"
	var/list/hit = elevOrgCtxCache[ck]
	if(hit)
		return hit.len ? hit : null
	var/list/res = list()
	var/list/cl = ElevOrgClassify(T, L, ElevOrgDepthAt(T, L))
	if(cl)
		var/w = ((BuildOrgWindowY(T) - cl[3] + 40) % 4) * 4 + BuildOrgWindowX(T)
		var/list/a = ElevOrgCtxIds(cl[1], sty, w, cl[2], cl[5])
		var/list/b = ElevOrgCtxIdsY(cl[1], sty, w, cl[2], cl[5])
		var/list/z = ElevOrgCtxIdsZ(cl[1], sty, w, cl[2], cl[5])
		res = list(a ? a[1] : 0, a ? a[2] : 0, b ? b[1] : 0, b ? b[2] : 0, cl[4], cl[1], w, cl[2], cl[5], z ? z[1] : 0, z ? z[2] : 0, z ? z[3] : 0)
	elevOrgCtxCache[ck] = res
	return res.len ? res : null

/proc/ElevOrgFeet(turf/T, L, sty, turf/S)
	var/list/ctx = ElevOrgTileCtx(T, L, sty)
	if(!ctx || !ctx[4])
		return null
	var/mat = ElevEdgeMat(T)
	if(mat == "water")
		return null
	var/mtop = ElevEdgeMat(ElevOrgMem(T, L) ? T : S)
	var/ck = "[T.x],[T.y],[T.z],[L],[sty],[mat],[mtop]"
	var/list/hit = elevOrgFeetCache[ck]
	if(hit)
		return hit
	var/list/out = list()
	var/rs = ElevOrgRecords(sty, ctx[4])
	if(rs)
		var/n = length(rs)
		for(var/i = 1, i + 5 <= n, i += 6)
			var/c1 = text2ascii(rs, i) - 48
			var/c2 = text2ascii(rs, i + 1) - 48
			var/c4 = text2ascii(rs, i + 3) - 48
			var/oq = (text2ascii(rs, i + 2) - 48) | ((c4 & 3) << 6)
			var/seg = text2ascii(rs, i + 4) - 48
			var/top = (c1 >> 5) & 1
			var/foot = (c2 >> 5) & 1
			var/he = 0
			if(foot)
				he = min(ElevOrgApronH(top ? mtop : mat, T.x * 32 + (c1 & 31), oq), seg)
			out += list(list(c1 & 31, c2 & 31, top, foot, he, seg, text2ascii(rs, i + 5) - 48, (c4 >> 2) & 3))
	elevOrgFeetCache[ck] = out
	return out

/proc/ElevOrgContactImage(turf/G, L, sty, turf/S, list/pm, list/fx, list/fresh)
	var/list/raw = null
	for(var/ty = -1 to 1)
		for(var/tx = -1 to 1)
			var/turf/T = locate(G.x + tx, G.y + ty, G.z)
			if(!T)
				continue
			var/list/ft = ElevOrgFeet(T, L, sty, S)
			if(!ft || !ft.len)
				continue
			var/xo = tx * 32
			var/yo = -ty * 32
			var/mtop = ElevEdgeMat(ElevOrgMem(T, L) ? T : S)
			for(var/list/f in ft)
				var/he = f[5]
				var/top = f[3]
				if(he >= f[6] || !(f[7] & (1 << he)) || (!he && top))
					continue
				var/x = f[1] + xo
				if(x < -2 || x > 33)
					continue
				var/y = f[2]
				var/yb = y - he
				if(yb + yo > 31 || yb + yo + 3 < 0)
					continue
				var/list/MR = ElevOrgMatInfo((he && top) ? mtop : ElevEdgeMat(ElevOrgRowTile(T, yb + 1)))
				var/list/prof = MR[5] ? elevOrgContactShort : elevOrgContactLong
				for(var/q = 0 to prof.len - 1)
					var/yy = yb + q
					if(yy == y && top)
						break
					if(yy > y + f[8])
						break
					var/Y = yy + yo
					if(Y < 0 || Y > 31)
						continue
					if(!raw)
						raw = new/list(1152)
						for(var/i = 1 to 1152)
							raw[i] = 0
					var/k = Y * 36 + x + 3
					if(raw[k] < prof[q + 1])
						raw[k] = prof[q + 1]
	if(!raw)
		return
	var/list/acc = new/list(1024)
	for(var/i = 1 to 1024)
		acc[i] = 0
	var/any = 0
	for(var/Y = 0 to 31)
		for(var/xi = 1 to 36)
			var/v = raw[Y * 36 + xi]
			if(v <= 0)
				continue
			var/x = xi - 3
			for(var/d = -2 to 2)
				var/X = x + d
				if(X < 0 || X > 31)
					continue
				acc[Y * 32 + X + 1] += v * elevOrgContactBlur[d + 3]
				any = 1
	if(!any)
		return
	var/list/holes = fx[1]
	var/list/paint = fx[2]
	var/list/MG = ElevOrgMatInfo(ElevEdgeMat(G))
	var/list/cells = list()
	for(var/Y = 0 to 31)
		for(var/X = 0 to 31)
			var/v = acc[Y * 32 + X + 1]
			if(v <= 0)
				continue
			var/key = "[X],[Y]"
			var/turf/PS = paint[key]
			if(pm[Y * 32 + X + 1] && !PS && !holes[key])
				continue
			var/list/M = PS ? ElevOrgMatInfo(ElevEdgeMat(PS)) : MG
			var/r = max(0, min(255, round(255 * (1 - v * M[10]) + 0.5)))
			var/g = max(0, min(255, round(255 * (1 - v * M[11]) + 0.5)))
			var/b = max(0, min(255, round(255 * (1 - v * M[12]) + 0.5)))
			if(r >= 255 && g >= 255 && b >= 255)
				continue
			cells[key] = rgb(r, g, b)
	if(!cells.len)
		return
	var/list/kp = list()
	for(var/k in cells)
		kp += "[k]=[cells[k]]"
	var/ck = md5(jointext(kp, ";"))
	var/res = elevOrgContactCache[ck]
	if(!res)
		var/icon/C = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
		for(var/k in cells)
			var/cp = findtext(k, ",")
			C.DrawBox(cells[k], text2num(copytext(k, 1, cp)) + 1, 32 - text2num(copytext(k, cp + 1)))
		res = fcopy_rsc(C)
		elevOrgContactCache[ck] = res
	var/image/I = image(res)
	I.layer = ElevLayer(L, 4) + 0.0001
	I.blend_mode = BLEND_MULTIPLY
	fresh += I

/proc/ElevOrgBevCode(sty, mat)
	switch(sty)
		if("w")
			return (mat == "snow") ? "n" : "g"
		if("c")
			return "d"
		if("s")
			return (mat == "ice") ? "i" : "a"
		if("n")
			return "n"
		if("i")
			return "i"
	return null

/proc/ElevOrgBevMat(bm)
	switch(bm)
		if("g")
			return "grass"
		if("n")
			return "snow"
		if("d")
			return "dirt"
		if("a")
			return "sand"
		if("i")
			return "ice"
	return "none"

/proc/ElevOrgPal(turf/T)
	if(!T)
		return null
	var/mat = ElevEdgeMat(T)
	var/list/M = ElevOrgMatInfo(mat)
	if(M[2] < 0)
		return null
	if(mat == "snow")
		return list(M[13], M[14], M[15], M[16], M[17], M[18], M[2], M[3], M[4])
	if(!T.icon)
		return null
	var/pk = "\ref[T.icon]|[T.icon_state]"
	if(pk in elevOrgPalCache)
		return elevOrgPalCache[pk]
	var/list/P = ElevOrgPalDerive(icon(T.icon, T.icon_state, SOUTH, 1))
	elevOrgPalCache[pk] = P
	return P

/proc/ElevOrgPalDerive(icon/I)
	var/list/R = list()
	var/list/Gn = list()
	var/list/Bl = list()
	var/list/Lv = list()
	for(var/y = I.Height(), y >= 1, y--)
		for(var/x = 1 to I.Width())
			var/c = I.GetPixel(x, y)
			if(!c)
				continue
			var/list/v = rgb2num(c)
			if(v.len > 3 && v[4] <= 0)
				continue
			R += v[1]
			Gn += v[2]
			Bl += v[3]
			Lv += 299 * v[1] + 587 * v[2] + 114 * v[3]
	var/n = Lv.len
	if(!n)
		return null
	var/mi = 1
	for(var/i = 2 to n)
		if(Lv[i] < Lv[mi])
			mi = i
	var/k = round(n * 95 / 100)
	var/lo = 0
	var/hi = 255000
	while(lo < hi)
		var/md = round((lo + hi) / 2)
		var/cnt = 0
		for(var/lv in Lv)
			if(lv <= md)
				cnt++
		if(cnt > k)
			hi = md
		else
			lo = md + 1
	var/want = k
	for(var/lv in Lv)
		if(lv < lo)
			want--
	var/pi = 0
	for(var/i = 1 to n)
		if(Lv[i] == lo)
			if(!want)
				pi = i
				break
			want--
	if(!pi)
		return null
	return list(min(255, R[pi] + 32), min(255, Gn[pi] + 32), min(255, Bl[pi] + 32), R[mi], Gn[mi], Bl[mi], round((R[mi] * 3 + 2) / 4), round((Gn[mi] * 3 + 2) / 4), round((Bl[mi] * 3 + 2) / 4))

/proc/ElevOrgBevImage(turf/G, L, sty, turf/S, list/ctx, list/fresh)
	if(!ctx)
		return
	var/turf/TT = ElevOrgMem(G, L) ? G : S
	var/bm = ElevOrgBevCode(sty, ElevEdgeMat(TT))
	if(!bm)
		return
	var/list/ids = ElevOrgBevId(ctx[6], sty, bm, ctx[7], ctx[8], ctx[9])
	if(!ids || (!ids[1] && !ids[2]))
		return
	var/list/FM = ElevOrgMatInfo(ElevOrgBevMat(bm))
	var/list/PT = ElevOrgPal(TT)
	var/list/PG = ElevOrgPal(G)
	var/hic = null
	if(PT && PT[1] >= 0)
		hic = rgb(PT[1], PT[2], PT[3])
	else if(!PT && FM[13] >= 0)
		hic = rgb(FM[13], FM[14], FM[15])
	var/midc = PT ? rgb(PT[4], PT[5], PT[6]) : rgb(FM[16], FM[17], FM[18])
	var/gsh = PG ? rgb(PG[7], PG[8], PG[9]) : (PT ? rgb(PT[7], PT[8], PT[9]) : rgb(FM[2], FM[3], FM[4]))
	var/bk = "[sty][bm]|[ids[1]]|[ids[2]]|[hic]|[midc]|[gsh]"
	var/res = elevOrgBevCache[bk]
	if(!res)
		var/icon/M = icon('Mapping/EdgeOrg/org_cols.dmi', "blank")
		if(ids[1] > 0)
			if(hic)
				var/icon/H = ElevOrgCellMask(elevOrgBev["[sty][bm]"], ids[1])
				if(H)
					H.Blend(hic, ICON_MULTIPLY)
					M.Blend(H, ICON_OVERLAY)
			var/icon/D = ElevOrgCellMask(elevOrgBevMid["[sty][bm]"], ids[1])
			if(D)
				D.Blend(midc, ICON_MULTIPLY)
				M.Blend(D, ICON_OVERLAY)
		if(ids[2] > 0)
			var/icon/R = ElevOrgCellMask(elevOrgRing["[sty][bm]"], ids[2])
			if(R)
				R.Blend(gsh, ICON_MULTIPLY)
				M.Blend(R, ICON_OVERLAY)
		res = fcopy_rsc(M)
		elevOrgBevCache[bk] = res
	var/image/I = image(res)
	I.layer = ElevLayer(L, 6)
	fresh += I

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
	if(ElevStairTurf(G))
		if(levels.len || ElevCoverOf(G))
			var/image/ST = image(ElevTexIcon(G, hg), null, ElevTexState(G, hg))
			ST.dir = G.dir
			ST.layer = ElevLayer(ELEV_MAX, 9) + 0.0004
			fresh += ST
			ElevStairShade(G, ST.layer, fresh)
		return
	for(var/lk in levels)
		ElevOrgLevel(G, text2num(lk), levels[lk], fresh)

/proc/ElevBelowFoot(turf/T)
	if(!T)
		return 0
	var/list/af = ElevFaceInfo(locate(T.x, T.y + 1, T.z))
	return (af && af[3] == af[2]) ? 1 : 0

/proc/ElevOrgWrapEnd(turf/T, list/fi, dx)
	var/code = ElevWrapEnd(T, fi, dx)
	if(code != "j")
		return code
	var/list/nf = ElevFaceInfo(locate(T.x + dx, T.y, T.z))
	return (nf && nf[1] == fi[1]) ? "w" : "j"

/proc/ElevOrgInnerSuffix(turf/T, side, top, sameOk)
	if(!T)
		return ""
	var/turf/A = locate(T.x, T.y + 1, T.z)
	var/list/af = ElevFaceInfo(A)
	if(!af || af[3] != af[2])
		return ""
	var/sfx = (sameOk && af[1] == top) ? "s" : ""
	if(ElevWrapEnd(A, af, (side == "R") ? -1 : 1) == "x")
		sfx += "x"
	return sfx

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
				if(ElevOrgStyle(fn[6]))
					ElevFoamTrio("ox", "[ElevStyleCode(WS)][N.x % 3][ElevOrgWrapEnd(N, fn, -1)][ElevOrgWrapEnd(N, fn, 1)]", T, ElevLayer(fn[1], 9), fresh)
				else
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
				var/yorg = ElevOrgStyle(nf[6]) ? 1 : 0
				ElevFoamTrio(yorg ? "oy" : "y", tkey, T, yorg ? ElevLayer(nf[1], 9) : ELEV_FOAM_LAYER, fresh)
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
		if(!ElevOrgStyle(T) && !ElevRoofTurf(T))
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
	for(var/image/BI in fresh)
		BuildBakeImage(BI)
	T.overlays += fresh
	T.elevOverlays = fresh

/proc/ElevOrgWhyNot(turf/S)
	if(!S || ElevAt(S) <= 0)
		return "not raised"
	var/m = BuildMaterialFor(S)
	var/pst = ElevFaceStyleAt(S, S)
	var/info = "type [S.type], material [m ? m : "unflagged"], painted cliff style [pst]"
	if(!ElevNaturalTop(S))
		return "top material is not grass, dirt, sand, ice or water, so it keeps the square rim ([info])"
	if(ElevStairTurf(S))
		return "stairs or ladder turf ([info])"
	if(ElevFaceFlat(S, pst))
		return "painted with custom wall art, so it keeps flat walls and the square rim ([info])"
	var/turf/B = locate(S.x, S.y - 1, S.z)
	if(B && ElevAt(B) <= 0 && BuildIsCliffTurf(B))
		return "a placed cliff turf sits directly below it ([info])"
	return "edge style [BuildEdgeStyleFor(m)] has no organic set ([info])"

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
		usr << "  organic rim: [osty ? "yes (style [osty], config [ElevOrgCfg(T, h)], window [BuildOrgWindowX(T)],[BuildOrgWindowY(T)], depth [ElevOrgDepthAt(T, h)])" : "no - [ElevOrgWhyNot(T)]"]"
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
