globalTracker/var
	MECH_RED_COMET_THRUST = 0.7
	MECH_RED_COMET_HIT = 1.2
	MECH_RED_COMET_WINDOW = 10
	MECH_RIPOSTE_MULT = 1.3
	MECH_RIPOSTE_WINDOW = 20
	MECH_PSYCOMMU_BITS = 1
	MECH_PSYCOMMU_REACH = 1.25
	MECH_PSYCOMMU_ENERGY = 1.1
	MECH_MASS_REPAIR = 0.5
	MECH_MASS_RECIPE = 0.8
	MECH_MASS_HULL = 10
	MECH_SHIELD_FRONT = 0.8
	MECH_SHIELD_BLOCK = 25
	MECH_KATA_STEP = 0.1
	MECH_KATA_MAX = 3
	MECH_KATA_WINDOW = 30
	MECH_SIEGE_STILL_DS = 20
	MECH_SIEGE_BACK = 1.25
	MECH_SIEGE_REACH = 2
	MECH_SIEGE_KB = 0.5
	MECH_PREDATOR_MULT = 1.25
	MECH_PREDATOR_STOMP_KB = 5
	MECH_VENT_HEAT = 70
	MECH_VENT_STR = 1.2
	MECH_VENT_CAP = 1.15
	MECH_AFTERBURNER_SPEED = 1.2
	MECH_AFTERBURNER_DRIFT = 1.3
	MECH_AFTERBURNER_SALVO = 2
	MECH_FIRE_CONTROL_SHOTS = 1
	MECH_BIT_MOTHER_BITS = 2
	MECH_SYNC_HEAT = 0.75
	MECH_SYNC_HIT = 1.15
	MECH_SYNC_HANDLING = 2
	MECH_HOVER_EMP = 0.5
	MECH_HOVER_DRIFT = 0.5
	MECH_SENSOR_RANGE = 12
	MECH_SENSOR_BIT_REACH = 1.5
	MECH_SENSOR_EMP = 0.5
	MECH_LOW_HULL_PCT = 30

passiveInfo/RedComet
	setLines()
		lines = list("Mech passive (Vanguard). Thrust costs less heat: it is multiplied by [glob.outputVariableInfo("MECH_RED_COMET_THRUST")].",\
"The first hit within [glob.outputVariableInfo("MECH_RED_COMET_WINDOW")] deciseconds of a Thrust deals [glob.outputVariableInfo("MECH_RED_COMET_HIT")] times damage.")

passiveInfo/Riposte
	setLines()
		lines = list("Mech passive (Duelist). After taking a melee hit, your next melee hit within [glob.outputVariableInfo("MECH_RIPOSTE_WINDOW")] deciseconds deals [glob.outputVariableInfo("MECH_RIPOSTE_MULT")] times damage.")

passiveInfo/Psycommu
	setLines()
		lines = list("Mech passive (Seraph). Funnel parts field [glob.outputVariableInfo("MECH_PSYCOMMU_BITS")] extra bit and reach [glob.outputVariableInfo("MECH_PSYCOMMU_REACH")] times as far.",\
"Energy shots deal [glob.outputVariableInfo("MECH_PSYCOMMU_ENERGY")] times damage.")

passiveInfo/MassProduction
	setLines()
		lines = list("Mech passive (Sentinel). Mech Bay repairs cost [glob.outputVariableInfo("MECH_MASS_REPAIR")] of the usual materials.",\
"Parts crafted for this model cost [glob.outputVariableInfo("MECH_MASS_RECIPE")] of their materials.",\
"Hull is [glob.outputVariableInfo("MECH_MASS_HULL")] percent higher.")

passiveInfo/ShieldBearer
	setLines()
		lines = list("Mech passive (Paladin). Hits from your front arc (your facing and its two neighbors) deal [glob.outputVariableInfo("MECH_SHIELD_FRONT")] times damage.",\
"Frontal projectiles have a [glob.outputVariableInfo("MECH_SHIELD_BLOCK")] percent chance to be blocked outright.")

passiveInfo/TwinBladeKata
	setLines()
		lines = list("Mech passive (Musha). Each melee hit in an alternating chain adds [glob.outputVariableInfo("MECH_KATA_STEP")] damage, up to [glob.outputVariableInfo("MECH_KATA_MAX")] stacks.",\
"The chain clears after [glob.outputVariableInfo("MECH_KATA_WINDOW")] deciseconds without a hit.")

passiveInfo/SiegePlatform
	setLines()
		lines = list("Mech passive (Bastion). After standing still for [glob.outputVariableInfo("MECH_SIEGE_STILL_DS")] deciseconds, Back weapons deal [glob.outputVariableInfo("MECH_SIEGE_BACK")] times damage and reach [glob.outputVariableInfo("MECH_SIEGE_REACH")] more tiles.",\
"While planted, knockback taken is multiplied by [glob.outputVariableInfo("MECH_SIEGE_KB")].")

passiveInfo/PredatorFrame
	setLines()
		lines = list("Mech passive (Typhon). Hits on a target facing away deal [glob.outputVariableInfo("MECH_PREDATOR_MULT")] times damage, on top of the rear weak point.",\
"Landing from flight onto a target's tile stomps it (a 1 tile burst, knockback [glob.outputVariableInfo("MECH_PREDATOR_STOMP_KB")]).")

passiveInfo/VentCycling
	setLines()
		lines = list("Mech passive (Juggernaut). Above [glob.outputVariableInfo("MECH_VENT_HEAT")] heat, STR is multiplied by [glob.outputVariableInfo("MECH_VENT_STR")].",\
"The overheat line is multiplied by [glob.outputVariableInfo("MECH_VENT_CAP")].")

passiveInfo/Afterburner
	setLines()
		lines = list("Mech passive (Shark). Flight top speed is multiplied by [glob.outputVariableInfo("MECH_AFTERBURNER_SPEED")] and drift by [glob.outputVariableInfo("MECH_AFTERBURNER_DRIFT")].",\
"Missile salvos fire [glob.outputVariableInfo("MECH_AFTERBURNER_SALVO")] extra missiles.")

passiveInfo/FireControl
	setLines()
		lines = list("Mech passive (Fighter). Back weapons fire [glob.outputVariableInfo("MECH_FIRE_CONTROL_SHOTS")] extra shot per salvo.",\
"Two identical Back parts fire as one salvo.")

passiveInfo/BitMothership
	setLines()
		lines = list("Mech passive (Cross). Funnel parts field [glob.outputVariableInfo("MECH_BIT_MOTHER_BITS")] extra bits and recall instantly.",\
"The hurtbox is the drawn ink only.")

passiveInfo/PilotSync
	setLines()
		lines = list("Mech passive (Lancer). Mech-compatible pilot skills cost [glob.outputVariableInfo("MECH_SYNC_HEAT")] of their heat and deal [glob.outputVariableInfo("MECH_SYNC_HIT")] times damage.",\
"Piloting Prowess handling counts [glob.outputVariableInfo("MECH_SYNC_HANDLING")] times.")

passiveInfo/HoverChassis
	setLines()
		lines = list("Mech passive (Strider). Never triggers caltrops or mines and ignores water slows.",\
"EMP stall is multiplied by [glob.outputVariableInfo("MECH_HOVER_EMP")]. On the ground it drifts at [glob.outputVariableInfo("MECH_HOVER_DRIFT")] of a flyer's rate.")

passiveInfo/SensorArray
	setLines()
		lines = list("Mech passive (Overseer). Cloaked and Tracker-tagged targets show within [glob.outputVariableInfo("MECH_SENSOR_RANGE")] tiles, and Jammers do not affect it.",\
"Bit reach is multiplied by [glob.outputVariableInfo("MECH_SENSOR_BIT_REACH")]. EMP heat and stall are multiplied by [glob.outputVariableInfo("MECH_SENSOR_EMP")].")

mob/proc/getRedComet()
	return passive_handler.Get("RedComet")

mob/proc/getRiposte()
	return passive_handler.Get("Riposte")

mob/proc/getPsycommu()
	return passive_handler.Get("Psycommu")

mob/proc/getMassProduction()
	return passive_handler.Get("MassProduction")

mob/proc/getShieldBearer()
	return passive_handler.Get("ShieldBearer")

mob/proc/getTwinBladeKata()
	return passive_handler.Get("TwinBladeKata")

mob/proc/getSiegePlatform()
	return passive_handler.Get("SiegePlatform")

mob/proc/getPredatorFrame()
	return passive_handler.Get("PredatorFrame")

mob/proc/getVentCycling()
	return passive_handler.Get("VentCycling")

mob/proc/getAfterburner()
	return passive_handler.Get("Afterburner")

mob/proc/getFireControl()
	return passive_handler.Get("FireControl")

mob/proc/getBitMothership()
	return passive_handler.Get("BitMothership")

mob/proc/getPilotSync()
	return passive_handler.Get("PilotSync")

mob/proc/getHoverChassis()
	return passive_handler.Get("HoverChassis")

mob/proc/getSensorArray()
	return passive_handler.Get("SensorArray")

mob/proc/MechSiegePlanted()
	if(!mech || !getSiegePlatform()) return 0
	return (world.time - gun_last_move >= glob.MECH_SIEGE_STILL_DS) ? 1 : 0

mob/proc/MechBackWeaponMult()
	return MechSiegePlanted() ? glob.MECH_SIEGE_BACK : 1

mob/proc/MechBackWeaponReach()
	return MechSiegePlanted() ? glob.MECH_SIEGE_REACH : 0

mob/proc/MechBitBonus()
	. = 0
	if(getPsycommu()) . += glob.MECH_PSYCOMMU_BITS
	if(getBitMothership()) . += glob.MECH_BIT_MOTHER_BITS

mob/proc/MechBitReachMult()
	. = 1
	if(getPsycommu()) . *= glob.MECH_PSYCOMMU_REACH
	if(getSensorArray()) . *= glob.MECH_SENSOR_BIT_REACH

mob/proc/MechBitRecallInstant()
	return getBitMothership() ? 1 : 0

mob/proc/MechInkHurtbox()
	return getBitMothership() ? 1 : 0

mob/proc/MechEnergyShotMult()
	return getPsycommu() ? glob.MECH_PSYCOMMU_ENERGY : 1

mob/proc/MechFlightSpeedMult()
	return getAfterburner() ? glob.MECH_AFTERBURNER_SPEED : 1

mob/proc/MechDriftMult()
	. = 1
	if(getAfterburner()) . *= glob.MECH_AFTERBURNER_DRIFT
	var/h = passive_handler.Get("MechDriftPct")
	if(h) . *= 1 + h / 100

mob/proc/MechGroundDriftMult()
	return getHoverChassis() ? glob.MECH_HOVER_DRIFT : 0

mob/proc/MechSalvoBonus()
	return getAfterburner() ? glob.MECH_AFTERBURNER_SALVO : 0

mob/proc/MechBackShotBonus()
	return getFireControl() ? glob.MECH_FIRE_CONTROL_SHOTS : 0

mob/proc/MechPairedBackSalvo()
	return getFireControl() ? 1 : 0

mob/proc/MechPredatorStomp()
	return getPredatorFrame() ? glob.MECH_PREDATOR_STOMP_KB : 0

mob/proc/MechSensorRange()
	return getSensorArray() ? glob.MECH_SENSOR_RANGE : 0

mob/proc/MechJamImmune()
	return getSensorArray() ? 1 : 0

mob/Players/MechStatMult(stat)
	if(!mech) return 1
	. = 1
	var/v = "[stat]Mult"
	var/list/on = list()
	if(ActiveBuff) on += ActiveBuff
	if(SpecialBuff) on += SpecialBuff
	for(var/k in SlotlessBuffs)
		var/obj/Skills/Buffs/SB = SlotlessBuffs[k]
		if(SB) on += SB
	for(var/obj/Skills/Buffs/B in on)
		if(!IsMechCompatible(B) || !BuffOn(B) || !(v in B.vars)) continue
		var/m = B.vars[v]
		if(isnum(m) && m > 0) . *= m
	if(stat == "Str" && getVentCycling() && HeatNow() > glob.MECH_VENT_HEAT) . *= glob.MECH_VENT_STR
	if(stat == "Str" || stat == "For")
		var/rage = passive_handler.Get("MechLowHullRage")
		if(rage && HealthPct() < glob.MECH_LOW_HULL_PCT) . *= 1 + rage / 100
	if(stat in list("Str", "End", "Spd", "For", "Off", "Def"))
		. += GetWillStatMult()

/obj/Items/Mech/MechStatMods(list/S)
	..()
	var/pct = 0
	if(MechHasPassive("Mass Production")) pct += glob.MECH_MASS_HULL
	var/list/C = MechCoatingRow(coating)
	for(var/i = 1 to length(C) step 3)
		if(C[i] == "MechHullPct") pct += C[i + 1]
	for(var/obj/Items/P in MechPartsOfKind("Internal"))
		var/h = MechPartVar(P, "hull_pct")
		if(isnum(h)) pct += h
	if(pct)
		S["Vit"] = (max(0.1, S["Vit"]) + glob.HP_STAT_BASE) * (1 + pct / 100) - glob.HP_STAT_BASE
