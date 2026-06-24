race
	demon
		name = "Demon"
		desc = "Dark shadows cast from a world beyond our own, given individuality and humanity."
		visual = 'Demon.png'
		locked = TRUE
		power = 6
		strength = 2
		endurance = 1.5
		speed = 1.5
		offense = 1.5
		defense = 1
		force = 2
		regeneration = 3
		imagination = 2

		passives = list("AbyssMod" = 0.5, "Corruption" = 1, "StaticWalk" = 1, "SpaceWalk" = 1, "CursedWounds" = 1, "FakePeace" = 1, "MartialMagic" = 1)
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2,/obj/Skills/Utility/Imitate, /obj/Skills/Utility/Telepathy,  /obj/Skills/Buffs/SlotlessBuffs/Regeneration,  \
						/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic, /obj/Skills/Buffs/SlotlessBuffs/DemonMagic/HellFire, /obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption, /obj/Skills/Teleport/Traverse_Depths, \
						/obj/Skills/Buffs/SlotlessBuffs/Racial/Demon/Disguise)
		var/devil_arm_upgrades = 1
		var/sub_devil_arm_upgrades = 0

		proc/checkReward(mob/p)
			p.checkDevilArmUpgrades();

		onFinalization(mob/user)
			..()
			for(var/transformation/demon/devil_trigger/mazoku/T in user.race.transformations)
				user.race.transformations -= T
				del T
			user.EnhancedSmell = 1
			user.EnhancedHearing = 1
			user.TrueName=input(user, "As a demon, you have a True Name. It should be kept secret. What is your True Name?", "Get True Name") as text
			user << "The name by which you can be conjured is <b>[user.TrueName]</b>."
			user << "Please set macros for (Dark Magic), (Hell Fire) and (Corruption), your 3 demon magics."
			glob.trueNames.Add(user.TrueName)
			user.client.updateCorruption()
			user.demon.selectPassive(user, "CORRUPTION_PASSIVES", "Buff", TRUE)
			user.demon.selectPassive(user, "CORRUPTION_DEBUFFS", "Debuff")
