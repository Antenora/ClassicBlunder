ascension
	agorothian
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			choices = list("Aethirian" = /ascension/sub_ascension/agorothian/Aethirian, "Isroth" =  /ascension/sub_ascension/agorothian/Isroth, "Eserthen" = /ascension/sub_ascension/agorothian/Eserthen)
			passives = list("ManaGen" = 2,)
			

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
		passives = list("ManaGen" = 2)
			
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(choice == /ascension/sub_ascension/agorothian/Eserthen)
					passives += list("BlurringStrikes" = 0.25, Godspeed" = 1, "Adaptive" = 1)
					strength = 0.25
					endurance = 0.25
					speed = 0.5
					force = 0.25
					offense = 1
					defense = 1
					anger = 1
				if(choice == /ascension/sub_ascension/agorothian/Isroth)
					passives += list("AngerAdaptiveForce" = 0.2, "Harden" = 1, "DemonicDurability" = 1)
					strength = 0.5
					endurance = 1
					speed = 0.25
					force = 0.25
					offense = 1
					anger = 1
				if(choice == /ascension/sub_ascension/agorothian/Aethirian)
					passives += list("SpiritSword" = 0.25, "SpiritFlow" = 0.25 "ManaCapMult" = 0.5)
				strength = 0.5
					force = 0.5
					defense = 1
					endurance = 0.25
					speed = 0.25
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.transUnlocked<1)
					owner.transUnlocked=1
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			intimidation = 1.5
			
			
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(choice == /ascension/sub_ascension/agorothian/Eserthen)
					passives += list("BlurringStrikes" = 0.25, Godspeed" = 1, "Adaptive" = 1)
					strength = 0.25
					endurance = 0.25
					speed = 1
					force = 0.25
					offense = 1
					defense = 1
					if(choice == /ascension/sub_ascension/agorothian/Isroth)
					passives += list("AngerAdaptiveForce" = 0.2, "Harden" = 1, "DemonicDurability" = 1)
					strength = 1
					endurance = 0.5
					speed = 0.25
					force = 0.25
					offense = 1
					anger = 1
				if(choice == /ascension/sub_ascension/agorothian/Aethirian)
					passives += list("SpiritSword" = 0.25, "SpiritFlow" = 0.25 "ManaCapMult" = 0.5)
					strength = 0.5
					force = 0.5
					defense = 1
					endurance = 0.25
					speed = 0.25
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL

			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(choice == /ascension/sub_ascension/agorothian/Eserthen)
					passives += list("BlurringStrikes" = 0.25, Godspeed" = 1, "Adaptive" = 1,  )
					strength = 0.25
					endurance = 0.25
					speed = 0.5
					force = 0.25
					offense = 1
					defense = 1
				if(choice == /ascension/sub_ascension/agorothian/Isroth)
					passives += list("AngerAdaptiveForce" = 0.2, "Harden" = 1, "DemonicDurability" = 1, )
					strength = 0.5
					endurance = 1
					speed = 0.25
					force = 0.25
					offense = 1
					anger = 1
				if(choice == /ascension/sub_ascension/agorothian/Aethirian)
					passives += list( "SpiritSword" = 0.5 "SpiritFlow" = 0.25 "ManaCapMult" = 0.5, )
				strength = 0.5
					force = 0.5
					defense = 1
					endurance = 0.25
					speed = 0.25
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(choice == /ascension/sub_ascension/agorothian/Eserthen)
					passives += list("BlurringStrikes" = 0.25, Godspeed" = 1, "Adaptive" = 1)
					strength = 0.25
					endurance = 0.25
					speed = 0.5
					force = 0.25
					offense = 1
					defense = 1
				if(choice == /ascension/sub_ascension/agorothian/Isroth)
					passives += list("AngerAdaptiveForce" = 0.2, "Harden" = 1, "DemonicDurability" = 1)
					strength = 0.5
					endurance = 0.5
					speed = 0.25
					force = 0.25
					offense = 1
					anger = 1
				if(choice == /ascension/sub_ascension/agorothian/Aethirian)
					passives += list("hybridstrike" = 0.25, "SpiritFlow" = 0.25 "ManaCapMult" = 0.5)
					strength = 0.5
					force = 0.5
					defense = 1
					endurance = 0.25
					speed = 0.25
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
	
			simulateChoiceMutation(mob/owner)
				var/list/ascs = owner.race?.ascensions
				if(!islist(ascs) || ascs.len < 1) return
				var/ascension/first = ascs[1]
				if(!first) return
				var/choice = first.choiceSelected
				if(choice == /ascension/sub_ascension/agorothian/Eserthen)
					passives += list("BlurringStrikes" = 1, Godspeed" = 1, "Adaptive" = 1)
					strength = 0.25
					endurance = 0.25
					speed = 1
					force = 0.25
					offense = 1
					defense = 1
				if(choice == /ascension/sub_ascension/agorothian/Isroth)
					passives += list("AngerAdaptiveForce" = 0.2, "Harden" = 1, "DemonicDurability" = 1)
					strength = 1
					endurance = 1
					speed = 0.25
					force = 0.25
					offense = 1
					anger = 1
				if(choice == /ascension/sub_ascension/agorothian/Aethirian)
					passives += list("SpiritSword" = 0.5, "SpiritFlow" = 0.5 "ManaCapMult" = 0.5)
					strength = 1
					force = 1
					defense = 1
					offense = 0.25
					endurance = 0.5
					speed = 0.25
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()

ascension
	sub_ascension
		agorothian
			Isroth
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Righteous_Fury)
				passives = list("Isroth" = 1, "AngerAdaptiveForce" = 0.2, "Harden" = 1, "DemonicDurability" = 1)
				strength = 1
					endurance = 1.5
					speed = 0.25
					force = 0.25
					offense = 1
					anger = 1
				onAscension(mob/owner)
					owner.Class = "Isroth"
					..()

			Aethirian
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Aether_Blade)
				passives = list( "Aethirian" = 1, "SpiritSword" = 0.5, "SpiritFlow" = 0.5, "ManaCapMult" = 0.5, "MartialMagic" = 1)
					strength = 1.5
					force = 1.5
					defense = 1
					offense = 0.25
					endurance = 0.25
					speed = 0.25
					onAscension(mob/owner)
					owner.Class = "Aethirian"
					..()

			Eserthen
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Boundless_Waltz)
				passives = list("Eserthen" = 1, "Adaptation" = 1, "BlurringStrikes" = 0.5, "Godspeed" = 1)
					strength = 0.25
					endurance = 0.25
					speed = 1.5
					force = 0.25
					offense = 1
					defense = 1
				onAscension(mob/owner)
					owner.Class = "Eserthen"
					..()