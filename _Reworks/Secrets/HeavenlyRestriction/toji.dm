
/*
/datum/SecretInfomation
	HeavenlyRestriction
		name = "Heavenly Restriction"
		givenSkills = list("/obj/Skills/Buffs/SlotlessBuffs/HeavenlyRestriction/HeavenlyRestriction")
		secretVariable = list("Restrictions" = list(), "Improvements" = list())

/mob/var/datum/SecretInfomation/secretDatum = new()

pick something to restrict
pick something to improve
depending on the rescrit and improve, give an increase to that improve
if the improve is wide like melee damage, lessen the boon, if its narrow like normal attack widen the boon
if the restrict is narrow like using a sword, lessen the boon, if it is wide like 'using armed skills' widen the boon
(sword punching exists, so somebody could not use a sword, but still use armed skills making it narrow)

at intervals of 2, 4, 6 pick another restrict and improve, if you pick the same, increase the mult of the 1 boon

throw in stat mults at 2,4,5, depending on the path of restricting
    this is to say like a melee focus will get str , a force will get for, anda  hybrid will get both
    a melee will get str but lose for, by picking to lose for they get more str
    same as for and melee, by picking both the bonous is not that much

*/
/obj/Skills/Buffs/SlotlessBuffs/HeavenlyRestriction/HeavenlyRestriction
	AlwaysOn = 1
	ActiveMessage = ""
	OffMessage = ""

var/list/heavenly_restrictions = list("Staff" = 1, "Armor" = 2, "Sword" = 1, "Heavy Strike" = 2, "Armed Skills" = 2.5, "Unarmed Skills" = 2.5, "Magic" = 4, \
"Science" = 4, "Queues" = 3, "Autohits" = 3, "Projectiles" = 3, "Grapples" = 2, "All Skills" = 10, "Force" = 3, "Defense" = 3, "Endurance" = 3, \
"Cybernetics" = 2, "Strength" = 3, "Speed" = 3, "Offense" = 3, "Normal Attack" = 6, "Grab" = 2, "Zanzoken" = 3, "Senses" = 4, "Anger" = 4, "Power Control" = 3, "Special Slotter" = 4)

var/list/heavenly_improvements = list("Dragon Clash", "Grab", "Reverse Dash", "Launchers", "Stunners", "Heavy Strike", "Dragon Dash", "Senses", "Throw", "Strength", "Force", "Endurance", "Offense", "Defense", "Speed", "Anger", "Power Control", "Power")

/SecretInfomation/HeavenlyRestriction/proc/modifyRestrictionValues(mob/p, restriction)
	switch(restriction)
		if("Force")
			if(p.BaseFor()>p.BaseStr())
				return 1.5
		if("Defense")
			if(p.BaseDef()>p.BaseOff())
				return 1.5
		if("Offense")
			if(p.BaseOff()>p.BaseDef())
				return 1.5
		if("Endurance")
			var/boon = 1
			if(p.BaseEnd() > p.BaseStr())
				boon += 0.25
			if(p.BaseEnd() > p.BaseFor())
				boon += 0.25
			return boon
		if("Strength")
			if(p.BaseStr() > p.BaseFor())
				return 1.5
		if("Cybernetics")
			var/boon = 1
			boon += p.CyberizeMod
			return boon
		if("Magic")
			var/boon = 1
			boon += p.passive_handler.Get("ManaCapMult")
			return boon
	return 1

/SecretInfomation/HeavenlyRestriction/proc/pickRestriction(mob/p)
	var/list/modifiedRestrictions = heavenly_restrictions.Copy() - getRestrictions()
	var/list/shownRestrictions = list()
	for(var/i in modifiedRestrictions)
		var/value = modifiedRestrictions[i]
		var/mult = modifyRestrictionValues(p,i)
		modifiedRestrictions[i] = value*mult
		shownRestrictions += "[i] ([modifiedRestrictions[i]])"
	var/selection = input(p, "Pick a restriction. They are shown as what they'll restrict and the value in parathenses.") in shownRestrictions
	var/list/splitter = splittext(selection, " (")
	var/list/restrictionValue = list(splitter[1], modifiedRestrictions[splitter[1]])
	return restrictionValue

/SecretInfomation/HeavenlyRestriction/proc/pickImprove(mob/p, currentRestricitonChoice)
	var/atLimit = 1
	var/selection
	var/list/restrictions = getRestrictions() + currentRestricitonChoice + getBoons()
	while(atLimit)
		selection = input(p, "Pick an improvement") in heavenly_improvements - restrictions
		if(!(countImprovements(p, selection) >= 3))
			atLimit = 0
		else
			p << "You are at the limit for that improvement."
			selection = null
			atLimit = 1
	return selection

/SecretInfomation/HeavenlyRestriction/proc/applySecretVariable(mob/p, list/restr, improv)
	secretVariable["Restrictions"][restr[1]] = list(improv, restr[2])
	updateImprove(improv, restr[2])
	// secretVariable = list("Resitrictions" = list(1 = list(restr, improv), )

/SecretInfomation/HeavenlyRestriction/proc/updateImprove(improv, value)
	if(secretVariable["Improvements"][improv])
		secretVariable["Improvements"][improv] += value
	else
		secretVariable["Improvements"][improv] = value

/*
/SecretInfomation/HeavenlyRestriction/proc/resetImproves(mob/p)
    for(var/r in secretVariable["Restrictions"])
        r = secretVariable["Restrictions"][r]
        if(secretVariable["Improvements"][r[2]])
            if(r[1] in NARROW_RESTRICTS)
                secretVariable["Improvements"][r[2]]["narrow"] += 1
            else if(r[1] in WIDE_RESTRICTS)
                secretVariable["Improvements"][r[2]]["wide"] += 1
        else

            if(r[1] in NARROW_RESTRICTS)
                secretVariable["Improvements"][r[2]] = list("narrow" = 1, "wide" = 0)
            else if(r[1] in WIDE_RESTRICTS)
                secretVariable["Improvements"][r[2]] = list("narrow" = 0, "wide" = 1)*/


/SecretInfomation/HeavenlyRestriction/proc/getBoon(mob/p, improvement)
	var/totalBoon = 0
	for(var/index in secretVariable["Improvements"])
		if(index == improvement)
			totalBoon += secretVariable["Improvements"][index]

	return totalBoon


/SecretInfomation/HeavenlyRestriction/proc/countImprovements(mob/p, improv)
	var/total = 0
	for(var/index in secretVariable["Restrictions"])
		if(index == improv)
			total += 1
	return total

/SecretInfomation/HeavenlyRestriction/proc/getRestrictions()
	. = list()
	for(var/index in secretVariable["Restrictions"])
		. += index

/SecretInfomation/HeavenlyRestriction/proc/getBoons()
	. = list()
	for(var/index in secretVariable["Improvements"])
		. += index

/SecretInfomation/HeavenlyRestriction/proc/hasImprovement(improvement)
	if(secretVariable["Improvements"][improvement])
		return secretVariable["Improvements"][improvement]
	return FALSE

/SecretInfomation/HeavenlyRestriction/proc/hasRestriction(restriction)
	var/list/restricts = getRestrictions()
	for(var/x in restricts)
		if(restriction == x)
			return TRUE
	return FALSE


/*
/mob/verb/testRestriction()
	usr.secretDatum = new/SecretInfomation/HeavenlyRestriction()
	usr.Secret = "Heavenly Restriction"
	while(usr.secretDatum.currentTier < 2)
		var/list/restriction = usr.secretDatum?:pickRestriction(src)
		usr.secretDatum?:applySecretVariable(src, restriction, secretDatum?:pickImprove(src, restriction))
		usr.secretDatum.currentTier++
		sleep(15)
/*	var/improv = input(src, "what one") in usr.secretDatum?:secretVariable["Improvements"]
	world << improv
	usr.secretDatum?:getBoon(src, improv)*/
	return*/