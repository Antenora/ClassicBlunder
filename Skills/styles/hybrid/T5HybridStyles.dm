/obj/Skills/Buffs/NuStyle/UnarmedStyle
	The_Fourth_Fate
		SignatureTechnique = 4
		SagaSignature = 1
		StyleOff=3
		StyleStr=3
		StyleSpd=3
		StyleDef=3
		OurFuture=1
		NeedsSword=0
		NoSword=0
		Finisher="/obj/Skills/Queue/Finisher/Grasp_Tomorrow"
		passives = list("Determination(Black)" = 1, "Determination(White)" = 1, "BladeFisting" = 1, "MagicSword" = 1, "MartialMagic" = 1, "ManaGeneration" = 5 ,"EnergyGeneration" = 5, \
		"MovementMastery" = 20, "PureDamage"=10, "PureReduction" = 10, "SweepingStrike" = 1, "Extend" = 2, "Gum Gum" = 2, "SpiritFlow" = 4, "Skimming" = 3, "Godspeed" = 3, \
		"Our Future" = 1, "The Legend of REBIRTH" = 1)
		StyleActive="The Fourth Fate"
		verb/The_Fourth_Fate()
			set hidden=1
			src.Trigger(usr)