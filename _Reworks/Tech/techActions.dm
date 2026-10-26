/mob/proc/TechIntFactor()
	var/intf = Intelligence
	if(passive_handler["Spiritual Tactician"])
		if(Imagination > Intelligence)
			intf = Imagination
	if(intf < 0.5)
		intf = 0.5
	return intf

/mob/proc/TechNodeCost(knowledgePaths/tech/t)
	if(!t) return 0
	var/theCost = TechTierPrice(t.tier) * clamp(1 - 0.15 * (TechIntFactor() - 1), 0.1, 1)
	return max(1, round(theCost, 1))

/mob/proc/TechNodeRankNeeded(knowledgePaths/tech/t)
	if(!t) return 1
	return TechTierRank(t.tier)

/mob/proc/CanAffordTechNode(knowledgePaths/tech/t)
	return GetRPPSpendable() >= TechNodeCost(t)

/mob/proc/BuyTechNode(knowledgePaths/tech/t)
	if(!t) return 0
	if(t.name in knowledgeTracker.learnedKnowledge)
		src << "You've already learned [t.name]."
		return 0
	if(!t.meetsReqs(knowledgeTracker.learnedKnowledge))
		src << "You do not meet the requirements to learn [t.name] ([t.ReqLine()])!"
		return 0
	var/need = TechNodeRankNeeded(t)
	if(LifeRank("Technology") < need)
		src << "[t.name] needs Technology rank [need]."
		return 0
	var/theCost = TechNodeCost(t)
	if(!SpendRPP(theCost, "[t.name]"))
		return 0
	UnlockTech(t, "Technology")
	return 1

/mob/proc/ScouterIconPrompt(obj/Items/Tech/Scouter/S)
	if(!S) return
	if(S.ScouterIcon == 1) return
	S.ScouterIcon = 1
	var/Choice = Ask(src, "What icon would you like for the scouter?", "", null, "pick", list("Green", "Blue", "Red", "Purple"), 0)
	switch(Choice)
		if("Green") S.icon = 'GreenScouter.dmi'
		if("Blue")  S.icon = 'BlueScouter.dmi'
		if("Red")   S.icon = 'RedScouter.dmi'
		if("Purple") S.icon = 'PurpleScouter.dmi'

var/list/TECH_BENCH_ORDER = list("Engineer", "Operative", "Gunsmith", "Mechanist", "Cyberneticist", "Medic")
var/list/TECH_SUBTYPE_ALLOWED = list("Any", "Blasphemy", "Rebellion", "Locksmithing", "Modular Weaponry", "Advanced Plating", "NOT IN")

/mob/proc/TechTreeAuditLines()
	if(length(TechnologyTree) < 1)
		fillOutTechTree()
	var/list/out = list()
	var/list/names = list()
	var/list/benchrpp = list()
	for(var/b in TECH_BENCH_ORDER)
		benchrpp[b] = 0
	var/count = 0
	var/total = 0
	for(var/n in TechnologyTree)
		var/knowledgePaths/tech/t = TechnologyTree[n]
		if(!t || t.name == "Not Obtainable") continue
		names += t.name
		count++
		var/price = TechTierPrice(t.tier)
		total += price
		if(t.bench in benchrpp)
			benchrpp[t.bench] += price
	var/list/benchline = list()
	for(var/b in TECH_BENCH_ORDER)
		benchline += "[b] [benchrpp[b]]"
	out += "Technology tree audit"
	out += "Nodes: [count] (target 54)"
	out += "RPP at Int 1: [total] (target 345) - [jointext(benchline, ", ")]"
	var/list/badreq = list()
	var/list/badlayout = list()
	var/list/badsub = list()
	for(var/n in TechnologyTree)
		var/knowledgePaths/tech/t = TechnologyTree[n]
		if(!t || t.name == "Not Obtainable") continue
		for(var/req in t.requires)
			if(!(req in names)) badreq += "[t.name] requires [req]"
		for(var/req in t.requires_any)
			if(!(req in names)) badreq += "[t.name] requires any of [req]"
		if(!TechTreeLayout[t.name]) badlayout += "[t.name] has no layout entry"
	for(var/ln in TechTreeLayout)
		if(!(ln in names)) badlayout += "layout row [ln] has no node"
	for(var/obj/Items/it in Technology_List)
		if(!istype(it, /obj/Items/Tech) && !istype(it, /obj/Items/Gear)) continue
		if(isnull(it.SubType)) continue
		if(it.SubType in TECH_SUBTYPE_ALLOWED) continue
		if(it.SubType in names) continue
		badsub += "[it.name] ([it.type]) SubType \"[it.SubType]\""
	out += "Dangling prerequisites ([badreq.len]): [badreq.len ? jointext(badreq, "; ") : "none"]"
	out += "Layout mismatches ([badlayout.len]): [badlayout.len ? jointext(badlayout, "; ") : "none"]"
	out += "Dangling SubType strings ([badsub.len]): [badsub.len ? jointext(badsub, "; ") : "none"]"
	return out

/mob/Admin4/verb/techTreeAudit()
	set category = "Admin"
	set name = "Technology Tree Audit"
	for(var/line in TechTreeAuditLines())
		src << line
