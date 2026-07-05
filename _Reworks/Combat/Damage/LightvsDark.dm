/globalTracker/var/LIGHT_DARK_EFFECTIVE = 0.5
/globalTracker/var/DEMON_DARK_BOON_ALWAYS = TRUE
/globalTracker/var/DEMON_NO_DARK_BOON = TRUE
/mob/proc/getEleEffective(swordEle, atomicFist, demon)
    var/effective = glob.LIGHT_DARK_EFFECTIVE
    if(swordEle)
        effective *= 0.75
    if(atomicFist)
        effective *= 2
    if(demon)
        effective += AscensionsAcquired
    return effective



// TESTED
/mob/proc/getLightDarkCalc(option, mob/d)
	. = 0
	var/direFist = UsingDireFist()
	var/darkSword = UsingDarkElementSword()
	var/atomicFist = UsingAtomicFist()
	var/demon = isRace(DEMON)
	if(glob.DEMON_NO_DARK_BOON)
		demon = 0
	var/tranqFist = UsingTranquilFist()
	var/lightSword = UsingLightElementSword()
	switch(option)
		if("Offense")
			var/hasDarkOff = (direFist || darkSword || ElementalOffense == "Dark" || demon|| ElementalOffense == "Heartless" )
			if(hasDarkOff)
				var/effective = getEleEffective(darkSword, atomicFist, demon)
				if(effective > 0 && Anger)
					. += effective
				if(demon && !Anger)
					if(glob.DEMON_DARK_BOON_ALWAYS)
						. += (effective / 2)
			var/hasLightOff = (tranqFist || lightSword || ElementalOffense == "Light")
			if(!demon && hasLightOff)
				var/effective = getEleEffective(lightSword, atomicFist, demon)
				if(effective > 0 && (d&&d.Anger || d&&d.AngerCD)|| ElementalOffense == "Heartless")
					. += effective
		if("Defense")
			var/hasDarkDef = (direFist || darkSword || ElementalDefense == "Dark" || demon)
			if(hasDarkDef)
				var/effective = getEleEffective(darkSword, atomicFist, demon)
				if(effective > 0 && Anger)
					. -= effective
				if(demon && !Anger)
					if(glob.DEMON_DARK_BOON_ALWAYS)
						. -= (effective / 2)
			var/hasLightDef = (tranqFist || lightSword || ElementalDefense == "Light")
			if(!demon && hasLightDef)
				var/effective = getEleEffective(lightSword, atomicFist, demon)
				if(effective > 0 && (Anger || AngerCD))
					. -= effective
