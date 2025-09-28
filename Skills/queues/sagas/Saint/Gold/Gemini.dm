obj/Skills/Queue/Demon_Emperor_Fist
	UnarmedOnly=1
	CosmoPowered=1
	DamageMult=4.5
	AccuracyMult = 1.25
	Instinct=4
	Duration=5
	PrecisionStrike=10
	BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Demon_Grasp"
	Cooldown=-1
	IconLock=1
	HitSparkIcon='Hit Effect Satsui.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkSize=0.5
	HitMessage="forces their opponent to obey them with the Demon Emperor Fist!"
	verb/Demon_Emperor_Fist()
		set category="Skills"
		set name="Genrou Maou Ken"
		usr.SetQueue(src)