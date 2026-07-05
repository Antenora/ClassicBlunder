/obj/Skills/Projectile/Racial/Fox_Fire_Barrage
	FoxFire = 2
	Homing = 1
	Distance=30
	DamageMult=2.5
	Burning = 10
	Blasts=3
	AccMult=2
	Homing=1
	HomingCharge=1
	HomingDelay=1
	EnergyCost=8
	Delay=5
	Speed=1.5
	IconChargeOverhead=1
	IconLock = 'Elec Ball Blue.dmi'
	Cooldown = 60
	adjust(mob/p)
		FoxFire = 2 + p.AscensionsAcquired
		Blasts= 3 * max(1, p.AscensionsAcquired);
		DamageMult= 2.5 + (p.AscensionsAcquired * 0.25)

	verb/Fox_Fire_Barrage()
		set category = "Skills"
		adjust(usr)
		usr.UseProjectile(src)