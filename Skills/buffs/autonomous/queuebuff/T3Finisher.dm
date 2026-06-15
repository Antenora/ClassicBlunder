/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Intercepting_Fist
		passives = list("Relentlessness" = 1, "Fury" = 6, "Momentum" = 4, "BuffMastery" = 3,\
		                "StyleMastery" = 4, "Brutalize" = 2, "Interception" = 4, "CounterMaster" = 10,\
		                "BlurringStrikes" = 1,  "TensionLock" = 1)
		OffMult=1.5
		DefMult=1.5

	The_8th_Wonder_Of_The_World
		StyleNeeded = "All Star Wrestling"
		VaizardHealth = 5
		DefMult = 0.75
		SpdMult = 0.75
		StrMult = 1.75
		EndMult = 1.75
		passives = list("Muscle Power" = 4, "TechniqueMastery" = 5, "DeathField" = 7, \
		                "Juggernaut"= 5, "KBRes"= 5, "PureReduction" = 2, "GiantForm" = 1,  "TensionLock" = 1)

	Kensei
		StyleNeeded="Two Heavens As One"
		ManaGlow=rgb(255, 255, 255)
		ManaGlowSize=2
		passives = list("TensionLock" = 1,"CursedWounds" = 1, "PureDamage" = 5, "Instinct" = 4, "TechniqueMastery" = 3)
		HitSpark='Slash - Ragna.dmi'
		HitX=-32
		HitY=-32
		HitTurn=1
		ActiveMessage="ascends to become a Peerless Blade!"
		OffMessage="represses their nature as a Swordmaster..."

	Enten
		IconLock='SweatDrop.dmi'
		IconApart=1
		passives= list("Technique Mastery" = -6)
		ActiveMessage="has the core of their Techniques disrupted by the Peerless Blade's passing..."
		OffMessage="finds themselves again..."

	Judge_of_Heaven
		StyleNeeded="Fierce Diety"
		IconLock='EyesSage.dmi'
		IconLayer=4
		IconApart=1
		passives = list("Duelist" = 3, "Half-Sword" = 1, "Zornhau" = 1, "EndlessNine" = 0.25, "LifeGeneration" = 2, \
		               "KBRes" = 4, "Harden" = 3, "Unnerve" = 2, "Pressure" = 1, "TensionLock" = 1, "PureDamage"=2)
		StrMult=1.5
		EndMult=1.5
		VaizardHealth=2
		ActiveMessage="ascends to tear down the seat of the Heavens!"
		OffMessage="represses their nature as a Godslayer..."

	Justice_of_Hell
		IconLock='SweatDrop.dmi'
		IconApart=1
		passives = list("PureReduction" = -2, "Flow" = -2, "PureDamage" = -2, "Godspeed" = -2)
		CrippleAffected = 50
		SlowAffected = 50

	Infinite_Blades
		StyleNeeded="Acrobat"
		IconLock='Mist Veil.dmi'
		IconApart=1
		IconLayer=4
		passives = list("Tossing" = 4, "Mortal Will" = 1, "MortalStacks" = 1, "BlockChance" = 33, "CriticalBlock" = 0.3 , "Secret Knives" = "Blade_Addition",  \
		"TensionLock" = 1) // not sure
		StyleOff = 1.5
		StyleStr = 1.25
		StyleSpd = 1.5
		ActiveMessage="ascends to become a Whirlwind of Steel, Unending!"
		OffMessage="represses their nature as a Cornicopia of Steel..."

	Super_Shredded
		IconLock='Bleed.dmi'
		IconApart=1
		IconState="1"
		passives = list("PureReduction" = -2)
		HealthDrain = 0.025
		EndMult=0.75
		DefMult=0.75
		ActiveMessage="has been torn to shreds!"
		OffMessage="shakes off their damage."
	Bloodfury
		StrMult=1.75
		SpdMult=1.75
		EndMult=0.5
		AngerMult=1.25
		VaizardHealth=10
		passives = list("Flicker" = 2, "Pursuer" = 2, "PureDamage" = 2, "Instinct" = 2, \
		 "Speed Force" = 1 , "Sajire Rush" = 1, "Poisoning" = 5, "Enrage" = 1, "PureReduction" = -2)
	Radioactive
		passives = list("AfterImages" = 4, "Godspeed" = 4, "Speed Force" = 2, "Iaijutsu" = 1, "Rain" = 5,\
		"CriticalChance" = 20, "TensionLock" = 1)
		SpdMult=1.5
		StrMult=1.25
		EndMult=1.25
		TimerLimit = 20
		IconLock='SweatDrop.dmi'
		IconApart=1
	Final_Session
		passives = list("AfterImages" = 4, "Speed Force" = 2, "Iaijutsu" = 1, "Relentlessness" = 1, \
		                "Fury" = 4, "TripleStrike" = 0.5, "DoubleStrike" = 2, "Warping" = 2, "Momentum" = 1.5, \
		                "TensionLock" = 1, "Forever After" = 1)
		SpdMult=1.5
		StrMult=1.5
		IconLock='SweatDrop.dmi'
		IconApart=1
	Magnetism
		passives = list("BetterAim" = 3, , "Scorching" = 8, "Shattering" = 8, "Shocking" = 8, "Freezing" = 8)