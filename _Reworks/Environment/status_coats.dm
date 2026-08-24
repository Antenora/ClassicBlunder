globalTracker
	var/tmp
		STATUS_COATS = TRUE
		COAT_RANGE = 16

mob
	var/tmp
		coat_key
		coat_i = 0
		obj/coat_bleed_drip/coat_drip
		obj/coat_fx/coat_fx

var/list/_coat_tex

proc/_CoatCanvas()
	var/icon/I = new('sandstorm.dmi')
	I.DrawBox(rgb(0, 0, 0, 0), 1, 1, 32, 32)
	return I

proc/_CoatHash(n)
	return (n * 73 + (n * n) % 47) % 100

proc/_CoatBakeTextures()
	if(_coat_tex) return
	_coat_tex = list()
	var/icon/I
	var/n
	I = _CoatCanvas()
	for(n = 1, n <= 10, n++)
		var/x = 6 + _CoatHash(n) % 20
		var/y = 5 + _CoatHash(n + 31) % 22
		I.DrawBox(rgb(225, 245, 255, 235), x, y)
		I.DrawBox(rgb(225, 245, 255, 180), x + 1, y)
		I.DrawBox(rgb(225, 245, 255, 180), x - 1, y)
		I.DrawBox(rgb(225, 245, 255, 180), x, y + 1)
		I.DrawBox(rgb(225, 245, 255, 180), x, y - 1)
	_coat_tex["chill"] = I
	I = _CoatCanvas()
	for(n = 1, n <= 9, n++)
		var/x = 8 + _CoatHash(n + 7) % 17
		var/y = 3 + _CoatHash(n + 53) % 13
		I.DrawBox(rgb(255, 220, 120, 255), x, y)
		I.DrawBox(rgb(255, 140, 40, 230), x, y + 1)
		I.DrawBox(rgb(255, 140, 40, 200), x + (_CoatHash(n) % 3) - 1, y + 2)
	_coat_tex["burn"] = I
	var/icon/TND
	for(var/f = 1, f <= 4, f++)
		I = _CoatCanvas()
		var/salt = f * 13 + 3
		for(n = 1, n <= 3, n++)
			var/x = 8 + _CoatHash(n * salt) % 15
			var/y = 26 - _CoatHash(n * salt + 5) % 18
			for(var/k = 1, k <= 6, k++)
				I.DrawBox(rgb(255, 250, 170, 255), x, y)
				if(_CoatHash(n * salt + k) > 55) I.DrawBox(rgb(255, 245, 120, 160), x + 1, y)
				x += (_CoatHash(n * salt + k) % 5) - 2
				y -= 1 + _CoatHash(n * salt + k + 9) % 2
				if(y < 2) break
		if(f == 1)
			TND = I
		else
			TND.Insert(I, "", SOUTH, f, 0, 2)
	_coat_tex["tendrils"] = TND
	I = _CoatCanvas()
	for(n = 1, n <= 6, n++)
		var/x = 9 + _CoatHash(n + 11) % 15
		var/y = 3
		for(var/k = 1, k <= 5 + _CoatHash(n) % 3, k++)
			I.DrawBox(rgb(60, 10, 80, 230), x, y)
			x += (_CoatHash(n * 7 + k) % 3) - 1
			y += 2 + _CoatHash(n + k) % 2
	_coat_tex["doom"] = I
	I = _CoatCanvas()
	for(n = 1, n <= 8, n++)
		var/x = 7 + _CoatHash(n + 19) % 19
		var/y = 6 + _CoatHash(n + 41) % 21
		I.DrawBox(rgb(140, 230, 60, 220), x, y)
		if(_CoatHash(n) > 50) I.DrawBox(rgb(90, 180, 40, 180), x + 1, y)
	_coat_tex["poison"] = I
	I = _CoatCanvas()
	for(n = 1, n <= 3, n++)
		var/cx = 10 + _CoatHash(n * 13) % 12
		var/cy = 8 + _CoatHash(n * 29) % 16
		for(var/k = 1, k <= 4, k++)
			var/x = cx
			var/y = cy
			var/dx = (_CoatHash(n * k + 3) % 3) - 1
			var/dy = (_CoatHash(n * k + 8) % 3) - 1
			if(!dx && !dy) dx = 1
			for(var/s = 1, s <= 4 + _CoatHash(k) % 3, s++)
				I.DrawBox(rgb(235, 235, 245, 210), x, y)
				x += dx
				y += dy
	_coat_tex["shatter"] = I
	I = _CoatCanvas()
	for(n = 1, n <= 5, n++)
		var/x = 8 + _CoatHash(n + 23) % 16
		var/y = 6 + _CoatHash(n + 61) % 19
		I.DrawBox(rgb(90, 0, 10, 160), x, y)
		I.DrawBox(rgb(90, 0, 10, 120), x + 1, y)
		I.DrawBox(rgb(90, 0, 10, 120), x, y + 1)
	_coat_tex["frenzy"] = I

proc/_CoatTint(r, g, b, i)
	var/ir = 1 + (r - 1) * i
	var/ig = 1 + (g - 1) * i
	var/ib = 1 + (b - 1) * i
	return list(ir,0,0,0, 0,ig,0,0, 0,0,ib,0, 0,0,0,1, 0,0,0,0)

proc/_CoatFor(mob/M)
	if(M.Stasis > 0) return list(1, null, "#78f0ff", 0.7, 0.95, 1.25, "stasis")
	if(M.Doomed > 0) return list(min(1, M.Doomed / 5), "doom", "#8c3cc8", 0.8, 0.62, 0.95, "doom")
	if(M.Frenzy > 0) return list(min(1, M.Frenzy / 5), "frenzy", "#ff2828", 1.3, 0.62, 0.62, "frenzy")
	if(M.Slow > 0) return list(min(1, M.Slow / 10), "chill", "#aadcff", 0.72, 0.92, 1.42, "chill")
	var/vb = max(0, M.Burn - M.SilentBurnAmount)
	if(vb > 0) return list(min(1, vb / 15), null, "#ff781e", 0.62, 0.5, 0.46, "burn")
	if(M.Shock > 0) return list(min(1, M.Shock / 10), null, "#fff578", 1.05, 1.05, 0.9, "shock")
	var/vp = max(0, M.Poison - M.SilentPoisonAmount)
	if(vp > 0) return list(min(1, vp / 15), "poison", "#78dc3c", 0.82, 1.12, 0.72, "poison")
	if(M.Shatter > 0) return list(min(1, M.Shatter / 10), "shatter", null, 0.92, 0.92, 0.98, "shatter")
	if(M.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Charmed)) return list(1, null, "#ff82c8", 1.18, 0.85, 1.02, "charmed")
	if(M.Bleed > 0) return list(min(1, M.Bleed / 15), null, null, 1.0, 0.82, 0.82, "bleed")
	return null

proc/_CoatStrip(mob/M)
	for(var/nm in list("coat_tint", "coat_tex", "coat_rim"))
		var/F = M.filters[nm]
		if(F) M.filters -= F
	M.coat_key = null
	M.coat_i = 0

proc/_CoatApply(mob/M, list/C)
	var/key = C[7]
	var/i = C[1]
	var/aura = MobAuraActive(M)
	var/skey = aura ? "[key]:a" : key
	if(aura) i *= 0.5
	if(M.coat_key == skey && abs(M.coat_i - i) < 0.1 && M.filters["coat_tint"])
		return
	_CoatStrip(M)
	M.coat_key = skey
	M.coat_i = i
	M.filters += filter(name = "coat_tint", type = "color", color = _CoatTint(C[4], C[5], C[6], i))
	if(!aura)
		if(C[2] && _coat_tex && _coat_tex[C[2]])
			M.filters += filter(name = "coat_tex", type = "layer", icon = _coat_tex[C[2]], blend_mode = BLEND_INSET_OVERLAY, color = "#ffffff")
		if(C[3])
			var/list/rc = _FxRGB(C[3])
			if(rc)
				M.filters += filter(name = "coat_rim", type = "outline", size = 1, color = rgb(rc[1], rc[2], rc[3], 90 + round(120 * i)))
		_CoatAnimate(M, key)

proc/_CoatAnimate(mob/M, key)
	var/F = M.filters["coat_tex"]
	var/R = M.filters["coat_rim"]
	switch(key)
		if("burn")
			if(R)
				animate(R, color = rgb(255, 120, 30, 200), time = 5, loop = -1, easing = SINE_EASING)
				animate(color = rgb(255, 120, 30, 110), time = 5, easing = SINE_EASING)
		if("doom")
			if(F)
				animate(F, color = rgb(190, 140, 255, 255), time = 12, loop = -1, easing = SINE_EASING)
				animate(color = "#ffffff", time = 12, easing = SINE_EASING)
			if(R)
				animate(R, color = rgb(140, 60, 200, 60), time = 12, loop = -1, easing = SINE_EASING)
				animate(color = rgb(140, 60, 200, 200), time = 12, easing = SINE_EASING)
		if("frenzy")
			if(R)
				animate(R, color = rgb(255, 40, 40, 240), time = 3, loop = -1)
				animate(color = rgb(255, 40, 40, 80), time = 3)
			if(F)
				animate(F, color = rgb(255, 255, 255, 120), time = 4, loop = -1, easing = SINE_EASING)
				animate(color = "#ffffff", time = 4, easing = SINE_EASING)
		if("poison")
			if(F)
				animate(F, color = rgb(200, 255, 160, 110), time = 8, loop = -1, easing = SINE_EASING)
				animate(color = "#ffffff", time = 8, easing = SINE_EASING)
		if("chill")
			if(F)
				animate(F, color = rgb(255, 255, 255, 120), time = 9, loop = -1, easing = SINE_EASING)
				animate(color = "#ffffff", time = 9, easing = SINE_EASING)
		if("charmed")
			if(R)
				animate(R, color = rgb(255, 130, 200, 70), time = 8, loop = -1, easing = SINE_EASING)
				animate(color = rgb(255, 130, 200, 210), time = 8, easing = SINE_EASING)

/obj/coat_fx
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	appearance_flags = KEEP_APART
	plane = 0
	layer = 5
	blend_mode = BLEND_ADD
	var/tmp/fx_key

var/list/_coat_fx_pools = list("burn" = list(), "shock" = list())

proc/_CoatFxOn(mob/M, key, i)
	if(M.coat_fx && M.coat_fx.fx_key == key)
		if(key == "burn" && M.coat_fx.particles) M.coat_fx.particles.spawning = 0.5 + i * 1.5
		return
	_CoatFxOff(M)
	var/list/pool = _coat_fx_pools[key]
	var/obj/coat_fx/D
	if(pool.len)
		D = pool[pool.len]
		pool.len--
	else
		D = new
		D.fx_key = key
		if(key == "burn")
			var/particles/P = new
			P.width = 40
			P.height = 52
			P.icon = _hd2d_ember_icon
			P.position = generator("box", list(-7, -6, 0), list(7, 12, 0))
			P.velocity = generator("vector", list(-0.25, 0.5, 0), list(0.25, 1.5, 0))
			P.drift = generator("sphere", 0, 0.35)
			P.lifespan = generator("num", 7, 11)
			P.fade = 5
			P.fadein = 2
			P.scale = generator("num", 0.3, 0.55)
			P.spawning = 0
			D.particles = P
			D.color = "#ff9a3c"
		else
			D.icon = _coat_tex["tendrils"]
			D.color = "#fff578"
			D.pixel_x = 0
	if(glob.MULTIPLY_REVEAL) D.plane = LIGHTING_PLANE
	else D.plane = 0
	M.vis_contents += D
	M.coat_fx = D
	if(key == "burn")
		D.particles.spawning = 0.5 + i * 1.5
	else
		D.alpha = 230
		animate(D, alpha = 110, time = 2, loop = -1)
		animate(alpha = 230, time = 2)

proc/_CoatFxOff(mob/M)
	if(!M.coat_fx) return
	var/obj/coat_fx/D = M.coat_fx
	if(D.particles) D.particles.spawning = 0
	M.vis_contents -= D
	var/list/pool = _coat_fx_pools[D.fx_key]
	if(pool) pool += D
	M.coat_fx = null

/obj/coat_bleed_drip
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	appearance_flags = KEEP_APART
	plane = 0
	layer = 5
	color = "#a01018"

var/list/_coat_drip_pool = list()

proc/_CoatDripOn(mob/M, i)
	if(!_hd2d_ember_icon) return
	if(!M.coat_drip)
		var/obj/coat_bleed_drip/D
		if(_coat_drip_pool.len)
			D = _coat_drip_pool[_coat_drip_pool.len]
			_coat_drip_pool.len--
		else
			D = new
		if(!D.particles)
			var/particles/P = new
			P.width = 40
			P.height = 44
			P.icon = _hd2d_ember_icon
			P.position = generator("box", list(-8, -4, 0), list(8, 18, 0))
			P.velocity = generator("vector", list(-0.3, -0.5, 0), list(0.3, -1.5, 0))
			P.gravity = list(0, -1.2)
			P.lifespan = generator("num", 6, 10)
			P.fade = 5
			P.scale = generator("num", 0.35, 0.6)
			P.spawning = 0
			D.particles = P
		M.vis_contents += D
		M.coat_drip = D
	M.coat_drip.particles.spawning = 0.4 + i * 1.2

proc/_CoatDripOff(mob/M)
	if(!M.coat_drip) return
	M.coat_drip.particles.spawning = 0
	M.vis_contents -= M.coat_drip
	_coat_drip_pool += M.coat_drip
	M.coat_drip = null

proc/_CoatSweep()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.STATUS_COATS)
			var/list/seen = list()
			for(var/mob/Players/P in players)
				if(!P.client) continue
				for(var/mob/M in range(glob.COAT_RANGE, P))
					if(seen[M]) continue
					seen[M] = 1
					try
						var/list/C = _CoatFor(M)
						if(C)
							_CoatApply(M, C)
							if(C[7] == "burn" || C[7] == "shock")
								_CoatFxOn(M, C[7], C[1])
							else if(M.coat_fx)
								_CoatFxOff(M)
						else
							if(M.coat_key) _CoatStrip(M)
							if(M.coat_fx) _CoatFxOff(M)
						if(M.Bleed > 0)
							_CoatDripOn(M, min(1, M.Bleed / 15))
						else if(M.coat_drip)
							_CoatDripOff(M)
					catch
						continue
		sleep(10)

var/_coat_boot = _CoatBoot()
proc/_CoatBoot()
	spawn(90)
		_CoatBakeTextures()
		_CoatSweep()
	return 1

/mob/Admin2/verb/Status_Coats_Toggle()
	set category = "Admin"
	set name = "Status Coats Toggle"
	glob.STATUS_COATS = !glob.STATUS_COATS
	if(!glob.STATUS_COATS)
		for(var/mob/M in world)
			if(M.coat_key) _CoatStrip(M)
			if(M.coat_drip) _CoatDripOff(M)
			if(M.coat_fx) _CoatFxOff(M)
	src << "Status coats: [glob.STATUS_COATS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set status coats to [glob.STATUS_COATS].")

/mob/Admin2/verb/Coat_Test(t as text)
	set category = "Admin"
	set name = "Coat Test"
	switch(t)
		if("chill") Slow = 10
		if("burn") Burn = 15
		if("shock") Shock = 10
		if("doom") Doomed = 5
		if("stasis") Stasis = 10
		if("poison") Poison = 15
		if("shatter") Shatter = 10
		if("frenzy") Frenzy = 5
		if("bleed") Bleed = 15
		if("clear")
			Slow = 0
			Burn = 0
			Shock = 0
			Doomed = 0
			Stasis = 0
			Poison = 0
			Shatter = 0
			Frenzy = 0
			Bleed = 0
	src << "Coat test: [t] (sweeps in within a second)."
