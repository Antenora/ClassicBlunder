ascension
	yokai
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("TechniqueMastery" = 1, "Touch of Death" = 1)
			strength = 0.25
			force = 0.25
			offense = 0.5
			choices = list("Grand Caster" = /ascension/sub_ascension/yokai/grand_caster, "Two become One" = /ascension/sub_ascension/yokai/two_become_one)

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			strength = 0.25
			force = 0.25
			offense = 0.25
			passives = list("Touch of Death" = 1)
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/grand_caster)
					passives["ManaGeneration"] = 1
					passives["QuickCast"] = 2
					passives["ManaCapMult"] = 0.25
					passives["ManaStats"] = 0.25
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/two_become_one)
					passives = list("MovementMastery" = 1, "ManaStats" = 0.5)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form/sf in owner.contents)
						sf.passives["TechniqueMastery"] = 0
						sf.passives["ManaStats"] = 0
				..()

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			strength = 0.25
			force = 0.25
			offense = 0.25
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/grand_caster)
					passives["ManaGeneration"] = 1
					passives["QuickCast"] = 1
					passives["ManaCapMult"] = 0.25
					passives["SpiritStrike"] = 0.25
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/two_become_one)
					passives = list("MovementMastery" = 2, "ManaStats" = 0.25)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form/sf in owner.contents)
						sf.passives["TechniqueMastery"] = 2
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			strength = 0.25
			force = 0.25
			endurance = 0.25
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/grand_caster)
					passives["SpiritStrike"] = 0.25
					passives["ManaCapMult"] = 0.25
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/two_become_one)
					passives = list("MovementMastery" = 2, "ManaStats" = 0.25)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form/sf in owner.contents)
						sf.ManaDrain -= 0.05
				..()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			strength = 0.25
			force = 0.25
			endurance = 0.25
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/grand_caster)
					passives["SpiritStrike"] = 0.75
					passives["ManaCapMult"] = 0.25
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/yokai/two_become_one)
					passives = list("MovementMastery" = 2, "ManaStats" = 0.5)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form/sf in owner.contents)
						sf.ManaDrain = 0
				..()


ascension
	sub_ascension
		yokai
			grand_caster
				passives = list("QuickCast" = 1, "ManaGeneration" = 2)
				offense = 0.25
				force = 0.25

			two_become_one
				passives = list( "ManaStats" = 0.25)
				onAscension(mob/owner)
					for(var/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form/sf in owner.contents)
						sf.passives["TechniqueMastery"] = -1
					..()