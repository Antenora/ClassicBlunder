/obj/Skills/AutoHit
	Shitenketsu
		FlickAttack=3
		Area="Circle"
		NoLock=1
		NoAttackLock=1
		StrScaling=1
		Rush=3
		Rounds=5
		DamageMult = T2_DMG_MULT/2/5;
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
		DamageMult = T2_DMG_MULT/2/10;
		Rounds=10
		ComboMaster = 1
		StrScaling=1
		EndEffectiveness=1
		WindUp=0.2
		CanBeDodged=1
		WindupMessage="sets themselves into a handstand..."
		ActiveMessage="lets their legs rip like a top!!"
		Icon='SweepingKick.dmi'
		IconX=-32
		IconY=-32
		Cooldown=4
	Ice_Ply
		SpecialAttack=1
		DamageMult = T2_DMG_MULT/2;
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
		DamageMult = T2_DMG_MULT / 2 / 5;
		EndEffectiveness = 0.75
	Flashfire_Fist
		Area = "Wave"
		TurfShift='BurnedGround.dmi'
		Distance=5
		SpecialAttack = 1
		Size = 3
		DamageMult = T2_DMG_MULT / 2;
		Rush = 3
		EndEffectiveness = 1
		Scorching = 50

	Pinning_Stake
		Area = "Target"
		Snaring = 4
		Distance = 4
		DamageMult = T2_DMG_MULT / 2;
		Shattering = 25
		HitSparkIcon='HitsparkStar.dmi'

	Beef_Burst
		Area="Wide Wave"
		NoLock=1
		NoAttackLock=1
		Distance=5
		DamageMult = T2_DMG_MULT / 2;
		StrScaling=1
		ForScaling=1
		EndEffectiveness=1
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
		DamageMult= T2_DMG_MULT / 2;
		StrScaling=1
		ForScaling=1
		EndEffectiveness=1
		Cooldown=4
		BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/QueueBuff/Finisher/Ruptured"
		//TODO: finish
