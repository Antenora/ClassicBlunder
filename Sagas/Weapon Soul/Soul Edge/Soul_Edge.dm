obj/Items/Sword/Heavy/Legendary/WeaponSoul/Blade_of_Chaos
	name="Blade of Chaos"
	icon='SoulEdge.dmi'
	ExtraClass=1
	Ascended=6
	passives = list("Extend" = 1)
	Destructable=0
	ShatterTier=0

obj/Skills/AutoHit/Soul_Drain
	NeedsSword=1
	Distance=10
	DistanceAround=6
	Gravity=5
	WindUp=1
	WindupMessage="channels the chaos of Soul Edge...."
	DamageMult=1.95
	StrScaling=1
	ActiveMessage="unleashes a tidal wave of chaos into the area!"
	Area="Around Target"
	GuardBreak=1
	PassThrough=1
	MortalBlow=0.25
	HitSparkIcon = null
	TurfStrike=1
	TurfShiftLayer=EFFECTS_LAYER
	TurfShiftDuration=-10
	TurfShiftDurationSpawn=0
	TurfShiftDurationDespawn=5
	TurfShift='Gravity.dmi'
	Cooldown=8
	EnergyCost=2
	Instinct=1
	adjust(mob/p)
		DamageMult = (5 + p.SagaLevel) * 0.195
		WindUp = 1 - p.SagaLevel/10
	verb/Soul_Drain()
		set category="Skills"
		adjust(usr)
		usr.Activate(src)

obj/Skills/AutoHit/Dark_Reconquista
	NeedsSword=1
	Copyable=2
	Area="Wide Wave"
	ComboMaster=1
	Distance=2
	StrScaling=1
	EndEffectiveness=1
	DamageMult=4.25
	HitSparkIcon='Slash - Vampire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=1.5
	HitSparkDispersion=1
	TurfStrike=2
	TurfShift='Dirt1.dmi'
	TurfShiftDuration=3
	EnergyCost=2
	Cooldown=10
	ActiveMessage="draws back Soul Edge and drives it forward in a devastating, soul-rending slash!"
	HeldSkill=TRUE
	ChargePeriod=3
	SweetSpot=1.5
	SweetSpotBenefit=3
	ChargeOverlay='DarkShock.dmi'
	ChargeWaveIcon='KenShockwaveBloodlust.dmi'
	ChargeWaveBlend=2

	adjust(mob/p)
		DamageMult = (10 + p.SagaLevel) * 0.2833

	OnHeldRelease(mob/p, var/benefit)
		adjust(p)
		DamageMult *= benefit
		Distance = (benefit * 3)
		p.Activate(src, noGCD = TRUE)

	verb/Dark_Reconquista()
		set category="Skills"
		usr.BeginHeldSkill(src)

// Automatic followup AutoHit triggered when Triumph's sweet spot is hit.
/obj/Skills/AutoHit/Reconquista_Triumph_Strike
	Area = "Circle"
	StrScaling = 1
	DamageMult = 0.43
	ComboMaster = 1
	Rounds = 10
	ChargeTech = 1
	ChargeFlight = 1
	ChargeTime = 0.75
	Grapple = 1
	GrabMaster = 1
	Stunner = 1
	Launcher = 1
	Cooldown = 1
	Size = 1
	EnergyCost = 5
	Instinct = 1
	Icon='DarkPortal.dmi'
	IconX=-35
	IconY=-35
	ActiveMessage = "drives Soul Edge home with a conquering lunge!"

/obj/Skills/AutoHit/Dark_Reconquista_Triumph
	parent_type = /obj/Skills/AutoHit/Wave
	name = "Triumph"
	NeedsSword = 1
	Copyable = 2
	StrScaling = 1
	EndEffectiveness = 1
	Cooldown = 30
	EnergyCost = 8
	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 2
	SweetSpotBenefit = 4
	ChargeOverlay = 'DarkShock.dmi'
	ChargeWaveIcon = 'KenShockwaveBloodlust.dmi'
	ChargeWaveBlend = 2
	WaveIcon = 'KenShockwavePurple.dmi'
	WaveLifetime = 30

	OnHeldRelease(mob/p, var/benefit, var/sweet_spot_hit = FALSE)
		if(EnergyCost)   
			var/drain = p.passive_handler["Drained"] ? EnergyCost * (1 + p.passive_handler["Drained"]/10) : EnergyCost
			p.LoseEnergy(drain)
		DamageMult = (15 + p.SagaLevel) * benefit * 0.1712
		spawnWave(p)
		if(sweet_spot_hit)
			p.throwFollowUp(/obj/Skills/AutoHit/Reconquista_Triumph_Strike)

	verb/Triumph()
		set category = "Skills"
		usr.BeginHeldSkill(src)

obj/Skills/Buffs/SpecialBuffs/Heavenly_Regalia/Soul_Edge
	name = "Heavenly Regalia: Chaos Armament"
	StrMult=1.3
	OffMult=1.3
	EndMult=1.3
	passives = list( "Momentum" = 2)
	IconLock='EyeFlameC.dmi'
	ActiveMessage="'s chaotic treasures ring in resonance: Heavenly Regalia!"
	OffMessage="'s treasures lose their chaotic luster..."
	verb/Heavenly_Regalia()
		set category="Skills"
		src.Trigger(usr)


/obj/Skills/Buffs/NuStyle/SwordStyle //slightly weaker than t2. maybe make it scaling???
	Stained_Memories
		StyleActive="Stained Memories"
		passives = list( "Shearing" = 2)
		StyleEnd=1.25
		StyleStr=1.25
		Finisher="/obj/Skills/Queue/Finisher/Rook_Splitter"
		adjust(mob/p)
			StyleStr = 1.15 + (0.15 * p.SagaLevel)
			StyleEnd = 1.15 + (0.15 * p.SagaLevel)
			passives["Shearing"] = 2+p.SagaLevel
		verb/Stained_Memories()
			set hidden=1
			adjust(usr)
			Trigger(usr)


/obj/Skills/Queue/Finisher
	Rook_Splitter
		DamageMult=8
		HitSparkIcon='Slash - Zan.dmi'
		HitSparkX=-32
		HitSparkY=-32
		BuffSelf="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Grim_Lord"
		HitMessage = "crushes the very world with the might of Soul Edge!"
/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher
	Grim_Lord
		StrMult=1.3
		EndMult=1.3
