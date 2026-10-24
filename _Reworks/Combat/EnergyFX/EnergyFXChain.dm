var/energyfx_chain_on = 0
var/energyfx_chain_issue = 0
var/energyfx_chain_births = 0
var/energyfx_chain_static_in = 0
var/energyfx_chain_static_out = 0
var/energyfx_chain_static_ticks = 0

/datum/beamfx/var/datum/efx_chain/ch

/obj/energyfx/chainroot
	icon = null

/datum/efx_chpiece
	var/key
	var/light = 0
	var/obj/energyfx/carrier/car
	var/obj/energyfx/O
	var/obj/energyfx/boost
	var/obj/energyfx/jit
	var/bst = 1
	var/bst_ax = 0
	var/bst_ay = 0
	var/B = 0
	var/cbx = 0
	var/cby = 0
	var/list/cuts
	var/list/msk
	var/list/spec
	var/shown = 0
	var/looping = 0
	var/idle = 0

/datum/efx_chbody
	var/kind = 0
	var/obj/energyfx/scr
	var/list/kids = list()
	var/list/kloop = list()
	var/list/slots = list()
	var/vlo
	var/vhi
	var/soff
	var/shown = 0
	var/looping = 0
	var/lsx
	var/lsy

/datum/efx_chain
	var/obj/energyfx/chainroot/root
	var/rx = 0
	var/ry = 0
	var/list/pieces = list()
	var/list/bodies = list()
	var/list/els = list()
	var/list/el_end = list()
	var/list/el_cmt = list()
	var/static_on = 0
	var/static_f0 = 0
	var/try_after = 0
	var/forced = 0
	var/seen_uid = 0
	var/seen_rl = 0
	var/list/sig
	var/list/st_fr
	var/list/st_raw
	var/obj/energyfx/spk1
	var/obj/energyfx/spk2
	var/obj/energyfx/glint
	var/spk_len = -1
	var/glint_on = 0
	var/obj/energyfx/imp_p
	var/obj/energyfx/imp_l
	var/imp_on = 0
	var/imp_k0 = 0
	var/imp_loopk = -1
	var/imp_x = 0
	var/imp_y = 0
	var/imp_s = 1
	var/imp_out = 0
	var/end_k = 0

/datum/beam/FxStart(mob/M, obj/Skills/Projectile/Z)
	var/datum/beamfx/F = ..()
	if(F && energyfx_chain_on) F.ch_on = 1
	return F

/datum/beamfx/proc/ChainCan()
	if(!rl || rl_g || rl_ch) return 0
	return 1

/datum/beamfx/Step()
	if(!ch_on) return ..()
	if(!ChainCan() || bgeo || fgeo || clash_mode)
		ChainEscape()
		return ..()
	k++
	Tick(k)
	if(!ch) ch = new
	if(!isnull(t0)) ChainOutput()
	CharsTick()

/datum/beamfx/Busy()
	if(!ch_on) return ..()
	if(objs.len || rl_lrays.len || rl_shocks.len || rl_rbolts.len || rl_flares.len || rl_bolts.len || rl_sparks2.len) return 1
	if(!ch) return 0
	if(ch.imp_on) return 1
	for(var/key in ch.pieces)
		var/datum/efx_chpiece/PC = ch.pieces[key]
		if(PC.shown || PC.idle < 3) return 1
	for(var/key in ch.els)
		var/datum/efx_chpiece/PE = ch.els[key]
		if(PE.shown) return 1
	for(var/key in ch.bodies)
		var/datum/efx_chbody/BD = ch.bodies[key]
		if(BD.shown) return 1
	return 0

/datum/beamfx/Cleanup()
	if(ch_on && ch) ChainFree()
	..()

/datum/beamfx/proc/ChainEscape()
	if(ch) ChainFree()
	ch = null
	ch_on = 0
	rl_cf = list(list(), list())
	rl_lcf = list(list(), list())
	rl_sf = list(list(null, null), list(null, null))
	rl_sw = list(null, null)

/datum/beamfx/proc/ChainOutput()
	var/f1 = 2 * k
	if(ch.static_on)
		if(ChainSigEq(ChainSig(f1)))
			ChainStaticTick(f1)
			return
		ChainLeaveStatic()
	var/list/hl = Holds()
	var/v1 = Q(f1, hl)
	var/v2 = Q(f1 + 1, hl)
	if(ch.forced)
		v1 = f1
		if(v2 < f1 + 1) v2 = v1
	var/j1 = (v1 == f1) ? 1 : 0
	var/j2 = (v2 == f1 + 1) ? 1 : 0
	var/list/M1 = ChainMutate(f1)
	var/list/el1 = ChainElRaw(f1, j1, M1)
	var/list/D1 = j1 ? ChainDraw(f1, ChainFlow(f1, el1)) : null
	var/list/M2 = ChainMutate(f1 + 1)
	var/list/el2 = ChainElRaw(f1 + 1, j2, M2)
	var/list/D2 = j2 ? ChainDraw(f1 + 1, ChainFlow(f1 + 1, el2)) : null
	ch.forced = 0
	var/mode = 0
	if(D1 && D2) mode = 2
	else if(D1) mode = 1
	else if(D2) mode = 3
	if(!ch.root && (D1 || D2)) ChainRoot()
	if(!ch.root) return
	if(mode)
		ChainGroup(D1, D2, mode)
		ChainBody(D1, D2, mode, f1)
		ChainFlash(D1, D2, mode)
		ChainEls(D1, D2, mode)
		ChainSpecks(D1 ? D1 : D2)
	ChainImpact(f1)
	ChainSeen()
	if(mode == 1 && j1 && k >= ch.try_after && ChainQuiet(f1, f1)) ChainGoStatic(f1)

/datum/beamfx/proc/ChainSeen()
	var/top = ch.seen_uid
	for(var/datum/bfx_obj/o in objs)
		top = max(top, o.uid)
	ch.seen_uid = top
	ch.seen_rl = max(ch.seen_rl, rl_uid)

/datum/beamfx/proc/ChainRoot()
	var/obj/energyfx/chainroot/R = ChainGet(/obj/energyfx/chainroot, null)
	if(!R) return
	var/tx = floor(Ox / 32) + 1
	var/ty = floor(Oy / 32) + 1
	var/turf/T = locate(tx, ty, z)
	if(!T)
		ChainPut(R)
		return
	ChainLoc(R, T)
	ch.root = R
	ch.rx = (tx - 1) * 32
	ch.ry = (ty - 1) * 32

/datum/beamfx/proc/ChainGet(path, obj/energyfx/P)
	var/obj/energyfx/O = EnergyFXGet(path, src)
	if(!O) return null
	O.pixel_x = 0
	O.pixel_y = 0
	if(P)
		P.vis_contents += O
		O.fx_car = P
	energyfx_chain_births++
	return O

/datum/beamfx/proc/ChainPut(obj/energyfx/O)
	if(!O) return
	EnergyFXFree(O)

/datum/beamfx/proc/ChainLoc(obj/energyfx/O, turf/T)
	O.loc = T
	O.step_x = 0
	O.step_y = 0

/datum/beamfx/proc/ChainReparent(obj/energyfx/O, obj/energyfx/P)
	if(O.fx_car) O.fx_car.vis_contents -= O
	P.vis_contents += O
	O.fx_car = P

/datum/beamfx/proc/ChainFam(obj/energyfx/O, fam, st, light)
	var/ic = RLFamIcon(fam, light)
	if(O.icon != ic)
		var/list/f = BEAMFX_FAM[fam]
		O.icon = ic
		O.fx_w = f[2]
		O.fx_h = f[3]
	if(O.icon_state != st) O.icon_state = st

/datum/beamfx/proc/ChainBlank(obj/energyfx/O)
	O.icon = rl_carF
	O.icon_state = "b"
	O.fx_w = rl_carB
	O.fx_h = rl_carB

/datum/beamfx/proc/ChainArt(obj/energyfx/O, ic, st, w, h, nm)
	O.icon = ic
	O.icon_state = st
	O.fx_w = w
	O.fx_h = h

/datum/beamfx/proc/ChainXf(obj/energyfx/O, matrix/M)
	O.transform = M
	energyfx_chain_issue++

/datum/beamfx/proc/ChainAl(obj/energyfx/O, al)
	O.color = EFX92FoldA(EFX92_IDENTITY, al)
	energyfx_chain_issue++

/datum/beamfx/proc/ChainZ(obj/energyfx/O, z)
	O.layer = z

/datum/beamfx/proc/ChainPix(obj/energyfx/O, x, y)
	O.pixel_x = x
	O.pixel_y = y

/datum/beamfx/proc/ChainLook0(obj/energyfx/O, light, kt)
	O.plane = light ? ENERGYFX_SHARP_PLANE : ENERGYFX_PAINT_PLANE
	O.blend_mode = light ? BLEND_ADD : BLEND_DEFAULT
	O.appearance_flags = kt ? KEEP_TOGETHER : initial(O.appearance_flags)
	O.filters = kt ? null : RLObjFilter(light)
	O.alpha = 255

/datum/beamfx/proc/ChainHalt(obj/energyfx/O)
	animate(O)

/datum/beamfx/proc/ChainSeq(obj/energyfx/O, list/steps, lp)
	var/first = 1
	for(var/list/s in steps)
		var/sh = s[1]
		var/t = s[2]
		var/ic = null
		if(sh & 1) ic = (s[5] < 0) ? s[3] : RLFamIcon(s[3], s[5])
		var/st = s[4]
		var/matrix/M = s[6]
		var/list/col = (sh & 4) ? EFX92FoldA(EFX92_IDENTITY, s[7]) : null
		if(first)
			switch(sh)
				if(7) animate(O, icon = ic, icon_state = st, transform = M, color = col, time = t, loop = lp, easing = JUMP_EASING, flags = ANIMATION_END_NOW)
				if(3) animate(O, icon = ic, icon_state = st, transform = M, time = t, loop = lp, easing = JUMP_EASING, flags = ANIMATION_END_NOW)
				if(1) animate(O, icon = ic, icon_state = st, time = t, loop = lp, easing = JUMP_EASING, flags = ANIMATION_END_NOW)
				if(2) animate(O, transform = M, time = t, loop = lp, easing = JUMP_EASING, flags = ANIMATION_END_NOW)
				if(4) animate(O, color = col, time = t, loop = lp, easing = JUMP_EASING, flags = ANIMATION_END_NOW)
			first = 0
		else
			switch(sh)
				if(7) animate(icon = ic, icon_state = st, transform = M, color = col, time = t, easing = JUMP_EASING)
				if(3) animate(icon = ic, icon_state = st, transform = M, time = t, easing = JUMP_EASING)
				if(1) animate(icon = ic, icon_state = st, time = t, easing = JUMP_EASING)
				if(2) animate(transform = M, time = t, easing = JUMP_EASING)
				if(4) animate(color = col, time = t, easing = JUMP_EASING)
	energyfx_chain_issue += steps.len

/datum/beamfx/proc/ChainFade(obj/energyfx/O, t)
	animate(O, color = EFX92FoldA(EFX92_IDENTITY, 0), time = t, flags = ANIMATION_PARALLEL)
	energyfx_chain_issue++

/datum/beamfx/proc/ChainMasks(obj/energyfx/C, list/plans, cx0, cy0)
	var/list/fl = list()
	for(var/list/p in plans)
		fl += filter(type = "alpha", icon = EFX92M2Icon(p[1]), x = p[2] - cx0, y = p[3] - cy0, flags = MASK_INVERSE)
	C.filters = fl
	energyfx_chain_issue++

/datum/beamfx/proc/ChainMaskAt(obj/energyfx/C, i, wx, wy, cx0, cy0)
	animate(C.filters[i], x = wx - cx0, y = wy - cy0, time = 0.5, easing = JUMP_EASING, flags = ANIMATION_END_NOW | ANIMATION_PARALLEL)
	energyfx_chain_issue++

/datum/beamfx/proc/ChainMaskTwo(obj/energyfx/C, i, x1, y1, x2, y2)
	animate(C.filters[i], x = x1, y = y1, time = 0.25, easing = JUMP_EASING, flags = ANIMATION_END_NOW | ANIMATION_PARALLEL)
	animate(C.filters[i], x = x2, y = y2, time = 0.25, easing = JUMP_EASING)
	energyfx_chain_issue += 2

/datum/beamfx/proc/ChainMutate(fi)
	var/t = FT(fi)
	if(isnull(t0) || t < t0) return null
	var/Hrv = Hr(t, fi, 0)
	if(isnull(Hrv)) return null
	var/dead = !isnull(dead_f) && fi >= dead_f
	var/firing = isnull(release_f) || fi < release_f
	var/ending = !isnull(end_t) && t >= end_t
	var/st = dead ? dead_struggle : Struggling(fi, 0)
	var/nd = RLDraw(fi)
	var/list/hg = RLHeadGeom(t, fi, Hrv, rl_pierce ? 0 : st, nd)
	var/list/Hd = hg[1]
	var/list/sn = RLSnap(hg[3], t, fi)
	var/xh = sn[1]
	if(rl_pierce)
		if(Hd["ramped"]) xh = mz - Hd["xm"] * rl_st
	else
		if(ending && isnull(rl_end_phase)) rl_end_phase = sn[2]
		if(!ending) rl_end_xh = xh
	var/bk = Back(t, fi)
	if(!rl.B) return list(xh, Hd, firing, bk)
	var/surges_on = isnull(rl.P["surges"]) ? 1 : rl.P["surges"]
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
			if(!firing && dd < bk - 30) continue
			alive += o
			continue
		alive += o
	objs = alive
	var/list/keepf = list()
	for(var/list/f in rl_flares)
		if(t - f[1] > 0.25) continue
		keepf[++keepf.len] = f
	rl_flares = keepf
	return list(xh, Hd, firing, bk)

/datum/beamfx/proc/ChainElRaw(fi, draw, list/M)
	var/t = FT(fi)
	var/list/a = list()
	var/list/b = list()
	var/list/c = list()
	if(isnull(t0) || t < t0) return list(a, b, c)
	if(isnull(Hr(t, fi, 0))) return list(a, b, c)
	rl_draw = draw
	var/list/A = rl.A
	if(rl_pierce)
		RLBoltSprites(a, t, fi)
		RLSpark2Sprites(b, t, fi)
	else
		if(A["lrays"]) RLLraySprites(a, t, fi)
		if(A["shock"] && M) RLShockSprites(a, t, fi, M[1], M[2], M[3], M[4])
		if(A["rbolts"]) RLRootBoltSprites(b, t, fi)
	rl_draw = 1
	if(draw && M && rl.B)
		for(var/datum/bfx_obj/o in objs)
			if(o.kind != "surge") continue
			var/list/r = ChainSurgeRec(o, t, fi, M[1], M[2], M[3])
			if(r) c[++c.len] = r
	return list(a, b, c)

/datum/beamfx/proc/ChainFlow(fi, list/el)
	var/t = FT(fi)
	if(isnull(t0) || t < t0) return null
	var/Hrv = Hr(t, fi, 0)
	if(isnull(Hrv)) return null
	if(rl_pierce) return ChainFlowPierce(fi, el, t, Hrv)
	var/list/out = list()
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
	var/endp = rl_end_phase
	if(ending && isnull(endp)) endp = ih
	var/head_cut = xh + Hd["cut"] * stk
	var/hi_cut = head_cut
	var/lo_cut = null
	var/list/St = A["star"]
	rl_draw = 1
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
		var/xb2 = sb[1]
		var/ib = sb[2]
		lo_cut = xb2 + Bl["cut"] * stk
		var/al2 = min(1, (t - t0) / 0.04)
		var/hp = xb2 + Bl["ox"] * stk
		var/list/bfr = Bl["frames"]
		var/list/pair2 = bfr[ib + 1]
		var/bcut = bud_closed ? min(xb2 + Bl["cut"] * stk, xh) : (xb2 + Bl["cut"] * stk)
		RLPair(out, pair2, WX(hp), WY(hp), ang, stk, 1, al2, 4.5, 0, list(RLCut(bcut + EFX92_JOIN_OV * stk, -1, stk)), list(RLCut(bcut, -1, stk)), "bloom", "bl", null, bfr, ib)
		if(A["bloom_flare"]) RLFlareSprites(out, t, fi, xb2, nd)
		if(A["rays"]) RLRaySprites(out, t, fi, al2, 1, nd)
	else
		var/q = (t - release_t) / 0.1
		if(q < 1 && St)
			var/sc = 1 - 0.85 * q
			var/al3 = (1 - q) ** 1.2
			var/list/sfr2 = St["frames"]
			var/list/pair3 = sfr2[BeamFXMod(nd, sfr2.len) + 1]
			RLPair(out, pair3, WX(mz), WY(mz), 0, sc, sc, al3, 4.6, 0, null, null, "star", "mz")
		else if(q < 1 && A["bloom_closed"])
			var/list/Bc = A["bloom_closed"]
			var/list/sb2 = RLSnap(mz, t, fi)
			var/xb3 = sb2[1]
			var/ib2 = sb2[2]
			var/sc2 = 1 - 0.85 * q
			var/al4 = (1 - q) ** 1.2
			var/hp2 = xb3 + Bc["ox"] * sc2 * stk
			var/list/bfr2 = Bc["frames"]
			RLPair(out, bfr2[ib2 + 1], WX(hp2), WY(hp2), ang, sc2 * stk, sc2, al4, 4.5, 0, null, null, "bloom", "bc", null, bfr2, ib2)
			if(A["rays"]) RLRaySprites(out, t, fi, al4, sc2, nd)
		if(!ending)
			var/list/T = A["tail"]
			var/list/stl = RLSnap(bk, t, fi)
			var/xt = stl[1]
			var/it = stl[2]
			lo_cut = xt + T["cut"] * stk
			var/closing = (kh == heads.len - 1) && (xt + P["tail_L"] * stk >= head_cut) && !rl_no_drain
			var/hp3 = xt + T["ox"] * stk
			var/list/tfr = T["frames"]
			if(!closing)
				var/tcut = min(xt + T["cut"] * stk, head_cut)
				RLPair(out, tfr[it + 1], WX(hp3), WY(hp3), ang, stk, 1, 1, 4.2, 0, list(RLCut(tcut + EFX92_JOIN_OV * stk, -1, stk)), list(RLCut(tcut, -1, stk)), "tail", "tl")
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
		var/hp4 = xh + Hsrc["ox"] * stk
		var/list/hfr = Hsrc["frames"]
		var/list/pc = cuts.len ? list(RLCut(head_cut - EFX92_JOIN_OV * stk, 1, stk)) : list()
		var/list/hb = list(Hsrc["ox"], Hd["R"], Hd["sq"])
		RLPair(out, hfr[ih + 1], WX(hp4), WY(hp4), ang, stk, 1, 1, 5, 0, pc, cuts, "head", "hd[Hsrc == Hd ? kh : "x"]", hb, hfr, ih)
	else
		var/qe = (t - end_t) / P["erode_dt"]
		var/ei = floor(qe + 0.000001)
		var/list/E = A["erode"]
		var/list/efr = E["frames"]
		var/list/ef1 = efr[1]
		if(ei < ef1.len)
			var/xe = isnull(rl_end_xh) ? xh : rl_end_xh
			var/ph = isnull(endp) ? ih : endp
			var/list/eph = efr[ph + 1]
			var/hp5 = xe + E["ox"] * stk
			var/list/Ph = P["heads"]
			var/list/hl = Ph[Ph.len]
			RLPair(out, eph[ei + 1], WX(hp5), WY(hp5), ang, stk, 1, 1, 5, 0, null, null, "erode", "er", list(E["ox"], hl[1], hl[2]))
	if(el) out += el[1]
	var/list/reps
	if(!isnull(lo_cut) && lo_cut < hi_cut && !ending)
		var/list/cs = list(RLCut(lo_cut, 1, stk), RLCut(hi_cut, -1, stk))
		var/bd0 = dstart + LatBase(t, fi)
		reps = list(list(-1, WX(bd0), WY(bd0), ang, stk, 1, 1, 4, 0, 0, cs, "stamp", null, "sp", null, 0), list(-1, WX(bd0), WY(bd0), ang, stk, 1, 1, 0, 0, 1, cs, "stamp", null, "sl", null, 0))
	if(A["halo"]) RLHaloSprites(out, t, fi, xh, st, ending, nd)
	if(el) out += el[2]
	if(el) out += el[3]
	var/boost = ChainFlashFlare(out, t, fi, Hrv, xh, st, ending)
	if(P["xglint"] && St) RLHitGlint(out, t, fi, Hrv, st, ending, nd)
	if(reps) out += reps
	return list(out, xh, Hd, firing, ending, boost, nd, Hrv, bk)

/datum/beamfx/proc/ChainFlowPierce(fi, list/el, t, Hrv)
	var/list/out = list()
	var/list/A = rl.A
	var/stk = rl_st
	var/firing = isnull(release_f) || fi < release_f
	var/bk = Back(t, fi)
	var/nd = RLDraw(fi)
	var/list/hg = RLHeadGeom(t, fi, Hrv, 0, nd)
	var/list/Hd = hg[1]
	var/ramped = Hd["ramped"] ? 1 : 0
	var/list/sn = RLSnap(hg[3], t, fi)
	var/ih = sn[2]
	var/xh = ramped ? (mz - Hd["xm"] * stk) : sn[1]
	var/head_cut = xh + Hd["cut"] * stk
	var/lo_cut = null
	var/list/St = A["star"]
	var/list/sfr = St["frames"]
	var/jm = BeamFXMod(nd, sfr.len)
	rl_draw = 1
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
	if(!isnull(lo_cut) && lo_cut < head_cut && !ramped)
		var/list/cs = list(RLCut(lo_cut, 1, stk), RLCut(head_cut, -1, stk))
		var/bd0 = dstart + LatBase(t, fi)
		out += list(list(-1, WX(bd0), WY(bd0), ang, stk, 1, 1, 4, 0, 0, cs, "stamp", null, "sp", null, 0), list(-1, WX(bd0), WY(bd0), ang, stk, 1, 1, 0, 0, 1, cs, "stamp", null, "sl", null, 0))
	var/list/boost = list(1, 0, 0)
	if(rl.B)
		if(el) out += el[3]
		boost = ChainFlashFlare(out, t, fi, Hrv, xh, 0, 0)
		RLPierceFlash(out, t, fi)
	if(el)
		out += el[1]
		out += el[2]
	return list(out, xh, Hd, firing, 0, boost, nd, Hrv, bk)

/datum/beamfx/proc/ChainWiden(list/all, fi, t)
	return rl_pierce ? RLWidenPierce(all, fi, t) : RLWiden(all, fi, t)

/datum/beamfx/proc/ChainFlashFlare(list/out, t, fi, Hrv, xh, st, ending)
	var/list/B = rl.B
	if(!B) return list(1, 0, 0)
	var/list/P = rl.P
	var/list/FL = B["flash"]
	var/list/FA = FL["frames"]
	var/fres = FL["res"]
	if(isnull(fres)) fres = 1
	var/jf = BeamFXMod(floor((fi - fi0) / 2), FA.len)
	var/fl = 0
	for(var/list/f in rl_flares)
		var/dt = t - f[1]
		if(dt > 0.25) continue
		if(dt >= 0 && dt < 0.2) fl = max(fl, f[2] * ((1 - dt / 0.2) ** 1.3))
	if(fl > 0.01 && !ending)
		var/ksc = P["flare_k"] * (0.75 + 0.25 * fl) / fres
		RLRec(out, FA[jf + 1], WX(xh), WY(xh), 0, ksc, ksc, min(1, 0.85 * fl), 0, 0, 1, null, "flare", "fr")
	if(st && !isnull(t_hit) && t >= t_hit)
		var/qh = HitQ(t)
		var/jit = 0.88 + 0.28 * BeamFXMod(BeamFXMod(fi, 97) * 62 + BeamFXMod(fi0, 97) * 31, 97) / 97
		var/first = max(0, 1 - (t - t_hit) / 0.18)
		var/al = (0.55 + 0.35 * qh + 0.5 * first) * (ending ? max(0, 1 - (t - end_t) / RLP("flash_end_fade", 0.2)) : 1)
		var/c = Contact(t, fi, 0)
		var/cd = isnull(c) ? (Hrv + EFX92_CONTACT) : c
		var/ksc2 = P["flash_k"] * (0.45 + 0.55 * qh + 0.3 * first) * jit / fres
		if(al > 0.01) RLRec(out, FA[jf + 1], WX(cd - 3), WY(cd - 3), 0, ksc2, ksc2, min(1, al), 0, 0, 1, null, "flash", "fs")
	return list(1 + 0.25 * fl, 0, 0)

/datum/beamfx/proc/ChainDraw(fi, list/W)
	if(!W) return null
	var/list/all = W[1]
	if(abs(rl_k - 1) > 0.000001) all = ChainWiden(all, fi, FT(fi))
	var/list/S = list()
	var/list/E = list()
	var/list/reps = list()
	var/pidx = 0
	var/fx = 0
	var/fy = 0
	for(var/list/r in all)
		var/tg = r[RL92_TAG]
		if(tg == "stamp")
			reps[++reps.len] = r
			continue
		var/si = r[RL92_ST]
		if(isnull(si) || si < 0) continue
		var/zl = 0
		if(r[RL92_KIND] == 0)
			pidx++
			zl = r[RL92_LY] + pidx * 0.000001 + RLZo()
		var/list/sp = ChainSpec(r, zl)
		if(!ChainOnMap(sp[BFX_X], sp[BFX_Y])) continue
		if(tg == "flash")
			fx = r[RL92_X]
			fy = r[RL92_Y]
		if(ChainElTag(tg))
			E[r[RL92_KEY]] = list(sp, r[RL92_CUTS])
		else if(tg == "pflash")
			S["[r[RL92_KEY]]|1"] = list(sp, r[RL92_CUTS])
		else
			S["[tg]|[r[RL92_KIND]]"] = list(sp, r[RL92_CUTS])
	var/list/b = W[6]
	return list(S, reps.len ? reps : null, E, list(b[1], fx, fy), W)

/datum/beamfx/proc/ChainSpec(list/r, zl)
	var/list/stt = rl.S[r[RL92_ST] + 1]
	var/file = stt[1] + 1
	var/a = r[RL92_ANG]
	var/ca = cos(a)
	var/sa = sin(a)
	var/sx = r[RL92_SX]
	var/sy = r[RL92_SY]
	return list(rl.fams[file], stt[2], r[RL92_KIND], r[RL92_X] + ca * sx * stt[3] - sa * sy * stt[4], r[RL92_Y] + sa * sx * stt[3] + ca * sy * stt[4], a, sx, sy, 0, r[RL92_AL], r[RL92_LY], r[RL92_OR], r[RL92_TAG], 1, null, zl, 0)

/datum/beamfx/proc/ChainOnMap(x, y)
	var/tx = floor(x / 32) + 1
	var/ty = floor(y / 32) + 1
	return (tx >= 1 && ty >= 1 && tx <= world.maxx && ty <= world.maxy) ? 1 : 0

/datum/beamfx/proc/ChainSame(list/a, list/b)
	if(!a || !b) return a == b
	var/list/sa = a[1]
	var/list/sb = b[1]
	if(!sa || !sb) return sa == sb
	for(var/i = 1 to 12)
		if(sa[i] != sb[i]) return 0
	if(sa[16] != sb[16]) return 0
	return ChainCutsEq(a[2], b[2])

/datum/beamfx/proc/ChainNear(list/a, list/b)
	if(!a || !b) return a == b
	var/list/sa = a[1]
	var/list/sb = b[1]
	if(!sa || !sb) return sa == sb
	if(sa[1] != sb[1] || sa[2] != sb[2] || sa[3] != sb[3] || sa[13] != sb[13]) return 0
	if(abs(sa[4] - sb[4]) > 0.01 || abs(sa[5] - sb[5]) > 0.01) return 0
	for(var/i = 6 to 12)
		if(abs(sa[i] - sb[i]) > 0.0001) return 0
	if(abs(sa[16] - sb[16]) > 0.0000001) return 0
	return ChainCutsEq(a[2], b[2])

/datum/beamfx/proc/ChainCutsEq(list/a, list/b)
	var/na = a ? a.len : 0
	var/nb = b ? b.len : 0
	if(na != nb) return 0
	if(!na) return 1
	for(var/i = 1 to na)
		var/list/x = a[i]
		var/list/y = b[i]
		if(abs(x[1] - y[1]) > 0.01 || abs(x[2] - y[2]) > 0.01) return 0
		if(abs(x[3] - y[3]) > 0.00001 || abs(x[4] - y[4]) > 0.00001 || abs(x[5] - y[5]) > 0.0001) return 0
	return 1

/datum/beamfx/proc/ChainAlphaOf(list/sp)
	return clamp(sp[BFX_ALPHA] * 255, 0, 255)

/datum/beamfx/proc/ChainPieceNew(key, list/sp, list/cuts)
	var/datum/efx_chpiece/PC = new
	PC.key = key
	PC.light = sp[BFX_LIGHT]
	if(cuts && cuts.len)
		var/obj/energyfx/carrier/C = ChainGet(/obj/energyfx/carrier, ch.root)
		if(!C) return null
		PC.car = C
		PC.B = rl_carB
		ChainBlank(C)
		ChainLook0(C, PC.light, 1)
		ChainZ(C, sp[BFX_ZL])
		var/obj/energyfx/O = ChainGet(PC.light ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, C)
		if(!O)
			ChainPieceFree(PC)
			return null
		PC.O = O
		ChainLook0(O, PC.light, 0)
		ChainFam(O, sp[BFX_FAM], sp[BFX_ST], PC.light)
		ChainZ(O, sp[BFX_ZL])
		ChainCarPlace(PC, sp)
		ChainCarMasks(PC, cuts)
	else
		var/obj/energyfx/O2 = ChainGet(PC.light ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, ch.root)
		if(!O2) return null
		PC.O = O2
		ChainLook0(O2, PC.light, 0)
		ChainFam(O2, sp[BFX_FAM], sp[BFX_ST], PC.light)
		ChainZ(O2, sp[BFX_ZL])
		O2.fx_bx = ch.rx + O2.fx_w / 2
		O2.fx_by = ch.ry + O2.fx_h / 2
	ChainAl(PC.O, 0)
	PC.shown = 0
	return PC

/datum/beamfx/proc/ChainCarPlace(datum/efx_chpiece/PC, list/sp)
	var/B = PC.B
	PC.cbx = floor(sp[BFX_X]) - B / 2
	PC.cby = floor(sp[BFX_Y]) - B / 2
	ChainPix(PC.car, PC.cbx - ch.rx, PC.cby - ch.ry)
	PC.O.fx_bx = PC.cbx + PC.O.fx_w / 2
	PC.O.fx_by = PC.cby + PC.O.fx_h / 2

/datum/beamfx/proc/ChainPlans(list/cuts, cx0, cy0)
	var/list/out = list()
	for(var/list/c in cuts)
		var/list/pl = EFX92CutPlan(c, cx0, cy0)
		out += list(list(pl[1], pl[2], pl[3]), list(pl[4], pl[5], pl[6]))
	return out

/datum/beamfx/proc/ChainCarMasks(datum/efx_chpiece/PC, list/cuts)
	var/cx0 = PC.cbx + PC.B / 2
	var/cy0 = PC.cby + PC.B / 2
	var/list/pl = ChainPlans(cuts, cx0, cy0)
	ChainMasks(PC.car, pl, cx0, cy0)
	PC.msk = pl
	PC.cuts = cuts

/datum/beamfx/proc/ChainCarSync(datum/efx_chpiece/PC, list/sp, list/cuts)
	if(!PC.car || !sp) return
	var/moved = abs(sp[BFX_X] - (PC.cbx + PC.B / 2)) > 48 || abs(sp[BFX_Y] - (PC.cby + PC.B / 2)) > 48
	if(moved) ChainCarPlace(PC, sp)
	if(moved || !ChainCutsEq(cuts, PC.cuts)) ChainCarMoveMasks(PC, cuts)
	if(PC.car.layer != sp[BFX_ZL]) ChainZ(PC.car, sp[BFX_ZL])

/datum/beamfx/proc/ChainCarMoveMasks(datum/efx_chpiece/PC, list/cuts)
	var/cx0 = PC.cbx + PC.B / 2
	var/cy0 = PC.cby + PC.B / 2
	var/list/pl = ChainPlans(cuts, cx0, cy0)
	var/same = (PC.msk && PC.msk.len == pl.len) ? 1 : 0
	if(same)
		for(var/i = 1 to pl.len)
			var/list/a = pl[i]
			var/list/b = PC.msk[i]
			if(a[1] != b[1]) same = 0
	if(!same)
		ChainMasks(PC.car, pl, cx0, cy0)
	else
		for(var/i = 1 to pl.len)
			var/list/a2 = pl[i]
			var/list/b2 = PC.msk[i]
			if(abs(a2[2] - b2[2]) > 0.000001 || abs(a2[3] - b2[3]) > 0.000001) ChainMaskAt(PC.car, i, a2[2], a2[3], cx0, cy0)
	PC.msk = pl
	PC.cuts = cuts

/datum/beamfx/proc/ChainCarTwo(datum/efx_chpiece/PC, list/c1, list/c2)
	var/cx0 = PC.cbx + PC.B / 2
	var/cy0 = PC.cby + PC.B / 2
	var/list/p1 = ChainPlans(c1, cx0, cy0)
	var/list/p2 = ChainPlans(c2, cx0, cy0)
	var/same = (PC.msk && PC.msk.len == p1.len && p1.len == p2.len) ? 1 : 0
	if(same)
		for(var/i = 1 to p1.len)
			var/list/a = p1[i]
			var/list/b = p2[i]
			var/list/m = PC.msk[i]
			if(a[1] != b[1] || a[1] != m[1]) same = 0
	if(!same)
		ChainMasks(PC.car, p2, cx0, cy0)
		PC.msk = p2
		PC.cuts = c2
		return
	for(var/i = 1 to p1.len)
		var/list/a2 = p1[i]
		var/list/b2 = p2[i]
		ChainMaskTwo(PC.car, i, a2[2] - cx0, a2[3] - cy0, b2[2] - cx0, b2[3] - cy0)
	PC.msk = p2
	PC.cuts = c2

/datum/beamfx/proc/ChainXOf(datum/efx_chpiece/PC, list/sp)
	var/list/f = BEAMFX_FAM[sp[BFX_FAM]]
	var/bx = PC.car ? PC.cbx : ch.rx
	var/by = PC.car ? PC.cby : ch.ry
	return BeamFXXform(sp, bx + f[2] / 2, by + f[3] / 2)

/datum/beamfx/proc/ChainPieceSet(datum/efx_chpiece/PC, list/sp)
	var/obj/energyfx/O = PC.O
	var/list/o = PC.spec
	if(!o || o[1] != sp[1] || o[2] != sp[2]) ChainFam(O, sp[BFX_FAM], sp[BFX_ST], PC.light)
	if(O.layer != sp[BFX_ZL]) ChainZ(O, sp[BFX_ZL])
	if(!o || !PC.shown || abs(o[4] - sp[4]) > 0.000001 || abs(o[5] - sp[5]) > 0.000001 || abs(o[6] - sp[6]) > 0.000001 || abs(o[7] - sp[7]) > 0.000001 || abs(o[8] - sp[8]) > 0.000001) ChainXf(O, ChainXOf(PC, sp))
	if(!o || !PC.shown || abs(o[10] - sp[10]) > 0.000001) ChainAl(O, ChainAlphaOf(sp))
	PC.spec = sp
	PC.shown = 1
	PC.idle = 0

/datum/beamfx/proc/ChainPieceHide(datum/efx_chpiece/PC)
	ChainPieceStop(PC)
	if(PC.shown)
		ChainAl(PC.O, 0)
		PC.shown = 0
	PC.idle++

/datum/beamfx/proc/ChainPieceStop(datum/efx_chpiece/PC)
	if(!PC.looping) return
	ChainHalt(PC.O)
	if(PC.jit)
		ChainHalt(PC.jit)
		ChainXf(PC.jit, matrix())
	PC.looping = 0

/datum/beamfx/proc/ChainStepOf(datum/efx_chpiece/PC, list/sp, t)
	if(!sp) return list(4, t, null, null, 0, null, 0)
	return list(7, t, sp[BFX_FAM], sp[BFX_ST], PC.light, ChainXOf(PC, sp), ChainAlphaOf(sp))

/datum/beamfx/proc/ChainPieceTwo(datum/efx_chpiece/PC, list/sp1, list/sp2)
	ChainPieceStop(PC)
	if(sp1)
		if(PC.O.layer != sp1[BFX_ZL]) ChainZ(PC.O, sp1[BFX_ZL])
	else if(sp2)
		if(PC.O.layer != sp2[BFX_ZL]) ChainZ(PC.O, sp2[BFX_ZL])
	ChainSeq(PC.O, list(ChainStepOf(PC, sp1, 0.25), ChainStepOf(PC, sp2, 0.25)), 1)
	if(sp2)
		PC.spec = sp2
		PC.shown = 1
	else
		PC.shown = 0
	PC.idle = 0

/datum/beamfx/proc/ChainLook(datum/efx_chpiece/PC, list/e1, list/e2, mode)
	var/list/a
	var/list/b
	if(mode == 1)
		a = e1
		b = e1
	else if(mode == 2)
		a = e1
		b = e2
	else
		a = PC.shown ? list(PC.spec, PC.cuts) : null
		b = e2
	if(PC.looping)
		ChainPieceStop(PC)
		PC.shown = 1
	if(ChainSame(a, b))
		if(!b)
			ChainPieceHide(PC)
			return
		ChainCarSync(PC, b[1], b[2])
		ChainPieceSet(PC, b[1])
		return
	if(PC.car)
		if(a && b)
			ChainCarSync(PC, a[1], a[2])
			if(!ChainCutsEq(a[2], b[2])) ChainCarTwo(PC, a[2], b[2])
		else if(a)
			ChainCarSync(PC, a[1], a[2])
		else if(b)
			ChainCarSync(PC, b[1], b[2])
	ChainPieceTwo(PC, a ? a[1] : null, b ? b[1] : null)

/datum/beamfx/proc/ChainPieceLoop(datum/efx_chpiece/PC, list/frames)
	var/list/steps = list()
	var/list/sp0 = frames[1]
	if(PC.O.layer != sp0[BFX_ZL]) ChainZ(PC.O, sp0[BFX_ZL])
	for(var/list/sp in frames)
		steps += list(ChainStepOf(PC, sp, 0.5))
	ChainSeq(PC.O, steps, -1)
	PC.looping = 1
	PC.shown = 1
	PC.idle = 0
	PC.spec = frames[frames.len]

/datum/beamfx/proc/ChainPieceFree(datum/efx_chpiece/PC)
	if(PC.O)
		PC.O.filters = null
		ChainPut(PC.O)
	if(PC.jit) ChainPut(PC.jit)
	if(PC.boost) ChainPut(PC.boost)
	if(PC.car)
		PC.car.filters = null
		PC.car.icon = null
		PC.car.icon_state = null
		ChainPix(PC.car, 0, 0)
		PC.car.appearance_flags = initial(PC.car.appearance_flags)
		ChainPut(PC.car)
	PC.O = null
	PC.car = null
	PC.boost = null
	PC.jit = null
	PC.shown = 0
	PC.looping = 0

/datum/beamfx/proc/ChainGroupKeys(list/S1, list/S2)
	var/list/keys = list()
	for(var/list/S in list(S1, S2))
		for(var/key in S)
			if(findtext(key, "flash|") == 1 || findtext(key, "flare|") == 1) continue
			keys[key] = 1
	for(var/key in ch.pieces)
		if(findtext(key, "flash|") == 1 || findtext(key, "flare|") == 1) continue
		keys[key] = 1
	return keys

/datum/beamfx/proc/ChainGroup(list/D1, list/D2, mode)
	var/list/S1 = D1 ? D1[1] : null
	var/list/S2 = D2 ? D2[1] : null
	for(var/key in ChainGroupKeys(S1, S2))
		var/list/e1 = S1 ? S1[key] : null
		var/list/e2 = S2 ? S2[key] : null
		var/datum/efx_chpiece/PC = ch.pieces[key]
		if(!PC)
			var/list/first = (mode == 3) ? e2 : (e1 ? e1 : e2)
			if(!first) continue
			PC = ChainPieceNew(key, first[1], first[2])
			if(!PC) continue
			ch.pieces[key] = PC
		ChainLook(PC, e1, e2, mode)
		if(!PC.shown && PC.idle >= 3)
			ChainPieceFree(PC)
			ch.pieces -= key

/datum/beamfx/proc/ChainOff(fi)
	var/P = S * rl.np
	var/u = LatBase(FT(fi), fi)
	return u - P * floor(u / P)

/datum/beamfx/proc/ChainBodyCuts(list/rep)
	var/list/cs = list()
	for(var/list/c in rep[RL92_CUTS])
		cs += list(list((c[1] - Ox) * ax + (c[2] - Oy) * ay, ((c[3] * ax + c[4] * ay) > 0) ? 1 : -1, c[5] / 2 + 1))
	return cs

/datum/beamfx/proc/ChainStampOut(list/cs, e0, e1)
	for(var/list/c in cs)
		if(c[2] > 0)
			if(e1 < c[1] - c[3]) return 1
		else
			if(e0 > c[1] + c[3]) return 1
	return 0

/datum/beamfx/proc/ChainStampIn(list/cs, e0, e1)
	for(var/list/c in cs)
		if(c[2] > 0)
			if(e0 <= c[1] + c[3]) return 0
		else
			if(e1 >= c[1] - c[3]) return 0
	return 1

/datum/beamfx/proc/ChainBodyPlan(list/rep, fi)
	RLStampExtent()
	var/base = dstart + ChainOff(fi)
	var/sx = rep[RL92_SX]
	var/e0 = base + rl_se0 * sx
	var/e1 = base + rl_se1 * sx
	var/list/cs = ChainBodyCuts(rep)
	var/ga = -1000000
	var/gd = 1000000
	for(var/list/c in cs)
		if(c[2] > 0) ga = max(ga, ceil((c[1] - c[3] - e1) / S))
		else gd = min(gd, floor((c[1] + c[3] - e0) / S))
	if(ga < -100000 || gd > 100000 || gd < ga - 4) return list(base, list(), null, null)
	var/ma = ga - 3
	while(ma <= gd + 3 && ChainStampOut(cs, e0 + S * ma, e1 + S * ma)) ma++
	var/md = gd + 3
	while(md >= ma && ChainStampOut(cs, e0 + S * md, e1 + S * md)) md--
	if(md < ma) return list(base, list(), null, null)
	var/ilo = null
	var/ihi = null
	var/mi = ma
	while(mi <= md && !ChainStampIn(cs, e0 + S * mi, e1 + S * mi)) mi++
	if(mi <= md)
		ilo = mi
		var/mj = md
		while(mj >= mi && !ChainStampIn(cs, e0 + S * mj, e1 + S * mj)) mj--
		ihi = mj
	var/list/edges = list()
	var/elo = isnull(ilo) ? md : (ilo - 1)
	for(var/m = ma to elo)
		edges += m
	if(!isnull(ihi))
		for(var/m2 = ihi + 1 to md)
			edges += m2
	return list(base, edges, ilo, ihi)

/datum/beamfx/proc/ChainEdgeSpecs(list/rep, list/plan, kind)
	var/list/out = list()
	var/base = plan[1]
	var/list/ed = plan[2]
	var/ilo = plan[3]
	var/nl = 0
	for(var/m in ed)
		if(isnull(ilo) || m < ilo) nl++
	for(var/i = 1 to ed.len)
		var/m = ed[i]
		var/key
		if(i <= nl) key = "L[i - 1]"
		else key = "H[ed.len - i]"
		out[key] = list(RLStampSpec(m, base + S * m, rep, kind), rep[RL92_CUTS])
	return out

/datum/beamfx/proc/ChainScrollXform(a, off)
	var/ca = cos(a)
	var/sa = sin(a)
	var/d0 = dstart + off
	return matrix(ca, -sa, WX(d0) - (ch.rx + rl_carB / 2), sa, ca, WY(d0) - (ch.ry + rl_carB / 2))

/datum/beamfx/proc/ChainKidXform(obj/energyfx/K, m, sx, sy, list/stt)
	return matrix(sx, 0, S * m + sx * stt[3] + (rl_carB / 2 - K.fx_w / 2), 0, sy, sy * stt[4] + (rl_carB / 2 - K.fx_h / 2))

/datum/beamfx/proc/ChainKid(datum/efx_chbody/BD, m, sx, sy)
	var/list/stamps = rl.A["stamps"]
	var/list/pr = stamps[BeamFXMod(m, rl.np) + 1]
	var/si = pr[BD.kind + 1]
	if(si < 0) return null
	var/list/stt = rl.S[si + 1]
	var/file = stt[1] + 1
	var/obj/energyfx/K = ChainGet(BD.kind ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, BD.scr)
	if(!K) return null
	ChainLook0(K, BD.kind, 0)
	ChainFam(K, rl.fams[file], stt[2], BD.kind)
	ChainZ(K, BD.kind ? 0 : 4 + (m + 500) * 0.00001 + RLZo())
	ChainXf(K, ChainKidXform(K, m, sx, sy, stt))
	ChainAl(K, 0)
	return K

/datum/beamfx/proc/ChainBodyNew(kind)
	var/datum/efx_chbody/BD = new
	BD.kind = kind
	var/obj/energyfx/M = ChainGet(kind ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, ch.root)
	if(!M) return null
	ChainLook0(M, kind, 0)
	M.filters = null
	ChainBlank(M)
	ChainZ(M, kind ? 0 : 4 + RLZo())
	ChainAl(M, 255)
	BD.scr = M
	return BD

/datum/beamfx/proc/ChainBodyKids(datum/efx_chbody/BD, sx, sy, mlo, mhi)
	if(isnull(BD.lsx) || abs(BD.lsx - sx) > 0.000001 || abs(BD.lsy - sy) > 0.000001)
		for(var/key in BD.kids)
			ChainPut(BD.kids[key])
		BD.kids = list()
		BD.kloop = list()
		BD.vlo = null
		BD.vhi = null
		BD.lsx = sx
		BD.lsy = sy
	if(isnull(mlo)) return
	for(var/m = mlo to mhi)
		if(BD.kids["[m]"]) continue
		var/obj/energyfx/K = ChainKid(BD, m, sx, sy)
		if(K) BD.kids["[m]"] = K

/datum/beamfx/proc/ChainKidVis(datum/efx_chbody/BD, list/p1, list/p2, mode)
	var/c0 = BD.vlo
	var/c1 = BD.vhi
	var/a0
	var/a1
	var/b0
	var/b1
	if(mode == 3)
		a0 = c0
		a1 = c1
	else if(p1)
		a0 = p1[3]
		a1 = p1[4]
	if(mode == 1)
		b0 = a0
		b1 = a1
	else if(p2)
		b0 = p2[3]
		b1 = p2[4]
	var/lo = null
	var/hi = null
	var/l2 = null
	var/h2 = null
	var/full = (isnull(c0) || isnull(a0) || isnull(b0)) ? 1 : 0
	for(var/v in list(c0, a0, b0))
		if(isnull(v)) continue
		lo = isnull(lo) ? v : min(lo, v)
		l2 = isnull(l2) ? v : max(l2, v)
	for(var/w in list(c1, a1, b1))
		if(isnull(w)) continue
		hi = isnull(hi) ? w : max(hi, w)
		h2 = isnull(h2) ? w : min(h2, w)
	if(isnull(lo))
		BD.vlo = b0
		BD.vhi = b1
		return
	var/list/cand = list()
	if(full)
		for(var/m = lo to hi)
			cand += m
	else
		for(var/m2 = lo to l2)
			cand += m2
		for(var/m3 = h2 to hi)
			if(m3 > l2) cand += m3
	for(var/m in cand)
		var/obj/energyfx/K = BD.kids["[m]"]
		if(!K) continue
		var/cur = (!isnull(c0) && m >= c0 && m <= c1) ? 1 : 0
		var/va = (!isnull(a0) && m >= a0 && m <= a1) ? 1 : 0
		var/vb = (!isnull(b0) && m >= b0 && m <= b1) ? 1 : 0
		if(va == vb)
			if(cur != va) ChainAl(K, va ? 255 : 0)
		else
			ChainSeq(K, list(list(4, 0.25, null, null, 0, null, va ? 255 : 0), list(4, 0.25, null, null, 0, null, vb ? 255 : 0)), 1)
	BD.vlo = b0
	BD.vhi = b1

/datum/beamfx/proc/ChainBody(list/D1, list/D2, mode, f1)
	for(var/kind = 0 to 1)
		var/list/r1 = (D1 && D1[2]) ? D1[2] : null
		var/list/r2 = (D2 && D2[2]) ? D2[2] : null
		var/list/rep1 = (r1 && r1.len > kind) ? r1[kind + 1] : null
		var/list/rep2 = (r2 && r2.len > kind) ? r2[kind + 1] : null
		var/datum/efx_chbody/BD = ch.bodies["[kind]"]
		if(!BD)
			if(!rep1 && !rep2) continue
			BD = ChainBodyNew(kind)
			if(!BD) continue
			ch.bodies["[kind]"] = BD
		ChainBodyApply(BD, rep1, f1, rep2, f1 + 1, mode)

/datum/beamfx/proc/ChainBodyApply(datum/efx_chbody/BD, list/rep1, d1, list/rep2, d2, mode)
	var/list/a = (mode == 3) ? null : rep1
	var/list/b = (mode == 1) ? rep1 : rep2
	if(BD.looping)
		ChainHalt(BD.scr)
		BD.looping = 0
		BD.soff = null
	var/list/p1 = a ? ChainBodyPlan(a, d1) : null
	var/list/p2 = null
	if(b) p2 = (mode == 1) ? p1 : ChainBodyPlan(b, d2)
	var/list/ref = a ? a : b
	if(ref)
		var/mlo = null
		var/mhi = null
		for(var/list/p in list(p1, p2))
			if(isnull(p[3])) continue
			mlo = isnull(mlo) ? p[3] : min(mlo, p[3])
			mhi = isnull(mhi) ? p[4] : max(mhi, p[4])
		ChainBodyKids(BD, ref[RL92_SX], ref[RL92_SY], mlo, mhi)
		var/o1 = a ? ChainOff(d1) : BD.soff
		var/o2 = o1
		if(mode != 1 && b) o2 = ChainOff(d2)
		var/ang1 = ref[RL92_ANG]
		if(isnull(o1) || abs(o1 - o2) < 0.000001)
			if(isnull(BD.soff) || abs(BD.soff - o2) > 0.000001 || !BD.shown) ChainXf(BD.scr, ChainScrollXform(ang1, o2))
		else
			ChainSeq(BD.scr, list(list(2, 0.25, null, null, 0, ChainScrollXform(ang1, o1), null), list(2, 0.25, null, null, 0, ChainScrollXform(ang1, o2), null)), 1)
		BD.soff = o2
		BD.shown = 1
	else if(BD.shown && mode != 3)
		ChainXf(BD.scr, matrix(1, 0, 100000, 0, 1, 100000))
		BD.shown = 0
		BD.soff = null
	ChainKidVis(BD, p1, p2, mode)
	var/list/E1 = (a && p1) ? ChainEdgeSpecs(a, p1, BD.kind) : list()
	var/list/E2 = list()
	if(b && p2) E2 = (mode == 1) ? E1 : ChainEdgeSpecs(b, p2, BD.kind)
	var/list/keys = list()
	for(var/key in E1)
		keys[key] = 1
	for(var/key in E2)
		keys[key] = 1
	for(var/key in BD.slots)
		keys[key] = 1
	for(var/key in keys)
		var/list/e1 = E1[key]
		var/list/e2 = E2[key]
		var/datum/efx_chpiece/PS = BD.slots[key]
		if(!PS)
			var/list/first = (mode == 3) ? e2 : (e1 ? e1 : e2)
			if(!first) continue
			PS = ChainPieceNew("b[BD.kind]:[key]", first[1], first[2])
			if(!PS) continue
			BD.slots[key] = PS
		ChainLook(PS, (mode == 3) ? null : e1, e2, mode)
		if(!PS.shown && PS.idle >= 3)
			ChainPieceFree(PS)
			BD.slots -= key

/datum/beamfx/proc/ChainBoostNew(datum/efx_chpiece/PC)
	var/obj/energyfx/G = ChainGet(/obj/energyfx/rlsharp, ch.root)
	if(!G) return
	ChainLook0(G, 1, 0)
	G.filters = null
	ChainBlank(G)
	ChainZ(G, 0)
	ChainAl(G, 255)
	PC.boost = G
	ChainReparent(PC.O, G)
	PC.O.fx_bx = ch.rx + PC.O.fx_w / 2
	PC.O.fx_by = ch.ry + PC.O.fx_h / 2
	PC.bst = 1

/datum/beamfx/proc/ChainBoostM(b, x, y)
	var/cx = ch.rx + rl_carB / 2
	var/cy = ch.ry + rl_carB / 2
	return matrix(b, 0, (1 - b) * (x - cx), 0, b, (1 - b) * (y - cy))

/datum/beamfx/proc/ChainBoostSet(datum/efx_chpiece/PC, b, x, y)
	var/obj/energyfx/G = PC.boost
	if(!G) return
	if(abs(b - 1) < 0.000001)
		if(PC.bst != 1)
			ChainXf(G, matrix())
			PC.bst = 1
		return
	if(PC.bst == b && PC.bst_ax == x && PC.bst_ay == y) return
	ChainXf(G, ChainBoostM(b, x, y))
	PC.bst = b
	PC.bst_ax = x
	PC.bst_ay = y

/datum/beamfx/proc/ChainBoostTwo(datum/efx_chpiece/PC, list/b1, list/b2)
	var/obj/energyfx/G = PC.boost
	if(!G) return
	ChainSeq(G, list(list(2, 0.25, null, null, 0, ChainBoostM(b1[1], b1[2], b1[3]), null), list(2, 0.25, null, null, 0, ChainBoostM(b2[1], b2[2], b2[3]), null)), 1)
	PC.bst = b2[1]
	PC.bst_ax = b2[2]
	PC.bst_ay = b2[3]

/datum/beamfx/proc/ChainFlash(list/D1, list/D2, mode)
	var/list/S1 = D1 ? D1[1] : null
	var/list/S2 = D2 ? D2[1] : null
	var/list/b1 = D1 ? D1[4] : null
	var/list/b2 = D2 ? D2[4] : null
	for(var/tg in list("flare", "flash"))
		var/key = "[tg]|1"
		var/list/e1 = S1 ? S1[key] : null
		var/list/e2 = S2 ? S2[key] : null
		var/datum/efx_chpiece/PC = ch.pieces[key]
		if(!PC)
			var/list/first = (mode == 3) ? e2 : (e1 ? e1 : e2)
			if(!first) continue
			PC = ChainPieceNew(key, first[1], first[2])
			if(!PC) continue
			ch.pieces[key] = PC
			if(tg == "flash") ChainBoostNew(PC)
		if(tg == "flash" && PC.boost)
			var/list/ba = (mode == 3 || !e1) ? b2 : b1
			var/list/bb = (mode == 1) ? b1 : b2
			if(ba && bb && mode == 2 && e1 && e2 && abs(ba[1] - bb[1]) > 0.000001) ChainBoostTwo(PC, ba, bb)
			else if(bb) ChainBoostSet(PC, bb[1], bb[2], bb[3])
			else if(ba) ChainBoostSet(PC, ba[1], ba[2], ba[3])
		ChainLook(PC, e1, e2, mode)
		if(!PC.shown && PC.idle >= 3)
			ChainPieceFree(PC)
			ch.pieces -= key

/datum/beamfx/proc/ChainEls(list/D1, list/D2, mode)
	var/list/E1 = D1 ? D1[3] : null
	var/list/E2 = D2 ? D2[3] : null
	var/list/keys = list()
	for(var/list/E in list(E1, E2))
		for(var/key in E)
			keys[key] = 1
	for(var/key in ch.els)
		keys[key] = 1
	for(var/key in keys)
		var/list/e1 = E1 ? E1[key] : null
		var/list/e2 = E2 ? E2[key] : null
		var/datum/efx_chpiece/PE = ch.els[key]
		if(!PE)
			var/list/first = (mode == 3) ? e2 : (e1 ? e1 : e2)
			if(!first) continue
			PE = ChainPieceNew(key, first[1], first[2])
			if(!PE) continue
			ch.els[key] = PE
		ChainLook(PE, e1, e2, mode)
		if(!PE.shown && PE.idle >= 3)
			ChainPieceFree(PE)
			ch.els -= key

/datum/beamfx/proc/ChainSurgeRec(datum/bfx_obj/o, t, fi, xh, list/Hd, firing)
	var/surges_on = isnull(rl.P["surges"]) ? 1 : rl.P["surges"]
	if(!surges_on || !rl.B) return null
	var/list/P = rl.P
	var/list/Sg = rl.B["surge"]
	var/list/sa_ = RLP("surge_a", list(8, 40))
	var/age = t - o.t0
	if(age < 0) return null
	var/dd = o.d0 + o.v * age
	var/front = xh - Hd["R"] * 0.4 * rl_st
	if(dd >= front) return null
	if(!firing && dd < Back(t, fi) - 30) return null
	var/a = BeamFXSstep(mz + sa_[1] * rl_st, mz + sa_[2] * rl_st, dd) * (1 - BeamFXSstep(front - 10 * rl_st, front, dd))
	if(a <= 0.002) return null
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
	return list(sfr[BeamFXMod(o.seq, sfr.len) + 1], WX(hp), WY(hp), ang, rl_st, 0.85 + 0.15 * o.scale, a * min(1, o.scale), 0, 0, 1, list(list(WX(dc), WY(dc), ax, ay, soft)), "surge", null, "su[o.uid]", null, 0)

/datum/beamfx/proc/ChainImpact(f1)
	var/list/I = EFXC_IMPACT[rl.key]
	if(ch.imp_on && ch.imp_loopk == k) ChainImpactLoop(I)
	var/want = (I && !clash_mode && isnull(end_t) && !isnull(t_hit) && FT(f1 + 1) >= t_hit && Struggling(f1, 0)) ? 1 : 0
	if(!want)
		if(ch.imp_on && !ch.imp_out) ChainImpactOut()
		if(ch.imp_on && ch.imp_out && k >= ch.imp_out) ChainImpactHide()
		return
	var/list/an = ChainImpactAnchor(f1)
	if(!ch.imp_on) ChainImpactShow(I, an[1], an[2], an[3])
	else if(abs(an[1] - ch.imp_x) > 0.001 || abs(an[2] - ch.imp_y) > 0.001 || abs(an[3] - ch.imp_s) > 0.000001) ChainImpactMove(I, an[1], an[2], an[3])

/datum/beamfx/proc/ChainImpactAnchor(fi)
	var/t = FT(fi)
	var/c = Contact(t, fi, 0)
	var/Hrv = Hr(t, fi, 0)
	var/cd = isnull(c) ? (Hrv + EFX92_CONTACT) : c
	if(abs(rl_k - 1) < 0.000001) return list(WX(cd), WY(cd), 1)
	var/st = Struggling(fi, 0)
	var/nd = RLDraw(fi)
	var/list/hg = RLHeadGeom(t, fi, Hrv, st, nd)
	var/list/Hd = hg[1]
	var/list/sn = RLSnap(hg[3], t, fi)
	var/hf = sn[1] + Hd["R"] * Hd["sq"] * rl_st
	var/list/Ph = rl.P["heads"]
	var/list/hl = Ph[Ph.len]
	var/kc = EFX92KbOf(rl_k, rl.P["rp"], hl[1])
	var/dd = hf + kc * (cd - hf)
	return list(WX(dd), WY(dd), kc)

/datum/beamfx/proc/ChainImpactXform(list/I, x, y, s)
	var/w = I[4]
	var/h = I[5]
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/ox = (I[2] + w / 2) * s
	var/oy = (I[3] + h / 2) * s
	return matrix(ca * s, -sa * s, x + ca * ox - sa * oy - (ch.rx + w / 2), sa * s, ca * s, y + sa * ox + ca * oy - (ch.ry + h / 2))

/datum/beamfx/proc/ChainImpactObj(kind)
	var/obj/energyfx/O = kind ? ch.imp_l : ch.imp_p
	if(O) return O
	O = ChainGet(kind ? /obj/energyfx/rlsharp : /obj/energyfx/rlpaint, ch.root)
	if(!O) return null
	ChainLook0(O, kind, 0)
	if(kind) ch.imp_l = O
	else ch.imp_p = O
	return O

/datum/beamfx/proc/ChainImpactShow(list/I, x, y, s)
	var/N = I[8]
	for(var/kind = 0 to 1)
		var/obj/energyfx/O = ChainImpactObj(kind)
		if(!O) return
		var/list/ons = kind ? I[10] : I[9]
		var/pre = kind ? "r" : "q"
		ChainArt(O, ons[1], "[pre]0", I[4], I[5], "IMP:[rl.key]:[kind]")
		ChainZ(O, kind ? 0 : 5.4 + RLZo())
		ChainXf(O, ChainImpactXform(I, x, y, s))
		ChainAl(O, 255)
		var/list/steps = list()
		for(var/i = 0 to N - 1)
			steps += list(list(1, 0.25, ons[i + 1], "[pre][i]", -1, null, null))
		ChainSeq(O, steps, 1)
	ch.imp_on = 1
	ch.imp_out = 0
	ch.imp_k0 = k
	ch.imp_loopk = k + N / 2
	ch.imp_x = x
	ch.imp_y = y
	ch.imp_s = s

/datum/beamfx/proc/ChainImpactLoop(list/I)
	var/L = I[1]
	var/j0 = I[11]
	for(var/kind = 0 to 1)
		var/obj/energyfx/O = kind ? ch.imp_l : ch.imp_p
		if(!O) continue
		var/list/ics = kind ? I[7] : I[6]
		var/pre = kind ? "l" : "p"
		var/list/steps = list()
		for(var/i = 0 to L - 1)
			var/j = BeamFXMod(j0 + i, L)
			steps += list(list(1, 0.5, ics[j + 1], "[pre][j]", -1, null, null))
		ChainSeq(O, steps, -1)
	ch.imp_loopk = -1

/datum/beamfx/proc/ChainImpactMove(list/I, x, y, s)
	for(var/obj/energyfx/O in list(ch.imp_p, ch.imp_l))
		ChainXf(O, ChainImpactXform(I, x, y, s))
	ch.imp_x = x
	ch.imp_y = y
	ch.imp_s = s

/datum/beamfx/proc/ChainImpactOut()
	for(var/obj/energyfx/O in list(ch.imp_p, ch.imp_l))
		ChainFade(O, 2.5)
	ch.imp_out = k + 6

/datum/beamfx/proc/ChainImpactHide()
	for(var/obj/energyfx/O in list(ch.imp_p, ch.imp_l))
		ChainHalt(O)
		ChainAl(O, 0)
	ch.imp_on = 0
	ch.imp_out = 0
	ch.imp_loopk = -1

/datum/beamfx/proc/ChainSpecks(list/D)
	if(!D || rl_pierce) return
	var/list/W = D[5]
	var/list/reps = D[2]
	var/Hrv = W[8]
	var/lo = isnull(release_t) ? (mz + 24) : (W[9] + 12)
	var/L = (reps && !W[5] && !s_dead) ? max(0, Hrv - lo) : 0
	if(abs(L - ch.spk_len) > 8 || (L <= 0 && ch.spk_len > 0))
		ChainSpeckSet(lo, L)
		ch.spk_len = L
	var/want = (!isnull(t_hit) && Struggling(2 * k, 0) && isnull(end_t)) ? 1 : 0
	if(want != ch.glint_on)
		ChainGlintSet(want)
		ch.glint_on = want

/datum/beamfx/proc/ChainSpeckSet(lo, L)
	var/list/gs = rl_gspark
	if(!gs || !gs.len) return
	for(var/side in list(1, -1))
		var/obj/energyfx/E = (side > 0) ? ch.spk1 : ch.spk2
		if(L < 40)
			if(E && E.particles)
				var/particles/beamfx_speck/PP0 = E.particles
				PP0.spawning = 0
			continue
		if(!E)
			E = ChainGet(/obj/energyfx/rlsharp, ch.root)
			if(!E) return
			var/list/stt = rl.S[gs[1] + 1]
			var/list/fam = BEAMFX_FAM[rl.fams[stt[1] + 1]]
			E.icon = null
			E.blend_mode = BLEND_ADD
			E.color = null
			E.alpha = 255
			var/particles/beamfx_speck/PP = new
			PP.icon = fam[1]
			var/list/sts = list()
			for(var/idx in gs)
				var/list/s2 = rl.S[idx + 1]
				sts += s2[2]
			PP.icon_state = sts
			PP.lifespan = generator("num", 2.2, 4.2)
			PP.fadein = 1
			PP.fade = 1.5
			PP.friction = 0
			PP.grow = list(0, 0)
			PP.scale = list(0.85, 0.85)
			PP.bound1 = vector(-4000, -4000, -10)
			PP.bound2 = vector(4000, 4000, 10)
			E.particles = PP
			if(side > 0) ch.spk1 = E
			else ch.spk2 = E
		var/particles/beamfx_speck/P2 = E.particles
		var/list/sl = RLP("spark_lat", list(1, 7))
		var/rp = rl.P["rp"]
		P2.width = ceil(L + 2 * 64)
		P2.height = 96
		P2.count = ceil(RLP("spark_rate", 0.25) * L / 32 * 10) + 20
		P2.spawning = RLP("spark_rate", 0.25) * L / 32
		P2.position = generator("box", vector(-L / 2, side * (rp + sl[1]), 0), vector(L / 2 - 12, side * (rp + sl[2]), 0))
		P2.velocity = generator("box", vector(Vs * 0.025, side * 0.4, 0), vector(Vs * 0.07, side * 1.2, 0))
		E.transform = matrix(cos(ang), -sin(ang), WX(lo + L / 2) - ch.rx - 16, sin(ang), cos(ang), WY(lo + L / 2) - ch.ry - 16)
		energyfx_chain_issue++

/datum/beamfx/proc/ChainGlintSet(on)
	var/list/gs = rl_gspark
	if(!gs || !gs.len) return
	if(!on)
		if(ch.glint && ch.glint.particles)
			var/particles/beamfx_speck/PP0 = ch.glint.particles
			PP0.spawning = 0
		return
	var/c = Contact(FT(2 * k), 2 * k, 0)
	if(isnull(c)) return
	var/obj/energyfx/E = ch.glint
	if(!E)
		E = ChainGet(/obj/energyfx/rlsharp, ch.root)
		if(!E) return
		E.icon = null
		E.blend_mode = BLEND_ADD
		E.color = null
		E.alpha = 255
		var/list/stt = rl.S[gs[1] + 1]
		var/list/fam = BEAMFX_FAM[rl.fams[stt[1] + 1]]
		var/particles/beamfx_speck/PP = new
		PP.icon = fam[1]
		var/list/sts = list()
		for(var/idx in gs)
			var/list/s2 = rl.S[idx + 1]
			sts += s2[2]
		PP.icon_state = sts
		PP.width = 400
		PP.height = 400
		PP.count = 120
		PP.lifespan = generator("num", 2.5, 5)
		PP.fadein = 0.3
		PP.fade = 2
		PP.friction = 0.15
		PP.grow = list(-0.05, -0.05)
		PP.scale = list(0.95, 0.95)
		PP.position = generator("circle", 6, 14)
		PP.velocity = generator("circle", 9, 26)
		E.particles = PP
		ch.glint = E
	var/list/G = rl.P["glint"]
	var/particles/beamfx_speck/P2 = E.particles
	P2.spawning = G["per_tick"] * 2
	E.transform = matrix(1, 0, WX(c - 4) - ch.rx - 16, 0, 1, WY(c - 4) - ch.ry - 16)
	energyfx_chain_issue++

/datum/beamfx/proc/ChainQuiet(v1, v2)
	if(v2 != v1 || BeamFXMod(v1, 2)) return 0
	if(!isnull(release_t) || !isnull(dead_t) || !isnull(end_t) || clash_mode) return 0
	if(hlog_h.len < 3) return 0
	if(abs(hlog_h[hlog_h.len] - hlog_h[hlog_h.len - 2]) > 0.001) return 0
	var/t = FT(v1)
	if(t - t0 < 0.3) return 0
	if(!isnull(t_hit) && t < t_hit + 0.3) return 0
	var/list/hl = Holds()
	for(var/f = v1, f <= v1 + 26, f++)
		if(Q(f, hl) != f - BeamFXMod(f, 2)) return 0
	return 1

/datum/beamfx/proc/ChainSig(f1)
	return list(hlog_h.len ? hlog_h[hlog_h.len] : null, Struggling(f1, 0), t_hit, release_t, release_f, fly_t, swallow_t, end_t, end_H, dead_t, s_dead, s_blocked, s_clash, clash_mode, partner ? 1 : 0, s_off, target_d, st_f, rm_ih, rm_ir, Ox, Oy, d, ang, mz, rl_k, rl_st)

/datum/beamfx/proc/ChainSigEq(list/a)
	var/list/b = ch.sig
	if(!a || !b || a.len != b.len) return 0
	for(var/i = 1 to a.len)
		var/x = a[i]
		var/y = b[i]
		if(isnum(x) && isnum(y))
			if(abs(x - y) > 0.000001) return 0
		else if(x != y) return 0
	return 1

/datum/beamfx/proc/ChainAhead(list/frames, v1, n)
	while(frames.len < n)
		var/f = v1 + 2 * frames.len
		var/list/W = ChainFlow(f, null)
		if(!W) return 0
		var/list/D = ChainDraw(f, W)
		frames += list(D)
	return 1

/datum/beamfx/proc/ChainPeriod(list/frames, key, v1)
	var/list/F0 = frames[1]
	var/list/S0 = F0[1]
	var/list/e = S0[key]
	for(var/p in list(12, 24, 36, 48))
		if(!ChainAhead(frames, v1, p + 2)) return 0
		var/list/Fa = frames[p + 1]
		var/list/Fb = frames[2]
		var/list/Fc = frames[p + 2]
		var/list/Sa = Fa[1]
		var/list/Sb = Fb[1]
		var/list/Sc = Fc[1]
		if(!ChainNear(e, Sa[key]) || !ChainNear(Sb[key], Sc[key])) continue
		for(var/j = 1 to p - 1)
			var/list/Fj = frames[j + 1]
			var/list/Sj = Fj[1]
			var/list/ej = Sj[key]
			if(!e && !ej) continue
			if(!e || !ej || !ChainCutsEq(e[2], ej[2])) return 0
		return p
	return 0

/datum/beamfx/proc/ChainRepEq(list/a, list/b)
	if(!a || !b) return a == b
	if(a.len != b.len) return 0
	for(var/i = 1 to a.len)
		var/list/x = a[i]
		var/list/y = b[i]
		if(!ChainCutsEq(x[RL92_CUTS], y[RL92_CUTS])) return 0
		if(abs(x[RL92_ANG] - y[RL92_ANG]) > 0.0001 || abs(x[RL92_SX] - y[RL92_SX]) > 0.000001 || abs(x[RL92_SY] - y[RL92_SY]) > 0.000001 || abs(x[RL92_AL] - y[RL92_AL]) > 0.000001) return 0
	return 1

/datum/beamfx/proc/ChainFrontOf(list/D)
	var/list/W = D[5]
	var/list/Hd = W[3]
	return W[2] - Hd["R"] * 0.4 * rl_st

/datum/beamfx/proc/ChainGoStatic(v1)
	var/list/frames = list()
	if(!ChainAhead(frames, v1, 14))
		ch.try_after = k + 4
		return
	var/list/F0 = frames[1]
	var/list/F12 = frames[13]
	var/list/S0 = F0[1]
	for(var/j = 2 to 13)
		var/list/Fj = frames[j]
		if(!ChainRepEq(F0[2], Fj[2]))
			ch.try_after = k + 4
			return
	var/list/W0 = F0[5]
	var/list/W12 = F12[5]
	if(W0[4] != W12[4] || abs(ChainFrontOf(F0) - ChainFrontOf(F12)) > 0.01)
		ch.try_after = k + 4
		return
	var/list/keys = ChainGroupKeys(S0, null)
	var/list/per = list()
	for(var/key in keys)
		var/p = ChainPeriod(frames, key, v1)
		if(!p)
			ch.try_after = k + 4
			return
		per[key] = p
	var/list/bplan = ChainBodyStaticPlan(frames, v1)
	if(!bplan)
		ch.try_after = k + 4
		return
	var/datum/efx_chpiece/PF = ch.pieces["flash|1"]
	var/flash = (PF && S0["flash|1"]) ? 1 : 0
	if(flash && !PF.jit) ChainJitNew(PF)
	if(flash && !PF.jit)
		ch.try_after = k + 4
		return
	var/list/st = list()
	var/list/raw = list()
	for(var/j = 1 to 12)
		var/list/Fj2 = frames[j]
		var/list/Wj = Fj2[5]
		st += list(list(Wj[2], Wj[3], Wj[4], Wj[9]))
		raw += list(Wj[1])
	ch.st_fr = st
	ch.st_raw = raw
	ch.static_f0 = v1
	for(var/key in keys)
		var/datum/efx_chpiece/PC = ch.pieces[key]
		if(!PC) continue
		if(!S0[key])
			ChainPieceFree(PC)
			ch.pieces -= key
			continue
		var/list/loopf = list()
		for(var/j = 1 to per[key])
			var/list/Fj3 = frames[j]
			var/list/Sj = Fj3[1]
			var/list/ej = Sj[key]
			loopf += list(ej[1])
		ChainPieceLoop(PC, loopf)
	ChainBodyStatic(bplan, v1)
	if(flash) ChainFlashStatic(PF, v1)
	ChainElStaticAll(v1)
	ch.sig = ChainSig(2 * k)
	ch.static_on = 1
	energyfx_chain_static_in++

/datum/beamfx/proc/ChainBodyStaticPlan(list/frames, v1)
	var/list/out = list()
	var/list/F0 = frames[1]
	var/list/r0 = F0[2]
	for(var/kind = 0 to 1)
		var/list/rep0 = (r0 && r0.len > kind) ? r0[kind + 1] : null
		var/datum/efx_chbody/BD = ch.bodies["[kind]"]
		if(!rep0)
			out += list(null)
			continue
		if(!BD) return null
		var/list/plans = list()
		for(var/j = 0 to 11)
			plans += list(ChainBodyPlan(rep0, v1 + 2 * j))
		var/list/p0 = plans[1]
		var/list/ed0 = p0[2]
		var/b0 = p0[1]
		for(var/j = 2 to 12)
			var/list/pj = plans[j]
			var/list/edj = pj[2]
			if(edj.len != ed0.len) return null
			for(var/i = 1 to ed0.len)
				if(abs((pj[1] + S * edj[i]) - (b0 + S * ed0[i])) > 0.01) return null
		out += list(list(rep0, plans))
	return out

/datum/beamfx/proc/ChainBodyStatic(list/bplan, v1)
	for(var/kind = 0 to 1)
		var/datum/efx_chbody/BD = ch.bodies["[kind]"]
		if(!BD) continue
		var/list/bp = bplan[kind + 1]
		if(!bp)
			if(BD.shown)
				ChainXf(BD.scr, matrix(1, 0, 100000, 0, 1, 100000))
				BD.shown = 0
			for(var/ks in BD.slots)
				ChainPieceFree(BD.slots[ks])
			BD.slots = list()
			continue
		var/list/rep = bp[1]
		var/list/plans = bp[2]
		var/mlo = null
		var/mhi = null
		for(var/list/p in plans)
			if(isnull(p[3])) continue
			mlo = isnull(mlo) ? p[3] : min(mlo, p[3])
			mhi = isnull(mhi) ? p[4] : max(mhi, p[4])
		ChainBodyKids(BD, rep[RL92_SX], rep[RL92_SY], mlo, mhi)
		var/list/ss = list()
		for(var/j = 0 to 11)
			ss += list(list(2, 0.5, null, null, 0, ChainScrollXform(rep[RL92_ANG], ChainOff(v1 + 2 * j)), null))
		ChainSeq(BD.scr, ss, -1)
		BD.looping = 1
		BD.shown = 1
		BD.soff = ChainOff(v1 + 22)
		for(var/key in BD.kids)
			var/m = text2num(key)
			var/obj/energyfx/K = BD.kids[key]
			var/list/vis = list()
			var/n = 0
			for(var/list/p2 in plans)
				var/v = (!isnull(p2[3]) && m >= p2[3] && m <= p2[4]) ? 1 : 0
				vis += v
				n += v
			if(BD.kloop[key]) ChainHalt(K)
			if(n == 12 || n == 0)
				ChainAl(K, n ? 255 : 0)
				BD.kloop -= key
			else
				var/list/ks2 = list()
				for(var/v2 in vis)
					ks2 += list(list(4, 0.5, null, null, 0, null, v2 ? 255 : 0))
				ChainSeq(K, ks2, -1)
				BD.kloop[key] = 1
		var/list/pl = plans[12]
		BD.vlo = pl[3]
		BD.vhi = pl[4]
		var/list/eps = list()
		for(var/list/pj in plans)
			eps += list(ChainEdgeSpecs(rep, pj, kind))
		var/list/want = eps[1]
		for(var/key2 in BD.slots.Copy())
			if(want[key2]) continue
			ChainPieceFree(BD.slots[key2])
			BD.slots -= key2
		for(var/key3 in want)
			var/list/e = want[key3]
			var/datum/efx_chpiece/PS = BD.slots[key3]
			if(!PS)
				PS = ChainPieceNew("b[kind]:[key3]", e[1], e[2])
				if(!PS) continue
				BD.slots[key3] = PS
			ChainPieceStop(PS)
			ChainCarSync(PS, e[1], e[2])
			var/zl = 0
			if(!kind)
				var/rank = text2num(copytext(key3, 2))
				if(copytext(key3, 1, 2) == "L") zl = 4 + ((isnull(mlo) ? 0 : mlo) - 40 + rank + 500) * 0.00001 + RLZo()
				else zl = 4 + ((isnull(mhi) ? 0 : mhi) + 40 - rank + 500) * 0.00001 + RLZo()
			if(PS.car.layer != zl) ChainZ(PS.car, zl)
			if(PS.O.layer != zl) ChainZ(PS.O, zl)
			var/list/sl = list()
			var/list/lastsp
			for(var/list/epj in eps)
				var/list/ek = epj[key3]
				var/list/sp = ek ? ek[1] : null
				sl += list(ChainStepOf(PS, sp, 0.5))
				lastsp = sp
			ChainSeq(PS.O, sl, -1)
			PS.looping = 1
			PS.shown = 1
			PS.idle = 0
			PS.spec = lastsp

/datum/beamfx/proc/ChainJitNew(datum/efx_chpiece/PC)
	var/obj/energyfx/G = PC.boost
	if(!G) return
	var/obj/energyfx/J = ChainGet(/obj/energyfx/rlsharp, G)
	if(!J) return
	ChainLook0(J, 1, 0)
	J.filters = null
	ChainBlank(J)
	ChainZ(J, 0)
	ChainAl(J, 255)
	PC.jit = J
	ChainReparent(PC.O, J)

/datum/beamfx/proc/ChainFlashStatic(datum/efx_chpiece/PC, v1)
	var/list/FL = rl.B["flash"]
	var/list/FA = FL["frames"]
	var/fres = FL["res"]
	if(isnull(fres)) fres = 1
	var/obj/energyfx/J = PC.jit
	var/t = FT(v1)
	var/c = Contact(t, v1, 0)
	var/cd = isnull(c) ? (Hr(t, v1, 0) + EFX92_CONTACT) : c
	var/k0 = rl.P["flash_k"] / fres
	var/n = FA.len
	var/list/raw = list()
	RLRec(raw, FA[1], WX(cd - 3), WY(cd - 3), 0, k0, k0, 0.9, 0, 0, 1, null, "flash", "fs")
	if(abs(rl_k - 1) > 0.000001)
		var/list/rr0 = ch.st_raw[1]
		var/list/rr = rr0.Copy()
		rr += raw
		rr = ChainWiden(rr, v1, t)
		raw = list()
		for(var/list/r0 in rr)
			if(r0[RL92_TAG] == "flash") raw += list(r0)
	if(!raw.len) return
	var/list/r = raw[1]
	var/fx = r[RL92_X]
	var/fy = r[RL92_Y]
	ChainPieceStop(PC)
	var/list/steps = list()
	var/list/last
	for(var/j = 0 to n - 1)
		r[RL92_ST] = FA[BeamFXMod(floor((v1 + 2 * j - fi0) / 2), n) + 1]
		var/list/sp = ChainSpec(r, 0)
		steps += list(ChainStepOf(PC, sp, 0.5))
		last = sp
	ChainSeq(PC.O, steps, -1)
	var/list/js = list()
	var/f0m = BeamFXMod(fi0, 97) * 31
	for(var/j = 0 to 96)
		var/s = 0.88 + 0.28 * BeamFXMod(BeamFXMod(v1 + 2 * j, 97) * 62 + f0m, 97) / 97
		js += list(list(2, 0.5, null, null, 0, ChainBoostM(s, fx, fy), null))
	ChainSeq(J, js, -1)
	PC.looping = 1
	PC.shown = 1
	PC.idle = 0
	PC.spec = last
	PC.bst_ax = fx
	PC.bst_ay = fy

/datum/beamfx/proc/ChainPhase(f)
	return ch.st_fr[BeamFXMod((f - ch.static_f0) / 2, 12) + 1]

/datum/beamfx/proc/ChainPhaseRaw(f)
	return ch.st_raw[BeamFXMod((f - ch.static_f0) / 2, 12) + 1]

/datum/beamfx/proc/ChainElAll()
	var/list/out = list()
	for(var/datum/bfx_obj/o in objs)
		if(o.kind == "surge") out += list(list("su", o, o.uid))
	for(var/list/r in rl_lrays)
		out += list(list("lr", r, r[9]))
	for(var/list/b in rl_rbolts)
		out += list(list("rb", b, b[11]))
	for(var/list/s in rl_shocks)
		out += list(list("sh", s, s[7]))
	for(var/list/bo in rl_bolts)
		out += list(list("bo", bo, bo["uid"]))
	for(var/list/s2 in rl_sparks2)
		out += list(list("s2", s2, s2[9]))
	return out

/datum/beamfx/proc/ChainElRecsAt(list/el, f, list/fr)
	var/t = FT(f)
	var/list/out = list()
	var/tp = el[1]
	if(tp == "su")
		var/list/r = ChainSurgeRec(el[2], t, f, fr[1], fr[2], fr[3])
		if(r) out += list(r)
		return out
	if(tp == "lr")
		var/list/keep = rl_lrays
		rl_lrays = list(el[2])
		RLLraySprites(out, t, f)
		rl_lrays = keep
		return out
	if(tp == "rb")
		var/list/keep2 = rl_rbolts
		rl_rbolts = list(el[2])
		RLRootBoltSprites(out, t, f)
		rl_rbolts = keep2
		return out
	if(tp == "sh")
		var/list/keep3 = rl_shocks
		rl_shocks = list(el[2])
		RLShockSprites(out, t, f, fr[1], fr[2], fr[3], fr[4])
		rl_shocks = keep3
		return out
	if(tp == "bo")
		var/list/keep4 = rl_bolts
		rl_bolts = list(el[2])
		RLBoltSprites(out, t, f)
		rl_bolts = keep4
		return out
	if(tp == "s2")
		var/list/keep5 = rl_sparks2
		rl_sparks2 = list(el[2])
		RLSpark2Sprites(out, t, f)
		rl_sparks2 = keep5
	return out

/datum/beamfx/proc/ChainElTag(tg)
	return (tg == "surge" || tg == "lray" || tg == "rbolt" || tg == "rbolt_e" || tg == "shock" || tg == "bolt" || tg == "spark") ? 1 : 0

/datum/beamfx/proc/ChainElStatic(list/el, f1)
	var/list/cp = el.Copy()
	if(el[1] != "su")
		var/list/s0 = el[2]
		cp[2] = s0.Copy()
	var/list/per = list()
	var/started = 0
	var/lead = 0
	var/n = 0
	rl_draw = 1
	for(var/j = 0 to 400)
		var/f = f1 + 2 * j
		var/list/fr = ChainPhase(f)
		var/list/recs = ChainElRecsAt(cp, f, fr)
		if(recs.len && abs(rl_k - 1) > 0.000001)
			var/list/raw0 = ChainPhaseRaw(f)
			var/list/all = raw0.Copy()
			all += recs
			all = ChainWiden(all, f, FT(f))
			recs = list()
			for(var/list/rw in all)
				if(ChainElTag(rw[RL92_TAG])) recs += list(rw)
		if(!recs.len)
			if(!started)
				lead++
				if(cp[1] != "su" && j > 4) break
				if(cp[1] == "su")
					var/datum/bfx_obj/o = cp[2]
					var/list/Hd = fr[2]
					var/age = FT(f) - o.t0
					if(age >= 0 && o.d0 + o.v * age >= fr[1] - Hd["R"] * 0.4 * rl_st) break
				continue
			break
		started = 1
		n = j + 1
		for(var/list/r in recs)
			var/rsi = r[RL92_ST]
			if(isnull(rsi) || rsi < 0) continue
			var/key = r[RL92_KEY]
			if(!per[key]) per[key] = list()
			var/list/L = per[key]
			while(L.len < j - lead) L += list(null)
			var/list/sp = ChainSpec(r, 0)
			if(!ChainOnMap(sp[BFX_X], sp[BFX_Y])) sp = null
			L += list(list(sp, r[RL92_CUTS]))
	if(cp[1] == "sh") ch.el_cmt["sh[cp[3]]"] = cp[2]
	for(var/key in per)
		var/list/L2 = per[key]
		var/list/first
		for(var/list/e in L2)
			if(e[1])
				first = e
				break
		var/datum/efx_chpiece/PE = ch.els[key]
		if(!first)
			if(PE)
				ChainPieceFree(PE)
				ch.els -= key
			continue
		if(!PE)
			PE = ChainPieceNew(key, first[1], first[2])
			if(!PE) continue
			ch.els[key] = PE
		ChainPieceStop(PE)
		ChainCarSync(PE, first[1], first[2])
		var/list/steps = list()
		if(lead) steps += list(list(4, lead * 0.5, null, null, 0, null, 0))
		for(var/i = 1 to L2.len)
			var/list/e2 = L2[i]
			steps += list(ChainStepOf(PE, e2 ? e2[1] : null, 0.5))
		steps += list(list(4, 0.5, null, null, 0, null, 0))
		var/list/fs = first[1]
		if(PE.O.layer != fs[BFX_ZL]) ChainZ(PE.O, fs[BFX_ZL])
		ChainSeq(PE.O, steps, 1)
		PE.looping = 1
		PE.shown = 1
		PE.idle = 0
		PE.spec = null
	ch.el_end["[cp[1]][cp[3]]"] = k + n + 1

/datum/beamfx/proc/ChainElStaticAll(v1)
	for(var/list/el in ChainElAll())
		ChainElStatic(el, v1)

/datum/beamfx/proc/ChainElKeysOf(tp, uid)
	if(tp == "su") return list("su[uid]")
	return list("[tp][uid]p", "[tp][uid]l")

/datum/beamfx/proc/ChainElDrop(tp, uid)
	for(var/key in ChainElKeysOf(tp, uid))
		var/datum/efx_chpiece/PE = ch.els[key]
		if(PE)
			ChainPieceFree(PE)
			ch.els -= key
	ch.el_end -= "[tp][uid]"

/datum/beamfx/proc/ChainStaticTick(f1)
	energyfx_chain_static_ticks++
	var/t = FT(f1)
	var/list/fr = ChainPhase(f1)
	var/xh = fr[1]
	var/list/Hd = fr[2]
	var/front = xh - Hd["R"] * 0.4 * rl_st
	var/surges_on = isnull(rl.P["surges"]) ? 1 : rl.P["surges"]
	var/top = ch.seen_uid
	var/list/alive = list()
	for(var/datum/bfx_obj/o in objs)
		if(o.kind != "surge")
			alive += o
			continue
		if(!surges_on || !rl.B) continue
		var/age = t - o.t0
		if(age >= 0 && o.d0 + o.v * age >= front)
			if(!(o.uid in rl_arrived))
				rl_arrived += o.uid
				rl_flares[++rl_flares.len] = list(o.t0 + (front - o.d0) / o.v, o.scale)
			ChainElDrop("su", o.uid)
			continue
		alive += o
		if(o.uid > ch.seen_uid) ChainElStatic(list("su", o, o.uid), f1)
		top = max(top, o.uid)
	objs = alive
	ch.seen_uid = top
	var/rtop = ch.seen_rl
	var/list/kl = list()
	for(var/list/r in rl_lrays)
		var/ek = ch.el_end["lr[r[9]]"]
		if(ek && ek <= k)
			ChainElDrop("lr", r[9])
			continue
		kl[++kl.len] = r
		if(r[9] > ch.seen_rl) ChainElStatic(list("lr", r, r[9]), f1)
		rtop = max(rtop, r[9])
	rl_lrays = kl
	var/list/kb = list()
	for(var/list/b in rl_rbolts)
		var/ek2 = ch.el_end["rb[b[11]]"]
		if(ek2 && ek2 <= k)
			ChainElDrop("rb", b[11])
			continue
		kb[++kb.len] = b
		if(b[11] > ch.seen_rl) ChainElStatic(list("rb", b, b[11]), f1)
		rtop = max(rtop, b[11])
	rl_rbolts = kb
	var/list/ksh = list()
	for(var/list/s in rl_shocks)
		var/ek3 = ch.el_end["sh[s[7]]"]
		if(ek3 && ek3 <= k)
			ChainElDrop("sh", s[7])
			ch.el_cmt -= "sh[s[7]]"
			continue
		ksh[++ksh.len] = s
		if(s[7] > ch.seen_rl) ChainElStatic(list("sh", s, s[7]), f1)
		rtop = max(rtop, s[7])
	rl_shocks = ksh
	if(rl_pierce)
		rl_draw = 0
		var/t2 = FT(f1 + 1)
		RLBoltSprites(list(), t, f1)
		RLBoltSprites(list(), t2, f1 + 1)
		RLSpark2Sprites(list(), t, f1)
		RLSpark2Sprites(list(), t2, f1 + 1)
		rl_draw = 1
		for(var/list/bo in rl_bolts)
			if(bo["uid"] > ch.seen_rl) ChainElStatic(list("bo", bo, bo["uid"]), f1)
			rtop = max(rtop, bo["uid"])
		for(var/list/s2 in rl_sparks2)
			if(s2[9] > ch.seen_rl) ChainElStatic(list("s2", s2, s2[9]), f1)
			rtop = max(rtop, s2[9])
		for(var/ek in ch.el_end.Copy())
			var/tp2 = copytext(ek, 1, 3)
			if((tp2 == "bo" || tp2 == "s2") && ch.el_end[ek] <= k) ChainElDrop(tp2, copytext(ek, 3))
	ch.seen_rl = max(rtop, rl_uid)
	rl_end_xh = xh
	ChainStaticFlare(f1, t, xh)
	ChainImpact(f1)

/datum/beamfx/proc/ChainStaticFlare(f1, t, xh)
	var/fl = 0
	var/list/kf = list()
	for(var/list/f in rl_flares)
		var/dt = t - f[1]
		if(dt > 0.25) continue
		kf[++kf.len] = f
		if(dt >= 0 && dt < 0.2) fl = max(fl, f[2] * ((1 - dt / 0.2) ** 1.3))
	rl_flares = kf
	var/datum/efx_chpiece/PF = ch.pieces["flash|1"]
	if(PF && PF.boost) ChainBoostSet(PF, 1 + 0.25 * fl, PF.bst_ax, PF.bst_ay)
	var/datum/efx_chpiece/PR = ch.pieces["flare|1"]
	var/list/sp
	if(fl > 0.01 && rl.B)
		var/list/FL = rl.B["flash"]
		var/list/FA = FL["frames"]
		var/fres = FL["res"]
		if(isnull(fres)) fres = 1
		var/ksc = rl.P["flare_k"] * (0.75 + 0.25 * fl) / fres
		var/list/raw = list()
		RLRec(raw, FA[BeamFXMod(floor((f1 - fi0) / 2), FA.len) + 1], WX(xh), WY(xh), 0, ksc, ksc, min(1, 0.85 * fl), 0, 0, 1, null, "flare", "fr")
		if(abs(rl_k - 1) > 0.000001)
			var/list/rr0 = ChainPhaseRaw(f1)
			var/list/rr = rr0.Copy()
			rr += raw
			rr = ChainWiden(rr, f1, t)
			raw = list()
			for(var/list/r0 in rr)
				if(r0[RL92_TAG] == "flare") raw += list(r0)
		if(raw.len)
			sp = ChainSpec(raw[1], 0)
			if(!ChainOnMap(sp[BFX_X], sp[BFX_Y])) sp = null
	if(sp)
		if(!PR)
			PR = ChainPieceNew("flare|1", sp, null)
			if(!PR) return
			ch.pieces["flare|1"] = PR
		ChainPieceSet(PR, sp)
	else if(PR)
		ChainPieceHide(PR)

/datum/beamfx/proc/ChainLeaveStatic()
	for(var/key in ch.pieces)
		ChainPieceStop(ch.pieces[key])
	for(var/key in ch.els)
		var/datum/efx_chpiece/PE = ch.els[key]
		if(PE.looping)
			ChainPieceStop(PE)
			PE.shown = 0
			PE.spec = null
	for(var/key in ch.bodies)
		var/datum/efx_chbody/BD = ch.bodies[key]
		if(BD.looping)
			ChainHalt(BD.scr)
			BD.looping = 0
		for(var/kk in BD.kloop)
			ChainHalt(BD.kids[kk])
		BD.kloop = list()
		for(var/key2 in BD.slots)
			ChainPieceStop(BD.slots[key2])
	for(var/list/s in rl_shocks)
		var/list/c = ch.el_cmt["sh[s[7]]"]
		if(!c) continue
		if(!isnull(c[5]) && c[5] <= FT(2 * k))
			s[5] = c[5]
			s[6] = c[6]
	ch.el_cmt = list()
	ch.el_end = list()
	ch.static_on = 0
	ch.sig = null
	ch.forced = 1
	ch.try_after = k + 2
	energyfx_chain_static_out++

/datum/beamfx/proc/ChainFree()
	for(var/key in ch.pieces)
		ChainPieceFree(ch.pieces[key])
	ch.pieces = list()
	for(var/key in ch.els)
		ChainPieceFree(ch.els[key])
	ch.els = list()
	for(var/key in ch.bodies)
		var/datum/efx_chbody/BD = ch.bodies[key]
		for(var/kk in BD.kids)
			ChainPut(BD.kids[kk])
		BD.kids = list()
		for(var/ks in BD.slots)
			ChainPieceFree(BD.slots[ks])
		BD.slots = list()
		if(BD.scr)
			BD.scr.icon = null
			BD.scr.icon_state = null
			ChainPut(BD.scr)
			BD.scr = null
	ch.bodies = list()
	for(var/obj/energyfx/P in list(ch.imp_p, ch.imp_l))
		P.filters = null
		P.icon = null
		P.icon_state = null
	for(var/obj/energyfx/E in list(ch.spk1, ch.spk2, ch.glint, ch.imp_p, ch.imp_l))
		ChainPut(E)
	ch.spk1 = null
	ch.spk2 = null
	ch.glint = null
	ch.imp_p = null
	ch.imp_l = null
	ch.imp_on = 0
	ch.static_on = 0
	if(ch.root)
		ChainPut(ch.root)
		ch.root = null

/datum/beamfx/feint/New(dir_text, ox, oy, zlevel, width, seed, list/C255, list/core255, list/glow255)
	..()
	if(energyfx_chain_on) ch_on = 1

/datum/beamfx/feint/Step()
	if(!ch_on) return ..()
	k++
	Tick(k)
	rl_cf = null
	if(!ch) ch = new
	if(rl && !isnull(t0) && !ch.end_k) ChainFeint()
	CharsTick()

/datum/beamfx/feint/Busy()
	if(!ch_on) return ..()
	return (ch && k < ch.end_k) ? 1 : 0

/datum/beamfx/feint/proc/ChainFeintRecs(f)
	var/list/out = list()
	var/t = FT(f)
	if(isnull(t0) || t < t0) return out
	var/T = t - t0
	var/list/FE = rl.FE
	var/jf = EFX92FeintJ(T)
	var/x = WX(mz + ENERGYFX_FEINT_AT * rl_st)
	var/y = WY(mz + ENERGYFX_FEINT_AT * rl_st)
	rl_draw = 1
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
	return out

/datum/beamfx/feint/proc/ChainFeint()
	ChainRoot()
	if(!ch.root)
		ch.end_k = k + 1
		return
	var/tend = ENERGYFX_FEINT_PEAK + ENERGYFX_FEINT_N * ENERGYFX_FEINT_DT
	for(var/list/o in rl_fl)
		tend = max(tend, o[1] + o[4])
	var/list/per = list()
	var/n = 0
	for(var/f = 2 * k, FT(f) - t0 <= tend + 0.000001, f++)
		var/pidx = 0
		for(var/list/r in ChainFeintRecs(f))
			var/si = r[RL92_ST]
			if(isnull(si) || si < 0) continue
			var/zl = 0
			if(r[RL92_KIND] == 0)
				pidx++
				zl = r[RL92_LY] + pidx * 0.000001
			var/list/spc = ChainSpec(r, zl)
			if(!ChainOnMap(spc[BFX_X], spc[BFX_Y])) continue
			var/key = r[RL92_KEY]
			if(!per[key]) per[key] = list()
			var/list/L = per[key]
			while(L.len < n) L += list(null)
			L += list(spc)
		n++
	for(var/key in per)
		var/list/L2 = per[key]
		var/list/first
		var/lead = 0
		for(var/list/e in L2)
			if(e)
				first = e
				break
			lead++
		if(!first) continue
		var/datum/efx_chpiece/PC = ChainPieceNew(key, first, null)
		if(!PC) continue
		ch.pieces[key] = PC
		var/list/steps = list()
		if(lead) steps += list(list(4, lead * 0.25, null, null, 0, null, 0))
		for(var/i = lead + 1 to L2.len)
			steps += list(ChainStepOf(PC, L2[i], 0.25))
		steps += list(list(4, 0.25, null, null, 0, null, 0))
		ChainSeq(PC.O, steps, 1)
		PC.looping = 1
		PC.shown = 1
	ch.end_k = k + ceil(n / 2) + 2
