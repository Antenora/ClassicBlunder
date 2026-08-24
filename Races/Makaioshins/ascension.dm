ascension
	makaioshin
		/*passives = list()
		proc/findFalldown(mob/p)
			var/obj/Skills/Buffs/SlotlessBuffs/Falldown_Mode/Makaioshin/d = new()
			d = locate() in p
			if(!d)
				world.log << "There was an error finding [p]'s Falldown Mode, please fix as their ascension is likely bugged"
				p << "Please report to the admin or discord that your Falldown Mode is bugged on asc"
			return d*/
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("HellPower" = 0.25, "ChaosMod" = 0.25, "ChaosReist" = 0.25, "SpiritPower" = 0.25, "HellRisen" = 0.25, "Incomplete" = -0.25)
			anger = 0.15
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
			passives = list("HellPower" = 0.25, "ChaosMod" = 0.75, "ChaosReist" = 0.75, "SpiritPower" = 0.25, "HellRisen" = 0.25, "Incomplete" = -0.25)
			strength = 0.25
			force = 0.5
			defense = 0.25
			offense = 0.25
			recovery = 0.25
			anger = 0.1
			on_ascension_message = "Chaos flows through your every breath."
			postAscension(mob/owner)
				..()
				owner.Class = "Lightbringer"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("HellPower" = 0.25, "ChaosMod" = 1.5, "ChaosResist" = 1.5, "SpiritPower" = 0.25, "TechniqueMastery" = 1, "Incomplete" = -0.25)
			anger = 0.2
			strength = 0.25
			force = 0.25
			endurance = 0.5
			recovery = 0.25
			postAscension(mob/owner)
				..()
				owner.Class = "Shadowlord"
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("HellPower" = 0.25, "ChaosMod" = 2, "ChaosResist" = 2, "KiControlMastery"=1, "Incomplete" = -0.25)
			anger = 0.15
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
				if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Chaos_Control, owner))
					owner.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Chaos_Control)
				if(!locate(/obj/Skills/AutoHit/Chaos_Degrade, owner))
					owner.AddSkill(new/obj/Skills/AutoHit/Chaos_Degrade)
				if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Chaos_Soldier, owner))
					owner.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Chaos_Soldier)
				owner.passive_handler.Increase("ChaosRuler", 1)
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("HellPower" = 1, "EndlessAnger" = 1, "SpiritPower" = 0.25, "GodKi"=1)

			postAscension(mob/owner)
				..()
				owner.Class = "The Shining One"
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			passives = list("GodKi"=1)

			postAscension(mob/owner)
				..()
				owner.Class = "The Shining One"
