globalTracker
	var/tmp
		FLASH_ENVELOPE = TRUE
		FLASH_RALLY = TRUE
		FLASH_MOVE = TRUE
		FLASH_STATES = TRUE
		FLASH_WORLD = TRUE
		RALLY_COEF = 0.35
		RALLY_WINDOW_DS = 10
		RALLY_MAX_HITS = 5
		RALLY_STOP_RATE = 0.15
		FLASH_BLOOM_CD_DS = 2.5
		FLASH_CHIP_CD_DS = 2

mob/var/tmp
	rally_hits = 0
	rally_until = 0
	_flash_env_busy = 0
	_flash_bloom_next = 0
	_flash_chip_next = 0
	_flash_defl_next = 0
	_flash_charge_on = 0
	_hb_flip = 0
	_swing_n = 0
	_clash_flash_next = 0
	kb_thrown = 0
	obj/fx_clashlight/_flash_plate
	obj/fx_clashlight/_flash_arm
	obj/fx_clashlight/_flash_band
	obj/fx_clashlight/_flash_hand

obj/Flash_Still
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	density = 0
	mouse_opacity = 0

proc/FlashDirPx(d)
	var/x = 0
	var/y = 0
	if(d & NORTH) y = 1
	if(d & SOUTH) y = -1
	if(d & EAST) x = 1
	if(d & WEST) x = -1
	return list(x, y)

proc/FlashDirAngle(d)
	switch(d)
		if(NORTH) return 0
		if(NORTHEAST) return 45
		if(EAST) return 90
		if(SOUTHEAST) return 135
		if(SOUTH) return 180
		if(SOUTHWEST) return 225
		if(WEST) return 270
		if(NORTHWEST) return 315
	return 0

proc/FlashGlow(atom/movable/host, col = "#ffffff", matrix/mx, a = 190, under = 0)
	if(!host || !_fx_glow_icon) return null
	var/obj/fx_clashlight/L = new
	L.icon = _fx_glow_icon
	L.color = col
	L.alpha = a
	L.plane = 23
	L.layer = under ? 3.5 : 6
	if(mx) L.transform = mx
	var/list/anc = FxChildAnchor(host)
	L.pixel_x = anc[1]
	L.pixel_y = anc[2]
	host.vis_contents += L
	return L

mob/proc/RallyLevel()
	if(!glob || !glob.FLASH_RALLY) return 0
	if(world.time > rally_until) return 0
	return clamp(rally_hits / glob.RALLY_MAX_HITS, 0, 1)

mob/proc/RallyBump()
	if(world.time > rally_until) rally_hits = 0
	rally_hits = min(rally_hits + 1, glob.RALLY_MAX_HITS)
	rally_until = world.time + glob.RALLY_WINDOW_DS

mob/proc/SwingEnvelope(atom/enemy, weight = 0.3, col = "#ffffff")
	if(!petal_attacking) flick("Attack", src)
	if(!glob.FLASH_ENVELOPE || _flash_env_busy || !enemy) return
	var/matrix/M = transform
	if(M && (M.b || M.d)) return
	_flash_env_busy = 1
	if(world.time > rally_until) _swing_n = 0
	_swing_n++
	var/side = (_swing_n % 2) ? 1 : -1
	var/lvl = RallyLevel()
	var/w = min(weight + 0.4 * lvl, 1)
	FlashSwingSmear(src, enemy, w, col, angoff = side * 22)
	if(rally_hits >= 3 && lvl > 0)
		FlashSwingSmear(src, enemy, w * 0.8, col, angoff = -side * 30)
	if(lvl >= 1)
		spawn(2)
			if(enemy) FlashSwingSmear(src, enemy, w * 0.6, col, angoff = side * 10, amult = 0.4)
	var/list/v = FlashDirPx(get_dir(src, enemy))
	var/px = 2 + round(2 * w)
	var/lat = side * round(px * 0.5)
	animate(src, pixel_x = v[1]*px - v[2]*lat, pixel_y = v[2]*px + v[1]*lat, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = -(v[1]*px - v[2]*lat), pixel_y = -(v[2]*px + v[1]*lat), time = 2, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_RELATIVE)
	spawn(4)
		_flash_env_busy = 0

proc/FlashSwingSmear(mob/A, atom/enemy, w = 0.3, col = "#ffffff", angoff = 0, amult = 1)
	if(!A || !enemy || !glob.FLASH_ENVELOPE) return
	var/ang = GetAngle(A, enemy) + angoff
	var/matrix/mx = matrix(1.3 + w, 0, 0, 0, 0.3, 0)
	mx.Turn(ang - 90)
	var/obj/fx_clashlight/S = FlashGlow(A, col, mx, round((120 + round(60 * w)) * amult))
	if(!S) return
	var/list/v = FlashDirPx(get_dir(A, enemy))
	S.pixel_x += v[1]*10
	S.pixel_y += v[2]*10
	var/matrix/mx2 = matrix(mx)
	mx2.Scale(1.3)
	animate(S, alpha = 0, transform = mx2, pixel_x = S.pixel_x + v[1]*8, pixel_y = S.pixel_y + v[2]*8, time = 3, easing = QUAD_EASING|EASE_OUT)
	spawn(4)
		if(A) A.vis_contents -= S

proc/FlashContactBloom(mob/V, w)
	var/obj/fx_clashlight/B = FlashGlow(V, "#ffffff", matrix() * (0.45 + 0.7 * min(w, 1)), 190)
	if(!B) return
	animate(B, transform = matrix() * (0.7 + 0.9 * min(w, 1)), alpha = 0, time = 3, easing = QUAD_EASING|EASE_OUT)
	spawn(4)
		if(V) V.vis_contents -= B

proc/FlashContact(mob/A, mob/V, quakeIntens, counterHit = 0, dx = 0, dy = 0)
	set waitfor = 0
	if(!A || !V) return
	var/q = quakeIntens
	if(glob.FLASH_RALLY)
		q = min(q * (1 + glob.RALLY_STOP_RATE * A.RallyLevel()), 14)
	var/ringScale = 1 + (glob.FLASH_RALLY ? 0.4 * A.RallyLevel() : 0)
	KenShockwave(V, Size = clamp(q * randValue(0.001, 0.2) * ringScale, 0.0001, 1.5), PixelX = dx, PixelY = dy, Time = 4)
	var/froze = HitStop(A, V, q, counterHit ? glob.COUNTER_HIT_STOP_BONUS : 0)
	V.Earthquake(q, -4,4,-4,4, 0, get_dir(A, V))
	if(counterHit)
		FlashCounterMoment(A, V, froze)

proc/FlashCounterMoment(mob/A, mob/V, froze = 1)
	if(!A || !V || !glob.FLASH_ENVELOPE) return
	var/obj/Flash_Still/G = new
	G.appearance = V.appearance
	G.dir = V.dir
	G.loc = V.loc
	if(PmActive())
		G.step_x = V.step_x
		G.step_y = V.step_y
	G.transform = G.transform * matrix(1, 0.14, 0, 0, 1, 0)
	G.alpha = 200
	animate(G, alpha = 0, time = 10, tag = "flashcm")
	spawn(11)
		G.loc = null
	if(froze)
		var/obj/Flash_Still/G2 = new
		G2.appearance = A.appearance
		G2.dir = A.dir
		G2.loc = A.loc
		if(PmActive())
			G2.step_x = A.step_x
			G2.step_y = A.step_y
		G2.transform = G2.transform * matrix(1, -0.14, 0, 0, 1, 0)
		G2.alpha = 120
		animate(G2, alpha = 0, time = 8, tag = "flashcm2")
		spawn(9)
			G2.loc = null
	var/matrix/bmx = matrix(2.2, 0, 0, 0, 0.22, 0)
	bmx.Turn(GetAngle(A, V) - 90)
	var/obj/fx_clashlight/R = FlashGlow(V, "#ffd27a", bmx, 230)
	if(R)
		animate(R, transform = bmx * 1.5, alpha = 0, time = 4, easing = QUAD_EASING|EASE_OUT)
		spawn(5)
			if(V) V.vis_contents -= R

proc/ZanzoBlink(mob/M, turf/t_from, arrive = 0)
	if(!glob.FLASH_MOVE || !M || !t_from) return
	var/obj/Effects/KenShockwave2/DR = new
	DR.loc = t_from
	DR.Size = 1.1
	DR.Lifetime = 3
	if(!arrive) return
	var/turf/here = get_step(M, 0)
	if(!here || here == t_from) return
	Footfall(M)
	Footfall(M)
	KenShockwave(M, Size = 0.6, Blend = 2, Time = 3)
	var/list/v = FlashDirPx(get_dir(t_from, here))
	animate(M, pixel_x = -v[1]*3, pixel_y = -v[2]*3, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = v[1]*3, pixel_y = v[2]*3, time = 2, flags = ANIMATION_RELATIVE)

mob/proc/WarpArrive(turf/from)
	if(!glob.FLASH_MOVE || !from) return
	var/turf/here = get_step(src, 0)
	if(!here || here == from || here.z != from.z) return
	var/dist = get_dist(from, here)
	if(dist <= 1) return
	var/s = clamp((dist - 1) / 9, 0.15, 1)
	var/dx = clamp(from.x - here.x, -1, 1)
	var/dy = clamp(from.y - here.y, -1, 1)
	var/obj/Flash_Still/G = new
	G.appearance = appearance
	G.dir = dir
	G.loc = here
	if(PmActive())
		G.step_x = step_x
		G.step_y = step_y
	G.pixel_x = dx * (6 + round(8 * s))
	G.pixel_y = dy * (6 + round(8 * s))
	G.alpha = 100 + round(90 * s)
	animate(G, alpha = 0, time = 3 + round(3 * s))
	spawn(7)
		G.loc = null
	if(s > 0.5)
		var/obj/Flash_Still/G2 = new
		G2.appearance = appearance
		G2.dir = dir
		G2.loc = here
		if(PmActive())
			G2.step_x = step_x
			G2.step_y = step_y
		G2.pixel_x = dx * (18 + round(14 * s))
		G2.pixel_y = dy * (18 + round(14 * s))
		G2.alpha = 40 + round(60 * s)
		animate(G2, alpha = 0, time = 3 + round(2 * s))
		spawn(6)
			G2.loc = null
	Footfall(src)
	if(s > 0.35) Footfall(src)
	if(s > 0.75) Footfall(src)
	KenShockwave2(src, Size = 0.5 + 0.6 * s, Time = 5)

proc/FlashDashKickoff(mob/A, atom/Trg)
	if(!A || !Trg) return
	Footfall(A)
	Footfall(A)
	Footfall(A)
	spawn() Skid(A, 4)
	var/list/v = FlashDirPx(get_dir(A, Trg))
	if(!A.GetSuperDash())
		KenShockwave(A, Size = 0.35, PixelX = -v[1]*16, PixelY = -v[2]*16, Blend = 2, Time = 3)
	var/matrix/pmx = matrix(0.9, 0, 0, 0, 0.3, 0)
	pmx.Turn(FlashDirAngle(get_dir(A, Trg)) - 90)
	var/obj/fx_clashlight/P = FlashGlow(A, "#ffffff", pmx, 140)
	if(P)
		P.pixel_x -= v[1]*10
		P.pixel_y -= v[2]*10
		animate(P, pixel_x = P.pixel_x - v[1]*10, pixel_y = P.pixel_y - v[2]*10, alpha = 0, time = 3)
		spawn(4)
			if(A) A.vis_contents -= P
	animate(A, pixel_x = -v[1]*2, pixel_y = -v[2]*2, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = v[1]*2, pixel_y = v[2]*2, time = 1, flags = ANIMATION_RELATIVE)

proc/FlashWallPress(mob/M, kdir, remTiles)
	if(!M || !glob.FLASH_WORLD) return
	var/list/v = FlashDirPx(kdir)
	var/matrix/mx = matrix(1.1, 0, 0, 0, 0.35, 0)
	mx.Turn(FlashDirAngle(kdir))
	var/obj/fx_clashlight/P = FlashGlow(M, "#ffffff", mx, 190)
	if(P)
		P.pixel_x += v[1]*14
		P.pixel_y += v[2]*14
		animate(P, pixel_y = P.pixel_y - 6, alpha = 0, time = 4)
		spawn(5)
			if(M) M.vis_contents -= P
	Footfall(M)
	Footfall(M)
	animate(M, pixel_x = -v[1]*6, pixel_y = -v[2]*6, time = 2, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = v[1]*6, pixel_y = v[2]*6, time = 3, flags = ANIMATION_RELATIVE)

proc/FlashKOGutter(mob/M)
	if(!M || !glob.FLASH_WORLD) return
	var/obj/fx_clashlight/G = FlashGlow(M, "#fff2cf", matrix()*1.3, 170)
	if(G)
		animate(G, transform = matrix()*0.2, alpha = 0, time = 7, easing = QUAD_EASING|EASE_IN)
		spawn(8)
			if(M) M.vis_contents -= G
	Landfall(M, 0.7)

proc/FlashStandUp(mob/M)
	if(!M || !glob.FLASH_WORLD) return
	Footfall(M)
	animate(M, pixel_y = 2, time = 2, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_y = -2, time = 3, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_RELATIVE)
	var/obj/fx_clashlight/G = FlashGlow(M, "#fff2cf", matrix()*0.3, 0)
	if(G)
		animate(G, transform = matrix()*1.1, alpha = 150, time = 8)
		animate(alpha = 0, time = 6)
		spawn(15)
			if(M) M.vis_contents -= G

proc/FlashFacePlate(mob/M, obj/fx_clashlight/P, sx, sy)
	if(!M || !P) return
	var/matrix/mx = matrix(sx, 0, 0, 0, sy, 0)
	mx.Turn(FlashDirAngle(M.dir) - 90)
	P.transform = mx
	var/list/anc = FxChildAnchor(M)
	var/list/v = FlashDirPx(M.dir)
	P.pixel_x = anc[1] + v[1]*14
	P.pixel_y = anc[2] + v[2]*14

proc/FlashFaceWatch(mob/M, obj/fx_clashlight/P, arm = 0)
	set waitfor = 0
	var/last_dir = M ? M.dir : 0
	while(M && P && (arm ? M._flash_arm == P : M._flash_plate == P))
		if(arm && !M.AttackQueue)
			M.FlashQueueArmEnd()
			return
		if(M.dir != last_dir)
			last_dir = M.dir
			if(arm)
				var/list/anc = FxChildAnchor(M)
				var/list/v = FlashDirPx(M.dir)
				P.pixel_x = anc[1] + v[1]*10
				P.pixel_y = anc[2] + v[2]*10
			else
				FlashFacePlate(M, P, 0.55, 1.05)
		sleep(2)

mob/proc/FlashGuardPlate(state)
	if(state == 1)
		if(_flash_plate || !glob.FLASH_STATES) return
		var/obj/fx_clashlight/P = FlashGlow(src, "#9fd8ff", matrix(), 120)
		if(!P) return
		FlashFacePlate(src, P, 0.55, 1.05)
		_flash_plate = P
		FlashFaceWatch(src, P)
	else
		var/obj/fx_clashlight/P = _flash_plate
		_flash_plate = null
		if(!P) return
		if(state == 2)
			animate(P, transform = P.transform * 2, alpha = 0, time = 3, easing = QUAD_EASING|EASE_OUT)
		else
			animate(P, alpha = 0, time = 2)
		spawn(4)
			vis_contents -= P

mob/proc/FlashGuardChip()
	if(!_flash_plate) return
	if(world.time < _flash_chip_next) return
	_flash_chip_next = world.time + glob.FLASH_CHIP_CD_DS
	var/obj/fx_clashlight/P = _flash_plate
	var/heat = clamp(GuardMeter / max(glob.GUARD_METER_MAX, 1), 0, 1)
	P.color = rgb(159 + round(96 * heat), 216 - round(140 * heat), 255 - round(180 * heat))
	var/matrix/base = P.transform
	animate(P, alpha = 200, transform = base * 0.88, time = 1, flags = ANIMATION_PARALLEL)
	animate(alpha = 130 - round(60 * heat), transform = base, time = 4)
	Footfall(get_step(src, dir))
	var/list/v = FlashDirPx(dir)
	animate(src, pixel_x = -v[1]*2, pixel_y = -v[2]*2, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = v[1]*2, pixel_y = v[2]*2, time = 2, flags = ANIMATION_RELATIVE)

proc/FlashPerfectGuard(mob/A, mob/D)
	if(!A || !D || !glob.FLASH_STATES) return
	var/obj/fx_clashlight/P = D._flash_plate
	if(P)
		var/matrix/base = P.transform
		animate(P, transform = base * 0.08, alpha = 255, time = 1)
		animate(transform = base, alpha = 120, time = 3)
	spawn() AfterImage(A)
	var/matrix/bmx = matrix(1.8, 0, 0, 0, 0.2, 0)
	bmx.Turn(FlashDirAngle(D.dir) - 90)
	var/obj/fx_clashlight/B = FlashGlow(D, "#9fd8ff", bmx, 230)
	if(B)
		var/list/v = FlashDirPx(D.dir)
		B.pixel_x += v[1]*14
		B.pixel_y += v[2]*14
		animate(B, transform = bmx * 1.4, alpha = 0, time = 4, easing = QUAD_EASING|EASE_OUT)
		spawn(5)
			if(D) D.vis_contents -= B
	KenShockwave(D, Size = 0.6, Blend = 2, Time = 3)
	HitStop(D, A, glob.HIT_STOP_MIN)

mob/proc/FlashQueueArm()
	FlashQueueArmEnd()
	if(!glob.FLASH_STATES) return
	var/obj/Skills/Queue/Q = AttackQueue
	if(!Q) return
	var/w = clamp(0.3 + 0.15 * (Q.DamageMult + Q.KBMult * 0.3), 0.3, 1)
	var/list/v = FlashDirPx(dir)
	var/obj/fx_clashlight/G = FlashGlow(src, "#ffe9b0", matrix() * (1 + w), 40)
	if(!G) return
	G.pixel_x += v[1]*10
	G.pixel_y += v[2]*10
	_flash_arm = G
	animate(G, transform = matrix() * 0.4, alpha = 150 + round(60 * w), time = 8, easing = QUAD_EASING|EASE_IN)
	FlashFaceWatch(src, G, 1)

mob/proc/FlashQueueArmEnd()
	var/obj/fx_clashlight/G = _flash_arm
	_flash_arm = null
	if(!G) return
	animate(G, transform = matrix() * 1.6, alpha = 0, time = 2, easing = QUAD_EASING|EASE_OUT)
	spawn(3)
		vis_contents -= G

mob/proc/FlashQueueSpend(atom/enemy)
	var/obj/fx_clashlight/G = _flash_arm
	_flash_arm = null
	if(!G || !glob.FLASH_STATES) return 0
	var/matrix/mx = matrix(1.5, 0, 0, 0, 0.35, 0)
	if(enemy)
		mx.Turn(GetAngle(src, enemy) - 90)
	animate(G, transform = matrix() * 0.18, alpha = 255, time = 1)
	animate(transform = mx, alpha = 0, time = 3, easing = QUAD_EASING|EASE_OUT)
	spawn(5)
		vis_contents -= G
	return 1

proc/FlashChargeTick(mob/M, up = 0)
	set waitfor = 0
	if(!M || M._flash_charge_on || !glob.FLASH_STATES) return
	M._flash_charge_on = 1
	var/i = 0
	while(M && (up == 2 ? M.held_skill : (up ? M.PoweringUp : M.ChargingEnergy)))
		i++
		var/pct = 0.5
		var/ramp = 0
		if(up == 2)
			var/obj/Skills/HZ = M.held_skill
			pct = HZ ? clamp((world.time - M.held_charge_start) / max(HZ.ChargePeriod * 10, 1), 0.1, 1) : 0.5
		else if(up)
			pct = clamp(M.PowerControl / 200, 0.3, 1)
		else
			pct = clamp(M.Energy / max(100 - M.TotalFatigue, 1), 0, 1)
			ramp = min(1, (world.time - M.charge_started_at) / max(glob.CHARGE_RAMP_DS, 1))
		var/n = 1 + round(2 * max(pct, ramp * 0.8) * GfxBudgetScale())
		for(var/j = 1, j <= n, j++)
			var/obj/fx_clashlight/S = FlashGlow(M, up == 2 ? "#cfe6ff" : (up ? "#ffd9a0" : "#a8e4ff"), matrix()*0.22, 0)
			if(!S) continue
			var/a = rand(0, 359)
			S.pixel_x += round(sin(a) * 38)
			S.pixel_y += round(cos(a) * 38)
			if(up == 1)
				animate(S, pixel_x = S.pixel_x - round(sin(a) * 10), pixel_y = S.pixel_y + 40, alpha = 170, time = 4)
				animate(alpha = 0, transform = matrix()*0.1, time = 3)
			else
				animate(S, pixel_x = S.pixel_x - round(sin(a) * 38), pixel_y = S.pixel_y - round(cos(a) * 38), alpha = 180, time = 5 - round(2 * max(ramp, up == 2 ? pct : 0)), easing = QUAD_EASING|EASE_IN)
				animate(alpha = 0, transform = matrix()*0.08, time = 2)
			spawn(8)
				if(M) M.vis_contents -= S
		if(i % 4 == 2)
			Footfall(M)
		sleep(7)
	if(M) M._flash_charge_on = 0

proc/FlashChargeCap(mob/M)
	if(!M || !glob.FLASH_STATES) return
	KenShockwave(M, Size = 0.8, Blend = 2, Time = 4)
	M.Earthquake(4, -2,2,-2,2, 0, 0)
	animate(M, pixel_y = 3, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_y = -3, time = 2, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_RELATIVE)
	Footfall(M)
	Footfall(M)
	Landfall(M, 0.6)
	var/obj/fx_clashlight/S = FlashGlow(M, "#a8e4ff", matrix()*1.2, 0)
	if(S)
		animate(S, transform = matrix()*0.3, alpha = 200, time = 2, easing = QUAD_EASING|EASE_IN)
		animate(transform = matrix()*1.6, alpha = 0, time = 3, easing = QUAD_EASING|EASE_OUT)
		spawn(6)
			if(M) M.vis_contents -= S

proc/FlashThrowRelease(mob/A, mob/V, kdir, dist)
	if(!glob.FLASH_MOVE || !A || !V) return
	var/w = min(dist / glob.MAX_KB_TIME, 1)
	var/list/v = FlashDirPx(kdir)
	Footfall(A)
	Footfall(A)
	animate(A, pixel_x = v[1]*4, pixel_y = v[2]*4, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = -v[1]*4, pixel_y = -v[2]*4, time = 2, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_RELATIVE)
	KenShockwave(V, Size = clamp(0.4 + w, 0.4, 1.4), Time = 4)
	spawn(1)
		if(V) KenShockwave(V, Size = clamp(0.7 + 1.2 * w, 0.7, 1.9), Blend = 2, Time = 5)

proc/FlashThrowApex(mob/M)
	if(!glob.FLASH_MOVE || !M || !M.Knockbacked) return
	var/obj/Flash_Still/G = new
	G.appearance = M.appearance
	G.dir = M.dir
	G.loc = M.loc
	if(PmActive())
		G.step_x = M.step_x
		G.step_y = M.step_y
	G.pixel_z = M.pixel_z
	G.transform = G.transform * matrix(1, 0.18, 0, 0, 1, 0)
	G.alpha = 120
	animate(G, alpha = 0, time = 5)
	spawn(6)
		G.loc = null

proc/FlashDashArrive(mob/A, mob/V)
	if(!glob.FLASH_MOVE || !A) return
	var/list/v = FlashDirPx(A.dir)
	var/obj/fx_clashlight/K = FlashGlow(A, "#ffffff", matrix()*0.9, 150)
	if(K)
		K.pixel_x += v[1]*8
		K.pixel_y += v[2]*8
		animate(K, transform = matrix()*0.25, alpha = 255, time = 1, easing = QUAD_EASING|EASE_IN)
		animate(transform = matrix()*1.3, alpha = 0, time = 2, easing = QUAD_EASING|EASE_OUT)
		spawn(4)
			if(A) A.vis_contents -= K
	Footfall(get_step(A, A.dir))
	Footfall(get_step(A, A.dir))
	Footfall(get_step(A, turn(A.dir, 45)))
	Footfall(get_step(A, turn(A.dir, -45)))
	Footfall(A)

proc/FlashRdPart(mob/M, turf/from)
	if(!glob.FLASH_MOVE || !M || !from) return
	var/turf/here = get_step(M, 0)
	if(!here || here.z != from.z) return
	var/dist = get_dist(from, here)
	if(dist < 2) return
	var/turf/mid = locate(round((from.x + here.x) / 2), round((from.y + here.y) / 2), here.z)
	if(!mid) return
	var/shear = 0.16
	if(M.Target && M.Target.x < M.x)
		shear = -0.16
	var/obj/Flash_Still/G = new
	G.appearance = M.appearance
	G.dir = M.dir
	G.loc = mid
	G.transform = G.transform * matrix(1, shear, 0, 0, 1, 0)
	G.alpha = 150
	animate(G, alpha = 150, time = 6)
	animate(alpha = 0, time = 4)
	spawn(11)
		G.loc = null

proc/FlashAlphaCounter(mob/M)
	if(!M || !glob.FLASH_STATES) return
	var/obj/fx_clashlight/P = M._flash_plate
	if(P)
		var/matrix/base = P.transform
		animate(P, transform = base * 0.2, alpha = 255, time = 1)
		animate(transform = base, alpha = 120, time = 3)
	for(var/i = 0, i < 3, i++)
		spawn(i * 2)
			if(M) KenShockwave(M, Size = 0.5 + i * 0.35, Blend = 2, Time = 3)

proc/FlashGrabClinch(mob/A, mob/V)
	if(!glob.FLASH_STATES || !A || !V) return
	var/turf/Ta = get_step(A, 0)
	var/turf/Tv = get_step(V, 0)
	if(Ta && Tv && Ta.z == Tv.z)
		KenShockwave(V, Size = 0.45, PixelX = (Ta.x - Tv.x) * 16, PixelY = (Ta.y - Tv.y) * 16, Blend = 2, Time = 3)
	Footfall(A)
	var/list/v = FlashDirPx(get_dir(A, V) || A.dir)
	animate(A, pixel_x = v[1]*3, pixel_y = v[2]*3, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = -v[1]*3, pixel_y = -v[2]*3, time = 2, flags = ANIMATION_RELATIVE)

mob/proc/FlashGrabBand(on)
	if(on)
		if(_flash_band || !glob.FLASH_STATES) return
		var/obj/fx_clashlight/B = FlashGlow(src, "#ffffff", matrix(1.7, 0, 0, 0, 0.55, 0), 0, under = 1)
		if(!B) return
		B.pixel_y -= 8
		_flash_band = B
		animate(B, alpha = 70, time = 3)
	else
		var/obj/fx_clashlight/B = _flash_band
		_flash_band = null
		if(!B) return
		animate(B, transform = matrix() * 0.3, alpha = 0, time = 2)
		spawn(3)
			vis_contents -= B

proc/FlashBeamIgnite(datum/beam/B, omni = 0)
	if(!glob.FLASH_STATES || !B || !B.owner) return
	var/mob/M = B.owner
	var/w = clamp((B.charge - 0.5), 0, 1)
	var/col = FxBlastTint(B.skill)
	KenShockwave2(M, Size = 0.7 + 0.6 * w, Time = 4)
	Footfall(M)
	if(col)
		FxLightPulse(get_step(M, 0), 0.8 + 0.6 * w, col, 0.85)
	if(omni)
		return
	var/list/v = FlashDirPx(B.bdir)
	if(w > 0.1)
		Footfall(M)
		animate(M, pixel_x = -v[1]*(2 + round(2*w)), pixel_y = -v[2]*(2 + round(2*w)), time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
		animate(pixel_x = v[1]*(2 + round(2*w)), pixel_y = v[2]*(2 + round(2*w)), time = 3, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_RELATIVE)
	var/matrix/mmx = matrix(0.5 + 0.5*w, 0, 0, 0, 0.9 + 0.5*w, 0)
	mmx.Turn(FlashDirAngle(B.bdir) - 90)
	var/obj/fx_clashlight/Mz = FlashGlow(M, col ? col : "#ffffff", mmx, 200)
	if(Mz)
		Mz.pixel_x += v[1]*18
		Mz.pixel_y += v[2]*18
		animate(Mz, transform = mmx * 1.6, alpha = 0, time = 4, easing = QUAD_EASING|EASE_OUT)
		spawn(5)
			if(M) M.vis_contents -= Mz

proc/FlashSweetSpot(mob/M)
	if(!M || !glob.FLASH_STATES) return
	GfxWatchdogSnapshot("SWEETSPOT")
	KenShockwave2(M, Size = 0.9, Time = 4)
	KenShockwave(M, icon = 'KenShockwaveFocus.dmi', Size = 0.5, Blend = 2, Time = 3)
	_HitStopClient(M, 1)
	var/obj/fx_clashlight/S = FlashGlow(M, "#ffd700", matrix()*0.4, 230)
	if(S)
		animate(S, transform = matrix()*1.5, alpha = 0, time = 4, easing = QUAD_EASING|EASE_OUT)
		spawn(5)
			if(M) M.vis_contents -= S

proc/FlashVolleyHand(mob/M, obj/Skills/Projectile/Z, on)
	if(on)
		if(!glob.FLASH_STATES || !M || M._flash_hand) return
		var/col = FxBlastTint(Z) || "#ffffff"
		var/list/v = FlashDirPx(M.dir)
		var/obj/fx_clashlight/H = FlashGlow(M, col, matrix()*0.3, 0)
		if(!H) return
		H.pixel_x += v[1]*10
		H.pixel_y += v[2]*10 + 2
		M._flash_hand = H
		animate(H, alpha = 190, transform = matrix()*0.45, time = 2)
	else
		var/obj/fx_clashlight/H = M ? M._flash_hand : null
		if(M) M._flash_hand = null
		if(!H || !M) return
		animate(H, alpha = 0, transform = matrix()*0.2, time = 2)
		spawn(3)
			if(M) M.vis_contents -= H

proc/FlashVolleyRecoil(mob/M)
	if(!M || M._flash_env_busy || !glob.FLASH_STATES) return
	M._flash_env_busy = 1
	var/list/v = FlashDirPx(M.dir)
	animate(M, pixel_x = -v[1], pixel_y = -v[2], time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = v[1], pixel_y = v[2], time = 1, flags = ANIMATION_RELATIVE)
	spawn(2)
		if(M) M._flash_env_busy = 0

proc/FlashDeflect(mob/D, atom/movable/P)
	if(!glob.FLASH_STATES || !D) return
	if(P && P.loc)
		var/obj/Flash_Still/G = new
		G.appearance = P.appearance
		G.dir = P.dir
		G.loc = P.loc
		G.pixel_x = P.pixel_x
		G.pixel_y = P.pixel_y
		G.transform = G.transform * matrix(1.4, 0, 0, 0, 0.7, 0)
		G.alpha = 130
		animate(G, alpha = 0, time = 3)
		spawn(4)
			G.loc = null
	if(world.time >= D._flash_defl_next)
		D._flash_defl_next = world.time + 2
		KenShockwave(D, Size = 0.35, Blend = 2, Time = 2)

proc/FlashTransformMoment(mob/M)
	if(!M || !glob.FLASH_STATES) return
	var/turf/T = get_step(M, 0)
	KenShockwave2(M, Size = 1.4, Time = 6)
	Footfall(M)
	Footfall(M)
	for(var/j = 1, j <= 4, j++)
		var/obj/fx_clashlight/S = FlashGlow(M, "#ffe9b0", matrix()*0.2, 0)
		if(!S) continue
		S.pixel_x += rand(-20, 20)
		S.pixel_y += rand(-10, 4)
		animate(S, pixel_y = S.pixel_y + 44, alpha = 170, time = 5)
		animate(alpha = 0, time = 3)
		spawn(9)
			if(M) M.vis_contents -= S
	if(T)
		for(var/client/C)
			var/mob/CM = C.mob
			if(!CM || CM.z != T.z || get_dist(CM, T) > 15) continue
			FxZoomPunch(C, T, 0.97, 3)

proc/FlashDragonClash(mob/A, mob/B)
	set waitfor = 0
	if(!glob.FLASH_MOVE || !A || !B) return
	if(world.time < A._clash_flash_next || world.time < B._clash_flash_next) return
	A._clash_flash_next = world.time + 30
	B._clash_flash_next = world.time + 30
	A.dir = get_dir(A, B) || A.dir
	B.dir = get_dir(B, A) || B.dir
	var/turf/TA = get_step(A, 0)
	var/turf/TB = get_step(B, 0)
	if(!TA || !TB || TA.z != TB.z) return
	var/px = (TB.x - TA.x) * 16
	var/py = (TB.y - TA.y) * 16
	var/list/v = FlashDirPx(get_dir(A, B) || A.dir)
	KenShockwave(A, Size = 0.6, PixelX = px, PixelY = py, Blend = 2, Time = 3)
	var/obj/fx_clashlight/Bulb = FlashGlow(A, "#ffffff", matrix()*0.5, 170)
	if(Bulb)
		Bulb.pixel_x += px
		Bulb.pixel_y += py
	for(var/i = 1, i <= 3, i++)
		if(!A || !B) break
		animate(A, pixel_x = v[1]*2, pixel_y = v[2]*2, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
		animate(pixel_x = -v[1]*2, pixel_y = -v[2]*2, time = 1, flags = ANIMATION_RELATIVE)
		animate(B, pixel_x = -v[1]*2, pixel_y = -v[2]*2, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
		animate(pixel_x = v[1]*2, pixel_y = v[2]*2, time = 1, flags = ANIMATION_RELATIVE)
		if(Bulb)
			animate(Bulb, transform = matrix() * (0.5 + 0.25 * i), time = 2, flags = ANIMATION_PARALLEL)
		Footfall(A)
		Footfall(B)
		KenShockwave(A, Size = 0.35 + 0.2 * i, PixelX = px, PixelY = py, Blend = 2, Time = 3)
		sleep(2)
	if(Bulb && A)
		animate(Bulb, transform = matrix() * 1.6, alpha = 0, time = 3, easing = QUAD_EASING|EASE_OUT)
		spawn(4)
			if(A) A.vis_contents -= Bulb
	if(A && B && TA && TB)
		GfxWatchdogSnapshot("CLASH_BREAK")
		var/turf/MT = locate(round((TA.x + TB.x) / 2), round((TA.y + TB.y) / 2), TA.z)
		if(MT)
			FxHeavyImpact(MT, priority = 1)
		HitStop(A, B, 10)
		Landfall(A, 0.5)
		Landfall(B, 0.5)

proc/KOCameraPan(client/C, turf/T, hold)
	if(!C || !C.mob) return
	var/turf/E = get_step(C.eye ? C.eye : C.mob, 0)
	if(!E || E.z != T.z) return
	var/dx = clamp((T.x - E.x) * 32, -96, 96)
	var/dy = clamp((T.y - E.y) * 32, -72, 72)
	if(!dx && !dy) return
	animate(C, pixel_x = round(dx * 0.4), pixel_y = round(dy * 0.4), time = 4, easing = QUAD_EASING|EASE_OUT)
	spawn(4 + hold)
		if(C) animate(C, pixel_x = 0, pixel_y = 0, time = 5, easing = QUAD_EASING)

proc/FlashKOMoment(mob/M)
	set waitfor = 0
	if(!M || !glob.FLASH_WORLD) return
	var/turf/T = get_step(M, 0)
	if(!T) return
	SlowMoZone(M, glob.KO_SLOWMO_RADIUS, glob.KO_SLOWMO_MULT, glob.KO_SLOWMO_DS)
	for(var/client/C)
		var/mob/CM = C.mob
		if(!CM) continue
		var/turf/ET = get_step(C.eye ? C.eye : CM, 0)
		if(!ET || ET.z != T.z || get_dist(ET, T) > 15) continue
		KOCameraPan(C, T, 10)

proc/FlashKOFall(mob/M)
	if(!M || !glob.FLASH_WORLD) return
	var/obj/Flash_Still/G = new
	G.appearance = M.appearance
	G.dir = M.dir
	G.loc = M.loc
	if(PmActive())
		G.step_x = M.step_x
		G.step_y = M.step_y
	G.layer = M.layer + 0.01
	var/matrix/base = G.transform ? matrix(G.transform) : matrix()
	var/matrix/tilted = matrix(base)
	tilted.Turn(90)
	M.alpha = 0
	animate(G, transform = tilted, pixel_y = -4, time = 10, easing = QUAD_EASING|EASE_IN)
	animate(alpha = 0, time = 3)
	spawn(10)
		if(M)
			Landfall(M, 0.5)
			M.Earthquake(3, -2,2,-2,2, 0, 0)
	spawn(11)
		if(M)
			animate(M, alpha = 255, time = 2)
	spawn(14)
		G.loc = null
	FlashKOMoment(M)
