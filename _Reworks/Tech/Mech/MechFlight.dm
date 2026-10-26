globalTracker/var
	MECH_FLY_RISE_TICKS = 5
	MECH_FLY_IDLE_LAND = 100
	MECH_FLY_FLASH_DS = 10
	MECH_FLY_ACCEL = 0.125
	MECH_FLY_DRAG = 0.32
	MECH_FLY_VMAX = 1.2
	MECH_FLY_REVERSE_MULT = 2
	MECH_FLY_SNAP = 0.5
	MECH_FLY_STEP_MAX = 32
	MECH_FLY_DRAG_MIN = 0.02
	MECH_FLY_DRAG_MAX = 0.9
	MECH_FLY_LINE_GAP = 20
	MECH_FLY_LAYER = 1.5
	MECH_HOVER_ACCEL = 0.5
	MECH_THRUST_TICKS = 4
	MECH_THRUST_HEAT = 8
	MECH_THRUST_CD = 30
	MECH_THRUST_SPEED = 2
	MECH_THRUST_CHARGES = 1
	MECH_THRUST_REACH = 2
	MECH_STOMP_DMG = 1
	MECH_STOMP_RADIUS = 2.5
	MECH_STOMP_WAVE_SIZE = 1
	MECH_STOMP_WAVE_BLEND = 2
	MECH_STOMP_WAVE_TIME = 4

var/list/MECH_FLASH_WHITE = list(1,0,0, 0,1,0, 0,0,1, 1,1,1)
var/list/MECH_FLASH_CLEAR = list(1,0,0, 0,1,0, 0,0,1, 0,0,0)

mob/var/tmp
	mech_air = 0
	mech_air_until = 0
	mech_vx = 0
	mech_vy = 0
	mech_ax = 0
	mech_ay = 0
	mech_input_dir = 0
	mech_input_at = -100
	mech_idle_since = 0
	mech_fly_token = 0
	mech_fly_running = 0
	mech_burst_vx = 0
	mech_burst_vy = 0
	mech_burst_left = 0
	mech_thrust_attack = 0
	mech_thrust_ram = 0
	list/mech_thrust_hits
	obj/Skills/mech_thrust_fresh

/obj/Skills/Mech/Thrust
	name = "Thrust"
	desc = "Fire the mech's thrusters in a short burst along your movement input, or your facing when you hold none. A grounded mech takes off first. Costs heat."
	NoGCD = 1
	MaxCharges = 1
	Charges = 1
	ChargeRefresh = 3
	Cooldown = 3
	verb/Thrust()
		set category = "Skills"
		usr.MechThrustPress(src)

/obj/Skills/AutoHit/Mech_Stomp
	name = "Predator Stomp"
	Area = "Circle"
	Distance = 2.5
	StrScaling = 1
	DamageMult = 1
	Knockback = 1
	NoGCD = 1
	Cooldown = 0

mob/proc/MechFlyNum(key, def)
	var/list/row = mech ? mech.MechRow() : null
	var/v = row ? row[key] : null
	return isnum(v) ? v : def

mob/proc/MechFlyBaseY()
	return MechFlyNum("offset_y", 0)

mob/proc/MechFlyRise()
	return MechFlyNum("rise", 0)

mob/proc/MechFlyStates()
	var/list/row = mech ? mech.MechRow() : null
	var/list/L = row ? row["fly_states"] : null
	if(islist(L) && L.len >= 3) return L
	var/s = row ? row["state"] : ""
	return list(s, s, s)

mob/proc/MechFlyState()
	var/list/L = MechFlyStates()
	switch(mech_air)
		if(0) return L[1]
		if(2) return (mech_vx || mech_vy) ? L[3] : L[2]
	return L[2]

mob/proc/MechCanFly(obj/Items/Mech/R)
	if(!R) R = mech
	if(!R) return 0
	var/list/row = R.MechRow()
	if(row && row["fly"]) return 1
	for(var/obj/Items/P in R.MechPartsOfKind("Back"))
		if(MechPartVar(P, "grants_flight")) return 1
	return 0

mob/proc/MechHovers(obj/Items/Mech/R)
	if(!R) R = mech
	if(!R || MechLimp() || MechCanFly(R)) return 0
	var/list/row = R.MechRow()
	return (row && row["hover"]) ? 1 : 0

mob/Players/MechAirborne()
	return (mech && mech_air) ? 1 : 0

mob/proc/MechFlyLine(what, text)
	if(what == mech_refuse_what && world.time < mech_refuse_at) return
	mech_refuse_what = what
	mech_refuse_at = world.time + glob.MECH_FLY_LINE_GAP
	src << text

mob/proc/MechInputRecord()
	var/d = heldDir()
	if(d && !Allow_Move(d)) d = 0
	mech_input_dir = d
	mech_input_at = world.time
	return d

mob/proc/MechInputDir()
	return (world.time - mech_input_at <= world.tick_lag) ? mech_input_dir : 0

mob/Players/MechInputDir()
	if(!key1 && !key2 && !key3 && !key4) return 0
	if(!..()) return 0
	return heldDir()

mob/proc/MechFacingFree()
	return !dir_locked && Beaming != 2 && !Stasis && !Frozen && !Launched && !Stunned && !Suspended && !ActionLocked && !PoweringUp

mob/proc/MechFaceInput(held)
	if(held && MechFacingFree()) dir = held
	return dir

mob/proc/MechRooted()
	if(!Move_Requirements()) return 1
	if(passive_handler && passive_handler["Snared"] > 0) return 1
	if(splat_stagger_until > world.time) return 1
	if(grabbed && grabbed.Grab == src) return 1
	return 0

mob/proc/MechDirUnit(d)
	var/ux = 0
	var/uy = 0
	if(d & EAST) ux = 1
	else if(d & WEST) ux = -1
	if(d & NORTH) uy = 1
	else if(d & SOUTH) uy = -1
	if(ux && uy)
		ux *= 0.70710678
		uy *= 0.70710678
	return list(ux, uy)

mob/proc/MechSpeed()
	return sqrt(mech_vx * mech_vx + mech_vy * mech_vy)

mob/proc/MechMoving()
	if(!mech) return 0
	if(mech_vx || mech_vy || mech_burst_left > 0) return 1
	if(mech_air == 1 || mech_air == 3) return 1
	return heldDir() ? 1 : 0

mob/proc/MechFlyBudget()
	var/f = Flying
	Flying = 0
	var/ms = MovementSpeed()
	Flying = f
	var/delay = GunMoveDelay(glob.BASE_LOOP_DELAY + ms)
	if(Crippled && !mech_air)
		var/rev = GetDebuffReversal()
		if(rev)
			delay /= (1 + ((glob.MAX_CRIPPLE_MULT * (Crippled / glob.CRIPPLE_DIVISOR) / 2) * rev))
		else
			delay *= (1 + (glob.MAX_CRIPPLE_MULT * (Crippled / glob.CRIPPLE_DIVISOR)))
	delay *= SlowMoDelayMult(src)
	. = 32 * glob.PLAYER_SPEED_MULT / max(1, -round(-delay))
	if(!mech_air && Swim && getHoverChassis()) . *= glob.MECH_HOVER_SWIM

mob/proc/MechVmax()
	if(!mech) return 0
	. = MechFlyBudget() * MechFlyNum("move", 1) * MechFlyNum("fly_vmax", glob.MECH_FLY_VMAX)
	if(mech_air) . *= MechFlightSpeedMult()

mob/proc/MechFlyDrag(hover)
	var/drag = MechFlyNum("fly_drag", glob.MECH_FLY_DRAG)
	var/m = 1
	if(mech_air)
		m = MechDriftMult()
	else if(hover)
		m = MechGroundDriftMult()
	if(m > 0) drag /= m
	return clamp(drag, glob.MECH_FLY_DRAG_MIN, glob.MECH_FLY_DRAG_MAX)

mob/proc/MechAccelerate(held, vmax, hover)
	var/accel = vmax * MechFlyNum("fly_accel", glob.MECH_FLY_ACCEL)
	if(hover) accel *= glob.MECH_HOVER_ACCEL
	var/list/u = MechDirUnit(held)
	var/ux = u[1]
	var/uy = u[2]
	if(ux || uy)
		if(ux * mech_vx + uy * mech_vy < 0) accel *= glob.MECH_FLY_REVERSE_MULT
		mech_vx += accel * ux
		mech_vy += accel * uy
	else
		var/keep = 1 - MechFlyDrag(hover)
		mech_vx *= keep
		mech_vy *= keep
		if(MechSpeed() < glob.MECH_FLY_SNAP)
			mech_vx = 0
			mech_vy = 0
	var/s = MechSpeed()
	if(s > vmax && s > 0)
		mech_vx *= vmax / s
		mech_vy *= vmax / s

mob/proc/MechStepAxis(d, px)
	. = 0
	var/horiz = (d == EAST || d == WEST)
	while(px > 0)
		var/use = min(px, glob.MECH_FLY_STEP_MAX)
		var/b = horiz ? (x - 1) * 32 + step_x : (y - 1) * 32 + step_y
		step_size = use
		dir = d
		step(src, d)
		var/got = abs((horiz ? (x - 1) * 32 + step_x : (y - 1) * 32 + step_y) - b)
		. += got
		if(got < use) break
		px -= use

mob/proc/MechFlyMove(face)
	mech_ax += mech_vx
	mech_ay += mech_vy
	var/dx = HurtTrunc(mech_ax)
	var/dy = HurtTrunc(mech_ay)
	mech_ax -= dx
	mech_ay -= dy
	if(!dx && !dy) return 0
	glide_size = max(1, round(sqrt(dx * dx + dy * dy)))
	var/mx = 0
	var/my = 0
	if(dx)
		mx = MechStepAxis(dx > 0 ? EAST : WEST, abs(dx))
		if(mx < abs(dx))
			mech_vx = 0
			mech_ax = 0
			mech_burst_vx = 0
	if(dy)
		my = MechStepAxis(dy > 0 ? NORTH : SOUTH, abs(dy))
		if(my < abs(dy))
			mech_vy = 0
			mech_ay = 0
			mech_burst_vy = 0
	step_size = 32
	dir = face
	if(mx || my) gun_last_move = world.time
	return mx + my

mob/proc/MechVelocityZero()
	mech_vx = 0
	mech_vy = 0
	mech_ax = 0
	mech_ay = 0
	mech_burst_vx = 0
	mech_burst_vy = 0
	mech_burst_left = 0
	MechThrustEnd()

mob/proc/MechImpulse(d, px, ticks = 1)
	if(!mech || !d || px <= 0) return 0
	var/list/u = MechDirUnit(d)
	mech_burst_vx = u[1] * px
	mech_burst_vy = u[2] * px
	mech_burst_left = max(1, round(ticks))
	MechFlightEnsure()
	return 1

mob/proc/MechFlash()
	color = MECH_FLASH_WHITE
	MechBodyState()
	animate(src, color = MECH_FLASH_CLEAR, time = glob.MECH_FLY_FLASH_DS)

mob/proc/MechFlightEnsure()
	if(mech_fly_running || !mech) return
	mech_fly_running = 1
	MechFlightLoop(++mech_fly_token)

mob/proc/MechFlightLoop(token)
	set waitfor = 0
	while(1)
		sleep(world.tick_lag)
		if(token != mech_fly_token) return
		if(!mech || !MechFlightTick()) break
	mech_fly_running = 0

mob/proc/MechFlightReset()
	mech_fly_token++
	mech_fly_running = 0
	if(mech_air)
		layer = MOB_LAYER
		UpdateStandingLayer()
	mech_air = 0
	mech_input_dir = 0
	mech_input_at = -100
	Flying = 0
	MechVelocityZero()

mob/proc/MechTakeoff()
	if(!mech || mech_air) return 0
	mech_air = 1
	mech_air_until = world.time + glob.MECH_FLY_RISE_TICKS
	mech_idle_since = world.time
	Flying = 1
	layer = MOB_LAYER + glob.MECH_FLY_LAYER
	MechFlash()
	animate(src, pixel_y = MechFlyBaseY() + MechFlyRise(), time = glob.MECH_FLY_RISE_TICKS, flags = ANIMATION_PARALLEL)
	MechFlightEnsure()
	return 1

mob/proc/MechLand(forced = 0)
	if(!mech || (mech_air != 1 && mech_air != 2)) return 0
	mech_air = 3
	mech_air_until = world.time + glob.MECH_FLY_RISE_TICKS
	MechVelocityZero()
	if(forced) Flying = 0
	animate(src, pixel_y = MechFlyBaseY(), time = glob.MECH_FLY_RISE_TICKS)
	MechBodyState()
	MechFlightEnsure()
	return 1

mob/proc/MechLandCancel()
	if(mech_air != 3) return 0
	mech_air = 2
	mech_idle_since = world.time
	animate(src, pixel_y = MechFlyBaseY() + MechFlyRise(), time = max(world.tick_lag, glob.MECH_FLY_RISE_TICKS - max(0, mech_air_until - world.time)))
	MechBodyState()
	return 1

mob/proc/MechTouchdown()
	mech_air = 0
	Flying = 0
	layer = MOB_LAYER
	UpdateStandingLayer()
	MechVelocityZero()
	pixel_y = MechFlyBaseY()
	MechFlash()
	MechStompHook()

mob/proc/MechMustLand()
	return (MechLimp() || !MechCanFly()) ? 1 : 0

mob/proc/MechFlightTick()
	return 0

mob/Players/MechFlightTick()
	if(!mech) return 0
	if(mech_air == 1)
		MechFaceInput(MechInputDir())
		if(world.time < mech_air_until) return 1
		mech_air = 2
		mech_idle_since = world.time
		MechBodyState()
	if(mech_air == 3)
		if(Flying && MechInputDir() && !MechMustLand() && !GravityWellHolds())
			MechLandCancel()
			return 1
		if(world.time < mech_air_until) return 1
		MechTouchdown()
		return 0
	if(mech_air == 2)
		if(GravityWellHolds())
			src << "<font color='#8be9ff'>A gravity well drags you out of the air!</font>"
			MechLand(1)
			return 1
		if(!Flying)
			MechLand(1)
			return 1
		if(MechMustLand())
			MechLand()
			return 1
	var/hover = !mech_air && MechHovers()
	if(!mech_air && !hover && mech_burst_left <= 0)
		MechVelocityZero()
		return 0
	if(MechRooted())
		MechVelocityZero()
		if(mech_air) MechBodyState()
		return (mech_air || hover) ? 1 : 0
	var/held = MechInputDir()
	var/face = MechFaceInput(held)
	var/bursting = mech_burst_left > 0
	if(bursting)
		mech_vx = mech_burst_vx
		mech_vy = mech_burst_vy
		mech_burst_left--
	else
		MechAccelerate(held, MechVmax(), hover)
	MechFlyMove(face)
	if(bursting)
		MechThrustContacts()
		if(mech_burst_left <= 0) MechThrustEnd()
	if(!mech_air && !hover)
		if(mech_burst_left > 0) return 1
		MechVelocityZero()
		return 0
	var/moving = (mech_vx || mech_vy) ? 1 : 0
	if(moving || held || bursting) mech_idle_since = world.time
	if(mech_air == 2)
		MechBodyState()
		if(!moving && !held && world.time - mech_idle_since >= glob.MECH_FLY_IDLE_LAND) MechLand()
		return 1
	return (moving || held || mech_burst_left > 0) ? 1 : 0

mob/Players/PmMovementTick()
	if(!mech) return ..()
	if(mech_burst_left > 0 || mech_air || MechHovers())
		MechInputRecord()
		if(mech) MechFlightEnsure()
		return
	if(MechCanFly() && !MechLimp())
		if(GravityWellHolds())
			MechFlyLine("field", "A gravity well holds [mech] to the ground.")
			return ..()
		var/d = MechInputRecord()
		if(mech && d) MechTakeoff()
		return
	return ..()

mob/Players/FieldGround()
	if(!mech) return ..()
	if(mech_air == 1 || mech_air == 2) MechLand(1)
	Flying = 0

mob/Players/MechBodyState()
	if(!mech) return ..()
	var/s = MechFlyState()
	if(icon_state != s) icon_state = s

mob/Players/MechBodyLook()
	..()
	if(!mech) return
	if(mech_air == 1 || mech_air == 2) pixel_y = MechFlyBaseY() + MechFlyRise()
	MechBodyState()

mob/proc/MechPilotLand()
	if(!Flying) return
	Flying = 0
	density = 1
	layer = MOB_LAYER
	UpdateStandingLayer()
	pixel_z = 0

mob/Players/MechMount(obj/Items/Mech/R, remount = 0)
	MechPilotLand()
	MechFlightReset()
	..()
	if(!R || mech != R) return
	var/obj/Skills/S = R.part_kept ? R.part_kept[/obj/Skills/Mech/Thrust] : null
	if(S)
		MechThrustSync(S)
		if(!length(S.recharge_ends))
			S.Charges = S.MaxCharges
			S.Using = 0
	if(mech_thrust_fresh)
		MechThrustSlot(R, mech_thrust_fresh)
		mech_thrust_fresh = null
	MechBodyState()

mob/Players/MechDismount(wreck = 0, silent = 0)
	if(mech)
		if(mech_air) animate(src)
		MechFlightReset()
	return ..()

mob/Players/MechGrantSkills(obj/Items/Mech/R)
	if(R)
		var/obj/Skills/T = R.part_kept ? R.part_kept[/obj/Skills/Mech/Thrust] : null
		if(MechCanFly(R))
			var/fresh = !T
			T = R.MechKept(/obj/Skills/Mech/Thrust)
			if(fresh) mech_thrust_fresh = T
		else if(T)
			R.part_kept -= /obj/Skills/Mech/Thrust
			MechThrustUnslot(R, T)
			if(T.loc == src) DeleteSkill(T)
			else del T
	return ..()

mob/proc/MechThrustSlot(obj/Items/Mech/R, obj/Skills/S)
	if(!R || !R.shortcuts || !S) return
	for(var/i = 1 to HOTBAR_SLOTS)
		if(R.shortcuts.vars["shortcut[i]"] == S) return
	for(var/i = 1 to HOTBAR_SLOTS)
		if(!R.shortcuts.vars["shortcut[i]"])
			R.shortcuts.vars["shortcut[i]"] = S
			if(client) client.RefreshHotbar()
			return

mob/proc/MechThrustUnslot(obj/Items/Mech/R, obj/Skills/S)
	if(!R || !R.shortcuts || !S) return
	for(var/i = 1 to HOTBAR_SLOTS)
		if(R.shortcuts.vars["shortcut[i]"] == S) R.shortcuts.vars["shortcut[i]"] = null

mob/proc/MechAllParts()
	. = list()
	if(!mech) return
	for(var/s in mech.parts)
		var/obj/Items/P = mech.MechPartIn(s)
		if(P && !(P in .)) . += P

mob/proc/MechThrustCharges()
	. = glob.MECH_THRUST_CHARGES
	for(var/obj/Items/P in MechAllParts())
		var/c = MechPartVar(P, "thrust_charges")
		if(isnum(c) && c > .) . = round(c)

mob/proc/MechThrustTicks()
	var/m = 1
	for(var/obj/Items/P in MechAllParts())
		var/l = MechPartVar(P, "thrust_len_mult")
		if(isnum(l) && l > m) m = l
	return max(1, round(glob.MECH_THRUST_TICKS * m))

mob/proc/MechThrustFlag(v)
	for(var/obj/Items/P in MechAllParts())
		if(MechPartVar(P, v)) return 1
	return 0

mob/proc/MechThrustPx()
	return glob.MECH_THRUST_SPEED * MechVmax() * (1 + passive_handler.Get("MechThrustPct") / 100)

mob/proc/MechThrustHeat()
	return glob.MECH_THRUST_HEAT * MechThrustHeatMult()

mob/proc/MechThrustSync(obj/Skills/S)
	if(!S) return
	var/n = max(1, MechThrustCharges())
	if(S.MaxCharges != n)
		S.Charges = clamp(S.Charges + n - S.MaxCharges, 0, n)
		S.MaxCharges = n
		if(S.Charges > 0) S.Using = 0
	S.ChargeRefresh = glob.MECH_THRUST_CD / 10
	S.Cooldown = S.ChargeRefresh
	S.NoGCD = 1

mob/proc/MechThrustPress(obj/Skills/S)
	var/obj/Items/Mech/R = mech
	if(!R)
		src << "You are not piloting anything."
		return 0
	if(!S) return 0
	if(!MechCanFly(R))
		MechFlyLine("thrust", "[R] has no thrusters to fire.")
		return 0
	MechThrustSync(S)
	if(MechLimp())
		MechFlyLine("thrust", "[R] is out of fuel. The thrusters will not light.")
		return 0
	if(Overheated())
		MechTooHot()
		return 0
	if(MechStalled())
		MechFlyLine("thrust", "[R]'s thrusters are stalled.")
		return 0
	if(S.Using || S.Charges <= 0) return 0
	if(MechRooted()) return 0
	if(!mech_air && GravityWellHolds())
		MechFlyLine("field", "A gravity well holds [R] to the ground.")
		return 0
	var/d = heldDir()
	if(!d) d = dir
	HeatAdd(MechThrustHeat())
	mech_thrust_at = world.time
	if(!mech_air) MechTakeoff()
	else if(mech_air == 3) MechLandCancel()
	mech_thrust_attack = MechThrustFlag("thrust_attack")
	mech_thrust_ram = MechThrustFlag("thrust_ram")
	mech_thrust_hits = (mech_thrust_attack || mech_thrust_ram) ? list() : null
	MechFaceInput(d)
	MechImpulse(d, MechThrustPx(), MechThrustTicks())
	mech_idle_since = world.time
	S.Cooldown()
	return 1

mob/proc/MechThrustEnd()
	mech_thrust_attack = 0
	mech_thrust_ram = 0
	mech_thrust_hits = null

mob/proc/MechTouching(mob/M, pad)
	if(!M || M == src || M.z != z) return 0
	if(!HurtboxOn()) return get_dist(src, M) <= 1
	ApplyHurtbox()
	M.ApplyHurtbox()
	if(hurt_w <= 0 || M.hurt_w <= 0) return get_dist(src, M) <= 1
	var/al = HurtL() - pad
	var/ab = HurtB() - pad
	var/ar = HurtL() + hurt_w + pad
	var/at = HurtB() + hurt_h + pad
	return (al < M.HurtL() + M.hurt_w) && (M.HurtL() < ar) && (ab < M.HurtB() + M.hurt_h) && (M.HurtB() < at)

mob/proc/MechThrustContacts()
	if(!(mech_thrust_attack || mech_thrust_ram) || !islist(mech_thrust_hits)) return
	for(var/mob/M in HurtRangeMobs(src, 2, -round(-glob.MECH_THRUST_REACH / 32)))
		if(M == src || !M.density || M.Dead || (M in mech_thrust_hits)) continue
		if(!MechTouching(M, glob.MECH_THRUST_REACH)) continue
		mech_thrust_hits += M
		MechThrustCrossed(M)

mob/proc/MechThrustCrossed(mob/M)
	return

mob/proc/MechStompHook()
	var/kb = MechPredatorStomp()
	var/turf/e = get_turf(src)
	if(!mech || kb <= 0 || !e) return 0
	var/r = glob.MECH_STOMP_RADIUS
	var/cx = (e.x - 1) * 32 + 16
	var/cy = (e.y - 1) * 32 + 16
	var/found = 0
	for(var/mob/M in view(r + 1, e) | BigBodiesNear(e, r + 1, TRUE))
		if(M == src || !M.density || M.KO || M.Dead) continue
		if(ZoneHitsMob(cx, cy, 32 * r, M))
			found = 1
			break
	if(!found) return 0
	var/obj/Skills/AutoHit/Mech_Stomp/S = mech.MechKept(/obj/Skills/AutoHit/Mech_Stomp)
	if(S.loc != src) AddSkill(S)
	else if(!(S in Skills)) AddSkill(S, 1)
	S.Distance = r
	S.DamageMult = glob.MECH_STOMP_DMG
	S.Knockback = kb
	. = Activate(S, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE)
	if(.) KenShockwave(src, Size = glob.MECH_STOMP_WAVE_SIZE, Blend = glob.MECH_STOMP_WAVE_BLEND, Time = glob.MECH_STOMP_WAVE_TIME)
