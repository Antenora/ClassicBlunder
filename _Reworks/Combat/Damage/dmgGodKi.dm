/mob/proc/godKiModifiers(mob/defender, destructive)
	if(istype(src, /mob/Player/AI/Demon) || istype(defender, /mob/Player/AI/Demon) || src.isRace(DEMIFIEND) || defender.isRace(DEMIFIEND))
		return
	if(HasGodKi())
		. += (GetGodKi() * 10) * glob.GODKI_DIFF_MULT
	if(defender.HasGodKi() && destructive < 2 )
		. -= (defender.GetGodKi() * 10) * glob.GODKI_DIFF_MULT
	var/EffectiveEndlessNine=defender.GetEndlessNine(src);
	if(HasGodKi() && EffectiveEndlessNine && destructive < 2 )
		. -= (EffectiveEndlessNine * 10) * glob.GODKI_DIFF_MULT
	if(defender.passive_handler.Get("The Immovable Object")&&!defender.HasGodKi())
		. = 0;
	if(defender.HasNull())
		. = 0;


/mob/proc/maouKiModifiers(mob/defender, destructive)
	if(HasMaouKi())
		. += (GetMaouKi() * 10) * glob.MAOUKI_DIFF_MULT
	if(defender.HasMaouKi() && destructive < 2 )
		. -= (defender.GetMaouKi() * 10) * glob.MAOUKI_DIFF_MULT
	if(defender.passive_handler.Get("The Immovable Object")&&!defender.HasMaouKi())
		. = 0;
