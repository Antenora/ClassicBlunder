//opt-in camera director

/mob/gfx_camera
	name = "graphics camera"
	density = 0
	invisibility = 101
	mouse_opacity = 0
	Savable = 0
	var/tmp
		mob/Players/owner
		last_target_x = 0
		last_target_y = 0
		last_target_z = 0
		look_x = 0
		look_y = 0
		vel_x = 0 //spring state, px/s
		vel_y = 0

client
	var/tmp
		mob/gfx_camera/gfx_camera
		gfx_camera_active = FALSE

proc/GfxCameraWanted(client/C)
	var/Options/P = C ? C.prefs : null
	return C && C.mob && istype(C.mob, /mob/Players) && istype(P, /Options) && P.experimentalCamera && !GfxReducedMotion(C)

proc/GfxCameraWorldX(atom/movable/A)
	return A ? (A.x - 1) * world.icon_size + A.step_x + world.icon_size / 2 : 0

proc/GfxCameraWorldY(atom/movable/A)
	return A ? (A.y - 1) * world.icon_size + A.step_y + world.icon_size / 2 : 0

proc/GfxCameraViewTiles(client/C)
	if(!C) return list(world.view * 2 + 1, world.view * 2 + 1)
	var/v = C.view
	if(isnum(v))
		var/n = max(1, round(v) * 2 + 1)
		return list(n, n)
	var/list/parts = splittext("[v]", "x")
	if(parts.len >= 2)
		var/w = max(1, text2num(parts[1]))
		var/h = max(1, text2num(parts[2]))
		if(w && h) return list(w, h)
	return list(world.view * 2 + 1, world.view * 2 + 1)

proc/GfxCameraClampPoint(client/C, wx, wy)
	var/list/dims = GfxCameraViewTiles(C)
	var/world_w = world.maxx * world.icon_size
	var/world_h = world.maxy * world.icon_size
	var/half_w = dims[1] * world.icon_size / 2
	var/half_h = dims[2] * world.icon_size / 2
	if(world_w <= half_w * 2)
		wx = world_w / 2
	else
		wx = clamp(wx, half_w, world_w - half_w)
	if(world_h <= half_h * 2)
		wy = world_h / 2
	else
		wy = clamp(wy, half_h, world_h - half_h)
	return list(wx, wy)

proc/GfxCameraPlace(client/C, mob/gfx_camera/G, wx, wy, z)
	if(!G || !z) return 0
	var/list/clamped = GfxCameraClampPoint(C, wx, wy)
	wx = clamped[1]
	wy = clamped[2]
	var/tx = clamp(floor(wx / world.icon_size) + 1, 1, world.maxx)
	var/ty = clamp(floor(wy / world.icon_size) + 1, 1, world.maxy)
	var/turf/T = locate(tx, ty, z)
	if(!T) return 0
	G.loc = T
	//round-to-nearest: one-arg round() FLOORS, which biases negative offsets a pixel low
	G.step_x = round(wx - ((tx - 1) * world.icon_size + world.icon_size / 2), 1)
	G.step_y = round(wy - ((ty - 1) * world.icon_size + world.icon_size / 2), 1)
	return 1

proc/GfxCameraSnap(client/C, mob/Players/P)
	if(!C || !C.gfx_camera || !P) return
	var/mob/gfx_camera/G = C.gfx_camera
	var/px = GfxCameraWorldX(P)
	var/py = GfxCameraWorldY(P)
	G.owner = P
	G.last_target_x = px
	G.last_target_y = py
	G.last_target_z = P.z
	G.look_x = 0
	G.look_y = 0
	G.vel_x = 0
	G.vel_y = 0
	G.glide_size = 64 //snap covers big distances: glide briskly instead of the auto-glide crawl
	GfxCameraPlace(C, G, px, py, P.z)

//center visual passes on whatever the client is actually watching
proc/GfxViewAnchor(client/C)
	if(C && C.eye && get_turf(C.eye)) return C.eye
	return C ? C.mob : null

//a camera-owned eye still counts as the player's own view, not spectating
proc/GfxClientEyeIsMob(client/C, mob/M)
	if(!C || !M) return FALSE
	if(C.eye == M) return TRUE
	return C.gfx_camera && C.eye == C.gfx_camera && C.gfx_camera.owner == M

proc/GfxCameraEnable(client/C)
	if(!GfxCameraWanted(C)) return
	var/mob/Players/P = C.mob
	//another system owns the eye - wait for it to hand control back
	if(C.eye != P && C.eye != C.gfx_camera) return
	if(!C.gfx_camera)
		C.gfx_camera = new(get_turf(P))
		GfxCameraSnap(C, P)
	else if(C.gfx_camera.owner != P)
		GfxCameraSnap(C, P)
	C.gfx_camera.owner = P
	C.eye = C.gfx_camera
	C.gfx_camera_active = TRUE

proc/GfxCameraDisable(client/C)
	if(!C) return
	if(C.gfx_camera && C.eye == C.gfx_camera && C.mob)
		C.eye = C.mob
	C.gfx_camera_active = FALSE
	if(C.gfx_camera)
		var/mob/gfx_camera/G = C.gfx_camera
		C.gfx_camera = null
		G.owner = null
		G.loc = null
		del G

proc/GfxCameraSync(client/C)
	if(!C) return
	if(GfxCameraWanted(C))
		GfxCameraEnable(C)
	else
		GfxCameraDisable(C)

proc/GfxCameraTrack(client/C)
	if(!GfxCameraWanted(C))
		if(C && C.gfx_camera) GfxCameraDisable(C)
		return
	var/mob/Players/P = C.mob
	if(C.eye != P && C.eye != C.gfx_camera)
		C.gfx_camera_active = FALSE
		return // observer/cutscene/camera currently owns the eye
	if(!C.gfx_camera || C.eye == P)
		GfxCameraEnable(C)
	if(!C.gfx_camera || C.eye != C.gfx_camera) return
	var/mob/gfx_camera/G = C.gfx_camera
	var/px = GfxCameraWorldX(P)
	var/py = GfxCameraWorldY(P)
	var/vx = px - G.last_target_x
	var/vy = py - G.last_target_y
	//teleports and z changes snap instead of scrolling across the map
	if(G.last_target_z != P.z || max(abs(vx), abs(vy)) > world.icon_size * 6)
		GfxCameraSnap(C, P)
		return
	G.last_target_x = px
	G.last_target_y = py
	G.last_target_z = P.z
	//look-ahead stays modest; target framing adds 2 tiles at most
	var/velocity_look_x = clamp(vx * 3, -28, 28)
	var/velocity_look_y = clamp(vy * 3, -22, 22)
	if(!vx && !vy)
		//stopped: keep the lead and bleed it off gently, no yank back to center
		G.look_x *= 0.94
		G.look_y *= 0.94
	else
		G.look_x = G.look_x * 0.68 + velocity_look_x * 0.32
		G.look_y = G.look_y * 0.68 + velocity_look_y * 0.32
	var/look_x = G.look_x
	var/look_y = G.look_y
	var/atom/movable/focus = P.Target
	if(ismob(focus) && focus != P && get_turf(focus) && focus.z == P.z && focus.invisibility <= P.see_invisible)
		var/fdx = GfxCameraWorldX(focus) - px
		var/fdy = GfxCameraWorldY(focus) - py
		if(max(abs(fdx), abs(fdy)) <= ClientViewRange(C) * world.icon_size)
			look_x += clamp(fdx * 0.18, -64, 64)
			look_y += clamp(fdy * 0.18, -48, 48)
	look_x = clamp(look_x, -72, 72)
	look_y = clamp(look_y, -54, 54)
	var/want_x = px + look_x
	var/want_y = py + look_y
	var/gx = GfxCameraWorldX(G)
	var/gy = GfxCameraWorldY(G)
	//critically damped spring: eases in and out, converges with no deadband
	var/dt = 0.1 //loop cadence: sleep(1) = 1ds
	var/w = 5.5 //response frequency; higher = tighter follow
	G.vel_x += (w * w * (want_x - gx) - 2 * w * G.vel_x) * dt
	G.vel_y += (w * w * (want_y - gy) - 2 * w * G.vel_y) * dt
	//catch-up cap scales with player velocity so no movement mode outruns it
	var/cap_x = max(18, abs(vx) + 10)
	var/cap_y = max(18, abs(vy) + 10)
	var/move_x = clamp(G.vel_x * dt, -cap_x, cap_x)
	var/move_y = clamp(G.vel_y * dt, -cap_y, cap_y)
	var/next_x = gx + move_x
	var/next_y = gy + move_y
	//lead is fine, but never trail more than 10px behind sustained movement
	var/max_trail = 10
	if(vx > 0 && next_x < px - max_trail)
		next_x = px - max_trail
		G.vel_x = vx / dt //ride the wall at the player's own speed, no wind-up
	else if(vx < 0 && next_x > px + max_trail)
		next_x = px + max_trail
		G.vel_x = vx / dt
	if(vy > 0 && next_y < py - max_trail)
		next_y = py - max_trail
		G.vel_y = vy / dt
	else if(vy < 0 && next_y > py + max_trail)
		next_y = py + max_trail
		G.vel_y = vy / dt
	//map-edge: clamp BEFORE the glide math or the client arrives early and stalls; dump the into-wall velocity too
	var/list/edge = GfxCameraClampPoint(C, next_x, next_y)
	if(edge[1] != next_x)
		next_x = edge[1]
		G.vel_x = 0
	if(edge[2] != next_y)
		next_y = edge[2]
		G.vel_y = 0
	//glide must match this write's real displacement: euclidean length, rounded UP, or the client snaps every write
	var/wdx = next_x - gx
	var/wdy = next_y - gy
	var/write_px = sqrt(wdx * wdx + wdy * wdy)
	G.glide_size = max(1, -round(-(write_px * world.tick_lag)))
	GfxCameraPlace(C, G, next_x, next_y, P.z)

var/_gfx_camera_boot = _GfxCameraBoot()

proc/_GfxCameraBoot()
	spawn(100)
		_GfxCameraLoop()
	return 1

proc/_GfxCameraLoop()
	set waitfor = 0
	set background = 1
	while(1)
		for(var/client/C)
			GfxCameraTrack(C)
		sleep(1)

client/Del()
	if(istype(mob, /mob/Players))
		_WxDetachPlayer(mob)
	if(gfx_haze_emitter)
		gfx_haze_emitter.particles = null
	GfxCameraDisable(src)
	. = ..()
