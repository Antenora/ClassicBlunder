globalTracker/var
	MECH_REAR_MULT = 1.15
	list/MECH_KB_BY_STEP = list(1, 0.5, 0)
	MECH_BURN_HEAT = 2
	MECH_CHILL_DISSIPATION = 0.6
	MECH_SHOCK_STALL = 10
	MECH_EMP_STALL_DS = 40
	MECH_EMP_HEAT = 30
	MECH_RAMP_MIN = 0.4
	MECH_RAMP_TICKS = 6
	MECH_RAMP_TILE_GAP = 10
	MECH_HOVER_SWIM = 4
	MECH_DOOR_LINE_GAP = 20
	MECH_PROWESS_DISSIPATION = 0.05
	MECH_PROWESS_THRUST = 0.04
	MECH_PROWESS_LIMIT = 0.05

var/list/MECH_BAKED_MELEE_HITS = list("TV_Robot02" = 2)

mob/var/tmp
	mech_ramp = 1
	mech_ramp_at = 0
	mech_stall_until = 0
	mech_hand = 0
	mech_kata = 0
	mech_kata_at = 0
	mech_riposte_until = 0
	mech_thrust_at = 0
	mech_multi_at = -1
	mech_door_at = 0

mob/proc/MechAirborne()
	return 0

mob/proc/MechRecallBits()
	return

mob/proc/MechStalled()
	return (mech && world.time < mech_stall_until) ? 1 : 0

mob/proc/MechRampTick()
	var/gap = PmActive() ? world.tick_lag * 2 : glob.MECH_RAMP_TILE_GAP
	if(world.time - mech_ramp_at > gap)
		mech_ramp = glob.MECH_RAMP_MIN
	else
		mech_ramp = min(1, mech_ramp + (1 - glob.MECH_RAMP_MIN) / glob.MECH_RAMP_TICKS)
	mech_ramp_at = world.time

mob/Players/MoveBudgetMult()
	. = ..()
	if(!mech || MechAirborne()) return
	var/list/row = mech.MechRow()
	var/mv = row ? row["move"] : 1
	if(mech_limp)
		. *= mv * glob.MECH_LIMP_MOVE
	else
		MechRampTick()
		. *= mv * mech_ramp
	if(Swim && getHoverChassis()) . *= glob.MECH_HOVER_SWIM

mob/proc/MechClassStep(cls)
	switch(cls)
		if("Medium") return 1
		if("Heavy") return 2
	return 0

mob/Players/MechKBMult()
	if(!mech) return 1
	var/list/row = mech.MechRow()
	var/list/L = glob.MECH_KB_BY_STEP
	var/s = MechClassStep(row ? row["class"] : null) + passive_handler.Get("MechKnockbackStep")
	. = L[clamp(round(s), 0, L.len - 1) + 1]
	if(MechSiegePlanted()) . *= glob.MECH_SIEGE_KB

mob/proc/MechMeleeParts()
	. = list()
	if(!mech) return
	for(var/s in list("RArm", "LArm"))
		var/obj/Items/P = mech.MechPartIn(s)
		if(P && !(P in .) && isnum(MechPartVar(P, "melee_mult"))) . += P

mob/proc/MechActiveMeleePart()
	var/list/L = MechMeleeParts()
	if(!L.len) return null
	if(L.len == 1) return L[1]
	return L[(mech_hand % 2) + 1]

mob/proc/MechMeleeMult()
	var/obj/Items/P = MechActiveMeleePart()
	if(!P) return list(1, 1, null)
	var/d = MechPartVar(P, "melee_mult")
	var/t = MechPartVar(P, "melee_delay")
	return list(isnum(d) ? d : 1, isnum(t) ? t : 1, MechPartVar(P, "melee_rider"))

mob/proc/MechAttackDelayMult()
	if(!mech) return 1
	var/list/row = mech.MechRow()
	var/list/mm = MechMeleeMult()
	return (row ? row["atk"] : 1) * mm[2]

mob/Players/SpeedDelay(var/Modifier=1)
	. = ..()
	if(mech) . *= MechAttackDelayMult()

mob/proc/MechExtraMeleeHits()
	if(!mech) return 0
	var/n = MECH_BAKED_MELEE_HITS[mech.model]
	. = isnum(n) ? n - 1 : 0
	for(var/s in mech.parts)
		var/obj/Items/P = mech.MechPartIn(s)
		var/e = P ? MechPartVar(P, "extra_melee_hits") : null
		if(isnum(e)) . += e

mob/Players/MultiStrike(secondStrike, thirdStrike, asuraStrike)
	if(mech && !secondStrike && !AttackQueue)
		var/extra = MechExtraMeleeHits()
		if(extra > 0)
			if(mech_multi_at == world.time) return
			mech_multi_at = world.time
			Melee1(SecondStrike = 1)
			if(extra > 1) Melee1(SecondStrike = 1, ThirdStrike = 1)
			return
	return ..()

mob/proc/MechFrontArc(mob/A)
	if(!A) return 0
	var/d = get_dir(src, A)
	if(!d) return 0
	return (d == dir || d == turn(dir, 45) || d == turn(dir, -45)) ? 1 : 0

proc/MechProjectileStrike(strike/S)
	return (S && S.spirit && !S.melee && !S.autohit) ? 1 : 0

mob/proc/MechPilotStrike(strike/S)
	if(!S) return 0
	if(!S.melee && world.time <= mech_pilot_skill_until) return 1
	if(S.melee && AttackQueue && IsMechCompatible(AttackQueue) && !MechOwnsSkill(AttackQueue)) return 1
	return 0

mob/proc/MechKataStep()
	if(world.time - mech_kata_at > glob.MECH_KATA_WINDOW) mech_kata = 0
	. = mech_kata
	mech_kata = min(glob.MECH_KATA_MAX, mech_kata + 1)
	mech_kata_at = world.time

mob/proc/MechDamageTakenMult()
	return 1

mob/proc/MechFrontCut()
	return getShieldBearer() ? 1 - glob.MECH_SHIELD_FRONT : 0

mob/Players/MechTakenMult(mob/attacker, strike/S)
	if(!mech) return 1
	. = MechDamageTakenMult()
	if(attacker && attacker != src)
		if(getBackSide(attacker, src))
			. *= glob.MECH_REAR_MULT
		else if(MechFrontArc(attacker))
			if(getShieldBearer() && MechProjectileStrike(S) && prob(glob.MECH_SHIELD_BLOCK))
				src << "[mech]'s shield turns the shot aside."
				return 0
			. *= max(0, 1 - MechFrontCut())
	if(S && S.melee && getRiposte()) mech_riposte_until = world.time + glob.MECH_RIPOSTE_WINDOW

mob/Players/MechDealtMult(mob/defender, strike/S)
	if(!mech || !S) return 1
	. = 1
	if(S.melee)
		var/list/mm = MechMeleeMult()
		. *= mm[1]
		var/ogre = passive_handler.Get("MechMeleePct")
		if(ogre && MechActiveMeleePart()) . *= 1 + ogre / 100
		if(getRiposte() && world.time <= mech_riposte_until)
			. *= glob.MECH_RIPOSTE_MULT
			mech_riposte_until = 0
		if(getTwinBladeKata()) . *= 1 + glob.MECH_KATA_STEP * MechKataStep()
		mech_hand = !mech_hand
	if(getPredatorFrame() && defender && getBackSide(src, defender)) . *= glob.MECH_PREDATOR_MULT
	if(getRedComet() && mech_thrust_at && world.time - mech_thrust_at <= glob.MECH_RED_COMET_WINDOW)
		. *= glob.MECH_RED_COMET_HIT
		mech_thrust_at = 0
	if(getPilotSync() && MechPilotStrike(S)) . *= glob.MECH_SYNC_HIT

mob/Players/AddBleed(var/Value, var/mob/Attacker=null)
	if(mech) return
	return ..()

mob/Players/AddPoison(var/Value, var/mob/Attacker=null)
	if(mech) return
	return ..()

mob/Players/AddShock(var/Value, var/mob/Attacker=null)
	if(mech)
		if(Value > 0) mech_stall_until = max(mech_stall_until, world.time + glob.MECH_SHOCK_STALL)
		return
	return ..()

mob/Players/AddCrippling(var/Value, var/mob/Attacker=null)
	if(mech && MechAirborne()) return
	return ..()

mob/Players/doDebuffDamage(typeOfDebuff)
	if(!mech || !(typeOfDebuff in list("Burn", "Bleed", "Poison"))) return ..()
	if(typeOfDebuff == "Burn")
		var/h = glob.MECH_BURN_HEAT
		if(passive_handler.Get("MechBurnHeatHalf")) h *= 0.5
		HeatAdd(h)
	reduceDebuffStacks(typeOfDebuff)

mob/proc/MechEMPStallMult()
	. = 1
	if(getHoverChassis()) . *= glob.MECH_HOVER_EMP
	var/e = passive_handler.Get("MechEMPStallPct")
	if(e) . *= max(0, 1 - e / 100)
	if(getSensorArray()) . *= glob.MECH_SENSOR_EMP

mob/proc/MechEMPHeatMult()
	. = 1
	if(getSensorArray()) . *= glob.MECH_SENSOR_EMP

mob/Players/EMPHit(strength)
	. = ..()
	if(!mech || strength <= 0) return
	mech_stall_until = max(mech_stall_until, world.time + glob.MECH_EMP_STALL_DS * strength * MechEMPStallMult())
	HeatAdd(glob.MECH_EMP_HEAT * MechEMPHeatMult())
	MechRecallBits()
	src << "<font color='#8be9ff'>The pulse stalls [mech]'s systems.</font>"
	. = 1

mob/Players/MaimMult(kind)
	if(mech) return 1
	return ..()

mob/Players/MaimFlat(kind)
	if(mech) return 0
	return ..()

mob/Players/MaimCreepHit(mob/attacker, dmg)
	if(MechNoWounds()) return
	return ..()

mob/Players/MechHazardImmune()
	return (mech && getHoverChassis()) ? 1 : 0

mob/Players/MechDissipationMult()
	. = ..()
	if(!mech) return
	. *= 1 + glob.MECH_PROWESS_DISSIPATION * MechHandlingPoints()
	if(Slow > 0) . *= glob.MECH_CHILL_DISSIPATION
	var/y = passive_handler.Get("MechDissipationPct")
	if(y) . *= 1 + y / 100

mob/Players/MechHeatMaxMult()
	. = ..()
	if(mech && getVentCycling()) . *= glob.MECH_VENT_CAP

mob/proc/MechThrustHeatMult()
	. = max(0.1, 1 - glob.MECH_PROWESS_THRUST * MechHandlingPoints())
	if(getRedComet()) . *= glob.MECH_RED_COMET_THRUST

mob/proc/MechLimitDurationMult()
	. = 1 + glob.MECH_PROWESS_LIMIT * MechHandlingPoints()
	var/e = passive_handler.Get("MechLimitPct")
	if(e) . *= 1 + e / 100

mob/Players/AppearanceOn()
	if(mech)
		MechBodyLook()
		return
	return ..()

mob/Players/HollowApplyMask()
	if(mech) return
	return ..()

mob/Players/ContinueKB(var/DustBlock=0)
	..()
	if(mech) MechBodyState()

mob/Players/StopKB(var/DustBlock=0)
	..()
	if(mech) MechBodyState()

proc/MechDoorBlocks(atom/movable/O)
	var/mob/M = O
	if(!istype(M) || !M.mech) return 0
	if(world.time >= M.mech_door_at)
		M.mech_door_at = world.time + glob.MECH_DOOR_LINE_GAP
		M << "[M.mech] is far too big to fit through a door."
	return 1

/obj/Items/Tech/Door/Cross(atom/movable/O)
	if(MechDoorBlocks(O)) return 0
	return ..()

/obj/Items/Tech/Reinforced_Door/Cross(atom/movable/O)
	if(MechDoorBlocks(O)) return 0
	return ..()

/obj/Turfs/Door/Cross(atom/movable/O)
	if(MechDoorBlocks(O)) return 0
	return ..()
