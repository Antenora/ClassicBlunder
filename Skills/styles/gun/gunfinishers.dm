/mob/var/tmp/gun_muzzle_pending = 0
/mob/var/tmp/gun_muzzle_mult = 1
/mob/var/tmp/gun_muzzle_shatter = 0

/obj/Skills/Projectile/GunFinisher
	name = "Gun Finisher"
	NeedsGun = 1
	NoGCD = 1
	Cooldown = 0
	AttackReplace = 1
	UsesOff = 1
	StrScaling = 0
	ForScaling = 0
	EndEffectiveness = 1
	Striking = 1
	Instant = 1
	Delay = GUNF_VOLLEY_DELAY
	Variation = 6
	Radius = 0
	Blasts = 1
	Speed = 0.3
	Distance = 7
	IconLock = 'BlastTracer.dmi'
	IconSize = 1
	HitboxW = 12
	HitboxH = 32
	MenuIconFile = GUN_STYLE_ICON
	MenuIcon = "Handgun"

/obj/Skills/Projectile/GunFinisher/Dead_Center
	name = "Dead Center"
	MenuIcon = "PSG"
	DamageMult = 3
	AccMult = 2
	Distance = 9
	ActiveMessage = "lines up a single shot, dead center!"

/obj/Skills/Projectile/GunFinisher/Dead_Center/Empowered
	DamageMult = 4.5
	Deflectable = -1

/obj/Skills/Projectile/GunFinisher/Lead_Curtain
	name = "Lead Curtain"
	MenuIcon = "SMG"
	Blasts = 12
	SpreadArc = 60
	DamageMult = 0.4
	TurfMud = GUNF_CURTAIN_SLOW
	Instant = 0
	ActiveMessage = "hangs a curtain of lead!"

/obj/Skills/Projectile/GunFinisher/Lead_Curtain/Empowered
	DamageMult = 0.6
	Bloodletting = 1

/obj/Skills/Projectile/GunFinisher/Doorbuster
	name = "Doorbuster"
	MenuIcon = "Shotgun"
	Blasts = 8
	SpreadArc = 90
	Distance = 2
	DamageMult = 0.6
	gun_knockback = 2
	gun_shatter = GUN_POINTBLANK_SHATTER
	ActiveMessage = "kicks the door in with a full blast!"

/obj/Skills/Projectile/GunFinisher/Doorbuster/Empowered
	DamageMult = 0.9
	gun_knockback = 3

/obj/Skills/Projectile/GunFinisher/Fusillade
	name = "Fusillade"
	MenuIcon = "TMP"
	Blasts = 3
	SpreadArc = 8
	DamageMult = 1.2
	Instant = 0
	ActiveMessage = "fires a tight fusillade on the run!"

/obj/Skills/Projectile/GunFinisher/Fusillade/Empowered
	DamageMult = 1.8
	Blasts = 5

/obj/Skills/Projectile/GunFinisher/Arcane_Volley
	name = "Arcane Volley"
	MenuIcon = "Photon Pistol"
	Blasts = 6
	DamageMult = 0.7
	UsesOff = 0
	UsesFor = 1
	Instant = 0
	ActiveMessage = "looses a volley of spell-charged rounds!"

/obj/Skills/Projectile/GunFinisher/Arcane_Volley/Empowered
	DamageMult = 1.05
	Blasts = 9

/obj/Skills/Projectile/GunFinisher/Muzzle_Shot
	name = "Muzzle Shot"
	MenuIcon = "Punisher"

/obj/Skills/AutoHit/GunFinisher
	name = "Gun Finisher"
	NeedsGun = 1
	NoGCD = 1
	Cooldown = 0
	MenuIconFile = GUN_STYLE_ICON
	MenuIcon = "Punisher"
	var/contact_mult = 1
	var/contact_shatter = 0

/obj/Skills/AutoHit/GunFinisher/Muzzle_Kick
	name = "Muzzle Kick"
	Area = "Strike"
	Distance = 1
	StrScaling = 1
	UnarmedOnly = 1
	DamageMult = 3
	ActiveMessage = "plants a kick and fires point blank!"

/obj/Skills/AutoHit/GunFinisher/Muzzle_Kick/Empowered
	DamageMult = 4.5
	contact_mult = GUNF_EMPOWER
	contact_shatter = GUN_POINTBLANK_SHATTER

/mob/FinisherFire(obj/Skills/S)
	if(istype(S, /obj/Skills/Projectile/GunFinisher))
		var/obj/Skills/Projectile/P = S
		GunFinisherStamp(P, EquippedGun())
		GunArtAim(P)
		GunFaceAim()
		if(GunIsSuppressed())
			P.ActiveMessage = null
		. = UseProjectile(P, TRUE)
		P.ActiveMessage = initial(P.ActiveMessage)
		GunArtAimReset(P)
		return
	if(istype(S, /obj/Skills/AutoHit/GunFinisher))
		var/obj/Skills/AutoHit/GunFinisher/K = S
		GunFaceAim()
		gun_muzzle_pending = world.time + GUNF_MUZZLE_WINDOW
		gun_muzzle_mult = K.contact_mult
		gun_muzzle_shatter = K.contact_shatter
	return ..()

/mob/proc/GunFinisherStamp(obj/Skills/Projectile/P, obj/Items/Gun/g)
	if(!P || !g)
		return
	P.IconLock = g.BulletIcon
	P.IconSize = g.BulletSize
	P.LockX = g.BulletLockX
	P.LockY = g.BulletLockY
	P.HitboxW = g.BulletHitW
	P.HitboxH = g.BulletHitH
	P.FireOffsetX = g.MuzzleX
	P.FireOffsetY = g.MuzzleY

/mob/proc/GunMuzzleContact(mob/victim, mult = 1, shatter = 0)
	var/obj/Items/Gun/G = EquippedGun()
	if(!G || !victim || victim.KO || !isturf(victim.loc))
		return
	var/obj/Skills/Projectile/R = GunChild(/obj/Skills/Projectile/GunFinisher/Muzzle_Shot)
	GunStampShot(R, G, 0)
	R.DamageMult *= mult
	R.gun_shatter = shatter
	R.SpreadArc = 0
	R.FlightAngle = null
	R.DirOverride = get_dir(src, victim) || dir
	R.SpawnPosition = victim.loc
	for(var/i = 1 to max(1, R.Blasts))
		var/obj/Skills/Projectile/_Projectile/Q = Blast(R, victim.loc, 0)
		if(Q)
			Q.step_x = victim.step_x
			Q.step_y = victim.step_y
			Q.Homing = victim
	R.SpawnPosition = null
	GunArtAimReset(R)

/strikeHook/gunMuzzleContact
	stage = "post"
	fire(strike/S)
		if(!S || !S.autohit || !S.attacker || !S.defender || S.attacker == S.defender)
			return
		var/mob/A = S.attacker
		if(A.gun_muzzle_pending <= world.time)
			return
		A.gun_muzzle_pending = 0
		var/mob/D = S.defender
		var/mult = A.gun_muzzle_mult
		var/shatter = A.gun_muzzle_shatter
		spawn(0)
			if(A && D)
				A.GunMuzzleContact(D, mult, shatter)
