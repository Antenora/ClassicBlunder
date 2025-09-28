race
	gajalaka
		name="Chakardi"
		icon_neuter= list('Gajalaka.dmi', 'Gaja EX.dmi', 'Gaja EX Maim.dmi')
		desc = {"Chakardi AKA (■■■■■■■■) are native to Mt. Red. Descendants of the illustrious Shiny-Rock tribe. Their former name is considered an insult, aimed to ground them as the monsters they once were decades ago. Chakardi is from the legend of Don Don Chaka, the sound of a heart thumping and Kardia (Heart). Often affluent and insanely resilient, their power is based on pulling from their emotions and heart to summon forth special power. (They’re the ill■■■■■■■.)"}
		visual = 'Gajalaka.png'
		passives = list("Tenacity" = 1,"CashCow" = 1, "Blubber" = 0.25)

		classes = list("Acolyte", "Rebel", "Nobility", "Heart")
		class_info = list("Faith driven Chakardi that harmonize with their once monsterious nature to manifest the power of Mt. Red. They follow the legends left behind by Kiwi the Greedy.", \
					"Chakardi who Rebel against the system, constantly lashing out and acting out. They forgo the need for money and attempt to tackle their problems with their own powers instead of the power derived from coin. Followers of ??? the Fang", \
					"Chakardi that view themselves as better than others, generally scholars and intellectuals that cast magic and chase the fabled 'greed magic', a hypothesized magic unique to their heritage. Often times they attribute their knowledge to an elder Elf, Gywneria.",\
					"Chakardi that will lay down their lives for their fellow Chakardi. Despite all odds they stand tall against opression, discrimination and any attempt to put them down. Their powers are most closely attuned to Don Don Chakra, which often causes them to be accused of being 'demons' also known as Shatter-Spawn.")
		stats_per_class = list("Acolyte" = list(1.25, 1.25, 1.25, 0.75, 1.25, 0.75), "Rebel" = list(1.5, 0.75, 1.25, 1.25, 0.75, 1) , \
							"Nobility" = list(0.75, 0.75, 2, 1.25, 1, 1.25), "Heart" = list(1.5, 1.5, 0.75, 1.25, 0.75, 1))
		power = 1
		strength = 0.75
		endurance = 0.75
		force = 0.75
		offense = 0.75
		defense = 0.75
		speed = 0.75
		intellect = 1.5
		imagination = 2
		economy = 2
		skills = list(/obj/Skills/Projectile/Goblin_Greed)

		onFinalization(mob/user)
			user.EnhancedSmell=1
			user.CyberizeMod = 0.5
			user.contents += new/obj/Items/Wearables/Icon_67
			user.contents += new/obj/Items/Wearables/Icon_68
			user.contents += new/obj/Items/Wearables/Icon_69
			user.contents += new/obj/Items/Wearables/Icon_70
			..()
			switch(user.Class)
				if("Acolyte")
					user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Acolyte)
				if("Rebel")
					user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Rebel)
					user.passive_handler.Set("SwordPunching", 1)
				if("Nobility")
					user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_The_Noble)
					user.passive_handler.Set("MartialMagic", 1)
				if("Heart")
					user.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Heart_of_Liberation)