ascension
	angel
		passives = list()
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			on_ascension_message = "Your authority strengthens."
			postAscension(mob/owner)
				..()
				if(owner.AngelAscension == "Guardian")
					owner.GrantGuardianItem(/obj/Items/Wearables/Guardian/Belt_of_Truth)
					owner << "(Please re-equip your Heavenly Armaments to receive their boons.)"
				if(owner.AngelAscension == "Mentor")
					owner << "Your connection to the Heavens reinforce your own understanding of Instinct."
				owner.Class = "Principality"
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			on_ascension_message = "You grow ever-closer to God."
			postAscension(mob/owner)
				//t2 style
				if(owner.AngelAscension=="Mentor")
					owner << "Your connection to the Heavens reinforce your own understanding of Instinct."
					owner.UILevel=2
				if(owner.AngelAscension == "Guardian")
					owner.GrantGuardianItem(/obj/Items/Armor/Guardian/Breastplate_of_Righteousness)
					owner.GrantGuardianItem(/obj/Items/Wearables/Guardian/Sandals_of_Peace)
					owner << "(Please re-equip your Heavenly Armaments to receive their boons.)"
				..()
				owner.Class = "Power"
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			on_ascension_message = "You shall not abide evil."
			postAscension(mob/owner)
				//t3 style/armor, can now teach style
				if(owner.AngelAscension=="Mentor")
					owner << "Your understanding of Instinct is close to completion."
					owner.UILevel=3
				if(owner.AngelAscension == "Guardian")
					owner.GrantGuardianItem(/obj/Items/Wearables/Guardian/Helmet_of_Salvation)
					owner.GrantGuardianItem(/obj/Items/Wearables/Guardian/Shield_of_Faith)
					owner << "(Please re-equip your Heavenly Armaments to receive their boons.)"
				..()
				owner.Class = "Virtue"
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			on_ascension_message = "You shall not abide evil."
			postAscension(mob/owner)
				//t4 style
				if(owner.AngelAscension=="Mentor")
					owner << "You have fully attuned yourself to your divine Instinct."
					owner.UILevel=4
				if(owner.AngelAscension == "Guardian")
					owner.GrantGuardianItem(/obj/Items/Sword/Guardian/Sword_of_the_Spirit)
					owner << "(Please re-equip your Heavenly Armaments to receive their boons.)"
				..()
				owner.Class = "Dominion"
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			on_ascension_message = "When closing your eyes, you bear witness to His heavenly throne."
			postAscension(mob/owner)
				..()
				owner.Class = "Throne"
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			on_ascension_message = "When closing your eyes, you bear witness to His heavenly throne."
			postAscension(mob/owner)
				..()
				owner.Class = "Seraphim"