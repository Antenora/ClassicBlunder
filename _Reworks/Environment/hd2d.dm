// structure sun shadows, light shafts, fire embers, vignette, farblur, bloom, color grading

#define FARBLUR_PLANE 30 //drawn above the world, below the HUD

globalTracker
	var/tmp
		WALL_SHADOWS = TRUE //stacked wall turfs cast sun/moon shadows, length scales with stack height
		WALLSHADOW_LEN = 1.15 //tiles of shadow per stacked row at the longest sun angle
		WALLSHADOW_ALPHA = 1.0 //multiplier on the mob-shadow alpha so walls match the scene
		WALLSHADOW_MIN_ROWS = 1
		WALLSHADOW_MAX_ROWS = 4
		LIGHT_SHAFTS = TRUE //god rays, angle follows the sun; gated by the camera area's sees_sky
		SHAFT_ALPHA = 120
		MOON_SHAFTS = TRUE //full-moon nights only (MoonEventK gates the alpha)
		EMBERS = TRUE //drifting motes off placed fire lights, colored by the flame
		EMBER_RATE = 1.0
		FARBLUR = TRUE //world switch; the per-player pref defaults OFF (opt-in)
		FARBLUR_SOFT_SIZE = 1 //three graded tiers - two read as a hard band
		FARBLUR_SOFT_BAND = 0.50 //fraction of screen height (from top) where this tier fades out
		FARBLUR_MILD_SIZE = 2
		FARBLUR_MID = 0.38
		FARBLUR_HEAVY_SIZE = 3.5
		FARBLUR_TOP = 0.26
		FARBLUR_BLOOM = FALSE //night experiment ONLY - daylight terrain crosses the threshold and halos everything
		FARBLUR_BLOOM_SIZE = 9
		FARBLUR_BLOOM_THRESHOLD = 175
		VIGNETTE = TRUE
		VIGNETTE_ALPHA = 66 //corner ceiling by day
		VIGNETTE_NIGHT_BOOST = 1.35 //corners breathe darker after dark
		AMBIENT_FX = TRUE //zone ambience: fireflies/leaves/motes/ash/dust/bubbles per env profile
		AMBIENT_DENSITY = 1 //global multiplier on ambient particle counts
		FIREFLY_SEED_MOD = 11 //1 in N open tiles hosts fireflies in firefly zones; higher = sparser
		FIREFLY_ALPHA = 235
		WATER_SPARKLE = TRUE //v2: clustered map-anchored glints (a uniform screen sheet sparkled everywhere)
		SPARKLE_ALPHA = 190
		SPARKLE_SEED_MOD = 7 //1 in N water tiles seeds a cluster; higher = sparser
		RIM_LIGHT = TRUE //lit edge on actors near placed lights, colored by the flame
		RIM_ALPHA = 110
		RIM_RANGE = 7 //tiles a light can rim from
		//no aerial haze here - screen-space haze paints over LoS blackness. don't re-add it.
		WORLD_BLOOM = TRUE //whole-scene bloom so placed fires blossom - skill-FX bloom never touches them
		WORLD_BLOOM_THRESHOLD = 205 //high: only genuinely bright pixels
		WORLD_BLOOM_SIZE = 7
		//night-gated (dark > 0.35): daylight sand crosses ANY workable threshold and halos
		COLOR_GRADE = TRUE //HD-2D grade on the world plane; the HUD (plane 100) stays clean
		GRADE_GAIN = 1.22 //contrast gain
		GRADE_BLACK = 0.03 //black floor subtracted after gain
		GRADE_WARM = 0.1 //R-over-B tilt
		GRADE_DAY_SOFTEN = 0.65 //day pulls gain+warm toward neutral; 0 = full grade all day, 1 = neutral at noon
		GRADE_CONST_SCALE = 1 //FILTER const row is NORMALIZED - 255 here blacks out the world; x255 belongs to icon MapColors


var/icon/_hd2d_wallshadow_icon
var/icon/_hd2d_shaft_icon
var/icon/_hd2d_ember_icon
var/icon/_hd2d_vignette_icon
var/icon/_hd2d_leaf_icon
var/icon/_hd2d_bubble_icon
var/list/_hd2d_glint_icons = list()
var/list/_hd2d_shaft_fit = list()

proc/Hd2dShaftIcon(spx)
	if(spx >= 512) return _hd2d_shaft_icon
	var/key = "[spx]"
	var/icon/I = _hd2d_shaft_fit[key]
	if(!I)
		I = icon(_hd2d_shaft_icon)
		I.Scale(spx, spx)
		_hd2d_shaft_fit[key] = I
	return I

proc/_Hd2dBuildIcons()
	if(_hd2d_wallshadow_icon) return
	//shadow strip: white, solid core, smooth tail - tinted/scaled per obj. y128 = wall base
	_hd2d_wallshadow_icon = new('sandstorm.dmi')
	_hd2d_wallshadow_icon.Scale(32, 128)
	for(var/sy = 1, sy <= 128, sy++)
		var/t = (128 - sy) / 127
		var/sa = 255
		if(t > 0.55)
			var/u = (t - 0.55) / 0.45
			sa = round(255 * (1 - u * u * (3 - 2 * u)))
		_hd2d_wallshadow_icon.DrawBox(rgb(255, 255, 255, sa), 1, sy, 32, sy)
	//ember mote: soft dot, (1-d)^2 falloff so the additive blend glows
	_hd2d_ember_icon = new('sandstorm.dmi')
	_hd2d_ember_icon.Scale(9, 9)
	_hd2d_ember_icon.DrawBox(rgb(0, 0, 0, 0), 1, 1, 9, 9)
	for(var/ex = 1, ex <= 9, ex++)
		for(var/ey = 1, ey <= 9, ey++)
			var/edx = ex - 5
			var/edy = ey - 5
			var/ed = sqrt(edx * edx + edy * edy) / 4.5
			if(ed >= 1) continue
			_hd2d_ember_icon.DrawBox(rgb(255, 255, 255, round(255 * (1 - ed) * (1 - ed))), ex, ey, ex, ey)
	//shaft sheet: parallel streaks dissolving toward the bottom. REAL pixels on purpose -
	//the rays filter renders nothing on a transparent canvas
	_hd2d_shaft_icon = new('sandstorm.dmi')
	_hd2d_shaft_icon.Scale(512, 512)
	_hd2d_shaft_icon.DrawBox(rgb(0, 0, 0, 0), 1, 1, 512, 512)
	//streak density is designed post-scale: the sheet stretches ~5-6x to cover a screen
	var/list/scx = list(30, 92, 150, 224, 288, 356, 420, 480) //streak centers
	var/list/scw = list(6, 13, 5, 11, 7, 12, 5, 9) //half-widths
	var/list/sca = list(150, 75, 165, 85, 140, 70, 155, 95) //peak alphas
	for(var/cx = 1, cx <= 512, cx++)
		var/bv = 0
		for(var/st = 1, st <= 8, st++)
			var/su = min(1, abs(cx - scx[st]) / (scw[st] * 2.6))
			bv = max(bv, sca[st] * (1 - su * su * (3 - 2 * su)))
		if(bv >= 3) _hd2d_shaft_icon.DrawBox(rgb(255, 255, 255, round(bv)), cx, 1, cx, 512)
	//rays pour from the top and die out past two-thirds; per-row fade reads as segmented beams
	var/icon/vfade = new('sandstorm.dmi')
	vfade.Scale(512, 512)
	for(var/fy = 1, fy <= 512, fy++)
		var/ft = 1 - fy / 512 //0 at the sheet top, 1 at the bottom
		var/fv = 0
		if(ft < 0.30)
			fv = 255
		else if(ft < 0.72)
			var/fu = (ft - 0.30) / 0.42
			fv = round(255 * (1 - fu * fu * (3 - 2 * fu)))
		vfade.DrawBox(rgb(255, 255, 255, fv), 1, fy, 512, fy)
	_hd2d_shaft_icon.Blend(vfade, ICON_MULTIPLY)
	//water glints: a family of shapes - one repeated sprite reads as uniform
	_hd2d_glint_icons.Cut()
	var/list/gwid = list(5, 7, 9, 11, 13, 9)
	var/list/gflare = list(0, 1, 1, 2, 1, 2)
	var/list/gsharp = list(1, 0, 1, 0, 0, 1) //1 = quartic core, reads as a harder spark
	for(var/gv = 1, gv <= 6, gv++)
		var/gw = gwid[gv]
		var/gcx = round(gw / 2) + 1
		var/icon/GI = new('sandstorm.dmi')
		GI.Scale(gw, 5)
		GI.DrawBox(rgb(0, 0, 0, 0), 1, 1, gw, 5)
		for(var/gx2 = 1, gx2 <= gw, gx2++)
			var/f2 = 1 - abs(gx2 - gcx) / max(1, gcx)
			if(gsharp[gv]) f2 *= f2
			var/ga2 = round(255 * f2 * f2)
			if(ga2 > 8) GI.DrawBox(rgb(255, 255, 255, ga2), gx2, 3, gx2, 3)
		if(gflare[gv])
			GI.DrawBox(rgb(255, 255, 255, 90), gcx, 2, gcx, 2)
			GI.DrawBox(rgb(255, 255, 255, 90), gcx, 4, gcx, 4)
			if(gflare[gv] > 1)
				GI.DrawBox(rgb(255, 255, 255, 45), gcx, 1, gcx, 1)
				GI.DrawBox(rgb(255, 255, 255, 45), gcx, 5, gcx, 5)
		_hd2d_glint_icons += GI
	//ambient kind sprites: a tiny leaf blob + a bubble ring; round kinds reuse the ember dot
	_hd2d_leaf_icon = new('sandstorm.dmi')
	_hd2d_leaf_icon.Scale(5, 3)
	_hd2d_leaf_icon.DrawBox(rgb(0, 0, 0, 0), 1, 1, 5, 3)
	_hd2d_leaf_icon.DrawBox(rgb(255, 255, 255, 230), 2, 2, 4, 2)
	_hd2d_leaf_icon.DrawBox(rgb(255, 255, 255, 160), 1, 1, 3, 1)
	_hd2d_leaf_icon.DrawBox(rgb(255, 255, 255, 160), 3, 3, 5, 3)
	_hd2d_bubble_icon = new('sandstorm.dmi')
	_hd2d_bubble_icon.Scale(5, 5)
	_hd2d_bubble_icon.DrawBox(rgb(0, 0, 0, 0), 1, 1, 5, 5)
	_hd2d_bubble_icon.DrawBox(rgb(255, 255, 255, 190), 2, 1, 4, 1)
	_hd2d_bubble_icon.DrawBox(rgb(255, 255, 255, 190), 2, 5, 4, 5)
	_hd2d_bubble_icon.DrawBox(rgb(255, 255, 255, 190), 1, 2, 1, 4)
	_hd2d_bubble_icon.DrawBox(rgb(255, 255, 255, 190), 5, 2, 5, 4)
	_hd2d_bubble_icon.DrawBox(rgb(255, 255, 255, 70), 3, 3, 3, 3)
	//vignette: black radial corner falloff, baked at 128 and stretched - the GPU hides the steps
	_hd2d_vignette_icon = new('sandstorm.dmi')
	_hd2d_vignette_icon.Scale(128, 128)
	_hd2d_vignette_icon.DrawBox(rgb(0, 0, 0, 0), 1, 1, 128, 128)
	for(var/px = 1, px <= 128, px++)
		for(var/py = 1, py <= 128, py++)
			var/pdx = (px - 64.5) / 64
			var/pdy = (py - 64.5) / 64
			var/pr = sqrt(pdx * pdx + pdy * pdy) //0 center, ~1.41 corner
			if(pr <= 0.62) continue
			var/pu = min(1, (pr - 0.62) / 0.8)
			var/pa = round(255 * pu * pu * (3 - 2 * pu))
			if(pa > 0) _hd2d_vignette_icon.DrawBox(rgb(0, 0, 0, pa), px, py, px, py)


//per-turf cache: 0 = not a front edge, N = stacked rows. ver gates staleness
turf/var/tmp/_hd2d_wall = 0
turf/var/tmp/_hd2d_wall_ver = 0
var/_hd2d_cache_ver = 1

/obj/hd2d_wallshadow
	plane = SHADOW_PLANE //flattened with mob shadows so overlaps never stack
	layer = 1.1
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	var/tmp/rows = 0
	var/tmp/mark = 0

var/_hd2d_grade_bucket = -1 //clock bucket; a change rebuilds the world-plane filters

var/list/_hd2d_shadow_by_turf = list() //ground turf -> live shadow obj
var/list/_hd2d_shadow_pool = list()
var/_hd2d_epoch = 0
var/_hd2d_sun_key

//front edge = full-occluder turf whose south neighbor is open; rows counted north
proc/Hd2dWallRows(turf/T)
	if(!T) return 0
	if(T._hd2d_wall_ver == _hd2d_cache_ver) return T._hd2d_wall
	. = 0
	if(isturf(T) && SurfaceOcclusion(T) == OCCLUDE_FULL)
		var/turf/S = T.y > 1 ? locate(T.x, T.y - 1, T.z) : null
		if(S && SurfaceOcclusion(S) != OCCLUDE_FULL)
			. = 1
			var/turf/N = locate(T.x, T.y + 1, T.z)
			while(. < glob.WALLSHADOW_MAX_ROWS && N && SurfaceOcclusion(N) == OCCLUDE_FULL)
				.++
				N = T.y + . <= world.maxy ? locate(T.x, T.y + ., T.z) : null
	T._hd2d_wall = .
	T._hd2d_wall_ver = _hd2d_cache_ver

//turf edits go stale a whole column at a time; AO invalidation calls this
proc/Hd2dInvalidateColumn(turf/T)
	if(!T) return
	for(var/i = 0, i <= 4, i++)
		var/turf/S = T.y - i >= 1 ? locate(T.x, T.y - i, T.z) : null
		if(S) S._hd2d_wall_ver = 0
	for(var/j = 1, j <= 4, j++)
		var/turf/N = T.y + j <= world.maxy ? locate(T.x, T.y + j, T.z) : null
		if(N) N._hd2d_wall_ver = 0

//an edge cuts the shadow if it fully occludes or carries the drop_edge tag
proc/Hd2dCutsShadow(turf/T)
	if(!T) return 1
	if(SurfaceOcclusion(T) == OCCLUDE_FULL || SurfaceProp(T, "edgecut")) return 1
	for(var/obj/O in T)
		if(SurfaceOcclusion(O) == OCCLUDE_FULL || SurfaceProp(O, "edgecut")) return 1
	return 0

//pin the strip top to the wall base, scale length, lean by the sun.
//a 32x128 icon draws its center +48 above the ground tile center and transforms pivot there,
//so e=k, f=-32-64k holds the top edge on the wall base while the tail stretches south
proc/Hd2dShadowAim(obj/hd2d_wallshadow/O, list/sp, anim_time = 0)
	if(!O) return
	var/slope = sp[1] * 0.55 //walls lean less than mobs - they are wide, not just tall
	var/k = clamp(O.rows * 32 * glob.WALLSHADOW_LEN * sp[2] / 128, 0.08, 2.2)
	//walk the sheared path and die at the first drop edge; aim-time only, a dozen cached lookups
	var/turf/S = O.loc
	if(isturf(S))
		var/lt = ceil(k * 4) //k*128px / 32 = tiles
		for(var/d = 1, d <= lt, d++)
			var/wy = S.y - d
			//two rails: the strip is a tile wide - a lip beside the centerline needs its own walk
			var/wxc = slope * d
			var/wxw = S.x + round(wxc - 0.45, 1)
			var/wxe = S.x + round(wxc + 0.45, 1)
			var/turf/W1 = (wxw >= 1 && wxw <= world.maxx && wy >= 1) ? locate(wxw, wy, S.z) : null
			var/turf/W2 = (wxe >= 1 && wxe <= world.maxx && wy >= 1) ? locate(wxe, wy, S.z) : null
			if(Hd2dCutsShadow(W1) || Hd2dCutsShadow(W2))
				k = clamp((d - 1) * 32 / 128, 0.08, k)
				break
	var/matrix/M = matrix(1, -slope * k, 64 * slope * k, 0, k, -32 - 64 * k)
	var/a = round(sp[3] * glob.WALLSHADOW_ALPHA)
	if(anim_time > 0)
		animate(O, transform = M, alpha = a, color = sp[5], time = anim_time)
	else
		O.transform = M
		O.alpha = a
		O.color = sp[5]

proc/Hd2dShadowsClear()
	for(var/turf/T in _hd2d_shadow_by_turf)
		var/obj/hd2d_wallshadow/O = _hd2d_shadow_by_turf[T]
		if(O)
			O.loc = null
			if(_hd2d_shadow_pool.len < 300) _hd2d_shadow_pool += O
	_hd2d_shadow_by_turf.Cut()

proc/_Hd2dShadowSweep()
	_hd2d_epoch++
	var/list/sp = SunShadowParams()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		var/atom/anchor = GfxViewAnchor(P.client)
		var/turf/center = anchor ? get_turf(anchor) : null
		if(!center) continue
		var/list/dims = GfxCameraViewTiles(P.client)
		var/hw = round(max(dims[1], P.client.gfx_screen_cover_w) / 2) + 3
		var/hh = round(max(dims[2], P.client.gfx_screen_cover_h) / 2) + 5 //walls above the view cast into it
		for(var/ty = max(1, center.y - hh), ty <= min(world.maxy, center.y + hh), ty++)
			for(var/tx = max(1, center.x - hw), tx <= min(world.maxx, center.x + hw), tx++)
				var/turf/T = locate(tx, ty, center.z)
				if(!T) continue
				var/rows = Hd2dWallRows(T)
				if(rows < max(1, glob.WALLSHADOW_MIN_ROWS)) continue
				var/area/A = T.loc
				if(!A || !A.sees_sky) continue //no sun indoors
				var/turf/S = ty > 1 ? locate(tx, ty - 1, center.z) : null
				if(!S) continue
				var/obj/hd2d_wallshadow/O = _hd2d_shadow_by_turf[S]
				if(!O)
					if(_hd2d_shadow_pool.len)
						O = _hd2d_shadow_pool[_hd2d_shadow_pool.len]
						_hd2d_shadow_pool.len--
					else
						O = new
					if(!_hd2d_wallshadow_icon) _Hd2dBuildIcons()
					O.icon = _hd2d_wallshadow_icon
					O.rows = rows
					O.loc = S
					_hd2d_shadow_by_turf[S] = O
					Hd2dShadowAim(O, sp)
				else if(O.rows != rows)
					O.rows = rows
					Hd2dShadowAim(O, sp)
				O.mark = _hd2d_epoch
	var/list/drop = list()
	for(var/turf/DT in _hd2d_shadow_by_turf)
		var/obj/hd2d_wallshadow/DO = _hd2d_shadow_by_turf[DT]
		if(!DO || DO.mark != _hd2d_epoch) drop += DT
	for(var/turf/RT in drop)
		var/obj/hd2d_wallshadow/RO = _hd2d_shadow_by_turf[RT]
		_hd2d_shadow_by_turf -= RT
		if(RO)
			RO.loc = null
			if(_hd2d_shadow_pool.len < 300) _hd2d_shadow_pool += RO

//plane-0 additive with an area-level sees_sky gate - the capture-chain + mask-filter versions rendered nothing (don't go back)

/obj/screen/hd2d_shaft_canvas
	plane = 0
	screen_loc = "1,1" //a 512 icon at CENTER overhangs the view = the HUD-shift bug; the transform centers it
	layer = 6.58 //above the darkness blanket (6.5) and the MR multiply (6.55)
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	alpha = 0 //fades in on the first sun tick

//non-star capture: plane 0 draws normally AND exports, so the world stays clickable
//(a starred capture killed right-click on every world atom); HUD lives on HUD_PLANE, never blurred

/obj/hd2d_farblur_relay
	plane = FARBLUR_PLANE
	screen_loc = "SOUTHWEST"
	mouse_opacity = 0
	render_source = "hd2dworld"

//top-only gradient: opaque cap, smoothstep to clear by fade_end of the screen height
var/list/_hd2d_farblur_masks = list()

proc/_Hd2dFarblurMask(wpx, hpx, fade_end)
	var/mkey = "[wpx]x[hpx]-[fade_end]"
	var/icon/I = _hd2d_farblur_masks[mkey]
	if(I) return I
	I = new('sandstorm.dmi')
	I.Scale(wpx, hpx)
	I.DrawBox(rgb(0, 0, 0, 0), 1, 1, wpx, hpx)
	var/full = round(hpx * 0.06)
	var/fade = max(1, round(hpx * fade_end) - full)
	for(var/ry = 1, ry <= hpx, ry++)
		var/from_top = hpx - ry
		var/ma = 255
		if(from_top > full)
			var/u = (from_top - full) / fade
			if(u >= 1) continue
			ma = round(255 * (1 - u * u * (3 - 2 * u)))
		I.DrawBox(rgb(255, 255, 255, ma), 1, ry, wpx, ry)
	_hd2d_farblur_masks[mkey] = I
	return I


//canopy blur + parallax are dead ends here; the own-plane -> starred master -> relay chain makes content vanish

//corner darkening: black radial, normal blend, above every world plane, below the HUD
/obj/screen/hd2d_vignette
	plane = VIGNETTE_PLANE
	screen_loc = "1,1" //big-icon anchor rule (see the shaft canvas)
	mouse_opacity = 0
	alpha = 0 //ClientTick owns strength - night breathes darker


client
	var/tmp
		obj/screen/hd2d_shaft_canvas/hd2d_shaft
		obj/hd2d_farblur_relay/hd2d_fb_soft
		obj/hd2d_farblur_relay/hd2d_fb_mild
		obj/hd2d_farblur_relay/hd2d_fb_heavy
		obj/screen/hd2d_vignette/hd2d_vignette
		obj/screen/hd2d_ambient/hd2d_ambient
		hd2d_ambient_key
		hd2d_lightclass //sky/cave/bright - a change means indoor/outdoor crossing: CpmApply cut
		hd2d_env_key

proc/Hd2dShaftEnabled(client/C)
	return glob && glob.LIGHT_SHAFTS && C && C.prefs && C.prefs.lightShafts && GfxQualityRank(C) >= GFX_QUALITY_MEDIUM

proc/Hd2dFarblurEnabled(client/C)
	return glob && glob.FARBLUR && C && C.prefs && C.prefs.farBlur && GfxQualityRank(C) >= GFX_QUALITY_HIGH

proc/Hd2dVignetteEnabled(client/C)
	return glob && glob.VIGNETTE && C && C.prefs && C.prefs.vignette && GfxQualityRank(C) >= GFX_QUALITY_MEDIUM

//color-matrix grade from the gain/black/warm knobs
//input-major rows; const row NORMALIZED (0..1) - GRADE_BLACK 0.03 = a ~9-level floor
//taste knob = GRADE_BLACK, never GRADE_CONST_SCALE
//the clock darkens only sky zones; interiors get the day treatment, caves are always night
proc/_Hd2dLocalDark(client/C)
	var/atom/anchor = C ? GfxViewAnchor(C) : null
	var/turf/T = anchor ? get_turf(anchor) : null
	var/area/A = T ? T.loc : null
	if(!A || A.sees_sky) return DnDarknessFrac()
	if(A.dark_cave) return 1
	if(A.dn_indoor) return DnDarknessFrac() * (glob ? glob.INDOOR_DIM : 0.6)
	return 0

//per-zone grade: the camera's profile overrides the global knobs (null = global)
proc/_Hd2dGradeMatrix(client/C)
	var/gain = glob.GRADE_GAIN
	var/black = glob.GRADE_BLACK
	var/warm = glob.GRADE_WARM
	if(C && C.mob)
		var/turf/T = get_turf(C.mob)
		var/datum/environment_profile/P = EnvProfileForClient(C, T ? T.loc : null)
		if(P)
			if(!isnull(P.grade_gain)) gain = P.grade_gain
			if(!isnull(P.grade_black)) black = P.grade_black
			if(!isnull(P.grade_warm)) warm = P.grade_warm
	//night = full zone grade; day lerps gain+warm toward neutral. local darkness, bucketed 1/8ths
	var/dayness = round((1 - _Hd2dLocalDark(C)) * 8) / 8
	var/soften = clamp(glob.GRADE_DAY_SOFTEN * dayness, 0, 1)
	var/g = 1 + (gain - 1) * (1 - soften)
	var/w = warm * (1 - soften)
	var/cs = glob.GRADE_CONST_SCALE
	var/b = -black * g * cs
	return list(\
		(1 + w * 0.55) * g, 0.02 * g, 0, 0,\
		0.045 * g, g, 0.03 * g, 0,\
		0, 0.03 * g, (1 - w * 0.75) * g, 0,\
		0, 0, 0, 1,\
		b + w * 0.012 * cs, b, b - w * 0.004 * cs, 0)

proc/Hd2dGradeFilter(client/C)
	return filter(name = "hd2dgrade", type = "color", color = _Hd2dGradeMatrix(C))

proc/WorldBloomThreshold(client/C)
	var/atom/anchor = C ? GfxViewAnchor(C) : null
	var/turf/T = anchor ? get_turf(anchor) : null
	var/area/A = T ? T.loc : null
	var/amb
	if(A && A.dark_cave)
		amb = glob.LIGHT_CAVE_COLOR
	else
		amb = (glob && glob.DAY_NIGHT) ? DnColorNow() : "#ffffff"
		if(A && A.dn_indoor) amb = DnIndoorColor(amb)
	var/list/sk = _FxRGB(amb)
	var/a = sk ? max(sk[1], max(sk[2], sk[3])) : 255
	. = a
	if(glob.COLOR_GRADE && GfxQualityRank(C) >= GFX_QUALITY_MEDIUM) //bloom samples post-grade pixels
		var/list/M = _Hd2dGradeMatrix(C)
		. = max(a * (M[1] + M[5] + M[9]) + 255 * M[17],\
		    max(a * (M[2] + M[6] + M[10]) + 255 * M[18],\
		        a * (M[3] + M[7] + M[11]) + 255 * M[19]))
	return clamp(max(glob.WORLD_BLOOM_THRESHOLD, round(.) + 10), 96, 245)

//zone crossings glide the grade ~4s instead of snapping; falls back to a full rebuild
proc/Hd2dGradeShift(client/C, time = 40)
	if(!C) return
	if(!glob || !glob.COLOR_GRADE || GfxQualityRank(C) < GFX_QUALITY_MEDIUM)
		CpmApply(C)
		return
	var/list/M = _Hd2dGradeMatrix(C)
	var/hit = 0
	for(var/obj/plate in list(C.client_plane_master, C.fxplane_master, C.fxnb_master))
		if(!plate || !plate.filters) continue
		var/F = plate.filters["hd2dgrade"]
		if(F)
			animate(F, color = M, time = time)
			hit++
	if(!hit) CpmApply(C)

proc/Hd2dApplyClient(client/C)
	if(!C) return
	_Hd2dBuildIcons()
	//sized off VIEW tiles - past-the-view screen_loc shifts the whole HUD
	var/list/vdims = GfxCameraViewTiles(C)
	var/vtw = max(1, vdims[1])
	var/vth = max(1, vdims[2])
	var/vw = vtw * world.icon_size
	var/vh = vth * world.icon_size
	if(Hd2dShaftEnabled(C))
		if(!C.hd2d_shaft)
			C.hd2d_shaft = new
			C.screen += C.hd2d_shaft
		C.hd2d_shaft.icon = Hd2dShaftIcon(clamp(min(vtw, vth) * 32, 64, 512))
		//no rays filter here; the blur smooths 8-bit contour banding on faint moon shafts
		C.hd2d_shaft.filters = filter(type = "blur", size = 2)
		C.hd2d_env_key = null //force a transform rebuild at the current sun
	else
		if(C.hd2d_shaft)
			C.screen -= C.hd2d_shaft
			C.hd2d_shaft = null
	if(Hd2dFarblurEnabled(C))
		if(!C.client_plane_master) CpmApply(C) //creates + screens the world master
		C.client_plane_master.render_target = "hd2dworld" //NO star: the plane still draws, clicks stay alive
		if(!C.hd2d_fb_soft)
			C.hd2d_fb_soft = new
			C.screen += C.hd2d_fb_soft
		if(!C.hd2d_fb_mild)
			C.hd2d_fb_mild = new
			C.screen += C.hd2d_fb_mild
		if(!C.hd2d_fb_heavy)
			C.hd2d_fb_heavy = new
			C.screen += C.hd2d_fb_heavy
		C.hd2d_fb_soft.layer = 1
		C.hd2d_fb_mild.layer = 2
		C.hd2d_fb_heavy.layer = 3
		//blur first, mask second: the band samples the full image, then clips.
		//three graded tiers - two read as a hard band
		//(knob edits need Graphics Reapply / a settings change to take effect)
		C.hd2d_fb_soft.filters = list(\
			filter(type = "blur", size = glob.FARBLUR_SOFT_SIZE), \
			filter(type = "alpha", icon = _Hd2dFarblurMask(vw, vh, glob.FARBLUR_SOFT_BAND)))
		C.hd2d_fb_mild.filters = list(\
			filter(type = "blur", size = glob.FARBLUR_MILD_SIZE), \
			filter(type = "alpha", icon = _Hd2dFarblurMask(vw, vh, glob.FARBLUR_MID)))
		//bloom after the heavy blur: distant lights blossom into discs instead of smearing away
		var/list/hfl = list(filter(type = "blur", size = glob.FARBLUR_HEAVY_SIZE))
		if(glob.FARBLUR_BLOOM && GfxBloomEnabled(C))
			var/bt = clamp(glob.FARBLUR_BLOOM_THRESHOLD, 96, 245)
			hfl += filter(type = "bloom", threshold = rgb(bt, bt, bt), size = glob.FARBLUR_BLOOM_SIZE)
		hfl += filter(type = "alpha", icon = _Hd2dFarblurMask(vw, vh, glob.FARBLUR_TOP))
		C.hd2d_fb_heavy.filters = hfl
	else
		if(C.client_plane_master) C.client_plane_master.render_target = null
		if(C.hd2d_fb_soft)
			C.screen -= C.hd2d_fb_soft
			C.hd2d_fb_soft = null
		if(C.hd2d_fb_mild)
			C.screen -= C.hd2d_fb_mild
			C.hd2d_fb_mild = null
		if(C.hd2d_fb_heavy)
			C.screen -= C.hd2d_fb_heavy
			C.hd2d_fb_heavy = null
	if(Hd2dVignetteEnabled(C))
		if(!C.hd2d_vignette)
			C.hd2d_vignette = new
			C.hd2d_vignette.icon = _hd2d_vignette_icon
			C.screen += C.hd2d_vignette
		//non-uniform stretch to the viewport, centered by translate (anchor stays 1,1)
		C.hd2d_vignette.transform = matrix(vw / 128, 0, vw / 2 - 64, 0, vh / 128, vh / 2 - 64)
	else
		if(C.hd2d_vignette)
			C.screen -= C.hd2d_vignette
			C.hd2d_vignette = null
	Hd2dClientTick(C, 1) //snap: apply-time geometry must land instantly, never glide

//sun-facing state: shaft angle/color/strength, ~10s cadence via the daynight loop
//snap=1 runs every animate at time 0 - apply-time geometry must never glide into place
proc/Hd2dClientTick(client/C, snap = 0)
	if(!C) return
	var/area/wxA = null
	var/mob/Players/P = C.mob
	if(istype(P)) wxA = _WxNearbyWeatherArea(P)
	var/atom/ganchor = GfxViewAnchor(C)
	var/turf/gt = ganchor ? get_turf(ganchor) : null
	var/area/gA = gt ? gt.loc : null
	var/opensky = gA && gA.sees_sky
	if(C.hd2d_vignette)
		var/vdk = DnDarknessFrac()
		var/va = glob.VIGNETTE_ALPHA * (1 + (glob.VIGNETTE_NIGHT_BOOST - 1) * vdk)
		animate(C.hd2d_vignette, alpha = round(clamp(va, 0, 255)), time = snap ? 0 : 100)
	if(C.hd2d_shaft)
		var/list/sp = SunShadowParams()
		var/elev = 1 - clamp((sp[2] - glob.SHADOW_LEN_MIN) / max(0.001, glob.SHADOW_LEN_MAX - glob.SHADOW_LEN_MIN), 0, 1)
		var/isMoon = sp[4]
		//day trimmed: additive beams over bright sand stack into blowout at full strength.
		//moon shafts are a full-moon spectacle only - MoonEventK ramps them with the event
		var/sa = isMoon ? glob.SHAFT_ALPHA * 0.5 * elev * MoonEventK() : glob.SHAFT_ALPHA * (0.32 + 0.38 * elev) * (1 - DnDarknessFrac() * 0.5)
		if(wxA) sa = 0 //overcast kills shafts BY DESIGN - clear-sky test only
		if(!opensky) sa = 0 //no sky, no shafts - the area gate that replaced pixel masking
		if(isMoon && !glob.MOON_SHAFTS) sa = 0
		var/rcol = isMoon ? "#aebfe8" : DnLerp("#fff3d2", "#ffd9a8", 1 - elev)
		var/list/svd = GfxCameraViewTiles(C)
		var/svw = max(1, svd[1])
		var/svh = max(1, svd[2])
		var/first = isnull(C.hd2d_env_key)
		var/skey = "[round(sp[1], 0.06)]-[isMoon]-[svw]x[svh]"
		if(C.hd2d_env_key != skey)
			C.hd2d_env_key = skey
			//scale to cover any lean, then center on the viewport; one animate - a second call cancels the first
			var/spx = clamp(min(svw, svh) * 32, 64, 512)
			C.hd2d_shaft.icon = Hd2dShaftIcon(spx)
			var/covpx = max(svw, svh) * 32
			var/matrix/SM = matrix()
			SM.Scale(covpx * 1.5 / spx)
			SM.Turn(-arctan(sp[1]) * 0.5) //shafts lean with the sun; flip the sign if they fight the shadows
			SM.Translate(svw * 16 - spx / 2, svh * 16 - spx / 2)
			if(first || snap)
				//snap into place - a 10s glide from identity reads as the sheet crawling on-screen
				C.hd2d_shaft.transform = SM
				C.hd2d_shaft.color = rcol
				animate(C.hd2d_shaft, alpha = round(sa), time = snap ? 0 : 20)
			else
				animate(C.hd2d_shaft, transform = SM, color = rcol, alpha = round(sa), time = 100)
		else
			animate(C.hd2d_shaft, color = rcol, alpha = round(sa), time = snap ? 0 : 100)

//called from the daynight loop every 10s: re-aim wall shadows on sun-bucket change, tick clients
proc/Hd2dSunTick()
	if(!glob) return
	//clock buckets rebuild the world-plane filters; grade + bloom read local darkness per client
	var/gbucket = round((1 - DnDarknessFrac()) * 8) + round(MoonEventK() * 8) * 100
	if((glob.COLOR_GRADE || glob.WORLD_BLOOM) && gbucket != _hd2d_grade_bucket)
		_hd2d_grade_bucket = gbucket
		for(var/mob/Players/WP in players)
			if(WP.client) CpmApply(WP.client)
	if(glob.WALL_SHADOWS && _hd2d_shadow_by_turf.len)
		var/list/sp = SunShadowParams()
		var/key = "[round(sp[1], 0.08)]-[round(sp[2], 0.08)]-[round(sp[3] / 12)]-[sp[5]]"
		if(key != _hd2d_sun_key)
			_hd2d_sun_key = key
			for(var/turf/T in _hd2d_shadow_by_turf)
				Hd2dShadowAim(_hd2d_shadow_by_turf[T], sp, 100)
	if(glob.WATER_SPARKLE && _hd2d_glints_by_turf.len)
		_Hd2dGlintRetint() //change-gated: steady state never re-phases the loops
	if(glob.AMBIENT_FX && _hd2d_fireflies_by_turf.len)
		_Hd2dFireflyTick()
	for(var/mob/Players/P in players)
		if(P.client) Hd2dClientTick(P.client)

//one per-client emitter, kind chosen by the camera's environment profile (day/night slots)
//glow kinds ride above the blanket additively; matter kinds sit under it and darken

//steady-state alive = spawning x lifespan - size against the proven gfx_haze emitter, not intuition
/particles/hd2d_amb_motes
	count = 60
	spawning = 0.85
	lifespan = 70
	fade = 25
	fadein = 25
	velocity = generator("box", list(-0.18, -0.3, 0), list(0.18, 0.08, 0))
	drift = generator("sphere", 0, 0.05)
	scale = generator("num", 0.9, 2.2)
	color = rgb(255, 252, 235, 195)

/particles/hd2d_amb_leaves
	count = 24
	spawning = 0.4
	lifespan = 60
	fade = 12
	fadein = 6
	velocity = generator("box", list(-0.5, -0.9, 0), list(0.7, -0.35, 0)) //falls; wind biases x at attach
	drift = generator("sphere", 0, 0.12)
	spin = generator("num", -4, 4)
	scale = generator("num", 1.6, 3.2)
	color = "#c9a94e"

/particles/hd2d_amb_ash
	count = 32
	spawning = 0.55
	lifespan = 60
	fade = 20
	fadein = 12
	velocity = generator("box", list(-0.25, 0.15, 0), list(0.25, 0.6, 0)) //rises off the heat
	drift = generator("sphere", 0, 0.1)
	spin = generator("num", -2, 2)
	scale = generator("num", 0.9, 2.1)
	color = "#96837a" //lighter than real ash: #5a5350 vanished against dark volcanic ground

/particles/hd2d_amb_dust
	count = 50
	spawning = 0.9
	lifespan = 55
	fade = 18
	fadein = 14
	velocity = generator("box", list(0.3, -0.15, 0), list(1.1, 0.15, 0)) //sideways haul; wind biases at attach
	drift = generator("sphere", 0, 0.08)
	scale = generator("num", 1, 2.4)
	color = rgb(230, 206, 158, 180)

/particles/hd2d_amb_bubbles
	count = 30
	spawning = 0.55
	lifespan = 55
	fade = 10
	fadein = 8
	velocity = generator("box", list(-0.12, 0.5, 0), list(0.12, 1.1, 0))
	drift = generator("sphere", 0, 0.12)
	scale = generator("num", 1, 2.4)
	color = rgb(225, 243, 255, 200)

/obj/screen/hd2d_ambient
	screen_loc = "CENTER"
	plane = 0
	layer = 6.52 //just OVER the blanket; glow kinds move to 6.56 + ADD at attach
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE //match the proven gfx_haze emitter exactly
	alpha = 0
	Savable = 0
	gfx_transient_visual = 1

var/list/_hd2d_amb_kinds

proc/Hd2dAmbientKinds()
	if(_hd2d_amb_kinds) return _hd2d_amb_kinds
	_hd2d_amb_kinds = list(\
		"motes" = list("path" = /particles/hd2d_amb_motes, "glow" = 0),\
		"leaves" = list("path" = /particles/hd2d_amb_leaves, "glow" = 0),\
		"ash" = list("path" = /particles/hd2d_amb_ash, "glow" = 0),\
		"dust" = list("path" = /particles/hd2d_amb_dust, "glow" = 0),\
		"bubbles" = list("path" = /particles/hd2d_amb_bubbles, "glow" = 0))
	return _hd2d_amb_kinds

//rides EnvUpdateClient (1s), self-keyed - zone/dusk/quality changes land within a second
proc/_Hd2dAmbientApply(client/C, datum/environment_profile/P, area/A)
	if(!C) return
	var/rank = GfxQualityRank(C)
	var/ldk = _Hd2dLocalDark(C)
	var/kind = null
	if(glob && glob.AMBIENT_FX && P && rank >= GFX_QUALITY_MEDIUM)
		kind = ldk > 0.5 ? P.ambient_night : P.ambient_day
	if(kind == "fireflies") kind = null //the map-anchored firefly system owns that kind
	var/cover_w = max(C.gfx_screen_cover_w, 34)
	var/cover_h = max(C.gfx_screen_cover_h, 26)
	var/wxr = round(C.gfx_env_wind_x, 0.2)
	var/key = "[kind]-[P ? P.id : null]-q[rank]-[cover_w]x[cover_h]-w[wxr]-b[round(GfxBudgetScale(), 0.1)]-d[round(ldk * 4)]"
	if(C.hd2d_ambient_key == key) return
	C.hd2d_ambient_key = key
	if(!kind)
		if(C.hd2d_ambient)
			animate(C.hd2d_ambient, alpha = 0, time = 15)
			spawn(16) //let the fade finish, then stop simulating - unless a kind re-attached
				if(C && C.hd2d_ambient && C.hd2d_ambient_key == key)
					C.hd2d_ambient.particles = null
		return
	var/list/KD = Hd2dAmbientKinds()[kind]
	if(!KD) return
	if(!C.hd2d_ambient)
		C.hd2d_ambient = new
		C.screen += C.hd2d_ambient
	var/glow = KD["glow"]
	//matter kinds sit just over the blanket - fully multiplied motes vanish at night
	C.hd2d_ambient.layer = glow ? 6.56 : 6.52
	C.hd2d_ambient.blend_mode = glow ? BLEND_ADD : BLEND_DEFAULT
	if(!_hd2d_ember_icon) _Hd2dBuildIcons()
	var/path = KD["path"]
	var/particles/NP = new path
	NP.icon = (kind == "leaves") ? _hd2d_leaf_icon : (kind == "bubbles") ? _hd2d_bubble_icon : _hd2d_ember_icon
	var/pixel_w = max(1024, cover_w * world.icon_size)
	var/pixel_h = max(768, cover_h * world.icon_size)
	var/half_w = round(pixel_w / 2) + 96
	var/half_h = round(pixel_h / 2) + 96
	var/coverage = clamp((half_w * 2 * half_h * 2) / (1400 * 1000), 0.65, 3)
	var/pscale = rank >= GFX_QUALITY_ULTRA ? 1 : rank >= GFX_QUALITY_HIGH ? 0.8 : 0.5
	NP.width = half_w * 2
	NP.height = half_h * 2
	//uniform box on purpose: gaussian spread clumps full-screen coverage to the center
	NP.position = generator("box", list(-half_w, -half_h, -60), list(half_w, half_h, 60))
	NP.count = max(1, round(NP.count * coverage * pscale * glob.AMBIENT_DENSITY * GfxBudgetScale()))
	NP.spawning = NP.spawning * coverage * pscale * glob.AMBIENT_DENSITY
	if(kind == "leaves" || kind == "dust") //wind-following kinds
		var/wvx = C.gfx_env_wind_x * 0.25
		NP.velocity = kind == "leaves" \
			? generator("box", list(wvx - 0.5, -0.9, 0), list(wvx + 0.5, -0.35, 0)) \
			: generator("box", list(wvx + 0.2, -0.15, 0), list(wvx + 1, 0.15, 0))
	C.hd2d_ambient.particles = NP
	animate(C.hd2d_ambient, alpha = glow ? 255 : round(255 * (1 - ldk * 0.45)), time = 15)

//pooled world objs on hash-seeded home tiles - screen-space fireflies would pan with the camera

/obj/hd2d_firefly
	plane = 0
	layer = 6.56 //above both darkness paths (blanket 6.5, MR multiply 6.55) - bioluminescent
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	var/tmp/gseed = 1
	var/tmp/tmax = -1
	var/tmp/mark = 0

var/list/_hd2d_fireflies_by_turf = list() //home turf -> list of firefly objs
var/list/_hd2d_firefly_pool = list()
var/_hd2d_firefly_epoch = 0

//a tile hosts fireflies when its zone's night slot says so and dusk has fallen
proc/_Hd2dFireflyWanted(turf/T, dk)
	if(dk < 0.35) return 0
	var/area/A = T.loc
	if(!A) return 0
	var/datum/environment_profile/P = _env_profiles[A.env_profile_id]
	return P && P.ambient_night == "fireflies"

//blink loop: full blink-out, hash periods; non-parallel = it owns the main track
proc/_Hd2dFireflyBlink(obj/hd2d_firefly/F, dk, onlychange = 0)
	if(!F) return
	var/amax = round(glob.FIREFLY_ALPHA * clamp((dk - 0.35) / 0.3, 0, 1))
	if(onlychange && F.tmax == amax) return
	F.tmax = amax
	F.alpha = amax
	var/per = 8 + F.gseed % 23
	var/t1 = 3 + F.gseed % max(2, round(per * 0.5))
	animate(F, alpha = 0, time = t1, loop = -1, easing = SINE_EASING)
	animate(alpha = amax, time = max(3, per - t1), easing = SINE_EASING)

//wander: slow 10s glides near home, parallel so it rides alongside the blink loop
proc/_Hd2dFireflyAim(obj/hd2d_firefly/F)
	if(!F) return
	var/sc = 0.5 + (F.gseed % 5) / 10
	var/matrix/M = matrix(sc, 0, rand(-14, 14), 0, sc, rand(-10, 12))
	animate(F, transform = M, time = 100, easing = SINE_EASING, flags = ANIMATION_PARALLEL)

proc/Hd2dFirefliesClear()
	for(var/turf/T in _hd2d_fireflies_by_turf)
		for(var/obj/hd2d_firefly/F in _hd2d_fireflies_by_turf[T])
			animate(F) //cancel loops before pooling
			F.loc = null
			if(_hd2d_firefly_pool.len < 160) _hd2d_firefly_pool += F
	_hd2d_fireflies_by_turf.Cut()

proc/_Hd2dFireflySweep()
	_hd2d_firefly_epoch++
	var/dk = DnDarknessFrac()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		var/atom/anchor = GfxViewAnchor(P.client)
		var/turf/center = anchor ? get_turf(anchor) : null
		if(!center) continue
		var/list/dims = GfxCameraViewTiles(P.client)
		var/hw = round(max(dims[1], P.client.gfx_screen_cover_w) / 2) + 2
		var/hh = round(max(dims[2], P.client.gfx_screen_cover_h) / 2) + 2
		for(var/ty = max(1, center.y - hh), ty <= min(world.maxy, center.y + hh), ty++)
			for(var/tx = max(1, center.x - hw), tx <= min(world.maxx, center.x + hw), tx++)
				var/turf/T = locate(tx, ty, center.z)
				if(!T || T.density) continue //open ground and water both host; walls do not
				if((T.x * 89 + T.y * 41 + T.z * 23) % max(2, glob.FIREFLY_SEED_MOD)) continue
				if(!_Hd2dFireflyWanted(T, dk)) continue
				var/list/fl = _hd2d_fireflies_by_turf[T]
				if(!fl)
					if(!_hd2d_ember_icon) _Hd2dBuildIcons()
					fl = list()
					var/n = 1 + ((T.x * 7 + T.y * 3) % 5 == 0 ? 1 : 0) //mostly singles, odd pair
					for(var/i = 1, i <= n, i++)
						var/obj/hd2d_firefly/F
						if(_hd2d_firefly_pool.len)
							F = _hd2d_firefly_pool[_hd2d_firefly_pool.len]
							_hd2d_firefly_pool.len--
						else
							F = new
						var/h1 = T.x * 19 + T.y * 11 + i * 37
						F.icon = _hd2d_ember_icon
						F.gseed = h1
						F.color = DnLerp("#d8f0a0", "#ffd890", (h1 % 3) / 2) //green-gold spread
						F.pixel_x = 12 + (h1 % 17) - 8
						F.pixel_y = 12 + ((h1 * 3) % 15) - 7
						F.transform = null
						F.tmax = -1
						F.loc = T
						_Hd2dFireflyBlink(F, dk)
						_Hd2dFireflyAim(F)
						fl += F
					_hd2d_fireflies_by_turf[T] = fl
				for(var/obj/hd2d_firefly/F in fl)
					F.mark = _hd2d_firefly_epoch
	var/list/drop = list()
	for(var/turf/DT in _hd2d_fireflies_by_turf)
		var/list/dfl = _hd2d_fireflies_by_turf[DT]
		var/obj/hd2d_firefly/DF = dfl.len ? dfl[1] : null
		if(!DF || DF.mark != _hd2d_firefly_epoch) drop += DT
	for(var/turf/RT in drop)
		for(var/obj/hd2d_firefly/RF in _hd2d_fireflies_by_turf[RT])
			animate(RF)
			RF.loc = null
			if(_hd2d_firefly_pool.len < 160) _hd2d_firefly_pool += RF
		_hd2d_fireflies_by_turf -= RT

//sun-tick pass: dusk/dawn ramp re-issues blinks (change-gated), every tick re-aims wander
proc/_Hd2dFireflyTick()
	var/dk = DnDarknessFrac()
	for(var/turf/T in _hd2d_fireflies_by_turf)
		for(var/obj/hd2d_firefly/F in _hd2d_fireflies_by_turf[T])
			_Hd2dFireflyBlink(F, dk, 1)
			_Hd2dFireflyAim(F)

//pooled world objs on hash-seeded cluster turfs, twinkling client-side - the same shallows catch light every visit

/obj/hd2d_glint
	plane = 0
	layer = 2.4 //above water art, below actors
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	Savable = 0
	gfx_transient_visual = 1
	var/tmp/gseed = 1 //per-glint hash: shapes the envelope, tint bias, icon pick
	var/tmp/tmax = -1
	var/tmp/mark = 0

var/list/_hd2d_glints_by_turf = list() //seed turf -> list of glint objs
var/list/_hd2d_glint_pool = list()
var/_hd2d_glint_epoch = 0

//amplitude/tint from clock + weather; re-animates only on change so loops never re-phase
proc/_Hd2dGlintTwinkle(obj/hd2d_glint/G, dk, wet, onlychange = 0)
	if(!G) return
	var/amax = round(glob.SPARKLE_ALPHA * (1 - dk * 0.65) * (wet ? 0.2 : 1))
	var/col = DnLerp("#fff6d8", "#9fb4dd", dk)
	var/cb = (G.gseed % 5) / 16 //0..0.25 toward white - some glints run hotter than the tint
	if(cb) col = DnLerp(col, "#ffffff", cb)
	if(onlychange && G.tmax == amax && G.color == col) return
	G.tmax = amax
	G.color = col
	G.alpha = amax
	//hash-shaped envelope: period 6..34ds, trough 6..46%, asymmetric legs
	var/per = 6 + G.gseed % 29
	var/trough = 0.06 + (round(G.gseed / 7) % 9) / 20
	var/t1 = 2 + G.gseed % max(2, round(per * 0.6))
	var/t2 = max(2, per - t1)
	animate(G, alpha = max(8, round(amax * trough)), time = t1, loop = -1, easing = SINE_EASING)
	animate(alpha = amax, time = t2, easing = SINE_EASING)

proc/Hd2dGlintsClear()
	for(var/turf/T in _hd2d_glints_by_turf)
		for(var/obj/hd2d_glint/G in _hd2d_glints_by_turf[T])
			animate(G) //cancel the loop before pooling
			G.loc = null
			if(_hd2d_glint_pool.len < 240) _hd2d_glint_pool += G
	_hd2d_glints_by_turf.Cut()

proc/_Hd2dGlintSweep()
	_hd2d_glint_epoch++
	var/dk = DnDarknessFrac()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		var/atom/anchor = GfxViewAnchor(P.client)
		var/turf/center = anchor ? get_turf(anchor) : null
		if(!center) continue
		var/list/dims = GfxCameraViewTiles(P.client)
		var/hw = round(max(dims[1], P.client.gfx_screen_cover_w) / 2) + 2
		var/hh = round(max(dims[2], P.client.gfx_screen_cover_h) / 2) + 2
		for(var/ty = max(1, center.y - hh), ty <= min(world.maxy, center.y + hh), ty++)
			for(var/tx = max(1, center.x - hw), tx <= min(world.maxx, center.x + hw), tx++)
				var/turf/T = locate(tx, ty, center.z)
				if(!T || istype(T, /turf/CustomTurf)) continue //player builds: never decorate what saves
				if((T.x * 73 + T.y * 131 + T.z * 57) % max(2, glob.SPARKLE_SEED_MOD)) continue //cluster seeds only
				if(!GfxIsWaterSurface(T) || T.Lava || T.gfx_reflectivity == 0) continue
				var/list/gl = _hd2d_glints_by_turf[T]
				if(!gl)
					if(!_hd2d_glint_icons.len) _Hd2dBuildIcons()
					gl = list()
					var/area/A = T.loc
					var/wet = (A && A.wx_kind) ? 1 : 0
					var/n = 2 + (T.x * 31 + T.y * 17) % 4 //cluster size 2-5
					for(var/i = 1, i <= n, i++)
						var/obj/hd2d_glint/G
						if(_hd2d_glint_pool.len)
							G = _hd2d_glint_pool[_hd2d_glint_pool.len]
							_hd2d_glint_pool.len--
						else
							G = new
						//deterministic scatter: the same water always glitters the same way
						var/h1 = T.x * 13 + T.y * 7 + i * 29
						var/h2 = T.x * 5 + T.y * 23 + i * 41
						G.icon = _hd2d_glint_icons[1 + (h1 + h2) % _hd2d_glint_icons.len]
						G.gseed = h1 * 3 + h2 * 11 + i
						G.pixel_x = 10 + (h1 % 25) - 12
						G.pixel_y = 13 + (h2 % 25) - 12
						//independent stretch + mirrored half: the icon family multiplies
						var/sx = (0.65 + (h1 % 8) / 10) * ((h2 % 2) ? 1 : -1)
						var/sy = 0.65 + (h2 % 7) / 10
						G.transform = matrix(sx, 0, 0, 0, sy, 0)
						G.tmax = -1 //force the twinkle to (re)start
						G.loc = T
						_Hd2dGlintTwinkle(G, dk, wet)
						gl += G
					_hd2d_glints_by_turf[T] = gl
				for(var/obj/hd2d_glint/G in gl)
					G.mark = _hd2d_glint_epoch
	var/list/drop = list()
	for(var/turf/DT in _hd2d_glints_by_turf)
		var/list/dgl = _hd2d_glints_by_turf[DT]
		var/obj/hd2d_glint/DG = dgl.len ? dgl[1] : null
		if(!DG || DG.mark != _hd2d_glint_epoch) drop += DT
	for(var/turf/RT in drop)
		for(var/obj/hd2d_glint/RG in _hd2d_glints_by_turf[RT])
			animate(RG)
			RG.loc = null
			if(_hd2d_glint_pool.len < 240) _hd2d_glint_pool += RG
		_hd2d_glints_by_turf -= RT

//clock/weather drift: re-tints only what actually changed
proc/_Hd2dGlintRetint()
	var/dk = DnDarknessFrac()
	for(var/turf/T in _hd2d_glints_by_turf)
		var/area/A = T.loc
		var/wet = (A && A.wx_kind) ? 1 : 0
		for(var/obj/hd2d_glint/G in _hd2d_glints_by_turf[T])
			_Hd2dGlintTwinkle(G, dk, wet, 1)

//drop_shadow offset toward the light peeks past the silhouette on the lit side only
//(outline rings all sides and reads as a sticker); buff filter rebuilds re-add within a second

mob/var/tmp/_hd2d_rim_key

proc/_Hd2dRimSweep()
	for(var/mob/Players/P in players)
		if(!P.client) continue
		var/atom/anchor = GfxViewAnchor(P.client)
		var/turf/center = anchor ? get_turf(anchor) : null
		if(!center) continue
		for(var/mob/M in range(9, center))
			if(!M.icon) continue
			var/rimkey
			var/rx = 0
			var/ry = 0
			var/rcol
			if(glob.RIM_LIGHT && ShadowCastable(M))
				var/turf/mt = get_turf(M)
				var/best = 1000
				var/datum/lightsource/bestL
				var/turf/bestT
				for(var/datum/lightsource/L in LightsNearTurf(mt, glob.RIM_RANGE))
					var/turf/lt = LightSrcTurf(L)
					if(!lt || lt.z != mt.z) continue
					var/d = get_dist(mt, lt)
					if(d > min(L.radius, glob.RIM_RANGE) || d >= best) continue
					if(mt != lt && !LightClearLine(lt, mt)) continue //a wall between = no rim
					best = d
					bestL = L
					bestT = lt
				if(bestL)
					var/str = LightRenderStrength(bestT)
					if(str > 0.05)
						rx = clamp(bestT.x - mt.x, -1, 1) * 2
						ry = clamp(bestT.y - mt.y, -1, 1) * 2
						if(!rx && !ry) ry = -2 //standing ON the light: lit from below reads best
						var/falloff = 1 - best / max(1, min(bestL.radius, glob.RIM_RANGE))
						var/ra = round(glob.RIM_ALPHA * str * (0.35 + 0.65 * falloff))
						if(ra > 12)
							var/wcol = DnLerp(bestL.lcolor, "#ffffff", 0.3)
							rcol = rgb(text2num(copytext(wcol, 2, 4), 16), text2num(copytext(wcol, 4, 6), 16), \
								text2num(copytext(wcol, 6, 8), 16), min(ra, 255))
							rimkey = "[rx],[ry],[rcol]"
			if(M._hd2d_rim_key == rimkey && (!rimkey || (M.filters && M.filters["hd2drim"]))) continue
			M._hd2d_rim_key = rimkey
			M.filters -= "hd2drim"
			if(rimkey) M.filters += filter(name = "hd2drim", type = "drop_shadow", x = rx, y = ry, size = 1, color = rcol)


/particles/hd2d_ember
	width = 160
	height = 200
	count = 14
	spawning = 0.2
	lifespan = 26
	fade = 12
	fadein = 3
	position = generator("box", list(-7, -2, 0), list(7, 3, 0))
	velocity = generator("box", list(-0.3, 0.5, 0), list(0.3, 1.1, 0))
	drift = generator("sphere", 0, 0.06)
	friction = 0.03
	scale = generator("num", 0.7, 1.15)
	grow = -0.012

//carrier rides the fx plane: bloom + heat shimmer for free
/obj/hd2d_ember_carrier
	plane = 1
	layer = 6.4
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	Savable = 0
	gfx_transient_visual = 1

obj/var/tmp/obj/hd2d_ember_carrier/hd2d_embers

proc/Hd2dEmberAttach(obj/O, datum/lightsource/L)
	if(!glob || !glob.EMBERS || !O || !L || !L.flicker) return //flicker flag = fire-type light
	if(O.hd2d_embers) return
	//old saves can carry stale carriers baked into vis_contents - scrub them first
	for(var/obj/hd2d_ember_carrier/S in O.vis_contents)
		O.vis_contents -= S
		S.particles = null
		S.loc = null
	if(!_hd2d_ember_icon) _Hd2dBuildIcons()
	var/obj/hd2d_ember_carrier/E = new
	var/particles/hd2d_ember/PT = new
	PT.icon = _hd2d_ember_icon
	PT.color = DnLerp(L.lcolor, "#ffffff", 0.25) //the flame's own color, warmed toward a hot core
	PT.spawning = (0.08 + L.radius * 0.02) * max(0.1, glob.EMBER_RATE)
	PT.count = round(5 + L.radius * 1.6)
	E.particles = PT
	E.pixel_x = L.off_x
	E.pixel_y = L.off_y
	O.vis_contents += E
	O.hd2d_embers = E

proc/Hd2dEmberClear(obj/O)
	if(!O || !O.hd2d_embers) return
	O.vis_contents -= O.hd2d_embers
	O.hd2d_embers.particles = null
	O.hd2d_embers.loc = null
	O.hd2d_embers = null


var/_hd2d_boot = _Hd2dBoot()

proc/_Hd2dBoot()
	spawn(90)
		_Hd2dLoop()
	return 1

proc/_Hd2dLoop()
	set waitfor = 0
	set background = 1
	var/flip = 0
	while(1)
		if(world.tick_usage < 85)
			flip = !flip
			if(glob && glob.WALL_SHADOWS)
				if(flip) _Hd2dShadowSweep() //1s effective cadence
			else if(_hd2d_shadow_by_turf.len)
				Hd2dShadowsClear()
			if(flip && glob && glob.RIM_LIGHT)
				_Hd2dRimSweep()
			if(!flip && glob && glob.WATER_SPARKLE)
				_Hd2dGlintSweep() //counter-phase to the shadow sweep: same budget, no stacking
			if((!glob || !glob.WATER_SPARKLE) && _hd2d_glints_by_turf.len)
				Hd2dGlintsClear()
			if(!flip && glob && glob.AMBIENT_FX)
				_Hd2dFireflySweep()
			if((!glob || !glob.AMBIENT_FX) && _hd2d_fireflies_by_turf.len)
				Hd2dFirefliesClear()
		sleep(5)


/mob/Admin2/verb/Wall_Shadows_Toggle()
	set category = "Admin"
	set name = "Wall Shadows Toggle"
	glob.WALL_SHADOWS = !glob.WALL_SHADOWS
	if(!glob.WALL_SHADOWS) Hd2dShadowsClear()
	src << "Wall shadows: [glob.WALL_SHADOWS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set wall shadows to [glob.WALL_SHADOWS].")

/mob/Admin2/verb/Wall_Shadows_Rebuild()
	set category = "Admin"
	set name = "Wall Shadows Rebuild"
	_hd2d_cache_ver++
	Hd2dShadowsClear()
	src << "Wall shadow cache flushed."

/mob/Admin2/verb/Light_Shafts_Toggle()
	set category = "Admin"
	set name = "Light Shafts Toggle"
	glob.LIGHT_SHAFTS = !glob.LIGHT_SHAFTS
	for(var/client/C)
		Hd2dApplyClient(C)
	src << "Light shafts: [glob.LIGHT_SHAFTS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set light shafts to [glob.LIGHT_SHAFTS].")

/mob/Admin2/verb/Ambient_FX_Toggle()
	set category = "Admin"
	set name = "Ambient FX Toggle"
	glob.AMBIENT_FX = !glob.AMBIENT_FX
	if(!glob.AMBIENT_FX) Hd2dFirefliesClear()
	for(var/client/C)
		C.hd2d_ambient_key = null //self-keyed: the next env pass (<=1s) re-resolves
	src << "Ambient zone particles: [glob.AMBIENT_FX ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set ambient fx to [glob.AMBIENT_FX].")

/mob/Admin2/verb/Water_Sparkle_Toggle()
	set category = "Admin"
	set name = "Water Sparkle Toggle"
	glob.WATER_SPARKLE = !glob.WATER_SPARKLE
	if(!glob.WATER_SPARKLE) Hd2dGlintsClear()
	src << "Water sparkle: [glob.WATER_SPARKLE ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set water sparkle to [glob.WATER_SPARKLE].")

/mob/Admin2/verb/Rim_Light_Toggle()
	set category = "Admin"
	set name = "Rim Light Toggle"
	glob.RIM_LIGHT = !glob.RIM_LIGHT
	if(!glob.RIM_LIGHT)
		for(var/mob/M in world)
			if(M._hd2d_rim_key)
				M._hd2d_rim_key = null
				M.filters -= "hd2drim"
	src << "Rim light: [glob.RIM_LIGHT ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set rim light to [glob.RIM_LIGHT].")

/mob/Admin2/verb/Color_Grade_Toggle()
	set category = "Admin"
	set name = "Color Grade Toggle"
	glob.COLOR_GRADE = !glob.COLOR_GRADE
	for(var/client/C)
		CpmApply(C) //rebuilds the world-plane filters + both fx-plate mirrors
	src << "Color grade: [glob.COLOR_GRADE ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set color grade to [glob.COLOR_GRADE].")

/mob/Admin2/verb/Farblur_Toggle()
	set category = "Admin"
	set name = "Farblur Toggle"
	glob.FARBLUR = !glob.FARBLUR
	for(var/client/C)
		Hd2dApplyClient(C)
	src << "Far-field blur (world switch): [glob.FARBLUR ? "ON" : "OFF"]. Players still need the pref on."
	Log("Admin", "[ExtractInfo(src)] set farblur to [glob.FARBLUR].")

/mob/Admin2/verb/Embers_Toggle()
	set category = "Admin"
	set name = "Embers Toggle"
	glob.EMBERS = !glob.EMBERS
	if(glob.EMBERS)
		for(var/datum/lightsource/L in _light_sources)
			if(L.flicker && L.src_obj) Hd2dEmberAttach(L.src_obj, L)
	else
		for(var/datum/lightsource/EL in _light_sources)
			if(EL.src_obj) Hd2dEmberClear(EL.src_obj)
	src << "Fire embers: [glob.EMBERS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set embers to [glob.EMBERS].")

/mob/Admin2/verb/Vignette_Toggle()
	set category = "Admin"
	set name = "Vignette Toggle"
	glob.VIGNETTE = !glob.VIGNETTE
	for(var/client/C)
		Hd2dApplyClient(C)
	src << "Vignette: [glob.VIGNETTE ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set vignette to [glob.VIGNETTE].")
