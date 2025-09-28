ascension
	half_saiyan
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			intimidation = 10
			passives = list("Tenacity" = 1, "Adrenaline" = 0.25)
			onAscension(mob/owner)
				if(!applied)
					switch(owner.Class)
						if("Compassion")
							passives["UnderDog"] = 0.5
							speed=0.25
							strength=0.25
							defense=0.25
							endurance=0.25
							anger = 0.1
							for(var/transformation/saiyan/super_saiyan_3/ssj3 in owner.race.transformations)
								owner.race.transformations -= ssj3
								del ssj3
							owner.race.transformations.Add(new/transformation/half_saiyan/human/ultimate_mode())
							owner.race.transformations.Add(new/transformation/half_saiyan/human/beast_mode())
						if("Anger")
							passives["Enrage"]=1
							passives["CheapShot"]=0.5
							passives["Brutalize"]=0.25
							offense = 0.25
							strength = 0.5
							force = 0.25
							anger = 0.25
				..()

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			intimidation = 10
			passives = list("Brutalize" = 0.25, "Tenacity" = 0.5)
			onAscension(mob/owner)
				switch(owner.Class)
					if("Compassion")
						passives["UnderDog"] = 1
						speed=0.25
						strength=0.25
						defense=0.25
						endurance=0.25
					if("Anger")
						passives["Enrage"]=1
						passives["CheapShot"]=0.5
						passives["Brutalize"]=0.25
						endurance = 0.25
						strength = 0.25
						force = 0.5
				..()
		three
			unlock_potential = 40 // ?
			intimidation = 10
			passives = list("Brutalize" = 0.25, "Tenacity" = 0.5, "TechniqueMastery" = -1)

			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/adaptive)
					passives["Adrenaline"] = 0.5
					passives["Tenacity"] = 0.5
					defense = 0.25
					strength = 0.25
					offense = 0.25
					force = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/dominating)
					passives["Brutalize"] = 0.5
					passives["KillerInstinct"] = 0.05
					endurance = 0.25
					offense = 0.25
					strength = 0.5
				..()

		four
			unlock_potential = 65
			intimidation = 10
			passives = list("Brutalize" = 0.25, "Tenacity" = 0.5)

			onAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/adaptive)
					passives["Adrenaline"] = 0.5
					passives["Tenacity"] = 0.5
					strength = 0.25
					defense = 0.25
					offense = 0.5
					force = 0.25
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/half_saiyan/dominating)
					passives["Brutalize"] = 0.5
					passives["KillerInstinct"] = 0.05
					strength = 0.25
					force = 0.25
					offense = 0.5
					speed = 0.5
				..()

		five
			unlock_potential = 80
			intimidation = 10
			passives = list("Brutalize" = 0.25, "Tenacity" = 0.5)

ascension
	sub_ascension
		half_saiyan
			adaptive
				passives = list("Adaptation" = 1)
				offense = 0.5
				defense = 0.25
				endurance = 0.25
				onAscension(mob/owner)
					. = ..()
					for(var/transformation/saiyan/super_saiyan_3/ssj3 in owner.race.transformations)
						owner.race.transformations -= ssj3
						del ssj3
					owner.race.transformations.Add(new/transformation/half_saiyan/human/ultimate_mode())
					owner.race.transformations.Add(new/transformation/half_saiyan/human/beast_mode())
			
			dominating
				passives = list("KillerInstinct" = 0.05, "Brutalize" = 0.25)
				strength = 0.25
				endurance = 0.25
				force = 0.25
				speed = 0.25