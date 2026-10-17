/proc/NamekOnlineList()
	var/list/out = list()
	for(var/mob/Players/P in players)
		if(P.NamekIsNamek())
			out += P
	return out

/mob/proc/NamekPickTarget(title)
	var/list/pool = NamekOnlineList()
	if(!pool.len)
		usr << "<font color=red>No Namekians are online.</font>"
		return null
	var/list/lab = PromptLabelAtoms(pool, 1)
	var/choice = Ask(usr, "Which Namekian?", title, null, "pick", lab, 1)
	if(isnull(choice))
		return null
	return lab[choice]

/mob/Admin3/verb/Set_Namekian_Path()
	set category = "Admin"
	set name = "Set Namekian Path"
	var/mob/Players/P = NamekPickTarget("Set Namekian Path")
	if(!P)
		return
	var/list/paths = NamekClanPaths(P.Class)
	if(!paths.len)
		usr << "<font color=red>[P]'s clan is [P.Class ? P.Class : "unset"], which has no paths.</font>"
		return
	var/list/options = list()
	for(var/path in paths)
		options[path] = path
	options["None"] = "None"
	var/choice = Ask(usr, "Set [P]'s path. Current: [P.NamekPath ? P.NamekPath : "None"].", "Set Namekian Path", null, "pick", options, 1)
	if(isnull(choice))
		return
	var/newpath = options[choice] == "None" ? null : options[choice]
	if(!P.NamekSetPath(newpath))
		usr << "<font color=red>[P] already walks that path.</font>"
		return
	P << "<font color=yellow>An admin has set your path to [P.NamekPath ? P.NamekPath : "None"].</font>"
	Log("Admin", "[ExtractInfo(usr)] set [ExtractInfo(P)]'s Namekian path to [P.NamekPath ? P.NamekPath : "None"].")

/mob/Admin3/verb/Resync_Namekian()
	set category = "Admin"
	set name = "Resync Namekian"
	var/mob/Players/P = NamekPickTarget("Resync Namekian")
	if(!P)
		return
	P.NamekSyncAll()
	usr << "<font color=yellow>[P] resynced: body [P.NamekEvoApplied], path [P.NamekPath ? P.NamekPath : "None"].</font>"
	Log("Admin", "[ExtractInfo(usr)] resynced [ExtractInfo(P)]'s Namekian state.")

/mob/Admin3/verb/Namekian_Report()
	set category = "Admin"
	set name = "Namekian Report"
	var/list/pool = NamekOnlineList()
	var/list/rows = list()
	for(var/mob/Players/P in pool)
		var/mob/H = P.NamekHatchling
		rows[++rows.len] = list("t" = "[P.key]", "tn" = "[P.name]", "t2" = "Potential [P.Potential] - ascension [P.AscensionsAcquired]", "c" = list(P.Class ? "[P.Class]" : "-", P.NamekPath ? "[P.NamekPath]" : "-", "[P.AscensionsAcquired]", "[P.NamekEvoApplied]", "[P.NamekFusionSteps]", H ? "[H.name]" : "-"))
	usr.client?.TableShow("namekian:report", "NAMEKIAN", "Namekians online", "[rows.len] online", list(list("l" = "PLAYER", "a" = "l"), list("l" = "CLAN", "a" = "l"), list("l" = "PATH", "a" = "l"), list("l" = "ASCENSIONS", "a" = "r"), list("l" = "BODY", "a" = "r"), list("l" = "FUSION", "a" = "r"), list("l" = "HATCHLING", "a" = "l")), rows, "", null, list("nosort" = 1))
