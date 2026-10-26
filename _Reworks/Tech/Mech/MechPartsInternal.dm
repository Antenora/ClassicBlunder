mob/var/tmp
	mech_charge_at = 0
	obj/Items/Gun/mech_charge_gun
	mech_charge_fired_at = -100
	mech_charge_dmg = 0
	mech_charge_size = 0
	mech_charge_heat = 0

client/var/tmp/list/mech_scan_rows

/obj/Items/Mech/var/tmp/mech_mend_token = 0

/obj/Items/MechPart
	var/dissipation_flat = 0
	var/tmp/list/mech_passives

/obj/Items/MechPart/Internal
	mech_slot = "Internal"
	var/eject_range = 0
	var/pilot_heat_mult = 0
	var/pilot_dmg_mult = 0
	var/range_bonus = 0
	var/sensor_reveal = 0
	var/hull_pct = 0
	var/spd_mult = 0
	var/limit_drive = 0

	Charge_Capacitor
		name = "Charge Capacitor"
		desc = "A capacitor bank for a mech's Internal slot. Hold the fire button to charge your ranged arm part and release to shoot: over 2 seconds the shot grows to 3x damage and 2.5x size, and its heat to 5x the gun's own."
		heat_cost = 12
		var/charge_cap_ds = 20
		var/charge_dmg_max = 3
		var/charge_size_max = 2.5
		var/charge_heat_max = 5

	Cooling_System
		name = "Cooling System"
		desc = "A coolant loop for a mech's Internal slot. The mech sheds 4 more heat every second. Two stack."
		dissipation_flat = 4

	Emergency_Coolant
		name = "Emergency Coolant"
		desc = "A coolant flood for a mech's Internal slot. Grants Emergency Coolant: dump 50 heat at once, even while overheated. 3 charges, refilled whenever a Mech Bay services the mech."
		Techniques = list(/obj/Skills/Mech/Emergency_Coolant)
		var/coolant_max = 3
		var/coolant_charges = 3
		var/coolant_drop = 50

	Targeting_FCS
		name = "Targeting FCS"
		desc = "A fire control system for a mech's Internal slot. Mech guns and Back weapons gain 0.15 accuracy and 1 tile of range, and missiles lock on sooner."
		range_bonus = 1
		mech_passives = list("MechAccuracy" = 0.15, "MechHomingUp" = 1)

	Sensor_Package
		name = "Sensor Package"
		desc = "A sensor suite for a mech's Internal slot. Cloaked foes within 6 tiles are revealed, and your target card shows a mech target's Hull and heat."
		sensor_reveal = 6

	Reactive_Armor
		name = "Reactive Armor"
		desc = "Explosive plating for a mech's Internal slot. Hull 15 percent higher, speed 5 percent lower."
		hull_pct = 15
		spd_mult = 0.95

	Ejection_Booster
		name = "Ejection Booster"
		desc = "A rocket seat for a mech's Internal slot. When the mech is wrecked, you land 5 tiles clear."
		eject_range = 5

	Auto_Repair_Nanites
		name = "Auto-Repair Nanites"
		desc = "A nanite hive for a mech's Internal slot. Out of combat the Hull mends 2 percent every 10 seconds, piloted or parked."
		part_tier = MECH_TIER_WALKER
		mech_passives = list("MechHullMend" = 2)

	Finger_Amplifier
		name = "Finger Amplifier"
		desc = "A motion-trace amplifier for a mech's Internal slot. Mech-compatible pilot skills deal 20 percent more damage and cost 20 percent less heat."
		part_tier = MECH_TIER_WALKER
		pilot_heat_mult = 0.8
		pilot_dmg_mult = 1.2

/obj/Skills/Mech/Emergency_Coolant
	name = "Emergency Coolant"
	desc = "Flood the mech with coolant: 50 heat gone at once, even while overheated. Each Emergency Coolant holds 3 charges; a Mech Bay refills them."
	Cooldown = 2
	NoGCD = 1
	verb/Emergency_Coolant()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		return p.MechCoolantFire(src, noGCD)

/obj/Items/Mech/proc/MechInternals()
	return MechPartsOfKind("Internal")

/obj/Items/Mech/proc/MechCoolantLeft()
	. = 0
	for(var/obj/Items/MechPart/Internal/Emergency_Coolant/C in MechInternals())
		. += max(0, C.coolant_charges)

/obj/Items/Mech/proc/MechCoolantRefill()
	for(var/obj/Items/MechPart/Internal/Emergency_Coolant/C in MechInternals())
		C.coolant_charges = C.coolant_max

/obj/Items/Mech/proc/MechMendPct()
	. = 0
	for(var/obj/Items/MechPart/P in MechFittedParts())
		if(P.mech_passives) . += P.mech_passives["MechHullMend"] * glob.MECH_MEND_PCT

/obj/Items/Mech/proc/MechParkedMendStart()
	set waitfor = 0
	var/token = ++mech_mend_token
	if(MechMendPct() <= 0) return
	while(src && token == mech_mend_token)
		sleep(glob.MECH_MEND_DS)
		if(!src || token != mech_mend_token) return
		if(!isturf(loc) || mounted || disabled) return
		var/p = MechMendPct()
		if(p <= 0) return
		var/mob/G = mech_guard
		if(G && G.InCombat()) continue
		var/mx = MechHullMax()
		if(Hull >= mx) continue
		Hull = min(mx, Hull + mx * p / 100)
		MechGuardPush()

/obj/Items/Mech/MechPlaced(stamp = 1)
	..()
	if(isturf(loc) && !mounted) MechParkedMendStart()

/obj/Items/Mech/MechRefitDone(before)
	..()
	if(isturf(loc) && !mounted) MechParkedMendStart()

/obj/Items/Mech/MechStatMods(list/S)
	..()
	var/spd = 1
	for(var/obj/Items/MechPart/Internal/P in MechInternals())
		if(P.spd_mult > 0) spd *= P.spd_mult
	if(spd != 1) S["Spd"] *= spd

/obj/LifeSkills/Station/MechBay/MechBayPickRecord(mob/M)
	. = ..()
	var/obj/Items/Mech/R = .
	if(istype(R)) R.MechCoolantRefill()

mob/proc/MechCapacitor()
	if(!mech) return null
	for(var/obj/Items/MechPart/Internal/Charge_Capacitor/C in mech.MechInternals())
		return C
	return null

mob/proc/MechRangeBonus()
	. = 0
	if(!mech) return
	for(var/obj/Items/MechPart/Internal/P in mech.MechInternals())
		. += P.range_bonus

mob/proc/MechSensorReach()
	. = MechSensorRange()
	if(!mech) return
	for(var/obj/Items/MechPart/Internal/P in mech.MechInternals())
		if(P.sensor_reveal > .) . = P.sensor_reveal

mob/proc/MechHasSensorPackage()
	if(!mech) return 0
	for(var/obj/Items/MechPart/Internal/P in mech.MechInternals())
		if(P.sensor_reveal > 0) return 1
	return 0

mob/proc/MechCoolantFire(obj/Skills/S, noGCD = FALSE)
	if(!mech)
		src << "[S] only works from inside a mech."
		return 0
	var/obj/Items/MechPart/Internal/Emergency_Coolant/C
	for(var/obj/Items/MechPart/Internal/Emergency_Coolant/X in mech.MechInternals())
		if(X.coolant_charges > 0)
			C = X
			break
	if(!C)
		MechLine("coolant", "[mech]'s coolant tanks are empty. A Mech Bay refills them.")
		return 0
	if(!MechSkillGo(S, TRUE)) return 0
	C.coolant_charges--
	S.Cooldown(1, null, src)
	HeatDrop(C.coolant_drop)
	src << "Coolant floods [mech]. [mech.MechCoolantLeft()] charges left."
	return 1

mob/Players/MechPassiveList(obj/Items/Mech/R)
	. = ..()
	if(!R) return
	for(var/obj/Items/MechPart/P in R.MechFittedParts())
		for(var/k in P.mech_passives)
			.[k] += P.mech_passives[k]

mob/Players/MechDissipationFlat()
	. = ..()
	if(!mech) return
	for(var/obj/Items/MechPart/P in mech.MechFittedParts())
		. += P.dissipation_flat

mob/Players/MechBackWeaponReach()
	return ..() + MechRangeBonus()

mob/Players/MechDealtMult(mob/defender, strike/S)
	. = ..()
	if(!. || !mech || !MechPilotStrike(S)) return
	for(var/obj/Items/MechPart/Internal/P in mech.MechInternals())
		if(P.pilot_dmg_mult > 0) . *= P.pilot_dmg_mult

mob/Players/MechFuelTick(obj/Items/Mech/R, dt)
	..()
	var/r = MechSensorReach()
	if(r > 0 && mech == R) RevealCloaked(r)

mob/Players/GunChargeStart(atom/object, atom/location, params)
	if(!mech || !MechCapacitor()) return ..()
	var/obj/Items/Gun/G = MechActiveGun()
	if(!G || Overheated() || MechStalled()) return ..()
	mech_charge_at = world.time
	mech_charge_gun = G
	return 1

mob/Players/GunChargeRelease(atom/object, atom/location, params)
	if(!mech_charge_gun) return ..()
	var/obj/Items/Gun/G = mech_charge_gun
	mech_charge_gun = null
	mech_charge_fired_at = world.time
	var/obj/Items/MechPart/Internal/Charge_Capacitor/C = MechCapacitor()
	if(!mech || !C || MechActiveGun() != G) return 1
	GunAimAtClick(object, location, params)
	GunFaceAim()
	MechChargedShot(G, C, world.time - mech_charge_at)
	return 1

mob/proc/MechChargedShot(obj/Items/Gun/G, obj/Items/MechPart/Internal/Charge_Capacitor/C, held)
	if(!G || !C) return 0
	var/f = clamp(held / max(1, C.charge_cap_ds), 0, 1)
	mech_charge_dmg = 1 + (C.charge_dmg_max - 1) * f
	mech_charge_size = 1 + (C.charge_size_max - 1) * f
	mech_charge_heat = 1 + (C.charge_heat_max - 1) * f
	. = FireGun(G)
	mech_charge_dmg = 0
	mech_charge_size = 0
	mech_charge_heat = 0

mob/Players/GunClickFire(atom/object, atom/location, params)
	if(mech && (mech_charge_gun || world.time - mech_charge_fired_at <= world.tick_lag))
		GunAimAtClick(object, location, params)
		return
	return ..()

mob/Players/GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	..()
	if(!mech || !S || !g || !g.mech_only) return
	if(mech_charge_dmg) S.DamageMult *= mech_charge_dmg
	if(mech_charge_size) S.IconSize *= mech_charge_size
	var/r = MechRangeBonus()
	if(r) S.Distance += r

mob/Players/GunChargedShot(obj/Items/Gun/g)
	if(!mech || !g || !g.mech_only) return ..()
	var/h = g.heat_per_shot
	var/m = MechHeatCostMult() * (mech_charge_heat ? mech_charge_heat : 1)
	if(m != 1) g.heat_per_shot = h * m
	..()
	g.heat_per_shot = h

client/ScannerCardRows(mob/T)
	..()
	MechScanRows(T)

client/ScannerCardReset()
	..()
	for(var/atom/movable/o in mech_scan_rows)
		screen -= o
		del o
	mech_scan_rows = null

client/proc/MechScanRowsHide()
	for(var/atom/movable/shud/cardtext/r in mech_scan_rows)
		r.alpha = 0
		r.maptext = ""

client/proc/MechScanRows(mob/T)
	var/mob/M = mob
	if(!T || !M || !tcard || !T.mech || !M.MechHasSensorPackage())
		MechScanRowsHide()
		return
	if(!mech_scan_rows)
		mech_scan_rows = list()
		for(var/i = 1 to 2)
			var/atom/movable/shud/cardtext/r = new
			r.layer = MCARD_LAYER + 0.5
			r.maptext_x = SCAN_ROW_X
			r.maptext_width = SCAN_ROW_W
			r.maptext_height = SCAN_ROW_H
			r.alpha = 0
			mech_scan_rows += r
			screen += r
	var/top = -SCAN_ROW_GAP
	for(var/atom/movable/shud/cardtext/s in scan_rows)
		if(s.alpha > 0) top -= s.maptext_height - SCAN_ROW_H + SCAN_ROW_STEP
	var/list/texts = list(ScannerRowText("HULL [round(T.Health)] / [round(T.MaxHP())]"), ScannerRowText("HEAT [round(T.HeatNow())] / [round(T.HeatMax())]"))
	for(var/i = 1 to mech_scan_rows.len)
		var/atom/movable/shud/cardtext/r = mech_scan_rows[i]
		r.screen_loc = TargetChildLoc(0, top - SCAN_ROW_H)
		if(r.maptext != texts[i]) r.maptext = texts[i]
		r.alpha = 255
		top -= SCAN_ROW_STEP
