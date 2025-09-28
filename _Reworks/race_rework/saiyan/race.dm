race
	saiyan
		name = "Saiyan"
		desc = "Saiyans are a proud, mighty warrior race. They focus on their own personal strength above all else, rarely, if ever, tapping into any kind of external power."
		visual = 'Saiyan.png'

		locked = FALSE

		strength = 1.5
		endurance = 1.5
		force = 1.5
		offense = 1
		defense = 1
		speed = 1
		anger = 1.5
		regeneration = 1.5
		imagination = 0.5
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Oozaru)
		passives = list("Brutalize" = 0.25)

		onFinalization(mob/user)
			..()
			user.Tail(1)
//			user.contents+=new/obj/Oozaru

	/*
		TODO: think of a better way to handle racial features.
		New()
			..()
			var/obj/tail = new
			tail.layer = RACIAL_FEATURES_LAYER
			tail.icon = 'Tail.dmi'

			overlays.Add(tail)
	*/