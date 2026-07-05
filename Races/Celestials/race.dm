race
	celestial
		name = "Celestial"
		desc = "Through either blessing, curse, or some other contract or agreement, Celestials are mortals- usually humans- who have been granted the powers of the otherworldly races. In spite of this, they are neither inherently holy nor unholy."
		visual = 'Celestial.png'
		passives = list("Tenacity" = 1, "Adrenaline" = 1)
		statPoints = 12
		locked = TRUE
		power = 1
		strength = 1
		endurance = 1
		force = 1
		offense = 1
		defense = 1
		speed = 1
		anger = 1.5
		learning = 1.25
		intellect = 2
		imagination = 1.5

		New()
			..()
			transformations = list()

		onFinalization(mob/user)
			var/Choice
			..()
			Choice=input(user, "Have you gained the powers of Angels (Master of Arms) or Demons (Demon Magic)?", "Celestial Type") in list("Angel", "Demon")
			user.CelestialAscension = Choice
			GiveRacial(user)
		proc/GiveRacial(mob/p)
			switch(p.CelestialAscension)
				if("Angel")
					transformations += new/transformation/celestial/Master_of_Arms
					p << "You have embarked upon the path of the Master of Arms."
					p.passive_handler.Set("BladeFisting", 1)
				if("Demon")
					transformations += new/transformation/celestial/Celestial_Devil_Trigger
					transformations += new/transformation/celestial/Celestial_Sin_Devil_Trigger
					p.TrueName=input(p, "What is the name of the Demon within?", "Get True Name") as text
					p.passive_handler.Set("Innovation", 1)
					p.passive_handler.Set("MartialMagic", 1)
					p.passive_handler.Set("BladeFisting", 1)
					p.passive_handler.Set("ManaGeneration", 5)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/RoyalGuard)
					p.AddSkill(new/obj/Skills/AutoHit/RoyalRelease)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/HellFire)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption)
					p << "Please set macros for (Dark Magic), (Hell Fire) and (Corruption), your 3 demon magics."
					p.client.updateCorruption()
					p.demon.selectPassive(p, "CORRUPTION_PASSIVES", "Buff", TRUE)
					p.demon.selectPassive(p, "CORRUPTION_DEBUFFS", "Debuff")
