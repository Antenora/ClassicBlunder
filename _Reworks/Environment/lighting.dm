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
		FLICKER_MIN = 95 //flame-glow alpha low (waver floor)
		FLICKER_MAX = 195 //flame-glow alpha high (waver ceiling)
		//occluded blast lights: big/slow blasts cast a wall-blocked light while flying, capped + throttled
		OCCLUDED_BLASTS = TRUE //feature switch (only meaningful when LIGHTING is on)
		OCCLUDED_BLAST_MAX = 4 //hard global cap on simultaneous occluded footprints
		OCCLUDED_BLAST_RADIUS = 4 //footprint radius in tiles (smaller = cheaper)
		OCCLUDED_BLAST_INTERVAL = 2 //min ticks between repaints of one footprint

var/list/_light_sources = list()
var/list/_light_buckets = list()
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

//occluder = engine opacity, blocks_light, or the wall tree by icon - bare density also covers water/ore
proc/IsLightOccluder(turf/T)
	if(!T) return 1
	if(T.opacity) return 1
	if(T.blocks_light) return 1
	if(T.density && T.icon == 'Walls.dmi') return 1
	return 0

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
				corner[key] = f > 0 ? f * f : 0 //same edge curve as the flat path
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

var/icon/_uni_edge_icon //32px black strip, alpha ramps across Y: dark half +y

proc/UniEdgeIcon()
	if(_uni_edge_icon) return _uni_edge_icon
	var/icon/I = new('sandstorm.dmi')
	for(var/py = 1, py <= 32, py++)
		var/a = clamp(round((py - 14) / 4 * 255), 0, 255)
		for(var/px = 1, px <= 32, px++)
			I.DrawBox(rgb(0, 0, 0, a), px, py)
	_uni_edge_icon = I
	return I

//angular occlusion silhouette
proc/UniFindEdges(datum/lightsource/L, turf/s)
	var/list/walls = list()
	var/rr = L.radius
	for(var/turf/T in block(locate(max(1, s.x - rr), max(1, s.y - rr), s.z),
	                        locate(min(world.maxx, s.x + rr), min(world.maxy, s.y + rr), s.z)))
		if(IsLightOccluder(T) && T != s) walls += T
	if(!walls.len) return null
	var/turf/W0 = walls[1]
	var/cut = arctan(W0.x + 0.5 - (s.x + 0.5), W0.y + 0.5 - (s.y + 0.5))
	var/list/iv = list() //each: list(a1, a2, c1x, c1y, c2x, c2y, wx, wy)
	for(var/turf/T in walls)
		var/list/angs = list()
		for(var/ci = 0, ci <= 3, ci++)
			var/cx = T.x + (ci & 1)
			var/cy = T.y + (ci >> 1)
			var/ang = arctan(cx - (s.x + 0.5), cy - (s.y + 0.5)) - cut
			while(ang < 0) ang += 360
			while(ang >= 360) ang -= 360
			angs += list(list(ang, cx, cy))
		var/a_min = 99999
		var/a_max = -99999
		var/dmin = 99999
		var/dmax = 99999
		var/list/cmin; var/list/cmax
		for(var/list/A in angs)
			var/d2 = (A[2] - (s.x + 0.5)) * (A[2] - (s.x + 0.5)) + (A[3] - (s.y + 0.5)) * (A[3] - (s.y + 0.5))
			if(A[1] < a_min - 0.01 || (abs(A[1] - a_min) <= 0.01 && d2 < dmin)) //colinear ties: nearer corner
				a_min = A[1]
				dmin = d2
				cmin = A
			if(A[1] > a_max + 0.01 || (abs(A[1] - a_max) <= 0.01 && d2 < dmax))
				a_max = A[1]
				dmax = d2
				cmax = A
		//row: a1, a2, start corner + ITS wall, end corner + ITS wall (walls tracked per endpoint)
		if(a_max - a_min <= 180)
			iv += list(list(a_min, a_max, cmin[2], cmin[3], T.x, T.y, cmax[2], cmax[3], T.x, T.y))
		else //tile straddles the cut: split into a low piece [0..] and a high piece [..360]
			var/lo_max = -99999; var/list/lo_c
			var/hi_min = 99999; var/list/hi_c
			for(var/list/A in angs)
				if(A[1] < 180)
					if(A[1] > lo_max)
						lo_max = A[1]
						lo_c = A
				else
					if(A[1] < hi_min)
						hi_min = A[1]
						hi_c = A
			if(lo_c) iv += list(list(0, lo_max, lo_c[2], lo_c[3], T.x, T.y, lo_c[2], lo_c[3], T.x, T.y))
			if(hi_c) iv += list(list(hi_min, 360, hi_c[2], hi_c[3], T.x, T.y, hi_c[2], hi_c[3], T.x, T.y))
	if(!iv.len) return null
	//insertion sort by start angle
	for(var/i = 2, i <= iv.len, i++)
		var/list/cur = iv[i]
		var/j = i - 1
		while(j >= 1)
			var/list/prev = iv[j]
			if(prev[1] <= cur[1]) break
			iv[j + 1] = prev
			j--
		iv[j + 1] = cur
	//merge overlapping blocked intervals; each endpoint keeps its own corner + wall
	var/list/merged = list()
	var/list/acc = iv[1].Copy()
	for(var/i = 2, i <= iv.len, i++)
		var/list/nxt = iv[i]
		if(nxt[1] <= acc[2] + 0.5) //overlap/touch: extend, keep the farther end corner + wall
			if(nxt[2] > acc[2])
				acc[2] = nxt[2]
				acc[7] = nxt[7]
				acc[8] = nxt[8]
				acc[9] = nxt[9]
				acc[10] = nxt[10]
		else
			merged += list(acc)
			acc = nxt.Copy()
	merged += list(acc)
	//every merged-interval endpoint bordering a real gap (>= 6 deg) casts one straight
	//penumbra line through its silhouette corner (the hull extreme is the graze point)
	var/list/out = list()
	for(var/i = 1, i <= merged.len, i++)
		var/list/A = merged[i]
		var/list/B = merged[(i % merged.len) + 1]
		var/gap_start = A[2]
		var/gap_end = (i == merged.len) ? B[1] + 360 : B[1]
		var/span = gap_end - gap_start
		if(span < 6) continue //crack between wall runs: stamps cover it
		var/e1x = A[7]; var/e1y = A[8] //end corner of A: blocked side is decreasing angle
		var/e2x = B[3]; var/e2y = B[4] //start corner of B: blocked side is increasing angle
		out += list(list(arctan(e1x - (s.x + 0.5), e1y - (s.y + 0.5)), sqrt((e1x - (s.x + 0.5)) * (e1x - (s.x + 0.5)) + (e1y - (s.y + 0.5)) * (e1y - (s.y + 0.5))), -1))
		out += list(list(arctan(e2x - (s.x + 0.5), e2y - (s.y + 0.5)), sqrt((e2x - (s.x + 0.5)) * (e2x - (s.x + 0.5)) + (e2y - (s.y + 0.5)) * (e2y - (s.y + 0.5))), 1))
	return out.len ? out : null

proc/UniPaintLight(datum/lightsource/L, turf/s, list/visible, lightStrength)
	var/a = round(L.maxalpha * lightStrength)
	if(a < 3) return
	if(!_fx_glow_icon) _FxBuildIcons()
	if(!_fx_glow_icon) return
	var/rr = L.radius
	var/scale = rr * 2 * 32 / 64 //radial overlay: 64px glow icon out to the light radius
	L.uni_objs = list()
	var/list/vis = list()
	for(var/turf/T in visible) vis[T] = 1
	//interior unit: untransformed anchor so stamp offsets stay in exact world pixels
	var/obj/gfx_uni_light/U = new(s)
	U.color = L.lcolor
	U.alpha = a
	if(glob.UNI_MASK_BLUR > 0)
		U.filters = filter(type = "blur", size = glob.UNI_MASK_BLUR)
	var/image/R = image(_fx_glow_icon)
	R.transform = matrix() * scale
	R.pixel_x = -16
	R.pixel_y = -16
	R.layer = 1
	R.appearance_flags = RESET_COLOR | RESET_ALPHA
	U.overlays += R
	//penumbra lines first: stamps near a line yield to its gradient strip
	var/list/edges = UniFindEdges(L, s)
	//shadow stamps: every non-visible floor tile in the disc; walls skip (band glow stays)
	for(var/ty = max(1, s.y - rr), ty <= min(world.maxy, s.y + rr), ty++)
		for(var/tx = max(1, s.x - rr), tx <= min(world.maxx, s.x + rr), tx++)
			var/turf/T = locate(tx, ty, s.z)
			if(!T || vis[T] || IsLightOccluder(T)) continue
			var/ddx = tx - s.x
			var/ddy = ty - s.y
			if(ddx * ddx + ddy * ddy > rr * rr) continue
			var/near_line = FALSE
			if(edges)
				for(var/list/E in edges)
					var/along = ddx * cos(E[1]) + ddy * sin(E[1])
					if(along < E[2] - 1) continue
					var/perp = ddy * cos(E[1]) - ddx * sin(E[1])
					if(abs(perp) < 1.0)
						near_line = TRUE
						break
			if(near_line) continue //the strip's gradient owns this tile
			var/image/S = image(EnvWhiteIcon())
			S.color = "#000000"
			S.blend_mode = BLEND_MULTIPLY
			S.pixel_x = ddx * 32
			S.pixel_y = ddy * 32
			S.layer = 2
			S.appearance_flags = RESET_COLOR | RESET_ALPHA
			U.overlays += S
	//the strips: one rotated gradient per silhouette ray, dark side facing the shadow
	if(edges)
		for(var/list/E in edges)
			var/elen = rr - E[2] + 1
			if(elen < 0.6) continue
			var/image/G = image(UniEdgeIcon())
			G.blend_mode = BLEND_MULTIPLY
			G.layer = 3
			G.appearance_flags = RESET_COLOR | RESET_ALPHA
			var/matrix/ME = matrix()
			ME.Scale(elen, E[3] * 2.2)
			ME.Turn(-E[1])
			var/ct = E[2] - 0.3 + elen / 2
			ME.Translate(cos(E[1]) * ct * 32, sin(E[1]) * ct * 32)
			G.transform = ME
			U.overlays += G
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

//compute + paint a light's occluded footprint
proc/LightCompute(datum/lightsource/L)
	LightClear(L)
	if(!glob || !glob.LIGHTING || !L) return
	var/turf/s = LightSrcTurf(L)
	if(!s) return
	LightBucketRegister(L)
	var/darkFrac = LightDarkFrac(s) //true ambient darkness; retained for cheap repaint detection
	var/lightStrength = LightRenderStrength(s)
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

proc/LightingApplyAll()
	for(var/datum/lightsource/L in _light_sources)
		LightCompute(L)

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
			for(var/datum/lightsource/L in _light_sources)
				var/turf/s = LightSrcTurf(L)
				if(!s) continue
				if(abs(LightDarkFrac(s) - L.painted_dark) > 0.02)
					LightCompute(L)
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
	return L

proc/RemoveLightSource(datum/lightsource/L)
	if(!L) return
	LightClear(L)
	KillFlame(L)
	LightBucketUnregister(L)
	_light_sources -= L

obj/var/tmp/datum/lightsource/attached_light

proc/LightPropAttach(obj/O, radius, lcolor, maxalpha, flicker = 0)
	if(!O || O.attached_light) return
	if(!get_turf(O)) return //build-panel phantom (Add_Builds new()s every prop with no loc) - don't register a dead light
	PurgeStaleFlameVisuals(O) //old saves can carry baked-in flame visuals - scrub them
	var/datum/lightsource/L = new
	L.src_obj = O
	L.radius = clamp(radius || glob.LIGHT_DEFAULT_RADIUS, 1, 20)
	L.lcolor = lcolor || glob.LIGHT_DEFAULT_COLOR
	L.maxalpha = maxalpha || glob.LIGHT_MAX_ALPHA
	L.flicker = flicker
	_light_sources += L
	O.attached_light = L
	LightBucketRegister(L)
	LightCompute(L)

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
			F.dark = lightStrength
			F.alpha = round((glob.FLICKER_MIN + glob.FLICKER_MAX) / 2 * lightStrength) //start at settled brightness, not default 255
			O.vis_contents += F
			L.flame = F
			FlameFlicker(F)
		else
			L.flame.dark = lightStrength //re-tint amplitude as the clock changes
	else
		KillFlame(L)

proc/FlameFlicker(obj/flamelight/F)
	set waitfor = 0
	set background = 1
	while(F && F.active)
		var/na = round(rand(glob.FLICKER_MIN, glob.FLICKER_MAX) * F.dark)
		animate(F, alpha = na, time = rand(2, 4))
		sleep(rand(2, 5))

//emissive reveal: a vis child that keeps the sprite at full color through darkness
//MR ON = white silhouette added into the unblurred base buffer (multiply-by-white reveals)
//MR OFF = fullbright copy redrawn above the plane-0 blanket
obj/var/emissive_tier = 0 //set per type or per map instance; boot sweep picks up tagged props
obj/var/tmp/obj/gfx_emissive/attached_emissive

var/list/_gfx_emissives = list() //child -> owner prop
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
				animate(E.halo, alpha = T ? round(120 * LightRenderStrength(T)) : 0, time = 10)
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

proc/LightingRefreshReflectionsForArea(area/A)
	if(!A || !glob || !glob.LIGHTING) return
	for(var/datum/lightsource/L in _light_sources)
		var/turf/s = LightSrcTurf(L)
		if(!s) continue
		var/touches = s.loc == A
		if(!touches && L.visible_turfs)
			for(var/turf/T in L.visible_turfs)
				if(T.loc == A)
					touches = TRUE
					break
		if(touches) LightCompute(L)

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
