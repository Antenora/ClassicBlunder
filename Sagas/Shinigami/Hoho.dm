// TIER 1

/obj/Skills/Hoho/Shunpo
	name = "Shunpo"
	MaxCharges = 5
	Charges = 5
	ChargeRefresh = 10
	ManaCost = 0
	var/tmp/ShunpoToggle = FALSE

	verb/Shunpo()
		set name = "Shunpo"
		set category = "Skills"
		var/mob/User = usr
		src.ShunpoToggle = !src.ShunpoToggle
		if(src.ShunpoToggle)
			User << "Shunpo active. ([src.Charges]/[src.MaxCharges] charges)"
		else
			User << "Shunpo deactivated."

/obj/Skills/Hoho/Shunpo_Upgrade1
	name = "Shunpo Mastery I"

/obj/Skills/Hoho/Shunpo_Upgrade2
	name = "Shunpo Mastery II"

/obj/Skills/Hoho/Shunpo_Upgrade3
	name = "Shunpo Mastery III"

/obj/Skills/Hoho/Shunpo_Upgrade4
	name = "Shunpo Mastery IV"

// TIER 2

/obj/Skills/AutoHit/Hoho/Senka
	name = "Senka"
	NeedsSword = 1
	Area = "Target"
	GuardBreak = 1
	StrOffense = 1
	MortalBlow = 0.25
	DamageMult = 10
	Distance = 10
	PassThrough = 1
	Cooldown = 30
	ManaCost = 5
	ActiveMessage = "vanishes and reappears with a decisive strike Senka!"

	verb/Senka()
		set name = "Senka"
		set category = "Skills"
		usr.Activate(src)

// TIER 3

/obj/Skills/Hoho/Utsusemi
	name = "Utsusemi"
	ManaCost = 10
	Cooldown = 60

	verb/Utsusemi()
		set name = "Utsusemi"
		set category = "Skills"
		var/mob/User = usr
		if(cooldown_remaining) return
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, User)
		if(src.ManaCost) User.LoseMana(src.ManaCost)

		// Create decoy clone at user's current position
		var/mob/Player/HohoClone/c = new(User.loc)
		c.initClone(User)
		c.fade_owner = User

		// Redirect all players currently targeting the user to the clone
		for(var/mob/Players/P in players)
			if(P.Target == User)
				P.Target = c

		// Vanish instantly before slipping away
		User.alpha = 0

		var/back_dir = turn(User.dir, 180)
		var/turf/dest = User.loc
		for(var/i = 1 to 4)
			var/turf/next = get_step(dest, back_dir)
			if(!next || next.density) break
			dest = next
		if(dest != User.loc)
			User.Move(dest)
		User.dir = turn(User.dir, 180)

		User << "You slip away behind an afterimage with Utsusemi."

		// Clone expires after 5 seconds
		spawn(50)
			if(c && c.loc)
				c.fadeAndDelete()

// TIER 4

/obj/Skills/Hoho/Speed_Clones
	name = "Speed Clones"
	ManaCost = 20
	Cooldown = 90
	var/tmp/list/cloneList = null
	var/tmp/clones_active = FALSE

	verb/Speed_Clones()
		set name = "Speed Clones"
		set category = "Skills"
		var/mob/User = usr
		if(cooldown_remaining) return
		if(clones_active)
			User << "Speed Clones are already active."
			return
		if(src.ManaCost && User.ManaAmount < src.ManaCost)
			User << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, User)
		if(src.ManaCost) User.LoseMana(src.ManaCost)

		clones_active = TRUE
		cloneList = list()

		// Spawn 5 clones at positions around the user
		var/list/dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
		for(var/i = 1 to 5)
			var/mob/Player/HohoClone/c = new(User.loc)
			c.initClone(User)
			var/dir = pick(dirs)
			dirs -= dir
			var/turf/start = User.loc
			var/spread_dist = rand(3, 5)
			for(var/step = 1 to spread_dist)
				var/turf/next_step = get_step(start, dir)
				if(!next_step || next_step.density) break
				start = next_step
			if(start != User.loc)
				c.loc = start
			cloneList.Add(c)

		OMsg(User, "<b>[User]'s speed splits into a flurry of afterimages with Hohō: Speed Clones!</b>")

		var/last_x = User.x
		var/last_y = User.y
		var/end_time = world.time + 150  // 15 seconds

		spawn(0)
			while(clones_active && cloneList && User && User.loc)
				sleep(1)
				if(!User || !User.loc) break
				if(world.time >= end_time) break

				var/dx = User.x - last_x
				var/dy = User.y - last_y

				if(dx || dy)
					for(var/mob/Player/HohoClone/c in cloneList)
						if(!c || !c.loc) continue
						var/nx = c.x + dx
						var/ny = c.y + dy
						if(nx >= 1 && ny >= 1 && nx <= world.maxx && ny <= world.maxy)
							var/turf/cdest = locate(nx, ny, c.z)
							if(cdest && !cdest.density)
								c.loc = cdest
								c.dir = User.dir

					// 25% chance per movement tick to randomly swap with a clone
					if(prob(25) && cloneList.len)
						var/mob/Player/HohoClone/swap_c = pick(cloneList)
						if(swap_c && swap_c.loc)
							var/turf/user_turf = User.loc
							var/turf/clone_turf = swap_c.loc
							// Skip if a clone is already at the swap destination
							var/blocked = FALSE
							for(var/mob/Player/HohoClone/other in user_turf)
								blocked = TRUE
								break
							if(!blocked)
								User.loc = clone_turf
								swap_c.loc = user_turf

					last_x = User.x
					last_y = User.y

			// Timer expired or user gone
			clones_active = FALSE
			if(cloneList)
				for(var/mob/Player/HohoClone/c in cloneList)
					if(c && c.loc)
						c.fadeAndDelete()
				cloneList = null

mob/Player/HohoClone
	Health = 1
	density = 1
	Grabbable = 1
	var/tmp/mob/owner = null
	var/tmp/mob/fade_owner = null

	New(loc)
		..()
		if(!passive_handler) passive_handler = new()

	proc/initClone(mob/User)
		src.icon = User.icon
		src.overlays = User.overlays
		src.name = User.name
		src.dir = User.dir
		src.owner = User
		src.Health = User.Health
		src.VaizardHealth = User.VaizardHealth
		spawn(0)
			while(src && src.loc && !fading && owner && owner.loc)
				src.Health = owner.Health
				src.VaizardHealth = owner.VaizardHealth
				sleep(1)

	var/tmp/fading = FALSE

	proc/fadeAndDelete()
		if(fading) return
		fading = TRUE
		for(var/mob/m in players)
			if(m.Target == src)
				m.Target = null
		if(fade_owner && fade_owner.loc && fade_owner.alpha < 255)
			animate(fade_owner, alpha=255, time=10)
		animate(src, alpha=0, time=10)
		spawn(10)
			if(src) del src

	LoseHealth(amount)
		fadeAndDelete()

	HasGodKi()
		if(owner && owner.loc)
			return owner.HasGodKi()
		return 0

	GetGodKi()
		if(owner && owner.loc)
			return owner.GetGodKi()
		return 0

	HasMaouKi()
		if(owner && owner.loc)
			return owner.HasMaouKi()
		return 0

	Del()
		for(var/mob/m in players)
			if(m.Target == src)
				m.Target = null
		..()
