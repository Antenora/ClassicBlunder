#if fexists("../../../Icons/Private/EnergyFX/Comets/RelookCometsNAlpha.dmi") || fexists("Icons/Private/EnergyFX/Comets/RelookCometsNAlpha.dmi")
#define EFX92_COMETN_ALPHA 'Icons/Private/EnergyFX/Comets/RelookCometsNAlpha.dmi'
#else
#define EFX92_COMETN_ALPHA EFX92_COMETN
#endif

/datum/efx92_gather
	var/list/G
	var/list/CH
	var/period = 1
	var/wide = 0
	var/datum/bfx_rng/rng
	var/datum/bfx_rng/rng_b
	var/datum/bfx_rng/rng_f
	var/list/rays = list()
	var/list/bolts = list()
	var/list/flecks
	var/list/ring_on
	var/bx = 0
	var/by = 0
	var/list/body_pts
	var/t_rel
	var/L_rel = 1
	var/L_now = 0
	var/t_now = 0
	var/uid = 0
	var/sd = 0

/datum/efx92_comets
	var/list/items = list()
	var/list/recent = list()
	var/datum/bfx_rng/rng
	var/avoid
	var/t_rel
	var/acc = 0.9
	var/uid = 0
	var/reach_k = 1
	var/dur_k = 1

/datum/beamfx/var/datum/efx92_gather/rl_g
/datum/beamfx/var/datum/efx92_comets/rl_cm
/datum/beamfx/var/rl_gf0
/datum/beamfx/var/rl_L = 0
/datum/beamfx/var/rl_Lp = 0
/datum/beamfx/var/rl_gend = -1
/datum/beamfx/var/rl_gclock = 0
/datum/beamfx/var/datum/energyfx_charge/rl_gc

var/list/efx92_cspec

proc/EFX92CSpec()
	if(!efx92_cspec) efx92_cspec = json_decode(EFX92_CSPEC)
	return efx92_cspec

proc/EFX92SStep(e0, e1, x)
	var/t = clamp((x - e0) / (e1 - e0), 0, 1)
	return t * t * (3 - 2 * t)

proc/EFX92Wrap(a)
	return BeamFXMod(a + 180, 360) - 180

/datum/beamfx/proc/RLGT(fi)
	return FT(fi - rl_gf0)

/datum/beamfx/proc/RLGL(fi)
	var/L
	if(rl_gclock) L = RLGT(fi) / rl_g.period
	else L = BeamFXMod(fi - rl_gf0, 2) ? rl_L + (rl_L - rl_Lp) / 2 : rl_L
	return rl_g.wide ? L : min(1, L)

/datum/beamfx/proc/RLGLevelQ(L, frm)
	return min(1, max(0, (min(L, 1) - frm) / max(0.000001, 1 - frm)))

/datum/beamfx/proc/RLGWideKP(L)
	var/list/Wd = rl_g.G["wide"]
	if(!Wd) return 1
	var/ch = 0.5 + max(L, 0) * 0.5 * Wd["period"]
	var/w = min(max(0.85 + 0.3 * (ch - 0.5), 0.85), 1.3)
	if(ch > 2) w = min(1.3 * sqrt(ch / 2), 3)
	return EFX92KbOf(Wd["icon"] * w / 2.2, rl.P["rp"], rl.P["bloom_R"])

/datum/beamfx/proc/RLGRTarget(L)
	var/re = rl_g.G["R_end"]
	return (isnull(re) ? rl.P["bloom_R"] : re) * RLGWideKP(L)

/datum/beamfx/proc/RLGRadius(L)
	var/r0 = rl_g.G["r0"]
	return r0 + (RLGRTarget(L) - r0) * (min(1, max(0, L)) ** 0.8)

/datum/beamfx/proc/RLGCenter()
	var/list/Wd = rl_g.G["wide"]
	if(Wd)
		var/dw = mz + Wd["c0"] * RLGWideKP(rl_g.L_now)
		return list(WX(dw), WY(dw))
	var/cdx = rl_g.G["center_dx"]
	var/dm = mz + (isnull(cdx) ? rl.P["bloom_x"] : cdx)
	var/list/An = rl_g.G["anchor"]
	if(!An) return list(WX(dm), WY(dm))
	var/apx = rl_g.bx + An[1]
	var/apy = rl_g.by + An[2]
	if(isnull(rl_g.t_rel) || rl_g.t_now < rl_g.t_rel) return list(apx, apy)
	var/sw = rl_g.G["sweep"]
	var/m = min(1, (rl_g.t_now - rl_g.t_rel) / (isnull(sw) ? 0.1 : sw))
	var/e = m * m * (3 - 2 * m)
	return list(apx + (WX(dm) - apx) * e, apy + (WY(dm) - apy) * e)

/datum/beamfx/proc/RLGTwin(L, t)
	var/list/Tw = rl_g.G["twin"]
	var/list/cc = RLGCenter()
	if(!Tw) return list(list(cc[1], cc[2], RLGRadius(L)))
	var/Lc = min(L, 1)
	var/m = min(1, max(0, (Lc - Tw["split"]) / Tw["merge"]))
	if(!isnull(rl_g.t_rel) && t >= rl_g.t_rel)
		var/m_rel = min(1, max(0, (min(rl_g.L_rel, 1) - Tw["split"]) / Tw["merge"]))
		m = min(1, m_rel + (t - rl_g.t_rel) / Tw["rush"])
		Lc = max(Lc, min(rl_g.L_rel, 1))
	var/r_m = Tw["R"][2] * Tw["merge_k"]
	if(m >= 1)
		var/q = min(1, max(0, (Lc - Tw["split"] - Tw["merge"]) / max(0.000001, 1 - Tw["split"] - Tw["merge"])))
		return list(list(cc[1], cc[2], r_m + (RLGRTarget(max(L, Lc)) - r_m) * (q ** 0.8)))
	var/fx_ = cos(ang)
	var/fy_ = sin(ang)
	var/px_ = -fy_
	var/py_ = fx_
	var/rs = Tw["R"][1] + (Tw["R"][2] - Tw["R"][1]) * (min(1, Lc / Tw["split"]) ** 0.8)
	var/e = m * m * (3 - 2 * m)
	rs = rs + (r_m - rs) * EFX92SStep(0.6, 1, e)
	var/up = Tw["up"]
	var/dk = Tw["depth_k"]
	if(isnull(up)) up = 0
	if(isnull(dk)) dk = 1
	var/list/out = list()
	for(var/s in list(1, -1))
		var/sx = rl_g.bx + fx_ * Tw["fwd"] + px_ * s * Tw["off"]
		var/sy = rl_g.by + up + (fy_ * Tw["fwd"] + py_ * s * Tw["off"]) * dk
		var/bulge = Tw["arc"] * sin(180 * e)
		out[++out.len] = list(sx + (cc[1] - sx) * e + fx_ * bulge, sy + (cc[2] - sy) * e + fy_ * bulge, rs)
	return out

/datum/beamfx/proc/RLGBoltCfgs()
	var/Bt = rl_g.G["bolts"]
	if(!Bt) return list()
	var/list/Bl = Bt
	if(Bl["alive"]) return list(Bt)
	return Bt

/datum/beamfx/proc/RLGBoltArt()
	var/list/A = rl_g.CH["rbolts"]
	return A ? A : rl.A["rbolts"]

/datum/beamfx/proc/RLGSplashR(L)
	var/list/Sp = rl_g.G["splash"]
	if(!Sp) return 0
	var/q = RLGLevelQ(L, Sp["from_level"])
	var/r0 = Sp["R"][1] * Sp["r_start"]
	return r0 + (Sp["R"][2] - r0) * (q ** 0.8)

/datum/beamfx/proc/RLGTickBolts(now, L)
	var/list/cfgs = RLGBoltCfgs()
	var/list/A
	for(var/ci = 1 to cfgs.len)
		var/list/Bt = cfgs[ci]
		if(!isnull(rl_g.t_rel) || L < Bt["from_level"]) continue
		if(!A) A = RLGBoltArt()
		var/alive = 0
		for(var/list/b in rl_g.bolts)
			if(b[12] == ci && now < b[1] + b[4] * BEAMFX_TICK - 0.000001) alive++
		var/q = RLGLevelQ(L, Bt["from_level"])
		var/list/al = Bt["alive"]
		var/want = EFX92PyRound(al[1] + (al[2] - al[1]) * q)
		var/mode = Bt["mode"]
		var/radiate = (mode == "radiate" || mode == "twin")
		for(var/n = 1 to max(0, want - alive))
			var/bi = -1
			var/cx
			var/cy
			var/R
			if(mode == "twin")
				var/list/balls = RLGTwin(L, now)
				bi = rl_g.rng_b.RandRange(balls.len)
				var/list/bb = balls[bi + 1]
				cx = bb[1]
				cy = bb[2]
				R = bb[3]
			else if(mode == "radiate")
				cx = rl_g.bx
				cy = rl_g.by
				R = RLGSplashR(L)
			else if(mode == "body")
				cx = rl_g.bx
				cy = rl_g.by
				R = 0
			else
				var/list/cc = RLGCenter()
				cx = cc[1]
				cy = cc[2]
				R = RLGRadius(L)
			var/kind = (rl_g.rng_b.R() < Bt["long_p"]) ? "beam" : "short"
			var/list/AK = A[kind]
			var/var_ = rl_g.rng_b.RandRange(AK.len)
			var/sc = rl_g.rng_b.U(0.85, 1.15)
			var/list/V = AK[var_ + 1]
			var/Lb = V["L"] * sc
			var/x0
			var/y0
			var/a
			if(mode == "body")
				var/list/pt = rl_g.body_pts[rl_g.rng_b.RandRange(rl_g.body_pts.len) + 1]
				x0 = pt[1]
				y0 = pt[2]
				a = rl_g.rng_b.U(0, 360)
			else
				var/a0 = rl_g.rng_b.U(0, 360)
				var/list/rr = Bt["root_r"]
				var/r0 = R * rl_g.rng_b.U(rr[1], rr[2])
				x0 = cx + cos(a0) * r0
				y0 = cy + sin(a0) * r0
				var/turn = (rl_g.rng_b.R() < 0.5) ? 1 : -1
				var/list/tl = Bt["tilt"]
				if(radiate) a = a0 + turn * rl_g.rng_b.U(tl[1], tl[2])
				else a = a0 + turn * (90 - rl_g.rng_b.U(tl[1], tl[2]))
			var/x = x0 + cos(a) * Lb * 0.5
			var/y = y0 + sin(a) * Lb * 0.5
			var/list/vf = V["frames"]
			var/sy = (rl_g.rng_b.R() < 0.5) ? 1 : -1
			rl_g.uid++
			rl_g.bolts[++rl_g.bolts.len] = list(now, kind, var_, vf.len, sc, x, y, a, bi, x - cx, y - cy, ci, sy, rl_g.uid)

/datum/beamfx/proc/RLGBoltSprites(list/out, t, L)
	var/list/cfgs = RLGBoltCfgs()
	if(!cfgs.len) return
	var/list/A = RLGBoltArt()
	var/twin = 0
	for(var/list/c in cfgs)
		if(c["mode"] == "twin") twin = 1
	var/list/balls = twin ? RLGTwin(L, t) : null
	var/list/rals = list()
	for(var/list/Bt in cfgs)
		var/ral = 1
		if(!isnull(rl_g.t_rel) && t >= rl_g.t_rel)
			var/q = (t - rl_g.t_rel) / Bt["rel_fade"]
			ral = (q >= 1) ? 0 : (1 - q) ** 1.2
		rals += ral
	var/list/keep = list()
	for(var/list/b in rl_g.bolts)
		var/fi = RLAge(t, b[1])
		if(fi >= b[4] || rals[b[12]] <= 0) continue
		keep[++keep.len] = b
		if(fi < 0) continue
		var/list/Bt = cfgs[b[12]]
		var/list/AK = A[b[2]]
		var/list/V = AK[b[3] + 1]
		var/list/vf = V["frames"]
		var/x = b[6]
		var/y = b[7]
		if(balls && b[9] >= 0 && Bt["mode"] == "twin")
			var/list/bc = balls[min(b[9], balls.len - 1) + 1]
			x = bc[1] + b[10]
			y = bc[2] + b[11]
		var/tg = Bt["front"] ? "cbolt_f" : "cbolt"
		RLPair(out, vf[fi + 1], x, y, b[8], b[5], b[13] * b[5], rals[b[12]], 15.6, 0, null, null, tg, "gk[b[14]]")
	rl_g.bolts = keep

/datum/beamfx/proc/RLGTickFlecks(now, L)
	var/list/Fk = rl_g.G["flecks"]
	if(!Fk || !isnull(rl_g.t_rel)) return
	if(!rl_g.flecks)
		rl_g.flecks = list()
		rl_g.rng_f = new /datum/bfx_rng(97 + rl_g.sd)
	var/list/rt = Fk["rate"]
	var/rate = rt[1] + (rt[2] - rt[1]) * min(1, L)
	var/n = floor(rate) + ((rl_g.rng_f.R() < rate - floor(rate)) ? 1 : 0)
	var/R = RLGRadius(L)
	var/list/GA = rl.A["sparks"]
	var/list/fr = Fk["r"]
	var/list/fv = Fk["v"]
	var/list/fl = Fk["life"]
	var/list/fs = Fk["sc"]
	for(var/i = 1 to n)
		var/a = rl_g.rng_f.U(0, 360)
		var/r = R + rl_g.rng_f.U(fr[1], fr[2])
		var/t0 = now + rl_g.rng_f.U(0, BEAMFX_TICK)
		var/v = rl_g.rng_f.U(fv[1], fv[2])
		var/life = rl_g.rng_f.U(fl[1], fl[2])
		var/g = rl_g.rng_f.RandRange(GA.len)
		var/sc = rl_g.rng_f.U(fs[1], fs[2])
		rl_g.uid++
		rl_g.flecks[++rl_g.flecks.len] = list(t0, a, r, v, life, g, sc, rl_g.uid)

/datum/beamfx/proc/RLGFlecks(list/out, t)
	if(!rl_g.flecks) return
	var/list/cc = RLGCenter()
	var/list/GA = rl.A["sparks"]
	var/list/keep = list()
	for(var/list/f in rl_g.flecks)
		var/age = t - f[1]
		if(age >= f[5]) continue
		keep[++keep.len] = f
		if(age < 0) continue
		var/q = age / f[5]
		var/rr = f[3] + f[4] * age
		var/kk = f[7] * (0.7 + 0.3 * sin(180 * q))
		RLRec(out, GA[f[6] + 1], cc[1] + cos(f[2]) * rr, cc[2] + sin(f[2]) * rr, 0, kk, kk, sin(180 * q) ** 1.5, 0, 0, 1, null, "fleck", "gf[f[8]]")
	rl_g.flecks = keep

/datum/beamfx/proc/RLGTickRing(now, L)
	var/list/Rg = rl_g.G["ring"]
	if(!Rg) return
	if(!rl_g.ring_on)
		rl_g.ring_on = list()
		for(var/k2 = 1 to Rg["n"])
			rl_g.ring_on += null
	for(var/k2 = 0 to Rg["n"] - 1)
		var/lv = Rg["from_level"] + (Rg["to_level"] - Rg["from_level"]) * (k2 + 1) / Rg["n"]
		if(isnull(rl_g.ring_on[k2 + 1]) && L >= lv) rl_g.ring_on[k2 + 1] = now

/datum/beamfx/proc/RLGRing(list/out, t, L)
	var/list/Rg = rl_g.G["ring"]
	if(!Rg || !rl_g.ring_on) return
	var/ral = 1
	if(!isnull(rl_g.t_rel) && t >= rl_g.t_rel)
		var/q = (t - rl_g.t_rel) / Rg["fade"]
		if(q >= 1) return
		ral = 1 - q
	var/list/cc = RLGCenter()
	var/ax_ = cos(ang)
	var/ay_ = sin(ang)
	var/fi = RLAge(t, 0)
	var/full = 1
	for(var/v in rl_g.ring_on)
		if(isnull(v)) full = 0
	var/list/RA = rl_g.CH["ring"]
	for(var/k2 = 0 to rl_g.ring_on.len - 1)
		var/ton = rl_g.ring_on[k2 + 1]
		if(isnull(ton) || t < ton) continue
		var/th = 90 - k2 * 360 / Rg["n"]
		var/u = cos(th) * Rg["R"] * Rg["squash"]
		var/v = sin(th) * Rg["R"]
		var/x = cc[1] + ax_ * u - ay_ * v
		var/y = cc[2] + ay_ * u + ax_ * v
		var/j = RLAge(t, ton)
		var/al = ral
		if(full && j >= Rg["flash"]) al *= 1 - Rg["pulse"] * BeamFXMod(fi + k2, 2)
		RLPair(out, RA[(j < Rg["flash"]) ? 2 : 1], x, y, 0, 1, 1, al, (u < 0) ? 14.45 : 14.55, 0, null, null, "ring", "gr[k2]")

/datum/beamfx/proc/RLGSplash(list/out, t, L)
	var/list/Sp = rl_g.G["splash"]
	if(!Sp || L < Sp["from_level"]) return
	var/al = 1
	if(!isnull(rl_g.t_rel) && t >= rl_g.t_rel)
		var/f = (t - rl_g.t_rel) / Sp["fade"]
		if(f >= 1) return
		al = 1 - f
	var/Rb = RLGSplashR(L)
	var/list/sizes = rl_g.CH["splash"]
	var/list/Sz = sizes[1]
	var/bd = 1000000
	for(var/list/e in sizes)
		if(abs(e["R"] - Rb) < bd)
			bd = abs(e["R"] - Rb)
			Sz = e
	var/fi = RLAge(t, 0)
	var/k2 = Rb / Sz["R"]
	var/list/fr = Sz["frames"]
	RLPair(out, fr[BeamFXMod(fi, fr.len) + 1], rl_g.bx, rl_g.by, 0, k2, k2, al, 14, 0, null, null, "gsplash", "gs")

/datum/beamfx/proc/RLGBubble(list/out, t, L)
	var/list/Bb = rl_g.G["bubble"]
	if(!Bb) return
	var/q = RLGLevelQ(L, Bb["from_level"])
	var/al = Bb["alpha"] * q
	if(!isnull(rl_g.t_rel) && t >= rl_g.t_rel)
		var/f = (t - rl_g.t_rel) / Bb["fade"]
		if(f >= 1) return
		al *= 1 - f
	if(al <= 0.001) return
	var/list/BR = Bb["R"]
	var/Rb = BR[1] + (BR[2] - BR[1]) * (q ** 0.8)
	var/list/sizes = rl_g.CH["bubble"]
	var/list/Sz = sizes[1]
	var/bd = 1000000
	for(var/list/e in sizes)
		if(abs(e["R"] - Rb) < bd)
			bd = abs(e["R"] - Rb)
			Sz = e
	var/fi = RLAge(t, 0)
	var/k2 = Rb / Sz["R"]
	var/list/cc = RLGCenter()
	var/x = rl_g.bx + (cc[1] - rl_g.bx) * Bb["mid"]
	var/y = rl_g.by + (cc[2] - rl_g.by) * Bb["mid"]
	var/list/fr = Sz["frames"]
	RLPair(out, fr[BeamFXMod(fi, fr.len) + 1], x, y, 0, k2, k2, al, 14.2, 0, null, null, "bubble", "gu")

/datum/beamfx/proc/RLGTickRays(now, L)
	var/list/Ry = rl_g.G["rays"]
	var/list/RA = rl_g.CH["rays"]
	if(!Ry || !RA || !isnull(rl_g.t_rel) || L < Ry["from_level"]) return
	var/list/plan = Ry["plan"]
	var/alive = 0
	for(var/list/r in rl_g.rays)
		if(now < r[1] + plan.len * BEAMFX_TICK - 0.000001) alive++
	var/q = (min(L, 1) - Ry["from_level"]) / max(0.000001, 1 - Ry["from_level"])
	var/list/al = Ry["alive"]
	var/want = EFX92PyRound(al[1] + (al[2] - al[1]) * q)
	var/nv = RA.len
	var/list/root = Ry["root"]
	for(var/i = 1 to min(Ry["per_tick"], max(0, want - alive)))
		var/top = max(1, EFX92PyRound(1 + (nv - 1) * q))
		var/t0 = now + rl_g.rng.U(0, BEAMFX_TICK * 0.5)
		var/v = rl_g.rng.RandRange(top)
		var/a = rl_g.rng.U(0, 360)
		var/sc = rl_g.rng.U(0.85, 1.1)
		var/sy = (rl_g.rng.R() < 0.5) ? 1 : -1
		var/r0 = rl_g.rng.U(root[1], root[2])
		rl_g.uid++
		rl_g.rays[++rl_g.rays.len] = list(t0, v, a, sc, sy, r0, rl_g.uid)

/datum/beamfx/proc/RLGSprites(list/out, t, L)
	var/list/cc = RLGCenter()
	var/R = RLGRadius(L)
	var/ra = 1
	if(!isnull(rl_g.t_rel))
		var/rf = rl_g.G["rel_fade"]
		var/q = (t - rl_g.t_rel) / (isnull(rf) ? 0.05 : rf)
		if(q >= 1) return
		ra = 1 - q
	var/fi = RLAge(t, 0)
	var/pk = rl_g.G["pulse"]
	if(isnull(pk)) pk = 0.04
	var/pulse = 1 + pk * ((BeamFXMod(floor(fi / 2), 2) == 0) ? 1 : -1) * min(1, L * 2)
	var/list/Sg = rl_g.G["star"]
	if(Sg)
		var/list/sc = Sg["scales"]
		var/s_now = sc[1] + (sc[sc.len] - sc[1]) * (min(1, max(0, L)) ** 0.8)
		var/list/stars = rl_g.CH["star"]
		var/list/St = stars[1]
		var/bd = 1000000
		for(var/list/e in stars)
			if(abs(e["s"] - s_now) < bd)
				bd = abs(e["s"] - s_now)
				St = e
		var/k2 = s_now / St["s"]
		var/list/sa = St["art"]
		var/list/fr = sa["frames"]
		RLPair(out, fr[BeamFXMod(fi, fr.len) + 1], cc[1], cc[2], 0, k2, k2, ra, 14.6, 0, null, null, "gstar", "gt")
		return
	var/list/balls = rl_g.CH["balls"]
	var/list/tw = RLGTwin(L, t)
	for(var/bi = 0 to tw.len - 1)
		var/list/bb = tw[bi + 1]
		var/list/Bl = balls[1]
		var/bd = 1000000
		for(var/list/e in balls)
			if(abs(e["R"] - bb[3]) < bd)
				bd = abs(e["R"] - bb[3])
				Bl = e
		var/k2 = bb[3] / Bl["R"] * pulse
		var/list/fr = Bl["frames"]
		RLPair(out, fr[BeamFXMod(floor(fi / 2) + bi * 2, fr.len) + 1], bb[1], bb[2], ang, k2, k2, ra, 14.5, 0, null, null, "gball", "gb[bi]")
	var/list/Ry = rl_g.G["rays"]
	var/list/RA = rl_g.CH["rays"]
	if(Ry && RA)
		var/list/plan = Ry["plan"]
		var/list/keep = list()
		for(var/list/r in rl_g.rays)
			var/fj = RLAge(t, r[1])
			if(fj >= plan.len) continue
			keep[++keep.len] = r
			if(fj < 0) continue
			var/list/V = RA[r[2] + 1]
			var/list/vf = V["frames"]
			var/d = R * r[6] + V["ox"] * r[4]
			RLPair(out, vf[fj + 1], cc[1] + cos(r[3]) * d, cc[2] + sin(r[3]) * d, r[3], r[4], r[5] * r[4], ra, 14.4, 0, null, null, "gray_", "gy[r[7]]")
		rl_g.rays = keep

/datum/beamfx/proc/RLCWant(L)
	var/list/SP = EFX92CSpec()["SPEC"]
	var/list/al = SP["alive"]
	return EFX92PyRound(al[1] + (al[2] - al[1]) * min(L, 1) + (al[3] - al[2]) * min(max(L - 1, 0), 1))

/datum/beamfx/proc/RLCPick()
	var/list/SP = EFX92CSpec()["SPEC"]
	var/best = 0
	var/bg = -1
	for(var/i = 1 to SP["spacing_k"])
		var/a
		if(isnull(rl_cm.avoid)) a = rl_cm.rng.U(0, 360)
		else a = rl_cm.avoid + SP["avoid"] + rl_cm.rng.U(0, 360 - 2 * SP["avoid"])
		var/g = 180
		if(rl_cm.recent.len)
			g = 1000000
			for(var/b in rl_cm.recent)
				g = min(g, abs(EFX92Wrap(a - b)))
		if(g > bg)
			best = a
			bg = g
	rl_cm.recent += best
	while(rl_cm.recent.len > SP["recent"]) rl_cm.recent.Cut(1, 2)
	return best

/datum/beamfx/proc/RLCTick(now, L)
	if(!isnull(rl_cm.t_rel)) return
	var/list/SP = EFX92CSpec()["SPEC"]
	var/sp = 1 - SP["fast"] * min(L, 1.5) / 1.5
	var/list/du = SP["dur"]
	var/list/ret = SP["retract"]
	var/life = 0.5 * (du[1] + du[2]) * sp * rl_cm.dur_k + ret.len * BEAMFX_TICK
	rl_cm.acc += RLCWant(L) * rl_cm.dur_k * BEAMFX_TICK / life
	var/n = floor(rl_cm.acc)
	rl_cm.acc -= n
	var/list/hp = SP["head_p"]
	var/list/p0 = hp[1]
	var/list/p1 = hp[2]
	var/list/r0r = SP["r0"]
	var/list/drr = SP["drift"]
	for(var/i = 1 to min(SP["per_tick"], n))
		var/dur = rl_cm.rng.U(du[1], du[2]) * sp * rl_cm.dur_k
		var/u = rl_cm.rng.R()
		var/hi = p0.len - 1
		var/acc = 0
		for(var/j = 1 to p0.len)
			acc += p0[j] + (p1[j] - p0[j]) * min(L, 1)
			if(u < acc)
				hi = j - 1
				break
		var/kd = rl_cm.rng.RandInt(0, SP["delay"])
		var/t0 = now + kd * BEAMFX_TICK
		var/fa0 = EFX92PyRound(now / BEAMFX_FR)
		var/ts = 0
		if(kd == 1)
			var/ci = fa0 / 2 + 1
			ts = (ci >= 1 && ci <= length(EFX92_CTIE)) ? text2num(copytext(EFX92_CTIE, ci, ci + 1)) - 1 : 0
		var/a0 = RLCPick()
		var/r0 = rl_cm.rng.U(r0r[1], r0r[2]) * rl_cm.reach_k
		var/drift = rl_cm.rng.U(drr[1], drr[2]) * ((rl_cm.rng.R() < 0.5) ? 1 : -1)
		var/k2 = rl_cm.rng.U(0.9, 1.1)
		var/ph = rl_cm.rng.RandRange(2)
		rl_cm.uid++
		rl_cm.items[++rl_cm.items.len] = list("t0" = t0, "dur" = dur, "a0" = a0, "r0" = r0, "drift" = drift, "hi" = hi, "k" = k2, "ph" = ph, "done" = 0, "t_arr" = null, "ti" = 0, "uid" = rl_cm.uid, "back" = (rl_cm.core && !rl_cm.meld) ? 1 : 0, "fa" = fa0 + 2 * kd, "ts" = ts)

/datum/beamfx/proc/RLCRelease(t)
	var/list/SP = EFX92CSpec()["SPEC"]
	rl_cm.t_rel = t
	var/nr = EFX92PyRound(t / BEAMFX_FR)
	for(var/list/c in rl_cm.items)
		if(c["fa"] > nr || (c["fa"] == nr && c["ts"] >= 0))
			c["done"] = 1
			continue
		c["q_rel"] = min(1, (t - c["t0"]) / c["dur"])
		c["rush"] = SP["rush"] * (1 + rl_cm.rush_k * (1 - c["q_rel"]))

/datum/beamfx/proc/RLCQ(list/c, tq)
	if(!isnull(rl_cm.t_rel) && !isnull(c["q_rel"]) && tq > rl_cm.t_rel) return c["q_rel"] + (1 - c["q_rel"]) * (tq - rl_cm.t_rel) / c["rush"]
	return (tq - c["t0"]) / c["dur"]

/datum/beamfx/proc/RLCPos(list/c, q, cx, cy, Rr)
	var/list/SP = EFX92CSpec()["SPEC"]
	var/qc = min(max(q, 0), 1)
	var/e = SP["lin"] * qc + (1 - SP["lin"]) * (qc ** SP["pw"])
	var/r_end = rl_cm.core ? RLCCore(c["a0"] + c["drift"]) : Rr * SP["rim"]
	var/r = c["r0"] + (r_end - c["r0"]) * e
	var/a = c["a0"] + c["drift"] * e
	return list(cx + cos(a) * r, cy + sin(a) * r)

/datum/beamfx/proc/RLCTier(d)
	var/list/SP = EFX92CSpec()["SPEC"]
	var/list/lens = SP["lengths"]
	var/ti = 0
	for(var/i = 1 to lens.len)
		if(lens[i] <= d) ti = i - 1
	return ti

/datum/beamfx/proc/RLCDraw(list/out, list/c, x, y, a, ti, la)
	var/list/com = rl.CO
	var/list/row = com[c["hi"] + 1]
	var/list/V = row[ti + 1]
	var/k2 = c["k"]
	var/list/tex = V["tex"]
	var/list/pair = tex[BeamFXMod(c["ph"] + EFX92PyRound(c["step"]), 2) + 1]
	var/cx = x + cos(a) * V["ox"] * k2
	var/cy = y + sin(a) * V["ox"] * k2
	var/list/SP = EFX92CSpec()["SPEC"]
	var/tg = c["back"] ? "comet_b" : "comet"
	RLRec(out, pair[1], cx, cy, a, k2, k2, 1, SP["layer"] + 10, 0, 0, null, tg, "cm[c["uid"]]p")
	RLRec(out, pair[2], cx, cy, a, k2, k2, la, 0, 0, 1, null, tg, "cm[c["uid"]]l")

/datum/beamfx/proc/RLCSprites(list/out, t, L, Rr)
	var/list/SP = EFX92CSpec()["SPEC"]
	var/list/cen = rl_g ? RLGCenter() : list(rl_cm.cx, rl_cm.cy)
	var/tq = FT(floor(EFX92PyRound(t / BEAMFX_FR) / 2) * 2)
	var/list/lt = SP["light"]
	var/la = lt[1] + (lt[2] - lt[1]) * min(1, max(0, L))
	var/twin = rl_g && rl_g.G["twin"]
	var/list/ret = SP["retract"]
	var/tqi = floor(EFX92PyRound(t / BEAMFX_FR) / 2) * 2
	for(var/list/c in rl_cm.items)
		if(c["done"]) continue
		if(tqi < c["fa"] || (tqi == c["fa"] && c["ts"] > 0)) continue
		var/q = max(0, RLCQ(c, tq))
		var/cx = cen[1]
		var/cy = cen[2]
		var/Rc = Rr
		if(twin)
			var/list/balls = RLGTwin(L, tq)
			if(balls.len > 1)
				if(isnull(c["side"])) c["side"] = (sin(c["a0"] - ang) > 0) ? 0 : 1
				var/list/bb = balls[c["side"] + 1]
				cx = bb[1]
				cy = bb[2]
				Rc = bb[3]
			else
				var/list/b1 = balls[1]
				cx = b1[1]
				cy = b1[2]
				Rc = b1[3]
		c["step"] = (tq - c["t0"]) / BEAMFX_TICK
		var/dq = BEAMFX_TICK / c["dur"]
		if(!isnull(rl_cm.t_rel) && !isnull(c["q_rel"]) && tq > rl_cm.t_rel) dq = (1 - c["q_rel"]) * BEAMFX_TICK / c["rush"]
		if(q < 1 - 0.000000001)
			var/list/p = RLCPos(c, q, cx, cy, Rc)
			var/list/pp = RLCPos(c, q - dq, cx, cy, Rc)
			var/list/pn = RLCPos(c, min(1, q + dq), cx, cy, Rc)
			var/list/p0 = RLCPos(c, 0, cx, cy, Rc)
			var/a = arctan(pn[1] - p[1], pn[2] - p[2])
			var/d = min(max(SP["tail_min"], SP["tail_k"] * sqrt((p[1] - pp[1]) ** 2 + (p[2] - pp[2]) ** 2)), sqrt((p[1] - p0[1]) ** 2 + (p[2] - p0[2]) ** 2) + SP["tail_grow"])
			var/ti = RLCTier(d / c["k"])
			c["ti"] = ti
			c["ang"] = a
			RLCDraw(out, c, p[1], p[2], a, ti, la)
			continue
		if(isnull(c["t_arr"])) c["t_arr"] = tq
		var/j = EFX92PyRound((tq - c["t_arr"]) / BEAMFX_TICK)
		if(j >= ret.len)
			c["done"] = 1
			continue
		var/rushed = !isnull(rl_cm.t_rel) && tq > rl_cm.t_rel
		var/a2 = c["a0"] + c["drift"]
		var/rr
		if(!rl_cm.core) rr = Rc * (rushed ? 1 : ret[j + 1])
		else if(rl_cm.meld) rr = RLCCore(a2)
		else
			var/list/cret = SP["core_retract"]
			rr = RLCCore(a2) * (rushed ? 1 : cret[j + 1])
		var/ti2 = (j == 0) ? floor(c["ti"] / 2) : 0
		var/mx = cx + cos(a2) * rr
		var/my = cy + sin(a2) * rr
		if(rl_cm.meld && !c["melded"])
			c["melded"] = 1
			rl_cm.melds[++rl_cm.melds.len] = list(tq, mx, my, c["ang"], c["hi"], c["uid"])
		RLCDraw(out, c, mx, my, c["ang"], ti2, la)
	if(rl_cm.meld)
		var/list/MEL = EFX92CSpec()["MELD"]
		var/list/plan = MEL["plan"]
		var/list/keep = list()
		for(var/list/m in rl_cm.melds)
			var/j2 = EFX92PyRound((tq - m[1]) / BEAMFX_TICK)
			if(j2 >= plan.len) continue
			keep[++keep.len] = m
			var/list/pl = plan[j2 + 1]
			var/list/mrow = rl.ME[m[5] + 1]
			RLRec(out, mrow[j2 + 1], m[2] + cos(m[4]) * pl[1], m[3] + sin(m[4]) * pl[1], m[4], 1, 1, pl[3], 0, 0, 1, null, "meld", "md[m[6]]")
		rl_cm.melds = keep

/datum/beamfx/proc/RLGTick(kk)
	rl_cf = list(list(), list())
	rl_lcf = list(list(), list())
	rl_sf = list(list(null, null), list(null, null))
	rl_sw = list(null, null)
	if(isnull(rl_gf0))
		rl_gf0 = 2 * kk
		t0 = FT(rl_gf0)
		fi0 = rl_gf0
	if(!rl_gclock)
		rl_Lp = rl_L
		if(rl_gc && rl_gm && rl_gm.energyfx_charge == rl_gc) rl_L = max(0, rl_gc.level)
	var/qn = 2 * kk
	if(rl_csilk) RLCSilSync()
	if(!isnull(rl_g.t_rel)) return
	var/now = RLGT(qn)
	var/L = RLGL(qn)
	if(!isnull(rl_g.t_rel)) L = rl_g.L_rel
	rl_g.L_now = L
	rl_g.t_now = now
	RLGTickRays(now, L)
	RLGTickBolts(now, L)
	RLGTickRing(now, L)
	RLGTickFlecks(now, L)
	if(rl_cm) RLCTick(now, L)

/datum/beamfx/proc/RLGRelease(fi)
	if(!isnull(rl_g.t_rel)) return
	rl_g.L_rel = RLGL(fi - 1)
	rl_g.t_rel = RLGT(fi)
	rl_g.L_now = rl_g.L_rel
	if(rl_cm) RLCRelease(rl_g.t_rel)
	rl_gend = fi + 40

/datum/beamfx/proc/RLGFrame(fi, j)
	var/t = RLGT(fi)
	var/L = isnull(rl_g.t_rel) ? RLGL(fi) : rl_g.L_rel
	rl_g.L_now = L
	rl_g.t_now = t
	var/jr = isnull(rl_g.t_rel) ? -1 : EFX92PyRound((t - rl_g.t_rel) / BEAMFX_FR)
	var/list/out = list()
	if(jr < 8) RLGSplash(out, t, L)
	if(rl_cm && jr < 20) RLCSprites(out, t, L, (jr < 0) ? RLGRadius(L) : RLGRTarget(L))
	if(jr < 8)
		RLGBoltSprites(out, t, L)
		RLGRing(out, t, L)
	if(jr < 4) RLGSprites(out, t, L)
	if(jr < 20) RLGFlecks(out, t)
	if(jr < 8) RLGBubble(out, t, L)
	if(logging) RLLog(fi, out)
	if(rl_crt)
		var/list/rest = list()
		for(var/list/r in out)
			if(r[RL92_TAG] == "gsplash") RLGSplashPut(j, r)
			else rest[++rest.len] = r
		out = rest
	RLEmitAll(j, fi, out)

/datum/beamfx/proc/RLGSplashPut(j, list/r)
	if(!rl_csilm) return
	var/list/ic = BeamFXImageCenter(rl_csilm)
	var/list/ex = list(list("rsi", rl_crt, ic[1], ic[2], "u", MASK_INVERSE))
	RLPut(j, r[RL92_KEY], r, r[RL92_X], r[RL92_Y], r[RL92_ANG], r[RL92_SX], r[RL92_SY], r[RL92_KIND] ? 0 : r[RL92_LY], null, null, null, ex)

/datum/beamfx/proc/RLCSilSync()
	var/atom/movable/M = rl_csilm
	if(!M || !rl_csilk) return
	var/d4 = EFX92Dir4(M.dir)
	if(rl_csilk.icon != M.icon) rl_csilk.icon = M.icon
	if(rl_csilk.icon_state != M.icon_state) rl_csilk.icon_state = M.icon_state
	if(rl_csilk.dir != d4) rl_csilk.dir = d4

/datum/beamfx/CasterRimX(t, xs)
	if(!rl_g) return ..()
	if(isnull(rl_gf0) || (!isnull(rl_g.t_rel) && t - FT(rl_gf0) >= rl_g.t_rel)) return 0
	var/lk = rl_g.G["light"]
	var/L = rl_gclock ? (t - FT(rl_gf0)) / rl_g.period : rl_L
	return min(1, max(0, L) * 1.3) * (isnull(lk) ? 1 : lk)

/datum/beamfx/var/mob/rl_gm

/datum/energyfx_look/efx92charge/proc/MobCharge(mob/M, obj/Skills/Z)
	return EFX92ChargeStart(M, Z)

var/datum/energyfx_look/efx92charge/efx92_charge_look = new
/mob/var/tmp/datum/beamfx/efx92_chg

proc/EFX92ChargeRegister()
	if(!EFX92_ASSETS) return 0
	var/n = 0
	for(var/p in EFX92_SKILL)
		var/key = EFX92_SKILL[p]
		var/datum/efx92_row/RR = EFX92Row(key)
		if(!RR || !RR.G) continue
		var/datum/energyfx_row/R = ENERGYFX_REG[text2path(p)]
		if(!R) continue
		R.handler = efx92_charge_look
		if(!R.extra) R.extra = list()
		R.extra["own_charge"] = 1
		n++
	return n

proc/EFX92ChargeStart(mob/M, obj/Skills/Z)
	if(!M || !Z || !M.loc || !M.energyfx_charge) return 0
	var/key = EFX92_SKILL["[Z.type]"]
	var/datum/efx92_row/R = key ? EFX92Row(key) : null
	if(!R || !R.G) return 0
	if(M.efx92_chg) EFX92ChargeDrop(M.efx92_chg)
	var/dt = BeamFXDirText(M.dir)
	var/list/dv = BeamFXDirVec(dt)
	var/bx0 = (M.x - 1) * 32 + 16 + M.step_x
	var/by0 = (M.y - 1) * 32 + 16 + M.step_y
	beamfx_seed++
	var/datum/beamfx/F = new(dt, bx0 + dv[1] * 32, by0 + dv[2] * 32, M.z, EFX92_BAKE_W[key] ? EFX92_BAKE_W[key] : 1, (round(world.time, 1) * 7 + beamfx_seed * 131) % 30000, BeamFXSkillColor(Z), null, null)
	F.RLInit(key)
	var/datum/efx92_gather/G = new
	G.G = R.G
	G.CH = R.CH
	G.period = R.cperiod
	G.wide = R.G["wide"] ? 1 : 0
	var/sd = (round(world.time, 1) * 7 + beamfx_seed * 131) % 30000
	G.sd = sd
	G.rng = new /datum/bfx_rng(21 + sd)
	G.rng_b = new /datum/bfx_rng(28 + sd)
	G.bx = bx0
	G.by = by0
	var/list/bp = EFX92_BODYPTS[dt]
	G.body_pts = list()
	for(var/i = 1 to bp.len step 2)
		G.body_pts[++G.body_pts.len] = list(bx0 + bp[i], by0 + bp[i + 1])
	F.rl_g = G
	var/datum/efx92_comets/C = new
	C.rng = new /datum/bfx_rng(31 + sd)
	var/list/cc = F.RLGCenter()
	C.avoid = arctan(bx0 - cc[1], by0 - cc[2])
	F.rl_cm = C
	F.caster_mob = M
	F.owner = M
	F.rl_gm = M
	F.RLCSilOn(M)
	F.rl_gc = M.energyfx_charge
	M.efx92_chg = F
	EFX92KeepOn(M, key)
	EFX92ChargeLoop(F)
	return 1

proc/EFX92ChargeDrop(datum/beamfx/F)
	if(!F) return
	if(F.rl_gm && isnull(F.rl_g.t_rel) && F.rl_gm.efx92_keep_key == F.rl.key) EFX92KeepOff(F.rl_gm)
	if(F.rl_gm && F.rl_gm.efx92_chg == F) F.rl_gm.efx92_chg = null
	F.rl_gm = null
	F.rl_gc = null
	if(!F.finished)
		F.finished = 1
		F.Cleanup()

proc/EFX92ChargeLoop(datum/beamfx/F)
	set waitfor = 0
	while(F && !F.finished)
		var/mob/M = F.rl_gm
		if(!M || !M.loc || M.z != F.z)
			EFX92ChargeDrop(F)
			return
		if(isnull(F.rl_g.t_rel) && M.energyfx_charge != F.rl_gc && !isnull(F.rl_gf0))
			F.RLGRelease(2 * (F.k + 1))
		if(!isnull(F.rl_g.t_rel) && 2 * F.k > F.rl_gend)
			EFX92ChargeDrop(F)
			return
		var/u0 = world.tick_usage
		try
			F.Step()
		catch(var/exception/e)
			world.log << "EFX92: charge step failed ([e]) @ [e.file]:[e.line]"
			EFX92ChargeDrop(F)
			return
		beamfx_cost += max(0, world.tick_usage - u0)
		beamfx_cost_n++
		sleep(world.tick_lag)

/world/New()
	. = ..()
	EFX92ChargeRegister()

/mob/var/tmp/list/efx92_keep
/mob/var/tmp/efx92_keep_key
var/list/efx92_keep_cache = list()

proc/EFX92KeepImages(key)
	var/list/L = efx92_keep_cache[key]
	if(L) return L
	var/datum/efx92_row/R = EFX92Row(key)
	if(!R) return null
	L = list()
	var/list/seen = list()
	for(var/list/stt in R.S)
		var/fi = stt[1] + 1
		if(seen["[fi]"]) continue
		seen["[fi]"] = 1
		var/image/I = image(icon = R.F[fi], icon_state = stt[2])
		I.alpha = 0
		I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		L += I
	var/list/mseen = list()
	for(var/st in EFX92_M2_FILE)
		var/f = EFX92_M2_FILE[st]
		if(mseen["[f]"]) continue
		mseen["[f]"] = 1
		var/image/I2 = image(icon = f, icon_state = st)
		I2.alpha = 0
		I2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		L += I2
	efx92_keep_cache[key] = L
	return L

proc/EFX92KeepOn(mob/M, key)
	if(!M || !key || !EFX92_ASSETS) return
	if(M.efx92_keep_key == key) return
	EFX92KeepOff(M)
	var/list/L = EFX92KeepImages(key)
	if(!L) return
	M.overlays += L
	M.efx92_keep = L
	M.efx92_keep_key = key

proc/EFX92KeepOff(mob/M)
	if(!M || !M.efx92_keep) return
	M.overlays -= M.efx92_keep
	M.efx92_keep = null
	M.efx92_keep_key = null

/datum/efx92_comets/var/list/core
/datum/efx92_comets/var/meld = 0
/datum/efx92_comets/var/rush_k = 0
/datum/efx92_comets/var/list/melds = list()
/datum/efx92_comets/var/cx = 0
/datum/efx92_comets/var/cy = 0
/datum/efx92_comets/var/Rr = 0

/datum/beamfx/var/rl_ch = 0
/datum/beamfx/var/list/rl_cpm
/datum/beamfx/var/list/rl_clm
/datum/beamfx/var/atom/movable/rl_csrc
/datum/beamfx/var/rl_cmode
/datum/beamfx/var/rl_cramp = 0
/datum/beamfx/var/rl_clev = 0
/datum/beamfx/var/rl_clev0 = 0
/datum/beamfx/var/rl_clt = 0
/datum/beamfx/var/rl_cT = 0
/datum/beamfx/var/rl_cLrel = 1
/datum/beamfx/var/rl_cend = -1
/datum/beamfx/var/list/rl_cov
/datum/beamfx/var/list/rl_cbody
/datum/beamfx/var/rl_cbkey
/datum/beamfx/var/rl_crt
/datum/beamfx/var/obj/rl_csil
/datum/beamfx/var/obj/rl_csilk
/datum/beamfx/var/atom/movable/rl_csilm

/obj/efx92_sil
	appearance_flags = KEEP_TOGETHER | KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = 0

/obj/efx92_silk
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	mouse_opacity = 0

var/datum/efx92_row/efx92_cometn_row
var/list/efx92_contact_cache = list()
var/efx92_sil_n = 0

proc/EFX92CometRow()
	if(efx92_cometn_row) return efx92_cometn_row
	if(!EFX92_ASSETS) return null
	var/list/J = json_decode(EFX92_COMETN_META)
	if(!J) return null
	var/datum/efx92_row/R = new
	R.key = "COMETN"
	R.F = list(EFX92_COMETN_ALPHA)
	R.fams = list("R92COMETN_1")
	R.FW = list(J["W"])
	R.FH = list(J["H"])
	R.P = list()
	R.A = list()
	R.S = list()
	R.CO = list()
	R.ME = list()
	R.np = 1
	R.nph = 1
	R.period = 1
	BEAMFX_FAM["R92COMETN_1"] = list(EFX92_COMETN_ALPHA, J["W"], J["H"])
	efx92_fam["R92COMETN_1"] = R
	var/list/rows = J["rows"]
	for(var/hi = 1 to rows.len)
		var/list/row = rows[hi]
		var/list/orow = list()
		for(var/li = 1 to row.len)
			var/list/e = row[li]
			var/list/tex = list()
			for(var/f = 0 to 1)
				R.S[++R.S.len] = list(0, "p[hi - 1]_[li - 1]_[f]", 0, 0)
				R.S[++R.S.len] = list(0, "l[hi - 1]_[li - 1]_[f]", 0, 0)
				tex[++tex.len] = list(R.S.len - 2, R.S.len - 1)
			orow[++orow.len] = list("L" = e["L"], "ox" = e["ox"], "tex" = tex)
		R.CO[++R.CO.len] = orow
	var/list/ml = J["meld"]
	for(var/list/mr in ml)
		var/list/mrow = list()
		for(var/nm in mr)
			R.S[++R.S.len] = list(0, nm, 0, 0)
			mrow += R.S.len - 1
		R.ME[++R.ME.len] = mrow
	efx92_row_cache["COMETN"] = R
	efx92_cometn_row = R
	return R

proc/EFX92CometTint(list/colors)
	var/datum/energyfx_streaks/S = new
	S.colors = colors
	S.Paint()
	var/list/lc = S.ramp[1]
	var/list/lcore = S.ramp[4]
	var/g = S.light_k
	return list(S.paint_m.Copy(), list((lcore[1] - lc[1]) * g, (lcore[2] - lc[2]) * g, (lcore[3] - lc[3]) * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0))

/datum/beamfx/proc/RLObjFilter(light)
	if(rl_cpm) return list(filter(type = "color", color = light ? rl_clm : rl_cpm))
	return light ? null : EFX92PaintFilter()

/datum/beamfx/proc/RLCCore(a_deg)
	var/list/rs = rl_cm.core
	var/u = BeamFXMod(a_deg, 360) / 3
	var/i0 = BeamFXMod(floor(u), rs.len)
	var/f = u - floor(u)
	var/list/MEL = EFX92CSpec()["MELD"]
	return rs[i0 + 1] * (1 - f) + rs[BeamFXMod(i0 + 1, rs.len) + 1] * f - MEL["contact_in"]

proc/EFX92Dir4(d)
	if(d == NORTHEAST || d == SOUTHEAST) return EAST
	if(d == NORTHWEST || d == SOUTHWEST) return WEST
	return d

proc/EFX92Contact(ic, st, dr)
	if(!ic) return null
	var/key = "[ic]|[st]|[dr]"
	var/list/C = efx92_contact_cache[key]
	if(C) return C
	var/icon/I = new(ic, st, dr, 1)
	var/W = I.Width()
	var/H = I.Height()
	var/list/al = new /list(W * H)
	var/sw = 0
	var/sx = 0
	var/sy = 0
	for(var/y = 1 to H)
		var/row = H - y
		for(var/x = 1 to W)
			var/c = I.GetPixel(x, y)
			var/a = 0
			if(c) a = (length(c) >= 9) ? text2num(copytext(c, 8, 10), 16) / 255 : 1
			al[row * W + x] = a
			if(a > 0)
				sw += a
				sx += a * (x - 0.5)
				sy += a * (row + 0.5)
	if(sw <= 0) return null
	var/gx = sx / sw
	var/gy = sy / sw
	var/rneed = 0
	for(var/r2 = 0 to H - 1)
		for(var/x2 = 0 to W - 1)
			if(al[r2 * W + x2 + 1] > 0.5)
				rneed = max(rneed, sqrt(max((x2 - gx) ** 2, (x2 + 1 - gx) ** 2) + max((r2 - gy) ** 2, (r2 + 1 - gy) ** 2)))
	var/n0 = max(0, floor((48 - (rneed + 1)) / 0.25))
	var/list/rs = list()
	for(var/ai = 0 to 119)
		var/ca = cos(ai * 3)
		var/sa = sin(ai * 3)
		var/hit = 0
		for(var/n = n0 to 191)
			var/r = 48 - n * 0.25
			var/px = floor(gx + r * ca)
			var/py = floor(gy - r * sa)
			if(px >= 0 && px < W && py >= 0 && py < H && al[py * W + px + 1] > 0.5)
				hit = r
				break
		rs += hit
	C = list(gx, gy, W, H, rs)
	if(efx92_contact_cache.len < 256) efx92_contact_cache[key] = C
	return C

/datum/beamfx/proc/RLCBody()
	var/atom/movable/M = rl_csrc
	if(!M) return 0
	var/d4 = EFX92Dir4(M.dir)
	var/bk = "[M.icon]|[M.icon_state]|[d4]"
	if(bk != rl_cbkey)
		var/list/C = EFX92Contact(M.icon, M.icon_state, d4)
		if(!C) return 0
		rl_cbkey = bk
		rl_cbody = C
		rl_cm.core = C[5]
		if(rl_csilk)
			rl_csilk.icon = M.icon
			rl_csilk.icon_state = M.icon_state
			rl_csilk.dir = d4
	var/list/C2 = rl_cbody
	var/list/ic = BeamFXImageCenter(M)
	rl_cm.cx = ic[1] - C2[3] / 2 + C2[1]
	rl_cm.cy = ic[2] - C2[4] / 2 + (C2[4] - C2[2])
	return 1

/datum/beamfx/proc/RLCSilOn(atom/movable/M)
	efx92_sil_n++
	rl_crt = "*efx92sil[efx92_sil_n]"
	var/B = EFX92_BLANKS[1]
	var/list/sz = BeamFXIconSize(M)
	var/obj/efx92_sil/S = new
	S.icon = EFX92_BLANK_F[1]
	S.icon_state = "b"
	S.pixel_x = -(B - sz[1]) / 2
	S.pixel_y = -(B - sz[2]) / 2
	S.render_target = rl_crt
	var/obj/efx92_silk/K = new
	K.icon = M.icon
	K.icon_state = M.icon_state
	K.dir = EFX92Dir4(M.dir)
	K.pixel_x = (B - sz[1]) / 2
	K.pixel_y = (B - sz[2]) / 2
	S.vis_contents += K
	M.vis_contents += S
	rl_csil = S
	rl_csilk = K
	rl_csilm = M

/datum/beamfx/proc/RLCSilOff()
	if(rl_csil)
		if(rl_csilm) rl_csilm.vis_contents -= rl_csil
		rl_csil.vis_contents.Cut()
	rl_csil = null
	rl_csilk = null
	rl_csilm = null

proc/EFX92Cubic(q)
	if(q < 0.5) return 4 * q * q * q
	var/u = -2 * q + 2
	return 1 - u * u * u / 2

/datum/beamfx/proc/RLCOver(t)
	var/atom/movable/P = rl_csrc
	if(!P || !P.loc) return
	var/list/ov = rl_cov
	var/q = (ov[5] > 0) ? clamp(t / ov[5], 0, 1) : 1
	var/e = EFX92Cubic(q)
	var/pz = ov[1] + (ov[2] - ov[1]) * e
	var/sc = ov[3] + (ov[4] - ov[3]) * e
	rl_cm.cx = (P.x - 1) * 32 + P.step_x + P.pixel_x + P.pixel_w + ov[6] / 2
	rl_cm.cy = (P.y - 1) * 32 + P.step_y + P.pixel_y + pz + ov[7] / 2
	rl_cm.Rr = ov[6] / 2 * sc

/datum/beamfx/proc/RLCHPos(t)
	if(rl_cmode == "body")
		if(rl_csrc && rl_csrc.loc) RLCBody()
	else if(rl_cmode == "over") RLCOver(t)

/datum/beamfx/proc/RLCHL(t)
	if(rl_cT > 0) return min(1, max(0, t) / rl_cT)
	if(rl_cramp > 0) return rl_clev0 + (1 - rl_clev0) * clamp((t - rl_clt) / (rl_cramp / 10), 0, 1)
	return rl_clev

/datum/beamfx/proc/RLCHLevel(lv)
	var/t = isnull(rl_gf0) ? 0 : RLGT(2 * k + 1)
	rl_clev0 = RLCHL(t)
	rl_clev = max(0, lv)
	rl_clt = t

/datum/beamfx/proc/RLCHTick(kk)
	rl_cf = list(list(), list())
	rl_lcf = list(list(), list())
	rl_sf = list(list(null, null), list(null, null))
	rl_sw = list(null, null)
	if(isnull(rl_gf0))
		rl_gf0 = 2 * kk
		t0 = FT(rl_gf0)
		fi0 = rl_gf0
	var/now = RLGT(2 * kk)
	RLCHPos(now)
	if(!isnull(rl_cm.t_rel)) return
	RLCTick(now, RLCHL(now))

/datum/beamfx/proc/RLCHRelease(fi)
	if(!isnull(rl_cm.t_rel)) return
	rl_cLrel = RLCHL(RLGT(fi - 1))
	RLCRelease(RLGT(fi))
	rl_cend = fi + 40

/datum/beamfx/proc/RLCHFrame(fi, j)
	var/t = RLGT(fi)
	RLCHPos(t)
	var/L = isnull(rl_cm.t_rel) ? RLCHL(t) : rl_cLrel
	var/list/out = list()
	RLCSprites(out, t, L, rl_cm.Rr)
	if(logging) RLLog(fi, out)
	var/list/rest = list()
	for(var/list/r in out)
		if(r[RL92_TAG] == "meld") RLCMeldPut(j, r)
		else rest[++rest.len] = r
	RLEmitAll(j, fi, rest)

/datum/beamfx/proc/RLCMeldPut(j, list/r)
	if(!rl_crt || !rl_csrc) return
	var/kq = BeamFXMod(EFX92PyRound(BeamFXMod(r[RL92_ANG] + 180, 360) / 22.5), 16)
	var/a = kq * 22.5
	var/dx = EFX92PyRound(cos(a) * 2)
	var/dy = EFX92PyRound(sin(a) * 2)
	var/list/ic = BeamFXImageCenter(rl_csrc)
	var/list/ex = list(list("rs", rl_crt, ic[1], ic[2], "s", 0), list("rsi", rl_crt, ic[1] - dx, ic[2] - dy, "i[kq]", MASK_INVERSE))
	RLPut(j, r[RL92_KEY], r, r[RL92_X], r[RL92_Y], r[RL92_ANG], r[RL92_SX], r[RL92_SY], 0, null, null, null, ex)

proc/EFX92OverheadArt(obj/Skills/Projectile/_Projectile/P)
	var/mob/O = P.Owner
	var/obj/Skills/Projectile/Z = (O && P.SkillPath) ? (locate(P.SkillPath) in O) : null
	var/a = FxIconPaint(P.icon, P.icon_state)
	if(!a && Z) a = FxIconPaint(Z.IconLock, "tail")
	if(!a && Z) a = FxIconPaint(Z.IconLock, "head")
	return list(a)

proc/EFX92OverheadComets(obj/Skills/Projectile/_Projectile/P, T)
	if(!P || !glob || !glob.ENERGYFX || !EFX92_ASSETS || T <= 0) return null
	var/mob/O = P.Owner
	if(!O) return null
	var/obj/Skills/Projectile/Z = P.SkillPath ? (locate(P.SkillPath) in O) : null
	if(!Z || !Z.IconChargeOverhead) return null
	if(EnergyFXChargeDrawing(O, Z)) return null
	var/matrix/M = P.transform
	var/s0 = M ? sqrt(abs(M.a * M.e - M.b * M.d)) : 1
	var/z1 = Z.IconChargeOverhead * 32 - 1
	var/list/sz = BeamFXIconSize(P)
	var/list/ov = list(Z.IconSizeGrowTo ? P.pixel_z : z1, z1, s0, Z.IconSizeGrowTo ? Z.IconSizeGrowTo : s0, Z.IconSizeGrowTo ? T / 10 : 0, sz[1], sz[2])
	return EFX92CometStart(P, EFX92OverheadArt(P), 0, "over", T / 10, ov)

proc/EFX92CometStart(atom/movable/M, list/colors, ramp_ds, mode, period = 0, list/ov = null, reach_k = 1, dur_k = 1)
	if(!M || !M.loc || !EFX92_ASSETS) return null
	var/datum/efx92_row/R = EFX92CometRow()
	if(!R || !R.CO) return null
	beamfx_seed++
	var/sd = (round(world.time, 1) * 7 + beamfx_seed * 131) % 30000
	var/datum/beamfx/F = new("E", 0, 0, M.z, 1, sd, list(255, 255, 255), null, null)
	F.RLInit("COMETN")
	var/list/tm = EFX92CometTint(colors)
	F.rl_cpm = tm[1]
	F.rl_clm = tm[2]
	var/datum/efx92_comets/C = new
	C.rng = new /datum/bfx_rng(31 + sd)
	C.reach_k = reach_k
	C.dur_k = dur_k
	F.rl_cm = C
	F.rl_ch = 1
	F.rl_cmode = mode
	F.rl_csrc = M
	F.rl_cramp = ramp_ds
	F.rl_cT = period
	F.rl_cov = ov
	if(ismob(M)) F.caster_mob = M
	if(mode == "body")
		C.meld = 1
		C.rush_k = 2
		if(!F.RLCBody())
			F.finished = 1
			F.Cleanup()
			return null
		F.RLCSilOn(M)
	else
		F.RLCOver(0)
	EFX92CometLoop(F)
	return F

proc/EFX92CometDrop(datum/beamfx/F)
	if(!F || F.finished) return
	F.finished = 1
	F.Cleanup()

proc/EFX92CometRelease(datum/beamfx/F)
	if(!F || F.finished) return
	if(isnull(F.rl_gf0))
		EFX92CometDrop(F)
		return
	F.RLCHRelease(2 * (F.k + 1))

proc/EFX92CometLoop(datum/beamfx/F)
	set waitfor = 0
	while(F && !F.finished)
		var/atom/movable/M = F.rl_csrc
		if(M && (!M.loc || M.z != F.z))
			F.rl_csrc = null
			M = null
		if(!M)
			if(F.rl_cmode == "body" || isnull(F.rl_gf0))
				EFX92CometDrop(F)
				return
			if(isnull(F.rl_cm.t_rel)) F.RLCHRelease(2 * (F.k + 1))
		if(isnull(F.rl_cm.t_rel) && !isnull(F.rl_gf0) && F.rl_cmode == "over" && F.rl_cT > 0 && F.RLGT(2 * (F.k + 1)) >= F.rl_cT) F.RLCHRelease(2 * (F.k + 1))
		if(!isnull(F.rl_cm.t_rel) && 2 * F.k > F.rl_cend)
			EFX92CometDrop(F)
			return
		var/u0 = world.tick_usage
		try
			F.Step()
		catch(var/exception/e)
			world.log << "EFX92: comet step failed ([e]) @ [e.file]:[e.line]"
			EFX92CometDrop(F)
			return
		beamfx_cost += max(0, world.tick_usage - u0)
		beamfx_cost_n++
		sleep(world.tick_lag)

/datum/beamfx/Cleanup()
	..()
	if(rl_ch || rl_g) RLCSilOff()

var/list/efx92_cut_cache = list()

proc/EFX92CutIcon(list/pal, list/anc)
	var/key = "[pal[1]],[pal[2]]|[anc ? "[anc[1]],[anc[2]]" : "-"]"
	var/icon/I = efx92_cut_cache[key]
	if(I) return I
	I = new(EFX92_BLANK_F[1], "b")
	I.Crop(1, 1, 96, 96)
	for(var/x = 1 to 96)
		var/px = x - 48.5
		for(var/y = 1 to 96)
			var/py = y - 48.5
			var/a = 2.718281828459045 ** (-((px - pal[1]) ** 2 + (py - pal[2]) ** 2) / 49)
			if(anc) a = max(a, 2.718281828459045 ** (-((px - anc[1]) ** 2 + (py - anc[2]) ** 2) / 98))
			var/v = round(0.8 * a * 255 + 0.5)
			if(v > 0) I.DrawBox(rgb(255, 255, 255, v), x, y)
	if(efx92_cut_cache.len < 128) efx92_cut_cache[key] = I
	return I

/datum/bfx_char/Refresh(datum/beamfx/F, fkey2, list/above, list/spill, list/palm, list/tl)
	var/same = (M && M.appearance == app && fkey2 == fkey)
	..()
	if(same || !F || !F.rl_g || role != 1 || !palm || !occ || !locc) return
	var/list/anc
	var/list/An = F.rl_g.G["anchor"]
	if(An)
		var/list/cc = BeamFXImageCenter(M)
		anc = list(F.rl_g.bx + An[1] - cc[1], F.rl_g.by + An[2] - cc[2])
	var/icon/I = EFX92CutIcon(palm, anc)
	var/list/fo = list()
	var/list/fl = list()
	if(above)
		fo += filter(type = "alpha", icon = BeamFXMaskIcon("above"), x = above[1], y = above[2])
		fl += filter(type = "alpha", icon = BeamFXMaskIcon("above"), x = above[1], y = above[2])
	fo += filter(type = "alpha", icon = I, flags = MASK_INVERSE)
	fl += filter(type = "alpha", icon = I, flags = MASK_INVERSE)
	occ.filters = fo
	locc.filters = fl

/datum/beamfx/Holds()
	if(rl_g || rl_ch) return list()
	return ..()

/datum/beamfx/Q(i, list/hl)
	if(rl_g || (rl_ch && rl_cmode == "over")) return i
	return ..()

/datum/beamfx/CharsTick()
	if(rl_ch) return
	return ..()

/datum/energyfx_streaks/var/datum/beamfx/rl92h
/datum/energyfx_streaks/var/rl92src

/datum/energyfx_streaks/Start(atom/movable/m, list/c, r_ds, oh)
	if(!EFX92_ASSETS) return 0
	. = ..()
	if(!. || oh) return
	if(ismob(m))
		var/mob/M2 = m
		if(M2.energyfx_charge)
			var/obj/Skills/Z = M2.energyfx_charge.Z
			if(Z && EFX92_SKILL["[Z.type]"] && EnergyFXChargeDrawing(M2, Z)) return
		else if(M2.held_skill) rl92src = "held"
	rl92h = EFX92CometStart(m, c, r_ds, "body")

/datum/energyfx_streaks/Build()
	carrier = Get(/obj/energyfx/chghost, M, KEEP_APART | RESET_COLOR)
	if(!carrier) return 0
	return 1

/datum/energyfx_streaks/Level(lv)
	..()
	if(rl92h && !rl92h.finished) rl92h.RLCHLevel(lv)

/datum/energyfx_streaks/Off()
	if(rl92h)
		EFX92CometRelease(rl92h)
		rl92h = null
	if(!live) return
	live = 0
	ENERGYFX_CHG_LIVE -= src
	if(M && M.energyfx_streaks == src) M.energyfx_streaks = null
	if(!M || !carrier)
		Drop()
		return
	var/t = Now()
	var/cur = EnergyFXChgRound(EnergyFXChgAt(ca_tr, t))
	var/list/st = list()
	for(var/list/im in ENERGYFX_CHG_IMPLODE)
		st[++st.len] = list(im[1], CarrierTf(EnergyFXChgR3(ks * im[2])), EnergyFXChgRound(cur * im[3]))
	Run(carrier, st, 0)
	GlowEnvelope(st, cur)
	Flash(cur)
	var/ticks = max(1, EnergyFXChgRound(ENERGYFX_CHG_FREE_Q * 0.25 / world.tick_lag))
	for(var/obj/energyfx/O in objs)
		EnergyFXDue(O, ticks)
	objs = list()
	carrier = null
	ghost = null
	glow = null
	gpulse = null

/datum/energyfx_streaks/Drop()
	if(rl92h)
		EFX92CometDrop(rl92h)
		rl92h = null
	..()

/mob/EnergyFXChargeClear()
	..()
	var/datum/energyfx_streaks/S = energyfx_streaks
	if(S && S.rl92src == "held") EnergyFXStreaksOff(src)
