globalTracker
	var/tmp
		IMPACT_FRAMES = TRUE
		IMPACT_BURSTS = TRUE
		IMPACT_RIPPLES = TRUE
		IMPACT_FRAME_CD = 12

obj/Skills/var/ImpactFrame = 0
obj/AutoHitter/var/ImpactFrame = 0

client
	var/tmp
		_if_until = 0
		_if_bw_on = 0
		_zoom_until = 0

var/_impact_tick = 0
var/_impact_n = 0

proc/FxHeavyImpact(atom/m, obj/Skills/Z = null, priority = 0)
	if(!glob || !m) return
	var/turf/T = get_turf(m)
	if(!T) return
	if(_impact_tick != world.time)
		_impact_tick = world.time
		_impact_n = 0
	if(++_impact_n > 3 && !priority) return
	if(glob.IMPACT_BURSTS) FxImpactBurst(T, Z)
	var/fam = prob(50) ? "lines" : "spikes"
	for(var/client/C)
		var/mob/CM = C.mob
		if(!CM || CM.z != T.z || get_dist(CM, T) > 15) continue
		if(glob.IMPACT_FRAMES)
			FxImpactLinesClient(C, T, fam)
			FxImpactFrameClient(C)
		if(glob.IMPACT_RIPPLES) FxImpactRippleClient(C, T)

/obj/gfx_impact_lines
	icon = 'impact_frames.dmi'
	plane = 0
	layer = 9
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	screen_loc = "1,1"

client/var/tmp/obj/gfx_impact_lines/_if_lines

proc/_ImpactScreenPx(client/C, turf/T)
	var/turf/E = get_turf(C.eye ? C.eye : C.mob)
	if(!E || E.z != T.z) return null
	var/list/vt = GfxCameraViewTiles(C)
	return list(vt[1] * 16 + (T.x - E.x) * 32, vt[2] * 16 + (T.y - E.y) * 32, vt[1] * 32, vt[2] * 32)

proc/FxImpactLinesClient(client/C, turf/T, fam)
	var/list/sp = _ImpactScreenPx(C, T)
	if(!sp) return
	var/vw = sp[3]
	var/vh = sp[4]
	var/cx = clamp(sp[1], vw * 0.3, vw * 0.7)
	var/cy = clamp(sp[2], vh * 0.3, vh * 0.7)
	var/obj/gfx_impact_lines/L = C._if_lines
	if(!L)
		L = new
		C._if_lines = L
	var/matrix/M = matrix()
	M.Scale(max(vw, vh) * 1.7 / 512)
	M.Translate(cx - 256, cy - 256)
	L.transform = M
	L.icon_state = "[fam]_a"
	L.color = "#ffffff"
	C.screen += L
	spawn(1)
		if(L)
			L.icon_state = "[fam]_b"
			L.color = "#000000"
	spawn(4)
		if(C && L)
			C.screen -= L

proc/_ImpactMatrix(mid, k)
	var/c = 0.5 - k * mid
	return list(0.299*k,0.299*k,0.299*k,0, 0.587*k,0.587*k,0.587*k,0, 0.114*k,0.114*k,0.114*k,0, 0,0,0,1, c,c,c,0)

proc/FxImpactFrameClient(client/C)
	if(!C || world.time < C._if_until) return
	if(C.prefs && C.prefs.reducedFlashes) return
	C._if_until = world.time + max(4, glob.IMPACT_FRAME_CD)
	var/turf/ET = get_turf(C.eye ? C.eye : C.mob)
	var/dark = ET ? LightDarkFrac(ET) : 0
	var/mid = 0.45 - 0.30 * clamp(dark, 0, 1)
	C._if_bw_on = 1
	_ImpactApply(C, _ImpactMatrix(mid, -9))
	spawn(1)
		if(C && C._if_bw_on) _ImpactApply(C, _ImpactMatrix(mid, 9))
	spawn(3)
		if(C) _ImpactClear(C)

proc/_ImpactApply(client/C, list/M)
	if(!C) return
	for(var/obj/O in list(C.client_plane_master, C.fx_relay, C.fxnb_relay))
		if(!O) continue
		var/F = O.filters["if_bw"]
		if(F) O.filters -= F
		O.filters += filter(name = "if_bw", type = "color", color = M)

proc/_ImpactClear(client/C)
	C._if_bw_on = 0
	for(var/obj/O in list(C.client_plane_master, C.fx_relay, C.fxnb_relay))
		if(!O) continue
		var/F = O.filters["if_bw"]
		if(F) O.filters -= F

/obj/gfx_impact_burst
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	plane = 0
	layer = 6.56
	blend_mode = BLEND_ADD

var/list/_impact_burst_pool = list()

proc/FxImpactBurst(turf/T, obj/Skills/Z)
	if(!_hd2d_ember_icon) return
	var/obj/gfx_impact_burst/B
	if(_impact_burst_pool.len)
		B = _impact_burst_pool[_impact_burst_pool.len]
		_impact_burst_pool.len--
	else
		B = new
	if(!B.particles)
		var/particles/P = new
		P.width = 192
		P.height = 192
		P.count = 60
		P.spawning = 0
		P.lifespan = generator("num", 4, 9)
		P.fade = 5
		P.icon = _hd2d_ember_icon
		P.position = generator("circle", 0, 6)
		P.velocity = generator("circle", 8, 26)
		P.gravity = list(0, -0.4)
		P.scale = generator("num", 0.5, 1.1)
		P.grow = -0.04
		B.particles = P
	var/col = Z ? FxIconPaint(Z.icon, Z.icon_state) : null
	B.color = col ? col : "#ffe6c0"
	B.loc = T
	B.particles.spawning = 55
	spawn(2)
		if(B && B.particles) B.particles.spawning = 0
	spawn(16)
		if(B)
			B.loc = null
			_impact_burst_pool += B

proc/FxZoomPunch(client/C, turf/T, mag = 1.05, hold = 2)
	if(!C || !C.client_plane_master || !T) return
	if(C.prefs && C.prefs.reducedFlashes) return
	if(world.time < C._zoom_until) return
	C._zoom_until = world.time + max(4, glob.IMPACT_FRAME_CD)
	var/list/sp = _ImpactScreenPx(C, T)
	if(!sp) return
	var/vw = sp[3]
	var/vh = sp[4]
	var/fx = clamp(sp[1], vw * 0.3, vw * 0.7)
	var/fy = clamp(sp[2], vh * 0.3, vh * 0.7)
	var/matrix/Z = matrix()
	Z.Translate(-fx, -fy)
	Z.Scale(mag)
	Z.Translate(fx, fy)
	animate(C.client_plane_master, transform = Z, time = 1, easing = QUAD_EASING|EASE_OUT)
	spawn(1 + max(hold, 0))
		if(C && C.client_plane_master)
			animate(C.client_plane_master, transform = matrix(), time = 3, easing = QUAD_EASING|EASE_OUT)

proc/FxImpactRippleClient(client/C, turf/T)
	if(!C || !C.client_plane_master || !C.mob) return
	var/obj/M = C.client_plane_master
	if(M.filters["fx_ripple"]) return
	var/list/sp = _ImpactScreenPx(C, T)
	if(!sp) return
	M.filters += filter(name = "fx_ripple", type = "ripple", x = sp[1], y = sp[2], size = 7, repeat = 24, radius = 4, falloff = 3, flags = WAVE_BOUNDED)
	animate(M.filters["fx_ripple"], radius = round(max(sp[3], sp[4]) * 0.65), size = 1, time = 5)
	spawn(6)
		var/obj/M2 = C ? C.client_plane_master : null
		if(M2)
			var/F = M2.filters["fx_ripple"]
			if(F) M2.filters -= F

/mob/Admin2/verb/Impact_Test()
	set category = "Admin"
	set name = "Impact Test"
	FxHeavyImpact(src)
	src << "Impact package fired on your tile."

/mob/Admin2/verb/Impact_Frames_Toggle()
	set category = "Admin"
	set name = "Impact Frames Toggle"
	glob.IMPACT_FRAMES = !glob.IMPACT_FRAMES
	src << "Impact frames: [glob.IMPACT_FRAMES ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set impact frames to [glob.IMPACT_FRAMES].")

/mob/Admin2/verb/Impact_Bursts_Toggle()
	set category = "Admin"
	set name = "Impact Bursts Toggle"
	glob.IMPACT_BURSTS = !glob.IMPACT_BURSTS
	src << "Impact bursts: [glob.IMPACT_BURSTS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set impact bursts to [glob.IMPACT_BURSTS].")

/mob/Admin2/verb/Impact_Ripples_Toggle()
	set category = "Admin"
	set name = "Impact Ripples Toggle"
	glob.IMPACT_RIPPLES = !glob.IMPACT_RIPPLES
	src << "Impact ripples: [glob.IMPACT_RIPPLES ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set impact ripples to [glob.IMPACT_RIPPLES].")
