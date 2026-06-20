obj/Skills/Buffs/NuStyle/Legendary
	Legendary_Stance
		SignatureTechnique=1
		Copyable=0
		StyleEnd=1.15
		StyleStr=1.3
		Enlarge = 1.25
		passives = list("GiantForm" = 1, "DoubleStrike" = 1, "Fa Jin" = 2, "Momentum" = 1, "HardStyle" = 1, "Instinct"=2, "Juggernaut" = 1, "PureReduction" = 1,\
						"SweepingStrike" = 1, "Meaty Paws" = 1, "Brutalize" = 1, "LegendarySaiyan" = 1,"Momentum"=1,"Harden" = 1.5, "Deflection" = 0.5)
		StyleActive="Legendary Stance"
		Finisher="/obj/Skills/Queue/Finisher/Tengenkotsu"
		adjust(mob/p)
			passives = list("GiantForm" = 1, "DoubleStrike" = 1, "Fa Jin" = 2, "Momentum" = 1, "HardStyle"=1, "Instinct"=2, "Juggernaut" = 1, "PureReduction" = 1,\
						"SweepingStrike" = 1, "Meaty Paws" = 1, "Brutalize" = 1, "LegendarySaiyan" = 1,"Momentum"=1,"Harden" = 1.5, "Deflection" = 0.5, "UnarmedDamage"=1)
		verb/Legendary_Stance()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Legacy_Of_The_Fabled_King
		SignatureTechnique=2
		Copyable=0
		StyleEnd=1.25
		StyleStr=1.35
		Enlarge = 1.5
		passives = list("GiantForm" = 1, "DoubleStrike" = 2, "Fa Jin" = 2, "Momentum" = 2, "HardStyle" = 1, "Instinct"=3, "Juggernaut" = 1, "PureDamage" = 0.5, "PureReduction" = 1.5,\
						"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 2,"Gum Gum" =1, "Meaty Paws" = 1.5, "KiControlMastery" = 1,"LegendarySaiyan"=1,"Momentum"=2,"Harden" = 2,\
						 "Deflection" = 1)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "DoubleStrike" = 2, "Fa Jin" = 2, "Momentum" = 2, "HardStyle" = 1, "Instinct"=3, "Juggernaut" = 1, "PureDamage" = 0.5, "PureReduction" = 1.5,\
							"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 2,"Gum Gum" =1, "Meaty Paws" = 1.5, "KiControlMastery" = 1,"LegendarySaiyan"=1,"Momentum"=2,"Harden" = 2,\
							 "Deflection" = 1, "UnarmedDamage"=2)
		StyleActive="Legacy Of The Fabled King"
		Finisher="/obj/Skills/Queue/Finisher/Mugen_Tengenkotsu"
		verb/Fabled_King_Stance()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	True_Fist_Of_The_Fabled_King
		SignatureTechnique=3
		Copyable=0
		StyleEnd=1.5
		StyleStr=1.5
		Enlarge = 1.75
		passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 3, "HardStyle"=1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 1, "PureReduction" = 2,\
						"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 2, "Meaty Paws" = 1.5, "KiControlMastery" = 2,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
						"Harden" = 2, "Deflection" = 1,"Gum Gum" =1)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 3, "HardStyle" = 1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 1, "PureReduction" = 2,\
				"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 2, "Meaty Paws" = 1.5, "KiControlMastery" = 2,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
				"Harden" = 2, "Deflection" = 1,"Gum Gum" =1, "UnarmedDamage"=3)

		StyleActive="Fist Of The Fabled King (True)"
		Finisher="/obj/Skills/Queue/Finisher/Erupting_Mugen_Tengenkotsu"
		verb/Fist_Of_The_Fabled_King_Stance()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Fist_Of_The_King_Of_Tomorrow //no god ki
		SignatureTechnique=4
		Copyable=0
		StyleEnd=1.5
		StyleStr=2.5
		Enlarge =2
		passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 3, "HardStyle"=1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 1, "PureReduction" = 2,\
						"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 2, "Meaty Paws" = 1.5, "KiControlMastery" = 2,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
						"Harden" = 2, "Deflection" = 1,"Gum Gum" =1)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 3, "Momentum" = 3, "HardStyle" = 1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 2, "PureReduction" = 3,\
				"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 3,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
				"Harden" = 2, "Deflection" = 2,"Gum Gum" =1, "UnarmedDamage"=4,"DisableGodKi"=1, "Deicide" = 15, "ZenkaiPower" = 1)

		StyleActive="Fist Of The King Of Tomorrow"
		Finisher="/obj/Skills/Queue/Finisher/Saigo_no_Kyukyoku_Tengenkotsu"
		verb/Fist_Of_The_King_Of_Tomorrow()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Apotheosis_Of_The_Fabled_King //god ki
		SignatureTechnique=4
		Copyable=0
		StyleEnd=1.5
		StyleStr=2.5
		Enlarge =2
		passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 3, "HardStyle"=1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 1, "PureReduction" = 2,\
						"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 2, "Meaty Paws" = 1.5, "KiControlMastery" = 2,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
						"Harden" = 2, "Deflection" = 1,"Gum Gum" =1)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 3, "Momentum" = 3, "HardStyle" = 1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 2, "PureReduction" = 3,\
				"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 5,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
				"Harden" = 2, "Deflection" = 2,"Gum Gum" =1, "UnarmedDamage"=4, "MovementMastery" = 5)

		StyleActive="Apotheosis Of The Fabled King"
		Finisher="/obj/Skills/Queue/Finisher/Saigo_no_Kyukyoku_Tengenkotsu"
		verb/Apotheosis_Of_The_Fabled_King()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Mantle_Of_The_Fabled_King //fifth tier that allows dodge but does nothing else
		SignatureTechnique=4
		Copyable=0
		StyleEnd=1.5
		StyleStr=2.5
		Enlarge =2
		passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 3, "HardStyle"=1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 1, "PureReduction" = 2,\
						"NoDodge" = 1, "SweepingStrike" = 1, "Brutalize" = 2, "Meaty Paws" = 1.5, "KiControlMastery" = 2,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
						"Harden" = 2, "Deflection" = 1,"Gum Gum" =1)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 3, "Momentum" = 3, "HardStyle" = 1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 2, "PureReduction" = 3,\
				"SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 5,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
				"Harden" = 2, "Deflection" = 2,"Gum Gum" =1, "UnarmedDamage"=4, "MovementMastery" = 5)

		StyleActive="Mantle Of The Fabled King"
		Finisher="/obj/Skills/Queue/Finisher/Saigo_no_Kyukyoku_Tengenkotsu"
		verb/Mantle_Of_The_Fabled_King()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
	Mantle_Of_The_King_Of_Tomorrow //no god ki
		SignatureTechnique=4
		Copyable=0
		StyleEnd=1.5
		StyleStr=2.5
		Enlarge =2
		passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 2, "Momentum" = 3, "HardStyle"=1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 1, "PureReduction" = 2,\
						"SweepingStrike" = 1, "Brutalize" = 2, "Meaty Paws" = 1.5, "KiControlMastery" = 2,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
						"Harden" = 2, "Deflection" = 1,"Gum Gum" =1)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "DoubleStrike" = 3, "Fa Jin" = 3, "Momentum" = 3, "HardStyle" = 1, "Instinct"=4, "Juggernaut" = 1, "PureDamage" = 2, "PureReduction" = 3,\
				"SweepingStrike" = 1, "Brutalize" = 3, "Meaty Paws" = 2, "KiControlMastery" = 3,"LegendarySaiyan"=1, "Pride"=1, "Zeal"=1, "Honor"=1,\
				"Harden" = 2, "Deflection" = 2,"Gum Gum" =1, "UnarmedDamage"=4,"DisableGodKi"=1, "Deicide" = 15, "ZenkaiPower" = 1)

		StyleActive="Mantle Of The King Of Tomorrow"
		Finisher="/obj/Skills/Queue/Finisher/Saigo_no_Kyukyoku_Tengenkotsu"
		verb/Mantle_Of_The_King_Of_Tomorrow()
			set hidden=1
			adjust(usr)
			src.Trigger(usr)
