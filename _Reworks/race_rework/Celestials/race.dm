race
	celestial
		name = "Celestial"
		desc = "Through either blessing, curse, or some other contract or agreement, Celestials are mortals- usually humans- who have been granted the powers of the otherworldly races. In spite of this, they are neither inherently holy nor unholy."
		visual = 'Humans.png'
		passives = list("Tenacity" = 1, "Adrenaline" = 1)
		statPoints = 12
		power = 1
		strength = 1
		endurance = 1
		force = 1
		offense = 1
		defense = 1
		speed = 1
		anger = 1.5
		learning = 1.25
		intellect = 2
		imagination = 1.5
		onFinalization(mob/user)
			var/Choice
			var/Confirm
			while(Confirm!="Yes")
				Choice=input(user, "Have you gained the powers of Angels or Demons?", "Celestial Type") in list("Angel", "Demon")
				switch(Choice)
					if("Angel")
						Confirm=alert(user, "Your body was imparted with the spark of the divine normally reserved for the soul, granting your mind and body natural harmony far beyond that of the average mortal.", "Angel", "Yes", "No")
						if(!locate(/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Selfless_State, user))
							var/obj/Skills/Buffs/NuStyle/s=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/HalfbreedAngelStyles/Selfless_State
							user.AddSkill(s)
							user << "You have embarked upon the path of true martial arts mastery: Ultra Instinct."
					if("Demon")
						Confirm=alert(user, "An inert demon has been forcibly implanted in your soul, allowing you to brandish its power as a weapon.", "Demon", "Yes", "No")
						user.TrueName=input(user, "What is the name of the Demon within?", "Get True Name") as text
						user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2)
				user.CelestialAscension = Choice