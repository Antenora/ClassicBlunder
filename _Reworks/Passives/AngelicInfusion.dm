passiveInfo/AngelicInfusion
	setLines()
		lines = list("Amplifies all healing received by 20% per stack.",\
"Affects HealHealth, LifeGeneration ticks, and all other healing sources.")

/mob/proc/getAngelicInfusion()
	. = passive_handler.Get("AngelicInfusion")
/mob/proc/getAngelicInfusionMult()
	. = 1;
	var/pip = getAngelicInfusion()
	if(pip) . += (0.2 * pip);//0.2 could be a global variable but we're speedrunning rn
