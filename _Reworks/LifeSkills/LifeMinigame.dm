/atom/movable/lifebar
	layer = FLY_LAYER + 4
	mouse_opacity = 0
	screen_loc = "CENTER-3,SOUTH+5"

/atom/movable/lifebar/part
	layer = FLY_LAYER + 4.1
	mouse_opacity = 0

/atom/movable/lifebar/part/text
	New()
		..()
		filters = filter(type = "outline", size = 1, color = "#000000")

proc/RunLifeMinigame(mob/M, id = "timing_bar", difficulty = 1, list/opts)
	if(!M || !M.client) return -1
	if(M.client.life_minigame_sink) return -1
	var/datum/life_minigame/g
	switch(id)
		if("timing_bar") g = new/datum/life_minigame/timing_bar
		if("rapid_tap") g = new/datum/life_minigame/rapid_tap
		if("hold_fill") g = new/datum/life_minigame/hold_fill
	if(!g) return -1
	if(opts && opts["target"]) g.target = opts["target"]
	return g.Run(M, difficulty, opts)

/datum/life_minigame
	var/mob/owner
	var/atom/target        // wander off from the node/station and the work stops
	var/done = FALSE
	var/press_time = 0
	var/list/hud = list()

	proc/HandlePress(mob/M)
		if(done) return
		press_time = world.time
		done = TRUE

	proc/HandleRelease(mob/M)
		return

	proc/Run(mob/M, difficulty = 1, list/opts)
		return LIFE_PERF_MIN

	proc/Attach(mob/M)
		owner = M
		M.client.life_minigame_sink = src

	proc/Show(atom/movable/o)
		hud += o
		owner.client.screen += o

	proc/MakePart(atom/movable/lifebar/anchor, icon_file, px, py, lay = 0)
		var/atom/movable/lifebar/part/p = new
		if(icon_file) p.icon = icon_file
		p.pixel_x = px
		p.pixel_y = py
		p.layer = anchor.layer + 0.1 + lay
		anchor.vis_contents += p
		hud += p
		return p

	proc/Interrupted()
		if(!owner || !owner.client || owner.KO || owner.Dead) return TRUE
		if(target && get_dist(owner, target) > 1) return TRUE
		return FALSE

	proc/Cleanup()
		if(owner && owner.client)
			if(owner.client.life_minigame_sink == src)
				owner.client.life_minigame_sink = null
			for(var/atom/movable/o in hud)
				owner.client.screen -= o
		for(var/atom/movable/o in hud)
			del o
		hud = list()
		owner = null

// paired pointers sweep the track; tap when their tips are over the sweet-spot handle.
#define LIFE_BAR_X0 26
#define LIFE_BAR_SPAN 148
#define LIFE_SWEET_HALF 15
#define LIFE_TIP_OFFSET 18
#define LIFE_HIT_SLOP 16

/datum/life_minigame/timing_bar
	Run(mob/M, difficulty = 1, list/opts)
		Attach(M)
		var/speed = 1
		var/period = LIFE_MINING_BAR_PERIOD
		if(opts)
			if(opts["speed_mult"]) speed = opts["speed_mult"]
			if(opts["period"]) period = opts["period"]
		period /= max(speed, 0.1)
		var/cx = rand(LIFE_BAR_X0 + LIFE_SWEET_HALF, LIFE_BAR_X0 + LIFE_BAR_SPAN - LIFE_SWEET_HALF)

		var/atom/movable/lifebar/track = new
		track.icon = 'HUD/lifebar_track.png'
		Show(track)
		// pointers overlay the frame: tips kiss the inner gauge (from-bottom 20..34)
		var/atom/movable/lifebar/part/hand = MakePart(track, 'HUD/lifebar_sweet.png', cx - LIFE_SWEET_HALF, 10, 0.1)
		var/atom/movable/lifebar/part/ptop = MakePart(track, 'HUD/lifebar_pointer_down.png', LIFE_BAR_X0 - LIFE_TIP_OFFSET, 34, 0.2)
		var/atom/movable/lifebar/part/pbot = MakePart(track, 'HUD/lifebar_pointer_up.png', LIFE_BAR_X0 - LIFE_TIP_OFFSET, -2, 0.2)
		var/atom/movable/lifebar/part/text/hint = new
		hint.maptext_width = 198
		hint.maptext_height = 16
		hint.pixel_y = 78
		hint.layer = track.layer + 0.3
		hint.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">[M.InteractKeyName()] - strike!</span></center>"
		track.vis_contents += hint
		hud += hint

		var/ticks = max(4, round(period * 10))
		sleep(1)   // let the client receive the bar before animating, or the pointers snap
		if(Interrupted())
			Cleanup()
			return -1
		animate(ptop, transform = matrix(1, 0, LIFE_BAR_SPAN, 0, 1, 0), time = ticks)
		animate(pbot, transform = matrix(1, 0, LIFE_BAR_SPAN, 0, 1, 0), time = ticks)
		var/started = world.time
		while(!done && world.time < started + ticks)
			if(Interrupted())
				Cleanup()
				return -1
			sleep(1)
		var/perf = 0
		if(done)
			var/frac = clamp((press_time - started) / ticks, 0, 1)
			var/dx = round(LIFE_BAR_SPAN * frac)
			animate(ptop)
			animate(pbot)
			ptop.transform = matrix(1, 0, dx, 0, 1, 0)
			pbot.transform = matrix(1, 0, dx, 0, 1, 0)
			var/dist = abs((LIFE_BAR_X0 + dx) - cx)
			if(dist <= LIFE_HIT_SLOP)
				perf = LIFE_PERF_MAX
			else
				perf = clamp(1.2 - (dist - LIFE_HIT_SLOP) / 25, 0, 1.2)
			hand.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 3, color = (dist <= LIFE_HIT_SLOP) ? "#78eb78" : "#ff6464")
		sleep(3)
		Cleanup()
		return perf

// out of your depth the window is shorter than the fill time - unwinnable on purpose.
/datum/life_minigame/hold_fill
	var/holding = FALSE
	var/fill = 0
	var/need = 24

	HandlePress(mob/M)
		if(done) return
		holding = TRUE

	HandleRelease(mob/M)
		holding = FALSE

	Run(mob/M, difficulty = 1, list/opts)
		Attach(M)
		holding = (M.client && M.client.life_interact_down) ? TRUE : FALSE   
		var/limit = 40
		if(opts)
			if(opts["need"]) need = opts["need"]
			if(opts["limit"]) limit = opts["limit"]
		var/impossible = (limit < need)

		var/atom/movable/lifebar/track = new
		track.icon = 'HUD/lifebar_track.png'
		Show(track)
		var/atom/movable/lifebar/part/fill_bar = MakePart(track, 'HUD/lifebar_fill.png', 26, 20, 0)
		fill_bar.filters = filter(type = "alpha", icon = 'HUD/lifebar_mask.png', x = -148)
		var/atom/movable/lifebar/part/hand = MakePart(track, 'HUD/lifebar_sweet.png', 26 + 148 - LIFE_SWEET_HALF, 10, 0.1)
		// the pointers are the clock - beat them to the end
		var/atom/movable/lifebar/part/ptop = MakePart(track, 'HUD/lifebar_pointer_down.png', LIFE_BAR_X0 - LIFE_TIP_OFFSET, 34, 0.2)
		var/atom/movable/lifebar/part/pbot = MakePart(track, 'HUD/lifebar_pointer_up.png', LIFE_BAR_X0 - LIFE_TIP_OFFSET, -2, 0.2)
		var/atom/movable/lifebar/part/text/hint = new
		hint.maptext_width = 198
		hint.maptext_height = 16
		hint.pixel_y = 78
		hint.layer = track.layer + 0.3
		hint.maptext = "<center><span style=\"[LIFE_FONT]; color:[impossible ? "#ff6464" : "#ffffff"]\">[M.InteractKeyName()] - HOLD!</span></center>"
		track.vis_contents += hint
		hud += hint

		sleep(1)
		if(Interrupted())
			Cleanup()
			return -1
		animate(ptop, transform = matrix(1, 0, LIFE_BAR_SPAN, 0, 1, 0), time = limit)
		animate(pbot, transform = matrix(1, 0, LIFE_BAR_SPAN, 0, 1, 0), time = limit)
		var/started = world.time
		var/shown = -1
		var/glowing = FALSE
		while(world.time < started + limit && fill < need)
			if(Interrupted())
				Cleanup()
				return -1
			if(holding)
				fill += 1
				if(!glowing)
					glowing = TRUE
					hand.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 2, color = "#ffb020")
			else
				fill = max(0, fill - LIFE_HOLD_DECAY)
				if(glowing)
					glowing = FALSE
					hand.filters = null
			var/frac = min(1, fill / need)
			if(frac != shown)
				shown = frac
				animate(fill_bar.filters[1], x = round(148 * frac) - 148, time = 2, easing = SINE_EASING)
			sleep(1)
		done = TRUE
		var/perf
		if(fill >= need)
			var/elapsed = world.time - started
			perf = min(LIFE_PERF_MAX, 1.0 + 2 * (limit - elapsed) / limit)
			hand.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 3, color = "#78eb78")
		else
			perf = fill / need
			hand.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 3, color = "#ff6464")
		animate(ptop)
		animate(pbot)
		sleep(3)
		Cleanup()
		return perf

// mash Interact before the window closes
/datum/life_minigame/rapid_tap
	var/taps = 0
	var/last_tap = 0
	var/need = 10

	HandlePress(mob/M)
		if(done) return
		if(world.time < last_tap + LIFE_TAP_MIN_GAP) return
		last_tap = world.time
		taps++

	Run(mob/M, difficulty = 1, list/opts)
		Attach(M)
		var/level = 0
		if(opts && opts["level"]) level = opts["level"]
		need = LIFE_TAP_BASE + LIFE_TAP_PER_TIER * difficulty
		var/window = LIFE_TAP_WINDOW_BASE + LIFE_TAP_WINDOW_PER_LEVEL * level
		// the tap-gap cap must leave the bar fillable
		var/maxtaps = round(window * 10 / LIFE_TAP_MIN_GAP)
		if(need > maxtaps - 2) need = maxtaps - 2

		var/atom/movable/lifebar/track = new
		track.icon = 'HUD/lifebar_track.png'
		Show(track)
		var/atom/movable/lifebar/part/fill = MakePart(track, 'HUD/lifebar_fill.png', 26, 20, 0)
		fill.filters = filter(type = "alpha", icon = 'HUD/lifebar_mask.png', x = -148)
		var/atom/movable/lifebar/part/hand = MakePart(track, 'HUD/lifebar_sweet.png', 26 + 148 - LIFE_SWEET_HALF, 10, 0.1)
		var/atom/movable/lifebar/part/text/hint = new
		hint.maptext_width = 198
		hint.maptext_height = 16
		hint.pixel_y = 56
		hint.layer = track.layer + 0.3
		hint.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">[M.InteractKeyName()] - hammer! tap fast!</span></center>"
		track.vis_contents += hint
		hud += hint

		var/ticks = max(10, round(window * 10))
		var/started = world.time
		var/shown = -1
		while(world.time < started + ticks)
			if(Interrupted())
				Cleanup()
				return -1
			var/frac = min(1, taps / need)
			if(frac != shown)
				shown = frac
				// glide the mask like the tbar health fills do, no jerking
				animate(fill.filters[1], x = round(148 * frac) - 148, time = 4, easing = SINE_EASING)
			sleep(1)
		done = TRUE
		var/perf = 0.5 + min(1, taps / need)
		hand.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 3, color = taps >= need ? "#78eb78" : "#ff6464")
		sleep(3)
		Cleanup()
		return perf
