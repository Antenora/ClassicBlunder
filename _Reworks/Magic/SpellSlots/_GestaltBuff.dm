// Gestalt Buffs — 8 elements, 3 tiers each
// SpecialBuff subtypes — occupy the Special slot (same slot as Magus Trance)
// The 'tier' var is set by the unlock system when granting the buff
// adjust() dynamically sets stats and passives based on current tier

/obj/Skills/Buffs/SpecialBuffs/Fire_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "channels the blazing essence of Fire!"
	OffMessage = "lets the flames recede..."
	adjust(mob/p)
		SpdMult = 1
		EndMult = 1
		DefMult = 1
		if(tier >= 3)
			ForMult = 1.4
			StrMult = 1.35
			OffMult = 1.3
			passives = list("Scorching" = 1, "Momentum" = 1, "FireHerald" = 1, "Brutalize" = 1, "CriticalDamage" = 2, "DemonicDurability" = 4)
		else if(tier >= 2)
			ForMult = 1.25
			StrMult = 1.15
			OffMult = 1
			passives = list("Scorching" = 1, "Momentum" = 1, "FireHerald" = 1, "Brutalize" = 1)
		else
			ForMult = 1.1
			StrMult = 1
			OffMult = 1
			passives = list("Scorching" = 1, "Momentum" = 1)
	verb/Fire_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Water_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "draws upon the flowing essence of Water!"
	OffMessage = "lets the current still..."
	adjust(mob/p)
		StrMult = 1
		SpdMult = 1
		OffMult = 1
		if(tier >= 3)
			EndMult = 1.4
			ForMult = 1.35
			DefMult = 1.3
			passives = list("Chilling" = 1, "FluidForm" = 1, "IceHerald" = 1, "ControlResist" = 1, "Blubber" = 3, "MeleeResist" = 1)
		else if(tier >= 2)
			EndMult = 1.25
			ForMult = 1.15
			DefMult = 1
			passives = list("Chilling" = 1, "FluidForm" = 1, "IceHerald" = 1, "ControlResist" = 1)
		else
			EndMult = 1.1
			ForMult = 1
			DefMult = 1
			passives = list("Chilling" = 1, "FluidForm" = 1)
	verb/Water_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Earth_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "hardens with the unyielding essence of Earth!"
	OffMessage = "releases the stone resolve..."
	adjust(mob/p)
		StrMult = 1
		SpdMult = 1
		OffMult = 1
		if(tier >= 3)
			ForMult = 1.4
			EndMult = 1.35
			DefMult = 1.3
			passives = list("Shattering" = 1, "Harden" = 1, "EarthHerald" = 1, "Grit" = 1, "Juggernaut" = 1, "CriticalBlock" = 2)
		else if(tier >= 2)
			ForMult = 1.25
			EndMult = 1.15
			DefMult = 1
			passives = list("Shattering" = 1, "Harden" = 1, "EarthHerald" = 1, "Grit" = 1)
		else
			ForMult = 1.1
			EndMult = 1
			DefMult = 1
			passives = list("Shattering" = 1, "Harden" = 1)
	verb/Earth_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Wind_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "surges with the crackling essence of Wind!"
	OffMessage = "lets the storm calm..."
	adjust(mob/p)
		StrMult = 1
		EndMult = 1
		DefMult = 1
		if(tier >= 3)
			ForMult = 1.4
			SpdMult = 1.35
			OffMult = 1.3
			passives = list("Shocking" = 1, "Afterimages" = 1, "ThunderHerald" = 1, "BlurringStrikes" = 1, "AttackSpeed" = 2, "Godspeed" = 2)
		else if(tier >= 2)
			ForMult = 1.25
			SpdMult = 1.15
			OffMult = 1
			passives = list("Shocking" = 1, "Afterimages" = 1, "ThunderHerald" = 1, "BlurringStrikes" = 1)
		else
			ForMult = 1.1
			SpdMult = 1
			OffMult = 1
			passives = list("Shocking" = 1, "Afterimages" = 1)
	verb/Wind_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Light_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "radiates with the holy essence of Light!"
	OffMessage = "dims the divine glow..."
	adjust(mob/p)
		StrMult = 1
		ForMult = 1
		OffMult = 1
		if(tier >= 3)
			SpdMult = 1.4
			EndMult = 1.35
			DefMult = 1.3
			passives = list("LifeGeneration" = 3, "BuffMastery" = 1, "Restoration" = 1, "DebuffResistance" = 1, "AngelicInfusion" = 1)
		else if(tier >= 2)
			SpdMult = 1.25
			EndMult = 1.15
			DefMult = 1
			passives = list("LifeGeneration" = 1, "BuffMastery" = 1, "Restoration" = 1, "DebuffResistance" = 1)
		else
			SpdMult = 1.1
			EndMult = 1
			DefMult = 1
			passives = list("LifeGeneration" = 1, "BuffMastery" = 1)
	verb/Light_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Dark_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "embraces the consuming essence of Darkness!"
	OffMessage = "suppresses the dark power..."
	adjust(mob/p)
		EndMult = 1
		SpdMult = 1
		DefMult = 1
		if(tier >= 3)
			StrMult = 1.4
			ForMult = 1.35
			OffMult = 1.3
			passives = list("KillerInstinct" = 1, "Pressure" = 1, "CriticalChance" = 2, "LifeSteal" = 2, "DemonicInfusion" = 1)
		else if(tier >= 2)
			StrMult = 1.25
			ForMult = 1.15
			OffMult = 1
			passives = list("KillerInstinct" = 1, "Pressure" = 1, "CriticalChance" = 2, "LifeSteal" = 1)
		else
			StrMult = 1.1
			ForMult = 1
			OffMult = 1
			passives = list("KillerInstinct" = 1, "Pressure" = 1)
	verb/Dark_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Time_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "attunes to the temporal essence of Time!"
	OffMessage = "releases the temporal flow..."
	adjust(mob/p)
		StrMult = 1
		EndMult = 1
		OffMult = 1
		if(tier >= 3)
			ForMult = 1.4
			SpdMult = 1.35
			DefMult = 1.3
			passives = list("TechniqueMastery" = 2, "DebuffDurationReduction" = 1, "Blubber" = 2, "Godspeed" = 1, "FluidForm" = 1, "Entropic" = 1)
		else if(tier >= 2)
			ForMult = 1.25
			SpdMult = 1.15
			DefMult = 1
			passives = list("TechniqueMastery" = 2, "DebuffDurationReduction" = 1, "Blubber" = 2, "Godspeed" = 1)
		else
			ForMult = 1.1
			SpdMult = 1
			DefMult = 1
			passives = list("TechniqueMastery" = 2, "DebuffDurationReduction" = 1)
	verb/Time_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)

/obj/Skills/Buffs/SpecialBuffs/Space_Gestalt_Buff
	MagicNeeded = 1
	Cooldown = -1
	var/tier = 1
	ActiveMessage = "warps with the spatial essence of Space!"
	OffMessage = "stabilizes the spatial field..."
	adjust(mob/p)
		StrMult = 1
		EndMult = 1
		DefMult = 1
		if(tier >= 3)
			SpdMult = 1.4
			ForMult = 1.35
			OffMult = 1.3
			passives = list("Warping" = 1, "Flicker" = 1, "Siphon" = 2, "PUSpike" = 5, "Steady" = 2, "Vortex" = 5)
		else if(tier >= 2)
			SpdMult = 1.25
			ForMult = 1.15
			OffMult = 1
			passives = list("Warping" = 1, "Flicker" = 1, "Siphon" = 2, "PUSpike" = 5)
		else
			SpdMult = 1.1
			ForMult = 1
			OffMult = 1
			passives = list("Warping" = 1, "Flicker" = 1)
	verb/Space_Gestalt_Buff()
		set hidden = 1
		src.Trigger(usr)
