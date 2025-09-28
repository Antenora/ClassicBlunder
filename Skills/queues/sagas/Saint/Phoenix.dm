obj/Skills/Queue/Phoenix_Demon_Illusion_Strike
	UnarmedOnly=1
	CosmoPowered=1
	DamageMult=4.5
	AccuracyMult = 1.25
	Instinct=4
	Duration=5
	Warp=10
	Stunner=6
	Crippling=5
	BuffAffected="/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Demon_Illusion"
	Cooldown=-1
	IconLock=1
	HitSparkIcon='Hit Effect Ripple.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkSize=0.5
	HitMessage="scrambles the opponent's mind with the power of Phoenix!"
	verb/Phoenix_Demon_Illusion_Strike()
		set category="Skills"
		set name="Houou Genmaken"
		usr.SetQueue(src)