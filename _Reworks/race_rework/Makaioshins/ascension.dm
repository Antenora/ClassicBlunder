ascension
	makaioshin
		passives = list()
		proc/findFalldown(mob/p)
			var/obj/Skills/Buffs/SlotlessBuffs/Falldown_Mode/Makaioshin/d = new()
			d = locate() in p
			if(!d)
				world.log << "There was an error finding [p]'s Falldown Mode, please fix as their ascension is likely bugged"
				p << "Please report to the admin or discord that your Falldown Mode is bugged on asc"
			return d
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 0.25, "HolyMod" = 0.25, "SpiritPower" = 0.25, , "HellRisen" = 0.25)
			anger = 0.15
			intimidation = 50
			strength = 0.25
			endurance = 0.25
			speed = 0.25
			recovery = 0.25
			on_ascension_message = "You hone your control over your contradictory nature."
			postAscension(mob/owner)
				..()
				owner.Class = "The Accuser"

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 0.75, "HolyMod" = 0.5, "SpiritPower" = 0.25, "HellRisen" = 0.25)
			intimidation = 50
			strength = 0.25
			force = 0.5
			defense = 0.25
			offense = 0.25
			recovery = 0.25
			anger = 0.1
			on_ascension_message = "Chaos flows through your every breath."
			postAscension(mob/owner)
				..()
				var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da = owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
				if(!da.secondDevilArmPick)
					owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2).pickSelection(owner, TRUE)
					owner.race?:sub_devil_arm_upgrades = 1
				if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Incomplete_Ultra_Instinct, owner))
					var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Incomplete_Ultra_Instinct
					owner.AddSkill(s)
				owner.Class = "Lightbringer"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("HellPower" = 0.25, "AbyssMod" = 1, "HolyMod" = 2, "SpiritPower" = 0.25, "TechniqueMastery" = 1)
			anger = 0.2
			intimidation = 100
			strength = 0.25
			force = 0.25
			endurance = 0.5
			recovery = 0.25
			postAscension(mob/owner)
				..()
				owner.Class = "Shadowlord"
				if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Ultra_Instinct, owner))
					var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Ultra_Instinct
					owner.AddSkill(s)
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("HellPower" = 0.25, "HolyMod" = 2, "AbyssMod" = 2, " KiControlMastery"=1)
			anger = 0.15
			intimidation = 250
			strength = 0.25
			force = 0.25
			defense = 0.75
			offense = 0.75
			endurance = 0.25
			recovery = 0.25
			speed = 0.75
			postAscension(mob/owner)
				..()
				owner.Class = "Morningstar"
				if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Perfected_Ultra_Instinct, owner))
					var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Perfected_Ultra_Instinct
					owner.AddSkill(s)
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("HellPower" = 1, "EndlessAnger" = 1, "SpiritPower" = 0.25, "GodKi"=1)
			intimidation = 250

			postAscension(mob/owner)
				..()
				owner.Class = "The Shining One"