proc/OugiPlayableTypes()
	var/list/L = list()
	for(var/T in subtypesof(/obj/Skills/Ougi))
		var/obj/Skills/Ougi/O = T
		if(!initial(O.OugiScene)) continue
		L["[initial(O.name)] ([T])"] = T
	return L

proc/OugiOnlinePick(mob/asker, title)
	var/list/L = list()
	for(var/mob/Players/P in players)
		if(P.client) L["[P.name] ([P.key])"] = P
	if(!L.len) return null
	var/pick = Ask(asker, "Which player?", title, null, "pick", L, 1)
	if(!pick || !L[pick]) return null
	return L[pick]

/mob/Admin3/verb/Give_Ougi()
	set category = "Admin"
	set name = "Give-Ougi"
	var/list/types = OugiPlayableTypes()
	if(!types.len)
		usr << "No Ougi types exist."
		return
	var/tp = Ask(usr, "Which Ougi?", "Give-Ougi", null, "pick", types, 1)
	if(!tp || !types[tp]) return
	var/mob/P = OugiOnlinePick(usr, "Give-Ougi")
	if(!P) return
	var/T = types[tp]
	var/obj/Skills/Ougi/O = locate(T) in P
	var/forced = 0
	if(!O && ispath(T, /obj/Skills/Ougi/Secret))
		var/obj/Skills/Ougi/tpl = OugiSecretTemplate(T)
		for(var/R in tpl.RequiredSkills)
			if(!(locate(R) in P)) forced = 1
		if(forced && Ask(usr, "[P] does not own what [tpl.name] needs. Grant it without the requirements?", "Give-Ougi", null, "pick", list("Grant it", "Cancel"), 1) != "Grant it") return
	if(!O)
		var/why = OugiSagaRefusalFor(T, P)
		if(why && Ask(usr, "[why] Grant it anyway?", "Give-Ougi", null, "pick", list("Grant it", "Cancel"), 1) != "Grant it") return
	if(!O)
		O = new T
		O.SecretGrantedByAdmin = forced
		P.AddSkill(O)
	P.EquippedOugi = "[T]"
	P << "You received the Ougi [O.name]. It is equipped."
	usr << "Gave [O.name] to [P] and equipped it."
	Log("Admin", "[ExtractInfo(usr)] gave the Ougi [O.name] to [ExtractInfo(P)].")

/mob/Admin3/verb/Take_Ougi()
	set category = "Admin"
	set name = "Take-Ougi"
	var/mob/P = OugiOnlinePick(usr, "Take-Ougi")
	if(!P) return
	var/list/owned = list()
	for(var/obj/Skills/Ougi/O in P)
		owned["[O.name] ([O.type])"] = O
	if(!owned.len)
		usr << "[P] owns no Ougi."
		return
	var/pick = Ask(usr, "Take which Ougi?", "Take-Ougi", null, "pick", owned, 1)
	if(!pick || !owned[pick]) return
	var/obj/Skills/Ougi/O = owned[pick]
	if(P.OugiLock)
		usr << "[P] is inside an Ougi right now."
		return
	if(P.EquippedOugi == "[O.type]") P.EquippedOugi = null
	var/n = O.name
	del O
	usr << "Took [n] from [P]."
	Log("Admin", "[ExtractInfo(usr)] took the Ougi [n] from [ExtractInfo(P)].")

/mob/Admin3/verb/Fill_Tension()
	set category = "Admin"
	set name = "Fill-Tension"
	var/mob/P = OugiOnlinePick(usr, "Fill-Tension")
	if(!P) return
	P.tempTensionLock = 0
	P.Tension = P.getTensionCap()
	usr << "[P]'s Tension is full ([P.Tension])."

/mob/Admin3/verb/Ougi_Release_All()
	set category = "Admin"
	set name = "Ougi-Release-All"
	var/n = OugiReleaseAll()
	usr << "Ougi release: [n] scene(s) or lock(s) cleared."
	Log("Admin", "[ExtractInfo(usr)] used Ougi-Release-All ([n]).")

/mob/Admin3/verb/Ougi_Rooms()
	set category = "Admin"
	set name = "Ougi-Rooms"
	var/list/R = OugiRoomsList()
	if(!R.len)
		usr << "No Ougi rooms have been built yet."
	var/stuck = 0
	for(var/datum/ougi_room/O in R)
		var/inuse = 0
		for(var/datum/ougi_scene/S in OugiLiveList())
			if(S.room == O) inuse = 1
		if(O.busy && !inuse) stuck++
		usr << "[O.id]: [O.template], z [O.z] center [O.cx],[O.cy], [O.busy ? (inuse ? "in use" : "STUCK") : "free"][O.Valid() ? "" : ", INVALID"]"
	var/list/acts = list()
	if(stuck) acts += "Free [stuck] stuck room(s)"
	acts += "Reload a prefab template"
	acts += "Done"
	var/pick = Ask(usr, "Ougi rooms:", "Ougi-Rooms", "Done", "pick", acts, 1)
	if(pick == "Reload a prefab template")
		var/list/T = OugiPrefabTemplates()
		if(!T.len)
			usr << "No Prefabs/ougi_<name>.dmm files exist yet. Save-Prefab a room as ougi_<name> first."
			return
		var/id = Ask(usr, "Reload which template?", "Ougi-Rooms", null, "pick", T, 1)
		if(!id) return
		usr << OugiStageReload(id)
		return
	if(!stuck || pick != acts[1]) return
	for(var/datum/ougi_room/O in R)
		var/inuse = 0
		for(var/datum/ougi_scene/S in OugiLiveList())
			if(S.room == O) inuse = 1
		if(O.busy && !inuse) OugiRoomRelease(O)
	usr << "Freed [stuck] room(s)."

/mob/Admin3/verb/Ougi_Fast()
	set category = "Admin"
	set name = "Ougi-Fast"
	glob.OUGI_FAST = !glob.OUGI_FAST
	usr << "Ougi beat times: [glob.OUGI_FAST ? "halved" : "normal"]."

/mob/Admin3/verb/Ougi_Preview()
	set category = "Admin"
	set name = "Ougi-Preview"
	var/list/reg = OugiScenesRegistry()
	if(!reg.len)
		usr << "No Ougi scenes are registered."
		return
	var/list/ids = list()
	for(var/k in reg)
		ids += k
	var/id = Ask(usr, "Which scene?", "Ougi-Preview", null, "pick", ids, 1)
	if(!id || !reg[id]) return
	usr.OugiPreviewRun(id)

mob/proc/OugiPreviewRun(id)
	var/list/reg = OugiScenesRegistry()
	if(!id || !reg[id]) return null
	if(OugiLock)
		src << "You are inside an Ougi already."
		return null
	var/mob/Player/AI/TestDummy/D
	for(var/mob/Player/AI/TestDummy/old in world)
		if(old.ai_owner == src && old.z == z && get_dist(old, src) <= 10) D = old
	if(!D)
		D = new
		var/turf/spot = get_step(src, dir)
		D.loc = spot ? spot : loc
		D.ai_owner = src
		D.ai_hostility = 0
		D.ai_wander = 0
		D.ai_state = "Idle"
	var/obj/Skills/Ougi/O = OugiEquipped()
	if(!O)
		for(var/T in subtypesof(/obj/Skills/Ougi))
			var/obj/Skills/Ougi/Q = T
			if(initial(Q.OugiScene) == id)
				O = new T
				break
	if(!O) O = new /obj/Skills/Ougi/Energy/Heat_Dome_Attack
	var/datum/ougi_room/R = OugiRoomAcquire(O.OugiStage, O.OugiGround)
	if(!R)
		src << "Wait for the current Ougi to end."
		return null
	OugiCommit(O, reg[id], D, R, list(src, D), 1)
	for(var/datum/ougi_scene/S in OugiLiveList())
		if(S.attacker == src && S.preview && S.live && !S.ended) . = S

/mob/Admin3/verb/Ougi_Capture_Beat()
	set category = "Admin"
	set name = "Ougi-Capture-Beat"
	var/list/reg = OugiScenesRegistry()
	if(!reg.len)
		usr << "No Ougi scenes are registered."
		return
	var/list/ids = list()
	for(var/k in reg)
		ids += k
	var/id = Ask(usr, "Which scene?", "Ougi-Capture-Beat", null, "pick", ids, 1)
	if(!id || !reg[id]) return
	var/datum/ougi_scene/tpl = reg[id]
	var/list/picks = list()
	var/i = 0
	for(var/list/beat in tpl.beats)
		i++
		picks["[i]: [beat[1]] ds, [beat[2]]"] = beat[1]
	if(!picks.len) return
	var/pick = Ask(usr, "Pause after which beat? The scene holds there for 6 seconds and your client saves a screenshot after 2.", "Ougi-Capture-Beat", null, "pick", picks, 1)
	if(!pick || isnull(picks[pick])) return
	var/datum/ougi_scene/S = usr.OugiPreviewRun(id)
	if(!S)
		usr << "The preview did not start."
		return
	S.pause_at = picks[pick]
	S.pause_shot = 20
	S.pause_hold_ds = 60
	usr << "Ougi-Capture-Beat: [id] pauses after [picks[pick]] ds. The screenshot lands in your BYOND screenshots folder."

proc/OugiSceneIconNames(datum/ougi_scene/S)
	var/list/L = list("OUGI_RING_ICON" = OUGI_RING_ICON, "OUGI_WHITE_ICON" = OUGI_WHITE_ICON, "OUGI_BLACK_ICON" = OUGI_BLACK_ICON, "OUGI_STANDIN_ICON" = OUGI_STANDIN_ICON)
	if(S && S.icon_defines)
		for(var/k in S.icon_defines)
			L[k] = S.icon_defines[k]
	return L

proc/OugiSceneBlendName(v)
	switch(v)
		if(BLEND_DEFAULT) return "@BLEND_DEFAULT"
		if(BLEND_OVERLAY) return "@BLEND_OVERLAY"
		if(BLEND_ADD) return "@BLEND_ADD"
		if(BLEND_SUBTRACT) return "@BLEND_SUBTRACT"
		if(BLEND_MULTIPLY) return "@BLEND_MULTIPLY"
		if(BLEND_INSET_OVERLAY) return "@BLEND_INSET_OVERLAY"
	return v

proc/OugiSceneDirName(v)
	switch(v)
		if(NORTH) return "@NORTH"
		if(SOUTH) return "@SOUTH"
		if(EAST) return "@EAST"
		if(WEST) return "@WEST"
		if(NORTHEAST) return "@NORTHEAST"
		if(NORTHWEST) return "@NORTHWEST"
		if(SOUTHEAST) return "@SOUTHEAST"
		if(SOUTHWEST) return "@SOUTHWEST"
	return v

proc/OugiSceneListIsAssoc(list/L)
	for(var/k in L)
		if(istext(k) && !isnull(L[k])) return 1
	return 0

proc/OugiSceneJsonValue(key, v, list/icons)
	if(isnull(v)) return null
	if(isnum(v))
		if(key == "blend") return OugiSceneBlendName(v)
		if(key == "dir") return OugiSceneDirName(v)
		return v
	if(istext(v)) return v
	if(ispath(v)) return "[v]"
	if(isfile(v) || isicon(v))
		for(var/n in icons)
			if("[icons[n]]" == "[v]") return "@[n]"
		return "'[v]'"
	if(islist(v))
		var/list/L = v
		var/list/out = list()
		if(OugiSceneListIsAssoc(L))
			for(var/k in L)
				out[k] = OugiSceneJsonValue(k, L[k], icons)
		else
			for(var/e in L)
				var/c = OugiSceneJsonValue(null, e, icons)
				if(islist(c)) out += list(c)
				else out += c
		return out
	return "[v]"

proc/OugiSceneJsonBeats(list/B, list/icons)
	var/list/out = list()
	for(var/list/beat in B)
		var/list/b = list("at" = beat[1], "op" = beat[2])
		if(beat.len >= 3 && islist(beat[3])) b["args"] = OugiSceneJsonValue(null, beat[3], icons)
		out += list(b)
	return out

proc/OugiSceneOugiType(id)
	for(var/T in subtypesof(/obj/Skills/Ougi))
		var/obj/Skills/Ougi/Q = T
		if(initial(Q.OugiScene) == id) return T
	return null

proc/OugiSceneExportData(datum/ougi_scene/S)
	if(!S || !S.id) return null
	var/list/icons = OugiSceneIconNames(S)
	var/list/D = list()
	D["id"] = S.id
	D["parent"] = istype(S, /datum/ougi_scene/stand_in) ? "stand_in" : "authored"
	D["category"] = S.category
	D["stage"] = S.stage
	var/T = OugiSceneOugiType(S.id)
	var/obj/Skills/Ougi/Q = T
	D["ground"] = T ? initial(Q.OugiGround) : null
	D["length_ds"] = S.length_ds
	D["climax_ds"] = S.climax_ds
	var/def = json_encode(OugiSceneJsonBeats(OugiDefaultPrelude(), icons))
	var/mine = json_encode(OugiSceneJsonBeats(S.prelude, icons))
	D["prelude"] = (!S.prelude || mine == def) ? null : OugiSceneJsonBeats(S.prelude, icons)
	D["beats"] = OugiSceneJsonBeats(S.beats, icons)
	var/list/sf = list()
	if(S.surfaces)
		for(var/list/row in S.surfaces)
			sf += list(OugiSceneJsonValue(null, row, icons))
	D["surfaces"] = sf
	return D

proc/OugiSceneModuleScene(cat, kind)
	var/id = OugiBurstModuleId(cat, kind)
	var/datum/ougi_scene/S = OugiSceneById(id)
	if(S) return S
	S = new /datum/ougi_scene
	S.id = id
	S.category = cat
	S.stage = "burst"
	S.beats = OugiBurstModule(cat, kind)
	S.length_ds = S.BeatsSpan(S.beats)
	S.climax_ds = OugiBurstHitAt(S.beats)
	return S

proc/OugiSceneExportAll()
	var/list/L = list()
	for(var/k in OugiScenesRegistry())
		L[k] = OugiSceneById(k)
	for(var/cat in list("Unarmed", "Armed", "Gun", "Energy"))
		for(var/kind in list("chain", "finisher"))
			var/datum/ougi_scene/M = OugiSceneModuleScene(cat, kind)
			L[M.id] = M
	return L

proc/OugiSceneExportWrite(datum/ougi_scene/S)
	var/list/D = OugiSceneExportData(S)
	if(!D) return null
	var/path = "OugiScenes/[S.id].json"
	if(fexists(path)) fdel(path)
	if(!text2file(json_encode(D), path)) return null
	return path

/mob/Admin3/verb/Ougi_Export_Scene()
	set category = "Admin"
	set name = "Ougi-Export-Scene"
	var/list/all = OugiSceneExportAll()
	var/list/ids = list("All scenes")
	for(var/k in all)
		ids += k
	var/id = Ask(usr, "Export which scene as JSON?", "Ougi-Export-Scene", null, "pick", ids, 1)
	if(!id) return
	var/n = 0
	for(var/k in all)
		if(id != "All scenes" && k != id) continue
		var/path = OugiSceneExportWrite(all[k])
		if(path)
			n++
			usr << "Ougi-Export-Scene: wrote [path]"
		else
			usr << "Ougi-Export-Scene: could not write [k]."
	usr << "Ougi-Export-Scene: [n] file(s) in the world folder's OugiScenes."
