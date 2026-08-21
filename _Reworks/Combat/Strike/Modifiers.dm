globalTracker/var/SYMBIOTE_DMG_TEST = 2

/mob/proc/styleModifiers(mob/defender)
    if(HasSoftStyle())
        . += (defender.TotalFatigue/20) * (GetSoftStyle() / glob.SOFT_STYLE_DMG_BOON_DIVISOR)
    if(HasHardStyle())
        . += (defender.TotalInjury/20) * (GetHardStyle() / glob.HARD_STYLE_DMG_BOON_DIVISOR)
    if(passive_handler.Get("CheapShot"))
        . += (defender.TotalInjury/glob.CHEAP_SHOT_DIVISOR) * (passive_handler.Get("CheapShot") + GetMangLevel())
    if(HasCyberStigma())
        if(defender.CyberCancel || defender.Mechanized || defender.Saga == "King of Braves")
            var/mana = defender.ManaAmount
            var/manaCap = defender.GetManaCapMult()
            var/ratio = mana / manaCap
            ratio = abs(ratio - 100) / 33
            . += ratio * (max(defender.Mechanized,defender.CyberCancel) * (GetCyberStigma() ))

globalTracker/var/
    MORTAL_VS_GOD_SPEC_DMG_REDUCTION = 0.3;

#define NO_GOD_KI_REDUCTION 1
#define VALID_SPEC_DMG_TYPE list("Holy", "Abyss", "Slayer")//only slayer is implemented atm
/mob/proc/attackModifiers(mob/defender, list/forcedDmgList=list())
    var/godKiNerf = NO_GOD_KI_REDUCTION;
    if(defender.HasGodKi() && !HasGodKi() && !HasNull() && !isRace(DEMIFIEND) && !defender.isRace(DEMIFIEND) && !istype(src, /mob/Player/AI/Demon) && !istype(defender, /mob/Player/AI/Demon)) godKiNerf += max(0, (glob.MORTAL_VS_GOD_SPEC_DMG_REDUCTION * defender.GetGodKi()));
    var/forcedHoly = getForcedDamageType("Holy", forcedDmgList)
    if(HasHolyMod() || forcedHoly)
        . += (HolyDamage(defender, forcedHoly) / glob.HOLY_DAMAGE_DIVISOR)
    var/forcedAbyss = getForcedDamageType("Abyss", forcedDmgList)
    if(HasAbyssMod() || forcedAbyss)
        . += (AbyssDamage(defender, forcedAbyss) / glob.ABYSS_DAMAGE_DIVISOR)
    . += GetSlayerMod(defender, getForcedDamageType("Slayer", forcedDmgList)) / glob.SLAYER_DAMAGE_DIVISOR; //validates within the GetSlayerMod proc, which does still need to be moved out of _binaryChecks
    . /= max(NO_GOD_KI_REDUCTION, godKiNerf);

/mob/proc/getForcedDamageType(typeToFind, list/forcedDmgList=list())
    if(!typeToFind) return 0;
    if(!forcedDmgList || forcedDmgList.len < 1) return 0;
    if(!(typeToFind in VALID_SPEC_DMG_TYPE)) return 0;
    var/val = forcedDmgList[typeToFind];
    . = 0;
    . += isnum(val) ? val : 0;

//one list for every delivery type; null when the skill brings nothing
/proc/buildSpecDmgTypes(holyMod, sanctify, abyssMod, slayerMod)
    var/holy = (holyMod ? holyMod : 0) + (sanctify ? sanctify * glob.SANCTIFY_EFFECTIVENESS : 0)
    if(holy <= 0 && !abyssMod && !slayerMod) return null
    . = list()
    if(holy > 0) .["Holy"] = holy
    if(abyssMod) .["Abyss"] = abyssMod
    if(slayerMod) .["Slayer"] = slayerMod

/mob/proc/desperationCheck()
	var/bonus = 1
	if(HasInjuryImmune() || HasUnstoppable()) //you can't be desperate if nothing can stop you
		return FALSE
	if(passive_handler.Get("UnderDog") || hasDeterminationDesperation())
		// they are able to get the bonus
		bonus += Saga == "King of Braves" ? 0.35 : 0
		bonus += Saga == "Kamui" ? 0.35 : 0
		bonus += Secret == "Spiral" ? 0.35 : 0
		bonus += isRace(HUMAN) ? 0.35 : 0
		bonus += isRace(HALFSAIYAN) ? 0.35 : 0
		bonus += isRace(POPO) ? 0.35 : 0
		bonus += getDeterminationDesperationRatio()
		return bonus
	return FALSE

/mob/proc/GetDesperationBonus(mob/defender)
	var/bonusRatio = desperationCheck()
	var/defBonusRatio = defender ? defender.desperationCheck() : 0
	var/PopoVal=1
	if(isRace(POPO))
		PopoVal*=GetPowerUpRatio()
	var/injuries = TotalInjury/100
	var/defInjuries = defender ? defender.TotalInjury/100 : 0
	var/UnderDet = getDeterminationCount()
	. = 0
	if(bonusRatio)
		. +=  round(((glob.DESPERATION_ATK_RATE * bonusRatio) * (UnderDet+passive_handler.Get("UnderDog"))) * injuries, 0.01) * PopoVal
	if(defBonusRatio)
		var/defUnderDet = defender.getDeterminationCount()
		. -=  round(((glob.DESPERATION_DEF_RATE * defBonusRatio) * (defUnderDet+defender.passive_handler.Get("UnderDog"))) * defInjuries, 0.01) * PopoVal
	. = clamp(., -glob.DESPERATION_CAP, glob.DESPERATION_CAP)


/mob/proc/getTypeBonus(unarmed, spirit)
	if(spirit && HasSpiritualDamage())
		. += GetSpiritualDamage()

/mob/proc/getDuelistBonus(mob/defender)
	if(Target && HasDuelist())
		if(Target == defender)
			. += GetDuelist()

/obj/Skills/Buffs/proc/incrementLimit(mob/player, option)
	var/varLimit = option + "Limit"
	if(!vars[varLimit])
		return FALSE
	if(vars[option] ++ >= vars[varLimit])
		vars[option] = 0
		Trigger(player)
		return TRUE
	return FALSE

/mob/proc/triggerLimit(option)
	var/varName = option + "Hits"
	var/varLimit = option + "HitsLimit"
	var/list/varlist = list("ActiveBuff","SpecialBuff","SlotlessBuffs","StanceBuff","StyleBuff")
	if(HasPassive(varLimit, BuffsOnly = 1, NoMobVar = 1))
		for(var/x in varlist)
			if(vars[x])
				if(istype(vars[x], /list)) // must b slotlessbuffs
					for(var/buffs in vars[x]) // index it
						if(vars[x][buffs]) // index of an index, kind of autistic, make sure it exists though (it should but w/e)
							if(vars[x][buffs].vars[varLimit] != 0) // make sure its not 0 before we put it up
								vars[x][buffs].incrementLimit(src, varName) // yeah put it up
				else
					if(vars[x].vars[varLimit] != 0)
						vars[x].incrementLimit(src, varName)

/globalTracker/var/LIGHT_DARK_EFFECTIVE = 0.5
/mob/proc/getEleEffective(swordEle, atomicFist)
    var/effective = glob.LIGHT_DARK_EFFECTIVE
    if(swordEle)
        effective *= 0.75
    if(atomicFist)
        effective *= 2
    return effective



// TESTED
/mob/proc/getLightDarkCalc(option, mob/d)
	. = 0
	var/direFist = UsingDireFist()
	var/darkSword = UsingDarkElementSword()
	var/atomicFist = UsingAtomicFist()
	var/tranqFist = UsingTranquilFist()
	var/lightSword = UsingLightElementSword()
	switch(option)
		if("Offense")
			var/hasDarkOff = (direFist || darkSword || ElementalOffense == "Dark" || ElementalOffense == "Heartless" )
			if(hasDarkOff)
				var/effective = getEleEffective(darkSword, atomicFist)
				if(effective > 0 && Anger)
					. += effective
			var/hasLightOff = (tranqFist || lightSword || ElementalOffense == "Light")
			if(hasLightOff)
				var/effective = getEleEffective(lightSword, atomicFist)
				if(effective > 0 && (d&&d.Anger || d&&d.AngerCD)|| ElementalOffense == "Heartless")
					. += effective
		if("Defense")
			var/hasDarkDef = (direFist || darkSword || ElementalDefense == "Dark")
			if(hasDarkDef)
				var/effective = getEleEffective(darkSword, atomicFist)
				if(effective > 0 && Anger)
					. -= effective
			var/hasLightDef = (tranqFist || lightSword || ElementalDefense == "Light")
			if(hasLightDef)
				var/effective = getEleEffective(lightSword, atomicFist)
				if(effective > 0 && (Anger || AngerCD))
					. -= effective


globalTracker/var/list/IGNORE_POWER_CLAMP_PASSIVES = list("Star Surge")


/mob/proc/ignoresPowerClamp(mob/defender)
    if(!defender) return
    if(istype(src, /mob/Player/AI) || istype(defender, /mob/Player/AI))
        return TRUE
    if(!passive_handler || !defender.passive_handler)
        return FALSE
    if(passive_handler.Get("Justice") || defender.passive_handler.Get("Justice"))
        return FALSE
    if(isRace(MAJIN))
        return TRUE
    if(Secret == "Heavenly Restriction" && secretDatum?:hasImprovement("Power"))
        return TRUE
    for(var/passive in glob.IGNORE_POWER_CLAMP_PASSIVES)
        if(passive_handler.Get(passive))
            return TRUE
    if(passive_handler.Get("WrathFactor") && HealthPct() <= 50 && demonDevilTriggerSinMastery())
        return TRUE
    if(passive_handler.Get("Kaioken") && (HealthPct()<=20 || Kaioken>=5))
        return TRUE
    if(isRace(POPO) || defender.isRace(POPO))
        return TRUE
    if(isRace(MAKAIOSHIN))
        if(CheckSlotless("Corrupt Self"))
            return TRUE
        if(HealthPct() <= 15 + (AscensionsAcquired*5))
            return TRUE
 /*   var/godKi = !HasNullTarget() ? GetGodKi() : 0;
    var/defenderGodKi = !defender.HasNullTarget() ? defender.GetGodKi() : 0;
    if(!defenderGodKi && godKi)
        return TRUE
    else
        if(godKi > defenderGodKi && (godKi - defenderGodKi) >= 0.5)
            return TRUE*/
    return FALSE


/globalTracker/var/BASE_MOMENTUM_CHANCE = 50
/globalTracker/var/MAX_HARDEN_STACKS = 32
/globalTracker/var/MAX_GRIT_STACKS = 100
/globalTracker/var/HARDEN_DIVISOR = 2
/globalTracker/var/MAX_MOMENTUM_STACKS = 32
/globalTracker/var/MOMENTUM_DIVISOR = 2
/globalTracker/var/ACUPUNCTURE_BASE_CHANCE = 8
/globalTracker/var/ACUPUNCTURE_DIVISOR = 2

/globalTracker/var/MOMENTUM_BASE_BOON = 0.0005
/globalTracker/var/MOMENTUM_MAX_BOON = 4

/mob/proc/applySoftCC(mob/defender, val)
    if(defender.getHarden())
        defender.HardenAccumulate();
    if(passive_handler["SoulTug"] && (defender.CyberCancel||defender.Mechanized))
        defender.AddConfusing(passive_handler["SoulTug"]*glob.SOULTUGMULT)
    if(HasDisorienting())
        if(prob(GetDisorienting()*25))
            defender.AddConfusing(clamp(val, 1,10) * 1.25)
    if(HasStunningStrike())
        if(!defender.Stunned)
            if(prob(clamp(GetStunningStrike() * 10, 10, 70)))
                Stun(defender, 3)
/mob/proc/applyAdditonalDebuffs(mob/defender, value)
    var/list/debuffs = list("Shearing", "Confusing","Crippling", "Attracting")
    for(var/debuff in debuffs)
        if(passive_handler.Get("[debuff]"))
            call(defender, "Add[debuff]")(passive_handler.Get("[debuff]") * clamp(value, 0.1, 1))


/mob/proc/finalModifiers(mob/defender)
    if(defender.GetWeaponSoulType() == "Soul Calibur")
        . -= 2
