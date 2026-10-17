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
		return
	var/datum/energyfx_colors/K = C255
	fx_colors = K
	ramp = K.ramp

var/list/energyfx_feint_masks = list()

proc/EnergyFXFeintMask(st)
	var/icon/I = energyfx_feint_masks[st]
	if(!I)
		I = icon(ENERGYFX_ART_FEINT_MASKS, st)
		energyfx_feint_masks[st] = I
	return I

/datum/beamfx/feint

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

/datum/beamfx/var/bent = 0
