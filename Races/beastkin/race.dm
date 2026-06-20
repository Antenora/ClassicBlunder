

race
	beastkin
		name = "Beastkin"
		desc = "A loose collection of ex-humans, united only in that they were mutated from the remnants of the Lost Artifacts of the Rift."
		visual = 'Monstrous.png'
		strength = 1.25
		endurance = 1.25
		force = 1.25
		offense = 1.25
		defense = 1.25
		speed = 1.25
		regeneration = 1.5
		intellect = 0.5
		classes = list("Heart of The Beastkin", "Monkey King", "Unseen Predator", "Undying Rage", \
						"Feather Cowl", "Feather Knife", "Spirit Walker", "Trickster", \
						"Fox Fire")
		class_info = list("{Beasthearts gain The Grit, a triggered buff which grants you a shield depending on how much damage you've taken and dished out.\
They have increased tenacity when pushed to their breaking point (below 10% health).\
They gain steady and doublestrike passives.\
Inspiration taken from Sett (League of Legends)}",\
"WUKONG",\
"RENGAR",\
"TRYNDAMERE",\
"RAKAN",\
"XAYAH",\
"UDYR",\
"NIDALEE",\
"<:3c",\
"AHRI")
		// attaching this here cause lol
		stats_per_class = list("Heart of The Beastkin" = list(1.25, 2, 0.75, 1, 1, 1.5), "Monkey King" = list(1.25,1.25,1.25,1.25,1.25,1.25),\
						"Unseen Predator" = list(1.75, 0.75, 1, 1.75, 0.75, 1.5), "Undying Rage" = list(1.75, 0.75, 1.75, 1, 0.75, 1.5), \
						"Feather Cowl" = list(0.75, 2, 0.75, 1.25, 1.5, 1.25), "Feather Knife" = list(1.5, 0.75, 1, 1.75, 0.75, 1.75), \
						"Spirit Walker" = list(1, 1.5, 1, 0.75, 0.75, 1), \
						"Trickster" = list(1, 1, 2, 1, 1.5, 1), "Fox Fire" = list(0.75, 1, 2, 1.5, 1.5, 0.75 ))
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
				if("Heart of The Beastkin")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/The_Grit)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_the_Half_Beast)
					p.passive_handler.Set("Grit", 1)
					p.passive_handler.Set("Steady", 1)
					p.passive_handler.Set("DoubleStrike",1)
				if("Monkey King")
					p.passive_handler.Increase("Nimbus", 1)
					var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Beastkin/Never_Fall/nf = new(p)
					p.AddSkill(nf)
					p.passive_handler.Increase("Instinct", 1)

				if("Unseen Predator")
					p.passive_handler.passives["Heavy Strike"] = "Unseen Predator"
					p.AddSkill(new/obj/Skills/Queue/Racial/Beastkin/Savagery)
				if("Undying Rage")
					p.passive_handler.Increase("Fury", 1)
					p.passive_handler.Increase("Wrathful Tenacity", 0.15)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Racial/Undying_Rage)

				if("Feather Cowl")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Feather_Cowl)
					p.passive_handler.Increase("Harden", 1)
					p.passive_handler.Increase("Pressure", 1)
					p.passive_handler.Increase("BladeFisting", 1)

				if("Feather Knife")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Clean_Cuts)
					p.passive_handler.passives["Extra Secret Knives"] = "Feathers"
					p.passive_handler.Increase("Tossing", 1)
					p.passive_handler.Increase("Momentum", 1)
					p.passive_handler.Increase("BladeFisting", 1)


				if("Spirit Walker")
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Pheonix_Form)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Ram_Form)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Bear_Form)
					p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Spirit_Walker/Turtle_Form)

				if("Trickster")
					imagination = 2
					intellect = 1.5;
					p.SetStat("Intellect", intellect)
					p.SetStat("Imagination", imagination)
					p.passive_handler.Increase("Spiritual Tactician", 1)
					p.passive_handler.Increase("ManaGeneration", 2);
					p.passive_handler.Increase("Touch of Death", 1);
					p.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Spirit_Form);
					p.findOrAddSkill(/obj/Skills/AutoHit/Mist_Form);
					p.findOrAddSkill(/obj/Skills/Utility/Imitate);
					p.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Blend_In);

				if("Fox Fire")
					p.Attunement = "Fox Fire"
					p.passive_handler.passives["Heavy Strike"] = "Fox Fire"
					p.passive_handler.Increase("SpiritStrike", 1) //Allows their Basic attacks to use force INSTEAD of Strength.
					p.AddSkill(new/obj/Skills/Projectile/Racial/Fox_Fire_Barrage)

