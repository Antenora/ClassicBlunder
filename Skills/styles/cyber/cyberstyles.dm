/obj/Skills/Buffs/NuStyle/UnarmedStyle
	Gun_Cleric_Style
		SignatureTechnique=1
		CyberSignature=1
		Copyable=0
		StyleSpd = 1.15
		StyleFor = 1.3
		passives = list("CriticalChance" = 15, "CriticalDamage" = 0.1, \
						"SpecialStrike" = 1, "Gun Kata" = 1, "Instinct" = 2, "Flow" = 2)
		verb/Gun_Cleric_Style()
			set hidden=1
			src.Trigger(usr)
	Gun_Kata_Style
		SignatureTechnique=2
		CyberSignature=1
		Copyable=0
		StyleSpd = 1.3
		StyleFor = 1.3
		passives = list("CriticalChance" = 35, "CriticalDamage" = 0.15, \
						"SpecialStrike" = 1, "Gun Kata" = 1, "Instinct" = 2, "Flow" = 2)
		verb/Gun_Kata_Style()
			set hidden=1
			src.Trigger(usr)
	Equilibrium_Style
		SignatureTechnique=3
		CyberSignature=1
		Copyable=0
		StyleSpd = 1.5
		StyleFor = 1.5
		passives = list("CriticalChance" = 35, "CriticalDamage" = 0.3, \
						"SpecialStrike" = 1, "Gun Kata" = 1, "Instinct" = 2, "Flow" = 2)
		verb/Equilibrium_Style()
			set hidden=1
			src.Trigger(usr)
	Clockwork_Style
		SignatureTechnique=4
		CyberSignature=1
		Copyable=0
		StyleSpd = 2
		StyleFor = 2
		passives = list("CriticalChance" = 50, "CriticalDamage" = 0.5, \
						"SpecialStrike" = 1, "Gun Kata" = 1, "Instinct" = 2, "Flow" = 2)
		verb/Clockwork_Style()
			set hidden=1
			src.Trigger(usr)
	College_Ball_Style
		SignatureTechnique=1
		CyberSignature=1
		Copyable=0
		StyleStr=1.30
		StyleEnd=1.15
		passives = list("Fa Jin" = 2,"Acupuncture" = 1, "Flow" = 1, "Interception" = 1)
		StyleActive="College Ball Style"
		Finisher="/obj/Skills/Queue/Finisher/Dark_Dragon_Commandment"
		verb/College_Ball_Style()
			set hidden=1
			src.Trigger(usr)
	Overwhelming_Force
		SignatureTechnique=2
		CyberSignature=1
		Copyable=0
		StyleEnd=1.15
		StyleStr=1.45
		passives = list("DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 2, "HardStyle"=1, "Instinct"=2)
		StyleActive="Overwhelming Force Style"
		Finisher="/obj/Skills/Queue/Finisher/Mastery_of_Two_Layers"
		verb/Overwhelming_Force()
			set hidden=1
			src.Trigger(usr)


/obj/Skills/Buffs/NuStyle/SwordStyle