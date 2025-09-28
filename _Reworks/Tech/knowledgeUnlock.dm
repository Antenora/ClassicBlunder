//#define subtypesof(typepath) ( typesof(typepath) - typepath )

var/knowledgePaths/tech/list/TechnologyTree = list()

/proc/fillOutTechTree()
	. = typesof(/knowledgePaths/tech)
	for(var/x in .)
		var/knowledgePaths/tech = new x
		TechnologyTree[tech.name] += tech
		for(var/i in TechnologyTree)
			if(tech.name in TechnologyTree[i].requires)
				tech.unlocks += "[i], "
		tech.unlocks = replacetext(tech.unlocks, ", ", "", -1, -4)
#define BASE_COST 30


/mob/proc/removeTechKnowledge(mob/p, path, cost, prompt)
	if(path in MagicList) return
	var/theCost = cost
	var/knowledgePaths/tech = TechnologyTree[path]
	if(!tech) return
	theCost *= 1 + (0.25 * length(tech.requires))
	if(tech.breakthrough)
		theCost /= 4
	theCost = round(theCost,  1)
	var/confirmation = "Yes"
	if(prompt)
		confirmation = input(p,"Are you sure you want to refund [tech.name] for [theCost] points?") in list("Yes", "No")
	if(confirmation == "Yes")
		p.RPPSpendable += theCost
		p.RPPSpent -= theCost
		p.knowledgeTracker.learnedKnowledge -= tech.name
		p << "You have refunded [tech.name] for [theCost]!"
	switch(path)
		if("CyberEngineering")
			CyberEngineeringUnlocked=0
		if("Engineering")
			EngineeringUnlocked=0
			ForgingUnlocked--
		if("MilitaryTechnology")
			MilitaryTechnologyUnlocked=0
		if("AdvancedTransmissionTechnology")
			AdvancedTransmissionTechnologyUnlocked=0
		if("Telecommunications")
			TelecommunicationsUnlocked=0
		if("Medicine")
			MedicineUnlocked=0
		if("ImprovedMedicalTechnology")
			ImprovedMedicalTechnologyUnlocked=0
			for(var/obj/Skills/Utility/Surgery/s in src)
				del s
		if("Repair")
			RepairAndConversionUnlocked=0
			for(var/obj/Skills/Utility/Reforge/r in src)
				del r
		if("MilitaryEngineering")
			MilitaryEngineeringUnlocked=0
			ForgingUnlocked--
		if("Forge")
			ForgingUnlocked=0
		if("Enhancement")
			for(var/obj/Skills/Utility/Upgrade_Equipment/ue in src)
				del ue
				ForgingUnlocked--
		if("Locksmithing")
			for(var/obj/Skills/Utility/Copy_Key/ck in src)
				del ck
		if("Smelting")
			for(var/obj/Skills/Utility/Smelt/s in src)
				del s
		if("Cyber Augmentations")
			for(var/obj/Skills/Utility/Cybernetic_Augmentation/ca in src)
				del ca
		if("Revival Protocol")
			for(var/obj/Skills/Utility/Revival_Protocol/rp in src)
				del rp
		if("Espionage Equipment")
			for(var/obj/Skills/Utility/Espionage_Scan/es in src)
				del es

/mob/verb/learnTech()
	set category = "Utility"
	set name = "Technology"
	var/int = Intelligence
	if(passive_handler["Spiritual Tactician"])
		if(Imagination > Intelligence)
			int = Imagination
	var/theCost = glob.TECH_BASE_COST / int
	var/list/thingCanBuy = list()
	if(length(TechnologyTree) < 1)
		fillOutTechTree()

	for(var/n in TechnologyTree)
		var/knowledgePaths/tech = TechnologyTree[n]
		if(n in knowledgeTracker.learnedKnowledge)
			continue
		if(length(tech.requires) > 0)
			// this means they have requirements
			if(tech.meetsReqs(knowledgeTracker.learnedKnowledge)) // send the list

				thingCanBuy += tech.name
			else
				continue
		else
			thingCanBuy += tech.name
	var/input = input(src,"What would you like to learn?") in thingCanBuy + "Cancel"
	if(input == "Cancel")
		return
	if(input in thingCanBuy)
		var/knowledgePaths/tech = TechnologyTree[input]
		if(tech.meetsReqs(knowledgeTracker.learnedKnowledge))
			theCost *= 1 + (0.25 * length(tech.requires))
			if(tech.breakthrough)
				theCost /= 4
			theCost = round(theCost,  1)
			var/confirmation = input(src,"Are you sure you want to learn [tech.name] for [theCost] points?\nUnlocks: [tech.unlocks]\nDescription: [tech.description]") in list("Yes", "No")
			if(confirmation == "Yes")
				if(SpendRPP(theCost, "[tech.name]"))
					UnlockTech(tech, "Technology")
		else
			src << "You do not meet the requirements to learn [tech.name] ([jointext(tech.requires, " , ")])!"

/mob/proc/UnlockTech(knowledgePaths/t, type)
	src << " You have unlocked the knowledge of <b><u>[t.name]</u></b>!"
	addUnlockedTech(t.name, type)
	// AddUnlockedTechnology(t.name)
	switch(t.name)
		// ALCHEMY //
		if("Alchemy")
			AlchemyUnlocked=1
			PotionTypes.Add("Wild Herb")
		if("Healing Herbs")
			PotionTypes.Add("Healing Herb")
		if("Magic Herbs")
			PotionTypes.Add("Magic Herb")
		if("Toxic Herbs")
			PotionTypes.Add("Toxic Herb")
		if("Hallucinogen Herbs")
			PotionTypes.Add("Hallucinogen Herb")
		if("Philter Herbs")
			PotionTypes.Add("Philter Herb")
		if("Stimulant Herbs")
			PotionTypes.Add("Stimulant Herb")
		if("Relaxant Herbs")
			PotionTypes.Add("Relaxant Herb")
		if("Numbing Herbs")
			PotionTypes.Add("Numbing Herb")
		if("Mutagenic Herbs")
			PotionTypes.Add("Mutagenic Herb")
		if("Refreshment Herbs")
			PotionTypes.Add("Refreshment Herb")

		if("ImprovedAlchemy")
			ImprovedAlchemyUnlocked=1
			PotionTypes.Add("Wild Herb")
			if(!locate(/obj/Skills/Utility/Transmute, src))
				src << "You now know enough about alchemy and magic circuits to transmute a victim into a true Philosopher Stone!  This will cost their life..."
				src.AddSkill(new/obj/Skills/Utility/Transmute)
		// END ALCHEMY //
		// TOOL SHIT //
		if("ToolEnchantment")
			ToolEnchantmentUnlocked=1
			if(!locate(/obj/Skills/Utility/Create_Magic_Circle, src))
				src << "You learn to craft a magical circle!  This will cut all capacity costs by 25% while you are present on it.  You can only make one, so choose wisely where to put it!"
				src.AddSkill(new/obj/Skills/Utility/Create_Magic_Circle)
		if("Spell Focii")
			ToolEnchantmentUnlocked++
		if("Magical Communication")
			ToolEnchantmentUnlocked++
		if("Magical Vehicles")
			ToolEnchantmentUnlocked++
		if("Warding Glyphs")
			ToolEnchantmentUnlocked++
		// END TOOL SHIT //
		// ENHANCEMENT SHIT //
		if("ArmamentEnchantment")
			ArmamentEnchantmentUnlocked=1
			if(!locate(/obj/Skills/Utility/Upgrade_Equipment, src))
				src << "You learn the Upgrade Equipment skill, which can enchant swords and staves!"
				src.AddSkill(new/obj/Skills/Utility/Upgrade_Equipment)
			src<< "You learn how to enchant weapons with fire, water, wind or earth elements and reinforce their basic functions!"
		if("Coating Enchantment")
			ArmamentEnchantmentUnlocked=2
			src << "You learn how to coat weapons with poison or pure silver!"
		if("Door to Darkness")
			ArmamentEnchantmentUnlocked=3
			src << "You learn how to enchant weapons with pacifying light or enraging darkness and ascend the weapons into unique status!"
		if("Magical Forging")
			ArmamentEnchantmentUnlocked=4
			src << "You learn how to magnify the traits of a weapon class with magic!"
		if("Soul Infusion")
			ArmamentEnchantmentUnlocked=5
			src << "You learn how to enchant weapons with the forces of chaos and make them rival arms of legend!"
		// END ENHANCEMENT SHIT //
		// TOME START //
		if("TomeCreation")
			TomeCreationUnlocked=1
		if("Tome Cleansing")
			TomeCreationUnlocked++
		if("Tome Expansion")
			TomeCreationUnlocked++
		if("Tome Excerpts")
			TomeCreationUnlocked++
		if("Tome Translation")
			TomeCreationUnlocked+=2
		// END TOME //
		// CREST START //
		if("CrestCreation")
			CrestCreationUnlocked=1
			if(!locate(/obj/Skills/Utility/Create_Magic_Crest, src))
				src.AddSkill(new/obj/Skills/Utility/Create_Magic_Crest)
				src << "You learn how to shape your very own Magic Crest!"
		if("Crest Expert")
			CrestCreationUnlocked=2
		if("Crest Master")
			CrestCreationUnlocked=3
		if("Crest Grandmaster")
			CrestCreationUnlocked=4
		if("Crest Legend")
			CrestCreationUnlocked++

		if("Summon Magic")
			SummoningMagicUnlocked++
			if(!locate(/obj/Skills/Utility/Summon_Entity, src))
				src.AddSkill(new/obj/Skills/Utility/Summon_Entity)
				src << "You learn to summon an entity from a realm far away."
			if(SummoningMagicUnlocked>5)
				SummoningMagicUnlocked=5

		if("Object Sealing")
			SealingMagicUnlocked++
			if(!locate(/obj/Skills/Utility/Seal_Object, src))
				src.AddSkill(new/obj/Skills/Utility/Seal_Object)
				src << "You learn to seal an object to protect it!"
			if(!locate(/obj/Skills/Utility/Seal_Break, src))
				src.AddSkill(new/obj/Skills/Utility/Seal_Break)
				src << "You learn how to attempt dismantling any existing seal!"

		if("SealingMagic")
			SealingMagicUnlocked=2

		if("Spell Sealing")
			SealingMagicUnlocked++



		if("SpaceMagic")
			SpaceMagicUnlocked=1
		if("Counterspell")
			SpaceMagicUnlocked++
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Counterspell, src))
				src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Counterspell)
				src << "You learn how to counter spells!"

		if("Holding Magic")
			SpaceMagicUnlocked++
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Hold_Person, src))
				src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Hold_Person)

		if("Teleportation")
			SpaceMagicUnlocked++
			if(!locate(/obj/Skills/Blink, src))
				src.AddSkill(new/obj/Skills/Blink)
				src << "You learn how to instantly displace yourself through space!"
		if("Retrieval")
			SpaceMagicUnlocked++

		if("Bilocation")
			SpaceMagicUnlocked++

		if("TimeMagic")
			TimeMagicUnlocked=1
		if("Transmigration")
			TimeMagicUnlocked++
		if("Life Warranty")
			TimeMagicUnlocked++
			//TODO ADD THEM BEING ABLE TO ROLL ANOTHER ROLL ON VOID
			// lol
		if("Temporal Displacement")
			TimeMagicUnlocked++
			//TODO ADD THEM BEING ABLE TO GET EXTRA CHANCE ON VOID
		if("Temporal Acceleration")
			TimeMagicUnlocked++
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Haste, src))
				src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Haste)
		if("Temporal Rewinding")
			TimeMagicUnlocked++
			if(!locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Reverse_Wounds, src))
				src.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Magic/Reverse_Wounds)

		// TECH SHIT //
		if("CyberEngineering")
			CyberEngineeringUnlocked=1
		if("Engineering")
			EngineeringUnlocked=1
			ForgingUnlocked++
		if("MilitaryTechnology")
			MilitaryTechnologyUnlocked=1
		if("AdvancedTransmissionTechnology")
			AdvancedTransmissionTechnologyUnlocked=1
		if("Telecommunications")
			TelecommunicationsUnlocked=1
		if("Medicine")
			MedicineUnlocked=1
		if("ImprovedMedicalTechnology")
			ImprovedMedicalTechnologyUnlocked=1
			if(!locate(/obj/Skills/Utility/Surgery, src))
				src.AddSkill(new/obj/Skills/Utility/Surgery)
				src << "You learn how to treat crippling long-term injuries!"
		if("Repair")
			RepairAndConversionUnlocked=1
			if(!locate(/obj/Skills/Utility/Reforge, src))
				src.AddSkill(new/obj/Skills/Utility/Reforge)
				src << "You learn how to reforge weapons, armor, and staves!"
		if("MilitaryEngineering")
			MilitaryEngineeringUnlocked=1
			ForgingUnlocked++
		if("Forge")
			ForgingUnlocked++
		if("Enhancement")
			if(!locate(/obj/Skills/Utility/Upgrade_Equipment, src))
				src.AddSkill(new/obj/Skills/Utility/Upgrade_Equipment)
				src << "You learn the Upgrade Equipment skill, enhance Weapons and Armor!"
				ForgingUnlocked++
		if("Locksmithing")
			if(!locate(/obj/Skills/Utility/Copy_Key, src))
				src.AddSkill(new/obj/Skills/Utility/Copy_Key)
				src << "You learn how to make identical copies of keys!"
		if("Smelting")
			if(!locate(/obj/Skills/Utility/Smelt, src))
				src.AddSkill(new/obj/Skills/Utility/Smelt)
				src << "You learn how to smelt tech items down for a return of 50% of their cost!"
		if("Cyber Augmentations")
			src.AddSkill(new/obj/Skills/Utility/Cybernetic_Augmentation)
			src << "You learn how to operate with cybernetics!"
		if("Revival Protocol")
			if(!locate(/obj/Skills/Utility/Revival_Protocol, src))
				src.AddSkill(new/obj/Skills/Utility/Revival_Protocol)
				src << "You learn how to attempt to save people from the threshold of death!"
		if("Espionage Equipment")
			if(!locate(/obj/Skills/Utility/Espionage_Scan, src))
				src.AddSkill(new/obj/Skills/Utility/Espionage_Scan)
				src << "You can right click a nearby person to scan them for espionage equipment!"

/knowledgePaths/proc/meetsReqs(list/acquired)
	for(var/req in requires)
		if(req in acquired)
			continue
		else
			return 0
	return 1


/mob/proc/RemoveTech(knowledgePaths/t, ty)
	if(istext(t))
		t = global.vars["[ty]Tree"][t]

	src << " You have removed the knowledge of <b><u>[t.name]</u></b>!"

	removeUnlockedTech(t.name, ty)
	switch(t.name)
		if("Alchemy")
			AlchemyUnlocked=1
			PotionTypes.Remove("Wild Herb")
		if("Healing Herbs")
			PotionTypes.Remove("Healing Herb")
		if("Magic Herbs")
			PotionTypes.Remove("Magic Herb")
		if("Toxic Herbs")
			PotionTypes.Remove("Toxic Herb")
		if("Hallucinogen Herbs")
			PotionTypes.Remove("Hallucinogen Herb")
		if("Philter Herbs")
			PotionTypes.Remove("Philter Herb")
		if("Stimulant Herbs")
			PotionTypes.Remove("Stimulant Herb")
		if("Relaxant Herbs")
			PotionTypes.Remove("Relaxant Herb")
		if("Numbing Herbs")
			PotionTypes.Remove("Numbing Herb")
		if("Mutagenic Herbs")
			PotionTypes.Remove("Mutagenic Herb")
		if("Refreshment Herbs")
			PotionTypes.Remove("Refreshment Herb")

		if("ImprovedAlchemy")
			ImprovedAlchemyUnlocked--
			PotionTypes.Remove("Wild Herb")
			if(locate(/obj/Skills/Utility/Transmute, src))
				for(var/obj/Skills/Utility/Transmute/tt in src)
					del tt
		// END ALCHEMY //
		// TOOL SHIT //
		if("ToolEnchantment")
			ToolEnchantmentUnlocked--
			if(locate(/obj/Skills/Utility/Create_Magic_Circle, src))
				for(var/obj/Skills/Utility/Create_Magic_Circle/mc in src)
					del mc
		if("Spell Focii")
			ToolEnchantmentUnlocked--
		if("Magical Communication")
			ToolEnchantmentUnlocked--
		if("Magical Vehicles")
			ToolEnchantmentUnlocked--
		if("Warding Glyphs")
			ToolEnchantmentUnlocked--
		// END TOOL SHIT //
		// ENHANCEMENT SHIT //
		if("ArmamentEnchantment")
			ArmamentEnchantmentUnlocked--
			if(locate(/obj/Skills/Utility/Upgrade_Equipment, src))
				for(var/obj/Skills/Utility/Upgrade_Equipment/ue in src)
					del ue
		if("Coating Enchantment")
			ArmamentEnchantmentUnlocked--
		if("Door to Darkness")
			ArmamentEnchantmentUnlocked--
		if("Magical Forging")
			ArmamentEnchantmentUnlocked--
		if("Soul Infusion")
			ArmamentEnchantmentUnlocked--
		// END ENHANCEMENT SHIT //
		// TOME START //
		if("TomeCreation")
			TomeCreationUnlocked--
		if("Tome Cleansing")
			TomeCreationUnlocked--
		if("Tome Expansion")
			TomeCreationUnlocked--
		if("Tome Excerpts")
			TomeCreationUnlocked--
		if("Tome Translation")
			TomeCreationUnlocked-=2
		// END TOME //
		// CREST START //
		if("CrestCreation")
			CrestCreationUnlocked=0
			if(locate(/obj/Skills/Utility/Create_Magic_Crest, src))
				for(var/obj/Skills/Utility/Create_Magic_Crest/cmc in src)
					del cmc
		if("Crest Expert")
			CrestCreationUnlocked--
		if("Crest Master")
			CrestCreationUnlocked--
		if("Crest Grandmaster")
			CrestCreationUnlocked--
		if("Crest Legend")
			CrestCreationUnlocked--

		if("Summon Magic")
			SummoningMagicUnlocked--
			if(locate(/obj/Skills/Utility/Summon_Entity, src))
				for(var/obj/Skills/Utility/Summon_Entity/se in src)
					del se
			if(SummoningMagicUnlocked<0)
				SummoningMagicUnlocked=0

		if("Object Sealing")
			SealingMagicUnlocked--
			if(locate(/obj/Skills/Utility/Seal_Object, src))
				for(var/obj/Skills/Utility/Seal_Object/so in src)
					del so
			if(locate(/obj/Skills/Utility/Seal_Break, src))
				for(var/obj/Skills/Utility/Seal_Break/sb in src)
					del sb

		if("SealingMagic")
			SealingMagicUnlocked--

		if("Spell Sealing")
			SealingMagicUnlocked--



		if("SpaceMagic")
			SpaceMagicUnlocked--
		if("Counterspell")
			SpaceMagicUnlocked--

		if("Holding Magic")
			SpaceMagicUnlocked--
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Hold_Person, src))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Magic/Hold_Person/hp in src)
					del hp

		if("Teleportation")
			SpaceMagicUnlocked--
			if(locate(/obj/Skills/Blink, src))
				for(var/obj/Skills/Blink/b in src)
					del b
		if("Retrieval")
			SpaceMagicUnlocked--

		if("Bilocation")
			SpaceMagicUnlocked--

		if("TimeMagic")
			TimeMagicUnlocked--
		if("Transmigration")
			TimeMagicUnlocked--
		if("Life Warranty")
			TimeMagicUnlocked--

		if("Temporal Displacement")
			TimeMagicUnlocked--

		if("Temporal Acceleration")
			TimeMagicUnlocked--
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Haste, src))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Magic/Haste/h in src)
					del h

		if("Temporal Rewinding")
			TimeMagicUnlocked++
			if(locate(/obj/Skills/Buffs/SlotlessBuffs/Magic/Reverse_Wounds, src))
				for(var/obj/Skills/Buffs/SlotlessBuffs/Magic/Reverse_Wounds/rw in src)
					del rw


		// TECH SHIT //
		if("CyberEngineering")
			CyberEngineeringUnlocked--
		if("Engineering")
			EngineeringUnlocked--
			ForgingUnlocked--
		if("MilitaryTechnology")
			MilitaryTechnologyUnlocked--
		if("AdvancedTransmissionTechnology")
			AdvancedTransmissionTechnologyUnlocked--
		if("Telecommunications")
			TelecommunicationsUnlocked--
		if("Medicine")
			MedicineUnlocked--
		if("ImprovedMedicalTechnology")
			ImprovedMedicalTechnologyUnlocked--
			if(locate(/obj/Skills/Utility/Surgery, src))
				for(var/obj/Skills/Utility/Surgery/s in src)
					del s
		if("Repair")
			RepairAndConversionUnlocked--
			if(locate(/obj/Skills/Utility/Reforge, src))
				for(var/obj/Skills/Utility/Reforge/r in src)
					del r
		if("MilitaryEngineering")
			MilitaryEngineeringUnlocked--
			ForgingUnlocked--
		if("Forge")
			ForgingUnlocked--
		if("Enhancement")
			if(locate(/obj/Skills/Utility/Upgrade_Equipment, src))
				for(var/obj/Skills/Utility/Upgrade_Equipment/ue in src)
					del ue

				ForgingUnlocked--
		if("Locksmithing")
			if(locate(/obj/Skills/Utility/Copy_Key, src))
				for(var/obj/Skills/Utility/Copy_Key/ck in src)
					del ck
		if("Smelting")
			if(locate(/obj/Skills/Utility/Smelt, src))
				for(var/obj/Skills/Utility/Smelt/sm in src)
					del sm
		if("Cyber Augmentations")
			for(var/obj/Skills/Utility/Cybernetic_Augmentation/ca in src)
				del ca

		if("Revival Protocol")
			if(locate(/obj/Skills/Utility/Revival_Protocol, src))
				for(var/obj/Skills/Utility/Revival_Protocol/rp in src)
					del rp
		if("Espionage Equipment")
			if(locate(/obj/Skills/Utility/Espionage_Scan, src))
				for(var/obj/Skills/Utility/Espionage_Scan/sc in src)
					del sc
