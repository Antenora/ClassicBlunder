globalTracker/var/tmp
	ENERGYFX = TRUE
	ENERGYFX_CAP = 2200
	ENERGYFX_BLUR = 1.5
	ENERGYFX_LIGHT_SCALE = 2

var/list/ENERGYFX_POOL = list()
var/list/ENERGYFX_DUE
var/energyfx_live = 0
var/energyfx_pending = 0
var/energyfx_loop = 0
var/energyfx_anim_n = 0
var/energyfx_tl_key_n = 0
var/energyfx_tl_plan_n = 0

/mob/Admin2/verb/Energy_FX_Stats()
	set category = "Admin"
	set name = "Energy FX Stats"
	var/a0 = energyfx_anim_n
	var/c0 = beamfx_cost
	var/n0 = beamfx_cost_n
	src << "Energy FX stats: sampling 5 seconds..."
	sleep(50)
	var/steps = beamfx_cost_n - n0
	var/ms = steps ? (beamfx_cost - c0) * world.tick_lag / steps : 0
	src << "Energy FX: [energyfx_live] live objects (cap [glob.ENERGYFX_CAP], [ENERGYFX_SKIPPED] skipped), [round((energyfx_anim_n - a0) / 5, 1)] animation steps per second, [steps] beam updates, [round(ms, 0.01)] ms per beam update."

/mob/Admin2/verb/Energy_FX_Toggle()
	set category = "Admin"
	set name = "Energy FX Toggle"
	glob.ENERGYFX = !glob.ENERGYFX
	src << "Energy FX: [glob.ENERGYFX ? "ON" : "OFF"] (new effects only)."
	Log("Admin", "[ExtractInfo(src)] set Energy FX to [glob.ENERGYFX].")

/obj/energyfx
	icon = BEAMFX_STAMP_ICON
	mouse_opacity = 0
	density = 0
	animate_movement = NO_STEPS
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	surface_profile = "ground_flat"
	bound_width = 1
	bound_height = 1
	var/tmp/fx_free = -1000
	var/tmp/fx_due = 0
	var/tmp/fx_w = 0
	var/tmp/fx_h = 0

/obj/energyfx/paint
	plane = ENERGYFX_PAINT_PLANE

/obj/energyfx/light
	plane = ENERGYFX_LIGHT_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx/emit
	icon = null
	plane = ENERGYFX_PAINT_PLANE
	layer = 5.5

/obj/energyfx/sharp
	plane = ENERGYFX_SHARP_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx/gpaint
	plane = ENERGYFX_GPAINT_PLANE

/obj/energyfx/grlight
	plane = ENERGYFX_GRLIGHT_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx/fpaint
	plane = ENERGYFX_FPAINT_PLANE

/obj/energyfx/fsharp
	plane = ENERGYFX_FSHARP_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx/flight
	plane = ENERGYFX_FLIGHT_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx/flight2
	plane = ENERGYFX_FLIGHT2_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx_master
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER

/obj/energyfx_master/paint
	plane = ENERGYFX_PAINT_PLANE
	render_target = "*energyfx_paint"

/obj/energyfx_master/light
	plane = ENERGYFX_LIGHT_PLANE
	render_target = "*energyfx_light"
	New()
		..()
		EnergyFXLightFilters(src)

/obj/energyfx_master/occ
	plane = ENERGYFX_OCC_PLANE
	render_target = "*energyfx_occ"

/obj/energyfx_master/locc
	plane = ENERGYFX_LOCC_PLANE
	render_target = "*energyfx_locc"

/obj/energyfx_master/hide
	plane = ENERGYFX_HIDE_PLANE
	render_target = "*energyfx_hide"

/obj/energyfx_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	mouse_opacity = 0

/obj/energyfx_relay/paint
	layer = ENERGYFX_PAINT_RELAY_LAYER
	render_source = "*energyfx_paint"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*energyfx_occ", flags = MASK_INVERSE)

/obj/energyfx_relay/light
	layer = ENERGYFX_LIGHT_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_light"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE)
		EnergyFXLightRelayColor(src)

/obj/energyfx_master/sharp
	plane = ENERGYFX_SHARP_PLANE
	render_target = "*energyfx_sharp"

/obj/energyfx_master/gpaint
	plane = ENERGYFX_GPAINT_PLANE
	render_target = "*energyfx_gpaint"

/obj/energyfx_master/grlight
	plane = ENERGYFX_GRLIGHT_PLANE
	render_target = "*energyfx_grlight"
	New()
		..()
		filters = filter(type = "blur", size = ENERGYFX_PASS_BLUR)

/obj/energyfx_master/fpaint
	plane = ENERGYFX_FPAINT_PLANE
	render_target = "*energyfx_fpaint"

/obj/energyfx_master/fsharp
	plane = ENERGYFX_FSHARP_PLANE
	render_target = "*energyfx_fsharp"

/obj/energyfx_master/flight
	plane = ENERGYFX_FLIGHT_PLANE
	render_target = "*energyfx_flight"
	New()
		..()
		filters = filter(type = "blur", size = ENERGYFX_PASS_BLUR)

/obj/energyfx_master/flight2
	plane = ENERGYFX_FLIGHT2_PLANE
	render_target = "*energyfx_flight2"
	New()
		..()
		filters = filter(type = "blur", size = ENERGYFX_PASS_BLUR)

/obj/energyfx_relay/sharp
	layer = ENERGYFX_SHARP_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_sharp"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE)

/obj/energyfx_relay/gpaint
	layer = ENERGYFX_GPAINT_RELAY_LAYER
	render_source = "*energyfx_gpaint"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*energyfx_occ", flags = MASK_INVERSE)

/obj/energyfx_relay/grlight
	layer = ENERGYFX_GRLIGHT_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_grlight"
	color = list(ENERGYFX_PASS_LS, 0, 0, 0, ENERGYFX_PASS_LS, 0, 0, 0, ENERGYFX_PASS_LS)
	New()
		..()
		filters = filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE)

/obj/energyfx_relay/fpaint
	layer = ENERGYFX_FPAINT_RELAY_LAYER
	render_source = "*energyfx_fpaint"

/obj/energyfx_relay/fsharp
	layer = ENERGYFX_FSHARP_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_fsharp"

/obj/energyfx_relay/flight
	layer = ENERGYFX_FLIGHT_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_flight"
	color = list(ENERGYFX_PASS_LS, 0, 0, 0, ENERGYFX_PASS_LS, 0, 0, 0, ENERGYFX_PASS_LS)

/obj/energyfx_relay/flight2
	layer = ENERGYFX_FLIGHT2_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_flight2"
	color = list(ENERGYFX_PASS_LS, 0, 0, 0, ENERGYFX_PASS_LS, 0, 0, 0, ENERGYFX_PASS_LS)

proc/EnergyFXLightFilters(obj/energyfx_master/light/M)
	if(!M) return
	var/b = glob ? glob.ENERGYFX_BLUR : 1.5
	M.filters = (b > 0) ? filter(type = "blur", size = b) : null

proc/EnergyFXLightRelayColor(obj/O)
	var/k = glob ? glob.ENERGYFX_LIGHT_SCALE : 1
	O.color = (k == 1) ? null : list(k, 0, 0, 0, k, 0, 0, 0, k)

client/var/tmp/list/energyfx_screen

proc/EnergyFXEnsureMasters(client/C)
	if(!C) return
	if(!C.energyfx_screen)
		C.energyfx_screen = list(new /obj/energyfx_master/paint, new /obj/energyfx_master/light, new /obj/energyfx_master/occ, new /obj/energyfx_master/locc, new /obj/energyfx_master/hide, new /obj/energyfx_master/rimw, new /obj/energyfx_master/rima, new /obj/energyfx_relay/paint, new /obj/energyfx_relay/light, new /obj/energyfx_relay/rimw, new /obj/energyfx_relay/rima, new /obj/energyfx_master/sharp, new /obj/energyfx_master/gpaint, new /obj/energyfx_master/grlight, new /obj/energyfx_master/fpaint, new /obj/energyfx_master/fsharp, new /obj/energyfx_master/flight, new /obj/energyfx_master/flight2, new /obj/energyfx_relay/sharp, new /obj/energyfx_relay/gpaint, new /obj/energyfx_relay/grlight, new /obj/energyfx_relay/fpaint, new /obj/energyfx_relay/fsharp, new /obj/energyfx_relay/flight, new /obj/energyfx_relay/flight2)
	for(var/obj/O in C.energyfx_screen)
		if(!(O in C.screen)) C.screen += O

proc/EnergyFXNow()
	return round(world.time / world.tick_lag, 1)

var/ENERGYFX_SKIPPED = 0
var/energyfx_skip_logged = -1000
var/list/ENERGYFX_SKIP_NAMES = list()

proc/EnergyFXRegisterSkipName(key, name)
	ENERGYFX_SKIP_NAMES[key] = name
	return 1

proc/EnergyFXSkipName(who)
	if(isnull(who)) return "an effect"
	if(istext(who) || ispath(who))
		var/n = ENERGYFX_SKIP_NAMES[who]
		return n ? n : "[who]"
	if(istype(who, /datum/beamfx))
		var/datum/beamfx/F = who
		return F.fx_name ? F.fx_name : "a beam"
	return "[who]"

proc/EnergyFXSkip(who)
	ENERGYFX_SKIPPED++
	if(world.time - energyfx_skip_logged < 10) return
	energyfx_skip_logged = world.time
	world.log << "ENERGYFX: cap [glob.ENERGYFX_CAP] reached, skipped [EnergyFXSkipName(who)] ([ENERGYFX_SKIPPED] skipped so far)"

proc/EnergyFXGet(path, who)
	if(!glob) return null
	if(energyfx_live >= glob.ENERGYFX_CAP)
		EnergyFXSkip(who)
		return null
	var/obj/energyfx/O
	var/list/P = ENERGYFX_POOL[path]
	if(P && P.len)
		O = P[1]
		if(O.fx_free <= EnergyFXNow() - 2)
			P.Cut(1, 2)
		else
			O = null
	if(!O) O = new path
	energyfx_live++
	return O

proc/EnergyFXFree(obj/energyfx/O)
	if(!O) return
	animate(O)
	if(O.fx_car)
		O.fx_car.vis_contents -= O
		O.fx_car = null
	O.loc = null
	O.transform = null
	O.color = null
	O.alpha = 255
	if(O.particles) O.particles = null
	if(O.overlays.len) O.overlays.Cut()
	if(O.vis_contents.len) O.vis_contents.Cut()
	O.plane = initial(O.plane)
	O.blend_mode = initial(O.blend_mode)
	O.fx_free = EnergyFXNow()
	O.fx_due = 0
	energyfx_live = max(0, energyfx_live - 1)
	var/list/P = ENERGYFX_POOL[O.type]
	if(!P)
		P = list()
		ENERGYFX_POOL[O.type] = P
	if(P.len < 1500) P += O

proc/EnergyFXDue(obj/energyfx/O, ticks)
	if(!ENERGYFX_DUE)
		ENERGYFX_DUE = new /list(ENERGYFX_RING)
		for(var/i = 1 to ENERGYFX_RING)
			ENERGYFX_DUE[i] = list()
	O.fx_due = EnergyFXNow() + max(1, round(ticks, 1))
	var/list/B = ENERGYFX_DUE[(O.fx_due % ENERGYFX_RING) + 1]
	B += O
	energyfx_pending++
	if(!energyfx_loop) EnergyFXLoop()

proc/EnergyFXLoop()
	set waitfor = 0
	if(energyfx_loop) return
	energyfx_loop = 1
	var/last = EnergyFXNow()
	while(energyfx_pending > 0)
		sleep(world.tick_lag)
		var/now = EnergyFXNow()
		if(now - last > ENERGYFX_RING) last = now - ENERGYFX_RING
		for(var/t = last + 1, t <= now, t++)
			var/list/B = ENERGYFX_DUE[(t % ENERGYFX_RING) + 1]
			if(!B.len) continue
			var/n = B.len
			for(var/obj/energyfx/O in B)
				if(O.fx_due && O.fx_due <= t) EnergyFXFree(O)
			B.Cut()
			energyfx_pending = max(0, energyfx_pending - n)
		last = now
	energyfx_loop = 0

var/list/ENERGYFX_REG = list()

/datum/energyfx_row
	var/path
	var/look
	var/name
	var/def_main
	var/def_core
	var/def_glow
	var/hit_icon
	var/width = 1
	var/length = 10
	var/overflight = 0.3
	var/list/holds
	var/list/extra
	var/datum/energyfx_look/handler

proc/EnergyFXReg(path, look, name, def_main, def_core, def_glow, hit_icon, width = 1, length = 10, overflight = 0.3, list/extra)
	var/datum/energyfx_row/R = new
	R.path = path
	R.look = look
	R.name = name
	R.def_main = def_main
	R.def_core = def_core
	R.def_glow = def_glow
	R.hit_icon = hit_icon
	R.width = width
	R.length = length
	R.overflight = overflight
	R.extra = extra
	if(!(path in ENERGYFX_REG)) ENERGYFX_REG += path
	ENERGYFX_REG[path] = R
	if(name) EnergyFXRegisterSkipName(path, name)
	return R

proc/EnergyFXRow(obj/Skills/Z)
	if(!Z) return null
	return ENERGYFX_REG[Z.type]

proc/EnergyFXRowOf(path)
	return ENERGYFX_REG[path]

var/list/ENERGYFX_NONCANON_BEAMS = list(/obj/Skills/Projectile/Beams/Shine_Ray, /obj/Skills/Projectile/Beams/Gamma_Ray, /obj/Skills/Projectile/Beams/Killer_Shine)

proc/EnergyFXRowCanon(datum/energyfx_row/R)
	if(!R) return 0
	if(R.extra && R.extra["canon"]) return 1
	if(R.look == "beam") return !(R.path in ENERGYFX_NONCANON_BEAMS)
	return 0

proc/EnergyFXIsSub(col)
	return istext(col) && copytext(col, 1, 2) == "-"

proc/EnergyFXSlotRGB(col, ref)
	if(!EnergyFXIsSub(col)) return BeamFXHexRGB(col)
	var/list/p = BeamFXHexRGB(copytext(col, 2))
	if(!p) return null
	return list(max(0, ref - p[1]), max(0, ref - p[2]), max(0, ref - p[3]))

/datum/energyfx_colors
	var/gray = 0
	var/bright = 1
	var/list/main255
	var/list/core255
	var/list/glow255
	var/list/ramp

/datum/energyfx_colors/proc/PaintMatrix(kp = 1)
	if(gray)
		return list(bright, bright, bright, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	var/list/edge = ramp[2]
	var/list/core = ramp[3]
	return list((core[1] - edge[1]) * kp, (core[2] - edge[2]) * kp, (core[3] - edge[3]) * kp, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, edge[1], edge[2], edge[3], 0)

/datum/energyfx_colors/proc/LightMatrix(k = 1)
	var/list/lc = ramp[1]
	var/list/lcore = ramp[4]
	var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : 1
	var/g = (gray ? 0.35 * bright : 1) / ls
	return list((lcore[1] - lc[1]) * k * g, (lcore[2] - lc[2]) * k * g, (lcore[3] - lc[3]) * k * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)

proc/EnergyFXResolveColors(main, core, glow, def_main, def_core, def_glow)
	var/datum/energyfx_colors/C = new
	var/list/c = EnergyFXSlotRGB(main ? main : def_main, 158)
	if(!c) c = list(0, 0, 0)
	var/lum = BeamFXLum(list(c[1] / 255, c[2] / 255, c[3] / 255))
	var/mx = max(c[1], c[2], c[3])
	var/sat = mx ? (mx - min(c[1], c[2], c[3])) / mx : 0
	C.core255 = EnergyFXSlotRGB(core ? core : def_core, 255)
	C.glow255 = EnergyFXSlotRGB(glow ? glow : def_glow, 158)
	if(lum < ENERGYFX_NEAR_BLACK || sat < ENERGYFX_GRAY_SAT)
		C.gray = 1
		C.bright = (lum < ENERGYFX_NEAR_BLACK) ? 1 : mx / 255
		C.main255 = list(153, 153, 153)
	else
		C.main255 = c
	C.ramp = BeamFXRamp(C.main255, C.core255, C.glow255)
	return C

proc/EnergyFXSkillColors(obj/Skills/Z, datum/energyfx_row/R)
	if(!R) R = EnergyFXRow(Z)
	var/own = Z && !EnergyFXRowCanon(R)
	return EnergyFXResolveColors(own ? Z.EnergyColorMain : null, own ? Z.EnergyColorCore : null, own ? Z.EnergyColorGlow : null, R ? R.def_main : null, R ? R.def_core : null, R ? R.def_glow : null)

proc/EnergyFXPaintMatrix(main, core)
	var/datum/energyfx_colors/C = EnergyFXResolveColors(main, core, null, null, null, null)
	return C.PaintMatrix()

proc/EnergyFXLightMatrix(glow, core, main)
	var/datum/energyfx_colors/C = EnergyFXResolveColors(main, core, glow, null, null, null)
	return C.LightMatrix()

proc/EnergyFXHoldTable(datum/energyfx_row/R)
	if(R && R.holds) return R.holds
	return list(ENERGYFX_HOLD_IGN_AT, ENERGYFX_HOLD_IGN, ENERGYFX_HOLD_PRE, ENERGYFX_HOLD_ONES, ENERGYFX_HOLD_PEAK, ENERGYFX_HOLD_REL_AT, ENERGYFX_HOLD_REL)

proc/EnergyFXHoldList(ign_f, contact_f, detect_f, release_f, list/table)
	if(!table) table = EnergyFXHoldTable()
	var/list/hl = list()
	if(!isnull(ign_f)) hl += list(list(ign_f + table[1], table[2]))
	if(!isnull(contact_f))
		var/hs = max(contact_f - table[3], isnull(detect_f) ? contact_f - table[3] : detect_f)
		if(hs < contact_f) hl += list(list(hs, contact_f - hs))
		hl += list(list(contact_f + table[4], table[5]))
	if(!isnull(release_f)) hl += list(list(release_f + table[6], table[7]))
	return hl

proc/EnergyFXDrawing(i, list/hl, contact_f, list/table)
	if(!table) table = EnergyFXHoldTable()
	var/v = i - BeamFXMod(i, 2)
	if(!isnull(contact_f) && i >= contact_f && i < contact_f + table[4]) v = i
	for(var/list/h in hl)
		if(i >= h[1] && i < h[1] + h[2]) v = h[1]
	return v

proc/EnergyFXStepKey(atom/A, matrix/M, alpha, color, dur, started)
	if(!started) animate(A, transform = M, alpha = alpha, color = color, time = dur, easing = ENERGYFX_STEP_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
	else animate(transform = M, alpha = alpha, color = color, time = dur, easing = ENERGYFX_STEP_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
	energyfx_anim_n++

#define ENERGYFX_TL_NEW 1
#define ENERGYFX_TL_T 2
#define ENERGYFX_TL_A 4
#define ENERGYFX_TL_C 8
#define ENERGYFX_TL_S 16

proc/EnergyFXTlKey(atom/A, matrix/M, alpha, color, st, dur, delay, fl)
	if(fl & ENERGYFX_TL_NEW)
		if(fl & ENERGYFX_TL_T) animate(A, transform = M, alpha = alpha, color = color, icon_state = st, time = dur, delay = delay, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		else animate(A, alpha = alpha, time = dur, delay = delay, easing = JUMP_EASING | EASE_IN)
	else
		switch(fl & 30)
			if(2) animate(transform = M, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			if(4) animate(alpha = alpha, time = dur, easing = JUMP_EASING | EASE_IN)
			if(6) animate(transform = M, alpha = alpha, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			if(8) animate(color = color, time = dur, easing = JUMP_EASING | EASE_IN)
			if(10) animate(transform = M, color = color, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			if(12) animate(alpha = alpha, color = color, time = dur, easing = JUMP_EASING | EASE_IN)
			if(14) animate(transform = M, alpha = alpha, color = color, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			if(16) animate(icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN)
			if(18) animate(transform = M, icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			if(20) animate(alpha = alpha, icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN)
			if(22) animate(transform = M, alpha = alpha, icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			if(24) animate(color = color, icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN)
			if(26) animate(transform = M, color = color, icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			if(28) animate(alpha = alpha, color = color, icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN)
			else animate(transform = M, alpha = alpha, color = color, icon_state = st, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
	energyfx_tl_key_n++

proc/EnergyFXStepChain(atom/A, list/frames, first_f, from_f, list/hl, contact_f, list/table)
	var/last_f = first_f + frames.len - 1
	var/i = from_f
	var/curv = -1000000
	var/dur = 0
	var/list/cur
	var/started = 0
	while(i - from_f < 400)
		var/v = EnergyFXDrawing(i, hl, contact_f, table)
		if(v > last_f) break
		if(v != curv)
			if(dur > 0)
				if(cur) EnergyFXStepKey(A, cur[1], cur[2], cur[3], dur, started)
				else EnergyFXStepKey(A, A.transform, 0, A.color, dur, started)
				started = 1
			curv = v
			cur = (v >= first_f) ? frames[v - first_f + 1] : null
			dur = 0
		dur += ENERGYFX_FRAME_DS
		i++
	if(dur > 0)
		if(cur) EnergyFXStepKey(A, cur[1], cur[2], cur[3], dur, started)
		else EnergyFXStepKey(A, A.transform, 0, A.color, dur, started)
		started = 1
	if(started) animate(alpha = 0, time = ENERGYFX_FRAME_DS, easing = ENERGYFX_STEP_EASING)
	return i - from_f

/datum/energyfx_look
	proc/Owns(obj/Skills/Projectile/_Projectile/P)
		return 0
	proc/Spawn(obj/Skills/Projectile/_Projectile/P)
		return 0
	proc/Charge(obj/Skills/Projectile/_Projectile/P, T)
		return 0
	proc/Launch(obj/Skills/Projectile/_Projectile/P)
		return 0
	proc/Tick(obj/Skills/Projectile/_Projectile/P)
		return 0
	proc/Hit(obj/Skills/Projectile/_Projectile/P, atom/target)
		return 0
	proc/Fuse(obj/Skills/Projectile/_Projectile/P, atom/target)
		return 0
	proc/Clash(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/_Projectile/other)
		return 0
	proc/CounterDied(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/_Projectile/counter)
		return 0
	proc/Finish(obj/Skills/Projectile/_Projectile/P)
		return 0
	proc/Burst(turf/T, radius, datum/energyfx_row/row, datum/energyfx_colors/C)
		return 0

var/datum/energyfx_look/energyfx_burst_look
var/list/ENERGYFX_FINISH_DRAWN = list()

proc/EnergyFXLookOf(obj/Skills/Projectile/_Projectile/P)
	if(!P) return null
	var/datum/energyfx_row/R = EnergyFXRowOf(P.SkillPath)
	return R ? R.handler : null

proc/EnergyFXProjectileOwned(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Owns(P) : 0

proc/EnergyFXProjectileSpawn(obj/Skills/Projectile/_Projectile/P)
	if(!glob || !glob.ENERGYFX) return 0
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Spawn(P) : 0

proc/EnergyFXProjectileCharge(obj/Skills/Projectile/_Projectile/P, T)
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Charge(P, T) : 0

proc/EnergyFXProjectileLaunch(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Launch(P) : 0

proc/EnergyFXProjectileTick(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Tick(P) : 0

proc/EnergyFXProjectileHit(obj/Skills/Projectile/_Projectile/P, atom/target)
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Hit(P, target) : 0

proc/EnergyFXProjectileFuse(obj/Skills/Projectile/_Projectile/P, atom/target)
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Fuse(P, target) : 0

proc/EnergyFXProjectileClash(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/_Projectile/other)
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	if(L) L.Clash(P, other)
	var/datum/energyfx_look/O = EnergyFXLookOf(other)
	if(O) O.Clash(other, P)
	return 0

proc/EnergyFXProjectileDiedAgainst(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/_Projectile/other)
	var/datum/energyfx_look/O = EnergyFXLookOf(other)
	return O ? O.CounterDied(other, P) : 0

proc/EnergyFXProjectileFinish(obj/Skills/Projectile/_Projectile/P)
	if(!P) return 0
	if(ENERGYFX_FINISH_DRAWN[P])
		ENERGYFX_FINISH_DRAWN -= P
		return 1
	var/datum/energyfx_look/L = EnergyFXLookOf(P)
	return L ? L.Finish(P) : 0

proc/EnergyFXAutoHitCast(obj/AutoHitter/A, obj/Skills/Z)
	if(!EnergyFXRow(Z)) return 0
	return 0

proc/EnergyFXAutoHitWindup(mob/M, obj/Skills/Z)
	if(!EnergyFXRow(Z)) return 0
	return 0

proc/EnergyFXAutoHitErupt(obj/AutoHitter/A, obj/Skills/Z, turf/T, size)
	if(!EnergyFXRow(Z)) return 0
	return 0

proc/EnergyFXHitSpark(mob/m, obj/Skills/Z, atom/target)
	if(!EnergyFXRow(Z)) return 0
	return 0

proc/EnergyFXGrappleBurst(mob/M, obj/Skills/Z, atom/target)
	if(!EnergyFXRow(Z)) return 0
	return 0

proc/EnergyFXVeilM1()
	var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : 2
	var/k = ls / ENERGYFX_GRAY_LSCALE
	var/i1 = k / (ENERGYFX_VEIL_HI1 - ENERGYFX_VEIL_LO1)
	var/i2 = k / (ENERGYFX_VEIL_HI2 - ENERGYFX_VEIL_LO2)
	var/i3 = k / (ENERGYFX_VEIL_HI3 - ENERGYFX_VEIL_LO3)
	var/c1 = -ENERGYFX_VEIL_LO1 / (ENERGYFX_VEIL_HI1 - ENERGYFX_VEIL_LO1)
	var/c2 = -ENERGYFX_VEIL_LO2 / (ENERGYFX_VEIL_HI2 - ENERGYFX_VEIL_LO2)
	var/c3 = -ENERGYFX_VEIL_LO3 / (ENERGYFX_VEIL_HI3 - ENERGYFX_VEIL_LO3)
	return list(0.2126 * i1, 0.2126 * i2, 0.2126 * i3, 0, 0.7152 * i1, 0.7152 * i2, 0.7152 * i3, 0, 0.0722 * i1, 0.0722 * i2, 0.0722 * i3, 0, 0, 0, 0, 0, c1, c2, c3, 1)

proc/EnergyFXVeilM2()
	return list(0, 0, 0, ENERGYFX_VEIL_W1, 0, 0, 0, ENERGYFX_VEIL_W2, 0, 0, 0, ENERGYFX_VEIL_W3, 0, 0, 0, 0, ENERGYFX_VEIL_GRAY, ENERGYFX_VEIL_GRAY, ENERGYFX_VEIL_GRAY, ENERGYFX_VEIL_C)

proc/EnergyFXCovM1()
	var/i1 = 1 / (ENERGYFX_COV_HI1 - ENERGYFX_COV_LO1)
	var/i2 = 1 / (ENERGYFX_COV_HI2 - ENERGYFX_COV_LO2)
	var/i3 = 1 / (ENERGYFX_COV_HI3 - ENERGYFX_COV_LO3)
	return list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, i1, i2, i3, 0, -ENERGYFX_COV_LO1 * i1, -ENERGYFX_COV_LO2 * i2, -ENERGYFX_COV_LO3 * i3, 1)

proc/EnergyFXCovM2()
	return list(0, 0, 0, ENERGYFX_COV_W1, 0, 0, 0, ENERGYFX_COV_W2, 0, 0, 0, ENERGYFX_COV_W3, 0, 0, 0, 0, 0, 0, 0, ENERGYFX_COV_C)

proc/EnergyFXKneeM()
	var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : 2
	return list(ls, 0, 0, 0, 0, ls, 0, 0, 0, 0, ls, 0, 0, 0, 0, 1, -ENERGYFX_GRAY_KNEE, -ENERGYFX_GRAY_KNEE, -ENERGYFX_GRAY_KNEE, 0)

/obj/energyfx_master/glight
	plane = ENERGYFX_GLIGHT_PLANE
	render_target = "*energyfx_glight"
	New()
		..()
		filters = filter(type = "blur", size = glob ? glob.ENERGYFX_BLUR : 1.5)

/obj/energyfx_master/damp
	plane = ENERGYFX_DAMP_PLANE
	render_target = "*energyfx_damp"
	New()
		..()
		filters = list(filter(type = "alpha", render_source = "*energyfx_occ", flags = MASK_INVERSE), filter(type = "blur", size = ENERGYFX_DAMP_BLUR), filter(type = "color", color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ENERGYFX_GRAY_DAMP, 0, 0, 0, 0)))

/obj/energyfx_master/cov
	plane = ENERGYFX_COV_PLANE
	render_target = "*energyfx_cov"
	New()
		..()
		filters = list(filter(type = "alpha", render_source = "*energyfx_occ", flags = MASK_INVERSE), filter(type = "blur", size = ENERGYFX_COV_BLUR), filter(type = "color", color = EnergyFXCovM1()), filter(type = "color", color = EnergyFXCovM2()))

/obj/energyfx_master/gring
	plane = ENERGYFX_GRING_PLANE
	render_target = "*energyfx_gring"
	New()
		..()
		filters = filter(type = "blur", size = ENERGYFX_GRING_BLUR)

/obj/energyfx_relay/covsrc
	plane = ENERGYFX_COV_PLANE
	layer = 1
	render_source = "*energyfx_paint"

/obj/energyfx_relay/veil
	layer = ENERGYFX_VEIL_RELAY_LAYER
	render_source = "*energyfx_glight"
	New()
		..()
		filters = list(filter(type = "color", color = EnergyFXVeilM1()), filter(type = "color", color = EnergyFXVeilM2()), filter(type = "alpha", render_source = "*energyfx_cov", flags = MASK_INVERSE), filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE))

/obj/energyfx_relay/glight
	layer = ENERGYFX_GLIGHT_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_glight"
	New()
		..()
		filters = list(filter(type = "layer", render_source = "*energyfx_damp", blend_mode = BLEND_MULTIPLY), filter(type = "color", color = EnergyFXKneeM()), filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE))

/obj/energyfx_relay/gring
	layer = ENERGYFX_GRING_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*energyfx_gring"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE)

client/var/tmp/list/energyfx_gray_screen

client/ApplyWorldMag()
	..()
	EnergyFXEnsureMasters(src)
	EnergyFXEnsureGrayMasters(src)

proc/EnergyFXEnsureGrayMasters(client/C)
	if(!C) return
	if(!C.energyfx_gray_screen)
		C.energyfx_gray_screen = list(new /obj/energyfx_master/glight, new /obj/energyfx_master/damp, new /obj/energyfx_master/cov, new /obj/energyfx_master/gring, new /obj/energyfx_relay/covsrc, new /obj/energyfx_relay/veil, new /obj/energyfx_relay/glight, new /obj/energyfx_relay/gring)
	for(var/obj/O in C.energyfx_gray_screen)
		if(!(O in C.screen)) C.screen += O
