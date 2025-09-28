

race
	beastman
		name = "Beastman"
		desc = "Not to be confused with Saiyans."
		visual = 'Monstrous.png'
		strength = 1.25
		endurance = 1.25
		force = 1.25
		offense = 1.25
		defense = 1.25
		speed = 1.25
		regeneration = 1.5
		intellect = 0.5
		recovery = 2
		classes = list("Heart of The Beastman", "Monkey King", "Unseen Predator", "Undying Rage", \
						"Feather Cowl", "Feather Knife", "Spirit Walker", "Shapeshifter", "Trickster", \
						"Fox Fire")
		class_info = list("SETT", "WUKONG", "RENGAR", "TRYNDAMERE", "RAKAN", "XAYAH", "UDYR", "NIDALEE", "???", "AHRI")
		// attaching this here cause lol
		stats_per_class = list("Heart of The Beastman" = list(1.25, 1.5, 1, 1.25, 1, 1.5), "Monkey King" = list(1.25,1.25,1.25,1.25,1.25,1.25),\
						"Unseen Predator" = list(1.5, 1, 1, 1.5, 1, 1.5), "Undying Rage" = list(1.5, 1, 1, 1, 1, 2), \
						"Feather Cowl" = list(0.75, 2, 0.75, 1, 2, 1), "Feather Knife" = list(1.5, 0.75, 1, 1.5, 1, 1.75), \
						"Spirit Walker" = list(1, 1, 1.5, 1.5, 1.5, 1), "Shapeshifter" = list(1,1,1,1,1,1), \
						"Trickster" = list(1, 1, 2, 1, 1.5, 1), "Fox Fire" = list(1.5, 1, 2, 1.5, 0.75, 0.75 ))
		imagination = 1
		var/MaxGrit = 0
		var/Grit = 0
		var/Racial = "" // first sub ascension choice
		onFinalization(mob/user)
			user.EnhancedSmell=1
			user.EnhancedHearing=1
			Racial = user.Class
			GiveRacial(user)
			..()

		proc/GiveRacial(mob/p)
			switch(Racial)
				if("Heart of The Beastman")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/The_Grit)
					p.passive_handler.Set("Grit", 1)
				if("Monkey King")
					p.passive_handler.Increase("Hardening", 1)
					p.passive_handler.Increase("Instinct", 1)
					p.passive_handler.Increase("Nimbus", 1)
					var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastman/Never_Fall/nf = new(p)
					p.AddSkill(nf)
				if("Unseen Predator")
					p.passive_handler.passives["Heavy Strike"] = "Unseen Predator"
					p.AddSkill(new/obj/Skills/Queue/Racial/Beastman/Savagery)
				if("Undying Rage")
					p.passive_handler.Increase("Fury", 1)
					p.passive_handler.Increase("Wrathful Tenacity", 0.15)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage)

				if("Feather Cloak")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Feather_Cowl)
					p.passive_handler.Increase("Hardening", 1)
					p.passive_handler.Increase("Pressure", 1)
					p.passive_handler.Increase("SwordPunching", 1)

				if("Feather Knife")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Clean_Cuts)
					p.passive_handler.passives["Secret Knives"] = "Feathers"
					p.passive_handler.Increase("Tossing", 1)
					p.passive_handler.Increase("Momentum", 1)
					p.passive_handler.Increase("SwordPunching", 1)


				if("Spirit Walker")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Spirit_Walker/Pheonix_Form)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Spirit_Walker/Ram_Form)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Spirit_Walker/Bear_Form)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Spirit_Walker/Turtle_Form)

				if("Shapeshifter")
					var/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastman/Shapeshift/s = new()
					p.AddSkill(s)
					s.init(p)
					// set up the shapeshift buff

				if("Trickster")
					imagination = 2
					p.passive_handler.Increase("Spiritual Tactician", 1)
					p.AddSkill(new/obj/Skills/Utility/Imitate)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Blend_In)

				if("Fox Fire")
					p.Attunement = "Fox Fire"
					p.passive_handler.passives["Heavy Strike"] = "Fox Fire"
					p.AddSkill(new/obj/Skills/Projectile/Racial/Fox_Fire_Barrage)

