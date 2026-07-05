obj/Skills/Queue/DrillKnee
	ActiveMessage="forms a drill around their knee!"
	HitMessage="drives the drill into their opponent!"
	SBuffNeeded="King of Braves"
	DamageMult=12
	AccuracyMult = 1.175
	Instinct=1
	Duration=5
	KBMult=0.00001
	Cooldown=150
	Decider=1
	ShoryukenEffect=2
	Quaking=5
	PushOut=5
	PushOutWaves=3
	PushOutIcon='KenShockwaveLegend.dmi'
	verb/Drill_Knee()
		set category="Skills"
		usr.SetQueue(src)

/obj/Skills/AutoHit/Plasma_Hold
	Area = "Target"
	Snaring = 5
	SnaringOverlay='Overdrive.dmi'
	Distance=14
	DamageMult=1
	AdaptRate = 1
	ActiveMessage="shoots crackling plasma at their target!" //TODO: come back to this
	Cooldown=30
	verb/Plasma_Hold()
		set category="Skills"
		usr.Activate(src)