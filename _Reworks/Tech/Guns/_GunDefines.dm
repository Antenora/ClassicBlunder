#define GUN_CLASS_HANDGUN "Handgun"
#define GUN_CLASS_AUTOMATIC "Automatic"
#define GUN_CLASS_SHOTGUN "Shotgun"

#define GUN_CALIBER_PISTOL "Pistol"
#define GUN_CALIBER_RIFLE "Rifle"
#define GUN_CALIBER_SHELL "Shell"

#define GUN_HANDGUN_DAMAGE 0.39
#define GUN_HANDGUN_ACCURACY 1.15
#define GUN_HANDGUN_CADENCE 1
#define GUN_HANDGUN_RANGE 7
#define GUN_HANDGUN_SPEED 0.3
#define GUN_HANDGUN_PELLETS 1
#define GUN_HANDGUN_SPREAD 0
#define GUN_HANDGUN_FALLOFF 0
#define GUN_HANDGUN_KNOCKBACK 0
#define GUN_HANDGUN_RELOAD_TICK 2.5
#define GUN_HANDGUN_RELOAD_ROUNDS 1

#define GUN_AUTOMATIC_DAMAGE 0.12
#define GUN_AUTOMATIC_ACCURACY 0.95
#define GUN_AUTOMATIC_CADENCE 0.3333
#define GUN_AUTOMATIC_RANGE 6
#define GUN_AUTOMATIC_SPEED 0.25
#define GUN_AUTOMATIC_PELLETS 1
#define GUN_AUTOMATIC_SPREAD 0
#define GUN_AUTOMATIC_FALLOFF 0
#define GUN_AUTOMATIC_KNOCKBACK 0
#define GUN_AUTOMATIC_RELOAD_TICK 2.5
#define GUN_AUTOMATIC_RELOAD_ROUNDS 3

#define GUN_SHOTGUN_DAMAGE 0.155
#define GUN_SHOTGUN_ACCURACY 0.9
#define GUN_SHOTGUN_CADENCE 1.6
#define GUN_SHOTGUN_RANGE 3
#define GUN_SHOTGUN_SPEED 0.4
#define GUN_SHOTGUN_PELLETS 6
#define GUN_SHOTGUN_SPREAD 45
#define GUN_SHOTGUN_FALLOFF 0.22
#define GUN_SHOTGUN_KNOCKBACK 0.35
#define GUN_SHOTGUN_RELOAD_TICK 6
#define GUN_SHOTGUN_RELOAD_ROUNDS 1

#define GUN_BLOOM_PER_SHOT 0.05
#define GUN_BLOOM_MAX 0.45
#define GUN_BLOOM_DECAY 0.05
#define GUN_BLOOM_GRACE 4

#define GUN_AIM_CONE 20
#define GUN_PISTOL_WHIP 0.5
#define GUN_RELOAD_TICK 2.5
#define GUN_RELOAD_MOVE_PENALTY 2
#define GUN_LANE_CAP 16

#define GUN_MAG_CAP 60
#define GUN_MOD_SLOTS 2
#define GUN_EXTMAG_MULT 1.25
#define GUN_SCOPE_RANGE 2
#define GUN_SCOPE_CONE 10
#define GUN_COMP_BLOOM 0.5
#define GUN_SPEEDLOADER_MULT 0.75
#define GUN_LASER_ACC 0.1
#define GUN_CPU_ACC 0.1
#define GUN_WEAVE_MULT 0.75

#define GUN_TRACER_TIME 200
#define GUN_TRANQ_STACKS 3
#define GUN_TRANQ_WINDOW 50

#define GUN_QUICKDRAW_ROUNDS 1
#define GUN_QUICKDRAW_ACC 1.3
#define GUN_QUICKDRAW_CD 8
#define GUN_FAN_ACC 0.7
#define GUN_FAN_DELAY 0.5
#define GUN_FAN_CD 12
#define GUN_RICOCHET_ROUNDS 2
#define GUN_RICOCHET_RANGE 2
#define GUN_RICOCHET_CD 8
#define GUN_BURST_ROUNDS 3
#define GUN_BURST_SPREAD 6
#define GUN_BURST_CD 6
#define GUN_SUPPRESS_ROUNDS 3
#define GUN_SUPPRESS_RATE 5
#define GUN_SUPPRESS_CONE 30
#define GUN_SUPPRESS_DAMAGE 0.6
#define GUN_SUPPRESS_SLOW 3
#define GUN_SUPPRESS_ACC 0.8
#define GUN_SUPPRESS_TIME 30
#define GUN_SUPPRESS_CD 10
#define GUN_SLUG_ROUNDS 1
#define GUN_SLUG_RANGE 6
#define GUN_SLUG_CD 6
#define GUN_POINTBLANK_ROUNDS 1
#define GUN_POINTBLANK_REACH 1
#define GUN_POINTBLANK_KB 2
#define GUN_POINTBLANK_SHATTER 1
#define GUN_POINTBLANK_CD 10
#define GUN_UNDERBARREL_CD 6
#define GUN_BAYONET_BLEED 1

#define GUN_ROUNDS_PER_RUN 20
#define GUN_SHELLS_PER_RUN 10
#define GUN_TRAINING_PER_RUN 30

#define GUN_MODROW_X 252
#define GUN_MODROW_Y 162
#define GUN_MODROW_STEP 22
#define GUN_MODROW_W 120

/proc/GunClassDamage(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_DAMAGE
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_DAMAGE
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_DAMAGE
	return GUN_HANDGUN_DAMAGE

/proc/GunClassAccuracy(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_ACCURACY
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_ACCURACY
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_ACCURACY
	return GUN_HANDGUN_ACCURACY

/proc/GunClassCadence(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_CADENCE
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_CADENCE
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_CADENCE
	return GUN_HANDGUN_CADENCE

/proc/GunClassRange(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_RANGE
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_RANGE
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_RANGE
	return GUN_HANDGUN_RANGE

/proc/GunClassSpeed(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_SPEED
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_SPEED
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_SPEED
	return GUN_HANDGUN_SPEED

/proc/GunClassPellets(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_PELLETS
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_PELLETS
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_PELLETS
	return GUN_HANDGUN_PELLETS

/proc/GunClassSpread(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_SPREAD
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_SPREAD
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_SPREAD
	return GUN_HANDGUN_SPREAD

/proc/GunClassFalloff(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_FALLOFF
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_FALLOFF
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_FALLOFF
	return GUN_HANDGUN_FALLOFF

/proc/GunClassKnockback(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_KNOCKBACK
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_KNOCKBACK
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_KNOCKBACK
	return GUN_HANDGUN_KNOCKBACK

/proc/GunClassReloadTick(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_RELOAD_TICK
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_RELOAD_TICK
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_RELOAD_TICK
	return GUN_RELOAD_TICK

/proc/GunClassReloadRounds(gclass)
	switch(gclass)
		if(GUN_CLASS_HANDGUN)
			return GUN_HANDGUN_RELOAD_ROUNDS
		if(GUN_CLASS_AUTOMATIC)
			return GUN_AUTOMATIC_RELOAD_ROUNDS
		if(GUN_CLASS_SHOTGUN)
			return GUN_SHOTGUN_RELOAD_ROUNDS
	return GUN_HANDGUN_RELOAD_ROUNDS

/proc/GunReloadMovePenalty()
	return GUN_RELOAD_MOVE_PENALTY

/proc/GunPistolWhipMult()
	return GUN_PISTOL_WHIP

/proc/GunAimCone()
	return GUN_AIM_CONE

/proc/GunLaneCap()
	return GUN_LANE_CAP

/proc/GunDirAngle(d)
	switch(d)
		if(EAST)
			return 0
		if(NORTHEAST)
			return 45
		if(NORTH)
			return 90
		if(NORTHWEST)
			return 135
		if(WEST)
			return 180
		if(SOUTHWEST)
			return 225
		if(SOUTH)
			return 270
		if(SOUTHEAST)
			return 315
	return 270

/proc/GunAngleDir(a)
	var/n = a
	while(n < 0)
		n += 360
	while(n >= 360)
		n -= 360
	if(n < 22.5 || n >= 337.5)
		return EAST
	if(n < 67.5)
		return NORTHEAST
	if(n < 112.5)
		return NORTH
	if(n < 157.5)
		return NORTHWEST
	if(n < 202.5)
		return WEST
	if(n < 247.5)
		return SOUTHWEST
	if(n < 292.5)
		return SOUTH
	return SOUTHEAST

/proc/GunAngleCardinal(a)
	var/n = a
	while(n < 0)
		n += 360
	while(n >= 360)
		n -= 360
	if(n < 45 || n >= 315)
		return EAST
	if(n < 135)
		return NORTH
	if(n < 225)
		return WEST
	return SOUTH

/proc/GunAngleDelta(a, b)
	var/d = a - b
	while(d <= -180)
		d += 360
	while(d > 180)
		d -= 360
	return abs(d)

/proc/GunMetalTraits(mid)
	switch(mid)
		if("copper")
			return list(0.9, 1.0, 1.1)
		if("tin")
			return list(0.85, 1.0, 1.15)
		if("bronze")
			return list(1.0, 1.0, 1.05)
		if("iron")
			return list(1.0, 1.0, 1.0)
		if("steel")
			return list(1.1, 1.0, 0.95)
		if("silver")
			return list(1.0, 1.1, 1.0)
		if("gold")
			return list(1.05, 1.05, 0.9)
		if("cobalt")
			return list(1.1, 1.05, 1.0)
		if("mythril")
			return list(1.0, 1.1, 1.15)
		if("adamantite")
			return list(1.2, 1.0, 0.95)
		if("starmetal")
			return list(1.2, 1.1, 1.05)
		if("orichalcum")
			return list(1.15, 1.1, 1.1)
	return list(1, 1, 1)

/proc/GunSuppressAccMult()
	return GUN_SUPPRESS_ACC

mob/proc/GunHitMult(mob/victim, obj/Skills/Projectile/_Projectile/P)
	return MaimMult("WeaponDamage")

mob/proc/GunOnHit(mob/victim, obj/Skills/Projectile/_Projectile/P)
	return

obj/Skills/Projectile/var/tmp/ki_blasts = 0
obj/Skills/Projectile/var/tmp/ki_shots = 0
obj/Skills/Projectile/var/tmp/list/ki_stamp

var/list/KI_SKILL_EXCLUDED = list(/obj/Skills/Projectile/Gear, /obj/Skills/Projectile/Mech, /obj/Skills/Projectile/Ordnance, /obj/Skills/Projectile/Sword, /obj/Skills/Projectile/Hado, /obj/Skills/Projectile/Bakudo, /obj/Skills/Projectile/Ninjutsu, /obj/Skills/Projectile/Staff_Projectile, /obj/Skills/Projectile/Magic,\
	/obj/Skills/Projectile/DemiFiend,\
	/obj/Skills/Projectile/Air_Blades, /obj/Skills/Projectile/Bakudantsuki, /obj/Skills/Projectile/Benihiko, /obj/Skills/Projectile/Bushogoma, /obj/Skills/Projectile/Taimatsu_Inferno,\
	/obj/Skills/Projectile/Beams/Excalibur, /obj/Skills/Projectile/Beams/Excalibur_Morgan, /obj/Skills/Projectile/ExcaliburProjectile, /obj/Skills/Projectile/ExcaliburMProjectile, /obj/Skills/Projectile/Crystal_Rose_Glass, /obj/Skills/Projectile/BlazingSlashProjectile,\
	/obj/Skills/Projectile/Feathers, /obj/Skills/Projectile/GodSlayer, /obj/Skills/Projectile/Quincy, /obj/Skills/Projectile/Atlatl, /obj/Skills/Projectile/Blade_Addition, /obj/Skills/Projectile/Stake, /obj/Skills/Projectile/Secret_Knives, /obj/Skills/Projectile/Khonshu, /obj/Skills/Projectile/FTG, /obj/Skills/Projectile/UltimaLaser, /obj/Skills/Projectile/ChaosKnife, /obj/Skills/Projectile/Hundred_Knives, /obj/Skills/Projectile/Senbon,\
	/obj/Skills/Projectile/Arcane_Blast, /obj/Skills/Projectile/Arcane_Burst, /obj/Skills/Projectile/Arcane_Cluster, /obj/Skills/Projectile/Arcane_Discharge, /obj/Skills/Projectile/Arcane_Explosion, /obj/Skills/Projectile/Arcane_Fist_Discharge, /obj/Skills/Projectile/Arcane_Landmine, /obj/Skills/Projectile/Arcane_Micro_Singularity, /obj/Skills/Projectile/Arcane_Singularity, /obj/Skills/Projectile/Arcane_Spray, /obj/Skills/Projectile/Arcane_Whirlwind, /obj/Skills/Projectile/Beams/Arcane_Bullet, /obj/Skills/Projectile/GravityTornado, /obj/Skills/Projectile/Heavy_Discharge,\
	/obj/Skills/Projectile/Beams/Hyper_Beam, /obj/Skills/Projectile/Beams/TasteTheRainbow, /obj/Skills/Projectile/Beams/Unbelievable_Rage, /obj/Skills/Projectile/Burning_Black, /obj/Skills/Projectile/ChaosBusterShot, /obj/Skills/Projectile/SuperChaosBusterShot, /obj/Skills/Projectile/ChaosSaberToss, /obj/Skills/Projectile/ChaosSaberWave, /obj/Skills/Projectile/Devilsbuster, /obj/Skills/Projectile/Red_Buster, /obj/Skills/Projectile/Rude_Buster, /obj/Skills/Projectile/RoaringCrescentWave, /obj/Skills/Projectile/Royal_Flames, /obj/Skills/Projectile/Zone_Attacks/Final_Chaos,\
	/obj/Skills/Projectile/Gates_of_Babylon, /obj/Skills/Projectile/Enkidu_Chains,\
	/obj/Skills/Projectile/Beams/ChaosBlaster, /obj/Skills/Projectile/Bubblebeam, /obj/Skills/Projectile/Fire_Blast, /obj/Skills/Projectile/Inferno, /obj/Skills/Projectile/HelfireInferno,\
	/obj/Skills/Projectile/Machine_Gun_Burst, /obj/Skills/Projectile/Homing_Ray_Missiles, /obj/Skills/Projectile/Plasma_Cannon, /obj/Skills/Projectile/Cyberize, /obj/Skills/Projectile/GunKataShot, /obj/Skills/Projectile/SmallLemonThing, /obj/Skills/Projectile/BIG_SHOT)
var/list/ki_skill_cache = list()

/proc/IsKiSkill(obj/Skills/Projectile/S)
	if(!istype(S, /obj/Skills/Projectile))
		return 0
	if(S.NeedsGun || S.IsSpell || S.MagicNeeded || S.NeedsSword || S.ChakraNature)
		return 0
	var/t = S.type
	. = ki_skill_cache[t]
	if(isnull(.))
		. = 1
		for(var/x in KI_SKILL_EXCLUDED)
			if(ispath(t, x) || findtext("[t]", "[x]/") == 1)
				. = 0
				break
		ki_skill_cache[t] = .

mob/proc/KiStampPassives(obj/Skills/Projectile/S)
	return

mob/proc/KiStampShot(obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/Z)
	return

mob/proc/KiHitMult(mob/victim, obj/Skills/Projectile/_Projectile/P)
	return 1

mob/proc/KiOnHit(mob/victim, obj/Skills/Projectile/_Projectile/P, hit = 0)
	return

#define GUN_ENERGY_MAX 100
#define GUN_ENERGY_DAMAGE 0.85
#define GUN_ENERGY_PIERCE 0.25
#define GUN_HANDGUN_ENERGY 4
#define GUN_AUTOMATIC_ENERGY 1
#define GUN_SHOTGUN_ENERGY 6
#define GUN_HANDGUN_HEAT 12
#define GUN_AUTOMATIC_HEAT 3.5
#define GUN_SHOTGUN_HEAT 18
#define GUN_HEAT_MAX 100
#define GUN_HEAT_POLL 10
#define GUN_HEAT_DISSIPATION 8
#define MECH_HEAT_DISSIPATION 10
#define GUN_HEAT_WARN_GAP 20
#define GUN_BATTERY_PER_RUN 1
#define GUN_BATTERY_SWAP_ROUNDS 10
#define GUN_AM_DEVICE_MULT 1.4
#define GUN_AM_BODY_MULT 0.7

mob/proc/HeatSource()
	return null

mob/proc/HeatNow()
	return 0

mob/proc/HeatMax()
	return GUN_HEAT_MAX

mob/proc/HeatAdd(n)
	return 0

mob/proc/HeatDissipation()
	return 0

mob/proc/Overheated()
	return 0

mob/proc/HeatClear()
	return

mob/proc/MechHeatMaxMult()
	return 1

mob/proc/MechDissipationMult()
	return 1

mob/proc/MechDissipationFlat()
	return 0

mob/proc/MechHeatCostMult()
	return 1

mob/proc/GunBatteryReload(obj/Items/Gun/G)
	return 0

mob/proc/GunAMMult(atom/victim, obj/Skills/Projectile/_Projectile/P)
	return 1
