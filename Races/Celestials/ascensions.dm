ascension
	celestial
		passives = list()
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("SpiritPower" = 0.25)
			anger = 0.25
			strength = 0.25
			force = 0.25
			endurance = 0.25
			speed = 0.25
			recovery = 0.25
			on_ascension_message = "You become more in-tune with your otherworldly nature."
			postAscension(mob/owner)
				..()
				owner.Class = "Pale Imitation"
				if(owner.CelestialAscension=="Angel")
					owner.passive_handler.Increase("Persistence", 2)
					owner.passive_handler.Increase("SpiritSword", 0.5)
					spawn(5)
						if(owner && owner.client)
							owner.ChooseCelestialWeapon()
				if(owner.CelestialAscension=="Demon")
					owner.passive_handler.Set("Stylish", 1)
					if(!applied)
						owner.demon.selectPassive(owner, "CORRUPTION_PASSIVES", "Buff")
						owner.demon.selectPassive(owner, "CORRUPTION_DEBUFFS", "Debuff")

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("SpiritPower" = 0.25, "TechniqueMastery" = 1)
			strength = 0.25
			force = 0.25
			defense = 0.25
			offense = 0.25
			recovery = 0.25
			anger = 0.1
			on_ascension_message = "You start to better understand your purpose."
			postAscension(mob/owner)
				..()
				owner.Class = "Lightbringer"
				if(owner.CelestialAscension=="Angel")
					owner.passive_handler.Increase("DivineArmory", 1)
					owner.passive_handler.Increase("Juggernaut", 1)
					owner.passive_handler.Increase("Steady", 2.5)
					owner.passive_handler.Increase("MovementMastery", 5)
					spawn(5)
						if(owner && owner.client)
							owner.ChooseCelestialWeapon()
				if(owner.CelestialAscension=="Demon")
					if(!applied)
						owner.demon.selectPassive(owner, "CORRUPTION_PASSIVES", "Buff")
						owner.demon.selectPassive(owner, "CORRUPTION_DEBUFFS", "Debuff")
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("SpiritPower" = 0.5, "TechniqueMastery" = 2)
			anger = 0.25
			strength = 0.25
			force = 0.25
			endurance = 0.25
			recovery = 0.35
			postAscension(mob/owner)
				..()
				if(owner.CelestialAscension=="Angel")
					owner.passive_handler.Increase("DebuffResistance", 1)
					owner.passive_handler.Increase("LifeGeneration", 1)
					owner.passive_handler.Increase("Pressure", 3)
					owner.passive_handler.Increase("Anaerobic", 1)
					spawn(5)
						if(owner && owner.client)
							owner.ChooseCelestialWeapon()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("KiControlMastery"=2)
			anger = 0.3
			strength = 0.25
			force = 0.25
			defense = 0.75
			offense = 0.75
			endurance = 0.25
			recovery = 0.3
			speed = 0.75
			postAscension(mob/owner)
				..()
				if(owner.CelestialAscension=="Angel")
					owner.passive_handler.Increase("SpiritSword", 0.5)
					owner.passive_handler.Increase("BlurringStrikes", 1.5)
					owner.passive_handler.Increase("DoubleStrike", 0.5)
					owner.passive_handler.Increase("TripleStrike", 0.5)
					spawn(5)
						if(owner && owner.client)
							owner.ChooseCelestialWeapon()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("SpiritPower" = 1)

			postAscension(mob/owner)
				..()
				owner.Class = "Transcendent"
				if(owner.CelestialAscension=="Angel")
					owner.passive_handler.Increase("Purity", 1)
					owner.passive_handler.Increase("BeyondPurity", 1)
					spawn(5)
						if(owner && owner.client)
							owner.ChooseCelestialWeapon()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list("SpiritPower" = 1)

			postAscension(mob/owner)
				..()
				owner.Class = "Transcendent"
				if(owner.CelestialAscension=="Angel")
					spawn(5)
						if(owner && owner.client)
							owner.ChooseCelestialWeapon()
