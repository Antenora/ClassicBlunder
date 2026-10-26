/datum/beamfx/var/tmp/tl = -1
/datum/beamfx/var/tmp/tl_k0 = 0
/datum/beamfx/var/tmp/tl_end = -1
/datum/beamfx/var/tmp/tl_H = 0
/datum/beamfx/var/tmp/list/tl_fc
/datum/beamfx/var/tmp/list/tl_flogs
/datum/beamfx/var/tmp/datum/beamfx/tl_c
/datum/beamfx/var/tmp/list/tl_pc
/datum/beamfx/var/tmp/tl_force = 0
/datum/beamfx/var/tmp/tl_pace = 1
/datum/beamfx/var/tmp/tl_maxlen
/datum/beamfx/var/tmp/tl_cause
/datum/beamfx/var/tmp/tl_ta
/datum/beamfx/var/tmp/tl_tp
/datum/beamfx/var/tmp/tl_ca = 1
/datum/beamfx/var/tmp/tl_sa = 0
/datum/beamfx/var/tmp/tl_cp = 1
/datum/beamfx/var/tmp/tl_spp = 0
/datum/beamfx/var/tmp/list/tl_cc
/datum/beamfx/var/tmp/tl_cck = -1
/datum/beamfx/var/tmp/obj/energyfx/tl_o
/datum/beamfx/var/tmp/tl_f0 = 0
/datum/beamfx/var/tmp/tl_started = 0
/datum/beamfx/var/tmp/tl_fresh = 0
/datum/beamfx/var/tmp/tl_delay = 0
/datum/beamfx/var/tmp/list/tl_prev
/datum/beamfx/var/tmp/tl_m1 = 0
/datum/beamfx/var/tmp/tl_m2 = 0
/datum/beamfx/var/tmp/tl_m3 = 0
/datum/beamfx/var/tmp/tl_m4 = 0
/datum/beamfx/var/tmp/tl_m5 = 0
/datum/beamfx/var/tmp/tl_m6 = 0
/datum/beamfx/var/tmp/tl_pa = 0
/datum/beamfx/var/tmp/tl_pcol
/datum/beamfx/var/tmp/tl_pst

/datum/beamfx/var/tmp/obj/energyfx/tl_car_o
/datum/beamfx/var/tmp/tl_car_bx = 0
/datum/beamfx/var/tmp/tl_car_by = 0
/datum/beamfx/var/tmp/tl_car_ox = 0
/datum/beamfx/var/tmp/tl_car_oy = 0
/datum/beamfx/var/tmp/tl_car_d
/datum/beamfx/var/tmp/list/tl_car_seq
/datum/beamfx/var/tmp/tl_car_from = 0
/datum/beamfx/var/tmp/tl_car_pace = 1
/datum/beamfx/var/tmp/list/tl_tv
/datum/beamfx/var/tmp/tl_tv0 = 0
/datum/beamfx/var/tmp/list/tl_bcache
/datum/beamfx/var/tmp/list/tl_pend
/datum/beamfx/var/tmp/list/tl_freeq
/datum/beamfx/var/tmp/list/tl_cpend

/datum/bfx_slot/var/tmp/list/tl_seq
/datum/bfx_slot/var/tmp/tl_from = 0
/datum/bfx_slot/var/tmp/tl_last = -1000
/datum/bfx_slot/var/tmp/tl_pace = 1
/datum/bfx_slot/var/tmp/tl_child = 0
/datum/bfx_slot/var/tmp/tl_m = 0
/datum/bfx_slot/var/tmp/list/tl_bodyv

/obj/energyfx/stream
	icon = null
	plane = ENERGYFX_PAINT_PLANE
	layer = 4

var/list/ENERGYFX_TL_NOCOPY = list("type", "parent_type", "vars", "tag", "tl_c")
var/list/ENERGYFX_TL_IN = list("length", "travel", "release", "contact", "clash_freeze", "death", "push", "anchor_x", "anchor_y", "direction", "z", "contact_moved", "target", "partner", "clash_mode", "clash_lead", "clash_on", "clash_mid_x", "clash_mid_y", "gain", "no_bloom", "start", "slowmo")

proc/EnergyFXTlSame(list/a, list/b)
	if(a == b) return 1
	if(!a || !b) return 0
	var/n = a.len
	if(b.len != n) return 0
	for(var/i = 1 to n)
		if(a[i] != b[i]) return 0
	return 1

/datum/bfx_slot/proc/TlAt(f)
	if(!tl_seq || !tl_seq.len) return null
	var/i = f - tl_from + 1
	if(i < 1) return null
	if(i > tl_seq.len) i = tl_seq.len
	return tl_seq[i]

/datum/beamfx/ClashContact(t, qf, strict)
	if(tl_cck != k)
		tl_cck = k
		tl_cc = list()
	var/key = "[num2text(t, 12)]|[qf]|[strict]"
	var/mv = tl_cc[key]
	if(!isnull(mv)) return (mv == "-") ? null : mv
	var/v = ..()
	tl_cc += key
	tl_cc[key] = isnull(v) ? "-" : v
	return v

/datum/beamfx/proc/TlPerTick()
	if(tl < 0)
		var/datum/beam/B = beam
		tl = (bent || istype(src, /datum/beamfx/feint) || (B && istype(B.skill, /obj/Skills/Projectile/Beams/Shine_Ray))) ? 0 : 1
	return tl ? 0 : 1

/datum/beamfx/proc/TlPace()
	if(death_k >= 0 || !owner) return 1
	return SlowMoDelayMult(owner)

/datum/beamfx/proc/TlIn()
	return list(s_n, s_travelled, s_firing, s_blocked, s_clash, s_dead, s_off, Ox, Oy, d, z, target_d, target_mob, partner, clash_mode, clash_lead, cm_on, cm_x, cm_y, gain, no_bloom, start_wt, TlPace())

/datum/beamfx/proc/TlDiff(list/a, list/b)
	for(var/i = 1 to a.len)
		if(a[i] != b[i]) return ENERGYFX_TL_IN[i]
	return null

/datum/beamfx/proc/TlNext(list/v)
	var/list/w = v.Copy()
	if(w[5] || w[6]) return w
	var/ml = tl_maxlen
	if(isnull(ml) && beam)
		var/datum/beam/B = beam
		ml = B.maxlen
	if(w[3])
		if(!w[4] && (isnull(ml) || w[1] < ml)) w[1] = w[1] + 1
	else if(!w[4] && (isnull(ml) || w[2] + w[1] - 1 < ml))
		w[2] = w[2] + 1
	else
		w[1] = w[1] - 1
		w[2] = w[2] + 1
	return w

/datum/beamfx/proc/TlClone()
	var/datum/beamfx/C = tl_c
	if(!C)
		C = new type(d, Ox, Oy, z, ws, 1, null, null, null)
		tl_c = C
	for(var/v in vars)
		if(v in ENERGYFX_TL_NOCOPY) continue
		C.vars[v] = vars[v]
	C.stamp_m = stamp_m.Copy()
	C.stamp_tbf = stamp_tbf.Copy()
	C.objs = objs.Copy()
	C.ring_q = ring_q.Copy()
	C.flame_src = flame_src.Copy()
	C.surge_emit = surge_emit.Copy()
	C.pulses = pulses.Copy()
	C.hlog_f = hlog_f.Copy()
	C.hlog_h = hlog_h.Copy()
	C.blk_f = blk_f.Copy()
	C.blk_v = blk_v.Copy()
	C.olog_f = olog_f.Copy()
	C.olog_v = olog_v.Copy()
	C.spk_shots = spk_shots.Copy()
	var/datum/bfx_rng/G = new(1)
	G.s1 = rng.s1
	G.s2 = rng.s2
	G.s3 = rng.s3
	C.rng = G
	C.tl_c = null
	return C

/datum/beamfx/Step()
	if(TlPerTick()) return ..()
	tl_body = 1
	k++
	TlFrees()
	var/list/now_in = TlIn()
	var/cause
	if(!tl_fc) cause = "start"
	else if(k < tl_end) cause = TlDiff(tl_fc[k - tl_k0 + 1], now_in)
	var/u0 = uid_next
	if(cause || k >= tl_end || tl_force)
		tl_nopre = 0
		Tick(k)
		var/H = min(8, max(1, tl_H * 2))
		if(tl_force) H = 8
		else if(cause) H = 1
		if(clash_mode && partner) H = 1
		TlPlan(H, now_in, cause, u0)
	else
		tl_nopre = 1
		Tick(k)
		FrameAdvance(2 * k)
		FrameAdvance(2 * k + 1)
		tl_nopre = 0
	TlBirths()
	if(logging) TlLog()
	SpeckStep()
	CharsTick()

/datum/beamfx/proc/TlPlan(H, list/in0, cause, u0)
	energyfx_tl_plan_n++
	tl_k0 = k
	tl_H = H
	tl_end = k + H
	tl_cause = cause
	tl_pace = in0[23]
	var/f0 = 2 * k
	var/nfr = 2 * H
	var/list/fs = new /list(nfr)
	var/list/fb = new /list(nfr)
	var/list/nc = list()
	var/list/fc = list()
	fc += list(in0)
	if(logging) tl_flogs = list()
	new_chains = nc
	for(var/j = 1 to 2)
		var/fi = f0 + j - 1
		frame_specs = list(list(), list())
		frame_body = list(null, null)
		if(logging) flog = list()
		FrameAdvance(fi)
		Frame(fi, j)
		fs[j] = frame_specs[j]
		fb[j] = frame_body[j]
		if(logging) TlKeep(fi, flog)
	new_chains = null
	frame_specs = null
	frame_body = null
	if(H > 1)
		var/list/fcs = list()
		for(var/datum/bfx_obj/so in objs)
			fcs += list(list(so, so.fc_init, so.fc_n, so.fc_x, so.fc_y, so.fc_a))
		var/datum/beamfx/C = TlClone()
		C.new_chains = nc
		var/list/v = in0
		for(var/jt = 1 to H - 1)
			v = TlNext(v)
			fc += list(v)
			C.s_n = v[1]
			C.s_travelled = v[2]
			C.k++
			C.Tick(C.k)
			for(var/j = 1 to 2)
				var/fi = 2 * C.k + j - 1
				C.frame_specs = list(list(), list())
				C.frame_body = list(null, null)
				if(logging) C.flog = list()
				C.FrameAdvance(fi)
				C.Frame(fi, j)
				fs[fi - f0 + 1] = C.frame_specs[j]
				fb[fi - f0 + 1] = C.frame_body[j]
				if(logging) TlKeep(fi, C.flog)
		C.new_chains = null
		C.frame_specs = null
		C.frame_body = null
		C.flog = null
		for(var/list/sv in fcs)
			var/datum/bfx_obj/ro = sv[1]
			ro.fc_init = sv[2]
			ro.fc_n = sv[3]
			ro.fc_x = sv[4]
			ro.fc_y = sv[5]
			ro.fc_a = sv[6]
	tl_fc = fc
	TlIssue(f0, nfr, fs, nc, u0, fb)

/datum/beamfx/proc/TlKeep(fi, list/L)
	var/key = "[fi]"
	tl_flogs += key
	tl_flogs[key] = L

/datum/beamfx/proc/TlIssue(f0, nfr, list/fs, list/nc, u0, list/fb)
	var/list/hl = Holds()
	var/ds = 0.25 * tl_pace
	var/list/vm = new /list(nfr)
	for(var/i = 1 to nfr)
		vm[i] = Q(f0 + i - 1, hl)
	var/list/keys = list()
	for(var/list/F in fs)
		for(var/key in F)
			if(isnull(keys[key]))
				keys += key
				keys[key] = 1
	for(var/key in slots)
		if(isnull(keys[key]))
			keys += key
			keys[key] = 1
	tl_pend = null
	tl_bcache = null
	if(tl_body)
		if(!tl_car_o)
			for(var/key in keys)
				if(copytext(key, 1, 2) == "s")
					TlCarNew(f0)
					break
		if(tl_car_o)
			if(tl_car_d != d) TlRekey()
			if(tl_car_o.z != z) tl_car_o.loc = locate(tl_car_o.x, tl_car_o.y, z)
			TlCarIssue(f0, nfr, vm, ds)
	for(var/key in keys)
		var/datum/bfx_slot/SL = slots[key]
		if(tl_body && (SL ? SL.tl_child : copytext(key, 1, 2) == "s"))
			if(tl_car_o) TlStampKey(key, SL, f0, nfr, vm, fs, fb, ds)
			continue
		var/carry = SL ? SL.TlAt(f0 - 1) : null
		var/list/seq = new /list(nfr)
		var/list/first
		for(var/i = 1 to nfr)
			var/v = vm[i]
			var/list/val
			if(v < f0)
				val = carry
			else
				var/list/F = fs[v - f0 + 1]
				val = F[key]
				if(val && val[BFX_PR] < 0) val = null
			seq[i] = val
			if(val && !first) first = val
		var/fresh = 0
		if(!SL)
			if(!first) continue
			var/obj/energyfx/NO
			var/ok = 0
			var/tries = 0
			for(var/i = 1 to nfr)
				var/list/cand = seq[i]
				if(!cand || (i > 1 && seq[i - 1] == cand)) continue
				NO = NewObj(cand, cand[BFX_PR])
				if(NO)
					ok = i
					break
				tries++
				if(tries >= 4) break
			if(!NO) continue
			for(var/i = 1 to ok - 1)
				seq[i] = null
			SL = new
			SL.obj = NO
			SL.fam = first[BFX_FAM]
			SL.light = first[BFX_LIGHT]
			SL.st = NO.icon_state
			SL.last = seq[ok]
			SL.pr = first[BFX_PR]
			slots += key
			slots[key] = SL
			fresh = 1
			if(logging) TlLogObj(NO, f0, "new", key)
		else
			if(!first && !carry)
				if(SL.tl_last < f0 - 4)
					if(logging) TlLogObj(SL.obj, f0, "free", key)
					EnergyFXFree(SL.obj)
					slots -= key
					continue
				var/off0 = f0 - SL.tl_from
				var/allh = 1
				if(SL.tl_seq && off0 >= 0)
					for(var/i = off0 + 1 to SL.tl_seq.len)
						if(SL.tl_seq[i])
							allh = 0
							break
				if(allh) continue
			else if(SL.tl_seq && SL.tl_pace == tl_pace)
				var/off = f0 - SL.tl_from
				if(off >= 0 && off + nfr <= SL.tl_seq.len)
					var/same = 1
					for(var/i = 1 to nfr)
						if(!EnergyFXTlSame(seq[i], SL.tl_seq[off + i]))
							same = 0
							break
					if(same) continue
		var/obj/energyfx/O = SL.obj
		if(first && O.layer != first[BFX_ZL]) O.layer = first[BFX_ZL]
		TlBegin(O, fresh, f0)
		var/i = 1
		while(i <= nfr)
			var/list/val = seq[i]
			var/j = i + 1
			while(j <= nfr && (seq[j] == val || EnergyFXTlSame(seq[j], val))) j++
			TlRun(val, (j - i) * ds)
			if(val) SL.tl_last = f0 + j - 2
			i = j
		SL.tl_seq = seq
		SL.tl_from = f0
		SL.tl_pace = tl_pace
		if(tl_prev) SL.last = tl_prev
		SL.shown = seq[nfr] ? 1 : 0
		tl_o = null
		TlFreeLater(key, SL)
	TlChains(f0, nc, u0, hl)

/datum/beamfx/proc/TlCarNew(f0)
	var/tx = floor(Ox / 32) + 1
	var/ty = floor(Oy / 32) + 1
	var/turf/T = locate(tx, ty, z)
	if(!T) return
	var/obj/energyfx/stream/O = EnergyFXGet(/obj/energyfx/stream, src)
	if(!O) return
	O.loc = T
	O.transform = null
	tl_car_o = O
	tl_car_bx = (tx - 1) * 32
	tl_car_by = (ty - 1) * 32
	tl_car_ox = Ox
	tl_car_oy = Oy
	tl_car_d = d
	tl_car_seq = null
	tl_car_from = 0
	if(logging) TlLogCar(O, f0, "new", tl_car_bx, tl_car_by, 0)

/datum/beamfx/proc/TlCarT(v)
	var/lb = LatBase(FT(v), v)
	return list(ax * lb + (Ox - tl_car_ox), ay * lb + (Oy - tl_car_oy))

proc/EnergyFXTlSeqAt(list/seq, from, f)
	if(!seq || !seq.len) return null
	var/i = f - from + 1
	if(i < 1) return null
	if(i > seq.len) i = seq.len
	return seq[i]

/datum/beamfx/proc/TlCarIssue(f0, nfr, list/vm, ds)
	var/list/seq = new /list(nfr)
	tl_tv = new /list(nfr)
	tl_tv0 = f0
	var/list/prev
	for(var/i = 1 to nfr)
		var/v = vm[i]
		var/list/val
		if(v < f0) val = EnergyFXTlSeqAt(tl_car_seq, tl_car_from, f0 - 1)
		if(!val) val = TlCarT(v)
		if(prev && prev[1] == val[1] && prev[2] == val[2]) val = prev
		if(v >= f0) tl_tv[v - f0 + 1] = val
		seq[i] = val
		prev = val
	if(tl_car_seq && tl_car_pace == tl_pace)
		var/same = 1
		for(var/i = 1 to nfr)
			var/list/dv = EnergyFXTlSeqAt(tl_car_seq, tl_car_from, f0 + i - 1)
			var/list/nv = seq[i]
			if(!dv || dv[1] != nv[1] || dv[2] != nv[2])
				same = 0
				break
		if(same) return
	var/obj/energyfx/O = tl_car_o
	var/i = 1
	var/started = 0
	while(i <= nfr)
		var/list/val = seq[i]
		var/j = i + 1
		while(j <= nfr && seq[j] == val) j++
		var/matrix/M = matrix(1, 0, val[1], 0, 1, val[2])
		var/dur = (j - i) * ds
		if(!started) animate(O, transform = M, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		else animate(transform = M, time = dur, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		energyfx_tl_car_n++
		if(logging) TlLogCar(O, f0, started ? "key" : "chain", val[1], val[2], dur)
		started = 1
		i = j
	tl_car_seq = seq
	tl_car_from = f0
	tl_car_pace = tl_pace

/datum/beamfx/proc/TlRekey()
	for(var/key in slots)
		var/datum/bfx_slot/SL = slots[key]
		if(SL && SL.tl_child) SL.tl_bodyv = null
	tl_car_d = d

proc/EnergyFXTlKeyM(key)
	var/p = findtext(key, "p", 2)
	var/l = findtext(key, "l", 2)
	var/e = (p && l) ? min(p, l) : (p ? p : l)
	return text2num(copytext(key, 2, e))

/datum/beamfx/proc/TlChildVal(list/sp, v, list/prev)
	var/list/T = (tl_tv && v >= tl_tv0 && v - tl_tv0 + 1 <= tl_tv.len) ? tl_tv[v - tl_tv0 + 1] : null
	if(!T) T = TlCarT(v)
	var/x = sp[BFX_X] - T[1]
	var/y = sp[BFX_Y] - T[2]
	if(prev && prev.len == sp.len && abs(prev[BFX_X] - x) < 0.001 && abs(prev[BFX_Y] - y) < 0.001)
		var/same = 1
		for(var/i = 1 to sp.len)
			if(i == BFX_X || i == BFX_Y) continue
			if(prev[i] != sp[i])
				same = 0
				break
		if(same) return prev
	var/list/cv = sp.Copy()
	cv[BFX_X] = x
	cv[BFX_Y] = y
	return cv

/datum/beamfx/proc/TlBodySpecs(m, v, hr)
	var/ck = "[m]|[v]"
	if(tl_bcache)
		var/list/hit = tl_bcache[ck]
		if(hit) return hit
	var/list/fsv = frame_specs
	var/list/flv = flog
	var/lg = logging
	frame_specs = list(list(), list())
	flog = null
	logging = 0
	var/t = FT(v)
	var/firing = isnull(release_f) || v < release_f
	var/dd = LatD(m, t, v)
	if(wide)
		wide_cap = list()
		StampBody(1, m, dd, firing)
		var/list/cap = wide_cap
		wide_cap = null
		WideScale(1, v, t, hr, cap)
	else
		StampBody(1, m, dd, firing)
	var/list/out = frame_specs[1]
	frame_specs = fsv
	flog = flv
	logging = lg
	if(!tl_bcache) tl_bcache = list()
	tl_bcache += ck
	tl_bcache[ck] = out
	return out

/datum/beamfx/proc/TlStampKey(key, datum/bfx_slot/SL, f0, nfr, list/vm, list/fs, list/fb, ds)
	var/m = SL ? SL.tl_m : EnergyFXTlKeyM(key)
	var/list/carry = SL ? SL.TlAt(f0 - 1) : null
	var/list/bodyv = SL ? SL.tl_bodyv : null
	var/list/seq = new /list(nfr)
	var/list/prev = carry
	var/list/sp0
	var/ok = 0
	for(var/i = 1 to nfr)
		var/v = vm[i]
		var/list/val
		if(v < f0)
			val = carry
		else
			var/idx = v - f0 + 1
			var/list/B = fb ? fb[idx] : null
			if(B && m >= B[1] && m <= B[2])
				if(bodyv && prev == bodyv)
					val = prev
				else
					var/list/BS = TlBodySpecs(m, v, B[3])
					var/list/bsp = BS[key]
					if(bsp)
						val = TlChildVal(bsp, v, prev)
						bodyv = val
						if(!sp0) sp0 = bsp
			else
				var/list/F = fs[idx]
				var/list/sp = F[key]
				if(sp && sp[BFX_PR] < 0) sp = null
				if(sp)
					val = TlChildVal(sp, v, prev)
					if(!sp0) sp0 = sp
		seq[i] = val
		if(val && !ok) ok = i
		prev = val
	if(!SL)
		if(!ok) return
		if(!tl_pend) tl_pend = list()
		tl_pend += key
		tl_pend[key] = list(seq, f0, ok, sp0, bodyv, m, ds)
		return
	SL.tl_bodyv = bodyv
	var/obj/energyfx/O = SL.obj
	if(!ok && !carry && SL.tl_last < f0 - 4)
		if(logging) TlLogObj(O, f0, "free", key)
		EnergyFXFree(O)
		slots -= key
		return
	if(SL.tl_pace == tl_pace)
		var/same = 1
		for(var/i = 1 to nfr)
			var/list/dv = SL.TlAt(f0 + i - 1)
			var/list/nv = seq[i]
			if(nv != dv && !EnergyFXTlSame(nv, dv))
				same = 0
				break
		if(same) return
	TlBegin(O, 0, f0)
	var/i = 1
	while(i <= nfr)
		var/list/val = seq[i]
		var/j = i + 1
		while(j <= nfr && (seq[j] == val || EnergyFXTlSame(seq[j], val))) j++
		TlRun(val, (j - i) * ds)
		if(val) SL.tl_last = f0 + j - 2
		i = j
	SL.tl_seq = seq
	SL.tl_from = f0
	SL.tl_pace = tl_pace
	if(tl_prev) SL.last = tl_prev
	SL.shown = seq[nfr] ? 1 : 0
	tl_o = null
	TlFreeLater(key, SL)

/datum/beamfx/proc/TlBirths()
	TlChainBirths()
	if(!tl_pend || !tl_pend.len || !tl_car_o) return
	var/f1 = 2 * k
	var/list/due
	for(var/key in tl_pend)
		var/list/P = tl_pend[key]
		if(P[2] + P[3] - 1 <= f1 + 1)
			if(!due) due = list()
			due += key
	if(!due) return
	for(var/key in due)
		var/list/P = tl_pend[key]
		tl_pend -= key
		if(!slots[key]) TlBirth(key, P, f1)

/datum/beamfx/proc/TlBirth(key, list/P, f1)
	var/list/seq = P[1]
	var/pf0 = P[2]
	var/list/sp0 = P[4]
	var/obj/energyfx/O = NewObj(sp0, sp0[BFX_PR])
	if(!O) return
	O.loc = null
	tl_car_o.vis_contents += O
	O.fx_car = tl_car_o
	O.fx_bx = tl_car_bx + O.fx_w / 2
	O.fx_by = tl_car_by + O.fx_h / 2
	var/datum/bfx_slot/SL = new
	SL.obj = O
	SL.fam = sp0[BFX_FAM]
	SL.light = sp0[BFX_LIGHT]
	SL.st = O.icon_state
	SL.pr = sp0[BFX_PR]
	SL.tl_child = 1
	SL.tl_m = P[6]
	SL.tl_bodyv = P[5]
	slots += key
	slots[key] = SL
	if(logging) TlLogObj(O, f1, "new", key)
	var/nfr = seq.len
	var/i0 = max(1, f1 - pf0 + 1)
	var/list/seq2 = seq.Copy()
	for(var/i = 1 to i0 - 1)
		seq2[i] = null
	var/ds = P[7]
	TlBegin(O, 1, f1)
	var/i = i0
	while(i <= nfr)
		var/list/val = seq2[i]
		var/j = i + 1
		while(j <= nfr && (seq2[j] == val || EnergyFXTlSame(seq2[j], val))) j++
		TlRun(val, (j - i) * ds)
		if(val) SL.tl_last = pf0 + j - 2
		i = j
	SL.tl_seq = seq2
	SL.tl_from = pf0
	SL.tl_pace = tl_pace
	if(tl_prev) SL.last = tl_prev
	SL.shown = seq2[nfr] ? 1 : 0
	tl_o = null
	TlFreeLater(key, SL)

/datum/beamfx/proc/TlFreeLater(key, datum/bfx_slot/SL)
	var/list/seq = SL.tl_seq
	if(!seq || !seq.len || seq[seq.len]) return
	var/lv = 0
	for(var/i = seq.len, i >= 1, i--)
		if(seq[i])
			lv = i
			break
	var/fh = lv ? SL.tl_from + lv - 1 : SL.tl_last
	var/kt = max(k + 1, ceil((fh + 5) / 2))
	if(!tl_freeq) tl_freeq = list()
	var/b = "[kt]"
	var/list/L = tl_freeq[b]
	if(!L)
		L = list()
		tl_freeq += b
		tl_freeq[b] = L
	L += key

/datum/beamfx/proc/TlFrees()
	if(!tl_freeq) return
	var/b = "[k]"
	var/list/L = tl_freeq[b]
	if(!L) return
	tl_freeq -= b
	var/f = 2 * k
	for(var/key in L)
		var/datum/bfx_slot/SL = slots[key]
		if(!SL || SL.TlAt(f) || SL.tl_last >= f - 4) continue
		var/list/seq = SL.tl_seq
		if(seq && seq.len && seq[seq.len]) continue
		if(logging) TlLogObj(SL.obj, f, "free", key)
		EnergyFXFree(SL.obj)
		slots -= key

/datum/beamfx/Cleanup()
	..()
	tl_pend = null
	tl_cpend = null
	tl_freeq = null
	if(tl_car_o)
		if(logging) TlLogCar(tl_car_o, 2 * k + 2, "free", 0, 0, 0)
		EnergyFXFree(tl_car_o)
		tl_car_o = null

/datum/beamfx/proc/TlBegin(obj/energyfx/O, fresh, f0)
	tl_o = O
	tl_f0 = f0
	tl_started = 0
	tl_fresh = fresh
	tl_delay = 0
	tl_prev = null

/datum/beamfx/proc/TlRun(list/sp, dur)
	var/obj/energyfx/O = tl_o
	if(!sp)
		if(!tl_started)
			if(tl_fresh)
				tl_delay += dur
				return
			EnergyFXTlKey(O, null, 0, null, null, dur, 0, ENERGYFX_TL_NEW | ENERGYFX_TL_A)
			tl_started = 1
			if(logging) TlLogKey(O, tl_f0, ENERGYFX_TL_NEW | ENERGYFX_TL_A, dur, 0, null, 0, 0, 0, 0, 0, 0, 0, null, null)
		else
			EnergyFXTlKey(O, null, 0, null, null, dur, 0, ENERGYFX_TL_A)
			if(logging) TlLogKey(O, tl_f0, ENERGYFX_TL_A, dur, 0, null, 0, 0, 0, 0, 0, 0, 0, null, null)
		tl_prev = null
		return
	var/a = sp[BFX_ANG]
	var/p = sp[BFX_PRE]
	if(a != tl_ta || p != tl_tp)
		tl_ta = a
		tl_tp = p
		tl_ca = cos(a)
		tl_sa = sin(a)
		tl_cp = cos(p)
		tl_spp = sin(p)
	var/sx = sp[BFX_SX]
	var/sy = sp[BFX_SY]
	var/m1 = tl_ca * sx * tl_cp - tl_sa * sy * tl_spp
	var/m2 = -tl_ca * sx * tl_spp - tl_sa * sy * tl_cp
	var/m3 = sp[BFX_X] - O.fx_bx
	var/m4 = tl_sa * sx * tl_cp + tl_ca * sy * tl_spp
	var/m5 = -tl_sa * sx * tl_spp + tl_ca * sy * tl_cp
	var/m6 = sp[BFX_Y] - O.fx_by
	var/al
	var/col
	var/st
	var/list/pv = tl_prev
	if(pv && sp[BFX_ALPHA] == pv[BFX_ALPHA] && sp[BFX_FADE] == pv[BFX_FADE] && sp[BFX_TAG] == pv[BFX_TAG] && sp[BFX_ST] == pv[BFX_ST] && sp[BFX_LIGHT] == pv[BFX_LIGHT] && sp[BFX_FAM] == pv[BFX_FAM])
		al = tl_pa
		col = tl_pcol
		st = tl_pst
	else
		al = AlphaOf(sp)
		col = ColorOf(sp)
		st = StateOf(sp)
	var/fl
	if(!tl_started)
		fl = ENERGYFX_TL_NEW | ENERGYFX_TL_T | ENERGYFX_TL_A | ENERGYFX_TL_C | ENERGYFX_TL_S
		tl_started = 1
	else if(!tl_prev)
		fl = ENERGYFX_TL_T | ENERGYFX_TL_A | ENERGYFX_TL_C | ENERGYFX_TL_S
	else
		fl = 0
		if(m1 != tl_m1 || m2 != tl_m2 || m3 != tl_m3 || m4 != tl_m4 || m5 != tl_m5 || m6 != tl_m6) fl |= ENERGYFX_TL_T
		if(al != tl_pa) fl |= ENERGYFX_TL_A
		if(col != tl_pcol) fl |= ENERGYFX_TL_C
		if(st != tl_pst) fl |= ENERGYFX_TL_S
		if(!fl) fl = ENERGYFX_TL_A
	var/dl = (fl & ENERGYFX_TL_NEW) ? tl_delay : 0
	EnergyFXTlKey(O, (fl & ENERGYFX_TL_T) ? matrix(m1, m2, m3, m4, m5, m6) : null, al, col, st, dur, dl, fl)
	if(logging) TlLogKey(O, tl_f0, fl, dur, dl, sp, m1, m2, m3, m4, m5, m6, al, col, st)
	tl_m1 = m1
	tl_m2 = m2
	tl_m3 = m3
	tl_m4 = m4
	tl_m5 = m5
	tl_m6 = m6
	tl_pa = al
	tl_pcol = col
	tl_pst = st
	tl_prev = sp

/datum/beamfx/proc/TlChainBuild(datum/bfx_obj/o, c, obj/energyfx/O, from_f, list/hl, fresh)
	var/list/specs = o.pre_specs
	var/last_f = o.pre_f0 + specs.len - 1
	var/ds = 0.25 * tl_pace
	TlBegin(O, fresh, from_f)
	var/i = from_f
	var/list/cur
	var/n = 0
	var/curv = -1000000
	while(i - from_f < 400)
		var/v = Q(i, hl)
		if(v > last_f) break
		if(v != curv)
			var/list/nx
			if(v >= o.pre_f0)
				var/list/pair = specs[v - o.pre_f0 + 1]
				if(pair) nx = pair[c]
			if(n > 0 && nx != cur && !EnergyFXTlSame(nx, cur))
				TlRun(cur, n * ds)
				n = 0
			cur = nx
			curv = v
		n++
		i++
	if(n > 0) TlRun(cur, n * ds)
	if(tl_prev) TlRun(null, ds)
	else if(!tl_started)
		tl_fresh = 0
		TlRun(null, ds)
	tl_o = null
	return i - from_f

/datum/beamfx/proc/TlChains(f0, list/nc, u0, list/hl)
	if(!tl_pc) tl_pc = list()
	var/now = EnergyFXNow()
	var/list/drop
	for(var/key in tl_pc)
		var/list/e = tl_pc[key]
		if(e[1] > u0 || e[2] <= now)
			if(!drop) drop = list()
			drop += key
			if(e[1] > u0)
				for(var/obj/energyfx/CO in e[3])
					if(CO.loc)
						EnergyFXTlKey(CO, null, 0, null, null, 0.25, 0, ENERGYFX_TL_NEW | ENERGYFX_TL_A)
						if(logging) TlLogKey(CO, f0, ENERGYFX_TL_NEW | ENERGYFX_TL_A, 0.25, 0, null, 0, 0, 0, 0, 0, 0, 0, null, null)
	if(drop)
		for(var/key in drop)
			tl_pc -= key
	if(rm_changed)
		rm_changed = 0
		for(var/key in tl_pc)
			var/list/re = tl_pc[key]
			var/datum/bfx_obj/ro = re[4]
			var/list/rs = ro.pre_specs
			if(!rs || ro.pre_f0 + rs.len - 1 < f0) continue
			var/list/po = re[3]
			var/list/pcs = re[5]
			for(var/ci = 1 to po.len)
				var/obj/energyfx/RO = po[ci]
				if(!RO || !RO.loc) continue
				var/fr = TlChainBuild(ro, pcs[ci], RO, f0, hl, 0)
				var/due = ceil((ceil((fr + 2) / 2) + 1) * tl_pace)
				EnergyFXDue(RO, due)
				re[2] = max(re[2], now + due)
	if(tl_cpend)
		var/list/cdrop
		for(var/key in tl_cpend)
			var/list/P = tl_cpend[key]
			var/datum/bfx_obj/po0 = P[1]
			if(po0.uid > u0)
				if(!cdrop) cdrop = list()
				cdrop += key
		if(cdrop)
			for(var/key in cdrop)
				tl_cpend -= key
	for(var/datum/bfx_obj/o in nc)
		var/key = "[o.uid]"
		if(tl_pc[key]) continue
		var/list/specs = o.pre_specs
		if(!specs || !specs.len) continue
		var/fv = 0
		for(var/i = 1 to specs.len)
			if(specs[i])
				fv = i
				break
		if(!fv) continue
		var/ff = o.pre_f0 + fv - 1
		if(ff > f0 + 1)
			if(!tl_cpend) tl_cpend = list()
			if(isnull(tl_cpend[key])) tl_cpend += key
			tl_cpend[key] = list(o, ff)
			continue
		if(tl_cpend && tl_cpend[key]) tl_cpend -= key
		TlChainBorn(o, key, f0, hl, now)

/datum/beamfx/proc/TlChainBorn(datum/bfx_obj/o, key, f0, list/hl, now)
	var/list/firstpair
	for(var/list/pair in o.pre_specs)
		if(pair)
			firstpair = pair
			break
	if(!firstpair) return
	var/pr = ChainPair(o)
	var/ncnt = (pr > 0) ? 1 : firstpair.len
	var/list/po = list()
	var/list/pcs = list()
	var/last_due = now
	for(var/c = 1 to ncnt)
		var/list/sp0 = firstpair[c]
		var/obj/energyfx/O = NewObj(sp0, (pr > 0) ? pr : 0)
		if(!O) continue
		po += O
		pcs += c
		if(logging) TlLogObj(O, f0, "chain", key)
		var/fr = TlChainBuild(o, c, O, f0, hl, 1)
		var/due = ceil((ceil((fr + 2) / 2) + 1) * tl_pace)
		EnergyFXDue(O, due)
		last_due = max(last_due, now + due)
	if(po.len)
		tl_pc += key
		tl_pc[key] = list(o.uid, last_due, po, o, pcs)

/datum/beamfx/proc/TlChainBirths()
	if(!tl_cpend || !tl_cpend.len) return
	var/f1 = 2 * k
	var/list/due
	for(var/key in tl_cpend)
		var/list/P = tl_cpend[key]
		if(P[2] <= f1 + 1)
			if(!due) due = list()
			due += key
	if(!due) return
	var/list/hl = Holds()
	var/now = EnergyFXNow()
	if(!tl_pc) tl_pc = list()
	for(var/key in due)
		var/list/P = tl_cpend[key]
		tl_cpend -= key
		if(!tl_pc[key]) TlChainBorn(P[1], key, f1, hl, now)

/datum/beamfx/proc/TlLog()
	var/f1 = 2 * k
	var/list/hl = Holds()
	for(var/fi = f1 to f1 + 1)
		var/list/L = tl_flogs ? tl_flogs["[fi]"] : null
		flog = L ? L : list()
		LogFrame(fi)
	flog = null
	LogQ(f1, Q(f1, hl), Q(f1 + 1, hl))

/datum/beamfx/proc/LogQ(f1, v1, v2)
	world.log << "BFXQ[log_tag] [f1] [v1] [v2]"

/datum/beamfx/proc/TlLogKey(obj/energyfx/O, f0, fl, dur, delay, list/sp, m1, m2, m3, m4, m5, m6, al, col, st)
	world.log << "BFXK[log_tag] \ref[O] [f0] [fl] [dur] [delay]"

/datum/beamfx/proc/TlLogObj(obj/energyfx/O, f0, ev, key)
	world.log << "BFXN[log_tag] \ref[O] [f0] [ev] [key] [O.fx_car ? "\ref[O.fx_car]" : "-"]"

/datum/beamfx/proc/TlLogCar(obj/energyfx/O, f0, ev, a, b, c)
	world.log << "BFXC[log_tag] \ref[O] [f0] [ev] [a] [b] [c]"
