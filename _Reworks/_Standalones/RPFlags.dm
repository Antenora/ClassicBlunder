RPFlag
	parent_type = /obj/

	invisibility = 100
	icon = 'skilltree.dmi'

	alpha = 155

	density = 0
	opacity = 0

	var/requiresItem = null
	var/trulyRequiresItem = FALSE

	Crossed(atom/movable/O)
		if(isplayer(O))
			var/mob/Players/p = O
			var/message = "[p] has crossed a RPFlag titled ([name]) at [x],[y],[z]"
			if(requiresItem)
				var/found = FALSE
				for(var/obj/Items/i in p)
					if(istype(i, requiresItem))
						found = TRUE
						break
				if(!found)
					message += " without a [requiresItem]!"
				else
					message += "!"
			AdminMessage("[message]")

	Cross(atom/movable/O)
		if(isplayer(O))
			if(requiresItem&&trulyRequiresItem)
				for(var/obj/Items/i in O)
					if(istype(i, requiresItem))
						return TRUE
				O << "That seems like a bad idea..."
				return FALSE
			else
				return TRUE

/obj/Items/Tech/SpaceMask/Rebreather
	TechType = "Rebreather"
	Cost = 1
	name = "Rebreather"
	desc = "A rebreather specifically designed to ward off the effects of the miasma."
	// its 9 am

mob/Admin3/verb/CreateRPFlag()
	if(!src.Alert("Are you sure you want to create an RP Flag?")) return
	var/nameofFlag = Ask(usr, "What do you want the flag to be titled?", "", null, "text", null, 1)
	if(!nameofFlag)
		return
	var/RPFlag/rpflag = new(usr.loc)
	var/flagNeedsXItem = Ask(usr, "What item does the flag need?", "", null, "pick", (list("None") + typesof(/obj/Items)), 0)
	if(flagNeedsXItem != "None")
		var/trulyNeed = Ask(usr, "Does the flag truly need [flagNeedsXItem]?", "", null, "pick", list("Yes", "No"), 0)
		if(trulyNeed == "Yes")
			rpflag.trulyRequiresItem = TRUE
		rpflag.requiresItem = flagNeedsXItem
	rpflag.name = nameofFlag