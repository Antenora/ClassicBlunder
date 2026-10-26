obj/Skills/Projectile/_Projectile/QuincyFinish()
	if(!istype(src.from_skill, /obj/Skills/Projectile/Quincy/Burner_Finger_Melt) || src.Killed || src.Distance < 0 || (src.clash_lock && !src.clash_lock.ended))
		return ..()
	var/obj/Skills/Projectile/Quincy/Burner_Finger_Melt/fs = src.from_skill
	var/turf/t = get_turf(src)
	var/mob/o = src.Owner
	var/ticks = fs.lava_ticks
	. = ..()
	if(t && o)
		o.QuincyLavaPatch(t, ticks, 1)
