obj/Skills/Queue/Thunder_Wave
	DamageMult=0.75
	Instinct=3
	Launcher=1
	Paralyzing=10
	AccuracyMult = 1.25
	KBAdd=3
	InstantStrikes=10
	InstantStrikesDelay=1.5
	PrecisionStrike=500
	Duration=5
	IconLock=1
	HitSparkIcon='Slash - Zero.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkSize=2
	HitSparkTurns=1
	Cooldown=150
	ActiveMessage="sends Andromeda's shackles for an endless pursuit after their target!"
	verb/Thunder_Wave()
		set category="Skills"
		usr.SetQueue(src)