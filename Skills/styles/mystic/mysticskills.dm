
/obj/Skills/Buffs/
	var/SlotlessBuffNeeded = null
/obj/Skills/Buffs/SlotlessBuffs/Magmic_Shield
	passives = list("Magmic" = 1)
	Cooldown = 120
	TimerLimit = 0
	BuffName = "Magmic Shield"
	name = "Magmic Shield"
	SlotlessBuffNeeded = "Earth"
	ActiveMessage = "erupts a magmic shield before themselves!"
	verb/Magmic_Shield()
		set category = "Skills"
		src.Trigger(usr)
		

/obj/Skills/AutoHit/Hurricane
	ElementalClass="Wind"
	Distance=12
	DistanceAround = 3
	Size = 2
	NoLock = 1 
	/*TurfShift = 'Air Slash.dmi'
	TurfShiftDuration=3
	TurfStrike=2*/
	Area="Around Target"
	Rounds = 5
	DamageMult = 0.1
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	AdaptRate = 1
	Shocking = 10
	Paralyzing=5
	SpecialAttack=1
	CanBeDodged=1
	Cooldown = 5
/obj/Skills/AutoHit/Thunder_Bolt
	ElementalClass="Wind"
	Distance=12
	NoAttackLock=1
	Area="Target"
	NoLock = 1 
	AdaptRate=1
	DamageMult=1.5
	Paralyzing=15
	Size=1
	Bolt=2
	SpecialAttack=1
	CanBeDodged=0
	CanBeBlocked=0
	Cooldown = 0.5
	adjust(mob/p)
		Cooldown = max(1 - (p.Potential/110), 0.1)
		Paralyzing = 5 + p.Potential/2
		DamageMult = 0.5 + round(p.Potential/50)
/obj/Skills/AutoHit/Icy_Wind
	ElementalClass="Water"
	NoAttackLock=1
	NoLock = 1 
	Area="Around Target"
	AdaptRate=1
	DamageMult=1.25
	Freezing=15
	Distance=12
	DistanceAround = 1
	Size = 2
	/*TurfShift = 'Blizzard.dmi'
	TurfShiftDuration=3
	TurfStrike=2*/
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	SpecialAttack=1
	CanBeDodged=0
	CanBeBlocked=0
	Cooldown = 0.5
	adjust(mob/p)
		Cooldown = max(1.5 - (p.Potential/110), 0.1)
		Freezing = 15 + p.Potential/2
		DamageMult = 1 + round(p.Potential/50)
		Rounds = 5 + round(p.Potential/20)
/obj/Skills/AutoHit/HellfireRain
	ElementalClass="Hellfire"
	NoAttackLock=1
	Area="Around Target"
	AdaptRate=1
	NoLock = 1 
	DamageMult=0.5
	Distance=12
	DistanceAround = 3
	Rounds=5
	DarknessFlame = 6
	Size = 2
	/*TurfShift = 'Flaming Rain.dmi'
	TurfShiftDuration=3
	TurfStrike=2*/
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	SpecialAttack=1
	CanBeDodged=0
	CanBeBlocked=0
	Cooldown = 0.5
	adjust(mob/p)
		Cooldown = max(2 - (p.Potential/110), 0.1)
		DarknessFlame = 6 + p.Potential/25
		DamageMult = 1 + round(p.Potential/50)
		Rounds = 5 + round(p.Potential/20)

/obj/Skills/AutoHit/Earthquake
	Earthshaking = 5
	Area="Around Target"
	Rounds = 5
	NoLock = 1 
	NoAttackLock=1
	/*TurfStrike=2
	TurfShift='Dirt.dmi'
	TurfShiftDuration=3*/
	DamageMult = 0.1
	SpecialAttack = 1
	AdaptRate=1
	CanBeDodged = 0
	CanBeBlocked = 0
	Cooldown = 5
	Distance = 12
	Size = 2
	HitSparkIcon='BLANK.dmi'
	HitSparkX=0
	HitSparkY=0
	Shattering = 10


/obj/Skills/Projectile/Bubblebeam
	IconLock = 'WaterPrison.dmi'
	Distance=15
	AccMult=2
	DamageMult=0.05
	Speed = 1.33
	Knockback=0
	Blasts=10
	Continuous=1
	Variation=64
	IconSize = 0.25
	Chilling = 10
	Homing = 3
	HomingDelay = 1

/obj/Skills/Projectile/Fire_Blast
	IconLock = 'FireBlast.dmi'
	Blasts = 1
	DamageMult = 1
	Distance = 25
	Speed = 0.33
	IconSize = 2
	Burning = 50
	Homing = 3
	HomingDelay = 2



/obj/Skills/AutoHit/Blood_Whips
	Area="Circle"
	ComboMaster=1
	AdaptRate=1
	DamageMult=0.05
	Rounds=30
	Cooldown=30
	NoLock = 1
	NoAttackLock = 1
	Size=3
	PullIn = 5
	NeedsSword = 0
	UnarmedOnly = 0
	Icon='bloodmiasma.dmi'
	HitSparkIcon = 'Hit Effect Vampire.dmi'
	HitSparkX = -32
	HitSparkY = -32
	Instinct=2
	LifeSteal = 100
	ActiveMessage="summons a miasma of blood around themselves."


/obj/Skills/AutoHit/Hyper_Inferno
	Area="Wave"
	AdaptRate=1
	DamageMult=0.15
	ComboMaster=1
	NoLock = 1 
	Instinct=2
	NoAttackLock=1
	Knockback=3
	Cooldown=45
	HitSparkIcon='Hit Effect.dmi'
	HitSparkX=-32
	HitSparkY=-32
	WindUp=0.1
	Hurricane="/obj/Skills/Projectile/Inferno"
	HurricaneDelay=0.1
	WindupMessage="spins rapidly, invoking a tornado that whisks their target!"
	ActiveMessage="bursts forward to deliver a storm of rapid strikes!!"
/obj/Skills/Projectile/Inferno
	FlickBlast=0
	AttackReplace=1
	Distance=21
	DamageMult=0.2
	Dodgeable=0
	Deflectable=0
	Instinct=2
	Radius=2
	ZoneAttack=1
	ZoneAttackX=0
	ZoneAttackY=0
	FireFromSelf=1
	FireFromEnemy=0
	MultiHit=20
	Scorching = 1
	Knockback=2
	Piercing=1
	IconLock='FireTornadoHead.dmi'
	IconSize=0.25
	LockX=-32
	LockY=-32
	Variation=0
	Trail='FireTornadoTrail.dmi'
	TrailDuration=8
	TrailSize=1
	TrailX=-32
	TrailY=-32

/obj/Skills/AutoHit/HellfireInferno
	Area="Wave"
	AdaptRate=1
	DamageMult=0.75
	NoLock = 1 
	ComboMaster=1
	NoAttackLock=1
	NoLock=1
	Instinct=2
	Knockback=15
	Cooldown=15
	HitSparkIcon='Hit Effect.dmi'
	HitSparkX=-32
	HitSparkY=-32
	HitSparkTurns=1
	HitSparkSize=0.8
	HitSparkCount=20
	HitSparkDispersion=24
	HitSparkDelay=1
	WindUp=0.1
	Hurricane="/obj/Skills/Projectile/HelfireInferno"
	HurricaneDelay=0.1
	WindupMessage="spins rapidly, invoking a tornado that whisks their target!"
	ActiveMessage="bursts forward to deliver a storm of rapid strikes!!"
/obj/Skills/Projectile/HelfireInferno
	FlickBlast=0
	AttackReplace=1
	Distance=7
	DamageMult=0.8 
	Dodgeable=0
	Deflectable=0
	Instinct=2
	Radius=4
	FireFromSelf=1
	FireFromEnemy=0
	Knockback=0
	Piercing=1
	IconLock='FireTornadoHead.dmi'
	IconSize=1
	LockX=-8
	LockY=-8
	Variation=0
	Trail='FireTornadoTrail.dmi'
	TrailDuration=20
	TrailSize=1
	TrailX=-8
	TrailY=-8