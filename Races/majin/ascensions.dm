ascension
	majin
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			anger = 0.1
			imaginationAdd = 0.2
			endurance = 0.75
			defense = 0.75
			strength = 0.75
			force = 0.75
			speed = 0.75
			offense = 0.75
			passives = list()

			onAscension(mob/owner)
				if(!owner.Class || (owner.Class != "Innocent" && owner.Class != "Super" && owner.Class != "Unhinged"))
					var/picked = input(owner, "Choose your Majin Class.", "Majin Class") in list("Innocent","Super","Unhinged")
					owner.Class = picked
				switch(owner.Class)
					if("Innocent")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 2, "Blubber" = 1, "PureReduction" = 1)
					if("Super")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 2,  "Duelist" = 1)
					if("Unhinged")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 2, "CriticalDamage" = 0.05, "PureDamage" = 1)
				if(owner.majinAbsorb)
					owner.majinAbsorb.updateVariables(owner)
				owner.majinCheatDeathUsed = 0
				..()

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			anger = 0.1
			imaginationAdd = 0.25
			endurance = 0.75
			defense = 0.75
			strength = 0.75
			force = 0.75
			speed = 0.75
			offense = 0.75
			passives = list()

			onAscension(mob/owner)
				switch(owner.Class)
					if("Innocent")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "Blubber" = 1, "PureReduction" = 1)
					if("Super")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1,  "Duelist" = 1)
					if("Unhinged")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "CriticalDamage" = 0.05, "PureDamage" = 1)
				if(owner.majinAbsorb)
					owner.majinAbsorb.updateVariables(owner)
				owner.majinCheatDeathUsed = 0
				..()

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			anger = 0.1
			endurance = 0.75
			defense = 0.75
			strength = 0.75
			force = 0.75
			speed = 0.75
			offense = 0.75
			passives = list()

			onAscension(mob/owner)
				switch(owner.Class)
					if("Innocent")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "Blubber" = 1, "PureReduction" = 1)
					if("Super")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1,  "Duelist" = 1)
					if("Unhinged")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "CriticalDamage" = 0.05, "PureDamage" = 1)
				if(owner.majinAbsorb)
					owner.majinAbsorb.updateVariables(owner)
				owner.majinCheatDeathUsed = 0
				..()

		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			anger = 0.15
			imaginationAdd = 0.2
			endurance = 1
			defense = 1
			strength = 1
			force = 1
			speed = 1
			offense = 1
			passives = list()

			onAscension(mob/owner)
				switch(owner.Class)
					if("Innocent")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "Blubber" = 1, "PureReduction" = 1)
					if("Super")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1,  "Duelist" = 1)
					if("Unhinged")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "CriticalDamage" = 0.05, "PureDamage" = 1)
				if(owner.majinAbsorb)
					owner.majinAbsorb.updateVariables(owner)
				owner.majinCheatDeathUsed = 0
				..()

		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			anger = 0.15
			endurance = 1
			defense = 1
			strength = 1
			force = 1
			speed = 1
			offense = 1
			passives = list()

			onAscension(mob/owner)
				switch(owner.Class)
					if("Innocent")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "Blubber" = 1, "PureReduction" = 1)
					if("Super")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1,  "Duelist" = 1)
					if("Unhinged")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "CriticalDamage" = 0.05, "PureDamage" = 1)
				if(owner.majinAbsorb)
					owner.majinAbsorb.updateVariables(owner)
				owner.majinCheatDeathUsed = 0
				..()

		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			anger = 0.2
			imaginationAdd = 0.25
			endurance = 1.25
			defense = 1.25
			strength = 1.25
			force = 1.25
			speed = 1.25
			offense = 1.25
			passives = list()

			onAscension(mob/owner)
				switch(owner.Class)
					if("Innocent")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "Unstoppable" = 1, "Blubber" = 1, "PureReduction" = 1)
					if("Super")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "Unstoppable" = 1,  "Duelist" = 1)
					if("Unhinged")
						passives = list("Gum Gum" = 0.5, "PUSpike" = 25, "KiControlMastery" = 1, "Unstoppable" = 1, "CriticalDamage" = 0.05, "PureDamage" = 1)
				if(owner.majinAbsorb)
					owner.majinAbsorb.updateVariables(owner)
				owner.majinCheatDeathUsed = 0
				..()
