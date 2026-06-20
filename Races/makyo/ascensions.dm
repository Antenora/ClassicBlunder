ascension
	makyo
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("Juggernaut" = 0.5, "DemonicDurability" = 1, "HeavyHitter" = 0.5, "Trample" = 1, "Adrenaline" = 1)
			skills = list(/obj/Skills/Buffs/SlotlessBuffs/Makyo/Expand)
			strength = 1
			endurance = 1
			offense = 0.25
			force = 0.25
			intimidation = 25
			anger = 0.15
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("Pressure" = 1, "DemonicDurability" = 1, "HeavyHitter" = 0.5, "Adrenaline" = 2)
			endurance = 1.25
			strength = 1.25
			force = 0.5
			offense = 0.5
			intimidation = 50
			anger = 0.15
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("Juggernaut" = 1, "DemonicDurability" = 1, "HeavyHitter" = 0.5, "Pressure" = 1, "SweepingStrike" = 1)
			strength = 1.75
			endurance = 1.75
			force = 1.25
			offense = 1.25
			intimidation = 50
			anger = 0.15
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("Juggernaut" = 1, "DemonicDurability" = 1, "HeavyHitter" = 1, "Pressure" = 1, "Adrenaline" = 2)
			strength = 2.5
			endurance = 2.5
			force = 1.5
			offense = 1.5
			intimidation = 25
			anger = 0.15
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("Juggernaut" = 1, "DemonicDurability" = 1, "HeavyHitter" = 2, "Pressure" = 1)
			strength = 2.75
			endurance = 2.75
			force = 1.75
			intimidation = 25

		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list("Juggernaut" = 1, "DemonicDurability" = 1, "HeavyHitter" = 2, "Pressure" = 2, "GiantSwings" = 1)
			strength = 3
			endurance = 3
			offense = 3
			intimidation = 25

/*ascension
	makyo
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Winter" = /ascension/sub_ascension/makyo/winter, "Summer"= /ascension/sub_ascension/makyo/summer, "Fall" = /ascension/sub_ascension/makyo/fall, "Spring" = /ascension/sub_ascension/makyo/spring)
			choiceTitle = "From which Court do you Hail?"
			choiceMessage ="As you've grown, the Court of Seasons calls, which House are you most attuned to?\n\nSummer:Passionate yet fickle, you burn too bright for most, for you know in no time at all you shall be snuffed out...\n\nWinter: Stagnant and solitary, slow to act, yet bringing forth the inevitable end once roused...\n\nFall: The most mystical and  mysterious of all, wise beyond your years and yet always in the midst of fading...\n\nSpring: The most vivacious and inexperienced, always creating new marvels while rarely perfecting what you bring to bloom..."
			passives = list("ManaCapMult" =0.25)
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/summer)
					strength = 0.25
					force = 0.25
					endurance = -0.125
					defense = -0.125
					passives+= list("HardStyle"= 1, "Flicker" = 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/winter)
					endurance = 0.25
					defense = 0.25
					offense = -0.125
					speed = -0.125
					passives+= list("SoftStyle" = 1, "Juggernaut" = 0.25)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/fall)
					force = 0.25
					endurance = 0.25
					offense = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/spring)
					strength = 0.25
					speed = 0.25
					defense = 0.25
					passives+= list("Godspeed" = 1, "BlurringStrikes"=1)
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("ManaCapMult" =0.25)
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/summer)
					strength = 0.25
					force = 0.25
					endurance = -0.125
					defense = -0.125
					passives+= list("Scorching" = 2)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/winter)
					endurance = 0.25
					defense = 0.25
					offense = -0.125
					speed = -0.125
					passives+= list("SoftStyle" = 1, "Juggernaut" = 0.25, "ManaSeal" = 1, "CyberStigma" = 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/fall)
					force = 0.25
					endurance = 0.25
					offense = 0.25
					passives+= list("Shattering" = 2)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/spring)
					strength = 0.25
					speed = 0.25
					defense = 0.25
					passives+= list("Pursuer" = 1, "Shocking" = 2)
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/summer)
					strength = 0.25
					force = 0.25
					endurance = -0.125
					defense = -0.125
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/winter)
					endurance = 0.25
					defense = 0.25
					offense = -0.125
					speed = -0.125
					passives+= list("SoftStyle" = 1, "Juggernaut" = 0.25,"CyberStigma" = 1, "SoulFire"= 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/fall)
					force = 0.25
					endurance = 0.25
					offense = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/spring)
					strength = 0.25
					speed = 0.25
					defense = 0.25
					passives+= list("Godspeed" = 1, "BlurringStrikes"=1)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("ManaCapMult" =0.25)
			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/summer)
					strength = 0.25
					force = 0.25
					endurance = -0.125
					defense = -0.125
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/winter)
					endurance = 0.25
					defense = 0.25
					offense = -0.125
					speed = -0.125
					passives+= list("SoftStyle" = 1, "Juggernaut" = 0.25, "CyberStigma" = 2, "SoulFire"= 1)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/fall)
					force = 0.25
					endurance = 0.25
					offense = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/makyo/spring)
					strength = 0.25
					speed = 0.25
					defense = 0.25
				..()

ascension
	sub_ascension
		makyo
			summer //Fire Element, Burn up, Hybrid, Glass Cannon sort of choice, live fast, die young
				skills= list(/obj/Skills/Buffs/SlotlessBuffs/Makyo/Sword_of_Sunlight)
				strength = 0.5
				force = 0.5
				endurance = -0.25
				defense = -0.25
				passives= list("ShonenPower" = 1, "HardStyle" = 1)

				onAscension(mob/owner)
					owner.Class = "Summer"
					..()
			winter // Water Element, Freezing, bring death through Inevitabilty, wearing all things to stagnation
				skills= list(/obj/Skills/Buffs/SlotlessBuffs/Makyo/Crown_of_Rime)
				endurance = 0.5
				defense = 0.5
				offense = -0.25
				speed = -0.25
				passives= list("SoftStyle" = 1, "Juggernaut" = 1)

				onAscension(mob/owner)
					owner.Class = "Winter"
					..()
			spring // Wind Element. Essence of Life. To Do: VitalStrike Passive, build up charge on target when you deal damage, then can spend that charge on a target for various skills, potential Tech route?
				strength = 0.5
				speed = 0.5
				defense = 0.5
				intelligenceAdd=3
				imaginationAdd=-2
				passives= list("Godspeed"= 1, "Flicker" = 1)

				onAscension(mob/owner)
					owner.Class = "Spring"
					..()
			fall // Earth Element. the fading embers, gives Self Debuffs for Boons. Magic Path?.
				skills= list(/obj/Skills/Buffs/SlotlessBuffs/Makyo/Fall/Shedding_Leaves, /obj/Skills/Buffs/SlotlessBuffs/Makyo/Fall/Hibernation_Preparation, /obj/Skills/Buffs/SlotlessBuffs/Makyo/Fall/Harvest_Time)
				force = 0.5
				endurance = 0.5
				offense = 0.5
				passives= list("ManaStats" = 1)

				onAscension(mob/owner)
					owner.Class = "Fall"
					..()
					*/