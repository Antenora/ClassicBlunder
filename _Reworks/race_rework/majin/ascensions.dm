ascension
	majin
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Innocence" = /ascension/sub_ascension/majin/innocence, "Super" = /ascension/sub_ascension/majin/super, "Unhinged" = /ascension/sub_ascension/majin/unhinged)
			anger = 0.1
			intimidation = 15
			imaginationAdd = 0.2

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			choices = list("Harness Evil" = /ascension/sub_ascension/majin/harness_evil, "Remain Consistent" = /ascension/sub_ascension/majin/remain_consistent, "Become Docile" = /ascension/sub_ascension/majin/become_docile)
			intimidation = 15
			anger = 0.1
			imaginationAdd = 0.25

			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/innocence)
					endurance = 0.1
					defense = 0.1
					strength = 0.05
					speed = -0.05
					passives = list("Blubber" = 0.5, "CallousedHands" = 0.15)
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/super)
					strength = 0.1
					endurance = 0.1
					defense = 0.1
					speed = 0.1
					force = 0.1
					offense = 0.1
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/unhinged)
					strength = 0.15
					defense = -0.1
					force = 0.15
					endurance = -0.1
					passives = list("UnhingedForm" = 0.25)
				..()

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			choices = list("Harness Evil" = /ascension/sub_ascension/majin/harness_evil, "Remain Consistent" = /ascension/sub_ascension/majin/remain_consistent, "Become Docile" = /ascension/sub_ascension/majin/become_docile)
			intimidationMult = 0.5
			anger = 0.1

			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/innocence)
					endurance = 0.25
					defense = 0.15
					strength = 0.15
					passives = list("Blubber" = 1, "CallousedHands" = 0.15)
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/super)
					strength = 0.25
					endurance = 0.25
					defense = 0.25
					speed = 0.25
					force = 0.25
					offense = 0.25
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/unhinged)
					strength = 0.15
					defense = -0.1
					force = 0.15
					endurance = -0.1
					speed = 0.25
					passives = list("UnhingedForm" = 0.5)
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			choices = list("Harness Evil" = /ascension/sub_ascension/majin/harness_evil, "Remain Consistent" = /ascension/sub_ascension/majin/remain_consistent, "Become Docile" = /ascension/sub_ascension/majin/become_docile)
			intimidation = 10
			anger = 0.15
			imaginationAdd = 0.2

			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/innocence)
					endurance = 0.2
					defense = 0.2
					strength = 0.1
					passives = list("Blubber" = 1, "CallousedHands" = -0.6, "HardenedFrame" = 1)
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/super)
					strength = 0.1
					endurance = 0.1
					defense = 0.1
					speed = 0.1
					force = 0.1
					offense = 0.1
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/unhinged)
					strength = 0.2
					defense = -0.1
					force = 0.2
					endurance = -0.1
					speed = 0.25
					passives = list("UnhingedForm" = 0.5)
				..()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			choices = list("Harness Evil" = /ascension/sub_ascension/majin/harness_evil, "Remain Consistent" = /ascension/sub_ascension/majin/remain_consistent, "Become Docile" = /ascension/sub_ascension/majin/become_docile)
			intimidation = 10

			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/innocence)
					endurance = 0.25
					defense = 0.2
					strength = 0.2
					passives = list("Blubber" = 1)
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/super)
					strength = 0.05
					endurance = 0.05
					defense = 0.05
					speed = 0.05
					force = 0.05
					offense = 0.05
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/majin/unhinged)
					strength = 0.2
					offense = 0.2
					force = 0.15
					speed = 0.2
					passives = list("UnhingedForm" = 0.5)
					anger = 0.15
				..()

ascension
	sub_ascension
		majin
			innocence
				choices = list("Harness Evil" = /ascension/sub_ascension/majin/harness_evil, "Remain Consistent" = /ascension/sub_ascension/majin/remain_consistent, "Become Docile" = /ascension/sub_ascension/majin/become_docile)
				endurance = 0.3
				defense  = 0.3
				speed = -0.1
				passives = list("Blubber" = 1, "CallousedHands" = 0.15, "Adaptation" = 1)

			super
				choices = list("Harness Evil" = /ascension/sub_ascension/majin/harness_evil, "Remain Consistent" = /ascension/sub_ascension/majin/remain_consistent, "Become Docile" = /ascension/sub_ascension/majin/become_docile)
				strength = 0.125
				force = 0.125
				endurance = 0.125
				speed = 0.125
				offense = 0.125
				defense = 0.125
				passives = list("FluidForm" = 1, "Adaptation" = 1)

			unhinged
				choices = list("Harness Evil" = /ascension/sub_ascension/majin/harness_evil, "Remain Consistent" = /ascension/sub_ascension/majin/remain_consistent, "Become Docile" = /ascension/sub_ascension/majin/become_docile)
				strength = 0.3
				endurance = -0.2
				defense = -0.2
				offense = 0.3
				passives = list("UnhingedForm" = 1)
				angerPoint = 5

			harness_evil
				choices = list("Brutality" = /ascension/sub_ascension/majin/harness_evil/brutality, "Anger" = /ascension/sub_ascension/majin/harness_evil/anger, "Both" = /ascension/sub_ascension/majin/harness_evil/both)
				brutality
					choices = list()
					passives = list("UnhingedForm" = 0.25, "Pursuer" = 1)

				anger
					choices = list()
					angerPoint = 5
					passives = list("DemonicDurability" = 0.25)

					onAscension(mob/owner)
						if(angerPoint+owner.AngerPoint > 65)
							passives["EndlessAnger"] = 1
						..()

				both
					choices = list()
					angerPoint = 2.5
					passives = list("DemonicDurability" = 0.175, "UnhingedForm" = 0.175, "Pursuer" = 0.5)
					onAscension(mob/owner)
						if(angerPoint+owner.AngerPoint > 65)
							passives["EndlessAnger"] = 1
						..()

			remain_consistent
				choices = list("Adaptability" = /ascension/sub_ascension/majin/remain_consistent/adaptability, "Consistency" = /ascension/sub_ascension/majin/remain_consistent/consistency, "Both" = /ascension/sub_ascension/majin/remain_consistent/both)
				adaptability
					choices = list()
					passives = list("Adaptation" = 0.2, "Flicker" = 1, "Hustle" = 0.15)

				consistency
					choices = list()
					passives = list("Steady" = 0.25, "DebuffResistance" = 0.15, "StableBP" = 0.5)

				both
					choices = list()
					passives = list("Adaptation" = 0.1, "Flicker" = 0.5, "Hustle" = 0.075, "Steady" = 0.175, "DebuffResistance" = 0.075, "StableBP" = 0.25)

			become_docile
				choices = list("Stability" = /ascension/sub_ascension/majin/become_docile/stability, "Peace" = /ascension/sub_ascension/majin/become_docile/peace, "Both" = /ascension/sub_ascension/majin/become_docile/both)
				stability
					choices = list()
					passives = list("VenomResistance" = 0.25, "DebuffResistance" = 0.25, "Juggernaut" = 0.5)

					onAscension(mob/owner)
						if(owner.passive_handler.Get("Juggernaut")+passives["Juggernaut"] >= 1)
							passives["GiantForm"] =1
						..()

				peace
					choices = list()
					passives = list("Flow" = 0.5, "DeathField" = 0.5, "VoidField" = 0.5)

				both
					choices = list()
					passives = list("VenomResistance" = 0.25, "DebuffResistance" = 0.25, "Juggernaut" = 0.25, "Flow" = 0.25, "DeathField" = 0.25, "VoidField" = 0.25)

					onAscension(mob/owner)
						if(owner.passive_handler.Get("Juggernaut")+passives["Juggernaut"] >= 1)
							passives["GiantForm"] =1
						..()