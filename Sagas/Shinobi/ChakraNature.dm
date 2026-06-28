var/list/ChakraNatureList = list("Katon", "Futon", "Raiton", "Suiton", "Doton")

obj/Skills
	var/ChakraNature            // one of ChakraNatureList, or null for natureless jutsu/non-jutsu skills
	var/ChakraExtraPickSlot     // which pick slot the 2nd (off-affinity) pick was charged to

mob/proc/ChakraCostMult(obj/Skills/S)
	if(!S || !S.ChakraNature) return 1
	if(src.Saga != "Shinobi") return 1
	if(src.ChakraSpecialization && S.ChakraNature == src.ChakraSpecialization) return 0.5
	if(S.Copied && S.copiedBy == "Sharingan") return 1
	if(src.ChakraAffinities && (S.ChakraNature in src.ChakraAffinities)) return 1
	return 2

mob/proc/rollChakraAffinity()
	if(src.ChakraSpecialization) return
	var/owned = (src.ChakraAffinities ? src.ChakraAffinities.len : 0) + src.ChakraAffinityPending
	var/chance = 0
	switch(owned)
		if(1) chance = 25
		if(2) chance = 10
		if(3) chance = 3
		if(4) chance = 1
	if(!chance || !prob(chance))
		return
	src.ChakraAffinityPending++
	var/choice = alert(src, "A new chakra nature stirs within you. Will you attune to it?", "Chakra Awakening", "Accept", "Decline")
	if(choice == "Accept" && !src.ChakraSpecialization)
		src.pickChakraAffinity()
	else
		src << "You decided not to obtain another affinity."
	src.ChakraAffinityPending--

mob/proc/pickChakraAffinity(firstPick = FALSE)
	if(!src.ChakraAffinities)
		src.ChakraAffinities = list()
	var/list/remaining = ChakraNatureList - src.ChakraAffinities
	if(!remaining.len)
		return
	if(firstPick)
		var/choice = input(src, "Which Chakra Nature do you have an affinity for?", "Chakra Affinity") in remaining
		src.ChakraAffinities += choice
		src << "Your chakra flows naturally into <b>[choice]</b>. Jutsu of other natures will cost twice as much to use and double picks to learn."
	else
		src << "A new chakra nature is opening itself to you!"
		var/choice = input(src, "Which Chakra Nature do you attune to?", "New Chakra Affinity") in remaining
		src.ChakraAffinities += choice
		src << "You now hold an affinity for <b>[choice]</b> chakra!"
		src << "Your broadened chakra expands your Jutsu selections, every pick tier now holds more picks."
		src.refundChakraExtraPicks(choice)

mob/proc/verb_ObtainChakraAffinity()
	set name = "Obtain Chakra Affinity"
	set category = "Shinobi"
	if(src.Saga != "Shinobi")
		return
	if(src.ChakraSpecialization)
		src << "You have specialized in [src.ChakraSpecialization], no other chakra nature will answer you."
		return
	if(src.ChakraAffinityPending)
		src << "You are already in the middle of attuning to a chakra nature."
		return
	var/owned = src.ChakraAffinities ? src.ChakraAffinities.len : 0
	if(owned < 1)
		return
	if(owned >= 3)
		src << "Training alone can take you no further."
		return
	var/cost = (owned == 1) ? 100 : 200
	if(src.GetRPPSpendable() < cost)
		src << "You need [cost] RPP to obtain another Chakra Affinity. (You have [round(src.GetRPPSpendable())].)"
		return

	src.ChakraAffinityPending++
	var/confirm = alert(src, "Invest [cost] RPP to obtain a [owned == 1 ? "second" : "third"] Chakra Affinity?", "Obtain Chakra Affinity", "Yes", "No")
	// Re-validate after the prompt: affinities, specialization, or RPP may have changed while it sat open.
	if(confirm != "Yes" || src.Saga != "Shinobi" || src.ChakraSpecialization \
	   || (src.ChakraAffinities ? src.ChakraAffinities.len : 0) != owned \
	   || src.GetRPPSpendable() < cost)
		if(confirm == "Yes")
			src << "You can no longer obtain a Chakra Affinity this way."
		src.ChakraAffinityPending--
		return

	src.RPPSpendable -= cost
	src.RPPSpent += cost
	src << "You initiate grueling elemental training..."
	src.pickChakraAffinity()
	src.ChakraAffinityPending--

mob/proc/offerChakraSpecialization()
	if(src.Saga != "Shinobi") return
	if(src.ChakraSpecialization) return
	var/waited = 0
	while(src.ChakraAffinityPending > 0 && waited < 3000)
		sleep(10)
		waited += 10
	if(!src.ChakraAffinities || src.ChakraAffinities.len != 1)
		return
	var/nature = src.ChakraAffinities[1]
	src.ChakraAffinityPending++
	var/done = FALSE
	while(!done)
		var/choice = alert(src, "Your bond with [nature] runs deep, and you may now choose to specialize in it. Specializing PERMANENTLY forsakes all other chakra natures - no further affinities, by chance or training. In exchange, your [nature] jutsu cost half as much, their cooldowns are reduced by 15%, and your Jutsu pick capacity is doubled. This offer will not come again.", "Chakra Specialization", "Specialize", "Decline")
		if(choice == "Specialize")
			if(alert(src, "Specializing in [nature] cannot be undone. Are you certain?", "Chakra Specialization", "Yes", "No") == "Yes")
				src.ChakraSpecialization = nature
				src << "You devote yourself wholly to <b>[nature]</b>. Its chakra answers you like a second heartbeat."
				src << "Your [nature] jutsu now cost half Mana and recover 15% faster, and your Jutsu pick capacity has doubled."
				done = TRUE
		else
			src << "You leave your chakra open to other natures."
			done = TRUE
	src.ChakraAffinityPending--

mob/proc/refundChakraExtraPicks(nature)
	for(var/obj/Skills/S in src)
		if(S.ChakraNature != nature) continue
		if(!S.ChakraExtraPickSlot) continue
		switch(S.ChakraExtraPickSlot)
			if("JutsuSL1Picks") src.JutsuSL1Picks = max(0, src.JutsuSL1Picks - 1)
			if("JutsuSL3Picks") src.JutsuSL3Picks = max(0, src.JutsuSL3Picks - 1)
			if("JutsuSL5Picks") src.JutsuSL5Picks = max(0, src.JutsuSL5Picks - 1)
			if("JutsuSL6Picks") src.JutsuSL6Picks = max(0, src.JutsuSL6Picks - 1)
			if("JutsuSL7Picks") src.JutsuSL7Picks = max(0, src.JutsuSL7Picks - 1)
		S.ChakraExtraPickSlot = null
		src << "The extra pick spent learning <b>[S.name]</b> returns to you."

mob/proc/ShinobiRestoreVerbs()
	if(src.Saga != "Shinobi") return
	src.verbs += /mob/proc/verb_ObtainChakraAffinity
