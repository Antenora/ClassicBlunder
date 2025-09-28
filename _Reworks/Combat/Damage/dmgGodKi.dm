/mob/proc/godKiModifiers(mob/defender, destructive)
	if(HasGodKi())
		. += GetGodKi() * 10
	if(defender.HasGodKi() && destructive < 2 )
		. -= defender.GetGodKi() * 10