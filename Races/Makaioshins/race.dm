race
	makaioshin
		name = "Makaioshin"
		desc = "Makaioshins are a mysterious race who's origins can't be accurately traced, but most claim to be something akin to fallen angels. While being able to flawlessly wield the powers of light and darkness- Angels and Demons- in equal measure, they tend towards having a chaotic nature due to their contradictory existence."
		visual = 'Makaioshins.png'
		locked = TRUE
		power = 8
		strength = 1.75
		endurance = 2
		speed = 1.5
		offense = 1.5
		defense = 1.5
		force = 1.75
		regeneration = 3
		imagination = 3
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2, /obj/Skills/Buffs/SlotlessBuffs/Regeneration, /obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic, /obj/Skills/Buffs/SlotlessBuffs/DemonMagic/HellFire, /obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption)
		passives = list("ChaosMod" = 0.5, , "ChaosResist" = 0.5, "HellPower" = 1, "FakePeace"=1, "StaticWalk" = 1, "SpaceWalk" = 1, "SpiritPower" = 1, "MartialMagic" = 1, "BladeFisting" = 1, "Incomplete" = 1, "Corruption" = 1)
		var/devil_arm_upgrades = 1
		var/sub_devil_arm_upgrades = 0
		/*proc/findFalldown(mob/p)
			var/obj/Skills/Buffs/SlotlessBuffs/Falldown_Mode/Makaioshin/d = new()
			d = locate() in p
			if(!d)
				world.log << "There was an error finding [p]'s ture form, please fix as their ascension is likely bugged"
				p << "Please report to the admin or discord that your true form is bugged on asc"
			return d*/
		proc/checkReward(mob/p)
			p.checkDevilArmUpgrades();
		onFinalization(mob/user)
			user.TrueName=input(user, "Your demonic nature has a mind of its own. What name shall you use to call upon it?", "Get True Name") as text
			user << "The name your demonic half goes by is <b>[user.TrueName]</b>."
			user.EnhancedSmell = 1
			user.EnhancedHearing = 1
			user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Light)
			user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Divinity)
			user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Order)
			user << "Please set macros for (Light), (Divinity), and (Order), your 3 angel magics."
			user << "Please set macros for (Dark Magic), (Hell Fire) and (Corruption), your 3 demon magics."
			user.client.updateCorruption()
			user.demon.selectPassive(user, "CORRUPTION_PASSIVES", "Buff", TRUE)
			user.demon.selectPassive(user, "CORRUPTION_DEBUFFS", "Debuff")
			user.passive_handler.increaseList(passives)
			for(var/s in skills)
				user.AddSkill(new s)
