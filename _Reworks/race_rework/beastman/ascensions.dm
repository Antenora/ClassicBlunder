ascension
	beastman
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			anger = 0.05
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastman")
							owner.passive_handler.Increase("Adrenaline", 1)
							endurance = 0.25
							strength = 0.5
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							endurance = 0.15
							strength = 0.15
							offense = 0.15
							defense = 0.15
							speed = 0.15
							force = 0.15
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 0.5)
							strength = 0.25
							offense = 0.25
							speed = 0.25
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.05)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.5
							speed = 0.5
							offense = 0.25
							defense = -0.25
							endurance = -0.25
							anger = 0.25
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 25)
							owner.passive_handler.Increase("CriticalBlock", 0.15)
							endurance = 0.5
							defense = 0.5
							strength = -0.25
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 25)
							owner.passive_handler.Increase("CriticalDamage", 0.15)
							offense = 0.5
							speed = 0.25
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 1)
							owner.passive_handler.Increase("Instinct", 1)
							endurance = 0.25
							strength = 0.1
							offense = 0.2
							defense = 0.2
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							endurance = 0.1
							strength = 0.1
							offense = 0.1
							defense = 0.1
							speed = 0.1
							force = 0.1
						
						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("Soulfire", 1)
							offense = 0.25
							force = 0.5
				..()
				if(!applied)
					if(owner.Class == "Shapeshifter")
						var/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Shapeshift/s = owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Shapeshift)
						s.c_buff.adjust_custom_buff(owner, s)
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			anger = 0.1
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastman")
							owner.passive_handler.Increase("Blubber", 0.25)
							endurance = 0.25
							strength = 0.25
							speed = 0.25
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							endurance = 0.15
							strength = 0.15
							offense = 0.15
							defense = 0.15
							speed = 0.15
							force = 0.15
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 0.5)
							strength = 0.25
							offense = 0.25
							speed = 0.25
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.1)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.5
							speed = 0.25
							offense = 0.25
							defense = -0.25
							endurance = -0.25
							anger = 0.5
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 10)
							owner.passive_handler.Increase("CriticalBlock", 0.1)
							speed = 0.5
							offense = 0.25
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 10)
							owner.passive_handler.Increase("CriticalDamage", 0.1)
							strength = 0.25
							speed = 0.25
							endurance = 0.25
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 2)
							owner.passive_handler.Increase("Instinct", 2)
							force = 0.25
							strength = 0.25
							endurance = 0.25
						if("Shapeshifter")
							owner << "currently not working"
						
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							endurance = 0.1
							strength = 0.1
							offense = 0.1
							defense = 0.1
							speed = 0.1
							force = 0.1
						
						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("Soulfire", 1)
							offense = 0.25
							force = 0.5
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastman")
							owner.passive_handler.Increase("Blubber", 0.25)
							endurance = 0.25
							strength = 0.25
							speed = 0.25
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							endurance = 0.15
							strength = 0.15
							offense = 0.15
							defense = 0.15
							speed = 0.15
							force = 0.15
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 0.5)
							strength = 0.25
							offense = 0.25
							speed = 0.25
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.1)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.5
							speed = 0.25
							offense = 0.25
							defense = -0.25
							endurance = -0.25
							anger = 0.5
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 10)
							owner.passive_handler.Increase("CriticalBlock", 0.1)
							speed = 0.5
							offense = 0.25
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 10)
							owner.passive_handler.Increase("CriticalDamage", 0.1)
							strength = 0.25
							speed = 0.25
							endurance = 0.25
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 2)
							owner.passive_handler.Increase("Instinct", 2)
							force = 0.25
							strength = 0.25
							endurance = 0.25
						if("Shapeshifter")
							owner << "currently not working"
						
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							endurance = 0.1
							strength = 0.1
							offense = 0.1
							defense = 0.1
							speed = 0.1
							force = 0.1
						
						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("Soulfire", 1)
							offense = 0.25
							force = 0.5
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL

			postAscension(mob/owner)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL

			postAscension(mob/owner)
				..()


/ascension/sub_ascension/beastman/ferocious

/ascension/sub_ascension/beastman/nimble

/ascension/sub_ascension/beastman/niche