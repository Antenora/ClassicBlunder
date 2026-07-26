//light rays

globalTracker
	var/tmp
		KI_RAYS = TRUE //master switch
		KIRAY_MAX = 10 //most live carriers at once - each costs size^2 fill
		KIRAY_INTERVAL = 3 //poll cadence in ds (the mob follows via vis_contents)
		KIRAY_SIZE_REST = 12 //default RESTING ray length px when a form doesn't override it
		KIRAY_SIZE_CHARGE = 16 //px a full 0->1 power-up charge adds on top of the resting length
		KIRAY_SIZE_MAX = 30 //ceiling - a filter can't draw past its 64px host, higher just clips (bake a bigger core first)
		KIRAY_DENSITY = 10 //default ray count/fineness (whole number) when a form doesn't override
		KIRAY_THRESHOLD = 0.55 //default 0..1 spike cutoff: higher = fewer, harder, isolated spikes
		KIRAY_Y = 4 //ray origin above the carrier's center - chest, not feet
		KIRAY_FACTOR = 0.25 //0..1 length VARIANCE so the aura breathes - NOT a length knob
		KIRAY_CHURN_TIME = 8000 //ds for one full 0->1000 offset sweep (~1.25 units/s)
		KIRAY_CORE_ALPHA = 70 //peak alpha of the baked ki core - under BLOOM_THRESHOLD on purpose

var/icon/_fx_kicore_icon //rays need a non-transparent host icon; doubles as the ki haze
var/list/_kiray_objs = list() //every live carrier; swept for orphans
var/_kiray_boot = _KrBoot()

mob/var/tmp/obj/fx_kiaura/kiray_obj

//opt-in per form - nothing generic, a form has to ask. overrides at 0/null fall back to the globs
transformation
	var
		form_ki_rays = 0 //1 = this form casts ki aura rays
		form_ray_colour //null = sample the form's own aura art (form_aura_icon)
		form_ray_density = 0 //0 = glob.KIRAY_DENSITY. Higher = more, finer rays
		form_ray_threshold = 0 //0 = glob.KIRAY_THRESHOLD. Higher = fewer, harder, isolated spikes
		form_ray_size = 0 //0 = glob.KIRAY_SIZE_REST. RESTING length; the power-up charge adds on top

//escape hatch for non-transformations (Angel buffs etc); tmp, the owning buff re-applies after reboot
mob/var/tmp/ki_rays_on = 0

//soft ki haze baked dim so only the rays clear BLOOM_THRESHOLD - carrier alpha would dim the rays too
proc/_KrBuildIcon()
	var/pk = glob ? glob.KIRAY_CORE_ALPHA : 70
	var/icon/K = new('sandstorm.dmi')
	K.Scale(64, 64)
	K.DrawBox(rgb(0,0,0,0), 1, 1, 64, 64)
	for(var/py = 1, py <= 64, py++)
		for(var/px = 1, px <= 64, px++)
			var/dx = px - 32.5
			var/dy = py - 32.5
			var/d = sqrt(dx * dx + dy * dy) / 31
			if(d < 1)
				K.DrawBox(rgb(255, 255, 255, round((1 - d) * (1 - d) * (1 - d) * pk)), px, py, px, py)
	_fx_kicore_icon = K

/obj/fx_kiaura
	mouse_opacity = 0
	density = 0
	plane = 1 //the bloomed effects plane: fxplane_master blooms the bright rays for free
	layer = EFFECTS_LAYER - 0.5 //within plane 1: under beams/blasts/sparks
	pixel_x = -16 //center the 64px core on the 32px tile
	pixel_y = -16
	//KEEP_APART: mobs are KEEP_TOGETHER, without it the plane gets ignored and the rays never bloom; the RESETs keep MobColor/Enlarge off the aura
	appearance_flags = PIXEL_SCALE | KEEP_APART | NO_CLIENT_COLOR | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	Savable = 0
	gfx_transient_visual = 1
	var/tmp
		mob/owner
		ray_key //"[transActive]-[ki_rays_on]"; null = no filter yet. A change forces a full rebuild
		ray_size = -1

	New(mob/o)
		..(null) //no loc - lives in the mob's vis_contents, not its contents
		owner = o
		icon = _fx_kicore_icon

//the active transformation if it opted into rays, else null
proc/KiRayForm(mob/M)
	if(!M.transActive || !M.race || !M.race.transformations) return null
	if(M.transActive > M.race.transformations.len) return null
	var/transformation/T = M.race.transformations[M.transActive]
	return (T && T.form_ki_rays) ? T : null

//eligible = an opted-in form or ki_rays_on; a plain fighter powering up gets nothing
proc/KiRayCandidate(mob/M)
	if(!M || !M.icon) return 0
	if(M.AdminInviso || M.invisibility > 0) return 0
	if(!get_turf(M)) return 0
	if(M.PowerControl <= 25) return 0 //ki suppressed/restrained: hiding your power shows no rays
	return (KiRayForm(M) || M.ki_rays_on) ? 1 : 0

//the look only rebuilds when the form (or the manual hook) changes - never per charge tick
proc/KiRayKey(mob/M)
	return "[M.transActive]-[M.ki_rays_on]"

//0..1 power-up charge. Mirrors the PUThreshold ladder in Stats.dm - keep the two in step.
mob/proc/KiRayCharge()
	if(!PoweringUp) return 0
	var/thr = 150
	if(passive_handler)
		if(passive_handler.Get("Red Hot Rage")) thr = 300
		if(passive_handler.Get("Controlled Chaos")) thr = 200 //CC wins if both, as in Stats
	return clamp((PowerControl - 100) / max(1, thr - 100), 0, 1)

//the form's resting length, plus growth from the power-up charge so it still swells when you build ki
proc/KiRaySize(mob/M, charge01)
	var/transformation/T = KiRayForm(M)
	var/rest = (T && T.form_ray_size) ? T.form_ray_size : glob.KIRAY_SIZE_REST
	return min(glob.KIRAY_SIZE_MAX, rest + glob.KIRAY_SIZE_CHARGE * charge01)

//per-form override, else sample the form's own aura art
proc/KiRayColor(mob/M)
	var/transformation/T = KiRayForm(M)
	if(T)
		if(T.form_ray_colour) return T.form_ray_colour
		if(T.form_aura_icon)
			var/c = FxIconColor(T.form_aura_icon, T.form_aura_icon_state)
			if(c) return c
	return "#dff0ff" //cool white-blue

//build the filter once per look, then only animate size - named filters STACK on re-add, and restarting the churn every tick stutters it
mob/proc/EnsureKiRays(charge01)
	if(!_fx_kicore_icon) return
	if(!kiray_obj)
		kiray_obj = new(src)
		vis_contents += kiray_obj
		_kiray_objs |= kiray_obj
	var/obj/fx_kiaura/C = kiray_obj
	var/key = KiRayKey(src)
	var/px = round(clamp(KiRaySize(src, charge01), 0, glob.KIRAY_SIZE_MAX))
	if(C.ray_key != key)
		var/transformation/T = KiRayForm(src)
		C.ray_key = key
		C.ray_size = px
		C.filters = null //reset FIRST: a duplicate name stacks, it does not replace
		C.filters += filter(name = "kirays", type = "rays", y = glob.KIRAY_Y, size = px, \
			color = KiRayColor(src), \
			density = (T && T.form_ray_density) ? T.form_ray_density : glob.KIRAY_DENSITY, \
			threshold = (T && T.form_ray_threshold) ? T.form_ray_threshold : glob.KIRAY_THRESHOLD, \
			factor = glob.KIRAY_FACTOR)
		//can't animate filter()'s return - add it, then look the copy up by name; churn needs ANIMATION_PARALLEL or the size tween freezes it
		var/F = C.filters["kirays"]
		if(!F) return
		//keep both steps: a single-step loop=-1 doesn't loop, and the time=0 snap-back is invisible because offset wraps at 1000
		animate(F, offset = 1000, time = glob.KIRAY_CHURN_TIME, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		animate(offset = 0, time = 0)
		return
	if(px == C.ray_size) return //charge hasn't moved a whole pixel: leave the churn alone
	C.ray_size = px
	var/F = C.filters["kirays"]
	if(F) animate(F, size = px, time = glob.KIRAY_INTERVAL, flags = ANIMATION_PARALLEL)

//saves serialize vis_contents but kiray_obj is tmp, so a loaded mob can carry an orphan carrier that hazes forever - scrub it. gather then mutate
proc/KiRayScrubStale(mob/M)
	var/list/stale
	for(var/obj/fx_kiaura/s in M.vis_contents)
		if(s == M.kiray_obj) continue
		if(!stale) stale = list()
		stale += s
	if(!stale) return
	for(var/obj/fx_kiaura/s in stale)
		M.vis_contents -= s
		_kiray_objs -= s
		s.filters = null
		s.owner = null
		s.loc = null

mob/proc/ClearKiRays()
	if(!kiray_obj) return
	var/obj/fx_kiaura/C = kiray_obj
	kiray_obj = null
	_kiray_objs -= C
	vis_contents -= C
	C.filters = null //kill the loop=-1 churn before the last ref drops
	C.owner = null
	C.loc = null //never del - del scans the whole world, loc=null frees it

proc/KiRays_Process()
	if(WorldLoading) return
	if(!glob || !glob.KI_RAYS)
		_KiRaySweep(null)
		return
	//view-scoped: only mobs a client can actually see are candidates
	var/list/seen = list()
	var/list/cand = list()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		var/atom/view_anchor = GfxViewAnchor(P.client)
		if(!get_turf(view_anchor)) view_anchor = P
		for(var/mob/M in view(ClientViewRange(P.client), view_anchor))
			if(seen[M]) continue
			seen[M] = 1
			KiRayScrubStale(M) //before the candidate gate: a save-baked carrier can sit on a mob that never powers up
			if(!KiRayCandidate(M)) continue
			var/c01 = M.KiRayCharge()
			//charge ranks them; already-lit mobs get a bonus so the set doesn't churn at the cap
			cand[M] = list(round(c01 * 50) + (M.kiray_obj ? 25 : 0), c01)
	//hard cap: highest score keeps the slot, so the biggest form always wins
	var/list/lit = list()
	var/n = min(glob.KIRAY_MAX, cand.len)
	while(lit.len < n)
		var/mob/best
		var/bestscore = -1
		for(var/mob/M in cand)
			if(lit[M]) continue
			var/list/d = cand[M]
			if(d[1] > bestscore)
				bestscore = d[1]
				best = M
		if(!best) break
		lit[best] = 1
		var/list/bd = cand[best]
		best.EnsureKiRays(bd[2])
	_KiRaySweep(lit)

//drop carriers out of view/no longer charging/cut by the cap, reap orphans; gather first, then mutate
proc/_KiRaySweep(list/lit)
	var/list/reap = list()
	var/list/clear = list()
	for(var/obj/fx_kiaura/C in _kiray_objs)
		var/mob/o = C.owner
		if(!o)
			reap += C
		else if(!lit || !lit[o])
			clear |= o
	for(var/obj/fx_kiaura/C in reap)
		_kiray_objs -= C
		C.filters = null
		C.loc = null
	for(var/mob/o in clear)
		o.ClearKiRays()

proc/_KrBoot()
	spawn(90) //after fxplane's icon build, and after glob exists
		_KrBuildIcon()
		_KrLoop()
	return 1

proc/_KrLoop()
	set waitfor = 0
	set background = 1
	while(1)
		KiRays_Process()
		sleep(max(1, glob ? glob.KIRAY_INTERVAL : 3))

/mob/Admin2/verb/Ki_Rays_Toggle()
	set category = "Admin"
	set name = "Ki Rays Toggle"
	glob.KI_RAYS = !glob.KI_RAYS
	src << "Ki aura rays: [glob.KI_RAYS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set ki rays to [glob.KI_RAYS].")
