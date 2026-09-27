/proc/HollowOnlineList()
	var/list/out = list()
	for(var/mob/Players/P in players)
		if(P.HollowIsHollow())
			out += P
	return out

/mob/Admin3/proc/HollowPickTarget(title)
	var/list/pool = HollowOnlineList()
	if(!pool.len)
		usr << "<font color=red>No Hollows are online.</font>"
		return null
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/choice = Ask(usr, "Which Hollow?", title, null, "pick", lab, 1)
	if(isnull(choice))
		return null
	return lab[choice]

/mob/Admin3/verb/Set_Hollow_Stage()
	set category = "Admin"
	set name = "Set Hollow Stage"
	var/mob/Players/P = HollowPickTarget("Set Hollow Stage")
	if(!P)
		return
	var/list/stages = list("Hollow" = HOLLOW_STAGE_BASE, "Menos Grande" = HOLLOW_STAGE_GILLIAN, "Adjuchas" = HOLLOW_STAGE_ADJUCHAS, "Vasto Lorde" = HOLLOW_STAGE_VASTO)
	var/choice = Ask(usr, "Set [P] to which stage?", "Set Hollow Stage", null, "pick", stages, 1)
	if(isnull(choice))
		return
	P.HollowSetStage(stages[choice])
	P << "<font color=yellow>An admin has set your stage to [HollowStageName(P.HollowStage)].</font>"
	Log("Admin", "[ExtractInfo(usr)] set [ExtractInfo(P)]'s Hollow stage to [P.HollowStage].")

/mob/Admin3/verb/Grant_Vasto_Lorde()
	set category = "Admin"
	set name = "Grant Vasto Lorde"
	var/mob/Players/P = HollowPickTarget("Grant Vasto Lorde")
	if(!P)
		return
	if(P.HollowStage == HOLLOW_STAGE_VASTO)
		usr << "<font color=red>[P] is already a Vasto Lorde.</font>"
		return
	var/confirm = Ask(usr, "Grant [P] Vasto Lorde?", "Grant Vasto Lorde", null, "confirm", null, 1, "Grant", "Cancel")
	if(confirm != "Grant")
		return
	P.HollowVastoRolled = 1
	P.HollowSetStage(HOLLOW_STAGE_VASTO)
	P << "<font color=yellow>You are now a Vasto Lorde.</font>"
	Log("Admin", "[ExtractInfo(usr)] granted [ExtractInfo(P)] Vasto Lorde.")

/mob/Admin3/verb/Edit_Hollow_Points()
	set category = "Admin"
	set name = "Edit Hollow Points"
	var/mob/Players/P = HollowPickTarget("Edit Hollow Points")
	if(!P)
		return
	var/val = Ask(usr, "Set [P]'s Vasto Lorde points. Current: [P.HollowPoints]. Cap: [HOLLOW_POINT_CAP].", "Edit Hollow Points", "[P.HollowPoints]", "uint", null, 1)
	if(isnull(val))
		return
	P.HollowPoints = clamp(val, 0, HOLLOW_POINT_CAP)
	usr << "<font color=yellow>[P] now has [P.HollowPoints] point(s).</font>"
	Log("Admin", "[ExtractInfo(usr)] set [ExtractInfo(P)]'s Hollow points to [P.HollowPoints].")

/mob/Admin3/verb/Reroll_Hollow_Shell()
	set category = "Admin"
	set name = "Reroll Shell"
	var/mob/Players/P = HollowPickTarget("Reroll Shell")
	if(!P)
		return
	if(P.HollowStage != HOLLOW_STAGE_BASE)
		usr << "<font color=red>[P] is past the shell stage.</font>"
		return
	P.HollowRollShell()
	P.HollowSyncSkills()
	var/datum/hollow_shell/S = HollowShellDatum(P.HollowShell)
	usr << "<font color=yellow>[P] is now a [S ? S.label : P.HollowShell].</font>"
	Log("Admin", "[ExtractInfo(usr)] rerolled [ExtractInfo(P)]'s shell to [P.HollowShell].")

/mob/Admin3/verb/Set_Vasto_Lorde_Limit()
	set category = "Admin"
	set name = "Set Vasto Lorde Limit"
	var/val = Ask(usr, "Natural Vasto Lorde limit. Current count: [glob.VastoLordeCount]. Current limit: [glob.VastoLordeLimit].", "Set Vasto Lorde Limit", "[glob.VastoLordeLimit]", "uint", null, 1)
	if(isnull(val))
		return
	glob.VastoLordeLimit = val
	usr << "<font color=yellow>Natural Vasto Lorde limit is now [glob.VastoLordeLimit].</font>"
	Log("Admin", "[ExtractInfo(usr)] set the natural Vasto Lorde limit to [glob.VastoLordeLimit].")

/mob/Admin3/verb/Hollow_Report()
	set category = "Admin"
	set name = "Hollow Report"
	var/list/pool = HollowOnlineList()
	var/list/rows = list()
	for(var/mob/Players/P in pool)
		var/datum/hollow_shell/S = HollowShellDatum(P.HollowShell)
		rows[++rows.len] = list("t" = "[P.key]", "tn" = "[P.name]", "t2" = "Potential [P.Potential] - ascension [P.AscensionsAcquired]", "c" = list(HollowStageName(P.HollowStage), HollowArrancarName(P.HollowArrancar), P.HollowDeathRegen ? "On" : "Off", "[P.HollowPoints]", S ? S.label : "-", P.HollowResId ? "[P.HollowResId]" : "-"))
	usr.client?.TableShow("hollow:report", "HOLLOW", "Hollows online", "[rows.len] online - [glob.VastoLordeCount]/[glob.VastoLordeLimit] natural Vasto Lorde", list(list("l" = "PLAYER", "a" = "l"), list("l" = "STAGE", "a" = "l"), list("l" = "ARRANCAR", "a" = "l"), list("l" = "REGEN", "a" = "l"), list("l" = "POINTS", "a" = "r"), list("l" = "SHELL", "a" = "l"), list("l" = "RESURRECCION", "a" = "l")), rows, "", null, list("nosort" = 1))
