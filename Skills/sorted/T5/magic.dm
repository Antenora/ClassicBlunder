/obj/Skills/Projectile/Magic/Meteor_Swarm
	ElementalClass="Fire"
	SkillCost=TIER_5_COST
	Copyable=6
	PreRequisite=list("/obj/Skills/Projectile/Magic/Meteor")
	Blasts = 8
	Distance=20
	DamageMult=3
	Dodgeable=-1
	AccMult = 1.175
	Speed=2
	EndRate = 1
	ManaCost=60
	Cooldown=150
	IconLock='Boulder Normal.dmi'
	IconSize=2
	LockX=-36
	LockY=-36
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
	ActiveMessage="invokes: <font size=+1>METEORA!</font size>"
	adjust(mob/p)
		DamageMult = initial(DamageMult)
	verb/Meteor_Swarm()
		set category="Skills"
		adjust(usr)
		usr.UseProjectile(src)
/obj/Skills/Projectile/Magic/Call_Calamity
	ElementalClass="Fire"
	Blasts = 3
	Distance=50
	DamageMult=10
	Dodgeable=-1
	AccMult = 1.175
	Speed=2
	EndRate = 1
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