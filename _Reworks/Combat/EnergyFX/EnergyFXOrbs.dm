#define EFXO_GL_PLANE 43
#define EFXO_ML_PLANE 44
#define EFXO_UP_PLANE 45
#define EFXO_UL_PLANE 46
#define EFXO_SM_PLANE 47
#define EFXO_FL_PLANE 48
#define EFXO_XP_PLANE 49
#define EFXO_XS_PLANE 50
#define EFXO_XL_PLANE 51
#define EFXO_YP_PLANE 52
#define EFXO_YL_PLANE 53
#define EFXO_NP_PLANE 54
#define EFXO_ZP_PLANE 55
#define EFXO_ZS_PLANE 56
#define EFXO_ZL_PLANE 57
#define EFXO_WP_PLANE 58
#define EFXO_WL_PLANE 59
#define EFXO_LG_PLANE 72
#define EFXO_GL_RELAY 6.616
#define EFXO_ML_RELAY 6.6335
#define EFXO_UP_RELAY 6.642
#define EFXO_UL_RELAY 6.644
#define EFXO_SM_RELAY 6.646
#define EFXO_FL_RELAY 6.6512
#define EFXO_XP_RELAY 6.654
#define EFXO_XS_RELAY 6.655
#define EFXO_XL_RELAY 6.656
#define EFXO_YP_RELAY 6.657
#define EFXO_YL_RELAY 6.658
#define EFXO_NP_RELAY 6.618
#define EFXO_ZP_RELAY 6.66
#define EFXO_ZS_RELAY 6.661
#define EFXO_ZL_RELAY 6.662
#define EFXO_WP_RELAY 6.663
#define EFXO_WL_RELAY 6.664
#define EFXO_LS 4
#define EFXO_TICK 0.05
#define EFXO_FPS 40

#define EO_KEY 1
#define EO_KIND 2
#define EO_IK 3
#define EO_ST 4
#define EO_X 5
#define EO_Y 6
#define EO_ANG 7
#define EO_SX 8
#define EO_SY 9
#define EO_AL 10
#define EO_COL 11
#define EO_LAY 12
#define EO_PRE 13

/obj/Skills/Projectile/_Projectile/var/tmp/datum/energyfx_orbshot/efx_orb

globalTracker/var/tmp
	ENERGYFX_ORB_LOG = FALSE

var/energyfx_orb_seed = 0
var/list/energyfx_orb_log
var/energyfx_orb_log_tag = ""
var/list/EFXO_ID = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0)

/obj/energyfx/orb
/obj/energyfx/orb/gl
	plane = EFXO_GL_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/ml
	plane = EFXO_ML_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/up
	plane = EFXO_UP_PLANE
/obj/energyfx/orb/ul
	plane = EFXO_UL_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/sm
	plane = EFXO_SM_PLANE
/obj/energyfx/orb/fl
	plane = EFXO_FL_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/xp
	plane = EFXO_XP_PLANE
/obj/energyfx/orb/xs
	plane = EFXO_XS_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/xl
	plane = EFXO_XL_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/yp
	plane = EFXO_YP_PLANE
/obj/energyfx/orb/yl
	plane = EFXO_YL_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/np
	plane = EFXO_NP_PLANE
/obj/energyfx/orb/zp
	plane = EFXO_ZP_PLANE
/obj/energyfx/orb/zs
	plane = EFXO_ZS_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/zl
	plane = EFXO_ZL_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/wp
	plane = EFXO_WP_PLANE
/obj/energyfx/orb/wl
	plane = EFXO_WL_PLANE
	blend_mode = BLEND_ADD

var/list/EFXO_PATHS = list("GP" = /obj/energyfx/gpaint, "GL" = /obj/energyfx/orb/gl, "MP" = /obj/energyfx/paint, "ML" = /obj/energyfx/orb/ml,
	"UP" = /obj/energyfx/orb/up, "UL" = /obj/energyfx/orb/ul, "SM" = /obj/energyfx/orb/sm, "FP" = /obj/energyfx/fpaint, "FS" = /obj/energyfx/fsharp,
	"FL" = /obj/energyfx/orb/fl, "XP" = /obj/energyfx/orb/xp, "XS" = /obj/energyfx/orb/xs, "XL" = /obj/energyfx/orb/xl, "YP" = /obj/energyfx/orb/yp,
	"YL" = /obj/energyfx/orb/yl, "NP" = /obj/energyfx/orb/np, "ZP" = /obj/energyfx/orb/zp, "ZS" = /obj/energyfx/orb/zs, "ZL" = /obj/energyfx/orb/zl,
	"WP" = /obj/energyfx/orb/wp, "WL" = /obj/energyfx/orb/wl, "GLg" = /obj/energyfx/orb/glg, "MLg" = /obj/energyfx/orb/mlg, "ULg" = /obj/energyfx/orb/ulg,
	"FLg" = /obj/energyfx/orb/flg, "XLg" = /obj/energyfx/orb/xlg, "CM" = /obj/energyfx/orb/cm, "CP" = /obj/energyfx/orb/cp,
	"CS" = /obj/energyfx/orb/cs, "CL" = /obj/energyfx/orb/cl, "CLg" = /obj/energyfx/orb/clg, "LP" = /obj/energyfx/orb/lp)

/obj/energyfx_master/orb
/obj/energyfx_master/orb/gl
	plane = EFXO_GL_PLANE
	render_target = "*energyfx_orb_gl"
/obj/energyfx_master/orb/ml
	plane = EFXO_ML_PLANE
	render_target = "*energyfx_orb_ml"
/obj/energyfx_master/orb/up
	plane = EFXO_UP_PLANE
	render_target = "*energyfx_orb_up"
/obj/energyfx_master/orb/ul
	plane = EFXO_UL_PLANE
	render_target = "*energyfx_orb_ul"
/obj/energyfx_master/orb/sm
	plane = EFXO_SM_PLANE
	render_target = "*energyfx_orb_sm"
/obj/energyfx_master/orb/fl
	plane = EFXO_FL_PLANE
	render_target = "*energyfx_orb_fl"
/obj/energyfx_master/orb/xp
	plane = EFXO_XP_PLANE
	render_target = "*energyfx_orb_xp"
/obj/energyfx_master/orb/xs
	plane = EFXO_XS_PLANE
	render_target = "*energyfx_orb_xs"
/obj/energyfx_master/orb/xl
	plane = EFXO_XL_PLANE
	render_target = "*energyfx_orb_xl"
/obj/energyfx_master/orb/yp
	plane = EFXO_YP_PLANE
	render_target = "*energyfx_orb_yp"
/obj/energyfx_master/orb/yl
	plane = EFXO_YL_PLANE
	render_target = "*energyfx_orb_yl"
/obj/energyfx_master/orb/np
	plane = EFXO_NP_PLANE
	render_target = "*energyfx_orb_np"
/obj/energyfx_master/orb/zp
	plane = EFXO_ZP_PLANE
	render_target = "*energyfx_orb_zp"
/obj/energyfx_master/orb/zs
	plane = EFXO_ZS_PLANE
	render_target = "*energyfx_orb_zs"
/obj/energyfx_master/orb/zl
	plane = EFXO_ZL_PLANE
	render_target = "*energyfx_orb_zl"
/obj/energyfx_master/orb/wp
	plane = EFXO_WP_PLANE
	render_target = "*energyfx_orb_wp"
/obj/energyfx_master/orb/wl
	plane = EFXO_WL_PLANE
	render_target = "*energyfx_orb_wl"
/obj/energyfx_master/orb/lg
	plane = EFXO_LG_PLANE
	render_target = "*energyfx_orb_lg"

/obj/energyfx_master/orb/New()
	..()
	if(plane in list(EFXO_GL_PLANE, EFXO_ML_PLANE, EFXO_UL_PLANE, EFXO_FL_PLANE, EFXO_XL_PLANE, EFXO_YL_PLANE, EFXO_ZL_PLANE, EFXO_WL_PLANE))
		filters = filter(type = "blur", size = glob ? glob.ENERGYFX_BLUR : 1.5)

/obj/energyfx_relay/orb
/obj/energyfx_relay/orb/gl
	layer = EFXO_GL_RELAY
	render_source = "*energyfx_orb_gl"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/ml
	layer = EFXO_ML_RELAY
	render_source = "*energyfx_orb_ml"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/up
	layer = EFXO_UP_RELAY
	render_source = "*energyfx_orb_up"
/obj/energyfx_relay/orb/ul
	layer = EFXO_UL_RELAY
	render_source = "*energyfx_orb_ul"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/sm
	layer = EFXO_SM_RELAY
	render_source = "*energyfx_orb_sm"
/obj/energyfx_relay/orb/fl
	layer = EFXO_FL_RELAY
	render_source = "*energyfx_orb_fl"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/xp
	layer = EFXO_XP_RELAY
	render_source = "*energyfx_orb_xp"
/obj/energyfx_relay/orb/xs
	layer = EFXO_XS_RELAY
	render_source = "*energyfx_orb_xs"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/xl
	layer = EFXO_XL_RELAY
	render_source = "*energyfx_orb_xl"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/yp
	layer = EFXO_YP_RELAY
	render_source = "*energyfx_orb_yp"
/obj/energyfx_relay/orb/yl
	layer = EFXO_YL_RELAY
	render_source = "*energyfx_orb_yl"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/np
	layer = EFXO_NP_RELAY
	render_source = "*energyfx_orb_np"
/obj/energyfx_relay/orb/zp
	layer = EFXO_ZP_RELAY
	render_source = "*energyfx_orb_zp"
/obj/energyfx_relay/orb/zs
	layer = EFXO_ZS_RELAY
	render_source = "*energyfx_orb_zs"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/zl
	layer = EFXO_ZL_RELAY
	render_source = "*energyfx_orb_zl"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/wp
	layer = EFXO_WP_RELAY
	render_source = "*energyfx_orb_wp"
/obj/energyfx_relay/orb/wl
	layer = EFXO_WL_RELAY
	render_source = "*energyfx_orb_wl"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/lg
	layer = 6.6
	render_source = "*energyfx_orb_lg"
	blend_mode = BLEND_ADD

/obj/energyfx_relay/orb/lg/New()
	..()
	plane = EFXOBasePlane()

/obj/energyfx_relay/orb/New()
	..()
	if(layer in list(EFXO_GL_RELAY, EFXO_ML_RELAY, EFXO_UL_RELAY, EFXO_FL_RELAY, EFXO_XL_RELAY, EFXO_YL_RELAY, EFXO_ZL_RELAY, EFXO_WL_RELAY))
		color = list(EFXO_LS, 0, 0, 0, EFXO_LS, 0, 0, 0, EFXO_LS)
	if(layer == EFXO_GL_RELAY || layer == EFXO_ML_RELAY)
		filters = filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE)
	if(layer == EFXO_NP_RELAY)
		filters = filter(type = "alpha", render_source = "*energyfx_occ", flags = MASK_INVERSE)

client/var/tmp/list/energyfx_orb_screen

proc/EnergyFXOrbMasters(client/C)
	if(!C) return
	if(!C.energyfx_orb_screen)
		C.energyfx_orb_screen = list()
		for(var/p in typesof(/obj/energyfx_master/orb) - /obj/energyfx_master/orb)
			C.energyfx_orb_screen += new p
		for(var/p in typesof(/obj/energyfx_relay/orb) - /obj/energyfx_relay/orb)
			C.energyfx_orb_screen += new p
		for(var/p in typesof(/obj/energyfx_master/orbgray) - /obj/energyfx_master/orbgray)
			C.energyfx_orb_screen += new p
		for(var/p in typesof(/obj/energyfx_relay/orbgray) - /obj/energyfx_relay/orbgray)
			C.energyfx_orb_screen += new p
	for(var/obj/O in C.energyfx_orb_screen)
		if(!(O in C.screen)) C.screen += O

client/ApplyWorldMag()
	..()
	EnergyFXOrbMasters(src)

/datum/bfx_rng/orb
	var/key
	var/list/log

/datum/bfx_rng/orb/R()
	. = ..()
	if(log) log += .

proc/EnergyFXOrbN(v)
	return num2text(v, 12)

proc/EnergyFXOrbLog(line)
	if(!energyfx_orb_log) return
	energyfx_orb_log += line

var/datum/energyfx_orbs/efxo_log_cur
var/efxo_scene_n = 0
/datum/energyfx_orbs/var/sid = 0

/datum/energyfx_orbs/proc/OL(line)
	if(!energyfx_orb_log) return
	if(efxo_log_cur != src)
		efxo_log_cur = src
		if(!sid) sid = ++efxo_scene_n
		energyfx_orb_log += "Z [sid]"
	energyfx_orb_log += line

proc/EFXOEaseOut(q)
	q = clamp(q, 0, 1)
	return 1 - (1 - q) * (1 - q)

proc/EFXOSstep(e0, e1, x)
	var/t = clamp((x - e0) / (e1 - e0), 0, 1)
	return t * t * (3 - 2 * t)

proc/EFXOAtan2(y, x)
	if(!x && !y) return 0
	return arctan(x, y)

proc/EFXOHyp(x, y)
	return sqrt(x * x + y * y)

proc/EFXOExp(x)
	return 2.718281828 ** x

proc/EFXOBit(list/L, i)
	var/w = floor(i / 24) + 1
	if(i < 0 || w > L.len) return 0
	return (L[w] >> (i % 24)) & 1

proc/EFXOBit2(list/L, row, col, cols)
	return EFXOBit(L, row * cols + col)

/datum/energyfx_look/orbs
	var/list/scenes = list()

/datum/energyfx_look/orbs/Owns(obj/Skills/Projectile/_Projectile/P)
	return P && P.efx_orb && !P.efx_orb.dropped

/datum/energyfx_look/orbs/Spawn(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_row/R = EnergyFXRowOf(P.SkillPath)
	if(!R || !R.extra || !P.loc) return 0
	var/datum/energyfx_orbs/S = JoinScene(P, R)
	if(!S)
		var/path = text2path("/datum/energyfx_orbs/[R.extra["kind"]]")
		if(!path) return 0
		S = new path
		S.Init(P, R, src)
		scenes += S
	var/datum/energyfx_orbshot/O = S.AddShot(P, R)
	if(!O) return 0
	P.efx_orb = O
	S.Loop()
	return 1

/datum/energyfx_look/orbs/proc/JoinScene(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	for(var/datum/energyfx_orbs/S in scenes)
		if(!S.done && S.Accepts(P, R)) return S
	return null

/datum/energyfx_look/orbs/Charge(obj/Skills/Projectile/_Projectile/P, T)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(O) O.S.OnCharge(O, T)
	return 0

/datum/energyfx_look/orbs/Launch(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(O) O.S.OnLaunch(O)
	return 0

/datum/energyfx_look/orbs/Hit(obj/Skills/Projectile/_Projectile/P, atom/target)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(O) O.S.OnHit(O, target)
	return 0

/datum/energyfx_look/orbs/Fuse(obj/Skills/Projectile/_Projectile/P, atom/target)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(O) O.S.OnFuse(O, target)
	return 0

/datum/energyfx_look/orbs/Clash(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/_Projectile/other)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(O) O.S.OnClash(O, other)
	return 0

/datum/energyfx_look/orbs/CounterDied(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/_Projectile/counter)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(O) return O.S.OnCounterDied(O, counter)
	return 0

/datum/energyfx_look/orbs/Tick(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(O) O.S.OnTick(O)
	return 0

/datum/energyfx_look/orbs/Finish(obj/Skills/Projectile/_Projectile/P)
	var/datum/energyfx_orbshot/O = P.efx_orb
	if(!O) return 0
	return O.S.OnFinish(O)

var/datum/energyfx_look/orbs/energyfx_orb_look = new

/datum/energyfx_orbshot
	var/obj/Skills/Projectile/_Projectile/P
	var/datum/energyfx_orbs/S
	var/idx = 0
	var/k_spawn
	var/k_charge
	var/T_charge = 0
	var/k_launch
	var/k_fuse
	var/k_end
	var/end_lost = 0
	var/dropped = 0
	var/list/hits = list()
	var/list/pk = list()
	var/list/dp = list()
	var/heading = 0
	var/zz = 1
	var/list/vars_ = list()

/datum/energyfx_orbshot/proc/Center()
	if(!P || !P.loc) return null
	if(P.KickPath && !isnull(P.kick_px)) return list(P.kick_px, P.kick_py)
	return list((P.x - 1) * 32 + P.step_x + 16 + P.vhb_ax, (P.y - 1) * 32 + P.step_y + 16 + P.vhb_ay)

/datum/energyfx_orbshot/proc/SetP(k, list/c)
	if(k < 0 || !c) return
	if(pk.len < k + 1) pk.len = k + 1
	var/list/old = pk[k + 1]
	pk[k + 1] = c
	if(old && old[1] == c[1] && old[2] == c[2]) return
	if(dp.len > 2 * k) dp.len = 2 * k

/datum/energyfx_orbshot/proc/GetP(k)
	if(k < 0) k = 0
	for(var/i = min(k + 1, pk.len), i >= 1, i--)
		if(pk[i]) return pk[i]
	return null

/datum/energyfx_orbshot/proc/HasP(k)
	return k >= 0 && k + 1 <= pk.len && pk[k + 1]

/datum/energyfx_orbshot/proc/PredP(k)
	if(HasP(k)) return pk[k + 1]
	var/list/a = GetP(k - 1)
	if(!a) return null
	var/list/b = HasP(k - 2) ? pk[k - 1] : null
	if(!b || (!isnull(k_end) && k > k_end)) return a
	return list(a[1] + (a[1] - b[1]), a[2] + (a[2] - b[2]))

/datum/energyfx_orbshot/proc/DrawnAt(f)
	if(f < 0) f = 0
	if(f + 1 <= dp.len && dp[f + 1]) return dp[f + 1]
	var/k = floor(f / 2)
	var/list/p0 = GetP(k)
	if(!p0) return null
	var/list/out
	if(f % 2 == 0)
		var/list/pm = HasP(k - 1) ? pk[k] : p0
		var/list/pn = PredP(k + 1)
		if(!pn) pn = p0
		out = list((pm[1] + 6 * p0[1] + pn[1]) / 8, (pm[2] + 6 * p0[2] + pn[2]) / 8)
	else
		var/list/pn2 = PredP(k + 1)
		if(!pn2) pn2 = p0
		out = list((p0[1] + pn2[1]) / 2, (p0[2] + pn2[2]) / 2)
	if(dp.len < f + 1) dp.len = f + 1
	dp[f + 1] = out
	if(S && S.parity) S.OL("D [idx] [f] [EnergyFXOrbN(out[1])] [EnergyFXOrbN(out[2])]")
	return out

/datum/energyfx_orbshot/proc/DrawnT(t)
	var/ff = t * EFXO_FPS
	var/f0 = floor(ff)
	var/u = ff - f0
	var/list/a = DrawnAt(f0)
	if(!a) return null
	if(u < 0.000001) return a
	var/list/b = DrawnAt(f0 + 1)
	if(!b) return a
	return list(a[1] + (b[1] - a[1]) * u, a[2] + (b[2] - a[2]) * u)

/datum/energyfx_orbs
	var/datum/energyfx_look/orbs/look
	var/datum/energyfx_row/row
	var/list/extra
	var/list/shots = list()
	var/K0 = 0
	var/zz = 1
	var/mob/caster
	var/obj/Skills/from
	var/list/objs = list()
	var/done = 0
	var/looping = 0
	var/idle = 0
	var/last_k = -1000
	var/k_done = -1
	var/list/streams = list()
	var/list/chars = list()
	var/parity = 0
	var/max_life = 1200

/datum/energyfx_orbs/proc/Init(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R, datum/energyfx_look/orbs/L)
	look = L
	row = R
	extra = R.extra
	caster = P.Owner
	from = P.from_skill
	zz = P.z
	K0 = EnergyFXNow() - 2
	parity = glob && glob.ENERGYFX_ORB_LOG
	if(parity) OL("G [energyfx_orb_log_tag] [R.extra["kind"]] [K0]")

/datum/energyfx_orbs/proc/Accepts(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	return 0

/datum/energyfx_orbs/proc/Now()
	return EnergyFXNow() - K0

/datum/energyfx_orbs/proc/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = new
	O.P = P
	O.S = src
	O.idx = shots.len
	O.zz = P.z
	O.k_spawn = Now()
	O.SetP(O.k_spawn, O.Center())
	shots += O
	if(parity) OL("E [O.idx] spawn [O.k_spawn]")
	return O

/datum/energyfx_orbs/proc/Stream(key)
	var/datum/bfx_rng/orb/G = streams[key]
	if(!G)
		energyfx_orb_seed++
		G = new(energyfx_orb_seed * 7919 + 13)
		G.key = key
		if(parity) G.log = list()
		streams[key] = G
	return G

/datum/energyfx_orbs/proc/OnCharge(datum/energyfx_orbshot/O, T)
	O.k_charge = Now()
	O.T_charge = T
	if(parity) OL("E [O.idx] charge [O.k_charge] [EnergyFXOrbN(T)]")

/datum/energyfx_orbs/proc/OnLaunch(datum/energyfx_orbshot/O)
	O.k_launch = Now()
	O.SetP(O.k_launch, O.Center())
	if(parity) OL("E [O.idx] launch [O.k_launch]")

/datum/energyfx_orbs/proc/OnHit(datum/energyfx_orbshot/O, atom/target)
	var/k = Now()
	O.SetP(k, O.Center())
	O.hits += list(list(k, target))
	if(parity) OL("E [O.idx] hit [k] [target ? "[target.type]" : "-"]")
	if(last_k == k && !done)
		HitNow(O, k)
		DrawTick(k)

/datum/energyfx_orbs/proc/HitNow(datum/energyfx_orbshot/O, k)

/datum/energyfx_orbs/proc/OnFuse(datum/energyfx_orbshot/O, atom/target)
	O.k_fuse = Now()
	if(parity) OL("E [O.idx] fuse [O.k_fuse]")

/datum/energyfx_orbs/proc/OnClash(datum/energyfx_orbshot/O, obj/Skills/Projectile/_Projectile/other)
	if(parity) OL("E [O.idx] clash [Now()]")

/datum/energyfx_orbs/proc/OnTick(datum/energyfx_orbshot/O)
	var/k = Now()
	var/list/c = O.Center()
	if(!c) return
	var/list/old = O.HasP(k) ? O.pk[k + 1] : null
	if(old && old[1] == c[1] && old[2] == c[2]) return
	O.SetP(k, c)
	if(parity) OL("P [O.idx] [k] [EnergyFXOrbN(c[1])] [EnergyFXOrbN(c[2])]")
	if(last_k == k) DrawTick(k)

/datum/energyfx_orbs/proc/OnCounterDied(datum/energyfx_orbshot/O, obj/Skills/Projectile/_Projectile/counter)
	return 0

/datum/energyfx_orbs/proc/OnFinish(datum/energyfx_orbshot/O)
	if(!isnull(O.k_end)) return 1
	O.k_end = Now()
	O.SetP(O.k_end, O.Center())
	O.end_lost = !O.P || O.P.Killed
	if(parity) OL("E [O.idx] finish [O.k_end] [O.end_lost]")
	return 1

/datum/energyfx_orbs/proc/Sample(k)
	for(var/datum/energyfx_orbshot/O in shots)
		if(O.dropped || !isnull(O.k_end)) continue
		if(!O.P || !O.P.loc || O.P.efx_orb != O)
			O.k_end = k
			O.end_lost = 1
			if(parity) OL("E [O.idx] lost [k]")
			continue
		var/list/c = O.Center()
		O.SetP(k, c)
		if(parity) OL("P [O.idx] [k] [EnergyFXOrbN(c[1])] [EnergyFXOrbN(c[2])]")

/datum/energyfx_orbs/proc/Q(fi)
	return fi - (fi % 2)

/datum/energyfx_orbs/proc/PredictHyper(datum/energyfx_orbshot/O, k)
	var/obj/Skills/Projectile/_Projectile/P = O.P
	if(!P || !P.loc || isnull(O.k_launch) || !isnull(O.k_end) || !P.HyperHoming || !ismob(P.Homing)) return 0
	var/kc = k + 2
	var/ns = max(1, P.pm_substep)
	if(BeamFXMod(kc - O.k_launch, ns)) return 0
	var/list/a = O.GetP(k)
	var/list/b = O.HasP(k - 1) ? O.pk[k] : a
	if(!a || !b) return 0
	var/px = a[1] + 2 * (a[1] - b[1]) - P.vhb_ax
	var/py = a[2] + 2 * (a[2] - b[2]) - P.vhb_ay
	var/mob/T = P.Homing
	if(T.proj_immune_until > world.time + 2 * world.tick_lag || T.Airborne) return 0
	var/tx = floor(px / 32) + 1
	var/ty = floor(py / 32) + 1
	var/r = max(1, P.Radius)
	return abs(T.x - tx) <= r && abs(T.y - ty) <= r

/datum/energyfx_orbs/proc/Predicted(datum/energyfx_orbshot/O, k)
	var/list/pr = O.vars_["pred"]
	if(!pr)
		pr = list()
		O.vars_["pred"] = pr
	var/key = "[k + 2]"
	if(!(key in pr) && PredictHyper(O, k))
		pr += key
		if(parity) OL("E [O.idx] predict [k + 2]")
	var/list/keep = list()
	for(var/kk in pr)
		var/kc = text2num(kk)
		var/hit = 0
		for(var/list/e in O.hits)
			if(e[1] == kc) hit = 1
		if(hit || kc >= k || !isnull(O.k_end) && O.k_end == kc) keep += kk
	O.vars_["pred"] = keep

/datum/energyfx_orbs/proc/TickWork(k)

/datum/energyfx_orbs/proc/Draw(fi, v)
	return list()

/datum/energyfx_orbs/proc/Chars(k)

/datum/energyfx_orbs/proc/Busy(k)
	return 0

/datum/energyfx_orbs/proc/Rec(list/out, key, kind, ik, st, x, y, ang, sx, sy, al, list/col, lay, pre = 0)
	out[++out.len] = list(key, kind, ik, st, x, y, ang, sx, sy, al, col, lay, pre)

/datum/energyfx_orbs/proc/Xform(obj/energyfx/O, list/s)
	var/a = s[EO_ANG]
	var/p = s[EO_PRE]
	if(!a && !p) return matrix(s[EO_SX], 0, s[EO_X] - O.fx_bx, 0, s[EO_SY], s[EO_Y] - O.fx_by)
	var/ca = cos(a)
	var/sa = sin(a)
	var/cp = cos(p)
	var/spp = sin(p)
	var/sx = s[EO_SX]
	var/sy = s[EO_SY]
	return matrix(ca * sx * cp - sa * sy * spp, -ca * sx * spp - sa * sy * cp, s[EO_X] - O.fx_bx, sa * sx * cp + ca * sy * spp, -sa * sx * spp + ca * sy * cp, s[EO_Y] - O.fx_by)

/datum/energyfx_orbs/proc/Apply(k, list/D0, list/D1)
	var/list/m0 = list()
	var/list/m1 = list()
	var/list/keys = list()
	for(var/list/s in D0)
		m0[s[EO_KEY]] = s
		keys[s[EO_KEY]] = 1
	for(var/list/s in D1)
		m1[s[EO_KEY]] = s
		keys[s[EO_KEY]] = 1
	var/list/gone = list()
	for(var/key in objs)
		if(!keys[key]) gone += key
	for(var/key in gone)
		EFXOFree(objs[key])
		objs -= key
	for(var/key in keys)
		var/list/s0 = m0[key]
		var/list/s1 = m1[key]
		var/list/sp = s0 ? s0 : s1
		var/list/ic = EFXOIcon(sp)
		if(!ic) continue
		var/obj/energyfx/O = objs[key]
		if(!O)
			O = EnergyFXGet(EFXO_PATHS[sp[EO_KIND]], row ? row.path : "orb")
			if(!O) continue
			O.icon = ic[1]
			O.fx_w = ic[2]
			O.fx_h = ic[3]
			O.alpha = 0
			O.efxo_kf = null
			EFXOUntwin(O)
			var/tw = EFXO_TWINS[sp[EO_IK]]
			if(tw)
				var/list/tic = ENERGYFX_ORB_ICONS[tw]
				if(tic)
					O.efx_damp = new /obj/energyfx_twin/orbdamp
					O.efx_damp.icon = tic[1]
					O.vis_contents += O.efx_damp
			var/ftw = EFXO_FTWINS[sp[EO_IK]]
			if(ftw)
				var/list/fic = ENERGYFX_ORB_ICONS[ftw]
				if(fic)
					O.efx_damp = new /obj/energyfx_twin/orbfdamp
					O.efx_damp.icon = fic[1]
					O.vis_contents += O.efx_damp
				O.efxo_cov = new /obj/energyfx_twin/orbfcov
				O.efxo_cov.icon = ic[1]
				O.vis_contents += O.efxo_cov
			objs[key] = O
		if(!O.loc || abs(sp[EO_X] - O.fx_bx) > 48 || abs(sp[EO_Y] - O.fx_by) > 48)
			if(!EnergyFXPlace(O, sp[EO_X], sp[EO_Y], zz))
				EFXOFree(O)
				objs -= key
				continue
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
		if(parity)
			if(s0) LogRec(2 * k, O, s0, list(t0, al0, c0, st0, f0))
			if(s1) LogRec(2 * k + 1, O, s1, list(t1, al1, c1, st1, f1))
		animate(O, transform = t0, alpha = al0, color = c0, icon = f0, icon_state = st0, time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		energyfx_anim_n++
		if(al0 != al1 || st0 != st1 || c0 != c1 || f0 != f1 || (t1 != t0 && (t0.a != t1.a || t0.b != t1.b || t0.c != t1.c || t0.d != t1.d || t0.e != t1.e || t0.f != t1.f)))
			animate(transform = t1, alpha = al1, color = c1, icon = f1, icon_state = st1, time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			energyfx_anim_n++

proc/EFXOIcon(list/s)
	var/list/ic = ENERGYFX_ORB_ICONS[s[EO_IK]]
	if(!ic) ic = ENERGYFX_ORB_ICONS["[s[EO_IK]]:[s[EO_ST]]"]
	return ic

/obj/energyfx_orbkeep
	alpha = 0
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/datum/energyfx_orbs/var/obj/energyfx_orbkeep/keeper
/datum/energyfx_orbs/var/list/kept
/datum/energyfx_orbs/var/list/pre_q
/datum/energyfx_orbs/var/pre_i = 0

/datum/energyfx_orbs/proc/PreloadTick()
	if(!keeper || !keeper.loc) return
	var/b = EFXO_PRELOAD_PX
	while(pre_i < pre_q.len)
		var/list/e = pre_q[pre_i + 1]
		if(e[3] > b && b < EFXO_PRELOAD_PX) break
		b -= e[3]
		pre_i++
		Keep(e[1], e[2], null)
	if(pre_i >= pre_q.len) pre_q = null

/datum/energyfx_orbs/proc/Keep(f, st, obj/energyfx/O)
	if(!kept) kept = list()
	var/kk = "[f]"
	if(!kept[kk])
		kept[kk] = 1
		if(!keeper) keeper = new
		keeper.overlays += image(f, icon_state = st)
	if(keeper && O && O.loc && (!keeper.loc || keeper.z != O.z || abs(keeper.x - O.x) > 4 || abs(keeper.y - O.y) > 4)) keeper.loc = O.loc

/datum/energyfx_orbs/proc/LogRec(fi, obj/energyfx/O, list/s, list/a)
	var/matrix/m = a[1]
	var/list/c = a[3]
	var/cs = ""
	for(var/v in c)
		cs += "[cs == "" ? "" : ","][EnergyFXOrbN(v)]"
	OL("S [fi] [s[EO_KEY]] [s[EO_KIND]] [s[EO_IK]] [s[EO_ST]] [EnergyFXOrbN(s[EO_X])] [EnergyFXOrbN(s[EO_Y])] [EnergyFXOrbN(s[EO_ANG])] [EnergyFXOrbN(s[EO_SX])] [EnergyFXOrbN(s[EO_SY])] [EnergyFXOrbN(s[EO_PRE])] [EnergyFXOrbN(s[EO_AL])] [a[2]] [EnergyFXOrbN(s[EO_LAY])] [O.x] [O.y] [O.fx_w] [O.fx_h] [EnergyFXOrbN(m.a)] [EnergyFXOrbN(m.b)] [EnergyFXOrbN(m.c)] [EnergyFXOrbN(m.d)] [EnergyFXOrbN(m.e)] [EnergyFXOrbN(m.f)] [cs]")

/datum/energyfx_orbs/proc/DrawTick(k)
	if(done || k < last_k) return
	last_k = k
	while(k_done < k)
		k_done++
		TickWork(k_done)
	var/v0 = Q(2 * k)
	var/v1 = Q(2 * k + 1)
	var/list/D0 = Draw(2 * k, v0)
	var/list/D1 = Draw(2 * k + 1, v1)
	AddGlows(D0, v0)
	AddGlows(D1, v1)
	if(parity)
		OL("Q [2 * k] [v0]")
		OL("Q [2 * k + 1] [v1]")
	Apply(k, D0, D1)
	if(pre_q) PreloadTick()
	Chars(k)
	idle = (D0.len || D1.len || Busy(k)) ? 0 : idle + 1

/datum/energyfx_orbs/proc/AllEnded()
	for(var/datum/energyfx_orbshot/O in shots)
		if(isnull(O.k_end)) return 0
	return 1

/datum/energyfx_orbs/proc/Loop()
	set waitfor = 0
	if(looping) return
	looping = 1
	sleep(0)
	var/k = Now()
	Sample(k)
	DrawTick(k)
	while(!done)
		sleep(world.tick_lag)
		sleep(0)
		if(done) break
		k = Now()
		Sample(k)
		DrawTick(k)
		if((AllEnded() && idle >= 2) || k > max_life)
			Cleanup()
			break
	looping = 0

/datum/energyfx_orbs/proc/Cleanup()
	if(done) return
	done = 1
	if(keeper)
		keeper.overlays = null
		keeper.loc = null
		keeper = null
	kept = null
	for(var/key in objs)
		EFXOFree(objs[key])
	objs = list()
	for(var/m in chars)
		var/datum/bfx_char/C = chars[m]
		if(C) C.Drop()
	chars = list()
	for(var/datum/energyfx_orbshot/O in shots)
		O.dropped = 1
		if(O.P && O.P.efx_orb == O) O.P.efx_orb = null
		O.P = null
	if(parity)
		for(var/key in streams)
			var/datum/bfx_rng/orb/G = streams[key]
			var/line = "R [key]"
			for(var/v in G.log)
				line += " [EnergyFXOrbN(v)]"
			OL(line)
		OL("X [energyfx_orb_log_tag]")
	if(look) look.scenes -= src
	caster = null
	from = null

/datum/bfx_char/proc/OrbRefresh(dt, fkey2, list/tl, occl)
	if(M.appearance == app && fkey2 == fkey) return
	app = M.appearance
	fkey = fkey2
	var/apart = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	Copy(sil, 0, FLOAT_LAYER, apart)
	sil.render_target = "*[id]"
	if(occl)
		Copy(occ, ENERGYFX_OCC_PLANE, 1, apart)
		Copy(locc, ENERGYFX_LOCC_PLANE, 1, apart)
	else
		occ.alpha = 0
		locc.alpha = 0
		occ.plane = FLOAT_PLANE
		locc.plane = FLOAT_PLANE
	occ.filters = null
	locc.filters = null
	if(dark)
		Copy(dark, FLOAT_PLANE, FLOAT_LAYER, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
		dark.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		dark.alpha = 0
	var/list/dv = BeamFXDirVec(dt)
	BeamFXRimBuild(M, "*[id]", dv[1], dv[2], tl, 1.45, 0.35, rims.len / 2, null, rims)

proc/EnergyFXOrbAnimAlpha(list/L, a0, a1)
	for(var/obj/O in L)
		animate(O, alpha = a0, time = 0.25, easing = JUMP_EASING | EASE_IN)
		if(a1 != a0) animate(alpha = a1, time = 0.25, easing = JUMP_EASING | EASE_IN)

/datum/energyfx_orbs/proc/CharFX(mob/T, dt, list/tl, dk0, dk1, rm0, rm1, occl)
	if(!T || !T.loc || T.z != zz)
		var/datum/bfx_char/C0 = chars[T]
		if(C0)
			C0.Drop()
			chars -= T
		return
	var/datum/bfx_char/C = chars[T]
	if(!C)
		C = new(T, 2)
		chars[T] = C
	C.OrbRefresh(dt, "[dt]|[occl]", tl, occl)
	EnergyFXOrbAnimAlpha(C.rims, round(clamp(rm0 / 1.45, 0, 1) * 255, 1), round(clamp(rm1 / 1.45, 0, 1) * 255, 1))
	if(C.dark) EnergyFXOrbAnimAlpha(list(C.dark), round(clamp(dk0, 0, 1) * 255, 1), round(clamp(dk1, 0, 1) * 255, 1))
	if(parity) OL("C [last_k] [T.x] [T.y] [dt] [EnergyFXOrbN(dk0)] [EnergyFXOrbN(dk1)] [EnergyFXOrbN(rm0)] [EnergyFXOrbN(rm1)] [occl]")

/datum/energyfx_orbs/proc/CharDrop(mob/T)
	var/datum/bfx_char/C = chars[T]
	if(C)
		C.Drop()
		chars -= T

/world/New()
	if(!energyfx_burst_look) energyfx_burst_look = energyfx_orb_look
	. = ..()

proc/EFXOTvLt(v, k)
	if(v != 2 * k) return v < 2 * k
	return EFXOBit(EFXO_LT, k)

proc/EFXOTvGe(v, k)
	return !EFXOTvLt(v, k)

proc/EFXOAfter1(k0, k)
	if(k != k0 + 1) return k > k0 + 1
	return !EFXOBit(EFXO_ADD1, k0)

proc/EFXORoundHalfEven(x)
	var/f = floor(x)
	var/d = x - f
	if(d > 0.5) return f + 1
	if(d < 0.5) return f
	return (f % 2) ? f + 1 : f

proc/EFXOWakeFrame(list/tbl, life40, n, k, v)
	var/o = v - 2 * k
	if(o < 0) return -1
	var/ex = (o >= life40) ? -1 : floor(o * n / life40)
	var/i = k * EFXO_WAKE_O + o
	if(o < EFXO_WAKE_O && k < EFXO_TBL_K && EFXOBit(tbl, i))
		if(ex < 0) return n - 1
		ex -= 1
	return ex

/datum/energyfx_orbs/proc/Heading(datum/energyfx_orbshot/O, f)
	var/list/a = O.DrawnAt(max(0, f - 1))
	var/list/b = O.DrawnAt(f)
	if(!a || !b || (a[1] == b[1] && a[2] == b[2])) return O.heading
	O.heading = EFXOAtan2(b[2] - a[2], b[1] - a[1])
	return O.heading

proc/EFXODir8(ang)
	var/a = ang - 360 * floor(ang / 360)
	var/i = round(a / 45, 1) % 8
	return list("E", "NE", "N", "NW", "W", "SW", "S", "SE")[i + 1]

/datum/energyfx_orbwake
	var/list/col_body
	var/list/segs = list()
	var/dist = 0
	var/L = 16
	var/N = 6
	var/n = 6
	var/life40 = 10
	var/ik
	var/list/tbl

/datum/energyfx_orbwake/proc/Spawn(k, x, y, ang, step)
	dist += step
	var/ph = EFXORoundHalfEven(dist / L) % N
	segs[++segs.len] = list(k, x - cos(ang) * L, y - sin(ang) * L, ang, ph)

/datum/energyfx_orbwake/var/list/kc
/datum/energyfx_orbwake/var/kpre
/datum/energyfx_orbwake/var/list/stc

/datum/energyfx_orbwake/proc/Sprites(datum/energyfx_orbs/S, list/out, v, pre, kp, kl, list/lm, lay)
	if(!kc || kpre != pre)
		kc = list()
		kpre = pre
	while(kc.len < segs.len * 2)
		var/ki = round(kc.len / 2) + 1
		kc[++kc.len] = "[pre][ki]p"
		kc[++kc.len] = "[pre][ki]l"
	if(!stc) stc = list()
	for(var/i = 1 to segs.len)
		var/list/g = segs[i]
		var/fi = EFXOWakeFrame(tbl, life40, n, g[1], v)
		if(fi < 0) continue
		while(stc.len < g[5] + 1)
			stc[++stc.len] = list()
		var/list/sp = stc[g[5] + 1]
		while(sp.len < 2 * (fi + 1))
			var/fj = round(sp.len / 2)
			sp[++sp.len] = "[g[5]]_[fj]_0"
			sp[++sp.len] = "[g[5]]_[fj]_1"
		S.Rec(out, kc[2 * i - 1], kp, ik, sp[2 * fi + 1], g[2], g[3], g[4], 1, 1, 1, col_body, lay)
		S.Rec(out, kc[2 * i], kl, ik, sp[2 * fi + 2], g[2], g[3], g[4], 1, 1, 1, lm, 0)

/datum/energyfx_orbwake/proc/Alive(v)
	for(var/list/g in segs)
		var/o = v - 2 * g[1]
		if(o >= 0 && o <= life40) return 1
	return 0

/datum/energyfx_orbsparkles
	var/list/parts = list()
	var/ik
	var/sc_lo = 0.32
	var/sc_hi = 0.7

/datum/energyfx_orbsparkles/proc/Burst(datum/bfx_rng/G, t0, x, y, n, r0 = 6)
	for(var/i = 1 to n)
		var/a = G.U(0, 6.283185307)
		var/sp = G.U(55, 175)
		var/tj = G.U(0, 0.04)
		var/rx = G.R()
		var/ry = G.R()
		var/ad = a * 57.29577951
		var/life = G.U(0.25, 0.55)
		var/sc = G.U(sc_lo, sc_hi)
		var/spin = G.U(-420, 420)
		var/rot = G.U(0, 360)
		var/cell = G.RandRange(16)
		var/dx = G.U(-30, 30)
		var/dy = G.U(-30, 30)
		var/tw = G.U(9, 16)
		parts[++parts.len] = list(t0 + tj, x + cos(ad) * r0 * rx, y + sin(ad) * r0 * ry, cos(ad) * sp, sin(ad) * sp, life, sc, spin, rot, cell, dx, dy, tw, "[cell]")

/datum/energyfx_orbsparkles/var/list/kc
/datum/energyfx_orbsparkles/var/kpre

/datum/energyfx_orbsparkles/proc/Sprites(datum/energyfx_orbs/S, list/out, t, pre, kind, list/lm)
	if(!kc || kpre != pre)
		kc = list()
		kpre = pre
	while(kc.len < parts.len)
		var/kn = kc.len + 1
		kc += "[pre][kn]"
	for(var/i = 1 to parts.len)
		var/list/p = parts[i]
		var/age = t - p[1]
		if(age < 0 || age >= p[6]) continue
		var/q = age / p[6]
		var/kk = age * (1 - 0.75 * min(1, age / p[6]))
		var/x = p[2] + p[4] * kk + 0.5 * p[11] * age * age
		var/y = p[3] + p[5] * kk + 0.5 * p[12] * age * age
		var/tw = 0.75 + 0.25 * sin((6.283185307 * p[13] * age + p[10]) * 57.29577951)
		var/al = min(1, age / 0.03) * (1 - EFXOSstep(0.55, 1, q)) * tw
		var/sc = p[7] * (1 - 0.4 * q)
		S.Rec(out, kc[i], kind, ik, p[14], x, y, p[9] + p[8] * age, sc, sc, al, lm, 0)

/datum/energyfx_orbsparkles/proc/Alive(t)
	for(var/list/p in parts)
		var/age = t - p[1]
		if(age < p[6]) return 1
	return 0

/datum/energyfx_orbsunburst
	var/list/items = list()
	var/x
	var/y
	var/ox = 0
	var/ik

/datum/energyfx_orbsunburst/New(datum/bfx_rng/G, xx, yy, Re, rays_ox, rays_ik)
	x = xx
	y = yy
	ox = rays_ox
	ik = rays_ik
	var/n = G.RandInt(9, 12)
	var/base = G.U(0, 360)
	for(var/i = 0 to n - 1)
		var/a = base + i * 360 / n + G.U(-11, 11)
		var/lng = (i % 2 == 0)
		var/ln = lng ? G.U(0.8, 1.05) : G.U(0.42, 0.62)
		var/wd = G.U(0.9, 1.3) * (lng ? 1 : 0.8)
		var/vv = G.RandRange(4)
		var/spin = G.U(-10, 10)
		items[++items.len] = list(a, ln * Re / 16, wd, vv, spin)

/datum/energyfx_orbsunburst/proc/Sprites(datum/energyfx_orbs/S, list/out, d, pre, kind, list/lm)
	if(d < 0) return
	var/g
	var/fa = 1
	if(d <= 2)
		g = list(0.4, 0.78, 1.04)[d + 1]
	else if(d <= 10)
		g = 1 + 0.004 * (d - 3)
	else
		var/j = floor((d - 11) / 2)
		g = 1.03 + 0.04 * (j + 1)
		fa = max(0, 1 - 0.22 * (j + 1))
	if(fa <= 0.001) return
	for(var/i = 1 to items.len)
		var/list/it = items[i]
		var/a = it[1] + it[5] * d / 40
		var/sl = it[2] * g
		S.Rec(out, "[pre][i]", kind, ik, "0_[it[4]]", x + cos(a) * ox * sl, y + sin(a) * ox * sl, a, sl, it[3], fa, lm, 0)

/datum/energyfx_orbs/proc/Holds(fi, list/hl, list/ones)
	var/v = fi - (fi % 2)
	for(var/list/o in ones)
		if(fi >= o[1] && fi < o[2]) v = fi
	for(var/list/h in hl)
		if(fi >= h[1] && fi < h[1] + h[2]) v = h[1]
	return v

/datum/energyfx_orbs/spirit
	var/fi0 = 4

/datum/energyfx_orbs/spirit/Accepts(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	if(R != row || P.Owner != caster || P.from_skill != from) return 0
	var/obj/Skills/Projectile/Z = from
	if(!Z || shots.len >= max(1, Z.Blasts)) return 0
	return Now() <= 4 + Z.Blasts * max(1, round(Z.Delay / world.tick_lag, 1))

/datum/energyfx_orbs/spirit/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	var/datum/energyfx_orbwake/W = new
	W.L = EFXO_SB_WAKE_L
	W.N = EFXO_SB_WAKE_N
	W.n = EFXO_SB_WAKE_F
	W.life40 = EFXO_SB_WAKE_LIFE40
	W.ik = "SpiritWake"
	W.tbl = EFXO_SB_WAKE_TBL
	O.vars_["wake"] = W
	var/datum/energyfx_orbsparkles/K = new
	K.ik = "SpiritSparkle"
	O.vars_["spk"] = K
	O.vars_["hits"] = list()
	return O

/datum/energyfx_orbs/spirit/proc/Z(datum/energyfx_orbshot/O, t)
	if(isnull(O.k_launch)) return 31
	return 31 * max(0, 1 - max(0, t - O.k_launch * EFXO_TICK) / 0.2)

/datum/energyfx_orbs/spirit/proc/PathA(datum/energyfx_orbshot/O, t)
	var/list/a = O.DrawnT(t - 1 / EFXO_FPS)
	var/list/b = O.DrawnT(t)
	if(!a || !b || (abs(a[1] - b[1]) < 0.000001 && abs(a[2] - b[2]) < 0.000001)) return O.heading
	O.heading = EFXOAtan2(b[2] - a[2], b[1] - a[1])
	return O.heading

/datum/energyfx_orbs/spirit/proc/ProcessHits(datum/energyfx_orbshot/O)
	var/list/H = O.vars_["hits"]
	while(H.len < O.hits.len)
		var/list/e = O.hits[H.len + 1]
		var/kh = e[1]
		var/th = kh * EFXO_TICK
		var/list/p = O.DrawnT(th)
		var/a = PathA(O, th)
		var/hx = p[1] + cos(a) * 6
		var/hy = p[2] + sin(a) * 6
		var/j = H.len
		var/datum/energyfx_orbsunburst/SB = new(Stream("sb[O.idx]_[j]"), hx, hy, 16, EFXO_SB_RAYS_OX, "OrbRays")
		var/datum/energyfx_orbsparkles/K = O.vars_["spk"]
		var/datum/bfx_rng/G = Stream("spk[O.idx]")
		K.Burst(G, th, hx, hy, 18)
		K.Burst(G, th + 0.05, hx, hy, 8)
		H[++H.len] = list(kh, hx, hy, SB, EFXODir8(a), e[2])
	if(!isnull(O.k_end) && isnull(O.vars_["pop"]))
		var/ke = O.k_end
		if(H.len)
			var/list/last = H[H.len]
			if(last[1] == ke)
				O.vars_["pop"] = list(ke, last[2], last[3])
				return
		var/te = ke * EFXO_TICK
		var/list/pe = O.DrawnT(te)
		var/ae = PathA(O, te)
		if(pe) O.vars_["pop"] = list(ke, pe[1] + cos(ae) * 6, pe[2] + sin(ae) * 6)

/datum/energyfx_orbs/spirit/HitNow(datum/energyfx_orbshot/O, k)
	ProcessHits(O)

/datum/energyfx_orbs/spirit/TickWork(k)
	for(var/datum/energyfx_orbshot/O in shots)
		ProcessHits(O)
		Predicted(O, k)
		if(isnull(O.k_launch) || !EFXOAfter1(O.k_launch, k)) continue
		if(!isnull(O.k_end) && k >= O.k_end) continue
		var/tk = k * EFXO_TICK
		var/tl = O.k_launch * EFXO_TICK
		var/list/c = O.DrawnT(tk)
		var/list/cp = O.DrawnT(max(tl, tk - EFXO_TICK))
		if(!c || !cp) continue
		var/z = Z(O, tk)
		var/zp = Z(O, max(tl, tk - EFXO_TICK))
		var/st = EFXOHyp(c[1] - cp[1], (c[2] + z) - (cp[2] + zp))
		var/ang = st > 0.000001 ? EFXOAtan2((c[2] + z) - (cp[2] + zp), c[1] - cp[1]) : PathA(O, tk)
		var/datum/energyfx_orbwake/W = O.vars_["wake"]
		W.Spawn(k, c[1], c[2] + z, ang, st > 0.000001 ? st : 16)

/datum/energyfx_orbs/spirit/Q(fi)
	var/list/hl = list(list(fi0 + 2, 4))
	var/list/ones = list()
	for(var/datum/energyfx_orbshot/O in shots)
		if(!isnull(O.k_launch)) hl += list(list(2 * O.k_launch + 1, 3))
		var/list/seen = list()
		for(var/list/e in O.hits)
			var/ih = 2 * e[1]
			seen["[e[1]]"] = 1
			hl += list(list(ih - 3, 3), list(ih + 5, 6))
			ones += list(list(ih, ih + 5))
		var/list/pr = O.vars_["pred"]
		for(var/kk in pr)
			if(seen[kk]) continue
			hl += list(list(2 * text2num(kk) - 3, 3))
		if(!isnull(O.k_end) && !O.end_lost)
			var/ie = 2 * O.k_end
			var/dup = 0
			for(var/list/e2 in O.hits)
				if(2 * e2[1] == ie) dup = 1
			if(!dup)
				hl += list(list(ie + 5, 6))
				ones += list(list(ie, ie + 5))
	return Holds(fi, hl, ones)

/datum/energyfx_orbs/spirit/Draw(fi, v)
	var/list/out = list()
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	for(var/datum/energyfx_orbshot/O in shots)
		var/datum/energyfx_orbwake/W = O.vars_["wake"]
		W.Sprites(src, out, v, "w[O.idx]_", "UP", "UL", EFXO_SB_LM, 4.8 + O.idx * 0.001)
	for(var/datum/energyfx_orbshot/O in shots)
		if(!EFXOTvGe(v, O.k_spawn)) continue
		if(!isnull(O.k_end) && !EFXOTvLt(v, O.k_end)) continue
		var/list/p = O.DrawnT(tv)
		if(!p) continue
		var/z = Z(O, tv)
		var/a = PathA(O, isnull(O.k_launch) ? tv : max(tv, O.k_launch * EFXO_TICK))
		var/g = EFXOEaseOut(min(1, (tv - O.k_spawn * EFXO_TICK) / 0.1))
		var/sc = 0.45 + 0.55 * g
		var/hf = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_SB_NF)
		var/st = "rest_[hf]"
		var/ang = 0
		if(!isnull(O.k_launch) && !EFXOTvLt(v, O.k_launch))
			var/tl = O.k_launch * EFXO_TICK
			var/frac = EFXO_SB_SPEED * (tv - tl) / EFXO_SB_STUB
			if(frac >= 0.875)
				st = "fly_[hf]"
			else if(frac > 0.125)
				var/ki = min(EFXO_SB_NSTUB - 1, floor(frac * EFXO_SB_NSTUB + 0.5) - 1)
				st = (ki < 0) ? "rest_[hf]" : "fly_staged_[ki]_[hf]"
			if(tv - 0.02 > tl)
				var/list/pp = O.DrawnT(max(tl, tv - 0.02))
				ang = EFXOAtan2((p[2] + z) - (pp[2] + Z(O, max(tl, tv - 0.02))), p[1] - pp[1])
			else
				ang = a
		Rec(out, "h[O.idx]p", "FP", "SpiritHead", "[st]_0", p[1], p[2] + z, ang, sc, sc, 1, null, 5 + O.idx * 0.001)
		Rec(out, "h[O.idx]l", "FL", "SpiritHead", "[st]_1", p[1], p[2] + z, ang, sc, sc, 1, EFXO_SB_LM, 0)
	for(var/datum/energyfx_orbshot/O in shots)
		var/list/H = O.vars_["hits"]
		for(var/j = 1 to H.len)
			var/list/e = H[j]
			var/d = v - 2 * e[1]
			if(d < 0 || !EFXOTvGe(fi, e[1])) continue
			var/fl = (d <= 2) ? 1 : max(0, 1 - (d - 2) / 6)
			if(fl > 0.002)
				Rec(out, "f[O.idx]_[j]", "XL", "SpiritFlash", "x", e[2], e[3], 0, 0.45, 0.45, fl, EFXO_SB_LM, 0)
			var/ri = (d < 5) ? d : 5 + floor((d - 5) / 2)
			if(ri < EFXO_SB_NRING)
				Rec(out, "r[O.idx]_[j]", "XL", "SpiritRing", "[ri]", e[2], e[3], 0, 1, 1, 1, EFXO_SB_LM, 0)
			var/datum/energyfx_orbsunburst/SB = e[4]
			SB.Sprites(src, out, d, "s[O.idx]_[j]_", "XL", EFXO_SB_LM)
		var/list/pop = O.vars_["pop"]
		if(pop)
			var/dp = v - 2 * pop[1]
			if(dp >= 0 && EFXOTvGe(fi, pop[1]))
				var/pi = (dp < 3) ? dp : ((dp <= 10) ? 2 : 3 + floor((dp - 11) / 2))
				if(pi < EFXO_SB_NPOP)
					Rec(out, "p[O.idx]p", "XP", "SpiritPop", "[pi]_0", pop[2], pop[3], 0, 1, 1, 1, null, 5.2 + O.idx * 0.001)
					Rec(out, "p[O.idx]l", "XL", "SpiritPop", "[pi]_1", pop[2], pop[3], 0, 1, 1, 1, EFXO_SB_LM, 0)
				var/list/lh = H.len ? H[H.len] : null
				if(!lh || lh[1] != pop[1])
					var/flp = (dp <= 2) ? 1 : max(0, 1 - (dp - 2) / 6)
					if(flp > 0.002)
						Rec(out, "fp[O.idx]", "XL", "SpiritFlash", "x", pop[2], pop[3], 0, 0.45, 0.45, flp, EFXO_SB_LM, 0)
	for(var/datum/energyfx_orbshot/O in shots)
		var/datum/energyfx_orbsparkles/K = O.vars_["spk"]
		K.Sprites(src, out, t, "k[O.idx]_", "XL", EFXO_SB_LM)
	return out

/datum/energyfx_orbs/spirit/proc/KD(v)
	var/list/res = list()
	for(var/datum/energyfx_orbshot/O in shots)
		var/list/H = O.vars_["hits"]
		for(var/list/e in H)
			if(!EFXOTvGe(v, e[1])) continue
			var/th = e[1] * EFXO_TICK
			var/tv = v / EFXO_FPS
			var/kd = EFXOEaseOut((tv - th) / 0.1) * max(0, 1 - max(0, tv - th - 0.25) / 0.3)
			var/mob/T = e[6]
			if(!ismob(T) || kd <= 0.001) continue
			var/list/cur = res[T]
			if(!cur || kd > cur[1]) res[T] = list(kd, e[5])
	return res

/datum/energyfx_orbs/spirit/Chars(k)
	var/list/a = KD(Q(2 * k))
	var/list/b = KD(Q(2 * k + 1))
	var/list/targets = list()
	for(var/T in a) targets |= T
	for(var/T in b) targets |= T
	for(var/T in chars) targets |= T
	for(var/mob/T in targets)
		var/list/x0 = a[T]
		var/list/x1 = b[T]
		var/k0 = x0 ? x0[1] : 0
		var/k1 = x1 ? x1[1] : 0
		if(k0 <= 0.001 && k1 <= 0.001)
			CharDrop(T)
			continue
		var/dt = x1 ? x1[2] : x0[2]
		CharFX(T, dt, EFXO_SB_TL, (k0 > 0.001) ? 0.5 * k0 : 0, (k1 > 0.001) ? 0.5 * k1 : 0, (k0 > 0.001) ? 0.85 * k0 : 0, (k1 > 0.001) ? 0.85 * k1 : 0, 0)

/datum/energyfx_orbs/spirit/Busy(k)
	var/v = 2 * k + 1
	for(var/datum/energyfx_orbshot/O in shots)
		var/datum/energyfx_orbwake/W = O.vars_["wake"]
		var/datum/energyfx_orbsparkles/K = O.vars_["spk"]
		if(W.Alive(v) || K.Alive(v / EFXO_FPS)) return 1
	return KD(v).len > 0

proc/EFXORoundPy(x)
	return EFXORoundHalfEven(x)

proc/EFXOTblBit(list/L, k)
	if(!L || k < 0 || k >= EFXO_TBL_K) return 0
	return EFXOBit(L, k)

proc/EFXOPlusLe(k0, k1, c)
	if(k1 != k0 + c) return k1 > k0 + c
	return !EFXOTblBit(EFXO_PLUS["[c]"], k0)

proc/EFXOMinusLt(k1, k0, c)
	if(k1 != k0 - c) return k1 < k0 - c
	return EFXOTblBit(EFXO_MINUS["[c]"], k0)

proc/EFXOTvGtMinus(v, k, c)
	if(v != 2 * k - 2 * c) return v > 2 * k - 2 * c
	return EFXOTblBit(EFXO_TVM["[c]"], k)

/datum/energyfx_orbblast3
	var/Re = 48
	var/x = 0
	var/y = 0
	var/kh = 0
	var/list/grow
	var/nd = 8
	var/list/sparks = list()
	var/list/smokes = list()
	var/list/embers = list()
	var/dome_ik
	var/ground_ik
	var/list/lm
	var/list/lm_scorch
	var/list/fl_kinds = list("XP", "XS", "XL")
	var/list/kick
	var/list/lm2
	var/list/lms2
	var/smoke_ik = "B3Smoke"
	var/list/lm_flash
	var/e4
	var/list/e4m
	var/sqx = 1
	var/sqy = 1
	var/sqa = 0
	var/dsc = 1

/datum/energyfx_orbblast3/New(datum/bfx_rng/G, Re_, x_, y_, kh_, g0, dome_ik_, ground_ik_, list/lm_, list/lm_scorch_)
	Re = Re_
	x = x_
	y = y_
	kh = kh_
	dome_ik = dome_ik_
	ground_ik = ground_ik_
	lm = lm_
	lm_scorch = lm_scorch_
	grow = list()
	for(var/g in EFXO_B3_GROW)
		grow += isnull(g0) ? g : round(g0 + (1 - g0) * (g - EFXO_B3_GROW[1]) / (1 - EFXO_B3_GROW[1]), 0.0001)
	nd = floor(EFXORoundHalfEven(8 + (Re - 32) / 48 * 5))
	var/k = Re / 48
	var/ns = EFXORoundHalfEven(12 * k ** 0.7)
	for(var/i = 1 to ns)
		var/a = G.U(0, 6.283185307)
		var/r0 = Re * G.U(0.2, 0.55)
		var/v = G.U(260, 520) * (0.75 + 0.25 * k)
		var/life = G.U(0.22, 0.42)
		var/d0 = G.U(0, 0.05)
		var/ln = G.U(0.5, 1.05)
		var/wd = G.U(0.45, 0.85)
		var/drag = G.U(2.2, 3.4)
		sparks[++sparks.len] = list(a, r0, v, life, d0, ln, wd, drag)
	var/nsm = EFXORoundHalfEven(18 * k ** 0.6)
	for(var/i = 1 to nsm)
		var/a = G.U(0, 6.283185307)
		var/r0 = Re * G.U(0.3, 0.85)
		var/r1 = r0 + Re * G.U(0.2, 0.45)
		var/d0 = G.U(0.2, 0.38)
		var/life = G.U(0.6, 1)
		var/sc = k * G.U(0.7, 1.25)
		var/rot = G.U(0, 360)
		var/spin = G.U(-30, 30)
		var/vv = G.RandRange(4)
		var/rise = G.U(4, 12) * k
		smokes[++smokes.len] = list(a, r0, r1, d0, life, sc, rot, spin, vv, rise)
	var/ne = EFXORoundHalfEven(9 * k ** 0.7)
	for(var/i = 1 to ne)
		var/a = G.U(0, 6.283185307)
		var/r0 = Re * G.U(0.2, 0.8)
		var/ad = a * 57.29577951
		var/d0 = G.U(0.15, 0.35)
		var/life = G.U(0.45, 0.8)
		var/vx = G.U(-18, 18)
		var/vy = G.U(24, 60)
		var/sc = G.U(0.5, 0.9)
		var/tw = G.U(8, 14)
		embers[++embers.len] = list(cos(ad) * r0, sin(ad) * r0, d0, life, vx, vy, sc, tw)

/datum/energyfx_orbblast3/proc/DomeIndex(d)
	var/ng = grow.len
	if(d < 0) return null
	if(d < ng) return d
	if(d < 11) return ng + BeamFXMod(floor((d - ng) / 2), 2)
	var/j = floor((d - 11) / 2)
	return (j < nd) ? ng + 2 + j : null

/datum/energyfx_orbblast3/proc/Body(datum/energyfx_orbs/S, list/out, d, pre, lay = 5)
	var/di = DomeIndex(d)
	var/ky = 1
	var/dyk = 0
	if(kick && d >= 0 && d < kick.len)
		ky = kick[d + 1]
		dyk = (ky - 1) * Re * 0.5
	if(!isnull(di) && e4)
		S.Rec(out, "[pre]db", fl_kinds[1], e4, e4m[1] ? "o[di]" : "og[di]", x, y + dyk, sqa, dsc * sqx, dsc * ky * sqy, 1, e4m[1], lay)
		for(var/k = 0 to 2)
			S.Rec(out, "[pre]da[k]", fl_kinds[2], e4, "l[k]_[di]", x, y + dyk, sqa, dsc * sqx, dsc * ky * sqy, 1, e4m[k + 2], 0)
	else if(!isnull(di))
		S.Rec(out, "[pre]db", fl_kinds[1], dome_ik, "b[di]", x, y + dyk, sqa, dsc * sqx, dsc * ky * sqy, 1, null, lay)
		S.Rec(out, "[pre]da", fl_kinds[2], dome_ik, "a[di]", x, y + dyk, sqa, dsc * sqx, dsc * ky * sqy, 1, null, 0)
	if(d >= 0 && d <= 6)
		var/fl = (d <= 1) ? 1 : max(0, 1 - (d - 1) / 5)
		var/s = Re / 48
		var/ks = EFXO_B3_STAR[d + 1]
		S.Rec(out, "[pre]fs", fl_kinds[3], "B3Flash", "soft", x, y, sqa, 0.9 * s * sqx, 0.9 * s * sqy, fl, lm_flash ? lm_flash : lm, 0)
		S.Rec(out, "[pre]ft", fl_kinds[3], "B3Flash", "star", x, y, 18 + sqa, ks * 1.1 * s * sqx, ks * 1.1 * s * sqy, fl, lm_flash ? lm_flash : lm, 0)

/datum/energyfx_orbblast3/proc/Ground(datum/energyfx_orbs/S, list/out, d, pre, kind = "GL")
	if(d >= 1)
		var/ri = (d < 5) ? d - 1 : 4 + floor((d - 5) / 2)
		if(ri < EFXO_B3_NRINGS)
			S.Rec(out, "[pre]gr", kind, ground_ik, "rings_[ri]", x, y, 0, dsc, dsc, 1, LM2(), 0)
	if(d >= 0 && d < 8)
		var/fi = min(EFXO_B3_NFLOOR - 1, d)
		var/fa = (d < 4) ? 1 : max(0, 1 - (d - 3) / 4)
		S.Rec(out, "[pre]gf", kind, ground_ik, "floor_[fi]", x, y, 0, dsc, dsc, fa, LM2(), 0)

/datum/energyfx_orbblast3/proc/LM2()
	if(!lm2) lm2 = EFXOLMa(lm, 2)
	return lm2

/datum/energyfx_orbblast3/proc/LMS2()
	if(!lms2) lms2 = EFXOLMa(lm_scorch, 2)
	return lms2

/datum/energyfx_orbblast3/proc/Scorch(datum/energyfx_orbs/S, list/out, d, pre, pkind = "GP", lkind = "GL")
	if(d < 2 || d >= 8 + 3 * EFXO_B3_NSCORCH) return
	var/si = (d >= 8) ? min(EFXO_B3_NSCORCH - 1, max(0, floor((d - 8) / 3))) : 0
	S.Rec(out, "[pre]sp", pkind, ground_ik, "scorch_[si]_0", x, y, 0, dsc, dsc, 1, null, 1)
	S.Rec(out, "[pre]sl", lkind, ground_ik, "scorch_[si]_1", x, y, 0, dsc, dsc, 1, LMS2(), 0)

/datum/energyfx_orbblast3/proc/Particles(datum/energyfx_orbs/S, list/out, list/smoke_out, t, pre, lkind = "XL", skind = "SM")
	var/age0 = t - kh * EFXO_TICK
	if(age0 < 0) return
	for(var/i = 1 to sparks.len)
		var/list/s = sparks[i]
		var/age = age0 - s[5]
		if(age < 0 || age >= s[4]) continue
		var/q = age / s[4]
		var/e = EFXOExp(-s[8] * age)
		var/r = s[2] + s[3] * (1 - e) / s[8]
		var/vnow = s[3] * e
		var/ad = s[1] * 57.29577951
		var/list/p = list(x + cos(ad) * r, y + sin(ad) * r)
		var/ln = s[6] * (0.35 + vnow / 420)
		var/al = min(1, age / 0.03) * (1 - EFXOSstep(0.55, 1, q))
		S.Rec(out, "[pre]k[i]", lkind, "B3Spark", "x", p[1], p[2], ad, ln, s[7], al, lm, 0)
	for(var/i = 1 to embers.len)
		var/list/em = embers[i]
		var/age = age0 - em[3]
		if(age < 0 || age >= em[4]) continue
		var/q = age / em[4]
		var/list/p = list(x + em[1] + em[5] * age, y + em[2] + em[6] * age * (1 - 0.4 * q))
		var/tw = 0.7 + 0.3 * sin(360 * em[8] * age)
		var/al = min(1, age / 0.06) * (1 - EFXOSstep(0.5, 1, q)) * tw
		S.Rec(out, "[pre]e[i]", lkind, "B3Ember", "x", p[1], p[2], 0, em[7], em[7], al, lm, 0)
	if(!smoke_out) return
	for(var/i = 1 to smokes.len)
		var/list/sm = smokes[i]
		var/age = age0 - sm[4]
		if(age < 0 || age >= sm[5]) continue
		var/q = age / sm[5]
		var/u = 1 - (1 - q) ** 2.2
		var/r = sm[2] + (sm[3] - sm[2]) * u
		var/ad = sm[1] * 57.29577951
		var/list/p = list(x + cos(ad) * r, y + sin(ad) * r + sm[10] * u)
		var/kk = min(EFXO_B3_NSMOKE - 1, floor(q * EFXO_B3_NSMOKE))
		var/sc = sm[6] * (0.7 + 0.5 * u)
		S.Rec(smoke_out, "[pre]m[i]", skind, smoke_ik, "[sm[9]]_[kk]_0", p[1], p[2], sm[7] + sm[8] * age, sc, sc, min(1, age / 0.12), null, 5.4 + i * 0.0001)

/datum/energyfx_orbblast3/proc/Alive(t, d)
	if(d < 8 + 3 * EFXO_B3_NSCORCH) return 1
	var/age0 = t - kh * EFXO_TICK
	for(var/list/s in smokes)
		if(age0 - s[4] < s[5]) return 1
	for(var/list/e in embers)
		if(age0 - e[3] < e[4]) return 1
	return 0

/datum/energyfx_orbconverge
	var/list/parts = list()
	var/ik = "B3Spark"

/datum/energyfx_orbconverge/proc/Emit(datum/bfx_rng/G, t0, n, r_from)
	for(var/i = 1 to n)
		var/tj = G.U(0, 0.05)
		var/a = G.U(0, 6.283185307)
		var/r0 = r_from * G.U(1.4, 2.3)
		var/life = G.U(0.16, 0.3)
		var/ln = G.U(0.35, 0.7)
		var/wd = G.U(0.45, 0.8)
		parts[++parts.len] = list(t0 + tj, a * 57.29577951, r0, life, ln, wd)

/datum/energyfx_orbconverge/proc/Sprites(datum/energyfx_orbs/S, list/out, t, cx, cy, r_surf, pre, kind, list/lm)
	for(var/i = 1 to parts.len)
		var/list/p = parts[i]
		var/age = t - p[1]
		if(age < 0 || age >= p[4]) continue
		var/q = age / p[4]
		var/r = p[3] + (r_surf - p[3]) * (q * q)
		var/al = min(1, age / 0.04) * (1 - EFXOSstep(0.75, 1, q))
		S.Rec(out, "[pre][i]", kind, ik, "x", cx + cos(p[2]) * r, cy + sin(p[2]) * r, p[2] + 180, p[5] * (0.6 + 0.8 * q), p[6], al, lm, 0)

/datum/energyfx_orbconverge/proc/Alive(t)
	for(var/list/p in parts)
		if(t - p[1] < p[4]) return 1
	return 0

proc/EFXOArcs(datum/energyfx_orbs/S, list/out, datum/bfx_rng/G, x, y, r, pre, kind, ik, list/lm)
	var/list/res = list()
	var/n = list(1, 1, 2)[G.RandRange(3) + 1]
	for(var/i = 1 to n)
		var/a = G.U(0, 6.283185307) * 57.29577951
		var/rr = r + G.U(0, 3)
		var/k = G.U(0.55, 0.9) * max(0.5, r / 16)
		var/st = G.RandRange(4)
		var/ang = a + 90 + G.U(-20, 20)
		var/fl = list(1, -1)[G.RandRange(2) + 1]
		var/al = G.U(0.6, 1)
		res[++res.len] = list(st, x + cos(a) * rr, y + sin(a) * rr, ang, k, k * fl, al)
	return res

/datum/energyfx_orbs/bigbang
	var/list/arcs_cache = list()
	var/datum/energyfx_orbwake/wake
	var/datum/energyfx_orbconverge/conv
	var/datum/energyfx_orbblast3/blast
	var/kb
	var/bx
	var/by
	var/fang = 0
	var/fx = 1
	var/fy = 0
	var/palm_x
	var/palm_y
	var/mob/struck
	var/bdir = "W"
	var/R_ = EFXO_BB_R
	var/palm_k = 0.9
	var/conv_n = 2
	var/b_re = 48
	var/b_g0
	var/b_dome = "B3Dome48BB"
	var/b_ground = "B3Ground48"
	var/list/lm
	var/list/tlc
	var/kd_hold = 0.3
	var/kd_fade = 0.4

/datum/energyfx_orbs/bigbang/proc/Setup()
	lm = EFXO_BB_LM
	tlc = EFXO_BB_TL
	wake.L = EFXO_BB_WAKE_L
	wake.N = EFXO_BB_WAKE_N
	wake.n = EFXO_BB_WAKE_F
	wake.life40 = EFXO_BB_WAKE_LIFE40
	wake.ik = "BigBangWake"
	wake.tbl = EFXO_BB_WAKE_TBL

/datum/energyfx_orbs/bigbang/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	wake = new
	Setup()
	conv = new
	var/d = DisplayedCardinal(P.Owner ? P.Owner.dir : P.dir, SOUTH)
	var/list/dv = BeamFXDirVec(BeamFXDirText(d))
	fx = dv[1]
	fy = dv[2]
	fang = EFXOAtan2(fy, fx)
	return O

/datum/energyfx_orbs/bigbang/proc/Shot()
	return shots.len ? shots[1] : null

/datum/energyfx_orbs/bigbang/proc/Tch(datum/energyfx_orbshot/O)
	if(O.T_charge > 0) return O.T_charge / 10
	if(!isnull(O.k_launch)) return (O.k_launch - O.k_spawn) * EFXO_TICK
	return 1.5

/datum/energyfx_orbs/bigbang/proc/KLaunch(datum/energyfx_orbshot/O)
	if(!isnull(O.k_launch)) return O.k_launch
	if(!isnull(O.k_charge)) return O.k_charge + round(O.T_charge / (world.tick_lag), 1)
	return null

/datum/energyfx_orbs/bigbang/proc/Scale(datum/energyfx_orbshot/O, t)
	return 1 / 3 + (2 / 3) * EFXOSstep(0, 1, (t - O.k_spawn * EFXO_TICK) / Tch(O))

/datum/energyfx_orbs/bigbang/proc/Palm(datum/energyfx_orbshot/O)
	if(isnull(palm_x))
		var/list/p = O.GetP(O.k_spawn)
		if(!p) return null
		palm_x = p[1] - R_ * palm_k * fx
		palm_y = p[2] - R_ * palm_k * fy
	return list(palm_x, palm_y)

/datum/energyfx_orbs/bigbang/proc/ChargePos(datum/energyfx_orbshot/O, t)
	var/list/pm = Palm(O)
	if(!pm) return null
	var/sc = Scale(O, t)
	return list(pm[1] + R_ * sc * palm_k * fx, pm[2] + R_ * sc * palm_k * fy, sc)

/datum/energyfx_orbs/bigbang/proc/BallPos(datum/energyfx_orbshot/O, t, v)
	if(isnull(O.k_launch) || EFXOTvLt(v, O.k_launch)) return ChargePos(O, t)
	var/list/d = O.DrawnT(t)
	return d ? list(d[1], d[2], 1) : null

/datum/energyfx_orbs/bigbang/proc/BallPosK(datum/energyfx_orbshot/O, k)
	if(isnull(O.k_launch) || k < O.k_launch) return ChargePos(O, k * EFXO_TICK)
	var/list/d = O.DrawnAt(2 * k)
	return d ? list(d[1], d[2], 1) : null

/datum/energyfx_orbs/bigbang/proc/HeadT(datum/energyfx_orbshot/O, t)
	if(isnull(O.k_launch)) return fang
	var/list/a = O.DrawnT(t - 1 / EFXO_FPS)
	var/list/b = O.DrawnT(t)
	if(!a || !b || (abs(a[1] - b[1]) < 0.01 && abs(a[2] - b[2]) < 0.01)) return O.heading ? O.heading : fang
	O.heading = EFXOAtan2(b[2] - a[2], b[1] - a[1])
	return O.heading

/datum/energyfx_orbs/bigbang/proc/Boom(datum/energyfx_orbshot/O)
	if(blast) return
	if(O.vars_["countered"])
		if(isnull(kb) && !isnull(O.k_end)) kb = O.k_end
		return
	var/k = null
	var/mob/T = null
	if(O.hits.len)
		var/list/e = O.hits[1]
		k = e[1]
		T = e[2]
	else if(!isnull(O.k_end))
		k = O.k_end
	if(isnull(k)) return
	kb = k
	struck = ismob(T) ? T : null
	var/list/p = O.DrawnT(k * EFXO_TICK)
	bx = round(p[1], 1)
	by = round(p[2], 1)
	bdir = EFXODir8(HeadT(O, k * EFXO_TICK) + 180)
	PreBoom()
	blast = new(Stream("b3"), b_re, bx, by, kb, b_g0, b_dome, b_ground, lm, EFXO_LM_SCORCH)
	OnBoom()

/datum/energyfx_orbs/bigbang/proc/PreBoom()

/datum/energyfx_orbs/bigbang/proc/OnBoom()

/datum/energyfx_orbs/bigbang/HitNow(datum/energyfx_orbshot/O, k)
	Boom(O)

/datum/energyfx_orbs/bigbang/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return
	Boom(O)
	var/kl = KLaunch(O)
	if(conv_n && !isnull(kl) && EFXOPlusLe(O.k_spawn, k, 2) && EFXOMinusLt(k, kl, 2))
		conv.Emit(Stream("conv"), k * EFXO_TICK, conv_n, R_ * 1.2)
	if(!isnull(O.k_launch) && k >= O.k_launch + 1 && (isnull(kb) || k < kb))
		var/list/c = BallPosK(O, k)
		var/list/cp = BallPosK(O, max(O.k_launch, k - 1))
		if(c && cp)
			var/st = EFXOHyp(c[1] - cp[1], c[2] - cp[2])
			wake.Spawn(k, c[1], c[2], HeadT(O, k * EFXO_TICK), st > 0.000001 ? st : 10)

/datum/energyfx_orbs/bigbang/Q(fi)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return fi - (fi % 2)
	var/kl = KLaunch(O)
	var/list/hl = list()
	var/list/ones = list()
	if(!isnull(kl))
		var/ir = 2 * kl
		hl += list(list(ir - 4, 4))
		ones += list(list(ir, isnull(kb) ? 1000000 : 2 * kb + 5))
	return Holds(fi, hl, ones)

/datum/energyfx_orbs/bigbang/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return out
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	if(blast)
		blast.Scorch(src, out, d, "b")
		blast.Ground(src, out, d, "b")
	wake.Sprites(src, out, v, "w", "UP", "UL", EFXO_BB_LM, 4.8)
	if(blast)
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b")
		out += sm
	if(EFXOTvGe(v, O.k_spawn) && (isnull(kb) || EFXOTvLt(v, kb)))
		var/list/bp = BallPos(O, tv, v)
		if(bp)
			var/sc = bp[3]
			var/hf = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_BB_NF)
			var/st = "rest_[hf]"
			var/ang = fang
			if(!isnull(O.k_launch) && !EFXOTvLt(v, O.k_launch))
				var/list/p0 = O.DrawnT(O.k_launch * EFXO_TICK)
				var/dist = EFXOHyp(bp[1] - p0[1], bp[2] - p0[2])
				var/frac = dist / (EFXO_BB_STUB * 1.4)
				if(frac >= 1)
					st = "fly_[hf]"
				else
					st = "fly_staged_[min(EFXO_BB_NSTUB - 1, floor(frac * EFXO_BB_NSTUB))]_[hf]"
				ang = HeadT(O, tv)
			Rec(out, "bp", "FP", "BigBangBall", "[st]_0", bp[1], bp[2], ang, sc, sc, 1, null, 5)
			Rec(out, "bl", "FL", "BigBangBall", "[st]_1", bp[1], bp[2], ang, sc, sc, 1, EFXO_BB_LM, 0)
			var/kl = KLaunch(O)
			if(isnull(O.k_launch) || EFXOTvLt(v, O.k_launch))
				conv.Sprites(src, out, tv, bp[1], bp[2], EFXO_BB_R * sc * 0.95, "c", "FL", EFXO_BB_LM)
				if(!isnull(kl) && EFXOTvGtMinus(v, kl, 20))
					var/list/ac = arcs_cache["[v]"]
					if(!ac)
						ac = EFXOArcs(src, out, Stream("arc[v]"), bp[1], bp[2], EFXO_BB_R * sc, "a", "FL", "BigBangArc", EFXO_BB_LM)
						arcs_cache["[v]"] = ac
					for(var/i = 1 to ac.len)
						var/list/a = ac[i]
						Rec(out, "a[i]", "FL", "BigBangArc", "[a[1]]", a[2], a[3], a[4], a[5], a[6], a[7], EFXO_BB_LM, 0)
	if(!isnull(O.k_launch) && EFXOTvGe(v, O.k_launch))
		var/fa = tv - O.k_launch * EFXO_TICK
		var/list/pm = Palm(O)
		var/mx = pm[1] + 4 * fx
		var/my = pm[2] + 4 * fy
		if(fa < 0.14)
			var/q = fa / 0.14
			Rec(out, "mf", "FL", "BigBangMisc", "flash", mx, my, fang, 1 + 0.6 * q, 1 + 0.6 * q, 1 - q * q, EFXO_BB_LM, 0)
		if(fa < 0.22)
			var/q2 = fa / 0.22
			var/kk = (EFXO_BB_R * (0.8 + 1.4 * EFXOEaseOut(q2))) / EFXO_BB_RING_R
			Rec(out, "mr", "FL", "BigBangMisc", "ring", mx, my, fang, kk * 0.55, kk, 1 - q2, EFXO_BB_LM, 0)
	if(blast)
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b")
	return out

/datum/energyfx_orbs/bigbang/proc/KD(v)
	if(isnull(kb) || !EFXOTvGe(v, kb)) return 0
	var/tv = v / EFXO_FPS
	var/th = kb * EFXO_TICK
	return EFXOEaseOut((tv - th) / 0.1) * max(0, 1 - max(0, tv - th - kd_hold) / kd_fade)

/datum/energyfx_orbs/bigbang/Chars(k)
	if(!struck) return
	var/k0 = KD(Q(2 * k))
	var/k1 = KD(Q(2 * k + 1))
	var/d = Q(2 * k + 1) - 2 * kb
	var/ground = blast && d < 8 + 3 * EFXO_B3_NSCORCH
	if(k0 <= 0.001 && k1 <= 0.001 && !ground)
		CharDrop(struck)
		return
	CharFX(struck, bdir, tlc, 0.46 * k0, 0.46 * k1, 0.8 * k0, 0.8 * k1, ground)

/datum/energyfx_orbs/bigbang/Busy(k)
	var/v = 2 * k + 1
	if(wake.Alive(v) || conv.Alive(v / EFXO_FPS)) return 1
	if(blast && blast.Alive(v / EFXO_FPS, v - 2 * kb)) return 1
	return 0

/datum/energyfx_orbs/sgm
	parent_type = /datum/energyfx_orbs/bigbang
	R_ = EFXO_SGM_R
	palm_k = 0.95
	conv_n = 0
	b_re = 80
	b_g0 = 0.65
	b_dome = "B3Dome80SGM"
	b_ground = "B3Ground80"
	kd_hold = 0.4
	kd_fade = 0.5
	var/datum/energyfx_orbsunburst/sun

/datum/energyfx_orbs/sgm/Setup()
	lm = EFXO_SGM_LM
	tlc = EFXO_SGM_TL
	wake.L = EFXO_SGM_WAKE_L
	wake.N = EFXO_SGM_WAKE_N
	wake.n = EFXO_SGM_WAKE_F
	wake.life40 = EFXO_SGM_WAKE_LIFE40
	wake.ik = "SGMWake"
	wake.tbl = EFXO_SGM_WAKE_TBL

/datum/energyfx_orbs/sgm/Scale(datum/energyfx_orbshot/O, t)
	return 0.3 + 0.7 * EFXOEaseOut(max(0, (t - O.k_spawn * EFXO_TICK) / 0.1))

/datum/energyfx_orbs/sgm/OnBoom()
	sun = new(Stream("sb"), bx, by, 66, EFXO_SB_RAYS_OX, "OrbRays")

/datum/energyfx_orbs/sgm/Q(fi)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return fi - (fi % 2)
	return Holds(fi, list(), list(list(2 * O.k_spawn, isnull(kb) ? 1000000 : 2 * kb + 5)))

/datum/energyfx_orbs/sgm/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return out
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	if(blast)
		blast.Scorch(src, out, d, "b")
		blast.Ground(src, out, d, "b")
	wake.Sprites(src, out, v, "w", "UP", "UL", lm, 4.8)
	if(blast)
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b")
		out += sm
	if(EFXOTvGe(v, O.k_spawn) && (isnull(kb) || EFXOTvLt(v, kb)))
		var/list/bp = BallPos(O, tv, v)
		if(bp)
			var/sc = bp[3]
			var/hf = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_SGM_NF)
			var/fly = !isnull(O.k_launch) && !EFXOTvLt(v, O.k_launch)
			var/st = fly ? "fly_[hf]" : "rest_[hf]"
			var/ang = fly ? HeadT(O, tv) : fang
			Rec(out, "bp", "FP", "SGMBall", "[st]_0", bp[1], bp[2], ang, sc, sc, 1, null, 5)
			Rec(out, "bl", "FL", "SGMBall", "[st]_1", bp[1], bp[2], ang, sc, sc, 1, lm, 0)
	if(EFXOTvGe(v, O.k_spawn))
		var/fa = tv - O.k_spawn * EFXO_TICK
		var/list/pm = Palm(O)
		if(pm)
			if(fa < 0.16)
				var/q = fa / 0.16
				Rec(out, "mf", "FL", "BigBangMisc", "flash", pm[1] + 8 * fx, pm[2] + 8 * fy, fang, 0.8 + 0.5 * q, 0.8 + 0.5 * q, 1 - q * q, lm, 0)
			if(fa < 0.26)
				var/q2 = fa / 0.26
				var/kk = (R_ * (0.4 + 0.5 * EFXOEaseOut(q2))) / EFXO_BB_RING_R
				Rec(out, "mr", "FL", "BigBangMisc", "ring", pm[1] + 6 * fx, pm[2] + 6 * fy, fang, kk * 0.5, kk, 1 - q2, lm, 0)
	if(blast)
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b")
		if(sun) sun.Sprites(src, out, d, "s", "XL", lm)
	return out

proc/EFXOAgeF(v, k, op, c)
	var/o = v - 2 * k
	var/oc = round(c * 40, 1)
	if(o != oc) return (op == "lt") ? (o < oc) : (o >= oc)
	return EFXOTblBit(EFXO_AGE["f[op][c]"], k)

proc/EFXOAgeT(kk, k, op, c)
	var/o = kk - k
	var/oc = round(c * 20, 1)
	if(o != oc) return (op == "lt") ? (o < oc) : (o >= oc)
	return EFXOTblBit(EFXO_AGE["t[op][c]"], k)

proc/EFXOSqJ(k, off)
	if(off < 0 || off > 2 || k < 0 || k >= EFXO_TBL_K) return -1
	return EFXO_SQH[k * 3 + off + 1] - 1

proc/EFXOH20(v)
	return floor(v / 2) - EFXOBit(EFXO_H20, v)

/datum/energyfx_orbs/omega
	parent_type = /datum/energyfx_orbs/bigbang
	R_ = EFXO_OM_R
	conv_n = 0
	b_re = 80
	b_ground = "B3Ground80"
	kd_hold = 0.4
	kd_fade = 0.5
	var/list/feeds = list()
	var/list/heads = list()
	var/last_dm = 0
	var/k_rel

/datum/energyfx_orbs/omega/Setup()
	lm = EFXO_OM_LM
	tlc = EFXO_OM_TL
	wake.L = EFXO_OM_WAKE_L
	wake.N = EFXO_OM_WAKE_N
	wake.n = EFXO_OM_WAKE_F
	wake.life40 = EFXO_OM_WAKE_LIFE40
	wake.ik = "OmegaWake"
	wake.tbl = EFXO_OM_WAKE_TBL

/datum/energyfx_orbs/omega/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	last_dm = P.DamageMult
	return O

/datum/energyfx_orbs/omega/proc/Held()
	return caster && from && caster.held_skill == from

/datum/energyfx_orbs/omega/proc/FeedRate()
	var/obj/Skills/Z = from
	return max(1, round((Z ? Z.FireRate : 10) / world.tick_lag, 1))

/datum/energyfx_orbs/omega/proc/Feeds(datum/energyfx_orbshot/O, k)
	var/obj/Skills/Projectile/_Projectile/P = O.P
	if(P && P.loc && !P.Killed && P.DamageMult > last_dm + 0.001)
		last_dm = P.DamageMult
		var/kf = P.vhb_g0 ? round(P.vhb_g0 / world.tick_lag, 1) - K0 : k
		feeds += kf
		var/done = 0
		for(var/list/h in heads)
			if(isnull(h[2]) && isnull(h[3]))
				h[2] = kf
				done = 1
				break
		if(!done) heads += list(list(kf, kf, null))
		if(parity) OL("E [O.idx] feed [kf]")
	if(isnull(k_rel) && !Held())
		k_rel = k
		if(parity) OL("E [O.idx] release [k]")
		for(var/list/h2 in heads.Copy())
			if(isnull(h2[2]) && isnull(h2[3]))
				if(k_rel > h2[1] - 5) h2[3] = k_rel
				else heads -= list(h2)
	if(!isnull(k_rel) || !isnull(kb) || !isnull(O.k_end) || feeds.len >= 4 || (P && P.DamageMult >= 2.5)) return
	for(var/list/h3 in heads)
		if(isnull(h3[2])) return
	var/kp = feeds.len ? feeds[feeds.len] + FeedRate() : round(caster.held_charge_start / world.tick_lag, 1) - K0 + FeedRate()
	heads += list(list(kp, null, null))
	if(parity) OL("E [O.idx] predict_feed [kp]")

/datum/energyfx_orbs/omega/proc/SizeF(datum/energyfx_orbshot/O, v)
	var/tv = v / EFXO_FPS
	var/s = 0.3 + 0.7 * min(1, max(0, tv - KL(O) * EFXO_TICK))
	var/sw = 0
	for(var/kf in feeds)
		if(!EFXOTvGe(v, kf)) continue
		if(EFXOAgeF(v, kf, "lt", 0.05)) s *= 1.05
		else if(EFXOAgeF(v, kf, "lt", 0.1)) s *= 1.13
		else s *= 1.1
		if(EFXOAgeF(v, kf, "lt", 0.4)) sw = max(sw, 0.06 * EFXOExp(-(tv - kf * EFXO_TICK) / 0.12))
	return list(s, sw)

/datum/energyfx_orbs/omega/proc/SizeT(datum/energyfx_orbshot/O, k)
	var/s = 0.3 + 0.7 * min(1, max(0, (k - KL(O)) * EFXO_TICK))
	for(var/kf in feeds)
		if(k < kf) continue
		if(EFXOAgeT(k, kf, "lt", 0.05)) s *= 1.05
		else if(EFXOAgeT(k, kf, "lt", 0.1)) s *= 1.13
		else s *= 1.1
	return s

/datum/energyfx_orbs/omega/PreBoom()
	var/n = 0
	for(var/kf in feeds)
		if(kf <= kb) n++
	n = min(4, n)
	b_g0 = EFXO_OM_G0[n + 1]
	b_dome = "B3Dome80OM[n]"

/datum/energyfx_orbs/omega/HitNow(datum/energyfx_orbshot/O, k)
	Boom(O)
	if(!isnull(kb))
		for(var/list/h in heads.Copy())
			if(isnull(h[2])) heads -= list(h)

/datum/energyfx_orbs/omega/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return
	if(isnull(kb)) Feeds(O, k)
	Boom(O)
	if(!isnull(kb))
		for(var/list/h in heads.Copy())
			if(isnull(h[2])) heads -= list(h)
	if(!isnull(O.k_launch) && EFXOAfter1(O.k_launch, k) && (isnull(kb) || k < kb))
		var/list/c = BallPosK(O, k)
		var/list/cp = BallPosK(O, max(O.k_launch, k - 1))
		if(c && cp)
			var/st = EFXOHyp(c[1] - cp[1], c[2] - cp[2])
			var/h = HeadT(O, k * EFXO_TICK)
			var/off = R_ * SizeT(O, k) * 0.6
			wake.Spawn(k, c[1] - cos(h) * off, c[2] - sin(h) * off, h, st > 0.000001 ? st : 32)

/datum/energyfx_orbs/omega/BallPos(datum/energyfx_orbshot/O, t, v)
	var/list/d = O.DrawnT(t)
	return d ? list(d[1], d[2], 1) : null

/datum/energyfx_orbs/omega/BallPosK(datum/energyfx_orbshot/O, k)
	var/list/d = O.DrawnAt(2 * k)
	return d ? list(d[1], d[2], 1) : null

/datum/energyfx_orbs/omega/Q(fi)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return fi - (fi % 2)
	var/list/ones = list()
	if(!isnull(kb)) ones += list(list(2 * kb, 2 * kb + 5))
	for(var/list/h in heads)
		var/kt = isnull(h[2]) ? h[1] : h[2]
		ones += list(list(2 * kt - 10, 2 * kt + 6))
	return Holds(fi, list(list(2 * KL(O), 3)), ones)

/datum/energyfx_orbs/omega/proc/HeadAt(datum/energyfx_orbshot/O, list/out, j, v, kt, alpha)
	var/tv = v / EFXO_FPS
	var/a_ = tv - kt * EFXO_TICK
	var/u = max(0, (a_ + 0.25) / 0.25)
	var/list/p = O.DrawnT(tv)
	if(!p) return
	var/list/sz = SizeF(O, v)
	var/rc = R_ * sz[1] * (1 + sz[2])
	var/h = HeadT(O, tv)
	var/ch = cos(h)
	var/sh = sin(h)
	var/along = -260.8 + (260.8 - rc * 0.9) * u * u
	var/up = 10 * (1 - u)
	var/x = p[1] + ch * along - sh * up
	var/y = p[2] + sh * along + ch * up
	var/hf = BeamFXMod(EFXOH20(v), EFXO_SB_NF)
	var/st
	if(u < 0.7)
		st = "fly_staged_[min(EFXO_SB_NSTUB - 1, floor(u * EFXO_SB_NSTUB))]_[hf]"
	else
		st = "fly_[hf]"
	var/ang = h - 12 * (1 - u)
	Rec(out, "hp[j]", "FP", "OmegaFeed", "[st]_0", x, y, ang, 1.2, 1.2, alpha, null, 5.2 + j * 0.0001)
	Rec(out, "hl[j]", "FL", "OmegaFeed", "[st]_1", x, y, ang, 1.2, 1.2, alpha, lm, 0)

/datum/energyfx_orbs/omega/proc/KL(datum/energyfx_orbshot/O)
	return isnull(O.k_launch) ? O.k_spawn : O.k_launch

/datum/energyfx_orbs/omega/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return out
	var/kl = KL(O)
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	if(blast)
		blast.Scorch(src, out, d, "b")
		blast.Ground(src, out, d, "b")
	wake.Sprites(src, out, v, "w", "UP", "UL", lm, 4.8)
	if(blast)
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b")
		out += sm
	if(EFXOTvGe(v, kl) && (isnull(kb) || EFXOTvLt(v, kb)))
		var/list/p = O.DrawnT(tv)
		if(p)
			var/list/sz = SizeF(O, v)
			var/rc = R_ * sz[1] * (1 + sz[2])
			var/kk = rc / R_
			var/h = HeadT(O, tv)
			var/bf = BeamFXMod(floor((v - 2 * kl) / 2), EFXO_OM_NF)
			Rec(out, "bp", "FP", "OmegaBubble", "[bf]_0", p[1], p[2], fang, kk, kk, 1, null, 5)
			Rec(out, "bl", "FL", "OmegaBubble", "[bf]_1", p[1], p[2], fang, kk, kk, 1, lm, 0)
			var/kc = (8 + 0.18 * rc) / EFXO_OM_CORE_R
			Rec(out, "bc", "FL", "OmegaCore", "art", p[1], p[2], fang, kc, kc, 1, lm, 0)
			for(var/j = 1 to heads.len)
				var/list/hd = heads[j]
				var/kt = isnull(hd[2]) ? hd[1] : hd[2]
				if(EFXOAgeF(v, kt, "ge", -0.25) && !EFXOTvGe(v, kt))
					if(isnull(hd[3]) || EFXOTvLt(v, hd[3]))
						HeadAt(O, out, j, v, kt, 1)
					else
						var/qa = (tv - hd[3] * EFXO_TICK) / 0.05
						if(qa < 1) HeadAt(O, out, j, 2 * hd[3], kt, 1 - qa)
				if(isnull(hd[2]) || !EFXOTvGe(v, hd[2])) continue
				var/fa = tv - hd[2] * EFXO_TICK
				if(EFXOAgeF(v, hd[2], "lt", 0.15))
					Rec(out, "ff[j]", "FL", "CatacHit", "flash", p[1] - cos(h) * rc * 0.92, p[2] - sin(h) * rc * 0.92, 0, 0.7, 0.7, 1 - fa / 0.15, lm, 0)
				if(fa < 0.22)
					var/q = fa / 0.22
					var/rs = (0.75 + 0.55 * q) * rc / EFXO_OM_RIPPLE_R
					Rec(out, "fr[j]", "FL", "OmegaRipple", "art", p[1], p[2], 0, rs, rs, 0.85 * (1 - q) ** 1.3, lm, 0)
	if(blast)
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b")
	return out

/datum/energyfx_orbs/jecht
	var/fi0 = 4

/datum/energyfx_orbs/jecht/Accepts(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	if(R != row || P.Owner != caster || P.from_skill != from) return 0
	var/obj/Skills/Projectile/Z = from
	if(!Z || shots.len >= max(1, Z.Blasts)) return 0
	return Now() <= 4 + Z.Blasts * max(1, round(Z.Delay / world.tick_lag, 1)) + 40

/datum/energyfx_orbstar4
	var/list/items = list()
	var/x
	var/y
	var/ox = 0
	var/ik = "OrbRays"

/datum/energyfx_orbstar4/New(datum/bfx_rng/G, xx, yy, size, rays_ox)
	x = xx
	y = yy
	ox = rays_ox
	var/base = G.U(0, 90)
	for(var/i = 0 to 3)
		var/lng = (i % 2 == 0)
		var/a = base + i * 90 + G.U(-6, 6)
		var/ln = size * (lng ? G.U(0.9, 1.1) : G.U(0.55, 0.75))
		var/vv = G.RandRange(4)
		var/wd = G.U(0.45, 0.6)
		items[++items.len] = list(a, ln, vv, wd)

/datum/energyfx_orbstar4/proc/Sprites(datum/energyfx_orbs/S, list/out, k, alpha, pre, kind, list/lm)
	for(var/i = 1 to items.len)
		var/list/it = items[i]
		var/sl = it[2] * k
		if(sl <= 0.02) continue
		S.Rec(out, "[pre][i]", kind, ik, "0_[it[3]]", x + cos(it[1]) * ox * sl, y + sin(it[1]) * ox * sl, it[1], sl, it[4], alpha, lm, 0)

proc/EFXOCeil40(k)
	return 2 * k + EFXOBit(EFXO_C40, k)

/datum/energyfx_orbs/jecht/Init(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R, datum/energyfx_look/orbs/L)
	..()
	max_life = 2400

/datum/energyfx_orbs/jecht/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	var/datum/energyfx_orbwake/W = new
	W.L = EFXO_JT_WAKE_L
	W.N = EFXO_JT_WAKE_N
	W.n = EFXO_JT_WAKE_F
	W.life40 = EFXO_JT_WAKE_LIFE40
	W.ik = "JechtWake"
	W.tbl = EFXO_JT_WAKE_TBL
	O.vars_["wake"] = W
	var/datum/energyfx_orbsparkles/K = new
	K.ik = "JechtStars"
	K.sc_lo = 0.4
	K.sc_hi = 0.62
	O.vars_["spk"] = K
	O.vars_["hits"] = list()
	O.vars_["big"] = list()
	var/d = DisplayedCardinal(P.Owner ? P.Owner.dir : P.dir, SOUTH)
	var/list/dv = BeamFXDirVec(BeamFXDirText(d))
	O.vars_["fx"] = dv[1]
	O.vars_["fy"] = dv[2]
	return O

/datum/energyfx_orbs/jecht/OnHit(datum/energyfx_orbshot/O, atom/target)
	var/list/B = O.vars_["big"]
	B += (O.P && O.P.HomingCharge <= 0) ? 1 : 0
	..()

/datum/energyfx_orbs/jecht/HitNow(datum/energyfx_orbshot/O, k)
	ProcessHits(O, k)

/datum/energyfx_orbs/jecht/proc/PredictFirst(datum/energyfx_orbshot/O, k)
	var/obj/Skills/Projectile/_Projectile/P = O.P
	if(!P || !P.loc || isnull(O.k_launch) || O.hits.len || !isnull(O.vars_["pred"]) || !ismob(P.Homing)) return
	var/list/a = O.GetP(k)
	var/list/b = O.HasP(k - 1) ? O.pk[k] : null
	if(!a || !b) return
	var/mob/T = P.Homing
	if(T.proj_immune_until > world.time + 2 * world.tick_lag || T.Airborne) return
	var/tcx = (T.x - 1) * 32 + T.step_x + 16
	var/tcy = (T.y - 1) * 32 + T.step_y + 16
	var/d1 = EFXOHyp(a[1] + (a[1] - b[1]) - tcx, a[2] + (a[2] - b[2]) - tcy)
	var/d2 = EFXOHyp(a[1] + 2 * (a[1] - b[1]) - tcx, a[2] + 2 * (a[2] - b[2]) - tcy)
	if(d2 <= 16 && d1 > 16)
		O.vars_["pred"] = k + 2
		if(parity) OL("E [O.idx] predict [k + 2]")

/datum/energyfx_orbs/jecht/proc/Fang(datum/energyfx_orbshot/O)
	return EFXOAtan2(O.vars_["fy"], O.vars_["fx"])

/datum/energyfx_orbs/jecht/proc/KLp(datum/energyfx_orbshot/O)
	if(!isnull(O.k_launch)) return O.k_launch
	if(!isnull(O.k_charge)) return O.k_charge + round(O.T_charge / world.tick_lag, 1)
	return null

/datum/energyfx_orbs/jecht/proc/Done(datum/energyfx_orbshot/O)
	return O.vars_["done"]

/datum/energyfx_orbs/jecht/proc/Pre(datum/energyfx_orbshot/O)
	var/list/p = O.GetP(O.k_spawn)
	return p ? p : O.Center()

/datum/energyfx_orbs/jecht/proc/PosT(datum/energyfx_orbshot/O, t, pre_launch, after_done)
	if(pre_launch)
		var/list/p0 = Pre(O)
		return p0 ? list(p0[1], p0[2], 31, Fang(O)) : null
	var/kd = Done(O)
	if(after_done)
		var/td = kd * EFXO_TICK
		var/list/e = PosT(O, td, 0, 0)
		if(!e) return null
		var/a = e[4]
		var/dd = 640 * (t - td)
		return list(e[1] + cos(a) * dd, e[2] + sin(a) * dd * 0.2, 0, a)
	var/list/d = O.DrawnT(t)
	if(!d) return null
	var/z = 31 * max(0, 1 - (t - O.k_launch * EFXO_TICK) / 0.12)
	return list(d[1], d[2], z, HeadT(O, t))

/datum/energyfx_orbs/jecht/proc/HeadT(datum/energyfx_orbshot/O, t)
	var/list/a = O.DrawnT(t - 1 / EFXO_FPS)
	var/list/b = O.DrawnT(t)
	if(!a || !b || (abs(a[1] - b[1]) < 0.01 && abs(a[2] - b[2]) < 0.01)) return isnull(O.vars_["head"]) ? Fang(O) : O.vars_["head"]
	O.vars_["head"] = EFXOAtan2(b[2] - a[2], b[1] - a[1])
	return O.vars_["head"]

/datum/energyfx_orbs/jecht/proc/PosK(datum/energyfx_orbshot/O, k)
	var/kd = Done(O)
	return PosT(O, k * EFXO_TICK, isnull(O.k_launch) || k < O.k_launch, !isnull(kd) && k >= kd)

/datum/energyfx_orbs/jecht/proc/PosV(datum/energyfx_orbshot/O, v)
	var/kd = Done(O)
	return PosT(O, v / EFXO_FPS, isnull(O.k_launch) || EFXOTvLt(v, O.k_launch), !isnull(kd) && EFXOTvGe(v, kd))

/datum/energyfx_orbs/jecht/proc/ProcessHits(datum/energyfx_orbshot/O, k)
	var/list/H = O.vars_["hits"]
	var/list/B = O.vars_["big"]
	var/n = O.vars_["nproc"] ? O.vars_["nproc"] : 0
	while(n < O.hits.len)
		n++
		if(!isnull(O.vars_["fin"])) continue
		var/list/e = O.hits[n]
		var/kh = e[1]
		var/atom/movable/T = e[2]
		var/big = (n <= B.len) ? B[n] : 0
		var/h = HeadT(O, kh * EFXO_TICK)
		var/list/pb = O.DrawnAt(2 * kh)
		var/tcx = (T && T.loc) ? (T.x - 1) * 32 + T:step_x + 16 : (pb ? pb[1] : 0)
		var/tcy = (T && T.loc) ? (T.y - 1) * 32 + T:step_y + 16 : (pb ? pb[2] : 0)
		var/hx = tcx - 9 * cos(h)
		var/hy = tcy - 9 * sin(h)
		var/datum/energyfx_orbstar4/S4 = new(Stream("st4h[O.idx]_[H.len]"), hx, hy, big ? 0.7 : 0.36, EFXO_SB_RAYS_OX)
		var/datum/energyfx_orbsparkles/K = O.vars_["spk"]
		K.Burst(Stream("spk[O.idx]"), kh * EFXO_TICK, hx, hy, big ? 8 : 2, 4)
		H[++H.len] = list(kh, hx, hy, big, S4, T, EFXODir8(h))
		if(big)
			O.vars_["fin"] = kh
			O.vars_["done"] = kh + 1
			if(parity) OL("E [O.idx] finisher [kh]")
	O.vars_["nproc"] = n
	if(isnull(O.vars_["done"]) && !isnull(O.k_end))
		O.vars_["done"] = O.k_end
		if(parity) OL("E [O.idx] done [O.k_end]")

/datum/energyfx_orbs/jecht/TickWork(k)
	for(var/datum/energyfx_orbshot/O in shots)
		ProcessHits(O, k)
		PredictFirst(O, k)
		var/kd = Done(O)
		if(!isnull(kd) && !O.vars_["fadeb"] && k * EFXO_TICK >= kd * EFXO_TICK + 0.12)
			O.vars_["fadeb"] = 1
			var/list/pf = PosT(O, kd * EFXO_TICK + 0.12, 0, 1)
			var/datum/energyfx_orbsparkles/K = O.vars_["spk"]
			if(pf) K.Burst(Stream("spk[O.idx]"), kd * EFXO_TICK + 0.12, pf[1], pf[2], 10, 5)
		if(isnull(O.k_launch) || k < O.k_launch + 1) continue
		if(!isnull(kd) && (k - kd) * EFXO_TICK >= 0.12) continue
		var/list/c = PosK(O, k)
		var/list/cp = PosK(O, max(O.k_launch, k - 1))
		if(!c || !cp) continue
		var/st = EFXOHyp(c[1] - cp[1], (c[2] + c[3]) - (cp[2] + cp[3]))
		var/ang = st > 0.000001 ? EFXOAtan2((c[2] + c[3]) - (cp[2] + cp[3]), c[1] - cp[1]) : c[4]
		var/datum/energyfx_orbwake/W = O.vars_["wake"]
		W.Spawn(k, c[1], c[2] + c[3], ang, st > 0.000001 ? st : 32)

/datum/energyfx_orbs/jecht/Q(fi)
	var/list/hl = list()
	var/list/ones = list()
	var/datum/energyfx_orbshot/O0 = shots.len ? shots[1] : null
	if(O0) hl += list(list(2 * O0.k_spawn + 2, 4))
	for(var/datum/energyfx_orbshot/O in shots)
		if(!isnull(O.k_launch)) hl += list(list(2 * O.k_launch + 1, 3))
		var/list/H = O.vars_["hits"]
		if(!H || !H.len)
			if(!isnull(O.vars_["pred"])) hl += list(list(2 * O.vars_["pred"] - 3, 3))
			continue
		var/ih = 2 * H[1][1]
		hl += list(list(ih - 3, 3))
		var/kd = Done(O)
		if(isnull(kd))
			ones += list(list(ih, 1000000))
		else
			var/ce = EFXOCeil40(kd)
			ones += list(list(ih, ce + 4))
			hl += list(list(ce + 4, 6))
	return Holds(fi, hl, ones)

/datum/energyfx_orbs/jecht/Draw(fi, v)
	var/list/out = list()
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	for(var/datum/energyfx_orbshot/O in shots)
		var/datum/energyfx_orbwake/W = O.vars_["wake"]
		W.Sprites(src, out, v, "w[O.idx]_", "UP", "UL", EFXO_JT_LM, 4.8 + O.idx * 0.001)
	for(var/datum/energyfx_orbshot/O in shots)
		var/kd = Done(O)
		if(!EFXOTvGe(v, O.k_spawn)) continue
		if(!isnull(kd) && v - 2 * kd >= 5) continue
		var/list/p = PosV(O, v)
		if(!p) continue
		var/fi_ = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_JT_NF)
		var/g = EFXOEaseOut(min(1, (tv - O.k_spawn * EFXO_TICK) / 0.12))
		var/sc = 0.4 + 0.6 * g
		var/al = 1
		var/st
		var/ang
		var/x = p[1]
		var/y = p[2] + p[3]
		if(isnull(O.k_launch) || EFXOTvLt(v, O.k_launch))
			var/klp = KLp(O)
			var/span = isnull(klp) ? 0.1 : max(0.1, (klp - O.k_spawn) * EFXO_TICK)
			var/q = min(1, (tv - O.k_spawn * EFXO_TICK) / span)
			var/half = (q > 0.5)
			if(!isnull(klp) && klp - O.k_spawn == 20 && v - 2 * O.k_spawn == 20) half = EFXOTblBit(EFXO_JT_HALF, O.k_spawn)
			st = half ? "charge_[fi_]" : "rest_[fi_]"
			y += 1.5 * sin(360 * tv * 2.2)
			ang = Fang(O)
		else
			var/frac = 640 * (tv - O.k_launch * EFXO_TICK) / EFXO_JT_STUB
			if(frac >= 0.875)
				st = "fly_[fi_]"
			else if(frac > 0.125)
				st = "fly_staged_[max(0, min(EFXO_JT_NSTUB - 1, floor(frac * EFXO_JT_NSTUB + 0.5) - 1))]_[fi_]"
			else
				st = "charge_[fi_]"
			var/list/pp = PosT(O, max(O.k_launch * EFXO_TICK, tv - 0.02), 0, !isnull(kd) && max(O.k_launch * EFXO_TICK, tv - 0.02) >= kd * EFXO_TICK)
			if(pp && abs(x - pp[1]) + abs(y - pp[2] - pp[3]) > 0.001)
				ang = EFXOAtan2(y - (pp[2] + pp[3]), x - pp[1])
			else
				ang = p[4]
			if(!isnull(kd) && EFXOTvGe(v, kd)) al = max(0, 1 - (tv - kd * EFXO_TICK) / 0.12)
		Rec(out, "bg[O.idx]", "FP", "JechtBall", "[st]_2", x, y, ang, sc, sc, al, null, 5.1 + O.idx * 0.001)
		Rec(out, "bp[O.idx]", "XP", "JechtBall", "[st]_0", x, y, ang, sc, sc, al, null, 5 + O.idx * 0.001)
		Rec(out, "bl[O.idx]", "XL", "JechtBall", "[st]_1", x, y, ang, sc, sc, al, EFXO_JT_LM, 0)
	for(var/datum/energyfx_orbshot/O in shots)
		if(!isnull(O.k_launch) && EFXOTvGe(v, O.k_launch) && v - 2 * O.k_launch < 8)
			var/d = v - 2 * O.k_launch
			var/list/p0 = Pre(O)
			if(p0)
				var/kx = p0[1] + 6 * O.vars_["fx"]
				var/ky = p0[2] + 6 * O.vars_["fy"] + 31
				var/ri = (d < 4) ? d : 4 + floor((d - 4) / 2)
				if(ri < EFXO_JT_NKICK)
					Rec(out, "kr[O.idx]", "XL", "JechtKickRing", "[ri]", kx, ky, 0, 1, 1, 1, EFXO_JT_LM, 0)
				var/fl = (d <= 1) ? 1 : max(0, 1 - (d - 1) / 3)
				if(fl > 0.002)
					Rec(out, "kf[O.idx]", "XL", "JechtSoft", "x", kx, ky, 0, 0.16, 0.16, fl, EFXO_JT_LM, 0)
					var/datum/energyfx_orbstar4/SK = O.vars_["star_kick"]
					if(!SK)
						SK = new(Stream("st4k[O.idx]"), p0[1], p0[2] + 31, 0.5, EFXO_SB_RAYS_OX)
						O.vars_["star_kick"] = SK
					SK.Sprites(src, out, EFXO_JT_KSTAR[min(d, 6) + 1], fl, "ks[O.idx]_", "XL", EFXO_JT_LM)
		var/list/H = O.vars_["hits"]
		for(var/j = 1 to H.len)
			var/list/e = H[j]
			if(!EFXOTvGe(v, e[1])) continue
			var/d2 = v - 2 * e[1]
			var/big = e[4]
			if(d2 >= (big ? 13 : 7)) continue
			if(big)
				var/rb = (d2 < 4) ? d2 : 4 + floor((d2 - 4) / 2)
				if(rb < EFXO_JT_NBIG)
					Rec(out, "hb[O.idx]_[j]a", "XL", "JechtBigRing", "[rb]", e[2], e[3], 35, 1, 0.55, 1, EFXO_JT_LM, 0)
					Rec(out, "hb[O.idx]_[j]b", "XL", "JechtBigRing", "[rb]", e[2], e[3], -35, 1, 0.55, 1, EFXO_JT_LM, 0)
				var/si = (d2 < 3) ? d2 : 3 + floor((d2 - 3) / 2)
				if(si < EFXO_JT_NSHOCK)
					Rec(out, "hs[O.idx]_[j]", "XL", "JechtShock", "[si]", e[2], e[3], 0, 1, 1, 1, EFXO_JT_LM, 0)
			var/fl2 = (d2 <= 1) ? 1 : max(0, 1 - (d2 - 1) / (big ? 4 : 2))
			if(fl2 > 0.002)
				var/ss = big ? 0.24 : 0.12
				Rec(out, "hf[O.idx]_[j]", "XL", "JechtSoft", "x", e[2], e[3], 0, ss, ss, fl2, EFXO_JT_LM, 0)
				var/datum/energyfx_orbstar4/S4 = e[5]
				S4.Sprites(src, out, EFXO_JT_HSTAR[min(d2, 7) + 1], fl2, "hst[O.idx]_[j]_", "XL", EFXO_JT_LM)
	for(var/datum/energyfx_orbshot/O in shots)
		var/datum/energyfx_orbsparkles/K = O.vars_["spk"]
		K.Sprites(src, out, t, "k[O.idx]_", "XL", EFXO_JT_LM)
	return out

/datum/energyfx_orbs/jecht/proc/KD(v)
	var/list/res = list()
	var/tv = v / EFXO_FPS
	for(var/datum/energyfx_orbshot/O in shots)
		var/list/H = O.vars_["hits"]
		if(!H || !H.len) continue
		var/list/e = H[1]
		if(!EFXOTvGe(v, e[1])) continue
		var/kd = Done(O)
		var/fade = isnull(kd) ? 1 : max(0, 1 - max(0, tv - kd * EFXO_TICK - 0.1) / 0.3)
		var/k = EFXOEaseOut((tv - e[1] * EFXO_TICK) / 0.08) * fade
		var/mob/T = e[6]
		if(!ismob(T) || k <= 0.001) continue
		var/list/cur = res[T]
		if(!cur || k > cur[1]) res[T] = list(k, e[7])
	return res

/datum/energyfx_orbs/jecht/Chars(k)
	var/list/a = KD(Q(2 * k))
	var/list/b = KD(Q(2 * k + 1))
	var/list/targets = list()
	for(var/T in a) targets |= T
	for(var/T in b) targets |= T
	for(var/T in chars) targets |= T
	for(var/mob/T in targets)
		var/list/x0 = a[T]
		var/list/x1 = b[T]
		var/k0 = x0 ? x0[1] : 0
		var/k1 = x1 ? x1[1] : 0
		if(k0 <= 0.001 && k1 <= 0.001)
			CharDrop(T)
			continue
		CharFX(T, x1 ? x1[2] : x0[2], EFXO_JT_TL, 0.5 * k0, 0.5 * k1, 0.85 * k0, 0.85 * k1, 0)

/datum/energyfx_orbs/jecht/Busy(k)
	var/v = 2 * k + 1
	for(var/datum/energyfx_orbshot/O in shots)
		var/datum/energyfx_orbwake/W = O.vars_["wake"]
		var/datum/energyfx_orbsparkles/K = O.vars_["spk"]
		if(W.Alive(v) || K.Alive(v / EFXO_FPS)) return 1
		var/kd = Done(O)
		if(!isnull(kd) && !O.vars_["fadeb"]) return 1
	return KD(v).len > 0

proc/EFXOAgeM(v, k, op, c)
	var/o = v - 2 * k
	var/oc = round(c * 40, 1)
	if(o != oc) return (op == "lt") ? (o < oc) : (o >= oc)
	return EFXOTblBit(EFXO_AGE["m[op][c]"], k)

proc/EFXOPaintK(k, list/edge)
	return list(k, 0, 0, 0, 0, k, 0, 0, 0, 0, k, 0, 0, 0, 0, 1, (1 - k) * edge[1], (1 - k) * edge[2], (1 - k) * edge[3], 0)

proc/EFXOLightK(k, list/lc, list/lcore)
	var/g = 1 / EFXO_LS
	return list(k * (lcore[1] - lc[1]) * g, k * (lcore[2] - lc[2]) * g, k * (lcore[3] - lc[3]) * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)

proc/EFXOCoolK(al)
	return 0.3 + 0.7 * clamp(al, 0, 1) ** 0.8

/datum/energyfx_orbsparks3d
	var/list/parts = list()

/datum/energyfx_orbsparks3d/proc/Emit(datum/bfx_rng/G, t0, cx, cy, Rad, n, vlo = 40, vhi = 120)
	for(var/i = 1 to n)
		var/u = G.U(-1, 1)
		var/ph = G.U(0, 360)
		var/s = sqrt(max(0, 1 - u * u))
		var/nx = s * cos(ph)
		var/ny = s * sin(ph)
		var/j = G.U(-40, 40)
		var/dx = nx * cos(j) - ny * sin(j)
		var/dy = nx * sin(j) + ny * cos(j)
		var/v = G.U(vlo, vhi)
		var/r0 = Rad * G.U(1, 1.3)
		var/tj = G.U(0, 0.05)
		var/life = G.U(0.25, 0.5)
		var/seq = G.RandRange(6)
		var/sc = G.U(0.35, 0.75)
		parts[++parts.len] = list(t0 + tj, cx + nx * r0, cy + ny * r0, u, s, dx * v, dy * v, life, seq, sc)

/datum/energyfx_orbsparks3d/proc/Sprites(datum/energyfx_orbs/S, list/back, list/front, tv, pre, list/edge, list/lc, list/lcore)
	for(var/i = 1 to parts.len)
		var/list/p = parts[i]
		var/age = tv - p[1]
		if(age < 0 || age >= p[8]) continue
		var/q = age / p[8]
		var/k = age * (1 - 0.9 * age)
		var/x = p[2] + p[6] * k
		var/y = p[3] + p[7] * k
		var/ang = (p[5] > 0.001) ? EFXOAtan2(p[7], p[6]) : 0
		var/sx = p[10] * (0.3 + 0.7 * p[5]) * (1 - 0.35 * EFXOSstep(0.55, 1, q))
		var/al = min(1, age / 0.025) * (1 - EFXOSstep(0.7, 1, q))
		var/isfront = p[4] >= -0.2
		var/lal = al * (isfront ? 1 : 0.6)
		var/list/out = isfront ? front : back
		S.Rec(out, "[pre]p[i]", isfront ? "WP" : "UP", "DeathBallSpark", "[p[9]]_0", x, y, ang, sx, 1, al, EFXOPaintK(EFXOCoolK(al), edge), isfront ? 5.3 : 4.7)
		S.Rec(out, "[pre]l[i]", isfront ? "WL" : "UL", "DeathBallSpark", "[p[9]]_1", x, y, ang, sx, 1, lal, EFXOLightK(EFXOCoolK(lal), lc, lcore), 0)

/datum/energyfx_orbsparks3d/proc/Alive(tv)
	for(var/list/p in parts)
		if(tv - p[1] < p[8]) return 1
	return 0

/datum/energyfx_orbbolts
	var/list/items = list()

/datum/energyfx_orbbolts/proc/Emit(datum/bfx_rng/G, k0, cx, cy, Rad, n)
	for(var/i = 1 to n)
		var/a = G.U(0, 360)
		var/r = Rad * G.U(0.35, 1.2)
		var/tang = a + G.U(-120, 120)
		var/life = list(0.1, 0.1, 0.15)[G.RandRange(3) + 1]
		var/seq = G.RandRange(8)
		var/sc = G.U(0.95, 1.4) * Rad / 62
		var/flip = (G.R() < 0.5) ? 1 : -1
		items[++items.len] = list(k0, cx + cos(a) * r, cy + sin(a) * r, tang, life, seq, sc, flip)

/datum/energyfx_orbbolts/proc/Sprites(datum/energyfx_orbs/S, list/out, v, pre, list/lc, list/lcore)
	for(var/i = 1 to items.len)
		var/list/b = items[i]
		if(EFXOTvLt(v, b[1]) || !EFXOAgeF(v, b[1], "lt", b[5])) continue
		S.Rec(out, "[pre]p[i]", "WP", "DeathBallFork", "[b[6]]_0", b[2], b[3], b[4], b[7], b[7] * b[8], 1, null, 5.6)
		S.Rec(out, "[pre]l[i]", "WL", "DeathBallFork", "[b[6]]_1", b[2], b[3], b[4], b[7], b[7] * b[8], 1, EFXOLightK(1, lc, lcore), 0)

/datum/energyfx_orbbolts/proc/Alive(tv)
	for(var/list/b in items)
		if(tv - b[1] * EFXO_TICK < b[5]) return 1
	return 0

/datum/energyfx_orbs/deathball
	parent_type = /datum/energyfx_orbs/bigbang
	R_ = EFXO_DB_R
	conv_n = 0
	b_re = 64
	b_g0 = 0.97
	b_dome = "B3Dome64DB"
	b_ground = "B3Ground64DB"
	var/datum/energyfx_orbsparks3d/sparks
	var/datum/energyfx_orbbolts/bolts
	var/mob/occ_target
	var/gx
	var/gy
	var/cy0

/datum/energyfx_orbs/deathball/Setup()
	lm = EFXO_DB_BLM
	tlc = EFXO_DB_TL
	sparks = new
	bolts = new
	bdir = "N"

/datum/energyfx_orbs/deathball/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	var/mob/T = P.Owner ? P.Owner.Target : null
	if(ismob(T) && T.z == P.z && abs(T.x - P.x) <= 1 && abs(T.y - P.y) <= 1) occ_target = T
	return O

/datum/energyfx_orbs/deathball/proc/Anchor(datum/energyfx_orbshot/O)
	if(isnull(gx))
		var/list/p = O.GetP(O.k_spawn)
		if(!p) return 0
		gx = p[1]
		cy0 = p[2]
		gy = p[2] - 6
	return 1

/datum/energyfx_orbs/deathball/proc/KDrop(datum/energyfx_orbshot/O)
	return isnull(O.k_launch) ? null : O.k_launch

/datum/energyfx_orbs/deathball/proc/KHit(datum/energyfx_orbshot/O)
	if(!isnull(kb)) return kb
	if(!isnull(O.k_fuse)) return O.k_fuse + 3
	return null

/datum/energyfx_orbs/deathball/proc/Hover(datum/energyfx_orbshot/O)
	var/kd = KDrop(O)
	if(!isnull(kd)) return (kd - O.k_spawn) * EFXO_TICK
	var/obj/Skills/Projectile/Z = from
	return (Z ? Z.Hover : 40) / 10

/datum/energyfx_orbs/deathball/proc/ZPos(datum/energyfx_orbshot/O, tv, v)
	var/kd = KDrop(O)
	if(isnull(kd) || EFXOTvLt(v, kd)) return EFXO_DB_HOVER
	var/u = min(1, (tv - kd * EFXO_TICK) / 0.2)
	return EFXO_DB_HOVER * (1 - u * u)

/datum/energyfx_orbs/deathball/proc/ZPosK(datum/energyfx_orbshot/O, k)
	var/kd = KDrop(O)
	if(isnull(kd) || k < kd) return EFXO_DB_HOVER
	var/u = min(1, (k - kd) * EFXO_TICK / 0.2)
	return EFXO_DB_HOVER * (1 - u * u)

/datum/energyfx_orbs/deathball/Boom(datum/energyfx_orbshot/O)
	if(blast) return
	var/k = null
	var/mob/T = null
	if(O.hits.len)
		var/list/e = O.hits[1]
		k = e[1]
		T = e[2]
	else if(!isnull(O.k_end))
		k = O.k_end
	if(isnull(k) || !Anchor(O)) return
	kb = k
	struck = ismob(T) ? T : occ_target
	bx = round(gx, 1)
	by = round(cy0, 1)
	PreBoom()
	blast = new(Stream("b3"), b_re, bx, by, kb, b_g0, b_dome, b_ground, lm, EFXO_DB_LM_SCORCH)
	blast.fl_kinds = list("ZP", "ZS", "ZL")
	blast.smoke_ik = "B3SmokeDB"
	OnBoom()

/datum/energyfx_orbs/deathball/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O || !Anchor(O)) return
	Boom(O)
	var/kh = KHit(O)
	if(k < O.k_spawn) return
	var/tk = k * EFXO_TICK
	if(!isnull(kh) && k == kh)
		sparks.Emit(Stream("spk"), tk, gx, cy0, R_, 14, 120, 320)
		bolts.Emit(Stream("bolt"), k, gx, cy0, R_, 3)
		return
	if(!isnull(kh) && k > kh) return
	if(!isnull(O.k_end) && k >= O.k_end) return
	var/q = min(1, (tk - O.k_spawn * EFXO_TICK) / Hover(O))
	var/z = ZPosK(O, k)
	var/g = EFXOEaseOut(min(1, (tk - O.k_spawn * EFXO_TICK) / 0.3))
	var/datum/bfx_rng/N = Stream("np")
	sparks.Emit(Stream("spk"), tk, gx, cy0 + z, R_ * (0.4 + 0.6 * g), 1 + EFXORoundHalfEven(1.5 * q + N.R()))
	if(N.R() < 0.5 + 0.35 * q)
		bolts.Emit(Stream("bolt"), k, gx, cy0 + z, R_ * (0.4 + 0.6 * g), 1)

/datum/energyfx_orbs/deathball/Q(fi)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return fi - (fi % 2)
	var/list/ones = list()
	var/kd = KDrop(O)
	if(!isnull(kd)) ones += list(list(2 * kd, isnull(kb) ? 1000000 : 2 * kb + 5))
	return Holds(fi, list(list(2 * O.k_spawn + 2, 4)), ones)

/datum/energyfx_orbs/deathball/proc/BodyFrame(datum/energyfx_orbshot/O, v)
	var/o = v - 2 * O.k_spawn
	var/f = floor(o / 2)
	if(o % 2 == 0 && O.k_spawn < 16 && f < 200 && EFXOBit(EFXO_DB_BF, O.k_spawn * 200 + f)) f -= 1
	return BeamFXMod(min(EFXO_DB_NF - 1, f), EFXO_DB_NF)

/datum/energyfx_orbs/deathball/proc/Stage(datum/energyfx_orbshot/O, v, hover)
	var/tv = v / EFXO_FPS
	var/q = min(1, (tv - O.k_spawn * EFXO_TICK) / hover)
	var/st = min(EFXO_DB_NCRACK - 1, floor(q * EFXO_DB_NCRACK))
	var/o = v - 2 * O.k_spawn
	if(abs(hover - 4) < 0.0001 && o % 20 == 0 && o > 0 && o <= 140 && O.k_spawn < 16)
		var/j = o / 20
		st = min(EFXO_DB_NCRACK - 1, j - EFXOBit(EFXO_DB_ST, O.k_spawn * 8 + j))
	return st

/datum/energyfx_orbs/deathball/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O || !Anchor(O)) return out
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	var/hover = Hover(O)
	if(EFXOTvGe(v, O.k_spawn))
		var/st = Stage(O, v, hover)
		var/fade = 1
		if(!isnull(kb) && !EFXOAgeM(v, kb, "lt", 0.2)) fade = max(0, 1 - (tv - kb * EFXO_TICK - 0.2) / 0.6)
		if(fade > 0.002)
			Rec(out, "cs", "GP", "DeathBallFissure", "[st]", gx, gy, 0, 1, 1, fade * 0.7, EFXOPaintK(EFXOCoolK(fade * 0.7), EFXO_DB_SH_EDGE), 1)
			Rec(out, "cp", "GP", "DeathBallCrack", "[st]_0", gx, gy, 0, 1, 1, fade, EFXOPaintK(EFXOCoolK(fade), EFXO_DB_FX_EDGE), 1.1)
			Rec(out, "cl", "GL", "DeathBallCrack", "[st]_1", gx, gy, 0, 1, 1, fade, EFXOLightK(EFXOCoolK(fade), EFXO_DB_FX_LC, EFXO_DB_FX_LCORE), 0)
	var/visible = EFXOTvGe(v, O.k_spawn) && (isnull(kb) || EFXOTvLt(v, kb)) && (isnull(O.k_end) || !isnull(kb) || EFXOTvLt(v, O.k_end))
	if(visible)
		var/g = EFXOEaseOut(min(1, (tv - O.k_spawn * EFXO_TICK) / 0.3))
		var/z = ZPos(O, tv, v)
		var/sa = 0.45 * min(1, (tv - O.k_spawn * EFXO_TICK) / 0.3) * (0.8 + 0.4 * (1 - z / EFXO_DB_HOVER))
		var/ss = 0.98 + 0.25 * (1 - z / EFXO_DB_HOVER)
		Rec(out, "pool", "GL", "DeathBallPool", "x", gx, gy, 0, ss, ss * 0.5, sa, EFXO_DB_FX_LM, 0)
		var/q = min(1, (tv - O.k_spawn * EFXO_TICK) / hover)
		var/pulse = 1 + (0.012 + 0.018 * q) * sin(360 * (tv - O.k_spawn * EFXO_TICK) * (2 + 3 * q))
		var/sx = (0.07 + 0.93 * g) * pulse
		var/sy = sx
		var/kh = KHit(O)
		if(!isnull(kh) && EFXOAgeM(v, kh, "ge", -0.05))
			sx = 1.08
			sy = 0.85
		var/bf = BodyFrame(O, v)
		Rec(out, "op", "SM", "DeathBallBody", "[bf]_0", gx, cy0 + z, 0, sx, sy, 1, null, 5)
		Rec(out, "ol", "FL", "DeathBallBody", "[bf]_1", gx, cy0 + z, 0, sx, sy, 1, EFXO_DB_LM, 0)
		Rec(out, "ob", "XP", "DeathBallBody", "[bf]_2", gx, cy0 + z, 0, sx, sy, 1, null, 5.1)
		Rec(out, "oa", "XS", "DeathBallBody", "[bf]_3", gx, cy0 + z, 0, sx, sy, 1, null, 0)
	if(blast)
		blast.Scorch(src, out, d, "b", "NP", "ML")
		blast.Ground(src, out, d, "b", "ML")
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b", "ZL", "YP")
		out += sm
	var/sparks_on = EFXOTvGe(v, O.k_spawn) && (isnull(kb) || EFXOAgeM(v, kb, "lt", 0.6))
	if(sparks_on)
		var/list/back = list()
		var/list/front = list()
		sparks.Sprites(src, back, front, tv, "s", EFXO_DB_FX_EDGE, EFXO_DB_FX_LC, EFXO_DB_FX_LCORE)
		bolts.Sprites(src, front, v, "f", EFXO_DB_FX_LC, EFXO_DB_FX_LCORE)
		out += back
		out += front
	if(blast)
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b", "ZL", "YP")
	return out

/datum/energyfx_orbs/deathball/Chars(k)
	var/mob/T = struck ? struck : occ_target
	if(!T) return
	var/k0 = KD(Q(2 * k))
	var/k1 = KD(Q(2 * k + 1))
	var/kf = isnull(kb) ? -1000 : Q(2 * k + 1) - 2 * kb
	var/ground = isnull(kb) || kf < 8 + 3 * EFXO_B3_NSCORCH || kf < 8 + 24
	if(k0 <= 0.001 && k1 <= 0.001 && !ground)
		CharDrop(T)
		return
	CharFX(T, "N", tlc, 0.46 * k0, 0.46 * k1, 0.8 * k0, 0.8 * k1, ground)

/datum/energyfx_orbs/deathball/Busy(k)
	var/v = 2 * k + 1
	if(sparks.Alive(v / EFXO_FPS) || bolts.Alive(v / EFXO_FPS)) return 1
	if(blast && blast.Alive(v / EFXO_FPS, v - 2 * kb)) return 1
	return isnull(kb)

var/list/EFXO_FITCACHE = list()

proc/EFXOGrayRule(list/C255)
	if(!C255) return 1
	var/r = C255[1] / 255
	var/g = C255[2] / 255
	var/b = C255[3] / 255
	var/mx = max(r, g, b)
	var/sat = (mx > 0) ? (mx - min(r, g, b)) / mx : 0
	return (0.2126 * r + 0.7152 * g + 0.0722 * b) < 0.03 || sat < 0.1

proc/EFXOTo255(v)
	return EFXORoundHalfEven(clamp(v, 0, 1) * 255)

proc/EFXODeriveBase(list/m)
	var/list/p = list(m[1] ** 2.4, m[2] ** 2.4, m[3] ** 2.4)
	var/mx = max(p[1], p[2], p[3], 0.000001)
	return list(0.8 * p[1] / mx, 0.8 * p[2] / mx, 0.8 * p[3] / mx)

proc/EFXODeriveCore(list/m)
	return list(1 - 0.25 * (1 - m[1]), 1 - 0.25 * (1 - m[2]), 1 - 0.25 * (1 - m[3]))

proc/EFXOPalette(list/C255, list/core255, list/glow255)
	if(EFXOGrayRule(C255)) return list(list(56, 56, 56), list(158, 158, 158), list(255, 255, 255), 1)
	var/list/c = list(C255[1] / 255, C255[2] / 255, C255[3] / 255)
	var/list/base
	var/list/mid
	if(glow255)
		var/list/g = list(glow255[1] / 255, glow255[2] / 255, glow255[3] / 255)
		if(BeamFXLum(c) < BeamFXLum(g))
			base = c
			mid = g
	if(!base)
		base = EFXODeriveBase(c)
		mid = c
	var/list/cr = core255 ? list(core255[1] / 255, core255[2] / 255, core255[3] / 255) : EFXODeriveCore(mid)
	return list(list(EFXOTo255(base[1]), EFXOTo255(base[2]), EFXOTo255(base[3])), list(EFXOTo255(mid[1]), EFXOTo255(mid[2]), EFXOTo255(mid[3])),
		list(EFXOTo255(cr[1]), EFXOTo255(cr[2]), EFXOTo255(cr[3])), 0)

proc/EFXOSubPalette(list/m255, list/core255, list/glow255)
	var/list/mid = list(m255[1] / 255, m255[2] / 255, m255[3] / 255)
	var/list/base = list(max(0, m255[1] - 102) / 255, max(0, m255[2] - 102) / 255, max(0, m255[3] - 102) / 255)
	if(glow255)
		var/list/g = list(glow255[1] / 255, glow255[2] / 255, glow255[3] / 255)
		if(BeamFXLum(mid) < BeamFXLum(g))
			base = mid
			mid = g
	var/list/cr = core255 ? list(core255[1] / 255, core255[2] / 255, core255[3] / 255) : EFXODeriveCore(mid)
	return list(list(EFXOTo255(base[1]), EFXOTo255(base[2]), EFXOTo255(base[3])), list(EFXOTo255(mid[1]), EFXOTo255(mid[2]), EFXOTo255(mid[3])),
		list(EFXOTo255(cr[1]), EFXOTo255(cr[2]), EFXOTo255(cr[3])), 0)

proc/EFXOOrder(list/pal)
	var/list/v = list(-(pal[1][1] + pal[2][1]) / 255, -(pal[1][2] + pal[2][2]) / 255, -(pal[1][3] + pal[2][3]) / 255)
	var/list/o = list(1, 2, 3)
	for(var/i = 2 to 3)
		var/j = i
		while(j > 1 && v[o[j]] < v[o[j - 1]])
			o.Swap(j, j - 1)
			j--
	return o

proc/EFXORampAdd(I, list/pal)
	var/s1 = EFXOSstep(0, 0.5, I)
	var/s2 = EFXOSstep(0.45, 1, I)
	var/list/col = list(0, 0, 0)
	for(var/i = 1 to 3)
		var/cb = pal[1][i] / 255
		var/cm = pal[2][i] / 255
		var/cc = pal[3][i] / 255
		var/cv = cb + (cm - cb) * s1
		col[i] = cv + (cc - cv) * s2
	var/list/out = list(0, 0, 0)
	if(pal[4])
		for(var/i = 1 to 3)
			out[i] = clamp(col[i] * 1.5 * I ** 1.5, 0, 1)
		return out
	var/list/o = EFXOOrder(pal)
	out[o[1]] = clamp(col[o[1]] * 1.5 * I, 0, 1)
	out[o[2]] = clamp(col[o[2]] * 1.5 * I ** 1.5, 0, 1)
	out[o[3]] = clamp(col[o[3]] * I ** 2.5, 0, 1)
	return out

proc/EFXOLum3(list/c)
	return 0.2126 * c[1] + 0.7152 * c[2] + 0.0722 * c[3]

proc/EFXOMine(ws, nv, list/ramp, list/pal)
	var/calm = 1 - 0.75 * EFXOSstep(0.55, 0.95, ws)
	var/I = clamp(0.5 + 0.5 * ws + 0.5 * calm * (nv - 0.5), 0, 1)
	var/m = 1 + 0.55 * calm * (nv - 0.5)
	var/list/edge = ramp[2]
	var/list/core = ramp[3]
	var/wc = clamp(ws, 0, 1)
	var/list/ca = list(clamp(edge[1] + wc * (core[1] - edge[1]), 0, 1), clamp(edge[2] + wc * (core[2] - edge[2]), 0, 1), clamp(edge[3] + wc * (core[3] - edge[3]), 0, 1))
	var/ya = EFXOLum3(ca)
	var/t = ya * m
	var/list/gr = EFXORampAdd(I, pal)
	var/mx = max(gr[1], gr[2], gr[3], 0.0001)
	var/list/hu = list(gr[1] / mx, gr[2] / mx, gr[3] / mx)
	var/yg = max(EFXOLum3(hu), 0.001)
	var/yt = max(ya, 0.001)
	var/list/out = list(0, 0, 0)
	for(var/i = 1 to 3)
		var/g = clamp(hu[i] / yg * t, 0, 1)
		var/c2 = clamp(ca[i] * (t / yt), 0, 1)
		out[i] = c2 + 0.6 * (g - c2)
	return out

proc/EFXOFitMatrix(key, list/C255, list/core255, list/glow255, list/subpal)
	var/ck = "[key]|[jointext(C255, ",")]|[core255 ? jointext(core255, ",") : "-"]|[glow255 ? jointext(glow255, ",") : "-"][subpal ? "|sub" : ""]"
	var/list/hit = EFXO_FITCACHE[ck]
	if(hit) return hit
	var/list/F = EFXO_FIT[key]
	if(!F) return null
	var/n = F[1]
	var/list/ramp = BeamFXRamp(C255, core255, glow255)
	var/list/pal = subpal ? subpal : EFXOPalette(C255, core255, glow255)
	var/list/co = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	for(var/s = 1 to n)
		var/list/T = EFXOMine(F[1 + s], F[1 + n + s], ramp, pal)
		for(var/r = 0 to 3)
			var/p = F[1 + 2 * n + r * n + s]
			co[r * 3 + 1] += p * T[1]
			co[r * 3 + 2] += p * T[2]
			co[r * 3 + 3] += p * T[3]
	var/list/M = list(co[1], co[2], co[3], 0, co[4], co[5], co[6], 0, co[7], co[8], co[9], 0, 0, 0, 0, 1, co[10], co[11], co[12], 0)
	EFXO_FITCACHE[ck] = M
	if(EFXO_FITCACHE.len > 512) EFXO_FITCACHE.Cut(1, 2)
	return M

/datum/energyfx_orbcolors
	var/list/main255
	var/list/core255
	var/list/glow255
	var/gray = 0
	var/bright = 1
	var/anchor = 0
	var/canon = 0
	var/sub = 0
	var/list/ramp
	var/list/pal

/datum/energyfx_orbcolors/proc/Setup(obj/Skills/Z, datum/energyfx_row/R)
	var/list/ex = R ? R.extra : null
	canon = ex && ex["canon"]
	var/main = Z ? Z.EnergyColorMain : null
	var/core = Z ? Z.EnergyColorCore : null
	var/glow = Z ? Z.EnergyColorGlow : null
	if(canon)
		main = R ? R.def_main : null
		core = R ? R.def_core : null
		glow = R ? R.def_glow : null
	else if(!main)
		main = R ? R.def_main : null
	sub = !canon && EnergyFXIsSub(main)
	main255 = EnergyFXSlotRGB(main, 158)
	core255 = EnergyFXSlotRGB(core, 255)
	glow255 = EnergyFXSlotRGB(glow, 158)
	if(!main255) main255 = list(0, 0, 0)
	gray = !canon && !sub && EFXOGrayRule(main255)
	if(gray)
		var/lum = EFXOLum3(list(main255[1] / 255, main255[2] / 255, main255[3] / 255))
		bright = (lum < 0.03) ? 1 : max(main255[1], main255[2], main255[3]) / 255
	var/list/an = ex ? ex["anchor"] : null
	anchor = canon || (!sub && an && EFXOSameRGB(main255, BeamFXHexRGB(an[1])) && EFXOSameRGB(core255, BeamFXHexRGB(an[2])) && EFXOSameRGB(glow255, BeamFXHexRGB(an[3])))
	ramp = BeamFXRamp(gray ? list(153, 153, 153) : main255, core255, glow255)
	pal = sub ? EFXOSubPalette(main255, core255, glow255) : EFXOPalette(main255, core255, glow255)

/datum/energyfx_orbcolors/proc/Body(key)
	if(anchor || gray || canon) return null
	return EFXOFitMatrix(key, main255, core255, glow255, sub ? pal : null)

/datum/energyfx_orbcolors/proc/Light(k = 1)
	return EFXOLightK(k, ramp[1], ramp[4])

/datum/energyfx_orbcolors/proc/BodyIK(ik)
	return gray ? "[ik]G" : ik

proc/EFXOSameRGB(list/a, list/b)
	if(!a || !b) return !a && !b
	return a[1] == b[1] && a[2] == b[2] && a[3] == b[3]

/datum/energyfx_orbs/proc/PredictContact(datum/energyfx_orbshot/O, k, rad = 16)
	var/obj/Skills/Projectile/_Projectile/P = O.P
	if(!P || !P.loc || isnull(O.k_launch) || O.hits.len || !isnull(O.vars_["pred"]) || !ismob(P.Homing) || P.vhb_w <= 0) return
	var/list/a = O.GetP(k)
	var/list/b = O.HasP(k - 1) ? O.pk[k] : null
	if(!a || !b) return
	var/mob/T = P.Homing
	if(T.proj_immune_until > world.time + 2 * world.tick_lag || T.Airborne || !T.density) return
	var/list/B = BodyInkRectL(BodyInkProbe(T))
	var/fl = 1 + (P.x - 1) * 32 + P.step_x + 16 + P.vhb_ox - P.vhb_w / 2
	var/fb = 1 + (P.y - 1) * 32 + P.step_y + 16 + P.vhb_oy - P.vhb_h / 2
	var/vx = a[1] - b[1]
	var/vy = a[2] - b[2]
	var/ns = max(1, P.pm_substep)
	var/hit1 = 0
	var/hit2 = 0
	for(var/s = 1 to 2 * ns)
		var/q = s / ns
		var/l = fl + vx * q
		var/bt = fb + vy * q
		if(l < B[1] + B[3] && B[1] < l + P.vhb_w && bt < B[2] + B[4] && B[2] < bt + P.vhb_h)
			if(s <= ns) hit1 = 1
			else hit2 = 1
	if(!hit1 && hit2)
		O.vars_["pred"] = k + 2
		if(parity) OL("E [O.idx] predict [k + 2]")

proc/EFXOE4Mats(key, list/pal)
	var/list/F = EFXO_E4[key]
	if(!F) return null
	var/list/y = list()
	for(var/i = 1 to 41)
		var/list/ra = EFXORampAdd(F[1 + i], pal)
		var/m = max(ra[1], ra[2], ra[3])
		y += m * EFXOSstep(0.25, 0.6, m)
	var/list/lam = list(0, 0, 0, 0)
	for(var/r = 0 to 3)
		var/acc = 0
		for(var/i = 1 to 41)
			acc += F[42 + r * 41 + i] * y[i]
		lam[r + 1] = acc
	var/list/out = list(pal[4] ? null : list(0, 0, 0, lam[1], 0, 0, 0, lam[2], 0, 0, 0, lam[3], 0, 0, 0, lam[4], 0, 0, 0, 0))
	var/list/o = pal[4] ? null : EFXOOrder(pal)
	for(var/k = 1 to 3)
		var/list/M = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		var/list/st = pal[k]
		if(!o)
			for(var/c = 1 to 3)
				M[4 + c] = 2.2 * st[c] / 255
		else
			for(var/r = 1 to 3)
				var/c2 = o[r]
				M[(r - 1) * 4 + c2] = 2.2 * st[c2] / 255
		out += list(M)
	return out

/datum/energyfx_orbsputter
	var/list/parts = list()
	var/ik = "TrackSputter"
	var/ncell = 9

/datum/energyfx_orbsputter/proc/Emit(datum/bfx_rng/G, t0, x, y, heading, n, Rh)
	for(var/i = 1 to n)
		var/back = heading + 180 + G.U(-85, 85)
		var/a0 = G.U(0, 360)
		var/v = G.U(50, 170)
		var/tj = G.U(0, 0.05)
		var/life = G.U(0.1, 0.26)
		var/sc = G.U(0.45, 0.95)
		var/rot = G.U(0, 360)
		var/spin = G.U(-600, 600)
		var/cell = G.RandRange(ncell)
		parts[++parts.len] = list(t0 + tj, x + cos(a0) * Rh * 0.8, y + sin(a0) * Rh * 0.8, cos(back) * v, sin(back) * v, life, sc, rot, spin, cell)

/datum/energyfx_orbsputter/proc/Sprites(datum/energyfx_orbs/S, list/out, t, pre, kind, list/lm)
	for(var/i = 1 to parts.len)
		var/list/p = parts[i]
		var/age = t - p[1]
		if(age < 0 || age >= p[6]) continue
		var/q = age / p[6]
		var/x = p[2] + p[4] * age * (1 - 0.5 * q)
		var/y = p[3] + p[5] * age * (1 - 0.5 * q)
		var/al = min(1, age / 0.02) * (1 - EFXOSstep(0.5, 1, q))
		var/sc = p[7] * (1 - 0.5 * q)
		S.Rec(out, "[pre][i]", kind, ik, "[p[10]]", x, y, p[8] + p[9] * age, sc, sc, al, lm, 0)

/datum/energyfx_orbsputter/proc/Alive(t)
	for(var/list/p in parts)
		if(t - p[1] < p[6]) return 1
	return 0

/datum/energyfx_orbs/tracking
	parent_type = /datum/energyfx_orbs/bigbang
	R_ = EFXO_TB_R
	conv_n = 0
	b_re = 48
	b_ground = "B3Ground48"
	bdir = "E"
	var/datum/energyfx_orbcolors/cols
	var/datum/energyfx_orbsputter/sput
	var/list/flick
	var/list/bm_body
	var/list/bm_wake

/datum/energyfx_orbs/tracking/Setup()
	cols = new
	cols.Setup(from, row)
	lm = cols.LM("hl")
	tlc = EFXOLitColor(cols)
	wake.L = EFXO_TB_WAKE_L
	wake.N = EFXO_TB_WAKE_N
	wake.n = EFXO_TB_WAKE_F
	wake.life40 = EFXO_TB_WAKE_LIFE40
	wake.ik = cols.BodyIK("TrackWake")
	wake.tbl = EFXO_TB_WAKE_TBL
	wake.col_body = cols.Body("tb_wake")
	bm_body = cols.Body("tb_heads")
	sput = new
	sput.ncell = EFXO_TB_NCELL
	if(cols.gray) b_ground = "B3Ground48G"

/datum/energyfx_orbs/tracking/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	var/datum/bfx_rng/G = Stream("flick")
	flick = list()
	for(var/i = 1 to 400)
		var/fs = G.U(0.86, 1.14)
		var/fl = G.U(0.75, 1.3)
		flick += list(list(fs, fl))
	return O

/datum/energyfx_orbs/tracking/PreBoom()
	b_dome = "B3E4_48TB"

/datum/energyfx_orbs/tracking/OnBoom()
	blast.e4 = b_dome
	blast.e4m = EFXOE4Mats(b_dome, cols.pal)
	blast.lm_flash = cols.LM("flash")
	blast.fl_kinds = list("XP", "XS", cols.LK("XL"))

/datum/energyfx_orbs/tracking/proc/PosT(datum/energyfx_orbshot/O, t, pre)
	if(pre)
		var/list/p0 = O.GetP(O.k_spawn)
		return p0 ? list(p0[1], p0[2], 31, fang) : null
	var/list/d = O.DrawnT(t)
	if(!d) return null
	return list(d[1], d[2], 31 * max(0, 1 - (t - O.k_launch * EFXO_TICK) / 0.2), HeadT(O, t))

/datum/energyfx_orbs/tracking/proc/PosK(datum/energyfx_orbshot/O, k)
	return PosT(O, k * EFXO_TICK, isnull(O.k_launch) || k < O.k_launch)

/datum/energyfx_orbs/tracking/proc/PosV(datum/energyfx_orbshot/O, v)
	return PosT(O, v / EFXO_FPS, isnull(O.k_launch) || EFXOTvLt(v, O.k_launch))

/datum/energyfx_orbs/tracking/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return
	Boom(O)
	if(!isnull(kb) && k >= kb) return
	if(!isnull(O.k_end) && k >= O.k_end) return
	var/tk = k * EFXO_TICK
	var/datum/bfx_rng/G = Stream("flick")
	if(!isnull(O.k_launch) && k >= O.k_launch + 1)
		var/list/c = PosK(O, k)
		var/list/cp = PosK(O, max(O.k_launch, k - 1))
		if(!c || !cp) return
		var/st = EFXOHyp(c[1] - cp[1], (c[2] + c[3]) - (cp[2] + cp[3]))
		var/ang = st > 0.000001 ? EFXOAtan2((c[2] + c[3]) - (cp[2] + cp[3]), c[1] - cp[1]) : c[4]
		wake.Spawn(k, c[1], c[2] + c[3], ang, st > 0.000001 ? st : 10)
		var/n = 3 + ((G.R() < 0.5) ? 1 : 0)
		sput.Emit(Stream("sput"), tk, c[1], c[2] + c[3], ang, n, R_)
	else if(k >= O.k_spawn && (isnull(O.k_launch) || k < O.k_launch))
		var/list/c2 = PosK(O, k)
		if(!c2) return
		var/hd = 90 + G.U(-60, 60)
		sput.Emit(Stream("sput"), tk, c2[1], c2[2] + c2[3], hd, 2, R_)
	PredictContact(O, k, R_ + 12)

/datum/energyfx_orbs/tracking/Q(fi)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return fi - (fi % 2)
	var/list/hl = list(list(2 * O.k_spawn + 2, 4))
	var/list/ones = list()
	if(!isnull(O.k_launch)) hl += list(list(2 * O.k_launch + 1, 3))
	if(!isnull(kb))
		hl += list(list(2 * kb - 3, 3))
		ones += list(list(2 * kb, 2 * kb + 5))
	else if(!isnull(O.vars_["pred"]))
		hl += list(list(2 * O.vars_["pred"] - 3, 3))
	return Holds(fi, hl, ones)

/datum/energyfx_orbs/tracking/HitNow(datum/energyfx_orbshot/O, k)
	Boom(O)

/datum/energyfx_orbs/tracking/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return out
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	if(blast)
		blast.Scorch(src, out, d, "b")
		blast.Ground(src, out, d, "b", cols.LK("GL"))
	wake.Sprites(src, out, v, "w", "NP", cols.LK("ML"), lm, 4.8)
	if(blast)
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b", cols.LK("XL"))
		out += sm
	if(EFXOTvGe(v, O.k_spawn) && (isnull(kb) || EFXOTvLt(v, kb)))
		var/list/p = PosV(O, v)
		if(p)
			var/dj = floor((v - 2 * O.k_spawn) / 2)
			var/list/ff = flick[BeamFXMod(dj, 400) + 1]
			var/g = EFXOEaseOut(min(1, (tv - O.k_spawn * EFXO_TICK) / 0.1))
			var/sc = (0.45 + 0.55 * g) * ff[1]
			var/fi_ = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_TB_NF)
			var/st
			var/ang
			var/x = p[1]
			var/y = p[2] + p[3]
			if(isnull(O.k_launch) || EFXOAgeM(v, O.k_launch, "lt", 0.05))
				st = "rest_[fi_]"
				ang = 0
			else
				st = "fly_[fi_]"
				var/list/pp = PosT(O, max(O.k_launch * EFXO_TICK, tv - 0.02), 0)
				if(pp && abs(x - pp[1]) + abs(y - pp[2] - pp[3]) > 0.001)
					ang = EFXOAtan2(y - (pp[2] + pp[3]), x - pp[1])
				else
					ang = p[4]
			Rec(out, "bp", "FP", cols.BodyIK("TrackBomb"), "[st]_0", x, y, ang, sc, sc, 1, bm_body, 5)
			Rec(out, "bl", cols.LK("FL"), cols.BodyIK("TrackBomb"), "[st]_1", x, y, ang, sc, sc, min(1, ff[2]), lm, 0)
			var/list/bl_ = out[out.len]
			bl_.len = 14
			bl_[14] = ff[2]
	sput.Sprites(src, out, t, "s", cols.LK("FL"), lm)
	if(blast)
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b", cols.LK("XL"))
	return out

/datum/energyfx_orbs/tracking/Busy(k)
	var/v = 2 * k + 1
	if(wake.Alive(v) || sput.Alive(v / EFXO_FPS)) return 1
	if(blast && blast.Alive(v / EFXO_FPS, v - 2 * kb)) return 1
	return 0

proc/EFXOLitColor(datum/energyfx_orbcolors/C)
	var/list/m = C.gray ? list(0.6, 0.6, 0.6) : list(C.main255[1] / 255, C.main255[2] / 255, C.main255[3] / 255)
	var/list/b = BeamFXWarmEdge(m)
	return list(clamp(b[1] * 0.85 + 0.15, 0, 1), clamp(b[2] * 0.85 + 0.15, 0, 1), clamp(b[3] * 0.85 + 0.15, 0, 1))

#define EFXO_GLG_PLANE 60
#define EFXO_MLG_PLANE 61
#define EFXO_ULG_PLANE 62
#define EFXO_FLG_PLANE 63
#define EFXO_XLG_PLANE 64
#define EFXO_GLG_VEIL 6.6162
#define EFXO_GLG_RELAY 6.6165
#define EFXO_MLG_VEIL 6.6336
#define EFXO_MLG_RELAY 6.6337
#define EFXO_ULG_VEIL 6.6442
#define EFXO_ULG_RELAY 6.6445
#define EFXO_FLG_VEIL 6.6513
#define EFXO_FLG_RELAY 6.6514
#define EFXO_XLG_VEIL 6.6562
#define EFXO_XLG_RELAY 6.6564
#define EFXO_GLS 2
#define EFXO_FD_PLANE 65
#define EFXO_FC_PLANE 66

/obj/energyfx/orb/glg
	plane = EFXO_GLG_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/mlg
	plane = EFXO_MLG_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/ulg
	plane = EFXO_ULG_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/flg
	plane = EFXO_FLG_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/xlg
	plane = EFXO_XLG_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx_master/orbgray
	var/masked = 0
/obj/energyfx_master/orbgray/New()
	..()
	filters = filter(type = "blur", size = glob ? glob.ENERGYFX_BLUR : 1.5)
/obj/energyfx_master/orbgray/glg
	plane = EFXO_GLG_PLANE
	render_target = "*energyfx_orb_glg"
/obj/energyfx_master/orbgray/mlg
	plane = EFXO_MLG_PLANE
	render_target = "*energyfx_orb_mlg"
/obj/energyfx_master/orbgray/ulg
	plane = EFXO_ULG_PLANE
	render_target = "*energyfx_orb_ulg"
/obj/energyfx_master/orbgray/flg
	plane = EFXO_FLG_PLANE
	render_target = "*energyfx_orb_flg"
/obj/energyfx_master/orbgray/xlg
	plane = EFXO_XLG_PLANE
	render_target = "*energyfx_orb_xlg"
/obj/energyfx_master/orbgray/fd
	plane = EFXO_FD_PLANE
	render_target = "*efxo_fdamp"
/obj/energyfx_master/orbgray/fd/New()
	..()
	filters = list(filter(type = "blur", size = ENERGYFX_DAMP_BLUR), filter(type = "color", color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ENERGYFX_GRAY_DAMP, 0, 0, 0, 0)))
/obj/energyfx_master/orbgray/fc
	plane = EFXO_FC_PLANE
	render_target = "*efxo_fcov"
/obj/energyfx_master/orbgray/fc/New()
	..()
	filters = list(filter(type = "blur", size = ENERGYFX_COV_BLUR), filter(type = "color", color = EnergyFXCovM1()), filter(type = "color", color = EnergyFXCovM2()))

proc/EFXOGrayVeilM1()
	var/k = EFXO_GLS / ENERGYFX_GRAY_LSCALE
	var/i1 = k / (ENERGYFX_VEIL_HI1 - ENERGYFX_VEIL_LO1)
	var/i2 = k / (ENERGYFX_VEIL_HI2 - ENERGYFX_VEIL_LO2)
	var/i3 = k / (ENERGYFX_VEIL_HI3 - ENERGYFX_VEIL_LO3)
	var/c1 = -ENERGYFX_VEIL_LO1 / (ENERGYFX_VEIL_HI1 - ENERGYFX_VEIL_LO1)
	var/c2 = -ENERGYFX_VEIL_LO2 / (ENERGYFX_VEIL_HI2 - ENERGYFX_VEIL_LO2)
	var/c3 = -ENERGYFX_VEIL_LO3 / (ENERGYFX_VEIL_HI3 - ENERGYFX_VEIL_LO3)
	return list(0.2126 * i1, 0.2126 * i2, 0.2126 * i3, 0, 0.7152 * i1, 0.7152 * i2, 0.7152 * i3, 0, 0.0722 * i1, 0.0722 * i2, 0.0722 * i3, 0, 0, 0, 0, 0, c1, c2, c3, 1)

proc/EFXOGrayKneeM()
	return list(EFXO_GLS, 0, 0, 0, 0, EFXO_GLS, 0, 0, 0, 0, EFXO_GLS, 0, 0, 0, 0, 1, -ENERGYFX_GRAY_KNEE, -ENERGYFX_GRAY_KNEE, -ENERGYFX_GRAY_KNEE, 0)

/obj/energyfx_relay/orbgray
	var/masked = 0
	var/front = 0
	var/veil = 0
/obj/energyfx_relay/orbgray/New()
	..()
	var/list/f = list()
	if(veil)
		f += filter(type = "color", color = EFXOGrayVeilM1())
		f += filter(type = "color", color = EnergyFXVeilM2())
		if(masked) f += filter(type = "alpha", render_source = "*energyfx_cov", flags = MASK_INVERSE)
		if(front) f += filter(type = "alpha", render_source = "*efxo_fcov", flags = MASK_INVERSE)
	else
		if(masked) f += filter(type = "layer", render_source = "*energyfx_damp", blend_mode = BLEND_MULTIPLY)
		if(front) f += filter(type = "layer", render_source = "*efxo_fdamp", blend_mode = BLEND_MULTIPLY)
		f += filter(type = "color", color = EFXOGrayKneeM())
	if(masked) f += filter(type = "alpha", render_source = "*energyfx_locc", flags = MASK_INVERSE)
	filters = f
/obj/energyfx_relay/orbgray/glg_v
	layer = EFXO_GLG_VEIL
	render_source = "*energyfx_orb_glg"
	masked = 1
	veil = 1
/obj/energyfx_relay/orbgray/glg
	layer = EFXO_GLG_RELAY
	render_source = "*energyfx_orb_glg"
	blend_mode = BLEND_ADD
	masked = 1
/obj/energyfx_relay/orbgray/mlg_v
	layer = EFXO_MLG_VEIL
	render_source = "*energyfx_orb_mlg"
	masked = 1
	veil = 1
/obj/energyfx_relay/orbgray/mlg
	layer = EFXO_MLG_RELAY
	render_source = "*energyfx_orb_mlg"
	blend_mode = BLEND_ADD
	masked = 1
/obj/energyfx_relay/orbgray/ulg_v
	layer = EFXO_ULG_VEIL
	render_source = "*energyfx_orb_ulg"
	veil = 1
/obj/energyfx_relay/orbgray/ulg
	layer = EFXO_ULG_RELAY
	render_source = "*energyfx_orb_ulg"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orbgray/flg_v
	layer = EFXO_FLG_VEIL
	render_source = "*energyfx_orb_flg"
	veil = 1
	front = 1
/obj/energyfx_relay/orbgray/flg
	layer = EFXO_FLG_RELAY
	render_source = "*energyfx_orb_flg"
	blend_mode = BLEND_ADD
	front = 1
/obj/energyfx_relay/orbgray/xlg_v
	layer = EFXO_XLG_VEIL
	render_source = "*energyfx_orb_xlg"
	veil = 1
/obj/energyfx_relay/orbgray/xlg
	layer = EFXO_XLG_RELAY
	render_source = "*energyfx_orb_xlg"
	blend_mode = BLEND_ADD

proc/EFXOGrayLightK(tag)
	switch(tag)
		if("flash") return ENERGYFX_GRAY_FLASH_K
		if("hl") return ENERGYFX_GRAY_HEAD_K
		if("wl") return ENERGYFX_GRAY_WL_K
	return 1

/datum/energyfx_orbcolors/proc/LK(kind)
	return gray ? "[kind]g" : kind

/datum/energyfx_orbcolors/proc/LM(tag = "hl", al = 1)
	var/k = (tag == "accent" || tag == "wl") ? EFXOCoolK(al) : 1
	if(!gray) return Light(k)
	var/list/lc = ramp[1]
	var/list/lcore = ramp[4]
	var/g = ENERGYFX_GRAY_LSCALE * bright / EFXO_GLS * EFXOGrayLightK(tag)
	return list((lcore[1] - lc[1]) * k * g, (lcore[2] - lc[2]) * k * g, (lcore[3] - lc[3]) * k * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)

proc/EFXONovaBolts(datum/energyfx_orbs/S, list/out, datum/bfx_rng/G, x, y, sc, Rr, kind, list/lm)
	var/n = list(1, 1, 2)[G.RandRange(3) + 1]
	for(var/i = 1 to n)
		var/a = G.U(0, 360)
		var/r = G.U(0, 0.32) * Rr * sc
		var/b = G.U(0, 360)
		var/k = G.U(0.7, 1.1) * sc * Rr / 34
		var/st = G.RandRange(4)
		var/al = G.U(0.55, 1)
		S.Rec(out, "nb[i]", kind, "NovaBolt", "[st]", x + cos(b) * r, y + sin(b) * r, a, k, k, al, lm, 0)

/datum/energyfx_orbs/nova
	parent_type = /datum/energyfx_orbs/bigbang
	R_ = EFXO_DN_R
	conv_n = 3
	b_re = 32
	b_g0 = 0.9
	b_ground = "B3Ground32"
	bdir = "W"
	var/datum/energyfx_orbcolors/cols
	var/list/bm_body
	var/list/bolt_cache = list()

/datum/energyfx_orbs/nova/Setup()
	cols = new
	cols.Setup(from, row)
	lm = cols.LM("hl")
	tlc = EFXOLitColor(cols)
	wake.L = EFXO_DN_WAKE_L
	wake.N = EFXO_DN_WAKE_N
	wake.n = EFXO_DN_WAKE_F
	wake.life40 = EFXO_DN_WAKE_LIFE40
	wake.ik = cols.BodyIK("NovaWake")
	wake.tbl = EFXO_DN_WAKE_TBL
	wake.col_body = cols.Body("dn_wake")
	bm_body = cols.Body("dn_heads")
	if(cols.gray) b_ground = "B3Ground32G"

/datum/energyfx_orbs/nova/PreBoom()
	b_dome = "B3E4_32DN"

/datum/energyfx_orbs/nova/OnBoom()
	blast.e4 = b_dome
	blast.e4m = EFXOE4Mats(b_dome, cols.pal)
	blast.lm_flash = cols.LM("flash")
	blast.fl_kinds = list("XP", "XS", cols.LK("XL"))

/datum/energyfx_orbs/nova/Scale(datum/energyfx_orbshot/O, t)
	return 0.05 + 0.95 * EFXOSstep(0, 1, (t - O.k_spawn * EFXO_TICK) / Tch(O))

/datum/energyfx_orbs/nova/proc/PosT(datum/energyfx_orbshot/O, t, pre)
	var/list/p0 = O.GetP(O.k_spawn)
	if(pre)
		if(!p0) return null
		var/sc = Scale(O, t)
		return list(p0[1], p0[2], EFXO_DN_HOVER0 + R_ * sc, sc)
	var/list/d = O.DrawnT(t)
	if(!d) return null
	var/a = t - O.k_launch * EFXO_TICK
	var/zq = min(1, a / 0.2)
	return list(d[1], d[2], (EFXO_DN_HOVER0 + R_) * (1 - zq * zq), 1)

/datum/energyfx_orbs/nova/proc/PosK(datum/energyfx_orbshot/O, k)
	return PosT(O, k * EFXO_TICK, isnull(O.k_launch) || k < O.k_launch)

/datum/energyfx_orbs/nova/proc/PosV(datum/energyfx_orbshot/O, v)
	return PosT(O, v / EFXO_FPS, isnull(O.k_launch) || EFXOTvLt(v, O.k_launch))

/datum/energyfx_orbs/nova/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return
	Boom(O)
	var/kl = KLaunch(O)
	if(k >= O.k_spawn && !isnull(kl) && EFXOMinusLt(k, kl, 2))
		conv.Emit(Stream("conv"), k * EFXO_TICK, 3, R_)
	if(!isnull(O.k_launch) && k >= O.k_launch + 1 && (isnull(kb) || k < kb))
		var/list/c = PosK(O, k)
		var/list/cp = PosK(O, max(O.k_launch, k - 1))
		if(c && cp)
			var/st = EFXOHyp(c[1] - cp[1], (c[2] + c[3]) - (cp[2] + cp[3]))
			var/ang = st > 0.000001 ? EFXOAtan2((c[2] + c[3]) - (cp[2] + cp[3]), c[1] - cp[1]) : 0
			wake.Spawn(k, c[1], c[2] + c[3], ang, st > 0.000001 ? st : 10)

/datum/energyfx_orbs/nova/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return out
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	if(blast)
		blast.Scorch(src, out, d, "b")
		blast.Ground(src, out, d, "b", cols.LK("GL"))
	wake.Sprites(src, out, v, "w", "UP", cols.LK("UL"), lm, 4.8)
	if(blast)
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b", cols.LK("XL"))
		out += sm
	if(EFXOTvGe(v, O.k_spawn) && (isnull(kb) || EFXOTvLt(v, kb)))
		var/list/p = PosV(O, v)
		if(p)
			var/x = p[1]
			var/y = p[2] + p[3]
			var/sc = p[4]
			var/fi_ = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_DN_NF)
			var/pre = isnull(O.k_launch) || EFXOTvLt(v, O.k_launch)
			var/st = pre ? "rest_[fi_]" : "fly_[fi_]"
			var/ang = 0
			if(!pre)
				var/list/pp = PosT(O, max(O.k_launch * EFXO_TICK, tv - 0.02), 0)
				if(pp) ang = EFXOAtan2(y - (pp[2] + pp[3]), x - pp[1])
			Rec(out, "sp", "FP", cols.BodyIK("NovaSun"), "[st]_0", x, y, ang, sc, sc, 1, bm_body, 5)
			Rec(out, "sl", cols.LK("FL"), cols.BodyIK("NovaSun"), "[st]_1", x, y, ang, sc, sc, 1, lm, 0)
			if(sc > 0.5)
				var/list/bl = bolt_cache["[v]"]
				if(!bl)
					bl = list()
					EFXONovaBolts(src, bl, Stream("bolt[v]"), x, y, sc, R_, cols.LK("FL"), lm)
					bolt_cache["[v]"] = bl
				out += bl
			if(pre)
				conv.Sprites(src, out, tv, x, y, R_ * sc * 0.95, "c", cols.LK("FL"), lm)
				var/ts = O.k_spawn * EFXO_TICK
				var/ri = 0
				for(var/tr in list(ts + 0.03, ts + 0.2))
					ri++
					var/a_ = (tv - tr) / 0.18
					if(a_ >= 0 && a_ < 1)
						var/rr = (1.7 - 0.7 * a_ * a_) * R_ * sc + 2
						var/k = rr / 31
						Rec(out, "rg[ri]", cols.LK("FL"), "NovaMisc", "ring", x, y, 0, k, k, 0.7 * min(1, a_ / 0.2) * (1 - EFXOSstep(0.7, 1, a_)), lm, 0)
				if(EFXOAgeF(v, O.k_spawn, "lt", 0.1))
					var/q = (tv - ts) / 0.1
					Rec(out, "st", cols.LK("FL"), "NovaMisc", "star", x, y, 0, 1.2 + 0.6 * q, 1.2 + 0.6 * q, 1 - q, cols.LM("flash"), 0)
			var/kl = KLaunch(O)
			if(!isnull(kl))
				var/ga = tv - (kl * EFXO_TICK - 0.08)
				if(ga >= 0 && ga < 0.16)
					var/q2 = ga / 0.16
					Rec(out, "gl", cols.LK("FL"), "NovaMisc", "glint", x, y, 0, (1.4 + 1.2 * q2) * R_ / 34, 1, 1 - q2 * q2, cols.LM("flash"), 0)
	if(blast)
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b", cols.LK("XL"))
	return out

proc/EFXOAgeTS(kk, k, op, c)
	var/o = kk - k
	var/oc = round(c * 20, 1)
	if(o != oc) return (op == "lt") ? (o < oc) : (o >= oc)
	return EFXOTblBit(EFXO_AGE["T[op][c]"], k)

/obj/energyfx/orb/g21
	plane = ENERGYFX_GLIGHT_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx_twin/orbdamp
	appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER
/obj/energyfx_twin/orbfdamp
	plane = EFXO_FD_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER
/obj/energyfx_twin/orbfcov
	plane = EFXO_FC_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_TOGETHER

/obj/energyfx/var/tmp/obj/energyfx_twin/efxo_cov
/obj/energyfx/var/tmp/efxo_kf

proc/EFXOFree(obj/energyfx/O)
	if(!O) return
	EFXOUntwin(O)
	EnergyFXFree(O)

proc/EFXOUntwin(obj/energyfx/O)
	if(O.efx_damp)
		O.vis_contents -= O.efx_damp
		O.efx_damp = null
	if(O.efxo_cov)
		O.vis_contents -= O.efxo_cov
		O.efxo_cov = null

/datum/energyfx_orbembers
	var/list/parts = list()
	var/ik = "PillarEmber"

/datum/energyfx_orbembers/proc/Emit(datum/bfx_rng/G, t0, x, y, n)
	for(var/i = 1 to n)
		var/tj = G.U(0, 0.05)
		var/dx = G.U(-14, 14)
		var/dy = G.U(0, 20)
		var/vy = G.U(120, 320)
		var/vx = G.U(-20, 20)
		var/life = G.U(0.3, 0.6)
		var/sc = G.U(0.35, 0.75)
		var/ang = 90 + G.U(-6, 6)
		parts[++parts.len] = list(t0 + tj, x + dx, y + dy, vx, vy, life, sc, ang)

/datum/energyfx_orbembers/proc/Sprites(datum/energyfx_orbs/S, list/out, t, pre, kind, list/lm)
	for(var/i = 1 to parts.len)
		var/list/p = parts[i]
		var/age = t - p[1]
		if(age < 0 || age >= p[6]) continue
		var/q = age / p[6]
		var/al = min(1, age / 0.04) * (1 - EFXOSstep(0.5, 1, q))
		S.Rec(out, "[pre][i]", kind, ik, "x", p[2] + p[4] * age, p[3] + p[5] * age * (1 - 0.35 * q), p[8] - 90, p[7], p[7] * (1 + 0.6 * (1 - q)), al, lm, 0)

/datum/energyfx_orbembers/proc/Alive(t)
	for(var/list/p in parts)
		if(t - p[1] < p[6]) return 1
	return 0

/datum/energyfx_orbs/pillar
	var/datum/energyfx_orbcolors/cols
	var/list/bm_mine
	var/list/bm_col
	var/datum/energyfx_orbstar4/star
	var/datum/energyfx_orbsparkles/spk
	var/datum/energyfx_orbembers/emb
	var/mx
	var/my
	var/gy
	var/kf
	var/ke
	var/mob/struck
	var/burst = 0
	var/list/lm
	var/list/tlc

/datum/energyfx_orbs/pillar/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	cols = new
	cols.Setup(from, row)
	lm = cols.LM("hl")
	tlc = EFXOLitColor(cols)
	bm_mine = cols.Body("plm_heads")
	bm_col = cols.Body("pl_column")
	spk = new
	spk.ik = "JechtStars"
	spk.sc_lo = 0.3
	spk.sc_hi = 0.55
	emb = new
	return O

/datum/energyfx_orbs/pillar/proc/Shot()
	return shots.len ? shots[1] : null

/datum/energyfx_orbs/pillar/proc/Anchor(datum/energyfx_orbshot/O)
	if(isnull(mx))
		var/list/p = O.GetP(O.k_spawn)
		if(!p) return 0
		mx = p[1]
		my = p[2]
		gy = my - 6
		star = new(Stream("star"), mx, gy + 4, 0.55, EFXO_SB_RAYS_OX)
	return 1

/datum/energyfx_orbs/pillar/OnFuse(datum/energyfx_orbshot/O, atom/target)
	..()
	if(isnull(kf))
		kf = O.k_fuse
		if(ismob(target)) struck = target

/datum/energyfx_orbs/pillar/proc/Erupt(datum/energyfx_orbshot/O)
	if(!isnull(ke)) return
	if(O.hits.len)
		var/list/e = O.hits[1]
		ke = e[1]
		if(!struck && ismob(e[2])) struck = e[2]
	else if(!isnull(O.k_end))
		ke = O.k_end
	if(!isnull(ke) && isnull(kf)) kf = ke - 2
	if(!isnull(ke) && parity) OL("E [O.idx] erupt [ke]")

/datum/energyfx_orbs/pillar/HitNow(datum/energyfx_orbshot/O, k)
	Erupt(O)

/datum/energyfx_orbs/pillar/proc/KE()
	if(!isnull(ke)) return ke
	if(!isnull(kf)) return kf + 2
	return null

/datum/energyfx_orbs/pillar/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O || !Anchor(O)) return
	Erupt(O)
	if(isnull(ke)) return
	if(k >= ke && EFXOAgeTS(k, ke, "lt", 0.6))
		emb.Emit(Stream("emb"), k * EFXO_TICK, mx, gy, EFXOAgeTS(k, ke, "lt", 0.15) ? 5 : 2)
	if(!burst && k >= ke)
		burst = 1
		spk.Burst(Stream("spk"), ke * EFXO_TICK, mx, gy + 4, 14, 10)

/datum/energyfx_orbs/pillar/Q(fi)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return fi - (fi % 2)
	var/list/hl = list(list(2 * O.k_spawn + 6, 4))
	var/list/ones = list()
	var/k2 = KE()
	if(!isnull(k2))
		ones += list(list(2 * k2 - 4, 2 * k2 + 5))
		hl += list(list(2 * k2 + 5, 6))
	return Holds(fi, hl, ones)

/datum/energyfx_orbs/pillar/proc/ColIndex(d)
	if(d < 0) return null
	if(d < EFXO_PL_RISE) return d
	var/d2 = d - EFXO_PL_RISE
	if(d2 < EFXO_PL_PEAK) return EFXO_PL_RISE
	var/j = EFXO_PL_RISE + 1 + floor((d2 - EFXO_PL_PEAK) / 2)
	return (j < EFXO_PL_NCOL) ? j : null

/datum/energyfx_orbs/pillar/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O || !Anchor(O)) return out
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/ts = O.k_spawn * EFXO_TICK
	var/gk = cols.gray ? "MLg" : "GL"
	var/glm = lm
	if(EFXOTvGe(v, O.k_spawn) && (isnull(kf) || EFXOAgeM(v, kf, "lt", 0.1)))
		var/fi_ = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_SB_NF)
		var/z = 22 + 1.5 * sin(360 * (tv - ts) * 0.8)
		var/sc = 1
		var/trig = !isnull(kf) && EFXOTvGe(v, kf)
		if(trig)
			var/q = (tv - kf * EFXO_TICK) / 0.1
			z = 22 * (1 - q * q)
			sc = 1 + 0.3 * q
		Rec(out, "mp", "FP", cols.BodyIK("PillarMine"), "rest_[fi_]_0", mx, my + z, 0, sc, sc, 1, bm_mine, 5)
		Rec(out, "ml", cols.LK("FL"), cols.BodyIK("PillarMine"), "rest_[fi_]_1", mx, my + z, 0, sc, sc, 1, lm, 0)
		if(!trig)
			Rec(out, "mr", cols.LK("FL"), "PillarMRing", "0", mx, my + z, -18, 1, 0.3, 1, lm, 0)
		var/o = v - 2 * O.k_spawn
		var/ph = EFXOFMod(tv - ts, 0.8) / 0.8
		var/pi = (O.k_spawn < 8 && o >= 0 && o < 400) ? text2ascii(EFXO_PL_PULSE, O.k_spawn * 400 + o + 1) - 48 : min(5, floor(ph * 6))
		if(pi == 0 && ph > 0.5) ph = max(0, ph - 1)
		else if(pi == 5 && ph < 0.5) ph = min(1, ph + 1)
		Rec(out, "pu", gk, "PillarPulse", "[pi]", mx, gy, 0, 1, 0.5, 1 - ph, glm, 0)
		if(trig)
			Rec(out, "ms", cols.LK("FL"), "JechtSoft", "x", mx, my + z, 0, 0.22, 0.22, 0.9, cols.LM("flash"), 0)
	if(!isnull(ke))
		var/d = v - 2 * ke
		if(d >= 0)
			var/di = (d >= 6) ? min(EFXO_PL_NDECAL - 1, max(0, floor((d - 6) / 4))) : 0
			if(di < EFXO_PL_NDECAL - 1)
				if(cols.gray)
					Rec(out, "dp", "MP", "PillarDecalG", "[di]", mx, gy, 0, 1, 0.55, 1, list(cols.bright, 0, 0, 0, 0, cols.bright, 0, 0, 0, 0, cols.bright, 0, 0, 0, 0, 1, 0, 0, 0, 0), 1)
				else
					Rec(out, "dp", "GP", "PillarDecal", "[di]_0", mx, gy, 0, 1, 0.55, 1, EFXOHeatMatrix(cols, 1), 1)
				Rec(out, "dl", gk, cols.gray ? "PillarDecalLG" : "PillarDecal", "[di]_1", mx, gy, 0, 1, 0.55, 1, cols.LM("accent", 1), 0)
			var/ri = (d < 4) ? d : 4 + floor((d - 4) / 2)
			if(ri < EFXO_PL_NSPIKY)
				Rec(out, "rs", gk, cols.BodyIK("PillarRings"), "spiky_[ri]", mx, gy, 0, 1, 0.55, 1, glm, 0)
			if(d < 4 && d < EFXO_PL_NGLOWH)
				Rec(out, "rg", gk, cols.BodyIK("PillarRings"), "glowh_[d]", mx, gy, 0, 1, 0.55, 1, glm, 0)
			var/fl = (d <= 1) ? 1 : max(0, 1 - (d - 1) / 4)
			if(fl > 0.002)
				Rec(out, "ef", cols.LK("FL"), "JechtSoft", "x", mx, gy + 6, 0, 0.4, 0.3, fl, cols.LM("flash"), 0)
				star.Sprites(src, out, EFXO_PL_STAR[min(d, 5) + 1], fl, "es", cols.LK("FL"), lm)
			var/ci = ColIndex(d)
			if(!isnull(ci))
				Rec(out, "cp", "FP", cols.BodyIK("PillarColumn"), "frames_[ci]_0", mx, gy + EFXO_PL_OY, 0, 1, 1, 1, bm_col, 5)
				Rec(out, "cl", cols.LK("FL"), cols.BodyIK("PillarColumn"), "frames_[ci]_1", mx, gy + EFXO_PL_OY, 0, 1, 1, 1, lm, 0)
	emb.Sprites(src, out, t, "e", cols.LK("FL"), lm)
	spk.Sprites(src, out, t, "k", cols.LK("FL"), lm)
	return out

/datum/energyfx_orbs/pillar/proc/KD(v)
	if(isnull(ke) || !EFXOTvGe(v, ke)) return 0
	var/a = v / EFXO_FPS - ke * EFXO_TICK
	return EFXOEaseOut(a / 0.1) * max(0, 1 - max(0, a - 0.5) / 0.4)

/datum/energyfx_orbs/pillar/Chars(k)
	var/mob/T = struck
	if(!T)
		var/datum/energyfx_orbshot/O0 = shots.len ? shots[1] : null
		var/obj/Skills/Projectile/_Projectile/P = O0 ? O0.P : null
		var/mob/c = caster
		if(c && ismob(c.Target) && P && P.loc && get_dist(c.Target, P) <= 2) T = c.Target
	if(!T) return
	var/k0 = KD(Q(2 * k))
	var/k1 = KD(Q(2 * k + 1))
	var/ground = isnull(ke) || Q(2 * k + 1) - 2 * ke < 8 + 4 * EFXO_PL_NDECAL
	if(k0 <= 0.001 && k1 <= 0.001 && !ground)
		CharDrop(T)
		return
	CharFX(T, "E", tlc, 0.5 * k0, 0.5 * k1, 0.85 * k0, 0.85 * k1, 1)

/datum/energyfx_orbs/pillar/Busy(k)
	var/v = 2 * k + 1
	if(emb.Alive(v / EFXO_FPS) || spk.Alive(v / EFXO_FPS)) return 1
	if(isnull(ke)) return 1
	var/d = v - 2 * ke
	return d < 8 + 4 * EFXO_PL_NDECAL || !isnull(ColIndex(d))

proc/EFXOHeatMatrix(datum/energyfx_orbcolors/C, kk)
	var/list/edge = C.ramp[2]
	var/list/core = C.ramp[3]
	return list((core[1] - edge[1]) * kk, (core[2] - edge[2]) * kk, (core[3] - edge[3]) * kk, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, edge[1], edge[2], edge[3], 0)

proc/EFXOFMod(x, m)
	return x - floor(x / m) * m

var/list/EFXO_TWINS = list("PillarDecalG" = "PillarDecalD", "StealthCrackG" = "StealthCrackD")
var/list/EFXO_FTWINS = list("CatacSplatG" = "CatacSplatD")

/datum/energyfx_orbs/stealth
	parent_type = /datum/energyfx_orbs/bigbang
	conv_n = 0
	b_re = 48
	b_ground = "B3Ground48"
	b_dome = "B3E4_48SB"
	var/datum/energyfx_orbcolors/cols
	var/kf
	var/mx
	var/my

/datum/energyfx_orbs/stealth/Setup()
	cols = new
	cols.Setup(from, row)
	lm = cols.LM("hl")
	tlc = EFXOLitColor(cols)
	if(cols.gray) b_ground = "B3Ground48G"

/datum/energyfx_orbs/stealth/proc/Anchor(datum/energyfx_orbshot/O)
	if(isnull(mx))
		var/list/p = O.GetP(O.k_spawn)
		if(!p) return 0
		mx = p[1]
		my = p[2] - 4
	return 1

/datum/energyfx_orbs/stealth/OnFuse(datum/energyfx_orbshot/O, atom/target)
	..()
	if(isnull(kf)) kf = O.k_fuse
	if(ismob(target) && !struck) struck = target

/datum/energyfx_orbs/stealth/Boom(datum/energyfx_orbshot/O)
	if(blast || !Anchor(O)) return
	var/k = null
	if(O.hits.len)
		var/list/e = O.hits[1]
		k = e[1]
		if(ismob(e[2])) struck = e[2]
	else if(!isnull(O.k_end))
		k = O.k_end
	if(isnull(k)) return
	kb = k
	bx = round(mx, 1)
	by = round(my, 1)
	if(struck)
		var/tcx = (struck.x - 1) * 32 + struck.step_x + 16
		var/tcy = (struck.y - 1) * 32 + struck.step_y + 16
		bdir = EFXODir8(EFXOAtan2(my - tcy, mx - tcx))
	blast = new(Stream("b3"), b_re, bx, by, kb, null, b_dome, b_ground, lm, EFXO_LM_SCORCH)
	blast.e4 = b_dome
	blast.e4m = EFXOE4Mats(b_dome, cols.pal)
	blast.lm_flash = cols.LM("flash")
	blast.fl_kinds = list("XP", "XS", cols.LK("XL"))
	blast.kick = EFXO_ST_KICK

/datum/energyfx_orbs/stealth/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return
	Anchor(O)
	Boom(O)

/datum/energyfx_orbs/stealth/proc/KH()
	if(!isnull(kb)) return kb
	if(!isnull(kf)) return kf + 2
	return null

/datum/energyfx_orbs/stealth/Q(fi)
	var/k2 = KH()
	if(isnull(k2)) return fi - (fi % 2)
	return Holds(fi, list(list(2 * k2 - 4, 2)), list(list(2 * k2 - 2, 2 * k2 + 6)))

/datum/energyfx_orbs/stealth/proc/CrackPaint(list/out, st)
	if(cols.gray)
		Rec(out, "cp", "MP", "StealthCrackG", "[st]", mx, my, 0, 1, 1, 1, list(cols.bright, 0, 0, 0, 0, cols.bright, 0, 0, 0, 0, cols.bright, 0, 0, 0, 0, 1, 0, 0, 0, 0), 1.1)
	else
		Rec(out, "cp", "MP", "StealthCrack", "[st]_0", mx, my, 0, 1, 1, 1, EFXOHeatMatrix(cols, 1), 1.1)

/datum/energyfx_orbs/stealth/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O || !Anchor(O)) return out
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	if(blast) blast.Scorch(src, out, d, "b")
	var/k2 = KH()
	var/lk = cols.LK("ML")
	var/lik = cols.gray ? "StealthCrackLG" : "StealthCrack"
	if(!isnull(k2))
		var/o = v - 2 * k2
		var/pre_ok = (o > -4 || (o == -4 && !EFXOTblBit(EFXO_ST_PNG, k2))) && (o < 0 || (o == 0 && EFXOTblBit(EFXO_ST_PLT, k2)))
		if(pre_ok)
			var/pre = v / EFXO_FPS - (k2 * EFXO_TICK - 0.1)
			var/q = pre / 0.1
			var/j = o + 4
			var/qi = j - ((k2 < EFXO_TBL_K) ? EFXOBit(EFXO_ST_QI, k2 * 5 + j) : 0)
			var/st = min(EFXO_ST_NCRACK - 1, 3 + qi)
			var/kk = (48 * (0.4 + 0.5 * q)) / EFXO_OM_RIPPLE_R
			Rec(out, "rp", lk, "OmegaRipple", "art", mx, my, 0, kk, kk * 0.6, 0.9, lm, 0)
			Rec(out, "fs", "NP", "StealthFissure", "[st]", mx, my, 0, 1, 1, 0.6, EFXOPaintK(EFXOCoolK(0.6), EFXO_ST_FS_EDGE), 1)
			CrackPaint(out, st)
			Rec(out, "cl", lk, lik, "[st]_1", mx, my, 0, 1, 1, 1, cols.LM("accent", 1), 0)
	if(!isnull(kb) && d >= 0 && d < 40)
		var/fa = (d < 10) ? 1 : max(0, 1 - (d - 10) / 30)
		var/stl = EFXO_ST_NCRACK - 1
		Rec(out, "fs", "NP", "StealthFissure", "[stl]", mx, my, 0, 1, 1, fa * 0.6, EFXOPaintK(EFXOCoolK(fa * 0.6), EFXO_ST_FS_EDGE), 1)
		var/al = fa * ((d < 6) ? 1 : 0.5)
		Rec(out, "cl", lk, lik, "[stl]_1", mx, my, 0, 1, 1, al, cols.LM("accent", al), 0)
	if(blast)
		blast.Ground(src, out, d, "b", lk)
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b", cols.LK("XL"))
		out += sm
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b", cols.LK("XL"))
	return out

/datum/energyfx_orbs/stealth/Chars(k)
	var/mob/T = struck
	if(!T) return
	var/k0 = KD(Q(2 * k))
	var/k1 = KD(Q(2 * k + 1))
	var/ground = isnull(kb) || Q(2 * k + 1) - 2 * kb < 40
	if(k0 <= 0.001 && k1 <= 0.001 && !ground)
		CharDrop(T)
		return
	CharFX(T, bdir, tlc, 0.46 * k0, 0.46 * k1, 0.8 * k0, 0.8 * k1, 1)

/datum/energyfx_orbs/stealth/Busy(k)
	var/v = 2 * k + 1
	if(isnull(kb)) return 1
	if(v - 2 * kb < 40) return 1
	return blast && blast.Alive(v / EFXO_FPS, v - 2 * kb)

proc/EFXOLMa(list/m, a)
	if(!m || a == 1) return m
	var/list/r = m.Copy()
	for(var/i in list(1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19))
		r[i] *= a
	return r

proc/EFXOHeatDark(datum/energyfx_orbcolors/C)
	var/list/c = list(C.main255[1] / 255, C.main255[2] / 255, C.main255[3] / 255)
	var/list/b = BeamFXWarmEdge(c)
	var/kb = clamp((BeamFXLum(b) - 0.3) / 0.3, 0, 1)
	kb = kb * kb * (3 - 2 * kb)
	var/list/core = C.ramp[3]
	var/list/e = list(0, 0, 0)
	for(var/i = 1 to 3)
		e[i] = clamp(b[i] * (1 - 0.18 * kb), 0, 1)
	return list(core[1] - e[1], core[2] - e[2], core[3] - e[3], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, e[1], e[2], e[3], 0)

/datum/energyfx_orbs/catac
	var/datum/energyfx_orbcolors/cols
	var/datum/energyfx_orbshot/carrier
	var/datum/energyfx_orbwake/wake
	var/list/bits = list()
	var/list/lm
	var/list/lmf
	var/list/lm2
	var/list/lmf2
	var/list/bm_orb
	var/list/bm_bit
	var/list/hm
	var/list/p0
	var/oang = 0
	var/wake_dist = 0
	var/list/wake_prev
	var/ns = 6
	var/stag = 2
	var/every = 2
	var/total = 0
	var/seq = 0

/datum/energyfx_orbs/catac/Init(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R, datum/energyfx_look/orbs/L)
	..()
	if(R.extra["bit"] && P.emit_parent) from = P.emit_parent.from_skill
	cols = new
	cols.Setup(from, R)
	lm = cols.LM("hl")
	lmf = cols.LM("flash")
	lm2 = EFXOLMa(lm, 2)
	lmf2 = EFXOLMa(lmf, 2)
	bm_orb = cols.Body("co_frames")
	bm_bit = cols.Body("cob_frames")
	if(!cols.gray) hm = EFXOHeatDark(cols)
	wake = new
	wake.L = EFXO_CO_WAKE_L
	wake.N = EFXO_CO_WAKE_N
	wake.n = EFXO_CO_WAKE_F
	wake.life40 = EFXO_CO_WAKE_LIFE40
	wake.ik = cols.BodyIK("CatacWake")
	wake.tbl = EFXO_CO_WAKE_TBL
	wake.col_body = cols.Body("co_wake")

/datum/energyfx_orbs/catac/Accepts(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	if(!R.extra["bit"] || P.Owner != caster || !carrier) return 0
	return isnull(carrier.k_end) || Now() <= carrier.k_end + 4

/datum/energyfx_orbs/catac/AddShot(obj/Skills/Projectile/_Projectile/P, datum/energyfx_row/R)
	var/datum/energyfx_orbshot/O = ..()
	if(R.extra["bit"])
		O.vars_["bit"] = 1
	else if(!carrier)
		carrier = O
		every = max(1, P.EmitEvery)
		stag = P.EmitStagger ? max(1, round(P.EmitStagger / world.tick_lag, 1)) : 0
	return O

/datum/energyfx_orbs/catac/OnLaunch(datum/energyfx_orbshot/O)
	..()
	if(O == carrier && O.P)
		ns = max(1, O.P.pm_substep)
		var/d = DisplayedCardinal(O.P.dir, EAST)
		var/list/dv = BeamFXDirVec(BeamFXDirText(d))
		oang = EFXOAtan2(dv[2], dv[1])

/datum/energyfx_orbs/catac/proc/KL()
	return isnull(carrier.k_launch) ? carrier.k_spawn : carrier.k_launch

/datum/energyfx_orbs/catac/proc/Info(bi)
	var/datum/bfx_rng/G = Stream("bits")
	var/list/ang = (carrier && carrier.P) ? carrier.P.emit_angles : null
	while(bits.len <= bi)
		var/j = bits.len
		var/a0 = (ang && j < ang.len) ? ang[j + 1] : 0
		var/ph = G.RandRange(EFXO_CO_NF)
		var/rot = G.U(0, 360)
		var/spin = list(-1, 1)[G.RandRange(2) + 1] * G.U(360, 900)
		var/list/fl = list()
		for(var/i = 1 to 40)
			fl += G.U(0.88, 1.12)
		var/pr = G.U(0, 360)
		var/arc = G.RandRange(4)
		var/list/sp = list()
		var/nsp = list(2, 3, 3)[G.RandRange(3) + 1]
		for(var/i = 1 to nsp)
			sp[++sp.len] = list(a0 + G.U(-0.9, 0.9) * 57.29577951, G.U(60, 160), G.U(0.08, 0.16), G.U(0.22, 0.38))
		bits[++bits.len] = list(a0, ph, rot, spin, fl, pr, arc, sp, null, null)
		if(parity) OL("E 0 bitang [j] [EnergyFXOrbN(a0)]")
	return bits[bi + 1]

/datum/energyfx_orbs/catac/proc/KE(bi)
	var/list/b = Info(bi)
	var/datum/energyfx_orbshot/S = b[9]
	if(S) return S.k_spawn
	if(!carrier) return null
	var/step = floor(bi / every)
	var/list/b0 = (bi % every) ? Info(bi - (bi % every)) : null
	var/datum/energyfx_orbshot/S0 = b0 ? b0[9] : null
	if(S0) return S0.k_spawn + (bi % every) * stag
	return KL() + ns * (step + 1) + (bi % every) * stag

/datum/energyfx_orbs/catac/TickWork(k)
	if(carrier && carrier.P) total = carrier.P.emit_total
	for(var/datum/energyfx_orbshot/O in shots)
		if(!O.vars_["bit"] || !isnull(O.vars_["bi"])) continue
		var/obj/Skills/Projectile/_Projectile/P = O.P
		if(!P || isnull(P.kick_px)) continue
		var/bi = P.emit_index
		O.vars_["bi"] = bi
		var/list/b = Info(bi)
		b[9] = O
		var/list/c = carrier ? carrier.GetP(O.k_spawn) : null
		if(c)
			O.SetP(O.k_spawn, list(c[1] + cos(b[1]) * KICK_PATH["r0"], c[2] + sin(b[1]) * KICK_PATH["r0"]))
		if(parity) OL("E [O.idx] bit [bi]")
	if(!carrier) return
	if(!p0) p0 = carrier.DrawnT(KL() * EFXO_TICK)
	if(k < KL() + 1 || (!isnull(carrier.k_end) && k >= carrier.k_end)) return
	var/list/p = carrier.DrawnT(k * EFXO_TICK)
	if(!p) return
	var/st = wake_prev ? EFXOHyp(p[1] - wake_prev[1], p[2] - wake_prev[2]) : 0
	var/ang = (wake_prev && st > 0.000001) ? EFXOAtan2(p[2] - wake_prev[2], p[1] - wake_prev[1]) : oang
	wake_prev = p
	wake.Spawn(k, p[1], p[2], ang, st)

/datum/energyfx_orbs/catac/Q(fi)
	if(!carrier || isnull(carrier.k_end)) return fi - (fi % 2)
	return Holds(fi, list(), list(list(2 * carrier.k_end, 2 * carrier.k_end + 7)))

/datum/energyfx_orbs/catac/proc/Lay(base)
	seq++
	return base + seq * 0.00001

/datum/energyfx_orbs/catac/proc/HitIK()
	return cols.gray ? "CatacHitLG" : "CatacHitH"

/datum/energyfx_orbs/catac/proc/Splat(list/out, key, d, x, y, ang, sc, lay)
	if(cols.gray)
		Rec(out, "[key]p", "FP", "CatacSplatG", "[d]", x, y, ang, sc, sc, 1, list(cols.bright, 0, 0, 0, 0, cols.bright, 0, 0, 0, 0, cols.bright, 0, 0, 0, 0, 1, 0, 0, 0, 0), Lay(lay))
	else
		Rec(out, "[key]p", "FP", "CatacHitH", "splat_[d]_0", x, y, ang, sc, sc, 1, hm, Lay(lay))
	Rec(out, "[key]l", cols.LK("FL"), HitIK(), "splat_[d]_1", x, y, ang, sc, sc, 1, lm2, 0)

/datum/energyfx_orbs/catac/Draw(fi, v)
	var/list/out = list()
	seq = 0
	var/tv = v / EFXO_FPS
	var/R0 = EFXO_CO_R
	var/alive = carrier && v >= 2 * KL() && (isnull(carrier.k_end) || v < 2 * carrier.k_end)
	if(carrier) wake.Sprites(src, out, v, "w", "UP", cols.LK("UL"), lm, 4.8)
	var/n = max(total, bits.len)
	var/pulse = 0
	var/list/kes = list()
	for(var/bi = 0 to n - 1)
		var/ke = KE(bi)
		kes += ke
		if(isnull(ke)) continue
		var/ob = v - (2 * ke - 8)
		if(ob >= 0 && ob < 12.8) pulse = max(pulse, sin(180 * min(1, ob / 12.8)))
	var/list/cp = null
	if(alive)
		cp = carrier.DrawnT(tv)
		if(cp && p0)
			var/dist = EFXOHyp(cp[1] - p0[1], cp[2] - p0[2])
			var/fo = BeamFXMod(floor(dist / (6.283185307 * R0) * EFXO_CO_NF), EFXO_CO_NF)
			var/sc = min(1, 0.4 + 0.6 * (v - 2 * KL()) / 4.8) * (1 + 0.1 * pulse)
			Rec(out, "op", "FP", cols.BodyIK("CatacOrb"), "[fo]_0", cp[1], cp[2], oang, sc, sc, 1, bm_orb, Lay(5))
			Rec(out, "ol", cols.LK("FL"), cols.BodyIK("CatacOrb"), "[fo]_1", cp[1], cp[2], oang, sc, sc, 1, EFXOLMa(lm, 1 + 0.8 * pulse), 0)
	if(carrier && !isnull(carrier.k_end))
		var/d = v - 2 * carrier.k_end
		var/list/pe = carrier.DrawnT(carrier.k_end * EFXO_TICK)
		if(pe && d >= 0)
			if(d < 2)
				var/kc = list(0.55, 0.3)[d + 1]
				Rec(out, "ep", "FP", cols.BodyIK("CatacOrb"), "0_0", pe[1], pe[2], oang, kc, kc, 1, bm_orb, Lay(5))
				Rec(out, "el", cols.LK("FL"), cols.BodyIK("CatacOrb"), "0_1", pe[1], pe[2], oang, kc, kc, 1, lm, 0)
			if(d < 7)
				Splat(out, "es", d, pe[1], pe[2], 0, 1, 5)
			if(d < 4)
				Rec(out, "ef", cols.LK("FL"), HitIK(), "flash", pe[1], pe[2], 15 * d, 1.2 + 0.25 * d, 1.2 + 0.25 * d, (d < 2) ? 1 : 0.5, lmf2, 0)
			if(d < 6)
				var/q = d / 6
				Rec(out, "et", cols.LK("FL"), HitIK(), "streak", pe[1], pe[2], 0, 0.6 + 0.8 * q, 0.6 + 0.8 * q, 1 - q, lm2, 0)
	for(var/bi = 0 to n - 1)
		var/ke = kes[bi + 1]
		if(isnull(ke)) continue
		var/list/b = Info(bi)
		var/a0 = b[1]
		var/ob = v - (2 * ke - 8)
		if(ob >= 0 && ob < 8 && alive && cp)
			var/q = ob / 8
			var/ca = cos(a0)
			var/sa = sin(a0)
			var/r_in = R0 * 0.8
			var/r_b = R0 * (0.8 + 0.8 * q * q)
			var/s_b = 0.4 + 0.75 * q
			Rec(out, "b[bi]h", cols.LK("FL"), HitIK(), "flash", cp[1] + ca * R0 * 0.92, cp[2] + sa * R0 * 0.92, b[6], 0.22 + 0.25 * q, 0.22 + 0.25 * q, 0.55 + 0.45 * q, lmf2, 0)
			var/neck = max(0, r_b - r_in)
			if(neck > 1)
				var/rm = (r_in + r_b) * 0.5
				Rec(out, "b[bi]np", "FP", cols.BodyIK("CatacBit"), "[b[2]]_0", cp[1] + ca * rm, cp[2] + sa * rm, a0, (neck + 6 * s_b) / 12, 0.5 * s_b, 1, bm_bit, Lay(5.1))
				Rec(out, "b[bi]nl", cols.LK("FL"), cols.BodyIK("CatacBit"), "[b[2]]_1", cp[1] + ca * rm, cp[2] + sa * rm, a0, (neck + 6 * s_b) / 12, 0.5 * s_b, 1, EFXOLMa(lm, 1.2), 0)
				Rec(out, "b[bi]ns", cols.LK("FL"), "B3Spark", "x", cp[1] + ca * rm, cp[2] + sa * rm, a0, (neck + 8) / 30, 0.55, 1, lm, 0)
	for(var/bi = 0 to n - 1)
		var/ke = kes[bi + 1]
		if(isnull(ke)) continue
		var/list/b = Info(bi)
		var/a0 = b[1]
		var/ob = v - (2 * ke - 8)
		if(ob >= 0 && ob < 8 && alive && cp)
			var/q = ob / 8
			var/r_b = R0 * (0.8 + 0.8 * q * q)
			var/s_b = 0.4 + 0.75 * q
			var/st = 1 + 0.35 * q
			Rec(out, "b[bi]bp", "FP", cols.BodyIK("CatacBit"), "[b[2]]_0", cp[1] + cos(a0) * r_b, cp[2] + sin(a0) * r_b, a0, s_b * st, s_b / st, 1, bm_bit, Lay(5.2))
			Rec(out, "b[bi]bl", cols.LK("FL"), cols.BodyIK("CatacBit"), "[b[2]]_1", cp[1] + cos(a0) * r_b, cp[2] + sin(a0) * r_b, a0, s_b * st, s_b / st, 1, EFXOLMa(lm, 1 + 0.9 * q), 0)
			if(q > 0.3)
				Rec(out, "b[bi]a", cols.LK("FL"), "BigBangArc", "[b[7]]", cp[1] + cos(a0) * R0 * 0.95, cp[2] + sin(a0) * R0 * 0.95, a0 + 90, 0.5, (b[7] % 2) ? 0.5 : -0.5, 0.9, lm, 0)
		var/datum/energyfx_orbshot/S = b[9]
		if(!S) continue
		var/o = v - 2 * ke
		var/alive_b = o >= 0 && (isnull(S.k_end) || v < 2 * S.k_end)
		if(alive_b)
			var/age = o / 40
			var/list/p = S.DrawnT(tv)
			if(p)
				var/ba = a0
				if(o > 0)
					var/list/pp = S.DrawnT(tv - 1 / EFXO_FPS)
					if(pp && EFXOHyp(p[1] - pp[1], p[2] - pp[2]) > 0.000001) ba = EFXOAtan2(p[2] - pp[2], p[1] - pp[1])
				var/bv = KICK_PATH["v1"] + (KICK_PATH["v0"] - KICK_PATH["v1"]) * EFXOExp(-age / KICK_PATH["tau"])
				var/list/fl = b[5]
				var/kf = fl[BeamFXMod(o, 40) + 1] * min(1, 0.95 + age)
				var/fr = BeamFXMod(b[2] + floor(3 * o / 5), EFXO_CO_NF)
				var/ln = 0.35 + 0.45 * (bv / EFXO_CO_V0)
				Rec(out, "b[bi]s", cols.LK("FL"), "B3Spark", "x", p[1] - cos(ba) * (6 + 8 * ln), p[2] - sin(ba) * (6 + 8 * ln), ba, ln, 0.65, 0.85, lm, 0)
				var/rot = b[3] + b[4] * age
				Rec(out, "b[bi]fp", "FP", cols.BodyIK("CatacBit"), "[fr]_0", p[1], p[2], rot, kf, kf, 1, bm_bit, Lay(5.2))
				Rec(out, "b[bi]fl", cols.LK("FL"), cols.BodyIK("CatacBit"), "[fr]_1", p[1], p[2], rot, kf, kf, 1, lm, 0)
		if(o >= 0 && o <= 4)
			var/list/s0 = S.GetP(S.k_spawn)
			if(s0)
				var/age2 = o / 40
				var/q2 = age2 / 0.12
				if(o <= 2)
					Rec(out, "b[bi]xf", cols.LK("FL"), HitIK(), "flash", s0[1], s0[2], b[6], 0.6 - 0.2 * q2, 0.6 - 0.2 * q2, 1 - 0.6 * q2, lmf2, 0)
				if(o < 4)
					Rec(out, "b[bi]xa", cols.LK("FL"), "BigBangArc", "[(b[7] + 1) % 4]", s0[1], s0[2], a0 + 90, 0.55, 0.55, 1 - q2, lm, 0)
				var/list/sps = b[8]
				for(var/i = 1 to sps.len)
					var/list/sp = sps[i]
					if(age2 < sp[3])
						var/qq = age2 / sp[3]
						var/dd = sp[2] * age2 * (1 - 0.5 * qq)
						Rec(out, "b[bi]k[i]", cols.LK("FL"), "B3Spark", "x", s0[1] + cos(sp[1]) * dd, s0[2] + sin(sp[1]) * dd, sp[1], sp[4] * 1.3, 0.5, 1 - qq, lm, 0)
	for(var/bi = 0 to n - 1)
		var/list/b = Info(bi)
		var/datum/energyfx_orbshot/S = b[9]
		if(!S || isnull(S.k_end)) continue
		var/dp = v - 2 * S.k_end
		if(dp >= 0 && dp < 7)
			var/list/pe = S.DrawnT(S.k_end * EFXO_TICK)
			if(pe)
				Splat(out, "b[bi]q", dp, pe[1], pe[2], b[6], 0.7, 5.3)
				if(dp < 3)
					Rec(out, "b[bi]qf", cols.LK("FL"), HitIK(), "flash", pe[1], pe[2], b[6], 0.75, 0.75, (dp < 2) ? 1 : 0.5, lmf2, 0)
	return out

/datum/energyfx_orbs/catac/Busy(k)
	var/v = 2 * k + 1
	if(wake.Alive(v)) return 1
	if(carrier && isnull(carrier.k_end)) return 1
	if(carrier && v - 2 * carrier.k_end < 8) return 1
	for(var/datum/energyfx_orbshot/S in shots)
		if(!S.vars_["bit"]) continue
		if(isnull(S.k_end) || v - 2 * S.k_end < 8) return 1
	return 0

#define EFXO_CM_PLANE 67
#define EFXO_CP_PLANE 68
#define EFXO_CS_PLANE 69
#define EFXO_CL_PLANE 70
#define EFXO_CLG_PLANE 71
#define EFXO_CM_RELAY 6.6365
#define EFXO_CP_RELAY 6.637
#define EFXO_CS_RELAY 6.638
#define EFXO_CL_RELAY 6.639
#define EFXO_CLG_VEIL 6.6393
#define EFXO_CLG_RELAY 6.6395

/obj/energyfx/orb/cm
	plane = EFXO_CM_PLANE
/obj/energyfx/orb/cp
	plane = EFXO_CP_PLANE
/obj/energyfx/orb/cs
	plane = EFXO_CS_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/cl
	plane = EFXO_CL_PLANE
	blend_mode = BLEND_ADD
/obj/energyfx/orb/clg
	plane = EFXO_CLG_PLANE
	blend_mode = BLEND_ADD

/obj/energyfx_master/orb/cm
	plane = EFXO_CM_PLANE
	render_target = "*energyfx_orb_cm"
/obj/energyfx_master/orb/cp
	plane = EFXO_CP_PLANE
	render_target = "*energyfx_orb_cp"
/obj/energyfx_master/orb/cs
	plane = EFXO_CS_PLANE
	render_target = "*energyfx_orb_cs"
/obj/energyfx_master/orb/cl
	plane = EFXO_CL_PLANE
	render_target = "*energyfx_orb_cl"
/obj/energyfx_master/orb/cl/New()
	..()
	filters = filter(type = "blur", size = glob ? glob.ENERGYFX_BLUR : 1.5)

/obj/energyfx_relay/orb/cm
	layer = EFXO_CM_RELAY
	render_source = "*energyfx_orb_cm"
/obj/energyfx_relay/orb/cp
	layer = EFXO_CP_RELAY
	render_source = "*energyfx_orb_cp"
/obj/energyfx_relay/orb/cs
	layer = EFXO_CS_RELAY
	render_source = "*energyfx_orb_cs"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/cl
	layer = EFXO_CL_RELAY
	render_source = "*energyfx_orb_cl"
	blend_mode = BLEND_ADD
/obj/energyfx_relay/orb/cl/New()
	..()
	color = list(EFXO_LS, 0, 0, 0, EFXO_LS, 0, 0, 0, EFXO_LS)

/obj/energyfx_master/orbgray/clg
	plane = EFXO_CLG_PLANE
	render_target = "*energyfx_orb_clg"
/obj/energyfx_relay/orbgray/clg_v
	layer = EFXO_CLG_VEIL
	render_source = "*energyfx_orb_clg"
	veil = 1
/obj/energyfx_relay/orbgray/clg
	layer = EFXO_CLG_RELAY
	render_source = "*energyfx_orb_clg"
	blend_mode = BLEND_ADD

/datum/energyfx_orbcolors/proc/SetupHex(hex)
	canon = 0
	anchor = 0
	main255 = BeamFXHexRGB(hex)
	core255 = null
	glow255 = null
	if(!main255) main255 = list(0, 0, 0)
	gray = EFXOGrayRule(main255)
	if(gray)
		var/lum = EFXOLum3(list(main255[1] / 255, main255[2] / 255, main255[3] / 255))
		bright = (lum < 0.03) ? 1 : max(main255[1], main255[2], main255[3]) / 255
	ramp = BeamFXRamp(gray ? list(153, 153, 153) : main255, core255, glow255)
	pal = EFXOPalette(main255, core255, glow255)

/datum/energyfx_orbs/proc/CounterSpec(datum/energyfx_orbshot/O)
	return null

/datum/energyfx_orbs/bigbang/var/head_ik = "SupernovaBBBall"
/datum/energyfx_orbs/bigbang/var/head_nf = EFXO_BB_NF

/datum/energyfx_orbs/bigbang/proc/Cols()
	return null

/datum/energyfx_orbs/tracking/Cols()
	return cols

/datum/energyfx_orbs/nova/Cols()
	return cols

/datum/energyfx_orbs/stealth/Cols()
	return cols

/datum/energyfx_orbs/bigbang/CounterSpec(datum/energyfx_orbshot/O)
	PreBoom()
	var/datum/energyfx_orbcolors/C = Cols()
	if(!C)
		C = new
		C.Setup(from, row)
	var/list/s = list()
	s["re"] = b_re
	s["g0"] = b_g0
	s["dome"] = b_dome
	s["ground"] = b_ground
	s["lm"] = lm
	s["cols"] = C
	s["e4"] = findtext(b_dome, "B3E4") == 1
	s["head"] = head_ik
	s["head_nf"] = head_nf
	s["head_bm"] = null
	return s

/datum/energyfx_orbs/sgm/head_ik = "SGMBall"
/datum/energyfx_orbs/sgm/head_nf = EFXO_SGM_NF
/datum/energyfx_orbs/omega/head_ik = null
/datum/energyfx_orbs/deathball/head_ik = null
/datum/energyfx_orbs/tracking/head_ik = null
/datum/energyfx_orbs/nova/head_ik = null
/datum/energyfx_orbs/stealth/head_ik = null

/datum/energyfx_orbcounter
	var/kc
	var/th
	var/ta
	var/list/c0
	var/lx
	var/ly
	var/datum/energyfx_orbblast3/blast
	var/list/plan
	var/splash_ik
	var/list/sm
	var/list/spec
	var/list/lm
	var/lk
	var/idx

/datum/energyfx_orbs/supernova
	parent_type = /datum/energyfx_orbs/bigbang
	R_ = EFXO_SN_R
	conv_n = 3
	b_re = 170
	b_g0 = 0.92
	b_dome = "B3Dome170SN"
	b_ground = "B3Ground170"
	bdir = "E"
	head_ik = null
	var/kf
	var/kflip
	var/hd = 0
	var/list/counters = list()
	var/list/strikes = list()
	var/list/pexe

/datum/energyfx_orbs/supernova/Setup()
	lm = EFXO_SN_LM
	tlc = EFXO_SN_TL
	pre_q = EFXO_SN_PRELOAD

/datum/energyfx_orbs/supernova/Scale(datum/energyfx_orbshot/O, t)
	return 0.1 + 0.9 * EFXOEaseOut(min(1, max(0, (t - O.k_spawn * EFXO_TICK) / Tch(O))))

/datum/energyfx_orbs/supernova/OnFuse(datum/energyfx_orbshot/O, atom/target)
	..()
	if(isnull(kf))
		kf = O.k_fuse
		if(ismob(target)) struck = target

/datum/energyfx_orbs/supernova/proc/SunPos(datum/energyfx_orbshot/O, v)
	var/tv = v / EFXO_FPS
	var/kl = KLaunch(O)
	if(isnull(kl) || EFXOTvLt(v, kl))
		var/list/p0 = O.GetP(O.k_spawn)
		if(!p0) return null
		var/sc = Scale(O, tv)
		return list(p0[1], p0[2], EFXO_SN_HEAD + R_ * sc, sc, 1)
	var/list/d = O.DrawnT(tv)
	if(!d) return null
	var/z = (EFXO_SN_HEAD + R_) * (1 - EFXOSstep(0, 1, (tv - kl * EFXO_TICK) / 0.3))
	return list(d[1], d[2], z, 1, 0)

/datum/energyfx_orbs/supernova/proc/SunHead(datum/energyfx_orbshot/O, t)
	if(isnull(O.k_launch)) return 0
	var/list/a = O.DrawnT(t - 1 / EFXO_FPS)
	var/list/b = O.DrawnT(t)
	var/h = O.vars_["hd"]
	if(!a || !b || (abs(a[1] - b[1]) < 0.01 && abs(a[2] - b[2]) < 0.01)) return isnull(h) ? fang : h
	var/raw = EFXOAtan2(b[2] - a[2], b[1] - a[1])
	if(isnull(h))
		O.vars_["hd"] = raw
		return raw
	var/df = raw - h
	while(df > 180) df -= 360
	while(df < -180) df += 360
	if(abs(df) <= 90 || (!isnull(kflip) && t >= kflip * EFXO_TICK - 0.0001 && !O.vars_["flipped"]))
		if(abs(df) > 90) O.vars_["flipped"] = 1
		O.vars_["hd"] = raw
		return raw
	return h

/datum/energyfx_orbs/supernova/proc/SunHeadV(datum/energyfx_orbshot/O, v)
	var/list/hv = O.vars_["hv"]
	if(!hv)
		hv = list()
		O.vars_["hv"] = hv
	var/key = "[v]"
	if(!isnull(hv[key])) return hv[key]
	var/h = SunHead(O, v / EFXO_FPS)
	hv[key] = h
	return h

/datum/energyfx_orbs/supernova/Boom(datum/energyfx_orbshot/O)
	if(blast) return
	if(isnull(kf) && !isnull(O.k_end) && !O.end_lost) kf = O.k_end - 1.5
	if(isnull(kf)) return
	var/ke = isnull(O.k_fuse) ? O.k_end : kf
	var/list/p = O.DrawnT(ke * EFXO_TICK)
	if(!p) return
	pexe = p
	kb = kf + 1.5
	bx = round(p[1], 1)
	by = round(p[2], 1)
	hd = SunHeadV(O, round(2 * ke, 1))
	if(struck)
		var/tcx = (struck.x - 1) * 32 + struck.step_x + 16
		var/tcy = (struck.y - 1) * 32 + struck.step_y + 16
		bdir = EFXODir8(EFXOAtan2(by - tcy, bx - tcx))
	blast = new(Stream("b3"), b_re, bx, by, kb, b_g0, b_dome, b_ground, lm, EFXO_LM_SCORCH)
	pre_q = null

/datum/energyfx_orbs/supernova/TickWork(k)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return
	Boom(O)
	if(O.P && isnull(kflip) && !isnull(O.k_launch) && O.P.Owner && O.P.Owner != caster)
		kflip = k
		if(parity) OL("E [O.idx] flip [k]")
	var/kl = KLaunch(O)
	if(!isnull(kl) && EFXOPlusLe(O.k_spawn, k, 1) && EFXOMinusLt(k, kl, 2))
		conv.Emit(Stream("conv"), k * EFXO_TICK, 3, R_ * Scale(O, k * EFXO_TICK))

/datum/energyfx_orbs/supernova/OnClash(datum/energyfx_orbshot/O, obj/Skills/Projectile/_Projectile/other)
	..()
	if(!isnull(kf) || !other) return
	var/k = Now()
	for(var/list/s in strikes)
		if(s[1] == k) return
	var/list/c = O.Center()
	if(!c) return
	var/px = (other.x - 1) * 32 + other.step_x + 16 + other.vhb_ax
	var/py = (other.y - 1) * 32 + other.step_y + 16 + other.vhb_ay
	var/th = (abs(px - c[1]) + abs(py - c[2]) > 0.001) ? EFXOAtan2(py - c[2], px - c[1]) : 0
	strikes[++strikes.len] = list(k, th)
	if(parity) OL("E [O.idx] strike [k] [EnergyFXOrbN(th)]")

/datum/energyfx_orbs/supernova/OnCounterDied(datum/energyfx_orbshot/O, obj/Skills/Projectile/_Projectile/counter)
	if(!counter || blast) return 0
	var/k = Now()
	var/list/c = O.Center()
	var/list/pc = list((counter.x - 1) * 32 + counter.step_x + 16 + counter.vhb_ax, (counter.y - 1) * 32 + counter.step_y + 16 + counter.vhb_ay)
	if(!c) return 0
	var/datum/energyfx_orbcounter/E = new
	E.idx = counters.len + 1
	E.kc = k
	E.c0 = c
	E.th = (abs(pc[1] - c[1]) + abs(pc[2] - c[2]) > 0.001) ? EFXOAtan2(pc[2] - c[2], pc[1] - c[1]) : 0
	E.ta = E.th + 180
	E.lx = c[1] + cos(E.th) * R_
	E.ly = c[2] + sin(E.th) * R_
	var/datum/energyfx_orbshot/CO = counter.efx_orb
	var/list/spec = (CO && CO.S) ? CO.S.CounterSpec(CO) : null
	var/datum/energyfx_orbcolors/C
	var/re
	E.spec = spec
	if(CO && !spec)
		counters += E
		if(parity) OL("E [O.idx] counter [k] [EnergyFXOrbN(E.th)] [EnergyFXOrbN(E.ta)] 2")
		return 0
	if(spec)
		CO.vars_["countered"] = 1
		var/list/a = CO.DrawnT((k - 1) * EFXO_TICK)
		var/list/b = CO.DrawnT(k * EFXO_TICK)
		if(a && b && EFXOHyp(b[1] - a[1], b[2] - a[2]) > 0.001) E.ta = EFXOAtan2(b[2] - a[2], b[1] - a[1])
		C = spec["cols"]
		re = spec["re"]
	else
		ENERGYFX_FINISH_DRAWN[counter] = 1
		C = new
		C.SetupHex(FxBlastTint(counter))
		re = 16 * max(1, counter.Explode)
	E.cols = C
	var/bx_ = E.lx + cos(E.th) * re * 0.3
	var/by_ = E.ly + sin(E.th) * re * 0.3
	var/datum/energyfx_orbblast3/B
	if(spec && !spec["e4"])
		B = new(Stream("cb[E.idx]"), re, bx_, by_, k + 1, spec["g0"], spec["dome"], spec["ground"], spec["lm"], EFXO_LM_SCORCH)
		E.lm = spec["lm"]
		E.lk = "CL"
		E.splash_ik = (spec["dome"] == "B3Dome48BB") ? "SplashBB" : "SplashE4"
		if(E.splash_ik == "SplashE4") E.sm = EFXOE4Mats("SplashE4", C.pal)
	else
		var/list/sets = list(16, 32, 48, 64, 80)
		var/rs = 16
		for(var/r in sets)
			if(r <= re) rs = r
		var/ek = (spec && spec["e4"]) ? spec["dome"] : ((rs == 48) ? "B3E4_48TB" : "B3E4_[rs]G")
		var/gk = (spec && spec["e4"]) ? spec["ground"] : "B3Ground[rs][C.gray ? "G" : ""]"
		B = new(Stream("cb[E.idx]"), re, bx_, by_, k + 1, (spec ? spec["g0"] : null), ek, gk, C.LM("hl"), EFXO_LM_SCORCH)
		B.e4 = ek
		B.e4m = EFXOE4Mats(ek, C.pal)
		B.lm_flash = C.LM("flash")
		if(!spec) B.dsc = re / rs
		E.lm = C.LM("hl")
		E.lk = C.LK("CL")
		E.splash_ik = "SplashE4"
		E.sm = EFXOE4Mats("SplashE4", C.pal)
	B.fl_kinds = list("CP", "CS", E.lk)
	B.sqx = EFXO_SN_SQ[1]
	B.sqy = EFXO_SN_SQ[2]
	B.sqa = E.th
	E.blast = B
	var/datum/bfx_rng/G = Stream("spl[E.idx]")
	E.plan = list()
	for(var/i = 0 to 5)
		var/t_off = G.U(0, EFXO_TICK)
		var/life = G.U(0.15, 0.24)
		var/da = G.U(75, 160)
		var/kk = EFXO_SPL_K * G.U(0.8, 1.25)
		var/vr = G.RandRange(4)
		var/r0 = G.U(2, 6) * EFXO_SPL_K
		E.plan[++E.plan.len] = list(t_off, life, (i % 2 == 0) ? 1 : -1, da, kk, vr, r0)
	counters += E
	if(parity) OL("E [O.idx] counter [k] [EnergyFXOrbN(E.th)] [EnergyFXOrbN(E.ta)] [spec ? 1 : 0] [EnergyFXOrbN(c[1])] [EnergyFXOrbN(c[2])] [re] [spec ? "-" : (FxBlastTint(counter) || "-")] [E.idx]")
	return 0

/datum/energyfx_orbs/supernova/Q(fi)
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return fi - (fi % 2)
	var/kl = KLaunch(O)
	var/list/hl = list()
	var/list/ones = list()
	if(!isnull(kl)) hl += list(list(2 * kl - 4, 4))
	if(!isnull(kflip)) hl += list(list(2 * kflip + 1, 3))
	if(!isnull(kf)) ones += list(list(2 * kf, 2 * kf + 9))
	for(var/list/s in strikes)
		ones += list(list(2 * s[1], 2 * s[1] + 10))
	return Holds(fi, hl, ones)

/datum/energyfx_orbs/supernova/KD(v)
	if(isnull(kf) || v < 2 * kf) return 0
	var/tv = v / EFXO_FPS
	var/td = kf * EFXO_TICK
	return EFXOEaseOut((tv - td) / 0.12) * max(0, 1 - max(0, tv - td - EFXO_SN_TCRIT - 0.6) / 0.6)

/datum/energyfx_orbs/supernova/Chars(k)
	if(!struck) return
	var/k0 = KD(Q(2 * k))
	var/k1 = KD(Q(2 * k + 1))
	var/d = Q(2 * k + 1) - 2 * kb
	var/ground = blast && d < 8 + 3 * EFXO_B3_NSCORCH
	if(k0 <= 0.001 && k1 <= 0.001 && !ground)
		CharDrop(struck)
		return
	CharFX(struck, bdir, tlc, 0.46 * k0, 0.46 * k1, 0.8 * k0, 0.8 * k1, ground)

/datum/energyfx_orbs/supernova/proc/CounterDraw(list/out, datum/energyfx_orbcounter/E, v, t)
	var/pre = "c[E.idx]"
	if(!E.blast) return
	var/d = v - 2 * (E.kc + 1)
	E.blast.Scorch(src, out, d, "[pre]b", "GP", "GL")
	E.blast.Ground(src, out, d, "[pre]b", "GL")
	var/list/smk = list()
	E.blast.Particles(src, list(), smk, t, "[pre]b", E.lk, "CM")
	out += smk
	var/px = E.lx + cos(E.th) * 2
	var/py = E.ly + sin(E.th) * 2
	for(var/i = 1 to E.plan.len)
		var/list/p = E.plan[i]
		var/age = t - ((E.kc + 1) * EFXO_TICK + p[1])
		if(age < 0 || age >= p[2]) continue
		var/at = E.ta + p[3] * p[4]
		var/j = min(EFXO_SPL_NS - 1, floor(age / p[2] * (EFXO_SPL_NS - 1) + 0.5))
		var/rr = p[7] + EFXO_SPL_OX * p[5]
		var/sx = px + cos(at) * rr
		var/sy = py + sin(at) * rr
		if(E.splash_ik == "SplashBB")
			Rec(out, "[pre]s[i]p", "CP", "SplashBB", "frames_[p[6]]_[j]_0", sx, sy, at, p[5], p[5] * p[3], 1, null, 5.1 + E.idx * 0.0001)
			if(j < EFXO_SPL_NL) Rec(out, "[pre]s[i]a", "CS", "SplashBB", "frames_[p[6]]_[j]_1", sx, sy, at, p[5], p[5] * p[3], 1, null, 0)
		else
			Rec(out, "[pre]s[i]p", "CP", "SplashE4", E.sm[1] ? "o[p[6]]_[j]" : "og[p[6]]_[j]", sx, sy, at, p[5], p[5] * p[3], 1, E.sm[1], 5.1 + E.idx * 0.0001)
			for(var/k = 0 to 2)
				Rec(out, "[pre]s[i]a[k]", "CS", "SplashE4", "l[k]_[p[6]]_[j]", sx, sy, at, p[5], p[5] * p[3], 1, E.sm[k + 2], 0)
	E.blast.Body(src, out, d, "[pre]b", 5 + E.idx * 0.0001)
	E.blast.Particles(src, out, null, t, "[pre]b", E.lk)
	var/b = EFXOSqJ(E.kc, v - 2 * E.kc)
	var/list/spec = E.spec
	if(spec && spec["head"] && b >= 0)
		var/hik = spec["head"]
		var/datum/energyfx_orbcolors/C = spec["cols"]
		if(C) hik = C.BodyIK(hik)
		var/kx = list(0.7, 0.45)[b + 1] * 0.75
		var/ky = list(1.2, 1.45)[b + 1] * 0.75
		var/hf = BeamFXMod(floor(v / 2), spec["head_nf"])
		var/hx = E.lx + cos(E.th) * (9 + 4 * b)
		var/hy = E.ly + sin(E.th) * (9 + 4 * b)
		Rec(out, "[pre]hp", "FP", hik, "rest_[hf]_0", hx, hy, E.th, kx, ky, 1, spec["head_bm"], 5.3)
		Rec(out, "[pre]hl", C ? C.LK("FL") : "FL", hik, "rest_[hf]_1", hx, hy, E.th, kx, ky, 1, EFXOLMa(spec["lm"], 1.3 + 0.4 * b), 0)

/datum/energyfx_orbs/supernova/Draw(fi, v)
	var/list/out = list()
	var/datum/energyfx_orbshot/O = Shot()
	if(!O) return out
	var/tv = v / EFXO_FPS
	var/t = fi / EFXO_FPS
	var/d = isnull(kb) ? -1000 : v - 2 * kb
	if(blast)
		blast.Scorch(src, out, d, "b")
		blast.Ground(src, out, d, "b")
	for(var/datum/energyfx_orbcounter/E in counters)
		CounterDraw(out, E, v, t)
	if(blast)
		var/list/sm = list()
		blast.Particles(src, list(), sm, t, "b")
		out += sm
	var/crit_end = isnull(kf) ? null : 2 * kf + 3
	if(v >= 2 * O.k_spawn && (isnull(crit_end) || v < crit_end))
		var/list/p = SunPos(O, v)
		if(p)
			var/x = p[1]
			var/y = p[2]
			var/z = p[3]
			var/sc = p[4]
			var/pre = p[5]
			var/la = 1
			for(var/list/s in strikes)
				var/os = v - 2 * (s[1] + 1)
				if(os >= 0 && os < 12) la = max(la, 1 + 0.4 * (1 - (os / 40) / 0.3))
			if(!isnull(kflip))
				var/of = v - 2 * kflip
				var/af = of / 40
				if(of >= 0 && of < 4)
					sc *= 1 + 0.05 * sin(180 * af / 0.1)
					la = max(la, 1.5)
			if(!isnull(kf) && v >= 2 * kf)
				var/u = min(1, (v - 2 * kf) / 3)
				sc = 1 + 0.05 * u
				la = 1 + 1.2 * u
				Rec(out, "cf", "UL", "BigBangMisc", "flash", x, y, 0, 1.5 + 2.5 * u, 1.5 + 2.5 * u, 0.4 + 0.6 * u, lm, 0)
			var/fr = BeamFXMod(floor((v - 2 * O.k_spawn) / 2), EFXO_SN_NF)
			var/st = pre ? "rest_[fr]" : "fly_[fr]"
			var/ang = pre ? 0 : SunHeadV(O, (!isnull(kf) && v > 2 * kf) ? 2 * kf : v)
			Rec(out, "sp", "UP", "SupernovaSun", "[st]_0", x, y + z, ang, sc, sc, 1, null, 5)
			Rec(out, "sl", "UL", "SupernovaSun", "[st]_1", x, y + z, ang, sc, sc, 1, EFXOLMa(lm, la), 0)
			if(pre)
				conv.Sprites(src, out, tv, x, y + z, R_ * sc * 0.95, "c", "UL", lm)
				if(EFXOAgeF(v, O.k_spawn, "lt", 0.1))
					var/q = (tv - O.k_spawn * EFXO_TICK) / 0.1
					Rec(out, "st", "UL", "NovaMisc", "star", x, y + z, 0, 1.4 + 0.8 * q, 1.4 + 0.8 * q, 1 - q, lm, 0)
			for(var/i = 1 to strikes.len)
				var/list/s = strikes[i]
				var/oh = v - 2 * (s[1] + 1)
				var/h_ = oh / 40
				if(oh >= 0 && oh < 14)
					var/lx = x + cos(s[2]) * (R_ - 6)
					var/ly = y + z + sin(s[2]) * (R_ - 6)
					Rec(out, "hs[i]", "UL", "BigBangMisc", "flash", lx, ly, s[2], 1.3, 1.9, 0.9 * (1 - h_ / 0.35), lm, 0)
	if(blast && d >= 0 && d < EFXO_SN_NFADE && pexe)
		var/kbs = 1.05 + 0.05 * (d + 1)
		Rec(out, "bu", "XP", "SupernovaBurst", "[d]_0", bx, by, hd, kbs, kbs, 1, null, 5.5)
		Rec(out, "bl", "XL", "SupernovaBurst", "[d]_1", bx, by, hd, kbs, kbs, 1, EFXOLMa(lm, 1.8), 0)
	if(blast)
		blast.Body(src, out, d, "b")
		blast.Particles(src, out, null, t, "b")
	return out

/datum/energyfx_orbs/supernova/Busy(k)
	var/v = 2 * k + 1
	if(conv.Alive(v / EFXO_FPS)) return 1
	if(blast && blast.Alive(v / EFXO_FPS, v - 2 * kb)) return 1
	for(var/datum/energyfx_orbcounter/E in counters)
		if(E.blast && E.blast.Alive(v / EFXO_FPS, v - 2 * (E.kc + 1))) return 1
	for(var/list/s in strikes)
		if(v / EFXO_FPS - (s[1] + 1) * EFXO_TICK < 0.35) return 1
	var/datum/energyfx_orbshot/O = Shot()
	if(O && isnull(O.k_end) && isnull(kf)) return 1
	return 0

/datum/energyfx_orbcolors/proc/SetupColors(datum/energyfx_colors/C)
	canon = 0
	anchor = 0
	main255 = C.main255 ? C.main255 : list(0, 0, 0)
	core255 = C.core255
	glow255 = C.glow255
	gray = C.gray
	bright = C.bright
	ramp = BeamFXRamp(gray ? list(153, 153, 153) : main255, core255, glow255)
	pal = EFXOPalette(main255, core255, glow255)

proc/EFXOE4Set(re)
	var/rs = 16
	for(var/r in list(16, 32, 48, 64, 80))
		if(r <= re) rs = r
	return rs

/datum/energyfx_orbs/burst
	var/datum/energyfx_orbcolors/cols
	var/datum/energyfx_orbblast3/blast
	var/kb

/datum/energyfx_orbs/burst/proc/Start(turf/T, Re, datum/energyfx_row/R, datum/energyfx_colors/C, datum/energyfx_look/orbs/L)
	look = L
	row = R
	extra = R ? R.extra : null
	zz = T.z
	K0 = EnergyFXNow() - 2
	parity = glob && glob.ENERGYFX_ORB_LOG
	if(parity) OL("G [energyfx_orb_log_tag] burst [K0]")
	cols = new
	cols.SetupColors(C)
	kb = Now()
	var/rs = EFXOE4Set(Re)
	var/ek = (rs == 48) ? "B3E4_48TB" : "B3E4_[rs]G"
	var/gk = "B3Ground[rs][cols.gray ? "G" : ""]"
	blast = new(Stream("b3"), Re, (T.x - 1) * 32 + 16, (T.y - 1) * 32 + 16, kb, null, ek, gk, cols.LM("hl"), EFXO_LM_SCORCH)
	blast.e4 = ek
	blast.e4m = EFXOE4Mats(ek, cols.pal)
	blast.lm_flash = cols.LM("flash")
	blast.fl_kinds = list("XP", "XS", cols.LK("XL"))
	blast.dsc = Re / rs
	if(parity) OL("E 0 burst [kb] [Re] [rs]")
	look.scenes += src
	Loop()

/datum/energyfx_orbs/burst/Draw(fi, v)
	var/list/out = list()
	var/t = fi / EFXO_FPS
	var/d = v - 2 * kb
	blast.Scorch(src, out, d, "b")
	blast.Ground(src, out, d, "b", cols.LK("GL"))
	var/list/sm = list()
	blast.Particles(src, list(), sm, t, "b", cols.LK("XL"))
	out += sm
	blast.Body(src, out, d, "b")
	blast.Particles(src, out, null, t, "b", cols.LK("XL"))
	return out

/datum/energyfx_orbs/burst/Busy(k)
	var/v = 2 * k + 1
	return blast && blast.Alive(v / EFXO_FPS, v - 2 * kb)

/datum/energyfx_look/orbs/Burst(turf/T, radius, datum/energyfx_row/row, datum/energyfx_colors/C)
	if(!T || !C || radius < 2) return 0
	var/datum/energyfx_orbs/burst/S = new
	S.Start(T, 16 * radius, row, C, src)
	return 1

/obj/energyfx/orb/lp
	plane = EFXO_LG_PLANE

proc/EFXOBasePlane()
	var/obj/fxlight_into_base/L = /obj/fxlight_into_base
	return initial(L.plane)

proc/EFXOGlowOK()
	return glob && glob.LIGHTING && glob.DYNAMIC_LIGHTS && glob.MULTIPLY_REVEAL

proc/EFXOGk(age, a, b, c)
	if(age < 0) return 0
	return EFXOExp(-max(0, age - a) / b) * min(1, (age + 0.025) / c)

/datum/energyfx_orbs/proc/Glow(list/out, key, x, y, r, strength, list/col)
	if(strength <= 0.002 || !col || !EFXOGlowOK()) return
	var/turf/T = locate(floor(x / 32) + 1, floor(y / 32) + 1, zz)
	if(!T) return
	var/list/amb = LightAmbientRGB(T)
	var/ceil = LightPaintCeiling(amb)
	var/lim = 1000
	for(var/i = 1 to 3)
		lim = min(lim, (ceil - amb[i]) / 255 / max(col[i], 0.001))
	var/b = min(strength, lim)
	if(b <= 0.002) return
	b -= LightStaticPaintAt(T) / 255
	if(b <= 0.002) return
	var/sc = r / EFXO_POOL_R0
	for(var/list/s in out)
		if(s.len < 15 || s[EO_KIND] != "LP" || s[EO_SX] != sc || abs(s[EO_X] - x) >= 0.5 || abs(s[EO_Y] - y) >= 0.5) continue
		var/list/c0 = s[15]
		if(c0[1] != col[1] || c0[2] != col[2] || c0[3] != col[3]) continue
		if(b > s[14])
			s[14] = b
			s[EO_COL] = list(0, 0, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, 0, 0, 0, col[1], col[2], col[3], 0)
		return
	Rec(out, "gw[key]", "LP", "OrbGlowPool", "pool", x, y, 0, sc, sc, 1, list(0, 0, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, 0, 0, 0, col[1], col[2], col[3], 0), 6.6)
	var/list/s2 = out[out.len]
	s2.len = 15
	s2[14] = b
	s2[15] = col

/datum/energyfx_orbs/proc/AddGlows(list/out, v)

/datum/energyfx_orbs/proc/RecOf(list/out, key)
	for(var/list/s in out)
		if(s[EO_KEY] == key) return s
	return null

/datum/energyfx_orbs/proc/BlastGlow(list/out, datum/energyfx_orbblast3/B, v, k, s, a, b, c, list/col, key = "b")
	if(!B) return
	var/age = (v - 2 * B.kh) / EFXO_FPS
	Glow(out, key, B.x, B.y, B.Re * k, s * EFXOGk(age, a, b, c), col)

/datum/energyfx_orbs/spirit/AddGlows(list/out, v)
	for(var/datum/energyfx_orbshot/O in shots)
		var/list/h = RecOf(out, "h[O.idx]p")
		if(h) Glow(out, "o[O.idx]", h[EO_X], h[EO_Y] - 6, 16 * 2.2, 0.35, EFXO_SB_TL)
		if(O.hits.len)
			var/list/e = O.hits[1]
			var/list/p = O.DrawnT(e[1] * EFXO_TICK)
			if(p) Glow(out, "h[O.idx]", p[1], p[2], 60, 0.7 * EFXOGk((v - 2 * e[1]) / EFXO_FPS, 0.12, 0.3, 0.1), EFXO_SB_TL)

/datum/energyfx_orbs/jecht/AddGlows(list/out, v)
	for(var/datum/energyfx_orbshot/O in shots)
		var/list/h = RecOf(out, "bp[O.idx]")
		if(h) Glow(out, "o[O.idx]", h[EO_X], h[EO_Y] - 6, 36, 0.4 * h[EO_AL], EFXO_JT_TL)
		for(var/i = 1 to O.hits.len)
			var/list/e = O.hits[i]
			var/mob/T = e[2]
			if(!ismob(T)) continue
			Glow(out, "h[O.idx]_[i]", (T.x - 1) * 32 + T.step_x + 16 - 9, (T.y - 1) * 32 + T.step_y + 16, 56, 0.6 * EFXOGk((v - 2 * e[1]) / EFXO_FPS, 0.08, 0.25, 0.075), EFXO_JT_TL)

/datum/energyfx_orbs/bigbang/var/glow_key = "bp"
/datum/energyfx_orbs/bigbang/var/glow_dy = -8
/datum/energyfx_orbs/bigbang/var/glow_r = 3
/datum/energyfx_orbs/bigbang/var/glow_s = 0.45
/datum/energyfx_orbs/bigbang/var/glow_bk = 1.6
/datum/energyfx_orbs/bigbang/var/glow_bs = 0.9
/datum/energyfx_orbs/bigbang/var/list/glow_bt = list(0.15, 0.35, 0.1)

/datum/energyfx_orbs/bigbang/AddGlows(list/out, v)
	var/list/h = glow_key ? RecOf(out, glow_key) : null
	if(h) Glow(out, "o", h[EO_X], h[EO_Y] + glow_dy, R_ * glow_r * h[EO_SX], glow_s * h[EO_SX], tlc)
	if(blast) BlastGlow(out, blast, v, glow_bk, glow_bs, glow_bt[1], glow_bt[2], glow_bt[3], tlc)

/datum/energyfx_orbs/sgm/glow_dy = -10
/datum/energyfx_orbs/sgm/glow_r = 2.6
/datum/energyfx_orbs/sgm/glow_s = 0.55
/datum/energyfx_orbs/sgm/glow_bs = 0.95
/datum/energyfx_orbs/sgm/glow_bt = list(0.2, 0.45, 0.1)

/datum/energyfx_orbs/omega/glow_bs = 0.95
/datum/energyfx_orbs/omega/glow_bt = list(0.2, 0.45, 0.1)

/datum/energyfx_orbs/omega/AddGlows(list/out, v)
	var/list/h = RecOf(out, "bp")
	if(h) Glow(out, "o", h[EO_X], h[EO_Y] - 8, R_ * h[EO_SX] * 1.8, 0.45, tlc)
	if(blast) BlastGlow(out, blast, v, glow_bk, glow_bs, glow_bt[1], glow_bt[2], glow_bt[3], tlc)

/datum/energyfx_orbs/tracking/AddGlows(list/out, v)
	var/list/h = RecOf(out, "bp")
	var/list/l = RecOf(out, "bl")
	if(h) Glow(out, "o", h[EO_X], h[EO_Y] - 6, 36, 0.4 * ((l && l.len >= 14) ? l[14] : 1), tlc)
	if(blast) BlastGlow(out, blast, v, 1.6, 0.9, 0.15, 0.35, 0.1, tlc)

/datum/energyfx_orbs/nova/AddGlows(list/out, v)
	var/datum/energyfx_orbshot/O = Shot()
	if(O && RecOf(out, "sp"))
		var/list/p = PosV(O, v)
		if(p) Glow(out, "o", p[1], p[2] - 6, R_ * p[4] * 2.4, 0.5 * p[4], tlc)
	if(blast) BlastGlow(out, blast, v, 1.8, 0.9, 0.15, 0.35, 0.1, tlc)

/datum/energyfx_orbs/stealth/AddGlows(list/out, v)
	if(blast) BlastGlow(out, blast, v, 1.6, 0.9, 0.15, 0.35, 0.1, tlc)

/datum/energyfx_orbs/deathball/AddGlows(list/out, v)
	var/datum/energyfx_orbshot/O = Shot()
	var/list/h = RecOf(out, "op")
	if(O && h && !isnull(gx) && (!blast || EFXOTvLt(v, blast.kh)))
		var/z = h[EO_Y] - cy0
		var/gb = 0.5 * min(1, ((v - 2 * O.k_spawn) / EFXO_FPS) / 0.3) * (0.7 + 0.3 * (1 - z / EFXO_DB_HOVER))
		Glow(out, "o", gx, gy + 8, EFXO_DB_R * 1.9, gb, tlc)
	if(blast && EFXOTvGe(v, blast.kh)) BlastGlow(out, blast, v, 1.6, 0.9, 0.15, 0.35, 0.1, EFXO_DB_BTL)

/datum/energyfx_orbs/pillar/AddGlows(list/out, v)
	if(isnull(mx)) return
	if(isnull(kf) || EFXOTvLt(v, kf)) Glow(out, "o", mx, my, 24, 0.25, tlc)
	if(!isnull(ke) && EFXOTvGe(v, ke)) Glow(out, "e", mx, gy + 10, 76, 0.9 * EFXOGk((v - 2 * ke) / EFXO_FPS, 0.5, 0.35, 0.1), tlc)

/datum/energyfx_orbs/catac/AddGlows(list/out, v)
	var/list/tl = EFXOLitColor(cols)
	var/list/h = RecOf(out, "op")
	if(h) Glow(out, "o", h[EO_X], h[EO_Y] - 6, EFXO_CO_R * 2.8, 0.4, tl)
	if(carrier && !isnull(carrier.k_end))
		var/list/pe = carrier.DrawnT(carrier.k_end * EFXO_TICK)
		if(pe) Glow(out, "e", pe[1], pe[2], 40, 0.7 * EFXOGk((v - 2 * carrier.k_end) / EFXO_FPS, 0.1, 0.25, 0.075), tl)

/datum/energyfx_orbs/supernova/AddGlows(list/out, v)
	var/datum/energyfx_orbshot/O = Shot()
	if(O && RecOf(out, "sp"))
		var/list/p = SunPos(O, v)
		if(p) Glow(out, "o", p[1], p[2] - 12, R_ * p[4] * 1.3 * 1.6, 0.5, tlc)
	for(var/datum/energyfx_orbcounter/E in counters)
		if(E.blast)
			BlastGlow(out, E.blast, v, 1.6, 0.8, 0.12, 0.3, 0.08, E.cols ? EFXOLitColor(E.cols) : tlc, "c[E.idx]")
	if(blast) BlastGlow(out, blast, v, 1.6, 0.95, 0.25, 0.6, 0.1, tlc)

/datum/energyfx_orbs/burst/AddGlows(list/out, v)
	if(blast) BlastGlow(out, blast, v, 1.6, 0.9, 0.15, 0.35, 0.1, EFXOLitColor(cols))

/datum/energyfx_orbcounter/var/datum/energyfx_orbcolors/cols
