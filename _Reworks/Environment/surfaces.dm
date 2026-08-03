//surface profiles: one place that decides how any turf/obj meets light, shadow and wind.
//resolution order: instance override, then explicit type profile, then auto-classify.

//OCCLUDE_* and SHADOW_INFINITE live in 00_graphics_defines.dm (include order)

atom
	var
		surface_profile //explicit profile id; null = auto-classify by type
		//per-instance mapper overrides; null = inherit the profile
		sp_occlude
		sp_shadow_len
		sp_wind
		sp_light_type
		sp_light_color
		sp_light_radius
		sp_light_off_x //where on the sprite the light actually lives, in pixels from center
		sp_light_off_y //(+y = up) e.g. a street lamp emits from its head, not its post
		sp_light_cookie //light_cookies.dmi state - the pool takes that shape instead of the plain radial
		sp_light_shaft //god-ray beam on a window light: null = auto (directional cookies beam), 0 = off
		sp_shaft //trees/canopy: 1 = drop a sun shaft column (day, open sky, clear weather)
		sp_wind_pivot //pixels below center to bend around; null = profile default
		sp_exempt_dark
		sp_recolor //"blue"/"green": permute channels so saturated art matches its light
	var/tmp
		_sp_light //the datum/lightsource this instance owns, if any

atom/movable/var/tmp/obj/gfx_screen_glow/gfx_screen_glow
atom/movable/var/tmp/obj/gfx_canopy/gfx_canopy_obj

var/list/_sp_type_cache = list() //type -> profile id
var/list/_sp_profiles
var/list/_sp_light_types

//pinned type profiles
obj/Turfs/Edges/surface_profile = "drop_edge"
turf/Edges/surface_profile = "drop_edge"

proc/SurfaceProfiles()
	if(_sp_profiles) return _sp_profiles
	_sp_profiles = list(
		"floor" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		"sky_void" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 1),
		"wall" = list("occl" = OCCLUDE_FULL, "len" = SHADOW_INFINITE, "wind" = 0, "exempt" = 0),
		"wall_decor" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		"flat_decal" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		//mountings: all cast no shadow, but they are NOT interchangeable with each other
		"wall_mounted" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		"tabletop" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		"ground_flat" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		//edge trim: casts off its own named side only (see SurfaceEdgeDir)
		"edge_tile" = list("occl" = OCCLUDE_PARTIAL, "len" = 2.2, "wind" = 0, "exempt" = 0),
		//glows only where its own pixels are lit (a console screen), casts no light
		"emissive_screen" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		"fence" = list("occl" = OCCLUDE_PARTIAL, "len" = SHADOW_INFINITE, "wind" = 0, "exempt" = 0),
		"drop_edge" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0, "edgecut" = 1), //cliff-lip trim: cuts cast shadows, never blocks light
		"prop_low" = list("occl" = OCCLUDE_FULL, "len" = 1.3, "wind" = 0, "exempt" = 0),
		"prop_medium" = list("occl" = OCCLUDE_FULL, "len" = 2.0, "wind" = 0, "exempt" = 0),
		"prop_tall" = list("occl" = OCCLUDE_FULL, "len" = 2.8, "wind" = 0, "exempt" = 0),
		"foliage" = list("occl" = OCCLUDE_DAPPLE, "len" = 1.6, "wind" = 0.7, "exempt" = 0),
		"tree" = list("occl" = OCCLUDE_DAPPLE, "len" = 2.6, "wind" = 0.55, "exempt" = 0),
		"canopy" = list("occl" = OCCLUDE_DAPPLE, "len" = 1.2, "wind" = 0.45, "exempt" = 0, "fg" = 1), //overhead leaves/awnings (objs only): above-actor layer + player-behind fade, no filters
		"water" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		"emissive_hazard" = list("occl" = OCCLUDE_NONE, "len" = 0, "wind" = 0, "exempt" = 0),
		"light_source" = list("occl" = OCCLUDE_PARTIAL, "len" = 1.2, "wind" = 0, "exempt" = 0),
		"actor" = list("occl" = OCCLUDE_FULL, "len" = 2.6, "wind" = 0, "exempt" = 0))
	return _sp_profiles

//light emission as data
proc/LightTypes()
	if(_sp_light_types) return _sp_light_types
	_sp_light_types = list(
		"torch" = list("r" = 5, "c" = "#ffb060", "a" = 170, "f" = 1),
		"campfire" = list("r" = 7, "c" = "#ff8038", "a" = 185, "f" = 1),
		"lamp" = list("r" = 6, "c" = "#fff0c0", "a" = 170, "f" = 0),
		"bluelamp" = list("r" = 6, "c" = "#7fb0ff", "a" = 170, "f" = 0),
		"greenlamp" = list("r" = 6, "c" = "#8fffb0", "a" = 170, "f" = 0),
		"streetlamp" = list("r" = 8, "c" = "#ffe9c0", "a" = 175, "f" = 0, "em" = 0), //post-heavy art: the head-anchored pool carries the glow, no whole-sprite reveal
		"candle" = list("r" = 3, "c" = "#ffd9a0", "a" = 150, "f" = 1),
		"lava" = list("r" = 4, "c" = "#ff5a1e", "a" = 155, "f" = 1),
		"ichor" = list("r" = 5, "c" = "#8fffb0", "a" = 140, "f" = 0),
		"reactor" = list("r" = 6, "c" = "#7fd8ff", "a" = 160, "f" = 0),
		"window" = list("r" = 4, "c" = "#ffe2b0", "a" = 155, "f" = 0, "ck" = "panes")) //light through glass; the pool falls off the obj's facing
	return _sp_light_types

proc/SurfaceAutoClassify(atom/A)
	if(!A) return "floor"
	var/p = lowertext("[A.type]")
	if(ismob(A)) return "actor"
	if(findtext(p, "torch") || findtext(p, "lamp") || findtext(p, "lantern") || findtext(p, "candle") \
	   || findtext(p, "brazier") || findtext(p, "campfire") || findtext(p, "firewood") || findtext(p, "/fire"))
		return "light_source"
	if(findtext(p, "lava") || findtext(p, "magma") || findtext(p, "ichor") || findtext(p, "crystal") \
	   || findtext(p, "reactor") || findtext(p, "ember"))
		return "emissive_hazard"
	//canopy before tree: "treecanopy" and friends must land on the overhead profile
	if(findtext(p, "canopy") || findtext(p, "awning") || findtext(p, "overhang")) return "canopy"
	if(findtext(p, "tree") || findtext(p, "palm")) return "tree"
	if(findtext(p, "bush") || findtext(p, "shrub") || findtext(p, "hedge") || findtext(p, "flower") \
	   || findtext(p, "fern") || findtext(p, "vine") || findtext(p, "cactus") || findtext(p, "foliage") \
	   || findtext(p, "plant") || findtext(p, "sapling") || findtext(p, "reed"))
		return "foliage"
	if(findtext(p, "water") || findtext(p, "/sea") || findtext(p, "ocean") || findtext(p, "shallow") \
	   || findtext(p, "surf") || findtext(p, "swamp") || findtext(p, "deluge"))
		return "water"
	if(findtext(p, "roof")) return "floor" //roofs darken like any other surface
	if(findtext(p, "fence") || findtext(p, "railing") || findtext(p, "gate")) return "fence"
	if(findtext(p, "crack") || findtext(p, "overlay") || findtext(p, "rug") || findtext(p, "carpet") \
	   || findtext(p, "stain") || findtext(p, "blood") || findtext(p, "decal") || findtext(p, "path"))
		return isturf(A) ? "flat_decal" : "wall_decor"
	if(isturf(A))
		return (A.opacity || A.density) ? "wall" : "floor"
	if(A.opacity) return "wall"
	if(!A.density) return "prop_medium"
	if(findtext(p, "statue") || findtext(p, "pillar") || findtext(p, "column") || findtext(p, "console") \
	   || findtext(p, "door") || findtext(p, "drawer") || findtext(p, "couch") || findtext(p, "bed") \
	   || findtext(p, "stove") || findtext(p, "wagon") || findtext(p, "cart"))
		return "prop_tall"
	if(findtext(p, "pot") || findtext(p, "rock") || findtext(p, "stone") || findtext(p, "log") \
	   || findtext(p, "book") || findtext(p, "jug") || findtext(p, "apple"))
		return "prop_low"
	return "prop_medium"

proc/SurfaceProfileOf(atom/A)
	if(!A) return "floor"
	if(A.surface_profile) return A.surface_profile
	var/p = _sp_type_cache["[A.type]"]
	if(p) return p
	p = SurfaceAutoClassify(A)
	_sp_type_cache["[A.type]"] = p
	return p

proc/SurfaceProp(atom/A, key)
	var/list/P = SurfaceProfiles()[SurfaceProfileOf(A)]
	return P ? P[key] : 0

//instance override wins over the profile for each field
proc/SurfaceOcclusion(atom/A)
	if(!A) return OCCLUDE_NONE
	if(A.sp_occlude != null) return A.sp_occlude
	return SurfaceProp(A, "occl")

proc/SurfaceShadowLen(atom/A)
	if(!A) return 0
	if(A.sp_shadow_len != null) return A.sp_shadow_len
	return SurfaceProp(A, "len")

proc/SurfaceShadowStrength(atom/A)
	switch(SurfaceOcclusion(A))
		if(OCCLUDE_FULL) return 1
		if(OCCLUDE_DAPPLE) return 0.55
		if(OCCLUDE_PARTIAL) return 0.45
	return 0

//edge tiles occlude along one side only
proc/SurfaceEdgeDir(atom/A)
	if(!A) return 0
	var/pr = SurfaceProfileOf(A)
	if(pr != "edge_tile" && pr != "drop_edge") return 0
	var/t = "[A.type]"
	var/tail = copytext(t, findlasttext(t, "/") + 1)
	//trailing cardinal wins (Edge4N, bridgeE); some sets spell it out
	var/last = uppertext(copytext(tail, length(tail)))
	switch(last)
		if("N") return NORTH
		if("S") return SOUTH
		if("E") return EAST
		if("W") return WEST
	var/low = lowertext(tail)
	if(findtext(low, "north")) return NORTH
	if(findtext(low, "south")) return SOUTH
	if(findtext(low, "east")) return EAST
	if(findtext(low, "west")) return WEST
	return 0

//the two corners of that side, in grid coords, for a tile at tx,ty
proc/SurfaceEdgeCorners(tx, ty, edir)
	switch(edir)
		if(NORTH) return list(tx, ty + 1, tx + 1, ty + 1)
		if(SOUTH) return list(tx, ty, tx + 1, ty)
		if(EAST) return list(tx + 1, ty, tx + 1, ty + 1)
		if(WEST) return list(tx, ty, tx, ty + 1)
	return null

//how far below the icon center the bend happens; trees flex from the base, small plants tilt whole
//base cell + overlay stack height: a Palm is a 32px cell wearing a 64px crown
var/list/_sp_vis_h = list()
proc/SurfaceVisualHeight(atom/movable/A)
	if(!A) return 32
	var/key = "[A.type]"
	if(_sp_vis_h[key]) return _sp_vis_h[key]
	var/h = SurfaceIconHeight(A)
	var/top = 0
	for(var/image/O in A.overlays)
		if(O.pixel_y > top) top = O.pixel_y
	h += top
	_sp_vis_h[key] = h
	return h

var/list/_sp_icon_h = list()
proc/SurfaceIconHeight(atom/A)
	if(!A || !A.icon) return 32
	var/key = "[A.icon]-[A.icon_state]"
	if(_sp_icon_h[key]) return _sp_icon_h[key]
	var/icon/I = new(A.icon, A.icon_state)
	var/h = I ? I.Height() : 32
	_sp_icon_h[key] = h
	return h

//pivot must be the sprite's BASE - half the icon height puts the hinge on the ground
proc/SurfaceWindPivot(atom/A)
	if(!A) return 0
	if(A.sp_wind_pivot != null) return A.sp_wind_pivot
	switch(SurfaceProfileOf(A))
		if("tree", "foliage", "canopy") return -(SurfaceIconHeight(A) / 2)
	return 0

proc/SurfaceExemptDark(atom/A)
	if(!A) return 0
	if(A.sp_exempt_dark != null) return A.sp_exempt_dark
	return SurfaceProp(A, "exempt")

//screen-only emissive: additive draw through a contrast matrix - dark chassis pixels vanish, lit screens glow
/obj/gfx_screen_glow
	gfx_transient_visual = 1
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_APART
	plane = 0
	layer = 6.53
	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR

proc/SurfaceScreenGlow(atom/movable/A)
	if(!A || A.gfx_screen_glow) return
	var/obj/gfx_screen_glow/G = new
	//crush everything below mid-gray toward black, keep bright saturated pixels
	G.color = list(1.9,-0.5,-0.5,0, -0.5,1.9,-0.5,0, -0.5,-0.5,1.9,0, 0,0,0,1, -0.28,-0.28,-0.28,0)
	G.alpha = 190
	A.vis_contents += G
	A.gfx_screen_glow = G

proc/SurfaceScreenGlowClear(atom/movable/A)
	if(!A || !A.gfx_screen_glow) return
	A.vis_contents -= A.gfx_screen_glow
	A.gfx_screen_glow.loc = null
	A.gfx_screen_glow = null

//channel permutation recolors saturated hues and leaves grays alone - no new art files
var/list/_sp_recolor_cache = list()
proc/SurfaceRecolorIcon(ic, state, mode)
	if(!ic) return null
	var/key = "[ic]-[state]-[mode]"
	if(_sp_recolor_cache[key]) return _sp_recolor_cache[key]
	var/icon/I = new(ic, state)
	if(!I) return null
	if(mode == "blue") I.MapColors(0,0,1, 0,1,0, 1,0,0) //R<->B
	else if(mode == "green") I.MapColors(0,1,0, 0,0,1, 1,0,0) //R->G, G->B, B->R
	_sp_recolor_cache[key] = I
	return I

//rigid trunk: split the sprite at trunk/canopy, wind only touches the leaf child
var/list/_sp_canopy_cache = list()

/obj/gfx_canopy
	gfx_transient_visual = 1
	mouse_opacity = 0
	appearance_flags = KEEP_APART
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE

proc/SurfaceCanopySplit(ic, state)
	var/key = "[ic]-[state]"
	if(_sp_canopy_cache[key] != null) return _sp_canopy_cache[key]
	var/icon/I = new(ic, state)
	var/res = 0
	if(I)
		var/w = I.Width()
		var/h = I.Height()
		if(w >= 16 && h >= 20)
			var/list/wid = new /list(h)
			var/wmax = 0
			for(var/y = 1, y <= h, y++)
				var/lo = 0
				var/hi = 0
				for(var/x = 1, x <= w, x++)
					if(I.GetPixel(x, y))
						if(!lo) lo = x
						hi = x
				wid[y] = hi ? (hi - lo + 1) : 0
				if(wid[y] > wmax) wmax = wid[y]
			if(wmax > 0)
				for(var/y = 1, y <= h, y++) //scan up: first row wider than 45% ends the trunk
					if(wid[y] > wmax * 0.45)
						res = y
						break
				if(res < h * 0.25) res = round(h * 0.25)
				if(res > h * 0.6) res = round(h * 0.6)
				if(res <= 2 || res >= h - 3) res = 0 //too small to be worth splitting
	_sp_canopy_cache[key] = res
	return res

//disabled: base-shear wind replaced the split; kept for reference
proc/SurfaceSplitCanopy(atom/movable/A)
	return 0
proc/_SurfaceSplitCanopyLegacy(atom/movable/A)
	if(!A || A.gfx_canopy_obj || !A.icon) return 0
	if(A.overlays && A.overlays.len) return 0 //overlay-built crown; pivot bend handles it
	var/split = SurfaceCanopySplit(A.icon, A.icon_state)
	if(!split) return 0
	var/icon/full = new(A.icon, A.icon_state)
	var/h = full.Height()
	var/w = full.Width()
	var/lap = max(3, round((h - split) * 0.18))
	var/base = max(1, split - lap)
	var/icon/trunk = new(full)
	trunk.Crop(1, 1, w, split) //keep the base (crown overlaps back over this)
	var/icon/leaves = new(full)
	leaves.Crop(1, base + 1, w, h) //crown + overlap skirt
	var/obj/gfx_canopy/G = new
	G.icon = leaves
	G.pixel_y = base //re-seat the crown where it was
	G.layer = A.layer
	A.icon = trunk
	A.vis_contents += G
	A.gfx_canopy_obj = G
	G.gfx_wind_response = A.gfx_wind_response
	G.gfx_wind_phase = A.gfx_wind_phase || rand(0, 359)
	G.sp_wind_pivot = -(leaves.Height() / 2) - lap
	return 1

//apply the profile's non-lighting side effects (wind, light emission) to one atom
proc/SurfaceApply(atom/A)
	if(!A) return
	if(SurfaceProfileOf(A) == "emissive_screen" && istype(A, /atom/movable))
		SurfaceScreenGlow(A)
	if(A.sp_recolor && istype(A, /atom/movable))
		var/atom/movable/RM = A
		var/icon/NI = SurfaceRecolorIcon(RM.icon, RM.icon_state, RM.sp_recolor)
		if(NI)
			RM.icon = NI
			RM.sp_recolor = null //once only; the cache keeps it cheap
	var/w = (A.sp_wind != null) ? A.sp_wind : SurfaceProp(A, "wind")
	if(w > 0 && istype(A, /atom/movable))
		var/atom/movable/M = A
		//flags sit OUTSIDE the first-time gate: gfx_wind_response is a SAVED var, the gate
		//short-circuits on rebooted servers and anything inside it never runs
		//KEEP_TOGETHER: transforms apply per-appearance, so an overlay-built palm shears into pieces without it
		M.appearance_flags |= PIXEL_SCALE | KEEP_TOGETHER
		if(M.gfx_wind_response <= 0)
			M.gfx_wind_response = w
			GfxRefreshStructureMetadata(M)
	if(istype(A, /atom/movable))
		GfxApplyForegroundRole(A) //canopy profile on/off -> FOREGROUND_PLANE routing
	var/lt = A.sp_light_type
	if(!lt && SurfaceProfileOf(A) == "light_source") lt = SurfaceDefaultLightType(A)
	if(lt) SurfaceAttachLight(A, lt)
	if(A.sp_shaft && istype(A, /atom/movable))
		CanopyShaftAttach(A) //tick loop owns visibility, so attach is safe even with rays off

proc/SurfaceDefaultLightType(atom/A)
	var/p = lowertext("[A.type]")
	if(findtext(p, "campfire") || findtext(p, "/fire") || findtext(p, "firewood")) return "campfire"
	if(findtext(p, "streetlamp") || findtext(p, "lampost")) return "streetlamp"
	if(findtext(p, "bluelamp")) return "bluelamp"
	if(findtext(p, "greenlamp")) return "greenlamp"
	if(findtext(p, "lamp")) return "lamp"
	if(findtext(p, "candle")) return "candle"
	return "torch"

proc/SurfaceAttachLight(atom/A, ltype)
	if(!A || !ltype) return
	var/list/T = LightTypes()[ltype]
	if(!T) return
	if(!istype(A, /obj)) return //lights ride objs; turf hazards glow via emissives instead
	var/obj/O = A
	if(O.attached_light) return
	var/col = A.sp_light_color ? A.sp_light_color : T["c"]
	var/rad = (A.sp_light_radius != null) ? A.sp_light_radius : T["r"]
	var/ox = (A.sp_light_off_x != null) ? A.sp_light_off_x : 0
	var/oy = (A.sp_light_off_y != null) ? A.sp_light_off_y : 0
	var/ck = A.sp_light_cookie ? A.sp_light_cookie : T["ck"]
	LightPropAttach(O, rad, col, T["a"], T["f"], ox, oy, ck, O.dir, A.sp_light_shaft)
	if(T["em"] != 0) FxEmissiveAttach(O, EMISSIVE_REVEAL) //a lamp should never darken like an ordinary prop
	//em = 0 types (post-heavy fixtures) skip the reveal: their off_y pool lights the head locally

//boot sweep: profiles applied once the map has settled
proc/_SurfaceBoot()
	spawn(90)
		var/n = 0
		for(var/obj/O in world)
			if(!O.loc) continue
			var/pr = SurfaceProfileOf(O)
			if(pr == "light_source" || pr == "foliage" || pr == "tree" || pr == "emissive_hazard" || pr == "canopy")
				SurfaceApply(O)
				n++
		Log("Debug", "Surface profiles applied to [n] props.")
		_lights_settled = 1 //from here, light attach/detach repaints overlap neighbors (soft-clip)
	return 1
var/_surface_boot = _SurfaceBoot()

// mapper tools

/mob/Admin2/verb/Surface_Inspect(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Inspect"
	if(!A) return
	var/pr = SurfaceProfileOf(A)
	var/occ = SurfaceOcclusion(A)
	src << "<b>[A.name]</b> ([A.type])"
	src << "profile: [pr][A.surface_profile ? " (explicit)" : " (auto)"]"
	src << "occlusion: [occ == OCCLUDE_NONE ? "none" : occ == OCCLUDE_PARTIAL ? "partial" : occ == OCCLUDE_DAPPLE ? "dapple" : "full"][A.sp_occlude != null ? " (override)" : ""]"
	src << "shadow length: [SurfaceShadowLen(A) == SHADOW_INFINITE ? "infinite" : SurfaceShadowLen(A)] tiles | strength [SurfaceShadowStrength(A)]"
	src << "wind: [(A.sp_wind != null) ? A.sp_wind : SurfaceProp(A, "wind")] | darkness-exempt: [SurfaceExemptDark(A) ? "yes" : "no"]"
	src << "light: [A.sp_light_type ? A.sp_light_type : (pr == "light_source" ? SurfaceDefaultLightType(A) : "none")]"
	if(A.sp_light_cookie) src << "cookie: [A.sp_light_cookie] (pool falls [A.dir == NORTH ? "north" : A.dir == EAST ? "east" : A.dir == WEST ? "west" : "south"])"

/mob/Admin2/verb/Surface_Set_Profile(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Set Profile"
	if(!A) return
	var/list/ids = SurfaceProfiles()
	var/p = input(src, "Profile for [A.name]? (current: [SurfaceProfileOf(A)])") as null|anything in ids + "clear (auto)"
	if(!p) return
	A.surface_profile = (p == "clear (auto)") ? null : p
	SurfaceApply(A)
	LightingRecomputeNear(get_turf(A))
	src << "[A.name] profile -> [SurfaceProfileOf(A)]."
	Log("Admin", "[ExtractInfo(src)] set surface profile of [A.type] to [p].")

/mob/Admin2/verb/Surface_Set_Type_Profile(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Set Type Profile"
	if(!A) return
	var/list/ids = SurfaceProfiles()
	var/p = input(src, "Profile for ALL [A.type]? (current: [SurfaceProfileOf(A)]) Session-only until pinned in code.") as null|anything in ids + "clear (auto)"
	if(!p) return
	if(p == "clear (auto)")
		_sp_type_cache -= "[A.type]"
	else
		_sp_type_cache["[A.type]"] = p
	src << "[A.type] type-wide profile -> [p] (until reboot - report the type path to pin it in code)."
	Log("Admin", "[ExtractInfo(src)] set TYPE-WIDE profile of [A.type] to [p].")
	//push onto placed instances - wind/light/canopy land at SurfaceApply time. budgeted walk
	var/ttype = A.type
	spawn()
		var/n = 0
		var/seen = 0
		for(var/obj/O in world)
			if(++seen % 4096 == 0 && world.tick_usage > 70) sleep(1)
			if(O.type != ttype || !O.loc) continue
			SurfaceApply(O)
			n++
		src << "[ttype]: profile re-applied to [n] placed instance\s."

/mob/Admin2/verb/Surface_Set_Occlusion(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Set Occlusion"
	if(!A) return
	var/list/modes = list("none" = OCCLUDE_NONE, "partial" = OCCLUDE_PARTIAL,
	                      "dapple (foliage)" = OCCLUDE_DAPPLE, "full" = OCCLUDE_FULL,
	                      "clear (use profile)" = null)
	var/k = input(src, "Occlusion for [A.name]?") as null|anything in modes
	if(!k) return
	A.sp_occlude = modes[k]
	if(k != "clear (use profile)")
		var/L = input(src, "Shadow length in tiles (0 = infinite, blank = keep)?") as num|null
		if(L != null) A.sp_shadow_len = L
	LightingRecomputeNear(get_turf(A))
	src << "[A.name] occlusion -> [k]."
	Log("Admin", "[ExtractInfo(src)] set occlusion of [A.type] to [k].")

/mob/Admin2/verb/Surface_Set_Light(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Set Light"
	if(!A || !isobj(A))
		if(A) src << "Lights ride objs; use an obj (turf hazards glow via emissives)."
		return
	var/obj/O = A
	var/list/types = LightTypes()
	var/t = input(src, "Light type for [O.name]? (current: [O.sp_light_type || "none"])") as null|anything in types + "none (remove)"
	if(!t) return
	if(O.attached_light)
		LightPropDetach(O)
	if(t == "none (remove)")
		O.sp_light_type = null
		FxEmissiveDetach(O)
		src << "[O.name]: light removed."
		return
	O.sp_light_type = t
	var/c = input(src, "Glow colour (blank = profile default [LightTypes()[t]["c"]])?") as text|null
	if(c && length(c) >= 4) O.sp_light_color = c
	var/r = input(src, "Radius in tiles (blank = default [LightTypes()[t]["r"]])?") as num|null
	if(r != null) O.sp_light_radius = clamp(r, 1, 20)
	SurfaceAttachLight(O, t)
	src << "[O.name] -> [t] light."
	Log("Admin", "[ExtractInfo(src)] made [O.type] a [t] light.")

/mob/Admin2/verb/Surface_Set_Cookie(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Set Cookie"
	if(!A || !isobj(A))
		if(A) src << "Cookies shape a light's pool; they ride light objs."
		return
	var/obj/O = A
	var/list/shapes = list("panes", "arch", "slats", "cone", "grate", "dapple", "none (plain pool)")
	var/t = input(src, "Pool shape for [O.name]? (current: [O.sp_light_cookie || "plain"]) Directional shapes fall off the obj's facing - rotate the obj to aim them.") as null|anything in shapes
	if(!t) return
	O.sp_light_cookie = (t == "none (plain pool)") ? null : t
	if(O.attached_light)
		LightPropDetach(O)
		SurfaceAttachLight(O, O.sp_light_type || SurfaceDefaultLightType(O))
		src << "[O.name] pool -> [O.sp_light_cookie || "plain"]."
	else
		src << "[O.name] pool -> [O.sp_light_cookie || "plain"] (takes effect once it has a light - Surface Set Light)."
	Log("Admin", "[ExtractInfo(src)] set light cookie of [O.type] to [O.sp_light_cookie || "none"].")

/mob/Admin2/verb/Surface_Set_Shaft(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Set Shaft"
	if(!A || !istype(A, /atom/movable))
		if(A) src << "Shafts ride objs: a tree gets a canopy sun column, a window light toggles its beam."
		return
	var/atom/movable/M = A
	if(isobj(M))
		var/obj/O = M
		if(O.attached_light || O.sp_light_type) //a light: cycle its window beam auto/off
			O.sp_light_shaft = (O.sp_light_shaft == 0) ? null : 0
			if(O.attached_light)
				LightPropDetach(O)
				SurfaceAttachLight(O, O.sp_light_type || SurfaceDefaultLightType(O))
			src << "[O.name] window beam -> [(O.sp_light_shaft == 0) ? "OFF" : "auto (panes/arch cookies beam)"]."
			Log("Admin", "[ExtractInfo(src)] set window beam of [O.type] to [(O.sp_light_shaft == 0) ? "off" : "auto"].")
			return
	if(M.gfx_canopy_shaft_obj)
		CanopyShaftDetach(M)
		M.sp_shaft = null
		src << "[M.name]: canopy shaft removed."
	else
		M.sp_shaft = 1
		CanopyShaftAttach(M)
		src << "[M.name]: canopy shaft attached (shows under open sky, daylight, clear weather; moon shafts if enabled)."
	Log("Admin", "[ExtractInfo(src)] set canopy shaft of [M.type] to [M.sp_shaft ? "on" : "off"].")

/mob/Admin2/verb/Surface_Set_Wind(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Set Wind"
	if(!A || !istype(A, /atom/movable))
		if(A) src << "Wind applies to movable atoms (objs), not turfs."
		return
	var/atom/movable/M = A
	var/w = input(src, "Wind response 0-1 (0 = still; foliage default 0.7)?") as num|null
	if(w == null) return
	M.sp_wind = clamp(w, 0, 1)
	M.gfx_wind_response = M.sp_wind
	GfxRefreshStructureMetadata(M)
	src << "[M.name] wind -> [M.sp_wind]."
	Log("Admin", "[ExtractInfo(src)] set wind of [M.type] to [M.sp_wind].")

/mob/Admin2/verb/Surface_Clear_Overrides(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Surface Clear Overrides"
	if(!A) return
	A.surface_profile = null
	A.sp_occlude = null
	A.sp_shadow_len = null
	A.sp_wind = null
	A.sp_exempt_dark = null
	A.sp_light_color = null
	A.sp_light_radius = null
	A.sp_light_cookie = null
	A.sp_light_shaft = null
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		if(AM.gfx_canopy_shaft_obj) CanopyShaftDetach(AM)
	A.sp_shaft = null
	LightingRecomputeNear(get_turf(A))
	src << "[A.name]: overrides cleared (now [SurfaceProfileOf(A)] by auto-classify)."

/mob/Admin2/verb/Surface_Audit_Here()
	set category = "Mapper"
	set name = "Surface Audit Here"
	var/list/tally = list()
	for(var/turf/T in view(7, src))
		var/p = SurfaceProfileOf(T)
		tally[p] = (tally[p] || 0) + 1
		for(var/obj/O in T)
			var/po = SurfaceProfileOf(O)
			tally[po] = (tally[po] || 0) + 1
	src << "<b>Surfaces in view:</b>"
	for(var/k in tally) src << "  [k]: [tally[k]]"

//lava / molten ground: glows, never blocks light
turf
	IconsX
		Icon7/surface_profile = "emissive_hazard" //molten lava
		Icon31/surface_profile = "emissive_hazard" //banded lava
		Icon55/surface_profile = "emissive_hazard" //molten lava
		Icon8/surface_profile = "floor"
		Icon56/surface_profile = "floor"
	Dirt4R/surface_profile = "floor" 
	MidgarTiles/MidgarRapeWindow/surface_profile = "fence" 
	Special/midgarTrainPole/surface_profile = "fence" 
	Misc4/surface_profile = "emissive_hazard"
	Misc5/surface_profile = "emissive_hazard"
	Misc6/surface_profile = "emissive_hazard"
	Misc7/surface_profile = "emissive_hazard"
	Misc8/surface_profile = "emissive_hazard"
	Misc9/surface_profile = "emissive_hazard"
	Misc10/surface_profile = "emissive_hazard"
	Misc11/surface_profile = "emissive_hazard"
	Misc12/surface_profile = "emissive_hazard"
	Misc13/surface_profile = "emissive_hazard"

obj/Turfs/IconsX
	//plants, crops, flowers, grass - these sway
	Icon90/surface_profile = "foliage"
	Icon91/surface_profile = "foliage"
	Icon92/surface_profile = "foliage"
	Icon93/surface_profile = "foliage"
	Icon94/surface_profile = "foliage"
	Icon95/surface_profile = "foliage"
	Icon96/surface_profile = "foliage"
	Icon97/surface_profile = "foliage"
	Icon98/surface_profile = "foliage"
	Icon99/surface_profile = "foliage"
	Icon104/surface_profile = "foliage"
	Icon105/surface_profile = "foliage"
	Icon106/surface_profile = "foliage"
	Icon107/surface_profile = "foliage"
	Icon109/surface_profile = "foliage"
	Icon110/surface_profile = "foliage"
	Icon111/surface_profile = "foliage"
	Icon112/surface_profile = "foliage"
	Icon114/surface_profile = "foliage"
	Icon117/surface_profile = "foliage"
	Icon118/surface_profile = "foliage"
	Icon119/surface_profile = "foliage"
	Icon120/surface_profile = "foliage"
	Icon144/surface_profile = "foliage"
	Icon130/surface_profile = "tree"
	//small ground clutter
	Icon102/surface_profile = "prop_low" //log pile
	Icon103/surface_profile = "prop_low" //pebbles
	Icon113/surface_profile = "prop_low" //fallen log
	Icon121/surface_profile = "prop_low" //tree stump
	Icon122/surface_profile = "prop_low" //boulders
	Icon126/surface_profile = "prop_low" //white rocks
	Icon131/surface_profile = "prop_low" //ice shards
	Icon132/surface_profile = "prop_low" //basin
	Icon142/surface_profile = "prop_low" //coal/black rock
	Icon143/surface_profile = "prop_low" //rubble
	//waist-height objects
	Icon100/surface_profile = "prop_medium"
	Icon115/surface_profile = "prop_medium" //hay pile
	Icon116/surface_profile = "prop_medium" //stone block
	Icon124/surface_profile = "prop_medium" //altar block
	Icon127/surface_profile = "prop_medium" //barrel
	Icon141/surface_profile = "prop_medium" //snowman
	//tall silhouettes
	Icon101/surface_profile = "prop_tall" //scarecrow
	Icon108/surface_profile = "prop_tall" //stone arch
	Icon123/surface_profile = "prop_tall" //stone arch
	Icon125/surface_profile = "prop_tall" //well
	Icon128/surface_profile = "prop_tall" //signpost
	Icon129/surface_profile = "prop_tall" //monument
	//fences let light through; the stone runs do not
	Icon133/surface_profile = "fence"
	Icon134/surface_profile = "fence"
	Icon135/surface_profile = "fence"
	Icon136/surface_profile = "fence"
	Icon137/surface_profile = "wall"
	Icon138/surface_profile = "wall"
	Icon139/surface_profile = "wall"
	Icon140/surface_profile = "wall"

obj/KatieObj/Furniture
	Furniture_34 //Candlestick
		surface_profile = "light_source"
		sp_light_type = "candle"
	Furniture_47 //Chandelier
		surface_profile = "light_source"
		sp_light_type = "candle"
		sp_light_radius = 6
	Furniture_60 //Fireplace
		surface_profile = "light_source"
		sp_light_type = "campfire"
		sp_light_off_y = -15
	Furniture_87 //Orb Table - red orb
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#ff6a6a"
		sp_light_radius = 3
		sp_light_off_y = 4
	//trees in this family bend from the trunk, not the middle
	Furniture_95/surface_profile = "tree" //Potted_Tree

obj/KatieObj/Misc
	Misc_53 //lamp heads (overlay half of a post lamp)
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 4
	Misc_54 //lamp post (underlay half) - emits from the heads at the top
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 20
	Misc_60 //PowerLamp - magenta orb
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#ffa8f0"
		sp_light_off_y = 12
	Misc_103 //Torch
		surface_profile = "light_source"
		sp_light_type = "torch"
		sp_light_off_y = 10
	Misc_72
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_color = "#dcecf5"
		sp_light_off_y = 18
	Misc_73
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_color = "#dcecf5"
		sp_light_off_y = 18
	Misc_74
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_color = "#dcecf5"
		sp_light_off_x = 9
		sp_light_off_y = 19
	Misc_75
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_color = "#dcecf5"
		sp_light_off_x = -9
		sp_light_off_y = 19
	Misc_76
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_color = "#dcecf5"
		sp_light_off_x = 11
		sp_light_off_y = 18
	Misc_77
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_color = "#dcecf5"
		sp_light_off_x = -11
		sp_light_off_y = 18
	//light comes from the head
	Misc_79
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 8
	Misc_80
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 8
	Misc_81
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 6
	Misc_82
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 6
	Misc_83
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 6
	Misc_84
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 6
	Misc_105/surface_profile = "tree" //Tree Park

obj/KatieObj/Tech
	Tech_1 //Center Room Piece - purple gem on pedestal
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#b06af0"
		sp_light_radius = 3
		sp_light_off_y = 18
	Tech_11 //Energy Cells
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#9eebf5"
		sp_light_radius = 2
		sp_light_off_y = -2
	Tech_12 //Energy Cells2
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#b1f1f7"
		sp_light_radius = 2
		sp_light_off_y = -2
	Tech_17 //Glow disc
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#dfeaff"
		sp_light_off_y = 4
	Tech_27 //Lamp
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_off_y = 10
	Tech_28 //Lampost
		surface_profile = "light_source"
		sp_light_type = "streetlamp"
		sp_light_off_y = 20
	Tech_29 //Light
		surface_profile = "light_source"
		sp_light_type = "lamp"
	Tech_30 //Lights
		surface_profile = "light_source"
		sp_light_type = "lamp"
	Tech_40 //Regen tube - whole tube glows
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#4de4f9"
		sp_light_radius = 3
	Tech_62 //Tesla Moter
		surface_profile = "light_source"
		sp_light_type = "lamp"
		sp_light_color = "#8ce4f2"
		sp_light_radius = 2
		sp_light_off_y = 3

obj/KatieObj/Wall_Obj
	Wall_Obj_37 //Rich Fireplace
		surface_profile = "light_source"
		sp_light_type = "campfire"
		sp_light_off_y = -6
	Wall_Obj_45 //Wall Fire
		surface_profile = "light_source"
		sp_light_type = "torch"
		sp_light_off_y = -9

obj/KatieObj/Door_Obj
	Door_2/surface_profile = "wall_mounted"
	Door_3/surface_profile = "wall_mounted"
	Door_4/surface_profile = "wall_mounted"

obj/KatieObj/Furniture
	Furniture_1/surface_profile = "prop_medium" 
	Furniture_112/surface_profile = "prop_medium" 
	Furniture_127/surface_profile = "prop_medium" 
	Furniture_15/surface_profile = "prop_medium" 
	Furniture_151/surface_profile = "prop_medium" 
	Furniture_50/surface_profile = "prop_medium" 
	Furniture_67/surface_profile = "prop_medium" 
	Furniture_68/surface_profile = "prop_medium" 
	Furniture_69/surface_profile = "prop_medium" 
	Furniture_70/surface_profile = "prop_medium" 
	Furniture_71/surface_profile = "prop_medium" 
	Furniture_72/surface_profile = "prop_medium" 
	Furniture_73/surface_profile = "prop_medium" 
	Furniture_75/surface_profile = "prop_medium" 
	Furniture_76/surface_profile = "prop_medium" 
	Furniture_86/surface_profile = "prop_medium" 
	Furniture_96/surface_profile = "prop_medium" 

obj/KatieObj/Misc
	Misc_10/surface_profile = "prop_medium"
	Misc_100/surface_profile = "prop_medium"
	Misc_101/surface_profile = "prop_medium"
	Misc_11/surface_profile = "prop_medium"
	Misc_110/surface_profile = "prop_tall" //well
	Misc_12/surface_profile = "prop_medium"
	Misc_13/surface_profile = "prop_tall"
	Misc_16/surface_profile = "prop_tall" //sign
	Misc_2/surface_profile = "prop_tall"
	Misc_22/surface_profile = "prop_medium"
	Misc_24/surface_profile = "prop_medium"
	Misc_25/surface_profile = "prop_medium"
	Misc_42/surface_profile = "prop_tall"
	Misc_43/surface_profile = "prop_tall" //gallows
	Misc_48/surface_profile = "prop_medium"
	Misc_49/surface_profile = "prop_medium"
	Misc_50/surface_profile = "prop_medium"
	Misc_55/surface_profile = "prop_medium"
	Misc_59/surface_profile = "prop_medium"
	Misc_6/surface_profile = "prop_low" //large pile of rocks

obj/KatieObj/Space/Atmos
	Atmos_14
		surface_profile = "light_source" //subtle, red+blue mix, wall mounted
		sp_light_type = "lamp"
		sp_light_color = "#c86a9a"
		sp_light_radius = 2
	Atmos_15
		surface_profile = "light_source" //subtle, green+red+blue, wall mounted
		sp_light_type = "lamp"
		sp_light_color = "#8ad0a0"
		sp_light_radius = 2
	Atmos_16
		surface_profile = "light_source" //subtle, yellow+red+blue, wall mounted
		sp_light_type = "lamp"
		sp_light_color = "#d8c86a"
		sp_light_radius = 2
	Atmos_17
		surface_profile = "light_source" //subtle, red+blue mix, wall mounted
		sp_light_type = "lamp"
		sp_light_color = "#c86a9a"
		sp_light_radius = 2
	Atmos_19
		surface_profile = "light_source" //very subtle green glow on its button
		sp_light_type = "lamp"
		sp_light_color = "#7fe58f"
		sp_light_radius = 2

obj/KatieObj/Tech
	Tech_2/surface_profile = "emissive_screen"
	Tech_23/surface_profile = "prop_medium"
	Tech_24/surface_profile = "prop_medium"
	Tech_25/surface_profile = "prop_medium"
	Tech_26/surface_profile = "prop_medium"
	Tech_3/surface_profile = "emissive_screen"
	Tech_31/surface_profile = "prop_medium"
	Tech_39
		surface_profile = "light_source" //must be WHITE, may auto-detect as red
		sp_light_type = "lamp"
		sp_light_color = "#ffffff"
		sp_light_radius = 5
	Tech_4/surface_profile = "prop_medium"
	Tech_41/surface_profile = "emissive_hazard"
	Tech_43/surface_profile = "emissive_hazard"
	Tech_47/surface_profile = "prop_medium"
	Tech_56/surface_profile = "prop_medium"
	Tech_64/surface_profile = "prop_medium"
	Tech_67/surface_profile = "prop_medium"
	Tech_68/surface_profile = "emissive_hazard"
	Tech_70/surface_profile = "prop_medium"
	Tech_72/surface_profile = "prop_medium"

obj/Turfs
	Clock/surface_profile = "wall_mounted"
	Console4/surface_profile = "emissive_screen"
	Console5/surface_profile = "emissive_screen"
	Console6L/surface_profile = "emissive_screen"
	Console6R/surface_profile = "emissive_screen"
	Console6R2/surface_profile = "emissive_screen"
	HellRock
		surface_profile = "light_source" //glowing magma at base: subtle orange, focused low
		sp_light_type = "torch"
		sp_light_color = "#ff7a3a"
		sp_light_radius = 3
		sp_light_off_y = -10
	HellRock2
		surface_profile = "light_source" //glowing magma at base: subtle orange, focused low
		sp_light_type = "torch"
		sp_light_color = "#ff7a3a"
		sp_light_radius = 3
		sp_light_off_y = -10
	IconsXLBig/surface_profile = "prop_medium" //IconsXLBig is a prop, not flat
	Jugs/surface_profile = "tabletop" //on tables
	Pew_Bible/surface_profile = "prop_medium" //long seat
	Pew_No_Bible/surface_profile = "prop_medium" //long seat
	Phone/surface_profile = "wall_mounted"
	Plant10/surface_profile = "prop_low" //actually a rock
	Plant11/surface_profile = "prop_medium" //potted plant - prop, not foliage
	Plant12/surface_profile = "prop_medium" //potted plant - prop, not foliage
	SignTech1/surface_profile = "emissive_hazard" //emissive, flat
	SignTech2/surface_profile = "emissive_hazard" //emissive, flat
	Surf/surface_profile = "edge_tile" //water edge; water-like but NO sparkles - too small
	Towel_Rack/surface_profile = "wall_mounted"
	bridgeE/surface_profile = "edge_tile"
	bridgeN/surface_profile = "edge_tile"
	bridgeS/surface_profile = "edge_tile"
	bridgeW/surface_profile = "edge_tile"
	firewood/surface_profile = "prop_medium" //just a wood pile, NOT a light

obj/Turfs/IconsX
	Icon1/surface_profile = "wall_mounted" //shelf on wall
	Icon119/surface_profile = "ground_flat" //too flat for foliage
	Icon126/surface_profile = "ground_flat" //stepping stones
	Icon132/surface_profile = "ground_flat" //small crater
	Icon142/surface_profile = "ground_flat"
	Icon150/surface_profile = "ground_flat" //too flat for foliage
	Icon162/surface_profile = "wall_mounted"
	Icon163/surface_profile = "wall_mounted"
	Icon164/surface_profile = "wall_mounted"
	Icon165/surface_profile = "wall_mounted"
	Icon166/surface_profile = "wall_mounted"
	Icon167/surface_profile = "ground_flat"
	Icon168/surface_profile = "ground_flat"
	Icon173/surface_profile = "ground_flat" //stairs on floors
	Icon174/surface_profile = "ground_flat" //stairs on floors
	Icon27/surface_profile = "wall_mounted"
	Icon28/surface_profile = "wall_mounted"
	Icon29/surface_profile = "wall_mounted"
	Icon3/surface_profile = "wall_mounted"
	Icon30/surface_profile = "wall_mounted"
	Icon38/surface_profile = "tabletop"
	Icon39/surface_profile = "tabletop"
	Icon4/surface_profile = "wall_mounted"
	Icon40/surface_profile = "tabletop"
	Icon5/surface_profile = "wall_mounted"
	Icon56/surface_profile = "tabletop"
	Icon57/surface_profile = "tabletop"
	Icon58/surface_profile = "wall_mounted"
	Icon59/surface_profile = "wall_mounted"
	Icon60/surface_profile = "wall_mounted"
	Icon61/surface_profile = "wall_mounted"
	Icon64/surface_profile = "tabletop"
	Icon65/surface_profile = "tabletop"
	Icon66/surface_profile = "tabletop"
	Icon67/surface_profile = "tabletop"
	Icon68/surface_profile = "tabletop"
	Icon69/surface_profile = "tabletop"
	Icon74/surface_profile = "tabletop"
	Icon75/surface_profile = "tabletop"
	Icon76/surface_profile = "tabletop"
	Icon77/surface_profile = "tabletop"
	Icon79/surface_profile = "wall_mounted"
	Icon8/surface_profile = "wall_mounted"
	Icon80/surface_profile = "wall_mounted"
	Icon81/surface_profile = "wall_mounted"
	Icon82/surface_profile = "wall_mounted"
	Icon87/surface_profile = "ground_flat"
	Icon88/surface_profile = "ground_flat"
	Icon89/surface_profile = "ground_flat"
	Icon9/surface_profile = "wall_mounted"
	Icon90/surface_profile = "ground_flat"

obj/Turfs/IconsXLBig
	Icon10/surface_profile = "prop_medium"
	Icon11/surface_profile = "prop_medium"
	Icon12/surface_profile = "prop_medium"
	Icon13/surface_profile = "prop_medium"
	Icon14/surface_profile = "prop_medium"
	Icon15/surface_profile = "prop_medium"
	Icon16/surface_profile = "prop_medium"
	Icon17/surface_profile = "prop_medium"
	Icon18/surface_profile = "prop_medium"
	Icon19/surface_profile = "prop_medium"
	Icon2/surface_profile = "prop_medium"
	Icon20/surface_profile = "prop_medium"
	Icon21/surface_profile = "prop_medium"
	Icon22/surface_profile = "prop_medium"
	Icon23/surface_profile = "prop_medium"
	Icon24/surface_profile = "wall_mounted"
	Icon25/surface_profile = "wall_mounted"
	Icon26/surface_profile = "wall_mounted"
	Icon27/surface_profile = "wall_mounted"
	Icon28/surface_profile = "wall_mounted"
	Icon29/surface_profile = "wall_mounted"
	Icon3/surface_profile = "prop_medium" //prop, not flat
	Icon30/surface_profile = "wall_mounted"
	Icon31/surface_profile = "wall_mounted"
	Icon32/surface_profile = "wall_mounted" //flat against wall
	Icon34/surface_profile = "wall_mounted"
	Icon35/surface_profile = "wall_mounted"
	Icon36/surface_profile = "wall_mounted" //window with curtains closed
	Icon37/surface_profile = "wall_mounted"
	Icon59/surface_profile = "wall_mounted"
	Icon6/surface_profile = "wall_mounted"
	Icon60/surface_profile = "wall_mounted"
	Icon7/surface_profile = "prop_medium" //bed

obj/Turfs/LightProp
	BlueLamp
		surface_profile = "light_source" //flame art is orange but emits blue - RECOLOR ART
		sp_recolor = "blue" //flame art matched to its light
	GreenLamp
		surface_profile = "light_source" //flame art is orange but emits green - RECOLOR ART
		sp_recolor = "green" //flame art matched to its light

//water-edge trim: reads as water but is far too small to carry a reflection sparkle
obj/Turfs/Surf
	surface_profile = "edge_tile"
	gfx_reflectivity = 0

// reports every gate wind has to pass, in order
/mob/Admin2/verb/Wind_Debug(atom/A as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Wind Debug"
	if(!A) return
	src << "<b>[A.name]</b> ([A.type])"
	src << "profile: [SurfaceProfileOf(A)]"
	if(!istype(A, /atom/movable))
		src << "NOT movable - wind only applies to movable atoms."
		return
	var/atom/movable/M = A
	src << "wind_response: [M.gfx_wind_response] (0 = no wind; profile wants [SurfaceProp(M, "wind")])"
	src << "flags: KEEP_TOGETHER [(M.appearance_flags & KEEP_TOGETHER) ? "ON" : "OFF - overlays will shear apart"] | PIXEL_SCALE [(M.appearance_flags & PIXEL_SCALE) ? "ON" : "OFF"]"
	src << "height: base [SurfaceIconHeight(M)]px, visual [SurfaceVisualHeight(M)]px (gain normalises on visual)"
	src << "registered in material list: [(_gfx_material_atoms && (M in _gfx_material_atoms)) ? "YES" : "NO - never visited by the wind loop"]"
	src << "bucket key: [GfxMaterialBucketKey(M) || "NULL (no turf - cannot be bucketed)"]"
	src << "overlays: [M.overlays ? M.overlays.len : 0][(M.overlays && M.overlays.len) ? " (overlay-built: canopy split skipped, pivot bend only)" : ""]"
	if(M.gfx_canopy_obj)
		var/obj/gfx_canopy/G = M.gfx_canopy_obj
		src << "canopy: SPLIT - crown pivot [G.sp_wind_pivot], crown wind [G.gfx_wind_response] (trunk rigid)"
	else
		var/sp = M.icon ? SurfaceCanopySplit(M.icon, M.icon_state) : 0
		src << "canopy: not split ([sp ? "split row [sp] available - call SurfaceSplitCanopy" : "no usable trunk found in sprite"]); pivot [SurfaceWindPivot(M)]"
	var/turf/T = get_turf(M)
	var/list/W = EnvWindForArea(T ? T.loc : null)
	src << "wind here: [EnvWindReport(T ? T.loc : null)] | amplitude [glob.WIND_AMPLITUDE]"
	if(!W[1] && !W[2]) src << "WIND IS ZERO in this area - profile wind_x/y are 0."
	//every sprite-copy that could render a second tree, and whether it is being swayed
	src << "--- vis_contents ([M.vis_contents ? M.vis_contents.len : 0]) ---"
	for(var/atom/movable/V in M.vis_contents)
		var/synced = (V == M.gfx_material_highlight || V == M.gfx_emissive_copy) ? "SWAYED" : "NOT swayed"
		src << "  [V.type] icon=[V.icon ? "[V.icon]" : "none"] state=[V.icon_state] \
alpha=[V.alpha] px=[V.pixel_x],[V.pixel_y] visflags=[V.vis_flags] xf=[V.transform ? "set" : "none"] -> [synced]"
	src << "--- other copies ---"
	src << "  contact_shadow: [M.gfx_contact_shadow ? "yes ([M.gfx_contact_shadow.type])" : "no"]"
	src << "  emissive_reflection: [M.gfx_emissive_reflection ? "yes" : "no"]"
	src << "  overlays: [M.overlays ? M.overlays.len : 0] | underlays: [M.underlays ? M.underlays.len : 0]"
	src << "  own transform: [M.transform ? "[M.transform.a],[M.transform.b],[M.transform.c] / [M.transform.d],[M.transform.e],[M.transform.f]" : "none"]"

// duplicate forensics
/mob/Admin2/verb/Duplicate_Debug(atom/T as obj|turf in view(6, usr))
	set category = "Mapper"
	set name = "Duplicate Debug"
	if(!T) return
	var/turf/G = get_turf(T)
	if(!G) return
	src << "<b>Everything on [G] ([G.x],[G.y],[G.z]):</b>"
	var/n = 0
	for(var/atom/movable/M in G)
		n++
		src << "  [M.type] | icon=[M.icon] state=[M.icon_state] | alpha=[M.alpha] | wind=[M.gfx_wind_response] phase=[M.gfx_wind_phase] | xf=[M.transform ? "set" : "none"]"
	src << "[n] movable\s. Same type appearing more than once above = a baked duplicate."

/mob/Admin2/verb/Duplicate_Scan()
	set category = "Mapper"
	set name = "Duplicate Scan"
	var/list/stacks = list()
	for(var/turf/G in view(10, usr))
		var/list/seen = list()
		for(var/obj/O in G)
			if(!O.icon || O.gfx_transient_visual) continue
			var/key = "[O.type]@[G.x],[G.y]"
			seen[key] = (seen[key] || 0) + 1
		for(var/key in seen)
			if(seen[key] > 1) stacks[key] = seen[key]
	if(!stacks.len)
		src << "No stacked same-type props within view(10)."
		return
	src << "<b>Stacked duplicates in view:</b>"
	for(var/key in stacks) src << "  [key] x[stacks[key]]"

/mob/Admin2/verb/Duplicate_Purge()
	set category = "Mapper"
	set name = "Duplicate Purge"
	var/kill = 0
	for(var/turf/G in view(10, usr))
		var/list/keep = list()
		var/list/doomed = list()
		for(var/obj/O in G)
			if(!O.icon || O.gfx_transient_visual) continue
			var/key = "[O.type]:[O.icon_state]:[O.pixel_x],[O.pixel_y]"
			if(keep[key]) doomed += O //an exact stacked twin - keep the first only
			else keep[key] = O
		for(var/obj/O in doomed)
			LightPropDetach(O)
			FxEmissiveDetach(O)
			O.loc = null //refcount-free, never del
			kill++
	src << "Purged [kill] stacked duplicate prop\s in view(10). Save the map to make it stick."
	Log("Admin", "[ExtractInfo(src)] purged [kill] stacked duplicate props.")

obj/Turfs/IconsXLBig
	Icon72/surface_profile = "tree" //snow pine
	Icon73/surface_profile = "tree" //palm
	Icon74/surface_profile = "tree" //dead tree
	Icon75/surface_profile = "tree" //pine
	Icon49/surface_profile = "foliage" //ivy

// more classifications
//Screens/holograms/lit panels take emissive_screen: the glow clips to the lit area.
//the 53/54/55 fireplaces are unlit art - they stay props

obj/KatieObj/Furniture
	Furniture_13/surface_profile = "wall_decor" //Bed Topper
	Furniture_100/surface_profile = "wall_decor" //Red Banner
	Furniture_61/surface_profile = "emissive_screen" //Fish Tank Side
	Furniture_62/surface_profile = "emissive_screen" //Fish Tank
	Furniture_77/surface_profile = "emissive_screen" //lit panel
	Furniture_115/surface_profile = "emissive_screen" //Slot Machines
	Furniture_94/surface_profile = "foliage" //Plant

obj/KatieObj/Misc
	Misc_1/surface_profile = "ground_flat" //Beams Down - flat planking
	Misc_21/surface_profile = "emissive_hazard" //Crystal - whole body glows
	Misc_93/surface_profile = "emissive_screen" //Sol Statue - lit top only
	Misc_26/surface_profile = "fence"
	Misc_27/surface_profile = "fence"
	Misc_28/surface_profile = "fence"
	Misc_58/surface_profile = "fence"
	Misc_62/surface_profile = "fence"
	Misc_29/surface_profile = "foliage"
	Misc_30/surface_profile = "foliage"
	Misc_32/surface_profile = "foliage"
	Misc_33/surface_profile = "foliage"
	Misc_35/surface_profile = "foliage"
	Misc_40/surface_profile = "foliage"
	Misc_41/surface_profile = "foliage"
	Misc_61/surface_profile = "foliage"
	Misc_64/surface_profile = "foliage"
	Misc_36/surface_profile = "tree" //gnarled tree
	Misc_38/surface_profile = "prop_tall"
	Misc_39/surface_profile = "prop_tall"
	Misc_45/surface_profile = "prop_tall"
	Misc_66/surface_profile = "prop_tall"
	Misc_70/surface_profile = "prop_tall"
	Misc_71/surface_profile = "prop_tall"
	Misc_78/surface_profile = "prop_tall" //road sign
	Misc_85/surface_profile = "prop_tall"
	Misc_86/surface_profile = "prop_tall"
	Misc_87/surface_profile = "prop_tall" //traffic-light SIGN - painted symbol, not a light
	Misc_88/surface_profile = "prop_tall"
	Misc_89/surface_profile = "prop_tall"
	Misc_90/surface_profile = "prop_tall"
	Misc_91/surface_profile = "prop_tall"
	Misc_96/surface_profile = "prop_tall"
	Misc_98/surface_profile = "prop_tall"

obj/KatieObj/Tech //screens and holograms - glow, cast no light
	Tech_5/surface_profile = "emissive_screen"
	Tech_6/surface_profile = "emissive_screen"
	Tech_18/surface_profile = "emissive_screen"
	Tech_19/surface_profile = "emissive_screen"
	Tech_20/surface_profile = "emissive_screen"
	Tech_21/surface_profile = "emissive_screen"
	Tech_22/surface_profile = "emissive_screen"
	Tech_32/surface_profile = "emissive_screen"
	Tech_33/surface_profile = "emissive_screen"
	Tech_34/surface_profile = "emissive_screen"
	Tech_35/surface_profile = "emissive_screen"
	Tech_36/surface_profile = "emissive_screen"
	Tech_38/surface_profile = "emissive_screen"
	Tech_50/surface_profile = "emissive_screen"
	Tech_51/surface_profile = "emissive_screen"

obj/Turfs/IconsXLBig
	Icon56/surface_profile = "wall_decor" //hanging banner
	Icon57/surface_profile = "wall_decor" //hanging banner
	Icon62/surface_profile = "wall_mounted"
	Icon63/surface_profile = "wall_mounted"
	Icon64/surface_profile = "wall_mounted"
	Icon65/surface_profile = "wall_mounted" //stained glass window

obj/Turfs/MidgarObj
	TV/surface_profile = "emissive_screen"
	Widescreen/surface_profile = "emissive_screen"

obj/Turfs/Sign
	Information_Panel/surface_profile = "emissive_screen"
