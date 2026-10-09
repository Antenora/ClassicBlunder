#define SEKIHA_EXP(x) (2.718281828 ** (x))

/obj/Skills/Projectile/var/DriveTarget = 0
/obj/Skills/Projectile/_Projectile/var/tmp/datum/sekihafx/efx_shot
/obj/Skills/Projectile/_Projectile/var/tmp/mob/drive_mob
/obj/Skills/Projectile/_Projectile/var/tmp/drive_anim = SLIDE_STEPS
/mob/var/tmp/datum/sekihafx/sekiha_pending

var/list/SEKIHA_LIT = list(SEKIHA_LIT_R, SEKIHA_LIT_G, SEKIHA_LIT_B)
var/list/SEKIHA_ICONS = list(
	"hand" = list(SEKIHA_ICON_HAND, SEKIHA_ICON_HAND_W, SEKIHA_ICON_HAND_H),
	"ringw" = list(SEKIHA_ICON_RINGW, SEKIHA_ICON_RINGW_W, SEKIHA_ICON_RINGW_H),
	"ringe" = list(SEKIHA_ICON_RINGE, SEKIHA_ICON_RINGE_W, SEKIHA_ICON_RINGE_H),
	"rings" = list(SEKIHA_ICON_RINGS, SEKIHA_ICON_RINGS_W, SEKIHA_ICON_RINGS_H),
	"kanji" = list(SEKIHA_ICON_KANJI, SEKIHA_ICON_KANJI_W, SEKIHA_ICON_KANJI_H),
	"core" = list(SEKIHA_ICON_CORE, SEKIHA_ICON_CORE_W, SEKIHA_ICON_CORE_H))
var/list/SEKIHA_PATHS = list("P" = /obj/energyfx/paint, "S" = /obj/energyfx/sharp, "L" = /obj/energyfx/light, "GP" = /obj/energyfx/gpaint,
	"GL" = /obj/energyfx/grlight, "FP" = /obj/energyfx/fpaint, "FS" = /obj/energyfx/fsharp, "FL" = /obj/energyfx/flight, "FL2" = /obj/energyfx/flight2)
var/list/sekiha_parity_lines

proc/SekihaBit(list/L, i)
	var/w = floor(i / 24) + 1
	if(w < 1 || w > L.len) return 0
	return (L[w] >> (i % 24)) & 1

proc/SekihaCenter(atom/movable/A)
	return list((A.x - 1) * 32 + A.step_x + 16, (A.y - 1) * 32 + A.step_y + 16)

proc/EnergyFXSkinLocked(obj/Skills/S)
	if(!istype(S, /obj/Skills/Projectile)) return 0
	var/datum/energyfx_row/R = EnergyFXRow(S)
	if(R) return R.look != "beam"
#if SEKIHA_ART
	return istype(S, /obj/Skills/Projectile/Sekiha_Tenkyoken)
#else
	return 0
#endif

/datum/bfx_char/proc/SekihaRefresh(d, fkey2, list/above, list/palm, list/tl)
	if(M.appearance == app && fkey2 == fkey) return
	app = M.appearance
	fkey = fkey2
	var/apart = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	Copy(sil, 0, FLOAT_LAYER, apart)
	sil.render_target = "*[id]"
	Copy(occ, ENERGYFX_OCC_PLANE, 1, apart)
	Copy(locc, ENERGYFX_LOCC_PLANE, 1, apart)
	var/list/fo = list()
	var/list/fl = list()
	if(above)
		fo += filter(type = "alpha", icon = BeamFXMaskIcon("above"), x = above[1], y = above[2])
		fl += filter(type = "alpha", icon = BeamFXMaskIcon("above"), x = above[1], y = above[2])
	occ.filters = fo.len ? fo : null
	locc.filters = fl.len ? fl : null
	if(dark)
		Copy(dark, FLOAT_PLANE, FLOAT_LAYER, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
		dark.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		dark.alpha = 0
	var/list/dv = BeamFXDirVec(d)
	var/sgn = (role == 1) ? -1 : 1
	BeamFXRimBuild(M, "*[id]", sgn * dv[1], sgn * dv[2], tl, 1.45, (role == 1) ? 0.3 : 0.35, rims.len / 2, palm, rims)

proc/SekihaAnimAlpha(list/L, a0, a1)
	for(var/obj/O in L)
		animate(O, alpha = a0, time = 0.25, easing = JUMP_EASING | EASE_IN)
		if(a1 != a0) animate(alpha = a1, time = 0.25, easing = JUMP_EASING | EASE_IN)

/datum/sekihafx
	var/mob/caster
	var/obj/Skills/Projectile/_Projectile/shot
	var/mob/target
	var/zz = 1
	var/dt = "E"
	var/ang = 0
	var/ca = 1
	var/sa = 0
	var/fl = 1
	var/k0 = 0
	var/kl = 22
	var/kl_plan = 22
	var/launched = 0
	var/kc
	var/kh
	var/kh_pred
	var/ended = 0
	var/seq = 0
	var/hx = 0
	var/hy = 0
	var/cpx = 0
	var/cpy = 0
	var/list/pk = list()
	var/list/kj
	var/list/sheds = list()
	var/list/emitted = list()
	var/list/objs = list()
	var/list/hit_pt
	var/datum/bfx_char/cfx_c
	var/datum/bfx_char/cfx_t
	var/last_k = -1000
	var/done = 0
	var/looping = 0
	var/idle = 0
	var/parity = 0
	var/fake_now = 0
	var/list/vi_force
	var/datum/energyfx_blasts/live/b3s
	var/list/b3_draws

/datum/sekihafx/proc/Now()
	if(parity) return fake_now
	return EnergyFXNow() - k0

/datum/sekihafx/proc/SetDir(d)
	dt = BeamFXDirText(d)
	switch(dt)
		if("E") ang = 0
		if("NE") ang = 45
		if("N") ang = 90
		if("NW") ang = 135
		if("W") ang = 180
		if("SW") ang = 225
		if("S") ang = 270
		else ang = 315
	ca = cos(ang)
	sa = sin(ang)
	fl = (ca < -0.000001) ? -1 : 1

/datum/sekihafx/proc/SetP(k, x, y)
	if(k < 0) return
	if(pk.len < k + 1) pk.len = k + 1
	pk[k + 1] = list(x, y)

/datum/sekihafx/proc/LastP(k)
	for(var/i = min(k + 1, pk.len), i >= 1, i--)
		if(pk[i]) return i - 1
	return -1

/datum/sekihafx/proc/GetP(k, extrap)
	if(k >= 0 && k + 1 <= pk.len && pk[k + 1]) return pk[k + 1]
	var/m = LastP(k)
	if(m < 0) return list(cpx, cpy)
	var/list/a = pk[m + 1]
	if(extrap && m >= 1 && pk[m])
		var/list/b = pk[m]
		var/n = k - m
		return list(a[1] + (a[1] - b[1]) * n, a[2] + (a[2] - b[2]) * n)
	return a

/datum/sekihafx/proc/PosAt(Qv)
	if(!launched || Qv < 2 * kl) return list(cpx, cpy)
	var/qq = Qv
	if(!isnull(kh) && qq > 2 * kh) qq = 2 * kh
	if(qq % 2 == 0) return GetP(qq / 2, 0)
	var/list/a = GetP((qq - 1) / 2, 0)
	var/list/b = GetP((qq + 1) / 2, 1)
	return list((a[1] + b[1]) * 0.5, (a[2] + b[2]) * 0.5)

/datum/sekihafx/proc/Q(fi)
	var/v = fi - (fi % 2)
	if(!isnull(kh) && fi >= 2 * kh && fi < 2 * kh + 5) v = fi
	if(kl_plan > 2 && fi >= 6 && fi < 10) v = 6
	var/kp = !isnull(kh) ? kh : kh_pred
	if(!isnull(kp) && fi >= 2 * kp - 3 && fi < 2 * kp) v = 2 * kp - 3
	if(!isnull(kh) && fi >= 2 * kh + 5 && fi < 2 * kh + 11) v = 2 * kh + 5
	return v

/datum/sekihafx/proc/FIdx(Qv)
	var/raw = floor(Qv / 2) - 2
	if(Qv % 2 == 0 && Qv >= 4 && SekihaBit(SEKIHA_FCORR, Qv)) raw -= 1
	return BeamFXMod(raw + seq, SEKIHA_NHAND)

/datum/sekihafx/proc/ShedIdx(ke, n)
	var/i = floor(0.75 * n + 0.5)
	if(n == 2 || n == 6 || n == 10)
		var/b = (n == 2) ? 0 : ((n == 6) ? 1 : 2)
		if(ke >= 0 && ke < SEKIHA_SHEDCORR.len && ((SEKIHA_SHEDCORR[ke + 1] >> b) & 1)) i -= 1
	return min(SEKIHA_NSHED - 1, i)

/datum/sekihafx/proc/Rec(list/out, key, kind, ik, st, x, y, a, sx, sy, al, cm, lay)
	var/list/ic = SEKIHA_ICONS[ik]
	out[++out.len] = list(key, kind, ic[1], ic[2], ic[3], st, x, y, a, sx, sy, al, cm, lay)

/datum/sekihafx/proc/Draw(fi)
	var/list/out = list()
	var/Qv = Q(fi)
	if(Qv < 4) return out
	var/hit = !isnull(kh) && Qv > 2 * kh
	if(!hit)
		var/list/p = PosAt(Qv)
		DrawHand(out, Qv, Qv * SEKIHA_FR, p, (!launched || Qv < 2 * kl))
	else
		DrawEnd(out, Qv)
		if(ended == 1) DrawCore(out, Qv)
	DrawObjs(out, Qv)
	return out

/datum/sekihafx/proc/DrawHand(list/out, Qv, ts, list/p, charge)
	var/f = FIdx(Qv)
	var/x0 = p[1]
	var/y0 = p[2]
	var/sc = 1
	var/la = 1
	var/swa = 1
	var/sws = 1
	var/sxk = 1
	var/syk = 1
	var/st_b = "hb[f]"
	var/st_a = "ha[f]"
	if(charge)
		var/dur = max(SEKIHA_TICK, (kl_plan - 2) * SEKIHA_TICK)
		var/q = clamp((ts - 0.1) / dur, 0, 1)
		var/h5x = hx + ca * SEKIHA_BUD_FWD
		var/h5y = hy + sa * SEKIHA_BUD_FWD
		var/sl = BeamFXEaseOut(BeamFXSstep(0, 0.55, q))
		x0 = h5x + (x0 - h5x) * sl
		y0 = h5y + (y0 - h5y) * sl
		var/g = BeamFXSstep(0, SEKIHA_FORM_END, q)
		sc = 0.55 + 0.45 * BeamFXEaseOut(min(1, (ts - 0.1) / 0.1))
		var/pb = SEKIHA_PULLBACK * BeamFXSstep(0.84, 1, q)
		x0 -= ca * pb
		y0 -= sa * pb
		la = 1 + 0.6 * SEKIHA_EXP(-(((q - 0.94) / 0.05) ** 2))
		if(g < 0.999)
			var/fi_ = min(SEKIHA_NFORM - 1, floor(g * (SEKIHA_NFORM - 1) + 0.5))
			st_b = "fb[fi_]"
			st_a = "fa[fi_]"
		swa = BeamFXSstep(0.3, 0.75, q)
		sws = 0.6 + 0.4 * BeamFXEaseOut(BeamFXSstep(0.3, 0.9, q))
	else
		la = 1 + 0.5 * SEKIHA_EXP(-(((Qv - 2 * kl) / 2) ** 2))
		if(!isnull(kc) && Qv > 2 * kc)
			var/dtf = Qv - 2 * kc
			var/xph = dtf / 2 - 0.000001
			var/ph = xph - floor(xph)
			la += 0.6 * SEKIHA_EXP(-((dtf * SEKIHA_FR / 0.04) ** 2)) + 0.18 * SEKIHA_EXP(-((ph / 0.25) ** 2))
			var/sq = SEKIHA_EXP(-((dtf * SEKIHA_FR / 0.05) ** 2))
			sxk = 1 - 0.08 * sq
			syk = 1 + 0.05 * sq
	if(swa > 0.01)
		var/K = SEKIHA_K * sc
		var/rcx = x0 + ca * (SEKIHA_RING_CX * K) - sa * (SEKIHA_RING_CY * K * fl)
		var/rcy = y0 + sa * (SEKIHA_RING_CX * K) + ca * (SEKIHA_RING_CY * K * fl)
		var/fs = BeamFXMod(floor(Qv / 2), SEKIHA_NRING)
		var/ks = sc * sws
		Rec(out, "rbb", "P", "ringw", "rbb[fs]", rcx, rcy, ang, ks, ks * fl, swa, 1, 4.9)
		Rec(out, "rba", "S", "ringw", "rba[fs]", rcx, rcy, ang, ks, ks * fl, 1, swa, 4.9)
		Rec(out, "rfb", "P", "ringw", "rfb[fs]", rcx, rcy, ang, ks, ks * fl, swa * 0.7, 1, 5.3)
		Rec(out, "rfa", "S", "ringw", "rfa[fs]", rcx, rcy, ang, ks, ks * fl, 1, swa * 0.7, 5.3)
	var/ox = SEKIHA_HAND_OX * SEKIHA_K * sc * sxk
	var/oy = SEKIHA_HAND_OY * SEKIHA_K * sc * fl * syk
	var/hxx = x0 + ca * ox - sa * oy
	var/hyy = y0 + sa * ox + ca * oy
	Rec(out, "hb", "P", "hand", st_b, hxx, hyy, ang, sc * sxk, sc * fl * syk, 1, 1, 5)
	Rec(out, "ha", "S", "hand", st_a, hxx, hyy, ang, sc * sxk, sc * fl * syk, 1, la, 5)

/datum/sekihafx/proc/DrawEnd(list/out, Qv)
	var/n = Qv - 2 * kh
	var/px = hit_pt[1]
	var/py = hit_pt[2]
	var/sc = 1
	var/la = 1
	var/st_b
	var/st_a
	if(n <= 2)
		sc = 1 + 0.06 * (n * 0.5)
		var/f = BeamFXMod(kh + seq, SEKIHA_NHAND)
		st_b = "hb[f]"
		st_a = "ha[f]"
		la = 1.6
	else
		var/i = n - 2
		if(i < SEKIHA_NERODE)
			sc = 1.06 + 0.06 * i / SEKIHA_NERODE
			st_b = "eb[i]"
			st_a = "ea[i]"
	var/K0 = SEKIHA_K
	var/rcx = px + ca * (SEKIHA_RING_CX * K0) - sa * (SEKIHA_RING_CY * K0 * fl)
	var/rcy = py + sa * (SEKIHA_RING_CX * K0) + ca * (SEKIHA_RING_CY * K0 * fl)
	if(n <= 2)
		var/ks = 1 + 0.1 * (n * 0.5)
		var/fs = BeamFXMod(floor(Qv / 2), SEKIHA_NRING)
		Rec(out, "rbb", "P", "ringw", "rbb[fs]", rcx, rcy, ang, ks, ks * fl, 1, 1, 4.9)
		Rec(out, "rba", "S", "ringw", "rba[fs]", rcx, rcy, ang, ks, ks * fl, 1, 1, 4.9)
		Rec(out, "rfb", "P", "ringw", "rfb[fs]", rcx, rcy, ang, ks, ks * fl, 1, 1, 5.3)
		Rec(out, "rfa", "S", "ringw", "rfa[fs]", rcx, rcy, ang, ks, ks * fl, 1, 1, 5.3)
	else
		var/j = n - 2
		if(j < SEKIHA_NRERODE)
			var/ks2 = 1 + 0.3 * j / SEKIHA_NRERODE
			Rec(out, "reb", "P", "ringe", "reb[j]", rcx, rcy, ang, ks2, ks2 * fl, 1, 1, 4.9)
			Rec(out, "rea", "S", "ringe", "rea[j]", rcx, rcy, ang, ks2, ks2 * fl, 1, 1, 4.9)
	if(st_b)
		var/ox = SEKIHA_HAND_OX * SEKIHA_K * sc
		var/oy = SEKIHA_HAND_OY * SEKIHA_K * sc * fl
		var/hxx = px + ca * ox - sa * oy
		var/hyy = py + sa * ox + ca * oy
		Rec(out, "hb", "P", "hand", st_b, hxx, hyy, ang, sc, sc * fl, 1, 1, 5)
		Rec(out, "ha", "S", "hand", st_a, hxx, hyy, ang, sc, sc * fl, 1, la, 5)

/datum/sekihafx/proc/DrawCore(list/out, Qv)
	var/n = Qv - 2 * kh
	if(n < 1 || n > 4) return
	var/cm = 0.8 * (1 - n / 4)
	if(cm <= 0) return
	var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : SEKIHA_LS
	Rec(out, "core", "L", "core", "c", hit_pt[1] - ca * 2, hit_pt[2] - sa * 2, ang, 0.8, 0.8, 1, cm * SEKIHA_LS / ls, 0)

/datum/sekihafx/proc/DrawObjs(list/out, Qv)
	if(kj)
		var/n = Qv - 2 * kl
		var/kb_ = (kl >= 0 && kl < SEKIHA_KANJICORR.len) ? SEKIHA_KANJICORR[kl + 1] : 0
		if((n >= 0 && n <= 33 && !(n == 0 && (kb_ & 1))) || (n == 34 && (kb_ & 2)))
			var/st
			var/fa = 1
			var/stb
			var/sta
			if(n <= 24)
				var/h = BeamFXMod(floor(n / 2), SEKIHA_NKHOLD)
				stb = "kb[h]"
				sta = "ka[h]"
				st = 1 + 0.3 * (1 - BeamFXEaseOut(min(1, n / 3)))
				fa = 1 + 0.8 * SEKIHA_EXP(-((n / 2) ** 2))
			else
				var/j = min(SEKIHA_NKERODE - 1, floor((5 * n - 122) / 6))
				stb = "keb[j]"
				sta = "kea[j]"
				st = 1 + 0.04 * j / SEKIHA_NKERODE
			var/kx = kj[1] + 0.3 * ca * n
			Rec(out, "kb", "P", "kanji", stb, kx, kj[2], 0, st, st, 1, 1, 4.6)
			Rec(out, "ka", "S", "kanji", sta, kx, kj[2], 0, st, st, 1, fa, 4.6)
	for(var/idx = 1 to sheds.len)
		var/list/s = sheds[idx]
		var/n = Qv - 2 * s[1]
		var/sb_ = (s[1] >= 0 && s[1] < SEKIHA_SHEDCORR.len) ? SEKIHA_SHEDCORR[s[1] + 1] : 0
		if(n < 0 || n > 12 || (n == 0 && (sb_ & 8)) || (n == 12 && !(sb_ & 16))) continue
		var/i = ShedIdx(s[1], n)
		Rec(out, "sb[idx]", "P", "rings", "rs[s[4]]b[i]", s[2], s[3], s[5], 1, s[6], 1, 1, 4.7 + 0.0001 * idx)
		Rec(out, "sa[idx]", "S", "rings", "rs[s[4]]a[i]", s[2], s[3], s[5], 1, s[6], 1, 1, 4.7 + 0.0001 * idx)

/datum/sekihafx/proc/HitK(Qv)
	if(isnull(kc) || ended == 2) return 0
	if(Qv <= 2 * kc) return 0
	var/dtf = Qv - 2 * kc
	var/kk = BeamFXEaseOut(dtf * SEKIHA_FR / 0.06)
	if(isnull(kh) || Qv <= 2 * kh) kk *= 0.82 + 0.18 * cos(180 * dtf)
	if(!isnull(kh)) kk *= 1 - BeamFXSstep(0.24, 0.4, max(0, (Qv - 2 * kh) * SEKIHA_FR))
	return 0.6 * kk

/datum/sekihafx/proc/MK(Qv)
	var/m = 0
	if(launched && Qv >= 2 * kl && Qv - 2 * kl < 8)
		var/q = (Qv - 2 * kl) * SEKIHA_FR
		m = BeamFXEaseOut((q + 0.02) / 0.05) * (1 - BeamFXSstep(0.06, 0.2, q))
	if(Qv >= 4 && (!launched || Qv < 2 * kl))
		m = max(m, SEKIHA_CHARGE_GLOW * BeamFXSstep(0, 0.8, (Qv * SEKIHA_FR - 0.1) / max(SEKIHA_TICK, (kl_plan - 2) * SEKIHA_TICK)))
	return m

/datum/sekihafx/proc/EmitShed(k)
	if(!launched || ended == 2 || k < kl || ((k - kl) % SEKIHA_RING_EVERY)) return
	if(!isnull(kh) && k > kh) return
	if(emitted["[k]"]) return
	emitted["[k]"] = 1
	var/list/p = GetP(k, 0)
	var/K = SEKIHA_SIZE
	var/x = p[1] + ca * (SEKIHA_RING_CX * K) - sa * (SEKIHA_RING_CY * K * fl)
	var/y = p[2] + sa * (SEKIHA_RING_CX * K) + ca * (SEKIHA_RING_CY * K * fl)
	var/vi = rand(0, SEKIHA_NSHEDV - 1)
	if(vi_force && vi_force.len > sheds.len) vi = vi_force[sheds.len + 1]
	sheds[++sheds.len] = list(k, x, y, vi, ang, fl)

/datum/sekihafx/proc/Xform(obj/energyfx/O, list/s)
	var/a = s[9]
	var/c = cos(a)
	var/n = sin(a)
	return matrix(c * s[10], -n * s[11], s[7] - O.fx_bx, n * s[10], c * s[11], s[8] - O.fx_by)

/datum/sekihafx/proc/KeyOf(obj/energyfx/O, list/s, list/other)
	if(!s)
		if(!other) return list(matrix(), 0, list(1, 0, 0, 0, 1, 0, 0, 0, 1), O.icon_state)
		return list(Xform(O, other), 0, list(other[13], 0, 0, 0, other[13], 0, 0, 0, other[13]), other[6])
	var/cm = s[13]
	return list(Xform(O, s), round(clamp(s[12], 0, 1) * 255, 1), list(cm, 0, 0, 0, cm, 0, 0, 0, cm), s[6])

/datum/sekihafx/proc/SameKey(list/a, list/b)
	if(a[2] != b[2] || a[4] != b[4]) return 0
	var/list/ca_ = a[3]
	var/list/cb_ = b[3]
	if(ca_[1] != cb_[1]) return 0
	var/matrix/ma = a[1]
	var/matrix/mb = b[1]
	return ma.a == mb.a && ma.b == mb.b && ma.c == mb.c && ma.d == mb.d && ma.e == mb.e && ma.f == mb.f

/datum/sekihafx/proc/Apply(k, list/D0, list/D1)
	var/list/m0 = list()
	var/list/m1 = list()
	var/list/keys = list()
	for(var/list/s in D0)
		m0[s[1]] = s
		keys[s[1]] = 1
	for(var/list/s in D1)
		m1[s[1]] = s
		keys[s[1]] = 1
	var/list/gone = list()
	for(var/key in objs)
		if(!keys[key]) gone += key
	for(var/key in gone)
		EnergyFXFree(objs[key])
		objs -= key
	for(var/key in keys)
		var/list/s0 = m0[key]
		var/list/s1 = m1[key]
		var/list/sp = s0 ? s0 : s1
		var/obj/energyfx/O = objs[key]
		if(!O)
			O = EnergyFXGet(SEKIHA_PATHS[sp[2]], "sekiha")
			if(!O) continue
			O.icon = sp[3]
			O.fx_w = sp[4]
			O.fx_h = sp[5]
			O.alpha = 0
			objs[key] = O
		if(!O.loc || abs(sp[7] - O.fx_bx) > 48 || abs(sp[8] - O.fx_by) > 48)
			if(!EnergyFXPlace(O, sp[7], sp[8], zz))
				EnergyFXFree(O)
				objs -= key
				continue
		O.layer = sp[14]
		var/list/a0 = KeyOf(O, s0, s1)
		var/list/a1 = KeyOf(O, s1, s0)
		if(parity)
			if(s0) SekihaParityLog(2 * k, key, O, s0, a0)
			if(s1) SekihaParityLog(2 * k + 1, key, O, s1, a1)
		animate(O, transform = a0[1], alpha = a0[2], color = a0[3], icon_state = a0[4], time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		energyfx_anim_n++
		if(!SameKey(a0, a1))
			animate(transform = a1[1], alpha = a1[2], color = a1[3], icon_state = a1[4], time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			energyfx_anim_n++

/datum/sekihafx/proc/Chars(k)
	var/c0 = MK(Q(2 * k))
	var/c1 = MK(Q(2 * k + 1))
	var/h0 = HitK(Q(2 * k))
	var/h1 = HitK(Q(2 * k + 1))
	var/fk = 0.72 + 0.1 * sin(360 * (2 * k) * SEKIHA_FR / 0.33)
	var/cr0 = clamp(c0 / 1.45, 0, 1) * 255
	var/cr1 = clamp(c1 / 1.45, 0, 1) * 255
	var/tr0 = clamp(fk * h0 / 1.45, 0, 1) * 255
	var/tr1 = clamp(fk * h1 / 1.45, 0, 1) * 255
	var/dk0 = min(1, 0.46 * h0) * 255
	var/dk1 = min(1, 0.46 * h1) * 255
	if(parity)
		sekiha_parity_lines += "C [2 * k] [SekihaN(cr0)] [SekihaN(tr0)] [SekihaN(dk0)] [SekihaN(c0)] [SekihaN(h0)] [SekihaN(hx)] [SekihaN(hy)]"
		sekiha_parity_lines += "C [2 * k + 1] [SekihaN(cr1)] [SekihaN(tr1)] [SekihaN(dk1)] [SekihaN(c1)] [SekihaN(h1)] [SekihaN(hx)] [SekihaN(hy)]"
		return
	if(!glob || !glob.BEAMFX_CHARS) return
	if(caster && caster.loc && caster.z == zz)
		if(!cfx_c || cfx_c.M != caster)
			if(cfx_c) cfx_c.Drop()
			cfx_c = new(caster, 1)
		var/list/cc = BeamFXImageCenter(caster)
		var/list/palm = list(round(hx - cc[1], 0.01), round(hy - cc[2], 0.01))
		var/list/above = (dt == "S" || dt == "SE" || dt == "SW") ? list(0, round(hy - 2 - cc[2], 0.01)) : null
		cfx_c.SekihaRefresh(dt, "[dt]|[palm[1]]|[palm[2]]|[above ? above[2] : "x"]", above, palm, SEKIHA_LIT)
		SekihaAnimAlpha(cfx_c.rims, cr0, cr1)
	else if(cfx_c)
		cfx_c.Drop()
		cfx_c = null
	if(target && target.loc && target.z == zz && target != caster)
		if(!cfx_t || cfx_t.M != target)
			if(cfx_t) cfx_t.Drop()
			cfx_t = new(target, 2)
		cfx_t.SekihaRefresh(dt, "[dt]", null, null, SEKIHA_LIT)
		SekihaAnimAlpha(cfx_t.rims, tr0, tr1)
		if(cfx_t.dark) SekihaAnimAlpha(list(cfx_t.dark), dk0, dk1)
	else if(cfx_t)
		cfx_t.Drop()
		cfx_t = null

/datum/sekihafx/proc/DrawTick(k)
	if(parity && b3s && !isnull(kh) && k > kh) b3s.DrawTick(k - kh + 2)
	if(done || k < last_k) return
	last_k = k
	if(launched && ended != 2) EmitShed(k)
	var/list/D0 = Draw(2 * k)
	var/list/D1 = Draw(2 * k + 1)
	Apply(k, D0, D1)
	Chars(k)
	var/busy = D0.len || D1.len || HitK(Q(2 * k)) > 0.001 || HitK(Q(2 * k + 1)) > 0.001 || MK(Q(2 * k + 1)) > 0.001
	idle = busy ? 0 : idle + 1

/datum/sekihafx/proc/Anchor()
	if(shot && target && shot.drive_mob == target)
		var/list/tc = SekihaCenter(target)
		return list(tc[1] - ca * SEKIHA_CONTACT, tc[2] - sa * SEKIHA_CONTACT)
	if(shot && shot.loc)
		var/list/c = SekihaCenter(shot)
		var/list/hd = BeamFXHand(dt)
		return list(c[1] + hd[1] + ca * SEKIHA_LAUNCH_FWD, c[2] + hd[2] + sa * SEKIHA_LAUNCH_FWD)
	return GetP(max(0, Now()), 0)

/datum/sekihafx/proc/Start(mob/M, ds)
	caster = M
	zz = M.z
	SetDir(M.dir)
	var/list/c = SekihaCenter(M)
	var/list/hd = BeamFXHand(dt)
	hx = c[1] + hd[1]
	hy = c[2] + hd[2]
	cpx = hx + ca * SEKIHA_LAUNCH_FWD
	cpy = hy + sa * SEKIHA_LAUNCH_FWD
	k0 = EnergyFXNow() - 2
	kl_plan = 2 + max(1, ceil(ds / world.tick_lag - 0.0001))
	kl = kl_plan
	seq = rand(0, SEKIHA_NHAND - 1)
	var/mob/tg = M.Target
	if(ismob(tg) && tg != M && tg.z == zz) target = tg
	DrawTick(2)
	Loop()

/datum/sekihafx/proc/NoCharge(obj/Skills/Projectile/_Projectile/P)
	shot = P
	zz = P.z
	SetDir(P.Owner ? P.Owner.dir : P.dir)
	var/list/c = SekihaCenter(P)
	var/list/hd = BeamFXHand(dt)
	hx = c[1] + hd[1]
	hy = c[2] + hd[2]
	cpx = hx + ca * SEKIHA_LAUNCH_FWD
	cpy = hy + sa * SEKIHA_LAUNCH_FWD
	k0 = EnergyFXNow() - 2
	kl_plan = 2
	kl = 2
	seq = rand(0, SEKIHA_NHAND - 1)
	Loop()

/datum/sekihafx/proc/Launch(obj/Skills/Projectile/_Projectile/P)
	if(launched || done) return
	shot = P
	launched = 1
	SetDir(P.dir)
	kl = Now()
	var/list/a = Anchor()
	SetP(kl, a[1], a[2])
	kj = list(a[1] + ca * SEKIHA_KANJI_KX, a[2] + SEKIHA_KANJI_KY)
	DrawTick(kl)

/datum/sekihafx/proc/Contact(mob/T)
	if(done || !isnull(kc)) return
	kc = Now()
	target = T
	kh_pred = kc + SEKIHA_DRIVE_HITS

/datum/sekihafx/proc/FlightTick(obj/Skills/Projectile/_Projectile/P)
	if(done || ended || !launched) return
	var/k = Now()
	var/list/a = Anchor()
	SetP(k, a[1], a[2])
	DrawTick(k)

/datum/sekihafx/proc/Finish(obj/Skills/Projectile/_Projectile/P, lost)
	if(done || ended) return
	var/k = Now()
	if(!launched)
		if(P)
			Launch(P)
		else
			launched = 1
			kl = k
	ended = lost ? 2 : 1
	kh = k
	var/list/a = Anchor()
	SetP(k, a[1], a[2])
	hit_pt = a
	DrawTick(k)
	shot = null
	Loop()
	if(ended == 1)
		b3s = EnergyFXSekihaBlast(src, b3_draws)
		if(b3s)
			if(parity) b3s.DrawTick(2)
			else b3s.Loop()

/datum/sekihafx/proc/Cleanup()
	if(parity && b3s) b3s.Cleanup()
	if(done) return
	done = 1
	for(var/key in objs)
		EnergyFXFree(objs[key])
	objs = list()
	if(cfx_c) cfx_c.Drop()
	if(cfx_t) cfx_t.Drop()
	cfx_c = null
	cfx_t = null
	if(caster && caster.sekiha_pending == src) caster.sekiha_pending = null
	if(shot && shot.efx_shot == src) shot.efx_shot = null
	caster = null
	target = null
	shot = null

/datum/sekihafx/proc/Loop()
	set waitfor = 0
	if(looping || parity) return
	looping = 1
	while(!done)
		sleep(world.tick_lag)
		if(done) break
		var/k = Now()
		if(!launched)
			if(kl_plan <= 2) continue
			if(k > kl_plan + 6 || !caster || !caster.loc)
				Cleanup()
				break
			DrawTick(k)
		else if(!ended)
			if(!shot || !shot.loc || shot.efx_shot != src)
				Finish(null, 1)
			else if(k - last_k >= 2)
				DrawTick(k - 1)
		else
			DrawTick(k)
			if(idle >= 2 || k - kh > 120)
				Cleanup()
				break
	looping = 0

proc/SekihaParityLog(fi, key, obj/energyfx/O, list/s, list/a)
	var/matrix/m = a[1]
	sekiha_parity_lines += "S [fi] [key] [s[2]] [s[6]] [SekihaN(s[7])] [SekihaN(s[8])] [SekihaN(s[9])] [SekihaN(s[10])] [SekihaN(s[11])] [SekihaN(s[12])] [SekihaN(s[13])] [s[14]] [O.x] [O.y] [O.fx_w] [O.fx_h] [SekihaN(m.a)] [SekihaN(m.b)] [SekihaN(m.c)] [SekihaN(m.d)] [SekihaN(m.e)] [SekihaN(m.f)] [a[2]] [O.icon]"

proc/SekihaN(v)
	return num2text(v, 12)

proc/EnergyFXSekihaCharge(mob/M, obj/Skills/Z, ds)
	if(M.sekiha_pending) M.sekiha_pending.Cleanup()
	var/datum/sekihafx/F = new
	M.sekiha_pending = F
	F.Start(M, ds)

/mob/EnergyFXChargeHook(obj/Skills/Z)
#if SEKIHA_ART
	if(istype(Z, /obj/Skills/Projectile/Sekiha_Tenkyoken) && glob && glob.ENERGYFX)
		var/obj/Skills/Projectile/PZ = Z
		var/ds = HasQuickCast() ? 10 * PZ.Charge / (GetQuickCast() * (1 + GetKiControlMastery() * 0.1)) : 10 * PZ.Charge / (1 + GetKiControlMastery() * 0.1)
		EnergyFXSekihaCharge(src, Z, ds)
		return 1
#endif
	return ..()

proc/EnergyFXShotAttach(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/Z)
	if(!P || !Z) return 0
	P.DriveTarget = Z.DriveTarget
#if SEKIHA_ART
	if(!istype(Z, /obj/Skills/Projectile/Sekiha_Tenkyoken) || !glob || !glob.ENERGYFX) return 0
	var/mob/M = P.Owner
	var/datum/sekihafx/F = M ? M.sekiha_pending : null
	if(F && F.done) F = null
	if(!F)
		F = new
		F.caster = M
		F.NoCharge(P)
	if(M && M.sekiha_pending == F) M.sekiha_pending = null
	F.shot = P
	P.efx_shot = F
	P.bfx_plane = P.plane
	P.plane = ENERGYFX_HIDE_PLANE
	P.Trail = null
	return 1
#else
	return 0
#endif

/obj/Skills/Projectile/_Projectile/proc/DriveHit(atom/a)
	if(!DriveTarget || !ismob(a)) return 0
	var/mob/m = a
	if(drive_mob) return m == drive_mob
	if(!MultiHit || Killed || m.Stasis) return 0
	drive_mob = m
	if(m.Guarding) m.GuardStop()
	if(m.ChargingEnergy) m.ChargeStop()
	if(PmActive())
		m.step_x = 0
		m.step_y = 0
	m.icon_state = "KB"
	m.Knockbacked = dir
	m.Knockback = MultiHit
	m.kb_start_time = world.time
	m.kb_sender = Owner
	m.previousKnockBack = MultiHit
	drive_anim = m.animate_movement
	m.animate_movement = NO_STEPS
	if(efx_shot) efx_shot.Contact(m)
	return 1

/obj/Skills/Projectile/_Projectile/proc/DriveStep()
	var/mob/m = drive_mob
	if(!m) return
	if(!m.loc || m.z != z || !m.Knockbacked)
		ProjectileFinish()
		return
	m.ContinueKB(1)
	if(!Killed && Distance > 0 && RehitEligible(LastHitAt, m, HitInterval))
		OnContact(m)

/obj/Skills/Projectile/_Projectile/proc/DriveEnd()
	var/mob/m = drive_mob
	drive_mob = null
	if(!m) return
	m.animate_movement = drive_anim
	if(m.Knockbacked) m.StopKB(1)
