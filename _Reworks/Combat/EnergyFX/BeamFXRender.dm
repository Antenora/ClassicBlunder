/obj/energyfx/var/tmp/fx_bx = 0
/obj/energyfx/var/tmp/fx_by = 0

/datum/beamfx/var/log_tag = ""

proc/BeamFXXform(list/sp, bx, by)
	var/a = sp[BFX_ANG]
	var/p = sp[BFX_PRE]
	var/ca = cos(a)
	var/sa = sin(a)
	var/cp = cos(p)
	var/spp = sin(p)
	var/sx = sp[BFX_SX]
	var/sy = sp[BFX_SY]
	return matrix(ca * sx * cp - sa * sy * spp, -ca * sx * spp - sa * sy * cp, sp[BFX_X] - bx, sa * sx * cp + ca * sy * spp, -sa * sx * spp + ca * sy * cp, sp[BFX_Y] - by)

proc/EnergyFXPlace(obj/energyfx/O, x, y, zz)
	if(O.fx_car) return 0
	var/tx = floor(x / 32) + 1
	var/ty = floor(y / 32) + 1
	if(tx < 1 || ty < 1 || tx > world.maxx || ty > world.maxy) return 0
	var/turf/T = locate(tx, ty, zz)
	if(!T) return 0
	O.loc = T
	O.step_x = 0
	O.step_y = 0
	O.fx_bx = (tx - 1) * 32 + O.fx_w / 2
	O.fx_by = (ty - 1) * 32 + O.fx_h / 2
	return 1

proc/BeamFXCool(a)
	return 0.3 + 0.7 * (clamp(a, 0, 1) ** 0.8)

var/list/BEAMFX_HIDDEN = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

proc/BeamFXFoldA(list/c, al)
	if(al >= 255) return c
	var/a = max(0, al) / 255
	var/list/m = c.Copy()
	m[4] *= a
	m[8] *= a
	m[12] *= a
	m[16] *= a
	m[20] *= a
	return m

/datum/beamfx/proc/StateOf(list/sp)
	return

/datum/beamfx/proc/ColorOf(list/sp)
	return

/datum/beamfx/proc/AlphaOf(list/sp)
	return

/datum/beamfx/proc/NewObj(list/sp, pr = 0)
	return

/datum/bfx_slot/var/dv = -1
/datum/bfx_slot/var/shown = 0

/datum/beamfx/proc/SlotStep(datum/bfx_slot/SL, w, started, delay_first, hold_pre)
	var/obj/energyfx/O = SL.obj
	if(started && hold_pre > 0) animate(transform = BeamFXXform(SL.last, O.fx_bx, O.fx_by), time = hold_pre)
	if(w == "hide")
		if(!started) animate(O, color = BEAMFX_HIDDEN, time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN)
		else animate(color = BEAMFX_HIDDEN, time = 0.25, easing = JUMP_EASING | EASE_IN)
		SL.shown = 0
	else
		var/list/sp = w
		var/st = StateOf(sp)
		if(!started) animate(O, transform = BeamFXXform(sp, O.fx_bx, O.fx_by), color = BeamFXFoldA(ColorOf(sp), AlphaOf(sp)), icon_state = st, time = 0.25, delay = delay_first, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		else animate(transform = BeamFXXform(sp, O.fx_bx, O.fx_by), color = BeamFXFoldA(ColorOf(sp), AlphaOf(sp)), icon_state = st, time = 0.25, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
		SL.st = st
		SL.last = sp
		SL.shown = 1
	energyfx_anim_n++

/datum/beamfx/proc/Realize()
	var/list/F1 = frame_specs[1]
	var/list/F2 = frame_specs[2]
	var/f1 = 2 * k
	var/list/hl = Holds()
	var/v1 = Q(f1, hl)
	var/v2 = Q(f1 + 1, hl)
	if(logging) world.log << "BFXQ[log_tag] [f1] [v1] [v2]"
	var/list/keys = list()
	for(var/key in F1) keys[key] = 1
	for(var/key in F2) keys[key] = 1
	for(var/key in slots) keys[key] = 1
	for(var/key in keys)
		var/list/s1 = F1[key]
		var/list/s2 = F2[key]
		var/list/first = s1 ? s1 : s2
		if(first && first[BFX_PR] < 0) continue
		var/datum/bfx_slot/SL = slots[key]
		var/list/want = list()
		for(var/si = 1 to 2)
			var/v = (si == 1) ? v1 : v2
			if(si == 2 && v2 == v1)
				want += list(null)
			else if(v < f1)
				want += list((SL && SL.dv == v) ? null : "hide")
			else
				var/list/sp = (v == f1) ? s1 : s2
				want += list(sp ? sp : "hide")
		if(!SL)
			var/list/fs
			for(var/w in want)
				if(islist(w))
					fs = w
					break
			if(!fs) continue
			var/obj/energyfx/NO = NewObj(fs, fs[BFX_PR])
			if(!NO) continue
			SL = new
			SL.obj = NO
			SL.fam = fs[BFX_FAM]
			SL.light = fs[BFX_LIGHT]
			SL.st = NO.icon_state
			SL.last = fs
			SL.pr = fs[BFX_PR]
			slots[key] = SL
		var/obj/energyfx/O = SL.obj
		if(first && O.layer != first[BFX_ZL]) O.layer = first[BFX_ZL]
		for(var/si = 1 to 2)
			if(want[si] == "hide" && !SL.shown) want[si] = null
		var/started = 0
		var/list/ref
		for(var/w in want)
			if(islist(w))
				var/list/ws = w
				if(abs(ws[BFX_X] - O.fx_bx) > 48 || abs(ws[BFX_Y] - O.fx_by) > 48) ref = ws
		if(ref && EnergyFXPlace(O, ref[BFX_X], ref[BFX_Y], z))
			animate(O, transform = BeamFXXform(SL.last, O.fx_bx, O.fx_by), time = 0, flags = ANIMATION_END_NOW)
			started = 1
			energyfx_anim_n++
		var/skip1 = isnull(want[1])
		if(!skip1)
			SlotStep(SL, want[1], started, 0, 0)
			started = 1
		if(!isnull(want[2]))
			SlotStep(SL, want[2], started, skip1 ? 0.25 : 0, (started && skip1) ? 0.25 : 0)
			started = 1
		SL.dv = v2
		if(!s1 && !s2 && !SL.shown)
			SL.idle++
			if(SL.idle >= 3)
				EnergyFXFree(SL.obj)
				slots -= key
		else
			SL.idle = 0

/datum/beamfx/proc/Step()
	k++
	Tick(k)
	frame_specs = list(list(), list())
	for(var/j = 1 to 2)
		var/fi = 2 * k + (j - 1)
		if(logging) flog = list()
		Frame(fi, j)
		if(logging) LogFrame(fi)
	Realize()
	CharsTick()
	frame_specs = null

/datum/beamfx/proc/LogFrame(fi)
	world.log << "BFXF[log_tag] [fi] [flog.len]"
	for(var/list/sp in flog)
		world.log << "BFXS[log_tag] [sp[BFX_FAM]]|[sp[BFX_ST]]|[sp[BFX_LIGHT]]|[num2text(sp[BFX_X], 9)]|[num2text(sp[BFX_Y], 9)]|[num2text(sp[BFX_ANG], 9)]|[num2text(sp[BFX_SX], 9)]|[num2text(sp[BFX_SY], 9)]|[num2text(sp[BFX_PRE], 9)]|[num2text(sp[BFX_ALPHA], 9)]|[num2text(sp[BFX_LAYER], 9)]|[sp[BFX_ORDER]]|[sp[BFX_TAG]]|[num2text(sp[BFX_FADE], 9)]|[sp[BFX_SEED]][(sp.len >= BFX_CAR && sp[BFX_CAR]) ? "|[sp[BFX_CAR]]" : ""]"

/datum/beamfx/proc/Busy()
	if(objs.len) return 1
	for(var/key in slots)
		var/datum/bfx_slot/SL = slots[key]
		if(SL && SL.idle < 3) return 1
	return 0

/datum/beamfx/proc/Cleanup()
	CharsDrop()
	for(var/key in slots)
		var/datum/bfx_slot/SL = slots[key]
		if(SL) EnergyFXFree(SL.obj)
	slots = list()
	objs = list()
	finished = 1
