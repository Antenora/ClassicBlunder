obj/Skills/Buffs/ActiveBuffs/Hero
	FinnBuff
		sagaInfo = new/sagaInfo/finn
		NeedsSword = 1
		PULock = 1
		PowerMult=1.5
		SpdMult=1.3
		EndMult=1.2
		OffMult=1.3
		DefMult=1.2
		FatigueLeak = 0.5
		name = "Hero's Courage"
		BuffName = "Hero's Courage"
		ActiveMessage="brings out the heart of a hero!"
		OffMessage="represses their heroic spirit."

sagaInfo/finn
	choicePassives = list("2" = list("Instinct", "TechniqueMastery"), "4"= list("Flow", "MovementMastery"))
	perLevelPassives = list("ShonenPower" = 0.15) // 0.15 per tier
	specificPassives = list("3" = list("ShonenPower" = 0.2, "LifeSteal" = 0.05), \
	"4" = list("LifeSteal" = 0.1), "5" = list("ShonenPower" = 0.2), \
	"6" = list("Lifesteal" = 0.15), "7" = list("ShonenPower" = 0.2), \
	"8" = list("ShonenPower" = 0.4, "LifeSteal" = 0.2)) // 2 total at tier 8
	skillsPerTier = list("1" = "/obj/Skills/AutoHit/Mathematical_Dash", "2" = "/obj/Skills/Queue/High_Five_Dude", "3" = "/obj/Skills/AutoHit/Bombastic_Dive")



/mob/tierUpSaga(path)
	..()
	if(path == "Hero")
		var/pathh = "/obj/Skills/Buffs/ActiveBuffs/Hero/[HeroLegend]Buff"
		var/obj/Skills/Buffs/ActiveBuffs/Hero/buff = new pathh
		buff = locate() in src
		for(var/i in buff.sagaInfo.choicePassives)
			var/index = text2num(i)
			if(index == SagaLevel && buff.sagaInfo.chosenChoices[i] == null)
				var/choice = input("Choose a passive to learn!", "Choose a passive to learn!") in buff.sagaInfo.choicePassives[i]
				buff.sagaInfo.chosenChoices[i] = list("[choice]" = 1)
				src << "You have chosen to learn [choice]!"
		for(var/i in buff.sagaInfo.skillsPerTier)
			var/index = text2num(i)
			if(index == SagaLevel)
				var/paths = buff.sagaInfo.skillsPerTier[i]
				var/obj/Skills/AutoHit/skill = new paths
				AddSkill(skill)
	if(HeroLegend == "Finn")
		var/obj/Items/Sword/Medium/Legendary/FinnSword/fSword = new()
		fSword = locate() in src
		if(!fSword)
			fSword = new()
			fSword.Move(src)
			src<<"You have obtained the [fSword.name]!"
		if(fSword.suffix != "")
			fSword.ObjectUse(src)
		var/oldname = fSword.name
		fSword.Evolve(SagaLevel)
		if(oldname != fSword.name)
			src<<"Your [oldname] has evolved into [fSword.name]!"
