/obj/Skills/Projectile/Magic/Call_Calamity
	ElementalClass="Fire"
	Blasts = 3
	Distance=50
	DamageMult=10
	Dodgeable=-1
	AccMult = 1.175
	Speed=2
	EndEffectiveness = 1
	ManaCost=60
	Cooldown=150
	IconLock='Boulder Normal.dmi'
	IconSize=2
	LockX=-36
	LockY=-36
	ComboMaster=1
	Variation=0
	ZoneAttack=1
	ZoneAttackX=12
	ZoneAttackY=12
	Homing=1
	LosesHoming=100
	HyperHoming=1
	FireFromEnemy=1
	Radius=1
	Shattering=10
	Scorching=10
	Variation=0
	Explode=2
	Hover=1
	adjust(mob/p)
		DamageMult = initial(DamageMult)
    // lol, i will never finish this