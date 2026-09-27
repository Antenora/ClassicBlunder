ascension
	changeling
		one
			unlock_potential	=	ASCENSION_ONE_POTENTIAL+15
			passives = list()
			on_ascension_message = "Your prowess grows!"
			postAscension(mob/owner)
				. = ..()


		two
			unlock_potential	=	ASCENSION_TWO_POTENTIAL+10
			passives = list()
			on_ascension_message = "Your prowess grows!"
			postAscension(mob/owner)
				. = ..()
		three
			unlock_potential	=	ASCENSION_THREE_POTENTIAL
			endurance = 0.25
			passives = list()
			on_ascension_message = "Your prowess grows!"
			postAscension(mob/owner)
				. = ..()
		four
			unlock_potential	=	ASCENSION_FOUR_POTENTIAL
			endurance = 0.25
			passives = list()
			on_ascension_message = "Your prowess grows!"

		five
			unlock_potential	=	ASCENSION_FIVE_POTENTIAL
			endurance = 0.25
			passives = list()
			on_ascension_message = "Your prowess grows!"
		six
			unlock_potential	=	ASCENSION_SIX_POTENTIAL
			endurance = 0.25
			passives = list()
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