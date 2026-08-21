ascension
	half_saiyan
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("Tenacity" = 1, "Adrenaline" = 0.25)
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Compassion")
						passives["UnderDog"] = 0.5
						passives["Compassion"] = 1
						speed=0.25
						strength=0.25
						defense=0.25
						endurance=0.25
						anger = 0.1
					if("Justice")
						passives["CheapShot"]=0.5
						passives["Justice"] = 1
						offense = 0.25
						strength = 0.5
						force = 0.25
						anger = 0.25
			onAscension(mob/owner)
				if(!applied)
					simulateChoiceMutation(owner)
				..()

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			choices = list("Adaptive" = /ascension/sub_ascension/half_saiyan/adaptive, "Dominating" = /ascension/sub_ascension/half_saiyan/dominating)
			passives = list( "Tenacity" = 0.5)
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Compassion")
						passives["UnderDog"] = 1
						speed=0.25
						strength=0.25
						defense=0.25
						endurance=0.25
					if("Justice")
						passives["CheapShot"]=0.5
						endurance = 0.25
						strength = 0.25
						force = 0.5
			onAscension(mob/owner)
				if(!applied)
					simulateChoiceMutation(owner)
				if(owner.transUnlocked<1)
					owner.transUnlocked=1
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL // ?
			passives = list( "Tenacity" = 0.5, "TechniqueMastery" = 1)
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Compassion")
						passives["Adrenaline"] = 1
						passives["Tenacity"] = 3
						defense = 0.5
						strength = 0.5
						offense = 0.5
						force = 0.5
					if("Justice")
						endurance = 0.5
						offense = 0.5
						strength = 0.5
			onAscension(mob/owner)
				if(!applied)
					simulateChoiceMutation(owner)
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list( "Tenacity" = 0.5)
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Compassion")
						passives["Adrenaline"] = 0.5
						passives["Tenacity"] = 3
						strength = 0.5
						defense = 0.5
						offense = 0.5
						force = 0.5
					if("Justice")
						strength = 0.5
						force = 0.5
						offense = 0.5
						speed = 0.5
			onAscension(mob/owner)
				if(!applied)
					simulateChoiceMutation(owner)
				..()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list( "Tenacity" = 0.5)
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Compassion")
						passives["Adrenaline"] = 0.5
						passives["Tenacity"] = 0.5
						strength = 0.25
						defense = 0.25
						offense = 0.5
						force = 0.25
					if("Justice")
						strength = 0.25
						force = 0.25
						offense = 0.5
						speed = 0.5
			onAscension(mob/owner)
				if(!applied)
					simulateChoiceMutation(owner)
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list( "Tenacity" = 0.5)
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Compassion")
						passives["Adrenaline"] = 0.5
						passives["Tenacity"] = 0.5
						strength = 0.5
						defense = 0.5
						offense = 0.5
						force = 0.5
					if("Justice")
						strength = 0.5
						force = 0.5
						offense = 0.5
						speed = 0.5
			onAscension(mob/owner)
				if(!applied)
					simulateChoiceMutation(owner)
				..()

ascension
	sub_ascension
		half_saiyan
			adaptive
				passives = list( "TechniqueMastery" = 1)
				offense = 0.5
				defense = 0.5
				endurance = 0.25
				speed = 0.25
				onAscension(mob/owner)
					..()
					owner << "You embrace adaptation becoming flexible and resilient!"
					if(owner.Class == "Justice")
						owner.race.transformations += new /transformation/half_saiyan/saiyan/super_saiyan_rage()

			dominating
				passives = list(  "ZenkaiPower" = 0.1)
				strength = 0.25
				endurance = 0.25
				force = 0.25
				speed = 0.25
				onAscension(mob/owner)
					..()
					owner << "You embrace domination, primal ferocity and power surge through you!"
					if(owner.Class == "Justice")
						owner.race.transformations += new /transformation/saiyan/super_saiyan_3()
						owner.race.transformations += new /transformation/saiyan/super_saiyan_4()
