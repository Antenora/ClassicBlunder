/datum/ougi_scene/OpHit(list/a)
	var/obj/Skills/Ougi/O = ougi
	var/mob/A = attacker
	var/live_hit = !hit_done && !preview && climax_mult > 0 && O && A && target && A.passive_handler
	if(live_hit)
		if(O.OugiLifeSteal) A.passive_handler.Increase("LifeSteal", O.OugiLifeSteal, TRUE)
		if(O.OugiDisorienting) A.passive_handler.Increase("Disorienting", O.OugiDisorienting, TRUE)
	..()
	if(live_hit && A && A.passive_handler)
		if(O.OugiLifeSteal) A.passive_handler.Decrease("LifeSteal", O.OugiLifeSteal, TRUE)
		if(O.OugiDisorienting) A.passive_handler.Decrease("Disorienting", O.OugiDisorienting, TRUE)

/datum/ougi_scene/End(force = 0)
	var/post = !ended && !fizzled && !preview && hit_done && climax_mult > 0
	var/obj/Skills/Ougi/O = ougi
	var/mob/A = attacker
	var/mob/T = target
	..()
	if(post && O && A) O.OugiAfterScene(A, T)

/datum/ougi_scene/DoOp(op, list/a)
	switch(op)
		if("burst") return OpOugiBurst(a)
		if("beam") return OpOugiBeam(a)
	return ..()

/datum/ougi_scene/proc/OugiOpTurf(list/a)
	var/at = ArgText(a, "at", "target")
	var/mob/M = (at == "attacker" || at == "target") ? Who(at) : null
	if(M && M.loc && room && M.z == room.z) return M.loc
	return MarkTurf(at)

/datum/ougi_scene/proc/OpOugiBurst(list/a)
	var/turf/T = OugiOpTurf(a)
	var/row = ArgText(a, "row", null)
	if(!T || !row) return
	if(istext(row)) row = text2path(row)
	var/px = ArgNum(a, "dx", 0)
	var/py = ArgNum(a, "dy", 0)
	var/at = ArgText(a, "at", "target")
	var/mob/M = (at == "attacker" || at == "target") ? Who(at) : null
	if(M && T == M.loc)
		var/list/p = OugiSceneMobPoint(M)
		px += p[1] - ((T.x - 1) * world.icon_size + world.icon_size / 2)
		py += p[2] - ((T.y - 1) * world.icon_size + world.icon_size / 2)
	EnergyFXBurst(T, max(2, ArgNum(a, "radius", 2)), row, null, px, py)

var/list/ougi_beam_templates = list()

/datum/ougi_scene/proc/OpOugiBeam(list/a)
	var/mob/M = Who(ArgText(a, "who", "attacker"))
	var/row = ArgText(a, "row", null)
	if(!M || !M.loc || !row) return
	if(istext(row)) row = text2path(row)
	if(!ispath(row, /obj/Skills/Projectile)) return
	var/obj/Skills/Projectile/P = ougi_beam_templates["[row]"]
	if(!P)
		P = new row
		P.loc = null
		ougi_beam_templates["[row]"] = P
	var/mob/other = (M == attacker) ? target : attacker
	if(other && other.z == M.z)
		var/d = get_dir(M, other)
		if(d) M.dir = d
	P.EnergyFXFeint(M)
