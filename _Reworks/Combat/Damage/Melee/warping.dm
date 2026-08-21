/mob/proc/QueueDashTo(mob/M, maxTiles)
	if(!M || !M.loc || M.z != z || maxTiles <= 0) return
	last_combo_warp_dist = get_dist(src, M)
	if(!PmActive())
		var/steps = maxTiles
		while(steps-- > 0 && M && M.loc && get_dist(src, M) > 1)
			step_towards(src, M)
			sleep(1)
		if(M && M.loc && M.z == z)
			dir = get_dir(src, M) || dir
		return
	var/budget = maxTiles * 32
	var/delay = glob.BASE_LOOP_DELAY + MovementSpeed()
	var/px_tick = max(2, round(1.25 * 32 * glob.PLAYER_SPEED_MULT / max(1, -round(-delay))))
	is_dashing++
	while(budget > 0 && M && M.loc && M.z == z && !KO && !Stunned && !(Stasis > 0))
		if(max(abs((M.x-x)*32 + (M.step_x-step_x)), abs((M.y-y)*32 + (M.step_y-step_y))) <= 33)
			break
		var/moved = PmDashStep(M, min(px_tick, budget))
		if(!moved)
			break
		budget -= moved
		sleep(world.tick_lag)
	is_dashing--
	if(is_dashing < 0)
		is_dashing = 0
	if(M && M.loc && M.z == z)
		dir = get_dir(src, M) || dir

/mob/proc/getWarpingStrike()
	. = 0
	if(passive_handler["Bear Spirit"] == 1)
		return 2
	if(passive_handler["Speed Force"] >= 3)
		return  passive_handler["Speed Force"] * 1.5