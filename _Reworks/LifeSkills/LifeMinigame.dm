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
		if("drag_saw") g = new/datum/life_minigame/drag_saw
		if("fish_bar") g = new/datum/life_minigame/fish_bar
		if("water_fill") g = new/datum/life_minigame/water_fill
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

	// mouse-drag input (drag_saw)
	proc/HandleSawDown(mob/M, params)
		return
	proc/HandleSawDrag(mob/M, params)
		return
	proc/HandleSawUp(mob/M, params)
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

// grab the bar and saw up & down. vertical travel fills it; beat the clock
/atom/movable/lifebar/sawtrack
	mouse_opacity = 2
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	MouseDown(location, control, params)
		if(usr && usr.client && usr.client.life_minigame_sink)
			usr.client.life_minigame_sink.HandleSawDown(usr, params)
	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(usr && usr.client && usr.client.life_minigame_sink)
			usr.client.life_minigame_sink.HandleSawDrag(usr, params)
	MouseUp(location, control, params)
		if(usr && usr.client && usr.client.life_minigame_sink)
			usr.client.life_minigame_sink.HandleSawUp(usr, params)

/datum/life_minigame/drag_saw
	var/fill = 0            // stroke-units banked (0..need)
	var/need = 6
	var/last_y = null
	var/stroke_dir = 0      // +1 up / -1 down / 0 idle
	var/anchor_y = 0        // where the current stroke began (last turning point)
	var/peak = 0            // furthest px traveled in stroke_dir from the anchor
	var/credit = 0          // px of this stroke already banked (0..SPAN)

	HandleSawDown(mob/M, params)
		if(done || !M.client) return
		var/list/p = M.client.MouseAbs(params)
		last_y = p ? p[2] : null
		stroke_dir = 0
		peak = 0
		credit = 0

	HandleSawDrag(mob/M, params)
		if(done || !M.client) return
		var/list/p = M.client.MouseAbs(params)
		if(!p) return
		var/y = p[2]
		if(isnull(last_y))
			last_y = y
			return
		var/dy = y - last_y
		last_y = y
		if(!dy) return
		var/dir = (dy > 0) ? 1 : -1
		if(stroke_dir == 0)
			stroke_dir = dir
			anchor_y = y - dy
			peak = 0
			credit = 0
		var/disp = (y - anchor_y) * stroke_dir      // travel in the current stroke direction
		if(disp > peak)
			// extending the stroke - bank up to SPAN, no further
			peak = disp
			var/newcredit = min(peak, LIFE_SAW_SPAN)
			if(newcredit > credit)
				fill += (newcredit - credit) / LIFE_SAW_SPAN
				credit = newcredit
		else if(peak - disp >= LIFE_SAW_REVERSAL)
			// pulled back far enough: begin the return stroke from the turning point
			anchor_y += peak * stroke_dir
			stroke_dir = dir
			peak = max(0, (y - anchor_y) * stroke_dir)
			credit = min(peak, LIFE_SAW_SPAN)
			if(credit > 0) fill += credit / LIFE_SAW_SPAN

	HandleSawUp(mob/M, params)
		last_y = null
		stroke_dir = 0

	Run(mob/M, difficulty = 1, list/opts)
		Attach(M)
		var/limit = 40
		if(opts)
			if(opts["need"]) need = opts["need"]
			if(opts["limit"]) limit = opts["limit"]

		var/atom/movable/lifebar/sawtrack/track = new
		track.icon = 'HUD/lifebar_track.png'
		Show(track)
		var/atom/movable/lifebar/part/fill_bar = MakePart(track, 'HUD/lifebar_fill.png', 26, 20, 0)
		fill_bar.filters = filter(type = "alpha", icon = 'HUD/lifebar_mask.png', x = -148)
		var/atom/movable/lifebar/part/hand = MakePart(track, 'HUD/lifebar_sweet.png', 26 + 148 - LIFE_SWEET_HALF, 10, 0.1)
		var/atom/movable/lifebar/part/ptop = MakePart(track, 'HUD/lifebar_pointer_down.png', LIFE_BAR_X0 - LIFE_TIP_OFFSET, 34, 0.2)
		var/atom/movable/lifebar/part/pbot = MakePart(track, 'HUD/lifebar_pointer_up.png', LIFE_BAR_X0 - LIFE_TIP_OFFSET, -2, 0.2)
		var/atom/movable/lifebar/part/text/hint = new
		hint.maptext_width = 220
		hint.maptext_height = 16
		hint.pixel_y = 78
		hint.layer = track.layer + 0.3
		hint.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">grab the bar - saw up &amp; down!</span></center>"
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
		var/lastfill = 0
		while(world.time < started + limit && fill < need)
			if(Interrupted())
				Cleanup()
				return -1
			if(fill > lastfill)
				if(!glowing)
					glowing = TRUE
					hand.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 2, color = "#ffb020")
			else
				fill = max(0, fill - LIFE_SAW_DECAY)
				if(glowing)
					glowing = FALSE
					hand.filters = null
			lastfill = fill
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

// keep it inside the fish's moving sweet spot to fill the catch meter. 5 fish movement patterns.
/datum/life_minigame/fish_bar
	var/holding = FALSE
	var/track_h = 200
	var/sweet_h = 56
	var/pointer_h = 12
	var/sweet_pos = 70
	var/sweet_target = 70
	var/pointer_pos = 90
	var/pointer_vel = 0
	var/progress = 32
	var/pattern = "mixed"
	var/diff = 1
	var/retarget = 1
	var/atom/movable/lifebar/part/sweet_part
	var/atom/movable/lifebar/part/pointer_part
	var/atom/movable/lifebar/part/fill_part

	HandlePress(mob/M)
		holding = TRUE

	HandleRelease(mob/M)
		holding = FALSE

	Interrupted()
		if(!owner || !owner.client || owner.KO || owner.Dead) return TRUE
		if(target && get_dist(owner, target) > 3) return TRUE   // fishing casts from up to 3 tiles; walking further cancels
		return FALSE

	proc/NewSweetTarget()
		var/base_interval = 25
		var/jump = 55
		switch(pattern)
			if("smooth")
				base_interval = 42
				jump = 28
			if("dart")
				base_interval = 9
				jump = 115
			if("sinker")
				base_interval = 22
				jump = 60
			if("floater")
				base_interval = 22
				jump = 60
		base_interval = max(6, round(base_interval / (1 + 0.18 * diff)))
		var/hi = track_h - sweet_h
		jump = min(round(jump * (1 + 0.12 * diff)), round(hi * 0.7))
		var/newt
		if(pattern == "sinker")
			newt = sweet_pos + rand(-jump, round(jump * 0.4))     // favors down
		else if(pattern == "floater")
			newt = sweet_pos + rand(-round(jump * 0.4), jump)     // favors up
		else
			newt = sweet_pos + rand(-jump, jump)
		sweet_target = clamp(newt, 0, hi)
		retarget = base_interval

	proc/StepSweet()
		retarget--
		if(retarget <= 0) NewSweetTarget()
		var/ease = 0.16
		switch(pattern)
			if("smooth") ease = 0.06
			if("dart") ease = 0.5
		ease = min(0.7, ease * (1 + 0.10 * diff))   
		var/dy = sweet_target - sweet_pos
		if(pattern == "sinker" && dy < 0) ease = min(1, ease * 2.2)   // heavy fall
		if(pattern == "floater" && dy > 0) ease = min(1, ease * 2.2)  // buoyant rise
		sweet_pos = clamp(sweet_pos + dy * ease, 0, track_h - sweet_h)

	proc/StepPointer()
		pointer_vel += (holding ? 2.4 : 0) - 1.1     
		pointer_vel = clamp(pointer_vel, -9, 9)
		pointer_pos += pointer_vel
		if(pointer_pos < 0)
			pointer_pos = 0
			pointer_vel = -pointer_vel * 0.3
		var/top = track_h - pointer_h
		if(pointer_pos > top)
			pointer_pos = top
			pointer_vel = -pointer_vel * 0.3

	Run(mob/M, difficulty = 1, list/opts)
		Attach(M)
		diff = difficulty
		if(opts && opts["pattern"]) pattern = opts["pattern"]
		holding = (M.client && M.client.life_interact_down) ? TRUE : FALSE
		sweet_pos = (track_h - sweet_h) / 2
		sweet_target = sweet_pos
		pointer_pos = (track_h - pointer_h) / 2

		var/atom/movable/lifebar/track = new
		track.icon = 'Icons/LifeSkills/fishbar_track.png'
		track.screen_loc = "CENTER:160,SOUTH:66"   // above the right end of the 12-slot hotbar (slot 12 = CENTER:160,SOUTH:30)
		Show(track)
		MakePart(track, 'Icons/LifeSkills/fishbar_prog_bg.png', 32, 4, 0)
		fill_part = MakePart(track, 'Icons/LifeSkills/fishbar_prog_fill.png', 32, 4, 0.1)
		sweet_part = MakePart(track, 'Icons/LifeSkills/fishbar_sweet.png', 2, 4, 0.2)
		pointer_part = MakePart(track, 'Icons/LifeSkills/fishbar_pointer.png', 2, 4, 0.3)
		var/atom/movable/lifebar/part/text/hint = new
		hint.maptext_width = 120
		hint.maptext_height = 16
		hint.pixel_x = -46
		hint.pixel_y = 214
		hint.layer = track.layer + 0.4
		hint.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">[M.InteractKeyName()] - reel it in!</span></center>"
		track.vis_contents += hint
		hud += hint

		sleep(1)
		if(Interrupted())
			Cleanup()
			return -1
		var/stayed = 0
		var/total = 0
		while(progress > 0 && progress < 100)
			if(Interrupted())
				Cleanup()
				return -1
			StepSweet()
			StepPointer()
			total++
			var/pc = pointer_pos + pointer_h / 2
			var/inzone = (pc >= sweet_pos && pc <= sweet_pos + sweet_h)
			if(inzone)
				stayed++
				progress += 1.2
			else
				progress -= (0.7 + 0.08 * diff)
			progress = clamp(progress, 0, 100)
			sweet_part.transform = matrix(1, 0, 0, 0, 1, sweet_pos)
			pointer_part.transform = matrix(1, 0, 0, 0, 1, pointer_pos)
			pointer_part.color = inzone ? "#78ff8c" : "#ffcf5a"
			var/frac = progress / 100
			var/matrix/fm = matrix()
			fm.Scale(1, frac)
			fm.Translate(0, -track_h * (1 - frac) / 2)
			fill_part.transform = fm
			sleep(1)
		var/perf
		if(progress >= 100)
			perf = clamp(0.5 + 1.2 * (stayed / max(1, total)), LIFE_PERF_MIN, LIFE_PERF_MAX)
		else
			perf = 0   // the fish got away
		sleep(2)
		Cleanup()
		return perf

/datum/life_minigame/water_fill
	var/obj/LifeSkills/FarmPlot/plot
	var/holding = FALSE

	Interrupted()
		if(!owner || !owner.client || owner.KO || owner.Dead) return TRUE
		if(!plot || get_dist(owner, plot) > 1) return TRUE
		return FALSE

	HandlePress(mob/M)
		holding = TRUE

	HandleRelease(mob/M)
		holding = FALSE

	Run(mob/M, difficulty = 1, list/opts)
		Attach(M)
		plot = opts ? opts["plot"] : null
		if(!plot)
			Cleanup()
			return -1
		target = plot
		holding = (M.client && M.client.life_interact_down) ? TRUE : FALSE
		var/atom/movable/lifebar/track = new
		track.icon = 'HUD/lifebar_track.png'
		Show(track)
		var/atom/movable/lifebar/part/fill_bar = MakePart(track, 'HUD/lifebar_fill.png', 26, 20, 0)
		fill_bar.filters = filter(type = "alpha", icon = 'HUD/lifebar_mask.png', x = -148)
		var/atom/movable/lifebar/part/text/hint = new
		hint.maptext_width = 220
		hint.maptext_height = 16
		hint.pixel_y = 78
		hint.layer = track.layer + 0.3
		hint.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">hold [M.InteractKeyName()] - water the plot</span></center>"
		track.vis_contents += hint
		hud += hint

		sleep(1)
		if(Interrupted())
			Cleanup()
			return -1
		var/shown = -1
		while(plot && plot.water_progress < 100)
			if(Interrupted())
				Cleanup()
				return -1
			if(!holding) break                       // released: the plot keeps its progress
			plot.water_progress = min(100, plot.water_progress + FARM_WATER_RATE)
			var/frac = plot.water_progress / 100
			if(frac != shown)
				shown = frac
				animate(fill_bar.filters[1], x = round(148 * frac) - 148, time = 2, easing = SINE_EASING)
			sleep(1)
		var/done = (plot && plot.water_progress >= 100)
		if(done)
			plot.SetWatered()
			sleep(3)
		Cleanup()
		return done ? 1 : 0
