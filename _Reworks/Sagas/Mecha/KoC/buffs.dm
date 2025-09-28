/obj/Skills/Buffs/SpecialBuff/King_Of_Courage
	var/sagaInfo/sagaInfo = new/sagaInfo/courage
	Cooldown = 0
	PowerGlows = rgb(17, 169, 62)
	ActiveMessage = "encases their body with their willpower!"
	OffMessage = "dismisses their willpower..."

	adjust(mob/p)
		var/piloting = p.Intelligence * p.passive_handler.Get("PilotingProwess") // 2 * 7.5 max
		var/sLevel = p.SagaLevel
		var/mult = clamp((0.05 * piloting) * sLevel, 0.05, 1)
		OffMult = 1 + mult
		DefMult = 1 + mult
		Intimidation = 1 + sLevel/6
		if(sagaInfo.choicesPaths["1"] == "Endless Evolution" && sLevel>=2)
			switch(sagaInfo.pathsPicked)
				if("Overwhelming Force")
					ForMult = 1.2 + (0.1 * sLevel)
					SpdMult = 1.3 + (0.05 * sLevel)
					EndMult = 1 - (0.066 * sLevel)
					passives["WeaponBreaker"] = 1
					passives["HardStyle"] = 0
					passives["Flow"] = 0
				if("Unstoppable Strength")
					StrMult = 1.2 + (0.1 * sLevel)
					SpdMult = 1.1 + (0.05 * sLevel)
					EndMult = 1 - (0.033 * sLevel)
					passives["HardStyle"] = 1
					passives["WeaponBreaker"] = 0
					passives["Flow"] = 0
				if("Peerless Agility")
					StrMult = 1 + (0.05 * sLevel)
					ForMult = 1 + (0.05 * sLevel)
					SpdMult = 1.3 + (0.1 * sLevel)
					EndMult = 1 - (0.066 * sLevel)
					passives["Flow"] = 1
					passives["HardStyle"] = 0
					passives["WeaponBreaker"] = 0
	verb/Courageous_Giga_Guard()
		set category = "Skills"
		if(!usr.BuffOn(src))
			adjust(usr) // we will run into fuckery with the swapping for sure
		src.Trigger(usr)
	


// Endless Evolution
/obj/Skills/Buffs/SlotlessBuffs/Plot_Armor // True Effort + 
	Copyable=0
	ManaCost=30
	passives = list("Instinct" = 1, "Pursuer" = 1, "NoDodge" = 1)
	VaizardHealth = 10
	TextColor=rgb(63, 241, 111)
	ActiveMessage="exerts their will power to encase themselves with plot armor!"
	OffMessage="isn't able to keep up their deception..."
	TimerLimit=20
	Cooldown=80
	verb/Plot_Armor()
		set category="Skills"
		src.Trigger(usr)
/obj/Skills/Buffs/SlotlessBuffs/Veiled_Reality // drain DeM when at 50% to gain a part of its power now
	ResourceCost = list("Deus Ex Machina", 1/2)
	verb/Libera_Me_From_Hell()
		set category = "Skills"

/obj/Skills/Buffs/SlotlessBuffs/Evolve // regen + verb to change paths

