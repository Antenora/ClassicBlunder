/*
staggering auto buffs that get better and better up until the best being at 10%,
scaling with potential as well
*/


/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury
	AllOutAttack = 0
	Cooldown = -1
/obj/Skills/Buffs/SlotlessBuffs/Autonomous
	var/TooLittleHealth=0
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/adjust(mob/p)

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_One
	CustomActive = "<b><font color='red'>You felt something hovering close behind your head...</b></font>"
	OffMessage = "listlessly gazes forward, eyes starting to glaze over. Perhaps they are starting to understand, too."
	BuffName = "Hellborn Fury"
	//injury
	TooMuchInjury=15
	NeedsInjury=5
	TooLittleInjury=4
	EndMult = 1
	StrMult = 1
	adjust(mob/p)
		if(altered) return
		passives = list("CalmAnger" = 1, "Instinct" = 2, "PureDamage" = 2, "Persistence" = p.AscensionsAcquired/2, \
						"LikeWater" = 1 + round(p.Potential/25,1), "AbyssMod" = round(p.Potential/40,1), \
						"BleedHit"=1.5, "FavoredPrey" = "Depths", "SlayerMod"= 0.25*(p.AscensionsAcquired+1))
		StrMult = 1.15 + (p.Potential/150)
		ForMult = 1.15 + (p.Potential/150)
		OffMult = 1.15 + (p.Potential/200)
		PowerMult = 1.05 + (p.Potential/200)
		AutoAnger=0
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
		// gain oozaru, but in base

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Two
	CustomActive = "<b><font color='red'><font size=+1>You felt lightheaded. You saw golden stars...</b></font size></font color>"
	OffMessage = "is ever-silent, their blood starting to stick to the ground. Their self-image falters, but they know what they're doing. And they know why. <b>Do you?</b>"
	//injury
	TooMuchInjury=25
	NeedsInjury=15
	TooLittleInjury=14
	BuffName = "Hellspawn"
	adjust(mob/p)
		if(altered) return
		passives = list("CalmAnger" = 1, \
						"LikeWater" = 2 + round(p.Potential/25,1), "Flicker" = 1, "Pursuer" = 1, "PureDamage" = 2, "PureReduction" = 1, "HellPower" = 0.15, "Persistence" = p.AscensionsAcquired, \
						"Instinct" = 3, "AbyssMod" = round(p.Potential/30,1), "BleedHit"=0.75, "FavoredPrey" = "Depths","SlayerMod"= 0.25*(p.AscensionsAcquired+1))
		StrMult = 1.2 + (p.Potential/100)
		ForMult = 1.2 + (p.Potential/100)
		OffMult = 1.2 + (p.Potential/200)
		PowerMult = 1.075 + (p.Potential/200)
		AutoAnger=0
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Three
	CustomActive = "<b><font color='red'><font size=+1>Your vision narrows. ... The world revolves around you.</b></font size></font color>"
	OffMessage = "finally started acting like who they really are."
	//injury
	TooMuchInjury=40
	NeedsInjury=25
	TooLittleInjury=24
	BuffName = "True Hellspawn"
	adjust(mob/p)
		if(altered) return
		passives = list("CalmAnger" = 1, "BleedHit"=0.25,"PureReduction" = 2, \
						"LikeWater" = 2 + round(p.Potential/20,1),"SlayerMod"= 0.5*(p.AscensionsAcquired+1), "HellPower" = 0.4, "Persistence" = p.AscensionsAcquired, \
						"Powerhouse" = 1 + (p.Potential/75), "Instinct" = 4, "Flicker" = 2, "Pursuer" = 2, "PureDamage" = 2.5, "AbyssMod" = round(p.Potential/20,1), "FavoredPrey" = "Depths")
		StrMult = 1.25 + (p.Potential/75)
		ForMult = 1.25 + (p.Potential/75)
		OffMult = 1.25 + (p.Potential/75)
		PowerMult = 1.1 + (p.Potential/150)
		EnergyHeal = 0.005 * p.Potential
		AutoAnger=0
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Four
	CustomActive = "<b><font color='red'><font size=+1>Your heartbeat becomes twisted. You grow pale.</b></font size></font color>"
	OffMessage = "returns to who they once were, as if nothing happened. But you'll never see them the same way again, will you?"
	//injury
	NeedsInjury=41
	TooLittleInjury=40
	BuffName = "Herald of the Depths"
	adjust(mob/p)
		if(altered) return
		passives = list("CalmAnger" = 1, "LikeWater" = 2 + round(p.Potential/15,1),"SlayerMod"= 0.5*(p.AscensionsAcquired+1), "HellPower" = 0.65, \
						"Powerhouse" = 2 + (p.Potential/25), "Instinct" = 5, "Flicker" = 3, "Pursuer" = 3, "PureDamage" = 3, "AbyssMod" = round(p.Potential/15,1), "FavoredPrey" = "Beyond")
		StrMult = 1.25 + (p.Potential/50)
		ForMult = 1.25 + (p.Potential/50)
		OffMult = 1.25 + (p.Potential/50)
		PowerMult = 1.15 + (p.Potential/75)
		EnergyHeal = 0.01 * p.Potential
		AutoAnger=0
		if(prob(15)&&p.transUnlocked<2&&p.passive_handler.Get("Herald of the End"))
			p.passive_handler.Increase("The Clock Is Ticking", 0.5)
			p<<"<font color=red><b>You of all people should know how dangerous this power is. The clock is ticking, [p]...</font></b>"
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/HellbornFury/Stage_Five
	CustomActive = "<b><font color='red'><font size=+1>The darkness gives a long gaze, which slithered like a snake.</b></font size></font color>"
	OffMessage = "somehow manages to return to normal. Is it over?"
	//injury
	NeedsSSJ=2
	TooLittleHealth=0.1
	BuffName = "Bringer of the Calamity"
	adjust(mob/p)
		if(altered) return
		passives = list("EndlessAnger" = 1, "LikeWater" = 2 + round(p.Potential/15,1),"SlayerMod"= 0.5*(p.AscensionsAcquired+1),\
						"Powerhouse" = 2 + (p.Potential/25), "Instinct" = 5, "Flicker" = 5, "Pursuer" = 5, "PureDamage" = 5, "PureReduction" = 4, "AbyssMod" = round(p.Potential/15,1), "FavoredPrey" = "Beyond")
		StrMult = 1.25 + (p.Potential/50)
		ForMult = 1.25 + (p.Potential/50)
		OffMult = 1.25 + (p.Potential/50)
		PowerMult = 1.15 + (p.Potential/75)
		BioArmor=0
		AutoAnger=1
		Enlarge = 3
		DarkChange=1
		IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
		if(p.transUnlocked<2)
			passives = list("Unstoppable"=1, "EndlessAnger" = 1, "LikeWater" = 2 + round(p.Potential/15,1),"SlayerMod"= 0.5*(p.AscensionsAcquired+1),\
							"Powerhouse" = 2 + (p.Potential/25), "Instinct" = 5, "Flicker" = 5, "Pursuer" = 5, "PureDamage" = 5,"PureReduction" = 4, "AbyssMod" = round(p.Potential/15,1), "FavoredPrey" = "Beyond")
			Enlarge = 3
			DarkChange=1
			IconTint=list(0.15,0,0, 0.05,0.25,0.15, 0.05,0.05,0.35, 0,0,0)
			BioArmor=500
	Trigger(mob/User, Override=FALSE)
		adjust(User)
		..()


