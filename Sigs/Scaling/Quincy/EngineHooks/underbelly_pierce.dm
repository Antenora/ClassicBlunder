obj/Skills/Projectile/_Projectile/QuincyHitUnderbelly(atom/a, MultDamage=1)
	var/mob/o = src.Owner
	if(!ismob(a) || !ismob(o) || !o.UnderbellyTarget || a != o.UnderbellyTarget)
		return ..()
	var/p = o.UnderbellyPierce(a)
	if(p >= 1)
		return ..()
	var/was = src.EndEffectiveness
	src.EndEffectiveness = min(isnum(was) ? was : 1, p)
	. = ..()
	if(src)
		src.EndEffectiveness = was

obj/AutoHitter/QuincyDamage(mob/m)
	var/mob/o = src.Owner
	if(!ismob(m) || !ismob(o) || !o.UnderbellyTarget || m != o.UnderbellyTarget)
		return ..()
	var/p = o.UnderbellyPierce(m)
	if(p >= 1)
		return ..()
	var/was = src.EndRes
	src.EndRes = min(isnum(was) ? was : 1, p)
	. = ..()
	if(src)
		src.EndRes = was
