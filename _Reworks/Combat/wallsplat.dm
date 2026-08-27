mob/var/tmp
	splat_stagger_until = 0
	mob/kb_sender = null	
	kb_start_time = 0		//fresh KB stamp, perfect-break window anchors here

proc/ApplySplatStagger(mob/M, ds, pose = 1)
	if(!M) return
	M.splat_stagger_until = world.time + ds
	if(!pose)
		Footfall(M)
		var/list/v = FlashDirPx(M.dir)
		animate(M, pixel_x = v[1]*3, pixel_y = v[2]*3 - 2, time = 2, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
		animate(pixel_x = -v[1]*3, pixel_y = -v[2]*3 + 2, time = 3, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_RELATIVE)
		return
	M.icon_state = "KB"
	spawn(ds)
		if(M && world.time >= M.splat_stagger_until && M.icon_state == "KB" && !M.Knockbacked && !M.KO && !M.Launched)
			M.icon_state = ""

//flourish: pose quick for tension
mob/var/tmp/flourish_until = 0

mob/proc/FlourishArm()
	flourish_until = world.time + glob.FLOURISH_WINDOW_DS
	KenShockwave(src, Size = 0.2, Blend = 2, Time = 2)
