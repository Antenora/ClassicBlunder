ascension
	celestial
		passives = list()
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("SpiritPower" = 0.25)
			anger = 0.25
			strength = 0.25
			endurance = 0.25
			speed = 0.25
			recovery = 0.25
			on_ascension_message = "You become more in-tune with your otherworldly nature."
			postAscension(mob/owner)
				..()
				owner.Class = "Pale Imitation"

		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("SpiritPower" = 0.25, "TechniqueMastery" = 1)
			strength = 0.25
			force = 0.25
			defense = 0.25
			offense = 0.25
			recovery = 0.25
			anger = 0.1
			on_ascension_message = "You start to better understand your purpose."
			postAscension(mob/owner)
				..()
				if(owner.CelestialAscension=="Demon")
					var/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2/da = owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
					if(!da.secondDevilArmPick)
						owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2).pickSelection(owner, TRUE)
						owner.race?:sub_devil_arm_upgrades = 1
				if(owner.CelestialAscension=="Angel")
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Incomplete_Ultra_Instinct, owner))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Incomplete_Ultra_Instinct
						owner.AddSkill(s)
				owner.Class = "Lightbringer"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("SpiritPower" = 0.5, "TechniqueMastery" = 2)
			anger = 0.25
			strength = 0.25
			force = 0.25
			endurance = 0.5
			recovery = 0.35
			postAscension(mob/owner)
				..()
				if(owner.CelestialAscension=="Angel")
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Ultra_Instinct, owner))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Ultra_Instinct
						owner.AddSkill(s)
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("KiControlMastery"=2)
			anger = 0.3
			strength = 0.25
			force = 0.25
			defense = 0.75
			offense = 0.75
			endurance = 0.25
			recovery = 0.3
			speed = 0.75
			postAscension(mob/owner)
				..()
				if(owner.CelestialAscension=="Angel")
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Perfected_Ultra_Instinct, owner))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Perfected_Ultra_Instinct
						owner.AddSkill(s)
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("SpiritPower" = 0.2)
			intimidation = 250

			postAscension(mob/owner)
				..()
				owner.Class = "Transcendent"