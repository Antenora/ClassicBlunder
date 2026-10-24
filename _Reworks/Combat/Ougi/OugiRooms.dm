#define OUGI_PREFAB_MAX_W 61
#define OUGI_PREFAB_MAX_H 41
#define OUGI_MARK_ICON 'HUD/build_white.png'
#define OUGI_STANDIN_RING_PX -105
#define OUGI_STANDIN_RING_SCALE 0.3

/area/OugiStage
	name = "Ougi Stage"
	sees_sky = 0
	env_profile_id = "void"
	zone_wind_mult = 0
	Void
		name = "Ougi Void"

/turf/OugiStage
	name = "stage"
	VoidFloor
		name = "void"
		density = 0
		opacity = 0
	Ground
		name = "ground"
		density = 0
		opacity = 0
		Grass
			icon = 'Icons/Turfs/Grass.dmi'
			icon_state = "Grass1"
		Dirt
			icon = 'Icons/Turfs/Dirt1.dmi'

/datum/ougi_stage
	var
		id
		ground_turf
		backdrop
		room_w = OUGI_ROOM_SPAN
		room_h = OUGI_ROOM_SPAN
		ground_top = 0
		env_profile = "void"
		list/mark_offsets
		prefab
		datum/build_import_ctx/prefab_ctx
		has_horizon = 0
		sees_sky = 0
		wind_mult = 0
		weather

/datum/ougi_stage/void
	id = "void"

/datum/ougi_stage/burst
	id = "burst"
	ground_turf = /turf/OugiStage/Ground/Grass
	backdrop = "mountain_dusk"
	room_w = 31
	env_profile = "default"
	mark_offsets = list("target" = list(0, -3), "m1" = list(-5, -3), "m2" = list(3, 0), "m3" = list(5, -3), "m4" = list(-3, -6))

/datum/ougi_stage/mountain_dusk
	id = "mountain_dusk"
	ground_turf = /turf/OugiStage/Ground/Grass
	backdrop = "mountain_dusk"
	room_w = 41
	env_profile = "default"

proc/OugiStageById(id)
	if(!glob.OugiStages) glob.OugiStages = list()
	if(!glob.OugiStages.len)
		for(var/T in typesof(/datum/ougi_stage) - /datum/ougi_stage)
			var/datum/ougi_stage/S = new T
			if(S.id) glob.OugiStages[S.id] = S
	if(!id) return null
	var/datum/ougi_stage/ST = glob.OugiStages[id]
	if(!ST)
		ST = OugiStageFromPrefab(id)
		if(ST) glob.OugiStages[id] = ST
	return ST

var/list/ougi_prefab_missing = list()

proc/OugiPrefabPath(id)
	return "Prefabs/ougi_[id].dmm"

proc/OugiPrefabLogOnce(id, msg)
	if(ougi_prefab_missing[id]) return
	ougi_prefab_missing[id] = 1
	world.log << "OUGI: [msg]"

proc/OugiStageFromPrefab(id)
	if(!istext(id) || !length(id)) return null
	var/f = OugiPrefabPath(id)
	if(!fexists(f))
		OugiPrefabLogOnce(id, "no prefab [f] for stage [id]; the void stage is used")
		return null
	var/datum/build_import_ctx/ctx = BuildImportParse(f)
	if(!ctx || !ctx.rows.len || !ctx.keyLen)
		OugiPrefabLogOnce(id, "prefab [f] could not be parsed; the void stage is used")
		return null
	var/cols = round(length(ctx.rows[1]) / ctx.keyLen)
	var/rows = ctx.rows.len
	if(cols < OUGI_ROOM_SPAN || rows < OUGI_ROOM_SPAN || cols > OUGI_PREFAB_MAX_W || rows > OUGI_PREFAB_MAX_H)
		OugiPrefabLogOnce(id, "prefab [f] is [cols]x[rows]; a stage prefab must be [OUGI_ROOM_SPAN]x[OUGI_ROOM_SPAN] to [OUGI_PREFAB_MAX_W]x[OUGI_PREFAB_MAX_H]; the void stage is used")
		return null
	var/datum/ougi_stage/ST = new
	ST.id = id
	ST.prefab = f
	ST.prefab_ctx = ctx
	ST.room_w = cols
	ST.room_h = rows
	ST.mark_offsets = list()
	var/cxo = round((cols + 1) / 2)
	var/cyo = round((rows + 1) / 2)
	var/list/settings
	for(var/j = 1 to rows)
		var/row = ctx.rows[j]
		for(var/i = 1 to cols)
			var/list/entries = ctx.dict[copytext(row, (i - 1) * ctx.keyLen + 1, i * ctx.keyLen + 1)]
			if(!entries) continue
			for(var/list/E in entries)
				var/p = E["path"]
				if(ispath(p, /obj/Turfs/OugiStage/Mark))
					var/obj/Turfs/OugiStage/Mark/MK = p
					var/nm = initial(MK.mark_name)
					if(nm) ST.mark_offsets[nm] = list(i - cxo, 1 + rows - j - cyo)
				else if(ispath(p, /obj/Turfs/OugiStage/Settings))
					var/list/v = E["vars"]
					settings = OugiSettingsParse(v ? v["desc"] : null)
	OugiStageApplySettings(ST, settings)
	var/list/h = ST.mark_offsets["horizon"]
	if(h)
		ST.has_horizon = 1
		ST.ground_top = h[2]
		ST.mark_offsets -= "horizon"
	return ST

proc/OugiSettingsParse(t)
	if(!istext(t) || !length(t)) return list()
	return params2list(t)

proc/OugiStageApplySettings(datum/ougi_stage/ST, list/S)
	if(!S) S = list()
	var/wx = S["weather"]
	ST.weather = (istext(wx) && (wx in _wx_kinds) && wx != "clear") ? wx : null
	var/wn = text2num(S["wind"])
	ST.wind_mult = isnum(wn) ? clamp(wn, 0, 3) : 0
	var/pf = S["profile"]
	ST.env_profile = (istext(pf) && length(pf)) ? pf : "default"
	ST.sees_sky = text2num(S["sky"]) ? 1 : 0
	if(ST.weather) ST.sees_sky = 1
	var/bd = S["backdrop"]
	ST.backdrop = OugiBackdropById(bd) ? bd : null

proc/OugiPrefabStamp(datum/ougi_stage/ST, ox, oy, oz, gy)
	var/datum/build_import_ctx/ctx = ST.prefab_ctx
	if(!ctx) return 0
	var/list/turfs = list()
	for(var/j = 1 to ST.room_h)
		var/row = ctx.rows[j]
		var/y = oy + ST.room_h - j
		for(var/i = 1 to ST.room_w)
			var/list/entries = ctx.dict[copytext(row, (i - 1) * ctx.keyLen + 1, i * ctx.keyLen + 1)]
			if(!entries) continue
			var/turf/T = locate(ox + i - 1, y, oz)
			if(!T) continue
			var/above = gy && y > gy
			for(var/list/E in entries)
				var/p = E["path"]
				if(!ispath(p, /turf) || above) continue
				var/turf/NT = new p(T)
				BuildImportApplyVars(NT, E["vars"], ctx)
				if(istype(NT, /turf/CustomTurf))
					var/turf/CustomTurf/CT = NT
					CT.InitialType = "/turf/CustomTurf"
					BuildCustomDefForTurf(CT)
				T = NT
				turfs += T
			for(var/list/E in entries)
				var/p = E["path"]
				if(!ispath(p, /obj) || ispath(p, /obj/Turfs/OugiStage)) continue
				var/obj/O = new p(T)
				BuildImportApplyVars(O, E["vars"], ctx)
				O.Savable = 0
				if(istype(O, /obj/Turfs/CustomObj1))
					BuildCustomObjApplyDef(O)
				GfxRefreshStructureMetadata(O)
	if(turfs.len)
		BuildEdgeSmoothAround(turfs, 1)
		for(var/turf/T in turfs)
			LightingRecomputeNear(T)
	return turfs.len

proc/OugiStageReload(id)
	if(!istext(id) || !length(id)) return "No template named."
	var/datum/ougi_stage/old = glob.OugiStages ? glob.OugiStages[id] : null
	if(old && !old.prefab) return "[id] is a built-in stage, not a prefab."
	if(glob.OugiStages) glob.OugiStages -= id
	ougi_prefab_missing -= id
	var/dropped = 0
	var/held = 0
	var/list/all = OugiRoomsList()
	for(var/datum/ougi_room/R in all.Copy())
		if(R.template != id) continue
		if(R.busy)
			R.stale = 1
			held++
		else
			OugiRoomDrop(R)
			dropped++
	var/datum/ougi_stage/ST = OugiStageById(id)
	var/list/rep = list()
	if(!ST)
		rep += "[OugiPrefabPath(id)] did not load; scenes on [id] use the void stage (see the server log)."
	else
		var/list/names = list()
		for(var/k in ST.mark_offsets)
			names += k
		if(ST.has_horizon) names += "horizon"
		rep += "[id]: [ST.room_w]x[ST.room_h], marks [names.len ? jointext(names, ", ") : "none (void offsets)"], weather [ST.weather || "clear"], wind [ST.wind_mult], profile [ST.env_profile], sky [ST.sees_sky ? "on" : "off"], backdrop [ST.backdrop || "none"]."
	rep += "[dropped] free room(s) rebuilt on next use[held ? ", [held] in use (rebuilt when their scene ends)" : ""]."
	return jointext(rep, " ")

proc/OugiRoomDrop(datum/ougi_room/R)
	if(!R) return
	var/list/all = OugiRoomsList()
	all -= R
	if(R.swapmap)
		var/swapmap/M = R.swapmap
		R.swapmap = null
		del M

proc/OugiPrefabTemplates()
	var/list/L = list()
	for(var/f in flist("Prefabs/"))
		if(copytext(f, 1, 6) == "ougi_" && copytext(f, length(f) - 3) == ".dmm")
			L |= copytext(f, 6, length(f) - 3)
	if(glob.OugiStages)
		for(var/k in glob.OugiStages)
			var/datum/ougi_stage/S = glob.OugiStages[k]
			if(S && S.prefab) L |= k
	return L

/obj/Turfs/OugiStage
	name = "Ougi Stage"
	icon = OUGI_MARK_ICON
	Buildable = 0
	Savable = 0
	density = 0
	Destructable = 0
	Grabbable = 0
	Attackable = 0
	layer = MOB_LAYER + 1
	maptext_width = 96
	maptext_y = 24

/obj/Turfs/OugiStage/New()
	..()
	maptext = "<span style=\"[MCARD_FONT]; color:#ffffff\">[OugiStageLabel()]</span>"

/obj/Turfs/OugiStage/proc/OugiStageLabel()
	return name

/obj/Turfs/OugiStage/Mark
	var/mark_name

/obj/Turfs/OugiStage/Mark/OugiStageLabel()
	return mark_name

/obj/Turfs/OugiStage/Mark/Attacker
	name = "Ougi Mark: attacker"
	mark_name = "attacker"
	color = "#ff6a4a"
	Buildable = 1

/obj/Turfs/OugiStage/Mark/Target
	name = "Ougi Mark: target"
	mark_name = "target"
	color = "#4aa8ff"
	Buildable = 1

/obj/Turfs/OugiStage/Mark/Ally1
	name = "Ougi Mark: ally1"
	mark_name = "ally1"
	color = "#7ad46a"
	Buildable = 1

/obj/Turfs/OugiStage/Mark/Ally2
	name = "Ougi Mark: ally2"
	mark_name = "ally2"
	color = "#7ad46a"
	Buildable = 1

/obj/Turfs/OugiStage/Mark/Ally3
	name = "Ougi Mark: ally3"
	mark_name = "ally3"
	color = "#7ad46a"
	Buildable = 1

/obj/Turfs/OugiStage/Mark/Camera
	name = "Ougi Mark: camera"
	mark_name = "camera"
	color = "#ffd23a"
	Buildable = 1

/obj/Turfs/OugiStage/Mark/Horizon
	name = "Ougi Mark: horizon"
	mark_name = "horizon"
	color = "#c070ff"
	Buildable = 1

/obj/Turfs/OugiStage/Settings
	name = "Ougi Room Settings"
	color = "#ffffff"
	Buildable = 1

/obj/Turfs/OugiStage/Settings/OugiStageLabel()
	return "settings"

/obj/Turfs/OugiStage/Settings/proc/OugiSettingsLine()
	var/list/S = OugiSettingsParse(desc)
	return "weather [S["weather"] || "clear"], wind [S["wind"] || "0"], profile [S["profile"] || "default"], sky [text2num(S["sky"]) ? "on" : "off"], backdrop [S["backdrop"] || "none"]"

mob/Mapper/verb/Ougi_Room_Settings()
	set category = "Mapper"
	set name = "Ougi-Room-Settings"
	var/atom/C = usr.client && usr.client.eye ? usr.client.eye : usr
	var/turf/at = get_turf(C)
	if(!at)
		usr << "Stand in the map first."
		return
	var/list/found = list()
	for(var/obj/Turfs/OugiStage/Settings/S in range(15, at))
		found["[S.x],[S.y]: [S.OugiSettingsLine()]"] = S
	if(!found.len)
		usr << "Place an Ougi Room Settings object (OBJECTS palette) inside the room first, then run this again."
		return
	spawn
		var/obj/Turfs/OugiStage/Settings/S
		if(found.len == 1)
			S = found[found[1]]
		else
			var/pick = Ask(usr, "Which settings object?", "Ougi-Room-Settings", null, "pick", found, 1)
			if(!pick) return
			S = found[pick]
		if(!S) return
		var/list/cur = OugiSettingsParse(S.desc)
		var/wx = Ask(usr, "Weather in this room? Any weather turns the sky on.", "Ougi-Room-Settings", cur["weather"] || "clear", "pick", _wx_kinds.Copy(), 1)
		if(isnull(wx)) return
		var/wind = Ask(usr, "Wind strength in this room?", "Ougi-Room-Settings", cur["wind"] || "0", "pick", list("0", "0.25", "0.5", "1", "1.5", "2", "3"), 1)
		if(isnull(wind)) return
		if(!_env_profiles.len) _EnvProfileBoot()
		var/list/profiles = list()
		for(var/k in _env_profiles)
			profiles += k
		var/pf = Ask(usr, "Environment profile?", "Ougi-Room-Settings", cur["profile"] || "default", "pick", profiles, 1)
		if(isnull(pf)) return
		var/sky = Ask(usr, "Does the room see the sky (day and night, weather)?", "Ougi-Room-Settings", text2num(cur["sky"]) ? "Sky on" : "Sky off", "pick", list("Sky on", "Sky off"), 1)
		if(isnull(sky)) return
		var/list/bds = list("none")
		OugiBackdropById("mountain_dusk")
		for(var/k in glob.OugiBackdrops)
			bds += k
		var/bd = Ask(usr, "Parallax backdrop above the horizon mark?", "Ougi-Room-Settings", cur["backdrop"] || "none", "pick", bds, 1)
		if(isnull(bd)) return
		if(!S) return
		var/list/L = list("weather" = wx, "wind" = wind, "profile" = pf, "sky" = (sky == "Sky on" || (wx && wx != "clear")) ? "1" : "0", "backdrop" = (bd == "none") ? "" : bd)
		S.desc = list2params(L)
		S.maptext = "<span style=\"[MCARD_FONT]; color:#ffffff\">settings</span>"
		usr << "Ougi room settings at [S.x],[S.y]: [S.OugiSettingsLine()]. Save-Prefab the room as ougi_<name> to keep them."

/obj/ougi_stand_in
	name = "Ougi"
	icon = OUGI_STANDIN_ICON
	icon_state = "On"
	mouse_opacity = 0
	density = 0
	Savable = 0
	Grabbable = 0
	gfx_transient_visual = 1
	layer = MOB_LAYER - 0.1

/obj/ougi_stand_in/proc/OugiStandInRing(datum/ougi_scene/S)
	var/cat = "Unarmed"
	if(S) cat = S.ougi ? S.ougi.OugiCategory : S.category
	var/image/I = image(OUGI_RING_ICON)
	I.pixel_x = OUGI_STANDIN_RING_PX
	I.pixel_y = OUGI_STANDIN_RING_PX
	I.color = OugiCategoryColor(cat)
	I.blend_mode = BLEND_ADD
	I.appearance_flags = RESET_COLOR | PIXEL_SCALE
	var/matrix/T = matrix()
	T.Scale(OUGI_STANDIN_RING_SCALE)
	I.transform = T
	underlays += I

proc/OugiCategoryColor(cat)
	switch(cat)
		if("Armed") return "#dce6f0"
		if("Gun") return "#ff6a4a"
		if("Energy") return "#5ab4ff"
	return "#ffd23a"

/datum/ougi_room
	var
		id
		template = "void"
		swapmap/swapmap
		area/A
		cx = 0
		cy = 0
		z = 0
		list/marks
		busy = 0
		since = 0
		datum/ougi_stage/stage
		ground
		gy = 0
		stale = 0

/datum/ougi_room/proc/Valid()
	return swapmap && swapmaps_byname[swapmap.id] == swapmap && marks && marks.len

/datum/ougi_room/proc/Mark(name)
	if(!marks) return null
	return marks[name] || marks["camera"]

proc/OugiResolveTemplate(template)
	return OugiStageById(template) ? template : "void"

proc/OugiRoomAcquire(template = "void", ground = null)
	template = OugiResolveTemplate(template)
	var/datum/ougi_stage/ST = OugiStageById(template)
	if(ST && ST.prefab) ground = null
	else if(!ground && ST) ground = ST.ground_turf
	var/key = ground ? "[template]|[ground]" : template
	var/list/R = OugiRoomsList()
	var/count = 0
	var/datum/ougi_room/free
	for(var/datum/ougi_room/O in R)
		if(O.template != key) continue
		if(!O.Valid() || O.stale) continue
		count++
		if(!O.busy && !free) free = O
	if(!free && count < glob.OUGI_ROOM_COPIES)
		free = OugiRoomBuild(key, count + 1, ST, ground)
	if(!free) return null
	free.busy = 1
	free.since = world.time
	return free

proc/OugiRoomRelease(datum/ougi_room/R)
	if(!R) return
	R.busy = 0
	R.since = 0
	if(R.stale) OugiRoomDrop(R)

proc/OugiRoomBuild(key, n, datum/ougi_stage/ST, ground)
	if(!ST) ST = OugiStageById("void")
	var/w = (ST ? ST.room_w : OUGI_ROOM_SPAN) + 2
	var/h = (ST ? ST.room_h : OUGI_ROOM_SPAN) + 2
	var/list/rooms = OugiRoomsList()
	var/rid = "ougi_[ST ? ST.id : "void"]_[n]_[ougi_boot_stamp]_[rooms.len + 1]"
	var/swapmap/M = new /swapmap(rid, w, h, 1)
	if(!M || !M.z1) return null
	var/turf/lo = M.LoCorner()
	var/turf/hi = M.HiCorner()
	M.BuildFilledRectangle(lo, hi, /turf/OugiStage/VoidFloor)
	M.BuildRectangle(lo, hi, /turf/swapmap_border)
	var/cx = M.x1 + round((w - 1) / 2)
	var/cy = M.y1 + round((h - 1) / 2)
	var/gy = 0
	if(ST && ST.prefab)
		if(ST.has_horizon) gy = clamp(cy + ST.ground_top, M.y1 + 1, M.y2 - 1)
		OugiPrefabStamp(ST, M.x1 + 1, M.y1 + 1, M.z1, gy)
		if(gy && gy < M.y2 - 1)
			OugiRimBuild(M.x1 + 1, M.x2 - 1, gy, M.z1)
	else if(ground && ispath(ground, /turf))
		gy = min(cy + (ST ? ST.ground_top : 0), M.y2 - 1)
		for(var/turf/T in block(locate(M.x1 + 1, M.y1 + 1, M.z1), locate(M.x2 - 1, gy, M.z1)))
			new ground(T)
		if(gy < M.y2 - 1)
			OugiRimBuild(M.x1 + 1, M.x2 - 1, gy, M.z1)
	var/area/OugiStage/Void/A = new
	A.env_profile_id = ST ? ST.env_profile : "void"
	if(ST && ST.prefab)
		A.zone_wind_mult = ST.wind_mult
		A.sees_sky = ST.sees_sky
	for(var/turf/T in block(lo, hi))
		A.contents += T
	if(A.sees_sky) DnRegisterNewArea(A)
	if(ST && ST.weather) WxSet(A, ST.weather)
	var/datum/ougi_room/R = new
	R.id = rid
	R.template = key
	R.stage = ST
	R.ground = ground
	R.swapmap = M
	R.A = A
	R.cx = cx
	R.cy = cy
	R.z = M.z1
	R.marks = list()
	R.marks["camera"] = locate(R.cx, R.cy, R.z)
	R.marks["attacker"] = locate(R.cx - 4, R.cy, R.z)
	R.marks["target"] = locate(R.cx + 4, R.cy, R.z)
	R.marks["ally1"] = locate(R.cx - 3, (gy && R.cy + 4 > gy) ? R.cy - 2 : R.cy + 4, R.z)
	R.marks["ally2"] = locate(R.cx - 5, R.cy, R.z)
	R.marks["ally3"] = locate(R.cx - 3, R.cy - 4, R.z)
	if(ST && ST.mark_offsets)
		for(var/k in ST.mark_offsets)
			var/list/o = ST.mark_offsets[k]
			R.marks[k] = locate(R.cx + o[1], R.cy + o[2], R.z)
	if(gy && !(ST && ST.prefab))
		for(var/k in R.marks)
			var/turf/MT = R.marks[k]
			if(MT && MT.y > gy) R.marks[k] = locate(MT.x, gy, R.z)
	R.gy = gy
	rooms += R
	return R

proc/OugiRimCfg(dy)
	var/cfg = dy ? 0 : 256
	var/i = 0
	for(var/list/o in shoreFoamOffs)
		i++
		if(dy + o[2] <= 0)
			cfg |= (1 << (i - 1))
	return cfg

proc/OugiRimCtx(turf/T, dy)
	ElevOrgSheetInit()
	var/cls = dy ? "nD1" : "mx1"
	var/list/rows = dy ? list(2, 1, 0, -1) : list(2, 1, 0, -1, -2)
	var/list/free = elevOrgClasses[cls]
	if(!free) return null
	var/idx = 0
	var/bi = 0
	for(var/pos in free)
		if(dy + rows[round(pos / 3) + 1] <= 0)
			idx |= (1 << bi)
		bi++
	var/w = ((BuildOrgWindowY(T) + 40) % 4) * 4 + BuildOrgWindowX(T)
	return list(0, 0, 0, 0, 0, cls, w, idx, free.len)

proc/OugiRimBuild(xa, xb, y, z)
	for(var/x = xa to xb)
		var/turf/T = locate(x, y, z)
		var/turf/A = locate(x, y + 1, z)
		if(!T || !A) continue
		var/sty = ElevOrgMatStyle(T)
		if(!sty) continue
		var/F = ElevOrgFilter("t", sty, T, OugiRimCfg(0))
		var/AF = ElevOrgFilter("t", sty, A, OugiRimCfg(1))
		if(!F || !AF) continue
		T.filters = F
		var/list/top = list()
		ElevOrgBevImage(T, 1, sty, T, OugiRimCtx(T, 0), top, 0)
		if(top.len) T.overlays += top
		var/image/I = image(T.icon, null, T.icon_state)
		I.dir = T.dir
		I.layer = ElevLayer(1, 5)
		I.filters = AF
		var/list/up = list(I)
		ElevOrgBevImage(A, 1, sty, T, OugiRimCtx(A, 1), up, 0)
		A.overlays += up

proc/OugiFreeTurfNear(turf/T, mob/M)
	if(!T) return null
	if(OugiTurfFree(T, M)) return T
	for(var/r = 1 to 2)
		for(var/turf/S in range(r, T))
			if(get_dist(S, T) != r) continue
			if(OugiTurfFree(S, M)) return S
	return T

proc/OugiTurfFree(turf/T, mob/M)
	if(!T || T.density) return 0
	for(var/atom/movable/A in T)
		if(A != M && A.density && ismob(A)) return 0
	return 1

proc/OugiActorEnter(mob/M, turf/T, datum/ougi_room/R, front = 0)
	if(!M || !T || !R) return 0
	var/turf/home = get_turf(M)
	M.PrevX = M.x
	M.PrevY = M.y
	M.PrevZ = M.z
	M.ougi_return_dir = M.dir
	M.ougi_return_step_x = M.step_x
	M.ougi_return_step_y = M.step_y
	M.ougi_return_flight = M.Flying
	M.ougi_return_pixel_x = M.pixel_x
	M.ougi_return_pixel_y = M.pixel_y
	M.ougi_return_pixel_z = M.pixel_z
	M.ougi_return_state = M.icon_state
	M.ougi_return_transform = M.transform
	if(!M.ougi_added_pixel_scale && !(M.appearance_flags & PIXEL_SCALE))
		M.appearance_flags |= PIXEL_SCALE
		M.ougi_added_pixel_scale = 1
	if(isnull(M.ougi_return_layer)) M.ougi_return_layer = M.layer
	M.layer = front ? OUGI_ACTOR_FRONT_LAYER : OUGI_ACTOR_LAYER
	if(home)
		if(M.ougi_stand_in) del M.ougi_stand_in
		M.ougi_stand_in = new /obj/ougi_stand_in(home)
		M.ougi_stand_in.OugiStandInRing(M.OugiLock)
	M.in_tmp_map = R.swapmap ? R.swapmap.id : "ougi"
	M.loc = T
	M.step_x = 0
	M.step_y = 0
	return 1

proc/OugiActorLeave(mob/M)
	if(!M || isnull(M.PrevX) || isnull(M.PrevY) || isnull(M.PrevZ)) return 0
	var/turf/T = locate(M.PrevX, M.PrevY, M.PrevZ)
	if(!T && M.ougi_stand_in) T = get_turf(M.ougi_stand_in)
	var/turf/F = OugiFreeTurfNear(T, M)
	if(F)
		M.loc = F
		if(F == T)
			M.step_x = M.ougi_return_step_x
			M.step_y = M.ougi_return_step_y
		else
			M.step_x = 0
			M.step_y = 0
	M.dir = M.ougi_return_dir
	M.pixel_x = M.ougi_return_pixel_x
	M.pixel_y = M.ougi_return_pixel_y
	M.pixel_z = M.ougi_return_pixel_z
	if(M.ougi_return_transform) M.transform = M.ougi_return_transform
	if(!isnull(M.ougi_return_state) && !M.KO) M.icon_state = M.ougi_return_state
	M.in_tmp_map = null
	M.PrevX = null
	M.PrevY = null
	M.PrevZ = null
	M.ougi_return_transform = null
	M.ougi_return_state = null
	if(M.ougi_added_pixel_scale)
		M.appearance_flags &= ~PIXEL_SCALE
		M.ougi_added_pixel_scale = 0
	if(!isnull(M.ougi_return_layer))
		M.layer = M.ougi_return_layer
		M.ougi_return_layer = null
		M.UpdateStandingLayer()
	if(M.ougi_stand_in)
		del M.ougi_stand_in
		M.ougi_stand_in = null
	return 1
