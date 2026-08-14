/globalTracker/var/
	CRIT_CAP = 50;
	CRIT_K = 25;
	CRIT_DMG_BASE = 0.5;
	BLOCK_CAP = 50;
	BLOCK_K = 25;
	BLOCK_DR_BASE = 0.5;
	FEATHER_COWL_GROUNDED_BLOCK = 40;
	FEATHER_COWL_GROUNDED_POTENCY = 0.2;

/mob/var/tmp/SureCrit = 0 //next unblocked hit crits, consumed on use

/mob/proc/getInfatuation(mob/defender)
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/buff in src)
		if(buff.passives["Infatuated"]&&buff.Password == defender?:UniqueID)
			return 1+buff.passives["Infatuated"]
	return 1

//Offense owns crit chance. skill dials ride in on the strike
/mob/proc/getCritChance(critEff = 1, critBonus = 0)
	var/off = GetOff(1)
	. = glob.CRIT_CAP * off / (off + glob.CRIT_K)
	. = . * critEff + critBonus
	var/denkoCharge = DenkoSekkaCharged
	if(denkoCharge)
		. += denkoCharge * glob.DENKO_SEKKA_CRIT_CHANCE_PER_LEVEL
		DenkoSekkaCharged = 0

//full multiplier. read BEFORE getCritChance - that one eats the Denko charge
/mob/proc/getCritDmg()
	. = 1 + glob.CRIT_DMG_BASE + passive_handler.Get("CriticalDamage")
	if(DenkoSekkaCharged)
		. += DenkoSekkaCharged * glob.DENKO_SEKKA_CRIT_DAMAGE_PER_LEVEL

//Defense owns block chance
/mob/proc/getBlockChance(blockEff = 1)
	var/def = GetDef(1)
	. = glob.BLOCK_CAP * def / (def + glob.BLOCK_K)
	. *= blockEff
	if(Class == "Feather Cowl" && Grounded > world.time)
		. += glob.FEATHER_COWL_GROUNDED_BLOCK //wakeup armor
	. += getDeterminationBlockBonus()

//full divisor
/mob/proc/getBlockDR()
	. = 1 + glob.BLOCK_DR_BASE + passive_handler.Get("CriticalBlock")
	if(Class == "Feather Cowl" && Grounded > world.time)
		. += glob.FEATHER_COWL_GROUNDED_POTENCY

//crit riders - fire after the strike resolves
/strikeHook/thunderHerald
	stage = "crit"
	fire(strike/S)
		var/mob/attacker = S.attacker
		if(attacker.AttackQueue || !attacker.passive_handler["ThunderHerald"])
			return
		var/obj/Skills/rider = attacker.findOrAddSkill(/obj/Skills/AutoHit/Thunder_Bolt)
		rider.adjust(attacker)
		attacker.Activate(rider)

/strikeHook/demonicInfusion
	stage = "crit"
	fire(strike/S)
		var/mob/attacker = S.attacker
		if(attacker.AttackQueue || !attacker.passive_handler["DemonicInfusion"])
			return
		var/obj/Skills/rider = attacker.findOrAddSkill(/obj/Skills/AutoHit/HellfireRain)
		rider.adjust(attacker)
		attacker.Activate(rider)

/strikeHook/reaperBlossom
	stage = "crit"
	fire(strike/S)
		var/mob/attacker = S.attacker
		if(attacker.AttackQueue || attacker.Class != "Reaper" || !prob(S.critChance/10))
			return
		var/obj/Skills/rider = attacker.findOrAddSkill(/obj/Skills/AutoHit/Blossom_Shower)
		rider.adjust(attacker)
		attacker.Activate(rider)
