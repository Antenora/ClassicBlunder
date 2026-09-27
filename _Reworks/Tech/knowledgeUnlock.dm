//#define subtypesof(typepath) ( typesof(typepath) - typepath )

var/knowledgePaths/tech/list/TechnologyTree = list()

/proc/fillOutTechTree()
	. = typesof(/knowledgePaths/tech)
	for(var/x in .)
		var/knowledgePaths/tech/node = new x
		TechnologyTree[node.name] += node
	for(var/n in TechnologyTree)
		var/knowledgePaths/tech/parent = TechnologyTree[n]
		var/list/leads = list()
		for(var/m in TechnologyTree)
			if(m == n) continue
			var/knowledgePaths/tech/child = TechnologyTree[m]
			if((n in child.requires) || (n in child.requires_any))
				leads += m
		parent.unlocks = leads.len ? jointext(leads, ", ") : null


/mob/proc/removeTechKnowledge(mob/p, path, cost, prompt)
	var/knowledgePaths/tech/t = TechnologyTree[path]
	if(!t) return
	var/theCost = p.TechNodeCost(t)
	var/confirmation = "Yes"
	if(prompt)
		confirmation = Ask(p, "Are you sure you want to refund [t.name] for [theCost] points?", "", null, "pick", list("Yes", "No"), 0)
	if(confirmation == "Yes")
		p.RPPSpendable += theCost
		p.RPPSpent -= theCost
		p.knowledgeTracker.learnedKnowledge -= t.name
		p << "You have refunded [t.name] for [theCost]!"
	switch(path)
		if("Cyber Engineering")
			p.CyberEngineeringUnlocked=0
		if("Engineering")
			p.EngineeringUnlocked=0
		if("Military Technology")
			p.MilitaryTechnologyUnlocked=0
		if("Telecommunications")
			p.TelecommunicationsUnlocked=0
		if("Scouters")
			p.AdvancedTransmissionTechnologyUnlocked=0
		if("Medicine")
			p.MedicineUnlocked=0
		if("Improved Medical Technology")
			p.ImprovedMedicalTechnologyUnlocked=0
			for(var/obj/Skills/Utility/Surgery/s in p)
				del s
		if("Military Engineering")
			p.MilitaryEngineeringUnlocked=0
		if("Cyber Augmentations")
			for(var/obj/Skills/Utility/Cybernetic_Augmentation/ca in p)
				del ca
/*		if("Revival Protocol")
			for(var/obj/Skills/Utility/Revival_Protocol/rp in src)
				del rp*/
		if("Espionage Equipment")
			for(var/obj/Skills/Utility/Espionage_Scan/es in p)
				del es
		if("Piloting Foundations")
			p.PilotingProwess=0

/mob/verb/learnTech()
	set category = "Utility"
	set hidden = 1
	set name = "Technology"
	// Now opens the node-based Tech menu
	if(length(TechnologyTree) < 1)
		fillOutTechTree()
	if(client)
		client.OpenTechMenu("tree")

/mob/proc/UnlockTech(knowledgePaths/t, type)
	src << " You have unlocked the knowledge of <b><u>[t.name]</u></b>!"
	addUnlockedTech(t.name, type)
	switch(t.name)
		// TECH SHIT //
		if("Cyber Engineering")
			CyberEngineeringUnlocked=1
		if("Engineering")
			EngineeringUnlocked=1
		if("Military Technology")
			MilitaryTechnologyUnlocked=1
		if("Telecommunications")
			TelecommunicationsUnlocked=1
		if("Scouters")
			AdvancedTransmissionTechnologyUnlocked=1
		if("Medicine")
			MedicineUnlocked=1
		if("Improved Medical Technology")
			ImprovedMedicalTechnologyUnlocked=1
			if(!locate(/obj/Skills/Utility/Surgery, src))
				src.AddSkill(new/obj/Skills/Utility/Surgery)
				src << "You learn how to treat crippling long-term injuries!"
		if("Military Engineering")
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
	if(requires_any && requires_any.len)
		for(var/req in requires_any)
			if(req in acquired)
				return 1
		return 0
	return 1

/knowledgePaths/proc/ReqLine()
	var/list/parts = list()
	if(requires && requires.len)
		parts += jointext(requires, ", ")
	if(requires_any && requires_any.len)
		var/anyline = jointext(requires_any, " or ")
		parts += anyline
	if(!parts.len) return "nothing"
	return jointext(parts, ", plus ")


/mob/proc/RemoveTech(knowledgePaths/t, ty)
	if(istext(t))
		t = global.vars["[ty]Tree"][t]

	src << " You have removed the knowledge of <b><u>[t.name]</u></b>!"

	removeUnlockedTech(t.name, ty)
	switch(t.name)
		// TECH SHIT //
		if("Cyber Engineering")
			CyberEngineeringUnlocked--
		if("Engineering")
			EngineeringUnlocked--
		if("Military Technology")
			MilitaryTechnologyUnlocked--
		if("Telecommunications")
			TelecommunicationsUnlocked--
		if("Scouters")
			AdvancedTransmissionTechnologyUnlocked=0
		if("Medicine")
			MedicineUnlocked--
		if("Improved Medical Technology")
			ImprovedMedicalTechnologyUnlocked--
			if(locate(/obj/Skills/Utility/Surgery, src))
				for(var/obj/Skills/Utility/Surgery/s in src)
					del s
		if("Military Engineering")
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
		if("Piloting Foundations")
			PilotingProwess--
			if(PilotingProwess < 0)
				PilotingProwess=0
