mob/var/tmp
	KageoniSavedPixelY = 0
	KageoniSavedAlpha = 0
	obj/Effects/IrooniIndicator/IroniIndicator
	IroniLastResonateTime = 0   // to prevent Irooni message spam

obj/Items/Sword/Medium/Legendary/Shinigami/Zanpakuto_Dual
	name = "Zanpakutō"
	icon = 'Goemon Katana Unsheathed 2.dmi'
	pixel_x = -16
	pixel_y = -16
	Ascended = 2
	Destructable = 0
	Stealable = 0
	ShatterTier = 0
	PermEquip = 1
	IsZanpakuto = 1
	Saga = "Shinigami"
	Cost = 0
	Unobtainable = 1

	ObjectUse(mob/Players/User = usr)
		if(!suffix && !User.InShinigamiForm)
			User << "Your Zanpakutō can only be equipped through Shinigami Form."
			return
		..()

/obj/Skills/Buffs/SlotlessBuffs/Katen_Kyokotsu
	name = "Katen Kyokotsu"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"DoubleStrike"     = 1 + SL,
			"CriticalChance"   = 5 + (5 * SL),
			"CriticalDamage"   = 0.05 + (0.05 * SL),
			"Flicker"          = 1 + SL,
			"Pursuer"          = 1 + SL,
			"TechniqueMastery" = 1 + SL,
			"Duelist"          = 1 + SL,
			"Shadowbringer"    = 1
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		StrMult = 1.1 + (0.15 * SL)
		SpdMult = 1.1 + (0.15 * SL)
		ForMult = 1.1 + (0.15 * SL)


	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)
			if(istype(user, /mob/Players))
				var/mob/Players/P = user
				if(P.HiddenInShadow || P.HideInShadowsActive)
					P.KageoniForceReset()

	verb/Shikai()
		set name = "Shikai"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(!usr.InShinigamiForm)
				usr << "You must be in Shinigami Form to use Shikai."
				return
			if(usr.InBankai())
				usr << "You cannot use Shikai while in Bankai."
				return
			var/hasZanpakuto = FALSE
			for(var/obj/Items/i in usr)
				if(i.IsZanpakuto && i.suffix)
					hasZanpakuto = TRUE
					break
			if(!hasZanpakuto)
				usr << "You must have your Zanpakutō equipped to use Shikai."
				return
			adjust(usr)
			OMsg(usr, "<b>[usr] calls out, \"[usr.ShikaiCall], [usr.AsauchiName]!\"</b>")
			src.Trigger(usr)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.applyShikaiIcon(usr)
		else
			src.Trigger(usr)

/obj/Skills/Projectile/Bushogoma
	name = "Bushogoma"
	ManaCost = 5
	DamageMult = 10
	Cooldown = 15
	Launcher = 3
	Homing = 0
	Distance = 12
	Speed = 1
	AccMult = 1.2
	Instinct = 2
	IconLock = 'Air Slash.dmi'
	LockX = -16
	LockY = -16
	ActiveMessage = "kicks up a roaring whirlwind with Bushogoma!"

	verb/Bushogoma()
		set name = "Bushogoma"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Bushogoma can only be used in Shikai."
			return
		usr.UseProjectile(src)

/obj/Skills/Takaoni
	name = "Takaoni"
	ManaCost = 5
	Cooldown = 30

	verb/Takaoni()
		set name = "Takaoni"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Takaoni can only be used in Shikai."
			return
		if(Using || cooldown_remaining) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(target.z != usr.z)
			usr << "Takaoni requires your target to be on the same plane."
			return
		if(target.y <= usr.y)
			usr << "Takaoni can only reach a target that is above you."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use Takaoni."
			return
		usr.LoseMana(src.ManaCost)
		src.Cooldown(1, null, usr)
		var/turf/dest = locate(target.x, target.y + 1, target.z)
		if(!dest || dest.density)
			dest = get_turf(target)
		usr.loc = dest
		usr.dir = SOUTH
		OMsg(usr, "<b>[usr] suddenly appears above their foe with Takaoni!</b>")

/obj/Skills/Kageoni
	name = "Kageoni"
	ManaCost = 15
	Cooldown = 75

	verb/Kageoni()
		set name = "Kageoni"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Kageoni can only be used in Shikai."
			return
		var/mob/Players/user = usr
		if(!istype(user)) return
		// If already hidden
		if(user.HiddenInShadow)
			if(user.KageoniMidTransition) return
			user.KageoniAssassinate(src)
			return
		// Already cloaked but not yet sunk in
		if(user.HideInShadowsActive)
			usr << "Click a shadow to slip inside."
			return
		if(Using || cooldown_remaining) return
		if(user.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use Kageoni."
			return
		user.LoseMana(src.ManaCost)
		src.Cooldown(1, null, user)
		user.KageoniActivate()

/obj/Skills/AutoHit/Kageoni_Autohit
	name = "Kageoni"
	Area = "Target"
	DamageMult = 20
	Executing = 0.5
	HitSparkIcon='Slash.dmi'
	HitSparkX=-32
	HitSparkY=-32
	ComboMaster = 1
	StrOffense = 1
	Distance = 2
	NoLock = 1
	NoAttackLock = 1
	Instinct = 5
	Cooldown = 0
	heavenlyRestrictionIgnore = 1
	ActiveMessage = "bursts from the shadow in a deadly ambush!"

// (Red=Autohit, Blue=Queue, Green=Projectile) Matching attack x1.5 damage, mismatch x0.5
// Cooldown starts when effect ends
/obj/Effects/IrooniIndicator
	Lifetime = -1
	icon = 'Irooni.dmi'
	icon_state = "red"
	mouse_opacity = 0

	New(loc)
		..()
		appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/obj/Skills/Irooni
	name = "Irooni"
	ManaCost = 20
	Cooldown = 60

	verb/Irooni()
		set name = "Irooni"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Irooni can only be used in Shikai."
			return
		if(Using || cooldown_remaining) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 10)
			usr << "Your target is too far away for Irooni."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use Irooni."
			return
		usr.LoseMana(src.ManaCost)
		src.Using = 1
		OMsg(usr, "<b>[usr] begins calling out various colors!</b>")
		usr.ApplyIrooni(target, src)

mob/proc/ApplyIrooni(mob/target, obj/Skills/Irooni/skill)
	if(!target) return
	if(target.IroniActive)
		target.ClearIrooni()
	target.IroniActive = 1
	target.IroniCaster = src
	target.IroniColor = "red"
	var/obj/Effects/IrooniIndicator/ind = new(null)
	ind.Target = target
	ind.icon_state = "red"
	var/icon/I = icon(target.icon, target.icon_state, target.dir)
	var/h = I.Height()
	if(!h) h = world.icon_size
	var/w = I.Width()
	ind.pixel_y = h
	ind.pixel_x = (w - world.icon_size) / 2
	target.vis_contents += ind
	target.IroniIndicator = ind
	spawn() target.IrooniLoop(src, skill)

mob/proc/IrooniLoop(mob/caster, obj/Skills/Irooni/skill)
	var/list/cycle = list("red", "blue", "green")
	var/idx = 1
	var/elapsed = 0
	while(src && IroniActive && elapsed < 600)
		sleep(30)             // 3 seconds per color
		elapsed += 30
		if(!src || !IroniActive) break
		idx = (idx % 3) + 1
		IroniColor = cycle[idx]
		if(IroniIndicator) IroniIndicator.icon_state = IroniColor
	ClearIrooni()
	// Cooldown starts now, on effect end
	if(skill)
		skill.Using = 0
		skill.Cooldown(1, null, caster)

mob/proc/ClearIrooni()
	IroniActive = 0
	IroniColor = null
	IroniCaster = null
	if(IroniIndicator)
		src.vis_contents -= IroniIndicator
		var/obj/Effects/IrooniIndicator/o = IroniIndicator
		o.Target = null
		IroniIndicator = null
		del o

// 2x movement speed, only when moving toward the target
/obj/Skills/Daruma_san_ga_Koronda
	name = "Daruma-san ga Koronda"
	ManaCost = 5
	Cooldown = 60

	verb/Daruma_san_ga_Koronda()
		set name = "Daruma-san ga Koronda"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Daruma-san ga Koronda can only be used in Shikai."
			return
		if(Using || cooldown_remaining) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana."
			return
		usr.LoseMana(src.ManaCost)
		src.Cooldown(1, null, usr)
		usr.DarumaTarget = target
		usr.DarumaActive = 1
		usr.DarumaEndTime = world.time + 300   // 30 seconds
		OMsg(usr, "<b>[usr] locks eyes on [target] and moves on a trail of reiatsu!</b>")
		spawn() usr.DarumaLoop()

mob/proc/DarumaLoop()
	while(src && DarumaActive)
		if(world.time >= DarumaEndTime || !DarumaTarget || DarumaTarget.loc == null)
			break
		sleep(5)
	DarumaActive = 0
	DarumaTarget = null
	DarumaEndTime = 0
	if(src && src.client) src << "Your pace returns to normal."

mob/proc/DarumaMovingToward(turf/dest)
	if(!DarumaActive || !DarumaTarget || !dest) return 0
	var/atom/T = DarumaTarget
	if(!T.loc) return 0
	if(T.z != dest.z) return 0
	var/old_dx = abs(x - T.x)
	var/old_dy = abs(y - T.y)
	var/new_dx = abs(dest.x - T.x)
	var/new_dy = abs(dest.y - T.y)
	if(new_dx > old_dx) return 0     // moved away on X
	if(new_dy > old_dy) return 0     // moved away on Y
	if(new_dx == old_dx && new_dy == old_dy) return 0
	return 1

/mob/MonkeySoldier/FlameSoldier/ShadowClone
	density = 0

	New(mob/p, dmg, timer)
		..()
		if(p)
			src.icon = p.icon
			src.icon_state = p.icon_state
			src.dir = p.dir
			src.color = p.color
			for(var/O in p.overlays)
				src.overlays += O
		src.alpha = 230
		src.layer = MOB_LAYER

	chaseTarget()
		if(!src.target || !src.target.loc) return
		if(get_dist(src, src.target) <= 1) return
		var/d = get_dir(src, src.target)
		for(var/dd in list(d, turn(d, 45), turn(d, -45)))
			var/turf/dest = get_step(src, dd)
			if(src.turfFree(dest))
				src.dir = dd
				src.loc = dest
				return

	FlickAttack()
		src.lastAttack = world.time
		flick("Attack", src)
		if(src.target)
			src.target.LoseHealth(src.damageValue)

mob/proc/summonShadowClones(dmg, count, lifetimeTicks)
	var/turf/center = get_turf(src)
	if(!center) return
	for(var/i in 1 to count)
		var/mob/MonkeySoldier/FlameSoldier/ShadowClone/sc = new(src, dmg, lifetimeTicks)
		var/list/spots = block(locate(max(1, center.x - 2), max(1, center.y - 2), center.z), locate(min(world.maxx, center.x + 2), min(world.maxy, center.y + 2), center.z))
		if(spots.len)
			var/turf/spot = pick(spots)
			if(spot) sc.loc = spot
		MonkeySoldiers.monkeySoldiers += sc
		blobLoop += sc

/obj/Skills/Kageokuri
	name = "Kageokuri"
	ManaCost = 25
	Cooldown = 120
	var/clone_count = 4
	var/clone_lifetime = 30 SECONDS

	verb/Kageokuri()
		set name = "Kageokuri"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Kageokuri can only be used in Shikai."
			return
		if(Using || cooldown_remaining) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use Kageokuri."
			return
		usr.LoseMana(src.ManaCost)
		src.Cooldown(1, null, usr)
		OMsg(usr, "<b>[usr]'s shadows manifest into copies that surge toward their foe!</b>")
		usr.summonShadowClones(1, clone_count, clone_lifetime)

mob/Players/proc/KageoniActivate()
	HideInShadowsActive = 1
	KageoniMidTransition = 0
	KageoniEndTime = world.time + 300
	src << "<b>Click a shadow to slip inside it.</b>"
	spawn() KageoniDurationLoop()

mob/Players/proc/KageoniDurationLoop()
	while(src && (HideInShadowsActive || HiddenInShadow))
		if(world.time >= KageoniEndTime)
			if(KageoniMidTransition)
				sleep(2)
				continue
			KageoniEndKageoni()
			return
		sleep(2)

mob/Players/proc/KageoniEndKageoni()
	if(HiddenInShadow)
		KageoniForceRise()
	else
		HideInShadowsActive = 0
		KageoniEndTime = 0

mob/Players/proc/KageoniEnterShadow(obj/Effects/Shadowbringer_Shadow/shadow)
	if(!shadow || !shadow.owner) return
	if(!HideInShadowsActive) return
	if(KageoniMidTransition) return
	if(HiddenInShadow)
		if(CurrentShadow && CurrentShadow != shadow && CurrentShadow.occupant == src)
			CurrentShadow.occupant = null
		CurrentShadow = shadow
		shadow.occupant = src
		loc = shadow.owner.loc
		return
	KageoniMidTransition = 1
	CurrentShadow = shadow
	KageoniSinkAnimation()
	if(!CurrentShadow || !CurrentShadow.owner)
		KageoniRestoreVisual()
		CurrentShadow = null
		KageoniMidTransition = 0
		return
	CurrentShadow.occupant = src
	loc = CurrentShadow.owner.loc
	invisibility = 101
	HiddenInShadow = 1
	Suspended = "Kageoni"
	if(islist(BeingTargetted))
		for(var/mob/tm in BeingTargetted.Copy())
			if(tm.Target == src)
				tm.RemoveTarget()
	KageoniMidTransition = 0

mob/Players/proc/KageoniSinkAnimation()
	KageoniSavedPixelY = pixel_y
	KageoniSavedAlpha = alpha
	animate(src, pixel_y = pixel_y - world.icon_size, alpha = 0, time = 7, easing = SINE_EASING)
	sleep(7)

mob/Players/proc/KageoniRise()
	invisibility = 0
	var/restoreAlpha = KageoniSavedAlpha ? KageoniSavedAlpha : 255
	pixel_y = KageoniSavedPixelY - world.icon_size
	alpha = 0
	animate(src, pixel_y = KageoniSavedPixelY, alpha = restoreAlpha, time = 9, easing = SINE_EASING)
	sleep(9)
	pixel_y = KageoniSavedPixelY
	alpha = restoreAlpha

mob/Players/proc/KageoniRestoreVisual()
	animate(src)
	pixel_y = KageoniSavedPixelY
	alpha = KageoniSavedAlpha ? KageoniSavedAlpha : 255
	invisibility = 0

mob/Players/proc/KageoniAssassinate(obj/Skills/Kageoni/skill)
	if(KageoniMidTransition) return
	KageoniMidTransition = 1
	var/obj/Effects/Shadowbringer_Shadow/shadow = CurrentShadow
	var/mob/Players/victim = (shadow ? shadow.owner : null)
	if(shadow && shadow.occupant == src)
		shadow.occupant = null
	if(victim && victim != src)
		victim.Suspended = "Kageoni Strike"
		spawn(20) if(victim && victim.Suspended == "Kageoni Strike") victim.Suspended = null
	KageoniRise()
	HiddenInShadow = 0
	if(Suspended == "Kageoni") Suspended = null
	CurrentShadow = null
	if(victim && victim != src)
		src.Target = victim
		var/obj/Skills/AutoHit/Kageoni_Autohit/ah = src.FindSkill(/obj/Skills/AutoHit/Kageoni_Autohit)
		if(!ah)
			ah = new /obj/Skills/AutoHit/Kageoni_Autohit
			src.AddSkill(ah)
		ah.Using = 0
		src.Activate(ah, TRUE, TRUE)
	HideInShadowsActive = 0
	KageoniEndTime = 0
	KageoniMidTransition = 0

mob/Players/proc/KageoniForceRise()
	var/obj/Effects/Shadowbringer_Shadow/shadow = CurrentShadow
	if(shadow && shadow.occupant == src)
		shadow.occupant = null
	if(HiddenInShadow)
		KageoniRise()
	HiddenInShadow = 0
	if(Suspended == "Kageoni") Suspended = null
	CurrentShadow = null
	HideInShadowsActive = 0
	KageoniEndTime = 0
	KageoniMidTransition = 0

mob/Players/proc/KageoniForceReset()
	var/obj/Effects/Shadowbringer_Shadow/shadow = CurrentShadow
	if(shadow && shadow.occupant == src)
		shadow.occupant = null
	if(HiddenInShadow || HideInShadowsActive)
		invisibility = 0
		alpha = KageoniSavedAlpha ? KageoniSavedAlpha : 255
		pixel_y = KageoniSavedPixelY
		if(Suspended == "Kageoni") Suspended = null
	HiddenInShadow = 0
	HideInShadowsActive = 0
	CurrentShadow = null
	KageoniEndTime = 0
	KageoniMidTransition = 0

mob/var/tmp
	TragedyAfflicted = 0
	TameraikizuActive = 0
	mob/TameraikizuPartner
	KatenBleedLock = 0
	mob/ZankiTarget
	ItokiribasamiAttacking = 0
	DangyoActive = 0
	mob/DangyoPartner
	list/KatenWaterTiles
	list/KatenWhiteImages

var/global/list/BG_CONTRAST_HIGH = list(
	0.508, 0.427, 0,
	0.998, 0.838, 0,
	0.194, 0.163, 0,
	-0.35, -0.294, 0)


/proc/playKatenBankaiVisual(mob/user)
	set waitfor = FALSE
	if(!user) return
	var/turf/origin = get_turf(user)
	if(!origin) return
	var/max_radius = 15
	var/list/expand_rings = list()
	for(var/i in 1 to max_radius + 1)
		expand_rings += list(list())
	for(var/turf/T in range(max_radius, origin))
		var/dx = T.x - origin.x
		var/dy = T.y - origin.y
		var/dist = sqrt(dx*dx + dy*dy)
		if(dist > max_radius) continue
		var/r = round(dist + 0.5)
		if(r < 0) r = 0
		if(r > max_radius) r = max_radius
		expand_rings[r + 1] += T
	var/list/tile_orig = list()
	var/list/atom_orig = list()
	for(var/r in 0 to max_radius)
		for(var/turf/T in expand_rings[r + 1])
			if(!T) continue
			if(!(T in tile_orig))
				tile_orig[T] = T.color
				animate(T, color = BG_CONTRAST_HIGH, time = 1)
			for(var/atom/movable/A in T)
				if(A in atom_orig) continue
				atom_orig[A] = A.color
				animate(A, color = BG_CONTRAST_HIGH, time = 1)
		sleep(1)
	sleep(8)
	for(var/turf/T as anything in tile_orig)
		if(T) animate(T, color = tile_orig[T], time = 20)
	for(var/atom/movable/A as anything in atom_orig)
		if(A) animate(A, color = atom_orig[A], time = 20)

/obj/Skills/Buffs/SlotlessBuffs/Karamatsu_Shinju
	name = "Katen Kyokotsu: Karamatsu Shinju"
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"DoubleStrike"     = 3 + SL,
			"CriticalChance"   = 5 + (5 * SL),
			"CriticalDamage"   = 0.05 + (0.05 * SL),
			"HardStyle"        = 3 + SL,
			"DeathField"       = 3 + SL,
			"Duelist"          = 1 + SL,
			"ManaCapMult"      = 0.2 + (0.15 * SL),
			"Shadowbringer"    = 1,
			"Tragedy"          = 1
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		StrMult = 1.4 + (0.1 * SL)
		SpdMult = 1.4 + (0.1 * SL)
		ForMult = 1.4 + (0.1 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(!wasOn && src.SlotlessOn)
			if(istype(user, /mob/Players))
				var/mob/Players/P = user
				P.KatenBankaiStart()
		else if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)
			if(istype(user, /mob/Players))
				var/mob/Players/P = user
				P.KatenBankaiEnd()

	verb/Bankai()
		set name = "Bankai"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(!usr.InShinigamiForm)
				usr << "You must be in Shinigami Form to use Bankai."
				return
			if(usr.InShikai())
				usr << "You must end Shikai before entering Bankai."
				return
			var/hasZanpakuto = FALSE
			for(var/obj/Items/i in usr)
				if(i.IsZanpakuto && i.suffix)
					hasZanpakuto = TRUE
					break
			if(!hasZanpakuto)
				usr << "You must have your Zanpakutō equipped to use Bankai."
				return
			if(usr.TotalFatigue > 50)
				usr << "Your body is too worn to bear Karamatsu Shinju. (Requires 50 or less Fatigue.)"
				return
			adjust(usr)
			OMsg(usr, "<b>[usr] calls out, \"Bankai... [usr.AsauchiName]: [usr.BankaiPrefix] !\"</b>")
			src.Trigger(usr)
		else
			src.Trigger(usr)

mob/Players/proc/KatenBankaiStart()
	playKatenBankaiVisual(src)
	spawn() TragedyLoop()

// negates their InjuryImmune/Unstoppable
mob/proc/TragedyLoop()
	while(src && InBankai() && passive_handler.Get("Tragedy"))
		if(Target && ismob(Target))
			var/mob/T = Target
			T.TragedyAfflicted = world.time
		sleep(3)

mob/Players/proc/KatenBankaiEnd()
	TotalFatigue = 90
	StrTax += 0.25
	ForTax += 0.25
	SpdTax += 0.25
	EndTax += 0.25
	DefTax += 0.25
	OffTax += 0.25
	if(TameraikizuPartner)
		var/mob/pt = TameraikizuPartner
		pt.TameraikizuActive = 0
		pt.TameraikizuPartner = null
	TameraikizuActive = 0
	TameraikizuPartner = null
	if(ZankiTarget)
		ZankiTarget.KatenBleedLock = 0
		ZankiTarget = null
	if(DangyoActive)
		DangyoEnd(DangyoPartner)
	KatenClearWhiteScreen(src)
	src << "<b>The full weight of the tragedy settles into your body.</b>"

mob/proc/KatenCleanseBankaiState()
	if(TameraikizuPartner)
		var/mob/pt = TameraikizuPartner
		if(pt && pt.TameraikizuPartner == src)
			pt.TameraikizuActive = 0
			pt.TameraikizuPartner = null
	TameraikizuActive = 0
	TameraikizuPartner = null
	KatenBleedLock = 0
	if(ZankiTarget)
		ZankiTarget.KatenBleedLock = 0
		ZankiTarget = null
	TragedyAfflicted = 0
	if(DangyoActive)
		DangyoEnd(DangyoPartner)
	if(Suspended == "Dangyo" || Suspended == "Shime")
		Suspended = null
	KatenClearWhiteScreen(src)

/obj/Skills/Ichidanme
	name = "Ichidanme: Tameraikizu no Wakachiai"
	ManaCost = 15
	Cooldown = -1

	verb/Ichidanme()
		set name = "Ichidanme: Tameraikizu no Wakachiai"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "This can only be used in Bankai."
			return
		if(Using) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 6)
			usr << "Your target is too far away."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana."
			return
		usr.LoseMana(src.ManaCost)
		src.Cooldown(1, null, usr)
		usr.TameraikizuActive = 1
		usr.TameraikizuPartner = target
		target.TameraikizuActive = 1
		target.TameraikizuPartner = usr
		OMsg(usr, "<b>[usr] and [target] are bound to share every wound from Ichidanme: Tameraikizu no Wakachiai!</b>")

/obj/Skills/Nidanme
	name = "Nidanme: Zanki no Shitone"
	ManaCost = 15
	Cooldown = -1

	verb/Nidanme()
		set name = "Nidanme: Zanki no Shitone"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "This can only be used in Bankai."
			return
		if(Using) return
		var/obj/Skills/Ichidanme/first = usr.FindSkill(/obj/Skills/Ichidanme)
		if(!first || !first.Using)
			usr << "You must perform Ichidanme: Tameraikizu no Wakachiai first."
			return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 6)
			usr << "Your target is too far away."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana."
			return
		usr.LoseMana(src.ManaCost)
		src.Cooldown(1, null, usr)
		target.Bleed = 100
		target.KatenBleedLock = 100
		usr.ZankiTarget = target
		OMsg(usr, "<b>[target] is laid upon a bed of their own blood with Nidanme: Zanki no Shitone!</b>")

/obj/Effects/KatenWater
	icon = 'PlainWater.dmi'
	Lifetime = -1
	density = 0
	mouse_opacity = 0
	Savable = 0
	layer = TURF_LAYER + 0.1

/obj/Skills/Sandanme
	name = "Sandanme: Dangyo no Fuchi"
	ManaCost = 15
	Cooldown = -1

	verb/Sandanme()
		set name = "Sandanme: Dangyo no Fuchi"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "This can only be used in Bankai."
			return
		if(Using) return
		var/obj/Skills/Nidanme/prev = usr.FindSkill(/obj/Skills/Nidanme)
		if(!prev || !prev.Using)
			usr << "You must perform Nidanme: Zanki no Shitone first."
			return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 6)
			usr << "Your target is too far away."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana."
			return
		usr.LoseMana(src.ManaCost)
		src.Cooldown(1, null, usr)
		usr.DangyoStart(target)

mob/proc/KatenSpawnWater(mob/a, mob/b)
	var/list/tiles = list()
	var/turf/ta = get_turf(a)
	var/turf/tb = get_turf(b)
	if(!ta || !tb || ta.z != tb.z) return tiles
	var/midx = round((ta.x + tb.x) / 2)
	var/midy = round((ta.y + tb.y) / 2)
	var/radius = get_dist(ta, tb) + 3
	var/turf/mid = locate(midx, midy, ta.z)
	if(!mid) return tiles
	for(var/turf/T in range(radius, mid))
		var/dx = T.x - midx
		var/dy = T.y - midy
		if(sqrt(dx*dx + dy*dy) > radius) continue
		var/obj/Effects/KatenWater/w = new(T)
		tiles += w
	return tiles

mob/proc/DangyoStart(mob/target)
	DangyoActive = 1
	DangyoPartner = target
	src.Suspended = "Dangyo"
	target.Suspended = "Dangyo"
	KatenWaterTiles = KatenSpawnWater(src, target)
	OMsg(src, "<b>The ground gives way to a drowning abyss beneath [src] and [target] from Sandanme: Dangyo no Fuchi!</b>")
	spawn() DangyoDrainLoop(target)

mob/proc/DangyoDrainLoop(mob/target)
	var/drain = 10
	while(src && target && DangyoActive)
		src.LoseMana(drain)
		target.LoseMana(drain)
		if(src.ManaAmount <= 0 || target.ManaAmount <= 0)
			var/mob/loser = (src.ManaAmount <= target.ManaAmount) ? src : target
			loser.WoundSelf(15)
			OMsg(src, "<b>[loser]'s reserves run dry in the depths!</b>")
			DangyoEnd(target)
			return
		sleep(16)

mob/proc/DangyoEnd(mob/target)
	DangyoActive = 0
	KatenClearWater()
	if(Suspended == "Dangyo") Suspended = null
	if(target && target.Suspended == "Dangyo") target.Suspended = null
	DangyoPartner = null

mob/proc/KatenClearWater()
	if(KatenWaterTiles)
		for(var/obj/Effects/KatenWater/w in KatenWaterTiles)
			if(w) del w
		KatenWaterTiles = null

/obj/Skills/AutoHit/Itokiribasami_Autohit
	name = "Itokiribasami Chizome no Nodobue"
	Area = "Target"
	DamageMult = 25
	ComboMaster = 1
	StrOffense = 1
	Executing = 1
	Distance = 10
	NoLock = 1
	NoAttackLock = 1
	HitSparkIcon='Slash - Vampire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	Instinct = 5
	Cooldown = 0
	heavenlyRestrictionIgnore = 1
	ActiveMessage = "draws the bloody garrote tight across their partner's throat with Itokiribasami Chizome no Nodobue!"

/obj/Skills/Shime_no_Dan
	name = "Shime no Dan: Itokiribasami Chizome no Nodobue"
	ManaCost = 0
	Cooldown = -1

	verb/Shime_no_Dan()
		set name = "Shime no Dan: Itokiribasami Chizome no Nodobue"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "This can only be used in Bankai."
			return
		if(Using) return
		var/obj/Skills/Sandanme/prev = usr.FindSkill(/obj/Skills/Sandanme)
		if(!prev || !prev.Using)
			usr << "You must perform Sandanme: Dangyo no Fuchi first."
			return
		if(usr.DangyoActive)
			usr << "You cannot finish the play while Dangyo no Fuchi still churns."
			return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 10)
			usr << "Your target is too far away."
			return
		src.Cooldown(1, null, usr)
		usr.ShimeNoDan(target)

mob/proc/KatenWhiteScreen(mob/M)
	if(!M || !M.client) return
	KatenClearWhiteScreen(M)
	var/list/imgs = list()
	for(var/turf/T in view(M))
		var/image/i = image('Icons/BLANK.dmi', T)
		i.icon_state = "white"
		i.layer = MOB_LAYER - 0.05
		i.alpha = 0
		M.client.images += i
		imgs += i
		animate(i, alpha = 255, time = 10)
	M.KatenWhiteImages = imgs

mob/proc/KatenClearWhiteScreen(mob/M)
	if(!M) return
	if(M.KatenWhiteImages)
		for(var/image/i in M.KatenWhiteImages)
			if(M.client) M.client.images -= i
		M.KatenWhiteImages = null

mob/proc/ShimeNoDan(mob/target)
	src.Suspended = "Shime"
	target.Suspended = "Shime"
	KatenWhiteScreen(src)
	KatenWhiteScreen(target)
	OMsg(src, "<b>The world drains to white as [src] closes upon [target]...</b>")
	spawn(50)
		if(!src) return
		if(src.Suspended == "Shime") src.Suspended = null
		if(target && target.Suspended == "Shime") target.Suspended = null
		// Strike lands while the screen is still white
		if(target && target.loc)
			src.Target = target
			src.ItokiribasamiAttacking = 1
			var/obj/Skills/AutoHit/Itokiribasami_Autohit/ah = src.FindSkill(/obj/Skills/AutoHit/Itokiribasami_Autohit)
			if(!ah)
				ah = new /obj/Skills/AutoHit/Itokiribasami_Autohit
				src.AddSkill(ah)
			ah.Using = 0
			src.Activate(ah, TRUE, TRUE)
			src.ItokiribasamiAttacking = 0
		// Better timing for visuals
		sleep(20)
		if(src.KatenWhiteImages)
			for(var/image/wi in src.KatenWhiteImages)
				animate(wi, alpha = 0, time = 5)
		if(target && target.KatenWhiteImages)
			for(var/image/wi in target.KatenWhiteImages)
				animate(wi, alpha = 0, time = 5)
		sleep(5)
		KatenClearWhiteScreen(src)
		if(target) KatenClearWhiteScreen(target)
		// Force the Bankai to end
		var/obj/Skills/Buffs/SlotlessBuffs/Karamatsu_Shinju/b = src.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Karamatsu_Shinju)
		if(b && b.SlotlessOn)
			b.Trigger(src)
