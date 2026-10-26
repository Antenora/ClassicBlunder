obj/Skills/Projectile/_Projectile/var/tmp/QuincyReflected = 0

obj/Skills/Projectile/_Projectile/QuincyHitXAxis(atom/a, MultDamage=1)
	if(!ismob(a) || src.QuincyReflected)
		return ..()
	var/obj/Skills/Projectile/fs = src.from_skill
	if(!istype(fs, /obj/Skills/Projectile) || !fs.QuincyReflectsHome)
		return ..()
	var/mob/m = a
	var/mob/o = src.Owner
	if(!ismob(o) || m == o || m.KO || !m.QuincyReflectsShot(src))
		return ..()
	m.QuincyReflectHome(src, o)
