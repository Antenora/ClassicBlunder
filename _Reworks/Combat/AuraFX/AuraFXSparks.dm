var/list/aurafx_spark_q = list(\
	null,\
	list(2.25, 1.0, 1.0, 2.2, 0.9, 1.0, 0.06, 0.25, 1.4, 2.2, 0.85, 1.0, 0.16, 0.14, 0.75, 1.0, 0.74, 1.0, 0.75),\
	list(4.5, 2.0, 1.0, 2.2, 0.9, 1.0, 0.06, 0.5, 1.4, 2.2, 0.85, 1.0, 0.16, 0.14, 0.75, 1.0, 0.74, 1.0, 0.75))

var/list/aurafx_crackle_w = list("c1" = 1, "c2" = 0.8, "c3" = 1, "c4" = 0.8, "c5" = 1, "c6" = 0.8, "c7" = 1, "c8" = 0.8)
var/list/aurafx_surge_w = list("s1" = 1, "s2" = 1, "s3" = 1, "s4" = 1)

/obj/aurafx/spark
	appearance_flags = KEEP_APART | RESET_COLOR
	blend_mode = BLEND_ADD
	var/tmp/kind

/obj/aurafx_lit_master
	plane = AURAFX_LIT_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*aurafx_lit"

/obj/aurafx_lit_relay
	plane = 0
	screen_loc = "SOUTHWEST"
	layer = AURAFX_LIT_RELAY_LAYER
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	render_source = "*aurafx_lit"

client/var/tmp/list/aurafx_screen

client/ApplyWorldMag()
	..()
	AuraFXEnsureMasters(src)

proc/AuraFXEnsureMasters(client/C)
	if(!C) return
	if(!C.aurafx_screen)
		C.aurafx_screen = list(new /obj/aurafx_lit_master, new /obj/aurafx_lit_relay)
	for(var/obj/O in C.aurafx_screen)
		if(!(O in C.screen)) C.screen += O

proc/AuraFXSparkM(ax, ay, ang)
	var/ca = cos(ang)
	var/sa = sin(ang)
	return matrix(ax * ca, -ay * sa, 0, ax * sa, ay * ca, 0)

proc/AuraFXSparkProj(az, D)
	return list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, az / D, 0, 0, 0, 1)

proc/AuraFXSparkSet(kind, list/Q)
	var/particles/P = new
	P.width = 256
	P.height = 256
	P.icon = AURAFX_SPARKS_ICON
	P.spawning = 0
	P.spin = generator("num", -12, 12)
	P.drift = generator("sphere", 0, 0.015)
	if(kind == "s")
		P.icon_state = aurafx_surge_w
		P.count = 8
		P.lifespan = generator("num", Q[9], Q[10])
		P.fade = 0.8
		P.position = generator("sphere", Q[15] * 0.75, Q[16] * 0.9)
		P.velocity = list(0, Q[13], 0)
		P.scale = generator("vector", list(Q[11], Q[11]), list(Q[12], Q[12]))
		P.rotation = generator("num", -20, 20)
		P.bound1 = list(-9, -0.6, -0.8)
		P.bound2 = list(9, 9, 0)
	else
		P.icon_state = aurafx_crackle_w
		P.count = 40
		P.lifespan = generator("num", Q[3], Q[4])
		P.fade = 0.7
		P.position = generator("sphere", Q[15], Q[16])
		P.velocity = generator("sphere", 0, Q[7])
		P.scale = generator("vector", list(Q[5], Q[5]), list(Q[6], Q[6]))
		P.rotation = generator("num", 0, 360)
		if(kind == "f")
			P.bound1 = list(-9, -0.6, -0.55)
			P.bound2 = list(9, 9, 0)
		else
			P.bound1 = list(-9, -9, 0)
			P.bound2 = list(9, 9, 9)
	return P

/datum/aurafx_rig
	var
		spark_tier = 0
		spark_t0 = 0
		spark_ramp = 0
		spark_key
		obj/aurafx/spark/sb
		obj/aurafx/spark/sf
		obj/aurafx/spark/ss

/datum/aurafx_rig/proc/SparkMake(kind, list/Q)
	var/obj/aurafx/spark/S = new
	S.kind = kind
	S.particles = AuraFXSparkSet(kind, Q)
	if(kind == "b")
		S.layer = AURAFX_L_SPARK_BACK
		S.vis_flags = VIS_UNDERLAY
		S.alpha = round(255 * Q[19], 1)
	else
		S.plane = AURAFX_LIT_PLANE
		S.layer = kind == "f" ? AURAFX_L_SPARK_FRONT : AURAFX_L_SPARK_SURGE
		S.alpha = round(255 * min(1, Q[18]) * (kind == "s" ? 0.9 : 1), 1)
	pieces += S
	Put(S)
	return S

/datum/aurafx_rig/proc/SparksOn(t, now)
	SparksOff()
	var/list/Q = aurafx_spark_q[t]
	spark_tier = t
	spark_t0 = now
	spark_ramp = 0
	spark_key = null
	sb = SparkMake("b", Q)
	sf = SparkMake("f", Q)
	ss = SparkMake("s", Q)
	SparkRegion()

/datum/aurafx_rig/proc/SparksOff()
	for(var/obj/aurafx/spark/S in list(sb, sf, ss))
		if(S.particles) S.particles.spawning = 0
		Drop(S)
		S.particles = null
	sb = null
	sf = null
	ss = null
	spark_tier = 0
	spark_key = null

/datum/aurafx_rig/proc/SparkRate(k)
	var/list/Q = aurafx_spark_q[spark_tier]
	if(sb && sb.particles) sb.particles.spawning = Q[2] * k
	if(sf && sf.particles) sf.particles.spawning = Q[1] * k
	if(ss && ss.particles) ss.particles.spawning = Q[8] * k

/datum/aurafx_rig/proc/SparkTick(now)
	var/t = (form >= 2 && !hidden) ? form : 0
	if(mode == AURAFX_M_IGNITE && t_ign >= 0 && now - t_ign < aurafx_reveal_at) t = 0
	if(t != spark_tier)
		if(t) SparksOn(t, now)
		else SparksOff()
	if(!spark_tier || spark_ramp >= 2) return
	var/e = now - spark_t0
	if(e >= 2)
		spark_ramp = 2
		SparkRate(1)
	else if(e >= 1 && spark_ramp < 1)
		spark_ramp = 1
		SparkRate(0.5)

/datum/aurafx_rig/proc/SparkRegion()
	if(!spark_tier || !sf) return
	var/list/Q = aurafx_spark_q[spark_tier]
	var/s = Q[17]
	var/key
	var/ox
	var/oy
	var/sm = 1
	var/ang = 0
	var/a0 = 0
	var/ex
	var/ey
	var/ez
	var/comet = (mode == AURAFX_M_FLY || mode == AURAFX_M_KB) && fly_kind
	if(comet)
		var/d = mode == AURAFX_M_KB ? kb_dir : travel
		var/L = mode == AURAFX_M_KB ? 56 : 141
		var/bx = -AuraFXUnitX(d)
		var/by = AuraFXUnitY(d)
		ang = arctan(bx, -by)
		a0 = 90 - ang
		var/ctr = 0.5 * (-9 + 0.55 * L)
		ex = 0.5 * (0.55 * L + 9) * s
		ey = 17 * s
		ez = 17 * s
		var/cx = mode == AURAFX_M_KB ? aurafx_kb_cx[d] : aurafx_fly_cx[d]
		var/cy = mode == AURAFX_M_KB ? aurafx_kb_cy[d] : aurafx_fly_cy[d]
		ox = (cx - 16) + bx * ctr
		oy = (16 - cy) - by * ctr
		key = "f[mode][d]"
	else
		var/g = (mode == AURAFX_M_IDLE && shown) ? 1 + 0.05 * (gi - 1) : 1
		var/kk = (g - 1) / 0.7
		ex = 17 + 4 * kk
		ey = 21 + 8 * kk
		ez = ex
		ox = 0
		oy = 4 * kk
		sm = sqrt(g)
		key = "i[g]"
	if(key == spark_key) return
	spark_key = key
	var/matrix/M2 = AuraFXSparkM(ex, ey, ang)
	var/list/T = AuraFXSparkProj(ez, 120)
	var/ycut = comet ? -1000 : -(18 + oy)
	var/ca = cos(ang)
	var/sa = sin(ang)
	for(var/obj/aurafx/spark/S in list(sb, sf, ss))
		var/particles/P = S.particles
		if(!P) continue
		P.transform = T
		S.pixel_x = round(ox, 1)
		S.pixel_y = round(oy, 1)
		P.drift = generator("sphere", 0, 0.015) * M2
		if(S.kind == "s")
			P.position = (comet ? generator("sphere", Q[15] * 0.75, Q[16] * 0.9) : generator("sphere", 0.3, 0.9)) * M2
			P.scale = generator("vector", list(Q[11] * sm, Q[11] * sm), list(Q[12] * sm, Q[12] * sm))
			P.rotation = generator("num", a0 - 20, a0 + 20)
			if(comet)
				P.velocity = vector(Q[14] * ex * ca, Q[14] * ex * sa, 0)
			else
				P.velocity = vector(-Q[13] * ey * sa, Q[13] * ey * ca, 0)
			P.bound1 = vector(-1000, ycut, -0.8)
			P.bound2 = vector(1000, 1000, 0)
		else
			P.position = (comet ? generator("sphere", Q[15], Q[16]) : generator("sphere", 0.3, 1)) * M2
			P.velocity = generator("sphere", 0, Q[7]) * M2
			if(S.kind == "f")
				P.bound1 = vector(-1000, ycut, -0.55)
				P.bound2 = vector(1000, 1000, 0)
			else
				P.bound1 = vector(-1000, -1000, 0)
				P.bound2 = vector(1000, 1000, 9)
			P.scale = generator("vector", list(Q[5] * sm, Q[5] * sm), list(Q[6] * sm, Q[6] * sm))
