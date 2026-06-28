var/knowledgePaths/magic/list/MagicTree = list() // Not touching this for my own sanity - Hadoje
var/list/AlchemyTree = list()
var/list/EnchantingTree = list()
var/list/MiscTree = list()

/proc/fillMagicTree() // Split into 3 trees, Alchemy, Enchant/Tools, and Misc. 
	var/list/Alchemytypes = subtypesof(/knowledgePaths/magic/alchemy)
	var/list/Enchanttypes = subtypesof(/knowledgePaths/magic/enchanting)
	var/list/Misctypes = subtypesof(/knowledgePaths/magic/misc)
	for(var/MagicType in Alchemytypes)
		var/knowledgePaths/magic/m = new MagicType
		AlchemyTree[m.name] = m

	for(var/MagicType in Enchanttypes)
		var/knowledgePaths/magic/m = new MagicType
		EnchantingTree[m.name] = m

	for(var/MagicType in Misctypes)
		var/knowledgePaths/magic/m = new MagicType
		MiscTree[m.name] = m


/proc/IsMagicTreeBuilt()
	if(length(AlchemyTree) < 1) return 0
	if(length(EnchantingTree) < 1) return 0
	if(length(MiscTree) < 1) return 0
	return 1


/mob/proc/learnKnowledge(pathType, knowledgeList, SubType=0)
	var/theCost
	var/list/buyList = list()
	var/int = Intelligence
	var/imag = Imagination
	if(passive_handler["Spiritual Tactician"])
		imag = Imagination * (glob.racials.SPIRITTACTMULT)
		int = imag
	switch(pathType)
		if("Magic")
			if(Imagination == 0)
				src<< "You do not have a soul. You can't learn magic."
				return
			theCost = glob.MAGIC_BASE_COST
			if(glob.MAGIC_INTELL_MATTERS)
				if(passive_handler["Spiritual Tactician"])
					if(Imagination > Intelligence)
						int = Imagination
				if(int < 0.5)
					int = 0.5
				theCost /= int // can only increase it by half, so majins dont cry
			if(passive_handler["Spiritual Tactician"])
				if(Imagination < Intelligence)
					imag = Intelligence
			theCost /= imag
			if(theCost < 1)
				theCost = 1
	if(!IsMagicTreeBuilt())
		fillMagicTree()
	var/list/knows = SubType ? global.vars["[SubType]Tree"] : global.vars["[pathType]Tree"];
	for(var/n in knows)
		var/knowledgePaths/knowledge = knows[n]
		if(n in knowledgeList)
			if(n == "General Magic Knowledge")
				if(GeneralMagicKnowledgeUnlocked<5)
					buyList += knowledge
			if(n == "Crest Legend")
				buyList += knowledge//It's infinite now, OMNI
			if(n == "Piloting Foundations")
				if(PilotingProwess<7)
					buyList += knowledge
			continue
		if(length(knowledge.requires) > 0)
			if(knowledge.meetsReqs(knowledgeList))
				buyList += knowledge
			else
				continue
		else
			buyList += knowledge
	var/input = input(src, "What would you like to learn") in buyList + "Cancel"
	if(input == "Cancel")
		return
	if(input in buyList)
		var/knowledgePaths/knowledge = knows["[input]"]

		if(knowledge.meetsReqs(knowledgeList))
			theCost *= 1 + (0.25 * length(knowledge.requires))
			if(knowledge.breakthrough)
				theCost /= 4
			theCost = round(theCost, 1)
			var/confirm = input(src, "Are you sure you want to learn [knowledge.name]? It will cost [theCost] rp points.\nDescription: [knowledge.description]]") in list("Yes" , "No")
			if(confirm == "Yes")
				if(SpendRPP(theCost, "[knowledge.name]"))
					UnlockTech(knowledge, pathType)



/mob/verb/learnMagic() // Change this to Thaumaturgy next wipe 
	set category = "Utility"
	set hidden = 1
	set name = "Thaumaturgy"
	var/choice = input(src, "What branch of magic do you wish to learn?", "Thaumaturgy") in list("Alchemy", "Enchanting", "Misc", "Nevermind")
	if(choice == "Nevermind") return
	
	learnKnowledge("Magic", knowledgeTracker.learnedMagic, choice)





/mob/proc/removeMagicKnowledge(mob/p, path, cost, prompt)
	if(path in TechnologyTree) return
	var/theCost = cost
	var/knowledgePaths/magic/tech = MagicTree[path]
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
		p.knowledgeTracker.learnedMagic -= tech.name
		p << "You have refunded [tech.name] for [theCost]!"
		if((tech.name in list("Basic Alchemy", "Flask Accumen", "Flask Mastery")))
			if(p.AlchemyUnlocked >= 1) // Refund AlchemyUnlocked improving techs IN ORDER. If you do not know which these are, check line 134 onward in knowledgeUnlock.dm
				p.ReduceAlchemyUnlocked()
		if((tech.name in list("Inkworks", "Advanced Inkworks", "Mastered Inkworks")))
			if(p.InkworksDatum.Tier >= 1)
				p.InkworksDatum.Tier = 0
	RemoveTech(tech, "Magic")

mob/Admin3/verb/RefundMagic(mob/p in players)
	set name = "Refund Magic"
	if(IsMagicTreeBuilt())
		fillMagicTree()
	if(!p.client)
		return
	var/choice = input(src, "What magic?") in p.generateMagicList() + "Cancel"
	if(choice != "Cancel")
		var/the_cost = glob.MAGIC_BASE_COST / p.Imagination
		if(glob.MAGIC_INTELL_MATTERS)
			the_cost /= p.Intelligence
		p.removeMagicKnowledge(p, choice, the_cost, 0)

/mob/Admin4/verb/RefundALLmagic(mob/p in world)
	if(IsMagicTreeBuilt())
		fillMagicTree()
	for(var/x in generateMagicList())
		var/the_cost = glob.MAGIC_BASE_COST / Imagination
		the_cost /= Intelligence
		removeMagicKnowledge(src, x, the_cost, 0)
		sleep(1)
	src << "magic tree mass refunded, if there are any issues gmhelp"
	AlchemyUnlocked=0
	ImprovedAlchemyUnlocked=0
	ToolEnchantmentUnlocked=0
	ArmamentEnchantmentUnlocked=0
	TomeCreationUnlocked=0
	CrestCreationUnlocked=0
	SummoningMagicUnlocked=0
	SealingMagicUnlocked=0
	SpaceMagicUnlocked=0
	TimeMagicUnlocked=0
	TotalMagicLevel=0
	GeneralMagicKnowledgeUnlocked=0


//TODO: Remove
/mob/proc/legacyRefundmagic()
	if(IsMagicTreeBuilt())
		fillMagicTree()
	for(var/x in generateMagicList())
		var/the_cost = 50 / Imagination
		the_cost /= Intelligence
		removeMagicKnowledge(src, x, the_cost, 0)
		sleep(1)
	src << "magic tree mass refunded, if there are any issues gmhelp"
	AlchemyUnlocked=0
	ImprovedAlchemyUnlocked=0
	ToolEnchantmentUnlocked=0
	ArmamentEnchantmentUnlocked=0
	TomeCreationUnlocked=0
	CrestCreationUnlocked=0
	SummoningMagicUnlocked=0
	SealingMagicUnlocked=0
	SpaceMagicUnlocked=0
	TimeMagicUnlocked=0
	TotalMagicLevel=0
