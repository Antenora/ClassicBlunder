obj/DimensionalMechHangar
	Savable = 1
	Grabbable = 0
	Destructable = 0
	density = 0
	mouse_opacity = 0
	invisibility = 101
	var/obj/Items/Mech/stored_mech
	var/mech_id
	proc/Prune()
		if(stored_mech && stored_mech.loc != src)
			stored_mech = null

obj/Items/Mech/var/dimensional_hangar_owner_id

mob/var/obj/DimensionalMechHangar/dimensional_mech_hangar

mob/proc/GetDimensionalMechHangar(create = TRUE)
	if(dimensional_mech_hangar && dimensional_mech_hangar.loc == src)
		dimensional_mech_hangar.Prune()
		return dimensional_mech_hangar

	dimensional_mech_hangar = locate(/obj/DimensionalMechHangar) in src

	if(!dimensional_mech_hangar && create)
		dimensional_mech_hangar = new(src)

	if(dimensional_mech_hangar)
		dimensional_mech_hangar.Prune()

	return dimensional_mech_hangar


mob/proc/FindDimensionalMech(obj/DimensionalMechHangar/H)
	if(!H || !H.mech_id) return null
	for(var/obj/Items/Mech/R in world)
		if(!R.DimensionalHangarInReach(src)) continue
		if(R.mounted) continue
		if(R.IntrinsicMechID() == H.mech_id)
			return R
	return null

mob/proc/FindDimensionalMechCandidate()
	var/obj/Items/Mech/found

	for(var/obj/Items/Mech/R in world)
		if(!R.DimensionalHangarInReach(src)) continue
		if(R.mounted) continue
		if(!R.MechIsPilot(src)) continue
		if(R.IntrinsicPilotRefusal(src)) continue
		if(R.dimensional_hangar_owner_id && R.dimensional_hangar_owner_id != IntrinsicOwnerID())
			continue
		if(found)
			src << "Move beside only one eligible mech before binding your dimensional hangar."
			return null

		found = R

	return found


mob/proc/DimensionalMechStore()
	if(mech)
		src << "Dismount before storing your mech."
		return FALSE
	if(InCombat())
		src << "You cannot open the dimensional hangar during combat."
		return FALSE
	var/obj/DimensionalMechHangar/H = GetDimensionalMechHangar()
	if(!H) return FALSE
	H.Prune()
	if(H.stored_mech)
		src << "[H.stored_mech] is already stored in your dimensional hangar."
		return FALSE
	var/obj/Items/Mech/R
	if(H.mech_id)
		R = FindDimensionalMech(H)
	else
		R = FindDimensionalMechCandidate()
	if(!R)
		src << "Your bound mech must be parked beside you."
		return FALSE
	if(!R.MechIsPilot(src))
		src << "You must be a registered pilot to bind this mech."
		return FALSE
	if(R.dimensional_deploying)
		src << "[R] has not finished materializing."
		return FALSE
	var/intrinsic_refusal = R.IntrinsicPilotRefusal(src)
	if(intrinsic_refusal)
		src << intrinsic_refusal
		return FALSE
	var/owner_id = IntrinsicOwnerID()
	if(R.dimensional_hangar_owner_id && R.dimensional_hangar_owner_id != owner_id)
		src << "[R] is already bound to somebody else's dimensional hangar."
		return FALSE
	if(!H.mech_id)
		H.mech_id = R.IntrinsicMechID()
		R.dimensional_hangar_owner_id = owner_id
		src << "[R] synchronizes with your dimensional hangar."
	if(R.IntrinsicMechID() != H.mech_id)
		src << "[R] is not the mech bound to your dimensional hangar."
		return FALSE
	src << "You begin returning [R] to its dimensional hangar."
	if(!MechChannel(MECH_RECALL_DS, null, "dimensional recall"))
		return FALSE
	if(!src || !H || H.loc != src || H.stored_mech)
		return FALSE
	if(!R || !R.DimensionalHangarInReach(src) || R.mounted)
		return FALSE
	if(InCombat())
		return FALSE
	R.MechGuardClear()
	MechDeployedClear(R)
	R.loc = H
	H.stored_mech = R
	OMsg(src, "[R] folds into a flash of light and vanishes into another dimension.")
	if(client)
		client.SaveChar()

	return TRUE

mob/proc/DimensionalMechSummon()
	if(mech)
		src << "You are already piloting a mech."
		return FALSE
	if(InCombat())
		src << "You cannot open the dimensional hangar during combat."
		return FALSE
	var/obj/DimensionalMechHangar/H = GetDimensionalMechHangar(FALSE)
	if(!H)
		src << "You do not have a dimensional hangar."
		return FALSE
	H.Prune()
	var/obj/Items/Mech/R = H.stored_mech
	if(!R)
		src << "Your dimensional hangar is empty."
		return FALSE
	if(R.dimensional_hangar_owner_id != IntrinsicOwnerID())
		src << "The dimensional hangar rejects the mech's authorization."
		return FALSE
	var/obj/Items/Mech/out = MechDeployedFor(ckey)
	if(out && out != R)
		src << "You already have [out] deployed."
		return FALSE
	var/turf/T = get_step(src, dir)
	if(!CapsuleGroundClear(T, src))
		src << "There is no room in front of you."
		return FALSE
	OMsg(src, "[src] snaps their fingers, calling out to [R]!")
	if(!MechChannel(MECH_DEPLOY_DS, null, "dimensional deployment"))
		return FALSE
	if(!src || !H || H.loc != src || H.stored_mech != R || InCombat())
		return FALSE
	T = get_step(src, dir)
	if(!CapsuleGroundClear(T, src))
		src << "There is no longer enough room to deploy [R]."
		return FALSE
	H.stored_mech = null
	R.loc = T
	MechDeployedSet(src, R)
	R.MechPlaced(1)
	R.PlayDimensionalArrival(T)
	OMsg(src, "A pillar of light crashes down as [R] emerges from another dimension!")
	if(client)
		client.SaveChar()
	return TRUE


obj/Skills/Mech/Deus_Ex_Manifest
	name = "Deus Ex Manifest"
	desc = "Snaps your fingers and summon your mech from an extradimensional space, or send it back."
	Copyable = 0
	MechCompatible = 1

	verb/Deus_Ex_Manifest()
		set category = "Skills"
		set hidden = 1
		var/mob/M = usr
		var/obj/DimensionalMechHangar/H = M.GetDimensionalMechHangar()
		if(H && H.stored_mech)
			M.DimensionalMechSummon()
		else
			M.DimensionalMechStore()

obj/Items/Mech/proc/DimensionalHangarInReach(mob/M)
	if(!M || !isturf(loc) || z != M.z)
		return FALSE

	var/list/row = MechRow()
	var/size = row && isnum(row["size"]) ? row["size"] : world.icon_size
	var/reach = max(1, -round(-(size / (world.icon_size * 2))))

	return get_dist(M, src) <= reach

// animation
#define DIMENSIONAL_BEAM_IMPACT_DELAY 12
#define DIMENSIONAL_MECH_FADE_IN 2
#define DIMENSIONAL_MECH_SILHOUETTE_HOLD 3
#define DIMENSIONAL_MECH_COLOR_RESTORE 10
#define DIMENSIONAL_BEAM_DURATION 23

obj/Items/Mech/var/tmp/dimensional_deploying = FALSE
obj/Effects/DimensionalMechArrival
	icon = 'MechSummonTall.dmi'
	icon_state = ""
	Lifetime = -1
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Destructable = 0
	Savable = 0
	gfx_transient_visual = 1
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	layer = EFFECTS_LAYER

	proc/Play(turf/T, Duration = DIMENSIONAL_BEAM_DURATION)
		if(!T)
			del src
			return

		loc = T
		alpha = 255

		var/icon/art = icon(icon, "")
		pixel_x = round((world.icon_size - art.Width()) / 2)
		pixel_y = 0

		flick("", src)
		spawn(max(1, Duration))
			if(src)
				EffectFinish()
				del src

obj/Items/Mech/proc/PlayDimensionalArrival(turf/T)
	set waitfor = 0

	if(!T || loc != T)
		return

	dimensional_deploying = TRUE
	if(!mech_guard)
		MechGuardSync()

	var/mob/Player/AI/Emplacement/MechGuard/G = mech_guard

	if(!G)
		dimensional_deploying = FALSE
		return

	var/final_color = G.color
	var/restore_color = final_color ? final_color : "#FFFFFF"

	animate(G)
	G.alpha = 0
	G.color = "#000000"

	var/obj/Effects/DimensionalMechArrival/F = new
	F.plane = G.plane
	F.layer = G.layer - 0.1
	F.Play(T)
	sleep(DIMENSIONAL_BEAM_IMPACT_DELAY)
	if(!src || !G || mech_guard != G || G.mech_record != src || loc != T)
		if(G)
			animate(G)
			G.alpha = 255
			if(src)
				G.MechGuardLook(src)
		dimensional_deploying = FALSE
		return
	animate(G)
	G.color = "#000000"
	G.alpha = 255
	sleep(DIMENSIONAL_MECH_SILHOUETTE_HOLD)
	if(!src || !G || mech_guard != G || G.mech_record != src || loc != T)
		if(G)
			animate(G)
			G.alpha = 255
			if(src)
				G.MechGuardLook(src)
		dimensional_deploying = FALSE
		return
	animate(
		G,
		color = restore_color,
		time = DIMENSIONAL_MECH_COLOR_RESTORE,
		easing = SINE_EASING
	)

	sleep(DIMENSIONAL_MECH_COLOR_RESTORE)

	if(!src)
		return

	if(G && mech_guard == G && G.mech_record == src)
		animate(G)
		G.alpha = 255
		G.MechGuardLook(src)

	dimensional_deploying = FALSE