#define LIFE_STIR_SKILL "Cooking"
#define LIFE_STIR_NEED(D) (3 + 0.4 * (D))
#define LIFE_STIR_TIME(need, D, rank) (round((need) * 14 * clamp(1.7 - 0.2 * ((D) - (rank)), 0.75, 2.2)))
#define LIFE_STIR_BAND(D) (clamp(16 - (D), 8, 16))
#define LIFE_STIR_MIN_R 6
#define LIFE_STIR_MAX_STEP 150
#define LIFE_STIR_LOCK 45
#define LIFE_STIR_RELOCK 45
#define LIFE_STIR_OUT_RATE 0.35
#define LIFE_STIR_DECAY 0.02
#define LIFE_STIR_FINISH_BONUS 0.5
#define LIFE_STIR_MARK_ANG 2
#define LIFE_STIR_MARK_RAD 1

/datum/life_minigame/stir_spiral
	var/need = 4
	var/limit = 60
	var/band = 12

	var/turns = 0
	var/inband = 0
	var/dir = 0
	var/lock = 0
	var/prog = 0
	var/peak = 0
	var/last_ang = null
	var/cx = 0
	var/cy = 0
	var/have_center = 0
	var/samples = 0
	var/moves = 0
	var/ran_ticks = 0
	var/perf_share = 0
	var/mark_ang = null
	var/mark_rad = null

	var/pad_icon = '_Reworks/Arcane/Icons/ArcaneCastCircle.dmi'
	var/pad_state = "Fire1"
	var/pad_size = 96
	var/pad_screen_loc = "CENTER-1,SOUTH+4"
	var/pad_fallback_col = -1
	var/pad_fallback_row = 4
	var/pad_center_dx = 0
	var/pad_center_dy = 0
	var/marker_icon = 'HUD/lifebar_handle.png'
	var/marker_w = 42
	var/marker_h = 44
	var/marker_lead = 90
	var/marker_glide = 2
	var/guide_r0 = 40
	var/guide_r1 = 12
	var/text_w = 220
	var/text_y = 100
	var/hint_y = 118

	proc/GuideRadius()
		var/p = (need > 0) ? clamp(turns / need, 0, 1) : 1
		return guide_r0 + (guide_r1 - guide_r0) * p

	proc/StirSample(x, y)
		samples++
		var/dx = x - cx
		var/dy = y - cy
		var/r = sqrt(dx * dx + dy * dy)
		if(r < LIFE_STIR_MIN_R) return 0
		var/ang = arctan(dx, dy)
		if(isnull(last_ang))
			last_ang = ang
			return 0
		var/d = ang - last_ang
		while(d > 180)
			d -= 360
		while(d <= -180)
			d += 360
		last_ang = ang
		if(abs(d) >= LIFE_STIR_MAX_STEP) return 0
		if(!d) return 0
		var/s = (d > 0) ? 1 : -1
		if(dir == 0 || s != dir)
			lock += d
			prog += dir * d
			if(abs(lock) >= (dir ? LIFE_STIR_RELOCK : LIFE_STIR_LOCK))
				dir = (lock > 0) ? 1 : -1
				lock = 0
				prog = 0
				peak = 0
			return 0
		lock = 0
		prog += dir * d
		if(prog <= peak) return 0
		var/adv = prog - peak
		peak = prog
		var/w = (abs(r - GuideRadius()) <= band) ? 1 : LIFE_STIR_OUT_RATE
		var/gain = adv / 360 * w
		turns += gain
		if(w == 1) inband += gain
		moves++
		return 1

	proc/StirDecay()
		if(turns <= 0)
			turns = 0
			inband = 0
			return
		var/nt = max(0, turns - LIFE_STIR_DECAY)
		inband = inband * (nt / turns)
		turns = nt

	proc/StirCenterFromScreen(client/C)
		if(!C) return
		var/list/t = C.PanelViewTiles()
		if(!t || t.len < 2) return
		var/col = round((t[1] + 1) / 2) + pad_fallback_col
		var/row = 1 + pad_fallback_row
		cx = (col - 1) * 32 + pad_size / 2 + pad_center_dx
		cy = (row - 1) * 32 + pad_size / 2 + pad_center_dy
		have_center = 1

	proc/StirCenterFromPress(mob/M, list/p, params)
		if(!M) return
		var/list/pl = params ? params2list(params) : null
		if(p && pl)
			var/ix = text2num(pl["icon-x"])
			var/iy = text2num(pl["icon-y"])
			if(!isnull(ix) && !isnull(iy))
				cx = p[1] - (ix - 1) + pad_size / 2 + pad_center_dx
				cy = p[2] - (iy - 1) + pad_size / 2 + pad_center_dy
				have_center = 1
				return
		if(!have_center) StirCenterFromScreen(M.client)

	HandleSawDown(mob/M, params)
		if(done || !M || !M.client) return
		var/list/p = M.client.MouseAbs(params)
		StirCenterFromPress(M, p, params)
		last_ang = null
		if(p && have_center) StirSample(p[1], p[2])

	HandleSawDrag(mob/M, params)
		if(done || !M || !M.client || !have_center) return
		var/list/p = M.client.MouseAbs(params)
		if(!p) return
		StirSample(p[1], p[2])

	HandleSawUp(mob/M, params)
		last_ang = null

	proc/MoveMarker(atom/movable/lifebar/part/mk)
		if(!mk) return
		var/base = isnull(last_ang) ? 90 : last_ang
		var/a = base + ((dir < 0) ? -marker_lead : marker_lead)
		var/r = GuideRadius()
		if(!isnull(mark_ang) && !isnull(mark_rad))
			var/da = a - mark_ang
			while(da > 180)
				da -= 360
			while(da <= -180)
				da += 360
			if(abs(da) < LIFE_STIR_MARK_ANG && abs(r - mark_rad) < LIFE_STIR_MARK_RAD) return
		mark_ang = a
		mark_rad = r
		animate(mk, transform = matrix(1, 0, cos(a) * r, 0, 1, sin(a) * r), time = marker_glide)

	Run(mob/M, difficulty = 1, list/opts)
		Attach(M)
		var/D = clamp(difficulty, 1, 10)
		var/rank = M.LifeRank(LIFE_STIR_SKILL)
		need = LIFE_STIR_NEED(D)
		band = LIFE_STIR_BAND(D)
		limit = LIFE_STIR_TIME(need, D, rank)
		if(opts)
			if(opts["need"]) need = opts["need"]
			if(opts["limit"]) limit = opts["limit"]
			if(opts["band"]) band = opts["band"]
			if(opts["target"]) target = opts["target"]
		need = max(0.1, need)
		limit = max(10, round(limit))

		var/atom/movable/lifebar/sawtrack/track = new
		track.icon = pad_icon
		track.icon_state = pad_state
		track.screen_loc = pad_screen_loc
		Show(track)
		var/atom/movable/lifebar/part/mark = MakePart(track, marker_icon, round((pad_size - marker_w) / 2), round((pad_size - marker_h) / 2), 0.2)
		var/atom/movable/lifebar/part/text/prog = new
		prog.maptext_width = text_w
		prog.maptext_height = 16
		prog.pixel_x = round((pad_size - text_w) / 2)
		prog.pixel_y = text_y
		prog.layer = track.layer + 0.3
		track.vis_contents += prog
		hud += prog
		var/atom/movable/lifebar/part/text/hint = new
		hint.maptext_width = text_w
		hint.maptext_height = 16
		hint.pixel_x = round((pad_size - text_w) / 2)
		hint.pixel_y = hint_y
		hint.layer = track.layer + 0.3
		hint.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">press and stir in circles - follow the marker inward</span></center>"
		track.vis_contents += hint
		hud += hint

		sleep(1)
		if(Interrupted())
			Cleanup()
			return -1
		MoveMarker(mark)
		var/started = world.time
		var/lastturns = 0
		var/shown = -1
		var/glowing = FALSE
		while(world.time < started + limit && turns < need)
			if(Interrupted())
				Cleanup()
				return -1
			if(turns > lastturns)
				if(!glowing)
					glowing = TRUE
					mark.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 2, color = "#ffb020")
			else
				StirDecay()
				if(glowing)
					glowing = FALSE
					mark.filters = null
			lastturns = turns
			var/shownow = round(turns, 0.1)
			if(shownow != shown)
				shown = shownow
				prog.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">stir - [shownow] / [round(need, 0.1)] turns</span></center>"
			MoveMarker(mark)
			sleep(1)
		done = TRUE
		ran_ticks = world.time - started
		perf_share = (turns > 0) ? clamp(inband / turns, 0, 1) : 0
		var/perf
		if(turns >= need)
			var/left = max(0, (started + limit) - world.time)
			perf = min(LIFE_PERF_MAX, 1.0 + LIFE_STIR_FINISH_BONUS * perf_share * min(1, 2 * left / limit))
			mark.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 3, color = "#78eb78")
		else
			perf = turns / need
			mark.filters = filter(type = "drop_shadow", x = 0, y = 0, size = 3, color = "#ff6464")
		prog.maptext = "<center><span style=\"[LIFE_FONT]; color:#ffffff\">stir - [round(turns, 0.1)] / [round(need, 0.1)] turns</span></center>"
		sleep(3)
		Cleanup()
		return perf

mob/Admin4/verb/lifeStirTest()
	set category = "Admin"
	if(!client) return
	if(client.life_minigame_sink)
		src << "Finish what you're doing first."
		return
	var/raw = PromptArgValue(src, args, 1, "Stir Test", "num")
	if(isnull(raw)) return
	var/D = text2num("[raw]")
	if(isnull(D))
		src << "Give a difficulty from 1 to 10."
		return
	D = clamp(round(D), 1, 10)
	var/datum/life_minigame/stir_spiral/g = new
	var/perf = g.Run(src, D, null)
	var/secs = g.ran_ticks / max(1, world.fps)
	var/rate = (secs > 0) ? (g.samples / secs) : 0
	src << "<b>stir test D[D]</b> - perf [round(perf, 0.01)], turns [round(g.turns, 0.01)] of [round(g.need, 0.1)], in-band share [round(g.perf_share * 100)]%"
	src << "limit [g.limit] ticks, band [g.band]px, ran [g.ran_ticks] ticks ([round(secs, 0.1)]s)"
	src << "drag samples [g.samples], banked [g.moves], [round(rate, 0.1)] samples per second"
