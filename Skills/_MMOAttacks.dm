obj/AttackMarker
	icon = 'MMOAttackMarker.dmi'
	icon_state = "WarningBox"
	layer = EFFECTS_LAYER
	mouse_opacity = 0

	var/mob/owner
	var/delay = 0
	var/projectile_type = /obj/Skills/Projectile/ChaosSaberWave
	var/fire_dir = null
	var/x_spawn_offset = 0
	var/y_spawn_offset = 0

	New(loc, mob/O, projectile_path = null, custom_delay = 0, custom_dir = null, custom_x_offset = 0, custom_y_offset = 0)
		..()

		owner = O

		if(ispath(projectile_path, /obj/Skills/Projectile))
			projectile_type = projectile_path

		delay = custom_delay
		fire_dir = custom_dir

		var/base_offset = 0

		if(ispath(projectile_path, /obj/Skills/Projectile))
			var/obj/Skills/Projectile/P = projectile_path
			base_offset = max(abs(initial(P.XSpawnOffset)), abs(initial(P.YSpawnOffset)))

		if(fire_dir && base_offset)
			var/list/offsets = O.GetMMOProjectileOffset(fire_dir, base_offset)
			x_spawn_offset = offsets["x"]
			y_spawn_offset = offsets["y"]
		else
			x_spawn_offset = custom_x_offset
			y_spawn_offset = custom_y_offset

		spawn(delay)
			FireMMOAttack()

	proc/FireMMOAttack()
		if(!src || !loc)
			return

		if(!owner)
			del(src)
			return

		var/path = projectile_type

		if(!ispath(path, /obj/Skills/Projectile))
			del(src)
			return

		var/obj/Skills/Projectile/p = new path

		p.adjust(owner)
		p.SpawnPosition = src

		if(fire_dir)
			p.DirOverride = fire_dir

		p.XSpawnOffset = x_spawn_offset
		p.YSpawnOffset = y_spawn_offset

		var/mob/O = owner
		var/obj/AttackMarker/M = src

		spawn(1)
			if(O && M && M.loc && p)
				O.UseProjectile(p)

			if(M)
				del(M)



mob/proc/GetMMOProjectileOffset(direction, offset_amount = 4)
	var/list/offsets = list("x" = 0, "y" = 0)

	switch(direction)
		if(EAST)
			offsets["x"] = -offset_amount
			offsets["y"] = 0
		if(WEST)
			offsets["x"] = offset_amount
			offsets["y"] = 0
		if(NORTH)
			offsets["x"] = 0
			offsets["y"] = -offset_amount
		if(SOUTH)
			offsets["x"] = 0
			offsets["y"] = offset_amount

	return offsets


mob/proc/SpawnMMOMarkers(projectile_path, Target, list/points, base_delay = 20, delay_step = 1, offset_amount = 4)
	if(!Target)
		return FALSE

	if(!points || !points.len)
		return FALSE

	var/turf/Center = get_turf(Target)
	if(!Center)
		return FALSE

	var/count = 0

	for(var/entry in points)
		if(!islist(entry))
			continue

		var/dx = entry["x"]
		var/dy = entry["y"]
		var/fire_dir = entry["dir"]

		var/turf/T = locate(Center.x + dx, Center.y + dy, Center.z)
		if(!T)
			continue

		var/marker_delay = base_delay + round(count / 2)

		var/list/offsets = GetMMOProjectileOffset(fire_dir, offset_amount)

		new /obj/AttackMarker(
			T,
			src,
			projectile_path,
			marker_delay,
			fire_dir,
			offsets["x"],
			offsets["y"]
		)

		count++

	return TRUE


// Patterns

mob/proc/SpawnMMOSingleMarker(projectile_path, Target, base_delay = 20)
	var/list/points = list()

	points += list(list(
		"x" = 0,
		"y" = 0,
		"dir" = null
	))

	return SpawnMMOMarkers(projectile_path, Target, points, base_delay)

mob/proc/SpawnMMOCheckerboardMarkers(projectile_path, Target, marker_range = 3, base_delay = 20, delay_step = 0)
	var/list/points = list()

	for(var/dx = -marker_range to marker_range)
		for(var/dy = -marker_range to marker_range)
			if((abs(dx) + abs(dy)) % 2 != 0)
				continue

			points += list(list(
				"x" = dx,
				"y" = dy,
				"dir" = null
			))

	return SpawnMMOMarkers(projectile_path, Target, points, base_delay, delay_step)

mob/proc/SpawnMMOCrossMarkers(projectile_path, Target, marker_range = 3, base_delay = 20, delay_step = 0.25, second_line_delay = 10)
	if(!Target)
		return FALSE

	var/turf/Center = get_turf(Target)
	if(!Center)
		return FALSE

	var/list/horizontal_points = list()
	var/list/vertical_points = list()

	for(var/dx = -marker_range to marker_range)
		var/fire_dir

		if(dx > 0)
			fire_dir = NORTH
		else
			fire_dir = SOUTH

		horizontal_points += list(list(
			"x" = dx,
			"y" = 0,
			"dir" = fire_dir
		))

	for(var/dy = -marker_range to marker_range)
		var/fire_dir

		if(dy > 0)
			fire_dir = EAST
		else
			fire_dir = WEST

		vertical_points += list(list(
			"x" = 0,
			"y" = dy,
			"dir" = fire_dir
		))

	SpawnMMOMarkers(projectile_path, Target, horizontal_points, base_delay, delay_step)

	spawn(second_line_delay)
		SpawnMMOMarkers(projectile_path, Target, vertical_points, base_delay, delay_step)

	return TRUE

mob/proc/SpawnMMOAlternatingHorizontalMarkers(projectile_path, Target, marker_range = 6, rounds = 4, base_delay = 20, round_delay = 10, delay_step = 0, offset_amount = 4)
	if(!Target)
		return FALSE

	var/turf/Center = get_turf(Target)
	if(!Center)
		return FALSE

	if(rounds <= 0)
		return FALSE

	for(var/round_index = 0 to rounds - 1)
		var/list/points = list()

		for(var/dx = -marker_range to marker_range)
			if((abs(dx) + round_index) % 2 != 0)
				continue

			points += list(list(
				"x" = dx,
				"y" = 0,
				"dir" = SOUTH
			))

		var/this_round_delay = base_delay + (round_index * round_delay)

		SpawnMMOMarkers(
			projectile_path,
			Target,
			points,
			this_round_delay,
			delay_step,
			offset_amount
		)

	return TRUE

obj/Skills
	Projectile
		Swords_of_Revealing_Light
			NewCost = TIER_3_COST
			NewCopyable = 4
			Copyable=2
			DamageMult=35
			Blasts=4
			AccMult=10
			Cooldown=45
			Crippling=10
			Piercing=1
			Striking=1
			IconSize=1
			Dodgeable=0
			ManaCost=20
			adjust(mob/p)
				DamageMult = initial(DamageMult)
			verb/Swords_of_Revealing_Light()
				set category="Skills"
				set hidden=0
				if(Using || cooldown_remaining)
					return FALSE

				var/hyper_mana_cost = ManaCost
				if(usr.ManaAmount < hyper_mana_cost)
					usr << "You need [hyper_mana_cost] mana."
					return FALSE
				if(!usr.Target || usr.Target == usr)
					usr << "You need a valid target."
					return FALSE
				adjust(usr)
				usr.ManaAmount -= hyper_mana_cost
				if(usr.ManaAmount < 0)
					usr.ManaAmount = 0
				src.Cooldown(1, null, usr)
				usr.SpawnMMOAlternatingHorizontalMarkers(/obj/Skills/Projectile/SwordsOfRevealingLightProjectile, usr.Target, 16,4,15,10)
				return TRUE
		SwordsOfRevealingLightProjectile
			YSpawnOffset=10
			DamageMult=35
			AccMult=10
			Distance=20
			Cooldown=0
			IconSize=1
			Dodgeable=0
			DirOverride=2
			Crippling=10
			ignoreBetterAim = TRUE // my fucking god tigers what did you do
			Piercing=1
			Striking=1
			ManaCost=0
			Cooldown=0
			Trail='Trail - Plasma.dmi'
			TrailSize=1
			IconLock='SwordOfRevealingLight.dmi'
			adjust(mob/p)
				DamageMult = initial(DamageMult) * glob.MMO_PROJ_DAMAGE_MULT
			verb/Sword_of_Revealing_Light_Fire()
				set category="Skills"
				set hidden=1
				return TRUE