/*mob/verb/AdminPanel(var/mob/m in players) //This is baby's first attempt at an admin panel. extremely fucking basic, don't touch
	set name = "Admin Panel"
	set category = "Admin"

	src << "AdminPanel() called. mob.type=[src.type] key=[src.key]"
	src << "target is [m]"

	if(!src.client)
		src << "No client attached (NPC or detached mob)."
		return

	var/html = "<html><body><b>Admin Panel Loaded</b><br><a href='byond://?src=\ref[src.client];panel=admin;action=heal'>Heal</a></body></html>"

	src.client << browse(html, "window=adminpanel;size=300x200;can_resize=1;can_close=1;titlebar=1")



client/Topic(href, list/href_list)
	..()

	if(href_list["panel"] != "admin")
		return

	if(href_list["action"] == "heal")
		if(src.mob)
			src.mob.Health = 100
			src.mob << "Healed."
*/