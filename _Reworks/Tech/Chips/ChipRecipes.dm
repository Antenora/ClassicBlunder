/datum/craft_recipe/lifecraft/tech/handheld/chip

/datum/craft_recipe/lifecraft/tech/handheld/chip/stat
	tier = 1
	knowledge_req = "Cyber Augmentations"
	add_slots = list(\
		list("Wiring", 1, TECH_MAT_WIRING, 1),\
		list("Silver", 1, "mat:Silver", 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip/stat/enhanced_strength
	id = "chip_enhanced_strength"
	label = "Enhanced Strength"
	result_type = /obj/Items/Chip/Stat/Enhanced_Strength

/datum/craft_recipe/lifecraft/tech/handheld/chip/stat/enhanced_force
	id = "chip_enhanced_force"
	label = "Enhanced Force"
	result_type = /obj/Items/Chip/Stat/Enhanced_Force

/datum/craft_recipe/lifecraft/tech/handheld/chip/stat/enhanced_endurance
	id = "chip_enhanced_endurance"
	label = "Enhanced Endurance"
	result_type = /obj/Items/Chip/Stat/Enhanced_Endurance

/datum/craft_recipe/lifecraft/tech/handheld/chip/stat/enhanced_aggression
	id = "chip_enhanced_aggression"
	label = "Enhanced Aggression"
	result_type = /obj/Items/Chip/Stat/Enhanced_Aggression

/datum/craft_recipe/lifecraft/tech/handheld/chip/stat/enhanced_reflexes
	id = "chip_enhanced_reflexes"
	label = "Enhanced Reflexes"
	result_type = /obj/Items/Chip/Stat/Enhanced_Reflexes

/datum/craft_recipe/lifecraft/tech/handheld/chip/stat/enhanced_speed
	id = "chip_enhanced_speed"
	label = "Enhanced Speed"
	result_type = /obj/Items/Chip/Stat/Enhanced_Speed

/datum/craft_recipe/lifecraft/tech/handheld/chip/routine
	tier = 2
	knowledge_req = "Combat Routines"
	drop_slots = list("Casing", "Wiring")
	add_slots = list(list("Servo", 1, TECH_MAT_SERVO, 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip/routine/taser_strike
	id = "chip_taser_strike"
	label = "Taser Strike"
	result_type = /obj/Items/Chip/Routine/Taser_Strike

/datum/craft_recipe/lifecraft/tech/handheld/chip/routine/rocket_punch
	id = "chip_rocket_punch"
	label = "Rocket Punch"
	result_type = /obj/Items/Chip/Routine/Rocket_Punch

/datum/craft_recipe/lifecraft/tech/handheld/chip/routine/internal_comms_suite
	id = "chip_internal_comms_suite"
	label = "Internal Comms Suite"
	result_type = /obj/Items/Chip/Routine/Internal_Comms_Suite

/datum/craft_recipe/lifecraft/tech/handheld/chip/routine/machine_gun_flurry
	id = "chip_machine_gun_flurry"
	label = "Machine Gun Flurry"
	result_type = /obj/Items/Chip/Routine/Machine_Gun_Flurry

/datum/craft_recipe/lifecraft/tech/handheld/chip/system
	tier = 3
	knowledge_req = "Neuron Manipulation"
	drop_slots = list("Casing", "Wiring", "Optic")
	add_slots = list(\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/nano_boost
	id = "chip_nano_boost"
	label = "Nano Boost"
	result_type = /obj/Items/Chip/System/Nano_Boost

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/combat_cpu
	id = "chip_combat_cpu"
	label = "Combat CPU"
	result_type = /obj/Items/Chip/System/Combat_CPU

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/stealth_systems
	id = "chip_stealth_systems"
	label = "Stealth Systems"
	result_type = /obj/Items/Chip/System/Stealth_Systems

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/reconstructive_nanobots
	id = "chip_reconstructive_nanobots"
	label = "Reconstructive Nanobots"
	result_type = /obj/Items/Chip/System/Reconstructive_Nanobots

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/blade_mode
	id = "chip_blade_mode"
	label = "Blade Mode"
	result_type = /obj/Items/Chip/System/Blade_Mode

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/internal_life_support
	id = "chip_internal_life_support"
	label = "Internal Life Support"
	result_type = /obj/Items/Chip/System/Internal_Life_Support

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/energy_assimilators
	id = "chip_energy_assimilators"
	label = "Energy Assimilators"
	result_type = /obj/Items/Chip/System/Energy_Assimilators

/datum/craft_recipe/lifecraft/tech/handheld/chip/system/targeting_cpu
	id = "chip_targeting_cpu"
	label = "Targeting CPU"
	result_type = /obj/Items/Chip/System/Targeting_CPU
	add_slots = list(\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Lens", 1, TECH_MAT_LENS, 1),\
		list("Shards", 1, "mat:GemShards", 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip/control
	tier = 4
	knowledge_req = "War Crimes"
	drop_slots = list("Casing", "Wiring", "Optic")
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1),\
		list("Gold", 1, "mat:Gold", 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip/control/punishment_chip
	id = "chip_punishment_chip"
	label = "Punishment Chip"
	result_type = /obj/Items/Chip/Control/Punishment_Chip

/datum/craft_recipe/lifecraft/tech/handheld/chip/control/failsafe_circuit
	id = "chip_failsafe_circuit"
	label = "Failsafe Circuit"
	result_type = /obj/Items/Chip/Control/Failsafe_Circuit

/datum/craft_recipe/lifecraft/tech/handheld/chip/control/explosive_implantation
	id = "chip_explosive_implantation"
	label = "Explosive Implantation"
	result_type = /obj/Items/Chip/Control/Explosive_Implantation

/datum/craft_recipe/lifecraft/tech/handheld/chip/control/cybernetic_mainframe
	id = "chip_cybernetic_mainframe"
	label = "Cybernetic Mainframe"
	knowledge_req = "Cybernetic Mainframe"
	result_type = /obj/Items/Chip/Frame/Cybernetic_Mainframe

/datum/craft_recipe/lifecraft/tech/handheld/chip/frame
	tier = 5
	knowledge_req = "Singularity"
	drop_slots = list("Casing", "Wiring", "Optic")
	add_slots = list(\
		list("Board", 1, TECH_MAT_BOARD, 1),\
		list("Cell", 2, TECH_MAT_CELL, 1),\
		list("Nanites", 1, TECH_MAT_NANITES, 1))

/datum/craft_recipe/lifecraft/tech/handheld/chip/frame/ripper_mode
	id = "chip_ripper_mode"
	label = "Ripper Mode"
	result_type = /obj/Items/Chip/Frame/Ripper_Mode

/datum/craft_recipe/lifecraft/tech/handheld/chip/frame/armstrong_augmentation
	id = "chip_armstrong_augmentation"
	label = "Armstrong Augmentation"
	result_type = /obj/Items/Chip/Frame/Armstrong_Augmentation

/datum/craft_recipe/lifecraft/tech/handheld/chip/frame/ray_gear
	id = "chip_ray_gear"
	label = "Ray Gear"
	result_type = /obj/Items/Chip/Frame/Ray_Gear

/datum/craft_recipe/lifecraft/tech/handheld/chip/frame/hilbert_effect
	id = "chip_hilbert_effect"
	label = "Hilbert Effect"
	result_type = /obj/Items/Chip/Frame/Hilbert_Effect

/datum/craft_recipe/lifecraft/tech/handheld/chip/frame/overdrive
	id = "chip_overdrive"
	label = "Overdrive"
	result_type = /obj/Items/Chip/Frame/Overdrive

/datum/craft_recipe/lifecraft/tech/handheld/chip/frame/infinity_drive
	id = "chip_infinity_drive"
	label = "Infinity Drive"
	result_type = /obj/Items/Chip/Frame/Infinity_Drive
