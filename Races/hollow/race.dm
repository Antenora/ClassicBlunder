race
	hollow
		name = "Hollow"
		desc = "A soul that lost its heart and grew a mask. Only by devouring its own kind does it evolve."
		visual = 'Saiyan.png'

		locked = FALSE
		statPoints = 10
		power = 3
		strength = 1.5
		endurance = 1.25
		force = 1.5
		offense = 1
		defense = 1
		speed = 1.25
		regeneration = 2
		recovery = 1
		imagination = 0.5
		intellect = 1
		learning = 1
		growth = 0.75
		anger_curve = list(list(75, 0.1, "is getting fired up..."), list(50, 0.3, null), list(35, 0.55, "is being pushed to their limit!"), list(20, 1, "'s power explodes with rage!!"))
		anger_curve_angered = 2
		anger_message = "shrieks through its mask!"

		New()
			..()
			if(glob && islist(glob.NoSagaRaces) && !(HOLLOW in glob.NoSagaRaces))
				glob.NoSagaRaces += HOLLOW

		onFinalization(mob/user)
			..()
			if(!user)
				return
			user.HollowStage = HOLLOW_STAGE_BASE
			user.HollowDeathRegen = 1
			user.HollowArrancar = HOLLOW_ARRANCAR_NONE
			user.HollowEvoApplied = 0
			user.HollowRollShell()
			user.HollowSyncSkills()
			user.HollowMoveToNest()
