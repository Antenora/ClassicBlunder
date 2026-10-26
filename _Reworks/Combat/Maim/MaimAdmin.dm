mob/Admin2/verb/maimApply()
	set category = "Admin"
	var/mob/m = PromptArg(usr, args, 1, "Maim Apply", "world:/mob")
	if(isnull(m))
		return
	var/part = PromptArgList(usr, args, 2, "Maim Apply: part", MAIM_PARTS.Copy())
	if(!(part in MAIM_PARTS))
		return
	var/tier = text2num("[PromptArgList(usr, args, 3, "Maim Apply: tier", list(1, 2, 3))]")
	if(!tier)
		return
	var/t = m.MaimSetTier(part, tier)
	m.recordMaim(usr, "Admin", "[part] tier [t]")
	Log("Admin", "[ExtractInfo(usr)] set [ExtractInfo(m)]'s [part] maim to tier [t].")
	usr << "[m]'s [lowertext(part)] maim is now tier [t]."
	m << "<font color='red'>Your [lowertext(part)] has been maimed. It is now tier [t].</font color>"

mob/Admin2/verb/maimClear()
	set category = "Admin"
	var/mob/m = PromptArg(usr, args, 1, "Maim Clear", "world:/mob")
	if(isnull(m))
		return
	m.MaimClearAll()
	Log("Admin", "[ExtractInfo(usr)] cleared every maim on [ExtractInfo(m)].")
	usr << "Every maim on [m] is cleared."
	m << "Your maims have been cleared."
