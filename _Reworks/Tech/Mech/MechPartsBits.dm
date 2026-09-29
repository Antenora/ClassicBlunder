mob/var/tmp
	list/mech_bits
	mech_bits_heat_at = 0
	mech_bits_home_at = 0
	mech_barrier_until = 0
	mech_barrier_token = 0
	list/mech_barrier_segs

/obj/Items/MechPart/Back/Funnel_Rack
	name = "Funnel Rack"
	desc = "A rack of remote weapon bits for a mech's Back. Grants Deploy Bits: 3 bits orbit you and fire small beams at your target within 6 tiles. Each shot costs 2 heat, and keeping them out costs 5 heat a second. They fly home when you overheat."
	part_tier = MECH_TIER_WALKER
	heat_cost = 5
	Techniques = list(/obj/Skills/Mech/Deploy_Bits)
	var/bit_count = 3
	var/bit_reach = 6
	var/bit_shot_heat = 2
	var/bit_field_heat = 5
	var/bit_fire_ds = 15
	var/bit_recall_ds = 10
	var/bit_dmg = 0.5
	var/bit_radius = 40
	var/bit_rev_ds = 40
	var/bit_layer = 0.1
	var/bit_icon = 'Icons/Technology/Tech.dmi'
	var/bit_state = "Emissor"
	var/bit_shot_icon = 'Icons/Blasts/UltimaLaser.dmi'
	var/bit_shot_size = 0.5

/obj/Items/MechPart/Back/Fin_Funnel_Barrier
	name = "Fin Funnel Barrier"
	desc = "A barrier emitter for a mech's Back. Grants Fin Funnel Barrier: while your bits are out, they stop shooting and form a ring around you that stops enemy shots for 4 seconds. Needs a Funnel Rack with its bits out. 20 heat."
	part_tier = MECH_TIER_WALKER
	heat_cost = 20
	Techniques = list(/obj/Skills/Mech/Fin_Funnel_Barrier)
	var/barrier_ds = 40
	var/barrier_pad = 0
	var/barrier_icon = 'Icons/Technology/Tech.dmi'
	var/barrier_state = "ForceField"

obj/Items/Gun/Handgun/Mech_Bit_Laser
	name = "Bit Laser"
	desc = "The small beam emitter inside a mech's remote bit."
	Class = "Light"
	icon_state = "Phaser"
	EquipIcon = null
	Caliber = null
	MagSize = 1
	mech_only = 1
	hands = 0
	energy_gun = 1
	heat_per_shot = 0
	heat_cost = 0
	BulletIcon = 'Icons/Blasts/UltimaLaser.dmi'
	BulletSize = 0.5
	BulletLockX = 0
	BulletLockY = 0
	BulletHitW = 8
	BulletHitH = 16
	MuzzleX = 0
	MuzzleY = 0
	ModelDamage = 0.5
	ModelAccuracy = 1
	ModelSpeed = 1

/obj/Skills/Mech/Deploy_Bits
	name = "Deploy Bits"
	desc = "Send out your Funnel Rack's bits, or call them home. Out, they orbit you and fire small beams at your target: 2 heat a shot and 5 heat a second while they fly. They fly home if you overheat."
	mech_ranged = 1
	verb/Deploy_Bits()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		. = p.MechBitsToggle(src, noGCD)
		if(.) p.IntrinsicSkillUsed(src)

/obj/Skills/Mech/Fin_Funnel_Barrier
	name = "Fin Funnel Barrier"
	desc = "Your fielded bits stop shooting and lock into a ring around you that stops enemy shots for 4 seconds. Needs your bits out. 20 heat."
	Cooldown = 15
	mech_heat = 20
	mech_ranged = 1
	verb/Fin_Funnel_Barrier()
		set category = "Skills"
		usr.MechPartUse(src)
	MechFire(mob/p, noGCD = FALSE)
		return p.MechBarrierFire(src, noGCD)

/mob/Player/AI/Emplacement/MechBit
	name = "Bit"
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "Emissor"
	Incorporeal = 1
	var/tmp/mob/bit_pilot
	var/tmp/obj/Items/MechPart/Back/Funnel_Rack/bit_rack
	var/tmp/obj/Items/Gun/Handgun/Mech_Bit_Laser/bit_gun
	var/tmp/bit_index = 1
	var/tmp/bit_total = 1
	var/tmp/bit_token = 0
	var/tmp/bit_next_shot = 0
	var/tmp/bit_recall_at = 0
	var/tmp/bit_recall_ds = 1
	var/tmp/bit_gone = 0

	EmplacementKey()
		return bit_pilot ? bit_pilot.DeviceKey() : ..()

	EmplacementDown(mob/P)
		BitGone()

	EMPHit(strength)
		if(strength <= 0) return 0
		BitGone()
		return 1

	AllianceCheck(mob/Player/target)
		var/mob/P = bit_pilot
		if(ismob(target) && P)
			if(target == P) return 1
			if(istype(target, /mob/Player/AI/Emplacement/MechBit))
				var/mob/Player/AI/Emplacement/MechBit/O = target
				if(O.bit_pilot == P) return 1
			if(target.ckey && P.inParty(target.ckey)) return 1
		return ..()

	GunStampPassives(obj/Skills/Projectile/S, obj/Items/Gun/g, bloom = 0)
		..()
		if(S && bit_pilot && bit_rack) S.Distance = max(S.Distance, bit_pilot.MechBitReach(bit_rack) + 1)

	Del()
		BitCleanup()
		..()

	proc/MechBitStats(obj/Items/Mech/R)
		var/total = glob && glob.progress ? glob.progress.totalPotentialToDate : 1
		EmplacementStats(round(total * TurretPotentialBand(R.CraftQuality), 0.1))
		var/list/S = R.MechStats()
		ForReplace = max(0.1, S["For"])

	proc/MechBitArm(obj/Items/MechPart/Back/Funnel_Rack/K)
		var/obj/Items/Gun/Handgun/Mech_Bit_Laser/G = new(src)
		G.ModelDamage = K.bit_dmg
		G.BulletIcon = K.bit_shot_icon
		G.BulletSize = K.bit_shot_size
		G.setStatLine()
		G.GunAlignEquip(src)
		overlays = null
		bit_gun = G
		var/obj/Skills/Projectile/Gunfire/F = locate(/obj/Skills/Projectile/Gunfire, Projectiles)
		if(!F)
			AddSkill(new/obj/Skills/Projectile/Gunfire)
			F = locate(/obj/Skills/Projectile/Gunfire, Projectiles)
		if(F)
			F.UsesOff = 0
			F.UsesFor = 1

	proc/BitStart()
		BitLoop(++bit_token)

	proc/BitLoop(token)
		set waitfor = 0
		while(src && !bit_gone && bit_token == token)
			if(!BitTick()) break
			sleep(world.tick_lag)

	proc/BitTick()
		var/mob/P = bit_pilot
		var/obj/Items/MechPart/Back/Funnel_Rack/K = bit_rack
		if(!P || !K || !P.mech || P.Dead || (P.key && !P.client) || !isturf(P.loc) || K.loc != P.mech)
			BitGone()
			return 0
		usr = src
		if(!bit_recall_at && P.Overheated())
			P.MechRecallBits()
			if(bit_gone) return 0
		BitFollow(P, K)
		if(bit_recall_at)
			if(world.time - bit_recall_at >= bit_recall_ds)
				BitGone()
				return 0
			return 1
		EmplacementIntent()
		CCRecovery()
		P.MechBitsFieldHeat(K)
		if(P.mech_barrier_until > world.time) return 1
		if(world.time < bit_next_shot) return 1
		var/mob/T = P.Target
		if(!BitTargetOK(T)) return 1
		bit_next_shot = world.time + K.bit_fire_ds
		BitShoot(T)
		return 1

	proc/BitFollow(mob/P, obj/Items/MechPart/Back/Funnel_Rack/K)
		if(loc != P.loc) loc = P.loc
		step_x = P.step_x
		step_y = P.step_y
		var/r = K.bit_radius
		if(bit_recall_at) r *= max(0, 1 - (world.time - bit_recall_at) / bit_recall_ds)
		var/ang = 360 * (world.time / max(1, K.bit_rev_ds) + (bit_index - 1) / max(1, bit_total))
		var/nx = round(r * cos(ang))
		var/ny = round(r * sin(ang)) + P.pixel_y - P.MechFlyBaseY()
		if(nx != pixel_x || ny != pixel_y)
			pixel_x = nx
			pixel_y = ny
			SetBodyOffset(nx, ny)
		var/want = P.layer + K.bit_layer
		if(layer != want) layer = want

	proc/BitTargetOK(mob/T)
		var/mob/P = bit_pilot
		if(!ismob(T) || !P || T == src || T == P) return 0
		if(T.KO || T.Dead || !T.density || T.z != z) return 0
		if(istype(T, /mob/Player/AI/Emplacement/MechBit))
			var/mob/Player/AI/Emplacement/MechBit/O = T
			if(O.bit_pilot == P) return 0
		if(T.ckey && P.inParty(T.ckey)) return 0
		if(P.ai_followers && (T in P.ai_followers)) return 0
		if(get_dist(src, T) > P.MechBitReach(bit_rack)) return 0
		return EmpClearShot(src, T, null)

	proc/BitShoot(mob/T)
		var/mob/P = bit_pilot
		var/obj/Items/Gun/G = bit_gun
		if(!G || !P) return 0
		GunSetAimAngle(GunTargetAngle(T))
		if(!FireGun(G)) return 0
		P.HeatAdd(bit_rack.bit_shot_heat * P.MechHeatCostMult())
		return 1

	proc/BitRecall(instant)
		if(bit_gone) return
		if(instant || !bit_rack)
			BitGone()
			return
		if(bit_recall_at) return
		bit_recall_ds = max(1, bit_rack.bit_recall_ds)
		bit_recall_at = world.time

	proc/BitGone()
		if(bit_gone) return
		bit_gone = 1
		bit_token++
		BitCleanup()
		loc = null
		spawn(0)
			if(src) del src

	proc/BitCleanup()
		var/mob/P = bit_pilot
		bit_pilot = null
		BodyTrack(0)
		if(P)
			if(P.ai_followers) P.ai_followers -= src
			if(P.mech_bits)
				P.mech_bits -= src
				if(!P.mech_bits.len) P.mech_bits = null
		Reloading = 0
		if(bit_gun)
			bit_gun.loc = null
			del bit_gun
		bit_gun = null

/obj/Mech_Barrier
	name = "Barrier"
	icon = 'Icons/Technology/Tech.dmi'
	icon_state = "ForceField"
	density = 1
	Savable = 0
	Grabbable = 0
	Attackable = 0
	Destructable = 0
	mouse_opacity = 0
	var/tmp/mob/barrier_pilot

	Cross(atom/movable/O)
		return 1

	onBumped(atom/Obstacle)
		if(istype(Obstacle, /obj/Skills/Projectile/_Projectile))
			var/obj/Skills/Projectile/_Projectile/P = Obstacle
			if(!barrier_pilot || P.Killed || P.Distance < 0) return
			if(P.Owner == barrier_pilot) return
			P.ProjectileFinish()
			return
		..()

mob/proc/MechBitRacks()
	. = list()
	if(!mech) return
	for(var/obj/Items/MechPart/Back/Funnel_Rack/K in MechAllParts())
		. += K

mob/proc/MechBitCount()
	. = 0
	for(var/obj/Items/MechPart/Back/Funnel_Rack/K in MechBitRacks())
		. += K.bit_count
	if(.) . += MechBitBonus()

mob/proc/MechBitReach(obj/Items/MechPart/Back/Funnel_Rack/K)
	return (K ? K.bit_reach : 0) * MechBitReachMult()

mob/proc/MechBitsOut()
	if(!mech_bits) return 0
	mech_bits -= null
	for(var/mob/Player/AI/Emplacement/MechBit/B in mech_bits.Copy())
		if(B.bit_gone || B.bit_recall_at) mech_bits -= B
	if(!mech_bits.len)
		mech_bits = null
		return 0
	return mech_bits.len

mob/proc/MechBitsFieldHeat(obj/Items/MechPart/Back/Funnel_Rack/K)
	if(!K || world.time < mech_bits_heat_at) return
	mech_bits_heat_at = world.time + 10
	HeatAdd(K.bit_field_heat * MechHeatCostMult())

mob/proc/MechBitsToggle(obj/Skills/S, noGCD = FALSE)
	if(!mech)
		src << "[S] only works from inside a mech."
		return 0
	if(MechBitsOut())
		MechBitsRecall(MechBitRecallInstant())
		src << "You call your bits home."
		return 1
	if(world.time < mech_bits_home_at)
		MechLine("bits", "Your bits are still flying home.")
		return 0
	if(!isturf(loc)) return 0
	var/list/racks = MechBitRacks()
	if(!racks.len)
		MechLine("bits", "[mech] has no Funnel Rack fitted.")
		return 0
	if(!MechSkillGo(S, noGCD)) return 0
	var/obj/Items/MechPart/Back/Funnel_Rack/K = racks[1]
	var/n = MechBitCount()
	mech_bits = list()
	mech_bits_heat_at = world.time + 10
	for(var/i = 1 to n)
		MechBitSpawn(K, i, n)
	OMsg(src, "[src]'s [mech] sends out [n] bits.")
	return 1

mob/proc/MechBitSpawn(obj/Items/MechPart/Back/Funnel_Rack/K, i, n)
	var/mob/Player/AI/Emplacement/MechBit/B = new(loc)
	B.step_x = step_x
	B.step_y = step_y
	B.bit_pilot = src
	B.bit_rack = K
	B.bit_index = i
	B.bit_total = n
	B.ai_owner = src
	var/k = DeviceKey()
	B.ai_alliances = k ? list(k) : list()
	B.name = "[mech.name]'s bit"
	B.icon = K.bit_icon
	B.icon_state = K.bit_state
	B.dir = dir
	B.MechBitStats(mech)
	B.MechBitArm(K)
	B.ApplyPixelBounds()
	B.ApplyHurtbox()
	B.BodyTrack(1)
	if(!ai_followers) ai_followers = list()
	ai_followers |= B
	if(!mech_bits) mech_bits = list()
	mech_bits += B
	B.bit_next_shot = world.time + round(K.bit_fire_ds * (i - 1) / max(1, n))
	B.BitStart()
	return B

mob/proc/MechBitsRecall(instant = 0)
	var/list/L = mech_bits
	mech_bits = null
	if(!L) return 0
	var/far = 0
	. = 0
	for(var/mob/Player/AI/Emplacement/MechBit/B in L)
		if(B.bit_gone) continue
		if(!instant && B.bit_rack) far = max(far, B.bit_rack.bit_recall_ds)
		B.BitRecall(instant)
		.++
	if(far) mech_bits_home_at = world.time + far

mob/proc/MechBarrierPart()
	if(!mech) return null
	for(var/obj/Items/MechPart/Back/Fin_Funnel_Barrier/K in MechAllParts())
		return K
	return null

mob/proc/MechBarrierFire(obj/Skills/S, noGCD = FALSE)
	if(!mech)
		src << "[S] only works from inside a mech."
		return 0
	var/obj/Items/MechPart/Back/Fin_Funnel_Barrier/K = MechBarrierPart()
	if(!K) return 0
	if(!MechBitsOut())
		MechLine("barrier", "[S] needs your bits out first.")
		return 0
	if(!MechSkillGo(S, noGCD)) return 0
	S.Cooldown(1, null, src)
	mech_barrier_until = world.time + K.barrier_ds
	MechBarrierLoop(++mech_barrier_token, K)
	OMsg(src, "[src]'s bits lock into a barrier ring.")
	return 1

mob/proc/MechBarrierBox(obj/Items/MechPart/Back/Fin_Funnel_Barrier/K)
	ApplyHurtbox()
	var/l = 16
	var/r = 16
	var/d = 16
	var/u = 16
	if(hurt_w > 0)
		var/cx = 1 + (x - 1) * 32 + 16
		var/cy = 1 + (y - 1) * 32 + 16
		l = cx - HurtL()
		r = HurtL() + hurt_w - cx
		d = cy - HurtB()
		u = HurtB() + hurt_h - cy
	var/pad = K ? K.barrier_pad : 0
	return list(MechBarrierReach(l) + pad, MechBarrierReach(r) + pad, MechBarrierReach(d) + pad, MechBarrierReach(u) + pad)

proc/MechBarrierReach(px)
	return max(1, MechCeil((px + 16) / 32))

mob/proc/MechBarrierLoop(token, obj/Items/MechPart/Back/Fin_Funnel_Barrier/K)
	set waitfor = 0
	var/list/box = MechBarrierBox(K)
	var/list/segs = list()
	mech_barrier_segs = segs
	while(mech && token == mech_barrier_token && world.time < mech_barrier_until && isturf(loc) && MechBitsOut())
		MechBarrierPlace(segs, box, K)
		sleep(world.tick_lag)
	if(token == mech_barrier_token)
		mech_barrier_until = 0
		mech_barrier_segs = null
	MechBarrierClear(segs)

mob/proc/MechBarrierPlace(list/segs, list/box, obj/Items/MechPart/Back/Fin_Funnel_Barrier/K)
	var/turf/c = loc
	var/i = 0
	for(var/dx = -box[1] to box[2])
		for(var/dy = -box[3] to box[4])
			if(dx != -box[1] && dx != box[2] && dy != -box[3] && dy != box[4]) continue
			i++
			var/turf/T = locate(c.x + dx, c.y + dy, c.z)
			var/obj/Mech_Barrier/B
			if(i <= segs.len)
				B = segs[i]
			else
				B = new
				B.barrier_pilot = src
				B.Owner = src
				B.icon = K.barrier_icon
				B.icon_state = K.barrier_state
				segs += B
			if(!T || T.density)
				if(B.loc) B.loc = null
			else if(B.loc != T)
				B.loc = T

mob/proc/MechBarrierClear(list/segs)
	for(var/obj/Mech_Barrier/B in segs)
		B.barrier_pilot = null
		B.loc = null
		del B

mob/proc/MechBarrierDrop()
	mech_barrier_token++
	mech_barrier_until = 0
	var/list/L = mech_barrier_segs
	mech_barrier_segs = null
	if(L) MechBarrierClear(L)

mob/Players/MechRecallBits()
	..()
	if(mech_bits) MechBitsRecall(MechBitRecallInstant())

mob/Players/MechDismount(wreck = 0, silent = 0)
	MechBitsRecall(1)
	MechBarrierDrop()
	return ..()
