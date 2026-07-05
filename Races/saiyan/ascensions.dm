ascension
	saiyan
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Pride" = /ascension/sub_ascension/saiyan/pride, "Honor" =  /ascension/sub_ascension/saiyan/honor, "Zeal" = /ascension/sub_ascension/saiyan/zeal)
			passives = list("Brutalize" = 0.25)
			strength = 0.25
			force = 0.25
			endurance = 0.25

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			anger = 0.25
			passives = list("Brutalize" = 0.5)
			strength = 0.25
			force = 0.25
			defense = 0.25
			offense = 0.25
			endurance = 0.25
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(istype(choice, /ascension/sub_ascension/saiyan/zeal))
					passives += list("Adaptation" = 0.5)
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list("AngerAdaptiveForce" = 0.2, "Adrenaline" = 1, "PureReduction" = 0.5)
				if(istype(choice, /ascension/sub_ascension/saiyan/pride))
					passives += list("Steady" = 1, "PureDamage" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.transUnlocked<1)
					owner.transUnlocked=1
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("Brutalize" = 0.5)
			strength = 0.5
			force = 0.5
			endurance = 0.5
			anger = 0.25
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(istype(choice, /ascension/sub_ascension/saiyan/zeal))
					passives += list("Adaptation" = 0.5, "LikeWater" = 0.5)
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list("AngerAdaptiveForce" = 0.2, "Juggernaut" = 1, "PureReduction" = 0.5)
				if(istype(choice, /ascension/sub_ascension/saiyan/pride))
					passives += list("Steady" = 1, "PureDamage" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			anger = 0.25
			passives = list("Brutalize" = 1)
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(istype(choice, /ascension/sub_ascension/saiyan/zeal))
					passives += list("Adaptation" = 0.5, "LikeWater" = 0.5)
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list("AngerAdaptiveForce" = 0.2, "Adrenaline" = 1, "PureReduction" = 1)
				if(istype(choice, /ascension/sub_ascension/saiyan/pride))
					passives += list("Steady" = 1, "PureDamage" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			anger = 0.25
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(istype(choice, /ascension/sub_ascension/saiyan/zeal))
					passives += list("Adaptation" = 0.5, "LikeWater" = 1)
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list("AngerAdaptiveForce" = 0.2, "Adrenaline" = 1, "PureReduction" = 1)
				if(istype(choice, /ascension/sub_ascension/saiyan/pride))
					passives += list("Steady" = 1, "PureDamage" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			anger = 0.25
			passives = list("Brutalize" = 1)
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(istype(choice, /ascension/sub_ascension/saiyan/zeal))
					passives += list("Adaptation" = 0.5, "LikeWater" = 0.5)
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list("AngerAdaptiveForce" = 0.2, "Adrenaline" = 1, "PureReduction" = 1)
				if(istype(choice, /ascension/sub_ascension/saiyan/pride))
					passives += list("Steady" = 1, "PureDamage" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()

ascension
	sub_ascension
		saiyan
			honor
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Grit)
				passives = list("Honor" = 1, "Defiance" = 1, "Juggernaut" = 0.5, "PureReduction" = 0.5)

				onAscension(mob/owner)
					owner.Class = "Honor"
					..()

			pride
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Dominance)
				passives = list("Pride" = 1, "PureDamage" = 0.5)

				onAscension(mob/owner)
					owner.Class = "Pride"
					..()

			zeal
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Soul)
				passives = list("Zeal" = 1, "Adaptation" = 0.5)

				onAscension(mob/owner)
					owner.Class = "Zeal"
					..()
