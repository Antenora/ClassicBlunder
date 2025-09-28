ascension
	eldritch
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			endurance = 0.25
			defense = 0.25
			speed = 0.25
			passives = list("DebuffResistance" = 0.25, "VenomResistance" = 0.25, "SoulFire" = 0.25, "DeathField" = 1, "VoidField" =1,)
			postAscension(mob/owner)
				owner.secretDatum.tierUp(2, owner)
				..()
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			endurance = 0.25
			defense = 0.25
			speed = 0.25
			passives = list("DebuffResistance" = 0.25, "VenomResistance" = 0.25,"SoulFire" = 0.15, "DeathField" = 1, "VoidField" = 1)
			postAscension(mob/owner)
				owner.secretDatum.tierUp(3, owner)
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			strength = 0.25
			endurance = 0.25
			force = 0.25
			offense = 0.25
			defense = 0.25
			speed = 0.25
			passives = list("DebuffResistance" = 0.25, "VenomResistance" = 0.5,"SoulFire" = 0.15, "DeathField" = 3, "VoidField" = 3)
			postAscension(mob/owner)
				owner.secretDatum.tierUp(4, owner)
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			strength = 0.25
			endurance = 0.25
			force = 0.25
			offense = 0.25
			defense = 0.25
			speed = 0.25
			passives = list("DebuffResistance" = 0.25, "VenomResistance" = 0.5, "SoulFire" = 0.15, "DeathField" = 2, "VoidField" = 2)
			postAscension(mob/owner)
				owner.secretDatum.tierUp(5, owner)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			strength = 0.25
			endurance = 0.25
			force = 0.25
			offense = 0.25
			defense = 0.25
			speed = 0.25
			passives = list("DebuffResistance" = 0.25, "VenomResistance" = 0.5,"SoulFire" = 0.15, "DeathField" = 3, "VoidField" = 3)
			postAscension(mob/owner)
				owner.secretDatum.tierUp(6, owner)
				..()