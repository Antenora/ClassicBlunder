/mob/Admin2/verb/Screen_Shatter()
	set category = "Admin"
	set name = "Screen Shatter"

	if(!src.client)
		return

	var/list/targets = list(src)
	for(var/mob/M in view(src))
		if(M.client && M != src)
			targets += M

	for(var/mob/M in targets)
		ScreenShatter(M)

	Log("Admin", "[ExtractInfo(src)] triggered Screen Shatter effect on [targets.len] player(s).")
