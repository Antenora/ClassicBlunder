race
	human
		name = "Human"
		desc = "The most resolute, determined, and adaptable race. While lacking in upfront strength, they sometimes manifest the power to create miracles."
		visual = 'Humans.png'
		passives = list("Tenacity" = 1, "Adrenaline" = 1, "Innovation" = 1)
		statPoints = 12
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
		classes = list("Underdog", "Heroic", "Resourceful")
		class_info = list("Humans that start off weak but possess power that can explosively ramp up.", "Humans that focus on maximizing the natural strength of the skills and buffs they attain.", "The weakest Humans of all, but are second to none at utilizing technology.")
		stats_per_class = list("Underdog" = list(1, 1, 1, 1, 1, 1), "Heroic" = list(1.75, 1.5, 1.75, 1.25, 1.25, 1.25), "Resourceful" = list(0.5, 0.5, 0.5, 0.75, 0.75, 2.5))
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
			
			if(user.Class=="Underdog")
				user.AngerMax = 2
				user.RPPMult = 1.35
				user.Intelligence = 2
				passives += list("Motivation" = 0.75)
			if(user.Class=="Heroic")
				user.AngerMax = 1.5
				user.RPPMult = 1.25
				user.Intelligence = 2
			if(user.Class=="Resourceful")
				user.AngerMax= 1.25
				user.RPPMult= 1.25
				user.Intelligence *= 1.5
				user.EconomyMult*=1.5
			..()
