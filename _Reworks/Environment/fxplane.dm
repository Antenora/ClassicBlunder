//FX render pipeline: bloom, skill light glows, screen distortion

globalTracker
	var/tmp
		BLOOM = TRUE //bloom on the effects plane
		BLOOM_SIZE = 8
		BLOOM_THRESHOLD = 190 //0-255 brightness where bloom starts
		DYNAMIC_LIGHTS = TRUE //light glows on magic/Blast/Special/beam skills
		LIGHT_SCALE = 2.5 //glow diameter in tiles at full power
		LIGHT_ICON_COLOR = TRUE //glow color sampled from the skill's own art; off = element palette
		DARK_SKILLS = TRUE //predominantly-black skills swap the glow for a darkening blob (negative light)
		DARKGLOW_ALPHA = 145 //peak strength of that blob
		CHARGE_LIGHTS = TRUE //aura'd actors (charging, transformed) shed a glow colored from their aura art
		CHARGE_LIGHT_ALPHA = 150 //peak strength of that glow in full darkness
		ADAPTIVE_EXPLOSIONS = TRUE //explosion tint follows the skill's own art; off = stock orange
		SCREEN_DISTORT = TRUE //displacement: shockwave rings + fire heat shimmer
		DISTORT_SIZE = 14 //max displacement in px
		PROJ_SHADOWS = TRUE //big/slow blasts drag a soft ground shadow (day + outdoors)
		PROJ_SHADOW_ALPHA = 120 //peak strength at full daylight
		PROJ_SHADOW_SCALE = 1.1 //ellipse width in tiles at IconSize 1
		PROJ_SHADOW_DROP = 12 //px below the art's center
		HEAT_COLUMNS = TRUE //rising shimmer off big explosions/craters/held-skill charging

//captures the effects plane into *fx; fx_relay paints it back in under the HUD
/obj/fxplane_master
	plane = 1
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*fx"

//the render plate: bloomed effects, drawn above world+weather, below the FLY_LAYER+2 HUD
/obj/fx_relay
	screen_loc = "SOUTHWEST" //render_source anchors bottom-left
	layer = 6.9
	mouse_opacity = 0
	render_source = "*fx"

//renders plane 15 into the offscreen "*fxdisp" buffer the displace filter samples
/obj/fxdisp_master
	plane = 15
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*fxdisp"

//no-bloom fx plate: near-white energy art defeats any bloom threshold, so it gets its own plane
/obj/fxnb_master
	plane = 23
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*fxnb"

/obj/fxnb_relay
	screen_loc = "SOUTHWEST"
	layer = 6.89 //just under the bloomed plate at 6.9
	mouse_opacity = 0
	render_source = "*fxnb"

//LIGHTING_PLANE is defined in daynight.dm

//lighting buffer: the master blurs the blocky per-tile lights, the relay adds the result back at 6.55
/obj/fxlight_master
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*fxlight"

/obj/fxlight_relay
	screen_loc = "SOUTHWEST"
	layer = 6.55
	mouse_opacity = 0
	blend_mode = BLEND_ADD //MR OFF default; FxApplyRelayBlend flips it to MULTIPLY + "*fxbase" when MR is on
	render_source = "*fxlight"

//MR base plane: crisp base + blurred lights merge into *fxbase, fxlight_relay multiplies it onto the world
/obj/fxbase_master
	plane = BASE_LIGHTING_PLANE
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "LEFT,BOTTOM"
	mouse_opacity = 0
	layer = BACKGROUND_LAYER
	render_target = "*fxbase" //no blur here - blurring the opaque base rims its edges

/obj/fxlight_into_base
	plane = BASE_LIGHTING_PLANE //re-captured by fxbase_master, composited ABOVE the base (layer 6.55 > 1)
	screen_loc = "SOUTHWEST"
	layer = 6.55
	mouse_opacity = 0
	blend_mode = BLEND_ADD
	render_source = "*fxlight" //the already-blurred additive lights

client
	var/tmp
		obj/fxplane_master/fxplane_master
		obj/fxdisp_master/fxdisp_master
		obj/fxlight_master/fxlight_master
		obj/fxlight_relay/fxlight_relay
		obj/fxbase_master/fxbase_master
		obj/fxlight_into_base/fxlight_into_base
		obj/fx_relay/fx_relay
		obj/fxnb_master/fxnb_master
		obj/fxnb_relay/fxnb_relay
		cpm_blur_size = 0 //current fullscreen blur (poison/drunk); applied by CpmApply

mob/var/tmp/_fx_pulse_t = 0 //autohit cast-pulse debounce (once per tick per caster)

/obj/fx_lightglow
	gfx_transient_visual = 1
	blend_mode = BLEND_ADD
	plane = 0 //world plane: above the darkness blanket, below the HUD stack
	layer = 6.55
	mouse_opacity = 0
	pixel_x = -16 //center the 64px icon on the tile
	pixel_y = -16

//negative light for black skills - keep default blend and plane 1, the additive buffer eats black
/obj/fx_darkglow
	gfx_transient_visual = 1
	plane = 1
	layer = 6.5
	color = "#000000"
	mouse_opacity = 0
	pixel_x = -16
	pixel_y = -16

//wall-occluded light footprint riding a projectile; repaints itself on tile-cross
/obj/fx_occlight
	gfx_transient_visual = 1
	blend_mode = BLEND_ADD
	plane = LIGHTING_PLANE
	layer = 6.55
	mouse_opacity = 0
	var/atom/movable/host //the projectile it follows
	var/active = 1
	var/counted = 0 //this footprint holds a slot in _occ_blast_n
	var/lcolor
	var/radius = 4
	var/turf/last_turf
	var/last_paint = 0

/obj/fx_heatblob
	gfx_transient_visual = 1
	plane = 15 //renders only into the displacement buffer
	layer = 1
	mouse_opacity = 0
	pixel_x = -16
	pixel_y = -16

/obj/fx_dispring
	gfx_transient_visual = 1
	plane = 15
	layer = 2
	mouse_opacity = 0
	pixel_x = -16
	pixel_y = -16
	alpha = 230

//ground shadow ellipse under a big flying blast
/obj/fx_projshadow
	gfx_transient_visual = 1
	plane = SHADOW_PLANE
	layer = 1
	color = "#000000"
	mouse_opacity = 0
	pixel_x = -16
	pixel_y = -16

obj/Skills/Projectile
	plane = 23 //no-bloom fx plate: near-white energy art defeats any bloom threshold
	var/tmp/_fx_glowed = 0 //legacy beam head: glow attached once

//effects render on the bloomed plane; ground props opt back out so they still layer under mobs
obj/Effects
	plane = 1
	Tornado/plane = FLOAT_PLANE
	DeadZone/plane = FLOAT_PLANE
	Blackhole/plane = FLOAT_PLANE
	DividingField/plane = FLOAT_PLANE
	PocketPortal/plane = FLOAT_PLANE
	PocketExit/plane = FLOAT_PLANE
	Barrier/plane = FLOAT_PLANE
	ForceField/plane = FLOAT_PLANE
	PoisonGas/plane = FLOAT_PLANE
	Crater/plane = FLOAT_PLANE
	KKTShockwave/plane = FLOAT_PLANE
	KatenWater/plane = FLOAT_PLANE //ground water sheet, lives under mobs
	Shadowbringer_Shadow/plane = FLOAT_PLANE //under-caster shadow decal

var/icon/_fx_glow_icon
var/icon/_fx_fill_icon //flat disc, soft rim: the indirect-fill bounce layer inside light composites
var/icon/_fx_ring_icon
var/icon/_fx_heat_icon
var/list/_fx_lit_paths = list()
var/_fx_boot = _FxBoot()

proc/_FxBoot()
	spawn(40)
		_FxBuildIcons()
		for(var/v = 0, v <= 2, v++)
			_FxConeIcon(v)
			sleep(world.tick_lag)
		_FxBuildLitPaths()
	return 1

//boot-built icons: radial glow, displacement ring (red=x, green=y, 128=neutral), heat blob
proc/_FxBuildIcons()
	if(_fx_glow_icon && _fx_ring_icon && _fx_heat_icon) return
	var/px
	var/py
	var/icon/G = new('sandstorm.dmi')
	G.Scale(64, 64)
	G.DrawBox(rgb(0,0,0,0), 1, 1, 64, 64)
	for(py = 1, py <= 64, py++)
		for(px = 1, px <= 64, px++)
			var/dx = px - 32.5
			var/dy = py - 32.5
			var/d = sqrt(dx*dx + dy*dy) / 31
			if(d < 1)
				G.DrawBox(rgb(255, 255, 255, round((1-d)*(1-d)*255)), px, py, px, py)
	_fx_glow_icon = G
	//flat inside, smooth rim: bounce fill must be even across the room, not a second hotspot
	var/icon/FD = new('sandstorm.dmi')
	FD.Scale(64, 64)
	FD.DrawBox(rgb(0,0,0,0), 1, 1, 64, 64)
	for(py = 1, py <= 64, py++)
		for(px = 1, px <= 64, px++)
			var/dx = px - 32.5
			var/dy = py - 32.5
			var/d = sqrt(dx*dx + dy*dy) / 31
			if(d < 1)
				var/e = (d <= 0.8) ? 1 : (1 - d) / 0.2
				FD.DrawBox(rgb(255, 255, 255, round(255 * e * e * (3 - 2 * e))), px, py, px, py)
	_fx_fill_icon = FD
	var/icon/R = new('sandstorm.dmi')
	R.Scale(64, 64)
	R.DrawBox(rgb(128,128,128,0), 1, 1, 64, 64)
	for(py = 1, py <= 64, py++)
		for(px = 1, px <= 64, px++)
			var/dx = px - 32.5
			var/dy = py - 32.5
			var/dpx = sqrt(dx*dx + dy*dy)
			var/d = dpx / 31
			if(d > 0.5 && d < 1)
				var/band = 1 - abs(d - 0.75) * 4
				if(band > 0)
					R.DrawBox(rgb(round(128 + dx/max(dpx,1)*120), round(128 + dy/max(dpx,1)*120), 128, round(band*230)), px, py, px, py)
	_fx_ring_icon = R
	var/icon/H = new('sandstorm.dmi')
	H.Scale(64, 64)
	H.DrawBox(rgb(128,128,128,0), 1, 1, 64, 64)
	for(py = 1, py <= 64, py++)
		for(px = 1, px <= 64, px++)
			var/dx = px - 32.5
			var/dy = py - 32.5
			var/d = sqrt(dx*dx + dy*dy) / 31
			if(d < 1)
				H.DrawBox(rgb(128, round(128 + 40*(1-d)), 128, round(150*(1-d))), px, py, px, py)
	_fx_heat_icon = H

#define FX_CONE_PX 96 //cone texture cell; apex sits at the center so Turn() aims it cleanly

var/list/_fx_cone_icons = list()

proc/_FxConeIcon(variant = 0)
	var/key = "cone[variant]"
	if(_fx_cone_icons[key]) return _fx_cone_icons[key]
	var/half = FX_CONE_PX / 2 + 0.5
	var/rad = FX_CONE_PX / 2 - 1
	var/list/rays = list()
	if(variant) //deterministic spread per variant, no rand() at boot
		for(var/i = 1, i <= 7, i++)
			rays += (((i * 17 + variant * 11) % 53) - 26)
	var/icon/C = new('sandstorm.dmi')
	C.Scale(FX_CONE_PX, FX_CONE_PX)
	C.DrawBox(rgb(0,0,0,0), 1, 1, FX_CONE_PX, FX_CONE_PX)
	for(var/py = 1, py <= FX_CONE_PX, py++)
		for(var/px = 1, px <= FX_CONE_PX, px++)
			var/dx = px - half
			var/dy = py - half
			var/r = sqrt(dx*dx + dy*dy)
			var/d = r / rad
			if(d >= 1) continue
			var/ang = (r > 1) ? arccos(dx / r) : 0 //degrees off +x, 0..180
			var/angK = (ang <= 30) ? 1 : max(0, 1 - (ang - 30) / 9)
			if(angK <= 0) continue
			//solid body with a soft rim: gentle falloff across the length, then a short feather
			var/radial = 1 - 0.45 * d
			if(d > 0.8) radial *= (1 - d) / 0.2
			var/a = 0
			if(!variant)
				a = radial * angK * 225
			else
				var/signed = (dy < 0) ? -ang : ang //mirror for the ray bands
				var/rk = 0
				for(var/ra in rays)
					var/off = abs(signed - ra)
					if(off < 7) rk = max(rk, 1 - off / 7)
				if(rk <= 0) continue
				a = radial * angK * rk * 250
			if(a < 3) continue
			C.DrawBox(rgb(255, 255, 255, round(min(a, 255))), px, py, px, py)
	_fx_cone_icons[key] = C
	return C

//combat light child: additive, aimable, torn down by ref
/obj/fx_clashlight
	gfx_transient_visual = 1
	Savable = 0
	blend_mode = BLEND_ADD
	layer = 6.55
	mouse_opacity = 0
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	var/tmp/is_ray = 0 //ray-streak layer: owns its own wave loop, skip bulk transform tweens

//rays sweep inside the cone
proc/FxConeRayWave(obj/fx_clashlight/O, matrix/base, phase, base_a)
	if(!O || !base) return
	var/matrix/L = matrix(base)
	L.Turn(-10)
	var/matrix/R = matrix(base)
	R.Turn(10)
	var/lo = round(base_a * 0.35)
	animate(O, transform = L, alpha = phase ? base_a : lo, time = 7, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = R, alpha = phase ? lo : base_a, time = 7, easing = SINE_EASING)

proc/FxClashLightPair(atom/movable/host, icon/tex, col, matrix/mx, wa = 215, ba = 250)
	. = list()
	if(!host || !tex) return
	var/frac = LightRenderStrength(get_turf(host)) //~0.10 daylight, ~1 at night
	wa = round(wa * (1 - 0.65 * frac))
	ba = round(ba * (0.35 + 0.65 * frac))
	var/list/anc = FxChildAnchor(host)
	var/ox = anc[1] + (64 - tex.Width()) / 2 
	var/oy = anc[2] + (64 - tex.Height()) / 2
	for(var/pl in list(1, LIGHTING_PLANE))
		var/obj/fx_clashlight/L = new
		L.icon = tex
		L.color = col
		L.alpha = (pl == 1) ? wa : ba
		L.plane = pl
		if(pl == 1) L.layer = 6
		L.transform = mx
		L.pixel_x = ox
		L.pixel_y = oy
		host.vis_contents += L
		. += L

proc/FxConeAim(open_dir, scale = 1)
	var/matrix/M = matrix()
	M.Turn(dir2angle(open_dir) - 90)
	M.Scale(scale)
	return M

proc/FxAttachConeLight(atom/movable/host, open_dir, col = "#ffffff", scale = 3)
	. = list()
	if(!host) return
	var/matrix/M = FxConeAim(open_dir, scale)
	. += FxClashLightPair(host, _FxConeIcon(0), col, M, 205, 240) //body
	var/list/r1 = FxClashLightPair(host, _FxConeIcon(1), col, M, 225, 255)
	var/list/r2 = FxClashLightPair(host, _FxConeIcon(2), col, M, 200, 235)
	for(var/obj/fx_clashlight/O in r1)
		O.is_ray = 1
		FxConeRayWave(O, M, 1, O.alpha)
	for(var/obj/fx_clashlight/O in r2)
		O.is_ray = 1
		FxConeRayWave(O, M, 0, O.alpha)
	. += r1
	. += r2

proc/FxAttachRoundLight(atom/movable/host, col = "#ffffff", scale = 1.6, rays = 0)
	. = FxClashLightPair(host, _fx_glow_icon, col, matrix() * scale, 165, 230)
	if(!rays) return
	for(var/obj/fx_clashlight/O in .)
		O.filters += filter(name = "clashrays", type = "rays", size = 26, color = col, density = 11, threshold = 0.5, factor = 0.3)
		var/F = O.filters["clashrays"]
		if(!F) continue
		//two steps or loop=-1 silently does nothing; ~12s cycle so it visibly churns
		animate(F, offset = 1000, time = 120, loop = -1, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
		animate(offset = 0, time = 0)

//detach + free a list of clash lights from their host
proc/FxDropLights(atom/movable/host, list/objs)
	if(!objs) return
	for(var/obj/O in objs)
		if(host) host.vis_contents -= O
		animate(O) //cancel the looping wave/churn chains before the obj is freed
		O.filters = null
		O.loc = null

proc/_FxBuildLitPaths()
	for(var/t = 1, t <= 5, t++)
		var/list/bucket = SkillTree["BlastT[t]"]
		if(bucket)
			for(var/k in bucket)
				_fx_lit_paths[k] = 1

proc/FxSkillCastsLight(obj/Skills/S)
	if(!S) return 0
	if(S.MagicNeeded || S.SpellElement) return 1
	if(istype(S, /obj/Skills/Projectile))
		var/obj/Skills/Projectile/P = S
		if(P.Area == "Beam") return 1
	if(_fx_lit_paths["[S.type]"]) return 1
	return 0

//beam?
proc/FxSkillIsBeam(obj/Skills/Projectile/S)
	return S && S.Area == "Beam"

//only big/slow shots earn the occluded footprint; heuristic
proc/FxSkillBigSlow(obj/Skills/Projectile/S)
	if(!S) return 0
	if(S.Charge) return 1 //chargeable = heavy/slow
	if(S.Explode >= 2) return 1 //sizable explosion
	if(S.Radius >= 1) return 1 //area attack
	if(S.IconSize >= 2) return 1 //physically large art
	return 0

//fire-ish: fire/hellfire element, fire spell, or burning status riders on the shot
proc/FxSkillIsFire(obj/Skills/Projectile/P, obj/Skills/Projectile/Z)
	var/obj/Skills/Projectile/S = Z ? Z : P
	if(!S) return 0
	if(S.SpellElement == "Fire") return 1
	if(S.ElementalClass == "Fire" || S.ElementalClass == "Hellfire") return 1
	if(islist(S.ElementalClass) && (("Fire" in S.ElementalClass) || ("Hellfire" in S.ElementalClass))) return 1
	if(P && (P.Burning || P.Scorching || P.Combustion)) return 1
	return 0

//mostly-black skill: the live art measures dark or wears a near-black tint
proc/FxSkillIsDark(obj/Skills/Projectile/P, obj/Skills/Projectile/Z)
	if(!P) return 0
	if(P.color && istext(P.color))
		var/list/tc = _FxRGB(P.color)
		if(tc && max(tc[1], max(tc[2], tc[3])) < 60) return 1
	var/f = 0
	if(P.icon)
		f = _FxIconDarkFrac(P.icon, P.icon_state)
	else if(Z && Z.IconLock)
		f = _FxIconDarkFrac(Z.IconLock, P.icon_state)
	return f >= FX_DARK_FRAC_MIN

//anchor a 64px vis child on the art's true center - big skills carry pixel_x like -158
proc/FxChildAnchor(atom/movable/P)
	if(P.vhb_w > 0) //pixel hitbox active: its center is the art's true center
		return list(-16 + P.vhb_ox - P.pixel_x, -16 + P.vhb_oy - P.pixel_y)
	return list(-16, -16) //legacy path: keep the parent offset, center on its tile

//dominant-color sampling, one sweep per icon+state, cached forever
var/list/_fx_icon_color_cache = list()

proc/_FxIconRaw(f, state)
	if(!f) return null
	var/id = "[f]"
	//runtime /icon datums stringify to ""/"/icon" - key those by ref() or every custom blast collides
	if(!length(id) || id == "/icon") id = "[ref(f)]"
	var/key = "[id]:[state]"
	var/hit = _fx_icon_color_cache[key]
	if(hit) return hit == "x" ? null : hit
	var/result = _FxSampleIcon(f, state)
	_fx_icon_color_cache[key] = result ? result : "x"
	return result

//as a light: lifted toward white so it reads as glow, not paint
proc/FxIconColor(f, state)
	return _FxLift(_FxIconRaw(f, state))

//as paint: the saturated hue itself; grayscale art returns null so callers fall back to stock orange
proc/FxIconPaint(f, state)
	var/c = _FxIconRaw(f, state)
	var/list/p = _FxRGB(c)
	if(!p) return null
	if(255 - min(p[1], min(p[2], p[3])) < 255 * 0.15) return null //same neutral cut the sampler uses
	return c

proc/_FxRGB(col) //"#rrggbb" -> list(r,g,b); null on anything else (named colors, #rgb shorthand)
	if(!col || !istext(col) || length(col) < 7) return null
	return list(text2num(copytext(col, 2, 4), 16), text2num(copytext(col, 4, 6), 16), text2num(copytext(col, 6, 8), 16))

proc/_FxLift(col)
	var/list/c = _FxRGB(col)
	if(!c) return null
	return rgb(round(c[1] * 0.78 + 255 * 0.22), round(c[2] * 0.78 + 255 * 0.22), round(c[3] * 0.78 + 255 * 0.22))

proc/_FxSampleIcon(f, state)
	var/icon/I = new(f, state)
	if(!I) return null
	var/w = I.Width()
	var/h = I.Height()
	if(!w || !h) return null
	var/stride = max(1, round(w / 16))
	//12 hue bins + a neutral bucket; track weight and weighted rgb sums
	var/list/bw = new/list(12)
	var/list/br = new/list(12)
	var/list/bg = new/list(12)
	var/list/bb = new/list(12)
	var/i
	for(i = 1, i <= 12, i++)
		bw[i] = 0; br[i] = 0; bg[i] = 0; bb[i] = 0
	var/nw = 0
	var/nr = 0
	var/ng = 0
	var/nb = 0
	for(var/py = 1, py <= h, py += stride)
		for(var/px = 1, px <= w, px += stride)
			var/c = I.GetPixel(px, py)
			if(!c) continue
			var/r = text2num(copytext(c, 2, 4), 16)
			var/g = text2num(copytext(c, 4, 6), 16)
			var/b = text2num(copytext(c, 6, 8), 16)
			if(length(c) >= 9 && text2num(copytext(c, 8, 10), 16) < 96) continue
			var/M = max(r, g, b)
			var/m = min(r, g, b)
			if(M < 40) continue //outlines / near-black
			var/s = (M - m) / M
			var/weight = (M / 255) * (0.25 + s)
			if(s < 0.15)
				nw += weight; nr += r * weight; ng += g * weight; nb += b * weight
				continue
			var/ch = M - m
			var/hue = 0
			if(M == r) hue = 60 * (g - b) / ch
			else if(M == g) hue = 60 * ((b - r) / ch + 2)
			else hue = 60 * ((r - g) / ch + 4)
			if(hue < 0) hue += 360
			var/bin = round(hue / 30) + 1
			if(bin > 12) bin = 1
			bw[bin] += weight
			br[bin] += r * weight
			bg[bin] += g * weight
			bb[bin] += b * weight
	var/best = 0
	var/bestw = 0
	for(i = 1, i <= 12, i++)
		if(bw[i] > bestw)
			bestw = bw[i]
			best = i
	var/fr
	var/fg
	var/fb
	if(best && bestw >= nw * 0.6) //prefer the vivid hue unless the icon is truly neutral
		fr = br[best] / bw[best]; fg = bg[best] / bw[best]; fb = bb[best] / bw[best]
	else if(nw > 0)
		fr = nr / nw; fg = ng / nw; fb = nb / nw
	else
		return null
	//normalize bright; callers decide light-lift vs paint
	var/scale = 255 / max(fr, max(fg, fb))
	return rgb(round(fr * scale), round(fg * scale), round(fb * scale))

//dark test
var/const/FX_DARK_FRAC_MIN = 0.4
var/const/FX_DARK_BRIGHT_VETO = 0.25
var/list/_fx_icon_dark_cache = list()

proc/_FxIconDarkFrac(f, state)
	if(!f) return 0
	var/id = "[f]"
	//same key strategy as _FxIconRaw: runtime /icon datums stringify to ""/"/icon" - ref() them
	if(!length(id) || id == "/icon") id = "[ref(f)]"
	var/key = "[id]:[state]"
	var/hit = _fx_icon_dark_cache[key]
	if(!isnull(hit)) return hit
	var/result = _FxMeasureDarkFrac(f, state)
	_fx_icon_dark_cache[key] = result
	return result

proc/_FxMeasureDarkFrac(f, state)
	var/icon/I = new(f, state)
	if(!I) return 0
	var/w = I.Width()
	var/h = I.Height()
	if(!w || !h) return 0
	var/stride = max(1, round(w / 16))
	var/n = 0
	var/dark = 0
	var/bright = 0
	for(var/py = 1, py <= h, py += stride)
		for(var/px = 1, px <= w, px += stride)
			var/c = I.GetPixel(px, py)
			if(!c) continue
			if(length(c) >= 9 && text2num(copytext(c, 8, 10), 16) < 96) continue
			n++
			var/M = max(text2num(copytext(c, 2, 4), 16), max(text2num(copytext(c, 4, 6), 16), text2num(copytext(c, 6, 8), 16)))
			if(M < 60) dark++
			else if(M >= 200) bright++
	if(!n) return 0
	if(bright / n >= FX_DARK_BRIGHT_VETO) return 0 //bright core: the black is outline, not body
	return dark / n

//glow color for a flying projectile: explicit tint > its own art > element palette
proc/FxGlowColor(obj/Skills/Projectile/P)
	if(P && glob && glob.LIGHT_ICON_COLOR)
		if(P.color && istext(P.color)) return P.color
		var/c = FxIconColor(P.icon, P.icon_state)
		if(c) return c
	return FxElementColor(P ? P.SpellElement : null)

//pulse color for an effect obj (explosions): explicit tint > its art
proc/FxEffectColor(atom/E)
	if(!E || !glob || !glob.LIGHT_ICON_COLOR) return null
	if(E.color && istext(E.color)) return E.color
	return FxIconColor(E.icon, E.icon_state)

//pulse color for an autohit cast: hitspark art > skill art > element palette
proc/FxAutoHitColor(obj/Skills/AutoHit/Z)
	if(Z && glob && glob.LIGHT_ICON_COLOR)
		var/c = FxIconColor(Z.HitSparkIcon, null)
		if(!c) c = FxIconColor(Z.icon, Z.icon_state)
		if(c) return c
	return FxElementColor(Z ? Z.SpellElement : null)

//explosion.dmi is baked grayscale; FxRampMatrix repaints it any tint - FX_BANG_TINT gives the stock orange back exactly
var/FX_BANG_TINT = "#fc7a01" //stock ramp edge
var/FX_BANG_LIGHT = "#ffb739" //what the stock art samples to; keeps untinted light pulses identical
var/const/FX_RAMP_K = 0.846 //how far the art drives its hot channel toward the dominant one
var/const/FX_RAMP_MIN = 0.35 //shortest ramp we allow, as a fraction of the dominant channel

//tint -> 4x3 color matrix ramping edge->core; red cores run fire-orange, blue cores cyan
proc/FxRampMatrix(tint)
	var/list/e = _FxRGB(tint)
	if(!e) return null
	var/dom = 1
	if(e[2] > e[dom]) dom = 2
	if(e[3] > e[dom]) dom = 3
	var/ch = 2 //green is the art's hot-shift channel...
	if(dom == 2) ch = (e[1] >= e[3]) ? 1 : 3 //...unless green already leads; then take the middle
	var/list/c = e.Copy()
	c[ch] = e[ch] + (e[dom] - e[ch]) * FX_RAMP_K
	//hot channel already topped out: cool the edge instead so the ramp keeps its span
	if(c[ch] - e[ch] < e[dom] * FX_RAMP_MIN)
		var/lo = 1
		if(e[2] < e[lo]) lo = 2
		if(e[3] < e[lo]) lo = 3
		e[ch] = max(e[lo], c[ch] - e[dom] * FX_RAMP_MIN)
	return list((c[1]-e[1])/255, (c[2]-e[2])/255, (c[3]-e[3])/255, 0, 0, 0, 0, 0, 0, e[1]/255, e[2]/255, e[3]/255)

//light thrown by a ramped explosion: read the edge back from the matrix (the guard may have cooled it), walk 0.38 up, lift
proc/FxRampPulse(tint)
	var/list/M = FxRampMatrix(tint)
	if(!M) return null
	return _FxLift(rgb(round((M[10] + M[1] * 0.38) * 255), round((M[11] + M[2] * 0.38) * 255), round((M[12] + M[3] * 0.38) * 255)))

//explosion tint for a projectile: explicit tint > its own art > element; null = stock orange
proc/FxBlastTint(obj/Skills/Projectile/P)
	if(!P || !glob || !glob.ADAPTIVE_EXPLOSIONS) return null
	if(P.color && istext(P.color)) return P.color
	var/c = FxIconPaint(P.icon, P.icon_state)
	if(c) return c
	return P.SpellElement ? FxElementColor(P.SpellElement) : null

//same, for an autohit cast: hitspark art > skill art > element
proc/FxAutoHitTint(obj/Skills/AutoHit/Z)
	if(!Z || !glob || !glob.ADAPTIVE_EXPLOSIONS) return null
	var/c = FxIconPaint(Z.HitSparkIcon, null)
	if(!c) c = FxIconPaint(Z.icon, Z.icon_state)
	if(c) return c
	return Z.SpellElement ? FxElementColor(Z.SpellElement) : null

proc/FxElementColor(el)
	switch(el)
		if("Fire") return "#ffab5e"
		if("Water") return "#7ec8ff"
		if("Earth") return "#d8b878"
		if("Air") return "#d8ffe8"
		if("Wind") return "#d8ffe8"
		if("Light") return "#fff8d8"
		if("Dark") return "#b080ff"
		if("Time") return "#80ffd8"
		if("Space") return "#8890ff"
	return "#ffe2b0" //warm ki default

//light registry for shadows: moving lights track their atom, pulses are fixed points that expire
var/list/_fx_lights = list()

/datum/fx_light
	var/atom/movable/src_atom //moving source (projectile); position read live
	var/turf/fixed //fixed point (explosion/cast pulse)
	var/radius = 6
	var/lcolor
	var/expire = 0 //world.time; 0 = lives as long as src_atom exists

proc/FxRegisterLight(atom/movable/source, turf/fixed_t, radius = 6, lcolor = null, life = 0)
	if(!glob || !glob.WORLD_SHADOWS || !glob.LIGHT_SHADOWS) return //no shadows = no need to track lights
	var/cap = max(12, round(64 * GfxBudgetScale()))
	if(_fx_lights.len >= cap) return
	var/datum/fx_light/L = new
	L.src_atom = source
	L.fixed = fixed_t
	L.radius = radius
	L.lcolor = lcolor
	if(life) L.expire = world.time + life
	_fx_lights += L
	return L

proc/FxLightTurf(datum/fx_light/L)
	if(L.fixed) return L.fixed
	return L.src_atom ? get_turf(L.src_atom) : null

proc/FxPruneLights()
	for(var/datum/fx_light/L in _fx_lights.Copy())
		if(L.expire)
			if(world.time >= L.expire) _fx_lights -= L
		else if(!L.src_atom || !L.src_atom.loc) //moving source deleted, or off-map/dying (endLife nulls loc before its sleep)
			_fx_lights -= L

// aura lights
//aura light: one pooled vis child + a shadow entry riding the actor - follows aura state, not Auraz edges
mob/var/tmp/obj/fx_lightglow/charge_glow
mob/var/tmp/datum/fx_light/charge_fxlight
mob/var/tmp/charge_glow_cycle //icon-file text driving a color cycle, or null
mob/var/tmp/charge_glow_frac = 0 //darkness the glow was last driven at - drift re-bases alpha
mob/var/tmp/charge_glow_ikey //name-or-ref of the aura icon sizing/coloring the glow now

//animated multi-hue auras baked offline; Rainbow runs the full hue wheel
var/list/_aura_cycle_cache
proc/AuraCycleColors()
	if(_aura_cycle_cache) return _aura_cycle_cache
	_aura_cycle_cache = list(\
		"RainbowAura.dmi" = list(48, "#ff3838", "#ff9b38", "#ffff38", "#9bff38", "#38ff38", "#38ff9b",\
		                         "#38ffff", "#389bff", "#3838ff", "#9b38ff", "#ff38ff", "#ff389b"))
	return _aura_cycle_cache

//IconLock art worn from a buff or held skill ('BLANK.dmi' = the held default)
proc/_BuffLockIcon(mob/M)
	if(M.ActiveBuff && M.ActiveBuff.IconLock && "[M.ActiveBuff.IconLock]" != "BLANK.dmi") return M.ActiveBuff.IconLock
	if(M.SpecialBuff && M.SpecialBuff.IconLock && "[M.SpecialBuff.IconLock]" != "BLANK.dmi") return M.SpecialBuff.IconLock
	if(M.AttackQueue && M.AttackQueue.IconLock && "[M.AttackQueue.IconLock]" != "BLANK.dmi") return M.AttackQueue.IconLock
	return null

//aura icon priority: lock, buff IconLocks, form auras, powered aura, overlays, underlays
proc/MobAuraIcon(mob/M)
	if(M.AuraLocked && M.AuraLock) return M.AuraLock
	var/il = _BuffLockIcon(M)
	if(il) return il
	if(M.transActive >= 2 && M.Form2Aura) return M.Form2Aura //player-uploaded form auras
	if(M.transActive && M.Form1Aura) return M.Form1Aura //render plain-blend: the ADD scan can't see them
	if(M.ChargingEnergy || M.PoweringUp || M.PowerControl > 100)
		for(var/obj/Skills/Power_Control/PC in M.contents) //the customized powered-state aura
			if(PC.sicon) return PC.sicon
	for(var/o in M.overlays)
		var/image/I = o //appearances aren't /image datums - raw cast, then read the vars
		if(I && I.blend_mode == BLEND_ADD && I.icon) return I.icon
	for(var/o in M.underlays)
		var/image/I = o
		if(I && I.icon) return I.icon
	return null

//runtime cycle probe for uploaded animated auras; no real hue travel = static color
var/list/_aura_custom_cycle = list() //"[ref]" -> list(total_ds, colors...) | "static"
proc/AuraCustomCycle(f)
	var/id = "[f]"
	if(length(id) && id != "/icon") return null //named files are the offline table's job
	var/key = "[ref(f)]"
	var/hit = _aura_custom_cycle[key]
	if(hit) return islist(hit) ? hit : null
	var/list/cols = list()
	try
		for(var/i = 1, i <= 8, i++)
			var/icon/F = new(f, null, SOUTH, i)
			var/c = _FxSampleIcon(F, null)
			if(!c) break
			cols += c
	catch //frame extraction from an uploaded datum can runtime - degrade, never crash the attach
		_aura_custom_cycle[key] = "static"
		return null
	//count occupied hue bins: an aura that TRAVELS the wheel fills several
	var/list/bins = list()
	var/list/uniq = list()
	for(var/c in cols)
		var/list/p = _FxRGB(c)
		if(!p) continue
		var/mx = max(p[1], max(p[2], p[3]))
		var/mn = min(p[1], min(p[2], p[3]))
		if(!mx || (mx - mn) / mx < 0.15) continue //neutral frame: no hue to bin
		var/ch = mx - mn
		var/hue = 0
		if(mx == p[1]) hue = 60 * (p[2] - p[3]) / ch
		else if(mx == p[2]) hue = 60 * ((p[3] - p[1]) / ch + 2)
		else hue = 60 * ((p[1] - p[2]) / ch + 4)
		if(hue < 0) hue += 360
		var/bin = "[round(hue / 30)]"
		if(!(bin in bins))
			bins += bin
			uniq += c //one representative color per hue bin keeps the chain short
	if(bins.len >= 4) //4+ distinct hue regions = genuinely color-shifting
		var/list/out = list(max(12, uniq.len * 4)) //~4ds per stop reads calm
		out += uniq
		_aura_custom_cycle[key] = out
		return out
	_aura_custom_cycle[key] = "static"
	return null

//mirrors the Auraz Add branches, keep them in step
proc/MobAuraActive(mob/M)
	if(!M) return 0
	//var checks first (can't runtime); NEVER test skill ownership - skills sit in contents forever
	if(M.ChargingEnergy || M.PoweringUp) return 1
	if(M.PowerControl > 100) return 1 //holding a powered state (Ki Control etc) keeps the aura up
	if(M.AuraLocked && M.AuraLock) return 1
	if(_BuffLockIcon(M)) return 1 //IconLock buffs + held-skill locks wear visible art
	if(M.transActive) return 1
	if(M.tension >= 5) return 1
	if(M.ClothBronze) return 1
	if(M.Saga == "Spiral") return 1
	try //proc-backed checks last: a runtime in any of them must not kill the light path
		if(M.passive_handler && M.passive_handler.Get("Controlled Chaos")) return 1
		if(M.passive_handler && M.passive_handler.Get("BurningShot")) return 1
		if(M.CheckSpecial("Kamui Unite")) return 1
		if(M.RippleActive()) return 1
	catch
	return 0

//inked extent of an icon (max bbox of visible pixels), cached - tiny art lights small
var/list/_fx_icon_inked = list()
proc/_FxIconInked(f)
	if(!f) return 32
	var/id = "[f]"
	if(!length(id) || id == "/icon") id = "[ref(f)]"
	var/hit = _fx_icon_inked[id]
	if(hit) return hit
	var/inked = 32
	try
		var/icon/I = new(f)
		var/w = I.Width()
		var/h = I.Height()
		if(w > 0 && h > 0)
			var/minx = w + 1
			var/maxx = 0
			var/miny = h + 1
			var/maxy = 0
			for(var/py = 1, py <= h, py += 2)
				for(var/px = 1, px <= w, px += 2)
					var/c = I.GetPixel(px, py)
					if(!c) continue
					if(length(c) >= 9 && text2num(copytext(c, 8, 10), 16) < 40) continue
					if(px < minx) minx = px
					if(px > maxx) maxx = px
					if(py < miny) miny = py
					if(py > maxy) maxy = py
			if(maxx >= minx) inked = max(maxx - minx + 1, maxy - miny + 1)
	catch
		inked = 32
	_fx_icon_inked[id] = inked
	return inked

//glow scale from inked size: ~12px flame -> ~1.4 tiles, 96px aura -> ~4.8
proc/_AuraGlowScale(inked)
	return clamp(0.5 + inked * 0.02, 0.6, 3.2)

//single entry point: attach, refresh or drop the light to match the mob's real state
proc/MobAuraLightRefresh(mob/M)
	if(!M) return
	if(!glob || !glob.CHARGE_LIGHTS || !glob.LIGHTING || !glob.DYNAMIC_LIGHTS || !MobAuraActive(M))
		MobAuraLightOff(M)
		return
	MobAuraLightOn(M)

//loop the glow through a baked color cycle; gentle alpha wave rides the same chain
proc/_AuraCycleDrive(obj/fx_lightglow/L, list/cyc, frac)
	var/steps = cyc.len - 1
	var/step_t = max(1, round(cyc[1] / steps))
	var/aHi = round(glob.CHARGE_LIGHT_ALPHA * frac)
	var/aLo = round(aHi * 0.8)
	L.color = cyc[2]
	L.alpha = aHi
	animate(L, color = cyc[3], alpha = aLo, time = step_t, loop = -1)
	for(var/i = 4, i <= cyc.len, i++)
		animate(color = cyc[i], alpha = (i % 2) ? aHi : aLo, time = step_t)
	animate(color = cyc[2], alpha = aHi, time = step_t)

proc/MobAuraLightOn(mob/M)
	if(!M || !glob || !glob.CHARGE_LIGHTS || !glob.LIGHTING || !glob.DYNAMIC_LIGHTS) return
	if(!_fx_glow_icon) _FxBuildIcons()
	if(!_fx_glow_icon) return
	var/turf/t = get_turf(M)
	if(!t) return
	var/frac = LightRenderStrength(t)
	//the daylight floor is 0.10 - below dusk, no aura light at all (a dim husk otherwise sticks)
	if(frac < 0.25)
		MobAuraLightOff(M)
		return
	//the light must attach no matter what sampling does - failures fall back to the default color
	var/aicon
	var/list/cyc
	var/col
	var/inked = 32
	try
		aicon = MobAuraIcon(M)
		cyc = aicon ? (AuraCycleColors()["[aicon]"] || AuraCustomCycle(aicon)) : null
		col = cyc ? cyc[2] : (aicon ? FxIconColor(aicon, null) : null)
		inked = _FxIconInked(aicon)
	catch
		cyc = null
		col = null
	if(!col) col = "#cfe4ff" //bare ki charge: cool white
	//icon datums all stringify alike - key by ref or two custom auras read as the same
	var/aid = "[aicon]"
	var/ikey = aicon ? ((length(aid) && aid != "/icon") ? aid : "[ref(aicon)]") : null
	var/key = cyc ? ikey : null
	var/rad = clamp(round(inked / 16) + 2, 2, 8)
	if(M.charge_glow) //already lit: track color/cycle/size/strength in place
		if(M.charge_fxlight)
			M.charge_fxlight.lcolor = col
			M.charge_fxlight.radius = rad
		if(M.charge_glow_ikey != ikey)
			M.charge_glow_ikey = ikey
			M.charge_glow.transform = matrix() * _AuraGlowScale(inked)
		if(key != M.charge_glow_cycle || abs(frac - M.charge_glow_frac) > 0.02)
			M.charge_glow_cycle = key
			M.charge_glow_frac = frac
			if(cyc)
				_AuraCycleDrive(M.charge_glow, cyc, frac)
			else
				animate(M.charge_glow) //end any running chain
				M.charge_glow.color = col
				M.charge_glow.alpha = round(glob.CHARGE_LIGHT_ALPHA * frac)
				animate(M.charge_glow, alpha = round(glob.CHARGE_LIGHT_ALPHA * frac * 0.72), time = 9, loop = -1, easing = SINE_EASING)
				animate(alpha = round(glob.CHARGE_LIGHT_ALPHA * frac), time = 9, easing = SINE_EASING)
		else if(!cyc)
			M.charge_glow.color = col
		return
	var/obj/fx_lightglow/L = new
	L.icon = _fx_glow_icon
	L.color = col
	L.alpha = round(glob.CHARGE_LIGHT_ALPHA * frac)
	L.transform = matrix() * _AuraGlowScale(inked) //light footprint follows the art's real size
	var/list/anc = FxChildAnchor(M)
	L.pixel_x = anc[1]
	L.pixel_y = anc[2]
	if(glob.MULTIPLY_REVEAL) L.plane = LIGHTING_PLANE //add INTO the buffer so the multiply reveals it
	M.vis_contents += L
	M.charge_glow = L
	M.charge_fxlight = FxRegisterLight(M, null, rad, col)
	M.charge_glow_cycle = key
	M.charge_glow_frac = frac
	M.charge_glow_ikey = ikey
	if(cyc)
		_AuraCycleDrive(L, cyc, frac)
	else
		//slow breathing so the pool reads alive without strobing
		animate(L, alpha = round(glob.CHARGE_LIGHT_ALPHA * frac * 0.72), time = 9, loop = -1, easing = SINE_EASING)
		animate(alpha = round(glob.CHARGE_LIGHT_ALPHA * frac), time = 9, easing = SINE_EASING)

proc/MobAuraLightOff(mob/M)
	if(!M) return
	if(M.charge_glow)
		M.vis_contents -= M.charge_glow
		M.charge_glow.loc = null //refcount-free, never del
		M.charge_glow = null
	if(M.charge_fxlight)
		_fx_lights -= M.charge_fxlight
		M.charge_fxlight = null
	M.charge_glow_cycle = null
	M.charge_glow_frac = 0
	M.charge_glow_ikey = null

//reconciler: catches aura paths with no edge hook + day/night moving under standing players
proc/_AuraLightTick()
	set waitfor = 0
	set background = 1
	while(1)
		if(glob && glob.CHARGE_LIGHTS && glob.LIGHTING)
			for(var/client/C)
				var/mob/M = C.mob
				if(M) spawn(-1) MobAuraLightRefresh(M) //isolated: one mob's runtime must not kill the sweep
		sleep(50) //5s: the net for paths with no edge hook (timer-expired buffs etc)

var/_aura_light_boot = _AuraLightBoot()
proc/_AuraLightBoot()
	spawn(120)
		_AuraLightTick()
	return 1

//walks the aura-light chain and prints every gate; run it while the aura is up
/mob/Admin2/verb/Aura_Light_Debug()
	set category = "Admin"
	set name = "Aura Light Debug"
	var/mob/M = src
	src << "<b>--- aura light debug ---</b>"
	src << "globs: CHARGE_LIGHTS=[glob.CHARGE_LIGHTS] LIGHTING=[glob.LIGHTING] DYNAMIC_LIGHTS=[glob.DYNAMIC_LIGHTS] MULTIPLY_REVEAL=[glob.MULTIPLY_REVEAL] CHARGE_LIGHT_ALPHA=[glob.CHARGE_LIGHT_ALPHA]"
	src << "state: ChargingEnergy=[M.ChargingEnergy] PoweringUp=[M.PoweringUp] AuraLocked=[M.AuraLocked] AuraLock=[M.AuraLock ? "SET" : "null"] transActive=[M.transActive] tension=[M.tension] ClothBronze=[M.ClothBronze] Saga=[M.Saga]"
	var/pc = 0
	for(var/obj/Skills/Power_Control/P in M.contents)
		pc++
		src << "  Power_Control #[pc]: [P.type] sicon=[P.sicon ? "SET ([P.sicon])" : "null"]"
	src << "Power_Control objs in contents: [pc]"
	src << "PowerControl=[M.PowerControl] ActiveBuff=[M.ActiveBuff ? "[M.ActiveBuff.type] lock=[M.ActiveBuff.IconLock]" : "null"] SpecialBuff=[M.SpecialBuff ? "[M.SpecialBuff.type] lock=[M.SpecialBuff.IconLock]" : "null"] QueueLock=[M.AttackQueue ? "[M.AttackQueue.IconLock]" : "null"]"
	src << "MobAuraActive = [MobAuraActive(M)]"
	var/aicon = MobAuraIcon(M)
	src << "MobAuraIcon = [aicon ? "SET (\"[aicon]\" ref [ref(aicon)])" : "null"]"
	if(aicon) src << "inked=[_FxIconInked(aicon)]px -> glow scale [_AuraGlowScale(_FxIconInked(aicon))]"
	var/turf/t = get_turf(M)
	src << "turf=[t ? "[t.x],[t.y],[t.z]" : "NULL"] LightRenderStrength=[t ? LightRenderStrength(t) : "n/a"]"
	src << "_fx_glow_icon=[_fx_glow_icon ? "built" : "NULL"]"
	src << "before: charge_glow=[M.charge_glow ? "EXISTS alpha=[M.charge_glow.alpha] color=[M.charge_glow.color] plane=[M.charge_glow.plane] in_vis=[(M.charge_glow in M.vis_contents) ? "yes" : "NO"]" : "null"] fxlight=[M.charge_fxlight ? "yes" : "null"] cycle=[M.charge_glow_cycle] driven_frac=[M.charge_glow_frac]"
	src << "calling MobAuraLightRefresh synchronously..."
	MobAuraLightRefresh(M)
	src << "after refresh: charge_glow=[M.charge_glow ? "EXISTS alpha=[M.charge_glow.alpha] color=[M.charge_glow.color] plane=[M.charge_glow.plane] in_vis=[(M.charge_glow in M.vis_contents) ? "yes" : "NO"]" : "null"]"
	if(!M.charge_glow)
		src << "refresh did not attach - forcing MobAuraLightOn directly..."
		MobAuraLightOn(M)
		src << "after forced On: charge_glow=[M.charge_glow ? "EXISTS alpha=[M.charge_glow.alpha] color=[M.charge_glow.color] plane=[M.charge_glow.plane]" : "STILL NULL"]"
	src << "vis_contents total: [M.vis_contents ? M.vis_contents.len : 0]"
	src << "<b>--- end ---</b>"

/mob/Admin2/verb/Charge_Lights_Toggle()
	set category = "Admin"
	set name = "Charge Lights Toggle"
	glob.CHARGE_LIGHTS = !glob.CHARGE_LIGHTS
	if(!glob.CHARGE_LIGHTS)
		for(var/mob/M in world)
			if(M.charge_glow) MobAuraLightOff(M)
	src << "Aura charge lights: [glob.CHARGE_LIGHTS ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set charge lights to [glob.CHARGE_LIGHTS].")

//attach glow (and heat blob for fire) to a flying projectile/beam head; Z can be null on the legacy beam path
proc/FxAttachLight(obj/Skills/Projectile/P, obj/Skills/Projectile/Z)
	if(!P || !glob) return
	//anchor children on the art's true center, canceling the inherited parent offset
	var/list/anc = FxChildAnchor(P)
	var/cx = anc[1]
	var/cy = anc[2]
	//black skills get the dark blob and veto every bright path below - the veto must hold even with DYNAMIC_LIGHTS off
	var/is_dark = glob.DARK_SKILLS && _fx_glow_icon && FxSkillIsDark(P, Z)
	if(is_dark && glob.DYNAMIC_LIGHTS)
		var/obj/fx_darkglow/D = new
		D.icon = _fx_glow_icon
		D.alpha = glob.DARKGLOW_ALPHA
		D.transform = matrix() * (glob.LIGHT_SCALE * 0.85)
		D.pixel_x = cx
		D.pixel_y = cy
		P.vis_contents += D
	//big/slow blasts get a wall-occluded footprint (capped); everything else falls through to the cheap glow
	var/occ_on = 0
	var/occ_cap = max(1, round(glob.OCCLUDED_BLAST_MAX * GfxBudgetScale()))
	if(!is_dark && glob.LIGHTING && glob.OCCLUDED_BLASTS && Z && !FxSkillIsBeam(Z) && FxSkillBigSlow(Z) && _occ_blast_n < occ_cap)
		if(LightRenderStrength(get_turf(P)) > 0.03)
			occ_on = FxAttachOccLight(P)
	if(!is_dark && !occ_on && glob.DYNAMIC_LIGHTS && _fx_glow_icon && (Z ? FxSkillCastsLight(Z) : 1))
		var/frac = LightRenderStrength(get_turf(P))
		if(frac > 0.03)
			var/obj/fx_lightglow/L = new
			L.icon = _fx_glow_icon
			L.color = FxGlowColor(P)
			L.alpha = round(210 * frac)
			L.transform = matrix() * glob.LIGHT_SCALE
			L.pixel_x = cx
			L.pixel_y = cy
			if(glob.MULTIPLY_REVEAL) L.plane = LIGHTING_PLANE //add INTO the buffer so the multiply reveals it (else it gets multiplied down)
			P.vis_contents += L
			FxRegisterLight(P, null, glob.LIGHT_SHADOW_RADIUS, FxGlowColor(P)) //moving light for shadows
	if(glob.SCREEN_DISTORT && _fx_heat_icon && FxSkillIsFire(P, Z))
		var/obj/fx_heatblob/H = new
		H.icon = _fx_heat_icon
		H.transform = matrix() * 1.3
		H.pixel_x = cx
		H.pixel_y = cy
		P.vis_contents += H
		animate(H, transform = matrix() * 1.7, time = 4, loop = -1)
		animate(transform = matrix() * 1.3, time = 4)
	//big/slow blasts drag a ground shadow, day + outdoors only
	if(!is_dark && glob.PROJ_SHADOWS && _fx_glow_icon && Z && !FxSkillIsBeam(Z) && FxSkillBigSlow(Z))
		var/turf/pt = get_turf(P)
		var/area/pa = pt ? pt.loc : null
		var/sfrac = 1 - DnDarknessFrac()
		if(pa && pa.sees_sky && sfrac > 0.1)
			var/obj/fx_projshadow/S = new
			S.icon = _fx_glow_icon
			S.alpha = round(glob.PROJ_SHADOW_ALPHA * sfrac)
			var/sc = glob.PROJ_SHADOW_SCALE * max(Z.IconSize, 1)
			S.transform = matrix(sc, 0, 0, 0, sc * 0.45, 0)
			S.pixel_x = cx
			S.pixel_y = cy - glob.PROJ_SHADOW_DROP
			P.vis_contents += S

var/_fx_pulse_tick = 0
var/_fx_pulse_n = 0

//one-shot glow burst; per-tick cap so turf-AoE loops can't flood the world
proc/FxLightPulse(turf/T, size = 1.5, col = null, min_frac = 0)
	if(!glob || !glob.DYNAMIC_LIGHTS || !_fx_glow_icon || !T) return
	var/frac = max(LightRenderStrength(T), min_frac)
	if(frac < 0.03) return
	if(_fx_pulse_tick != world.time)
		_fx_pulse_tick = world.time
		_fx_pulse_n = 0
	if(++_fx_pulse_n > max(5, round(12 * GfxBudgetScale()))) return
	var/obj/fx_lightglow/L = new(T)
	L.icon = _fx_glow_icon
	if(col) L.color = col
	L.alpha = round(230 * frac)
	L.transform = matrix() * 0.4
	if(glob.MULTIPLY_REVEAL) L.plane = LIGHTING_PLANE //reveal through the multiply instead of being darkened by it
	animate(L, transform = matrix() * size, alpha = 0, time = 6)
	GfxReflectionPulse(T, size, col || "#ffe2b0")
	FxRegisterLight(null, T, glob.LIGHT_SHADOW_RADIUS - 1, col, 8) //transient light for shadows
	spawn(8) if(L) L.loc = null //never del transient FX - del scans the whole world; loc=null frees it fine

var/_fx_dpulse_tick = 0
var/_fx_dpulse_n = 0

//dark twin of FxLightPulse: one-shot darkening burst for black explosions
proc/FxDarkPulse(turf/T, size = 1.5)
	if(!glob || !glob.DYNAMIC_LIGHTS || !glob.DARK_SKILLS || !_fx_glow_icon || !T) return
	if(_fx_dpulse_tick != world.time)
		_fx_dpulse_tick = world.time
		_fx_dpulse_n = 0
	if(++_fx_dpulse_n > 12) return
	var/obj/fx_darkglow/D = new(T)
	D.icon = _fx_glow_icon
	D.alpha = glob.DARKGLOW_ALPHA
	D.transform = matrix() * 0.4
	animate(D, transform = matrix() * size, alpha = 0, time = 6)
	spawn(8) if(D) D.loc = null //same refcount-free teardown as the light pulse

var/_fx_heatcol_tick = 0
var/_fx_heatcol_n = 0

//rising heat shimmer off a blast site, per-tick capped
proc/FxHeatColumn(turf/T, size = 1)
	set waitfor = 0
	if(!glob || !glob.SCREEN_DISTORT || !glob.HEAT_COLUMNS || !_fx_heat_icon || !T) return
	if(_fx_heatcol_tick != world.time)
		_fx_heatcol_tick = world.time
		_fx_heatcol_n = 0
	if(++_fx_heatcol_n > 6) return
	size = min(size, 3)
	for(var/i = 0, i < 2, i++)
		var/obj/fx_heatblob/H = new(T)
		H.icon = _fx_heat_icon
		H.transform = matrix() * (0.7 + size * 0.3)
		animate(H, pixel_y = 34, alpha = 0, transform = matrix() * (1.1 + size * 0.4), time = 15, easing = SINE_EASING|EASE_OUT)
		spawn(17) if(H) H.loc = null
		sleep(5)

//heat shimmer over a charging caster; watches held_skill so every ChargeLoop exit tears it down
//KEEP_APART below is load-bearing: mobs are KEEP_TOGETHER, without it the displacement plane gets ignored
proc/FxChargeShimmer(mob/M, obj/Skills/Z)
	set waitfor = 0
	if(!M || !glob || !glob.SCREEN_DISTORT || !glob.HEAT_COLUMNS || !_fx_heat_icon) return
	var/obj/fx_heatblob/H = new
	H.icon = _fx_heat_icon
	H.appearance_flags |= KEEP_APART
	H.transform = matrix() * 1.1
	M.vis_contents += H
	animate(H, transform = matrix() * 1.5, time = 5, loop = -1)
	animate(transform = matrix() * 1.1, time = 5)
	while(M && M.held_skill == Z)
		sleep(5)
	if(M) M.vis_contents -= H //dropping the ref frees it

//Bang's routing test: dark explosion art (icon_override) or an explicit near-black tint
proc/FxBangIsDark(icon_override, color_override)
	if(!glob || !glob.DARK_SKILLS) return 0
	if(icon_override) return _FxIconDarkFrac(icon_override, null) >= FX_DARK_FRAC_MIN
	var/list/tc = _FxRGB(color_override)
	if(tc && max(tc[1], max(tc[2], tc[3])) < 60) return 1
	return 0

//autohit cast: Icon is the big visible art (Enuma's Hellnova), hitspark only covers a missing one
proc/FxAutoHitIsDark(obj/Skills/AutoHit/Z)
	if(!Z || !glob || !glob.DARK_SKILLS) return 0
	var/f = 0
	if(Z.Icon)
		f = _FxIconDarkFrac(Z.Icon, null)
	else if(Z.HitSparkIcon)
		f = _FxIconDarkFrac(Z.HitSparkIcon, null)
	return f >= FX_DARK_FRAC_MIN

var/_occ_blast_n = 0 //live count of occluded blast footprints (hard-capped by OCCLUDED_BLAST_MAX)

//attach a wall-occluded footprint to a big/slow blast; returns 1 so the caller skips the radial glow
proc/FxAttachOccLight(obj/Skills/Projectile/P)
	var/obj/fx_occlight/O = new
	O.host = P
	O.lcolor = FxGlowColor(P)
	O.radius = glob.OCCLUDED_BLAST_RADIUS
	O.counted = 1
	_occ_blast_n++
	P.vis_contents += O
	FxRegisterLight(P, null, glob.LIGHT_SHADOW_RADIUS, O.lcolor) //this light also casts shadows
	var/turf/s = get_turf(P)
	O.last_turf = s
	O.last_paint = world.time
	OccLightPaint(O, s)
	OccLightRun(O)
	return 1

//is any occluder within rr of s? (early-exit) - decides cheap soft-circle vs per-cell footprint
proc/OccOccluderNear(turf/s, rr)
	if(!s) return 0
	for(var/turf/T in range(rr, s))
		if(T != s && IsLightOccluder(T)) return 1
	return 0

//repaint the footprint: open air = a scaled soft circle, near a wall = a 1px-per-tile occluded bitmap scaled up
proc/OccLightPaint(obj/fx_occlight/O, turf/s)
	if(!O || !s) return
	var/frac = LightRenderStrength(s)
	if(frac < 0.03)
		O.alpha = 0
		return
	var/rr = O.radius
	var/list/anc = FxChildAnchor(O.host) //re-anchor each paint so pixel-glide drift resyncs per tile
	if(!OccOccluderNear(s, rr))
		O.icon = _fx_glow_icon
		O.transform = matrix() * rr
		O.color = O.lcolor
		O.alpha = round(glob.LIGHT_MAX_ALPHA * frac) //match the near-wall peak so no pop when a wall enters radius
		O.pixel_x = anc[1]
		O.pixel_y = anc[2]
		return
	var/N = 2 * rr + 1
	var/icon/ic = icon('sandstorm.dmi')
	ic.Scale(N, N)
	ic.DrawBox(null, 1, 1, N, N) //erase to transparent (null color = erase)
	for(var/turf/T in range(rr, s))
		var/ddx = T.x - s.x
		var/ddy = T.y - s.y
		var/d = sqrt(ddx * ddx + ddy * ddy)
		if(d > rr) continue
		if(T != s && !LightClearLine(s, T)) continue //wall-blocked
		var/fo = 1 - (d / (rr + 0.5))
		fo *= fo //smooth edge
		var/a = round(255 * fo)
		if(a < 8) continue
		ic.DrawBox(rgb(255, 255, 255, a), ddx + rr + 1, ddy + rr + 1, ddx + rr + 1, ddy + rr + 1)
	O.icon = ic //stays N-px: upscaling here would transmit a fresh ~288px resource every repaint
	O.transform = matrix() * 32 //blow the tiny icon up client-side (PIXEL_SCALE plane + the master blur soften it)
	O.color = O.lcolor
	O.alpha = round(glob.LIGHT_MAX_ALPHA * frac)
	O.pixel_x = anc[1] + 32 - N / 2 //center the N-px icon (scaled about its own center) on the host tile
	O.pixel_y = anc[2] + 32 - N / 2

//poll loop: repaint only on a new tile, tear down the moment the host dies
proc/OccLightRun(obj/fx_occlight/O)
	set waitfor = 0
	set background = 1
	while(O && O.active && O.host && O.host.loc)
		var/turf/t = get_turf(O.host)
		if(t && t != O.last_turf && (world.time - O.last_paint) >= glob.OCCLUDED_BLAST_INTERVAL * world.tick_lag) //INTERVAL is in ticks; world.time is deciseconds
			O.last_turf = t
			O.last_paint = world.time
			OccLightPaint(O, t)
		sleep(world.tick_lag)
	OccLightEnd(O)

//refcount-free teardown, never del
proc/OccLightEnd(obj/fx_occlight/O)
	if(!O) return
	O.active = 0
	if(O.counted)
		O.counted = 0
		_occ_blast_n--
	if(O.host)
		O.host.vis_contents -= O
		O.host = null
	O.loc = null

var/_fx_ring_tick = 0
var/_fx_ring_n = 0
var/list/_fx_ring_turfs = list()

//expanding displacement ring; same-turf-same-tick casts coalesce to one and a per-tick cap holds the rest
proc/FxDistortRing(atom/M, Size = 1)
	if(!glob || !glob.SCREEN_DISTORT || !_fx_ring_icon || !M) return
	var/turf/T = isturf(M) ? M : get_turf(M)
	if(!T) return
	if(_fx_ring_tick != world.time)
		_fx_ring_tick = world.time
		_fx_ring_n = 0
		_fx_ring_turfs.Cut()
	if(_fx_ring_turfs[T]) return //stacked same-target rings would multi-bend the scene
	if(++_fx_ring_n > 4) return
	_fx_ring_turfs[T] = 1
	var/obj/fx_dispring/R = new(T)
	R.icon = _fx_ring_icon
	R.transform = matrix() * 0.3
	animate(R, transform = matrix() * (1 + Size * 1.6), alpha = 0, time = 6)
	spawn(8) if(R) R.loc = null //same as the glow: avoid del's world-wide ref scan on burst FX

//sole writer of client_plane_master.filters: fullscreen blur (poison/drunk) + displace
proc/CpmApply(client/C)
	if(!C) return
	if(!C.client_plane_master)
		C.client_plane_master = new()
		C.screen += C.client_plane_master
	var/list/fl = list()
	if(glob && glob.COLOR_GRADE && GfxQualityRank(C) >= GFX_QUALITY_MEDIUM)
		fl += Hd2dGradeFilter(C) //zone-aware grade: plane-0 master only, the HUD (plane 100) stays clean
	if(glob && glob.WORLD_BLOOM && _Hd2dLocalDark(C) > 0.35 && GfxBloomEnabled(C))
		//whole-scene night bloom: placed fires/lights blossom (skill-FX bloom never sees them)
		var/wt = WorldBloomThreshold(C)
		fl += filter(type="bloom", threshold=rgb(wt, wt, wt), size=glob.WORLD_BLOOM_SIZE)
	if(C.cpm_blur_size > 0)
		fl += filter(type="blur", size=C.cpm_blur_size)
	if(glob && glob.SCREEN_DISTORT && GfxDistortEnabled(C))
		fl += filter(type="displace", size=glob.DISTORT_SIZE, render_source="*fxdisp")
	C.client_plane_master.filters = fl.len ? fl : null
	FxApplyBloom(C) //keep the effects-plane blur mirror in sync

//bloom + a mirror of the fullscreen blur - the effects plane escapes client_plane_master
proc/FxApplyBloom(client/C)
	if(!C || !C.fxplane_master) return
	var/grade = glob && glob.COLOR_GRADE && GfxQualityRank(C) >= GFX_QUALITY_MEDIUM
	var/list/fl = list()
	if(grade) fl += Hd2dGradeFilter(C) //the fx plates escape the world master - mirror the grade
	if(glob && glob.BLOOM && GfxBloomEnabled(C))
		var/t = clamp(glob.BLOOM_THRESHOLD + C.gfx_env_bloom_bias, 96, 245)
		var/bs = GfxQualityRank(C) >= GFX_QUALITY_HIGH ? glob.BLOOM_SIZE : max(2, round(glob.BLOOM_SIZE * 0.55))
		fl += filter(type="bloom", threshold=rgb(t,t,t), size=bs)
	if(C.cpm_blur_size > 0)
		fl += filter(type="blur", size=C.cpm_blur_size)
	C.fxplane_master.filters = fl.len ? fl : null
	if(C.fxnb_master) //the no-bloom plate: same mirrors, never the bloom
		var/list/nfl = list()
		if(grade) nfl += Hd2dGradeFilter(C)
		if(C.cpm_blur_size > 0)
			nfl += filter(type="blur", size=C.cpm_blur_size)
		C.fxnb_master.filters = nfl.len ? nfl : null

proc/FxEnsureMasters(client/C)
	if(!C) return
	if(!C.fxplane_master)
		C.fxplane_master = new()
		C.screen += C.fxplane_master
	if(!C.fxdisp_master)
		C.fxdisp_master = new()
		C.screen += C.fxdisp_master
	if(!C.fx_relay)
		C.fx_relay = new()
		C.screen += C.fx_relay
	if(!C.fxlight_master)
		C.fxlight_master = new()
		C.screen += C.fxlight_master
	if(!C.fxlight_relay)
		C.fxlight_relay = new()
		C.screen += C.fxlight_relay
	if(!C.fxbase_master)
		C.fxbase_master = new()
		C.screen += C.fxbase_master
	if(!C.fxlight_into_base)
		C.fxlight_into_base = new()
		C.screen += C.fxlight_into_base
	if(!C.fxnb_master)
		C.fxnb_master = new()
		C.screen += C.fxnb_master
	if(!C.fxnb_relay)
		C.fxnb_relay = new()
		C.screen += C.fxnb_relay
	FxApplyLightBlur(C)
	FxApplyRelayBlend(C)
	FxApplyBloom(C)

//classic = ADD the blurred lights; multiply-reveal = MULTIPLY the merged *fxbase
proc/FxApplyRelayBlend(client/C)
	if(!C || !C.fxlight_relay) return
	if(glob && glob.MULTIPLY_REVEAL)
		C.fxlight_relay.blend_mode = BLEND_MULTIPLY
		C.fxlight_relay.render_source = "*fxbase"
	else
		C.fxlight_relay.blend_mode = BLEND_ADD
		C.fxlight_relay.render_source = "*fxlight"

//gate the lighting blur behind LIGHTING so idle clients don't pay a per-frame blur pass
proc/FxApplyLightBlur(client/C)
	if(!C || !C.fxlight_master) return
	if(glob && glob.LIGHTING && GfxQualityRank(C) >= GFX_QUALITY_MEDIUM)
		var/blur = GfxQualityRank(C) >= GFX_QUALITY_HIGH ? glob.LIGHT_BLUR : max(2, round(glob.LIGHT_BLUR * 0.5))
		C.fxlight_master.filters = filter(type = "blur", size = blur) //smooths blocky per-tile lighting
	else
		C.fxlight_master.filters = null
	CpmApply(C)

/mob/Admin2/verb/Bloom_Toggle()
	set category = "Admin"
	set name = "Bloom Toggle"
	glob.BLOOM = !glob.BLOOM
	for(var/client/C)
		if(C.fxplane_master) FxApplyBloom(C)
	src << "Bloom: [glob.BLOOM ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set bloom to [glob.BLOOM].")

/mob/Admin2/verb/Lights_Toggle()
	set category = "Admin"
	set name = "Lights Toggle"
	glob.DYNAMIC_LIGHTS = !glob.DYNAMIC_LIGHTS
	src << "Dynamic lights: [glob.DYNAMIC_LIGHTS ? "ON" : "OFF"] (applies to new casts)."
	Log("Admin", "[ExtractInfo(src)] set dynamic lights to [glob.DYNAMIC_LIGHTS].")

/mob/Admin2/verb/Occluded_Blasts_Toggle()
	set category = "Admin"
	set name = "Occluded Blasts Toggle"
	glob.OCCLUDED_BLASTS = !glob.OCCLUDED_BLASTS
	src << "Occluded blast lights: [glob.OCCLUDED_BLASTS ? "ON" : "OFF"] (needs Lighting on; applies to new casts)."
	Log("Admin", "[ExtractInfo(src)] set occluded blasts to [glob.OCCLUDED_BLASTS].")

/mob/Admin2/verb/Distort_Toggle()
	set category = "Admin"
	set name = "Distort Toggle"
	glob.SCREEN_DISTORT = !glob.SCREEN_DISTORT
	for(var/client/C)
		CpmApply(C)
	src << "Screen distortion: [glob.SCREEN_DISTORT ? "ON" : "OFF"]."
	Log("Admin", "[ExtractInfo(src)] set screen distortion to [glob.SCREEN_DISTORT].")
