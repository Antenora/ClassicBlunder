proc/getNinjutsuSkills()
	return list(
		list("name"="Katon: Goukakyu no Jutsu",
		     "path"="/obj/Skills/Projectile/Ninjutsu/Goukakyu",
		     "tier"=1, "requires"=null, "nature"="Katon"),
		list("name"="Katon: Endan",
		     "path"="/obj/Skills/Projectile/Ninjutsu/Endan",
		     "tier"=1, "requires"=null, "nature"="Katon"),
		list("name"="Katon: Ryuka no Jutsu",
		     "path"="/obj/Skills/AutoHit/Ninjutsu/Ryuka",
		     "tier"=1, "requires"=null, "nature"="Katon"),
		list("name"="Katon: Housenka no Jutsu",
		     "path"="/obj/Skills/Projectile/Ninjutsu/Housenka",
		     "tier"=1, "requires"=null, "nature"="Katon"))

proc/getGenjutsuSkills()
	return list()

proc/getTaijutsuSkills()
	return list()

proc/getJutsuSkills(Category)
	switch(Category)
		if("Ninjutsu") return getNinjutsuSkills()
		if("Genjutsu") return getGenjutsuSkills()
		if("Taijutsu") return getTaijutsuSkills()
	return list()

proc/getJutsuSlotDefs()
	return list(
		list("slot"="JutsuSL1Picks", "minSL"=1, "base"=2, "tierCap"=1),
		list("slot"="JutsuSL3Picks", "minSL"=3, "base"=2, "tierCap"=2),
		list("slot"="JutsuSL5Picks", "minSL"=5, "base"=1, "tierCap"=3),
		list("slot"="JutsuSL6Picks", "minSL"=6, "base"=1, "tierCap"=4),
		list("slot"="JutsuSL7Picks", "minSL"=7, "base"=1, "tierCap"=5))

proc/getJutsuAffinityMult(mob/User)
	var/mult = 1
	if(User.ChakraAffinities && User.ChakraAffinities.len > 1)
		mult = User.ChakraAffinities.len
	if(User.ChakraSpecialization)
		mult = max(mult, 2)
	return mult

proc/getJutsuSlotSpent(mob/User, slot)
	switch(slot)
		if("JutsuSL1Picks") return User.JutsuSL1Picks
		if("JutsuSL3Picks") return User.JutsuSL3Picks
		if("JutsuSL5Picks") return User.JutsuSL5Picks
		if("JutsuSL6Picks") return User.JutsuSL6Picks
		if("JutsuSL7Picks") return User.JutsuSL7Picks
	return 0

proc/addJutsuSlotSpent(mob/User, slot)
	switch(slot)
		if("JutsuSL1Picks") User.JutsuSL1Picks++
		if("JutsuSL3Picks") User.JutsuSL3Picks++
		if("JutsuSL5Picks") User.JutsuSL5Picks++
		if("JutsuSL6Picks") User.JutsuSL6Picks++
		if("JutsuSL7Picks") User.JutsuSL7Picks++

proc/getJutsuPickSlot(mob/User)
	var/mult = getJutsuAffinityMult(User)
	for(var/list/def in getJutsuSlotDefs())
		if(User.SagaLevel < def["minSL"]) continue
		if(getJutsuSlotSpent(User, def["slot"]) < def["base"] * mult)
			return list("tierCap"=def["tierCap"], "slot"=def["slot"])
	return null

// Total unspent picks across all unlocked slots
proc/getJutsuPicksAvailable(mob/User)
	var/mult = getJutsuAffinityMult(User)
	var/total = 0
	for(var/list/def in getJutsuSlotDefs())
		if(User.SagaLevel < def["minSL"]) continue
		total += max(0, def["base"] * mult - getJutsuSlotSpent(User, def["slot"]))
	return total

proc/getJutsuPickCost(mob/User, nature)
	if(!nature) return 1
	if(User.ChakraAffinities && (nature in User.ChakraAffinities)) return 1
	return 2

proc/spendJutsuPicks(mob/User, cost)
	if(getJutsuPicksAvailable(User) < cost) return null
	var/mult = getJutsuAffinityMult(User)
	var/list/charged = list()
	for(var/list/def in getJutsuSlotDefs())
		if(charged.len >= cost) break
		if(User.SagaLevel < def["minSL"]) continue
		while(charged.len < cost && getJutsuSlotSpent(User, def["slot"]) < def["base"] * mult)
			addJutsuSlotSpent(User, def["slot"])
			charged += def["slot"]
	return charged

/obj/Skills/Buffs/SlotlessBuffs/Shinobi_Arts
	name = "Shinobi Arts"
	Slotless = 1
	var/tmp/JutsuSelecting = FALSE

	proc/LearnJutsu(mob/User, Category)
		if(User.Saga != "Shinobi")
			return

		var/list/masterList = getJutsuSkills(Category)
		if(!masterList.len)
			User << "[Category] instruction is not yet available."
			return

		if(JutsuSelecting)
			User << "You are already selecting a Jutsu."
			return
		JutsuSelecting = TRUE

		var/list/pickSlot = getJutsuPickSlot(User)
		if(!pickSlot)
			User << "You have no [Category] selections available."
			JutsuSelecting = FALSE
			return

		var/tierCap = pickSlot["tierCap"]
		var/available = getJutsuPicksAvailable(User)

		var/list/options = list()
		var/list/optionEntries = list()
		for(var/list/skill in masterList)
			if(skill["tier"] > tierCap) continue
			var/path = text2path(skill["path"])
			if(!path) continue
			if(locate(path, User)) continue
			if(skill["requires"])
				var/reqPath = text2path(skill["requires"])
				if(!locate(reqPath, User)) continue
			var/cost = getJutsuPickCost(User, skill["nature"])
			if(cost > available) continue
			var/label = skill["name"]
			if(skill["nature"])
				label += " ([skill["nature"]][cost > 1 ? ", 2 picks" : ""])"
			options[label] = path
			optionEntries[label] = skill

		if(!options.len)
			User << "You have already learned all eligible [Category] (Tier [tierCap] or lower) that you can afford."
			JutsuSelecting = FALSE
			return

		var/choice = input(User, "Select a [Category] skill to learn. (Tier [tierCap] cap, [available] pick\s available. Jutsu outside your Chakra Affinity cost 2 picks and 2x Mana.)", "Learn [Category]") as null|anything in options
		if(!choice)
			JutsuSelecting = FALSE
			return

		var/list/entry = optionEntries[choice]
		var/cost = getJutsuPickCost(User, entry["nature"])
		var/list/charged = spendJutsuPicks(User, cost)
		if(!charged)
			User << "You can no longer afford that selection."
			JutsuSelecting = FALSE
			return

		var/chosenPath = options[choice]
		var/obj/Skills/S = new chosenPath
		if(entry["nature"])
			S.ChakraNature = entry["nature"]
		if(cost > 1)
			S.ChakraExtraPickSlot = charged[charged.len]
		User.AddSkill(S)
		User << "You learn <b>[entry["name"]]</b>!"
		if(cost > 1)
			User << "Forcing chakra outside your affinity is taxing: <b>[entry["name"]]</b> will cost double Mana until you gain the [entry["nature"]] affinity."

		var/remaining = getJutsuPicksAvailable(User)
		if(remaining > 0)
			User << "You have [remaining] Jutsu pick\s remaining."

		JutsuSelecting = FALSE

	verb/Learn_Ninjutsu()
		set name = "Learn Ninjutsu"
		set category = "Shinobi"
		LearnJutsu(usr, "Ninjutsu")

	verb/Learn_Genjutsu()
		set name = "Learn Genjutsu"
		set category = "Shinobi"
		LearnJutsu(usr, "Genjutsu")

	verb/Learn_Taijutsu()
		set name = "Learn Taijutsu"
		set category = "Shinobi"
		LearnJutsu(usr, "Taijutsu")
