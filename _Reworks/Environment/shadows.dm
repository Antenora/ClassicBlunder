globalTracker
	var/tmp
		WORLD_SHADOWS = TRUE //master switch (sun + lights)
		LIGHT_SHADOWS = TRUE //point-light shadows on top of the sun shadow
		SHADOW_MAX_LIGHTS = 2 //most point-light shadows a single mob casts at once
		SHADOW_SHEAR_MAX = 1.2 //max horizontal lean
		SHADOW_LEN_MIN = 0.35 //vertical foreshorten at noon / near a light (short)
		SHADOW_LEN_MAX = 1.5 //vertical foreshorten at dawn/dusk / far from a light (long)
		SHADOW_SUN_ALPHA = 115 //daytime sun-shadow strength
		SHADOW_MOON_ALPHA = 42 //night moon-shadow strength
		SHADOW_LIGHT_ALPHA = 95 //point-light shadow strength at the source
		SHADOW_WIDTH = 0.9 //point-light shadow width perpendicular to the fall - stops the E/W collapse
		SHADOW_MOON_TINT = "#7f8fbf"
		SHADOW_SUN_TINT = "#0a0a0e"
		LIGHT_SHADOW_RADIUS = 6 //tiles a registered light casts shadows over
		SHADOW_INTERVAL = 3 //process cadence in ds (mob follows via vis_contents; only re-angles)
		SHADOW_VIEW_MARGIN = 12
		//full-moon event overrides (ramp driven by MoonEventK in daynight.dm)
		MOON_EVENT_ALPHA = 150 //full-moon shadow strength, vs the 42 nobody has ever noticed
		MOON_EVENT_LEN_MIN = 1.05 //event length FLOOR - the only knob that lengthens (see SunShadowParams)
		MOON_EVENT_TINT = "#141c30" //cold near-black; the pale #7f8fbf reads as haze, not shadow
		//altitude (pixel_z): shadow shrinks + fades as the mob rises - flight, lofts, juggles
		SHADOW_ALT_REF = 48 //full-flight height; response saturates here
		SHADOW_ALT_SHRINK = 0.45 //silhouette size lost at full altitude
		SHADOW_ALT_FADE = 0.55 //alpha lost at full altitude

mob/var/tmp/list/shadow_pool //reusable /obj/fx_worldshadow, [1..N] for sun + light shadows
mob/var/tmp/shadow_seen_at = 0

var/list/_shadow_objs = list() //every live shadow obj; swept for orphans
var/_shadow_reap_at = 0
var/_ws_boot = _WsBoot()

proc/ShadowDisplayedCardinal(d, prev)
	switch(d)
		if(NORTHEAST, SOUTHEAST) return EAST
		if(NORTHWEST, SOUTHWEST) return WEST
		if(NORTH, SOUTH, EAST, WEST) return d
	return prev || SOUTH

//sun/moon state -> list(shear, lenK, alpha, isMoon, tint)
proc/SunShadowParams()
	var/p = (glob && glob.DAY_NIGHT) ? DnPhase() : 0.2 //clock off -> a fixed mid-morning sun
	var/ps = p - 0.88 + 1.0
	if(ps >= 1.0) ps -= 1.0
	var/isMoon = 0
	var/da
	if(ps <= 0.70)
		da = ps / 0.70
	else
		da = (ps - 0.70) / 0.30
		isMoon = 1
	var/elev = sin(da * 180) //BYOND trig = degrees
	var/shear = (da - 0.5) * 2 * glob.SHADOW_SHEAR_MAX
	var/lenK = glob.SHADOW_LEN_MIN + (glob.SHADOW_LEN_MAX - glob.SHADOW_LEN_MIN) * (1 - elev)
	var/alpha
	var/tint
	if(isMoon)
		//shear stays untouched - it crosses zero at peak, flooring it would snap the lean
		var/k = MoonEventK()
		alpha = DnLerpNum(glob.SHADOW_MOON_ALPHA, glob.MOON_EVENT_ALPHA, k) * elev
		tint = glob.SHADOW_MOON_TINT
		if(k > 0)
			var/lmin = min(DnLerpNum(glob.SHADOW_LEN_MIN, glob.MOON_EVENT_LEN_MIN, k), glob.SHADOW_LEN_MAX)
			lenK = lmin + (glob.SHADOW_LEN_MAX - lmin) * (1 - elev)
			tint = DnLerp(glob.SHADOW_MOON_TINT, glob.MOON_EVENT_TINT, k)
	else
		alpha = glob.SHADOW_SUN_ALPHA * (0.55 + 0.45 * elev) * (1 - DnDarknessFrac())
		tint = glob.SHADOW_SUN_TINT
	return list(shear, lenK, round(alpha), isMoon, tint)

//nearest point lights -> list of "rad" fall configs for Configure
proc/ComputeLightShadows(mob/M)
	var/list/out = list()
	if(!glob.LIGHT_SHADOWS) return out
	if(!_fx_lights.len && !(glob.LIGHTING && _light_sources.len)) return out
	var/list/cand = list()
	for(var/datum/fx_light/L in _fx_lights) //dynamic blast/pulse lights
		var/turf/lt = FxLightTurf(L)
		if(!lt || lt.z != M.z) continue
		var/d = get_dist(M, lt)
		if(d > L.radius) continue
		cand += list(list(d, M.x - lt.x, M.y - lt.y, L.radius, LightRenderStrength(lt)))
	if(glob.LIGHTING) //placed lights cast shadows too (walk around a torch, shadow rotates)
		var/turf/mt = get_turf(M)
		for(var/datum/lightsource/PL in LightsNearTurf(mt, 22))
			var/turf/lt = LightSrcTurf(PL) //src_obj (torch prop) OR fixed lx/ly/lz; props leave lx/ly/lz null
			if(!lt || lt.z != M.z) continue
			var/d = get_dist(M, lt)
			if(d > PL.radius) continue
			if(mt != lt && !LightClearLine(lt, mt)) continue //a wall between = the light can't reach this mob, so no shadow
			cand += list(list(d, M.x - lt.x, M.y - lt.y, PL.radius, LightRenderStrength(lt)))
	var/k = max(0, round(glob.SHADOW_MAX_LIGHTS * GfxBudgetScale()))
	while(out.len < k && cand.len)
		var/best = 1
		for(var/i in 2 to cand.len)
			if(cand[i][1] < cand[best][1]) best = i
		var/list/c = cand[best]
		cand.Cut(best, best + 1)
		var/d = c[1]
		var/dx = c[2] //mob - light (the away-from-light vector)
		var/dy = c[3]
		var/radius = c[4]
		var/light_strength = c[5]
		var/distF = radius > 0 ? clamp(d / radius, 0, 1) : 0
		var/mag = sqrt(dx * dx + dy * dy)
		var/ux = mag > 0 ? dx / mag : 0 //unit vector pointing away from the light
		var/uy = mag > 0 ? dy / mag : -1 //on the light tile: default straight down
		var/lenK = glob.SHADOW_LEN_MIN + (glob.SHADOW_LEN_MAX - glob.SHADOW_LEN_MIN) * distF
		var/a = round(glob.SHADOW_LIGHT_ALPHA * (1 - distF) * light_strength)
		if(a < 8) continue
		out += list(list("rad", ux, uy, lenK, a, glob.SHADOW_SUN_TINT))
	return out

/obj/fx_worldshadow
	mouse_opacity = 0
	density = 0
	plane = SHADOW_PLANE
	layer = 1 //flattened and placed under mobs by gfx_shadow_relay
	Savable = 0
	gfx_transient_visual = 1
	var/tmp
		mob/owner
		cached_owner_appearance //exact look snapshot; detects same-length gear replacements too
		measure_key //base icon/state/cardinal used for the feet-pivot measurement
		display_dir = SOUTH //sticky 4-dir facing while the mob travels diagonally
		cached_h = 32
		cached_gap = 0
		snap_next = 1 //snap (not animate) the next Configure - set on create + on silhouette rebuild
		last_ux = 0 //last radial away-direction; a hard swing snaps (a matrix lerp through ~180 collapses)
		last_uy = -1

	New(mob/o)
		..(null)
		loc = null
		owner = o
		appearance_flags |= KEEP_TOGETHER

	//refresh only when the mob's look or shown facing changes
	proc/RebuildSilhouette()
		if(!owner) return
		var/shown_dir = ShadowDisplayedCardinal(owner.dir, display_dir)
		var/current_appearance = owner.appearance
		if(current_appearance == cached_owner_appearance && shown_dir == display_dir) return
		cached_owner_appearance = current_appearance
		display_dir = shown_dir
		//VIS_INHERIT_ICON/STATE picks up the engine moving flag so walk frames animate
		//never reset color/alpha/transform here - Move() calls this mid-step and a raw copy flashes through
		icon = owner.icon
		icon_state = owner.icon_state
		dir = shown_dir
		overlays = owner.overlays
		underlays = owner.underlays
		appearance_flags = KEEP_TOGETHER
		vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE
		var/new_measure_key = "[owner.icon]-[owner.icon_state]-[shown_dir]"
		if(new_measure_key != measure_key)
			measure_key = new_measure_key
			var/icon/I = icon(owner.icon, owner.icon_state, shown_dir, 1)
			var/h = I.Height()
			if(!h) h = world.icon_size
			var/w = I.Width()
			var/gap = 0
			for(var/y = 1 to h)
				var/found = 0
				for(var/x = 1 to w)
					if(I.GetPixel(x, y))
						gap = y - 1
						found = 1
						break
				if(found) break
			cached_h = h
			cached_gap = gap

	//feet-pinned projection: "sun" = shear flip, "rad" = radial away from a point light
	//mob scale rides in as sx/sy - vis children inherit pixel offsets but not transform
	proc/Configure(list/c, sx, sy, opz)
		var/matrix/Mx
		var/px
		var/py
		var/a
		var/col
		var/altK = 0
		if(opz > 0 && glob.SHADOW_ALT_REF > 0)
			altK = min(opz / glob.SHADOW_ALT_REF, 1)
			var/shrink = 1 - glob.SHADOW_ALT_SHRINK * altK
			sx *= shrink
			sy *= shrink
		if(c[1] == "rad")
			var/ux = c[2]
			var/uy = c[3]
			var/ln = c[4]
			a = c[5]
			col = c[6]
			var/ws = glob.SHADOW_WIDTH
			//height axis -> ln*(ux,uy); width axis -> ws*perp, perp=(-uy,ux); then mob scale
			var/mb = sy * ln * ux
			var/me = sy * ln * uy
			Mx = matrix(sx * ws * -uy, mb, 0, sx * ws * ux, me, 0)
			px = mb * (cached_h / 2 - cached_gap)
			py = (cached_gap - cached_h / 2) * (sy - me) - opz
			if(!snap_next && (ux * last_ux + uy * last_uy) < -0.2) //hard swing (>~100 deg): snap, don't lerp the matrix through a collapse
				snap_next = 1
			last_ux = ux
			last_uy = uy
		else //"sun"
			var/fx = c[2]
			var/fy = c[3]
			a = c[4]
			col = c[5]
			Mx = matrix(sx, fx * sy, 0, 0, fy * sy, 0)
			px = fx * sy * (cached_h / 2 - cached_gap)
			py = sy * (cached_gap - cached_h / 2) * (1 - fy) - opz
		if(altK) a = round(a * (1 - glob.SHADOW_ALT_FADE * altK))
		var/matrix/M = Mx
		if(snap_next) //fresh shadow / just rebuilt: set instantly (no grow-in from identity)
			snap_next = 0
			transform = M
			pixel_x = px
			pixel_y = py
			color = col
			alpha = a
		else //glide to the new angle/length so light-driven moves are smooth, not jerky
			animate(src, transform = M, pixel_x = px, pixel_y = py, color = col, alpha = a, time = glob.SHADOW_INTERVAL)

//no sees_sky gate here - that's per-config, point lights still work in caves
proc/ShadowCastable(mob/M)
	if(!M || !M.icon) return 0
	if(M.AdminInviso || M.invisibility > 0) return 0
	if(!get_turf(M)) return 0
	if(istype(M, /mob/Players))
		var/mob/Players/P = M
		if(P.ShadowbringerShadowObj) return 0
	return 1

//ensure one pooled shadow per config, then aim each
mob/proc/EnsureMobShadows(list/configs)
	if(!shadow_pool) shadow_pool = list()
	//saves serialize vis_contents, so a reloaded mob carries baked-in stale shadows - scrub them
	var/list/stale = list()
	for(var/obj/fx_worldshadow/s in vis_contents)
		if(!(s in shadow_pool)) stale += s
	for(var/obj/fx_worldshadow/s in stale)
		vis_contents -= s
		_shadow_objs -= s
		s.owner = null //ref-drop, never del (del scans the whole world)
		s.loc = null
	for(var/obj/fx_worldshadow/s in shadow_pool)
		if(!(s in vis_contents)) vis_contents += s
	var/sx = 1
	var/sy = 1
	var/matrix/ot = transform
	if(ot)
		sx = ot.a
		sy = ot.e
	var/opz = pixel_z
	var/n = configs.len
	while(shadow_pool.len < n)
		var/obj/fx_worldshadow/s = new(src)
		vis_contents += s
		shadow_pool += s
		_shadow_objs |= s
	for(var/i = 1, i <= shadow_pool.len, i++)
		var/obj/fx_worldshadow/s = shadow_pool[i]
		if(i <= n)
			s.RebuildSilhouette()
			s.Configure(configs[i], sx, sy, opz)
		else
			s.alpha = 0 //spare (fewer lights this tick); kept for reuse, cheap

mob/proc/ClearMobShadows()
	if(shadow_pool)
		for(var/obj/fx_worldshadow/s in shadow_pool)
			_shadow_objs -= s
			vis_contents -= s
			s.owner = null //ref-drop, never del
			s.loc = null
		shadow_pool = null

mob/proc/HideMobShadows()
	if(!shadow_pool) return
	for(var/obj/fx_worldshadow/s in shadow_pool)
		if(!s.alpha && s.snap_next) continue
		animate(s)
		s.alpha = 0
		s.snap_next = 1

//client.view can be a "WxH" string wider than world.view - cover what the player actually sees
proc/ClientViewRange(client/C)
	if(!C) return world.view
	var/v = C.view
	if(isnum(v)) return clamp(v, world.view, 33)
	var/list/parts = splittext("[v]", "x")
	if(parts.len >= 2)
		var/w = text2num(parts[1])
		var/h = text2num(parts[2])
		if(w && h) return clamp(round(max(w, h) / 2) + 1, world.view, 33) //radius that covers the wider dimension, small margin
	return world.view

proc/ShadowScanRadius(client/C)
	return min(ClientViewRange(C) + glob.SHADOW_VIEW_MARGIN, 33)

proc/ShadowScanAround(atom/anchor, rng, list/sp, list/seen)
	for(var/mob/M in range(rng, anchor))
		if(seen && seen[M]) continue
		if(seen) seen[M] = 1
		if(!ShadowCastable(M))
			M.HideMobShadows()
			continue
		var/list/configs = list()
		var/turf/mt = get_turf(M)
		var/area/MA = mt ? mt.loc : null
		if(sp[3] >= 8 && MA && MA.sees_sky) //sun/moon shadow: outdoors only
			configs += list(list("sun", sp[1], -sp[2], sp[3], sp[5])) //shear, -lenK, alpha, tint
		for(var/lc in ComputeLightShadows(M)) //point lights: anywhere (incl. caves)
			configs += list(lc)
		if(!configs.len)
			M.HideMobShadows()
			continue
		if(M.shadow_pool && world.time - M.shadow_seen_at > glob.SHADOW_INTERVAL * 2)
			for(var/obj/fx_worldshadow/s in M.shadow_pool)
				s.snap_next = 1
		M.shadow_seen_at = world.time
		M.EnsureMobShadows(configs)

proc/ShadowPrewarm(mob/M)
	if(WorldLoading) return
	if(!glob || !glob.WORLD_SHADOWS) return
	if(!M || !M.client) return
	if(!GfxShadowEnabled(M.client)) return
	var/atom/view_anchor = GfxViewAnchor(M.client)
	if(!get_turf(view_anchor)) view_anchor = M
	ShadowScanAround(view_anchor, ShadowScanRadius(M.client), SunShadowParams(), null)
	var/turf/vt = get_turf(view_anchor)
	if(vt)
		for(var/atom/movable/A in GfxMaterialsNear(vt, ShadowScanRadius(M.client) + 2))
			if(A.z == vt.z && A.gfx_wind_response > 0) GfxApplyMaterialWind(A)

proc/WorldShadow_Process()
	if(WorldLoading) return
	if(!glob || !glob.WORLD_SHADOWS)
		if(_shadow_objs.len)
			var/list/clear = list()
			for(var/obj/fx_worldshadow/sh in _shadow_objs)
				if(sh.owner) clear[sh.owner] = 1
				else sh.loc = null
			_shadow_objs.Cut()
			for(var/mob/o in clear)
				o.ClearMobShadows()
		if(_fx_lights.len) _fx_lights.Cut() //master off: stop tracking lights (nothing prunes them here)
		return
	FxPruneLights()
	var/list/sp = SunShadowParams()
	var/list/seen = list()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		if(!GfxShadowEnabled(P.client)) continue
		var/atom/view_anchor = GfxViewAnchor(P.client)
		if(!get_turf(view_anchor)) view_anchor = P
		ShadowScanAround(view_anchor, ShadowScanRadius(P.client), sp, seen) //scan the fitted view around the actual camera center
	if(world.time >= _shadow_reap_at)
		_shadow_reap_at = world.time + 300
		_ShadowReapOrphans()

proc/_ShadowReapOrphans()
	var/list/reap = list()
	for(var/obj/fx_worldshadow/sh in _shadow_objs)
		if(!sh.owner) reap += sh
	if(!reap.len) return
	_shadow_objs -= reap
	for(var/obj/fx_worldshadow/sh in reap)
		sh.loc = null

proc/_WsBoot()
	spawn(90)
		_WsLoop()
	return 1

proc/_WsLoop()
	set waitfor = 0
	set background = 1
	while(1)
		WorldShadow_Process()
		sleep(max(1, glob ? glob.SHADOW_INTERVAL : 3))

/mob/Admin2/verb/Shadows_Toggle()
	set category = "Admin"
	set name = "Shadows Toggle"
	glob.WORLD_SHADOWS = !glob.WORLD_SHADOWS
	src << "World shadows: [glob.WORLD_SHADOWS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set world shadows to [glob.WORLD_SHADOWS].")

/mob/Admin2/verb/Light_Shadows_Toggle()
	set category = "Admin"
	set name = "Light Shadows Toggle"
	glob.LIGHT_SHADOWS = !glob.LIGHT_SHADOWS
	if(!glob.LIGHT_SHADOWS) _fx_lights.Cut()
	src << "Point-light shadows: [glob.LIGHT_SHADOWS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set light shadows to [glob.LIGHT_SHADOWS].")
