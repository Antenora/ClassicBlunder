globalTracker/var
	MECH_RIDER_BURN = 6
	MECH_RIDER_BLEED = 3
	MECH_RIDER_SHATTER = 3
	MECH_RIDER_SHOCK = 6
	MECH_RIDER_CHILL = 6
	MECH_RIDER_WATER = 6
	MECH_RIDER_POISON = 3
	MECH_PART_QSTEP = 0.1
	MECH_SHIELD_UP_MULT = 0.5
	MECH_SPLASH_MULT = 0.6
	MECH_BOAR_KB = 1
	MECH_HOMING_STEP = 1
	MECH_LINE_GAP = 10
	MECH_ROCKET_RETURN_PAD = 2

var/list/MECH_RIDER_COATINGS = list("MechRiderBurn" = "Burn", "MechRiderChill" = "Chill", "MechRiderWater" = "Water", "MechRiderShock" = "Shock", "MechRiderPoison" = "Poison")

/obj/Items/Gun/var
	hands = 1
	paired = 0
	heat_cost = 0
	part_tier = 0
	shot_state
	shot_speed_mult = 1
	shot_splash = 0
	tmp/shot_icon

/obj/Skills/var
	mech_heat = 0
	mech_ranged = 0
	mech_from_part = 0
	tmp/mech_dmg = 0
	tmp/mech_heat_scale = 1
	tmp/mech_fire_heat = 1

mob/var/tmp
	mech_gun_hand = 0
	mech_swing_at = -1
	mech_shield_up = 0
	mech_line_at = 0
	mech_line_what
	mech_dash_until = 0
	obj/Items/mech_struck_part

proc/MechPartQuality(obj/Items/P)
	if(!P) return 1
	if(istype(P, /obj/Items/Gun))
		var/obj/Items/Gun/G = P
		return (G.DamageEffectiveness ? G.DamageEffectiveness : 1) / max(G.ModelDamage, 0.01)
	var/f = LIFE_GEARQ_SCALE[QualityClamp(P.CraftQuality)]
	. = 1 + glob.MECH_PART_QSTEP * (f - 1)
	if(P.metal_id)
		var/list/t = GunMetalTraits(P.metal_id)
		. *= 1 + (t[1] - 1) * f
	if(P.CraftQuality == QUAL_LEGENDARY) . *= LIFE_LEG_AUGMENT

proc/MechPartCraftName(obj/Items/I, mid)
	var/q = (I.CraftQuality == QUAL_NORMAL) ? "" : "[QualityName(I.CraftQuality)] "
	var/m = mid ? "[LIFE_METAL_NAME[mid]] " : ""
	return "[q][m][initial(I.name)]"

proc/MechSkillPath(p)
	var/t = ispath(p) ? p : text2path("[p]")
	return ispath(t, /obj/Skills) ? t : null

proc/MechSkillFired(obj/Skills/S, was_using, was_charges)
	if(!S) return 0
	if(S.MaxCharges > 0) return (S.Charges < was_charges) ? 1 : 0
	return (!was_using && S.Using) ? 1 : 0

/obj/Items/Mech/proc/MechPartTechniques(obj/Items/P)
	var/list/out = list()
	if(!P) return out
	for(var/path in P.Techniques)
		var/t = MechSkillPath(path)
		if(t && !(t in out))
			out += t

	if(!P.IsIntrinsicPart() || !IntrinsicPartActive(P))
		return out

	RegisterMechIntrinsicParts()

	var/list/record = intrinsic_installed[P.intrinsic_record_key]
	if(!islist(record)) return out
	var/datum/mech_intrinsic_part/D = MechIntrinsicParts[record["part_id"]]
	if(!D) return out
	var/list/state = record["state"]
	if(!islist(state))
		state = list()
		record["state"] = state

	var/mob/Owner
	for(var/mob/M in world)
		if(M.intrinsic_character_id == record["owner_id"])
			Owner = M
			break

	if(Owner)
		var/list/extra = D.ExtraSkillPaths(Owner, src, state)
		var/list/cached = list()

		if(islist(extra))
			for(var/path in extra)
				var/t = MechSkillPath(path)
				if(t && !(t in cached))
					cached += t
		state["extra_skill_paths"] = cached

	var/list/extra = state["extra_skill_paths"]
	if(islist(extra))
		for(var/path in extra)
			var/t = MechSkillPath(path)
			if(t && !(t in out))
				out += t

	return out


/obj/Items/MechPart
	name = "Mech Part"
	desc = "A mech part. A Mech Bay fits it into a parked mech."
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "Modular"
	var/hands = 1
	var/paired = 0
	var/heat_cost = 0
	var/part_tier = MECH_TIER_LIGHT

/obj/Items/MechPart/Arm
	mech_slot = "Arm"
	var/melee_mult
	var/melee_delay = 1
	var/melee_rider
	var/melee_rider_n = 0
	var/melee_pierce = 0
	var/melee_kb = 0

	Heat_Hawk
		name = "Heat Hawk"
		desc = "A superheated axe for a mech's arm. It turns the Normal Attack into heavy, slow swings (1.3x damage, 1.2x attack delay) that set the target burning. 5 heat per swing. One hand."
		heat_cost = 5
		melee_mult = 1.3
		melee_delay = 1.2
		melee_rider = "Burn"

	Beam_Saber
		name = "Beam Saber"
		desc = "An energy blade for a mech's arm. It turns the Normal Attack into fast swings (0.8x attack delay) that cut through a quarter of the target's armor. 3 heat per swing. One hand."
		energy_heat_source = TRUE
		heat_cost = 3
		melee_mult = 1
		melee_delay = 0.8
		melee_pierce = 0.25

	Progressive_Knife
		name = "Progressive Knife"
		desc = "A vibrating combat knife for a mech's arm. It turns the Normal Attack into quick stabs (0.9x damage, 0.9x attack delay) that bleed the target and ignore a quarter of its armor. 3 heat per swing. One hand."
		heat_cost = 3
		melee_mult = 0.9
		melee_delay = 0.9
		melee_rider = "Bleed"
		melee_pierce = 0.25

	Power_Fist
		name = "Power Fist"
		icon = 'Icons/Technology/Gear/PowerFist.dmi'
		icon_state = ""
		desc = "A piston-driven fist for a mech's arm. It turns the Normal Attack into slow, crushing punches (1.6x damage, 1.5x attack delay) that knock the target back. 6 heat per swing. One hand."
		heat_cost = 6
		melee_mult = 1.6
		melee_delay = 1.5
		melee_kb = 2

	Heat_Rod
		name = "Heat Rod"
		desc = "An electrified whip for a mech's arm. Grants Heat Rod: a 4 tile lash that shocks the target and drags it to your feet, mechs included. 8 heat. One hand."
		heat_cost = 8
		Techniques = list(/obj/Skills/AutoHit/Mech/Heat_Rod)

	Claw_Arm
		name = "Claw Arm"
		icon = 'Icons/Technology/Gear/PowerClaw.dmi'
		icon_state = ""
		desc = "A hydraulic claw for a mech's arm. Grants Claw Arm: a grapple strong enough to lift another mech, then slam it away. 10 heat. One hand."
		heat_cost = 10
		Techniques = list(/obj/Skills/Grapple/Mech/Claw_Arm)

	Chainsaw_Blade
		name = "Chainsaw Blade"
		icon = 'Icons/Technology/Gear/Chainsaw.dmi'
		icon_state = ""
		desc = "A mech-sized chainsaw. Grants Chainsaw Blade: your next Normal Attack grinds five times and bleeds the target. 2 heat per hit. One hand."
		heat_cost = 2
		Techniques = list(/obj/Skills/Queue/Mech/Chainsaw_Blade)

	Mech_Shield
		name = "Mech Shield"
		desc = "A heavy shield for a mech's arm. Grants Mech Shield: hold its key to raise it. While raised, hits from the front deal half damage and shots from the front are stopped, and your other hand keeps fighting. No heat. One hand."
		Techniques = list(/obj/Skills/AutoHit/Mech/Mech_Shield)

	Rocket_Punch
		name = "Rocket Punch"
		icon = 'Icons/Technology/Gear/ImpactGloves.dmi'
		icon_state = ""
		desc = "A detachable rocket fist for a mech's arm. Grants Rocket Punch: the fist flies out, knocks back what it hits, and flies home. 10 heat. One hand."
		heat_cost = 10
		Techniques = list(/obj/Skills/Projectile/Mech/Rocket_Punch)

	Pile_Bunker
		name = "Pile Bunker"
		icon = 'Icons/Technology/Gear/PileBunker.dmi'
		icon_state = ""
		desc = "A mech-sized pile driver. Grants Pile Bunker: hold its key to charge, release to drive one huge stab (up to 4x) that shatters armor, then recover for 2 seconds. 25 heat. One hand."
		part_tier = MECH_TIER_WALKER
		heat_cost = 25
		Techniques = list(/obj/Skills/AutoHit/Mech/Pile_Bunker)

	Drill_Arm
		name = "Drill Arm"
		icon_state = "HandDrill"
		desc = "A spiral drill for a mech's arm. Grants Drill Arm: a 4 tile drilling rush that grinds whatever it hits. 15 heat. One hand."
		part_tier = MECH_TIER_WALKER
		heat_cost = 15
		Techniques = list(/obj/Skills/AutoHit/Mech/Drill_Arm)

	Giga_Drill
		name = "Giga Drill"
		icon_state = "HandDrill"
		desc = "A drill so large it takes both arms. Grants Giga Drill: the Drill Arm's rush at twice the damage. 20 heat. Two hands."
		part_tier = MECH_TIER_WALKER
		hands = 2
		heat_cost = 20
		Techniques = list(/obj/Skills/AutoHit/Mech/Giga_Drill)

/obj/Items/MechPart/Back
	mech_slot = "Back"

obj/Items/Gun/Handgun/Beam_Rifle
	name = "Beam Rifle"
	desc = "A mech-scale energy rifle for a mech's arm. One hard beam per click, 12 heat a shot. Energy beams punch through part of a target's armor and cannot be deflected. One hand."
	Class = "Heavy"
	icon_state = "Photon Rifle"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	mech_slot = "Arm"
	part_tier = MECH_TIER_LIGHT
	energy_gun = 1
	heat_per_shot = GUN_HANDGUN_HEAT
	heat_cost = GUN_HANDGUN_HEAT
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.5
	ModelAccuracy = 1.05
	ModelSpeed = 1
	LegendNames = list("Legendary Beam Rifle")

obj/Items/Gun/Automatic/Beam_Machine_Gun
	name = "Beam Machine Gun"
	desc = "A mech-scale energy repeater for a mech's arm. Hold the mouse to stream beams, 3.5 heat a round. Energy beams punch through part of a target's armor and cannot be deflected. One hand."
	Class = "Heavy"
	icon_state = "Photon Repeaters"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	mech_slot = "Arm"
	part_tier = MECH_TIER_LIGHT
	energy_gun = 1
	heat_per_shot = GUN_AUTOMATIC_HEAT
	heat_cost = GUN_AUTOMATIC_HEAT
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.2
	ModelAccuracy = 1
	ModelSpeed = 1
	LegendNames = list("Legendary Beam Machine Gun")

obj/Items/Gun/Shotgun/Scatter_Beam_Gun
	name = "Scatter Beam Gun"
	desc = "A mech-scale energy scattergun for a mech's arm. Each click throws a spread of beams, 18 heat a shot. Energy beams punch through part of a target's armor and cannot be deflected. One hand."
	Class = "Heavy"
	icon_state = "Plasma Cannon"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	mech_slot = "Arm"
	part_tier = MECH_TIER_LIGHT
	energy_gun = 1
	heat_per_shot = GUN_SHOTGUN_HEAT
	heat_cost = GUN_SHOTGUN_HEAT
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 10
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.2
	ModelAccuracy = 1
	ModelSpeed = 1
	LegendNames = list("Legendary Scatter Beam Gun")

obj/Items/Gun/Automatic/Gatling_Arm
	name = "Gatling Arm"
	desc = "A rotary cannon for a mech's arm. Hold the mouse to stream shells at 1.4x the rate of a normal automatic, 3 heat a round. No magazine: it runs on heat. One hand."
	Class = "Heavy"
	icon_state = "SMG"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	mech_slot = "Arm"
	part_tier = MECH_TIER_LIGHT
	heat_per_shot = 3
	heat_cost = 3
	BulletIcon = 'Icons/Blasts/BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1
	ModelAccuracy = 1
	ModelSpeed = 1.4
	LegendNames = list("Legendary Gatling Arm")

obj/Items/Gun/Handgun/Hyper_Bazooka
	name = "Hyper Bazooka"
	desc = "A mech-scale rocket launcher for a mech's arm. Each click fires a slow rocket that bursts on impact and splashes everything within a tile, 20 heat a shot. No magazine: it runs on heat. One hand."
	Class = "Heavy"
	icon_state = "Rocket Launcher"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	mech_slot = "Arm"
	part_tier = MECH_TIER_LIGHT
	heat_per_shot = 20
	heat_cost = 20
	BulletIcon = MECH_ICON_SHOTS
	shot_state = "Shot5"
	shot_speed_mult = 1.667
	shot_splash = 1
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 2.5
	ModelAccuracy = 0.95
	ModelSpeed = 0.6
	LegendNames = list("Legendary Hyper Bazooka")

obj/Items/Gun/Handgun/Beam_Magnum
	name = "Beam Magnum"
	desc = "A mech-scale energy magnum for a mech's arm. One devastating beam per click (4x a Beam Rifle's base), 60 heat a shot. Energy beams punch through part of a target's armor and cannot be deflected. One hand."
	Class = "Heavy"
	icon_state = "Phaser"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	mech_slot = "Arm"
	part_tier = MECH_TIER_WALKER
	energy_gun = 1
	heat_per_shot = 60
	heat_cost = 60
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 4
	ModelAccuracy = 1.05
	ModelSpeed = 1
	LegendNames = list("Legendary Beam Magnum")

obj/Items/Gun/Handgun/Twin_Buster_Rifle
	name = "Twin Buster Rifle"
	desc = "A paired beam rifle that takes both of a mech's arms. A click fires a normal beam (12 heat). Grants Twin Buster: hold its key to charge, release to pour a giant beam that fills the heat gauge. Two hands."
	Class = "Heavy"
	icon_state = "Photon Rifle"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	mech_slot = "Arm"
	part_tier = MECH_TIER_WALKER
	hands = 2
	energy_gun = 1
	heat_per_shot = GUN_HANDGUN_HEAT
	heat_cost = 100
	Techniques = list(/obj/Skills/Projectile/Beams/Mech/Twin_Buster)
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 1.5
	ModelAccuracy = 1.05
	ModelSpeed = 1
	LegendNames = list("Legendary Twin Buster Rifle")

/obj/Items/Mech/proc/MechFittedParts()
	. = list()
	for(var/s in parts)
		var/obj/Items/P = MechPartIn(s)
		if(P && !(P in .)) . += P

/obj/Items/Mech/proc/MechPartSkillPaths()
	. = list()
	for(var/obj/Items/P in MechFittedParts())
		for(var/path in MechPartTechniques(P))
			if(!(path in .))
				. += path

/obj/Items/Mech/proc/MechPartsGranting(path)
	. = list()
	for(var/obj/Items/P in MechFittedParts())
		var/list/techniques = MechPartTechniques(P)
		if(path in techniques)
			. += P

/obj/Items/Mech/proc/MechShortcutDrop(obj/Skills/S)
	if(!shortcuts || !S) return
	for(var/i = 1 to HOTBAR_SLOTS)
		if(shortcuts.vars["shortcut[i]"] == S) shortcuts.vars["shortcut[i]"] = null

/obj/Items/Mech/proc/MechPrunePartSkills()
	if(!part_kept) return
	var/list/want = MechPartSkillPaths()
	for(var/k in part_kept.Copy())
		var/obj/Skills/S = part_kept[k]
		if(!S || !S.mech_from_part || (k in want)) continue
		part_kept -= k
		MechShortcutDrop(S)
		if(ismob(S.loc))
			var/mob/M = S.loc
			M.DeleteSkill(S)
		else
			del S

/obj/Items/Mech/proc/MechSyncPartSkills()
	if(!part_kept) return
	for(var/p in MechPartSkillPaths())
		var/obj/Skills/S = part_kept[p]
		if(!S) continue
		S.mech_from_part = 1
		S.MechPartSync(src, MechPartsGranting(p))

/obj/Items/Mech/MechCoreSkillPaths()
	var/list/L = ..()
	. = list()
	for(var/p in L)
		var/t = MechSkillPath(p)
		if(t && !(t in .)) . += t
	for(var/p in MechPartSkillPaths())
		if(!(p in .)) . += p

/obj/Items/Mech/MechEnsureSkills()
	MechPrunePartSkills()
	..()
	MechSyncPartSkills()

/obj/Skills/proc/MechInitDamage()
	return 0

/obj/Skills/proc/MechBaseDamage()
	return mech_dmg ? mech_dmg : MechInitDamage()

/obj/Skills/proc/MechPartSync(obj/Items/Mech/R, list/granting)
	var/obj/Items/P = length(granting) ? granting[1] : null
	mech_dmg = MechInitDamage() * MechPartQuality(P)
	if("DamageMult" in vars) vars["DamageMult"] = mech_dmg
	var/n = length(granting)
	var/merged = (P && P.mech_slot == "Back" && R && R.MechHasPassive("Fire Control")) ? 1 : 0
	if(n > 1 && !merged)
		if(MaxCharges != n)
			MaxCharges = n
			Charges = n
			Using = 0
		ChargeRefresh = Cooldown
	else if(MaxCharges)
		MaxCharges = 0
		Charges = 0
		ChargeRefresh = 0
		if(!cooldown_remaining) Using = 0

/obj/Skills/proc/MechFire(mob/p, noGCD = FALSE)
	return 0

/obj/Skills/proc/MechAfterFire(mob/p)
	return

/obj/Skills/proc/MechReleaseFire(mob/p, benefit)
	return 0

/obj/Skills/proc/MechImpact(mob/p, obj/Skills/Projectile/_Projectile/P)
	return

/obj/Skills/proc/MechBarrageFire(mob/p, scale)
	return p.MechPartUse(src, TRUE, scale)

mob/proc/MechPartHeatMult(obj/Skills/S)
	return 1

mob/proc/MechHomingBonus()
	return passive_handler.Get("MechHomingUp") * glob.MECH_HOMING_STEP

mob/proc/MechLine(what, text)
	if(what == mech_line_what && world.time < mech_line_at) return
	mech_line_what = what
	mech_line_at = world.time + glob.MECH_LINE_GAP
	src << text

mob/proc/MechStallLine()
	MechLine("stall", "[mech ? mech.name : "Your mech"]'s weapon systems are stalled.")

mob/proc/MechPartOnBoard(obj/Skills/S)
	if(mech || !istype(src, /mob/Players)) return 1
	MechLine("board", "[S] only works from inside a mech.")
	return 0

mob/proc/MechRangedReady()
	if(Overheated())
		if(mech) MechTooHot()
		return 0
	if(MechStalled())
		MechStallLine()
		return 0
	return 1

mob/proc/MechSkillGo(obj/Skills/S, noGCD = FALSE)
	if(!S || S.Using || S.cooldown_remaining) return 0
	if(world.time < mech_dash_until) return 0
	if(HeldSkillBlocksAction(S)) return 0
	if(!noGCD && GCDBlocked(S)) return 0
	if(!CanAttack(3)) return 0
	return 1

mob/proc/MechSkillHeat(obj/Skills/S, scale = 1)
	if(!S) return
	var/h = S.mech_heat * scale * S.mech_fire_heat * MechPartHeatMult(S)
	if(h > 0) HeatAdd(IntrinsicHeatCost(h, S))


mob/proc/MechPartUse(obj/Skills/S, noGCD = FALSE, heat_scale = 1)
	if(!S || !MechPartOnBoard(S)) return 0
	if(S.mech_ranged && !MechRangedReady()) return 0
	var/was_using = S.Using
	var/was_charges = S.Charges
	var/obj/Items/Mech/intrinsic_using_mech = mech
	S.mech_heat_scale = heat_scale
	S.mech_fire_heat = 1
	. = S.MechFire(src, noGCD)
	if(MechSkillFired(S, was_using, was_charges))
		MechSkillHeat(S, heat_scale)
		S.MechAfterFire(src)
		if(intrinsic_using_mech && mech == intrinsic_using_mech && !S.HeldSkill) IntrinsicSkillUsed(S)
	S.mech_heat_scale = 1

mob/proc/MechHeldStart(obj/Skills/S)
	if(!S || !MechPartOnBoard(S)) return 0
	if(S.mech_ranged && !MechRangedReady()) return 0
	return BeginHeldSkill(S)

mob/proc/MechHeldRelease(obj/Skills/S, benefit)
	if(!S) return 0
	if(S.mech_ranged && !MechRangedReady()) return 0
	var/was_using = S.Using
	var/was_charges = S.Charges
	S.mech_fire_heat = 1
	var/obj/Items/Mech/intrinsic_using_mech = mech
	. = S.MechReleaseFire(src, benefit)
	if(MechSkillFired(S, was_using, was_charges))
		MechSkillHeat(S, S.mech_heat_scale)
		S.MechAfterFire(src)
		if(intrinsic_using_mech && mech == intrinsic_using_mech) IntrinsicSkillUsed(S)
	S.mech_heat_scale = 1

mob/proc/MechDash(d, tiles, ticks)
	if(!mech || !d || tiles <= 0) return 0
	ticks = max(1, round(ticks))
	mech_dash_until = world.time + ticks * world.tick_lag
	dir = d
	return MechImpulse(d, 32 * tiles / ticks, ticks)

mob/proc/MechAimSkill(obj/Skills/Projectile/S)
	var/ang = OrdnanceAimAngle(S.Distance)
	S.FlightAngle = ang
	S.DirOverride = GunAngleDir(ang)

mob/proc/MechRangedParts()
	. = list()
	if(!mech) return
	for(var/s in list("RArm", "LArm"))
		var/obj/Items/Gun/G = mech.MechPartIn(s)
		if(istype(G) && G.mech_only && !(G in .)) . += G

mob/proc/MechCursorSync()
	if(client && !client.cursor_dyn) CursorNeutral(client)

mob/proc/MechApplyRider(mob/D, key, n = 0, pts = 1)
	if(!D || !key || pts <= 0) return
	switch(key)
		if("Burn")
			D.AddBurn((n ? n : glob.MECH_RIDER_BURN) * pts, src)
		if("Bleed")
			D.AddBleed((n ? n : glob.MECH_RIDER_BLEED) * pts, src)
		if("Shatter")
			D.AddShatter((n ? n : glob.MECH_RIDER_SHATTER) * pts, src)
		if("Shock")
			D.AddShock((n ? n : glob.MECH_RIDER_SHOCK) * pts, src)
		if("Chill")
			D.AddSlow((n ? n : glob.MECH_RIDER_CHILL) * pts, src)
		if("Water")
			D.AddDrenched((n ? n : glob.MECH_RIDER_WATER) * pts, src)
		if("Poison")
			D.AddPoison((n ? n : glob.MECH_RIDER_POISON) * pts, src)

mob/proc/MechMeleeLanded(mob/D, strike/S)
	var/obj/Items/MechPart/Arm/P = mech_struck_part
	mech_struck_part = null
	if(istype(AttackQueue, /obj/Skills/Queue/Mech/Chainsaw_Blade))
		var/obj/Skills/Queue/Mech/Chainsaw_Blade/C = AttackQueue
		var/h = C.hit_heat * MechPartHeatMult(C)
		if(h > 0) HeatAdd(h)
	var/sting = passive_handler.Get("MechMeleeHeat")
	if(sting && D.mech) D.HeatAdd(sting)
	if(!istype(P)) return
	MechApplyRider(D, P.melee_rider, P.melee_rider_n)
	for(var/k in MECH_RIDER_COATINGS)
		MechApplyRider(D, MECH_RIDER_COATINGS[k], 0, passive_handler.Get(k))
	var/bleed = passive_handler.Get("MechMeleeBleed")
	if(bleed) D.AddBleed(bleed, src)
	var/kb = P.melee_kb + passive_handler.Get("MechMeleeKnockback") * glob.MECH_BOAR_KB
	if(kb > 0 && !D.Knockbacked && !D.KO)
		Knockback(max(2, kb), D, get_dir(src, D) || dir)

/strikeHook/mechPartMelee
	stage = "post"
	fire(strike/S)
		if(!S || !S.melee || S.dealt <= 0) return
		var/mob/A = S.attacker
		var/mob/D = S.defender
		if(!A || !D || A == D || !A.mech) return
		A.MechMeleeLanded(D, S)

mob/Players/MechDealtMult(mob/defender, strike/S)
	var/obj/Items/P = (mech && S && S.melee) ? MechActiveMeleePart() : null
	mech_struck_part = P
	. = ..()
	if(P) . *= MechPartQuality(P)

mob/Players/MeleeEndMult(mob/enemy)
	. = ..()
	if(!mech || AttackQueue) return
	var/p = MechPartVar(MechActiveMeleePart(), "melee_pierce")
	if(isnum(p) && p > 0) . *= 1 - p

mob/Players/MechTakenMult(mob/attacker, strike/S)
	. = ..()
	if(!. || !mech || !mech_shield_up || !attacker || attacker == src) return
	if(getBackSide(attacker, src) || !MechFrontArc(attacker)) return
	if(MechProjectileStrike(S))
		MechLine("shield", "[mech]'s shield stops the shot.")
		return 0
	. *= glob.MECH_SHIELD_UP_MULT

mob/Players/MechActiveGun()
	if(!mech || mech_swing_at == world.time) return null
	var/list/L = MechRangedParts()
	if(!L.len) return null
	if(L.len == 1) return L[1]
	return L[(mech_gun_hand % 2) + 1]

mob/Players/MechHandAdvance(obj/Items/Gun/g)
	if(!mech || !g || g.hands <= 0) return
	mech_gun_hand = !mech_gun_hand

mob/Players/EquippedGun()
	if(!mech) return ..()
	var/obj/Items/Gun/G = MechActiveGun()
	return G ? G : 0

mob/Players/GunWhip()
	if(!mech) return ..()
	mech_swing_at = world.time
	Melee1()
	return 1

/mob/Players/Melee1(dmgmulti=1, spdmulti=1, iconoverlay, forcewarp, forcedTarget=null, ExtendoAttack=null, SecondStrike, ThirdStrike, AsuraStrike, accmulti=1, SureKB=0, NoKB=0, IgnoreCounter=0, BreakAttackRate=0, hitback = 0, WhipOnly = 0)
	if(!mech || SecondStrike || ThirdStrike || AsuraStrike || EquippedGun()) return ..()
	var/obj/Items/P = MechActiveMeleePart()
	var/was = NextAttack
	. = ..()
	if(!P || NextAttack == was || NextAttack <= world.time) return
	var/h = MechPartVar(P, "heat_cost")
	if(isnum(h) && h > 0) HeatAdd(IntrinsicHeatCost(h * MechPartHeatMult(), P))
	if(mech) mech.IntrinsicEvent("weapon", src, P)

mob/Players/MechSkillAllowed(obj/Skills/S)
	if(mech && istype(S, /obj/Skills/Projectile/Gunfire)) return 1
	return ..()

mob/Players/FireGun(obj/Items/Gun/g)
	if(g && g.mech_only && mech && MechStalled())
		MechStallLine()
		return 0
	return ..()

mob/Players/GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	..()
	MechGunStamp(S, g)

mob/proc/MechGunStamp(obj/Skills/Projectile/S, obj/Items/Gun/g)
	if(!S) return
	S.mech_splash = 0
	if(!g || !g.mech_only) return
	if(g.shot_state)
		if(!g.shot_icon) g.shot_icon = icon(g.BulletIcon, g.shot_state)
		S.IconLock = g.shot_icon
	if(g.shot_speed_mult != 1) S.Speed *= g.shot_speed_mult
	S.mech_splash = g.shot_splash
	if(!mech) return
	var/pct = passive_handler.Get("MechRangedArmPct")
	if(pct && g.hands > 0) S.DamageMult *= 1 + pct / 100
	if(g.energy_gun) S.DamageMult *= MechEnergyShotMult()
	var/acc = passive_handler.Get("MechAccuracy")
	if(acc) S.AccMult += acc

mob/proc/MechSplash(obj/Skills/Projectile/_Projectile/P)
	var/r = P ? P.mech_splash : 0
	if(r <= 0 || !isturf(P.loc)) return
	Bang(P.loc, Size = r, Offset = 0, PX = P.VariationX + P.vhb_ax + P.step_x, PY = P.VariationY + P.vhb_ay + P.step_y)
	var/list/hit = OrdVictims(src, P, OrdCenterX(P), OrdCenterY(P), r)
	if(!hit.len) return
	var/dm = P.DamageMult
	P.DamageMult = dm * glob.MECH_SPLASH_MULT
	P.Deflectable = -1
	P.Dodgeable = -1
	P.Knockback = 0
	for(var/mob/M in hit)
		if(!P.Owner) break
		if(P.LastHitAt && (M in P.LastHitAt)) continue
		P.Hit(M)
	P.DamageMult = dm

mob/OnSpellImpact(obj/Skills/S, obj/Skills/Projectile/_Projectile/P)
	..()
	if(!P || !isturf(P.loc)) return
	if(P.mech_splash > 0) MechSplash(P)
	if(S) S.MechImpact(src, P)

mob/Players/MechMount(obj/Items/Mech/R, remount = 0)
	mech_gun_hand = 0
	mech_shield_up = 0
	..()
	MechCursorSync()

mob/Players/MechDismount(wreck = 0, silent = 0)
	mech_shield_up = 0
	mech_struck_part = null
	. = ..()
	MechCursorSync()

/obj/Skills/AutoHit/Mech
	name = "Mech AutoHit"
	var/dash_tiles = 0
	var/dash_ticks = 4
	var/dash_first = 0

	MechInitDamage()
		return initial(DamageMult)

	Use(mob/user, noGCD = FALSE)
		return user.MechPartUse(src, noGCD)

	MechFire(mob/p, noGCD = FALSE)
		if(HeldSkill) return p.MechHeldStart(src)
		if(dash_tiles <= 0 || !p.mech) return p.Activate(src, noGCD = noGCD)
		if(!p.MechSkillGo(src, noGCD)) return 0
		if(dash_first)
			. = p.Activate(src, noGCD = noGCD)
			if(Using || cooldown_remaining) p.MechDash(p.dir, dash_tiles, dash_ticks)
			return
		p.MechDash(p.dir, dash_tiles, dash_ticks)
		sleep(dash_ticks * world.tick_lag)
		return p.Activate(src, noGCD = TRUE)

	Heat_Rod
		name = "Heat Rod"
		desc = "Lash out with the Heat Rod: a 4 tile whip that shocks what it hits and drags it to your feet. Mech-scale, so it pulls mechs too."
		Area = "Wave"
		Distance = 4
		StrScaling = 1
		DamageMult = 1.5
		Paralyzing = 1
		Cooldown = 8
		mech_heat = 8
		verb/Heat_Rod()
			set category = "Skills"
			usr.MechPartUse(src)
		OnSkillHit(mob/caster, mob/m, atom/hitter)
			if(!caster || !m || m.KO || m.Dead) return
			var/d = get_dist(caster, m)
			if(d > 1) m.PullToward(caster, d - 1, 1)

	Mech_Shield
		name = "Mech Shield"
		desc = "Hold to raise the Mech Shield. While it is up, hits from your front deal half damage and shots from your front are stopped, and your other hand keeps fighting."
		HeldSkill = 1
		InfiniteHold = 1
		HeldAllowsActions = 1
		NoGCD = 1
		Cooldown = 1
		verb/Mech_Shield()
			set category = "Skills"
			usr.MechHeldStart(src)
		OnHeldStart(mob/p)
			if(p)
				p.mech_shield_up = 1
				p.IntrinsicSkillUsed(src)
		OnHeldRelease(mob/p, benefit, sweet_spot_hit, charge_level)
			if(!p) return
			p.mech_shield_up = 0
			Cooldown(1, null, p)
		OnHeldFizzle(mob/p)
			if(p) p.mech_shield_up = 0

	Pile_Bunker
		name = "Pile Bunker"
		desc = "Hold to charge the Pile Bunker, release to drive one huge stab into whatever is in front of you (up to 4x at full charge) that shatters armor. You need 2 seconds to recover after."
		HeldSkill = 1
		ChargePeriod = 1.5
		NoFizzle = 1
		Area = "Strike"
		Distance = 1
		StrScaling = 1
		DamageMult = 4
		Cooldown = 12
		mech_heat = 25
		var/pile_min = 0.25
		var/pile_shatter = 3
		var/pile_recovery = 20
		verb/Pile_Bunker()
			set category = "Skills"
			usr.MechHeldStart(src)
		OnHeldRelease(mob/p, benefit, sweet_spot_hit, charge_level)
			if(p) p.MechHeldRelease(src, benefit)
		MechReleaseFire(mob/p, benefit)
			DamageMult = MechBaseDamage() * (pile_min + (1 - pile_min) * clamp(benefit, 0, 1))
			return p.Activate(src, noGCD = TRUE)
		MechAfterFire(mob/p)
			p.NextAttack = max(p.NextAttack, world.time + pile_recovery)
		OnSkillHit(mob/caster, mob/m, atom/hitter)
			if(m) m.AddShatter(pile_shatter, caster)

	Drill_Arm
		name = "Drill Arm"
		desc = "Rush up to 4 tiles behind the spinning Drill Arm, grinding whatever it hits."
		Area = "Strike"
		ControlledRush = 1
		Rush = 4
		RushDelay = 1
		ChargeTech = 1
		ChargeTime = 1
		Rounds = 5
		StrScaling = 1
		DamageMult = 0.8
		Knockback = 1
		Size = 1
		Icon = 'Icons/Effects/CircleWind.dmi'
		IconX = -32
		IconY = -32
		Cooldown = 10
		mech_heat = 15
		verb/Drill_Arm()
			set category = "Skills"
			usr.MechPartUse(src)

	Giga_Drill
		name = "Giga Drill"
		desc = "Rush up to 4 tiles behind the Giga Drill, grinding whatever it hits at twice a Drill Arm's damage."
		Area = "Strike"
		ControlledRush = 1
		Rush = 4
		RushDelay = 1
		ChargeTech = 1
		ChargeTime = 1
		Rounds = 5
		StrScaling = 1
		DamageMult = 1.6
		Knockback = 1
		Size = 2
		Icon = 'Icons/Effects/CircleWind.dmi'
		IconX = -32
		IconY = -32
		Cooldown = 12
		mech_heat = 20
		verb/Giga_Drill()
			set category = "Skills"
			usr.MechPartUse(src)

/obj/Skills/Grapple/Mech
	name = "Mech Grapple"
	MechScale = 1

	MechInitDamage()
		return initial(DamageMult)

	Use(mob/user, noGCD = FALSE)
		return user.MechPartUse(src, noGCD)

	MechFire(mob/p, noGCD = FALSE)
		return Activate(p, noGCD)

	Claw_Arm
		name = "Claw Arm"
		desc = "While you hold someone in a grab, crush them in the Claw Arm and slam them away. Strong enough to lift another mech."
		DamageMult = 3
		StrScaling = 1
		Stunner = 0.3
		ThrowAdd = 2
		ThrowMult = 1
		TriggerMessage = "crushes and slams"
		Cooldown = 10
		mech_heat = 10
		verb/Claw_Arm()
			set category = "Skills"
			usr.MechPartUse(src)

/obj/Skills/Queue/Mech
	name = "Mech Queue"

	MechInitDamage()
		return initial(DamageMult)

	Use(mob/user, noGCD = FALSE)
		return user.MechPartUse(src, noGCD)

	MechFire(mob/p, noGCD = FALSE)
		return p.SetQueue(src, noGCD)

	Chainsaw_Blade
		name = "Chainsaw Blade"
		desc = "Rev the Chainsaw Blade: your next Normal Attack grinds five times and bleeds the target. Each hit that lands costs heat."
		DamageMult = 0.45
		AccuracyMult = 1.1
		InstantStrikes = 5
		Bloodletting = 2
		Duration = 5
		Cooldown = 10
		var/hit_heat = 2
		HitMessage = "grinds into their target with a roaring chainsaw!"
		verb/Chainsaw_Blade()
			set category = "Skills"
			usr.MechPartUse(src)

/obj/Skills/Projectile/Mech
	name = "Mech Projectile"
	var/mech_back = 0
	var/mech_missile = 0
	var/mech_blasts = 1
	var/mech_to_target = 0
	var/shot_file = MECH_ICON_SHOTS
	var/shot_state

	New()
		..()
		if(shot_state) IconLock = icon(shot_file, shot_state)

	MechInitDamage()
		return initial(DamageMult)

	Use(mob/user, noGCD = FALSE)
		return user.MechPartUse(src, noGCD)

	MechFire(mob/p, noGCD = FALSE)
		if(HeldSkill) return p.MechHeldStart(src)
		MechStampSalvo(p)
		if(mech_to_target && ismob(p.Target) && p.Target != p && p.Target.z == p.z)
			Distance = clamp(get_dist(p, p.Target), 2, Distance)
		p.MechAimSkill(src)
		. = p.UseProjectile(src, noGCD)
		FlightAngle = null
		DirOverride = 0

	proc/MechStampSalvo(mob/p)
		var/merge = 1
		if(mech_back && p.mech)
			var/n = length(p.mech.MechPartsGranting(type))
			if(n > 1 && p.MechPairedBackSalvo()) merge = n
		mech_fire_heat = merge
		Blasts = mech_blasts * merge
		DamageMult = MechBaseDamage()
		Distance = initial(Distance)
		if(mech_back)
			Blasts += p.MechBackShotBonus()
			DamageMult *= p.MechBackWeaponMult()
			Distance += p.MechBackWeaponReach()
		if(mech_missile)
			Blasts += p.MechSalvoBonus()
			HomingDelay = max(1, initial(HomingDelay) - p.MechHomingBonus())
		var/acc = p.passive_handler.Get("MechAccuracy")
		AccMult = initial(AccMult) + acc

	Rocket_Punch
		name = "Rocket Punch"
		desc = "Fire your fist. It knocks back what it hits and flies home to your arm."
		IconLock = 'Icons/Technology/Gear/ImpactGloves.dmi'
		Distance = 5
		Speed = 0.5
		DamageMult = 2.5
		StrScaling = 1
		ForScaling = 0
		Knockback = 2
		Variation = 0
		Cooldown = 10
		mech_heat = 10
		mech_ranged = 1
		verb/Rocket_Punch()
			set category = "Skills"
			usr.MechPartUse(src)
		MechImpact(mob/p, obj/Skills/Projectile/_Projectile/P)
			if(!p || !P || !isturf(P.loc) || P.z != p.z) return
			var/obj/Skills/Projectile/Mech/Rocket_Punch_Return/R = new
			R.DamageMult = DamageMult
			R.Distance = get_dist(P, p) + glob.MECH_ROCKET_RETURN_PAD
			R.DirOverride = get_dir(P, p)
			R.SpawnPosition = P.loc
			var/obj/Skills/Projectile/_Projectile/B = p.Blast(R, P.loc, 0)
			if(!B) return
			B.Homing = p
			if(P.LastHitAt)
				if(!B.LastHitAt) B.LastHitAt = list()
				for(var/M in P.LastHitAt)
					B.LastHitAt[M] = world.time + 50

	Rocket_Punch_Return
		name = "Rocket Punch"
		IconLock = 'Icons/Technology/Gear/ImpactGloves.dmi'
		Speed = 0.5
		DamageMult = 2.5
		StrScaling = 1
		ForScaling = 0
		Knockback = 2
		Variation = 0




/obj/Skills/Projectile/Beams/Mech
	name = "Mech Beam"
	mech_ranged = 1
	EndEffectiveness = 0.75
	var/mech_back = 0

	MechInitDamage()
		return initial(DamageMult)

	Use(mob/user, noGCD = FALSE)
		return user.MechHeldStart(src)

	OnHeldRelease(mob/p, benefit, sweet_spot_hit, charge_level)
		if(!p) return
		if(mech_ranged && !p.MechRangedReady()) return
		DamageMult = MechBaseDamage() * p.MechEnergyShotMult()
		if(mech_back) DamageMult *= p.MechBackWeaponMult()
		var/was_using = Using
		var/was_charges = Charges
		mech_fire_heat = 1
		..()
		if(MechSkillFired(src, was_using, was_charges))
			p.MechSkillHeat(src, mech_heat_scale)
			MechAfterFire(p)
			p.IntrinsicSkillUsed(src)
		mech_heat_scale = 1

	MechBarrageFire(mob/p, scale)
		if(!p.MechPartOnBoard(src) || Using || cooldown_remaining) return 0
		mech_heat_scale = scale
		OnHeldRelease(p, 1)
		return 1

	Twin_Buster
		name = "Twin Buster"
		desc = "Hold to charge the Twin Buster Rifle, release to pour a giant beam. Firing it fills the heat gauge."
		HeldSkill = 1
		HeldBeam = 1
		IconLock = 'Icons/Beams/Beam20.dmi'
		ChargePeriod = 2
		BeamTime = 30
		Distance = 20
		DamageMult = 0.62
		Knockback = 1
		Cooldown = 20
		mech_heat = 100
		CritEffectiveness = 0
		verb/Twin_Buster()
			set category = "Skills"
			usr.MechHeldStart(src)
