/obj/Skills/Buffs/SpecialBuffs/Keyblade
	SpecialSlot = 0
	Slotless = 1
	FlashChange = 1
	ExclusiveFamily = /obj/Skills/Buffs/SpecialBuffs/Keyblade
	Speed_Rave
		BuffName = "Speed Rave"
		passives = list("AttackSpeed" = 3, "AfterImages" = 1)
		verb/Speed_Rave()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Critical_Impact
		BuffName = "Critical Impact"
		passives = list("AttackSpeed" = -2, "CriticalDamage" = 0.1)
		verb/Critical_Impact()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Spell_Weaver
		BuffName = "Spell Weaver"
		passives = list("QuickCast" = 3)
		verb/Spell_Weaver()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Firestorm
		BuffName = "Firestorm"
		ElementalClass = "Fire"
		ElementalOffense = "Fire"
		ElementalDefense = "Fire"
		passives = list("Burning" = 1)
		Burning = 1
		verb/Firestorm()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Diamond_Dust
		BuffName = "Diamond Dust"
		ElementalClass = "Water"
		ElementalOffense = "Water"
		ElementalDefense = "Water"
		passives = list("Chilling" = 1)
		Chilling = 1
		verb/Diamond_Dust_Command()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Thunderbolt
		BuffName = "Thunderbolt"
		ElementalClass = "Wind"
		ElementalOffense = "Wind"
		ElementalDefense = "Wind"
		passives = list("Shocking" = 1)
		Shocking = 1
		verb/Thunderbolt()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Wing_Blade
		BuffName = "Wing Blade"
		passives = list("AfterImages" = 1)
		SwordIcon = 'BLANK.dmi'
		SwordIconSecond = 'BLANK.dmi'
		IconLock = 'WingBlade.dmi'
		LockX = -16
		LockY = -16
		IconLockBlend = 2
		IconApart = 1
		verb/Wing_Blade()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Cyclone
		BuffName = "Cyclone"
		ElementalClass = "Wind"
		ElementalOffense = "Wind"
		ElementalDefense = "Wind"
		passives = list("TechniqueMastery" = 3, "Paralyzing" = 1)
		Shocking = 1
		Paralyzing = 0.2
		verb/Cyclone()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Rock_Breaker
		BuffName = "Rock Breaker"
		ElementalClass = "Earth"
		ElementalOffense = "Earth"
		ElementalDefense = "Earth"
		passives = list("Harden" = 1, "Crushing" = 1)
		Crushing = 1
		verb/Rock_Breaker()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Dark_Impulse
		BuffName = "Dark Impulse"
		IconLock = 'DarknessGlow.dmi'
		AuraArt = 1
		IconUnder = 1
		LockX = -32
		LockY = -32
		ElementalOffense = "Dark"
		ElementalDefense = "Dark"
		passives = list("Momentum" = 1, "Piercing" = 0.25)
		verb/Dark_Impulse()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Ghost_Drive
		BuffName = "Ghost Drive"
		passives = list("Godspeed" = 1, "QuickCast" = 1)
		Afterimages = 1
		verb/Ghost_Drive()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Blade_Charge
		BuffName = "Blade Charge"
		passives = list("AfterImages" = 1)
		verb/Blade_Charge()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Ultimate_Form
		BuffName = "Ultimate Form"
		ElementalOffense = "Love"
		passives = list("Godspeed" = 1, "QuickCast" = 1)
		verb/Ultimate_Form()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Forces_Of_Darkness
		BuffName = "Forces of Darkness"
		IconLock = 'DarknessGlow.dmi'
		AuraArt = 1
		IconUnder = 1
		LockX = -32
		LockY = -32
		ElementalOffense = "Dark"
		ElementalDefense = "Dark"
		passives = list("Momentum" = 1, "HellPower" = 0.5, "AbyssMod" = 3)
		verb/Forces_Of_Darkness()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Vector_to_the_Heavens
		BuffName = "Vector to the Heavens (Keyblade)"
		ElementalOffense = "Light"
		ElementalDefense = "Light"
		passives = list("HolyMod" = 5)
		verb/Vector_to_the_Heavens_Command()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
	Nachtflugel
		BuffName = "Nachtflugel"
		ElementalOffense = "Truth"
		ElementalDefense = "Mirror"
		passives = list("Godspeed" = 4, "Skimming" = 2)
		verb/Nachtflugel()
			set category = "Skills"
			set hidden = 1
			src.Trigger(usr)
