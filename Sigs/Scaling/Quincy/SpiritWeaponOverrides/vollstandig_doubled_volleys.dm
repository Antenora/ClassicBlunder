/obj/Skills/Projectile/Quincy/Heilig_Pfeil_Blade/adjust(mob/p)
	..()
	if(p && p.QuincyVollstandigOnNow())
		Blasts = max(1, Blasts) * QUINCY_VOLL_VOLLEY_MULT

/mob/Players/GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	..()
	if(S && istype(g, /obj/Items/Gun/Quincy) && QuincyVollstandigOnNow())
		S.Blasts = max(1, S.Blasts) * QUINCY_VOLL_VOLLEY_MULT
