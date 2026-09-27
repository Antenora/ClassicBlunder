/obj/HollowNest
	name = "Hollow Nest"
	desc = "A hollow in the sand where the newly re-formed crawl out."
	icon = 'Icons/LifeSkills/Stations.dmi'
	icon_state = "anvil"
	density = 0
	Savable = 1
	Attackable = 0
	invisibility = 101
	alpha = 0

/mob/Admin3/verb/Place_Hollow_Nest()
	set category = "Admin"
	set name = "Place Hollow Nest"
	var/turf/T = get_step(usr, usr.dir)
	if(!isturf(T))
		usr << "<font color=red>There is no tile in front of you.</font>"
		return
	for(var/obj/HollowNest/N in T)
		usr << "<font color=red>There is already a Hollow Nest there.</font>"
		return
	new/obj/HollowNest(T)
	usr << "<font color=yellow>Hollow Nest placed at ([T.x],[T.y],[T.z]). Save the world to keep it.</font>"
	Log("Mapper", "[ExtractInfo(usr)] placed a Hollow Nest at ([T.x],[T.y],[T.z]).", 1)

/mob/Admin3/verb/Remove_Hollow_Nest()
	set category = "Admin"
	set name = "Remove Hollow Nest"
	var/obj/HollowNest/closest
	var/best = 9999
	for(var/obj/HollowNest/N in range(6, usr))
		var/d = get_dist(usr, N)
		if(d < best)
			best = d
			closest = N
	if(!closest)
		usr << "<font color=red>No Hollow Nest within six tiles.</font>"
		return
	var/turf/T = closest.loc
	var/confirm = Ask(usr, "Remove the Hollow Nest at ([T.x],[T.y],[T.z])?", "Remove Hollow Nest", null, "confirm", null, 1, "Remove", "Cancel")
	if(confirm != "Remove")
		return
	del closest
	usr << "<font color=yellow>Hollow Nest removed. Save the world to keep the change.</font>"
	Log("Mapper", "[ExtractInfo(usr)] removed a Hollow Nest at ([T.x],[T.y],[T.z]).", 1)
