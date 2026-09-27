obj/Items/Gun/Handgun/Beam_Pistol
	name = "Beam Pistol"
	desc = "A sidearm that fires bolts of focused energy. Every shot builds heat and draws on its charge, and at full heat it locks until it cools completely. Energy bolts punch through part of a target's armor and cannot be deflected. Hold Reload with a Battery in your pack to recharge it."
	Class = "Light"
	icon_state = "Photon Pistol"
	EquipIcon = 'Blaster.dmi'
	pixel_x = 0
	pixel_y = 0
	Caliber = null
	MagSize = 1
	energy_gun = 1
	energy_per_shot = GUN_HANDGUN_ENERGY
	heat_per_shot = GUN_HANDGUN_HEAT
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1
	ModelAccuracy = 1.05
	ModelSpeed = 1
	LegendNames = list("Legendary Beam Pistol", "Legendary Beam Pistol", "Legendary Beam Pistol")

obj/Items/Gun/Automatic/Pulse_SMG
	name = "Pulse SMG"
	desc = "A compact automatic that streams short energy pulses. Each pulse costs little charge and little heat, but a held trigger builds heat faster than it bleeds off. Energy pulses punch through part of a target's armor and cannot be deflected. Hold Reload with a Battery in your pack to recharge it."
	Class = "Light"
	icon_state = "Photon Repeaters"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	Caliber = null
	MagSize = 1
	energy_gun = 1
	energy_per_shot = GUN_AUTOMATIC_ENERGY
	heat_per_shot = GUN_AUTOMATIC_HEAT
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1
	ModelAccuracy = 1
	ModelSpeed = 1
	LegendNames = list("Legendary Pulse SMG", "Legendary Pulse SMG", "Legendary Pulse SMG")

obj/Items/Gun/Shotgun/Scatter_Gun
	name = "Scatter Gun"
	desc = "A short energy scattergun that throws a spread of bolts. It is hungry and runs hot, but up close nothing hits harder. Energy bolts punch through part of a target's armor and cannot be deflected. Hold Reload with a Battery in your pack to recharge it."
	Class = "Heavy"
	icon_state = "Plasma Cannon"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	Caliber = null
	MagSize = 1
	energy_gun = 1
	energy_per_shot = GUN_SHOTGUN_ENERGY
	heat_per_shot = GUN_SHOTGUN_HEAT
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 10
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1
	ModelAccuracy = 1
	ModelSpeed = 1
	LegendNames = list("Legendary Scatter Gun", "Legendary Scatter Gun", "Legendary Scatter Gun")

/datum/craft_recipe/lifecraft/tech/handheld/energy_gun
	tier = 5
	knowledge_req = "Energy Weaponry"
	add_slots = list(\
		list("Lens", 2, TECH_MAT_LENS, 1),\
		list("Cell", 1, TECH_MAT_CELL, 1))

	TemplateSlots()
		. = ..()
		. += list(list("Metal", 1, TECH_SEL_INGOT, tier))

	MakeResult(mob/M, q, perf, list/picks)
		var/mid = GunRecipeMetal(src, picks)
		. = ..()
		var/obj/Items/Gun/G = .
		if(!istype(G))
			return
		G.metal_id = mid
		G.setStatLine()
		G.name = GunCraftName(G, mid)

/datum/craft_recipe/lifecraft/tech/handheld/energy_gun/beam_pistol
	id = "tech_gun_beam_pistol"
	label = "Beam Pistol"
	result_type = /obj/Items/Gun/Handgun/Beam_Pistol

/datum/craft_recipe/lifecraft/tech/handheld/energy_gun/pulse_smg
	id = "tech_gun_pulse_smg"
	label = "Pulse SMG"
	result_type = /obj/Items/Gun/Automatic/Pulse_SMG

/datum/craft_recipe/lifecraft/tech/handheld/energy_gun/scatter_gun
	id = "tech_gun_scatter_gun"
	label = "Scatter Gun"
	result_type = /obj/Items/Gun/Shotgun/Scatter_Gun
