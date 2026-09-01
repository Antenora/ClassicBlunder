#define CUSTOM_MANIFEST "Mapping/Custom/manifest.txt"

var/global/list/customDefs
var/global/customDefsDirty = 0

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
		tmp/fhash = ""

/proc/BuildCustomLoad()
	if(customDefs)
		return customDefs
	customDefs = list()
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
		if(!fexists(D.fname))
			continue
		customDefs += D
	return customDefs

/proc/BuildCustomSave()
	var/list/lines = list()
	for(var/datum/build_custom_def/D in customDefs)
		lines += jointext(list(D.kind, BuildDmmEscape(D.name), BuildDmmEscape(D.fname), BuildDmmEscape(D.icon_state), "[D.density]", "[D.opacity]", "[D.roof]", "[D.layerv]", "[D.pixelX]", "[D.pixelY]", "[D.edge]", D.hash, BuildDmmEscape(D.creator), D.material), "\t")
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
	BuildEntryFit(E)
	return E

var/global/list/customDefIconCache = list()

/proc/BuildCustomDefForIcon(ic, st)
	BuildCustomLoad()
	var/ck = "[ic]|[st]"
	var/hit = customDefIconCache[ck]
	if(hit)
		return (hit == "none") ? null : hit
	var/it = "[ic]"
	var/list/cands = list()
	for(var/datum/build_custom_def/D in customDefs)
		if(D.kind == "turf" && D.fname == it)
			cands += D
	if(!cands.len)
		var/h = md5(ic)
		if(h)
			for(var/datum/build_custom_def/D in customDefs)
				if(D.kind == "turf" && D.hash == h)
					cands += D
			if(!cands.len)
				for(var/datum/build_custom_def/D in customDefs)
					if(D.kind != "turf")
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
	customDefIconCache[ck] = best ? best : "none"
	return best

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
	for(var/datum/build_custom_def/D in customDefs)
		if(D.name == nm)
			return D
	return null

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
	var/kindT = M.HUDTextPrompt("T = turf, O = object", "T")
	if(isnull(kindT))
		return
	var/kind = (uppertext(copytext(kindT, 1, 2)) == "O") ? "obj" : "turf"
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
			M << "Custom creation cancelled."
			return
		M << "Flags: D = dense, O = opaque, R = roof. Type any of them, or leave empty."
		sleep(5)
		var/flags = M.HUDTextPrompt("Flags: D O R (or empty)", "")
		if(isnull(flags))
			flags = ""
		flags = uppertext(flags)
		var/mat = ""
		if(kind == "turf")
			M << "Material family makes this turf edge-blend like real terrain (cliffs and banks included for Water). Leave empty to keep it its own material."
			sleep(5)
			var/matIn = M.HUDTextPrompt("Material: Grass Dirt Sand Water Stone Wood Ice (or empty)", "")
			if(isnull(matIn))
				matIn = ""
			matIn = trimtext(matIn)
			for(var/nm2 in buildMaterialNames)
				if(cmptext(nm2, matIn))
					mat = nm2
					break
		var/datum/build_custom_def/D = new
		D.kind = kind
		D.name = nm
		D.fname = fname
		D.icon_state = state
		D.density = findtext(flags, "D") ? 1 : 0
		D.opacity = findtext(flags, "O") ? 1 : 0
		D.roof = (kind == "turf" && findtext(flags, "R")) ? 1 : 0
		D.hash = uphash
		D.creator = C.ckey
		D.material = mat
		BuildCustomRegister(D)
		Log("Mapper", "[M] ([C.ckey]) registered custom [kind] \"[D.name]\" ([D.fname], state \"[state]\", material [length(mat) ? mat : "auto"]).", 1)
		M << "Registered \"[D.name]\" - it is now in every mapper's CUSTOM palette."
		S.category = BUILD_CAT_CUSTOM
		S.RefreshFiltered()
		BuildHUDRefreshGrid(S)
		BuildHUDRefreshDrop(S)

/proc/BuildCustomRetroApply(datum/build_custom_def/D, dDens, dOpac, dRoof, reEdge)
	set waitfor = FALSE
	set background = TRUE
	if(D.kind != "turf")
		return
	var/list/snap = CustomTurfs.Copy()
	var/list/hit = list()
	var/n = 0
	for(var/turf/CustomTurf/T in snap)
		n++
		if(n % 400 == 0)
			sleep(-1)
		if(BuildCustomDefForIcon(T.icon, T.icon_state) != D)
			continue
		if(dDens)
			T.density = D.density
		if(dOpac)
			T.opacity = D.opacity
		if(dRoof)
			T.Roof = D.roof
		hit += T
	if(reEdge && hit.len)
		BuildEdgeSmoothAround(hit, 1)
	Log("Mapper", "Custom def \"[D.name]\" retro-applied to [hit.len] placed tiles (dense [dDens ? "yes" : "no"], opaque [dOpac ? "yes" : "no"], roof [dRoof ? "yes" : "no"], re-edge [reEdge ? "yes" : "no"]).", 1)

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
	var/pick = input(usr, "Edit which custom?", "Edit Custom") as null|anything in mine
	if(!pick)
		return
	var/datum/build_custom_def/D = mine[pick]
	var/d0 = D.density
	var/o0 = D.opacity
	var/r0 = D.roof
	var/m0 = D.material
	while(D)
		var/list/menu = list()
		if(D.kind == "turf")
			menu += "Material: [length(D.material) ? D.material : "AUTO (its own)"]"
		menu += "Dense: [D.density ? "ON" : "OFF"]"
		menu += "Opaque: [D.opacity ? "ON" : "OFF"]"
		if(D.kind == "turf")
			menu += "Roof: [D.roof ? "ON" : "OFF"]"
		menu += "Done"
		var/choice = input(usr, "Custom \"[D.name]\" - pick a setting.", "Edit Custom") as null|anything in menu
		if(!choice || choice == "Done")
			break
		if(findtext(choice, "Material"))
			var/list/mats = buildMaterialNames.Copy()
			mats += "AUTO (its own material)"
			var/mpick = input(usr, "Which family should \"[D.name]\" edge-blend as? Water gets cliffs and banks.", "Edit Custom") as null|anything in mats
			if(!mpick)
				continue
			D.material = (mpick in buildMaterialNames) ? mpick : ""
		else if(findtext(choice, "Dense"))
			D.density = !D.density
		else if(findtext(choice, "Opaque"))
			D.opacity = !D.opacity
		else if(findtext(choice, "Roof"))
			D.roof = !D.roof
	var/dDens = (D.density != d0)
	var/dOpac = (D.opacity != o0)
	var/dRoof = (D.roof != r0)
	var/matChanged = (D.material != m0)
	if(!dDens && !dOpac && !dRoof && !matChanged)
		return
	BuildCustomSave()
	if(buildPalette)
		for(var/datum/build_entry/E in buildPalette)
			if(E.category == BUILD_CAT_CUSTOM && E.name == "-[D.name]-")
				E.cDensity = D.density
				E.cOpacity = D.opacity
				E.cRoof = D.roof
				break
	usr << "Saved \"[D.name]\" - new placements use the new settings[D.kind == "turf" ? "; placed tiles are updating in the background" : ""]."
	Log("Mapper", "[usr] ([usr.ckey]) edited custom def \"[D.name]\" (material [length(D.material) ? D.material : "auto"], D[D.density] O[D.opacity] R[D.roof]).", 1)
	BuildCustomRetroApply(D, dDens, dOpac, dRoof, matChanged)

mob/Admin3/verb/Delete_Custom_Def()
	set category = "Mapper"
	spawn
		var/nm = usr.HUDTextPrompt("Delete which custom?", "")
		if(isnull(nm) || !length(nm))
			return
		BuildCustomLoad()
		var/datum/build_custom_def/D = BuildCustomFindByName(nm)
		if(!D)
			usr << "No custom named \"[nm]\". Registered: [customDefs.len]."
			for(var/datum/build_custom_def/D2 in customDefs)
				usr << "  [D2.name] ([D2.kind], by [D2.creator])"
			return
		customDefs -= D
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
