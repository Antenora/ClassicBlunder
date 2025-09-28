/*
staggering auto buffs that get better and better up until the best being at 10%, 
scaling with potential as well
*/


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful
	AllOutAttack = 0
	Cooldown = -1
	HealthDrain = 0.01
	CantTrans = TRUE
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
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Hardening" = round(p.Potential/35,1), "Instinct" = 1, "Flow" = 1, \
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
		EndMult += (p.Potential/200)
		StrMult += (p.Potential/200)
		ForMult += (p.Potential/200)
		DefMult = clamp(0.75 + (p.Potential/200),0.75,1)
		SpdMult = clamp(0.75 + (p.Potential/200),0.75,1)
		OffMult = 1.2 + p.Potential/200
		HealthDrain = 0.007 - (p.Potential * 0.00005)
		PowerMult = 1 + (p.Potential/200)
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
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Hardening" = round(p.Potential/25,1), "DemonicDurability" = round(p.Potential/30,1), \
						"LikeWater" = 2 + round(p.Potential/25,1), "Flicker" = 1, "Pursuer" = 1,  "BuffMastery" = 1.5, "PureDamage" = 0.5, "PureReduction" = 0.5, \
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
		HealthDrain = 0.009 - (p.Potential * 0.00005)
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
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Hardening" = round(p.Potential/10,1), "DemonicDurability" = round(p.Potential/15,1), "AngerAdaptiveForce" = round(p.Potential/100), \
						"Powerhouse" = 1 + (p.Potential/75), "Instinct" = 3, "Flow" = 3, "Flicker" = 2, "Pursuer" = 2, "BuffMastery" = 2, "PureDamage" = 1, "PureReduction" = 1)
		EndMult = 1 + (p.Potential/75)
		StrMult = 1 + (p.Potential/75)
		ForMult = 1 + (p.Potential/75)
		PowerMult = 1 + (p.Potential/150)
		AngerMult = 1 + (p.Potential/100)
		EnergyHeal = 0.005 * p.Potential
		HealthDrain = 0.011 - (p.Potential * 0.00005)
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
		passives = list("GiantForm" = 1, "AutoAnger" = 1, "Hardening" = round(p.Potential/5,1), "DemonicDurability" = round(p.Potential/10,1), "AngerAdaptiveForce" = round(p.Potential/100), \
						"Powerhouse" = 2 + (p.Potential/25), "Instinct" = 4, "Flow" = 4, "Flicker" = 3, "Pursuer" = 3, "BuffMastery" = 3, "PureDamage" = 1.5, "PureReduction" = 1.5)
		EndMult = 1 + (p.Potential/50)
		StrMult = 1 + (p.Potential/50)
		ForMult = 1 + (p.Potential/50)
		PowerMult = 1 + (p.Potential/75)
		HealthDrain = 0.015 - (p.Potential * 0.00008)
		EnergyHeal = 0.01 * p.Potential
		AngerMult = 1 + (p.Potential/50)
		VaizardHealth = (10 * (p.Potential/100)) 
		if(p.Potential>=50)
			passives["Wrathful"] = 1
	Trigger(mob/User, Override=FALSE)
		adjust(User) 
		..()


/mob/Admin3/verb/GiveWrathful()
	var/mob/p = input(src, "Who?") in players
	p << "You have been given the Wrathful buff."
	p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_One)
	p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Two)
	p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Three)
	p.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Wrathful/Stage_Four)
