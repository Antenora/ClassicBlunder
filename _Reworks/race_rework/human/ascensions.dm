/ascension/sub_ascension/human/hero
	passives = list("UnderDog" = 1)
	offense = 0.25
	strength = 0.25
	force = 0.25

/ascension/sub_ascension/human/innovative
	passives = list("Persistence" = 1)
	defense = 0.25
	endurance = 0.25



ascension
	human
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Hero" = /ascension/sub_ascension/human/hero, "Innovative" = /ascension/sub_ascension/human/innovative)
			passives = list("Tenacity" = 1, "Shonen" = 1, "ShonenPower" = 0.15)
			new_anger_message = "grows desperate!"
			on_ascension_message = "You learn the meaning of desperation..."
			anger = 0.1
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("Tenacity" = 1, "Shonen" = 1, "ShonenPower" = 0.15)
			new_anger_message = "grows determined!"
			on_ascension_message = "You learn the meaning of responsibility..."
			anger = 0.1
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/hero)
					passives["UnderDog"] = 1
					passives["Adrenaline"] = 2
					offense = 0.25
					strength = 0.25
					force = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/innovative)
					passives["Persistence"] = 1
					passives["Adaptation"] = 1
					defense = 0.5
					endurance = 0.25
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("Tenacity" = 1, "DemonicDurability" = 0.5)
			new_anger_message="grows confident!"
			on_ascension_message = "You learn the meaning of confidence..."
			anger = 0.1
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/hero)
					passives["UnderDog"] = 1
					defense = 0.25
					endurance = 0.25
					offense = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/innovative)
					passives["Persistence"] = 1
					defense = 0.25
					endurance = 0.25
					strength = 0.25
					force = 0.25
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("Tenacity" = 1, "DemonicDurability" = 0.5)
			new_anger_message = "gains absolute clarity!"
			on_ascension_message = "You learn the meaning of competence..."
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/hero)
					passives["UnderDog"] = 1
					defense = 0.25
					endurance = 0.25
					offense = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/innovative)
					passives["Persistence"] = 1
					defense = 0.25
					endurance = 0.25
					strength = 0.25
					force = 0.25
				..()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list( "Tenacity" = 1, "DemonicDurability" = 0.5)
			new_anger_message = "becomes angry!"
			on_ascension_message = "You learn the meaning of humanity..."
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/hero)
					passives["UnderDog"] = 1
					defense = 0.25
					endurance = 0.25
					offense = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/human/innovative)
					passives["Persistence"] = 1
					defense = 0.25
					endurance = 0.25
					strength = 0.25
					force = 0.25
				..()