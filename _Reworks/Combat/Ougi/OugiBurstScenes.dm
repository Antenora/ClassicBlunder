var/const/OUGI_BURST_RULE_MOCKUP = "Placeholder burst modules only. No Chain Burst or Full Burst scene is authored in the engine until its mockup (a frame strip of every beat over a real game frame at 1x and a GIF at real timing) has been approved by the owner."
var/const/OUGI_BURST_RULE_ASSETS = "Asset check: every surface a Burst needs is named with its asset or pipeline before the mockup starts. Energy, spiritual attacks and hit sparks use the engine FX pipelines (EnergyFX, AuraFX, Modern FX). A surface with no readily available asset is reported to the owner, never improvised."

proc/OugiBurstRing(at, scale, life, jx = 0, jy = 0)
	return list("at" = at, "icon" = OUGI_RING_ICON, "x" = -105 + jx, "y" = -105 + jy, "scale" = scale, "life" = life, "blend" = BLEND_ADD)

proc/OugiBurstModuleId(cat, kind)
	return "burst_[lowertext(cat)]_[kind]"

proc/OugiBurstModule(cat, kind)
	var/datum/ougi_scene/S = OugiSceneById(OugiBurstModuleId(cat, kind))
	if(!S) S = OugiSceneById(OugiBurstModuleId("Energy", kind))
	return (S && S.beats) ? S.beats : list()

proc/OugiBurstSide(datum/ougi_stage/ST, mark)
	if(!ST || !ST.mark_offsets) return 1
	var/list/o = ST.mark_offsets[mark]
	var/list/t = ST.mark_offsets["target"]
	if(!o || !t) return 1
	return (o[1] <= t[1]) ? 1 : -1

proc/OugiBurstShift(list/mod, t0, mark, side)
	var/list/out = list()
	for(var/list/beat in mod)
		var/list/a = beat.len >= 3 ? beat[3] : null
		if(!a)
			out += list(list(beat[1] + t0, beat[2]))
			continue
		var/list/na = a.Copy()
		for(var/k in list("who", "to", "at"))
			if(na[k] == "self") na[k] = mark
		if(isnum(na["dx"])) na["dx"] = na["dx"] * side
		out += list(list(beat[1] + t0, beat[2], na))
	return out

proc/OugiBurstHitAt(list/mod)
	for(var/list/beat in mod)
		if(beat[2] == "hit") return beat[1]
	return 0

proc/OugiBurstMake(datum/ougi_chain/C)
	var/datum/ougi_scene/burst/B = new
	B.burst_chain = C
	B.attacker = C.initiator
	B.target = C.target
	B.preview = C.preview
	var/cat = C.categories[C.initiator]
	B.category = cat ? cat : "Energy"
	B.Build()
	return B

/datum/ougi_scene/burst
	stage = "burst"
	length_ds = 50
	climax_ds = 40
	var/datum/ougi_chain/burst_chain
	var/list/cast

/datum/ougi_scene/burst/Build()
	beats = list()
	if(!burst_chain) return
	cast = list()
	for(var/mob/M in burst_chain.members)
		if(cast.len >= 4) break
		cast += M
	if(!cast.len) return
	var/datum/ougi_stage/ST = OugiStageById(stage)
	var/t = 2
	for(var/i = 2 to cast.len)
		var/mark = "m[i]"
		var/list/mod = OugiBurstModule(burst_chain.categories[cast[i]], "chain")
		beats += OugiBurstShift(mod, t, mark, OugiBurstSide(ST, mark))
		t += BeatsSpan(mod) + glob.OUGI_BURST_GAP_DS
	var/list/fin = burst_chain.FinisherBeats(category)
	beats += OugiBurstShift(fin, t, "m1", OugiBurstSide(ST, "m1"))
	climax_ds = t + OugiBurstHitAt(fin)
	length_ds = t + BeatsSpan(fin)

/datum/ougi_scene/burst/Who(name)
	if(name == "target") return target
	if(cast && length(name) == 2 && copytext(name, 1, 2) == "m")
		var/i = text2num(copytext(name, 2))
		if(i >= 1 && i <= cast.len) return cast[i]
	return attacker

/datum/ougi_scene/burst/EnterRoom()
	if(!room || !target || !cast || !cast.len) return
	actors = list()
	for(var/i = 1 to cast.len)
		var/mob/M = cast[i]
		if(M) actors[M] = "m[i]"
	actors[target] = "target"
	for(var/mob/M in actors)
		OugiActorEnter(M, room.Mark(actors[M]), room, actors[M] == "target")
	for(var/mob/M in actors)
		if(M == target) M.dir = attacker ? (get_dir(M, attacker) || WEST) : WEST
		else M.dir = get_dir(M, target) || EAST
	if(!camera) camera = new /mob/gfx_camera/ougi_camera
	camera.glide_size = 64
	var/turf/C = room.Mark("camera")
	OugiCamPlace(camera, (C.x - 1) * world.icon_size + world.icon_size / 2, (C.y - 1) * world.icon_size + world.icon_size / 2, C.z)
	backdrop = room.stage ? OugiBackdropById(room.stage.backdrop) : null
	if(backdrop)
		bd_rest_x = GfxCameraWorldX(camera)
		bd_rest_y = GfxCameraWorldY(camera)
		bd_t0 = world.time
		bd_horizon = (OUGI_ROOM_HALF + room.stage.ground_top + 1) * world.icon_size
		spawn() BackdropLoop()

/datum/ougi_scene/burst/OpActorFace(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors)) return
	var/d = ArgNum(a, "dir", 0)
	if(!d)
		var/mob/O = (M == target) ? attacker : target
		d = O ? (get_dir(M, O) || M.dir) : M.dir
	M.dir = d

/datum/ougi_scene/burst/OpHit(list/a)
	if(hit_done) return
	hit_done = 1
	if(preview || !burst_chain)
		if(target && target.loc) OugiHitSpark(target)
		return
	burst_chain.ApplyFinisher(src)

/datum/ougi_scene/burst/OugiChainPlateArgs()
	var/n = cast ? cast.len : 2
	return list("text" = (n >= 4) ? "FULL BURST" : "CHAIN BURST x[n]", "category" = category)
