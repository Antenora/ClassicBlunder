#if fexists("../../../Icons/Private/Ougi/sparks/impact.dmi") || fexists("Icons/Private/Ougi/sparks/impact.dmi")
#define OUGI_SPARK_IMPACT_ART 'Icons/Private/Ougi/sparks/impact.dmi'
#else
#define OUGI_SPARK_IMPACT_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/blade.dmi") || fexists("Icons/Private/Ougi/sparks/blade.dmi")
#define OUGI_SPARK_BLADE_ART 'Icons/Private/Ougi/sparks/blade.dmi'
#else
#define OUGI_SPARK_BLADE_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/energy.dmi") || fexists("Icons/Private/Ougi/sparks/energy.dmi")
#define OUGI_SPARK_ENERGY_ART 'Icons/Private/Ougi/sparks/energy.dmi'
#else
#define OUGI_SPARK_ENERGY_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/guard.dmi") || fexists("Icons/Private/Ougi/sparks/guard.dmi")
#define OUGI_SPARK_GUARD_ART 'Icons/Private/Ougi/sparks/guard.dmi'
#else
#define OUGI_SPARK_GUARD_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/fire.dmi") || fexists("Icons/Private/Ougi/sparks/fire.dmi")
#define OUGI_SPARK_FIRE_ART 'Icons/Private/Ougi/sparks/fire.dmi'
#else
#define OUGI_SPARK_FIRE_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/ice.dmi") || fexists("Icons/Private/Ougi/sparks/ice.dmi")
#define OUGI_SPARK_ICE_ART 'Icons/Private/Ougi/sparks/ice.dmi'
#else
#define OUGI_SPARK_ICE_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/lightning.dmi") || fexists("Icons/Private/Ougi/sparks/lightning.dmi")
#define OUGI_SPARK_LIGHTNING_ART 'Icons/Private/Ougi/sparks/lightning.dmi'
#else
#define OUGI_SPARK_LIGHTNING_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/water.dmi") || fexists("Icons/Private/Ougi/sparks/water.dmi")
#define OUGI_SPARK_WATER_ART 'Icons/Private/Ougi/sparks/water.dmi'
#else
#define OUGI_SPARK_WATER_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/earth.dmi") || fexists("Icons/Private/Ougi/sparks/earth.dmi")
#define OUGI_SPARK_EARTH_ART 'Icons/Private/Ougi/sparks/earth.dmi'
#else
#define OUGI_SPARK_EARTH_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/wind.dmi") || fexists("Icons/Private/Ougi/sparks/wind.dmi")
#define OUGI_SPARK_WIND_ART 'Icons/Private/Ougi/sparks/wind.dmi'
#else
#define OUGI_SPARK_WIND_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/light.dmi") || fexists("Icons/Private/Ougi/sparks/light.dmi")
#define OUGI_SPARK_LIGHT_ART 'Icons/Private/Ougi/sparks/light.dmi'
#else
#define OUGI_SPARK_LIGHT_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/dark.dmi") || fexists("Icons/Private/Ougi/sparks/dark.dmi")
#define OUGI_SPARK_DARK_ART 'Icons/Private/Ougi/sparks/dark.dmi'
#else
#define OUGI_SPARK_DARK_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/space.dmi") || fexists("Icons/Private/Ougi/sparks/space.dmi")
#define OUGI_SPARK_SPACE_ART 'Icons/Private/Ougi/sparks/space.dmi'
#else
#define OUGI_SPARK_SPACE_ART OUGI_ART_FALLBACK
#endif
#if fexists("../../../Icons/Private/Ougi/sparks/time.dmi") || fexists("Icons/Private/Ougi/sparks/time.dmi")
#define OUGI_SPARK_TIME_ART 'Icons/Private/Ougi/sparks/time.dmi'
#else
#define OUGI_SPARK_TIME_ART OUGI_ART_FALLBACK
#endif

/datum/ougi_authoring_rules
	var/mockups = "Mockups are required for every Ougi \[OWNER 2026-10-19]: the choreography must be impeccable and the owner confirms the spectacle first; no scene is authored in the engine until its mockup (a frame strip of every beat over a real game frame at 1x plus a GIF at real timing, every surface named) has been approved by the owner."
	var/assets = "Asset check \[OWNER 2026-10-19]: when a surface has no readily available asset, the lane tells the owner which Ougi and which surface rather than improvising; energy, spiritual attacks and hit sparks use the engine FX pipelines (EnergyFX, AuraFX, Modern FX hitsparks), never new sheets."

/datum/ougi_scene/authored

/datum/ougi_scene/authored/proc/B(at, op, list/a)
	beats += list(list(at, op, a))

proc/OugiSceneSparkArt(fam)
	var/list/L = list("impact" = OUGI_SPARK_IMPACT_ART, "blade" = OUGI_SPARK_BLADE_ART, "energy" = OUGI_SPARK_ENERGY_ART, "guard" = OUGI_SPARK_GUARD_ART, "fire" = OUGI_SPARK_FIRE_ART, "ice" = OUGI_SPARK_ICE_ART, "lightning" = OUGI_SPARK_LIGHTNING_ART, "water" = OUGI_SPARK_WATER_ART, "earth" = OUGI_SPARK_EARTH_ART, "wind" = OUGI_SPARK_WIND_ART, "light" = OUGI_SPARK_LIGHT_ART, "dark" = OUGI_SPARK_DARK_ART, "space" = OUGI_SPARK_SPACE_ART, "time" = OUGI_SPARK_TIME_ART)
	return L[fam]

var/list/ougi_spark_size = list()

var/list/ougi_ghost_masks = list()

proc/OugiGhostMask(ic, st, list/box, mirror)
	if(!ic || box.len < 4) return null
	for(var/v in box)
		if(!isnum(v)) return null
	var/key = "[ic]|[box[1]],[box[2]],[box[3]],[box[4]]|[mirror]"
	if(key in ougi_ghost_masks) return ougi_ghost_masks[key]
	var/icon/K = icon(ic, st, SOUTH, 1)
	var/w = K ? K.Width() : 0
	var/h = K ? K.Height() : 0
	if(!w || !h)
		ougi_ghost_masks[key] = null
		return null
	var/x1 = clamp(round(min(box[1], box[3]), 1), 0, w - 1)
	var/x2 = clamp(round(max(box[1], box[3]), 1), 0, w - 1)
	var/y1 = clamp(round(min(box[2], box[4]), 1), 0, h - 1)
	var/y2 = clamp(round(max(box[2], box[4]), 1), 0, h - 1)
	if(mirror)
		var/m1 = w - 1 - x2
		x2 = w - 1 - x1
		x1 = m1
	K.DrawBox(null, 1, 1, w, h)
	K.DrawBox(rgb(255, 255, 255), x1 + 1, y1 + 1, x2 + 1, y2 + 1)
	var/r = fcopy_rsc(K)
	ougi_ghost_masks[key] = r
	return r

proc/OugiSceneSparkSize(fam)
	var/list/s = ougi_spark_size[fam]
	if(!s)
		var/icon/I = icon(OugiSceneSparkArt(fam))
		s = list(I.Width(), I.Height())
		ougi_spark_size[fam] = s
	return s

proc/OugiSceneTintMatrix(c)
	if(islist(c)) return c
	switch(c)
		if("mono") return list(0.3, 0.3, 0.3, 0.59, 0.59, 0.59, 0.11, 0.11, 0.11, 0, 0, 0)
		if("bleach") return list(0.75, 0.7, 0.62, 0.45, 0.55, 0.45, 0.12, 0.12, 0.2, 0.22, 0.2, 0.16)
		if("ember") return list(0.9, 0.35, 0.15, 0.4, 0.55, 0.2, 0.1, 0.1, 0.3, 0.08, 0.02, 0)
	return null

/obj/Effects/OugiFX/scene_piece
	layer = MOB_LAYER + 0.4
	animate_movement = NO_STEPS

/datum/ougi_scene
	var
		list/tinted
		list/tint_recs
		list/actor_tinted
		bd_loop_gen = 0
		bd_fade_t0 = 0
		bd_fade_time = 0
		bd_fade_gen = 0
		list/actor_scales
		list/actor_turns
		list/actor_walks

/datum/ougi_scene/DoOp(op, list/a)
	switch(op)
		if("actor_turn") return OpActorTurn(a)
		if("beam_hold") return OpBeamHold(a)
		if("trail") return OpTrail(a)
		if("prop") return OpProp(a)
		if("bullet") return OpBullet(a)
		if("tint") return OpTint(a)
		if("actor_tint") return OpActorTint(a)
		if("backdrop_swap") return OpBackdropSwap(a)
	return ..()

/datum/ougi_scene/OpHit(list/a)
	var/fam = ArgText(a, "spark", null)
	if(fam && !hit_done && target && target.loc && OugiSceneSparkArt(fam))
		var/mob/A = attacker
		var/list/c = OugiSceneMobPoint(target)
		var/mirror = 0
		if(A && A.loc && A.z == target.z)
			var/list/ac = OugiSceneMobPoint(A)
			mirror = (ac[1] > c[1]) ? 1 : 0
		OugiSceneSpark(fam, c[1] + (mirror ? 9 : -9), c[2] - 4, mirror)
	..()

/datum/ougi_scene/End(force = 0)
	var/list/T = tinted
	var/list/F = actor_tinted
	var/list/W = actor_walks
	actor_walks = null
	tinted = null
	tint_recs = null
	actor_tinted = null
	actor_scales = null
	actor_turns = null
	..()
	if(T)
		for(var/atom/A in T)
			animate(A)
			A.color = null
	if(F)
		for(var/mob/A in F)
			animate(A)
			A.color = null
	if(W)
		for(var/mob/A in W)
			var/list/r = W[A]
			A.glide_size = r[1]

/datum/ougi_scene/proc/OpActorTurn(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	if(!M || !(M in actors)) return
	if(!actor_turns) actor_turns = list()
	actor_turns[M] = ArgNum(a, "angle", 0)
	// "ease" takes any easing name; the older "easing" arg still works
	ActorPose(M, Ds(ArgNum(a, "time", 2)), OugiEaseFlags(ArgText(a, "ease", ArgText(a, "easing", "linear"))))

/datum/ougi_scene/proc/ActorPose(mob/M, time, easing = LINEAR_EASING)
	ActorRelay(M)

/datum/ougi_scene/proc/ActorDisp(mob/M, turf/home)
	if(!home || !M.loc || M.z != home.z) return list(0, 0)
	return list((M.x - home.x) * world.icon_size + M.step_x, (M.y - home.y) * world.icon_size + M.step_y)

/datum/ougi_scene/proc/ActorWalk(mob/M, turf/home, ex, ey, t)
	set waitfor = 0
	if(!actor_walks) actor_walks = list()
	var/list/old = actor_walks[M]
	var/list/token = list(old ? old[1] : M.glide_size)
	actor_walks[M] = token
	var/list/d0 = ActorDisp(M, home)
	var/n = max(1, round(t / world.tick_lag, 1))
	M.glide_size = max(1, sqrt((ex - d0[1]) ** 2 + (ey - d0[2]) ** 2) / n)
	for(var/i = 1 to n)
		sleep(world.tick_lag)
		if(!live || !M.loc || !actor_walks || actor_walks[M] != token) return
		var/wx = (home.x - 1) * world.icon_size + round(d0[1] + (ex - d0[1]) * i / n, 1)
		var/wy = (home.y - 1) * world.icon_size + round(d0[2] + (ey - d0[2]) * i / n, 1)
		var/turf/T = locate(floor(wx / world.icon_size) + 1, floor(wy / world.icon_size) + 1, home.z)
		if(!T) return
		M.loc = T
		M.step_x = wx - (T.x - 1) * world.icon_size
		M.step_y = wy - (T.y - 1) * world.icon_size
	if(actor_walks && actor_walks[M] == token)
		actor_walks -= M
		M.glide_size = token[1]

/datum/ougi_scene/proc/OugiSceneMobPoint(mob/M)
	return list(GfxCameraWorldX(M) + M.pixel_x - M.ougi_return_pixel_x, GfxCameraWorldY(M) + M.pixel_y - M.ougi_return_pixel_y)

/datum/ougi_scene/proc/OugiScenePoint(p, list/rel)
	if(islist(p))
		var/list/o = p
		var/list/b = rel ? rel : list(0, 0)
		return list(b[1] + (o.len >= 1 ? o[1] : 0), b[2] + (o.len >= 2 ? o[2] : 0))
	if(!istext(p)) return rel
	var/mob/M = null
	if(p == "attacker" || p == "target" || p == "self" || (length(p) == 2 && copytext(p, 1, 2) == "m")) M = Who(p)
	if(M && M.loc && room && M.z == room.z) return OugiSceneMobPoint(M)
	var/turf/T = MarkTurf(p)
	if(!T) return rel
	return list((T.x - 1) * world.icon_size + world.icon_size / 2, (T.y - 1) * world.icon_size + world.icon_size / 2)

/datum/ougi_scene/proc/OugiScenePlace(atom/movable/O, wx, wy, w, h)
	if(!room) return 0
	var/tx = clamp(floor(wx / world.icon_size) + 1, 1, world.maxx)
	var/ty = clamp(floor(wy / world.icon_size) + 1, 1, world.maxy)
	var/turf/T = locate(tx, ty, room.z)
	if(!T) return 0
	O.loc = T
	O.pixel_x = round(wx - (tx - 1) * world.icon_size - w / 2, 1)
	O.pixel_y = round(wy - (ty - 1) * world.icon_size - h / 2, 1)
	return 1

/datum/ougi_scene/proc/OugiSceneTemp(atom/movable/O, life)
	temp_atoms += O
	spawn(life)
		if(O)
			temp_atoms -= O
			GfxReleaseAtom(O)
			del O

/datum/ougi_scene/proc/OugiSceneSpark(fam, wx, wy, mirror = 0)
	var/art = OugiSceneSparkArt(fam)
	if(!art) return null
	var/list/sz = OugiSceneSparkSize(fam)
	var/obj/Effects/OugiFX/scene_piece/S = new
	S.icon = art
	S.icon_state = ""
	if(!OugiScenePlace(S, wx, wy, sz[1], sz[2]))
		del S
		return null
	if(mirror)
		var/matrix/M = matrix()
		M.Scale(-1, 1)
		S.transform = M
	S.layer = MOB_LAYER + 0.5
	OugiSceneTemp(S, 10)
	return S

/datum/ougi_scene/proc/OpBeamHold(list/a)
	set waitfor = 0
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	var/row = ArgText(a, "row", null)
	if(istext(row)) row = text2path(row)
	if(!row || !ispath(row, /obj/Skills/Projectile) || !room) return
	var/list/p0 = OugiScenePoint(ArgText(a, "from", "attacker"), (M && M.loc) ? OugiSceneMobPoint(M) : null)
	var/list/p1 = OugiScenePoint(ArgText(a, "to", "target"), p0)
	if(!p0 || !p1) return
	var/obj/Skills/Projectile/P = ougi_beam_templates["[row]"]
	if(!P)
		P = new row
		P.loc = null
		ougi_beam_templates["[row]"] = P
	var/datum/energyfx_row/R = EnergyFXRow(P)
	if(!R || R.look != "beam" || !glob || !glob.ENERGYFX || !BEAMFX_ASSETS) return
	var/turf/T0 = locate(floor(p0[1] / world.icon_size) + 1, floor(p0[2] / world.icon_size) + 1, room.z)
	var/turf/T1 = locate(floor(p1[1] / world.icon_size) + 1, floor(p1[2] / world.icon_size) + 1, room.z)
	var/d = get_dir(T0, T1)
	if(!d) d = EAST
	if(M) M.dir = d
	var/charge = Ds(ArgNum(a, "charge_ds", 0))
	if(charge > 0) sleep(charge)
	if(!live) return
	var/datum/energyfx_colors/C = EnergyFXSkillColors(P, R)
	beamfx_seed++
	var/seed = (round(world.time, 1) * 7 + beamfx_seed * 131) % 30000
	var/turf/H = get_step(T0, d)
	if(!H) return
	var/ox = (H.x - 1) * 32 + 16
	var/oy = (H.y - 1) * 32 + 16
	var/datum/beamfx/F = new(BeamFXDirText(d), ox, oy, room.z, max(0.25, ArgNum(a, "width", 1)), seed, C, null, null)
	F.fx_row = R
	F.owner = M
	F.caster_mob = M
	F.fx_name = R.name ? R.name : P.name
	var/key = EFX92_SKILL["[row]"]
	if(key && EFX92_ASSETS) F.RLInit(key)
	if(ArgText(a, "to", "target") == "target") F.target_mob = target
	var/reach = max(F.D, (p1[1] - ox) * F.ax + (p1[2] - oy) * F.ay)
	var/tiles = max(1, round(reach / F.D, 1))
	var/hold = Ds(ArgNum(a, "hold_ds", 20))
	var/release = Ds(ArgNum(a, "release_ds", 4))
	var/t_end = 0
	var/rel_at = 0
	F.s_travelled = 0
	F.s_firing = 1
	F.start_wt = EnergyFXNow()
	while(live && F && !F.finished)
		if(F.s_n < tiles) F.s_n++
		else if(!F.s_blocked)
			F.s_blocked = 1
			F.target_d = reach
			t_end = world.time + hold
		if(t_end && !rel_at && world.time >= t_end)
			F.s_firing = 0
			rel_at = world.time + release
		if(rel_at && world.time >= rel_at)
			F.s_dead = 1
			F.death_k = max(0, F.k)
			BeamFXAfterlife(F)
			return
		try
			F.Step()
		catch(var/exception/e)
			world.log << "OUGI: beam_hold step failed in [id]: [e] ([e.file]:[e.line])"
			F.Cleanup()
			return
		sleep(world.tick_lag)
	if(F && !F.finished) F.Cleanup()

/datum/ougi_scene/proc/OugiSceneSpline(list/pts, step)
	if(!pts || pts.len < 2) return pts
	var/list/out = list()
	for(var/i = 1 to pts.len - 1)
		var/list/p0 = pts[max(1, i - 1)]
		var/list/p1 = pts[i]
		var/list/p2 = pts[i + 1]
		var/list/p3 = pts[min(pts.len, i + 2)]
		var/len = sqrt((p2[1] - p1[1]) ** 2 + (p2[2] - p1[2]) ** 2)
		var/n = max(1, round(len / step, 1))
		for(var/k = 0 to n - 1)
			var/t = k / n
			var/t2 = t * t
			var/t3 = t2 * t
			var/x = 0.5 * (2 * p1[1] + (-p0[1] + p2[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2 + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3)
			var/y = 0.5 * (2 * p1[2] + (-p0[2] + p2[2]) * t + (2 * p0[2] - 5 * p1[2] + 4 * p2[2] - p3[2]) * t2 + (-p0[2] + 3 * p1[2] - 3 * p2[2] + p3[2]) * t3)
			out += list(list(x, y))
	out += list(pts[pts.len])
	return out

/datum/ougi_scene/proc/OugiScenePath(list/path, list/start)
	var/list/pts = list()
	if(start) pts += list(start)
	for(var/e in path)
		var/list/q = OugiScenePoint(e, start)
		if(q) pts += list(q)
	return pts

/datum/ougi_scene/proc/OpTrail(list/a)
	set waitfor = 0
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	var/tex = ArgText(a, "texture", null)
	var/list/path = ArgText(a, "path", null)
	if(!tex || !islist(path) || !room) return
	var/list/start = (M && M.loc && M.z == room.z) ? OugiSceneMobPoint(M) : null
	var/list/pts = OugiSceneSpline(OugiScenePath(path, start), 8)
	if(!pts || pts.len < 2) return
	var/icon/I = icon(tex)
	var/iw = I.Width()
	var/ih = I.Height()
	var/st = ArgText(a, "state", "")
	var/width = ArgNum(a, "width", 16)
	var/life = Ds(ArgNum(a, "life", 6))
	var/sweep = Ds(ArgNum(a, "time", 3))
	var/blend = ArgNum(a, "blend", BLEND_ADD)
	var/n = pts.len - 1
	var/list/slices = null
	var/total = 0
	var/arc = 0
	if(ArgText(a, "uv", null) == "along")
		slices = list()
		var/list/names = icon_states(I)
		while(("[st][slices.len + 1]") in names)
			slices += "[st][slices.len + 1]"
		if(!slices.len) slices = null
		for(var/j = 1 to n)
			var/list/p0 = pts[j]
			var/list/p1 = pts[j + 1]
			total += sqrt((p1[1] - p0[1]) ** 2 + (p1[2] - p0[2]) ** 2)
	for(var/i = 1 to n)
		if(!live) return
		var/list/q0 = pts[i]
		var/list/q1 = pts[i + 1]
		var/dx = q1[1] - q0[1]
		var/dy = q1[2] - q0[2]
		var/len = sqrt(dx * dx + dy * dy)
		arc += len
		if(len >= 0.5)
			var/obj/Effects/OugiFX/scene_piece/S = new
			S.icon = tex
			S.icon_state = slices ? slices[clamp(floor((arc - len / 2) / max(total, 1) * slices.len) + 1, 1, slices.len)] : st
			S.blend_mode = blend
			var/matrix/T = matrix()
			T.Scale((len + 1) / iw, width / ih)
			T.Turn(-arctan(dx, dy))
			S.transform = T
			if(OugiScenePlace(S, (q0[1] + q1[1]) / 2, (q0[2] + q1[2]) / 2, iw, ih)) OugiSceneTemp(S, life + sweep * (n - i) / n)
			else del S
		var/w = sweep / n
		if(w >= world.tick_lag) sleep(w)

/datum/ougi_scene/proc/OpProp(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	var/ic = ArgText(a, "icon", null)
	if(!ic || !M || !M.loc || !room) return
	var/list/c = OugiSceneMobPoint(M)
	var/icon/I = icon(ic)
	var/w = I.Width()
	var/h = I.Height()
	var/sx = c[1] + ArgNum(a, "dx", 0)
	var/sy = c[2] + ArgNum(a, "dy", 0)
	var/obj/Effects/OugiFX/scene_piece/S = new
	S.icon = ic
	S.icon_state = ArgText(a, "state", "")
	if(!OugiScenePlace(S, sx, sy, w, h))
		del S
		return
	var/time = Ds(ArgNum(a, "time", 6))
	var/life = Ds(ArgNum(a, "life", 10))
	var/to_mark = ArgText(a, "throw_to", null)
	if(to_mark)
		var/list/e = OugiScenePoint(to_mark, c)
		var/px = S.pixel_x + (e[1] - sx)
		var/py = S.pixel_y + (e[2] - sy)
		var/peak = max(S.pixel_y, py) + ArgNum(a, "arc", 32)
		animate(S, pixel_x = px, time = time)
		animate(S, pixel_y = peak, time = time / 2, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
		animate(pixel_y = py, time = time / 2, easing = SINE_EASING | EASE_IN)
		life += time
	OugiSceneTemp(S, life)
	return S

/datum/ougi_scene/proc/OpBullet(list/a)
	set waitfor = 0
	var/ic = ArgText(a, "icon", null)
	var/list/path = ArgText(a, "path", null)
	if(!ic || !islist(path) || !room) return
	var/list/start = OugiScenePoint(ArgText(a, "from", "attacker"), null)
	var/list/pts = OugiScenePath(path, start)
	if(!pts || pts.len < 2) return
	var/icon/I = icon(ic)
	var/w = I.Width()
	var/h = I.Height()
	var/speed = max(1, ArgNum(a, "speed", 64))
	var/fam = ArgText(a, "spark", null)
	var/obj/Effects/OugiFX/scene_piece/S = new
	S.icon = ic
	S.icon_state = ArgText(a, "state", "")
	var/list/p0 = pts[1]
	if(!OugiScenePlace(S, p0[1], p0[2], w, h))
		del S
		return
	temp_atoms += S
	var/bx = S.pixel_x - p0[1]
	var/by = S.pixel_y - p0[2]
	for(var/i = 2 to pts.len)
		if(!live || !S) return
		var/list/q0 = pts[i - 1]
		var/list/q1 = pts[i]
		var/dx = q1[1] - q0[1]
		var/dy = q1[2] - q0[2]
		var/t = Ds(sqrt(dx * dx + dy * dy) / speed)
		var/matrix/T = matrix()
		T.Turn(-arctan(dx, dy))
		S.transform = T
		animate(S, pixel_x = bx + q1[1], pixel_y = by + q1[2], time = t, flags = ANIMATION_PARALLEL)
		if(t > 0) sleep(t)
		if(fam) OugiSceneSpark(fam, q1[1], q1[2], dx < 0)
	var/life = Ds(ArgNum(a, "life", 2))
	if(life > 0) sleep(life)
	if(S)
		temp_atoms -= S
		GfxReleaseAtom(S)
		del S

/datum/ougi_scene/proc/OpTint(list/a)
	set waitfor = 0
	if(!room || !room.swapmap) return
	var/list/M = OugiSceneTintMatrix(ArgText(a, "color", "mono"))
	if(!M) return
	var/ti = Ds(ArgNum(a, "in", 2))
	var/th = Ds(ArgNum(a, "hold", 10))
	var/tout = Ds(ArgNum(a, "out", 2))
	var/list/L = list()
	var/swapmap/S = room.swapmap
	for(var/turf/T in block(locate(S.x1, S.y1, S.z1), locate(S.x2, S.y2, S.z1)))
		L += T
	for(var/atom/movable/O in temp_atoms)
		L += O
	if(ArgNum(a, "actors", 1))
		for(var/mob/A in actors)
			if(!actor_tinted || !actor_tinted[A])
				L += A
	tinted = L
	if(!tint_recs) tint_recs = list()
	tint_recs += list(list(world.time, ti, th, tout, M, null, L))
	var/list/I = list(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
	for(var/atom/A in L)
		if(istype(A, /obj/ougi_actor))
			var/obj/ougi_actor/G = A
			G.GhostTint(M, ti, th, tout)
			continue
		if(A in actors)
			ActorRelay(A)
			continue
		if(isturf(A)) animate(A, color = M, time = ti)
		else animate(A, color = M, time = ti, tag = "ougi_tint")
		animate(color = M, time = th)
		animate(color = I, time = tout)
	for(var/client/C in clients)
		for(var/obj/O in OugiClientBackdropSets(C))
			animate(O, color = M, time = ti)
			animate(color = M, time = th)
			animate(color = I, time = tout)
	sleep(ti + th + tout + world.tick_lag)
	if(tinted == L)
		for(var/atom/A in L)
			A.color = null
			if(istype(A, /obj/ougi_actor))
				var/obj/ougi_actor/G = A
				G.GhostUntint()
		for(var/client/C in clients)
			for(var/obj/O in OugiClientBackdropSets(C))
				O.color = null
		tinted = null

proc/OugiSceneTintMix(list/a, list/b, p)
	var/list/o = list()
	for(var/i in 1 to 12)
		o += a[i] + (b[i] - a[i]) * p
	return o

proc/OugiGhostFold(list/m, a)
	return list(m[1], m[2], m[3], 0, m[4], m[5], m[6], 0, m[7], m[8], m[9], 0, 0, 0, 0, a / 255, m[10], m[11], m[12], 0)

/obj/ougi_actor/proc/GhostAlphaAt(t)
	if(ougi_ghost_life <= 0) return 0
	return clamp(ougi_ghost_alpha * (1 - (t - ougi_ghost_born) / ougi_ghost_life), 0, 255)

/obj/ougi_actor/proc/GhostTint(list/M, ti, th, tout)
	var/t0 = world.time
	var/list/I = list(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
	var/list/S0 = ougi_ghost_color || I
	var/end = ougi_ghost_born + ougi_ghost_life - t0
	var/list/ends = list(ti, ti + th, ti + th + tout)
	var/list/starts = list(S0, M, M)
	var/list/goals = list(M, M, I)
	animate(src)
	alpha = 255
	color = OugiGhostFold(ti > 0 ? S0 : M, GhostAlphaAt(t0))
	var/prev = 0
	var/first = 1
	for(var/i = 1 to 3)
		if(prev >= end) break
		var/k = ends[i]
		var/list/c = goals[i]
		if(k > end)
			c = OugiSceneTintMix(starts[i], c, (end - prev) / (k - prev))
			k = end
		if(k <= prev && i < 3) continue
		c = OugiGhostFold(c, GhostAlphaAt(t0 + k))
		if(first) animate(src, color = c, time = k - prev)
		else animate(color = c, time = k - prev)
		first = 0
		prev = k

/obj/ougi_actor/proc/GhostUntint()
	var/t = world.time
	animate(src)
	color = null
	alpha = round(GhostAlphaAt(t), 1)
	var/left = ougi_ghost_born + ougi_ghost_life - t
	if(left > 0) animate(src, alpha = 0, time = left)

proc/OugiSceneTintRecAt(list/r, t)
	var/e = (isnull(t) ? world.time : t) - r[1]
	var/ti = r[2]
	var/th = r[3]
	var/tout = r[4]
	if(e < 0 || e > ti + th + tout) return null
	var/list/I = list(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
	if(e < ti) return OugiSceneTintMix(r[6] ? r[6] : I, r[5], e / ti)
	if(e < ti + th) return r[5]
	return OugiSceneTintMix(I, r[5], tout ? 1 - (e - ti - th) / tout : 0)

/datum/ougi_scene/BackdropLook(t)
	if(!tint_recs || !tint_recs.len) return null
	var/list/r = tint_recs[tint_recs.len]
	if(world.time > r[1] + r[2] + r[3] + r[4] + world.tick_lag) return null
	var/list/c = OugiSceneTintRecAt(r, t)
	return c ? c : list(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)

/datum/ougi_scene/BackdropFadeApply(client/C)
	if(!C) return
	var/left = bd_fade_t0 + bd_fade_time - world.time
	if(bd_fade_time <= 0 || left <= 0)
		if(C.ougi_backdrop_fade) C.screen -= C.ougi_backdrop_fade
		return
	if(!C.ougi_backdrop_fade) C.ougi_backdrop_fade = new
	var/obj/F = C.ougi_backdrop_fade
	var/p = 1 - left / bd_fade_time
	animate(F)
	F.alpha = round(255 * (backdrop ? p : 1 - p), 1)
	C.screen |= F
	animate(F, alpha = backdrop ? 255 : 0, time = left)

proc/OugiClientBackdropSets(client/C)
	return (C.ougi_backdrop_objs || list()) + (C.ougi_backdrop_old || list())

/datum/ougi_scene/proc/FighterTintRec(mob/A)
	var/list/r = actor_tinted ? actor_tinted[A] : null
	if(r && OugiSceneTintRecAt(r)) return r
	for(var/i = tint_recs ? tint_recs.len : 0, i >= 1, i--)
		var/list/q = tint_recs[i]
		var/list/L = q[7]
		if(A in L) return q
	return null

/datum/ougi_scene/proc/FighterTintNow(mob/A)
	var/list/r = FighterTintRec(A)
	return r ? OugiSceneTintRecAt(r) : null

/datum/ougi_scene/proc/OpActorTint(list/a)
	set waitfor = 0
	var/list/M = OugiSceneTintMatrix(ArgText(a, "color", "mono"))
	if(!M) return
	var/who = ArgText(a, "who", "both")
	var/list/F = list()
	for(var/n in (who == "both" ? list("attacker", "target") : list(who)))
		var/mob/A = Who(n)
		if(A && A.loc && !(A in F)) F += A
	if(!F.len) return
	var/ti = Ds(ArgNum(a, "in", 2))
	var/th = Ds(ArgNum(a, "hold", 10))
	var/tout = Ds(ArgNum(a, "out", 2))
	var/list/I = list(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
	if(!actor_tinted) actor_tinted = list()
	var/list/mine = list()
	for(var/mob/A in F)
		var/list/S = FighterTintNow(A)
		var/list/r = list(world.time, ti, th, tout, M, S)
		mine[A] = r
		actor_tinted[A] = r
		for(var/list/q in tint_recs)
			var/list/L = q[7]
			L -= A
		if(A in actors)
			ActorRelay(A)
			continue
		A.color = S
		animate(A, color = M, time = ti, tag = "ougi_tint")
		animate(color = M, time = th)
		animate(color = I, time = tout)
	sleep(ti + th + tout + world.tick_lag)
	if(!actor_tinted) return
	for(var/mob/A in mine)
		if(actor_tinted[A] == mine[A])
			actor_tinted -= A
			A.color = null

/datum/ougi_scene/proc/OpBackdropSwap(list/a)
	var/datum/ougi_backdrop/N = OugiBackdropById(ArgText(a, "backdrop", null))
	var/t = Ds(ArgNum(a, "time", 6))
	var/datum/ougi_backdrop/P = backdrop
	backdrop = N
	if(N && !bd_t0 && room)
		var/turf/M = room.Mark("camera")
		if(M)
			bd_rest_x = (M.x - 1) * world.icon_size + world.icon_size / 2
			bd_rest_y = (M.y - 1) * world.icon_size + world.icon_size / 2
		bd_t0 = world.time
		bd_horizon = OugiRoomHorizonPx(room)
	bd_fade_t0 = world.time
	bd_fade_time = t
	bd_old = t > 0 ? P : null
	bd_fade_gen++
	for(var/client/C in clients)
		if(!C.ougi_in_display) continue
		OugiClientEndBackdropFade(C)
		var/list/old = C.ougi_backdrop_objs
		C.ougi_backdrop_objs = null
		if(N) OugiClientBackdrop(C, src)
		if(old && bd_old)
			if(N)
				for(var/obj/O in old)
					O.plane = OUGI_BACKDROP_OLD_PLANE
			C.ougi_backdrop_old = old
		else if(old)
			for(var/obj/O in old)
				C.screen -= O
				del O
		if(!N) BackdropFadeApply(C)
	if(t > 0) BackdropFadeEnd(bd_fade_gen, t + world.tick_lag)
	if(N && !P)
		bd_loop_gen++
		spawn() BackdropLoop()

/datum/ougi_scene/proc/BackdropFadeEnd(g, delay)
	set waitfor = 0
	sleep(delay)
	if(!live || g != bd_fade_gen) return
	bd_old = null
	for(var/client/C in clients)
		OugiClientEndBackdropFade(C)
