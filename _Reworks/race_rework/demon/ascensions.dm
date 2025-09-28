ascension
	demon
		passives = list()
		proc/findTrueForm(mob/p)
			var/obj/Skills/Buffs/SlotlessBuffs/True_Form/Demon/d = new()
			d = locate() in p
			if(!d)
				world.log << "There was an error finding [p]'s ture form, please fix as their ascension is likely bugged"
				p << "Please report to the admin or discord that your true form is bugged on asc"
			return d
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 0.25, "SpiritPower" = 0.25, , "HellRisen" = 0.25)
			anger = 0.15
			intimidation = 50
			strength = 0.25
			endurance = 0.25
			speed = 0.25
			on_ascension_message = "You evolve into a stronger demon..."
			postAscension(mob/owner)
				if(!applied)
					owner.demon.selectPassive(owner, "CORRUPTION_PASSIVES", "Buff")
					owner.demon.selectPassive(owner, "CORRUPTION_DEBUFFS", "Debuff")
				..()
				owner.Class = "B"

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 0.75, "SpiritPower" = 0.25, "HellRisen" = 0.25)
			intimidation = 50
			strength = 0.25
			force = 0.5
			defense = 0.25
			offense = 0.25
			anger = 0.1
			on_ascension_message = "Your power is unrivaled..."
			postAscension(mob/owner)
				if(!applied)
					owner.demon.selectPassive(owner, "CORRUPTION_PASSIVES", "Buff")
					owner.demon.selectPassive(owner, "CORRUPTION_DEBUFFS", "Debuff")
				..()
				var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da = owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
				if(!da.secondDevilArmPick)
					owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2).pickSelection(owner, TRUE)
					owner.race?:sub_devil_arm_upgrades = 1
				owner.Class = "A"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 1, "SpiritPower" = 0.25)
			anger = 0.2
			intimidation = 100
			strength = 0.25
			force = 0.25
			endurance = 0.5
			postAscension(mob/owner)
				..()
				owner.Class = "S"
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 2)
			anger = 0.15
			intimidation = 250
			strength = 0.25
			force = 0.25
			defense = 0.75
			offense = 0.75
			endurance = 0.25
			speed = 0.75
			postAscension(mob/owner)
				..()
				owner.Class = "False King"
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("HellPower" = 1, "EndlessAnger" = 1, "SpiritPower" = 0.25)
			intimidation = 250

			postAscension(mob/owner)
				..()
				owner.Class = "Maou"