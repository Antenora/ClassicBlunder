obj/Skills/Projectile/_Projectile/QuincyProjectileNew(mob/m, obj/Skills/Projectile/Z)
	if(istype(Z, /obj/Skills/Projectile/Quincy/Thrown_Thing))
		var/obj/Skills/Projectile/Quincy/Thrown_Thing/T = Z
		if(T.lifted)
			src.icon_state = T.lifted.icon_state
	return ..()

obj/Skills/Projectile/_Projectile/QuincyFinish()
	var/obj/Skills/Projectile/fs = src.from_skill
	if(src.Distance < 0 || (src.clash_lock && !src.clash_lock.ended))
		return ..()
	if(!istype(fs, /obj/Skills/Projectile/Quincy/Spork) && !istype(fs, /obj/Skills/Projectile/Quincy/Thrown_Thing))
		return ..()
	var/turf/t = get_turf(src)
	var/turf/c = locate(round((src.CenterX() + src.vhb_ax - 1) / 32) + 1, round((src.CenterY() + src.vhb_ay - 1) / 32) + 1, src.z)
	var/mob/o = src.Owner
	. = ..()
	if(c && !c.density)
		t = c
	if(!t || !fs)
		return
	if(istype(fs, /obj/Skills/Projectile/Quincy/Spork))
		if(o)
			o.GluttonTrapPlant(t, fs)
	else
		var/obj/Skills/Projectile/Quincy/Thrown_Thing/T = fs
		T.ThrownLand(t)
