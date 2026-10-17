obj/Skills/Projectile/_Projectile/Click(location, control, params)
	var/mob/u = usr
	if(ismob(u) && u.QuincySchrift == "E" && u.QuincyBombCanSeize(src))
		u.QuincyBombSeize(src)
		return
	return ..()

obj/Skills/Projectile/_Projectile/QuincyFinish()
	if(!istype(src.from_skill, /obj/Skills/Projectile/Quincy/Zofiel_Rain) || src.Killed || src.Distance < 0 || (src.clash_lock && !src.clash_lock.ended))
		return ..()
	var/turf/t = get_turf(src)
	var/mob/o = src.Owner
	var/sx = src.step_x
	var/sy = src.step_y
	. = ..()
	if(t && o)
		o.QuincyBombPlant(t, QUINCY_ZOFIEL_BOMB_MULT, world.time - QUINCY_ZOFIEL_BOMB_HEAD, sx, sy)

client/Click(atom/object, atom/location, control, params)
	if(istype(object, /obj/QuincyCard))
		var/list/p = params2list(params)
		if(!p["right"] && !p["middle"])
			object.Click(location, control, params)
			return
	var/mob/m = src.mob
	if(m && m.QuincySchrift == "E" && isturf(location) && (isturf(object) || ismob(object)) && m.QuincyBombClick(object, location, params))
		return
	return ..()
