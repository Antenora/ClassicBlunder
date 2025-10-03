ascension
	angel
		passives = list()
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			passives = list("HolyMod" = 0.25, "SpiritPower" = 0.25)
			strength = 0.25
			endurance = 0.25
			speed = 0.25
			recovery = 0.25
			on_ascension_message = "Your authority strengthens."
			postAscension(mob/owner)
				..()
				owner.Class = "Principality"
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			passives = list("HolyMod" = 0.75, "SpiritPower" = 0.25)
			strength = 0.15
			force = 0.25
			defense = 0.35
			offense = 0.15
			recovery = 0.25
			on_ascension_message = "You grow ever-closer to God."
			postAscension(mob/owner)
				//t2 style
				if(owner.AngelAscension=="Mentor")
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles/Incomplete_Ultra_Instinct, owner))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles/Incomplete_Ultra_Instinct
						owner.AddSkill(s)
						owner << "Your game-designer wants to get this over with so she can feel like she did something substantial today but can't think of cool flavor text. Contact her about this later."
						owner.SagaLevel=2
				..()
				owner.Class = "Power"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			passives = list("HolyMod" = 1, "SpiritPower" = 0.25, " KiControlMastery"=1,  "CalmAnger" = 1)
			anger = 0.2
			strength = 0.25
			force = 0.25
			endurance = 0.5
			on_ascension_message = "You shall not abide evil."
			postAscension(mob/owner)
				//t3 style/armor, can now teach style
				if(owner.AngelAscension=="Mentor")
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles/Ultra_Instinct, owner))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles/Ultra_Instinct
						owner.AddSkill(s)
						owner << "Jesse is gay and forgot to fill this out before the wipe launched. Everyone laugh at her (lovingly, or she'll get sad and AFK for the rest of the day)."
						owner.SagaLevel=3
				..()
				owner.Class = "Virtue"
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			passives = list("HolyMod" = 2, "TechniqueMastery" = 1)
			strength = 0.25
			force = 0.25
			defense = 0.75
			offense = 0.75
			endurance = 0.25
			speed = 0.75
			recovery = 0.25
			on_ascension_message = "You shall not abide evil."
			postAscension(mob/owner)
				//t4 style
				if(owner.AngelAscension=="Mentor")
					if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles/Perfected_Ultra_Instinct, owner))
						var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/AngelStyles/Perfected_Ultra_Instinct
						owner.AddSkill(s)
						owner << "Fourth flavor text is the charm, right?."
						owner.SagaLevel=4
				..()
				owner.Class = "Dominion"
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			passives = list("SpiritPower" = 0.25)//not sure what to give here. i'll think about it
			on_ascension_message = "When closing your eyes, you bear witness to His heavenly throne."
			postAscension(mob/owner)
				..()
				owner.Class = "Throne"