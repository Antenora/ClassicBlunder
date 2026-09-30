var/list/BEAMFX_FAM = list(\
	"Stamp" = list(BEAMFX_STAMP_ICON, 64, 80),\
	"Bloom" = list(BEAMFX_BLOOM_ICON, 104, 64),\
	"Head" = list(BEAMFX_HEAD_ICON, 128, 80),\
	"Impact" = list(BEAMFX_IMPACT_ICON, 160, 128),\
	"End" = list(BEAMFX_END_ICON, 104, 72),\
	"Surge" = list(BEAMFX_SURGE_ICON, 112, 84),\
	"Bead" = list(BEAMFX_BEAD_ICON, 48, 48),\
	"Sheath" = list(BEAMFX_SHEATH_ICON, 56, 56),\
	"Flash" = list(BEAMFX_FLASH_ICON, 128, 128),\
	"Shard" = list(BEAMFX_SHARD_ICON, 80, 32),\
	"Lance" = list(BEAMFX_LANCE_ICON, 128, 32),\
	"Tongue" = list(BEAMFX_TONGUE_ICON, 80, 48),\
	"Wedge" = list(BEAMFX_WEDGE_ICON, 96, 72),\
	"Ring" = list(BEAMFX_RING_ICON, 96, 96),\
	"Arc" = list(BEAMFX_ARC_ICON, 72, 48),\
	"Speck" = list(BEAMFX_SPECK_ICON, 20, 20),\
	"Curl" = list(BEAMFX_CURL_ICON, 72, 44))

#define BFX_FAM 1
#define BFX_ST 2
#define BFX_LIGHT 3
#define BFX_X 4
#define BFX_Y 5
#define BFX_ANG 6
#define BFX_SX 7
#define BFX_SY 8
#define BFX_PRE 9
#define BFX_ALPHA 10
#define BFX_LAYER 11
#define BFX_ORDER 12
#define BFX_TAG 13
#define BFX_FADE 14
#define BFX_SEED 15
#define BFX_ZL 16
#define BFX_PR 17

/datum/bfx_slot
	var/obj/beamfx/obj
	var/fam
	var/light = 0
	var/list/last
	var/idle = 0
	var/st
	var/pr = 0

/datum/beamfx/proc/Emit(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr = 0)
	var/list/sp = list(fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	var/list/F = frame_specs[j]
	F[key] = sp
	if(logging) flog += list(sp)

/datum/beamfx/proc/Head(j, key, fam, st, hx, hy, hs, stflag, alpha = 1, sxk = 1, syk = 1, rank = 1)
	var/off = stflag ? 4 : -12
	var/along = stflag ? hs * (BEAMFX_CONTACT - (BEAMFX_CONTACT - off) * sxk) : off * hs
	var/x = hx + ax * along
	var/y = hy + ay * along
	var/zl = 5 + rank * 0.00001
	Emit(j, "[key]p", fam, st, 0, x, y, ang, hs * sxk, ws * hs * syk, 0, alpha * ((stflag && clash_mode) ? 0.85 : 1), 5, 0, "flame", 1, 0, zl)
	Emit(j, "[key]l", fam, st, 1, x, y, ang, hs * sxk, ws * hs * syk, 0, alpha, 0, 0, "hl", 1, 0, zl)

/datum/beamfx/proc/Flash(j, fi, Hr, hs, alpha, sxk = 1, syk = 1)
	if(alpha <= 0.002) return
	var/cfx = WX(Hr + BEAMFX_CONTACT - 1)
	var/cfy = WY(Hr + BEAMFX_CONTACT - 1)
	var/jit = 0.88 + 0.28 * ((BeamFXMod(fi, 97) * 62 + BeamFXMod(fi0, 97) * 31) % 97) / 97
	Emit(j, "fll", "Flash", "fl0", 1, cfx, cfy, ang, jit * hs * sxk, jit * hs * syk, 0, alpha, 0, 0, "flash", 1, 0, 6)

/datum/beamfx/proc/Frame(fi, j)
	var/t = FT(fi)
	if(isnull(t0) || t < t0) return
	ctx_f = fi
	var/Hr = Hr(t, fi, 0)
	if(isnull(Hr)) return
	var/dead = !isnull(dead_f) && fi >= dead_f
	var/ending = !isnull(end_t) && t >= end_t
	var/bk = Back(t, fi)
	var/growv = BeamFXEaseOut((t - t0) / 0.12)
	var/firing = isnull(release_f) || fi < release_f
	var/drain = !firing && ever_blocked
	var/rem = Hr - bk
	var/g_last = drain ? (1 - BeamFXSstep(BEAMFX_LAST_L, BEAMFX_LAST_L + 16, rem)) : 0
	var/g_fly = (!isnull(fly_f) && fi > fly_f) ? (1 - BeamFXSstep(95, 130, rem)) : 0
	var/flying = !isnull(fly_f) && fi > fly_f
	var/list/gone = list()
	for(var/si = 1 to stamp_m.len)
		var/m = stamp_m[si]
		if(stamp_tbf[si] > fi) continue
		var/dd = LatD(m, t, fi)
		if(dd > Hr + S * 1.5 || dd < bk - S * 1.5)
			gone += m
			continue
		var/a_in
		if(firing) a_in = BeamFXSstep(mz + BEAMFX_STREAM_IN0, mz + BEAMFX_STREAM_IN1, dd)
		else if(flying) a_in = BeamFXSstep(bk + 16, bk + 96, dd)
		else a_in = BeamFXSstep(bk, bk + 40, dd)
		var/a = a_in * (1 - BeamFXSstep(Hr + BEAMFX_STREAM_OUT0, Hr + BEAMFX_STREAM_OUT1, dd)) * (1 - g_last) * (1 - g_fly)
		if(dead && isnull(fly_t) && !drain) a *= max(0, 1 - (t - dead_t) / 0.15)
		if(ending) a = 0
		if(a <= 0.002) continue
		var/x = WX(dd)
		var/y = WY(dd)
		var/syk = 1
		var/la = a
		if(!firing)
			var/tk = flying ? BeamFXSstep(bk + 16, bk + 104, dd) : BeamFXSstep(bk, bk + 52, dd)
			syk = 0.3 + 0.7 * (tk ** 0.8)
			la = a * tk
		var/ph = BeamFXMod(m, BEAMFX_PHASES)
		var/zl = 4 + (m + 500) * 0.00001
		Emit(j, "s[m]p", "Stamp", "s[ph]", 0, x, y, ang, D / 32, ws * syk, 0, a, 4, m, "", 1, 0, zl)
		Emit(j, "s[m]l", "Stamp", "s[ph]", 1, x, y, ang, D / 32, ws * syk, 0, la, 0, m, "", 1, 0, zl)
	var/list/alive = list()
	var/oi = 1
	while(oi <= objs.len)
		var/datum/bfx_obj/o = objs[oi]
		oi++
		var/age = t - o.t0
		if(age < 0)
			alive += o
			continue
		switch(o.kind)
			if("bead", "streak", "surge")
				var/dd = o.d0 + o.v * age
				if(dd > Hr - 6 || (!firing && dd < bk - 30))
					if(o.kind == "surge" && dd > Hr - 6)
						var/ta = o.t0 + (Hr - 6 - o.d0) / o.v
						pulses += list(list(ta, o.scale))
						if(!isnull(t_hit) && Struggling(fi, 0) && isnull(end_t))
							ring_q += list(list(ta, o.scale))
					continue
				alive += o
				var/a = BeamFXSstep(mz + 10, mz + 40, dd) * (1 - BeamFXSstep(Hr - 46, Hr - 8, dd)) * BeamFXSstep(bk, bk + 24, dd)
				if(a <= 0.002) continue
				var/x = WX(dd, o.lat)
				var/y = WY(dd, o.lat)
				if(o.kind == "bead")
					Emit(j, "o[o.uid]l", "Bead", "bd0", 1, x, y, ang, 1, ws, 0, a, 0, 0, "accent", 1, 0, 5)
				else if(o.kind == "streak")
					Emit(j, "o[o.uid]l", "Sheath", "sh0", 1, x, y, ang, 1, 1, 0, a * 0.85, 0, 0, "accent", 1, 0, 5)
				else
					var/zl = 4.1 + (o.uid % 4000) * 0.000001
					Emit(j, "o[o.uid]p", "Surge", "su0", 0, x, y, ang, D / 32, ws * o.scale, 0, a * 0.9, 4.1, 0, "surge", 1, 0, zl, 1 / 0.9)
					Emit(j, "o[o.uid]l", "Surge", "su0", 1, x, y, ang, D / 32, ws * o.scale, 0, a, 0, 0, "surge", 1, 0, zl, -1)
			if("wedge")
				if(age >= o.life) continue
				alive += o
				var/q = age / o.life
				var/c = Struggling(fi, 0) ? Contact(t, fi, 0) : null
				var/cd = isnull(c) ? o.d0 : c
				var/bx = WX(cd - 2)
				var/by = WY(cd - 2)
				var/r0 = 3 + 7 * q
				var/ln = o.scale * (0.45 + 0.55 * BeamFXEaseOut(min(1, q / 0.45)))
				var/flip = (BeamFXMod(o.ang - ang, 360) < 180) ? 1 : -1
				var/ang_t = o.ang + 24 * flip * q
				var/cx = bx + cos(ang_t) * (r0 + 20 * ln)
				var/cy = by + sin(ang_t) * (r0 + 20 * ln)
				var/thin = 1 - 0.72 * BeamFXSstep(0.35, 1, q)
				var/fdw = min(1, age / 0.02) * (1 - BeamFXSstep(0.82, 1, q))
				var/al = fdw * (min(1, gain) ** 0.6)
				var/root = clash_mode ? (gain ** 0.25) : 1
				var/zl = 5.35 + (o.uid % 4000) * 0.000001
				Emit(j, "o[o.uid]p", "Wedge", "wg[o.seq]", 0, cx, cy, ang_t, ln * (1 + 0.1 * q), ln * flip * thin * root, 0, al * 0.9, 5.35, 0, "p", fdw, 0, zl, grey ? 0 : 1 / 0.9)
				Emit(j, "o[o.uid]l", "Wedge", "wg[o.seq]", 1, cx, cy, ang_t, ln * (1 + 0.1 * q), ln * flip * thin * root, 0, al, 0, 0, "wl", 1, 0, zl, grey ? 0 : -1)
			if("rarc")
				if(age >= o.life) continue
				alive += o
				ParticleFrame(o, fi)
			else
				if(age >= o.life) continue
				alive += o
				ParticleFrame(o, fi)
	objs = alive
	for(var/m in gone)
		var/gi = stamp_m.Find(m)
		if(gi)
			stamp_m.Cut(gi, gi + 1)
			stamp_tbf.Cut(gi, gi + 1)
	var/st = dead ? dead_struggle : Struggling(fi, 0)
	var/hs = min(0.55 + 0.45 * BeamFXEaseOut((t - t0) / 0.22), max(0.3, (Hr - mz + 8) / 62))
	for(var/list/p in pulses)
		if(p[1] <= t && t < p[1] + 0.22)
			hs *= 1 + 0.11 * p[2] * sin(180 * (t - p[1]) / 0.22)
	var/list/pk = list()
	for(var/list/p in pulses)
		if(p[1] > t - 0.3) pk += list(p)
	pulses = pk
	if(st) hs *= 1 + 0.05 * sin(360 * (t - t0) / 0.31) + 0.03 * sin(360 * (t - t0) / 0.17)
	var/f = floor((fi - fi0) / 4) % BEAMFX_NF
	var/fb = floor((fi - fi0) / 2) % BEAMFX_NF
	var/hx = WX(Hr)
	var/hy = WY(Hr)
	var/show = 1
	if(st && !isnull(end_t))
		if(t >= end_t)
			var/q = t - end_t
			var/rx = WX(Hr + BEAMFX_CONTACT - 8)
			var/ry = WY(Hr + BEAMFX_CONTACT - 8)
			if(!remnant_done)
				remnant_done = 1
				spk_shots += list(list("remnant", t, rx, ry))
			var/i = floor(q / 0.035 + 0.0001)
			if(i < 7)
				Head(j, "iA", "Impact", "ie[i]", hx, hy, hs * 1.05, 1, 1, 1.15, 0.92, 3)
				Flash(j, fi, Hr, hs * 1.15, max(0, 0.9 * (1 - q / 0.16)), 1.2, 0.9)
			else if(!erode_done)
				erode_done = 1
				spk_shots += list(list("erode", t, rx, ry))
			show = 0
		else
			var/qs = (t - swallow_t) / max(0.001, end_t - swallow_t)
			hs *= 1 + 0.1 * BeamFXEaseOut(qs)
	else if(dead && isnull(fly_t))
		var/q = t - dead_t
		if(q < 0.12)
			hs *= 1 + 0.22 * BeamFXEaseOut(q / 0.12)
		else
			var/i = floor((q - 0.12) / 0.04 + 0.0001)
			if(i < 10) Head(j, "hA", "Head", "he[i]", hx, hy, hs * 1.22, 0, 1, 1, 1, 1)
			show = 0
	if(!isnull(fly_t) && t >= fly_te)
		var/i = floor((t - fly_te) / 0.025 + 0.0001)
		if(i < 14) Head(j, "hA", "Head", "hf[i]", hx, hy, hs * (1 - 0.3 * i / 14), 0, 1, 1, 1, 1)
		show = 0
	var/pre_hit = st && (isnull(t_hit) || t < t_hit)
	if(show && pre_hit)
		Head(j, "hA", "Head", "h[fb]", hx, hy, hs, 0, 1, 1, 1, 1)
		show = 0
	if(show)
		if(st)
			var/qh = HitQ(t)
			if(qh < 0.999)
				var/c = Contact(t, fi, 0)
				var/hh = (isnull(c) ? Hr + BEAMFX_CONTACT : c) - 9
				Head(j, "hA", "Head", "h[fb]", WX(hh), WY(hh), hs, 0, 1 - qh, 1, 1, 1)
			var/hsb = hs * BurstScale(t) * (gain ** (clash_mode ? 0.45 : 0.2))
			var/ga = clash_mode ? (min(1, gain) ** 0.9) : 1
			if(g_last < 0.999)
				Head(j, "iA", "Impact", clash_mode ? "c[fb]" : "i[fb]", hx, hy, hsb, 1, (1 - g_last) * min(1, 0.3 + qh) * ga, 1, 1, 3)
			if(g_last > 0.001)
				Head(j, "iB", "Impact", clash_mode ? "cn[fb]" : "in[fb]", hx, hy, hsb, 1, g_last, 1, 1, 4)
				if(rem > 1)
					var/lx = WX(Hr + 2)
					var/ly = WY(Hr + 2)
					var/sxl = max(rem + 2, 2) / BEAMFX_LAST_L
					var/cxl = lx + ax * -36 * sxl
					var/cyl = ly + ay * -36 * sxl
					Emit(j, "lap", "Bloom", "la[f]", 0, cxl, cyl, ang, sxl, ws, 0, g_last, 4.3, 0, "flame", 1, 0, 4.3)
					Emit(j, "lal", "Bloom", "la[f]", 1, cxl, cyl, ang, sxl, ws, 0, g_last, 0, 0, "", 1, 0, 4.3)
			Flash(j, fi, Hr, hs * BurstScale(t), 0.9 * (0.4 + 0.6 * qh))
		else
			var/br = 1 + 0.04 * sin(360 * t / 0.23) + 0.025 * sin(360 * t / 0.37 + 74.4845133)
			var/jit = 1.2 * sin(360 * t / 0.29) + 0.6 * sin(360 * t / 0.13)
			var/jx = WX(Hr + jit)
			var/jy = WY(Hr + jit)
			if(g_fly < 0.999) Head(j, "hA", "Head", "h[fb]", jx, jy, hs * br, 0, 1 - g_fly, 1, 1, 1)
			if(g_fly > 0.001) Head(j, "hB", "Head", "fh[fb]", jx, jy, hs * br, 0, g_fly, 1, 1, 2)
	if(!no_bloom && (firing || fi < release_f + 4))
		var/q = firing ? 0 : (t - release_t) / 0.1
		var/cx = WX(mz)
		var/cy = WY(mz)
		var/sc = (0.4 + 0.6 * growv) * (1 - 0.85 * q) * (1 + 0.05 * sin(360 * (t - t0) / 0.37)) * bloom_k
		var/x = cx + ax * 14 * sc
		var/y = cy + ay * 14 * sc
		var/al = min(1, (t - t0) / 0.04) * ((1 - q) ** 1.2)
		var/g = firing ? BeamFXSstep(44, 80, Hr - mz) : 0
		if(1 - g > 0.002)
			Emit(j, "bbp", "Bloom", "bb[f]", 0, x, y, ang, sc, ws * sc, 0, al * (1 - g), 4.5, 0, "flame", 1, 0, 4.50001)
			Emit(j, "bbl", "Bloom", "bb[f]", 1, x, y, ang, sc, ws * sc, 0, al * (1 - g), 0, 0, "", 1, 0, 4.50001)
		if(g > 0.002)
			Emit(j, "blp", "Bloom", "b[f]", 0, x, y, ang, sc, ws * sc, 0, al * g, 4.5, 0, "flame", 1, 0, 4.50002)
			Emit(j, "bll", "Bloom", "b[f]", 1, x, y, ang, sc, ws * sc, 0, al * g, 0, 0, "", 1, 0, 4.50002)
	if(!firing && !(dead && isnull(fly_t) && !drain) && !ending)
		var/fly_ok = isnull(fly_t) || t < fly_te + 0.05
		var/ea = 1 - g_last
		if(rem > 6 && fly_ok && ea > 0.002)
			var/fe = !isnull(fly_t) ? 0 : (floor((fi - release_f) / 4) % BEAMFX_NF)
			var/sxe = D / 32 * min(1, max(0.25, rem / 80))
			var/ex = WX(bk + 28 * sxe)
			var/ey = WY(bk + 28 * sxe)
			var/fade = ea
			if(!isnull(fly_t)) fade = BeamFXSstep(55, 72, rem)
			Emit(j, "enp", "End", "e[fe]", 0, ex, ey, ang, sxe, ws, 0, fade, 4.2, 0, "flame", 1, 0, 4.2)
			Emit(j, "enl", "End", "e[fe]", 1, ex, ey, ang, sxe, ws, 0, fade, 0, 0, "", 1, 0, 4.2)

/datum/beamfx/proc/ParticleFrame(datum/bfx_obj/o, fi)
	if(!o.pre_done) Precompute(o, fi)
	if(!logging || !o.pre_specs) return
	var/idx = fi - o.pre_f0 + 1
	if(idx < 1 || idx > o.pre_specs.len) return
	var/list/pair = o.pre_specs[idx]
	if(!pair) return
	for(var/list/sp in pair)
		flog += list(sp)

/datum/beamfx/proc/ParticleSpec(datum/bfx_obj/o, t)
	var/age = t - o.t0
	var/q = age / o.life
	var/zl
	switch(o.kind)
		if("shard", "lance")
			var/list/P = FlowPos(o, age)
			var/sp = o.v * max(0, 1 - o.decel * age)
			var/is_shard = (o.kind == "shard")
			var/st_ = o.scale * (0.55 + sp / (is_shard ? 300 : 520)) * (1 - 0.4 * BeamFXSstep(0.5, 1, q))
			var/thin = 1 - 0.75 * BeamFXSstep(0.3, 1, q)
			var/al = min(1, age / 0.02) * (1 - BeamFXSstep(0.8, 1, q))
			var/fl_ = (o.lat < 0) ? -1 : 1
			var/fam = is_shard ? "Shard" : "Lance"
			var/tx = is_shard ? "sd[o.seq]" : "ln[o.seq]"
			zl = 5.4 + (o.uid % 4000) * 0.000001
			return list(list(fam, tx, 0, P[1], P[2], P[3], st_, thin * fl_, 0, al * 0.8, 5.4, 0, "p", al, 0, zl), list(fam, tx, 1, P[1], P[2], P[3], st_, thin * fl_, 0, al, 0, 0, "accent", 1, 0, zl))
		if("tongue")
			var/list/P = FlowPos(o, age)
			var/env = min(1, age / 0.04) * (1 - BeamFXSstep(0.8, 1, q))
			var/sc = 1 + o.grow * q
			var/flip = (o.omega >= 0) ? 1 : -1
			var/thin = 1 - 0.6 * BeamFXSstep(0.4, 1, q)
			zl = 5.25 + (o.uid % 4000) * 0.000001
			return list(list("Tongue", "tg[o.seq]", 0, P[1], P[2], P[3], sc * (1 + 0.3 * q), sc * ws * flip * thin, 0, env * 0.8, 5.25, 0, "p", env, 0, zl), list("Tongue", "tg[o.seq]", 1, P[1], P[2], P[3], sc * (1 + 0.3 * q), sc * ws * flip * thin, 0, env * 0.85, 0, 0, "wl", 1, 0, zl))
		if("curl")
			var/list/P = FlowPos(o, age)
			var/env = min(1, age / 0.05) * (1 - BeamFXSstep(0.4, 1, q))
			var/sc = 1 + o.grow * q
			var/al = env * 0.55
			zl = 5.2 + (o.uid % 4000) * 0.000001
			return list(list("Curl", "cu[o.seq]", 0, P[1], P[2], P[3], sc * (1 + 0.4 * q), sc * ws, 0, al * (1 - 0.5 * q), 5.2, 0, "p", env * (1 - 0.5 * q), 0, zl), list("Curl", "cu[o.seq]", 1, P[1], P[2], P[3], sc * (1 + 0.4 * q), sc * ws, 0, al, 0, 0, "accent", 1, 0, zl))
		if("arc")
			zl = 5.6 + (o.uid % 4000) * 0.000001
			return list(list("Arc", "ar[o.seq]", 0, o.x0, o.y0, o.ang, 1, 1, 0, 0.85, 5.6, 0, "arc", 1, 0, zl), list("Arc", "ar[o.seq]", 1, o.x0, o.y0, o.ang, 1, 1, 0, 0.9, 0, 0, "accent", 1, 0, zl))
		if("rarc")
			var/sc = o.scale * (0.35 + 1.45 * BeamFXEaseOut(q))
			var/fa = (1 - q) * min(1, age / 0.03)
			var/ba = clash_mode ? 0.5 : 0.62
			var/la_ = clash_mode ? 0.85 : 1
			zl = 5.7 + (o.uid % 4000) * 0.000001
			return list(list("Ring", "ra[o.seq]", 0, o.x0, o.y0, ang, sc * 0.42, sc * ws * o.omega, o.ang, ba * fa, 5.7, 0, clash_mode ? "ring_c" : "ring", fa, 0, zl), list("Ring", "ra[o.seq]", 1, o.x0, o.y0, ang, sc * 0.42, sc * ws * o.omega, o.ang, la_ * fa, 0, 0, "accent", 1, 0, zl))
		if("tw")
			var/tw = sin(180 * q) ** 1.5
			zl = 5
			return list(list("Speck", "ss0", 1, o.x0 + o.vx * age, o.y0 + o.vy * age, 0, 1, 1, 0, 0.9 * tw, 0, 0, "accent", 1, 0, zl))
	return null

/datum/beamfx/proc/Precompute(datum/bfx_obj/o, fi)
	o.pre_done = 1
	o.pre_f0 = fi
	o.pre_specs = list()
	var/f = fi
	while(1)
		var/t = FT(f)
		var/age = t - o.t0
		if(age >= o.life) break
		o.pre_specs += list(ParticleSpec(o, t))
		f++
		if(f - fi > 200) break
	if(new_chains) new_chains += o
