var/list/MECHS_OUT = list()

proc/MechDeployedFor(ck)
	if(!ck) return null
	var/obj/Items/Mech/R = MECHS_OUT[ck]
	if(!R)
		MECHS_OUT -= ck
		return null
	if(R.deployed_by != ck || !(isturf(R.loc) || R.mounted))
		MECHS_OUT -= ck
		return null
	return R

proc/MechDeployedSet(mob/M, obj/Items/Mech/R)
	if(!M || !R || !M.ckey) return 0
	for(var/k in MECHS_OUT.Copy())
		if(MECHS_OUT[k] == R && k != M.ckey) MECHS_OUT -= k
	MECHS_OUT[M.ckey] = R
	R.deployed_by = M.ckey
	return 1

proc/MechDeployedClear(obj/Items/Mech/R)
	if(!R) return
	for(var/k in MECHS_OUT.Copy())
		if(MECHS_OUT[k] == R) MECHS_OUT -= k
	R.deployed_by = null

proc/MechPartVar(obj/Items/I, v)
	if(!I || !(v in I.vars)) return null
	return I.vars[v]

proc/MechIsPart(obj/Items/I)
	if(!I || !I.mech_slot) return 0
	var/t = MechPartVar(I, "part_tier")
	return (isnum(t) && t > 0) ? 1 : 0

proc/MechSlotFamily(slot)
	switch(slot)
		if("RArm", "LArm") return "Arm"
		if("RBack", "LBack") return "Back"
	return "Internal"

mob/var/tmp/mech_kit_kind
mob/var/tmp/mech_channeling = 0

mob/proc/MechHere()
	if(isturf(loc))
		for(var/obj/Items/Mech/R in loc)
			return R
	return locate(/obj/Items/Mech) in src

mob/proc/MechLicensed()
	if(!knowledgeTracker || !knowledgeTracker.learnedKnowledge) return 0
	return ("Piloting Foundations" in knowledgeTracker.learnedKnowledge) ? 1 : 0

mob/proc/MechChannel(ds, atom/near, what)
	if(mech_channeling)
		src << "You're already in the middle of something."
		return 0
	mech_channeling = 1
	var/hs = Health
	var/atom/start = loc
	var/end = world.time + ds
	. = 1
	while(world.time < end)
		sleep(MECH_CHANNEL_STEP)
		if(KO || Dead)
			. = 0
			break
		if(loc != start)
			src << "You moved. The [what] stops."
			. = 0
			break
		if(near && (!near.loc || get_dist(src, near) > 1))
			src << "You are out of reach. The [what] stops."
			. = 0
			break
		if(Health < hs || InCombat())
			src << "The fight breaks off the [what]."
			. = 0
			break
	mech_channeling = 0

mob/proc/CapsuleEmpty()
	for(var/obj/Items/Capsule/C in src)
		C.CapsulePrune()
		if(!C.stored) return C
	return null

client/DeviceDropTarget(atom/over, obj/Items/I)
	. = ..()
	if(. || !mob || !I) return
	var/obj/Items/Mech/R
	if(istype(over, /obj/Items/Mech))
		R = over
	else if(istype(over, /mob/Player/AI/Emplacement/MechGuard))
		var/mob/Player/AI/Emplacement/MechGuard/G = over
		R = G.mech_record
	if(!R || !isturf(R.loc)) return 0
	return R.MechAcceptItem(mob, I)

/obj/Items/Mech
	name = "Mech"
	desc = "A piloted war machine. Its registered pilots can board it, and its builder decides who is registered."
	icon = MECH_ICON_MECHA
	icon_state = "Stand"
	density = 1
	Savable = 1
	Grabbable = 0
	Attackable = 0
	Destructable = 0
	Stealable = 0
	UpdatesDescription = 1
	var
		model = "MechA"
		core_tier = MECH_CORE_TIER_MIN
		frame_kit
		coating
		Hull = 0
		fuel = MECH_FUEL_START
		list/parts
		list/part_kept
		list/socket_chips
		list/pilots
		builder
		mounted = 0
		disabled = 0
		paint
		shortcut/shortcuts
		parked_since = 0
		deployed_by
		tmp/mob/Player/AI/Emplacement/MechGuard/mech_guard

	New()
		..()
		spawn(0)
			if(src) MechSettle()

	Del()
		MechGuardClear()
		MechDeployedClear(src)
		..()

	Click()
		if(loc == usr) return
		MechMenu(usr)

	proc/Update_Description()
		desc = "[initial(desc)]<br><br>[jointext(MechStatusLines(null), "<br>")]"

	proc/MechSettle()
		if(Hull <= 0 && !disabled) Hull = MechHullMax()
		MechLook()
		if(!isturf(loc) || mounted) return
		if(deployed_by && !MechDeployedFor(deployed_by)) MECHS_OUT[deployed_by] = src
		MechPlaced(0)

	proc/MechRow()
		return MECH_MODELS[model]

	proc/MechLevel()
		var/lv = MechCoreTier() - 1 + (CraftQuality == QUAL_LEGENDARY ? 1 : 0)
		return clamp(lv, MECH_LEVEL_MIN, MECH_LEVEL_MAX)

	proc/MechHullTrait(h)
		return 1 + (h - 1) * LIFE_GEARQ_SCALE[QualityClamp(CraftQuality)]

	proc/MechStats()
		var/list/row = MechRow()
		var/list/base = row ? row["stats"] : null
		var/list/kit = MechKitRow(frame_kit)
		var/lv = MechLevel() - 1
		var/list/S = list()
		for(var/i = 1 to MECH_STAT_KEYS.len)
			var/k = MECH_STAT_KEYS[i]
			var/v = (base && i <= base.len) ? base[i] : 0
			v += lv
			if(kit && kit[k]) v += kit[k]
			S[k] = v
		var/list/t = MechMetalTraits(metal_id)
		S["Vit"] *= MechHullTrait(t[1])
		S["End"] *= t[2]
		S["Def"] *= t[2]
		S["Spd"] *= t[3]
		MechStatMods(S)
		IntrinsicEvent("stats", null, S)
		return S

	proc/MechStatMods(list/S)
		return

	proc/MechHullMax()
		var/list/S = MechStats()
		return glob.HP_PER_VIT * (max(0.1, S["Vit"]) + glob.HP_STAT_BASE)

	proc/MechHasPassive(pname)
		var/list/row = MechRow()
		var/list/P = row ? row["passive"] : null
		if(!P) return 0
		for(var/i = 1 to P.len step 2)
			if(P[i] == pname) return 1
		return 0

	proc/MechSockets()
		var/list/row = MechRow()
		return row ? row["sockets"] : 0

	proc/MechOpenSlots()
		. = list()
		var/list/row = MechRow()
		if(!row) return
		. += row["slots"]
		for(var/i = 1 to row["internals"])
			. += "Int[i]"

	proc/MechPartIn(slot)
		var/obj/Items/P = MechRawPartIn(slot)
		return (P && IntrinsicPartActive(P)) ? P : null

	proc/MechPartsOfKind(kind)
		. = list()
		for(var/s in parts)
			var/obj/Items/P = MechPartIn(s)
			if(!P || (P in .)) continue
			if(ispath(kind))
				if(istype(P, kind)) . += P
			else if(P.mech_slot == kind)
				. += P

	proc/MechPartSlotsFor(obj/Items/I, slot)
		var/fam = MechSlotFamily(slot)
		if(fam == "Arm" && MechPartVar(I, "hands") == 2) return list("RArm", "LArm")
		if(fam == "Back" && MechPartVar(I, "paired")) return list("RBack", "LBack")
		return list(slot)

	proc/MechPartFits(obj/Items/I, slot)
		if(!MechIsPart(I)) return "[I] is not a mech part"
		var/list/open = MechOpenSlots()
		if(!(slot in open)) return "[src] has no [MECH_SLOT_NAMES[slot]]"
		if(I.mech_slot != MechSlotFamily(slot)) return "[I] does not fit the [MECH_SLOT_NAMES[slot]]"
		for(var/s in MechPartSlotsFor(I, slot))
			if(!(s in open))
				return "[I] needs the [MECH_SLOT_NAMES[s]] too, and [src] has none"
		return null

	proc/MechFit(obj/Items/I, slot, mob/M)
		if(MechPartFits(I, slot)) return 0
		var/list/need = MechPartSlotsFor(I, slot)
		var/special = I.IsIntrinsicPart()
		for(var/s in need)
			var/obj/Items/old = MechRawPartIn(s)
			if(old && old.IsIntrinsicPart()) special = TRUE
		if(special) return IntrinsicFit(I, slot, M)
		for(var/s in need)
			var/obj/Items/old = MechPartIn(s)
			if(old) MechUnfit(old, M)
		if(!parts) parts = list()
		I.suffix = null
		I.loc = src
		for(var/s in need)
			parts[s] = I
		return 1

	proc/MechUnfit(obj/Items/P, mob/M)
		if(!P) return 0
		if(P.IsIntrinsicPart()) return IntrinsicUnfit(P, M)
		if(parts)
			for(var/s in parts.Copy())
				if(parts[s] == P) parts -= s
			if(!parts.len) parts = null
		if(P.loc == src)
			if(M) M.GiveOrDrop(P)
			else P.loc = loc
		return 1

	proc/MechChipFits(obj/Items/Chip/C)
		if(!istype(C)) return 0
		if(C.ChipFamily != "System" && C.ChipFamily != "Routine") return 0
		if(socket_chips && (C.type in socket_chips)) return 0
		return 1

	proc/MechIsPilot(mob/M)
		if(!M || !M.ckey || !pilots) return 0
		return (M.ckey in pilots) ? 1 : 0

	proc/MechIsBuilder(mob/M)
		return (M && builder && M.ckey == builder) ? 1 : 0

	proc/MechPilotOthers()
		. = list()
		for(var/k in pilots)
			if(k != builder) . += k

	proc/MechPilotAdd(mob/M)
		if(!MechIsBuilder(M)) return
		var/k = PromptKnownKey(M, "Register a pilot")
		if(!k || !src) return
		k = ckey(k)
		if(!length(k)) return
		if(!pilots) pilots = list()
		if(k in pilots)
			M << "[k] is already a registered pilot of [src]."
			return
		pilots += k
		M << "[k] is now a registered pilot of [src]."

	proc/MechPilotRemove(mob/M)
		if(!MechIsBuilder(M)) return
		var/list/L = MechPilotOthers()
		if(!L.len)
			M << "Nobody but you is registered on [src]."
			return
		var/k = Ask(M, "Take which pilot off [src]?", "[src]", null, "pick", L, 1)
		if(!k || !src || !pilots) return
		pilots -= k
		M << "[k] is no longer a pilot of [src]."

	proc/MechPlatingClass()
		return metal_id ? LIFE_METAL_NAME[metal_id] : null

	proc/MechStatusLines(mob/M)
		. = list()
		var/list/row = MechRow()
		. += "[row ? row["name"] : model], [row ? row["class"] : "unknown"] frame, Level [MechLevel()], [QualityName(CraftQuality)] quality."
		if(disabled) . += "Disabled. It is a wreck until a Mech Bay repairs it."
		. += "Hull: [round(Hull)] of [round(MechHullMax())]."
		. += "Fuel: [round(fuel, 0.1)] of [MECH_FUEL_CAP] minutes."
		var/mc = MechPlatingClass()
		. += "Plating: [mc ? mc : "unknown"]. Frame kit: [frame_kit ? frame_kit : "none"]. Coating: [MechCoatingName(coating)]. Reactor: tier [MechCoreTier()] core."
		var/list/S = MechStats()
		var/list/sl = list()
		for(var/k in MECH_STAT_KEYS)
			sl += "[uppertext(k)] [round(S[k], 0.1)]"
		. += jointext(sl, ", ")
		for(var/s in MechOpenSlots())
			var/obj/Items/P = MechPartIn(s)
			. += "[MECH_SLOT_NAMES[s]]: [P ? P.name : "empty"]."
		var/list/chips = list()
		for(var/c in socket_chips)
			chips += "[QualityName(socket_chips[c])] [TechItemName(c)]"
		. += "Chip sockets ([length(socket_chips)] of [MechSockets()]): [chips.len ? jointext(chips, ", ") : "empty"]."
		if(M && MechIsPilot(M)) . += "Pilots: [jointext(pilots, ", ")]."

	proc/MechShowStatus(mob/M)
		//if(!M) return
		//for(var/line in MechStatusLines(M))
		//	M << line
		ShowMechInfo(M)

	proc/MechActions(mob/M)
		. = list()
		if(!isturf(loc)) return
		var/pilot = MechIsPilot(M)
		if(pilot && M.MechLicensed()) . += "Board"
		. += "Status"
		if(fuel < MECH_FUEL_CAP) . += "Refuel"
		if(pilot) . += "Capsule"
		if(MechIsBuilder(M))
			. += "Add a pilot"
			var/list/others = MechPilotOthers()
			if(others.len) . += "Remove a pilot"

	proc/MechAct(mob/M, act)
		switch(act)
			if("Board")
				if(MechIsPilot(M) && M.MechLicensed()) MechBoard(M)
			if("Status")
				MechShowStatus(M)
			if("Refuel")
				MechRefuel(M)
			if("Capsule")
				MechCapsuleUp(M)
			if("Add a pilot")
				MechPilotAdd(M)
			if("Remove a pilot")
				MechPilotRemove(M)

	proc/MechMenu(mob/M)
		if(!M || !M.client || !isturf(loc)) return
		if(get_dist(M, src) > 1)
			M << "Get next to [src] first."
			return
		if(M.Secret == "Heavenly Restriction" && M.secretDatum?:hasRestriction("Science"))
			M << "[src] will not answer your touch."
			return
		var/list/acts = MechActions(M)
		if(!acts.len) return
		var/act = Ask(M, "Hull [round(Hull)] of [round(MechHullMax())], fuel [round(fuel, 0.1)] minutes.[disabled ? " Disabled." : ""]", "[src]", null, "pick", acts, 1)
		if(!act || !src || !isturf(loc) || get_dist(M, src) > 1) return
		MechAct(M, act)

	proc/MechBoard(mob/M)
		if(M) M << "[src]'s cockpit stays sealed for now."

	proc/MechAcceptItem(mob/M, obj/Items/I)
		return 0

	proc/MechRefuel(mob/M)
		if(!M || get_dist(M, src) > 1) return
		if(fuel >= MECH_FUEL_CAP)
			M << "[src]'s tank is full."
			return
		if(CountMaterial(M, "FuelCell") < 1)
			M << "You need a Fuel Cell in your Collection Log to refuel [src]."
			return
		ConsumeMaterial(M, "FuelCell", 1)
		fuel = min(MECH_FUEL_CAP, fuel + MECH_FUEL_PER_CELL)
		M << "You feed a Fuel Cell into [src]. Fuel: [round(fuel, 0.1)] of [MECH_FUEL_CAP] minutes."

	proc/MechCapsuleUp(mob/M)
		if(!M || !isturf(loc)) return
		if(!MechIsPilot(M))
			M << "Only a registered pilot can capsule [src]."
			return
		if(M.InCombat())
			M << "You can't pack a mech away in a fight."
			return
		var/obj/Items/Capsule/C = M.CapsuleEmpty()
		if(!C)
			M << "You need an empty Capsule to pack [src] away."
			return
		M << "You start packing [src] into [C]."
		if(!M.MechChannel(MECH_RECALL_DS, src, "packing")) return
		if(!src || !isturf(loc) || mounted || !C || C.loc != M || C.stored || !MechIsPilot(M) || M.InCombat()) return
		C.CapsuleTake(M, src, disabled ? "wreck" : "mech")
		OMsg(M, "[M] packs [src] into a capsule.")

	proc/MechHullZero()
		if(mounted) return
		disabled = 1
		MechLook()

	proc/MechLook()
		var/list/row = MechRow()
		if(row)
			name = row["name"]
			icon = row["icon"]
			icon_state = row["state"]
			pixel_x = row["offset_x"]
			pixel_y = row["offset_y"]
		color = disabled ? (row ? row["wreck_color"] : MECH_WRECK_TINT) : null
		if(mech_guard) mech_guard.MechGuardLook(src)

	proc/MechPlaced(stamp = 1)
		if(!isturf(loc) || mounted) return
		if(stamp) parked_since = world.realtime
		MechLook()
		MechGuardSync()

	proc/MechRefitDone(before)
		if(disabled)
			Hull = 0
		else if(before > 0)
			Hull = clamp(Hull / before * MechHullMax(), 1, MechHullMax())
		MechLook()
		MechGuardSync()

	proc/MechGuardSync()
		if(isturf(loc) && !mounted)
			if(!mech_guard || !mech_guard.loc || mech_guard.mech_home != loc || mech_guard.mech_record != src)
				MechGuardSpawn()
			else
				MechGuardPower()
				MechGuardPush()
		else
			MechGuardClear()

	proc/MechGuardSpawn()
		MechGuardClear()
		if(!isturf(loc)) return
		var/mob/Player/AI/Emplacement/MechGuard/G = new(loc)
		G.mech_record = src
		G.mech_home = loc
		mech_guard = G
		G.MechGuardLook(src)
		MechGuardPower()
		MechGuardPush()
		invisibility = 101
		mouse_opacity = 0
		G.MechGuardWatch()

	proc/MechGuardClear()
		var/mob/Player/AI/Emplacement/MechGuard/G = mech_guard
		mech_guard = null
		invisibility = 0
		mouse_opacity = 1
		if(!G) return
		if(G.mech_record == src && !disabled && G.Health > 0)
			Hull = clamp(G.Health, 0, MechHullMax())
		G.mech_record = null
		G.RemoveTarget()
		G.loc = null
		spawn(0)
			if(G) del G

	proc/MechGuardPower()
		var/mob/Player/AI/Emplacement/MechGuard/G = mech_guard
		if(!G) return
		var/total = glob && glob.progress ? glob.progress.totalPotentialToDate : 1
		G.EmplacementStats(round(total * TurretPotentialBand(CraftQuality), 0.1))
		var/list/S = MechStats()
		G.EndReplace = max(0.1, S["End"])
		G.mech_hull_max = glob.HP_PER_VIT * (max(0.1, S["Vit"]) + glob.HP_STAT_BASE)

	proc/MechGuardPush()
		var/mob/Player/AI/Emplacement/MechGuard/G = mech_guard
		if(!G) return
		if(disabled)
			G.Health = G.MaxHP()
		else
			G.Health = clamp(Hull, 0.1, G.MaxHP())

	proc/MechGuardPull()
		var/mob/Player/AI/Emplacement/MechGuard/G = mech_guard
		if(!G || disabled) return
		Hull = clamp(G.Health, 0, MechHullMax())
		if(Hull <= 0) MechGuardDown(null)

	proc/MechGuardDown(mob/P)
		Hull = 0
		if(!disabled) MechHullZero()
		MechGuardPush()
		MechLook()

/mob/Player/AI/Emplacement/MechGuard
	name = "Mech"
	var/tmp/obj/Items/Mech/mech_record
	var/tmp/turf/mech_home
	var/tmp/mech_hull_max = 0
	var/tmp/mech_watching = 0

	ApplyPixelBounds()
		bound_width = 32
		bound_height = 32
		bound_x = 0
		bound_y = 0

	MaxHP()
		if(mech_hull_max > 0) return mech_hull_max
		return ..()

	LoseHealth(val)
		..()
		if(mech_record) mech_record.MechGuardPull()

	EmplacementKey()
		return mech_record ? mech_record.builder : null

	EmplacementDown(mob/P)
		if(mech_record)
			mech_record.MechGuardDown(P)
			return
		..()

	EMPHit(strength)
		return 0

	Click(location, control, params)
		var/was = (usr.Target == src)
		..()
		if(!mech_record || get_dist(usr, src) > 1) return
		if(was) mech_record.MechMenu(usr)

	proc/MechGuardLook(obj/Items/Mech/R)
		if(!R) return
		name = R.name
		icon = R.icon
		icon_state = R.icon_state
		pixel_x = R.pixel_x
		pixel_y = R.pixel_y
		dir = R.dir
		color = R.color
		ApplyPixelBounds()
		ApplyHurtbox()

	proc/MechGuardWatch()
		set waitfor = 0
		if(mech_watching) return
		mech_watching = 1
		while(src && loc)
			var/obj/Items/Mech/R = mech_record
			if(!R || R.mech_guard != src)
				loc = null
				spawn(0)
					if(src) del src
				break
			if(R.loc != mech_home || R.mounted)
				R.MechGuardClear()
				break
			R.MechGuardPull()
			R.MechGuardPower()
			EmplacementIntent()
			sleep(MECH_GUARD_TICK)
		mech_watching = 0



mob/Admin3/verb/Give_Mech_Assembly_Parts()
	set name = "Give Mech Assembly Parts"
	set category = "Debug"
	RegisterLifeCrafts()
	RegisterLifeMatFamilies()
	var/list/choices = list()
	for(var/datum/craft_recipe/lifecraft/tech/wearable/mech/R in LifeCraftRecipes("Technology"))
		choices["[R.label] ([R.id])"] = R
	if(!choices.len)
		src << "No mech recipes were found."
		return
	var/pick = Ask(src, "Give materials for which mech?", "Mech Assembly Parts", null, "pick", choices, 1)
	if(!pick) return
	var/datum/craft_recipe/lifecraft/tech/wearable/mech/R = choices[pick]
	if(!R || !R.slots) return
	var/list/materials = list()
	for(var/datum/craft_slotreq/S in R.slots)
		var/chosen
		var/chosen_tier
		for(var/mc in LifeMatRegistry)
			if(!S.Accepts(mc)) continue
			var/tier = LifeMatTier(mc)
			if(!chosen || tier < chosen_tier)
				chosen = mc
				chosen_tier = tier
		if(!chosen)
			src << "Could not find a material for [S.name]. Nothing was granted."
			return
		materials += list(list(chosen, S.amount))
	for(var/list/entry in materials)
		MatLogAdd(entry[1], QUAL_NORMAL, entry[2])
		src << "Added [entry[2]]x [LifeMatName(entry[1])] to your Collection Log."
	var/obj/Items/MechKit/Speed/K = new
	GiveOrDrop(K)
	if(client)
		client.BuildInvPage()
	src << "You now have the materials and a Speed Frame Kit needed to assemble [R.label]."


obj/Items/Mech/proc/MechDetailedInfo(mob/Viewer)
	var/list/L = list()
	RegisterMechIntrinsicParts()

	var/list/row = MechRow()
	var/mob/Pilot
	if(mounted && ismob(loc))
		var/mob/M = loc
		if(M.mech == src)
			Pilot = M

	L += "<b>—— [name] ——</b>"
	if(desc) L += "[desc]"
	L += "Model: [row ? row["name"] : model]"
	L += "Class: [row ? row["class"] : "Unknown"]"
	L += "Level: [MechLevel()] | Quality: [QualityName(CraftQuality)]"
	L += "Status: [disabled ? "Disabled" : (Pilot ? "Piloted" : "Parked")]"

	var/current_hull = Pilot ? Pilot.Health : Hull
	var/maximum_hull = Pilot ? Pilot.MaxHP() : MechHullMax()
	L += "Hull: [round(current_hull, 0.1)] / [round(maximum_hull, 0.1)]"
	L += "Fuel: [round(fuel, 0.1)] / [MECH_FUEL_CAP] minutes"

	var/plating = MechPlatingClass()
	L += "Plating: [plating ? LifeMatName(plating) : "None"]"
	L += "Coating: [MechCoatingName(coating)]"
	L += "Frame kit: [frame_kit ? frame_kit : "None"]"

	// Core and intrinsic reactor.
	L += "<b>—— Core ——</b>"
	L += "Effective core tier: [MechCoreTier()]"

	var/list/reactor = islist(intrinsic_installed) ? intrinsic_installed["Reactor"] : null
	if(islist(reactor))
		var/datum/mech_intrinsic_part/D = MechIntrinsicParts[reactor["part_id"]]
		L += "Intrinsic reactor: [D ? D.name : reactor["part_id"]]"
		if(D && D.description)
			L += "[D.description]"
		L += "Assignment: [IntrinsicValid(reactor) ? "Valid" : "Inactive / invalid"]"
		L += "Installation: [reactor["replaces_core"] ? "Replaces ordinary core" : "Legacy reactor augment"]"
		if(D)
			L += "Base positive Will bonus multiplier: x[D.will_bonus_mult]"
	else
		L += "Ordinary core"

	// Base stats exclude the pilot's Will and compatible buff modifiers.
	L += "<b>—— Base Mech Stats ——</b>"
	var/list/stats = MechStats()
	var/list/stat_lines = list()
	for(var/stat in MECH_STAT_KEYS)
		stat_lines += "[uppertext(stat)]: [round(stats[stat], 0.01)]"
	L += jointext(stat_lines, " | ")

	// Actual current stats while someone is piloting.
	if(Pilot)
		L += "<b>—— Current Pilot Stats ——</b>"
		L += "Pilot: [Pilot.name]"
		L += "Will: [round(Pilot.Will, 0.1)]"
		L += "Will stat bonus: [round(Pilot.GetWillStatMult(), 0.001)]"
		L += "STR: [round(Pilot.GetStr(), 0.01)] | END: [round(Pilot.GetEnd(), 0.01)] | SPD: [round(Pilot.GetSpd(), 0.01)]"
		L += "FOR: [round(Pilot.GetFor(), 0.01)] | OFF: [round(Pilot.GetOff(), 0.01)] | DEF: [round(Pilot.GetDef(), 0.01)]"
		L += "Heat: [round(Pilot.HeatNow(), 0.1)] / [round(Pilot.HeatMax(), 0.1)]"
		L += "Cooling: [round(Pilot.HeatDissipation(), 0.1)] per second"

	// Model-defined passives.
	L += "<b>—— Model Passives ——</b>"
	var/list/passives = row ? row["passive"] : null
	if(islist(passives) && passives.len)
		for(var/i = 1 to passives.len step 2)
			if(i + 1 <= passives.len)
				L += "[passives[i]]: [passives[i + 1]]"
	else
		L += "None"

	// Include occupied slots even if the current frame no longer exposes them.
	L += "<b>—— Installed Parts ——</b>"
	var/list/slots = MechOpenSlots()
	for(var/slot in parts)
		if(!(slot in slots))
			slots += slot

	var/list/shown = list()
	for(var/slot in slots)
		var/slot_name = MECH_SLOT_NAMES[slot]
		if(!slot_name) slot_name = slot

		var/obj/Items/P = MechRawPartIn(slot)
		if(!P)
			L += "[slot_name]: Empty"
			continue

		// Describe paired/two-handed parts once, with all occupied slots.
		if(P in shown) continue
		shown += P

		var/list/occupied = list()
		for(var/other_slot in slots)
			if(MechRawPartIn(other_slot) != P) continue
			var/other_name = MECH_SLOT_NAMES[other_slot]
			occupied += other_name ? other_name : other_slot

		L += "<b>[jointext(occupied, " + ")]: [P.name]</b>"
		if(P.desc) L += "[P.desc]"

		if(P.IsIntrinsicPart())
			L += "Intrinsic part: [IntrinsicPartActive(P) ? "Active" : "Inactive / invalid assignment"]"

			var/datum/mech_intrinsic_part/D = MechIntrinsicParts[P.intrinsic_part_id]
			if(D && D.description)
				L += "[D.description]"
		else
			L += "Quality: [QualityName(P.CraftQuality)]"

		var/part_tier = MechPartVar(P, "part_tier")
		if(isnum(part_tier))
			L += "Part tier: [part_tier]"

		var/heat = MechPartVar(P, "heat_cost")
		if(isnum(heat) && heat > 0)
			L += "Listed base heat cost: [heat]"

		if(MechPartVar(P, "grants_flight"))
			L += "Enables flight"

		if(!P.IsIntrinsicPart() || IntrinsicPartActive(P))
			var/list/techniques = MechPartTechniques(P)
			for(var/path in techniques)
				var/obj/Skills/S = path
				L += "Skill: [initial(S.name)]"
				var/skill_desc = initial(S.Desc)
				if(skill_desc)
					L += "[skill_desc]"

	// Chips are stored as type -> quality.
	L += "<b>—— Chips ([length(socket_chips)] / [MechSockets()]) ——</b>"
	if(length(socket_chips))
		for(var/path in socket_chips)
			L += "[QualityName(socket_chips[path])] [TechItemName(path)]"
			if(ispath(path, /obj/Items))
				var/obj/Items/C = path
				var/chip_desc = initial(C.desc)
				if(chip_desc)
					L += "[chip_desc]"
	else
		L += "None"

	if(Viewer && MechIsPilot(Viewer))
		L += "<b>—— Registration ——</b>"
		L += "Builder: [builder]"
		L += "Registered pilots: [jointext(pilots, ", ")]"

	return L

obj/Items/Mech/proc/ShowMechInfo(mob/Viewer)
	if(!Viewer) return
	for(var/line in MechDetailedInfo(Viewer))
		Viewer << line

mob/verb/Mech_Information()
	set name = "Mech Information"
	set category = "Character Custom"

	if(!mech)
		src << "You are not piloting a mech. Use a parked mech's Status action."
		return

	mech.ShowMechInfo(src)