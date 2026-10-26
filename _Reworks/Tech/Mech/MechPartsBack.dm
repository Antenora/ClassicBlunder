/obj/Items/MechPart/Back
	Missile_Pod
		name = "Missile Pod"
		icon = 'Icons/Technology/Gear/MissileSmall.dmi'
		icon_state = ""
		desc = "A shoulder missile pod for a mech's Back. Grants Missile Pod: a salvo of 6 missiles that fan out, then home on your target. 25 heat."
		heat_cost = 25
		Techniques = list(/obj/Skills/Projectile/Mech/Missile_Pod)

	Micro_Missile_Swarm
		name = "Micro-Missile Swarm"
		icon = 'Icons/Technology/Gear/MissileSmall.dmi'
		icon_state = ""
		desc = "A rack of micro-missiles for a mech's Back. Grants Micro-Missile Swarm: 12 light missiles in a wide fan that home on your target. 30 heat."
		part_tier = MECH_TIER_WALKER
		heat_cost = 30
		Techniques = list(/obj/Skills/Projectile/Mech/Micro_Missile_Swarm)

	Shoulder_Cannon
		name = "Shoulder Cannon"
		icon = 'Icons/Other/Guns.dmi'
		icon_state = "Rocket Launcher"
		desc = "A heavy cannon for a mech's Back. Grants Shoulder Cannon: one direct-fire shell that knocks its target back. 18 heat."
		heat_cost = 18
		Techniques = list(/obj/Skills/Projectile/Mech/Shoulder_Cannon)

	Grenade_Rack
		name = "Grenade Rack"
		icon = 'Icons/Technology/device.dmi'
		icon_state = "timer"
		desc = "A grenade launcher for a mech's Back. Grants Grenade Rack: a grenade lobbed over cover that bursts across a tile. 15 heat."
		heat_cost = 15
		Techniques = list(/obj/Skills/Projectile/Mech/Grenade_Rack)

	Mega_Particle_Cannon
		name = "Mega Particle Cannon"
		icon = 'Icons/Other/Guns.dmi'
		icon_state = "Plasma Cannon"
		desc = "A particle cannon that takes both of a mech's Backs. Grants Mega Particle Cannon: a wide energy sweep 3 tiles ahead that punches through part of the target's armor. 45 heat."
		part_tier = MECH_TIER_WALKER
		paired = 1
		heat_cost = 45
		Techniques = list(/obj/Skills/AutoHit/Mech/Mega_Particle_Cannon)

	Satellite_Cannon
		name = "Satellite Cannon"
		icon = 'Icons/Technology/Tech.dmi'
		icon_state = "Emissor"
		desc = "A reflector cannon that takes both of a mech's Backs. Grants Satellite Cannon: hold its key to channel, release to fire a beam as long as the screen. Fills the heat gauge."
		part_tier = MECH_TIER_WALKER
		paired = 1
		heat_cost = 100
		Techniques = list(/obj/Skills/Projectile/Beams/Mech/Satellite_Cannon)

/obj/Skills/Projectile/Mech
	Missile_Pod
		name = "Missile Pod"
		desc = "Launch a salvo of 6 missiles. They fan out, then home on your target."
		mech_back = 1
		mech_missile = 1
		mech_blasts = 6
		Blasts = 6
		Delay = 0.5
		Distance = 10
		Speed = 0.5
		SpreadArc = 35
		HomingCharge = 1
		HomingDelay = 3
		DamageMult = 0.6
		StrScaling = 0
		ForScaling = 1
		EndEffectiveness = 1
		AccMult = 1.1
		Variation = 0
		Explode = 1
		Cooldown = 12
		mech_heat = 25
		mech_ranged = 1
		shot_state = "Shot5"
		verb/Missile_Pod()
			set category = "Skills"
			usr.MechPartUse(src)

	Micro_Missile_Swarm
		name = "Micro-Missile Swarm"
		desc = "Launch 12 light missiles in a wide fan. They home on your target."
		mech_back = 1
		mech_missile = 1
		mech_blasts = 12
		Blasts = 12
		Delay = 0.3
		Distance = 10
		Speed = 0.45
		SpreadArc = 60
		HomingCharge = 1
		HomingDelay = 2
		DamageMult = 0.35
		StrScaling = 0
		ForScaling = 1
		EndEffectiveness = 1
		AccMult = 1.1
		Variation = 0
		Explode = 1
		Cooldown = 14
		mech_heat = 30
		mech_ranged = 1
		shot_state = "Shot5"
		verb/Micro_Missile_Swarm()
			set category = "Skills"
			usr.MechPartUse(src)

	Shoulder_Cannon
		name = "Shoulder Cannon"
		desc = "Fire one heavy shell straight at your target. It knocks back what it hits."
		mech_back = 1
		mech_blasts = 1
		Blasts = 1
		Delay = 1
		Distance = 12
		Speed = 0.35
		DamageMult = 3
		StrScaling = 0
		ForScaling = 1
		EndEffectiveness = 1
		AccMult = 1.1
		Knockback = 2
		Variation = 0
		Explode = 1
		Cooldown = 8
		mech_heat = 18
		mech_ranged = 1
		shot_state = "Shot3"
		verb/Shoulder_Cannon()
			set category = "Skills"
			usr.MechPartUse(src)

	Grenade_Rack
		name = "Grenade Rack"
		desc = "Lob a grenade over cover. It bursts where it lands and splashes everything within a tile."
		mech_back = 1
		mech_blasts = 1
		Blasts = 1
		Delay = 1
		Distance = 6
		Speed = 0.6
		ArcShot = 1
		DamageMult = 0.5
		StrScaling = 0
		ForScaling = 1
		EndEffectiveness = 1
		Variation = 0
		mech_splash = 1
		mech_to_target = 1
		Cooldown = 10
		mech_heat = 15
		mech_ranged = 1
		shot_file = 'Icons/Technology/device.dmi'
		shot_state = "timer"
		verb/Grenade_Rack()
			set category = "Skills"
			usr.MechPartUse(src)

/obj/Skills/AutoHit/Mech/Mega_Particle_Cannon
	name = "Mega Particle Cannon"
	desc = "Sweep a wide cone of energy 3 tiles ahead. It punches through part of the target's armor."
	Area = "Arc"
	Distance = 3
	StrScaling = 0
	ForScaling = 1
	DamageMult = 3
	EndEffectiveness = 0.75
	Cooldown = 12
	mech_heat = 45
	mech_ranged = 1
	verb/Mega_Particle_Cannon()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		DamageMult = MechBaseDamage() * p.MechBackWeaponMult() * p.MechEnergyShotMult()
		Distance = initial(Distance) + p.MechBackWeaponReach()
		Rounds = initial(Rounds) + p.MechBackShotBonus()
		return ..()

/obj/Skills/Projectile/Beams/Mech/Satellite_Cannon
	name = "Satellite Cannon"
	desc = "Hold to channel the Satellite Cannon, release to fire a beam as long as the screen. Firing it fills the heat gauge."
	HeldSkill = 1
	HeldBeam = 1
	IconLock = 'Icons/Beams/Beam14.dmi'
	ChargePeriod = 2
	BeamTime = 10
	Distance = 20
	DamageMult = 1.2
	Knockback = 1
	Cooldown = 8
	mech_heat = 100
	mech_back = 1
	CritEffectiveness = 0
	verb/Satellite_Cannon()
		set category = "Skills"
		usr.MechHeldStart(src)
