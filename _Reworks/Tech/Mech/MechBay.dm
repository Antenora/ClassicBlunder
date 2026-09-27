proc/MechCeil(n)
	return -round(-(n - 0.000001))

proc/MechKitType(key)
	for(var/T in typesof(/obj/Items/MechKit) - /obj/Items/MechKit)
		var/obj/Items/MechKit/K = T
		if(initial(K.kit_key) == key) return T
	return null

/obj/LifeSkills/Station/MechBay
	name = "Mech Bay"
	icon = 'Icons/LifeSkills/Stations.dmi'
	icon_state = "anvil"
	desc = "A gantry for building and servicing mechs. Face it and press your Interact key."
	density = 1
	station_kind = "mechbay"
	craft_skill = "Technology"
	craft_title = "MECH BAY"
	craft_verb = "ASSEMBLE"

	Click()
		if(!usr) return
		if(!CraftReach(usr))
			usr << "You need to get closer to the [name]."
			return
		MechBayMenu(usr)

	InteractWith(mob/M)
		if(!M || !M.client || !CraftReach(M)) return 0
		spawn(0)
			MechBayMenu(M)
		return 1

	proc/MechBayMenu(mob/M)
		if(!M || !M.client || M.KO || M.Dead) return
		if(!CraftReach(M)) return
		var/list/acts = list("Assemble", "Repair", "Refit", "Pilots", "Pull Beacon", "Repaint", "Loadout")
		var/act = Ask(M, "What do you want to do at the [name]?", craft_title, null, "pick", acts, 1)
		if(!act || !src || !M || !CraftReach(M)) return
		if(act == "Assemble")
			if(M.client) M.client.LifeCraftOpen(src)
			return
		var/obj/Items/Mech/R = MechBayPickRecord(M)
		if(!R) return
		switch(act)
			if("Repair")
				MechBayRepair(M, R)
			if("Refit")
				MechBayRefit(M, R)
			if("Pilots")
				MechBayPilots(M, R)
			if("Pull Beacon")
				MechBayPullBeacon(M, R)
			if("Repaint")
				MechBayRepaint(M, R)
			if("Loadout")
				MechBayLoadout(M, R)

	proc/MechBayRecords(mob/M)
		. = list()
		for(var/turf/X in range(MECH_BAY_REACH, src))
			for(var/obj/Items/Mech/R in X)
				if(!isturf(R.loc) || R.mounted) continue
				if(!R.MechIsPilot(M)) continue
				. += R

	proc/MechBayValid(mob/M, obj/Items/Mech/R)
		if(!M || !R || !src) return 0
		if(!isturf(R.loc) || R.mounted || get_dist(R, src) > MECH_BAY_REACH) return 0
		if(!R.MechIsPilot(M) || !CraftReach(M)) return 0
		return 1

	proc/MechBayPickRecord(mob/M)
		var/list/L = MechBayRecords(M)
		if(!L.len)
			M << "Park a mech you are registered on within [MECH_BAY_REACH] tiles of the [name]."
			return null
		if(L.len == 1) return L[1]
		var/list/labels = list()
		for(var/obj/Items/Mech/R in L)
			labels["[R.name], Hull [round(R.Hull)] of [round(R.MechHullMax())] ([R.x],[R.y])"] = R
		var/k = Ask(M, "Which mech?", craft_title, null, "pick", labels, 1)
		if(!k) return null
		var/obj/Items/Mech/R = labels[k]
		return MechBayValid(M, R) ? R : null

	proc/MechBayRepairCost(obj/Items/Mech/R)
		var/mx = max(1, R.MechHullMax())
		var/list/row = R.MechRow()
		var/pn = row ? row["plating_n"] : MECH_PLATING_MEDIUM
		var/missing = clamp(mx - R.Hull, 0, mx)
		if(R.disabled) missing = mx
		var/ingots = max(MECH_REPAIR_MIN, MechCeil(missing / mx * pn / MECH_REPAIR_DIVISOR))
		var/servos = (R.disabled || R.Hull <= 0) ? MECH_REPAIR_SERVOS : 0
		if(R.MechHasPassive("Mass Production"))
			ingots = max(MECH_REPAIR_MIN, MechCeil(ingots / 2))
			servos = MechCeil(servos / 2)
		return list(ingots, servos)

	proc/MechBayRepair(mob/M, obj/Items/Mech/R)
		var/mx = R.MechHullMax()
		if(R.Hull >= mx && !R.disabled)
			M << "[R] needs no repair."
			return
		var/mc = R.MechPlatingClass()
		if(!mc)
			M << "The Bay cannot tell what metal [R] is plated with."
			return
		var/list/c = MechBayRepairCost(R)
		var/list/need = list("[c[1]]x [LifeMatName(mc)]")
		if(c[2]) need += "[c[2]]x Servo"
		var/list/short = list()
		if(CountMaterial(M, mc) < c[1]) short += "[c[1] - CountMaterial(M, mc)]x [LifeMatName(mc)]"
		if(c[2] && CountMaterial(M, "Servo") < c[2]) short += "[c[2] - CountMaterial(M, "Servo")]x Servo"
		if(short.len)
			M << "Repairing [R] takes [jointext(need, " and ")]. You are short [jointext(short, " and ")]."
			return
		ConsumeMaterial(M, mc, c[1])
		if(c[2]) ConsumeMaterial(M, "Servo", c[2])
		R.disabled = 0
		R.Hull = R.MechHullMax()
		R.MechLook()
		R.MechGuardSync()
		OMsg(M, "[M] repairs [R] at the [name] with [jointext(need, " and ")].")

	proc/MechBayRefit(mob/M, obj/Items/Mech/R)
		if(M.InCombat())
			M << "You can't refit a mech in a fight."
			return
		var/list/opts = list()
		for(var/s in R.MechOpenSlots())
			var/obj/Items/P = R.MechPartIn(s)
			opts["[MECH_SLOT_NAMES[s]]: [P ? P.name : "empty"]"] = s
		opts["Frame kit: [R.frame_kit ? R.frame_kit : "none"]"] = "kit"
		opts["Coating: [MechCoatingName(R.coating)]"] = "coating"
		opts["Reactor: tier [R.core_tier] core"] = "reactor"
		opts["Chips: [length(R.socket_chips)] of [R.MechSockets()]"] = "chips"
		var/pick = Ask(M, "Refit which part of [R]? Each refit costs [MECH_REFIT_LS] Life Stamina, and the old component comes back to you.", craft_title, null, "pick", opts, 1)
		if(!pick || !MechBayValid(M, R)) return
		var/what = opts[pick]
		switch(what)
			if("kit")
				MechBayRefitKit(M, R)
			if("coating")
				MechBayRefitCoating(M, R)
			if("reactor")
				MechBayRefitReactor(M, R)
			if("chips")
				MechBayRefitChips(M, R)
			else
				MechBayRefitSlot(M, R, what)

	proc/MechBayPay(mob/M, obj/Items/Mech/R)
		if(!MechBayValid(M, R) || M.InCombat()) return 0
		return M.UseLifeStamina(MECH_REFIT_LS)

	proc/MechBayRefitSlot(mob/M, obj/Items/Mech/R, slot)
		var/fam = MechSlotFamily(slot)
		var/obj/Items/cur = R.MechPartIn(slot)
		var/list/labels = list()
		if(cur) labels["Take out [cur.name]"] = "out"
		for(var/obj/Items/I in M)
			if(I.mech_slot != fam || I.suffix == "*Equipped*") continue
			if(R.MechPartFits(I, slot)) continue
			var/lab = "[QualityName(I.CraftQuality)] [I.name]"
			var/n = 2
			while(labels[lab])
				lab = "[QualityName(I.CraftQuality)] [I.name] ([n++])"
			labels[lab] = I
		if(!labels.len)
			M << "You carry no [lowertext(fam)] part that fits [R]'s [MECH_SLOT_NAMES[slot]]."
			return
		var/k = Ask(M, "What goes into [R]'s [MECH_SLOT_NAMES[slot]]?", craft_title, null, "pick", labels, 1)
		if(!k) return
		MechBayApplySlot(M, R, slot, labels[k])

	proc/MechBayApplySlot(mob/M, obj/Items/Mech/R, slot, choice)
		var/before = R.MechHullMax()
		if(choice == "out")
			var/obj/Items/cur = R.MechPartIn(slot)
			if(!cur || !MechBayPay(M, R)) return 0
			R.MechUnfit(cur, M)
			M << "You pull [cur] out of [R]."
		else
			var/obj/Items/I = choice
			if(!istype(I) || I.loc != M || R.MechPartFits(I, slot) || !MechBayPay(M, R)) return 0
			R.MechFit(I, slot, M)
			M << "You fit [I] into [R]'s [MECH_SLOT_NAMES[slot]]."
		if(M.client) M.client.BuildInvPage()
		R.MechRefitDone(before)
		return 1

	proc/MechBayRefitKit(mob/M, obj/Items/Mech/R)
		var/list/labels = list()
		for(var/obj/Items/MechKit/K in M)
			if(K.kit_key == R.frame_kit || labels["[K.name]"]) continue
			labels["[K.name]"] = K
		if(!labels.len)
			M << "You carry no other Frame kit."
			return
		var/k = Ask(M, "Which Frame kit goes into [R]?", craft_title, null, "pick", labels, 1)
		if(!k) return
		MechBayApplyKit(M, R, labels[k])

	proc/MechBayApplyKit(mob/M, obj/Items/Mech/R, obj/Items/MechKit/K)
		if(!istype(K) || K.loc != M || K.kit_key == R.frame_kit || !MechBayPay(M, R)) return 0
		var/before = R.MechHullMax()
		var/old = R.frame_kit
		R.frame_kit = K.kit_key
		M << "You fit [K] into [R]."
		del K
		var/oldtype = MechKitType(old)
		if(oldtype)
			var/obj/Items/MechKit/back = new oldtype
			M.GiveOrDrop(back)
		if(M.client) M.client.BuildInvPage()
		R.MechRefitDone(before)
		return 1

	proc/MechBayMaterialChoices(mob/M, sel, exclude)
		. = list()
		RegisterLifeMaterials()
		var/datum/craft_slotreq/S = new
		S.mat_tag = copytext(sel, 5)
		for(var/mc in LifeMatRegistry)
			if(mc == exclude || !S.Accepts(mc)) continue
			for(var/q = QUAL_POOR to QUAL_LEGENDARY)
				if(M.MatLogCountQ(mc, q) > 0)
					.["[QualityName(q)] [LifeMatName(mc)]"] = list(mc, q)

	proc/MechBayRefitCoating(mob/M, obj/Items/Mech/R)
		var/list/labels = MechBayMaterialChoices(M, TECH_SEL_COATING, R.coating)
		if(R.coating) labels["Strip the [LifeMatName(R.coating)] coating"] = "strip"
		if(!labels.len)
			M << "You have no coating material in your Collection Log."
			return
		var/k = Ask(M, "What coats [R]? The coating is now [MechCoatingName(R.coating)].", craft_title, null, "pick", labels, 1)
		if(!k) return
		var/choice = labels[k]
		if(islist(choice))
			var/list/p = choice
			MechBayApplyCoating(M, R, p[1], p[2])
		else if(choice == "strip")
			MechBayApplyCoating(M, R, null, null)

	proc/MechBayApplyCoating(mob/M, obj/Items/Mech/R, mc, q)
		if(mc)
			var/datum/craft_slotreq/S = new
			S.mat_tag = copytext(TECH_SEL_COATING, 5)
			if(!S.Accepts(mc) || mc == R.coating || M.MatLogCountQ(mc, q) < 1) return 0
		else if(!R.coating)
			return 0
		if(!MechBayPay(M, R)) return 0
		var/before = R.MechHullMax()
		var/old = R.coating
		if(mc)
			LifeConsumeExact(M, mc, q, 1)
			R.coating = mc
			M << "You coat [R] in [LifeMatName(mc)]."
		else
			R.coating = null
			M << "You strip the coating off [R]."
		if(old) M.MatLogAdd(old, QUAL_NORMAL, 1)
		R.MechRefitDone(before)
		return 1

	proc/MechBayRefitReactor(mob/M, obj/Items/Mech/R)
		var/list/labels = MechBayMaterialChoices(M, TECH_SEL_CORE, null)
		if(!labels.len)
			M << "You have no golem core in your Collection Log."
			return
		var/k = Ask(M, "Which core powers [R]? It runs a tier [R.core_tier] core now.", craft_title, null, "pick", labels, 1)
		if(!k) return
		var/list/p = labels[k]
		if(islist(p)) MechBayApplyReactor(M, R, p[1], p[2])

	proc/MechBayApplyReactor(mob/M, obj/Items/Mech/R, mc, q)
		var/datum/craft_slotreq/S = new
		S.mat_tag = copytext(TECH_SEL_CORE, 5)
		if(!mc || !S.Accepts(mc) || M.MatLogCountQ(mc, q) < 1 || !MechBayPay(M, R)) return 0
		var/before = R.MechHullMax()
		var/old = R.core_tier
		LifeConsumeExact(M, mc, q, 1)
		R.core_tier = clamp(LifeMatTier(mc), MECH_CORE_TIER_MIN, MECH_CORE_TIER_MAX)
		var/oldmc = MechCoreClassForTier(old)
		if(oldmc) M.MatLogAdd(oldmc, QUAL_NORMAL, 1)
		M << "You seat a [LifeMatName(mc)] in [R]. It is Level [R.MechLevel()] now."
		R.MechRefitDone(before)
		return 1

	proc/MechBayRefitChips(mob/M, obj/Items/Mech/R)
		var/list/acts = list()
		if(length(R.socket_chips) < R.MechSockets()) acts += "Socket a chip"
		if(length(R.socket_chips)) acts += "Pull a chip"
		if(!acts.len)
			M << "[R] has no chip sockets."
			return
		var/act = Ask(M, "Chip sockets on [R]: [length(R.socket_chips)] of [R.MechSockets()] used.", craft_title, null, "pick", acts, 1)
		if(!act) return
		if(act == "Socket a chip")
			var/list/labels = list()
			for(var/obj/Items/Chip/C in M)
				if(!R.MechChipFits(C)) continue
				var/lab = "[QualityName(C.CraftQuality)] [C.name]"
				if(!labels[lab]) labels[lab] = C
			if(!labels.len)
				M << "You have no System or Routine chip that fits [R]."
				return
			var/k = Ask(M, "Which chip goes into [R]?", craft_title, null, "pick", labels, 1)
			if(!k) return
			MechBayApplySocket(M, R, labels[k])
		else
			var/list/labels = list()
			for(var/t in R.socket_chips)
				labels["[QualityName(R.socket_chips[t])] [TechItemName(t)]"] = t
			var/k = Ask(M, "Which chip comes out of [R]?", craft_title, null, "pick", labels, 1)
			if(!k) return
			MechBayApplyUnsocket(M, R, labels[k])

	proc/MechBayApplySocket(mob/M, obj/Items/Mech/R, obj/Items/Chip/C)
		if(!istype(C) || C.loc != M || !R.MechChipFits(C) || length(R.socket_chips) >= R.MechSockets() || !MechBayPay(M, R)) return 0
		if(!R.socket_chips) R.socket_chips = list()
		R.socket_chips[C.type] = C.CraftQuality
		M << "You socket [C] into [R]."
		del C
		if(M.client) M.client.BuildInvPage()
		return 1

	proc/MechBayApplyUnsocket(mob/M, obj/Items/Mech/R, t)
		if(!t || !R.socket_chips || !(t in R.socket_chips) || !MechBayPay(M, R)) return 0
		var/q = R.socket_chips[t]
		R.socket_chips -= t
		if(!R.socket_chips.len) R.socket_chips = null
		var/obj/Items/Chip/C = new t
		C.CraftQuality = q
		M.GiveOrDrop(C)
		M << "You pull [C] out of [R]."
		if(M.client) M.client.BuildInvPage()
		return 1

	proc/MechBayPilots(mob/M, obj/Items/Mech/R)
		if(!R.MechIsBuilder(M))
			M << "Only [R]'s builder can change who pilots it."
			return
		var/list/acts = list("Add a pilot")
		var/list/others = R.MechPilotOthers()
		if(others.len) acts += "Remove a pilot"
		var/act = Ask(M, "Pilots of [R]: [jointext(R.pilots, ", ")].", craft_title, null, "pick", acts, 1)
		if(!act || !MechBayValid(M, R)) return
		if(act == "Add a pilot") R.MechPilotAdd(M)
		else R.MechPilotRemove(M)

	proc/MechBayRepaint(mob/M, obj/Items/Mech/R)
		var/k = Ask(M, "Which paint for [R]?", craft_title, null, "pick", MECH_PAINTS, 1)
		if(!k || !MechBayValid(M, R)) return
		R.paint = MECH_PAINTS[k]
		M << "[R] is marked for a [lowertext(k)] paint job."

	proc/MechBayPullBeacon(mob/M, obj/Items/Mech/R)
		if(M) M << "No beacon is fitted to [R]."

	proc/MechBayLoadout(mob/M, obj/Items/Mech/R)
		if(M) M << "The Bay's loadout console is not wired to [R] yet."

mob/Admin4/verb/makeMechBay()
	set category = "Admin"
	new/obj/LifeSkills/Station/MechBay(get_step(src, src.dir))
	src << "Mech Bay placed."
