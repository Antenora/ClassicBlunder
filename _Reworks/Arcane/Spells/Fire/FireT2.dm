obj/Skills/AutoHit/Fire/Leo_Palma
	name = "Leo Palma"
	SpellTier = 2
	SpellShape = "debuff"
	PageKey = "31"
	MenuIcon = "BurningFinger"
	Desc = "Three lion paws of fire rise around your target and clamp shut, holding it in place and sealing its spells while the paws squeeze burning heat into it. Cast it on a target that already burns hard and the paws feed on that fire and hold longer. Water on the target dissolves the paws."
	Area = "Target"
	Distance = 4
	DamageMult = 0.2
	ForScaling = 0.01
	Snaring = 1.5
	SnaringOverlay = 'root.dmi'
	BindBurn = 5
	BindBurnTicks = 15
	FacingPin = 1
	ManaCost = 6
	Cooldown = 18
	CooldownStatic = 1
	Consumes = list("Fire")
	ConsumeMinPool = 25
	PrimedBy = list("Fire")
	PrimeThreshold = 25
	LitCostMult = 0.5
	TitheRate = 0.15
	var/tmp/hold_ticks = 0
	OnConsume(mob/caster, mob/target, pool, amount)
		var/extra = round(amount / 25) * 5
		hold_ticks = min(initial(BindBurnTicks) + extra, 35)
		BindBurnTicks = hold_ticks
	OnSpellHitExtra(mob/caster, mob/m, atom/hitter)
		var/ticks = hold_ticks ? hold_ticks : initial(BindBurnTicks)
		hold_ticks = 0
		applySilence(m, ticks)
		if(ticks > initial(BindBurnTicks))
			spawn(1) ExtendHold(m, ticks)
		spawn() DrenchWatch(m, ticks)
		spawn(2) BindBurnTicks = initial(BindBurnTicks)
	proc/ExtendHold(mob/m, ticks)
		for(var/i = 0, i < 5, i++)
			if(!m) return
			var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare/sn = locate() in m
			if(sn && m.BuffOn(sn))
				sn.TimerLimit = ticks / 10
				return
			sleep(1)
	proc/DrenchWatch(mob/m, ticks)
		var/until = world.time + ticks
		while(m && world.time < until && !m.KO && !m.Dead)
			if(m.Drenched > 0)
				var/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/Snare/sn = locate() in m
				if(sn && m.BuffOn(sn)) sn.Trigger(m, 1)
				break
			sleep(2)
	verb/Leo_Palma()
		set name = "Leo Palma"
		set category = "Skills"
		usr.Activate(src)

obj/Skills/AutoHit/Fire/Hawk_Dive
	name = "Hawk Dive"
	IsSpell = 1
	Area = "Target"
	Distance = 6
	SilentCast = 1
	NoGCD = 1
	ManaCost = 0
	Cooldown = 0
	DamageMult = 0.4
	TurfBurn = 6
	HitSparkIcon = 'Explosion - Fire.dmi'
	HitSparkSize = 0.5

obj/Skills/Buffs/SlotlessBuffs/Fire/Halcon_Gardinas
	name = "Halcon Gardinas"
	BuffName = "Halcon Gardinas"
	SpellTier = 2
	SpellShape = "buff"
	PageKey = "N2"
	MenuIcon = "NovaStrike"
	Desc = "A hawk of flame takes wing around you and hunts your target, diving on it every few heartbeats and snapping enemy shots out of the air. Three quick hits crush its core. Press again while it lives to seize its back for a short flight, which ends the summon."
	TimerLimit = 12
	MiscBindable = 1
	ManaCost = 8
	Cooldown = 30
	EventRefund = list("intercept" = 2)
	EventRefundCap = list("intercept" = 3)
	ActiveMessage = "calls a hawk of flame to their side!"
	OffMessage = "lets the hawk of flame scatter into embers."
	Trigger(mob/User, Override)
		if(!User) return 0
		var/was = User.BuffOn(src)
		. = ..()
		var/now = User.BuffOn(src)
		if(!was && now)
			var/obj/Guardian/G = new(User, 12)
			G.dive_every = 20
			G.dive_range = 6
			G.dive_burn = 6
			G.dive_mult = 0.4
			G.intercept_every = 40
			G.break_hits = 3
			G.break_window = 80
			G.dive_path = /obj/Skills/AutoHit/Fire/Hawk_Dive
			spawn() Watch(User, G)
		else if(was && !now)
			var/obj/Guardian/G = User.guardian
			if(G && G.alive)
				G.expired_intact = 1
				User.GuardianExpired(G)
				G.Dismiss(1)
	proc/Watch(mob/User, obj/Guardian/G)
		while(User && User.BuffOn(src))
			if(!G || !G.alive || User.guardian != G)
				if(User.BuffOn(src)) Trigger(User, 1)
				return
			sleep(5)
	verb/Halcon_Gardinas()
		set name = "Halcon Gardinas"
		set category = "Skills"
		if(usr.guardian && usr.guardian.alive && usr.BuffOn(src))
			usr.GuardianCarry()
			return
		src.Trigger(usr)

obj/Skills/Projectile/Fire/Sol_Linea
	name = "Sol Linea"
	SpellTier = 2
	SpellShape = "line"
	PageKey = "32"
	MenuIcon = "Supernova"
	Desc = "A small sun gathers in your palm, then an instant lance of fire runs a straight line through every enemy on it, ignoring shields and guards. A target already burning hard has all its fire drawn out and spent at once, and the freed flame leaps onto those beside it. The sun turns white when the lance is ready to feed."
	IconLock = 'FireBlast.dmi'
	Piercing = 1
	Variation = 0
	Speed = 0.1
	Distance = 8
	DamageMult = 2.2
	ShieldPierce = 1
	Explode = 0
	TurfBurn = 8
	ManaCost = 6
	Cooldown = 15
	Consumes = list("Fire")
	ConsumeMinPool = 20
	TrueDamagePerPoint = 0.08
	TitheRate = 0.15
	PrimedBy = list("Fire")
	PrimeThreshold = 20
	LitCostMult = 0.5
	var/tmp/winding = 0
	OnConsume(mob/caster, mob/target, pool, amount)
		for(var/mob/o in range(1, target))
			if(o == target || o == caster || o.KO || o.Dead) continue
			if(caster.inParty(o.ckey)) continue
			o.AddBurn(8, caster, 1)
	proc/SunOrb(mob/p, lit)
		var/obj/Effects/KenShockwave/S = new
		S.icon = 'Icons/Effects/KenShockwave.dmi'
		S.color = lit ? "#ffffff" : "#ffa040"
		S.Size = 0.4
		S.Lifetime = 5
		S.loc = p.loc
		S.pixel_z = p.pixel_z
		if(PmActive())
			S.step_x = p.step_x
			S.step_y = p.step_y
	verb/Sol_Linea()
		set name = "Sol Linea"
		set category = "Skills"
		if(src.Using || src.cooldown_remaining || winding) return
		var/mob/p = usr
		if(p.GCDBlocked(src)) return
		winding = 1
		SunOrb(p, p.SpellLit(src))
		sleep(4)
		winding = 0
		if(!p || p.KO || p.Dead) return
		p.UseProjectile(src)

obj/Skills/Projectile/Fire/Crimus_Serbe
	name = "Crimus Serbe"
	SpellTier = 2
	SpellShape = "projectile"
	PageKey = "N8"
	MenuIcon = "DragonNova"
	Desc = "A serpent of flame that hunts your target, or bends toward wherever you face when you have none, leaving smouldering ground in its wake. It coils around whatever it catches, then bursts. Against a burning target it feeds on the fire and hurls the target away along a path that burns; if the throw is cut short by a wall or a body, the mana comes back."
	IconLock = 'FireTornadoHead.dmi'
	LockX = -44
	LockY = -44
	Trail = 'TrailFire.dmi'
	TrailSize = 1
	Homing = 1
	SteerRate = 45
	Distance = 7
	Speed = 0.5
	Explode = 1
	Knockback = 1
	TurfBurn = 10
	HoldTarget = 0.4
	ManaCost = 5
	Cooldown = 10
	Consumes = list("Fire")
	ConsumeAmount = 15
	ConsumeMinPool = 15
	PrimedBy = list("Fire")
	PrimeThreshold = 15
	LitCostMult = 0.5
	OwnRefund = 1
	SlamRefund = 1
	SlamShort = 2
	var/tmp/paid = 0
	OnConsume(mob/caster, mob/target, pool, amount)
		var/d = get_dir(caster, target)
		if(!d) d = caster.dir
		var/list/path = list()
		var/turf/T = get_turf(target)
		for(var/i = 1, i <= 3, i++)
			T = get_step(T, d)
			if(!T) break
			path += T
		caster.Knockback(3, target, d, 1)
		for(var/turf/G in path)
			caster.SpawnFireGround(G, 20, 2)
		caster.SlamMeasure(target, src, 3, caster.SpellManaNeed(src))
	verb/Crimus_Serbe()
		set name = "Crimus Serbe"
		set category = "Skills"
		usr.UseProjectile(src)

obj/Skills/Buffs/SlotlessBuffs/Fire/Mana_Skin
	SilentCast = 1
	name = "Mana Skin"
	BuffName = "Mana Skin"
	SpellTier = 2
	SpellShape = "mage passive"
	PageKey = "SHELF_M1"
	MenuIcon = "AdvancedFireMagic"
	Desc = "A coat of mana that never leaves your skin: fire bites less, burns settle in shallower, your own flames will not hurt you, and anyone who strikes you in melee singes their hand on the heat. The coat falls while you are exhausted."
	AlwaysOn = 1
	NeedsPassword = 0
	doNotDelete = 1
	TimerLimit = 0
	ManaCost = 0
	Cooldown = 0
	passives = list("FireResist" = 2, "BurnResist" = 2, "OwnFireImmune" = 1, "ContactBurn" = 5)
	New()
		..()
		spawn() Watch()
	proc/Watch()
		while(src)
			if(ismob(loc))
				var/mob/M = loc
				var/on = M.BuffOn(src)
				if(M.IsExhausted())
					if(on) Trigger(M, 1)
				else if(!on)
					Trigger(M, 1)
				sleep(20)
			else
				sleep(50)
