/obj/Skills/AutoHit
	Flash_Draw//sword
		Area = "Cross"
		ComboMaster = 1
		NoLock = 1
		NoAttackLock = 1
		Rounds = 2
		StrOffense = 1
		DamageMult = 2.2
		Instinct = 2
		Distance = 4
		Size = 2
		Knockback = 1
		SpeedStrike = 2
		Stunner = 1
		ShockIcon = 'KenShockwaveGod.dmi'
		Shockwaves = 0
		Shockwave = 0
		TurfStrike = 5
		HitSparkIcon = 'Slash - Power.dmi'
		HitSparkX = -32
		HitSparkY = -32
		HitSparkSize = 2
		HitSparkTurns = 1
		HitSparkLife = 6
		ActiveMessage = "reappears behind their target, a volley of blinding cuts flash across the field!"
		Cooldown = 4

	Prismatic_Bloom//mystic
		Area = "Around Target"
		NoLock = 1
		NoAttackLock = 1
		AdaptRate = 1
		Distance = 3
		DistanceAround = 3
		Rounds = 4
		IgnoreAlreadyHit = 1
		DamageMult = 1.8
		ForOffense = 1
		EndDefense = 0.75
		Instinct = 2
		TurfShift = 'SparkleRainbow.dmi'
		TurfShiftDuration = 12
		HitSparkIcon = 'Hit Effect Divine.dmi'
		HitSparkX = -32
		HitSparkY = -32
		HitSparkSize = 3
		HitSparkTurns = 0
		HitSparkLife = 8
		ActiveMessage = "erupts in a prismatic storm that dazzles all nearby foes!"
		Cooldown = 4

	Tranquil_Burst//martial
		UnarmedOnly = 1
		Area = "Strike"
		NoLock = 1
		NoAttackLock = 1
		StrOffense = 2
		DamageMult = 2.4
		Instinct = 2
		Stunner = 2
		Quaking = 4
		PreShockwave = 1
		PreShockwaveDelay = 1
		Shockwaves = 2
		Shockwave = 3
		ShockIcon = 'KenShockwaveDivine.dmi'
		ShockBlend = 2
		ShockDiminish = 1.2
		ShockTime = 5
		TurfErupt = 1.5
		TurfEruptOffset = 6
		HitSparkIcon = 'Hit Effect Ripple.dmi'
		HitSparkX = -32
		HitSparkY = -32
		HitSparkSize = 2
		HitSparkTurns = 1
		HitSparkLife = 7
		ActiveMessage = "releases a tranquil shockwave that quakes the ground with serene power!"
		Cooldown = 4

obj/Skills/Grapple
	Instinct_Reversal//grapple
		Reversal = 1
		OneAndDone = 1
		DamageMult = 4
		StrRate = 1
		EndRate = 0.9
		ThrowAdd = 2
		ThrowMult = 1.25
		ThrowSpeed = 1.25
		Effect = "Lotus"
		EffectMult = 2
		Stunner = 3
		Instinct = 2
		TriggerMessage = "instinctively reverses and throws"