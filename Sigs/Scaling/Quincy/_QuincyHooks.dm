/obj/Skills/Projectile/_Projectile/var/tmp/QuincyHitPass = 0
/obj/Skills/Projectile/_Projectile/var/tmp/QuincyFinishPass = 0
/obj/AutoHitter/var/tmp/QuincyDamagePass = 0

/obj/Skills/Projectile/_Projectile/proc/QuincyProjectileNew(mob/m, obj/Skills/Projectile/Z)
	return

/obj/Skills/Projectile/_Projectile/proc/QuincyHit(atom/a, MultDamage=1)
	return QuincyHitUnderbelly(a, MultDamage)

/obj/Skills/Projectile/_Projectile/proc/QuincyHitUnderbelly(atom/a, MultDamage=1)
	return QuincyHitJailWind(a, MultDamage)

/obj/Skills/Projectile/_Projectile/proc/QuincyHitJailWind(atom/a, MultDamage=1)
	return QuincyHitXAxis(a, MultDamage)

/obj/Skills/Projectile/_Projectile/proc/QuincyHitXAxis(atom/a, MultDamage=1)
	return QuincyHitVollstandig(a, MultDamage)

/obj/Skills/Projectile/_Projectile/proc/QuincyHitVollstandig(atom/a, MultDamage=1)
	return QuincyHitSchneider(a, MultDamage)

/obj/Skills/Projectile/_Projectile/proc/QuincyHitSchneider(atom/a, MultDamage=1)
	src.QuincyHitPass = 1
	return src.Hit(a, MultDamage)

/obj/Skills/Projectile/_Projectile/proc/QuincyFinish()
	src.QuincyFinishPass = 1
	return src.ProjectileFinish()

/obj/AutoHitter/proc/QuincyDamage(mob/m)
	src.QuincyDamagePass = 1
	return src.Damage(m)

/obj/Skills/Teleport/proc/QuincyTeleportAllowed(mob/User)
	return 1
