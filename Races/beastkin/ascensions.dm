#define ASC_1_CHOICES list("Edge" = /ascension/sub_ascension/beastkin/edge, "Buck" = /ascension/sub_ascension/beastkin/buck, "Infi" = /ascension/sub_ascension/beastkin/infi)
#define ASC_2_CHOICES list("Ira" = /ascension/sub_ascension/beastkin/ira, "Rus" = /ascension/sub_ascension/beastkin/rus, "Mer" = /ascension/sub_ascension/beastkin/mer, "Mil" = /ascension/sub_ascension/beastkin/mil);
#define ASC_UPPER_CHOICES list()
#define ASC_UPPER_TEXT ""
ascension
	beastkin
		one
			unlock_potential = ASCENSION_ONE_POTENTIAL
			anger = 0.05
			choices = ASC_1_CHOICES;
			on_ascension_message = {"In the distant past, there were 3 Makers of Rift Artifacts. Who designed the equipment that infects your blood today?
Was it Edge, with the brand of the sword, bloodthirsty and determined?
Was it Buck, with the brand of the shield, patient and enduring?
Or was it Infi, with the brand of the ring, endlessly energetic?"};
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastkin")
							passives["Adrenaline"] = 1
							passives["Harden"] = 1
							passives["CallousedHands"] = 0.1
							endurance = 1
							strength = 0.5
							speed = 0.5
						if("Monkey King")
							passives["Nimbus"] = 1
							passives["HybridStrike"] = 1
							owner.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Monkey_Gourd)
							endurance = 0.3
							strength = 0.35
							offense = 0.35
							defense = 0.35
							speed = 0.3
							force = 0.35
						if("Unseen Predator")
							passives["Steady"] = 1
							passives["Brutalize"] = 1
							strength = 0.75
							offense = 0.75
							speed = 0.5
						if("Undying Rage")
							passives["Momentum"] = 1
							passives["KillerInstinct"] = 0.05
							passives["Wrathful Tenacity"] = 0.15
							strength = 0.5
							speed = 0.5
							offense = 0.25
							defense = -0.1
							endurance = -0.1
							anger = 1
						if("Feather Cowl")
							passives["BlockChance"] = 25
							passives["CriticalBlock"] = 0.25
							passives["CriticalChance"] = 10
							passives["CriticalDamage"] = 0.1
							speed = 1
							offense = 1
						if("Feather Knife")
							passives["CriticalChance"] = 25
							passives["CriticalDamage"] = 0.25
							passives["Musoken"] = 1;
							passives["AttackSpeed"] = 1;
							strength = 0.5
							speed = 0.5
							endurance = 0.5
							offense = 0.5
						if("Spirit Walker")
							passives["Flow"] = 1
							passives["Instinct"] = 1
							strength = 0.5
							endurance = 0.5
							offense = 0.5
							defense = 0.5
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							strength = 0.5
							force = 0.5
							offense = 0.5
							defense = 0.5
							passives["TechniqueMastery"] = 1
							passives["Touch of Death"] = 1
							passives["QuickCast"] = 1
							passives["ManaGeneration"] = 2
							passives["ManaStats"] = 0.25
						if("Fox Fire")
							passives["SoftStyle"] = 1
							passives["SoulFire"] = 1
							offense = 1
							force = 1
				..()
				if(!applied)
					if(owner.Class == "Shapeshifter")
						var/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Shapeshift/s = owner.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Racial/Beastkin/Shapeshift)
						s.c_buff.adjust_custom_buff(owner, s)
		two
			unlock_potential = ASCENSION_TWO_POTENTIAL
			anger = 0.25
			choices = ASC_2_CHOICES;
			on_ascension_message = {"Each of the 3 great Makers cast their Artifacts in a particular material. What is your equipment made from?
Is it made of Ira, quick to lash out?
Is it made of Rus, craving of speed?
Is it made of Mer, elusive and avoidant?
Or is it made of Mil? Not the admin. It's the defensive option. No offense, Mil."};
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastkin")
							owner.passive_handler.Increase("Blubber", 0.25)
							owner.passive_handler.Increase("Harden", 1)
							owner.passive_handler.Increase("CallousedHands", 0.1)
							endurance = 1
							strength = 0.5
							speed = 0.5
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							owner.passive_handler.Increase("Harden", 1)
							owner.passive_handler.Increase("HybridStrike", 1)
							endurance = 0.3
							strength = 0.35
							offense = 0.35
							defense = 0.35
							speed = 0.3
							force = 0.35
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 1)
							strength = 0.5
							offense = 0.75
							speed = 0.75
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.1)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.5
							speed = 0.25
							offense = 0.25
							defense = -0.25
							endurance = -0.25
							anger = 1
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 10);
							owner.passive_handler.Increase("CriticalBlock", 0.1);
							owner.passive_handler.Increase("CriticalChance", 5);
							owner.passive_handler.Increase("CriticalDamage", 0.05);
							speed = 1
							offense = 1
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 10)
							owner.passive_handler.Increase("CriticalDamage", 0.1)
							owner.passive_handler.Increase("Musoken", 1)
							owner.passive_handler.Increase("AttackSpeed", 1)
							strength = 0.5
							speed = 0.5
							endurance = 0.5
							offense = 0.5
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 1)
							owner.passive_handler.Increase("Instinct", 1)
							strength=0.5;
							force=0.5;
							offense=0.5;
							defense=0.5;
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							strength = 0.5
							force = 0.5
							offense = 0.5
							defense = 0.5
							owner.passive_handler.Increase("Touch of Death", 1);
							owner.passive_handler.Increase("ManaGeneration", 1);
							owner.passive_handler.Increase("QuickCast", 2);
							owner.passive_handler.Increase("ManaCapMult", 0.25);
							owner.passive_handler.Increase("ManaStats", 0.5);
							owner.passive_handler.Increase("MovementMastery", 1);
						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("SoulFire", 1)
							offense = 1
							force = 1
				..()
		three
			unlock_potential = ASCENSION_THREE_POTENTIAL
			anger=0.2
			on_ascension_message = "ouughhh ascension 3"
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastkin")
							owner.passive_handler.Increase("Blubber", 0.25)
							owner.passive_handler.Increase("Harden", 1)
							owner.passive_handler.Increase("CallousedHands", 0.1)
							endurance = 1
							strength = 0.5
							speed = 0.5
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							owner.passive_handler.Increase("HybridStrike", 1)
							endurance = 0.3
							strength = 0.35
							offense = 0.35
							defense = 0.35
							speed = 0.3
							force = 0.35
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 1)
							strength = 0.75
							offense = 0.5
							speed = 0.75
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.1)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.5
							speed = 0.25
							offense = 0.25
							defense = -0.25
							endurance = -0.25
							anger = 1
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 10);
							owner.passive_handler.Increase("CriticalBlock", 0.1);
							owner.passive_handler.Increase("CriticalChance", 5);
							owner.passive_handler.Increase("CriticalDamage", 0.05);
							speed = 1
							strength = 1
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 10)
							owner.passive_handler.Increase("CriticalDamage", 0.1)
							owner.passive_handler.Increase("Musoken", 1)
							owner.passive_handler.Increase("AttackSpeed", 1)
							strength = 0.5
							speed = 0.5
							endurance = 0.5
							offense = 0.5
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 1)
							owner.passive_handler.Increase("Instinct", 1)
							strength=0.5;
							force=0.5;
							offense=0.5;
							defense=0.5;
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							strength = 0.5
							force = 0.5
							offense = 0.5
							defense = 0.5
							owner.passive_handler.Increase("ManaGeneration", 1);
							owner.passive_handler.Increase("QuickCast", 1);
							owner.passive_handler.Increase("ManaCapMult", 0.25);
							owner.passive_handler.Increase("SpiritStrike", 0.25);
							owner.passive_handler.Increase("MovementMastery", 2);
							owner.passive_handler.Increase("ManaStats", 0.25);
						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("SoulFire", 1)
							offense = 1
							force = 1
				..()
		four
			unlock_potential = ASCENSION_FOUR_POTENTIAL
			anger = 0.5
			on_ascension_message = "ouughhh ascension 4"
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastkin")
							owner.passive_handler.Increase("Blubber", 0.25)
							owner.passive_handler.Increase("Harden", 1)
							owner.passive_handler.Increase("CallousedHands", 0.1)
							endurance = 1
							strength = 0.5
							speed = 0.5
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							owner.passive_handler.Increase("HybridStrike", 1)
							endurance = 0.3
							strength = 0.35
							offense = 0.35
							defense = 0.35
							speed = 0.3
							force = 0.35
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 1)
							strength = 0.75
							offense = 0.75
							speed = 0.5
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.1)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.5
							speed = 0.25
							offense = 0.25
							anger = 1.5
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 10);
							owner.passive_handler.Increase("CriticalBlock", 0.1);
							owner.passive_handler.Increase("CriticalChance", 5);
							owner.passive_handler.Increase("CriticalDamage", 0.05);
							speed = 1
							defense = 1
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 10)
							owner.passive_handler.Increase("CriticalDamage", 0.1)
							owner.passive_handler.Increase("Musoken", 1)
							owner.passive_handler.Increase("AttackSpeed", 1)
							strength = 0.5
							speed = 0.5
							endurance = 0.5
							offense = 0.5
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 1)
							owner.passive_handler.Increase("Instinct", 1)
							strength=0.5;
							force=0.5;
							offense=0.5;
							defense=0.5;
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							strength = 0.5
							force = 0.5
							offense = 0.5
							defense = 0.5
							owner.passive_handler.Increase("SpiritStrike", 0.25);
							owner.passive_handler.Increase("ManaCapMult", 0.25);
							owner.passive_handler.Increase("MovementMastery", 2);
							owner.passive_handler.Increase("ManaStats", 0.25);
						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("SoulFire", 1)
							owner.passive_handler.Increase("SpiritStrike", 1)
							offense = 1
							force = 1
				..()
		five
			unlock_potential = ASCENSION_FIVE_POTENTIAL
			anger = 0.5
			on_ascension_message = "ouughhh ascension 5"
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastkin")
							owner.passive_handler.Increase("Harden", 1)
							owner.passive_handler.Increase("CallousedHands", 0.1)
							owner.passive_handler.Increase("Deflection", 2)
							endurance = 1
							strength = 0.5
							speed = 0.5
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							owner.passive_handler.Increase("HybridStrike", 1)
							endurance = 0.3
							strength = 0.35
							offense = 0.35
							defense = 0.35
							speed = 0.3
							force = 0.35
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 1)
							strength = 0.5
							offense = 0.75
							speed = 0.75
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.1)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.25
							speed = 0.25
							offense = 0.25
							anger = 1
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 10);
							owner.passive_handler.Increase("CriticalBlock", 0.1);
							owner.passive_handler.Increase("CriticalChance", 5);
							owner.passive_handler.Increase("CriticalDamage", 0.05);
							speed = 1
							offense = 1
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 10)
							owner.passive_handler.Increase("CriticalDamage", 0.1)
							owner.passive_handler.Increase("Musoken", 1)
							owner.passive_handler.Increase("AttackSpeed", 1)
							strength = 0.5
							speed = 0.5
							endurance = 0.5
							offense = 0.5
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 1)
							owner.passive_handler.Increase("Instinct", 1)
							strength=0.5;
							force=0.5;
							offense=0.5;
							defense=0.5;
						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							strength = 0.5
							force = 0.5
							offense = 0.5
							defense = 0.5
							owner.passive_handler.Increase("SpiritStrike", 0.75);
							owner.passive_handler.Increase("ManaCapMult", 0.25);
							owner.passive_handler.Increase("MovementMastery", 2);
							owner.passive_handler.Increase("ManaStats", 0.5);
						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("SoulFire", 1)
							owner.passive_handler.Increase("SpiritStrike", 1)
							offense = 0.5
							force = 1
							endurance = 0.5
				..()
		six
			unlock_potential = ASCENSION_SIX_POTENTIAL
			anger = 1;
			on_ascension_message = "ouughhh ascension 6"
			onAscension(mob/owner)
				if(!applied)
					var/choice = owner.race?:Racial
					switch(choice)
						if("Heart of The Beastkin")
							owner.passive_handler.Increase("CallousedHands", 0.2)
							owner.passive_handler.Increase("Deflection", 2)
							owner.passive_handler.Increase("DemonicDurability", 1);
							endurance = 1
							strength = 0.5
							speed = 0.5
						if("Monkey King")
							owner.passive_handler.Increase("Nimbus", 1)
							owner.passive_handler.Increase("HybridStrike", 1)
							endurance = 0.3
							strength = 0.35
							offense = 0.35
							defense = 0.35
							speed = 0.3
							force = 0.35
						if("Unseen Predator")
							owner.passive_handler.Increase("Steady", 1)
							owner.passive_handler.Increase("Brutalize", 1)
							strength = 0.75
							offense = 0.5
							speed = 0.75
						if("Undying Rage")
							owner.passive_handler.Increase("Momentum", 1)
							owner.passive_handler.Increase("KillerInstinct", 0.1)
							owner.passive_handler.Increase("Wrathful Tenacity", 0.15)
							strength = 0.25
							speed = 0.25
							offense = 0.25
							anger = 1
						if("Feather Cowl")
							owner.passive_handler.Increase("BlockChance", 25);
							owner.passive_handler.Increase("CriticalBlock", 0.25);
							owner.passive_handler.Increase("CriticalChance", 20);
							owner.passive_handler.Increase("CriticalDamage", 0.2);
							speed = 1
							defense = 1
						if("Feather Knife")
							owner.passive_handler.Increase("CriticalChance", 25)
							owner.passive_handler.Increase("CriticalDamage", 0.25)
							owner.passive_handler.Increase("BlockChance", 25);
							owner.passive_handler.Increase("CriticalBlock", 0.25);
							strength = 0.5
							speed = 0.5
							endurance = 0.5
							offense = 0.5
						if("Spirit Walker")
							owner.passive_handler.Increase("Flow", 2)
							owner.passive_handler.Increase("Instinct", 2)
							owner.passive_handler.Increase("LikeWater", 3)
							strength=0.5;
							force=0.5;
							offense=0.5;
							defense=0.5;

						if("Trickster")
							ecoAdd = 1
							imaginationAdd = 0.5
							strength = 0.5
							force = 0.5
							offense = 0.5
							defense = 0.5

						if("Fox Fire")
							owner.passive_handler.Increase("SoftStyle", 1)
							owner.passive_handler.Increase("SoulFire", 1)
							owner.passive_handler.Increase("SpiritStrike", 1)
							offense = 0.5
							force = 1
							endurance = 0.5
				..()

