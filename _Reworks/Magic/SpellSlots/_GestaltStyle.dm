// Gestalt Styles — 8 elements, 3 tiers each
// NuStyle subtypes under Magus_Style
// The 'tier' var is set by the unlock system when granting the style
// adjust() dynamically sets stats and passives based on current tier

/obj/Skills/Buffs/NuStyle/Magus_Style/Fire_Gestalt
	StyleActive = "Fire Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleEnd = 1
		StyleDef = 1
		StyleSpd = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleStr = 1.9
			StyleFor = 1.75
			StyleOff = 1.6
			passives = list("HeavyHitter" = 1, "Scorching" = 1, "Momentum" = 2, "Brutalize" = 1, "MartialMagic" = 1, "PureDamage" = 3, "CriticalChance" = 20, "CriticalDamage" = 0.2)
		else if(tier >= 2)
			StyleStr = 1.4
			StyleFor = 1.35
			StyleOff = 1.3
			passives = list("HeavyHitter" = 1, "Scorching" = 1, "Momentum" = 2, "Brutalize" = 0.5, "CriticalChance" = 10, "CriticalDamage" = 0.1)
		else
			StyleStr = 1.2
			StyleFor = 1.15
			StyleOff = 1.1
			passives = list("HeavyHitter" = 1, "Scorching" = 1)
	verb/Fire_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/Magus_Style/Water_Gestalt
	StyleActive = "Water Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleStr = 1
		StyleSpd = 1
		StyleOff = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleFor = 1.9
			StyleEnd = 1.75
			StyleDef = 1.6
			passives = list("FluidForm" = 1, "Blubber" = 1, "LikeWater" = 4, "ControlResist" = 1, "MeleeResist" = 2)
		else if(tier >= 2)
			StyleFor = 1.4
			StyleEnd = 1.35
			StyleDef = 1.3
			passives = list("FluidForm" = 1, "Blubber" = 1, "LikeWater" = 2, "ControlResist" = 1)
		else
			StyleFor = 1.2
			StyleEnd = 1.15
			StyleDef = 1.1
			passives = list("FluidForm" = 1, "Blubber" = 1)
	verb/Water_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/Magus_Style/Earth_Gestalt
	StyleActive = "Earth Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleStr = 1
		StyleSpd = 1
		StyleOff = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleEnd = 1.9
			StyleFor = 1.75
			StyleDef = 1.6
			passives = list("Harden" = 1, "Steady" = 1, "MeleeResist" = 1, "Tenacity" = 2, "PureReduction" = 3)
		else if(tier >= 2)
			StyleEnd = 1.4
			StyleFor = 1.35
			StyleDef = 1.3
			passives = list("Harden" = 1, "Steady" = 1, "MeleeResist" = 1, "PureReduction" = 2)
		else
			StyleEnd = 1.2
			StyleFor = 1.15
			StyleDef = 1.1
			passives = list("Harden" = 1, "Steady" = 1)
	verb/Earth_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/Magus_Style/Wind_Gestalt
	StyleActive = "Wind Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleStr = 1
		StyleEnd = 1
		StyleDef = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleSpd = 1.9
			StyleFor = 1.75
			StyleOff = 1.6
			passives = list("BlurringStrikes" = 3, "AttackSpeed" = 1, "Fury" = 2, "Afterimages" = 1, "Flicker" = 3)
		else if(tier >= 2)
			StyleSpd = 1.4
			StyleFor = 1.35
			StyleOff = 1.3
			passives = list("BlurringStrikes" = 1, "AttackSpeed" = 1, "Fury" = 2, "Afterimages" = 1)
		else
			StyleSpd = 1.2
			StyleFor = 1.15
			StyleOff = 1.1
			passives = list("BlurringStrikes" = 1, "AttackSpeed" = 1)
	verb/Wind_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/Magus_Style/Light_Gestalt
	StyleActive = "Light Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleStr = 1
		StyleFor = 1
		StyleOff = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleEnd = 1.9
			StyleSpd = 1.75
			StyleDef = 1.6
			passives = list("Steady" = 1, "HolyMod" = 5, "BuffMastery" = 2, "Fury" = 2, "ManaGeneration" = 3, "EnergyGeneration" = 3)
		else if(tier >= 2)
			StyleEnd = 1.4
			StyleSpd = 1.35
			StyleDef = 1.3
			passives = list("Steady" = 1, "HolyMod" = 3, "BuffMastery" = 2, "Fury" = 2, "ManaGeneration" = 2, "EnergyGeneration" = 2)
		else
			StyleEnd = 1.2
			StyleSpd = 1.15
			StyleDef = 1.1
			passives = list("Steady" = 1, "HolyMod" = 1, "ManaGeneration" = 1, "EnergyGeneration" = 1)
	verb/Light_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/Magus_Style/Dark_Gestalt
	StyleActive = "Dark Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleEnd = 1
		StyleSpd = 1
		StyleDef = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleFor = 1.9
			StyleStr = 1.75
			StyleOff = 1.6
			passives = list("KillerInstinct" = 0.1, "CriticalChance" = 20, "CriticalDamage" = 0.2, "LifeSteal" = 20, "Pressure" = 2, "Momentum" = 2, "Brutalize" = 2)
		else if(tier >= 2)
			StyleFor = 1.4
			StyleStr = 1.35
			StyleOff = 1.3
			passives = list("KillerInstinct" = 0.1, "CriticalChance" = 20, "CriticalDamage" = 0.2, "LifeSteal" = 10, "Pressure" = 2)
		else
			StyleFor = 1.2
			StyleStr = 1.15
			StyleOff = 1.1
			passives = list("KillerInstinct" = 0.1, "CriticalChance" = 20, "CriticalDamage" = 0.2)
	verb/Dark_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/Magus_Style/Time_Gestalt
	StyleActive = "Time Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleStr = 1
		StyleEnd = 1
		StyleOff = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleSpd = 1.9
			StyleFor = 1.75
			StyleDef = 1.6
			passives = list("TechniqueMastery" = 5, "CounterMaster" = 1, "FluidForm" = 1, "Deflection" = 1, "Godspeed" = 3)
		else if(tier >= 2)
			StyleSpd = 1.4
			StyleFor = 1.35
			StyleDef = 1.3
			passives = list("TechniqueMastery" = 3, "CounterMaster" = 1, "FluidForm" = 1, "Deflection" = 1)
		else
			StyleSpd = 1.2
			StyleFor = 1.15
			StyleDef = 1.1
			passives = list("TechniqueMastery" = 1, "CounterMaster" = 1)
	verb/Time_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)

/obj/Skills/Buffs/NuStyle/Magus_Style/Space_Gestalt
	StyleActive = "Space Gestalt"
	var/tier = 1
	adjust(mob/p)
		StyleStr = 1
		StyleEnd = 1
		StyleDef = 1
		tier=p.getGestaltTier();
		if(tier >= 3)
			StyleFor = 1.9
			StyleSpd = 1.75
			StyleOff = 1.6
			passives = list("Warping" = 1, "SuperDash" = 1, "Flicker" = 1, "MovementMastery" = 2, "Pressure" = 5, "Unnerve" = 5)
		else if(tier >= 2)
			StyleFor = 1.4
			StyleSpd = 1.35
			StyleOff = 1.3
			passives = list("Warping" = 1, "SuperDash" = 1, "Flicker" = 1, "MovementMastery" = 2)
		else
			StyleFor = 1.2
			StyleSpd = 1.15
			StyleOff = 1.1
			passives = list("Warping" = 1, "SuperDash" = 1)
	verb/Space_Gestalt()
		set hidden = 1
		if(usr.Saga && !usr.isRace(NOBODY) && !usr.isRace(DEMIFIEND))
			usr << "Your Saga prevents you from using a Gestalt Style."
			return
		src.Trigger(usr)
