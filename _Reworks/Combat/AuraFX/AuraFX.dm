globalTracker/var/tmp
	AURAFX = TRUE

var/list/aurafx_rigs = list()
var/aurafx_looping = 0
var/aurafx_errors = 0
var/aurafx_last_error
var/list/aurafx_hot_m = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 1,0.99,0.72,0)
var/list/aurafx_cool_m = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 1,0.86,0.45,0)
var/list/aurafx_black_m = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)

mob/var/tmp/datum/aurafx_rig/aurafx_rig

transformation/saiyan/var/aurafx_tier = 0

transformation/saiyan/super_saiyan
	aurafx_tier = 1

transformation/saiyan/super_saiyan_2
	aurafx_tier = 2

transformation/saiyan/super_saiyan_3
	aurafx_tier = 3

/obj/aurafx
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	surface_profile = "ground_flat"
	var/tmp/obj/aurafx/stamp/stamp
	var/tmp/lit = 0
	var/tmp/on = 0

/obj/aurafx/paint

/obj/aurafx/apart
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/aurafx/light
	appearance_flags = KEEP_APART | RESET_COLOR
	blend_mode = BLEND_ADD
	lit = 1

/obj/aurafx/stamp
	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR
	appearance_flags = KEEP_APART | RESET_COLOR

/obj/aurafx/copy
	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR

/obj/aurafx/keep
	alpha = 0
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

proc/AuraFXOn()
	return glob && glob.AURAFX && AURAFX_ASSETS

proc/AuraFXNow()
	return round(world.time / world.tick_lag, 1)

proc/AuraFXTierM(gi, facing)
	var/k = (gi - 1) * 4 + (facing == NORTH ? 2 : facing == EAST ? 3 : facing == WEST ? 4 : 1)
	var/matrix/X = matrix()
	X.Scale(aurafx_grow_sx[k], aurafx_grow_sy[k])
	X.Translate(aurafx_grow_tx[k], aurafx_grow_ty[k])
	return X

proc/AuraFXPlaceArt(obj/aurafx/O, st, ox, oy)
	O.icon = aurafx_art_ic[st]
	O.icon_state = st
	O.pixel_x = ox + aurafx_art_dx[st]
	O.pixel_y = oy + aurafx_art_dy[st]

proc/AuraFXSwapArt(obj/aurafx/O, st)
	var/was = O.icon_state
	if(was && (was in aurafx_art_dx))
		O.pixel_x += aurafx_art_dx[st] - aurafx_art_dx[was]
		O.pixel_y += aurafx_art_dy[st] - aurafx_art_dy[was]
	O.icon = aurafx_art_ic[st]
	O.icon_state = st

proc/AuraFXStampConfig(obj/aurafx/stamp/S, lit)
	FxEmissiveConfig(S, null)
	if(lit && !(glob && glob.MULTIPLY_REVEAL))
		S.layer = AURAFX_STAMP_LAYER_L
		S.blend_mode = BLEND_ADD

proc/AuraFXLoop()
	set waitfor = 0
	if(aurafx_looping) return
	aurafx_looping = 1
	while(aurafx_rigs.len)
		sleep(world.tick_lag)
		var/now = AuraFXNow()
		for(var/datum/aurafx_rig/R in aurafx_rigs.Copy())
			try
				R.Tick(now)
			catch(var/exception/E)
				aurafx_errors++
				aurafx_last_error = "[E] [E.file]:[E.line]"
				world.log << "AuraFX rig error: [aurafx_last_error]"
				R.Kill()
	aurafx_looping = 0

mob/proc/AuraFXRig()
	if(!aurafx_rig)
		var/datum/aurafx_rig/R = new
		R.M = src
		R.facing = R.Facing4(dir)
		aurafx_rig = R
		aurafx_rigs += R
		AuraFXLoop()
	return aurafx_rig

mob/proc/AuraFXWant(transformation/saiyan/D)
	var/datum/aurafx_rig/R = AuraFXRig()
	R.want = D.aurafx_tier
	R.exit = AURAFX_EXIT_FADE
	R.art = D.form_aura_icon

mob/proc/AuraFXUnwant(transformation/saiyan/D)
	if(aurafx_rig) aurafx_rig.want = 0

mob/proc/AuraFXForm(transformation/saiyan/D)
	if(D.aurafx_tier < 2)
		if(aurafx_rig) aurafx_rig.form = 0
		return
	var/datum/aurafx_rig/R = AuraFXRig()
	R.form = D.aurafx_tier

mob/proc/AuraFXFormOff(transformation/saiyan/D)
	if(aurafx_rig && aurafx_rig.form == D.aurafx_tier) aurafx_rig.form = 0

transformation/saiyan/apply_visuals(mob/user, aura = 1, hair = 1, extra = 1)
	if(aurafx_tier && user && AuraFXOn() && istype(user, /mob/Players))
		..(user, 0, hair, extra)
		if(aura) user.AuraFXWant(src)
		if(extra)
			user.AuraFXForm(src)
			if(aurafx_tier >= 2 && form_icon_2) user.overlays -= form_icon_2
		return
	..()

transformation/saiyan/remove_visuals(mob/user, aura = 1, hair = 1, extra = 1)
	if(aurafx_tier && user && user.aurafx_rig)
		if(aura) user.AuraFXUnwant(src)
		if(extra) user.AuraFXFormOff(src)
	..()

transformation/saiyan/transform(mob/user, forceTrans)
	var/was = is_active
	. = ..()
	if(aurafx_tier && user && user.aurafx_rig && !was && is_active)
		user.aurafx_rig.ignite = aurafx_tier

transformation/saiyan/revert(mob/user)
	var/was = is_active
	. = ..()
	if(aurafx_tier && user && user.aurafx_rig && was && !is_active)
		user.aurafx_rig.exit = AURAFX_EXIT_FADE

mob/Players/AppearanceOff()
	if(aurafx_rig)
		aurafx_rig.want = 0
		aurafx_rig.form = 0
		aurafx_rig.exit = AURAFX_EXIT_NOW
	..()

mob/Players/Logout()
	if(aurafx_rig) aurafx_rig.Kill()
	..()

mob/Players/AuraArtIcon()
	. = ..()
	if(!. && aurafx_rig && (aurafx_rig.shown || aurafx_rig.mode != AURAFX_M_OFF)) . = aurafx_rig.art

/datum/aurafx_rig
	var
		mob/M
		want = 0
		exit = AURAFX_EXIT_FADE
		form = 0
		shown = 0
		ignite = 0
		art
		mode = AURAFX_M_OFF
		t_mode = 0
		hidden = 0
		night = 0
		night_at = 0
		facing = SOUTH
		grow = 1
		gi = 1
		idle0 = 0
		t_ign = -1
		ign_kind = 0
		ign_done = 0
		list/pieces = list()
		obj/aurafx/paint/hp
		obj/aurafx/light/hl
		obj/aurafx/apart/ibp
		obj/aurafx/light/ibl
		obj/aurafx/apart/ifp
		obj/aurafx/light/ifl
		obj/aurafx/copy/engulf
		obj/aurafx/copy/bloom
		obj/aurafx/copy/rim
		obj/aurafx/keep/keep
		list/kept

/datum/aurafx_rig/proc/Facing4(d)
	if(d & EAST) return EAST
	if(d & WEST) return WEST
	if(d & NORTH) return NORTH
	return SOUTH

/datum/aurafx_rig/proc/Make(path, ic, lay, px, py, under = 0)
	var/obj/aurafx/O = new path
	O.icon = ic
	O.layer = lay
	O.pixel_x = px
	O.pixel_y = py
	if(under) O.vis_flags |= VIS_UNDERLAY
	pieces += O
	return O

/datum/aurafx_rig/proc/Put(obj/aurafx/O)
	if(!O) return
	if(!O.on)
		O.on = 1
		if(!hidden && M) M.vis_contents += O
	if(night && !O.stamp && Stampable(O)) StampOn(O)

/datum/aurafx_rig/proc/Take(obj/aurafx/O)
	if(!O || !O.on) return
	O.on = 0
	if(M) M.vis_contents -= O
	animate(O)

/datum/aurafx_rig/proc/Drop(obj/aurafx/O)
	if(!O) return
	Take(O)
	if(O.stamp)
		O.vis_contents -= O.stamp
		O.stamp = null
	pieces -= O

/datum/aurafx_rig/proc/Stampable(obj/aurafx/O)
	return !istype(O, /obj/aurafx/copy) && !istype(O, /obj/aurafx/spark)

/datum/aurafx_rig/proc/StampOn(obj/aurafx/O)
	if(O.stamp) return
	var/obj/aurafx/stamp/S = new
	AuraFXStampConfig(S, O.lit)
	O.stamp = S
	O.vis_contents += S

/datum/aurafx_rig/proc/StampOff(obj/aurafx/O)
	if(!O.stamp) return
	O.vis_contents -= O.stamp
	O.stamp = null

/datum/aurafx_rig/proc/NightTick(now)
	if(now < night_at) return
	night_at = now + 20
	var/turf/T = get_turf(M)
	var/fl = glob ? clamp(glob.LIGHT_DAY_STRENGTH, 0, 0.35) : 0.1
	var/n = (T && glob && glob.LIGHTING && glob.EMISSIVES && LightRenderStrength(T) >= fl + 0.1) ? 1 : 0
	if(n == night) return
	night = n
	for(var/obj/aurafx/O in pieces)
		if(!Stampable(O)) continue
		if(night && O.on) StampOn(O)
		else if(!night) StampOff(O)

/datum/aurafx_rig/proc/Hide(h)
	if(h == hidden) return
	hidden = h
	for(var/obj/aurafx/O in pieces)
		if(!O.on) continue
		if(hidden) M.vis_contents -= O
		else M.vis_contents += O
	if(keep)
		if(hidden) M.vis_contents -= keep
		else M.vis_contents += keep

/datum/aurafx_rig/proc/KeepArt(list/states)
	if(!keep)
		keep = new
		kept = list()
		if(!hidden && M) M.vis_contents += keep
	var/list/add = list()
	for(var/st in states)
		if(kept[st]) continue
		kept[st] = 1
		add += image(aurafx_art_ic[st], icon_state = st)
	if(add.len) keep.overlays += add

/datum/aurafx_rig/proc/KeepOff()
	if(!keep) return
	if(M) M.vis_contents -= keep
	keep.overlays = null
	keep = null
	kept = null

/datum/aurafx_rig/proc/Kill()
	for(var/obj/aurafx/O in pieces.Copy())
		Drop(O)
	pieces = list()
	KeepOff()
	SparksOff()
	aurafx_rigs -= src
	var/mob/W = M
	M = null
	if(W && W.aurafx_rig == src)
		W.aurafx_rig = null
		W.AuraLightSync()

/datum/aurafx_rig/proc/HeadMake()
	if(!hp) hp = Make(/obj/aurafx/paint, null, AURAFX_L_HEADP, aurafx_idle_px, aurafx_idle_py)
	if(!hl) hl = Make(/obj/aurafx/light, null, AURAFX_L_HEADL, aurafx_idle_px, aurafx_idle_py)

/datum/aurafx_rig/proc/HeadShow(st, d)
	HeadMake()
	for(var/obj/aurafx/O in list(hp, hl))
		animate(O)
		AuraFXPlaceArt(O, "[st][O == hp ? "p" : "l"]", aurafx_idle_px, aurafx_idle_py)
		O.dir = d
		O.alpha = 255
		O.transform = null
		Put(O)

/datum/aurafx_rig/proc/HeadOff()
	Take(hp)
	Take(hl)

/datum/aurafx_rig/proc/GrowIndex()
	return clamp(round((grow - 1) / 0.05, 1) + 1, 1, aurafx_grow_states.len)

/datum/aurafx_rig/proc/SetMode(m, now)
	mode = m
	t_mode = now

/datum/aurafx_rig/proc/StartIdle(now)
	SetMode(AURAFX_M_IDLE, now)
	gi = GrowIndex()
	idle0 = now
	HeadShow(aurafx_grow_states[gi], facing)
	SparkRegion()

/datum/aurafx_rig/proc/StartAppear(now)
	FlyDrop()
	SetMode(AURAFX_M_APPEAR, now)
	HeadShow("a", facing)

/datum/aurafx_rig/proc/StartFade(now)
	FlyDrop()
	IgniteDrop()
	var/ph = ((now - idle0) % aurafx_idle_loop + aurafx_idle_loop) % aurafx_idle_loop
	var/i = round(ph / 4, 1) % 4
	HeadShow(aurafx_fade_states[i + 1], facing)
	if(gi > 1)
		var/matrix/X = AuraFXTierM(gi, facing)
		hp.transform = X
		hl.transform = X
		animate(hp, transform = matrix(), time = aurafx_fade_ticks * world.tick_lag)
		animate(hl, transform = matrix(), time = aurafx_fade_ticks * world.tick_lag)
	grow = 1
	SetMode(AURAFX_M_FADE, now)
	SparkRegion()

/datum/aurafx_rig/proc/StartIgnite(now, burst)
	IgniteDrop()
	ign_kind = burst ? 2 : 1
	t_ign = now
	ign_done = 0
	var/pre = burst ? "b" : "i"
	ibp = Make(/obj/aurafx/apart, null, AURAFX_L_IGN_BACKP, aurafx_ign_px, aurafx_ign_py, 1)
	ibl = Make(/obj/aurafx/light, null, AURAFX_L_IGN_BACKL, aurafx_ign_px, aurafx_ign_py, 1)
	ifp = Make(/obj/aurafx/apart, null, AURAFX_L_IGN_FRONTP, aurafx_ign_px, aurafx_ign_py)
	ifl = Make(/obj/aurafx/light, null, AURAFX_L_IGN_FRONTL, aurafx_ign_px, aurafx_ign_py)
	AuraFXPlaceArt(ibp, "[pre]bp", aurafx_ign_px, aurafx_ign_py)
	AuraFXPlaceArt(ibl, "[pre]bl", aurafx_ign_px, aurafx_ign_py)
	AuraFXPlaceArt(ifp, "[pre]fp", aurafx_ign_px, aurafx_ign_py)
	AuraFXPlaceArt(ifl, "[pre]fl", aurafx_ign_px, aurafx_ign_py)
	for(var/obj/aurafx/O in list(ibp, ibl, ifp, ifl))
		Put(O)
	if(!burst)
		FlyDrop()
		HeadOff()
		SetMode(AURAFX_M_IGNITE, now)

/datum/aurafx_rig/proc/IgniteDrop()
	for(var/obj/aurafx/O in list(ibp, ibl, ifp, ifl, engulf, bloom, rim))
		Drop(O)
	ibp = null
	ibl = null
	ifp = null
	ifl = null
	engulf = null
	bloom = null
	rim = null
	t_ign = -1

/datum/aurafx_rig/proc/CopyLook(obj/aurafx/copy/C)
	C.appearance = M.appearance
	C.vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR
	C.filters = null
	C.transform = null
	C.pixel_x = 0
	C.pixel_y = 0
	C.pixel_z = 0
	C.pixel_w = 0
	C.mouse_opacity = 0
	C.plane = FLOAT_PLANE
	C.invisibility = 0
	C.maptext = null
	C.render_target = null
	C.render_source = null
	var/list/ko = list()
	for(var/o in M.overlays)
		var/image/I = o
		if(!I) continue
		if(M.shadow_excl && M.shadow_excl[o]) continue
		if(I.blend_mode != BLEND_DEFAULT && I.blend_mode != BLEND_OVERLAY) continue
		ko += o
	C.overlays = ko
	var/list/ku = list()
	for(var/u in M.underlays)
		var/image/I = u
		if(!I) continue
		if(M.shadow_excl && M.shadow_excl[u]) continue
		if(I.blend_mode != BLEND_DEFAULT && I.blend_mode != BLEND_OVERLAY) continue
		ku += u
	C.underlays = ku

/datum/aurafx_rig/proc/RimStart()
	rim = new /obj/aurafx/copy
	CopyLook(rim)
	rim.layer = AURAFX_L_RIM
	rim.appearance_flags = KEEP_TOGETHER | KEEP_APART | RESET_COLOR
	rim.blend_mode = BLEND_ADD
	rim.color = aurafx_black_m
	rim.filters = filter(type = "outline", size = 1, color = rgb(255, 217, 102))
	rim.alpha = 0
	pieces += rim
	Put(rim)
	animate(rim, alpha = 89, time = 2, easing = SINE_EASING)
	animate(alpha = 89, time = 1.1)
	animate(alpha = 0, time = 0.8)

/datum/aurafx_rig/proc/EngulfStart()
	engulf = new /obj/aurafx/copy
	CopyLook(engulf)
	engulf.layer = AURAFX_L_ENGULF
	engulf.appearance_flags = KEEP_TOGETHER
	engulf.blend_mode = BLEND_DEFAULT
	engulf.color = aurafx_hot_m
	engulf.alpha = 0
	pieces += engulf
	Put(engulf)
	animate(engulf, alpha = 219, time = 1.2)
	animate(alpha = 219, time = 0.8)
	animate(alpha = 0, color = aurafx_cool_m, time = 1.4, easing = SINE_EASING)
	bloom = new /obj/aurafx/copy
	CopyLook(bloom)
	bloom.layer = AURAFX_L_BLOOM
	bloom.appearance_flags = KEEP_TOGETHER | KEEP_APART | RESET_COLOR
	bloom.blend_mode = BLEND_ADD
	bloom.color = aurafx_hot_m
	bloom.filters = filter(type = "blur", size = 1.6)
	bloom.alpha = 0
	pieces += bloom
	Put(bloom)
	animate(bloom, alpha = 115, time = 1.2)
	animate(alpha = 115, time = 0.8)
	animate(alpha = 0, color = aurafx_cool_m, time = 1.4, easing = SINE_EASING)

/datum/aurafx_rig/proc/IgniteEvent(e, bit, at)
	if(e < at || (ign_done & bit)) return 0
	ign_done |= bit
	return 1

/datum/aurafx_rig/proc/IgniteTick(now)
	if(t_ign < 0) return
	var/e = now - t_ign
	if(ign_kind == 1)
		if(IgniteEvent(e, 1, 7) && !hidden) RimStart()
		if(IgniteEvent(e, 2, 13) && !hidden) EngulfStart()
		if(IgniteEvent(e, 4, 16))
			Drop(rim)
			rim = null
			if(mode == AURAFX_M_IGNITE) HeadShow("r", facing)
		if(IgniteEvent(e, 8, 20))
			Drop(engulf)
			Drop(bloom)
			engulf = null
			bloom = null
		if(IgniteEvent(e, 16, aurafx_idle_at) && mode == AURAFX_M_IGNITE) StartIdle(now)
	if(e >= (ign_kind == 1 ? aurafx_ign_ticks : aurafx_burst_ticks))
		IgniteDrop()

/datum/aurafx_rig/proc/Reconcile(now)
	if(want && !shown)
		shown = want
		if(hidden)
			IgniteDrop()
			StartIdle(now)
		else if(ignite)
			grow = 1
			StartIgnite(now, 0)
		else
			StartAppear(now)
		ignite = 0
		M.AuraLightSync()
		return
	if(want && shown && want != shown)
		var/up = want > shown
		shown = want
		if(up && ignite && !hidden && mode != AURAFX_M_IGNITE) StartIgnite(now, 1)
		ignite = 0
		return
	if(!want && shown)
		shown = 0
		ignite = 0
		if(exit == AURAFX_EXIT_NOW || hidden || mode == AURAFX_M_IGNITE)
			ClearHead(now)
		else
			StartFade(now)
		exit = AURAFX_EXIT_FADE
		return
	ignite = 0

/datum/aurafx_rig/proc/ClearHead(now)
	FlyDrop()
	IgniteDrop()
	HeadOff()
	KeepOff()
	grow = 1
	SetMode(AURAFX_M_OFF, now)
	M.AuraLightSync()

/datum/aurafx_rig/proc/ModeTick(now)
	var/e = now - t_mode
	switch(mode)
		if(AURAFX_M_APPEAR)
			if(e >= aurafx_appear_ticks) StartIdle(now)
		if(AURAFX_M_FADE)
			if(e >= aurafx_fade_ticks)
				HeadOff()
				KeepOff()
				SetMode(AURAFX_M_OFF, now)
				M.AuraLightSync()

/datum/aurafx_rig/proc/FacingTick()
	var/f = Facing4(M.dir)
	if(f == facing) return
	facing = f
	if(hp) hp.dir = f
	if(hl) hl.dir = f

/datum/aurafx_rig/proc/GrowTick(now)
	if(M.ChargingEnergy || M.PoweringUp)
		grow = min(1.7, grow + 0.005)
	else
		grow = max(1, grow - 0.0875)
	if(mode != AURAFX_M_IDLE) return
	if((now - idle0) % aurafx_swap_ticks) return
	var/ni = GrowIndex()
	if(ni == gi) return
	gi = ni
	idle0 = now
	AuraFXPlaceArt(hp, "[aurafx_grow_states[gi]]p", aurafx_idle_px, aurafx_idle_py)
	AuraFXPlaceArt(hl, "[aurafx_grow_states[gi]]l", aurafx_idle_px, aurafx_idle_py)
	SparkRegion()

/datum/aurafx_rig/proc/Tick(now)
	if(!M || !AuraFXOn())
		Kill()
		return
	Hide(M.invisibility > 0 || M.alpha < 40 || M.AdminInviso || !isturf(M.loc))
	Reconcile(now)
	IgniteTick(now)
	ModeTick(now)
	FacingTick()
	Motion(now)
	GrowTick(now)
	SparkTick(now)
	NightTick(now)
	if(!shown && !form && mode == AURAFX_M_OFF && t_ign < 0) Kill()

proc/AuraFXRestoreAll()
	for(var/mob/Players/P in world)
		var/transformation/saiyan/D = null
		if(P.race && P.transActive && P.race.transformations && P.transActive <= P.race.transformations.len)
			D = P.race.transformations[P.transActive]
		if(!istype(D) || !D.aurafx_tier) continue
		if(glob.AURAFX)
			var/had = D.form_aura && (D.form_aura.appearance in P.overlays)
			D.remove_visuals(P, 1, 0, 1)
			D.apply_visuals(P, had ? 1 : 0, 0, 1)
		else
			var/had = P.aurafx_rig && P.aurafx_rig.want
			if(P.aurafx_rig) P.aurafx_rig.Kill()
			D.apply_visuals(P, had ? 1 : 0, 0, 1)

/mob/Admin2/verb/Aura_FX_Toggle()
	set category = "Admin"
	set name = "Aura FX Toggle"
	glob.AURAFX = !glob.AURAFX
	AuraFXRestoreAll()
	src << "Aura FX: [glob.AURAFX ? "ON" : "OFF"] (assets [AURAFX_ASSETS ? "present" : "missing"])."
	Log("Admin", "[ExtractInfo(src)] set aura fx to [glob.AURAFX].")

/mob/Admin2/verb/Aura_FX_Debug()
	set category = "Admin"
	set name = "Aura FX Debug"
	var/datum/aurafx_rig/R = aurafx_rig
	if(!R)
		src << "Aura FX: no rig on you. glob=[glob.AURAFX] assets=[AURAFX_ASSETS] rigs=[aurafx_rigs.len]"
		return
	src << "Aura FX rig: want=[R.want] shown=[R.shown] form=[R.form] mode=[R.mode] ign=[R.t_ign] grow=[R.grow] gi=[R.gi] facing=[R.facing] hidden=[R.hidden] night=[R.night] pieces=[R.pieces.len] kept=[R.kept ? R.kept.len : 0] travel=[R.travel] rigs=[aurafx_rigs.len] errors=[aurafx_errors] [aurafx_last_error]"
