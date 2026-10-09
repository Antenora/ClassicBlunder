/datum/beam/var/tmp/datum/beamfx/fx
/datum/beam/var/tmp/fx_in_tick = 0
/datum/beam/var/tmp/datum/beamfx/fork_fx
/datum/beam/var/tmp/fork_drive = 0

/datum/beam/proc/FxOwned()
	return (fx || (parent && parent.fx)) ? 1 : 0

/datum/beamfx/var/no_bloom = 0
/datum/beamfx/var/clash_lead = 0
/datum/beamfx/var/death_k = -1
/datum/beamfx/var/fx_name

/datum/beam/New(mob/M, obj/Skills/Projectile/Z, d)
	..()
	if(M && FxEligible(Z)) fx = FxStart(M, Z)

/mob/proc/EnergyFXChargeHook(obj/Skills/Z)
	return 0

/mob/proc/EnergyFXChargeDraws(obj/Skills/Z)
	return 0

/mob/proc/EnergyFXChargeTick(obj/Skills/Z, frac)
	return

/mob/proc/EnergyFXChargeClear()
	return

/obj/Skills/Projectile/proc/EnergyFXFeint(mob/p)
	return 0

/datum/beam/proc/FxEligible(obj/Skills/Projectile/Z)
	return 0

/datum/beam/proc/FxStart(mob/M, obj/Skills/Projectile/Z)
	return BeamFXStart(src, M, Z)

/datum/beam/Tick()
	fx_in_tick = 1
	try
		..()
	catch(var/exception/e)
		fx_in_tick = 0
		throw e
	fx_in_tick = 0
	if(fx) BeamFXTickFrom(src)
	else if(fork_drive && fork_fx) EnergyFXForkArmTick(src)

/datum/beam/Die()
	var/datum/beamfx/F = fx
	var/list/A = arms ? arms.Copy() : null
	var/datum/beamfx/AF = fork_drive ? fork_fx : null
	..()
	if(AF && !AF.finished && AF.death_k < 0)
		fork_drive = 0
		if(!EnergyFXForkHandoff(AF, AF.fork_arms, src))
			AF.death_k = max(0, AF.k)
			BeamFXAfterlife(AF)
		return
	if(F && F.fgeo && A && EnergyFXForkHandoff(F, A, null)) return
	if(F && !F.finished && F.death_k < 0 && !fx_in_tick)
		F.death_k = max(0, F.k)
		BeamFXAfterlife(F)

/obj/Skills/Projectile/_Projectile/var/tmp/bfx_plane

/datum/beam/MakePart()
	var/obj/Skills/Projectile/_Projectile/p = ..()
	if(p && FxOwned())
		p.bfx_plane = p.plane
		p.plane = ENERGYFX_HIDE_PLANE
	return p

/datum/beam/HeadGlow()
	if(FxOwned()) return
	..()

proc/BeamFXSkillColor(obj/Skills/Projectile/Z)
	var/list/c = EnergyFXSlotRGB(Z.EnergyColorMain, 158)
	if(c) return c
	var/art = FxIconPaint(Z.IconLock, "tail")
	if(!art) art = FxIconPaint(Z.IconLock, "head")
	c = BeamFXHexRGB(art)
	return c ? c : list(0, 0, 0)

proc/BeamFXWidth(datum/beam/B, obj/Skills/Projectile/Z)
	var/w = 1
	if(glob && glob.FLASH_STATES)
		var/ch = B.charge
		w = clamp(0.85 + 0.3 * (ch - 0.5), 0.85, 1.3)
		if(ch > 2) w = min(1.3 * sqrt(ch / 2), 3)
	var/sz = (Z && Z.IconSize) ? Z.IconSize : 1
	return w * sz

proc/BeamFXStart(datum/beam/B, mob/M, obj/Skills/Projectile/Z)
	beamfx_seed++
	var/seed = (round(world.time, 1) * 7 + beamfx_seed * 131) % 30000
	var/datum/beamfx/F = new(BeamFXDirText(B.bdir), 0, 0, M.z, BeamFXWidth(B, Z), seed, BeamFXSkillColor(Z), EnergyFXSlotRGB(Z.EnergyColorCore, 255), EnergyFXSlotRGB(Z.EnergyColorGlow, 158))
	F.beam = B
	F.owner = M
	F.caster_mob = M
	F.fx_name = Z.name
	F.logging = glob ? glob.BEAMFX_LOG : 0
	return F

proc/BeamFXAnchor(datum/beam/B, datum/beamfx/F)
	if(!B.anchor) return
	var/want = BeamFXDirText(B.bdir)
	if(want != F.d) F.SetDir(want)
	F.Ox = (B.anchor.x - 1) * 32 + 16 + B.ox
	F.Oy = (B.anchor.y - 1) * 32 + 16 + B.oy
	F.z = B.anchor.z

proc/BeamFXBlocker(datum/beam/B)
	var/obj/Skills/Projectile/_Projectile/h = B.HeadPart()
	if(!h || !h.loc) return null
	var/mob/best
	var/bestd = 1000000
	for(var/mob/m in range(2, h))
		if(m == B.owner || !m.density) continue
		if(!HitboxesOverlap(h, m)) continue
		var/dd = get_dist(B.anchor, m)
		if(dd < bestd)
			bestd = dd
			best = m
	return best

proc/BeamFXTickFrom(datum/beam/B)
	var/datum/beamfx/F = B.fx
	if(!F || F.finished || F.death_k >= 0) return
	if(F.k < 0 || B.firing)
		if(F.k < 0)
			F.no_bloom = B.no_origin ? 1 : 0
			F.start_wt = EnergyFXNow()
		BeamFXAnchor(B, F)
	F.s_n = B.parts.len
	F.s_travelled = B.travelled
	F.s_firing = B.firing ? 1 : 0
	F.s_blocked = B.blocked ? 1 : 0
	F.s_clash = B.frozen ? 1 : 0
	F.s_dead = B.dying ? 1 : 0
	if(F.partner && F.partner.finished) F.partner = null
	if(F.clash_ref)
		var/datum/beam_clash/CL = F.clash_ref
		if(CL.ended || CL.done)
			BeamFXClashEnd(F)
		else if(F.cm_on)
			F.s_off = CL.p * glob.CLASH_PUSH_PX + CL.kick
	var/forked = (F.fgeo || (B.prism_split && B.arms)) ? EnergyFXForkFeed(B, F) : 0
	if(B.blocked && !B.frozen && !forked)
		var/mob/m = BeamFXBlocker(B)
		F.target_mob = m
		if(m)
			var/cx = (m.x - 1) * 32 + m.step_x + m.bound_x + m.bound_width / 2
			var/cy = (m.y - 1) * 32 + m.step_y + m.bound_y + m.bound_height / 2
			F.target_d = (cx - F.Ox) * F.ax + (cy - F.Oy) * F.ay
		else
			var/obj/Skills/Projectile/_Projectile/pb = BeamFXBeamBlocker(B)
			var/datum/beamfx/PF = (pb && pb.beam_owner) ? pb.beam_owner.fx : null
			if(PF && PF != F && !PF.finished && PF.death_k < 0)
				if(F.partner != PF) BeamFXPair(F, PF, PF.partner == F ? 0 : 1)
			else if(pb)
				var/px = (pb.x - 1) * 32 + pb.step_x + pb.bound_x + pb.bound_width / 2
				var/py = (pb.y - 1) * 32 + pb.step_y + pb.bound_y + pb.bound_height / 2
				F.target_d = (px - F.Ox) * F.ax + (py - F.Oy) * F.ay
			else
				F.target_d = (F.s_travelled + F.s_n) * F.D
	if(F.bent && B.steer) EnergyFXBendFeed(B, F)
	var/u0 = world.tick_usage
	try
		F.Step()
	catch(var/exception/e)
		world.log << "BEAMFX: step failed ([e]) @ [e.file]:[e.line]"
		F.Cleanup()
		B.fx = null
		BeamFXUnhide(B)
		return
	beamfx_cost += max(0, world.tick_usage - u0)
	beamfx_cost_n++
	if(B.dying && F.death_k < 0 && !F.fork_handed)
		F.death_k = F.k
		BeamFXAfterlife(F)

proc/BeamFXAfterlife(datum/beamfx/F)
	set waitfor = 0
	while(F && !F.finished)
		sleep(world.tick_lag)
		F.s_dead = 1
		try
			F.Step()
		catch(var/exception/e)
			world.log << "BEAMFX: afterlife step failed ([e]) @ [e.file]:[e.line]"
			F.Cleanup()
			return
		if((F.k - F.death_k > 6 && !F.Busy()) || F.k - F.death_k > 160)
			F.Cleanup()

proc/BeamFXLumOf(datum/beamfx/F)
	return F.ClashLum()

/datum/beamfx/proc/ClashLum()
	var/list/lc = ramp[1]
	return max(0.05, BeamFXLum(lc))

proc/BeamFXBeamBlocker(datum/beam/B)
	var/obj/Skills/Projectile/_Projectile/h = B.HeadPart()
	if(!h || !h.loc) return null
	for(var/obj/Skills/Projectile/_Projectile/p in range(2, h))
		if(p == h || p.Owner == B.owner) continue
		if(!HitboxesOverlap(h, p)) continue
		return p
	return null

proc/BeamFXPair(datum/beamfx/F, datum/beamfx/P, lead)
	F.clash_mode = 1
	P.clash_mode = 1
	F.partner = P
	P.partner = F
	F.clash_lead = lead ? 1 : 0
	P.clash_lead = lead ? 0 : 1
	var/lf = BeamFXLumOf(F)
	var/lp = BeamFXLumOf(P)
	F.gain = clamp((lp / lf) ** 0.75, 0.55, 1.45)
	P.gain = clamp((lf / lp) ** 0.75, 0.55, 1.45)

proc/BeamFXClashEnd(datum/beamfx/F)
	var/datum/beamfx/P = F.partner
	for(var/datum/beamfx/X in list(F, P))
		if(!X) continue
		X.clash_ref = null
		X.cm_on = 0
		X.clash_mode = 0
		X.partner = null

/datum/beamfx/var/datum/beam_clash/clash_ref

/datum/beam_clash/BuildFx()
	var/datum/beamfx/FA = a?.beam_ref?.fx
	var/datum/beamfx/FB = b?.beam_ref?.fx
	if(FA && FB)
		BeamFXPair(FA, FB, 1)
		FA.cm_on = 1
		FA.cm_x = null
		FA.cm_y = null
		FA.clash_ref = src
		FB.clash_ref = src
		mid = a.head ? get_turf(a.head) : null
		return
	if(FA) FA.clash_mode = 1
	if(FB) FB.clash_mode = 1
	..()

proc/BeamFXUnhide(datum/beam/B)
	for(var/obj/Skills/Projectile/_Projectile/p in B.parts)
		if(p && p.plane == ENERGYFX_HIDE_PLANE) p.plane = isnull(p.bfx_plane) ? initial(p.plane) : p.bfx_plane
