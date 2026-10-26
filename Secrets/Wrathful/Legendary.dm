/obj/Skills/Buffs/SlotlessBuffs/Legendary
	Copyable = 0
	ExclusiveFamily = /obj/Skills/Buffs/SlotlessBuffs/Legendary
	Legendary_Stance
		BuffName = "Legendary Stance"
		Enlarge = 1.25
		passives = list("GiantForm" = 1, "Momentum" = 1, "Juggernaut" = 1, "LegendarySaiyan" = 1, "Harden" = 1.5)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "Momentum" = 1, "Juggernaut" = 1, "LegendarySaiyan" = 1, "Harden" = 1.5, "UnarmedDamage" = 1)
		verb/Legendary_Stance()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Legacy_Of_The_Fabled_King
		BuffName = "Legacy Of The Fabled King"
		Enlarge = 1.5
		passives = list("GiantForm" = 1, "Momentum" = 2, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 1, "LegendarySaiyan" = 1, "Harden" = 2)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "Momentum" = 2, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 1, "LegendarySaiyan" = 1, "Harden" = 2, "UnarmedDamage" = 2)
		verb/Fabled_King_Stance()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	True_Fist_Of_The_Fabled_King
		BuffName = "Fist Of The Fabled King (True)"
		Enlarge = 1.75
		passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 2, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 2, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2, "UnarmedDamage" = 3)
		verb/Fist_Of_The_Fabled_King_Stance()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Fist_Of_The_King_Of_Tomorrow
		BuffName = "Fist Of The King Of Tomorrow"
		Enlarge = 2
		passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 2, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 3, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "Harden" = 2, "UnarmedDamage" = 4, "DisableGodKi" = 1, "ZenkaiPower" = 1)
		verb/Fist_Of_The_King_Of_Tomorrow()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Apotheosis_Of_The_Fabled_King
		BuffName = "Apotheosis Of The Fabled King"
		Enlarge = 2
		passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 2, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 5, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2, "UnarmedDamage" = 4)
		verb/Apotheosis_Of_The_Fabled_King()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Mantle_Of_The_Fabled_King
		BuffName = "Mantle Of The Fabled King"
		Enlarge = 2
		passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "NoDodge" = 1, "KiControlMastery" = 2, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "KiControlMastery" = 5, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2, "UnarmedDamage" = 4)
		verb/Mantle_Of_The_Fabled_King()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Mantle_Of_The_King_Of_Tomorrow
		BuffName = "Mantle Of The King Of Tomorrow"
		Enlarge = 2
		passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "KiControlMastery" = 2, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "ZenkaiPower" = 1, "Harden" = 2)
		adjust(mob/p)
			passives = list("GiantForm" = 1, "Momentum" = 3, "Juggernaut" = 1, "KiControlMastery" = 3, "LegendarySaiyan" = 1, "Pride" = 1, "Zeal" = 1, "Harden" = 2, "UnarmedDamage" = 4, "DisableGodKi" = 1, "ZenkaiPower" = 1)
		verb/Mantle_Of_The_King_Of_Tomorrow()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
