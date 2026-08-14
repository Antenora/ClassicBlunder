// TIER 1

/obj/Skills/Projectile/Ninjutsu/Goukakyu
	name = "Katon: Goukakyu no Jutsu"
	ChakraNature = "Katon"
	SpellElement = "Fire"
	Copyable = 1
	Homing = 0
	DamageMult = 10
	Explode = 2
	Scorching = 10
	Speed = 1.25
	ManaCost = 5
	Cooldown = 15
	LockX = -16
	LockY = -16
	ActiveMessage = "kneads chakra into flame and breathes out a great fireball, Katon: Gōkakyū no Jutsu!"

	New()
		..()
		IconLock = icon('Explosion - Fire.dmi', "2")

	verb/Goukakyu()
		set name = "Katon: Goukakyu no Jutsu"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Ninjutsu/Endan
	name = "Katon: Endan"
	ChakraNature = "Katon"
	SpellElement = "Fire"
	Copyable = 1
	Homing = 0
	DamageMult = 7
	Explode = 1
	Scorching = 5
	Combustion = 30
	Speed = 1
	ManaCost = 8
	Cooldown = 10
	IconLock = 'FireBlast.dmi'
	ActiveMessage = "spits a searing bullet of flame, Katon: Endan!"

	verb/Endan()
		set name = "Katon: Endan"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/AutoHit/Ninjutsu/Ryuka
	name = "Katon: Ryuka no Jutsu"
	ChakraNature = "Katon"
	SpellElement = "Fire"
	Copyable = 1
	Area = "Arc"
	Distance = 3
	DamageMult = 0.5
	ForScaling = 1
	Scorching = 15
	Rounds = 10
	ManaCost = 10
	Cooldown = 15
	HitSparkIcon = 'Explosion - Fire.dmi'
	HitSparkTurns = 1
	HitSparkSize = 1
	HitSparkDispersion = 1
	TurfStrike = 1
	ActiveMessage = "sends fire racing along their line, Katon: Ryūka no Jutsu!"

	verb/Ryuka()
		set name = "Katon: Ryuka no Jutsu"
		set category = "Skills"
		usr.Activate(src)

/obj/Skills/Projectile/Ninjutsu/Housenka
	name = "Katon: Housenka no Jutsu"
	ChakraNature = "Katon"
	SpellElement = "Fire"
	Copyable = 1
	ZoneAttack = 1
	ZoneAttackX = 3
	ZoneAttackY = 3
	Hover = 7
	Homing = 2
	Blasts = 10
	DamageMult = 0.85
	AccMult = 1.25
	Scorching = 5
	Explode = 1
	Instinct = 1
	Variation = 0
	Speed = 1
	Distance = 20
	ManaCost = 10
	Cooldown = 20
	IconLock = 'FireBlast.dmi'
	ActiveMessage = "scatters a volley of fire, Katon: Hōsenka no Jutsu!"

	verb/Housenka()
		set name = "Katon: Housenka no Jutsu"
		set category = "Skills"
		usr.UseProjectile(src)
