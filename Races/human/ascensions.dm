/ascension/sub_ascension/human/hero
	passives = list("UnderDog" = 1,"Persistence" = 1)
	offense = 0.25
	strength = 0.25
	force = 0.25
	defense = 0.25
	endurance = 0.25

/ascension/sub_ascension/human/innovative
	defense = 0.25
	endurance = 0.25



ascension
	human
		var/dormantDemonPassivesAdded = 0

		proc/applyDormantDemonPassives(mob/owner)
			if(applied || dormantDemonPassivesAdded || !owner.passive_handler)
				return
			if(!owner.passive_handler.Get("DormantDemon"))
				return
			passives["HellPower"] = (isnum(passives["HellPower"]) ? passives["HellPower"] : 0) + 0.25
			passives["HellRisen"] = (isnum(passives["HellRisen"]) ? passives["HellRisen"] : 0) + 0.25
			passives["AbyssMod"] = (isnum(passives["AbyssMod"]) ? passives["AbyssMod"] : 0) + 1
			dormantDemonPassivesAdded = 1

		revertAscension(mob/owner)
			..()
			if(!dormantDemonPassivesAdded)
				return
			if(isnum(passives["HellPower"]))
				passives["HellPower"] -= 0.25
				if(passives["HellPower"] <= 0)
					passives -= "HellPower"
			if(isnum(passives["HellRisen"]))
				passives["HellRisen"] -= 0.25
				if(passives["HellRisen"] <= 0)
					passives -= "HellRisen"
			if(isnum(passives["AbyssMod"]))
				passives["AbyssMod"] -= 1
				if(passives["AbyssMod"] <= 0)
					passives -= "AbyssMod"
			dormantDemonPassivesAdded = 0

		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
	//		choices = list("Hero" = /ascension/sub_ascension/human/hero, "Innovative" = /ascension/sub_ascension/human/innovative)
			passives = list("Tenacity" = 1, "Shonen" = 1, "ShonenPower" = 0.15, "UnderDog" = 1,"Persistence" = 1)
			new_anger_message = "grows desperate!"
			on_ascension_message = "You learn the meaning of desperation..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Underdog")
							anger = 0.1
							offense = 0.25
							strength = 0.25
							force = 0.25
							defense = 0.25
							endurance = 0.25
							speed = 0.25
							passives  += list("Motivation" = 0.1)
						if("Heroic")
							offense = 0.5
							strength = 0.5
							force = 0.5
							defense = 0.5
							endurance = 0.5
							speed = 0.4
							passives += list("KiControlMastery"= 1)
						if("Resourceful")
							offense = 0.1
							strength = 0.1
							force = 0.1
							defense = 0.1
							endurance = 0.1
							speed = 0.4
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				applyDormantDemonPassives(owner)
				..()
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("Tenacity" = 1, "Shonen" = 1, "ShonenPower" = 0.15, "UnderDog"=1, "Adrenaline"=1, "Persistence" = 1, "Adaptation" = 1)
			new_anger_message = "grows determined!"
			on_ascension_message = "You learn the meaning of responsibility..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Underdog")
							anger = 0.1
							offense = 0.25
							strength = 0.25
							force = 0.25
							defense = 0.25
							endurance = 0.25
							speed = 0.25
							passives  += list("Motivation" = 0.15)
						if("Heroic")
							offense = 1
							strength = 1
							force = 1
							defense = 1
							endurance = 1
							speed = 0.4
							if(!owner.passive_handler.Get("FavoredPrey"))
								passives  += list("FavoredPrey" = "Transformations")
						if("Resourceful")
							offense = 0.1
							strength = 0.1
							force = 0.1
							defense = 0.1
							endurance = 0.1
							speed = 0.4
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				applyDormantDemonPassives(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<2)
					owner.transUnlocked=2
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			var/mazokuSinChosen = ""
			passives = list("Tenacity" = 1, "DemonicDurability" = 0.5, "UnderDog"=1, "Persistence" = 1)
			new_anger_message="grows confident!"
			on_ascension_message = "You learn the meaning of confidence..."
			anger = 0.1
			defense = 0.5
			endurance = 0.25
			offense = 0.25
			strength = 0.25
			force = 0.25
			speed = 0.25
			simulateChoiceMutation(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Underdog")
							anger = 0.1
							offense = 0.25
							strength = 0.25
							force = 0.25
							defense = 0.25
							endurance = 0.25
							speed = 0.25
						if("Heroic")
							offense = 0.75
							strength = 0.75
							force = 0.75
							defense = 0.75
							endurance = 0.75
							speed = 0.4
							passives += list("KiControlMastery"= 1)
							//TO DO - Something that makes them scale with SSj2. Passives? Inherent buff? hm.
						if("Resourceful")
							offense = 0.1
							strength = 0.1
							force = 0.1
							defense = 0.1
							endurance = 0.1
							speed = 0.4
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<3)
					owner.transUnlocked=3
				applyDormantDemonPassives(owner)
				..()
			postAscension(mob/owner)
				..()
				if(!owner.passive_handler || !owner.passive_handler.Get("DormantDemon")) return
				if(mazokuSinChosen != "") return
				var/sinChoice = input(owner, "A dormant power stirs within you. Which path do you walk?", "Dormant Demon Awakening") in list("Apathy", "Hope")
				mazokuSinChosen = sinChoice
				switch(sinChoice)
					if("Apathy")
						owner.passive_handler.Increase("ApathyFactor", 1)
					if("Hope")
						owner.passive_handler.Increase("HopeFactor", 1)
						if(!locate(/obj/Skills/Queue/Kibou_ou_Hope, owner))
							owner.AddSkill(new /obj/Skills/Queue/Kibou_ou_Hope)
			revertAscension(mob/owner)
				if(mazokuSinChosen != "" && owner.passive_handler)
					owner.passive_handler.Decrease(mazokuSinChosen + "Factor", 1)
					if(mazokuSinChosen == "Hope")
						var/obj/Skills/Queue/Kibou_ou_Hope/k = locate(/obj/Skills/Queue/Kibou_ou_Hope, owner)
						if(k) owner.DeleteSkill(k)
					mazokuSinChosen = ""
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("Tenacity" = 1, "DemonicDurability" = 0.5, "UnderDog"=1, "Persistence" = 1)
			new_anger_message = "gains absolute clarity!"
			on_ascension_message = "You learn the meaning of competence..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Underdog")
							anger = 0.1
							offense = 0.25
							strength = 0.25
							force = 0.25
							defense = 0.25
							endurance = 0.25
							speed = 0.25
						if("Heroic")
							offense = 1
							strength = 1
							force = 1
							defense = 1
							endurance = 1
							speed = 0.4
							//TO DO - Something that makes it not obvious that I just copied and pasted this three times
						if("Resourceful")
							offense = 0.1
							strength = 0.1
							force = 0.1
							defense = 0.1
							endurance = 0.1
							speed = 0.4
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<4)
					owner.transUnlocked=4
				applyDormantDemonPassives(owner)
				..()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list( "Tenacity" = 1, "DemonicDurability" = 0.5, "UnderDog"=1, "Persistence" = 1)
			new_anger_message = "becomes angry!"
			on_ascension_message = "You learn the meaning of humanity..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Underdog")
							anger = 0.1
							offense = 0.25
							strength = 0.25
							force = 0.25
							defense = 0.25
							endurance = 0.25
							speed = 0.25
						if("Heroic")
							offense = 1.5
							strength = 1.5
							force = 1.5
							defense = 1.5
							endurance = 1.5
							speed = 0.4
							passives += list("KiControlMastery"= 1)
							//TO DO - Something that makes it not obvious that I just copied and pasted this four times
						if("Resourceful")
							offense = 0.1
							strength = 0.1
							force = 0.1
							defense = 0.1
							endurance = 0.1
							speed = 0.4
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<4)
					owner.transUnlocked=4
				applyDormantDemonPassives(owner)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list( "Tenacity" = 1, "DemonicDurability" = 0.5, "UnderDog"=1, "Persistence" = 1)
			new_anger_message = "becomes angry!"
			on_ascension_message = "You learn the meaning of humanity..."
			simulateChoiceMutation(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Underdog")
							offense = 0.25
							strength = 0.25
							force = 0.25
							defense = 0.25
							endurance = 0.25
							speed = 0.25
						if("Heroic")
							offense = 2
							strength = 2
							force = 2
							defense = 2
							endurance = 2
							speed = 0.4
							//TO DO - Something that makes it not obvious that I just copied and pasted this five times
						if("Resourceful")
							offense = 0.1
							strength = 0.1
							force = 0.1
							defense = 0.1
							endurance = 0.1
							speed = 0.4
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				if(owner.Class=="Underdog" && owner.transUnlocked<5)
					owner.transUnlocked=5
				applyDormantDemonPassives(owner)
				..()
				if(owner.isMazokuHuman())
					var/already_has_sea = FALSE
					for(var/transformation/T in owner.race.transformations)
						if(istype(T, /transformation/human/sacred_energy_aura))
							already_has_sea = TRUE
							break
					if(!already_has_sea)
						owner.race.transformations += new /transformation/human/sacred_energy_aura()
			revertAscension(mob/owner)
				if(owner.passive_handler && owner.race && owner.race.transformations)
					for(var/transformation/T in owner.race.transformations.Copy())
						if(istype(T, /transformation/human/sacred_energy_aura))
							owner.race.transformations -= T
							del T
							break
				..()
