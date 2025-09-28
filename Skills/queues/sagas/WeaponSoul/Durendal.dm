obj/Skills/Queue/Blazing_Slash
	ActiveMessage="channels the might of ancient saints into a slash worthy of a pyre!"
	DamageMult=2.5
	AccuracyMult=3
	KBMult=3
	SweepStrike=1
	Burning = 25
	Duration = 5
	Cooldown=30
	NeedsSword=1
	EnergyCost=5
	FollowUp = "/obj/Skills/Queue/Blazing_Slash_Part_2"
	Launcher = 3
	HitSparkIcon='Fire Slash.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkSize=1.5
	verb/Blazing_Slash()
		set category="Skills"
		usr.SetQueue(src)

obj/Skills/Queue/Blazing_Slash_Part_2
	SagaSignature=1
	DamageMult=0.75
	Dunker=1
	AccuracyMult=5
	KBMult=0.00001
	Shining=1
	Duration=5
	Projectile="/obj/Skills/Projectile/BlazingSlashProjectile"
	Cooldown=1
	Instinct=1
	EnergyCost=2

obj/Skills/Projectile/BlazingSlashProjectile
	IconLock='DurendalBurn.dmi'
	LockX=-32
	LockY=-46
	IconSize=0.5
	Dodgeable=-1
	Burning=1
	Radius=1
	Striking=1
	ZoneAttack=1
	ZoneAttackX=0
	ZoneAttackY=0
	FireFromSelf=1
	FireFromEnemy=0
	Variation=0
	Speed=0.75
	StrRate=1
	ForRate=0
	EndRate=1
	Knockback=1
	MultiHit=8
	DamageMult=0.5
	AccMult=2
	Deflectable=0
	Distance=10
	Instinct=2