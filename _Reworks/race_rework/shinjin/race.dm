race
	shinjin
		name = "Shinjin"
		desc = "shinjin things man lol"
		visual = 'Humans.png'

		locked = TRUE
		power = 1
		strength = 1
		endurance = 1
		force = 1
		offense = 1
		defense = 1.25
		speed = 1
		anger = 1.5
		learning = 1
		onFinalization(mob/user)
			user.AddSkill(new/obj/Skills/Utility/Telepathy)
			user.AddSkill(new/obj/Skills/Utility/Sense)
			user.AddSkill(new/obj/Skills/Telekinesis)
			user.AddSkill(new/obj/Skills/Utility/Observe)
			user.AddSkill(new/obj/Skills/Utility/Keep_Body)
			user.AddSkill(new/obj/Skills/Reincarnation)
			user.AddSkill(new/obj/Skills/Utility/Teachz)
			user.Timeless = 1
			var/Choice
			var/Confirm
			while(Confirm!="Yes")
				Choice=input(user, "Which realm do you swear your loyalty to?", "Shinjin Ascension") in list("Kai", "Makai")
				switch(Choice)
					if("Kai")
						Confirm=alert(user, "Do you pledge your allegiance to the continuity and propserity of the Living Realm?", "Shinjin Ascension", "Yes", "No")
					if("Makai")
						Confirm=alert(user, "Do you pledge your allegiance to the expansion and domination of the Demon Realm?", "Shinjin Ascension", "Yes", "No")
			if(Choice=="Kai")
				user.passive_handler.Increase("SpiritPower", 1)
				user.passive_handler.Increase("CalmAnger", 1)
			if(Choice=="Makai")
				user.passive_handler.Increase("HellPower", 1)
				user.passive_handler.Increase("StaticWalk", 1)
				anger = 2
				user.NewAnger(2)
				user.Intimidation=10
				user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Majin)
			user.ShinjinAscension = Choice
			var/pickedPath = input(user, "Pick a Kaio Direction.") in list("North", "East", "South", "West")
			user.Class = pickedPath
			switch(pickedPath)
				if("North")
					user.passive_handler.Increase("Restoration", 1)
					user.Attunement="Earth"
					user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kaioken)
					user.AddSkill(new/obj/Skills/Projectile/Genki_Dama)
					// var/obj/Skills/Buffs/NuStyle/UnarmedStyle/North_Star_Style/nss=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/North_Star_Style
				if("East")
					user.OxygenMax*=4
					user.passive_handler.Increase("SpaceWalk", 1)
					user.Attunement = "Wind"
					user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Toppuken)
					user.AddSkill(new/obj/Skills/AutoHit/Gwych_Dymestl)
					// var/obj/Skills/Buffs/NuStyle/UnarmedStyle/East_Star_Style/ess=new/obj/Skills/Buffs/NuStyle/UnarmedStyle/East_Star_Style
				if("South")
					user.Attunement="Fire"
					user.passive_handler.Increase("WalkThroughHell", 1)
					user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Rekkaken)
					user.AddSkill(new/obj/Skills/Projectile/Zone_Attacks/Global_Devastation)
					// var/obj/Skills/Buffs/NuStyle/SwordStyle/South_Star_Style/sss=new/obj/Skills/Buffs/NuStyle/SwordStyle/South_Star_Style
				if("West")
					user.Attunement = "Water"
					user.passive_handler.Increase("WaterWalk", 1)
					user.AddSkill(new/obj/Skills/Buffs/SpecialBuffs/Kyoukaken)
					user.AddSkill(new/obj/Skills/AutoHit/Great_Deluge)
					// var/obj/Skills/Buffs/NuStyle/FreeStyle/West_Star_Style/wss=new/obj/Skills/Buffs/NuStyle/FreeStyle/West_Star_Style
			..()