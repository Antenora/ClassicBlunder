ascension
	changeling
		one
			unlock_potential	=	ASCENSION_ONE_POTENTIAL
			intimidation = 3
			endurance = 0.25
			passives = list("PureReduction" = 2)
			on_ascension_message = "Your prowess grows!"
			postAscension(mob/owner)
				. = ..()
				owner.BioArmorMax += 25
				if(owner.transUnlocked < 1)
					owner.transUnlocked = 1
				

		two
			unlock_potential	=	ASCENSION_TWO_POTENTIAL
			intimidation = 3
			endurance = 0.25
			passives = list("PureReduction" = 2)
			on_ascension_message = "Your prowess grows!"
			postAscension(mob/owner)
				. = ..()
				owner.BioArmorMax += 50
				if(owner.transUnlocked < 2)
					owner.transUnlocked = 2
		three
			unlock_potential	=	ASCENSION_THREE_POTENTIAL
			intimidation = 3
			endurance = 0.25
			passives = list("PureReduction" = 2)
			on_ascension_message = "Your prowess grows!"
			postAscension(mob/owner)
				. = ..()
				owner.BioArmorMax += 75
				if(owner.transUnlocked < 3)
					owner.transUnlocked = 3
		four
			unlock_potential	=	ASCENSION_FOUR_POTENTIAL
			intimidation = 3
			endurance = 0.25
			passives = list("PureReduction" = 2)
			choices = list("100% Power" = /ascension/sub_ascension/changeling/hundred_percent, "Fifth Form" = /ascension/sub_ascension/changeling/fifth_form)
			on_ascension_message = "Your prowess grows!"

		five
			unlock_potential	=	ASCENSION_FIVE_POTENTIAL
			intimidation = 3
			endurance = 0.25
			passives = list("PureReduction" = 2)
			on_ascension_message = "Your prowess grows!"

ascension
	sub_ascension
		changeling
			hundred_percent
				skills = list(/obj/Skills/Buffs/SpecialBuffs/OneHundredPercentPower)
			fifth_form
				onAscension(mob/owner)
					. = ..()
					owner.transUnlocked = 4