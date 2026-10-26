// good fucking lord man

proc/OugiEaseFlags(e)
	if(!istext(e) || !e) return LINEAR_EASING
	var/list/p = splittext(lowertext(e), "_")
	var/f = LINEAR_EASING
	switch(p[1])
		if("sine") f = SINE_EASING
		if("quad") f = QUAD_EASING
		if("cubic") f = CUBIC_EASING
		if("circular", "circ") f = CIRCULAR_EASING
		if("back") f = BACK_EASING
		if("bounce") f = BOUNCE_EASING
		if("elastic") f = ELASTIC_EASING
		if("jump") f = JUMP_EASING
	if(p.len >= 2)
		switch(p[2])
			if("in") f |= EASE_IN
			if("out") f |= EASE_OUT
			if("inout") f |= EASE_IN | EASE_OUT
	return f

proc/OugiShapeState(list/a, list/prev, take_xy)
	var/list/s = prev ? prev.Copy() : list("scale" = 1, "sx" = 1, "sy" = 1, "angle" = 0, "kx" = 0, "ky" = 0, "x" = 0, "y" = 0, "alpha" = 255, "flip" = 0)
	if(!a) return s
	for(var/k in list("scale", "sx", "sy", "angle", "alpha"))
		if(isnum(a[k])) s[k] = a[k]
	if(isnum(a["skew_x"])) s["kx"] = a["skew_x"]
	if(isnum(a["skew_y"])) s["ky"] = a["skew_y"]
	if(take_xy)
		if(isnum(a["x"])) s["x"] = a["x"]
		if(isnum(a["y"])) s["y"] = a["y"]
	return s

proc/OugiShapeMatrix(list/s)
	var/matrix/M = matrix()
	M.Scale(s["scale"] * s["sx"] * (s["flip"] ? -1 : 1), s["scale"] * s["sy"])
	if(s["kx"] || s["ky"])
		M.Multiply(matrix(1, tan(s["kx"]), 0, tan(s["ky"]), 1, 0))
	if(s["angle"]) M.Turn(s["angle"])
	return M

/datum/ougi_scene/proc/OugiShapeApply(list/a, obj/Effects/OugiFX/F, is_fx)
	if(!F || !a) return
	var/list/keys = ArgText(a, "keys", null)
	var/has_keys = islist(keys) && keys.len

	var/shaped = has_keys || isnum(ArgNum(a, "angle", null)) || isnum(ArgNum(a, "sx", null)) || isnum(ArgNum(a, "sy", null)) || isnum(ArgNum(a, "skew_x", null)) || isnum(ArgNum(a, "skew_y", null))
	if(!is_fx && isnum(ArgNum(a, "scale", null))) shaped = 1
	if(!shaped) return
	var/list/s = OugiShapeState(a, null, 0)
	s["flip"] = is_fx ? a["flip"] : 0
	var/riding = F.ougi_ride ? 1 : 0
	var/matrix/M0 = OugiShapeMatrix(s)
	if(riding)
		var/list/r = F.ougi_ride
		r[4] = matrix(M0)
		RiderFollow(F)
	else
		F.transform = M0
	if(!has_keys) return
	var/bx = F.pixel_x
	var/by = F.pixel_y
	var/xy = !a["throw_to"]

	var/matrix_lerp = (ArgText(a, "lerp", null) == "matrix")
	var/t = 0
	var/first = 1
	for(var/list/k in keys)
		if(!islist(k)) continue
		var/kt = isnum(k["t"]) ? max(t, k["t"]) : t
		var/list/n = OugiShapeState(k, s, 1)
		if(istext(k["state"])) OugiKeyState(F, k["state"], Ds(kt))
		var/e = OugiEaseFlags(k["ease"])
		var/span = Ds(kt - t)
		var/steps = max(1, ceil(span / world.tick_lag - 0.001))
		var/turn = n["angle"] - s["angle"]
		turn -= 360 * floor((turn + 180) / 360)
		var/matrix/M0s = matrix_lerp ? OugiShapeMatrix(s) : null
		var/matrix/M1s = matrix_lerp ? OugiShapeMatrix(n) : null
		for(var/i = 1 to steps)
			var/p = (span > 0) ? OugiEase(i / steps, e) : 1
			var/list/c = OugiShapeLerp(s, n, p, turn)
			var/px = xy ? round(bx + c["x"], 1) : F.pixel_x
			var/py = xy ? round(by + c["y"], 1) : F.pixel_y
			var/al = round(c["alpha"], 1)
			var/st = span / steps
			if(riding)
				if(first) animate(F, pixel_x = px, pixel_y = py, alpha = al, time = st, flags = ANIMATION_PARALLEL)
				else animate(pixel_x = px, pixel_y = py, alpha = al, time = st)
			else
				var/matrix/X = matrix_lerp ? OugiMatrixLerp(M0s, M1s, p) : OugiShapeMatrix(c)
				if(first) animate(F, transform = X, pixel_x = px, pixel_y = py, alpha = al, time = st, flags = ANIMATION_PARALLEL | ANIMATION_LINEAR_TRANSFORM)
				else animate(transform = X, pixel_x = px, pixel_y = py, alpha = al, time = st, flags = ANIMATION_LINEAR_TRANSFORM)
			first = 0
		s = n
		t = kt


proc/OugiKeyState(obj/Effects/OugiFX/F, st, delay)
	set waitfor = 0
	if(delay > 0) sleep(delay)
	if(F) F.icon_state = st // attached pieces ride in vis_contents with no loc

proc/OugiShapeLerp(list/s, list/n, p, turn)
	var/list/c = s.Copy()
	for(var/k in list("scale", "sx", "sy", "kx", "ky", "x", "y", "alpha"))
		c[k] = s[k] + (n[k] - s[k]) * p
	c["angle"] = s["angle"] + turn * p
	return c

proc/OugiMatrixLerp(matrix/A, matrix/B, p)
	return matrix(A.a + (B.a - A.a) * p, A.b + (B.b - A.b) * p, A.c + (B.c - A.c) * p, A.d + (B.d - A.d) * p, A.e + (B.e - A.e) * p, A.f + (B.f - A.f) * p)


/datum/ougi_scene/var/tmp/ougi_fx_seq = 0

/datum/ougi_scene/proc/OugiFxOrder(list/a, obj/Effects/OugiFX/F)
	ougi_fx_seq++
	var/nudge = ArgNum(a, "layer", 0)
	if(F.layer < MOB_LAYER)
		F.layer = MOB_LAYER - 0.1 + clamp(nudge * 0.001 + ougi_fx_seq * 0.00005, -0.09, 0.095)
	else
		F.layer += nudge * 0.1 + ougi_fx_seq * 0.002

/datum/ougi_scene/OpFX(list/a)
	var/obj/Effects/OugiFX/F = ..()
	if(!F) return F
	OugiFxLostAnchor(a, F)
	OugiFxOrder(a, F)
	OugiShapeApply(a, F, 1)
	return F

/datum/ougi_scene/OpProp(list/a)
	var/obj/Effects/OugiFX/S = ..()
	if(!S) return S
	OugiFxOrder(a, S)
	if(ArgNum(a, "restart", 0)) flick(S.icon_state || S.icon, S)
	OugiShapeApply(a, S, 0)
	return S


/datum/ougi_scene/var/list/ougi_alpha_runs
/datum/ougi_scene/var/list/ougi_alpha_orig

/datum/ougi_scene/DoOp(op, list/a)
	if(op == "actor_fade") return OpActorFade(a)
	return ..()

/datum/ougi_scene/proc/ActorAlphaAt(mob/M, t)
	var/list/r = ougi_alpha_runs ? ougi_alpha_runs[M] : null
	if(!r) return M.alpha
	if(r[4] <= 0 || t >= r[3] + r[4]) return r[2]
	return round(r[1] + (r[2] - r[1]) * OugiEase((t - r[3]) / r[4], r[5]), 1)

/datum/ougi_scene/proc/OpActorFade(list/a)
	var/w = ArgText(a, "who", "attacker")
	var/list/L = (w == "both") ? list(attacker, target) : list(Who(w))
	for(var/mob/M in L)
		if(!(M in actors)) continue
		if(!ougi_alpha_orig) ougi_alpha_orig = list()
		if(isnull(ougi_alpha_orig[M])) ougi_alpha_orig[M] = M.alpha
		var/a0 = ActorAlphaAt(M, world.time)
		if(!ougi_alpha_runs) ougi_alpha_runs = list()
		ougi_alpha_runs[M] = list(a0, clamp(ArgNum(a, "alpha", 0), 0, 255), world.time, Ds(ArgNum(a, "time", 3)), OugiEaseFlags(ArgText(a, "ease", "linear")))
		ActorRelay(M)

/datum/ougi_scene/ReturnActor(mob/M)
	if(M && ougi_alpha_orig && !isnull(ougi_alpha_orig[M]))
		animate(M)
		M.alpha = ougi_alpha_orig[M]
		ougi_alpha_orig -= M
	if(M && ougi_alpha_runs) ougi_alpha_runs -= M
	..()

// decodes shit early to try to avoid lag. not perfect
/obj/ougi_screen/warm
	layer = 1
	alpha = 1

/datum/ougi_scene/var/tmp/list/ougi_warm_objs

/datum/ougi_scene/proc/OugiWarmCollect(v, list/out, state)
	if(islist(v))
		var/list/L = v
		var/st = state
		if(L.len && !isnull(L["state"]) && istext(L["state"])) st = L["state"]
		for(var/k in L)
			if(istext(k) && !isnull(L[k])) OugiWarmCollect(L[k], out, st)
			else OugiWarmCollect(k, out, st)
		return
	if(isicon(v) || isfile(v))
		out["[v]|[state]"] = list(v, istext(state) ? state : "")

/datum/ougi_scene/FlashIn()
	..()
	var/list/found = list()
	for(var/list/beat in beats)
		if(beat.len >= 3) OugiWarmCollect(beat[3], found, "")
	if(run_prelude && prelude)
		for(var/list/beat in prelude)
			if(beat.len >= 3) OugiWarmCollect(beat[3], found, "")
	if(!found.len) return
	ougi_warm_objs = list()
	var/matrix/tiny = matrix()
	tiny.Scale(0.02)
	for(var/k in found)
		var/list/p = found[k]
		var/obj/ougi_screen/warm/W = new
		W.icon = p[1]
		W.icon_state = p[2]
		W.transform = tiny
		ougi_warm_objs += W
	for(var/client/C in clients)
		C.screen += ougi_warm_objs
	spawn(OUGI_FLASH_DS + OUGI_WIPE_IN_DS + OUGI_WIPE_HOLD_DS) OugiWarmClear()

/datum/ougi_scene/proc/OugiWarmClear()
	if(!ougi_warm_objs) return
	for(var/client/C in clients)
		C.screen -= ougi_warm_objs
	for(var/obj/O in ougi_warm_objs)
		del O
	ougi_warm_objs = null

/datum/ougi_scene/End(force = 0)
	OugiWarmClear()
	..()


/datum/ougi_scene/var/tmp/list/ougi_actor_spot

/datum/ougi_scene/DoOp(op, list/a)
	for(var/role in list("attacker", "target"))
		var/mob/M = Who(role)
		if(M && M.loc && room && M.z == room.z && (M in actors))
			if(!ougi_actor_spot) ougi_actor_spot = list()
			var/list/p = ActorPixelAt(M, world.time)
			ougi_actor_spot[role] = list(M.loc, p[1], p[2], M.step_x, M.step_y)
	return ..()

/datum/ougi_scene/proc/OugiFxLostAnchor(list/a, obj/Effects/OugiFX/F)
	var/at = ArgText(a, "at", "target")
	if(at != "attacker" && at != "target") return
	var/mob/M = Who(at)
	if(M && M.loc && room && M.z == room.z) return
	var/list/s = ougi_actor_spot ? ougi_actor_spot[at] : null
	if(!s || !s[1]) return
	F.loc = s[1]
	F.step_x = s[4]
	F.step_y = s[5]
	F.pixel_x = round(ArgNum(a, "x", 0) + s[2], 1)
	F.pixel_y = round(ArgNum(a, "y", 0) + s[3], 1)
