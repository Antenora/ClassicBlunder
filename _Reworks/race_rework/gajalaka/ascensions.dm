ascension
	gajalaka
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("CashCow" = 1)
			on_ascension_message = "Your goblin greed grows..."
			powerAdd = 0.25
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.Class
					switch(choice)
						if("Acolyte")
							strength = 0.25
							endurance = 0.25
							force = 0.25
							offense = 0.15
							speed = 0.15
							ecoAdd = 0.5
							passives = list("Tenacity" = 0.5, "CashCow" = 2, "Blubber" = 0.25)
						if("Rebel")
							strength = 0.25
							endurance = 0.5
							force = 0.25
							ecoAdd = -1
							intelligenceAdd = -0.5
							passives = list("Tenacity" = 1, "ShonenPower" = 0.25)
						if("Nobility")
							force = 0.5
							offense = 0.25
							defense = 0.5
							imaginationAdd = 0.5
							owner.passive_handler.Increase("ManaCapMult", 0.1)
						if("Heart")
							endurance = 0.5
							defense = 0.25
							strength = 0.25
							passives = list("Tenacity" = 1,"DebuffResistance" = 0.25, "DemonicDurability" = 0.25)
				..()

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("CashCow" = 1)
			on_ascension_message = "Your goblin greed grows..."
			anger = 0.15
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.Class
					switch(choice)
						if("Acolyte")
							strength = 0.25
							endurance = 0.25
							force = 0.25
							offense = 0.15
							speed = 0.15
							ecoAdd = 0.5
							passives = list("Tenacity" = 0.5, "CashCow" = 1, "Blubber" = 0.25)
						if("Rebel")
							strength = 0.25
							endurance = 0.5
							force = 0.25
							ecoAdd = -1
							intelligenceAdd = -0.5
							passives = list("Tenacity" = 1, "ShonenPower" = 0.25)
						if("Nobility")
							force = 0.5
							offense = 0.25
							defense = 0.5
							imaginationAdd = 0.5
							owner.passive_handler.Increase("ManaCapMult", 0.1)
						if("Heart")
							endurance = 0.5
							defense = 0.25
							strength = 0.25
							passives = list("Tenacity" = 1,"DebuffResistance" = 0.25, "DemonicDurability" = 0.25)
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			strength = 0.5
			endurance = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			speed = 0.5
			cyberizeModAdd = 0.1
			passives = list("CashCow" = 1)
			on_ascension_message = "Your goblin greed grows..."
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			strength = 0.5
			endurance = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			speed = 0.5
			cyberizeModAdd = 0.1
			passives = list("CashCow" = 1)
			on_ascension_message = "Your goblin greed grows..."
			enhanceChips = 1
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			strength = 0.5
			endurance = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			speed = 0.5
			cyberizeModAdd = 0.1
			passives = list("CashCow" = 1)
			on_ascension_message = "Your goblin greed grows..."
			enhanceChips = 2