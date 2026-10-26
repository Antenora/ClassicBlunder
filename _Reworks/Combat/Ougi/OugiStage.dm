#define OUGI_NOTICE_DS 10

/mob/gfx_camera/ougi_camera
	name = "ougi camera"

/obj/ougi_screen
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	plane = OUGI_FX_PLANE
	layer = 20
	appearance_flags = PIXEL_SCALE | KEEP_APART | RESET_COLOR
	screen_loc = "1,1"

/obj/ougi_screen/wipe
	layer = 30

/obj/ougi_screen/wipe_lines
	layer = 31
	alpha = 107
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/ougi_screen/wipe_fringe
	layer = 29
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/ougi_screen/fade
	layer = 30

/obj/ougi_screen/plate
	layer = 25
	alpha = 0

/obj/ougi_screen/flash_relay
	layer = 21
	render_source = "*ougiflash"

/obj/ougi_flash_master
	plane = OUGI_FLASH_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "1,1"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*ougiflash"

/obj/ougi_screen/nameplate
	layer = 40
	maptext_height = 16

/obj/ougi_screen/focus
	layer = 20.5
	blend_mode = BLEND_ADD
	alpha = 0
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/ougi_screen/ring
	layer = 21.5

/obj/ougi_screen/backdrop
	plane = OUGI_BACKDROP_PLANE
	layer = 1
	appearance_flags = PIXEL_SCALE | KEEP_APART | RESET_COLOR
	var/bd_wrap = 0

/obj/ougi_backdrop_fade
	plane = OUGI_BACKDROP_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "1,1"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER

/datum/ougi_backdrop
	var
		id
		icon
		list/layers
		layer_w = 320
		layer_h = 240
		scale = 2
		overlap = 160

/datum/ougi_backdrop/mountain_dusk
	id = "mountain_dusk"
	icon = OUGI_BD_MOUNTAIN_DUSK_ART
	layers = list(list("sky", 0.02, 0), list("far_mountains", 0.10, 0), list("middle_mountains", 0.25, 0), list("myst", 0.45, 6), list("far_trees", 0.65, 0), list("near_trees", 0.85, 0))

/datum/ougi_backdrop/sky_pink
	id = "sky_pink"
	icon = OUGI_BD_SKY_PINK_ART
	layer_w = 272
	layer_h = 160
	scale = 4
	overlap = 352
	layers = list(list("back", 0.04, 0), list("clouds", 0.3, 0))

proc/OugiBackdropById(id)
	if(!id) return null
	if(!glob.OugiBackdrops) glob.OugiBackdrops = list()
	if(!glob.OugiBackdrops.len)
		for(var/T in typesof(/datum/ougi_backdrop) - /datum/ougi_backdrop)
			var/datum/ougi_backdrop/B = new T
			if(B.id) glob.OugiBackdrops[B.id] = B
	return glob.OugiBackdrops[id]

/obj/ougi_actor
	mouse_opacity = 0
	Savable = 0
	density = 0
	gfx_transient_visual = 1
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	var/tmp
		list/ougi_ghost_color
		ougi_ghost_alpha = 0
		ougi_ghost_born = 0
		ougi_ghost_life = 0

/obj/Effects/OugiFX
	mouse_opacity = 0
	Savable = 0
	Lifetime = -1
	appearance_flags = PIXEL_SCALE

/client/var/tmp/obj/ougi_screen/wipe_lines/ougi_wipe_lines
/client/var/tmp/obj/ougi_screen/wipe_fringe/ougi_wipe_fringe
/client/var/tmp/obj/ougi_screen/fade/ougi_fade
/client/var/tmp/ougi_wipe_d = 1
/client/var/tmp/list/ougi_actor_plates
/client/var/tmp/list/ougi_flash_fx
/client/var/tmp/datum/ougi_view_rig/ougi_view_rig

/datum/ougi_view_rig/proc/WorldTransform(mag, tx, ty, time)
	return 0

/datum/ougi_view_rig/proc/Drop()
	return

/datum/ougi_scene
	var
		id
		category = "Energy"
		stage = "void"
		length_ds = 50
		climax_ds = 35
		list/prelude
		list/beats
		mob/attacker
		mob/target
		obj/Skills/Ougi/ougi
		datum/ougi_room/room
		mob/gfx_camera/ougi_camera/camera
		list/watchers = list()
		list/locked = list()
		list/actors = list()
		list/clients = list()
		list/temp_atoms = list()
		list/temp_lights = list()
		obj/ougi_screen/plate/flash_plate
		obj/ougi_screen/nameplate/nameplate
		live = 0
		ended = 0
		fizzled = 0
		preview = 0
		run_prelude = 0
		hit_done = 0
		beat_failed = 0
		climax_mult = 0
		time_scale = 1
		zoom = 1
		zoom_from = 1
		zoom_t0 = 0
		zoom_time = 0
		datum/ougi_backdrop/backdrop
		datum/ougi_backdrop/bd_old
		bd_rest_x = 0
		bd_rest_y = 0
		bd_t0 = 0
		bd_frozen_at = 0
		bd_horizon = 0
		bd_last_dx
		bd_last_dy
		bd_last_z
		max_ds = 0
		started_at = 0
		wipe_from = -1
		list/reduced_motion = list()
		list/noticed = list()
		notice_next = 0
		wx_saved = 0
		wx_prev_kind
		wx_prev_sky = 0
		list/surfaces
		list/icon_defines
		pause_at = -1
		paused = 0
		paused_total = 0
		pause_hold_ds = 0
		pause_shot = 0

/datum/ougi_scene/New()
	..()
	if(!prelude) prelude = OugiDefaultPrelude()
	Build()

/datum/ougi_scene/proc/Build()
	return

/datum/ougi_scene/proc/BeatsSpan(list/B)
	var/span = 0
	for(var/list/beat in B)
		if(isnum(beat[1])) span = max(span, beat[1])
	return span

/datum/ougi_scene/proc/SlowmoFactor()
	var/f = 1
	for(var/list/beat in beats)
		if(beat.len >= 3 && beat[2] == "slowmo")
			var/list/a = beat[3]
			if(a && isnum(a["scale"])) f *= max(a["scale"], 1)
	return f

/datum/ougi_scene/proc/EstimateDs()
	var/t = OUGI_FLASH_DS + 2 * (OUGI_WIPE_IN_DS + OUGI_WIPE_HOLD_DS + OUGI_WIPE_OUT_DS) + OUGI_WHITEOUT_DS + OUGI_HIT_SETTLE_DS
	t += BeatsSpan(beats) * SlowmoFactor() + 10
	if(run_prelude) t += BeatsSpan(prelude) + 60
	return round(t + 20)

proc/OugiDefaultPrelude()
	return list(\
		list(0, "cam_move", list("to" = "attacker", "time" = 5)),\
		list(OUGI_PRELUDE_HOLD_DS, "transform"),\
		list(OUGI_PRELUDE_HOLD_DS + 1, "flash", list("color" = "#ffffff", "in" = 1, "hold" = 1, "out" = 3)),\
		list(OUGI_PRELUDE_HOLD_DS + 6, "cam_move", list("to" = "camera", "time" = 5)),\
		list(OUGI_PRELUDE_HOLD_DS + 11, "hold"))

/datum/ougi_scene/proc/Who(name)
	if(name == "target") return target
	return attacker

/datum/ougi_scene/proc/Begin()
	set waitfor = 0
	live = 1
	started_at = world.time
	max_ds = EstimateDs()
	for(var/mob/M in watchers.Copy())
		if(OugiLockApply(src, M) && M.client)
			clients |= M.client
	for(var/client/C in clients)
		ReducedMotion(C)
	spawn() Watchdog()
	spawn() KeeperLoop()
	NoticeScan()
	FlashIn()
	sleep(OUGI_FLASH_DS)
	if(!live) return
	if(!preview && attacker && attacker.OugiGuardStops(target))
		Fizzle()
		return
	if(!attacker || !target)
		End(1)
		return
	wipe_from = (attacker.x <= target.x) ? -1 : 1
	WipeCover(wipe_from)
	sleep(OUGI_WIPE_IN_DS)
	if(!live) return
	EnterRoom()
	FlashOut()
	for(var/client/C in clients)
		OugiClientEnterDisplay(C, src)
	sleep(OUGI_WIPE_HOLD_DS)
	if(!live) return
	WipeReveal(wipe_from)
	sleep(OUGI_WIPE_OUT_DS)
	if(!live) return
	spawn(OUGI_PLATE_DELAY_DS) PlateRun()
	if(run_prelude) RunBeats(prelude)
	if(live) RunBeats(beats)
	if(live && !hit_done) OpHit(null)
	if(live) Exit()

/datum/ougi_scene/proc/Watchdog()
	while(live && (paused || world.time < started_at + max_ds + 20 + paused_total))
		sleep(10)
	if(live)
		world.log << "OUGI: watchdog ended [id] after [max_ds + 20] ds"
		End(1)

/datum/ougi_scene/proc/PauseHere()
	paused = 1
	var/t0 = world.time
	bd_frozen_at = t0
	if(pause_shot)
		spawn(pause_shot)
			if(live && paused)
				for(var/client/C in clients)
					if(C.ougi_in_display) winset(C, null, "command=.screenshot auto")
	var/until = pause_hold_ds > 0 ? world.time + pause_hold_ds : 0
	while(live && paused && (!until || world.time < until))
		sleep(world.tick_lag)
	bd_t0 += world.time - t0
	bd_frozen_at = 0
	paused_total += world.time - t0
	paused = 0
	pause_at = -1

/datum/ougi_scene/proc/KeeperLoop()
	while(live)
		for(var/mob/M in locked)
			OugiHoldMob(M)
		if(attacker && attacker.ougi_was_rp == 0 && attacker.OugiLock == src && !attacker.PureRPMode)
			attacker.CutsceneModeOn(1)
		if(world.time >= notice_next) NoticeScan()
		sleep(OUGI_KEEPER_DS)

/datum/ougi_scene/proc/ReducedMotion(client/C)
	if(!C) return 0
	if(isnull(reduced_motion[C])) reduced_motion[C] = GfxReducedMotion(C) ? 1 : 0
	return reduced_motion[C]

/datum/ougi_scene/proc/NoticeName()
	if(ougi) return ougi.name
	if(istype(src, /datum/ougi_scene/burst)) return "a Chain Burst"
	return "an Ougi"

/datum/ougi_scene/proc/NoticeSpots()
	var/list/L = list()
	for(var/mob/M in list(attacker, target) + actors)
		if(!M) continue
		if(M.ougi_stand_in && M.ougi_stand_in.loc) L |= get_turf(M.ougi_stand_in)
		else if(M.loc && !(room && M.z == room.z)) L |= get_turf(M)
	return L

/datum/ougi_scene/proc/NoticeScan()
	notice_next = world.time + OUGI_NOTICE_DS
	if(preview || !live || !attacker || !target) return
	var/list/spots = NoticeSpots()
	if(!spots.len) return
	var/line = "<b>[attacker] is unleashing [NoticeName()] on [target]!</b>"
	for(var/mob/Players/P in players)
		if(!P.client || noticed[P] || P.OugiLock || (P in locked)) continue
		for(var/turf/T in spots)
			if(P.z == T.z && get_dist(P, T) <= glob.OUGI_LOCK_RANGE)
				noticed[P] = 1
				P << line
				break

/datum/ougi_scene/proc/RunBeats(list/B)
	if(!B) return 1
	var/t = 0
	BeatClockStart()
	for(var/list/beat in B)
		if(!live) return 0
		var/at = beat[1]
		var/wait = (at - t) * time_scale * OugiTimeScale()
		if(pause_at >= 0 && at > pause_at)
			PauseHere()
			if(!live) return 0
		BeatSleep(wait)
		t = at
		if(!live) return 0
		var/op = beat[2]
		var/list/a = beat.len >= 3 ? beat[3] : null
		var/ok = 0
		try
			DoOp(op, a)
			ok = 1
		catch(var/exception/E)
			world.log << "OUGI: beat [op] at [at] in [id] failed: [E] ([E.file]:[E.line])"
		if(!ok)
			beat_failed = 1
			return 0
	return 1

/datum/ougi_scene/proc/BeatClockStart()
	return

/datum/ougi_scene/proc/BeatSleep(wait)
	if(wait > 0) sleep(wait)

/datum/ougi_scene/proc/DoOp(op, list/a)
	switch(op)
		if("hold") return
		if("actor_move") OpActorMove(a)
		if("actor_offset") OpActorMove(a)
		if("actor_state") OpActorState(a)
		if("actor_face") OpActorFace(a)
		if("actor_scale") OpActorScale(a)
		if("ghost") OpGhost(a)
		if("cam_move") OpCamMove(a)
		if("cam_zoom") OpCamZoom(a)
		if("cam_shake") OpCamShake(a)
		if("cut") OpCut(a)
		if("light") OpLight(a)
		if("fx") OpFX(a)
		if("flash") OpFlash(a)
		if("plate") PlateRun(a)
		if("slowmo") OpSlowmo(a)
		if("hit") OpHit(a)
		if("transform") OpTransform(a)
		if("weather") OpWeather(a)
		if("trail", "sfx")
			world.log << "OUGI: op [op] is unimplemented in [id]; skipped"
		else
			world.log << "OUGI: unknown op [op] in [id]; skipped"

/datum/ougi_scene/proc/ArgNum(list/a, key, def)
	if(!a || !isnum(a[key])) return def
	return a[key]

/datum/ougi_scene/proc/ArgText(list/a, key, def)
	if(!a || isnull(a[key])) return def
	return a[key]

/datum/ougi_scene/proc/Ds(n)
	return max(0, n * time_scale * OugiTimeScale())

/datum/ougi_scene/proc/MarkTurf(name)
	if(!room) return null
	return room.Mark(name)

/datum/ougi_scene/proc/OpActorMove(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors)) return
	var/turf/home = MarkTurf(actors[M])
	var/turf/dest = MarkTurf(ArgText(a, "to", actors[M]))
	if(!home || !dest) return
	var/px = round(M.ougi_return_pixel_x + (dest.x - home.x) * world.icon_size + ArgNum(a, "dx", 0), 1)
	var/py = round(M.ougi_return_pixel_y + (dest.y - home.y) * world.icon_size + ArgNum(a, "dy", 0), 1)
	if(ArgNum(a, "walk", 0))
		ActorWalk(M, home, px - M.pixel_x, py - M.pixel_y, Ds(ArgNum(a, "time", 3)))
		return
	if(actor_walks && actor_walks[M])
		var/list/w = actor_walks[M]
		M.glide_size = w[1]
		actor_walks -= M
	var/list/d0 = ActorDisp(M, home)
	ActorMoveRun(M, px - d0[1], py - d0[2], Ds(ArgNum(a, "time", 3)), OugiEaseFlags(ArgText(a, "ease", "sine")))

/datum/ougi_scene/proc/OpActorState(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors)) return
	var/st = ArgText(a, "state", "")
	if(st && M.icon && !(st in icon_states(M.icon))) st = ""
	M.icon_state = st

/datum/ougi_scene/proc/OpActorFace(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors)) return
	var/d = ArgNum(a, "dir", 0)
	if(!d)
		var/mob/O = (M == attacker) ? target : attacker
		d = O ? (get_dir(M, O) || M.dir) : M.dir
	M.dir = d

/datum/ougi_scene/proc/OpActorScale(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors)) return
	if(!actor_scales) actor_scales = list()
	actor_scales[M] = max(0.01, ArgNum(a, "scale", 1)) // no upper limit; 0 would collapse the pose matrix
	ActorPose(M, Ds(ArgNum(a, "time", 2)), OugiEaseFlags(ArgText(a, "ease", "linear")))

/datum/ougi_scene/proc/OpGhost(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !M.loc) return
	var/obj/ougi_actor/G = new(M.loc)
	G.appearance = M.appearance
	G.mouse_opacity = 0
	var/ga = ArgNum(a, "alpha", 160)
	G.alpha = ga
	var/list/GC = OugiSceneTintMatrix(ArgText(a, "color", null))
	if(length(GC) >= 12)
		G.ougi_ghost_color = GC
		G.alpha = 255
		G.color = OugiGhostFold(GC, ga)
	G.step_x = M.step_x
	G.step_y = M.step_y
	G.layer = M.layer - 0.01
	if(ArgNum(a, "front", 0))
		var/top = M.layer
		for(var/mob/X in actors)
			top = max(top, X.layer)
		G.layer = top + 0.01
	G.pixel_x += ArgNum(a, "dx", 0)
	G.pixel_y += ArgNum(a, "dy", 0)
	var/st = ArgText(a, "state", null)
	if(istext(st))
		if(st && G.icon && !(st in icon_states(G.icon))) st = ""
		G.icon_state = st
	var/list/crop = ArgText(a, "crop", null)
	if(islist(crop))
		var/mk = OugiGhostMask(G.icon, G.icon_state, crop, (M.dir & WEST) ? 1 : 0)
		if(mk)
			G.appearance_flags |= KEEP_TOGETHER
			G.filters += filter(type = "alpha", icon = mk)
	temp_atoms += G
	var/life = Ds(ArgNum(a, "life", 4))
	G.ougi_ghost_alpha = ga
	G.ougi_ghost_born = world.time
	G.ougi_ghost_life = life
	if(G.ougi_ghost_color) animate(G, color = OugiGhostFold(G.ougi_ghost_color, 0), time = life)
	else animate(G, alpha = 0, time = life)
	spawn(life + 1)
		temp_atoms -= G
		GfxReleaseAtom(G)
		del G
	return G

/datum/ougi_scene/proc/CamWorldX()
	return camera ? GfxCameraWorldX(camera) : 0

/datum/ougi_scene/proc/CamWorldY()
	return camera ? GfxCameraWorldY(camera) : 0

proc/OugiCamPlace(mob/gfx_camera/G, wx, wy, z)
	if(!G || !z) return 0
	var/tx = clamp(floor(wx / world.icon_size) + 1, 1, world.maxx)
	var/ty = clamp(floor(wy / world.icon_size) + 1, 1, world.maxy)
	var/turf/T = locate(tx, ty, z)
	if(!T) return 0
	G.loc = T
	G.step_x = round(wx - ((tx - 1) * world.icon_size + world.icon_size / 2), 1)
	G.step_y = round(wy - ((ty - 1) * world.icon_size + world.icon_size / 2), 1)
	return 1

/datum/ougi_scene/proc/OpCamMove(list/a)
	if(!camera || !room) return
	var/sx = CamWorldX()
	var/sy = CamWorldY()
	var/ex = sx
	var/ey = sy
	var/dest = ArgText(a, "to", null)
	if(dest)
		var/turf/T = MarkTurf(dest)
		var/mob/M = (dest == "attacker" || dest == "target") ? Who(dest) : null
		if(M && M.loc && M.z == room.z)
			var/list/mp = OugiSceneMobPoint(M)
			ex = mp[1]
			ey = mp[2]
		else if(T)
			ex = (T.x - 1) * world.icon_size + world.icon_size / 2
			ey = (T.y - 1) * world.icon_size + world.icon_size / 2
	ex += ArgNum(a, "dx", 0)
	ey += ArgNum(a, "dy", 0)
	var/ticks = max(1, round(Ds(ArgNum(a, "time", 4)) / world.tick_lag))
	var/sine = ArgText(a, "easing", null) == "sine"
	spawn()
		var/lx = round(sx, 1)
		var/ly = round(sy, 1)
		for(var/i = 1 to ticks)
			if(!live || !camera) return
			var/f = i / ticks
			f = sine ? 0.5 - 0.5 * cos(180 * f) : f * f * (3 - 2 * f)
			var/nx = sx + (ex - sx) * f
			var/ny = sy + (ey - sy) * f
			if(sine)
				camera.glide_size = max(1, sqrt((round(nx, 1) - lx) ** 2 + (round(ny, 1) - ly) ** 2))
				lx = round(nx, 1)
				ly = round(ny, 1)
			else
				camera.glide_size = max(1, abs(ex - sx) / ticks + abs(ey - sy) / ticks)
			OugiCamPlace(camera, nx, ny, room.z)
			sleep(world.tick_lag)

/datum/ougi_scene/proc/CurrentZoom()
	if(zoom_time <= 0 || world.time >= zoom_t0 + zoom_time) return zoom
	var/p = (world.time - zoom_t0) / zoom_time
	p = 1 - (1 - p) * (1 - p)
	return zoom_from + (zoom - zoom_from) * p

/datum/ougi_scene/proc/OpCamZoom(list/a)
	zoom_from = CurrentZoom()
	zoom = clamp(ArgNum(a, "mag", 1), 0.5, 3)
	var/t = Ds(ArgNum(a, "time", 2))
	zoom_t0 = world.time
	zoom_time = t
	for(var/client/C in clients)
		if(C.ougi_in_display) OugiClientWorldTransform(C, zoom, 0, 0, t)

proc/OugiClientWorldTransform(client/C, mag, tx, ty, time)
	if(!C) return
	if(C.ougi_view_rig && C.ougi_view_rig.WorldTransform(mag, tx, ty, time)) return
	var/matrix/M = C.WorldMagMatrix()
	if(mag != 1) M.Scale(mag)
	if(tx || ty) M.Translate(tx, ty)
	for(var/obj/O in list(C.client_plane_master, C.fx_relay, C.fxnb_relay, C.world_overlay_master))
		if(!O) continue
		if(time > 0) animate(O, transform = M, time = time, easing = QUAD_EASING | EASE_OUT)
		else O.transform = M

proc/OugiClientSharpFx(client/C, on)
	if(!C) return
	for(var/obj/O in list(C.fx_relay, C.fxnb_relay))
		if(on) O.appearance_flags |= PIXEL_SCALE
		else O.appearance_flags &= ~PIXEL_SCALE

/datum/ougi_scene/proc/OpCamShake(list/a)
	var/s = ArgNum(a, "strength", 6)
	var/ticks = max(1, round(Ds(ArgNum(a, "time", 4)) / world.tick_lag))
	for(var/client/C in clients)
		if(!C.ougi_in_display || ReducedMotion(C)) continue
		spawn()
			for(var/i = 1 to ticks)
				if(!C || !live || !C.ougi_in_display) return
				var/k = s * (1 - (i - 1) / ticks)
				OugiClientWorldTransform(C, zoom, rand(-k, k), rand(-k, k), 0)
				sleep(world.tick_lag)
			if(C && C.ougi_in_display) OugiClientWorldTransform(C, zoom, 0, 0, 0)

/datum/ougi_scene/proc/EnsureFlashPlate()
	if(!flash_plate)
		flash_plate = new /obj/ougi_screen/plate
		flash_plate.icon = OugiSolidIcon(OUGI_WHITE_ICON)
	return flash_plate

/datum/ougi_scene/proc/FitPlateFor(client/C)
	var/obj/ougi_screen/plate/P = EnsureFlashPlate()
	var/list/vp = OugiViewPx(C)
	var/matrix/M = matrix()
	M.Scale(vp[1] / 32 + 0.1, vp[2] / 32 + 0.1)
	M.Translate(vp[1] / 2 - 16, vp[2] / 2 - 16)
	P.transform = M

/datum/ougi_scene/proc/OpCut(list/a)
	var/obj/ougi_screen/plate/P = EnsureFlashPlate()
	P.color = ArgText(a, "color", "#ffffff")
	P.alpha = 255
	spawn(world.tick_lag)
		if(P) P.alpha = 0

/datum/ougi_scene/proc/OpFlash(list/a)
	var/obj/ougi_screen/plate/P = EnsureFlashPlate()
	P.color = ArgText(a, "color", "#ffffff")
	var/peak = ArgNum(a, "alpha", 255)
	var/ti = Ds(ArgNum(a, "in", 1))
	var/th = Ds(ArgNum(a, "hold", 1))
	var/tout = Ds(ArgNum(a, "out", 3))
	animate(P, alpha = peak, time = ti)
	animate(alpha = peak, time = th)
	animate(alpha = 0, time = tout)

/datum/ougi_scene/proc/OpLight(list/a)
	var/turf/T = MarkTurf(ArgText(a, "at", "camera"))
	if(!T) return
	var/datum/lightsource/L = AddLightSource(T, ArgNum(a, "radius", 5), ArgText(a, "color", "#ffffff"), ArgNum(a, "alpha", 0))
	if(!L) return
	temp_lights += L
	var/life = Ds(ArgNum(a, "life", 10))
	spawn(life)
		if(L in temp_lights)
			temp_lights -= L
			RemoveLightSource(L)

/datum/ougi_scene/proc/OpFX(list/a)
	var/mob/M = null
	var/at = ArgText(a, "at", "target")
	if(at == "attacker" || at == "target") M = Who(at)
	var/turf/T = (M && M.loc && room && M.z == room.z) ? M.loc : MarkTurf(at)
	if(!T) return
	var/ic = ArgText(a, "icon", null)
	if(!ic) return
	var/obj/Effects/OugiFX/F = new(T)
	F.icon = ic
	F.icon_state = ArgText(a, "state", "")
	F.pixel_x = ArgNum(a, "x", 0) + (M ? M.pixel_x : 0)
	F.pixel_y = ArgNum(a, "y", 0) + (M ? M.pixel_y : 0)
	if(M && T == M.loc)
		F.step_x = M.step_x
		F.step_y = M.step_y
	F.blend_mode = ArgNum(a, "blend", BLEND_DEFAULT)
	var/fc = ArgText(a, "color", null)
	if(fc)
		var/list/FC = OugiSceneTintMatrix(fc)
		if(FC) F.color = FC
	if(ArgNum(a, "under", 0))
		F.plane = FLOAT_PLANE
		F.layer = MOB_LAYER - 0.1
	var/s = ArgNum(a, "scale", 1)
	if(s != 1)
		var/matrix/FM = matrix()
		FM.Scale(s)
		F.transform = FM
	temp_atoms += F
	//icon animations share one clock per state, so a reused animated icon joins mid-loop; flick plays it from frame 1
	if(ArgNum(a, "restart", 0)) flick(F.icon_state || F.icon, F)
	var/life = Ds(ArgNum(a, "life", 6))
	spawn(life)
		temp_atoms -= F
		GfxReleaseAtom(F)
		del F
	return F

/datum/ougi_scene/proc/OpWeather(list/a)
	if(!room || !room.A) return
	var/area/A = room.A
	var/kind = ArgText(a, "kind", "clear")
	if(!(kind in _wx_kinds))
		world.log << "OUGI: weather kind [kind] is unknown in [id]; skipped"
		return
	if(!wx_saved)
		wx_saved = 1
		wx_prev_kind = A.wx_kind
		wx_prev_sky = A.sees_sky
	if(kind == "clear")
		A.sees_sky = wx_prev_sky
		WxSet(A, null)
	else
		A.sees_sky = 1
		WxSet(A, kind)

/datum/ougi_scene/proc/RestoreWeather()
	if(!wx_saved) return
	wx_saved = 0
	if(!room || !room.A) return
	room.A.sees_sky = wx_prev_sky
	WxSet(room.A, wx_prev_kind)

/datum/ougi_scene/proc/OpSlowmo(list/a)
	time_scale = max(0.1, ArgNum(a, "scale", 1))

/datum/ougi_scene/proc/OpTransform(list/a)
	if(!attacker || preview) return
	attacker.OugiTensionChecks()
	if(attacker.OugiLock == src && !attacker.ougi_was_rp)
		if(!attacker.PureRPMode) attacker.CutsceneModeOn(1)
		OugiHoldMob(attacker)

/datum/ougi_scene/proc/OpHit(list/a)
	if(hit_done) return
	hit_done = 1
	if(!attacker || !target || !ougi) return
	if(preview || climax_mult <= 0)
		if(target.loc && ArgNum(a, "ring", 1)) OugiHitSpark(target)
		return
	var/obj/Skills/AutoHit/OugiStrike/K = ougi.OugiGetStrike()
	K.DamageMult = climax_mult * ArgNum(a, "mult", 1)
	attacker.Target = target
	var/rp_a = attacker.ougi_was_rp
	var/rp_t = target.ougi_was_rp
	var/st_a = attacker.Stasis
	var/st_t = target.Stasis
	var/mp = target.mirror_parry_active
	var/mr = target.mirror_reflect_active
	var/rg = target.passive_handler ? target.passive_handler.Get("RoyalGuarding") : 0
	attacker.Stasis = 0
	target.Stasis = 0
	target.mirror_parry_active = FALSE
	target.mirror_reflect_active = FALSE
	if(rg) target.passive_handler.Set("RoyalGuarding", 0)
	attacker.Activate(K, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE, noAdjust = TRUE)
	// the settle runs beside the scene: sleeping here pushed every later beat 3 ds back in real uses only
	OugiHitSettle(K, rp_a, rp_t, st_a, st_t, mp, mr, rg)

/datum/ougi_scene/proc/OugiHitSettle(obj/Skills/AutoHit/OugiStrike/K, rp_a, rp_t, st_a, st_t, mp, mr, rg)
	set waitfor = 0
	sleep(OUGI_HIT_SETTLE_DS)
	if(target)
		target.mirror_parry_active = mp
		target.mirror_reflect_active = mr
		if(rg && target.passive_handler) target.passive_handler.Set("RoyalGuarding", rg)
		if(rp_t) target.Stasis = st_t
		else if(target.OugiLock == src) OugiHoldMob(target)
		else target.Stasis = target.ougi_prev_stasis
	if(attacker)
		if(rp_a) attacker.Stasis = st_a
		else if(attacker.OugiLock == src) OugiHoldMob(attacker)
	if(K)
		K.DamageMult = 0
		K.Using = 0

proc/OugiHitSpark(mob/M)
	if(!M) return
	KenShockwave(M, icon = OUGI_RING_ICON, Size = 0.4, Blend = 2, Time = 6)

/datum/ougi_scene/proc/EnterRoom()
	if(!room || !attacker || !target) return
	actors = list()
	actors[attacker] = "attacker"
	actors[target] = "target"
	for(var/mob/M in actors)
		OugiActorEnter(M, room.Mark(actors[M]), room, actors[M] == "target")
	attacker.dir = EAST
	target.dir = WEST
	if(!camera) camera = new /mob/gfx_camera/ougi_camera
	camera.glide_size = 64
	var/turf/C = room.Mark("camera")
	OugiCamPlace(camera, (C.x - 1) * world.icon_size + world.icon_size / 2, (C.y - 1) * world.icon_size + world.icon_size / 2, C.z)
	backdrop = room.stage ? OugiBackdropById(room.stage.backdrop) : null
	if(backdrop)
		bd_rest_x = GfxCameraWorldX(camera)
		bd_rest_y = GfxCameraWorldY(camera)
		bd_t0 = world.time
		bd_horizon = OugiRoomHorizonPx(room)
		spawn() BackdropLoop()

proc/OugiRoomHorizonPx(datum/ougi_room/R)
	var/gt = (R && R.stage) ? R.stage.ground_top : 0
	var/turf/C = R ? R.Mark("camera") : null
	if(R && R.gy && C) gt = R.gy - C.y
	return (OUGI_ROOM_HALF + gt + 1) * world.icon_size

/datum/ougi_scene/proc/BackdropLoop()
	var/g = bd_loop_gen
	while(live && (backdrop || bd_old) && g == bd_loop_gen)
		BackdropSync(world.tick_lag)
		sleep(world.tick_lag)

/datum/ougi_scene/proc/BackdropSync(time, client/only)
	if(!backdrop && !bd_old) return
	var/dx = camera ? GfxCameraWorldX(camera) - bd_rest_x : 0
	var/dy = camera ? GfxCameraWorldY(camera) - bd_rest_y : 0
	var/z = CurrentZoom()
	var/moved = only || BackdropLook(world.time + time) || dx != bd_last_dx || dy != bd_last_dy || z != bd_last_z
	bd_last_dx = dx
	bd_last_dy = dy
	bd_last_z = z
	var/el = ((bd_frozen_at ? bd_frozen_at : world.time) - bd_t0) / 10
	for(var/client/C in (only ? list(only) : clients))
		if(!C.ougi_in_display) continue
		if(backdrop && C.ougi_backdrop_objs) BackdropSyncSet(C, backdrop, C.ougi_backdrop_objs, dx, dy, z, el, time, moved)
		if(bd_old && C.ougi_backdrop_old) BackdropSyncSet(C, bd_old, C.ougi_backdrop_old, dx, dy, z, el, time, moved)

/datum/ougi_scene/proc/BackdropSyncSet(client/C, datum/ougi_backdrop/B, list/objs, dx, dy, z, el, time, moved)
	var/list/vp = OugiViewPx(C)
	var/i = 0
	var/first = 1
	var/half = round(OUGI_BD_COPIES / 2)
	for(var/list/L in B.layers)
		var/depth = L[2]
		var/drift = L[3]
		if(!moved && !drift)
			i += (first ? OUGI_BD_COPIES * 2 : OUGI_BD_COPIES)
			first = 0
			continue
		var/lz = 1 + (z - 1) * depth
		var/s = B.scale * lz
		var/step = max(1, floor(B.layer_w * s))
		var/off = -(dx * depth + drift * el) * lz
		var/wn = floor(off / step + 0.5)
		off -= wn * step
		var/bottom = vp[2] / 2 + (bd_horizon - B.overlap - vp[2] / 2) * lz - dy * depth * lz
		if(first && bottom + B.layer_h * s < vp[2])
			bottom = vp[2] - B.layer_h * s
		var/mirror = first
		var/gap = first && vp[2] / 2 + (bd_horizon - vp[2] / 2 - dy) * z < bottom + world.icon_size * z
		first = 0
		var/ccy = bottom + B.layer_h * s / 2
		for(var/k = -half to half)
			i++
			if(i > objs.len) break
			var/obj/ougi_screen/backdrop/O = objs[i]
			var/matrix/M = matrix()
			M.Scale(s)
			M.Translate(vp[1] / 2 + off + k * step - B.layer_w / 2, ccy - B.layer_h / 2)
			BackdropPlace(O, M, O.bd_wrap == wn ? time : 0)
			O.bd_wrap = wn
			if(!mirror) continue
			i++
			if(i > objs.len) break
			var/obj/ougi_screen/backdrop/F = objs[i]
			if(!gap)
				if(!isnull(F.bd_wrap))
					C.screen -= F
					F.bd_wrap = null
				continue
			var/entering = isnull(F.bd_wrap)
			if(entering) C.screen += F
			var/matrix/FM = matrix()
			FM.Scale(s, -s)
			FM.Translate(vp[1] / 2 + off + k * step - B.layer_w / 2, bottom - B.layer_h * s / 2 - B.layer_h / 2)
			BackdropPlace(F, FM, (!entering && F.bd_wrap == wn) ? time : 0, ANIMATION_LINEAR_TRANSFORM)
			F.bd_wrap = wn

/datum/ougi_scene/proc/BackdropLook(t)
	return null

/datum/ougi_scene/proc/BackdropFadeApply(client/C)
	return

/datum/ougi_scene/proc/BackdropPlace(obj/O, matrix/M, time, flags = 0)
	var/list/look = BackdropLook(world.time + max(time, 0))
	if(time > 0)
		if(!look) animate(O, transform = M, time = time, flags = flags)
		else animate(O, transform = M, color = look, time = time, flags = flags)
		return
	animate(O)
	O.transform = M
	if(look) O.color = look

proc/OugiClientBackdrop(client/C, datum/ougi_scene/S)
	OugiClientClearBackdrop(C)
	if(!C || !S || !S.backdrop) return
	C.ougi_backdrop_objs = list()
	var/n = 0
	for(var/list/L in S.backdrop.layers)
		n++
		for(var/k = 1 to (n == 1 ? OUGI_BD_COPIES * 2 : OUGI_BD_COPIES))
			var/obj/ougi_screen/backdrop/O = new
			O.icon = S.backdrop.icon
			O.icon_state = L[1]
			O.layer = n
			C.ougi_backdrop_objs += O
			C.screen += O
	S.BackdropSync(0, C)
	S.BackdropFadeApply(C)

proc/OugiClientClearBackdrop(client/C)
	OugiClientEndBackdropFade(C)
	if(!C || !C.ougi_backdrop_objs) return
	for(var/obj/O in C.ougi_backdrop_objs)
		C.screen -= O
		del O
	C.ougi_backdrop_objs = null

proc/OugiClientEndBackdropFade(client/C)
	if(!C) return
	if(C.ougi_backdrop_fade) C.screen -= C.ougi_backdrop_fade
	if(!C.ougi_backdrop_old) return
	for(var/obj/O in C.ougi_backdrop_old)
		C.screen -= O
		del O
	C.ougi_backdrop_old = null

/datum/ougi_scene/proc/ReturnActor(mob/M)
	if(!M) return
	if(M.ougi_stand_in || (room && room.swapmap && M.in_tmp_map == room.swapmap.id))
		animate(M)
		OugiActorLeave(M)

/datum/ougi_scene/proc/LeaveRoom()
	for(var/mob/M in actors)
		ReturnActor(M)

/datum/ougi_scene/proc/FlashIn()
	for(var/client/C in clients)
		var/mob/M = C.mob
		if(M && !ReducedMotion(C))
			M._fps_hold_until = max(M._fps_hold_until, world.time + OUGI_PIN_DS)
			C.ougi_fps_until = world.time + OUGI_PIN_DS
			C.fps = glob.HIT_STOP_PIN_FPS
			spawn(OUGI_PIN_DS)
				if(C && C.mob && world.time >= C.mob._fps_hold_until)
					C.fps = C.mob.EffectiveClientFPS()
		OugiClientDim(C, 1)
		OugiClientActorPlates(C, src)
		OugiClientFlashFX(C, src)
		if(!ReducedMotion(C)) OugiClientWipeWarm(C, 1, "in", 0)

/datum/ougi_scene/proc/FlashOut()
	for(var/client/C in clients)
		OugiClientDim(C, 0)
		OugiClientClearActorPlates(C)
		OugiClientClearFlashFX(C)

proc/OugiScreenPos(client/C, atom/movable/A)
	if(!C || !A) return null
	var/atom/movable/V = C.eye ? C.eye : C.mob
	var/turf/E = get_turf(V)
	if(!E || A.z != E.z) return null
	var/list/vt = GfxCameraViewTiles(C)
	var/list/vp = OugiViewPx(C)
	var/mag = C.world_mag || 1
	var/hx = (vt[1] % 2) ? 0 : world.icon_size / 2
	var/hy = (vt[2] % 2) ? 0 : world.icon_size / 2
	var/sx = vp[1] / 2 + (hx + GfxCameraWorldX(A) + A.pixel_x - GfxCameraWorldX(V)) * mag
	var/sy = vp[2] / 2 + (hy + GfxCameraWorldY(A) + A.pixel_y + A.pixel_z - GfxCameraWorldY(V)) * mag
	if(sx < 0 || sy < 0 || sx > vp[1] || sy > vp[2]) return null
	return list(sx, sy)

proc/OugiFlashTrack(client/C, datum/ougi_scene/S, list/fx, list/p)
	set waitfor = 0
	var/lx = round(p[1], 1)
	var/ly = round(p[2], 1)
	while(C && S && C.ougi_flash_fx == fx)
		sleep(world.tick_lag)
		if(!C || C.ougi_flash_fx != fx) return
		var/list/q = OugiScreenPos(C, S.attacker)
		if(!q) continue
		var/dx = round(q[1], 1) - lx
		var/dy = round(q[2], 1) - ly
		if(!dx && !dy) continue
		lx += dx
		ly += dy
		for(var/obj/O in fx)
			var/matrix/M = matrix(O.transform)
			M.Translate(dx, dy)
			animate(O, transform = M, time = world.tick_lag, flags = ANIMATION_PARALLEL)

proc/OugiClientFlashFX(client/C, datum/ougi_scene/S)
	OugiClientClearFlashFX(C)
	if(!C || !S) return
	var/list/p = OugiScreenPos(C, S.attacker)
	if(!p) return
	var/list/vp = OugiViewPx(C)
	C.ougi_flash_fx = list()
	var/big = vp[1] >= 768 && vp[2] >= 432
	if(big || (vp[1] >= 480 && vp[2] >= 270))
		var/obj/ougi_screen/focus/F = new
		F.icon = big ? OUGI_FOCUS_L_ART : OUGI_FOCUS_S_ART
		var/iw = big ? 768 : 480
		var/ih = big ? 432 : 270
		var/k = max(1.56 * vp[1] / iw, 1.045 * vp[2] / ih)
		var/matrix/M = matrix()
		M.Scale(k)
		M.Translate(p[1] - iw / 2, p[2] - ih / 2)
		F.transform = M
		C.ougi_flash_fx += F
		C.screen += F
		spawn(world.tick_lag)
			if(F)
				animate(F, alpha = 255, time = 1)
				animate(alpha = 255, time = 3)
				animate(alpha = 0, time = 1)
	var/obj/ougi_screen/ring/R = new
	R.icon = OUGI_GOLD_RING_ART
	R.color = glob.OUGI_RING_COLOR
	var/matrix/RM = matrix()
	RM.Translate(round(p[1], 1) - 102, round(p[2], 1) - 102)
	R.transform = RM
	C.ougi_flash_fx += R
	C.screen += R
	OugiFlashTrack(C, S, C.ougi_flash_fx, p)

proc/OugiClientClearFlashFX(client/C)
	if(!C || !C.ougi_flash_fx) return
	for(var/obj/O in C.ougi_flash_fx)
		C.screen -= O
		del O
	C.ougi_flash_fx = null

proc/OugiDimMatrix(k)
	return list(k,0,0,0, 0,k,0,0, 0,0,k,0, 0,0,0,1, 0,0,0,0)

proc/OugiClientDim(client/C, on)
	if(!C) return
	C.ougi_dimmed = on
	for(var/obj/O in list(C.client_plane_master, C.fx_relay, C.fxnb_relay))
		if(!O) continue
		var/F = O.filters["ougi_dim"]
		if(F) O.filters -= F
		if(on)
			O.filters += filter(name = "ougi_dim", type = "color", color = OugiDimMatrix(1))
			var/G = O.filters["ougi_dim"]
			if(G) animate(G, color = OugiDimMatrix(OUGI_DIM_LEVEL), time = OUGI_DIM_DS)

proc/OugiClientActorPlates(client/C, datum/ougi_scene/S)
	if(!C || !S) return
	OugiClientClearActorPlates(C)
	var/turf/E = get_turf(C.eye ? C.eye : C.mob)
	if(!E) return
	if(!C.ougi_flash_master) C.ougi_flash_master = new /obj/ougi_flash_master
	if(!C.ougi_flash_relay) C.ougi_flash_relay = new /obj/ougi_screen/flash_relay
	C.ougi_flash_relay.transform = C.WorldMagMatrix()
	C.screen |= C.ougi_flash_master
	C.screen |= C.ougi_flash_relay
	C.ougi_actor_plates = list()
	for(var/mob/M in list(S.attacker, S.target))
		if(!M || M.z != E.z) continue
		var/image/I = image(loc = M)
		I.appearance = M.appearance
		I.dir = M.dir
		I.override = 1
		I.plane = OUGI_FLASH_PLANE
		I.appearance_flags |= KEEP_TOGETHER | KEEP_APART
		if(M == S.attacker)
			I.color = list(0,0,0, 0,0,0, 0,0,0, 1,1,1)
			var/image/II = I
			spawn(10)
				if(II) animate(II, color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time = 20)
		C.ougi_actor_plates += I
		C.images += I

proc/OugiClientClearActorPlates(client/C)
	if(!C) return
	if(C.ougi_actor_plates)
		for(var/image/I in C.ougi_actor_plates)
			C.images -= I
		C.ougi_actor_plates = null
	if(C.ougi_flash_relay) C.screen -= C.ougi_flash_relay
	if(C.ougi_flash_master) C.screen -= C.ougi_flash_master

proc/OugiClientWipe(client/C)
	if(!C) return null
	if(!C.ougi_wipe)
		C.ougi_wipe = new /obj/ougi_screen/wipe
		C.ougi_wipe.icon = OugiSolidIcon(OUGI_BLACK_ICON)
	if(!C.ougi_wipe_lines)
		C.ougi_wipe_lines = new /obj/ougi_screen/wipe_lines
	if(!C.ougi_wipe_fringe)
		C.ougi_wipe_fringe = new /obj/ougi_screen/wipe_fringe
	return C.ougi_wipe

proc/OugiClientWipeSet(client/C, d, phase, p, time)
	var/obj/ougi_screen/wipe/W = OugiClientWipe(C)
	var/obj/ougi_screen/wipe_lines/WL = C.ougi_wipe_lines
	var/obj/ougi_screen/wipe_fringe/WF = C.ougi_wipe_fringe
	C.ougi_wipe_d = d
	var/list/vp = OugiViewPx(C)
	var/vw = vp[1]
	var/vh = vp[2]
	var/big = vw >= 768 && vh >= 432
	var/fits = big || (vw >= 480 && vh >= 270)
	var/iw = big ? 768 : 480
	var/ih = big ? 432 : 270
	var/fw = big ? 235 : 147
	var/edge = big ? 19 : 12
	var/k = vh / ih
	var/bodyw = vw + 80
	var/front = (phase == "in") ? (-40 + (vw + 80) * p) : (-40 + (vw + (fw - edge) * k + 80) * p)
	var/bcx = (phase == "in") ? (front - bodyw / 2) : (front + bodyw / 2)
	var/fcx = (phase == "in") ? (front - edge * k + fw * k / 2) : (front + edge * k - fw * k / 2)
	if(d < 0)
		bcx = vw - bcx
		fcx = vw - fcx
	var/matrix/B = matrix()
	B.Scale(bodyw / 32, vh / 32 + 0.2)
	B.Translate(bcx - 16, vh / 2 - 16)
	var/matrix/L = matrix()
	L.Scale((d > 0 ? 1 : -1) * bodyw / iw, vh / ih)
	L.Translate(bcx - iw / 2, vh / 2 - ih / 2)
	var/matrix/F = matrix()
	F.Scale((d > 0 ? 1 : -1) * k, k)
	F.Translate(fcx - fw / 2, vh / 2 - ih / 2)
	W.screen_loc = "1,1"
	C.screen |= W
	if(fits)
		WL.icon = big ? OUGI_WIPE_STREAKS_L_ART : OUGI_WIPE_STREAKS_S_ART
		WF.icon = big ? OUGI_WIPE_FRINGE_L_ART : OUGI_WIPE_FRINGE_S_ART
		WF.icon_state = phase
		WL.screen_loc = "1,1"
		WF.screen_loc = "1,1"
		C.screen |= WL
		C.screen |= WF
	else
		C.screen -= WL
		C.screen -= WF
		WL.screen_loc = null
		WF.screen_loc = null
	if(time > 0)
		animate(W, transform = B, time = time, easing = QUAD_EASING | EASE_OUT)
		animate(WL, transform = L, time = time, easing = QUAD_EASING | EASE_OUT)
		animate(WF, transform = F, time = time, easing = QUAD_EASING | EASE_OUT)
	else
		W.transform = B
		WL.transform = L
		WF.transform = F

proc/OugiClientWipeCovered(client/C)
	if(C && C.ougi_wipe && (C.ougi_wipe in C.screen))
		OugiClientWipeSet(C, C.ougi_wipe_d, "in", 1, 0)
	if(C && C.ougi_fade && (C.ougi_fade in C.screen))
		OugiClientFadeFit(C)

proc/OugiClientFadeFit(client/C)
	if(!C) return null
	if(!C.ougi_fade)
		C.ougi_fade = new /obj/ougi_screen/fade
		C.ougi_fade.icon = OugiSolidIcon(OUGI_BLACK_ICON)
	var/list/vp = OugiViewPx(C)
	var/matrix/M = matrix()
	M.Scale(vp[1] / 32 + 0.1, vp[2] / 32 + 0.1)
	M.Translate(vp[1] / 2 - 16, vp[2] / 2 - 16)
	C.ougi_fade.transform = M
	C.ougi_fade.screen_loc = "1,1"
	return C.ougi_fade

proc/OugiClientWipeWarm(client/C, d, phase, cover)
	if(!C) return
	var/obj/ougi_screen/wipe/W = OugiClientWipe(C)
	var/matrix/B = W.transform
	OugiClientWipeSet(C, d, phase, 0.5, 0)
	if(cover) W.transform = B
	else W.alpha = 0
	C.ougi_wipe_lines.alpha = 1
	C.ougi_wipe_fringe.alpha = 1

proc/OugiClientSwitchCover(client/C)
	if(!C || !C.ougi_wipe_covered) return 0
	var/matrix/M = matrix()
	M.Scale(OUGI_BLANKET_PX / 32)
	M.Translate(OUGI_BLANKET_PX / 2 - 80, OUGI_BLANKET_PX / 2 - 80)
	if(C.ougi_wipe && (C.ougi_wipe in C.screen))
		animate(C.ougi_wipe)
		C.ougi_wipe.transform = M
		C.ougi_wipe.alpha = 255
		for(var/obj/O in list(C.ougi_wipe_lines, C.ougi_wipe_fringe))
			animate(O)
			O.alpha = 0
	if(C.ougi_fade && (C.ougi_fade in C.screen))
		animate(C.ougi_fade)
		C.ougi_fade.transform = M
		C.ougi_fade.alpha = 255
	return 1

proc/OugiClientViewSettled(client/C)
	var/list/vs = splittext("[winget(C, "mapwindow.map", "view-size")]", "x")
	if(!C) return 1
	if(vs.len < 2) return 0
	var/w = text2num(vs[1])
	var/h = text2num(vs[2])
	if(!w || !h) return 0
	var/list/vt = GfxCameraViewTiles(C)
	if(abs(w * vt[2] - h * vt[1]) > vt[1] + vt[2]) return 0
	if(C.ougi_in_display) C.ougi_cut_px = min(w, h)
	return 1

proc/OugiClientFence(client/C)
	set waitfor = 0
	if(!C) return
	C.ougi_fences++
	var/t0 = world.time
	sleep(world.tick_lag)
	while(C && world.time - t0 < OUGI_FENCE_DS && !OugiClientViewSettled(C))
		sleep(world.tick_lag)
	sleep(world.tick_lag)
	if(C) winget(C, "mapwindow.map", "view-size")
	if(C) C.ougi_fences = max(0, C.ougi_fences - 1)

/datum/ougi_scene/proc/AwaitFences()
	var/t0 = world.time
	bd_frozen_at = t0
	while(live && world.time - t0 < OUGI_FENCE_DS)
		var/waiting = 0
		for(var/client/C in clients)
			if(C.ougi_fences) waiting = 1
		if(!waiting) break
		sleep(world.tick_lag)
	if(backdrop) bd_t0 += world.time - t0
	bd_frozen_at = 0

proc/OugiClientEaseStart(client/C)
	if(!C || !C.ougi_cut_px) return
	var/z = C.view_fit_last_zoom || 1
	var/s0 = max(1, C.ougi_cut_px / (OUGI_FRAME_TILES * world.icon_size * z))
	if(abs(s0 - (C.world_mag || 1)) < 0.02) return
	var/matrix/M = matrix()
	M.Scale(s0)
	for(var/obj/O in list(C.client_plane_master, C.fx_relay, C.fxnb_relay, C.world_overlay_master))
		O.transform = M
	C.ougi_ease_pending = 1

proc/OugiClientEaseBack(client/C)
	if(!C || !C.ougi_ease_pending) return
	C.ougi_ease_pending = 0
	var/matrix/W = C.WorldMagMatrix()
	for(var/obj/O in list(C.client_plane_master, C.fx_relay, C.fxnb_relay, C.world_overlay_master))
		animate(O, transform = W, time = OUGI_EASE_BACK_DS, easing = SINE_EASING)
	spawn(OUGI_EASE_BACK_DS)
		if(C && !C.ougi_in_display && !C.ougi_ease_pending) OugiClientSharpFx(C, 0)

/datum/ougi_scene/proc/WipeCover(side)
	var/d = -side
	for(var/client/C in clients)
		C.ougi_wipe_covered = 1
		if(ReducedMotion(C))
			var/obj/ougi_screen/fade/F = OugiClientFadeFit(C)
			F.alpha = 0
			C.screen |= F
			spawn(world.tick_lag)
				if(F) animate(F, alpha = 255, time = OUGI_WIPE_IN_DS)
		else
			var/obj/ougi_screen/wipe/W = OugiClientWipe(C)
			OugiClientWipeSet(C, d, "in", 0, 0)
			W.alpha = 255
			C.ougi_wipe_lines.alpha = 107
			C.ougi_wipe_fringe.alpha = 255
			var/client/CC = C
			spawn(world.tick_lag)
				if(CC) OugiClientWipeSet(CC, d, "in", 1, OUGI_WIPE_IN_DS)
			spawn(world.tick_lag + OUGI_WIPE_IN_DS - OUGI_STREAK_FADE_DS)
				if(CC && CC.ougi_wipe_lines) animate(CC.ougi_wipe_lines, alpha = 0, time = OUGI_STREAK_FADE_DS, flags = ANIMATION_PARALLEL)

/datum/ougi_scene/proc/WipeReveal(side)
	AwaitFences()
	var/d = -side
	for(var/client/C in clients)
		C.ougi_wipe_covered = 0
		if(ReducedMotion(C))
			if(!C.ougi_fade) continue
			OugiClientWipeCovered(C)
			animate(C.ougi_fade, alpha = 0, time = OUGI_WIPE_OUT_DS)
			continue
		if(!C.ougi_wipe) continue
		OugiClientWipeSet(C, d, "out", 0, 0)
		OugiClientWipeSet(C, d, "out", 1, OUGI_WIPE_OUT_DS)
		C.ougi_wipe_fringe.alpha = 255
		animate(C.ougi_wipe_lines, alpha = 107, time = OUGI_STREAK_FADE_DS, flags = ANIMATION_PARALLEL)
		OugiClientEaseBack(C)

proc/OugiClientWipeRemove(client/C)
	if(!C) return
	C.ougi_wipe_covered = 0
	for(var/obj/O in list(C.ougi_wipe, C.ougi_wipe_lines, C.ougi_wipe_fringe, C.ougi_fade))
		C.screen -= O
		O.screen_loc = null

proc/OugiClientEnterDisplay(client/C, datum/ougi_scene/S)
	if(!C || !S || !S.camera) return
	var/covered = OugiClientSwitchCover(C)
	if(!C.ougi_in_display)
		C.ougi_in_display = 1
		C.SetupCutsceneDisplay()
	OugiClientSharpFx(C, 1)
	C.ougi_eye_prev = C.eye
	C.ougi_perspective_prev = C.perspective
	C.perspective = EYE_PERSPECTIVE
	C.eye = S.camera
	S.FitPlateFor(C)
	C.screen |= S.EnsureFlashPlate()
	OugiClientBackdrop(C, S)
	if(covered)
		if(!S.ReducedMotion(C)) OugiClientWipeWarm(C, C.ougi_wipe_d, "out", 1)
		OugiClientFence(C)
	else
		OugiClientWipeCovered(C)
	Hd2dClientTick(C, 1)

proc/OugiClientRestore(client/C, datum/ougi_scene/S)
	if(!C) return
	if(C.ougi_view_rig) C.ougi_view_rig.Drop()
	var/covered = OugiClientSwitchCover(C)
	OugiClientClearActorPlates(C)
	OugiClientClearFlashFX(C)
	OugiClientClearBackdrop(C)
	OugiClientDim(C, 0)
	if(S)
		if(C.eye == S.camera || (S.camera && C.eye != C.mob))
			C.eye = C.mob
			C.perspective = C.ougi_perspective_prev
		if(S.flash_plate) C.screen -= S.flash_plate
		if(S.nameplate) C.screen -= S.nameplate
	C.ougi_eye_prev = null
	if(C.ougi_in_display)
		C.ougi_in_display = 0
		OugiClientWorldTransform(C, 1, 0, 0, 0)
		C.EndCutsceneDisplay()
		if(covered && S && !S.ended && !S.ReducedMotion(C)) OugiClientEaseStart(C)
		if(!C.ougi_ease_pending) OugiClientSharpFx(C, 0)
	if(covered)
		if(C.ougi_wipe && (C.ougi_wipe in C.screen)) OugiClientWipeWarm(C, C.ougi_wipe_d, "out", 1)
		OugiClientFence(C)
	else
		OugiClientWipeCovered(C)
	Hd2dClientTick(C, 1)

proc/OugiPlateColor(cat)
	switch(cat)
		if("Armed") return "white"
		if("Gun") return "red"
		if("Energy") return "blue"
	return "gold"

proc/OugiPlateHasDescender(title)
	for(var/c in list("g", "j", "p", "q", "y", "Q", ",", ";"))
		if(findtextEx(title, c)) return 1
	return 0

proc/OugiPlateTextY(title)
	var/lo = OugiPlateHasDescender(title) ? OUGI_FONT_DESCENT : OUGI_FONT_BASELINE
	return -round(-(OUGI_PLATE_BAND_LO + OUGI_PLATE_BAND_HI) / 2) - (lo + OUGI_FONT_INK_TOP) / 2

proc/OugiPlateWidth(title)
	return max(OUGI_PLATE_W, length(title) * OUGI_FONT_ADVANCE - 1 + OUGI_PLATE_TEXT_PAD)

var/list/_ougi_plate_cache = list()

proc/OugiPlateIcon(color, bw)
	var/key = "[color]|[bw]"
	if(_ougi_plate_cache[key]) return _ougi_plate_cache[key]
	if(!("[color]_bandl" in icon_states(OUGI_NAMEPLATE_ART))) return null
	var/icon/C = icon(OUGI_NAMEPLATE_ART, "blank")
	C.Crop(1, 1, bw, OUGI_PLATE_H)
	C.Blend(icon(OUGI_NAMEPLATE_ART, "[color]_bandl"), ICON_OVERLAY, 1, 1)
	for(var/x = 41, x <= bw - 40, x += 64)
		var/icon/M = icon(OUGI_NAMEPLATE_ART, "[color]_bandm")
		M.Crop(1, 1, min(64, bw - 40 - x + 1), OUGI_PLATE_H)
		C.Blend(M, ICON_OVERLAY, x, 1)
	C.Blend(icon(OUGI_NAMEPLATE_ART, "[color]_bandr"), ICON_OVERLAY, bw - 39, 1)
	C.Blend(icon(OUGI_NAMEPLATE_ART, "[color]_crest"), ICON_OVERLAY, 1 + round((bw - OUGI_PLATE_W) / 2), 1)
	_ougi_plate_cache[key] = C
	return C

/datum/ougi_scene/proc/PlateRun(list/a)
	set waitfor = 0
	if(!live) return
	if(!nameplate) nameplate = new /obj/ougi_screen/nameplate
	var/title = ArgText(a, "text", ougi ? ougi.name : "Ougi")
	var/cat = ArgText(a, "category", ougi ? ougi.OugiCategory : category)
	var/bw = OugiPlateWidth(title)
	var/fw = OUGI_FRAME_TILES * world.icon_size
	nameplate.icon = OugiPlateIcon(OugiPlateColor(cat), bw)
	nameplate.screen_loc = "1:[round((fw - bw) / 2)],1:[fw - glob.OUGI_PLATE_TOP_GAP - OUGI_PLATE_H]"
	nameplate.maptext_width = bw
	nameplate.maptext_x = round((bw - (length(title) * OUGI_FONT_ADVANCE - 1)) / 2)
	nameplate.maptext_y = OugiPlateTextY(title)
	nameplate.maptext = "<span style=\"[MCARD_FONT]; color:#ffffff\">[title]</span>"
	var/rise = OUGI_PLATE_H + glob.OUGI_PLATE_TOP_GAP + 24
	var/matrix/up = matrix()
	up.Translate(0, rise)
	var/matrix/over = matrix()
	over.Translate(0, -rise * 0.06)
	nameplate.transform = up
	for(var/client/C in clients)
		if(C.ougi_in_display)
			C.screen |= nameplate
	sleep(world.tick_lag)
	if(!live) return
	animate(nameplate, transform = over, time = 2.4, easing = SINE_EASING)
	animate(transform = matrix(), time = 0.6, easing = SINE_EASING)
	animate(transform = matrix(), time = 15)
	animate(transform = up, time = 3, easing = SINE_EASING)

/datum/ougi_scene/proc/Fizzle()
	fizzled = 1
	if(attacker)
		attacker << "<b>[target] guarded! [ougi ? ougi.name : "The Ougi"] fizzles.</b>"
		attacker.OugiFizzleRefund(ougi)
	if(target) target << "<b>You guarded against [attacker]'s Ougi!</b>"
	for(var/client/C in clients)
		OugiClientClearActorPlates(C)
		for(var/obj/O in list(C.client_plane_master, C.fx_relay, C.fxnb_relay))
			if(!O) continue
			var/G = O.filters["ougi_dim"]
			if(G) animate(G, color = OugiDimMatrix(1), time = OUGI_FIZZLE_DS)
	if(attacker) KenShockwave(attacker, icon = OUGI_RING_ICON, Size = 0.3, Blend = 2, Time = 6)
	sleep(OUGI_FIZZLE_DS)
	End(0)

/datum/ougi_scene/proc/Exit()
	var/obj/ougi_screen/plate/P = EnsureFlashPlate()
	P.color = "#ffffff"
	animate(P, alpha = 255, time = OUGI_WHITEOUT_DS)
	for(var/client/C in clients)
		if(!ReducedMotion(C)) OugiClientWipeWarm(C, 1, "in", 0)
	sleep(OUGI_WHITEOUT_DS)
	if(!live) return
	WipeCover(-wipe_from)
	sleep(OUGI_WIPE_IN_DS)
	if(!live) return
	if(OugiChainSceneExit(src)) return
	LeaveRoom()
	for(var/mob/M in locked.Copy())
		OugiLockRelease(src, M)
	sleep(OUGI_WIPE_HOLD_DS)
	if(!live) return
	WipeReveal(-wipe_from)
	sleep(OUGI_WIPE_OUT_DS)
	if(target && target.loc && !preview) FxHeavyImpact(target, null, 1)
	End(0)

/datum/ougi_scene/proc/End(force = 0)
	if(ended) return
	ended = 1
	live = 0
	LeaveRoom()
	for(var/mob/M in locked.Copy())
		OugiLockRelease(src, M)
	for(var/client/C in clients)
		OugiClientRestore(C, null)
		OugiClientWipeRemove(C)
		OugiClientEaseBack(C)
		if(flash_plate) C.screen -= flash_plate
		if(nameplate) C.screen -= nameplate
	for(var/atom/movable/A in temp_atoms.Copy())
		GfxReleaseAtom(A)
		del A
	temp_atoms = list()
	for(var/datum/lightsource/L in temp_lights.Copy())
		RemoveLightSource(L)
	temp_lights = list()
	if(camera)
		camera.loc = null
		del camera
	RestoreWeather()
	OugiRoomRelease(room)
	if(ougi)
		ougi.Using = 0
		if(ougi.ougi_strike)
			ougi.ougi_strike.DamageMult = 0
			ougi.ougi_strike.Using = 0
	if(attacker && !fizzled && !preview)
		attacker.ougi_cd_until = world.time + glob.OUGI_COOLDOWN_S * 10
	var/list/live_list = OugiLiveList()
	live_list -= src
	if(force) world.log << "OUGI: scene [id] force-ended"
