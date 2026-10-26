#define OUGI_TEAR_MAX 3
#define OUGI_TEAR_PLANE_DRAW -39
#define OUGI_TEAR_PLANE_CHAIN -38
#define OUGI_TEAR_PLANE_MASK -34
#define OUGI_TEAR_PLANE_VOID -31
#define OUGI_TEAR_PLANE_WHITE -28
#define OUGI_TEAR_PLANE_CELL_MASK -27
#define OUGI_TEAR_PLANE_CELL -19
#define OUGI_TEAR_PLANE_EDGE -11
#define OUGI_TEAR_PIECE 2048
#define OUGI_TEAR_PIECE_STEP 768
#define OUGI_TEAR_MARGIN_TILES 12
#define OUGI_TEAR_EDGE_LAYER 50
#define OUGI_TEAR_VIEW_LAYER 100
#define OUGI_TEAR_SEAM_LAYER 1
#define OUGI_TEAR_SEAM_PLANE 23

/obj/ougi_tear_plane
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER

/obj/ougi_tear_relay
	screen_loc = "1,1"
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE | TILE_BOUND

/obj/ougi_tear_holder
	screen_loc = "1,1"
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE | TILE_BOUND

/datum/ougi_tear
	var
		id
		px = 0
		py = 0
		angle = 0
		tdx = 1
		tdy = 0
		ndx = 0
		ndy = 1
		g0 = 0
		s0 = 0
		g1 = 0
		s1 = 0
		t0 = 0
		dur = 0
		easing = SINE_EASING
		void_icon
		void_state = ""
		void_drift = 0
		edge_icon
		edge_state = ""
		edge_width = 0
		seam_icon
		seam_state = ""
		seam_life = 20
		opened_at = 0
		gmax = 0
		u0 = -1024
		u1 = 1024
		vox = 0
		voy = 0
		closed = 0
		list/last_args

/datum/ougi_tear/proc/Value(t)
	var/p = dur > 0 ? clamp((t - t0) / dur, 0, 1) : 1
	var/e = OugiEase(p, easing)
	return list(g0 + (g1 - g0) * e, s0 + (s1 - s0) * e)

/datum/ougi_tear/proc/Offset(t, rm)
	var/g = g1
	var/s = s1
	if(!rm)
		var/list/v = Value(t)
		g = v[1]
		s = v[2]
	return list(round(g / 2 * ndx + s / 2 * tdx, 1), round(g / 2 * ndy + s / 2 * tdy, 1))

/datum/ougi_tear/proc/Done(t)
	return t >= t0 + dur

/datum/ougi_tear/proc/Drift(t, rm)
	if(rm || !void_drift) return list(0, 0)
	var/list/sz = OugiIconSize(void_icon)
	var/d = void_drift * (t - opened_at)
	var/x = round(d * tdx, 1)
	var/y = round(d * tdy, 1)
	return list(x - floor(x / sz[1]) * sz[1], y - floor(y / sz[2]) * sz[2])

/datum/ougi_tear/proc/D(x, y)
	return (x - px) * ndx + (y - py) * ndy

/datum/ougi_tear/proc/U(x, y)
	return (x - px) * tdx + (y - py) * tdy

/datum/ougi_view_rig/tear
	var
		client/C
		datum/ougi_scene/S
		list/base = list()
		list/built = list()
		list/imgs = list()
		list/cache = list()
		obj/ougi_tear_relay/view
		list/stage_relays = list()
		list/cell_masks = list()
		list/cell_holders = list()
		mag = 1
		sx = 0
		sy = 0
		world_target
		overlay_target
		rm = 0
		installed = 0

/datum/ougi_view_rig/tear/New(client/CC, datum/ougi_scene/SS)
	..()
	C = CC
	S = SS
	rm = S.ReducedMotion(C)

/datum/ougi_view_rig/tear/proc/Plane(plane, target)
	var/obj/ougi_tear_plane/P = new
	P.plane = plane
	P.render_target = target
	return P

/datum/ougi_view_rig/tear/proc/Relay(plane, layer, source)
	var/obj/ougi_tear_relay/R = new
	R.plane = plane
	R.layer = layer
	R.render_source = source
	return R

/datum/ougi_view_rig/tear/proc/Show(list/L, obj/O)
	L += O
	C.screen += O
	return O

/datum/ougi_view_rig/tear/proc/ViewMatrix()
	var/matrix/M = matrix()
	var/k = (C.world_mag || 1) * mag
	if(k != 1) M.Scale(k)
	return M

/datum/ougi_view_rig/tear/proc/ShakeLoc()
	return "1:[round(sx, 1)],1:[round(sy, 1)]"

/datum/ougi_view_rig/tear/proc/Install()
	if(installed || !C) return
	installed = 1
	C.ougi_view_rig = src
	mag = S.zoom
	var/obj/W = C.client_plane_master
	if(W)
		world_target = W.render_target
		W.render_target = "*ougitear_w"
		animate(W)
		W.transform = matrix()
	var/obj/O = C.world_overlay_master
	if(O)
		overlay_target = O.render_target
		O.render_target = "*ougitear_o"
		animate(O)
		O.transform = matrix()
	for(var/obj/R in list(C.fx_relay, C.fxnb_relay))
		C.screen -= R
	Show(base, Plane(OUGI_BACKDROP_PLANE, "*ougitear_bh"))
	Show(base, Plane(OUGI_TEAR_PLANE_CHAIN, "*ougitear_l0"))
	if(W) Show(base, Relay(OUGI_TEAR_PLANE_CHAIN, 1, "*ougitear_w"))
	if(C.fxnb_relay) Show(base, Relay(OUGI_TEAR_PLANE_CHAIN, 2, "*fxnb"))
	if(C.fx_relay) Show(base, Relay(OUGI_TEAR_PLANE_CHAIN, 3, "*fx"))
	if(O) Show(base, Relay(OUGI_TEAR_PLANE_CHAIN, 4, "*ougitear_o"))
	Show(base, Plane(OUGI_TEAR_PLANE_WHITE, "*ougitear_white"))
	var/obj/ougi_tear_holder/WH = new
	WH.icon = OugiSolidIcon(OUGI_WHITE_ICON)
	WH.plane = OUGI_TEAR_PLANE_WHITE
	var/list/vp = OugiViewPx(C)
	var/matrix/WM = matrix()
	WM.Scale(vp[1] / 32 + 2, vp[2] / 32 + 2)
	WM.Translate(vp[1] / 2 - 16, vp[2] / 2 - 16)
	WH.transform = WM
	Show(base, WH)
	view = Show(base, Relay(OUGI_TEAR_PLANE_DRAW, OUGI_TEAR_VIEW_LAYER, "*ougitear_l0"))
	ApplyZoom(0)

/datum/ougi_view_rig/tear/proc/ApplyZoom(time)
	var/matrix/M = ViewMatrix()
	var/list/L = list(view)
	for(var/obj/R in cell_masks)
		L += R
	var/rest = S.zoom_t0 + S.zoom_time - world.time
	for(var/obj/R in L)
		R.screen_loc = ShakeLoc()
		if(time > 0) animate(R, transform = M, time = time, easing = QUAD_EASING | EASE_OUT)
		else if(rest > 0 && mag == S.zoom)
			var/matrix/N = matrix()
			var/k = (C.world_mag || 1) * S.CurrentZoom()
			if(k != 1) N.Scale(k)
			R.transform = N
			animate(R, transform = M, time = rest, easing = QUAD_EASING | EASE_OUT)
		else
			animate(R)
			R.transform = M

/datum/ougi_view_rig/tear/WorldTransform(m, tx, ty, time)
	if(!installed) return 0
	var/zoomed = (m != mag) || time > 0
	mag = m
	sx = tx
	sy = ty
	if(zoomed) ApplyZoom(time)
	else
		var/l = ShakeLoc()
		view.screen_loc = l
		for(var/obj/R in cell_masks)
			R.screen_loc = l
	return 1

/datum/ougi_view_rig/tear/proc/ClearBuilt()
	for(var/obj/O in built)
		C.screen -= O
	built = list()
	stage_relays = list()
	cell_masks = list()
	cell_holders = list()
	cache = list()

/datum/ougi_view_rig/tear/proc/Build()
	if(!installed) return
	ClearBuilt()
	var/list/stack = S.ougi_tear_stack
	var/n = stack ? stack.len : 0
	for(var/k = 1 to n)
		var/datum/ougi_tear/T = stack[k]
		var/list/I = imgs[T]
		if(!I) I = Images(T)
		for(var/image/M in I[1])
			M.plane = OUGI_TEAR_PLANE_MASK + k - 1
		for(var/image/V in I[2])
			V.plane = OUGI_TEAR_PLANE_VOID + k - 1
		for(var/image/E in I[3])
			E.plane = OUGI_TEAR_PLANE_EDGE + k - 1
		Show(built, Plane(OUGI_TEAR_PLANE_EDGE + k - 1, "*ougitear_e[k]"))
		Show(built, Relay(OUGI_TEAR_PLANE_CHAIN + k - 1, 5, "*ougitear_e[k]"))
		Show(built, Plane(OUGI_TEAR_PLANE_MASK + k - 1, "*ougitear_mk[k]"))
		Show(built, Plane(OUGI_TEAR_PLANE_VOID + k - 1, "*ougitear_vt[k]"))
		Show(built, Plane(OUGI_TEAR_PLANE_CHAIN + k, "*ougitear_l[k]"))
		var/obj/ougi_tear_relay/V = Show(built, Relay(OUGI_TEAR_PLANE_CHAIN + k, 1, "*ougitear_vt[k]"))
		var/obj/ougi_tear_relay/A = Show(built, Relay(OUGI_TEAR_PLANE_CHAIN + k, 2, "*ougitear_l[k - 1]"))
		A.filters = filter(type = "alpha", render_source = "*ougitear_mk[k]")
		var/obj/ougi_tear_relay/B = Show(built, Relay(OUGI_TEAR_PLANE_CHAIN + k, 3, "*ougitear_l[k - 1]"))
		B.filters = filter(type = "alpha", render_source = "*ougitear_mk[k]", flags = MASK_INVERSE)
		stage_relays += list(list(A, B, V))
	view.render_source = "*ougitear_l[n]"
	for(var/c = 0 to (2 ** n) - 1)
		Show(built, Plane(OUGI_TEAR_PLANE_CELL_MASK + c, "*ougitear_cm[c]"))
		cell_masks += Show(built, Relay(OUGI_TEAR_PLANE_CELL_MASK + c, 1, "*ougitear_white"))
		Show(built, Plane(OUGI_TEAR_PLANE_CELL + c, "*ougitear_hc[c]"))
		var/obj/ougi_tear_holder/H = new
		H.plane = OUGI_TEAR_PLANE_CELL + c
		cell_holders += Show(built, H)
		var/obj/ougi_tear_relay/F = Show(built, Relay(OUGI_TEAR_PLANE_DRAW, 1 + c, "*ougitear_hc[c]"))
		F.filters = filter(type = "alpha", render_source = "*ougitear_cm[c]")
	ApplyZoom(0)
	Refresh(world.time, 1)

/datum/ougi_view_rig/tear/proc/Img(icon, state, turf/T, plane, layer)
	var/image/I = image(icon, T)
	I.icon_state = state
	I.plane = plane
	I.layer = layer
	I.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | KEEP_APART
	I.mouse_opacity = 0
	C.images += I
	return I

/datum/ougi_view_rig/tear/proc/Images(datum/ougi_tear/T)
	var/list/I = list(list(), list(), list(), list())
	imgs[T] = I
	var/z = S.room ? S.room.z : 1
	var/k0 = floor((T.u0 - OUGI_TEAR_PIECE / 2) / OUGI_TEAR_PIECE_STEP)
	var/k1 = -floor(-(T.u1 + OUGI_TEAR_PIECE / 2) / OUGI_TEAR_PIECE_STEP)
	var/sk = OUGI_TEAR_PIECE / 32
	for(var/k = k0 to k1)
		var/qx = T.px + T.tdx * k * OUGI_TEAR_PIECE_STEP
		var/qy = T.py + T.tdy * k * OUGI_TEAR_PIECE_STEP
		var/turf/A = locate(floor(qx / 32) + 1, floor(qy / 32) + 1, z)
		if(!A) continue
		var/image/M = Img(OugiSolidIcon(OUGI_WHITE_ICON), "", A, OUGI_TEAR_PLANE_MASK, 1)
		var/matrix/X = matrix()
		X.Scale(sk)
		X.Turn(T.angle)
		X.Translate(qx + T.ndx * OUGI_TEAR_PIECE / 2 - ((A.x - 1) * 32 + 16), qy + T.ndy * OUGI_TEAR_PIECE / 2 - ((A.y - 1) * 32 + 16))
		M.transform = X
		I[1] += M
	VoidImages(T)
	if(T.edge_icon && T.edge_width > 0)
		var/list/es = OugiIconSize(T.edge_icon)
		var/step = max(1, es[1] - 1)
		var/i0 = floor(T.u0 / step) - 1
		var/i1 = -floor(-T.u1 / step) + 1
		for(var/side in list(1, -1))
			for(var/i = i0 to i1)
				var/cx = T.px + T.tdx * i * step + side * T.ndx * T.edge_width / 2
				var/cy = T.py + T.tdy * i * step + side * T.ndy * T.edge_width / 2
				var/turf/A = locate(floor(cx / 32) + 1, floor(cy / 32) + 1, z)
				if(!A) continue
				var/image/E = Img(T.edge_icon, T.edge_state, A, OUGI_TEAR_PLANE_EDGE, OUGI_TEAR_EDGE_LAYER + (side > 0 ? 0 : 5) + (i - i0) * 0.001)
				var/matrix/X = matrix()
				X.Scale(1, -side * T.edge_width / es[2])
				X.Turn(T.angle)
				X.Translate(cx - ((A.x - 1) * 32 + es[1] / 2), cy - ((A.y - 1) * 32 + es[2] / 2))
				E.transform = X
				I[3] += E
	return I

/datum/ougi_view_rig/tear/proc/VoidImages(datum/ougi_tear/T)
	var/list/I = imgs[T]
	if(!I || !T.void_icon) return
	var/list/have = I[4]
	var/list/sz = OugiIconSize(T.void_icon)
	var/w = sz[1]
	var/h = sz[2]
	var/z = S.room ? S.room.z : 1
	var/hw = T.gmax / 2 + 2
	var/list/box = S.TearBox()
	var/i0 = floor((box[1] - T.vox) / w) - 1
	var/i1 = -floor(-(box[3] - T.vox) / w) + 1
	var/j0 = floor((box[2] - T.voy) / h) - 1
	var/j1 = -floor(-(box[4] - T.voy) / h) + 1
	for(var/i = i0 to i1)
		for(var/j = j0 to j1)
			var/key = "[i],[j]"
			if(key in have) continue
			var/x0 = T.vox + i * w
			var/y0 = T.voy + j * h
			var/dmin = 1e9
			var/dmax = -1e9
			var/umin = 1e9
			var/umax = -1e9
			for(var/cx in list(x0, x0 + 2 * w))
				for(var/cy in list(y0, y0 + 2 * h))
					var/d = T.D(cx, cy)
					var/u = T.U(cx, cy)
					dmin = min(dmin, d)
					dmax = max(dmax, d)
					umin = min(umin, u)
					umax = max(umax, u)
			if(dmax < -hw || dmin > hw || umax < T.u0 || umin > T.u1) continue
			var/turf/A = locate(floor((x0 + w / 2) / 32) + 1, floor((y0 + h / 2) / 32) + 1, z)
			if(!A) continue
			var/image/V = Img(T.void_icon, T.void_state, A, OUGI_TEAR_PLANE_VOID, 1)
			V.pixel_x = x0 - (A.x - 1) * 32
			V.pixel_y = y0 - (A.y - 1) * 32
			have[key] = V
			I[2] += V
	var/k = S.ougi_tear_stack.Find(T)
	if(k)
		for(var/image/V in I[2])
			V.plane = OUGI_TEAR_PLANE_VOID + k - 1

/datum/ougi_view_rig/tear/proc/Set(key, v)
	if(cache[key] == v) return 0
	cache[key] = v
	return 1

/datum/ougi_view_rig/tear/proc/Refresh(t, force = 0)
	if(!installed) return
	if(force) cache = list()
	var/list/stack = S.ougi_tear_stack
	var/n = stack ? stack.len : 0
	var/list/offs = list()
	for(var/k = 1 to n)
		var/datum/ougi_tear/T = stack[k]
		var/list/o = T.Offset(t, rm)
		offs += list(o)
		var/list/R = stage_relays[k]
		var/obj/A = R[1]
		var/obj/B = R[2]
		var/obj/V = R[3]
		if(Set("a[k]", "[o[1]],[o[2]]"))
			A.screen_loc = "1:[o[1]],1:[o[2]]"
			B.screen_loc = "1:[-o[1]],1:[-o[2]]"
			V.filters = list(filter(type = "alpha", render_source = "*ougitear_mk[k]", x = o[1], y = o[2], flags = MASK_INVERSE), filter(type = "alpha", render_source = "*ougitear_mk[k]", x = -o[1], y = -o[2]))
		var/list/I = imgs[T]
		if(I && T.void_icon)
			var/list/dr = T.Drift(t, rm)
			if(Set("v[k]", "[dr[1]],[dr[2]]"))
				var/list/have = I[4]
				var/list/vs = OugiIconSize(T.void_icon)
				for(var/key in have)
					var/image/VI = have[key]
					var/turf/VL = VI.loc
					var/list/ij = splittext(key, ",")
					VI.pixel_x = T.vox + text2num(ij[1]) * vs[1] + dr[1] - (VL.x - 1) * 32
					VI.pixel_y = T.voy + text2num(ij[2]) * vs[2] + dr[2] - (VL.y - 1) * 32
	var/z = (C.world_mag || 1) * S.CurrentZoom()
	var/list/bd = list()
	var/bdkey = ""
	for(var/obj/ougi_screen/backdrop/O in C.screen)
		bd += O
		bdkey += "\ref[O]"
	for(var/c = 0 to cell_holders.len - 1)
		var/list/fl = list()
		var/ox = 0
		var/oy = 0
		for(var/k = n to 1 step -1)
			var/list/o = offs[k]
			var/b = (c >> (k - 1)) & 1
			ox += b ? -o[1] : o[1]
			oy += b ? -o[2] : o[2]
			fl += filter(type = "alpha", render_source = "*ougitear_mk[k]", x = ox, y = oy, flags = b ? MASK_INVERSE : 0)
		var/obj/M = cell_masks[c + 1]
		if(Set("m[c]", "[ox],[oy]"))
			M.filters = fl.len ? fl : null
		var/obj/H = cell_holders[c + 1]
		if(Set("h[c]", "[ox * z],[oy * z]"))
			H.transform = matrix(1, 0, ox * z, 0, 1, oy * z)
		if(Set("hv[c]", bdkey))
			for(var/obj/O in bd)
				O.vis_flags |= VIS_INHERIT_PLANE
			H.vis_contents = bd
	var/obj/W = C.client_plane_master
	if(W && W.render_target != "*ougitear_w")
		world_target = W.render_target
		W.render_target = "*ougitear_w"
	if(W)
		var/matrix/X = W.transform
		if(X.a != 1 || X.b || X.c || X.d || X.e != 1 || X.f)
			animate(W)
			W.transform = matrix()
	if(Set("wm", "[C.world_mag]")) ApplyZoom(0)

/datum/ougi_view_rig/tear/Drop()
	if(!installed) return
	installed = 0
	if(C.ougi_view_rig == src) C.ougi_view_rig = null
	ClearBuilt()
	for(var/obj/O in base)
		C.screen -= O
	base = list()
	for(var/datum/ougi_tear/T in imgs)
		DropImages(T)
	imgs = list()
	for(var/obj/ougi_screen/backdrop/O in C.screen)
		O.vis_flags &= ~VIS_INHERIT_PLANE
	if(C.client_plane_master) C.client_plane_master.render_target = world_target
	if(C.world_overlay_master) C.world_overlay_master.render_target = overlay_target
	for(var/obj/R in list(C.fx_relay, C.fxnb_relay))
		C.screen |= R
	OugiClientWorldTransform(C, mag, sx, sy, 0)
	if(S && S.ougi_tear_rigs) S.ougi_tear_rigs -= C

/datum/ougi_view_rig/tear/proc/DropImages(datum/ougi_tear/T)
	var/list/I = imgs[T]
	if(!I) return
	for(var/k = 1 to 3)
		for(var/image/M in I[k])
			C.images -= M
	imgs -= T

/datum/ougi_scene
	var
		list/ougi_tears
		list/ougi_tear_stack
		list/ougi_tear_rigs
		list/ougi_tear_seams
		ougi_tear_gen = 0
		ougi_tear_seam_n = 0

/datum/ougi_scene/DoOp(op, list/a)
	if(op == "tear") return OpTear(a)
	return ..()

/datum/ougi_scene/proc/TearBox()
	var/m = OUGI_TEAR_MARGIN_TILES * world.icon_size
	var/swapmap/W = room ? room.swapmap : null
	if(!W) return list(-1e6, -1e6, 1e6, 1e6)
	return list((W.x1 - 1) * world.icon_size - m, (W.y1 - 1) * world.icon_size - m, W.x2 * world.icon_size + m, W.y2 * world.icon_size + m)

/datum/ougi_scene/proc/TearSpan(datum/ougi_tear/T)
	var/list/b = TearBox()
	var/lo = -1e9
	var/hi = 1e9
	var/list/d = list(T.tdx, T.tdy)
	var/list/p = list(T.px, T.py)
	for(var/i = 1 to 2)
		if(abs(d[i]) < 1e-6) continue
		var/a = (b[i] - p[i]) / d[i]
		var/c = (b[i + 2] - p[i]) / d[i]
		lo = max(lo, min(a, c))
		hi = min(hi, max(a, c))
	if(lo > hi) return list(-1024, 1024)
	return list(lo, hi)

/datum/ougi_scene/proc/OpTear(list/a)
	if(!room) return
	var/tid = "[ArgText(a, "id", "tear")]"
	if(!ougi_tears) ougi_tears = list()
	if(!ougi_tear_stack) ougi_tear_stack = list()
	if(!ougi_tear_rigs) ougi_tear_rigs = list()
	var/now = world.time
	if(TearCloseDone(now))
		for(var/client/C in ougi_tear_rigs)
			var/datum/ougi_view_rig/tear/R = ougi_tear_rigs[C]
			R.Build()
	var/datum/ougi_tear/T = ougi_tears[tid]
	if(T && !T.closed)
		var/list/v = T.Value(now)
		T.g0 = v[1]
		T.s0 = v[2]
		T.g1 = max(0, ArgNum(a, "gap", T.g1))
		T.s1 = ArgNum(a, "slide", T.s1)
		T.t0 = now
		T.dur = Ds(ArgNum(a, "time", 3))
		T.easing = OugiTearEasing(ArgText(a, "easing", "sine"))
		T.void_drift = ArgNum(a, "void_drift", T.void_drift)
		T.seam_icon = ArgText(a, "seam", T.seam_icon)
		T.seam_state = ArgText(a, "seam_state", T.seam_state)
		T.seam_life = ArgNum(a, "seam_life", T.seam_life)
		if(T.g1 > T.gmax)
			T.gmax = T.g1
			for(var/client/C in ougi_tear_rigs)
				var/datum/ougi_view_rig/tear/R = ougi_tear_rigs[C]
				R.VoidImages(T)
				R.Refresh(now, 1)
	else
		if(ougi_tear_stack.len >= OUGI_TEAR_MAX)
			world.log << "OUGI: tear [tid] in [id] skipped: [OUGI_TEAR_MAX] tears are already open"
			return
		var/list/old = T ? T.last_args : null
		var/list/m = old ? old.Copy() : list()
		for(var/k in a)
			m[k] = a[k]
		var/datum/ougi_tear/N = new
		N.id = tid
		N.last_args = m
		if(T && isnull(a["at"]) && isnull(a["dx"]) && isnull(a["dy"]))
			N.px = T.px
			N.py = T.py
		else
			var/list/p = OugiScenePoint(ArgText(m, "at", "target"), null)
			if(!p)
				world.log << "OUGI: tear [tid] in [id] has no point; skipped"
				return
			N.px = p[1] + ArgNum(m, "dx", 0)
			N.py = p[2] + ArgNum(m, "dy", 0)
		N.angle = ArgNum(m, "angle", 0)
		N.tdx = cos(N.angle)
		N.tdy = -sin(N.angle)
		N.ndx = sin(N.angle)
		N.ndy = cos(N.angle)
		N.g1 = max(0, ArgNum(m, "gap", 0))
		N.s1 = ArgNum(m, "slide", 0)
		N.gmax = N.g1
		N.t0 = now
		N.opened_at = now
		N.dur = Ds(ArgNum(m, "time", 3))
		N.easing = OugiTearEasing(ArgText(m, "easing", "sine"))
		N.void_icon = ArgText(m, "void", null)
		N.void_state = ArgText(m, "void_state", "")
		N.void_drift = ArgNum(m, "void_drift", 0)
		N.edge_icon = ArgText(m, "edge", null)
		N.edge_state = ArgText(m, "edge_state", "")
		N.edge_width = max(0, ArgNum(m, "edge_width", 0))
		N.seam_icon = ArgText(m, "seam", null)
		N.seam_state = ArgText(m, "seam_state", "")
		N.seam_life = ArgNum(m, "seam_life", 20)
		N.vox = round(N.px, 1)
		N.voy = round(N.py, 1)
		var/list/u = TearSpan(N)
		N.u0 = u[1]
		N.u1 = u[2]
		ougi_tears[tid] = N
		ougi_tear_stack += N
		for(var/client/C in ougi_tear_rigs)
			var/datum/ougi_view_rig/tear/R = ougi_tear_rigs[C]
			R.Build()
	TearTick()
	if(!ougi_tear_loop)
		ougi_tear_gen++
		ougi_tear_loop = 1
		spawn(world.tick_lag) TearLoop(ougi_tear_gen)

/datum/ougi_scene
	var/ougi_tear_loop = 0

proc/OugiTearEasing(e)
	if(e == "quad_out") return QUAD_EASING | EASE_OUT
	if(e == "linear") return LINEAR_EASING
	return SINE_EASING

/datum/ougi_scene/proc/TearLoop(gen)
	while(live && ougi_tear_gen == gen)
		TearTick()
		if(!ougi_tear_stack.len && !ougi_tear_rigs.len) break
		sleep(world.tick_lag)
	if(ougi_tear_gen == gen) ougi_tear_loop = 0

/datum/ougi_scene/proc/TearCloseDone(now)
	var/changed = 0
	for(var/datum/ougi_tear/T in ougi_tear_stack.Copy())
		if(T.Done(now) && T.g1 <= 0 && !T.s1)
			T.closed = 1
			ougi_tear_stack -= T
			changed = 1
			TearSeam(T)
			for(var/client/C in ougi_tear_rigs)
				var/datum/ougi_view_rig/tear/R = ougi_tear_rigs[C]
				R.DropImages(T)
	return changed

/datum/ougi_scene/proc/TearTick()
	var/now = world.time
	var/changed = TearCloseDone(now)
	if(ougi_tear_stack.len)
		for(var/client/C in clients)
			if(!C.ougi_in_display || ougi_tear_rigs[C]) continue
			var/datum/ougi_view_rig/tear/R = new(C, src)
			ougi_tear_rigs[C] = R
			R.Install()
			R.Build()
	for(var/client/C in ougi_tear_rigs.Copy())
		var/datum/ougi_view_rig/tear/R = ougi_tear_rigs[C]
		if(!C || !R.installed)
			ougi_tear_rigs -= C
			continue
		if(changed) R.Build()
		else R.Refresh(now)
		if(!ougi_tear_stack.len && now >= zoom_t0 + zoom_time) R.Drop()

/datum/ougi_scene/proc/TearSeam(datum/ougi_tear/T)
	if(!T.seam_icon || !room) return
	var/list/ss = OugiIconSize(T.seam_icon)
	var/step = max(1, ss[1] - 1)
	var/i0 = floor(T.u0 / step) - 1
	var/i1 = -floor(-T.u1 / step) + 1
	var/list/rec = list()
	ougi_tear_seam_n++
	for(var/client/C in clients)
		if(!C.ougi_in_display) continue
		for(var/i = i0 to i1)
			var/cx = T.px + T.tdx * i * step
			var/cy = T.py + T.tdy * i * step
			var/turf/A = locate(floor(cx / 32) + 1, floor(cy / 32) + 1, room.z)
			if(!A) continue
			var/image/E = image(T.seam_icon, A)
			E.icon_state = T.seam_state
			E.plane = OUGI_TEAR_SEAM_PLANE
			E.layer = OUGI_TEAR_SEAM_LAYER + ougi_tear_seam_n * 0.01 + (i - i0) * 0.0001
			E.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | KEEP_APART
			E.mouse_opacity = 0
			var/matrix/X = matrix()
			X.Turn(T.angle)
			X.Translate(cx - ((A.x - 1) * 32 + ss[1] / 2), cy - ((A.y - 1) * 32 + ss[2] / 2))
			E.transform = X
			C.images += E
			rec += list(list(C, E))
	if(!rec.len) return
	if(!ougi_tear_seams) ougi_tear_seams = list()
	ougi_tear_seams += list(rec)
	var/life = Ds(T.seam_life)
	spawn(life)
		if(ougi_tear_seams && (rec in ougi_tear_seams))
			ougi_tear_seams -= list(rec)
			TearSeamDrop(rec)

/datum/ougi_scene/proc/TearSeamDrop(list/rec)
	for(var/list/e in rec)
		var/client/C = e[1]
		if(C) C.images -= e[2]

/datum/ougi_scene/proc/TearsEnd()
	ougi_tear_gen++
	ougi_tear_loop = 0
	if(ougi_tear_rigs)
		for(var/client/C in ougi_tear_rigs.Copy())
			var/datum/ougi_view_rig/tear/R = ougi_tear_rigs[C]
			if(R) R.Drop()
	ougi_tear_rigs = null
	if(ougi_tear_seams)
		for(var/list/rec in ougi_tear_seams)
			TearSeamDrop(rec)
	ougi_tear_seams = null
	ougi_tear_stack = null
	ougi_tears = null

/datum/ougi_scene/LeaveRoom()
	TearsEnd()
	..()

/datum/ougi_scene/End(force = 0)
	TearsEnd()
	..()
