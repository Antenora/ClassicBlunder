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
	//depth projection so the motes drift at different apparent speeds
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

area
	var/env_profile_id = "default"

//maps opt areas into profiles later; everything defaults to neutral for now

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

proc/EnvWindForArea(area/A)
	var/datum/environment_profile/P = EnvProfile(A)
	var/wx = 1
	if(A)
		switch(A.wx_kind)
			if("storm") wx = 2.4
			if("blizzard") wx = 3
			if("dust") wx = 2.6
			if("rain", "snow") wx = 1.35
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
	var/list/wind = list(P.wind_x, P.wind_y)
	if(A && A.wx_kind)
		var/wind_mult = 1
		switch(A.wx_kind)
			if("storm") wind_mult = 2.4
			if("blizzard") wind_mult = 3
			if("dust") wind_mult = 2.6
			if("rain", "snow") wind_mult = 1.35
		wind[1] *= wind_mult
		wind[2] *= wind_mult
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
	var/profile_key = "[P.id]-[A ? A.wx_kind : null]-q[GfxQualityRank(C)]-preview[C.gfx_env_preview_id]"
	if(C.gfx_env_profile_id != profile_key)
		C.gfx_env_profile_id = profile_key
		animate(C.gfx_env_grade, color = grade_color, alpha = target_alpha, time = time)
		FxApplyBloom(C)
	var/wet_alpha = GfxReflectionEnabled(C) ? round(C.gfx_env_wetness * 10) : 0
	animate(C.gfx_wet_sheen, alpha = wet_alpha, time = time)
	GfxConfigureAtmosphere(C, P, A, time)
	GfxApplyReflectionPass(C, A)
	GfxUpdateMoonlight(C, A, time)

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
