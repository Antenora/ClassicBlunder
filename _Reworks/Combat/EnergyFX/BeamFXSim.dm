/datum/bfx_obj
	var/kind
	var/t0 = 0
	var/d0 = 0
	var/v = 0
	var/lat = 0
	var/x0 = 0
	var/y0 = 0
	var/vx = 0
	var/vy = 0
	var/decel = 0
	var/seq = 0
	var/ang = 0
	var/omega = 0
	var/scale = 1
	var/life = 1000000000
	var/grow = 0
	var/uid = 0
	var/fc_n = 0
	var/fc_x = 0
	var/fc_y = 0
	var/fc_a = 0
	var/fc_init = 0
	var/list/pre_specs
	var/pre_f0 = 0
	var/pre_done = 0
	var/list/pobjs

/datum/beamfx
	var/datum/beam/beam
	var/mob/owner
	var/z = 1
	var/d = "E"
	var/ax = 1
	var/ay = 0
	var/nx = 0
	var/ny = 1
	var/ang = 0
	var/D = 32
	var/S = 32
	var/Vg = 640
	var/Vs = 352
	var/lat0 = 0
	var/mz = 0
	var/dstart = 0
	var/Ox = 0
	var/Oy = 0
	var/ws = 1
	var/target_d
	var/clash_mode = 0
	var/datum/beamfx/partner
	var/gain = 1
	var/t0
	var/fi0
	var/uid_next = 0
	var/datum/bfx_rng/rng
	var/list/stamp_m = list()
	var/list/stamp_tbf = list()
	var/list/objs = list()
	var/bead_gap = 2
	var/since_bead = 0
	var/bead_side = 1
	var/next_surge
	var/next_dome
	var/list/ring_q = list()
	var/last_ring = -1
	var/list/flame_src = list()
	var/list/surge_emit = list()
	var/bloom_k = 1
	var/list/pulses = list()
	var/list/hlog_f = list()
	var/list/hlog_h = list()
	var/list/blk_f = list()
	var/list/blk_v = list()
	var/release_t
	var/release_f
	var/fly_t
	var/fly_f
	var/fly_H
	var/fly_te
	var/dead_t
	var/dead_f
	var/dead_H
	var/dead_struggle = 0
	var/ever_blocked = 0
	var/st_t0
	var/st_f
	var/st_h0
	var/t_hit
	var/remnant_done = 0
	var/erode_done = 0
	var/swallow_t
	var/swallow_f
	var/swallow_bk
	var/end_t
	var/final_done = 0
	var/end_H
	var/k = -1
	var/ctx_f = 0
	var/start_wt = 0
	var/s_n = 0
	var/s_travelled = 0
	var/s_firing = 1
	var/s_blocked = 0
	var/s_clash = 0
	var/s_dead = 0
	var/s_off = 0
	var/grey = 0
	var/list/ramp
	var/list/slots = list()
	var/list/frame_specs
	var/list/new_chains
	var/list/flog
	var/logging = 0
	var/finished = 0
	var/mob/target_mob
	var/mob/caster_mob
	var/cm_on = 0
	var/cm_x
	var/cm_y
	var/list/olog_f = list()
	var/list/olog_v = list()
	var/list/spk_burst
	var/list/spk_shots = list()
	var/rm_ih
	var/rm_fdet
	var/rm_ir
	var/rm_changed = 0

/datum/beamfx/New(dir_text, ox, oy, zlevel, width, seed, list/C255, list/core255, list/glow255)
	rng = new /datum/bfx_rng(seed)
	z = zlevel
	ws = width
	SetDir(dir_text)
	Ox = ox
	Oy = oy
	SetColor(C255, core255, glow255)

/datum/beamfx/proc/SetDir(dir_text)
	d = dir_text
	var/list/dv = BeamFXDirVec(d)
	var/n = sqrt(dv[1] * dv[1] + dv[2] * dv[2])
	ax = dv[1] / n
	ay = dv[2] / n
	nx = -ay
	ny = ax
	ang = arctan(dv[1], dv[2])
	D = (length(d) == 2) ? 32 * sqrt(2) : 32
	S = D
	Vg = D / BEAMFX_TICK
	Vs = 0.55 * Vg
	var/list/hand = BeamFXHand(d)
	var/along = hand[1] * ax + hand[2] * ay
	lat0 = hand[1] * nx + hand[2] * ny
	mz = along - D
	dstart = mz + 8
	bloom_k = (d in list("S", "SE", "SW")) ? 0.9 : 1

/datum/beamfx/proc/SetColor(list/C255, list/core255, list/glow255)
	var/list/c = C255 ? C255 : list(0, 0, 0)
	var/lum = BeamFXLum(list(c[1] / 255, c[2] / 255, c[3] / 255))
	if(lum < 0.03)
		grey = 1
		var/list/g = list(0, 0, 0)
		for(var/i = 1 to 3)
			g[i] = clamp(c[i] / 255 + (0.6 - lum), 0, 1) * 255
		ramp = BeamFXRamp(g, null, null)
	else
		grey = 0
		ramp = BeamFXRamp(c, core255, glow255)

proc/BeamFXDirVec(d)
	switch(d)
		if("E") return list(1, 0)
		if("NE") return list(1, 1)
		if("N") return list(0, 1)
		if("NW") return list(-1, 1)
		if("W") return list(-1, 0)
		if("SW") return list(-1, -1)
		if("S") return list(0, -1)
	return list(1, -1)

proc/BeamFXHand(d)
	switch(d)
		if("E", "SE", "NE") return list(11.5, 0.5)
		if("S") return list(8, 0.5)
		if("W", "SW", "NW") return list(-11.5, 0.5)
	return list(-10, 0.5)

proc/BeamFXDirText(dir)
	switch(dir)
		if(EAST) return "E"
		if(NORTHEAST) return "NE"
		if(NORTH) return "N"
		if(NORTHWEST) return "NW"
		if(WEST) return "W"
		if(SOUTHWEST) return "SW"
		if(SOUTH) return "S"
	return "SE"

/datum/beamfx/proc/FT(fi)
	return fi * BEAMFX_FR

/datum/beamfx/proc/WX(dd, lat = 0)
	return Ox + ax * dd + nx * (lat + lat0)

/datum/beamfx/proc/WY(dd, lat = 0)
	return Oy + ay * dd + ny * (lat + lat0)

/datum/beamfx/proc/FrameOk(f, qf, strict)
	return strict ? (f < qf) : (f <= qf)

/datum/beamfx/proc/Mk(kind, t0v)
	var/datum/bfx_obj/o = new
	o.kind = kind
	o.t0 = t0v
	uid_next++
	o.uid = uid_next
	return o

/datum/beamfx/proc/AtH(qf, strict)
	for(var/i = hlog_f.len, i >= 1, i--)
		if(FrameOk(hlog_f[i], qf, strict)) return hlog_h[i]
	return null

/datum/beamfx/proc/AtHDef(qf, strict, def)
	for(var/i = hlog_f.len, i >= 1, i--)
		if(FrameOk(hlog_f[i], qf, strict)) return hlog_h[i]
	return def

/datum/beamfx/proc/LastHF(qf, strict)
	for(var/i = hlog_f.len, i >= 1, i--)
		if(FrameOk(hlog_f[i], qf, strict)) return hlog_f[i]
	return null

/datum/beamfx/proc/HGlide(t, qf, strict)
	var/H = AtH(qf, strict)
	if(isnull(H)) return null
	var/prevH = AtHDef(qf - 2, strict, H)
	var/lf = LastHF(qf, strict)
	var/g = isnull(lf) ? 1 : min(1, (t - FT(lf)) / BEAMFX_TICK)
	return prevH + (H - prevH) * g

/datum/beamfx/proc/Struggling(qf, strict)
	if(!isnull(end_H)) return 1
	for(var/i = blk_f.len, i >= 1, i--)
		if(FrameOk(blk_f[i], qf, strict)) return blk_v[i] ? 1 : 0
	return 0

/datum/beamfx/proc/Contact(t, qf, strict)
	if(clash_mode && partner) return ClashContact(t, qf, strict)
	if(!isnull(target_d)) return target_d - 12
	return null

/datum/beamfx/proc/ClashWob(tl)
	return 3 * sin(360 * 2.2 * tl) + 1.5 * sin(360 * 3.7 * tl + 57.2957795) + 7 * sin(360 * tl / 1.25) + 3.5 * sin(360 * tl / 0.53 + 45.8366236)

/datum/beamfx/proc/OffGlide(t, qf, strict)
	var/V
	var/Vf
	for(var/i = olog_f.len, i >= 1, i--)
		if(FrameOk(olog_f[i], qf, strict))
			V = olog_v[i]
			Vf = olog_f[i]
			break
	if(isnull(V)) return 0
	var/prevV = V
	for(var/i = olog_f.len, i >= 1, i--)
		if(FrameOk(olog_f[i], qf - 2, strict))
			prevV = olog_v[i]
			break
	var/g = min(1, (t - FT(Vf)) / BEAMFX_TICK)
	return prevV + (V - prevV) * g

/datum/beamfx/proc/ClashContact(t, qf, strict)
	var/datum/beamfx/lead = clash_lead ? src : partner
	var/datum/beamfx/oth = clash_lead ? partner : src
	var/dwt = start_wt - partner.start_wt
	var/tl = clash_lead ? t : t + dwt * 0.05
	var/lqf = clash_lead ? qf : qf + dwt * 2
	var/mx
	var/my
	if(lead.cm_on)
		if(isnull(lead.cm_x))
			var/dlo = lead.start_wt - oth.start_wt
			var/ha0 = lead.HGlide(tl, lqf, strict)
			var/hb0 = oth.HGlide(tl + dlo * 0.05, lqf + dlo * 2, strict)
			if(isnull(ha0) || isnull(hb0)) return null
			lead.cm_x = (lead.WX(ha0) + oth.WX(hb0)) / 2
			lead.cm_y = (lead.WY(ha0) + oth.WY(hb0)) / 2
		mx = lead.cm_x
		my = lead.cm_y
		var/s = lead.OffGlide(tl, lqf, strict) + ClashWob(tl)
		var/pa0 = (mx - lead.Ox) * lead.ax + (my - lead.Oy) * lead.ay
		var/dab = (oth.Ox - lead.Ox) * lead.ax + (oth.Oy - lead.Oy) * lead.ay
		var/lo = lead.mz + 40
		var/hi = dab - oth.mz - 40
		var/pa = pa0 + s
		if(lo <= hi) pa = clamp(pa, lo, hi)
		else pa = (lo + hi) / 2
		mx += lead.ax * (pa - pa0)
		my += lead.ay * (pa - pa0)
		return (mx - Ox) * ax + (my - Oy) * ay
	var/sx = 0
	var/sy = 0
	var/n = 0
	for(var/i = 0 to 6)
		var/tt = t - i * 0.05
		var/ha = HGlide(tt, qf - 2 * i, strict)
		var/hb = partner.HGlide(tt + dwt * 0.05, qf - 2 * i + dwt * 2, strict)
		if(isnull(ha) || isnull(hb)) continue
		sx += (WX(ha) + partner.WX(hb)) / 2
		sy += (WY(ha) + partner.WY(hb)) / 2
		n++
	if(!n) return null
	mx = sx / n
	my = sy / n
	var/wob = ClashWob(tl)
	mx += lead.ax * wob
	my += lead.ay * wob
	return (mx - Ox) * ax + (my - Oy) * ay

/datum/beamfx/proc/Holds()
	var/list/hl = list()
	if(!isnull(fi0)) hl += list(list(fi0 + 2, 4))
	if(!isnull(rm_ih))
		var/hs = max(rm_ih - 3, rm_fdet)
		if(hs < rm_ih) hl += list(list(hs, rm_ih - hs))
		hl += list(list(rm_ih + 5, 6))
	if(!isnull(rm_ir)) hl += list(list(rm_ir + 1, 3))
	return hl

/datum/beamfx/proc/Q(i, list/hl)
	var/v = i - BeamFXMod(i, 2)
	if(!isnull(rm_ih) && i >= rm_ih && i < rm_ih + 5) v = i
	for(var/list/h in hl)
		if(i >= h[1] && i < h[1] + h[2]) v = h[1]
	return v

/datum/beamfx/proc/HitQ(t)
	if(isnull(t_hit) || t < t_hit) return 0
	return BeamFXEaseOut((t - t_hit) / 0.09)

/datum/beamfx/proc/BurstScale(t)
	return 0.45 + 0.55 * HitQ(t)

/datum/beamfx/proc/Hr(t, qf, strict)
	var/at_dead = !isnull(dead_f) && (strict ? (qf > dead_f) : (qf >= dead_f))
	if(!isnull(end_H) && at_dead) return end_H
	var/H
	var/at_fly = !isnull(fly_f) && (strict ? (qf > fly_f) : (qf >= fly_f))
	if(at_fly)
		H = fly_H + (t - fly_t) * Vg
	else if(at_dead)
		H = dead_H
	else
		H = HGlide(t, qf, strict)
		if(isnull(H)) return null
	var/st = at_dead ? dead_struggle : Struggling(qf, strict)
	var/em = mz + 4 + Vg * 1.3 * max(0, t - t0 - 0.05)
	if(st)
		var/c = Contact(t, qf, strict)
		if(!isnull(c))
			if(!isnull(t_hit) && t >= t_hit)
				H = c - BEAMFX_CONTACT * BurstScale(t)
			else if(!isnull(st_f) && (strict ? (qf > st_f) : (qf >= st_f)))
				H = min(c - 9, st_h0 + (t - st_t0) * Vg)
			else
				H = c - 9
	return min(H, em)

/datum/beamfx/proc/Back(t, qf)
	if(isnull(release_f) || qf < release_f) return mz
	if(!isnull(swallow_f) && qf > swallow_f) return swallow_bk + (t - swallow_t) * BEAMFX_SWALLOW_V
	if(!isnull(fly_f) && qf > fly_f) return dstart + (fly_t - release_t) * Vg + (t - fly_t) * Vg * 1.8
	return dstart + (t - release_t) * Vg

/datum/beamfx/proc/LatBase(t, qf)
	if(isnull(release_f) || qf <= release_f) return Vs * (t - t0)
	return Vs * (release_t - t0) + Vg * (t - release_t)

/datum/beamfx/proc/LatD(m, t, qf)
	return dstart + S * m + LatBase(t, qf)

/datum/beamfx/proc/SpawnFlow(kind, now, x, y, a0, vv, om, lifev, dec, grw, sq, scl = 1)
	var/t0v = now + rng.U(0, BEAMFX_TICK)
	var/datum/bfx_obj/o = Mk(kind, t0v)
	o.x0 = x
	o.y0 = y
	o.ang = a0
	o.v = vv
	o.omega = om
	o.life = lifev
	o.decel = dec
	o.grow = grw
	o.seq = sq
	o.scale = scl
	objs += o
	return o

/datum/beamfx/proc/BurstDir(clash, wide = 0)
	var/side = (rng.R() < 0.5) ? 1 : -1
	if(clash) return ang + 180 + side * rng.U(0, wide ? 98 : 92)
	if(rng.R() < 0.55) return ang + side * rng.U(60, 125)
	return ang + 180 + rng.U(-55, 55)

/datum/beamfx/proc/NewFlameSrc(now, clash, side)
	var/a
	var/dr
	if(clash)
		a = ang + 180 + side * rng.U(22, 92)
		dr = side * rng.U(-18, 28)
	else
		a = ang + side * rng.U(66, 138)
		dr = side * rng.U(8, 42)
	return list(a, dr, now, now + rng.U(0.22, 0.5), side)

/datum/beamfx/proc/MkWedge(t0v, cd, a0, lifev, scl, sq, om)
	var/datum/bfx_obj/o = Mk("wedge", t0v)
	o.d0 = cd - 2
	o.ang = a0
	o.life = lifev
	o.scale = scl
	o.seq = sq
	o.omega = om
	objs += o

/datum/beamfx/proc/BurstEmit(now, cd, strength = 1, clash = 0, final = 0)
	if(final)
		var/list/srcs = flame_src.Copy()
		if(!srcs.len)
			srcs += list(NewFlameSrc(now, clash, (rng.R() < 0.5) ? 1 : -1))
		if(srcs.len < 3 && rng.R() < 0.6)
			var/list/f1 = srcs[1]
			srcs += list(NewFlameSrc(now, clash, (rng.R() < 0.5) ? f1[5] : -f1[5]))
		for(var/list/fsrc in srcs)
			var/nw = 1 + ((rng.R() < 0.45) ? 1 : 0)
			for(var/i = 1 to nw)
				var/a0 = fsrc[1] + fsrc[2] * (now - fsrc[3]) + rng.U(-14, 14)
				var/t0v = now + rng.U(0, 0.06)
				var/lifev = rng.U(0.08, 0.17)
				var/scl = rng.U(0.7, 1.4)
				var/sq = rng.RandRange(8)
				MkWedge(t0v, cd, a0, lifev, scl, sq, fsrc[5])
	else
		var/list/keep = list()
		for(var/list/f in flame_src)
			if(f[4] > now) keep += list(f)
		flame_src = keep
		var/want = (rng.R() < 0.55) ? 2 : 3
		while(flame_src.len < want)
			var/np = 0
			var/nn = 0
			for(var/list/f in flame_src)
				if(f[5] == 1) np++
				else nn++
			var/side
			if(np > nn) side = -1
			else if(nn > np) side = 1
			else side = (rng.R() < 0.5) ? 1 : -1
			flame_src += list(NewFlameSrc(now, clash, side))
		var/early = isnull(t_hit) ? 1 : (0.45 + 0.55 * BeamFXSstep(0.05, 0.16, now - t_hit))
		for(var/list/fsrc in flame_src)
			var/n_w = ((rng.R() < 0.6) ? 1 : 0) + ((rng.R() < 0.14 * strength) ? 1 : 0)
			if(early < 0.9 && rng.R() < 0.5) n_w++
			for(var/i = 1 to n_w)
				var/a0 = fsrc[1] + fsrc[2] * (now - fsrc[3]) + rng.U(-9, 9)
				var/t0v = now + rng.U(0, BEAMFX_TICK)
				var/lifev = rng.U(0.14, 0.22) * (0.7 + 0.3 * early)
				var/scl = rng.U(0.95, 1.45) * (min(1, strength) ** 0.3) * early
				var/sq = rng.RandRange(8)
				MkWedge(t0v, cd, a0, lifev, scl, sq, fsrc[5])
	var/quiet = final || !isnull(swallow_t)
	var/nsh = quiet ? 0 : round((2 + ((rng.R() < 0.5) ? 1 : 0)) * strength, 1)
	for(var/i = 1 to nsh)
		var/a0 = BurstDir(clash)
		var/r0 = rng.U(7, 13)
		var/bx = WX(cd - 2) + cos(a0) * r0
		var/by = WY(cd - 2) + sin(a0) * r0
		var/vv = rng.U(220, 560)
		var/om = rng.U(-45, 45)
		var/lifev = rng.U(0.11, 0.22)
		var/sq = rng.RandRange(5)
		var/scl = rng.U(0.8, 1.35)
		var/datum/bfx_obj/o = SpawnFlow("shard", now, bx, by, a0, vv, om, lifev, 2.6, 0, sq, scl)
		o.lat = (rng.R() < 0.5) ? 1 : -1
	if(!quiet && rng.R() < 0.45 * strength && (isnull(t_hit) || now >= t_hit + 0.1))
		var/a0 = BurstDir(clash)
		var/r0 = rng.U(9, 14)
		var/bx = WX(cd - 2) + cos(a0) * r0
		var/by = WY(cd - 2) + sin(a0) * r0
		var/a1 = a0 + rng.U(-12, 12)
		var/vv = rng.U(420, 650)
		var/om = rng.U(-40, 40)
		var/lifev = rng.U(0.12, 0.2)
		var/sq = rng.RandRange(4)
		var/scl = rng.U(0.85, 1.35)
		var/datum/bfx_obj/o = SpawnFlow("lance", now, bx, by, a1, vv, om, lifev, 2.2, 0, sq, scl)
		o.lat = (rng.R() < 0.5) ? 1 : -1
	if(rng.R() < 0.6 * strength && !final)
		var/side = (rng.R() < 0.5) ? 1 : -1
		var/a0
		if(clash) a0 = ang + 180 + side * rng.U(55, 95)
		else a0 = ang + side * rng.U(72, 108)
		var/om = side * rng.U(170, 320) * (clash ? 0.6 : 1)
		var/r0 = rng.U(6, 11)
		var/bx = WX(cd - 2) + cos(a0) * r0
		var/by = WY(cd - 2) + sin(a0) * r0
		var/vv = rng.U(80, 170)
		var/lifev = rng.U(0.2, 0.3)
		var/sq = rng.RandRange(4)
		SpawnFlow("tongue", now, bx, by, a0, vv, om, lifev, 1.8, 1.3, sq)
	if(final) spk_shots += list(list("final", now, WX(cd - 2), WY(cd - 2), strength, clash ? 1 : 0))
	else spk_burst = list(now, cd, strength, clash ? 1 : 0)

/datum/beamfx/proc/Tick(kk)
	var/qn = 2 * kk
	var/now = FT(qn)
	ctx_f = qn
	if(!isnull(end_t) && !final_done && now >= end_t)
		final_done = 1
		BurstEmit(now, end_H + BEAMFX_CONTACT, 1.6 * min(1, gain), clash_mode, 1)
	if(s_dead)
		if(isnull(dead_t))
			dead_t = now
			dead_f = qn
			dead_H = hlog_h.len ? hlog_h[hlog_h.len] : 0
			dead_struggle = (Struggling(qn - 2, 0) || ever_blocked) ? 1 : 0
			if(dead_struggle && isnull(end_t))
				var/hr = Hr(now - 0.000001, qn, 1)
				if(!hr) hr = dead_H
				end_H = hr
				var/bk = Back(now, qn)
				swallow_t = now
				swallow_f = qn
				swallow_bk = min(bk, hr - 2)
				end_t = now + max(0.06, (hr - swallow_bk) / BEAMFX_SWALLOW_V)
			else if(dead_struggle)
				var/hr2 = Hr(now - 0.000001, qn, 1)
				if(!hr2) hr2 = dead_H
				end_H = hr2
			else if(isnull(fly_t))
				var/hr3 = Hr(now - 0.000001, qn, 1)
				if(!hr3) hr3 = dead_H
				spk_shots += list(list("fly", now, WX(hr3 + 6), WY(hr3 + 6)))
		return
	var/n = s_n
	if(n == 0) return
	if(isnull(t0))
		t0 = now
		fi0 = qn
		next_surge = now + 0.25
	if(!s_firing && isnull(release_t))
		release_t = now
		release_f = qn
		rm_ir = qn
		rm_changed = 1
	var/H = (s_travelled + n - 1) * D
	if(!isnull(release_t) && isnull(fly_t) && !(s_blocked || s_clash) && hlog_h.len && abs(H - hlog_h[hlog_h.len]) < 0.001 && s_travelled > 0 && !ever_blocked)
		var/rem = H - Back(now, qn)
		fly_t = now
		fly_f = qn
		fly_H = H
		fly_te = now + max(0.1, (rem - 64) / (0.8 * Vg))
	var/moving = !hlog_h.len || abs(H - hlog_h[hlog_h.len]) > 0.001
	hlog_f += qn
	hlog_h += H
	if(cm_on)
		olog_f += qn
		olog_v += s_off
	var/struggling = (s_blocked || s_clash) ? 1 : 0
	if(struggling && isnull(st_t0))
		st_t0 = now
		st_f = qn
		var/prev = HGlide(now - 0.000001, qn, 1)
		var/em = mz + 4 + Vg * 1.3 * max(0, now - t0 - 0.05)
		st_h0 = min(isnull(prev) ? H : prev, em)
		var/c0 = Contact(now, qn, 0)
		if(isnull(c0)) c0 = st_h0 + 9
		t_hit = now + max(0, (c0 - 9 - st_h0) / Vg)
		rm_ih = ceil(t_hit / BEAMFX_FR - 0.0001)
		rm_fdet = qn
		rm_changed = 1
	if(struggling) ever_blocked = 1
	blk_f += qn
	blk_v += struggling
	if(!isnull(release_t) && ever_blocked && isnull(swallow_t))
		var/hr = Hr(now, qn, 0)
		if(!isnull(hr) && hr - Back(now, qn) <= BEAMFX_SWALLOW)
			swallow_t = now
			swallow_f = qn
			swallow_bk = Back(now, qn)
			end_H = hr
			end_t = now + max(0.06, (hr - swallow_bk) / BEAMFX_SWALLOW_V)
	var/hr_next = Hr(now + BEAMFX_TICK, qn + 2, 0)
	if(!hr_next) hr_next = H
	var/bk = Back(now + BEAMFX_TICK, qn + 2)
	var/span_lo = bk - S
	var/span_hi = max(H, hr_next) + S + BEAMFX_CONTACT
	var/m_lo = ceil((span_lo - dstart - LatBase(now + BEAMFX_TICK, qn + 2)) / S)
	var/m_hi = floor((span_hi - dstart - LatBase(now, qn)) / S)
	for(var/m = m_lo, m <= m_hi, m++)
		if(!(m in stamp_m))
			stamp_m += m
			stamp_tbf += qn
	if(struggling && isnull(next_dome))
		next_dome = now + (clash_mode ? rng.U(0, 0.45) : 0)
	if(s_firing && now - t0 > 0.14)
		since_bead++
		if(since_bead >= bead_gap)
			since_bead = 0
			bead_gap = rng.RandInt(2, 4)
			bead_side = -bead_side
			var/t0b = now + rng.U(0, BEAMFX_TICK)
			var/vb = Vg * rng.U(1.35, 1.7)
			var/lb = bead_side * rng.U(1, 4.5) * ws
			var/datum/bfx_obj/ob = Mk("bead", t0b)
			ob.d0 = mz + 12
			ob.v = vb
			ob.lat = lb
			objs += ob
		if(rng.R() < 0.8)
			var/side = (rng.R() < 0.5) ? 1 : -1
			var/t0s = now + rng.U(0, BEAMFX_TICK)
			var/vs2 = Vg * rng.U(1.5, 2.1)
			var/ls = side * rng.U(4.5, 8) * ws
			var/datum/bfx_obj/os = Mk("streak", t0s)
			os.d0 = mz + 16
			os.v = vs2
			os.lat = ls
			objs += os
		if(now >= next_surge - 0.000001)
			surge_emit += now
			var/vu = Vg * rng.U(1.2, 1.7)
			var/su = rng.U(0.9, 1.35)
			var/datum/bfx_obj/ou = Mk("surge", now)
			ou.d0 = mz + 14
			ou.v = vu
			ou.scale = su
			objs += ou
			next_surge = now + rng.U(0.2, 0.7)
	var/lo = max(Back(now, qn), mz + 16)
	var/body_len = max(0, H - lo)
	var/ng = 0.12 * body_len / 32
	var/cnt = floor(ng) + ((rng.R() < ng - floor(ng)) ? 1 : 0)
	for(var/i = 1 to cnt)
		if(body_len < 24) break
		var/dd = rng.U(lo, H - 12)
		var/side = (rng.R() < 0.5) ? 1 : -1
		var/lat = side * abs(rng.Gauss(7.6 * 1.1, 2.5)) * ws
		var/x0 = WX(dd, lat)
		var/y0 = WY(dd, lat)
		var/fw = rng.U(20, 70)
		var/ov = rng.U(2, 6) * side
		var/t0w = now + rng.U(0, BEAMFX_TICK)
		var/lifew = rng.U(0.3, 0.55)
		var/sqw = rng.RandRange(2)
		var/datum/bfx_obj/ow = Mk("tw", t0w)
		ow.x0 = x0
		ow.y0 = y0
		ow.vx = ax * fw + nx * ov
		ow.vy = ay * fw + ny * ov
		ow.life = lifew
		ow.seq = sqw
		objs += ow
	var/hr_now = Hr(now, qn, 0)
	if(!hr_now) hr_now = H
	if(struggling && !isnull(t_hit) && now + BEAMFX_TICK > t_hit)
		var/c = Contact(now, qn, 0)
		var/cd = isnull(c) ? hr_now + BEAMFX_CONTACT : c
		BurstEmit(max(now, t_hit), cd, gain, clash_mode, 0)
		var/n_arc
		if(clash_mode) n_arc = (rng.R() < 0.7) ? 2 : 1
		else n_arc = (rng.R() < 0.75) ? 1 : 0
		for(var/i = 1 to n_arc)
			var/ra = rng.U(24, 34)
			var/side = (rng.R() < 0.5) ? 1 : -1
			var/an
			if(clash_mode) an = ang + 180 + side * rng.U(15, 100)
			else an = ang + side * rng.U(55, 165)
			var/x0 = WX(cd - 2) + cos(an) * ra
			var/y0 = WY(cd - 2) + sin(an) * ra
			var/t0a = now + rng.U(0, BEAMFX_TICK)
			var/a1 = an + rng.U(-20, 20)
			var/lifea = rng.U(0.05, 0.075)
			var/sqa = rng.RandRange(10)
			var/datum/bfx_obj/oa = Mk("arc", t0a)
			oa.x0 = x0
			oa.y0 = y0
			oa.ang = a1
			oa.life = lifea
			oa.seq = sqa
			objs += oa
		var/list/fire = list()
		var/list/rest = list()
		for(var/list/rq in ring_q)
			if(rq[1] <= now + BEAMFX_TICK) fire += list(rq)
			else rest += list(rq)
		ring_q = rest
		var/t_r = max(now, t_hit)
		if(!fire.len && t_r - last_ring > 0.9) fire = list(list(t_r, 1))
		if(fire.len)
			var/list/f1 = fire[1]
			var/tq = f1[1]
			var/sqq = f1[2]
			if(max(tq, t_hit) - last_ring >= (clash_mode ? 0.4 : 0.28))
				var/x0 = WX(cd - 1)
				var/y0 = WY(cd - 1)
				var/sc = rng.U(0.92, 1.08) * (clash_mode ? 1.2 : 0.95) * (0.85 + 0.15 * sqq)
				var/tr = max(tq, t_hit)
				var/n_pc
				if(clash_mode) n_pc = (rng.R() < 0.5) ? 3 : 4
				else n_pc = (rng.R() < 0.55) ? 2 : 3
				var/phi0 = rng.U(0, 360)
				for(var/jj = 0 to n_pc - 1)
					var/phi = phi0 + jj * (360 / n_pc) + rng.U(-38, 38)
					var/t0r = tr + rng.U(0, 0.045)
					var/lifer = rng.U(0.16, 0.26)
					var/sclr = sc * rng.U(0.82, 1.18)
					var/sqr = rng.RandRange(8)
					var/omr = (rng.R() < 0.5) ? 1 : -1
					var/datum/bfx_obj/orr = Mk("rarc", t0r)
					orr.x0 = x0
					orr.y0 = y0
					orr.life = lifer
					orr.scale = sclr
					orr.seq = sqr
					orr.ang = phi
					orr.omega = omr
					objs += orr
				last_ring = tr
	else if(H > mz + 40 && (isnull(release_t) || isnull(fly_t)) && !moving)
		if(rng.R() < 0.45)
			var/side = (rng.R() < 0.5) ? 1 : -1
			if(rng.R() < 0.5)
				var/a0 = ang + side * rng.U(5, 30)
				var/lt = side * rng.U(0, 5) * ws
				var/x0 = WX(hr_now + 12, lt)
				var/y0 = WY(hr_now + 12, lt)
				var/vv = rng.U(40, 80)
				var/om = -side * rng.U(40, 120)
				var/lifev = rng.U(0.18, 0.28)
				var/sq = rng.RandRange(4)
				SpawnFlow("curl", now, x0, y0, a0, vv, om, lifev, 2, 1.3, sq)
			else
				var/a0 = ang + 180 - side * rng.U(15, 60)
				var/lt = side * rng.U(5, 9) * ws
				var/x0 = WX(hr_now + 2, lt)
				var/y0 = WY(hr_now + 2, lt)
				var/vv = rng.U(40, 90)
				var/om = -side * rng.U(80, 190)
				var/lifev = rng.U(0.24, 0.34)
				var/sq = rng.RandRange(4)
				SpawnFlow("curl", now, x0, y0, a0, vv, om, lifev, 1.6, 1.5, sq)

/datum/beamfx/proc/FlowPos(datum/bfx_obj/o, age)
	if(!o.fc_init)
		o.fc_init = 1
		o.fc_n = 0
		o.fc_x = o.x0
		o.fc_y = o.y0
		o.fc_a = o.ang
	while((o.fc_n + 1) * 0.01 <= age + 0.000001)
		var/tt = o.fc_n * 0.01
		var/sp = o.v * max(0, 1 - o.decel * tt)
		o.fc_a += o.omega * (1 + 1.2 * tt) * 0.01
		o.fc_x += cos(o.fc_a) * sp * 0.01
		o.fc_y += sin(o.fc_a) * sp * 0.01
		o.fc_n++
	var/rem = age - o.fc_n * 0.01
	if(rem > 0.000001)
		var/tt2 = o.fc_n * 0.01
		var/sp2 = o.v * max(0, 1 - o.decel * tt2)
		var/a2 = o.fc_a + o.omega * (1 + 1.2 * tt2) * rem
		return list(o.fc_x + cos(a2) * sp2 * rem, o.fc_y + sin(a2) * sp2 * rem, a2)
	return list(o.fc_x, o.fc_y, o.fc_a)
