/obj/Skills/Projectile/Cataclysmic_Orb
	SkillCost=TIER_5_COST
	Copyable=6
	EnergyCost=20
	Speed = 2
	Distance=20
	Blasts=30
	Charge=1
	DamageMult=3
	ComboMaster=1
	Stunner= 3
	Instinct=1
	AccMult=2
	Homing=3
	Explode=1
	ZoneAttackX=8
	ZoneAttackY=8
	IconLock='Plasma.dmi'
	LockX=0
	LockY=0
	Hover=7
	Variation=0
	Cooldown = 150
	ActiveMessage="Kicks up a Barrage of Orbs, creating an inescapable trap!"
	verb/Cataclysmic_Orb()
		set category="Skills"
		usr.UseProjectile(src)
