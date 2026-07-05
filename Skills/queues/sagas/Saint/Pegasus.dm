
obj/Skills/Queue/Pegasus_Rolling_Crash
	UnarmedOnly=1
	CosmoPowered=1
	DamageMult=9
	AccuracyMult = 1.175
	Instinct=4
	Duration=5
	Warp=1
	Grapple=1
	KBMult=0.001
	GrabTrigger="/obj/Skills/Grapple/Lotus_Drop"
	IconLock=1
	HitSparkIcon='BLANK.dmi'
	HitMessage="flies their opponent high on the wings of Pegasus!"
	Cooldown=150
	verb/Pegasus_Rolling_Crash()
		set category="Skills"
		usr.SetQueue(src)