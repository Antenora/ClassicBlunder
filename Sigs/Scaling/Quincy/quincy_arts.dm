/obj/Skills/Projectile/Quincy/Licht_Regen
	name = "Licht Regen"
	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 2.5
	SweetSpotWindow = 0.4
	NoFizzle = 1
	Cooldown = 25
	ManaCost = 6
	DamageMult = 0.35
	Blasts = 6
	Delay = 1
	Homing = 1
	Distance = 12
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	Variation = 0
	ChargeMessage = "gathers Reishi along their left arm..."
	ActiveMessage = "unleashes Licht Regen!"

	adjust(mob/p)
		Homing = (p.QuincyHeritage == "Gemischt" && p.QuincyLevel >= 6) ? 2 : 1

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		adjust(p)
		Blasts = 6 + round(6 * benefit)
		p.UseProjectile(src)
		ResetHeldConfig()
		Blasts = initial(Blasts)

	verb/Licht_Regen()
		set name = "Licht Regen"
		set category = "Skills"
		if(!usr.QuincyWeaponDrawn())
			usr << "Draw your Spirit Weapon first."
			return
		usr.BeginHeldSkill(src)

/obj/Skills/Projectile/Quincy/Klavier
	name = "Klavier"
	Blasts = 8
	Delay = 1
	DamageMult = 0.3
	AccMult = 1.2
	Distance = 12
	Speed = 0.25
	Cooldown = 20
	ManaCost = 5
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	Variation = 0
	ActiveMessage = "plays a Klavier of arrows!"

	verb/Klavier()
		set name = "Klavier"
		set category = "Skills"
		if(!usr.QuincyWeaponDrawn())
			usr << "Draw your Spirit Weapon first."
			return
		usr.UseProjectile(src)

/obj/Skills/Queue/Quincy

/obj/Skills/Queue/Quincy/Schneider_Dance
	name = "Schneider Dance"
	Combo = 3
	Rapid = 1
	DamageMult = 0.9
	Projectile = "/obj/Skills/Projectile/Quincy/Heilig_Pfeil_Blade"
	ProjectileCount = 6
	Cooldown = 25
	ManaCost = 5
	NeedsSword = 1
	HitMessage = "cuts and looses a volley of Reishi!"

	verb/Schneider_Dance()
		set name = "Schneider Dance"
		set category = "Skills"
		if(!usr.QuincyWeaponDrawn())
			usr << "Draw your Spirit Weapon first."
			return
		usr.SetQueue(src)
