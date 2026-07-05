mob/proc/gainShinobi()
	src << "Chakra stirs within you, honed by discipline and bloodshed... you have become a <b>Shinobi</b>."
	src.Saga = "Shinobi"
	src.SagaLevel = 1

	var/list/Branches = list("Sharingan", "Eight Gates", "Sage Mode")
	src.ShinobiBranch = input("Which path does [src] receive?", "Shinobi Branch") in Branches

	src << "The path of <b>[src.ShinobiBranch]</b> lies before you."

	src.ChakraAffinities = list()
	src.pickChakraAffinity(TRUE)
	src.verbs += /mob/proc/verb_ObtainChakraAffinity

	src << "Your training grants you access to Jutsu. You can currently select 2 Tier 1 jutsu."


mob/tierUpSaga(Path)
	..()
	if(Path == "Shinobi")
		switch(SagaLevel)
			if(2)
				src << "Your body and chakra grow accustomed to one another..."
				// Not done
				// switch(ShinobiBranch)
				// 	if("Sharingan")
				// 	if("Eight Gates")
				// 	if("Sage Mode")

			if(3)
				src << "Your command of Jutsu deepens. You can learn 2 more jutsu (Tier 2 or lower)."
				// branch SL3 unlocks

			if(4)
				src << "Your power surges to new heights..."
				// branch SL4 unlocks

			if(5)
				src << "Your mastery of Jutsu sharpens. You can select 1 jutsu (Tier 3 or lower)."
				// branch SL5 unlocks

			if(6)
				src << "You are nearing the peak of the shinobi arts. You can select 1 jutsu (Tier 4 or lower)."
				// branch SL6 unlocks

			if(7)
				src << "The pinnacle of the shinobi arts is within reach. You can select 1 jutsu (Tier 5 or lower)."
				// branch SL7 unlocks

		// At SL3, single-affinity Shinobi get their one-time Specialization offer
		if(SagaLevel == 3)
			offerChakraSpecialization()
		rollChakraAffinity()
