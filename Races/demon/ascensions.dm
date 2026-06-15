ascension
	demon
		passives = list()
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 0.25, "SpiritPower" = 0.25, "HellRisen" = 0.5, "AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 2, "Juggernaut" = 1)
			anger = 0.15
			intimidation = 50
			strength = 0.25
			endurance = 0.25
			speed = 0.25
			on_ascension_message = "You evolve into a stronger demon..."
			postAscension(mob/owner)
				if(!applied)
					owner.demon.selectPassive(owner, "CORRUPTION_PASSIVES", "Buff")
					owner.demon.selectPassive(owner, "CORRUPTION_DEBUFFS", "Debuff")
				..()
				owner.Class = "B"

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 0.75, "SpiritPower" = 0.25, "HellRisen" = 0.25, "AngerAdaptiveForce" = 0.1, "TechniqueMastery" = 1, "Juggernaut" = 0.5, "FluidForm" = 1)
			intimidation = 50
			strength = 0.25
			force = 0.5
			defense = 0.25
			offense = 0.25
			anger = 0.1
			on_ascension_message = "Your power is unrivaled..."
			postAscension(mob/owner)
				if(!applied)
					owner.demon.selectPassive(owner, "CORRUPTION_PASSIVES", "Buff")
					owner.demon.selectPassive(owner, "CORRUPTION_DEBUFFS", "Debuff")
				..()
				owner.Class = "A"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			choices = list("Lust" = /ascension/sub_ascension/demon/lust, "Greed" = /ascension/sub_ascension/demon/greed, "Envy" = /ascension/sub_ascension/demon/envy, "Sloth" = /ascension/sub_ascension/demon/sloth, "Gluttony" = /ascension/sub_ascension/demon/gluttony, "Wrath" = /ascension/sub_ascension/demon/wrath, "Pride" = /ascension/sub_ascension/demon/pride)
			passives = list("HellPower" = 0.25, "AbyssMod" = 1, "SpiritPower" = 0.25, "AngerAdaptiveForce" = 0.05, "TechniqueMastery" = 1, "FluidForm" = 0.5, "Juggernaut" = 0.5)
			anger = 0.2
			intimidation = 100
			strength = 0.25
			force = 0.25
			endurance = 0.5
			postAscension(mob/owner)
				..()
				owner.Class = "S"
				if(src.choiceSelected == /ascension/sub_ascension/demon/gluttony)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Gluttonous_Feast) in owner)
						owner.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Gluttonous_Feast)
				if(src.choiceSelected == /ascension/sub_ascension/demon/envy)
					if(!locate(/obj/Skills/AutoHit/I_Want_To_Be_Like_You) in owner)
						owner.AddSkill(new /obj/Skills/AutoHit/I_Want_To_Be_Like_You)
				if(src.choiceSelected == /ascension/sub_ascension/demon/lust)
					if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Object_of_Desire) in owner)
						owner.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Object_of_Desire)
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 2, "AngerAdaptiveForce" = 0.25, "TechniqueMastery" = 2, "FluidForm" = 0.5)
			anger = 0.15
			intimidation = 250
			strength = 0.25
			force = 0.25
			defense = 0.75
			offense = 0.75
			endurance = 0.25
			speed = 0.75
			postAscension(mob/owner)
				..()
				owner.Class = "False King"
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("HellPower" = 1, "EndlessAnger" = 1, "SpiritPower" = 0.25)
			intimidation = 250

			postAscension(mob/owner)
				..()
				owner.Class = "Maou"
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			intimidation = 250

			postAscension(mob/owner)
				..()
				owner.Class = "Mazoku"

/ascension/sub_ascension/demon/lust
	choices = list("Sadism" = /ascension/sub_ascension/demon/lust/sadism, "Masochism" = /ascension/sub_ascension/demon/lust/masochism)
	passives = list("LustFactor" = 1)
	sadism
		choices = list()
		passives = list("Sadist" = 1)
	masochism
		choices = list()
		passives = list("Masochist" = 1)

/ascension/sub_ascension/demon/greed
	passives = list("GreedFactor" = 1)

/ascension/sub_ascension/demon/envy
	passives = list("EnvyFactor" = 1)

/ascension/sub_ascension/demon/sloth
	passives = list("SlothFactor" = 1)

/ascension/sub_ascension/demon/gluttony
	passives = list("GluttonyFactor" = 1)

/ascension/sub_ascension/demon/wrath
	passives = list("WrathFactor" = 1)

/ascension/sub_ascension/demon/pride
	passives = list("PrideFactor" = 1)