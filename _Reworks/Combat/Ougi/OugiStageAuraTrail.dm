/datum/ougi_scene
	var
		list/ougi_aura_trail

/datum/ougi_scene/proc/ActorMoveRunning(mob/M, t)
	var/list/r = ougi_move_runs ? ougi_move_runs[M] : null
	return r && r[6] > 0 && t - world.tick_lag < r[5] + r[6] && M.pixel_x == r[3] && M.pixel_y == r[4]

/datum/ougi_scene/OpAura(list/a)
	var/tr = ArgNum(a, "trail", -1)
	if(tr >= 0)
		var/mob/M = Who(ArgText(a, "who", "attacker"))
		if(M && (M in actors))
			if(!ougi_aura_trail) ougi_aura_trail = list()
			if(tr) ougi_aura_trail[M] = 1
			else ougi_aura_trail -= M
		if(isnull(a["phase"])) return
	..()

/datum/ougi_scene/DoOp(op, list/a)
	. = ..()
	if(op != "actor_face" && op != "actor_state") return
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	var/datum/aurafx_rig/ougi_scene/R = (M && ougi_auras) ? ougi_auras[M] : null
	if(!R) return
	if(op == "actor_face") R.pose_own_dir = 0
	else R.pose_own_state = 0

/datum/ougi_scene/OugiAurasEnd()
	..()
	ougi_aura_trail = null

/datum/aurafx_rig/ougi_scene
	var
		pose_state
		pose_own_state = 0
		pose_dir = 0
		pose_dir_set = 0
		pose_own_dir = 0

/datum/aurafx_rig/ougi_scene/MotionFast()
	var/datum/ougi_scene/S = scene
	return S && S.ougi_aura_trail && S.ougi_aura_trail[M]

/datum/aurafx_rig/ougi_scene/Motion(now)
	var/datum/ougi_scene/S = scene
	if(S)
		var/list/p = S.ActorPixelAt(M, world.time)
		move_ox = p[1]
		move_oy = p[2]
		jump_px = S.ActorMoveRunning(M, world.time) ? max(world.maxx, world.maxy) * world.icon_size : initial(jump_px)
		tail_min = MotionFast() ? world.icon_size * aurafx_tail_ticks : 0
	..()
	if(pose_own_dir && mode == AURAFX_M_FLY)
		if(M.dir != pose_dir_set) pose_own_dir = 0
		else PoseFace()

/datum/aurafx_rig/ougi_scene/proc/PoseFace()
	pose_dir_set = Facing4(travel)
	M.dir = pose_dir_set

/datum/aurafx_rig/ougi_scene/SetMode(m, now)
	var/was = mode
	..()
	if(!M) return
	var/air0 = was == AURAFX_M_FLY || was == AURAFX_M_STOP
	var/air1 = m == AURAFX_M_FLY || m == AURAFX_M_STOP
	if(m == AURAFX_M_FLY && was != AURAFX_M_FLY)
		pose_own_state = 0
		if(M.icon_state != "Flight" && M.icon && ("Flight" in icon_states(M.icon)))
			pose_state = M.icon_state
			pose_own_state = 1
			M.icon_state = "Flight"
		if(!air0 || !pose_own_dir || M.dir != pose_dir_set) pose_dir = M.dir
		pose_own_dir = 1
		PoseFace()
		return
	if(was == AURAFX_M_FLY && m != AURAFX_M_FLY)
		if(pose_own_state && M.icon_state == "Flight") M.icon_state = pose_state
		pose_own_state = 0
	if(air0 && !air1)
		if(pose_own_dir && M.dir == pose_dir_set) M.dir = pose_dir
		pose_own_dir = 0

/datum/aurafx_rig/ougi_scene/GrowTick(now)
	if(glide_gi && (mode == AURAFX_M_FLY || mode == AURAFX_M_KB || mode == AURAFX_M_STOP))
		for(var/obj/aurafx/O in list(hp, hl))
			animate(O)
			O.transform = matrix()
	..()
