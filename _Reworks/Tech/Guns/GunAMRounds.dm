obj/Items/Ammo/Pistol/AntiMateriel
	name = "Anti-Materiel Pistol Rounds"
	desc = "Dense penetrator rounds made to crack machines. They hit turrets, drones, force fields and piloted mechs far harder, and people noticeably softer."
	RiderAntiMateriel = 1

obj/Items/Ammo/Rifle/AntiMateriel
	name = "Anti-Materiel Rifle Rounds"
	desc = "Dense penetrator rounds made to crack machines. They hit turrets, drones, force fields and piloted mechs far harder, and people noticeably softer."
	RiderAntiMateriel = 1

/datum/craft_recipe/lifecraft/tech/field/ammo/antimateriel_pistol
	id = "tech_ammo_am_pistol"
	label = "Anti-Materiel Pistol Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Pistol/AntiMateriel
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Copper", 1, "mat:Copper", 1),\
		list("Steel", 2, "mat:Steel", 1))

/datum/craft_recipe/lifecraft/tech/field/ammo/antimateriel_rifle
	id = "tech_ammo_am_rifle"
	label = "Anti-Materiel Rifle Rounds"
	tier = 3
	knowledge_req = "Munitions"
	result_type = /obj/Items/Ammo/Rifle/AntiMateriel
	result_count = GUN_ROUNDS_PER_RUN
	slotspec = list(\
		list("Propellant", 1, TECH_MAT_PROPELLANT, 1),\
		list("Steel", 3, "mat:Steel", 1))

/proc/GunAMIsDevice(atom/victim)
	if(ismob(victim))
		var/mob/M = victim
		if(M.HeatMechRecord())
			return 1
		return istype(M, /mob/Player/AI/Emplacement) ? 1 : 0
	if(isobj(victim))
		var/obj/O = victim
		return O.Attackable ? 1 : 0
	return 0

mob/GunAMMult(atom/victim, obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(!P)
		return
	var/obj/Items/Ammo/A = P.gun_ammo
	if(!ispath(A, /obj/Items/Ammo) || !initial(A.RiderAntiMateriel))
		return
	. *= GunAMIsDevice(victim) ? GUN_AM_DEVICE_MULT : GUN_AM_BODY_MULT
