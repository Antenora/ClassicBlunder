var/list/EFXPB_ROWS = list("Crash_Burst" = 1)
var/EFXPB_HOST = 1
var/EFXPB_REC = 1
var/list/EFXPB_WICON = list()
var/list/EFXPB_WSIG = list()
var/list/EFXPB_FB = list("0b", "1b", "2b", "3b", "4b", "5b", "6b", "7b", "8b", "9b", "10b", "11b", "12b", "13b", "14b", "15b")
var/list/EFXPB_FL = list("0l", "1l", "2l", "3l", "4l", "5l", "6l", "7l", "8l", "9l", "10l", "11l", "12l", "13l", "14l", "15l")

/obj/energyfx/pbhost
	icon = null

/datum/efxpb_sky
	var/s
	var/ghost
	var/zt
	var/bobk
	var/nkmax
	var/lay
	var/sidph
	var/kh
	var/khl
	var/kgp
	var/ikm
	var/ikg
	var/list/lmg
	var/list/lmm
	var/alm
	var/list/iks
	var/list/cos_
	var/list/lms
	var/list/als
	var/erupt
	var/wake
	var/ignite
	var/wkind
	var/size
	var/wturns
	var/waveww
	var/wnp
	var/wlife
	var/wturns2
	var/nofizz

/datum/efxpb_wk
	var/ok = 0
	var/ik
	var/nw
	var/ox
	var/span
	var/layb
	var/list/lm
	var/list/flip

/datum/energyfx_blasts/live/var/list/pbo
/datum/energyfx_blasts/live/var/list/pbs
/datum/energyfx_blasts/live/var/list/pbr
/datum/energyfx_blasts/live/var/pb_end = -1
/datum/energyfx_blasts/live/var/pb_rim_end = -1
/datum/energyfx_blasts/live/var/pb_rim = 0
/datum/energyfx_blasts/live/var/pb_bk = -1
/datum/energyfx_blasts/live/var/list/pb_tl
/datum/energyfx_blasts/live/var/list/pb_rimv
/datum/energyfx_blasts/live/var/obj/energyfx/pbhost/pb_host
/datum/energyfx_blasts/live/var/pb_hbx = 0
/datum/energyfx_blasts/live/var/pb_hby = 0
/datum/energyfx_blasts/live/var/list/pb_dr
/datum/energyfx_blasts/live/var/pb_dk = -1
/datum/energyfx_blasts/live/var/pb_fk = 0
/datum/energyfx_blasts/live/var/list/pb_lm

/datum/energyfx_blastshot/var/pb_d = 0
/datum/energyfx_blastshot/var/list/pb_keys
/datum/energyfx_blastshot/var/pb_bh = -1
/datum/energyfx_blastshot/var/list/pb_sig
/datum/energyfx_blastshot/var/list/pb_hl
/datum/energyfx_blastshot/var/list/pb_hs
/datum/energyfx_blastshot/var/pb_hg = 0
/datum/energyfx_blastshot/var/pb_ih
/datum/energyfx_blastshot/var/pb_done = 0
/datum/energyfx_blastshot/var/datum/efxpb_sky/pb_k
/datum/energyfx_blastshot/var/pb_kc = 0
/datum/energyfx_blastshot/var/datum/efxpb_wk/pb_w
/datum/energyfx_blastshot/var/pb_wg = -1

/datum/energyfx_blasts/live/proc/PBOn(datum/energyfx_row/R)
	if(replay || !R || !R.extra) return 0
	return EFXPB_ROWS[R.extra["row"]] ? 1 : 0

/datum/energyfx_blasts/live/LightM(ik, tag = "hl", al = 1)
	if(!pb || al != 1) return ..()
	if(!pb_lm) pb_lm = list()
	var/kk = "[ik]|[tag]"
	var/list/m = pb_lm[kk]
	if(!m)
		m = ..()
		pb_lm[kk] = m
	return m

/datum/energyfx_blasts/live/proc/PBTick(k)
	if(done || k < last_k) return
	var/fresh = k > last_k
	last_k = k
	if(fresh)
		while(k_done < k)
			k_done++
			PBTickWork(k_done)
	PBDue(k)
	PBScan(k)
	PBChars(k)
	idle = PBBusy(k) ? 0 : idle + 1

/datum/energyfx_blasts/live/proc/PBTickWork(k)
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(!isnull(sh.t_hit) && k > sh.TThr("kfly1", sh.t_hit) + 1) continue
		TickShot(sh, k)
	if(spk_q || spk_live) SpeckTick(k)

/datum/energyfx_blasts/live/proc/PBDueAdd(dk, key, f0)
	if(!pb_dr)
		pb_dr = new /list(64)
		for(var/i = 1 to 64)
			pb_dr[i] = list()
	var/list/B = pb_dr[(dk % 64) + 1]
	B[++B.len] = list(dk, key, f0)

/datum/energyfx_blasts/live/proc/PBDue(k)
	if(!pb_dr)
		pb_dk = k
		return
	var/t0 = (pb_dk < 0) ? k : max(pb_dk + 1, k - 63)
	for(var/t = t0, t <= k, t++)
		var/bi = (t % 64) + 1
		var/list/B = pb_dr[bi]
		if(!B.len) continue
		var/list/rest
		for(var/list/e in B)
			if(e[1] > k)
				if(!rest) rest = list()
				rest[++rest.len] = e
				continue
			var/list/ch = pbr ? pbr[e[2]] : null
			if(ch && ch.len > 7 && ch[1] == e[3]) PBFree(e[2])
		pb_dr[bi] = rest ? rest : list()
	pb_dk = k

/datum/energyfx_blasts/live/proc/PBSig(datum/energyfx_blastshot/sh)
	var/list/g = sh.pb_sig
	var/fl = sh.feeds ? sh.feeds.len : 0
	if(g && g[1] == sh.t_launch && g[2] == sh.t_hit && g[3] == sh.t_end && g[4] == sh.t_pred && g[5] == sh.t_contact && g[6] == fl && g[7] == sh.lead && g[8] == sh.k_end) return 0
	var/c = 1
	if(!isnull(sh.t_hit) && (!g || g[2] != sh.t_hit)) c |= 2
	if(!isnull(sh.t_launch) && (!g || g[1] != sh.t_launch)) c |= 4
	sh.pb_sig = list(sh.t_launch, sh.t_hit, sh.t_end, sh.t_pred, sh.t_contact, fl, sh.lead, sh.k_end)
	return c

/datum/energyfx_blasts/live/proc/PBScan(k)
	var/list/nh
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(sh.pb_done) continue
		var/c = PBSig(sh)
		var/closed = !isnull(sh.t_hit) || !isnull(sh.t_end)
		if(!c && !sh.objs.len && !isnull(sh.k_end) && sh.pb_bh <= 2 * k && k > sh.k_end + 40 && (closed || !sh.pb_keys || !sh.pb_keys.len))
			sh.pb_done = 1
			continue
		if(c)
			if(closed) sh.pb_d = 1
			if(c & 2)
				if(!nh) nh = list()
				nh += sh
			if(c & 4) pb_rim = 1
		if(!closed) PBBody(sh, k)
		if(sh.objs.len) PBWakes(sh, k)
	if(nh)
		for(var/datum/energyfx_blastshot/s2 in nh)
			if(!s2.hit_pt) continue
			for(var/datum/energyfx_blastshot/sh in bshots)
				if(sh == s2 || isnull(sh.t_hit) || !sh.hit_pt || sh.pb_bh <= 2 * k) continue
				if(EFXOHyp(s2.hit_pt[1] - sh.hit_pt[1], s2.hit_pt[2] - sh.hit_pt[2]) < 20) sh.pb_d = 1
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(sh.pb_d) PBShotCompile(sh, k)

/datum/energyfx_blasts/live/proc/PBHolds(datum/energyfx_blastshot/sh)
	var/list/g = sh.pb_hs
	if(g && g[1] == sh.t_spawn && g[2] == sh.t_launch && g[3] == sh.t_hit && g[4] == sh.t_pred && g[5] == sh.first_volley) return sh.pb_hl
	sh.pb_hs = list(sh.t_spawn, sh.t_launch, sh.t_hit, sh.t_pred, sh.first_volley)
	sh.pb_hl = ShotHolds(sh)
	sh.pb_ih = isnull(sh.t_hit) ? null : EFXBFidx(sh.t_hit)
	sh.pb_hg++
	return sh.pb_hl

/datum/energyfx_blasts/live/proc/PBQs(datum/energyfx_blastshot/sh, i)
	var/v = i - (i % 2)
	var/ih = sh.pb_ih
	if(!isnull(ih) && ih <= i && i < ih + 5) v = i
	for(var/list/h in sh.pb_hl)
		if(h[1] <= i && i < h[1] + h[2]) v = h[1]
	return v

/datum/energyfx_blasts/live/proc/PBBody(datum/energyfx_blastshot/sh, k)
	PBHolds(sh)
	var/f = 2 * k
	var/v0 = PBQs(sh, f)
	var/v1 = PBQs(sh, f + 1)
	var/datum/efxpb_sky/K = sh.pb_k
	if(!K && !sh.pb_kc)
		sh.pb_kc = 1
		if(!sh.big_only && sh.R("variant", "ball") == "skyorb") K = PBSkyK(sh)
	var/list/D0 = list()
	sh.t_twos = EFXBFtime(f)
	if(K) PBSky(D0, sh, K, EFXBFtime(v0), v0)
	else PBFlight(D0, sh, EFXBFtime(v0), v0)
	var/list/D1 = D0
	if(v1 != v0)
		D1 = list()
		if(K) PBSky(D1, sh, K, EFXBFtime(v1), v1)
		else PBFlight(D1, sh, EFXBFtime(v1), v1)
	var/list/live = list()
	if(D1 == D0)
		for(var/list/s in D0)
			if(PBIssue(s[EO_KEY], s, s, f)) live += s[EO_KEY]
	else
		var/list/m0 = list()
		var/list/m1 = list()
		var/list/keys = list()
		for(var/list/s in D0)
			m0[s[EO_KEY]] = s
			keys[s[EO_KEY]] = 1
		for(var/list/s in D1)
			m1[s[EO_KEY]] = s
			keys[s[EO_KEY]] = 1
		for(var/key in keys)
			if(PBIssue(key, m0[key], m1[key], f)) live += key
	if(sh.pb_keys)
		for(var/key in sh.pb_keys)
			if(!(key in live)) PBFree(key)
	sh.pb_keys = live
	if(live.len) pb_bk = k

/datum/energyfx_blasts/live/proc/PBIssue(key, list/s0, list/s1, f)
	var/list/sp = s0 ? s0 : s1
	var/list/ic = EFXOIcon(sp)
	if(!ic) return 0
	var/obj/energyfx/O = PBObj(key)
	if(!O)
		O = EnergyFXGet(EFXO_PATHS[sp[EO_KIND]], row ? row.path : "blast")
		if(!O) return 0
		O.icon = ic[1]
		O.fx_w = ic[2]
		O.fx_h = ic[3]
		O.alpha = 0
		O.efxo_kf = null
		if(!pbo)
			pbo = list()
			pbs = list()
		pbo[key] = O
		pbs[key] = O.fx_free
	if(!PBPut(O, sp[EO_X], sp[EO_Y]))
		PBFree(key)
		return 0
	if(O.layer != sp[EO_LAY]) O.layer = sp[EO_LAY]
	var/list/sb = s1 ? s1 : s0
	var/f0 = ic[1]
	var/f1 = f0
	var/matrix/t0 = Xform(O, sp)
	var/matrix/t1 = t0
	var/st0 = sp[EO_ST]
	var/st1 = st0
	var/c0 = sp[EO_COL] ? sp[EO_COL] : EFXO_ID
	var/c1 = c0
	if(sb != sp)
		t1 = Xform(O, sb)
		st1 = sb[EO_ST]
		c1 = sb[EO_COL] ? sb[EO_COL] : EFXO_ID
		if(st1 != st0 || sb[EO_IK] != sp[EO_IK])
			var/list/ic1 = EFXOIcon(sb)
			f1 = ic1 ? ic1[1] : O.icon
	var/al0 = s0 ? round(clamp(s0[EO_AL], 0, 1) * 255, 1) : 0
	var/al1 = s1 ? round(clamp(s1[EO_AL], 0, 1) * 255, 1) : 0
	if(O.efxo_kf != f0)
		Keep(f0, st0, O)
		O.efxo_kf = f0
	if(f1 != f0)
		Keep(f1, st1, O)
		O.efxo_kf = f1
	animate(O, transform = t0, alpha = al0, color = c0, icon = f0, icon_state = st0, time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
	energyfx_anim_n++
	if(al0 != al1 || st0 != st1 || c0 != c1 || f0 != f1 || (t1 != t0 && (t0.a != t1.a || t0.b != t1.b || t0.c != t1.c || t0.d != t1.d || t0.e != t1.e || t0.f != t1.f)))
		animate(transform = t1, alpha = al1, color = c1, icon = f1, icon_state = st1, time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		energyfx_anim_n++
	if(EFXPB_REC)
		if(!pbr) pbr = list()
		pbr[key] = list(f, list(s0, s1), 0, 0, 0, O.fx_bx, O.fx_by)
	return 1

/datum/energyfx_blasts/live/proc/PBSkyK(datum/energyfx_blastshot/sh)
	var/datum/efxpb_sky/K = new
	K.s = RSize(sh)
	K.ghost = sh.R("ghost", 1)
	K.zt = sh.R("sky_z", 180)
	K.bobk = sh.R("bob", 1.2)
	K.nkmax = sh.R("fall_px", 7.5) / 0.05 / 250
	K.lay = Lay(5, sh, 0)
	K.sidph = sh.sid * 1.7 * 57.29577951
	K.kh = "[sh.sid]h"
	K.khl = "[sh.sid]hl"
	K.kgp = "[sh.sid]gp"
	K.ikm = Art("ball_mine")
	K.ikg = Art("glow")
	K.lmg = LightM(K.ikg)
	var/al = K.ghost
	var/list/m = LightM(K.ikm, "hl", al)
	if(al > 1)
		m = EFXOLMa(m, al)
		al = 1
	K.lmm = m
	K.alm = al
	K.iks = list(Art("ball_n0"), Art("ball_n1"), Art("ball_n2"), Art("ball"))
	K.cos_ = list()
	K.lms = list()
	K.als = list()
	for(var/ik in K.iks)
		var/list/ad = EFXB_ART["[ik]:geo"]
		K.cos_ += ad ? ad[1] : -12
		var/a2 = K.ghost
		var/list/m2 = LightM(ik, "hl", a2)
		if(a2 > 1)
			m2 = EFXOLMa(m2, a2)
			a2 = 1
		K.lms[++K.lms.len] = m2
		K.als += a2
	K.erupt = sh.R("erupt")
	K.wake = sh.R("wake")
	K.ignite = sh.R("ignite", 0.08)
	K.wkind = sh.R("wake_kind")
	K.size = sh.R("size", 1)
	K.wturns = sh.R("wake_turns")
	K.waveww = sh.R("wave_w", 1)
	var/wik = (sh.R("beam") == "godot") ? "BLMkBody" : WakeKey(sh)
	K.wnp = EFXB_ART["[wik]:np"]
	K.wlife = EFXB_ART["[wik]:life"]
	K.wturns2 = EFXB_ART["[wik]:turns"]
	K.nofizz = sh.R("no_fizzle")
	sh.pb_k = K
	return K

/datum/energyfx_blasts/live/proc/PBBall(list/out, datum/efxpb_sky/K, f, x, y, ang, sc, neck)
	var/ni = (neck < 0.999) ? min(2, floor(neck * 3)) + 1 : 4
	var/ik = K.iks[ni]
	var/ox = K.cos_[ni] * sc * 1
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/bx = x + ca * ox
	var/by = y + sa * ox
	out[++out.len] = list(K.kh, "NP", ik, EFXPB_FB[f + 1], bx, by, ang, sc * 1, sc, K.ghost, null, K.lay, 0)
	out[++out.len] = list(K.khl, "ML", ik, EFXPB_FL[f + 1], bx, by, ang, sc * 1, sc, K.als[ni], K.lms[ni], 0, 0)

/datum/energyfx_blasts/live/proc/PBSky(list/out, datum/energyfx_blastshot/sh, datum/efxpb_sky/K, t, v)
	if(isnull(sh.t_spawn) || v < sh.Thr("spawn", sh.t_spawn)) return
	var/list/p = sh.PosAt(t)
	if(!p) return
	var/f = Frame16(sh, v, t)
	var/launched = !isnull(sh.t_launch) && v >= sh.Thr("launch", sh.t_launch)
	var/hx = p[1]
	var/hy = p[2] + p[3]
	var/s = K.s
	if(isnull(sh.t_hit) || v < sh.Thr("hit", sh.t_hit))
		if(v < sh.Thr("sky", sh.t_sky))
			var/ang = (t > sh.t_spawn + 0.0001) ? sh.Heading(t + 0.0001) : 90
			var/grow = EFXOEaseOut((t - sh.t_spawn) / 0.1)
			var/sc0 = s * (0.45 + 0.55 * grow)
			PBBall(out, K, f, hx, hy, ang, sc0, NeckFrac(sh, t, sc0, 1))
		else if(!launched)
			var/st = t - sh.t_sky
			var/bob = K.bobk * sin(360 * st / 0.9 + K.sidph)
			var/settle = 1 + 0.2 * EFXOExp(-(((st - 0.03) / 0.06) ** 2))
			out[++out.len] = list(K.kh, "NP", K.ikm, EFXPB_FB[f + 1], hx, hy + bob, 0, s * settle, s * settle, K.ghost, null, K.lay, 0)
			out[++out.len] = list(K.khl, "ML", K.ikm, EFXPB_FL[f + 1], hx, hy + bob, 0, s * settle, s * settle, K.alm, K.lmm, 0, 0)
		else
			var/z = p[3]
			PBBall(out, K, f, hx, hy, -90, s, min(1, (K.zt - z) / max(1, 27 * s), K.nkmax))
			var/gk = (1 - min(1, z / K.zt)) ** 1.5
			if(gk > 0.02)
				var/kg = s * (1.5 + 0.7 * gk)
				out[++out.len] = list(K.kgp, "ML", K.ikg, "l", p[1], p[2], 0, kg, kg * 0.5, K.ghost * 0.7 * gk, K.lmg, 0, 0)
	if(sh.from_hand && sh.hand && !isnull(sh.t_launch) && v >= sh.Thr("mz0", sh.t_launch - 0.02) && v < sh.Thr("mz1", sh.t_launch + 0.16) && !K.erupt)
		var/m0 = sh.t_launch - 0.02
		var/tm = t
		if(v >= sh.Thr("mh0", m0 + 2 * EFXB_FR - 0.000000001) && v < sh.Thr("mh1", m0 + 6 * EFXB_FR - 0.000000001)) tm = m0 + 2 * EFXB_FR
		sh.t_real = t
		var/mang = sh.ang0
		if(isnull(mang)) mang = launched ? sh.Heading(t) : 0
		Muzzle(out, sh, tm, mang, s, v)

/datum/energyfx_blasts/live/TickShot(datum/energyfx_blastshot/sh, k)
	if(!pb || !isnull(sh.t_contact)) return ..()
	var/datum/efxpb_sky/K = sh.pb_k
	if(!K)
		if(sh.pb_kc) return ..()
		sh.pb_kc = 1
		if(sh.big_only || sh.R("variant", "ball") != "skyorb") return ..()
		K = PBSkyK(sh)
	var/now = k * EFXB_TICK
	if(!isnull(sh.t_launch) && !sh.launch_done && k >= sh.TThr("kld", sh.t_launch - EFXB_TICK, 1)) sh.launch_done = 1
	if(!isnull(sh.t_launch) && k >= sh.TThr("kfly0", sh.t_launch) && (isnull(sh.t_hit) || k < sh.TThr("kfly1", sh.t_hit)) && (isnull(sh.t_end) || k < sh.TThr("kfly2", sh.t_end)) && k != sh.last_emit) sh.last_emit = k
	var/flying = (k >= sh.TThr("ksp0", sh.t_spawn) && k < sh.TThr("ksky", sh.t_sky)) || (!isnull(sh.t_launch) && k >= sh.TThr("kfa0", sh.t_launch, 1) && k < sh.TThr("kfa1", sh.t_hit))
	if(flying && K.wake && k != sh.last_wake)
		sh.last_wake = k
		var/list/pw = sh.PosAt(now)
		if(pw)
			var/n = sh.wake_n
			sh.wake_n = n + 1
			if(n == 0) sh.wake_k0 = k
			var/gw = EFXOEaseOut((now - sh.t_spawn) / K.ignite)
			var/gsc = (K.wkind == "line") ? 1 : (0.4 + 0.6 * gw)
			if(K.wkind == "wavebody") gsc = 1 / max(0.000001, K.size)
			var/h_in = sh.Heading(now)
			var/h_out = h_in
			if(K.wturns)
				var/list/p2 = sh.PosAt(now + EFXB_TICK)
				if(p2 && EFXOHyp(p2[1] - pw[1], p2[2] + p2[3] - pw[2] - pw[3]) > 0.5) h_out = EFXOAtan2(p2[2] + p2[3] - pw[2] - pw[3], p2[1] - pw[1])
			var/list/P = list(pw[1], pw[2] + pw[3])
			var/nn = EFXBMod(n, K.wnp)
			var/sc = K.size * sh.size_k * gsc
			if(n == 0)
				NewObj(sh, list("kind" = "wake", "t0" = now, "P" = P, "life" = K.wlife, "n" = nn, "scale" = sc, "ww" = K.waveww, "ang" = h_out, "first" = 1))
			else if(abs(EFXBMod(h_out - h_in + 180, 360) - 180) < 1 || !K.wturns2)
				NewObj(sh, list("kind" = "wake", "t0" = now, "P" = P, "life" = K.wlife, "n" = nn, "scale" = sc, "ww" = K.waveww, "ang" = h_in))
			else
				NewObj(sh, list("kind" = "wake", "t0" = now, "P" = P, "life" = K.wlife, "n" = nn, "scale" = sc, "ww" = K.waveww, "ang" = h_in, "half" = "back"))
				NewObj(sh, list("kind" = "wake", "t0" = now, "P" = P, "life" = K.wlife, "n" = nn, "scale" = sc, "ww" = K.waveww, "ang" = h_out, "half" = "front"))
	if(!isnull(sh.t_end) && isnull(sh.t_hit) && !sh.fizz_done && k >= sh.TThr("kfz", sh.t_end - EFXB_TICK, 1) && !K.nofizz)
		sh.fizz_done = 1
		Specks(sh, "fizz", sh.t_end + 0.05, sh.end_pt, round(8 * K.size), 0)

/datum/energyfx_blasts/live/proc/PBShotCompile(datum/energyfx_blastshot/sh, k)
	sh.pb_d = 0
	PBHolds(sh)
	var/f0 = 2 * k
	var/list/recs = list()
	var/fast = !isnull(sh.t_hit) && PBHitFast(sh, k, recs)
	var/H = EFXPB_CLOSED_CAP
	var/n = 0
	var/quiet = 0
	for(var/kk = k, kk < k + H, kk++)
		var/pv = -1000000
		var/list/pout
		var/any = 0
		for(var/j = 0 to 1)
			var/fi = 2 * kk + j
			var/v = PBQs(sh, fi)
			var/list/out
			if(v == pv)
				out = pout
			else
				out = list()
				sh.t_twos = EFXBFtime(fi - (fi % 2))
				var/t = EFXBFtime(v)
				if(sh.pb_k && isnull(sh.t_end)) PBSky(out, sh, sh.pb_k, t, v)
				else PBFlight(out, sh, t, v)
				if(!fast) PBHitPart(out, sh, t, v)
			pv = v
			pout = out
			for(var/list/s in out)
				var/key = s[EO_KEY]
				var/list/F = recs[key]
				if(!F)
					F = new /list(2 * H)
					recs[key] = F
				F[fi - f0 + 1] = s
				any = 1
		n = kk - k + 1
		quiet = any ? 0 : quiet + 1
		if(quiet >= 2) break
	var/list/old = sh.pb_keys
	sh.pb_keys = list()
	var/bh = f0 + 2 * n
	for(var/key in recs)
		var/list/F = recs[key]
		if(F.len == 2 * H) F.len = 2 * n
		PBLay(key, F, f0)
		sh.pb_keys += key
		bh = max(bh, f0 + F.len)
	if(old)
		for(var/key in old)
			if(!(key in recs)) PBFree(key)
	sh.pb_bh = bh

/datum/energyfx_blasts/live/proc/PBHitFast(datum/energyfx_blastshot/sh, k, list/recs)
	var/vr = sh.R("variant", "ball")
	if(vr == "laser" || vr == "void" || vr == "timeskip" || vr == "ball" || vr == "mine" || sh.big_only) return 0
	if(sh.R("merge") || sh.merge_skip || !sh.hit_pt || !isnull(sh.t_contact) || sh.R("pierce")) return 0
	if(sh.feeds && sh.feeds.len) return 0
	var/k0 = sh.R("hit", 0.55) * sh.merge_k
	if(k0 <= 0) return 0
	var/f0 = 2 * k
	var/th = sh.t_hit
	var/fh = sh.Thr("hit", th)
	var/f03 = sh.Thr("hit+0.3", th + 0.3)
	var/list/P = sh.hit_pt
	var/ang = sh.Heading(th - 0.0001)
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/ghost = sh.R("ghost", 1)
	var/spn
	var/kspl
	var/seed
	var/sp0
	var/sp1
	var/slay
	var/list/SC
	if(sh.lead)
		var/back = 38 * sh.R("hit", 0.55) * 0.75
		SC = list(P[1] - ca * back, P[2] - sa * back)
		spn = 3
		kspl = sh.R("hit", 0.55) * 1.1
		seed = 2
		sp0 = 100
		sp1 = 165
		slay = 5.47
	else
		var/sfw = sh.R("splash_fwd", 0)
		SC = list(P[1] + ca * sfw, P[2] + sa * sfw)
		spn = 6
		kspl = min(sh.R("splash_cap", 9), sh.R("hit", 0.55) * sh.merge_k * 2)
		seed = 1
		sp0 = 75
		sp1 = 160
		slay = 5.44
	var/ik = "BLS[setname]"
	var/sns = EFXB_ART["spl:ns"]
	var/sox = EFXB_ART["spl:ox"]
	var/list/pcs = list()
	for(var/i = 0, i < spn, i++)
		var/list/d = SplashDraws(sh, seed, i)
		var/side = (i % 2 == 0) ? 1 : -1
		var/a_t = ang + side * (sp0 + (sp1 - sp0) * d[3])
		var/kk = kspl * d[4]
		var/r0 = d[6] * kspl
		var/key = "[sh.sid]s[seed]_[i]"
		pcs[++pcs.len] = list(d, side, a_t, kk, d[5], SC[1] + cos(a_t) * (r0 + sox * kk), SC[2] + sin(a_t) * (r0 + sox * kk), "[key]p", "[key]a", Lay(slay, sh, i), -1, null, null, list(), list())
	var/list/nb
	var/xik
	var/hold
	var/vi_
	var/ex
	var/ey
	var/xlay
	var/list/XP
	var/list/XA
	if(!sh.lead)
		nb = list()
		for(var/datum/energyfx_blastshot/s2 in bshots)
			if(s2 == sh || isnull(s2.t_hit) || s2.merge_skip || s2.R("hit", 0) <= 0) continue
			var/dd = EFXOHyp(s2.hit_pt[1] - P[1], s2.hit_pt[2] - P[2])
			if(dd < 20) nb[++nb.len] = list(s2.t_hit, 1 - dd / 20)
		xik = "BLX[setname]"
		hold = sh.R("hit_hold", 0.27)
		vi_ = EFXBMod(sh.seq + sh.sid, 4)
		var/fw = 2 + sh.R("expl_fwd", 0)
		ex = P[1] + ca * fw
		ey = P[2] + sa * fw
		xlay = Lay(5.45, sh, 0)
		XP = list()
		XA = list()
	var/bskip = sh.R("bloom_skip", 0) * EFXB_FR
	var/quiet = 0
	var/n = 0
	var/lx
	var/list/rxp
	var/list/rxa
	var/lxa
	for(var/fi = f0, fi < f0 + 2 * EFXPB_CLOSED_CAP, fi++)
		var/v = PBQs(sh, fi)
		var/t = EFXBFtime(v)
		var/any = 0
		var/hitv = v >= fh && v >= sh.Thr("spawn", sh.t_spawn) && sh.PosAt(min(t, th))
		n++
		for(var/list/pc in pcs)
			var/list/A = pc[14]
			var/list/B = pc[15]
			A.len = n
			B.len = n
			if(!hitv || v >= f03) continue
			var/list/d = pc[1]
			var/age = t - (th + d[1])
			if(age < 0 || age >= d[2]) continue
			var/j = min(sns - 1, floor(age / d[2] * (sns - 1) + 0.5))
			if(j != pc[11])
				pc[11] = j
				pc[12] = list(pc[8], "XP", ik, "[pc[5]]_[j]b", pc[6], pc[7], pc[3], pc[4], pc[4] * pc[2], 1, null, pc[10], 0)
				pc[13] = list(pc[9], "XS", ik, "[pc[5]]_[j]a", pc[6], pc[7], pc[3], pc[4], pc[4] * pc[2], 1, null, 0, 0)
			A[n] = pc[12]
			B[n] = pc[13]
			any = 1
		if(XP)
			XP.len = n
			XA.len = n
			if(hitv)
				var/q = t - th
				var/o = 0
				for(var/list/nn in nb)
					var/dt = t - nn[1]
					if(dt >= 0 && dt < 0.5) o += nn[2] * (1 - dt / 0.5)
				var/g2 = ghost * (1 / (1 + 0.8 * o))
				var/i_d = (q >= hold - 0.0000001) ? EFXBIntT((q - hold) / EFXB_FR) : -1
				var/list/frm = ExplFrame(sh, v, q + bskip, q, hold, 0, i_d)
				if(frm)
					var/st = "[vi_][frm[1]][frm[2]]"
					if(st != lx)
						lx = st
						rxp = list("[sh.sid]xp", "XP", xik, "[st]b", ex, ey, 0, k0, k0, ghost, null, xlay, 0)
						rxa = null
					if(!rxa || g2 != lxa)
						lxa = g2
						rxa = list("[sh.sid]xa", "XS", xik, "[st]a", ex, ey, 0, k0, k0, g2, null, 0, 0)
					XP[n] = rxp
					XA[n] = rxa
					any = 1
		quiet = any ? 0 : quiet + 1
		if(quiet >= 4 && fi >= fh + 2) break
	for(var/list/pc in pcs)
		var/list/A = pc[14]
		var/list/B = pc[15]
		A.len = n
		B.len = n
		recs[pc[8]] = A
		recs[pc[9]] = B
	if(XP)
		recs["[sh.sid]xp"] = XP
		recs["[sh.sid]xa"] = XA
	return 1

/datum/energyfx_blasts/live/proc/PBFlight(list/out, datum/energyfx_blastshot/sh, t, v)
	if(sh.big_only) return
	if(isnull(sh.t_spawn) || v < sh.Thr("spawn", sh.t_spawn)) return
	var/s = RSize(sh)
	var/vr = sh.R("variant", "ball")
	if(vr == "void" || vr == "timeskip") return
	var/f = Frame16(sh, v, t)
	var/hit = !isnull(sh.t_hit) && v >= sh.Thr("hit", sh.t_hit)
	var/ended = !isnull(sh.t_end) && v >= sh.Thr("end", sh.t_end) && !hit
	var/launched = !isnull(sh.t_launch) && v >= sh.Thr("launch", sh.t_launch)
	var/list/p = sh.PosAt(isnull(sh.t_hit) ? t : min(t, sh.t_hit))
	if(!p) return
	var/hx = p[1]
	var/hy = p[2] + p[3]
	var/ang = isnull(sh.ang0) ? 0 : sh.ang0
	if(launched && (vr != "skyorb" || ended || isnull(sh.ang0))) ang = sh.Heading(t)
	var/ghost = sh.R("ghost", 1)
	if(!hit && !ended && vr == "skyorb")
		SkyOrb(out, sh, t, v, f, hx, hy, s, ghost, launched)
	else if(!hit && !ended)
		var/grow = EFXOEaseOut((t - sh.t_spawn) / sh.R("ignite", 0.08))
		if(!launched)
			var/bob = sh.R("bob", 1.2) * sin(360 * (t - sh.t_spawn) / 0.9 + sh.sid * 1.7 * 57.29577951)
			var/sc = s * (0.35 + 0.65 * grow) * (1 + 0.04 * sin(360 * t / 0.37 + sh.sid * 57.29577951))
			if(sh.R("fingertip") && vr == "laser" && sh.from_hand)
				var/k2 = sh.R("muzzle", 0.35) * 2.6 * (0.45 + 0.6 * grow)
				var/ns = EFXB_ART["[Art("star")]:n"]
				var/js = min(ns - 1, EFXBMod(sh.Tie("sf", v, EFXBIntT((t - sh.t_spawn) / EFXB_TICK)), 2))
				RecB(out, "[sh.sid]ft", 1, Art("star"), "[js]b", hx, hy, 0, k2, k2, 1, Lay(5.5, sh, 0))
				RecL(out, "[sh.sid]ftl", 1, Art("star"), "[js]l", hx, hy, 0, k2, k2, 1)
			else if(sh.R("fingertip") && sh.from_hand)
				var/k3 = sh.R("muzzle", 0.55) * 2.2 * (0.35 + 0.65 * grow)
				var/ikp = Art("spark")
				var/xs_ = hx + EFXB_ART["[ikp]:geo"][1] * k3
				RecB(out, "[sh.sid]ft", 1, ikp, "[f]b", xs_, hy, 0, k3, k3, 1, Lay(5.5, sh, 0))
				RecL(out, "[sh.sid]ftl", 1, ikp, "[f]l", xs_, hy, 0, k3, k3, 1)
			else
				var/iki = Art("ball_idle")
				RecB(out, "[sh.sid]h", 0, iki, "[f]b", hx, hy + bob, 0, sc, sc, 1, Lay(5, sh, 0))
				RecL(out, "[sh.sid]hl", 0, iki, "[f]l", hx, hy + bob, 0, sc, sc, 1)
			if(!sh.from_hand && v < sh.Thr("spawn+0.12", sh.t_spawn + 0.12))
				var/qa = (t - sh.t_spawn) / 0.12
				var/ikz = Art("muzzle")
				Rec(out, "[sh.sid]pf", "ML", ikz, "[f]l", hx, hy, 0, 0.7 * s, 0.7 * s, 0.8 * (1 - qa), LightM(ikz, "flash"), 0)
		else
			Flight(out, sh, t, v, f, hx, hy, ang, s, grow, ghost)
	if(ended && !sh.R("no_fizzle") && vr != "laser") Fizzle(out, sh, t, v, s, ang, ghost)
	if(sh.from_hand && sh.hand && !isnull(sh.t_launch) && v >= sh.Thr("mz0", sh.t_launch - 0.02) && v < sh.Thr("mz1", sh.t_launch + 0.16) && vr != "laser" && !sh.R("erupt"))
		var/m0 = sh.t_launch - 0.02
		var/tm = t
		if(v >= sh.Thr("mh0", m0 + 2 * EFXB_FR - 0.000000001) && v < sh.Thr("mh1", m0 + 6 * EFXB_FR - 0.000000001)) tm = m0 + 2 * EFXB_FR
		sh.t_real = t
		Muzzle(out, sh, tm, isnull(sh.ang0) ? ang : sh.ang0, s, v)

/datum/energyfx_blasts/live/proc/PBHitPart(list/out, datum/energyfx_blastshot/sh, t, v)
	if(sh.big_only) return
	if(isnull(sh.t_spawn) || v < sh.Thr("spawn", sh.t_spawn)) return
	var/vr = sh.R("variant", "ball")
	if(vr == "void" || vr == "timeskip") return
	if(!sh.PosAt(isnull(sh.t_hit) ? t : min(t, sh.t_hit))) return
	var/s = RSize(sh)
	var/hit = !isnull(sh.t_hit) && v >= sh.Thr("hit", sh.t_hit)
	var/ended = !isnull(sh.t_end) && v >= sh.Thr("end", sh.t_end) && !hit
	if(hit) Hit(out, sh, t, v, s, sh.R("ghost", 1))
	if(ended && vr == "laser" && sh.end_pt && sh.hand) Laser(out, sh, t, v, s, sh.R("ghost", 1), 1)

/datum/energyfx_blasts/live/proc/PBWakes(datum/energyfx_blastshot/sh, k)
	var/f = 2 * k
	PBHolds(sh)
	var/list/L = sh.objs
	if(sh.pb_wg != sh.pb_hg)
		sh.pb_wg = sh.pb_hg
		var/list/keep = list()
		for(var/list/o in L)
			var/fe = o["pbf"]
			if(!isnull(fe) && fe <= f) continue
			if(isnull(fe))
				if(o["kind"] != "wake" || !PBWakeFlip(sh, o, k)) PBWake(sh, o, k)
			else if(o["pbg"] != sh.pb_hg)
				if(!o["pbq"] || !PBFlipStill(sh, o, k))
					o["pbq"] = null
					PBWake(sh, o, k)
			keep[++keep.len] = o
		sh.objs = keep
		return
	var/i = L.len
	while(i >= 1)
		var/list/o = L[i]
		if(!isnull(o["pbf"])) break
		i--
	for(var/j = i + 1 to L.len)
		var/list/o = L[j]
		if(o["kind"] != "wake" || !PBWakeFlip(sh, o, k)) PBWake(sh, o, k)
	var/c = 0
	for(var/list/o in L)
		var/fe = o["pbf"]
		if(isnull(fe) || fe > f) break
		c++
	if(c) L.Cut(1, c + 1)

/datum/energyfx_blasts/live/proc/PBWakeK(datum/energyfx_blastshot/sh)
	var/datum/efxpb_wk/W = new
	sh.pb_w = W
	if(!EFXPB_WSIG.len || sh.R("wake_kind") == "wavebody" || sh.R("beam") == "godot") return W
	W.ik = WakeKey(sh)
	W.nw = EFXB_ART["[W.ik]:nw"]
	W.ox = EFXB_ART["[W.ik]:ox"]
	W.span = ceil(EFXB_ART["[W.ik]:life"] / EFXB_TICK) + 2
	W.layb = EFXBLayerRank(4.3) * 65536 + (1 + sh.ord) * 512
	W.lm = LightM(W.ik)
	W.flip = list()
	W.ok = 1
	return W

/datum/energyfx_blasts/live/proc/PBClean(datum/energyfx_blastshot/sh, a, b)
	var/ih = sh.pb_ih
	if(!isnull(ih) && ih < b && ih + 5 > a) return 0
	for(var/list/h in sh.pb_hl)
		if(h[1] < b && h[1] + h[2] > a) return 0
	return 1

/datum/energyfx_blasts/live/proc/PBWakeFlip(datum/energyfx_blastshot/sh, list/o, k)
	var/datum/efxpb_wk/W = sh.pb_w
	if(!W) W = PBWakeK(sh)
	if(!W.ok) return 0
	var/life = o["life"]
	var/t0 = o["t0"]
	var/f0 = 2 * k
	var/m = W.nw - 1
	var/list/q = list()
	if(PBClean(sh, f0, f0 + 2 * W.span))
		for(var/fi = f0, fi < f0 + 400, fi += 2)
			var/age = EFXBFtime(fi) - t0
			if(age >= life - 0.0000001) break
			if(age < 0) return 0
			var/i = min(m, EFXORoundHalfEven(age / life * m))
			q += i
			q += i
	else
		for(var/fi = f0, fi < f0 + 400, fi++)
			var/age = EFXBFtime(PBQs(sh, fi)) - t0
			if(age >= life - 0.0000001) break
			if(age < 0) return 0
			q += min(m, EFXORoundHalfEven(age / life * m))
	var/list/e = EFXPB_WSIG["[W.ik]|[jointext(q, ",")]"]
	if(!e) return 0
	var/pre
	if(o["first"]) pre = "s"
	else if(o["half"] == "front") pre = "fr[o["n"]]"
	else if(o["half"] == "back") pre = "bk[o["n"]]"
	else pre = "f[o["n"]]"
	var/ck = "[pre]|[e[1]]"
	var/list/fc = W.flip[ck]
	if(!fc)
		var/sb = "[pre]_c[e[1]]b"
		var/sl = "[pre]_c[e[1]]l"
		var/list/icb = EFXPB_WICON["[W.ik]|[sb]"]
		var/list/icl = EFXPB_WICON["[W.ik]|[sl]"]
		if(!icb || !icl || !icb[1] || !icl[1]) return 0
		fc = list(icb, icl, sb, sl)
		W.flip[ck] = fc
	var/ang = o["ang"]
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/sxw = o["scale"]
	var/syw = o["scale"] * o["ww"]
	var/x = o["P"][1] + ca * W.ox * sxw
	var/y = o["P"][2] + sa * W.ox * sxw
	var/kb = "[sh.sid]w[o["id"]]"
	var/kl = "[kb]l"
	var/lay = W.layb + clamp(o["id"], 0, 511)
	var/n = q.len
	var/list/A
	var/list/B
	var/list/rb
	var/list/rl
	if(EFXPB_REC)
		A = new /list(n)
		B = new /list(n)
		var/pi = -1
		for(var/i = 1 to n)
			if(q[i] != pi)
				pi = q[i]
				rb = list(kb, "NP", W.ik, "[pre]_[pi]b", x, y, ang, sxw, syw, 1, null, lay, 0)
				rl = list(kl, "ML", W.ik, "[pre]_[pi]l", x, y, ang, sxw, syw, 1, W.lm, 0, 0)
			A[i] = rb
			B[i] = rl
	else
		rb = list(kb, "NP", W.ik, null, x, y, ang, sxw, syw, 1, null, lay, 0)
		rl = list(kl, "ML", W.ik, null, x, y, ang, sxw, syw, 1, W.lm, 0, 0)
	if(!PBFlip(kb, rb, A, f0, n, fc[1], fc[3], null))
		return 0
	if(!PBFlip(kl, rl, B, f0, n, fc[2], fc[4], W.lm))
		PBFree(kb)
		return 0
	o["pbk"] = list(kb, kl)
	o["pbf"] = f0 + n
	o["pbg"] = sh.pb_hg
	o["pbq"] = q
	o["pb0"] = f0
	return 1

/datum/energyfx_blasts/live/proc/PBFlip(key, list/r, list/F, f0, n, list/ic, st, list/col)
	var/obj/energyfx/O = pbo ? pbo[key] : null
	if(O && (O.loc || O.fx_car) && O.fx_free == pbs[key])
		animate(O)
	else
		O = EnergyFXGet(EFXO_PATHS[r[EO_KIND]], row ? row.path : "blast")
		if(!O) return 0
		if(!pbo)
			pbo = list()
			pbs = list()
		pbo[key] = O
		pbs[key] = O.fx_free
	O.icon = ic[1]
	O.fx_w = ic[2]
	O.fx_h = ic[3]
	if(O.pixel_x || O.pixel_y)
		O.pixel_x = 0
		O.pixel_y = 0
	if(!PBPut(O, r[EO_X], r[EO_Y]))
		PBFree(key)
		return 0
	O.layer = r[EO_LAY]
	O.transform = Xform(O, r)
	O.color = col
	O.icon_state = st
	O.alpha = 255
	if(!pb_fk)
		Keep(ic[1], st, O)
		pb_fk = 1
	if(!pbr) pbr = list()
	pbr[key] = list(f0, F, 0, 0, 0, O.fx_bx, O.fx_by, 1)
	var/fe = f0 + n
	pb_end = max(pb_end, fe + 1)
	PBDueAdd(ceil(fe / 2), key, f0)
	return 1

/datum/energyfx_blasts/live/proc/PBFlipStill(datum/energyfx_blastshot/sh, list/o, k)
	var/list/q = o["pbq"]
	var/f0 = o["pb0"]
	var/ik = WakeKey(sh)
	var/nw = EFXB_ART["[ik]:nw"]
	var/life = o["life"]
	var/t0 = o["t0"]
	var/n = -1
	for(var/fi = 2 * k, fi < f0 + 400, fi++)
		var/age = EFXBFtime(PBQs(sh, fi)) - t0
		if(age >= life - 0.0000001)
			n = fi - f0
			break
		var/i = fi - f0 + 1
		if(age < 0 || i > q.len || q[i] != min(nw - 1, EFXORoundHalfEven(age / life * (nw - 1)))) return 0
	if(n != q.len) return 0
	o["pbg"] = sh.pb_hg
	return 1

/datum/energyfx_blasts/live/proc/PBWakeL(datum/energyfx_blastshot/sh, list/o, k, datum/efxpb_wk/W)
	var/f0 = 2 * k
	var/life = o["life"]
	var/t0 = o["t0"]
	var/m = W.nw - 1
	var/ang = o["ang"]
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/sxw = o["scale"]
	var/syw = o["scale"] * o["ww"]
	var/x = o["P"][1] + ca * W.ox * sxw
	var/y = o["P"][2] + sa * W.ox * sxw
	var/kb = "[sh.sid]w[o["id"]]"
	var/kl = "[kb]l"
	var/pre
	if(o["first"]) pre = "s_"
	else if(o["half"] == "front") pre = "fr[o["n"]]_"
	else if(o["half"] == "back") pre = "bk[o["n"]]_"
	else pre = "f[o["n"]]_"
	var/lay = W.layb + clamp(o["id"], 0, 511)
	var/list/A = list()
	var/list/B = list()
	var/pi = -1
	var/list/rb
	var/list/rl
	var/n = 0
	for(var/fi = f0, fi < f0 + 400, fi++)
		var/age = EFXBFtime(PBQs(sh, fi)) - t0
		if(age >= life - 0.0000001) break
		n++
		if(age < 0)
			A.len += 1
			B.len += 1
			continue
		var/i = min(m, EFXORoundHalfEven(age / life * m))
		if(i != pi)
			pi = i
			rb = list(kb, "NP", W.ik, "[pre][i]b", x, y, ang, sxw, syw, 1, null, lay, 0)
			rl = list(kl, "ML", W.ik, "[pre][i]l", x, y, ang, sxw, syw, 1, W.lm, 0, 0)
		A[++A.len] = rb
		B[++B.len] = rl
	A.len = n
	B.len = n
	PBLayW(kb, A, f0)
	PBLayW(kl, B, f0)
	var/list/oldk = o["pbk"]
	if(oldk)
		for(var/key in oldk)
			if(key != kb && key != kl) PBFree(key)
	o["pbk"] = list(kb, kl)
	o["pbf"] = f0 + n
	o["pbg"] = sh.pb_hg

/datum/energyfx_blasts/live/proc/PBLayW(key, list/F, f0)
	var/n = F.len
	var/list/first
	for(var/i = 1 to n)
		first = F[i]
		if(first) break
	if(!first)
		PBFree(key)
		return
	var/obj/energyfx/O = PBObj(key)
	if(O && pbr && PBSameChain(pbr[key], F, f0)) return
	var/list/ic = EFXOIcon(first)
	if(!ic) return
	if(!O)
		O = EnergyFXGet(EFXO_PATHS[first[EO_KIND]], row ? row.path : "blast")
		if(!O) return
		O.icon = ic[1]
		O.fx_w = ic[2]
		O.fx_h = ic[3]
		O.alpha = 0
		O.efxo_kf = null
		if(!pbo)
			pbo = list()
			pbs = list()
		pbo[key] = O
		pbs[key] = O.fx_free
	if(O.pixel_x || O.pixel_y)
		O.pixel_x = 0
		O.pixel_y = 0
	if(!PBPut(O, first[EO_X], first[EO_Y]))
		PBFree(key)
		return
	if(O.layer != first[EO_LAY]) O.layer = first[EO_LAY]
	var/matrix/xm = Xform(O, first)
	var/list/c = first[EO_COL] ? first[EO_COL] : EFXO_ID
	var/started = 0
	var/vis = 0
	var/steps = 0
	var/pf
	var/kept
	var/i = 1
	while(i <= n)
		var/list/s = F[i]
		var/j = i + 1
		if(s)
			while(j <= n && F[j] == s) j++
			var/list/ic2 = EFXOIcon(s)
			var/f = ic2 ? ic2[1] : O.icon
			if(!vis)
				if(started) animate(transform = xm, alpha = 255, color = c, icon = f, icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
				else animate(O, transform = xm, alpha = 255, color = c, icon = f, icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			else if(f != pf)
				animate(icon = f, icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			else
				animate(icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			pf = f
			if(f != kept)
				kept = f
				Keep(f, s[EO_ST], O)
			vis = 1
		else
			while(j <= n && !F[j]) j++
			if(started) animate(alpha = 0, time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			else animate(O, alpha = 0, time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			vis = 0
		started = 1
		steps++
		i = j
	if(vis)
		animate(alpha = 0, time = 0.25, easing = JUMP_EASING | EASE_IN)
		steps++
	energyfx_anim_n += steps
	if(!pbr) pbr = list()
	pbr[key] = list(f0, F, 0, 0, 0, O.fx_bx, O.fx_by)
	var/fe = f0 + n
	pb_end = max(pb_end, fe + 1)
	EnergyFXDue(O, ceil((fe + 1) / 2) + EFXPB_FREE_PAD - Now())

/datum/energyfx_blasts/live/proc/PBWake(datum/energyfx_blastshot/sh, list/o, k)
	if(o["kind"] == "wake")
		var/datum/efxpb_wk/W = sh.pb_w
		if(!W) W = PBWakeK(sh)
		if(W.ok)
			PBWakeL(sh, o, k, W)
			return
	var/f0 = 2 * k
	var/list/recs = list()
	var/n = 0
	if(o["kind"] == "wake" && sh.R("wake_kind") != "wavebody" && sh.R("beam") != "godot")
		var/ik = WakeKey(sh)
		var/nw = EFXB_ART["[ik]:nw"]
		var/life = o["life"]
		var/t0 = o["t0"]
		var/ang = o["ang"]
		var/ca = cos(ang)
		var/sa = sin(ang)
		var/sxw = o["scale"]
		var/syw = o["scale"] * o["ww"]
		var/x = o["P"][1] + ca * EFXB_ART["[ik]:ox"] * sxw
		var/y = o["P"][2] + sa * EFXB_ART["[ik]:ox"] * sxw
		var/kb = "[sh.sid]w[o["id"]]"
		var/kl = "[kb]l"
		var/pre
		if(o["first"]) pre = "s_"
		else if(o["half"] == "front") pre = "fr[o["n"]]_"
		else if(o["half"] == "back") pre = "bk[o["n"]]_"
		else pre = "f[o["n"]]_"
		var/lay = Lay(4.3, sh, o["id"])
		var/list/lm = LightM(ik)
		var/list/A = list()
		var/list/B = list()
		var/pi = -1
		var/list/rb
		var/list/rl
		for(var/fi = f0, fi < f0 + 400, fi++)
			var/age = EFXBFtime(PBQs(sh, fi)) - t0
			if(age >= life - 0.0000001) break
			n++
			if(age < 0)
				A.len += 1
				B.len += 1
				continue
			var/i = min(nw - 1, EFXORoundHalfEven(age / life * (nw - 1)))
			if(i != pi)
				pi = i
				rb = list(kb, "NP", ik, "[pre][i]b", x, y, ang, sxw, syw, 1, null, lay, 0)
				rl = list(kl, "ML", ik, "[pre][i]l", x, y, ang, sxw, syw, 1, lm, 0, 0)
			A[++A.len] = rb
			B[++B.len] = rl
		recs[kb] = A
		recs[kl] = B
	else
		for(var/fi = f0, fi < f0 + 400, fi++)
			var/v = PBQs(sh, fi)
			var/list/out = list()
			sh.t_twos = EFXBFtime(fi - (fi % 2))
			if(!ObjRec(out, sh, o, EFXBFtime(v), v)) break
			n++
			for(var/list/s in out)
				var/list/F = recs[s[EO_KEY]]
				if(!F)
					F = list()
					recs[s[EO_KEY]] = F
				F.len = n
				F[n] = s
	var/list/oldk = o["pbk"]
	var/list/keys = list()
	for(var/key in recs)
		var/list/F = recs[key]
		F.len = n
		PBLay(key, F, f0)
		keys += key
	if(oldk)
		for(var/key in oldk)
			if(!(key in recs)) PBFree(key)
	o["pbk"] = keys
	o["pbf"] = f0 + n
	o["pbg"] = sh.pb_hg

/datum/energyfx_blasts/live/proc/PBObj(key)
	var/obj/energyfx/O = pbo ? pbo[key] : null
	if(O && ((!O.loc && !O.fx_car) || O.fx_free != pbs[key])) O = null
	return O

/datum/energyfx_blasts/live/proc/PBFree(key)
	var/obj/energyfx/O = PBObj(key)
	if(O) EFXOFree(O)
	if(pbo)
		pbo -= key
		pbs -= key
	if(pbr) pbr -= key

/datum/energyfx_blasts/live/proc/PBPut(obj/energyfx/O, x, y)
	if(!EFXPB_HOST)
		if(!O.loc || abs(x - O.fx_bx) > 48 || abs(y - O.fx_by) > 48) return EnergyFXPlace(O, x, y, zz)
		return 1
	if(O.fx_car) return 1
	if(!pb_host || !pb_host.loc)
		var/tx = floor(x / 32) + 1
		var/ty = floor(y / 32) + 1
		if(tx < 1 || ty < 1 || tx > world.maxx || ty > world.maxy) return 0
		var/turf/T = locate(tx, ty, zz)
		if(!T) return 0
		var/obj/energyfx/pbhost/H = EnergyFXGet(/obj/energyfx/pbhost, row ? row.path : "blast")
		if(!H) return 0
		H.loc = T
		pb_host = H
		pb_hbx = (tx - 1) * 32
		pb_hby = (ty - 1) * 32
		if(!keeper) keeper = new
		if(!keeper.loc) keeper.loc = T
	O.loc = null
	pb_host.vis_contents += O
	O.fx_car = pb_host
	O.fx_bx = pb_hbx + O.fx_w / 2
	O.fx_by = pb_hby + O.fx_h / 2
	return 1

proc/EFXPBRecEq(list/a, list/b)
	if(a == b) return 1
	if(!a || !b) return 0
	for(var/i = 1 to 13)
		if(i == EO_COL)
			var/list/ca = a[i]
			var/list/cb = b[i]
			if(ca == cb) continue
			if(!ca || !cb || ca.len != cb.len) return 0
			for(var/j = 1 to ca.len)
				if(ca[j] != cb[j]) return 0
		else if(a[i] != b[i]) return 0
	return 1

proc/EFXPBColEq(list/a, list/b)
	if(a == b) return 1
	if(!a || !b || a.len != b.len) return 0
	for(var/j = 1 to a.len)
		if(a[j] != b[j]) return 0
	return 1

proc/EFXPBSameXf(list/a, list/b)
	return a[EO_X] == b[EO_X] && a[EO_Y] == b[EO_Y] && a[EO_ANG] == b[EO_ANG] && a[EO_SX] == b[EO_SX] && a[EO_SY] == b[EO_SY] && a[EO_PRE] == b[EO_PRE]

/datum/energyfx_blasts/live/proc/PBSameChain(list/old, list/F, f0)
	if(!old || old.len > 7 || old[3]) return 0
	var/of0 = old[1]
	var/list/oF = old[2]
	if(of0 > f0) return 0
	var/off = f0 - of0
	if(off + F.len > oF.len) return 0
	if(of0 + oF.len != f0 + F.len) return 0
	for(var/i = 1 to F.len)
		if(!EFXPBRecEq(oF[off + i], F[i])) return 0
	return 1

/datum/energyfx_blasts/live/proc/PBLay(key, list/F, f0)
	var/n = F.len
	var/list/first
	for(var/i = 1 to n)
		first = F[i]
		if(first) break
	if(!first)
		PBFree(key)
		return
	var/obj/energyfx/O = PBObj(key)
	if(O && pbr && PBSameChain(pbr[key], F, f0)) return
	var/list/ic = EFXOIcon(first)
	if(!ic) return
	if(!O)
		O = EnergyFXGet(EFXO_PATHS[first[EO_KIND]], row ? row.path : "blast")
		if(!O) return
		O.icon = ic[1]
		O.fx_w = ic[2]
		O.fx_h = ic[3]
		O.alpha = 0
		O.efxo_kf = null
		if(!pbo)
			pbo = list()
			pbs = list()
		pbo[key] = O
		pbs[key] = O.fx_free
	if(O.pixel_x || O.pixel_y)
		O.pixel_x = 0
		O.pixel_y = 0
	if(!PBPut(O, first[EO_X], first[EO_Y]))
		PBFree(key)
		return
	if(O.layer != first[EO_LAY]) O.layer = first[EO_LAY]
	var/started = 0
	var/vis = 0
	var/steps = 0
	var/list/xs
	var/matrix/xm
	var/matrix/pm
	var/pa = -1
	var/list/pc
	var/pf
	var/kept
	var/i = 1
	while(i <= n)
		var/list/s = F[i]
		var/j = i + 1
		if(s)
			while(j <= n)
				var/list/s2 = F[j]
				if(!s2 || (s2 != s && !EFXPBRecEq(s2, s))) break
				j++
			if(!xs || !EFXPBSameXf(xs, s))
				xm = Xform(O, s)
				xs = s
			var/list/ic2 = EFXOIcon(s)
			var/f = ic2 ? ic2[1] : O.icon
			var/a = round(clamp(s[EO_AL], 0, 1) * 255, 1)
			var/list/c = s[EO_COL] ? s[EO_COL] : EFXO_ID
			if(!started || xm != pm || a != pa || !EFXPBColEq(c, pc))
				if(started) animate(transform = xm, alpha = a, color = c, icon = f, icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
				else animate(O, transform = xm, alpha = a, color = c, icon = f, icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
				pm = xm
				pa = a
				pc = c
			else if(f != pf)
				animate(icon = f, icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			else
				animate(icon_state = s[EO_ST], time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			pf = f
			if(f != kept)
				kept = f
				Keep(f, s[EO_ST], O)
			vis = 1
		else
			while(j <= n && !F[j]) j++
			if(started) animate(alpha = 0, time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			else animate(O, alpha = 0, time = 0.25 * (j - i), easing = JUMP_EASING | EASE_IN)
			pa = 0
			vis = 0
		started = 1
		steps++
		i = j
	if(vis)
		animate(alpha = 0, time = 0.25, easing = JUMP_EASING | EASE_IN)
		steps++
	energyfx_anim_n += steps
	if(!pbr) pbr = list()
	pbr[key] = list(f0, F, 0, 0, 0, O.fx_bx, O.fx_by)
	var/fe = f0 + n
	pb_end = max(pb_end, fe + 1)
	EnergyFXDue(O, ceil((fe + 1) / 2) + EFXPB_FREE_PAD - Now())

/datum/energyfx_blasts/live/proc/PBChars(k)
	if(caster && caster.loc && caster.z == zz)
		if(!crig)
			crig = new(caster, 1)
			chars[caster] = crig
			pb_rim = 1
		var/d = EFXBDirName(caster.dir)
		var/list/hp = EFXBHandPx(d)
		var/list/above = null
		if(d == "S" || d == "SE" || d == "SW") above = list(hp[1], hp[2])
		var/oa = crig.app
		var/ofk = crig.fkey
		if(!pb_tl) pb_tl = EFXOLitColor(cols)
		crig.BlastRefresh(d, "[d]|[caster.icon_state]", above, list(hp[1], hp[2]), pb_tl)
		if(crig.app != oa || crig.fkey != ofk) pb_rim = 1
	if(pb_rim) PBCasterRims(k)
	if(hitmobs.len)
		var/list/tl = EFXOLitColor(cols)
		var/th = EFXBFtime(2 * k)
		var/rp = 0.72 + 0.1 * sin(360 * th / 0.33)
		for(var/mob/M in hitmobs)
			var/h0 = HitKFor(M, 2 * k)
			var/h1 = HitKFor(M, 2 * k + 1)
			CharFX(M, EFXBDirName(caster_dir), tl, 0.46 * h0, 0.46 * h1, rp * h0, rp * h1, 1)

/datum/energyfx_blasts/live/proc/PBMuzzleK(fi)
	var/k = 0
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(!sh.from_hand || isnull(sh.t_launch)) continue
		var/m1 = sh.Thr("mk1", sh.t_launch + 0.2)
		if(m1 + EFXPB_HOLD_LAG <= fi) continue
		PBHolds(sh)
		var/vq = PBQs(sh, fi)
		var/q = EFXBFtime(vq) - sh.t_launch
		if(vq >= sh.Thr("mk0", sh.t_launch - 0.02) && vq < m1)
			k = max(k, EFXOEaseOut((q + 0.02) / 0.05) * (1 - EFXOSstep(0.06, 0.2, q)))
	return k

/datum/energyfx_blasts/live/proc/PBCasterRims(k)
	pb_rim = 0
	if(!crig || !crig.rims.len) return
	var/f0 = 2 * k
	var/fend = f0 + 2
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(!sh.from_hand || isnull(sh.t_launch)) continue
		fend = max(fend, sh.Thr("mk1", sh.t_launch + 0.2) + EFXPB_HOLD_LAG)
	fend = min(fend, f0 + EFXPB_RIM_CAP)
	var/list/vs = list()
	var/list/ds = list()
	var/list/raw = list()
	for(var/f = f0, f < fend, f++)
		var/a = round(clamp(PBMuzzleK(f), 0, 1) * 255, 1)
		raw += a
		if(vs.len && vs[vs.len] == a) ds[ds.len] += 0.25
		else
			vs += a
			ds += 0.25
	for(var/obj/O in crig.rims)
		for(var/i = 1 to vs.len)
			if(i == 1) animate(O, alpha = vs[i], time = ds[i], easing = JUMP_EASING | EASE_IN)
			else animate(alpha = vs[i], time = ds[i], easing = JUMP_EASING | EASE_IN)
	energyfx_anim_n += vs.len * crig.rims.len
	pb_rim_end = max(pb_rim_end, ceil(fend / 2))
	pb_rimv = list(f0, raw)

/datum/energyfx_blasts/live/proc/PBBusy(k)
	if((spk_q && spk_q.len) || (spk_live && spk_live.len)) return 1
	if(2 * k < pb_end || k < pb_rim_end || pb_bk >= k) return 1
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(sh.objs.len) return 1
	return 0

/datum/energyfx_blasts/live/proc/PBCleanup()
	for(var/key in pbo)
		var/obj/energyfx/O = pbo[key]
		if(O && (O.loc || O.fx_car) && O.fx_free == pbs[key]) EFXOFree(O)
	pbo = null
	pbs = null
	pbr = null
	pb_dr = null
	if(pb_host)
		EnergyFXFree(pb_host)
		pb_host = null
