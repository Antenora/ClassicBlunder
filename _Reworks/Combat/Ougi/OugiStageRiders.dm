/obj/Effects/OugiFX
	var/tmp/list/ougi_ride

/datum/ougi_scene
	var
		list/ougi_pose_runs

var/list/ougi_icon_sizes = list()

proc/OugiIconSize(ic)
	if(!ic) return list(world.icon_size, world.icon_size)
	var/list/s = ougi_icon_sizes[ic]
	if(!s)
		var/icon/I = icon(ic)
		s = I ? list(I.Width(), I.Height()) : list(world.icon_size, world.icon_size)
		ougi_icon_sizes[ic] = s
	return s

proc/OugiEase(p, easing)
	p = clamp(p, 0, 1)
	var/kind = easing & ~(EASE_IN | EASE_OUT)
	var/io = easing & (EASE_IN | EASE_OUT)
	if(kind == SINE_EASING)
		if(io == EASE_IN) return 1 - cos(90 * p)
		if(io == EASE_OUT) return sin(90 * p)
		return 0.5 - 0.5 * cos(180 * p)
	if(kind == QUAD_EASING || kind == CUBIC_EASING)
		var/n = (kind == QUAD_EASING) ? 2 : 3
		if(io == EASE_IN) return p ** n
		if(io == EASE_OUT) return 1 - (1 - p) ** n
		return p < 0.5 ? (2 ** (n - 1)) * p ** n : 1 - (2 ** (n - 1)) * (1 - p) ** n
	return p

/datum/ougi_scene/OpFX(list/a)
	var/obj/Effects/OugiFX/F = ..()
	if(!F) return F
	if(ArgNum(a, "flip", 0))
		var/matrix/FM = matrix(F.transform)
		FM.Scale(-1, 1)
		F.transform = FM
	var/at = ArgText(a, "at", "target")
	if(!ArgNum(a, "attach", 0) || (at != "attacker" && at != "target")) return F
	var/mob/M = Who(at)
	if(!M || !(M in actors) || F.loc != M.loc) return F
	var/list/fs = OugiIconSize(F.icon)
	var/list/ms = OugiIconSize(M.icon)
	F.loc = null
	F.step_x = 0
	F.step_y = 0
	F.pixel_x = ArgNum(a, "x", 0)
	F.pixel_y = ArgNum(a, "y", 0)
	F.gfx_transient_visual = 1
	F.appearance_flags |= KEEP_APART | RESET_COLOR | RESET_ALPHA
	F.ougi_ride = list(M, F.pixel_x + fs[1] / 2 - ms[1] / 2, F.pixel_y + fs[2] / 2 - ms[2] / 2, matrix(F.transform))
	M.vis_contents += F
	RiderFollow(F)
	return F

/datum/ougi_scene/ActorPose(mob/M, time, easing = LINEAR_EASING)
	var/list/p0 = ActorPoseAt(M, world.time)
	var/s1 = actor_scales ? actor_scales[M] : null
	var/g1 = actor_turns ? actor_turns[M] : null
	if(!isnum(s1)) s1 = 1
	if(!isnum(g1)) g1 = 0
	var/d = g1 - p0[2]
	d -= 360 * floor((d + 180) / 360)
	if(!ougi_pose_runs) ougi_pose_runs = list()
	ougi_pose_runs[M] = list(p0[1], p0[2], s1, p0[2] + d, world.time, time, easing)
	..()
	for(var/obj/Effects/OugiFX/F in M.vis_contents)
		if(F.ougi_ride) RiderFollow(F)

/datum/ougi_scene/proc/ActorPoseAt(mob/M, t)
	var/list/r = ougi_pose_runs ? ougi_pose_runs[M] : null
	if(!r) return list(1, 0)
	var/p = (r[6] > 0) ? OugiEase((t - r[5]) / r[6], r[7]) : 1
	return list(r[1] + (r[3] - r[1]) * p, r[2] + (r[4] - r[2]) * p)

/datum/ougi_scene/proc/RiderMatrix(obj/Effects/OugiFX/F, t)
	var/list/r = F.ougi_ride
	var/mob/M = r[1]
	var/list/p = ActorPoseAt(M, t)
	var/matrix/A = M.ougi_return_transform ? matrix(M.ougi_return_transform) : matrix()
	A.Scale(p[1])
	if(p[2]) A.Turn(p[2])
	var/det = A.a * A.e - A.b * A.d
	var/matrix/X = matrix(r[4])
	if(!det) return X
	var/vx = r[2]
	var/vy = r[3]
	X.Translate(vx - (A.e * vx - A.b * vy) / det, vy - (A.a * vy - A.d * vx) / det)
	return X

/datum/ougi_scene/proc/RiderFollow(obj/Effects/OugiFX/F)
	var/mob/M = F.ougi_ride[1]
	var/list/run = ougi_pose_runs ? ougi_pose_runs[M] : null
	var/now = world.time
	var/done = run ? run[5] + run[6] : now
	if(done <= now)
		animate(F, transform = RiderMatrix(F, now), time = 0)
		return
	var/n = max(1, ceil((done - now) / world.tick_lag))
	var/last = now
	for(var/k = 1 to n)
		var/tk = (k == n) ? done : now + k * world.tick_lag
		if(k == 1) animate(F, transform = RiderMatrix(F, tk), time = tk - last)
		else animate(transform = RiderMatrix(F, tk), time = tk - last)
		last = tk

/datum/ougi_scene/ReturnActor(mob/M)
	if(M)
		var/list/R = list()
		for(var/obj/Effects/OugiFX/F in M.vis_contents)
			if(F in temp_atoms) R += F
		for(var/obj/Effects/OugiFX/F in R)
			temp_atoms -= F
			GfxReleaseAtom(F)
			del F
		if(ougi_pose_runs) ougi_pose_runs -= M
	..()
