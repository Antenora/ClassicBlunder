obj/Skills/Queue/Acubens
	UnarmedOnly=1
	CosmoPowered=1
	DamageMult=9
	AccuracyMult = 1.25
	Instinct=5
	Duration=3
	Counter=1
	Warp=1
	Grapple=1
	KBMult=0.001
	GrabTrigger="/obj/Skills/Grapple/Sword/Hacksaw/Cancer_Snap"
	IconLock=1
	HitSparkIcon='BLANK.dmi'
	HitMessage="snaps the opponent in half with their legs emulating Cancer pincers!"
	Cooldown=150
	verb/Acubens()
		set category="Skills"
		usr.SetQueue(src)