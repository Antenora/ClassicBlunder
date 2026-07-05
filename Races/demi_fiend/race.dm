race
	demi_fiend
		name = "Demi-fiend"
		desc = "An artificial, composite being with a human heart and the body of a demon, created by a certain individual. They possess the ability to ingest magatama to utilize the power of demons and fight as their equal."
		visual = 'Makaioshins.png'
		locked = TRUE
		passives = list("MartialMagic" = 1)
		power = 3;
		strength = 2
		endurance = 2
		speed = 2
		force = 2
		offense = 1
		defense = 1
		regeneration = 3
		recovery = 3
		imagination = 3
		anger = 1.5
		onFinalization(mob/user)
			var/obj/Items/Magatama/Marogareh/M = new
			user.AddItem(M)
			M.equipMagatama(user)
			user.verbs += /mob/proc/CraftMagatama
			// Demi-fiends automatically begin as Devil Summoners (Tier 1)
			user.Saga = "Devil Summoner"
			user.SagaLevel = 1
			user.tierUpSaga("Devil Summoner")
			..()
