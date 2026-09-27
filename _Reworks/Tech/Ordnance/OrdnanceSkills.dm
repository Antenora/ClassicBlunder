var/list/ord_live_traps = list()

mob/proc/OrdnanceSpares(mob/M)
	if(!M) return 1
	if(M == src) return 1
	if(M.ckey && inParty(M.ckey)) return 1
	if(M in ai_followers) return 1
	if(src in M.ai_followers) return 1
	return 0

proc/OrdBoxOverlap(atom/A, atom/B)
	if(!A || !B || A.z != B.z) return 0
	var/ax = A.LowerX()
	var/ay = A.LowerY()
	var/bx = B.LowerX()
	var/by = B.LowerY()
	return ax < bx + B.Width() && bx < ax + A.Width() && ay < by + B.Height() && by < ay + A.Height()

proc/OrdCenterX(atom/movable/A)
	. = A.LowerX() + A.Width() / 2
	if(istype(A, /obj/Skills/Projectile/_Projectile))
		var/obj/Skills/Projectile/_Projectile/P = A
		. += P.vhb_ax

proc/OrdCenterY(atom/movable/A)
	. = A.LowerY() + A.Height() / 2
	if(istype(A, /obj/Skills/Projectile/_Projectile))
		var/obj/Skills/Projectile/_Projectile/P = A
		. += P.vhb_ay

proc/OrdVictims(mob/owner, atom/movable/center, cx, cy, radius)
	. = list()
	var/r = 32 * radius
	for(var/mob/M in view(radius + 1, center) | BigBodiesNear(center, radius + 1, TRUE))
		if(M.Dead || M.KO) continue
		if(owner && owner.OrdnanceSpares(M)) continue
		if(!CircleHitsBody(cx, cy, r, M)) continue
		. += M

proc/OrdEMPBurst(mob/owner, atom/movable/center, cx, cy, radius, strength)
	var/r = 32 * radius
	for(var/atom/movable/A in range(radius + 1, center) | BigBodiesNear(center, radius + 1))
		if(A == center) continue
		if(ismob(A))
			var/mob/M = A
			if(M.Dead || M.KO) continue
			if(owner && owner.OrdnanceSpares(M)) continue
			if(!CircleHitsBody(cx, cy, r, M)) continue
		else if(!CircleHitsBounds(cx, cy, r, A))
			continue
		A.EMPHit(strength)

proc/OrdSpreadClouds(path, mob/owner, turf/T)
	if(!T) return
	var/list/shared = list()
	for(var/turf/t in range(1, T))
		if(t.density) continue
		var/obj/Traps/C = new path(t, owner)
		C.shared = shared

proc/OrdAreaLine(atom/at, msg)
	if(!at || !msg) return
	for(var/mob/Players/E in hearers(10, at))
		if(!E.client) continue
		if(E.client.getPref("CombatMessagesInIC"))
			E.client.outputToChat("[msg]", ALL_OUTPUT)
		else
			E.client.outputToChat("[msg]", ALL_NOT_IC_OUTPUT)

mob/proc/OrdnanceSkill(path)
	var/obj/Skills/Projectile/Ordnance/S = locate(path) in Projectiles
	if(!S)
		AddSkill(new path)
		S = locate(path) in Projectiles
	return S

mob/proc/OrdnanceAimAngle(range)
	if(ismob(Target) && Target != src && Target.z == z && get_dist(src, Target) <= range)
		return GunTargetAngle(Target)
	return GunDirAngle(dir)

mob/proc/OrdnanceThrow(path)
	var/obj/Skills/Projectile/Ordnance/S = OrdnanceSkill(path)
	if(!S) return 0
	var/ang = OrdnanceAimAngle(S.Distance)
	S.FlightAngle = ang
	S.DirOverride = GunAngleDir(ang)
	S.Using = 0
	. = UseProjectile(S, TRUE)
	S.FlightAngle = null
	S.DirOverride = 0
	S.Using = 0

mob/proc/OrdnanceBurst(path, turf/T, sx = 0, sy = 0)
	if(!T) return 0
	var/obj/Skills/Projectile/Ordnance/S = OrdnanceSkill(path)
	if(!S) return 0
	var/was_static = S.Static
	var/was_dist = S.Distance
	S.Static = 1
	S.Distance = 0
	S.SpawnPosition = T
	var/obj/Skills/Projectile/_Projectile/P = Blast(S, T, 0)
	S.Static = was_static
	S.Distance = was_dist
	S.SpawnPosition = null
	if(P && P.loc == T)
		P.step_x = sx
		P.step_y = sy
	return P ? 1 : 0

mob/OnSpellImpact(obj/Skills/S, obj/Skills/Projectile/_Projectile/P)
	..()
	if(!istype(S, /obj/Skills/Projectile/Ordnance) || !P || !isturf(P.loc)) return
	var/obj/Skills/Projectile/Ordnance/O = S
	O.Detonate(src, P, OrdCenterX(P), OrdCenterY(P))

mob/Players/Logout()
	OrdnanceClearOwned()
	..()

mob/proc/OrdnanceClearOwned()
	for(var/obj/Traps/T in ord_live_traps.Copy())
		if(T.remove_on_logout && T.owner_ref == src) T.TrapGone()

/obj/Skills/Projectile/Ordnance
	name = "Ordnance"
	NoGCD = 1
	AttackReplace = 1
	Cooldown = 0
	EnergyCost = 0
	ManaCost = 0
	Distance = ORD_THROW_RANGE
	Speed = ORD_THROW_SPEED
	DamageMult = 0
	AccMult = 1
	UsesOff = 1
	StrScaling = 0
	ForScaling = 0
	EndEffectiveness = 1
	Radius = 1
	Blasts = 1
	Variation = 0
	Knockback = 0
	var/throw_icon = 'device.dmi'
	var/throw_state = ""

	New()
		..()
		IconLock = icon(throw_icon, throw_state)

	proc/Detonate(mob/owner, obj/Skills/Projectile/_Projectile/P, cx, cy)
		return

	Frag_Grenade
		name = "Frag Grenade"
		throw_state = "timer"
		Explode = 1

		Detonate(mob/owner, obj/Skills/Projectile/_Projectile/P, cx, cy)
			var/list/hit = OrdVictims(owner, P, cx, cy, ORD_FRAG_RADIUS)
			if(!hit.len) return
			P.DamageMult = ORD_FRAG_DAMAGE
			P.Deflectable = -1
			P.Dodgeable = -1
			P.Knockback = 0
			for(var/mob/M in hit)
				if(!P.Owner) break
				P.Hit(M)

	Smoke_Grenade
		name = "Smoke Grenade"
		throw_state = "atmos"

		Detonate(mob/owner, obj/Skills/Projectile/_Projectile/P, cx, cy)
			OrdSpreadClouds(/obj/Traps/Smoke_Cloud, owner, P.loc)

	Flash_Grenade
		name = "Flash Grenade"
		throw_state = "flash2"

		Detonate(mob/owner, obj/Skills/Projectile/_Projectile/P, cx, cy)
			for(var/mob/M in OrdVictims(owner, P, cx, cy, ORD_FLASH_RADIUS))
				M.AddConfusing(ORD_FLASH_CONFUSE, owner)
				M << "<font color='#ff6b6b'>A blinding flash leaves you reeling!</font>"

	Gas_Grenade
		name = "Gas Grenade"
		throw_state = "hydro"

		Detonate(mob/owner, obj/Skills/Projectile/_Projectile/P, cx, cy)
			OrdSpreadClouds(/obj/Traps/Gas_Cloud, owner, P.loc)

	EMP_Grenade
		name = "EMP Grenade"
		throw_state = "emp"
		Explode = 1

		Detonate(mob/owner, obj/Skills/Projectile/_Projectile/P, cx, cy)
			OrdEMPBurst(owner, P, cx, cy, ORD_EMP_RADIUS, ORD_EMP_STRENGTH)

	Flare
		name = "Flare"
		Distance = ORD_FLARE_RANGE
		throw_state = "igniter"

		Detonate(mob/owner, obj/Skills/Projectile/_Projectile/P, cx, cy)
			var/turf/T = P.loc
			if(T.density) T = get_step(T, turn(P.dir, 180))
			if(!T || T.density) return
			new /obj/Traps/Flare(T, owner)

	Bola
		name = "Bola"
		Distance = ORD_BOLA_RANGE
		Radius = 0
		Crippling = ORD_BOLA_CRIPPLE
		throw_state = "bracelet"

/mob/proc/MechHazardImmune()
	return 0

/obj/Traps
	name = "Trap"
	icon = 'device.dmi'
	icon_state = ""
	density = 0
	Savable = 0
	Grabbable = 0
	Attackable = 0
	Destructable = 0
	var/lifetime = 0
	var/remove_on_logout = 0
	var/grounded_only = 0
	var/cloud_tick = 0
	var/trap_box = 16
	var/tmp/mob/owner_ref
	var/tmp/owner_key
	var/tmp/armed = 1
	var/tmp/gone = 0
	var/tmp/list/shared

	New(loc, mob/owner)
		..()
		owner_ref = owner
		owner_key = owner ? owner.ckey : null
		TrapBounds()
		ord_live_traps += src
		if(lifetime > 0)
			spawn(lifetime)
				if(src && !gone) TrapExpire()
		TrapStart()
		if(cloud_tick > 0) spawn() CloudLoop()

	Crossed(atom/movable/O)
		..()
		if(gone || !armed || !ismob(O)) return
		var/mob/M = O
		if(!TrapEligible(M)) return
		TrapTrigger(M)

	proc/TrapBounds()
		if(trap_box <= 0 || trap_box >= 32) return
		bound_x = round((32 - trap_box) / 2)
		bound_y = bound_x
		bound_width = trap_box
		bound_height = trap_box

	proc/TrapSpares(mob/M)
		if(!M) return 1
		if(owner_ref && owner_ref.OrdnanceSpares(M)) return 1
		if(owner_key && M.ckey == owner_key) return 1
		return 0

	proc/TrapEligible(mob/M)
		if(!M || M.Dead || M.KO) return 0
		if(M.MechHazardImmune()) return 0
		if(TrapSpares(M)) return 0
		if(grounded_only && (M.Flying || M.Launched || M.Airborne)) return 0
		return 1

	proc/TrapStart()
		return

	proc/TrapTrigger(mob/M)
		return

	proc/TrapExpire()
		TrapGone()

	proc/TrapGone()
		if(gone) return
		gone = 1
		armed = 0
		ord_live_traps -= src
		owner_ref = null
		shared = null
		loc = null

	proc/CloudLoop()
		while(!gone && loc)
			for(var/mob/M in range(1, src))
				if(M.Dead) continue
				if(!OrdBoxOverlap(src, M)) continue
				CloudTouch(M)
			sleep(cloud_tick)

	proc/CloudTouch(mob/M)
		return

/obj/Traps/Smoke_Cloud
	name = "Smoke"
	icon = 'Icons/Effects/Smoke.dmi'
	mouse_opacity = 0
	layer = MOB_LAYER + 0.5
	armed = 0
	trap_box = 32
	lifetime = ORD_CLOUD_LIFE
	cloud_tick = ORD_SMOKE_TICK

	CloudTouch(mob/M)
		M.in_smoke = max(M.in_smoke, world.time + ORD_SMOKE_HOLD)

/obj/Traps/Gas_Cloud
	name = "Gas"
	icon = 'PoisonGas.dmi'
	pixel_x = -16
	pixel_y = -16
	mouse_opacity = 0
	layer = MOB_LAYER + 0.5
	armed = 0
	trap_box = 32
	lifetime = ORD_CLOUD_LIFE
	cloud_tick = ORD_GAS_TICK

	CloudTouch(mob/M)
		if(M.KO || TrapSpares(M)) return
		if(M.HasVenomImmune()) return
		if(shared)
			if(shared[M] > world.time) return
			shared[M] = world.time + cloud_tick - 1
		M.AddPoison(ORD_GAS_POISON, owner_ref)

/obj/Traps/Caltrops
	name = "Caltrops"
	icon_state = "pinup"
	grounded_only = 1
	remove_on_logout = 1
	lifetime = ORD_CALTROP_LIFE
	var/tmp/list/stung

	TrapTrigger(mob/M)
		if(!stung) stung = list()
		if(stung[M] > world.time) return
		stung[M] = world.time + ORD_CALTROP_REARM
		M.AddCrippling(ORD_CALTROP_CRIPPLE, owner_ref)
		if(owner_ref) owner_ref.DoDamage(M, ORD_CALTROP_HIT)
		M << "<font color='#ff6b6b'>You step on caltrops!</font>"

/obj/Traps/Mine
	name = "Mine"
	grounded_only = 1
	remove_on_logout = 1
	armed = 0
	lifetime = ORD_MINE_LIFE
	var/burst

	TrapStart()
		spawn(ORD_MINE_ARM) MineArm()

	proc/MineArm()
		if(gone || !loc) return
		armed = 1
		for(var/mob/M in range(1, src))
			if(!OrdBoxOverlap(src, M)) continue
			if(!TrapEligible(M)) continue
			TrapTrigger(M)
			return

	TrapTrigger(mob/M)
		if(gone || !armed) return
		armed = 0
		var/turf/T = loc
		var/sx = step_x
		var/sy = step_y
		var/mob/O = owner_ref
		TrapGone()
		if(O && T) O.OrdnanceBurst(burst, T, sx, sy)

/obj/Traps/Mine/Frag_Mine
	name = "Frag Mine"
	icon_state = "timer0"
	burst = /obj/Skills/Projectile/Ordnance/Frag_Grenade

/obj/Traps/Mine/EMP_Mine
	name = "EMP Mine"
	icon_state = "empar"
	burst = /obj/Skills/Projectile/Ordnance/EMP_Grenade

/obj/Traps/Flare
	name = "Flare"
	icon_state = "igniter"
	armed = 0
	lifetime = ORD_FLARE_LIFE
	var/flare_radius = 3
	var/flare_color = "#ff5a3c"
	var/flare_alpha = 110
	var/flare_flicker = 0

	TrapStart()
		spawn(1)
			if(!gone && isturf(loc)) LightPropAttach(src, flare_radius, flare_color, flare_alpha, flare_flicker)
		spawn() FlareLoop()

	proc/FlareLoop()
		while(!gone && loc)
			if(hascall(src, "RevealCloaked")) call(src, "RevealCloaked")(ORD_FLARE_REVEAL)
			sleep(ORD_FLARE_PULSE)

	TrapGone()
		LightPropDetach(src)
		..()

/obj/Traps/Breaching_Charge
	name = "Breaching Charge"
	icon_state = "electropack1"
	layer = OBJ_LAYER + 0.1
	armed = 0
	var/tmp/obj/door

	TrapStart()
		spawn(ORD_BREACH_TIME) BreachFire()

	proc/BreachFire()
		if(gone) return
		var/obj/D = door
		var/turf/T = loc
		TrapGone()
		if(!D || !D.loc || !T) return
		Bang(T, Size = 1, Offset = 0)
		OrdBreachDoor(D)
		OrdAreaLine(T, "<font color='#ffb347'>The breaching charge blows [D] open!</font>")
