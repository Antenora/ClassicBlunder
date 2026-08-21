globalTracker/var/DEPORT_CRIPPLE = 30

proc/deportStepBlocked(turf/start, turf/end)
	for(var/obj/Turfs/Edges/E in start)
		if(E.dir == get_dir(start, end))
			return TRUE
	for(var/obj/Turfs/Edges/E in end)
		if(E.dir == get_dir(end, start))
			return TRUE
	if(end.density) return TRUE
	for(var/obj/i in end)
		if(i.density && !istype(i, /obj/AutoHitter) && !istype(i, /obj/Skills/Projectile/_Projectile))
			return TRUE
	return FALSE

mob/proc/applyDeport(tileAmt, throwdir = 0)
	if(!tileAmt) return
	var/turf/deport
	if(throwdir)
		var/turf/cur = loc
		if(istype(cur))
			for(var/i = 1, i <= tileAmt, i++)
				var/turf/next = get_step(cur, throwdir)
				if(!next || deportStepBlocked(cur, next))
					break
				cur = next
			if(cur != loc)
				deport = cur
	else
		deport = randomReachableTurf(tileAmt)
	AddCrippling(glob.DEPORT_CRIPPLE)
	if(deport)
		loc = deport
		step_x = 0
		step_y = 0


mob/proc/randomReachableTurf(range = 10)
	if(!range || !loc) return
	var/turf/start = loc

	var/list/possible = list()

	var/list/open = list(start)
	var/list/visited = list(start)

	while(open.len)
		var/turf/current = open[1]
		open.Cut(1, 2)

		if(get_dist(start, current) <= range)
			possible += current

		for(var/d in CARDINAL_DIRECTIONS)
			var/turf/next = get_step(current, d)

			if(!next)
				continue

			if(next in visited)
				continue

			if(get_dist(start, next) > range)
				continue

			if(!checkValid(current, next))
				visited += next
				open += next

	if(!possible.len)
		return null

	possible -= start
	if(!possible.len)
		return start

	return pick(possible)

proc/checkValid(turf/start, turf/end)
	for(var/obj/Turfs/Edges/E in start)
		if(E.dir == get_dir(start, end))
			return TRUE

	for(var/obj/Turfs/Edges/E in end)
		if(E.dir == get_dir(end, start))
			return TRUE
	
	if(start.density) return TRUE
	if(end.density) return TRUE

	for(var/obj/i in start)
		if(i.density) return TRUE
	for(var/obj/i in end)
		if(i.density) return TRUE

	return FALSE