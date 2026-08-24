/obj/Skills/Buffs/NuStyle/SwordStyle

	Way_of_the_Kensei
		SignatureTechnique = 4
		StyleOff=1.5
		StyleStr=1.5
		StyleSpd=1.5
		StyleDef=1.5
		Finisher="/obj/Skills/Queue/Finisher/Jinzen_Senkei"
		passives = list( "SwordAscension" = 6, "Sword Master" = 1, "SweepingStrike" = 1, "DoubleStrike" = 3,  \
			 "Half-Sword" = 2, "Rage" = 1, "TripleStrike" = 1, "Iaijutsu" = 8, "Musoken" = 1, "Fury" = 3, "Momentum" = 3, "Harden" = 3, \
			"Parry" = 3, "Disarm" = 2, "Deflection" = 2)
		StyleActive="Way of the Kensei"
		verb/Way_of_the_Kensei()
			set hidden=1
			src.Trigger(usr)
	Kyutoryu
		SignatureTechnique = 4
		StyleActive="Kyutoryu"
		StyleSpd=2.25
		StyleStr=1.75
		Finisher="/obj/Skills/Queue/Finisher/Demonic_Nine_Flashes"
		passives = list("AsuraStrike" = 1, "TripleStrike" = 2, "DoubleStrike" = 3, "Iaijutsu" = 5, \
			"Fury" = 5, "NeedsSecondSword" = 1, "NeedsThirdSword" = 1,  "SweepingStrike" = 1, \
			"Iaijutsu" = 3, "Disarm" = 3, "Parry" = 3, "Fury" = 5)
		verb/Kyutoryu()
			set hidden=1
			src.Trigger(usr)
	Alpha_inForce
		SignatureTechnique = 4
		StyleActive="Alpha inForce"
		StyleStr=1.5
		StyleFor=1.5
		StyleEnd=1.25
		StyleOff=1.25
		StyleSpd=1.25
		passives = list("Knight of the Empty Seat" = 1, "HybridStyle" = "MysticStyle", "CriticalDamage"= 0.15,   "SweepingStrike" = 1, \
			"MovingCharge"= 1, "TripleStrike" = 1, "DoubleStrike" = 2, "Momentum" = 2, "Parry" = 2, "Deflection" = 2,  "QuickCast" = 5, "ManaSteal" = 25, "ManaGeneration" = 5)
		Finisher = "/obj/Skills/Queue/Finisher/Seiken_Gradalpha"
		verb/Alpha_inForce()
			set hidden=1
			src.Trigger(usr)
	Ulforce
		SignatureTechnique = 4
		StyleActive="Ulforce"
		StyleSpd=3
		passives = list("HotHundred" = 1, "SweepingStrike"= 1, "Warping" = 5, "Godspeed" = 4, "Skimming" = 2, "AfterImages" = 4, "Speed Force" = 2)
		Finisher = "/obj/Skills/Queue/Finisher/Shining_V_Force"
		verb/Ulforce()
			set hidden=1
			src.Trigger(usr)
	War_God
		SignatureTechnique = 4
		StyleActive="Kratos"
		StyleOff=1.5
		StyleStr=2
		StyleEnd=1.5
		Finisher="/obj/Skills/Queue/Finisher/The_Blade_of_Chaos"
		passives = list("DisableGodKi" = 1, "Rage" = 5, "Half-Sword" = 5, \
			"Shearing" = 10, "Deflection" = 5, "Disarm" = 3,"Parry" = 5, "Momentum" = 5, \
			"Secret Knives" = "GodSlayer", "Tossing" = 5,   "BladeFisting" = 1, "Extend" = 2)
		// either throw swords at them, or runes, depending on icon_state do a different effect
		adjust(mob/p)
			passives = list("DisableGodKi" = 1, "Rage" = 5, "Half-Sword" = 5, \
				"Shearing" = 10, "Deflection" = 5, "Disarm" = 3,"Parry" = 5, "Momentum" = 5, \
				"Secret Knives" = "GodSlayer", "Tossing" = 5,   "BladeFisting" = 1, "Extend" = 2)
		verb/War_God()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Nebula_Blade
		SignatureTechnique=4
		passives = list("HybridStyle" = "MysticStyle", "Wuju" = 1, "CriticalDamage"= 0.05, "Shocking" = 4, "ThunderHerald" = 1, \
			"Flicker" = 1, "Fury" = 2.5, "Iaijutsu" = 4,   "Combustion" = 40, "Scorching" = 5)
		StyleSpd = 1.5
		StyleFor = 1.75
		StyleStr = 1.75
		ElementalOffense = "Wind"
		StyleActive="Nebula_Blade"
		Finisher="/obj/Skills/Queue/Finisher/Stellar_Formation"
		verb/Nebula_Blade()
			set hidden=1
			Trigger(usr)
	Hearts_Beating_As_One
		SignatureTechnique=4
		StyleActive="Final Form!!!!"
		StyleStr = 1.5
		StyleFor = 1.75
		StyleEnd = 1.75
		ElementalOffense = "Chaos"
		passives = list("HybridStyle" = "MysticStyle", "Heavy Strike" = "ChaosBlaster", "CriticalDamage"= 0.15,   \
					"Secret Knives" = "GodSlayer", "MovingCharge"=1, "Tossing"=2, "BladeFisting"= 1, "Extend" = 1, "Gum Gum" = 1)
		Finisher="/obj/Skills/Queue/Finisher/Hyper_Goner_Two"
		adjust(mob/p)
			passives = list("HybridStyle" = "MysticStyle", "Heavy Strike" = "ChaosBlaster", "CriticalDamage"= 0.15,   \
					"Secret Knives" = "GodSlayer", "MovingCharge"=1, "Tossing"=2, "BladeFisting"= 1, "Extend" = 1, "Gum Gum" = 1)
		verb/Hearts_Beating_As_One()
			set hidden=1
			adjust(usr)
			Trigger(usr)
