//reusable impact/ground FX

//arc sprite for Discharge
obj/Effects/DischargeArc
	icon='Icons/Effects/Lightning VFX5.dmi'
	layer=EFFECTS_LAYER
	plane=1
	blend_mode=2
	Lifetime=3 //Effects New() runs the fade+finish chain
	pixel_x=-48
	pixel_y=-48

proc
	//landing impact at A's feet. 0 = whisper. >=0.5 adds a hop of quake, >=0.8 a pressure ring.
	Landfall(atom/A, weight = 0)
		set waitfor=0
		if(!A) return
		var/turf/T = get_turf(A)
		if(!T) return
		if(weight > 2) weight = 2
		var/n = 4 + round(weight * 4)
		var/r = 8 + round(weight * 10)
		for(var/i = 1, i <= n, i++)
			var/obj/Effects/Dust/D = new(T)
			if(PmActive() && ismovable(A)) //mid-tile mobs: mirror the real offsets
				var/atom/movable/M = A
				D.step_x = M.step_x
				D.step_y = M.step_y
			//PARALLEL so the radial kick layers with the settle from Dust/New
			var/ang = (i - 1) * (360 / n) + rand(-20, 20)
			animate(D, pixel_w = round(cos(ang) * r, 1), pixel_z = round(sin(ang) * r, 1), time = 6, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
		if(weight >= 0.5)
			A.Earthquake(4,-2,2,-2,2)
		if(weight >= 0.8)
			KenShockwave(A, Size = 0.5 + weight)

	//sliding dust trail - a small puff every 2 ticks, quits once A stops or vanishes
	Skid(atom/A, time = 6)
		set waitfor=0
		if(!A || !get_turf(A)) return
		var/turf/last
		var/still = 0
		for(var/t = 0, t < time, t += 2)
			if(!A) return
			var/turf/T = get_turf(A)
			if(!T) return
			if(T == last)
				if(++still >= 2) return
			else
				still = 0
				last = T
			Footfall(A)
			sleep(2)

	//one tiny puff at the feet. Dash steps, not ordinary walking.
	Footfall(atom/A)
		if(!A) return
		var/turf/T = get_turf(A)
		if(!T) return
		var/obj/Effects/Dust/D = new(T)
		if(PmActive() && ismovable(A))
			var/atom/movable/M = A
			D.step_x = M.step_x
			D.step_y = M.step_y
		//re-stage the settle small and faint, a fresh animate replaces New's chain
		D.alpha = 160
		D.pixel_x = -16 + rand(-5, 5)
		D.pixel_y = -16 + rand(-8, -2)
		var/ang = pick(0, 45, 90, 135, 180, 225, 270, 315)
		D.transform = turn(matrix()*0.25, ang)
		animate(D, transform = turn(matrix()*0.4, ang + rand(-25, 25)), pixel_x = D.pixel_x + gauss(3), pixel_y = D.pixel_y + rand(1, 4), alpha = 0, time = 13, easing = QUAD_EASING|EASE_OUT)

	//brief electric arcing around A
	Discharge(atom/A, col = null, n = 3)
		set waitfor=0
		if(!A || !get_turf(A)) return
		FxLightPulse(get_turf(A), 1.4, col)
		for(var/i = 1, i <= n, i++)
			var/turf/T = get_turf(A)
			if(!T) return
			var/obj/Effects/DischargeArc/E = new(T)
			if(PmActive() && ismovable(A))
				var/atom/movable/M = A
				E.step_x = M.step_x
				E.step_y = M.step_y
			E.pixel_x += rand(-12, 12)
			E.pixel_y += rand(-12, 12)
			E.transform = turn(matrix() * (0.4 + rand()*0.1), pick(0, 45, 90, 135, 180, 225, 270, 315))
			if(col) E.color = col
			sleep(rand(2, 3))
