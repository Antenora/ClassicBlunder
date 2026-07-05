race
	dragon
		name = "Dragon"
		desc = "Dragons represent aspects of the world, said to be born of animosity. Reborn nearing times of great tragedy, they only regain their past lives of protecting the world at age 20."
		visual = 'Dragon.png'


		power = 2
		strength = 1.75
		endurance = 1.75
		speed = 1
		force = 1.75
		offense = 1.25
		defense = 1.25
		anger = 2
		regeneration = 2
		recovery = 2
		imagination = 2

		onFinalization(mob/user)
			user.Class = input(user,"Pick an element to represent you.", "Dragon Element") in list("Fire","Metal", "Gold", "Wind", "Water","Dark", "Light")
			switch(user.Class)
				if("Fire")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/AutoHit/Fire_Breath, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Heat_Of_Passion)
					passives["DemonicDurability"] = 1
					passives["SpiritHand"] = 1
				if("Metal")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/Projectile/Shard_Storm, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Dragons_Tenacity)
					passives["Harden"] = 1
					passives["KBRes"] = 1
				if("Wind")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/Projectile/Static_Stream, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Wind_Supremacy)
					passives["Godspeed"] = 1
					passives["Flicker"] = 1
				if("Water")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/AutoHit/Oceanic_Wrath, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Slithereen_Crush)
					passives["SoftStyle"] = 1
					passives["Fishman"] = 1
					passives["FluidForm"] = 1
				if("Gold")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/Projectile/A_Pound_of_Gold, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Hoarders_Riches)
					user.EconomyMult *= 2
					passives["CashCow"] = 1
					passives["Blubber"] = 0.25
				if("Poison")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/AutoHit/Poison_Gas, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Melt_Down)
				if("Dark")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/AutoHit/Frenzy_Breath, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Frenzy_Mantle)
					passives["Fury"] = 1
					passives["Momentum"] = 1
					passives["Maki"] = 1
				if("Light")
					skills = list(/obj/Skills/AutoHit/Dragon_Roar, /obj/Skills/Projectile/Consuming_Light, /obj/Skills/Buffs/SlotlessBuffs/Autonomous/Dragon_Rage/Radiant_Aegis)
					passives["DemonicDurability"] = 1
					passives["SoulFire"] = 1.5
			..()
