// NOTE: HALF SAIYANS INHERIT SAIYAN TRANSFORMATIONS
race
	half_saiyan
		name = "Half_Saiyan"
		desc = "Half-breed Saiyans. While lacking their overwhelming pride and reliance on personal, innate power, they nevertheless have great hidden potential."
		visual = 'Halfie.png'

		locked = TRUE
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
		class_info = list("Channeling humanity to pave a path forward in a murky future", "Using their brutal heritage to channel the innate anger that comes with.")
		stats_per_class = list("Compassion" = list(1.25, 1.25, 1.25, 1.25, 1.25, 1.25),"Anger" = list(1.5,1.5,1.5,1,1,1))
		classes = list("Compassion", "Anger")

		onFinalization(mob/user)
			..()
			if(user.Class == "Compassion")
				user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Hidden_Potential)
				anger = 1.4
			else
				user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/HalfSaiyan/Saiyan_Pride)
			user.Tail(1)
			var/list/transpaths = subtypesof(text2path("/transformation/saiyan"))
			for(var/i in transpaths)
				transformations += new i