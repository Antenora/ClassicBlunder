globalTracker
	var/tmp
		WEATHER = TRUE //master switch
		WX_ROLL_MINUTES = 15 //new weather roll cadence per planet

area
	var/list/wx_table //weighted kinds; null = always clear
	var/tmp/wx_kind
	var/tmp/obj/screen/wx_tint/wx_tint
	var/tmp/obj/screen/wx_flash/wx_flash

area/Outside/Planet/Earth/wx_table = list("clear"=60,"rain"=28,"storm"=12)
area/Outside/Planet/Namek/wx_table = list("clear"=70,"rain"=30)
area/Outside/Planet/Vegeta/wx_table = list("clear"=70,"dust"=30)
area/Outside/Planet/Ice/wx_table = list("clear"=50,"snow"=32,"blizzard"=18)
area/Outside/Planet/AlienOcean/wx_table = list("clear"=50,"rain"=35,"storm"=15)
area/Outside/Planet/AlienGrassland/wx_table = list("clear"=65,"rain"=35)
area/Outside/Planet/AlienArctic/wx_table = list("clear"=55,"snow"=30,"blizzard"=15)
area/Outside/Planet/AlienDesolate/wx_table = list("clear"=60,"dust"=40)

mob
	var/tmp
		obj/screen/wx_tint/_wx_key //tint obj currently attached - object identity, not kind
		list/_wx_objs //everything we put on this client's screen
		_wx_standing = 0 //player is personally on an outside weather tile (tint/flash gate)
		_wx_tier = 0
		_wx_cover_w = 0
		_wx_cover_h = 0
		_wx_mask_key
		list/_wx_mask_images

/particles/wx_dust
	icon = 'sandstorm.dmi'
	width = 1400
	height = 1000
	count = 4200
	spawning = 60
	lifespan = 70
	fade = 3
	fadein = 3
	grow = 0.015
	scale = generator("num", 1.0, 2.2, NORMAL_RAND)
	gravity = list(-0.6, 0)
	position = generator("box", list(-500,-380,-100), list(500,380,100))
	color = "#5a2808"
	transform = list(1,0,0,0, 0,1,0,0, 0,0,1,1/750, 0,0,0,1)

/particles/wx_dust_medium
	parent_type = /particles/wx_dust
	count = 1900
	spawning = 30

/particles/wx_dust_low
	parent_type = /particles/wx_dust
	count = 800
	spawning = 15

//sits above the 6.5 day/night blanket, below the HUD stack
/obj/screen/wx_tint
	screen_loc = "CENTER"
	layer = 6.6
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	New()
		..()
		icon = EnvWhiteIcon()
		GfxFitSharedScreenOverlay(src)

/obj/screen/wx_emitter
	screen_loc = "CENTER"
	plane = WEATHER_PRECIP_PLANE
	layer = 1
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	Savable = 0
	gfx_transient_visual = 1
	var/tmp
		base_particle_count = 0
		base_particle_spawning = 0

//one row of adjacent 32x128 strips; rows sit every four screen tiles so edges meet
/obj/screen/wx_panel_row
	plane = WEATHER_PRECIP_PLANE
	layer = 1
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	Savable = 0
	gfx_transient_visual = 1

//offscreen plates: one alpha mask clips every repeated panel at once
/obj/screen/wx_precip_master
	plane = WEATHER_PRECIP_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*wxprecip"

/obj/screen/wx_outdoor_mask_master
	plane = WEATHER_MASK_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*wxoutdoormask"

/obj/screen/wx_precip_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	layer = 6.7
	mouse_opacity = 0
	render_source = "*wxprecip"
	New()
		..()
		filters = filter(type = "alpha", render_source = "*wxoutdoormask")

/obj/screen/wx_flash
	screen_loc = "CENTER"
	layer = 6.8
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE
	alpha = 0
	New()
		..()
		icon = EnvWhiteIcon()
		GfxFitSharedScreenOverlay(src)

//kind -> tint color, tint alpha
proc/_WxVisuals(kind)
	switch(kind)
		if("rain") return list("#46587a", 55)
		if("storm") return list("#2e3a55", 95)
		if("snow") return list("#ccd8ea", 35)
		if("blizzard") return list("#aebfd8", 95)
		if("dust") return list("#c49848", 90, /particles/wx_dust)
	return null

//kind -> panel layers (icon, state, alpha, draw layer); two speeds hide the 32x128 repeat
proc/_WxPanelLayers(kind)
	switch(kind)
		if("rain") return list(\
			list('Icons/Effects/Weather Rain Light.dmi', "flowslow", 120, 1),\
			list('Icons/Effects/Weather Rain Light.dmi', "flow", 235, 2))
		if("storm") return list(\
			list('Icons/Effects/Weather Rain Heavy.dmi', "flow", 255, 1),\
			list('Icons/Effects/Weather Rain Light.dmi', "flow", 200, 2))
		if("snow") return list(\
			list('Icons/Effects/Weather Snow Light.dmi', "flowslow", 120, 1),\
			list('Icons/Effects/Weather Snow Light.dmi', "flow", 235, 2))
		if("blizzard") return list(\
			list('Icons/Effects/Weather Snow Heavy.dmi', "flow", 255, 1),\
			list('Icons/Effects/Weather Snow Light.dmi', "flow", 200, 2))
	return null

proc/_WxParticlePath(kind, tier)
	switch(kind)
		if("dust")
			if(tier <= GFX_QUALITY_LOW) return /particles/wx_dust_low
			if(tier == GFX_QUALITY_MEDIUM) return /particles/wx_dust_medium
			return /particles/wx_dust
	return null

proc/_WxConfigureWind(area/A, obj/screen/wx_emitter/E, kind)
	if(!A || !E || !E.particles) return
	var/list/W = EnvWindForArea(A)
	var/wx = W[1]
	var/wy = W[2]
	switch(kind)
		if("dust") E.particles.velocity = generator("box", list(wx-3,wy-1,-1), list(wx+3,wy+2,1))

proc/_WxConfigureClientEmitter(client/C, area/A, obj/screen/wx_emitter/E, kind)
	if(!C || !E || !E.particles) return
	if(!E.base_particle_count)
		E.base_particle_count = E.particles.count
		E.base_particle_spawning = E.particles.spawning
	var/pixel_w = max(1024, C.gfx_screen_cover_w * world.icon_size)
	var/pixel_h = max(768, C.gfx_screen_cover_h * world.icon_size)
	var/half_w = round(pixel_w / 2) + 96
	var/half_h = round(pixel_h / 2) + 96
	var/coverage_scale = clamp((half_w * 2 * half_h * 2) / (1400 * 1000), 0.65, 3)
	E.particles.width = half_w * 2
	E.particles.height = half_h * 2
	E.particles.count = max(1, round(E.base_particle_count * coverage_scale))
	E.particles.spawning = max(1, round(E.base_particle_spawning * coverage_scale))
	E.particles.position = generator("box", list(-half_w, -half_h, -100), list(half_w, half_h, 100))
	_WxConfigureWind(A, E, kind)

proc/_WxAttachPanelRows(mob/Players/P, kind)
	if(!P || !P.client) return
	var/list/layers = _WxPanelLayers(kind)
	if(!layers) return
	var/list/dims = GfxCameraViewTiles(P.client)
	var/view_w = max(1, dims[1])
	var/view_h = max(1, dims[2])
	var/li = 0
	for(var/list/spec in layers)
		li++
		//the whole layer shares one state and one x-shift - per-row variety cuts seams at every row edge
		//rows stay inside 1..view_w x 1..view_h; out-of-view screen objs shift the HUD and desync the plates
		//only the dim layer takes the shift, via transform - screen-obj pixel_x doesn't render
		var/sx = (li == 1) ? 0 : rand(1, 31)
		for(var/y = 1, y <= view_h, y += 4)
			var/obj/screen/wx_panel_row/R = new()
			R.icon = spec[1]
			R.icon_state = spec[2]
			R.alpha = spec[3]
			R.layer = spec[4]
			if(sx) R.transform = matrix(1, 0, -sx, 0, 1, 0)
			R.screen_loc = "1,[y] to [view_w],[y]"
			P._wx_objs += R
			P.client.screen += R

proc/_WxClearOutdoorMask(mob/Players/P)
	if(!P) return
	if(P.client && P._wx_mask_images)
		for(var/image/I in P._wx_mask_images)
			P.client.images -= I
	P._wx_mask_images = null
	P._wx_mask_key = null

proc/_WxTurfReceivesWeather(turf/T, area/weather_area)
	if(!T || !weather_area) return FALSE
	var/area/A = T.loc
	return A && A.sees_sky && A.wx_kind == weather_area.wx_kind

proc/_WxMaskRunImage(turf/start, run_length)
	if(!start || run_length <= 0) return null
	var/image/I = image(EnvWhiteIcon(), start)
	I.plane = WEATHER_MASK_PLANE
	I.layer = 1
	I.appearance_flags = RESET_ALPHA | RESET_COLOR | PIXEL_SCALE
	if(run_length > 1)
		var/matrix/M = matrix()
		M.Scale(run_length, 1)
		I.transform = M
		//transforms grow from the icon center - shove the strip east so the west edge stays put
		I.pixel_x = round((run_length - 1) * world.icon_size / 2)
	return I

proc/_WxUpdateOutdoorMask(mob/Players/P, area/weather_area)
	if(!P || !P.client || !weather_area)
		_WxClearOutdoorMask(P)
		return
	var/atom/anchor = GfxViewAnchor(P.client)
	var/turf/center = anchor ? get_turf(anchor) : null
	if(!center)
		_WxClearOutdoorMask(P)
		return
	var/list/dims = GfxCameraViewTiles(P.client)
	var/view_w = max(dims[1], P.client.gfx_screen_cover_w)
	var/view_h = max(dims[2], P.client.gfx_screen_cover_h)
	//4-tile buckets skip per-step rebuilds; the extra 8 tiles keep the old mask covering between buckets
	var/bucket_x = floor((center.x - 1) / 4)
	var/bucket_y = floor((center.y - 1) / 4)
	var/key = "[center.z]-[bucket_x]-[bucket_y]-[view_w]x[view_h]"
	if(P._wx_mask_key == key) return
	var/mask_center_x = bucket_x * 4 + 2
	var/mask_center_y = bucket_y * 4 + 2
	var/half_w = ceil(view_w / 2) + 8
	var/half_h = ceil(view_h / 2) + 8
	var/min_x = max(1, mask_center_x - half_w)
	var/max_x = min(world.maxx, mask_center_x + half_w)
	var/min_y = max(1, mask_center_y - half_h)
	var/max_y = min(world.maxy, mask_center_y + half_h)
	var/list/new_images = list()
	for(var/y = min_y, y <= max_y, y++)
		var/turf/run_start = null
		for(var/x = min_x, x <= max_x + 1, x++)
			var/turf/T = x <= max_x ? locate(x, y, center.z) : null
			if(_WxTurfReceivesWeather(T, weather_area))
				if(!run_start) run_start = T
			else if(run_start)
				var/image/I = _WxMaskRunImage(run_start, x - run_start.x)
				if(I) new_images += I
				run_start = null
	//install the new mask before dropping the old one or the rain blinks on bucket changes
	var/list/old_images = P._wx_mask_images
	P._wx_mask_images = new_images
	P._wx_mask_key = key
	P.client.images += new_images
	if(old_images)
		for(var/image/I in old_images)
			P.client.images -= I

//any outside area with weather up in view: own tile first, then eight samples around the view edge
proc/_WxNearbyWeatherArea(mob/Players/P)
	if(!glob || !glob.WEATHER || !P || !P.client) return null
	var/atom/anchor = GfxViewAnchor(P.client)
	var/turf/center = anchor ? get_turf(anchor) : null
	if(!center) return null
	var/r = min(ClientViewRange(P.client), 12)
	for(var/list/off in list(list(r,0), list(-r,0), list(0,r), list(0,-r), list(r,r), list(r,-r), list(-r,r), list(-r,-r)))
		var/turf/S = locate(clamp(center.x + off[1], 1, world.maxx), clamp(center.y + off[2], 1, world.maxy), center.z)
		var/area/SA = S ? S.loc : null
		if(SA && SA.sees_sky && SA.wx_kind) return SA
	return null

proc/_WxDetachPlayer(mob/Players/P)
	if(!P) return
	_WxClearOutdoorMask(P)
	if(P._wx_objs)
		for(var/obj/screen/O in P._wx_objs.Copy())
			if(P.client) P.client.screen -= O
			if(istype(O, /obj/screen/wx_emitter))
				O.particles = null
			if(istype(O, /obj/screen/wx_emitter) || istype(O, /obj/screen/wx_panel_row) || istype(O, /obj/screen/wx_precip_master) || istype(O, /obj/screen/wx_outdoor_mask_master) || istype(O, /obj/screen/wx_precip_relay))
				del O
	P._wx_objs = null
	P._wx_key = null
	P._wx_tier = 0
	P._wx_cover_w = 0
	P._wx_cover_h = 0

proc/_WxStartMsg(kind)
	switch(kind)
		if("rain") return "Rain begins to fall."
		if("storm") return "A storm rolls in overhead."
		if("snow") return "Snow begins to fall."
		if("blizzard") return "A blizzard whips up!"
		if("dust") return "A dust storm sweeps across the land."
	return null

proc/_WxEndMsg(kind)
	switch(kind)
		if("rain") return "The rain lets up."
		if("storm") return "The storm passes."
		if("snow") return "The snowfall fades."
		if("blizzard") return "The blizzard dies down."
		if("dust") return "The dust settles."
	return null

var/_wx_boot = _WxBoot()

proc/_WxBoot()
	spawn(60)
		_WxRollLoop()
	spawn(70)
		_WxSyncLoop()
	return 1

proc/_WxPickWeighted(list/L)
	var/total = 0
	for(var/k in L) total += L[k]
	var/roll = rand(1, total)
	for(var/k in L)
		roll -= L[k]
		if(roll <= 0) return k
	return "clear"

proc/_WxRollLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.WEATHER)
			for(var/area/A in _dn_sky_areas)
				if(!A.wx_table) continue
				var/kind = _WxPickWeighted(A.wx_table)
				if(kind == "clear") kind = null
				if(kind != A.wx_kind)
					WxSet(A, kind)
		else
			for(var/area/A in _dn_sky_areas)
				if(A.wx_kind)
					WxSet(A, null)
		sleep(max(1, glob ? glob.WX_ROLL_MINUTES : 15) * 600)

proc/WxSet(area/A, kind)
	var/old = A.wx_kind
	if(A.wx_tint || A.wx_flash)
		for(var/client/C)
			if(A.wx_tint) C.screen -= A.wx_tint
			if(A.wx_flash) C.screen -= A.wx_flash
		A.wx_tint = null
		A.wx_flash = null
	A.wx_kind = kind
	if(kind)
		var/list/V = _WxVisuals(kind)
		A.wx_tint = new()
		A.wx_tint.color = V[1]
		A.wx_tint.alpha = V[2]
		if(kind == "storm")
			A.wx_flash = new()
			spawn() _WxStormFlashes(A)
	//flavor line to players standing under that sky (skip same-kind re-forces)
	var/msg = (kind != old) ? (kind ? _WxStartMsg(kind) : _WxEndMsg(old)) : null
	if(msg)
		for(var/mob/Players/P in players)
			var/turf/T = GfxGroundTurf(P)
			if(T && T.loc == A)
				P << "<font color=#8be9ff>[msg]</font>"
	_WxSyncPass() //re-attach immediately, no clear-sky gap until the next loop tick
	LightingRefreshReflectionsForArea(A)

proc/_WxStormFlashes(area/A)
	set waitfor = 0
	set background = 1
	var/obj/screen/wx_flash/F = A.wx_flash
	while(A && A.wx_kind == "storm" && A.wx_flash == F)
		sleep(rand(150, 600))
		if(!A || A.wx_kind != "storm" || A.wx_flash != F) break
		animate(F, alpha = 150, time = 1)
		animate(alpha = 0, time = 4)

proc/_WxSyncPass()
	for(var/mob/Players/P in players)
		if(!P.client)
			_WxDetachPlayer(P)
			continue
		var/turf/T = GfxGroundTurf(P)
		var/area/A = T ? T.loc : null
		var/area/standing = (glob && glob.WEATHER && A && A.sees_sky && A.wx_kind) ? A : null
		//panels stay up for any outside weather in view; only the tint and flashes care where YOU stand
		var/area/want = standing || _WxNearbyWeatherArea(P)
		var/obj/screen/wx_tint/want_key = want ? want.wx_tint : null
		var/tier = GfxWeatherTier(P.client)
		var/cover_w = P.client.gfx_screen_cover_w
		var/cover_h = P.client.gfx_screen_cover_h
		if(P._wx_key == want_key && P._wx_standing == !!standing && P._wx_tier == tier && P._wx_cover_w == cover_w && P._wx_cover_h == cover_h)
			if(want) _WxUpdateOutdoorMask(P, want)
			continue
		_WxDetachPlayer(P)
		P._wx_key = want_key
		P._wx_standing = !!standing
		P._wx_tier = tier
		P._wx_cover_w = cover_w
		P._wx_cover_h = cover_h
		if(want_key)
			P._wx_objs = list(want_key)
			if(standing) P.client.screen += want_key //the tint grades YOUR sky, not the roof over you
			var/list/panel_layers = _WxPanelLayers(want.wx_kind)
			var/particle_path = _WxParticlePath(want.wx_kind, tier)
			if(panel_layers || particle_path)
				var/obj/screen/wx_precip_master/precip_master = new()
				var/obj/screen/wx_outdoor_mask_master/mask_master = new()
				var/obj/screen/wx_precip_relay/precip_relay = new()
				P._wx_objs += list(precip_master, mask_master, precip_relay)
				P.client.screen += list(precip_master, mask_master, precip_relay)
				if(panel_layers)
					_WxAttachPanelRows(P, want.wx_kind)
				else
					var/obj/screen/wx_emitter/emitter = new()
					emitter.particles = new particle_path
					_WxConfigureClientEmitter(P.client, want, emitter, want.wx_kind)
					P._wx_objs += emitter
					P.client.screen += emitter
				_WxUpdateOutdoorMask(P, want)
			if(standing && want.wx_flash && !GfxReducedFlashes(P.client))
				P._wx_objs += want.wx_flash
				P.client.screen += want.wx_flash

proc/_WxSyncLoop()
	set waitfor = 0
	set background = 1
	while(1)
		_WxSyncPass()
		sleep(5)

/mob/Admin2/verb/Weather_Toggle()
	set category = "Admin"
	set name = "Weather Toggle"
	glob.WEATHER = !glob.WEATHER
	src << "Weather: [glob.WEATHER ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set weather to [glob.WEATHER].")
	_WxSyncPass()

/mob/Admin2/verb/Force_Weather()
	set category = "Admin"
	set name = "Force Weather"
	if(!glob.WEATHER)
		src << "Weather master switch is OFF - Weather Toggle first or nothing will show."
	var/list/zones = list()
	for(var/area/A in _dn_sky_areas)
		zones["[A.name]"] = A
	var/zn = input(src, "Which planet?") in zones + "Cancel"
	if(zn == "Cancel") return
	var/area/A = zones[zn]
	var/kind = input(src, "Which weather?") in list("clear","rain","storm","snow","blizzard","dust","Cancel")
	if(kind == "Cancel") return
	WxSet(A, kind == "clear" ? null : kind)
	src << "Weather on [zn]: [kind]."
	Log("Admin", "[ExtractInfo(src)] forced [kind] weather on [zn].")
