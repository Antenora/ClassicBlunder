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
	plane = 1 //bloomed effects plane
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
var/icon/_fx_ring_icon
var/icon/_fx_heat_icon
var/list/_fx_lit_paths = list()
var/_fx_boot = _FxBoot()

proc/_FxBoot()
	spawn(40)
		_FxBuildIcons()
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

//anchor a 64px vis_contents child on the art's true center - big skills carry pixel_x like -158 and a naive child inherits it and lands off-screen
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

proc/FxLightTurf(datum/fx_light/L)
	if(L.fixed) return L.fixed
	return L.src_atom ? get_turf(L.src_atom) : null

proc/FxPruneLights()
	for(var/datum/fx_light/L in _fx_lights.Copy())
		if(L.expire)
			if(world.time >= L.expire) _fx_lights -= L
		else if(!L.src_atom || !L.src_atom.loc) //moving source deleted, or off-map/dying (endLife nulls loc before its sleep)
			_fx_lights -= L

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
proc/FxLightPulse(turf/T, size = 1.5, col = null)
	if(!glob || !glob.DYNAMIC_LIGHTS || !_fx_glow_icon || !T) return
	var/frac = LightRenderStrength(T)
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
	if(C.cpm_blur_size > 0)
		fl += filter(type="blur", size=C.cpm_blur_size)
	if(glob && glob.SCREEN_DISTORT && GfxDistortEnabled(C))
		fl += filter(type="displace", size=glob.DISTORT_SIZE, render_source="*fxdisp")
	C.client_plane_master.filters = fl.len ? fl : null
	FxApplyBloom(C) //keep the effects-plane blur mirror in sync

//bloom + a mirror of the fullscreen blur - the effects plane escapes client_plane_master
proc/FxApplyBloom(client/C)
	if(!C || !C.fxplane_master) return
	var/list/fl = list()
	if(glob && glob.BLOOM && GfxBloomEnabled(C))
		var/t = clamp(glob.BLOOM_THRESHOLD + C.gfx_env_bloom_bias, 96, 245)
		var/bs = GfxQualityRank(C) >= GFX_QUALITY_HIGH ? glob.BLOOM_SIZE : max(2, round(glob.BLOOM_SIZE * 0.55))
		fl += filter(type="bloom", threshold=rgb(t,t,t), size=bs)
	if(C.cpm_blur_size > 0)
		fl += filter(type="blur", size=C.cpm_blur_size)
	C.fxplane_master.filters = fl.len ? fl : null

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
