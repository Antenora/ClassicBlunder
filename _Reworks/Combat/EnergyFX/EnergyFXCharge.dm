/obj/energyfx/chghost
	icon = ENERGYFX_CHG_HOST_ICON
	icon_state = ""

/obj/energyfx/chgglow
	icon = ENERGYFX_CHG_POOL_ICON
	icon_state = "l_pool"
	blend_mode = BLEND_ADD
	layer = 6.55
	pixel_x = -80
	pixel_y = -32

var/list/ENERGYFX_CHG_LIVE = list()

proc/EnergyFXChgNow()
	return round(world.time * 4, 1)

proc/EnergyFXChgRound(x)
	var/f = floor(x)
	var/d = x - f
	if(d > 0.5) return f + 1
	if(d < 0.5) return f
	return (f % 2) ? f + 1 : f

proc/EnergyFXChgR3(x)
	return EnergyFXChgRound(x * 1000) / 1000

proc/EnergyFXChgRotate(tf0, al0, list/steps, t_off)
	if(!t_off) return list(tf0, al0, steps)
	var/acc = 0
	var/tf = tf0
	var/al = al0
	for(var/i = 1 to steps.len)
		var/list/s = steps[i]
		if(acc == t_off)
			return list(tf, al, steps.Copy(i) + steps.Copy(1, i))
		if(acc < t_off && t_off < acc + s[1])
			if(s[2]) tf = s[2]
			if(!isnull(s[3])) al = s[3]
			var/list/out = list(list(acc + s[1] - t_off, s[2], s[3]))
			out += steps.Copy(i + 1)
			out += steps.Copy(1, i)
			out[++out.len] = list(t_off - acc, s[2], s[3])
			return list(tf, al, out)
		if(s[2]) tf = s[2]
		if(!isnull(s[3])) al = s[3]
		acc += s[1]
	return list(tf0, al0, steps)

proc/EnergyFXChgRamp(a0, a1, dur)
	if(dur <= 0 || a0 == a1) return list(list(max(dur, ENERGYFX_CHG_DT_Q), null, a1))
	var/n = max(1, floor(dur / ENERGYFX_CHG_DT_Q))
	var/list/out = list()
	for(var/k = 1 to n)
		out[++out.len] = list(ENERGYFX_CHG_DT_Q, null, EnergyFXChgRound(a0 + (a1 - a0) * k / n))
	return out

proc/EnergyFXChgAt(list/tr, t)
	if(!tr) return 0
	var/e = t - tr[1]
	var/v = tr[2]
	if(e < 0) return v
	for(var/list/s in tr[3])
		if(e < s[1]) return isnull(s[3]) ? v : s[3]
		if(!isnull(s[3])) v = s[3]
		e -= s[1]
	return v

proc/EnergyFXChgRawBucket(lv)
	var/b = 0
	for(var/i = 1 to ENERGYFX_CHG_EDGES.len)
		if(lv >= ENERGYFX_CHG_EDGES[i]) b = i - 1
	return b

proc/EnergyFXChgBudget(list/cp, want)
	return max(0, min(want, cp[1]) - cp[2])

/datum/energyfx_streaks
	var/atom/movable/M
	var/list/colors
	var/ramp_ds = 0
	var/ramp_q = 0
	var/overhead = 0
	var/level = 0
	var/bucket = -1
	var/rb = -1
	var/started = 0
	var/t_on = 0
	var/live = 0
	var/vn = "normal"
	var/gray = 0
	var/list/rgb
	var/list/ramp
	var/light_k = 1
	var/glow_k = 1
	var/lift = 0
	var/list/paint_m
	var/list/light_m
	var/ks_icon = 1
	var/mscale = 1
	var/ks0 = 1
	var/ks = 1
	var/gq = 1
	var/cx0 = 0
	var/cy0 = 0
	var/ax = 0
	var/ay = 0
	var/crowd_n = 1
	var/drop = 0
	var/ak = 1
	var/t_off = 0
	var/obj/energyfx/carrier
	var/obj/energyfx/ghost
	var/obj/energyfx/glow
	var/obj/energyfx/gpulse
	var/list/g_cp
	var/g_gs = 0
	var/g_lo = 1
	var/g_refa = 0
	var/g_refb = 0
	var/list/objs
	var/list/ca_tr

/datum/energyfx_charge
	var/mob/M
	var/obj/Skills/Z
	var/datum/energyfx_row/row
	var/datum/energyfx_colors/colors
	var/level = 0
	var/started = 0

/atom/movable/var/tmp/datum/energyfx_streaks/energyfx_streaks
/mob/var/tmp/datum/energyfx_charge/energyfx_charge

/datum/energyfx_streaks/proc/Now()
	return EnergyFXChgNow()

/datum/energyfx_streaks/proc/Dice()
	t_off = rand(0, ENERGYFX_CHG_PERIOD_Q / 2 - 1) * 2

/datum/energyfx_streaks/proc/Ambient(turf/T)
	return LightAmbientRGB(T)

/datum/energyfx_streaks/proc/StaticPaint(turf/T)
	return LightStaticPaintAt(T)

/datum/energyfx_streaks/proc/Put(obj/energyfx/O, tf, al, col)
	if(tf) O.transform = tf
	if(!isnull(al)) O.alpha = al
	if(col) O.color = col

/datum/energyfx_streaks/proc/Run(obj/energyfx/O, list/steps, loop = 0)
	var/n = 0
	var/lp = loop ? -1 : 1
	for(var/list/s in steps)
		var/tf = s[2]
		var/al = s[3]
		var/tm = s[1] * 0.25
		if(!n)
			if(tf && !isnull(al)) animate(O, transform = tf, alpha = al, time = tm, loop = lp, easing = ENERGYFX_STEP_EASING)
			else if(tf) animate(O, transform = tf, time = tm, loop = lp, easing = ENERGYFX_STEP_EASING)
			else animate(O, alpha = al, time = tm, loop = lp, easing = ENERGYFX_STEP_EASING)
		else
			if(tf && !isnull(al)) animate(transform = tf, alpha = al, time = tm, easing = ENERGYFX_STEP_EASING)
			else if(tf) animate(transform = tf, time = tm, easing = ENERGYFX_STEP_EASING)
			else animate(alpha = al, time = tm, easing = ENERGYFX_STEP_EASING)
		n++
	energyfx_anim_n += n

/datum/energyfx_streaks/proc/Get(path, atom/movable/parent, flags = 0)
	if(!parent) return null
	var/obj/energyfx/O = EnergyFXGet(path, "a charge")
	if(!O) return null
	O.appearance_flags = flags
	if(path == /obj/energyfx/chgglow)
		var/obj/fx_occlight/L = /obj/fx_occlight
		O.plane = initial(L.plane)
	parent.vis_contents += O
	O.fx_car = parent
	objs += O
	return O

/datum/energyfx_streaks/proc/Start(atom/movable/m, list/c, r_ds, oh)
	M = m
	colors = c
	ramp_ds = max(0, r_ds)
	ramp_q = EnergyFXChgRound(ramp_ds * 4)
	overhead = oh
	started = world.time
	t_on = Now()
	objs = list()
	Dice()
	Paint()
	Size()
	Crowd()
	if(!Build())
		Drop()
		return 0
	live = 1
	M.energyfx_streaks = src
	ENERGYFX_CHG_LIVE += src
	Begin()
	return 1

/datum/energyfx_streaks/proc/Paint()
	var/c = (colors && colors.len) ? colors[1] : null
	if(istext(c)) c = BeamFXHexRGB(c)
	if(!islist(c) || length(c) < 3) c = list(ENERGYFX_CHG_GRAY_R, ENERGYFX_CHG_GRAY_G, ENERGYFX_CHG_GRAY_B)
	var/list/hsv = BeamFXRGB2HSV(c[1] / 255, c[2] / 255, c[3] / 255)
	if(hsv[2] < ENERGYFX_CHG_GRAY_SAT)
		gray = 1
		rgb = list(ENERGYFX_CHG_GRAY_R, ENERGYFX_CHG_GRAY_G, ENERGYFX_CHG_GRAY_B)
	else
		gray = 0
		var/hd = hsv[1] * 360
		if(hd >= ENERGYFX_CHG_VIOLET_LO && hd <= ENERGYFX_CHG_VIOLET_HI) hd = min(ENERGYFX_CHG_VIOLET_HI, hd + ENERGYFX_CHG_VIOLET_SHIFT)
		var/list/o = BeamFXHSV2RGB(hd / 360, max(hsv[2], ENERGYFX_CHG_SAT_FLOOR), max(hsv[3], ENERGYFX_CHG_VAL_FLOOR))
		rgb = list(EnergyFXChgRound(o[1] * 255 + 0.0001), EnergyFXChgRound(o[2] * 255 + 0.0001), EnergyFXChgRound(o[3] * 255 + 0.0001))
	var/lum = BeamFXLum(list(rgb[1] / 255, rgb[2] / 255, rgb[3] / 255))
	if(gray)
		lift = ENERGYFX_CHG_GRAY_LIFT
		light_k = ENERGYFX_CHG_GRAY_LIGHT_K
		glow_k = 1
	else
		light_k = EnergyFXChgR3(min(1, max(ENERGYFX_CHG_DARK_LIGHT_MIN, (lum / ENERGYFX_CHG_DARK_LUM) ** 2)))
		lift = EnergyFXChgR3(ENERGYFX_CHG_DARK_LIFT * clamp((ENERGYFX_CHG_DARK_LUM - lum) / ENERGYFX_CHG_DARK_LUM, 0, 1))
		glow_k = (lum < ENERGYFX_CHG_DARK_LUM) ? ENERGYFX_CHG_DARK_GLOW_K : 1
	var/list/R = BeamFXRamp(rgb, null, null)
	var/list/lc = R[1]
	var/list/core = R[3]
	var/list/lcore = R[4]
	var/list/e0 = R[2]
	var/list/edge = list(0, 0, 0)
	for(var/i = 1 to 3)
		edge[i] = e0[i] + (core[i] - e0[i]) * lift
	ramp = list(lc, edge, core, lcore)
	paint_m = list(core[1] - edge[1], core[2] - edge[2], core[3] - edge[3], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, edge[1], edge[2], edge[3], 0)
	var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : 1
	var/g = light_k / ls
	light_m = list((lcore[1] - lc[1]) * g, (lcore[2] - lc[2]) * g, (lcore[3] - lc[3]) * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)

/datum/energyfx_streaks/proc/Size()
	var/list/sz = BeamFXIconSize(M)
	ks_icon = sz[2] / 32
	mscale = 1
	var/matrix/T = M.transform
	if(T)
		var/d = abs(T.a * T.e - T.b * T.d)
		if(d > 0) mscale = sqrt(d)
	var/total = ks_icon * mscale
	if(total >= ENERGYFX_CHG_BIG_MIN)
		vn = "big"
		ks0 = sqrt(total) / mscale
	else
		vn = "normal"
		ks0 = ks_icon
	ks = ks0
	gq = ks_icon / ks0
	cx0 = sz[1] / 2 - 16
	cy0 = sz[2] / 2 - 16
	ax = overhead ? ENERGYFX_CHG_ANCHOR_OVER_X : ENERGYFX_CHG_ANCHOR_BODY_X
	ay = overhead ? ENERGYFX_CHG_ANCHOR_OVER_Y : ENERGYFX_CHG_ANCHOR_BODY_Y

/datum/energyfx_streaks/proc/Anchor()
	var/list/c = BeamFXImageCenter(M)
	var/k = ks0 * mscale
	return list(c[1] + k * ax, c[2] + k * ay)

/datum/energyfx_streaks/proc/CrowdCount()
	var/list/me = Anchor()
	var/n = 1
	var/near = -1
	var/list/dead
	for(var/datum/energyfx_streaks/O in ENERGYFX_CHG_LIVE)
		if(O == src) continue
		if(!O.M || O.M.energyfx_streaks != O)
			if(!dead) dead = list()
			dead += O
			continue
		if(O.M.z != M.z) continue
		var/list/p = O.Anchor()
		var/dx = p[1] - me[1]
		var/dy = p[2] - me[2]
		var/d = sqrt(dx * dx + dy * dy)
		if(d > ENERGYFX_CHG_CROWD_R) continue
		n++
		if(near < 0 || d < near) near = d
	if(dead)
		for(var/datum/energyfx_streaks/D in dead)
			D.Drop()
	return list(n, near)

/datum/energyfx_streaks/proc/Crowd()
	var/list/c = CrowdCount()
	var/n = c[1]
	var/near = c[2]
	crowd_n = n
	drop = 0
	ak = 1
	for(var/list/st in ENERGYFX_CHG_CROWD)
		if(n >= st[1])
			drop = st[2]
			ak = st[3]
	var/sk = 1
	if(n >= 2 && near >= 0) sk = min(1, ENERGYFX_CHG_CROWD_NEAR_K * near / (ENERGYFX_CHG_CROWD_REACH * ks0 * mscale))
	ks = EnergyFXChgR3(ks0 * sk)

/datum/energyfx_streaks/proc/CAlpha(b)
	return EnergyFXChgRound(ENERGYFX_CHG_ALPHA[b + 1] * ak)

/datum/energyfx_streaks/proc/CarrierTf(k)
	return matrix(k, 0, cx0 + ks * ax, 0, k, cy0 + ks * ay)

/datum/energyfx_streaks/proc/Build()
	return 0

/datum/energyfx_streaks/proc/Begin()
	Plan(t_on, 0)

/datum/energyfx_streaks/proc/Plan(t, lv)
	level = max(0, lv)
	rb = EnergyFXChgRawBucket(level)
	var/b0 = max(0, rb - drop)
	bucket = b0
	var/a_on = CAlpha(b0)
	var/list/cs = list()
	for(var/k = 1 to ENERGYFX_CHG_ON_STEPS)
		cs[++cs.len] = list(ENERGYFX_CHG_DT_Q, null, EnergyFXChgRound(a_on * k / ENERGYFX_CHG_ON_STEPS))
	var/amax = a_on
	if(ramp_q > 0)
		var/el = ENERGYFX_CHG_DT_Q * ENERGYFX_CHG_ON_STEPS
		var/cur = a_on
		var/done = b0
		for(var/b = 2 to ENERGYFX_CHG_EDGES.len)
			var/e = ENERGYFX_CHG_EDGES[b]
			if(e > max(level, 1)) break
			var/bb = max(0, (b - 1) - drop)
			if(bb <= done) continue
			var/tb = EnergyFXChgRound(ramp_q * (e - level) / max(0.000001, 1 - level) / ENERGYFX_CHG_TICK_Q) * ENERGYFX_CHG_TICK_Q
			if(tb > el)
				cs[++cs.len] = list(tb - el, null, cur)
				el = tb
			var/list/rs = EnergyFXChgRamp(cur, CAlpha(bb), ENERGYFX_CHG_LEVEL_Q)
			cs += rs
			for(var/list/s in rs)
				el += s[1]
			cur = CAlpha(bb)
			amax = max(amax, cur)
			done = bb
	Put(carrier, CarrierTf(ks), 0)
	Run(carrier, cs, 0)
	ca_tr = list(t, 0, cs)
	GlowIssue(t, cs, 0, amax)

/datum/energyfx_streaks/proc/Level(lv)
	if(!live) return
	var/t = Now()
	if(t <= t_on)
		Plan(t_on, lv)
		return
	level = max(0, lv)
	rb = EnergyFXChgRawBucket(level)
	var/b = max(0, rb - drop)
	if(b == bucket) return
	var/cur = EnergyFXChgRound(EnergyFXChgAt(ca_tr, t))
	var/list/cs = EnergyFXChgRamp(cur, CAlpha(b), ENERGYFX_CHG_LEVEL_Q)
	Run(carrier, cs, 0)
	ca_tr = list(t, cur, cs)
	bucket = b
	GlowIssue(t, cs, cur, CAlpha(b))

/datum/energyfx_streaks/proc/GlowAllowed()
	return glob && glob.LIGHTING && glob.DYNAMIC_LIGHTS && glob.MULTIPLY_REVEAL && M && isturf(M.loc)

/datum/energyfx_streaks/proc/GlowColor()
	var/list/lc = ramp[1]
	var/list/col = list(lc[1], lc[2], lc[3])
	if(bucket >= ENERGYFX_CHG_GLOW_WHITE_AT)
		for(var/i = 1 to 3)
			col[i] = col[i] + (1 - col[i]) * ENERGYFX_CHG_GLOW_WHITE_K
	if(gray)
		for(var/i = 1 to 3)
			col[i] = col[i] * light_k
	return col

/datum/energyfx_streaks/proc/Cap(list/col)
	var/turf/T = M.loc
	var/list/amb = Ambient(T)
	var/ceil = LightPaintCeiling(amb)
	var/lim = 1000
	for(var/i = 1 to 3)
		lim = min(lim, (ceil - amb[i]) / 255 / max(col[i], 0.001))
	return list(lim, StaticPaint(T) / 255)

/datum/energyfx_streaks/proc/GlowSteps(alo)
	var/P = ENERGYFX_CHG_PERIOD_Q
	var/list/vts = list()
	for(var/v in ENERGYFX_CHG_PULSES[vn])
		var/x = ((v - t_off) % P + P) % P
		var/j = 1
		while(j <= vts.len && vts[j] <= x)
			j++
		vts.Insert(j, x)
	var/list/out = list()
	var/cur = 0
	for(var/vt in vts)
		if(vt > cur) out[++out.len] = list(vt - cur, null, alo)
		out[++out.len] = list(ENERGYFX_CHG_GLOW_PULSE_Q, null, 255)
		cur = vt + ENERGYFX_CHG_GLOW_PULSE_Q
	if(P > cur) out[++out.len] = list(P - cur, null, alo)
	return out

/datum/energyfx_streaks/proc/GlowLo(a)
	return EnergyFXChgBudget(g_cp, g_gs * a / 255 * g_lo)

/datum/energyfx_streaks/proc/GlowHi(a)
	return EnergyFXChgBudget(g_cp, g_gs * a / 255) - GlowLo(a)

/datum/energyfx_streaks/proc/GlowHide()
	if(glow) Run(glow, list(list(ENERGYFX_CHG_DT_Q, null, 0)), 0)
	if(ghost) Run(ghost, list(list(ENERGYFX_CHG_DT_Q, null, 0)), 0)
	g_refa = 0
	g_refb = 0

/datum/energyfx_streaks/proc/GlowIssue(t, list/cs, a0, amax)
	if(amax <= 0 || !GlowAllowed())
		GlowHide()
		return
	var/list/col = GlowColor()
	g_cp = Cap(col)
	g_gs = ENERGYFX_CHG_GLOW_GAIN * glow_k
	g_lo = EnergyFXChgRound(255 / (1 + ENERGYFX_CHG_GLOW_PULSE)) / 255
	var/list/st = GlowSteps(0)
	var/tot = 0
	for(var/list/s in st)
		tot += s[1]
	var/pulse = st.len >= 2 && tot > 0
	if(!pulse) g_lo = 1
	g_refa = GlowLo(amax)
	g_refb = 0
	if(pulse)
		g_refb = GlowHi(a0)
		for(var/list/s in cs)
			if(!isnull(s[3])) g_refb = max(g_refb, GlowHi(s[3]))
	if(g_refa <= 0 && g_refb <= 0)
		GlowHide()
		return
	var/matrix/gtf = matrix(0.5 * gq, 0, ENERGYFX_CHG_GLOW_OX * gq, 0, 0.5 * gq, ENERGYFX_CHG_GLOW_OY * gq)
	if(!glow)
		glow = Get(/obj/energyfx/chgglow, carrier, RESET_ALPHA)
		if(!glow) return
		Put(glow, gtf)
	Put(glow, null, null, list(0, 0, 0, 0, col[1] * g_refa, col[2] * g_refa, col[3] * g_refa, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
	if(pulse && g_refb > 0)
		if(!ghost)
			ghost = Get(/obj/energyfx/chghost, carrier, RESET_ALPHA)
			if(ghost)
				gpulse = Get(/obj/energyfx/chgglow, ghost)
				if(gpulse) Put(gpulse, gtf)
		if(gpulse)
			var/list/r = EnergyFXChgRotate(null, 0, st, (t - t_on) % tot)
			Put(gpulse, null, 0, list(0, 0, 0, 0, col[1] * g_refb, col[2] * g_refb, col[3] * g_refb, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
			Run(gpulse, r[3], 1)
	else if(ghost)
		Run(ghost, list(list(ENERGYFX_CHG_DT_Q, null, 0)), 0)
	GlowEnvelope(cs, a0)

/datum/energyfx_streaks/proc/GlowEnvelope(list/cs, a0)
	if(glow && g_refa > 0)
		var/list/ha = list()
		for(var/list/s in cs)
			ha[++ha.len] = list(s[1], null, isnull(s[3]) ? null : min(255, EnergyFXChgRound(255 * GlowLo(s[3]) / g_refa)))
		Put(glow, null, min(255, EnergyFXChgRound(255 * GlowLo(a0) / g_refa)))
		Run(glow, ha, 0)
	if(ghost && gpulse && g_refb > 0)
		var/list/hb = list()
		for(var/list/s in cs)
			hb[++hb.len] = list(s[1], null, isnull(s[3]) ? null : min(255, EnergyFXChgRound(255 * GlowHi(s[3]) / g_refb)))
		Put(ghost, null, min(255, EnergyFXChgRound(255 * GlowHi(a0) / g_refb)))
		Run(ghost, hb, 0)

/datum/energyfx_streaks/proc/Flash(cur)
	if(!GlowAllowed()) return
	var/list/col = GlowColor()
	var/list/cp = Cap(col)
	var/gs = ENERGYFX_CHG_GLOW_GAIN * glow_k * ENERGYFX_CHG_FLASH_K
	var/fa = cur / 255
	var/hi = EnergyFXChgBudget(cp, gs * fa)
	if(hi <= 0) return
	var/obj/energyfx/F = Get(/obj/energyfx/chgglow, M, KEEP_APART | RESET_COLOR)
	if(!F) return
	var/qq = gq * ENERGYFX_CHG_FLASH_SCALE
	Put(F, matrix(0.5 * qq * ks, 0, ks * ENERGYFX_CHG_GLOW_OX * gq + cx0 + ks * ax, 0, 0.5 * qq * ks, ks * ENERGYFX_CHG_GLOW_OY * gq + cy0 + ks * ay), 0, list(0, 0, 0, 0, col[1] * hi, col[2] * hi, col[3] * hi, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
	var/n = ENERGYFX_CHG_FLASH_FADE_Q / 2
	var/list/st = list(list(ENERGYFX_CHG_FLASH_HOLD_Q, null, 255))
	for(var/j = 1 to n)
		var/v = round(255 * fa * (1 - j / n), 0.01)
		st[++st.len] = list(2, null, EnergyFXChgRound(255 * EnergyFXChgBudget(cp, gs * v / 255) / hi))
	Run(F, st, 0)

/datum/energyfx_streaks/proc/Off()
	return

/datum/energyfx_streaks/proc/Drop()
	live = 0
	ENERGYFX_CHG_LIVE -= src
	if(M && M.energyfx_streaks == src) M.energyfx_streaks = null
	for(var/obj/energyfx/O in objs)
		EnergyFXFree(O)
	objs = list()
	carrier = null
	ghost = null
	glow = null
	gpulse = null

proc/EnergyFXStreaksOn(atom/movable/M, list/colors, ramp_ds = 0, overhead = 0)
	if(!M || !glob || !glob.ENERGYFX || !ENERGYFX_CHG_ASSETS) return null
	if(M.energyfx_streaks) M.energyfx_streaks.Drop()
	var/datum/energyfx_streaks/S = new
	if(!S.Start(M, colors, ramp_ds, overhead)) return null
	return S

proc/EnergyFXStreaksLevel(atom/movable/M, frac)
	if(!M || !M.energyfx_streaks) return
	M.energyfx_streaks.Level(frac)

proc/EnergyFXStreaksOff(atom/movable/M)
	if(!M || !M.energyfx_streaks) return
	M.energyfx_streaks.Off()

proc/EnergyFXChargeOn(mob/M, obj/Skills/Z)
	if(!M || !Z) return 0
	var/datum/energyfx_row/R = EnergyFXRow(Z)
	if(!R) return 0
	if(M.energyfx_charge)
		M.energyfx_charge.M = null
		M.energyfx_charge = null
	var/datum/energyfx_charge/C = new
	C.M = M
	C.Z = Z
	C.row = R
	C.colors = (R.extra && R.extra["canon"]) ? EnergyFXResolveColors(null, null, null, R.def_main, R.def_core, R.def_glow) : EnergyFXSkillColors(Z, R)
	C.started = world.time
	M.energyfx_charge = C
	var/datum/energyfx_colors/K = C.colors
	if(!(R.extra && R.extra["no_streaks"])) EnergyFXStreaksOn(M, list(K.main255, K.core255, K.glow255), 0, Z.IconChargeOverhead)
	if(EnergyFXChargeDrawing(M, Z) && hascall(R.handler, "MobCharge")) call(R.handler, "MobCharge")(M, Z)
	return EnergyFXChargeDrawing(M, Z)

proc/EnergyFXChargeLevel(mob/M, frac)
	if(!M || !M.energyfx_charge) return
	var/datum/energyfx_charge/C = M.energyfx_charge
	C.level = max(0, frac)
	EnergyFXStreaksLevel(M, frac)

proc/EnergyFXChargeOff(mob/M)
	if(!M || !M.energyfx_charge) return
	var/datum/energyfx_charge/C = M.energyfx_charge
	C.M = null
	M.energyfx_charge = null
	EnergyFXStreaksOff(M)

proc/EnergyFXChargeDrawing(mob/M, obj/Skills/Z)
	var/datum/energyfx_row/R = EnergyFXRow(Z)
	return (R && R.handler && R.extra && R.extra["own_charge"]) ? 1 : 0

/mob/EnergyFXChargeHook(obj/Skills/Z)
	return EnergyFXChargeOn(src, Z)

/mob/EnergyFXChargeDraws(obj/Skills/Z)
	if(!energyfx_charge || energyfx_charge.Z != Z) return 0
	return EnergyFXChargeDrawing(src, Z)

/mob/EnergyFXChargeTick(obj/Skills/Z, frac)
	if(!energyfx_charge || energyfx_charge.Z != Z) return
	if(Z.HeldBeam && held_skill == Z) frac = HeldBeamBenefit(Z)
	EnergyFXChargeLevel(src, frac)

/mob/EnergyFXChargeClear()
	EnergyFXChargeOff(src)
