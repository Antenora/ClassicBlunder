/obj/Skills/Buffs/NuStyle/SwordStyle
	stage_flags = list(\
		list("NeedsSword" = 1),\
		list("NeedsSword" = 1),\
		list("NeedsSword" = 1),\
		list("NeedsSword" = 1))

	Duelist
		StyleActive = "Duelist"
		passives = list("Parry" = 1, "Disarm" = 1)
		stage_passives = list(\
			list("Parry" = 1, "Disarm" = 1),\
			list("Parry" = 1, "Disarm" = 1, "Reversal" = 0.5),\
			list("Parry" = 2, "Disarm" = 2, "Reversal" = 1),\
			list("Parry" = 2, "Disarm" = 2, "Reversal" = 1, "Parry Riposte" = 1))
		verb/Duelist_Style()
			set hidden = 1
			src.Trigger(usr)

	Twin_Blade
		StyleActive = "Twin Blade"
		passives = list("DoubleStrike" = 1, "SweepingStrike" = 1)
		stage_passives = list(\
			list("DoubleStrike" = 1, "SweepingStrike" = 1),\
			list("DoubleStrike" = 1, "SweepingStrike" = 1, "TripleStrike" = 0.5),\
			list("DoubleStrike" = 2, "SweepingStrike" = 1, "TripleStrike" = 1),\
			list("DoubleStrike" = 2, "SweepingStrike" = 1, "TripleStrike" = 1, "AsuraStrike" = 1))
		stage_flags = list(\
			list("NeedsSword" = 1, "NeedsSecondSword" = 1),\
			list("NeedsSword" = 1, "NeedsSecondSword" = 1),\
			list("NeedsSword" = 1, "NeedsSecondSword" = 1),\
			list("NeedsSword" = 1, "NeedsSecondSword" = 1, "AllowsThirdSword" = 1))
		verb/Twin_Blade_Style()
			set hidden = 1
			src.Trigger(usr)

	Iaido
		StyleActive = "Iaido"
		passives = list("Iaijutsu" = 0.5, "Sheathed" = 1)
		stage_passives = list(\
			list("Iaijutsu" = 0.5, "Sheathed" = 1),\
			list("Iaijutsu" = 0.5, "Sheathed" = 1, "Hit Scan" = 1),\
			list("Iaijutsu" = 1, "Sheathed" = 2, "Hit Scan" = 2),\
			list("Iaijutsu" = 1, "Sheathed" = 2, "Hit Scan" = 2, "Battojutsu" = 1))
		verb/Iaido_Style()
			set hidden = 1
			src.Trigger(usr)

	Heavy_Blade
		StyleActive = "Heavy Blade"
		passives = list("Half-Sword" = 1, "WeaponBreaker" = 1)
		stage_passives = list(\
			list("Half-Sword" = 1, "WeaponBreaker" = 1),\
			list("Half-Sword" = 1, "WeaponBreaker" = 1, "ArmorPeeling" = 1),\
			list("Half-Sword" = 2, "WeaponBreaker" = 2, "ArmorPeeling" = 1),\
			list("Half-Sword" = 2, "WeaponBreaker" = 2, "ArmorPeeling" = 1, "Overhead" = 2))
		verb/Heavy_Blade_Style()
			set hidden = 1
			src.Trigger(usr)

	Chain
		StyleActive = "Chain"
		passives = list("Extend" = 1, "Tossing" = 1, "Secret Knives" = "Secret_Knives")
		stage_passives = list(\
			list("Extend" = 1, "Tossing" = 1, "Secret Knives" = "Secret_Knives"),\
			list("Extend" = 1, "Tossing" = 1, "Secret Knives" = "Secret_Knives", "AirBend" = 1),\
			list("Extend" = 2, "Tossing" = 1, "Secret Knives" = "Secret_Knives", "AirBend" = 2),\
			list("Extend" = 2, "Tossing" = 1, "Secret Knives" = "Secret_Knives", "AirBend" = 2, "EntanglingRoots" = 1))
		verb/Chain_Style()
			set hidden = 1
			src.Trigger(usr)

	Spellblade
		StyleActive = "Spellblade"
		passives = list("MagicSword" = 1, "MovingCharge" = 1)
		stage_passives = list(\
			list("MagicSword" = 1, "MovingCharge" = 1),\
			list("MagicSword" = 1, "MovingCharge" = 1, "Wuju" = 1),\
			list("MagicSword" = 1, "MovingCharge" = 1, "Wuju" = 1, "Enchanted Edge" = 1),\
			list("MagicSword" = 1, "MovingCharge" = 1, "Wuju" = 1, "Enchanted Edge" = 2))
		verb/Spellblade_Style()
			set hidden = 1
			src.Trigger(usr)
