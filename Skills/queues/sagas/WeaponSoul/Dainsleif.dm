obj/Skills/Queue/Cursed_Blade
	ActiveMessage="channels the ruin of their legendary weapon into each and every attack...!"
	DamageMult=1
	AccuracyMult=3
	Combo = 5
	Shearing = 20
	SweepStrike=1
	Warp = 1
	NoWhiff = 1
	Duration = 5
	Cooldown=30
	NeedsSword=1
	EnergyCost=5
	HitSparkIcon='Slash - Zero.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkSize=1.5
	adjust(mob/p)
		if(p.cursedSheathValue)
			DamageMult = 1.5 + p.cursedSheathValue/200
			Combo = 5 + p.cursedSheathValue/100
	verb/Cursed_Blade()
		set category="Skills"
		adjust(usr)
		usr.SetQueue(src)

