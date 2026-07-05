race
	fae
		name = "Fae"
		desc = "Typically small creatures with an innate gift for magic. Mana runs in their veins like blood."
		visual = 'Fae.png'
		locked = TRUE
		power = 1
		strength = 1
		endurance = 1.25
		speed = 1.75
		force = 1.75
		offense = 1
		defense = 1.5
		anger = 1.5
		regeneration = 2
		recovery = 2
		imagination = 3

		onFinalization(mob/user)
			user.Class = input(user,"What type of Fae are you?", "Fae Species") in list("Pixie","Goblin")//I may add other types like Dryads later. Went with my 2 favorite types for now.
			switch(user.Class)
				if("Pixie") //Your typical butterfly-winged little tricksters. Forcies
					skills = list(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/FaeBuffs/Pixie_Mania)
					passives["ManaGeneration"] = 1
					passives["QuickCast"] = 1
				if("Goblin") //Playable Raccoons with a need for speed.
					skills = list(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/FaeBuffs/Fury_of_the_Small)
					passives["ManaGeneration"] = 1
					passives["Fury"] = 1

			..()

//Their innovations only apply in their buff. They can be found in the FireSpellSlots/AirSpellSlots/WaterSpellSlots/EarthSpellSlots files.
//I intentionally did not give them advanced magic innovations JUUUST in case, since we haven't seen them yet.
//Most their innovations are just 20%-50% Range + Speed/Damage increases. Some get status infliction bonuses, too.