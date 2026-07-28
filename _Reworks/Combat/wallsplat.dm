mob/var/tmp
	splat_stagger_until = 0
	mob/kb_sender = null	
	kb_start_time = 0		//fresh KB stamp, perfect-break window anchors here

proc/ApplySplatStagger(mob/M, ds)
	if(!glob.WALL_SPLAT || !M) return
	M.splat_stagger_until = world.time + ds
	M.icon_state = "KB"
	spawn(ds)
		if(M && world.time >= M.splat_stagger_until && M.icon_state == "KB" && !M.Knockbacked && !M.KO && !M.Launched)
			M.icon_state = ""

//flourish: pose quick for tension
mob/var/tmp/flourish_until = 0

mob/proc/FlourishArm()
	if(!glob.POSE_FLOURISH) return
	flourish_until = world.time + glob.FLOURISH_WINDOW_DS
	KenShockwave(src, Size = 0.2, Blend = 2, Time = 2)
