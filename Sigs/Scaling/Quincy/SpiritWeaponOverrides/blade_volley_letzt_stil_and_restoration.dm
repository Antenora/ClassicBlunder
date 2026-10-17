/obj/Skills/Projectile/Quincy/Heilig_Pfeil_Blade/adjust(mob/p)
	..()
	if(p.QuincyLetztActive)
		EndEffectiveness = QUINCY_LETZT_END_EFF
		ShieldPierce = 1
	else
		EndEffectiveness = initial(EndEffectiveness)
		ShieldPierce = initial(ShieldPierce)
	if(p.QuincyLevel >= 5)
		DamageMult *= QUINCY_RESTORE_MULT
