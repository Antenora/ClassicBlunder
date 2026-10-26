/mob/var/list/installed_chips
/mob/var/chipLoad = 0
/mob/var/list/chip_prior
/mob/var/tmp/list/chip_offline
/mob/var/tmp/chip_offline_id = 0

/obj/Items/Chip
	name = "Chip"
	desc = "A cybernetic module, ready for installation."
	icon = CHIP_ICON_MODULES
	icon_state = CHIP_STATE_STAT
	var/ChipFamily = ""
	var/Load = 0
	var/ModuleKey = ""
	var/ChipScales = 0
	var/ChipRemovable = 1
	var/ChipAndroidOnly = 0
	var/ChipOrganicOnly = 0

	proc/ChipBlock(mob/M, short)
		if(ChipAndroidOnly && !M.isRace(ANDROID))
			return short ? "Android only" : "Only an Android can take the [name]."
		if(ChipOrganicOnly && M.isRace(ANDROID))
			return short ? "not for Androids" : "An Android cannot take the [name]."
		return null

	Stat
		ChipFamily = "Stat"
		Load = CHIP_LOAD_STAT
		icon_state = CHIP_STATE_STAT
		ChipScales = 1

		Enhanced_Strength
			name = "Enhanced Strength"
			ModuleKey = "Enhanced Strength"
			desc = "Enhanced Strength increases Strength."
		Enhanced_Force
			name = "Enhanced Force"
			ModuleKey = "Enhanced Force"
			desc = "Enhanced Force increases Force."
		Enhanced_Endurance
			name = "Enhanced Endurance"
			ModuleKey = "Enhanced Endurance"
			desc = "Enhanced Endurance increases Endurance."
		Enhanced_Aggression
			name = "Enhanced Aggression"
			ModuleKey = "Enhanced Aggression"
			desc = "Enhanced Aggression increases Offense."
		Enhanced_Reflexes
			name = "Enhanced Reflexes"
			ModuleKey = "Enhanced Reflexes"
			desc = "Enhanced Reflexes increases Defense."
		Enhanced_Speed
			name = "Enhanced Speed"
			ModuleKey = "Enhanced Speed"
			desc = "Enhanced Speed increases Speed."

	Routine
		ChipFamily = "Routine"
		Load = CHIP_LOAD_ROUTINE
		icon_state = CHIP_STATE_ROUTINE

		Taser_Strike
			name = "Taser Strike"
			ModuleKey = "Taser Strike"
			desc = "Taser Strike delivers an electric shock to the opponent to allow for more openings."
		Rocket_Punch
			name = "Rocket Punch"
			ModuleKey = "Rocket Punch"
			desc = "Rocket Punch fires a mechanized appendage for an explosive assault."
		Internal_Comms_Suite
			name = "Internal Comms Suite"
			ModuleKey = "Internal Comms Suite"
			desc = "The Internal Comms Suite lets the augmented scan precise power levels and access wireless communications from inside their own head."
		Machine_Gun_Flurry
			name = "Machine Gun Flurry"
			ModuleKey = "Machine Gun Flurry"
			desc = "Machine Gun Flurry unleashes a rush of blows once enough momentum has been gathered."

	System
		ChipFamily = "System"
		Load = CHIP_LOAD_SYSTEM
		icon_state = CHIP_STATE_SYSTEM

		Nano_Boost
			name = "Nano Boost"
			ModuleKey = "Nano Boost"
			desc = "Nano Boost gives the augmented a sudden surge of cybernetic power when they are badly hurt."
		Combat_CPU
			name = "Combat CPU"
			ModuleKey = "Combat CPU"
			desc = "Combat CPU burns a little battery to run constant simulations of the fight. Bottom line: better evasion."
		Stealth_Systems
			name = "Stealth Systems"
			ModuleKey = "Stealth Systems"
			desc = "Stealth Systems let the augmented visually disguise themselves when they lower their power."
		Reconstructive_Nanobots
			name = "Reconstructive Nanobots"
			ModuleKey = "Reconstructive Nanobots"
			desc = "Reconstructive Nanobots repair the augmented with precise efficiency when they enter a rest cycle."
		Blade_Mode
			name = "Blade Mode"
			ModuleKey = "Blade Mode"
			desc = "Blade Mode runs high speed calculations that improve the accuracy and swiftness of delivered blows."
		Internal_Life_Support
			name = "Internal Life Support"
			ModuleKey = "Internal Life Support"
			desc = "Internal Life Support keeps the augmented from perishing to mortal wounds."
			ChipOrganicOnly = 1
		Energy_Assimilators
			name = "Energy Assimilators"
			ModuleKey = "Energy Assimilators"
			desc = "Energy Assimilators are small, orb-like constructs fitted into the palm of a hand that consume energy on direct contact with its source."
			ChipAndroidOnly = 1
		Targeting_CPU
			name = "Targeting CPU"
			ModuleKey = "Targeting CPU"
			desc = "The Targeting CPU steadies the augmented's aim: guns bloom less and land more often."
			ChipScales = 1

	Control
		ChipFamily = "Control"
		Load = CHIP_LOAD_CONTROL
		icon = CHIP_ICON_CONTROL
		icon_state = CHIP_STATE_CONTROL
		ChipRemovable = 0

		Punishment_Chip
			name = "Punishment Chip"
			ModuleKey = "Punishment Chip"
			desc = "A simple electric circuit wired into the receiver's nervous system."
			ChipOrganicOnly = 1
		Failsafe_Circuit
			name = "Failsafe Circuit"
			ModuleKey = "Failsafe Circuit"
			desc = "A failsafe circuit that lets its holder switch the receiver's power off in case of disobedience."
			ChipBlock(mob/M, short)
				. = ..()
				if(.) return
				if(!M.CyberCancel)
					return short ? "needs cybernetics" : "[M] needs cybernetics installed before a Failsafe Circuit can hook into them."
		Explosive_Implantation
			name = "Explosive Implantation"
			ModuleKey = "Explosive Implantation"
			desc = "A powerful explosive device, implanted in the receiver."

	Frame
		ChipFamily = "Frame"
		Load = CHIP_LOAD_FRAME
		icon_state = CHIP_STATE_FRAME

		Ripper_Mode
			name = "Ripper Mode"
			ModuleKey = "Ripper Mode"
			desc = "Ripper Mode lets the augmented present a facsimile of sadism that greatly bolsters speed and offensive prowess."
		Armstrong_Augmentation
			name = "Armstrong Augmentation"
			ModuleKey = "Armstrong Augmentation"
			desc = "Armstrong Augmentation forges a powerful nanite shell in response to physical trauma, raising Strength and Endurance while forsaking Defense."
		Ray_Gear
			name = "Ray Gear"
			ModuleKey = "Ray Gear"
			desc = "Ray Gear gives the augmented unparalleled firepower and folds ranged capabilities into their basic combat protocols while sapping their battery."
		Hilbert_Effect
			name = "Hilbert Effect"
			ModuleKey = "Hilbert Effect"
			desc = "The Hilbert Effect breaches into a higher domain, raising every offensive capability while sapping the battery."
		Overdrive
			name = "Overdrive"
			ModuleKey = "Overdrive"
			desc = "Overdrive overclocks every cybernetically enhanced aspect in exchange for battery life."
		Infinity_Drive
			name = "Infinity Drive"
			ModuleKey = "Infinity Drive"
			desc = "Infinity Drive lets a fusion-powered augmented support their whole performance with a nigh-infinite energy output."
		Cybernetic_Mainframe
			name = "Cybernetic Mainframe"
			ModuleKey = "Cybernetic Mainframe"
			desc = "A cybernetic mainframe makes its holder a complete cyborg, forsaking most natural abilities for more room to customize, and it frees more Load for other chips."
			Load = CHIP_LOAD_MAINFRAME
			ChipBlock(mob/M, short)
				. = ..()
				if(.) return
				if(M.isRace(ANDROID) && M.Potential < CHIP_MAINFRAME_ANDROID_POTENTIAL)
					return short ? "Potential [CHIP_MAINFRAME_ANDROID_POTENTIAL]" : "An Android needs Potential [CHIP_MAINFRAME_ANDROID_POTENTIAL] before its frame can take a Mainframe."

proc/ChipQualityFactor(q)
	switch(QualityClamp(q))
		if(QUAL_POOR)
			return CHIP_Q_POOR
		if(QUAL_GOOD)
			return CHIP_Q_GOOD
		if(QUAL_EPIC)
			return CHIP_Q_EPIC
		if(QUAL_LEGENDARY)
			return CHIP_Q_LEGENDARY
	return CHIP_Q_NORMAL

proc/ChipFactorFor(path, q)
	var/obj/Items/Chip/P = path
	return initial(P.ChipScales) ? ChipQualityFactor(q) : 1

proc/ChipTypes()
	. = list()
	for(var/t in typesof(/obj/Items/Chip))
		var/obj/Items/Chip/P = t
		if(initial(P.ModuleKey)) . += t

proc/ChipPassives(key, q = QUAL_NORMAL)
	if(ispath(key, /obj/Items/Chip))
		var/obj/Items/Chip/P = key
		key = initial(P.ModuleKey)
	if(key == "Targeting CPU")
		return list("Targeting CPU" = ChipQualityFactor(q))
	return list()

proc/ChipPriorVars(key, mob/M)
	switch(key)
		if("Ripper Mode", "Armstrong Augmentation", "Ray Gear", "Hilbert Effect", "Overdrive", "Infinity Drive")
			return list("FusionPowered", "ManaPU")
		if("Cybernetic Mainframe")
			if(M && M.isRace(ANDROID))
				return list("transUnlocked")
	return null

mob/proc/ChipCount(path)
	if(!installed_chips) return 0
	var/list/qs = installed_chips[path]
	return qs ? qs.len : 0

mob/proc/ChipHasMainframe()
	return (CyberneticMainframe || ChipCount(/obj/Items/Chip/Frame/Cybernetic_Mainframe)) ? 1 : 0

mob/proc/ChipCap()
	return EnhanceChipsMax + (ChipHasMainframe() ? CHIP_CAP_MAINFRAME : 0)

mob/proc/ChipRecord(path, q)
	if(!installed_chips) installed_chips = list()
	var/list/qs = installed_chips[path]
	if(!qs)
		qs = list()
		installed_chips[path] = qs
	qs += q

mob/proc/ChipUnrecord(path, q)
	if(!installed_chips) return
	var/list/qs = installed_chips[path]
	if(qs) qs -= q
	if(!qs || !qs.len) installed_chips -= path
	if(!installed_chips.len) installed_chips = null

mob/proc/ChipReceiver()
	if(isRace(ANDROID)) return src
	if(knowledgeTracker && ("Cyber Augmentations" in knowledgeTracker.learnedKnowledge))
		var/mob/T = Target
		if(istype(T) && T != src && T.z == z && get_dist(src, T) <= 1) return T
	return src

mob/proc/ChipRefusal(obj/Items/Chip/C, mob/M, short = 0)
	if(!C || C.loc != src) return short ? "gone" : "That chip is no longer in your pack."
	if(!M || M.Dead) return short ? "no receiver" : "There is no one to operate on."
	if(M != src && (M.z != z || get_dist(src, M) > 1)) return short ? "too far" : "[M] is too far away to operate on."
	if(M.Secret == "Heavenly Restriction" && (M.secretDatum?:hasRestriction("Science") || M.secretDatum?:hasRestriction("Cybernetics")))
		return short ? "restricted" : "[M]'s body rejects cybernetics."
	if(!(M == src && isRace(ANDROID)) && M.Saga && !(M.Saga in glob.CYBERIZESAGAS))
		return short ? "saga" : "[M]'s path does not allow cybernetics."
	var/why = C.ChipBlock(M, short)
	if(why) return why
	if(C.ChipFamily != "Stat" && M.ChipCount(C.type))
		return short ? "installed" : "[M] already has a [C.name] installed."
	var/cap = M.ChipCap()
	var/need = M.chipLoad + C.Load
	if(need > cap)
		return short ? "Load full" : "Load full: the [C.name] would put [M] at [need] of [cap] Load."
	return null

mob/proc/ChipPriorTake(key)
	. = list()
	for(var/v in ChipPriorVars(key, src))
		if(chip_prior && (v in chip_prior)) continue
		if(!chip_prior) chip_prior = list()
		chip_prior[v] = vars[v]
		. += v

mob/proc/ChipPriorDrop(list/taken)
	if(!chip_prior) return
	for(var/v in taken)
		chip_prior -= v
	if(!chip_prior.len) chip_prior = null

mob/proc/ChipVarClaimed(v, skip)
	for(var/t in installed_chips)
		if(t == skip) continue
		var/obj/Items/Chip/P = t
		if(v in ChipPriorVars(initial(P.ModuleKey), src)) return 1
	return 0

mob/proc/ChipPriorRelease(key, list/log, skip)
	for(var/v in ChipPriorVars(key, src))
		if(!chip_prior || !(v in chip_prior)) continue
		if(ChipVarClaimed(v, skip)) continue
		ChipVarSet(v, chip_prior[v], log)
		if(isnull(log)) chip_prior -= v
	if(chip_prior && !chip_prior.len) chip_prior = null

mob/proc/ChipVarAdd(v, delta, list/log)
	var/n = vars[v] + delta
	if(abs(n) < 0.0001) n = isnull(initial(vars[v])) ? null : 0
	vars[v] = n
	if(log) log += list(list("add", v, -delta))

mob/proc/ChipVarSet(v, val, list/log)
	if(log) log += list(list("set", v, vars[v]))
	vars[v] = val

mob/proc/ChipVarReset(v, list/log)
	ChipVarSet(v, initial(vars[v]), log)

mob/proc/ChipPassiveAdd(key, delta, list/log)
	if(!passive_handler) return
	if(delta > 0)
		passive_handler.Increase(key, delta)
	else
		passive_handler.Decrease(key, -delta)
	if(abs(passive_handler.Get(key)) < 0.0001 && passive_handler.passives)
		passive_handler.passives -= key
	if(log) log += list(list("passive", key, -delta))

mob/proc/ChipSkillOff(path, list/log)
	var/obj/Skills/S
	for(var/obj/Skills/K in src)
		if(K.type == path) S = K
	if(!S) return
	if(istype(S, /obj/Skills/Buffs))
		var/obj/Skills/Buffs/B = S
		if(BuffOn(B)) B.Trigger(src, Override = 1)
	DeleteSkill(S, log ? FALSE : TRUE)
	if(log) log += list(list("skill", S))

mob/proc/ChipUndo(key, factor, list/log)
	switch(key)
		if("Enhanced Strength")
			ChipVarAdd("EnhanceChips", -1, log)
			ChipVarAdd("EnhancedStrength", -factor, log)
		if("Enhanced Endurance")
			ChipVarAdd("EnhanceChips", -1, log)
			ChipVarAdd("EnhancedEndurance", -factor, log)
		if("Enhanced Force")
			ChipVarAdd("EnhanceChips", -1, log)
			ChipVarAdd("EnhancedForce", -factor, log)
		if("Enhanced Speed")
			ChipVarAdd("EnhanceChips", -1, log)
			ChipVarAdd("EnhancedSpeed", -factor, log)
		if("Enhanced Aggression")
			ChipVarAdd("EnhanceChips", -1, log)
			ChipVarAdd("EnhancedAggression", -factor, log)
		if("Enhanced Reflexes")
			ChipVarAdd("EnhanceChips", -1, log)
			ChipVarAdd("EnhancedReflexes", -factor, log)

		if("Nano Boost")
			ChipVarReset("NanoBoost", log)
		if("Blade Mode")
			ChipVarReset("BladeMode", log)
			ChipSkillOff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Blade_Mode, log)
		if("Taser Strike")
			ChipSkillOff(/obj/Skills/Queue/Cyberize/Taser_Strike, log)
		if("Machine Gun Flurry")
			ChipSkillOff(/obj/Skills/AutoHit/Cyberize/Machine_Gun_Flurry, log)
		if("Rocket Punch")
			ChipSkillOff(/obj/Skills/Projectile/Cyberize/Rocket_Punch, log)
		if("Stealth Systems")
			ChipVarReset("StealthSystems", log)
			ChipSkillOff(/obj/Skills/Buffs/SlotlessBuffs/Camouflage, log)
		if("Combat CPU")
			ChipVarReset("CombatCPU", log)
		if("Reconstructive Nanobots")
			ChipVarReset("MeditateModule", log)
		if("Internal Life Support")
			ChipVarReset("StabilizeModule", log)
		if("Energy Assimilators")
			ChipVarReset("EnergyAssimilators", log)
			ChipSkillOff(/obj/Skills/Grapple/Energy_Drain, log)
		if("Internal Comms Suite")
			ChipVarReset("InternalScouter", log)
			ChipSkillOff(/obj/Skills/Utility/Internal_Communicator, log)
		if("Targeting CPU")
			ChipPassiveAdd("Targeting CPU", -factor, log)

		if("Punishment Chip")
			ChipSkillOff(/obj/Skills/Buffs/SlotlessBuffs/Implants/Stun_Chip, log)
		if("Failsafe Circuit")
			ChipSkillOff(/obj/Skills/Buffs/SlotlessBuffs/Implants/Failsafe_Chip, log)
		if("Explosive Implantation")
			ChipSkillOff(/obj/Skills/Buffs/SlotlessBuffs/Implants/Internal_Explosive, log)

		if("Ripper Mode")
			ChipSkillOff(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ripper_Mode, log)
		if("Armstrong Augmentation")
			ChipSkillOff(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Armstrong_Augmentation, log)
		if("Ray Gear")
			ChipSkillOff(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Ray_Gear, log)
		if("Hilbert Effect")
			ChipSkillOff(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Hilbert_Effect, log)
		if("Overdrive")
			ChipSkillOff(/obj/Skills/Buffs/SpecialBuffs/MilitaryFrames/Overdrive, log)
		if("Infinity Drive")
			ChipVarReset("InfinityModule", log)

		if("Cybernetic Mainframe")
			if(!isRace(ANDROID))
				ChipVarReset("CyberneticMainframe", log)
			if(isRace(ANDROID))
				if(transActive) Revert()
				ChipVarReset("SuperAndroid", log)
			ChipSkillOff(/obj/Skills/Utility/Cyborg_Integration, log)
		else
			return 0
	return 1

mob/proc/ChipInstall(obj/Items/Chip/C, mob/M)
	var/obj/Skills/Utility/Cybernetic_Augmentation/S = locate() in src
	if(!S || !C) return 0
	if(!M) M = ChipReceiver()
	if(S.Using)
		src << "You're already running an operation!"
		return 0
	var/why = ChipRefusal(C, M)
	if(why)
		src << "<font color=#ff6464>[why]</font>"
		return 0
	S.Using = 1
	. = ChipInstallRun(S, C, M)
	S.Using = 0

mob/proc/ChipInstallRun(obj/Skills/Utility/Cybernetic_Augmentation/S, obj/Items/Chip/C, mob/M)
	if(client)
		var/who = (M == src) ? "yourself" : "[M]"
		var/lasting = M.isRace(ANDROID) ? "" : " It cannot be taken back out."
		var/Confirm = Ask(src, "Install a [QualityName(C.CraftQuality)] [C.name] ([C.ChipFamily], Load [C.Load]) into [who]?[lasting]", "Cybernetic Augmentation ([C.name])", null, "confirm", null, 1, "No", "Yes")
		if(Confirm != "Yes")
			OMsg(src, "[src] decided to not operate.")
			return 0
	if(M != src)
		var/Consent
		if(knowledgeTracker && ("War Crimes" in knowledgeTracker.learnedKnowledge) && M.KO) Consent = "Yes"
		else Consent = Ask(M, "[C.desc]\nDo you want to undergo the augmentation procedure?", "Cybernetic Augmentation", null, "confirm", null, 1, "No", "Yes")
		if(Consent != "Yes")
			OMsg(src, "[M] rejects the surgery.")
			return 0
	var/why = ChipRefusal(C, M)
	if(why)
		src << "<font color=#ff6464>[why]</font>"
		return 0
	var/q = C.CraftQuality
	var/list/taken = M.ChipPriorTake(C.ModuleKey)
	if(!S.InstallModule(M, C.ModuleKey, ChipFactorFor(C.type, q)))
		M.ChipPriorDrop(taken)
		return 0
	M.ChipRecord(C.type, q)
	M.chipLoad += C.Load
	OMsg(src, "[src] operated on [M], installing a [C.ModuleKey] module!")
	M.SetCyberCancel()
	del C
	if(client) client.BuildInvPage()
	return 1

mob/proc/ChipRemove(path, q)
	if(!isRace(ANDROID))
		src << "Only an Android can open its own frame."
		return 0
	if(InCombat())
		src << "<font color=#ff6464>You can't open your frame in the middle of a fight.</font>"
		return 0
	if(chip_offline)
		src << "<font color=#ff6464>Your systems are still rebooting.</font>"
		return 0
	if(!ChipCount(path)) return 0
	var/obj/Items/Chip/P = path
	if(!initial(P.ChipRemovable))
		src << "<font color=#ff6464>The [initial(P.name)] is locked into your frame.</font>"
		return 0
	var/list/qs = installed_chips[path]
	if(isnull(q)) q = qs[1]
	if(!(q in qs)) return 0
	var/key = initial(P.ModuleKey)
	ChipUndo(key, ChipFactorFor(path, q), null)
	ChipUnrecord(path, q)
	chipLoad = max(0, chipLoad - initial(P.Load))
	ChipPriorRelease(key, null, null)
	SetCyberCancel()
	var/obj/Items/Chip/N = new path
	N.CraftQuality = q
	GiveOrDrop(N)
	OMsg(src, "[src] removes a [key] module from their frame.")
	return 1

mob/proc/ChipOfflineAllowed(path)
	return path != /obj/Items/Chip/Frame/Cybernetic_Mainframe

mob/proc/ChipOffline(path, secs)
	if(chip_offline || !installed_chips) return 0
	if(!path)
		var/list/pool = list()
		for(var/t in installed_chips)
			if(!ChipOfflineAllowed(t)) continue
			var/list/each = installed_chips[t]
			for(var/k = 1 to each.len)
				pool += t
		if(!pool.len) return 0
		path = pick(pool)
	if(!ChipCount(path) || !ChipOfflineAllowed(path)) return 0
	var/obj/Items/Chip/P = path
	var/list/qs = installed_chips[path]
	var/key = initial(P.ModuleKey)
	var/list/log = list()
	ChipUndo(key, ChipFactorFor(path, pick(qs)), log)
	ChipPriorRelease(key, log, path)
	chip_offline = log
	var/id = ++chip_offline_id
	SetCyberCancel()
	src << "<font color=#ff6464>Your [key] module goes offline!</font>"
	spawn(max(1, secs) * 10)
		ChipOnline(id)
	return 1

mob/proc/ChipOnline(id)
	var/list/log = chip_offline
	if(!log) return 0
	if(id && id != chip_offline_id) return 0
	chip_offline = null
	for(var/i = log.len to 1 step -1)
		var/list/e = log[i]
		switch(e[1])
			if("add")
				ChipVarAdd(e[2], e[3], null)
			if("set")
				vars[e[2]] = e[3]
			if("skill")
				AddSkill(e[2])
			if("passive")
				ChipPassiveAdd(e[2], e[3], null)
	SetCyberCancel()
	src << "Your systems come back online."
	return 1

mob/Write(savefile/F)
	if(chip_offline) ChipOnline()
	..()

/obj/Skills/Utility/Cybernetic_Augmentation/proc/ChipMenuKey()
	return "chips:\ref[src]"

/obj/Skills/Utility/Cybernetic_Augmentation/proc/ChipMenu(mob/U)
	if(!U || !U.client) return
	var/mob/M = U.ChipReceiver()
	var/list/rows = list()
	rows[++rows.len] = list("sec" = (M == U) ? "INSTALL INTO YOURSELF" : "INSTALL INTO [uppertext("[M]")]")
	var/n = 0
	for(var/obj/Items/Chip/C in U)
		n++
		var/why = U.ChipRefusal(C, M, 1)
		rows[++rows.len] = list("t" = "[C.name]", "c" = list("[C.ChipFamily]", "[C.Load]", "[QualityName(C.CraftQuality)]", why ? "[why]" : "install"), "h" = "?src=\ref[src];chip=install;ref=\ref[C]")
	if(!n) rows[++rows.len] = list("t" = "no chips in your pack", "c" = list("", "", "", ""))
	if(M == U && U.installed_chips)
		rows[++rows.len] = list("sec" = "INSTALLED")
		var/android = U.isRace(ANDROID)
		for(var/t in U.installed_chips)
			var/obj/Items/Chip/P = t
			var/list/qs = U.installed_chips[t]
			for(var/q in qs)
				var/list/row = list("t" = "[initial(P.name)]")
				var/state = "permanent"
				if(android)
					state = initial(P.ChipRemovable) ? (U.InCombat() ? "in combat" : "remove") : "locked in"
					if(initial(P.ChipRemovable)) row["h"] = "?src=\ref[src];chip=remove;type=[url_encode("[t]")];q=[q]"
				row["c"] = list("[initial(P.ChipFamily)]", "[initial(P.Load)]", "[QualityName(q)]", state)
				rows[++rows.len] = row
	if(hascall(src, "RepairOffered") && call(src, "RepairOffered")(M))
		rows[++rows.len] = list("sec" = "SERVICE")
		rows[++rows.len] = list("t" = "Repair", "c" = list("", "", "", "repair"), "h" = "?src=\ref[src];chip=repair")
	var/list/cols = list(list("l" = "CHIP", "a" = "l"), list("l" = "FAMILY", "a" = "l"), list("l" = "LOAD", "a" = "r"), list("l" = "QUALITY", "a" = "l"), list("l" = "STATUS", "a" = "r"))
	var/sub = "Load [M.chipLoad] of [M.ChipCap()][M == U ? "" : " - [M]"]"
	var/hint = U.isRace(ANDROID) ? "a chip to install it, or an installed one to remove it" : "a chip to install it"
	U.client.TableShow(ChipMenuKey(), "AUGMENT", "Cybernetic Augmentation", sub, cols, rows, hint, null, list("nosort" = 1))

/obj/Skills/Utility/Cybernetic_Augmentation/Topic(href, href_list[])
	var/act = href_list["chip"]
	if(!act) return ..()
	var/mob/U = usr
	if(!istype(U) || !U.client || loc != U) return
	if(U.KO || U.Dead)
		U.client.PanelClose(ChipMenuKey())
		return
	switch(act)
		if("install")
			var/obj/Items/Chip/C = locate(href_list["ref"])
			if(!istype(C) || C.loc != U)
				ChipMenu(U)
				return
			spawn()
				U.ChipInstall(C, U.ChipReceiver())
				ChipMenu(U)
		if("remove")
			var/path = text2path(href_list["type"])
			var/q = text2num(href_list["q"])
			if(!ispath(path, /obj/Items/Chip)) return
			spawn()
				U.ChipRemove(path, q)
				ChipMenu(U)
		if("repair")
			var/mob/M = U.ChipReceiver()
			if(!hascall(src, "Repair") || !call(src, "RepairOffered")(M)) return
			spawn()
				call(src, "Repair")(M)
				ChipMenu(U)

proc/ChipProbeInstall(obj/Skills/Utility/Cybernetic_Augmentation/S, key)
	var/mob/D = new
	D.name = "chip audit"
	D.race = new /race/human
	var/mob/was = usr
	usr = D
	. = S.InstallModule(D, key, 1) ? 1 : 0
	usr = was
	del D

proc/ChipProbeUndo(key)
	var/mob/D = new
	D.name = "chip audit"
	D.race = new /race/human
	. = D.ChipUndo(key, 1, null) ? 1 : 0
	del D

proc/ChipAuditLines()
	RegisterLifeCrafts()
	var/list/out = list("Chip audit")
	var/list/recipe_of = list()
	for(var/datum/craft_recipe/lifecraft/R in LifeCraftRecipes("Technology"))
		if(ispath(R.result_type, /obj/Items/Chip)) recipe_of[R.result_type] = R.id
	var/list/unknown = list()
	var/list/noundo = list()
	var/list/norecipe = list()
	var/obj/Skills/Utility/Cybernetic_Augmentation/S = new
	var/list/types = ChipTypes()
	for(var/t in types)
		var/obj/Items/Chip/P = t
		var/key = initial(P.ModuleKey)
		var/rid = recipe_of[t]
		out += "[t] | [initial(P.ChipFamily)] | Load [initial(P.Load)] | [key] | [rid ? rid : "no recipe"] | removable [initial(P.ChipRemovable) ? "yes" : "no"]"
		if(initial(P.ChipFamily) != "Mech" && !ChipProbeInstall(S, key)) unknown += "[t] ([key])"
		if(initial(P.ChipFamily) != "Mech" && !ChipProbeUndo(key)) noundo += "[t] ([key])"
		if(!rid) norecipe += "[t]"
	del S
	out += "Chip types: [types.len]"
	out += "ModuleKeys the install switch does not know ([unknown.len]): [unknown.len ? jointext(unknown, "; ") : "none"]"
	out += "ModuleKeys the removal switch does not know ([noundo.len]): [noundo.len ? jointext(noundo, "; ") : "none"]"
	out += "Chips with no recipe ([norecipe.len]): [norecipe.len ? jointext(norecipe, "; ") : "none"]"
	return out

mob/Admin4/verb/chipAudit()
	set category = "Admin"
	set name = "Chip Audit"
	for(var/line in ChipAuditLines())
		src << line
