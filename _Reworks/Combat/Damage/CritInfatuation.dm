/globalTracker/var/
	BLOCK_CHANCE_CAP = 40;
	CRIT_BLOCK_CAP = 0.2;
	CRITICAL_CHANCE_CAP = 40;
	CRIT_DMG_CAP = 0.2;
	MARTIAL_CRIT_CHANCE_BONUS = 5;
	MARTIAL_CRIT_CHANCE_SCALING = 2.5;
	MARTIAL_CRIT_DMG_BONUS = 0.1;
	MARTIAL_CRIT_DMG_SCALING = 0.05;

/mob/proc/getInfatuation(mob/defender)
	for(var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/buff in src)
		if(buff.passives["Infatuated"]&&buff.Password == defender?:UniqueID)
			return 1+buff.passives["Infatuated"]
	return 1

/mob/proc/getCritChance()
	. = passive_handler.Get("CriticalChance");
	. = min(glob.CRITICAL_CHANCE_CAP, .);
	var/denkoCharge = DenkoSekkaCharged
	if(denkoCharge)
		. += denkoCharge * glob.DENKO_SEKKA_CRIT_CHANCE_PER_LEVEL
		DenkoSekkaCharged = 0
	if(passive_handler["Determination(Red)"]||passive_handler["Determination(White)"])
		. += (ManaAmount/4)
	var/martialStyle = usingStyle("UnarmedStyle")
	if(martialStyle)
		if(Saga && SagaLevel)
			. += (glob.MARTIAL_CRIT_CHANCE_BONUS + (glob.MARTIAL_CRIT_CHANCE_SCALING * SagaLevel))
		else 
			. += (glob.MARTIAL_CRIT_CHANCE_BONUS + (glob.MARTIAL_CRIT_CHANCE_SCALING * StyleBuff.SignatureTechnique))

/mob/proc/getCritDmg()
	. = passive_handler.Get("CriticalDamage");
	. = min(glob.CRIT_BLOCK_CAP, .);
	var/denkoCharge = DenkoSekkaCharged
	if(denkoCharge)
		. += denkoCharge * glob.DENKO_SEKKA_CRIT_DAMAGE_PER_LEVEL
	var/martialStyle = usingStyle("UnarmedStyle")
	if(martialStyle)
		if(Saga && SagaLevel)
			. += (glob.MARTIAL_CRIT_DMG_BONUS + (glob.MARTIAL_CRIT_DMG_SCALING * SagaLevel))
		else 
			. += (glob.MARTIAL_CRIT_DMG_BONUS + (glob.MARTIAL_CRIT_DMG_SCALING * StyleBuff.SignatureTechnique))

/mob/proc/getBlockChance()
	. = passive_handler.Get("BlockChance");
	. = min(glob.BLOCK_CHANCE_CAP, .);
	if(Class == "Feather Cowl" && Grounded>world.time) . += glob.BLOCK_CHANCE_CAP;
	var/martialStyle = usingStyle("UnarmedStyle")
	if(martialStyle)
		if(Saga && SagaLevel)
			. += (glob.MARTIAL_CRIT_CHANCE_BONUS + (glob.MARTIAL_CRIT_CHANCE_SCALING * SagaLevel));
		else 
			. += (glob.MARTIAL_CRIT_CHANCE_BONUS + (glob.MARTIAL_CRIT_CHANCE_SCALING * StyleBuff.SignatureTechnique));
	if(passive_handler["Determination(Red)"] && ManaAmount>=75||passive_handler["Determination(White)"] && ManaAmount>=75)
		if(SagaLevel<4||RebirthHeroType=="Red")
			. += (ManaAmount/100)
		else
			if(ManaAmount<98)
				. += (ManaAmount/150)
			if(ManaAmount>=98)
				. += (ManaAmount/33)

/mob/proc/getBlockDmg()
	. = passive_handler.Get("CriticalBlock");
	. = min(glob.CRIT_BLOCK_CAP, .);
	if(Class == "Feather Cowl" && Grounded>world.time) . += glob.CRIT_BLOCK_CAP;
	var/martialStyle = usingStyle("UnarmedStyle")
	if(martialStyle)
		if(Saga && SagaLevel)
			. += (glob.MARTIAL_CRIT_DMG_BONUS + (glob.MARTIAL_CRIT_DMG_SCALING * SagaLevel));
		else 
			. += (glob.MARTIAL_CRIT_DMG_BONUS + (glob.MARTIAL_CRIT_DMG_SCALING * StyleBuff.SignatureTechnique));

/mob/proc/getCritAndBlock(mob/defender, damage)
	var/critChance = getCritChance();
	var/critDMG = getCritDmg()
	var/blockChance = 0;
	var/critBlock = 0;

	if(defender)
		blockChance = defender.getBlockChance();
		critBlock = defender.getBlockDmg();

	var/didCrit = prob(critChance)
	if(didCrit)
		if(!AttackQueue)
			if(passive_handler["ThunderHerald"])
				var/obj/Skills/s = findOrAddSkill(/obj/Skills/AutoHit/Thunder_Bolt)
				s.adjust(src)
				Activate(s)
			if(passive_handler["IceHerald"])
				var/obj/Skills/s = findOrAddSkill(/obj/Skills/AutoHit/Icy_Wind)
				s.adjust(src)
				Activate(s)
			if(passive_handler["DemonicInfusion"])
				var/obj/Skills/s = findOrAddSkill(/obj/Skills/AutoHit/HellfireRain)
				s.adjust(src)
				Activate(s)
			if(src.Class=="Reaper")
				if(prob(critChance/10))
					var/obj/Skills/s = findOrAddSkill(/obj/Skills/AutoHit/Blossom_Shower)
					s.adjust(src)
					Activate(s)
		if(passive_handler["Determination(Red)"] && ManaAmount>=75||passive_handler["Determination(White)"] && ManaAmount>=75)
			if(SagaLevel<4||RebirthHeroType=="Red")
				if(SagaLevel==3&&!passive_handler["UnleashToggle"])
					var/obj/Skills/s = findOrAddSkill(/obj/Skills/AutoHit/Unleash)
					s.adjust(src)
					Activate(s)
				ManaAmount=0
			if(SagaLevel>=4&&RebirthHeroType!="Red")
				if(ManaAmount>=98)
					if(!passive_handler["UnleashToggle"])
						var/obj/Skills/s = findOrAddSkill(/obj/Skills/AutoHit/Unleash)
						s.adjust(src)
						Activate(s)
					if(SagaLevel<5)
						ManaAmount=0
					if(SagaLevel>=5&&ManaAmount>=150)
						ManaAmount-=50
		damage *= 1+critDMG
	if(prob(blockChance))
		damage /= 1+critBlock
	return damage
