/particles/gfx_haze
	icon = 'sandstorm.dmi'
	width = 1400
	height = 1000
	count = 1
	spawning = 0
	lifespan = 180
	fade = 45
	fadein = 45
	friction = 0.015
	scale = generator("num", 2.5, 6.5, NORMAL_RAND)
	position = generator("box", list(-700,-500,-120), list(700,500,120))
	velocity = generator("box", list(-0.3,-0.1,-0.2), list(0.7,0.25,0.2))
	color = "#d9e5ee"
	transform = list(1,0,0,0, 0,1,0,0, 0,0,1,1/850, 0,0,0,1)

/datum/environment_profile
	var
		id = "default"
		display_name = "Neutral"
		grade_color = "#ffffff"
		grade_alpha = 0
		bloom_bias = 0
		wind_x = 0
		wind_y = 0
		base_wetness = 0
		reflection_strength = 0.65
		haze_color = "#d9e5ee"
		haze_alpha = 0
		haze_density = 0
		haze_depth = 1
		grade_gain
		grade_black
		grade_warm
		ambient_day
		ambient_night

area
	var/env_profile_id = "default"


var/list/_env_profiles = list()
var/_env_profile_boot = _EnvProfileBoot()

proc/_EnvProfileMake(id, display_name, grade_color, grade_alpha, bloom_bias, wind_x, wind_y, base_wetness, reflection_strength = 0.65)
	var/datum/environment_profile/P = new
	P.id = id
	P.display_name = display_name
	P.grade_color = grade_color
	P.grade_alpha = grade_alpha
	P.bloom_bias = bloom_bias
	P.wind_x = wind_x
	P.wind_y = wind_y
	P.base_wetness = base_wetness
	P.reflection_strength = reflection_strength
	_env_profiles[id] = P
	return P

proc/_EnvProfileHaze(id, haze_color, haze_alpha, haze_density, haze_depth = 1)
	var/datum/environment_profile/P = _env_profiles[id]
	if(!P) return
	P.haze_color = haze_color
	P.haze_alpha = haze_alpha
	P.haze_density = haze_density
	P.haze_depth = haze_depth

proc/_EnvProfileMood(id, gain, black, warm, aday, anight)
	var/datum/environment_profile/P = _env_profiles[id]
	if(!P) return
	P.grade_gain = gain
	P.grade_black = black
	P.grade_warm = warm
	P.ambient_day = aday
	P.ambient_night = anight

proc/_EnvProfileBoot()
	_EnvProfileMake("default", "Neutral", "#ffffff", 0, 0, 0.5, 0, 0)
	_EnvProfileMake("temperate", "Temperate", "#f1f6ff", 16, -4, 1.1, 0.2, 0.08, 0.65)
	_EnvProfileMake("lush", "Lush", "#e7f8e1", 22, -6, 1.0, 0.45, 0.18, 0.7)
	_EnvProfileMake("arid", "Arid", "#ead2ad", 32, 7, 2.8, 0.2, 0.01, 0.25)
	_EnvProfileMake("frozen", "Frozen", "#dcecff", 32, -8, 1.6, 0.35, 0.15, 0.75)
	_EnvProfileMake("volcanic", "Volcanic", "#ffb49f", 42, 11, 0.6, 0.25, 0.01, 0.2)
	_EnvProfileMake("coastal", "Coastal", "#d9efff", 26, -6, 2.0, 0.55, 0.35, 0.9)
	_EnvProfileMake("swamp", "Swamp", "#d4dfb8", 30, 2, 0.7, 0.25, 0.65, 0.75)
	_EnvProfileMake("subterranean", "Subterranean", "#d4d0df", 38, 10, 0.05, 0, 0.12, 0.35)
	_EnvProfileMake("underwater", "Underwater", "#98cfe8", 56, 10, 0.35, 0.1, 1, 0.95)
	_EnvProfileMake("industrial", "Industrial", "#e0ddd5", 20, 4, 0.35, 0.1, 0.05, 0.45)
	_EnvProfileMake("ethereal", "Ethereal", "#f3eeff", 24, -12, 0.4, 0.1, 0.04, 0.7)
	_EnvProfileMake("void", "Void", "#c5b8e8", 48, 18, 0, 0, 0, 0.15)
	_EnvProfileMake("toxic", "Toxic", "#d5efa8", 36, 6, 0.5, 0.15, 0.18, 0.5)
	_EnvProfileMake("corrupted", "Corrupted", "#e4b2cc", 40, 12, 0.3, 0.1, 0.02, 0.3)
	_EnvProfileHaze("temperate", "#dce8ee", 7, 0.08)
	_EnvProfileHaze("lush", "#d3e5d0", 15, 0.2)
	_EnvProfileHaze("arid", "#dfc69f", 12, 0.16, 1.2)
	_EnvProfileHaze("frozen", "#e3f2ff", 12, 0.14)
	_EnvProfileHaze("volcanic", "#b76f5e", 28, 0.34, 1.25)
	_EnvProfileHaze("coastal", "#d5ebf4", 20, 0.3, 1.15)
	_EnvProfileHaze("swamp", "#bdc99e", 34, 0.52, 1.35)
	_EnvProfileHaze("subterranean", "#b8b3c2", 26, 0.34, 1.2)
	_EnvProfileHaze("underwater", "#83bfd8", 46, 0.7, 1.45)
	_EnvProfileHaze("industrial", "#c6c2b8", 16, 0.2)
	_EnvProfileHaze("ethereal", "#e8dcff", 25, 0.38, 1.3)
	_EnvProfileHaze("void", "#9d8abe", 24, 0.28, 1.3)
	_EnvProfileHaze("toxic", "#bddb82", 34, 0.48, 1.35)
	_EnvProfileHaze("corrupted", "#c68aa9", 28, 0.4, 1.25)
	_EnvProfileMood("temperate", null, null, null, null, "fireflies")
	_EnvProfileMood("lush", 1.24, 0.035, 0.02, "leaves", "fireflies")
	_EnvProfileMood("arid", 1.24, 0.035, 0.16, "dust", null)
	_EnvProfileMood("frozen", 1.2, 0.03, -0.06, null, null)
	_EnvProfileMood("volcanic", 1.3, 0.05, 0.2, "ash", "ash")
	_EnvProfileMood("coastal", 1.18, 0.02, 0.03, null, "fireflies")
	_EnvProfileMood("swamp", 1.18, 0.045, 0.04, "motes", "fireflies")
	_EnvProfileMood("subterranean", 1.26, 0.055, 0.08, "motes", "motes")
	_EnvProfileMood("underwater", 1.15, 0.04, -0.12, "bubbles", "bubbles")
	_EnvProfileMood("industrial", 1.18, 0.04, 0.05, "motes", "motes")
	_EnvProfileMood("ethereal", 1.12, 0.015, -0.05, "motes", "motes")
	_EnvProfileMood("void", 1.3, 0.06, -0.08, null, null)
	_EnvProfileMood("toxic", 1.2, 0.04, -0.04, "motes", "fireflies")
	_EnvProfileMood("corrupted", 1.28, 0.05, -0.02, null, null)
	spawn(100)
		_EnvProfileLoop()
	return 1

proc/EnvProfile(area/A)
	if(!_env_profiles.len) _EnvProfileBoot()
	if(!A) return _env_profiles["default"]
	var/datum/environment_profile/P = _env_profiles[A.env_profile_id]
	return P || _env_profiles["default"]

proc/EnvProfileForClient(client/C, area/A)
	if(C && C.gfx_env_preview_id)
		var/datum/environment_profile/preview = _env_profiles[C.gfx_env_preview_id]
		if(preview) return preview
	return EnvProfile(A)

proc/EnvWeatherWetness(area/A)
	if(!A || !A.wx_kind) return 0
	switch(A.wx_kind)
		if("rain") return 0.65
		if("storm") return 1
		if("snow") return 0.25
		if("blizzard") return 0.35
	return 0

globalTracker
	var/tmp
		WIND_SCALE = 1
		WIND_AMPLITUDE = 9
		WIND_MIN_PX = 6
		WIND_MAX_PX = 24
		WIND_OVERRIDE = 0
		WIND_MAN_X = 0
		WIND_MAN_Y = 0
		WIND_WX_STORM = 2.4
		WIND_WX_BLIZZARD = 3
		WIND_WX_DUST = 2.6
		WIND_WX_PRECIP = 1.35

proc/EnvWeatherWindMult(area/A)
	if(!A || !A.wx_kind || !glob) return 1
	switch(A.wx_kind)
		if("storm") return glob.WIND_WX_STORM
		if("blizzard") return glob.WIND_WX_BLIZZARD
		if("dust") return glob.WIND_WX_DUST
		if("rain", "snow") return glob.WIND_WX_PRECIP
	return 1

proc/EnvWindForArea(area/A, datum/environment_profile/prof)
	if(glob && glob.WIND_OVERRIDE) return list(glob.WIND_MAN_X, glob.WIND_MAN_Y)
	var/datum/environment_profile/P = prof ? prof : EnvProfile(A)
	var/wx = EnvWeatherWindMult(A) * (glob ? glob.WIND_SCALE : 1) * (A ? A.zone_wind_mult : 1)
	return list(P.wind_x * wx, P.wind_y * wx)

proc/EnvAtmosphereFor(datum/environment_profile/P, area/A)
	var/color = P ? P.haze_color : "#d9e5ee"
	var/alpha = P ? P.haze_alpha : 0
	var/density = P ? P.haze_density : 0
	if(A && A.wx_kind)
		switch(A.wx_kind)
			if("rain")
				color = DnLerp(color, "#aebfd2", 0.4)
				alpha += 8
				density += 0.1
			if("storm")
				color = DnLerp(color, "#77899f", 0.55)
				alpha += 16
				density += 0.22
			if("snow")
				color = DnLerp(color, "#e3edf5", 0.45)
				alpha += 7
				density += 0.1
			if("blizzard")
				color = DnLerp(color, "#d6e5f1", 0.65)
				alpha += 24
				density += 0.3
			if("dust")
				color = DnLerp(color, "#bd8f58", 0.7)
				alpha += 28
				density += 0.34
	return list(color, clamp(alpha, 0, 72), clamp(density, 0, 1))

proc/GfxConfigureAtmosphere(client/C, datum/environment_profile/P, area/A, transition_time = 10)
	if(!C || !C.gfx_haze_grade || !C.gfx_haze_emitter) return
	var/list/H = EnvAtmosphereFor(P, A)
	var/haze_color = H[1]
	var/haze_alpha = H[2]
	var/haze_density = H[3]
	var/rank = GfxQualityRank(C)
	var/flat_scale = rank == GFX_QUALITY_LOW ? 0.5 : 0.72
	C.gfx_haze_grade.color = haze_color
	animate(C.gfx_haze_grade, alpha = round(haze_alpha * flat_scale), time = transition_time)
	if(!C.gfx_haze_emitter.particles)
		C.gfx_haze_emitter.particles = new /particles/gfx_haze
	var/cover_w = max(C.gfx_screen_cover_w, 34)
	var/cover_h = max(C.gfx_screen_cover_h, 26)
	var/key = "[P ? P.id : "default"]-[A ? A.wx_kind : null]-q[rank]-[cover_w]x[cover_h]"
	var/particle_scale = 0
	switch(rank)
		if(GFX_QUALITY_MEDIUM) particle_scale = 0.45
		if(GFX_QUALITY_HIGH) particle_scale = 0.8
		if(GFX_QUALITY_ULTRA) particle_scale = 1
	var/target_emitter_alpha = particle_scale > 0 ? round(haze_alpha * 1.55) : 0
	animate(C.gfx_haze_emitter, alpha = target_emitter_alpha, time = transition_time)
	if(C.gfx_haze_key == key) return
	C.gfx_haze_key = key
	var/particles/gfx_haze/GP = C.gfx_haze_emitter.particles
	var/pixel_w = max(1024, cover_w * world.icon_size)
	var/pixel_h = max(768, cover_h * world.icon_size)
	var/half_w = round(pixel_w / 2) + 128
	var/half_h = round(pixel_h / 2) + 96
	var/coverage = clamp((half_w * 2 * half_h * 2) / (1400 * 1000), 0.65, 3)
	var/live_count = round(210 * haze_density * particle_scale * coverage * GfxBudgetScale())
	GP.width = half_w * 2
	GP.height = half_h * 2
	GP.count = max(1, live_count)
	GP.spawning = live_count > 0 ? max(1, round(live_count / 120)) : 0
	var/zspread = round(120 * (P ? P.haze_depth : 1))
	GP.position = generator("box", list(-half_w,-half_h,-zspread), list(half_w,half_h,zspread))
	var/wx = C.gfx_env_wind_x * 0.22
	var/wy = C.gfx_env_wind_y * 0.12
	GP.velocity = generator("box", list(wx-0.25,wy-0.08,-0.2), list(wx+0.45,wy+0.2,0.2))
	GP.color = haze_color
	C.gfx_haze_emitter.filters = rank >= GFX_QUALITY_HIGH ? filter(type="blur", size=1.4) : null

proc/EnvUpdateClient(client/C, immediate = FALSE)
	if(!C || !C.mob) return
	GfxEnsureClient(C)
	var/turf/T = get_turf(C.mob)
	var/area/A = T ? T.loc : null
	var/datum/environment_profile/P = EnvProfileForClient(C, A)
	if(!P) return
	var/list/wind = EnvWindForArea(A, P)
	C.gfx_env_wind_x = wind[1]
	C.gfx_env_wind_y = wind[2]
	C.gfx_env_wetness = clamp(max(P.base_wetness, EnvWeatherWetness(A)), 0, 1)
	C.gfx_env_bloom_bias = P.bloom_bias
	var/qf = GfxQualityRank(C) == GFX_QUALITY_LOW ? 0.55 : 1
	var/target_alpha = round(P.grade_alpha * qf)
	var/grade_color = P.grade_color
	if(A && A.wx_kind)
		switch(A.wx_kind)
			if("storm")
				grade_color = DnLerp(grade_color, "#9aaac8", 0.42)
				target_alpha = min(90, target_alpha + 18)
			if("rain")
				grade_color = DnLerp(grade_color, "#b8c8df", 0.28)
				target_alpha = min(75, target_alpha + 9)
			if("snow", "blizzard") grade_color = DnLerp(grade_color, "#e6f2ff", 0.35)
			if("dust") grade_color = DnLerp(grade_color, "#d4aa72", 0.4)
	var/time = immediate ? 0 : 10
	if(Hd2dWorldBloomOn(C)) _Hd2dScanIndoor(C)
	var/lightclass = !A ? "none" : A.sees_sky ? "sky" : A.dark_cave ? "cave" : "bright"
	var/profile_key = "[P.id]-[A ? A.wx_kind : null]-q[GfxQualityRank(C)]-preview[C.gfx_env_preview_id]-[lightclass]"
	if(C.gfx_env_profile_id != profile_key)
		C.gfx_env_profile_id = profile_key
		animate(C.gfx_env_grade, color = grade_color, alpha = target_alpha, time = time)
		FxApplyBloom(C)
		if(C.hd2d_lightclass != lightclass)
			C.hd2d_lightclass = lightclass
			CpmApply(C)
		else
			Hd2dGradeShift(C, immediate ? 0 : 40)
	var/wet_alpha = GfxReflectionEnabled(C) ? round(C.gfx_env_wetness * 10) : 0
	animate(C.gfx_wet_sheen, alpha = wet_alpha, time = time)
	GfxConfigureAtmosphere(C, P, A, time)
	GfxApplyReflectionPass(C, A)
	GfxUpdateMoonlight(C, A, time)
	_Hd2dAmbientApply(C, P, A)
	Hd2dBloomRefresh(C) 

proc/GfxUpdateMoonlight(client/C, area/A, transition_time = 10)
	if(!C || !C.gfx_moon_fill) return
	var/k = (A && A.sees_sky) ? MoonEventK() : 0
	var/quality_scale = 1
	switch(GfxQualityRank(C))
		if(GFX_QUALITY_LOW) quality_scale = 0.6
		if(GFX_QUALITY_MEDIUM) quality_scale = 0.85
		if(GFX_QUALITY_ULTRA) quality_scale = 1.1
	C.gfx_moon_fill.color = glob.MOON_FILL_COLOR
	var/target_alpha = round(clamp(glob.MOON_FILL_ALPHA * k * quality_scale, 0, 40))
	animate(C.gfx_moon_fill, alpha = target_alpha, time = transition_time)

proc/_EnvProfileLoop()
	set waitfor = 0
	set background = 1
	while(1)
		for(var/client/C)
			EnvUpdateClient(C)
		sleep(10)

/mob/Admin2/verb/Environment_Profile_Info()
	set category = "Admin"
	set name = "Environment Profile Info"
	var/turf/T = get_turf(src)
	var/area/A = T ? T.loc : null
	var/datum/environment_profile/P = EnvProfileForClient(client, A)
	var/list/W = EnvWindForArea(A)
	src << "Area [A ? A.name : "none"] uses profile [P.display_name] ([P.id]); wind [round(W[1], 0.1)], [round(W[2], 0.1)], wetness [round(max(P.base_wetness, EnvWeatherWetness(A)), 0.01)], haze [P.haze_alpha]/[round(P.haze_density, 0.01)]."
	src << "DN: sees_sky [A ? A.sees_sky : "?"] | dn_indoor [A ? A.dn_indoor : "?"] | dark_cave [A ? A.dark_cave : "?"] | icon [A && A.icon ? "[A.icon]" : "none"] | color [A ? A.color : "?"] | bloom_t [client ? client.hd2d_bloom_t : "?"] (0 = off) | indoor_seen [client ? client.hd2d_indoor_seen : "?"] sky_seen [client ? client.hd2d_sky_seen : "?"] shaft_add [client ? client.hd2d_shaft_add : "?"]"

/mob/Admin2/verb/Set_Area_Environment_Profile()
	set category = "Mapper"
	set name = "Set Area Environment Profile"
	var/turf/T = get_turf(src)
	var/area/A = T ? T.loc : null
	if(!A)
		src << "No area here."
		return
	var/list/options = list()
	for(var/id in _env_profiles)
		var/datum/environment_profile/EP = _env_profiles[id]
		options["[EP.display_name] ([id])"] = id
	var/choice = input(src, "Assign a profile to AREA [A.name] ([A.type]). Session-only until pinned in code.", "Area Environment") as null|anything in options
	if(!choice) return
	if(istype(A, /area/MapperZone))
		var/area/MapperZone/MZ = A
		BuildZonesLoad()
		var/datum/build_zone_def/ZD = zoneDefsByUid[MZ.zoneKey]
		if(!ZD)
			ZD = zoneDefsByName[MZ.zoneKey]
		if(!ZD)
			src << "This mapper zone has no registry entry; use Zone_Settings instead."
			return
		if(ZD.creator != src.ckey && !src:Admin)
			src << "Zone \"[ZD.name]\" belongs to [ZD.creator] - only they (or an Admin) can change it."
			return
		ZD.profile = options[choice]
		BuildZoneApply(ZD)
		BuildZonesSave()
		src << "Zone \"[ZD.name]\" -> [options[choice]] (persists across reboots)."
		Log("Admin", "[ExtractInfo(src)] set zone \"[ZD.name]\" env profile to [options[choice]].")
		return
	A.env_profile_id = options[choice]
	BuildZoneProfileRecord(A.type, options[choice])
	for(var/client/CC)
		CC.gfx_env_profile_id = null
	src << "[A.name] -> [options[choice]] (persists across reboots)."
	Log("Admin", "[ExtractInfo(src)] set area env profile of [A.type] to [options[choice]].")

/mob/Admin2/verb/Preview_Environment_Profile()
	set category = "Admin"
	set name = "Preview Environment Profile"
	if(!client) return
	var/list/options = list("Map Default")
	for(var/id in _env_profiles)
		var/datum/environment_profile/P = _env_profiles[id]
		options["[P.display_name] ([id])"] = id
	var/choice = input(src, "Preview a generic profile for your client only. This does not assign or alter the current area.", "Environment Preview") in options + "Cancel"
	if(choice == "Cancel") return
	client.gfx_env_preview_id = choice == "Map Default" ? null : options[choice]
	client.gfx_env_profile_id = null
	client.gfx_haze_key = null
	client.gfx_reflection_filter_key = null
	EnvUpdateClient(client, TRUE)
	src << "Environment preview: [client.gfx_env_preview_id || "map default"]."

proc/EnvWindRefresh()
	for(var/client/C)
		EnvUpdateClient(C, TRUE)

proc/EnvWindReport(area/A)
	var/list/W = EnvWindForArea(A)
	var/mag = sqrt(W[1] * W[1] + W[2] * W[2])
	var/dir = mag > 0.001 ? round(arctan(W[1], W[2])) : 0
	return "strength [round(mag, 0.01)] dir [dir]deg (x [round(W[1], 0.01)], y [round(W[2], 0.01)])"

/mob/Admin2/verb/Wind_Control()
	set category = "Admin"
	set name = "Wind Control"
	var/turf/T = get_turf(src)
	var/area/A = T ? T.loc : null
	var/list/opts = list("Global scale", "Sway amplitude", "Manual wind (override)",
	                     "Clear override (back to auto)", "Weather multipliers", "Show current wind")
	var/pick = input(src, "Wind here: [EnvWindReport(A)]") as null|anything in opts
	if(!pick) return
	switch(pick)
		if("Global scale")
			var/s = input(src, "Global wind scale (1 = normal, 0 = still, 3 = gale)?") as num|null
			if(s == null) return
			glob.WIND_SCALE = clamp(s, 0, 10)
			src << "Global wind scale -> [glob.WIND_SCALE]."
		if("Sway amplitude")
			var/amp = input(src, "Max foliage sway in degrees (current [glob.WIND_AMPLITUDE]; 0 = still, 9 = default, 25 = wild)?") as num|null
			if(amp == null) return
			glob.WIND_AMPLITUDE = clamp(amp, 0, 45)
			src << "Sway amplitude -> [glob.WIND_AMPLITUDE] degrees."
		if("Manual wind (override)")
			var/mag = input(src, "Wind strength (0-10; profile values are ~0.5-3)?") as num|null
			if(mag == null) return
			var/dir = input(src, "Direction in degrees (0 = east, 90 = north)?") as num|null
			if(dir == null) return
			mag = clamp(mag, 0, 10)
			glob.WIND_MAN_X = mag * cos(dir)
			glob.WIND_MAN_Y = mag * sin(dir)
			glob.WIND_OVERRIDE = 1
			src << "Manual wind ON: [EnvWindReport(A)]."
		if("Clear override (back to auto)")
			glob.WIND_OVERRIDE = 0
			src << "Manual wind OFF - profile + weather again: [EnvWindReport(A)]."
		if("Weather multipliers")
			var/k = input(src, "Which weather?") as null|anything in list("storm", "blizzard", "dust", "rain/snow")
			if(!k) return
			var/cur = k == "storm" ? glob.WIND_WX_STORM : k == "blizzard" ? glob.WIND_WX_BLIZZARD : \
			          k == "dust" ? glob.WIND_WX_DUST : glob.WIND_WX_PRECIP
			var/v = input(src, "[k] wind multiplier (current [cur])?") as num|null
			if(v == null) return
			v = clamp(v, 0, 10)
			switch(k)
				if("storm") glob.WIND_WX_STORM = v
				if("blizzard") glob.WIND_WX_BLIZZARD = v
				if("dust") glob.WIND_WX_DUST = v
				else glob.WIND_WX_PRECIP = v
			src << "[k] wind multiplier -> [v]."
		if("Show current wind")
			src << "Area [A ? A.name : "?"] ([A ? (A.wx_kind || "clear") : "?"]): [EnvWindReport(A)]"
			src << "scale [glob.WIND_SCALE] | override [glob.WIND_OVERRIDE ? "ON" : "off"] | storm [glob.WIND_WX_STORM] blizzard [glob.WIND_WX_BLIZZARD] dust [glob.WIND_WX_DUST] rain/snow [glob.WIND_WX_PRECIP]"
			return
	EnvWindRefresh()
	Log("Admin", "[ExtractInfo(src)] wind control: [pick].")
