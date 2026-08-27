
/mob/var/customPixelX = 0
/mob/var/customPixelY = 0

/mob/proc/Whiff(mob/attacker = null)
	set waitfor = FALSE
	var/px = 0
	var/py = 0
	if(attacker)
		var/list/v = FlashDirPx(get_dir(attacker, src))
		px = v[1] * 14
		py = v[2] * 14
		FlashSwingSmear(attacker, src, 0.5)
	KenShockwave(src, icon='fevKiai.dmi', Size = 0.5, PixelX = px, PixelY = py)



/mob/verb/resetPixelOffset()
	set name = "Reset Pixel Offset"
	set category = "Other"
	set hidden = 1
	pixel_x = customPixelX
	pixel_y = customPixelY
	alpha = 255