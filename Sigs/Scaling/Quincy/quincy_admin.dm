/proc/QuincyOnlineList()
	var/list/out = list()
	for(var/mob/Players/P in players)
		if(P.QuincyIsQuincy())
			out += P
	return out

/mob/proc/QuincyPickTarget(title)
	var/list/pool = QuincyOnlineList()
	if(!pool.len)
		usr << "<font color=red>No Quincy are online.</font>"
		return null
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/choice = Ask(usr, "Which Quincy?", title, null, "pick", lab, 1)
	if(isnull(choice))
		return null
	return lab[choice]

/mob/proc/QuincyFreeRegistry()
	if(glob.QuincyKaiser && glob.QuincyKaiser.len && (glob.QuincyKaiser[1] == src.key || glob.QuincyKaiser[1] == src.ckey))
		glob.QuincyKaiser = list()
	if(glob.SchriftHolders)
		for(var/letter in glob.SchriftHolders.Copy())
			var/list/entry = glob.SchriftHolders[letter]
			if(!islist(entry) || !entry.len)
				continue
			if(entry[1] == src.key || entry[1] == src.ckey)
				glob.SchriftHolders -= letter
				continue
			var/list/kept = list()
			var/changed = 0
			for(var/sub in entry)
				if(islist(sub))
					var/list/s = sub
					if(s.len && (s[1] == src.key || s[1] == src.ckey))
						changed = 1
						continue
				kept += list(sub)
			if(changed)
				if(kept.len)
					glob.SchriftHolders[letter] = kept
				else
					glob.SchriftHolders -= letter

/mob/Admin3/verb/Give_Quincy()
	set category = "Admin"
	set name = "Give Quincy"
	var/list/pool = list()
	for(var/mob/Players/P in players)
		if(P.ckey)
			pool += P
	if(!pool.len)
		usr << "<font color=red>Nobody is online.</font>"
		return
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/pick_label = Ask(usr, "Who awakens as a Quincy?", "Give Quincy", null, "pick", lab, 1)
	if(isnull(pick_label))
		return
	var/mob/Players/P = lab[pick_label]
	if(!P)
		return
	if(P.QuincyIsQuincy())
		usr << "<font color=red>[P] is already a Quincy.</font>"
		return
	if(P.HollowIsHollow())
		usr << "<font color=red>[P] is a Hollow and cannot carry the blood of the Quincy.</font>"
		return
	if(P.Saga)
		usr << "<font color=red>[P] already follows a Saga.</font>"
		return
	if(P.CyberneticMainframe)
		usr << "<font color=red>[P] is a Cybernetic Mainframe.</font>"
		return
	var/weapon = Ask(P, "Your Reishi gathers into a weapon. Which shape does it take? This choice is permanent.", "Spirit Weapon", null, "pick", list("Bow", "Gun", "Sword"), 1)
	if(isnull(weapon))
		usr << "<font color=red>[P] did not choose a weapon. Nothing changes.</font>"
		return
	var/wclass = Ask(P, "Which form does your [lowertext(weapon)] take?", "Spirit Weapon", null, "pick", QuincyWeaponClasses(weapon), 1)
	if(isnull(wclass))
		usr << "<font color=red>[P] did not choose a form. Nothing changes.</font>"
		return
	if(!P || P.QuincyIsQuincy() || P.HollowIsHollow() || P.Saga || P.CyberneticMainframe)
		return
	P.QuincyWeapon = weapon
	P.QuincyWeaponClass = wclass
	P.QuincyLevel = 1
	P.GintoRefillStamp = world.time
	P << "<font color=#9fd8ff>A Quincy Cross settles against your wrist. The Reishi around answers you.</font>"
	P.QuincySyncSkills()
	P.QuincyLevelCheck()
	world << "<font color=#9fd8ff><b>[P] has awakened the blood of the Quincy.</b></font>"
	Log("Admin", "[ExtractInfo(usr)] made [ExtractInfo(P)] a Quincy ([weapon], [wclass]).")

/mob/Admin3/verb/Remove_Quincy()
	set category = "Admin"
	set name = "Remove Quincy"
	var/mob/Players/P = QuincyPickTarget("Remove Quincy")
	if(!P)
		return
	var/confirm = Ask(usr, "Strip [P] of the Quincy signature? Every Quincy skill, letter and seat goes with it.", "Remove Quincy", null, "confirm", null, 1, "Remove", "Cancel")
	if(confirm != "Remove")
		return
	P.QuincyFreeRegistry()
	for(var/T in QuincyManagedSkillTypes())
		var/obj/Skills/S = P.QuincyOwnedSkill(T)
		if(!S)
			continue
		if(istype(S, /obj/Skills/Buffs) && P.BuffOn(S))
			var/obj/Skills/Buffs/B = S
			B.Trigger(P, 1)
		P.DeleteSkill(S)
	P.GunDispel()
	for(var/obj/Items/Gun/Quincy/G in P)
		G.PermEquip = 0
		if(G.suffix)
			G.GunAlignEquip(P)
		del G
	P.QuincyLevel = 0
	P.QuincyWeapon = null
	P.QuincyWeaponClass = null
	P.QuincyGloveMastery = 0
	P.QuincyGloveBroken = 0
	P.QuincyHeritage = null
	P.QuincySchrift = null
	P.QuincyRank = null
	P.QuincyAdminPermission = 0
	P.QuincyVollstandigBlockedUntil = 0
	P.GintoTubes = 0
	P.GintoRefillStamp = 0
	P.QuincyLetztActive = 0
	P.HaloBroken = 0
	if(P.client)
		P.client.RefreshHotbarCharges()
	P << "<font color=yellow>The Reishi no longer answers you.</font>"
	usr << "<font color=yellow>[P] is no longer a Quincy.</font>"
	Log("Admin", "[ExtractInfo(usr)] removed the Quincy signature from [ExtractInfo(P)].")

/mob/Admin3/verb/Set_Quincy_Level()
	set category = "Admin"
	set name = "Set Quincy Level"
	var/mob/Players/P = QuincyPickTarget("Set Quincy Level")
	if(!P)
		return
	var/val = Ask(usr, "Set [P]'s Signature Mastery Level (1 to [QUINCY_LEVEL_MAX]). Current: [P.QuincyLevel].", "Set Quincy Level", "[P.QuincyLevel]", "uint", null, 1)
	if(isnull(val))
		return
	val = clamp(round(val), 1, QUINCY_LEVEL_MAX)
	P.QuincyLevel = val
	if(val > 4)
		P.QuincyGloveBroken = 1
	P.QuincySyncSkills()
	P << "<font color=yellow>An admin has set your Signature Mastery Level to [val].</font>"
	usr << "<font color=yellow>[P] is now at Signature Mastery Level [val].</font>"
	Log("Admin", "[ExtractInfo(usr)] set [ExtractInfo(P)]'s Quincy level to [val].")

/mob/Admin3/verb/Quincy_Report()
	set category = "Admin"
	set name = "Quincy Report"
	var/list/pool = QuincyOnlineList()
	var/list/rows = list()
	for(var/mob/Players/P in pool)
		rows[++rows.len] = list("t" = "[P.key]", "tn" = "[P.name]", "t2" = "Potential [P.Potential]", "c" = list("[P.QuincyLevel]", "[P.QuincyWeapon]", "[P.QuincyWeaponClass]", "[round(P.QuincyGloveMastery)]/[QUINCY_GLOVE_MASTERY]", P.QuincyGloveBroken ? "Yes" : "No", P.QuincyHeritage ? "[P.QuincyHeritage]" : "-", P.QuincySchrift ? "[P.QuincySchrift]" : "-", P.QuincyRank ? "[P.QuincyRank]" : "-"))
	usr.client?.TableShow("quincy:report", "QUINCY", "Quincy online", "[rows.len] online", list(list("l" = "PLAYER", "a" = "l"), list("l" = "LEVEL", "a" = "r"), list("l" = "WEAPON", "a" = "l"), list("l" = "CLASS", "a" = "l"), list("l" = "GLOVE", "a" = "r"), list("l" = "BROKEN", "a" = "l"), list("l" = "HERITAGE", "a" = "l"), list("l" = "LETTER", "a" = "l"), list("l" = "RANK", "a" = "l")), rows, "", null, list("nosort" = 1))
