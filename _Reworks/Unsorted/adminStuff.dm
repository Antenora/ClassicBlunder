/mob/Admin3/verb/Races()
	set name = "Races"
	set category = "Admin"
	var/list/lol = list()
	for(var/mob/x in players)
		var/race = x.race.name
		lol["[race]"]++
		if(x.isRace(BEASTMAN))
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
			objHTML = ""
			skillHTML = ""
			itemHTML = ""
			mobHTML = ""
			turfHTML = ""
	New()
		..()
		var/list/objs = typesof(/obj)

		for(var/x in objs)
			if(ispath(x,/obj/Skills))
				skillHTML += "<td><a href=byond://?src=INSERTHERE;action=magic;var=[x]>[x]<td></td></tr>"
				continue
			else if(ispath(x,/obj/Items))
				itemHTML += "<td><a href=byond://?src=INSERTHERE;action=magic;var=[x]>[x]<td></td></tr>"
				continue
			objHTML += "<td><a href=byond://?src=INSERTHERE;action=magic;var=[x]>[x]<td></td></tr>"

		var/list/mobs = typesof(/mob)
		for(var/x in mobs)
			mobHTML += "<td><a href=byond://?src=INSERTHERE;action=magic;var=[x]>[x]<td></td></tr>"

		var/list/turfs = typesof(/turf)
		for(var/x in turfs)
			turfHTML += "<td><a href=byond://?src=INSERTHERE;action=magic;var=[x]>[x]<td></td></tr>"


/mob/Admin4/verb/ChangeWorldSettings()
	set category = "Admin"
	set name = "Change World Settings"
	var/i = input(src, "ssss") in list("tick_lag","fps")
	src << "Current [i] is [world.vars[i]]"
	var/x = input(src, "ssss") as num
	world.vars[i] = x
	src << "Changed [i] to [x]"
	src << "Current [i] is [world.vars[i]]"

/mob/verb/changeClientFPS()
	set category = "Other"
	set name = "Change Client FPS"
	client.fps = input(src, "ssss") as num
	src.client<<"[client.fps]"

/mob/Admin3/verb/Copy(obj/O in world)
	set category = "Admin"
	set name = "Copy"
	var/obj/O2 = copyatom(O)
	O2.name = "[O.name]_copy"
	O2.Move(src)


/mob/Admin2/verb/Give_Make(mob/A in world)
	set category="Admin"
	set name="Give/Make"
	var/blah={"<html><Magic><body bgcolor=#000000 text="white" link="red">"}
	blah+="[A]<br>[A.type]"
	blah+="<table width=10%>"
	var/info =""
	switch(input(usr, "What do you want to select?") in list("Skills","Items","Object","Mob","Turf","Cancel"))
		if("Skills")
			info = globalStorage.skillHTML
		if("Items")
			info = globalStorage.itemHTML
		if("Object")
			info = globalStorage.objHTML
		if("Mob")
			info = globalStorage.mobHTML
		if("Turf")
			info = globalStorage.turfHTML
		if("Cancel") return
	blah += replacetext(info,"INSERTHERE","\ref[A]")
	blah += "</html>"
	usr<<browse(blah,"window=[A];size=450x600")


