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
	var/theCost = glob.TECH_BASE_COST / TechIntFactor()
	theCost *= 1 + (0.25 * length(t.requires))
	if(t.breakthrough)
		theCost /= 4
	return round(theCost, 1)

/mob/proc/CanAffordTechNode(knowledgePaths/tech/t)
	return GetRPPSpendable() >= TechNodeCost(t)

/mob/proc/BuyTechNode(knowledgePaths/tech/t)
	if(!t) return 0
	if(t.name in knowledgeTracker.learnedKnowledge)
		src << "You've already learned [t.name]."
		return 0
	if(!t.meetsReqs(knowledgeTracker.learnedKnowledge))
		src << "You do not meet the requirements to learn [t.name] ([jointext(t.requires, " , ")])!"
		return 0
	var/theCost = TechNodeCost(t)
	if(!SpendRPP(theCost, "[t.name]"))
		return 0
	UnlockTech(t, "Technology")
	return 1

/mob/proc/CraftTechItem(obj/Items/catalog)
	if(!catalog) return 0
	if(KO)
		src << "You cannot create items while KO'd."
		return 0
	var/datum/craft_recipe/r = GetTechRecipe(catalog)

	if(istype(catalog, /obj/Items/Tech/Power_Pack))
		var/qty = input(src, "How many packs would you like to make?", "Power Packs") as num|null
		if(isnull(qty) || qty <= 0) return 0
		var/unit = r.MoneyCost(src, catalog)
		var/total = unit * qty
		var/have = 0
		for(var/obj/Money/mo in src) have += mo.Level
		if(have < total)
			src << "You don't have enough money! You need [Commas(total)] resources to make [qty] [catalog]."
			return 0
		TakeMoney(total)
		UpdateTechnologyWindow()
		var/obj/Items/Tech/Power_Pack/P = new catalog.type(loc)
		r.Finish(P, null)
		P.TotalStack = qty
		P.suffix = "[qty]"
		src << "You made [qty] [catalog]."
		return 1

	if(!r.CanCraft(src, catalog, null))
		src << "You don't have enough to make [catalog]."
		return 0
	r.Consume(src, catalog, null)
	UpdateTechnologyWindow()

	var/obj/Items/made = new catalog.type
	r.Finish(made, null)

	if(made.Stackable)
		for(var/obj/Items/o in src)
			if(o.type == made.type && o.CraftQuality == made.CraftQuality && o.TotalStack < INV_STACK_MAX)
				o.TotalStack++
				o.suffix = "[o.TotalStack]"
				src << "You stack a new [made]."
				del made
				break

	if(made)
		if(made.Grabbable)
			if(!CanPickupItem(made))
				del made
				return 0
			made.loc = src
		else
			made.loc = loc
		made.CreatorKey = ckey
		made.CreatorSignature = EnergySignature
		src << "You made \an [made]!"
		if(istype(made, /obj/Items/Tech/Scouter))
			ScouterIconPrompt(made)
	return 1

/mob/proc/ScouterIconPrompt(obj/Items/Tech/Scouter/S)
	if(!S) return
	if(S.ScouterIcon == 1) return
	S.ScouterIcon = 1
	var/Choice = input(src, "What icon would you like for the scouter?") in list("Green", "Blue", "Red", "Purple")
	switch(Choice)
		if("Green") S.icon = 'GreenScouter.dmi'
		if("Blue")  S.icon = 'BlueScouter.dmi'
		if("Red")   S.icon = 'RedScouter.dmi'
		if("Purple") S.icon = 'PurpleScouter.dmi'
