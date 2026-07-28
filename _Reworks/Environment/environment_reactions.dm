//footprints, rain/snow impacts and water ripples - hard-capped, spawned around active views

mob/Players
	var/tmp
		turf/_gfx_reaction_turf
		_gfx_last_footprint = 0
		_gfx_last_water_ripple = 0
		_gfx_wet_until = 0
		_gfx_snow_until = 0

obj/Skills/Projectile/_Projectile
	var/tmp
		turf/_gfx_water_center_turf
		_gfx_last_water_ripple = 0

var/icon/_gfx_footprint_icon
var/icon/_gfx_splash_icon
var/icon/_gfx_snow_splash_icon
var/icon/_gfx_water_ripple_icon
var/_gfx_footprint_count = 0
var/_gfx_splash_count = 0
var/_gfx_water_ripple_count = 0
var/_gfx_water_ripple_spawns = 0
var/list/_gfx_splash_recent = list()
var/list/_gfx_water_ripple_recent = list()

/obj/gfx_footprint
	plane = SHADOW_PLANE
	layer = 0.7
	mouse_opacity = 0
	density = 0
	Savable = 0
	gfx_transient_visual = 1

/obj/gfx_rain_splash
	plane = 1
	layer = 6.57
	mouse_opacity = 0
	density = 0
	blend_mode = BLEND_ADD
	Savable = 0
	gfx_transient_visual = 1

/obj/gfx_water_ripple
	icon = 'Icons/BLANK.dmi'
	icon_state = "N"
	plane = 0
	layer = MOB_LAYER - 0.05
	mouse_opacity = 0
	density = 0
	blend_mode = BLEND_DEFAULT
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA
	Savable = 0
	gfx_transient_visual = 1

proc/_GfxReactionBuildIcons()
	if(_gfx_footprint_icon && _gfx_water_ripple_icon) return
	var/icon/F = icon('Icons/BLANK.dmi')
	F.Scale(32, 32)
	F.DrawBox(null, 1, 1, 32, 32)
	var/icon/step = icon('Icons/small_shadow.dmi')
	step.Scale(5, 10)
	step.Blend("#ffffff", ICON_ADD)
	F.Blend(step, ICON_OVERLAY, 11, 8)
	F.Blend(step, ICON_OVERLAY, 18, 15)
	_gfx_footprint_icon = F
	_gfx_splash_icon = icon('Icons/Effects/Rain Impact.dmi')
	_gfx_snow_splash_icon = icon('Icons/Effects/Snow Impact.dmi')
	//4px padding + never scaling past 1x keeps a shoreline ripple from drawing on land
	var/icon/R = icon('Icons/BLANK.dmi')
	R.Scale(32, 32)
	R.DrawBox(null, 1, 1, 32, 32)
	for(var/px = 1, px <= 32, px++)
		for(var/py = 1, py <= 32, py++)
			var/dx = (px - 16.5) / 12
			var/dy = (py - 16.5) / 5
			var/outer = abs(sqrt(dx * dx + dy * dy) - 1)
			var/idx = (px - 16.5) / 7.5
			var/idy = (py - 16.5) / 2.8
			var/inner = abs(sqrt(idx * idx + idy * idy) - 1)
			if(outer <= 0.11)
				R.DrawBox(outer <= 0.055 ? "#ffffff" : "#8aaec0", px, py, px, py)
			else if(inner <= 0.13)
				R.DrawBox(inner <= 0.065 ? "#d9f3ff" : "#6f94a8", px, py, px, py)
	_gfx_water_ripple_icon = R

proc/GfxTurfWeatherExposed(turf/T)
	if(!T) return FALSE
	var/area/A = T.loc
	return A && A.sees_sky

proc/GfxPrecipitationImpactBlocked(turf/T)
	if(!T || IsLightOccluder(T)) return TRUE
	if(istype(T, /turf/CustomTurf) && T:Roof) return TRUE
	//impacts belong on the ground, not on top of a canopy, bridge or roof
	for(var/atom/movable/O in T)
		if(O.foreground_occluder || O.opacity || istype(O, /obj/LifeSkills/Tree)) return TRUE
	return FALSE

proc/GfxTurfAlreadySnowCovered(turf/T)
	if(!T) return FALSE
	//no snow-cover flag in the map data - sniff type/state/icon for snow floors, leave plain ice alone
	var/signature = lowertext("[T.type]|[T.icon]|[T.icon_state]")
	return findtext(signature, "snow") > 0

proc/GfxMaybeLeaveFootprint(mob/Players/P)
	if(!P || !P.client) return
	var/turf/T = GfxGroundTurf(P)
	if(!T) return
	if(GfxSupportsWaterRipple(T))
		P._gfx_wet_until = max(P._gfx_wet_until, world.time + 120)
		//ten-tick idle cadence overlaps rings so treading water never dead-pauses
		var/ripple_interval = (T != P._gfx_reaction_turf) ? 5 : 10
		if(!P.Flying && world.time - P._gfx_last_water_ripple >= ripple_interval)
			GfxSpawnWaterRipple(T, P, P.Swim ? 1.1 : 0.95)
			P._gfx_last_water_ripple = world.time
		P._gfx_reaction_turf = T
		return
	if(world.time - P._gfx_last_footprint < 4 || T == P._gfx_reaction_turf) return
	P._gfx_reaction_turf = T
	var/area/A = T.loc
	var/kind = A ? A.wx_kind : null
	var/exposed = GfxTurfWeatherExposed(T)
	if(exposed && (kind == "rain" || kind == "storm"))
		P._gfx_wet_until = world.time + (kind == "storm" ? 140 : 110)
	if(exposed && (kind == "snow" || kind == "blizzard"))
		P._gfx_snow_until = world.time + (kind == "blizzard" ? 90 : 65)
	var/snow = world.time < P._gfx_snow_until
	var/wet = world.time < P._gfx_wet_until
	if(!snow && !wet) return
	var/cap = max(24, round(120 * GfxBudgetScale()))
	if(_gfx_footprint_count >= cap) return
	_GfxReactionBuildIcons()
	var/obj/gfx_footprint/F = new(T)
	F.icon = _gfx_footprint_icon
	if(snow)
		F.plane = 0
		F.layer = 2.05
		F.color = "#d8e8f4"
		F.alpha = round(92 * clamp((P._gfx_snow_until - world.time) / 65, 0.3, 1))
	else
		F.color = "#16202a"
		F.alpha = round(48 * clamp((P._gfx_wet_until - world.time) / 110, 0.25, 1))
	F.dir = P.dir
	F.pixel_x = clamp(GfxGroundOffsetX(P, T), -10, 10)
	F.pixel_y = clamp(GfxGroundOffsetY(P, T), -10, 10)
	_gfx_footprint_count++
	P._gfx_last_footprint = world.time
	spawn(snow ? 450 : 180)
		if(F) animate(F, alpha = 0, time = 40)
		sleep(40)
		// Another cleanup path may release the effect while this delayed fade is asleep.
		if(F) F.loc = null
		_gfx_footprint_count = max(0, _gfx_footprint_count - 1)

proc/GfxSpawnRainSplash(turf/T, strength = 1)
	if(!T || !GfxTurfWeatherExposed(T) || GfxPrecipitationImpactBlocked(T)) return
	var/area/A = T.loc
	if(!A || !(A.wx_kind == "rain" || A.wx_kind == "storm")) return
	if(_gfx_splash_recent[T] && world.time - _gfx_splash_recent[T] < 8) return
	var/cap = max(12, round(60 * GfxBudgetScale()))
	if(_gfx_splash_count >= cap) return
	_GfxReactionBuildIcons()
	_gfx_splash_recent[T] = world.time
	var/obj/gfx_rain_splash/S = new(T)
	S.icon = _gfx_splash_icon
	S.color = null //preserve the authored blue palette
	S.alpha = round(210 * strength)
	// The 16px animation is bottom-left anchored; keep the complete impact inside its tile.
	S.pixel_x = rand(0, 16)
	S.pixel_y = rand(0, 16)
	S.transform = matrix()
	_gfx_splash_count++
	animate(S, alpha = S.alpha, time = 5)
	animate(alpha = 0, time = 3)
	spawn(9)
		if(S) S.loc = null
		_gfx_splash_count = max(0, _gfx_splash_count - 1)

proc/GfxSpawnSnowSplash(turf/T, strength = 1)
	if(!T || !GfxTurfWeatherExposed(T) || GfxPrecipitationImpactBlocked(T) || GfxTurfAlreadySnowCovered(T)) return
	var/area/A = T.loc
	if(!A || !(A.wx_kind == "snow" || A.wx_kind == "blizzard")) return
	if(_gfx_splash_recent[T] && world.time - _gfx_splash_recent[T] < 10) return
	var/cap = max(12, round(54 * GfxBudgetScale()))
	if(_gfx_splash_count >= cap) return
	_GfxReactionBuildIcons()
	_gfx_splash_recent[T] = world.time
	var/obj/gfx_rain_splash/S = new(T)
	S.icon = _gfx_snow_splash_icon
	S.color = null
	S.alpha = round(235 * strength)
	S.pixel_x = rand(0, 16)
	S.pixel_y = rand(0, 16)
	S.transform = matrix()
	_gfx_splash_count++
	// Eight authored frames at 150ms each, followed by a short fade.
	animate(S, alpha = S.alpha, time = 12)
	animate(alpha = 0, time = 3)
	spawn(16)
		if(S) S.loc = null
		_gfx_splash_count = max(0, _gfx_splash_count - 1)

proc/GfxSupportsWaterRipple(turf/T)
	return T && GfxIsWaterSurface(T) && !T.Lava

//ring radius is 12x5px; only let it cross a tile edge when that neighbor is water too
proc/GfxWaterRippleOffsets(atom/movable/source, turf/T)
	var/ox = source ? GfxGroundOffsetX(source, T) : 0
	var/oy = source ? GfxGroundOffsetY(source, T) : 0
	if(ox > 4 && !GfxSupportsWaterRipple(get_step(T, EAST))) ox = 4
	if(ox < -4 && !GfxSupportsWaterRipple(get_step(T, WEST))) ox = -4
	if(oy > 11 && !GfxSupportsWaterRipple(get_step(T, NORTH))) oy = 11
	if(oy < -11 && !GfxSupportsWaterRipple(get_step(T, SOUTH))) oy = -11
	//two water neighbors can meet around a dry diagonal corner - clamp one axis or the ellipse corners trespass
	var/diag
	if(ox > 4 && oy > 11) diag = NORTHEAST
	else if(ox > 4 && oy < -11) diag = SOUTHEAST
	else if(ox < -4 && oy > 11) diag = NORTHWEST
	else if(ox < -4 && oy < -11) diag = SOUTHWEST
	if(diag && !GfxSupportsWaterRipple(get_step(T, diag)))
		if(abs(ox) - 4 >= abs(oy) - 11) ox = ox > 0 ? 4 : -4
		else oy = oy > 0 ? 11 : -11
	return list(clamp(ox, -16, 15), clamp(oy, -16, 15))

proc/GfxSpawnWaterRipple(turf/T, atom/movable/source, strength = 1)
	if(source)
		var/turf/ground = GfxGroundTurf(source)
		//under pixel movement the turf crossing can beat the visible center; the microstep hook will retry
		if(!GfxSupportsWaterRipple(ground)) return
		T = ground
	if(!GfxSupportsWaterRipple(T)) return
	if(_gfx_water_ripple_recent[T] && world.time - _gfx_water_ripple_recent[T] < 2) return
	var/cap = max(24, round(96 * GfxBudgetScale()))
	if(_gfx_water_ripple_count >= cap) return
	_GfxReactionBuildIcons()
	_gfx_water_ripple_recent[T] = world.time
	var/obj/gfx_water_ripple/R = new(T)
	var/list/ripple_offset = GfxWaterRippleOffsets(source, T)
	R.pixel_x = ripple_offset[1]
	R.pixel_y = ripple_offset[2]
	//runtime icons don't render as a bare object icon - ride the ring as an overlay on an authored base
	var/image/ring = image(icon = _gfx_water_ripple_icon, layer = R.layer)
	ring.plane = 0
	ring.color = istype(source, /obj/Skills/Projectile/_Projectile) ? "#b9e5ff" : "#e0f6ff"
	ring.appearance_flags = KEEP_APART | RESET_ALPHA
	R.overlays = list(ring)
	R.alpha = round(clamp(strength, 0.25, 1.15) * 230)
	R.transform = matrix(0.30, 0, 0, 0, 0.30, 0)
	_gfx_water_ripple_count++
	_gfx_water_ripple_spawns++
	animate(R, transform = matrix(0.78, 0, 0, 0, 0.78, 0), alpha = R.alpha, time = 4, flags = ANIMATION_END_NOW | ANIMATION_LINEAR_TRANSFORM)
	animate(transform = matrix(1, 0, 0, 0, 1, 0), alpha = 0, time = 9, flags = ANIMATION_LINEAR_TRANSFORM)
	spawn(14)
		if(R)
			animate(R, flags = ANIMATION_END_NOW)
			R.overlays = null
			R.loc = null
		_gfx_water_ripple_count = max(0, _gfx_water_ripple_count - 1)

proc/GfxProjectileWaterMove(obj/Skills/Projectile/_Projectile/P, turf/before)
	if(!P) return
	var/turf/ground = GfxGroundTurf(P)
	if(GfxSupportsWaterRipple(ground) && ground != P._gfx_water_center_turf)
		GfxSpawnWaterRipple(ground, P, 0.9)
		P._gfx_last_water_ripple = world.time
	P._gfx_water_center_turf = ground

proc/GfxProjectileWaterPulse(obj/Skills/Projectile/_Projectile/P)
	if(!P || world.time - P._gfx_last_water_ripple < 10) return
	var/turf/ground = GfxGroundTurf(P)
	if(!GfxSupportsWaterRipple(ground)) return
	GfxSpawnWaterRipple(ground, P, 0.8)
	P._gfx_last_water_ripple = world.time

proc/_GfxReactionPass()
	var/list/pulsed_projectiles = list()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		GfxMaybeLeaveFootprint(P)
		if(islist(P.active_projectiles))
			for(var/obj/Skills/Projectile/_Projectile/Q in P.active_projectiles)
				if(pulsed_projectiles[Q]) continue
				pulsed_projectiles[Q] = TRUE
				GfxProjectileWaterPulse(Q)
		var/turf/PT = GfxGroundTurf(P)
		var/area/A = PT ? PT.loc : null
		if(!A || !A.sees_sky || !(A.wx_kind in list("rain", "storm", "snow", "blizzard"))) continue
		var/tier = GfxWeatherTier(P.client)
		var/heavy_weather = (A.wx_kind == "storm" || A.wx_kind == "blizzard")
		if(tier <= GFX_QUALITY_LOW && !prob(heavy_weather ? 55 : 35)) continue
		if(tier == GFX_QUALITY_MEDIUM && !prob(heavy_weather ? 85 : 65)) continue
		var/n = (heavy_weather && tier >= GFX_QUALITY_HIGH) ? 2 : 1
		n = max(1, round(n * GfxBudgetScale()))
		for(var/i = 1, i <= n, i++)
			var/turf/T = locate(clamp(P.x + rand(-8, 8), 1, world.maxx), clamp(P.y + rand(-6, 6), 1, world.maxy), P.z)
			var/area/TA = T ? T.loc : null
			if(T && TA == A)
				if(A.wx_kind == "rain" || A.wx_kind == "storm")
					GfxSpawnRainSplash(T, A.wx_kind == "storm" ? 1 : 0.7)
				else
					GfxSpawnSnowSplash(T, A.wx_kind == "blizzard" ? 1 : 0.72)
	for(var/turf/T in _gfx_splash_recent.Copy())
		if(world.time - _gfx_splash_recent[T] > 20) _gfx_splash_recent -= T
	for(var/turf/T in _gfx_water_ripple_recent.Copy())
		if(world.time - _gfx_water_ripple_recent[T] > 20) _gfx_water_ripple_recent -= T

var/_gfx_reaction_boot = _GfxReactionBoot()

proc/_GfxReactionBoot()
	spawn(130)
		_GfxReactionBuildIcons()
		_GfxReactionLoop()
	return 1

proc/_GfxReactionLoop()
	set waitfor = 0
	set background = 1
	while(1)
		_GfxReactionPass()
		sleep(5)
