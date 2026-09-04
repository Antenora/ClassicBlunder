obj/Magic_Circle
	icon='Demon Gate.dmi'
	pixel_x=-96
	pixel_y=-96
	Pickable=0
	Grabbable=0
	Destructable=0
	layer=TURF_LAYER
	Savable=1
	var/Creator//holds creator ckey
	var/Locked=1//only cuts creator mana
	var/currentRitualID = null
/*	proc/ritualAnimation()

	verb/triggerRitual()
		if(!currentRitualID) return
		var/ritual/ritual
		for(var/ritual/r in ritualDatabase)
			if(r.name == currentRitualID)
				ritual = new r
		ritual.performRitual(src, usr)
		ritualAnimation()

	verb/setRitual()
		var/list/validRituals = list("Cancel")
		for(var/knowledge in usr.knowledgeTracker.learnedMagic)
			if(knowledge == "Introductory Ritual Magics")
				validRituals += list("Sword Enchanting")
		if(length(validRituals)==1) return
		var/chosenRitual = input(usr, "Pick a ritual.") in validRituals
		if(chosenRitual == "Cancel") return
		currentRitualID = chosenRitual*/

	verb/Toggle()
		set src in range(1, usr)
		if(usr.ckey==src.Creator)
			if(src.Locked)
				src.Locked=0
				usr << "You allow your magic circle to be used by others nearby!  But the benefits are reduced."
			else
				src.Locked=1
				usr << "You do not allow others to use your magic circle!"
		else
			usr << "This isn't your magical circle!"
	verb/Erase()
		set src in range(1, usr)
		if(usr.ckey==src.Creator)
			if(!locate(/obj/Skills/Utility/Create_Magic_Circle, usr))
				usr << "You erase the circle, ready to place it elsewhere."
				usr.AddSkill(new/obj/Skills/Utility/Create_Magic_Circle)
			del src
