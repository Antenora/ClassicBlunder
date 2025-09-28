/obj/Skills/AutoHit
	Shitenketsu
		FlickAttack=3
		Area="Circle"
		NoLock=1
		NoAttackLock=1
		StrOffense=1
		Rush=3
		Rounds=5
		DamageMult=2
		ControlledRush=3
		Launcher=3
		DelayedLauncher=1
		ComboMaster=1
		HitSparkIcon='Hit Effect.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkCount=10
		HitSparkDispersion=12
	Jarret_Jarret
		Area="Circle"
		NoLock=1
		NoAttackLock=1
		RoundMovement=0
		Distance=3
		Instinct=4
		DamageMult=1.5
		Rounds=10
		ComboMaster = 1
		StrOffense=1
		EndDefense=1
		WindUp=0.2
		CanBeDodged=1
		WindupMessage="sets themselves into a handstand..."
		ActiveMessage="lets their legs rip like a top!!"
		Icon='SweepingKick.dmi'
		IconX=-32
		IconY=-32
		IconTime=10
		Cooldown=4
	Ice_Ply
		AdaptRate = 1
		SpecialAttack=1
		DamageMult=4
		Stasis=5
		TurfShift='IceGround.dmi'
		Distance=5
		Area="Circle"
	Dantes_Inferno
		Area = "Circle"
		Distance = 8
		Size = 1
		TurfShift = 'Flaming Rain.dmi'
		Scorching = 15
		Rounds = 5
		SpecialAttack = 1
		DamageMult = 0.33
		AdaptRate = 1
		EndDefense = 0.75
	Flashfire_Fist
		Area = "Wave"
		TurfShift='BurnedGround.dmi'
		Distance=5
		SpecialAttack = 1
		Size = 3
		DamageMult = 4
		AdaptRate = 1
		Rush = 3
		EndDefense = 1
		Scorching = 50
	
	Pinning_Stake
		Area = "Target"
		Snaring = 4
		Distance = 4
		DamageMult = 4
		AdaptRate = 1
		Shattering = 25
		HitSparkIcon='HitsparkStar.dmi'
	
	Beef_Burst
		Area="Wide Wave"
		NoLock=1
		NoAttackLock=1
		Distance=5
		DamageMult=2
		StrOffense=1
		ForOffense=1
		EndDefense=1
		Knockback=10
		Scorching=30
		ActiveMessage="follows up with an incendiary kick!!"
		HitSparkIcon='Hit Effect Ripple.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkSize=3
		HitSparkTurns=0
		HitSparkLife=7
		TurfStrike=1
		TurfShift='Dirt1.dmi'
		TurfShiftDuration=30
		Cooldown=4
	

	Rupture
		Area = "Target"
		NoLock=1
		NoAttackLock=1
		Distance=50
		DamageMult=3
		StrOffense=1
		ForOffense=1
		EndDefense=1
		Cooldown=4
		BuffAffected=/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ruptured
		//TODO: finish
	