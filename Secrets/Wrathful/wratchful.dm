/*
staggering auto buffs that get better and better up until the best being at 10%,
scaling with potential as well
*/


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful
	AllOutAttack = 0
	Cooldown = -1
	HealthDrain = 0.01
	CantTrans = FALSE
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/adjust(mob/p)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_One
	ActiveMessage = "harnesses their primal form to increase their rage."
	OffMessage = "further degrades into a more primal state."
	NeedsHealth = 90
	TooMuchHealth = 91
	HealthThreshold = 75
	Enlarge = 1.5
	BuffName = "Wrath Form"
	HealthDrain = 0.008
	EndMult = 1
	StrMult = 1
	GiantForm = 1
	AutoAnger = 1
	adjust(mob/p)
		if(altered) return
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Harden" = round(p.Potential/35,1), "Instinct" = 1, "Flow" = 1, \
						"LikeWater" = 1 + round(p.Potential/25,1), "Meaty Paws" = round(p.Potential/20,1))
		switch(p.oozaru_type)
			if("Wrathful")
				StrMult = 1.4
				EndMult = 1.4
				ForMult = 1.3
			if("Enlightened")
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
			if("Instinctual")
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
		EndMult += (p.Potential/250)
		StrMult += (p.Potential/250)
		ForMult += (p.Potential/250)
		DefMult = clamp(0.75 + (p.Potential/250),0.75,1)
		SpdMult = clamp(0.75 + (p.Potential/250),0.75,1)
		OffMult = 1.2 + p.Potential/250
		HealthDrain = 0.007 - (p.Potential * 0.000025)
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
		// gain oozaru, but in base

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Two
	ActiveMessage = "continues to degrade into a more primal state."
	OffMessage = "fails to keep control of their power."
	NeedsHealth = 75
	TooMuchHealth = 76
	HealthThreshold = 50
	Enlarge = 1.5
	AutoAnger = 1
	BuffName = "Wrathful"
	adjust(mob/p)
		if(altered) return
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Harden" = round(p.Potential/25,1), "DemonicDurability" = round(p.Potential/30,1), \
						"LikeWater" = 2 + round(p.Potential/25,1), "Flicker" = 1, "Pursuer" = 1, "PureDamage" = 0.5, "PureReduction" = 0.5, \
						"Meaty Paws" = round(p.Potential/20,1), "Instinct" = 2, "Flow" = 2 )
		switch(p.oozaru_type)
			if("Wrathful")
				StrMult = 1.4
				EndMult = 1.4
				ForMult = 1.3
			if("Enlightened")
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
			if("Instinctual")
				StrMult = 1.2
				ForMult = 1.2
				EndMult = 1.2
		EndMult += (p.Potential/150)
		StrMult += (p.Potential/150)
		ForMult += (p.Potential/150)
		PowerMult = 1 + (p.Potential/200)
		HealthDrain = 0.009 - (p.Potential * 0.000025)
		AngerMult = 1 + (p.Potential/150)
		if(p.Potential>=100)
			passives["Wrathful"] = 1
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Three
	ActiveMessage = "'s power flows out, in an almost uncontrollable manner!"
	OffMessage = "has lost control of their power!"
	NeedsHealth = 50
	TooMuchHealth = 51
	HealthThreshold = 15
	AutoAnger = 1
	Enlarge = 2
	BuffName = "Chou Wrathful"
	adjust(mob/p)
		if(altered) return
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Harden" = round(p.Potential/10,1), "DemonicDurability" = round(p.Potential/50,1), "AngerAdaptiveForce" = round(p.Potential/200), \
						"Powerhouse" = 1 + (p.Potential/75), "Instinct" = 3, "Flow" = 3, "Flicker" = 2, "Pursuer" = 2, "PureDamage" = 1, "PureReduction" = 1)
		EndMult = 1 + (p.Potential/125)
		StrMult = 1 + (p.Potential/125)
		ForMult = 1 + (p.Potential/125)
		AngerMult = 1 + (p.Potential/100)
		EnergyHeal = 0.005 * p.Potential
		HealthDrain = 0.018 - (p.Potential * 0.00005)
		VaizardHealth = (10 * (p.Potential/100))
		if(p.Potential>=75)
			passives["Wrathful"] = 1
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Four
	ActiveMessage = "'s power seeps from their very being, leaking out like an endless supply!"
	OffMessage = "'s rage has been quelled.'"
	NeedsHealth = 15
	TooMuchHealth = 16
	Enlarge = 2
	AutoAnger = 1
	BuffName = "Full Power Chou Wrathful"
	adjust(mob/p)
		if(altered) return
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Harden" = round(p.Potential/5,1), "DemonicDurability" = round(p.Potential/25,1), "AngerAdaptiveForce" = round(p.Potential/200), \
						"Powerhouse" = 2 + (p.Potential/25), "Instinct" = 4, "Flow" = 4, "Flicker" = 3, "Pursuer" = 3, "BuffMastery" = 3, "PureDamage" = 1.5, "PureReduction" = 1.5)
		EndMult = 1 + (p.Potential/100)
		StrMult = 1 + (p.Potential/100)
		ForMult = 1 + (p.Potential/100)
		HealthDrain = 0.015 - (p.Potential * 0.000016)
		EnergyHeal = 0.01 * p.Potential
		AngerMult = 1 + (p.Potential/100)
		VaizardHealth = (10 * (p.Potential/100))
		if(p.Potential>=50)
			passives["Wrathful"] = 1
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()


/mob/Admin3/verb/Give_Rare_Saiyan()
	set category = "Admin"
	set name = "Give Rare Saiyan"
	var/mob/p = input(src, "Who?", "Give Rare Saiyan") in players
	if(!p) return
	var/choice = input(usr, "Which rare saiyan for [p]?", "Give Rare Saiyan") as null|anything in list("Hellspawn", "Heavenborn", "Legendary", "Wrathful", "Cancel")
	if(!choice || choice == "Cancel") return
	switch(choice)
		if("Hellspawn")
			p << "You have been given the Hellspawn buff."
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_One)
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Two)
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Three)
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Four)
			p.passive_handler.Increase("HellPower", 0.1)
			p.passive_handler.Increase("Persistence", 2)
			p.passive_handler.Increase("MaimMastery", 1)
			p.AddSkill(new/obj/Skills/False_Moon)
			p.oozaru_type = "Demonic"
			for(var/transformation/saiyan/ssj in p.race.transformations)
				p.race.transformations -= ssj
				del ssj
			p.race.transformations += new /transformation/saiyan/hellspawn_super_saiyan()
			p.race.transformations += new /transformation/saiyan/hellspawn_super_saiyan_2()
			p.race.transformations += new /transformation/saiyan/hellspawn_super_full_power_saiyan_2_limit_breaker()
		if("Heavenborn")
			p << "You are now a Heavenborn Saiyan."
			for(var/transformation/saiyan/ssj in p.race.transformations)
				p.race.transformations -= ssj
				del ssj
			p.race.transformations += new /transformation/saiyan/heavenborn_super_saiyan()
			p.race.transformations += new /transformation/saiyan/super_saiyan_rose()
			p.Secret="Heavenborn"
		if("Legendary")
			p << "You have become a Legendary Super Saiyan."
			p.AddSkill(new/obj/Skills/Buffs/NuStyle/Legendary/Legendary_Stance)
			p.passive_handler.Increase("Fabled King", 1)
			p.passive_handler.Increase("True Inheritor", 1)
			p.passive_handler.Increase("Duren", 1)
			p.AngerMessage = "grasps the sun."
		if("Wrathful")
			p << "You have been given the Wrathful buff."
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_One)
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Two)
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Three)
			p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Four)
