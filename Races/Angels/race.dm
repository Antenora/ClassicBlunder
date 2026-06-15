race
	angel
		name = "Angel"
		desc = "An otherworldly race hailing from the Void. There are two varieties: ancient mentors to mortalkind that are said to be masters of martial and spiritual arts alike, and otherworldly guardians of (REDACTED)."
		visual = 'Angels.png'
		locked = TRUE
		statPoints = 5
		power = 7
		strength = 7
		endurance = 7
		speed = 7
		offense = 7
		defense = 7
		force = 7
		recovery = 3
		anger = 2
		regeneration = 1.7
		imagination = 3
		var/devil_arm_upgrades = 1

		passives = list("HolyMod" = 7, "StaticWalk" = 1, "SpaceWalk" = 1, "SpiritPower" = 2, "MartialMagic" = 1, "GodKi" = 0.7, "CalmAnger" = 1, "KiControlMastery" = 1, "TechniqueMastery" = 7)
		skills = list()
		onFinalization(mob/user)
			user.Timeless = 1
			var/Choice
			var/Confirm
			while(Confirm!="Yes")
				Choice=input(user, "Are you a Guardian (insert biblically accurate meme here) or a Mentor (adhere more closely to Dragon Ball Canon)?", "Angel Ascension") in list("Guardian", "Mentor")
				switch(Choice)
					if("Guardian")
						Confirm=alert(user, "Do you wish to guard the gates to the world beyond?", "Angel Ascension", "Yes", "No")
						if(Confirm=="Yes")
							user.Class = "Guardian"
							user.AddSkill(/obj/Skills/Utility/Recall_Armaments)
							user.GrantGuardianItem(/obj/Items/Sword/Guardian/Sword_of_the_Saint)
							user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Light)
							user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Divinity)
							user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/AngelMagic/Order)
							user << "Please set macros for (Light), (Divinity), and (Order), your 3 angel magics."
					if("Mentor")
						Confirm=alert(user, "Do you wish to mentor humanity and ensure the spiritual arts remain unforgotten?", "Angel  Ascension", "Yes", "No")
						if(Confirm=="Yes")
							if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/SlotlessUI/Divine_Instinct, user))
								user.Class = "Mentor"
								user.AddSkill(new /obj/Skills/Buffs/SlotlessBuffs/Autonomous/SlotlessUI/Divine_Instinct)
								user.AddSkill(/obj/Skills/Utility/Mentor_System)
								user << "You have embarked upon the path of true martial arts mastery: Ultra Instinct."
								user.Secret="Ultra Instinct"
								user.UILevel=1
								passives["StyleMastery"]=7
				user.AngelAscension = Choice
				//t1 style/armor unlocked

			user.passive_handler.increaseList(passives)
			for(var/s in skills)
				user.AddSkill(new s)
