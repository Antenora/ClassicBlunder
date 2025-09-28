/mob/Admin3/verb/BreakPact()
	var/datum/Pact/whichPact = input(usr, "Which pact would you like to break?") in glob.allPacts
	var/withPenalties = input(usr, "Would you like to break that pact with penalties or without?") in list("With Penalties", "Without Penalties")
	var/penaltiesForWho
	switch(withPenalties)
		if("With Penalties")
			withPenalties = TRUE
			penaltiesForWho = input(usr, "Who would you like to apply penalties to?") in list("Both", PACT_OWNER, PACT_SUBJECT)
		if("Without Penalties")
			withPenalties = FALSE
	whichPact.breakPact(withPenalties, penaltiesForWho)

/globalTracker/var/list/allPacts = list() // where the actual pact datum ends up.

proc/findPactByID(id)
	for(var/datum/Pact/pact in glob.allPacts)
		if(pact.pactID == id)
			return pact

/obj/Pact
/obj/Pact/var/pactLimit = PACT_LIMIT
/obj/Pact/var/list/currentPacts = list()// a list with ids to pacts in it

/obj/Pact/verb/Check_Pact()
	set category = "Skills"
	checkPact(usr)

/obj/Pact/proc/checkPact(mob/user)
	var/list/allPacts = getAllPacts()
	if(allPacts.len == 0)
		user << "You don't have any pacts set up!"
		return

	var/datum/Pact/whichPact = input(user, "What pact would you like to view the details and penalty of?") in allPacts
	whichPact.viewAllDetails(user)

/obj/Pact/proc/getAllPacts()
	. = list()
	for(var/pactID in currentPacts)
		. += findPactByID(pactID)

/obj/Pact/proc/checkPactRequirements(mob/user)
	if(currentPacts.len >= pactLimit)
		user << "You already are at the limits for your pacts!"
		return 0
	return 1

/obj/Pact/Pacted // the obj ppl pacted should get for sanity purposes

/obj/Pact/Pacter //the obj ppl pacting others Should Actually Get.

/obj/Pact/Pacter/verb/Create_Pact()
	set category = "Skills"
	createPact(usr)

/obj/Pact/Pacter/proc/createPact(mob/user)
	if(!checkPactRequirements(user))
		return

	var/list/validTargets = getTargets(user)

	var/target = pickTarget(user, validTargets)

	var/datum/Pact/pact = new()
	pact.CreatePact(user, target)

/obj/Pact/Pacter/proc/getTargets(mob/user)
	. = list("Cancel")
	for(var/mob/m in oview(15,user))
		. += m

/obj/Pact/Pacter/proc/pickTarget(mob/user, list/validTargets)
	var/target = input(user, "Who would you like to make a pact with?") in validTargets
	if(target=="Cancel") return 0
	return target



/datum/Pact
/datum/Pact/var/details // html / text of the details of the pact.
/datum/Pact/var/ownerPenalty = NO_PENALTY // bitflag of what penalties to cause for the owner.
/datum/Pact/var/subjectPenalty = NO_PENALTY // bitflag of what penalties to cause for the subject.
/datum/Pact/var/penaltyHarshness = 0.5 // how many taxes/healthcut * 100 the dude gets i think.
/datum/Pact/var/subjectUID // subject's UniqueID
/datum/Pact/var/ownerUID // owner's UniqueID
/datum/Pact/var/sealed = FALSE // if the pact is actually active and enforced

/datum/Pact/var/broken = PACT_UNBROKEN // if the pact is broken.
/datum/Pact/var/ownerPenaltyInflicted = FALSE
/datum/Pact/var/subjectPenaltyInflicted = FALSE

/datum/Pact/var/pactID

/datum/Pact/proc/CreatePact(mob/Players/owner, mob/Players/subject)
	ownerUID = owner.UniqueID
	subjectUID = subject.UniqueID
	createDetails(owner)
	chooseOwnerPenalties(owner)
	chooseSubjectPenalties(owner)
	choosePenaltyHarshness(owner)
	if(!confirmDetails(owner))
		del src
	if(!presentPact(subject))
		owner << "[subject] rejected your pact!"
		del src
	owner << "[subject] has accepted your pact!"
	subject << "The pact is signed..."
	sealed = TRUE
	pactID = glob.allPacts.len+1
	var/obj/Pact/Pacted/subjectPact = locate() in subject
	if(!subjectPact)
		subjectPact = new()
		subject.contents += subjectPact
	subjectPact.currentPacts += pactID
	var/obj/Pact/Pacter/ownerPact = locate() in owner
	ownerPact.currentPacts += pactID
	glob.allPacts += src

/datum/Pact/proc/presentPact(mob/presentingTo)
	viewDetails(presentingTo)
	var/accept = input(presentingTo, "Do you accept the pact with the penalties of [translatePenalty(PACT_OWNER)] for the owner([findPlayerByUID(ownerUID)]), and [translatePenalty(PACT_SUBJECT)] for the subject([presentingTo.name]) from [findPlayerByUID(ownerUID)]? The harshness of these penalties are [getHarshnessForDisplay()]% of your values.") in list("Yes", "No")
	switch(accept)
		if("Yes")
			return 1
		if("No")
			return 0

/datum/Pact/proc/translatePenalty(which = PACT_OWNER)
	var/text = ""
	switch(which)
		if(PACT_OWNER)
			if(ownerPenalty & NO_PENALTY)
				text += "No Penalty."
			if(ownerPenalty & TAX_PENALTY)
				text += "Tax Penalty, "
			if(ownerPenalty & HEALTH_PENALTY)
				text += "Health Penalty, "
			if(ownerPenalty & ENERGY_PENALTY)
				text += "Energy Penalty, "
			if(ownerPenalty & MANA_PENALTY)
				text += "Mana Penalty, "
			if(ownerPenalty & DEATH_PENALTY)
				text += "Death Penalty, "
		if(PACT_SUBJECT)
			if(subjectPenalty & NO_PENALTY)
				text += "No Penalty."
			if(subjectPenalty & TAX_PENALTY)
				text += "Tax Penalty, "
			if(subjectPenalty & HEALTH_PENALTY)
				text += "Health Penalty, "
			if(subjectPenalty & ENERGY_PENALTY)
				text += "Energy Penalty, "
			if(subjectPenalty & MANA_PENALTY)
				text += "Mana Penalty, "
			if(subjectPenalty & DEATH_PENALTY)
				text += "Death Penalty, "
	text = replacetext(text, ", ", ".", length(text)-3, 0)
	return text

/datum/Pact/proc/chooseOwnerPenalties(mob/picker)
	var/choice
	while(choice != "No Penalty")
		choice = input(picker, "What penalties would you like to add to the Owner's Penalties, the current penalties are [translatePenalty()] Click No Penalty when done.", "Owner Penalty Selection") in PENALTY_LIST
		ownerPenalty |= PENALTY_TRANSLATION_LIST[choice]
	picker << "The owner penalties are [translatePenalty(PACT_OWNER)]"

/datum/Pact/proc/chooseSubjectPenalties(mob/picker)
	var/choice
	while(choice != "No Penalty")
		choice = input(picker, "What penalties would you like to add to the Subject's Penalties, the current penalties are [translatePenalty()] Click No Penalty when done.", "Subject Penalty Selection") in PENALTY_LIST
		subjectPenalty |= PENALTY_TRANSLATION_LIST[choice]
	picker << "The subject penalties are [translatePenalty(PACT_SUBJECT)]"

/datum/Pact/proc/choosePenaltyHarshness(mob/picker)
	var/harshness
	while(harshness == -1)
		harshness = input(picker, "What amount of harshness do you want the penalty to be? From 1 to 100. 1 being a 1% tax on break, or a 1% health cut and so on. This doesn't impact Death Penalty.", "Penalty Harshness") as num
		if(harshness > 100 || harshness < 0)
			picker << "Invalid harshness!"
			harshness = -1
	penaltyHarshness = harshness/100

/datum/Pact/proc/getHarshnessForDisplay()
	return penaltyHarshness*100

/datum/Pact/proc/createDetails(mob/writer)
	details = input(writer, "What would you like the details to be?") as message

/datum/Pact/proc/viewDetails(mob/viewer)
	viewer << browse(html_encode(details))

/datum/Pact/proc/confirmDetails(mob/owner)
	viewDetails(owner)
	var/confirm = input("Are you sure you want to present this pact to [findPlayerByUID(subjectUID)] with the penalties of [translatePenalty()] with a harshness of [getHarshnessForDisplay()]% and the following details?") in list("Yes", "No")
	switch(confirm)
		if("Yes")
			return 1
		if("No")
			return 0

/datum/Pact/proc/breakPact(inflictPenalties = FALSE, whoToInflict)
	var/mob/subject = findPlayerByUID(subjectUID)
	var/mob/owner = findPlayerByUID(ownerUID)
	if(subject&&!subjectPenaltyInflicted)
		breakPactMessage(subject)
	if(owner&&!ownerPenaltyInflicted)
		breakPactMessage(owner)
	if(inflictPenalties)
		inflictPenalties(owner, subject, whoToInflict)
		switch(whoToInflict)
			if("Both")
				broken = PACT_BROKEN_BOTH_PENALTY
			if(PACT_OWNER)
				broken = PACT_BROKEN_OWNER_PENALTY
			if(PACT_SUBJECT)
				broken = PACT_BROKEN_SUBJECT_PENALTY
	else
		broken = PACT_BROKEN_NO_PENALTY
		ownerPenaltyInflicted = TRUE
		subjectPenaltyInflicted = TRUE

/datum/Pact/proc/inflictPenalties(mob/owner, mob/subject, whoToInflict)
	if(owner&&!ownerPenaltyInflicted&&(whoToInflict==PACT_OWNER||whoToInflict=="Both"))
		if(ownerPenalty & NO_PENALTY)
			owner << "No penalty has been applied to you..."
		if(ownerPenalty & TAX_PENALTY)
			causeTaxPenalty(owner)
		if(ownerPenalty & HEALTH_PENALTY)
			causeHealthPenalty(owner)
		if(ownerPenalty & ENERGY_PENALTY)
			causeEnergyPenalty(owner)
		if(ownerPenalty & MANA_PENALTY)
			causeManaPenalty(owner)
		if(ownerPenalty & DEATH_PENALTY)
			causeDeathPenalty(owner)

		ownerPenaltyInflicted = TRUE

	if(subject&&!subjectPenaltyInflicted&&(whoToInflict==PACT_SUBJECT||whoToInflict=="Both"))
		if(subjectPenalty & NO_PENALTY)
			subject << "No penalty has been applied to you..."
		if(subjectPenalty & TAX_PENALTY)
			causeTaxPenalty(subject)
		if(subjectPenalty & HEALTH_PENALTY)
			causeHealthPenalty(subject)
		if(subjectPenalty & ENERGY_PENALTY)
			causeEnergyPenalty(subject)
		if(subjectPenalty & MANA_PENALTY)
			causeManaPenalty(subject)
		if(subjectPenalty & DEATH_PENALTY)
			causeDeathPenalty(subject)

		subjectPenaltyInflicted = TRUE

/datum/Pact/proc/causeTaxPenalty(mob/inflictOn)
	OMsg(inflictOn,"[inflictOn] feels their body constrict with hundreds of little chains unseen to the eye!")
	inflictOn.AddStrTax(penaltyHarshness)
	inflictOn.AddEndTax(penaltyHarshness)
	inflictOn.AddSpdTax(penaltyHarshness)
	inflictOn.AddForTax(penaltyHarshness)
	inflictOn.AddOffTax(penaltyHarshness)
	inflictOn.AddDefTax(penaltyHarshness)

/datum/Pact/proc/causeHealthPenalty(mob/inflictOn)
	OMsg(inflictOn,"[inflictOn] feels their very life force drain away, suddenly quite pale!")
	inflictOn.AddHealthCut(penaltyHarshness)

/datum/Pact/proc/causeEnergyPenalty(mob/inflictOn)
	OMsg(inflictOn,"[inflictOn] feels their stamina drain away, finding it hard to breathe!")
	inflictOn.AddEnergyCut(penaltyHarshness)

/datum/Pact/proc/causeManaPenalty(mob/inflictOn)
	OMsg(inflictOn,"[inflictOn] feels their very magical existence begin to shrivel...!")
	inflictOn.AddManaCut(penaltyHarshness)

/datum/Pact/proc/causeDeathPenalty(mob/inflictOn)
	OMsg(inflictOn,"[inflictOn] suddenly grasps their chest, seizing up...!")
	inflictOn.Death(null, "[inflictOn] suffers a Penalty, rending their heart in twain.")

/datum/Pact/proc/breakPactMessage(mob/tellThem)
	if(tellThem)
		viewDetails(tellThem)
		tellThem << "Your pact with the penalties of [translatePenalty()] & the following details has been broken!"

/datum/Pact/proc/viewAllDetails(mob/viewer)
	viewDetails(viewer)
	viewer << "This pact has the penalties of [translatePenalty()]"


// i didnt look at anything below here rly

/datum/DemonRacials/var/PactsByCkey

/datum/DemonRacials/var/PactsTaken = 0 

/datum/DemonRacials/proc/givePact(mob/o,mob/p, datum/Pact/pact)
	var/asc = o.AscensionsAcquired + 1
	if(PactsTaken + 1 > asc)
		o <<"You can't make any more pacts."
		return
	var/option = input(o, "What do you want to give?") in list("Magic", "Passive","Enchant")
	giveReward(o, p, option)



/datum/DemonRacials/proc/giveReward(mob/o, mob/p, option)
	switch(option)
		if("Magic")
			var/skills = list("DarkMagic" = list("Shadow Ball" = /obj/Skills/Projectile/Magic/DarkMagic/Shadow_Ball, \
			"Soul Leech" = /obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Soul_Leech, "Dominate Mind" = /obj/Skills/Buffs/SlotlessBuffs/Magic/DarkMagic/Dominate_Mind), \
			"HellFire" = list("Hellpyre" = /obj/Skills/Projectile/Magic/HellFire/Hellpyre, \
			"Hellstorm" = /obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/Hellstorm, "OverHeat" = /obj/Skills/Buffs/SlotlessBuffs/Magic/HellFire/OverHeat))
			var/exists = TRUE
			var/exit = FALSE
			var/obj/Skills/newSkill = null
			while(exit == FALSE)
				var/category = input(o, "What category") in list("DarkMagic", "HellFire")
				var/selection = input(o, "What skill?") in skills[category]
				for(var/obj/Skills/x in p)
					if(x.type == selection)
						exists = TRUE
						break
				if(exists)
					break
				newSkill = new selection
				exit = TRUE
				// i hate this shit

			p.AddSkill(newSkill)

		if("Passive")
			var/passive = input(o, "What passive?") in o.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Devil_Arm2).passives
			if(!passive)
				o << "You have none"
				return
			var/obj/Skills/Buffs/SlotlessBuffs/Posture_2/posture = p.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Posture_2)
			if(posture)
				posture.passives["[passive]"] += 0
			    // devil arm function to calculate what gets what
