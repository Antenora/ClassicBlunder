/obj/Skills/Buffs/NuStyle/UnarmedStyle
	God_Fist
		SignatureTechnique = 4
		StyleActive="God Fist"
		StyleEnd = 1.5
		StyleDef = 1.5
		StyleSpd = 1.5
		StyleStr = 1.5
		Finisher="/obj/Skills/Queue/Finisher/The_Big_Bang_Punch"
		passives = list("LikeWater" = 4, "Fa Jin" = 3, "Interception" = 3, "Sunyata" = 5 , "Gum Gum" = 2, "Acupuncture" = 2, \
						"Flow" = 2, "Instinct" = 2, "Momentum" = 3, "Harden" = 2, "Pressure" = 3, "HardStyle" = 1, \
						"FluidForm" = 4, "DoubleStrike" = 2)
		verb/God_Fist()
			set hidden=1
			src.Trigger(usr)
	Ten_Directions
		SignatureTechnique = 4
		StyleActive="Ten Directions"
		passives = list("Iaido"=8, "Flying Thunder God" = 1, "BlurringStrikes" = 3, "Fury" = 3, "Fa Jin" = 2, "Instinct" = 2, "Secret Knives" = "FTG", "Tossing" = 3, \
		"BladeFisting" = 1, "NeedsSword" = 0, "NoSword" = 1, "Interception" = 3, "Sunyata" = 3, "LikeWater" = 5, "SoftStyle" = 1,"Flow" = 4, "Godspeed" = 3, "Skimming" = 2)
		Finisher="/obj/Skills/Queue/Finisher/Hyakuretsu_Ken"
		StyleSpd = 2.25
		StyleOff = 1.5
		StyleStr = 1.25
		adjust(mob/p)
			passives = list("Iaido" = 8, "Flying Thunder God" = 1, "BlurringStrikes" = 3, "Fury" = 3, "Fa Jin" = 2, "Instinct" = 2, "Secret Knives" = "FTG", "Tossing" = 3, \
			"BladeFisting" = 1, "NeedsSword" = 0, "NoSword" = 1, "Interception" = 3, "Sunyata" = 3, "LikeWater" = 5, "SoftStyle" = 1,"Flow" = 4, "Godspeed" = 3, "Skimming" = 2)
		verb/Ten_Directions()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Giga_Galaxy_Wrestling
		SignatureTechnique = 4
		StyleActive="Giga Galaxy Wrestling"
		StyleEnd = 2
		StyleStr = 2
		Finisher="/obj/Skills/Queue/Finisher/Stone_Cold_Stunner"
		passives = list("Heavy Strike" = "Wrestling", "Muscle Power" =8, "Grippy" = 7, \
		"Scoop" = 5, "DeathField" = 5, "Gum Gum" = 3, "Harden" = 4, \
		"Momentum" = 4, "CallousedHands"=0.15)
		verb/Giga_Galaxy_Wrestling()
			set hidden=1
			src.Trigger(usr)
	High_Roller// mystic+unarmed
		SignatureTechnique=4
		Copyable=0
		StyleStr=1.75
		StyleFor=1.75
		StyleEnd=1.5
		StyleActive="High Roller"
		passives = list("HybridStyle" = "MysticStyle","Fury" = 2, "Momentum" = 2,  "Harden" = 2, "SpiritHand" = 2, "Instinct" = 2, \
							"Flow" = 2, "SpiritFlow" = 2, "Combustion" = 50, "Scorching" = 6, "Shattering" = 5)
		Finisher="/obj/Skills/Queue/Finisher/Jackpot"
		adjust(mob/p)
			passives = list("HybridStyle" = "MysticStyle","Fury" = 4, "Momentum" = 4,  "Harden" = 2, "SpiritHand" = 4, "Instinct" = 2, \
							"Flow" = 2, "SpiritFlow" = 2, "Combustion" = 50, "Scorching" = 6, "Shattering" = 5, "HardStyle" = 1)
		verb/High_Roller_Style()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
