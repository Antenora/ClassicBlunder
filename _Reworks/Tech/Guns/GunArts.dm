/obj/Skills/Projectile/var/tmp/gun_ricochet = 0
/obj/Skills/Projectile/var/tmp/gun_shatter = 0
/obj/Skills/Projectile/var/tmp/gun_knockback = 0
/obj/Skills/Projectile/var/tmp/gun_suppress = 0

/mob/var/tmp/list/gun_children

/obj/Skills/Projectile/GunArt
	name = "Gun Art"
	NeedsGun = 1
	NoChargeRegen = 1
	UsesOff = 1
	StrScaling = 0
	ForScaling = 0
	EndEffectiveness = 1
	Instant = 1
	Striking = 1
	Variation = 6
	Radius = 0
	Blasts = 1
	Distance = 7
	Speed = 0.3
	IconLock = 'BlastTracer.dmi'
	IconSize = 0.5
	var/art_rounds = 1

	proc/ArtRounds(obj/Items/Gun/G)
		return art_rounds

	proc/ArtCheck(mob/user, obj/Items/Gun/G)
		return 1

	proc/ArtStamp(mob/user, obj/Items/Gun/G, n)
		return

/obj/Skills/Projectile/GunArt/Quickdraw
	name = "Quickdraw"
	Cooldown = GUN_QUICKDRAW_CD
	AttackReplace = 1
	art_rounds = GUN_QUICKDRAW_ROUNDS
	ActiveMessage = "draws and fires in a single motion!"

	ArtCheck(mob/user, obj/Items/Gun/G)
		return user.CanAttack(-1)

	ArtStamp(mob/user, obj/Items/Gun/G, n)
		AccMult *= GUN_QUICKDRAW_ACC

	verb/Quickdraw()
		set name = "Quickdraw"
		set category = "Skills"
		usr.GunArtFire(src)

/obj/Skills/Projectile/GunArt/Fan_the_Hammer
	name = "Fan the Hammer"
	Cooldown = GUN_FAN_CD
	Instant = 0
	Delay = GUN_FAN_DELAY
	ActiveMessage = "fans the hammer!"

	ArtRounds(obj/Items/Gun/G)
		return G ? G.Loaded : 0

	ArtStamp(mob/user, obj/Items/Gun/G, n)
		Blasts = max(1, Blasts) * n
		AccMult *= GUN_FAN_ACC
		user.NextAttack = max(user.NextAttack, world.time + Blasts * Delay * SlowMoDelayMult(user))

	verb/Fan_the_Hammer()
		set name = "Fan the Hammer"
		set category = "Skills"
		usr.GunArtFire(src)

/obj/Skills/Projectile/GunArt/Ricochet
	name = "Ricochet"
	Cooldown = GUN_RICOCHET_CD
	art_rounds = GUN_RICOCHET_ROUNDS
	gun_ricochet = GUN_RICOCHET_RANGE
	ActiveMessage = "banks a shot off the mark!"

	verb/Ricochet()
		set name = "Ricochet"
		set category = "Skills"
		usr.GunArtFire(src)

/obj/Skills/Projectile/GunArt/Ricochet_Round
	name = "Ricochet Round"
	NoGCD = 1
	Cooldown = 0

/obj/Skills/Projectile/GunArt/Burst
	name = "Burst"
	Cooldown = GUN_BURST_CD
	art_rounds = GUN_BURST_ROUNDS
	ActiveMessage = "squeezes off a tight burst!"

	ArtStamp(mob/user, obj/Items/Gun/G, n)
		Blasts = max(1, Blasts) * n
		SpreadArc = GUN_BURST_SPREAD

	verb/Burst()
		set name = "Burst"
		set category = "Skills"
		usr.GunArtFire(src)

/obj/Skills/Projectile/GunArt/Suppressing_Fire
	name = "Suppressing Fire"
	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = GUN_SUPPRESS_RATE
	Cooldown = GUN_SUPPRESS_CD
	art_rounds = GUN_SUPPRESS_ROUNDS

	OnHeldTick(mob/p)
		p.GunSuppressTick(src)

	OnHeldRelease(mob/p, benefit, sweet_spot_hit = FALSE, charge_level = 0)
		Cooldown(1, null, p)

	verb/Suppressing_Fire()
		set name = "Suppressing Fire"
		set category = "Skills"
		usr.GunSuppressStart(src)

/obj/Skills/Projectile/GunArt/Suppressing_Round
	name = "Suppressing Round"
	NoGCD = 1
	Cooldown = 0
	gun_suppress = GUN_SUPPRESS_TIME

/obj/Skills/Projectile/GunArt/Slug
	name = "Slug"
	Cooldown = GUN_SLUG_CD
	art_rounds = GUN_SLUG_ROUNDS
	ActiveMessage = "chambers a slug and fires!"

	ArtStamp(mob/user, obj/Items/Gun/G, n)
		GunSlugStamp(src, G)

	verb/Slug()
		set name = "Slug"
		set category = "Skills"
		usr.GunArtFire(src)

/obj/Skills/Projectile/GunArt/Point_Blank
	name = "Point Blank"
	Cooldown = GUN_POINTBLANK_CD
	art_rounds = GUN_POINTBLANK_ROUNDS
	gun_shatter = GUN_POINTBLANK_SHATTER
	gun_knockback = GUN_POINTBLANK_KB
	ActiveMessage = "jams the barrel in close and fires!"

	ArtCheck(mob/user, obj/Items/Gun/G)
		var/mob/T = user.Target
		if(!ismob(T) || T == user || T.z != user.z || get_dist(user, T) > GUN_POINTBLANK_REACH)
			user << "Point Blank needs your target within [GUN_POINTBLANK_REACH] tile."
			return 0
		return 1

	ArtStamp(mob/user, obj/Items/Gun/G, n)
		Knockback = 0

	verb/Point_Blank()
		set name = "Point Blank"
		set category = "Skills"
		usr.GunArtFire(src)

/obj/Skills/Projectile/GunArt/Underbarrel
	name = "Underbarrel Launcher"
	Cooldown = GUN_UNDERBARREL_CD
	art_rounds = 0

	verb/Underbarrel_Launcher()
		set name = "Underbarrel Launcher"
		set category = "Skills"
		usr.GunUnderbarrelFire(src)

/obj/Skills/AutoHit/GunArt
	name = "Gun Art"
	NeedsGun = 1
	NoChargeRegen = 1

/obj/Skills/AutoHit/GunArt/Bayonet_Stab
	name = "Bayonet Stab"
	Area = "Strike"
	Distance = 1
	StrScaling = 1
	DamageMult = 1
	Bloodletting = GUN_BAYONET_BLEED
	Cooldown = 0
	NoGCD = 1
	HitSparkIcon = 'Slash.dmi'
	HitSparkX = -32
	HitSparkY = -32
	HitSparkSize = 1
	HitSparkTurns = 1

mob/proc/GunChild(path)
	if(!gun_children)
		gun_children = list()
	var/obj/Skills/Projectile/S = gun_children[path]
	if(!S)
		S = new path
		gun_children[path] = S
	return S

mob/proc/GunArtAim(obj/Skills/Projectile/S)
	var/ang = GunAimAngleNow()
	S.FlightAngle = ang
	S.DirOverride = GunAngleDir(ang)
	S.LaunchOffX = 0
	S.LaunchOffY = 0

mob/proc/GunArtAimReset(obj/Skills/Projectile/S)
	S.FlightAngle = null
	S.DirOverride = 0
	S.LaunchOffX = 0
	S.LaunchOffY = 0

mob/proc/GunArtSpend(n)
	var/obj/Items/Gun/G = EquippedGun()
	if(!G || n <= 0 || G.Loaded < n)
		return 0
	G.Loaded -= n
	GunRefillSkill(G)
	return 1

mob/proc/GunArtRefund(n)
	var/obj/Items/Gun/G = EquippedGun()
	if(!G || n <= 0)
		return
	G.Loaded = min(G.Loaded + n, G.MagSize)
	GunRefillSkill(G)

mob/proc/GunArtFire(obj/Skills/Projectile/GunArt/A)
	if(!A)
		return 0
	var/obj/Items/Gun/G = EquippedGun()
	if(!G)
		src << "You need a gun to use [A]!"
		return 0
	if(!(A in Skills))
		src << "Your [G.name] does not carry [A]."
		return 0
	if(A.Using || A.cooldown_remaining)
		return 0
	if(Reloading)
		src << "You can't use [A] while reloading."
		return 0
	if(!A.ArtCheck(src, G))
		return 0
	var/n = A.ArtRounds(G)
	if(n <= 0 || G.Loaded < n)
		src << "Your [G.name] needs [max(n, 1)] loaded round\s for [A]."
		return 0
	GunStampShot(A, G, 0)
	A.ArtStamp(src, G, n)
	GunArtAim(A)
	if(GunIsSuppressed())
		A.ActiveMessage = null
	GunArtSpend(n)
	UseProjectile(A)
	A.ActiveMessage = initial(A.ActiveMessage)
	GunArtAimReset(A)
	. = (A.Using || A.cooldown_remaining) ? 1 : 0
	if(!.)
		GunArtRefund(n)

mob/proc/GunSuppressStart(obj/Skills/Projectile/GunArt/Suppressing_Fire/A)
	if(!A)
		return
	var/obj/Items/Gun/G = EquippedGun()
	if(!G)
		src << "You need a gun to use [A]!"
		return
	if(!(A in Skills))
		src << "Your [G.name] does not carry [A]."
		return
	if(G.Loaded < GUN_SUPPRESS_ROUNDS)
		src << "Your [G.name] needs [GUN_SUPPRESS_ROUNDS] loaded rounds for [A]."
		return
	BeginHeldSkill(A)

mob/proc/GunSuppressTick(obj/Skills/Projectile/GunArt/Suppressing_Fire/A)
	var/obj/Items/Gun/G = EquippedGun()
	if(!G || Reloading || G.Loaded < GUN_SUPPRESS_ROUNDS || !(A in Skills))
		if(held_skill == A)
			ReleaseHeldSkill()
		return
	var/obj/Skills/Projectile/R = GunChild(/obj/Skills/Projectile/GunArt/Suppressing_Round)
	GunStampShot(R, G, 0)
	R.DamageMult *= GUN_SUPPRESS_DAMAGE
	R.SpreadArc = GUN_SUPPRESS_CONE / 2
	R.TurfMud = GUN_SUPPRESS_SLOW
	var/shots = max(1, R.Blasts) * GUN_SUPPRESS_ROUNDS
	if(!GunArtSpend(GUN_SUPPRESS_ROUNDS))
		return
	GunArtAim(R)
	GunFaceAim()
	flick("Attack", src)
	for(var/i = 1 to shots)
		Blast(R, src, 0)
	GunArtAimReset(R)

mob/proc/GunArtOnHit(mob/victim, obj/Skills/Projectile/_Projectile/P, obj/Skills/Projectile/S)
	if(!victim || !S)
		return
	if(S.gun_shatter > 0)
		victim.AddShatter(S.gun_shatter, src)
	if(S.gun_knockback > 0 && !victim.Knockbacked)
		Knockback(S.gun_knockback, victim, get_dir(src, victim) || P.dir, Ki = 1)
	if(S.gun_suppress > 0)
		victim.gun_suppressed = world.time + S.gun_suppress
	if(S.gun_ricochet > 0)
		GunRicochet(victim, P, S.gun_ricochet)

mob/proc/GunRicochet(mob/victim, obj/Skills/Projectile/_Projectile/P, reach)
	var/obj/Items/Gun/G = EquippedGun()
	if(!G || !victim || !P || !isturf(victim.loc))
		return
	var/mob/next
	var/best = reach + 1
	for(var/mob/M in range(reach, victim))
		if(M == victim || M == src || M.KO || M.Dead || M.Stasis || M.PureRPMode || !M.density)
			continue
		if(P.SweepAllySkip(M))
			continue
		var/d = get_dist(victim, M)
		if(d < best)
			best = d
			next = M
	if(!next)
		return
	var/obj/Skills/Projectile/R = GunChild(/obj/Skills/Projectile/GunArt/Ricochet_Round)
	GunStampShot(R, G, 0)
	R.SpreadArc = 0
	R.FlightAngle = null
	R.DirOverride = get_dir(victim, next) || P.dir
	R.Distance = reach + 1
	R.SpawnPosition = victim.loc
	var/obj/Skills/Projectile/_Projectile/Q = Blast(R, victim.loc, 0)
	R.SpawnPosition = null
	GunArtAimReset(R)
	if(!Q)
		return
	Q.step_x = victim.step_x
	Q.step_y = victim.step_y
	Q.Homing = next
	if(Q.LastHitAt)
		Q.LastHitAt[victim] = world.time + 50

mob/proc/GunUnderbarrelFire(obj/Skills/Projectile/GunArt/Underbarrel/A)
	if(!A)
		return 0
	var/obj/Items/Gun/G = EquippedGun()
	if(!G || !G.HasMod(/obj/Items/GunMod/Underbarrel_Launcher))
		src << "You need a gun with an Underbarrel Launcher to use that!"
		return 0
	if(!(A in Skills) || A.Using || A.cooldown_remaining)
		return 0
	if(Reloading || !CanAttack(-1))
		return 0
	var/fragpath = text2path("/obj/Items/Ordnance/Frag_Grenade")
	var/obj/Items/F
	if(fragpath)
		for(var/obj/Items/I in src)
			if(istype(I, fragpath) && I.TotalStack > 0)
				F = I
				break
	if(!F)
		src << "You have no Frag Grenade to load into the launcher."
		return 0
	var/throwpath = ("throw_skill" in F.vars) ? F.vars["throw_skill"] : null
	if(!throwpath || !hascall(src, "OrdnanceThrow"))
		src << "The launcher cannot fire that grenade."
		return 0
	if(!call(src, "OrdnanceThrow")(throwpath))
		return 0
	if(F.TotalStack > 1)
		F.TotalStack--
		F.suffix = "[F.TotalStack]"
	else
		del F
	A.Cooldown(1, null, src)
	if(!GunIsSuppressed())
		OMsg(src, "<b>[src] fires a grenade from their underbarrel launcher!</b>")
	if(client)
		client.BuildInvPage()
	return 1
