// Variant 1
var/global/list/BW_PERCEPTUAL = list(
	0.299, 0.299, 0.299,
	0.587, 0.587, 0.587,
	0.114, 0.114, 0.114,
	0,     0,     0)

// Variant 2
var/global/list/BW_CONTRAST_MED = list(
	0.419, 0.419, 0.419,
	0.822, 0.822, 0.822,
	0.160, 0.160, 0.160,
	-0.20, -0.20, -0.20)

// Variant 3 (the one that is used atm)
var/global/list/BW_CONTRAST_HIGH = list(
	0.508, 0.508, 0.508,
	0.998, 0.998, 0.998,
	0.194, 0.194, 0.194,
	-0.35, -0.35, -0.35)

/obj/Skills/AutoHit/Suzumushi
	name = "Suzumushi"
	Area = "Target"
	Distance = 6
	DamageMult = 1
	ForOffense = 0.01
	ManaCost = 20
	Cooldown = 30
	ActiveMessage = "seizes their target's movement with the piercing ring of Suzumushi!"

	verb/Suzumushi()
		set name = "Suzumushi"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Suzumushi can only be used in Shikai."
			return
		if(!usr.Activate(src))
			return
		var/mob/T = usr.Target
		if(!T) return
		applySuspend(T, 5)
		playSuzumushiVisual(usr, T)

/proc/playSuzumushiVisual(mob/user, atom/target)
	set waitfor = FALSE
	if(!user || !target) return

	var/max_radius = 8
	var/ring_delay = 3

	var/turf/user_origin = get_turf(user)
	if(!user_origin) return

	var/list/expand_rings = list()
	for(var/i in 1 to max_radius + 1)
		expand_rings += list(list())

	for(var/turf/T in range(max_radius, user_origin))
		var/dx = T.x - user_origin.x
		var/dy = T.y - user_origin.y
		var/dist = sqrt(dx*dx + dy*dy)
		if(dist > max_radius) continue
		var/r = round(dist + 0.5)
		if(r < 0) r = 0
		if(r > max_radius) r = max_radius
		var/list/slot = expand_rings[r + 1]
		slot += T

	var/list/tile_orig = list()
	var/list/atom_orig = list()

	for(var/r in 0 to max_radius)
		var/list/slot = expand_rings[r + 1]
		for(var/turf/T in slot)
			if(!T) continue
			if(!(T in tile_orig))
				tile_orig[T] = T.color
				animate(T, color = BW_CONTRAST_HIGH, time = 1)
			for(var/atom/movable/A in T)
				if(A in atom_orig) continue
				atom_orig[A] = A.color
				animate(A, color = BW_CONTRAST_HIGH, time = 1)
		sleep(1)

	sleep(3)

	var/turf/target_origin = get_turf(target)
	if(!target_origin)
		for(var/turf/T as anything in tile_orig)
			if(T) T.color = tile_orig[T]
		for(var/atom/movable/A as anything in atom_orig)
			if(A) A.color = atom_orig[A]
		return

	var/list/collapse_rings = list()
	for(var/i in 1 to max_radius + 1)
		collapse_rings += list(list())

	for(var/turf/T as anything in tile_orig)
		if(!T) continue
		var/dx = T.x - target_origin.x
		var/dy = T.y - target_origin.y
		var/dist = sqrt(dx*dx + dy*dy)
		var/r = round(dist + 0.5)
		if(r < 0) r = 0
		if(r > max_radius) r = max_radius
		var/list/slot = collapse_rings[r + 1]
		slot += T

	for(var/r = max_radius, r >= 0, r--)
		var/list/slot = collapse_rings[r + 1]
		for(var/turf/T in slot)
			if(!(T in tile_orig)) continue
			animate(T, color = tile_orig[T], time = ring_delay)
			tile_orig -= T
			for(var/atom/movable/A in T)
				if(A in atom_orig)
					animate(A, color = atom_orig[A], time = ring_delay)
					atom_orig -= A
		sleep(ring_delay)

	for(var/turf/T as anything in tile_orig)
		if(T) T.color = tile_orig[T]
	for(var/atom/movable/A as anything in atom_orig)
		if(A) A.color = atom_orig[A]

/obj/Skills/Buffs/SlotlessBuffs/Suzumushi
	name = "Suzumushi"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Harden"    = 1 + SL,
			"Steady"    = 1 + SL,
			"Flow"      = 1 + SL,
			"FluidForm" = 0.5 + (SL * 0.5),
			"Flicker"   = 1 + SL,
			"Pressure"  = 1 + SL
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		EndMult = 1.2 + (0.15 * SL)
		StrMult = 1.2 + (0.15 * SL)
		SpdMult = 1.2 + (0.15 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)

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

/obj/Skills/Projectile/Benihiko
	name = "Benihiko"
	ManaCost = 10
	ZoneAttack = 1
	Speed = 0.25
	Distance = 20
	Blasts = 15
	Charge = 1
	DamageMult = 1
	Instinct = 1
	AccMult = 2
	Homing = 3
	Explode = 0
	ZoneAttackX = 3
	ZoneAttackY = 3
	Hover = 7
	Variation = 0
	Cooldown = 60
	IconLock = 'TousenTechs.dmi'
	icon_state = "Benihiko2"
	ActiveMessage = "launches a swarm of sonic blades with Benihiko!"

	verb/Benihiko()
		set name = "Benihiko"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Benihiko can only be used in Shikai."
			return
		usr.UseProjectile(src)
