// Prevents all healing entirely
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/AshChoked
	AlwaysOn = 0
	NeedsPassword = 0
	TimerLimit = 30
	IconLock = 'marked.dmi'
	BuffName = "Ash-Choked"
	passives = list("AshChoked" = 1)
	ActiveMessage = "is choked by smoldering ash, their wounds refuse to close!"
	OffMessage = "shakes the clinging ash from their body."

proc/applyAshChoked(mob/target, mob/caster)
	if(!target) return
	var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/AshChoked/ac = target.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/AshChoked)
	if(!ac) return
	if(!target.BuffOn(ac))
		ac.Trigger(target, 1)

/obj/leftOver/RyujinFlameField
	icon = 'Fire VFX4.dmi'
	density = 0
	lifetime = -1
	pixel_x = -48
	pixel_y = -48
	alpha = 0
	layer = MOB_LAYER - 0.5
	var/field_damage = 0.5
	var/damage_interval = 10
	var/tmp/list/last_damage_time = list()

	New(turf/_loc, mob/p, _lifetime)
		if(!_loc)
			del src
			return
		loc = locate(_loc.x, _loc.y, _loc.z)
		if(_lifetime) lifetime = _lifetime
		init(p)
		owner = p
		animate(src, alpha = 255, time = 5)
		..()

	proc/deal_field_damage(mob/m)
		if(!m || m == owner || m.KO || !ismob(m)) return
		if(!(istype(m, /mob/Players) || istype(m, /mob/Player))) return
		var/last = last_damage_time[m]
		if(!last || (world.time - last) >= damage_interval)
			m.LoseHealth(field_damage)
			m.AddBurn(field_damage, owner)
			last_damage_time[m] = world.time

	proc/covered_mobs()
		. = list()
		var/turf/cen = get_turf(src)
		if(!cen) return
		var/list/b = block(locate(max(1, cen.x - 1), max(1, cen.y - 1), cen.z), locate(min(world.maxx, cen.x + 2), min(world.maxy, cen.y + 2), cen.z))
		for(var/turf/T in b)
			for(var/mob/m in T)
				. += m

	on_tick()
		if(owner && owner.PureRPMode) return
		for(var/mob/m in covered_mobs())
			deal_field_damage(m)

	Update()
		// This is kinda leftover from my first try at this
		if(lifetime < 0)
			on_tick()
			return
		lifetime -= world.tick_lag
		if(lifetime <= 0)
			ticking_generic -= src
			owner = null
			last_damage_time = null
			tick_on = null
			loc = null
		else
			on_tick()

/obj/Skills/Buffs/SlotlessBuffs/Ryujin_Jakka
	name = "Ryūjin Jakka"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Instinct"       = 1 + SL,
			"MagicSword"     = 1,
			"HybridStrike"   = 0.5 + (0.5 * SL),
			"Scorching"      = 1 + SL,
			"Combustion"     = 50 + (SL * 5),
			"SoulFire"       = 1 + SL
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		ForMult = 1.1 + (0.1 * SL)
		StrMult = 1.1 + (0.1 * SL)
		EndMult = 1.1 + (0.1 * SL)

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

/obj/Skills/Projectile/Taimatsu_Inferno
	FlickBlast=0
	AttackReplace=1
	Distance=21
	DamageMult=0.5
	Dodgeable=0
	Deflectable=0
	Instinct=2
	Radius=2
	ZoneAttack=1
	ZoneAttackX=0
	ZoneAttackY=0
	FireFromSelf=1
	FireFromEnemy=0
	MultiHit=20
	Scorching = 1
	Knockback=2
	Piercing=1
	IconLock='FireTornadoHead.dmi'
	IconSize=0.25
	LockX=-32
	LockY=-32
	Variation=0
	Trail='FireTornadoTrail.dmi'
	TrailDuration=8
	TrailSize=1
	TrailX=-32
	TrailY=-32

/obj/Skills/AutoHit/Taimatsu
	name = "Taimatsu"
	Area="Wave"
	AdaptRate=1
	DamageMult=0.15
	ComboMaster=1
	NoLock = 1
	Instinct=2
	NoAttackLock=1
	Knockback=3
	Cooldown=45
	HitSparkIcon='Hit Effect.dmi'
	HitSparkX=-32
	HitSparkY=-32
	WindUp=0.1
	Hurricane="/obj/Skills/Projectile/Taimatsu_Inferno"
	HurricaneDelay=0.1
	WindupMessage="raises their blade as the air itself begins to ignite..."
	ActiveMessage="sweeps their blazing sword, unleashing a roaring firestorm!"

	verb/Taimatsu()
		set name = "Taimatsu"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Taimatsu can only be used in Shikai."
			return
		usr.Activate(src)

/obj/Effects/JokakuFlameWall
	icon = 'FireWall.dmi'
	density = 1
	layer = EFFECTS_LAYER + 1
	Lifetime = -1
	var/tmp/mob/wall_owner

/obj/Skills/Jokaku_Enjo
	name = "Jōkaku Enjō"
	ManaCost = 20
	Cooldown = 60
	var/wall_active = FALSE
	var/wall_range = 2
	var/wall_duration = 10 SECONDS
	var/touch_damage = 1
	var/touch_burn = 10
	var/touch_interval = 10
	var/tmp/list/walls = list()
	var/tmp/list/last_touch = list()

	New()
		walls = list()
		last_touch = list()
		..()

	proc/spawnWalls(mob/user, turf/center)
		clearWalls()
		walls = list()
		var/cx = center.x
		var/cy = center.y
		var/cz = center.z
		var/list/b = block(locate(max(1, cx - wall_range), max(1, cy - wall_range), cz), locate(min(world.maxx, cx + wall_range), min(world.maxy, cy + wall_range), cz))
		for(var/turf/T in b)
			if(abs(T.x - cx) != wall_range && abs(T.y - cy) != wall_range) continue
			var/obj/Effects/JokakuFlameWall/wall = new(T)
			wall.wall_owner = user
			walls += wall

	proc/clearWalls()
		var/list/to_del = walls.Copy()
		walls = list()
		for(var/obj/Effects/JokakuFlameWall/wall in to_del)
			if(wall)
				animate(wall, alpha = 0, time = 5)
		spawn(6)
			for(var/obj/Effects/JokakuFlameWall/wall in to_del)
				if(wall) del wall

	proc/touchDamage(mob/user, mob/m)
		if(!m || m == user || m.KO) return
		var/last = last_touch[m]
		if(!last || (world.time - last) >= touch_interval)
			m.AddBurn(touch_burn, user)
			m.LoseHealth(touch_damage)
			last_touch[m] = world.time

	verb/Jokaku_Enjo()
		set name = "Jokaku Enjo"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Jōkaku Enjō can only be used in Shikai."
			return
		if(wall_active)
			usr << "Jōkaku Enjō is already active."
			return
		if(Using || cooldown_remaining) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 10)
			usr << "Target is too far away."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, usr)
		usr.LoseMana(src.ManaCost)
		var/mob/user = usr
		OMsg(user, "<b>[user] sweeps a hand toward [target]... \"Jōkaku Enjō.\"</b>")
		var/turf/center = get_turf(target)
		spawnWalls(user, center)
		wall_active = TRUE
		var/obj/Skills/Jokaku_Enjo/self = src
		spawn()
			var/elapsed = 0
			while(self.wall_active && user && user.loc && elapsed < self.wall_duration)
				for(var/obj/Effects/JokakuFlameWall/wall in self.walls)
					if(!wall || !wall.loc) continue
					for(var/mob/m in range(1, wall))
						if(m == user) continue
						self.touchDamage(user, m)
				sleep(3)
				elapsed += 3
			self.wall_active = FALSE
			self.clearWalls()

/obj/Effects/EnnetsuOrb
	Lifetime = -1
	icon = 'Fire VFX8 Alt.dmi'
	layer = EFFECTS_LAYER + 1
	alpha = 0
	density = 0

/obj/Skills/AutoHit/Ennetsu_Jigoku_Impact
	name = "Ennetsu Jigoku Impact"
	Area="Target"
	Distance=20
	DamageMult=10
	StrOffense=1
	ForOffense=1
	Scorching=20
	Cooldown=0
	WindUp=0
	NoLock=1
	NoAttackLock=1
	HitSparkIcon='Hit Effect.dmi'

/obj/Skills/Ennetsu_Jigoku
	name = "Ennetsu Jigoku"
	ManaCost = 30
	Cooldown = 75
	var/orb_distance = 8

	proc/orbLaunch(mob/user, mob/target)
		if(!user || !target || !target.loc) return
		var/turf/center = get_turf(target)
		if(!center) return
		var/list/dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
		var/list/orbs = list()
		for(var/d in dirs)
			var/turf/t = center
			for(var/i in 1 to orb_distance)
				var/turf/nt = get_step(t, d)
				if(nt) t = nt
			var/obj/Effects/EnnetsuOrb/orb = new(t)
			orbs += orb
			animate(orb, alpha = 255, time = 4)
			sleep(3)
		sleep(4)
		for(var/obj/Effects/EnnetsuOrb/orb in orbs)
			spawn()
				var/started = world.time
				var/reached = FALSE
				while(orb && orb.loc && target && target.loc)
					if(world.time - started >= 30 SECONDS) break
					if(get_turf(orb) == get_turf(target))
						reached = TRUE
						break
					var/d = get_dir(orb, target)
					if(d)
						var/turf/ns = get_step(orb, d)
						if(ns) orb.loc = ns
					sleep(1)
				if(orb && orb.loc && reached)
					Bang(orb.loc, Size = 1.5, Offset = 2, Vanish = 4)
					if(target && target.loc)
						var/obj/Skills/AutoHit/Ennetsu_Jigoku_Impact/imp = new()
						user.Target = target
						user.Activate(imp, TRUE)
				if(orb) del orb

	verb/Ennetsu_Jigoku()
		set name = "Ennetsu Jigoku"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Ennetsu Jigoku can only be used in Shikai."
			return
		if(Using || cooldown_remaining) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(get_dist(usr, target) > 12)
			usr << "Target is too far away."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, usr)
		usr.LoseMana(src.ManaCost)
		var/mob/user = usr
		OMsg(user, "<b>[user] raises their blade skyward... \"Ennetsu Jigoku!\" Flames gather to consume [target]!</b>")
		spawn()
			orbLaunch(user, target)

/obj/Skills/Buffs/SlotlessBuffs/Zanka_no_Tachi
	name = "Zanka no Tachi"
	Slotless = 1
	IsBankaiForm = 1
	ManaThreshold = 2

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Instinct"         = 1 + SL,
			"MagicSword"       = 1,
			"HybridStrike"     = 2.5 + (0.5 * SL),
			"Scorching"        = 3 + SL,
			"SoulFire"         = 3 + SL,
			"FireHerald"       = 1
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		ForMult = 1.3 + (0.1 * SL)
		StrMult = 1.3 + (0.1 * SL)
		EndMult = 1.3 + (0.1 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(!wasOn && src.SlotlessOn)
			activateBankaiForms(user)
		else if(wasOn && !src.SlotlessOn)
			deactivateBankaiForms(user)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)

	// always present during Bankai
	proc/activateBankaiForms(mob/user)
		var/obj/Skills/Buffs/SlotlessBuffs/Kyokujitsujin/k = user.findOrAddSkill(/obj/Skills/Buffs/SlotlessBuffs/Kyokujitsujin)
		if(k)
			k.adjust(user)
			if(!user.BuffOn(k))
				k.Trigger(user)

	proc/deactivateBankaiForms(mob/user)
		if(!user) return
		var/obj/Skills/Buffs/SlotlessBuffs/Kyokujitsujin/k = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Kyokujitsujin)
		if(k && user.BuffOn(k))
			k.Trigger(user)
		var/obj/Skills/Buffs/SlotlessBuffs/Zanjitsu_Gokui/zg = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Zanjitsu_Gokui)
		if(zg && zg.SlotlessOn)
			zg.Trigger(user)
		// Despawn any lingering Daisojin swarm.
		var/list/soldiers = user.MonkeySoldiers.monkeySoldiers.Copy()
		for(var/mob/MonkeySoldier/FlameSoldier/fs in soldiers)
			if(fs && fs.owner == user)
				fs.EndMonkey(user)

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
			adjust(usr)
			src.Trigger(usr)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.applyBankaiIcon(usr)
			if(sf) sf.applyBankaiShihakushoIcon(usr)
			OMsg(usr, "<b>[usr] calls out, \"Bankai... [usr.BankaiPrefix]!\"</b>")
		else
			src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Kyokujitsujin
	name = "Higashi: Kyokujitsujin"
	Slotless = 1
	AlwaysOn = 1

	adjust(mob/p)
		var/SL = p.SagaLevel
		passives = list(
			"PridefulRage" = 1,
			"PureDamage"   = 1 + SL,
			"Zornhau"      = 1 + SL,
			"SpiritSword"   = 2
		)
		OffMult = 1.1 + (0.1 * SL)
		SpdMult = 1.1 + (0.1 * SL)
		DefMult = 1.1 + (0.1 * SL)

/obj/Skills/Buffs/SlotlessBuffs/Zanjitsu_Gokui
	name = "Nishi: Zanjitsu Gokui"
	Slotless = 1
	AuraLock='FlameAura.dmi'
	AuraX=-16
	AuraY=-8
	var/tmp/aura_active = FALSE
	var/tmp/list/flame_fields = list()
	var/aura_range = 4

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"ChillImmune" = 1,
			"WaterResist" = 5,
			"DeathField"  = 3 + SL,
			"VoidField"   = 3 + SL,
			"PureReduction" = 1 + SL
		)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(!wasOn && src.SlotlessOn)
			startAura(user)
		else if(wasOn && !src.SlotlessOn)
			stopAura(user)

	proc/startAura(mob/user)
		if(aura_active) return
		aura_active = TRUE
		var/obj/Skills/Buffs/SlotlessBuffs/Zanjitsu_Gokui/self = src
		spawn()
			var/field_counter = 0
			while(self.aura_active && user && user.loc && user.InBankai())
				if(user.PureRPMode)
					sleep(10)
					continue
				for(var/mob/m in range(self.aura_range, user))
					if(m == user || !m.client) continue
					m.AddBurn(2, user)
				field_counter++
				if(field_counter >= 5)
					field_counter = 0
					self.spawnFlameField(user)
				sleep(10)
			self.stopAura(user)

	proc/spawnFlameField(mob/user)
		var/turf/center = get_turf(user)
		if(!center) return
		var/list/candidates = list()
		for(var/turf/T in range(aura_range, center))
			var/has_field = FALSE
			for(var/obj/leftOver/RyujinFlameField/f in T)
				has_field = TRUE
				break
			if(!has_field)
				candidates += T
		if(!candidates.len) return
		var/turf/spot = pick(candidates)
		var/obj/leftOver/RyujinFlameField/field = new(spot, user)
		flame_fields += field

	proc/stopAura(mob/user)
		aura_active = FALSE
		for(var/obj/leftOver/RyujinFlameField/f in flame_fields)
			if(f)
				ticking_generic -= f
				del f
		flame_fields = list()

	Del()
		stopAura(null)
		..()

	verb/Zanjitsu_Gokui()
		set name = "Zanjitsu Gokui"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(!usr.InBankai())
				usr << "Zanjitsu Gokui can only be used in Bankai."
				return
			adjust(usr)
			OMsg(usr, "<b>[usr]'s body erupts into a shroud of searing heat... \"Zanjitsu Gokui.\"</b>")
			src.Trigger(usr)
		else
			src.Trigger(usr)

/obj/Skills/Queue/Tenchi_Kaijin
	name = "Kita: Tenchi Kaijin"
	DamageMult = 15
	AccuracyMult = 1.2
	Ashing   = 1
	Explosive = 10
	PushOut  = 3
	PushOutWaves = 2
	Finisher = 1
	Delayer  = 0.15
	Quaking  = 3
	Instinct = 2
	Duration = 10
	Cooldown = 75
	ManaCost = 30

	verb/Tenchi_Kaijin()
		set name = "Tenchi Kaijin"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "Tenchi Kaijin can only be used in Bankai."
			return
		usr.SetQueue(src)

/mob/MonkeySoldier/FlameSoldier
	attackDelay = 12
	density = 1
	var/lastUpdate = 0

	New(mob/p, dmg, timer)
		..()
		src.icon = 'Skeleton.dmi'
		src.icon_state = ""
		src.overlays.Cut()
		src.underlays.Cut()
		src.color = null
		src.alpha = 255
		src.glide_size = 8
		src.lastUpdate = world.time

	Update()
		if(!src.owner)
			src.EndMonkey()
			return
		var/delta = world.time - src.lastUpdate
		src.lastUpdate = world.time
		if(src.owner.PureRPMode)
			src.spawnTime += delta
			return
		src.setTargetToOwners()
		if(src.InstantKillCriteria())
			src.EndMonkey(owner)
			return
		// Chase the owner's current target every tick of the swarm loop
		src.chaseTarget()
		if(src && src.TimeToAttack() && src.target && get_dist(src, src.target) <= 1)
			src.FlickAttack()

	proc/turfFree(turf/T)
		if(!T || T.density) return FALSE
		for(var/atom/movable/A in T)
			if(A == src) continue
			if(A.density) return FALSE
		return TRUE

	proc/chaseTarget()
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
			src.target.AddBurn(src.damageValue, src.owner)

mob/proc/summonFlameSoldiers(dmg, count, lifetimeTicks)
	var/turf/center = get_turf(src)
	if(!center) return
	for(var/i in 1 to count)
		var/mob/MonkeySoldier/FlameSoldier/fs = new(src, dmg, lifetimeTicks)
		var/list/spots = block(locate(max(1, center.x - 2), max(1, center.y - 2), center.z), locate(min(world.maxx, center.x + 2), min(world.maxy, center.y + 2), center.z))
		if(spots.len)
			var/turf/spot = pick(spots)
			if(spot) fs.loc = spot
		MonkeySoldiers.monkeySoldiers += fs
		blobLoop += fs

/obj/Skills/Kaka_Jumanokushi_Daisojin
	name = "Minami: Kaka Jūmanokushi Daisōjin"
	ManaCost = 60
	Cooldown = 150
	var/soldier_count = 8
	var/soldier_lifetime = 30 SECONDS

	verb/Kaka_Jumanokushi_Daisojin()
		set name = "Kaka Jumanokushi Daisojin"
		set category = "Skills"
		if(!usr.InBankai())
			usr << "Kaka Jūmanokushi Daisōjin can only be used in Bankai."
			return
		if(Using || cooldown_remaining) return
		var/mob/target = usr.Target
		if(!target || !target.loc)
			usr << "No target selected."
			return
		if(usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		src.Cooldown(1, null, usr)
		usr.LoseMana(src.ManaCost)
		var/mob/user = usr
		OMsg(user, "<b>[user] drives their blazing blade into the earth... \"Kaka Jūmanokushi Daisōjin!\" A legion of burning dead claws its way up from the ash!</b>")
		var/turf/center = get_turf(target)
		if(center)
			for(var/turf/T in range(2, center))
				Bang(T, Size = 1, Offset = 4, Vanish = 4)
			for(var/mob/m in range(2, center))
				if(m == user || !m.client) continue
				m.AddBurn(10, user)
		user.summonFlameSoldiers(1, soldier_count, soldier_lifetime)
