obj/Skills/Queue/Piranhan_Rose
	UnarmedOnly=1
	CosmoPowered=1
	DamageMult=0.85
	KBAdd=1
	AccuracyMult = 1.25
	Instinct=4
	Duration=5
	PrecisionStrike=10
	InstantStrikes=10
	InstantStrikesDelay=2
	PridefulRage=1
	HitSparkIcon='fevExplosion - Hellfire.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkSize=0.3
	ActiveMessage="grasps a handful of pitch-black roses..."
	HitMessage="throws the black roses which eat away at everything they touch!"
	Cooldown=150
	verb/Piranhan_Rose()
		set category="Skills"
		usr.SetQueue(src)