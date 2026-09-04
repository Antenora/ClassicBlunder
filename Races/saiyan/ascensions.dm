ascension
	saiyan
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Pride" = /ascension/sub_ascension/saiyan/pride, "Honor" =  /ascension/sub_ascension/saiyan/honor, "Zeal" = /ascension/sub_ascension/saiyan/zeal)
			strength = 0.25
			force = 0.25
			endurance = 0.25

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			choices = list("Power" = /ascension/sub_ascension/saiyan/power, "Control" =  /ascension/sub_ascension/saiyan/control)
			anger = 0.25
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
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list( "Adrenaline" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
				if(owner.SaiyanPotential=="Average")
					owner<<"Your can feel your next transformation on the horizon. A new font of power awaits you."
				else if(owner.SaiyanPotential=="Early Bird")
					owner<<"You have already achieved the status of a Super Saiyan, and your next form doesn't feel too far off. However, you know what they say about the stars that shine brightest..."
				else if(owner.SaiyanPotential=="Late Bloomer")
					owner<<"For some reason, your next transformation eludes you. However, towards the end of your journey..."
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
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
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list( "Juggernaut" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			anger = 0.25
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list( "Adrenaline" = 1)
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
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list( "Adrenaline" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			anger = 0.25
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(istype(choice, /ascension/sub_ascension/saiyan/honor))
					passives += list( "Adrenaline" = 1)
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()

ascension
	sub_ascension
		saiyan
			honor
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Grit)
				passives = list("ZenkaiPower" = 1, "Defiance" = 1, "Juggernaut" = 0.5)
				choiceMessage = "Honor Saiyans focus on durability above all, and are capable of manifesting explosive strength closer towards the end of a fight."
				onAscension(mob/owner)
					owner.Class = "Honor"
					..()

			pride
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Dominance)
				passives = list("Pride" = 1)
				choiceMessage = "Pride Saiyans focus on power above all, and have great control over their energy, especially at higher health."
				onAscension(mob/owner)
					owner.Class = "Pride"
					..()

			zeal
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Saiyan_Soul)
				passives = list("Zeal" = 1)
				choiceMessage = "Zeal Saiyans have a unique proficiency at adapting to the circumstances of a fight."
				onAscension(mob/owner)
					owner.Class = "Zeal"
					..()
			power
				choiceMessage = "Power Saiyans are the path for GT-focused Saiyans, granting them stronger Super Saiyan forms, Golden Oozaru and an enhanced Super Saiyan 3 at 60 potential, and locks them to Super Saiyan 4 and its limit broken form."
				onAscension(mob/owner)
					owner.SaiyanFocus = "Power"
					for(var/transformation/saiyan/ssj in owner.race.transformations)
						if(istype(ssj, /transformation/saiyan/super_saiyan_god) || istype(ssj, /transformation/saiyan/super_saiyan_blue)|| istype(ssj, /transformation/saiyan/super_saiyan_blue_evolved))
							owner.race.transformations -= ssj
							del ssj
					owner.AddSkill(new/obj/Skills/AutoHit/False_Moon)
					..()
			control
				growthadd=1.25
				choiceMessage = "Control Saiyans are the path for Saiyans who want to go down the Super Saiyan God path. Selecting this vastly raises your growth rate for invested stats, gives your Super Saiyan forms slight stat boosts, and locks you to Super Saiyan 4 Daima, God, Blue, and Blue Evolved."
				onAscension(mob/owner)
					owner.SaiyanFocus = "Control"
					for(var/transformation/saiyan/ssj in owner.race.transformations)
						if(istype(ssj, /transformation/saiyan/super_saiyan_4)||istype(ssj, /transformation/saiyan/super_full_power_saiyan_4_limit_breaker))
							owner.race.transformations -= ssj
							del ssj
					..()