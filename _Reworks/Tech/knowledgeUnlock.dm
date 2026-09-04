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
		if("MilitaryEngineering")
			MilitaryEngineeringUnlocked=0
		if("Cyber Augmentations")
			for(var/obj/Skills/Utility/Cybernetic_Augmentation/ca in src)
				del ca
/*		if("Revival Protocol")
			for(var/obj/Skills/Utility/Revival_Protocol/rp in src)
				del rp*/
		if("Espionage Equipment")
			for(var/obj/Skills/Utility/Espionage_Scan/es in src)
				del es
		if("Culinary Basics")
			for(var/obj/Skills/Utility/Cooking/cock in src)
				del cock
		if("Piloting Foundations")
			PilotingProwess=0

/mob/verb/learnTech()
	set category = "Utility"
	set hidden = 1
	set name = "Technology"
	// Now opens the node-based Tech menu
	if(length(TechnologyTree) < 1)
		fillOutTechTree()
	if(client)
		client.OpenTechMenu("tree")
	return
	var/int = Intelligence
	if(passive_handler["Spiritual Tactician"])
		if(Imagination > Intelligence)
			int = Imagination
	if(int < 0.5)
		int = 0.5
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
		// TECH SHIT //
		if("CyberEngineering")
			CyberEngineeringUnlocked=1
		if("Engineering")
			EngineeringUnlocked=1
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
		if("MilitaryEngineering")
			MilitaryEngineeringUnlocked=1
		// Repair/Forge/Enhancement/Locksmithing/Smelting grants live in Smithing ranks now
		if("Cyber Augmentations")
			src.AddSkill(new/obj/Skills/Utility/Cybernetic_Augmentation)
			src << "You learn how to operate with cybernetics!"
	/*	if("Revival Protocol")
			if(!locate(/obj/Skills/Utility/Revival_Protocol, src))
				src.AddSkill(new/obj/Skills/Utility/Revival_Protocol)
				src << "You learn how to attempt to save people from the threshold of death!"*/
		if("Espionage Equipment")
			if(!locate(/obj/Skills/Utility/Espionage_Scan, src))
				src.AddSkill(new/obj/Skills/Utility/Espionage_Scan)
				src << "You can right click a nearby person to scan them for espionage equipment!"
		if("Culinary Basics")
			if(!locate(/obj/Skills/Utility/Cooking, src))
				src.AddSkill(new/obj/Skills/Utility/Cooking);
				src << "You have learned the basics of <u>Cooking</u>!"
		if("Piloting Foundations")
			PilotingProwess++
			if(PilotingProwess>7)
				PilotingProwess=7


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
		// TECH SHIT //
		if("CyberEngineering")
			CyberEngineeringUnlocked--
		if("Engineering")
			EngineeringUnlocked--
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
		if("MilitaryEngineering")
			MilitaryEngineeringUnlocked--
		if("Cyber Augmentations")
			for(var/obj/Skills/Utility/Cybernetic_Augmentation/ca in src)
				del ca

	/*	if("Revival Protocol")
			if(locate(/obj/Skills/Utility/Revival_Protocol, src))
				for(var/obj/Skills/Utility/Revival_Protocol/rp in src)
					del rp*/
		if("Espionage Equipment")
			if(locate(/obj/Skills/Utility/Espionage_Scan, src))
				for(var/obj/Skills/Utility/Espionage_Scan/sc in src)
					del sc
		if("Culinary Basics")
			if(locate(/obj/Skills/Utility/Cooking, src))
				for(var/obj/Skills/Utility/Cooking/cock in src)
					del cock
		if("Piloting Foundations")
			PilotingProwess--
			if(PilotingProwess < 0)
				PilotingProwess=0
