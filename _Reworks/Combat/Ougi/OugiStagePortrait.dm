/datum/ougi_scene/DoOp(op, list/a)
	if(op == "portrait") return OpPortrait(a)
	return ..()

proc/OugiPortraitCrop(icon/I, list/box)
	if(!I || !islist(box) || box.len < 4) return I
	for(var/v in box)
		if(!isnum(v)) return I
	var/w = I.Width()
	var/h = I.Height()
	if(!w || !h) return I
	var/x1 = clamp(round(min(box[1], box[3]), 1), 0, w - 1)
	var/x2 = clamp(round(max(box[1], box[3]), 1), 0, w - 1)
	var/y1 = clamp(round(min(box[2], box[4]), 1), 0, h - 1)
	var/y2 = clamp(round(max(box[2], box[4]), 1), 0, h - 1)
	if(x1 > 0) I.DrawBox(null, 1, 1, x1, h)
	if(x2 < w - 1) I.DrawBox(null, x2 + 2, 1, w, h)
	if(y1 > 0) I.DrawBox(null, x1 + 1, 1, x2 + 1, y1)
	if(y2 < h - 1) I.DrawBox(null, x1 + 1, y2 + 2, x2 + 1, h)
	return I

proc/OugiPortraitIcon(mob/M, state, list/crop)
	if(!M) return null
	var/st = istext(state) ? M.PortraitCanon(state) : null
	if(!istext(st)) st = M.PortraitState()
	var/ic = M.GetPortraitState(st)
	if(!islist(crop)) return ic
	return OugiPortraitCrop(icon(ic), crop)

/datum/ougi_scene/proc/OpPortrait(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	var/ic = OugiPortraitIcon(M, ArgText(a, "state", null), ArgText(a, "crop", null))
	if(!ic) return
	var/life = ArgNum(a, "life", 10)
	var/obj/Effects/OugiFX/F = OpFX(list("at" = ArgText(a, "at", "camera"), "icon" = ic, "state" = "", "x" = ArgNum(a, "x", 0), "y" = ArgNum(a, "y", 0), "life" = life, "under" = ArgNum(a, "under", 1)))
	if(!F) return
	var/s = ArgNum(a, "scale", 1)
	var/g = ArgNum(a, "angle", 0)
	if(s != 1 || g)
		var/matrix/T = matrix()
		T.Scale(s)
		if(g) T.Turn(g)
		F.transform = T
	OugiPortraitSlide(F, Ds(life), Ds(ArgNum(a, "in", 0)), Ds(ArgNum(a, "out", 0)), ArgNum(a, "slide_dx", 0), ArgNum(a, "slide_dy", 0))
	return F

/datum/ougi_scene/proc/OugiPortraitSlide(obj/F, life, ti, tout, sx, sy)
	ti = clamp(ti, 0, life)
	tout = clamp(tout, 0, life - ti)
	if((!sx && !sy) || (ti <= 0 && tout <= 0)) return
	var/rx = F.pixel_x
	var/ry = F.pixel_y
	if(ti > 0)
		F.pixel_x = rx + sx
		F.pixel_y = ry + sy
		animate(F, pixel_x = rx, pixel_y = ry, time = ti, easing = SINE_EASING)
	if(tout <= 0) return
	if(ti > 0) animate(pixel_x = rx, pixel_y = ry, time = life - ti - tout)
	else animate(F, pixel_x = rx, pixel_y = ry, time = life - tout)
	animate(pixel_x = rx + sx, pixel_y = ry + sy, time = tout, easing = SINE_EASING)
