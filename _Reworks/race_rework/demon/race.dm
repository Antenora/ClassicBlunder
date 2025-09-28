race
	demon
		name = "Demon"
		desc = "A fragment of the formerly whole god known as Koek, the Shatter-Spawns bear a highly destructive potency that very few have ever hoped to control. Upon death, their souls return to the great demon Koek. They are often associated with ill omens, and the few that master their base instincts prefer to keep their identities hidden."
		visual = 'Eldritch.png'
		locked = TRUE
		power = 5
		strength = 2
		endurance = 1.5
		speed = 1.5
		offense = 1.5
		defense = 1
		force = 2
		regeneration = 3
		imagination = 2

		passives = list("AbyssMod" = 0.5, "Corruption" = 1, "StaticWalk" = 1, "SpaceWalk" = 1, "CursedWounds" = 1, "FakePeace" = 1, "MartialMagic" = 1)
		skills = list(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2,/obj/Skills/Utility/Imitate,  /obj/Skills/Buffs/SlotlessBuffs/Regeneration, /obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon, \
						/obj/Skills/Buffs/SlotlessBuffs/DemonMagic/DarkMagic, /obj/Skills/Buffs/SlotlessBuffs/DemonMagic/HellFire, /obj/Skills/Buffs/SlotlessBuffs/DemonMagic/Corruption)
		var/devil_arm_upgrades = 1
		var/sub_devil_arm_upgrades = 0

		proc/findTrueForm(mob/p)
			var/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/d = new()
			d = locate() in p
			if(!d)
				world.log << "There was an error finding [p]'s ture form, please fix as their ascension is likely bugged"
				p << "Please report to the admin or discord that your true form is bugged on asc"
			return d


		proc/checkReward(mob/p)
			var/max = round(p.Potential / 5) + 1
			if(p.Potential % 5 == 0 || devil_arm_upgrades < max)
				var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da = p.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
				if(devil_arm_upgrades + 1 > max) // not even possible
					return
				devil_arm_upgrades = max
				p << "Your devil arm evolves, toggle it on and off to use it"
				if(da.secondDevilArmPick)
					if(sub_devil_arm_upgrades < round((p.Potential - ASCENSION_TWO_POTENTIAL) / 10) + 1)
						if(p.Potential - ASCENSION_TWO_POTENTIAL % 10 == 0)
							sub_devil_arm_upgrades = round((p.Potential - ASCENSION_TWO_POTENTIAL) / 10) + 1
							p << "Your secondary devil arm evolves, toggle it on and off to use it"



		onFinalization(mob/user)
			..()
			user.EnhancedSmell = 1
			user.EnhancedHearing = 1
			user.TrueName=input(user, "As a demon, you have a True Name. It should be kept secret. What is your True Name?", "Get True Name") as text
			user << "The name by which you can be conjured is <b>[user.TrueName]</b>."
			user << "Please set macros for (Dark Magic), (Hell Fire) and (Corruption), your 3 demon magics."
			glob.trueNames.Add(user.TrueName)
			user.client.updateCorruption()
			user.demon.selectPassive(user, "CORRUPTION_PASSIVES", "Buff", TRUE)
			user.demon.selectPassive(user, "CORRUPTION_DEBUFFS", "Debuff")