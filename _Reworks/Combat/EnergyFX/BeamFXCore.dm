globalTracker/var/tmp
	BEAMFX = TRUE
	BEAMFX_CAP = 3200
	BEAMFX_BLUR = 1.5
	BEAMFX_LIGHT_SCALE = 2
	BEAMFX_LOG = FALSE

var/list/BEAMFX_TYPES = list(\
	/obj/Skills/Projectile/Beams/Eraser_Gun,\
	/obj/Skills/Projectile/Beams/Shine_Ray,\
	/obj/Skills/Projectile/Beams/Shine_Ray_Prism,\
	/obj/Skills/Projectile/Beams/Gamma_Ray,\
	/obj/Skills/Projectile/Beams/Piercer_Ray,\
	/obj/Skills/Projectile/Beams/Kamehameha,\
	/obj/Skills/Projectile/Beams/Motionless_Kamehameha,\
	/obj/Skills/Projectile/Beams/Galic_Gun,\
	/obj/Skills/Projectile/Beams/Final_Crash,\
	/obj/Skills/Projectile/Beams/Dodompa,\
	/obj/Skills/Projectile/Beams/Killer_Shine,\
	/obj/Skills/Projectile/Beams/Big/Super_Kamehameha,\
	/obj/Skills/Projectile/Beams/Big/Final_Flash,\
	/obj/Skills/Projectile/Beams/Big/Super_Dodompa,\
	/obj/Skills/Projectile/Beams/Big/True_Kamehameha,\
	/obj/Skills/Projectile/Beams/Big/Final_Shine)

var/list/BEAMFX_DIRS = list("E", "NE", "N", "NW", "W", "SW", "S", "SE")
var/list/BEAMFX_POOL = list()
var/list/BEAMFX_DUE
var/beamfx_live = 0
var/beamfx_pending = 0
var/beamfx_loop = 0
var/beamfx_seed = 0
var/beamfx_anim_n = 0
var/beamfx_cost = 0
var/beamfx_cost_n = 0

obj/Skills/var
	fx_main_color
	fx_core_color
	fx_glow_color

/mob/Admin2/verb/Beam_FX_Stats()
	set category = "Admin"
	set name = "Beam FX Stats"
	var/a0 = beamfx_anim_n
	var/c0 = beamfx_cost
	var/n0 = beamfx_cost_n
	src << "Beam FX stats: sampling 5 seconds..."
	sleep(50)
	var/steps = beamfx_cost_n - n0
	var/ms = steps ? (beamfx_cost - c0) * world.tick_lag / steps : 0
	src << "Beam FX: [beamfx_live] live objects, [round((beamfx_anim_n - a0) / 5, 1)] animation steps per second, [steps] beam updates, [round(ms, 0.01)] ms per beam update."

/mob/Admin2/verb/Beam_FX_Toggle()
	set category = "Admin"
	set name = "Beam FX Toggle"
	glob.BEAMFX = !glob.BEAMFX
	src << "Beam FX renderer: [glob.BEAMFX ? "ON" : "OFF"] (new beams only)."
	Log("Admin", "[ExtractInfo(src)] set the beam FX renderer to [glob.BEAMFX].")

proc/BeamFXEligible(obj/Skills/Projectile/Z)
	if(!Z || !glob || !glob.BEAMFX || !BEAMFX_ASSETS) return 0
	return (Z.type in BEAMFX_TYPES) ? 1 : 0

/obj/beamfx
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

/obj/beamfx/paint
	plane = BEAMFX_PAINT_PLANE

/obj/beamfx/light
	plane = BEAMFX_LIGHT_PLANE
	blend_mode = BLEND_ADD

/obj/beamfx/emit
	icon = null
	plane = BEAMFX_PAINT_PLANE
	layer = 5.5

/particles/beamfx_speck
	width = 384
	height = 384
	count = 900
	spawning = 0
	lifespan = generator("num", 2, 5.2)
	fade = 1.2
	fadein = 1
	position = generator("box", vector(-18, -14, 0), vector(-6, 14, 0))
	velocity = generator("circle", 5.9, 42.1)
	friction = 0.32
	grow = list(-0.15, -0.15)
	bound2 = vector(4, 1000, 1000)

/obj/beamfx_master
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER

/obj/beamfx_master/paint
	plane = BEAMFX_PAINT_PLANE
	render_target = "*beamfx_paint"

/obj/beamfx_master/light
	plane = BEAMFX_LIGHT_PLANE
	render_target = "*beamfx_light"
	New()
		..()
		BeamFXLightFilters(src)

/obj/beamfx_master/occ
	plane = BEAMFX_OCC_PLANE
	render_target = "*beamfx_occ"

/obj/beamfx_master/locc
	plane = BEAMFX_LOCC_PLANE
	render_target = "*beamfx_locc"

/obj/beamfx_master/hide
	plane = BEAMFX_HIDE_PLANE
	render_target = "*beamfx_hide"

/obj/beamfx_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	mouse_opacity = 0

/obj/beamfx_relay/paint
	layer = BEAMFX_PAINT_RELAY_LAYER
	render_source = "*beamfx_paint"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*beamfx_occ", flags = MASK_INVERSE)

/obj/beamfx_relay/light
	layer = BEAMFX_LIGHT_RELAY_LAYER
	blend_mode = BLEND_ADD
	render_source = "*beamfx_light"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*beamfx_locc", flags = MASK_INVERSE)
		BeamFXLightRelayColor(src)

proc/BeamFXLightFilters(obj/beamfx_master/light/M)
	if(!M) return
	var/b = glob ? glob.BEAMFX_BLUR : 1.5
	M.filters = (b > 0) ? filter(type = "blur", size = b) : null

proc/BeamFXLightRelayColor(obj/O)
	var/k = glob ? glob.BEAMFX_LIGHT_SCALE : 1
	O.color = (k == 1) ? null : list(k, 0, 0, 0, k, 0, 0, 0, k)

client/var/tmp/list/beamfx_screen

client/ApplyWorldMag()
	..()
	BeamFXEnsureMasters(src)

proc/BeamFXEnsureMasters(client/C)
	if(!C) return
	if(!C.beamfx_screen)
		C.beamfx_screen = list(new /obj/beamfx_master/paint, new /obj/beamfx_master/light, new /obj/beamfx_master/occ, new /obj/beamfx_master/locc, new /obj/beamfx_master/hide, new /obj/beamfx_master/rimw, new /obj/beamfx_master/rima, new /obj/beamfx_relay/paint, new /obj/beamfx_relay/light, new /obj/beamfx_relay/rimw, new /obj/beamfx_relay/rima)
	for(var/obj/O in C.beamfx_screen)
		if(!(O in C.screen)) C.screen += O

proc/BeamFXNow()
	return round(world.time / world.tick_lag, 1)

proc/BeamFXGet(path)
	if(!glob || beamfx_live >= glob.BEAMFX_CAP) return null
	var/obj/beamfx/O
	var/list/P = BEAMFX_POOL[path]
	if(P && P.len)
		O = P[1]
		if(O.fx_free <= BeamFXNow() - 2)
			P.Cut(1, 2)
		else
			O = null
	if(!O) O = new path
	beamfx_live++
	return O

proc/BeamFXFree(obj/beamfx/O)
	if(!O) return
	animate(O)
	O.loc = null
	O.transform = null
	O.color = null
	O.alpha = 255
	if(O.particles) O.particles = null
	if(O.overlays.len) O.overlays.Cut()
	O.fx_free = BeamFXNow()
	O.fx_due = 0
	beamfx_live = max(0, beamfx_live - 1)
	var/list/P = BEAMFX_POOL[O.type]
	if(!P)
		P = list()
		BEAMFX_POOL[O.type] = P
	if(P.len < 1500) P += O

proc/BeamFXDue(obj/beamfx/O, ticks)
	if(!BEAMFX_DUE)
		BEAMFX_DUE = new /list(BEAMFX_RING)
		for(var/i = 1 to BEAMFX_RING)
			BEAMFX_DUE[i] = list()
	O.fx_due = BeamFXNow() + max(1, round(ticks, 1))
	var/list/B = BEAMFX_DUE[(O.fx_due % BEAMFX_RING) + 1]
	B += O
	beamfx_pending++
	if(!beamfx_loop) BeamFXDueLoop()

proc/BeamFXDueLoop()
	set waitfor = 0
	if(beamfx_loop) return
	beamfx_loop = 1
	var/last = BeamFXNow()
	while(beamfx_pending > 0)
		sleep(world.tick_lag)
		var/now = BeamFXNow()
		if(now - last > BEAMFX_RING) last = now - BEAMFX_RING
		for(var/t = last + 1, t <= now, t++)
			var/list/B = BEAMFX_DUE[(t % BEAMFX_RING) + 1]
			if(!B.len) continue
			var/n = B.len
			for(var/obj/beamfx/O in B)
				if(O.fx_due && O.fx_due <= t) BeamFXFree(O)
			B.Cut()
			beamfx_pending = max(0, beamfx_pending - n)
		last = now
	beamfx_loop = 0

proc/BeamFXSstep(e0, e1, x)
	var/t = clamp((x - e0) / (e1 - e0), 0, 1)
	return t * t * (3 - 2 * t)

proc/BeamFXEaseOut(q)
	q = clamp(q, 0, 1)
	return 1 - (1 - q) * (1 - q)

proc/BeamFXMod(a, b)
	return a - b * floor(a / b)

/datum/bfx_rng
	var/s1 = 1
	var/s2 = 1
	var/s3 = 1

/datum/bfx_rng/New(seed)
	var/s = round(seed, 1) % 30000
	if(s < 0) s += 30000
	s1 = 1 + (s * 7 + 13) % 30268
	s2 = 1 + (s * 11 + 17) % 30306
	s3 = 1 + (s * 13 + 19) % 30322

/datum/bfx_rng/proc/R()
	s1 = (171 * s1) % 30269
	s2 = (172 * s2) % 30307
	s3 = (170 * s3) % 30323
	return ((s1 + s2 + s3) % 30269) / 30269

/datum/bfx_rng/proc/U(a, b)
	return a + (b - a) * R()

/datum/bfx_rng/proc/RandInt(a, b)
	return a + floor(R() * (b - a + 1))

/datum/bfx_rng/proc/RandRange(n)
	return floor(R() * n)

/datum/bfx_rng/proc/Gauss(mu, sigma)
	var/u1 = max(0.000001, R())
	var/u2 = R()
	return mu + sigma * sqrt(-2 * log(u1)) * cos(360 * u2)

proc/BeamFXHexRGB(col)
	if(!col || !istext(col) || length(col) < 7) return null
	return list(text2num(copytext(col, 2, 4), 16), text2num(copytext(col, 4, 6), 16), text2num(copytext(col, 6, 8), 16))

proc/BeamFXRGB2HSV(r, g, b)
	var/maxc = max(r, g, b)
	var/minc = min(r, g, b)
	if(minc == maxc) return list(0, 0, maxc)
	var/s = (maxc - minc) / maxc
	var/rc = (maxc - r) / (maxc - minc)
	var/gc = (maxc - g) / (maxc - minc)
	var/bc = (maxc - b) / (maxc - minc)
	var/h
	if(r == maxc) h = bc - gc
	else if(g == maxc) h = 2 + rc - bc
	else h = 4 + gc - rc
	h = BeamFXMod(h / 6, 1)
	return list(h, s, maxc)

proc/BeamFXHSV2RGB(h, s, v)
	if(s == 0) return list(v, v, v)
	var/i = floor(h * 6)
	var/f = h * 6 - i
	var/p = v * (1 - s)
	var/q = v * (1 - s * f)
	var/t = v * (1 - s * (1 - f))
	i = BeamFXMod(i, 6)
	switch(i)
		if(0) return list(v, t, p)
		if(1) return list(q, v, p)
		if(2) return list(p, v, t)
		if(3) return list(p, q, v)
		if(4) return list(t, p, v)
	return list(v, p, q)

proc/BeamFXWarmEdge(list/c)
	var/list/hsv = BeamFXRGB2HSV(c[1], c[2], c[3])
	var/hd = hsv[1] * 360
	var/sat = hsv[2]
	var/val = hsv[3]
	if(hd >= 20 && hd <= 100)
		hd = hd - 0.55 * (hd - 36)
		sat = min(1, sat * 1.05)
		val = val * 0.86
	else if(hd >= 250 && hd <= 300)
		hd = hd - 0.4 * (hd - 268)
	return BeamFXHSV2RGB(hd / 360, sat, val)

proc/BeamFXLum(list/c)
	return 0.2126 * c[1] + 0.7152 * c[2] + 0.0722 * c[3]

proc/BeamFXRamp(list/C255, list/core255, list/glow255)
	var/list/c = list(C255[1] / 255, C255[2] / 255, C255[3] / 255)
	var/list/b = BeamFXWarmEdge(c)
	var/kb = clamp((BeamFXLum(b) - 0.3) / 0.3, 0, 1)
	kb = kb * kb * (3 - 2 * kb)
	var/list/edge = list(0, 0, 0)
	var/list/core = list(0, 0, 0)
	var/list/lc = list(0, 0, 0)
	var/list/lcore = list(0, 0, 0)
	for(var/i = 1 to 3)
		var/e = clamp(b[i] * (1 - 0.18 * kb), 0, 1)
		edge[i] = e + (1 - e) * 0.12 * (1 - kb)
		core[i] = c[i] + (1 - c[i]) * 0.9
		lc[i] = b[i]
		lcore[i] = c[i] + (1 - c[i]) * 0.9
	if(core255)
		for(var/i = 1 to 3)
			core[i] = core255[i] / 255
			lcore[i] = core[i]
	if(glow255)
		for(var/i = 1 to 3)
			lc[i] = glow255[i] / 255
	return list(lc, edge, core, lcore)
