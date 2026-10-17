var/list/STYLE_STAGE_FLAGS = list("NeedsSword", "NoSword", "NoStaff", "NeedsStaff", "NeedsGun", "NeedsSecondSword", "NeedsThirdSword", "AllowsThirdSword")

/obj/Skills/Buffs/NuStyle/adjust(mob/p)
	..()
	if(stage_passives)
		ApplyStage(StyleStage(p))

/obj/Skills/Buffs/NuStyle/proc/StageThresholds()
	. = list()
	if(!glob || !glob.progress)
		return
	var/list/T2 = glob.progress.T2_STYLES
	var/list/T3 = glob.progress.T3_STYLES
	var/list/T4 = glob.progress.T4_STYLES
	if(T2 && T2.len)
		. += T2[1]
	if(T3 && T3.len)
		. += T3[1]
	if(T4 && T4.len)
		. += T4[1]

/obj/Skills/Buffs/NuStyle/proc/StageCount()
	return stage_passives ? max(1, stage_passives.len) : 1

/obj/Skills/Buffs/NuStyle/proc/StageOwner(mob/p)
	if(ismob(p))
		return p
	if(ismob(loc))
		return loc
	return null

/obj/Skills/Buffs/NuStyle/StyleStage(mob/p)
	p = StageOwner(p)
	. = 1
	if(!p)
		return
	for(var/v in StageThresholds())
		if(p.Potential >= v)
			.++
	. = min(., StageCount())

/obj/Skills/Buffs/NuStyle/StageNextPotential(mob/p)
	p = StageOwner(p)
	if(!p || StyleStage(p) >= StageCount())
		return null
	for(var/v in StageThresholds())
		if(p.Potential < v)
			return v
	return null

/obj/Skills/Buffs/NuStyle/proc/ApplyStage(n)
	if(!stage_passives || !stage_passives.len)
		return
	n = clamp(round(n), 1, stage_passives.len)
	var/list/P = stage_passives[n]
	passives = istype(P) ? P.Copy() : list()
	ApplyStageFlags(n)
	applied_stage = n

/obj/Skills/Buffs/NuStyle/proc/ApplyStageFlags(n)
	if(!length(stage_flags))
		return
	var/list/F = stage_flags[clamp(round(n), 1, stage_flags.len)]
	if(!istype(F))
		F = list()
	for(var/key in STYLE_STAGE_FLAGS)
		vars[key] = (key in F) ? F[key] : 0

/obj/Skills/Buffs/NuStyle/proc/StageChanged(mob/p)
	return

/mob/proc/RosterStyleOwned()
	for(var/obj/Skills/Buffs/NuStyle/N in src)
		if(!N.SagaStyle)
			return N
	return null

/mob/proc/StyleLockRefuses(obj/Skills/S)
	if(!istype(S, /obj/Skills/Buffs/NuStyle))
		return 0
	var/obj/Skills/Buffs/NuStyle/N = S
	if(N.SagaStyle)
		return 0
	if(!RosterStyleOwned())
		return 0
	src << "You have chosen your style."
	return 1

/mob/StyleStageRefresh()
	..()
	var/obj/Skills/Buffs/NuStyle/S = StyleBuff
	if(!istype(S) || !S.stage_passives || !passive_handler)
		return
	var/n = S.StyleStage(src)
	var/was = S.applied_stage
	if(n == was)
		return
	if(S.current_passives)
		passive_handler.decreaseList(S.current_passives)
	S.ApplyStage(n)
	S.current_passives = S.passives
	passive_handler.increaseList(S.passives)
	if(was)
		src << "Your [S] has reached stage [n]."
	S.StageChanged(src)
