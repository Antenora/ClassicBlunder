globalTracker/var
	MECH_BOARD_DS = 20
	MECH_BOARD_MIN_DS = 5
	MECH_BOARD_PROWESS_DS = 2
	MECH_DISMOUNT_COMBAT_DS = 30
	MECH_FUEL_POLL = 10
	MECH_FUEL_BURN_DS = 600
	MECH_LIMP_LINE_DS = 600
	MECH_LIMP_MOVE = 0.6
	MECH_EJECT_RANGE = 1
	MECH_MEND_DS = 100
	MECH_MEND_PCT = 1
	list/MECH_PROWESS_XP = list(100, 300, 700, 1500, 3000, 6000)

/obj/Items/Mech/var/list/loadout_types

mob/var/tmp
	mech_fuel_token = 0
	mech_limp = 0
	mech_limp_line_at = 0
	mech_eject_at = -1
	mech_mend_at = 0

/obj/Skills/Mech
	name = "Mech"
	Dismount
		name = "Dismount"
		desc = "Climb out of your mech and park it where you stand. The mech has to be standing still. Instant out of combat, a 3 second channel in a fight."
		verb/Dismount()
			set category = "Skills"
			usr.MechDismountPress()
	Refuel
		name = "Refuel"
		desc = "Feed one Fuel Cell from your Collection Log into the mech you pilot."
		verb/Refuel()
			set category = "Skills"
			usr.MechRefuelPress()

/obj/Items/Mech/proc/MechKept(path)
	if(!part_kept) part_kept = list()
	var/obj/Skills/S = part_kept[path]
	if(!S || !S.loc)
		S = new path(src)
		part_kept[path] = S
	return S

/obj/Items/Mech/proc/MechKeptSkills()
	. = list()
	for(var/k in part_kept)
		var/obj/Skills/S = part_kept[k]
		if(S) . += S

/obj/Items/Mech/proc/MechCoreSkillPaths()
	. = list(/obj/Skills/Mech/Dismount, /obj/Skills/Mech/Refuel)
	var/list/row = MechRow()
	if(row && islist(row["baked"])) . += row["baked"]

/obj/Items/Mech/proc/MechEnsureSkills()
	for(var/p in MechCoreSkillPaths())
		MechKept(p)

/obj/Items/Mech/proc/MechEjectRange()
	. = glob.MECH_EJECT_RANGE
	for(var/obj/Items/P in MechPartsOfKind("Internal"))
		var/r = MechPartVar(P, "eject_range")
		if(isnum(r) && r > .) . = r

/obj/Items/Mech/proc/MechBoardRefusal(mob/M)
	if(!M) return "Nobody is there to board."
	var/intrinsic_refusal = IntrinsicPilotRefusal(M)
	if(intrinsic_refusal) return intrinsic_refusal
	if(!isturf(loc) || mounted) return "[src] is not parked."
	if(get_dist(M, src) > 1) return "Get next to [src] first."
	if(!MechIsPilot(M)) return "You are not a registered pilot of [src]."
	if(!M.MechLicensed()) return "You need Piloting Foundations to pilot [src]."
	if(disabled) return "[src] is a wreck. A Mech Bay has to repair it first."
	if(M.mech) return "You are already piloting [M.mech]."
	if(dimensional_deploying) return "[src] is still materializing."
	if(M.KO || M.Dead) return "You can't climb in like this."
	if(M.InCombat()) return "You can't climb into a mech in the middle of a fight."
	var/obj/Items/Mech/out = MechDeployedFor(M.ckey)
	if(out && out != src) return "You already have [out] out. Capsule it first."
	return null

/obj/Items/Mech/MechBoard(mob/M)
	var/why = MechBoardRefusal(M)
	if(why)
		if(M) M << why
		return 0
	if(!MechCoreOnline())
		M << "[src]'s reactor is offline. It can only limp until a functioning core is installed."
	else if(fuel <= 0)
		M << "[src]'s tank is empty. It will limp until you refuel it."
	M << "You start climbing into [src]."
	if(!M.MechChannel(M.MechBoardDS(src), src, "boarding")) return 0
	why = MechBoardRefusal(M)
	if(why)
		M << why
		return 0
	M.MechBoardNow(src)
	return 1

mob/proc/MechHandlingPoints(obj/Items/Mech/R)
	if(!R) R = mech
	. = PilotingProwess
	if(R && R.MechHasPassive("Pilot Sync")) . *= glob.MECH_SYNC_HANDLING

mob/proc/MechBoardDS(obj/Items/Mech/R)
	return max(glob.MECH_BOARD_MIN_DS, glob.MECH_BOARD_DS - glob.MECH_BOARD_PROWESS_DS * MechHandlingPoints(R))

mob/proc/MechBoardNow(obj/Items/Mech/R)
	if(!R) return

	var/intrinsic_refusal = R.IntrinsicPilotRefusal(src)
	if(intrinsic_refusal)
		src << intrinsic_refusal
		return

	if(mech_loadout) MechLoadoutClose()
	MechBoardDrop()
	if(Grab) Grab_Release()
	R.loc = src
	R.mounted = 1
	R.MechGuardSync()
	MechDeployedSet(src, R)
	MechMount(R)

mob/proc/MechBoardDrop()
	var/dropped = 0
	if(PoweringUp)
		PoweringUp = 0
		Auraz("Remove")
		dropped = 1
	if(PowerControl > 100)
		PowerControl = 100
		dropped = 1
	var/list/on = list()
	if(ActiveBuff) on += ActiveBuff
	if(SpecialBuff) on += SpecialBuff
	if(StanceBuff) on += StanceBuff
	if(StyleBuff) on += StyleBuff
	for(var/k in SlotlessBuffs)
		var/obj/Skills/Buffs/SB = SlotlessBuffs[k]
		if(SB && !SB.AlwaysOn) on += SB
	for(var/obj/Skills/Buffs/B in on)
		if(!BuffOn(B)) continue
		B.Trigger(src, Override = 1)
		dropped = 1
	if(transActive)
		Revert()
		dropped = 1
	if(Oozaru)
		Oozaru(0)
		dropped = 1
	if(dropped) src << "You let your power go as you climb in."

mob/proc/MechMount(obj/Items/Mech/R, remount = 0)
	if(!R) return
	mech = R
	if(!pilot_look)
		pilot_look = list(icon, icon_state, pixel_x, pixel_y)
		pilot_health_stash = Health
	if(!remount) HeatClear()
	MechApplyStats()
	Health = clamp(R.Hull, 0, MaxHP())
	MechBodyLook()
	MechGrantSkills(R)
	MechPassivesOn(R)
	MechShortcutsOn(R)
	mech_limp = MechShouldLimp(R)
	mech_limp_line_at = world.time + glob.MECH_LIMP_LINE_DS
	mech_ramp = glob.MECH_RAMP_MIN
	MechDeployedSet(src, R)
	R.IntrinsicEvent("mount", src, remount)
	MechFuelStart()
	if(!remount)
		src << "You take the controls of [R]. Hull [round(Health)] of [round(MaxHP())], fuel [round(R.fuel, 0.1)] minutes."
		OMsg(src, "[src] climbs into [R].")

mob/proc/MechApplyStats()
	var/obj/Items/Mech/R = mech
	if(!R) return
	var/list/S = R.MechStats()
	StrReplace = max(0.1, S["Str"])
	EndReplace = max(0.1, S["End"])
	SpdReplace = max(0.1, S["Spd"])
	ForReplace = max(0.1, S["For"])
	OffReplace = max(0.1, S["Off"])
	DefReplace = max(0.1, S["Def"])
	VitReplace = max(0.1, S["Vit"])

mob/proc/MechClearStats()
	StrReplace = 0
	EndReplace = 0
	SpdReplace = 0
	ForReplace = 0
	OffReplace = 0
	DefReplace = 0
	VitReplace = 0

mob/proc/MechBodyLook()
	var/obj/Items/Mech/R = mech
	var/list/row = R ? R.MechRow() : null
	if(!row) return
	overlays = null
	underlays = null
	icon = row["icon"]
	icon_state = row["state"]
	pixel_x = row["offset_x"]
	pixel_y = row["offset_y"]
	color = null
	SetBodyOffset(row["offset_x"], row["offset_y"])
	BodyTrack(1)
	ApplyPixelBounds()
	ApplyHurtbox()

mob/proc/MechBodyState()
	var/obj/Items/Mech/R = mech
	var/list/row = R ? R.MechRow() : null
	if(!row) return
	if(icon_state != row["state"]) icon_state = row["state"]

mob/proc/MechRestoreLook()
	var/list/L = pilot_look
	pilot_look = null
	SetBodyOffset(0, 0)
	BodyTrack(0)
	if(islist(L) && L.len >= 4)
		icon = L[1]
		icon_state = L[2]
		pixel_x = L[3]
		pixel_y = L[4]
	AppearanceOff()
	AppearanceOn()
	ApplyPixelBounds()
	ApplyHurtbox()

mob/proc/MechGrantSkills(obj/Items/Mech/R)
	R.MechEnsureSkills()
	for(var/obj/Skills/S in R.MechKeptSkills())
		if(S.loc != src)
			AddSkill(S)
		else if(!(S in Skills))
			AddSkill(S, 1)

mob/proc/MechRevokeSkills(obj/Items/Mech/R)
	for(var/obj/Skills/S in R.MechKeptSkills())
		if(istype(S, /obj/Skills/Buffs))
			var/obj/Skills/Buffs/B = S
			if(BuffOn(B)) B.Trigger(src, Override = 1)
		if(AttackQueue == S) AttackQueue = null
		DeleteSkill(S, FALSE)
		S.loc = R

mob/proc/MechPassiveList(obj/Items/Mech/R)
	. = list()
	var/list/row = R.MechRow()
	var/list/P = row ? row["passive"] : null
	for(var/i = 1 to length(P) step 2)
		var/k = replacetext("[P[i]]", " ", "")
		.[k] += P[i + 1]
	var/list/C = MechCoatingRow(R.coating)
	for(var/i = 1 to length(C) step 3)
		.["[C[i]]"] += C[i + 1]

mob/proc/MechPassivesOn(obj/Items/Mech/R)
	if(mech_passives_applied) return
	var/list/L = MechPassiveList(R)
	mech_passives_applied = L
	if(L.len) passive_handler.increaseList(L)

mob/proc/MechPassivesOff()
	var/list/L = mech_passives_applied
	mech_passives_applied = null
	if(islist(L) && L.len) passive_handler.decreaseList(L)

mob/proc/MechDismount(wreck = 0, silent = 0)
	var/obj/Items/Mech/R = mech
	if(!R) return 0
	var/turf/T = get_turf(src)
	mech_fuel_token++
	R.Hull = wreck ? 0 : clamp(Health, 0, R.MechHullMax())
	if(active_mech_transformation_id)
		RevertMechTransformation(R)
	R.IntrinsicEvent("dismount", src, wreck)
	MechShortcutsOff(R)
	MechRevokeSkills(R)
	MechPassivesOff()
	mech = null
	mech_limp = 0
	MechClearStats()
	var/stash = pilot_health_stash
	pilot_health_stash = null
	MechRestoreLook()
	Health = min(isnum(stash) ? stash : MaxHP(), MaxHP())
	MaxHealth()
	R.mounted = 0
	if(wreck)
		R.disabled = 1
		R.Hull = 0
	R.dir = dir
	R.loc = T
	R.MechPlaced(1)
	if(!silent)
		src << "You climb out of [R] and park it."
		OMsg(src, "[src] climbs out of [R].")
	return 1

mob/proc/MechEjectTurf(turf/at, range)
	if(!at) return null
	for(var/d = 1 to max(1, range))
		var/list/ring = list()
		for(var/turf/T in range(d, at))
			if(get_dist(T, at) != d) continue
			if(T.density) continue
			var/blocked = 0
			for(var/atom/movable/A in T)
				if(A.density && A != src)
					blocked = 1
					break
			if(!blocked) ring += T
		if(ring.len) return pick(ring)
	return null

mob/Players/MechEject()
	var/obj/Items/Mech/R = mech
	if(!R) return
	var/turf/at = get_turf(src)
	var/range = R.MechEjectRange()
	mech_eject_at = world.time
	MechDismount(1, 1)
	var/turf/T = MechEjectTurf(at, range)
	if(T)
		loc = T
		step_x = 0
		step_y = 0
	src << "<b>[R] breaks apart around you and throws you clear!</b>"
	OMsg(src, "[R] is wrecked, and [src] ejects!")

/mob/Player/AI/Emplacement/MechGuard/MechGuardLook(obj/Items/Mech/R)
	if(!R) return ..()
	SetBodyOffset(R.pixel_x, R.pixel_y)
	BodyTrack(1)
	return ..()

mob/Players/MechNoWounds()
	return (mech || mech_eject_at == world.time) ? 1 : 0

mob/proc/MechShouldLimp(obj/Items/Mech/R)
	if(!R) return FALSE
	return R.fuel <= 0 || !R.MechCoreOnline()

mob/Players/Unconscious(mob/P, text)
	if(mech)
		if(Health <= 0)
			MechEject()
			if(Health > 0) return
		else
			MechDismount()
	return ..()

mob/Players/MechLoginRemount()
	var/obj/Items/Mech/R
	for(var/obj/Items/Mech/X in src)
		if(X.mounted)
			R = X
			break
	if(R)
		MechMount(R, 1)

		var/intrinsic_refusal = R.IntrinsicPilotRefusal(src)
		if(intrinsic_refusal && mech == R)
			src << intrinsic_refusal
			MechDismount(silent = 1)

		return
	if(pilot_look || mech_passives_applied || pilot_shortcuts)
		MechLostCleanup()

mob/proc/MechLostCleanup()
	MechPassivesOff()
	MechClearStats()
	var/list/strays = list()
	for(var/obj/Skills/Mech/S in src)
		strays += S
	for(var/obj/Skills/Mech/S in strays)
		DeleteSkill(S)
	if(pilot_shortcuts)
		shortcuts = pilot_shortcuts
		pilot_shortcuts = null
	var/stash = pilot_health_stash
	pilot_health_stash = null
	if(pilot_look) MechRestoreLook()
	else
		SetBodyOffset(0, 0)
		BodyTrack(0)
	if(isnum(stash)) Health = min(stash, MaxHP())
	MaxHealth()
	src << "Your mech is gone. You are back on your own feet."

mob/proc/MechDismountPress()
	if(!mech)
		src << "You are not piloting anything."
		return
	if(mech_channeling) return
	if(MechMoving())
		MechLine("dismount", "[mech] is still moving. Bring it to a stop before you climb out.")
		return
	if(InCombat())
		src << "You start climbing out of [mech]."
		if(!MechDismountChannel()) return
	MechDismount()

mob/proc/MechDismountChannel()
	mech_channeling = 1
	var/hs = Health
	var/atom/start = loc
	var/end = world.time + glob.MECH_DISMOUNT_COMBAT_DS
	. = 1
	while(world.time < end)
		sleep(MECH_CHANNEL_STEP)
		if(!mech || KO || Dead)
			. = 0
			break
		if(loc != start || MechMoving())
			src << "You moved, so you stay in your seat."
			. = 0
			break
		if(Health < hs)
			src << "The hit knocks you back into your seat."
			. = 0
			break
	mech_channeling = 0

mob/proc/MechRefuelPress()
	var/obj/Items/Mech/R = mech
	if(!R)
		src << "You are not piloting anything."
		return
	if(R.fuel >= MECH_FUEL_CAP)
		src << "[R]'s tank is full."
		return
	if(CountMaterial(src, "FuelCell") < 1)
		src << "You need a Fuel Cell in your Collection Log to refuel [R]."
		return
	ConsumeMaterial(src, "FuelCell", 1)
	R.fuel = min(MECH_FUEL_CAP, R.fuel + MECH_FUEL_PER_CELL)
	if(mech_limp && !MechShouldLimp(R))
		mech_limp = 0
		src << "[R] roars back to full power."
	else if(!R.MechCoreOnline())
		src << "[R] has fuel, but its reactor remains offline."
	src << "You feed a Fuel Cell into [R]. Fuel: [round(R.fuel, 0.1)] of [MECH_FUEL_CAP] minutes."

mob/proc/MechFuelStart()
	set waitfor = 0
	var/token = ++mech_fuel_token
	var/obj/Items/Mech/R = mech
	var/last = world.time
	mech_mend_at = world.time + glob.MECH_MEND_DS
	while(R && mech == R && mech_fuel_token == token)
		sleep(glob.MECH_FUEL_POLL)
		if(!R || mech != R || mech_fuel_token != token) return
		var/dt = world.time - last
		last = world.time
		MechFuelTick(R, dt)

mob/proc/MechFuelTick(obj/Items/Mech/R, dt)
	if(!R || mech != R) return

	var/intrinsic_refusal = R.IntrinsicPilotRefusal(src)
	if(intrinsic_refusal)
		src << intrinsic_refusal
		MechDismount(silent = 1)
		return

	R.IntrinsicEvent("tick", src, dt)
	var/core_online = R.MechCoreOnline()
	if(R.fuel > 0 && core_online)
		var/used = R.IntrinsicNumber("fuel", src, dt / glob.MECH_FUEL_BURN_DS)
		R.fuel = max(0, R.fuel - used)
	var/should_limp = MechShouldLimp(R)
	if(should_limp && !mech_limp)
		mech_limp = 1
		mech_limp_line_at = world.time + glob.MECH_LIMP_LINE_DS

		if(!core_online)
			src << "[R]'s reactor goes offline. It can only limp until a functioning core is installed."
		else
			src << "[R] is out of fuel. It limps along until you refuel it."
	else if(!should_limp && mech_limp)
		mech_limp = 0
		src << "[R] returns to full operating power."
	else if(mech_limp && world.time >= mech_limp_line_at)
		mech_limp_line_at = world.time + glob.MECH_LIMP_LINE_DS

		if(!core_online)
			src << "[R]'s reactor remains offline and the mech is limping."
		else
			src << "[R] is still out of fuel and limping."

	if(passive_handler.Get("MechHullMend") && world.time >= mech_mend_at)
		mech_mend_at = world.time + glob.MECH_MEND_DS
		if(!InCombat() && Health < MaxHP())
			Health = min(MaxHP(), Health + PctToHP(glob.MECH_MEND_PCT * passive_handler.Get("MechHullMend")))
	R.Hull = clamp(Health, 0, R.MechHullMax())
	MechBodyState()

mob/proc/MechLimp()
	return mech && mech_limp

/strikeHook/mechPilotXP
	stage = "post"
	fire(strike/S)
		var/mob/A = S.attacker
		var/mob/D = S.defender
		if(!A || !D || A == D || S.dealt <= 0) return
		var/pct = D.HPToPct(S.dealt)
		if(A.mech && MechXPWorthy(D)) A.PilotXPGain(pct)
		if(D.mech && MechXPWorthy(A)) D.PilotXPGain(pct)

proc/MechXPWorthy(mob/M)
	if(istype(M, /mob/Players)) return 1
	if(istype(M, /mob/Player/AI))
		var/mob/Player/AI/AI = M
		return AI.ai_owner ? 1 : 0
	return 0

mob/proc/PilotXPGain(n)
	if(!isnum(n) || n <= 0) return
	PilotXP += n
	PilotProwessRefresh()

mob/proc/PilotProwessRefresh()
	var/lv = 1
	for(var/t in glob.MECH_PROWESS_XP)
		if(PilotXP >= t) lv++
	if(lv > PilotingProwess)
		PilotingProwess = lv
		src << "<b>Your piloting sharpens. Piloting Prowess is now [PilotingProwess].</b>"
