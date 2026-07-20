//occluded lighting

#define LIGHT_OVERLAY_LAYER 6.55 //above the day/night blanket (6.5), below weather/HUD

turf/var/blocks_light = 0 //occluder flag for walls that aren't the 'Walls.dmi' tree

turf/MidgarTiles
	MidgarWall1/blocks_light = 1
	MidgarWall2/blocks_light = 1
	MidgarWall3/blocks_light = 1
	MidgarWall4/blocks_light = 1
	Midgarwall5/blocks_light = 1
	MidgarLightWall1/blocks_light = 1
	MidgarLightWall2/blocks_light = 1
	MidgarLightWall3/blocks_light = 1
turf/Special/Midgar_IchorWall/blocks_light = 1

globalTracker
	var/tmp
		LIGHTING = FALSE //master switch
		LIGHT_DEFAULT_RADIUS = 6
		LIGHT_DEFAULT_COLOR = "#ffcf9e" //warm torch
		LIGHT_MAX_ALPHA = 170 //additive strength at the source
		LIGHT_DAY_STRENGTH = 0.10 //present but deliberately subtle under full daylight
		LIGHT_BLUR = 10 //blur size on the lighting plane master - smooths the per-tile grid
		FLICKER_MIN = 95 //flame-glow alpha low (waver floor)
		FLICKER_MAX = 195 //flame-glow alpha high (waver ceiling)
		//occluded blast lights: big/slow blasts cast a wall-blocked light while flying, capped + throttled
		OCCLUDED_BLASTS = TRUE //feature switch (only meaningful when LIGHTING is on)
		OCCLUDED_BLAST_MAX = 4 //hard global cap on simultaneous occluded footprints
		OCCLUDED_BLAST_RADIUS = 4 //footprint radius in tiles (smaller = cheaper)
		OCCLUDED_BLAST_INTERVAL = 2 //min ticks between repaints of one footprint

var/list/_light_sources = list()
var/list/_light_buckets = list()
var/_light_fov_builds = 0
var/_light_fov_cells = 0

#define LIGHT_BUCKET_SIZE 8

//a light source: either a fixed world point (lx/ly/lz) or tied to a prop (src_obj, follows it)
/datum/lightsource
	var/lx
	var/ly
	var/lz
	var/atom/movable/src_obj //if set, the light lives at this prop's turf (torch/campfire/lamp)
	var/radius = 6
	var/lcolor = "#ffcf9e"
	var/maxalpha = 170
	var/list/applied //turf -> the additive overlay image we put on it
	var/list/reflection_applied //reflective turf -> pooled-looking glint image on reflection plane
	var/list/visible_turfs //cached occlusion geometry; dusk/dawn repaints do not raycast again
	var/geometry_key
	var/bucket_key
	var/painted_dark = -1 //LightDarkFrac at last paint; the loop re-tints on material change
	var/last_recompute = 0 //world.time of last wall-change recompute (burst dedup)
	var/flicker = 0 //flame prop: carry a wavering flame glow at the source
	var/obj/flamelight/flame //the flame glow obj

//daylight floor keeps lamps from switching off; smoothstep grows them into dusk
proc/LightRenderStrength(turf/T)
	var/dark = clamp(LightDarkFrac(T), 0, 1)
	var/eased = dark * dark * (3 - 2 * dark)
	var/floor = glob ? clamp(glob.LIGHT_DAY_STRENGTH, 0, 0.35) : 0.10
	return floor + (1 - floor) * eased

proc/LightSrcTurf(datum/lightsource/L)
	if(!L) return null
	return L.src_obj ? get_turf(L.src_obj) : locate(L.lx, L.ly, L.lz)

proc/LightBucketKey(turf/T)
	if(!T) return null
	return "[T.z]:[floor((T.x - 1) / LIGHT_BUCKET_SIZE)]:[floor((T.y - 1) / LIGHT_BUCKET_SIZE)]"

proc/LightBucketUnregister(datum/lightsource/L)
	if(!L || !L.bucket_key) return
	var/list/B = _light_buckets[L.bucket_key]
	if(B)
		B -= L
		if(!B.len) _light_buckets -= L.bucket_key
	L.bucket_key = null

proc/LightBucketRegister(datum/lightsource/L)
	if(!L) return
	var/key = LightBucketKey(LightSrcTurf(L))
	if(key == L.bucket_key) return
	LightBucketUnregister(L)
	if(!key) return
	var/list/B = _light_buckets[key]
	if(!B)
		B = list()
		_light_buckets[key] = B
	B |= L
	L.bucket_key = key

proc/LightsNearTurf(turf/T, radius = 24)
	var/list/out = list()
	if(!T) return out
	var/bx = floor((T.x - 1) / LIGHT_BUCKET_SIZE)
	var/by = floor((T.y - 1) / LIGHT_BUCKET_SIZE)
	var/br = ceil(max(1, radius) / LIGHT_BUCKET_SIZE) + 1
	for(var/ix = bx - br, ix <= bx + br, ix++)
		for(var/iy = by - br, iy <= by + br, iy++)
			var/list/B = _light_buckets["[T.z]:[ix]:[iy]"]
			if(B) out |= B
	return out

//occluder = engine opacity, blocks_light, or the wall tree by icon - bare density also covers water/ore
proc/IsLightOccluder(turf/T)
	if(!T) return 1
	if(T.opacity) return 1
	if(T.blocks_light) return 1
	if(T.density && T.icon == 'Walls.dmi') return 1
	return 0

//clear line of light from A to B; sealed diagonal corners block the ray
proc/LightClearLine(turf/A, turf/B)
	if(!A || !B || A.z != B.z) return 0
	var/x0 = A.x
	var/y0 = A.y
	var/x1 = B.x
	var/y1 = B.y
	var/z = A.z
	var/dx = abs(x1 - x0)
	var/dy = abs(y1 - y0)
	var/sx = (x0 < x1) ? 1 : -1
	var/sy = (y0 < y1) ? 1 : -1
	var/err = dx - dy
	var/cx = x0
	var/cy = y0
	var/guard = 0
	while(guard++ < 512)
		var/e2 = 2 * err
		var/stepx = 0
		var/stepy = 0
		if(e2 > -dy)
			err -= dy
			stepx = sx
		if(e2 < dx)
			err += dx
			stepy = sy
		if(stepx && stepy) //diagonal move: a sealed corner blocks the ray
			if(IsLightOccluder(locate(cx + stepx, cy, z)) && IsLightOccluder(locate(cx, cy + stepy, z)))
				return 0
		cx += stepx
		cy += stepy
		if(cx == x1 && cy == y1)
			return 1 //reached the target; its own turf isn't tested as a blocker
		if(IsLightOccluder(locate(cx, cy, z)))
			return 0
	return 1

proc/LightInvalidateGeometry(datum/lightsource/L)
	if(!L) return
	L.visible_turfs = null
	L.geometry_key = null

//recursive octant shadowcasting - each cell visited once; dusk/dawn re-tints reuse the cached visible set
proc/_LightCastOctant(turf/s, radius, row, start_slope, end_slope, xx, xy, yx, yy, list/visible)
	if(!s || start_slope < end_slope) return
	var/new_start = start_slope
	for(var/distance = row, distance <= radius, distance++)
		var/blocked = FALSE
		var/dy = -distance
		for(var/dx = -distance, dx <= 0, dx++)
			var/map_x = s.x + dx * xx + dy * xy
			var/map_y = s.y + dx * yx + dy * yy
			var/left_slope = (dx - 0.5) / (dy + 0.5)
			var/right_slope = (dx + 0.5) / (dy - 0.5)
			if(start_slope < right_slope) continue
			if(end_slope > left_slope) break
			var/turf/T = locate(map_x, map_y, s.z)
			if(T && dx*dx + dy*dy <= radius*radius) visible[T] = 1
			var/opaque = IsLightOccluder(T)
			if(blocked)
				if(opaque)
					new_start = right_slope
				else
					blocked = FALSE
					start_slope = new_start
			else if(opaque && distance < radius)
				blocked = TRUE
				_LightCastOctant(s, radius, distance + 1, start_slope, left_slope, xx, xy, yx, yy, visible)
				new_start = right_slope
		if(blocked) break

proc/LightBuildVisibility(datum/lightsource/L, turf/s)
	if(!L || !s) return null
	var/key = "[s.x],[s.y],[s.z],[L.radius]"
	if(L.visible_turfs && L.geometry_key == key) return L.visible_turfs
	var/list/visible = list()
	visible[s] = 1
	L.geometry_key = key
	for(var/list/O in list(
		list(1,0,0,1), list(0,1,1,0), list(0,-1,1,0), list(-1,0,0,1),
		list(-1,0,0,-1), list(0,-1,-1,0), list(0,1,-1,0), list(1,0,0,-1)))
		_LightCastOctant(s, L.radius, 1, 1, 0, O[1], O[2], O[3], O[4], visible)
	L.visible_turfs = list()
	for(var/turf/T in visible) L.visible_turfs += T
	_light_fov_builds++
	_light_fov_cells += L.visible_turfs.len
	return L.visible_turfs

proc/GfxPaintLightReflections(datum/lightsource/L, list/visible, turf/s, light_strength)
	if(!L || !visible || !s || light_strength < 0.06) return
	_GfxDepthBuildIcons()
	L.reflection_applied = list()
	var/cap = max(12, round(56 * GfxBudgetScale()))
	for(var/turf/T in visible)
		var/surface = GfxTurfReflectionStrength(T)
		if(surface <= 0.1) continue
		//rain-wet ground gets a sparse checker; real water stays continuous
		if(!GfxIsPermanentReflectiveSurface(T) && (T.x + T.y) % 2) continue
		var/ddx = T.x - s.x
		var/ddy = T.y - s.y
		var/d = sqrt(ddx*ddx + ddy*ddy)
		var/falloff = 1 - d / (L.radius + 0.5)
		if(falloff <= 0) continue
		var/a = round(L.maxalpha * falloff * falloff * light_strength * surface * 0.48)
		if(a < 3) continue
		var/image/I = image(_gfx_light_reflection_icon, T)
		I.plane = REFLECTION_PLANE
		I.layer = 1.2
		I.blend_mode = BLEND_ADD
		I.color = L.lcolor
		I.alpha = a
		I.pixel_x = 7 + clamp((s.x - T.x) * 2, -9, 9)
		I.pixel_y = 1 + clamp((s.y - T.y), -5, 5)
		I.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART
		T.overlays += I
		L.reflection_applied[T] = I
		if(--cap <= 0) break

//compute + paint a light's occluded footprint
proc/LightCompute(datum/lightsource/L)
	LightClear(L)
	if(!glob || !glob.LIGHTING || !L) return
	var/turf/s = LightSrcTurf(L)
	if(!s) return
	LightBucketRegister(L)
	var/darkFrac = LightDarkFrac(s) //true ambient darkness; retained for cheap repaint detection
	var/lightStrength = LightRenderStrength(s)
	L.painted_dark = darkFrac
	UpdateFlameGlow(L, lightStrength)
	L.applied = list()
	var/rr = L.radius
	var/list/visible = LightBuildVisibility(L, s)
	for(var/turf/T in visible)
		var/ddx = T.x - s.x
		var/ddy = T.y - s.y
		var/d = sqrt(ddx * ddx + ddy * ddy)
		var/falloff = 1 - (d / (rr + 0.5))
		falloff *= falloff //smooth edge
		var/a = round(L.maxalpha * falloff * lightStrength)
		if(a < 3) continue
		var/image/ov = image(EnvWhiteIcon(), T)
		ov.blend_mode = BLEND_ADD
		ov.color = L.lcolor
		ov.alpha = a
		ov.layer = LIGHT_OVERLAY_LAYER
		ov.plane = LIGHTING_PLANE //rendered + blurred by the lighting plane master, then relayed
		ov.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART
		T.overlays += ov
		L.applied[T] = ov
	GfxPaintLightReflections(L, visible, s, lightStrength)

proc/LightClear(datum/lightsource/L)
	if(L && L.applied)
		for(var/turf/T in L.applied)
			if(T) T.overlays -= L.applied[T]
		L.applied = null
	if(L && L.reflection_applied)
		for(var/turf/T in L.reflection_applied)
			if(T) T.overlays -= L.reflection_applied[T]
		L.reflection_applied = null

proc/LightingApplyAll()
	for(var/datum/lightsource/L in _light_sources)
		LightCompute(L)

//re-tint lights as dusk/dawn moves; clock jumps call LightingApplyAll directly
var/_light_boot = _LightBoot()
proc/_LightBoot()
	spawn(95)
		_LightLoop()
	return 1

proc/_LightLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.LIGHTING)
			for(var/datum/lightsource/L in _light_sources)
				var/turf/s = LightSrcTurf(L)
				if(!s) continue
				if(abs(LightDarkFrac(s) - L.painted_dark) > 0.02)
					LightCompute(L)
		sleep(10)

proc/LightingClearAll()
	for(var/datum/lightsource/L in _light_sources)
		LightClear(L)
		KillFlame(L) //lighting off: also stop + drop the flame glows

//place a light at a world point and paint it
proc/AddLightSource(turf/T, radius, lcolor, maxalpha)
	if(!T) return null
	var/datum/lightsource/L = new
	L.lx = T.x
	L.ly = T.y
	L.lz = T.z
	L.radius = clamp(radius || glob.LIGHT_DEFAULT_RADIUS, 1, 20) //cap: bound the range() scan + LOS length
	L.lcolor = lcolor || glob.LIGHT_DEFAULT_COLOR
	L.maxalpha = maxalpha || glob.LIGHT_MAX_ALPHA
	_light_sources += L
	LightBucketRegister(L)
	LightCompute(L)
	return L

proc/RemoveLightSource(datum/lightsource/L)
	if(!L) return
	LightClear(L)
	KillFlame(L)
	LightBucketUnregister(L)
	_light_sources -= L

obj/var/tmp/datum/lightsource/attached_light

proc/LightPropAttach(obj/O, radius, lcolor, maxalpha, flicker = 0)
	if(!O || O.attached_light) return
	if(!get_turf(O)) return //build-panel phantom (Add_Builds new()s every prop with no loc) - don't register a dead light
	PurgeStaleFlameVisuals(O) //old saves can carry baked-in flame visuals - scrub them
	var/datum/lightsource/L = new
	L.src_obj = O
	L.radius = clamp(radius || glob.LIGHT_DEFAULT_RADIUS, 1, 20)
	L.lcolor = lcolor || glob.LIGHT_DEFAULT_COLOR
	L.maxalpha = maxalpha || glob.LIGHT_MAX_ALPHA
	L.flicker = flicker
	_light_sources += L
	O.attached_light = L
	LightBucketRegister(L)
	LightCompute(L)

// flame flicker
/obj/flamelight
	plane = LIGHTING_PLANE
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	layer = 6.56
	gfx_transient_visual = 1
	var/tmp/active = 0
	var/tmp/dark = 1 //current ambient darkness - scales the flicker so it dims at dusk

proc/KillFlame(datum/lightsource/L) //drop refs, refcount-free (never del)
	if(!L || !L.flame) return
	L.flame.active = 0
	if(L.src_obj) L.src_obj.vis_contents -= L.flame
	L.flame.loc = null
	L.flame = null

proc/PurgeStaleFlameVisuals(atom/movable/O)
	if(!O) return
	var/list/stale = list()
	for(var/obj/flamelight/F in O.vis_contents)
		stale += F
	for(var/obj/flamelight/F in stale)
		F.active = 0
		O.vis_contents -= F
		F.loc = null

proc/UpdateFlameGlow(datum/lightsource/L, lightStrength)
	if(!L || !L.flicker) return
	var/atom/movable/O = L.src_obj
	if(!O) return
	if(lightStrength > 0)
		if(!L.flame)
			PurgeStaleFlameVisuals(O)
			if(!_fx_glow_icon) _FxBuildIcons()
			var/obj/flamelight/F = new
			F.icon = _fx_glow_icon //radial alpha stays soft even when a client's blur pass is disabled
			F.color = L.lcolor
			F.pixel_x = -16
			F.pixel_y = -16
			F.transform = matrix() * 0.9
			F.active = 1
			F.dark = lightStrength
			F.alpha = round((glob.FLICKER_MIN + glob.FLICKER_MAX) / 2 * lightStrength) //start at settled brightness, not default 255
			O.vis_contents += F
			L.flame = F
			FlameFlicker(F)
		else
			L.flame.dark = lightStrength //re-tint amplitude as the clock changes
	else
		KillFlame(L)

proc/FlameFlicker(obj/flamelight/F)
	set waitfor = 0
	set background = 1
	while(F && F.active)
		var/na = round(rand(glob.FLICKER_MIN, glob.FLICKER_MAX) * F.dark)
		animate(F, alpha = na, time = rand(2, 4))
		sleep(rand(2, 5))

proc/LightPropDetach(obj/O)
	if(!O || !O.attached_light) return
	RemoveLightSource(O.attached_light)
	O.attached_light = null

obj/Turfs/LightProp
	icon = 'Objects.dmi'
	icon_state = "Torch1"
	density = 1
	name = "Torch"
	var/lp_radius = 5
	var/lp_color = "#ffb060"
	var/lp_alpha = 170
	var/lp_flicker = 1 //flame props waver; steady lamps set 0
	New()
		. = ..()
		spawn(3) LightPropAttach(src, lp_radius, lp_color, lp_alpha, lp_flicker) //spawn: let loc settle after build/load
	Del()
		LightPropDetach(src)
		..()

	Campfire
		name = "Campfire"
		icon_state = "Fire"
		lp_radius = 7
		lp_color = "#ff8038"
		lp_alpha = 185
	Lamp
		name = "Lamp"
		icon_state = "Torch2"
		lp_radius = 6
		lp_color = "#fff0c0"
		lp_flicker = 0 //steady electric light
	BlueLamp
		name = "Blue Lamp"
		icon_state = "Torch2"
		lp_radius = 6
		lp_color = "#7fb0ff"
		lp_flicker = 0
	GreenLamp
		name = "Green Lamp"
		icon_state = "Torch2"
		lp_radius = 6
		lp_color = "#8fffb0"
		lp_flicker = 0

obj/Turfs
	Torch1/New()
		. = ..()
		spawn(3) LightPropAttach(src, 5, "#ffb060", 170, 1)
	Torch1/Del()
		LightPropDetach(src)
		..()
	Torch2/New()
		. = ..()
		spawn(3) LightPropAttach(src, 5, "#ffb060", 170, 1)
	Torch2/Del()
		LightPropDetach(src)
		..()
	Torch3/New()
		. = ..()
		spawn(3) LightPropAttach(src, 5, "#ffb060", 170, 1)
	Torch3/Del()
		LightPropDetach(src)
		..()
	Fire/New()
		. = ..()
		spawn(3) LightPropAttach(src, 7, "#ff8038", 185, 1)
	Fire/Del()
		LightPropDetach(src)
		..()

//a turf's occluder state changed (wall destroyed/built): recompute the lights it could touch
proc/LightingRecomputeNear(turf/T)
	GfxAOInvalidateNear(T)
	if(!glob || !glob.LIGHTING || !T) return
	for(var/datum/lightsource/L in LightsNearTurf(T, 22))
		if(L.last_recompute == world.time) continue //a burst of wall changes this tick recomputes each light at most once
		var/turf/s = LightSrcTurf(L)
		if(!s || s.z != T.z) continue
		if(abs(s.x - T.x) <= L.radius + 1 && abs(s.y - T.y) <= L.radius + 1)
			L.last_recompute = world.time
			LightInvalidateGeometry(L)
			LightCompute(L)

proc/LightingRefreshReflectionsForArea(area/A)
	if(!A || !glob || !glob.LIGHTING) return
	for(var/datum/lightsource/L in _light_sources)
		var/turf/s = LightSrcTurf(L)
		if(!s) continue
		var/touches = s.loc == A
		if(!touches && L.visible_turfs)
			for(var/turf/T in L.visible_turfs)
				if(T.loc == A)
					touches = TRUE
					break
		if(touches) LightCompute(L)

/mob/Admin2/verb/Lighting_Toggle()
	set category = "Admin"
	set name = "Lighting Toggle"
	glob.LIGHTING = !glob.LIGHTING
	if(glob.LIGHTING)
		LightingApplyAll()
	else
		LightingClearAll()
	for(var/client/C) //enable/disable the lighting-plane blur pass to match
		FxApplyLightBlur(C)
	src << "Dynamic lighting: [glob.LIGHTING ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set lighting to [glob.LIGHTING].")

/mob/Admin2/verb/Place_Light()
	set category = "Admin"
	set name = "Place Light"
	if(!glob.LIGHTING)
		src << "Lighting is OFF - toggle it on first (Lighting Toggle)."
		return
	var/r = input(src, "Light radius (tiles, 1-20)?") as num|null
	if(isnull(r)) return
	var/datum/lightsource/L = AddLightSource(get_turf(src), r, glob.LIGHT_DEFAULT_COLOR, glob.LIGHT_MAX_ALPHA)
	src << "Placed a light (radius [L ? L.radius : "?"]) at your feet."
	Log("Admin", "[ExtractInfo(src)] placed a light.")

/mob/Admin2/verb/Clear_Lights()
	set category = "Admin"
	set name = "Clear Lights"
	for(var/datum/lightsource/L in _light_sources.Copy())
		if(L.src_obj) continue //leave prop-attached lights (torches/lamps); those clear via the prop's Del()
		RemoveLightSource(L)
	src << "Cleared all admin-placed lights."
	Log("Admin", "[ExtractInfo(src)] cleared all placed lights.")
