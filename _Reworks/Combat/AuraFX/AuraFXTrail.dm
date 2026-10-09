var/list/aurafx_dir8 = list(EAST, NORTHEAST, NORTH, NORTHWEST, WEST, SOUTHWEST, SOUTH, SOUTHEAST)
var/list/aurafx_rot_m = new /list(3601)
var/list/aurafx_arc_s
var/list/aurafx_arc_fi
var/list/aurafx_arc_mi
var/list/aurafx_arc_bi

proc/AuraFXDir8(dx, dy)
	var/i = round(arctan(dx, dy) / 45, 1)
	i = ((i % 8) + 8) % 8
	return aurafx_dir8[i + 1]

proc/AuraFXUnitX(d)
	if(d & EAST) return (d & (NORTH | SOUTH)) ? 0.70710678 : 1
	if(d & WEST) return (d & (NORTH | SOUTH)) ? -0.70710678 : -1
	return 0

proc/AuraFXUnitY(d)
	if(d & NORTH) return (d & (EAST | WEST)) ? 0.70710678 : 1
	if(d & SOUTH) return (d & (EAST | WEST)) ? -0.70710678 : -1
	return 0

proc/AuraFXDirDeg(d)
	return arctan(AuraFXUnitX(d), AuraFXUnitY(d))

proc/AuraFXWrap180(a)
	while(a >= 180)
		a -= 360
	while(a < -180)
		a += 360
	return a

proc/AuraFXRotM(rq)
	var/i = clamp(round((rq + 180) * 10, 1) + 1, 1, 3601)
	var/matrix/M = aurafx_rot_m[i]
	if(!M)
		M = matrix()
		M.Turn(180 - (i - 1) / 10)
		aurafx_rot_m[i] = M
	return M

proc/AuraFXArcPlan()
	if(aurafx_arc_s) return
	var/list/S = list()
	for(var/s in aurafx_fly_knots)
		for(var/v in list(s - aurafx_tan_h, s, s + aurafx_tan_h))
			if(!(v in S)) S += v
	for(var/a = 2 to S.len)
		var/v = S[a]
		var/b = a - 1
		while(b >= 1 && S[b] > v)
			S[b + 1] = S[b]
			b--
		S[b + 1] = v
	var/list/FI = list()
	var/list/MI = list()
	var/list/BI = list()
	for(var/s in aurafx_fly_knots)
		FI += S.Find(s - aurafx_tan_h)
		MI += S.Find(s)
		BI += S.Find(s + aurafx_tan_h)
	aurafx_arc_fi = FI
	aurafx_arc_mi = MI
	aurafx_arc_bi = BI
	aurafx_arc_s = S

/datum/aurafx_rig
	var
		list/hx = list()
		list/hy = list()
		hz = 0
		has_pos = 0
		travel = SOUTH
		fast_until = 0
		fly_kind = 0
		t_take = -1
		kb_dir = 0
		stop_faded = 0
		list/arc_px = list()
		list/arc_py = list()
		chain_steady
		chain_snap = 1
		obj/aurafx/paint/fp
		obj/aurafx/light/fl
		list/tps = list()
		list/tls = list()
		list/seg_px = list()
		list/seg_py = list()
		list/seg_d = list()
		list/seg_a = list()
		list/seg_rot = list()
		list/seg_ox = list()
		list/seg_oy = list()

/datum/aurafx_rig/proc/HistReset(X, Y)
	hx = list(X)
	hy = list(Y)

/datum/aurafx_rig/proc/HistPush(X, Y)
	hx.Insert(1, X)
	hy.Insert(1, Y)
	if(hx.len > 8)
		hx.len = 8
		hy.len = 8

/datum/aurafx_rig/proc/SegReset(K)
	seg_px = new /list(K)
	seg_py = new /list(K)
	seg_d = new /list(K)
	seg_a = new /list(K)
	seg_rot = new /list(K)
	for(var/j = 1 to K)
		seg_rot[j] = 0

/datum/aurafx_rig/proc/FlyStates(kind, tag)
	var/pre = kind == 1 ? "f" : "k"
	var/K = kind == 1 ? aurafx_k_fly : aurafx_k_kb
	if(!fp) fp = Make(/obj/aurafx/paint, null, AURAFX_L_FLYP, aurafx_fly_px, aurafx_fly_py)
	if(!fl) fl = Make(/obj/aurafx/light, null, AURAFX_L_FLYL, aurafx_fly_px, aurafx_fly_py)
	while(tps.len > K)
		Drop(tps[tps.len])
		Drop(tls[tls.len])
		tps.len--
		tls.len--
	while(tps.len < K)
		tps += Make(/obj/aurafx/apart, null, AURAFX_L_TAILP, 0, 0)
		tls += Make(/obj/aurafx/light, null, AURAFX_L_TAILL, 0, 0)
	SegReset(K)
	seg_ox = new /list(K)
	seg_oy = new /list(K)
	chain_steady = null
	animate(fp)
	animate(fl)
	var/list/show = list("[pre][tag]hp", "[pre][tag]hl")
	AuraFXPlaceArt(fp, show[1], aurafx_fly_px, aurafx_fly_py)
	AuraFXPlaceArt(fl, show[2], aurafx_fly_px, aurafx_fly_py)
	fp.alpha = 255
	fl.alpha = 255
	for(var/j = 1 to K)
		var/obj/aurafx/P = tps[j]
		var/obj/aurafx/L = tls[j]
		var/sp = "[pre][tag][j]p"
		var/sl = "[pre][tag][j]l"
		animate(P)
		animate(L)
		AuraFXSwapArt(P, sp)
		AuraFXSwapArt(L, sl)
		seg_ox[j] = aurafx_art_dx[sp] - aurafx_tail_half
		seg_oy[j] = aurafx_art_dy[sp] - aurafx_tail_half
		show += sp
		show += sl
		P.alpha = 255
		L.alpha = 255
		P.transform = null
		L.transform = null
	Put(fp)
	Put(fl)
	for(var/j = 1 to K)
		Put(tps[j])
		Put(tls[j])
	KeepArt(show)
	fly_kind = kind

/datum/aurafx_rig/proc/FlyDrop()
	Drop(fp)
	Drop(fl)
	fp = null
	fl = null
	for(var/obj/aurafx/O in tps)
		Drop(O)
	for(var/obj/aurafx/O in tls)
		Drop(O)
	tps = list()
	tls = list()
	SegReset(0)
	seg_ox = list()
	seg_oy = list()
	fly_kind = 0
	t_take = -1
	for(var/obj/aurafx/O in list(hp, hl))
		animate(O)
		O.alpha = 255

/datum/aurafx_rig/proc/IdleAlpha(a)
	for(var/obj/aurafx/O in list(hp, hl))
		animate(O)
		O.alpha = a

/datum/aurafx_rig/proc/StartComet(kind, now)
	var/d = kind == 2 ? kb_dir : travel
	FlyStates(kind, "t")
	fp.dir = d
	fl.dir = d
	IdleAlpha(0)
	t_take = now
	ChainFixed(d, kind == 2 ? aurafx_kb_cx : aurafx_fly_cx, kind == 2 ? aurafx_kb_cy : aurafx_fly_cy)
	SetMode(kind == 2 ? AURAFX_M_KB : AURAFX_M_FLY, now)
	SparkRegion()

/datum/aurafx_rig/proc/TakeoffTick(now)
	if(t_take < 0 || now - t_take < aurafx_take_ticks) return 0
	t_take = -1
	FlyStates(fly_kind, "")
	var/d = fly_kind == 2 ? kb_dir : travel
	fp.dir = d
	fl.dir = d
	return 1

/datum/aurafx_rig/proc/StartStop(now)
	var/d = fly_kind == 2 ? kb_dir : travel
	FlyStates(fly_kind, "s")
	fp.dir = d
	fl.dir = d
	t_take = -1
	stop_faded = 0
	SetMode(AURAFX_M_STOP, now)
	ChainStop(0)
	SparkRegion()

/datum/aurafx_rig/proc/SetSeg(j, px, py, d, a)
	if(seg_px[j] == px && seg_py[j] == py && seg_d[j] == d && seg_a[j] == a && seg_rot[j] == 0) return
	seg_px[j] = px
	seg_py[j] = py
	seg_d[j] = d
	seg_a[j] = a
	seg_rot[j] = 0
	for(var/obj/aurafx/O in list(tps[j], tls[j]))
		animate(O)
		O.pixel_x = px
		O.pixel_y = py
		O.dir = d
		O.alpha = a
		O.transform = null

/datum/aurafx_rig/proc/SetSegRot(j, px, py, d, a, r)
	var/rq = round(r, 0.1)
	if(seg_px[j] == px && seg_py[j] == py && seg_d[j] == d && seg_a[j] == a && seg_rot[j] == rq) return
	seg_px[j] = px
	seg_py[j] = py
	seg_d[j] = d
	seg_a[j] = a
	seg_rot[j] = rq
	var/matrix/T = AuraFXRotM(rq)
	for(var/obj/aurafx/O in list(tps[j], tls[j]))
		animate(O)
		O.pixel_x = px
		O.pixel_y = py
		O.dir = d
		O.alpha = a
		O.transform = T

/datum/aurafx_rig/proc/SetSegGlideRot(j, px, py, d, a, r)
	var/rq = round(r, 0.1)
	if(seg_px[j] == px && seg_py[j] == py && seg_d[j] == d && seg_a[j] == a && seg_rot[j] == rq) return
	var/obj/aurafx/P0 = tps[j]
	var/flip = P0.dir != d
	var/r0 = flip ? round(AuraFXWrap180(AuraFXDirDeg(P0.dir) + seg_rot[j] - AuraFXDirDeg(d)), 0.1) : seg_rot[j]
	var/snap = abs(rq - r0) > 150
	var/matrix/T0 = flip ? AuraFXRotM(r0) : null
	var/matrix/T = AuraFXRotM(rq)
	seg_px[j] = px
	seg_py[j] = py
	seg_d[j] = d
	seg_a[j] = a
	seg_rot[j] = rq
	for(var/obj/aurafx/O in list(tps[j], tls[j]))
		if(flip)
			O.dir = d
			O.transform = T0
		if(snap)
			O.transform = T
			animate(O, pixel_x = px, pixel_y = py, alpha = a, time = world.tick_lag)
		else
			animate(O, transform = T, pixel_x = px, pixel_y = py, alpha = a, time = world.tick_lag)

/datum/aurafx_rig/proc/SetSegPos(j, px, py, d)
	if(seg_px[j] == px && seg_py[j] == py && seg_d[j] == d && seg_rot[j] == 0) return
	seg_px[j] = px
	seg_py[j] = py
	seg_d[j] = d
	seg_rot[j] = 0
	for(var/obj/aurafx/O in list(tps[j], tls[j]))
		O.pixel_x = px
		O.pixel_y = py
		O.dir = d
		O.transform = null

/datum/aurafx_rig/proc/ChainFixed(d, list/cxs, list/cys)
	var/ux = AuraFXUnitX(d)
	var/uy = AuraFXUnitY(d)
	var/cx = cxs[d]
	var/cy = cys[d]
	var/list/kn = fly_kind == 2 ? aurafx_kb_knots : aurafx_fly_knots
	for(var/j = 1 to tps.len)
		var/s = kn[j]
		var/ax = cx + round(-s * ux, 1)
		var/ay = cy + round(s * uy, 1)
		SetSeg(j, ax + seg_ox[j], 32 - ay + seg_oy[j], d, 255)

/datum/aurafx_rig/proc/ChainStop(e)
	var/d = fly_kind == 2 ? kb_dir : travel
	var/i = clamp(e + 1, 1, aurafx_stop_ticks)
	var/list/UX = aurafx_stop_ux[d]
	var/list/UY = aurafx_stop_uy[d]
	if(!UX || !UY) return
	var/ux = UX[i]
	var/uy = UY[i]
	var/cx = aurafx_stand_cx[d]
	var/cy = aurafx_stand_cy[d]
	var/list/kn = fly_kind == 2 ? aurafx_kb_knots : aurafx_fly_knots
	for(var/j = 1 to tps.len)
		var/s = kn[j]
		var/ax = cx + round(s * ux, 1)
		var/ay = cy + round(s * uy, 1)
		SetSegPos(j, ax + seg_ox[j], 32 - ay + seg_oy[j], d)

/datum/aurafx_rig/proc/ArcAll()
	var/list/S = aurafx_arc_s
	var/m = S.len
	if(arc_px.len != m)
		arc_px = new /list(m)
		arc_py = new /list(m)
	var/n = hx.len
	var/i = 2
	var/acc = 0
	var/ex = 0
	var/ey = 0
	var/len = -1
	for(var/t = 1 to m)
		var/s = S[t]
		if(s <= 0)
			arc_px[t] = hx[1]
			arc_py[t] = hy[1]
			continue
		var/found = 0
		while(i <= n)
			if(len < 0)
				ex = hx[i - 1] - hx[i]
				ey = hy[i - 1] - hy[i]
				len = sqrt(ex * ex + ey * ey)
			if(len <= 0)
				i++
				len = -1
				continue
			if(acc + len >= s)
				var/f = (s - acc) / len
				arc_px[t] = hx[i - 1] - ex * f
				arc_py[t] = hy[i - 1] - ey * f
				found = 1
				break
			acc += len
			i++
			len = -1
		if(!found)
			arc_px[t] = hx[n] - (s - acc) * AuraFXUnitX(travel)
			arc_py[t] = hy[n] - (s - acc) * AuraFXUnitY(travel)

/datum/aurafx_rig/proc/ChainFly(X, Y)
	var/glide = !chain_snap
	chain_snap = 0
	var/n = hx.len
	if(n >= 7)
		var/sx = hx[1] - hx[2]
		var/sy = hy[1] - hy[2]
		var/same = 1
		for(var/k = 3, k <= 7, k++)
			if(hx[k - 1] - hx[k] != sx || hy[k - 1] - hy[k] != sy)
				same = 0
				break
		if(same)
			var/st = "[sx],[sy],[travel]"
			if(chain_steady == st) return
			chain_steady = st
		else
			chain_steady = null
	else
		chain_steady = null
	var/L = 0
	for(var/i = 2, i <= n && i <= 6, i++)
		var/seg = sqrt((hx[i - 1] - hx[i]) ** 2 + (hy[i - 1] - hy[i]) ** 2)
		if(i == 6) seg *= aurafx_tail_ticks - 4
		L += seg
	var/fold_s = 1e9
	var/acc = 0
	var/dprev = 0
	for(var/i = 2, i <= n, i++)
		var/ln = sqrt((hx[i - 1] - hx[i]) ** 2 + (hy[i - 1] - hy[i]) ** 2)
		var/dd = sqrt((hx[i] - hx[1]) ** 2 + (hy[i] - hy[1]) ** 2)
		if(dd < dprev - 1)
			fold_s = acc
			L = min(L, acc)
			break
		acc += ln
		dprev = dd
	var/mdx = n > 1 ? X - hx[2] : 0
	var/mdy = n > 1 ? Y - hy[2] : 0
	AuraFXArcPlan()
	ArcAll()
	var/cx = aurafx_fly_cx[travel]
	var/cy = aurafx_fly_cy[travel]
	var/base = AuraFXDirDeg(travel)
	var/K = tps.len
	for(var/j = 1 to K)
		var/s = aurafx_fly_knots[j]
		var/wa = s - (j > 1 ? aurafx_fly_knots[j - 1] : 0)
		var/right = j < K ? aurafx_fly_knots[j + 1] - s : wa
		var/m = clamp((L - (s - wa / 2)) / wa, 0, 1)
		var/obj/aurafx/P0 = tps[j]
		var/beyond = s + right > fold_s + 0.5
		if(j == 1)
			m = 1
			if(beyond)
				var/fax = cx + round(-s * AuraFXUnitX(travel), 1)
				var/fay = cy + round(s * AuraFXUnitY(travel), 1)
				if(glide)
					SetSegGlideRot(j, fax + seg_ox[j], 32 - fay + seg_oy[j], travel, 255, 0)
				else
					SetSegRot(j, fax + seg_ox[j], 32 - fay + seg_oy[j], travel, 255, 0)
				continue
		else if(beyond)
			m = 0
			if(glide && P0.alpha > 0)
				SetSegGlideRot(j, P0.pixel_x - mdx, P0.pixel_y - mdy, P0.dir, 0, seg_rot[j])
				continue
		var/fx = arc_px[aurafx_arc_fi[j]]
		var/fy = arc_py[aurafx_arc_fi[j]]
		var/bx = arc_px[aurafx_arc_bi[j]]
		var/by = arc_py[aurafx_arc_bi[j]]
		var/px = (fx + 2 * arc_px[aurafx_arc_mi[j]] + bx) / 4
		var/py = (fy + 2 * arc_py[aurafx_arc_mi[j]] + by) / 4
		var/th = base
		if(sqrt((fx - bx) ** 2 + (fy - by) ** 2) < 8)
			if(glide) th = AuraFXDirDeg(P0.dir) + seg_rot[j]
		else
			th = arctan(fx - bx, fy - by)
		var/r = AuraFXWrap180(th - base)
		var/ax = cx + round(px - X, 1)
		var/ay = cy + round(-(py - Y), 1)
		if(glide)
			SetSegGlideRot(j, ax + seg_ox[j], 32 - ay + seg_oy[j], travel, round(255 * m, 1), r)
		else
			SetSegRot(j, ax + seg_ox[j], 32 - ay + seg_oy[j], travel, round(255 * m, 1), r)

/datum/aurafx_rig/proc/Motion(now)
	var/X = (M.x - 1) * 32 + M.step_x
	var/Y = (M.y - 1) * 32 + M.step_y
	var/dx = 0
	var/dy = 0
	if(!has_pos || M.z != hz || !isturf(M.loc))
		HistReset(X, Y)
		chain_snap = 1
		hz = M.z
		has_pos = 1
	else
		dx = X - hx[1]
		dy = Y - hy[1]
		if(abs(dx) > 48 || abs(dy) > 48)
			HistReset(X, Y)
			chain_snap = 1
			dx = 0
			dy = 0
			if(mode == AURAFX_M_FLY) fast_until = now + 1
		else
			HistPush(X, Y)
	if(!shown || hidden)
		if(fly_kind) FlyDrop()
		if(mode == AURAFX_M_FLY || mode == AURAFX_M_KB || mode == AURAFX_M_STOP) SetMode(AURAFX_M_IDLE, now)
		return
	if(mode != AURAFX_M_IDLE && mode != AURAFX_M_FLY && mode != AURAFX_M_KB && mode != AURAFX_M_STOP) return
	var/moved = dx || dy
	if(moved) travel = AuraFXDir8(dx, dy)
	var/kd = M.Knockbacked
	if(kd && (kd & (NORTH | SOUTH | EAST | WEST)))
		if(mode != AURAFX_M_KB || kd != kb_dir)
			kb_dir = kd
			StartComet(2, now)
		else
			TakeoffTick(now)
		ChainFixed(kb_dir, aurafx_kb_cx, aurafx_kb_cy)
		return
	var/fastnow = moved && (M.is_dashing || M.Flying || max(abs(dx), abs(dy)) > 24)
	if(fastnow) fast_until = now + 1
	if(fastnow || (now < fast_until && mode == AURAFX_M_FLY))
		if(mode != AURAFX_M_FLY)
			StartComet(1, now)
			return
		if(moved && fp && fp.dir != travel)
			fp.dir = travel
			fl.dir = travel
			SparkRegion()
		if(t_take >= 0 && !TakeoffTick(now))
			ChainFixed(travel, aurafx_fly_cx, aurafx_fly_cy)
		else
			ChainFly(X, Y)
		return
	if(mode == AURAFX_M_FLY || mode == AURAFX_M_KB)
		StartStop(now)
		return
	if(mode == AURAFX_M_STOP)
		var/e = now - t_mode
		ChainStop(e)
		if(e >= aurafx_stop_fade_at && !stop_faded)
			stop_faded = 1
			for(var/obj/aurafx/O in list(hp, hl))
				animate(O, alpha = 255, time = (aurafx_stop_ticks - aurafx_stop_fade_at) * world.tick_lag)
			for(var/obj/aurafx/O in list(fp, fl) + tps + tls)
				animate(O, alpha = 0, time = (aurafx_stop_ticks - aurafx_stop_fade_at) * world.tick_lag)
		if(e >= aurafx_stop_ticks)
			FlyDrop()
			SetMode(AURAFX_M_IDLE, now)
