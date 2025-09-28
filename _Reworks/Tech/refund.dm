
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
		"SummoningMagicUnlocked",
		"SealingMagicUnlocked",
		"SpaceMagicUnlocked",
		"TimeMagicUnlocked")
	for(var/x in hoyl)
		vars["[x]"]=0



	for(var/p in knowledgeTracker.learnedKnowledge)
		if(p in EnchantmentKnowledge)
			var/theCost
			if(p in list("Alchemy", "Tool Enchantment", "Tome Creation", "Summoning Magic", "Space Magic"))
				theCost = 20 / Imagination
			else if(p in list("Improved Alchemy", "Armament Enchantment", "Crest Creation", "Sealing Magic", "Time Magic"))
				theCost = 40 / Imagination
			RPPSpendable += theCost
			RPPSpent -= theCost
			knowledgeTracker.learnedKnowledge -= p
			src << "You have refunded [p]!"


		else
			var/knowledgePaths/tech = TechnologyTree[p]
			var/theCost = glob.TECH_BASE_COST / Intelligence
			theCost *= 1 + (0.25 * length(tech.requires))
			RPPSpendable += theCost
			RPPSpent -= theCost
			knowledgeTracker.learnedKnowledge -= p
			src << "You have refunded [tech.name]!"


/mob/Admin3/verb/RemoveAllTech(mob/p in players)
	set name = "Refund All Technology"
	var/theCost = glob.TECH_BASE_COST / p.Intelligence
	for(var/x in p.knowledgeTracker.learnedKnowledge)
		removeTechKnowledge(p, x, theCost, FALSE)


/mob/Admin3/verb/RefundKnowledge(mob/p in players)
	set name = "Refund Technology"
	var/theCost = glob.TECH_BASE_COST / p.Intelligence
	var/thePath = input(usr,"What technology would you like to refund?") in p.knowledgeTracker.learnedKnowledge + "Cancel"
	if(thePath == "Cancel")
		return
	if(thePath in p.knowledgeTracker.learnedKnowledge)
		if(thePath in MagicList) return
		removeTechKnowledge(p, thePath, theCost, TRUE)