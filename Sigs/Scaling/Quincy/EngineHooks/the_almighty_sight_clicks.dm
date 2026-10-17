client/MouseDown(atom/object, atom/location, control, params)
	var/mob/m = src.mob
	if(m && m.AlmightyHits && m.AlmightyHitFind(object, params))
		return
	return ..()

client/Click(atom/object, atom/location, control, params)
	var/mob/m = src.mob
	if(m && m.AlmightyHits && m.AlmightyClick(object, location, params))
		return
	return ..()
