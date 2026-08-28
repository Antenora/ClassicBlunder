race
	human
		name = "Human"
		desc = "The most resolute, determined, and adaptable race. While lacking in upfront strength, they sometimes manifest the power to create miracles."
		visual = 'Humans.png'
		passives = list("Tenacity" = 1, "Adrenaline" = 1, "Innovation" = 1)
		statPoints = 15
		power = 1
		strength = 1
		endurance = 1
		force = 1
		offense = 1
		defense = 1
		speed = 1
		anger = 1.5
		learning = 1.25
		intellect = 2
		imagination = 1.5
		growth=1
		classes = list("Human")
		class_info = list("Humans that start off weak but possess power that can explosively ramp up.", "Humans that focus on maximizing the natural strength of the skills and buffs they attain.", "The weakest Humans of all, but are second to none at utilizing technology.")
		stats_per_class = list("Human" = list(1, 1, 1, 1, 1, 1))
	//	secondary_stats_per_class = list("Underdog" = list(2, 1.35, 2, 1.5, 1), "Heroic" = list(1.5, 1.25, 2, 1.5, 1), "Resourceful" = list(1.25, 1.15, 3, 3, 1.5))
		onFinalization(mob/user)
			if(user.Class=="Heroic"||user.Class=="Resourceful")
				for(var/transformation/human/HT in user.race.transformations)
					user.race.transformations -=HT
					del HT

			var/list/mazokuTransformations = list(/transformation/human/high_tension/mazoku, /transformation/human/high_tension_MAX/mazoku,
			/transformation/human/super_high_tension/mazoku, /transformation/human/super_high_tension_MAX/mazoku, /transformation/human/unlimited_high_tension/mazoku,
			/transformation/human/sacred_energy_aura);

			for(var/transformation/human/mazokuHT in user.race.transformations)
				if(mazokuHT.type in mazokuTransformations)
					user.race.transformations -= mazokuHT;
					del mazokuHT;
			..()
