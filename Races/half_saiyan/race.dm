// NOTE: HALF SAIYANS INHERIT SAIYAN TRANSFORMATIONS
race
	half_saiyan
		name = "Half_Saiyan"
		desc = "Half-breed Saiyans. While lacking their overwhelming pride and reliance on personal, innate power, they nevertheless have great hidden potential."
		visual = 'Halfie.png'

		power = 2
		strength = 1.25
		endurance = 1.25
		force = 1.25
		offense = 1
		defense = 1.5
		speed = 1
		anger = 1.5
		regeneration = 1.5
		imagination = 1
		intellect = 1.5
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Oozaru)
		passives = list("Tenacity" = 0.5, "Brutalize" = 0.25, "Adrenaline" = 0.5)
		class_info = list("Channeling humanity to pave a path forward in a murky future.", "Fight for your own justice.")
		stats_per_class = list("Compassion" = list(1.25, 1.75, 1.75, 1.25, 1.25, 1.5),"Justice" = list(1.75,1.5,1.75,1.25,1,1.25))
		classes = list("Compassion", "Justice")

		onFinalization(mob/user)
			..()

			if(user.Class == "Compassion")
				user.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Hidden_Potential)
				anger = 1.4
			else
				user.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Saiyan_Pride)

			if(!user.Tail)
				user.Tail(1)

			if(!islist(user.race.transformations))
				user.race.transformations = list()

			user.race.transformations.Cut()

			if(user.Class == "Compassion")
				for(var/transformation/saiyan/ssj in user.race.transformations)
					user.race.transformations -=ssj
					del ssj
				for(var/transformation/half_saiyan/UM in user.race.transformations)
					usr.race.transformations -=UM
					del UM
				user.race.transformations += new /transformation/saiyan/super_saiyan()
				user.race.transformations += new /transformation/saiyan/super_saiyan_2()
				user.race.transformations.Add(new/transformation/half_saiyan/human/ultimate_mode())
				user.race.transformations.Add(new/transformation/half_saiyan/human/beast_mode())
			else if(user.Class == "Justice")
				for(var/transformation/saiyan/ssj in user.race.transformations)
					user.race.transformations -=ssj
					del ssj
				for(var/transformation/half_saiyan/UM in user.race.transformations)
					user.race.transformations -=UM
					del UM
				user.race.transformations += new /transformation/saiyan/super_saiyan()
				user.race.transformations += new /transformation/saiyan/super_saiyan_2()
