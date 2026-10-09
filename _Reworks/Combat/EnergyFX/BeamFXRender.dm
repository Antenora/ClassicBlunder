/obj/energyfx/var/tmp/fx_bx = 0
/obj/energyfx/var/tmp/fx_by = 0

/datum/beamfx/var/list/ovl_cache = list()
/datum/beamfx/var/list/spk_em
/datum/beamfx/var/spk_mode = 0
/datum/beamfx/var/spk_x = 0
/datum/beamfx/var/spk_y = 0
/datum/beamfx/var/spk_str = -1
/datum/beamfx/var/spk_k = -1
/datum/beamfx/var/list/spk_live = list()
/datum/beamfx/var/log_tag = ""

proc/BeamFXXform(list/sp, bx, by)
	var/a = sp[BFX_ANG]
	var/p = sp[BFX_PRE]
	var/ca = cos(a)
	var/sa = sin(a)
	var/cp = cos(p)
	var/spp = sin(p)
	var/sx = sp[BFX_SX]
	var/sy = sp[BFX_SY]
	return matrix(ca * sx * cp - sa * sy * spp, -ca * sx * spp - sa * sy * cp, sp[BFX_X] - bx, sa * sx * cp + ca * sy * spp, -sa * sx * spp + ca * sy * cp, sp[BFX_Y] - by)

proc/EnergyFXPlace(obj/energyfx/O, x, y, zz)
	if(O.fx_car) return 0
	var/tx = floor(x / 32) + 1
	var/ty = floor(y / 32) + 1
	if(tx < 1 || ty < 1 || tx > world.maxx || ty > world.maxy) return 0
	var/turf/T = locate(tx, ty, zz)
	if(!T) return 0
	O.loc = T
	O.step_x = 0
	O.step_y = 0
	O.fx_bx = (tx - 1) * 32 + O.fx_w / 2
	O.fx_by = (ty - 1) * 32 + O.fx_h / 2
	return 1

proc/BeamFXCool(a)
	return 0.3 + 0.7 * (clamp(a, 0, 1) ** 0.8)

/datum/beamfx/proc/StateOf(list/sp)
	if(sp[BFX_LIGHT]) return "l[sp[BFX_ST]]"
	return grey ? "g[sp[BFX_ST]]" : "p[sp[BFX_ST]]"

/datum/beamfx/var/list/col_cache = list()

/datum/beamfx/proc/ColorOf(list/sp)
	var/tag = sp[BFX_TAG]
	var/li = sp[BFX_LIGHT]
	var/dyn = li ? (tag == "accent" || tag == "wl") : (grey ? (tag == "p" || tag == "ring" || tag == "ring_c" || tag == "arc") : (tag == "p" || tag == "ring" || tag == "ring_c"))
	var/ck = dyn ? "[li][tag][round(clamp(sp[BFX_ALPHA], 0, 1) * 255, 1)]|[(grey && !li) ? round(clamp(sp[BFX_FADE], 0, 1) * 255, 1) : 0]" : "[li][tag]"
	var/list/cached = col_cache[ck]
	if(cached) return cached
	var/list/res = ColorCalc(sp, dyn ? round(clamp(sp[BFX_ALPHA], 0, 1) * 255, 1) / 255 : sp[BFX_ALPHA], (grey && !li && dyn) ? round(clamp(sp[BFX_FADE], 0, 1) * 255, 1) / 255 : sp[BFX_FADE])
	if(col_cache.len < 1024)
		col_cache += ck
		col_cache[ck] = res
	return res

/datum/beamfx/proc/ColorCalc(list/sp, a, fdv)
	var/tag = sp[BFX_TAG]
	var/list/lc = ramp[1]
	var/list/edge = ramp[2]
	var/list/core = ramp[3]
	var/list/lcore = ramp[4]
	if(sp[BFX_LIGHT])
		var/k = (tag == "accent" || tag == "wl") ? BeamFXCool(a) : 1
		var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : 1
		var/g = (grey ? 0.35 : 1) / ls
		return list((lcore[1] - lc[1]) * k * g, (lcore[2] - lc[2]) * k * g, (lcore[3] - lc[3]) * k * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
	if(grey)
		if(tag == "p" || tag == "ring" || tag == "ring_c" || tag == "arc")
			var/fd = clamp(fdv, 0, 1)
			var/base = (fd > 0.001) ? min(1, a / fd) : 0
			var/t_ = 0.3 + (1 - fd) * 0.55
			var/rk = (tag == "ring") ? 1.6 : ((tag == "ring_c") ? 0.8 : 1)
			var/m = base * rk / 0.18
			return list(1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, m, 0, 0, 0, -t_ * m)
		return list(1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	var/kp = (tag == "p" || tag == "ring" || tag == "ring_c") ? BeamFXCool(a) : 1
	return list((core[1] - edge[1]) * kp, (core[2] - edge[2]) * kp, (core[3] - edge[3]) * kp, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, edge[1], edge[2], edge[3], 0)

/datum/beamfx/proc/AlphaOf(list/sp)
	if(!sp[BFX_LIGHT] && grey)
		var/tag = sp[BFX_TAG]
		if(tag == "p" || tag == "ring" || tag == "ring_c" || tag == "arc") return 255
	return clamp(sp[BFX_ALPHA] * 255, 0, 255)

/datum/beamfx/proc/LightOverlay(list/sp, pr)
	var/key = "[sp[BFX_FAM]]|[sp[BFX_ST]]|[round(pr, 0.0001)]"
	var/image/I = ovl_cache[key]
	if(!I)
		var/list/fam = BEAMFX_FAM[sp[BFX_FAM]]
		var/list/lc = ramp[1]
		var/list/lcore = ramp[4]
		var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : 1
		var/g = (grey ? 0.35 : 1) / ls * pr
		I = image(icon = fam[1], icon_state = "l[sp[BFX_ST]]")
		I.plane = ENERGYFX_LIGHT_PLANE
		I.blend_mode = BLEND_ADD
		I.appearance_flags = RESET_COLOR
		I.color = list((lcore[1] - lc[1]) * g, (lcore[2] - lc[2]) * g, (lcore[3] - lc[3]) * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
		ovl_cache[key] = I
	return I

/datum/beamfx/proc/NewObj(list/sp, pr = 0)
	var/obj/energyfx/O = EnergyFXGet(sp[BFX_LIGHT] ? /obj/energyfx/light : /obj/energyfx/paint, src)
	if(!O) return null
	var/list/fam = BEAMFX_FAM[sp[BFX_FAM]]
	O.icon = fam[1]
	O.fx_w = fam[2]
	O.fx_h = fam[3]
	O.icon_state = StateOf(sp)
	O.layer = sp[BFX_ZL]
	if(!EnergyFXPlace(O, sp[BFX_X], sp[BFX_Y], z))
		EnergyFXFree(O)
		return null
	O.transform = BeamFXXform(sp, O.fx_bx, O.fx_by)
	O.color = ColorOf(sp)
	O.alpha = 0
	if(pr > 0) O.overlays += LightOverlay(sp, pr)
	return O

/datum/bfx_slot/var/dv = -1
/datum/bfx_slot/var/shown = 0

/datum/beamfx/proc/SlotStep(datum/bfx_slot/SL, w, started, delay_first, hold_pre)
	var/obj/energyfx/O = SL.obj
	if(started && hold_pre > 0) animate(transform = BeamFXXform(SL.last, O.fx_bx, O.fx_by), time = hold_pre)
	if(w == "hide")
		if(!started) animate(O, alpha = 0, time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN)
		else animate(alpha = 0, time = 0.25, easing = JUMP_EASING | EASE_IN)
		SL.shown = 0
	else
		var/list/sp = w
		var/st = StateOf(sp)
		if(!started) animate(O, transform = BeamFXXform(sp, O.fx_bx, O.fx_by), alpha = AlphaOf(sp), color = ColorOf(sp), icon_state = st, time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		else animate(transform = BeamFXXform(sp, O.fx_bx, O.fx_by), alpha = AlphaOf(sp), color = ColorOf(sp), icon_state = st, time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		SL.st = st
		SL.last = sp
		SL.shown = 1
	energyfx_anim_n++

/datum/beamfx/proc/Realize()
	var/list/F1 = frame_specs[1]
	var/list/F2 = frame_specs[2]
	var/f1 = 2 * k
	var/list/hl = Holds()
	var/v1 = Q(f1, hl)
	var/v2 = Q(f1 + 1, hl)
	if(logging) world.log << "BFXQ[log_tag] [f1] [v1] [v2]"
	var/list/keys = list()
	for(var/key in F1) keys[key] = 1
	for(var/key in F2) keys[key] = 1
	for(var/key in slots) keys[key] = 1
	for(var/key in keys)
		var/list/s1 = F1[key]
		var/list/s2 = F2[key]
		var/list/first = s1 ? s1 : s2
		if(first && first[BFX_PR] < 0) continue
		var/datum/bfx_slot/SL = slots[key]
		var/list/want = list()
		for(var/si = 1 to 2)
			var/v = (si == 1) ? v1 : v2
			if(si == 2 && v2 == v1)
				want += list(null)
			else if(v < f1)
				want += list((SL && SL.dv == v) ? null : "hide")
			else
				var/list/sp = (v == f1) ? s1 : s2
				want += list(sp ? sp : "hide")
		if(!SL)
			var/list/fs
			for(var/w in want)
				if(islist(w))
					fs = w
					break
			if(!fs) continue
			var/obj/energyfx/NO = NewObj(fs, fs[BFX_PR])
			if(!NO) continue
			SL = new
			SL.obj = NO
			SL.fam = fs[BFX_FAM]
			SL.light = fs[BFX_LIGHT]
			SL.st = NO.icon_state
			SL.last = fs
			SL.pr = fs[BFX_PR]
			slots[key] = SL
		var/obj/energyfx/O = SL.obj
		if(first && O.layer != first[BFX_ZL]) O.layer = first[BFX_ZL]
		for(var/si = 1 to 2)
			if(want[si] == "hide" && !SL.shown) want[si] = null
		var/started = 0
		var/list/ref
		for(var/w in want)
			if(islist(w))
				var/list/ws = w
				if(abs(ws[BFX_X] - O.fx_bx) > 48 || abs(ws[BFX_Y] - O.fx_by) > 48) ref = ws
		if(ref && EnergyFXPlace(O, ref[BFX_X], ref[BFX_Y], z))
			animate(O, transform = BeamFXXform(SL.last, O.fx_bx, O.fx_by), time = 0, flags = ANIMATION_END_NOW)
			started = 1
			energyfx_anim_n++
		var/skip1 = isnull(want[1])
		if(!skip1)
			SlotStep(SL, want[1], started, 0, 0)
			started = 1
		if(!isnull(want[2]))
			SlotStep(SL, want[2], started, skip1 ? 0.25 : 0, (started && skip1) ? 0.25 : 0)
			started = 1
		SL.dv = v2
		if(!s1 && !s2 && !SL.shown)
			SL.idle++
			if(SL.idle >= 3)
				EnergyFXFree(SL.obj)
				slots -= key
		else
			SL.idle = 0

/datum/beamfx/proc/ChainPair(datum/bfx_obj/o)
	if(grey) return 0
	switch(o.kind)
		if("shard", "lance") return 1 / 0.8
		if("tongue") return 0.85 / 0.8
		if("arc") return 0.9 / 0.85
		if("rarc") return clash_mode ? 0.85 / 0.5 : 1 / 0.62
	return 0

/datum/beamfx/proc/ChainBuild(datum/bfx_obj/o, c, obj/energyfx/O, from_f, list/hl)
	var/list/specs = o.pre_specs
	var/last_f = o.pre_f0 + specs.len - 1
	var/i = from_f
	var/curv = -1000000
	var/dur = 0
	var/list/cur
	var/started = 0
	var/n = 0
	while(i - from_f < 400)
		var/v = Q(i, hl)
		if(v > last_f) break
		if(v != curv)
			if(dur > 0)
				ChainStep(O, cur, dur, started)
				started = 1
				n++
			curv = v
			cur = null
			if(v >= o.pre_f0)
				var/list/pair = specs[v - o.pre_f0 + 1]
				if(pair) cur = pair[c]
			dur = 0
		dur += 0.25
		i++
	if(dur > 0)
		ChainStep(O, cur, dur, started)
		started = 1
		n++
	if(started) animate(alpha = 0, time = 0.25, easing = JUMP_EASING | EASE_IN)
	else animate(O, alpha = 0, time = 0.25, easing = JUMP_EASING | EASE_IN)
	energyfx_anim_n += n + 1
	return i - from_f

/datum/beamfx/proc/ChainStep(obj/energyfx/O, list/sp, dur, started)
	if(sp)
		if(!started) animate(O, transform = BeamFXXform(sp, O.fx_bx, O.fx_by), alpha = AlphaOf(sp), color = ColorOf(sp), time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		else animate(transform = BeamFXXform(sp, O.fx_bx, O.fx_by), alpha = AlphaOf(sp), color = ColorOf(sp), time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
	else
		if(!started) animate(O, alpha = 0, time = dur, easing = JUMP_EASING | EASE_IN)
		else animate(alpha = 0, time = dur, easing = JUMP_EASING | EASE_IN)

/datum/beamfx/proc/RealizeChains()
	var/base = 2 * k
	var/list/hl = Holds()
	if(rm_changed)
		rm_changed = 0
		for(var/datum/bfx_obj/ro in objs)
			if(!ro.pre_done || !ro.pobjs || (ro in new_chains)) continue
			for(var/ci = 1 to ro.pobjs.len)
				var/obj/energyfx/RO = ro.pobjs[ci]
				if(RO && RO.loc) EnergyFXDue(RO, ceil((ChainBuild(ro, ci, RO, base, hl) + 2) / 2) + 1)
	for(var/datum/bfx_obj/o in new_chains)
		var/list/specs = o.pre_specs
		if(!specs || !specs.len) continue
		var/list/firstpair
		for(var/list/pair in specs)
			if(pair)
				firstpair = pair
				break
		if(!firstpair) continue
		var/pr = ChainPair(o)
		var/nc = (pr > 0) ? 1 : firstpair.len
		o.pobjs = list()
		for(var/c = 1 to nc)
			var/list/sp0 = firstpair[c]
			var/obj/energyfx/O = NewObj(sp0, (pr > 0) ? pr : 0)
			if(!O) continue
			o.pobjs += O
			var/frames = ChainBuild(o, c, O, base, hl)
			EnergyFXDue(O, ceil((frames + 2) / 2) + 1)

/datum/beamfx/proc/SpeckIcon()
	return BEAMFX_SPECK_ICON

/datum/beamfx/proc/SpeckColor()
	if(grey) return list(0.875, 0.875, 0.875, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	var/list/edge = ramp[2]
	var/list/core = ramp[3]
	var/kp = BeamFXCool(0.95)
	return list((core[1] - edge[1]) * kp, (core[2] - edge[2]) * kp, (core[3] - edge[3]) * kp, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, edge[1], edge[2], edge[3], 0)

/datum/beamfx/proc/MapPt(x, y)
	return list(x, y, ang)

/datum/beamfx/proc/SpeckEmitter(region, x, y, rate, v1, v2, l1, l2, cnt)
	var/obj/energyfx/emit/O = EnergyFXGet(/obj/energyfx/emit, src)
	if(!O) return null
	O.fx_w = 32
	O.fx_h = 32
	var/list/mp = MapPt(x, y)
	x = mp[1]
	y = mp[2]
	if(!EnergyFXPlace(O, x, y, z))
		EnergyFXFree(O)
		return null
	O.color = SpeckColor()
	var/particles/beamfx_speck/P = new
	P.icon = SpeckIcon()
	P.icon_state = grey ? list("gss0" = 31, "gdu0" = 38, "gsk0" = 6) : list("pss0" = 31, "pdu0" = 38, "psk0" = 6)
	P.lifespan = generator("num", l1, l2)
	if(cnt) P.count = cnt
	var/vh = v2 * 0.1
	if(region == "up" || region == "down")
		var/sg = (region == "up") ? 1 : -1
		P.velocity = generator("box", vector(0, sg * BEAMFX_SPK_SIDE_LO * vh, 0), vector(BEAMFX_SPK_SIDE_X * vh, sg * vh, 0))
		P.bound2 = vector(1000, 1000, 1000)
	else if(region == "all")
		P.velocity = generator("circle", v1 * 0.1, vh)
		P.position = vector(0, 0, 0)
		P.bound2 = vector(1000, 1000, 1000)
	else
		P.velocity = generator("circle", v1 * 0.1, vh)
	var/ca = cos(mp[3])
	var/sa = sin(mp[3])
	P.transform = matrix(ca, -sa, x - O.fx_bx, sa, ca, y - O.fx_by)
	P.spawning = rate
	O.particles = P
	return O

/datum/beamfx/proc/SpeckRates(mode, strg)
	if(mode == 2) return list("back" = BEAMFX_SPK_RATE_CLASH * 2 * strg)
	return list("back" = BEAMFX_SPK_RATE_HIT * 0.8 * 2 * strg, "up" = BEAMFX_SPK_RATE_HIT * 0.1 * strg, "down" = BEAMFX_SPK_RATE_HIT * 0.1 * strg)

/datum/beamfx/proc/SpeckStop()
	for(var/region in spk_em)
		var/obj/energyfx/emit/O = spk_em[region]
		if(!O) continue
		var/particles/P = O.particles
		if(P) P.spawning = 0
		spk_live += list(list(O, -1, k + BEAMFX_SPK_FREE))
	spk_em = null
	spk_mode = 0
	spk_str = -1

/datum/beamfx/proc/SpeckStep()
	if(logging && spk_burst) world.log << "BFXE burst [2 * k] [num2text(spk_burst[2], 9)] [num2text(spk_burst[3], 9)] [spk_burst[4]]"
	if(spk_burst)
		var/list/b = spk_burst
		spk_burst = null
		var/mode = b[4] ? 2 : 1
		var/bx = WX(b[2] - 2)
		var/by = WY(b[2] - 2)
		var/strg = b[3]
		if(spk_mode != mode)
			if(spk_mode) SpeckStop()
			spk_mode = mode
			spk_x = bx
			spk_y = by
			spk_str = strg
			spk_em = list()
			var/list/R = SpeckRates(mode, strg)
			for(var/region in R)
				var/obj/energyfx/emit/NE = SpeckEmitter(region, bx, by, R[region], BEAMFX_SPK_V1, BEAMFX_SPK_V2, BEAMFX_SPK_L1, BEAMFX_SPK_L2, 0)
				if(NE) spk_em[region] = NE
		else
			if(abs(bx - spk_x) + abs(by - spk_y) > BEAMFX_SPK_MOVE)
				spk_x = bx
				spk_y = by
				var/list/mp = MapPt(bx, by)
				var/ca = cos(mp[3])
				var/sa = sin(mp[3])
				for(var/region in spk_em)
					var/obj/energyfx/emit/O = spk_em[region]
					if(!O || !O.particles) continue
					if(!EnergyFXPlace(O, mp[1], mp[2], z)) continue
					var/particles/P = O.particles
					P.transform = matrix(ca, -sa, mp[1] - O.fx_bx, sa, ca, mp[2] - O.fx_by)
			if(abs(strg - spk_str) > 0.001)
				spk_str = strg
				var/list/R2 = SpeckRates(mode, strg)
				for(var/region in spk_em)
					var/obj/energyfx/emit/O2 = spk_em[region]
					if(O2 && O2.particles)
						var/particles/P2 = O2.particles
						P2.spawning = R2[region]
		spk_k = k
	else if(spk_mode && spk_k < k)
		SpeckStop()
	if(spk_shots.len)
		for(var/list/s in spk_shots)
			if(logging) world.log << "BFXE shot [2 * k] [s[1]] [num2text(s[3], 9)] [num2text(s[4], 9)]"
			var/obj/energyfx/emit/SO
			switch(s[1])
				if("final")
					var/n = round(2 * 75 * s[5], 1)
					SO = SpeckEmitter("back", s[3], s[4], n, BEAMFX_SPK_V1, BEAMFX_SPK_V2, BEAMFX_SPK_L1, BEAMFX_SPK_L2, n)
				if("fly")
					SO = SpeckEmitter("all", s[3], s[4], 10, 40, 120, 3, 5, 10)
				if("remnant")
					SO = SpeckEmitter("all", s[3], s[4], 14, 40, 130, 2.5, 5, 14)
				else
					SO = SpeckEmitter("all", s[3], s[4], 10, 20, 60, 2, 4, 10)
			if(SO) spk_live += list(list(SO, k + 2, k + BEAMFX_SPK_FREE + 2))
		spk_shots = list()
	if(spk_live.len)
		var/list/keep = list()
		for(var/list/e in spk_live)
			var/obj/energyfx/emit/O3 = e[1]
			if(e[2] >= 0 && k >= e[2])
				var/particles/P3 = O3.particles
				if(P3) P3.spawning = 0
				e[2] = -1
			if(k >= e[3])
				O3.particles = null
				EnergyFXFree(O3)
				continue
			keep += list(e)
		spk_live = keep

/datum/beamfx/proc/Step()
	k++
	Tick(k)
	frame_specs = list(list(), list())
	new_chains = list()
	for(var/j = 1 to 2)
		var/fi = 2 * k + (j - 1)
		if(logging) flog = list()
		FrameAdvance(fi)
		Frame(fi, j)
		if(logging) LogFrame(fi)
	Realize()
	RealizeChains()
	SpeckStep()
	CharsTick()
	new_chains = null
	frame_specs = null

/datum/beamfx/proc/LogFrame(fi)
	world.log << "BFXF[log_tag] [fi] [flog.len]"
	for(var/list/sp in flog)
		world.log << "BFXS[log_tag] [sp[BFX_FAM]]|[sp[BFX_ST]]|[sp[BFX_LIGHT]]|[num2text(sp[BFX_X], 9)]|[num2text(sp[BFX_Y], 9)]|[num2text(sp[BFX_ANG], 9)]|[num2text(sp[BFX_SX], 9)]|[num2text(sp[BFX_SY], 9)]|[num2text(sp[BFX_PRE], 9)]|[num2text(sp[BFX_ALPHA], 9)]|[num2text(sp[BFX_LAYER], 9)]|[sp[BFX_ORDER]]|[sp[BFX_TAG]]|[num2text(sp[BFX_FADE], 9)]|[sp[BFX_SEED]][(sp.len >= 19 && sp[18]) ? "|[sp[18]]|[sp[19]]" : ""]"

/datum/beamfx/proc/Busy()
	if(objs.len || spk_live.len || spk_mode) return 1
	for(var/key in slots)
		var/datum/bfx_slot/SL = slots[key]
		if(SL && SL.idle < 3) return 1
	return 0

/datum/beamfx/proc/Cleanup()
	CharsDrop()
	for(var/key in slots)
		var/datum/bfx_slot/SL = slots[key]
		if(SL) EnergyFXFree(SL.obj)
	slots = list()
	objs = list()
	for(var/region in spk_em)
		var/obj/energyfx/emit/O = spk_em[region]
		if(!O) continue
		O.particles = null
		EnergyFXFree(O)
	spk_em = null
	spk_mode = 0
	for(var/list/e in spk_live)
		var/obj/energyfx/emit/O2 = e[1]
		if(!O2) continue
		O2.particles = null
		EnergyFXFree(O2)
	spk_live = list()
	finished = 1
