var/list/MECH_STAT_KEYS = list("Str", "End", "Spd", "For", "Off", "Def", "Vit")

var/list/MECH_SLOT_NAMES = list("RArm" = "Right Arm", "LArm" = "Left Arm", "RBack" = "Right Back", "LBack" = "Left Back", "Int1" = "Internal 1", "Int2" = "Internal 2")

var/list/MECH_MODELS = list(\
	"MechA" = list("name" = "Vanguard", "class" = "Light", "size" = MECH_SIZE_LIGHT, "icon" = MECH_ICON_MECHA, "state" = "Stand", "fly" = 1, "hover" = 0,\
		"slots" = list("RArm", "LArm"), "fixed" = list(), "internals" = MECH_INTERNALS_LIGHT, "sockets" = MECH_SOCKETS_LIGHT,\
		"stats" = list(16, 12, 20, 14, 16, 12, 12), "move" = 1.15, "atk" = 0.95, "passive" = list("Red Comet", 1), "baked" = list("/obj/Skills/Projectile/Mech/Head_Vulcans"),\
		"rise" = 4, "fly_states" = list("StandWings", "WingsReady", "Fly"), "offset_x" = -24, "offset_y" = 0, "plating_n" = MECH_PLATING_LIGHT, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"MechB" = list("name" = "Duelist", "class" = "Light", "size" = MECH_SIZE_LIGHT, "icon" = MECH_ICON_MECHB, "state" = "Stand", "fly" = 1, "hover" = 0,\
		"slots" = list("RArm", "RBack"), "fixed" = list(), "internals" = MECH_INTERNALS_LIGHT, "sockets" = MECH_SOCKETS_LIGHT,\
		"stats" = list(18, 14, 19, 10, 17, 13, 12), "move" = 1.10, "atk" = 0.90, "passive" = list("Riposte", 1), "baked" = list("/obj/Skills/AutoHit/Mech/Lunge"),\
		"rise" = 4, "fly_states" = list("StandWings", "WingsReady", "Fly"), "offset_x" = -24, "offset_y" = 0, "plating_n" = MECH_PLATING_LIGHT, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"MechC" = list("name" = "Seraph", "class" = "Light", "size" = MECH_SIZE_LIGHT, "icon" = MECH_ICON_MECHC, "state" = "Stand", "fly" = 1, "hover" = 0,\
		"slots" = list("RArm", "LBack"), "fixed" = list(), "internals" = MECH_INTERNALS_LIGHT, "sockets" = MECH_SOCKETS_LIGHT,\
		"stats" = list(12, 12, 18, 20, 17, 12, 12), "move" = 1.10, "atk" = 1.00, "passive" = list("Psycommu", 1), "baked" = list("/obj/Skills/Mech/Overload_Pulse"),\
		"rise" = 4, "fly_states" = list("StandWings", "WingsReady", "Fly"), "offset_x" = -24, "offset_y" = 0, "plating_n" = MECH_PLATING_LIGHT, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"MechD" = list("name" = "Sentinel", "class" = "Light", "size" = MECH_SIZE_LIGHT, "icon" = MECH_ICON_MECHD, "state" = "Stand", "fly" = 1, "hover" = 0,\
		"slots" = list("LArm", "RBack"), "fixed" = list(), "internals" = MECH_INTERNALS_LIGHT, "sockets" = MECH_SOCKETS_LIGHT,\
		"stats" = list(15, 17, 16, 13, 14, 16, 16), "move" = 1.00, "atk" = 1.00, "passive" = list("Mass Production", 1), "baked" = list("/obj/Skills/Mech/Smoke_Discharge"),\
		"rise" = 4, "fly_states" = list("StandWings", "WingsReady", "Fly"), "offset_x" = -24, "offset_y" = 0, "plating_n" = MECH_PLATING_LIGHT, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot01" = list("name" = "Paladin", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV01, "state" = "", "fly" = 0, "hover" = 0,\
		"slots" = list("RArm", "LArm", "RBack"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(16, 17, 15, 16, 17, 17, 17), "move" = 1.00, "atk" = 1.00, "passive" = list("Shield Bearer", 1), "baked" = list("/obj/Skills/AutoHit/Mech/Shield_Bash"),\
		"rise" = 0, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot02" = list("name" = "Musha", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV02, "state" = "", "fly" = 0, "hover" = 0,\
		"slots" = list("RArm", "LArm", "LBack"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(21, 15, 17, 10, 18, 13, 15), "move" = 1.05, "atk" = 0.85, "passive" = list("Twin Blade Kata", 1), "baked" = list("/obj/Skills/AutoHit/Mech/Iai_Cleave"),\
		"rise" = 0, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot03" = list("name" = "Bastion", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV03, "state" = "", "fly" = 0, "hover" = 0,\
		"slots" = list("RBack", "LBack", "RArm"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(12, 20, 10, 18, 16, 18, 20), "move" = 0.80, "atk" = 1.20, "passive" = list("Siege Platform", 1), "baked" = list("/obj/Skills/Projectile/Mech/Twin_Cannon_Volley"),\
		"rise" = 0, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot04" = list("name" = "Typhon", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV04, "state" = "", "fly" = 1, "hover" = 0,\
		"slots" = list("RArm", "LArm", "LBack"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(19, 13, 19, 12, 18, 12, 13), "move" = 1.15, "atk" = 0.90, "passive" = list("Predator Frame", 1), "baked" = list("/obj/Skills/Grapple/Mech/Claw_Rend"),\
		"rise" = 4, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot05" = list("name" = "Juggernaut", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV05, "state" = "", "fly" = 0, "hover" = 0,\
		"slots" = list("RArm", "LArm", "RBack"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(20, 18, 12, 14, 15, 16, 19), "move" = 0.90, "atk" = 1.10, "passive" = list("Vent Cycling", 1), "baked" = list("/obj/Skills/AutoHit/Mech/Heat_Vent"),\
		"rise" = 0, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot08" = list("name" = "Shark", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV08, "state" = "", "fly" = 1, "hover" = 0,\
		"slots" = list("RArm", "RBack", "LBack"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(12, 12, 22, 17, 18, 12, 12), "move" = 1.25, "atk" = 1.00, "passive" = list("Afterburner", 1, "GunStrafe", 1), "baked" = list("/obj/Skills/Projectile/Mech/Strafing_Run"),\
		"rise" = 4, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot09" = list("name" = "Fighter", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV09, "state" = "", "fly" = 1, "hover" = 0,\
		"slots" = list("RBack", "LBack", "RArm"), "fixed" = list("RArm"), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(8, 16, 14, 20, 20, 16, 18), "move" = 0.95, "atk" = 1.10, "passive" = list("Fire Control", 1, "GunRollingThunder", 1), "baked" = list("/obj/Skills/Projectile/Mech/Barrage_Lock"),\
		"rise" = 4, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot10_01" = list("name" = "Cross", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV10A, "state" = "", "fly" = 1, "hover" = 0,\
		"slots" = list("RBack", "LBack", "RArm"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(6, 10, 24, 19, 19, 12, 9), "move" = 1.30, "atk" = 0.95, "passive" = list("Bit Mothership", 1), "baked" = list("/obj/Skills/Mech/Evasive_Roll"),\
		"rise" = 4, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot10_02" = list("name" = "Lancer", "class" = "Medium", "size" = MECH_SIZE_MEDIUM, "icon" = MECH_ICON_TV10B, "state" = "", "fly" = 0, "hover" = 0,\
		"slots" = list("RArm", "LArm", "RBack"), "fixed" = list(), "internals" = MECH_INTERNALS_MEDIUM, "sockets" = MECH_SOCKETS_MEDIUM,\
		"stats" = list(17, 13, 21, 15, 18, 14, 12), "move" = 1.20, "atk" = 0.85, "passive" = list("Pilot Sync", 1), "baked" = list("/obj/Skills/Mech/Vault"),\
		"rise" = 0, "offset_x" = -32, "offset_y" = 0, "plating_n" = MECH_PLATING_MEDIUM, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot06" = list("name" = "Strider", "class" = "Heavy", "size" = MECH_SIZE_HEAVY, "icon" = MECH_ICON_TV06, "state" = "", "fly" = 0, "hover" = 1,\
		"slots" = list("RArm", "LArm", "RBack", "LBack"), "fixed" = list(), "internals" = MECH_INTERNALS_HEAVY, "sockets" = MECH_SOCKETS_HEAVY,\
		"stats" = list(16, 20, 12, 20, 17, 20, 24), "move" = 0.85, "atk" = 1.15, "passive" = list("Hover Chassis", 1), "baked" = list("/obj/Skills/Projectile/Mech/Pod_Salvo"),\
		"rise" = 0, "offset_x" = -64, "offset_y" = 0, "plating_n" = MECH_PLATING_HEAVY, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2),\
	"TV_Robot07" = list("name" = "Overseer", "class" = "Heavy", "size" = MECH_SIZE_HEAVY, "icon" = MECH_ICON_TV07, "state" = "", "fly" = 0, "hover" = 0,\
		"slots" = list("RArm", "LArm", "RBack", "LBack"), "fixed" = list(), "internals" = MECH_INTERNALS_HEAVY, "sockets" = MECH_SOCKETS_HEAVY,\
		"stats" = list(14, 18, 10, 22, 20, 18, 22), "move" = 0.80, "atk" = 1.20, "passive" = list("Sensor Array", 1), "baked" = list("/obj/Skills/Mech/Sensor_Overload"),\
		"rise" = 0, "offset_x" = -64, "offset_y" = 0, "plating_n" = MECH_PLATING_HEAVY, "wreck_color" = MECH_WRECK_TINT, "fly_accel" = 0.125, "fly_drag" = 0.32, "fly_vmax" = 1.2))

var/list/MECH_METAL_TRAITS = list(\
	"copper" = list(0.90, 0.95, 1.05),\
	"tin" = list(0.85, 0.90, 1.10),\
	"bronze" = list(1.05, 1.00, 1.00),\
	"iron" = list(1.00, 1.00, 1.00),\
	"steel" = list(1.10, 1.05, 0.95),\
	"silver" = list(1.00, 1.00, 1.10),\
	"gold" = list(1.10, 0.95, 0.95),\
	"cobalt" = list(1.05, 1.10, 1.00),\
	"mythril" = list(0.95, 1.00, 1.15),\
	"adamantite" = list(1.20, 1.15, 0.85),\
	"starmetal" = list(1.10, 1.10, 1.05),\
	"orichalcum" = list(1.15, 1.10, 1.10))

var/list/MECH_KITS = list(\
	"Speed" = list("Spd" = 3, "Vit" = -2, "End" = -1),\
	"Tank" = list("Vit" = 3, "End" = 2, "Spd" = -3),\
	"Assault" = list("Str" = 3, "For" = 2, "Def" = -2),\
	"Mobile Fighter" = list("Str" = 2, "Spd" = 2, "Off" = 1, "Vit" = -3, "pilot_heat" = 0.8))

var/list/MECH_COATINGS = list(\
	"GoblinHide" = list("MeleeResist", 1, "resist"),\
	"BoarSinew" = list("MechMeleeKnockback", 1, "effect"),\
	"WolfFang" = list("MechMeleeBleed", 1, "effect"),\
	"TurtleLeg" = list("MechHullPct", 5, "effect"),\
	"DrakeScale" = list("FireResist", 2, "resist", "MechBurnHeatHalf", 1, "effect"),\
	"TurtleShell" = list("MechHullMend", 1, "effect"),\
	"HarpyTalon" = list("MechThrustPct", 25, "effect", "MechDriftPct", 20, "effect"),\
	"Ectoplasm" = list("MechEMPStallPct", 50, "effect"),\
	"OgreSinew" = list("MechMeleePct", 10, "effect"),\
	"ScorpionSting" = list("MechMeleeHeat", 5, "effect"),\
	"WyvernBeak" = list("MechRangedArmPct", 8, "effect"),\
	"NagaScale" = list("WaterResist", 2, "resist", "ChillResist", 2, "resist"),\
	"DemonHorn" = list("MechLowHullRage", 15, "effect"),\
	"CyclopsEye" = list("MechAccuracy", 0.1, "effect", "MechHomingUp", 1, "effect"),\
	"YetiHorn" = list("IceResist", 2, "resist", "MechDissipationPct", 15, "effect"),\
	"DragonScale" = list("FireResist", 1, "resist", "WaterResist", 1, "resist", "EarthResist", 1, "resist", "WindResist", 1, "resist", "IceResist", 1, "resist", "LightningResist", 1, "resist", "MechHullPct", 10, "effect"),\
	"DragonBone" = list("MechKnockbackStep", 1, "effect"),\
	"DragonEssence" = list("MechLimitPct", 30, "effect"),\
	"FireDragonClaw" = list("MechRiderBurn", 1, "effect"),\
	"WhiteDragonClaw" = list("MechRiderChill", 1, "effect"),\
	"WaterDragonClaw" = list("MechRiderWater", 1, "effect"),\
	"GoldenDragonClaw" = list("MechRiderShock", 1, "effect"),\
	"PoisonDragonClaw" = list("MechRiderPoison", 1, "effect"))

var/list/MECH_CORE_BY_TIER = list(null, "SlimeCore", "MudGolemCore", "StoneGolemCore", "ColossalCore")

var/list/MECH_PAINTS = list(\
	"White" = "#e6e6e6",\
	"Gunmetal" = "#5c6670",\
	"Crimson" = "#b22234",\
	"Cobalt" = "#2f5fb3",\
	"Forest" = "#3f7a3a",\
	"Sand" = "#c8b27a",\
	"Black" = "#1e1e22",\
	"Gold" = "#d4a93a")

proc/MechModelRow(key)
	if(!key) return null
	return MECH_MODELS[key]

proc/MechModelTier(key)
	var/list/row = MECH_MODELS[key]
	if(!row) return MECH_TIER_WALKER
	return row["class"] == "Light" ? MECH_TIER_LIGHT : MECH_TIER_WALKER

proc/MechMetalTraits(mid)
	var/list/t = mid ? MECH_METAL_TRAITS[lowertext("[mid]")] : null
	if(!t) t = MECH_METAL_TRAITS["iron"]
	return t.Copy()

proc/MechCoatingRow(mc)
	if(!mc) return null
	return MECH_COATINGS[mc]

proc/MechCoatingName(mc)
	if(!mc) return "none"
	return LifeMatName(mc)

proc/MechKitRow(kit)
	if(!kit) return null
	return MECH_KITS[kit]

proc/MechCoreClassForTier(t)
	t = clamp(round(t), MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)
	return MECH_CORE_BY_TIER[t]

proc/MechClassRecipeCount(cls, what)
	switch(what)
		if("Servo")
			switch(cls)
				if("Light") return MECH_SERVO_LIGHT
				if("Medium") return MECH_SERVO_MEDIUM
			return MECH_SERVO_HEAVY
		if("Cell")
			switch(cls)
				if("Light") return MECH_CELL_LIGHT
				if("Medium") return MECH_CELL_MEDIUM
			return MECH_CELL_HEAVY
		if("Casing")
			switch(cls)
				if("Light") return MECH_CASING_LIGHT
				if("Medium") return MECH_CASING_MEDIUM
			return MECH_CASING_HEAVY
		if("Wiring")
			switch(cls)
				if("Light") return MECH_WIRING_LIGHT
				if("Medium") return MECH_WIRING_MEDIUM
			return MECH_WIRING_HEAVY
	return 0

/datum/life_tagset/mech
	New()
		..()
		tags = list()
		for(var/mc in MECH_COATINGS)
			tags[mc] = list("coating")
