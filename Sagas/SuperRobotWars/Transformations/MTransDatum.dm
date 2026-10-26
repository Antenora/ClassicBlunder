datum/mech_transformation
	var/id
	var/name
	var/description
	var/required_will = 100
	var/required_heat_below = 100
	var/activation_heat = 0
	var/icon/transform_icon
	var/transform_icon_state = ""
	var/list/granted_skills = list()
	var/list/granted_passives = list()
	var/transform_color
	var/transform_color_space = FILTER_COLOR_RGB
	var/transform_color_filter = TRUE
	var/transform_glow = FALSE
	var/requires_install = TRUE

	proc/VisualFilterName()
		return "mech_transformation_[id]"
	proc/VisualGlowFilterName()
		return "mech_transformation_glow_[id]"
	proc/ApplyVisuals(mob/User)
		if(!User) return
		var/filter_name = VisualFilterName()
		var/glow_name = VisualGlowFilterName()
		User.filters -= filter_name
		User.filters -= glow_name
		if(transform_color && transform_color_filter)
			User.filters += filter(
				name = filter_name,
				type = "color",
				color = transform_color,
				space = transform_color_space
			)
		if(transform_glow)
			User.filters += filter(
				name = glow_name,
				type = "drop_shadow",
				x = 0,
				y = 0,
				size = 3,
				offset = 1,
				color = "#FFB52EAA"
			)

	proc/RemoveVisuals(mob/User)
		if(!User) return
		User.filters -= VisualFilterName()
		User.filters -= VisualGlowFilterName()

	proc/CanUse(mob/User, obj/Items/Mech/Mech)
		if(!User || !Mech)
			return FALSE
		if(!User.mech)
			User << "You must be piloting a mech."
			return FALSE
		if(!CanAccess(User, Mech))
			User << "[name] is not available to this mech."
			return FALSE
		if(User.Will < required_will)
			User << "[name] requires at least [required_will] Will."
			return FALSE
		if(User.HeatNow() > required_heat_below)
			User << "Your mech is too hot to transform."
			return FALSE
		return TRUE
	proc/Transform(mob/User, obj/Items/Mech/Mech)
		if(!CanUse(User, Mech))
			return FALSE
		User.HeatAdd(activation_heat)
		if(transform_icon)
			User.icon = transform_icon
			User.icon_state = transform_icon_state
		ApplyVisuals(User)
		for(var/passive in granted_passives)
			User.passive_handler.Increase(passive, granted_passives[passive])
		if(!islist(User.mech_transformation_granted_skills))
			User.mech_transformation_granted_skills = list()
		for(var/skill_path in granted_skills)
			if(User.FindSkill(skill_path))
				continue
			User.findOrAddSkill(skill_path)
			var/obj/Skills/S = User.FindSkill(skill_path)
			if(S)
				User.mech_transformation_granted_skills += S
		OnTransform(User, Mech)
		return TRUE

	proc/Revert(mob/User, obj/Items/Mech/Mech)
		if(!User)
			return FALSE
		RemoveVisuals(User)
		for(var/passive in granted_passives)
			User.passive_handler.Decrease(passive, granted_passives[passive])
		if(islist(User.mech_transformation_granted_skills))
			for(var/obj/Skills/S in User.mech_transformation_granted_skills.Copy())
				if(!S || S.loc != User)
					continue
				if(istype(S, /obj/Skills/Buffs))
					var/obj/Skills/Buffs/B = S
					if(User.BuffOn(B))
						B.Trigger(User, Override = 1)
				if(User.AttackQueue == S)
					User.AttackQueue = null
				User.DeleteSkill(S, FALSE)
				del S
		User.mech_transformation_granted_skills = null
		OnRevert(User, Mech)
		return TRUE
	proc/OnTransform(mob/User, obj/Items/Mech/Mech)
		return
	proc/OnRevert(mob/User, obj/Items/Mech/Mech)
		return
	proc/ModifyStat(mob/User, obj/Items/Mech/Mech, stat, amount)
		return amount
	proc/ModifyHeatCapacity(mob/User, obj/Items/Mech/Mech, amount)
		return amount
	proc/ModifyCooling(mob/User, obj/Items/Mech/Mech, amount)
		return amount
	proc/ModifyHeatCost(mob/User, obj/Items/Mech/Mech, amount, obj/source)
		return amount
	proc/OnUseSkill(mob/User, obj/Items/Mech/Mech, obj/Skills/Skill)
		return
	proc/OnTakeDamage(mob/User, obj/Items/Mech/Mech, amount)
		return


datum/mech_transformation/proc/CanAccess(mob/User, obj/Items/Mech/Mech)
	if(!User || !Mech)
		return FALSE
	if(!User.HasMechTransformation(id))
		return FALSE
	if(!requires_install)
		return TRUE
	if(!islist(User.MechTransformationAssignments))
		return FALSE
	if(!islist(Mech.mech_transformations_installed))
		return FALSE
	var/assigned_mech_id = User.MechTransformationAssignments[id]
	if(assigned_mech_id != Mech.IntrinsicMechID())
		return FALSE
	var/list/installation = Mech.mech_transformations_installed[id]
	if(!islist(installation))
		return FALSE
	if(installation["owner_id"] != User.IntrinsicOwnerID())
		return FALSE
	if(installation["mech_id"] != Mech.IntrinsicMechID())
		return FALSE
	return TRUE

mob/proc/InstallMechTransformation(obj/Items/Mech/Mech, transformation_id)
	if(!Mech || !transformation_id)
		return FALSE
	RegisterMechTransformations()
	var/datum/mech_transformation/T = MechTransformationDefs[transformation_id]
	if(!T)
		src << "That mech transformation does not exist."
		return FALSE
	if(!HasMechTransformation(transformation_id))
		src << "You have not unlocked [T.name]."
		return FALSE
	if(!T.requires_install)
		src << "[T.name] can already be used on any mech."
		return FALSE
	if(!islist(MechTransformationAssignments))
		MechTransformationAssignments = list()
	if(!islist(Mech.mech_transformations_installed))
		Mech.mech_transformations_installed = list()
	if(Mech.mech_transformation_id && Mech.mech_transformation_id != transformation_id)
		src << "[Mech] already has another transformation installed."
		return FALSE
	var/old_mech_id = MechTransformationAssignments[transformation_id]
	if(old_mech_id && old_mech_id != Mech.IntrinsicMechID())
		src << "[T.name] is already installed on another mech."
		return FALSE
	var/list/installation = list(
		"owner_id" = IntrinsicOwnerID(),
		"mech_id" = Mech.IntrinsicMechID()
	)
	MechTransformationAssignments[transformation_id] = Mech.IntrinsicMechID()
	Mech.mech_transformations_installed[transformation_id] = installation
	Mech.mech_transformation_id = transformation_id
	Mech.MechEnsureSkills()
	src << "[T.name] has been installed on [Mech]."
	return TRUE

mob/proc/UninstallMechTransformation(obj/Items/Mech/Mech, transformation_id)
	if(!Mech || !transformation_id)
		return FALSE
	if(active_mech_transformation_id == transformation_id)
		if(mech != Mech)
			src << "That transformation is currently active elsewhere."
			return FALSE
		RevertMechTransformation(Mech)
	if(!islist(Mech.mech_transformations_installed))
		return FALSE
	var/list/installation = Mech.mech_transformations_installed[transformation_id]
	if(!islist(installation))
		return FALSE
	if(installation["owner_id"] != IntrinsicOwnerID())
		return FALSE
	Mech.mech_transformations_installed -= transformation_id
	if(Mech.mech_transformation_id == transformation_id)
		Mech.mech_transformation_id = null
	if(islist(MechTransformationAssignments))
		if(MechTransformationAssignments[transformation_id] == Mech.IntrinsicMechID())
			MechTransformationAssignments -= transformation_id
	src << "The transformation has been removed from [Mech]."
	return TRUE

mob/proc/AvailableMechTransformations(obj/Items/Mech/Mech)
	var/list/out = list()
	if(!Mech || !islist(MechTransformationsUnlocked))
		return out
	RegisterMechTransformations()
	for(var/transformation_id in MechTransformationsUnlocked)
		var/datum/mech_transformation/T = MechTransformationDefs[transformation_id]
		if(T && T.CanAccess(src, Mech))
			out[transformation_id] = T

	return out
