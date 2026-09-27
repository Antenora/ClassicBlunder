var/list/MECH_COMPATIBLE_SKILLS = list(\
	/obj/Skills/Grapple/Burning_Finger,\
	/obj/Skills/Grapple/Erupting_Burning_Finger,\
	/obj/Skills/AutoHit/Drill_Spin,\
	/obj/Skills/Buffs/SpecialBuffs/King_of_Braves,\
	/obj/Skills/Buffs/SlotlessBuffs/Genesic_Brave,\
	/obj/Skills/Buffs/SlotlessBuffs/Will_Knife,\
	/obj/Skills/Buffs/SlotlessBuffs/Protect_Shade,\
	/obj/Skills/Projectile/King_of_Braves/Broken_Magnum,\
	/obj/Skills/Queue/DrillKnee,\
	/obj/Skills/AutoHit/Plasma_Hold,\
	/obj/Skills/AutoHit/Hell_And_Heaven,\
	/obj/Skills/Buffs/SlotlessBuffs/Dividing_Driver,\
	/obj/Skills/AutoHit/Giga_Drill_Breaker,\
	/obj/Skills/AutoHit/Goldion_Hammer,\
	/obj/Skills/Buffs/SlotlessBuffs/Protect_Wall,\
	/obj/Skills/Projectile/King_of_Braves/Broken_Phantom,\
	/obj/Skills/Projectile/King_of_Braves/Brave_Tornado,\
	/obj/Skills/AutoHit/Anti_Spiral_Giga_Drill_Breaker,\
	/obj/Skills/Queue/Secret_Heavy_Strike/Spiral_Drill) + typesof(/obj/Skills/Buffs/SlotlessBuffs/Spiral) + typesof(/obj/Skills/AutoHit/Spiral) + typesof(/obj/Skills/Projectile/Spiral)

var/list/MECH_SKILLX_ALLOWED = list("Grab")

globalTracker/var
	MECH_PILOT_HEAT_MIN = 5
	MECH_PILOT_HEAT_DIV = 4
	MECH_REFUSE_GAP = 10
	MECH_PILOT_SKILL_WINDOW = 30
	MECH_HEAT_WATCH_DS = 30

/obj/Skills/var/MechCompatible = 0
/obj/Skills/Grapple/var/MechScale = 0

mob/var/tmp/mech_refuse_at = 0
mob/var/tmp/mech_refuse_what
mob/var/tmp/mech_pilot_skill_until = 0

proc/IsMechCompatible(obj/Skills/S)
	if(!S) return 0
	if(S.MechCompatible) return 1
	return (S.type in MECH_COMPATIBLE_SKILLS) ? 1 : 0

mob/proc/MechOwnsSkill(obj/Skills/S)
	var/obj/Items/Mech/R = mech
	if(!R || !S || !R.part_kept) return 0
	for(var/k in R.part_kept)
		if(R.part_kept[k] == S) return 1
	return 0

mob/proc/MechSkillAllowed(obj/Skills/S)
	if(!mech || !S) return 1
	if(MechOwnsSkill(S) || IsMechCompatible(S)) return 1
	return 0

mob/proc/MechPilotSkill(obj/Skills/S)
	if(!mech || !S) return 0
	if(MechOwnsSkill(S)) return 0
	return IsMechCompatible(S)

mob/proc/MechRefuse(what)
	if(what == mech_refuse_what && world.time < mech_refuse_at) return
	mech_refuse_what = what
	mech_refuse_at = world.time + glob.MECH_REFUSE_GAP
	src << "[what] won't work from inside [mech ? mech.name : "a mech"]."

mob/proc/MechTooHot()
	if(mech_refuse_what == "heat" && world.time < mech_refuse_at) return
	mech_refuse_what = "heat"
	mech_refuse_at = world.time + glob.MECH_REFUSE_GAP
	src << "[mech ? mech.name : "Your mech"] is overheated. Let it cool down first."

mob/proc/MechSkillReady(obj/Skills/S)
	if(!S) return 0
	return (S.Using || S.cooldown_remaining) ? 0 : 1

mob/proc/MechPilotSkillHeatMult()
	. = 1
	var/obj/Items/Mech/R = mech
	if(!R) return
	var/list/kit = MechKitRow(R.frame_kit)
	if(kit && isnum(kit["pilot_heat"])) . *= kit["pilot_heat"]
	if(getPilotSync()) . *= glob.MECH_SYNC_HEAT
	for(var/obj/Items/P in R.MechPartsOfKind("Internal"))
		var/m = MechPartVar(P, "pilot_heat_mult")
		if(isnum(m) && m > 0) . *= m

mob/proc/MechPilotSkillHeat(obj/Skills/S)
	var/ec = S ? S.EnergyCost : 0
	return max(glob.MECH_PILOT_HEAT_MIN, ec / glob.MECH_PILOT_HEAT_DIV) * MechPilotSkillHeatMult()

mob/proc/MechPilotSkillFired(obj/Skills/S)
	mech_pilot_skill_until = world.time + glob.MECH_PILOT_SKILL_WINDOW
	HeatAdd(MechPilotSkillHeat(S))

mob/proc/MechPilotSkillAfter(obj/Skills/S, was_ready)
	if(!was_ready || !mech) return
	if(!MechSkillReady(S))
		MechPilotSkillFired(S)
		return
	MechHeatWatch(S)

mob/proc/MechHeatWatch(obj/Skills/S)
	set waitfor = 0
	var/obj/Items/Mech/R = mech
	var/end = world.time + glob.MECH_HEAT_WATCH_DS
	while(S && mech == R && world.time < end)
		sleep(2)
		if(S && mech == R && !MechSkillReady(S))
			MechPilotSkillFired(S)
			return

mob/proc/MechPilotGate(obj/Skills/S)
	if(!MechSkillAllowed(S))
		MechRefuse("[S]")
		return 0
	if(MechPilotSkill(S) && Overheated())
		MechTooHot()
		return 0
	return 1

mob/Players/UseProjectile(var/obj/Skills/Projectile/Z, noGCD = FALSE)
	if(!mech || !Z) return ..()
	if(!MechPilotGate(Z)) return 0
	if(!MechPilotSkill(Z)) return ..()
	var/was_ready = MechSkillReady(Z)
	. = ..()
	MechPilotSkillAfter(Z, was_ready)

mob/Players/Activate(var/obj/Skills/AutoHit/Z, ignoreCuck = FALSE, ignoreAttackLock = FALSE, noGCD = FALSE)
	if(!mech || !Z) return ..()
	if(!MechPilotGate(Z)) return 0
	if(!MechPilotSkill(Z)) return ..()
	var/was_ready = MechSkillReady(Z)
	. = ..()
	MechPilotSkillAfter(Z, was_ready)

mob/Players/SetQueue(var/obj/Skills/Queue/Q, noGCD = FALSE)
	if(!mech || !Q) return ..()
	if(!MechPilotGate(Q)) return 0
	if(!MechPilotSkill(Q)) return ..()
	var/was_ready = MechSkillReady(Q)
	. = ..()
	MechPilotSkillAfter(Q, was_ready)

mob/Players/BeginHeldSkill(var/obj/Skills/Z)
	if(!mech || !Z) return ..()
	if(!MechPilotGate(Z)) return 0
	return ..()

mob/Players/UseBuff(var/obj/Skills/Buffs/B, var/Override, noGCD = FALSE)
	if(!mech || !B || Override || BuffOn(B)) return ..()
	if(!MechSkillAllowed(B))
		if(!istype(B, /obj/Skills/Buffs/SlotlessBuffs/Autonomous)) MechRefuse("[B]")
		return 0
	if(!MechPilotSkill(B)) return ..()
	if(Overheated())
		MechTooHot()
		return 0
	. = ..()
	if(BuffOn(B)) MechPilotSkillFired(B)

mob/Players/SkillX(var/Wut,var/obj/Skills/Z,var/bypass=0,var/noGCD=0,var/TempoBypass=FALSE)
	if(mech && !(Wut in MECH_SKILLX_ALLOWED))
		MechRefuse(istype(Z, /obj/Skills) ? "[Z]" : "[Wut]")
		return FALSE
	return ..()

mob/Players/SkillStunX(var/Wut,var/obj/Skills/Z,var/bypass=0, dontTakeStack = FALSE, TempoBypass = FALSE)
	if(mech)
		MechRefuse(istype(Z, /obj/Skills) ? "[Z]" : "[Wut]")
		return FALSE
	return ..()

mob/Players/PowerUp()
	if(mech)
		MechRefuse("Power Up")
		return 0
	return ..()

mob/Players/PowerDown()
	if(mech)
		MechRefuse("Power Down")
		return 0
	return ..()

mob/Players/Transform(type)
	if(mech)
		MechRefuse("Transforming")
		return 0
	return ..()

mob/Players/attemptShortcut(num)
	if(mech && shortcuts)
		var/obj/Skills/S = shortcuts.vars["shortcut[num]"]
		if(S && !MechSkillAllowed(S))
			MechRefuse("[S]")
			return
	return ..()

mob/Players/MechGrappleBlock(obj/Skills/Grapple/G, mob/Trg)
	if(!mech || !G) return 0
	if(!MechPilotGate(G)) return 1
	if(MechPilotSkill(G)) MechPilotSkillFired(G)
	return 0

mob/Players/MechGrappleWhiff(obj/Skills/Grapple/G, mob/User)
	if(!mech || !G) return 0
	if(G.MechScale || IsMechCompatible(G)) return 0
	if(User)
		User << "[G] can't get a grip on [mech]. It whiffs."
		spawn(0)
			if(User) User.Grab_Release()
	return 1

mob/Players/LoseEnergy(var/val, _static = FALSE)
	if(mech) return
	return ..()
