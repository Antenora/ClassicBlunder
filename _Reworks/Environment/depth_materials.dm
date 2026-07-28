//cheap depth tricks: contact shadows, wall AO, foreground fades, emissives

atom
	var
		gfx_material_id = "default"
		casts_contact_shadow = 0
		gfx_contact_width = 0 //0 = derive from collision footprint
		gfx_contact_depth = 0
		gfx_contact_alpha = 78
		foreground_occluder = 0
		foreground_fade_alpha = 105
		gfx_emissive_color
		gfx_emissive_strength = 0
		gfx_wettable = 0
		gfx_reflectivity = -1 //-1 = automatic; 0 disables; 1 is a full-strength surface
		gfx_wind_response = 0
		gfx_directional_response = 0 //0 disables; 1 receives the full simulated directional highlight
		icon/gfx_normal_icon //optional RGB tangent-space normal map matching this sprite's states/dirs
		gfx_normal_state //optional state override; null follows icon_state
		gfx_structure_role = GFX_STRUCTURE_NONE
		gfx_elevation_level = 0 //visual/depth tier; does not alter combat pixel_z
		gfx_walk_elevation = 0 //deck tier inherited by standing actors on this tile
		gfx_occlusion_height = 0 //tiles of foreground reach; 0 derives from sprite/collision height
		depth_sort_bias = 0
atom/movable
	var/tmp
		obj/gfx_contact_shadow/gfx_contact_shadow
		obj/gfx_emissive_copy/gfx_emissive_copy
		obj/gfx_material_highlight/gfx_material_highlight
		obj/gfx_emissive_reflection/gfx_emissive_reflection
		matrix/gfx_wind_base_transform
		gfx_wind_phase = 0
		gfx_material_bucket_key

turf
	var/tmp
		_gfx_ao_mask = -1
		list/_gfx_ao_overlays

client
	var/tmp
		list/gfx_foreground_images
		list/gfx_foreground_targets
		list/gfx_foreground_tokens
		gfx_foreground_serial = 0
		gfx_ao_scan_x = 0
		gfx_ao_scan_y = 0
		gfx_ao_scan_z = 0
		gfx_ao_scan_radius = 0
		gfx_ao_scan_incomplete = TRUE

mob
	casts_contact_shadow = 1
	gfx_directional_response = 0.32
	standing = TRUE
	var/tmp/_gfx_reflection_cardinal_dir = SOUTH

mob/gfx_camera
	casts_contact_shadow = 0
	gfx_directional_response = 0

//CustomTurf copies water art without the Water vars, so match by icon too
var/list/_gfx_reflective_water_icons = list('Waters.dmi', 'PurpleWaterfall.dmi', 'water_tile.dmi')

proc/GfxIsWaterSurface(turf/T)
	if(!T) return FALSE
	if(T.Water || T.Shallow || T.Deluged || T.gfx_material_id == "water") return TRUE
	return T.icon in _gfx_reflective_water_icons

proc/GfxIsPermanentReflectiveSurface(turf/T)
	return T && (GfxIsWaterSurface(T) || T.gfx_wettable)

//pixel movement can leave loc a tile behind the visible center - ground checks use these
proc/GfxWorldPixelCenterX(atom/movable/A)
	return A ? (A.x - 1) * world.icon_size + A.step_x + world.icon_size / 2 : 0

proc/GfxWorldPixelCenterY(atom/movable/A)
	return A ? (A.y - 1) * world.icon_size + A.step_y + world.icon_size / 2 : 0

proc/GfxGroundTurf(atom/movable/A)
	if(!A || !A.z) return null
	var/tx = clamp(floor(GfxWorldPixelCenterX(A) / world.icon_size) + 1, 1, world.maxx)
	var/ty = clamp(floor(GfxWorldPixelCenterY(A) / world.icon_size) + 1, 1, world.maxy)
	return locate(tx, ty, A.z)

proc/GfxGroundOffsetX(atom/movable/A, turf/T)
	if(!A || !T) return 0
	return GfxWorldPixelCenterX(A) - ((T.x - 1) * world.icon_size + world.icon_size / 2)

proc/GfxGroundOffsetY(atom/movable/A, turf/T)
	if(!A || !T) return 0
	return GfxWorldPixelCenterY(A) - ((T.y - 1) * world.icon_size + world.icon_size / 2)

turf/Waters
	gfx_material_id = "water"
	gfx_wettable = 1
	gfx_reflectivity = 0.9

turf/Waterfall
	gfx_material_id = "water"
	gfx_wettable = 1
	gfx_reflectivity = 0.85

obj/LifeSkills/Tree
	gfx_material_id = "foliage"
	casts_contact_shadow = 1
	gfx_contact_width = 1.35
	gfx_contact_depth = 0.58
	foreground_occluder = 1
	gfx_wind_response = 0.7
	gfx_directional_response = 0.55
	gfx_occlusion_height = 2

obj/Turfs/Trees
	gfx_material_id = "foliage"
	casts_contact_shadow = 1
	gfx_contact_width = 1.45
	gfx_contact_depth = 0.62
	foreground_occluder = 1
	gfx_wind_response = 0.55
	gfx_directional_response = 0.5
	gfx_occlusion_height = 2

obj/Turfs/LightProp
	gfx_material_id = "emissive_prop"
	casts_contact_shadow = 1
	gfx_emissive_color = "#ffc078"
	gfx_emissive_strength = 90
	gfx_directional_response = 0.28

obj/Turfs/LightProp/Campfire
	gfx_emissive_color = "#ff8038"
	gfx_emissive_strength = 110

obj/Turfs/LightProp/BlueLamp
	gfx_emissive_color = "#7fb0ff"

obj/Turfs/LightProp/GreenLamp
	gfx_emissive_color = "#8fffb0"

obj/Turfs/Torch1
	gfx_material_id = "emissive_prop"
	casts_contact_shadow = 1
	gfx_emissive_color = "#ffb060"
	gfx_emissive_strength = 80

obj/Turfs/Torch2
	gfx_material_id = "emissive_prop"
	casts_contact_shadow = 1
	gfx_emissive_color = "#ffb060"
	gfx_emissive_strength = 80

obj/Turfs/Torch3
	gfx_material_id = "emissive_prop"
	casts_contact_shadow = 1
	gfx_emissive_color = "#ffb060"
	gfx_emissive_strength = 80

obj/Turfs/Fire
	gfx_material_id = "emissive_prop"
	casts_contact_shadow = 1
	gfx_emissive_color = "#ff8038"
	gfx_emissive_strength = 105

obj/Turfs/Edges
	gfx_material_id = "stone_edge"
	gfx_structure_role = GFX_STRUCTURE_EDGE
	gfx_elevation_level = 1
	gfx_occlusion_height = 1
	gfx_directional_response = 0.62
	foreground_fade_alpha = 125

obj/Turfs/bridgeN
	gfx_structure_role = GFX_STRUCTURE_RAIL
	gfx_elevation_level = 1
	gfx_occlusion_height = 1
	gfx_directional_response = 0.48
	foreground_fade_alpha = 135
obj/Turfs/bridgeS
	gfx_structure_role = GFX_STRUCTURE_RAIL
	gfx_elevation_level = 1
	gfx_occlusion_height = 1
	gfx_directional_response = 0.48
	foreground_fade_alpha = 135
obj/Turfs/bridgeE
	gfx_structure_role = GFX_STRUCTURE_RAIL
	gfx_elevation_level = 1
	gfx_occlusion_height = 1
	gfx_directional_response = 0.48
	foreground_fade_alpha = 135
obj/Turfs/bridgeW
	gfx_structure_role = GFX_STRUCTURE_RAIL
	gfx_elevation_level = 1
	gfx_occlusion_height = 1
	gfx_directional_response = 0.48
	foreground_fade_alpha = 135

obj/Turfs/Newturfs/IndustrialBridge
	gfx_material_id = "metal_deck"
	gfx_structure_role = GFX_STRUCTURE_DECK
	gfx_walk_elevation = 1
	gfx_directional_response = 0.42

var/icon/_gfx_contact_icon
var/list/_gfx_ao_icons = list()
var/list/_gfx_ao_dirty = list()
var/list/_gfx_direction_masks = list()
var/icon/_gfx_reflection_fade_icon
var/icon/_gfx_light_reflection_icon
var/list/_gfx_material_atoms = list()
var/list/_gfx_material_buckets = list()
var/list/_gfx_highlight_atoms = list()
var/list/_gfx_contact_objs = list()
var/list/_gfx_emissive_reflection_objs = list()
var/_gfx_reflection_pulse_tick = 0
var/_gfx_reflection_pulse_count = 0
var/_gfx_actor_reflection_ticks = 0

#define GFX_MATERIAL_BUCKET_SIZE 8

/obj/gfx_contact_shadow
	plane = SHADOW_PLANE
	layer = 1
	mouse_opacity = 0
	density = 0
	alpha = 78
	appearance_flags = KEEP_APART //mobs are KEEP_TOGETHER, without this the plane gets ignored
	Savable = 0
	gfx_transient_visual = 1
	var/tmp/atom/movable/owner

/obj/gfx_emissive_copy
	plane = 1
	layer = 6.58
	mouse_opacity = 0
	density = 0
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_APART | KEEP_TOGETHER | RESET_COLOR | RESET_ALPHA //lose KEEP_APART and this draws in place - phantom double
	Savable = 0
	gfx_transient_visual = 1
	var/tmp
		atom/movable/owner
		cached_appearance

	proc/Refresh()
		if(!owner) return
		var/a = owner.appearance
		if(a == cached_appearance && color == owner.gfx_emissive_color && alpha == owner.gfx_emissive_strength) return
		cached_appearance = a
		icon = owner.icon
		icon_state = owner.icon_state
		dir = owner.dir
		overlays = owner.overlays
		underlays = null
		color = owner.gfx_emissive_color || "#ffffff"
		alpha = clamp(owner.gfx_emissive_strength, 0, 180)
		vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE

/obj/gfx_material_highlight
	plane = MATERIAL_LIGHT_PLANE
	layer = 1
	mouse_opacity = 0
	density = 0
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_APART | KEEP_TOGETHER | RESET_COLOR | RESET_ALPHA //same KEEP_APART deal as the emissive copy
	Savable = 0
	gfx_transient_visual = 1
	var/tmp
		atom/movable/owner
		cached_key

	proc/Refresh(list/L)
		if(!owner || !L) return
		var/key = "[owner.appearance]-[L[5]]-[owner.gfx_normal_icon]-[owner.gfx_normal_state]"
		if(key == cached_key) return
		cached_key = key
		dir = owner.dir
		underlays = null
		if(owner.gfx_normal_icon)
			icon = owner.gfx_normal_icon
			icon_state = owner.gfx_normal_state || owner.icon_state
			overlays = null
			filters = null
			color = GfxNormalLightMatrix(L[1], L[2])
		else
			icon = owner.icon
			icon_state = owner.icon_state
			overlays = owner.overlays
			color = L[4]
			filters = filter(type="alpha", icon=_gfx_direction_masks["[L[5]]"])
		alpha = round(clamp(L[3] * owner.gfx_directional_response * 105, 0, 115))
		vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE

/obj/gfx_emissive_reflection
	plane = REFLECTION_PLANE
	layer = 1.1
	mouse_opacity = 0
	density = 0
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA
	Savable = 0
	gfx_transient_visual = 1
	var/tmp
		atom/movable/owner
		turf/surface
		cached_appearance

	proc/Refresh(strength)
		if(!owner || !surface) return
		_GfxDepthBuildIcons()
		loc = surface
		icon = _gfx_light_reflection_icon
		icon_state = null
		dir = SOUTH
		overlays = null
		underlays = null
		transform = matrix(1.25, 0, 0, 0, 0.58, 0)
		pixel_x = 7 + clamp((owner.x - surface.x) * 7, -10, 10)
		pixel_y = -4 + clamp((owner.y - surface.y) * 4, -6, 6)
		color = owner.gfx_emissive_color || "#ffffff"
		alpha = round(clamp(strength, 0, 1) * min(owner.gfx_emissive_strength, 150) * 0.9)
		filters = null

/obj/gfx_reflection_pulse
	plane = REFLECTION_PLANE
	layer = 1.25
	mouse_opacity = 0
	density = 0
	blend_mode = BLEND_ADD
	Savable = 0
	gfx_transient_visual = 1

proc/GfxNormalLightMatrix(dx, dy)
	var/mag = max(0.001, sqrt(dx * dx + dy * dy))
	var/lx = dx / mag * 0.58
	var/ly = dy / mag * 0.58
	var/lz = 0.72
	var/bias = -lx - ly - lz * 0.52
	//approximates the light dot product against an RGB normal map (X/Y around 0.5, Z in blue)
	return list(2*lx,2*lx,2*lx,0, 2*ly,2*ly,2*ly,0, 2*lz,2*lz,2*lz,0, 0,0,0,1, bias,bias,bias,0)

proc/GfxDirectionalKey(dx, dy)
	var/ax = abs(dx)
	var/ay = abs(dy)
	if(ay >= ax) return dy >= 0 ? NORTH : SOUTH
	return dx >= 0 ? EAST : WEST

proc/_GfxDepthBuildIcons()
	if(_gfx_contact_icon && _gfx_direction_masks.len && _gfx_reflection_fade_icon && _gfx_light_reflection_icon) return
	if(!_gfx_contact_icon)
		_gfx_contact_icon = icon('Icons/small_shadow.dmi')
	if(!_gfx_ao_icons.len)
		for(var/d in list(NORTH, SOUTH, EAST, WEST))
			var/icon/I = icon('sandstorm.dmi')
			I.Scale(32, 32)
			I.DrawBox(null, 1, 1, 32, 32)
			for(var/n = 0, n < 7, n++)
				var/a = round(105 * (1 - n / 7) * (1 - n / 7))
				switch(d)
					if(NORTH) I.DrawBox(rgb(0, 0, 0, a), 1, 32 - n, 32, 32 - n)
					if(SOUTH) I.DrawBox(rgb(0, 0, 0, a), 1, 1 + n, 32, 1 + n)
					if(EAST) I.DrawBox(rgb(0, 0, 0, a), 32 - n, 1, 32 - n, 32)
					if(WEST) I.DrawBox(rgb(0, 0, 0, a), 1 + n, 1, 1 + n, 32)
			_gfx_ao_icons["[d]"] = I
	if(!_gfx_direction_masks.len)
		//fallback cardinal gradient masks for sprites without a normal map
		for(var/d in list(NORTH,SOUTH,EAST,WEST))
			var/icon/M = icon('sandstorm.dmi')
			M.Scale(128,128)
			M.DrawBox(null,1,1,128,128)
			for(var/n = 1, n <= 128, n++)
				var/f = clamp(0.16 + (n - 1) / 127 * 0.84, 0, 1)
				var/a = round(f*f*230)
				switch(d)
					if(NORTH) M.DrawBox(rgb(255,255,255,a),1,n,128,n)
					if(SOUTH) M.DrawBox(rgb(255,255,255,a),1,129-n,128,129-n)
					if(EAST) M.DrawBox(rgb(255,255,255,a),n,1,n,128)
					if(WEST) M.DrawBox(rgb(255,255,255,a),129-n,1,129-n,128)
			_gfx_direction_masks["[d]"] = M
	if(!_gfx_reflection_fade_icon)
		var/icon/F = icon('sandstorm.dmi')
		F.Scale(128,128)
		F.DrawBox(null,1,1,128,128)
		for(var/py = 1, py <= 128, py++)
			var/f = clamp((128 - py) / 104, 0, 1)
			F.DrawBox(rgb(255,255,255,round(f*f*255)),1,py,128,py)
		_gfx_reflection_fade_icon = F
	if(!_gfx_light_reflection_icon)
		var/icon/R = icon('Icons/small_shadow.dmi')
		R.Scale(18,30)
		R.Blend("#ffffff", ICON_ADD)
		_gfx_light_reflection_icon = R

proc/GfxMaterialBucketKey(atom/movable/A)
	if(!A || !get_turf(A)) return null
	return "[A.z]:[floor((A.x-1)/GFX_MATERIAL_BUCKET_SIZE)]:[floor((A.y-1)/GFX_MATERIAL_BUCKET_SIZE)]"

proc/GfxMaterialBucketUnregister(atom/movable/A)
	if(!A || !A.gfx_material_bucket_key) return
	var/list/B = _gfx_material_buckets[A.gfx_material_bucket_key]
	if(B)
		B -= A
		if(!B.len) _gfx_material_buckets -= A.gfx_material_bucket_key
	A.gfx_material_bucket_key = null

proc/GfxMaterialBucketRegister(atom/movable/A)
	if(!A || ismob(A)) return //mobs are gathered directly from each client's view
	var/key = GfxMaterialBucketKey(A)
	if(key == A.gfx_material_bucket_key) return
	GfxMaterialBucketUnregister(A)
	if(!key) return
	var/list/B = _gfx_material_buckets[key]
	if(!B)
		B = list()
		_gfx_material_buckets[key] = B
	B |= A
	A.gfx_material_bucket_key = key

proc/GfxMaterialsNear(turf/T, radius)
	var/list/out = list()
	if(!T) return out
	var/bx = floor((T.x-1)/GFX_MATERIAL_BUCKET_SIZE)
	var/by = floor((T.y-1)/GFX_MATERIAL_BUCKET_SIZE)
	var/br = ceil(max(1,radius)/GFX_MATERIAL_BUCKET_SIZE)+1
	for(var/ix = bx-br, ix <= bx+br, ix++)
		for(var/iy = by-br, iy <= by+br, iy++)
			var/list/B = _gfx_material_buckets["[T.z]:[ix]:[iy]"]
			if(B) out |= B
	return out

atom/movable/New()
	. = ..()
	spawn(3) GfxRefreshStructureMetadata(src)

atom/movable/Del()
	GfxClearMaterialVisuals(src)
	GfxMaterialBucketUnregister(src)
	_gfx_material_atoms -= src
	. = ..()

proc/GfxRefreshStructureMetadata(atom/movable/A)
	if(!A) return
	if(istype(A, /obj/Turfs/CustomObj1) && A:edge && A.gfx_structure_role == GFX_STRUCTURE_NONE)
		A.gfx_structure_role = GFX_STRUCTURE_EDGE
		A.gfx_elevation_level = max(A.gfx_elevation_level, 1)
		A.gfx_occlusion_height = max(A.gfx_occlusion_height, 1)
		A.gfx_directional_response = max(A.gfx_directional_response, 0.5)
	if(A.icon == 'Mapping/NewIcons/IndustrialBridge.dmi' && A.gfx_structure_role == GFX_STRUCTURE_NONE)
		A.gfx_structure_role = GFX_STRUCTURE_DECK
		A.gfx_walk_elevation = max(A.gfx_walk_elevation, 1)
		A.gfx_directional_response = max(A.gfx_directional_response, 0.4)
	if(A.casts_contact_shadow || A.gfx_emissive_strength > 0 || A.foreground_occluder || A.gfx_directional_response > 0 || A.gfx_structure_role != GFX_STRUCTURE_NONE)
		_gfx_material_atoms |= A
		GfxMaterialBucketRegister(A)
		if(!A.gfx_wind_phase) A.gfx_wind_phase = rand(0, 359)
		GfxApplyStructureVisuals(A)
		GfxRefreshMaterialVisuals(A)

proc/GfxApplyStructureVisuals(atom/movable/A)
	if(!A || A.gfx_structure_role == GFX_STRUCTURE_NONE) return
	switch(A.gfx_structure_role)
		if(GFX_STRUCTURE_DECK)
			A.layer = max(A.layer, MOB_LAYER - 0.035)
		if(GFX_STRUCTURE_EDGE, GFX_STRUCTURE_RAIL)
			if(A.dir == NORTH)
				A.layer = MOB_LAYER - 0.028
			else if(A.dir == SOUTH)
				A.layer = MOB_LAYER + 0.028
			else
				A.layer = MOB_LAYER + 0.012
		if(GFX_STRUCTURE_FOREGROUND)
			A.layer = max(A.layer, MOB_LAYER + 0.035)

proc/GfxElevationAt(atom/A)
	var/turf/T = get_turf(A)
	if(!T) return 0
	var/level = max(T.gfx_elevation_level, T.gfx_walk_elevation)
	//player-built decks keep the palette icon but not its vars
	if(T.icon == 'Mapping/NewIcons/IndustrialBridge.dmi') level = max(level, 1)
	for(var/obj/O in T)
		if(O.gfx_walk_elevation > level) level = O.gfx_walk_elevation
	return level

proc/GfxElevationLayerBias(atom/A)
	return clamp(GfxElevationAt(A) * 0.016, -0.04, 0.04)

proc/GfxStructureWantsFade(atom/A, mob/P)
	if(!A || !P || A.z != P.z) return FALSE
	if(A.foreground_occluder) return TRUE
	if(A.gfx_structure_role == GFX_STRUCTURE_FOREGROUND) return TRUE
	if(A.gfx_structure_role == GFX_STRUCTURE_EDGE || A.gfx_structure_role == GFX_STRUCTURE_RAIL)
		return A.dir != NORTH
	return FALSE

proc/GfxMaterialLight(atom/movable/A)
	var/turf/T = get_turf(A)
	if(!T) return null
	var/area/AR = T.loc
	var/best_strength = 0
	var/best_dx = 0
	var/best_dy = 1
	var/best_color = "#fff2cf"
	if(AR && AR.sees_sky)
		var/list/SP = SunShadowParams()
		best_dx = -SP[1]
		best_dy = SP[2]
		best_strength = clamp(SP[3] / max(1, glob.SHADOW_SUN_ALPHA), 0.12, 1)
		best_color = SP[4] ? "#b8d2ff" : "#ffe4ad"
	if(glob && glob.LIGHTING)
		for(var/datum/lightsource/L in LightsNearTurf(T, 14))
			var/turf/LT = LightSrcTurf(L)
			if(!LT || LT.z != T.z) continue
			var/d = get_dist(T, LT)
			if(d > L.radius || (d && !LightClearLine(LT, T))) continue
			var/s = (1 - d / max(1, L.radius + 0.5)) * LightRenderStrength(LT) * clamp(L.maxalpha / 170, 0.25, 1.25)
			if(s <= best_strength) continue
			best_strength = s
			best_dx = LT.x - T.x
			best_dy = LT.y - T.y
			if(!best_dx && !best_dy) best_dy = 1
			best_color = L.lcolor
	for(var/datum/fx_light/FL in _fx_lights)
		var/turf/FT = FxLightTurf(FL)
		if(!FT || FT.z != T.z) continue
		var/d = get_dist(T, FT)
		if(d > FL.radius) continue
		var/s = (1 - d / max(1, FL.radius + 0.5)) * LightRenderStrength(FT) * 0.9
		if(s <= best_strength) continue
		best_strength = s
		best_dx = FT.x - T.x
		best_dy = FT.y - T.y
		if(!best_dx && !best_dy) best_dy = 1
		best_color = FL.lcolor || "#fff0c8"
	if(best_strength <= 0.04) return null
	var/key = GfxDirectionalKey(best_dx, best_dy)
	return list(best_dx, best_dy, clamp(best_strength, 0, 1), best_color, key)

proc/GfxEnsureMaterialHighlight(atom/movable/A)
	if(!A) return
	if(A.gfx_directional_response <= 0 || !A.icon || !get_turf(A) || (glob && glob.DBG_NO_HIGHLIGHT))
		GfxClearMaterialHighlight(A)
		return
	var/list/L = GfxMaterialLight(A)
	if(!L)
		GfxClearMaterialHighlight(A)
		return
	//sweep untracked strays
	for(var/obj/gfx_material_highlight/stray in A.vis_contents)
		if(stray != A.gfx_material_highlight)
			A.vis_contents -= stray
			stray.loc = null
	if(!A.gfx_material_highlight)
		var/obj/gfx_material_highlight/H = new
		H.owner = A
		A.vis_contents += H
		A.gfx_material_highlight = H
		_gfx_highlight_atoms |= A
	A.gfx_material_highlight.Refresh(L)

proc/GfxClearMaterialHighlight(atom/movable/A)
	if(!A || !A.gfx_material_highlight) return
	_gfx_highlight_atoms -= A
	A.vis_contents -= A.gfx_material_highlight
	A.gfx_material_highlight.loc = null
	A.gfx_material_highlight = null

proc/GfxTurfReflectionStrength(turf/T)
	if(!T) return 0
	if(GfxIsPermanentReflectiveSurface(T))
		return T.gfx_reflectivity >= 0 ? clamp(T.gfx_reflectivity, 0, 1) : (GfxIsWaterSurface(T) ? 0.9 : 0.8)
	var/area/A = T.loc
	var/datum/environment_profile/P = EnvProfile(A)
	return clamp(max(P ? P.base_wetness : 0, EnvWeatherWetness(A)) * 0.6, 0, 0.65)

proc/GfxFindReflectionSurface(atom/movable/A, radius = 2)
	var/turf/source = get_turf(A)
	if(!source) return null
	var/turf/best
	var/best_score = 1.0e31
	for(var/turf/T in range(radius, source))
		var/r = GfxTurfReflectionStrength(T)
		if(r <= 0.1) continue
		var/score = get_dist(source, T) * 10 + abs(source.x - T.x) * 2
		if(T.y > source.y) score += 5 //prefer a reflection falling toward screen-south
		score -= r * 3
		if(score < best_score)
			best_score = score
			best = T
	return best

proc/GfxEnsureEmissiveReflection(atom/movable/A)
	if(!A || A.gfx_emissive_strength <= 0 || !A.icon || (glob && glob.DBG_NO_GLINT))
		GfxClearEmissiveReflection(A)
		return
	var/turf/surface = GfxFindReflectionSurface(A)
	if(!surface)
		GfxClearEmissiveReflection(A)
		return
	if(!A.gfx_emissive_reflection)
		var/obj/gfx_emissive_reflection/R = new(surface)
		R.owner = A
		A.gfx_emissive_reflection = R
		_gfx_emissive_reflection_objs |= R
	A.gfx_emissive_reflection.surface = surface
	A.gfx_emissive_reflection.Refresh(GfxTurfReflectionStrength(surface))

proc/GfxClearEmissiveReflection(atom/movable/A)
	if(!A || !A.gfx_emissive_reflection) return
	_gfx_emissive_reflection_objs -= A.gfx_emissive_reflection
	A.gfx_emissive_reflection.loc = null
	A.gfx_emissive_reflection = null

proc/GfxReflectionPulse(turf/source, size = 1, color = "#ffffff")
	if(!source || !_fx_glow_icon) return
	if(_gfx_reflection_pulse_tick != world.time)
		_gfx_reflection_pulse_tick = world.time
		_gfx_reflection_pulse_count = 0
	var/cap = max(4, round(10 * GfxBudgetScale()))
	for(var/turf/T in range(2, source))
		var/surface = GfxTurfReflectionStrength(T)
		if(surface <= 0.1 || ++_gfx_reflection_pulse_count > cap) continue
		var/obj/gfx_reflection_pulse/R = new(T)
		R.icon = _fx_glow_icon
		R.color = color || "#ffffff"
		R.alpha = round(125 * surface)
		R.pixel_x = -16
		R.pixel_y = -22
		R.transform = matrix(size*0.35,0,0,0,size*0.12,0)
		animate(R, transform=matrix(size*0.8,0,0,0,size*0.24,0), alpha=0, time=7)
		spawn(8) if(R) R.loc = null

proc/GfxRefreshMaterialVisuals(atom/movable/A)
	if(!A) return
	if(A.gfx_emissive_strength > 0 && A.icon && !(glob && glob.DBG_NO_EMISSIVE))
		for(var/obj/gfx_emissive_copy/stray in A.vis_contents)
			if(stray != A.gfx_emissive_copy)
				A.vis_contents -= stray
				stray.loc = null
		if(!A.gfx_emissive_copy)
			var/obj/gfx_emissive_copy/E = new
			E.owner = A
			A.vis_contents += E
			A.gfx_emissive_copy = E
		A.gfx_emissive_copy.Refresh()
	else if(A.gfx_emissive_copy)
		A.vis_contents -= A.gfx_emissive_copy
		A.gfx_emissive_copy.loc = null
		A.gfx_emissive_copy = null
	GfxEnsureMaterialHighlight(A)
	GfxEnsureEmissiveReflection(A)

proc/GfxApplyMaterialWind(atom/movable/A)
	if(!A || A.gfx_wind_response <= 0) return
	var/turf/T = get_turf(A)
	var/area/AR = T ? T.loc : null
	var/list/W = EnvWindForArea(AR)
	var/power = clamp(sqrt(W[1] * W[1] + W[2] * W[2]) / 5, 0, 1)
	if(!A.gfx_wind_base_transform)
		A.gfx_wind_base_transform = A.transform ? new/matrix(A.transform) : matrix()
	var/angle = sin(world.time * (0.7 + power * 0.45) + A.gfx_wind_phase) * 1.8 * A.gfx_wind_response * power
	var/matrix/target = A.gfx_wind_base_transform * turn(matrix(), angle)
	//END_NOW so a busy server doesn't stack a queue; LINEAR keeps tree overlays together
	animate(A, transform = target, time = 10, flags = ANIMATION_END_NOW | ANIMATION_LINEAR_TRANSFORM)

proc/GfxClearMaterialVisuals(atom/movable/A)
	if(!A) return
	if(A.gfx_contact_shadow)
		_gfx_contact_objs -= A.gfx_contact_shadow
		A.vis_contents -= A.gfx_contact_shadow
		A.gfx_contact_shadow.loc = null
		A.gfx_contact_shadow = null
	if(A.gfx_emissive_copy)
		A.vis_contents -= A.gfx_emissive_copy
		A.gfx_emissive_copy.loc = null
		A.gfx_emissive_copy = null
	GfxClearMaterialHighlight(A)
	GfxClearEmissiveReflection(A)

proc/GfxEnsureContactShadow(atom/movable/A)
	if(!A) return
	if(glob && glob.DBG_NO_CONTACT)
		GfxClearContactShadow(A)
		return
	if(!A.casts_contact_shadow || !A.icon || !get_turf(A)) return
	_GfxDepthBuildIcons()
	//sweep untracked strays
	for(var/obj/gfx_contact_shadow/stray in A.vis_contents)
		if(stray != A.gfx_contact_shadow)
			A.vis_contents -= stray
			_gfx_contact_objs -= stray
			stray.loc = null
	if(!A.gfx_contact_shadow)
		var/obj/gfx_contact_shadow/S = new
		S.owner = A
		S.icon = _gfx_contact_icon
		A.vis_contents += S
		A.gfx_contact_shadow = S
		_gfx_contact_objs |= S
	A.gfx_contact_shadow.pixel_x = -A.pixel_x
	A.gfx_contact_shadow.pixel_y = -A.pixel_y - A.pixel_z - 2
	var/alt = clamp(A.pixel_z / 64, 0, 1)
	var/foot_w = max(1, A.bound_width) / 32
	var/foot_h = max(1, A.bound_height) / 32
	var/base_w = A.gfx_contact_width > 0 ? A.gfx_contact_width : clamp(foot_w * 0.82, 0.7, 2.5)
	var/base_d = A.gfx_contact_depth > 0 ? A.gfx_contact_depth : clamp(0.46 + (foot_h - 1) * 0.12, 0.42, 1)
	var/alt_scale = 1 - alt * 0.4
	A.gfx_contact_shadow.transform = matrix(base_w * alt_scale, 0, 0, 0, base_d * alt_scale, 0)
	A.gfx_contact_shadow.alpha = round(clamp(A.gfx_contact_alpha, 0, 160) * (1 - alt * 0.65))

proc/GfxClearContactShadow(atom/movable/A)
	if(!A || !A.gfx_contact_shadow) return
	_gfx_contact_objs -= A.gfx_contact_shadow
	A.vis_contents -= A.gfx_contact_shadow
	A.gfx_contact_shadow.loc = null
	A.gfx_contact_shadow = null

proc/GfxAOInvalidateNear(turf/T)
	if(!T) return
	for(var/turf/N in range(1, T))
		N._gfx_ao_mask = -1
		_gfx_ao_dirty |= N

proc/GfxAORecompute(turf/T)
	if(!T) return
	_gfx_ao_dirty -= T
	_GfxDepthBuildIcons()
	if(T._gfx_ao_overlays)
		for(var/image/I in T._gfx_ao_overlays)
			T.overlays -= I
	T._gfx_ao_overlays = null
	var/mask = 0
	if(!IsLightOccluder(T))
		for(var/d in list(NORTH, SOUTH, EAST, WEST))
			var/turf/N = get_step(T, d)
			if(!IsLightOccluder(N)) continue
			mask |= d
			var/image/I = image(_gfx_ao_icons["[d]"], T)
			I.plane = SHADOW_PLANE
			I.layer = 0.5
			I.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART
			T.overlays += I
			if(!T._gfx_ao_overlays) T._gfx_ao_overlays = list()
			T._gfx_ao_overlays += I
	T._gfx_ao_mask = mask

proc/GfxAreaReflectionStrength(area/A)
	var/datum/environment_profile/P = EnvProfile(A)
	return P ? P.reflection_strength : 0.65

proc/GfxReflectionDirectionName(direction)
	switch(direction)
		if(NORTH) return "north"
		if(SOUTH) return "south"
		if(EAST) return "east"
		if(WEST) return "west"
	return "none"

//walk outward to the nearest shoreline; the gap measures from the sprite's footprint
proc/_GfxScanReflectionDir(turf/source, direction, offset_x, offset_y, radius = 2)
	var/turf/T = source
	for(var/tiles = 1, tiles <= radius, tiles++)
		T = get_step(T, direction)
		if(!T) return null
		if(GfxIsWaterSurface(T) && !T.Lava && T.gfx_reflectivity != 0)
			var/axis_offset = 0
			switch(direction)
				if(SOUTH) axis_offset = max(0, offset_y)
				if(NORTH) axis_offset = max(0, -offset_y)
				if(WEST) axis_offset = max(0, offset_x)
				if(EAST) axis_offset = max(0, -offset_x)
			var/gap = (tiles - 1) * world.icon_size + axis_offset
			if(gap <= 48)
				return list("surface" = T, "dir" = direction, "gap" = gap, "source" = source)
			return null
		if(T.density || IsLightOccluder(T)) return null
	return null

proc/GfxFindActorReflectionTarget(mob/M, radius = 2)
	var/turf/source = GfxGroundTurf(M)
	if(!source) return null
	//standing on water: the reflection hangs straight below the feet
	if(GfxIsWaterSurface(source) && !source.Lava && source.gfx_reflectivity != 0)
		return list("surface" = source, "dir" = SOUTH, "gap" = 0, "source" = source)
	var/facing = M.dir
	if(facing == NORTH || facing == SOUTH || facing == EAST || facing == WEST)
		M._gfx_reflection_cardinal_dir = facing
	else
		facing = DisplayedCardinal(facing, M._gfx_reflection_cardinal_dir)
	var/offset_x = GfxGroundOffsetX(M, source)
	var/offset_y = GfxGroundOffsetY(M, source)
	var/list/best
	var/best_score = 1.0e31
	for(var/direction in list(SOUTH, NORTH, EAST, WEST))
		var/list/hit = _GfxScanReflectionDir(source, direction, offset_x, offset_y, radius)
		if(!hit) continue
		var/score = hit["gap"]
		//corner ties: prefer below, then the side being faced
		if(direction == SOUTH) score -= 0.75
		if(direction == facing) score -= 0.5
		if(score < best_score)
			best_score = score
			best = hit
	return best

proc/GfxFindActorReflectionSurface(mob/M, radius = 2)
	var/list/target = GfxFindActorReflectionTarget(M, radius)
	return target ? target["surface"] : null

proc/GfxActorReflectionStrength(mob/M, turf/surface = null, gap_pixels = 0)
	if(!M) return 0
	if(!surface) surface = GfxFindActorReflectionSurface(M)
	if(!surface) return 0
	var/area/A = surface.loc
	var/strength = GfxAreaReflectionStrength(A)
	if(GfxIsPermanentReflectiveSurface(surface))
		var/surface_reflectivity = surface.gfx_reflectivity >= 0 ? surface.gfx_reflectivity : (GfxIsWaterSurface(surface) ? 0.9 : 0.8)
		strength *= clamp(surface_reflectivity, 0, 1)
	else
		var/datum/environment_profile/P = EnvProfile(A)
		strength *= max(P ? P.base_wetness : 0, EnvWeatherWetness(A)) * 0.55
	strength *= clamp(1 - gap_pixels / 56, 0.18, 1)
	return clamp(strength, 0, 1)

//reflections scrapped for now; this loop just keeps each client's water mask fresh
proc/_GfxActorReflectionLoop()
	set waitfor = 0
	set background = 1
	while(1)
		if(!WorldLoading)
			_gfx_actor_reflection_ticks++
			for(var/client/C)
				GfxUpdateWaterMask(C)
		sleep(1)

proc/GfxFinishForegroundFade(client/C, atom/A, image/I, token)
	set waitfor = 0
	sleep(4)
	if(!C || !C.gfx_foreground_images || C.gfx_foreground_images[A] != I) return
	if(!C.gfx_foreground_targets || C.gfx_foreground_targets[A]) return
	if(!C.gfx_foreground_tokens || C.gfx_foreground_tokens[A] != token) return
	C.images -= I
	C.gfx_foreground_images -= A
	C.gfx_foreground_targets -= A
	C.gfx_foreground_tokens -= A

proc/GfxForegroundPass(client/C)
	if(!C || !C.mob) return
	if(!C.gfx_foreground_images) C.gfx_foreground_images = list()
	if(!C.gfx_foreground_targets) C.gfx_foreground_targets = list()
	if(!C.gfx_foreground_tokens) C.gfx_foreground_tokens = list()
	var/list/want = list()
	var/Options/prefs = C ? C.prefs : null
	if(istype(prefs, /Options) && prefs.foregroundFade && GfxQualityRank(C) >= GFX_QUALITY_MEDIUM)
		var/mob/P = C.mob
		for(var/atom/movable/O in range(2, P))
			if(!GfxStructureWantsFade(O, P) || O == P) continue
			if(O.y < P.y - 1) continue
			want[O] = 1
		for(var/turf/T in range(1, P))
			if(!T.foreground_occluder && !(istype(T, /turf/CustomTurf) && T:Roof)) continue
			want[T] = 1
	for(var/atom/A in C.gfx_foreground_images.Copy())
		if(want[A]) continue
		var/image/old = C.gfx_foreground_images[A]
		if((A in C.gfx_foreground_targets) && C.gfx_foreground_targets[A] == 0) continue
		C.gfx_foreground_targets[A] = 0
		var/token = ++C.gfx_foreground_serial
		C.gfx_foreground_tokens[A] = token
		animate(old, alpha = A.alpha, time = 3, flags = ANIMATION_END_NOW)
		GfxFinishForegroundFade(C, A, old, token)
	for(var/atom/A in want)
		var/image/I = C.gfx_foreground_images[A]
		if(!I)
			I = image(A)
			I.loc = A
			I.override = 1
			I.alpha = A.alpha
			C.gfx_foreground_images[A] = I
			C.images += I
		else
			var/current_alpha = I.alpha
			I.appearance = A.appearance
			I.alpha = current_alpha
		var/was_target = C.gfx_foreground_targets[A]
		C.gfx_foreground_targets[A] = 1
		C.gfx_foreground_tokens[A] = ++C.gfx_foreground_serial
		if(!was_target) animate(I, alpha = A.foreground_fade_alpha, time = 3, flags = ANIMATION_END_NOW)

proc/_GfxDepthProcess()
	if(WorldLoading) return
	var/list/seen_mobs = list()
	var/list/seen_materials = list()
	var/ao_budget = max(80, round(280 * GfxBudgetScale()))
	while(_gfx_ao_dirty.len && ao_budget > 0)
		var/turf/dirty = _gfx_ao_dirty[1]
		_gfx_ao_dirty.Cut(1, 2)
		if(!dirty || dirty._gfx_ao_mask >= 0) continue
		GfxAORecompute(dirty)
		ao_budget--
	for(var/mob/Players/P in players)
		if(!P.client) continue
		GfxForegroundPass(P.client)
		var/atom/view_anchor = GfxViewAnchor(P.client)
		var/turf/view_turf = get_turf(view_anchor)
		if(!view_turf)
			view_anchor = P
			view_turf = get_turf(P)
		//AO has to cover the fitted view or wide-view clients watch it pop in
		var/visible_r = ClientViewRange(P.client)
		var/effect_r = min(visible_r, 18)
		var/list/client_seen_mobs = list()
		for(var/mob/M in view(effect_r, view_anchor))
			if(M.icon && M.invisibility <= P.see_invisible)
				seen_mobs[M] = 1
				client_seen_mobs[M] = 1
		for(var/atom/movable/A in GfxMaterialsNear(view_turf, effect_r + 2))
			if(!A || !view_turf || A.z != view_turf.z) continue
			if(max(abs(A.x - view_turf.x), abs(A.y - view_turf.y)) <= effect_r + 2) seen_materials[A] = 1
		var/needs_ao_scan = P.client.gfx_ao_scan_incomplete || P.client.gfx_ao_scan_x != view_turf.x || P.client.gfx_ao_scan_y != view_turf.y || P.client.gfx_ao_scan_z != view_turf.z || P.client.gfx_ao_scan_radius != visible_r
		if(needs_ao_scan)
			P.client.gfx_ao_scan_x = view_turf.x
			P.client.gfx_ao_scan_y = view_turf.y
			P.client.gfx_ao_scan_z = view_turf.z
			P.client.gfx_ao_scan_radius = visible_r
			P.client.gfx_ao_scan_incomplete = FALSE
			for(var/turf/T in view(visible_r, view_anchor))
				if(T._gfx_ao_mask >= 0) continue
				if(ao_budget <= 0)
					P.client.gfx_ao_scan_incomplete = TRUE
					break
				GfxAORecompute(T)
				ao_budget--
	for(var/mob/M in seen_mobs)
		GfxEnsureContactShadow(M)
		GfxEnsureMaterialHighlight(M)
	for(var/atom/movable/A in seen_materials)
		GfxApplyStructureVisuals(A)
		GfxEnsureContactShadow(A)
		GfxRefreshMaterialVisuals(A)
		GfxApplyMaterialWind(A)
	for(var/atom/movable/A in _gfx_highlight_atoms.Copy())
		if(seen_materials[A] || seen_mobs[A]) continue
		GfxClearMaterialHighlight(A)
	for(var/obj/gfx_contact_shadow/S in _gfx_contact_objs.Copy())
		var/atom/movable/A = S.owner
		if(!A)
			_gfx_contact_objs -= S
			S.loc = null
		else if(!seen_mobs[A] && !seen_materials[A])
			GfxClearContactShadow(A)
	for(var/obj/gfx_emissive_reflection/R in _gfx_emissive_reflection_objs.Copy())
		if(!R.owner)
			_gfx_emissive_reflection_objs -= R
			R.loc = null
		else if(!seen_materials[R.owner])
			GfxClearEmissiveReflection(R.owner)

var/_gfx_depth_boot = _GfxDepthBoot()

proc/_GfxDepthBoot()
	spawn(110)
		_GfxDepthBuildIcons()
		_GfxActorReflectionLoop()
		_GfxDepthLoop()
	return 1

proc/_GfxDepthLoop()
	set waitfor = 0
	set background = 1
	while(1)
		_GfxDepthProcess()
		sleep(10)

/mob/Admin2/verb/Depth_Sorting_Toggle()
	set category = "Admin"
	set name = "Depth Sorting Toggle"
	glob.DEPTH_SORTING = !glob.DEPTH_SORTING
	for(var/mob/M in world)
		if(glob.DEPTH_SORTING)
			M.gfx_depth_owned_layer = null
			M.UpdateStandingLayer()
		else if(abs(M.layer - MOB_LAYER) <= 0.06)
			M.layer = MOB_LAYER
			M.gfx_depth_owned_layer = null
	src << "Actor depth sorting: [glob.DEPTH_SORTING ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set actor depth sorting to [glob.DEPTH_SORTING].")
