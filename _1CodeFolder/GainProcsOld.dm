mob/proc/Meditation()
	set waitfor=0
	var/obj/Skills/Meditate/med
	for(var/obj/Skills/Meditate/m in src)
		med = m
		break
	if(med.delay)
		sleep(5)
		return

	spawn()
		if(src.VaizardHealth>0)
			src.VaizardHealth=0
		if(passive_handler.Get("AbsorbingDamage"))
			AbsorbingDamage = 0
		if(passive_handler["Shellshocked"])
			passive_handler.Set("Shellshocked", 0)
		if(isRace(BEASTMAN) && race?:Racial == "Heart of The Beastman")
			if(passive_handler["Grit"] == 0)
				passive_handler.Set("Grit", 1)
		/*if(length(magatamaBeads))
			loseMagatama()*/
		med.delayTimer()


