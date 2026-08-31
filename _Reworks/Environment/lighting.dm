//occluded lighting

#define LIGHT_OVERLAY_LAYER 6.55 //above the day/night blanket (6.5), below weather/HUD

//emissive reveal tiers
#define EMISSIVE_REVEAL 1 //sprite draws at full color through darkness
#define EMISSIVE_GLOW 2 //reveal + soft halo, scaled by the clock

turf/var/blocks_light = 0 //occluder flag for walls that aren't the 'Walls.dmi' tree

turf/MidgarTiles
	MidgarWall1/blocks_light = 1
	MidgarWall2/blocks_light = 1
	MidgarWall3/blocks_light = 1
	MidgarWall4/blocks_light = 1
	Midgarwall5/blocks_light = 1
	MidgarLightWall1/blocks_light = 1
	MidgarLightWall2/blocks_light = 1
	MidgarLightWall3/blocks_light = 1
turf/Special/Midgar_IchorWall/blocks_light = 1

globalTracker
	var/tmp
		LIGHTING = TRUE //master switch
		LIGHT_DEFAULT_RADIUS = 6
		LIGHT_DEFAULT_COLOR = "#ffcf9e" //warm torch
		LIGHT_MAX_ALPHA = 170 //additive strength at the source
		LIGHT_DAY_STRENGTH = 0.10 //present but deliberately subtle under full daylight
		LIGHT_BLUR = 10 //blur size on the lighting plane master - smooths the per-tile grid
		EMISSIVES = TRUE //tagged props (fire, glow decor) punch through darkness at full color
		CORNER_LIGHTS = TRUE //bilinear corner gradients; off = legacy flat tiles + plane blur
		UNIFIED_LIGHTS = TRUE //smooth texture + KT-masked shadows + analytic spill wedges
		UNI_MASK_BLUR = 6 //softness of the room-mask stamp edges inside each light's composite
		LIGHT_FILL = 0.16 //indirect bounce: falloff floor inside a light's line-of-sight set (0 = off)
		LIGHT_SOFTCLIP = TRUE //clustered lights attenuate so overlaps saturate instead of clipping white
		LIGHT_PAINT_CEILING = 225
		LIGHT_PAINT_LIFT = 12
		LIGHT_ART_TARGET = 190
		GOD_RAYS = TRUE //visible beams: window lights with directional cookies + tagged canopy trees
		FLICKER_MIN = 95 //flame-glow alpha low (waver floor)
		FLICKER_MAX = 195 //flame-glow alpha high (waver ceiling)
		//occluded blast lights: big/slow blasts cast a wall-blocked light while flying, capped + throttled
		OCCLUDED_BLASTS = TRUE //feature switch (only meaningful when LIGHTING is on)
		OCCLUDED_BLAST_MAX = 4 //hard global cap on simultaneous occluded footprints
		OCCLUDED_BLAST_RADIUS = 4 //footprint radius in tiles (smaller = cheaper)
		OCCLUDED_BLAST_INTERVAL = 2 //min ticks between repaints of one footprint

var/list/_light_sources = list()
var/list/_light_buckets = list()
var/_lights_settled = 0 //boot sweep done; gates the attach/detach neighbor repaints (soft-clip)
var/_light_fov_builds = 0
var/_light_fov_cells = 0

#define LIGHT_BUCKET_SIZE 8

//a light source: either a fixed world point (lx/ly/lz) or tied to a prop (src_obj, follows it)
/datum/lightsource
	var/lx
	var/ly
	var/lz
	var/atom/movable/src_obj //if set, the light lives at this prop's turf (torch/campfire/lamp)
	var/radius = 6
	var/lcolor = "#ffcf9e"
	var/maxalpha = 170
	var/off_x = 0 //light origin in pixels from the prop's tile center (+y up)
	var/off_y = 0
	var/cookie //light_cookies.dmi state: the pool takes that shape instead of the plain radial
	var/cookie_dir = SOUTH //where a directional cookie's pool falls (window light spills this way)
	var/shaft //god-ray beam over the pool: null = auto (directional cookies beam), 0 = off
	var/list/applied //turf -> the additive overlay image we put on it
	var/list/uni_objs //unified renderer: the light's composite + spill objects
	var/list/reflection_applied //reflective turf -> pooled-looking glint image on reflection plane
	var/list/visible_turfs //cached occlusion geometry; dusk/dawn repaints do not raycast again
	var/geometry_key
	var/bucket_key
	var/painted_dark = -1 //LightDarkFrac at last paint; the loop re-tints on material change
	var/last_recompute = 0 //world.time of last wall-change recompute (burst dedup)
	var/flicker = 0 //flame prop: carry a wavering flame glow at the source
	var/obj/flamelight/flame //the flame glow obj

//daylight floor keeps lamps from switching off; smoothstep grows them into dusk
proc/LightRenderStrength(turf/T)
	var/dark = clamp(LightDarkFrac(T), 0, 1)
	var/eased = dark * dark * (3 - 2 * dark)
	var/floor = glob ? clamp(glob.LIGHT_DAY_STRENGTH, 0, 0.35) : 0.10
	return floor + (1 - floor) * eased

proc/LightAmbientRGB(turf/T)
	var/area/A = T ? T.loc : null
	if(!A) return list(255, 255, 255)
	if(A.dark_cave) return _FxRGB(glob ? glob.LIGHT_CAVE_COLOR : "#2b2b33")
	if(!A.icon) return list(255, 255, 255)
	if(A.plane != BASE_LIGHTING_PLANE && A.blend_mode != BLEND_MULTIPLY) return list(255, 255, 255)
	var/list/c = _FxRGB(A.color)
	return c ? c : list(255, 255, 255)

proc/LightPaintCeiling(list/amb)
	if(!amb) return 244
	var/mx = max(amb[1], max(amb[2], amb[3]))
	var/c = glob ? glob.LIGHT_PAINT_CEILING : 225
	var/lift = glob ? glob.LIGHT_PAINT_LIFT : 12
	return min(244, max(c, mx + lift))

proc/LightBudgetAlpha(turf/T, col, want, artlum = 0)
	if(want <= 0) return want
	var/list/amb = LightAmbientRGB(T)
	if(!amb) return want
	var/list/c = _FxRGB(col)
	if(!c) c = list(255, 255, 255)
	var/mx = max(amb[1], max(amb[2], amb[3]))
	var/ceiling = LightPaintCeiling(amb)
	if(artlum > 0)
		var/target = glob ? glob.LIGHT_ART_TARGET : 190
		ceiling = min(ceiling, max(target * 255 / artlum, mx))
	var/lim = want
	for(var/i = 1, i <= 3, i++)
		if(c[i] <= 0) continue
		lim = min(lim, (ceiling - amb[i]) * 255 / c[i])
	return max(0, round(min(want, lim)))

proc/LightStaticPaintAt(turf/T)
	if(!T || !glob || !glob.LIGHTING) return 0
	var/tot = 0
	for(var/datum/lightsource/L in LightsNearTurf(T, 24))
		var/turf/s = LightSrcTurf(L)
		if(!s || s.z != T.z) continue
		var/rr = L.radius + 0.5
		var/dx = s.x - T.x
		var/dy = s.y - T.y
		var/d = sqrt(dx * dx + dy * dy)
		if(d >= rr) continue
		var/f = 1 - d / rr
		tot += LightBudgetAlpha(s, L.lcolor, round(L.maxalpha * LightRenderStrength(s))) * f * f
	return tot

proc/LightArtTolerance(artlum)
	if(artlum <= 0) return 255
	var/target = glob ? glob.LIGHT_ART_TARGET : 190
	return min(255, target * 255 / artlum)

proc/LightLocalLevel(turf/T)
	var/list/amb = LightAmbientRGB(T)
	var/mx = amb ? max(amb[1], max(amb[2], amb[3])) : 255
	return mx + LightStaticPaintAt(T)

proc/LightGlowBudget(turf/T, col, want, artlum = 0)
	var/b = LightBudgetAlpha(T, col, want, artlum)
	if(b <= 0) return 0
	return max(0, round(b - LightStaticPaintAt(T)))

proc/LightSrcTurf(datum/lightsource/L)
	if(!L) return null
	return L.src_obj ? get_turf(L.src_obj) : locate(L.lx, L.ly, L.lz)

proc/LightBucketKey(turf/T)
	if(!T) return null
	return "[T.z]:[floor((T.x - 1) / LIGHT_BUCKET_SIZE)]:[floor((T.y - 1) / LIGHT_BUCKET_SIZE)]"

proc/LightBucketUnregister(datum/lightsource/L)
	if(!L || !L.bucket_key) return
	var/list/B = _light_buckets[L.bucket_key]
	if(B)
		B -= L
		if(!B.len) _light_buckets -= L.bucket_key
	L.bucket_key = null

proc/LightBucketRegister(datum/lightsource/L)
	if(!L) return
	var/key = LightBucketKey(LightSrcTurf(L))
	if(key == L.bucket_key) return
	LightBucketUnregister(L)
	if(!key) return
	var/list/B = _light_buckets[key]
	if(!B)
		B = list()
		_light_buckets[key] = B
	B |= L
	L.bucket_key = key

proc/LightsNearTurf(turf/T, radius = 24)
	var/list/out = list()
	if(!T) return out
	var/bx = floor((T.x - 1) / LIGHT_BUCKET_SIZE)
	var/by = floor((T.y - 1) / LIGHT_BUCKET_SIZE)
	var/br = ceil(max(1, radius) / LIGHT_BUCKET_SIZE) + 1
	for(var/ix = bx - br, ix <= bx + br, ix++)
		for(var/iy = by - br, iy <= by + br, iy++)
			var/list/B = _light_buckets["[T.z]:[ix]:[iy]"]
			if(B) out |= B
	return out

//occluder = engine opacity, blocks_light, or the turf's surface profile.
//never match on icon filename
proc/IsLightOccluder(turf/T)
	if(!T) return 1
	if(T.opacity) return 1
	if(T.blocks_light) return 1
	return SurfaceOcclusion(T) >= OCCLUDE_FULL

//static casters only - mobs would bake stale wedges, the live shadow system owns them
proc/LightTileCasters(turf/T)
	var/list/out
	for(var/atom/movable/A in T)
		if(ismob(A)) continue
		if(isobj(A))
			var/obj/O = A
			if(O.gfx_transient_visual) continue //transient FX are dynamic too - never bake them
		if(A.invisibility) continue
		if(SurfaceOcclusion(A) <= OCCLUDE_NONE) continue
		if(!out) out = list()
		out += A
	return out

//clear line of light from A to B; sealed diagonal corners block the ray
proc/LightClearLine(turf/A, turf/B)
	if(!A || !B || A.z != B.z) return 0
	var/x0 = A.x
	var/y0 = A.y
	var/x1 = B.x
	var/y1 = B.y
	var/z = A.z
	var/dx = abs(x1 - x0)
	var/dy = abs(y1 - y0)
	var/sx = (x0 < x1) ? 1 : -1
	var/sy = (y0 < y1) ? 1 : -1
	var/err = dx - dy
	var/cx = x0
	var/cy = y0
	var/guard = 0
	while(guard++ < 512)
		var/e2 = 2 * err
		var/stepx = 0
		var/stepy = 0
		if(e2 > -dy)
			err -= dy
			stepx = sx
		if(e2 < dx)
			err += dx
			stepy = sy
		if(stepx && stepy) //diagonal move: a sealed corner blocks the ray
			if(IsLightOccluder(locate(cx + stepx, cy, z)) && IsLightOccluder(locate(cx, cy + stepy, z)))
				return 0
		cx += stepx
		cy += stepy
		if(cx == x1 && cy == y1)
			return 1 //reached the target; its own turf isn't tested as a blocker
		if(IsLightOccluder(locate(cx, cy, z)))
			return 0
	return 1

proc/LightInvalidateGeometry(datum/lightsource/L)
	if(!L) return
	L.visible_turfs = null
	L.geometry_key = null

//recursive octant shadowcasting - each cell visited once; dusk/dawn re-tints reuse the cached visible set
proc/_LightCastOctant(turf/s, radius, row, start_slope, end_slope, xx, xy, yx, yy, list/visible)
	if(!s || start_slope < end_slope) return
	var/new_start = start_slope
	for(var/distance = row, distance <= radius, distance++)
		var/blocked = FALSE
		var/dy = -distance
		for(var/dx = -distance, dx <= 0, dx++)
			var/map_x = s.x + dx * xx + dy * xy
			var/map_y = s.y + dx * yx + dy * yy
			var/left_slope = (dx - 0.5) / (dy + 0.5)
			var/right_slope = (dx + 0.5) / (dy - 0.5)
			if(start_slope < right_slope) continue
			if(end_slope > left_slope) break
			var/turf/T = locate(map_x, map_y, s.z)
			if(T && dx*dx + dy*dy <= radius*radius) visible[T] = 1
			var/opaque = IsLightOccluder(T)
			if(blocked)
				if(opaque)
					new_start = right_slope
				else
					blocked = FALSE
					start_slope = new_start
			else if(opaque && distance < radius)
				blocked = TRUE
				_LightCastOctant(s, radius, distance + 1, start_slope, left_slope, xx, xy, yx, yy, visible)
				new_start = right_slope
		if(blocked) break

proc/LightBuildVisibility(datum/lightsource/L, turf/s)
	if(!L || !s) return null
	var/key = "[s.x],[s.y],[s.z],[L.radius]"
	if(L.visible_turfs && L.geometry_key == key) return L.visible_turfs
	var/list/visible = list()
	visible[s] = 1
	L.geometry_key = key
	for(var/list/O in list(
		list(1,0,0,1), list(0,1,1,0), list(0,-1,1,0), list(-1,0,0,1),
		list(-1,0,0,-1), list(0,-1,-1,0), list(0,1,-1,0), list(1,0,0,-1)))
		_LightCastOctant(s, L.radius, 1, 1, 0, O[1], O[2], O[3], O[4], visible)
	L.visible_turfs = list()
	for(var/turf/T in visible) L.visible_turfs += T
	_light_fov_builds++
	_light_fov_cells += L.visible_turfs.len
	return L.visible_turfs

proc/GfxPaintLightReflections(datum/lightsource/L, list/visible, turf/s, light_strength)
	if(!L || !visible || !s || light_strength < 0.06) return
	_GfxDepthBuildIcons()
	L.reflection_applied = list()
	var/cap = max(12, round(56 * GfxBudgetScale()))
	for(var/turf/T in visible)
		var/surface = GfxTurfReflectionStrength(T)
		if(surface <= 0.1) continue
		//rain-wet ground gets a sparse checker; real water stays continuous
		if(!GfxIsPermanentReflectiveSurface(T) && (T.x + T.y) % 2) continue
		var/ddx = T.x - s.x
		var/ddy = T.y - s.y
		var/d = sqrt(ddx*ddx + ddy*ddy)
		var/falloff = 1 - d / (L.radius + 0.5)
		if(falloff <= 0) continue
		var/a = round(L.maxalpha * falloff * falloff * light_strength * surface * 0.48)
		if(a < 3) continue
		var/image/I = image(_gfx_light_reflection_icon, T)
		I.plane = REFLECTION_PLANE
		I.layer = 1.2
		I.blend_mode = BLEND_ADD
		I.color = L.lcolor
		I.alpha = a
		I.pixel_x = 7 + clamp((s.x - T.x) * 2, -9, 9)
		I.pixel_y = 1 + clamp((s.y - T.y), -5, 5)
		I.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART
		T.overlays += I
		L.reflection_applied[T] = I
		if(--cap <= 0) break

//corner-gradient lighting
var/icon/_corner_light_icon
proc/CornerLightIcon()
	if(_corner_light_icon) return _corner_light_icon
	var/icon/I = new('sandstorm.dmi')
	for(var/py = 1, py <= 32, py++)
		var/fy = (py - 0.5) / 32 //icon y runs bottom-up: fy 1 = north
		for(var/px = 1, px <= 32, px++)
			var/fx = (px - 0.5) / 32
			I.DrawBox(rgb(round(255 * (1 - fx) * fy), round(255 * fx * fy), round(255 * (1 - fx) * (1 - fy))), px, py)
	_corner_light_icon = I
	return I

proc/_LightColorVec(c) //"#rrggbb" -> r,g,b fractions
	if(!istext(c)) return list(1, 1, 1)
	return list(text2num(copytext(c, 2, 4), 16) / 255, text2num(copytext(c, 4, 6), 16) / 255, text2num(copytext(c, 6, 8), 16) / 255)

proc/_LightCornerPaint(datum/lightsource/L, turf/s, list/visible, lightStrength)
	var/a = round(255 * lightStrength)
	if(a < 3) return
	var/icon/CI = CornerLightIcon()
	var/rr = L.radius
	var/scale = L.maxalpha / 255
	var/list/cvec = _LightColorVec(L.lcolor)
	var/cr = cvec[1] * scale
	var/cg = cvec[2] * scale
	var/cb = cvec[3] * scale
	//pass 1: corner brightness at every lattice point touching a visible turf
	var/list/corner = list()
	for(var/turf/T in visible)
		for(var/cy = T.y, cy <= T.y + 1, cy++)
			for(var/cx = T.x, cx <= T.x + 1, cx++)
				var/key = "[cx]:[cy]"
				if(corner[key] != null) continue
				var/ddx = cx - 0.5 - s.x
				var/ddy = cy - 0.5 - s.y
				var/f = 1 - sqrt(ddx * ddx + ddy * ddy) / (rr + 0.5)
				corner[key] = max(f > 0 ? f * f : 0, glob.LIGHT_FILL) //fill = indirect floor
	//pass 2: one gradient image per visible turf
	for(var/turf/T in visible)
		var/iSW = corner["[T.x]:[T.y]"]
		var/iSE = corner["[T.x + 1]:[T.y]"]
		var/iNW = corner["[T.x]:[T.y + 1]"]
		var/iNE = corner["[T.x + 1]:[T.y + 1]"]
		if(iSW <= 0.01 && iSE <= 0.01 && iNW <= 0.01 && iNE <= 0.01) continue
		var/image/ov = image(CI, T)
		ov.blend_mode = BLEND_ADD
		ov.color = list(\
			(iNW - iSE) * cr, (iNW - iSE) * cg, (iNW - iSE) * cb, 0,\
			(iNE - iSE) * cr, (iNE - iSE) * cg, (iNE - iSE) * cb, 0,\
			(iSW - iSE) * cr, (iSW - iSE) * cg, (iSW - iSE) * cb, 0,\
			0, 0, 0, 1,\
			iSE * cr, iSE * cg, iSE * cb, 0)
		ov.alpha = a
		if(glob.MULTIPLY_REVEAL)
			ov.plane = BASE_LIGHTING_PLANE //straight into the *fxbase merge, unblurred
			ov.layer = 6.6
		else
			ov.plane = 0 //direct draw above the 6.5 blanket; the blurred buffer would mush the gradient
			ov.layer = LIGHT_OVERLAY_LAYER
		ov.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART
		T.overlays += ov
		L.applied[T] = ov

//shadow volumes: two affine triangles per occluder, so edges stay straight at any angle
var/icon/_uni_tri_icon //32px black right triangle, anti-aliased hypotenuse
var/icon/_uni_tri_dapple //same triangle, broken up - foliage shadows read as leaf-litter

proc/UniShadowTriIcon(dapple = 0)
	if(dapple)
		if(_uni_tri_dapple) return _uni_tri_dapple
		var/icon/D = new('sandstorm.dmi')
		for(var/py = 1, py <= 32, py++)
			for(var/px = 1, px <= 32, px++)
				var/a = clamp(round((33.5 - (px + py)) * 255), 0, 255)
				//coarse pseudo-noise so gaps are chunky enough to survive the blur
				var/n = (px * 7 + py * 13 + ((px / 3) % 5) * 29 + ((py / 3) % 7) * 17) % 100
				if(n < 42) a = round(a * 0.25)
				else if(n < 68) a = round(a * 0.62)
				D.DrawBox(rgb(0, 0, 0, a), px, py)
		_uni_tri_dapple = D
		return D
	if(_uni_tri_icon) return _uni_tri_icon
	var/icon/I = new('sandstorm.dmi')
	for(var/py = 1, py <= 32, py++)
		for(var/px = 1, px <= 32, px++)
			I.DrawBox(rgb(0, 0, 0, clamp(round((33.5 - (px + py)) * 255), 0, 255)), px, py)
	_uni_tri_icon = I
	return I

//map the icon's unit triangle (P0 bottom-left, P1 bottom-right, P2 top-left; hypotenuse
//P1-P2 carries the soft edge) onto any 3 points, in px relative to the light obj's center
proc/_UniShadowTri(obj/O, p0x, p0y, p1x, p1y, p2x, p2y, strength = 1, dapple = 0)
	var/image/T = image(UniShadowTriIcon(dapple))
	T.blend_mode = BLEND_MULTIPLY
	T.layer = 2
	T.alpha = round(255 * clamp(strength, 0, 1)) //partial occluders keep some light
	T.appearance_flags = RESET_COLOR | RESET_ALPHA
	T.transform = matrix((p1x - p0x) / 32, (p2x - p0x) / 32, p0x + (p1x - p0x) / 2 + (p2x - p0x) / 2,
	                     (p1y - p0y) / 32, (p2y - p0y) / 32, p0y + (p1y - p0y) / 2 + (p2y - p0y) / 2)
	O.overlays += T

//cookies are baked facing SOUTH; matrix.Turn is clockwise, so S -> W -> N -> E
proc/_LightCookieAngle(d)
	switch(d)
		if(WEST) return 90
		if(NORTH) return 180
		if(EAST) return 270
	return 0

//beam edges are baked to the pool's edge formula, so the frustum lands exactly on it
proc/_LightBeamState(cookie)
	switch(cookie)
		if("panes") return "beam"
		if("arch") return "beam2"
	return null

proc/UniPaintLight(datum/lightsource/L, turf/s, list/visible, lightStrength)
	var/a = round(L.maxalpha * lightStrength)
	if(a < 3) return
	if(!_fx_glow_icon) _FxBuildIcons()
	if(!_fx_glow_icon) return
	var/rr = L.radius
	//pixel space anchors at the tile center; the light origin can sit elsewhere (lamp head)
	var/tcx = s.x + 0.5
	var/tcy = s.y + 0.5
	var/lcx = tcx + L.off_x / 32
	var/lcy = tcy + L.off_y / 32
	L.uni_objs = list()
	//one KT composite per light: smooth pool, shadow volumes cut out of it, wall faces relit
	var/obj/gfx_uni_light/U = new(s)
	U.color = L.lcolor
	U.alpha = a
	if(glob.UNI_MASK_BLUR > 0)
		U.filters = filter(type = "blur", size = glob.UNI_MASK_BLUR)
	var/image/R
	if(L.cookie)
		//shaped pool: a baked cookie (falloff pre-multiplied in) replaces the plain radial
		R = image('light_cookies.dmi')
		R.icon_state = L.cookie
		var/matrix/CM = matrix() * (rr * 2 * 32 / 128) //128px cookie scaled out to the radius
		var/ca = _LightCookieAngle(L.cookie_dir)
		if(ca) CM.Turn(ca)
		R.transform = CM
		R.pixel_x = -48 + L.off_x
		R.pixel_y = -48 + L.off_y
		//the beam rides the same transform as the pool
		if(glob.GOD_RAYS && L.shaft != 0)
			var/bs = _LightBeamState(L.cookie)
			if(bs)
				var/image/B = image('light_cookies.dmi')
				B.icon_state = bs
				B.transform = CM
				B.pixel_x = -48 + L.off_x
				B.pixel_y = -48 + L.off_y
				B.layer = 4 //in the air: over the shadow volumes and the lit wall slabs
				B.appearance_flags = RESET_COLOR | RESET_ALPHA
				U.overlays += B
	else
		R = image(_fx_glow_icon)
		R.transform = matrix() * (rr * 2 * 32 / 64) //64px glow icon scaled out to the radius
		R.pixel_x = -16 + L.off_x
		R.pixel_y = -16 + L.off_y
	R.layer = 1
	R.appearance_flags = RESET_COLOR | RESET_ALPHA
	U.overlays += R
	//flat fill disc under the shadow volumes: walls block it, prop shadows pass some bounce
	if(glob.LIGHT_FILL > 0 && _fx_fill_icon)
		var/image/F = image(_fx_fill_icon)
		F.transform = matrix() * (rr * 2 * 32 / 64 * 1.12) //a shade past the pool edge
		F.pixel_x = -16 + L.off_x
		F.pixel_y = -16 + L.off_y
		F.alpha = round(255 * min(glob.LIGHT_FILL, 0.5))
		F.layer = 1.1
		F.appearance_flags = RESET_COLOR | RESET_ALPHA
		U.overlays += F
	var/proj = (rr + 2) * 2 //push the far edge of each volume well past the pool
	//casters: occluding turfs, plus props/foliage/actors standing on visible turfs
	var/list/casters = list()
	for(var/turf/T in visible)
		if(T == s) continue //never shadow from the light's own tile - the lamp/campfire
		if(IsLightOccluder(T))
			casters[T] = T
			continue
		if(SurfaceOcclusion(T) > OCCLUDE_NONE) //edge/partial TURFS cast too, not just walls
			casters[T] = T
		var/list/tc = LightTileCasters(T)
		if(tc)
			for(var/atom/movable/A in tc)
				if(A == L.src_obj) continue //a moved light still must not occlude itself
				casters[A] = T
	for(var/atom/C in casters)
		var/turf/T = casters[C]
		var/slen = SurfaceShadowLen(C)
		var/sstr = SurfaceShadowStrength(C)
		if(sstr <= 0) continue
		var/dap = (SurfaceOcclusion(C) == OCCLUDE_DAPPLE)
		var/ax; var/ay; var/bx; var/by
		var/edir = SurfaceEdgeDir(C)
		if(edir)
			//edge tiles: lit from the high side, the shadow falls off the named face at partial strength
			var/list/EC = SurfaceEdgeCorners(T.x, T.y, edir)
			if(!EC) continue
			var/mx = (EC[1] + EC[3]) / 2
			var/my = (EC[2] + EC[4]) / 2
			var/nx = (edir == EAST) ? 1 : (edir == WEST) ? -1 : 0
			var/ny = (edir == NORTH) ? 1 : (edir == SOUTH) ? -1 : 0
			if((lcx - mx) * nx + (lcy - my) * ny >= 0)
				//lit from the open (low) side light must not climb the cliff - full block behind the lip
				sstr = 1
				slen = SHADOW_INFINITE
			ax = EC[1]; ay = EC[2]; bx = EC[3]; by = EC[4]
		else
			//silhouette corners = the tile's angular extremes seen from the light
			var/base = arctan(T.x + 0.5 - lcx, T.y + 0.5 - lcy)
			var/lo = 999
			var/hi = -999
			for(var/ci = 0, ci <= 3, ci++)
				var/cx = T.x + (ci & 1)
				var/cy = T.y + (ci >> 1)
				var/rel = arctan(cx - lcx, cy - lcy) - base
				while(rel <= -180) rel += 360
				while(rel > 180) rel -= 360
				if(rel < lo)
					lo = rel
					ax = cx
					ay = cy
				if(rel > hi)
					hi = rel
					bx = cx
					by = cy
		var/adx = ax - lcx
		var/ady = ay - lcy
		var/bdx = bx - lcx
		var/bdy = by - lcy
		var/da = sqrt(adx * adx + ady * ady)
		var/db = sqrt(bdx * bdx + bdy * bdy)
		if(da < 0.1 || db < 0.1) continue
		//SHADOW_INFINITE (walls) runs to the pool edge; props stop slen tiles past themselves
		var/ka = (slen == SHADOW_INFINITE) ? proj / da : (da + slen) / da
		var/kb = (slen == SHADOW_INFINITE) ? proj / db : (db + slen) / db
		//rays radiate from the light ORIGIN, but pixel space is anchored to the TILE center
		var/dox = lcx - tcx
		var/doy = lcy - tcy
		var/a1x = (adx + dox) * 32; var/a1y = (ady + doy) * 32
		var/b1x = (bdx + dox) * 32; var/b1y = (bdy + doy) * 32
		var/a2x = (adx * ka + dox) * 32; var/a2y = (ady * ka + doy) * 32
		var/b2x = (bdx * kb + dox) * 32; var/b2y = (bdy * kb + doy) * 32
		//quad A -> B -> B' -> A', split so both ray edges ride the icon's soft hypotenuse
		_UniShadowTri(U, a1x, a1y, b1x, b1y, b2x, b2y, sstr, dap)
		_UniShadowTri(U, b2x, b2y, a2x, a2y, a1x, a1y, sstr, dap)
	//lit wall faces stay full slabs - repaint over their own volumes
	for(var/turf/T in visible)
		if(!IsLightOccluder(T) || T == s) continue
		var/wdx = T.x + 0.5 - lcx
		var/wdy = T.y + 0.5 - lcy
		var/f = 1 - sqrt(wdx * wdx + wdy * wdy) / (rr + 0.5)
		if(f <= 0) continue
		var/image/WB = image(EnvWhiteIcon())
		WB.layer = 3
		WB.alpha = round(255 * f * f)
		WB.pixel_x = (T.x - s.x) * 32
		WB.pixel_y = (T.y - s.y) * 32
		WB.appearance_flags = RESET_COLOR | RESET_ALPHA
		U.overlays += WB
	L.uni_objs += U

/obj/gfx_uni_light
	gfx_transient_visual = 1
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	plane = BASE_LIGHTING_PLANE
	layer = 6.6
	appearance_flags = KEEP_TOGETHER | KEEP_APART
	pixel_x = 0
	pixel_y = 0

//soft-clip: overlapping neighbors attenuate a light so sums don't clip to white
proc/_LightOverlapScale(datum/lightsource/L, turf/s)
	var/o = 0
	for(var/datum/lightsource/M in LightsNearTurf(s, 24))
		if(M == L) continue
		var/turf/ms = LightSrcTurf(M)
		if(!ms || ms.z != s.z) continue
		var/reach = L.radius + M.radius
		if(reach <= 0) continue
		var/ddx = ms.x - s.x
		var/ddy = ms.y - s.y
		var/d = sqrt(ddx * ddx + ddy * ddy)
		if(d >= reach) continue
		o += 1 - d / reach
	return 1 / (1 + o)

//compute + paint a light's occluded footprint
proc/LightCompute(datum/lightsource/L)
	LightClear(L)
	if(!glob || !glob.LIGHTING || !L) return
	var/turf/s = LightSrcTurf(L)
	if(!s) return
	LightBucketRegister(L)
	var/darkFrac = LightDarkFrac(s) //true ambient darkness; retained for cheap repaint detection
	var/lightStrength = LightRenderStrength(s)
	if(glob.LIGHT_SOFTCLIP) lightStrength *= _LightOverlapScale(L, s)
	if(L.maxalpha > 0)
		lightStrength = min(lightStrength, LightBudgetAlpha(s, L.lcolor, L.maxalpha) / L.maxalpha)
	L.painted_dark = darkFrac
	UpdateFlameGlow(L, lightStrength)
	L.applied = list()
	var/rr = L.radius
	var/list/visible = LightBuildVisibility(L, s)
	if(glob.UNIFIED_LIGHTS)
		UniPaintLight(L, s, visible, lightStrength)
	else if(glob.CORNER_LIGHTS)
		_LightCornerPaint(L, s, visible, lightStrength)
	else
		for(var/turf/T in visible)
			var/ddx = T.x - s.x
			var/ddy = T.y - s.y
			var/d = sqrt(ddx * ddx + ddy * ddy)
			var/falloff = 1 - (d / (rr + 0.5))
			falloff *= falloff //smooth edge
			falloff = max(falloff, glob.LIGHT_FILL) //indirect floor inside the visible set
			var/a = round(L.maxalpha * falloff * lightStrength)
			if(a < 3) continue
			var/image/ov = image(EnvWhiteIcon(), T)
			ov.blend_mode = BLEND_ADD
			ov.color = L.lcolor
			ov.alpha = a
			ov.layer = LIGHT_OVERLAY_LAYER
			ov.plane = LIGHTING_PLANE //rendered + blurred by the lighting plane master, then relayed
			ov.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART
			T.overlays += ov
			L.applied[T] = ov
	GfxPaintLightReflections(L, visible, s, lightStrength)

proc/LightClear(datum/lightsource/L)
	if(L && L.uni_objs)
		for(var/obj/O in L.uni_objs)
			O.loc = null //refcount-free, never del
		L.uni_objs = null
	if(L && L.applied)
		for(var/turf/T in L.applied)
			if(T) T.overlays -= L.applied[T]
		L.applied = null
	if(L && L.reflection_applied)
		for(var/turf/T in L.reflection_applied)
			if(T) T.overlays -= L.reflection_applied[T]
		L.reflection_applied = null

//budgeted worker - repainting every light in one tick froze the server ~20s
var/_light_applyall_state = 0

proc/LightingApplyAll()
	if(_light_applyall_state)
		_light_applyall_state = 2 //state jumped again mid-pass: restart with fresh values
		return
	_light_applyall_state = 1
	spawn(-1) _LightApplyAllWorker()

proc/_LightApplyAllWorker()
	set waitfor = 0
	set background = 1
	do
		_light_applyall_state = 1
		var/n = 0
		for(var/datum/lightsource/L in _light_sources.Copy())
			if(_light_applyall_state == 2) break
			if(!(L in _light_sources)) continue //removed while we slept
			if(world.tick_usage > 70) sleep(2)
			LightCompute(L)
			if(++n % 6 == 0) sleep(1)
	while(_light_applyall_state == 2)
	_light_applyall_state = 0

//re-tint lights as dusk/dawn moves; clock jumps call LightingApplyAll directly
var/_light_boot = _LightBoot()
proc/_LightBoot()
	spawn(95)
		_LightLoop()
	return 1

proc/_LightLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.LIGHTING)
			var/n = 0
			for(var/datum/lightsource/L in _light_sources.Copy()) //Copy: we sleep mid-pass now
				if(!(L in _light_sources)) continue
				var/turf/s = LightSrcTurf(L)
				if(!s) continue
				if(abs(LightDarkFrac(s) - L.painted_dark) > 0.02)
					LightCompute(L)
					if(++n % 8 == 0) sleep(1) //a clock jump stales EVERY light - never burst one tick
		sleep(10)

proc/LightingClearAll()
	for(var/datum/lightsource/L in _light_sources)
		LightClear(L)
		KillFlame(L) //lighting off: also stop + drop the flame glows

//place a light at a world point and paint it
proc/AddLightSource(turf/T, radius, lcolor, maxalpha)
	if(!T) return null
	var/datum/lightsource/L = new
	L.lx = T.x
	L.ly = T.y
	L.lz = T.z
	L.radius = clamp(radius || glob.LIGHT_DEFAULT_RADIUS, 1, 20) //cap: bound the range() scan + LOS length
	L.lcolor = lcolor || glob.LIGHT_DEFAULT_COLOR
	L.maxalpha = maxalpha || glob.LIGHT_MAX_ALPHA
	_light_sources += L
	LightBucketRegister(L)
	LightCompute(L)
	if(glob.LIGHT_SOFTCLIP && _lights_settled) LightingRecomputeNear(T) //neighbors re-attenuate
	return L

proc/RemoveLightSource(datum/lightsource/L)
	if(!L) return
	var/turf/st = LightSrcTurf(L)
	LightClear(L)
	KillFlame(L)
	if(L.src_obj) Hd2dEmberClear(L.src_obj)
	LightBucketUnregister(L)
	_light_sources -= L
	if(glob.LIGHT_SOFTCLIP && _lights_settled && st) LightingRecomputeNear(st) //survivors brighten back

obj/var/tmp/datum/lightsource/attached_light

proc/LightPropAttach(obj/O, radius, lcolor, maxalpha, flicker = 0, off_x = 0, off_y = 0, cookie = null, cookie_dir = 0, shaft = null)
	if(!O || O.attached_light) return
	if(!get_turf(O)) return //build-panel phantom (Add_Builds new()s every prop with no loc) - don't register a dead light
	PurgeStaleFlameVisuals(O) //old saves can carry baked-in flame visuals - scrub them
	var/datum/lightsource/L = new
	L.src_obj = O
	L.radius = clamp(radius || glob.LIGHT_DEFAULT_RADIUS, 1, 20)
	L.lcolor = lcolor || glob.LIGHT_DEFAULT_COLOR
	L.maxalpha = maxalpha || glob.LIGHT_MAX_ALPHA
	L.flicker = flicker
	L.off_x = off_x
	L.off_y = off_y
	L.cookie = cookie
	L.cookie_dir = cookie_dir || SOUTH
	L.shaft = shaft
	_light_sources += L
	O.attached_light = L
	LightBucketRegister(L)
	LightCompute(L)
	if(glob.LIGHT_SOFTCLIP && _lights_settled) LightingRecomputeNear(get_turf(O)) //neighbors re-attenuate
	Hd2dEmberAttach(O, L) //fire-type lights (flicker) shed color-matched embers

// flame flicker
/obj/flamelight
	plane = LIGHTING_PLANE
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	layer = 6.56
	gfx_transient_visual = 1
	var/tmp/active = 0
	var/tmp/dark = 1 //current ambient darkness - scales the flicker so it dims at dusk

proc/KillFlame(datum/lightsource/L) //drop refs, refcount-free (never del)
	if(!L || !L.flame) return
	L.flame.active = 0
	if(L.src_obj) L.src_obj.vis_contents -= L.flame
	L.flame.loc = null
	L.flame = null

proc/PurgeStaleFlameVisuals(atom/movable/O)
	if(!O) return
	var/list/stale = list()
	for(var/obj/flamelight/F in O.vis_contents)
		stale += F
	for(var/obj/flamelight/F in stale)
		F.active = 0
		O.vis_contents -= F
		F.loc = null

proc/UpdateFlameGlow(datum/lightsource/L, lightStrength)
	if(!L || !L.flicker) return
	var/atom/movable/O = L.src_obj
	if(!O) return
	if(lightStrength > 0)
		if(!L.flame)
			PurgeStaleFlameVisuals(O)
			if(!_fx_glow_icon) _FxBuildIcons()
			var/obj/flamelight/F = new
			F.icon = _fx_glow_icon //radial alpha stays soft even when a client's blur pass is disabled
			F.color = L.lcolor
			F.pixel_x = -16
			F.pixel_y = -16
			F.transform = matrix() * 0.9
			F.active = 1
			F.dark = min(lightStrength, LightBudgetAlpha(get_turf(O), L.lcolor, glob.FLICKER_MAX) / max(glob.FLICKER_MAX, 1))
			F.alpha = round((glob.FLICKER_MIN + glob.FLICKER_MAX) / 2 * F.dark) //start at settled brightness, not default 255
			O.vis_contents += F
			L.flame = F
			FlameFlicker(F)
		else
			L.flame.dark = min(lightStrength, LightBudgetAlpha(get_turf(O), L.lcolor, glob.FLICKER_MAX) / max(glob.FLICKER_MAX, 1)) //re-tint amplitude as the clock changes
	else
		KillFlame(L)

proc/FlameFlicker(obj/flamelight/F)
	set waitfor = 0
	set background = 1
	while(F && F.active)
		var/na = round(rand(glob.FLICKER_MIN, glob.FLICKER_MAX) * F.dark)
		animate(F, alpha = na, time = rand(2, 4))
		sleep(rand(2, 5))

// canopy shafts
//sp_shaft trees drop a sun column; the tick loop drives alpha from sun/sky/weather
var/list/_canopy_shafts = list()

/obj/gfx_canopy_shaft
	icon = 'light_cookies.dmi'
	icon_state = "canopy_shaft"
	gfx_transient_visual = 1
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	plane = 0
	layer = 6.56
	alpha = 0 //the tick loop fades it in when sun/sky/weather allow
	var/tmp/atom/movable/shaft_host

atom/movable/var/tmp/obj/gfx_canopy_shaft/gfx_canopy_shaft_obj

proc/CanopyShaftAttach(atom/movable/A)
	if(!A || A.gfx_canopy_shaft_obj) return
	for(var/obj/gfx_canopy_shaft/old in A.vis_contents) //toggle spam must never stack children
		A.vis_contents -= old
		_canopy_shafts -= old
		old.loc = null
	var/obj/gfx_canopy_shaft/S = new
	S.shaft_host = A
	var/vh = SurfaceVisualHeight(A)
	S.pixel_x = -48 //128px icon centered on the tile
	S.pixel_y = round(vh * 0.72) - 64 //icon center at the canopy; the column falls to the ground
	A.vis_contents += S
	A.gfx_canopy_shaft_obj = S
	_canopy_shafts += S

proc/CanopyShaftDetach(atom/movable/A)
	if(!A || !A.gfx_canopy_shaft_obj) return
	var/obj/gfx_canopy_shaft/S = A.gfx_canopy_shaft_obj
	A.vis_contents -= S
	_canopy_shafts -= S
	S.shaft_host = null
	S.loc = null //refcount-free, never del
	A.gfx_canopy_shaft_obj = null

proc/_CanopyShaftTick()
	set waitfor = 0
	set background = 1
	while(1)
		if(_canopy_shafts.len)
			var/list/sp = SunShadowParams()
			var/elev = 1 - clamp((sp[2] - glob.SHADOW_LEN_MIN) / max(0.001, glob.SHADOW_LEN_MAX - glob.SHADOW_LEN_MIN), 0, 1)
			var/isMoon = sp[4]
			var/lean = -arctan(sp[1]) * 0.5 //same lean as the ambient sheet so they never fight
			var/matrix/LM = matrix()
			LM.Turn(lean)
			for(var/obj/gfx_canopy_shaft/S in _canopy_shafts.Copy())
				var/atom/movable/A = S.shaft_host
				if(!A || !A.loc || A.gfx_canopy_shaft_obj != S) //host died or was re-tagged
					_canopy_shafts -= S
					S.shaft_host = null
					S.loc = null
					continue
				var/turf/t = get_turf(A)
				var/area/ar = t ? t.loc : null
				var/a = 0
				if(glob.GOD_RAYS && ar && ar.sees_sky && !ar.wx_kind)
					if(isMoon)
						a = glob.MOON_SHAFTS ? 70 * elev * MoonEventK() : 0 //full-moon spectacle only
					else
						a = 110 * (0.35 + 0.65 * elev) * (1 - DnDarknessFrac() * 0.6)
				animate(S, alpha = round(clamp(a, 0, 255)), time = 20)
				S.transform = LM
				S.color = isMoon ? "#aebfe8" : "#fff0c8"
		sleep(150)

var/_canopy_shaft_boot = _CanopyShaftBoot()
proc/_CanopyShaftBoot()
	spawn(110)
		_CanopyShaftTick()
	return 1

//emissive reveal: a vis child that keeps the sprite at full color through darkness
//MR on = white stamp into the unblurred base buffer; off = fullbright copy above the blanket
obj/var/emissive_tier = 0 //set per type or per map instance; boot sweep picks up tagged props
obj/var/tmp/obj/gfx_emissive/attached_emissive

var/list/_gfx_emissives = list() //child -> host prop
var/list/_fx_emissive_white

/obj/gfx_emissive
	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR
	appearance_flags = KEEP_APART //a KEEP_TOGETHER parent would flatten the stamp off its plane
	gfx_transient_visual = 1
	mouse_opacity = 0
	var/tmp/obj/fx_lightglow/halo

proc/FxEmissiveWhite() //constant-row matrix: every visible pixel -> pure white, alpha kept
	if(!_fx_emissive_white) _fx_emissive_white = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 1,1,1,0)
	return _fx_emissive_white

proc/FxEmissiveConfig(obj/gfx_emissive/E, obj/O)
	if(!E) return
	if(glob && glob.MULTIPLY_REVEAL)
		E.plane = BASE_LIGHTING_PLANE 
		E.layer = 6.56
		E.blend_mode = BLEND_ADD
		E.color = FxEmissiveWhite()
	else
		E.plane = 0
		E.layer = 6.52 //above the 6.5 blanket, below the 6.55 glows
		E.blend_mode = BLEND_OVERLAY
		E.color = (O && istext(O.color)) ? O.color : null //keep mapper tints on the redraw
	E.alpha = (glob && glob.EMISSIVES) ? 255 : 0

proc/PurgeStaleEmissives(atom/movable/O)
	if(!O) return
	var/list/stale = list()
	for(var/obj/gfx_emissive/E in O.vis_contents)
		stale += E
	for(var/obj/gfx_emissive/E in stale)
		_gfx_emissives -= E
		O.vis_contents -= E
		E.loc = null

proc/FxEmissiveAttach(obj/O, tier = 0)
	if(!O || O.attached_emissive) return
	if(!get_turf(O)) return //build-panel phantom guard, same as the light props
	if(tier) O.emissive_tier = tier
	if(!O.emissive_tier) return
	PurgeStaleEmissives(O)
	var/obj/gfx_emissive/E = new
	FxEmissiveConfig(E, O)
	O.vis_contents += E
	O.attached_emissive = E
	_gfx_emissives[E] = O
	if(O.emissive_tier >= EMISSIVE_GLOW)
		if(!_fx_glow_icon) _FxBuildIcons()
		if(_fx_glow_icon)
			var/obj/fx_lightglow/H = new
			H.icon = _fx_glow_icon
			H.color = FxIconColor(O.icon, O.icon_state) || "#cfe4ff"
			H.alpha = 0 //the loop fades it with the clock
			H.transform = matrix() * 0.8
			H.pixel_x = -16
			H.pixel_y = -16
			if(glob && glob.MULTIPLY_REVEAL) H.plane = LIGHTING_PLANE
			O.vis_contents += H
			E.halo = H

proc/FxEmissiveDetach(obj/O)
	if(!O || !O.attached_emissive) return
	var/obj/gfx_emissive/E = O.attached_emissive
	_gfx_emissives -= E
	if(E.halo)
		O.vis_contents -= E.halo
		E.halo.loc = null //refcount-free, never del
		E.halo = null
	O.vis_contents -= E
	E.loc = null
	O.attached_emissive = null

//re-seat every stamp when multiply-reveal or the master toggle flips
proc/FxEmissiveApplyMode()
	for(var/obj/gfx_emissive/E in _gfx_emissives)
		var/obj/O = _gfx_emissives[E]
		FxEmissiveConfig(E, O)
		if(E.halo)
			E.halo.plane = (glob && glob.MULTIPLY_REVEAL) ? LIGHTING_PLANE : 0
			if(!glob || !glob.EMISSIVES) E.halo.alpha = 0

//one background tick scales glow halos with the clock; flame props ride the flicker system instead
proc/_FxEmissiveLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.EMISSIVES)
			for(var/obj/gfx_emissive/E in _gfx_emissives)
				if(!E.halo) continue
				var/obj/O = _gfx_emissives[E]
				var/turf/T = O ? get_turf(O) : null
				animate(E.halo, alpha = T ? LightGlowBudget(T, E.halo.color, round(120 * LightRenderStrength(T))) : 0, time = 10)
		sleep(100)

proc/_FxEmissiveBoot()
	spawn(80) //after build/load settles
		for(var/obj/O in world)
			if(O.emissive_tier && !O.attached_emissive && O.loc)
				FxEmissiveAttach(O)
		_FxEmissiveLoop()
	return 1
var/_fx_emissive_boot = _FxEmissiveBoot()

proc/LightPropDetach(obj/O)
	if(!O || !O.attached_light) return
	RemoveLightSource(O.attached_light)
	O.attached_light = null

obj/Turfs/LightProp
	icon = 'Objects.dmi'
	icon_state = "Torch1"
	density = 1
	name = "Torch"
	var/lp_radius = 5
	var/lp_color = "#ffb060"
	var/lp_alpha = 170
	var/lp_flicker = 1 //flame props waver; steady lamps set 0
	emissive_tier = EMISSIVE_REVEAL //light props never darken
	New()
		. = ..()
		spawn(3) 
			LightPropAttach(src, lp_radius, lp_color, lp_alpha, lp_flicker)
			FxEmissiveAttach(src)
	Del()
		LightPropDetach(src)
		FxEmissiveDetach(src)
		..()

	Campfire
		name = "Campfire"
		icon_state = "Fire"
		lp_radius = 7
		lp_color = "#ff8038"
		lp_alpha = 185
	Lamp
		name = "Lamp"
		icon_state = "Torch2"
		lp_radius = 6
		lp_color = "#fff0c0"
		lp_flicker = 0 //steady electric light
	BlueLamp
		name = "Blue Lamp"
		icon_state = "Torch2"
		lp_radius = 6
		lp_color = "#7fb0ff"
		lp_flicker = 0
	GreenLamp
		name = "Green Lamp"
		icon_state = "Torch2"
		lp_radius = 6
		lp_color = "#8fffb0"
		lp_flicker = 0

obj/Turfs
	Torch1/New()
		. = ..()
		spawn(3)
			LightPropAttach(src, 5, "#ffb060", 170, 1)
			FxEmissiveAttach(src, EMISSIVE_REVEAL)
	Torch1/Del()
		LightPropDetach(src)
		FxEmissiveDetach(src)
		..()
	Torch2/New()
		. = ..()
		spawn(3)
			LightPropAttach(src, 5, "#ffb060", 170, 1)
			FxEmissiveAttach(src, EMISSIVE_REVEAL)
	Torch2/Del()
		LightPropDetach(src)
		FxEmissiveDetach(src)
		..()
	Torch3/New()
		. = ..()
		spawn(3)
			LightPropAttach(src, 5, "#ffb060", 170, 1)
			FxEmissiveAttach(src, EMISSIVE_REVEAL)
	Torch3/Del()
		LightPropDetach(src)
		FxEmissiveDetach(src)
		..()
	Fire/New()
		. = ..()
		spawn(3)
			LightPropAttach(src, 7, "#ff8038", 185, 1)
			FxEmissiveAttach(src, EMISSIVE_REVEAL)
	Fire/Del()
		LightPropDetach(src)
		FxEmissiveDetach(src)
		..()

//a turf's occluder state changed (wall destroyed/built): recompute the lights it could touch
proc/LightingRecomputeNear(turf/T)
	GfxAOInvalidateNear(T)
	if(!glob || !glob.LIGHTING || !T) return
	for(var/datum/lightsource/L in LightsNearTurf(T, 22))
		if(L.last_recompute == world.time) continue //a burst of wall changes this tick recomputes each light at most once
		var/turf/s = LightSrcTurf(L)
		if(!s || s.z != T.z) continue
		if(abs(s.x - T.x) <= L.radius + 1 && abs(s.y - T.y) <= L.radius + 1)
			L.last_recompute = world.time
			LightInvalidateGeometry(L)
			LightCompute(L)

//queued worker - the synchronous version stalled ~21s repainting every light in one tick
var/list/_light_refresh_areas = list()
var/_light_refresh_running = 0

proc/LightingRefreshReflectionsForArea(area/A)
	if(!A || !glob || !glob.LIGHTING) return
	_light_refresh_areas |= A
	if(!_light_refresh_running)
		_light_refresh_running = 1
		spawn(-1) _LightRefreshWorker()

proc/_LightRefreshWorker()
	set waitfor = 0
	set background = 1
	while(_light_refresh_areas.len)
		var/area/A = _light_refresh_areas[1]
		_light_refresh_areas.Cut(1, 2)
		var/n = 0
		for(var/datum/lightsource/L in _light_sources.Copy()) //Copy: lights attach/remove while we sleep
			if(world.tick_usage > 70) sleep(2)
			var/turf/s = LightSrcTurf(L)
			if(!s) continue
			var/touches = s.loc == A
			if(!touches && L.visible_turfs)
				for(var/turf/T in L.visible_turfs)
					if(T.loc == A)
						touches = TRUE
						break
			if(!touches) continue
			if(!(L in _light_sources)) continue //removed while queued
			LightCompute(L)
			if(++n % 4 == 0) sleep(1)
	_light_refresh_running = 0

/mob/Admin2/verb/Lighting_Toggle()
	set category = "Admin"
	set name = "Lighting Toggle"
	glob.LIGHTING = !glob.LIGHTING
	if(glob.LIGHTING)
		LightingApplyAll()
	else
		LightingClearAll()
	for(var/client/C) //enable/disable the lighting-plane blur pass to match
		FxApplyLightBlur(C)
	src << "Dynamic lighting: [glob.LIGHTING ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set lighting to [glob.LIGHTING].")

/mob/Admin2/verb/Place_Light()
	set category = "Admin"
	set name = "Place Light"
	if(!glob.LIGHTING)
		src << "Lighting is OFF - toggle it on first (Lighting Toggle)."
		return
	var/r = input(src, "Light radius (tiles, 1-20)?") as num|null
	if(isnull(r)) return
	var/datum/lightsource/L = AddLightSource(get_turf(src), r, glob.LIGHT_DEFAULT_COLOR, glob.LIGHT_MAX_ALPHA)
	src << "Placed a light (radius [L ? L.radius : "?"]) at your feet."
	Log("Admin", "[ExtractInfo(src)] placed a light.")

/mob/Admin2/verb/Clear_Lights()
	set category = "Admin"
	set name = "Clear Lights"
	for(var/datum/lightsource/L in _light_sources.Copy())
		if(L.src_obj) continue //leave prop-attached lights (torches/lamps); those clear via the prop's Del()
		RemoveLightSource(L)
	src << "Cleared all admin-placed lights."
	Log("Admin", "[ExtractInfo(src)] cleared all placed lights.")

/mob/Admin2/verb/Emissives_Toggle()
	set category = "Admin"
	set name = "Emissives Toggle"
	glob.EMISSIVES = !glob.EMISSIVES
	FxEmissiveApplyMode()
	src << "Emissives: [glob.EMISSIVES ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set emissives to [glob.EMISSIVES].")

/mob/Admin2/verb/Corner_Lights_Toggle()
	set category = "Admin"
	set name = "Corner Lights Toggle"
	glob.CORNER_LIGHTS = !glob.CORNER_LIGHTS
	if(glob.LIGHTING) LightingApplyAll()
	src << "Corner-gradient lights: [glob.CORNER_LIGHTS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set corner lights to [glob.CORNER_LIGHTS].")

var/obj/_probe_kt_light
var/obj/_probe_plain_light

/obj/gfx_probe_light
	gfx_transient_visual = 1
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	layer = 6.6

proc/_ProbeStamps(obj/O)
	var/image/S1 = image(EnvWhiteIcon())
	S1.color = "#000000"
	S1.blend_mode = BLEND_MULTIPLY
	S1.pixel_x = 12
	var/image/S2 = image(EnvWhiteIcon())
	S2.color = "#000000"
	S2.blend_mode = BLEND_MULTIPLY
	S2.pixel_x = -6
	S2.pixel_y = 14
	O.overlays += S1
	O.overlays += S2

/mob/Admin2/verb/Unified_Lights_Toggle()
	set category = "Admin"
	set name = "Unified Lights Toggle"
	glob.UNIFIED_LIGHTS = !glob.UNIFIED_LIGHTS
	if(glob.LIGHTING) LightingApplyAll()
	src << "Unified lighting: [glob.UNIFIED_LIGHTS ? "ON (smooth + spill wedges)" : "OFF (corner/flat fallback)"]."
	Log("Admin", "[ExtractInfo(src)] set unified lights to [glob.UNIFIED_LIGHTS].")

/mob/Admin2/verb/Light_Fill_Set()
	set category = "Admin"
	set name = "Light Fill Set"
	var/f = input(src, "Indirect fill level 0-0.5 (current [glob.LIGHT_FILL]; 0 = off, 0.16 default)?") as num|null
	if(f == null) return
	glob.LIGHT_FILL = clamp(f, 0, 0.5)
	if(glob.LIGHTING) LightingApplyAll()
	src << "Indirect fill -> [glob.LIGHT_FILL]."
	Log("Admin", "[ExtractInfo(src)] set light fill to [glob.LIGHT_FILL].")

/mob/Admin2/verb/Soft_Clip_Toggle()
	set category = "Admin"
	set name = "Soft Clip Toggle"
	glob.LIGHT_SOFTCLIP = !glob.LIGHT_SOFTCLIP
	if(glob.LIGHTING) LightingApplyAll()
	src << "Light soft-clip: [glob.LIGHT_SOFTCLIP ? "ON (clusters saturate)" : "OFF (plain additive)"]."
	Log("Admin", "[ExtractInfo(src)] set light soft-clip to [glob.LIGHT_SOFTCLIP].")

/mob/Admin2/verb/God_Rays_Toggle()
	set category = "Admin"
	set name = "God Rays Toggle"
	glob.GOD_RAYS = !glob.GOD_RAYS
	if(glob.LIGHTING) LightingApplyAll() //window beams repaint; canopy shafts fade on their own tick
	src << "God rays: [glob.GOD_RAYS ? "ON (window beams + tagged canopy shafts)" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set god rays to [glob.GOD_RAYS].")

/mob/Admin2/verb/Unified_Light_Probe()
	set category = "Admin"
	set name = "Unified Light Probe"
	if(_probe_kt_light)
		_probe_kt_light.loc = null
		_probe_kt_light = null
		if(_probe_plain_light)
			_probe_plain_light.loc = null
			_probe_plain_light = null
		src << "Probe cleared."
		return
	if(!_fx_glow_icon) _FxBuildIcons()
	var/turf/T = get_turf(src)
	if(!_fx_glow_icon || !T)
		src << "Probe unavailable (no glow icon or no turf)."
		return
	var/obj/gfx_probe_light/K = new(locate(min(T.x + 3, world.maxx), T.y, T.z))
	K.icon = _fx_glow_icon
	K.color = "#ffb060"
	K.transform = matrix() * 4
	K.pixel_x = -16
	K.pixel_y = -16
	K.plane = BASE_LIGHTING_PLANE
	K.appearance_flags = KEEP_TOGETHER | KEEP_APART
	_ProbeStamps(K)
	_probe_kt_light = K
	var/obj/gfx_probe_light/P = new(locate(max(T.x - 3, 1), T.y, T.z))
	P.icon = _fx_glow_icon
	P.color = "#ffb060"
	P.transform = matrix() * 4
	P.pixel_x = -16
	P.pixel_y = -16
	P.plane = BASE_LIGHTING_PLANE
	P.appearance_flags = KEEP_APART
	_ProbeStamps(P)
	_probe_plain_light = P
	src << "Probe up (best viewed at night). EAST glow = KT-masked: its two dark notches should cut ONLY the glow, leaving ground/other lights untouched. WEST glow = plain: its stamps will darken everything under them. Run the verb again to clear."
	Log("Admin", "[ExtractInfo(src)] spawned the unified light probe.")

/mob/Admin2/verb/Make_Emissive() //tag any prop in reach for live testing; run again to untag
	set category = "Admin"
	set name = "Make Emissive"
	var/list/nearby = list()
	for(var/obj/O in oview(5, src))
		if(O.icon) nearby += O
	if(!nearby.len)
		src << "No props in view."
		return
	var/obj/O = input(src, "Toggle emissive on:") as null|anything in nearby
	if(!O) return
	if(O.attached_emissive)
		FxEmissiveDetach(O)
		O.emissive_tier = 0
		src << "[O.name]: emissive off."
	else
		FxEmissiveAttach(O, EMISSIVE_GLOW)
		src << "[O.name]: emissive + glow on."
	Log("Admin", "[ExtractInfo(src)] toggled emissive on [O.name].")
