obj/Skills/Projectile
	RoaringCrescentWave
		Distance=40
		Cooldown=8
		ManaCost=2
		DamageMult=1.4
		Shearing=1
		AccMult=100
		Piercing=1
		Dodgeable=-1
		ProjectileAfterimages=1
		Deflectable=-1
		IconLock='CrescentSlash.dmi'
		ActiveMessage="fires off a crescent wave!"
		IconSize=1
		MaxCharges=3
		Charges=3
		ChargeRefresh=6
		adjust(mob/p)
		verb/Roaring_Crescent_Wave()
			set category="Skills"
			set name="Roaring Crescent Wave"
			usr.UseProjectile(src)