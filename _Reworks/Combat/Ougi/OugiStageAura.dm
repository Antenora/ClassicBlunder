/datum/aurafx_rig/ougi_scene
	var
		datum/ougi_scene/scene
		grow_to = 1
		grow_step = 0
		glide_gi = 0

/datum/aurafx_rig/ougi_scene/proc/GrowToward(g)
	if(grow < grow_to) return min(grow_to, g + grow_step)
	if(grow > grow_to) return max(grow_to, g - grow_step)
	return g

/datum/aurafx_rig/ougi_scene/proc/TierRatio(a, b)
	var/ka = (a - 1) * 4 + (facing == NORTH ? 2 : facing == EAST ? 3 : facing == WEST ? 4 : 1)
	var/kb = (b - 1) * 4 + (facing == NORTH ? 2 : facing == EAST ? 3 : facing == WEST ? 4 : 1)
	var/sx = aurafx_grow_sx[kb] / aurafx_grow_sx[ka]
	var/sy = aurafx_grow_sy[kb] / aurafx_grow_sy[ka]
	var/matrix/X = matrix()
	X.Scale(sx, sy)
	X.Translate(aurafx_grow_tx[kb] - aurafx_grow_tx[ka] * sx, aurafx_grow_ty[kb] - aurafx_grow_ty[ka] * sy)
	return X

/datum/aurafx_rig/ougi_scene/GrowTick(now)
	grow = GrowToward(grow)
	if(mode != AURAFX_M_IDLE)
		glide_gi = 0
		return
	if((now - idle0) % aurafx_swap_ticks) return
	var/ni = GrowIndex()
	if(ni != gi)
		gi = ni
		idle0 = now
		for(var/obj/aurafx/O in list(hp, hl))
			animate(O)
			O.transform = matrix()
		AuraFXPlaceArt(hp, "[aurafx_grow_states[gi]]p", aurafx_idle_px, aurafx_idle_py)
		AuraFXPlaceArt(hl, "[aurafx_grow_states[gi]]l", aurafx_idle_px, aurafx_idle_py)
		SparkRegion()
	var/g = grow
	for(var/k = 1 to aurafx_swap_ticks)
		g = GrowToward(g)
	var/keep = grow
	grow = g
	var/nx = GrowIndex()
	grow = keep
	if(nx == gi)
		if(glide_gi)
			for(var/obj/aurafx/O in list(hp, hl))
				animate(O)
				O.transform = matrix()
		glide_gi = 0
		return
	glide_gi = nx
	var/matrix/X = TierRatio(gi, nx)
	for(var/obj/aurafx/O in list(hp, hl))
		animate(O, transform = X, time = aurafx_swap_ticks * world.tick_lag)

/datum/aurafx_rig/ougi_scene/Kill()
	var/datum/ougi_scene/S = scene
	var/mob/W = M
	scene = null
	..()
	if(S && S.ougi_auras && W && S.ougi_auras[W] == src) S.ougi_auras -= W

/datum/ougi_scene
	var
		list/ougi_auras
		list/ougi_aura_held

/datum/ougi_scene/DoOp(op, list/a)
	if(op == "aura") return OpAura(a)
	return ..()

/datum/ougi_scene/proc/OugiAuraSuspend(mob/M)
	var/datum/aurafx_rig/O = M.aurafx_rig
	if(!O || (!O.want && !O.form)) return
	if(!ougi_aura_held) ougi_aura_held = list()
	ougi_aura_held[M] = list(O.want, O.form, O.art)
	O.want = 0
	O.form = 0
	O.exit = AURAFX_EXIT_NOW

/datum/ougi_scene/proc/OpAura(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors) || !AuraFXOn()) return
	var/phase = ArgText(a, "phase", "ignite")
	if(!ougi_auras) ougi_auras = list()
	var/datum/aurafx_rig/ougi_scene/R = ougi_auras[M]
	if(!R)
		if(phase == "off" || phase == "dissipate" || phase == "hold") return
		OugiAuraSuspend(M)
		R = new
		R.M = M
		R.scene = src
		R.facing = R.Facing4(M.dir)
		ougi_auras[M] = R
		aurafx_rigs += R
		AuraFXLoop()
	var/size = clamp(ArgNum(a, "size", R.grow_to * 100), 100, 170) / 100
	var/ticks = max(1, Ds(ArgNum(a, "time", 4)) / world.tick_lag)
	switch(phase)
		if("ignite", "appear")
			R.want = 1
			R.ignite = (phase == "ignite") ? 1 : 0
			R.exit = AURAFX_EXIT_FADE
			if(!R.shown)
				R.grow = 1
				R.grow_to = 1
				R.grow_step = 0
		if("grow")
			if(!R.want)
				R.want = 1
				R.ignite = 0
			R.grow_to = size
			R.grow_step = abs(size - R.grow) / ticks
		if("hold")
			R.grow_to = R.grow
			R.grow_step = 0
		if("dissipate")
			R.want = 0
			R.exit = AURAFX_EXIT_FADE
		if("off")
			R.want = 0
			R.exit = AURAFX_EXIT_NOW
		else
			world.log << "OUGI: aura phase [phase] is unknown in [id]; skipped"

/datum/ougi_scene/proc/OugiAurasEnd()
	if(ougi_auras)
		for(var/mob/M in ougi_auras.Copy())
			var/datum/aurafx_rig/ougi_scene/R = ougi_auras[M]
			if(R) R.Kill()
		ougi_auras = null
	if(ougi_aura_held)
		for(var/mob/M in ougi_aura_held)
			var/list/h = ougi_aura_held[M]
			if(!M || !h || !AuraFXOn()) continue
			var/datum/aurafx_rig/O = M.AuraFXRig()
			O.want = h[1]
			O.form = h[2]
			O.art = h[3]
			O.exit = AURAFX_EXIT_FADE
		ougi_aura_held = null

/datum/ougi_scene/LeaveRoom()
	OugiAurasEnd()
	..()

/datum/ougi_scene/End(force = 0)
	OugiAurasEnd()
	..()
