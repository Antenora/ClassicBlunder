obj/Skills/Queue/Antares
	UnarmedOnly=1
	CosmoPowered=1
	Warp=5
	DamageMult=13
	AccuracyMult = 1.175
	Instinct=4
	Duration=5
	Dominator=1
	Stunner=3
	KBMult=0.00001
	Projectile="/obj/Skills/Projectile/Scarlet_Needle"
	PushOutIcon='KenShockwaveBloodlust.dmi'
	PushOutWaves=3
	PushOut=1
	HitSparkIcon='Hit Effect Vampire.dmi'
	ActiveMessage="raises their sting to execute a sure kill technique!"
	Cooldown=-1
	verb/Antares()
		set category="Skills"
		src.MortalBlow=(usr.Target.SenseRobbed*0.2)
		usr.SetQueue(src)