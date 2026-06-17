ascension
	dragon
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			intimidation = 20
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Metal")
						var/newpassives = list("Juggernaut" = 1, "HeavyHitter" = 0.5, "PureReduction" = 1)
						passives+= newpassives
						endurance=1.5
						strength=0.5
						force=0.5
					if("Fire")
						var/newpassives = list("SpiritHand" = 2, "AngerAdaptiveForce" = 0.25, "MeltyBlood" = 1)
						passives+= newpassives
						strength=1
						force=1
						offense= 0.5
						anger=0.25
					if("Water")
						var/newpassives = list("SoftStyle" = 1, "LikeWater" = 1, "Flow" = 1, "Instinct" = 1)
						passives+= newpassives
						force = 0.5
						defense = 1
						speed = 1
					if("Wind")
						var/newpassives = list("BlurringStrikes" = 0.5, "Flicker" = 1, "Godspeed" = 1, "VenomBlood" = 1, "Adrenaline" = 2)
						passives+= newpassives
						strength = 0.25
						force = 0.25
						speed =1.5
						defense = 0.5
					if("Gold")
						var/newpassives = list("Blubber" = 0.25, "CashCow" = 1)
						passives+= newpassives
						ecoAdd = 2
						endurance = 1
						speed = 1
						strength = 0.5
					if("Dark")
						passives += list("Fury" = 1, "Momentum" = 1)
						strength = 1
						speed = 0.5
						offense = 0.5
					if("Light")
						passives += list("SoulFire" = 1.5, "DemonicDurability" = 1)
						defense = 1.0
						endurance = 1.0
						strength = 0.5
				..()

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			intimidation = 30
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Metal")
						var/newpassives = list("Juggernaut" = 1, "HeavyHitter" = 0.5, "PureReduction" = 1)
						passives+= newpassives
						strength = 1
						endurance = 1
						force = 0.5
					if("Fire")
						var/newpassives = list("SpiritHand" = 2, "AngerAdaptiveForce" = 0.25)
						passives+= newpassives
						strength = 1
						force = 1
						anger=0.25
					if("Water")
						var/newpassives = list("SoftStyle" = 1, "LikeWater" = 1, "Flow" = 1, "FluidForm" = 1)
						passives+= newpassives
						force = 0.5
						defense = 1.5
						speed = 0.5
					if("Wind")
						var/newpassives = list("BlurringStrikes" = 0.5, "Flicker" = 1, "Godspeed" = 1)
						passives+= newpassives
						strength = 0.25
						force = 0.25
						speed = 1.5
						offense = 0.5
					if("Gold")
						passives = list("Blubber" = 0.25, "CashCow" = 1)
						ecoAdd = 1
						endurance = 1.25
						speed = 1.25
						strength = 0.5
					if("Dark")
						passives += list("Fury" = 1, "Momentum" = 1, "DoubleStrike" = 1)
						strength = 1
						speed = 1
						offense = 0.5
					if("Light")
						passives += list("VoidField" = 3, "EnergySteal" = 15, "Harden" = 1)
						defense = 1.0
						endurance = 1.0
						strength = 0.5
				..()

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			intimidation = 40
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Metal")
						var/newpassives = list("Juggernaut" = 1, "HeavyHitter" = 1, "DeathField" = 2, "PureReduction" = 1)
						passives+= newpassives
						strength = 1.5
						endurance = 1.5
						force = 1
					if("Fire")
						var/newpassives = list("SpiritHand" = 2, "SpiritFlow" = 2)
						passives+= newpassives
						strength = 1
						force = 1
						offense = 1
						anger=0.25
					if("Water")
						var/newpassives = list("SoftStyle" = 1, "LikeWater" = 1, "Flow" = 1, "Instinct" = 1)
						passives+= newpassives
						force = 1.5
						speed = 1
						defense = 2
					if("Wind")
						var/newpassives = list("BlurringStrikes" = 0.5, "Flicker" = 1, "Godspeed" = 1)
						passives+= newpassives
						strength = 0.5
						force = 0.5
						speed = 2
						offense = 1.5
					if("Gold")
						var/newpassives = list("Blubber" = 0.25, "CashCow" = 1)
						passives+= newpassives
						ecoAdd = 1
						endurance = 2
						speed = 2
						strength = 0.75
					if("Dark")
						passives += list("Fury" = 1, "Momentum" = 1, "TripleStrike" = 1)
						strength = 1.5
						speed = 1.5
						offense = 1.5
					if("Light")
						passives += list("CallousedHands" = 0.2, "DemonicDurability" = 1, "SoulFire" = 1.5, "BeyondPurity" = 1)
						defense = 1.0
						endurance = 1.5
						strength = 1
						offense = 0.5
						speed = 0.5
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Metal")
						var/newpassives = list("HeavyHitter" = 0.5, "DeathField" = 2, "Unstoppable" = 1, "PureReduction" = 1)
						passives+= newpassives
						strength = 2
						endurance = 2
						force = 1
					if("Fire")
						var/newpassives = list("SpiritHand" = 2, "AngerAdaptiveForce" = 0.25, "SpiritFlow" = 2)
						passives+= newpassives
						strength = 2
						force = 2
						offense = 1
						anger=0.25
					if("Water")
						var/newpassives = list("SoftStyle" = 1, "LikeWater" = 1, "Flow" = 1, "FluidForm" = 1, "CalmAnger" = 1)
						passives+= newpassives
						force = 2
						defense = 2
						speed = 1
					if("Wind")
						var/newpassives = list("BlurringStrikes" = 0.5, "Flicker" = 1, "Godspeed" = 1, "DenkoSekka" = 1)
						passives+= newpassives
						strength = 0.5
						force = 0.5
						speed = 3
						offense = 1
					if("Gold")
						var/newpassives = list("Blubber" = 0.25, "CashCow" = 1)
						passives+= newpassives
						ecoAdd = 1
						endurance = 2.5
						speed = 2.5
						strength = 1
					if("Dark")
						passives += list("Fury" = 1, "Momentum" = 1, "AsuraStrike" = 1)
						strength = 2
						speed = 2
						offense = 1
					if("Light")
						passives += list("CallousedHands" = 0.2, "VoidField" = 3, "EnergySteal" = 15, "Harden" = 1)
						defense = 1.5
						endurance = 2
						strength = 1
						offense = 0.5
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Metal")
						var/newpassives = list("HeavyHitter" = 0.5, "DeathField" = 3, "PureReduction" = 1)
						passives+= newpassives
						strength = 2
						endurance = 2
						force = 1
					if("Fire")
						var/newpassives = list("SpiritHand" = 2, "AngerAdaptiveForce" = 0.25, "SpiritFlow" = 2)
						passives+= newpassives
						strength = 2
						force = 2
						offense = 1
						anger=0.25
					if("Water")
						var/newpassives = list("SoftStyle" = 1, "LikeWater" = 1, "Flow" = 1, "Instinct" = 1)
						passives+= newpassives
						force = 1
						defense = 3
						speed = 1
					if("Wind")
						var/newpassives = list("BlurringStrikes" = 0.5, "Flicker" = 1, "Godspeed" = 1, "DenkoSekka" = 1)
						passives+= newpassives
						strength = 0.5
						force = 0.5
						speed = 3
						offense = 1
					if("Gold")
						var/newpassives = list("Blubber" = 0.25, "CashCow" = 1)
						passives+= newpassives
						ecoAdd = 1
						endurance = 2.5
						speed = 2.5
						strength = 1
					if("Dark")
						passives += list("Fury" = 1, "Momentum" = 1, "DoubleStrike" = 1, "TripleStrike" = 1)
						strength = 2
						speed = 1
						offense = 2
					if("Light")
						passives += list("DebuffReversal" = 1, "DemonicDurability" = 1, "SoulFire" = 1.5)
						defense = 1.5
						endurance = 2.0
						strength = 1
						speed = 0.5
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			onAscension(mob/owner)
				simulateChoiceMutation(owner)
				..()
			simulateChoiceMutation(mob/owner)
				switch(owner.Class)
					if("Metal")
						var/newpassives = list("HeavyHitter" = 0.5, "DeathField" = 3, "PureReduction" = 1)
						passives+= newpassives
						strength = 2
						endurance = 2
						force = 2
					if("Fire")
						var/newpassives = list("HybridStrike" = 3, "SpiritFlow" = 4)
						passives+= newpassives
						strength = 2
						force = 2
						offense = 2
						anger=0.25
					if("Water")
						var/newpassives = list("SoftStyle" = 1, "LikeWater" = 1, "Flow" = 1, "FluidForm" = 1)
						passives+= newpassives
						speed = 1
						force = 2
						defense = 3
					if("Wind")
						var/newpassives = list("BlurringStrikes" = 0.5, "Flicker" = 1, "Godspeed"=1, "DenkoSekka" = 1)
						passives+= newpassives
						strength = 1
						force = 1
						speed = 4
					if("Gold")
						var/newpassives = list("Blubber" = 0.25, "CashCow" = 1, )
						passives+= newpassives
						ecoAdd = 1
						endurance = 3
						speed = 3
						strength = 1.5
					if("Dark")
						passives += list("Fury" = 1, "Momentum" = 1, "AsuraStrike" = 1)
						strength = 2
						speed = 2
						offense = 2
					if("Light")
						passives += list("CallousedHands" = 0.2, "VoidField" = 3, "EnergySteal" = 15, "Harden" = 1)
						defense = 1.5
						endurance = 2
						strength = 1
						offense = 0.5
				..()
