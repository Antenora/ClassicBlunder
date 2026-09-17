#define CUSTOM_MANIFEST "Mapping/Custom/manifest.txt"

var/global/list/customDefs
var/global/list/customDefsByName
var/global/customDefsDirty = 0
obj/Turfs/CustomObj1/var/custom_def = ""

/datum/build_custom_def
	var
		kind = "turf"
		name = ""
		fname = ""
		icon_state = ""
		density = 0
		opacity = 0
		roof = 0
		layerv = 0
		pixelX = 0
		pixelY = 0
		edge = 0
		hash = ""
		creator = ""
		material = ""
		cliff = 0
		stairs = 0
		profile = ""
		fixture = ""
		tmp/fhash = ""

/proc/BuildCustomLoad()
	if(customDefs)
		return customDefs
	customDefs = list()
	customDefsByName = null
	if(!fexists(CUSTOM_MANIFEST))
		return customDefs
	var/t = file2text(CUSTOM_MANIFEST)
	if(!t)
		return customDefs
	for(var/line in splittext(t, "\n"))
		if(!length(line))
			continue
		var/list/f = splittext(line, "\t")
		if(f.len < 13)
			continue
		var/datum/build_custom_def/D = new
		D.kind = f[1]
		D.name = BuildDmmUnescape(f[2])
		D.fname = BuildDmmUnescape(f[3])
		D.icon_state = BuildDmmUnescape(f[4])
		D.density = text2num(f[5]) || 0
		D.opacity = text2num(f[6]) || 0
		D.roof = text2num(f[7]) || 0
		D.layerv = text2num(f[8]) || 0
		D.pixelX = text2num(f[9]) || 0
		D.pixelY = text2num(f[10]) || 0
		D.edge = text2num(f[11]) || 0
		D.hash = f[12]
		D.creator = BuildDmmUnescape(f[13])
		if(f.len >= 14 && (f[14] in buildMaterialNames))
			D.material = f[14]
		if(f.len >= 15)
			D.cliff = text2num(f[15]) || 0
		if(f.len >= 16)
			D.stairs = text2num(f[16]) || 0
		if(f.len >= 17 && (f[17] in SurfaceProfiles()))
			D.profile = f[17]
		if(f.len >= 18)
			D.fixture = BuildCustomFixtureValid(f[18])
		if(!fexists(D.fname))
			continue
		customDefs += D
	return customDefs

/proc/BuildCustomSave()
	var/list/lines = list()
	for(var/datum/build_custom_def/D in customDefs)
		lines += jointext(list(D.kind, BuildDmmEscape(D.name), BuildDmmEscape(D.fname), BuildDmmEscape(D.icon_state), "[D.density]", "[D.opacity]", "[D.roof]", "[D.layerv]", "[D.pixelX]", "[D.pixelY]", "[D.edge]", D.hash, BuildDmmEscape(D.creator), D.material, "[D.cliff]", "[D.stairs]", D.profile, D.fixture), "\t")
	if(fexists(CUSTOM_MANIFEST))
		fdel(CUSTOM_MANIFEST)
	text2file(jointext(lines, "\n"), CUSTOM_MANIFEST)

/proc/BuildCustomEntry(datum/build_custom_def/D)
	var/datum/build_entry/E = new
	E.name = "-[D.name]-"
	E.iconF = file(D.fname)
	E.icon_state = D.icon_state
	E.Creates = (D.kind == "obj") ? /obj/Turfs/CustomObj1 : /turf/CustomTurf
	E.category = BUILD_CAT_CUSTOM
	E.isCustom = 1
	E.cDensity = D.density
	E.cOpacity = D.opacity
	E.cRoof = D.roof
	E.cLayer = D.layerv
	E.cPixelX = D.pixelX
	E.cPixelY = D.pixelY
	E.cDef = D.name
	BuildEntryFit(E)
	return E

var/global/list/customDefIconCache = list()

/proc/BuildCustomDefForIcon(ic, st, kind = "turf")
	BuildCustomLoad()
	var/it = "[ic]"
	var/known = 0
	for(var/datum/build_custom_def/KD in customDefs)
		if(KD.kind == kind && KD.fname == it)
			known = 1
			break
	var/ck = known ? "[kind]|[it]|[st]" : "[kind]|h:[md5(ic)]|[st]"
	var/hit = customDefIconCache[ck]
	if(hit)
		return (hit == "none") ? null : hit
	var/list/cands = list()
	for(var/datum/build_custom_def/D in customDefs)
		if(D.kind == kind && D.fname == it)
			cands += D
	if(!cands.len)
		var/h = md5(ic)
		if(h)
			for(var/datum/build_custom_def/D in customDefs)
				if(D.kind == kind && D.hash == h)
					cands += D
			if(!cands.len)
				for(var/datum/build_custom_def/D in customDefs)
					if(D.kind != kind)
						continue
					if(!length(D.fhash) && fexists(D.fname))
						D.fhash = md5(file(D.fname))
					if(D.fhash == h)
						cands += D
	var/datum/build_custom_def/best
	for(var/datum/build_custom_def/D in cands)
		if("[D.icon_state]" == "[st]")
			best = D
			break
	if(!best && cands.len && length("[st]"))
		var/list/real = icon_states(ic)
		if(!real || !("[st]" in real))
			for(var/datum/build_custom_def/D in cands)
				if(!length("[D.icon_state]"))
					best = D
					break
	customDefIconCache[ck] = best ? best : "none"
	return best

/proc/BuildCustomFixtureValid(v)
	if(v == "stairs" || v == "ladder" || v == "bridge")
		return v
	return ""

/proc/BuildCustomFixture(datum/build_custom_def/D)
	if(!D)
		return ""
	if(length(D.fixture))
		return D.fixture
	return D.stairs ? "stairs" : ""

/proc/BuildCustomFixtureLabel(datum/build_custom_def/D)
	switch(BuildCustomFixture(D))
		if("stairs")
			return "STAIRS"
		if("ladder")
			return "LADDER"
		if("bridge")
			return "BRIDGE"
	return "NONE"

/proc/BuildCustomStamp(atom/A, datum/build_custom_def/D)
	if(!A)
		return
	var/old = A:custom_def
	if(D)
		A:custom_def = D.name
		if(A.name == initial(A.name) || (length(old) && A.name == old))
			A.name = D.name
		return
	A:custom_def = ""
	if(length(old) && A.name == old)
		A.name = initial(A.name)

/proc/BuildCustomNameOf(atom/A)
	var/datum/build_custom_def/D
	if(istype(A, /turf/CustomTurf))
		D = BuildCustomDefForTurf(A)
	else if(istype(A, /obj/Turfs/CustomObj1))
		D = BuildCustomDefForObj(A)
	return D ? D.name : ""

/proc/BuildCustomDefForTurf(turf/CustomTurf/T)
	if(!T)
		return null
	BuildCustomLoad()
	var/datum/build_custom_def/D
	if(length(T.custom_def))
		D = BuildCustomFindByName(T.custom_def)
		if(D && D.kind == "turf")
			if(T.name != D.name && T.name == initial(T.name))
				T.name = D.name
			return D
		BuildCustomStamp(T, null)
	D = BuildCustomDefForIcon(T.icon, T.icon_state)
	if(D)
		BuildCustomStamp(T, D)
	return D

/proc/BuildCustomMaterialForTurf(turf/CustomTurf/T)
	var/datum/build_custom_def/D = BuildCustomDefForTurf(T)
	if(D)
		if(D.material in buildMaterialNames)
			return D.material
		return "custom:[D.name]"
	return "custom:[T.icon]:[T.icon_state]"

/proc/BuildCustomDefForObj(obj/Turfs/CustomObj1/O)
	if(!O)
		return null
	BuildCustomLoad()
	var/datum/build_custom_def/D
	if(length(O.custom_def))
		D = BuildCustomFindByName(O.custom_def)
		if(D && D.kind == "obj")
			if(O.name != D.name && O.name == initial(O.name))
				O.name = D.name
			return D
		BuildCustomStamp(O, null)
	D = BuildCustomDefForIcon(O.icon, O.icon_state, "obj")
	if(D)
		BuildCustomStamp(O, D)
	return D

/proc/BuildCustomMaterial(ic, st)
	var/datum/build_custom_def/D = BuildCustomDefForIcon(ic, st)
	if(D)
		if(D.material in buildMaterialNames)
			return D.material
		return "custom:[D.name]"
	return "custom:[ic]:[st]"

/proc/BuildCustomIconPath(atom/A)
	BuildCustomLoad()
	var/it = "[A.icon]"
	for(var/datum/build_custom_def/D in customDefs)
		if(D.fname == it)
			return D.fname
	var/h = md5(A.icon)
	if(!h)
		return null
	for(var/datum/build_custom_def/D in customDefs)
		if(D.hash == h)
			return D.fname
	for(var/datum/build_custom_def/D in customDefs)
		if(!length(D.fhash) && fexists(D.fname))
			D.fhash = md5(file(D.fname))
		if(D.fhash == h)
			return D.fname
	return null

/proc/BuildCustomRecoverIcon(atom/A)
	if(!A.icon)
		return null
	var/h = md5(A.icon)
	if(!h)
		return null
	var/fname = "Mapping/Custom/rec_[h].png"
	if(!fexists(fname))
		if(!fcopy(A.icon, fname))
			return null
	return fname

/proc/BuildCustomFindByName(nm)
	BuildCustomLoad()
	if(!customDefsByName)
		customDefsByName = list()
		for(var/datum/build_custom_def/D in customDefs)
			if(!customDefsByName[D.name])
				customDefsByName[D.name] = D
	if(!istext(nm) || !length(nm))
		return null
	return customDefsByName[nm]

/proc/BuildCustomRefreshSessions()
	for(var/client/C)
		var/datum/build_session/S = C.bsession
		if(S?.active)
			S.RefreshFiltered()
			BuildHUDRefreshGrid(S)

/proc/BuildCustomRegister(datum/build_custom_def/D)
	BuildCustomLoad()
	var/base = D.name
	var/n = 2
	while(BuildCustomFindByName(D.name))
		D.name = "[base]_[n]"
		n++
	customDefs += D
	customDefsByName = null
	customDefIconCache = list()
	BuildCustomSave()
	if(buildPalette)
		buildPalette += BuildCustomEntry(D)
	BuildCustomRefreshSessions()

/proc/BuildCustomDesigner(client/C)
	var/datum/build_session/S = C?.bsession
	if(!S?.active)
		return
	var/mob/M = C.mob
	if(S.cpActive)
		return
	var/icon/up = input(M, "Upload the icon for the new custom (.dmi or .png).", "New Custom") as null|icon
	if(!up)
		return
	var/uphash = md5(up)
	var/reuse = ""
	BuildCustomLoad()
	for(var/datum/build_custom_def/D in customDefs)
		if(D.hash == uphash)
			reuse = D.fname
			break
	sleep(5)
	var/kindT = Ask(M, "Is the new custom a turf or an object?", "New Custom", "Turf", "pick", list("Turf", "Object"), 1)
	if(isnull(kindT))
		return
	var/kind = (kindT == "Object") ? "obj" : "turf"
	var/fname = reuse
	if(!length(fname))
		var/stamp = "[world.realtime][rand(100, 999)]"
		fname = "Mapping/Custom/c[ckey(stamp)].dmi"
		fcopy(up, fname)
	var/list/states = icon_states(file(fname))
	if(!states || !states.len)
		states = list("")
	S.CancelPending()
	S.cpActive = 1
	S.cpKind = kind
	S.cpFname = fname
	S.cpHash = uphash
	S.cpStates = states
	S.cpIdx = 1
	M << "NEW CUSTOM: the ghost at your cursor shows the current icon state ([states.len] available). CLICK to cycle, CTRL+CLICK to confirm, right-click to cancel."
	BuildHUDSetSelName(S, "STATE 1/[states.len]: [states[1]]")

/proc/BuildCustomFinish(client/C)
	var/datum/build_session/S = C?.bsession
	if(!S)
		return
	var/kind = S.cpKind
	var/fname = S.cpFname
	var/uphash = S.cpHash
	var/state = S.cpStates[S.cpIdx]
	S.cpActive = 0
	S.cpStates = null
	S.ClearGhost()
	S.ClearChip()
	spawn
		sleep(5)
		var/mob/M = C.mob
		BuildCustomLoad()
		for(var/datum/build_custom_def/D2 in customDefs)
			if(D2.kind == kind && D2.fname == fname && "[D2.icon_state]" == "[state]")
				M << "That art with state \"[state]\" is already registered as \"[D2.name]\" - Edit_Custom_Def changes its material and flags, or pick a different state."
				return
		var/nm = M.HUDTextPrompt("Name this custom [kind]", "")
		if(isnull(nm) || !length(nm))
			M << "Custom creation canceled."
			return
		var/datum/build_custom_def/D = new
		D.kind = kind
		D.name = nm
		D.fname = fname
		D.icon_state = state
		D.hash = uphash
		D.creator = C.ckey
		BuildCustomSettingsMenu(M, D, "New Custom")
		BuildCustomRegister(D)
		Log("Mapper", "[M] ([C.ckey]) registered custom [kind] \"[D.name]\" ([D.fname], state \"[state]\", material [length(D.material) ? D.material : "auto"], profile [length(D.profile) ? D.profile : "auto"]).", 1)
		M << "Registered \"[D.name]\" - it is now in every mapper's CUSTOM palette."
		S.category = BUILD_CAT_CUSTOM
		S.RefreshFiltered()
		BuildHUDRefreshGrid(S)
		BuildHUDRefreshDrop(S)

/proc/BuildCustomObjApplyDef(obj/Turfs/CustomObj1/O, datum/build_custom_def/D)
	if(!O)
		return
	if(!D)
		D = BuildCustomDefForObj(O)
	if(!D)
		return
	BuildCustomStamp(O, D)
	O.surface_profile = length(D.profile) ? D.profile : null
	if(D.profile == "tree" || D.profile == "foliage")
		O.gfx_material_id = "foliage"
		O.casts_contact_shadow = 1
		O.gfx_contact_width = 1.45
		O.gfx_contact_depth = 0.62
		O.foreground_occluder = (D.profile == "tree") ? 1 : 0
		O.gfx_directional_response = 0.5
		O.gfx_occlusion_height = (D.profile == "tree") ? 2 : 1
	else
		O.gfx_material_id = initial(O.gfx_material_id)
		O.casts_contact_shadow = initial(O.casts_contact_shadow)
		O.gfx_contact_width = initial(O.gfx_contact_width)
		O.gfx_contact_depth = initial(O.gfx_contact_depth)
		O.foreground_occluder = initial(O.foreground_occluder)
		O.gfx_directional_response = initial(O.gfx_directional_response)
		O.gfx_occlusion_height = initial(O.gfx_occlusion_height)
	var/w = (O.sp_wind != null) ? O.sp_wind : SurfaceProp(O, "wind")
	O.gfx_wind_response = w
	if(w <= 0)
		O.transform = null
	GfxClearMaterialVisuals(O)
	SurfaceApply(O)
	if(D.layerv)
		O.layer = D.layerv
	GfxRefreshStructureMetadata(O)

/proc/BuildCustomRetroApply(datum/build_custom_def/D, dDens, dOpac, dRoof, reEdge, reElev = 0, reProf = 0, mob/who = null, dLayer = 0)
	set waitfor = FALSE
	set background = TRUE
	var/list/hit = list()
	var/n = 0
	if(D.kind == "obj")
		var/list/osnap = worldObjectList.Copy()
		var/scanned = 0
		for(var/obj/Turfs/CustomObj1/O in osnap)
			n++
			if(n % 400 == 0)
				sleep(-1)
			if(!O.loc)
				continue
			scanned++
			if(BuildCustomDefForObj(O) != D)
				continue
			if(dDens)
				O.density = D.density
			if(dOpac)
				O.opacity = D.opacity
			if(dLayer && !D.layerv)
				O.layer = initial(O.layer)
			if(reProf || dLayer)
				BuildCustomObjApplyDef(O, D)
			hit += O
		if(reProf && hit.len && glob && glob.LIGHTING)
			LightingApplyAll()
		Log("Mapper", "Custom def \"[D.name]\" retro-applied to [hit.len] placed objects out of [scanned] custom objects checked (dense [dDens ? "yes" : "no"], opaque [dOpac ? "yes" : "no"], layer [dLayer ? "yes" : "no"], profile [reProf ? "yes" : "no"]).", 1)
		if(who)
			who << "\"[D.name]\": [hit.len] placed cop[hit.len == 1 ? "y" : "ies"] updated ([scanned] custom objects checked).[hit.len ? "" : " None are linked to it. Custom_Registry lists placed copies that are not linked to any custom; stand next to one and use Custom_Adopt."]"
		return
	var/list/tsnap = CustomTurfs.Copy()
	for(var/turf/CustomTurf/T in tsnap)
		n++
		if(n % 400 == 0)
			sleep(-1)
		if(BuildCustomDefForTurf(T) != D)
			continue
		if(dDens)
			T.density = D.density
		if(dOpac)
			T.opacity = D.opacity
		if(dRoof)
			T.Roof = D.roof
		if(reProf)
			T.surface_profile = length(D.profile) ? D.profile : null
			SurfaceApply(T)
		hit += T
	if(reEdge && hit.len)
		BuildEdgeSmoothAround(hit, 1)
	if(reElev && hit.len)
		ElevVisualRefresh(hit)
	if(reProf && hit.len && glob && glob.LIGHTING)
		LightingApplyAll()
	Log("Mapper", "Custom def \"[D.name]\" retro-applied to [hit.len] placed tiles (dense [dDens ? "yes" : "no"], opaque [dOpac ? "yes" : "no"], roof [dRoof ? "yes" : "no"], re-edge [reEdge ? "yes" : "no"], profile [reProf ? "yes" : "no"]).", 1)
	if(who)
		who << "\"[D.name]\": [hit.len] placed tile[hit.len == 1 ? "" : "s"] updated.[hit.len ? "" : " None are linked to it. Custom_Registry lists placed copies that are not linked to any custom; stand next to one and use Custom_Adopt."]"

mob/Mapper/verb/Custom_Registry()
	set category = "Mapper"
	BuildCustomLoad()
	if(!customDefs.len)
		usr << "No customs registered yet. NEW CUSTOM in the build drawer creates one."
		return
	var/list/tcount = list()
	var/list/ocount = list()
	var/list/looseT = list()
	var/list/looseO = list()
	for(var/turf/CustomTurf/T in CustomTurfs)
		var/datum/build_custom_def/TD = BuildCustomDefForTurf(T)
		if(TD)
			tcount[TD] = (tcount[TD] || 0) + 1
		else
			looseT += T
	for(var/obj/Turfs/CustomObj1/O in worldObjectList)
		if(!O.loc)
			continue
		var/datum/build_custom_def/OD = BuildCustomDefForObj(O)
		if(OD)
			ocount[OD] = (ocount[OD] || 0) + 1
		else
			looseO += O
	usr << "CUSTOM REGISTRY - [customDefs.len] entries. Edit_Custom_Def changes one and re-applies the change to every placed copy (creator or Admin)."
	for(var/datum/build_custom_def/D in customDefs)
		var/placed = (D.kind == "obj") ? (ocount[D] || 0) : (tcount[D] || 0)
		var/flags = "[D.density ? "D" : ""][D.opacity ? "O" : ""][D.roof ? "R" : ""][D.cliff ? "C" : ""]"
		usr << "  [D.name] | [D.kind] by [D.creator] | placed [placed] | fixture [BuildCustomFixtureLabel(D)][D.kind == "obj" ? " | layer [D.layerv ? D.layerv : "default"]" : ""] | profile [length(D.profile) ? D.profile : "auto"] | material [length(D.material) ? D.material : "auto"] | flags [length(flags) ? flags : "-"] | [D.fname] state \"[D.icon_state]\""
	if(looseO.len || looseT.len)
		usr << "NOT LINKED to any custom: [looseO.len] placed object[looseO.len == 1 ? "" : "s"] and [looseT.len] placed tile[looseT.len == 1 ? "" : "s"]. Stand next to one and use Custom_Adopt to link every copy of that art."
		var/list/spots = list()
		for(var/obj/LO in looseO)
			if(spots.len >= 8)
				break
			spots += "object ([LO.x],[LO.y],[LO.z])"
		var/cap = spots.len + 8
		for(var/turf/LT in looseT)
			if(spots.len >= cap)
				break
			spots += "tile ([LT.x],[LT.y],[LT.z])"
		usr << "  For example: [jointext(spots, ", ")]"

/proc/BuildCustomSettingsMenu(mob/M, datum/build_custom_def/D, title = "Edit Custom")
	while(M && D)
		var/list/menu = list()
		if(D.kind == "turf")
			menu += "Material: [length(D.material) ? D.material : "AUTO (its own)"]"
		menu += "Dense: [D.density ? "ON" : "OFF"]"
		menu += "Opaque: [D.opacity ? "ON" : "OFF"]"
		if(D.kind == "obj")
			menu += "Layer: [D.layerv ? D.layerv : "DEFAULT (3, under players)"]"
		if(D.kind == "turf")
			menu += "Roof: [D.roof ? "ON" : "OFF"]"
			menu += "Cliff: [D.cliff ? "ON" : "OFF"]"
		menu += "Fixture: [BuildCustomFixtureLabel(D)]"
		menu += "Profile: [length(D.profile) ? D.profile : "AUTO (by type)"]"
		menu += "Done"
		var/choice = Ask(M, "Custom \"[D.name]\" - pick a setting.", title, null, "pick", menu, 1)
		if(!choice || choice == "Done")
			break
		if(findtext(choice, "Material"))
			var/list/mats = buildMaterialNames.Copy()
			mats += "AUTO (its own material)"
			var/mpick = Ask(M, "Which family should \"[D.name]\" edge-blend as? Water gets cliffs and banks.", title, null, "pick", mats, 1)
			if(!mpick)
				continue
			D.material = (mpick in buildMaterialNames) ? mpick : ""
		else if(findtext(choice, "Dense"))
			D.density = !D.density
		else if(findtext(choice, "Opaque"))
			D.opacity = !D.opacity
		else if(findtext(choice, "Layer:"))
			var/lv = Ask(M, "Layer for \"[D.name]\". Enter 0 for the default (3, under players). Players are at about 4, so 4.1 or higher draws over them. Allowed range: 2.1 to 6.4.[D.profile == "canopy" ? " The canopy profile always keeps it above players." : ""]", title, D.layerv, "num", null, 1)
			if(isnull(lv))
				continue
			if(lv == 0)
				D.layerv = 0
				continue
			var/cl = clamp(lv, 2.1, 6.4)
			if(cl != lv)
				M << "Layer [lv] is outside 2.1 to 6.4, so \"[D.name]\" uses [cl]."
			D.layerv = round(cl, 0.001)
		else if(findtext(choice, "Roof"))
			D.roof = !D.roof
		else if(findtext(choice, "Cliff"))
			D.cliff = !D.cliff
		else if(findtext(choice, "Fixture"))
			var/list/fx = list("None" = "", "Stairs - climbs raised terrain, shows over cliff faces" = "stairs", "Ladder - walk over walls and cliffs" = "ladder", "Bridge - walk over water" = "bridge")
			var/fpick = Ask(M, "What does \"[D.name]\" let players do?", title, null, "pick", fx, 1)
			if(!fpick)
				continue
			D.fixture = fx[fpick]
			D.stairs = (D.kind == "turf" && D.fixture == "stairs") ? 1 : 0
		else if(findtext(choice, "Profile"))
			var/list/ids = list()
			for(var/pid in SurfaceProfiles())
				ids += pid
			ids += "AUTO (classify by type)"
			var/ppick = Ask(M, "Surface profile for \"[D.name]\": tree or foliage sway in the wind and cast soft shadows, wall blocks light, floor does nothing.", title, null, "pick", ids, 1)
			if(!ppick)
				continue
			D.profile = (ppick in SurfaceProfiles()) ? ppick : ""

mob/Mapper/verb/Edit_Custom_Def()
	set category = "Mapper"
	BuildCustomLoad()
	var/list/mine = list()
	for(var/datum/build_custom_def/D in customDefs)
		if(D.creator == usr.ckey || usr.Admin)
			mine["[D.name] ([D.kind], by [D.creator])"] = D
	if(!mine.len)
		usr << "No customs you can edit. NEW CUSTOM in the build drawer creates one."
		return
	var/pick = Ask(usr, "Edit which custom?", "Edit Custom", null, "pick", mine, 1)
	if(!pick)
		return
	var/datum/build_custom_def/D = mine[pick]
	var/d0 = D.density
	var/o0 = D.opacity
	var/r0 = D.roof
	var/m0 = D.material
	var/k0 = D.cliff
	var/s0 = D.stairs
	var/x0 = D.fixture
	var/p0 = D.profile
	var/l0 = D.layerv
	BuildCustomSettingsMenu(usr, D, "Edit Custom")
	var/dDens = (D.density != d0)
	var/dOpac = (D.opacity != o0)
	var/dRoof = (D.roof != r0)
	var/matChanged = (D.material != m0)
	var/cliffChanged = (D.cliff != k0)
	var/stairsChanged = (D.stairs != s0 || D.fixture != x0)
	var/profChanged = (D.profile != p0)
	var/layerChanged = (D.layerv != l0)
	if(!dDens && !dOpac && !dRoof && !matChanged && !cliffChanged && !stairsChanged && !profChanged && !layerChanged)
		return
	BuildCustomSave()
	if(buildPalette)
		for(var/datum/build_entry/E in buildPalette)
			if(E.category == BUILD_CAT_CUSTOM && E.name == "-[D.name]-")
				E.cDensity = D.density
				E.cOpacity = D.opacity
				E.cRoof = D.roof
				E.cLayer = D.layerv
				break
	usr << "Saved \"[D.name]\" - new placements use the new settings; placed copies are updating in the background."
	Log("Mapper", "[usr] ([usr.ckey]) edited custom def \"[D.name]\" (material [length(D.material) ? D.material : "auto"], D[D.density] O[D.opacity] R[D.roof] C[D.cliff] fixture [BuildCustomFixtureLabel(D)], layer [D.layerv ? D.layerv : "default"], profile [length(D.profile) ? D.profile : "auto"]).", 1)
	customDefIconCache = list()
	BuildCustomRetroApply(D, dDens, dOpac, dRoof, matChanged || cliffChanged, cliffChanged || stairsChanged, profChanged, usr, layerChanged)

mob/Mapper/verb/Custom_Adopt()
	set category = "Mapper"
	if(args.len && istype(args[1], /atom))
		BuildCustomAdoptAtom(usr, args[1])
		return
	var/list/seen = list()
	var/list/reps = list()
	for(var/atom/C in view(8, usr))
		var/isobj = istype(C, /obj/Turfs/CustomObj1)
		if(!isobj && !istype(C, /turf/CustomTurf))
			continue
		var/k = "[isobj ? "o" : "t"]|[C.name]|[C.icon_state]"
		if(seen[k])
			seen[k]++
			continue
		seen[k] = 1
		reps[k] = C
	if(!reps.len)
		usr << "No custom objects or custom tiles in view."
		return
	var/list/menu = list()
	for(var/k in reps)
		var/atom/C = reps[k]
		var/base = "[C.name][istype(C, /turf) ? " (tile)" : ""][seen[k] > 1 ? " x[seen[k]]" : ""]"
		var/label = base
		var/j = 2
		while(menu[label])
			label = "[base] #[j]"
			j++
		menu[label] = C
	var/target = Ask(usr, "Adopt which placed art? Every copy that shares it will be linked to the custom you pick next.", "Custom Adopt", null, "pick", menu, 1)
	if(!target)
		return
	var/atom/A = menu[target]
	if(!A)
		return
	BuildCustomAdoptAtom(usr, A)

/proc/BuildCustomAdoptAtom(mob/M, atom/A)
	if(!M || !A)
		return
	if(istype(A, /turf/CustomTurf))
		BuildCustomAdoptTurf(M, A)
		return
	if(!istype(A, /obj/Turfs/CustomObj1))
		M << "That is not a custom object or custom turf."
		return
	var/obj/Turfs/CustomObj1/O = A
	BuildCustomLoad()
	var/list/mine = list()
	for(var/datum/build_custom_def/D in customDefs)
		if(D.kind == "obj" && (D.creator == M.ckey || M.Admin))
			mine["[D.name] (by [D.creator])"] = D
	if(!mine.len)
		M << "No custom objects you can edit."
		return
	var/datum/build_custom_def/cur = BuildCustomDefForObj(O)
	var/pick = Ask(M, "Link every placed object that shares this art with which custom? (this one is [cur ? "\"[cur.name]\"" : "not linked to any"])", "Custom Adopt", null, "pick", mine, 1)
	if(!pick)
		return
	var/datum/build_custom_def/D = mine[pick]
	var/h = md5(O.icon)
	if(!h)
		M << "That object has no icon to match on."
		return
	var/st = "[O.icon_state]"
	spawn
		var/n = 0
		var/linked = 0
		for(var/obj/Turfs/CustomObj1/O2 in worldObjectList.Copy())
			n++
			if(n % 200 == 0)
				sleep(-1)
			if(!O2.loc || "[O2.icon_state]" != st)
				continue
			if(O2 != O && md5(O2.icon) != h)
				continue
			BuildCustomStamp(O2, D)
			BuildCustomObjApplyDef(O2, D)
			linked++
		if(linked && glob && glob.LIGHTING)
			LightingApplyAll()
		M << "Linked [linked] placed object[linked == 1 ? "" : "s"] to \"[D.name]\" and applied its settings (profile [length(D.profile) ? D.profile : "auto"])."
		Log("Mapper", "[M] ([M.ckey]) adopted [linked] placed objects into custom def \"[D.name]\".", 1)

/proc/BuildCustomAdoptTurf(mob/M, turf/CustomTurf/T)
	if(!M || !T)
		return
	BuildCustomLoad()
	var/list/mine = list()
	for(var/datum/build_custom_def/D in customDefs)
		if(D.kind == "turf" && (D.creator == M.ckey || M.Admin))
			mine["[D.name] (by [D.creator])"] = D
	if(!mine.len)
		M << "No custom turfs you can edit."
		return
	var/datum/build_custom_def/cur = BuildCustomDefForTurf(T)
	var/pick = Ask(M, "Link every placed tile that shares this art with which custom? (this one is [cur ? "\"[cur.name]\"" : "not linked to any"])", "Custom Adopt", null, "pick", mine, 1)
	if(!pick)
		return
	var/datum/build_custom_def/D = mine[pick]
	var/h = md5(T.icon)
	if(!h)
		M << "That tile has no icon to match on."
		return
	var/st = "[T.icon_state]"
	spawn
		var/n = 0
		var/list/hit = list()
		for(var/turf/CustomTurf/T2 in CustomTurfs.Copy())
			n++
			if(n % 200 == 0)
				sleep(-1)
			if("[T2.icon_state]" != st)
				continue
			if(T2 != T && md5(T2.icon) != h)
				continue
			BuildCustomStamp(T2, D)
			T2.density = D.density
			T2.opacity = D.opacity
			T2.Roof = D.roof
			T2.surface_profile = length(D.profile) ? D.profile : null
			hit += T2
		if(hit.len)
			BuildEdgeSmoothAround(hit, 1)
			ElevVisualRefresh(hit)
		M << "Linked [hit.len] placed tile[hit.len == 1 ? "" : "s"] to \"[D.name]\" and applied its settings (fixture [BuildCustomFixtureLabel(D)], material [length(D.material) ? D.material : "auto"])."
		Log("Mapper", "[M] ([M.ckey]) adopted [hit.len] placed tiles into custom def \"[D.name]\".", 1)

mob/Admin3/verb/Delete_Custom_Def()
	set category = "Mapper"
	spawn
		BuildCustomLoad()
		var/list/all = list()
		for(var/datum/build_custom_def/D2 in customDefs)
			all["[D2.name] ([D2.kind], by [D2.creator])"] = D2
		if(!all.len)
			usr << "No customs are registered."
			return
		var/nm = Ask(usr, "Delete which custom?", "Delete Custom", null, "pick", all, 1)
		if(isnull(nm))
			return
		var/datum/build_custom_def/D = all[nm]
		if(!D || !(D in customDefs))
			return
		customDefs -= D
		customDefsByName = null
		customDefIconCache = list()
		BuildCustomSave()
		if(buildPalette)
			for(var/datum/build_entry/E in buildPalette)
				if(E.category == BUILD_CAT_CUSTOM && E.name == "-[D.name]-")
					buildPalette -= E
					break
		for(var/client/C)
			var/datum/build_session/S = C.bsession
			if(S?.brush && S.brush.name == "-[D.name]-")
				S.brush = null
				BuildHUDRefreshHand(S)
		BuildCustomRefreshSessions()
		usr << "Deleted custom \"[D.name]\" (icon file kept on disk)."
		Log("Mapper", "[usr] ([usr.ckey]) deleted custom def \"[D.name]\".", 1)
