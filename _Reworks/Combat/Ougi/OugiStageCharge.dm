#if fexists("../../../Icons/Private/Ougi/charge/core_star.dmi") || fexists("Icons/Private/Ougi/charge/core_star.dmi")
#define OUGI_CHARGE_CORE_ART 'Icons/Private/Ougi/charge/core_star.dmi'
#else
#define OUGI_CHARGE_CORE_ART ENERGYFX_ORB_NOVAMISC_32X32
#endif
#define OUGI_CHARGE_CORE_IN_DS 2
#define OUGI_CHARGE_CORE_PULSE 1.12
#define OUGI_CHARGE_REACH_BASE 78
#define OUGI_CHARGE_REACH_MIN 24
#define OUGI_CHARGE_REACH_MAX 640

/datum/ougi_charge
	var
		mob/M
		dx = 0
		dy = 0
		radius = 16
		list/colors
		obj/Effects/OugiFX/scene_piece/hand
		obj/Effects/OugiFX/scene_piece/core
		datum/energyfx_streaks/streaks
		datum/beamfx/comets
		core_icon
		core_state = ""
		core_scale = 1
		core_tint = 1
		live = 1

/datum/ougi_scene
	var/list/ougi_charges

/datum/ougi_scene/DoOp(op, list/a)
	if(op == "charge") return OpCharge(a)
	return ..()

/datum/ougi_scene/proc/OugiChargeColors(list/a)
	var/row = ArgText(a, "row", null)
	if(istext(row)) row = text2path(row)
	if(row && ispath(row, /obj/Skills))
		var/obj/Skills/P = ougi_beam_templates["[row]"]
		if(!P)
			P = new row
			P.loc = null
			ougi_beam_templates["[row]"] = P
		var/datum/energyfx_row/R = EnergyFXRow(P)
		if(R)
			var/datum/energyfx_colors/K = (R.extra && R.extra["canon"]) ? EnergyFXResolveColors(null, null, null, R.def_main, R.def_core, R.def_glow) : EnergyFXSkillColors(P, R)
			if(K) return list(K.main255, K.core255, K.glow255)
	var/list/c = BeamFXHexRGB(ArgText(a, "color", "#ffd23a"))
	if(!islist(c)) c = list(255, 210, 58)
	return list(c)

/datum/ougi_scene/proc/OugiChargePoint(datum/ougi_charge/C)
	if(!C.M || !C.M.loc || !room || C.M.z != room.z) return null
	var/list/c = OugiSceneMobPoint(C.M)
	return list(c[1] + C.dx, c[2] + C.dy)

/datum/ougi_scene/proc/OugiChargeFollow(datum/ougi_charge/C)
	set waitfor = 0
	while(live && C.live && C.hand)
		var/list/p = OugiChargePoint(C)
		if(p)
			OugiScenePlace(C.hand, p[1], p[2], world.icon_size, world.icon_size)
			if(C.core)
				var/icon/I = icon(C.core_icon)
				OugiScenePlace(C.core, p[1], p[2], I.Width(), I.Height())
		sleep(world.tick_lag)

/datum/ougi_scene/proc/OpCharge(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors) || !room) return
	var/phase = ArgText(a, "phase", "build")
	if(!ougi_charges) ougi_charges = list()
	var/datum/ougi_charge/C = ougi_charges[M]
	if(phase == "build")
		if(C) OugiChargeDrop(C)
		C = new
		C.M = M
		C.dx = ArgNum(a, "dx", 0)
		C.dy = ArgNum(a, "dy", 0)
		C.radius = max(2, ArgNum(a, "radius", 16))
		C.colors = OugiChargeColors(a)
		C.core_icon = ArgText(a, "core", OUGI_CHARGE_CORE_ART)
		C.core_state = ArgText(a, "core_state", "star")
		C.core_scale = ArgNum(a, "core_scale", 1)
		C.core_tint = ArgNum(a, "core_tint", 1)
		ougi_charges[M] = C
		var/list/p = OugiChargePoint(C)
		if(!p) return
		C.hand = new
		if(!OugiScenePlace(C.hand, p[1], p[2], world.icon_size, world.icon_size))
			del C.hand
			return
		temp_atoms += C.hand
		var/ramp = Ds(ArgNum(a, "time", 10))
		C.streaks = EnergyFXStreaksOn(C.hand, C.colors, ramp, 0)
		var/k = C.radius / (world.icon_size / 2)
		var/reach_k = 1
		var/reach = ArgNum(a, "reach", 0)
		if(reach > 0) reach_k = clamp(reach, OUGI_CHARGE_REACH_MIN, OUGI_CHARGE_REACH_MAX) / OUGI_CHARGE_REACH_BASE
		C.comets = EFX92CometStart(C.hand, C.colors, ramp, "over", 0, list(0, 0, k, k, 0, world.icon_size, world.icon_size), reach_k, sqrt(reach_k))
		OugiChargeFollow(C)
		return
	if(!C) return
	switch(phase)
		if("implode")
			if(C.comets) EFX92CometRelease(C.comets)
			if(C.streaks) C.streaks.Off()
			OugiChargeCore(C)
		if("hold")
			OugiChargeCore(C)
		if("release")
			var/t = Ds(ArgNum(a, "time", 3))
			if(C.core)
				var/obj/O = C.core
				var/matrix/X = matrix()
				X.Scale(C.core_scale * 2.5)
				animate(O, transform = X, alpha = 0, time = t, easing = SINE_EASING | EASE_OUT)
				C.core = null
				spawn(t + world.tick_lag)
					if(O)
						temp_atoms -= O
						GfxReleaseAtom(O)
						del O
			OugiChargeDrop(C, 1)
		if("off")
			OugiChargeDrop(C)
		else
			world.log << "OUGI: charge phase [phase] is unknown in [id]; skipped"

/datum/ougi_scene/proc/OugiChargeCore(datum/ougi_charge/C)
	if(C.core || !C.core_icon) return
	var/list/p = OugiChargePoint(C)
	if(!p) return
	var/icon/I = icon(C.core_icon)
	var/obj/Effects/OugiFX/scene_piece/O = new
	O.icon = C.core_icon
	O.icon_state = C.core_state
	O.blend_mode = BLEND_ADD
	O.layer = MOB_LAYER + 0.45
	if(C.core_tint)
		var/list/tm = EFX92CometTint(C.colors)
		O.color = tm[2]
	if(!OugiScenePlace(O, p[1], p[2], I.Width(), I.Height()))
		del O
		return
	temp_atoms += O
	C.core = O
	var/matrix/S0 = matrix()
	S0.Scale(C.core_scale * 0.2)
	var/matrix/S1 = matrix()
	S1.Scale(C.core_scale)
	var/matrix/S2 = matrix()
	S2.Scale(C.core_scale * OUGI_CHARGE_CORE_PULSE)
	O.transform = S0
	O.alpha = 0
	animate(O, transform = S1, alpha = 255, time = Ds(OUGI_CHARGE_CORE_IN_DS), easing = SINE_EASING | EASE_OUT)
	animate(transform = S2, time = 2, easing = SINE_EASING, loop = -1)
	animate(transform = S1, time = 2, easing = SINE_EASING)

/datum/ougi_scene/proc/OugiChargeDrop(datum/ougi_charge/C, keep_core = 0)
	if(!C) return
	C.live = 0
	if(C.comets)
		EFX92CometDrop(C.comets)
		C.comets = null
	if(C.streaks)
		C.streaks.Drop()
		C.streaks = null
	if(C.core && !keep_core)
		temp_atoms -= C.core
		GfxReleaseAtom(C.core)
		del C.core
	C.core = null
	if(C.hand)
		temp_atoms -= C.hand
		GfxReleaseAtom(C.hand)
		del C.hand
	if(ougi_charges && C.M && ougi_charges[C.M] == C) ougi_charges -= C.M

/datum/ougi_scene/proc/OugiChargesEnd()
	if(!ougi_charges) return
	for(var/mob/M in ougi_charges.Copy())
		OugiChargeDrop(ougi_charges[M])
	ougi_charges = null

/datum/ougi_scene/LeaveRoom()
	OugiChargesEnd()
	..()

/datum/ougi_scene/End(force = 0)
	OugiChargesEnd()
	..()
