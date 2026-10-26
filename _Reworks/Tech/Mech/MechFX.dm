globalTracker/var/tmp
	MECHFX = TRUE
	MECHFX_CAP = 1400
	MECHFX_OCC_LINGER = 25
	MECHFX_CHAIN_GAP = 20
	MECHFX_GLOW_BLUR = 2.2

var/list/MECHFX_TINTS = list(\
	"blue" = list(0.3, 0.56, 1, 0.9, 0.95, 1, 0.12, 0.4, 1, 0.86, 0.94, 1, 0.64, 0.72, 0.97),\
	"violet" = list(0.5, 0.4, 1, 0.95, 0.93, 1, 0.42, 0.24, 1, 0.93, 0.9, 1, 0.74, 0.69, 0.97),\
	"gold" = list(1, 0.55, 0.2, 1, 0.95, 0.82, 1, 0.4, 0.06, 1, 0.94, 0.76, 0.99, 0.87, 0.68))

var/list/MECHFX_TRAVEL = list(\
	"E" = list(1, 0), "NE" = list(0.70710678, 0.70710678), "N" = list(0, 1), "NW" = list(-0.70710678, 0.70710678),\
	"W" = list(-1, 0), "SW" = list(-0.70710678, -0.70710678), "S" = list(0, -1), "SE" = list(0.70710678, -0.70710678))

var/list/MECHFX_TRAVEL_ORDER = list("E", "NE", "N", "NW", "W", "SW", "S", "SE")
var/list/MECHFX_GLINT_FRAMES = list(18, 16, 14, 12)
var/list/MECHFX_AMP_LEVELS = list(0.7, 0.725, 0.75, 0.775, 0.8, 0.825, 0.85, 0.875, 0.9, 0.925, 0.95, 0.975, 1)
var/list/MECHFX_MATS = list()
var/list/MECHFX_POOL = list()
var/list/MECHFX_DUE
var/list/MECHFX_MASKS = list()
var/list/MECHFX_MASK_ORDER = list()
var/mechfx_live = 0
var/mechfx_pending = 0
var/mechfx_loop = 0
var/mechfx_ghost_n = 0

mob/var/tmp/datum/mechfx_state/mechfx_st

client/var/tmp/list/mechfx_screen

/datum/mechfx_chain
	var
		relx = 0
		rely = 0
		has_rel = 0
		ax = 0
		ay = 0
		aburst = 0
		amoving = 0
		has_pt = 0
		seg = 0
		vis = 0
		since = 0
		gap = 3
		last_emit = -1000

/datum/mechfx_state
	var
		list/chains
		px = 0
		py = 0
		pdir = "S"
		pburst = 0
		has_prev = 0
		burst_start = -1000
		burst_last = -1000
		ghost_tick = -1000
		ghost_x = 0
		ghost_y = 0
		occ_token = 0
		occ_pending = 0
		hover_token = 0
		hover_tick = -1
		foot_v = 0
		plume_key
		south_key
		night_key
		obj/mechfx/plume/plume
		obj/mechfx/plume/plume2
		plume2_until = 0
		obj/mechfx/south/south
		obj/mechfx/occ/occ
		obj/mechfx/night/night
		obj/mechfx/night/night2

/obj/mechfx
	icon = MECHFX_WAKE_ICON
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	surface_profile = "ground_flat"
	bound_width = 1
	bound_height = 1
	var/tmp/fx_free = -1000

/obj/mechfx/lit
	plane = MECHFX_LIT_PLANE
	layer = 1
	blend_mode = BLEND_ADD

/obj/mechfx/smoke
	plane = 0

/obj/mechfx/ghost
	plane = MECHFX_GHOST_PLANE

/obj/mechfx/ghostglow
	plane = MECHFX_GHOST_PLANE
	blend_mode = BLEND_ADD

/obj/mechfx/dust
	plane = 0

/obj/mechfx/grit
	plane = 0
	icon = MECHFX_GRIT_ICON
	icon_state = "g"
	appearance_flags = PIXEL_SCALE

/obj/mechfx/plume
	plane = 0
	layer = EFFECTS_LAYER
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/mechfx/south
	plane = 0
	layer = EFFECTS_LAYER
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/mechfx/occ
	plane = MECHFX_OCC_PLANE
	layer = 1
	appearance_flags = KEEP_APART | RESET_COLOR
	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR

/obj/mechfx/night
	plane = 0
	layer = 6.55
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/mechfx_lit_master
	plane = MECHFX_LIT_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*mechfx_lit"

/obj/mechfx_occ_master
	plane = MECHFX_OCC_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*mechfx_occ"

/obj/mechfx_ghost_master
	plane = MECHFX_GHOST_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*mechfx_ghost"

/obj/mechfx_lit_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	layer = MECHFX_LIT_RELAY_LAYER
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	render_source = "*mechfx_lit"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*mechfx_occ", flags = MASK_INVERSE)

/obj/mechfx_ghost_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	layer = MECHFX_GHOST_RELAY_LAYER
	mouse_opacity = 0
	render_source = "*mechfx_ghost"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*mechfx_occ", flags = MASK_INVERSE)

client/ApplyWorldMag()
	..()
	MechFXEnsureMasters(src)

proc/MechFXEnsureMasters(client/C)
	if(!C) return
	if(!C.mechfx_screen)
		C.mechfx_screen = list(new /obj/mechfx_lit_master, new /obj/mechfx_occ_master, new /obj/mechfx_ghost_master, new /obj/mechfx_lit_relay, new /obj/mechfx_ghost_relay)
	for(var/obj/O in C.mechfx_screen)
		if(!(O in C.screen)) C.screen += O

proc/MechFXNow()
	return round(world.time / world.tick_lag, 1)

proc/MechFXSstep(e0, e1, v)
	var/t = clamp((v - e0) / (e1 - e0), 0, 1)
	return t * t * (3 - 2 * t)

proc/MechFXU(a, b)
	return a + (b - a) * rand()

proc/MechFXGauss(s)
	var/u1 = max(1e-9, rand())
	return s * sqrt(-2 * log(u1)) * cos(360 * rand())

proc/MechFXQ(v, q)
	return round(v / q, 1) * q

proc/MechFXDir4(d)
	if(d & EAST) return "E"
	if(d & WEST) return "W"
	if(d & NORTH) return "N"
	return "S"

proc/MechFXTravel(ux, uy)
	var/i = round(arctan(ux, uy) / 45, 1)
	i = ((i % 8) + 8) % 8
	return MECHFX_TRAVEL_ORDER[i + 1]

proc/MechFXRamp(tint, base, k2 = 1)
	var/key = "r[tint][base]_[k2]"
	var/list/M = MECHFX_MATS[key]
	if(M) return M
	var/list/T = MECHFX_TINTS[tint] || MECHFX_TINTS["blue"]
	M = list((T[base + 3] - T[base]) * k2, (T[base + 4] - T[base + 1]) * k2, (T[base + 5] - T[base + 2]) * k2, 0, 0, 0, 0, 0, 0, T[base], T[base + 1], T[base + 2])
	if(MECHFX_MATS.len < 4096) MECHFX_MATS[key] = M
	return M

proc/MechFXSmokeMat(tint)
	var/key = "s[tint]"
	var/list/M = MECHFX_MATS[key]
	if(M) return M
	var/list/T = MECHFX_TINTS[tint] || MECHFX_TINTS["blue"]
	M = list(T[13] * 1.1, 0, 0, 0, T[14] * 1.1, 0, 0, 0, T[15] * 1.1)
	MECHFX_MATS[key] = M
	return M

proc/MechFXGlowColor(tint)
	var/list/T = MECHFX_TINTS[tint] || MECHFX_TINTS["blue"]
	return rgb(round(T[7] * 255, 1), round(T[8] * 255, 1), round(T[9] * 255, 1))

proc/MechFXGet(path)
	if(!glob || mechfx_live >= glob.MECHFX_CAP) return null
	var/obj/mechfx/O
	var/list/P = MECHFX_POOL[path]
	if(P && P.len)
		O = P[1]
		if(O.fx_free <= MechFXNow() - 2)
			P.Cut(1, 2)
		else
			O = null
	if(!O) O = new path
	mechfx_live++
	return O

proc/MechFXFree(obj/mechfx/O)
	if(!O) return
	animate(O)
	O.loc = null
	O.filters = null
	O.fx_free = MechFXNow()
	mechfx_live = max(0, mechfx_live - 1)
	var/list/P = MECHFX_POOL[O.type]
	if(!P)
		P = list()
		MECHFX_POOL[O.type] = P
	if(P.len < 600) P += O

proc/MechFXDue(obj/mechfx/O, ticks)
	if(!MECHFX_DUE)
		MECHFX_DUE = new /list(MECHFX_RING)
		for(var/i = 1 to MECHFX_RING)
			MECHFX_DUE[i] = list()
	var/list/B = MECHFX_DUE[((MechFXNow() + max(1, round(ticks, 1))) % MECHFX_RING) + 1]
	B += O
	mechfx_pending++
	if(!mechfx_loop) MechFXLoop()

proc/MechFXLoop()
	set waitfor = 0
	if(mechfx_loop) return
	mechfx_loop = 1
	var/last = MechFXNow()
	while(mechfx_pending > 0)
		sleep(world.tick_lag)
		var/now = MechFXNow()
		if(now - last > MECHFX_RING) last = now - MECHFX_RING
		for(var/t = last + 1, t <= now, t++)
			var/list/B = MECHFX_DUE[(t % MECHFX_RING) + 1]
			if(!B.len) continue
			var/n = B.len
			for(var/obj/mechfx/O in B)
				MechFXFree(O)
			B.Cut()
			mechfx_pending = max(0, mechfx_pending - n)
		last = now
	mechfx_loop = 0

proc/MechFXMatrix(sx, sy, ang)
	var/matrix/M = matrix()
	if(sx != 1 || sy != 1) M.Scale(sx, sy)
	if(ang) M.Turn(ang)
	return M

proc/MechFXPlace(obj/mechfx/O, cx, cy, z, w, h, matrix/M)
	var/bx = cx - w / 2
	var/by = cy - h / 2
	var/ix = floor(bx)
	var/iy = floor(by)
	var/fx = round((bx - ix) * 4, 1) / 4
	var/fy = round((by - iy) * 4, 1) / 4
	if(fx >= 1)
		ix++
		fx = 0
	if(fy >= 1)
		iy++
		fy = 0
	var/tx = floor(ix / 32) + 1
	var/ty = floor(iy / 32) + 1
	if(tx < 1 || ty < 1 || tx > world.maxx || ty > world.maxy) return 0
	var/turf/T = locate(tx, ty, z)
	if(!T) return 0
	if(fx || fy)
		if(!M) M = matrix()
		M.Translate(fx, fy)
	O.transform = M
	O.loc = T
	O.step_x = ix - (tx - 1) * 32
	O.step_y = iy - (ty - 1) * 32
	return 1

proc/MechFXDriftSteps(obj/mechfx/O, vx, vy, decel, frames, st)
	var/matrix/B = O.transform
	var/total = frames * MECHFX_TICK_S
	var/n = max(1, round(total / st, 1))
	var/dt = total / n
	for(var/i = 1 to n)
		var/t = i * dt
		var/k = t * max(0, 1 - decel * t * 0.5)
		var/matrix/M = matrix(B)
		M.Translate(vx * k, vy * k)
		if(i == 1)
			animate(O, transform = M, time = dt * 10)
		else
			animate(transform = M, time = dt * 10)

proc/MechFXDriftLinear(obj/mechfx/O, vx, vy, frames)
	var/t = frames * MECHFX_TICK_S
	var/matrix/M = matrix(O.transform)
	M.Translate(vx * t, vy * t)
	animate(O, transform = M, time = frames * world.tick_lag)

proc/MechFXStamp(z, cx, cy, ang, sx, sy, amp, phase, thrust, tint)
	var/tag = thrust ? "t" : "c"
	var/life = thrust ? MECHFX_THRUST_FRAMES : MECHFX_WAKE_FRAMES
	var/a = clamp(round(amp * 255, 1), 1, 255)
	sx = MechFXQ(sx, 0.01)
	sy = MechFXQ(sy, 0.01)
	var/obj/mechfx/lit/L = MechFXGet(/obj/mechfx/lit)
	if(L)
		L.icon = MECHFX_WAKE_ICON
		L.icon_state = "l[tag][phase]"
		L.color = MechFXRamp(tint, 1)
		L.alpha = a
		if(MechFXPlace(L, cx, cy, z, MECHFX_WAKE_W, MECHFX_WAKE_H, MechFXMatrix(sx, sy, ang)))
			MechFXDue(L, life)
		else
			MechFXFree(L)
	var/obj/mechfx/smoke/S = MechFXGet(/obj/mechfx/smoke)
	if(S)
		S.icon = MECHFX_WAKE_ICON
		S.icon_state = "s[tag][phase]"
		S.color = MechFXSmokeMat(tint)
		S.alpha = a
		S.layer = MOB_LAYER + glob.MECH_FLY_LAYER - 0.05
		if(MechFXPlace(S, cx, cy, z, MECHFX_WAKE_W, MECHFX_WAKE_H, MechFXMatrix(sx, sy, ang)))
			MechFXDue(S, life)
		else
			MechFXFree(S)

proc/MechFXLight(z, cx, cy, state, frames, ang, sc, tint, vx, vy, decel, delay)
	set waitfor = 0
	if(delay > 0) sleep(delay * world.tick_lag)
	var/obj/mechfx/lit/L = MechFXGet(/obj/mechfx/lit)
	if(!L) return
	L.icon = MECHFX_LIGHTS_ICON
	L.icon_state = state
	L.color = MechFXRamp(tint, 7)
	L.alpha = 255
	if(!MechFXPlace(L, cx, cy, z, MECHFX_LIGHT_CANVAS, MECHFX_LIGHT_CANVAS, MechFXMatrix(sc, sc, MechFXQ(ang, 0.25))))
		MechFXFree(L)
		return
	if(vx || vy)
		if(decel) MechFXDriftSteps(L, vx, vy, decel, frames, (state == "streak" || state == "fast") ? 0.025 : MECHFX_TICK_S)
		else MechFXDriftLinear(L, vx, vy, frames)
	MechFXDue(L, frames)

proc/MechFXMask(size, travel, i)
	var/key = "[size]_[travel]_[i]"
	var/icon/I = MECHFX_MASKS[key]
	if(I) return I
	var/f = MECHFX_GHOSTMASK96_ICON
	if(size == 80) f = MECHFX_GHOSTMASK80_ICON
	else if(size == 160) f = MECHFX_GHOSTMASK160_ICON
	I = icon(f, "[travel]_[i]")
	MECHFX_MASKS[key] = I
	MECHFX_MASK_ORDER += key
	if(MECHFX_MASK_ORDER.len > 24)
		var/old = MECHFX_MASK_ORDER[1]
		MECHFX_MASK_ORDER.Cut(1, 2)
		MECHFX_MASKS -= old
	return I

proc/MechFXGhostAnim(obj/mechfx/O, pmin, span, list/u, peak, pw)
	for(var/i = 1 to 9)
		var/age = (i < 9) ? i * MECHFX_TICK_S : MECHFX_GHOST_LIFE
		var/dt = (i < 9) ? world.tick_lag : (MECHFX_GHOST_LIFE - 8 * MECHFX_TICK_S) * 10
		var/q = age / MECHFX_GHOST_LIFE
		var/a = (q >= 1) ? 0 : round(peak * 255 * ((1 - q) ** pw), 1)
		if(i == 1)
			animate(O, alpha = a, time = dt)
		else
			animate(alpha = a, time = dt)
	var/F = O.filters["mfxm"]
	if(!F) return
	var/hold = 0.35 * MECHFX_GHOST_LIFE
	animate(F, x = u[1] * pmin, y = u[2] * pmin, time = hold * 10, flags = ANIMATION_PARALLEL)
	var/n = ceil((MECHFX_GHOST_LIFE - hold) / 0.01 - 0.000001)
	var/prev = hold
	for(var/i = 1 to n)
		var/age = min(MECHFX_GHOST_LIFE, hold + i * 0.01)
		var/o = pmin + MechFXSstep(0.35, 1, age / MECHFX_GHOST_LIFE) * 1.15 * span
		animate(x = u[1] * o, y = u[2] * o, time = (age - prev) * 10)
		prev = age

proc/MechFXGhost(z, list/P, model, gx, gy, yb, d, f, travel, now)
	var/size = P["size"]
	var/list/pj = MECHFX_GHOSTPROJ["[model]_[d]_[f]_[travel]"]
	var/list/u = MECHFX_TRAVEL[travel]
	if(!pj || !u) return
	var/pmin = pj[1]
	var/span = pj[2]
	var/cv = size + 2 * MECHFX_GHOST_PAD
	var/gicon = MECHFX_GHOST96_ICON
	if(size == 80) gicon = MECHFX_GHOST80_ICON
	else if(size == 160) gicon = MECHFX_GHOST160_ICON
	var/icon/mask = MechFXMask(size, travel, now % (size == 160 ? 8 : 32))
	var/cx = gx + P["off"] + size / 2
	var/cy = gy + yb + size / 2
	mechfx_ghost_n = (mechfx_ghost_n + 1) % 900
	var/lay = 1 + mechfx_ghost_n * 0.001
	var/obj/mechfx/ghost/G = MechFXGet(/obj/mechfx/ghost)
	if(G)
		G.icon = gicon
		G.icon_state = "[model]_[d]_[f]"
		G.layer = lay
		G.alpha = round(0.72 * 255, 1)
		G.filters = filter(type = "alpha", icon = mask, x = u[1] * pmin, y = u[2] * pmin, name = "mfxm")
		if(MechFXPlace(G, cx, cy, z, cv, cv, null))
			MechFXGhostAnim(G, pmin, span, u, 0.72, 1.15)
			MechFXDue(G, 9)
		else
			MechFXFree(G)
	var/obj/mechfx/ghostglow/W = MechFXGet(/obj/mechfx/ghostglow)
	if(W)
		W.icon = gicon
		W.icon_state = "[model]_[d]_[f]s"
		W.layer = lay + 0.0005
		W.color = MechFXGlowColor(P["tint"])
		W.alpha = round(0.5 * 255, 1)
		W.filters = list(filter(type = "alpha", icon = mask, x = u[1] * pmin, y = u[2] * pmin, name = "mfxm"), filter(type = "blur", size = glob.MECHFX_GLOW_BLUR))
		if(MechFXPlace(W, cx, cy, z, cv, cv, null))
			MechFXGhostAnim(W, pmin, span, u, 0.5, 1.4)
			MechFXDue(W, 9)
		else
			MechFXFree(W)

mob/proc/MechFXHidden()
	return invisibility > 0 || alpha < 40 || AdminInviso

mob/proc/MechFXState()
	if(!mechfx_st) mechfx_st = new /datum/mechfx_state
	return mechfx_st

mob/proc/MechFXVisOff(obj/O)
	if(O) vis_contents -= O

mob/proc/MechFXVisOn(obj/O)
	if(O && !(O in vis_contents)) vis_contents += O

mob/proc/MechFXResetFlight(datum/mechfx_state/S)
	if(!S) return
	S.chains = null
	S.has_prev = 0
	S.pburst = 0
	S.burst_start = -1000
	S.burst_last = -1000
	S.ghost_tick = -1000

mob/proc/MechFXOccOn(datum/mechfx_state/S)
	if(!S.occ) S.occ = new /obj/mechfx/occ
	if(S.occ_pending)
		S.occ_pending = 0
		S.occ_token++
	MechFXVisOn(S.occ)

mob/proc/MechFXOccLater(datum/mechfx_state/S)
	set waitfor = 0
	var/tok = ++S.occ_token
	sleep(glob.MECHFX_OCC_LINGER * world.tick_lag)
	if(S.occ_token != tok || mech_air) return
	S.occ_pending = 0
	MechFXVisOff(S.occ)

mob/proc/MechFXAirOff(datum/mechfx_state/S)
	MechFXVisOff(S.plume)
	MechFXVisOff(S.plume2)
	MechFXVisOff(S.south)
	MechFXVisOff(S.night)
	MechFXVisOff(S.night2)
	S.plume_key = null
	S.south_key = null
	S.night_key = null
	if(S.chains || S.has_prev) MechFXResetFlight(S)
	if(S.occ && !S.occ_pending && (S.occ in vis_contents))
		S.occ_pending = 1
		MechFXOccLater(S)

mob/proc/MechFXClear()
	var/datum/mechfx_state/S = mechfx_st
	if(!S) return
	S.occ_token++
	S.hover_token++
	for(var/obj/O in list(S.plume, S.plume2, S.south, S.occ, S.night, S.night2))
		vis_contents -= O
	mechfx_st = null

mob/Players/MechFlightTick()
	var/b0 = mech_burst_left
	. = ..()
	if(mech) MechFXFlight(b0 > 0 && mech_burst_left < b0 && (mech_vx || mech_vy))

mob/Players/MechTakeoff()
	. = ..()
	if(. && mechfx_st) MechFXResetFlight(mechfx_st)

mob/Players/MechMount(obj/Items/Mech/R, remount = 0)
	MechFXClear()
	..()
	if(R && mech == R) MechFXMounted()

mob/Players/MechDismount(wreck = 0, silent = 0)
	. = ..()
	MechFXClear()

mob/proc/MechFXFlight(burst)
	if(!glob || !glob.MECHFX || !MECHFX_ASSETS || !mech) return
	var/list/P = MECHFX_PROFILES[mech.model]
	if(!P) return
	var/datum/mechfx_state/S = MechFXState()
	var/now = MechFXNow()
	var/X = (x - 1) * 32 + step_x
	var/Y = (y - 1) * 32 + step_y
	var/d = MechFXDir4(dir)
	var/vx = mech_vx
	var/vy = mech_vy
	var/spd = sqrt(vx * vx + vy * vy)
	var/hidden = MechFXHidden()
	if(!mech_air)
		MechFXAirOff(S)
		if(!hidden && MechHovers()) MechFXHover(S, P, X, Y, vx, vy, spd, now)
		return
	MechFXOccOn(S)
	var/yb = MechFlyBaseY() + MechFlyRise()
	var/vmax = max(0.001, MechVmax())
	if(burst)
		if(!S.pburst) S.burst_start = now
		S.burst_last = now
	if(!hidden)
		var/px = S.has_prev ? S.px : X
		var/py = S.has_prev ? S.py : Y
		var/pd = S.has_prev ? S.pdir : d
		var/ux
		var/uy
		if(spd > 0.3)
			ux = vx / spd
			uy = vy / spd
		else
			var/list/du = MechDirUnit(dir)
			ux = du[1]
			uy = du[2]
		if(burst && !S.pburst) MechFXIgnite(P, px, py, yb, pd, ux, uy, spd, vx, vy)
		if(burst) MechFXGhostCheck(S, P, px, py, yb, pd, ux, uy, now)
		MechFXChains(S, P, X, Y, yb, d, spd, burst, now)
	MechFXPlumeTick(S, P, d, spd, vmax, burst, now, hidden)
	MechFXSouthTick(S, P, d, vx, vy, spd, vmax, hidden)
	MechFXNightTick(S, P, spd, yb, hidden)
	S.px = X
	S.py = Y
	S.pdir = d
	S.pburst = burst
	S.has_prev = 1

mob/proc/MechFXIgnite(list/P, px, py, yb, pd, ux, uy, spd, vx, vy)
	var/list/an = P["anc"][pd]
	var/nx = px + P["off"] + an[1] + 0.5
	var/ny = py + yb + (P["size"] - an[2]) - 0.5
	var/ang = spd > 0.3 ? -arctan(vx, vy) : 0
	var/tint = P["tint"]
	for(var/i = 0 to 11)
		var/side = (i % 2) ? -1 : 1
		var/a2 = ang + 180 + side * MechFXU(17.1887, 41.253)
		var/v = MechFXU(380, 540)
		MechFXLight(z, nx - ux * 4, ny - uy * 4, "streak", 7, a2, 1.2, tint, cos(a2) * v, -sin(a2) * v, 1.3, rand() < 0.5 ? 1 : 0)
	for(var/i = 0 to 2)
		var/v = MechFXU(300, 380)
		MechFXLight(z, nx, ny, "fast", 9, ang + 180, 1.1, tint, -ux * v, -uy * v, 1.2, round(i * 0.6, 1))

mob/proc/MechFXGhostCheck(datum/mechfx_state/S, list/P, px, py, yb, pd, ux, uy, now)
	var/list/bl = P["blen"][pd]
	var/blen = (abs(ux) >= abs(uy)) ? bl[1] : bl[2]
	if(now - S.ghost_tick < 10)
		var/gdx = px - S.ghost_x
		var/gdy = py - S.ghost_y
		if(sqrt(gdx * gdx + gdy * gdy) < 0.62 * blen) return
	S.ghost_tick = now
	S.ghost_x = px
	S.ghost_y = py
	var/f = floor(world.time / P["delay"]) % P["frames"]
	MechFXGhost(z, P, mech.model, px, py, yb, pd, f, MechFXTravel(ux, uy), now)

mob/proc/MechFXChains(datum/mechfx_state/S, list/P, X, Y, yb, d, spd, burst, now)
	var/list/an = P["anc"][d]
	var/n = round(an.len / 2)
	if(!S.chains) S.chains = list()
	while(S.chains.len < n)
		S.chains += new /datum/mechfx_chain
	var/size = P["size"]
	var/off = P["off"]
	var/moving = spd > 0.5
	var/list/nz = P["noz"]
	var/ext = (P["plume"] && nz[d]) ? 0.6 * (7 + 0.85 * spd + (burst ? 8 : 0)) : 0
	for(var/i = 1 to n)
		var/datum/mechfx_chain/C = S.chains[i]
		var/tx = an[i * 2 - 1]
		var/ty = an[i * 2]
		if(ext)
			switch(d)
				if("E") tx -= ext
				if("W") tx += ext
				if("N") ty += ext
		if(!C.has_rel)
			C.relx = tx
			C.rely = ty
			C.has_rel = 1
		else
			C.relx += (tx - C.relx) * 0.6
			C.rely += (ty - C.rely) * 0.6
		var/ax = X + off + C.relx + 0.5
		var/ay = Y + yb + (size - C.rely) - 0.5
		if(C.has_pt) MechFXSegment(C, P, ax, ay, burst, moving, now)
		C.ax = ax
		C.ay = ay
		C.aburst = burst
		C.amoving = moving
		C.has_pt = 1

mob/proc/MechFXSegment(datum/mechfx_chain/C, list/P, bx, by, bburst, bmoving, now)
	var/dx = bx - C.ax
	var/dy = by - C.ay
	var/len = sqrt(dx * dx + dy * dy)
	if(len < 1.5 || !(C.amoving || bmoving)) return
	if(now - C.last_emit > glob.MECHFX_CHAIN_GAP)
		C.vis = 0
		C.since = 0
		C.gap = rand(2, 4)
	C.last_emit = now
	var/boost = C.aburst || bburst
	var/pieces = max(1, ceil(len / MECHFX_PIECE_LEN))
	var/ang = MechFXQ(-arctan(dx, dy), 0.25)
	var/tw = P["tw"]
	var/tint = P["tint"]
	var/sl = len / pieces
	var/ux = dx / len
	var/uy = dy / len
	var/gs = 16 * tw * (boost ? 1.3 : 1)
	for(var/i = 0 to pieces - 1)
		var/f0 = i / pieces
		var/f1 = (i + 1) / pieces
		var/ramp = MechFXSstep(0, 34, C.vis + sl * 0.5)
		MechFXStamp(z, C.ax + dx * (f0 + f1) / 2, C.ay + dy * (f0 + f1) / 2, ang, sl / MECHFX_STAMP_L, tw * (0.35 + 0.65 * ramp), ramp, C.seg % MECHFX_WAKE_PHASES, boost, tint)
		C.seg++
		C.vis += sl
		C.since++
		if(C.vis > 30 && C.since >= C.gap)
			C.since = 0
			C.gap = rand(2, 4)
			var/bv = 90 * MechFXU(0.8, 1.2) * (boost ? 1.3 : 1)
			MechFXLight(z, C.ax + dx * f1, C.ay + dy * f1, "bead", 14, ang + 180, tw * 0.9, tint, -ux * bv, -uy * bv, 0.6, 0)
		if(C.vis > 18)
			var/ng = 0.6 * (boost ? 1.8 : 1) * min(1, sl / MECHFX_STAMP_L)
			var/cnt = floor(ng) + ((rand() < ng - floor(ng)) ? 1 : 0)
			for(var/j = 1 to cnt)
				var/q = rand()
				var/lat = MechFXGauss(gs)
				var/gx = C.ax + dx * (f0 + (f1 - f0) * q) - uy * lat
				var/gy = C.ay + dy * (f0 + (f1 - f0) * q) + ux * lat
				var/ov = MechFXU(3, 12) * (lat >= 0 ? 1 : -1)
				var/bk = -MechFXU(0, 10)
				var/g = rand(1, 4)
				MechFXLight(z, gx, gy, "g[g]", MECHFX_GLINT_FRAMES[g], 0, 1, tint, -uy * ov + ux * bk, ux * ov + uy * bk, 0, rand() < 0.5 ? 1 : 0)

mob/proc/MechFXPlumeLook(obj/mechfx/plume/O, list/P, dd, state, canvas, r, ks)
	var/list/n = P["noz"][dd]
	O.icon = canvas == MECHFX_BOOST_CANVAS ? MECHFX_PLUMEBOOST_ICON : MECHFX_PLUME_ICON
	O.icon_state = state
	O.color = MechFXRamp(P["tint"], 1, r * r)
	O.alpha = round(255 * r, 1)
	O.pixel_x = n[1] - canvas / 2
	O.pixel_y = P["size"] - n[2] - canvas / 2
	var/matrix/M = matrix()
	M.Scale((dd == "W") ? -ks : ks, 1)
	if(dd == "N") M.Turn(-90)
	O.transform = M

mob/proc/MechFXPlumeTick(datum/mechfx_state/S, list/P, d, spd, vmax, burst, now, hidden)
	var/pm = P["plume"]
	var/list/nz = P["noz"]
	if(S.plume2 && now >= S.plume2_until) MechFXVisOff(S.plume2)
	if(hidden || !pm || !(nz[d] || (S.has_prev && nz[S.pdir])))
		MechFXVisOff(S.plume)
		S.plume_key = null
		return
	var/thr = min(1, spd / vmax)
	var/boosting = burst || (now - S.burst_last <= 5)
	var/tq = now * MECHFX_TICK_S
	var/fl = 1 + 0.15 * sin(360 * (tq * 3.1 + 0.3)) * cos(360 * (tq * 1.7 + 0.9))
	var/state
	var/canvas = MECHFX_PLUME_CANVAS
	var/r = 1
	var/lp
	var/lb
	if(thr < 0.03 && !boosting)
		lp = max(4, 5 * fl)
		lb = clamp(round(lp, 1), 4, 6)
		state = "[pm]i[lb]"
	else
		var/L = 7 + 0.85 * spd
		var/amp = 0.7 + 0.3 * thr
		if(boosting)
			canvas = MECHFX_BOOST_CANVAS
			r = amp
			if((now - S.burst_start) * MECHFX_TICK_S < 0.08)
				lp = max(4, L * 0.85 * fl)
				lb = clamp(2 * round(lp / 2, 1), 20, 66)
				state = "[pm]f[lb]"
			else
				lp = max(4, (L + 8) * fl)
				lb = clamp(2 * round(lp / 2, 1), 20, 82)
				state = "[pm]b[lb]"
		else
			var/k = MECHFX_AMP_LEVELS.len
			for(var/i = 1 to MECHFX_AMP_LEVELS.len)
				if(amp <= MECHFX_AMP_LEVELS[i] + 0.0001)
					k = i
					break
			r = amp / MECHFX_AMP_LEVELS[k]
			lp = max(4, L * fl)
			lb = clamp(round(lp, 1), 4, 48)
			state = "[pm]m[k - 1]_[lb]"
	r = clamp(MechFXQ(r, 0.01), 0, 1)
	var/ks = MechFXQ(lp / lb, 0.01)
	var/turned = S.has_prev && S.pdir != d
	if(turned && nz[S.pdir])
		if(!S.plume2) S.plume2 = new /obj/mechfx/plume
		MechFXPlumeLook(S.plume2, P, S.pdir, state, canvas, r, ks)
		MechFXVisOn(S.plume2)
		animate(S.plume2, alpha = 0, time = world.tick_lag)
		S.plume2_until = now + 1
	if(!nz[d])
		MechFXVisOff(S.plume)
		S.plume_key = null
		return
	if(!S.plume) S.plume = new /obj/mechfx/plume
	var/obj/mechfx/plume/O = S.plume
	MechFXVisOn(O)
	var/key = "[state]|[r]|[d]|[ks]"
	if(key == S.plume_key && !turned) return
	S.plume_key = key
	MechFXPlumeLook(O, P, d, state, canvas, r, ks)
	if(turned)
		var/fa = O.alpha
		O.alpha = 0
		animate(O, alpha = fa, time = world.tick_lag)

mob/proc/MechFXSouthTick(datum/mechfx_state/S, list/P, d, vx, vy, spd, vmax, hidden)
	if(hidden || d != "S" || spd <= 0.5 || !P["plume"])
		MechFXVisOff(S.south)
		S.south_key = null
		return
	var/amp = clamp(MechFXQ(min(1, spd / vmax), 0.01), 0, 1)
	var/a = arctan(vx, vy)
	if(a < 0) a += 360
	var/i = round(a / (360 / MECHFX_SOUTH_BUCKETS), 1) % MECHFX_SOUTH_BUCKETS
	if(!S.south) S.south = new /obj/mechfx/south
	var/obj/mechfx/south/O = S.south
	MechFXVisOn(O)
	var/key = "[i]|[amp]"
	if(key == S.south_key) return
	S.south_key = key
	O.icon = P["size"] == 160 ? MECHFX_SOUTH160_ICON : MECHFX_SOUTH_ICON
	O.icon_state = "[mech.model]_[i]"
	O.color = MechFXRamp(P["tint"], 1, amp * amp)
	O.alpha = round(255 * amp, 1)

mob/proc/MechFXNightTick(datum/mechfx_state/S, list/P, spd, yb, hidden)
	if(hidden || !glob.LIGHTING || !_fx_glow_icon || !(spd > 0.5 || !P["plume"]))
		MechFXVisOff(S.night)
		MechFXVisOff(S.night2)
		S.night_key = null
		return
	var/turf/T = loc
	if(!isturf(T)) return
	var/kf = min(1, 0.25 + spd / 20)
	var/list/tt = MECHFX_TINTS[P["tint"]] || MECHFX_TINTS["blue"]
	var/col = rgb(round((tt[1] * 0.5 + 0.5) * 255, 1), round((tt[2] * 0.5 + 0.5) * 255, 1), round((tt[3] * 0.5 + 0.5) * 255, 1))
	var/want = round(153 * kf * LightRenderStrength(T) / 8, 1) * 8
	var/cap = LightGlowBudget(T, col, want)
	if(cap <= 0)
		MechFXVisOff(S.night)
		MechFXVisOff(S.night2)
		S.night_key = null
		return
	var/mr = glob.MULTIPLY_REVEAL ? 1 : 0
	var/list/an = P["anc"]["E"]
	var/key = "[cap]|[mr]|[yb]"
	if(!S.night)
		S.night = new /obj/mechfx/night
		S.night2 = new /obj/mechfx/night
	MechFXVisOn(S.night)
	MechFXVisOn(S.night2)
	if(key == S.night_key) return
	S.night_key = key
	for(var/obj/mechfx/night/N in list(S.night, S.night2))
		N.icon = _fx_glow_icon
		N.color = col
		N.plane = mr ? LIGHTING_PLANE : 0
	S.night.alpha = cap
	S.night.transform = matrix(1.375, 0, 0, 0, 0.6875, 0)
	S.night.pixel_x = round(P["size"] / 2 - 32, 1)
	S.night.pixel_y = round(6 - yb - 32, 1)
	S.night2.alpha = round(cap * 0.8, 1)
	S.night2.transform = matrix(1.25, 0, 0, 0, 1.25, 0)
	S.night2.pixel_x = round(P["size"] / 2 - 32, 1)
	S.night2.pixel_y = round(P["size"] - an[2] - 32, 1)
