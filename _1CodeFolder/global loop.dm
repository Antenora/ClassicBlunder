


datum
	proc/Update()


var/tmp/update_loop
	global_loop
	sub_loop/ai_loop
	sub_loop/travel_loop
	special_loop/ai_tracker_loop/ai_tracker_loop

update_loop
	var
		tmp/list/updaters
		tick_lag
		next_tick

	New(tick_lag = 0)
		..()
		src.tick_lag = tick_lag
		updaters = new
		spawn Loop()

	proc
		Add(updater)
			if(!(updater in updaters))
				updaters += updater

		Remove(updater)
			updaters -= updater

		Loop()
			for()
				for(var/atom/updater in updaters)
					updater.Update()
				for(var/update_loop/updater in updaters)
					if(world.time >= updater.next_tick) updater.Update()
				sleep(world.tick_lag)

		UpdateAll()
			for(var/updater in updaters)
				Update(updater)

	Update(updater)
		updater:Update()

	special_loop //This subtype generally abuses overrides

	sub_loop
		var/delay
		var/last_loop
		New()
			..()
			updaters=new
			src.delay = delay
		Loop()
			return

		Add(updater)
			if(!(updater in updaters))
				updaters += updater
			global_loop.Add(src)

		Remove(updater)
			updaters -= updater
			if(!updaters.len)
				global_loop.Remove(src)

		Update()
			if(!delay || (world.time > last_loop + delay))
				last_loop = world.time
				for(var/datum/updater in updaters)
					updater.Update()