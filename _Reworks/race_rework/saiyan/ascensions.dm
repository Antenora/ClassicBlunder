ascension
	saiyan
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Pride" = /ascension/sub_ascension/saiyan/pride, "Honor" =  /ascension/sub_ascension/saiyan/honor, "Zeal" = /ascension/sub_ascension/saiyan/zeal)
			intimidation = 4
			passives = list("Brutalize" = 0.25)
			// GIVE MY NIGGAS SOMETHING TO EAT WITH
			strength = 0.25
			endurance = 0.25

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			anger = 0.25
			intimidation = 1.25
			passives = list("Brutalize" = 0.5)
			strength = 0.25
			defense = 0.25
			endurance = 0.25
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					passives += list("Adaptation" = 0.5)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					passives += list("AngerAdaptiveForce" = 0.2, "Adrenaline" = 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					passives += list("Steady" = 1, "PureDamage" = 1)
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			intimidation = 1.5
			passives = list("Brutalize" = 0.5)
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					passives += list("Adaptation" = 0.5)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					passives += list("AngerAdaptiveForce" = 0.2, "Juggernaut" = 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					passives += list("Steady" = 1, "PureDamage" = 1)
				..()
		four
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			intimidation = 1.5
			anger = 0.25
			passives = list("Brutalize" = 1)
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					passives += list("Adaptation" = 0.5)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					passives += list("AngerAdaptiveForce" = 0.2, "Adrenaline" = 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					passives += list("Steady" = 1, "PureDamage" = 0.5)
				..()
		five
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			intimidation = 1.5
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/zeal)
					passives += list("Adaptation" = 0.5)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/honor)
					passives += list("AngerAdaptiveForce" = 0.2, "Adrenaline" = 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/saiyan/pride)
					passives += list("Steady" = 1, "PureDamage" = 1)
				..()

ascension
	sub_ascension
		saiyan
			honor
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Grit)
				passives = list("Defiance" = 1, "Juggernaut" = 0.5)

			pride
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Dominance)
				passives = list("Pride" = 1, "PureDamage" = 0.5)

			zeal
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Soul)
				passives = list("Adaptation" = 0.5)