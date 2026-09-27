mob/var/tmp/obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/mech_limit

/obj/Items/MechPart/Internal
	Trans_Am_Drive
		name = "Trans-Am Drive"
		desc = "A Limit Drive for a mech's Internal slot. Grants Trans-Am: for 20 seconds, SPD +6, attacks come 30 percent faster and Thrust costs no heat. Needs a Level 2 frame. 30 heat to start, 120 second cooldown. A mech runs one Limit Drive."
		part_tier = MECH_TIER_WALKER
		heat_cost = 30
		limit_drive = 1
		Techniques = list(/obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/Trans_Am)

	Fortress_Drive
		name = "Fortress Drive"
		desc = "A Limit Drive for a mech's Internal slot. Grants Fortress: for 20 seconds the mech takes half damage but cannot move or fly. Needs a Level 2 frame. 30 heat to start, 120 second cooldown. A mech runs one Limit Drive."
		part_tier = MECH_TIER_WALKER
		heat_cost = 30
		limit_drive = 1
		Techniques = list(/obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/Fortress)

	Destroyer_Drive
		name = "Destroyer Drive"
		desc = "A Limit Drive for a mech's Internal slot. Grants Destroyer: for 15 seconds, STR and FOR +8, but every heat cost doubles. Needs a Level 4 frame. 40 heat to start, 180 second cooldown. A mech runs one Limit Drive."
		part_tier = MECH_TIER_WALKER
		heat_cost = 40
		limit_drive = 1
		Techniques = list(/obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/Destroyer)

/obj/Skills/Buffs/SlotlessBuffs/Mech_Limit
	name = "Limit Mode"
	Cooldown = 120
	CooldownStatic = 1
	var/limit_level = 2
	var/limit_heat = 30
	var/limit_secs = 20
	var/limit_spd = 0
	var/limit_str = 0
	var/limit_for = 0
	var/limit_delay = 1
	var/limit_taken = 1
	var/limit_rooted = 0
	var/limit_thrust_free = 0
	var/limit_heat_mult = 1

	Trigger(mob/User, Override = 0)
		. = ..()
		if(User) User.MechLimitSync(src)

	Trans_Am
		name = "Trans-Am"
		desc = "Push the mech past its limits for 20 seconds: SPD +6, attacks 30 percent faster, Thrust free of heat. Needs a Level 2 frame. 30 heat to start, 120 second cooldown."
		ActiveMessage = "pushes their mech into Trans-Am!"
		OffMessage = "lets their mech fall out of Trans-Am."
		limit_spd = 6
		limit_delay = 0.7
		limit_thrust_free = 1
		verb/Trans_Am()
			set category = "Skills"
			usr.MechLimitPress(src)

	Fortress
		name = "Fortress"
		desc = "Lock the mech down for 20 seconds: it takes half damage but cannot move or fly. Needs a Level 2 frame. 30 heat to start, 120 second cooldown."
		ActiveMessage = "locks their mech down into Fortress mode!"
		OffMessage = "unlocks their mech from Fortress mode."
		limit_taken = 0.5
		limit_rooted = 1
		verb/Fortress()
			set category = "Skills"
			usr.MechLimitPress(src)

	Destroyer
		name = "Destroyer"
		desc = "Burn the mech hot for 15 seconds: STR and FOR +8, but every heat cost doubles. Needs a Level 4 frame. 40 heat to start, 180 second cooldown."
		ActiveMessage = "drives their mech into Destroyer mode!"
		OffMessage = "lets their mech cool out of Destroyer mode."
		Cooldown = 180
		limit_level = 4
		limit_heat = 40
		limit_secs = 15
		limit_str = 8
		limit_for = 8
		limit_heat_mult = 2
		verb/Destroyer()
			set category = "Skills"
			usr.MechLimitPress(src)

mob/proc/MechLimitRefusal(obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/B)
	if(!mech) return "[B] only works from inside a mech."
	var/lv = mech.MechLevel()
	if(lv < B.limit_level) return "[mech] is a Level [lv] frame. [B] needs Level [B.limit_level] or higher."
	if(Overheated()) return "[mech] is overheated. Let it cool down first."
	if(MechLimp()) return "[mech] is out of fuel. The Limit Drive will not start."
	if(MechStalled()) return "[mech]'s systems are stalled."
	if(B.Using || B.cooldown_remaining) return "[B] is still recharging."
	if(mech_limit && mech_limit != B) return "[mech_limit] is already running."
	return null

mob/proc/MechLimitPress(obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/B)
	if(!B) return 0
	if(BuffOn(B))
		B.Trigger(src)
		return 1
	var/why = MechLimitRefusal(B)
	if(why)
		if(mech) MechLine("limit", why)
		else src << why
		return 0
	B.TimerLimit = round(B.limit_secs * MechLimitDurationMult(), 0.1)
	B.Trigger(src)
	if(!BuffOn(B)) return 0
	HeatAdd(B.limit_heat)
	return 1

mob/proc/MechLimitSync(obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/B)
	if(BuffOn(B))
		mech_limit = B
		if(B.limit_rooted && mech)
			if(MechAirborne()) MechLand(1)
			MechVelocityZero()
	else if(mech_limit == B)
		mech_limit = null
	if(mech) MechApplyStats()

mob/Players/MechMount(obj/Items/Mech/R, remount = 0)
	..()
	if(!R || mech != R) return
	mech_limit = null
	for(var/obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/B in R.MechKeptSkills())
		if(BuffOn(B)) mech_limit = B
	if(mech_limit) MechApplyStats()

/obj/Items/Mech/MechStatMods(list/S)
	..()
	var/mob/M = loc
	if(!ismob(M) || M.mech != src || !M.mech_limit) return
	var/obj/Skills/Buffs/SlotlessBuffs/Mech_Limit/B = M.mech_limit
	S["Spd"] += B.limit_spd
	S["Str"] += B.limit_str
	S["For"] += B.limit_for

/obj/Items/Mech/MechPartFits(obj/Items/I, slot)
	. = ..()
	if(. || !MechPartVar(I, "limit_drive")) return
	for(var/obj/Items/P in MechPartsOfKind("Internal"))
		if(P == I || MechPartIn(slot) == P) continue
		if(MechPartVar(P, "limit_drive")) return "[src] already runs [P]. A mech takes one Limit Drive"

mob/Players/MechHeatCostMult()
	. = ..()
	if(mech && mech_limit) . *= mech_limit.limit_heat_mult

mob/Players/MechPartHeatMult(obj/Skills/S)
	return ..() * MechHeatCostMult()

mob/Players/MechPilotSkillHeatMult()
	return ..() * MechHeatCostMult()

mob/Players/MechThrustHeatMult()
	. = ..() * MechHeatCostMult()
	if(mech && mech_limit && mech_limit.limit_thrust_free) . = 0

mob/Players/MechMeleeMult()
	. = ..()
	if(mech && mech_limit && mech_limit.limit_delay != 1)
		var/list/L = .
		L[2] *= mech_limit.limit_delay

mob/Players/MechDamageTakenMult()
	. = ..()
	if(mech && mech_limit) . *= mech_limit.limit_taken

mob/Players/MoveBudgetMult()
	. = ..()
	if(mech && mech_limit && mech_limit.limit_rooted) . = 0

mob/Players/MechRooted()
	if(mech && mech_limit && mech_limit.limit_rooted) return 1
	return ..()

mob/Players/MechCanFly(obj/Items/Mech/R)
	if(mech && mech_limit && mech_limit.limit_rooted && (!R || R == mech)) return 0
	return ..()

mob/Players/MechThrustPress(obj/Skills/S)
	if(mech && mech_limit && mech_limit.limit_rooted)
		MechFlyLine("thrust", "[mech] is locked down in [mech_limit] mode.")
		return 0
	return ..()
