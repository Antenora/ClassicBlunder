/mob/KiStampPassives(obj/Skills/Projectile/S)
	..()
	if(!S)
		return
	S.ki_blasts = 0
	S.ki_shots = 0
	S.ki_stamp = null
	if(!passive_handler || S.Area == "Beam" || !IsKiSkill(S))
		return
	if(S.Buster && !S.Charging)
		return
	var/dmg = 1
	var/spread = 0
	var/range = 0
	var/speed = 1
	var/explode = 0
	var/nofalloff = 0
	var/v = passive_handler.Get("Volley")
	if(v >= 1 && !S.Continuous)
		S.ki_blasts = round(v)
		dmg *= KIP_VOLLEY_DMG
	v = passive_handler.Get("Scatter")
	if(v > 0 && S.Blasts + S.ki_blasts > 1)
		spread = KIP_SCATTER_ARC * v
	v = passive_handler.Get("Hail")
	if(v >= 1 && !S.Continuous)
		S.ki_shots = max(1, S.MultiShot) + round(v)
	else if(!S.MultiShot && S.MultiShots)
		S.MultiShots = 0
	v = passive_handler.Get("Ki Range")
	if(v > 0)
		range = KIP_RANGE_TILES * v
	v = passive_handler.Get("Charged Shot")
	if(v > 0)
		if(world.time - last_ki_fire >= KIP_CHARGED_IDLE)
			dmg *= 1 + KIP_CHARGED_DMG * v
			speed = KIP_CHARGED_SPEED
		last_ki_fire = world.time
	v = passive_handler.Get("Blast Radius")
	if(v > 0 && S.Explode)
		explode = v
	if(passive_handler.Get("Long Shot") > 0)
		nofalloff = 1
	if(dmg != 1 || spread || range || speed != 1 || explode || nofalloff)
		S.ki_stamp = list("dmg" = dmg, "spread" = spread, "range" = range, "speed" = speed, "explode" = explode, "nofalloff" = nofalloff)

/mob/KiStampShot(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/Z)
	..()
	var/list/st = Z ? Z.ki_stamp : null
	if(!P || !st)
		return
	if(st["dmg"] != 1)
		P.DamageMult *= st["dmg"]
	if(st["spread"])
		P.SpreadArc += st["spread"]
	if(st["range"])
		P.DistanceMax += st["range"]
		P.Distance += st["range"]
	if(st["speed"] != 1)
		P.Speed /= st["speed"]
	if(st["explode"] && P.Explode)
		P.Explode += st["explode"]
		if(P.ExplodeRadiusPx)
			P.ExplodeRadiusPx += KIP_BLASTRADIUS_PX * st["explode"]
	if(st["nofalloff"])
		P.DamageFalloff = 0

/mob/KiHitMult(mob/victim, obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(!victim || !P || !passive_handler)
		return
	var/v = passive_handler.Get("Point Blank")
	if(v > 0 && victim.z == z && get_dist(src, victim) <= KIP_POINTBLANK_RANGE)
		. *= 1 + KIP_POINTBLANK_DMG * v
	v = passive_handler.Get("Setup")
	if(v > 0 && victim.setup_mark_by == src && victim.setup_mark_until > world.time)
		. *= 1 + KIP_SETUP_DMG * v
		victim.setup_mark_by = null
		victim.setup_mark_until = 0
		P.ki_setup_hit = victim
	v = passive_handler.Get("Long Shot")
	if(v > 0)
		var/tiles = P.DistanceMax - max(P.Distance, 0)
		if(tiles > KIP_LONGSHOT_TILES)
			. *= 1 + KIP_LONGSHOT_DMG * v * (tiles - KIP_LONGSHOT_TILES)

/mob/KiOnHit(mob/victim, obj/Skills/Projectile/_Projectile/P, hit = 0)
	..()
	if(!victim || !P || !passive_handler)
		return
	if(P.ki_setup_hit == victim)
		P.ki_setup_hit = null
		setup_gun_mark = world.time + KIP_SETUP_TIME
	var/v
	if(P.Explode)
		KiExplosionHit(victim, P, hit)
	else
		v = passive_handler.Get("Shockwave")
		if(v > 0 && !victim.KO && !victim.Knockbacked)
			Knockback(v >= 2 ? KIP_SHOCKWAVE_KB2 : KIP_SHOCKWAVE_KB, victim, P.dir || get_dir(src, victim), Ki = 1)
	v = passive_handler.Get("Saturation")
	if(v > 0 && victim)
		KiSaturate(victim, v)

/mob/proc/KiExplosionHit(mob/victim, obj/Skills/Projectile/_Projectile/P, hit = 0)
	if(!victim || !passive_handler)
		return
	var/v = passive_handler.Get("Aftershock")
	if(v > 0 && hit > 0)
		KiAftershock(get_turf(victim), hit * KIP_AFTERSHOCK_PCT * v)
	v = passive_handler.Get("Concussive")
	if(v > 0 && !victim.Stunned && !victim.KO)
		Stun(victim, v)

/mob/proc/KiSaturate(mob/victim, v)
	if(victim.ki_sat_by != src || victim.ki_sat_until <= world.time)
		victim.ki_sat_by = src
		victim.ki_sat_hits = 0
		victim.ki_sat_until = world.time + KIP_SAT_WINDOW
	victim.ki_sat_hits++
	if(victim.ki_sat_hits < KIP_SAT_HITS)
		return
	victim.ki_sat_by = null
	victim.ki_sat_hits = 0
	victim.ki_sat_until = 0
	if(victim.KO)
		return
	if(v >= 2)
		Stun(victim, KIP_SAT_STUN)
	else
		spawn()
			LaunchEffect(src, victim, KIP_SAT_LAUNCH)

/mob/proc/KiAftershock(turf/T, dmg)
	if(!isturf(T) || T.density || dmg <= 0)
		return
	for(var/obj/leftOver/KiAftershock/A in T)
		if(A.owner == src && !A.expired)
			A.lifetime = KIP_AFTERSHOCK_TIME
			A.hit = max(A.hit, dmg)
			return
	if(ki_aftershock_count >= KIP_AFTERSHOCK_CAP)
		return
	new /obj/leftOver/KiAftershock(T, src, dmg)

/mob/proc/KiAftershockPulse(mob/m, dmg)
	if(!m || m == src || m.KO || m.Dead || m.Stasis || dmg <= 0)
		return
	if(inParty(m.ckey))
		return
	if(ai_followers && (m in ai_followers))
		return
	DoDamage(m, dmg)

/obj/leftOver/KiAftershock
	icon = 'Crater.dmi'
	layer = OBJ_LAYER + 0.5
	pixel_x = -32
	pixel_y = -32
	alpha = 0
	density = 0
	Savable = 0
	gfx_transient_visual = 1
	var/art_scale = 0.34
	var/art_alpha = 200
	var/art_fade = 3
	var/hit = 0
	var/next_pulse = 0
	var/expired = 0
	New(turf/T, mob/p, dmg)
		if(!isturf(T) || !p)
			loc = null
			return
		loc = T
		lifetime = KIP_AFTERSHOCK_TIME
		hit = dmg
		next_pulse = world.time + KIP_AFTERSHOCK_FIRST
		init(p)
		p.ki_aftershock_count++
		transform = matrix() * art_scale
		animate(src, alpha = art_alpha, time = art_fade)
		..()
	on_tick()
		if(expired || !owner || world.time < next_pulse)
			return
		next_pulse = world.time + KIP_AFTERSHOCK_PULSE
		if(owner.PureRPMode)
			return
		for(var/mob/m in loc)
			owner.KiAftershockPulse(m, hit)
	Update()
		lifetime -= world.tick_lag
		if(lifetime <= 0)
			KiExpire()
		else
			on_tick()
	Cross(atom/movable/O)
		if(expired)
			return 1
		return ..()
	on_death()
		KiExpire()
	proc/KiExpire()
		if(expired)
			return
		expired = 1
		ticking_generic -= src
		if(owner)
			owner.ki_aftershock_count = max(0, owner.ki_aftershock_count - 1)
		owner = null
		tick_on = null
		animate(src, alpha = 0, time = art_fade)
		spawn(art_fade)
			loc = null

/passiveInfo/GunPointBlank/renderDesc()
	lines += "Ki projectile hits on a target within [KIP_POINTBLANK_RANGE] tile of you deal [KIP_POINTBLANK_DMG * 100]% more damage per point."
	..()

/passiveInfo/GunSetup/renderDesc()
	lines += "A ki projectile hit on the marked target works the same way."
	..()
