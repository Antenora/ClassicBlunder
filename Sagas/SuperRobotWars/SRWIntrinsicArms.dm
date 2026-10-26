obj/Items/MechPart/Arm/Rocket_Punch/IntrinsicPhotonicRocketPunch
	name = "Photonic Rocket Punch"
	desc = "A personal Rocket Punch arm unlocked through the SRW skill tree. Grants additional skills with RocketPunchMastery."
	intrinsic_template_id = "photonic_rocket_punch"
	Grabbable = 0

datum/mech_intrinsic_part/PhotonicRocketPunch
	id = "photonic_rocket_punch"
	name = "Photonic Rocket Punch"
	description = "Replaces one arm with a personal Rocket Punch arm. Grants additional skills with RocketPunchMastery."
	slot_family = "Arm"
	part_type = /obj/Items/MechPart/Arm/Rocket_Punch/IntrinsicPhotonicRocketPunch

	ExtraSkillPaths(mob/Owner, obj/Items/Mech/R, list/state)
		var/list/out = list()
		if(!Owner) return out
		if(Owner.passive_handler.Get("RocketPunchMastery") >= 1)
			out += /obj/Skills/Projectile/Mech/Reinforced_Rocket_Punch
		if(Owner.passive_handler.Get("RocketPunchMastery") >= 2)
			out += /obj/Skills/Projectile/Mech/Giant_Swing_Rocket_Punch
		return out

/obj/Skills/Projectile/Mech
	Reinforced_Rocket_Punch
		name = "Reinforced Rocket Punch"
		desc = "A stronger version of the Rocket Punch. It knocks back what it hits and flies home to your arm."
		IconLock = 'Icons/Technology/Gear/ImpactGloves.dmi'
		Distance = 10
		Speed = 0.5
		DamageMult = 5.5
		StrScaling = 1
		ForScaling = 0
		Knockback = 2
		Variation = 0
		Cooldown = 10
		mech_heat = 10
		mech_ranged = 1
		verb/Reinforced_Rocket_Punch()
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

	Giant_Swing_Rocket_Punch
		name = "Giant Swing Rocket Punch"
		desc = "Hold to swing your arm and release to fire a high-speed rocket punch. It knocks back what it hits and flies home to your arm."
		IconLock = 'Icons/Technology/Gear/ImpactGloves.dmi'
		Distance = 10
		Speed = 0.5
		DamageMult = 2.5
		StrScaling = 1
		ForScaling = 0
		Knockback = 2
		HeldSkill=1
		ChargePeriod=3
		Variation = 0
		Cooldown = 10
		mech_heat = 10
		mech_ranged = 1
		verb/Giant_Swing_Rocket_Punch()
			set category = "Skills"
			usr.MechHeldStart(src)
		OnHeldRelease(mob/p, benefit, sweet_spot_hit, charge_level)
			if(p) return p.MechHeldRelease(src, benefit)
		MechReleaseFire(mob/p, benefit)
			if(!p) return 0
			var/charge = clamp(benefit, 0, 1)
			MechStampSalvo(p)
			DamageMult += charge * 10
			Distance = 10+(charge*10)
			Speed = max(0.1, initial(Speed) - charge * 0.4)
			p.MechAimSkill(src)
			. = p.UseProjectile(src, noGCD = TRUE)
			FlightAngle = null
			DirOverride = 0
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
