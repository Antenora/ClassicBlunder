/datum/beamfx/var/gray_v = 1
/datum/beamfx/var/datum/energyfx_colors/fx_colors
/datum/beamfx/var/datum/energyfx_row/fx_row

/datum/beam/FxEligible(obj/Skills/Projectile/Z)
	if(!Z || !glob || !glob.ENERGYFX || !BEAMFX_ASSETS) return 0
	var/datum/energyfx_row/R = EnergyFXRow(Z)
	return (R && R.look == "beam") ? 1 : 0

/datum/beam/FxStart(mob/M, obj/Skills/Projectile/Z)
	var/datum/energyfx_row/R = EnergyFXRow(Z)
	var/datum/energyfx_colors/C = EnergyFXSkillColors(Z, R)
	beamfx_seed++
	var/seed = (round(world.time, 1) * 7 + beamfx_seed * 131) % 30000
	var/datum/beamfx/F = new(BeamFXDirText(bdir), 0, 0, M.z, BeamFXWidth(src, Z), seed, C, null, null)
	F.fx_row = R
	F.beam = src
	F.owner = M
	F.caster_mob = M
	F.fx_name = (R && R.name) ? R.name : Z.name
	F.logging = glob ? glob.BEAMFX_LOG : 0
	if(steer)
		F.bent = 1
		F.SetDir(F.d)
	return F

/datum/beamfx/SetColor(list/C255, list/core255, list/glow255)
	if(!istype(C255, /datum/energyfx_colors))
		..()
		gray_v2 = (grey && ENERGYFX_GRAY_ASSETS) ? 1 : 0
		return
	var/datum/energyfx_colors/K = C255
	fx_colors = K
	grey = K.gray
	gray_v2 = (K.gray && ENERGYFX_GRAY_ASSETS) ? 1 : 0
	gray_v = K.gray ? K.bright : 1
	ramp = K.ramp

/datum/beamfx/ClashLum()
	if(grey) return max(0.05, ENERGYFX_GRAY_CLASH_LUM * gray_v)
	return ..()

var/list/ENERGYFX_GRAY_FAM = list(\
	"Stamp" = list(ENERGYFX_ART_GRAY_STAMP, ENERGYFX_ART_DAMP_STAMP),\
	"Bloom" = list(ENERGYFX_ART_GRAY_BLOOM, ENERGYFX_ART_DAMP_BLOOM),\
	"Head" = list(ENERGYFX_ART_GRAY_HEAD, ENERGYFX_ART_DAMP_HEAD),\
	"Impact" = list(ENERGYFX_ART_GRAY_IMPACT, ENERGYFX_ART_DAMP_IMPACT),\
	"End" = list(ENERGYFX_ART_GRAY_END, ENERGYFX_ART_DAMP_END),\
	"Surge" = list(ENERGYFX_ART_GRAY_SURGE, ENERGYFX_ART_DAMP_SURGE),\
	"Bead" = list(ENERGYFX_ART_GRAY_BEAD, null),\
	"Sheath" = list(ENERGYFX_ART_GRAY_SHEATH, null),\
	"Flash" = list(ENERGYFX_ART_GRAY_FLASH, null),\
	"Shard" = list(ENERGYFX_ART_GRAY_SHARD, ENERGYFX_ART_DAMP_SHARD),\
	"Lance" = list(ENERGYFX_ART_GRAY_LANCE, ENERGYFX_ART_DAMP_LANCE),\
	"Tongue" = list(ENERGYFX_ART_GRAY_TONGUE, ENERGYFX_ART_DAMP_TONGUE),\
	"Wedge" = list(ENERGYFX_ART_GRAY_WEDGE, ENERGYFX_ART_DAMP_WEDGE),\
	"Ring" = list(ENERGYFX_ART_GRAY_RING, ENERGYFX_ART_DAMP_RING),\
	"Arc" = list(ENERGYFX_ART_GRAY_ARC, ENERGYFX_ART_DAMP_ARC),\
	"Speck" = list(ENERGYFX_ART_GRAY_SPECK, ENERGYFX_ART_DAMP_SPECK),\
	"Curl" = list(ENERGYFX_ART_GRAY_CURL, ENERGYFX_ART_DAMP_CURL))

/obj/energyfx_twin
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	plane = ENERGYFX_DAMP_PLANE
	vis_flags = VIS_INHERIT_ICON_STATE

/obj/energyfx/var/tmp/obj/energyfx_twin/efx_damp

proc/EnergyFXGrayLightK(tag)
	switch(tag)
		if("flash") return ENERGYFX_GRAY_FLASH_K
		if("hl") return ENERGYFX_GRAY_HEAD_K
		if("wl") return ENERGYFX_GRAY_WL_K
	return 1

/datum/beamfx/var/gray_v2 = 0

/datum/beamfx/proc/GrayV2()
	return gray_v2

/datum/beamfx/proc/GrayLightMatrix(tag, k, pr)
	var/list/lc = ramp[1]
	var/list/lcore = ramp[4]
	var/ls = glob ? glob.ENERGYFX_LIGHT_SCALE : 1
	var/g = ENERGYFX_GRAY_LSCALE * gray_v / ls * EnergyFXGrayLightK(tag) * pr
	return list((lcore[1] - lc[1]) * k * g, (lcore[2] - lc[2]) * k * g, (lcore[3] - lc[3]) * k * g, 0, lc[1] * g, lc[2] * g, lc[3] * g, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)

/datum/beamfx/StateOf(list/sp)
	if(GrayV2() && sp[BFX_LIGHT]) return "k[sp[BFX_ST]]"
	return ..()

proc/EnergyFXGrayErodes(tag)
	return tag == "p" || tag == "ring" || tag == "ring_c" || tag == "arc"

proc/EnergyFXGrayErodeK(list/sp)
	var/fd = clamp(sp[BFX_FADE], 0, 1)
	var/base = (fd > 0.001) ? round(min(1, sp[BFX_ALPHA] / fd) * 255, 1) / 255 : 0
	var/tag = sp[BFX_TAG]
	if(tag == "p") return base * ENERGYFX_GRAY_PA
	if(tag == "ring_c") return base * ENERGYFX_GRAY_RINGC_A
	return base

/datum/beamfx/AlphaOf(list/sp)
	if(!GrayV2() || sp[BFX_LIGHT] || !EnergyFXGrayErodes(sp[BFX_TAG])) return ..()
	return clamp(min(1, EnergyFXGrayErodeK(sp)) * 255, 0, 255)

/datum/beamfx/ColorOf(list/sp)
	if(!GrayV2() || sp[BFX_LIGHT] || !EnergyFXGrayErodes(sp[BFX_TAG])) return ..()
	var/tag = sp[BFX_TAG]
	var/k = EnergyFXGrayErodeK(sp)
	var/fd = round(clamp(sp[BFX_FADE], 0, 1) * 255, 1) / 255
	var/ck = "e[tag]|[round(k * 255, 1)]|[round(fd * 255, 1)]"
	var/list/cached = col_cache[ck]
	if(cached) return cached
	var/t_ = 0.3 + (1 - fd) * 0.55 + ENERGYFX_ERODE_BAND * ENERGYFX_ERODE_A
	var/m = max(1, k) / (ENERGYFX_ERODE_BAND * ENERGYFX_ERODE_B)
	var/kv = gray_v
	if(tag == "ring") kv = gray_v * ENERGYFX_GRAY_RING_K
	else if(tag == "ring_c") kv = gray_v * ENERGYFX_GRAY_RINGC_K
	var/list/res = list(kv, kv, kv, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, m, 0, 0, 0, -t_ * m)
	if(col_cache.len < 1024)
		col_cache += ck
		col_cache[ck] = res
	return res

/datum/beamfx/ColorCalc(list/sp, a, fdv)
	if(!GrayV2()) return ..()
	var/tag = sp[BFX_TAG]
	var/v = gray_v
	if(sp[BFX_LIGHT])
		return GrayLightMatrix(tag, (tag == "accent" || tag == "wl") ? BeamFXCool(a) : 1, 1)
	return list(v, v, v, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)

/datum/beamfx/proc/GrayRoute(list/sp)
	var/list/gf = ENERGYFX_GRAY_FAM[sp[BFX_FAM]]
	if(!gf) return null
	var/tag = sp[BFX_TAG]
	if(sp[BFX_LIGHT]) return list(gf[1], ENERGYFX_GLIGHT_PLANE, BLEND_ADD, null)
	if(tag == "ring" || tag == "ring_c") return list(gf[1], ENERGYFX_GRING_PLANE, BLEND_ADD, null)
	return list(gf[1], ENERGYFX_PAINT_PLANE, BLEND_DEFAULT, gf[2])

/datum/beamfx/NewObj(list/sp, pr = 0)
	var/obj/energyfx/O = ..()
	if(!O || !GrayV2()) return O
	var/list/route = GrayRoute(sp)
	if(!route) return O
	O.icon = route[1]
	O.plane = route[2]
	O.blend_mode = route[3]
	if(route[4])
		if(!O.efx_damp) O.efx_damp = new
		O.efx_damp.icon = route[4]
		O.vis_contents += O.efx_damp
	return O

/datum/beamfx/LightOverlay(list/sp, pr)
	if(!GrayV2()) return ..()
	var/key = "g|[sp[BFX_FAM]]|[sp[BFX_ST]]|[round(pr, 0.0001)]"
	var/image/I = ovl_cache[key]
	if(!I)
		var/list/gf = ENERGYFX_GRAY_FAM[sp[BFX_FAM]]
		I = image(icon = gf[1], icon_state = "k[sp[BFX_ST]]")
		I.plane = ENERGYFX_GLIGHT_PLANE
		I.blend_mode = BLEND_ADD
		I.appearance_flags = RESET_COLOR
		I.color = GrayLightMatrix(sp[BFX_TAG], 1, pr)
		ovl_cache[key] = I
	return I

/datum/beamfx/SpeckIcon()
	if(GrayV2()) return ENERGYFX_ART_GRAY_SPECK
	return ..()

/datum/beamfx/SpeckColor()
	if(!GrayV2()) return ..()
	return list(gray_v, gray_v, gray_v, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)

var/list/energyfx_feint_masks = list()

proc/EnergyFXFeintMask(st)
	var/icon/I = energyfx_feint_masks[st]
	if(!I)
		I = icon(ENERGYFX_ART_FEINT_MASKS, st)
		energyfx_feint_masks[st] = I
	return I

/datum/beamfx/feint
	var/rem_t
	var/rem_x = 0
	var/rem_y = 0

/datum/beamfx/feint/proc/Phase(t)
	var/T = t - t0
	if(T < ENERGYFX_FEINT_POP) return -2
	if(T < ENERGYFX_FEINT_PEAK) return -1
	return floor((T - ENERGYFX_FEINT_PEAK) / ENERGYFX_FEINT_DT + 0.000001)

/datum/beamfx/feint/proc/LightK(t)
	if(isnull(t0) || t < t0) return 0
	var/i = Phase(t)
	return (i < ENERGYFX_FEINT_N) ? ENERGYFX_FEINT_LIGHT[i + 3] : 0

/datum/beamfx/feint/proc/FeintLit()
	var/list/lc = LitColor()
	return list(clamp(lc[1] * 1.2 + 0.1, 0, 1), clamp(lc[2] * 1.2 + 0.1, 0, 1), clamp(lc[3] * 1.2 + 0.1, 0, 1))

/datum/beamfx/feint/Tick(kk)
	var/qn = 2 * kk
	var/now = FT(qn)
	ctx_f = qn
	if(isnull(t0))
		t0 = now
		fi0 = qn
		var/x0 = WX(mz + 10)
		var/y0 = WY(mz + 10)
		for(var/list/fl in ENERGYFX_FEINT_FLECKS)
			for(var/n = 1 to fl[2])
				var/a0 = ang + fl[1] + rng.U(-9, 9)
				var/lance = (rng.R() < 0.55) ? 1 : 0
				var/sq = rng.RandRange(lance ? 4 : 5)
				var/datum/bfx_obj/o = Mk(lance ? "flance" : "fshard", t0 + ENERGYFX_FEINT_POP + rng.U(0, 0.03))
				o.ang = a0
				o.v = rng.U(170, 330)
				o.life = rng.U(0.15, 0.26)
				o.scale = rng.U(0.75, 1.15)
				o.seq = sq
				o.lat = (fl[1] > 0) ? 1 : -1
				o.x0 = x0
				o.y0 = y0
				objs += o
		rem_t = t0 + ENERGYFX_FEINT_POP
		rem_x = x0
		rem_y = y0
	if(!remnant_done && rem_t < now + BEAMFX_TICK - 0.000001)
		remnant_done = 1
		spk_shots += list(list("remnant", rem_t, rem_x, rem_y))

/datum/beamfx/feint/Frame(fi, j)
	var/t = FT(fi)
	if(isnull(t0) || t < t0) return
	ctx_f = fi
	var/i = Phase(t)
	if(i < ENERGYFX_FEINT_N)
		var/st = (i < 0) ? "in[BeamFXMod(floor((fi - fi0) / 2), BEAMFX_NF)]" : "ie[2 + i]"
		var/kk = (i == -2) ? ENERGYFX_FEINT_POP_SC : 1 - 0.05 * max(i, 0)
		var/sc = ENERGYFX_FEINT_SC * kk
		var/cx = WX(mz + ENERGYFX_FEINT_AT * sc)
		var/cy = WY(mz + ENERGYFX_FEINT_AT * sc)
		Emit(j, "fip", "Impact", st, 0, cx, cy, ang, sc, sc, 0, 1, 5, 0, "flame", 1, 0, 5)
		Emit(j, "fil", "Impact", st, 1, cx, cy, ang, sc, sc, 0, 1, 0, 0, "hl", 1, 0, 5)
		var/fa = ENERGYFX_FEINT_FLASH[i + 3]
		var/fx_ = WX(mz + 12 * kk)
		var/fy_ = WY(mz + 12 * kk)
		Emit(j, "ffa", "Flash", "fl0", 1, fx_, fy_, ang, 1.05 * kk, 1.05 * kk, 0, fa, 0, 0, "flash", 1, 0, 6)
		Emit(j, "ffb", "Flash", "fl0", 1, fx_, fy_, ang, 0.6 * kk, 0.6 * kk, 0, fa, 0, 0, "flash", 1, 0, 6)
	var/list/alive = list()
	for(var/datum/bfx_obj/o in objs)
		var/age = t - o.t0
		if(age < 0)
			alive += o
			continue
		if(age >= o.life) continue
		alive += o
		ParticleFrame(o, fi)
	objs = alive

/datum/beamfx/feint/FrameAdvance(fi)
	return

/datum/beamfx/feint/ParticleSpec(datum/bfx_obj/o, t)
	if(o.kind != "fshard" && o.kind != "flance") return ..()
	var/age = t - o.t0
	var/q = age / o.life
	var/dist = o.v * (age - 0.9 * age * age / o.life * 0.5)
	var/sp = o.v * max(0, 1 - 0.9 * q)
	var/is_shard = (o.kind == "fshard")
	var/st_ = o.scale * (0.55 + sp / (is_shard ? 300 : 520)) * (1 - 0.4 * BeamFXSstep(0.5, 1, q))
	var/thin = 1 - 0.75 * BeamFXSstep(0.3, 1, q)
	var/al = min(1, age / 0.02) * (1 - BeamFXSstep(0.8, 1, q))
	var/x = o.x0 + cos(o.ang) * dist
	var/y = o.y0 + sin(o.ang) * dist
	var/fam = is_shard ? "Shard" : "Lance"
	var/tx = is_shard ? "sd[o.seq]" : "ln[o.seq]"
	var/zl = 5.4 + (o.uid % 4000) * 0.000001
	return list(list(fam, tx, 0, x, y, o.ang, st_, thin * o.lat, 0, al * 0.8, 5.4, 0, "p", al, 0, zl), list(fam, tx, 1, x, y, o.ang, st_, thin * o.lat, 0, al, 0, 0, "accent", 1, 0, zl))

/datum/beamfx/feint/ChainPair(datum/bfx_obj/o)
	if(o.kind == "fshard" || o.kind == "flance") return grey ? 0 : 1 / 0.8
	return ..()

/datum/bfx_char/feint
	var/list/inner

/datum/bfx_char/feint/New(mob/m, r)
	inner = list(new /obj/beamfx_char, new /obj/beamfx_char, new /obj/beamfx_char, new /obj/beamfx_char)
	..()

/datum/bfx_char/feint/Objs()
	var/list/L = ..()
	if(inner) L += inner
	return L

/datum/bfx_char/feint/Refresh(datum/beamfx/F, fkey2, list/above, list/spill, list/palm, list/tl)
	if(M.appearance == app && fkey2 == fkey) return
	app = M.appearance
	fkey = fkey2
	var/apart = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	Copy(sil, 0, FLOAT_LAYER, apart)
	sil.render_target = "*[id]"
	Copy(occ, ENERGYFX_OCC_PLANE, 1, apart)
	Copy(locc, ENERGYFX_LOCC_PLANE, 1, apart)
	var/icon/hands = EnergyFXFeintMask("hands")
	occ.filters = filter(type = "alpha", icon = hands, x = palm[1], y = palm[2], flags = MASK_INVERSE)
	locc.filters = filter(type = "alpha", icon = hands, x = palm[1], y = palm[2], flags = MASK_INVERSE)
	locc.alpha = 153
	var/list/dv = BeamFXDirVec(F.d)
	BeamFXRimBuild(M, "*[id]", -dv[1], -dv[2], list(tl[1] * 0.8 / 0.75, tl[2] * 0.8 / 0.75, tl[3] * 0.8 / 0.75), 1, 0.3, 3, palm, rims, EnergyFXFeintMask("palm24"))
	for(var/ii = 1 to 4)
		var/obj/beamfx_char/R = inner[ii]
		var/is_add = (ii > 2)
		BeamFXCopyApp(R, M, is_add ? BEAMFX_RIMA_PLANE : BEAMFX_RIMW_PLANE, (ii % 2) ? 2 : 3, apart)
		R.blend_mode = (ii % 2) ? BLEND_SUBTRACT : BLEND_ADD
		var/list/f = list()
		f += filter(type = "alpha", icon = EnergyFXFeintMask("palm13"), x = palm[1], y = palm[2])
		if(is_add)
			f += filter(type = "color", color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, tl[1] * 0.48, tl[2] * 0.48, tl[3] * 0.48, 0, 0, 0, 0, 1))
		else
			f += filter(type = "color", color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.42, 0.42, 0.42, 0, 0, 0, 0, 1))
		R.filters = f
		R.alpha = 0

/datum/beamfx/feint/proc/FeintChain()
	var/datum/bfx_char/feint/CF = cfx_caster
	var/list/hl = Holds()
	var/list/vals = list()
	for(var/f = 2 * k, f - 2 * k < 40, f++)
		var/kv = LightK(FT(Q(f, hl)))
		vals += clamp(kv, 0, 1) * 255
		if(kv <= 0) break
	ChainFrames(CF.rims + CF.inner, vals)

/datum/beamfx/feint/CharsTick()
	if(!glob || !glob.BEAMFX_CHARS) return
	var/mob/C = (caster_mob && caster_mob.loc && caster_mob.z == z) ? caster_mob : null
	if(cfx_caster && cfx_caster.M != C)
		cfx_caster.Drop()
		cfx_caster = null
	if(!C || isnull(t0)) return
	if(!cfx_caster) cfx_caster = new /datum/bfx_char/feint(C, 3)
	var/list/cc = BeamFXImageCenter(C)
	var/list/palm = list(round(WX(mz + 1) - cc[1], 0.01), round(WY(mz + 1) - cc[2], 0.01))
	var/app0 = cfx_caster.app
	var/fk0 = cfx_caster.fkey
	cfx_caster.Refresh(src, "f[d]|[palm[1]]|[palm[2]]", null, null, palm, FeintLit())
	if(cfx_caster.app != app0 || cfx_caster.fkey != fk0) FeintChain()

proc/EnergyFXFeintRun(datum/beamfx/feint/F)
	set waitfor = 0
	while(F && !F.finished)
		try
			F.Step()
		catch(var/exception/e)
			world.log << "ENERGYFX: feint step failed ([e]) @ [e.file]:[e.line]"
			F.Cleanup()
			return
		if(F.k > 80 || (F.k > 2 && !F.Busy()))
			F.Cleanup()
			return
		sleep(world.tick_lag)

/obj/Skills/Projectile/EnergyFXFeint(mob/p)
	if(!p || !glob || !glob.ENERGYFX || !BEAMFX_ASSETS) return 0
	var/datum/energyfx_row/R = EnergyFXRow(src)
	if(!R || R.look != "beam") return 0
	var/turf/T = get_step(get_turf(p), p.dir)
	if(!T) return 0
	var/datum/energyfx_colors/C = EnergyFXSkillColors(src, R)
	beamfx_seed++
	var/seed = (round(world.time, 1) * 7 + beamfx_seed * 131) % 30000
	var/datum/beamfx/feint/F = new(BeamFXDirText(p.dir), (T.x - 1) * 32 + 16 + p.step_x, (T.y - 1) * 32 + 16 + p.step_y, T.z, 1, seed, C, null, null)
	F.fx_row = R
	F.owner = p
	F.caster_mob = p
	F.fx_name = R.name ? R.name : name
	EnergyFXFeintRun(F)
	return 1

/datum/beamfx/var/wide = 0
/datum/beamfx/var/bent = 0
/datum/beamfx/var/wsw = 0
/datum/beamfx/var/list/wide_cap

proc/EnergyFXWideSw(w)
	var/q = clamp((w - ENERGYFX_WIDE_LO) / (ENERGYFX_WIDE_REF - ENERGYFX_WIDE_LO), 0, 1)
	return q * q * (3 - 2 * q)

proc/EnergyFXWideProf(w)
	var/e = max(w, 0.000001) ** (1 - (1 - ENERGYFX_WIDE_EDGE) * EnergyFXWideSw(w))
	var/fin = (ENERGYFX_WIDE_BODY * w - (ENERGYFX_WIDE_BODY - ENERGYFX_WIDE_SPLIT) * e) / ENERGYFX_WIDE_SPLIT
	return list(e, fin, ENERGYFX_WIDE_BODY * (w - e))

proc/EnergyFXWideFwd(lat, w)
	var/list/p = EnergyFXWideProf(w)
	var/a = abs(lat)
	var/o = (a <= ENERGYFX_WIDE_SPLIT) ? p[2] * a : p[3] + p[1] * a
	return (lat < 0) ? -o : o

/datum/beamfx/proc/WideXp(p)
	return ws ** (p * wsw)

/datum/beamfx/SetDir(dir_text)
	..()
	wsw = EnergyFXWideSw(ws)
	wide = (!bent && ws > ENERGYFX_WIDE_LO + 0.000001 && ENERGYFX_WIDE_ASSETS) ? 1 : 0
	if(wide) S = D * WideXp(ENERGYFX_WIDE_FLOW)

/datum/beamfx/proc/WideHeadK(hr)
	return min(WideXp(ENERGYFX_WIDE_EXP), max(1, (hr - mz) / ENERGYFX_WIDE_HEAD_L))

/datum/beamfx/proc/WideFlareW(dd, gm)
	var/w0 = ws ** (1 - (1 - ENERGYFX_WIDE_BLOOM) * wsw)
	var/x0 = mz - ENERGYFX_WIDE_REAR + (ENERGYFX_ART_BO + ENERGYFX_WIDE_REAR + ENERGYFX_WIDE_FLARE_U0 - 51.5) * gm
	var/x1 = mz - ENERGYFX_WIDE_REAR + (ENERGYFX_ART_BO + ENERGYFX_WIDE_REAR + ENERGYFX_WIDE_FLARE_U1 - 51.5) * gm
	return w0 + (ws - w0) * BeamFXSstep(x0, x1, dd)

/datum/beamfx/Emit(j, key, fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr = 0)
	if(!wide_cap) return ..()
	wide_cap += list(list(key, list(fam, st, light, x, y, a, sx, sy, pre, alpha, layer, order, tag, fade, seed, zl, pr)))

/datum/beamfx/ParticleFrame(datum/bfx_obj/o, fi)
	if(!wide_cap) return ..()
	var/list/pair = ParticleSpec(o, FT(fi))
	if(!pair) return
	for(var/ci = 1 to pair.len)
		var/list/sp = pair[ci]
		sp = sp.Copy()
		if(sp.len < BFX_PR) sp += 0
		wide_cap += list(list("o[o.uid]_[ci]", sp))

/datum/beamfx/Frame(fi, j)
	if(!wide) return ..()
	var/t = FT(fi)
	if(isnull(t0) || t < t0) return ..()
	var/hr = Hr(t, fi, 0)
	if(isnull(hr)) return ..()
	var/gf = WideXp(ENERGYFX_WIDE_FLOW)
	var/dead = !isnull(dead_f) && fi >= dead_f
	var/st = dead ? dead_struggle : Struggling(fi, 0)
	var/c = st ? Contact(t, fi, 0) : null
	if(!isnull(c) && !isnull(t_hit) && t >= t_hit)
		var/off = c - hr
		var/kx = WideXp(ENERGYFX_WIDE_EXP)
		f_out0 = off + (BEAMFX_STREAM_OUT0 - off) * kx
		f_out1 = off + (BEAMFX_STREAM_OUT1 - off) * kx
	else
		var/kh = WideHeadK(hr)
		var/full = (ENERGYFX_WIDE_NOSE_TIP - ENERGYFX_WIDE_NOSE_N - 64 + ENERGYFX_ART_HO) * kh - ENERGYFX_WIDE_OUT_K * 32 * D / 32 * gf
		f_out0 = BEAMFX_STREAM_OUT0 * kh
		f_out1 = BEAMFX_STREAM_OUT1 * kh + (full - BEAMFX_STREAM_OUT1 * kh) * wsw
	var/gm = WideXp(ENERGYFX_WIDE_MUZZLE)
	f_in0 = (BEAMFX_STREAM_IN0 + (ENERGYFX_WIDE_IN0 - BEAMFX_STREAM_IN0) * wsw) * gm
	f_in1 = (BEAMFX_STREAM_IN1 + (ENERGYFX_WIDE_IN1 - BEAMFX_STREAM_IN1) * wsw) * gm
	f_last = BEAMFX_LAST_L * WideXp(ENERGYFX_WIDE_EXP) * (1 + (ENERGYFX_WIDE_LAST_K - 1) * wsw)
	wide_cap = list()
	..()
	var/list/cap = wide_cap
	wide_cap = null
	f_in0 = BEAMFX_STREAM_IN0
	f_in1 = BEAMFX_STREAM_IN1
	f_out0 = BEAMFX_STREAM_OUT0
	f_out1 = BEAMFX_STREAM_OUT1
	f_last = BEAMFX_LAST_L
	WideScale(j, fi, t, hr, cap)

/datum/beamfx/proc/WidePut(list/F, key, list/sp)
	F[key] = sp
	if(logging) flog += list(sp)

/datum/beamfx/proc/WideLayers(list/F, key, list/s, sxk, syk, alpha, w_eff, core_layer)
	var/list/p = EnergyFXWideProf(w_eff)
	var/base = s[BFX_FAM]
	var/st0 = s[BFX_ST]
	var/sx2 = s[BFX_SX] * sxk
	var/list/hu = s.Copy()
	var/list/hv = s.Copy()
	s[BFX_FAM] = "[base]Q"
	s[BFX_SX] = sx2
	s[BFX_SY] = syk * p[2] / (ENERGYFX_WIDE_SS * ENERGYFX_WIDE_CORE_F)
	s[BFX_ALPHA] = alpha
	if(!s[BFX_LIGHT])
		var/cl = isnull(core_layer) ? ENERGYFX_WIDE_CORE_LAYER : core_layer
		s[BFX_ZL] = s[BFX_ZL] + (cl - s[BFX_LAYER])
		s[BFX_LAYER] = cl
	WidePut(F, "[key]q", s)
	var/ox = nx * p[3] * syk
	var/oy = ny * p[3] * syk
	var/sy2 = syk * p[1]
	hu[BFX_FAM] = "[base]H"
	hu[BFX_ST] = "u[st0]"
	hu[BFX_SX] = sx2
	hu[BFX_SY] = sy2
	hu[BFX_ALPHA] = alpha
	hu[BFX_X] += ox
	hu[BFX_Y] += oy
	WidePut(F, "[key]u", hu)
	hv[BFX_FAM] = "[base]H"
	hv[BFX_ST] = "v[st0]"
	hv[BFX_SX] = sx2
	hv[BFX_SY] = sy2
	hv[BFX_ALPHA] = alpha
	hv[BFX_X] -= ox
	hv[BFX_Y] -= oy
	WidePut(F, "[key]v", hv)

/datum/beamfx/proc/WidePair(list/F, key, list/s, sx, sy_ref, x, y)
	if(wsw > 0.001)
		var/list/b = s.Copy()
		b[BFX_FAM] = "[s[BFX_FAM]]W"
		b[BFX_SX] = sx
		b[BFX_SY] = sy_ref / ENERGYFX_WIDE_REF
		b[BFX_X] = x
		b[BFX_Y] = y
		if(s[BFX_LIGHT]) b[BFX_ALPHA] = s[BFX_ALPHA] * wsw
		else
			b[BFX_LAYER] = s[BFX_LAYER] - 0.0005
			b[BFX_ZL] = s[BFX_ZL] - 0.0005
		WidePut(F, "[key]w", b)
	if(wsw < 0.999)
		s[BFX_SX] = sx
		s[BFX_SY] = sy_ref
		s[BFX_X] = x
		s[BFX_Y] = y
		s[BFX_ALPHA] = s[BFX_ALPHA] * (1 - wsw)
		WidePut(F, key, s)

/datum/beamfx/proc/WideScale(j, fi, t, hr, list/cap)
	var/list/F = frame_specs[j]
	var/g = WideXp(ENERGYFX_WIDE_EXP)
	var/gf = WideXp(ENERGYFX_WIDE_FLOW)
	var/list/pf = EnergyFXWideProf(ws)
	var/gh = WideHeadK(hr)
	var/c = Struggling(fi, 0) ? Contact(t, fi, 0) : null
	var/cd = isnull(c) ? hr : c
	var/cx = WX(cd)
	var/cy = WY(cd)
	var/px = WX(mz - ENERGYFX_WIDE_REAR)
	var/py = WY(mz - ENERGYFX_WIDE_REAR)
	var/gmb = min(WideXp(ENERGYFX_WIDE_MUZZLE), max(1, (hr - mz + ENERGYFX_WIDE_REAR) / ENERGYFX_WIDE_STUB_L))
	var/released = !isnull(release_f) && fi >= release_f
	var/flying = !isnull(fly_f) && fi > fly_f
	var/bk = Back(t, fi)
	var/lk = 1 + (ENERGYFX_WIDE_LAST_K - 1) * wsw
	for(var/list/e in cap)
		var/key = e[1]
		var/list/s = e[2]
		var/fam = s[BFX_FAM]
		var/sx = s[BFX_SX]
		var/x = s[BFX_X]
		var/y = s[BFX_Y]
		switch(fam)
			if("Stamp", "Surge")
				var/dd = (x - Ox) * ax + (y - Oy) * ay
				var/list/fw = BEAMFX_FAM[fam]
				var/w_eff = WideFlareW(dd - ENERGYFX_WIDE_TAPER_BACK * fw[2] * 0.5 * sx * gf, gmb)
				var/syk = s[BFX_SY] / ws
				var/alpha = s[BFX_ALPHA]
				if(released && fam == "Stamp")
					var/xb = ENERGYFX_WIDE_TAIL_BACK * wsw * S
					var/lo = flying ? bk + 16 : bk
					var/hi = flying ? bk + 96 : bk + 40
					var/hk = flying ? bk + 104 : bk + 52
					var/a0 = BeamFXSstep(lo, hi, dd)
					var/k0 = BeamFXSstep(lo, hk, dd)
					var/a1 = BeamFXSstep(lo, hi, dd - xb)
					var/k1 = BeamFXSstep(lo, hk, dd - xb)
					var/ra = (a0 > 0.0001) ? a1 / a0 : 0
					alpha = s[BFX_ALPHA] * ra * (s[BFX_LIGHT] ? ((k0 > 0.0001) ? k1 / k0 : 0) : 1)
					syk = syk * (0.3 + 0.7 * (k1 ** 0.8)) / (0.3 + 0.7 * (k0 ** 0.8))
				WideLayers(F, key, s, gf, syk, alpha, w_eff, null)
			if("Bloom")
				if(copytext(s[BFX_ST], 1, 3) == "la")
					var/shl = ENERGYFX_ART_LO * sx * (g * lk - 1)
					WidePair(F, key, s, sx * g * lk, s[BFX_SY], x + ax * shl, y + ay * shl)
				else
					WidePair(F, key, s, sx * gmb, s[BFX_SY], px + (x - px) * gmb, py + (y - py) * gmb)
			if("End")
				var/she = ENERGYFX_WIDE_END_OFF * sx * (g - 1)
				WidePair(F, key, s, sx * g, s[BFX_SY], x + ax * she, y + ay * she)
			if("Head")
				var/hd = (x - Ox) * ax + (y - Oy) * ay - ENERGYFX_ART_HO * sx
				var/shh = ENERGYFX_ART_HO * sx * (gh - 1)
				WidePair(F, key, s, sx * gh, s[BFX_SY] * WideFlareW(hd - ENERGYFX_WIDE_HEAD_AT * gh, gmb) / ws, x + ax * shh, y + ay * shh)
			if("Impact")
				var/shi = -(BEAMFX_CONTACT - ENERGYFX_ART_IO) * sx * (g - 1)
				var/syi = s[BFX_SY] / ws
				s[BFX_X] = x + ax * shi
				s[BFX_Y] = y + ay * shi
				WideLayers(F, key, s, g, syi, s[BFX_ALPHA], ws, s[BFX_LAYER] - 0.05)
			if("Bead", "Sheath")
				var/dd2 = (x - Ox) * ax + (y - Oy) * ay
				var/lt = (x - Ox) * nx + (y - Oy) * ny - lat0
				var/l2 = EnergyFXWideFwd(lt / ws, ws) + lat0
				s[BFX_X] = Ox + ax * dd2 + nx * l2
				s[BFX_Y] = Oy + ay * dd2 + ny * l2
				s[BFX_SX] = sx * gf
				s[BFX_SY] = ((fam == "Bead") ? s[BFX_SY] / ws : s[BFX_SY]) * pf[1]
				WidePut(F, key, s)
			else
				var/dd3 = (x - Ox) * ax + (y - Oy) * ay
				if(abs(dd3 - cd) <= abs(dd3 - mz))
					s[BFX_X] = cx + (x - cx) * g
					s[BFX_Y] = cy + (y - cy) * g
				s[BFX_SX] = sx * g
				s[BFX_SY] = s[BFX_SY] * g
				WidePut(F, key, s)

/datum/beamfx/SpeckEmitter(region, x, y, rate, v1, v2, l1, l2, cnt)
	var/obj/energyfx/emit/O = ..()
	if(!wide || !O || !O.particles) return O
	var/particles/P = O.particles
	var/g = WideXp(ENERGYFX_WIDE_EXP)
	var/ca = cos(ang)
	var/sa = sin(ang)
	P.transform = matrix(ca * g, -sa * g, x - O.fx_bx, sa * g, ca * g, y - O.fx_by)
	return O

/datum/beamfx/SpeckStep()
	if(!wide || (!spk_burst && !spk_shots.len)) return ..()
	var/g = WideXp(ENERGYFX_WIDE_EXP)
	var/fi = 2 * k
	var/t = FT(fi)
	var/hr = Hr(t, fi, 0)
	if(!isnull(hr))
		var/c = Struggling(fi, 0) ? Contact(t, fi, 0) : null
		var/cd = isnull(c) ? hr : c
		var/cx = WX(cd)
		var/cy = WY(cd)
		if(spk_burst) spk_burst[2] = spk_burst[2] + 2 - 2 * g
		for(var/list/s in spk_shots)
			s[3] = cx + (s[3] - cx) * g
			s[4] = cy + (s[4] - cy) * g
	var/mode0 = spk_mode
	var/x0 = spk_x
	var/y0 = spk_y
	..()
	if(spk_mode && spk_mode == mode0 && (spk_x != x0 || spk_y != y0))
		var/ca = cos(ang)
		var/sa = sin(ang)
		for(var/region in spk_em)
			var/obj/energyfx/emit/O = spk_em[region]
			if(!O || !O.particles) continue
			var/particles/P = O.particles
			P.transform = matrix(ca * g, -sa * g, spk_x - O.fx_bx, sa * g, ca * g, spk_y - O.fx_by)
