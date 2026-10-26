/datum/ougi_scene
	var
		list/ougi_move_runs

/datum/ougi_scene/proc/ActorRunPixel(list/r, t)
	if(r[6] <= 0 || t >= r[5] + r[6]) return list(r[3], r[4])
	var/p = OugiEase((t - r[5]) / r[6], r.len >= 7 ? r[7] : SINE_EASING)
	return list(r[1] + (r[3] - r[1]) * p, r[2] + (r[4] - r[2]) * p)

/datum/ougi_scene/proc/ActorPixelAt(mob/M, t)
	var/list/r = ougi_move_runs ? ougi_move_runs[M] : null
	if(!r || t >= r[5] + r[6] || M.pixel_x != r[3] || M.pixel_y != r[4]) return list(M.pixel_x, M.pixel_y)
	return ActorRunPixel(r, t)

/datum/ougi_scene/proc/ActorPoseMatrixAt(mob/M, t)
	var/list/p = ActorPoseAt(M, t)
	var/matrix/T = M.ougi_return_transform ? matrix(M.ougi_return_transform) : matrix()
	T.Scale(p[1])
	if(p[2]) T.Turn(p[2])
	return T

/datum/ougi_scene/proc/ActorMoveRun(mob/M, px, py, time, easing = SINE_EASING)
	var/list/p0 = ActorPixelAt(M, world.time)
	if(!ougi_move_runs) ougi_move_runs = list()
	ougi_move_runs[M] = list(p0[1], p0[2], px, py, world.time, time, easing)
	ActorRelay(M)

/datum/ougi_scene/proc/ActorRelay(mob/M)
	var/now = world.time
	var/list/mr = ougi_move_runs ? ougi_move_runs[M] : null
	var/list/pr = ougi_pose_runs ? ougi_pose_runs[M] : null
	var/list/tr = FighterTintRec(M)
	if(tr && !OugiSceneTintRecAt(tr)) tr = null
	var/list/marks = list()
	var/list/bends = list()
	if(mr && mr[5] + mr[6] > now)
		marks += mr[5] + mr[6]
		bends += list(list(mr[5], mr[5] + mr[6]))
	if(pr && pr[5] + pr[6] > now)
		marks += pr[5] + pr[6]
		if(abs(pr[4] - pr[2]) > 90) marks += pr[5] + pr[6] / 2
		if(pr[7] != LINEAR_EASING) bends += list(list(pr[5], pr[5] + pr[6]))
	if(tr)
		var/te = tr[1] + tr[2] + tr[3] + tr[4]
		marks += list(tr[1] + tr[2], tr[1] + tr[2] + tr[3], te, te + world.tick_lag)
	var/list/ar = ougi_alpha_runs ? ougi_alpha_runs[M] : null
	if(ar && ar[3] + ar[4] > now)
		marks += ar[3] + ar[4]
		if(ar[5] != LINEAR_EASING) bends += list(list(ar[3], ar[3] + ar[4]))
	var/E = now
	for(var/m in marks)
		E = max(E, m)
	var/step = world.tick_lag * max(1, ceil((E - now) / (world.tick_lag * OUGI_RELAY_STEPS)))
	var/n = ceil((E - now) / step - 0.001)
	var/list/times = list(now)
	var/last = now
	for(var/k = 1 to n)
		var/g = (k == n) ? E : now + k * step
		for(var/j = 1 to marks.len)
			var/nx = g
			for(var/m in marks)
				if(m > last + 0.001 && m < nx - 0.001) nx = m
			if(nx >= g) break
			times += nx
			last = nx
		var/keep = (k == n)
		for(var/m in marks)
			if(abs(m - g) <= 0.001) keep = 1
		for(var/list/b in bends)
			if(g > b[1] && g < b[2]) keep = 1
		if(keep)
			times += g
			last = g
	for(var/i = 1 to times.len)
		var/t = times[i]
		var/list/p = mr ? ActorRunPixel(mr, t) : list(M.pixel_x, M.pixel_y)
		var/px = round(p[1], 1)
		var/py = round(p[2], 1)
		var/matrix/X = ActorPoseMatrixAt(M, t)
		var/dt = (i == 1) ? 0 : t - times[i - 1]
		var/al = ActorAlphaAt(M, t)
		if(!tr)
			if(i == 1) animate(M, pixel_x = px, pixel_y = py, transform = X, alpha = al, time = 0)
			else animate(pixel_x = px, pixel_y = py, transform = X, alpha = al, time = dt)
			continue
		var/list/c = OugiSceneTintRecAt(tr, t)
		if(i > 1 && tr[4] <= 0 && abs(t - tr[1] - tr[2] - tr[3]) <= 0.001)
			animate(pixel_x = px, pixel_y = py, transform = X, color = tr[5], alpha = al, time = dt)
			dt = 0
			c = OugiSceneTintRecAt(tr, t + 0.001)
		if(i == 1) animate(M, pixel_x = px, pixel_y = py, transform = X, color = c, alpha = al, time = 0)
		else animate(pixel_x = px, pixel_y = py, transform = X, color = c, alpha = al, time = dt)

/datum/ougi_scene/OugiSceneMobPoint(mob/M)
	var/list/c = ..()
	var/list/p = ActorPixelAt(M, world.time)
	return list(c[1] + p[1] - M.pixel_x, c[2] + p[2] - M.pixel_y)

/datum/ougi_scene/OpGhost(list/a)
	var/obj/ougi_actor/G = ..()
	if(!G) return G
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	G.dir = M.dir
	var/list/p = ActorPixelAt(M, world.time)
	if(p[1] != M.pixel_x || p[2] != M.pixel_y)
		G.pixel_x = round(p[1] + ArgNum(a, "dx", 0), 1)
		G.pixel_y = round(p[2] + ArgNum(a, "dy", 0), 1)
	var/list/run = ougi_pose_runs ? ougi_pose_runs[M] : null
	if(run && world.time < run[5] + run[6]) G.transform = ActorPoseMatrixAt(M, world.time)
	return G

/datum/ougi_scene/OpFX(list/a)
	var/obj/Effects/OugiFX/F = ..()
	var/at = ArgText(a, "at", "target")
	if(!F || !F.loc || (at != "attacker" && at != "target")) return F
	var/mob/M = Who(at)
	if(!M) return F
	var/list/p = ActorPixelAt(M, world.time)
	if(p[1] == M.pixel_x && p[2] == M.pixel_y) return F
	F.pixel_x = round(ArgNum(a, "x", 0) + p[1], 1)
	F.pixel_y = round(ArgNum(a, "y", 0) + p[2], 1)
	return F

/datum/ougi_scene/ReturnActor(mob/M)
	if(M && ougi_move_runs) ougi_move_runs -= M
	..()
