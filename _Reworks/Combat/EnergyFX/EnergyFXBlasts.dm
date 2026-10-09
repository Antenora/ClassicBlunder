#define EFXB_TICK 0.05
#define EFXB_FR 0.025
#define EFXB_NF 16

var/list/EFXB_ROWS = list()
var/list/EFXB_ART = list()
var/list/EFXB_L2 = list()
var/list/EFXB_FIT = list()
var/datum/energyfx_look/blasts/energyfx_blast_look = new

/datum/energyfx_look/blasts
	parent_type = /datum/energyfx_look/orbs

/datum/energyfx_look/blasts/Spawn(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_row/R = EnergyFXRowOf(P.SkillPath)
	if(!R || !R.extra || !P.loc) return 0
	var/datum/energyfx_blasts/S = JoinScene(P, R)
	if(!S)
		var/path = text2path("/datum/energyfx_blasts/[R.extra["kind"]]")
		if(!path) return 0
		S = new path
		S.Init(P, R, src)
		scenes += S
	var/datum/energyfx_blastshot/O = S.AddShot(P, R)
	if(!O) return 0
	P.efx_orb = O
	if(R.extra["clear_trail"]) P.Trail = null
	S.Loop()
	return 1

/datum/energyfx_look/blasts/proc/MobCharge(mob/M, obj/Skills/Z)
	var/datum/energyfx_row/R = EnergyFXRow(Z)
	if(!M || !R || !R.extra) return 0
	var/path = text2path("/datum/energyfx_blasts/[R.extra["kind"]]")
	if(!path) return 0
	var/datum/energyfx_blasts/S = new path
	S.InitCharge(M, Z, R, src)
	scenes += S
	S.Loop()
	return 1

/datum/energyfx_look/blasts/Burst(turf/T, radius, datum/energyfx_row/row, datum/energyfx_colors/C)
	if(!T || !C || radius >= 2) return 0
	var/datum/energyfx_blasts/burst/S = new
	S.StartBurst(T, radius, row, C, src)
	return 1

/world/New()
	if(!energyfx_small_burst_look) energyfx_small_burst_look = energyfx_blast_look
	EFXO_PATHS["NS"] = /obj/energyfx/sharp
	. = ..()

/datum/energyfx_blastshot
	parent_type = /datum/energyfx_orbshot
	var/list/r
	var/sid = 0
	var/datum/bfx_rng/rng
	var/seq = 0
	var/list/lg = list()
	var/t_spawn
	var/t_launch
	var/t_hit
	var/list/hit_pt
	var/t_end
	var/list/end_pt
	var/t_contact
	var/list/contact_pt
	var/from_hand = 1
	var/list/hand
	var/ang0 = 0
	var/list/objs = list()
	var/launch_done = 0
	var/fizz_done = 0
	var/merge_k = 1
	var/merge_skip = 0
	var/ground = 0
	var/last_emit = -1
	var/last_wake = -1
	var/last_drive = -1
	var/wake_n = 0
	var/wake_k0
	var/size_k = 1
	var/first_volley = 1
	var/datum/energyfx_blastshot/lead
	var/list/feeds
	var/list/feed_angs
	var/list/pierce_pts
	var/list/charge_pt
	var/t_arrive
	var/t_sky
	var/kv = 1
	var/vi = 0
	var/flip = 1
	var/ci = 0
	var/L = 0
	var/t_real
	var/t_twos
	var/list/ties
	var/list/splash_draws

/datum/energyfx_blastshot/proc/R(key, def = 0)
	var/v = r[key]
	return isnull(v) ? def : v

/datum/energyfx_blastshot/proc/PosAt(t)
	var/n = lg.len
	if(!n) return null
	var/list/e0 = lg[1]
	if(t < e0[1] - 0.000000001) return null
	var/list/eN = lg[n]
	if(t >= eN[1]) return list(eN[2], eN[3], eN[4])
	for(var/i = 1 to n - 1)
		var/list/a = lg[i]
		var/list/b = lg[i + 1]
		if(a[1] - 0.000000001 <= t && t <= b[1] + 0.000000001)
			var/g = (b[1] - a[1] < 0.000000001) ? 0 : (t - a[1]) / (b[1] - a[1])
			return list(a[2] + (b[2] - a[2]) * g, a[3] + (b[3] - a[3]) * g, a[4] + (b[4] - a[4]) * g)
	return list(eN[2], eN[3], eN[4])

/datum/energyfx_blastshot/proc/Heading(t)
	var/list/p1 = PosAt(t)
	if(!p1) return isnull(ang0) ? 0 : ang0
	for(var/i = lg.len, i >= 1, i--)
		var/list/e = lg[i]
		if(e[1] <= t - 0.000001 && (abs(e[2] - p1[1]) + abs(e[3] + e[4] - p1[2] - p1[3]) > 0.5))
			return EFXOAtan2(p1[2] + p1[3] - (e[3] + e[4]), p1[1] - e[2])
	return isnull(ang0) ? 0 : ang0

/datum/energyfx_blastshot/proc/PathBack(t, dist)
	var/list/p = PosAt(t)
	if(!p) return null
	var/list/pts = list(list(p[1], p[2] + p[3]))
	for(var/i = lg.len, i >= 1, i--)
		var/list/e = lg[i]
		if(e[1] < t - 0.000000001 && (isnull(t_launch) || e[1] >= t_launch - 0.000000001))
			pts[++pts.len] = list(e[2], e[3] + e[4])
	if(from_hand && hand && !isnull(t_launch))
		pts[++pts.len] = list(hand[1], hand[2])
	var/acc = 0
	for(var/i = 1 to pts.len - 1)
		var/list/a = pts[i]
		var/list/b = pts[i + 1]
		var/sg = EFXOHyp(b[1] - a[1], b[2] - a[2])
		if(acc + sg >= dist)
			var/g = (dist - acc) / max(0.000001, sg)
			return list(list(a[1] + (b[1] - a[1]) * g, a[2] + (b[2] - a[2]) * g), dist)
		acc += sg
	return list(pts[pts.len], acc)

/datum/energyfx_blastshot/proc/Tie(name, v, val)
	if(!ties) return val
	var/list/T = ties[name]
	if(!T) return val
	var/x = T["[v]"]
	return isnull(x) ? val : x

proc/EFXBIntT(x)
	return (x >= 0) ? floor(x + 0.00001) : -floor(-x + 0.00001)

proc/EFXBFidx(t)
	return round(t / EFXB_FR, 1)

proc/EFXBFtime(fi)
	return fi * EFXB_FR

proc/EFXBMod(a, b)
	return a - b * floor(a / b)

/datum/energyfx_blasts
	parent_type = /datum/energyfx_orbs
	var/list/bshots = list()
	var/datum/energyfx_blastcolors/cols
	var/setname = "col"
	var/replay = 0
	var/list/rdata
	var/mob/target
	var/caster_dir = EAST
	var/list/tgt_off
	var/list/cdir_at
	var/list/sparks
	var/list/bigs
	var/list/erupt
	var/vs = 0
	var/obj/Skills/csrc

/datum/energyfx_blasts/Q(fi)
	return fi

/datum/energyfx_blasts/proc/RowOf(datum/energyfx_row/R)
	return EFXB_ROWS[R.extra["row"]]

/datum/energyfx_blasts/proc/SetupColors(obj/Skills/Z, datum/energyfx_row/R)
	EFXBEnsureE4()
	cols = new
	cols.Setup(Z, R)
	setname = R.extra["canon"] ? R.extra["set"] : (cols.gray ? "gray" : "col")

/datum/energyfx_blasts/Init(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R, datum/energyfx_look/L)
	..()
	csrc = locate(P.SkillPath) in P.Owner
	if(R.extra["color_from"] && P.Owner) csrc = locate(text2path(R.extra["color_from"])) in P.Owner
	SetupColors(csrc ? csrc : P.from_skill, R)
	caster_dir = P.Owner ? P.Owner.dir : EAST

/datum/energyfx_blasts/proc/InitCharge(mob/M, obj/Skills/Z, datum/energyfx_row/R, datum/energyfx_look/L)
	look = L
	row = R
	extra = R.extra
	caster = M
	from = Z
	zz = M.z
	K0 = EnergyFXNow() - 2
	parity = glob && glob.ENERGYFX_ORB_LOG
	csrc = locate(Z.type) in M
	SetupColors(csrc ? csrc : Z, R)
	caster_dir = M.dir
	if(parity) OL("G [energyfx_orb_log_tag] [R.extra["kind"]] [K0]")

/datum/energyfx_blasts/proc/T(k)
	return k * EFXB_TICK

/datum/energyfx_blasts/proc/Art(kind)
	return "BL[setname]_[kind]"

/datum/energyfx_blasts/proc/L2(ik)
	return EFXB_L2[ik] ? 2 : 1

/datum/energyfx_blasts/proc/BodyM(ik)
	if(cols.gray)
		var/b = cols.bright
		return (b == 1) ? null : list(b, 0, 0, 0, 0, b, 0, 0, 0, 0, b, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	var/key = EFXB_ART[ik]
	if(!key) return null
	return cols.Body(key)

/datum/energyfx_blasts/proc/LightM(ik, tag = "hl", al = 1)
	var/list/m = cols.LM(tag, al)
	var/k = L2(ik)
	return (k == 1) ? m : EFXOLMa(m, k)

/datum/energyfx_blasts/proc/RecB(list/out, key, front, ik, st, x, y, ang, sx, sy, al, lay)
	Rec(out, key, front ? "XP" : "NP", ik, st, x, y, ang, sx, sy, al, BodyM(ik), lay)

/datum/energyfx_blasts/proc/RecA(list/out, key, front, ik, st, x, y, ang, sx, sy, al)
	Rec(out, key, front ? "XS" : "NS", ik, st, x, y, ang, sx, sy, al, null, 0)

/datum/energyfx_blasts/proc/RecL(list/out, key, front, ik, st, x, y, ang, sx, sy, al, tag = "hl")
	var/kd = front ? "FL" : "ML"
	var/list/m = LightM(ik, tag, al)
	if(al > 1)
		m = EFXOLMa(m, al)
		al = 1
	Rec(out, key, cols.LK(kd), ik, st, x, y, ang, sx, sy, al, m, 0)

/datum/energyfx_blastshot/var/list/thr

/datum/energyfx_blastshot/proc/Thr(name, te, strict = 0)
	if(thr)
		var/x = thr[name]
		if(!isnull(x)) return x
	if(isnull(te)) return 1e9
	var/u = te / EFXB_FR
	var/n = round(u, 1)
	if(abs(u - n) < 0.0001) return strict ? n + 1 : n
	return floor(u) + 1

/datum/energyfx_blastshot/proc/TThr(name, te, strict = 0)
	if(thr)
		var/x = thr[name]
		if(!isnull(x)) return x
	if(isnull(te)) return 1e9
	var/u = te / EFXB_TICK
	var/n = round(u, 1)
	if(abs(u - n) < 0.0001) return strict ? n + 1 : n
	return floor(u) + 1

/datum/energyfx_blasts/proc/ShotHolds(datum/energyfx_blastshot/sh)
	var/list/hl = list()
	var/vr = sh.R("variant")
	if(vr == "void" || vr == "timeskip") return hl
	if(!isnull(sh.t_spawn) && (isnull(sh.t_launch) || sh.t_launch > sh.t_spawn + 0.000001))
		hl += list(list(EFXBFidx(sh.t_spawn) + 2, 4))
	if(!isnull(sh.t_hit))
		var/ih = EFXBFidx(sh.t_hit)
		var/ip = isnull(sh.t_pred) ? ih : EFXBFidx(sh.t_pred)
		hl += list(list(min(ih, ip) - 3, 3))
		hl += list(list(ih + 5, 6))
	else if(!isnull(sh.t_pred))
		hl += list(list(EFXBFidx(sh.t_pred) - 3, 3))
	if(sh.R("held") && !isnull(sh.t_launch) && sh.first_volley)
		hl += list(list(EFXBFidx(sh.t_launch) + 1, 3))
	return hl

/datum/energyfx_blasts/proc/Qs(datum/energyfx_blastshot/sh, i)
	var/v = i - (i % 2)
	if(!isnull(sh.t_hit))
		var/ih = EFXBFidx(sh.t_hit)
		if(ih <= i && i < ih + 5) v = i
	for(var/list/h in ShotHolds(sh))
		if(h[1] <= i && i < h[1] + h[2]) v = h[1]
	return v

/datum/energyfx_blasts/proc/RSize(datum/energyfx_blastshot/sh)
	return sh.R("size", 1) * sh.size_k

/datum/energyfx_blasts/proc/Frame16(datum/energyfx_blastshot/sh, v, t)
	var/n = sh.Tie("f", v, EFXBIntT((t - sh.t_spawn) / EFXB_TICK))
	return EFXBMod(n + sh.seq, EFXB_NF)

/datum/energyfx_blasts/proc/Ball(list/out, datum/energyfx_blastshot/sh, f, x, y, ang, sc, el = 1, al = 1, kind = "ball", neck = 1, front = 0, lay = 5)
	if(neck < 0.999 && (kind in list("ball", "ball_big", "ball_flare")))
		kind = "[kind]_n[min(2, floor(neck * 3))]"
	var/ik = Art(kind)
	var/list/ad = EFXB_ART["[ik]:geo"]
	var/co = ad ? ad[1] : -12
	var/ox = co * sc * el
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/key = "[sh.sid]h"
	RecB(out, key, front, ik, "[f]b", x + ca * ox, y + sa * ox, ang, sc * el, sc, al, Lay(lay, sh, 0))
	RecL(out, "[key]l", front, ik, "[f]l", x + ca * ox, y + sa * ox, ang, sc * el, sc, al)

/datum/energyfx_blasts/proc/NeckFrac(datum/energyfx_blastshot/sh, t, sc, el)
	var/list/back = sh.PathBack(t, 400)
	if(!back) return 0
	var/avail = back[2]
	var/ln = 27 * sc * el
	var/list/p1 = sh.PosAt(t)
	var/list/p0 = sh.PosAt(max(sh.t_spawn, t - 0.025))
	var/vv = 0
	if(p1 && p0) vv = EFXOHyp(p1[1] - p0[1], p1[2] + p1[3] - p0[2] - p0[3]) / 0.025
	return max(0, min(1, avail / max(ln, 1), vv / 250))

/datum/energyfx_blasts/proc/Muzzle(list/out, datum/energyfx_blastshot/sh, t, ang, s, v)
	var/k = sh.R("muzzle", 0.55)
	if(k <= 0) return
	var/q = (t - sh.t_launch) / 0.16
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/hx = sh.hand[1]
	var/hy = sh.hand[2]
	k = k * s ** 0.35
	var/sc = k * (0.5 + 0.5 * EFXOEaseOut(min(1, (t - sh.t_launch + 0.02) / 0.05))) * (1 - 0.8 * EFXOSstep(0.3, 1, q))
	var/al = 1 - EFXOSstep(0.55, 1, q)
	if(al <= 0.01) return
	var/fb = EFXBMod(sh.Tie("fb", v, EFXBIntT((t - sh.t_launch + 1) / EFXB_TICK)), EFXB_NF)
	if(sh.R("fingertip") && sh.R("fingertip_under"))
		var/list/cp = sh.charge_pt ? sh.charge_pt : sh.hand
		var/tr = (isnull(sh.t_real) ? t : sh.t_real) - sh.t_launch
		var/k2 = sh.R("muzzle", 0.55) * 2.2 * (1 + 0.25 * EFXOEaseOut(min(1, (tr + 0.02) / 0.04))) * (1 - 0.4 * EFXOSstep(0, 0.15, tr))
		var/a_u = 1 - EFXOSstep(0, 0.15, tr)
		if(a_u > 0.01)
			var/ik = Art("spark")
			var/co_ = EFXB_ART["[ik]:geo"][1] * k2
			RecB(out, "[sh.sid]mu", 0, ik, "[fb]b", cp[1] + ca * co_, cp[2] + sa * co_, ang, k2, k2, a_u, Lay(4.9, sh, 0))
			RecL(out, "[sh.sid]mul", 0, ik, "[fb]l", cp[1] + ca * co_, cp[2] + sa * co_, ang, k2, k2, a_u)
		return
	if(sh.R("fingertip"))
		var/k3 = sh.R("muzzle", 0.55) * 2.2 * (0.6 + 0.4 * EFXOEaseOut(min(1, (t - sh.t_launch + 0.02) / 0.04))) * (1 - 0.7 * EFXOSstep(0.2, 1, q))
		var/ik2 = Art("spark")
		RecB(out, "[sh.sid]mu", 1, ik2, "[fb]b", hx, hy, ang, k3, k3, al, LayM(5.5, sh))
		RecL(out, "[sh.sid]mul", 1, ik2, "[fb]l", hx, hy, ang, k3, k3, al, "")
		return
	var/ik3 = Art("muzzle")
	RecB(out, "[sh.sid]mu", 0, ik3, "[fb]b", hx + ca * 3 * sc, hy + sa * 3 * sc, ang, sc, sc, al, LayM(4.5, sh))
	RecL(out, "[sh.sid]mul", 0, ik3, "[fb]l", hx + ca * 3 * sc, hy + sa * 3 * sc, ang, sc, sc, al, "")

/datum/energyfx_blasts/proc/Flight(list/out, datum/energyfx_blastshot/sh, t, v, f, hx, hy, ang, s, grow, ghost)
	var/vr = sh.R("variant", "ball")
	if(vr == "laser") return
	if(vr == "mine")
		var/ta = isnull(sh.t_arrive) ? sh.t_launch : sh.t_arrive
		if(v < sh.Thr("arrive", ta))
			var/sc0 = s * (0.55 + 0.45 * grow)
			Ball(out, sh, f, hx, hy, ang, sc0, 1, ghost, "ball", NeckFrac(sh, t, sc0, 1))
			return
		var/st = t - ta
		var/bob = sh.R("bob", 1.2) * sin(360 * st / 0.9 + sh.sid * 1.7 * 57.29577951)
		var/settle = 1 + 0.22 * EFXOExp(-(((st - 0.03) / 0.06) ** 2))
		var/ta2 = sh.t_spawn + sh.R("arm", 2.4)
		var/beat = 0
		if(v >= sh.Thr("arm", ta2))
			var/ph = sh.Tie("bt", v, EFXBMod((t - ta2) / sh.R("beat", 0.5), 1))
			beat = EFXOExp(-((ph / 0.12) ** 2))
		var/scm = s * (settle + 0.16 * beat)
		var/ikm = Art("ball_mine")
		RecB(out, "[sh.sid]h", 0, ikm, "[f]b", hx, hy + bob, 0, scm, scm, ghost, Lay(5, sh, 0))
		RecL(out, "[sh.sid]hl", 0, ikm, "[f]l", hx, hy + bob, 0, scm, scm, ghost * (1 + 0.6 * beat))
		var/qa = t - ta2
		var/sl = EFXB_ART["[Art("star")]:life"]
		if(v >= sh.Thr("arm", ta2) && v < sh.Thr("ms1", ta2 + sl))
			var/ns = EFXB_ART["[Art("star")]:n"]
			var/j = min(ns - 1, sh.Tie("mz", v, floor(qa / sl * (ns - 1) + 0.5)))
			var/kk = s * 1.15
			RecB(out, "[sh.sid]st", 0, Art("star"), "[j]b", hx, hy + bob, 0, kk, kk, ghost, Lay(5.1, sh, 0))
			RecL(out, "[sh.sid]stl", 0, Art("star"), "[j]l", hx, hy + bob, 0, kk, kk, ghost)
		return
	var/sc = s * (0.45 + 0.55 * grow)
	var/el = sh.R("elong", 1)
	if(sh.R("snap")) el = el * (1 + sh.R("snap") * EFXOExp(-max(0, t - sh.t_launch) / 0.07))
	if(sh.R("head") == "wave")
		WaveHead(out, sh, t, v, ang, ghost)
		return
	var/kind = sh.R("flare") ? "ball_flare" : (sh.R("big") ? "ball_big" : "ball")
	Ball(out, sh, f, hx, hy, ang, sc, el, ghost, kind, NeckFrac(sh, t, sc, el))

/datum/energyfx_blasts/proc/Crowd(datum/energyfx_blastshot/sh, t, v)
	var/cr = sh.Tie("cr", v, null)
	if(!isnull(cr)) return cr
	var/o = 0
	for(var/datum/energyfx_blastshot/s2 in bshots)
		if(s2 == sh || isnull(s2.t_hit) || s2.merge_skip || s2.R("hit", 0) <= 0) continue
		var/dt = t - s2.t_hit
		if(dt >= 0 && dt < 0.5)
			var/d = EFXOHyp(s2.hit_pt[1] - sh.hit_pt[1], s2.hit_pt[2] - sh.hit_pt[2])
			if(d < 20) o += (1 - d / 20) * (1 - dt / 0.5)
	return 1 / (1 + 0.8 * o)

/datum/energyfx_blasts/proc/Contact(list/out, datum/energyfx_blastshot/sh, t, v, s, ghost)
	if(sh.R("merge")) return
	var/vr = sh.R("variant", "ball")
	var/q = t - sh.t_hit
	if(v >= sh.Thr("hit+0.1", sh.t_hit + 0.1)) return
	if(vr == "laser") return
	var/list/P = sh.hit_pt
	var/ang = sh.Heading(sh.t_hit - 0.0001)
	if(vr == "ball" || vr == "mine")
		var/fa = 1 - EFXOEaseOut(q / 0.05)
		if(fa > 0.01)
			var/f = EFXBMod(sh.Tie("cf", v, EFXBIntT((t - sh.t_spawn) / EFXB_TICK)), EFXB_NF)
			if(vr == "mine")
				var/scm = s * (1 - 0.2 * q / 0.1)
				RecB(out, "[sh.sid]h", 0, Art("ball_mine"), "[f]b", P[1], P[2], 0, scm, scm, ghost * fa, Lay(5, sh, 0))
				RecL(out, "[sh.sid]hl", 0, Art("ball_mine"), "[f]l", P[1], P[2], 0, scm, scm, ghost * fa)
			else if(sh.R("head") == "wave")
				WaveHead(out, sh, sh.t_hit, v, ang, ghost * fa, P)
			else
				var/sc = s * (1 - 0.2 * q / 0.1)
				Ball(out, sh, f, P[1], P[2], ang, sc, sh.R("elong", 1), ghost * fa, sh.R("big") ? "ball_big" : "ball")

/datum/energyfx_blasts/proc/SplashDraws(datum/energyfx_blastshot/sh, seed, i)
	var/key = "[seed]_[i]"
	if(sh.splash_draws)
		var/list/d = sh.splash_draws[key]
		if(d) return d
	var/datum/bfx_rng/G = Stream("sp[sh.sid]_[key]")
	var/list/out = list(G.U(0, EFXB_TICK), G.U(0.15, 0.24), G.R(), G.U(0.8, 1.25), G.RandRange(4), G.U(2, 6))
	if(!sh.splash_draws) sh.splash_draws = list()
	sh.splash_draws[key] = out
	return out

/datum/energyfx_blasts/proc/SplashBurst(list/out, datum/energyfx_blastshot/sh, t, t0, list/P, ang, n, k, seed, sp0 = 95, sp1 = 160, lay = 5.44, sub0 = 0)
	var/ik = (cols.canon || cols.anchor || cols.gray) ? "BLS[setname]" : "BLSE4col"
	var/list/sm = (ik == "BLSE4col") ? EFXOE4Mats("BLSE4col", cols.pal) : null
	var/sns = EFXB_ART["spl:ns"]
	var/sox = EFXB_ART["spl:ox"]
	for(var/i = 0, i < n, i++)
		var/list/d = SplashDraws(sh, seed, i)
		var/life = d[2]
		var/age = t - (t0 + d[1])
		if(age < 0 || age >= life) continue
		var/side = (i % 2 == 0) ? 1 : -1
		var/a_t = ang + side * (sp0 + (sp1 - sp0) * d[3])
		var/kk = k * d[4]
		var/vi_ = d[5]
		var/j = min(sns - 1, floor(age / life * (sns - 1) + 0.5))
		var/r0 = d[6] * k
		var/cx = P[1] + cos(a_t) * (r0 + sox * kk)
		var/cy = P[2] + sin(a_t) * (r0 + sox * kk)
		var/key = "[sh.sid]s[seed]_[i]"
		var/ly = Lay(lay, sh, sub0 + i)
		if(sm)
			Rec(out, "[key]p", "XP", ik, sm[1] ? "o[vi_]_[j]" : "og[vi_]_[j]", cx, cy, a_t, kk, kk * side, 1, sm[1], ly)
			for(var/kq = 0 to 2)
				Rec(out, "[key]a[kq]", "XS", ik, "l[kq]_[vi_]_[j]", cx, cy, a_t, kk, kk * side, 1, sm[kq + 2], 0)
		else
			Rec(out, "[key]p", "XP", ik, "[vi_]_[j]b", cx, cy, a_t, kk, kk * side, 1, null, ly)
			Rec(out, "[key]a", "XS", ik, "[vi_]_[j]a", cx, cy, a_t, kk, kk * side, 1, null, 0)

/datum/energyfx_blasts/proc/ExplRec(list/out, key, vi_, code, j, x, y, k, alb, ala, lay)
	var/st = "[vi_][code][j]"
	if(cols.canon || cols.anchor || cols.gray)
		var/ik = "BLX[setname]"
		Rec(out, "[key]p", "XP", ik, "[st]b", x, y, 0, k, k, alb, null, lay)
		Rec(out, "[key]a", "XS", ik, "[st]a", x, y, 0, k, k, ala, null, 0)
	else
		var/list/em = EFXOE4Mats("BLXE4col", cols.pal)
		Rec(out, "[key]p", "XP", "BLXE4col", em[1] ? "o[st]" : "og[st]", x, y, 0, k, k, alb, em[1], lay)
		for(var/kq = 0 to 2)
			Rec(out, "[key]a[kq]", "XS", "BLXE4col", "l[kq]_[st]", x, y, 0, k, k, ala, em[kq + 2], 0)

/datum/energyfx_blasts/proc/ExplFrame(datum/energyfx_blastshot/sh, v, qb, q, hold, has_feeds, i_d)
	var/list/xf = sh.Tie("xf", v, null)
	if(xf) return (xf[1] == "N") ? null : xf
	if(qb < 0.125 - 0.0000001)
		return list("B", min(4, EFXBIntT(qb / EFXB_FR)))
	if(q < hold - 0.0000001)
		return has_feeds ? list("O", EFXBMod(EFXBIntT((q - 0.125) / 0.05), 16)) : list("P", 0)
	if(i_d >= 13) return null
	return list("D", i_d)

/datum/energyfx_blasts/proc/Hit(list/out, datum/energyfx_blastshot/sh, t, v, s, ghost)
	var/k = sh.R("hit", 0.55) * sh.merge_k
	var/q = t - sh.t_hit
	var/list/P = sh.hit_pt
	var/ang = sh.Heading(sh.t_hit - 0.0001)
	var/ca = cos(ang)
	var/sa = sin(ang)
	if(sh.R("variant") == "laser") Laser(out, sh, t, v, s, ghost)
	Contact(out, sh, t, v, s, ghost)
	var/ghost_p = ghost
	ghost = ghost * Crowd(sh, t, v)
	var/list/cpt = list(P[1] - ca * 2, P[2] - sa * 2)
	if(k <= 0)
		if(v < sh.Thr("hit+0.1", sh.t_hit + 0.1) && !sh.R("pierce"))
			Rec(out, "[sh.sid]cf", cols.LK("ML"), Art("core"), "l", cpt[1], cpt[2], ang, 0.5 * s, 0.5 * s, 0.8 * (1 - q / 0.1), LightM(Art("core"), "flash"), 0)
		return
	if(sh.merge_skip || sh.lead)
		if(v < sh.Thr("hit+0.3", sh.t_hit + 0.3) && !sh.R("merge"))
			var/kf = sh.R("hit", 0.55) * 1.1
			var/back = 38 * sh.R("hit", 0.55) * 0.75
			SplashBurst(out, sh, t, sh.t_hit, list(P[1] - ca * back, P[2] - sa * back), ang, 3, kf, 2, 100, 165, 5.47)
		return
	var/hold = sh.R("hit_hold", 0.27)
	var/list/arrived = list()
	if(sh.feeds && sh.feeds.len)
		var/mxf = sh.feeds[1]
		for(var/tf in sh.feeds) mxf = max(mxf, tf)
		hold = max(hold, mxf - sh.t_hit + 0.12)
		var/sr = 0
		var/sws = 0
		for(var/fj = 1 to sh.feeds.len)
			var/tf = sh.feeds[fj]
			if(v >= sh.Thr("arr[fj]", tf))
				arrived += tf
				sr += EFXOEaseOut(min(1, (t - tf) / 0.15))
				if(t - tf < 0.16) sws += sin(180 * (t - tf) / 0.16)
		var/kg = sh.R("merge") ? min(sh.R("feed_cap", 2.6), (1 + sr) ** 0.4) : min(1.45, 1 + 0.06 * sr)
		k = k * kg * (1 + 0.05 * sws)
	var/vi_ = EFXBMod(sh.seq + sh.sid, 4)
	if(v < sh.Thr("hit+0.3", sh.t_hit + 0.3))
		var/sfw = sh.R("splash_fwd", 0)
		SplashBurst(out, sh, t, sh.t_hit, list(P[1] + ca * sfw, P[2] + sa * sfw), ang, 6, min(sh.R("splash_cap", 9), sh.R("hit", 0.55) * sh.merge_k * 2), 1, 75, 160, 5.44)
	var/fw = 2 + sh.R("expl_fwd", 0)
	var/ex = P[1] + ca * fw
	var/ey = P[2] + sa * fw
	var/i_d = sh.Tie("xid", v, (q >= hold - 0.0000001) ? EFXBIntT((q - hold) / EFXB_FR) : -1)
	if(arrived.len && !sh.R("merge"))
		var/Rm = 38 * k
		for(var/j = 1 to arrived.len)
			var/tf = arrived[j]
			var/hj = EFXBMod(sh.sid * 7919 + (j - 1) * 104729, 1000003)
			var/u1 = EFXBMod(hj, 1000) / 1000
			var/u2 = EFXBMod(floor(hj / 1000), 1000) / 1000
			var/fa = sh.feed_angs ? sh.feed_angs["[j]"] : null
			if(isnull(fa)) fa = ang
			var/phi = fa + 180 + (u1 - 0.5) * 150
			var/vj = EFXBMod(vi_ + 1 + (j - 1), 4)
			var/aj = t - tf
			var/list/fr
			if(i_d >= 0)
				if(i_d + 3 >= 13) continue
				fr = list("D", i_d + 3)
			else
				fr = sh.Tie("pf[j]", v, null)
				if(!fr)
					if(aj < 0.125 - 0.0000001) fr = list("B", min(4, EFXBIntT(aj / EFXB_FR)))
					else fr = list("O", EFXBMod(EFXBIntT((aj - 0.125) / 0.05) + (j - 1) * 5, 16))
			var/kp = k * (0.42 + 0.16 * u2)
			var/dj = Rm * (0.5 + 0.12 * u2) * (0.85 + 0.15 * EFXOEaseOut(min(1, aj / 0.2)))
			ExplRec(out, "[sh.sid]fd[j]", vj, fr[1], fr[2], ex + cos(phi) * dj, ey + sin(phi) * dj, kp, ghost_p, ghost * 0.3, Lay(5.44, sh, 16 + j))
		ghost = ghost / (1 + 0.05 * arrived.len)
	var/qb = q + sh.R("bloom_skip", 0) * EFXB_FR
	var/list/frm = ExplFrame(sh, v, qb, q, hold, sh.feeds && sh.feeds.len, i_d)
	if(!frm) return
	ExplRec(out, "[sh.sid]x", vi_, frm[1], frm[2], ex, ey, k, ghost_p, ghost, Lay(5.45, sh, 0))

/datum/energyfx_blasts/proc/Laser(list/out, datum/energyfx_blastshot/sh, t, v, s, ghost, miss = 0)
	var/t0 = miss ? sh.t_end : sh.t_hit
	var/q = t - t0
	var/hx0 = sh.hand[1]
	var/hy0 = sh.hand[2]
	var/list/P = miss ? sh.end_pt : sh.hit_pt
	if(!P) return
	var/dx = P[1] - hx0
	var/dy = P[2] - hy0
	var/D = max(1, EFXOHyp(dx, dy))
	var/ang = EFXOAtan2(dy, dx)
	var/ca = dx / D
	var/sa = dy / D
	var/ikl = Art("laser")
	var/list/lg_ = EFXB_ART["[ikl]:laser"]
	if(v < sh.Thr(miss ? "end+laser" : "hit+laser", t0 + lg_[3]))
		var/nl = lg_[4]
		var/i = min(nl - 1, sh.Tie("lz", v, floor(q / lg_[3] * (nl - 1) + 0.5)))
		var/sx = D / lg_[1]
		var/x = hx0 + ca * lg_[2] * sx
		var/y = hy0 + sa * lg_[2] * sx
		RecB(out, "[sh.sid]lz", 1, ikl, "[i]b", x, y, ang, sx, s, ghost, Lay(5.3, sh, 0))
		RecL(out, "[sh.sid]lzl", 1, ikl, "[i]l", x, y, ang, sx, s, ghost)
	var/iks = Art("star")
	if(sh.R("laser_star", 1) && v < sh.Thr(miss ? "end+star" : "hit+star", t0 + EFXB_ART["[iks]:life"]))
		var/ns = EFXB_ART["[iks]:n"]
		var/j = min(ns - 1, sh.Tie("sz", v, floor(q / EFXB_ART["[iks]:life"] * (ns - 1) + 0.5)))
		var/k1 = sh.R("muzzle", 0.35) * 2.6
		RecB(out, "[sh.sid]s0", 1, iks, "[j]b", hx0, hy0, ang, k1, k1, ghost, Lay(5.6, sh, 0))
		RecL(out, "[sh.sid]s0l", 1, iks, "[j]l", hx0, hy0, ang, k1, k1, ghost)
		if(!miss)
			RecB(out, "[sh.sid]s1", 1, iks, "[j]b", P[1], P[2], ang, k1 * 0.8, k1 * 0.8, ghost, Lay(5.6, sh, 1))
			RecL(out, "[sh.sid]s1l", 1, iks, "[j]l", P[1], P[2], ang, k1 * 0.8, k1 * 0.8, ghost)
	if(miss) return
	var/kb = sh.R("laser_bloom", 0)
	if(kb > 0)
		var/vi_ = EFXBMod(sh.seq + sh.sid, 4)
		var/list/bp = (sh.pierce_pts && sh.pierce_pts.len) ? sh.pierce_pts[1] : list(hx0 + ca * 12, hy0 + sa * 12)
		var/mx = (hx0 + bp[1]) / 2
		var/my = (hy0 + bp[2]) / 2
		var/list/fr = sh.Tie("lb", v, null)
		if(fr && fr[1] == "N") fr = null
		else if(!fr)
			if(q < 0.125 - 0.0000001)
				fr = list("B", min(4, EFXBIntT(q / EFXB_FR)))
			else if(q < 0.275 - 0.0000001)
				fr = list("O", EFXBMod(EFXBIntT((q - 0.125) / 0.05), 16))
			else
				var/i_d = EFXBIntT((q - 0.275) / EFXB_FR)
				if(i_d < 13) fr = list("D", i_d)
		if(fr) ExplRec(out, "[sh.sid]lb", vi_, fr[1], fr[2], mx, my, kb, ghost, ghost, Lay(5.45, sh, 0))
	if(sh.pierce_pts)
		for(var/jp = 1 to sh.pierce_pts.len)
			if(q < 0.3 - 0.0000001)
				SplashBurst(out, sh, t, sh.t_hit, sh.pierce_pts[jp], ang, 5, sh.R("pierce_k", 0.8), 3 + jp - 1, 70, 135, 5.6, 8 + 5 * (jp - 1))

/datum/energyfx_blasts/proc/Fizzle(list/out, datum/energyfx_blastshot/sh, t, v, s, ang, ghost)
	var/q = t - sh.t_end
	var/i = sh.Tie("fz", v, EFXBIntT(q / 0.025))
	if(i < 10)
		var/sc = s * (1 - 0.3 * i / 10)
		var/ex = sh.end_pt[1]
		var/ey = sh.end_pt[2]
		var/kind = sh.R("big") ? "ball_big_erode" : "ball_erode"
		var/ik = Art(kind)
		var/co = EFXB_ART["[ik]:geo"][1]
		var/el = sh.R("elong", 1)
		var/ox = co * sc * el
		RecB(out, "[sh.sid]h", 0, ik, "[i]b", ex + cos(ang) * ox, ey + sin(ang) * ox, ang, sc * el, sc, ghost, Lay(5, sh, 0))
		RecL(out, "[sh.sid]hl", 0, ik, "[i]l", ex + cos(ang) * ox, ey + sin(ang) * ox, ang, sc * el, sc, ghost)

/datum/energyfx_blasts/proc/WaveHead(list/out, datum/energyfx_blastshot/sh, t, v, ang, al, list/P = null)
	var/kt = EFXBIntT(t / EFXB_TICK)
	var/nh = EFXB_ART["BLMkHead:n"]
	var/n = isnull(sh.wake_k0) ? 0 : EFXBMod(kt - sh.wake_k0, nh)
	if(!P)
		var/list/p = sh.PosAt(max(kt * EFXB_TICK, sh.t_launch))
		if(!p) return
		P = list(p[1], p[2] + p[3])
	var/k = sh.size_k
	var/ox = EFXB_ART["BLMkHead:ox"]
	var/x = P[1] + cos(ang) * ox * k
	var/y = P[2] + sin(ang) * ox * k
	for(var/j = 0, j < EFXB_ART["BLMkHead:layers"], j++)
		var/st = "h[n]_[j]"
		if(EFXB_ART["BLMkHead:[j]"] == "ga") RecA(out, "[sh.sid]wh[j]", 0, "BLMkHead", st, x, y, ang, k, k, al)
		else Rec(out, "[sh.sid]wh[j]", "NP", "BLMkHead", st, x, y, ang, k, k, al, null, Lay(5, sh, j))

/datum/energyfx_blasts/proc/SkyOrb(list/out, datum/energyfx_blastshot/sh, t, v, f, hx, hy, s, ghost, launched)
	var/list/p = sh.PosAt(t)
	var/zt = sh.R("sky_z", 180)
	if(v < sh.Thr("sky", sh.t_sky))
		var/ang = (t > sh.t_spawn + 0.0001) ? sh.Heading(t + 0.0001) : 90
		var/grow = EFXOEaseOut((t - sh.t_spawn) / 0.1)
		var/sc0 = s * (0.45 + 0.55 * grow)
		Ball(out, sh, f, hx, hy, ang, sc0, 1, ghost, "ball", NeckFrac(sh, t, sc0, 1))
		return
	if(!launched)
		var/st = t - sh.t_sky
		var/bob = sh.R("bob", 1.2) * sin(360 * st / 0.9 + sh.sid * 1.7 * 57.29577951)
		var/settle = 1 + 0.2 * EFXOExp(-(((st - 0.03) / 0.06) ** 2))
		var/ikm = Art("ball_mine")
		RecB(out, "[sh.sid]h", 0, ikm, "[f]b", hx, hy + bob, 0, s * settle, s * settle, ghost, Lay(5, sh, 0))
		RecL(out, "[sh.sid]hl", 0, ikm, "[f]l", hx, hy + bob, 0, s * settle, s * settle, ghost)
		return
	var/z = p ? p[3] : 0
	var/nk = min(1, (zt - z) / max(1, 27 * s), sh.R("fall_px", 7.5) / 0.05 / 250)
	Ball(out, sh, f, hx, hy, -90, s, 1, ghost, "ball", nk)
	var/gk = (1 - min(1, z / zt)) ** 1.5
	if(gk > 0.02)
		var/kg = s * (1.5 + 0.7 * gk)
		Rec(out, "[sh.sid]gp", cols.LK("ML"), Art("glow"), "l", p[1], p[2], 0, kg, kg * 0.5, ghost * 0.7 * gk, LightM(Art("glow")), 0)

/datum/energyfx_blasts/proc/WakeKey(datum/energyfx_blastshot/sh)
	return "BLW[sh.R("wtag", sh.R("row"))]_[setname]"

/datum/energyfx_blasts/proc/Objs(list/out, datum/energyfx_blastshot/sh, t, v)
	var/list/alive = list()
	for(var/list/o in sh.objs)
		var/age = t - o["t0"]
		if(age < 0)
			alive[++alive.len] = o
			continue
		var/wb = (o["kind"] == "wake" && sh.R("wake_kind") == "wavebody")
		if(!wb && age >= o["life"] - 0.0000001) continue
		alive[++alive.len] = o
		if(o["kind"] == "wake")
			var/ik = (sh.R("beam") == "godot") ? "BLMkBody" : WakeKey(sh)
			var/nw = EFXB_ART["[ik]:nw"]
			var/i
			if(wb)
				var/tw = isnull(sh.t_twos) ? t : sh.t_twos
				if(isnull(sh.t_hit) || tw <= sh.t_hit + 0.0000001) tw = t
				var/aw = tw - o["t0"]
				if(!isnull(sh.t_hit) && tw > sh.t_hit + 0.0000001) aw += sh.R("drain_k", 1.5) * (tw - sh.t_hit)
				if(aw >= o["life"] - 0.0000001 || aw < 0) continue
				i = min(nw - 1, EFXBIntT(aw / o["life"] * (nw - 1)))
			else
				i = min(nw - 1, sh.Tie("wk[o["id"]]", v, EFXORoundHalfEven(age / o["life"] * (nw - 1))))
			var/ang = o["ang"]
			var/ca = cos(ang)
			var/sa = sin(ang)
			var/sxw = o["scale"]
			var/syw = o["scale"] * o["ww"]
			var/x = o["P"][1] + ca * EFXB_ART["[ik]:ox"] * sxw
			var/y = o["P"][2] + sa * EFXB_ART["[ik]:ox"] * sxw
			var/key = "[sh.sid]w[o["id"]]"
			if(ik == "BLMkBody")
				var/stb = o["first"] ? "s_[i]" : "f[o["n"]]_[i]"
				for(var/j = 0, j < EFXB_ART["BLMkBody:layers"], j++)
					if(EFXB_ART["BLMkBody:[j]"] == "ga") RecA(out, "[key]_[j]", 0, ik, "[stb]_[j]", x, y, ang, sxw, sxw, 1)
					else Rec(out, "[key]_[j]", "NP", ik, "[stb]_[j]", x, y, ang, sxw, sxw, 1, null, Lay(4.3, sh, j))
				continue
			var/st
			if(o["first"]) st = "s_[i]"
			else if(o["half"] == "front") st = "fr[o["n"]]_[i]"
			else if(o["half"] == "back") st = "bk[o["n"]]_[i]"
			else st = "f[o["n"]]_[i]"
			RecB(out, key, 0, ik, "[st]b", x, y, ang, sxw, syw, 1, Lay(4.3, sh, o["id"]))
			RecL(out, "[key]l", 0, ik, "[st]l", x, y, ang, sxw, syw, 1)
		else if(o["kind"] == "splash")
			var/j2 = min(7, floor(age / o["life"] * 7 + 0.5))
			var/ad = sh.Heading(sh.t_hit - 0.0001)
			var/list/pd = sh.PosAt(min(t, sh.t_hit))
			var/rf = 9 * RSize(sh)
			var/cd_ = cos(ad)
			var/sd_ = sin(ad)
			var/bx_ = pd[1] + cd_ * rf * 0.45 - sd_ * o["side"] * rf * 0.75
			var/by_ = pd[2] + pd[3] + sd_ * rf * 0.45 + cd_ * o["side"] * rf * 0.75
			var/k_ = o["scale"]
			var/cx_ = bx_ + cos(o["ang"]) * EFXB_ART["BLDs:ox"] * k_
			var/cy_ = by_ + sin(o["ang"]) * EFXB_ART["BLDs:ox"] * k_
			var/ikd = cols.gray ? "BLDsgray" : "BLDs"
			var/key2 = "[sh.sid]d[o["id"]]"
			Rec(out, key2, "MP", ikd, "[o["vi"]]_[j2]p", cx_, cy_, o["ang"], k_, k_ * o["side"], 1, cols.gray ? null : EFXOHeatMatrix(cols, 1), Lay(5.6, sh, o["id"]))
			Rec(out, "[key2]l", cols.LK("ML"), ikd, "[o["vi"]]_[j2]l", cx_, cy_, o["ang"], k_, k_ * o["side"], 1, LightM(ikd), 0)
	sh.objs = alive

/datum/energyfx_blasts/proc/Void(list/out, datum/energyfx_blastshot/sh, t, v, s)
	if(isnull(sh.t_launch) || v < sh.Thr("launch", sh.t_launch)) return
	var/age = t - sh.t_launch
	var/ang = sh.ang0
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/i = EFXBIntT(age / EFXB_FR)
	var/k_ = s * sh.kv
	var/nv = EFXB_ART["BLVdStrike:nv"]
	var/vv = EFXBMod(sh.vi, nv)
	if(i < EFXB_ART["BLVdStrike:ns"])
		var/ox = EFXB_ART["BLVdStrike:ox"] * k_
		Rec(out, "[sh.sid]vs", "NP", "BLVdStrike", "[vv]_[i]b", sh.hand[1] + ca * ox, sh.hand[2] + sa * ox, ang, k_, k_ * sh.flip, 1, null, Lay(5, sh, 0))
		RecA(out, "[sh.sid]vsa", 0, "BLVdStrike", "[vv]_[i]a", sh.hand[1] + ca * ox, sh.hand[2] + sa * ox, ang, k_, k_ * sh.flip, 1)
	if(age < 0.16 && sh.R("muzzle", 0) > 0) Muzzle(out, sh, t, ang, s, v)

/datum/energyfx_blasts/proc/Timeskip(list/out, datum/energyfx_blastshot/sh, t, v, s)
	if(isnull(sh.t_launch) || v < sh.Thr("launch", sh.t_launch)) return
	var/age = t - sh.t_launch
	var/i = EFXBIntT(age / EFXB_FR)
	var/ang = sh.ang0
	var/ca = cos(ang)
	var/sa = sin(ang)
	var/list/pk = PathArt(sh.L)
	var/ik = pk[1]
	var/sxp = pk[2]
	var/np = EFXB_ART["[ik]:nv"]
	if(i < EFXB_ART["[ik]:ns"])
		var/ox = EFXB_ART["[ik]:ox"] * sxp
		var/st = "[EFXBMod(sh.vi, np)]_[i]"
		Rec(out, "[sh.sid]fp", "NP", ik, "[st]b", sh.hand[1] + ca * ox, sh.hand[2] + sa * ox, ang, sxp, sh.flip, 1, null, Lay(5, sh, 0))
		RecA(out, "[sh.sid]fpa", 0, ik, "[st]a", sh.hand[1] + ca * ox, sh.hand[2] + sa * ox, ang, sxp, sh.flip, 1)
	var/ic = i - sh.R("crush_delay", 1)
	if(sh.hit_pt && ic >= 0 && ic < EFXB_ART["BLFfCrush:ns"])
		var/stc = "[EFXBMod(sh.ci, EFXB_ART["BLFfCrush:nv"])]_[ic]"
		Rec(out, "[sh.sid]fc", "XP", "BLFfCrush", "[stc]b", sh.hit_pt[1], sh.hit_pt[2], ang, 1, sh.flip, 1, null, Lay(6, sh, 0))
		RecA(out, "[sh.sid]fca", 1, "BLFfCrush", "[stc]a", sh.hit_pt[1], sh.hit_pt[2], ang, 1, sh.flip, 1)
	if(age < 0.16 && sh.R("muzzle", 0) > 0) Muzzle(out, sh, t, ang, s, v)

/datum/energyfx_blasts/proc/PathArt(L)
	var/lr = round(L, 1)
	if(EFXB_ART["BLFfPath[lr]:ns"]) return list("BLFfPath[lr]", 1)
	var/lb = clamp(round(L / 16, 1) * 16, EFXB_ART["BLFfPath:min"], EFXB_ART["BLFfPath:max"])
	return list("BLFfPath[lb]", L / lb)

/datum/energyfx_blasts/proc/BigDome(Re)
	if(cols.canon || cols.anchor || cols.gray) return "BLB3[setname][Re]"
	var/rs = EFXOE4Set(Re)
	return (rs == 48) ? "B3E4_48TB" : "B3E4_[rs]G"

/datum/energyfx_blasts/proc/ShotSprites(list/out, datum/energyfx_blastshot/sh, t, v)
	if(sh.big_only) return
	if(isnull(sh.t_spawn) || v < sh.Thr("spawn", sh.t_spawn)) return
	var/s = RSize(sh)
	var/vr = sh.R("variant", "ball")
	if(vr == "void")
		Void(out, sh, t, v, s)
		Objs(out, sh, t, v)
		return
	if(vr == "timeskip")
		Timeskip(out, sh, t, v, s)
		return
	var/f = Frame16(sh, v, t)
	var/hit = !isnull(sh.t_hit) && v >= sh.Thr("hit", sh.t_hit)
	var/ended = !isnull(sh.t_end) && v >= sh.Thr("end", sh.t_end) && !hit
	var/launched = !isnull(sh.t_launch) && v >= sh.Thr("launch", sh.t_launch)
	var/list/p = sh.PosAt(isnull(sh.t_hit) ? t : min(t, sh.t_hit))
	if(!p) return
	var/hx = p[1]
	var/hy = p[2] + p[3]
	var/ang = launched ? sh.Heading(t) : (isnull(sh.ang0) ? 0 : sh.ang0)
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
				Rec(out, "[sh.sid]pf", cols.LK("ML"), ikz, "[f]l", hx, hy, 0, 0.7 * s, 0.7 * s, 0.8 * (1 - qa), LightM(ikz, "flash"), 0)
		else
			Flight(out, sh, t, v, f, hx, hy, ang, s, grow, ghost)
	if(hit) Hit(out, sh, t, v, s, ghost)
	if(ended && !sh.R("no_fizzle") && vr != "laser") Fizzle(out, sh, t, v, s, ang, ghost)
	if(ended && vr == "laser" && sh.end_pt && sh.hand) Laser(out, sh, t, v, s, ghost, 1)
	if(sh.from_hand && sh.hand && !isnull(sh.t_launch) && v >= sh.Thr("mz0", sh.t_launch - 0.02) && v < sh.Thr("mz1", sh.t_launch + 0.16) && vr != "laser" && !sh.R("erupt"))
		var/m0 = sh.t_launch - 0.02
		var/tm = t
		if(v >= sh.Thr("mh0", m0 + 2 * EFXB_FR - 0.000000001) && v < sh.Thr("mh1", m0 + 6 * EFXB_FR - 0.000000001)) tm = m0 + 2 * EFXB_FR
		sh.t_real = t
		Muzzle(out, sh, tm, isnull(sh.ang0) ? ang : sh.ang0, s, v)
	Objs(out, sh, t, v)

/datum/energyfx_blasts/proc/NewObj(datum/energyfx_blastshot/sh, list/o)
	var/n = sh.vars_["oid"]
	sh.vars_["oid"] = (n ? n : 0) + 1
	o["id"] = n ? n : 0
	sh.objs[++sh.objs.len] = o

/datum/energyfx_blasts/proc/TickShot(datum/energyfx_blastshot/sh, k)
	var/now = k * EFXB_TICK
	if(!isnull(sh.t_launch) && !sh.launch_done && k >= sh.TThr("kld", sh.t_launch - EFXB_TICK, 1)) sh.launch_done = 1
	var/flying = !isnull(sh.t_launch) && k >= sh.TThr("kfly0", sh.t_launch) && (isnull(sh.t_hit) || k < sh.TThr("kfly1", sh.t_hit)) && (isnull(sh.t_end) || k < sh.TThr("kfly2", sh.t_end))
	if(flying && k != sh.last_emit) sh.last_emit = k
	if(!isnull(sh.t_contact) && k >= sh.TThr("kdr0", sh.t_contact - 0.000001) && k < sh.TThr("kdr1", sh.t_hit - 0.000001) && k != sh.last_drive && sh.R("drive_splash", 1))
		sh.last_drive = k
		var/ad = sh.Heading(sh.t_hit - 0.0001)
		var/n_sp = (now < sh.t_contact + 0.000001) ? 4 : 3
		for(var/jj = 0, jj < n_sp, jj++)
			var/side = ((jj + sh.rng.RandRange(2)) % 2 == 0) ? 1 : -1
			var/t0 = now + sh.rng.U(0, EFXB_TICK)
			var/an = ad + side * sh.rng.U(95, 160)
			var/life = sh.rng.U(0.15, 0.22)
			var/sc = sh.R("drive_k", 0.6) * sh.rng.U(0.8, 1.25)
			var/vv = sh.rng.RandRange(4)
			NewObj(sh, list("kind" = "splash", "t0" = t0, "ang" = an, "side" = side, "life" = life, "scale" = sc, "vi" = vv))
	var/moving = isnull(sh.t_arrive) || k < sh.TThr("karr", sh.t_arrive)
	if(sh.R("variant") == "skyorb")
		var/rising = k >= sh.TThr("ksp0", sh.t_spawn) && k < sh.TThr("ksky", sh.t_sky)
		var/falling = !isnull(sh.t_launch) && k >= sh.TThr("kfa0", sh.t_launch, 1) && k < sh.TThr("kfa1", sh.t_hit)
		flying = rising || falling
		moving = 1
	if(flying && moving && sh.R("wake") && k != sh.last_wake)
		sh.last_wake = k
		var/list/pw = sh.PosAt(now)
		if(pw)
			var/n = sh.wake_n
			sh.wake_n = n + 1
			if(n == 0) sh.wake_k0 = k
			var/gw = EFXOEaseOut((now - sh.t_spawn) / sh.R("ignite", 0.08))
			var/ik = (sh.R("beam") == "godot") ? "BLMkBody" : WakeKey(sh)
			var/gsc = (sh.R("wake_kind") == "line") ? 1 : (0.4 + 0.6 * gw)
			if(sh.R("wake_kind") == "wavebody") gsc = 1 / max(0.000001, sh.R("size", 1))
			var/h_in = sh.Heading(now)
			var/h_out = h_in
			if(sh.R("wake_turns"))
				var/list/p2 = sh.PosAt(now + EFXB_TICK)
				if(p2 && EFXOHyp(p2[1] - pw[1], p2[2] + p2[3] - pw[2] - pw[3]) > 0.5) h_out = EFXOAtan2(p2[2] + p2[3] - pw[2] - pw[3], p2[1] - pw[1])
			var/np = EFXB_ART["[ik]:np"]
			var/list/base = list("kind" = "wake", "t0" = now, "P" = list(pw[1], pw[2] + pw[3]), "life" = EFXB_ART["[ik]:life"], "n" = EFXBMod(n, np),
				"scale" = sh.R("size", 1) * sh.size_k * gsc, "ww" = sh.R("wave_w", 1))
			var/turn = abs(EFXBMod(h_out - h_in + 180, 360) - 180)
			if(n == 0)
				var/list/o1 = base.Copy()
				o1["ang"] = h_out
				o1["first"] = 1
				NewObj(sh, o1)
			else if(turn < 1 || !EFXB_ART["[ik]:turns"])
				var/list/o2 = base.Copy()
				o2["ang"] = h_in
				NewObj(sh, o2)
			else
				var/list/o3 = base.Copy()
				o3["ang"] = h_in
				o3["half"] = "back"
				NewObj(sh, o3)
				var/list/o4 = base.Copy()
				o4["ang"] = h_out
				o4["half"] = "front"
				NewObj(sh, o4)
	if(!isnull(sh.t_end) && isnull(sh.t_hit) && !sh.fizz_done && k >= sh.TThr("kfz", sh.t_end - EFXB_TICK, 1) && !sh.R("no_fizzle"))
		sh.fizz_done = 1
		Specks(sh, "fizz", sh.t_end + 0.05, sh.end_pt, round(8 * sh.R("size", 1)), 0)

/datum/energyfx_blasts/var/list/spk_q
/datum/energyfx_blasts/var/list/spk_live

/datum/energyfx_blasts/proc/Specks(datum/energyfx_blastshot/sh, kind, t, list/P, n, ang)
	if(replay || !P || n <= 0) return
	if(!spk_q) spk_q = list()
	spk_q[++spk_q.len] = list(t, P[1], P[2], n)

/datum/energyfx_blasts/proc/SpeckColor()
	if(cols.gray) return list(0.875, 0.875, 0.875, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	var/list/edge = cols.ramp[2]
	var/list/core = cols.ramp[3]
	var/kp = BeamFXCool(0.95)
	return list((core[1] - edge[1]) * kp, (core[2] - edge[2]) * kp, (core[3] - edge[3]) * kp, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, edge[1], edge[2], edge[3], 0)

/datum/energyfx_blasts/proc/SpeckTick(k)
	if(spk_q && spk_q.len)
		var/list/rest = list()
		for(var/list/q in spk_q)
			if(T(k) < q[1] - 0.000001)
				rest[++rest.len] = q
				continue
			var/obj/energyfx/emit/O = EnergyFXGet(/obj/energyfx/emit, src)
			if(!O) continue
			O.fx_w = 32
			O.fx_h = 32
			if(!EnergyFXPlace(O, q[2], q[3], zz))
				EnergyFXFree(O)
				continue
			O.color = SpeckColor()
			var/particles/beamfx_speck/PT = new
			PT.icon = BEAMFX_SPECK_ICON
			PT.icon_state = cols.gray ? list("gss0" = 31, "gdu0" = 38, "gsk0" = 6) : list("pss0" = 31, "pdu0" = 38, "psk0" = 6)
			PT.lifespan = generator("num", 2.5, 4.5)
			PT.count = q[4]
			PT.position = generator("box", vector(-4, -4, 0), vector(4, 4, 0))
			PT.velocity = generator("circle", 3, 10)
			PT.bound2 = vector(1000, 1000, 1000)
			PT.transform = matrix(1, 0, q[2] - O.fx_bx, 0, 1, q[3] - O.fx_by)
			PT.spawning = q[4]
			O.particles = PT
			if(!spk_live) spk_live = list()
			spk_live[++spk_live.len] = list(O, k + 1, k + 14)
		spk_q = rest
	if(spk_live && spk_live.len)
		var/list/keep = list()
		for(var/list/e in spk_live)
			var/obj/energyfx/emit/O2 = e[1]
			if(e[2] >= 0 && k >= e[2])
				var/particles/P2 = O2.particles
				if(P2) P2.spawning = 0
				e[2] = -1
			if(k >= e[3])
				O2.particles = null
				EnergyFXFree(O2)
				continue
			keep[++keep.len] = e
		spk_live = keep

/datum/energyfx_blasts/Cleanup()
	for(var/list/e in spk_live)
		var/obj/energyfx/emit/O = e[1]
		O.particles = null
		EnergyFXFree(O)
	spk_live = null
	spk_q = null
	..()

var/list/EFXB_LAYERS = list(4.2, 4.25, 4.27, 4.3, 4.5, 4.6, 4.7, 4.9, 5, 5.1, 5.2, 5.3, 5.35, 5.4, 5.44, 5.45, 5.47, 5.5, 5.6, 5.7, 6)

proc/EFXBLayerRank(layer)
	for(var/i = 1 to EFXB_LAYERS.len)
		if(abs(EFXB_LAYERS[i] - layer) < 0.001) return i
	return EFXB_LAYERS.len + 1

/datum/energyfx_blastshot/var/ord = 0
/datum/energyfx_blastshot/var/idx2 = 0

/datum/energyfx_blasts/proc/Lay(layer, datum/energyfx_blastshot/sh, sub)
	return EFXBLayerRank(layer) * 65536 + (1 + sh.ord) * 512 + clamp(sub, 0, 511)

/datum/energyfx_blasts/proc/LayM(layer, datum/energyfx_blastshot/sh)
	return EFXBLayerRank(layer) * 65536 + clamp(sh.idx2, 0, 511)

/datum/energyfx_blasts/Draw(fi, v_unused)
	var/list/out = list()
	if(erupt) EruptDraw(out, fi)
	for(var/list/b in bigs) BigGround(out, b, fi)
	for(var/datum/energyfx_blastshot/sh in bshots)
		var/vq = Qs(sh, fi)
		sh.t_twos = EFXBFtime(fi - (fi % 2))
		ShotSprites(out, sh, EFXBFtime(vq), vq)
	for(var/list/b in bigs) BigBody(out, b, fi)
	if(sparks) SparksDraw(out, fi)
	return out

/datum/energyfx_blasts/proc/BigGround(list/out, list/b, fi)
	var/datum/energyfx_blastshot/sh = b[1]
	var/datum/energyfx_orbblast3/B = b[2]
	var/d = Qs(sh, fi) - EFXBFidx(sh.t_hit)
	if(d < 0) return
	B.Scorch(src, out, d, "b[sh.sid]", "GP", cols.LK("GL"))
	B.Ground(src, out, d, "b[sh.sid]", cols.LK("GL"))

/datum/energyfx_blasts/proc/BigBody(list/out, list/b, fi)
	var/datum/energyfx_blastshot/sh = b[1]
	var/datum/energyfx_orbblast3/B = b[2]
	var/d = Qs(sh, fi) - EFXBFidx(sh.t_hit)
	if(d < 0) return
	var/t = EFXBFtime(fi)
	var/list/smk = list()
	B.Particles(src, list(), smk, t, "b[sh.sid]", cols.LK("XL"), "SM")
	out += smk
	B.Body(src, out, d, "b[sh.sid]", 1600000)
	B.Particles(src, out, null, t, "b[sh.sid]", cols.LK("XL"))

/datum/energyfx_blasts/proc/EruptDraw(list/out, fi)
	var/datum/energyfx_blastshot/e = erupt[1]
	var/de = Qs(e, fi) - EFXBFidx(e.t_launch)
	if(de < 0 || de >= EFXB_ART["BLErupt:n"]) return
	var/k = erupt[4] / 44
	Rec(out, "er", cols.LK("GL"), "BLErupt", "[de]", erupt[2], erupt[3], 0, k, k, 1, LightM("BLErupt"), 0)

/datum/energyfx_blasts/proc/TgtOff(fi)
	if(!tgt_off) return list(0, 0)
	var/list/o = tgt_off["[fi]"]
	return o ? o : list(0, 0)

/datum/energyfx_blasts/proc/SparksDraw(list/out, fi)
	var/tf = EFXBFtime(fi)
	var/list/io = TgtOff(fi)
	var/ns = EFXB_ART["BLVdImpact:ns"]
	var/nvv = EFXB_ART["BLVdImpact:nv"]
	for(var/i = 1 to sparks.len)
		var/list/sp = sparks[i]
		if(tf < sp["t"] - 0.000000001) continue
		var/j = EFXBIntT((tf - sp["t"]) / EFXB_FR)
		if(j >= ns) continue
		var/st = "[EFXBMod(sp["v"], nvv)]_[j]"
		var/x = sp["bx"] + io[1]
		var/y = sp["by"] + io[2] + sp["jy"]
		var/mob/SM = sp["mob"]
		if(SM)
			if(!SM.loc) continue
			var/list/RB = BodyInkRectL(BodyInkProbe(SM))
			var/cd = cos(sp["dir"])
			if(abs(cd) < 0.38) x = RB[1] - 1 + RB[3] / 2
			else x = (SM.x - 1) * 32 + SM.step_x + ((cd > 0) ? 7 : 25)
			y = RB[2] - 1 + 12 + sp["jy"]
		Rec(out, "vi[i]", "XP", "BLVdImpact", "[st]b", x, y, sp["dir"], 1, sp["flip"], 1, null, EFXBLayerRank(6) * 65536 + i)
		Rec(out, "vi[i]a", "XS", "BLVdImpact", "[st]a", x, y, sp["dir"], 1, sp["flip"], 1, null, 0)

/datum/energyfx_blasts/proc/HitK(fi)
	var/k = 0
	for(var/datum/energyfx_blastshot/sh in bshots)
		var/vq = Qs(sh, fi)
		var/t = EFXBFtime(vq)
		if(isnull(sh.t_hit) || sh.ground) continue
		if(!isnull(sh.t_contact))
			if(vq < sh.Thr("contact", sh.t_contact)) continue
			var/q = t - sh.t_hit
			var/pulse = 0.82 + 0.18 * cos(360 * (t - sh.t_contact) / EFXB_TICK)
			var/kk = EFXOEaseOut((t - sh.t_contact) / 0.06) * ((vq < sh.Thr("hit", sh.t_hit)) ? pulse : 1) * (1 - EFXOSstep(0.24, 0.4, max(0, q)))
			k = max(k, 0.6 * kk)
			continue
		if(vq < sh.Thr("hit", sh.t_hit)) continue
		var/q2 = t - sh.t_hit
		var/hold = sh.R("hit_hold", 0.14) + 0.25
		var/kk2 = EFXOEaseOut(q2 / 0.08) * (1 - EFXOSstep(hold * 0.6, hold, q2))
		k = max(k, kk2 * sh.R("hit", 0.55) / 0.55)
	return min(1, k)

/datum/energyfx_blasts/proc/MuzzleK(fi)
	var/k = 0
	for(var/datum/energyfx_blastshot/sh in bshots)
		var/vq = Qs(sh, fi)
		var/t = EFXBFtime(vq)
		if(!sh.from_hand || isnull(sh.t_launch)) continue
		var/q = t - sh.t_launch
		if(vq >= sh.Thr("mk0", sh.t_launch - 0.02) && vq < sh.Thr("mk1", sh.t_launch + 0.2))
			k = max(k, EFXOEaseOut((q + 0.02) / 0.05) * (1 - EFXOSstep(0.06, 0.2, q)))
	return k

/datum/energyfx_blasts/Chars(k)
	var/dk0 = 0.46 * HitK(2 * k)
	var/dk1 = 0.46 * HitK(2 * k + 1)
	var/th = EFXBFtime(2 * k)
	var/rp = 0.72 + 0.1 * sin(360 * th / 0.33)
	var/rm0 = rp * HitK(2 * k)
	var/rm1 = rp * HitK(2 * k + 1)
	var/list/tl = EFXOLitColor(cols)
	if(target)
		CharFX(target, EFXBDirName(caster_dir), tl, dk0, dk1, rm0, rm1, 1)
	if(caster)
		CasterFX(caster, MuzzleK(2 * k), MuzzleK(2 * k + 1), tl)

/datum/energyfx_blasts/var/datum/bfx_char/crig

/datum/energyfx_blasts/proc/CasterFX(mob/M, mk0, mk1, list/tl)
	if(!M || !M.loc || M.z != zz) return
	if(!crig)
		crig = new(M, 1)
		chars[M] = crig
	var/d = EFXBDirName(M.dir)
	var/list/above = null
	var/list/hp = EFXBHandPx(d)
	if(d == "S" || d == "SE" || d == "SW") above = list(hp[1], hp[2])
	crig.BlastRefresh(d, "[d]|[M.icon_state]", above, list(hp[1], hp[2]), tl)
	EnergyFXOrbAnimAlpha(crig.rims, round(clamp(mk0, 0, 1) * 255, 1), round(clamp(mk1, 0, 1) * 255, 1))
	if(parity) OL("K [last_k] [M.x] [M.y] [d] [EnergyFXOrbN(mk0)] [EnergyFXOrbN(mk1)]")

proc/EFXBHandPx(d)
	switch(d)
		if("E", "SE", "NE") return list(11.5, 0.5)
		if("S") return list(8, 0.5)
		if("W", "SW", "NW") return list(-11.5, 0.5)
		if("N") return list(-10, 0.5)
	return list(11.5, 0.5)

proc/EFXBDirName(d)
	switch(d)
		if(NORTH) return "N"
		if(SOUTH) return "S"
		if(EAST) return "E"
		if(WEST) return "W"
		if(NORTHEAST) return "NE"
		if(NORTHWEST) return "NW"
		if(SOUTHEAST) return "SE"
		if(SOUTHWEST) return "SW"
	return "E"

/datum/bfx_char/proc/BlastRefresh(d, fkey2, list/above, list/palm, list/tl)
	if(M.appearance == app && fkey2 == fkey) return
	app = M.appearance
	fkey = fkey2
	var/apart = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	Copy(sil, 0, FLOAT_LAYER, apart)
	sil.render_target = "*[id]"
	Copy(occ, ENERGYFX_OCC_PLANE, 1, apart)
	Copy(locc, ENERGYFX_LOCC_PLANE, 1, apart)
	var/list/fo = list()
	if(above)
		fo += filter(type = "alpha", icon = BeamFXMaskIcon("above"), x = above[1], y = above[2])
	occ.filters = fo.len ? fo : null
	locc.filters = fo.len ? fo.Copy() : null
	var/list/dv = BeamFXDirVec(d)
	BeamFXRimBuild(M, "*[id]", -dv[1], -dv[2], tl, 1.45, 0.3, rims.len / 2, palm, rims)

/datum/energyfx_blasts/TickWork(k)
	for(var/datum/energyfx_blastshot/sh in bshots)
		TickShot(sh, k)
	if(spk_q || spk_live) SpeckTick(k)

/datum/energyfx_blasts/Sample(k)
	if(replay) return
	..()

/datum/energyfx_blasts/AllEnded()
	if(replay) return rdata && last_k >= rdata["ticks"] - 1
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(isnull(sh.k_end)) return 0
	return 1

/datum/energyfx_blasts/Busy(k)
	if((spk_q && spk_q.len) || (spk_live && spk_live.len)) return 1
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(sh.objs.len) return 1
	for(var/list/b in bigs)
		var/datum/energyfx_orbblast3/B = b[2]
		var/datum/energyfx_blastshot/s2 = b[1]
		var/v = 2 * k + 1
		if(B.Alive(v / 40, v - 2 * s2.t_hit / EFXB_TICK)) return 1
	return 0

/datum/energyfx_blastcolors
	parent_type = /datum/energyfx_orbcolors

/datum/energyfx_blastcolors/Body(key)
	if(anchor || gray || canon) return null
	return EFXBFitMatrix(key, main255, core255, glow255, sub ? pal : null)

var/list/EFXB_FITCACHE = list()

proc/EFXBMine(ws, nv, list/ramp, list/pal)
	var/calm = 1 - 0.92 * EFXOSstep(0.12, 0.55, ws)
	var/I = clamp(0.5 + 0.5 * ws + 0.9 * calm * (nv - 0.5), 0, 1)
	var/m = 1 + 1.35 * calm * (nv - 0.5)
	var/list/edge = ramp[2]
	var/list/core = ramp[3]
	var/wc = clamp(ws, 0, 1)
	var/list/ca = list(clamp(edge[1] + wc * (core[1] - edge[1]), 0, 1), clamp(edge[2] + wc * (core[2] - edge[2]), 0, 1), clamp(edge[3] + wc * (core[3] - edge[3]), 0, 1))
	var/t = EFXOLum3(ca) * m
	var/list/gr = EFXORampAdd(I, pal)
	var/mx = max(gr[1], gr[2], gr[3], 0.0001)
	var/list/hu = list(gr[1] / mx, gr[2] / mx, gr[3] / mx)
	var/yg = max(EFXOLum3(hu), 0.001)
	return list(clamp(hu[1] / yg * t, 0, 1), clamp(hu[2] / yg * t, 0, 1), clamp(hu[3] / yg * t, 0, 1))

proc/EFXBFitMatrix(key, list/C255, list/core255, list/glow255, list/subpal)
	var/ck = "[key]|[jointext(C255, ",")]|[core255 ? jointext(core255, ",") : "-"]|[glow255 ? jointext(glow255, ",") : "-"][subpal ? "|sub" : ""]"
	var/list/hit = EFXB_FITCACHE[ck]
	if(hit) return hit
	var/list/F = EFXB_FIT[key]
	if(!F) return null
	var/n = F[1]
	var/list/ramp = BeamFXRamp(C255, core255, glow255)
	var/list/pal = subpal ? subpal : EFXOPalette(C255, core255, glow255)
	var/list/co = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	for(var/s = 1 to n)
		var/list/T = EFXBMine(F[1 + s], F[1 + n + s], ramp, pal)
		for(var/r = 0 to 3)
			var/p = F[1 + 2 * n + r * n + s]
			co[r * 3 + 1] += p * T[1]
			co[r * 3 + 2] += p * T[2]
			co[r * 3 + 3] += p * T[3]
	var/list/M = list(co[1], co[2], co[3], 0, co[4], co[5], co[6], 0, co[7], co[8], co[9], 0, 0, 0, 0, 1, co[10], co[11], co[12], 0)
	EFXB_FITCACHE[ck] = M
	if(EFXB_FITCACHE.len > 512) EFXB_FITCACHE.Cut(1, 2)
	return M

/datum/energyfx_blastshot/var/list/base0
/datum/energyfx_blastshot/var/lay_n = 0
/datum/energyfx_blastshot/var/bulge = 0
/datum/energyfx_blastshot/var/spd_f = 1
/datum/energyfx_blastshot/var/delay = 0
/datum/energyfx_blastshot/var/lat0 = 1
/datum/energyfx_blastshot/var/mob/tgt
/datum/energyfx_blastshot/var/miss = 0
/datum/energyfx_blastshot/var/charging = 0
/datum/energyfx_blastshot/var/list/raw = list()
/datum/energyfx_blastshot/var/vx = 0
/datum/energyfx_blastshot/var/vy = 0
/datum/energyfx_blastshot/var/list/dir0
/datum/energyfx_blastshot/var/virtual = 0
/datum/energyfx_blastshot/var/big_only = 0
/datum/energyfx_blastshot/var/t_pred
/datum/energyfx_blasts/live/var/list/fire_slots

proc/EFXBDirAngle(d)
	return 90 - dir2angle(d)

var/list/EFXB_FEED_WIN = list("stream" = 0.5, "barrage" = 0.5, "burst" = 0.5, "random_home" = 0.5, "turret" = 0.5, "hellzone" = 0.6, "stormfall" = 0.6)

/datum/energyfx_blasts/live
	var/last_spawn_k = -1000
	var/list/hitmobs = list()

/datum/energyfx_blasts/live/Accepts(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	if(done || row != R || !P.Owner || P.Owner != caster || P.z != zz) return 0
	return Now() - last_spawn_k <= 20

/datum/energyfx_blasts/live/proc/CasterC()
	if(!caster || !caster.loc) return null
	return list((caster.x - 1) * 32 + caster.step_x + 16, (caster.y - 1) * 32 + caster.step_y + 16)

/datum/energyfx_blasts/live/proc/Palm(d)
	var/list/c = CasterC()
	if(!c) return null
	var/list/h = EFXBHandPx(EFXBDirName(d))
	return list(c[1] + h[1], c[2] + h[2])

/datum/energyfx_blasts/live/proc/ChargeShot()
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(sh.charging && !sh.P) return sh
	return null

/datum/energyfx_blasts/live/InitCharge(mob/M, obj/Skills/Z, datum/energyfx_row/R, datum/energyfx_look/L)
	..()
	last_spawn_k = Now()
	var/datum/energyfx_blastshot/sh = NewShot(Now())
	sh.charging = 1
	sh.zz = M.z
	sh.ang0 = EFXBDirAngle(M.dir)
	sh.hand = Palm(M.dir)
	if(!sh.hand) sh.hand = CasterC()
	var/lf = sh.R("launch_fwd", 0)
	sh.charge_pt = list(sh.hand[1] + cos(sh.ang0) * lf, sh.hand[2] + sin(sh.ang0) * lf)
	sh.base0 = sh.charge_pt.Copy()
	sh.lg += list(list(sh.t_spawn, sh.charge_pt[1], sh.charge_pt[2], 0))

/datum/energyfx_blasts/live/proc/NewShot(k)
	var/datum/energyfx_blastshot/sh = new
	sh.S = src
	sh.idx = shots.len
	sh.zz = zz
	sh.r = RowOf(row)
	sh.sid = bshots.len
	sh.idx2 = sh.sid
	sh.ord = sh.sid
	sh.rng = Stream("s[sh.sid]")
	sh.seq = sh.rng.RandRange(EFXB_NF)
	sh.k_spawn = k
	sh.t_spawn = T(k)
	sh.first_volley = (k - K0 <= 3)
	shots += sh
	bshots += sh
	return sh

/datum/energyfx_blasts/live/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/k = Now()
	last_spawn_k = k
	var/datum/energyfx_blastshot/sh = ChargeShot()
	var/list/c
	if(sh)
		sh.charging = 0
		sh.P = P
		sh.zz = P.z
		sh.t_launch = T(k)
		c = sh.Center()
		if(c)
			sh.base0 = c.Copy()
			sh.charge_pt = c.Copy()
			sh.dir0 = list(cos(sh.ang0), sin(sh.ang0))
			sh.lg = list(list(sh.t_spawn, c[1], c[2], 0))
			LogPos(sh, k, c)
		if(parity) OL("E [sh.idx] attach [k]")
		return sh
	sh = NewShot(k)
	sh.P = P
	sh.zz = P.z
	var/d = P.DirOverride || P.dir
	sh.ang0 = EFXBDirAngle(d)
	sh.dir0 = list(cos(sh.ang0), sin(sh.ang0))
	c = sh.Center()
	if(!c) c = Palm(d)
	sh.base0 = c.Copy()
	sh.hand = c.Copy()
	sh.vx = P.VariationX
	sh.vy = P.VariationY
	var/pat = sh.R("pattern")
	switch(pat)
		if("minefield")
			var/list/pm = Palm(caster ? caster.dir : d)
			if(pm) sh.hand = pm
			sh.t_launch = sh.t_spawn
			var/dd = EFXOHyp(c[1] - sh.hand[1], c[2] - sh.hand[2])
			sh.lay_n = max(2, ceil(dd / sh.R("lay_px", 48)))
			sh.t_arrive = sh.t_spawn + sh.lay_n * EFXB_TICK
			sh.ang0 = EFXOAtan2(c[2] - sh.hand[2], c[1] - sh.hand[1])
		if("stormfall")
			var/list/ps = Palm(caster ? caster.dir : d)
			if(ps) sh.hand = ps
			sh.t_sky = sh.t_spawn + sh.R("rise_ticks", 5) * EFXB_TICK
			sh.ang0 = 90
			sh.ground = 1
		if("burst")
			sh.bulge = sh.rng.U(-1, 1) * sh.R("bulge", 18)
			sh.spd_f = sh.rng.U(0.88, 1.12)
			sh.delay = sh.rng.U(0, 0.05)
			sh.size_k = sh.rng.U(0.85, 1.15)
			sh.lat0 = 0.6
		if("radial", "turret")
			sh.bulge = sh.rng.U(-1, 1) * sh.R("bulge", 12)
			sh.spd_f = sh.rng.U(0.9, 1.1)
			sh.delay = sh.rng.U(0, 0.04)
			sh.size_k = sh.rng.U(0.88, 1.12)
			sh.lat0 = 0
			if(!erupt && sh.R("erupt", 0) > 0)
				var/list/cc = CasterC()
				if(cc) erupt = list(sh, cc[1], cc[2], sh.R("erupt", 0))
		if("barrage")
			sh.size_k = sh.rng.U(0.86, 1.14)
			sh.spd_f = sh.rng.U(0.94, 1.06)
		if("stream")
			sh.lat0 = 0.5
		if("hellzone")
			sh.from_hand = 0
			Flurry(sh, k, c, d)
		if("instant", "flurry")
			sh.vi = sh.rng.RandRange(3)
			if(pat == "instant") sh.ci = sh.rng.RandRange(2)
			sh.flip = (sh.rng.U(0, 1) < 0.5) ? 1 : -1
			if(pat == "flurry")
				sh.kv = sh.rng.U(0.92, 1.08)
				sh.hand = list(c[1] + sh.vx, c[2] + sh.vy)
				sh.vx = 0
				sh.vy = 0
	if(sh.R("variant") == "laser" || pat == "instant" || pat == "flurry" || pat == "finale")
		sh.t_launch = sh.t_spawn
	LogPos(sh, k, c)
	if(parity)
		var/list/cc = CasterC()
		OL("E [sh.idx] spawn [k] [EnergyFXOrbN(c[1])] [EnergyFXOrbN(c[2])] [P.DirOverride || P.dir] [cc ? EnergyFXOrbN(cc[1]) : "-"] [cc ? EnergyFXOrbN(cc[2]) : "-"] [caster ? caster.dir : 0]")
	return sh

/datum/energyfx_blasts/live/proc/Flurry(datum/energyfx_blastshot/orb, k, list/P, d)
	var/list/rf = EFXB_ROWS["Hellzone_Grenade_fire"]
	var/list/hand = Palm(caster ? caster.dir : d)
	if(!rf || !hand) return
	if(!fire_slots)
		fire_slots = list()
		for(var/i = 0 to 11) fire_slots += i
	var/slot = fire_slots.len ? fire_slots[orb.rng.RandRange(fire_slots.len) + 1] : 12
	fire_slots -= slot
	var/mob/T = caster ? caster.Target : null
	var/list/tc = (ismob(T) && T.z == zz) ? list((T.x - 1) * 32 + T.step_x + 16, (T.y - 1) * 32 + T.step_y + 16) : null
	var/datum/energyfx_blastshot/fs = NewShot(k)
	fs.r = rf
	fs.virtual = 1
	fs.ground = 1
	fs.from_hand = 1
	fs.hand = hand
	fs.k_end = k
	var/fg = rf["fire_gap"]
	if(isnull(fg)) fg = 0.03
	var/tl = T(k) + fg * slot
	fs.t_spawn = tl
	fs.t_launch = tl
	var/cx = (hand[1] + P[1]) * 0.5
	var/cy = (hand[2] + P[2]) * 0.5
	var/dx = P[1] - hand[1]
	var/dy = P[2] - hand[2]
	var/dl = max(0.000001, EFXOHyp(dx, dy))
	var/nx = -dy / dl
	var/ny = dx / dl
	var/sgn = (fs.rng.U(0, 1) < 0.5) ? -1 : 1
	if(tc)
		var/side = (tc[1] - cx) * nx + (tc[2] - cy) * ny
		if(side > 4) sgn = -1
		else if(side < -4) sgn = 1
	var/bulge = sgn * fs.rng.U(30, 60)
	if(tc)
		for(var/tr = 1 to 24)
			var/qx = cx + nx * bulge
			var/qy = cy + ny * bulge
			var/near = 1e9
			for(var/ui = 0 to 40)
				var/u = ui / 40
				var/bx = (1 - u) * (1 - u) * hand[1] + 2 * (1 - u) * u * qx + u * u * P[1]
				var/by = (1 - u) * (1 - u) * hand[2] + 2 * (1 - u) * u * qy + u * u * P[2]
				near = min(near, EFXOHyp(bx - tc[1], by - tc[2]))
			if(near >= 30) break
			bulge += 8 * sgn
	ArcLog(fs, hand, P, bulge, 40 * fs.rng.U(0.92, 1.08), tl)
	orb.t_spawn = fs.t_hit

/datum/energyfx_blasts/live/proc/ArcLog(datum/energyfx_blastshot/sh, list/st, list/en, bulge, speed, tl)
	var/cx = (st[1] + en[1]) * 0.5
	var/cy = (st[2] + en[2]) * 0.5
	var/dx = en[1] - st[1]
	var/dy = en[2] - st[2]
	var/dl = max(0.000001, EFXOHyp(dx, dy))
	var/qx = cx - dy / dl * bulge
	var/qy = cy + dx / dl * bulge
	var/list/pts = list()
	var/list/cum = list(0)
	for(var/i = 0 to 200)
		var/u = i / 200
		pts[++pts.len] = list((1 - u) * (1 - u) * st[1] + 2 * (1 - u) * u * qx + u * u * en[1], (1 - u) * (1 - u) * st[2] + 2 * (1 - u) * u * qy + u * u * en[2])
		if(i) cum += cum[i] + EFXOHyp(pts[i + 1][1] - pts[i][1], pts[i + 1][2] - pts[i][2])
	var/tot = cum[cum.len]
	sh.ang0 = EFXOAtan2(pts[2][2] - pts[1][2], pts[2][1] - pts[1][1])
	sh.lg = list(list(tl, st[1], st[2], 0))
	var/t = (floor(tl / EFXB_TICK + 0.000000001) + 1) * EFXB_TICK
	var/dd = 0
	var/j = 1
	for(var/guard = 1 to 400)
		dd += speed * ((t - max(tl, t - EFXB_TICK)) / EFXB_TICK)
		var/stop = dd >= tot
		var/dq = min(dd, tot)
		while(j < cum.len - 1 && cum[j + 1] < dq) j++
		var/g = (cum[j + 1] - cum[j] < 0.000000001) ? 0 : (dq - cum[j]) / (cum[j + 1] - cum[j])
		var/x = pts[j][1] + (pts[j + 1][1] - pts[j][1]) * g
		var/y = pts[j][2] + (pts[j + 1][2] - pts[j][2]) * g
		sh.lg[++sh.lg.len] = list(t, x, y, 0)
		if(stop)
			sh.t_hit = t
			sh.hit_pt = list(x, y)
			return
		t += EFXB_TICK

/datum/energyfx_blasts/live/proc/Remaining(datum/energyfx_blastshot/sh, list/c)
	var/obj/Skills/Projectile/_Projectile/P = sh.P
	if(!P) return 0
	var/mob/T = ismob(P.Homing) ? P.Homing : null
	if(!T && caster && caster.Target && ismob(caster.Target)) T = caster.Target
	var/rng_left = max(0, P.Distance) * 32
	if(T && T.z == sh.zz && sh.dir0)
		var/tx = (T.x - 1) * 32 + T.step_x + 16 - c[1]
		var/ty = (T.y - 1) * 32 + T.step_y + 16 - c[2]
		var/along = tx * sh.dir0[1] + ty * sh.dir0[2]
		var/lat = abs(-tx * sh.dir0[2] + ty * sh.dir0[1])
		if(along > 0 && lat < 24) return min(rng_left, max(0, along - sh.R("contact", 10)))
	return rng_left

/datum/energyfx_blasts/live/proc/Cosmetic(datum/energyfx_blastshot/sh, t, list/c)
	var/x = c[1]
	var/y = c[2]
	var/z = 0
	var/obj/Skills/Projectile/_Projectile/P = sh.P
	if(P && P.pixel_z > 0) z = P.pixel_z
	var/pat = sh.R("pattern")
	if(pat == "minefield" && !isnull(sh.t_arrive) && t < sh.t_arrive - 0.000001)
		var/q = clamp((t - sh.t_spawn) / (sh.lay_n * EFXB_TICK), 0, 1)
		var/e = 1 - (1 - q) * (1 - q)
		return list(sh.hand[1] + (c[1] - sh.hand[1]) * e, sh.hand[2] + (c[2] - sh.hand[2]) * e, 0)
	if(pat == "stormfall")
		if(!isnull(sh.t_sky) && t < sh.t_sky - 0.000001)
			var/q2 = clamp((t - sh.t_spawn) / (sh.t_sky - sh.t_spawn), 0, 1)
			var/e2 = 1 - (1 - q2) * (1 - q2)
			return list(sh.hand[1] + (c[1] - sh.hand[1]) * e2, sh.hand[2] + (c[2] - sh.hand[2]) * e2, sh.R("sky_z", 180) * (1 - (1 - q2) ** 1.5))
		return list(x, y, isnull(sh.t_launch) ? sh.R("sky_z", 180) : z)
	if(isnull(sh.t_launch) || !sh.dir0) return list(x, y, z)
	var/age = t - sh.t_launch
	var/nx = -sh.dir0[2]
	var/ny = sh.dir0[1]
	if(pat in list("stream", "burst", "radial", "turret"))
		var/dtr = (c[1] - sh.base0[1]) * sh.dir0[1] + (c[2] - sh.base0[2]) * sh.dir0[2]
		var/rem = Remaining(sh, c)
		var/u = clamp(dtr / max(1, dtr + rem), 0, 1)
		var/lat = -sh.vx * sh.dir0[2] + sh.vy * sh.dir0[1]
		var/off = lat * (sh.lat0 + (1 - sh.lat0) * u) + sh.bulge * 2 * u * (1 - u)
		var/spd = sh.P ? max(1, sh.P.step_size) : 32
		var/fwd = (sh.spd_f - 1) * dtr * (1 - u) - spd * (sh.delay / EFXB_TICK) * (1 - u)
		fwd = max(-dtr, fwd)
		return list(x + nx * off + sh.dir0[1] * fwd, y + ny * off + sh.dir0[2] * fwd, z)
	if(sh.vx || sh.vy)
		var/q3 = clamp(age / 0.3, 0, 1)
		var/ks = q3 * q3 * (3 - 2 * q3)
		return list(x + sh.vx * ks, y + sh.vy * ks, z)
	return list(x, y, z)

/datum/energyfx_blasts/live/proc/LogPos(datum/energyfx_blastshot/sh, k, list/c, exact = 0)
	if(!c) return
	var/t = T(k)
	var/list/p = Cosmetic(sh, t, c)
	if(sh.R("pattern") == "random_home" && !isnull(sh.t_launch))
		var/kk = k - sh.k_spawn + 1
		if(sh.raw.len < kk) sh.raw.len = kk
		sh.raw[kk] = list(p[1], p[2])
		if(!exact && kk >= 2 && sh.raw[kk - 1])
			var/list/b = sh.raw[kk - 1]
			var/list/a = (kk >= 3 && sh.raw[kk - 2]) ? sh.raw[kk - 2] : b
			p = list((a[1] + 6 * b[1] + p[1]) / 8, (a[2] + 6 * b[2] + p[2]) / 8, p[3])
	var/n = sh.lg.len
	if(n)
		var/list/e = sh.lg[n]
		if(abs(e[1] - t) < 0.000001)
			sh.lg[n] = list(t, p[1], p[2], p[3])
			return
		if(e[1] > t) return
	sh.lg[++sh.lg.len] = list(t, p[1], p[2], p[3])

/datum/energyfx_blasts/live/Sample(k)
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(sh.virtual) continue
		if(sh.charging)
			if(k - sh.k_spawn > 60)
				sh.charging = 0
				sh.k_end = k
			continue
		if(sh.dropped || !isnull(sh.k_end)) continue
		if(!sh.P || !sh.P.loc || sh.P.efx_orb != sh)
			EndShot(sh, k, 1)
			continue
		var/list/c = sh.Center()
		LogPos(sh, k, c)
		if(parity && c) OL("P [sh.idx] [k] [EnergyFXOrbN(c[1])] [EnergyFXOrbN(c[2])] [sh.P.pixel_z] [sh.P.dir]")
		if(c && isnull(sh.t_hit) && isnull(sh.t_pred) && !isnull(sh.t_launch) && sh.dir0)
			var/spd = max(1, sh.P.step_size)
			var/rem = Remaining(sh, c)
			var/mob/T = ismob(sh.P.Homing) ? sh.P.Homing : (caster ? caster.Target : null)
			if(ismob(T) && rem < max(0, sh.P.Distance) * 32 && rem <= 2 * spd)
				sh.t_pred = T(k + max(1, ceil(rem / spd)))

/datum/energyfx_blasts/live/OnTick(datum/energyfx_orbshot/O)
	var/datum/energyfx_blastshot/sh = O
	if(!sh.P) return
	var/k = Now()
	LogPos(sh, k, sh.Center())
	if(last_k == k && !done) DrawTick(k)

/datum/energyfx_blasts/live/OnLaunch(datum/energyfx_orbshot/O)
	var/datum/energyfx_blastshot/sh = O
	var/k = Now()
	O.k_launch = k
	if(isnull(sh.t_launch)) sh.t_launch = T(k)
	var/pat = sh.R("pattern")
	if(sh.P && !(pat in list("minefield", "stormfall")))
		var/d = sh.P.DirOverride || sh.P.dir
		sh.ang0 = EFXBDirAngle(d)
		sh.dir0 = list(cos(sh.ang0), sin(sh.ang0))
	if(pat == "stormfall") LogPos(sh, k, sh.Center())
	if(parity) OL("E [O.idx] launch [k]")

/datum/energyfx_blasts/live/proc/CurPos(datum/energyfx_blastshot/sh, k)
	var/list/c = sh.Center()
	if(c) LogPos(sh, k, c, 1)
	var/list/p = sh.PosAt(T(k))
	return p ? list(p[1], p[2] + p[3]) : null

/datum/energyfx_blasts/live/OnHit(datum/energyfx_orbshot/O, atom/target)
	var/datum/energyfx_blastshot/sh = O
	var/k = Now()
	var/list/hp = CurPos(sh, k)
	if(!hp) return
	if(parity) OL("E [O.idx] hit [k] [target ? "[target.type]" : "-"] [EnergyFXProjectileOwned(sh.P)] [EnergyFXOrbN(hp[1])] [EnergyFXOrbN(hp[2])]")
	if(ismob(target))
		if(!sh.tgt) sh.tgt = target
		if(!(target in hitmobs)) hitmobs += target
		if(sh.R("variant") == "void")
			if(!sparks) sparks = list()
			sparks[++sparks.len] = list("t" = T(k), "v" = sh.rng.RandRange(3), "flip" = (sh.rng.U(0, 1) < 0.5) ? 1 : -1, "jy" = sh.rng.U(-3, 3), "dir" = sh.ang0, "bx" = 0, "by" = 0, "mob" = target)
	var/pat = sh.R("pattern")
	if(pat == "drive" || (sh.P && sh.P.DriveTarget))
		if(isnull(sh.t_contact))
			sh.t_contact = T(k)
			sh.contact_pt = hp
	else if(isnull(sh.t_hit))
		SetHit(sh, k, hp)
	if(last_k == k && !done) DrawTick(k)

/datum/energyfx_blasts/live/proc/SetHit(datum/energyfx_blastshot/sh, k, list/hp)
	sh.t_hit = T(k)
	sh.hit_pt = hp
	if(sh.R("variant") == "timeskip" && sh.hand) sh.L = EFXOHyp(hp[1] - sh.hand[1], hp[2] - sh.hand[2])
	if(sh.R("variant") == "laser" && sh.hand && sh.R("pierce"))
		sh.pierce_pts = list()
		for(var/mob/M in hitmobs)
			var/list/mc = list((M.x - 1) * 32 + M.step_x + 16, (M.y - 1) * 32 + M.step_y + 16)
			sh.pierce_pts[++sh.pierce_pts.len] = list(mc[1] - cos(sh.ang0) * 8, mc[2] - sin(sh.ang0) * 8)
	Feed(sh)
	var/ex = sh.R("explode", 0)
	if(ex >= 2) BigAt(sh, 16 * ex)

/datum/energyfx_blasts/live/proc/Feed(datum/energyfx_blastshot/sh)
	var/win = EFXB_FEED_WIN[sh.R("pattern")]
	if(isnull(win) || sh.R("hit", 0) <= 0) return
	var/dist = sh.R("feed_dist", sh.R("pattern") == "hellzone" ? 40 : 18)
	for(var/datum/energyfx_blastshot/ld in bshots)
		if(ld == sh || isnull(ld.t_hit) || ld.lead || ld.R("hit", 0) <= 0) continue
		var/mxf = ld.t_hit
		if(ld.feeds) for(var/tf in ld.feeds) mxf = max(mxf, tf)
		var/end = ld.t_hit + win + (mxf - ld.t_hit)
		if(sh.t_hit <= end + 0.000001 && EFXOHyp(sh.hit_pt[1] - ld.hit_pt[1], sh.hit_pt[2] - ld.hit_pt[2]) <= dist)
			sh.lead = ld
			if(!ld.feeds) ld.feeds = list()
			ld.feeds += sh.t_hit
			if(!ld.feed_angs) ld.feed_angs = list()
			ld.feed_angs["[ld.feeds.len]"] = sh.Heading(sh.t_hit - 0.0001)
			return

/datum/energyfx_blasts/live/proc/BigAt(datum/energyfx_blastshot/sh, Re, datum/bfx_rng/G = null)
	if(!bigs) bigs = list()
	if(!G) G = Stream("b[sh.sid]")
	var/rs = EFXOE4Set(Re)
	var/dome = BigDome(Re)
	var/datum/energyfx_orbblast3/B = new(G, Re, sh.hit_pt[1], sh.hit_pt[2], sh.t_hit / EFXB_TICK, null, dome, "B3Ground[rs][cols.gray ? "G" : ""]", cols.LM("hl"), EFXO_LM_SCORCH)
	if(findtext(dome, "E4") == 1 || findtext(dome, "B3E4"))
		B.e4 = dome
		B.e4m = EFXOE4Mats(dome, cols.pal)
	B.lm_flash = cols.LM("flash")
	B.fl_kinds = list("XP", "XS", cols.LK("XL"))
	bigs[++bigs.len] = list(sh, B)

/datum/energyfx_blasts/live/proc/EndShot(datum/energyfx_blastshot/sh, k, lost = 0)
	if(!isnull(sh.k_end)) return
	sh.k_end = k
	var/list/hp = sh.lg.len ? list(sh.lg[sh.lg.len][2], sh.lg[sh.lg.len][3] + sh.lg[sh.lg.len][4]) : null
	if(!lost && sh.P) hp = CurPos(sh, k)
	if(!hp) return
	if(!isnull(sh.t_contact) && isnull(sh.t_hit))
		SetHit(sh, k, hp)
		return
	if(!isnull(sh.t_hit)) return
	var/vr = sh.R("variant")
	var/killed = !sh.P || sh.P.Killed
	if(!killed && sh.R("explode", 0) >= 1 && vr != "laser" && vr != "void" && vr != "timeskip")
		sh.miss = 1
		SetHit(sh, k, hp)
		return
	sh.t_end = T(k)
	sh.end_pt = hp
	if(vr == "timeskip" && sh.hand) sh.L = EFXOHyp(hp[1] - sh.hand[1], hp[2] - sh.hand[2])

/datum/energyfx_blasts/live/OnFinish(datum/energyfx_orbshot/O)
	var/datum/energyfx_blastshot/sh = O
	if(!isnull(sh.k_end)) return 1
	var/k = Now()
	EndShot(sh, k, 0)
	if(parity) OL("E [O.idx] finish [k] [sh.miss]")
	if(last_k == k && !done) DrawTick(k)
	return 1

/datum/energyfx_blasts/live/Chars(k)
	if(caster) CasterFX(caster, MuzzleK(2 * k), MuzzleK(2 * k + 1), EFXOLitColor(cols))
	if(!hitmobs.len) return
	var/list/tl = EFXOLitColor(cols)
	var/th = EFXBFtime(2 * k)
	var/rp = 0.72 + 0.1 * sin(360 * th / 0.33)
	for(var/mob/M in hitmobs)
		var/h0 = HitKFor(M, 2 * k)
		var/h1 = HitKFor(M, 2 * k + 1)
		CharFX(M, EFXBDirName(caster_dir), tl, 0.46 * h0, 0.46 * h1, rp * h0, rp * h1, 1)

/datum/energyfx_blasts/live/proc/HitKFor(mob/M, fi)
	var/k = 0
	for(var/datum/energyfx_blastshot/sh in bshots)
		if(sh.tgt != M || sh.miss) continue
		var/vq = Qs(sh, fi)
		var/t = EFXBFtime(vq)
		if(isnull(sh.t_hit) && isnull(sh.t_contact)) continue
		if(!isnull(sh.t_contact))
			if(vq < sh.Thr("contact", sh.t_contact)) continue
			var/q = isnull(sh.t_hit) ? 0 : t - sh.t_hit
			var/pulse = 0.82 + 0.18 * cos(360 * (t - sh.t_contact) / EFXB_TICK)
			var/hitd = !isnull(sh.t_hit) && vq >= sh.Thr("hit", sh.t_hit)
			var/kk = EFXOEaseOut((t - sh.t_contact) / 0.06) * (hitd ? 1 : pulse) * (1 - EFXOSstep(0.24, 0.4, max(0, q)))
			k = max(k, 0.6 * kk)
			continue
		if(vq < sh.Thr("hit", sh.t_hit)) continue
		var/q2 = t - sh.t_hit
		var/hold = sh.R("hit_hold", 0.14) + 0.25
		k = max(k, EFXOEaseOut(q2 / 0.08) * (1 - EFXOSstep(hold * 0.6, hold, q2)) * sh.R("hit", 0.55) / 0.55)
	return min(1, k)

/datum/bfx_rng/replay
	var/list/vals
	var/ri = 0

/datum/bfx_rng/replay/R()
	ri++
	return (ri <= vals.len) ? vals[ri] : 0

/datum/bfx_rng/replay/RandRange(n)
	ri++
	return (ri <= vals.len) ? vals[ri] : 0

/datum/energyfx_blasts/proc/PtOff(list/p)
	if(!p) return null
	return list(p[1] + rdata["off"][1], p[2] + rdata["off"][2])

/datum/energyfx_blasts/proc/InitReplay(list/D, mob/C, mob/T, obj/Skills/Z)
	replay = 1
	rdata = D
	look = energyfx_blast_look
	row = EnergyFXRowOf(Z.type)
	extra = row.extra
	caster = C
	target = T
	from = Z
	zz = C.z
	K0 = EnergyFXNow()
	parity = 1
	SetupColors(Z, row)
	caster_dir = C.dir
	var/ox = D["off"][1]
	var/oy = D["off"][2]
	var/list/rows = EFXB_ROWS
	for(var/list/s in D["shots"])
		var/datum/energyfx_blastshot/sh = new
		sh.S = src
		sh.r = rows[s["row"]]
		sh.sid = s["sid"]
		sh.rng = new /datum/bfx_rng(s["seed"])
		sh.seq = sh.rng.RandRange(16)
		sh.idx = bshots.len
		sh.idx2 = s["idx2"]
		sh.ord = s["ord"]
		sh.t_spawn = s["t_spawn"]
		sh.t_launch = s["t_launch"]
		sh.t_hit = s["t_hit"]
		sh.t_end = s["t_end"]
		sh.t_contact = s["t_contact"]
		sh.t_arrive = s["t_arrive"]
		sh.t_sky = s["t_sky"]
		sh.from_hand = s["from_hand"]
		sh.ang0 = s["ang0"]
		sh.size_k = s["size_k"]
		sh.first_volley = s["first_volley"]
		sh.merge_k = s["merge_k"]
		sh.merge_skip = s["merge_skip"]
		sh.ground = s["ground"]
		sh.kv = s["kv"]
		sh.vi = s["vi"]
		sh.flip = s["flip"]
		sh.ci = s["ci"]
		sh.L = s["L"]
		sh.thr = s["thr"]
		sh.ties = s["ties"]
		sh.splash_draws = s["splash"]
		sh.feeds = s["feeds"]
		sh.feed_angs = s["feed_angs"]
		if(s["hand"]) sh.hand = list(s["hand"][1] + ox, s["hand"][2] + oy)
		if(s["hit_pt"]) sh.hit_pt = list(s["hit_pt"][1] + ox, s["hit_pt"][2] + oy)
		if(s["end_pt"]) sh.end_pt = list(s["end_pt"][1] + ox, s["end_pt"][2] + oy)
		if(s["contact_pt"]) sh.contact_pt = list(s["contact_pt"][1] + ox, s["contact_pt"][2] + oy)
		if(s["charge_pt"]) sh.charge_pt = list(s["charge_pt"][1] + ox, s["charge_pt"][2] + oy)
		if(s["pierce_pts"])
			sh.pierce_pts = list()
			for(var/list/pp in s["pierce_pts"]) sh.pierce_pts[++sh.pierce_pts.len] = list(pp[1] + ox, pp[2] + oy)
		for(var/list/e in s["log"]) sh.lg[++sh.lg.len] = list(e[1], e[2] + ox, e[3] + oy, e[4])
		if(s["seq"] != sh.seq) OL("X seq [sh.sid] mock [s["seq"]] dm [sh.seq]")
		shots += sh
		bshots += sh
	var/list/byid = list()
	for(var/datum/energyfx_blastshot/sh in bshots) byid["[sh.sid]"] = sh
	for(var/list/s in D["shots"])
		if(!isnull(s["lead"]))
			var/datum/energyfx_blastshot/a = byid["[s["sid"]]"]
			a.lead = byid["[s["lead"]]"]
	if(D["bigs"])
		bigs = list()
		for(var/list/b in D["bigs"])
			var/datum/energyfx_blastshot/bs = byid["[b["sid"]]"]
			var/datum/bfx_rng/replay/G = new(1)
			G.vals = b["draws"]
			var/rs = EFXOE4Set(b["Re"])
			var/dome = BigDome(b["Re"])
			var/datum/energyfx_orbblast3/B = new(G, b["Re"], bs.hit_pt[1], bs.hit_pt[2], bs.t_hit / EFXB_TICK, null, dome, "B3Ground[rs][cols.gray ? "G" : ""]", cols.LM("hl"), EFXO_LM_SCORCH)
			if(findtext(dome, "E4"))
				B.e4 = dome
				B.e4m = EFXOE4Mats(dome, cols.pal)
			B.lm_flash = cols.LM("flash")
			B.fl_kinds = list("XP", "XS", cols.LK("XL"))
			bigs[++bigs.len] = list(bs, B)
	if(D["erupt"])
		var/list/e = D["erupt"]
		erupt = list(byid["[e[1]]"], e[2] + ox, e[3] + oy, e[4])
	if(D["sparks"])
		sparks = list()
		for(var/list/sp in D["sparks"])
			var/list/sp2 = sp.Copy()
			sp2["bx"] = sp["bx"] + ox
			sp2["by"] = sp["by"] + oy
			sparks[++sparks.len] = sp2
	tgt_off = D["tgt_off"]
	cdir_at = D["cdir_at"]
	look.scenes += src
	OL("G replay [D["row"]] [K0]")

/datum/energyfx_blasts/replay

/datum/energyfx_blasts/burst

/datum/energyfx_blasts/burst/proc/StartBurst(turf/T, radius, datum/energyfx_row/R, datum/energyfx_colors/C, datum/energyfx_look/L)
	return 0

proc/EnergyFXSekihaBlast(datum/sekihafx/F, list/draws)
	var/datum/energyfx_row/R = EnergyFXRowOf(/obj/Skills/Projectile/Sekiha_Tenkyoken)
	if(!F || !R || !R.extra || !F.hit_pt) return null
	var/datum/energyfx_blasts/live/S = new
	S.look = energyfx_blast_look
	S.row = R
	S.extra = R.extra
	S.zz = F.zz
	S.K0 = EnergyFXNow() - 2
	S.parity = F.parity ? 1 : (glob && glob.ENERGYFX_ORB_LOG)
	S.SetupColors(null, R)
	S.last_spawn_k = 2
	var/datum/energyfx_blastshot/sh = S.NewShot(2)
	sh.virtual = 1
	sh.big_only = 1
	sh.ground = 1
	sh.t_spawn = S.T(2)
	sh.t_launch = sh.t_spawn
	sh.t_hit = sh.t_spawn
	sh.hit_pt = list(F.hit_pt[1], F.hit_pt[2])
	sh.k_end = 2
	var/datum/bfx_rng/replay/G
	if(draws)
		G = new(1)
		G.vals = draws
	S.BigAt(sh, 16 * EFXB_ROWS["Sekiha_Tenkyoken"]["explode"], G)
	if(S.parity) S.OL("G sekiha live [S.K0]")
	energyfx_blast_look.scenes += S
	return S
