/obj/Skills/AutoHit/Hollow/Trample
	name = "Trample"
	Area = "Circle"
	Distance = 4
	StrScaling = 1
	DamageMult = 3.2
	Knockback = 4
	WindUp = 1.5
	Cooldown = 6
	EnergyCost = 1
	WindupMessage = "rears back on its enormous legs!"
	ActiveMessage = "brings its full weight down and shakes the ground!"
	TurfErupt = 2
	TurfEruptOffset = 4
	Earthshaking = 12
	HitSparkIcon = 'Hit Effect.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkSize = 2
	HitSparkTurns = 0
	TurfStrike = 3
	TurfShift = 'Dirt1.dmi'
	TurfShiftDuration = 4

	verb/Trample()
		set name = "Trample"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Projectile/Beams/Big/Hollow

/obj/Skills/Projectile/Beams/Big/Hollow/Cero
	name = "Cero"
	DamageMult = 0.38
	Cooldown = 12
	ManaCost = 3
	Distance = 40
	BeamTime = 10
	HeldSkill = TRUE
	HeldBeam = TRUE
	ChargePeriod = 2
	CritEffectiveness = 0
	ActiveMessage = "fires a Cero!"
	IconLock = 'Cero.dmi'
	IconSize = 1.5
	LockX = 0
	LockY = 0

	verb/Cero()
		set name = "Cero"
		set category = "Skills"
		usr.BeginHeldSkill(src)

/obj/Skills/Projectile/Beams/Big/Hollow/Gran_Rey_Cero
	name = "Gran Rey Cero"
	DamageMult = 1.02
	Cooldown = 40
	ManaCost = 6
	HealthCost = 8
	Distance = 50
	BeamTime = 10
	HeldSkill = TRUE
	HeldBeam = TRUE
	ChargePeriod = 4
	CritEffectiveness = 0
	ActiveMessage = "mixes their own blood into the blast and fires a Gran Rey Cero!"
	IconLock = 'Gran Rey Cero.dmi'
	IconSize = 2
	LockX = 0
	LockY = 0

	verb/Gran_Rey_Cero()
		set name = "Gran Rey Cero"
		set category = "Skills"
		usr.BeginHeldSkill(src)

/obj/Skills/Projectile/Beams/Big/Hollow/Cero_Oscuras
	name = "Cero Oscuras"
	DamageMult = 1.23
	Cooldown = 60
	ManaCost = 12
	Distance = 60
	BeamTime = 10
	HeldSkill = TRUE
	HeldBeam = TRUE
	ChargePeriod = 5
	CritEffectiveness = 0
	ActiveMessage = "fires a pitch black Cero Oscuras!"
	IconLock = 'BlackGetsuga.dmi'
	IconSize = 2
	LockX = 0
	LockY = 0

	verb/Cero_Oscuras()
		set name = "Cero Oscuras"
		set category = "Skills"
		usr.BeginHeldSkill(src)
