var/list/EFXPB_WSIG = list()
var/list/EFXPB_WICON = list()
var/efxpb_fc = 0
var/efxpb_births = 0
var/efxpb_chains = 0
var/efxpb_anim = 0
var/efxpb_made = 0

/obj/energyfx/var/tmp/efxpb_at = -1

/datum/energyfx_orbs/var/tmp/list/efxpb_objs

/datum/energyfx_orbs/proc/PBValid(obj/energyfx/O)
	return O && O.loc && O.efxpb_at >= 0 && O.fx_free < O.efxpb_at

/datum/energyfx_orbs/proc/PBTrack(obj/energyfx/O)
	if(!efxpb_objs) efxpb_objs = list()
	efxpb_objs += O

/datum/energyfx_orbs/proc/PBFreeAll()
	for(var/obj/energyfx/O in efxpb_objs)
		if(PBValid(O)) EFXOFree(O)
	efxpb_objs = null

/datum/energyfx_orbs/Cleanup()
	..()
	PBFreeAll()

/datum/energyfx_orbs/proc/PBObj(list/r, list/ic)
	var/obj/energyfx/O = EnergyFXGet(EFXO_PATHS[r[EO_KIND]], row ? row.path : "orb")
	if(!O) return null
	O.icon = ic[1]
	O.fx_w = ic[2]
	O.fx_h = ic[3]
	O.alpha = 0
	O.efxo_kf = null
	if(!EnergyFXPlace(O, r[EO_X], r[EO_Y], zz))
		EFXOFree(O)
		return null
	O.layer = r[EO_LAY]
	O.efxpb_at = EnergyFXNow()
	PBTrack(O)
	efxpb_made++
	return O

/datum/energyfx_orbs/proc/PBFlip(obj/energyfx/O, list/r, list/ic, st, n, kfree)
	animate(O, transform = Xform(O, r), alpha = 255, color = r[EO_COL] ? r[EO_COL] : EFXO_ID, icon = ic[1], icon_state = st, time = 0.25 * n, easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
	animate(alpha = 0, color = BEAMFX_HIDDEN, time = 0.25, easing = JUMP_EASING | EASE_IN)
	efxpb_anim += 2
	Keep(ic[1], st, O)
	EnergyFXDue(O, kfree - Now())

/datum/energyfx_orbs/proc/PBChain(obj/energyfx/O, list/r, list/sts, f0, kfree)
	var/matrix/m = Xform(O, r)
	var/c = r[EO_COL] ? r[EO_COL] : EFXO_ID
	var/list/steps = list()
	var/k0 = floor(f0 / 2)
	for(var/k = k0, k < kfree, k++)
		var/s0 = (2 * k - f0 >= 0 && 2 * k - f0 < sts.len) ? sts[2 * k - f0 + 1] : null
		var/s1 = (2 * k + 1 - f0 >= 0 && 2 * k + 1 - f0 < sts.len) ? sts[2 * k + 1 - f0 + 1] : null
		if(!s0 && !s1)
			steps[++steps.len] = list(null, 0, 0.5)
			continue
		var/sa = s0 ? s0 : s1
		var/sb = s1 ? s1 : s0
		var/list/A = list(sa, s0 ? 255 : 0, 0.25)
		var/list/B = list(sb, s1 ? 255 : 0, 0.25)
		if(A[1] == B[1] && A[2] == B[2])
			A[3] = 0.5
			steps[++steps.len] = A
		else
			steps[++steps.len] = A
			steps[++steps.len] = B
	steps[++steps.len] = list(null, 0, 0.5)
	var/list/merged = list()
	for(var/list/s in steps)
		if(merged.len && merged[merged.len][1] == s[1] && merged[merged.len][2] == s[2]) merged[merged.len][3] += s[3]
		else merged[++merged.len] = s
	var/first = 1
	for(var/list/s in merged)
		if(!s[1])
			if(first) animate(O, alpha = 0, color = BEAMFX_HIDDEN, time = s[3], easing = JUMP_EASING | EASE_IN)
			else animate(alpha = 0, color = BEAMFX_HIDDEN, time = s[3], easing = JUMP_EASING | EASE_IN)
		else
			var/list/ic = ENERGYFX_ORB_ICONS[r[EO_IK]]
			if(!ic) ic = ENERGYFX_ORB_ICONS["[r[EO_IK]]:[s[1]]"]
			var/f = ic ? ic[1] : O.icon
			if(first) animate(O, transform = m, alpha = s[2], color = c, icon = f, icon_state = s[1], time = s[3], easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			else animate(transform = m, alpha = s[2], color = c, icon = f, icon_state = s[1], time = s[3], easing = JUMP_EASING | EASE_IN, flags = ANIMATION_LINEAR_TRANSFORM)
			Keep(f, s[1], O)
		first = 0
		efxpb_anim++
	efxpb_chains++
	EnergyFXDue(O, kfree - Now())

proc/PBSplit(st)
	var/c = copytext(st, length(st))
	if(c == "b" || c == "l")
		return list(copytext(st, 1, findlasttext(st, "_")), c)
	var/u2 = findlasttext(st, "_")
	var/u1 = findlasttext(st, "_", u2 - 1)
	return list(copytext(st, 1, u1), copytext(st, u2))

/datum/energyfx_blasts/proc/PBWakeRow(datum/energyfx_blastshot/sh)
	return sh.R("row") == "Crash_Burst"

/datum/energyfx_blasts/proc/PBWakeFrames(datum/energyfx_blastshot/sh, list/o, f0)
	var/list/fr = list()
	var/ik = (sh.R("beam") == "godot") ? "BLMkBody" : WakeKey(sh)
	var/nw = EFXB_ART["[ik]:nw"]
	var/life = o["life"]
	var/t0 = o["t0"]
	var/cut = life - 0.0000001
	var/wb = sh.R("wake_kind") == "wavebody"
	var/dk = sh.R("drain_k", 1.5)
	var/th = sh.t_hit
	var/ih = isnull(th) ? null : EFXBFidx(th)
	var/list/hl = ShotHolds(sh)
	var/seen = 0
	for(var/fi = f0, fi < f0 + 400, fi++)
		var/v = fi - (fi % 2)
		if(!isnull(ih) && ih <= fi && fi < ih + 5) v = fi
		for(var/list/h in hl)
			if(h[1] <= fi && fi < h[1] + h[2]) v = h[1]
		var/t = EFXBFtime(v)
		if(wb)
			var/tw = EFXBFtime(fi - (fi % 2))
			if(isnull(th) || tw <= th + 0.0000001) tw = t
			var/aw = tw - t0
			if(!isnull(th) && tw > th + 0.0000001) aw += dk * (tw - th)
			if(aw >= cut || aw < 0)
				if(seen || aw >= cut) break
				fr += null
				continue
			seen = 1
			fr += min(nw - 1, EFXBIntT(aw / life * (nw - 1)))
			continue
		var/age = t - t0
		if(age < 0)
			if(seen) break
			fr += null
			continue
		if(age >= cut) break
		seen = 1
		fr += min(nw - 1, EFXORoundHalfEven(age / life * (nw - 1)))
	return fr

/datum/energyfx_blasts/proc/PBWakeRecs(datum/energyfx_blastshot/sh, list/o, fi)
	var/list/out = list()
	var/vq = Qs(sh, fi)
	var/tw = sh.t_twos
	sh.t_twos = EFXBFtime(fi - (fi % 2))
	efxpb_fc++
	ObjRec(out, sh, o, EFXBFtime(vq), vq)
	efxpb_fc--
	sh.t_twos = tw
	return out

/datum/energyfx_blasts/proc/PBWakeIssue(datum/energyfx_blastshot/sh, list/o, k, reissue)
	var/f0 = 2 * k
	var/list/fr = PBWakeFrames(sh, o, f0)
	var/fx = 0
	while(fx < fr.len && isnull(fr[fx + 1])) fx++
	var/list/old = o["pbo"]
	if(fx >= fr.len)
		for(var/obj/energyfx/Q in old)
			if(PBValid(Q)) EFXOFree(Q)
		o["pbo"] = null
		return
	var/list/recs = PBWakeRecs(sh, o, f0 + fx)
	var/kfree = floor((f0 + fr.len - 1) / 2) + 1
	var/sig = fx ? null : jointext(fr, ",")
	var/list/objs = list()
	for(var/j = 1 to recs.len)
		var/list/r = recs[j]
		var/list/ps = PBSplit(r[EO_ST])
		var/pre = ps[1]
		var/L = ps[2]
		var/st = r[EO_ST]
		var/list/m = sig ? EFXPB_WSIG["[r[EO_IK]]|[sig]"] : null
		var/obj/energyfx/O = (old && j <= old.len) ? old[j] : null
		if(O && !PBValid(O)) O = null
		if(m && !reissue && !fx)
			var/fst = "[pre]_c[m[1]][L]"
			var/list/ic = EFXPB_WICON["[r[EO_IK]]|[fst]"]
			if(ic)
				if(!O) O = PBObj(r, ic)
				if(O)
					PBFlip(O, r, ic, fst, fr.len, kfree)
					objs += O
				continue
		var/list/ic2 = ENERGYFX_ORB_ICONS[r[EO_IK]]
		if(!ic2) ic2 = ENERGYFX_ORB_ICONS["[r[EO_IK]]:[st]"]
		if(!ic2) continue
		if(!O) O = PBObj(r, ic2)
		if(!O) continue
		var/list/sts = list()
		for(var/i = 1 to fr.len)
			sts += isnull(fr[i]) ? null : "[pre]_[fr[i]][L]"
		PBChain(O, r, sts, f0, kfree)
		objs += O
	if(old)
		for(var/obj/energyfx/Q in old)
			if(!(Q in objs) && PBValid(Q)) EFXOFree(Q)
	o["pbo"] = objs
	o["pbp"] = sh.t_pred
	o["pbt"] = sh.t_hit
	efxpb_births++

/datum/energyfx_blasts/ObjRec(list/out, datum/energyfx_blastshot/sh, list/o, t, v)
	if(efxpb_fc) return ..()
	var/d = o["pbd"]
	if(!d)
		if(replay || o["kind"] != "wake" || !PBWakeRow(sh))
			o["pbd"] = -1
			return ..()
		o["pbd"] = (sh.R("wake_kind") == "wavebody") ? 2 : 1
		o["pbk"] = last_k
		PBWakeIssue(sh, o, last_k, 0)
		d = o["pbd"]
	else if(d < 0)
		return ..()
	else if(o["pbk"] != last_k)
		o["pbk"] = last_k
		if(o["pbo"] && (o["pbp"] != sh.t_pred || o["pbt"] != sh.t_hit)) PBWakeIssue(sh, o, last_k, 1)
	var/age = t - o["t0"]
	if(age < 0 || d == 2) return 1
	return age < o["life"] - 0.0000001
