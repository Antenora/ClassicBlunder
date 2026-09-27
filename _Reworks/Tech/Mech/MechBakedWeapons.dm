obj/Items/Gun/Automatic/Head_Vulcans
	name = "Head Vulcans"
	desc = "The head-mounted vulcan guns built into a Vanguard."
	Class = "Light"
	icon_state = "SMG"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	hands = 0
	heat_per_shot = 2
	heat_cost = 2
	BulletIcon = 'Icons/Blasts/BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 0.8
	ModelAccuracy = 0.9
	ModelSpeed = 1

/obj/Skills/Projectile/Mech/Head_Vulcans
	name = "Head Vulcans"
	desc = "Spray a burst of six rounds from the head-mounted vulcans at your target. Each round costs 2 heat."
	Cooldown = 6
	mech_ranged = 1
	var/vulcan_rounds = 6
	var/vulcan_gap = 1
	var/tmp/obj/Items/Gun/Automatic/Head_Vulcans/vulcan
	verb/Head_Vulcans()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.MechSkillGo(src, noGCD)) return 0
		if(!vulcan) vulcan = new
		Cooldown(1, null, p)
		spawn(0)
			if(p) p.MechVulcanBurst(src)
		return 1

/obj/Skills/AutoHit/Mech/Lunge
	name = "Lunge"
	desc = "Thrust forward 3 tiles and strike whatever you reach."
	Area = "Strike"
	Distance = 1
	StrScaling = 1
	DamageMult = 2
	Cooldown = 6
	mech_heat = 6
	dash_tiles = 3
	dash_ticks = 4
	verb/Lunge()
		set category = "Skills"
		usr.MechPartUse(src)

/obj/Skills/AutoHit/Mech/Iai_Cleave
	name = "Iai Cleave"
	desc = "Draw and cut in one motion: a slash that hits everything on the 4 tiles ahead, then a dash through the line."
	Area = "Wave"
	Distance = 4
	StrScaling = 1
	DamageMult = 2.5
	Cooldown = 10
	mech_heat = 10
	dash_tiles = 4
	dash_ticks = 4
	dash_first = 1
	verb/Iai_Cleave()
		set category = "Skills"
		usr.MechPartUse(src)

/obj/Skills/Projectile/Mech/Twin_Cannon_Volley
	name = "Twin Cannon Volley"
	desc = "Lob two shells over cover onto your target's tile. Each bursts and splashes everything within a tile."
	mech_blasts = 2
	Blasts = 2
	Delay = 2
	Distance = 10
	Speed = 0.5
	ArcShot = 1
	DamageMult = 1.5
	StrScaling = 0
	ForScaling = 1
	EndEffectiveness = 1
	Variation = 0
	mech_splash = 1
	mech_to_target = 1
	Cooldown = 10
	mech_heat = 18
	mech_ranged = 1
	shot_state = "Shot3"
	verb/Twin_Cannon_Volley()
		set category = "Skills"
		usr.MechPartUse(src)

/obj/Skills/Grapple/Mech/Claw_Rend
	name = "Claw Rend"
	desc = "While you hold someone in a grab, pin them under the claws for a moment and rend them so they bleed. Strong enough to hold another mech."
	DamageMult = 2.5
	StrScaling = 1
	Stunner = 1.5
	Bloodletting = 4
	TriggerMessage = "pins and rends"
	Cooldown = 12
	mech_heat = 8
	verb/Claw_Rend()
		set category = "Skills"
		usr.MechPartUse(src)

/obj/Skills/AutoHit/Mech/Heat_Vent
	name = "Heat Vent"
	desc = "Dump 40 heat out of the vents as a 3 tile cone of fire that sets what it touches burning. Works while overheated."
	Area = "Arc"
	Distance = 3
	StrScaling = 0
	ForScaling = 1
	DamageMult = 1.5
	TurfBurn = 6
	Cooldown = 15
	var/vent_heat = 40
	verb/Heat_Vent()
		set category = "Skills"
		usr.MechPartUse(src)
	MechAfterFire(mob/p)
		if(p) p.HeatDrop(vent_heat)

/obj/Skills/Projectile/Mech/Strafing_Run
	name = "Strafing Run"
	desc = "Dash 6 tiles ahead, firing your arm gun at your target on every tile. Without a ranged arm part it is just the dash."
	Cooldown = 12
	var/strafe_tiles = 6
	var/strafe_ticks = 6
	verb/Strafing_Run()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		if(!p.MechSkillGo(src, noGCD)) return 0
		Cooldown(1, null, p)
		spawn(0)
			if(p) p.MechStrafe(src)
		return 1

/obj/Skills/Projectile/Mech/Barrage_Lock
	name = "Barrage Lock"
	desc = "Hold still for 2 seconds while the fire control locks on, then every Back weapon fires in sequence at half heat. Weapons still cooling are skipped."
	HeldSkill = 1
	ChargePeriod = 2
	NoFizzle = 1
	HeldFreeze = 1
	Cooldown = 20
	mech_ranged = 1
	var/barrage_gap = 3
	var/barrage_heat = 0.5
	verb/Barrage_Lock()
		set category = "Skills"
		usr.MechHeldStart(src)
	OnHeldRelease(mob/p, benefit, sweet_spot_hit, charge_level)
		if(p) p.MechHeldRelease(src, benefit)
	MechReleaseFire(mob/p, benefit)
		if(benefit < 1)
			p << "You break off the Barrage Lock before the fire control settles."
			return 0
		Cooldown(1, null, p)
		spawn(0)
			if(p) p.MechBarrage(src)
		return 1

/obj/Skills/Projectile/Mech/Pod_Salvo
	name = "Pod Salvo"
	desc = "Empty the pods: 12 small missiles in a wide spread, 8 tiles out."
	mech_blasts = 12
	Blasts = 12
	Delay = 0.3
	Distance = 8
	Speed = 0.5
	SpreadArc = 50
	DamageMult = 0.35
	StrScaling = 0
	ForScaling = 1
	EndEffectiveness = 1
	Variation = 0
	Explode = 1
	Cooldown = 14
	mech_heat = 30
	mech_ranged = 1
	shot_state = "Shot5"
	verb/Pod_Salvo()
		set category = "Skills"
		usr.MechPartUse(src)

/obj/Skills/AutoHit/Mech/Shield_Bash
	name = "Shield Bash"
	desc = "Lunge one tile behind your shield and knock back whatever you hit."
	Area = "Strike"
	Distance = 1
	StrScaling = 1
	DamageMult = 1.5
	Knockback = 2
	Cooldown = 8
	mech_heat = 5
	dash_tiles = 1
	dash_ticks = 2
	verb/Shield_Bash()
		set category = "Skills"
		usr.MechPartUse(src)

mob/proc/MechVulcanBurst(obj/Skills/Projectile/Mech/Head_Vulcans/S)
	for(var/i = 1 to S.vulcan_rounds)
		if(!S || !S.vulcan || KO || Dead) return
		if(ismob(Target) && Target != src && Target.z == z) GunSetAimAngle(GunTargetAngle(Target))
		if(!FireGun(S.vulcan)) return
		sleep(S.vulcan_gap)

mob/proc/MechStrafe(obj/Skills/Projectile/Mech/Strafing_Run/S)
	var/d = dir
	MechDash(d, S.strafe_tiles, S.strafe_ticks)
	var/gap = max(world.tick_lag, S.strafe_ticks * world.tick_lag / S.strafe_tiles)
	for(var/i = 1 to S.strafe_tiles)
		if(!S || KO || Dead) return
		var/obj/Items/Gun/G = MechActiveGun()
		if(G)
			if(ismob(Target) && Target != src && Target.z == z) GunSetAimAngle(GunTargetAngle(Target))
			FireGun(G)
		sleep(gap)

mob/proc/MechBarrage(obj/Skills/Projectile/Mech/Barrage_Lock/S)
	if(!mech || !S) return
	var/list/done = list()
	for(var/obj/Items/P in mech.MechPartsOfKind("Back"))
		for(var/p in P.Techniques)
			var/t = MechSkillPath(p)
			if(!t || (t in done)) continue
			done += t
			var/obj/Skills/B = mech.part_kept ? mech.part_kept[t] : null
			if(!B) continue
			B.MechBarrageFire(src, S.barrage_heat)
			sleep(S.barrage_gap)
			if(!mech || KO || Dead) return
