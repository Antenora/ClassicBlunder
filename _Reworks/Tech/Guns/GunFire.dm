obj/Skills/Projectile/Gunfire
	name = "Gunfire"
	NoGCD = 1
	NoChargeRegen = 1
	NeedsGun = 1
	Cooldown = 0
	AccMult = 1
	DamageMult = 1
	UsesOff = 1
	StrScaling = 0
	ForScaling = 0
	EndEffectiveness = 1
	Blasts = 1
	Instant = 1
	Distance = 7
	Speed = 0.3
	Striking = 1
	AttackReplace = 1
	Variation = 6
	Radius = 0
	IconLock = 'BlastTracer.dmi'
	IconSize = 0.5
	MaxCharges = 1
	Charges = 0
	ChargeRefresh = 0

mob/proc/FireGun(obj/Items/Gun/g)
	if(!g)
		return 0
	var/charged = g.energy_gun || g.mech_only
	if(charged)
		if(Overheated())
			GunHeatWarn(g)
			return 0
		g.EnergySync()
	if(g.Loaded <= 0)
		return 0
	var/obj/Skills/Projectile/Gunfire/gf = locate(/obj/Skills/Projectile/Gunfire, Projectiles)
	if(!gf)
		src.AddSkill(new/obj/Skills/Projectile/Gunfire)
		gf = locate(/obj/Skills/Projectile/Gunfire, Projectiles)
	if(!gf)
		return 0
	var/bloom = 0
	if(g.GunClass == GUN_CLASS_AUTOMATIC)
		bloom = GunBloomPenalty()
	GunStampShot(gf, g, bloom)
	GunStampPassives(gf, g, bloom)
	var/ang = GunAimAngleNow()
	GunFaceShot(ang)
	gf.FlightAngle = ang
	gf.DirOverride = GunAngleDir(ang)
	gf.LaunchOffX = 0
	gf.LaunchOffY = 0
	gf.MaxCharges = charged ? 1 : g.MagSize
	gf.Charges = charged ? 1 : g.Loaded
	gf.Using = 0
	. = src.UseProjectile(gf, TRUE)
	if(.)
		gun_last_fire = world.time
	if(charged)
		if(.)
			GunChargedShot(g)
		gf.MaxCharges = g.MagSize
		gf.Charges = g.Loaded
		gf.Using = 0
	else
		g.Loaded = max(0, min(gf.Charges, g.MagSize))
	gf.DirOverride = 0
	gf.FlightAngle = null
	gf.LaunchOffX = 0
	gf.LaunchOffY = 0
	if(g.GunClass == GUN_CLASS_AUTOMATIC)
		GunAddBloom(bloom, GUN_BLOOM_PER_SHOT * g.ModBloomMult())
	if(g.Loaded <= 0)
		gf.Using = 1
	if(client)
		client.RefreshHotbarCharges()
		client.RefreshAmmoHUD()
	return .

obj/Skills/Projectile/var/tmp/gun_ammo
obj/Skills/Projectile/var/tmp/gun_energy = 0
obj/Skills/Projectile/var/tmp/mech_splash = 0
/mob/var/tmp/gun_heat_warned = 0

mob/proc/GunChargedShot(obj/Items/Gun/g)
	if(g.energy_gun && !g.mech_only)
		g.energy = max(0, g.energy - g.energy_per_shot)
	g.EnergyReset()
	if(g.heat_per_shot > 0)
		HeatAdd(g.heat_per_shot)
	if(g.mech_only)
		MechHandAdvance(g)

mob/proc/GunHeatWarn(obj/Items/Gun/g)
	if(gun_heat_warned > world.time)
		return
	gun_heat_warned = world.time + GUN_HEAT_WARN_GAP
	src << "Your [g.name] is still overheated. It fires again once it cools completely."

mob/proc/GunStampShot(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	if(!S || !g)
		return
	var/cpu = passive_handler.Get("Targeting CPU")
	if(cpu > 0)
		bloom /= 1 + cpu
	else
		cpu = 0
	S.DamageMult = g.ClassDamage()
	S.AccMult = max(g.ClassAccuracy() + g.ModAcc() + cpu * GUN_CPU_ACC - bloom, 0.1)
	S.Speed = GunClassSpeed(g.GunClass)
	S.Distance = g.ClassRange()
	S.Blasts = GunClassPellets(g.GunClass)
	S.SpreadArc = GunClassSpread(g.GunClass)
	S.DamageFalloff = GunClassFalloff(g.GunClass)
	S.Knockback = GunClassKnockback(g.GunClass)
	S.IconLock = g.BulletIcon
	S.IconSize = g.BulletSize
	S.LockX = g.BulletLockX
	S.LockY = g.BulletLockY
	S.HitboxW = g.BulletHitW
	S.HitboxH = g.BulletHitH
	S.FireOffsetX = g.MuzzleX
	S.FireOffsetY = g.MuzzleY
	GunStampRiders(S, g)

mob/proc/GunStampRiders(obj/Skills/Projectile/S, obj/Items/Gun/g)
	S.gun_ammo = g.LoadedType
	S.gun_energy = g.energy_gun
	S.Deflectable = g.energy_gun ? 0 : initial(S.Deflectable)
	S.Bloodletting = 0
	S.TurfBurn = 0
	S.TurfMud = 0
	S.NoInjury = 0
	S.EndEffectiveness = 1
	if(g.energy_gun)
		S.gun_ammo = null
		S.EndEffectiveness = 1 - GUN_ENERGY_PIERCE
		return
	if(!ispath(g.LoadedType, /obj/Items/Ammo))
		return
	var/obj/Items/Ammo/A = g.LoadedType
	S.DamageMult *= initial(A.RiderDamageMult)
	S.AccMult *= initial(A.RiderAccMult)
	S.Bloodletting = initial(A.RiderBleed)
	S.TurfBurn = initial(A.RiderBurn)
	S.EndEffectiveness = 1 - initial(A.RiderPierce)
	S.NoInjury = initial(A.RiderNoInjury)
	if(initial(A.RiderSlug))
		GunSlugStamp(S, g)

/proc/GunSlugStamp(obj/Skills/Projectile/S, obj/Items/Gun/g)
	S.DamageMult *= max(1, S.Blasts)
	S.Blasts = 1
	S.SpreadArc = 0
	S.DamageFalloff = 0
	S.Distance = GUN_SLUG_RANGE + g.ModRange()

mob/proc/GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
	return

mob/GunHitMult(mob/victim, obj/Skills/Projectile/_Projectile/P)
	. = ..()
	if(P && P.gun_energy)
		. *= GUN_ENERGY_DAMAGE
	. *= GunAMMult(victim, P)

mob/proc/GunSetupPunch(mob/victim)
	return 1

mob/proc/GunIntercept(obj/Skills/Projectile/_Projectile/P)
	return 0

mob/proc/GunWhipReach()
	for(var/mob/M in get_step(src, dir))
		if(M == src || !M.density)
			continue
		if(istype(M, /mob/irlNPC))
			continue
		return 1
	for(var/mob/M in BodyReachMobs())
		if(M == src || istype(M, /mob/irlNPC))
			continue
		return 1
	return 0

mob/proc/GunWhip()
	if(!EquippedGun())
		return 0
	if(!GunWhipReach())
		return 0
	Melee1(WhipOnly = 1)
	return 1
