obj/Skills/Projectile/_Projectile/var/tmp/mob/QuincyAbsorbedBy

obj/Skills/Projectile/_Projectile/QuincyHitVollstandig(atom/a, MultDamage=1)
	if(!ismob(a))
		return ..()
	var/mob/m = a
	if(!m.QuincyVollstandigAbsorbs(src))
		return ..()
	if(src.QuincyAbsorbedBy == m)
		return
	src.QuincyAbsorbedBy = m
	m.QuincyVollstandigAbsorb()
	if(src.Distance >= 0)
		src.Killed = 1
		src.ProjectileFinish()
