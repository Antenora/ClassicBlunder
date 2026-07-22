//graphics policy + client-owned render plumbing: decides which passes a client gets

globalTracker
	var/tmp
		GRAPHICS_ADAPTIVE = TRUE
		GRAPHICS_BUDGET_SCALE = 1.0
		GRAPHICS_MIN_BUDGET = 0.55
		DEPTH_SORTING = TRUE
		DBG_NO_HIGHLIGHT = FALSE
		DBG_NO_EMISSIVE = FALSE
		DBG_NO_CONTACT = FALSE
		DBG_NO_GLINT = FALSE

client
	var/tmp
		obj/gfx_shadow_master/gfx_shadow_master
		obj/gfx_shadow_relay/gfx_shadow_relay
		obj/gfx_reflection_master/gfx_reflection_master
		obj/gfx_reflection_relay/gfx_reflection_relay
		obj/gfx_water_mask_master/gfx_water_mask_master
		list/gfx_water_mask_images
		gfx_water_mask_key
		obj/gfx_material_light_master/gfx_material_light_master
		obj/gfx_material_light_relay/gfx_material_light_relay
		obj/screen/gfx_env_grade/gfx_env_grade
		obj/screen/gfx_wet_sheen/gfx_wet_sheen
		obj/screen/gfx_moon_fill/gfx_moon_fill
		obj/screen/gfx_haze_grade/gfx_haze_grade
		obj/screen/gfx_haze_emitter/gfx_haze_emitter
		gfx_env_profile_id
		gfx_env_preview_id
		gfx_env_bloom_bias = 0
		gfx_env_wind_x = 0
		gfx_env_wind_y = 0
		gfx_env_wetness = 0
		gfx_screen_cover_w = 0
		gfx_screen_cover_h = 0
		gfx_haze_key
		gfx_reflection_filter_key
		gfx_initialized = FALSE

//shared base-world plane master; other systems hang filters off it
/obj/client_plane_master
	plane = FLOAT_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 1
	layer = BACKGROUND_LAYER

//shadows flatten here then show once through the relay, so overlaps don't stack
/obj/gfx_shadow_master
	plane = SHADOW_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*gfxshadows"

/obj/gfx_shadow_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	layer = MOB_LAYER - 0.03
	mouse_opacity = 0
	render_source = "*gfxshadows"

//the relay carries the wave, so the whole plane shares one filter set
/obj/gfx_reflection_master
	plane = REFLECTION_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*gfxreflections"

/obj/gfx_reflection_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	layer = MOB_LAYER - 0.02
	mouse_opacity = 0
	render_source = "*gfxreflections"

//white over water; the reflection relay alpha-clips against this so nothing paints on land
/obj/gfx_water_mask_master
	plane = WATER_MASK_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*gfxwatermask"

//own plane so low-quality clients can just hide the relay
/obj/gfx_material_light_master
	plane = MATERIAL_LIGHT_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*gfxmateriallight"

/obj/gfx_material_light_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	layer = MOB_LAYER + 0.025
	mouse_opacity = 0
	render_source = "*gfxmateriallight"

//area grade multiplies here, NOT client.color - legacy combat/cutscene effects still own that
/obj/screen/gfx_env_grade
	screen_loc = "CENTER"
	plane = 0
	layer = 6.42
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	blend_mode = BLEND_MULTIPLY
	alpha = 0
	New()
		..()
		icon = EnvWhiteIcon()

/obj/screen/gfx_wet_sheen
	screen_loc = "CENTER"
	plane = 0
	layer = 6.43
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	blend_mode = BLEND_ADD
	color = "#78aee8"
	alpha = 0
	New()
		..()
		icon = EnvWhiteIcon()

//additive fill so the full moon glows instead of just darkening
/obj/screen/gfx_moon_fill
	screen_loc = "CENTER"
	plane = 0
	layer = 6.56
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	blend_mode = BLEND_ADD
	color = "#8fb9ff"
	alpha = 0
	New()
		..()
		icon = EnvWhiteIcon()

//haze sits under the day/night blanket so fog stays in the scene
/obj/screen/gfx_haze_grade
	screen_loc = "CENTER"
	plane = 0
	layer = 6.44
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	alpha = 0
	New()
		..()
		icon = EnvWhiteIcon()

/obj/screen/gfx_haze_emitter
	screen_loc = "CENTER"
	plane = 0
	layer = 6.47
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	alpha = 0
	Savable = 0
	gfx_transient_visual = 1

var/_gfx_shared_screen_cover_w = 42
var/_gfx_shared_screen_cover_h = 32

proc/GfxScaleScreenOverlay(obj/screen/O, cover_w, cover_h)
	if(!O) return
	var/matrix/M = matrix()
	M.Scale(max(1, cover_w), max(1, cover_h))
	O.transform = M

//area tints show on many view sizes at once, so the shared cover only ever grows
proc/GfxFitSharedScreenOverlay(obj/screen/O)
	GfxScaleScreenOverlay(O, _gfx_shared_screen_cover_w, _gfx_shared_screen_cover_h)

//cover follows the map control's real pixel size; the spare edge tile hides rounding seams
proc/GfxResizeScreenOverlays(client/C, pixel_width = 0, pixel_height = 0)
	if(!C) return
	if(pixel_width <= 0 || pixel_height <= 0)
		var/list/parts = splittext(winget(C, "mapwindow.map", "size"), "x")
		if(parts.len >= 2)
			pixel_width = text2num(parts[1])
			pixel_height = text2num(parts[2])
	if(pixel_width <= 0 || pixel_height <= 0) return
	var/cover_w = max(1, round(pixel_width / world.icon_size))
	var/cover_h = max(1, round(pixel_height / world.icon_size))
	if(cover_w * world.icon_size < pixel_width) cover_w++
	if(cover_h * world.icon_size < pixel_height) cover_h++
	cover_w += 2
	cover_h += 2
	var/client_changed = C.gfx_screen_cover_w != cover_w || C.gfx_screen_cover_h != cover_h
	var/shared_grew = cover_w > _gfx_shared_screen_cover_w || cover_h > _gfx_shared_screen_cover_h
	if(!client_changed && !shared_grew) return
	if(client_changed)
		C.gfx_screen_cover_w = cover_w
		C.gfx_screen_cover_h = cover_h
		for(var/obj/screen/O in list(C.gfx_env_grade, C.gfx_wet_sheen, C.gfx_moon_fill, C.gfx_haze_grade))
			GfxScaleScreenOverlay(O, cover_w, cover_h)
		for(var/obj/screen/sandstorm_tint/S in C.screen)
			GfxScaleScreenOverlay(S, cover_w, cover_h)
	if(shared_grew)
		_gfx_shared_screen_cover_w = max(_gfx_shared_screen_cover_w, cover_w)
		_gfx_shared_screen_cover_h = max(_gfx_shared_screen_cover_h, cover_h)
		for(var/area/A in world)
			GfxFitSharedScreenOverlay(A.wx_tint)
			GfxFitSharedScreenOverlay(A.wx_flash)

proc/GfxQualityRank(client/C)
	var/Options/P = C ? C.prefs : null
	if(!istype(P, /Options)) return GFX_QUALITY_HIGH
	switch(lowertext("[P.graphicsQuality]"))
		if("low") return GFX_QUALITY_LOW
		if("medium") return GFX_QUALITY_MEDIUM
		if("ultra", "experimental") return GFX_QUALITY_ULTRA
	return GFX_QUALITY_HIGH

proc/GfxReducedMotion(client/C)
	var/Options/P = C ? C.prefs : null
	return istype(P, /Options) && P.reducedMotion

proc/GfxReducedFlashes(client/C)
	var/Options/P = C ? C.prefs : null
	return istype(P, /Options) && P.reducedFlashes

proc/GfxBloomEnabled(client/C)
	return GfxQualityRank(C) >= GFX_QUALITY_MEDIUM

proc/GfxDistortEnabled(client/C)
	return GfxQualityRank(C) >= GFX_QUALITY_HIGH && !GfxReducedMotion(C)

proc/GfxWeatherTier(client/C)
	return clamp(GfxQualityRank(C), GFX_QUALITY_LOW, GFX_QUALITY_HIGH)

proc/GfxCloudFactor(client/C)
	switch(GfxQualityRank(C))
		//shared sky: low presets dim the clouds, never delete them
		if(GFX_QUALITY_LOW) return 0.45
		if(GFX_QUALITY_MEDIUM) return 0.75
	return 1

proc/GfxShadowEnabled(client/C)
	return GfxQualityRank(C) >= GFX_QUALITY_MEDIUM

proc/GfxReflectionEnabled(client/C)
	var/Options/P = C ? C.prefs : null
	return istype(P, /Options) && P.reflections && GfxQualityRank(C) >= GFX_QUALITY_HIGH

proc/GfxBudgetScale()
	if(!glob || !glob.GRAPHICS_ADAPTIVE) return 1
	return clamp(glob.GRAPHICS_BUDGET_SCALE, glob.GRAPHICS_MIN_BUDGET, 1)

proc/GfxEnsureClient(client/C)
	if(!C) return
	var/needs_screen_fit = FALSE
	if(!C.gfx_shadow_master)
		C.gfx_shadow_master = new()
		C.screen += C.gfx_shadow_master
	if(!C.gfx_shadow_relay)
		C.gfx_shadow_relay = new()
		C.screen += C.gfx_shadow_relay
	if(!C.gfx_reflection_master)
		C.gfx_reflection_master = new()
		C.screen += C.gfx_reflection_master
	if(!C.gfx_reflection_relay)
		C.gfx_reflection_relay = new()
		C.screen += C.gfx_reflection_relay
	if(!C.gfx_water_mask_master)
		C.gfx_water_mask_master = new()
		C.screen += C.gfx_water_mask_master
	if(!C.gfx_material_light_master)
		C.gfx_material_light_master = new()
		C.screen += C.gfx_material_light_master
	if(!C.gfx_material_light_relay)
		C.gfx_material_light_relay = new()
		C.screen += C.gfx_material_light_relay
	if(!C.gfx_env_grade)
		C.gfx_env_grade = new()
		C.screen += C.gfx_env_grade
		needs_screen_fit = TRUE
	if(!C.gfx_wet_sheen)
		C.gfx_wet_sheen = new()
		C.screen += C.gfx_wet_sheen
		needs_screen_fit = TRUE
	if(!C.gfx_moon_fill)
		C.gfx_moon_fill = new()
		C.screen += C.gfx_moon_fill
		needs_screen_fit = TRUE
	if(!C.gfx_haze_grade)
		C.gfx_haze_grade = new()
		C.screen += C.gfx_haze_grade
		needs_screen_fit = TRUE
	if(!C.gfx_haze_emitter)
		C.gfx_haze_emitter = new()
		C.screen += C.gfx_haze_emitter
	if(needs_screen_fit)
		//the first fit ran before these overlays existed - force a refit
		C.gfx_screen_cover_w = 0
		C.gfx_screen_cover_h = 0
		GfxResizeScreenOverlays(C)

proc/GfxApplyShadowPass(client/C)
	if(!C) return
	GfxEnsureClient(C)
	if(!GfxShadowEnabled(C))
		C.gfx_shadow_relay.alpha = 0
		C.gfx_shadow_master.filters = null
		return
	C.gfx_shadow_relay.alpha = 255
	var/rank = GfxQualityRank(C)
	if(rank >= GFX_QUALITY_ULTRA)
		C.gfx_shadow_master.filters = filter(type = "blur", size = 1.25)
	else if(rank >= GFX_QUALITY_HIGH)
		C.gfx_shadow_master.filters = filter(type = "blur", size = 0.65)
	else
		C.gfx_shadow_master.filters = null

proc/GfxApplyMaterialLightPass(client/C)
	if(!C) return
	GfxEnsureClient(C)
	if(GfxQualityRank(C) < GFX_QUALITY_MEDIUM)
		C.gfx_material_light_relay.alpha = 0
		return
	C.gfx_material_light_relay.alpha = GfxQualityRank(C) >= GFX_QUALITY_ULTRA ? 255 : 225

proc/GfxApplyReflectionPass(client/C, area/A = null)
	if(!C) return
	GfxEnsureClient(C)
	if(!GfxReflectionEnabled(C))
		C.gfx_reflection_relay.alpha = 0
		C.gfx_reflection_relay.filters = null
		C.gfx_reflection_filter_key = null
		GfxClearWaterMask(C)
		return
	C.gfx_reflection_relay.alpha = 255
	if(!A && C.mob)
		var/turf/T = get_turf(C.mob)
		A = T ? T.loc : null
	var/wind_mag = sqrt(C.gfx_env_wind_x*C.gfx_env_wind_x + C.gfx_env_wind_y*C.gfx_env_wind_y)
	var/wetness = C.gfx_env_wetness
	var/key = "q[GfxQualityRank(C)]-w[round(wind_mag,0.2)]-wet[round(wetness,0.1)]-[A ? A.wx_kind : null]"
	if(C.gfx_reflection_filter_key == key) return
	C.gfx_reflection_filter_key = key
	var/list/fl = list()
	var/base_size = clamp(0.38 + wetness*0.24 + wind_mag*0.07, 0.38, 1.15)
	var/wavelength = clamp(22 - round(wind_mag*1.5), 13, 24)
	fl += filter(type = "wave", x = wavelength, y = 3, size = base_size, offset = 0)
	fl += filter(type = "blur", size = GfxQualityRank(C) >= GFX_QUALITY_ULTRA ? 0.45 : 0.25)
	if(GfxQualityRank(C) >= GFX_QUALITY_ULTRA)
		fl += filter(type = "wave", x = -(wavelength + 8), y = 4, size = base_size*0.48, offset = 0.4)
	//water clip LAST so wave/blur wobble inside the water; an empty mask blanks the plane
	fl += filter(type = "alpha", render_source = "*gfxwatermask")
	C.gfx_reflection_relay.filters = fl
	for(var/i = 1, i <= C.gfx_reflection_relay.filters.len, i++)
		var/f = C.gfx_reflection_relay.filters[i]
		if(f:type != "wave") continue
		animate(f, offset = f:offset, time = 0, loop = -1, flags = ANIMATION_PARALLEL)
		animate(offset = f:offset - 1, time = 35 + i * 9)

proc/GfxClearWaterMask(client/C)
	if(!C) return
	if(C.gfx_water_mask_images)
		for(var/image/I in C.gfx_water_mask_images)
			C.images -= I
	C.gfx_water_mask_images = null
	C.gfx_water_mask_key = null

//white runs over water near the view, rebuilt on 4-tile movement buckets
proc/GfxUpdateWaterMask(client/C)
	if(!C) return
	if(!GfxReflectionEnabled(C))
		if(C.gfx_water_mask_images) GfxClearWaterMask(C)
		return
	var/atom/anchor = GfxViewAnchor(C)
	var/turf/center = anchor ? get_turf(anchor) : null
	if(!center)
		GfxClearWaterMask(C)
		return
	var/list/dims = GfxCameraViewTiles(C)
	var/view_w = max(dims[1], C.gfx_screen_cover_w)
	var/view_h = max(dims[2], C.gfx_screen_cover_h)
	var/bucket_x = floor((center.x - 1) / 4)
	var/bucket_y = floor((center.y - 1) / 4)
	var/key = "[center.z]-[bucket_x]-[bucket_y]-[view_w]x[view_h]"
	if(C.gfx_water_mask_key == key) return
	C.gfx_water_mask_key = key
	var/mask_center_x = bucket_x * 4 + 2
	var/mask_center_y = bucket_y * 4 + 2
	var/half_w = round(view_w / 2) + 8
	var/half_h = round(view_h / 2) + 8
	var/list/fresh = list()
	for(var/ty = max(1, mask_center_y - half_h), ty <= min(world.maxy, mask_center_y + half_h), ty++)
		var/tx = max(1, mask_center_x - half_w)
		var/stop_x = min(world.maxx, mask_center_x + half_w)
		while(tx <= stop_x)
			var/turf/T = locate(tx, ty, center.z)
			if(!T || !GfxIsWaterSurface(T) || T.Lava || T.gfx_reflectivity == 0)
				tx++
				continue
			var/turf/run_start = T
			var/run_len = 1
			tx++
			while(tx <= stop_x)
				var/turf/N = locate(tx, ty, center.z)
				if(!N || !GfxIsWaterSurface(N) || N.Lava || N.gfx_reflectivity == 0) break
				run_len++
				tx++
			var/image/I = image(EnvWhiteIcon(), run_start)
			I.plane = WATER_MASK_PLANE
			I.layer = 1
			I.appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE
			if(run_len > 1)
				var/matrix/M = matrix()
				M.Scale(run_len, 1)
				I.transform = M
				//transforms expand around the icon center; shift east so the west edge holds
				I.pixel_x = round((run_len - 1) * world.icon_size / 2)
			fresh += I
	if(C.gfx_water_mask_images)
		for(var/image/I in C.gfx_water_mask_images)
			C.images -= I
	C.gfx_water_mask_images = fresh
	for(var/image/I in fresh)
		C.images += I

client/proc/ApplyGraphicsPreferences()
	GfxEnsureClient(src)
	FxEnsureMasters(src)
	CpmApply(src)
	FxApplyLightBlur(src)
	GfxApplyShadowPass(src)
	GfxApplyMaterialLightPass(src)
	GfxApplyReflectionPass(src)
	EnvUpdateClient(src, TRUE)
	if(mob)
		mob._wx_key = null
		mob._wx_tier = 0
	_WxSyncPass()
	_EnvCloudUpdateRelays(1 - DnDarknessFrac())
	GfxCameraSync(src)
	gfx_initialized = TRUE

client/proc/InitializeGraphics()
	if(!mob) return
	ApplyGraphicsPreferences()

/mob/verb/Graphics_Settings()
	set category = "Other"
	set name = "Graphics Settings"
	if(!client || !client.prefs) return
	var/choice = input(src, "Choose a graphics setting to change.\n\nCurrent preset: [client.prefs.graphicsQuality]", "Graphics Settings") in list(
		"Quality Preset", "Reduced Motion", "Reduced Flashes", "Foreground Fading", "Reflections", "Experimental Camera", "Apply / Close")
	switch(choice)
		if("Quality Preset")
			var/q = input(src, "Higher presets enable more particles, soft shadows, bloom, distortion, and reflections.", "Graphics Quality", client.prefs.graphicsQuality) in list("Low", "Medium", "High", "Ultra", "Cancel")
			if(q != "Cancel") client.prefs.graphicsQuality = q
		if("Reduced Motion") client.prefs.reducedMotion = !client.prefs.reducedMotion
		if("Reduced Flashes") client.prefs.reducedFlashes = !client.prefs.reducedFlashes
		if("Foreground Fading") client.prefs.foregroundFade = !client.prefs.foregroundFade
		if("Reflections") client.prefs.reflections = !client.prefs.reflections
		if("Experimental Camera") client.prefs.experimentalCamera = !client.prefs.experimentalCamera
	client.prefs.savePrefs(ckey)
	client.ApplyGraphicsPreferences()
	src << "Graphics: [client.prefs.graphicsQuality] | reduced motion [client.prefs.reducedMotion ? "ON" : "OFF"] | reduced flashes [client.prefs.reducedFlashes ? "ON" : "OFF"] | foreground fade [client.prefs.foregroundFade ? "ON" : "OFF"] | reflections [client.prefs.reflections ? "ON" : "OFF"] | camera [client.prefs.experimentalCamera ? "EXPERIMENTAL ON" : "OFF"]."

/mob/verb/Graphics_Diagnostics()
	set category = "Other"
	set name = "Graphics Diagnostics"
	if(!client) return
	var/wx = "clear"
	var/turf/T = GfxGroundTurf(src)
	var/area/A = T ? T.loc : null
	if(A && A.wx_kind) wx = A.wx_kind
	var/datum/environment_profile/P = EnvProfileForClient(client, A)
	var/list/reflection_solution = GfxFindActorReflectionTarget(src)
	var/turf/reflection_surface = reflection_solution ? reflection_solution["surface"] : null
	var/reflection_target = reflection_surface ? "[reflection_surface.x],[reflection_surface.y],[reflection_surface.z]" : "none"
	var/reflection_edge = reflection_solution ? GfxReflectionDirectionName(reflection_solution["dir"]) : "none"
	var/reflection_gap = reflection_solution ? reflection_solution["gap"] : 0
	var/highlights = 0
	for(var/atom/movable/O in _gfx_material_atoms)
		if(O.gfx_material_highlight) highlights++
	src << "<b>Graphics diagnostics</b>"
	src << "Preset: [client.prefs.graphicsQuality] | view: [client.view] | client FPS: [client.fps]"
	src << "Server CPU: [world.cpu]% | tick usage: [round(world.tick_usage, 0.1)] | adaptive budget: [round(GfxBudgetScale() * 100)]%"
	src << "Static lights: [_light_sources.len] | dynamic light records: [_fx_lights.len] | shadow objects: [_shadow_objs.len] | shared cloud banks: [_cloud_banks.len] ([GfxCloudChunkCount()] pieces) | weather: [wx]"
	src << "Environment: [P ? P.display_name : "Neutral"] | haze particles: [client.gfx_haze_emitter && client.gfx_haze_emitter.particles ? client.gfx_haze_emitter.particles.count : 0] | material highlights: [highlights]"
	src << "Cached light FOV builds: [_light_fov_builds] | average visible cells: [_light_fov_builds ? round(_light_fov_cells / _light_fov_builds, 0.1) : 0] | actor reflections: SCRAPPED | reflection ticks: [_gfx_actor_reflection_ticks] | emissive reflections: [_gfx_emissive_reflection_objs.len] | water mask runs: [client.gfx_water_mask_images ? client.gfx_water_mask_images.len : 0]"
	src << "AO view cache: [client.gfx_ao_scan_incomplete ? "building" : "ready"] | queued AO updates: [_gfx_ao_dirty.len] | water ripples: [_gfx_water_ripple_count] active / [_gfx_water_ripple_spawns] spawned"
	src << "Watchdog: [_gfx_watchdog_sequence > 0 ? "ACTIVE" : "waiting for first sample"] | samples written: [_gfx_watchdog_sequence] | file: graphics_watchdog.log"
	src << "Standing surface: water [GfxIsWaterSurface(T) ? "YES" : "no"] | reflection edge: [reflection_edge] | target: [reflection_target] | gap: [round(reflection_gap)]px | actor strength [round(GfxActorReflectionStrength(src, reflection_surface, reflection_gap), 0.01)] | actor eligible [reflection_surface ? "YES" : "no"]"

var/_gfx_adaptive_boot = _GfxAdaptiveBoot()

proc/_GfxAdaptiveBoot()
	spawn(120)
		_GfxAdaptiveLoop()
	return 1

proc/_GfxAdaptiveLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.GRAPHICS_ADAPTIVE)
			if(world.tick_usage >= 92)
				glob.GRAPHICS_BUDGET_SCALE = max(glob.GRAPHICS_MIN_BUDGET, glob.GRAPHICS_BUDGET_SCALE - 0.08)
			else if(world.tick_usage <= 65)
				glob.GRAPHICS_BUDGET_SCALE = min(1, glob.GRAPHICS_BUDGET_SCALE + 0.025)
		sleep(20)

/mob/Admin2/verb/Graphics_Adaptive_Toggle()
	set category = "Admin"
	set name = "Graphics Adaptive Toggle"
	glob.GRAPHICS_ADAPTIVE = !glob.GRAPHICS_ADAPTIVE
	if(!glob.GRAPHICS_ADAPTIVE) glob.GRAPHICS_BUDGET_SCALE = 1
	src << "Adaptive graphics budget: [glob.GRAPHICS_ADAPTIVE ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set adaptive graphics to [glob.GRAPHICS_ADAPTIVE].")

//crash-forensics heartbeat log; lives in this file so a .dme rewrite can't drop it

#define GFX_WATCHDOG_FILE "graphics_watchdog.log"
var/_gfx_watchdog_sequence = 0
var/_gfx_watchdog_boot = _GfxWatchdogBoot()

proc/GfxWatchdogSnapshot(reason = "HEARTBEAT")
	var/client_count = 0
	var/client_image_count = 0
	var/client_screen_count = 0
	var/reflection_count = islist(_gfx_emissive_reflection_objs) ? _gfx_emissive_reflection_objs.len : 0 //just the emissive glints
	var/reflection_filter_count = 0 //the relay carries the wave, nothing per-image
	for(var/client/C)
		client_count++
		if(islist(C.images)) client_image_count += C.images.len
		if(islist(C.screen)) client_screen_count += C.screen.len
	var/stamp = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/player_count = islist(players) ? players.len : 0
	var/line = "[stamp] seq=[++_gfx_watchdog_sequence] event=[reason] wt=[world.time] cpu=[world.cpu] tick=[round(world.tick_usage,0.1)] budget=[round(GfxBudgetScale()*100)] clients=[client_count] players=[player_count] images=[client_image_count] screen=[client_screen_count] actor_ref=[reflection_count] ref_filters=[reflection_filter_count] ref_ticks=[_gfx_actor_reflection_ticks] ripples=[_gfx_water_ripple_count]/[_gfx_water_ripple_spawns] materials=[islist(_gfx_material_atoms) ? _gfx_material_atoms.len : 0] contact=[islist(_gfx_contact_objs) ? _gfx_contact_objs.len : 0] emissive_ref=[islist(_gfx_emissive_reflection_objs) ? _gfx_emissive_reflection_objs.len : 0] ao_dirty=[islist(_gfx_ao_dirty) ? _gfx_ao_dirty.len : 0] lights=[islist(_light_sources) ? _light_sources.len : 0] shadows=[islist(_shadow_objs) ? _shadow_objs.len : 0] clouds=[islist(_cloud_banks) ? _cloud_banks.len : 0] cloud_chunks=[GfxCloudChunkCount()]"
	if(!text2file("[line]\n", GFX_WATCHDOG_FILE))
		world.log << "GFX WATCHDOG: failed to append [GFX_WATCHDOG_FILE] ([reason])."

proc/_GfxWatchdogBoot()
	spawn(150)
		GfxWatchdogSnapshot("BOOT")
		world.log << "GFX WATCHDOG: active; writing [GFX_WATCHDOG_FILE]."
		_GfxWatchdogLoop()
	return 1

proc/_GfxWatchdogLoop()
	set waitfor = 0
	set background = 1
	while(1)
		sleep(200)
		GfxWatchdogSnapshot("HEARTBEAT")

client/New()
	. = ..()
	GfxWatchdogSnapshot("CLIENT_NEW")

client/Del()
	GfxWatchdogSnapshot("CLIENT_DEL")
	GfxClearWaterMask(src)
	. = ..()

world/Del()
	GfxWatchdogSnapshot("WORLD_DEL")
	. = ..()

#undef GFX_WATCHDOG_FILE
