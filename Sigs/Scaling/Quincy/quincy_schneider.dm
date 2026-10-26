obj/Skills/Projectile/var/ManaDrainPerPass = 0
obj/Skills/Projectile/var/CutsProjectiles = 0

/obj/Skills/Projectile/Quincy/Seele_Schneider
	name = "Seele Schneider"
	MaxCharges = 3
	Charges = 3
	ChargeRefresh = 20
	ManaCost = 2
	DamageMult = 1.2
	Distance = 10
	Speed = 0.3
	Piercing = 1
	Deflectable = -1
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	Variation = 0
	ManaDrainPerPass = 5
	CutsProjectiles = 1

	verb/Seele_Schneider()
		set name = "Seele Schneider"
		set category = "Skills"
		if(!usr.QuincyWeaponDrawn())
			usr << "Draw your Spirit Weapon first."
			return
		usr.UseProjectile(src)
