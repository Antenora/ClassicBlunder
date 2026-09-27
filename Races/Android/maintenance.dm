#define ANDROID_KIT_STRAIN 0.05
#define ANDROID_POD_TICK 10
#define ANDROID_POD_REPAIR_TICKS 30
#define ANDROID_POD_STRAIN 0.01
#define ANDROID_POD_DRAIN DEV_PER_HOUR(12)

/obj/Items/Tech/Frame_Repair_Kit
	name = "Frame Repair Kit"
	desc = "Field repair for synthetic bodies. On an Android it eases frame strain and mends one damaged part; on anyone else it mends one damaged prosthetic part. Use it out of combat, on yourself or on a willing target next to you."
	icon = 'Tech.dmi'
	icon_state = "AdvancedKit"
	TechType = "Cyber Engineering"
	SubType = "Cyber Engineering"
	Stackable = 1
	BeltAlly = 1

	Click()
		if(loc != usr)
			return ..()
		usr.FrameRepairUse(src)

mob/proc/FrameProsthetic(part)
	return (prosthetic_parts && prosthetic_parts[part]) ? 1 : 0

mob/proc/FrameRepairParts(mob/T)
	. = list()
	if(!T)
		return
	var/android = T.race && T.isRace(ANDROID)
	for(var/p in MAIM_PARTS)
		var/tier = T.MaimTierOf(p)
		if(tier <= 0)
			continue
		if(!android && !T.FrameProsthetic(p))
			continue
		.["[p], tier [tier]"] = p

mob/proc/FrameRepairConsent(mob/user)
	return Ask(src, "[user] wants to use a Frame Repair Kit on you. Allow it?", "Frame Repair Kit", null, "confirm", null, 1, "No", "Yes") == "Yes"

mob/proc/FrameRepairAskPart(list/parts)
	return Ask(src, "Which part do you repair?", "Frame Repair Kit", null, "pick", parts, 1)

mob/proc/FrameRepairStill(obj/Items/Tech/Frame_Repair_Kit/K, mob/T)
	if(!K || K.loc != src || !T || T.Dead)
		return 0
	if(T != src && (T.z != z || get_dist(src, T) > 1))
		src << "[T] is too far away."
		return 0
	if(InCombat())
		src << "You cannot repair a frame in the middle of a fight."
		return 0
	return 1

mob/proc/FrameRepairUse(obj/Items/Tech/Frame_Repair_Kit/K)
	if(!K || K.loc != src)
		return 0
	if(Secret == "Heavenly Restriction" && secretDatum?:hasRestriction("Science"))
		return 0
	if(KO)
		src << "You cannot work on a frame while knocked out."
		return 0
	if(InCombat())
		src << "You cannot repair a frame in the middle of a fight."
		return 0
	if(K.Using)
		src << "You're already using this."
		return 0
	K.Using = 1
	. = FrameRepairRun(K)
	if(K)
		K.Using = 0

mob/proc/FrameRepairRun(obj/Items/Tech/Frame_Repair_Kit/K)
	var/mob/T = BeltReceiverFor(K)
	if(!T)
		T = src
	var/android = T.race && T.isRace(ANDROID)
	var/list/parts = FrameRepairParts(T)
	if(!parts.len && !(android && T.HealthCut > 0))
		if(android)
			src << "[T == src ? "Your frame has" : "[T]'s frame has"] no strain or damage to repair."
		else
			src << "A Frame Repair Kit only works on an Android frame or a damaged prosthetic part."
		return 0
	if(T != src && !T.KO)
		if(!T.FrameRepairConsent(src))
			src << "[T] declines the repair."
			return 0
		if(!FrameRepairStill(K, T))
			return 0
	var/part
	if(parts.len)
		var/pick = FrameRepairAskPart(parts)
		if(!pick || !parts[pick])
			return 0
		part = parts[pick]
		if(!FrameRepairStill(K, T))
			return 0
	var/eased = 0
	if(android && T.HealthCut > 0)
		eased = min(T.HealthCut, ANDROID_KIT_STRAIN * ChipQualityFactor(K.CraftQuality))
		T.HealthCut -= eased
		if(T.HealthCut < 0.0001)
			T.HealthCut = 0
	var/peeled = part ? T.MaimPeel(part) : 0
	BeltConsume(K)
	if(client)
		client.BuildInvPage()
	OMsg(src, "[src] works a Frame Repair Kit over [T == src ? "their own frame" : "[T]"].")
	var/list/done = list()
	if(eased > 0)
		done += "frame strain eased by [round(eased * 100, 0.1)] percent"
	if(peeled)
		done += "[lowertext(part)] mended by one tier"
	if(done.len)
		T << "Frame Repair Kit: [jointext(done, ", ")]."
	return 1

/obj/AndroidPodPiece
	name = "Maintenance Pod"
	density = 0
	Savable = 0
	Grabbable = 0
	Pickable = 0
	Attackable = 0
	Destructable = 0
	gfx_transient_visual = 1
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE

/obj/Items/Tech/Maintenance_Pod
	name = "Maintenance Pod"
	desc = "An Android's rest station. Bolt it down, load Power Packs and step in: every 30 seconds it eases frame strain, injury and fatigue. It burns one Power Pack every 5 minutes while someone is inside, and an empty pod does nothing."
	icon = 'Icons/Technology/techz.dmi'
	icon_state = "AndroidPod03"
	TechType = "Cyber Engineering"
	SubType = "Neuron Manipulation"
	Pickable = 1
	Grabbable = 1
	UpdatesDescription = 1
	density = 0
	dev_hopper = 1
	dev_drain = ANDROID_POD_DRAIN
	var
		list/pod_stack = list("AndroidPod04", "AndroidPod05")
		pod_stack_step = 32
		pod_stack_layer = 5
		pod_offset_y = 0
		pod_seat_x = 0
		pod_seat_y = 0
		tmp/list/pod_pieces
		tmp/mob/pod_occupant
		tmp/pod_ticks = 0
		tmp/pod_running = 0
		tmp/pod_warned = 0

	New()
		..()
		PodDress()
		spawn(1)
			if(src && isturf(loc) && !Grabbable) DeviceRegister()

	Read(savefile/F)
		. = ..()
		PodDress()

	proc/PodDress()
		for(var/obj/AndroidPodPiece/old in pod_pieces)
			vis_contents -= old
			old.loc = null
		pod_pieces = list()
		pixel_y = pod_offset_y
		for(var/i = 1 to pod_stack.len)
			var/obj/AndroidPodPiece/P = new
			P.icon = icon
			P.icon_state = pod_stack[i]
			P.pixel_y = pod_stack_step * i
			P.layer = pod_stack_layer
			pod_pieces += P
			vis_contents += P

	Del()
		if(pod_occupant)
			PodRelease(pod_occupant, 0)
		..()

	proc/Update_Description()
		desc = DeviceDescText()

	Click()
		if(loc == usr)
			usr << "Drop [src] where you want it, then click it to bolt it down."
			return
		DeviceMenu(usr)

	DeviceDrawing()
		return ..() && pod_occupant && PodHolds(pod_occupant)

	DeviceActions(mob/M)
		. = ..()
		if(!DevicePlaced())
			return
		if(pod_occupant == M)
			. += "Leave the pod"
		else if(!pod_occupant && M.race && M.isRace(ANDROID))
			. += "Enter the pod"

	DeviceAct(mob/M, act)
		switch(act)
			if("Enter the pod")
				PodEnter(M)
			if("Leave the pod")
				PodRelease(M)
			else
				..()

	DeviceStatus(mob/M)
		. = ..()
		if(pod_occupant)
			. += "Inside: [pod_occupant], frame strain [round(pod_occupant.HealthCut * 100, 0.1)] percent."
		else
			. += "Empty. Only an Android frame fits."

	proc/PodHolds(mob/M)
		if(!M || M.KO || M.Dead)
			return 0
		if(!DevicePlaced() || M.loc != loc)
			return 0
		return 1

	proc/PodEnter(mob/M)
		if(!M || M.KO || M.Dead)
			return
		if(!(M.race && M.isRace(ANDROID)))
			M << "[src] only takes an Android frame."
			return
		if(!DevicePlaced())
			M << "[src] has to be bolted down first."
			return
		if(pod_occupant && pod_occupant != M)
			if(PodHolds(pod_occupant))
				M << "[src] is already occupied."
				return
			PodRelease(pod_occupant, 0)
		pod_occupant = M
		M.loc = loc
		M.step_x = pod_seat_x
		M.step_y = pod_seat_y
		pod_ticks = 0
		pod_warned = 0
		OMsg(M, "[M] settles into [src].")
		if(!DevicePowered())
			M << "[src] has no power. Load Power Packs to run it."
		PodLoop()

	proc/PodRelease(mob/M, say = 1)
		if(!M || pod_occupant != M)
			return
		pod_occupant = null
		pod_ticks = 0
		if(say)
			OMsg(M, "[M] leaves [src].")

	proc/PodLoop()
		set waitfor = 0
		if(pod_running)
			return
		pod_running = 1
		while(pod_occupant)
			sleep(ANDROID_POD_TICK)
			var/mob/M = pod_occupant
			if(!M)
				break
			if(!PodHolds(M))
				PodRelease(M)
				break
			pod_ticks++
			if(pod_ticks < ANDROID_POD_REPAIR_TICKS)
				continue
			pod_ticks = 0
			if(!DevicePowered())
				if(!pod_warned)
					pod_warned = 1
					M << "[src] is out of power and does nothing."
				continue
			pod_warned = 0
			PodRepair(M)
		pod_running = 0

	proc/PodRepair(mob/M)
		if(M.HealthCut > 0)
			M.HealthCut -= ANDROID_POD_STRAIN
			if(M.HealthCut < 0.0001)
				M.HealthCut = 0
		if(M.TotalInjury)
			M.Recover("Injury", M.TotalInjury)
		if(M.TotalFatigue)
			M.Recover("Fatigue", M.TotalFatigue)

/datum/craft_recipe/lifecraft/tech/handheld/frame_repair_kit
	id = "tech_frame_repair_kit"
	label = "Frame Repair Kit"
	tier = 1
	knowledge_req = "Cyber Engineering"
	result_type = /obj/Items/Tech/Frame_Repair_Kit
	add_slots = list(list("Gel", 1, TECH_MAT_BIOGEL, 1))

/datum/craft_recipe/lifecraft/tech/placed/maintenance_pod
	id = "tech_maintenance_pod"
	label = "Maintenance Pod"
	tier = 3
	knowledge_req = "Neuron Manipulation"
	result_type = /obj/Items/Tech/Maintenance_Pod
	add_slots = list(list("Servo", 1, TECH_MAT_SERVO, 1))
