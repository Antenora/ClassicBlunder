#define GARGANTA_WINDUP 30
#define GARGANTA_RIFT_LIFE 80
#define GARGANTA_NEAR_TILES 4

mob/var/tmp/GargantaCrossing = 0

/obj/GargantaAnchor
	name = "Garganta Anchor"
	desc = "A place the void remembers."
	icon = 'Icons/LifeSkills/Stations.dmi'
	icon_state = "anvil"
	density = 0
	Savable = 1
	Attackable = 0
	invisibility = 101
	alpha = 0
	var/label = "Unnamed Anchor"

/obj/Effects/GargantaRift
	name = "Garganta"
	desc = "A tear in the world with nothing behind it."
	icon = 'BlackHole.dmi'
	icon_state = ""
	density = 0
	Savable = 0
	Attackable = 0
	layer = 2.5
	pixel_x = 0
	pixel_y = 0
	var/tmp/obj/GargantaAnchor/target
	var/tmp/mob/opener

	New(loc, obj/GargantaAnchor/A, mob/who)
		..()
		src.target = A
		src.opener = who
		spawn(GARGANTA_RIFT_LIFE)
			if(src)
				src.loc = null

	Crossed(atom/movable/O)
		..()
		if(!src.target || !isturf(src.target.loc))
			return
		if(!ismob(O))
			return
		var/mob/M = O
		if(!M.client || M.KO || M.Dead)
			return
		if(M.GargantaCrossing)
			return
		M.GargantaCrossing = 1
		var/turf/dest = src.target.loc
		spawn()
			if(!M)
				return
			OMsg(M, "<b><font color=#9b59b6>[M] steps into the Garganta and is gone.</font></b>")
			M.loc = dest
			M.step_x = 0
			M.step_y = 0
			OMsg(M, "<b><font color=#9b59b6>[M] steps out of a tear in the air.</font></b>")
			M.GargantaCrossing = 0

/proc/GargantaAnchorList()
	var/list/out = list()
	for(var/obj/GargantaAnchor/A in world)
		if(isturf(A.loc))
			out += A
	return out

/obj/Skills/Teleport/Hollow/Garganta
	name = "Garganta"
	desc = "Tear the world open and step through the space behind it."
	Cooldown = 120
	ManaCost = 4

	verb/Garganta()
		set name = "Garganta"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		if(src.Using || src.cooldown_remaining > 0)
			User << "<font color=red>[src] is not ready yet.</font>"
			return
		if(User.KO || User.Dead)
			User << "<font color=red>You cannot open a Garganta like this.</font>"
			return
		if(User.InCombat())
			User << "<font color=red>You cannot tear the world open while you are fighting.</font>"
			return
		if(User.ManaAmount < src.ManaCost)
			User << "<font color=red>You do not have the power to open a Garganta.</font>"
			return
		var/list/anchors = GargantaAnchorList()
		var/list/choices = list()
		for(var/obj/GargantaAnchor/A in anchors)
			if(A.z == User.z && get_dist(User, A) <= GARGANTA_NEAR_TILES)
				continue
			var/lab = A.label
			var/n = 2
			while(choices[lab])
				lab = "[A.label] #[n]"
				n++
			choices[lab] = A
		if(!choices.len)
			User << "<font color=red>There is nowhere far enough away to open onto.</font>"
			return
		var/pick_label = Ask(User, "Where does the tear open onto?", "Garganta", null, "pick", choices, 1)
		if(isnull(pick_label))
			return
		var/obj/GargantaAnchor/A = choices[pick_label]
		if(!A || !isturf(A.loc))
			return
		spawn()
			if(!User || User.KO || User.Dead)
				return
			OMsg(User, "<b><font color=#9b59b6>[User] draws a seam in the air and begins to pull it apart.</font></b>")
			sleep(GARGANTA_WINDUP)
			if(!User || User.KO || User.Dead)
				return
			if(!A || !isturf(A.loc))
				return
			var/turf/here = User.loc
			if(!isturf(here))
				return
			User.LoseMana(src.ManaCost)
			new/obj/Effects/GargantaRift(here, A, User)
			OMsg(User, "<b><font color=#9b59b6>[User] tears the world open. The black behind it is very deep.</font></b>")
			src.Cooldown(1, null, User)

/mob/HollowStageSkillSet()
	. = ..()
	if(!islist(.))
		return .
	if(src.HollowIsHollow())
		. += /obj/Skills/Teleport/Hollow/Garganta

/mob/Admin3/verb/Place_Garganta_Anchor()
	set category = "Admin"
	set name = "Place Garganta Anchor"
	var/turf/T = get_step(usr, usr.dir)
	if(!isturf(T))
		usr << "<font color=red>There is no tile in front of you.</font>"
		return
	for(var/obj/GargantaAnchor/existing in T)
		usr << "<font color=red>There is already an anchor there: [existing.label].</font>"
		return
	var/lab = Ask(usr, "What is this anchor called? Players pick it by this name.", "Place Garganta Anchor", "Hueco Mundo", "text", null, 1)
	if(isnull(lab) || !length(lab))
		return
	var/obj/GargantaAnchor/A = new(T)
	A.label = lab
	usr << "<font color=yellow>Anchor [lab] placed at ([T.x],[T.y],[T.z]). Save the world to keep it.</font>"
	Log("Mapper", "[ExtractInfo(usr)] placed Garganta anchor [lab] at ([T.x],[T.y],[T.z]).", 1)

/mob/Admin3/proc/GargantaPickAnchor(title)
	var/list/anchors = GargantaAnchorList()
	if(!anchors.len)
		usr << "<font color=red>No Garganta anchors have been placed.</font>"
		return null
	var/list/choices = list()
	for(var/obj/GargantaAnchor/A in anchors)
		var/lab = "[A.label] ([A.x],[A.y],[A.z])"
		choices[lab] = A
	var/pick_label = Ask(usr, "Which anchor?", title, null, "pick", choices, 1)
	if(isnull(pick_label))
		return null
	return choices[pick_label]

/mob/Admin3/verb/Rename_Garganta_Anchor()
	set category = "Admin"
	set name = "Rename Garganta Anchor"
	var/obj/GargantaAnchor/A = GargantaPickAnchor("Rename Garganta Anchor")
	if(!A)
		return
	var/lab = Ask(usr, "What should [A.label] be called instead?", "Rename Garganta Anchor", A.label, "text", null, 1)
	if(isnull(lab) || !length(lab))
		return
	Log("Mapper", "[ExtractInfo(usr)] renamed Garganta anchor [A.label] to [lab].", 1)
	A.label = lab
	usr << "<font color=yellow>Anchor renamed to [lab]. Save the world to keep it.</font>"

/mob/Admin3/verb/Remove_Garganta_Anchor()
	set category = "Admin"
	set name = "Remove Garganta Anchor"
	var/obj/GargantaAnchor/A = GargantaPickAnchor("Remove Garganta Anchor")
	if(!A)
		return
	var/confirm = Ask(usr, "Remove the anchor [A.label] at ([A.x],[A.y],[A.z])?", "Remove Garganta Anchor", null, "confirm", null, 1, "Remove", "Cancel")
	if(confirm != "Remove")
		return
	Log("Mapper", "[ExtractInfo(usr)] removed Garganta anchor [A.label] at ([A.x],[A.y],[A.z]).", 1)
	del A
	usr << "<font color=yellow>Anchor removed. Save the world to keep the change.</font>"

/mob/Admin3/verb/List_Garganta_Anchors()
	set category = "Admin"
	set name = "List Garganta Anchors"
	var/list/anchors = GargantaAnchorList()
	var/list/rows = list()
	for(var/obj/GargantaAnchor/A in anchors)
		rows[++rows.len] = list("t" = "[A.label]", "c" = list("[A.x]", "[A.y]", "[A.z]"))
	usr.client?.TableShow("garganta:anchors", "GARGANTA", "Garganta anchors", "[rows.len] placed", list(list("l" = "LABEL", "a" = "l"), list("l" = "X", "a" = "r"), list("l" = "Y", "a" = "r"), list("l" = "Z", "a" = "r")), rows, "", null, list("nosort" = 1))
