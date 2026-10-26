globalTracker/var/tmp
	BEAMFX_LOG = FALSE

var/list/BEAMFX_DIRS = list("E", "NE", "N", "NW", "W", "SW", "S", "SE")
var/beamfx_seed = 0
var/beamfx_cost = 0
var/beamfx_cost_n = 0

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
