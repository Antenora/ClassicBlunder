/mob/Admin3/verb/Races()
	set name = "Races"
	set category = "Admin"
	var/list/lol = list()
	for(var/mob/x in players)
		var/race = x.race.name
		lol["[race]"]++
		if(x.isRace(WILDER))
			lol["[x.Class]"]++

	for(var/x in lol)
		src<<"[x] = [lol[x]]"

/mob/Admin3/verb/Styles()
	set name = "Styles"
	set category = "Admin"
	var/list/lol = list()
	for(var/mob/x in players)
		for(var/obj/Skills/Buffs/NuStyle/style in x)
			lol["[style.StyleActive]"]++

	for(var/x in lol)
		src<<"[x] = [lol[x]]"

var/GlobalStorage/globalStorage

GlobalStorage
	var
		tmp
			list/objTypes = list()
			list/skillTypes = list()
			list/itemTypes = list()
			list/mobTypes = list()
			list/turfTypes = list()
	New()
		..()
		for(var/x in typesof(/obj))
			if(ispath(x,/obj/Skills))
				skillTypes += x
				continue
			else if(ispath(x,/obj/Items))
				itemTypes += x
				continue
			objTypes += x
		mobTypes = typesof(/mob)
		turfTypes = typesof(/turf)


/mob/Admin4/verb/ChangeWorldSettings()
	set category = "Admin"
	set name = "Change World Settings"
	var/i = Ask(src, "ssss", "", null, "pick", list("tick_lag","fps"), 0)
	src << "Current [i] is [world.vars[i]]"
	var/x = Ask(src, "ssss", "", null, "num", null, 0)
	world.vars[i] = x
	src << "Changed [i] to [x]"
	src << "Current [i] is [world.vars[i]]"

/mob/verb/changeClientFPS()
	set category = "Other"
	set hidden = 1
	set name = "Change Client FPS"
	var/n = Ask(src, "ssss", "", null, "num", null, 0)
	src.client<<"[SetClientFPS(n)]"

/mob/Admin3/verb/Copy()
	set category = "Admin"
	set name = "Copy"
	var/obj/O = PromptArg(usr, args, 1, "Copy", "world:/obj")
	if(isnull(O)) return
	var/obj/O2 = copyatom(O)
	O2.name = "[O.name]_copy"
	O2.Move(src)


/mob/Admin2/verb/Give_Make()
	set category="Admin"
	set name="Give/Make"
	var/mob/A = PromptArg(usr, args, 1, "Give/Make", "world:/mob")
	if(isnull(A)) return
	var/cat = Ask(usr, "What do you want to select?", "", null, "pick", list("Skills","Items","Object","Mob","Turf","Cancel"), 0)
	var/list/paths = null
	switch(cat)
		if("Skills")
			paths = globalStorage.skillTypes
		if("Items")
			paths = globalStorage.itemTypes
		if("Object")
			paths = globalStorage.objTypes
		if("Mob")
			paths = globalStorage.mobTypes
		if("Turf")
			paths = globalStorage.turfTypes
	if(!paths)
		return
	usr.client?.SheetShow("give:\ref[A]:[cat]", "GIVE", "[A] - [cat]", "Click a type to give it to [A].", SheetTypeRows(paths, "byond://?src=\ref[A];action=giveobj;var="), "a type to give")


