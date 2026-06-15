obj/Skills/Buffs/NuStyle/NobodyLegendary
	CyberSignature = 1
	Legacy_of_Ashes // T0/1. This is based on the Legendary styles from last wipe. Fire/Sword
		SignatureTechnique=1
		NeedsSword = 1
		Copyable=0
		StyleSpd=1.3
		StyleStr=1.15
		ElementalOffense="Fire"
		ElementalDefense="Fire"
		passives = list("BlurringStrikes" = 1, "Godspeed" = 1, "Momentum" = 1, "DoubleStrike" = 1, "Instinct" = 2, "Iaijutsu" = 2,\
						"Musoken" = 1, "Kindling" = 0.5, "Combustion" = 30, "Parry" = 2,"Ashen One" = 1)
		StyleActive="Legacy of Ashes"
		Finisher="/obj/Skills/Queue/Finisher/Session"
		verb/Legacy_of_Ashes()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Sunslammer
		SignatureTechnique=2
		NeedsSword = 1
		Copyable=0
		StyleSpd=1.3
		StyleStr=1.3
		ElementalOffense="Fire"
		ElementalDefense="Fire"
		passives = list("BlurringStrikes" = 1, "Godspeed" = 2, "Momentum" = 1, "DoubleStrike" = 2, "Instinct" = 3, "Flow" = 2, "Iaijutsu" = 2,\
						"Musoken" = 1, "Kindling" = 0.5, "Combustion" = 30, "Parry" = 2,"Ashen One" = 1, "SweepingStrike" = 1, "Deflection" = 1)
		StyleActive="Legacy of the Sunslammer"
		Finisher="/obj/Skills/Queue/Finisher/Session"
		verb/Sunslammer()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Heir_of_Grief // TUPAC BACK
		SignatureTechnique=3
		NeedsSword = 1
		Copyable=0
		StyleSpd=1.5
		StyleStr=1.5
		ElementalOffense="Fire"
		ElementalDefense="Fire"
		passives = list("BlurringStrikes" = 2, "Godspeed" = 2, "Momentum" = 1, "DoubleStrike" = 3, "Instinct" = 4, "Flow" = 3, "Iaijutsu" = 2,\
						"Musoken" = 1, "Kindling" = 0.5, "Combustion" = 30, "Parry" = 2,"Ashen One" = 1, "SweepingStrike" = 1, "Deflection" = 2)
		StyleActive="Heir of Grief"
		Finisher="/obj/Skills/Queue/Finisher/Endless_Session"
		verb/Heir_of_Grief()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Overture
		SignatureTechnique=4
		NeedsSword = 1
		Copyable=0
		StyleSpd=1.7
		StyleStr=1.7
		ElementalOffense="Fire"
		ElementalDefense="Fire"
		passives = list("BlurringStrikes" = 3, "Godspeed" = 3, "Momentum" = 2, "DoubleStrike" = 3, "TripleStrike" = 0.5, "Instinct" = 5, "Flow" = 4, "Iaijutsu" = 3,\
						"Musoken" = 1, "Kindling" = 1.5, "Combustion" = 30, "Parry" = 3,"Ashen One" = 1, "SweepingStrike" = 1, "Deflection" = 3)
		StyleActive="Overture"
		Finisher="/obj/Skills/Queue/Finisher/Endless_Session"
		verb/Overture()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
