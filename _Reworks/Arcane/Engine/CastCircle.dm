globalTracker/var
	CAST_CIRCLE_FORM = 8
	CAST_CIRCLE_DISSOLVE = 10
	CAST_CIRCLE_LINGER = 4
	SPELL_EMIT_FWD = 20

proc/CastCircleFile(el)
	switch(el)
		if("Fire") return 'Icons/PerditionMagic/Circles/Circle_Fire.dmi'
		if("Water") return 'Icons/PerditionMagic/Circles/Circle_Water.dmi'
		if("Ice") return 'Icons/PerditionMagic/Circles/Circle_Ice.dmi'
		if("Wind") return 'Icons/PerditionMagic/Circles/Circle_Wind.dmi'
		if("Lightning") return 'Icons/PerditionMagic/Circles/Circle_Lightning.dmi'
		if("Earth") return 'Icons/PerditionMagic/Circles/Circle_Earth.dmi'
		if("Light") return 'Icons/PerditionMagic/Circles/Circle_Light.dmi'
		if("Dark") return 'Icons/PerditionMagic/Circles/Circle_Darkness.dmi'
		if("Space") return 'Icons/PerditionMagic/Circles/Circle_Space.dmi'
		if("Time") return 'Icons/PerditionMagic/Circles/Circle_Time.dmi'
	return 'Icons/PerditionMagic/Circles/Circle_Space.dmi'

proc/CastCircleScale(tier)
	if(tier >= 5) return 1.5
	if(tier >= 3) return 1.2
	return 1

proc/FxDirStep(d, n)
	var/m = ((d & (NORTH|SOUTH)) && (d & (EAST|WEST))) ? round(n * 0.7071) : n
	var/fx = 0
	var/fy = 0
	if(d & EAST) fx = m
	else if(d & WEST) fx = -m
	if(d & NORTH) fy = m
	else if(d & SOUTH) fy = -m
	return list(fx, fy)

proc/FxSideStep(d, n)
	var/m = ((d & (NORTH|SOUTH)) && (d & (EAST|WEST))) ? round(n * 0.7071) : n
	var/fx = 0
	var/fy = 0
	if(d & EAST) fx = 1
	else if(d & WEST) fx = -1
	if(d & NORTH) fy = 1
	else if(d & SOUTH) fy = -1
	return list(fy * m, -fx * m)

obj/Skills/var
	CircleSide = 0
	CircleScale = 0
	CircleFwd = 0

proc/FxCasterCentre(mob/p, size)
	if(!p) return list(-round(size / 2) + 16, -round(size / 2) + 16)
	var/list/wh = _DispIconDims(p.icon)
	var/cx = (p.hurt_w > 0) ? (p.hurt_ox + p.hurt_w / 2 - size / 2) : ((wh[1] - size) / 2)
	var/cy = (p.hurt_h > 0) ? (p.hurt_oy + p.hurt_h / 2 - size / 2) : ((wh[2] - size) / 2)
	return list(round(cx), round(cy))

var/list/_fx_half_masks = list()

proc/FxHalfMask(icon/base, size, nx, ny)
	var/key = "[size]:[nx]:[ny]"
	var/icon/I = _fx_half_masks[key]
	if(I) return I
	I = new(base, null, SOUTH, 1)
	I.DrawBox(null, 1, 1, size, size)
	var/mid = size / 2 + 0.5
	var/len = sqrt(nx * nx + ny * ny)
	for(var/j = 1, j <= size, j++)
		var/uy = j - mid
		var/run_a = 0
		var/run_x = 1
		for(var/i = 1, i <= size + 1, i++)
			var/a = 0
			if(i <= size)
				var/s = ((i - mid) * nx + uy * ny) / len
				a = round(128 + s * 96)
				if(a < 0) a = 0
				if(a > 255) a = 255
			if(i == 1)
				run_a = a
				continue
			if(a != run_a || i > size)
				if(run_a > 0) I.DrawBox(rgb(255, 255, 255, run_a), run_x, j, i - 1, j)
				run_a = a
				run_x = i
	_fx_half_masks[key] = I
	return I

obj/fx_rider
	plane = 0
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	var/tmp
		mob/fx_host
		fx_size = 32
		fx_fwd = 0
		fx_side = 0
		fx_dir = 0
		fx_planted = 0
		fx_cx = 0
		fx_cy = 0
		fx_sx = 0
		fx_sy = 0
		gone = 0

	proc/Offsets()
		var/list/o = FxDirStep(fx_dir, fx_fwd)
		var/list/s = FxSideStep(fx_dir, fx_side)
		return list(fx_sx + fx_cx + o[1] + s[1], fx_sy + fx_cy + o[2] + s[2])

	proc/Place()
		if(!fx_planted)
			if(!fx_host) return
			fx_dir = fx_host.dir
			var/list/c = FxCasterCentre(fx_host, fx_size)
			fx_cx = c[1]
			fx_cy = c[2]
		dir = fx_dir
		var/list/o = Offsets()
		pixel_x = o[1]
		pixel_y = o[2]

	proc/Ride(mob/p, size, fwd, side = 0)
		if(!p || gone) return 0
		fx_host = p
		fx_size = size
		fx_fwd = fwd
		fx_side = side
		fx_sx = 0
		fx_sy = 0
		Place()
		p.vis_contents += src
		spawn() RideLoop()
		return 1

	proc/Plant(mob/p, size, fwd, side = 0)
		if(!p || gone) return 0
		var/turf/T = get_turf(p)
		if(!T) return 0
		fx_planted = 1
		fx_size = size
		fx_fwd = fwd
		fx_side = side
		fx_dir = p.dir
		var/list/c = FxCasterCentre(p, size)
		fx_cx = c[1]
		fx_cy = c[2]
		fx_sx = p.step_x
		fx_sy = p.step_y
		Place()
		loc = T
		return 1

	proc/RideLoop()
		while(!gone && fx_host)
			if(fx_host.dir != fx_dir) Place()
			sleep(1)
		if(!gone) Detach()

	proc/Detach()
		if(gone) return
		gone = 1
		if(fx_host)
			fx_host.vis_contents -= src
			fx_host = null
		loc = null

obj/fx_rider/castcircle
	icon = 'Icons/PerditionMagic/Circles/Circle_Fire.dmi'
	icon_state = "form"
	layer = MOB_LAYER - 0.1
	pixel_x = -16
	pixel_y = -16
	var/tmp
		mob/caster
		closing = 0
		holding = 0
		lock_layer = 0

	Place()
		..()
		if(lock_layer) return
		layer = (fx_dir & NORTH) ? MOB_LAYER - 0.1 : MOB_LAYER + 0.1

	New(turf/T, element, tier = 1, hold = 0, scale = 0)
		..(T)
		icon = CastCircleFile(element)
		holding = hold
		var/s = scale > 0 ? scale : CastCircleScale(tier)
		if(s != 1)
			var/matrix/M = matrix()
			M.Scale(s, s)
			transform = M
		icon_state = "form"
		spawn() Run()

	proc/Run()
		sleep(glob.CAST_CIRCLE_FORM)
		if(closing || gone) return
		icon_state = "hold"
		if(holding) return
		sleep(glob.CAST_CIRCLE_LINGER)
		if(closing || gone || holding) return
		Close()

	proc/Retarget(fwd, side, scale, time)
		if(gone || (!fx_planted && !fx_host)) return
		fx_fwd = fwd
		fx_side = side
		var/list/o = Offsets()
		var/matrix/M = matrix()
		if(scale > 0 && scale != 1) M.Scale(scale, scale)
		animate(src, pixel_x = o[1], pixel_y = o[2], transform = M, time = time)

	proc/Close()
		if(closing) return
		closing = 1
		icon_state = "dissolve"
		spawn(glob.CAST_CIRCLE_DISSOLVE)
			caster = null
			Detach()

	proc/Cut()
		closing = 1
		caster = null
		Detach()

obj/fx_rider/spellart
	layer = MOB_LAYER + 0.3
	var/tmp
		spent = 0
		fx_layer = 0
		fx_half = 0

	New(l, mob/p, icon/art, size, fwd, life, lay, side = 0, half = 0)
		..()
		if(!p)
			loc = null
			return
		icon = art
		fx_layer = lay
		layer = lay
		fx_half = half
		Ride(p, size, fwd, side)
		if(life > 0)
			spawn(life) Fade()

	Place()
		..()
		if(!fx_host) return
		layer = (fx_dir & NORTH) ? (MOB_LAYER - (fx_layer - MOB_LAYER)) : fx_layer
		if(fx_half)
			var/fx = 0
			var/fy = 0
			if(fx_dir & EAST) fx = 1
			else if(fx_dir & WEST) fx = -1
			if(fx_dir & NORTH) fy = 1
			else if(fx_dir & SOUTH) fy = -1
			filters = list(filter(type = "alpha", icon = FxHalfMask(icon, fx_size, fy * fx_half, -fx * fx_half)))

	proc/Kill()
		spent = 1
		animate(src, alpha = 0, time = 0)
		alpha = 0
		Detach()

	proc/Fade()
		if(spent) return
		spent = 1
		animate(src, alpha = 0, time = 3)
		spawn(3) Detach()

mob/proc/SpawnCastCircle(obj/Skills/S, hold = 0)
	if(!S) return null
	var/el = S.SpellElement
	if(!(el in ELEMENT_LIST)) el = "Space"
	CutCastCircles()
	if(!cast_circles) cast_circles = list()
	var/fwd = S.CircleFwd ? S.CircleFwd : glob.SPELL_EMIT_FWD
	var/list/sides = S.CircleSide ? list(S.CircleSide, -S.CircleSide) : list(0)
	var/obj/fx_rider/castcircle/first
	for(var/side in sides)
		var/obj/fx_rider/castcircle/C = new(null, el, S.SpellTier, hold, S.CircleScale)
		C.Plant(src, 64, fwd, side)
		C.caster = src
		cast_circles += C
		if(!first) first = C
	return first

mob/proc/CutCastCircles()
	if(!cast_circles) return
	for(var/obj/fx_rider/castcircle/C in cast_circles)
		C.Cut()
	cast_circles.Cut()

mob/proc/RetargetCastCircles(fwd, side, scale, time, keep = 0)
	if(!cast_circles) return
	var/list/sides = side ? list(side, -side) : list(0)
	var/i = 0
	for(var/obj/fx_rider/castcircle/C in cast_circles)
		if(C.gone) continue
		i++
		C.Retarget(fwd, sides[min(i, sides.len)], scale, time)
		if(keep > 0 && !C.holding)
			C.holding = 1
			spawn(keep) C.Close()

mob/proc/ScrubSpellArt()
	var/list/L = list()
	for(var/obj/fx_rider/spellart/A in vis_contents)
		L += A
	for(var/obj/fx_rider/spellart/A in L)
		A.Kill()

mob/proc/CloseCastCircle()
	if(!held_circle) return
	held_circle = null
	if(!cast_circles) return
	for(var/obj/fx_rider/castcircle/C in cast_circles)
		C.Close()

mob/var/tmp
	obj/fx_rider/castcircle/held_circle
	list/cast_circles
