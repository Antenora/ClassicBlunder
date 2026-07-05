/proc/DemonPortraitRscName(demon_name)
	var/clean = ""
	var/n = length(demon_name)
	for(var/i = 1, i <= n, i++)
		var/c = copytext(demon_name, i, i + 1)
		var/ascii = text2ascii(c)
		// A-Z, a-z, 0-9 are safe; replace everything else with underscore.
		if((ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122) || (ascii >= 48 && ascii <= 57))
			clean += c
		else
			clean += "_"
	return "dp_[clean].dmi"

/mob/proc/SendDemonPortraitResources(list/dnames)
	if(!client) return
	for(var/dname in dnames)
		var/datum/demon_data/dd = DEMON_DB[dname]
		if(!dd || !dd.demon_portrait2) continue
		src << browse_rsc(dd.demon_portrait2, DemonPortraitRscName(dname))

/proc/DemonPortraitHTML(datum/demon_data/dd, size, mob/viewer)
	if(!dd) return "<div style='width:[size]px;height:[size]px;background:#222;border:1px solid #555;display:inline-block;'></div>"
	if(viewer && viewer.client)
		var/rname = DemonPortraitRscName(dd.demon_name)
		return "<div style='width:[size]px;height:[size]px;overflow:hidden;display:inline-block;vertical-align:middle;line-height:0;'><img src='[rname]' width='[size]' height='[size]'></div>"
	// Fallback when no viewer context: first-letter initial block.
	var/initial = copytext(dd.demon_name, 1, 2)
	return "<div style='width:[size]px;height:[size]px;background:#1a1a2e;border:1px solid #4a2a6e;display:inline-flex;align-items:center;justify-content:center;color:#c8b8ff;font-size:[round(size*0.4)]px;font-weight:bold;'>[initial]</div>"

/proc/SilhouettePortraitHTML(datum/demon_data/dd, size)
	// Black silhouette style for demons the player is too low Potential Level to fuse.
	if(!dd) return "<div style='width:[size]px;height:[size]px;background:#000;border:1px solid #333;display:inline-block;'></div>"
	return "<div style='width:[size]px;height:[size]px;background:#000;border:1px solid #222;display:inline-flex;align-items:center;justify-content:center;color:#111;font-size:[round(size*0.4)]px;font-weight:bold;'>?</div>"

/proc/InvalidPortraitHTML(size)
	return "<div style='width:[size]px;height:[size]px;background:#300;border:2px solid #f00;display:flex;align-items:center;justify-content:center;color:#f44;font-size:[round(size*0.5)]px;font-weight:bold;'>X</div>"

#define DS_STYLE "background:#0a0a0f;color:#c8b8ff;font-family:'Arial',sans-serif;"
#define DS_HEADER_STYLE "background:#1a0a2e;color:#e8d0ff;padding:8px 12px;font-size:14px;font-weight:bold;border-bottom:1px solid #4a2a6e;"
#define DS_BTN_STYLE "background:#2a1a4e;color:#e8d0ff;border:1px solid #6a4a9e;padding:4px 10px;cursor:pointer;text-decoration:none;font-size:11px;"
#define DS_BTN_VALID "background:#1a3a1e;color:#80ff80;border:1px solid #3a8a3e;padding:4px 10px;cursor:pointer;text-decoration:none;font-size:11px;"

/proc/DemonDeadPortraitRscName(demon_name)
	return "dead_[DemonPortraitRscName(demon_name)]"

/mob/proc/RefreshDemonSummonWindow()
	var/party_size = demon_party ? demon_party.len : 0
	for(var/i = 1 to 12)
		var/slot = "DemonSlot_[i]"
		var/label = "DemonSlotName_[i]"
		if(i <= party_size)
			var/datum/party_demon/pd = demon_party[i]
			var/datum/demon_data/dd = DEMON_DB[pd.demon_name]
			if(dd)
				var/is_dead = (pd.current_hp <= 0)
				var/portrait_img
				if(is_dead && dd.demon_portrait)
					var/icon/gi = new icon(dd.demon_portrait)
					gi.GrayScale()
					var/rname = DemonDeadPortraitRscName(pd.demon_name)
					src << browse_rsc(gi, rname)
					portrait_img = rname
				else
					portrait_img = dd.demon_portrait
				winset(src, slot, "image=[portrait_img];is-visible=true")
				if(pd.demon_name == demon_active_name)
					winset(src, slot,  "background-color=#1a4aaa")
					winset(src, label, "text='[pd.demon_name]';text-color=#88bbff;background-color=#0a1a4e;is-visible=true")
				else
					winset(src, slot,  "background-color=#1a1a2e")
					winset(src, label, "text='[pd.demon_name]';text-color=#cccccc;background-color=#111111;is-visible=true")
			else
				winset(src, slot,  "image=;is-visible=false")
				winset(src, label, "text=;is-visible=false")
		else
			winset(src, slot,  "image=;is-visible=false")
			winset(src, label, "text=;is-visible=false")

/mob/verb/DemonSlotClick(index as num)
	set hidden = TRUE
	if(Saga != "Devil Summoner") return
	if(DevilSummonerBlocked()) return
	if(!demon_party || index < 1 || index > demon_party.len) return
	if(world.time < demon_summon_cooldown)
		var/remaining = round((demon_summon_cooldown - world.time) / 10)
		src << "Summon Demon is on cooldown. ([remaining]s remaining)"
		return
	var/datum/party_demon/pd = demon_party[index]
	if(!pd) return

	winshow(src, "DemonSummonWindow", FALSE)

	if(pd.demon_name == demon_active_name)
		DemonUnsummon()
	else
		DemonSummonFromParty(pd.demon_name)

/mob/proc/OpenFusionUI()

	if(!demon_party || demon_party.len < 2)
		src << "You need at least 2 demons in your party to fuse."
		return

	demon_fusion_open = TRUE

	var/list/party_names = list()
	for(var/datum/party_demon/pd in demon_party)
		party_names += pd.demon_name
	SendDemonPortraitResources(party_names)

	var/pl = DemonPotentialLevel()
	var/list/pairs = list()
	for(var/a = 1 to demon_party.len)
		for(var/b = a+1 to demon_party.len)
			var/datum/party_demon/pd_a = demon_party[a]
			var/datum/party_demon/pd_b = demon_party[b]
			var/result = GetFusionResultByLevel(pd_a.demon_name, pd_a.demon_potential,
			                                    pd_b.demon_name, pd_b.demon_potential)
			// Check if result is element or special fusion
			var/is_element = result && copytext(result, 1, 10) == "_ELEMENT_"
			var/is_special = result && !is_element && DEMON_SPECIAL_FUSIONS && (result in DEMON_SPECIAL_FUSIONS)
			var/valid = result && !is_element && (!is_special || SagaLevel >= 7)
			if(is_element && SagaLevel >= 6) valid = TRUE

			var/too_high = FALSE
			if(result && !is_element)
				var/datum/demon_data/rdd = DEMON_DB[result]
				if(rdd && rdd.demon_lvl > pl)
					too_high = TRUE
					valid = FALSE

			var/td_locked = FALSE
			if(result && !is_element && !IsFusionResultAllowed(result))
				td_locked = TRUE
				valid = FALSE

			var/in_party = FALSE
			if(result && !is_element && DemonInParty(result))
				in_party = TRUE
				valid = FALSE

			pairs += list(list(
				"a"            = pd_a.demon_name,
				"b"            = pd_b.demon_name,
				"result"       = result,
				"valid"        = valid,
				"element"      = is_element,
				"too_high"     = too_high,
				"td_locked" = td_locked,
				"in_party"     = in_party
			))

	var/list/valid_pairs    = list()
	var/list/high_pairs     = list()
	var/list/td_pairs       = list()
	var/list/inparty_pairs  = list()
	var/list/invalid_pairs  = list()
	for(var/entry in pairs)
		if(entry["valid"])             valid_pairs   += list(entry)
		else if(entry["too_high"])     high_pairs    += list(entry)
		else if(entry["td_locked"])    td_pairs      += list(entry)
		else if(entry["in_party"])     inparty_pairs += list(entry)
		else                           invalid_pairs += list(entry)
	SortFusionPairsByLevel(valid_pairs)
	SortFusionPairsByLevel(high_pairs)
	SortFusionPairsByLevel(td_pairs)
	SortFusionPairsByLevel(inparty_pairs)
	pairs = valid_pairs + high_pairs + td_pairs + inparty_pairs + invalid_pairs

	demon_fusion_page = max(1, min(demon_fusion_page, ceil(pairs.len / 5)))

	var/list/result_names = list()
	for(var/list/pr in pairs)
		var/res = pr["result"]
		if(!res) continue
		if(pr["element"]) continue
		var/needs_resource = pr["valid"] || pr["in_party"]
		if(!needs_resource) continue
		if(!(res in result_names))
			result_names += res
	SendDemonPortraitResources(result_names)

	src << browse(BuildFusionHTML(pairs, demon_fusion_page, src), "window=DemonFusion;size=440,460")

/proc/BuildFusionHTML(list/pairs, page, mob/viewer)
	var/total_pages = max(1, ceil(pairs.len / 5))
	var/page_start  = (page - 1) * 5 + 1
	var/page_end    = min(page_start + 4, pairs.len)

	var/html = "<html><head><style>"
	html += "body {[DS_STYLE] margin:0; padding:0;}"
	html += ".header {[DS_HEADER_STYLE]}"
	html += ".row {display:flex;align-items:center;border-bottom:1px solid #2a1a4e;padding:6px 8px;gap:8px;}"
	html += ".dname {font-size:10px;color:#9a88cc;text-align:center;width:40px;}"
	html += ".plus {font-size:20px;color:#6a4a9e;margin:0 4px;}"
	html += ".eq {font-size:20px;color:#6a4a9e;margin:0 4px;}"
	html += ".fuseBtn {[DS_BTN_VALID] margin-left:auto;}"
	html += ".pager {display:flex;align-items:center;gap:8px;padding:6px 12px;justify-content:flex-end;}"
	html += ".pagerBtn {[DS_BTN_STYLE]}"
	html += "</style></head><body data-src='\ref[world]' onunload=\"var s=document.body.getAttribute('data-src');window.location='byond://?src='+s+';demon_window_close=fusion';\">"

	html += "<div class='header'>FUSION LABORATORY &nbsp;&nbsp; Page [page] / [total_pages]</div>"

	for(var/i = page_start, i <= page_end, i++)
		var/list/pair = pairs[i]
		var/name_a       = pair["a"]
		var/name_b       = pair["b"]
		var/result       = pair["result"]
		var/valid        = pair["valid"]
		var/element      = pair["element"]
		var/too_high     = pair["too_high"]
		var/td_locked = pair["td_locked"]
		var/in_party     = pair["in_party"]

		var/datum/demon_data/da = DEMON_DB[name_a]
		var/datum/demon_data/db = DEMON_DB[name_b]
		var/datum/party_demon/pda = viewer ? viewer.DemonGetPartyDemonByName(name_a) : null
		var/datum/party_demon/pdb = viewer ? viewer.DemonGetPartyDemonByName(name_b) : null
		var/lvl_a = pda ? pda.demon_potential : (da ? da.demon_lvl : 0)
		var/lvl_b = pdb ? pdb.demon_potential : (db ? db.demon_lvl : 0)

		html += "<div class='row'>"

		html += "<div>"
		html += DemonPortraitHTML(da, 32, viewer)
		html += "<div class='dname'>[name_a]<br><span style='color:#7a6aaa;'>[da ? da.demon_race : "?"] Lv[lvl_a]</span></div>"
		html += "</div>"

		html += "<div class='plus'>+</div>"

		html += "<div>"
		html += DemonPortraitHTML(db, 32, viewer)
		html += "<div class='dname'>[name_b]<br><span style='color:#7a6aaa;'>[db ? db.demon_race : "?"] Lv[lvl_b]</span></div>"
		html += "</div>"

		html += "<div class='eq'>=</div>"

		if(valid)
			var/result_clean = result
			if(element)
				var/list/eparts = splittext(result, "_")
				var/erace = eparts.len >= 3 ? eparts[3] : ""
				var/eshift = (erace == "Aquans" || erace == "Aeros")
				result_clean = GetElementFusionResult(erace, name_a, eshift)
			var/datum/demon_data/dr = DEMON_DB[result_clean]
			html += "<div>"
			html += DemonPortraitHTML(dr, 32, viewer)
			html += "<div class='dname'>[result_clean ? result_clean : "?"]<br>"
			if(dr) html += "<span style='color:#7a6aaa;'>[dr.demon_race] Lv[dr.demon_lvl]</span>"
			html += "</div></div>"
			html += "<a class='fuseBtn' href='byond://?src=\ref[world];demon_fuse_a=[name_a];demon_fuse_b=[name_b]'>FUSE</a>"
		else if(too_high && result)
			// Show the silhouette + clickable FUSE so the player can be told why
			var/datum/demon_data/dr = DEMON_DB[result]
			html += "<div>"
			html += SilhouettePortraitHTML(dr, 32)
			html += "<div class='dname' style='color:#333333;'>???<br>"
			if(dr) html += "<span style='color:#444444;'>[dr.demon_race] Lv[dr.demon_lvl]</span>"
			html += "</div></div>"
			html += "<a class='fuseBtn' style='background:#1a0a0a;color:#884444;border:1px solid #663333;' href='byond://?src=\ref[world];demon_fuse_a=[name_a];demon_fuse_b=[name_b]'>FUSE</a>"
		else if(td_locked && result)
			var/datum/demon_data/dr = DEMON_DB[result]
			html += "<div>"
			html += SilhouettePortraitHTML(dr, 32)
			html += "<div class='dname' style='color:#5a3030;' title='Requires the True Demon path'>???<br>"
			if(dr) html += "<span style='color:#7a4040;'>[dr.demon_race]</span>"
			html += "</div></div>"
			html += "<div class='fuseBtn' style='background:#1a0a0a;color:#a04040;border:1px solid #663333;cursor:default;' title='Requires the True Demon path'>True Demon</div>"
		else if(in_party && result)
			// Result demon is already in the party -- can't have duplicates.
			var/datum/demon_data/dr = DEMON_DB[result]
			html += "<div>"
			html += DemonPortraitHTML(dr, 32, viewer)
			html += "<div class='dname' style='color:#666666;'>[result]<br>"
			if(dr) html += "<span style='color:#556655;'>[dr.demon_race] Lv[dr.demon_lvl]</span>"
			html += "</div></div>"
			html += "<div class='fuseBtn' style='background:#1a1a1a;color:#667766;border:1px solid #445544;cursor:default;'>In Party</div>"
		else
			html += "<div>[InvalidPortraitHTML(32)]<div class='dname' style='color:#663333;'>Invalid</div></div>"

		html += "</div>"  // end row

	// Pagination
	html += "<div class='pager'>"
	if(page > 1)
		html += "<a class='pagerBtn' href='byond://?src=\ref[world];demon_fusion_page=[page-1]'>&lt; Prev</a>"
	html += "<span style='color:#9a88cc;'>Page [page] / [total_pages]</span>"
	if(page < total_pages)
		html += "<a class='pagerBtn' href='byond://?src=\ref[world];demon_fusion_page=[page+1]'>Next &gt;</a>"
	html += "</div>"

	html += "</body></html>"
	return html

/mob/proc/ShowSkillInheritanceUI(result_name, list/base_skills, list/pool, max_picks)
	if(demon_inherit_open) return
	demon_inherit_open = TRUE
	SendDemonPortraitResources(list(result_name))

	var/datum/demon_data/dd = DEMON_DB[result_name]

	var/html = "<html><head><style>"
	html += "body {[DS_STYLE] margin:8px;}"
	html += ".header {[DS_HEADER_STYLE] margin:-8px -8px 8px -8px;}"
	html += ".section {margin:8px 0;}"
	html += ".skill-tag {display:inline-block;padding:3px 8px;margin:2px;border-radius:3px;font-size:11px;}"
	html += ".innate {background:#1a1a4e;color:#8888cc;border:1px solid #4444aa;}"
	html += ".pick {background:#1a3a1e;color:#80ff80;border:1px solid #3a8a3e;cursor:pointer;text-decoration:none;}"
	html += ".pick:hover {background:#2a5a2e;}"
	html += ".picked {background:#3a6a3e;color:#ffffff;border:2px solid #80ff80;}"
	html += ".confirmBtn {[DS_BTN_VALID] display:block;margin-top:12px;padding:8px 16px;font-size:13px;text-align:center;}"
	html += ".skipBtn {[DS_BTN_STYLE] display:block;margin-top:6px;padding:6px 12px;font-size:11px;text-align:center;}"
	html += "</style>"

	html += "<script>"
	html += "var maxPicks = [max_picks];"
	html += "var picked = {};"
	html += "function toggleSkill(name) {"
	html += "  if(picked\[name\]) { delete picked\[name\]; }"
	html += "  else { if(Object.keys(picked).length >= maxPicks) return; picked\[name\] = true; }"
	html += "  var els = document.querySelectorAll('.pick');"
	html += "  for(var i=0;i<els.length;i++) {"
	html += "    var el = els\[i\]; if(picked\[el.getAttribute('data-skill')\]) el.className='skill-tag picked';"
	html += "    else el.className='skill-tag pick';"
	html += "  }"
	html += "}"
	html += "function confirmInherit() {"
	html += "  var bsrc = document.body.getAttribute('data-src');"
	html += "  var skills = Object.keys(picked).join(',');"
	html += "  window.location = 'byond://?src=' + bsrc + ';demon_inherit_confirm=' + encodeURIComponent(skills);"
	html += "}"
	html += "function skipInherit() {"
	html += "  var bsrc = document.body.getAttribute('data-src');"
	html += "  window.location = 'byond://?src=' + bsrc + ';demon_inherit_confirm=';"
	html += "}"
	html += "</script></head><body data-src='\ref[world]' onunload=\"var s=document.body.getAttribute('data-src');window.location='byond://?src='+s+';demon_window_close=inherit';\">"

	html += "<div class='header'>SKILL INHERITANCE -- [result_name]</div>"

	html += DemonPortraitHTML(dd, 32, src)

	html += "<div class='section'><b style='color:#8888cc;'>Innate Skills:</b><br>"
	for(var/s in base_skills)
		html += "<span class='skill-tag innate'>[s]</span>"
	html += "</div>"

	html += "<div class='section'><b style='color:#80ff80;'>Choose up to [max_picks] skill(s) to inherit:</b><br>"
	for(var/s in pool)
		html += "<span class='skill-tag pick' data-skill='[s]' onclick='toggleSkill(\"[s]\")'>[s]</span>"
	html += "</div>"

	html += "<a class='confirmBtn' href='#' onclick='confirmInherit();return false;'>CONFIRM INHERITANCE</a>"
	html += "<a class='skipBtn' href='#' onclick='skipInherit();return false;'>Skip (No Inheritance)</a>"

	html += "</body></html>"
	src << browse(html, "window=DemonInherit;size=360,400")


/mob/proc/ShowDemonSkillManagerUI(datum/party_demon/pd)
	if(!pd) return
	demon_skilllearn_open = TRUE
	demon_skilllearn_target = pd.demon_name

	var/datum/demon_data/dd = DEMON_DB[pd.demon_name]
	if(!dd) return

	SendDemonPortraitResources(list(pd.demon_name))

	var/list/cur_skills = pd.demon_skills ? pd.demon_skills.Copy() : list()
	if(cur_skills.len == 1 && cur_skills[1] == "None") cur_skills = list()
	var/list/cur_passives = pd.passives ? pd.passives.Copy() : list()
	var/list/pending_skills = pd.pending_skills ? pd.pending_skills.Copy() : list()
	var/list/pending_passives = pd.pending_passives ? pd.pending_passives.Copy() : list()

	var/demon_lvl = clamp(pd.demon_potential, 1, 100)

	var/html = "<html><head><style>"
	html += "body {[DS_STYLE] margin:8px;}"
	html += ".header {[DS_HEADER_STYLE] margin:-8px -8px 8px -8px;}"
	html += ".section {margin:8px 0;}"
	html += ".skill-tag {display:inline-block;padding:3px 8px;margin:2px;border-radius:3px;font-size:11px;}"
	html += ".active {background:#1a1a4e;color:#8888cc;border:1px solid #4444aa;}"
	html += ".passive {background:#1a3a4e;color:#88ccdd;border:1px solid #4477aa;}"
	html += ".learn-active {background:#1a3a1e;color:#80ff80;border:1px solid #3a8a3e;}"
	html += ".learn-passive {background:#3a1a3e;color:#cc80ff;border:1px solid #6a3a6e;}"
	html += ".btn {[DS_BTN_STYLE] display:inline-block;margin:2px;padding:4px 10px;font-size:10px;text-decoration:none;}"
	html += ".btn-good {[DS_BTN_VALID] display:inline-block;margin:2px;padding:4px 10px;font-size:10px;text-decoration:none;}"
	html += ".meta {color:#7a6aaa;font-size:10px;}"
	html += "</style></head><body data-src='\ref[world]' onunload=\"var s=document.body.getAttribute('data-src');window.location='byond://?src='+s+';demon_window_close=skilllearn';\">"

	html += "<div class='header'>[pd.demon_name] -- Skills</div>"
	html += DemonPortraitHTML(dd, 32, src)
	html += "<div class='meta'>[dd.demon_race] | Base Lv [dd.demon_lvl] | Lv [demon_lvl]</div>"

	html += "<div class='section'><b style='color:#8888cc;'>Active Skills ([cur_skills.len]/4):</b><br>"
	if(cur_skills.len)
		for(var/s in cur_skills)
			html += "<span class='skill-tag active'>[s]</span>"
			html += " <a class='btn' href='byond://?src=\ref[world];demon_drop_skill=[pd.demon_name]:[s]'>Forget</a> "
	else
		html += "<i>(none)</i>"
	html += "</div>"

	html += "<div class='section'><b style='color:#88ccdd;'>Passive Skills ([cur_passives.len]/4):</b><br>"
	if(cur_passives.len)
		for(var/p in cur_passives)
			html += "<span class='skill-tag passive'>[p]</span>"
			html += " <a class='btn' href='byond://?src=\ref[world];demon_drop_passive=[pd.demon_name]:[p]'>Forget</a> "
	else
		html += "<i>(none)</i>"
	html += "</div>"

	if(pending_skills.len)
		html += "<div class='section'><b style='color:#80ff80;'>Skills ready to learn:</b><br>"
		for(var/s in pending_skills)
			html += "<span class='skill-tag learn-active'>[s]</span>"
			if(cur_skills.len < 4)
				html += " <a class='btn-good' href='byond://?src=\ref[world];demon_learn_skill=[pd.demon_name]:[s]'>Learn</a> "
			else
				html += " <span class='meta'>(forget one first)</span> "
		html += "</div>"

	if(pending_passives.len)
		html += "<div class='section'><b style='color:#cc80ff;'>Passives ready to learn:</b><br>"
		for(var/p in pending_passives)
			html += "<span class='skill-tag learn-passive'>[p]</span>"
			if(cur_passives.len < 4)
				html += " <a class='btn-good' href='byond://?src=\ref[world];demon_learn_passive=[pd.demon_name]:[p]'>Learn</a> "
			else
				html += " <span class='meta'>(forget one first)</span> "
		html += "</div>"

	if(!pending_skills.len && !pending_passives.len)
		html += "<div class='meta'>No new skills available right now. Meditate as your Potential grows to unlock more.</div>"

	html += "<a class='btn' href='byond://?src=\ref[world];demon_skilllearn_close=1' style='display:block;text-align:center;margin-top:8px;'>Close</a>"

	html += "</body></html>"
	src << browse(html, "window=DemonSkillLearn;size=420,460")


/mob/proc/OpenCompendiumUI()
	if(!demon_compendium || !demon_compendium.len)
		src << "Your compendium is empty. Use Record Demon to save a demon."
		return
	demon_compendium_open = TRUE
	// Pre-send portrait resources for every recorded demon.
	var/list/comp_names = list()
	for(var/dname in demon_compendium) comp_names += dname
	SendDemonPortraitResources(comp_names)
	src << browse(BuildCompendiumHTML(src), "window=DemonCompendium;size=480,420")

/proc/BuildCompendiumHTML(mob/player)
	var/html = "<html><head><style>"
	html += "body {[DS_STYLE] margin:0; padding:0;}"
	html += ".header {[DS_HEADER_STYLE]}"
	html += ".grid {display:flex;flex-wrap:wrap;gap:12px;padding:12px;}"
	html += ".card {background:#110820;border:1px solid #3a2a6e;padding:6px;text-align:center;width:52px;cursor:pointer;}"
	html += ".card:hover {border-color:#8a5abe;}"
	html += ".dname {font-size:9px;color:#c8b8ff;margin-top:4px;}"
	html += ".dinfo {font-size:8px;color:#7a6aaa;}"
	html += ".withdrawn {opacity:0.4;}"
	html += "</style></head><body data-src='\ref[world]' onunload=\"var s=document.body.getAttribute('data-src');window.location='byond://?src='+s+';demon_window_close=compendium';\">"
	html += "<div class='header'>COMPENDIUM -- [player.demon_compendium.len] Recorded</div>"
	html += "<div class='grid'>"

	for(var/dname in player.demon_compendium)
		var/datum/compendium_demon/cd = player.demon_compendium[dname]
		var/datum/demon_data/dd = DEMON_DB[dname]
		if(!dd) continue

		var/in_party = player.DemonInParty(dname)

		var/card_class = in_party ? "card withdrawn" : "card"
		var/link = in_party ? "" : "href='byond://?src=\ref[world];demon_withdraw=[dname]'"

		if(in_party)
			html += "<div class='[card_class]'>"
		else
			html += "<a class='[card_class]' [link] style='text-decoration:none;display:block;'>"
		html += DemonPortraitHTML(dd, 32, player)
		html += "<div class='dname'>[dname]</div>"
		html += "<div class='dinfo'>[dd.demon_race] Lv[dd.demon_lvl]</div>"
		if(cd.recorded_level > cd.base_level)
			html += "<div class='dinfo' style='color:#c8a840;'>* Recorded Lv[cd.recorded_level]</div>"
		// Show recorded skills count if they have extra skills
		if(cd.recorded_skills && cd.recorded_skills.len > dd.demon_skills.len)
			html += "<div class='dinfo' style='color:#80ff80;'>[cd.recorded_skills.len] skills</div>"
		if(in_party)
			html += "<div class='dinfo' style='color:#446644;'>\[In Party\]</div>"
		if(in_party)
			html += "</div>"
		else
			html += "</a>"

	html += "</div></body></html>"
	return html


/mob/proc/OpenWithdrawPopup(demon_name)
	if(DemonUIBusy()) return
	if(!demon_compendium || !(demon_name in demon_compendium)) return
	var/datum/compendium_demon/cd = demon_compendium[demon_name]
	var/datum/demon_data/dd = DEMON_DB[demon_name]
	if(!dd) return

	// Duplicate check
	if(DemonInParty(demon_name))
		src << "[demon_name] is already in your party."
		return

	// Check party space
	var/cap = demon_party_cap
	if(demon_party && demon_party.len >= cap)
		src << "Your party is full ([cap] demons). Release a demon first."
		return

	demon_withdraw_open = TRUE
	SendDemonPortraitResources(list(demon_name))

	var/base_cost     = cd.base_level * 250
	var/recorded_cost = cd.recorded_level * 250
	var/has_recorded = (cd.recorded_skills && cd.recorded_skills.len)

	var/html = "<html><head><style>body{[DS_STYLE]margin:8px;}</style></head><body data-src='\ref[world]' onunload=\"var s=document.body.getAttribute('data-src');window.location='byond://?src='+s+';demon_window_close=withdraw';\">"
	html += "<b style='font-size:14px;color:#e8d0ff;'>[demon_name]</b><br>"
	html += "<i style='color:#9a88cc;'>[dd.demon_race] -- Base Lv[cd.base_level]</i><br><br>"
	html += DemonPortraitHTML(dd, 32, src)
	html += "<br><br>"

	// Base withdrawal
	html += "<a href='byond://?src=\ref[world];demon_withdraw_confirm=[demon_name];level=base' style='[DS_BTN_STYLE] display:block; margin-bottom:6px;'>Withdraw at Base Lv[cd.base_level] ([base_cost] Mana Bits)</a>"
	html += "<div style='font-size:9px;color:#7a6aaa;margin-bottom:8px;'>Skills: [jointext(dd.demon_skills, ", ")]</div>"

	// Recorded withdrawal (if recorded at higher level or has extra skills)
	if(has_recorded || cd.recorded_level > cd.base_level)
		html += "<a href='byond://?src=\ref[world];demon_withdraw_confirm=[demon_name];level=recorded' style='[DS_BTN_VALID] display:block;'>Withdraw Recorded Lv[cd.recorded_level] ([recorded_cost] Mana Bits)</a>"
		if(has_recorded)
			html += "<div style='font-size:9px;color:#80ff80;margin-top:2px;'>Skills: [jointext(cd.recorded_skills, ", ")]</div>"

	html += "</body></html>"
	src << browse(html, "window=DemonWithdraw;size=240,360")

/mob/proc/OpenRecordDemonUI()
	if(!demon_party || !demon_party.len)
		src << "You have no demons in your party to record."
		return
	demon_record_open = TRUE
	// Pre-send portrait resources for every party demon.
	var/list/record_names = list()
	for(var/datum/party_demon/pd in demon_party) record_names += pd.demon_name
	SendDemonPortraitResources(record_names)
	src << browse(BuildRecordDemonHTML(src), "window=DemonRecord;size=400,280")

/proc/BuildRecordDemonHTML(mob/player)
	var/html = "<html><head><style>"
	html += "body {[DS_STYLE] margin:0; padding:0;}"
	html += ".header {[DS_HEADER_STYLE]}"
	html += ".grid {display:flex;flex-wrap:wrap;gap:12px;padding:12px;}"
	html += ".card {background:#110820;border:1px solid #3a2a6e;padding:6px;text-align:center;width:64px;cursor:pointer;}"
	html += ".card:hover {border-color:#d4a0ff;}"
	html += ".dname {font-size:9px;color:#c8b8ff;margin-top:4px;}"
	html += ".dinfo {font-size:8px;color:#7a6aaa;}"
	html += ".skills {font-size:7px;color:#80ff80;margin-top:2px;}"
	html += "</style></head><body data-src='\ref[world]' onunload=\"var s=document.body.getAttribute('data-src');window.location='byond://?src='+s+';demon_window_close=record';\">"
	html += "<div class='header'>RECORD DEMON -- Choose a demon to save to your compendium</div>"
	html += "<div class='grid'>"

	for(var/datum/party_demon/pd in player.demon_party)
		var/datum/demon_data/dd = DEMON_DB[pd.demon_name]
		if(!dd) continue
		html += "<a class='card' href='byond://?src=\ref[world];demon_record=[pd.demon_name]' style='text-decoration:none;display:block;'>"
		html += DemonPortraitHTML(dd, 32, player)
		html += "<div class='dname'>[pd.demon_name]</div>"
		html += "<div class='dinfo'>[dd.demon_race] Lv[pd.demon_potential]</div>"
		if(pd.demon_skills && pd.demon_skills.len)
			html += "<div class='skills'>[pd.demon_skills.len] skill(s)</div>"
		html += "</a>"

	html += "</div></body></html>"
	return html


/world/Topic(href, href_list, hsrc)
	// usr is set by BYOND to the mob of the client who clicked the link
	var/mob/user = usr
	if(!user || !istype(user, /mob)) return

	// Fusion page navigation
	if(href_list["demon_fusion_page"])
		user.demon_fusion_page = text2num(href_list["demon_fusion_page"])
		user.demon_fusion_open = FALSE
		user.OpenFusionUI()
		return

	// Fuse two demons
	if(href_list["demon_fuse_a"] && href_list["demon_fuse_b"])
		var/name_a = href_list["demon_fuse_a"]
		var/name_b = href_list["demon_fuse_b"]
		user.demon_fusion_open = FALSE
		user.ExecuteFusion(name_a, name_b)
		return

	if("demon_inherit_confirm" in href_list)
		if(user.demon_fusion_animating)
			return
		var/skills_str = href_list["demon_inherit_confirm"]
		var/list/inherited = list()
		if(skills_str && length(skills_str))
			inherited = splittext(skills_str, ",")
		if(user.demon_pending_fuse_result)
			var/list/valid_inherited = list()
			for(var/s in inherited)
				if(s && (s in user.demon_pending_fuse_pool))
					if(valid_inherited.len < user.demon_pending_fuse_open_slots)
						valid_inherited += s
			user.FinishFusion(user.demon_pending_fuse_a, user.demon_pending_fuse_b, user.demon_pending_fuse_result, valid_inherited)
		user.demon_inherit_open = FALSE
		return

	// Open withdrawal popup
	if(href_list["demon_withdraw"])
		user.OpenWithdrawPopup(href_list["demon_withdraw"])
		return

	// Confirm withdrawal
	if(href_list["demon_withdraw_confirm"])
		var/dname = href_list["demon_withdraw_confirm"]
		var/level_choice = href_list["level"]
		user.demon_withdraw_open = FALSE
		user.demon_compendium_open = FALSE
		user.ExecuteWithdraw(dname, level_choice)
		return

	// Record a demon
	if(href_list["demon_record"])
		user.demon_record_open = FALSE
		user.ExecuteRecordDemon(href_list["demon_record"])
		return

	if(href_list["demon_window_close"])
		switch(href_list["demon_window_close"])
			if("fusion")
				user.demon_fusion_open = FALSE
			if("compendium")
				user.demon_compendium_open = FALSE
			if("record")
				user.demon_record_open = FALSE
			if("withdraw")
				user.demon_withdraw_open = FALSE
			if("skilllearn")
				user.demon_skilllearn_open = FALSE
				user.demon_skilllearn_target = ""
			if("inherit")
				user.demon_inherit_open = FALSE
				if(!user.demon_fusion_animating)
					user.demon_pending_fuse_a = ""
					user.demon_pending_fuse_b = ""
					user.demon_pending_fuse_result = ""
					user.demon_pending_fuse_base_skills = null
					user.demon_pending_fuse_pool = null
					user.demon_pending_fuse_open_slots = 0
		return

	if(href_list["demon_skilllearn_close"])
		user << browse(null, "window=DemonSkillLearn")
		user.demon_skilllearn_open = FALSE
		user.demon_skilllearn_target = ""
		return

	if(href_list["demon_learn_skill"])
		var/list/parts = splittext(href_list["demon_learn_skill"], ":")
		if(parts.len >= 2)
			user.DemonLearnSkill(parts[1], parts[2])
		return

	if(href_list["demon_learn_passive"])
		var/list/parts = splittext(href_list["demon_learn_passive"], ":")
		if(parts.len >= 2)
			user.DemonLearnPassive(parts[1], parts[2])
		return

	if(href_list["demon_drop_skill"])
		var/list/parts = splittext(href_list["demon_drop_skill"], ":")
		if(parts.len >= 2)
			user.DemonDropSkill(parts[1], parts[2])
		return

	if(href_list["demon_drop_passive"])
		var/list/parts = splittext(href_list["demon_drop_passive"], ":")
		if(parts.len >= 2)
			user.DemonDropPassive(parts[1], parts[2])
		return

	..()

// Sort a list of fusion pair entries by result demon level, ascending.
// Element fusions (encoded result) sort last within the group.
/proc/SortFusionPairsByLevel(list/pairs)
	if(!pairs || pairs.len < 2) return
	var/n = pairs.len
	for(var/i = 1, i <= n - 1, i++)
		for(var/j = 1, j <= n - i, j++)
			var/list/a = pairs[j]
			var/list/b = pairs[j + 1]
			var/lvl_a = FusionPairResultLevel(a)
			var/lvl_b = FusionPairResultLevel(b)
			if(lvl_a > lvl_b)
				pairs[j]     = b
				pairs[j + 1] = a

/proc/FusionPairResultLevel(list/pair)
	var/res = pair ? pair["result"] : null
	if(!res) return 9999
	// Element fusions sort last
	if(copytext(res, 1, 10) == "_ELEMENT_") return 9999
	var/datum/demon_data/dr = DEMON_DB[res]
	return dr ? dr.demon_lvl : 9999
