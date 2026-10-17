/proc/QuincyCutProjectile(obj/Skills/Projectile/_Projectile/P)
	if(P.Area == "Beam")
		P.Distance = 0
		P.endLife()
	else
		P.ProjectileFinish()

obj/Skills/Projectile/_Projectile/QuincyHitSchneider(atom/a, MultDamage=1)
	var/obj/Skills/Projectile/fs = src.from_skill
	if(istype(a, /obj/Skills/Projectile/_Projectile))
		var/obj/Skills/Projectile/_Projectile/o = a
		if(!o.Owner || !src.Owner || o.Owner == src.Owner)
			return ..()
		if(istype(fs, /obj/Skills/Projectile) && fs.CutsProjectiles)
			QuincyCutProjectile(o)
			return
		var/obj/Skills/Projectile/ofs = o.from_skill
		if(istype(ofs, /obj/Skills/Projectile) && ofs.CutsProjectiles)
			QuincyCutProjectile(src)
			return
		return ..()
	if(!istype(fs, /obj/Skills/Projectile))
		return ..()
	var/gritz = istype(fs, /obj/Skills/Projectile/Ginto/Gritz_Film)
	if(!ismob(a) || (!fs.ManaDrainPerPass && !gritz))
		return ..()
	var/mob/m = a
	var/mob/own = src.Owner
	var/hk = m.ckey ? "[m.ckey]" : "\ref[m]"
	var/list/ah = src.AlreadyHit
	var/before = ah ? ah[hk] : 0
	. = ..()
	if(!m || !own || !ah || !(ah[hk] > before))
		return
	if(fs.ManaDrainPerPass)
		m.LoseMana(fs.ManaDrainPerPass)
		own.HealMana(fs.ManaDrainPerPass)
	if(gritz)
		OMsg(m, "A pentagonal film of Reishi wraps [m]!")
		m.QuincyGritzFilmOn()
