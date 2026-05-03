/mob/proc/DemonInParty(dname)
	if(!demon_party) return FALSE
	for(var/datum/party_demon/pd in demon_party)
		if(pd.demon_name == dname) return TRUE
	return FALSE

/mob/proc/DemonUIBusy()
	if(demon_inherit_open)     return TRUE
	if(demon_fusion_animating) return TRUE
	if(demon_pending_fuse_result && demon_pending_fuse_result != "") return TRUE
	return FALSE

/mob/proc/DevilSummonerBlocked()
	if(src.KO)
		src << "You cannot command demons while you are knocked out."
		return TRUE
	if(src.Dead)
		src << "You cannot command demons while you are dead."
		return TRUE
	return FALSE

/mob/proc/DemonPotentialLevel()
	return max(0, floor(max(0, Potential)))

/mob/proc/DemonTooHighLevel(dname)
	var/datum/demon_data/dd = DEMON_DB[dname]
	if(!dd) return FALSE
	return dd.demon_lvl > DemonPotentialLevel()

/mob/proc/DemonIsFusionLocked(dname)
	if(DEMON_SPECIAL_FUSIONS)
		for(var/result in DEMON_SPECIAL_FUSIONS)
			if(result == dname) return TRUE
	return FALSE

/mob/proc/DemonIsElemental(dname)
	var/datum/demon_data/dd = DEMON_DB[dname]
	if(!dd) return FALSE
	var/r = dd.demon_race
	return (r == "Erthys" || r == "Aeros" || r == "Aquans" || r == "Flaemis")

/mob/proc/DemonEligibleForPick(dname)
	var/datum/demon_data/dd = DEMON_DB[dname]
	if(!dd) return FALSE
	if(dd.demon_unique) return FALSE
	if(DemonIsFusionLocked(dname)) return FALSE
	if(DemonIsElemental(dname)) return FALSE
	if(dd.demon_lvl > DemonPotentialLevel()) return FALSE
	return TRUE

/mob/proc/DevilSummonerRestoreVerbs()
	if(Saga != "Devil Summoner") return
	if(SagaLevel >= 1)
		src.verbs += /mob/proc/verb_SummonDemon
		src.verbs += /mob/proc/verb_UnsummonDemon
		src.verbs += /mob/proc/verb_CallDemon
		src.verbs += /mob/proc/verb_DemonSkillManager
	if(SagaLevel >= 2)
		src.verbs += /mob/proc/verb_RecordDemon
		src.verbs += /mob/proc/verb_OpenCompendium
		src.verbs += /mob/proc/verb_SenseDemons
	if(SagaLevel >= 3)
		src.verbs += /mob/proc/verb_OpenFusion
	if(!demon_party) demon_party = list()
	if(!demon_compendium) demon_compendium = list()
	demon_active = null
	demon_active_name = ""
	demon_summon_cooldown = 0
	demon_call_cooldown = 0

	demon_fusion_open = FALSE
	demon_compendium_open = FALSE
	demon_record_open = FALSE
	demon_withdraw_open = FALSE
	demon_inherit_open = FALSE
	demon_fusion_animating = FALSE
	demon_fusion_anim_images = null
	demon_skilllearn_open = FALSE

	demon_pending_fuse_a = ""
	demon_pending_fuse_b = ""
	demon_pending_fuse_result = ""
	demon_pending_fuse_base_skills = null
	demon_pending_fuse_pool = null
	demon_pending_fuse_open_slots = 0

	for(var/datum/party_demon/pd in demon_party)
		if(!pd.demon_skills || !pd.demon_skills.len)
			var/datum/demon_data/dd = DEMON_DB[pd.demon_name]
			if(dd && dd.demon_skills) pd.demon_skills = dd.demon_skills.Copy()
		if(!pd.passives)
			var/datum/demon_data/dd2 = DEMON_DB[pd.demon_name]
			pd.passives = (dd2 && dd2.demon_passives) ? dd2.demon_passives.Copy() : list()
		if(!pd.pending_skills) pd.pending_skills = list()
		if(!pd.pending_passives) pd.pending_passives = list()
		pd.skill_cooldowns = list()

	if(SagaLevel >= 2)
		DevilSummonerCheckPickThreshold(silent = TRUE)
		if(demon_pending_picks > 0)
			src << "<font color='#c8a8ff'>You have <b>[demon_pending_picks]</b> unclaimed demon pick(s). Meditate and use <b>Sense Demons</b> to choose.</font>"

/mob/proc/DevilSummonerLogout()
	if(Saga != "Devil Summoner") return
	if(SagaLevel >= 4)
		RemoveDemonRacialPassive()
	ClearDemonSkillHUD()

	if(demon_fusion_animating)
		DemonFusionAnimAbort()

	demon_fusion_open = FALSE
	demon_compendium_open = FALSE
	demon_record_open = FALSE
	demon_withdraw_open = FALSE
	demon_inherit_open = FALSE

	demon_pending_fuse_a = ""
	demon_pending_fuse_b = ""
	demon_pending_fuse_result = ""
	demon_pending_fuse_base_skills = null
	demon_pending_fuse_pool = null
	demon_pending_fuse_open_slots = 0

	if(demon_active)
		var/mob/Player/AI/Demon/d = demon_active
		if(d)
			for(var/datum/party_demon/pd in demon_party)
				if(pd.demon_name == d.name)
					pd.current_hp = d.demon_hp
					break
			// Revert owner-targeted passive grants
			d.RemoveDemonPassives()
			ai_followers -= d
			d.ai_owner = null
			del(d)
		demon_active = null
		demon_active_name = ""


/mob/proc/verb_UnsummonDemon()
	set name     = "Unsummon Demon"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return
	if(!demon_active)
		src << "You have no demon summoned."
		return


	if(SagaLevel >= 4)
		RemoveDemonRacialPassive()
	ClearDemonSkillHUD()
	var/mob/Player/AI/Demon/d = demon_active
	if(d)
		for(var/datum/party_demon/pd in demon_party)
			if(pd.demon_name == demon_active_name)
				pd.current_hp = d.demon_hp
				break
		d.RemoveDemonPassives()
		d.ai_owner = null
		animate(d, alpha=0, time=8)
		spawn(8)
			ai_followers -= d
			del(d)
	demon_active      = null
	demon_active_name = ""
	src << "You unsummon your demon."

/mob/proc/verb_SummonDemon()
	set name     = "Summon Demon"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return

	if(DemonUIBusy())
		src << "Close your current Demon menu before summoning."
		return

	if(!demon_party || !demon_party.len)
		src << "You have no demons in your party."
		return

	if(world.time < demon_summon_cooldown)
		var/remaining = round((demon_summon_cooldown - world.time) / 10)
		src << "Summon Demon is on cooldown. ([remaining]s remaining)"
		return

	RefreshDemonSummonWindow()
	winshow(src, "DemonSummonWindow", TRUE)


/mob/proc/verb_CallDemon()
	set name     = "Call Demon"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return

	if(!demon_active)
		src << "You have no demon currently summoned."
		return

	if(world.time < demon_call_cooldown)
		var/remaining = round((demon_call_cooldown - world.time) / 10)
		src << "Call Demon is on cooldown. ([remaining]s remaining)"
		return

	var/mob/Player/AI/Demon/d = demon_active
	if(d)
		d.loc = locate(src.x, src.y, src.z)
		src << "You call [d.name] to your side."
		demon_call_cooldown = world.time + 150  // 15 seconds

/mob/proc/verb_RecordDemon()
	set name     = "Record Demon"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return

	if(SagaLevel < 2)
		src << "Unlock Tier 2 of Devil Summoner to access the Compendium."
		return

	if(demon_active)
		src << "Unsummon your demon before accessing the Compendium."
		return

	if(DemonUIBusy())
		src << "Close your current Demon menu first."
		return

	OpenRecordDemonUI()

/mob/proc/verb_OpenCompendium()
	set name     = "Compendium"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return

	if(SagaLevel < 2)
		src << "Unlock Tier 2 of Devil Summoner to access the Compendium."
		return

	if(demon_active)
		src << "Unsummon your demon before accessing the Compendium."
		return

	if(DemonUIBusy())
		src << "Close your current Demon menu first."
		return

	OpenCompendiumUI()

/mob/proc/verb_OpenFusion()
	set name     = "Fuse Demons"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return

	if(SagaLevel < 3)
		src << "Unlock Tier 3 of Devil Summoner to access Fusion."
		return

	if(demon_active)
		src << "Unsummon your demon before fusing."
		return

	if(DemonUIBusy())
		src << "Close your current Demon menu first."
		return

	OpenFusionUI()

/mob/proc/verb_SenseDemons()
	set name     = "Sense Demons"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return

	if(SagaLevel < 2)
		src << "Unlock Tier 2 of Devil Summoner to sense wandering demons."
		return

	if(demon_active)
		src << "Unsummon your demon before choosing a new one."
		return

	if(DemonUIBusy())
		src << "Close your current Demon menu first."
		return

	if(demon_sensing)
		return   // dialog already open; ignore the extra click silently

	DevilSummonerCheckPickThreshold(silent = TRUE)

	if(!demon_pending_picks || demon_pending_picks <= 0)
		src << "No demons are offering themselves to you right now. Continue growing in Potential."
		return

	OfferDevilSummonerPick()


/mob/proc/verb_DemonSkillManager()
	set name     = "Demon Skills"
	set category = "Devil Summoner"

	if(DevilSummonerBlocked()) return
	if(SagaLevel < 1)
		src << "Unlock Devil Summoner to manage demon skills."
		return
	if(DemonUIBusy())
		src << "Close your current Demon menu first."
		return
	if(!demon_party || !demon_party.len)
		src << "You have no demons in your party."
		return

	var/datum/party_demon/target_pd = null
	for(var/datum/party_demon/pd in demon_party)
		if((pd.pending_skills && pd.pending_skills.len) || (pd.pending_passives && pd.pending_passives.len))
			target_pd = pd
			break

	if(!target_pd)
		// No pending learns - allow browsing all party demons via input
		var/list/options = list()
		for(var/datum/party_demon/pd in demon_party)
			options["[pd.demon_name] (Lv[pd.demon_potential])"] = pd.demon_name
		var/choice = input(src, "Pick a demon to view their skills:", "Demon Skills") as null|anything in options
		if(!choice) return
		var/picked = options[choice]
		for(var/datum/party_demon/pd in demon_party)
			if(pd.demon_name == picked)
				target_pd = pd
				break
		if(!target_pd) return

	ShowDemonSkillManagerUI(target_pd)


/mob/proc/DemonSummonFromParty(demon_name)
	if(DevilSummonerBlocked()) return
	if(DemonUIBusy())
		src << "Complete or cancel your current Demon action first."
		winshow(src, "DemonSummonWindow", FALSE)
		return

	var/datum/party_demon/pd = null
	for(var/datum/party_demon/p in demon_party)
		if(p.demon_name == demon_name)
			pd = p
			break
	if(!pd)
		src << "That demon is not in your party."
		return

	if(pd.current_hp <= 0)
		src << "[demon_name]'s HP is depleted. Meditate to restore them."
		return

	if(demon_active)
		if(SagaLevel >= 4)
			RemoveDemonRacialPassive()
		ClearDemonSkillHUD()
		var/mob/Player/AI/Demon/old = demon_active
		if(old)
			// Save HP back to party before switching
			for(var/datum/party_demon/old_pd in demon_party)
				if(old_pd.demon_name == old.name)
					old_pd.current_hp = old.demon_hp
					break
			// Revert owner-targeted passive
			old.RemoveDemonPassives()
			old.ai_owner = null // Stop AI loop immediately
			animate(old, alpha=0, time=8)
			spawn(8) del(old)
		ai_followers -= demon_active
		demon_active = null
		demon_active_name = ""

	var/datum/demon_data/dd = DEMON_DB[demon_name]
	if(!dd) return

	if(!pd.demon_skills || !pd.demon_skills.len)
		pd.demon_skills = dd.demon_skills.Copy()
	if(!pd.skill_cooldowns)
		pd.skill_cooldowns = list()

	var/mob/Player/AI/Demon/d = new
	ticking_ai.Remove(d)
	d.alpha = 0
	d.loc = locate(src.x, src.y, src.z)
	animate(d, alpha=255, time=10)
	d.DemonInit(dd, src, pd)
	d.demon_hp = pd.current_hp  // restore HP

	demon_active      = d
	demon_active_name = demon_name

	src << "You summon <b>[demon_name]</b>!"
	demon_summon_cooldown = world.time + 600  // 60s

	// Tier 4+ racial passive
	if(SagaLevel >= 4 && dd.demon_race)
		ApplyDemonRacialPassive(dd.demon_race)

	BuildDemonSkillHUD(pd)

/mob/proc/DemonUnsummon()
	if(!demon_active) return
	if(SagaLevel >= 4)
		RemoveDemonRacialPassive()
	ClearDemonSkillHUD()
	var/mob/Player/AI/Demon/d = demon_active
	if(d)
		for(var/datum/party_demon/pd in demon_party)
			if(pd.demon_name == demon_active_name)
				pd.current_hp = d.demon_hp
				break
		// Undo all owner-targeted passive grants
		d.RemoveDemonPassives()
		d.ai_owner = null // Stop AI loop immediately
		animate(d, alpha=0, time=8)
		spawn(8)
			ai_followers -= d
			del(d)
	demon_active      = null
	demon_active_name = ""
	src << "You unsummon your demon."
	demon_summon_cooldown = world.time + 600  // 60s


/mob/proc/ExecuteFusion(name_a, name_b)
	if(DevilSummonerBlocked()) return
	if(DemonUIBusy())
		return

	var/datum/party_demon/pd_a = null
	var/datum/party_demon/pd_b = null
	for(var/datum/party_demon/pd in demon_party)
		if(pd.demon_name == name_a) pd_a = pd
		if(pd.demon_name == name_b) pd_b = pd
	if(!pd_a || !pd_b)
		src << "One or both demons are no longer in your party."
		return

	if(pd_a.current_hp <= 0)
		src << "<b>[name_a]</b> is defeated. Meditate to restore them before fusing."
		return
	if(pd_b.current_hp <= 0)
		src << "<b>[name_b]</b> is defeated. Meditate to restore them before fusing."
		return

	var/result_name = GetFusionResultByLevel(name_a, pd_a.demon_potential,
	                                          name_b, pd_b.demon_potential)
	if(!result_name || copytext(result_name, 1, 10) == "_ELEMENT_")
		// Element fusion
		if(result_name && copytext(result_name, 1, 10) == "_ELEMENT_")
			ExecuteElementFusion(name_a, name_b, result_name)
		else
			src << "That fusion is not possible."
		return

	if(DEMON_SPECIAL_FUSIONS && (result_name in DEMON_SPECIAL_FUSIONS) && SagaLevel < 7)
		src << "<font color='#ff6666'>Special fusion requires <b>Tier 7</b>.</font>"
		return

	if(DemonTooHighLevel(result_name))
		src << "<font color='#ff6666'>You are not yet strong enough to command that demon.</font>"
		return

	if(DemonInParty(result_name))
		src << "[result_name] is already in your party. You cannot have duplicates."
		return

	var/confirm = alert(src, "Fuse [name_a] and [name_b] to create [result_name]? Both original demons will be lost.", "Confirm Fusion", "Fuse", "Cancel")
	if(confirm != "Fuse") return

	if(!DemonInParty(name_a) || !DemonInParty(name_b)) return

	var/datum/demon_data/result_dd = DEMON_DB[result_name]
	if(!result_dd)
		src << "Error: result demon [result_name] not found in database."
		return

	// Check if skill inheritance is possible
	var/list/base_skills = result_dd.demon_skills.Copy()
	var/open_slots = 4 - base_skills.len

	pd_a = null
	pd_b = null
	for(var/datum/party_demon/pd in demon_party)
		if(pd.demon_name == name_a) pd_a = pd
		if(pd.demon_name == name_b) pd_b = pd
	if(!pd_a || !pd_b) return

	if(open_slots > 0)
		var/list/parent_pool = list()
		if(pd_a.demon_skills)
			for(var/s in pd_a.demon_skills)
				if(s && s != "None" && !(s in base_skills) && !(s in parent_pool) && !(s in DEMON_UNIQUE_SKILLS))
					parent_pool += s
		if(pd_b.demon_skills)
			for(var/s in pd_b.demon_skills)
				if(s && s != "None" && !(s in base_skills) && !(s in parent_pool) && !(s in DEMON_UNIQUE_SKILLS))
					parent_pool += s

		if(parent_pool.len > 0)
			// Show skill inheritance UI - fusion completes from Topic handler
			demon_pending_fuse_a = name_a
			demon_pending_fuse_b = name_b
			demon_pending_fuse_result = result_name
			demon_pending_fuse_base_skills = base_skills
			demon_pending_fuse_pool = parent_pool
			demon_pending_fuse_open_slots = open_slots
			ShowSkillInheritanceUI(result_name, base_skills, parent_pool, open_slots)
			return

	// No inheritance needed
	FinishFusion(name_a, name_b, result_name, list())

/mob/proc/FinishFusion(name_a, name_b, result_name, list/inherited_skills)
	if(!DemonInParty(name_a) || !DemonInParty(name_b))
		src << "<font color='#ff6666'>Fusion cancelled: one or both ingredients are no longer in your party.</font>"
		demon_pending_fuse_a = ""
		demon_pending_fuse_b = ""
		demon_pending_fuse_result = ""
		demon_pending_fuse_base_skills = null
		demon_pending_fuse_pool = null
		demon_pending_fuse_open_slots = 0
		demon_inherit_open = FALSE
		return

	if(DemonInParty(result_name))
		src << "<font color='#ff6666'>Fusion cancelled: [result_name] is already in your party.</font>"
		demon_pending_fuse_a = ""
		demon_pending_fuse_b = ""
		demon_pending_fuse_result = ""
		demon_pending_fuse_base_skills = null
		demon_pending_fuse_pool = null
		demon_pending_fuse_open_slots = 0
		demon_inherit_open = FALSE
		return

	if(demon_active_name == name_a || demon_active_name == name_b)
		DemonUnsummon()

	src << browse(null, "window=DemonFusion")
	demon_fusion_open = FALSE
	src << browse(null, "window=DemonInherit")
	demon_inherit_open = FALSE
	demon_pending_fuse_a = ""
	demon_pending_fuse_b = ""
	demon_pending_fuse_result = ""
	demon_pending_fuse_base_skills = null
	demon_pending_fuse_pool = null
	demon_pending_fuse_open_slots = 0

	PlayDemonFusionAnimation(name_a, name_b, result_name, inherited_skills)

/mob/proc/FinalizeFusion(name_a, name_b, result_name, list/inherited_skills)
	if(!DemonInParty(name_a) || !DemonInParty(name_b))
		src << "<font color='#ff6666'>Fusion cancelled: one or both ingredients are no longer in your party.</font>"
		return
	if(DemonInParty(result_name))
		src << "<font color='#ff6666'>Fusion cancelled: [result_name] is already in your party.</font>"
		return

	// Remove ingredients from party
	var/plen = length(demon_party)
	for(var/i = plen, i >= 1, i--)
		var/datum/party_demon/pd = demon_party[i]
		if(pd.demon_name == name_a || pd.demon_name == name_b)
			demon_party.Remove(pd)
			del(pd)

	var/datum/demon_data/result_dd = DEMON_DB[result_name]
	if(!result_dd)
		src << "Error: result demon [result_name] not found in database."
		return

	var/datum/party_demon/result_pd = new /datum/party_demon()
	result_pd.demon_name  = result_name
	result_pd.party_level = result_dd.demon_lvl
	result_pd.demon_potential = result_dd.demon_lvl
	result_pd.current_hp  = 100
	result_pd.demon_skills = result_dd.demon_skills.Copy()
	result_pd.passives = result_dd.demon_passives ? result_dd.demon_passives.Copy() : list()
	result_pd.pending_skills = list()
	result_pd.pending_passives = list()
	result_pd.highest_scaled_lvl = result_dd.demon_lvl
	if(inherited_skills && inherited_skills.len)
		for(var/s in inherited_skills)
			if(result_pd.demon_skills.len < 4 && !(s in result_pd.demon_skills))
				result_pd.demon_skills += s
	result_pd.skill_cooldowns = list()
	demon_party += result_pd

	src << "<b>Fusion successful!</b> [name_a] and [name_b] combined into <b>[result_name]</b>!"
	if(inherited_skills && inherited_skills.len)
		src << "<i>[result_name] inherited: [jointext(inherited_skills, ", ")]</i>"

	if(demon_party.len >= 2) OpenFusionUI()

// Element fusion path
/mob/proc/ExecuteElementFusion(name_a, name_b, encoded_result)
	if(DevilSummonerBlocked()) return
	if(SagaLevel < 6)
		src << "<font color='#ff6666'>Element fusion requires <b>Tier 6</b>.</font>"
		return
	var/parts = splittext(encoded_result, "_")
	var/element_race = parts[3]
	var/shift_up = (element_race == "Aquans" || element_race == "Aeros")
	var/target_demon = name_a

	for(var/datum/party_demon/pd in demon_party)
		if(pd.demon_name == name_a && pd.current_hp <= 0)
			src << "<b>[name_a]</b> is defeated. Meditate to restore them before fusing."
			return
		if(pd.demon_name == name_b && pd.current_hp <= 0)
			src << "<b>[name_b]</b> is defeated. Meditate to restore them before fusing."
			return

	var/result_name = GetElementFusionResult(element_race, target_demon, shift_up)
	if(!result_name)
		src << "No valid Element fusion result found."
		return

	if(DemonTooHighLevel(result_name))
		src << "<font color='#ff6666'>You are not yet strong enough to command that demon. (Requires a higher Potential Level. You have [DemonPotentialLevel()].)</font>"
		return

	// Duplicate check
	if(DemonInParty(result_name))
		src << "[result_name] is already in your party. You cannot have duplicates."
		return

	var/confirm = alert(src, "Element Fusion: [target_demon] -> [result_name]? [name_b] (the element) will be consumed.", "Confirm Fusion", "Fuse", "Cancel")
	if(confirm != "Fuse") return

	// Re-validate
	if(!DemonInParty(name_a) || !DemonInParty(name_b)) return

	// Get the non-element demon's skills for inheritance
	var/datum/party_demon/pd_target = null
	for(var/datum/party_demon/pd in demon_party)
		if(pd.demon_name == name_a) pd_target = pd

	if(demon_active_name == name_a || demon_active_name == name_b) DemonUnsummon()

	var/elen = length(demon_party)
	for(var/i = elen, i >= 1, i--)
		var/datum/party_demon/pd = demon_party[i]
		if(pd.demon_name == name_a || pd.demon_name == name_b)
			demon_party.Remove(pd)
			del(pd)

	var/datum/demon_data/result_dd = DEMON_DB[result_name]
	if(!result_dd) return

	var/datum/party_demon/result_pd = new /datum/party_demon()
	result_pd.demon_name  = result_name
	result_pd.party_level = result_dd.demon_lvl
	result_pd.demon_potential = result_dd.demon_lvl
	result_pd.current_hp  = 100
	result_pd.demon_skills = result_dd.demon_skills.Copy()
	result_pd.passives = result_dd.demon_passives ? result_dd.demon_passives.Copy() : list()
	result_pd.pending_skills = list()
	result_pd.pending_passives = list()
	result_pd.highest_scaled_lvl = result_dd.demon_lvl
	// Carry over non-element parent's inherited skills to open slots
	if(pd_target && pd_target.demon_skills)
		for(var/s in pd_target.demon_skills)
			if(result_pd.demon_skills.len >= 4) break
			if(s && s != "None" && !(s in result_pd.demon_skills))
				result_pd.demon_skills += s
	result_pd.skill_cooldowns = list()
	demon_party += result_pd

	src << "<b>Element Fusion!</b> [name_a] became <b>[result_name]</b>!"
	src << browse(null, "window=DemonFusion")
	demon_fusion_open = FALSE


/mob/proc/ExecuteWithdraw(demon_name, level_choice)
	if(DevilSummonerBlocked()) return
	if(DemonUIBusy())
		src << "Complete or cancel your current Demon action first."
		return
	if(!demon_compendium || !(demon_name in demon_compendium)) return
	var/datum/compendium_demon/cd = demon_compendium[demon_name]
	var/datum/demon_data/dd = DEMON_DB[demon_name]
	if(!dd) return

	// Duplicate check
	if(DemonInParty(demon_name))
		src << "[demon_name] is already in your party."
		return

	if(demon_party && demon_party.len >= demon_party_cap)
		src << "Your party is full."
		return

	var/chosen_level = cd.base_level
	var/cost = cd.base_level * 500

	if(level_choice == "recorded")
		chosen_level = cd.demon_potential
		cost = cd.demon_potential * 500

	if(!HasFragments(cost))
		src << "Insufficient Mana Bits. You need [cost] to withdraw [demon_name]."
		return
	TakeFragments(cost)
	src << "Spent [cost] Mana Bits."

	var/datum/party_demon/pd = new /datum/party_demon()
	pd.demon_name  = demon_name
	pd.party_level = chosen_level
	pd.demon_potential = chosen_level
	pd.current_hp  = 100
	// Set skills based on withdrawal type
	if(level_choice == "recorded" && cd.recorded_skills && cd.recorded_skills.len)
		pd.demon_skills = cd.recorded_skills.Copy()
	else
		pd.demon_skills = dd.demon_skills.Copy()
	if(level_choice == "recorded" && cd.recorded_passives && cd.recorded_passives.len)
		pd.passives = cd.recorded_passives.Copy()
	else
		pd.passives = dd.demon_passives ? dd.demon_passives.Copy() : list()
	pd.pending_skills = list()
	pd.pending_passives = list()
	pd.highest_scaled_lvl = max(dd.demon_lvl, cd.highest_scaled_lvl)
	pd.skill_cooldowns = list()
	demon_party += pd

	src << "[demon_name] added to your party at level [chosen_level]."
	src << browse(null, "window=DemonWithdraw")
	demon_withdraw_open = FALSE
	OpenCompendiumUI()


/mob/proc/ExecuteRecordDemon(demon_name)
	if(DevilSummonerBlocked()) return
	var/datum/party_demon/pd = null
	for(var/datum/party_demon/p in demon_party)
		if(p.demon_name == demon_name) { pd = p; break }
	if(!pd) return

	var/datum/demon_data/dd = DEMON_DB[demon_name]
	if(!dd) return

	if(!demon_compendium) demon_compendium = list()

	// Overwrite confirmation if already recorded
	if(demon_name in demon_compendium)
		var/confirm = alert(src, "[demon_name] is already recorded. Overwrite the recorded version?", "Confirm Overwrite", "Overwrite", "Cancel")
		if(confirm != "Overwrite")
			demon_record_open = FALSE
			return

	var/datum/compendium_demon/cd
	if(demon_name in demon_compendium)
		cd = demon_compendium[demon_name]
	else
		cd = new /datum/compendium_demon()
		cd.demon_name = demon_name
		cd.base_level = dd.demon_lvl

	cd.recorded_level = pd.demon_potential
	cd.demon_potential = pd.demon_potential
	// Snapshot current skills
	if(pd.demon_skills && pd.demon_skills.len)
		cd.recorded_skills = pd.demon_skills.Copy()
	else
		cd.recorded_skills = dd.demon_skills.Copy()
	if(pd.passives && pd.passives.len)
		cd.recorded_passives = pd.passives.Copy()
	else
		cd.recorded_passives = dd.demon_passives ? dd.demon_passives.Copy() : list()
	cd.highest_scaled_lvl = max(cd.highest_scaled_lvl, pd.highest_scaled_lvl)
	demon_compendium[demon_name] = cd

	src << "<b>[demon_name]</b> has been recorded in your compendium."
	if(cd.recorded_level > cd.base_level)
		src << "Recorded at Level [cd.recorded_level] (base: [cd.base_level]). Higher withdrawal costs Mana Bits."
	if(cd.recorded_skills.len > dd.demon_skills.len)
		src << "Skills recorded: [jointext(cd.recorded_skills, ", ")]"
	src << browse(null, "window=DemonRecord")
	demon_record_open = FALSE


/mob/proc/DemonMeditateCheck()
	if(Saga != "Devil Summoner") return
	if(icon_state == "Meditate")
		if(!demon_meditate_start)
			demon_meditate_start = world.time
			demon_meditate_healed = FALSE
			if(SagaLevel >= 2)
				var/granted = DevilSummonerCheckPickThreshold()
				if(!granted && demon_pending_picks > 0)
					src << "<font color='#c8a8ff'>You still have <b>[demon_pending_picks]</b> unclaimed demon pick(s). Use <b>Sense Demons</b> to choose.</font>"
		else if(!demon_meditate_healed && (world.time - demon_meditate_start) >= 150)
			var/any_healed = FALSE
			if(demon_party)
				for(var/datum/party_demon/pd in demon_party)
					if(pd.current_hp < 100)
						pd.current_hp = 100
						any_healed = TRUE
			if(demon_active)
				var/mob/Player/AI/Demon/d = demon_active
				if(d) d.demon_hp = 100
			if(any_healed)
				src << "<b>Your demons have been restored.</b>"
			demon_meditate_healed = TRUE
			DemonScanLearnable()
	else
		demon_meditate_start   = 0
		demon_meditate_healed  = FALSE

/mob/proc/DemonScanLearnable()
	if(!demon_party || !demon_party.len) return
	var/any_pending = FALSE
	for(var/datum/party_demon/pd in demon_party)
		var/datum/demon_data/dd = DEMON_DB[pd.demon_name]
		if(!dd) continue
		var/demon_lvl = clamp(pd.demon_potential, 1, 100)
		if(demon_lvl > pd.highest_scaled_lvl) pd.highest_scaled_lvl = demon_lvl

		// Check active learn list
		if(dd.demon_skill_learn)
			for(var/skill_name in dd.demon_skill_learn)
				var/learn_lvl = dd.demon_skill_learn[skill_name]
				if(demon_lvl < learn_lvl) continue
				if(skill_name in pd.demon_skills) continue
				if(pd.pending_skills && (skill_name in pd.pending_skills)) continue
				if(!pd.pending_skills) pd.pending_skills = list()
				pd.pending_skills += skill_name
				any_pending = TRUE

		// Check passive learn list
		if(dd.demon_passive_learn)
			for(var/p_name in dd.demon_passive_learn)
				var/learn_lvl = dd.demon_passive_learn[p_name]
				if(demon_lvl < learn_lvl) continue
				if(pd.passives && (p_name in pd.passives)) continue
				if(pd.pending_passives && (p_name in pd.pending_passives)) continue
				if(!pd.pending_passives) pd.pending_passives = list()
				pd.pending_passives += p_name
				any_pending = TRUE

	if(any_pending)
		DemonAutoLearn()

/mob/proc/DemonAutoLearn()
	if(!demon_party) return
	for(var/datum/party_demon/pd in demon_party)
		// Active skills
		if(pd.pending_skills && pd.pending_skills.len)
			var/list/to_learn = pd.pending_skills.Copy()
			for(var/skill_name in to_learn)
				if(pd.demon_skills && (skill_name in pd.demon_skills))
					pd.pending_skills -= skill_name
					continue
				if(pd.demon_skills && pd.demon_skills.len == 1 && pd.demon_skills[1] == "None")
					pd.demon_skills.Cut()
				if(pd.demon_skills && pd.demon_skills.len >= 4)
					src << "<font color='#c8a8ff'>[pd.demon_name] can learn <b>[skill_name]</b> but has no open skill slots. Use Demon Skills to manage them.</font>"
					continue
				if(!pd.demon_skills) pd.demon_skills = list()
				pd.demon_skills += skill_name
				pd.pending_skills -= skill_name
				src << "<font color='#80ff80'><b>[pd.demon_name] learned [skill_name]!</b></font>"
				if(demon_active && demon_active_name == pd.demon_name)
					var/mob/Player/AI/Demon/d = demon_active
					d.active_skills = pd.demon_skills.Copy()

		// Passives
		if(pd.pending_passives && pd.pending_passives.len)
			var/list/to_learn_p = pd.pending_passives.Copy()
			for(var/p_name in to_learn_p)
				if(pd.passives && (p_name in pd.passives))
					pd.pending_passives -= p_name
					continue
				if(!pd.passives) pd.passives = list()
				if(pd.passives.len >= 4)
					src << "<font color='#c8a8ff'>[pd.demon_name] can learn <b>[p_name]</b> but has no open passive slots. Use Demon Skills to manage them.</font>"
					continue
				pd.passives += p_name
				pd.pending_passives -= p_name
				src << "<font color='#cc80ff'><b>[pd.demon_name] learned the passive [p_name]!</b></font>"
				if(demon_active && demon_active_name == pd.demon_name)
					var/mob/Player/AI/Demon/d = demon_active
					d.RemoveDemonPassives()
					d.ApplyDemonPassives()


/mob/proc/AddDemonToRoster(dname)
	var/datum/demon_data/dd = DEMON_DB[dname]
	if(!dd) return
	if(!demon_party) demon_party = list()
	if(!demon_compendium) demon_compendium = list()

	// Duplicate check
	if(DemonInParty(dname))
		src << "<b>[dname]</b> is already in your party."
		return

	if(demon_party.len < demon_party_cap)
		var/datum/party_demon/pd = new /datum/party_demon()
		pd.demon_name  = dname
		pd.party_level = dd.demon_lvl
		pd.demon_potential = dd.demon_lvl
		pd.current_hp  = 100
		pd.demon_skills = dd.demon_skills.Copy()
		pd.passives = dd.demon_passives ? dd.demon_passives.Copy() : list()
		pd.skill_cooldowns = list()
		pd.pending_skills = list()
		pd.pending_passives = list()
		pd.highest_scaled_lvl = dd.demon_lvl
		demon_party += pd
		src << "<b>[dname]</b> has joined your party."
	else
		if(!(dname in demon_compendium))
			var/datum/compendium_demon/cd = new /datum/compendium_demon()
			cd.demon_name     = dname
			cd.base_level     = dd.demon_lvl
			cd.recorded_level = dd.demon_lvl
			cd.recorded_skills = dd.demon_skills.Copy()
			cd.recorded_passives = dd.demon_passives ? dd.demon_passives.Copy() : list()
			cd.highest_scaled_lvl = dd.demon_lvl
			demon_compendium[dname] = cd
			src << "<b>[dname]</b> has been added to your Compendium (party full)."
		else
			src << "<b>[dname]</b> is already recorded in your Compendium."

/mob/proc/GrantStarterDemons(tier)
	// Tier 1 only: choose two demons of level 1-5 to start your roster.
	if(tier != 1) return

	var/min_lvl = 1
	var/max_lvl = 5

	var/list/eligible = list()
	for(var/dname in DEMON_DB)
		var/datum/demon_data/dd = DEMON_DB[dname]
		if(dd.demon_lvl < min_lvl || dd.demon_lvl > max_lvl) continue
		if(dd.demon_unique) continue
		if(DemonIsFusionLocked(dname)) continue
		var/race = dd.demon_race
		if(race == "Erthys" || race == "Aeros" || race == "Aquans" || race == "Flaemis") continue
		eligible.Add(dname)

	if(!eligible.len)
		src << "No eligible demons available for your starter roster."
		return

	src << "<b>Choose 2 demons</b> to add to your starter roster (Level [min_lvl]-[max_lvl])."

	var/list/picked = list()
	for(var/n = 1, n <= 2, n++)
		var/list/options = eligible.Copy()
		for(var/p in picked)
			options -= p
		// Also remove demons already in party
		for(var/datum/party_demon/pd in demon_party)
			options -= pd.demon_name
		if(!options.len) break

		var/choice = input(src, "Choose demon [n] of 2:", "Starter Demon") as null|anything in options
		if(!choice) break
		picked.Add(choice)

	for(var/dname in picked)
		AddDemonToRoster(dname)


/mob/proc/DevilSummonerCheckPickThreshold(silent = FALSE)
	if(Saga != "Devil Summoner") return 0
	if(SagaLevel < 2) return 0
	var/pl = DemonPotentialLevel()
	var/expected_total = round(pl / 5)
	// Normalize in case the saved value is stale
	if(demon_last_pick_potential < 0) demon_last_pick_potential = 0
	var/already_granted = round(demon_last_pick_potential / 5)
	if(expected_total <= already_granted) return 0
	var/new_picks = expected_total - already_granted
	demon_last_pick_potential = expected_total * 5
	demon_pending_picks += new_picks
	if(!silent)
		src << "<font color='#c8a8ff'><b>You sense [new_picks] new demon[new_picks > 1 ? "s" : ""] offering [new_picks > 1 ? "themselves" : "itself"] to you.</b> <i>(Use Sense Demons to choose.)</i></font>"
	return new_picks

/mob/proc/OfferDevilSummonerPick()
	if(!demon_pending_picks || demon_pending_picks <= 0) return
	if(demon_sensing) return   // already inside a pick dialog

	var/list/eligible = list()
	for(var/dname in DEMON_DB)
		if(!DemonEligibleForPick(dname)) continue
		if(DemonInParty(dname)) continue
		eligible.Add(dname)

	if(!eligible.len)
		src << "No eligible demons are currently available to offer. (You may already own all you qualify for.)"
		return

	// Sort by level for readability
	var/elen = length(eligible)
	for(var/a = 1, a <= elen, a++)
		for(var/b = a+1, b <= elen, b++)
			var/datum/demon_data/da = DEMON_DB[eligible[a]]
			var/datum/demon_data/db = DEMON_DB[eligible[b]]
			if(da && db && da.demon_lvl > db.demon_lvl)
				var/tmp_a = eligible[a]
				eligible[a] = eligible[b]
				eligible[b] = tmp_a

	var/list/display_options = list()
	for(var/dname in eligible)
		var/datum/demon_data/dd = DEMON_DB[dname]
		display_options["[dname] (Lv[dd.demon_lvl] [dd.demon_race])"] = dname

	// Consume the pick BEFORE opening the dialog so that any re-entrant
	// calls (spam-clicking while the prompt is open) see 0 picks and bail.
	// We restore it if the player cancels.
	demon_pending_picks = max(0, demon_pending_picks - 1)
	demon_sensing = TRUE

	var/choice = input(src, "Choose a demon to claim: ([demon_pending_picks + 1] pick(s) remaining)", "Sense Demons") as null|anything in display_options

	demon_sensing = FALSE

	if(!choice)
		// Player cancelled — give the pick back
		demon_pending_picks++
		return
	var/picked_name = display_options[choice]
	if(!picked_name)
		demon_pending_picks++
		return

	// Re-validate
	if(!DemonEligibleForPick(picked_name))
		src << "[picked_name] is no longer eligible."
		demon_pending_picks++
		return
	if(DemonInParty(picked_name))
		src << "[picked_name] is already in your party."
		demon_pending_picks++
		return

	AddDemonToRoster(picked_name)


/mob/proc/DemonGetPartyDemonByName(dname)
	if(!demon_party) return null
	for(var/datum/party_demon/pd in demon_party)
		if(pd.demon_name == dname) return pd
	return null

/mob/proc/DemonLearnSkill(dname, skill_name)
	var/datum/party_demon/pd = DemonGetPartyDemonByName(dname)
	if(!pd) return
	if(!pd.pending_skills || !(skill_name in pd.pending_skills))
		src << "[skill_name] is not pending for [dname]."
		return
	// Duplicate guard — should not happen via normal UI but protect against edge cases
	if(pd.demon_skills && (skill_name in pd.demon_skills))
		src << "[dname] already knows [skill_name]."
		pd.pending_skills -= skill_name
		return
	// Strip placeholder "None" entry on first real skill learned
	if(pd.demon_skills && pd.demon_skills.len == 1 && pd.demon_skills[1] == "None")
		pd.demon_skills.Cut()
	if(pd.demon_skills.len >= 4)
		src << "[dname] already knows 4 active skills. Forget one first."
		return
	pd.demon_skills += skill_name
	pd.pending_skills -= skill_name
	src << "<font color='#80ff80'><b>[dname] learned [skill_name]!</b></font>"
	// If this demon is currently summoned, sync the skill list to the AI mob.
	if(demon_active && demon_active_name == dname)
		var/mob/Player/AI/Demon/d = demon_active
		d.active_skills = pd.demon_skills.Copy()
	ShowDemonSkillManagerUI(pd)

/mob/proc/DemonLearnPassive(dname, passive_name)
	var/datum/party_demon/pd = DemonGetPartyDemonByName(dname)
	if(!pd) return
	if(!pd.pending_passives || !(passive_name in pd.pending_passives))
		src << "[passive_name] is not pending for [dname]."
		return
	// Duplicate guard
	if(pd.passives && (passive_name in pd.passives))
		src << "[dname] already has the passive [passive_name]."
		pd.pending_passives -= passive_name
		return
	if(!pd.passives) pd.passives = list()
	if(pd.passives.len >= 4)
		src << "[dname] already knows 4 passives. Forget one first."
		return
	pd.passives += passive_name
	pd.pending_passives -= passive_name
	src << "<font color='#cc80ff'><b>[dname] learned the passive [passive_name]!</b></font>"
	// If summoned, re-apply passives now
	if(demon_active && demon_active_name == dname)
		var/mob/Player/AI/Demon/d = demon_active
		d.RemoveDemonPassives()
		d.ApplyDemonPassives()
	ShowDemonSkillManagerUI(pd)

/mob/proc/DemonDropSkill(dname, skill_name)
	var/datum/party_demon/pd = DemonGetPartyDemonByName(dname)
	if(!pd) return
	if(!pd.demon_skills || !(skill_name in pd.demon_skills))
		src << "[dname] does not know [skill_name]."
		return
	pd.demon_skills -= skill_name
	if(!pd.demon_skills.len) pd.demon_skills = list("None")
	src << "<font color='#aaaaaa'>[dname] forgot [skill_name].</font>"
	if(demon_active && demon_active_name == dname)
		var/mob/Player/AI/Demon/d = demon_active
		d.active_skills = pd.demon_skills.Copy()
	ShowDemonSkillManagerUI(pd)

/mob/proc/DemonDropPassive(dname, passive_name)
	var/datum/party_demon/pd = DemonGetPartyDemonByName(dname)
	if(!pd) return
	if(!pd.passives || !(passive_name in pd.passives))
		src << "[dname] does not have the passive [passive_name]."
		return
	pd.passives -= passive_name
	src << "<font color='#aaaaaa'>[dname] forgot the passive [passive_name].</font>"
	if(demon_active && demon_active_name == dname)
		var/mob/Player/AI/Demon/d = demon_active
		d.RemoveDemonPassives()
		d.ApplyDemonPassives()
	ShowDemonSkillManagerUI(pd)
