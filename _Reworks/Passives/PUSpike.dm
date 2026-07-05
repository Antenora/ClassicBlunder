globalTracker/var
	PU_SPIKE_MANG_MULTIPLIER = 30;
	PU_SPIKE_SHIRAYUKI_MULT = 1;
	PU_SPIKE_IMAGINARY_ACTIVE_ADD = 50;
	PU_SPIKE_IMAGINARY_SPECIAL_ADD = 50;
	PU_SPIKE_REDPUSPIKE_MULT = 1;
	PU_SPIKE_OVERDRIVE_ADD = 200;

/mob/proc/GetPUSpike()
	. = passive_handler.Get("PUSpike") //This stores stuff from sources of PUSpike... yay.
	. += (GetMangLevel() * glob.PU_SPIKE_MANG_MULTIPLIER) // if I have to nerf this, I am sorry.
	if(passive_handler["Shirayuki"] && Slow > 0)
		if(CheckActive("Ki Control"))
			. += (Slow * glob.PU_SPIKE_SHIRAYUKI_MULT)
	if(Class=="Imaginary")
		if(ActiveBuff)
			. += glob.PU_SPIKE_IMAGINARY_ACTIVE_ADD;
		if(SpecialBuff)
			. += glob.PU_SPIKE_IMAGINARY_SPECIAL_ADD;
	if(passive_handler.Get("RedPUSpike")) . += (passive_handler.Get("RedPUSpike") * glob.PU_SPIKE_OVERDRIVE_ADD);
	if(CheckSpecial("Overdrive")) . += glob.PU_SPIKE_OVERDRIVE_ADD;

	if(.) . = max(0, . / 100)
