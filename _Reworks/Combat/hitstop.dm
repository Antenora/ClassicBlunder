//hit-stop: freeze attacker+victim clients for a few frames on a heavy connect

globalTracker
	var/tmp
		HIT_STOP = TRUE //master switch
		HIT_STOP_MIN = 5 //min quakeIntens before any freeze
		HIT_STOP_MAX_DS = 3 //freeze length in deciseconds at full weight (quake 14)
		HIT_STOP_GAP_DS = 8 //quiet time after a freeze ends before the next can start
		HIT_STOP_PIN_FPS = 5
		SLOWMO = TRUE
		SLOWMO_MAX_ZONES = 3
		KO_SLOWMO_RADIUS = 8
		KO_SLOWMO_MULT = 3
		KO_SLOWMO_DS = 13
		KO_PAN_BACK_DS = 16

//whoever pins client.fps owns the hold until this time - Time Skip stamps it too, every restore checks it
mob/var/tmp/_fps_hold_until = 0

proc/HitStop(mob/A, mob/V, weight, bonus_ds = 0)
	if(!glob || !glob.HIT_STOP) return 0
	if(weight < glob.HIT_STOP_MIN) return 0
	var/span = max(1, 14 - glob.HIT_STOP_MIN)
	var/t = clamp(round(1 + (weight - glob.HIT_STOP_MIN) / span * (glob.HIT_STOP_MAX_DS - 1)), 1, glob.HIT_STOP_MAX_DS)
	if(bonus_ds) //counter-hit lands heavier
		t = min(t + bonus_ds, glob.COUNTER_HIT_STOP_CAP)
	var/r1 = _HitStopClient(A, t)
	var/r2 = _HitStopClient(V, t)
	return max(r1, r2)

proc/_HitStopClient(mob/M, ds)
	if(!M || !M.client) return 0
	if(M._fps_hold_until + glob.HIT_STOP_GAP_DS > world.time) return 0 //held, or too soon after one
	M._fps_hold_until = world.time + ds
	spawn()
		if(!M || !M.client) return
		M.client.fps = glob.HIT_STOP_PIN_FPS
		sleep(ds)
		if(M && M.client && world.time >= M._fps_hold_until)
			M.client.fps = M.EffectiveClientFPS()
	return ds

var/list/_slowmo_zones = list()
var/_slowmo_n = 0

atom/movable/var/tmp/_smo_acc = 0

/datum/slowmo_zone
	var/tmp
		atom/center
		cx = 0
		cy = 0
		cz = 0
		radius = 7
		mult = 3
		until = 0
		mob/exempt

/datum/slowmo_zone/proc/Pos()
	if(center && center.loc)
		var/turf/T = get_turf(center)
		if(T)
			cx = T.x
			cy = T.y
			cz = T.z

proc/SlowMoCovered(turf/T)
	if(!_slowmo_n || !T) return null
	for(var/datum/slowmo_zone/S in _slowmo_zones)
		if(world.time > S.until || !S.center || !S.center.loc) continue
		S.Pos()
		if(T.z != S.cz) continue
		if(max(abs(T.x - S.cx), abs(T.y - S.cy)) > S.radius) continue
		return S
	return null

proc/SlowMoZone(atom/center, radius = 7, mult = 3, ds = 12, mob/exempt)
	if(!center || !glob || !glob.SLOWMO) return null
	if(_slowmo_zones.len >= glob.SLOWMO_MAX_ZONES)
		SlowMoPrune()
		if(_slowmo_zones.len >= glob.SLOWMO_MAX_ZONES) return null
	var/datum/slowmo_zone/S = new
	S.center = center
	S.radius = radius
	S.mult = max(mult, 1)
	S.until = world.time + ds
	S.exempt = exempt
	S.Pos()
	_slowmo_zones += S
	_slowmo_n = _slowmo_zones.len
	spawn(ds + 1)
		SlowMoPrune()
	return S

proc/SlowMoPrune()
	for(var/datum/slowmo_zone/S in _slowmo_zones)
		if(world.time > S.until || !S.center || !S.center.loc)
			_slowmo_zones -= S
	_slowmo_n = _slowmo_zones.len

proc/SlowMoDelayMult(atom/A)
	if(!_slowmo_n || !A) return 1
	var/turf/T = get_turf(A)
	if(!T) return 1
	var/mob/actor = null
	if(ismob(A))
		actor = A
	else if(istype(A, /obj/Skills/Projectile))
		var/obj/Skills/Projectile/PP = A
		actor = PP.Owner
	var/best = 1
	var/stale = 0
	for(var/datum/slowmo_zone/S in _slowmo_zones)
		if(world.time > S.until || !S.center || !S.center.loc)
			stale = 1
			continue
		if(actor && S.exempt == actor)
			continue
		S.Pos()
		if(T.z != S.cz) continue
		if(max(abs(T.x - S.cx), abs(T.y - S.cy)) > S.radius) continue
		best = max(best, S.mult)
	if(stale)
		SlowMoPrune()
	return best

proc/SlowMoTickGate(atom/movable/M)
	if(!M) return 1
	var/smm = SlowMoDelayMult(M)
	if(smm <= 1)
		M._smo_acc = 0
		return 1
	M._smo_acc += 1 / smm
	if(M._smo_acc >= 1)
		M._smo_acc -= 1
		return 1
	return 0
