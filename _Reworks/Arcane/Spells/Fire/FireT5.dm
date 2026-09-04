obj/Skills/AutoHit/Fire/Vollzanbel
	name = "Vollzanbel"
	SpellTier = 5
	SpellShape = "line"
	PageKey = "CROWN"
	MenuIcon = "Supernova"
	Desc = "Pour hellfire into the staff, rooted and exposed while it gathers, then release a wall of flame that rolls seven tiles ahead of you and melts stone in its path. Everything it touches burns for all the fire already in it and loses sight of you for a moment, and hellfire lingers where the wave ends."
	HeldSkill = TRUE
	ChargePeriod = 2.5
	NoFizzle = TRUE
	HeldFreeze = 1
	HeldVulnerability = 0.25
	ChargeOverlay = 'FlameGlowHades.dmi'
	Area = "Wide Wave"
	Distance = 7
	DamageMult = 9
	TurfBurn = 0
	Consumes = list("Fire")
	TrueDamagePerPoint = 0.12
	TitheRate = 0.15
	TitheCap = 22
	StokeSecs = 10
	MeltConstructs = 1
	EventRefund = list("melt" = 3)
	EventRefundCap = list("melt" = 9)
	PrimedBy = list("Fire")
	PrimeThreshold = 30
	LitCostMult = 0.5
	ManaCost = 22
	Cooldown = 75
	HitSparkIcon = 'fevExplosion - Hellfire.dmi'
	HitSparkX = -32
	HitSparkY = -32
	OnHeldStart(mob/p)
		p.RemoveTarget()
		p.target_lock_block_until = world.time + 30
	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		DamageMult = initial(DamageMult) * (0.5 + 0.5 * benefit)
		p.Activate(src, noGCD = TRUE)
		spawn(10) DamageMult = initial(DamageMult)
	OnHeldFizzle(mob/p)
		DamageMult = initial(DamageMult)
	OnRound(mob/p, remaining)
		..()
		p.MeltConstructsAround(p, 7, src)
	OnSpellHitExtra(mob/caster, mob/m, atom/hitter)
		m.target_lock_block_until = world.time + 10
		if(m.Target == caster) m.RemoveTarget()
	OnRoundsDone(mob/p)
		..()
		var/turf/T = get_turf(p)
		for(var/i = 1, i <= 7, i++)
			var/turf/N = get_step(T, p.dir)
			if(!N || N.density) break
			T = N
		spawn(8)
			if(p) p.SpawnFireGround(T, 20, 5, 0.02, 1)
	verb/Vollzanbel()
		set name = "Vollzanbel"
		set category = "Skills"
		usr.BeginHeldSkill(src)

obj/Skills/AutoHit/Fire/Calidus_Brachium_Purgatory
	name = "Mana Zone Full Release: Calidus Brachium Purgatory"
	SpellTier = 5
	SpellShape = "autohit"
	PageKey = "N6"
	MenuIcon = "NovaStrike"
	Desc = "Pour every drop of your mana into a storm of blue flame around you for three breaths: stone inside melts, enemies burn and their mana burns away with them, and the last blow spends all the fire already in them. Afterwards you are spent for a while, unable to cast and easier to hurt."
	Area = "Circle"
	Distance = 6
	Rounds = 6
	DelayTime = 5
	RoundMovement = 0
	GuardBreak = 1
	ManaCostAll = 1
	ManaMinPct = 0.4
	ManaCost = 1
	Cooldown = 90
	DamageMult = 1.5
	StrScaling = 0.5
	ForScaling = 0.5
	TurfBurn = 8
	EnemyManaDrainPct = 0.05
	MeltConstructs = 1
	TrueDamagePerPoint = 0.12
	OwnRefund = 1
	StokeSecs = 0
	PrimedBy = list("Fire")
	PrimeThreshold = 30
	HitSparkIcon = 'Flame Spiral Blue.dmi'
	HitSparkX = -44
	HitSparkY = -44
	OnRound(mob/p, remaining)
		..()
		if(remaining == Rounds) p.MeltConstructsAround(p, 6, src)
		if(remaining == 1) Consumes = list("Fire")
	OnRoundsDone(mob/p)
		..()
		Consumes = null
		DamageMult = initial(DamageMult)
		applyExhausted(p, 6)
		p.DealWounds(p, p.PctToHP(2))
	verb/Calidus_Brachium_Purgatory()
		set name = "Calidus Brachium Purgatory"
		set category = "Skills"
		if(usr.ManaAmount < usr.ManaCap() * ManaMinPct)
			usr << "<font color=red>You do not have enough mana left in you to release Purgatory.</font>"
			return
		DamageMult = initial(DamageMult) * (1 + usr.ManaAmount / usr.ManaCap())
		usr.Activate(src)

obj/Skills/Buffs/SlotlessBuffs/Fire/Spirit_Dive
	name = "Spirit Dive: Salamander"
	BuffName = "Spirit Dive: Salamander"
	SpellTier = 5
	SpellShape = "pinnacle"
	PageKey = "SHELF_P"
	MenuIcon = "DragonNova"
	Desc = "Let the fire spirit sink into your arms for a time: scales, horns and wings of flame. Your fire burns hotter and deeper, boils the water off whatever it touches, and the spirit shows you every burning enemy near you while your mana slowly feeds it. It crumbles if you run dry or are badly hurt, and leaves you drained for a while afterwards."
	TimerLimit = 20
	MiscBindable = 1
	ManaCost = 25
	Cooldown = 120
	IconLock = 'FlameGlowHades.dmi'
	AuraArt = 1
	LockX = -16
	LockY = -4
	CrumbleBelowPct = 20
	passives = list("Scorching" = 8)
	ActiveMessage = "lets the fire spirit sink into their arms; scales, horns and wings of flame take shape."
	OffMessage = "shudders as the spirit's fire leaves them."
	var/tmp/dive_run = 0
	var/tmp/list/sense_images
	Trigger(mob/User, Override)
		var/was = User.BuffOn(src)
		. = ..()
		var/now = User.BuffOn(src)
		if(!was && now)
			User.AddElementPower("Fire", 0.3)
			User.burn_boil = 20
			User.bonus_burn = 10
			User.spirit_dive_on = 1
			dive_run++
			spawn() DiveLoop(User, dive_run)
		else if(was && !now)
			User.AddElementPower("Fire", -0.3)
			User.burn_boil = 0
			User.bonus_burn = 0
			User.spirit_dive_on = 0
			SenseClear(User)
			User.AfterFormDebuff(/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Debuff/SpiritFatigue, 10)
	proc/DiveLoop(mob/User, run)
		while(User && dive_run == run && User.BuffOn(src))
			sleep(10)
			if(!User || dive_run != run || !User.BuffOn(src)) break
			User.LoseMana(1, 1)
			if(User.ManaAmount <= 0 || User.HealthPct() < CrumbleBelowPct)
				Trigger(User, 1)
				break
			SenseRefresh(User)
	proc/SenseRefresh(mob/User)
		SenseClear(User)
		if(!User.client) return
		sense_images = list()
		for(var/mob/m in range(8, User))
			if(m == User || m.KO || m.Dead || m.Burn <= 0) continue
			if(User.inParty(m.ckey)) continue
			var/image/I = image(m)
			I.loc = m
			I.color = "#ff8c1a"
			I.alpha = 120
			I.layer = m.layer + 0.1
			I.filters = filter(type = "outline", size = 1, color = "#ff8c1a")
			sense_images += I
		User.client.images += sense_images
	proc/SenseClear(mob/User)
		if(!sense_images) return
		if(User && User.client) User.client.images -= sense_images
		sense_images = null
	verb/Spirit_Dive()
		set name = "Spirit Dive"
		set category = "Skills"
		src.Trigger(usr)
