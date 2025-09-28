var/knowledgePaths/magic/list/MagicTree = list()

/proc/fillMagicTree()
	. = typesof(/knowledgePaths/magic)
	for(var/x in .)
		var/knowledgePaths/magic/m = new x
		MagicTree[m.name] += m


/mob/proc/learnKnowledge(pathType, knowledgeList)
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
			if(length(MagicTree) < 1)
				fillMagicTree()
		if("Technology")
			theCost = glob.TECH_BASE_COST / int
			if(glob.MAGIC_INTELL_MATTERS && passive_handler["Spiritual Tactician"])
				theCost /= imag
			if(theCost < 1)
				theCost = 1
			if(length(TechnologyTree) < 1)
				fillOutTechTree()
	for(var/n in global.vars["[pathType]Tree"])
		var/knowledgePaths/knowledge = global.vars["[pathType]Tree"][n]
		if(n in knowledgeList)
			if(n == "Summon Magic")
				if(SummoningMagicUnlocked<5)
					buyList += knowledge
			if(n == "Crest Legend")
				if(CrestCreationUnlocked<7)
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
		var/knowledgePaths/knowledge = global.vars["[pathType]Tree"]["[input]"]
		
		if(knowledge.meetsReqs(knowledgeList))
			theCost *= 1 + (0.25 * length(knowledge.requires))
			if(knowledge.breakthrough)
				theCost /= 4
			theCost = round(theCost, 1)
			var/confirm = input(src, "Are you sure you want to learn [knowledge.name]? It will cost [theCost] rp points.") in list("Yes" , "No")
			if(confirm == "Yes")
				if(SpendRPP(theCost, "[knowledge.name]"))
					UnlockTech(knowledge, pathType)
		


/mob/verb/learnMagic()
	set category = "Utility"
	set name = "Magic Learning"
	learnKnowledge("Magic", knowledgeTracker.learnedMagic)





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
	RemoveTech(tech, "Magic")

mob/Admin3/verb/RefundMagic(mob/p in players)
	set name = "Refund Magic"
	if(length(MagicTree) < 1)
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
	if(length(MagicTree) < 1)
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



/mob/proc/legacyRefundmagic()
	if(length(MagicTree) < 1)
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
