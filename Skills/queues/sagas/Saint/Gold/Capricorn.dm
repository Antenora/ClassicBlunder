obj/Skills/Queue/Jumping_Stone
	UnarmedOnly=1
	CosmoPowered=1
	DamageMult=11
	AccuracyMult = 1.25
	Instinct=5
	Duration=3
	Counter=1
	Grapple=1
	KBMult=0.001
	GrabTrigger="/obj/Skills/Grapple/Lotus_Drop"
	IconLock=1
	HitSparkIcon='BLANK.dmi'
	HitMessage="counters the opponent with the swift agility of Capricorn!"
	Cooldown=150
	verb/Jumping_Stone()
		set category="Skills"
		usr.SetQueue(src)