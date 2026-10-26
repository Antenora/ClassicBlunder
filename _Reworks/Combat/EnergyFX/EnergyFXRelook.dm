#define RL92_ST 1
#define RL92_X 2
#define RL92_Y 3
#define RL92_ANG 4
#define RL92_SX 5
#define RL92_SY 6
#define RL92_AL 7
#define RL92_LY 8
#define RL92_OR 9
#define RL92_KIND 10
#define RL92_CUTS 11
#define RL92_TAG 12
#define RL92_BALL 13
#define RL92_KEY 14
#define RL92_SH 15
#define RL92_END 16

var/list/efx92_row_cache = list()
var/list/efx92_fam = list()
var/list/EFX92_IDENTITY = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0)

/obj/energyfx/rlpaint
	plane = ENERGYFX_PAINT_PLANE

/obj/energyfx/rlsharp
	plane = ENERGYFX_SHARP_PLANE
	blend_mode = BLEND_ADD

/datum/efx92_row
	var/key
	var/list/P
	var/list/A
	var/list/B
	var/list/S
	var/list/F
	var/list/FW
	var/list/FH
	var/list/fams
	var/list/CL
	var/list/FE
	var/list/CH
	var/list/CO
	var/list/ME
	var/list/G
	var/cperiod = 1
	var/bake_w = 1
	var/nph = 24
	var/np = 12
	var/period = 192
	var/nsparks = 0

proc/EFX92Row(key)
	var/datum/efx92_row/R = efx92_row_cache[key]
	if(R) return R
	var/list/blob = EFX92Blob(key)
	if(!blob) return null
	var/list/J = json_decode(blob[2])
	if(!J) return null
	R = new
	R.key = key
	R.F = blob[1]
	R.P = J["P"]
	R.A = J["art"]
	R.B = J["burst"]
	R.S = J["states"]
	R.CL = J["clash"]
	R.FE = J["feint"]
	var/list/CJ = J["charge"]
	if(CJ)
		R.CH = CJ["gather"]
		R.CO = CJ["comets"]
		R.ME = CJ["meld"]
	R.G = J["G"]
	R.cperiod = J["period"] ? J["period"] : 1
	R.FW = list()
	R.FH = list()
	R.fams = list()
	var/list/files = J["files"]
	for(var/i = 1 to files.len)
		var/list/wh = files[i]
		var/fam = "R92[key]_[i]"
		R.FW += wh[1]
		R.FH += wh[2]
		R.fams += fam
		BEAMFX_FAM[fam] = list(R.F[i], wh[1], wh[2])
		efx92_fam[fam] = R
	var/bw = EFX92_BAKE_W[key]
	R.bake_w = bw ? bw : 1
	R.nph = R.P["NPH"]
	R.np = R.P["NP"]
	R.period = R.P["S"] * R.np
	var/list/sp = R.A["sparks"]
	R.nsparks = sp ? sp.len : 0
	efx92_row_cache[key] = R
	return R

proc/EFX92PaintFilter()
	return list(filter(type = "color", color = EFX92_IDENTITY))

proc/EFX92FoldA(list/c, al)
	var/list/m = c.Copy()
	var/k = clamp(al, 0, 255) / 255
	m[4] *= k
	m[8] *= k
	m[12] *= k
	m[16] *= k
	m[20] *= k
	return m

proc/EFX92PyRound(x)
	var/f = floor(x)
	var/d = x - f
	if(d > 0.5) return f + 1
	if(d < 0.5) return f
	return (BeamFXMod(f, 2) == 0) ? f : f + 1

proc/EFX92KbOf(k, rp, R)
	return max(sqrt(k), EFX92_MARGIN * k * rp / R)

/datum/beamfx/var/datum/efx92_row/rl
/datum/beamfx/var/rl_seed = 11
/datum/beamfx/var/rl_k = 1
/datum/beamfx/var/rl_st = 1
/datum/beamfx/var/qstep = 8
/datum/beamfx/var/datum/bfx_rng/rng2
/datum/beamfx/var/datum/bfx_rng/rng4
/datum/beamfx/var/datum/bfx_rng/rng5
/datum/beamfx/var/datum/bfx_rng/rng6
/datum/beamfx/var/datum/bfx_rng/rng7
/datum/beamfx/var/list/rl_sparks = list()
/datum/beamfx/var/list/rl_glints = list()
/datum/beamfx/var/list/rl_flares = list()
/datum/beamfx/var/list/rl_arrived = list()
/datum/beamfx/var/list/rl_lrays = list()
/datum/beamfx/var/list/rl_shocks = list()
/datum/beamfx/var/list/rl_rbolts = list()
/datum/beamfx/var/list/rl_cbolts = list()
/datum/beamfx/var/rl_next_shock
/datum/beamfx/var/rl_lray_rel_done = 0
/datum/beamfx/var/rl_end_phase
/datum/beamfx/var/rl_end_xh
/datum/beamfx/var/rl_no_drain = 0
/datum/beamfx/var/rl_uid = 0
/datum/beamfx/var/list/rl_cart
/datum/beamfx/var/rl_clash_split = 0
/datum/beamfx/var/list/rl_clash_ev
/datum/beamfx/var/rl_draw = 1
/datum/beamfx/var/rl_pierce = 0
/datum/beamfx/var/datum/bfx_rng/rng3
/datum/beamfx/var/list/rl_bolts = list()
/datum/beamfx/var/list/rl_sparks2 = list()
/datum/beamfx/var/list/rl_pts = list()

/datum/beamfx/New(dir_text, ox, oy, zlevel, width, seed, list/C255, list/core255, list/glow255)
	rl_seed = seed
	..()

/datum/beam/FxEligible(obj/Skills/Projectile/Z)
	if(!EFX92_ASSETS) return 0
	return ..()

/obj/Skills/Projectile/EnergyFXFeint(mob/p)
	if(!EFX92_ASSETS) return 0
	return ..()

/datum/beam/FxStart(mob/M, obj/Skills/Projectile/Z)
	var/datum/beamfx/F = ..()
	if(F && Z && EFX92_ASSETS)
		var/key = EFX92_SKILL["[Z.type]"]
		if(key)
			F.RLInit(key)
			if(M) EFX92KeepOn(M, key)
	return F

/datum/beamfx/proc/RLInit(key)
	rl = EFX92Row(key)
	if(!rl) return 0
	rng2 = new /datum/bfx_rng(rl_seed + 1000)
	rng4 = new /datum/bfx_rng(rl_seed + 3000)
	rng5 = new /datum/bfx_rng(rl_seed + 4000)
	rng6 = new /datum/bfx_rng(rl_seed + 5000)
	rng7 = new /datum/bfx_rng(rl_seed + 6000)
	rl_k = ws / rl.bake_w
	rl_no_drain = (abs(rl_k - 1) > 0.000001) ? 1 : 0
	rl_pierce = rl.P["helix"] ? 1 : 0
	if(rl_pierce) rng3 = new /datum/bfx_rng(rl_seed + 2000)
	var/stk = (length(d) == 2) ? sqrt(2) : 1
	var/sk = rl.P["s_k"]
	if(isnull(sk)) sk = 0.5
	var/ext = EFX92_EXT[key] * max(1, rl_k) * stk
	var/need = 2 * (max(ext, 32 * stk * sk * (rl.np - 1) / 2 + ext) + 56)
	rl_gspark = rl.A["sparks"]
	rl_carB = EFX92_BLANKS[EFX92_BLANKS.len]
	rl_carF = EFX92_BLANK_F[EFX92_BLANKS.len]
	for(var/bi = 1 to EFX92_BLANKS.len)
		if(EFX92_BLANKS[bi] >= need)
			rl_carB = EFX92_BLANKS[bi]
			rl_carF = EFX92_BLANK_F[bi]
			break
	SetDir(d)
	return 1

/datum/beamfx/SetDir(dir_text)
	..()
	if(!rl) return
	rl_st = (length(d) == 2) ? sqrt(2) : 1
	var/sk = rl.P["s_k"]
	if(isnull(sk)) sk = 0.5
	var/fl = rl.P["flow"]
	if(isnull(fl)) fl = 0.5
	S = D * sk
	Vs = fl * Vg
	qstep = rl.period / rl.nph * rl_st
	var/list/mo = EFX92_MOUTH[rl.key]
	if(mo)
		var/list/h = mo[d]
		var/along = h[1] * ax + h[2] * ay
		lat0 = h[1] * nx + h[2] * ny
		mz = along - D
		dstart = mz + 8

/datum/beamfx/proc/RLP(name, def)
	var/v = rl.P[name]
	return isnull(v) ? def : v

/datum/beamfx/proc/RLDraw(fi)
	return floor((fi - fi0 + 1) / 2)

/datum/beamfx/proc/RLSnap(dd, t, fi)
	var/tau = dd - dstart - LatBase(t, fi)
	var/i = EFX92PyRound(tau / qstep)
	return list(dd + i * qstep - tau, BeamFXMod(i, rl.nph))

/datum/beamfx/proc/RLCut(dd, sgn, soft = 1)
	return list(WX(dd), WY(dd), ax * sgn, ay * sgn, soft)

/datum/beamfx/proc/RLRec(list/out, si, x, y, a, sx, sy, alpha, layer, order, kind, list/cuts, tag, key, list/ball = null, list/sh = null, endf = 0)
	if(!rl_draw) return
	out[++out.len] = list(si, x, y, a, sx, sy, alpha, layer, order, kind, cuts ? cuts : list(), tag, ball, key, sh, endf)

/datum/beamfx/proc/RLPair(list/out, list/pair, x, y, a, sx, sy, alpha, layer, order, list/pcuts, list/acuts, tag, key, list/ball = null, list/frames = null, ph = 0, endf = 0)
	if(!rl_draw) return
	var/list/shp = frames ? list(frames, ph, 1) : null
	var/list/sha = frames ? list(frames, ph, 2) : null
	RLRec(out, pair[1], x, y, a, sx, sy, alpha, layer, order, 0, pcuts, tag, "[key]p", ball, shp, endf)
	RLRec(out, pair[2], x, y, a, sx, sy, alpha, 0, 0, 1, acuts, tag, "[key]l", ball, sha, endf)

/datum/beamfx/proc/RLHeadGeom(t, fi, Hrv, st, nd)
	var/list/heads = rl.A["heads"]
	var/s = 0
	if(st && !isnull(t_hit) && t >= t_hit) s = HitQ(t)
	if(!isnull(end_t) && t >= end_t - 0.000001) s = 1
	var/k
	if(s > 0) k = 2 + EFX92PyRound(s * (heads.len - 3))
	else k = min(2, nd)
	var/list/Hd = heads[k + 1]
	var/front = Hrv + EFX92_CONTACT + 1 + 3 * s
	var/em_front = mz + rl.P["bloom_x"] * rl_st + 6 + Vg * 1.3 * max(0, t - t0)
	if(st && !isnull(t_hit) && t >= t_hit - 0.000001 && !clash_mode)
		var/c = Contact(t, fi, 0)
		if(!isnull(c))
			var/list/Hl = heads[heads.len]
			return list(Hd, k, min(c + 4, em_front) - Hl["R"] * Hl["sq"] * rl_st)
	front = min(front, em_front)
	return list(Hd, k, front - Hd["R"] * Hd["sq"] * rl_st)

proc/EFX92RingTie(j)
	if(j < 0 || j >= length(EFX92_RTIE)) return 0
	return copytext(EFX92_RTIE, j + 1, j + 2) == "1"

/datum/beamfx/proc/RLAge(t, ta)
	var/fa = ta / BEAMFX_FR
	var/ia = round(fa, 1)
	if(abs(fa - ia) < 0.001)
		var/fd = round(t / BEAMFX_FR, 1) - ia
		return floor((fd + 1) / 2)
	return EFX92PyRound((t - ta) / BEAMFX_TICK + 0.000001)

/datum/beamfx/Tick(kk)
	if(!rl) return ..()
	if(rl_g)
		RLGTick(kk)
		return
	if(rl_ch)
		RLCHTick(kk)
		return
	if(rl_raw.len)
		for(var/key in rl_raw.Copy())
			if(text2num(key) < 2 * kk - 16) rl_raw -= key
		for(var/key in rl_remap.Copy())
			if(text2num(key) < 2 * kk - 16)
				rl_remap -= key
				rl_remapv -= key
	if(!ch_on)
		rl_cf = list(list(), list())
		rl_lcf = list(list(), list())
		rl_sf = list(list(null, null), list(null, null))
		rl_sw = list(null, null)
	if(clash_mode && partner && !rl_cart) RLClashSetup()
	else if(!clash_mode && rl_cart)
		rl_cart = null
		rl_clash_ev = null
		rl_cbolts = list()
		rl_gspark = rl.A["sparks"]
	var/qn = 2 * kk
	var/now = FT(qn)
	var/lr0 = last_ring
	var/nudged = 0
	if(!isnull(t_hit) && lr0 >= 0)
		var/tr = max(now, t_hit)
		var/fa = tr / BEAMFX_FR
		var/fb = lr0 / BEAMFX_FR
		var/ia = round(fa, 1)
		var/ib = round(fb, 1)
		if(abs(fa - ia) < 0.001 && abs(fb - ib) < 0.001 && ia - ib == 36)
			nudged = EFX92RingTie(ib) ? (tr - 0.901) : (tr - 0.899)
			last_ring = nudged
	..()
	if(nudged && last_ring == nudged) last_ring = lr0
	if(isnull(t0)) return
	RLSpawnGlints(now, qn)
	if(ch_on) rl_glints = list()
	RLSpawnRootBolts(now, qn)
	RLSpawnLrays(now, qn)
	RLSpawnShocks(now, qn)
	if(clash_mode && rl_cart) RLClashTick(now, qn)
	if(!ch_on) RLSpawnSparks(now, qn)
	if(rl_pierce) RLTickPierce(now, qn)

/datum/beamfx/proc/RLSpawnSparks(now, qn)
	if(s_dead) return
	var/H = Hr(now, qn, 0)
	if(isnull(H)) return
	var/firing = isnull(release_t)
	var/lo = firing ? (mz + 24) : (Back(now, qn) + 12)
	var/L = H - lo
	if(L < 40) return
	var/rate = RLP("spark_rate", 0.25) * L / 32
	var/n = floor(rate) + ((rng2.R() < rate - floor(rate)) ? 1 : 0)
	var/rp = rl.P["rp"]
	var/list/sl = RLP("spark_lat", list(1, 7))
	for(var/i = 1 to n)
		var/dd = rng2.U(lo, H - 12)
		var/side = (rng2.R() < 0.5) ? 1 : -1
		var/lat = side * rng2.U(rp + sl[1], rp + sl[2])
		var/st0 = now + rng2.U(0, BEAMFX_TICK)
		var/life = rng2.U(0.22, 0.42)
		var/v = Vs * rng2.U(0.25, 0.7)
		var/vl = side * rng2.U(4, 12)
		var/list/gsb = rl_gspark
		var/g = rng2.RandRange(gsb ? gsb.len : 0)
		var/sc = rng2.U(0.75, 1.15)
		rl_uid++
		if(!rl_pierce) rl_sparks[++rl_sparks.len] = list(st0, dd, lat, v, vl, life, g, sc, rl_uid)

/datum/beamfx/proc/RLSpawnGlints(now, qn)
	if(!length(rl_gspark)) return
	if(isnull(t_hit) || now + BEAMFX_TICK <= t_hit) return
	if(!isnull(end_t) && now > end_t + 0.05) return
	if(!Struggling(qn, 0) && isnull(end_t)) return
	var/list/G = rl.P["glint"]
	var/n = G["per_tick"] * ((clash_mode && rl_cart) ? 2 : 1)
	if(t_hit <= now && now < t_hit + 0.1) n = G["first"]
	var/c = Contact(now, qn, 0)
	var/cd
	if(isnull(c))
		var/h = Hr(now, qn, 0)
		cd = (h ? h : 0) + EFX92_CONTACT
	else
		cd = c
	var/x0 = WX(cd - 4)
	var/y0 = WY(cd - 4)
	var/bs = RLP("burst_scale", 1)
	var/list/gv = G["v"]
	var/list/gl = G["life"]
	for(var/i = 1 to n)
		var/a0 = BurstDir(clash_mode)
		var/v = rng2.U(gv[1], gv[2])
		var/life = rng2.U(gl[1], gl[2])
		var/st0 = now + rng2.U(0, BEAMFX_TICK)
		var/r0 = rng2.U(6, 14) * bs
		v = v * (bs ** 0.8)
		var/list/gsa = rl_gspark
		var/g = rng2.RandRange(gsa ? gsa.len : 0)
		var/sc = rng2.U(0.7, 1.2)
		rl_uid++
		rl_glints[++rl_glints.len] = list(st0, x0 + cos(a0) * r0, y0 + sin(a0) * r0, a0, v, life, g, sc, rl_uid)

/datum/beamfx/proc/RLSpawnLrays(now, qn)
	var/list/LR = rl.P["lrays"]
	if(!LR) return
	var/list/plan = LR["plan"]
	var/nplan = plan.len
	if(!isnull(release_t))
		if(!rl_lray_rel_done)
			rl_lray_rel_done = 1
			var/rf = LR["release_frame"]
			for(var/list/r in rl_lrays)
				var/fi = RLAge(release_t, r[1])
				if(fi >= 0 && fi < rf)
					var/list/fr = r[4]
					var/list/nf = list(fr[fi + 1])
					for(var/q = rf to nplan - 1)
						nf += q
					r[4] = nf
					r[1] = release_t - BEAMFX_TICK
				else if(fi < 0)
					r[4] = list()
		return
	var/nalive = 0
	for(var/list/r in rl_lrays)
		var/list/fr = r[4]
		if(now < r[1] + fr.len * BEAMFX_TICK - 0.000001) nalive++
	var/list/A = rl.A["lrays"]
	var/want = min(LR["per_tick"], max(0, LR["alive"] - nalive))
	for(var/i = 1 to want)
		var/v = rng5.RandRange(A.len)
		var/ang2
		if(rng5.R() < LR["fwd_p"]) ang2 = ang + rng5.U(-90, 90)
		else ang2 = ang + 90 + rng5.U(0, 180)
		var/list/fr = list()
		for(var/q = 0 to nplan - 1)
			fr += q
		if(rng5.R() < LR["skip_p"])
			var/pi = rng5.RandInt(3, 4)
			fr.Cut(pi + 1, pi + 2)
		var/ti = 0
		if(LR["erupt_t"])
			var/lk = 1 + LR["erupt_k"] * max(0, 1 - (now - t0) / LR["erupt_t"])
			var/list/TK = LR["tiers"]
			var/best = 1000000
			for(var/jj = 1 to TK.len)
				var/dv = abs(TK[jj] - lk)
				if(dv < best)
					best = dv
					ti = jj - 1
			var/tf = (now - t0) / BEAMFX_FR
			var/tn = round(tf, 1)
			var/tt = EFX92_LTIER[rl.key]
			if(tt && abs(tf - tn) < 0.001 && tn >= 0 && tn < length(tt)) ti = text2num(copytext(tt, tn + 1, tn + 2))
		var/rt0 = now + rng5.U(0, BEAMFX_TICK * 0.5)
		var/sc = rng5.U(0.85, 1.15)
		var/sy = (rng5.R() < 0.5) ? 1 : -1
		var/list/root = LR["root"]
		var/r0 = rng5.U(root[1], root[2])
		rl_uid++
		rl_lrays[++rl_lrays.len] = list(rt0, v, ang2, fr, sc, sy, r0, ti, rl_uid)

/datum/beamfx/proc/RLSpawnShocks(now, qn)
	var/list/Sk = rl.P["shock"]
	if(!Sk || !isnull(release_t)) return
	if(isnull(rl_next_shock)) rl_next_shock = t0 + Sk["delay"]
	var/list/sv = Sk["v"]
	var/list/ev = Sk["every"]
	while(now + BEAMFX_TICK > rl_next_shock)
		var/st0 = max(rl_next_shock, now)
		var/v = rng6.U(sv[1], sv[2])
		var/rot = rng6.U(0, 360)
		var/sy = (rng6.R() < 0.5) ? 1 : -1
		rl_uid++
		rl_shocks[++rl_shocks.len] = list(st0, v, rot, sy, null, null, rl_uid)
		rl_next_shock = st0 + rng6.U(ev[1], ev[2])

/datum/beamfx/Frame(fi, j)
	if(!rl) return
	if(rl_g)
		RLGFrame(fi, j)
		return
	if(rl_ch)
		RLCHFrame(fi, j)
		return
	var/t = FT(fi)
	if(isnull(t0) || t < t0) return
	ctx_f = fi
	var/Hrv = Hr(t, fi, 0)
	if(isnull(Hrv)) return
	var/list/hl = Holds()
	var/rm = RLRemapWant(fi, hl)
	var/own = (rm == 1 && !BeamFXMod(fi, 2) && Q(fi + 1, hl) == fi) ? 1 : 0
	rl_draw = (own || (!rm && (Q(2 * k, hl) == fi || Q(2 * k + 1, hl) == fi))) ? 1 : 0
	rl_j = j
	var/list/out = list()
	if(rl_pierce) RLSpritesPierce(out, fi, t, Hrv)
	else RLSprites(out, fi, t, Hrv)
	if(!rl_draw)
		rl_draw = 1
		if(rm == 1 || rm == 3) RLRemapEmit(fi, j)
		return
	if(abs(rl_k - 1) > 0.000001) out = rl_pierce ? RLWidenPierce(out, fi, t) : RLWiden(out, fi, t)
	rl_raw["[fi]"] = list(out, rl_sw[j], b_sig)
	if(own)
		rl_ownf = fi
		RLRemapEmit(fi, j)
		return
	if(logging) RLLog(fi, out)
	RLEmitAll(j, fi, out)

/datum/beamfx/var/list/rl_raw = list()
/datum/beamfx/var/list/rl_remap = list()
/datum/beamfx/var/list/rl_remapv = list()
/datum/beamfx/var/rl_rmv
/datum/beamfx/var/rl_ownf

/datum/beamfx/Q(i, list/hl)
	if(rl && rl_remap.len)
		var/r = rl_remap["[i]"]
		if(!isnull(r)) return r
	return ..()

/datum/beamfx/proc/RLRemapWant(fi, list/hl)
	if(!bgeo && !fgeo) return 0
	if(!isnull(rl_remap["[fi]"]))
		rl_remap -= "[fi]"
		rl_remapv -= "[fi]"
	if(!isnull(rl_ownf) && rl_ownf == fi - 1 && rl_raw["[fi - 1]"])
		rl_ownf = null
		rl_remap["[fi]"] = fi
		rl_rmv = fi - 1
		return 3
	var/v = Q(fi, hl)
	if(floor(v / 2) == floor(fi / 2)) return 0
	if(!RLBendMode(fi)) return 0
	if(BeamFXMod(fi, 2) == 1 && rl_remapv["[fi - 1]"] == v)
		rl_remap["[fi]"] = fi - 1
		return 2
	var/list/c = rl_raw["[v]"]
	if(!c) return 0
	if(!fgeo && c[3] == b_sig) return 0
	rl_remap["[fi]"] = fi
	rl_remapv["[fi]"] = v
	rl_rmv = v
	return 1

/datum/beamfx/proc/RLRemapEmit(fi, j)
	var/list/c = rl_raw["[rl_rmv]"]
	if(!c) return
	rl_sw[j] = c[2]
	if(logging) RLLog(fi, c[1])
	rl_bm = RLBendMode(fi)
	RLBendAll(j, fi, c[1], rl_rmv)

/datum/beamfx/proc/RLLog(fi, list/out)
	return

/datum/beamfx/proc/RLSprites(list/out, fi, t, Hrv)
	var/list/P = rl.P
	var/list/A = rl.A
	var/stk = rl_st
	var/dead = !isnull(dead_f) && fi >= dead_f
	var/firing = isnull(release_f) || fi < release_f
	var/ending = !isnull(end_t) && t >= end_t
	var/bk = Back(t, fi)
	var/st = dead ? dead_struggle : Struggling(fi, 0)
	var/nd = RLDraw(fi)
	var/list/heads = A["heads"]
	var/list/hg = RLHeadGeom(t, fi, Hrv, st, nd)
	var/list/Hd = hg[1]
	var/kh = hg[2]
	var/list/sn = RLSnap(hg[3], t, fi)
	var/xh = sn[1]
	var/ih = sn[2]
	var/bud_closed = (P["bud_closed"] && kh < 2) ? 1 : 0
	if(ending && isnull(rl_end_phase)) rl_end_phase = ih
	var/head_cut = xh + Hd["cut"] * stk
	var/hi_cut = head_cut
	var/lo_cut = null
	var/list/St = A["star"]
	if(firing && St)
		var/xb = mz
		lo_cut = xb + St["cut"] * stk
		var/al = min(1, (t - t0) / 0.04)
		var/list/sfr = St["frames"]
		var/list/pair = sfr[BeamFXMod(nd, sfr.len) + 1]
		RLPair(out, pair, WX(xb), WY(xb), 0, 1, 1, al, 4.6, 0, null, null, "star", "mz")
	else if(firing)
		var/list/Bl = A["bloom"]
		var/list/buds = A["bloom_buds"]
		if(buds && nd < buds.len) Bl = buds[nd + 1]
		var/list/sb = RLSnap(mz, t, fi)
		var/xb = sb[1]
		var/ib = sb[2]
		lo_cut = xb + Bl["cut"] * stk
		var/al = min(1, (t - t0) / 0.04)
		var/hp = xb + Bl["ox"] * stk
		var/list/bfr = Bl["frames"]
		var/list/pair = bfr[ib + 1]
		var/bcut = bud_closed ? min(xb + Bl["cut"] * stk, xh) : (xb + Bl["cut"] * stk)
		RLPair(out, pair, WX(hp), WY(hp), ang, stk, 1, al, 4.5, 0, list(RLCut(bcut + EFX92_JOIN_OV * stk, -1, stk)), list(RLCut(bcut, -1, stk)), "bloom", "bl", null, bfr, ib)
		if(A["bloom_flare"] && rl_draw) RLFlareSprites(out, t, fi, xb, nd)
		if(A["rays"] && rl_draw) RLRaySprites(out, t, fi, al, 1, nd)
	else
		var/q = (t - release_t) / 0.1
		if(q < 1 && St)
			var/sc = 1 - 0.85 * q
			var/al = (1 - q) ** 1.2
			var/list/sfr = St["frames"]
			var/list/pair = sfr[BeamFXMod(nd, sfr.len) + 1]
			RLPair(out, pair, WX(mz), WY(mz), 0, sc, sc, al, 4.6, 0, null, null, "star", "mz")
		else if(q < 1 && A["bloom_closed"])
			var/list/Bl = A["bloom_closed"]
			var/list/sb = RLSnap(mz, t, fi)
			var/xb = sb[1]
			var/ib = sb[2]
			var/sc = 1 - 0.85 * q
			var/al = (1 - q) ** 1.2
			var/hp = xb + Bl["ox"] * sc * stk
			var/list/bfr = Bl["frames"]
			RLPair(out, bfr[ib + 1], WX(hp), WY(hp), ang, sc * stk, sc, al, 4.5, 0, null, null, "bloom", "bc", null, bfr, ib)
			if(A["rays"] && rl_draw) RLRaySprites(out, t, fi, al, sc, nd)
		if(!ending)
			var/list/T = A["tail"]
			var/list/stl = RLSnap(bk, t, fi)
			var/xt = stl[1]
			var/it = stl[2]
			lo_cut = xt + T["cut"] * stk
			var/closing = (kh == heads.len - 1) && (xt + P["tail_L"] * stk >= head_cut) && !rl_no_drain
			var/hp2 = xt + T["ox"] * stk
			var/list/tfr = T["frames"]
			if(!closing)
				var/tcut = min(xt + T["cut"] * stk, head_cut)
				RLPair(out, tfr[it + 1], WX(hp2), WY(hp2), ang, stk, 1, 1, 4.2, 0, list(RLCut(tcut + EFX92_JOIN_OV * stk, -1, stk)), list(RLCut(tcut, -1, stk)), "tail", "tl")
	var/closing_h = 0
	if(!firing && !ending && kh == heads.len - 1 && !rl_no_drain)
		var/list/sbk = RLSnap(bk, t, fi)
		if(sbk[1] + P["tail_L"] * stk >= head_cut) closing_h = 1
	if(!ending)
		var/list/Hsrc = Hd
		var/list/cuts = bud_closed ? list() : list(RLCut(head_cut, 1, stk))
		if(closing_h)
			var/list/sbk2 = RLSnap(bk, t, fi)
			var/Lrem = head_cut - sbk2[1]
			var/list/Ls = P["drain_L"]
			if(Lrem < Ls[1] * 0.5 * stk)
				Hsrc = A["head_closed"]
			else
				var/bi = 1
				var/bd = 1000000000
				for(var/li = 1 to Ls.len)
					var/dv = abs(Ls[li] * stk - Lrem)
					if(dv < bd)
						bd = dv
						bi = li
				var/list/DR = A["drain"]
				Hsrc = DR[bi]
			cuts = list()
		var/hp3 = xh + Hsrc["ox"] * stk
		var/list/hfr = Hsrc["frames"]
		var/list/pc = cuts.len ? list(RLCut(head_cut - EFX92_JOIN_OV * stk, 1, stk)) : list()
		var/list/hb = list(Hsrc["ox"], Hd["R"], Hd["sq"])
		RLPair(out, hfr[ih + 1], WX(hp3), WY(hp3), ang, stk, 1, 1, 5, 0, pc, cuts, "head", "hd[Hsrc == Hd ? kh : "x"]", hb, hfr, ih)
		rl_end_xh = xh
	else
		var/qe = (t - end_t) / P["erode_dt"]
		var/ei = floor(qe + 0.000001)
		var/list/E = A["erode"]
		var/list/efr = E["frames"]
		var/list/ef1 = efr[1]
		if(ei < ef1.len)
			var/xe = isnull(rl_end_xh) ? xh : rl_end_xh
			var/ph = isnull(rl_end_phase) ? ih : rl_end_phase
			var/list/eph = efr[ph + 1]
			var/hp4 = xe + E["ox"] * stk
			var/list/Ph = P["heads"]
			var/list/hl = Ph[Ph.len]
			RLPair(out, eph[ei + 1], WX(hp4), WY(hp4), ang, stk, 1, 1, 5, 0, null, null, "erode", "er", list(E["ox"], hl[1], hl[2]))
	if(!isnull(lo_cut) && lo_cut < hi_cut && !ending)
		RLStampPass(out, fi, t, Hrv, bk, lo_cut, hi_cut, stk)
	var/list/keep = list()
	var/list/spa = A["sparks"]
	for(var/list/sp in rl_sparks)
		var/age = t - sp[1]
		if(age >= sp[6]) continue
		keep[++keep.len] = sp
		if(age < 0 || !rl_draw) continue
		var/q2 = age / sp[6]
		var/a2 = sin(180 * q2) ** 1.5
		var/dd2 = sp[2] + sp[4] * age
		if(dd2 > Hrv + 6) continue
		var/kk2 = sp[8] * (0.7 + 0.3 * sin(180 * q2))
		RLRec(out, spa[sp[7] + 1], WX(dd2, sp[3] + sp[5] * age), WY(dd2, sp[3] + sp[5] * age), 0, kk2, kk2, a2, 0, 0, 1, null, "spark", "sk[sp[9]]")
	rl_sparks = keep
	if(A["lrays"]) RLLraySprites(out, t, fi)
	if(A["shock"]) RLShockSprites(out, t, fi, xh, Hd, firing, bk)
	if(A["halo"] && rl_draw) RLHaloSprites(out, t, fi, xh, st, ending, nd)
	if(A["rbolts"]) RLRootBoltSprites(out, t, fi)
	if(rl.B) RLBurstSprites(out, t, fi, Hrv, xh, Hd, st, firing, ending)
	if(P["xglint"] && St && rl_draw) RLHitGlint(out, t, fi, Hrv, st, ending, nd)
	if(clash_mode && rl_cart && st && !ending) RLClashSprites(out, t, fi)

/datum/beamfx/proc/RLLraySprites(list/out, t, fi)
	var/list/A = rl.A["lrays"]
	var/Rb = rl.P["bloom_R"]
	var/cxd = mz + rl.P["bloom_x"] * rl_st
	var/cx = WX(cxd)
	var/cy = WY(cxd)
	var/ral = 1
	if(!isnull(release_t) && t >= release_t)
		var/q = (t - release_t) / 0.1
		if(q >= 1)
			rl_lrays = list()
			return
		ral = (1 - q) ** 1.2
	var/lay = RLP("lray_layer", 4.4)
	var/list/keep = list()
	for(var/list/r in rl_lrays)
		var/rfi = RLAge(t, r[1])
		var/list/fr = r[4]
		if(rfi >= fr.len) continue
		keep[++keep.len] = r
		if(rfi < 0 || !rl_draw) continue
		var/list/V = A[r[2] + 1]
		if(r[8])
			var/list/tiers = V["tiers"]
			V = tiers[r[8] + 1]
		var/list/vfr = V["frames"]
		var/list/pair = vfr[fr[rfi + 1] + 1]
		var/ca = cos(r[3])
		var/sa = sin(r[3])
		var/dd = Rb * r[7] + V["ox"] * r[5]
		RLPair(out, pair, cx + ca * dd, cy + sa * dd, r[3], r[5], r[6] * r[5], ral, lay, 0, null, null, "lray", "lr[r[9]]")
	rl_lrays = keep

/datum/beamfx/proc/RLHaloSprites(list/out, t, fi, xh, st, ending, nd)
	if(isnull(t_hit) || t < t_hit || !st) return
	var/list/HR = rl.P["halo_ring"]
	var/k = min(1, (t - t_hit) / HR["grow"])
	if(ending)
		k *= max(0, 1 - (t - end_t) / HR["fade"])
		if(!isnull(rl_end_xh)) xh = rl_end_xh
	if(k <= 0.001) return
	var/list/H = rl.A["halo"]
	var/list/fr = H["frames"]
	var/list/pair = fr[BeamFXMod(nd, fr.len) + 1]
	var/sc = HR["s0"] + (1 - HR["s0"]) * min(1, (t - t_hit) / HR["grow"])
	RLPair(out, pair, WX(xh), WY(xh), 0, sc, sc, k, 4.9, 0, null, null, "halo", "ha")

/datum/beamfx/proc/RLShockSprites(list/out, t, fi, xh, list/Hd, firing, bk)
	var/list/Sk = rl.P["shock"]
	var/list/SA = rl.A["shock"]
	var/list/em = SA["emerge"]
	var/list/lp = SA["loop"]
	var/list/en = SA["end"]
	var/head_back = xh - (Hd["R"] + Sk["pre"]) * rl_st
	var/list/keep = list()
	for(var/list/s in rl_shocks)
		var/age = t - s[1]
		if(age < -0.000001)
			keep[++keep.len] = s
			continue
		var/dd = mz + (rl.P["bloom_x"] + rl.P["bloom_R"] * Sk["start"]) * rl_st + s[2] * age
		if(isnull(s[5]))
			if(!firing) s[5] = release_t
			else if(dd >= head_back)
				s[5] = t
				s[6] = head_back
		var/list/pair
		var/endf = 0
		if(!isnull(s[5]))
			var/jj = RLAge(t, s[5])
			if(jj >= en.len) continue
			pair = en[max(jj, 0) + 1]
			endf = 1
			if(!isnull(s[6])) dd = s[6]
		else
			var/sfi = RLAge(t, s[1])
			pair = (sfi < em.len) ? em[sfi + 1] : lp[BeamFXMod(sfi - em.len, lp.len) + 1]
		keep[++keep.len] = s
		if(!rl_draw || (!firing && !isnull(bk) && dd < bk)) continue
		RLPair(out, pair, WX(dd), WY(dd), ang, Sk["squash"], s[4], 1, 4.95, 0, null, null, "shock", "sh[s[7]]", null, null, 0, endf)
	rl_shocks = keep

/datum/beamfx/proc/RLFlareSprites(list/out, t, fi, xb, nd)
	var/list/F = rl.P["bloom_flare"]
	var/jj = nd - F["at"]
	var/list/seq = F["seq"]
	if(jj < 0 || jj >= seq.len) return
	var/list/BF = rl.A["bloom_flare"]
	var/list/Fl = BF[seq[jj + 1] + 1]
	var/list/fr = Fl["frames"]
	var/hp = xb + Fl["ox"] * rl_st
	RLPair(out, fr[BeamFXMod(nd, fr.len) + 1], WX(hp), WY(hp), ang, rl_st, 1, 1, 4.55, 0, null, null, "bflare", "bf")

/datum/beamfx/proc/RLRaySprites(list/out, t, fi, al, sc, nd)
	var/list/Ry = rl.A["rays"]
	var/list/fr = Ry["frames"]
	var/list/pair = fr[BeamFXMod(nd, fr.len) + 1]
	var/k = RLP("rays_k", 1)
	var/rd = mz + rl.P["bloom_x"] * sc * rl_st
	var/rot = RLP("rays_spin", 0) * (t - t0)
	RLPair(out, pair, WX(rd), WY(rd), rot, sc, sc, al * k, 4.4, 0, null, null, "rays", "ry")

/datum/beamfx/proc/RLHitGlint(list/out, t, fi, Hrv, st, ending, nd)
	if(isnull(t_hit) || t < t_hit || !st) return
	var/al = 1
	if(ending)
		al = max(0, 1 - (t - end_t) / RLP("flash_end_fade", 0.2))
		if(al <= 0) return
	var/list/St = rl.A["star"]
	var/c = Contact(t, fi, 0)
	var/cd = isnull(c) ? (Hrv + EFX92_CONTACT) : c
	var/list/fr = St["frames"]
	var/list/pair = fr[BeamFXMod(nd + 3, fr.len) + 1]
	var/list/XG = rl.P["xglint"]
	var/k = XG["hit_k"]
	RLPair(out, pair, WX(cd - 1), WY(cd - 1), 0, k, k, al, 5.45, 0, null, null, "xglint", "xg")

/datum/beamfx/proc/RLBurstScaled(x, y, t, fi)
	var/kb = RLP("burst_scale", 1)
	if(kb == 1) return list(x, y)
	var/c = Contact(t, fi, 0)
	if(isnull(c))
		var/h = Hr(t, fi, 0)
		c = (h ? h : 0) + EFX92_CONTACT
	var/cx = WX(c - 2)
	var/cy = WY(c - 2)
	return list(cx + (x - cx) * kb, cy + (y - cy) * kb)

/datum/beamfx/proc/RLBurstSprites(list/out, t, fi, Hrv, xh, list/Hd, st, firing, ending)
	var/list/B = rl.B
	var/list/P = rl.P
	var/list/FL = B["flash"]
	var/list/FA = FL["frames"]
	var/fres = FL["res"]
	if(isnull(fres)) fres = 1
	var/jf = BeamFXMod(floor((fi - fi0) / 2), FA.len)
	var/surges_on = isnull(P["surges"]) ? 1 : P["surges"]
	var/rays_on = isnull(P["burst_rays"]) ? 1 : P["burst_rays"]
	var/list/SA = B["splash"]
	var/list/RA = B["ray"]
	var/list/Sg = B["surge"]
	var/list/sa_ = RLP("surge_a", list(8, 40))
	var/bs = RLP("burst_scale", 1)
	var/list/alive = list()
	for(var/oi = 1 to objs.len)
		var/datum/bfx_obj/o = objs[oi]
		var/age = t - o.t0
		if(o.kind == "surge")
			if(!surges_on) continue
			var/dd = o.d0 + o.v * age
			var/front = xh - Hd["R"] * 0.4 * rl_st
			if(age >= 0 && dd >= front)
				if(!(o.uid in rl_arrived))
					rl_arrived += o.uid
					rl_flares[++rl_flares.len] = list(o.t0 + (front - o.d0) / o.v, o.scale)
				continue
			if(!firing && dd < Back(t, fi) - 30) continue
			alive += o
			if(age < 0 || !rl_draw) continue
			var/a = BeamFXSstep(mz + sa_[1] * rl_st, mz + sa_[2] * rl_st, dd) * (1 - BeamFXSstep(front - 10 * rl_st, front, dd))
			if(a <= 0.002) continue
			var/hp = dd + Sg["ox"] * rl_st
			var/dc
			var/soft
			if(firing)
				dc = mz + 4 * rl_st
				soft = 8 * rl_st
			else
				dc = Back(t, fi) + P["tail_L"] * 0.5 * rl_st
				soft = P["tail_L"] * rl_st
			var/list/sfr = Sg["frames"]
			RLRec(out, sfr[BeamFXMod(o.seq, sfr.len) + 1], WX(hp), WY(hp), ang, rl_st, 0.85 + 0.15 * o.scale, a * min(1, o.scale), 0, 0, 1, list(list(WX(dc), WY(dc), ax, ay, soft)), "surge", "su[o.uid]")
			continue
		if(o.kind == "wedge" || o.kind == "tongue" || o.kind == "shard" || o.kind == "lance")
			if(age >= o.life) continue
			if((o.kind == "shard" || o.kind == "lance") && !rays_on) continue
			alive += o
			if(age < 0 || !rl_draw) continue
			if((o.kind == "wedge" || o.kind == "tongue") && !SA) continue
			var/q = age / o.life
			if(o.kind == "wedge" || o.kind == "tongue")
				var/list/seq
				var/kk
				var/bx
				var/by
				var/a_t
				var/flip
				var/list/SF = SA["frames"]
				if(o.kind == "wedge")
					flip = (BeamFXMod(o.ang - ang, 360) < 180) ? 1 : -1
					a_t = o.ang + 18 * flip * q
					var/c = Struggling(fi, 0) ? Contact(t, fi, 0) : null
					var/cd = isnull(c) ? o.d0 : c
					var/cxh = WX(cd - 4)
					var/cyh = WY(cd - 4)
					var/r0 = (2 + 6 * q) * bs
					seq = SF[BeamFXMod(o.seq, 4) + 1]
					kk = o.scale * P["splash_k"]
					bx = cxh + cos(a_t) * r0
					by = cyh + sin(a_t) * r0
				else
					var/list/fp = FlowPos(o, age)
					var/list/bp = RLBurstScaled(fp[1], fp[2], t, fi)
					bx = bp[1]
					by = bp[2]
					a_t = fp[3]
					flip = (o.omega >= 0) ? 1 : -1
					seq = SF[4 + BeamFXMod(o.seq, 2) + 1]
					kk = P["splash_k"] * 0.85
				var/jj = min(seq.len - 1, floor(q * (seq.len - 1) + 0.5))
				var/ca = cos(a_t)
				var/sa = sin(a_t)
				RLPair(out, seq[jj + 1], bx + ca * SA["ox"] * kk, by + sa * SA["ox"] * kk, a_t, kk, kk * flip, 1, 5.4, 0, null, null, "splash", "sp[o.uid]")
			else
				var/list/fp2 = FlowPos(o, age)
				var/list/bp2 = RLBurstScaled(fp2[1], fp2[2], t, fi)
				var/list/RF = RA["frames"]
				var/list/seq2 = RF[BeamFXMod(o.seq, RF.len) + 1]
				var/jj2 = min(seq2.len - 1, floor(q * (seq2.len - 1) + 0.5))
				var/kk2 = o.scale * ((o.kind == "shard") ? P["ray_k"] : P["ray_k"] * 1.25)
				var/ca2 = cos(fp2[3])
				var/sa2 = sin(fp2[3])
				RLPair(out, seq2[jj2 + 1], bp2[1] - ca2 * RA["ox"] * kk2 * 0.5, bp2[2] - sa2 * RA["ox"] * kk2 * 0.5, fp2[3], kk2, kk2, 1, 5.5, 0, null, null, "ray", "ry[o.uid]")
			continue
		if(o.kind == "bead" || o.kind == "streak" || o.kind == "tw" || o.kind == "arc" || o.kind == "rarc" || o.kind == "curl")
			if(age < min(o.life, 1)) alive += o
			continue
		alive += o
	objs = alive
	var/fl = 0
	var/list/keepf = list()
	for(var/list/f in rl_flares)
		var/dt = t - f[1]
		if(dt > 0.25) continue
		keepf[++keepf.len] = f
		if(dt >= 0 && dt < 0.2) fl = max(fl, f[2] * ((1 - dt / 0.2) ** 1.3))
	rl_flares = keepf
	if(fl > 0.01 && !ending && rl_draw)
		var/ksc = P["flare_k"] * (0.75 + 0.25 * fl) / fres
		RLRec(out, FA[jf + 1], WX(xh), WY(xh), 0, ksc, ksc, min(1, 0.85 * fl), 0, 0, 1, null, "flare", "fr")
	if(rl_draw && st && !isnull(t_hit) && t >= t_hit)
		var/qh = HitQ(t)
		var/jit = 0.88 + 0.28 * BeamFXMod(BeamFXMod(fi, 97) * 62 + BeamFXMod(fi0, 97) * 31, 97) / 97
		var/first = max(0, 1 - (t - t_hit) / 0.18)
		var/al = (0.55 + 0.35 * qh + 0.5 * first) * (ending ? max(0, 1 - (t - end_t) / RLP("flash_end_fade", 0.2)) : 1)
		var/c = Contact(t, fi, 0)
		var/cd = isnull(c) ? (Hrv + EFX92_CONTACT) : c
		var/ksc2 = P["flash_k"] * (0.45 + 0.55 * qh + 0.3 * first) * jit * (1 + 0.25 * fl) / fres
		if(al > 0.01) RLRec(out, FA[jf + 1], WX(cd - 3), WY(cd - 3), 0, ksc2, ksc2, min(1, al), 0, 0, 1, null, "flash", "fs")
	var/list/G = P["glint"]
	var/list/GA = rl_gspark
	var/list/keepg = list()
	for(var/list/gl in rl_glints)
		var/age2 = t - gl[1]
		if(age2 >= gl[6]) continue
		keepg[++keepg.len] = gl
		if(age2 < 0 || !rl_draw) continue
		var/q3 = age2 / gl[6]
		var/ta = min(age2, 1 / G["decel"])
		var/dist = gl[5] * (ta - 0.5 * G["decel"] * ta * ta)
		var/a3 = (1 - q3 * q3) * min(1, age2 / 0.03)
		var/kk3 = gl[8] * (1 - 0.5 * q3)
		RLRec(out, GA[gl[7] + 1], gl[2] + cos(gl[4]) * dist, gl[3] + sin(gl[4]) * dist, 0, kk3, kk3, a3, 0, 0, 1, null, "glint", "gl[gl[9]]")
	rl_glints = keepg

/datum/beamfx/proc/RLFC(x, y)
	var/dx = x - Ox
	var/dy = y - Oy
	return list(dx * ax + dy * ay, dx * nx + dy * ny)

/datum/beamfx/proc/RLTW(dd, lat)
	return list(Ox + ax * dd + nx * lat, Oy + ay * dd + ny * lat)

/datum/beamfx/proc/RLSoft(dd, keep_front, soft)
	var/sg = keep_front ? 1 : -1
	return list(WX(dd), WY(dd), ax * sg, ay * sg, soft)

/datum/beamfx/proc/RLShift(list/r, m)
	var/list/sh = r[RL92_SH]
	if(!sh || !m) return r[RL92_ST]
	var/list/fr = sh[1]
	var/list/pair = fr[BeamFXMod(sh[2] + m, fr.len) + 1]
	return pair[sh[3]]

/datum/beamfx/proc/RLWiden(list/sprs, fi, t)
	var/list/P = rl.P
	var/list/A = rl.A
	var/k = rl_k
	var/rp = P["rp"]
	var/stk = rl_st
	var/cone = (P["muzzle"] == "cone")
	var/ball_palm = ((isnull(P["muzzle"]) || P["muzzle"] == "ball") && A["bloom"]) ? 1 : 0
	var/list/head
	for(var/list/s in sprs)
		if(s[RL92_BALL] && s[RL92_KIND] == 0)
			head = s
			break
	var/hj = 0
	var/hj_xh
	var/hj_R
	var/hj_sq
	var/hj_front
	var/hj_kb
	var/hj_Xw
	var/hj_m
	var/hj_hc
	var/hj_last
	if(head)
		var/list/fc = RLFC(head[RL92_X], head[RL92_Y])
		var/list/bl = head[RL92_BALL]
		hj_R = bl[2]
		hj_sq = bl[3]
		hj_xh = fc[1] - bl[1] * stk
		hj_front = hj_xh + hj_R * hj_sq * stk
		hj_kb = EFX92KbOf(k, rp, hj_R)
		var/hw = k * rp / hj_kb
		var/X_w = -sqrt(max(hj_R * hj_R - hw * hw, 0)) * stk
		hj_Xw = hj_front + hj_kb * (hj_xh + X_w - hj_front)
		hj_m = EFX92PyRound(((hj_Xw - hj_xh) - X_w) / qstep)
		hj_hc = hj_xh - (hj_R + 2) * stk
		var/list/Ph = P["heads"]
		var/list/hl = Ph[Ph.len]
		hj_last = (abs(hj_R - hl[1]) < 0.000001) ? 1 : 0
		hj = 1
	var/pj = 0
	var/pj_kb
	var/pj_Pw
	var/pj_m
	var/pj_pc
	var/list/Bl = A["bloom"]
	if(ball_palm)
		for(var/list/s in sprs)
			if(s[RL92_TAG] == "bloom")
				var/list/fc2 = RLFC(s[RL92_X], s[RL92_Y])
				var/xb = fc2[1] - Bl["ox"] * stk
				var/Rp = P["bloom_R"]
				var/xc = xb + P["bloom_x"] * stk
				pj_kb = EFX92KbOf(k, rp, Rp)
				var/hw2 = k * rp / pj_kb
				var/P_w = sqrt(max(Rp * Rp - hw2 * hw2, 0)) * stk
				pj_Pw = mz + pj_kb * (xc + P_w - mz)
				pj_m = EFX92PyRound(((pj_Pw - xc) - P_w) / qstep)
				pj_pc = xb + Bl["cut"] * stk
				pj = 1
				break
	var/closed_now = 0
	if(hj && hj_last && !isnull(release_t) && t >= release_t)
		if(Back(t, fi) + P["tail_L"] * 0.9 * stk > hj_Xw - EFX92_SOFT * stk) closed_now = 1
	var/firing = isnull(release_f) || fi < release_f
	var/has_stream = 0
	for(var/list/s in sprs)
		if(s[RL92_TAG] == "stamp" || s[RL92_TAG] == "tail")
			has_stream = 1
			break
	var/s_back = firing ? (pj ? pj_Pw : mz) : Back(t, fi)
	var/head_ok = (hj && has_stream && hj_Xw - s_back > 2 * EFX92_SOFT * stk) ? 1 : 0
	var/palm_ok = (firing && pj && has_stream && hj && hj_Xw - pj_Pw > 2 * EFX92_SOFT * stk) ? 1 : 0
	var/bud_c = null
	if(hj && !head_ok && P["bud_closed"] && head)
		var/list/hcuts = head[RL92_CUTS]
		if(!hcuts.len) bud_c = hj_front - hj_kb * hj_R * hj_sq * stk
	var/list/Ph2 = P["heads"]
	var/list/hl2 = Ph2[Ph2.len]
	var/kc = EFX92KbOf(k, rp, hl2[1])
	var/kp_all = EFX92KbOf(k, rp, P["bloom_R"])
	var/list/out = list()
	var/surge_ox = 0
	if(rl.B)
		var/list/Sg = rl.B["surge"]
		surge_ox = Sg["ox"] * stk
	for(var/list/s in sprs)
		var/tg = s[RL92_TAG]
		var/list/fc3 = RLFC(s[RL92_X], s[RL92_Y])
		var/dd = fc3[1]
		var/lat = fc3[2]
		var/rel = BeamFXMod(s[RL92_ANG] - ang, 180)
		var/aligned = (rel < 1 || rel > 179) ? 1 : 0
		var/list/r = s.Copy()
		if((tg == "stamp" || tg == "tail") && ball_palm && firing && !palm_ok && !head_ok) continue
		if(tg == "stamp" || tg == "tail" || tg == "surge" || (cone && tg == "bloom"))
			var/list/w = RLTW(dd, lat0 + k * (lat - lat0))
			if(aligned)
				r[RL92_SY] = s[RL92_SY] * k
			else
				r[RL92_SX] = s[RL92_SX] * k
				r[RL92_SY] = s[RL92_SY] * k
			if(tg == "surge" && rl.B)
				var/peak = dd - surge_ox
				w = RLTW(peak + k * (dd - peak), lat0 + k * (lat - lat0))
				r[RL92_SX] = s[RL92_SX] * k
			r[RL92_X] = w[1]
			r[RL92_Y] = w[2]
			var/list/cuts = list()
			for(var/list/c in s[RL92_CUTS])
				var/list/fcc = RLFC(c[1], c[2])
				var/cd = fcc[1]
				var/fwd = (c[3] * ax + c[4] * ay) > 0
				if(hj && !fwd && abs(cd - hj_hc) < 1.6)
					if(s[RL92_KIND] == 1) cuts[++cuts.len] = RLSoft(hj_Xw + EFX92_GLOW_TAPER * 0.3 * stk, 0, EFX92_GLOW_TAPER * stk)
					else cuts[++cuts.len] = RLSoft(hj_Xw, 0, EFX92_SOFT * stk)
				else if(pj && fwd && abs(cd - pj_pc) < 1.6)
					cuts[++cuts.len] = RLSoft(pj_Pw, 1, EFX92_SOFT * stk)
				else
					cuts[++cuts.len] = c
			if(tg == "surge" && hj) cuts[++cuts.len] = RLSoft(hj_Xw + EFX92_SURGE_SOFT * stk, 0, 2 * EFX92_SURGE_SOFT * stk)
			r[RL92_CUTS] = cuts
			out[++out.len] = r
			continue
		if((tg == "head" || tg == "erode") && hj)
			var/si = RLShift(s, hj_m)
			if(closed_now && tg == "head" && s[RL92_SH])
				var/list/sh = s[RL92_SH]
				var/list/hcf = A["head_closed"]
				var/list/hcfr = hcf["frames"]
				var/list/hp = hcfr[BeamFXMod(sh[2] + hj_m, hcfr.len) + 1]
				si = hp[sh[3]]
			var/list/w2 = RLTW(hj_front + hj_kb * (dd - hj_front), lat0 + hj_kb * (lat - lat0))
			var/list/cuts2 = list()
			if(!(tg == "erode" || closed_now || !head_ok))
				if(s[RL92_KIND] == 0)
					var/list/hcuts2 = head[RL92_CUTS]
					if(hcuts2.len) cuts2[++cuts2.len] = RLSoft(hj_Xw - (EFX92_HEAD_FADE * 0.5 + EFX92_SOFT * 0.5) * stk, 1, EFX92_HEAD_FADE * stk)
				else
					cuts2[++cuts2.len] = RLSoft(hj_Xw, 1, EFX92_SOFT * stk)
			r[RL92_ST] = si
			r[RL92_X] = w2[1]
			r[RL92_Y] = w2[2]
			r[RL92_SX] = s[RL92_SX] * hj_kb
			r[RL92_SY] = s[RL92_SY] * hj_kb
			r[RL92_CUTS] = cuts2
			if(s[RL92_KIND] == 0) r[RL92_LY] = 3.9
			out[++out.len] = r
			continue
		if(tg == "bloom" && pj)
			var/si2 = RLShift(s, pj_m)
			var/list/w3 = RLTW(mz + pj_kb * (dd - mz), lat0 + pj_kb * (lat - lat0))
			var/list/cuts3 = list()
			var/list/oc = s[RL92_CUTS]
			if(oc.len)
				if(palm_ok)
					if(s[RL92_KIND] == 0) cuts3[++cuts3.len] = RLSoft(pj_Pw + EFX92_SOFT * stk, 0, EFX92_SOFT * stk)
					else cuts3[++cuts3.len] = RLSoft(pj_Pw, 0, EFX92_SOFT * stk)
				else if(!isnull(bud_c))
					cuts3[++cuts3.len] = RLSoft(bud_c + ((s[RL92_KIND] == 0) ? EFX92_JOIN_OV * stk : 0), 0, stk)
			r[RL92_ST] = si2
			r[RL92_X] = w3[1]
			r[RL92_Y] = w3[2]
			r[RL92_SX] = s[RL92_SX] * pj_kb
			r[RL92_SY] = s[RL92_SY] * pj_kb
			r[RL92_CUTS] = cuts3
			if(s[RL92_KIND] == 0) r[RL92_LY] = 3.85
			out[++out.len] = r
			continue
		if(tg == "lray" && pj)
			var/list/w4 = RLTW(mz + pj_kb * (dd - mz), lat0 + pj_kb * (lat - lat0))
			r[RL92_X] = w4[1]
			r[RL92_Y] = w4[2]
			r[RL92_SX] = s[RL92_SX] * pj_kb
			r[RL92_SY] = s[RL92_SY] * pj_kb
			if(s[RL92_KIND] == 0) r[RL92_LY] = 3.8
			out[++out.len] = r
			continue
		if((tg == "halo" || tg == "flash" || tg == "flare" || tg == "splash" || tg == "ray" || tg == "glint") && hj)
			var/list/w5 = RLTW(hj_front + kc * (dd - hj_front), lat0 + kc * (lat - lat0))
			r[RL92_X] = w5[1]
			r[RL92_Y] = w5[2]
			r[RL92_SX] = s[RL92_SX] * kc
			r[RL92_SY] = s[RL92_SY] * kc
			var/list/mc = list()
			for(var/list/c2 in s[RL92_CUTS])
				var/list/fcm = RLFC(c2[1], c2[2])
				var/list/wm = RLTW(hj_front + kc * (fcm[1] - hj_front), fcm[2])
				mc[++mc.len] = list(wm[1], wm[2], c2[3], c2[4], c2[5] * kc)
			r[RL92_CUTS] = mc
			out[++out.len] = r
			continue
		if(tg == "spark")
			var/list/w6 = RLTW(dd, lat0 + k * (lat - lat0))
			var/q = sqrt(k)
			r[RL92_X] = w6[1]
			r[RL92_Y] = w6[2]
			r[RL92_SX] = s[RL92_SX] * q
			r[RL92_SY] = s[RL92_SY] * q
			out[++out.len] = r
			continue
		if(tg == "rbolt")
			var/list/w7 = RLTW(mz + kp_all * (dd - mz), lat0 + kp_all * (lat - lat0))
			r[RL92_X] = w7[1]
			r[RL92_Y] = w7[2]
			r[RL92_SX] = s[RL92_SX] * kp_all
			r[RL92_SY] = s[RL92_SY] * kp_all
			out[++out.len] = r
			continue
		if(tg == "rbolt_e")
			var/q2 = sqrt(k)
			var/list/w8 = RLTW(mz + kp_all * (dd - mz), lat0 + k * (lat - lat0))
			r[RL92_X] = w8[1]
			r[RL92_Y] = w8[2]
			r[RL92_SX] = s[RL92_SX] * q2
			r[RL92_SY] = s[RL92_SY] * q2
			out[++out.len] = r
			continue
		if(tg == "shock")
			if(s[RL92_END] && hj)
				var/list/w9 = RLTW(hj_front + hj_kb * (dd - hj_front), lat0 + hj_kb * (lat - lat0))
				r[RL92_X] = w9[1]
				r[RL92_Y] = w9[2]
				r[RL92_SX] = s[RL92_SX] * hj_kb
				r[RL92_SY] = s[RL92_SY] * hj_kb
			else
				var/list/w10 = RLTW(dd, lat0 + k * (lat - lat0))
				r[RL92_X] = w10[1]
				r[RL92_Y] = w10[2]
				r[RL92_SX] = s[RL92_SX] * k
				r[RL92_SY] = s[RL92_SY] * k
			out[++out.len] = r
			continue
		if(tg == "bflare")
			var/list/w11 = RLTW(mz + kp_all * (dd - mz), lat0 + kp_all * (lat - lat0))
			r[RL92_X] = w11[1]
			r[RL92_Y] = w11[2]
			r[RL92_SX] = s[RL92_SX] * kp_all
			r[RL92_SY] = s[RL92_SY] * kp_all
			out[++out.len] = r
			continue
		if(tg == "star")
			var/list/SP = P["star"]
			var/ks = EFX92KbOf(k, rp, SP["Rc"])
			var/list/w12 = RLTW(mz + ks * (dd - mz), lat0 + ks * (lat - lat0))
			r[RL92_X] = w12[1]
			r[RL92_Y] = w12[2]
			r[RL92_SX] = s[RL92_SX] * ks
			r[RL92_SY] = s[RL92_SY] * ks
			out[++out.len] = r
			continue
		if(tg == "xglint")
			var/list/XG = P["xglint"]
			if(abs(dd - mz) < 30 || !hj)
				var/kx = EFX92KbOf(k, rp, XG["core"])
				var/list/w13 = RLTW(mz + kx * (dd - mz), lat0 + kx * (lat - lat0))
				r[RL92_X] = w13[1]
				r[RL92_Y] = w13[2]
				r[RL92_SX] = s[RL92_SX] * kx
				r[RL92_SY] = s[RL92_SY] * kx
			else
				var/list/w14 = RLTW(hj_front + kc * (dd - hj_front), lat0 + kc * (lat - lat0))
				r[RL92_X] = w14[1]
				r[RL92_Y] = w14[2]
				r[RL92_SX] = s[RL92_SX] * kc
				r[RL92_SY] = s[RL92_SY] * kc
			out[++out.len] = r
			continue
		out[++out.len] = r
	return out

/datum/beamfx/var/rl_sky

var/list/efx92_sky_files = list()
var/list/efx92_sky_icon = list()

/datum/beamfx/proc/RLSkySafe()
	if(isnull(rl_sky))
		var/turf/T = locate(floor(Ox / 32) + 1, floor(Oy / 32) + 1, z)
		rl_sky = (T && istype(T.loc, /area/OugiStage)) ? 1 : 0
	return rl_sky

/datum/beamfx/proc/RLFamIcon(fam_key, light)
	var/list/fam = BEAMFX_FAM[fam_key]
	if(!light || !RLSkySafe()) return fam[1]
	var/ic = efx92_sky_icon[fam_key]
	if(!ic)
		ic = fam[1]
		var/datum/efx92_row/R = efx92_fam[fam_key]
		var/list/sky = R ? efx92_sky_files[R.key] : null
		var/i = R ? R.fams.Find(fam_key) : 0
		if(sky && i && i <= sky.len) ic = sky[i]
		efx92_sky_icon[fam_key] = ic
	return ic

/datum/beamfx/NewObj(list/sp, pr = 0)
	var/list/fam = BEAMFX_FAM[sp[BFX_FAM]]
	var/front = (sp[BFX_TAG] == "cbolt_f" || sp[BFX_TAG] == "bubble")
	var/obj/energyfx/O = EnergyFXGet(front ? (sp[BFX_LIGHT] ? /obj/energyfx/fsharp : /obj/energyfx/fpaint) : (sp[BFX_LIGHT] ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint), src)
	if(!O) return null
	O.icon = RLFamIcon(sp[BFX_FAM], sp[BFX_LIGHT])
	O.fx_w = fam[2]
	O.fx_h = fam[3]
	O.icon_state = sp[BFX_ST]
	O.layer = sp[BFX_ZL]
	if(sp.len >= BFX_CAR && sp[BFX_CAR])
		var/datum/efx_car/CD = bcars ? bcars[sp[BFX_CAR]] : null
		var/obj/energyfx/carrier/CO = CD ? CarObj(CD) : null
		if(!CO)
			EnergyFXFree(O)
			return null
		O.loc = null
		CO.vis_contents += O
		O.fx_car = CO
		O.fx_bx = CD.bx + O.fx_w / 2
		O.fx_by = CD.by + O.fx_h / 2
	else if(!EnergyFXPlace(O, sp[BFX_X], sp[BFX_Y], z))
		EnergyFXFree(O)
		return null
	O.transform = BeamFXXform(sp, O.fx_bx, O.fx_by)
	O.color = ColorOf(sp)
	O.filters = RLObjFilter(sp[BFX_LIGHT])
	if(sp[BFX_LIGHT]) O.blend_mode = BLEND_ADD
	O.alpha = 0
	return O

/datum/beamfx/StateOf(list/sp)
	return sp[BFX_ST]

/datum/beamfx/ColorOf(list/sp)
	return EFX92_IDENTITY

/datum/beamfx/AlphaOf(list/sp)
	return clamp(sp[BFX_ALPHA] * 255, 0, 255)

/datum/beamfx/Busy()
	if(rl)
		for(var/key in rl_cars)
			var/datum/efx92_car/CD = rl_cars[key]
			if(CD.idle < 3) return 1
		for(var/key in rl_movs)
			var/datum/efx92_mov/MV = rl_movs[key]
			if(MV.idle < 3) return 1
		for(var/key in rl_lcs)
			var/datum/efx92_lc/L = rl_lcs[key]
			if(L.idle < 3) return 1
	if(rl && (rl_sparks.len || rl_glints.len || rl_flares.len || rl_lrays.len || rl_shocks.len || rl_rbolts.len || rl_cbolts.len || rl_bolts.len || rl_sparks2.len)) return 1
	return ..()

/datum/beamfx/Cleanup()
	..()
	if(rl && !rl_g && caster_mob && caster_mob.efx92_keep_key == rl.key) EFX92KeepOff(caster_mob)
	rl_sparks = list()
	rl_glints = list()
	rl_flares = list()
	rl_lrays = list()
	rl_shocks = list()
	rl_rbolts = list()
	rl_cbolts = list()
	rl_bolts = list()
	rl_sparks2 = list()
	for(var/key in rl_cars)
		RLCarFree(rl_cars[key])
	rl_cars = list()
	for(var/key in rl_movs)
		RLMovFree(rl_movs[key])
	rl_movs = list()
	for(var/key in rl_lcs)
		RLLcFree(rl_lcs[key])
	rl_lcs = list()

/datum/beamfx/CasterRimX(t, xs)
	if(isnull(t0)) return 0
	if(!isnull(release_t) && t >= release_t + 0.14) return 0
	var/rampv = clamp((t - t0) / 0.06, 0, 1)
	if(!isnull(release_t) && t >= release_t) rampv *= max(0, 1 - (t - release_t) / 0.1)
	return rampv

/datum/beamfx/ClashLum()
	if(!rl) return
	var/list/pal = rl.P["pal"]
	var/list/gm = pal["g_mid"]
	return max(0.000001, (0.2126 * gm[1] + 0.7152 * gm[2] + 0.0722 * gm[3]) / 255)

/datum/beamfx/LitColor()
	if(!rl) return
	var/list/pal = rl.P["pal"]
	var/list/gm = rl.P["lit"] ? rl.P["lit"] : pal["g_mid"]
	return list(clamp(gm[1] / 255 * 0.85 + 0.15, 0, 1), clamp(gm[2] / 255 * 0.85 + 0.15, 0, 1), clamp(gm[3] / 255 * 0.85 + 0.15, 0, 1))

/datum/beamfx/proc/RLFront(t)
	var/qf = floor(t / BEAMFX_FR + 0.0001)
	var/H = Hr(t, qf, 0)
	if(isnull(H)) return null
	var/em = mz + rl.P["bloom_x"] * rl_st + 6 + Vg * 1.3 * max(0, t - t0)
	return min(H + EFX92_CONTACT + 1, em)

/datum/beamfx/proc/RLVCoil()
	var/list/hx = rl.P["helix"]
	return BeamFXMod(Vs * BEAMFX_TICK, rl.period / hx["turns"] * rl_st)

/datum/beamfx/proc/RLCrawl(bt0, t)
	var/vc = RLVCoil()
	if(isnull(release_t) || t <= release_t) return (t - bt0) / BEAMFX_TICK * vc
	return max(0, release_t - bt0) / BEAMFX_TICK * vc + (t - max(bt0, release_t)) * Vg

/datum/beamfx/proc/RLTickIdx(now, bt0)
	return floor((now - bt0) / BEAMFX_TICK + 0.5)

/datum/beamfx/proc/RLBoltAlive(list/b, now)
	var/list/fr = b["frames"]
	return now < b["t0"] + fr.len * BEAMFX_TICK - 0.000001

/datum/beamfx/proc/RLFramesFor(kind)
	var/list/Ar = rl.P["arcs"]
	var/list/plan = (kind == "beam") ? Ar["plan_beam"] : Ar["plan_short"]
	var/list/fr = list()
	for(var/i = 0 to plan.len - 1)
		fr += i
	if(kind == "beam" && rng3.R() < Ar["skip_p"])
		var/pi = rng3.RandInt(2, 4)
		fr.Cut(pi + 1, pi + 2)
	return fr

/datum/beamfx/proc/RLNewBolt(bt0, kind, mode, owner)
	var/list/arcs = rl.A["arcs"]
	var/list/AK = arcs[kind]
	var/v = rng3.RandRange(AK.len)
	var/list/fr = RLFramesFor(kind)
	var/list/V = AK[v + 1]
	var/sy = (rng3.R() < 0.5) ? 1 : -1
	var/sc = rng3.U(0.9, 1.1)
	rl_uid++
	var/list/b = list("t0" = bt0, "kind" = kind, "var" = v, "frames" = fr, "mode" = mode, "L" = V["L"], "sy" = sy, "sc" = sc, "tilt" = 0, "owner" = owner, "uid" = rl_uid, "chain" = 0, "ch" = 0, "rs" = 0, "side" = 0, "lat" = 0, "d0" = 0, "x" = 0, "y" = 0, "ang" = 0)
	rl_bolts[++rl_bolts.len] = b
	return b

/datum/beamfx/proc/RLBoltPoint(list/b, lx, ly, t)
	ly = ly * b["sy"]
	if(b["mode"] == "beam")
		var/dc = b["d0"] + b["L"] * 0.5 * b["sc"] + RLCrawl(b["t0"], t)
		var/a = b["tilt"]
		var/dd = dc + (lx * cos(a) - ly * sin(a)) * b["sc"]
		var/ll = b["lat"] + (lx * sin(a) + ly * cos(a)) * b["sc"]
		return list(WX(dd, ll), WY(dd, ll))
	var/th = b["ang"]
	return list(b["x"] + (lx * cos(th) - ly * sin(th)) * b["sc"], b["y"] + (lx * sin(th) + ly * cos(th)) * b["sc"])

/datum/beamfx/proc/RLAddSparks(st0, x, y, base_ang, spread, n, vk = 1)
	var/list/S = rl.P["sparks"]
	var/list/sv = S["v"]
	var/list/sl = S["life"]
	var/list/arcs = rl.A["arcs"]
	var/list/sa = arcs["sparks"]
	for(var/i = 1 to n)
		var/th = base_ang + rng3.U(-spread, spread)
		var/v = rng3.U(sv[1], sv[2]) * vk
		var/life = rng3.U(sl[1], sl[2])
		var/g = rng3.RandRange(sa.len)
		var/tt = st0 + rng3.U(0, 0.02)
		var/sc = rng3.U(0.85, 1.15)
		rl_uid++
		rl_sparks2[++rl_sparks2.len] = list(tt, x, y, th, v, life, g, sc, rl_uid)

/datum/beamfx/proc/RLStrikeSparks(list/b, n, out_ang, spread, vk = 1)
	var/list/arcs = rl.A["arcs"]
	var/list/AK = arcs[b["kind"]]
	var/list/V = AK[b["var"] + 1]
	var/list/pts = V["kinks"]
	for(var/i = 0 to n - 1)
		var/list/pt = (i == 0) ? pts[pts.len] : pts[rng3.RandRange(pts.len) + 1]
		var/list/xy = RLBoltPoint(b, pt[1], pt[2], b["t0"])
		RLAddSparks(b["t0"], xy[1], xy[2], out_ang, spread, 1, vk)

/datum/beamfx/proc/RLWoundBolt(bt0, th, r_in, sparks, pd)
	var/cx = WX(pd - 3)
	var/cy = WY(pd - 3)
	var/list/b = RLNewBolt(bt0, "short", "fixed", "wound")
	b["ang"] = th
	b["sc"] = b["sc"] * ((r_in < 3) ? 1.3 : 1)
	var/r0 = r_in + 0.5 * b["L"] * b["sc"]
	b["x"] = cx + cos(th) * r0
	b["y"] = cy + sin(th) * r0
	if(sparks) RLStrikeSparks(b, sparks, th, 35, 1.1)
	return b

/datum/beamfx/proc/RLPierceBurst(bt0, pd)
	var/list/Ar = rl.P["arcs"]
	var/list/S = rl.P["sparks"]
	var/n = Ar["pierce_first"]
	var/a0 = rng3.U(0, 360)
	for(var/i = 0 to n - 1)
		var/th = a0 + i * 360 / n + rng3.U(-22, 22)
		RLWoundBolt(bt0, th, 2, 1, pd)
	var/cx = WX(pd - 3)
	var/cy = WY(pd - 3)
	for(var/i = 1 to S["pierce"])
		var/ba = rng3.U(0, 360)
		RLAddSparks(bt0, cx, cy, ba, 0, 1, 1.25)

/datum/beamfx/proc/RLTickPierce(now, qn)
	for(var/list/pt in rl_pts)
		if(isnull(pt[2]))
			var/edge = pt[1] - 7
			var/f = RLFront(now)
			if(!isnull(f) && f >= edge)
				var/tp = now
				for(var/i = 0 to 19)
					var/tt = now - BEAMFX_TICK + i * 0.0025
					var/ff = RLFront(tt)
					if(!isnull(ff) && ff >= edge)
						tp = tt
						break
				tp = max(t0, tp)
				pt[2] = tp
				var/kt = tp / BEAMFX_TICK
				var/ki = round(kt, 1)
				var/kc = (abs(kt - ki) < 0.0001) ? ki : ceil(kt)
				RLPierceBurst(kc * BEAMFX_TICK, pt[1])
		if(!isnull(pt[2]) && isnull(pt[3]) && !isnull(release_t))
			if(Back(now, qn) >= pt[1] + 8) pt[3] = now
	RLRestrikeSparks(now, qn)
	if(!(s_dead && !isnull(dead_t) && now > dead_t + 0.05))
		RLSpawnBeamBolts(now, qn)
		RLSpawnMuzzleBolts(now, qn)
		for(var/list/pt2 in rl_pts)
			RLSpawnWoundBolts(now, qn, pt2)

/datum/beamfx/proc/RLRestrikeSparks(now, qn)
	var/list/S = rl.P["sparks"]
	var/list/Ar = rl.P["arcs"]
	var/list/H = rl.P["helix"]
	var/list/born = list()
	for(var/bi = 1 to rl_bolts.len)
		var/list/b = rl_bolts[bi]
		var/fi = RLTickIdx(now, b["t0"])
		var/list/fr = b["frames"]
		if(b["mode"] == "beam" && fi >= 0 && fi < fr.len && fr[fi + 1] == 3 && !b["ch"] && b["chain"] < Ar["chain_max"])
			if(rng3.R() < Ar["chain_p"])
				b["ch"] = 1
				var/d_now = b["d0"] + RLCrawl(b["t0"], now)
				var/list/cst = Ar["chain_step"]
				born[++born.len] = list(d_now + b["L"] * b["sc"] * rng3.U(cst[1], cst[2]), b["side"], b["chain"] + 1)
	var/list/al = Ar["lat"]
	for(var/list/bn in born)
		var/f = RLFront(now)
		if(isnull(f) || bn[1] > f - 8) continue
		var/side = bn[2]
		var/lat = side * (H["R"] + rng3.U(al[1], al[2]))
		var/tilt = rng3.U(-Ar["tilt"], Ar["tilt"])
		var/list/nb = RLNewBolt(now, "beam", "beam", null)
		nb["lat"] = lat
		nb["side"] = side
		nb["tilt"] = tilt
		nb["chain"] = bn[3]
		nb["d0"] = bn[1]
		var/list/sk = S["strike"]
		RLStrikeSparks(nb, rng3.RandInt(sk[1], sk[2]), ang + side * 90, S["spread"])
	for(var/bi2 = 1 to rl_bolts.len)
		var/list/b2 = rl_bolts[bi2]
		var/fi2 = RLTickIdx(now, b2["t0"])
		var/list/fr2 = b2["frames"]
		if(fi2 >= 0 && fi2 < fr2.len && fr2[fi2 + 1] == 3 && !b2["rs"])
			if(rng3.R() < S["restrike_p"])
				b2["rs"] = 1
				var/list/arcs = rl.A["arcs"]
				var/list/AK = arcs[b2["kind"]]
				var/list/V = AK[b2["var"] + 1]
				var/list/pts = V["kinks"]
				var/list/pt = pts[rng3.RandRange(pts.len) + 1]
				var/list/xy = RLBoltPoint(b2, pt[1], pt[2], now)
				var/base = (b2["mode"] == "beam") ? (ang + b2["side"] * 90) : b2["ang"]
				RLAddSparks(now, xy[1], xy[2], base, S["spread"], 1)

/datum/beamfx/proc/RLSpawnBeamBolts(now, qn)
	var/list/P = rl.P
	var/list/Ar = P["arcs"]
	var/list/H = P["helix"]
	var/list/S = P["sparks"]
	var/firing = isnull(release_t)
	var/f = RLFront(now)
	if(isnull(f)) return
	var/lo = firing ? (mz + P["root_L"] * 0.5 * rl_st) : (Back(now, qn) + 12)
	var/hi = min(f - 8, lo + 15 * 32)
	var/Lspan = hi - lo
	if(Lspan < 20) return
	var/list/pb = Ar["plan_beam"]
	var/mean_life = pb.len - Ar["skip_p"]
	var/lam = Ar["density"] * Lspan / 32 / mean_life
	var/n = floor(lam) + ((rng3.R() < lam - floor(lam)) ? 1 : 0)
	var/list/al = Ar["lat"]
	var/list/sk = S["strike"]
	for(var/i = 1 to n)
		var/side = (rng3.R() < 0.5) ? 1 : -1
		var/lat = side * (H["R"] + rng3.U(al[1], al[2]))
		var/tilt = rng3.U(-Ar["tilt"], Ar["tilt"])
		var/list/b = RLNewBolt(now, "beam", "beam", null)
		b["lat"] = lat
		b["side"] = side
		b["tilt"] = tilt
		b["d0"] = rng3.U(lo, max(lo, hi - b["L"]))
		RLStrikeSparks(b, rng3.RandInt(sk[1], sk[2]), ang + side * 90, S["spread"])

/datum/beamfx/proc/RLSpawnMuzzleBolts(now, qn)
	if(!isnull(release_t)) return
	var/list/Ar = rl.P["arcs"]
	var/alive = 0
	for(var/list/b in rl_bolts)
		if(b["owner"] == "muzzle" && RLBoltAlive(b, now)) alive++
	var/list/ma = Ar["muzzle_alive"]
	var/want = rng3.RandInt(ma[1], ma[2])
	var/mx = WX(mz + 1)
	var/my = WY(mz + 1)
	for(var/i = 1 to max(0, want - alive))
		var/th = ang + 180 + rng3.U(-115, 115)
		var/list/b2 = RLNewBolt(now, "short", "fixed", "muzzle")
		b2["ang"] = th
		var/r0 = 2 + 0.5 * b2["L"] * b2["sc"]
		b2["x"] = mx + cos(th) * r0
		b2["y"] = my + sin(th) * r0
		RLStrikeSparks(b2, rng3.RandInt(1, 2), th, 40, 0.8)

/datum/beamfx/proc/RLSpawnWoundBolts(now, qn, list/pt)
	if(isnull(pt[2]) || now <= pt[2] + 0.000001 || !isnull(pt[3])) return
	var/alive = 0
	for(var/list/b in rl_bolts)
		if(b["owner"] == "wound" && RLBoltAlive(b, now)) alive++
	if(alive == 0)
		var/list/Ar = rl.P["arcs"]
		if(rng3.R() < Ar["pierce_hold_p"])
			var/th = rng3.U(0, 360)
			RLWoundBolt(now, th, 4, 1, pt[1])

/datum/beamfx/proc/RLSpritesPierce(list/out, fi, t, Hrv)
	var/list/A = rl.A
	var/stk = rl_st
	var/firing = isnull(release_f) || fi < release_f
	var/bk = Back(t, fi)
	var/nd = RLDraw(fi)
	var/list/hg = RLHeadGeom(t, fi, Hrv, 0, nd)
	var/list/Hd = hg[1]
	var/ramped = Hd["ramped"] ? 1 : 0
	var/xh
	var/ih
	var/list/sn = RLSnap(hg[3], t, fi)
	if(ramped)
		ih = sn[2]
		xh = mz - Hd["xm"] * stk
	else
		xh = sn[1]
		ih = sn[2]
	var/head_cut = xh + Hd["cut"] * stk
	var/hi_cut = head_cut
	var/lo_cut = null
	var/list/St = A["star"]
	var/list/sfr = St["frames"]
	var/jm = BeamFXMod(nd, sfr.len)
	if(firing)
		var/al = min(1, (t - t0) / 0.04)
		RLPair(out, sfr[jm + 1], WX(mz), WY(mz), 0, 1, 1, al, 4.6, 0, null, null, "star", "mz")
		if(!ramped)
			var/list/Rt = A["root"]
			var/list/sb = RLSnap(mz, t, fi)
			var/xb = sb[1]
			lo_cut = xb + Rt["cut"] * stk
			var/rp_ = xb + Rt["ox"] * stk
			var/list/rfr = Rt["frames"]
			var/list/cuts = list(RLCut(min(lo_cut, head_cut), -1, stk))
			RLPair(out, rfr[sb[2] + 1], WX(rp_), WY(rp_), ang, stk, 1, 1, 4.5, 0, cuts, cuts, "root", "rt")
	else
		var/q = (t - release_t) / 0.1
		if(q < 1)
			var/sc = 1 - 0.85 * q
			var/al2 = (1 - q) ** 1.2
			RLPair(out, sfr[jm + 1], WX(mz), WY(mz), 0, sc, sc, al2, 4.6, 0, null, null, "star", "mz")
		var/list/T = A["tail"]
		var/list/stl = RLSnap(bk, t, fi)
		var/xt = stl[1]
		lo_cut = xt + T["cut"] * stk
		var/tp_ = xt + T["ox"] * stk
		var/list/tfr = T["frames"]
		var/list/cuts2 = list(RLCut(min(lo_cut, head_cut), -1, stk))
		RLPair(out, tfr[stl[2] + 1], WX(tp_), WY(tp_), ang, stk, 1, 1, 4.2, 0, cuts2, cuts2, "tail", "tl")
	var/list/hcuts = ramped ? list() : list(RLCut(head_cut, 1, stk))
	var/hp = xh + Hd["ox"] * stk
	var/list/hfr = Hd["frames"]
	RLPair(out, hfr[ih + 1], WX(hp), WY(hp), ang, stk, 1, 1, 5, 0, hcuts, hcuts, "head", "hd[hg[2]]")
	if(!isnull(lo_cut) && lo_cut < hi_cut && !ramped)
		RLStampPass(out, fi, t, Hrv, bk, lo_cut, hi_cut, stk)
	if(rl.B)
		RLBurstSprites(out, t, fi, Hrv, xh, Hd, 0, firing, 0)
		if(rl_draw) RLPierceFlash(out, t, fi)
	RLBoltSprites(out, t, fi)
	RLSpark2Sprites(out, t, fi)

/datum/beamfx/proc/RLBoltSprites(list/out, t, fi)
	var/list/arcs = rl.A["arcs"]
	var/list/keep = list()
	for(var/list/b in rl_bolts)
		var/bf = RLAge(t, b["t0"])
		var/list/fr = b["frames"]
		if(bf >= fr.len) continue
		keep[++keep.len] = b
		if(bf < 0 || !rl_draw) continue
		var/list/AK = arcs[b["kind"]]
		var/list/V = AK[b["var"] + 1]
		var/list/vfr = V["frames"]
		var/list/pair = vfr[fr[bf + 1] + 1]
		var/x
		var/y
		var/a
		if(b["mode"] == "beam")
			var/list/xy = RLBoltPoint(b, 0, 0, t)
			x = xy[1]
			y = xy[2]
			a = ang + b["tilt"]
		else
			x = b["x"]
			y = b["y"]
			a = b["ang"]
		RLPair(out, pair, x, y, a, b["sc"], b["sy"] * b["sc"], 1, 5.6, 0, null, null, "bolt", "bo[b["uid"]]")
	rl_bolts = keep

/datum/beamfx/proc/RLSpark2Sprites(list/out, t, fi)
	var/list/arcs = rl.A["arcs"]
	var/list/SA = arcs["sparks"]
	var/list/keep = list()
	for(var/list/sp in rl_sparks2)
		var/age = t - sp[1]
		if(age >= sp[6]) continue
		keep[++keep.len] = sp
		if(age < 0 || !rl_draw) continue
		var/tau = age / sp[6]
		var/dist = sp[5] * sp[6] * (1 - (1 - tau) ** 2) * 0.5
		var/x = sp[2] + cos(sp[4]) * dist
		var/y = sp[3] + sin(sp[4]) * dist
		var/sx = sp[8] * (0.45 + 0.55 * (1 - tau))
		var/sy = sp[8] * (1 - 0.5 * tau)
		RLPair(out, SA[sp[7] + 1], x, y, sp[4] + 180, sx, sy, 1 - tau * tau, 5.7, 0, null, null, "spark", "s2[sp[9]]")
	rl_sparks2 = keep

/datum/beamfx/proc/RLPierceFlash(list/out, t, fi)
	var/list/FL = rl.B["flash"]
	var/list/FA = FL["frames"]
	var/fres = FL["res"]
	if(isnull(fres)) fres = 1
	var/dur = RLP("pflash_t", 0.3)
	for(var/list/pt in rl_pts)
		if(isnull(pt[2]) || t < pt[2]) continue
		var/dt = t - pt[2]
		if(dt > dur) continue
		var/jf = BeamFXMod(floor((fi - fi0) / 2), FA.len)
		var/bud = min(1, dt / 0.04)
		var/al = bud * ((dt < 0.04) ? 1 : (max(0, 1 - (dt - 0.04) / (dur - 0.04)) ** 1.3))
		var/jit = 0.9 + 0.2 * BeamFXMod(BeamFXMod(fi, 97) * 62 + BeamFXMod(fi0, 97) * 31, 97) / 97
		var/ksc = rl.P["flash_k"] * (0.55 + 0.45 * bud) * jit / fres
		if(al > 0.01) RLRec(out, FA[jf + 1], WX(pt[1] - 4), WY(pt[1] - 4), 0, ksc, ksc, min(1, al), 0, 0, 1, null, "pflash", "pf[pt[1]]")

/datum/beamfx/proc/RLWidenPierce(list/sprs, fi, t)
	var/k = rl_k
	var/q = sqrt(k)
	var/list/out = list()
	for(var/list/s in sprs)
		var/tg = s[RL92_TAG]
		var/list/fc = RLFC(s[RL92_X], s[RL92_Y])
		var/dd = fc[1]
		var/lat = fc[2]
		var/rel = BeamFXMod(s[RL92_ANG] - ang, 180)
		var/aligned = (rel < 1 || rel > 179) ? 1 : 0
		var/list/r = s.Copy()
		if(tg == "root" || tg == "stamp" || tg == "tail" || tg == "head")
			var/list/w = RLTW(dd, lat0 + k * (lat - lat0))
			r[RL92_X] = w[1]
			r[RL92_Y] = w[2]
			if(aligned)
				r[RL92_SY] = s[RL92_SY] * k
			else
				r[RL92_SX] = s[RL92_SX] * k
				r[RL92_SY] = s[RL92_SY] * k
		else if(tg == "star")
			var/list/w2 = RLTW(mz + q * (dd - mz), lat0 + q * (lat - lat0))
			r[RL92_X] = w2[1]
			r[RL92_Y] = w2[2]
			r[RL92_SX] = s[RL92_SX] * q
			r[RL92_SY] = s[RL92_SY] * q
		else if(tg == "bolt" || tg == "spark")
			var/list/w3 = RLTW(dd, lat0 + k * (lat - lat0))
			r[RL92_X] = w3[1]
			r[RL92_Y] = w3[2]
			r[RL92_SX] = s[RL92_SX] * q
			r[RL92_SY] = s[RL92_SY] * q
		else if(tg == "pflash")
			r[RL92_SX] = s[RL92_SX] * q
			r[RL92_SY] = s[RL92_SY] * q
		out[++out.len] = r
	return out

/datum/efx92_car
	var/key
	var/obj/energyfx/carrier/O
	var/obj/energyfx/C
	var/light = 0
	var/B = 384
	var/bx = 0
	var/by = 0
	var/dv = -1
	var/shown = 0
	var/idle = 0
	var/nc = 0
	var/list/cn
	var/list/last
	var/list/lastq
	var/list/xm

/datum/efx92_mov
	var/key
	var/obj/energyfx/M
	var/light = 0
	var/g = 0
	var/list/kids = list()
	var/dv = -1
	var/shown = 0
	var/idle = 0
	var/list/lastT

var/list/efx92_m2_icons = list()
var/list/efx92_m2_idx = list()
var/efx92_m2_miss = 0

proc/EFX92M2Icon(st)
	var/icon/I = efx92_m2_icons[st]
	if(!I)
		I = icon(EFX92_M2_FILE[st], st)
		efx92_m2_icons[st] = I
	return I

proc/EFX92M2Index(soft, g)
	var/key = "[round(soft, 0.001)]|[g]"
	var/v = efx92_m2_idx[key]
	if(!isnull(v)) return v
	var/best = 0
	var/bd = 1000000
	for(var/i = 1 to EFX92_M2_S.len)
		if(EFX92_M2_G[i] != g) continue
		var/dv = abs(EFX92_M2_S[i] - soft)
		if(dv < bd)
			bd = dv
			best = i - 1
	if(bd > 0.001) efx92_m2_miss++
	efx92_m2_idx[key] = best
	return best

proc/EFX92CutState(list/c)
	var/nx = c[3]
	var/ny = c[4]
	if(abs(nx) > 0.99) return "x[(nx > 0) ? "p" : "n"][EFX92M2Index(c[5], 0)]"
	if(abs(ny) > 0.99) return "y[(ny > 0) ? "p" : "n"][EFX92M2Index(c[5], 0)]"
	return "[(nx * ny > 0) ? "d" : "e"][(nx > 0) ? "p" : "n"][EFX92M2Index(c[5], 1)]"

proc/EFX92CutSig(list/cuts)
	var/s = ""
	for(var/list/c in cuts)
		s += "[EFX92CutState(c)],"
	return s

proc/EFX92CutPlan(list/c, cx, cy)
	var/nx = c[3]
	var/ny = c[4]
	var/st = EFX92CutState(c)
	var/g = (abs(nx) > 0.99 || abs(ny) > 0.99) ? 0 : 1
	var/dist = (cx - c[1]) * nx + (cy - c[2]) * ny
	var/qx = cx - dist * nx
	var/qy = cy - dist * ny
	var/off = c[5] / 2 + 0.5 + (g ? 0 : EFX92_BLOCK_AXIS / 2)
	var/kst = g ? "k[copytext(st, 1, 3)]" : "kxp"
	return list(st, qx, qy, kst, qx - nx * off, qy - ny * off)

/datum/beamfx/var/list/rl_cf
/datum/beamfx/var/list/rl_sf
/datum/beamfx/var/list/rl_sw
/datum/beamfx/var/list/rl_cars = list()
/datum/beamfx/var/list/rl_movs = list()
/datum/beamfx/var/list/rl_mplan
/datum/beamfx/var/rl_carB = 384
/datum/beamfx/var/rl_carF
/datum/beamfx/var/list/rl_gspark
/datum/beamfx/var/rl_j = 1
/datum/beamfx/var/rl_se0
/datum/beamfx/var/rl_se1

/datum/beamfx/proc/RLStampPass(list/out, fi, t, Hrv, bk, lo_cut, hi_cut, stk)
	var/list/gone
	var/rep = 0
	for(var/si = 1 to stamp_m.len)
		if(stamp_tbf[si] > fi) continue
		var/m = stamp_m[si]
		var/dd = LatD(m, t, fi)
		if(dd > Hrv + S * 4 + 40 || dd < bk - S * 4)
			if(!gone) gone = list()
			gone += m
			continue
		if(rep || !rl_draw) continue
		if(dd + S < lo_cut || dd - S > hi_cut) continue
		rep = 1
		var/list/cs = list(RLCut(lo_cut, 1, stk), RLCut(hi_cut, -1, stk))
		var/list/stamps = rl.A["stamps"]
		RLPair(out, stamps[BeamFXMod(m, rl.np) + 1], WX(dd), WY(dd), ang, stk, 1, 1, 4, m, cs, cs, "stamp", "s")
		rl_sw[rl_j] = list(lo_cut, hi_cut)
	if(gone)
		for(var/m in gone)
			var/gi = stamp_m.Find(m)
			if(gi)
				stamp_m.Cut(gi, gi + 1)
				stamp_tbf.Cut(gi, gi + 1)

/datum/beamfx/proc/RLZo()
	return (clash_mode && partner && !clash_lead) ? 0.02 : 0

/datum/beamfx/proc/RLEmitAll(j, fi, list/out)
	rl_bm = RLBendMode(fi)
	if(rl_bm)
		RLBendAll(j, fi, out)
		return
	var/pidx = 0
	var/list/cf = rl_cf[j]
	var/list/sf = rl_sf[j]
	for(var/list/r in out)
		var/si = r[RL92_ST]
		if(isnull(si) || si < 0) continue
		var/kind = r[RL92_KIND]
		if(r[RL92_TAG] == "stamp")
			sf[kind + 1] = r
			continue
		var/list/stt = rl.S[si + 1]
		var/file = stt[1] + 1
		var/fxo = stt[3]
		var/fyo = stt[4]
		var/a = r[RL92_ANG]
		var/ca = cos(a)
		var/sa = sin(a)
		var/sx = r[RL92_SX]
		var/sy = r[RL92_SY]
		var/fcx = r[RL92_X] + ca * sx * fxo - sa * sy * fyo
		var/fcy = r[RL92_Y] + sa * sx * fxo + ca * sy * fyo
		var/lay = r[RL92_LY]
		var/zl = 0
		if(kind == 0)
			pidx++
			zl = lay + pidx * 0.000001 + RLZo()
		var/list/cuts = r[RL92_CUTS]
		if(cuts && cuts.len)
			cf["[r[RL92_KEY]]|f[file]|[EFX92CutSig(cuts)]"] = list(list(rl.fams[file], stt[2], kind, fcx, fcy, a, sx, sy, 0, r[RL92_AL], lay, r[RL92_OR], r[RL92_TAG], 1, null, zl, 0), cuts)
		else
			Emit(j, "[r[RL92_KEY]]|f[file]", rl.fams[file], stt[2], kind, fcx, fcy, a, sx, sy, 0, r[RL92_AL], lay, r[RL92_OR], r[RL92_TAG], 1, null, zl, 0)

/datum/beamfx/proc/RLStampExtent()
	if(!isnull(rl_se0)) return
	var/list/stamps = rl.A["stamps"]
	rl_se0 = 1000000
	rl_se1 = -1000000
	for(var/list/pr in stamps)
		for(var/idx in pr)
			var/list/stt = rl.S[idx + 1]
			var/w = rl.FW[stt[1] + 1]
			rl_se0 = min(rl_se0, stt[3] - w / 2)
			rl_se1 = max(rl_se1, stt[3] + w / 2)

/datum/beamfx/proc/RLStampSpec(m, dd, list/rep, kind)
	var/list/stamps = rl.A["stamps"]
	var/list/pr = stamps[BeamFXMod(m, rl.np) + 1]
	var/list/stt = rl.S[pr[kind + 1] + 1]
	var/file = stt[1] + 1
	var/a = rep[RL92_ANG]
	var/ca = cos(a)
	var/sa = sin(a)
	var/sx = rep[RL92_SX]
	var/sy = rep[RL92_SY]
	var/x = WX(dd) + ca * sx * stt[3] - sa * sy * stt[4]
	var/y = WY(dd) + sa * sx * stt[3] + ca * sy * stt[4]
	return list(rl.fams[file], stt[2], kind, x, y, a, sx, sy, 0, rep[RL92_AL], 4, m, "stamp", 1, null, kind ? 0 : 4 + (m + 500) * 0.00001 + RLZo(), 0)

/datum/beamfx/proc/RLStreamPlan(f1, v1, v2)
	rl_mplan = list()
	RLStampExtent()
	var/j1 = (v1 == f1 || v2 == f1) ? 1 : 0
	var/j2 = (v2 == f1 + 1) ? 1 : 0
	if(!j1 && !j2) return
	var/list/base = list(0, 0)
	if(j1) base[1] = dstart + LatBase(FT(f1), f1)
	if(j2) base[2] = dstart + LatBase(FT(f1 + 1), f1 + 1)
	var/nm = stamp_m.len
	var/np = rl.np
	for(var/kind = 0 to 1)
		var/list/reps = list(null, null)
		if(j1)
			var/list/sf1 = rl_sf[1]
			reps[1] = sf1[kind + 1]
		if(j2)
			var/list/sf2 = rl_sf[2]
			reps[2] = sf2[kind + 1]
		if(!reps[1] && !reps[2]) continue
		var/list/cps = list(null, null)
		var/list/e0s = list(0, 0)
		var/list/e1s = list(0, 0)
		for(var/j = 1 to 2)
			var/list/rep = reps[j]
			if(!rep) continue
			var/list/cc = list()
			for(var/list/c in rep[RL92_CUTS])
				cc += (c[1] - Ox) * ax + (c[2] - Oy) * ay
				cc += ((c[3] * ax + c[4] * ay) > 0) ? 1 : -1
				cc += c[5] / 2 + 1
			cps[j] = cc
			e0s[j] = base[j] + rl_se0 * rep[RL92_SX]
			e1s[j] = base[j] + rl_se1 * rep[RL92_SX]
		var/list/inside = list()
		var/list/edge = list()
		for(var/si = 1 to nm)
			if(stamp_tbf[si] > f1) continue
			var/m = stamp_m[si]
			var/sm = S * m
			var/allin = 1
			var/allout = 1
			for(var/j = 1 to 2)
				var/list/cc = cps[j]
				if(!cc) continue
				var/e0 = e0s[j] + sm
				var/e1 = e1s[j] + sm
				var/fin = 1
				var/fout = 0
				for(var/ci = 1 to cc.len step 3)
					var/cp = cc[ci]
					var/h = cc[ci + 2]
					if(cc[ci + 1] > 0)
						if(e1 < cp - h) fout = 1
						if(e0 <= cp + h) fin = 0
					else
						if(e0 > cp + h) fout = 1
						if(e1 >= cp - h) fin = 0
				if(!fin) allin = 0
				if(!fout) allout = 0
			if(allout) continue
			if(allin) inside += m
			else
				var/pos = edge.len + 1
				for(var/ei = 1 to edge.len)
					if(edge[ei] > m)
						pos = ei
						break
				edge.Insert(pos, m)
		for(var/j = 1 to 2)
			var/list/rep = reps[j]
			if(!rep || !edge.len) continue
			var/list/win = rl_sw[j]
			var/list/cf = rl_cf[j]
			var/sig = EFX92CutSig(rep[RL92_CUTS])
			for(var/ei = 1 to edge.len)
				var/m = edge[ei]
				var/dd = base[j] + S * m
				if(win && (dd + S < win[1] || dd - S > win[2])) continue
				cf["b[kind]:[ei]|[sig]"] = list(RLStampSpec(m, dd, rep, kind), rep[RL92_CUTS])
		var/list/segs = list()
		for(var/m in inside)
			var/g = floor(m / np)
			var/gk = "[kind]|[g]"
			var/list/P = segs[gk]
			if(!P)
				var/list/wt = list(null, null)
				for(var/j = 1 to 2)
					var/list/rep = reps[j]
					if(!rep)
						if((j == 1 && j1) || (j == 2 && j2)) wt[j] = "hide"
						continue
					var/d0 = base[j] + S * g * np
					wt[j] = list(WX(d0), WY(d0), rep[RL92_ANG], rep[RL92_SX], rep[RL92_SY], rep)
				P = list(list(), wt, kind, g)
				segs[gk] = P
			var/list/kl = P[1]
			kl += m
		for(var/gk in segs)
			rl_mplan[gk] = segs[gk]

/datum/beamfx/proc/RLCarPlace(datum/efx92_car/CD, x, y)
	var/bx = floor(x) - CD.B / 2
	var/by = floor(y) - CD.B / 2
	var/turf/T = locate(floor(bx / 32) + 1, floor(by / 32) + 1, z)
	if(!T) return 0
	CD.O.loc = T
	CD.O.pixel_x = bx - (T.x - 1) * 32
	CD.O.pixel_y = by - (T.y - 1) * 32
	CD.bx = bx
	CD.by = by
	if(CD.C)
		CD.C.fx_bx = bx + CD.C.fx_w / 2
		CD.C.fx_by = by + CD.C.fx_h / 2
	return 1

/datum/beamfx/proc/RLCarFree(datum/efx92_car/CD)
	if(CD.C)
		EnergyFXFree(CD.C)
		CD.C = null
	var/obj/energyfx/carrier/O = CD.O
	CD.O = null
	if(!O) return
	O.filters = null
	O.icon = null
	O.icon_state = null
	O.pixel_x = 0
	O.pixel_y = 0
	EnergyFXFree(O)

/datum/beamfx/proc/RLCarPos(datum/efx92_car/CD, list/sp, list/cuts)
	var/list/out = list()
	var/cx = sp[BFX_X]
	var/cy = sp[BFX_Y]
	for(var/ci = 1 to CD.nc)
		var/list/c = cuts[ci]
		var/list/n = CD.cn[ci]
		var/nx = n[1]
		var/ny = n[2]
		var/dist = (cx - c[1]) * nx + (cy - c[2]) * ny
		var/qx = cx - dist * nx
		var/qy = cy - dist * ny
		var/off = c[5] / 2 + 0.5 + n[3]
		out += qx
		out += qy
		out += qx - nx * off
		out += qy - ny * off
	return out

/datum/beamfx/proc/RLCarNew(key, list/sp, list/cuts, list/extra)
	var/datum/efx92_car/CD = new
	CD.key = key
	CD.light = sp[BFX_LIGHT]
	CD.B = rl_carB
	var/obj/energyfx/carrier/O = EnergyFXGet(/obj/energyfx/carrier, src)
	if(!O) return null
	CD.O = O
	O.icon = rl_carF
	O.icon_state = "b"
	O.plane = CD.light ? ENERGYFX_SHARP_PLANE : ENERGYFX_PAINT_PLANE
	O.blend_mode = CD.light ? BLEND_ADD : BLEND_DEFAULT
	O.appearance_flags = KEEP_TOGETHER
	O.layer = sp[BFX_ZL]
	if(!RLCarPlace(CD, sp[BFX_X], sp[BFX_Y]))
		RLCarFree(CD)
		return null
	var/obj/energyfx/C = EnergyFXGet(CD.light ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, src)
	if(!C)
		RLCarFree(CD)
		return null
	CD.C = C
	var/list/fam = BEAMFX_FAM[sp[BFX_FAM]]
	C.icon = RLFamIcon(sp[BFX_FAM], CD.light)
	C.fx_w = fam[2]
	C.fx_h = fam[3]
	C.icon_state = sp[BFX_ST]
	C.layer = sp[BFX_ZL]
	C.loc = null
	C.fx_bx = CD.bx + C.fx_w / 2
	C.fx_by = CD.by + C.fx_h / 2
	C.transform = BeamFXXform(sp, C.fx_bx, C.fx_by)
	C.color = ColorOf(sp)
	C.filters = RLObjFilter(CD.light)
	C.alpha = 0
	O.vis_contents += C
	C.fx_car = O
	CD.nc = cuts.len
	CD.cn = list()
	var/list/sts = list()
	for(var/list/c in cuts)
		var/st = EFX92CutState(c)
		var/g = (abs(c[3]) > 0.99 || abs(c[4]) > 0.99) ? 0 : 1
		CD.cn += list(list(c[3], c[4], g ? 0 : EFX92_BLOCK_AXIS / 2))
		sts += st
		sts += g ? "k[copytext(st, 1, 3)]" : "kxp"
	CD.lastq = RLCarPos(CD, sp, cuts)
	var/cx0 = CD.bx + CD.B / 2
	var/cy0 = CD.by + CD.B / 2
	var/list/fl = list()
	for(var/fidx = 1 to CD.nc * 2)
		fl += filter(type = "alpha", icon = EFX92M2Icon(sts[fidx]), x = CD.lastq[fidx * 2 - 1] - cx0, y = CD.lastq[fidx * 2] - cy0, flags = MASK_INVERSE)
	CD.xm = extra
	if(extra)
		for(var/list/xm in extra)
			if(xm[1] == "rs" || xm[1] == "rsi") fl += filter(type = "alpha", render_source = xm[2], x = xm[3] - cx0, y = xm[4] - cy0, flags = (xm[1] == "rsi") ? MASK_INVERSE : 0)
			else fl += filter(type = "alpha", icon = EnergyFXBendIcon(xm[1], xm[2]), x = xm[3] - cx0, y = xm[4] - cy0)
	O.filters = fl
	CD.last = sp
	return CD

/datum/beamfx/proc/RLCarRel(list/q, cx0, cy0)
	var/list/o = list()
	for(var/i = 1 to q.len step 2)
		o += q[i] - cx0
		o += q[i + 1] - cy0
	return o

/datum/beamfx/proc/RLFiltAnim(obj/O, fidx, list/st, delay_first, endnow)
	for(var/i = 1 to st.len step 2)
		if(i == 1) animate(O.filters[fidx], x = st[1], y = st[2], time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN, flags = endnow ? (ANIMATION_END_NOW | ANIMATION_PARALLEL) : ANIMATION_PARALLEL)
		else animate(O.filters[fidx], x = st[i], y = st[i + 1], time = 0.25, easing = JUMP_EASING | EASE_IN)
		energyfx_anim_n++

/datum/beamfx/proc/RLCarChildStep(datum/efx92_car/CD, w, started, delay_first, hold_pre)
	var/obj/energyfx/C = CD.C
	if(started && hold_pre > 0) animate(transform = BeamFXXform(CD.last, C.fx_bx, C.fx_by), time = hold_pre)
	if(w == "hide")
		if(!started) animate(C, color = EFX92FoldA(EFX92_IDENTITY, 0), time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN)
		else animate(color = EFX92FoldA(EFX92_IDENTITY, 0), time = 0.25, easing = JUMP_EASING | EASE_IN)
		CD.shown = 0
	else
		var/list/wl = w
		var/list/sp = wl[1]
		if(!started) animate(C, transform = BeamFXXform(sp, C.fx_bx, C.fx_by), color = EFX92FoldA(ColorOf(sp), AlphaOf(sp)), icon_state = sp[BFX_ST], time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		else animate(transform = BeamFXXform(sp, C.fx_bx, C.fx_by), color = EFX92FoldA(ColorOf(sp), AlphaOf(sp)), icon_state = sp[BFX_ST], time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		CD.last = sp
		CD.shown = 1
	energyfx_anim_n++

/datum/beamfx/proc/RLCarRealize(f1, v1, v2)
	var/list/F1 = rl_cf[1]
	var/list/F2 = rl_cf[2]
	var/list/keys = list()
	for(var/key in F1) keys[key] = 1
	for(var/key in F2) keys[key] = 1
	for(var/key in rl_cars) keys[key] = 1
	for(var/key in keys)
		var/list/s1 = F1[key]
		var/list/s2 = F2[key]
		var/datum/efx92_car/CD = rl_cars[key]
		var/list/want = list()
		for(var/si = 1 to 2)
			var/v = (si == 1) ? v1 : v2
			if(si == 2 && v2 == v1)
				want += list(null)
			else if(v < f1)
				want += list((CD && CD.dv == v) ? null : "hide")
			else
				var/list/e = (v == f1) ? s1 : s2
				want += list(e ? e : "hide")
		if(!CD)
			var/list/fs
			for(var/w in want)
				if(islist(w))
					fs = w
					break
			if(!fs) continue
			CD = RLCarNew(key, fs[1], fs[2], (fs.len > 2) ? fs[3] : null)
			if(!CD) continue
			rl_cars[key] = CD
		for(var/si = 1 to 2)
			if(want[si] == "hide" && !CD.shown) want[si] = null
		var/list/first
		for(var/w in want)
			if(islist(w))
				var/list/wl = w
				first = wl[1]
				break
		if(first)
			if(CD.O.layer != first[BFX_ZL])
				CD.O.layer = first[BFX_ZL]
				CD.C.layer = first[BFX_ZL]
			if(CD.C.icon_state != first[BFX_ST])
				var/ic = RLFamIcon(first[BFX_FAM], CD.light)
				if(CD.C.icon != ic) CD.C.icon = ic
		var/started = 0
		var/list/held = CD.lastq.Copy()
		if(first && (abs(first[BFX_X] - (CD.bx + CD.B / 2)) > 48 || abs(first[BFX_Y] - (CD.by + CD.B / 2)) > 48))
			if(RLCarPlace(CD, first[BFX_X], first[BFX_Y])) started = 1
		var/skip1 = isnull(want[1])
		var/st = started
		if(started)
			animate(CD.C, transform = BeamFXXform(CD.last, CD.C.fx_bx, CD.C.fx_by), time = 0, flags = ANIMATION_END_NOW)
			energyfx_anim_n++
		if(!skip1)
			RLCarChildStep(CD, want[1], st, 0, 0)
			st = 1
		if(!isnull(want[2])) RLCarChildStep(CD, want[2], st, skip1 ? 0.25 : 0, (st && skip1) ? 0.25 : 0)
		var/list/p1
		var/list/p2
		if(islist(want[1]))
			var/list/w1 = want[1]
			p1 = RLCarPos(CD, w1[1], w1[2])
		if(islist(want[2]))
			var/list/w2 = want[2]
			p2 = RLCarPos(CD, w2[1], w2[2])
		var/cx0 = CD.bx + CD.B / 2
		var/cy0 = CD.by + CD.B / 2
		var/list/xe = list()
		if(started && CD.xm)
			for(var/list/xm in CD.xm)
				xe += xm[3] - cx0
				xe += xm[4] - cy0
		var/list/q1 = p1 ? p1 : held
		var/list/r1 = RLCarRel(q1, cx0, cy0)
		var/list/rh = RLCarRel(held, cx0, cy0)
		var/list/r2 = isnull(want[2]) ? null : RLCarRel(p2 ? p2 : q1, cx0, cy0)
		for(var/fidx = 1 to CD.nc * 2)
			var/list/fst = list()
			var/dl = 0
			if(!skip1) fst += list(r1[fidx * 2 - 1], r1[fidx * 2])
			if(r2)
				if(skip1)
					if(started) fst += list(rh[fidx * 2 - 1], rh[fidx * 2])
					else dl = 0.25
				fst += list(r2[fidx * 2 - 1], r2[fidx * 2])
			if(fst.len) RLFiltAnim(CD.O, fidx, fst, dl, started)
		for(var/xi = 1 to xe.len / 2)
			RLFiltAnim(CD.O, CD.nc * 2 + xi, list(xe[xi * 2 - 1], xe[xi * 2]), 0, 1)
		if(p2) CD.lastq = p2
		else if(p1) CD.lastq = p1
		CD.dv = v2
		if(!s1 && !s2 && !CD.shown)
			CD.idle++
			if(CD.idle >= 3)
				RLCarFree(CD)
				rl_cars -= key
		else
			CD.idle = 0

/datum/beamfx/proc/RLMovFree(datum/efx92_mov/MV)
	for(var/ms in MV.kids)
		EnergyFXFree(MV.kids[ms])
	MV.kids = list()
	if(MV.M)
		MV.M.icon = null
		MV.M.icon_state = null
		EnergyFXFree(MV.M)
		MV.M = null

/datum/beamfx/proc/RLMovXform(datum/efx92_mov/MV, list/wt)
	var/a = wt[3]
	var/ca = cos(a)
	var/sa = sin(a)
	return matrix(ca, -sa, wt[1] - MV.M.fx_bx, sa, ca, wt[2] - MV.M.fx_by)

/datum/beamfx/proc/RLMovKid(datum/efx92_mov/MV, m, list/rep)
	var/list/stamps = rl.A["stamps"]
	var/list/pr = stamps[BeamFXMod(m, rl.np) + 1]
	var/list/stt = rl.S[pr[MV.light + 1] + 1]
	var/file = stt[1] + 1
	var/list/fam = BEAMFX_FAM[rl.fams[file]]
	var/lt = MV.light
	var/obj/energyfx/K = EnergyFXGet(lt ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, src)
	if(!K) return null
	K.icon = RLFamIcon(rl.fams[file], lt)
	K.fx_w = fam[2]
	K.fx_h = fam[3]
	K.icon_state = stt[2]
	K.layer = lt ? 0 : 4 + (m + 500) * 0.00001 + RLZo()
	K.loc = null
	var/sx = rep[RL92_SX]
	var/sy = rep[RL92_SY]
	var/B = MV.M.fx_w
	K.transform = matrix(sx, 0, S * (m - MV.g * rl.np) + sx * stt[3] + (B / 2 - K.fx_w / 2), 0, sy, sy * stt[4] + (B / 2 - K.fx_h / 2))
	K.color = EFX92_IDENTITY
	K.filters = RLObjFilter(lt)
	if(lt) K.blend_mode = BLEND_ADD
	K.alpha = 255
	MV.M.vis_contents += K
	K.fx_car = MV.M
	return K

/datum/beamfx/proc/RLMovNew(key, kind, g, list/wt)
	var/datum/efx92_mov/MV = new
	MV.key = key
	MV.light = kind
	MV.g = g
	var/obj/energyfx/M = EnergyFXGet(kind ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, src)
	if(!M) return null
	M.icon = rl_carF
	M.icon_state = "b"
	M.fx_w = rl_carB
	M.fx_h = rl_carB
	M.layer = kind ? 0 : 4 + (g * rl.np + 500) * 0.00001 + RLZo()
	MV.M = M
	if(!EnergyFXPlace(M, wt[1] + cos(wt[3]) * S * (rl.np - 1) / 2, wt[2] + sin(wt[3]) * S * (rl.np - 1) / 2, z))
		RLMovFree(MV)
		return null
	M.transform = RLMovXform(MV, wt)
	M.color = EFX92_IDENTITY
	M.alpha = 255
	MV.lastT = wt
	return MV

/datum/beamfx/proc/RLMovStep(datum/efx92_mov/MV, w, started, delay_first, hold_pre)
	var/obj/energyfx/M = MV.M
	if(started && hold_pre > 0) animate(transform = RLMovXform(MV, MV.lastT), time = hold_pre)
	var/matrix/X
	if(w == "hide")
		X = matrix(1, 0, 100000, 0, 1, 100000)
		MV.shown = 0
	else
		X = RLMovXform(MV, w)
		MV.lastT = w
		MV.shown = 1
	if(!started) animate(M, transform = X, time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN)
	else animate(transform = X, time = 0.25, easing = JUMP_EASING | EASE_IN)
	energyfx_anim_n++

/datum/beamfx/proc/RLMovRealize(f1, v1, v2)
	var/list/keys = list()
	for(var/key in rl_mplan) keys[key] = 1
	for(var/key in rl_movs) keys[key] = 1
	for(var/key in keys)
		var/list/P = rl_mplan[key]
		var/datum/efx92_mov/MV = rl_movs[key]
		var/list/want = list()
		for(var/si = 1 to 2)
			var/v = (si == 1) ? v1 : v2
			if(si == 2 && v2 == v1)
				want += list(null)
			else if(v < f1)
				want += list((MV && MV.dv == v) ? null : "hide")
			else
				var/list/wt = P ? P[2] : null
				var/e = wt ? wt[(v == f1) ? 1 : 2] : null
				want += list(e ? e : "hide")
		var/list/first
		for(var/w in want)
			if(islist(w))
				first = w
				break
		if(!MV)
			if(!first) continue
			MV = RLMovNew(key, P[3], P[4], first)
			if(!MV) continue
			rl_movs[key] = MV
		var/list/rep = first ? first[6] : null
		var/list/kl = P ? P[1] : list()
		var/list/keep = list()
		for(var/m in kl)
			keep["[m]"] = 1
		for(var/ms in MV.kids.Copy())
			if(!keep[ms])
				EnergyFXFree(MV.kids[ms])
				MV.kids -= ms
		if(rep)
			for(var/m in kl)
				if(!MV.kids["[m]"])
					var/obj/energyfx/K = RLMovKid(MV, m, rep)
					if(K) MV.kids["[m]"] = K
		for(var/si = 1 to 2)
			if(want[si] == "hide" && !MV.shown) want[si] = null
		var/started = 0
		if(first)
			var/a = first[3]
			var/mx = first[1] + cos(a) * S * (rl.np - 1) / 2
			var/my = first[2] + sin(a) * S * (rl.np - 1) / 2
			if(abs(mx - MV.M.fx_bx) > 48 || abs(my - MV.M.fx_by) > 48)
				if(EnergyFXPlace(MV.M, mx, my, z))
					animate(MV.M, transform = RLMovXform(MV, MV.lastT), time = 0, flags = ANIMATION_END_NOW)
					energyfx_anim_n++
					started = 1
		var/skip1 = isnull(want[1])
		if(!skip1)
			RLMovStep(MV, want[1], started, 0, 0)
			started = 1
		if(!isnull(want[2])) RLMovStep(MV, want[2], started, skip1 ? 0.25 : 0, (started && skip1) ? 0.25 : 0)
		MV.dv = v2
		if(!P && !MV.shown)
			MV.idle++
			if(MV.idle >= 3)
				RLMovFree(MV)
				rl_movs -= key
		else
			MV.idle = 0

/datum/beamfx/proc/RLLogPlan(f1, v1, v2)
	return

/datum/beamfx/Step()
	..()
	if(!rl || !rl_cf) return
	var/f1 = 2 * k
	var/list/hl = Holds()
	var/v1 = Q(f1, hl)
	var/v2 = Q(f1 + 1, hl)
	RLStreamPlan(f1, v1, v2)
	if(logging) RLLogPlan(f1, v1, v2)
	RLCarRealize(f1, v1, v2)
	RLLcRealize(f1, v1, v2)
	RLMovRealize(f1, v1, v2)

/datum/beamfx/proc/RLBallPt(a, r0)
	var/rel = a - ang
	var/along = cos(rel) * r0 * rl_st
	var/lat = sin(rel) * r0
	var/cd = mz + rl.P["bloom_x"] * rl_st
	return list(WX(cd + along, lat), WY(cd + along, lat))

/datum/beamfx/proc/RLSpawnRootBolts(now, qn)
	var/list/RB = rl.P["root_bolts"]
	if(!RB || !isnull(release_t) || isnull(t0)) return
	var/dl = RB["delay"]
	var/nd = round(dl / BEAMFX_FR, 1)
	if(abs(dl / BEAMFX_FR - nd) < 0.001 && round((now - t0) / BEAMFX_FR, 1) == nd)
		var/f0 = round(t0 / BEAMFX_FR, 1)
		if(f0 >= 0 && f0 < length(EFX92_RBTIE) && copytext(EFX92_RBTIE, f0 + 1, f0 + 2) == "1") return
	else if(now < t0 + dl) return
	var/list/A = rl.A["rbolts"]
	var/alive = 0
	for(var/list/b in rl_rbolts)
		if(now < b[1] + b[4] * BEAMFX_TICK - 0.000001) alive++
	for(var/i = 1 to max(0, RB["alive"] - alive))
		var/kind = (rng4.R() < RB["long_p"]) ? "beam" : "short"
		var/list/AK = A[kind]
		var/v = rng4.RandRange(AK.len)
		var/list/V = AK[v + 1]
		var/list/vf = V["frames"]
		var/side = (rng4.R() < 0.5) ? 1 : -1
		var/on = "ball"
		var/x
		var/y
		var/a
		var/sc
		if(RB["hug"])
			sc = rng4.U(0.85, 1.15)
			var/L = V["L"] * sc
			var/list/tl = RB["tilt"]
			var/tilt = rng4.U(tl[1], tl[2])
			on = "edge"
			var/x0
			var/y0
			if(rng4.R() < RB["ball_p"])
				on = "ball"
				var/list/sp = RB["spread"]
				var/aa = ang + side * rng4.U(sp[1], sp[2])
				var/list/rr = RB["root_r"]
				var/r0 = rl.P["bloom_R"] * rng4.U(rr[1], rr[2])
				var/list/bp = RLBallPt(aa, r0)
				x0 = bp[1]
				y0 = bp[2]
				var/turn = (rng4.R() < 0.5) ? 1 : -1
				a = aa + turn * (90 - tilt)
			else
				var/list/al = RB["along"]
				var/dd = mz + (rl.P["bloom_x"] + rl.P["bloom_R"] * rng4.U(al[1], al[2])) * rl_st
				var/list/lt = RB["lat"]
				var/lat = side * rl.P["rp"] * rng4.U(lt[1], lt[2])
				x0 = WX(dd, lat)
				y0 = WY(dd, lat)
				a = ang + side * tilt
			x = x0 + cos(a) * L * 0.5
			y = y0 + sin(a) * L * 0.5
		else
			var/list/sp2 = RB["spread"]
			a = ang + side * rng4.U(sp2[1], sp2[2])
			sc = rng4.U(0.85, 1.15)
			var/L2 = V["L"] * sc
			var/list/rr2 = RB["root_r"]
			var/r02 = rl.P["bloom_R"] * rng4.U(rr2[1], rr2[2])
			var/list/bp2 = RLBallPt(a, r02 + L2 * 0.5)
			x = bp2[1]
			y = bp2[2]
		var/sy = (rng4.R() < 0.5) ? 1 : -1
		rl_uid++
		rl_rbolts[++rl_rbolts.len] = list(now, kind, v, vf.len, x, y, a, sc, sy, on, rl_uid)

/datum/beamfx/proc/RLRootBoltSprites(list/out, t, fi)
	var/list/A = rl.A["rbolts"]
	var/list/RB = rl.P["root_bolts"]
	var/ral = 1
	if(RB["rel_fade"] && !isnull(release_t) && t >= release_t)
		var/q = (t - release_t) / RB["rel_fade"]
		if(q >= 1)
			rl_rbolts = list()
			return
		ral = (1 - q) ** 1.2
	var/list/keep = list()
	for(var/list/b in rl_rbolts)
		var/bf = RLAge(t, b[1])
		if(bf >= b[4]) continue
		keep[++keep.len] = b
		if(bf < 0 || !rl_draw) continue
		var/list/AK = A[b[2]]
		var/list/V = AK[b[3] + 1]
		var/list/vf = V["frames"]
		RLPair(out, vf[bf + 1], b[5], b[6], b[7], b[8], b[9] * b[8], ral, 5.6, 0, null, null, (b[10] == "edge") ? "rbolt_e" : "rbolt", "rb[b[11]]")
	rl_rbolts = keep

/datum/beamfx/proc/RLClashSetup()
	var/list/CL = rl.CL
	if(!CL) return
	var/datum/beamfx/P2 = partner
	var/list/C2 = (P2 && P2.rl) ? P2.rl.CL : null
	var/grind = (CL["style"] != "ball") || (C2 && C2["style"] != "ball")
	rl_clash_ev = null
	rl_cbolts = list()
	rl_clash_split = 0
	if(CL["sparks"]) rl_gspark = CL["sparks"]
	if(grind)
		rl_cart = list("balls" = null, "ring" = null, "bolts" = CL["bolts"], "R" = CL["ra"])
		return
	var/ra = CL["ra"]
	var/Rs = 1.6 * (C2 ? max(ra, C2["ra"]) : ra)
	var/list/RT = CL["R"]
	var/list/ent
	var/bd = 1000000
	for(var/rk in RT)
		var/list/e = RT[rk]
		var/dv = abs(e["R"] - Rs)
		if(dv < bd)
			bd = dv
			ent = e
	if(!ent)
		rl_cart = list("balls" = null, "ring" = null, "bolts" = CL["bolts"], "R" = ra)
		return
	rl_cart = list("balls" = ent["balls"], "ring" = ent["ring"], "bolts" = CL["bolts"], "R" = ent["R"])
	if(C2)
		var/rl_ = clash_lead ? ra : C2["ra"]
		var/ro_ = clash_lead ? C2["ra"] : ra
		var/sa = rl_ / (rl_ + ro_)
		rl_clash_split = clash_lead ? Rs * (2 * sa - 1) : Rs * (1 - 2 * sa)

/datum/beamfx/proc/RLClashTick(now, qn)
	if(isnull(t_hit) || now + BEAMFX_TICK <= t_hit || !Struggling(qn, 0)) return
	var/c = Contact(now, qn, 0)
	if(isnull(c)) return
	if(clash_lead)
		if(!rl_clash_ev) rl_clash_ev = list("pulses" = list(), "rings" = list(), "next_p" = now + 0.12, "next_r" = now + 0.05)
		var/list/E = rl_clash_ev
		var/list/pl = E["pulses"]
		while(now + BEAMFX_TICK > E["next_p"])
			pl += E["next_p"]
			E["next_p"] = E["next_p"] + rng7.U(0.18, 0.35)
		var/list/rg = E["rings"]
		while(rl_cart["ring"] && now + BEAMFX_TICK > E["next_r"])
			var/wx = WX(c)
			var/wy = WY(c)
			rg[++rg.len] = list(E["next_r"], wx, wy, (rng7.R() < 0.5) ? 1 : -1)
			E["next_r"] = E["next_r"] + rng7.U(0.3, 0.5)
	var/list/A = rl_cart["bolts"]
	var/alive = 0
	for(var/list/b in rl_cbolts)
		if(now < b[1] + b[4] * BEAMFX_TICK - 0.000001) alive++
	var/R = rl_cart["R"]
	var/cx = WX(c)
	var/cy = WY(c)
	for(var/i = 1 to max(0, 2 - alive))
		var/kind = (rng7.R() < 0.6) ? "beam" : "short"
		var/list/AK = A[kind]
		var/v = rng7.RandRange(AK.len)
		var/list/V = AK[v + 1]
		var/list/vf = V["frames"]
		var/a = ang + 180 + rng7.U(-80, 80)
		var/sc = rng7.U(0.85, 1.15)
		var/L = V["L"] * sc
		var/r0 = R * rng7.U(0.8, 0.95)
		var/x = cx + cos(a) * (r0 + L * 0.5)
		var/y = cy + sin(a) * (r0 + L * 0.5)
		var/sy = (rng7.R() < 0.5) ? 1 : -1
		rl_uid++
		rl_cbolts[++rl_cbolts.len] = list(now, kind, v, vf.len, x, y, a, sc, sy, rl_uid)

/datum/beamfx/proc/RLClashSprites(list/out, t, fi)
	var/datum/beamfx/lead = clash_lead ? src : partner
	var/list/E = lead ? lead.rl_clash_ev : null
	if(!E) return
	var/c = Contact(t, fi, 0)
	if(isnull(c)) return
	var/sp = rl_clash_split
	var/sz = 0
	for(var/tp in E["pulses"])
		var/dt = t - tp
		if(dt >= 0 && dt < BEAMFX_TICK * 1.5) sz = 2
		else if(dt >= BEAMFX_TICK * 1.5 && dt < BEAMFX_TICK * 3.5) sz = max(sz, 1)
	var/list/balls = rl_cart["balls"]
	if(!balls)
		RLClashBolts(out, t, fi)
		return
	if(rl_draw)
		var/list/Bl = balls[sz + 1]
		var/list/bfr = Bl["frames"]
		var/jm = BeamFXMod(RLDraw(fi), bfr.len)
		var/list/pair = bfr[jm + 1]
		var/sf = 10 * max(1, rl_cart["R"] / 34)
		var/lay = clash_lead ? 5.05 : 5.06
		var/x = WX(c)
		var/y = WY(c)
		var/pd = c + sp + sf * 0.5 + EFX92_JOIN_OV
		var/qd = c + sp
		RLRec(out, pair[1], x, y, ang, 1, 1, 1, lay, 0, 0, list(list(WX(pd), WY(pd), -ax, -ay, sf)), "cball", "cbp")
		RLRec(out, pair[2], x, y, ang, 1, 1, 1, 0, 0, 1, list(list(WX(qd), WY(qd), -ax, -ay, sf)), "cball", "cbl")
		var/list/RF = rl_cart["ring"]
		for(var/list/rr in E["rings"])
			var/j = RLAge(t, rr[1])
			if(j < 0 || j >= RF.len) continue
			var/list/rp = RF[j + 1]
			var/rpx = rr[2] + ax * (sp + 4 + EFX92_JOIN_OV)
			var/rpy = rr[3] + ay * (sp + 4 + EFX92_JOIN_OV)
			var/rqx = rr[2] + ax * sp
			var/rqy = rr[3] + ay * sp
			RLRec(out, rp[1], rr[2], rr[3], ang, 1, rr[4], 1, clash_lead ? 5.3 : 5.31, 0, 0, list(list(rpx, rpy, -ax, -ay, 8)), "cring", "cr[rr[1]]p")
			RLRec(out, rp[2], rr[2], rr[3], ang, 1, rr[4], 1, 0, 0, 1, list(list(rqx, rqy, -ax, -ay, 8)), "cring", "cr[rr[1]]l")
	RLClashBolts(out, t, fi)

/datum/beamfx/proc/RLClashBolts(list/out, t, fi)
	var/list/A = rl_cart["bolts"]
	var/list/keep = list()
	for(var/list/b in rl_cbolts)
		var/bf = RLAge(t, b[1])
		if(bf >= b[4]) continue
		keep[++keep.len] = b
		if(bf < 0 || !rl_draw) continue
		var/list/AK = A[b[2]]
		var/list/V = AK[b[3] + 1]
		var/list/vf = V["frames"]
		RLPair(out, vf[bf + 1], b[5], b[6], b[7], b[8], b[9] * b[8], 1, 5.6, 0, null, null, "cbolt", "cbo[b[10]]")
	rl_cbolts = keep

/datum/efx92_lc
	var/key
	var/obj/energyfx/O
	var/light = 0
	var/car
	var/fb = 0
	var/nc = 0
	var/list/last
	var/list/lastq
	var/shown = 0
	var/idle = 0
	var/dv = -1

/datum/beamfx/var/list/rl_lcf
/datum/beamfx/var/list/rl_lcs = list()
/datum/beamfx/var/rl_bm = 0
var/efx92_m2_lmiss = 0

proc/EFX92BendCls(tag)
	switch(tag)
		if("stamp", "tail", "bloom", "surge") return EFXB_FLOW
		if("head", "erode", "cap") return EFXB_HEAD
	return EFXB_RIGID

/datum/beamfx/proc/RLBendMode(fi)
	if(fgeo && ForkSplit(fi)) return 2
	if(BendOn()) return 1
	return 0

/datum/beamfx/proc/RLGeoS(d)
	return (rl_bm == 2) ? fgeo.SofD(d) : bgeo.SofD(d)

/datum/beamfx/proc/RLGeoD(S)
	if(rl_bm == 1) return bgeo.DofS(S)
	var/e = S - fgeo.SJ
	if(e <= 0) return S
	if(e > fgeo.sbe) return fgeo.SJ + fgeo.er + (e - fgeo.sbe) / fgeo.k1
	var/list/sb = fgeo.sb
	for(var/i = 1 to sb.len - 1)
		if(e <= sb[i + 1])
			var/w = (sb[i + 1] > sb[i]) ? (e - sb[i]) / (sb[i + 1] - sb[i]) : 0
			return fgeo.SJ + fgeo.er * (i - 1 + w) / 128
	return fgeo.SJ + fgeo.er

/datum/beamfx/proc/RLFlowCuts(list/cuts, hdc, hoff, list/extra)
	var/list/o = list()
	if(cuts)
		for(var/list/c in cuts)
			var/cd = (c[1] - Ox) * ax + (c[2] - Oy) * ay
			if(!isnull(hdc) && abs(cd - hdc) < EFX92_HEADCUT_REACH && (c[3] * ax + c[4] * ay) < 0)
				var/d2 = RLGeoD(cd - hoff)
				o[++o.len] = list(WX(d2), WY(d2), c[3], c[4], c[5])
			else
				o[++o.len] = c
	if(extra) o[++o.len] = extra
	return o

/datum/beamfx/proc/RLRunCuts(list/cuts, datum/efx_piece/P, head, dc, Sc)
	var/list/o = list()
	if(!cuts) return o
	var/rho = head ? 1 : P.l / bgeo.D
	for(var/list/c in cuts)
		var/cd = (c[1] - Ox) * ax + (c[2] - Oy) * ay
		var/sg = ((c[3] * ax + c[4] * ay) > 0) ? 1 : -1
		var/al = (head ? (Sc + cd - dc) : (P.S0 + (cd - P.u0 * bgeo.D) * rho)) - P.S0
		o[++o.len] = list(P.x0 + P.ex * al, P.y0 + P.ey * al, P.ex * sg, P.ey * sg, c[5] * rho)
	return o

/datum/beamfx/proc/RLLocalCuts(list/cuts, fd, a, sx)
	var/list/o = list()
	if(!cuts) return o
	var/k = sx * cos(a - ang)
	if(abs(k) < 0.000001) return o
	for(var/list/c in cuts)
		var/cd = (c[1] - Ox) * ax + (c[2] - Oy) * ay
		var/sg = ((c[3] * ax + c[4] * ay) > 0) ? 1 : -1
		o[++o.len] = list((cd - fd) / k, 0, (k > 0) ? sg : -sg, 0, c[5] / abs(k))
	return o

/datum/beamfx/proc/RLShiftCuts(list/cuts, sh)
	var/list/o = list()
	if(!cuts) return o
	for(var/list/c in cuts)
		o[++o.len] = list(c[1] + ax * sh, c[2] + ay * sh, c[3], c[4], c[5])
	return o

/datum/beamfx/proc/RLBranchCuts(list/cuts, sig, head, dc, Sc)
	var/list/o = list()
	if(!cuts) return o
	var/ex = ax * cos(45) - ay * sin(45) * sig
	var/ey = ax * sin(45) * sig + ay * cos(45)
	var/SJ = fgeo.SJ
	for(var/list/c in cuts)
		var/cd = (c[1] - Ox) * ax + (c[2] - Oy) * ay
		var/sg = ((c[3] * ax + c[4] * ay) > 0) ? 1 : -1
		var/Sl = head ? (Sc + cd - dc) : (SJ + fgeo.sbe + fgeo.k1 * (cd - SJ - fgeo.er))
		var/list/B = fgeo.LineXY(src, Sl, 0, sig)
		o[++o.len] = list(B[1], B[2], ex * sg, ey * sg, head ? c[5] : c[5] * fgeo.k1)
	return o

/datum/beamfx/proc/RLMaskA(datum/efx_corner/C)
	var/list/R = C.rec
	return list(list(R[1], "A", C.Vx + R[4], C.Vy + R[5], "[C.uid]A"))

/datum/beamfx/proc/RLMaskB(datum/efx_corner/C)
	var/list/R = C.rec
	var/list/o = list(list(R[1], "B", C.Vx + R[6], C.Vy + R[7], "[C.uid]B"))
	if(C.nclose && C.nxt && C.nxt.rec)
		var/list/R2 = C.nxt.rec
		o[++o.len] = list(R2[1], "A", C.nxt.Vx + R2[4], C.nxt.Vy + R2[5], "[C.nxt.uid]A")
	return o

/datum/beamfx/proc/RLForkMask(piece)
	var/list/R = fgeo.rec
	var/bi = (piece == "P") ? 3 : ((piece == "B+") ? 5 : 7)
	return list(list(R[1], piece, fgeo.Vx + R[bi], fgeo.Vy + R[bi + 1], "fk[piece]"))

/datum/beamfx/proc/RLPut(j, key, list/r, x, y, a, sx, sy, zl, car, list/scuts, list/lcuts, list/extra)
	var/list/stt = rl.S[r[RL92_ST] + 1]
	var/file = stt[1] + 1
	var/ca = cos(a)
	var/sa = sin(a)
	var/fcx = x + ca * sx * stt[3] - sa * sy * stt[4]
	var/fcy = y + sa * sx * stt[3] + ca * sy * stt[4]
	var/fam = rl.fams[file]
	var/kind = r[RL92_KIND]
	var/k2 = "[key]|f[file]"
	if(lcuts && lcuts.len)
		var/list/lf = rl_lcf[j]
		lf["[k2]|[EFX92CutSig(lcuts)]"] = list(list(fam, stt[2], kind, fcx, fcy, a, sx, sy, 0, r[RL92_AL], r[RL92_LY], r[RL92_OR], r[RL92_TAG], 1, null, zl, 0), lcuts, car)
		return
	if((scuts && scuts.len) || extra)
		if(!scuts) scuts = list()
		var/list/cf = rl_cf[j]
		var/xs = ""
		if(extra)
			for(var/list/xm in extra) xs += "[xm[5]],"
		var/list/sp = list(fam, stt[2], kind, fcx, fcy, a, sx, sy, 0, r[RL92_AL], r[RL92_LY], r[RL92_OR], r[RL92_TAG], 1, null, zl, 0)
		cf["[k2]|[EFX92CutSig(scuts)]|[xs]"] = extra ? list(sp, scuts, extra) : list(sp, scuts)
		return
	Emit(j, k2, fam, stt[2], kind, fcx, fcy, a, sx, sy, 0, r[RL92_AL], r[RL92_LY], r[RL92_OR], r[RL92_TAG], 1, null, zl, 0)
	if(car)
		var/list/F = frame_specs[j]
		var/list/s2 = F[k2]
		if(s2)
			s2.len = BFX_CAR
			s2[BFX_CAR] = car

/datum/beamfx/proc/RLRoute(j, list/r, key, cls, zl, list/cuts)
	var/list/stt = rl.S[r[RL92_ST] + 1]
	var/file = stt[1] + 1
	var/a = r[RL92_ANG]
	var/sx = r[RL92_SX]
	var/sy = r[RL92_SY]
	var/rx = r[RL92_X] - Ox
	var/ry = r[RL92_Y] - Oy
	var/dc = rx * ax + ry * ay
	var/lat = rx * nx + ry * ny
	if(rl_bm == 2)
		RLForkRoute(j, r, key, cls, zl, cuts, stt, file, dc, lat)
		return
	if(cls == EFXB_RIGID)
		var/list/E = bgeo.Eval(bgeo.SofD(dc))
		RLPut(j, key, r, E[1] - E[4] * lat, E[2] + E[3] * lat, a + arctan(E[3], E[4]) - ang, sx, sy, zl)
		return
	var/head = (cls == EFXB_HEAD)
	var/Sc = head ? bgeo.SofD(dc) : 0
	var/cr = cos(a - ang)
	var/sr = sin(a - ang)
	var/fd = dc + cr * sx * stt[3] - sr * sy * stt[4]
	var/flat = lat + sr * sx * stt[3] + cr * sy * stt[4]
	var/hw = rl.FW[file] / 2 * abs(sx)
	var/hh = rl.FH[file] / 2 * abs(sy)
	var/exa = abs(cr) * hw + abs(sr) * hh + 1.5
	var/exl = abs(flat) + abs(sr) * hw + abs(cr) * hh
	var/cen = head ? Sc + (fd - dc) : fd
	var/lo = cen - exa
	var/hi = cen + exa
	var/list/touch = list()
	for(var/datum/efx_corner/C in bgeo.corners)
		if(!C.rec) continue
		var/cA = head ? C.SA : C.dA
		var/cB = head ? C.SB : C.dB
		if(cB >= lo - 0.5 && cA <= hi + 0.5) touch += C
	if(!touch.len)
		var/datum/efx_piece/P = bgeo.LinAt(cen, head)
		var/list/R = RunXY(P, dc, lat, head, Sc)
		RLPut(j, key, r, R[1], R[2], a + R[3], sx * R[4], sy, zl, null, RLRunCuts(cuts, P, head, dc, Sc))
		return
	var/band = r[RL92_KIND] ? "L" : "p[round(zl * 10)]"
	var/bandp = "[band][head ? "H" : "F"]"
	var/datum/efx_corner/C1 = touch[1]
	if(lo < (head ? C1.SA : C1.dA))
		var/list/RA = RunXY(C1.pa, dc, lat, head, Sc)
		var/list/sca = RLRunCuts(cuts, C1.pa, head, dc, Sc)
		if(sca.len) RLPut(j, "[key]@[C1.uid]A", r, RA[1], RA[2], a + RA[3], sx * RA[4], sy, zl, null, sca, null, RLMaskA(C1))
		else RLPut(j, "[key]@[C1.uid]A", r, RA[1], RA[2], a + RA[3], sx * RA[4], sy, zl, CarBend(C1, "A", band, zl, cls))
	var/list/lc = RLLocalCuts(cuts, fd, a, sx)
	for(var/datum/efx_corner/C in touch)
		if(!C.miter)
			var/al = head ? (Sc - C.Smid) : C.kb * (dc - C.dmid)
			var/cxp = C.Mx + C.ebx * al - C.eby * lat
			var/cyp = C.My + C.eby * al + C.ebx * lat
			var/cang = a - ang + arctan(C.ebx, C.eby)
			var/csx = head ? sx : sx * C.kb
			RLPut(j, "[key]@[C.uid]N", r, cxp, cyp, cang, csx, sy, zl, CarBend(C, "CN", bandp, zl, cls), null, lc)
			if(exl > ENERGYFX_BEND_NEAR_L - 2)
				RLPut(j, "[key]@[C.uid]F", r, cxp, cyp, cang, csx, sy, zl, CarBend(C, "CF", bandp, zl, cls), null, lc)
		if(hi > (head ? C.SB : C.dB) && C.pb)
			var/list/RB = RunXY(C.pb, dc, lat, head, Sc)
			var/list/scb = RLRunCuts(cuts, C.pb, head, dc, Sc)
			if(scb.len) RLPut(j, "[key]@[C.uid]B", r, RB[1], RB[2], a + RB[3], sx * RB[4], sy, zl, null, scb, null, RLMaskB(C))
			else RLPut(j, "[key]@[C.uid]B", r, RB[1], RB[2], a + RB[3], sx * RB[4], sy, zl, CarBend(C, "B", band, zl, cls))

/datum/beamfx/proc/RLForkRoute(j, list/r, key, cls, zl, list/cuts, list/stt, file, dc, lat)
	var/a = r[RL92_ANG]
	var/sx = r[RL92_SX]
	var/sy = r[RL92_SY]
	var/SJ = fgeo.SJ
	var/cr = cos(a - ang)
	var/sr = sin(a - ang)
	var/hw = rl.FW[file] / 2 * abs(sx)
	var/hh = rl.FH[file] / 2 * abs(sy)
	if(cls == EFXB_RIGID)
		var/S = fgeo.SofD(dc)
		if(S <= SJ)
			RLPut(j, key, r, r[RL92_X], r[RL92_Y], a, sx, sy, zl)
			return
		var/rad = sqrt(hw * hw + hh * hh) + 1
		var/clx = Ox + nx * lat0
		var/cly = Oy + ny * lat0
		for(var/sig in list(1, -1))
			var/list/P = fgeo.BranchXY(src, S, lat, sig)
			var/a2 = a + arctan(P[3], P[4]) - ang
			var/ca = cos(a2)
			var/sa = sin(a2)
			var/fcx = P[1] + ca * sx * stt[3] - sa * sy * stt[4]
			var/fcy = P[2] + sa * sx * stt[3] + ca * sy * stt[4]
			var/ls = ((fcx - clx) * nx + (fcy - cly) * ny) * sig
			if(ls < -rad) continue
			var/k2 = "[key]@[(sig > 0) ? "+" : "-"]"
			if(ls > rad) RLPut(j, k2, r, P[1], P[2], a2, sx, sy, zl)
			else RLPut(j, k2, r, P[1], P[2], a2, sx, sy, zl, null, list(list(clx, cly, nx * sig, ny * sig, EFX92_FORK_CLIP)))
		return
	var/head = (cls == EFXB_HEAD)
	var/fd = dc + cr * sx * stt[3] - sr * sy * stt[4]
	var/exa = abs(cr) * hw + abs(sr) * hh + 1.5
	var/Sc = head ? fgeo.SofD(dc) : dc
	var/cen = head ? Sc + (fd - dc) : fd
	var/lo = cen - exa
	var/hi = cen + exa
	if(hi < SJ - ENERGYFX_FORK_BACK || !fgeo.rec)
		RLPut(j, key, r, r[RL92_X], r[RL92_Y], a, sx, sy, zl, null, cuts)
		return
	var/band = r[RL92_KIND] ? "L" : "p[round(zl * 10)]"
	var/cb = head ? "H" : "F"
	var/px = r[RL92_X] + ax * (Sc - dc)
	var/py = r[RL92_Y] + ay * (Sc - dc)
	if(lo < SJ + ENERGYFX_FORK_J_AHEAD)
		var/list/pc = RLShiftCuts(cuts, Sc - dc)
		if(pc.len) RLPut(j, "[key]@P", r, px, py, a, sx, sy, zl, null, pc, null, RLForkMask("P"))
		else RLPut(j, "[key]@P", r, px, py, a, sx, sy, zl, CarFork("P", band, zl, cls))
	var/injz = (hi >= SJ - ENERGYFX_FORK_J_BACK && lo <= SJ + ENERGYFX_FORK_J_AHEAD)
	var/list/lc = RLLocalCuts(cuts, fd, a, sx)
	for(var/sig in list(1, -1))
		var/sgn = (sig > 0) ? "+" : "-"
		var/Sl = head ? Sc : SJ + fgeo.sbe + fgeo.k1 * (dc - SJ - fgeo.er)
		var/list/B = fgeo.LineXY(src, Sl, lat, sig)
		var/ba = a + 45 * sig
		var/bsx = head ? sx : sx * fgeo.k1
		if(injz)
			RLPut(j, "[key]@JP[sgn]", r, px, py, a, sx, sy, zl, CarFork("JP[sgn]", "[band][cb]", zl, cls), null, lc)
			RLPut(j, "[key]@JB[sgn]", r, B[1], B[2], ba, bsx, sy, zl, CarFork("JB[sgn]", "[band][cb]", zl, cls), null, lc)
		if(hi > SJ)
			var/list/bc = RLBranchCuts(cuts, sig, head, dc, Sc)
			if(bc.len) RLPut(j, "[key]@B[sgn]", r, B[1], B[2], ba, bsx, sy, zl, null, bc, null, RLForkMask("B[sgn]"))
			else RLPut(j, "[key]@B[sgn]", r, B[1], B[2], ba, bsx, sy, zl, CarFork("B[sgn]", band, zl, cls))

/datum/beamfx/proc/RLBendSplit(j, list/r, zl, list/cuts)
	var/list/b = r[RL92_BALL]
	var/off = (b[1] + b[2]) * rl_st
	var/rx = r[RL92_X] - Ox
	var/ry = r[RL92_Y] - Oy
	var/dc = rx * ax + ry * ay
	var/lat = rx * nx + ry * ny
	var/list/E = bgeo.Eval(bgeo.SofD(dc) - off)
	var/ov = r[RL92_KIND] ? 0 : EFX92_JOIN_OV
	var/list/wc = cuts ? cuts.Copy() : list()
	wc[++wc.len] = list(WX(dc - off), WY(dc - off), -ax, -ay, 1)
	RLRoute(j, r, "[r[RL92_KEY]]w", EFXB_HEAD, zl, wc)
	var/tx = E[3]
	var/ty = E[4]
	var/px = E[1] + tx * off - ty * lat
	var/py = E[2] + ty * off + tx * lat
	var/a2 = r[RL92_ANG] + arctan(tx, ty) - ang
	var/sx = r[RL92_SX]
	var/z2 = zl ? zl + 0.0000005 : 0
	var/at = abs(tx)
	var/bt = abs(ty)
	if(at > 0.9999 || bt > 0.9999 || abs(at - bt) < 0.0001)
		RLPut(j, "[r[RL92_KEY]]r", r, px, py, a2, sx, r[RL92_SY], z2, null, list(list(E[1] - tx * ov, E[2] - ty * ov, tx, ty, 1)))
	else
		var/list/stt = rl.S[r[RL92_ST] + 1]
		RLPut(j, "[r[RL92_KEY]]r", r, px, py, a2, sx, r[RL92_SY], z2, null, null, list(list(-(off + ov) / sx - stt[3], 0, 1, 0, 1 / abs(sx))))

/datum/beamfx/proc/RLBendStamps(j, fi, hdc, hoff, list/fe)
	var/list/sf = rl_sf[j]
	if(!sf[1] && !sf[2]) return
	var/list/win = rl_sw[j]
	RLStampExtent()
	var/base = dstart + LatBase(FT(fi), fi)
	var/list/stamps = rl.A["stamps"]
	var/list/sreps = list(sf[1], sf[2])
	sf[1] = null
	sf[2] = null
	for(var/kind = 0 to 1)
		var/list/rep = sreps[kind + 1]
		if(!rep) continue
		var/list/cuts = RLFlowCuts(rep[RL92_CUTS], hdc, hoff, fe)
		var/list/cc = list()
		for(var/list/c in cuts)
			cc += (c[1] - Ox) * ax + (c[2] - Oy) * ay
			cc += ((c[3] * ax + c[4] * ay) > 0) ? 1 : -1
			cc += c[5] / 2 + 1
		var/e0 = rl_se0 * rep[RL92_SX]
		var/e1 = rl_se1 * rep[RL92_SX]
		for(var/si = 1 to stamp_m.len)
			if(stamp_tbf[si] > fi) continue
			var/m = stamp_m[si]
			var/dd = base + S * m
			if(win && (dd + S < win[1] || dd - S > win[2])) continue
			var/fin = 1
			var/fout = 0
			for(var/ci = 1 to cc.len step 3)
				var/cp = cc[ci]
				var/h = cc[ci + 2]
				if(cc[ci + 1] > 0)
					if(dd + e1 < cp - h) fout = 1
					if(dd + e0 <= cp + h) fin = 0
				else
					if(dd + e0 > cp + h) fout = 1
					if(dd + e1 >= cp - h) fin = 0
			if(fout) continue
			var/list/pr = stamps[BeamFXMod(m, rl.np) + 1]
			var/list/r = list(pr[kind + 1], WX(dd), WY(dd), rep[RL92_ANG], rep[RL92_SX], rep[RL92_SY], rep[RL92_AL], 4, m, kind, null, "stamp", null, "bs[kind]:[m]", null, 0)
			RLRoute(j, r, "bs[kind]:[m]", EFXB_FLOW, kind ? 0 : 4 + (m + 500) * 0.00001, fin ? null : cuts)

/datum/beamfx/proc/RLBendAll(j, fi, list/out, sfi)
	emit_raw = 1
	var/list/hrec
	for(var/list/r in out)
		if(r[RL92_TAG] == "head" && r[RL92_KIND] == 0 && r[RL92_BALL])
			hrec = r
			break
	var/hdc
	var/hoff
	var/list/fe
	var/list/fes
	if(hrec)
		hdc = (hrec[RL92_X] - Ox) * ax + (hrec[RL92_Y] - Oy) * ay
		hoff = hdc - RLGeoS(hdc)
		if(rl_bm == 1)
			var/list/hb = hrec[RL92_BALL]
			var/Sb = bgeo.SofD(hdc) - hb[1] * rl_st
			var/list/hcu = hrec[RL92_CUTS]
			var/de = bgeo.DofS((hcu && hcu.len) ? Sb - hb[2] * rl_st - EFX92_FLOW_GAP : Sb)
			fe = list(WX(de), WY(de), -ax, -ay, 1)
			fes = list(WX(de - EFX92_FLOW_FADE / 2), WY(de - EFX92_FLOW_FADE / 2), -ax, -ay, EFX92_FLOW_FADE)
	var/list/sf = rl_sf[j]
	var/pidx = 0
	for(var/list/r in out)
		var/si = r[RL92_ST]
		if(isnull(si) || si < 0) continue
		var/kind = r[RL92_KIND]
		var/tg = r[RL92_TAG]
		if(tg == "stamp")
			sf[kind + 1] = r
			continue
		var/zl = 0
		if(kind == 0)
			pidx++
			zl = r[RL92_LY] + pidx * 0.000001
		var/cls = EFX92BendCls(tg)
		var/list/cuts = r[RL92_CUTS]
		if(cls == EFXB_FLOW) cuts = RLFlowCuts(cuts, hdc, hoff, (tg == "surge") ? fes : fe)
		if(rl_bm == 1 && cls == EFXB_HEAD && r[RL92_BALL]) RLBendSplit(j, r, zl, cuts)
		else RLRoute(j, r, "[r[RL92_KEY]]", cls, zl, cuts)
	RLBendStamps(j, isnull(sfi) ? fi : sfi, hdc, hoff, fe)
	emit_raw = 0

/datum/beamfx/CarDesc(key, band, zl)
	var/datum/efx_car/CD = ..()
	if(rl && CD.plane == ENERGYFX_LIGHT_PLANE) CD.plane = ENERGYFX_SHARP_PLANE
	return CD

/datum/beamfx/proc/RLLcPos(list/lc)
	var/list/o = list()
	for(var/list/c in lc)
		var/list/pl = EFX92CutPlan(c, 0, 0)
		o += pl[2]
		o += pl[3]
		o += pl[5]
		o += pl[6]
	return o

/datum/beamfx/proc/RLLcNew(key, list/sp, list/lc, car)
	var/datum/efx92_lc/L = new
	L.key = key
	L.light = sp[BFX_LIGHT]
	L.car = car
	var/obj/energyfx/O = EnergyFXGet(L.light ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, src)
	if(!O) return null
	var/list/fam = BEAMFX_FAM[sp[BFX_FAM]]
	O.icon = RLFamIcon(sp[BFX_FAM], L.light)
	O.fx_w = fam[2]
	O.fx_h = fam[3]
	O.icon_state = sp[BFX_ST]
	O.layer = sp[BFX_ZL]
	if(car)
		var/datum/efx_car/CD = bcars ? bcars[car] : null
		var/obj/energyfx/carrier/CO = CD ? CarObj(CD) : null
		if(!CO)
			EnergyFXFree(O)
			return null
		O.loc = null
		CO.vis_contents += O
		O.fx_car = CO
		O.fx_bx = CD.bx + O.fx_w / 2
		O.fx_by = CD.by + O.fx_h / 2
	else if(!EnergyFXPlace(O, sp[BFX_X], sp[BFX_Y], z))
		EnergyFXFree(O)
		return null
	L.O = O
	O.transform = BeamFXXform(sp, O.fx_bx, O.fx_by)
	O.color = EFX92FoldA(ColorOf(sp), 0)
	O.alpha = 255
	if(L.light) O.blend_mode = BLEND_ADD
	var/list/fl0 = RLObjFilter(L.light)
	var/list/fl = fl0 ? fl0.Copy() : list()
	L.fb = fl.len
	L.nc = lc.len
	L.lastq = RLLcPos(lc)
	for(var/ci = 1 to L.nc)
		var/list/c = lc[ci]
		fl += filter(type = "alpha", icon = EFX92M2Icon(EFX92CutState(c)), x = L.lastq[ci * 4 - 3], y = L.lastq[ci * 4 - 2], flags = MASK_INVERSE)
		fl += filter(type = "alpha", icon = EFX92M2Icon("kxp"), x = L.lastq[ci * 4 - 1], y = L.lastq[ci * 4], flags = MASK_INVERSE)
	O.filters = fl
	L.last = sp
	return L

/datum/beamfx/proc/RLLcFree(datum/efx92_lc/L)
	if(!L.O) return
	L.O.filters = null
	EnergyFXFree(L.O)
	L.O = null

/datum/beamfx/proc/RLLcStep(datum/efx92_lc/L, w, started, delay_first, hold_pre)
	var/obj/energyfx/O = L.O
	if(started && hold_pre > 0) animate(transform = BeamFXXform(L.last, O.fx_bx, O.fx_by), time = hold_pre)
	if(w == "hide")
		if(!started) animate(O, color = EFX92FoldA(EFX92_IDENTITY, 0), time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN)
		else animate(color = EFX92FoldA(EFX92_IDENTITY, 0), time = 0.25, easing = JUMP_EASING | EASE_IN)
		L.shown = 0
	else
		var/list/wl = w
		var/list/sp = wl[1]
		if(!started) animate(O, transform = BeamFXXform(sp, O.fx_bx, O.fx_by), color = EFX92FoldA(ColorOf(sp), AlphaOf(sp)), icon_state = sp[BFX_ST], time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		else animate(transform = BeamFXXform(sp, O.fx_bx, O.fx_by), color = EFX92FoldA(ColorOf(sp), AlphaOf(sp)), icon_state = sp[BFX_ST], time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		L.last = sp
		L.shown = 1
	energyfx_anim_n++

/datum/beamfx/proc/RLLcRealize(f1, v1, v2)
	var/list/F1 = rl_lcf[1]
	var/list/F2 = rl_lcf[2]
	var/list/keys = list()
	for(var/key in F1) keys[key] = 1
	for(var/key in F2) keys[key] = 1
	for(var/key in rl_lcs) keys[key] = 1
	for(var/key in keys)
		var/list/s1 = F1[key]
		var/list/s2 = F2[key]
		var/datum/efx92_lc/L = rl_lcs[key]
		var/list/want = list()
		for(var/si = 1 to 2)
			var/v = (si == 1) ? v1 : v2
			if(si == 2 && v2 == v1)
				want += list(null)
			else if(v < f1)
				want += list((L && L.dv == v) ? null : "hide")
			else
				var/list/e = (v == f1) ? s1 : s2
				want += list(e ? e : "hide")
		if(!L)
			var/list/fs
			for(var/w in want)
				if(islist(w))
					fs = w
					break
			if(!fs) continue
			L = RLLcNew(key, fs[1], fs[2], fs[3])
			if(!L) continue
			rl_lcs[key] = L
		if(!L.O) continue
		for(var/si = 1 to 2)
			if(want[si] == "hide" && !L.shown) want[si] = null
		var/list/first
		for(var/w in want)
			if(islist(w))
				var/list/wl = w
				first = wl[1]
				break
		var/obj/energyfx/O = L.O
		if(first)
			if(O.layer != first[BFX_ZL]) O.layer = first[BFX_ZL]
			if(O.icon_state != first[BFX_ST])
				var/ic = RLFamIcon(first[BFX_FAM], L.light)
				if(O.icon != ic) O.icon = ic
		var/started = 0
		if(first && !L.car && (abs(first[BFX_X] - O.fx_bx) > 48 || abs(first[BFX_Y] - O.fx_by) > 48))
			if(EnergyFXPlace(O, first[BFX_X], first[BFX_Y], z)) started = 1
		var/skip1 = isnull(want[1])
		var/list/p1
		var/list/p2
		if(islist(want[1]))
			var/list/w1 = want[1]
			p1 = RLLcPos(w1[2])
		if(islist(want[2]))
			var/list/w2 = want[2]
			p2 = RLLcPos(w2[2])
		var/list/q1 = p1 ? p1 : L.lastq
		var/st = started
		if(started)
			animate(O, transform = BeamFXXform(L.last, O.fx_bx, O.fx_by), time = 0, flags = ANIMATION_END_NOW)
			energyfx_anim_n++
		if(!skip1)
			RLLcStep(L, want[1], st, 0, 0)
			st = 1
		if(!isnull(want[2])) RLLcStep(L, want[2], st, skip1 ? 0.25 : 0, (st && skip1) ? 0.25 : 0)
		for(var/qi = 1 to L.nc * 2)
			var/list/fst = list()
			if(!skip1) fst += list(q1[qi * 2 - 1], q1[qi * 2])
			if(!isnull(want[2]))
				var/list/q2 = p2 ? p2 : q1
				fst += list(q2[qi * 2 - 1], q2[qi * 2])
			if(fst.len) RLFiltAnim(O, L.fb + qi, fst, skip1 ? 0.25 : 0, 0)
		if(p2) L.lastq = p2
		else if(p1) L.lastq = p1
		L.dv = v2
		if(!s1 && !s2 && !L.shown)
			L.idle++
			if(L.idle >= 3)
				RLLcFree(L)
				rl_lcs -= key
		else
			L.idle = 0

/world/New()
	EFX92RegisterHit()
	. = ..()

/datum/beamfx/feint/var/list/rl_fl

proc/EFX92FeintFrame(T)
	if(T < ENERGYFX_FEINT_POP) return (T < ENERGYFX_FEINT_POP * 0.5) ? 0 : 1
	if(T < ENERGYFX_FEINT_PEAK) return 2 + min(3, floor((T - ENERGYFX_FEINT_POP) / ((ENERGYFX_FEINT_PEAK - ENERGYFX_FEINT_POP) / 4) + 0.000001))
	var/i = floor((T - ENERGYFX_FEINT_PEAK) / ENERGYFX_FEINT_DT + 0.000001)
	return (i < ENERGYFX_FEINT_N) ? 6 + i : null

proc/EFX92FeintN(T)
	var/n = EFX92PyRound(T / BEAMFX_FR)
	if(n >= 0 && n < EFX92_FEINT_J.len && abs(T - n * BEAMFX_FR) < 0.0001) return n
	return null

proc/EFX92FeintJ(T)
	var/n = EFX92FeintN(T)
	if(isnull(n)) return EFX92FeintFrame(T)
	var/j = EFX92_FEINT_J[n + 1]
	return (j < 0) ? null : j

proc/EFX92FeintK(T)
	var/n = EFX92FeintN(T)
	return isnull(n) ? EFX92FeintLight(T) : EFX92_FEINT_K[n + 1]

proc/EFX92FeintLight(T)
	if(T < 0) return 0
	if(T < ENERGYFX_FEINT_POP) return ENERGYFX_FEINT_LIGHT[1]
	if(T < ENERGYFX_FEINT_PEAK) return ENERGYFX_FEINT_LIGHT[2]
	var/i = floor((T - ENERGYFX_FEINT_PEAK) / ENERGYFX_FEINT_DT + 0.000001)
	return (i < ENERGYFX_FEINT_N) ? ENERGYFX_FEINT_LIGHT[3 + i] : 0

/datum/beamfx/feint/proc/RLFeintStart(now, qn)
	t0 = now
	fi0 = qn
	var/datum/bfx_rng/R = new /datum/bfx_rng(rl_seed)
	var/list/FE = rl.FE
	var/list/sp = FE["sparks"]
	var/x0 = WX(mz + (ENERGYFX_FEINT_AT + 7) * rl_st)
	var/y0 = WY(mz + (ENERGYFX_FEINT_AT + 7) * rl_st)
	rl_fl = list()
	for(var/list/fl in list(list(24, 3), list(-42, 2), list(63, 2)))
		for(var/n = 1 to fl[2])
			var/ft0 = ENERGYFX_FEINT_POP + R.U(0, 0.03)
			var/fa = ang + fl[1] + R.U(-9, 9)
			var/fv = R.U(170, 330)
			var/flife = R.U(0.15, 0.26)
			var/fg = R.RandRange(sp.len)
			var/fsc = R.U(0.85, 1.25)
			rl_fl[++rl_fl.len] = list(ft0, fa, fv, flife, fg, fsc, x0, y0)
	for(var/n = 1 to 5)
		var/ft0 = ENERGYFX_FEINT_PEAK + R.U(0, 0.05)
		var/fa = R.U(0, 360)
		var/fv = R.U(20, 55)
		var/flife = R.U(0.2, 0.32)
		var/fg = R.RandRange(sp.len)
		var/fsc = R.U(0.55, 0.8)
		rl_fl[++rl_fl.len] = list(ft0, fa, fv, flife, fg, fsc, x0, y0)

/datum/beamfx/feint/Tick(kk)
	if(!rl && isnull(t0) && fx_row && EFX92_ASSETS)
		var/key = EFX92_SKILL["[fx_row.path]"]
		var/datum/efx92_row/R = key ? EFX92Row(key) : null
		if(R && R.FE) RLInit(key)
	if(!rl) return
	rl_cf = list(list(), list())
	rl_lcf = list(list(), list())
	rl_sf = list(list(null, null), list(null, null))
	rl_sw = list(null, null)
	var/qn = 2 * kk
	var/now = FT(qn)
	ctx_f = qn
	if(isnull(t0)) RLFeintStart(now, qn)

/datum/beamfx/feint/Holds()
	return list()

/datum/beamfx/feint/Q(i, list/hl)
	return i

/datum/beamfx/feint/Frame(fi, j)
	if(!rl) return
	var/t = FT(fi)
	if(isnull(t0) || t < t0) return
	ctx_f = fi
	var/list/hl = Holds()
	rl_draw = (Q(2 * k, hl) == fi || Q(2 * k + 1, hl) == fi) ? 1 : 0
	if(!rl_draw) return
	var/T = t - t0
	var/list/FE = rl.FE
	var/list/out = list()
	var/jf = EFX92FeintJ(T)
	var/x = WX(mz + ENERGYFX_FEINT_AT * rl_st)
	var/y = WY(mz + ENERGYFX_FEINT_AT * rl_st)
	if(!isnull(jf) && T >= 0)
		var/list/fr = FE["frames"]
		RLPair(out, fr[jf + 1], x, y, 0, 1, 1, 1, 5.5, 0, null, null, "feint", "fe")
		var/kl = EFX92FeintK(T)
		if(rl.B && kl > 0.01)
			var/list/FL = rl.B["flash"]
			var/list/FA = FL["frames"]
			var/fres = FL["res"]
			if(isnull(fres)) fres = 1
			var/sc = (0.7 + 0.3 * kl) / fres
			RLRec(out, FA[BeamFXMod(jf, FA.len) + 1], x, y, 0, sc, sc, min(1, kl), 0, 0, 1, null, "bloom", "fb")
	var/list/sp = FE["sparks"]
	for(var/i = 1 to rl_fl.len)
		var/list/o = rl_fl[i]
		var/age = T - o[1]
		if(age < 0 || age >= o[4]) continue
		var/q = age / o[4]
		var/dist = o[3] * (age - 0.45 * age * age / o[4])
		var/kk2 = o[6] * (1 - 0.5 * q)
		var/a = min(1, age / 0.02) * (1 - BeamFXSstep(0.7, 1, q))
		RLRec(out, sp[o[5] + 1], o[7] + cos(o[2]) * dist, o[8] + sin(o[2]) * dist, 0, kk2, kk2, a, 0, 0, 1, null, "fleck", "fk[i]")
	if(logging) RLLog(fi, out)
	RLEmitAll(j, fi, out)

/datum/efx_bend/Build(list/px, list/py, d0, dh, Dv)
	..()
	for(var/i = 1 to corners.len - 1)
		var/datum/efx_corner/C = corners[i]
		C.nclose = (C.nxt && C.nxt.SA - C.SB < ENERGYFX_BEND_REACH) ? 1 : 0

