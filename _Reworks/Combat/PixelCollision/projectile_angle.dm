obj/Skills/Projectile/_Projectile
	var/tmp
		fa_rx = 0
		fa_ry = 0
		fa_px = 0
		fa_turn = 0
		fa_launch
		fa_bonus = 0
		fa_lastdist
		fa_dirs = 0
		fa_dirs_icon

	proc/AngleArtDirs()
		if(fa_dirs && icon == fa_dirs_icon)
			return fa_dirs
		fa_dirs_icon = icon
		fa_dirs = IconDirCount(icon)
		return fa_dirs

	proc/AngleWorldX()
		return 1 + (x - 1) * 32 + step_x + 16

	proc/AngleWorldY()
		return 1 + (y - 1) * 32 + step_y + 16

	proc/AngleToward(atom/movable/a)
		if(!a)
			return FlightAngle
		var/dx = (1 + (a.x - 1) * 32 + a.step_x + 16) - AngleWorldX()
		var/dy = (1 + (a.y - 1) * 32 + a.step_y + 16) - AngleWorldY()
		if(!dx && !dy)
			return FlightAngle
		var/ang = arctan(dx, dy)
		while(ang < 0)
			ang += 360
		return ang

	proc/AngleFlightDir()
		if(AngleArtDirs() == 4)
			return GunAngleCardinal(FlightAngle)
		return GunAngleDir(FlightAngle)

	proc/AngleArtBase()
		if(AngleArtDirs() <= 1)
			return GunDirAngle(SOUTH)
		return GunDirAngle(dir)

	proc/AngleArtTurn()
		if(isnull(FlightAngle))
			return
		var/want = FlightAngle - AngleArtBase()
		while(want <= -180)
			want += 360
		while(want > 180)
			want -= 360
		if(want == fa_turn)
			return
		if(!transform)
			transform = matrix()
		transform = transform.Turn(fa_turn - want)
		fa_turn = want

	proc/AngleSyncDir()
		var/d = AngleFlightDir()
		if(dir != d)
			dir = d
		var/shown = DisplayedCardinal(dir, pc_lastdir)
		if(shown != pc_lastdir)
			ReapplyHitboxForDir(shown)
			pc_lastdir = shown
		AngleArtTurn()

	proc/AngleBegin()
		fa_rx = 0
		fa_ry = 0
		fa_px = 0
		fa_bonus = 0
		fa_lastdist = null
		if(isnull(FlightAngle))
			return
		AngleSyncDir()
		if(!Owner || !loc || Owner.z != z)
			return
		var/ox = 1 + (Owner.x - 1) * 32 + Owner.step_x + 16
		var/oy = 1 + (Owner.y - 1) * 32 + Owner.step_y + 16
		var/px = AngleWorldX()
		var/py = AngleWorldY()
		var/r = sqrt((px - ox) * (px - ox) + (py - oy) * (py - oy))
		if(r < 1)
			return
		var/la = isnull(fa_launch) ? FlightAngle : fa_launch
		var/ix = round(ox + cos(la) * r - px, 1)
		var/iy = round(oy + sin(la) * r - py, 1)
		if(!ix && !iy)
			return
		Move(loc, dir, step_x + ix, step_y + iy)

	proc/AngleReconcile()
		if(isnull(FlightAngle))
			return
		if(dir == AngleFlightDir())
			return
		FlightAngle = GunDirAngle(dir)
		fa_rx = 0
		fa_ry = 0
		AngleSyncDir()

	proc/AngleBoxExtent(cx, cy)
		var/w = vhb_w > 0 ? vhb_w : 32
		var/h = vhb_h > 0 ? vhb_h : 32
		return max(2, abs(cx) * w + abs(cy) * h)

	proc/AngleAdvance(dx, dy)
		if(!isnull(fa_lastdist) && Distance != fa_lastdist)
			fa_bonus += Distance - fa_lastdist
		fa_px += sqrt(dx * dx + dy * dy)
		fa_rx += dx
		fa_ry += dy
		var/ix = fa_rx >= 0 ? round(fa_rx) : -round(-fa_rx)
		var/iy = fa_ry >= 0 ? round(fa_ry) : -round(-fa_ry)
		if(ix || iy)
			fa_rx -= ix
			fa_ry -= iy
			Move(loc, dir, step_x + ix, step_y + iy)
			if(Killed || Distance < 0 || !loc)
				return
		Distance = max(0, DistanceMax + fa_bonus - fa_px / 32)
		fa_lastdist = Distance

	proc/AngleSlide(total)
		var/cx = cos(FlightAngle)
		var/cy = sin(FlightAngle)
		var/ext = AngleBoxExtent(cx, cy)
		var/parts = round(total / ext)
		if(parts * ext < total)
			parts++
		parts = max(1, parts)
		var/per = total / parts
		for(var/p = 1, p <= parts, p++)
			AngleAdvance(cx * per, cy * per)
			if(Killed || Distance <= 0 || !loc)
				return
			PixelWallCheck()
			if(Killed || Distance <= 0)
				return
			PixelContactSweep()
			if(Killed || Distance <= 0)
				return

	proc/AngleTravel()
		for(var/i = 1, i <= max(1, pm_substep), i++)
			sleep(world.tick_lag)
			if(Killed || Distance <= 0)
				return
			AngleReconcile()
			var/shown = DisplayedCardinal(dir, pc_lastdir)
			if(isfile(icon) && icon != hb_icon)
				ApplySkillHitbox(icon, shown, hb_scale, hb_ovW, hb_ovH, hb_ovX, hb_ovY, hb_offX, hb_offY)
				pc_lastdir = shown
				AngleArtTurn()
			else if(shown != pc_lastdir)
				ReapplyHitboxForDir(shown)
				pc_lastdir = shown
				AngleArtTurn()
			RefitGrowScale()
			AngleSlide(max(1, step_size))
			if(Killed || Distance <= 0)
				return
