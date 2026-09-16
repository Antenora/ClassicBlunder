
/mob/proc/quickDirtyRefund()
	var/list/hoyl =list("ForgingUnlocked",
		"RepairAndConversionUnlocked",
		"MedicineUnlocked",
		"ImprovedMedicalTechnologyUnlocked",
		"TelecommunicationsUnlocked",
		"AdvancedTransmissionTechnologyUnlocked",
		"EngineeringUnlocked",
		"CyberEngineeringUnlocked",
		"MilitaryTechnologyUnlocked",
		"MilitaryEngineeringUnlocked",

		"AlchemyUnlocked",
		"ImprovedAlchemyUnlocked",
		"ToolEnchantmentUnlocked",
		"ArmamentEnchantmentUnlocked",
		"TomeCreationUnlocked",
		"CrestCreationUnlocked",
		"GeneralMagicKnowledgeUnlocked",
		"SealingMagicUnlocked",
		"SpaceMagicUnlocked",
		"TimeMagicUnlocked")
	for(var/x in hoyl)
		vars["[x]"]=0



	for(var/p in knowledgeTracker.learnedKnowledge)
		if(p in EnchantmentKnowledge)
			var/theCost
			if(p in list("Alchemy", "Tool Enchantment", "Tome Creation", "General Magic Knowledge", "Space Magic"))
				theCost = glob.TECH_BASE_COST / Imagination
			else if(p in list("Improved Alchemy", "Armament Enchantment", "Crest Creation", "Sealing Magic", "Time Magic"))
				theCost = glob.TECH_BASE_COST / Imagination
			RPPSpendable += theCost
			RPPSpent -= theCost
			knowledgeTracker.learnedKnowledge -= p
			src << "You have refunded [p]!"


		else
			var/knowledgePaths/tech = TechnologyTree[p]
			var/int = Intelligence
			if(passive_handler["Spiritual Tactician"])
				if(Imagination > Intelligence)
					int = Imagination
			if(int < 0.5)
				int = 0.5
			var/theCost = glob.TECH_BASE_COST / int
			theCost *= 1 + (0.25 * length(tech.requires))
			RPPSpendable += theCost
			RPPSpent -= theCost
			knowledgeTracker.learnedKnowledge -= p
			src << "You have refunded [tech.name]!"


/mob/Admin3/verb/RemoveAllTech()
	set name = "Refund All Technology"
	var/mob/p = PromptArg(usr, args, 1, "Refund All Technology", "players")
	if(isnull(p)) return
	var/int = p.Intelligence
	if(p.passive_handler["Spiritual Tactician"])
		if(p.Imagination > p.Intelligence)
			int = p.Imagination
	if(int < 0.5)
		int = 0.5
	var/theCost = glob.TECH_BASE_COST / int
	for(var/x in p.knowledgeTracker.learnedKnowledge)
		removeTechKnowledge(p, x, theCost, FALSE)


/mob/Admin3/verb/RefundKnowledge()
	set name = "Refund Technology"
	var/mob/p = PromptArg(usr, args, 1, "Refund Technology", "players")
	if(isnull(p)) return
	var/int = p.Intelligence
	if(p.passive_handler["Spiritual Tactician"])
		if(p.Imagination > p.Intelligence)
			int = p.Imagination
	if(int < 0.5)
		int = 0.5
	var/theCost = glob.TECH_BASE_COST / int
	var/thePath = Ask(usr, "What technology would you like to refund?", "", null, "pick", (p.knowledgeTracker.learnedKnowledge + "Cancel"), 0)
	if(thePath == "Cancel")
		return
	if(thePath in p.knowledgeTracker.learnedKnowledge)
		removeTechKnowledge(p, thePath, theCost, TRUE)