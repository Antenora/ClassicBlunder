/obj/Skills/Buffs/NuStyle/SwordStyle
	Two_Heaven_As_One
		SignatureTechnique = 3
		StyleActive="Two Heavens As One"
		StyleOff=1.25
		StyleStr=1.25
		StyleEnd=1.25
		StyleDef=1.25
		passives = list("The Way" = 1, "Sword Master" = 1, "LikeWater" = 4, "SweepingStrike" = 1, "DoubleStrike" = 2, "BlurringStrikes" = 1, \
		            "Zornhau" = 2, "Half-Sword" = 2, "Rage" = 1, "TripleStrike" = 0.5, "Iaijutsu" = 3, "Musoken" = 1, "Fury" = 2.5, \
		            "Parry" = 2.5, "Disarm" = 2, "Deflection" = 1)
		Finisher="/obj/Skills/Queue/Finisher/Clear_Water"
		verb/Two_Heaven_As_One()
			set hidden=1
			src.Trigger(usr)
	Acrobat
		SignatureTechnique = 3
		passives = list("DoubleStrike" = 2.5, "TripleStrike" = 1, "BlurringStrikes" = 1.5, "SweepingStrike" = 1,\
			"Deflection" = 1, "NeedsSecondSword" = 1, "NeedsThirdSword" = 1,  "Parry" = 2.5, "Iaijutsu" = 4, "Disarm" = 3,\
			"Unnerve" = 2, "Fury" = 4)
		NeedsSecondSword = 1
		StyleActive="Acrobat"
		StyleSpd=1.5
		StyleOff=1.25
		StyleStr=1.25
		NeedsThirdSword = 1
		Finisher="/obj/Skills/Queue/Finisher/Jumbled_Line_Up"
		verb/Acrobat()
			set hidden=1
			src.Trigger(usr)
	Tenken
		SignatureTechnique = 3
		Copyable=0
		StyleSpd=1.65
		StyleOff=1.35
		StyleActive="Tenken"
		passives = list("HybridStyle" = "UnarmedStyle", "Fury" = 2, "BlurringStrikes" = 2, "SweepingStrike" = 1, "BladeFisting" = 1, \
				"Iaijutsu" = 3, "Musoken" = 1, "CriticalChance" = 30, "CriticalDamage"= 0.1, "Extend" = 1, "Instinct" = 2, "Godspeed" = 3)
		Finisher="/obj/Skills/Queue/Finisher/Gatotsu_Rokujin"
		verb/Tenken()
			set hidden=1
			src.Trigger(usr)
	Fierce_Deity
		SignatureTechnique = 3
		StyleOff=1.25
		StyleStr=1.5
		StyleEnd=1.25
		StyleActive="Fierce Diety"
		passives = list("DisableGodKi" = 1, "Deicide" = 4, "Rage" = 2, "Half-Sword" = 2.5, "Zornhau" = 2.5, "FavoredPrey" = "Secret", "SlayerMod" = 4 , "Shearing" = 8, \
		"BladeFisting" = 1, "Secret Knives" = "Stake", "Tossing" = 3, "Parry" = 3,"Disarm" = 3,\
		"Harden" = 2, "Deflection" = 1, "EndlessNine" = 0.1, "Extend" = 2)
		Finisher="/obj/Skills/Queue/Finisher/Divine_Wrath"
		verb/Fierce_Deity()
			set hidden=1
			src.Trigger(usr)

//MAKE CONFIG TO GIVE PEOPLE GODKI IF THEY HAVE T3 STYLES
