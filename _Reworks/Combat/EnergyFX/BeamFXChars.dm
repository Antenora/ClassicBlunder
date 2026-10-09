#define BEAMFX_RIMW_PLANE 30
#define BEAMFX_RIMA_PLANE 31

globalTracker/var/tmp
	BEAMFX_CHARS = TRUE
	BEAMFX_RIM_BLUR = 0.5

var/beamfx_char_n = 0
var/list/beamfx_masks = list()

proc/BeamFXMaskIcon(st)
	var/icon/I = beamfx_masks[st]
	if(!I)
		I = icon(BEAMFX_MASK_ICON, st)
		beamfx_masks[st] = I
	return I
var/list/beamfx_icon_size = list()

/obj/beamfx_char
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1

/obj/energyfx_master/rimw
	plane = BEAMFX_RIMW_PLANE
	render_target = "*energyfx_rimw"

/obj/energyfx_master/rima
	plane = BEAMFX_RIMA_PLANE
	render_target = "*energyfx_rima"

/obj/energyfx_relay/rimw
	layer = BEAMFX_RIM_LAYER
	render_source = "*energyfx_rimw"
	color = list(0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

/obj/energyfx_relay/rima
	layer = BEAMFX_RIM_LAYER + 0.001
	blend_mode = BLEND_ADD
	render_source = "*energyfx_rima"

/datum/bfx_char
	var/mob/M
	var/role = 0
	var/id
	var/obj/beamfx_char/sil
	var/obj/beamfx_char/occ
	var/obj/beamfx_char/locc
	var/obj/beamfx_char/dark
	var/list/rims = list()
	var/app
	var/fkey

/datum/beamfx/var/datum/bfx_char/cfx_caster
/datum/beamfx/var/datum/bfx_char/cfx_target

proc/BeamFXIconSize(mob/M)
	var/key = "[M.icon]"
	var/list/s = beamfx_icon_size[key]
	if(!s)
		var/w = world.icon_size
		var/h = world.icon_size
		if(M.icon)
			var/icon/I = new(M.icon)
			w = I.Width()
			h = I.Height()
		s = list(w, h)
		if(beamfx_icon_size.len < 512) beamfx_icon_size[key] = s
	return s

proc/BeamFXImageCenter(mob/M)
	var/list/s = BeamFXIconSize(M)
	return list((M.x - 1) * 32 + M.step_x + M.pixel_x + M.pixel_w + s[1] / 2, (M.y - 1) * 32 + M.step_y + M.pixel_y + M.pixel_z + s[2] / 2)

/datum/bfx_char/New(mob/m, r)
	M = m
	role = r
	beamfx_char_n++
	id = "bfxs[beamfx_char_n]"
	sil = new
	occ = new
	locc = new
	var/nparts = (role == 1) ? 2 : 3
	for(var/i = 1 to nparts * 2)
		rims += new /obj/beamfx_char
	if(role == 2) dark = new
	for(var/obj/O in Objs()) M.vis_contents += O

/datum/bfx_char/proc/Objs()
	var/list/L = list(sil, occ, locc)
	L += rims
	if(dark) L += dark
	return L

/datum/bfx_char/proc/Drop()
	for(var/obj/O in Objs())
		if(M) M.vis_contents -= O
		animate(O)
		O.filters = null
		O.loc = null
	M = null

proc/BeamFXCopyApp(obj/O, mob/M, pl, lay, flags)
	O.appearance = M.appearance
	O.plane = pl
	O.layer = lay
	O.appearance_flags = flags
	O.pixel_x = 0
	O.pixel_y = 0
	O.pixel_w = 0
	O.pixel_z = 0
	O.color = null
	O.alpha = 255
	O.filters = null
	O.mouse_opacity = 0
	O.render_target = null
	O.render_source = null

proc/BeamFXRimBuild(mob/M, sil_rt, dx, dy, list/col, level, keep, nparts, list/palm, list/parts, icon/palm_icon)
	if(!parts) parts = list()
	while(parts.len < nparts * 2) parts += new /obj/beamfx_char
	var/apart = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	var/rb = glob ? glob.BEAMFX_RIM_BLUR : 0.5
	for(var/i = 1 to nparts * 2)
		var/obj/beamfx_char/R = parts[i]
		var/part = ((i - 1) % nparts) + 1
		var/is_add = (i > nparts)
		var/wgt = (part == 1) ? 1 : 0.55
		BeamFXCopyApp(R, M, is_add ? BEAMFX_RIMA_PLANE : BEAMFX_RIMW_PLANE, 1, apart)
		R.blend_mode = BLEND_ADD
		var/list/f = list(filter(type = "alpha", render_source = sil_rt, x = dx * part, y = dy * part, flags = MASK_INVERSE))
		for(var/m = 1 to part - 1)
			f += filter(type = "alpha", render_source = sil_rt, x = dx * m, y = dy * m)
		if(rb > 0) f += filter(type = "blur", size = rb)
		f += filter(type = "alpha", render_source = sil_rt)
		if(palm) f += filter(type = "alpha", icon = palm_icon ? palm_icon : BeamFXMaskIcon("palmw"), x = palm[1], y = palm[2])
		if(is_add)
			var/c = 0.75 * wgt * level
			f += filter(type = "color", color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, col[1] * c, col[2] * c, col[3] * c, 0, 0, 0, 0, 1))
		else
			var/c2 = (1 - keep) * wgt * level
			f += filter(type = "color", color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, c2, c2, c2, 0, 0, 0, 0, 1))
		R.filters = f
		R.alpha = 0
	return parts

/datum/bfx_char/proc/Copy(obj/O, pl, lay, flags)
	BeamFXCopyApp(O, M, pl, lay, flags)

/datum/bfx_char/proc/Refresh(datum/beamfx/F, fkey2, list/above, list/spill, list/palm, list/tl)
	if(M.appearance == app && fkey2 == fkey) return
	app = M.appearance
	fkey = fkey2
	var/apart = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	Copy(sil, 0, FLOAT_LAYER, apart)
	sil.render_target = "*[id]"
	Copy(occ, ENERGYFX_OCC_PLANE, 1, apart)
	Copy(locc, ENERGYFX_LOCC_PLANE, 1, apart)
	var/list/fo = list()
	var/list/fl = list()
	if(above)
		fo += filter(type = "alpha", icon = BeamFXMaskIcon("above"), x = above[1], y = above[2])
		fl += filter(type = "alpha", icon = BeamFXMaskIcon("above"), x = above[1], y = above[2])
	if(spill)
		fl += filter(type = "alpha", icon = BeamFXMaskIcon("spill"), x = spill[1], y = spill[2], flags = MASK_INVERSE)
	occ.filters = fo.len ? fo : null
	locc.filters = fl.len ? fl : null
	if(dark)
		Copy(dark, FLOAT_PLANE, FLOAT_LAYER, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
		dark.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		dark.alpha = 0
	var/list/dv = BeamFXDirVec(F.d)
	var/sgn = (role == 1) ? -1 : 1
	BeamFXRimBuild(M, "*[id]", sgn * dv[1], sgn * dv[2], tl, 1.45, (role == 1) ? 0.3 : 0.35, rims.len / 2, palm, rims)

/datum/beamfx/proc/HitK(t, fi)
	if(isnull(t0) || isnull(t_hit) || t < t_hit) return 0
	var/kk = BeamFXEaseOut((t - t_hit) / 0.1)
	kk *= 0.9 + 0.1 * sin(360 * t / 0.11)
	if(!isnull(end_t) && t > end_t + 0.1)
		kk *= max(0, 1 - (t - end_t - 0.1) / 0.3)
	else if(!isnull(dead_t) && isnull(end_t) && t > dead_t)
		kk *= max(0, 1 - (t - dead_t) / 0.25)
	else if(!Struggling(fi, 0))
		return 0
	return kk

/datum/beamfx/proc/LitColor()
	var/list/lc = ramp[1]
	return list(clamp(lc[1] * 0.85 + 0.15, 0, 1), clamp(lc[2] * 0.85 + 0.15, 0, 1), clamp(lc[3] * 0.85 + 0.15, 0, 1))

/datum/beamfx/var/ch_c_until = -1
/datum/beamfx/var/ch_c_nsurge
/datum/beamfx/var/ch_c_rel = 0
/datum/beamfx/var/ch_t_state = 0

/datum/beamfx/proc/CasterRimX(t, xs)
	if(isnull(t0)) return 0
	if(!isnull(release_t) && t >= release_t + 0.14) return 0
	var/rampv = clamp((t - t0) / 0.06, 0, 1)
	if(!isnull(release_t) && t >= release_t) rampv *= max(0, 1 - (t - release_t) / 0.1)
	var/pk = 0
	for(var/ts in surge_emit)
		if(t - ts > -0.2 && t - ts < 0.3) pk = max(pk, (2.718281828 ** (-(((t - ts) / 0.07) ** 2))))
	if(!isnull(xs) && t - xs > -0.2 && t - xs < 0.3) pk = max(pk, (2.718281828 ** (-(((t - xs) / 0.07) ** 2))))
	return rampv * (1 + 0.45 * pk)

proc/BeamFXSortNums(list/L)
	var/list/R = L.Copy()
	for(var/i = 2 to R.len)
		var/v = R[i]
		var/j = i - 1
		while(j >= 1 && R[j] > v)
			R[j + 1] = R[j]
			j--
		R[j + 1] = v
	return R

/datum/beamfx/proc/ChainFrames(list/objs_, list/vals, loopv = 0)
	var/list/durs = list()
	var/list/vs = list()
	for(var/i = 1 to vals.len)
		var/v = round(vals[i], 1)
		if(vs.len && vs[vs.len] == v) durs[durs.len] += 0.25
		else
			vs += v
			durs += 0.25
	for(var/obj/O in objs_)
		for(var/i = 1 to vs.len)
			if(i == 1) animate(O, alpha = vs[i], time = durs[i], loop = loopv ? loopv : 1, easing = JUMP_EASING | EASE_IN)
			else animate(alpha = vs[i], time = durs[i], easing = JUMP_EASING | EASE_IN)
	energyfx_anim_n += vs.len * objs_.len
	return vs.len

/datum/beamfx/proc/CasterChain()
	var/xs = s_firing ? next_surge : null
	var/te = !isnull(release_t) ? (release_t + 0.14) : (isnull(xs) ? FT(2 * k) + 0.5 : xs + 0.3)
	var/list/hl = Holds()
	var/list/vals = list()
	var/f = 2 * k
	while(FT(f) <= te + 0.0001 && f - 2 * k < 80)
		vals += clamp(CasterRimX(FT(Q(f, hl)), xs) / 1.45, 0, 1) * 255
		f++
	if(!vals.len) return
	var/n = ChainFrames(cfx_caster.rims, vals)
	ch_c_until = te
	ch_c_nsurge = xs
	if(logging) world.log << "BFXR c [2 * k] [n] [vals.len]"

/datum/beamfx/proc/TargetW(t)
	var/kk = BeamFXEaseOut((t - t_hit) / 0.1) * (0.9 + 0.1 * sin(360 * t / 0.11))
	return list(clamp((0.72 + 0.1 * sin(360 * t / 0.33)) * kk / 1.45, 0, 1) * 255, min(1, 0.46 * kk) * 255)

/datum/beamfx/proc/TargetLoopStart()
	return isnull(rm_ih) ? ceil((t_hit + 0.1) / BEAMFX_FR) : rm_ih + 11

/datum/beamfx/proc/TargetChain(f_end, loopv)
	var/list/hl = Holds()
	var/list/rv = list()
	var/list/dv = list()
	var/f = 2 * k
	while(f < f_end && f - 2 * k < 80)
		var/list/w = TargetW(FT(Q(f, hl)))
		rv += w[1]
		dv += w[2]
		f++
	if(!rv.len) return
	ChainFrames(cfx_target.rims, rv, loopv)
	if(cfx_target.dark) ChainFrames(list(cfx_target.dark), dv, loopv)
	if(logging) world.log << "BFXR t [2 * k] [loopv] [rv.len]"

/datum/beamfx/proc/TargetFade()
	var/list/hl = Holds()
	var/list/rv = list()
	var/list/dv = list()
	for(var/i = 0 to 13)
		var/f = 2 * k + i
		var/t = FT(Q(f, hl))
		var/kk = HitK(t, ctx_f)
		rv += (kk > 0.001) ? clamp((0.72 + 0.1 * sin(360 * t / 0.33)) * kk / 1.45, 0, 1) * 255 : 0
		dv += min(1, 0.46 * kk) * 255
		if(kk <= 0.001) break
	ChainFrames(cfx_target.rims, rv)
	if(cfx_target.dark) ChainFrames(list(cfx_target.dark), dv)

/datum/beamfx/proc/CharsTick()
	if(!glob || !glob.BEAMFX_CHARS) return
	var/mob/C = (!no_bloom && caster_mob && caster_mob.loc && caster_mob.z == z) ? caster_mob : null
	var/mob/T = (target_mob && target_mob.loc && target_mob.z == z && target_mob != C && !(clash_mode && partner)) ? target_mob : null
	if(cfx_caster && cfx_caster.M != C)
		cfx_caster.Drop()
		cfx_caster = null
		ch_c_until = -1
	if(cfx_target && cfx_target.M != T)
		cfx_target.Drop()
		cfx_target = null
		ch_t_state = 0
	if(isnull(t0)) return
	var/list/tl = LitColor()
	if(C)
		var/fresh = 0
		if(!cfx_caster)
			cfx_caster = new(C, 1)
			fresh = 1
		var/list/cc = BeamFXImageCenter(C)
		var/list/above
		if(d in list("S", "SE", "SW"))
			above = list(0, round(WY(mz) - 2 - cc[2], 0.01))
		var/list/spill
		var/list/palm = list(round(WX(mz + 1) - cc[1], 0.01), round(WY(mz + 1) - cc[2], 0.01))
		if(!(d in list("N", "NE", "NW"))) spill = palm
		cfx_caster.Refresh(src, "[d]|[palm[1]]|[palm[2]]|[above ? above[2] : "x"]", above, spill, palm, tl)
		var/xs_now = s_firing ? next_surge : null
		var/rel_now = !isnull(release_t)
		if(fresh || FT(2 * k + 1) > ch_c_until - 0.0001 || xs_now != ch_c_nsurge || rel_now != ch_c_rel)
			ch_c_rel = rel_now
			if(FT(2 * k + 1) <= (rel_now ? release_t + 0.14 : 1000000000)) CasterChain()
	if(T)
		if(!cfx_target)
			cfx_target = new(T, 2)
			ch_t_state = 0
		cfx_target.Refresh(src, "[d]", null, null, null, tl)
		var/t2 = FT(2 * k + 1)
		var/st = TargetHeld(2 * k + 1)
		var/ending = TargetEnding(t2)
		if(ch_t_state <= 2 && !isnull(t_hit) && (ending || (!st && isnull(end_t) && isnull(dead_t))))
			if(ch_t_state > 0)
				if(ending) TargetFade()
				else
					for(var/obj/O in cfx_target.rims) animate(O, alpha = 0, time = 0.25)
					if(cfx_target.dark) animate(cfx_target.dark, alpha = 0, time = 0.25)
			ch_t_state = ending ? 3 : 0
		else if(ch_t_state == 0 && st && !isnull(t_hit) && t2 >= t_hit)
			TargetChain(TargetLoopStart(), 0)
			ch_t_state = 1
		else if(ch_t_state == 1 && 2 * k >= TargetLoopStart())
			TargetChain(2 * k + 40, -1)
			ch_t_state = 2

/datum/beamfx/proc/TargetHeld(f)
	return Struggling(f, 0)

/datum/beamfx/proc/TargetEnding(t2)
	return (!isnull(end_t) && t2 > end_t + 0.1) || (!isnull(dead_t) && isnull(end_t) && t2 > dead_t)

/datum/beamfx/proc/CharsDrop()
	if(cfx_caster) cfx_caster.Drop()
	if(cfx_target) cfx_target.Drop()
	cfx_caster = null
	cfx_target = null
