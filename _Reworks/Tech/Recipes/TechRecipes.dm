/obj/Items/Tech/Bandage
	name = "Bandage"
	desc = "A roll of clean dressing. Click it to bind a small wound on yourself."
	icon = 'Tech.dmi'
	icon_state = "FirstAid"
	Stackable = 1

	Click()
		if(!(src in usr)) return ..()
		usr.UseBandage(src)

mob/proc/UseBandage(obj/Items/Tech/Bandage/B)
	if(!B || B.loc != src) return 0
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science")) return 0
	if(InCombat())
		src << "In a fight you can only use what is on your belt."
		return 0
	if(KO)
		src << "You can't bind a wound while knocked out."
		return 0
	if(TotalInjury <= 0)
		src << "You have no wound to bind."
		return 0
	HealWounds(TECH_BANDAGE_HEAL)
	OMsg(src, "[src] binds a wound.")
	B.TotalStack--
	if(B.TotalStack <= 0)
		del B
	else
		B.suffix = "[B.TotalStack]"
	if(client) client.BuildInvPage()
	return 1

/datum/craft_recipe/lifecraft/tech/field/wiring
	id = "tech_wiring"
	label = "Wiring"
	tier = 1
	result_type = /obj/Items/Material/Part/Wiring
	slotspec = list(list("Copper", 1, "mat:Copper", 1))

/datum/craft_recipe/lifecraft/tech/part/casing
	id = "tech_casing"
	label = "Casing"
	tier = 1
	result_type = /obj/Items/Material/Part/Casing
	slotspec = list(list("Metal", 1, TECH_SEL_INGOT, 1))

/datum/craft_recipe/lifecraft/tech/part/propellant
	id = "tech_propellant"
	label = "Propellant"
	tier = 1
	result_type = /obj/Items/Material/Part/Propellant
	slotspec = list(\
		list("Coal", 1, "mat:Coal", 1),\
		list("Guano", 1, "mat:BatGuano", 1))

/datum/craft_recipe/lifecraft/tech/part/biogel
	id = "tech_biogel"
	label = "BioGel"
	tier = 1
	result_type = /obj/Items/Material/Part/BioGel
	slotspec = list(\
		list("Herb", 1, TECH_SEL_HERB, 1),\
		list("Gelatin", 1, "mat:Gelatin", 1))

/datum/craft_recipe/lifecraft/tech/part/circuit_board
	id = "tech_circuit_board"
	label = "Circuit Board"
	tier = 2
	knowledge_req = "Fabrication"
	result_type = /obj/Items/Material/Part/CircuitBoard
	slotspec = list(\
		list("Wiring", 1, TECH_MAT_WIRING, 1),\
		list("Metal", 1, TECH_SEL_PRECIOUS, 1),\
		list("Gelatin", 1, "mat:Gelatin", 1))

/datum/craft_recipe/lifecraft/tech/part/servo
	id = "tech_servo"
	label = "Servo"
	tier = 2
	knowledge_req = "Fabrication"
	result_type = /obj/Items/Material/Part/Servo
	slotspec = list(\
		list("Steel", 1, "mat:Steel", 1),\
		list("Sinew", 1, TECH_SEL_SINEW, 1))

/datum/craft_recipe/lifecraft/tech/part/power_cell
	id = "tech_power_cell"
	label = "Power Cell"
	tier = 2
	knowledge_req = "Fabrication"
	result_type = /obj/Items/Material/Part/PowerCell
	slotspec = list(\
		list("Core", 1, TECH_SEL_CORE, 1),\
		list("Cobalt", 1, "mat:Cobalt", 1))

/datum/craft_recipe/lifecraft/tech/part/lens
	id = "tech_lens"
	label = "Lens"
	tier = 3
	knowledge_req = "Fabrication"
	result_type = /obj/Items/Material/Part/Lens
	slotspec = list(\
		list("Shards", 1, "mat:GemShards", 1),\
		list("Silver", 1, "mat:Silver", 1))

/datum/craft_recipe/lifecraft/tech/part/fuel_cell
	id = "tech_fuel_cell"
	label = "Fuel Cell"
	tier = 3
	knowledge_req = "Power Generators"
	result_type = /obj/Items/Material/Part/FuelCell
	slotspec = list(list("Fuel", 1, TECH_SEL_FUEL, 1))

/datum/craft_recipe/lifecraft/tech/part/nanites
	id = "tech_nanites"
	label = "Nanites"
	tier = 5
	knowledge_req = "Fabrication"
	result_type = /obj/Items/Material/Part/Nanites
	slotspec = list(\
		list("Starmetal", 1, "mat:Starmetal", 1),\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Core", 1, "mat:ColossalCore", 1))

/datum/craft_recipe/lifecraft/tech/door/key
	id = "tech_key"
	label = "Key"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Door_Pass
	drop_slots = list("Casing")
	metal_n = 1
	locked = 0

/datum/craft_recipe/lifecraft/tech/door/digital_key
	id = "tech_digital_key"
	label = "Digital Key"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Digital_Key
	drop_slots = list("Casing")
	metal_n = 1
	locked = 0

/datum/craft_recipe/lifecraft/tech/door/security_door
	id = "tech_security_door"
	label = "Security Door"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Door/Door2

/datum/craft_recipe/lifecraft/tech/door/plexiglas_door
	id = "tech_plexiglas_door"
	label = "Plexiglas Door"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Door/TransparentDoor
	glazed = 1

/datum/craft_recipe/lifecraft/tech/door/laser_gate
	id = "tech_laser_gate"
	label = "Laser Gate"
	tier = 1
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Door/LazerDoor/LaserDoor3Wide
	glazed = 1

/datum/craft_recipe/lifecraft/tech/door/reinforced_door
	id = "tech_reinforced_door"
	label = "Reinforced Door"
	tier = 3
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Reinforced_Door
	metal_sel = "mat:Steel"

/datum/craft_recipe/lifecraft/tech/door/reinforced_remote
	id = "tech_reinforced_remote"
	label = "Reinforced Remote"
	tier = 3
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Reinforced_Remote
	metal_sel = "mat:Steel"
	locked = 0

/datum/craft_recipe/lifecraft/tech/placed/safe
	id = "tech_safe"
	label = "Safe"
	tier = 2
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/Safe
	metal_sel = "mat:Steel"

/datum/craft_recipe/lifecraft/tech/wearable/air_mask
	id = "tech_air_mask"
	label = "Air Mask"
	tier = 2
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/SpaceMask
	drop_slots = list("Servo", "Cell")

/datum/craft_recipe/lifecraft/tech/wearable/rebreather
	id = "tech_rebreather"
	label = "Rebreather"
	tier = 2
	knowledge_req = "Engineering"
	result_type = /obj/Items/Tech/SpaceMask/Rebreather
	drop_slots = list("Servo", "Cell")

/datum/craft_recipe/lifecraft/tech/field/power_pack
	id = "tech_power_pack"
	label = "Power Pack"
	tier = 2
	knowledge_req = "Fabrication"
	result_type = /obj/Items/Tech/Power_Pack
	result_count = TECH_POWERPACK_PER_RUN
	slotspec = list(\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Casing", 1, TECH_MAT_CASING, 1))

/datum/craft_recipe/lifecraft/tech/placed/charging_station
	id = "tech_charging_station"
	label = "Charging Station"
	tier = 3
	knowledge_req = "Power Generators"
	result_type = /obj/Items/Tech/Charging_Station
	add_slots = list(list("Cell", 2, TECH_MAT_CELL, 1))

/datum/craft_recipe/lifecraft/tech/wearable/hazard_suit
	id = "tech_hazard_suit"
	label = "Hazard Suit"
	tier = 3
	knowledge_req = "Hazard Suits"
	result_type = /obj/Items/Gear/Hazard_Suit

/datum/craft_recipe/lifecraft/tech/wearable/sealed_suit
	id = "tech_sealed_suit"
	label = "Sealed Suit"
	tier = 4
	knowledge_req = "Hazard Suits"
	result_type = /obj/Items/Gear/Sealed_Suit
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/wearable/deflector_shield
	id = "tech_deflector_shield"
	label = "Deflector Shield"
	tier = 4
	knowledge_req = "Force Shielding"
	result_type = /obj/Items/Gear/Deflector_Shield
	add_slots = list(list("Board", 1, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/wearable/bubble_shield
	id = "tech_bubble_shield"
	label = "Bubble Shield"
	tier = 4
	knowledge_req = "Force Shielding"
	result_type = /obj/Items/Gear/Bubble_Shield
	add_slots = list(list("Board", 1, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/handheld/communicator
	id = "tech_communicator"
	label = "Communicator"
	tier = 1
	knowledge_req = "Telecommunications"
	result_type = /obj/Items/Tech/Communicator

/datum/craft_recipe/lifecraft/tech/handheld/speaker
	id = "tech_speaker"
	label = "Speaker"
	tier = 1
	knowledge_req = "Telecommunications"
	result_type = /obj/Items/Tech/Speaker

/datum/craft_recipe/lifecraft/tech/handheld/doorbell
	id = "tech_doorbell"
	label = "Doorbell"
	tier = 1
	knowledge_req = "Telecommunications"
	result_type = /obj/Items/Tech/Doorbell

/datum/craft_recipe/lifecraft/tech/handheld/binoculars
	id = "tech_binoculars"
	label = "Binoculars"
	tier = 1
	knowledge_req = "Telecommunications"
	result_type = /obj/Items/Tech/Binoculars
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/pda
	id = "tech_pda"
	label = "PDA"
	tier = 1
	knowledge_req = "Telecommunications"
	result_type = /obj/Items/Tech/PDA

/datum/craft_recipe/lifecraft/tech/handheld/jukebox
	id = "tech_jukebox"
	label = "Jukebox"
	tier = 1
	knowledge_req = "Telecommunications"
	result_type = /obj/Items/Tech/Jukebox

/datum/craft_recipe/lifecraft/tech/handheld/scouter
	id = "tech_scouter"
	label = "Scouter"
	tier = 2
	knowledge_req = "Scouters"
	result_type = /obj/Items/Tech/Scouter
	add_slots = list(list("Lens", 1, TECH_MAT_LENS, 1))

	MakeResult(mob/M, q, perf)
		. = ..()
		var/obj/Items/Tech/Scouter/S = .
		if(M && istype(S))
			spawn() M.ScouterIconPrompt(S)

/datum/craft_recipe/lifecraft/tech/handheld/wiretap
	id = "tech_wiretap"
	label = "Wiretap"
	tier = 2
	knowledge_req = "Espionage Equipment"
	result_type = /obj/Items/Tech/Wiretap

/datum/craft_recipe/lifecraft/tech/placed/transmission_tower
	id = "tech_transmission_tower"
	label = "Transmission Tower"
	tier = 3
	knowledge_req = "Wide Area Transmission"
	result_type = /obj/Items/Tech/Transmission_Tower

/datum/craft_recipe/lifecraft/tech/handheld/beacon
	id = "tech_beacon"
	label = "Beacon"
	tier = 3
	knowledge_req = "Wide Area Transmission"
	result_type = /obj/Items/Tech/Beacon

/datum/craft_recipe/lifecraft/tech/handheld/hacking_device
	id = "tech_hacking_device"
	label = "Hacking Device"
	tier = 3
	knowledge_req = "Intrusion Tools"
	result_type = /obj/Items/Tech/Hacking_Device
	add_slots = list(list("Board", 2, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/wearable/cloak
	id = "tech_cloak"
	label = "Cloak"
	tier = 4
	knowledge_req = "Obfuscation Equipment"
	result_type = /obj/Items/Tech/Cloak
	add_slots = list(list("Lens", 2, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/cloak_controls
	id = "tech_cloak_controls"
	label = "Cloak Controls"
	tier = 4
	knowledge_req = "Obfuscation Equipment"
	result_type = /obj/Items/Tech/Cloak_Controls

/datum/craft_recipe/lifecraft/tech/placed/projector_tower
	id = "tech_projector_tower"
	label = "Projector Tower"
	tier = 4
	knowledge_req = "EM Wave Projectors"
	result_type = /obj/Items/Tech/Projector_Tower

/datum/craft_recipe/lifecraft/tech/handheld/portable_projector
	id = "tech_portable_projector"
	label = "Portable Projector"
	tier = 4
	knowledge_req = "EM Wave Projectors"
	result_type = /obj/Items/Tech/Portable_Projector

/datum/craft_recipe/lifecraft/tech/wearable/prosthetic_limb
	id = "tech_prosthetic_limb"
	label = "Prosthetic Limb"
	tier = 1
	knowledge_req = "Cyber Engineering"
	result_type = /obj/Items/Gear/Prosthetic_Limb
	drop_slots = list("Cell")
	add_slots = list(list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip_controller
	id = "tech_chip_controller"
	label = "Chip Controller"
	tier = 4
	knowledge_req = "War Crimes"
	result_type = /obj/Items/Tech/Chip_Controller
	add_slots = list(list("Board", 2, TECH_MAT_BOARD, 1))

/datum/craft_recipe/lifecraft/tech/field/bandage
	id = "tech_bandage"
	label = "Bandage"
	tier = 1
	knowledge_req = "Medicine"
	result_type = /obj/Items/Tech/Bandage
	result_count = TECH_BANDAGE_PER_RUN
	slotspec = list(list("Gel", 1, TECH_MAT_BIOGEL, 1))

/datum/craft_recipe/lifecraft/tech/consumable/first_aid_kit
	id = "tech_first_aid_kit"
	label = "First Aid Kit"
	tier = 1
	knowledge_req = "Medicine"
	result_type = /obj/Items/Tech/First_Aid_Kit

/datum/craft_recipe/lifecraft/tech/consumable/perfume
	id = "tech_perfume"
	label = "Perfume"
	tier = 1
	knowledge_req = "Medicine"
	result_type = /obj/Items/Tech/Perfume
	add_slots = list(list("Herb", 1, TECH_SEL_HERB, 1))

/datum/craft_recipe/lifecraft/tech/consumable/soap
	id = "tech_soap"
	label = "Soap"
	tier = 1
	knowledge_req = "Medicine"
	result_type = /obj/Items/Tech/Soap
	add_slots = list(list("Gelatin", 1, "mat:Gelatin", 1))

/datum/craft_recipe/lifecraft/tech/consumable/medkit
	id = "tech_medkit"
	label = "Medkit"
	tier = 2
	knowledge_req = "Medkits"
	result_type = /obj/Items/Tech/Medkit

/datum/craft_recipe/lifecraft/tech/consumable/antivenom
	id = "tech_antivenom"
	label = "Fast-Acting Antivenom"
	tier = 2
	knowledge_req = "Fast Acting Medicine"
	result_type = /obj/Items/Tech/Fast_Acting_Antivenom

/datum/craft_recipe/lifecraft/tech/consumable/cooling_spray
	id = "tech_cooling_spray"
	label = "Isothermic Spray"
	tier = 2
	knowledge_req = "Fast Acting Medicine"
	result_type = /obj/Items/Tech/Cooling_Spray

/datum/craft_recipe/lifecraft/tech/consumable/sealing_spray
	id = "tech_sealing_spray"
	label = "Sealing Spray"
	tier = 2
	knowledge_req = "Fast Acting Medicine"
	result_type = /obj/Items/Tech/Sealing_Spray

/datum/craft_recipe/lifecraft/tech/consumable/focus_stabilizer
	id = "tech_focus_stabilizer"
	label = "Focus Stabilizer"
	tier = 2
	knowledge_req = "Fast Acting Medicine"
	result_type = /obj/Items/Tech/Focus_Stabilizer

/datum/craft_recipe/lifecraft/tech/consumable/anesthetics
	id = "tech_anesthetics"
	label = "Anesthetics"
	tier = 2
	knowledge_req = "Fast Acting Medicine"
	result_type = /obj/Items/Tech/Anesthetics

/datum/craft_recipe/lifecraft/tech/consumable/steroid
	id = "tech_steroid"
	label = "Steroid"
	tier = 3
	knowledge_req = "Enhancers"
	result_type = /obj/Items/Tech/Steroid
	add_slots = list(list("Gelatin", 2, "mat:Gelatin", 1))

/datum/craft_recipe/lifecraft/tech/consumable/revitalization_serum
	id = "tech_revitalization_serum"
	label = "Revitalization Serum"
	tier = 4
	knowledge_req = "Regenerative Medicine"
	result_type = /obj/Items/Tech/Revitalization_Serum

/datum/craft_recipe/lifecraft/tech/consumable/genome_enhance_serum
	id = "tech_genome_enhance_serum"
	label = "Genome Enhance Serum"
	tier = 4
	knowledge_req = "Regenerative Medicine"
	result_type = /obj/Items/Tech/Genome_Enhance_Serum

/datum/craft_recipe/lifecraft/tech/consumable/super_soldier_serum
	id = "tech_super_soldier_serum"
	label = "Super Soldier Serum"
	tier = 4
	knowledge_req = "Regenerative Medicine"
	result_type = /obj/Items/Tech/Super_Soldier_Serum

/datum/craft_recipe/lifecraft/tech/consumable/genome_warp_serum
	id = "tech_genome_warp_serum"
	label = "Genome Warp Serum"
	tier = 4
	knowledge_req = "Regenerative Medicine"
	result_type = /obj/Items/Tech/Genome_Warp_Serum
	add_slots = list(list("Nanites", 1, TECH_MAT_NANITES, 1))

/datum/craft_recipe/lifecraft/tech/placed/regenerator_tank
	id = "tech_regenerator_tank"
	label = "Regenerator Tank"
	tier = 4
	knowledge_req = "Regenerator Tanks"
	result_type = /obj/Items/Tech/Regenerator_Tank
	add_slots = list(list("Cell", 2, TECH_MAT_CELL, 1))

var/list/TECH_AUDIT_EXCLUDE = list(\
	/obj/Items/Tech = "abstract root",\
	/obj/Items/Gear = "abstract root",\
	/obj/Items/Tech/Door/LazerDoor = "Unobtainable parent of the Laser Gate",\
	/obj/Items/Tech/Door/LazerDoor/LazerDoorLeft = "Unobtainable Laser Gate segment, in no menu",\
	/obj/Items/Tech/Door/LazerDoor/LazerDoorRight = "Unobtainable Laser Gate segment, in no menu",\
	/obj/Items/Tech/Door/LazerDoor/LazerDoorMiddle = "Unobtainable Laser Gate segment, in no menu",\
	/obj/Items/Tech/Door = "retired, OWNER 2026-09-23",\
	/obj/Items/Tech/Door/Guild_Door = "OWNER 32, Guild doors",\
	/obj/Items/Tech/Door/Guild_Door/Guild_Door_Transparent = "OWNER 32, Guild doors",\
	/obj/Items/Tech/Lockpick = "OWNER 32, Smithing",\
	/obj/Items/Tech/Fiber_Bonding_Agent = "OWNER 32, Smithing",\
	/obj/Items/Tech/Quicksilver_Alloy = "OWNER 32, Smithing",\
	/obj/Items/Tech/Trick_Weapon_Kit = "OWNER 32, Smithing",\
	/obj/Items/Tech/Resistant_Coating = "OWNER 32, Smithing",\
	/obj/Items/Tech/Conservation_Kit = "Smithing, durability, OWNER 2026-09-23",\
	/obj/Items/Tech/Jukebox/Disco = "admin only, OWNER 2026-09-23",\
	/obj/Items/Gear/Ultra_Laser = "mid-wipe, Heavy Ordnance, OWNER 2026-09-23",\
	/obj/Items/Gear/Missile_Massacre = "mid-wipe, Heavy Ordnance, OWNER 2026-09-23",\
	/obj/Items/Gear/Missile_Launcher = "brief 15, Heavy Weaponry, OWNER 2026-09-23",\
	/obj/Items/Gear/Chemical_Mortar = "brief 15, Heavy Weaponry, OWNER 2026-09-23",\
	/obj/Items/Gear/Incinerator = "brief 15, Heavy Weaponry, OWNER 2026-09-23",\
	/obj/Items/Gear/Freeze_Ray = "brief 15, Heavy Weaponry, OWNER 2026-09-23",\
	/obj/Items/Gear/Hougyoku = "OWNER 32, saga",\
	/obj/Items/Gear/Hougyoku/Complete_Hougyoku = "OWNER 32, saga",\
	/obj/Items/Gear/Dark_Factor_Fragment = "OWNER 32, saga",\
	/obj/Items/Gear/Spiral_Engine = "OWNER 32, saga",\
	/obj/Items/Gear/Plasma_Blaster = "retired, brief 14 step 7",\
	/obj/Items/Gear/Plasma_Rifle = "retired, brief 14 step 7",\
	/obj/Items/Gear/Plasma_Gatling = "retired, brief 14 step 7",\
	/obj/Items/Gear/Mobile_Suit = "retired, brief 14 step 7",\
	/obj/Items/Gear/Automated_Aid_Dispenser = "retired, brief 14 step 7, the Aid Station is brief 20",\
	/obj/Items/Tech/PainKillers = "brief 22b",\
	/obj/Items/Tech/Security_Camera = "mid-wipe, Combat Scanning",\
	/obj/Items/Tech/Security_Display = "mid-wipe, Combat Scanning",\
	/obj/Items/Tech/PunchingBag = "brief 20, Training Dummy",\
	/obj/Items/Gear/Jet_Boots = "brief 19, jets",\
	/obj/Items/Gear/Jet_Pack = "brief 19, jets",\
	/obj/Items/Gear/Progressive_Blade = "brief 19, blades",\
	/obj/Items/Gear/Power_Armor = "brief 19, Exosuit",\
	/obj/Items/Gear/Power_Armor_Burst = "brief 19, Exosuit",\
	/obj/Items/Gear/Power_Armor_Burly = "brief 19, Exosuit",\
	/obj/Items/Gear/Power_Armor_Blitz = "brief 19, Exosuit",\
	/obj/Items/Gear/Blast_Fist = "brief 19, modules",\
	/obj/Items/Gear/Power_Fist = "brief 19, modules",\
	/obj/Items/Gear/Pile_Bunker = "brief 19, modules",\
	/obj/Items/Gear/Chainsaw = "brief 19, modules",\
	/obj/Items/Gear/Power_Claw = "brief 19, modules",\
	/obj/Items/Gear/Hook_Grip_Claw = "brief 19, modules",\
	/obj/Items/Gear/Lightsaber = "brief 19, sabers",\
	/obj/Items/Gear/Double_Lightsaber = "brief 19, sabers",\
	/obj/Items/Gear/Great_Lightsaber = "brief 19, sabers",\
	/obj/Items/Gear/Crossguard_Lightsaber = "brief 19, sabers",\
	/obj/Items/Gear/Shoto_Lightsaber = "brief 19, sabers",\
	/obj/Items/Tech/Planted_Wiretap = "made by planting a Wiretap, not an item anyone crafts",\
	/obj/Items/Tech/Log = "map-loading stub, not an item",\
	/obj/Items/Tech/CameraProbe = "map-loading stub, not an item",\
	/obj/Items/Tech/ConveyorBelt = "map-loading stub, not an item",\
	/obj/Items/Tech/AutoDrill = "map-loading stub, not an item",\
	/obj/Items/Tech/Regenerator = "map-loading stub, not an item",\
	/obj/Items/Tech/SpaceTravel = "map-loading stub, not an item",\
	/obj/Items/Gear/Prosthetic_Limb/Blue_Grimoire = "Wizardry item, not Technology",\
	/obj/Items/Gear/Prosthetic_Limb/Azure_Grimoire = "Wizardry item, not Technology",\
	/obj/Items/Gear/Crimson_Grimoire = "Wizardry item, not Technology",\
	/obj/Items/Gear/Blood_Grimoire = "Wizardry item, not Technology")
