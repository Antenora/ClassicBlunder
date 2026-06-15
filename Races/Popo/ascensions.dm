ascension
	popo
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("Persistence" = 1, "Adrenaline" = 1, "TechniqueMastery" = 1, "UnderDog" = 3, "CashCow" = 1, "ManaGeneration" =1 , "QuickCast" = 1, "Holding Back" = -1, "MovementMastery" = 6)
			on_ascension_message = "You come to understand the pecking order."
			strength = 1
			force = 1
			endurance = 1
			offense = 1
			defense = 1
			speed = 1.5
			recovery = 1
			postAscension(mob/owner)
				..()
				owner.Class = "The Dirt"

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("Persistence" = 1, "Adrenaline" = 1, "TechniqueMastery" = 1, "UnderDog" = 5, "CashCow" = 1, "ManaGeneration" =1, "QuickCast" = 1, "Holding Back" = -1, "MovementMastery" = 10)
			strength = 2
			force = 2
			endurance = 2
			offense = 2
			defense = 2
			speed = 2.5
			recovery = 2
			postAscension(mob/owner)
				..()
				owner.Class = "The Worms Inside The Dirt"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("Persistence" = 1, "Adrenaline" = 1, "TechniqueMastery" = 1, "UnderDog" = 5, "CashCow" = 1, "ManaGeneration" =1, "QuickCast" = 1, "Holding Back" = -1, "MovementMastery" = 10)
			strength = 3
			force = 3
			endurance = 3
			offense = 3
			defense = 3
			speed = 3.5
			recovery = 3
			postAscension(mob/owner)
				..()
				owner.Class = "Popo's Stool"
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("Persistence" = 1, "Adrenaline" = 1, "TechniqueMastery" = 1, "UnderDog" = 5, "CashCow" = 1, "ManaGeneration" =1, "QuickCast" = 1, "Holding Back" = -1, "MovementMastery" = 10)
			strength = 4
			force = 4
			endurance = 4
			offense = 4
			defense = 4
			speed = 4.5
			recovery = 4
			postAscension(mob/owner)
				..()
				owner.Class = "Kami"
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("Persistence" = 1, "Adrenaline" = 1, "TechniqueMastery" = 1, "UnderDog" = 5, "CashCow" = 1, "ManaGeneration" =1, "QuickCast" = 1, "Holding Back" = -1, "MovementMastery" = 10)
			strength = 5
			force = 5
			endurance = 5
			offense = 5
			defense = 5
			speed = 5.5
			recovery = 5
			on_ascension_message = "You finally sit atop the pecking order."
			postAscension(mob/owner)
				..()
				owner.Class = "Popo"
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list("Tenacity" = 20, "Adrenaline" = 1, "TechniqueMastery" = 1, "UnderDog" = 5, "CashCow" = 1, "ManaGeneration" =1, "QuickCast" = 1, "Holding Back" = -5, "MovementMastery" = 20)
			strength = 6
			force = 6
			endurance = 6
			offense = 6
			defense = 6
			speed = 6.5
			recovery = 6
			on_ascension_message = "You finally sit atop the pecking order."
			postAscension(mob/owner)
				..()
				owner.Class = "Dumplin'"
