race
	makaioshin
		name = "Makaioshin"
		desc = "Makaioshins are a mysterious race who's origins can't be accurately traced, but most claim to be something akin to fallen angels. While being able to flawlessly wield the powers of light and darkness- Angels and Demons- in equal measure, they tend towards having a chaotic nature due to their contradictory existence."
		visual = 'Eldritch.png'
		locked = TRUE
		power = 3
		strength = 2
		endurance = 2
		speed = 1.65
		offense = 1.5
		defense = 1.5
		force = 2
		regeneration = 3
		imagination = 3
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2, /obj/Skills/Buffs/SlotlessBuffs/Regeneration)
		var/devil_arm_upgrades = 1
		var/sub_devil_arm_upgrades = 0

		passives = list("HolyMod" = 0.5, "AbyssMod" = 0.5, "HellPower" = 1, "StaticWalk" = 1, "SpaceWalk" = 1, "SpiritPower" = 1, "MartialMagic" = 1, "BladeFisting" = 1)
		skills = list()
		proc/checkReward(mob/p)
			var/max = round(p.Potential / 5) + 1
			if(p.Potential % 5 == 0 || devil_arm_upgrades < max)
				var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da = p.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
				if(devil_arm_upgrades + 1 > max)
					return
				devil_arm_upgrades = max
				p << "Your devil arm evolves, toggle it on and off to use it"
				if(da.secondDevilArmPick)
					if(sub_devil_arm_upgrades < round((p.Potential - ASCENSION_TWO_POTENTIAL) / 10) + 1)
						if(p.Potential - ASCENSION_TWO_POTENTIAL % 10 == 0)
							sub_devil_arm_upgrades = round((p.Potential - ASCENSION_TWO_POTENTIAL) / 10) + 1
							p << "Your secondary devil arm evolves, toggle it on and off to use it"
		onFinalization(mob/user)
			user.Timeless = 1
			user.EnhancedSmell = 1
			user.EnhancedHearing = 1