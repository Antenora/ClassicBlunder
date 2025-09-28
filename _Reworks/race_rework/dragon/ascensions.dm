ascension
	dragon
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			intimidation = 30
			anger = 0.1
			onAscension(mob/owner)
				switch(owner.Class)
					if("Metal")
						passives = list("Juggernaut" = 0.25, "Unstoppable" = 0.25, "HeavyHitter" = 0.5, "DeathField" = 1.5)
						strength += 0.25
						endurance += 0.25
						offense += 0.5

					if("Fire")
						angerPoint += 5
						passives = list("MeltyBlood" = 1, "SpiritHand" = 1, "AngerAdaptiveForce" = 0.25)
						strength += 0.25
						force += 0.5
						offense += 0.25

					if("Water")
						passives = list("SoftStyle" = 1, "AbsoluteZero" = 3, "LikeWater" = 2,"Flow" = 1, "Instinct" = 1)
						strength += 0.25
						force += 0.25
						defense += 0.5

						
					if("Wind")
						passives = list("VenomBlood" = 1,"BlurringStrikes" = 0.25, "Flicker" = 1, "Adrenaline" = 2)
						speed += 0.5
						offense += 0.25
						defense += 0.25
					if("Gold")
						passives = list("Blubber" = 0.25, "CashCow" = 1)
						ecoAdd = 2
						endurance += 0.5
						speed += 0.25
				..()

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			intimidation = 20
			anger = 0.1
			onAscension(mob/owner)
				switch(owner.Class)
					if("Metal")
						passives = list("Juggernaut" = 0.25, "Unstoppable" = 0.25, "HeavyHitter" = 0.5, "DeathField" = 1.5)
						strength += 0.25
						endurance += 0.25
					if("Fire")
						angerPoint += 5
						passives = list("SpiritHand" = 0.5, "AngerAdaptiveForce" = 0.15)
						strength += 0.25
						force += 0.25
					if("Water")
						passives = list("AbsoluteZero" = 2, "LikeWater" = 2,"Flow" = 1, "Instinct" = 1)
						force += 0.25
						defense += 0.5
					if("Wind")
						passives = list("BlurringStrikes" = 0.25, "Flicker" = 1)
						speed += 0.25
						offense += 0.25
					if("Gold")
						passives = list("Blubber" = 0.25, "CashCow" = 1)
						ecoAdd = 1
						endurance += 0.5
						speed += 0.25
				..()

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			intimidation = 40
			onAscension(mob/owner)
				switch(owner.Class)
					if("Metal")
						passives = list("Juggernaut" = 0.5, "Unstoppable" = 0.25, "HeavyHitter" = 1, "DeathField" = 2)
						strength += 0.25
						endurance += 0.25
						defense += 0.25

					if("Fire")
						angerPoint += 5
						passives = list("AngerAdaptiveForce" = 0.25, "SpiritHand" = 0.5)
						strength += 0.25
						force += 0.25
						offense += 0.25
					if("Water")
						passives = list("SoftStyle" = 1, "FluidForm" = 1, "Flow" = 1)
						strength += 0.25
						force += 0.25
						defense += 0.25
					if("Wind")
						passives = list("BlurringStrikes" = 0.25, "Flicker" = 1)
						speed += 0.25
						offense += 0.25
						defense += 0.25
					if("Gold")
						passives = list("Blubber" = 0.25, "CashCow" = 1, )
						ecoAdd = 1
						endurance += 0.5
						speed += 0.25
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class)
					if("Metal")
						passives = list("Unstoppable" = 0.25, "HeavyHitter" = 0.5, "DeathField" = 3, )
						strength += 0.25
						endurance += 0.25
						defense += 0.25

					if("Fire")
						angerPoint += 5
						passives = list("DemonicDurability" = 0.25, "SpiritHand" = 1, )
						strength += 0.25
						force += 0.25
						offense += 0.25
					if("Water")
						passives = list(, "CalmAnger" = 1, "FluidForm" = 1, "SoftStyle" = 1)
						strength += 0.25
						force += 0.25
						defense += 0.25
					if("Wind")
						passives = list("BlurringStrikes" = 0.25, "Flicker" = 1, )
						speed += 0.25
						offense += 0.25
						defense += 0.25
					if("Gold")
						passives = list("Blubber" = 0.25, "CashCow" = 1, )
						ecoAdd = 1
						endurance += 0.5
						speed += 0.25
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			onAscension(mob/owner)
				switch(owner.Class)
					if("Metal")
						passives = list("Unstoppable" = 0.25, "HeavyHitter" = 0.5, "DeathField" = 2, )
						strength += 0.25
						endurance += 0.25
						defense += 0.25

					if("Fire")
						angerPoint += 5
						passives = list("DemonicDurability" = 0.25, "SpiritHand" = 1, )
						strength += 0.25
						force += 0.25
						offense += 0.25

					if("Water")
						passives = list("FluidForm" = 1, "SoftStyle" = 1, "Flow" = 1, )
						strength += 0.25
						force += 0.25
						defense += 0.25


					if("Wind")
						passives = list("BlurringStrikes" = 0.25, "Flicker" = 1, )
						speed += 0.25
						offense += 0.25
						defense += 0.25
					if("Gold")
						passives = list("Blubber" = 0.25, "CashCow" = 1, )
						ecoAdd = 1
						endurance += 0.5
						speed += 0.25
				..()