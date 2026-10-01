datum/mech_intrinsic_part
	var/id
	var/name
	var/description = ""
	var/slot_family
	// for Arm/Back/Internal: an intrinsic-only child of a normal mech part or gun
	var/part_type
	var/core_tier = 1 // replaces Core, so need a core tier
	var/will_bonus_mult = 1

	proc/IsConfigured()
		if(!id || !slot_family) return FALSE
		if(slot_family == "Reactor") return !part_type
		if(!(slot_family in list("Arm", "Back", "Internal"))) return FALSE
		if(!ispath(part_type, /obj/Items/MechPart) && !ispath(part_type, /obj/Items/Gun)) return FALSE
		var/obj/Items/T = part_type
		if(initial(T.mech_slot) != slot_family || initial(T.intrinsic_template_id) != id) return FALSE
		if(ispath(part_type, /obj/Items/Gun))
			var/obj/Items/Gun/G = part_type
			if(!initial(G.mech_only)) return FALSE
		return TRUE

	proc/OnInstall(mob/User, obj/Items/Mech/R, list/state)
		return
	proc/OnRemove(mob/User, obj/Items/Mech/R, list/state)
		return
	proc/OnMount(mob/User, obj/Items/Mech/R, list/state, remount = 0)
		return
	proc/OnDismount(mob/User, obj/Items/Mech/R, list/state, wreck = 0)
		return
	proc/OnUseWeapon(mob/User, obj/Items/Mech/R, obj/Items/weapon, list/state)
		return
	proc/OnUseSkill(mob/User, obj/Items/Mech/R, obj/Skills/S, list/state)
		return
	proc/OnTick(mob/User, obj/Items/Mech/R, dt, list/state)
		return
	proc/ModifyStats(mob/User, obj/Items/Mech/R, list/stats, list/state)
		return
	proc/ModifyHeatCost(mob/User, obj/Items/Mech/R, amount, obj/source, list/state)
		return amount
	proc/ModifyHeatCapacity(mob/User, obj/Items/Mech/R, amount, list/state)
		return amount
	proc/ModifyCooling(mob/User, obj/Items/Mech/R, amount, list/state)
		return amount
	proc/ModifyFuelUse(mob/User, obj/Items/Mech/R, amount, list/state)
		return amount
	proc/ModifyWeaponShot(mob/User, obj/Items/Mech/R, obj/Items/Gun/G, obj/Skills/Projectile/S, list/state)
		return
	proc/ExtraSkillPaths(mob/Owner, obj/Items/Mech/R, list/state)
		return list()
	proc/ModifyPilotXPGain(mob/User, obj/Items/Mech/R, amount, list/state)
		return amount


var/global/list/MechIntrinsicParts = list()
var/global/MechIntrinsicPartsRegistered = FALSE
mob/var/LearningComputerPilotXPGained = 0

proc/RegisterMechIntrinsicParts()
	if(MechIntrinsicPartsRegistered) return
	for(var/path in typesof(/datum/mech_intrinsic_part))
		if(path == /datum/mech_intrinsic_part) continue
		var/datum/mech_intrinsic_part/P = new path
		if(!P.IsConfigured())
			del P
			continue
		if(MechIntrinsicParts[P.id])
			world.log << "Duplicate intrinsic part ID: [P.id]"
			del P
			continue
		if(!P.name) P.name = P.id
		MechIntrinsicParts[P.id] = P
	MechIntrinsicPartsRegistered = TRUE

mob/var
	intrinsic_character_id
	list/MechIntrinsicUnlocks = list()

obj/Items/Mech/var
	intrinsic_mech_id
	list/intrinsic_installed = list()
	tmp/intrinsic_refitting = FALSE

proc/MechIntrinsicNewID(datum/D)
	return md5("[world.realtime]|[world.time]|[rand(1, 1000000000)]|[rand(1, 1000000000)]|\ref[D]")

mob/proc/IntrinsicOwnerID()
	if(!intrinsic_character_id) intrinsic_character_id = MechIntrinsicNewID(src)
	return intrinsic_character_id

obj/Items/Mech/proc/IntrinsicMechID()
	if(!intrinsic_mech_id) intrinsic_mech_id = MechIntrinsicNewID(src)
	return intrinsic_mech_id

var/global/list/MechIntrinsicClaims = list()
var/global/MechIntrinsicClaimsLoaded = FALSE

proc/MechIntrinsicLoadClaims()
	if(MechIntrinsicClaimsLoaded) return TRUE
	if(fexists("MechIntrinsicClaims.sav"))
		try
			var/savefile/F = new("MechIntrinsicClaims.sav")
			var/list/L
			F["claims"] >> L
			if(!islist(L)) return FALSE
			MechIntrinsicClaims = L
		catch(var/exception/E)
			world.log << "Intrinsic claims load failed: [E]"
			return FALSE
	MechIntrinsicClaimsLoaded = TRUE
	return TRUE

proc/MechIntrinsicSaveClaims()
	try
		var/savefile/F = new("MechIntrinsicClaims.sav")
		F["claims"] << MechIntrinsicClaims
	catch(var/exception/E)
		world.log << "Intrinsic claims save failed: [E]"
		return FALSE
	return TRUE

proc/MechIntrinsicClaimKey(owner_id, part_id)
	return "[owner_id]|[part_id]"

mob/proc/HasIntrinsicPart(part_id)
	return islist(MechIntrinsicUnlocks) && islist(MechIntrinsicUnlocks[part_id])

mob/proc/IntrinsicPartMechID(part_id)
	if(!MechIntrinsicLoadClaims()) return "unavailable"
	var/list/C = MechIntrinsicClaims[MechIntrinsicClaimKey(IntrinsicOwnerID(), part_id)]
	return islist(C) ? C["mech_id"] : null

obj/Items/Mech/proc/IntrinsicValid(list/I)
	if(!islist(I) || !MechIntrinsicLoadClaims()) return FALSE
	var/list/C = MechIntrinsicClaims[MechIntrinsicClaimKey(I["owner_id"], I["part_id"])]
	return islist(C) && C["mech_id"] == intrinsic_mech_id && C["token"] == I["token"]

obj/Items/Mech/proc/IntrinsicRecords()
	var/list/out = list()
	RegisterMechIntrinsicParts()
	if(!islist(intrinsic_installed)) return out
	for(var/slot in intrinsic_installed)
		var/list/I = intrinsic_installed[slot]
		if(!IntrinsicValid(I) || !MechIntrinsicParts[I["part_id"]]) continue
		if(slot != "Reactor")
			var/obj/Items/P = MechRawPartIn(I["slot"])
			if(!P || P.intrinsic_record_key != slot || !IntrinsicPartActive(P)) continue
		if(!islist(I["state"])) I["state"] = list()
		out += list(I)
	return out

obj/Items/Mech/proc/IntrinsicEvent(event, mob/User, value = null, extra = null)
	for(var/list/I in IntrinsicRecords())
		var/datum/mech_intrinsic_part/P = MechIntrinsicParts[I["part_id"]]
		var/list/state = I["state"]
		try
			switch(event)
				if("mount") P.OnMount(User, src, state, value)
				if("dismount") P.OnDismount(User, src, state, value)
				if("weapon") P.OnUseWeapon(User, src, value, state)
				if("skill") P.OnUseSkill(User, src, value, state)
				if("tick") P.OnTick(User, src, value, state)
				if("stats") P.ModifyStats(User, src, value, state)
				if("shot") P.ModifyWeaponShot(User, src, value, extra, state)
		catch(var/exception/E)
			world.log << "Intrinsic [P.id] [event] failed: [E]"

obj/Items/Mech/proc/IntrinsicNumber(kind, mob/User, amount, obj/source = null)
	for(var/list/I in IntrinsicRecords())
		var/datum/mech_intrinsic_part/P = MechIntrinsicParts[I["part_id"]]
		var/result = amount
		try
			switch(kind)
				if("heat") result = P.ModifyHeatCost(User, src, amount, source, I["state"])
				if("capacity") result = P.ModifyHeatCapacity(User, src, amount, I["state"])
				if("cooling") result = P.ModifyCooling(User, src, amount, I["state"])
				if("fuel") result = P.ModifyFuelUse(User, src, amount, I["state"])
				if("pilot_xp") result = P.ModifyPilotXPGain(User, src, amount, I["state"])
		catch(var/exception/E)
			world.log << "Intrinsic [P.id] [kind] failed: [E]"
		if(isnum(result)) amount = max(0, result)
	return amount

mob/proc/IntrinsicHeatCost(amount, obj/source = null)
	if(!mech) return amount
	return mech.IntrinsicNumber("heat", src, amount, source)

mob/proc/IntrinsicSkillUsed(obj/Skills/S)
	if(!mech || !S || istype(S, /obj/Skills/Projectile/Gunfire)) return
	mech.IntrinsicEvent("skill", src, S)


obj/LifeSkills/Station/MechBay/proc/MechBayIntrinsicReactors(mob/M, obj/Items/Mech/R)
	if(!MechBayValid(M, R) || M.InCombat()) return
	RegisterMechIntrinsicParts()
	if(!MechIntrinsicLoadClaims())
		M << "Intrinsic part assignments could not be loaded. Contact an admin."
		return
	var/list/choices = list()
	var/list/current = islist(R.intrinsic_installed) ? R.intrinsic_installed["Reactor"] : null
	if(islist(current))
		if(current["owner_id"] != M.IntrinsicOwnerID())
			M << "Only the character who installed this intrinsic reactor may remove it."
			return
		choices["Remove or replace intrinsic reactor"] = "remove"
	else
		for(var/part_id in M.MechIntrinsicUnlocks)
			var/datum/mech_intrinsic_part/P = MechIntrinsicParts[part_id]
			if(!P || P.slot_family != "Reactor" || !M.HasIntrinsicPart(part_id)) continue
			if(M.IntrinsicPartMechID(part_id)) continue
			choices["Install [P.name] ([part_id])"] = part_id
	if(!choices.len)
		M << "You have no unassigned intrinsic reactors. Remove one from its current mech first."
		return
	var/pick = Ask(M, "Choose an intrinsic reactor. Refitting costs [MECH_REFIT_LS] Life Stamina.", craft_title, null, "pick", choices, 1)
	if(!pick || !choices[pick]) return
	// All checks are repeated after the prompt. No yielding between check and commit.
	if(!MechBayValid(M, R) || M.InCombat()) return
	if(choices[pick] == "remove")
		MechBayRemoveIntrinsicReactor(M, R)
	else
		MechBayInstallIntrinsicReactor(M, R, choices[pick])

obj/LifeSkills/Station/MechBay/proc/MechBayInstallIntrinsicReactor(mob/M, obj/Items/Mech/R, part_id)
	if(!MechBayValid(M, R) || M.InCombat() || !MechIntrinsicLoadClaims()) return FALSE
	var/datum/mech_intrinsic_part/P = MechIntrinsicParts[part_id]
	if(!P || P.slot_family != "Reactor" || !M.HasIntrinsicPart(part_id)) return FALSE
	if(islist(R.intrinsic_installed) && R.intrinsic_installed["Reactor"]) return FALSE
	if(M.IntrinsicPartMechID(part_id))
		M << "That intrinsic part is already assigned to another mech."
		return FALSE
	if(!MechBayPay(M, R)) return FALSE
	var/before = R.MechHullMax()
	var/owner_id = M.IntrinsicOwnerID()
	var/token = MechIntrinsicNewID(R)
	var/claim_key = MechIntrinsicClaimKey(owner_id, part_id)
	MechIntrinsicClaims[claim_key] = list("mech_id" = R.IntrinsicMechID(), "token" = token)
	if(!MechIntrinsicSaveClaims())
		MechIntrinsicClaims -= claim_key
		M << "The assignment could not be saved; installation cancelled."
		return FALSE
	if(!islist(R.intrinsic_installed)) R.intrinsic_installed = list()
	var/list/state = list()
	var/old_core = R.core_tier
	R.intrinsic_installed["Reactor"] = list(
		"part_id" = part_id,
		"owner_id" = owner_id,
		"token" = token,
		"state" = state,
		"replaces_core" = TRUE
	)
	// ordinary core removed, MechCoreTier() reads the intrinsic one
	R.core_tier = 0

	var/oldmc = MechCoreClassForTier(old_core)
	if(oldmc)
		M.MatLogAdd(oldmc, QUAL_NORMAL, 1)
	try
		P.OnInstall(M, R, state)
	catch(var/exception/E)
		world.log << "Intrinsic [part_id] OnInstall failed: [E]"
	R.MechRefitDone(before)
	if(M.client) M.client.SaveChar()
	M << "You install [P.name] in [R] as its tier [R.MechCoreTier()] core."
	return TRUE

obj/LifeSkills/Station/MechBay/proc/MechBayRemoveIntrinsicReactor(mob/M, obj/Items/Mech/R)
	if(!MechBayValid(M, R) || M.InCombat() || !MechIntrinsicLoadClaims()) return FALSE
	var/list/I = islist(R.intrinsic_installed) ? R.intrinsic_installed["Reactor"] : null
	if(!islist(I) || I["owner_id"] != M.IntrinsicOwnerID()) return FALSE
	var/mc
	var/q
	if(I["replaces_core"])
		var/list/choices = MechBayMaterialChoices(M, TECH_SEL_CORE, null)
		if(!choices.len)
			M << "You need an ordinary core in your Collection Log to replace this reactor."
			return FALSE
		var/pick = Ask(M, "Which ordinary core replaces the intrinsic reactor?", craft_title, null, "pick", choices, 1)
		if(!pick) return FALSE
		var/list/choice = choices[pick]
		if(!islist(choice)) return FALSE
		mc = choice[1]
		q = choice[2]

	// Recheck after the prompt.
	if(!MechBayValid(M, R) || M.InCombat()) return FALSE
	if(!islist(R.intrinsic_installed)) return FALSE
	if(R.intrinsic_installed["Reactor"] != I) return FALSE
	if(I["owner_id"] != M.IntrinsicOwnerID()) return FALSE
	if(I["replaces_core"])
		var/datum/craft_slotreq/S = new
		S.mat_tag = copytext(TECH_SEL_CORE, 5)
		if(!mc || !S.Accepts(mc) || M.MatLogCountQ(mc, q) < 1)
			return FALSE
	if(!MechBayPay(M, R)) return FALSE
	var/before = R.MechHullMax()
	var/key = MechIntrinsicClaimKey(I["owner_id"], I["part_id"])
	var/list/old_claim = MechIntrinsicClaims[key]
	var/valid = R.IntrinsicValid(I)
	if(valid)
		MechIntrinsicClaims -= key
		if(!MechIntrinsicSaveClaims())
			MechIntrinsicClaims[key] = old_claim
			M << "The removal could not be saved; removal cancelled."
			return FALSE
	RegisterMechIntrinsicParts()
	var/datum/mech_intrinsic_part/P = MechIntrinsicParts[I["part_id"]]
	if(P && valid)
		try
			P.OnRemove(M, R, I["state"])
		catch(var/exception/E)
			world.log << "Intrinsic [P.id] OnRemove failed: [E]"
	if(I["replaces_core"])
		LifeConsumeExact(M, mc, q, 1)
		R.core_tier = clamp(LifeMatTier(mc), MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)
	R.intrinsic_installed -= "Reactor"
	R.MechEnsureSkills()
	R.MechRefitDone(before)
	if(M.client)
		M.client.BuildInvPage()
		M.client.SaveChar()
	M << "You remove the intrinsic reactor. [R] now uses a tier [R.MechCoreTier()] ordinary core."
	return TRUE


obj/LifeSkills/Station/MechBay/proc/MechBayIntrinsicAssignments(mob/M)
	if(!M || !CraftReach(M) || M.InCombat() || M.KO || M.Dead) return
	if(!MechIntrinsicLoadClaims()) return
	RegisterMechIntrinsicParts()
	var/list/options = list()
	var/prefix = "[M.IntrinsicOwnerID()]|"
	for(var/key in MechIntrinsicClaims)
		if(copytext(key, 1, length(prefix) + 1) != prefix) continue
		var/part_id = copytext(key, length(prefix) + 1)
		var/datum/mech_intrinsic_part/P = MechIntrinsicParts[part_id]
		options["[P ? P.name : part_id] ([part_id])"] = part_id
	if(!options.len)
		M << "You have no intrinsic part assignments."
		return
	var/choice = Ask(M, "Release an assignment only if its mech is missing. For an existing mech, remove the part normally.", craft_title, null, "pick", options, 1)
	if(!choice || !options[choice]) return
	var/part_id = options[choice]
	var/key = MechIntrinsicClaimKey(M.IntrinsicOwnerID(), part_id)
	var/list/C = MechIntrinsicClaims[key]
	if(!islist(C)) return
	var/token = C["token"]
	var/confirm = Ask(M, "Release this assignment? The old installation will stop working, even if its saved mech returns later.", craft_title, kind = "confirm", b1 = "Release", b2 = "Cancel")
	if(confirm != "Release") return
	if(!M || !CraftReach(M) || M.InCombat() || M.KO || M.Dead) return
	C = MechIntrinsicClaims[key]
	if(!islist(C) || C["token"] != token) return
	for(var/obj/Items/Mech/R in world)
		if(R.intrinsic_mech_id != C["mech_id"])
			continue
		// get_turf() follows the mech through pilots, capsules, and inventories
		// a null result means it only exists inside unloaded/offline saved contents, so you can reclaim this way in case you get grimed
		if(!get_turf(R))
			continue
		M << "That mech is currently deployed or held by an online character. Park it at a bay and remove the intrinsic part normally."
		return
	MechIntrinsicClaims -= key
	if(!MechIntrinsicSaveClaims())
		MechIntrinsicClaims[key] = C
		M << "The assignment could not be released."
		return
	if(M.client) M.client.SaveChar()
	M << "The assignment is released. You can install that intrinsic part again."


obj/Items/var
	intrinsic_template_id
	intrinsic_part_id
	intrinsic_owner_id
	intrinsic_token
	intrinsic_record_key
	tmp/intrinsic_pending = FALSE

obj/Items/proc/IsIntrinsicPart()
	return intrinsic_template_id || intrinsic_part_id

obj/Items/Mech/proc/MechRawPartIn(slot)
	if(!parts || !slot) return null
	var/obj/Items/P = parts[slot]
	return (P && P.loc == src) ? P : null

obj/Items/Mech/proc/IntrinsicPartActive(obj/Items/P)
	if(!P) return FALSE
	if(!P.IsIntrinsicPart()) return TRUE
	if(P.loc != src || !islist(intrinsic_installed)) return FALSE
	var/list/I = intrinsic_installed[P.intrinsic_record_key]
	if(!islist(I) || I["part_id"] != P.intrinsic_part_id || I["token"] != P.intrinsic_token) return FALSE
	if(I["owner_id"] != P.intrinsic_owner_id || !IntrinsicValid(I)) return FALSE
	var/list/slots = I["slots"]
	if(!islist(slots) || !slots.len) return FALSE
	for(var/s in slots)
		if(MechRawPartIn(s) != P) return FALSE
	return TRUE

proc/MechIntrinsicCreate(part_id, mob/M)
	RegisterMechIntrinsicParts()
	var/datum/mech_intrinsic_part/D = MechIntrinsicParts[part_id]
	if(!M || !D || !D.part_type || !M.HasIntrinsicPart(part_id) || M.IntrinsicPartMechID(part_id)) return null
	var/path = D.part_type
	var/obj/Items/P = new path
	P.intrinsic_part_id = part_id
	P.intrinsic_owner_id = M.IntrinsicOwnerID()
	P.intrinsic_pending = TRUE
	P.Grabbable = 0
	P.Savable = 1
	return P

obj/Items/Mech/proc/IntrinsicCanRemove(obj/Items/P, mob/M)
	if(!P || !M || mounted || intrinsic_refitting) return FALSE
	return !P.IsIntrinsicPart() || P.intrinsic_owner_id == M.IntrinsicOwnerID()

obj/Items/Mech/proc/IntrinsicFitError(obj/Items/P, slot, mob/M)
	if(!M || mounted || intrinsic_refitting) return "The mech cannot be refitted now."
	var/error = MechPartFits(P, slot)
	if(error) return error
	if(P.IsIntrinsicPart())
		RegisterMechIntrinsicParts()
		var/datum/mech_intrinsic_part/D = MechIntrinsicParts[P.intrinsic_part_id]
		if(!D || P.type != D.part_type || P.intrinsic_template_id != D.id || !P.intrinsic_pending || P.loc)
			return "That intrinsic part is not a new installation."
		if(P.intrinsic_owner_id != M.IntrinsicOwnerID() || !M.HasIntrinsicPart(D.id) || M.IntrinsicPartMechID(D.id))
			return "That intrinsic part is locked or already assigned."
	else if(P.loc != M)
		return "You must carry the crafted part."
	for(var/s in MechPartSlotsFor(P, slot))
		var/obj/Items/old = MechRawPartIn(s)
		if(old && !IntrinsicCanRemove(old, M)) return "Only the installer can remove the intrinsic part in [s]."
	return null

// release only THIS lease
obj/Items/Mech/proc/IntrinsicReleaseClaim(obj/Items/P)
	var/list/I = intrinsic_installed ? intrinsic_installed[P.intrinsic_record_key] : null
	if(IntrinsicValid(I))
		MechIntrinsicClaims -= MechIntrinsicClaimKey(I["owner_id"], I["part_id"])


obj/Items/Mech/proc/IntrinsicDetach(obj/Items/P, mob/M, was_active)
	var/list/I = intrinsic_installed ? intrinsic_installed[P.intrinsic_record_key] : null
	if(parts)
		for(var/s in parts.Copy())
			if(parts[s] == P) parts -= s
	if(islist(I))
		var/datum/mech_intrinsic_part/D = MechIntrinsicParts[I["part_id"]]
		intrinsic_installed -= P.intrinsic_record_key
		if(D && was_active)
			try
				D.OnRemove(M, src, I["state"])
			catch(var/exception/E)
				world.log << "Intrinsic removal hook failed: [E]"
	del P

obj/Items/Mech/proc/IntrinsicFit(obj/Items/P, slot, mob/M)
	var/error = IntrinsicFitError(P, slot, M)
	if(error)
		if(M) M << error
		return FALSE
	if(!MechIntrinsicLoadClaims()) return FALSE
	intrinsic_refitting = TRUE
	var/list/need = MechPartSlotsFor(P, slot)
	var/list/old_parts = list()
	var/list/active_parts = list()
	for(var/s in need)
		var/obj/Items/old = MechRawPartIn(s)
		if(old && !(old in old_parts))
			old_parts += old
			if(old.IsIntrinsicPart() && IntrinsicPartActive(old)) active_parts += old
	var/list/claims_before = MechIntrinsicClaims.Copy()
	for(var/obj/Items/old in old_parts)
		if(old.IsIntrinsicPart()) IntrinsicReleaseClaim(old)
	var/token
	if(P.IsIntrinsicPart())
		token = MechIntrinsicNewID(P)
		MechIntrinsicClaims[MechIntrinsicClaimKey(P.intrinsic_owner_id, P.intrinsic_part_id)] = list("mech_id" = IntrinsicMechID(), "token" = token)
	if(!MechIntrinsicSaveClaims())
		MechIntrinsicClaims = claims_before
		intrinsic_refitting = FALSE
		M << "Could not save the assignment. No parts were changed."
		return FALSE
	for(var/obj/Items/old in old_parts)
		if(old.IsIntrinsicPart())
			IntrinsicDetach(old, M, old in active_parts)
		else
			MechUnfit(old, M)
	if(!parts) parts = list()
	P.suffix = null
	P.loc = src
	for(var/s in need) parts[s] = P
	if(P.IsIntrinsicPart())
		P.intrinsic_pending = FALSE
		P.intrinsic_token = token
		P.intrinsic_record_key = "Part:[token]"
		if(!intrinsic_installed) intrinsic_installed = list()
		var/list/state = list()
		intrinsic_installed[P.intrinsic_record_key] = list("part_id" = P.intrinsic_part_id, "owner_id" = P.intrinsic_owner_id, "token" = token, "slot" = slot, "slots" = need.Copy(), "state" = state)
		var/datum/mech_intrinsic_part/D = MechIntrinsicParts[P.intrinsic_part_id]
		try
			D.OnInstall(M, src, state)
		catch(var/exception/E)
			world.log << "Intrinsic installation hook failed: [E]"
	intrinsic_refitting = FALSE
	return TRUE

obj/Items/Mech/proc/IntrinsicUnfit(obj/Items/P, mob/M)
	if(!IntrinsicCanRemove(P, M) || P.loc != src || !MechIntrinsicLoadClaims()) return FALSE
	intrinsic_refitting = TRUE
	var/was_active = IntrinsicPartActive(P)
	var/list/claims_before = MechIntrinsicClaims.Copy()
	IntrinsicReleaseClaim(P)
	if(!MechIntrinsicSaveClaims())
		MechIntrinsicClaims = claims_before
		intrinsic_refitting = FALSE
		return FALSE
	IntrinsicDetach(P, M, was_active)
	intrinsic_refitting = FALSE
	return TRUE

obj/Items/Mech/proc/MechCoreTier()
	var/list/I = islist(intrinsic_installed) ? intrinsic_installed["Reactor"] : null
	if(islist(I) && I["replaces_core"])
		RegisterMechIntrinsicParts()
		var/datum/mech_intrinsic_part/P = MechIntrinsicParts[I["part_id"]]
		if(P && IntrinsicValid(I))
			return clamp(P.core_tier, MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)

		return MECH_CORE_TIER_MIN
	return clamp(core_tier, MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)

obj/Items/Mech/proc/MechCoreOnline()
	var/list/I = islist(intrinsic_installed) ? intrinsic_installed["Reactor"] : null
	if(islist(I) && I["replaces_core"])
		RegisterMechIntrinsicParts()
		var/datum/mech_intrinsic_part/P = MechIntrinsicParts[I["part_id"]]
		if(!P || P.slot_family != "Reactor")
			return FALSE
		return IntrinsicValid(I)
	return core_tier >= MECH_CORE_TIER_MIN


proc/MechCraftIntrinsicID(value)
	var/prefix = "intrinsic_core:"
	if(!istext(value) || findtext(value, prefix) != 1) return null
	return copytext(value, length(prefix) + 1)

proc/MechCraftIntrinsicError(mob/M, datum/craft_recipe/lifecraft/R, i, value)
	var/part_id = MechCraftIntrinsicID(value)
	if(!part_id) return "Invalid intrinsic core."

	if(!M || !istype(R, /datum/craft_recipe/lifecraft/tech/wearable/mech))
		return "Intrinsic cores can only be used to assemble mechs."

	if(!R.slots || i < 1 || i > R.slots.len)
		return "Invalid ingredient slot."

	var/datum/craft_slotreq/S = R.slots[i]
	if(S.name != "Core")
		return "An intrinsic reactor only fits the Core ingredient slot."

	RegisterMechIntrinsicParts()

	var/datum/mech_intrinsic_part/P = MechIntrinsicParts[part_id]
	if(!P || P.slot_family != "Reactor")
		return "That intrinsic reactor does not exist."

	if(!M.HasIntrinsicPart(part_id))
		return "You have not unlocked [P.name]."

	if(clamp(P.core_tier, MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX) < S.min_tier)
		return "[P.name] does not meet the required core tier."

	if(M.IntrinsicPartMechID(part_id))
		return "[P.name] is already assigned, or assignments are unavailable."

	return null

proc/MechCraftIntrinsicLabel(value)
	RegisterMechIntrinsicParts()
	var/datum/mech_intrinsic_part/P = MechIntrinsicParts[MechCraftIntrinsicID(value)]
	if(!P) return "Unavailable intrinsic reactor"
	return "[P.name] - intrinsic tier [clamp(P.core_tier, MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)] core"


mob/var/tmp/list/mech_core_build

mob/proc/MechCraftReserveCore(datum/craft_recipe/lifecraft/R, list/picks)
	if(mech_core_build) return FALSE

	var/list/p = MechRecipePick(R, picks, "Core")
	if(!islist(p) || !MechCraftIntrinsicID(p[1])) return TRUE

	var/core_slot = 0
	for(var/i = 1 to R.slots.len)
		var/datum/craft_slotreq/S = R.slots[i]
		if(S.name == "Core")
			core_slot = i
			break

	var/error = MechCraftIntrinsicError(src, R, core_slot, p[1])
	if(error)
		src << error
		return FALSE

	if(!MechIntrinsicLoadClaims()) return FALSE

	var/part_id = MechCraftIntrinsicID(p[1])
	var/owner_id = IntrinsicOwnerID()
	var/mech_id = MechIntrinsicNewID(src)
	var/token = MechIntrinsicNewID(R)
	var/key = MechIntrinsicClaimKey(owner_id, part_id)

	var/list/build = list(
		"part_id" = part_id,
		"owner_id" = owner_id,
		"mech_id" = mech_id,
		"token" = token
	)

	MechIntrinsicClaims[key] = list("mech_id" = mech_id, "token" = token)

	if(!MechIntrinsicSaveClaims())
		MechIntrinsicClaims -= key
		src << "The intrinsic assignment could not be saved."
		return FALSE

	mech_core_build = build
	return TRUE

mob/proc/MechCraftAttachCore(obj/Items/Mech/R, part_id)
	var/list/B = mech_core_build
	if(!R || !islist(B) || B["part_id"] != part_id) return FALSE

	var/key = MechIntrinsicClaimKey(B["owner_id"], B["part_id"])
	var/list/C = MechIntrinsicClaims[key]
	if(!islist(C) || C["mech_id"] != B["mech_id"] || C["token"] != B["token"])
		return FALSE

	R.intrinsic_mech_id = B["mech_id"]
	R.core_tier = 0

	if(!islist(R.intrinsic_installed))
		R.intrinsic_installed = list()

	R.intrinsic_installed["Reactor"] = list(
		"part_id" = B["part_id"],
		"owner_id" = B["owner_id"],
		"token" = B["token"],
		"state" = list(),
		"replaces_core" = TRUE
	)

	B["result"] = R
	return TRUE

mob/proc/MechCraftFinishCore(obj/Items/made)
	var/list/B = mech_core_build
	mech_core_build = null
	if(!islist(B)) return

	// assembly successful keeps reservation
	if(made && made == B["result"])
		if(client) client.SaveChar()
		return

	// failed assembled releases only particular reservation
	var/key = MechIntrinsicClaimKey(B["owner_id"], B["part_id"])
	var/list/C = MechIntrinsicClaims[key]
	if(!islist(C) || C["mech_id"] != B["mech_id"] || C["token"] != B["token"])
		return

	MechIntrinsicClaims -= key

	if(!MechIntrinsicSaveClaims())
		MechIntrinsicClaims[key] = C
		src << "The failed assembly's intrinsic reservation could not be released. Check the server log before using assignment recovery."

datum/mech_intrinsic_part/proc/CraftCoreTier()
	return clamp(core_tier, MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)

obj/var/energy_heat_source = FALSE

obj/proc/IsEnergyHeatSource()
	if(energy_heat_source) return TRUE

	if(istype(src, /obj/Items/Gun))
		var/obj/Items/Gun/G = src
		return G.energy_gun

	return FALSE


obj/Items/Mech/proc/IntrinsicPilotRefusal(mob/M) // can't board mechs you don't have the intrinsic knowledge for special parts of
	if(!M) return "There is no pilot."

	RegisterMechIntrinsicParts()
	var/list/required = list()

	if(islist(intrinsic_installed))
		for(var/key in intrinsic_installed)
			var/list/I = intrinsic_installed[key]
			if(!islist(I)) continue

			var/part_id = I["part_id"]
			if(part_id && !(part_id in required))
				required += part_id

	for(var/slot in parts)
		var/obj/Items/P = MechRawPartIn(slot)
		if(!P || !P.IsIntrinsicPart()) continue

		var/part_id = P.intrinsic_part_id
		if(!part_id) part_id = P.intrinsic_template_id

		if(part_id && !(part_id in required))
			required += part_id

	var/list/missing = list()
	for(var/part_id in required)
		if(M.HasIntrinsicPart(part_id)) continue

		var/datum/mech_intrinsic_part/D = MechIntrinsicParts[part_id]
		missing += D ? D.name : part_id

	if(missing.len)
		return "You cannot pilot [src]. You must unlock: [jointext(missing, ", ")]."

	return null