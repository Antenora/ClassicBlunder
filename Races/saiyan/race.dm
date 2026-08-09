race
	saiyan
		name = "Saiyan"
		desc = "Saiyans are a proud, mighty warrior race. They focus on their own personal strength above all else, rarely, if ever, tapping into any kind of external power."
		visual = 'Saiyan.png'

		locked = FALSE

		power = 3;
		strength = 1.5
		endurance = 1.5
		force = 1.5
		offense = 1
		defense = 1
		speed = 1
		regeneration = 1.5
		imagination = 0.5
		growth=0.75
		//slow to build, explosive at the end
		anger_curve = list(list(75, 0.1, "is getting fired up..."), list(50, 0.3, null), list(35, 0.55, "is being pushed to their limit!"), list(20, 1, "'s power explodes with rage!!"))
		anger_curve_angered = 2
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Oozaru)

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