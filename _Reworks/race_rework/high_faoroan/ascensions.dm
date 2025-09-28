ascension
	high_faoroan
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			strength = 0.25
			endurance = 0.25
			force = 0.25
			offense = 0.25
			defense = 0.25
			speed = 0.25
			intimidation = 5
			passives = list("ManaCapMult" = 0.25, "Deicide" = 1, "Xenobiology" = 1, "SpiritFlow" = 1)
			choices = list("Distort" = /ascension/sub_ascension/high_faoroan/distort, "Define" = /ascension/sub_ascension/high_faoroan/define)
			skills = list(/obj/Skills/Buffs/SlotlessBuffs/Elf/God_Slicer)
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			strength = 0.25
			endurance = 0.25
			force = 0.25
			offense = 0.25
			defense = 0.25
			speed = 0.25
			anger = 0.15
			passives = list("TechniqueMastery" = 1.5, "ManaCapMult" = 0.25, "Deicide" = 1)
			choices = list("Destroy" = /ascension/sub_ascension/high_faoroan/destroy, "Remove" = /ascension/sub_ascension/high_faoroan/remove)
			skills = list(/obj/Skills/AutoHit/Elf/Compel)

		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			strength = 0.5
			endurance = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			speed = 0.5
			passives = list("ManaCapMult" = 0.25, "Deicide" = 1, "Xenobiology" = 1)
			intimidation = 10
			skills = list(/obj/Skills/AutoHit/Elf/Silence)
			postAscension(mob/owner)
				if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/high_faoroan/distort)
					owner.AddSkill(new/obj/Skills/AutoHit/Myriad_Truths)
				else if(owner.race.ascensions[1].choiceSelected == /ascension/sub_ascension/high_faoroan/define)
					owner.AddSkill(new/obj/Skills/AutoHit/Devils_Advocate)
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			intimidation = 10
			strength = 0.5
			endurance = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			speed = 0.5
			passives = list("ManaCapMult" = 0.25, "Deicide" = 2, "Xenobiology" = 1)
			choices = list("Conquer" = /ascension/sub_ascension/high_faoroan/conquer, "Obliterate" = /ascension/sub_ascension/high_faoroan/obliterate)
			skills = list(/obj/Skills/AutoHit/Elf/Flee)
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			intimidation = 10
			strength = 0.5
			endurance = 0.5
			force = 0.5
			offense = 0.5
			defense = 0.5
			speed = 0.5
			passives = list("Deicide" = 2, "Xenobiology" = 1)
			choices = list("Rest" = /ascension/sub_ascension/high_faoroan/rest, "Sacrifice" = /ascension/sub_ascension/high_faoroan/sacrifice)

ascension
	sub_ascension
		high_faoroan
			distort
				onAscension(mob/owner)
					for(var/obj/Skills/Buffs/SlotlessBuffs/The_Crown/tc in owner.contents)
						tc.passives["SwordPunching"] = 1
						tc.passives["TechniqueMastery"] = 1
						tc.passives["Adrenaline"] = 1
					..()

			define
				onAscension(mob/owner)
					for(var/obj/Skills/Buffs/SlotlessBuffs/The_Crown/tc in owner.contents)
						tc.passives["LikeWater"] = 2
						tc.passives["Flow"] = 1
						tc.passives["Instinct"] = 1
					..()

			destroy
				onAscension(mob/owner)
					for(var/obj/Skills/Buffs/SlotlessBuffs/The_Crown/tc in owner.contents)
						tc.passives["Persistence"] = 2
						tc.passives["Unstoppable"] = 1
						tc.passives["MartialMagic"] = 1
					..()

			remove
				onAscension(mob/owner)
					for(var/obj/Skills/Buffs/SlotlessBuffs/The_Crown/tc in owner.contents)
						tc.passives["Extend"] = 1
						tc.passives["SpiritStrike"] = 1
						tc.passives["HybridStrike"] = 1
					..()

			conquer
				onAscension(mob/owner)
					for(var/obj/Skills/Buffs/SlotlessBuffs/The_Crown/tc in owner.contents)
						tc.passives["DrainlessMana"] = 1
						tc.passives["SlayerMod"] = 2
						tc.passives["FavoredPrey"] = "Races"
						tc.passives["WeaponBreaker"] = 1
						tc.passives["Erosion"] = 0.25
					..()

			obliterate
				onAscension(mob/owner)
					for(var/obj/Skills/Buffs/SlotlessBuffs/The_Crown/tc in owner.contents)
						tc.passives["WeaponBreaker"] = 1
						tc.passives["Hellpower"] = 0.25
						tc.passives["Erosion"] = 0.25
					..()

			rest
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Regeneration)
			sacrifice
				skills = list(/obj/Skills/Buffs/SlotlessBuffs/Sacrifice)