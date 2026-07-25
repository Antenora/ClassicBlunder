//hit-stop: freeze attacker+victim clients for a few frames on a heavy connect

globalTracker
	var/tmp
		HIT_STOP = TRUE //master switch
		HIT_STOP_MIN = 5 //min quakeIntens before any freeze
		HIT_STOP_MAX_DS = 3 //freeze length in deciseconds at full weight (quake 14)
		HIT_STOP_GAP_DS = 8 //quiet time after a freeze ends before the next can start

//whoever pins client.fps owns the hold until this time - Time Skip stamps it too, every restore checks it
mob/var/tmp/_fps_hold_until = 0

proc/HitStop(mob/A, mob/V, weight, bonus_ds = 0)
	if(!glob || !glob.HIT_STOP) return
	if(weight < glob.HIT_STOP_MIN) return
	var/span = max(1, 14 - glob.HIT_STOP_MIN)
	var/t = clamp(round(1 + (weight - glob.HIT_STOP_MIN) / span * (glob.HIT_STOP_MAX_DS - 1)), 1, glob.HIT_STOP_MAX_DS)
	if(bonus_ds) //counter-hit lands heavier
		t = min(t + bonus_ds, glob.COUNTER_HIT_STOP_CAP)
	_HitStopClient(A, t)
	_HitStopClient(V, t)

proc/_HitStopClient(mob/M, ds)
	if(!M || !M.client) return
	if(M._fps_hold_until + glob.HIT_STOP_GAP_DS > world.time) return //held, or too soon after one
	M._fps_hold_until = world.time + ds
	spawn()
		if(!M || !M.client) return
		M.client.fps = 0.0001
		sleep(ds)
		if(M && M.client && world.time >= M._fps_hold_until)
			M.client.fps = M.EffectiveClientFPS()
