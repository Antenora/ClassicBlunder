obj/Skills/Fire
	IsSpell = 1
	SpellElement = "Fire"

obj/Skills/Fire/Daosdorg
	name = "Daosdorg"
	SpellTier = 3
	SpellShape = "aoe"
	PageKey = "41"
	MenuIcon = "SuperExplosiveWave"
	Desc = "Mark a patch of ground within a few paces and after a breath it becomes a long low blaze that scorches everything standing in it. Anyone inside who burns hard enough sets everyone else in the blaze alight to match. It will not light on water."
	ManaCost = 9
	Cooldown = 20
	var/tmp/marking = 0
	proc/MarkTurf(mob/p)
		var/mob/T = p.Target
		if(ismob(T) && T != p && T.z == p.z && get_dist(p, T) <= 6)
			return get_turf(T)
		var/turf/G = get_turf(p)
		for(var/i in 1 to 4)
			var/turf/N = get_step(G, p.dir)
			if(!N) break
			G = N
		return G
	verb/Daosdorg()
		set name = "Daosdorg"
		set category = "Skills"
		if(src.Using || src.cooldown_remaining || marking) return
		if(usr.KO || usr.Dead) return
		if(usr.HeldSkillBlocksAction(src)) return
		if(usr.passive_handler.Get("Silenced"))
			usr << "<font color=red>You can't use [src] you are silenced!</font>"
			return
		if(usr.GCDBlocked(src)) return
		if(!usr.SpellPreCast(src)) return
		if(usr.ManaAmount < usr.SpellManaNeed(src))
			usr << "<font color=red>You don't have enough mana to cast [src].</font>"
			return
		var/turf/T = MarkTurf(usr)
		if(!T || istype(T, /turf/Waters))
			usr << "<font color=red>The water will not take the flame.</font>"
			return
		usr.StartGCD(src)
		marking = 1
		var/obj/fx_rider/castcircle/C = new(T, "Fire", 3)
		C.caster = usr
		sleep(4)
		marking = 0
		if(!usr || usr.KO || usr.Dead) return
		usr.SpawnFireGround(T, 60, 3, 0.02, 1, 0, 0, 30)
		usr.LoseMana(usr.SpellManaNeed(src))
		src.Cooldown(1, null, usr)

obj/Skills/Buffs/SlotlessBuffs/Fire/Phoenix_Feathers_Robe
	name = "Phoenix Feathers Robe"
	BuffName = "Phoenix Feathers Robe"
	SpellTier = 3
	SpellShape = "buff"
	PageKey = "51"
	MenuIcon = "AdvancedFireMagic"
	Desc = "Wings of flame settle on you, or on a party ally standing beside you, and knit the wearer's wounds while they burn; the wearer's mana breathes back faster beneath them. Cast while your last target burns hard and that fire is drawn in as an instant mending and a longer flight. Water or a soaking snuffs the wings in steam."
	TimerLimit = 6
	MiscBindable = 1
	ManaCost = 10
	Cooldown = 30
	ManaRegenMult = 2
	ConsumeSelfCast = 1
	Consumes = list("Fire")
	PrimedBy = list("Fire")
	PrimeThreshold = 20
	LitCostMult = 0.5
	TitheRate = 0.15
	TitheCap = 10
	ConsumeMinPool = 20
	SnuffOnDrench = 1
	IconLock = 'Burning Flame.dmi'
	AuraArt = 1
	LockX = -16
	LockY = -4
	HealthHeal = 10
	passives = list("FireResist" = 2)
	ActiveMessage = "is wrapped in wings of flame."
	OffMessage = "lets the flame wings fade."
	var/tmp/mob/wearer
	var/tmp/obj/Skills/Buffs/SlotlessBuffs/Fire/Phoenix_Feathers_Robe/gift
	var/tmp/watch_id = 0
	var/tmp/gifted = 0
	Trigger(mob/User, Override)
		if(!User) return 0
		var/was = User.BuffOn(src)
		if(!was)
			TimerLimit = initial(TimerLimit)
			wearer = User
		. = ..()
		var/now = User.BuffOn(src)
		if(!was && now)
			User.mana_regen_mult = ManaRegenMult
			spawn() Watch(User)
		else if(was && !now)
			User.mana_regen_mult = 1
			wearer = null
			TimerLimit = initial(TimerLimit)
			if(gifted)
				var/mob/host = User
				spawn(1)
					if(host && !host.BuffOn(src)) host.DeleteSkill(src)
		else if(!was && !now)
			wearer = null
	proc/Watch(mob/User)
		var/id = ++watch_id
		while(User && watch_id == id && User.BuffOn(src))
			if(User.Drenched > 0)
				KenShockwave(User, Size = 0.8, Time = 6)
				User << "<font color=#9ad>Steam bursts off you as the wings are snuffed.</font>"
				Trigger(User, 1)
				break
			sleep(5)
	OnConsume(mob/caster, mob/target, pool, amount)
		if(!caster || amount <= 0) return
		var/mob/W = (wearer && wearer.loc) ? wearer : caster
		W.HealHealth(min(amount * 0.1, 10))
		var/obj/Skills/Buffs/SlotlessBuffs/Fire/Phoenix_Feathers_Robe/R = gift ? gift : src
		R.TimerLimit = min(R.TimerLimit + round(amount / 25), initial(R.TimerLimit) + 3)
	proc/GiftRobe(mob/caster, mob/ally)
		if(src.Using || src.cooldown_remaining)
			caster << "<font color=red>[src] is on cooldown.</font>"
			return
		if(caster.GCDBlocked(src)) return
		if(!caster.SpellPreCast(src)) return
		var/need = caster.SpellManaNeed(src)
		if(caster.ManaAmount < need)
			caster << "<font color=red>You don't have enough mana to cast [src].</font>"
			return
		var/had = locate(type) in ally
		var/obj/Skills/Buffs/SlotlessBuffs/Fire/Phoenix_Feathers_Robe/R = ally.findOrAddSkill(type)
		if(!R) return
		if(!had)
			R.gifted = 1
			R.PageKey = null
		if(ally.BuffOn(R))
			R.Timer = 0
		else
			R.TimerLimit = initial(R.TimerLimit)
			R.ManaCost = 0
			R.ConsumeSelfCast = 0
			R.Trigger(ally, 1)
			R.ManaCost = initial(R.ManaCost)
			R.ConsumeSelfCast = initial(R.ConsumeSelfCast)
			if(!ally.BuffOn(R))
				caster << "<font color=red>The wings will not settle on [ally].</font>"
				return
		caster.LoseMana(need)
		wearer = ally
		gift = R
		if(caster.last_struck && ismob(caster.last_struck))
			caster.SpendSpellPools(src, caster.last_struck)
		wearer = null
		gift = null
		src.Cooldown(1, null, caster)
	verb/Phoenix_Feathers_Robe()
		set name = "Phoenix Feathers Robe"
		set category = "Skills"
		var/mob/A = usr.Target
		if(!usr.BuffOn(src) && ismob(A) && A != usr && !A.KO && !A.Dead && A.z == usr.z && get_dist(usr, A) <= 3 && usr.inParty(A.ckey))
			GiftRobe(usr, A)
			return
		src.Trigger(usr)

obj/Skills/AutoHit/Fire/Flamethrower_Jet
	name = "Flamethrower Jet"
	Area = "Wave"
	Distance = 4
	DamageMult = 0.25
	TurfBurn = 5
	SilentCast = 1
	NoGCD = 1
	ManaCost = 0
	Cooldown = 0
	RoundMovement = 1
	NoLock = 1
	NoAttackLock = 1
	HitSparkIcon = 'Explosion - Fire.dmi'
	HitSparkSize = 0.5
	OnSpellHitExtra(mob/caster, mob/m, atom/hitter)
		if(!caster || !m || m.Burn < 60) return
		if(m.passive_handler && m.passive_handler.Get("Cauterized")) return
		applyCauterize(m, 50)
		caster.Stoke(4)

obj/Skills/AutoHit/Fire/Flamethrower
	name = "Flamethrower"
	SpellTier = 3
	SpellShape = "line"
	PageKey = "N5"
	MenuIcon = "FlareWave"
	Desc = "Hold the key and a jet of flame pours from your hand a few paces ahead, sweeping as you turn. The first breath is free; after that the jet drinks mana and gutters out on its own when you run low. You move slowly and stand exposed while it burns. An enemy that catches badly enough in the jet is cauterized and heals only half as well for a while."
	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 5
	HeldDrain = 1
	HeldDrainGrace = 10
	HeldMoveMult = 0.5
	HeldVulnerability = 0.15
	ManaCost = 8
	Cooldown = 12
	Area = "Wave"
	Distance = 4
	OnHeldTick(mob/p)
		if(!p || p.KO || p.Dead) return
		var/obj/Skills/AutoHit/Fire/Flamethrower_Jet/J = p.findOrAddSkill(/obj/Skills/AutoHit/Fire/Flamethrower_Jet)
		if(!J) return
		J.empowered_cast = empowered_cast
		J.Distance = Distance
		p.Activate(J, ignoreCuck = TRUE, ignoreAttackLock = TRUE, noGCD = TRUE)
	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		p.LoseMana(p.SpellManaNeed(src))
		src.Cooldown(1, null, p)
		SpellCastReset()
	OnHeldFizzle(mob/p)
		SpellCastReset()
	verb/Flamethrower()
		set name = "Flamethrower"
		set category = "Skills"
		usr.BeginHeldSkill(src)

obj/Skills/Projectile/Fire/Vanishing_Fireball
	name = "Extreme Killing Vanishing Fireball"
	SpellTier = 3
	SpellShape = "projectile"
	PageKey = "42"
	MenuIcon = "Supernova"
	Desc = "A small dense fireball pursues your target, vanishes a pace short and strikes from behind, where guard and facing cannot answer it. A keen sense sees a flicker where it will reappear. Cast while the target burns hard and it draws on that fire for a certain critical blow."
	IconLock = 'Icons/NSE/spells/cast/fireball.dmi'
	Homing = 1
	BlinkBehind = 1
	BackStrike = 1
	SenseTell = 6
	Distance = 7
	Speed = 0.4
	Explode = 1
	DamageMult = 1.6
	TurfBurn = 8
	ManaCost = 7
	Cooldown = 15
	Consumes = list("Fire")
	ConsumeAmount = 20
	ConsumeMinPool = 20
	PrimedBy = list("Fire")
	PrimeThreshold = 20
	LitCostMult = 0.5
	TitheRate = 0.15
	verb/Vanishing_Fireball()
		set name = "Vanishing Fireball"
		set category = "Skills"
		if(!usr.Target || usr.Target == usr)
			usr << "<font color=red>You need a target for [src].</font>"
			return
		usr.UseProjectile(src)

obj/Skills/AutoHit/Fire/Calidus_Brachium
	name = "Calidus Brachium"
	SpellTier = 3
	SpellShape = "autohit"
	PageKey = "52"
	MenuIcon = "BurningFinger"
	Desc = "Your fist ignites, you close the distance and land one heavy blow: it breaks guard, bursts any projectile in the arc into embers, throws the target back and disarms a raised sword. It lands harder on a burning target and harder still on a stunned one, and every projectile burst or stunned enemy finished returns mana."
	Area = "Strike"
	Rush = 2
	ControlledRush = 1
	GuardBreak = 1
	EraseProjectiles = 1
	Knockback = 1
	TurfBurn = 15
	DisarmIfSwordGuard = 1
	AmpVsPool = "Fire"
	AmpVsPoolMin = 20
	AmpVsPoolMult = 1.25
	BonusVsStunned = 0.3
	StrScaling = 0.5
	ForScaling = 0.5
	DamageMult = 4
	ManaCost = 6
	Cooldown = 12
	PrimedBy = list("Fire")
	PrimeThreshold = 20
	EventRefund = list("erase" = 2, "finisher" = 3)
	EventRefundCap = list("erase" = 6, "finisher" = 3)
	HitSparkIcon = 'Slash - Hellfire.dmi'
	HitSparkX = -32
	HitSparkY = -32
	OnSpellHitExtra(mob/caster, mob/m, atom/hitter)
		if(!caster || !m) return
		if(m.Stunned) caster.PayEventRefund(src, "finisher", 1)
	verb/Calidus_Brachium()
		set name = "Calidus Brachium"
		set category = "Skills"
		usr.Activate(src)

obj/Skills/Buffs/SlotlessBuffs/Fire/Mana_Method
	name = "Mana Method"
	BuffName = "Mana Method"
	SpellTier = 3
	SpellShape = "spell passive"
	PageKey = "SHELF_S1"
	MenuIcon = "AdvancedFireMagic"
	Desc = "Stand perfectly still in combat and a rune array draws itself beneath you; hold still again and a second joins it. Your next Fire spell spends an array and is kindled: stronger, farther, hotter and cheaper, and its fire pursues your last target. An area or line spell may spend both at once."
	AlwaysOn = 1
	NeedsPassword = 0
	doNotDelete = 1
	TimerLimit = 0
	ManaCost = 0
	Cooldown = 0
	SilentCast = 1
	passives = list("ManaMethod" = 1)
	New()
		..()
		spawn() Watch()
	proc/Watch()
		while(src)
			if(ismob(loc))
				var/mob/M = loc
				if(!M.BuffOn(src) && !Using && !M.KO && !M.Dead)
					Trigger(M, 1)
				sleep(20)
			else
				sleep(50)
