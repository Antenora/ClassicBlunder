#define GUN_QUICKHANDS_STEP 0.25
#define GUN_QUICKHANDS_FLOOR 0.4
#define GUN_BELTFED_STEP 0.2

/mob/var/obj/Items/Gun/equippedGun
/mob/var/tmp/Reloading = 0
/mob/var/tmp/gun_bloom = 0
/mob/var/tmp/gun_last_shot = 0
/mob/var/tmp/gun_last_fire = 0
/mob/var/tmp/gun_last_move = 0
/mob/var/tmp/gun_melee_at = 0

obj/Items/Gun
	icon = 'Icons/Other/Guns.dmi'
	var/GunClass = GUN_CLASS_HANDGUN
	var/MagSize = 10
	var/Loaded = 0
	var/LoadedType
	var/Caliber = GUN_CALIBER_PISTOL
	var/list/mods = list()
	var/tmp/DryWarned = 0
	var/BulletIcon = 'BlastTracer.dmi'
	var/BulletSize = 1
	var/BulletLockX = 0
	var/BulletLockY = 0
	var/BulletHitW = 12
	var/BulletHitH = 32
	var/MuzzleX = 0
	var/MuzzleY = 0
	var/ModelDamage = 1
	var/ModelAccuracy = 1
	var/ModelSpeed = 1
	var/energy_gun = 0
	var/energy = GUN_ENERGY_MAX
	var/energy_per_shot = 0
	var/heat_per_shot = 0
	var/mech_only = 0

obj/Items/Gun/New()
	..()
	if(!mods)
		mods = list()
	setStatLine()
	EnergyReset()

obj/Items/Gun/proc/EnergyShots()
	if(!energy_gun || energy_per_shot <= 0)
		return 0
	return round(energy / energy_per_shot)

obj/Items/Gun/proc/EnergyReset()
	if(mech_only)
		Loaded = 1
		MagSize = 1
		return
	if(!energy_gun)
		return
	Loaded = EnergyShots()
	MagSize = max(1, Loaded)

obj/Items/Gun/proc/EnergySync()
	if(energy_gun && !mech_only)
		var/s = EnergyShots()
		if(Loaded < s)
			energy = max(0, energy - (s - Loaded) * energy_per_shot)
	EnergyReset()

obj/Items/Gun/setStatLine()
	..()
	DamageEffectiveness *= ModelDamage
	AccuracyEffectiveness *= ModelAccuracy
	SpeedEffectiveness *= ModelSpeed
	if(!metal_id)
		return
	var/list/t = GunMetalTraits(metal_id)
	var/f = LIFE_GEARQ_SCALE[QualityClamp(CraftQuality)]
	DamageEffectiveness *= 1 + (t[1] - 1) * f
	AccuracyEffectiveness *= 1 + (t[2] - 1) * f
	SpeedEffectiveness *= 1 + (t[3] - 1) * f
	if(CraftQuality == QUAL_LEGENDARY)
		DamageEffectiveness *= LIFE_LEG_AUGMENT
		AccuracyEffectiveness *= LIFE_LEG_AUGMENT
		SpeedEffectiveness *= LIFE_LEG_AUGMENT
	SpeedEffectiveness = max(SpeedEffectiveness, 0.05)

obj/Items/Gun/proc/ClassDamage()
	return GunClassDamage(GunClass) * (DamageEffectiveness ? DamageEffectiveness : 1)

obj/Items/Gun/proc/ClassAccuracy()
	return GunClassAccuracy(GunClass) * (AccuracyEffectiveness ? AccuracyEffectiveness : 1)

obj/Items/Gun/proc/FireDelay(delay)
	var/spd = SpeedEffectiveness ? SpeedEffectiveness : 1
	return delay * GunClassCadence(GunClass) / max(spd, 0.1)

obj/Items/Gun/proc/ClassRange()
	return GunClassRange(GunClass) + ModRange()

obj/Items/Gun/proc/AimCone()
	return GunAimCone() + ModCone()

obj/Items/Gun/proc/PistolWhipMult()
	return GunPistolWhipMult()

obj/Items/Gun/proc/ReloadTick(mob/user)
	. = GunClassReloadTick(GunClass) * ModReloadMult()
	var/v = (user && user.passive_handler) ? user.passive_handler.Get("Quick Hands") : 0
	if(v > 0)
		. *= max(GUN_QUICKHANDS_FLOOR, 1 - GUN_QUICKHANDS_STEP * v)

obj/Items/Gun/proc/ReloadRounds()
	return GunClassReloadRounds(GunClass)

obj/Items/Gun/proc/HasMod(path)
	for(var/obj/Items/GunMod/M in mods)
		if(istype(M, path))
			return M
	return null

obj/Items/Gun/proc/ModRange()
	. = 0
	for(var/obj/Items/GunMod/M in mods)
		. += M.mod_range

obj/Items/Gun/proc/ModCone()
	. = 0
	for(var/obj/Items/GunMod/M in mods)
		. += M.mod_cone

obj/Items/Gun/proc/ModAcc()
	. = 0
	for(var/obj/Items/GunMod/M in mods)
		. += M.mod_acc

obj/Items/Gun/proc/ModBloomMult()
	. = 1
	for(var/obj/Items/GunMod/M in mods)
		. *= M.mod_bloom_mult

obj/Items/Gun/proc/ModReloadMult()
	. = 1
	for(var/obj/Items/GunMod/M in mods)
		. *= M.mod_reload_mult

obj/Items/Gun/proc/ModMagMult()
	. = 1
	for(var/obj/Items/GunMod/M in mods)
		. *= M.mod_mag_mult

obj/Items/Gun/proc/ModSilent()
	for(var/obj/Items/GunMod/M in mods)
		if(M.mod_silent)
			return 1
	return 0

obj/Items/Gun/proc/EffMagSize(mob/user)
	if(mech_only)
		return 1
	if(energy_gun)
		return max(1, EnergyShots())
	var/mult = ModMagMult()
	var/v = (user && user.passive_handler) ? user.passive_handler.Get("Belt Fed") : 0
	if(v > 0)
		mult *= 1 + GUN_BELTFED_STEP * v
	return clamp(round(initial(MagSize) * mult), 1, GUN_MAG_CAP)

obj/Items/Gun/proc/GunMagFor()
	return EffMagSize(ismob(loc) ? loc : null)

obj/Items/Gun/proc/SyncMag(mob/M)
	MagSize = GunMagFor()
	if(Loaded <= MagSize)
		return 0
	var/extra = Loaded - MagSize
	Loaded = MagSize
	var/p = ispath(LoadedType, /obj/Items/Ammo) ? LoadedType : text2path("/obj/Items/Ammo/[Caliber]/Standard")
	if(M && p)
		var/obj/Items/Ammo/back = new p
		back.TotalStack = extra
		back.suffix = "[extra]"
		M.GiveOrDrop(back)
	return extra

obj/Items/Gun/proc/WhipOverride(mob/user, delay)
	if(!user)
		return 0
	for(var/obj/Items/GunMod/M in mods)
		if(!M.mod_whip || !M.mod_skill)
			continue
		var/obj/Skills/AutoHit/S = locate(M.mod_skill) in user.AutoHits
		if(!S)
			return 0
		user.NextAttack = world.time + delay * SlowMoDelayMult(user)
		user.Activate(S, TRUE, TRUE)
		return 1
	return 0

/obj/Items/GunMod
	icon = 'Icons/Other/Guns.dmi'
	var/mod_mag_mult = 1
	var/mod_range = 0
	var/mod_cone = 0
	var/mod_acc = 0
	var/mod_bloom_mult = 1
	var/mod_reload_mult = 1
	var/mod_silent = 0
	var/mod_whip = 0
	var/mod_skill

obj/Items/Gun/Handgun
	GunClass = GUN_CLASS_HANDGUN
	Caliber = GUN_CALIBER_PISTOL

obj/Items/Gun/Automatic
	GunClass = GUN_CLASS_AUTOMATIC
	Caliber = GUN_CALIBER_RIFLE

obj/Items/Gun/Shotgun
	GunClass = GUN_CLASS_SHOTGUN
	Caliber = GUN_CALIBER_SHELL

obj/Items/Gun/Handgun/Handgun
	name = "Handgun"
	Class = "Light"
	MagSize = 10
	icon_state = "Handgun"
	EquipIcon = 'Blaster.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0

obj/Items/Gun/Automatic/SMG
	name = "SMG"
	Class = "Light"
	MagSize = 30
	icon_state = "SMG"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 12
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0

obj/Items/Gun/Shotgun/Shotgun
	name = "Shotgun"
	Class = "Heavy"
	MagSize = 6
	icon_state = "Shotgun"
	EquipIcon = 'AssaultRifle.dmi'
	pixel_x = 0
	pixel_y = 0
	BulletIcon = 'BlastTracer.dmi'
	BulletSize = 1
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 10
	BulletHitH = 32
	MuzzleX = 0
	MuzzleY = 0

obj/Items/Ammo
	icon = 'Icons/Other/Guns.dmi'
	Stackable = 1
	var/Caliber = GUN_CALIBER_PISTOL
	var/RiderBleed = 0
	var/RiderShatter = 0
	var/RiderSlow = 0
	var/RiderBurn = 0
	var/RiderParalyze = 0
	var/RiderPierce = 0
	var/RiderTag = 0
	var/RiderNoInjury = 0
	var/RiderEMP = 0
	var/RiderSlug = 0
	var/RiderDamageMult = 1
	var/RiderAccMult = 1

obj/Items/Ammo/Pistol
	Caliber = GUN_CALIBER_PISTOL
	icon_state = "Ammo 1"

obj/Items/Ammo/Rifle
	Caliber = GUN_CALIBER_RIFLE
	icon_state = "Ammo 2"

obj/Items/Ammo/Shell
	Caliber = GUN_CALIBER_SHELL
	icon_state = "Ammo 3"

obj/Items/Ammo/Pistol/Standard
	name = "Pistol Rounds"

obj/Items/Ammo/Rifle/Standard
	name = "Rifle Rounds"

obj/Items/Ammo/Shell/Standard
	name = "Shotgun Shells"

mob/proc/SanitizeEquippedGunRef()
	if(!equippedGun)
		return
	var/obj/Items/Gun/G = equippedGun
	if(!istype(G, /obj/Items/Gun))
		equippedGun = null
		return
	if(G.loc != src)
		equippedGun = null
		return
	if(!G.suffix || !findtext(G.suffix, "Equipped"))
		equippedGun = null

mob/proc/MechActiveGun()
	return null

mob/proc/MechHandAdvance(obj/Items/Gun/g)
	return

mob/proc/EquippedGun()
	var/obj/Items/Gun/mg = MechActiveGun()
	if(mg)
		return mg
	SanitizeEquippedGunRef()
	if(equippedGun)
		return equippedGun
	return 0

mob/proc/GunBlocksWeaponBuff(obj/Skills/Buffs/B)
	if(!B)
		return 0
	if(!EquippedGun())
		return 0
	if(B.NeedsSword || B.MakesSword || B.NeedsStaff || B.MakesStaff)
		return 1
	return 0

mob/proc/GunMoveDelay(delay)
	if(Reloading)
		if(passive_handler && passive_handler.Get("Run and Gun") >= 1)
			return delay
		return delay * GunReloadMovePenalty()
	return delay

mob/proc/GunLegacyMoveDelay(delay)
	if(PmActive())
		return delay
	return GunMoveDelay(delay)

mob/proc/GunBloomPenalty()
	if(!gun_bloom)
		return 0
	var/idle = world.time - gun_last_shot
	if(idle > GUN_BLOOM_GRACE)
		gun_bloom = max(0, gun_bloom - GUN_BLOOM_DECAY * (idle - GUN_BLOOM_GRACE))
	return gun_bloom

mob/proc/GunAddBloom(cur = -1, step = GUN_BLOOM_PER_SHOT)
	if(cur < 0)
		cur = GunBloomPenalty()
	var/v = passive_handler ? passive_handler.Get("Trigger Discipline") : 0
	if(v > 0)
		step /= 1 + v
	gun_bloom = min(GUN_BLOOM_MAX, cur + step)
	gun_last_shot = world.time

mob/proc/GunMeleeMult()
	var/v = passive_handler ? passive_handler.Get("Gun Melee") : 0
	if(v <= 0)
		gun_melee_at = 0
		return 1
	gun_melee_at = world.time
	return 1 + v

mob/proc/GunTargetAngle(atom/movable/a)
	if(!a)
		return GunDirAngle(dir)
	var/dx = (a.x * 32 + a.step_x) - (src.x * 32 + src.step_x)
	var/dy = (a.y * 32 + a.step_y) - (src.y * 32 + src.step_y)
	if(!dx && !dy)
		return GunDirAngle(dir)
	var/ang = arctan(dx, dy)
	while(ang < 0)
		ang += 360
	return ang

mob/proc/GunLaneOffset(obj/Items/Gun/G, shotdir)
	if(!G || !Target || Target == src || !ismob(Target))
		return null
	if(Target.z != src.z)
		return null
	if(Target.in_smoke > world.time)
		return null
	if(get_dist(src, Target) > G.ClassRange())
		return null
	if(GunAngleDelta(GunTargetAngle(Target), GunDirAngle(shotdir)) > G.AimCone())
		return null
	var/cap = GunLaneCap()
	var/ox = 0
	var/oy = 0
	if(shotdir == EAST || shotdir == WEST)
		oy = clamp(Target.step_y - src.step_y, -cap, cap)
	else if(shotdir == NORTH || shotdir == SOUTH)
		ox = clamp(Target.step_x - src.step_x, -cap, cap)
	else
		ox = clamp(Target.step_x - src.step_x, -cap, cap)
		oy = clamp(Target.step_y - src.step_y, -cap, cap)
	if(!ox && !oy)
		return null
	return list(ox, oy)

mob/proc/GunAmmoStack(obj/Items/Gun/G)
	if(!G)
		return null
	if(G.LoadedType)
		for(var/obj/Items/Ammo/A in src)
			if(A.type == G.LoadedType && A.TotalStack > 0)
				return A
		return null
	for(var/obj/Items/Ammo/A in src)
		if(A.Caliber == G.Caliber && A.TotalStack > 0)
			G.LoadedType = A.type
			return A
	return null

mob/proc/GunRefillSkill(obj/Items/Gun/G)
	if(!G)
		return
	var/obj/Skills/Projectile/Gunfire/gf = locate(/obj/Skills/Projectile/Gunfire, Projectiles)
	if(!gf)
		return
	gf.MaxCharges = G.MagSize
	gf.Charges = G.Loaded
	if(gf.Charges > 0)
		gf.Using = 0
	if(client)
		client.RefreshHotbarCharges()
		client.RefreshAmmoHUD()

mob/proc/ReloadStart()
	var/obj/Items/Gun/G = EquippedGun()
	if(!G)
		return
	if(Reloading)
		return
	if(G.mech_only)
		return
	if(G.energy_gun)
		GunBatteryReload(G)
		return
	if(G.Loaded >= G.MagSize)
		src << "Your [G.name] is already full."
		return
	if(KO || Stunned || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen)
		return
	if(!GunAmmoStack(G))
		src << "You have no ammunition for your [G.name]."
		return
	Reloading = 1
	if(GunIsSuppressed())
		src << "<b>You start reloading.</b>"
	else
		OMsg(src, "<b>[src] starts reloading.</b>")
	ReloadLoop(G)

mob/proc/GunIsSuppressed()
	var/obj/Items/Gun/G = EquippedGun()
	return G ? G.ModSilent() : 0

mob/proc/ReloadStop()
	if(!Reloading)
		return
	Reloading = 0

mob/proc/ReloadLoop(obj/Items/Gun/G)
	set waitfor = 0
	while(Reloading)
		sleep(G.ReloadTick(src) * SlowMoDelayMult(src))
		if(!Reloading)
			break
		if(EquippedGun() != G)
			break
		if(KO || Stunned || Knockbacked || Suspended || Stasis || Frozen || TimeFrozen)
			break
		if(G.Loaded >= G.MagSize)
			src << "Your [G.name] is loaded."
			break
		var/obj/Items/Ammo/A = GunAmmoStack(G)
		if(!A)
			src << "You are out of ammunition."
			break
		var/want = min(G.ReloadRounds(), G.MagSize - G.Loaded)
		var/moved = min(want, A.TotalStack)
		if(moved <= 0)
			break
		G.Loaded += moved
		G.DryWarned = 0
		A.TotalStack -= moved
		A.suffix = "[A.TotalStack]"
		if(A.TotalStack <= 0)
			del A
		GunRefillSkill(G)
		if(client)
			client.BuildInvPage()
	Reloading = 0

mob/Players/verb
	Reload()
		set hidden = 1
		set instant = 1
		src.ReloadStart()
	Reload_up()
		set hidden = 1
		set instant = 1
		src.ReloadStop()

mob/proc/GunAdoptAmmo(obj/Items/Ammo/A)
	if(!A)
		return 0
	var/obj/Items/Gun/G = EquippedGun()
	if(G && (G.energy_gun || G.mech_only))
		src << "Your [G.name] runs on energy, not rounds."
		return 1
	if(!G || G.Caliber != A.Caliber)
		return 0
	if(G.LoadedType == A.type)
		src << "Your [G.name] is already loaded with [A.name]."
		return 1
	if(G.Loaded > 0 && G.LoadedType)
		var/obj/Items/Ammo/back = new G.LoadedType
		back.TotalStack = G.Loaded
		back.suffix = "[back.TotalStack]"
		G.Loaded = 0
		GiveOrDrop(back)
	G.LoadedType = A.type
	G.DryWarned = 0
	GunRefillSkill(G)
	src << "Your [G.name] will now load [A.name]."
	return 1

obj/Items/Gun/proc/GunEquipRefused(mob/User)
	if(!User)
		return 1
	if(mech_only && !src.suffix)
		User << "The [src.name] only mounts on a mech's arm."
		return 1
	if(src.suffix && User.StyleBuff && User.StyleBuff.NeedsGun)
		User << "You can't remove your gun with [User.StyleBuff] active!"
		return 1
	if(User.StanceBuff && User.GunBlocksWeaponBuff(User.StanceBuff))
		User << "You can't change your gun with [User.StanceBuff] active!"
		return 1
	if(User.StyleBuff && User.GunBlocksWeaponBuff(User.StyleBuff))
		User << "You can't change your gun with [User.StyleBuff] active!"
		return 1
	if(User.ActiveBuff && User.GunBlocksWeaponBuff(User.ActiveBuff))
		User << "You can't change your gun with [User.ActiveBuff] active!"
		return 1
	if(User.SpecialBuff && User.GunBlocksWeaponBuff(User.SpecialBuff))
		User << "You can't change your gun with [User.SpecialBuff] active!"
		return 1
	if(User.SlotlessBuffs.len > 0)
		for(var/sb in User.SlotlessBuffs)
			var/obj/Skills/Buffs/b = User.SlotlessBuffs[sb]
			if(b && User.GunBlocksWeaponBuff(b))
				User << "You can't change your gun with [b] active!"
				return 1
	return 0

/mob/var/list/gun_art_kept

obj/Items/Gun/proc/GunArtPaths()
	. = list()
	for(var/p in Techniques)
		if(ispath(p, /obj/Skills))
			. += p
	for(var/obj/Items/GunMod/M in mods)
		if(ispath(M.mod_skill, /obj/Skills))
			. += M.mod_skill

mob/proc/GunArtKept(path)
	if(!gun_art_kept)
		gun_art_kept = list()
	var/obj/Skills/S = gun_art_kept[path]
	if(!S)
		S = new path
		gun_art_kept[path] = S
	return S

mob/proc/GunArtsOn(obj/Items/Gun/G)
	if(!G)
		return
	for(var/p in G.GunArtPaths())
		var/obj/Skills/S = GunArtKept(p)
		S.MenuIcon = G.icon_state
		S.MenuIconFile = G.icon
		if(!(S in Skills))
			AddSkill(S)

mob/proc/GunArtDrop(path)
	for(var/obj/Skills/S in Skills.Copy())
		if(S.type == path)
			DeleteSkill(S, FALSE)

mob/proc/GunArtsOff(obj/Items/Gun/G)
	if(!G)
		return
	for(var/p in G.GunArtPaths())
		GunArtDrop(p)

obj/Items/Gun/proc/GunAlignEquip(mob/A)
	if(!A)
		return
	var/placement = FLOAT_LAYER - 3
	if(src.LayerPriority)
		placement -= src.LayerPriority
	if(src.suffix && A == src.loc)
		if(A.equippedGun == src)
			A.equippedGun = null
		src.suffix = null
		A.Reloading = 0
		A.GunClearAim()
		var/obj/Skills/Projectile/Gunfire/gf = locate(/obj/Skills/Projectile/Gunfire, A.Projectiles)
		if(gf)
			gf.Using = 0
		A.GunArtsOff(src)
		if(src.EquipIcon)
			var/image/im = image(icon = src.EquipIcon, pixel_x = src.pixel_x, pixel_y = src.pixel_y, layer = placement)
			A.overlays -= im
		if(A.client)
			A.client.RefreshHotbar()
			A.client.RefreshAmmoHUD()
			A.client.BuildInvPage()
			if(!A.client.cursor_dyn)
				CursorNeutral(A.client)
		return
	if(A != src.loc)
		return
	A.equippedGun = src
	src.suffix = "*Equipped*"
	src.DryWarned = 0
	if(A.AttackQueue)
		A << "You drop [A.AttackQueue] from your queue."
		A.QueueOverlayRemove()
		A.ClearQueue()
	src.SyncMag(A)
	A.GunArtsOn(src)
	if(src.EquipIcon)
		var/image/im = image(icon = src.EquipIcon, pixel_x = src.pixel_x, pixel_y = src.pixel_y, layer = placement)
		A.overlays += im
	A.GunRefillSkill(src)
	if(A.client)
		A.client.BuildInvPage()
		if(!A.client.cursor_dyn)
			CursorNeutral(A.client)

/mob/Admin4/verb/gunTestKit()
	set category = "Admin"
	set name = "Gun Test Kit"
	var/list/kit = list(/obj/Items/Gun/Handgun/Handgun, /obj/Items/Gun/Automatic/SMG, /obj/Items/Gun/Shotgun/Shotgun)
	for(var/p in kit)
		var/obj/Items/Gun/G = new p(usr)
		G.Loaded = G.MagSize
	var/list/rounds = list(/obj/Items/Ammo/Pistol/Standard, /obj/Items/Ammo/Rifle/Standard, /obj/Items/Ammo/Shell/Standard)
	for(var/p in rounds)
		var/obj/Items/Ammo/A = new p(usr)
		A.TotalStack = 200
		A.suffix = "[A.TotalStack]"
	if(usr.client)
		usr.client.BuildInvPage()
	usr << "Three test guns and 200 of each standard round added."
