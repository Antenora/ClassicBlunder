var/global/list/MechTransformationDefs = list()
var/global/MechTransformationsRegistered = FALSE

proc/RegisterMechTransformations()
	if(MechTransformationsRegistered)
		return
	for(var/path in typesof(/datum/mech_transformation))
		if(path == /datum/mech_transformation)
			continue
		var/datum/mech_transformation/T = new path
		if(!T.id)
			world.log << "Mech transformation without an ID: [path]"
			del T
			continue
		if(MechTransformationDefs[T.id])
			world.log << "Duplicate mech transformation ID: [T.id]"
			del T
			continue
		if(!T.name)
			T.name = T.id
		MechTransformationDefs[T.id] = T
	MechTransformationsRegistered = TRUE


proc/MechTransformationDef(id)
	RegisterMechTransformations()
	return MechTransformationDefs[id]


mob/var/list/MechTransformationsUnlocked = list()
obj/Items/Mech
	var/mech_transformation_id
mob/var/tmp/active_mech_transformation_id
mob/var/tmp/mech_transforming = FALSE
mob/var/tmp/list/mech_transformation_granted_skills
mob/var/list/MechTransformationAssignments = list()
obj/Items/Mech/var/list/mech_transformations_installed = list()
///////////////

mob/proc/HasMechTransformation(id)
	if(!id || !islist(MechTransformationsUnlocked))
		return FALSE

	return MechTransformationsUnlocked[id] ? TRUE : FALSE


mob/proc/GetAssignedMechTransformation(obj/Items/Mech/Mech)
	if(!Mech)
		return null
	RegisterMechTransformations()

	// Installed transformations take priority.
	if(Mech.mech_transformation_id)
		var/datum/mech_transformation/installed = MechTransformationDef(Mech.mech_transformation_id)
		if(installed && installed.CanAccess(src, Mech))
			return installed

	// A transformation with requires_install = FALSE works in any mech.
	if(islist(MechTransformationsUnlocked))
		for(var/transformation_id in MechTransformationsUnlocked)
			var/datum/mech_transformation/T = MechTransformationDefs[transformation_id]
			if(T && !T.requires_install && T.CanAccess(src, Mech))
				return T

	return null


mob/proc/ActivateMechTransformation(obj/Items/Mech/Mech)
	if(mech_transforming || active_mech_transformation_id)
		return FALSE
	var/datum/mech_transformation/T = GetAssignedMechTransformation(Mech)
	if(!T)
		src << "This mech has no available transformation."
		return FALSE
	if(!T.CanUse(src, Mech))
		return FALSE
	mech_transforming = TRUE
	var/success = T.Transform(src, Mech)
	if(success)
		active_mech_transformation_id = T.id
	mech_transforming = FALSE
	return success


mob/proc/RevertMechTransformation(obj/Items/Mech/Mech)
	if(mech_transforming || !active_mech_transformation_id)
		return FALSE
	var/datum/mech_transformation/T = MechTransformationDef(active_mech_transformation_id)
	mech_transforming = TRUE
	if(T)
		T.Revert(src, Mech)
	active_mech_transformation_id = null
	mech_transforming = FALSE
	return TRUE

mob/proc/ActiveMechTransformation()
	if(!active_mech_transformation_id)
		return null

	return MechTransformationDef(active_mech_transformation_id)



