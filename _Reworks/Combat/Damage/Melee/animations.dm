
/mob/var/customPixelX = 0
/mob/var/customPixelY = 0

/mob/proc/Whiff()
	set waitfor = FALSE
	KenShockwave(src, icon='fevKiai.dmi', Size = 0.5)	



/mob/verb/resetPixelOffset()
	set name = "Reset Appearance"
	set category = "Other"
	pixel_x = customPixelX
	pixel_y = customPixelY
	alpha = 255