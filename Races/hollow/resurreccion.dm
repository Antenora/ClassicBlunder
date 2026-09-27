obj/Skills/Buffs/SpecialBuffs
	Resurreccion
		SpecialSlot = 1
		UnrestrictedBuff = 1
		CooldownStatic = 1
		Cooldown = 60
		StrMult = 1.15
		EndMult = 1.15
		ForMult = 1.15
		OffMult = 1.15
		DefMult = 1.15
		SpdMult = 1.15
		PowerMult = HOLLOW_RES_POWER_MULT
		passives = list("Pursuer" = 1, "Flicker" = 1)
		OffMessage = "seals their release."
		var
			res_id
			identity_line = ""
			list/kit_skills = list()

		verb/Release()
			set name = "Resurreccion"
			set category = "Skills"
			var/mob/User = usr
			if(!ismob(User))
				User = src.loc
			if(!ismob(User))
				return
			if(User.BuffOn(src))
				src.Trigger(User)
				return
			if(!User.HollowResurreccionReady(src.res_id))
				return
			if(User.AscensionsAcquired < 3)
				User << "<font color=red>Your Resurreccion has not awakened yet.</font>"
				return
			User.HollowClearSpecialSlot(src)
			src.Trigger(User)

	Segunda_Etapa
		SpecialSlot = 1
		UnrestrictedBuff = 1
		CooldownStatic = 1
		Cooldown = 60
		StrMult = 1.3
		EndMult = 1.3
		ForMult = 1.3
		OffMult = 1.3
		DefMult = 1.3
		SpdMult = 1.3
		PowerMult = HOLLOW_RES_POWER_MULT
		passives = list("Pursuer" = 2, "Flicker" = 2, "Juggernaut" = 0.5)
		OffMessage = "falls back out of the second stage."
		var
			res_id
			identity_line = ""
			list/kit_skills = list()

		verb/Release_Segunda()
			set name = "Segunda Etapa"
			set category = "Skills"
			var/mob/User = usr
			if(!ismob(User))
				User = src.loc
			if(!ismob(User))
				return
			if(User.BuffOn(src))
				src.Trigger(User)
				return
			if(!User.HollowResurreccionReady(src.res_id))
				return
			if(User.AscensionsAcquired < 4)
				User << "<font color=red>You are not developed enough for a second stage.</font>"
				return
			if(User.HollowStage != HOLLOW_STAGE_VASTO)
				User << "<font color=red>Only a Vasto Lorde can reach a second stage.</font>"
				return
			User.HollowClearSpecialSlot(src)
			src.Trigger(User)

/mob/proc/HollowResurreccionReady(id)
	if(!src.HollowIsHollow() || !src.HollowArrancar)
		return 0
	if(!id || src.HollowResId != id)
		src << "<font color=red>That release is not yours.</font>"
		return 0
	return 1

/mob/proc/HollowClearSpecialSlot(obj/Skills/Buffs/keep)
	if(!src.SpecialBuff || src.SpecialBuff == keep)
		return
	var/obj/Skills/Buffs/old = src.SpecialBuff
	old.Trigger(src, Override = 1)

/mob/proc/HollowResurreccionType(id)
	if(!id)
		return null
	for(var/T in typesof(/obj/Skills/Buffs/SpecialBuffs/Resurreccion) - /obj/Skills/Buffs/SpecialBuffs/Resurreccion)
		var/obj/Skills/Buffs/SpecialBuffs/Resurreccion/R = T
		if(initial(R.res_id) == id)
			return T
	return null

/mob/proc/HollowSegundaType(id)
	if(!id)
		return null
	for(var/T in typesof(/obj/Skills/Buffs/SpecialBuffs/Segunda_Etapa) - /obj/Skills/Buffs/SpecialBuffs/Segunda_Etapa)
		var/obj/Skills/Buffs/SpecialBuffs/Segunda_Etapa/S = T
		if(initial(S.res_id) == id)
			return T
	return null

/mob/HollowStageSkillSet()
	. = ..()
	if(!islist(.))
		return .
	if(!src.HollowArrancar || !src.HollowResId)
		return .
	if(src.AscensionsAcquired >= 3)
		var/rt = src.HollowResurreccionType(src.HollowResId)
		if(rt)
			. += rt
			var/obj/Skills/Buffs/SpecialBuffs/Resurreccion/R = rt
			for(var/k in initial(R.kit_skills))
				. += k
	if(src.AscensionsAcquired >= 4 && src.HollowStage == HOLLOW_STAGE_VASTO)
		var/st = src.HollowSegundaType(src.HollowResId)
		if(st)
			. += st
			var/obj/Skills/Buffs/SpecialBuffs/Segunda_Etapa/S = st
			for(var/k in initial(S.kit_skills))
				. += k

/mob/proc/HollowSealReleases()
	if(!src.SpecialBuff)
		return
	if(istype(src.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Resurreccion) || istype(src.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Segunda_Etapa))
		src.SpecialBuff.Trigger(src, Override = 1)

/mob/proc/HollowResurreccionLoginGuard()
	if(!src.HollowIsHollow() || !src.HollowResId)
		return
	var/list/entry = glob.ResurreccionHolders ? glob.ResurreccionHolders[src.HollowResId] : null
	if(islist(entry) && entry.len >= 1 && entry[1] == src.key)
		return
	src.HollowSealReleases()
	src.HollowResId = null
	src.HollowSyncSkills()
