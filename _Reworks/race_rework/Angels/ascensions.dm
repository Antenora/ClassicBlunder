ascension
	angel
		passives = list()
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("HolyMod" = 0.25, "SpiritPower" = 0.25)
			strength = 0.25
			endurance = 0.25
			speed = 0.25
			recovery = 0.25
			on_ascension_message = "Your authority strengthens."
			postAscension(mob/owner)
				..()
				owner.Class = "Principality"
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("HolyMod" = 0.75, "SpiritPower" = 0.25)
			strength = 0.15
			force = 0.25
			defense = 0.35
			offense = 0.15
			recovery = 0.25
			on_ascension_message = "You grow ever-closer to God."
			postAscension(mob/owner)
				//t2 style
				..()
				owner.Class = "Power"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("HolyMod" = 1, "SpiritPower" = 0.25, " KiControlMastery"=1,  "CalmAnger" = 1)
			anger = 0.2
			strength = 0.25
			force = 0.25
			endurance = 0.5
			on_ascension_message = "You shall not abide evil."
			postAscension(mob/owner)
				//t3 style/armor, can now teach style
				..()
				owner.Class = "Virtue"
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("HolyMod" = 2, "TechniqueMastery" = 1)
			strength = 0.25
			force = 0.25
			defense = 0.75
			offense = 0.75
			endurance = 0.25
			speed = 0.75
			recovery = 0.25
			on_ascension_message = "You shall not abide evil."
			postAscension(mob/owner)
				//t4 style
				..()
				owner.Class = "Dominion"
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("SpiritPower" = 0.25)
			intimidation = 250
			on_ascension_message = "When closing your eyes, you bear witness to His heavenly throne."
			postAscension(mob/owner)
				..()
				owner.Class = "Throne"