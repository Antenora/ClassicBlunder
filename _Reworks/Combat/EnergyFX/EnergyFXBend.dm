#define BFX_CAR 18
#define BFX_DMP 19
#define EFXB_RIGID 0
#define EFXB_FLOW 1
#define EFXB_HEAD 2

/obj/energyfx/var/tmp/obj/energyfx/carrier/fx_car

/obj/energyfx/carrier
	icon = null
	appearance_flags = KEEP_TOGETHER

/datum/efx_piece
	var/arc = 0
	var/u0 = 0
	var/u1 = 0
	var/S0 = 0
	var/S1 = 0
	var/l = 32
	var/x0 = 0
	var/y0 = 0
	var/ex = 1
	var/ey = 0
	var/datum/efx_corner/c

/datum/efx_corner
	var/j = 0
	var/th = 0
	var/sg = 1
	var/r = 0
	var/t = 0
	var/l0 = 32
	var/l1 = 32
	var/e0x = 1
	var/e0y = 0
	var/e1x = 1
	var/e1y = 0
	var/uA = 0
	var/uB = 0
	var/tot = 0
	var/m0 = 0
	var/m1 = 0
	var/Vx = 0
	var/Vy = 0
	var/tAx = 0
	var/tAy = 0
	var/tBx = 0
	var/tBy = 0
	var/cx = 0
	var/cy = 0
	var/SA = 0
	var/SB = 0
	var/dA = 0
	var/dB = 0
	var/miter = 0
	var/tkey
	var/uid
	var/Mx = 0
	var/My = 0
	var/ebx = 1
	var/eby = 0
	var/Smid = 0
	var/dmid = 0
	var/kb = 1
	var/list/rec
	var/datum/efx_piece/pa
	var/datum/efx_piece/pb
	var/datum/efx_corner/nxt
	var/nclose = 0

/datum/efx_bend
	var/D = 32
	var/list/pieces = list()
	var/list/corners = list()
	var/sig = ""

/datum/efx_car
	var/key
	var/obj/energyfx/carrier/O
	var/plane = ENERGYFX_PAINT_PLANE
	var/blend = BLEND_DEFAULT
	var/icn
	var/icn_state
	var/bx = 0
	var/by = 0
	var/vx = 0
	var/vy = 0
	var/list/flt
	var/used_k = -1
	var/minzl = 1000000
	var/paint = 0
	var/logline

var/list/energyfx_bend_icons = list()

proc/EnergyFXBendIcon(f, st)
	var/key = "[f]|[st]"
	var/icon/I = energyfx_bend_icons[key]
	if(!I)
		I = icon(f, st)
		energyfx_bend_icons += key
		energyfx_bend_icons[key] = I
	return I

proc/EnergyFXHerm(x, m0, tot, m1)
	return (x * x * x - 2 * x * x + x) * m0 + (-2 * x * x * x + 3 * x * x) * tot + (x * x * x - x * x) * m1

proc/EnergyFXHermD(x, m0, tot, m1)
	return (3 * x * x - 4 * x + 1) * m0 + (-6 * x * x + 6 * x) * tot + (3 * x * x - 2 * x) * m1

proc/EnergyFXHermInv(S, m0, tot, m1)
	var/x = clamp(S / tot, 0, 1)
	for(var/i = 1 to 16)
		var/df = EnergyFXHermD(x, m0, tot, m1)
		if(abs(df) < 0.000001) break
		var/nx = clamp(x - (EnergyFXHerm(x, m0, tot, m1) - S) / df, 0, 1)
		if(abs(nx - x) < 0.0000005)
			x = nx
			break
		x = nx
	return x

var/list/ENERGYFX_DIR8 = list("E", "NE", "N", "NW", "W", "SW", "S", "SE")

proc/EnergyFXDirOfVec(x, y)
	var/i = round(arctan(x, y) / 45 + 0.5)
	i = ((i % 8) + 8) % 8
	return ENERGYFX_DIR8[i + 1]

proc/EnergyFXBendClass(fam)
	switch(fam)
		if("Stamp", "Surge", "Bloom", "End", "Bead", "Sheath") return EFXB_FLOW
		if("Head", "Impact") return EFXB_HEAD
	return EFXB_RIGID

/datum/efx_bend/proc/Build(list/px, list/py, d0, dh, Dv)
	D = Dv
	pieces = list()
	corners = list()
	var/n = px.len
	var/list/a0 = BeamFXDirVec(d0)
	var/list/ah = BeamFXDirVec(dh)
	var/ext = ENERGYFX_BEND_EXT
	var/list/VX = list(px[1] - a0[1] * 32 * ext) + px + list(px[n] + ah[1] * 32 * ext)
	var/list/VY = list(py[1] - a0[2] * 32 * ext) + py + list(py[n] + ah[2] * 32 * ext)
	var/list/U = list(-ext)
	for(var/i = 0 to n - 1)
		U += i
	U += n - 1 + ext
	var/nv = VX.len
	var/list/segl = list()
	for(var/k = 1 to nv - 1)
		segl += max(0.000001, sqrt((VX[k + 1] - VX[k]) ** 2 + (VY[k + 1] - VY[k]) ** 2))
	var/list/cum = list(0)
	for(var/k = 1 to segl.len)
		cum += cum[k] + segl[k]
	for(var/j = 2 to nv - 1)
		var/v0x = VX[j] - VX[j - 1]
		var/v0y = VY[j] - VY[j - 1]
		var/v1x = VX[j + 1] - VX[j]
		var/v1y = VY[j + 1] - VY[j]
		var/th = arctan(v0x * v1x + v0y * v1y, v0x * v1y - v0y * v1x)
		if(abs(th) < 0.01) continue
		var/datum/efx_corner/C = new
		C.j = j
		C.th = th
		C.sg = (th > 0) ? 1 : -1
		C.l0 = segl[j - 1] / (U[j] - U[j - 1])
		C.l1 = segl[j] / (U[j + 1] - U[j])
		C.e0x = v0x / segl[j - 1]
		C.e0y = v0y / segl[j - 1]
		C.e1x = v1x / segl[j]
		C.e1y = v1y / segl[j]
		C.Vx = VX[j]
		C.Vy = VY[j]
		corners += C
	for(var/i = 1 to corners.len)
		var/datum/efx_corner/C = corners[i]
		if(abs(C.th) > 90.01)
			C.miter = 1
			continue
		var/datum/efx_corner/Cp = (i > 1) ? corners[i - 1] : null
		var/datum/efx_corner/Cn = (i < corners.len) ? corners[i + 1] : null
		var/prev = Cp ? cum[C.j] - cum[Cp.j] : 1000000000
		var/nxt = Cn ? cum[Cn.j] - cum[C.j] : 1000000000
		var/gap = min(prev, nxt)
		C.r = (gap >= 2 * ENERGYFX_BEND_R_WIDE * tan(abs(C.th) / 2)) ? ENERGYFX_BEND_R_WIDE : ENERGYFX_BEND_R
		C.t = C.r * tan(abs(C.th) / 2)
	for(var/i = 1 to corners.len - 1)
		var/datum/efx_corner/C1 = corners[i]
		var/datum/efx_corner/C2 = corners[i + 1]
		if(C1.t + C2.t > cum[C2.j] - cum[C1.j] + 0.001)
			C1.miter = 1
			C2.miter = 1
	for(var/datum/efx_corner/C in corners)
		if(C.miter)
			C.r = 0
			C.t = 0
		var/a = C.t / C.l0
		var/b = C.t / C.l1
		C.uA = U[C.j] - a
		C.uB = U[C.j] + b
		C.tAx = C.Vx - C.e0x * C.t
		C.tAy = C.Vy - C.e0y * C.t
		C.tBx = C.Vx + C.e1x * C.t
		C.tBy = C.Vy + C.e1y * C.t
		if(!C.miter)
			C.tot = C.r * abs(C.th) * 3.14159265 / 180
			C.m0 = C.l0 * (a + b)
			C.m1 = C.l1 * (a + b)
			C.cx = C.tAx - C.e0y * C.r * C.sg
			C.cy = C.tAy + C.e0x * C.r * C.sg
		var/k = round(abs(C.th) / 45 + 0.5)
		var/hin = EnergyFXDirOfVec(C.e0x, C.e0y)
		if(k >= 4) C.tkey = "[hin]U180"
		else if(k == 3) C.tkey = "[hin][C.sg > 0 ? "L" : "R"]135"
		else if(C.miter) C.tkey = "[hin][C.sg > 0 ? "L" : "R"][45 * k]M"
		else C.tkey = "[hin][C.sg > 0 ? "L" : "R"][45 * k][C.r]"
		C.uid = "[C.j]_[C.tkey]"
		C.rec = ENERGYFX_BEND_TYPES[C.tkey]
	var/cur = U[1]
	var/S = 0
	var/datum/efx_piece/last
	for(var/datum/efx_corner/C in corners)
		var/datum/efx_piece/P = Lin(cur, C.uA, U, VX, VY, segl, S)
		S = P.S1
		if(last && last.arc) last.c.pb = P
		C.pa = P
		if(!C.miter)
			var/datum/efx_piece/A = new
			A.arc = 1
			A.u0 = C.uA
			A.u1 = C.uB
			A.S0 = S
			A.S1 = S + C.tot
			A.c = C
			C.SA = A.S0
			C.SB = A.S1
			S = A.S1
			pieces += A
			last = A
		else
			C.SA = S
			C.SB = S
			last = new /datum/efx_piece
			last.arc = 1
			last.c = C
		cur = C.uB
	var/datum/efx_piece/PL = Lin(cur, U[nv], U, VX, VY, segl, S)
	if(last && last.arc) last.c.pb = PL
	var/s0 = SofU(0)
	for(var/datum/efx_piece/P in pieces)
		P.S0 -= s0
		P.S1 -= s0
	for(var/i = 1 to corners.len)
		var/datum/efx_corner/C = corners[i]
		C.SA -= s0
		C.SB -= s0
		C.dA = C.uA * D
		C.dB = C.uB * D
		if(i < corners.len)
			C.nxt = corners[i + 1]
			C.nclose = (C.nxt.SA - C.SB < ENERGYFX_BEND_REACH) ? 1 : 0
		if(C.miter) continue
		var/half = C.sg * abs(C.th) / 2
		var/ca = cos(half)
		var/sa = sin(half)
		C.ebx = C.e0x * ca - C.e0y * sa
		C.eby = C.e0x * sa + C.e0y * ca
		var/rx = C.tAx - C.cx
		var/ry = C.tAy - C.cy
		C.Mx = C.cx + rx * ca - ry * sa
		C.My = C.cy + rx * sa + ry * ca
		C.Smid = C.SA + C.tot / 2
		C.dmid = (C.uA + EnergyFXHermInv(C.tot / 2, C.m0, C.tot, C.m1) * (C.uB - C.uA)) * D
		C.kb = C.tot / max(0.000001, C.dB - C.dA)

/datum/efx_bend/proc/Lin(u0, u1, list/U, list/VX, list/VY, list/segl, S)
	var/datum/efx_piece/P = new
	P.u0 = u0
	P.u1 = max(u0, u1)
	var/mid = (P.u0 + P.u1) / 2
	var/k = U.len - 1
	for(var/i = 1 to U.len - 1)
		if(mid <= U[i + 1])
			k = i
			break
	P.l = segl[k] / (U[k + 1] - U[k])
	P.ex = (VX[k + 1] - VX[k]) / segl[k]
	P.ey = (VY[k + 1] - VY[k]) / segl[k]
	var/f = (u0 - U[k]) / (U[k + 1] - U[k])
	P.x0 = VX[k] + (VX[k + 1] - VX[k]) * f
	P.y0 = VY[k] + (VY[k + 1] - VY[k]) * f
	P.S0 = S
	P.S1 = S + (P.u1 - P.u0) * P.l
	pieces += P
	return P

/datum/efx_bend/proc/SofU(u)
	var/datum/efx_piece/F = pieces[1]
	if(u <= F.u0) return F.S0 + (u - F.u0) * F.l
	var/datum/efx_piece/L = pieces[pieces.len]
	if(u >= L.u1) return L.S1 + (u - L.u1) * L.l
	for(var/datum/efx_piece/P in pieces)
		if(u <= P.u1)
			if(!P.arc) return P.S0 + (u - P.u0) * P.l
			var/datum/efx_corner/C = P.c
			return P.S0 + EnergyFXHerm((u - P.u0) / (P.u1 - P.u0), C.m0, C.tot, C.m1)
	return L.S1

/datum/efx_bend/proc/SofD(d)
	return SofU(d / D)

/datum/efx_bend/proc/DofS(S)
	var/datum/efx_piece/F = pieces[1]
	if(S <= F.S0) return (F.u0 + (S - F.S0) / F.l) * D
	var/datum/efx_piece/L = pieces[pieces.len]
	if(S >= L.S1) return (L.u1 + (S - L.S1) / L.l) * D
	for(var/datum/efx_piece/P in pieces)
		if(S <= P.S1)
			if(!P.arc) return (P.u0 + (S - P.S0) / P.l) * D
			var/datum/efx_corner/C = P.c
			return (P.u0 + EnergyFXHermInv(S - P.S0, C.m0, C.tot, C.m1) * (P.u1 - P.u0)) * D
	return L.u1 * D

/datum/efx_bend/proc/Eval(S)
	var/datum/efx_piece/P = pieces[1]
	if(S > P.S0)
		P = pieces[pieces.len]
		if(S < P.S1)
			for(var/datum/efx_piece/Q in pieces)
				if(S <= Q.S1)
					P = Q
					break
	if(!P.arc) return list(P.x0 + P.ex * (S - P.S0), P.y0 + P.ey * (S - P.S0), P.ex, P.ey)
	var/datum/efx_corner/C = P.c
	var/ang = C.sg * (S - P.S0) / C.r * 57.2957795
	var/rx = C.tAx - C.cx
	var/ry = C.tAy - C.cy
	var/ca = cos(ang)
	var/sa = sin(ang)
	return list(C.cx + rx * ca - ry * sa, C.cy + rx * sa + ry * ca, C.e0x * ca - C.e0y * sa, C.e0x * sa + C.e0y * ca)

/datum/efx_bend/proc/LinAt(v, byS)
	for(var/datum/efx_piece/P in pieces)
		if(P.arc) continue
		if(byS)
			if(v >= P.S0 - 0.001 && v <= P.S1 + 0.001) return P
		else if(v >= P.u0 * D - 0.001 && v <= P.u1 * D + 0.001) return P
	var/datum/efx_piece/F = pieces[1]
	var/datum/efx_piece/L = pieces[pieces.len]
	if(byS) return (v < F.S0) ? F : L
	return (v < F.u0 * D) ? F : L

/datum/efx_fork
	var/fat = 0
	var/SJ = 0
	var/k1 = 1
	var/er = 0
	var/sbe = 0
	var/list/es
	var/list/sb
	var/Vx = 0
	var/Vy = 0
	var/list/rec
	var/hk

/datum/efx_fork/proc/Setup(datum/beamfx/F, fork_at)
	var/R = ENERGYFX_FORK_R
	fat = fork_at
	var/td = (fork_at + 1) * F.D
	SJ = td - F.D - R * tan(22.5)
	var/list/dv = BeamFXDirVec(F.d)
	var/list/dv2 = BeamFXDirVec(EnergyFXDirOfVec(dv[1] * cos(45) - dv[2] * sin(45), dv[1] * sin(45) + dv[2] * cos(45)))
	var/d2 = (dv2[1] && dv2[2]) ? 32 * sqrt(2) : 32
	k1 = d2 / F.D
	er = R * 3.14159265 / 4
	es = list()
	sb = list()
	var/acc = 0
	var/kp
	for(var/i = 0 to 128)
		var/e = er * i / 128
		var/q = i / 128
		var/kk = 1 + (k1 - 1) * q * q * (3 - 2 * q)
		if(i > 0) acc += 0.5 * (kk + kp) * (er / 128)
		es += e
		sb += acc
		kp = kk
	sbe = acc
	Vx = round(F.Ox + F.ax * fork_at * F.D, 1)
	Vy = round(F.Oy + F.ay * fork_at * F.D, 1)
	hk = F.d
	rec = ENERGYFX_FORK_TYPES[hk]

/datum/efx_fork/proc/SofD(d)
	var/e = d - SJ
	if(e <= 0) return d
	if(e > er) return SJ + sbe + k1 * (e - er)
	var/f = e / er * 128
	var/i = min(127, floor(f))
	var/w = f - i
	return SJ + sb[i + 1] + (sb[i + 2] - sb[i + 1]) * w

/datum/efx_fork/proc/BranchXY(datum/beamfx/F, S, lat, sig)
	var/R = ENERGYFX_FORK_R
	var/sbv = max(S - SJ, 0)
	var/sarc = R * 3.14159265 / 4
	var/ph = min(sbv, sarc) / R * 57.2957795
	var/rest = max(sbv - sarc, 0)
	var/al = min(S, SJ) + R * sin(ph) + rest * cos(45)
	var/lt = sig * (R * (1 - cos(ph)) + rest * sin(45))
	var/tx = F.ax * cos(ph) + F.nx * sig * sin(ph)
	var/ty = F.ay * cos(ph) + F.ny * sig * sin(ph)
	var/px = F.Ox + F.ax * al + F.nx * lt
	var/py = F.Oy + F.ay * al + F.ny * lt
	return list(px - ty * lat, py + tx * lat, tx, ty)

/datum/efx_fork/proc/LineXY(datum/beamfx/F, S, lat, sig)
	var/R = ENERGYFX_FORK_R
	var/kx = F.Ox + F.ax * (SJ + R * sin(45)) + F.nx * sig * R * (1 - cos(45))
	var/ky = F.Oy + F.ay * (SJ + R * sin(45)) + F.ny * sig * R * (1 - cos(45))
	var/ex = F.ax * cos(45) - F.ay * sin(45) * sig
	var/ey = F.ax * sin(45) * sig + F.ay * cos(45)
	var/al = S - (SJ + R * 3.14159265 / 4)
	return list(kx + ex * al - ey * lat, ky + ey * al + ex * lat)

/datum/beamfx/var/datum/efx_bend/bgeo
/datum/beamfx/var/datum/efx_fork/fgeo
/datum/beamfx/var/list/bcars
/datum/beamfx/var/list/bh_x
/datum/beamfx/var/list/bh_y
/datum/beamfx/var/b_sig = ""
/datum/beamfx/var/fork_dT
/datum/beamfx/var/fork_t
/datum/beamfx/var/fork_touch
/datum/beamfx/var/fork_raw = 0
/datum/beamfx/var/list/fork_q
/datum/beamfx/var/list/fork_split
/datum/beamfx/var/fork_handed = 0
/datum/beamfx/var/list/fork_arms

/datum/beamfx/proc/BendOn()
	return bgeo && bgeo.corners.len

/datum/beamfx/proc/TouchState(H)
	if(isnull(H) || isnull(fork_dT)) return 0
	var/st = Vg * BEAMFX_FR
	if(H >= fork_dT + st) return 2
	return (H >= fork_dT - st) ? 1 : 0

/datum/beamfx/proc/RawHr(t, qf)
	fork_raw = 1
	var/H = Hr(t, qf, 0)
	fork_raw = 0
	return H

/datum/beamfx/proc/ForkSplit(fi)
	if(!fgeo || isnull(t0)) return 0
	if(!fork_split) fork_split = list()
	var/key = "[fi]"
	var/v = fork_split[key]
	if(isnull(v))
		v = (TouchState(RawHr(FT(fi), fi)) == 2) ? 1 : 0
		if(fi <= 2 * k + 1)
			fork_split += key
			fork_split[key] = v
	return v

/datum/beamfx/Hr(t, qf, strict)
	var/H = ..()
	if(fork_raw || isnull(fork_dT) || isnull(H)) return H
	return (TouchState(H) == 1) ? fork_dT : H

/datum/beamfx/Q(i, list/hl)
	if(isnull(fork_dT) || isnull(t0)) return ..()
	if(!fork_q) fork_q = list()
	var/key = "[i]"
	var/v = fork_q[key]
	if(!isnull(v)) return v
	if(i > 2 * k + 1) return ..(i, Holds())
	if(isnull(rm_ih))
		var/stt = TouchState(RawHr(FT(i), i))
		if(stt == 2)
			rm_ih = i
			rm_fdet = i
			rm_changed = 1
		else if(stt == 1)
			if(isnull(fork_touch)) fork_touch = i
			v = fork_touch
	if(isnull(v)) v = ..(i, Holds())
	fork_q += key
	fork_q[key] = v
	return v

/datum/beamfx/Tick(kk)
	..()
	if(isnull(fork_dT) || !isnull(fork_t) || isnull(t0)) return
	var/now = FT(2 * kk)
	for(var/jj = 0 to 1)
		if(TouchState(RawHr(now + jj * BEAMFX_FR, 2 * kk + jj)))
			fork_t = now + jj * BEAMFX_FR
			t_hit = fork_t
			rm_changed = 1
			break

/datum/beamfx/HitK(t, fi)
	if(isnull(fork_dT)) return ..()
	if(isnull(fork_t) || t < fork_t) return 0
	var/kk = BeamFXEaseOut((t - fork_t) / 0.1) * (0.9 + 0.1 * sin(360 * t / 0.11))
	if(!isnull(release_t) && t > release_t) kk *= max(0, 1 - (t - release_t) / 0.3)
	return kk

/datum/beamfx/TargetHeld(f)
	if(isnull(fork_dT)) return ..()
	var/t = FT(f)
	return (!isnull(fork_t) && t >= fork_t && (isnull(release_t) || t <= release_t)) ? 1 : 0

/datum/beamfx/TargetEnding(t2)
	if(isnull(fork_dT)) return ..()
	return (!isnull(release_t) && t2 > release_t) ? 1 : 0

/datum/beamfx/ChainPair(datum/bfx_obj/o)
	if(fgeo) return 0
	return ..()

/datum/beamfx/MapPt(x, y)
	var/rx = x - Ox
	var/ry = y - Oy
	var/dc = rx * ax + ry * ay
	var/lat = rx * nx + ry * ny
	if(fgeo)
		var/S = fgeo.SofD(dc)
		if(S > fgeo.SJ)
			var/list/P = fgeo.BranchXY(src, S, lat, 1)
			return list(P[1], P[2], arctan(P[3], P[4]))
		return list(x, y, ang)
	if(!BendOn()) return list(x, y, ang)
	var/list/E = bgeo.Eval(bgeo.SofD(dc))
	return list(E[1] - E[4] * lat, E[2] + E[3] * lat, arctan(E[3], E[4]))

/datum/beamfx/SpeckEmitter(region, x, y, rate, v1, v2, l1, l2, cnt)
	var/obj/energyfx/emit/O = ..()
	if(!O || !fgeo) return O
	var/rx = x - Ox
	var/ry = y - Oy
	var/S = fgeo.SofD(rx * ax + ry * ay)
	if(S <= fgeo.SJ) return O
	var/list/P = fgeo.BranchXY(src, S, rx * nx + ry * ny, -1)
	var/obj/energyfx/emit/O2 = ..(region, x, y, rate, v1, v2, l1, l2, cnt)
	if(!O2) return O
	if(EnergyFXPlace(O2, P[1], P[2], z))
		var/particles/PP = O2.particles
		var/a2 = arctan(P[3], P[4])
		PP.transform = matrix(cos(a2), -sin(a2), P[1] - O2.fx_bx, sin(a2), cos(a2), P[2] - O2.fx_by)
	spk_live += list(list(O2, k + 2, k + BEAMFX_SPK_FREE + 2))
	return O

/datum/beamfx/proc/RebuildChains()
	for(var/datum/bfx_obj/o in objs)
		if(!o.pre_done) continue
		if(o.pobjs)
			for(var/obj/energyfx/O in o.pobjs)
				EnergyFXFree(O)
		o.pobjs = null
		o.pre_done = 0
		o.pre_specs = null

/datum/beamfx/ParticleSpec(datum/bfx_obj/o, t)
	var/list/L = ..()
	if(!L || !(fgeo || BendOn())) return L
	var/list/out = list()
	if(fgeo)
		for(var/sig in list(1, -1))
			for(var/list/sp in L)
				out += list(MapRigidSpec(sp, sig))
		return out
	for(var/list/sp in L)
		out += list(MapRigidSpec(sp, 0))
	return out

/datum/beamfx/proc/MapRigidSpec(list/sp, sig)
	var/list/s2 = sp.Copy()
	var/rx = sp[BFX_X] - Ox
	var/ry = sp[BFX_Y] - Oy
	var/dc = rx * ax + ry * ay
	var/lat = rx * nx + ry * ny
	if(fgeo)
		var/S = fgeo.SofD(dc)
		if(S <= fgeo.SJ)
			if(sig < 0) s2[BFX_ALPHA] = 0
			return s2
		var/list/P = fgeo.BranchXY(src, S, lat, sig)
		s2[BFX_X] = P[1]
		s2[BFX_Y] = P[2]
		s2[BFX_ANG] = sp[BFX_ANG] + arctan(P[3], P[4]) - ang
		return s2
	var/list/E = bgeo.Eval(bgeo.SofD(dc))
	s2[BFX_X] = E[1] - E[4] * lat
	s2[BFX_Y] = E[2] + E[3] * lat
	s2[BFX_ANG] = sp[BFX_ANG] + arctan(E[3], E[4]) - ang
	return s2

/datum/beamfx/proc/BandKey(light, zl, damp)
	if(damp) return "D"
	if(light) return GrayV2() ? "G" : "L"
	return "p[round(zl * 10)]"

/datum/beamfx/proc/BandPlane(band)
	switch(copytext(band, 1, 2))
		if("D") return ENERGYFX_DAMP_PLANE
		if("G") return ENERGYFX_GLIGHT_PLANE
		if("L") return ENERGYFX_LIGHT_PLANE
	return ENERGYFX_PAINT_PLANE

/datum/beamfx/proc/CarDesc(key, band, zl)
	if(!bcars) bcars = list()
	var/datum/efx_car/CD = bcars[key]
	if(!CD)
		CD = new
		CD.key = key
		CD.plane = BandPlane(band)
		CD.blend = (CD.plane == ENERGYFX_LIGHT_PLANE || CD.plane == ENERGYFX_GLIGHT_PLANE) ? BLEND_ADD : BLEND_DEFAULT
		CD.paint = (CD.plane == ENERGYFX_PAINT_PLANE) ? 1 : 0
		bcars += key
		bcars[key] = CD
		CD.used_k = -1
	if(CD.used_k != k)
		CD.used_k = k
		CD.minzl = zl
	else if(zl < CD.minzl) CD.minzl = zl
	return CD

/datum/beamfx/proc/CarBend(datum/efx_corner/C, piece, band, zl, cls)
	var/key = "[C.uid]|[piece]|[band]"
	if(piece == "B" && C.nclose && C.nxt && C.nxt.rec) key += "|[C.nxt.uid]"
	var/datum/efx_car/CD = CarDesc(key, band, zl)
	if(CD.flt) return key
	var/list/R = C.rec
	CD.vx = C.Vx
	CD.vy = C.Vy
	if(piece == "A" || piece == "B")
		var/cxo = (piece == "A") ? R[4] : R[6]
		var/cyo = (piece == "A") ? R[5] : R[7]
		CD.bx = C.Vx + cxo - 16
		CD.by = C.Vy + cyo - 16
		CD.flt = list(filter(type = "alpha", icon = EnergyFXBendIcon(R[1], piece)))
		CD.logline = "[R[1]]|[piece]|[C.Vx + cxo]|[C.Vy + cyo]"
		if(piece == "B" && C.nclose && C.nxt && C.nxt.rec)
			var/list/R2 = C.nxt.rec
			var/ox = (C.nxt.Vx + R2[4]) - (C.Vx + cxo)
			var/oy = (C.nxt.Vy + R2[5]) - (C.Vy + cyo)
			CD.flt += filter(type = "alpha", icon = EnergyFXBendIcon(R2[1], "A"), x = ox, y = oy)
			CD.logline += "|[R2[1]]|A|[C.nxt.Vx + R2[4]]|[C.nxt.Vy + R2[5]]"
		return key
	var/far = (piece == "CF")
	var/f = far ? R[3] : R[2]
	var/b0 = far ? 12 : 8
	var/w = R[b0 + 2]
	var/h = R[b0 + 3]
	var/sz = R[16 + (far ? 2 : 0) + ((cls == EFXB_HEAD) ? 1 : 0)]
	CD.icn = f
	CD.icn_state = "blank"
	CD.bx = C.Vx + R[b0] - w / 2
	CD.by = C.Vy + R[b0 + 1] - h / 2
	var/mst = (cls == EFXB_HEAD) ? "H" : "F"
	CD.flt = list(filter(type = "displace", icon = EnergyFXBendIcon(f, mst), size = sz), filter(type = "alpha", icon = EnergyFXBendIcon(f, "C")))
	CD.logline = "[f]|[mst]|[sz]|[C.Vx + R[b0]]|[C.Vy + R[b0 + 1]]"
	return key

/datum/beamfx/proc/CarFork(piece, band, zl, cls)
	var/key = "fork|[piece]|[band]"
	var/datum/efx_car/CD = CarDesc(key, band, zl)
	if(CD.flt) return key
	var/list/R = fgeo.rec
	CD.vx = fgeo.Vx
	CD.vy = fgeo.Vy
	switch(piece)
		if("P", "B+", "B-")
			var/bi = (piece == "P") ? 3 : ((piece == "B+") ? 5 : 7)
			CD.bx = fgeo.Vx + R[bi] - 16
			CD.by = fgeo.Vy + R[bi + 1] - 16
			CD.flt = list(filter(type = "alpha", icon = EnergyFXBendIcon(R[1], piece)))
			CD.logline = "[R[1]]|[piece]|[fgeo.Vx + R[bi]]|[fgeo.Vy + R[bi + 1]]"
		else
			var/mst = (cls == EFXB_HEAD) ? "JH" : "JF"
			var/sz = R[13 + ((cls == EFXB_HEAD) ? 1 : 0)]
			CD.icn = R[2]
			CD.icn_state = "blank"
			CD.bx = fgeo.Vx + R[9] - R[11] / 2
			CD.by = fgeo.Vy + R[10] - R[12] / 2
			CD.flt = list(filter(type = "displace", icon = EnergyFXBendIcon(R[2], mst), size = sz), filter(type = "alpha", icon = EnergyFXBendIcon(R[2], copytext(piece, 1, 4))))
			CD.logline = "[R[2]]|[mst]|[sz]|[fgeo.Vx + R[9]]|[fgeo.Vy + R[10]]|[copytext(piece, 1, 4)]"
	return key

/datum/beamfx/proc/CarObj(datum/efx_car/CD)
	if(CD.O) return CD.O
	var/turf/T = locate(floor(CD.vx / 32) + 1, floor(CD.vy / 32) + 1, z)
	if(!T) return null
	var/obj/energyfx/carrier/O = EnergyFXGet(/obj/energyfx/carrier, src)
	if(!O) return null
	O.icon = CD.icn
	O.icon_state = CD.icn_state
	O.plane = CD.plane
	O.blend_mode = CD.blend
	O.appearance_flags = KEEP_TOGETHER
	O.layer = CD.paint ? CD.minzl - 0.000003 : 1
	O.filters = CD.flt
	O.loc = T
	O.pixel_x = CD.bx - (T.x - 1) * 32
	O.pixel_y = CD.by - (T.y - 1) * 32
	CD.O = O
	if(logging) world.log << "BFXK[log_tag] [CD.key]|[CD.plane]|[CD.blend]|[CD.bx]|[CD.by]|[CD.logline]"
	return O

/datum/beamfx/proc/CarFree(datum/efx_car/CD)
	var/obj/energyfx/carrier/O = CD.O
	CD.O = null
	if(!O) return
	for(var/obj/energyfx/C in O.vis_contents)
		C.fx_car = null
	O.filters = null
	O.icon = null
	O.icon_state = null
	O.pixel_x = 0
	O.pixel_y = 0
	EnergyFXFree(O)

/datum/beamfx/proc/CarTick()
	for(var/key in bcars.Copy())
		var/datum/efx_car/CD = bcars[key]
		if(CD.used_k == k)
			if(CD.O && CD.paint) CD.O.layer = CD.minzl - 0.000003
			continue
		if(k - CD.used_k > 4 && (!CD.O || !CD.O.vis_contents.len))
			CarFree(CD)
			bcars -= key

/datum/beamfx/Step()
	..()
	if(bcars && bcars.len) CarTick()

/datum/beamfx/Cleanup()
	..()
	if(bcars)
		for(var/key in bcars)
			CarFree(bcars[key])
		bcars = null

/datum/beamfx/NewObj(list/sp, pr = 0)
	if(sp.len < BFX_DMP || !sp[BFX_CAR]) return ..()
	var/datum/efx_car/CD = bcars ? bcars[sp[BFX_CAR]] : null
	if(!CD) return null
	var/obj/energyfx/carrier/CO = CarObj(CD)
	if(!CO) return null
	var/obj/energyfx/O = ..(sp, 0)
	if(!O) return null
	if(O.efx_damp) O.vis_contents -= O.efx_damp
	if(sp[BFX_DMP])
		var/list/gf = ENERGYFX_GRAY_FAM[sp[BFX_FAM]]
		O.icon = gf[2]
		O.plane = ENERGYFX_DAMP_PLANE
		O.blend_mode = BLEND_DEFAULT
	O.loc = null
	CO.vis_contents += O
	O.fx_car = CO
	O.fx_bx = CD.bx + O.fx_w / 2
	O.fx_by = CD.by + O.fx_h / 2
	O.transform = BeamFXXform(sp, O.fx_bx, O.fx_by)
	return O

/datum/beamfx/proc/EmitCopy(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr, car, damp)
	var/list/F = frame_specs[j]
	Emit(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	var/list/sp = F[key]
	if(sp)
		sp.len = BFX_DMP
		sp[BFX_CAR] = car
		sp[BFX_DMP] = damp

/datum/beamfx/var/emit_raw = 0

/datum/beamfx/Emit(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr = 0)
	if(emit_raw) return ..()
	var/forking = fgeo ? ForkSplit(ctx_f) : 0
	if(!forking && !BendOn()) return ..()
	var/cls = EnergyFXBendClass(fam)
	var/rx = x - Ox
	var/ry = y - Oy
	var/dc = rx * ax + ry * ay
	var/lat = rx * nx + ry * ny
	emit_raw = 1
	if(forking) ForkEmit(cls, dc, lat, j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	else BendEmit(cls, dc, lat, j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	emit_raw = 0

/datum/beamfx/proc/SpriteExt(fam, a, sx, sy, pre, lat)
	var/list/fw = BEAMFX_FAM[fam]
	var/hw = fw[2] / 2 * abs(sx)
	var/hh = fw[3] / 2 * abs(sy)
	if(pre) hw = sqrt(hw * hw + hh * hh)
	if(pre) hh = hw
	var/rel = a - ang
	return list(abs(cos(rel)) * hw + abs(sin(rel)) * hh + 1.5, abs(lat) + abs(sin(rel)) * hw + abs(cos(rel)) * hh)

/datum/beamfx/proc/BendEmit(cls, dc, lat, j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	if(cls == EFXB_RIGID)
		var/list/E = bgeo.Eval(bgeo.SofD(dc))
		Emit(j, key, fam, st, light, E[1] - E[4] * lat, E[2] + E[3] * lat, a + arctan(E[3], E[4]) - ang, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
		return
	var/list/ex = SpriteExt(fam, a, sx, sy, pre, lat)
	var/head = (cls == EFXB_HEAD)
	var/Sc = head ? bgeo.SofD(dc) : 0
	var/lo = (head ? Sc : dc) - ex[1]
	var/hi = (head ? Sc : dc) + ex[1]
	var/list/touch = list()
	for(var/datum/efx_corner/C in bgeo.corners)
		if(!C.rec) continue
		var/cA = head ? C.SA : C.dA
		var/cB = head ? C.SB : C.dB
		if(cB >= lo - 0.5 && cA <= hi + 0.5) touch += C
	if(!touch.len)
		var/datum/efx_piece/P = bgeo.LinAt(head ? Sc : dc, head)
		var/list/R = RunXY(P, dc, lat, head, Sc)
		Emit(j, key, fam, st, light, R[1], R[2], a + R[3], sx * R[4], sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
		return
	var/band = BandKey(light, zl, 0)
	var/dband = (!light && GrayV2() && ENERGYFX_GRAY_FAM[fam] && ENERGYFX_GRAY_FAM[fam][2]) ? "D" : null
	var/pr2 = 0
	var/datum/efx_corner/C1 = touch[1]
	if(lo < (head ? C1.SA : C1.dA))
		var/list/RA = RunXY(C1.pa, dc, lat, head, Sc)
		CopyOut(j, "[key]@[C1.uid]A", CarBend(C1, "A", band, zl, cls), dband ? CarBend(C1, "A", dband, zl, cls) : null, fam, st, light, RA[1], RA[2], a + RA[3], sx * RA[4], sy, pre, alpha, layer, order, tag, fade, seed, zl, pr2)
	for(var/datum/efx_corner/C in touch)
		if(!C.miter)
			var/al = head ? (Sc - C.Smid) : C.kb * (dc - C.dmid)
			var/cxp = C.Mx + C.ebx * al - C.eby * lat
			var/cyp = C.My + C.eby * al + C.ebx * lat
			var/ca = a - ang + arctan(C.ebx, C.eby)
			var/csx = head ? sx : sx * C.kb
			CopyOut(j, "[key]@[C.uid]N", CarBend(C, "CN", "[band][head ? "H" : "F"]", zl, cls), dband ? CarBend(C, "CN", "D[head ? "H" : "F"]", zl, cls) : null, fam, st, light, cxp, cyp, ca, csx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr2)
			if(ex[2] > ENERGYFX_BEND_NEAR_L - 2)
				CopyOut(j, "[key]@[C.uid]F", CarBend(C, "CF", "[band][head ? "H" : "F"]", zl, cls), dband ? CarBend(C, "CF", "D[head ? "H" : "F"]", zl, cls) : null, fam, st, light, cxp, cyp, ca, csx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr2)
		if(hi > (head ? C.SB : C.dB) && C.pb)
			var/list/RB = RunXY(C.pb, dc, lat, head, Sc)
			CopyOut(j, "[key]@[C.uid]B", CarBend(C, "B", band, zl, cls), dband ? CarBend(C, "B", dband, zl, cls) : null, fam, st, light, RB[1], RB[2], a + RB[3], sx * RB[4], sy, pre, alpha, layer, order, tag, fade, seed, zl, pr2)

/datum/beamfx/proc/CopyOut(j, key, car, dcar, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	EmitCopy(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr, car, 0)
	if(dcar) EmitCopy(j, "[key]d", fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr, dcar, 1)

/datum/beamfx/proc/RunXY(datum/efx_piece/P, dc, lat, head, Sc)
	var/rho = head ? 1 : P.l / bgeo.D
	var/S = head ? Sc : P.S0 + (dc - P.u0 * bgeo.D) * rho
	var/al = S - P.S0
	return list(P.x0 + P.ex * al - P.ey * lat, P.y0 + P.ey * al + P.ex * lat, arctan(P.ex, P.ey) - ang, rho)

/datum/beamfx/proc/ForkEmit(cls, dc, lat, j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
	var/SJ = fgeo.SJ
	if(cls == EFXB_RIGID)
		var/S = fgeo.SofD(dc)
		if(S <= SJ)
			Emit(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
			return
		for(var/sig in list(1, -1))
			var/list/P = fgeo.BranchXY(src, S, lat, sig)
			Emit(j, "[key]@[sig > 0 ? "+" : "-"]", fam, st, light, P[1], P[2], a + arctan(P[3], P[4]) - ang, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
		return
	var/list/ex = SpriteExt(fam, a, sx, sy, pre, lat)
	var/head = (cls == EFXB_HEAD)
	var/Sc = head ? fgeo.SofD(dc) : dc
	var/lo = Sc - ex[1]
	var/hi = Sc + ex[1]
	if(hi < SJ - ENERGYFX_FORK_BACK || !fgeo.rec)
		Emit(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)
		return
	var/band = BandKey(light, zl, 0)
	var/dband = (!light && GrayV2() && ENERGYFX_GRAY_FAM[fam] && ENERGYFX_GRAY_FAM[fam][2]) ? "D" : null
	var/px = x + ax * (Sc - dc)
	var/py = y + ay * (Sc - dc)
	var/cb = head ? "H" : "F"
	if(lo < SJ + ENERGYFX_FORK_J_AHEAD)
		CopyOut(j, "[key]@P", CarFork("P", band, zl, cls), dband ? CarFork("P", dband, zl, cls) : null, fam, st, light, px, py, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, 0)
	var/injz = (hi >= SJ - ENERGYFX_FORK_J_BACK && lo <= SJ + ENERGYFX_FORK_J_AHEAD)
	for(var/sig in list(1, -1))
		var/sgn = (sig > 0) ? "+" : "-"
		var/Sl = head ? Sc : SJ + fgeo.sbe + fgeo.k1 * (dc - SJ - fgeo.er)
		var/list/B = fgeo.LineXY(src, Sl, lat, sig)
		var/ba = a + 45 * sig
		var/bsx = head ? sx : sx * fgeo.k1
		if(injz)
			CopyOut(j, "[key]@JP[sgn]", CarFork("JP[sgn]", "[band][cb]", zl, cls), dband ? CarFork("JP[sgn]", "D[cb]", zl, cls) : null, fam, st, light, px, py, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, 0)
			CopyOut(j, "[key]@JB[sgn]", CarFork("JB[sgn]", "[band][cb]", zl, cls), dband ? CarFork("JB[sgn]", "D[cb]", zl, cls) : null, fam, st, light, B[1], B[2], ba, bsx, sy, pre, alpha, layer, order, tag, fade, seed, zl, 0)
		if(hi > SJ)
			CopyOut(j, "[key]@B[sgn]", CarFork("B[sgn]", band, zl, cls), dband ? CarFork("B[sgn]", dband, zl, cls) : null, fam, st, light, B[1], B[2], ba, bsx, sy, pre, alpha, layer, order, tag, fade, seed, zl, 0)

/datum/beamfx/var/bend_uids = ""

/datum/beamfx/proc/BendGeoUpdate(dh)
	if(!bh_x || bh_x.len < 2) return
	var/sig = "[bh_x.len]|[dh]"
	if(sig == b_sig) return
	b_sig = sig
	if(!bgeo) bgeo = new
	bgeo.Build(bh_x, bh_y, d, dh, D)
	var/uids = ""
	for(var/datum/efx_corner/C in bgeo.corners)
		uids += "[C.uid];"
	if(uids != bend_uids)
		bend_uids = uids
		RebuildChains()

proc/EnergyFXBendFeed(datum/beam/B, datum/beamfx/F)
	if(!ENERGYFX_BEND_ASSETS || !B.path || !B.path.len) return
	if(!F.bh_x)
		F.bh_x = list()
		F.bh_y = list()
	var/total = B.travelled + B.path.len
	while(F.bh_x.len < total)
		var/idx = F.bh_x.len - B.travelled + 1
		if(idx < 1 || idx > B.path.len) break
		var/turf/T = B.path[idx]
		if(!T) break
		F.bh_x += (T.x - 1) * 32 + 16 + B.ox
		F.bh_y += (T.y - 1) * 32 + 16 + B.oy
	F.BendGeoUpdate(BeamFXDirText(B.hdir))
	if(!F.BendOn() || !B.blocked || B.frozen) return
	var/px
	var/py
	if(F.target_mob)
		var/mob/m = F.target_mob
		px = (m.x - 1) * 32 + m.step_x + m.bound_x + m.bound_width / 2
		py = (m.y - 1) * 32 + m.step_y + m.bound_y + m.bound_height / 2
	else
		var/obj/Skills/Projectile/_Projectile/pb = BeamFXBeamBlocker(B)
		if(!pb || (pb.beam_owner && pb.beam_owner.fx)) return
		px = (pb.x - 1) * 32 + pb.step_x + pb.bound_x + pb.bound_width / 2
		py = (pb.y - 1) * 32 + pb.step_y + pb.bound_y + pb.bound_height / 2
	var/datum/efx_piece/P = F.bgeo.pieces[F.bgeo.pieces.len]
	F.target_d = F.bgeo.DofS(P.S0 + (px - P.x0) * P.ex + (py - P.y0) * P.ey)

proc/EnergyFXForkLiveArm(list/arms)
	for(var/datum/beam/A in arms)
		if(A && !A.dying) return A
	return null

proc/EnergyFXForkFeed(datum/beam/B, datum/beamfx/F)
	if(!ENERGYFX_FORK_ASSETS) return 0
	if(!F.fgeo)
		if(!B.prism_split || !B.arms || !B.fork_at) return 0
		F.fgeo = new
		F.fgeo.Setup(F, B.fork_at)
		F.fork_dT = (B.fork_at + 1) * F.D - ENERGYFX_FORK_CONTACT
		F.fork_arms = B.arms.Copy()
		var/mob/best
		var/bt = -1
		for(var/mob/m in B.hit_at)
			if(B.hit_at[m] > bt)
				bt = B.hit_at[m]
				best = m
		if(best) F.target_mob = best
		if(F.wide)
			F.bent = 1
			F.SetDir(F.d)
		F.RebuildChains()
	var/datum/beam/A = EnergyFXForkLiveArm(F.fork_arms)
	var/fa = F.fgeo.fat
	var/tail = B.parts.len ? B.travelled : fa + 1 + (A ? A.travelled : 0)
	var/head = (A && A.parts.len) ? fa + A.travelled + A.parts.len : B.travelled + B.parts.len - 1
	F.s_travelled = tail
	F.s_n = max(0, head - tail + 1)
	F.s_blocked = 0
	F.s_clash = 0
	F.target_d = null
	return 1

proc/EnergyFXForkArmTick(datum/beam/A)
	var/datum/beamfx/F = A.fork_fx
	if(!F || F.finished || F.death_k >= 0) return
	var/fa = F.fgeo.fat
	F.s_travelled = fa + 1 + A.travelled
	F.s_n = A.parts.len
	F.s_firing = 0
	F.s_blocked = 0
	F.s_clash = 0
	F.s_dead = A.dying ? 1 : 0
	F.target_d = null
	var/u0 = world.tick_usage
	try
		F.Step()
	catch(var/exception/e)
		world.log << "BEAMFX: fork step failed ([e]) @ [e.file]:[e.line]"
		F.Cleanup()
		return
	beamfx_cost += max(0, world.tick_usage - u0)
	beamfx_cost_n++

proc/EnergyFXForkHandoff(datum/beamfx/F, list/arms, datum/beam/except)
	if(!F || F.finished || !F.fgeo) return 0
	for(var/datum/beam/A in arms)
		if(A && A != except && !A.dying && A.parts.len)
			A.fork_fx = F
			A.fork_drive = 1
			F.fork_handed = 1
			return 1
	return 0
