#define QUINCY_GINTO_MAX 5
#define QUINCY_GINTO_MAX_GEMISCHT 7
#define QUINCY_GINTO_REFILL 300

mob/var/tmp/obj/Effects/Quincy_Gritz_Film/QuincyGritzFilm

/mob/proc/QuincyWeaponDrawn()
	return istype(src.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Spirit_Weapon)

/mob/proc/QuincyGintoMax()
	if(src.QuincyHeritage == "Gemischt")
		return QUINCY_GINTO_MAX_GEMISCHT
	return QUINCY_GINTO_MAX

/mob/proc/QuincyGintoRefill()
	var/cap = QuincyGintoMax()
	if(world.time < src.GintoRefillStamp)
		src.GintoRefillStamp = world.time
	if(src.GintoTubes >= cap)
		src.GintoTubes = cap
		src.GintoRefillStamp = world.time
		return
	var/add = round((world.time - src.GintoRefillStamp) / QUINCY_GINTO_REFILL)
	if(add > 0)
		src.GintoTubes = min(cap, src.GintoTubes + add)
		src.GintoRefillStamp = world.time

/mob/Players/CinderTollReset()
	..()
	if(QuincyIsQuincy() && src.QuincyLevel >= 2)
		src.GintoTubes = QuincyGintoMax()
		src.GintoRefillStamp = world.time

/mob/Players/Login()
	..()
	spawn(25)
		if(src && QuincyIsQuincy())
			QuincyGintoRefill()

/mob/Players/QuincySyncSkills()
	..()
	QuincyGintoSyncInner()

/mob/proc/QuincyGintoSyncInner()
	for(var/T in typesof(/obj/Skills/Ginto) - /obj/Skills/Ginto)
		var/obj/Skills/Ginto/G = T
		var/ip = initial(G.inner_path)
		if(!ispath(ip, /obj/Skills))
			continue
		var/obj/Skills/outer = QuincyOwnedSkill(T)
		var/obj/Skills/inner = QuincyOwnedSkill(ip)
		if(outer && !inner)
			src.AddSkill(new ip)
		else if(!outer && inner)
			src.DeleteSkill(inner)

/obj/Skills/Ginto
	var/tubes_needed = 1
	var/incantation
	var/inner_path

	proc/GintoPrep(mob/User)
		return 1

	proc/GintoFire(mob/User)
		var/obj/Skills/inner = User.QuincyOwnedSkill(src.inner_path)
		if(!inner)
			User.QuincyGintoSyncInner()
			inner = User.QuincyOwnedSkill(src.inner_path)
		if(!inner)
			return 0
		var/stamp = inner.cooldown_start_wt
		if(istype(inner, /obj/Skills/AutoHit))
			User.Activate(inner, noGCD = TRUE)
		else if(istype(inner, /obj/Skills/Projectile))
			User.UseProjectile(inner, noGCD = TRUE)
		return inner && inner.Using && inner.cooldown_start_wt != stamp

	proc/GintoCast(mob/User)
		if(!ismob(User))
			return
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		if(User.GCDBlocked(src))
			return
		if(!User.QuincyWeaponDrawn())
			User << "Draw your Spirit Weapon first."
			return
		User.QuincyGintoRefill()
		if(User.GintoTubes < src.tubes_needed)
			User << "You have [User.GintoTubes] silver tubes; [src.name] needs [src.tubes_needed]."
			return
		User.GintoTubes -= src.tubes_needed
		OMsg(User, "[User] calls: <i>[src.incantation]</i>")
		GintoPrep(User)
		if(!GintoFire(User))
			User.GintoTubes = min(User.QuincyGintoMax(), User.GintoTubes + src.tubes_needed)
			return
		src.Cooldown(1, null, User)

/obj/Skills/Ginto/Heizen
	name = "Heizen"
	tubes_needed = 4
	Cooldown = 20
	incantation = "Renze Forumeru Venti Gral!"
	inner_path = /obj/Skills/AutoHit/Ginto/Heizen_Prism

	verb/Heizen()
		set name = "Heizen"
		set category = "Skills"
		GintoCast(usr)

/obj/Skills/Ginto/Wolke
	name = "Wolke"
	tubes_needed = 1
	Cooldown = 15
	incantation = "Ihn schenke Zweig!"
	inner_path = /obj/Skills/AutoHit/Ginto/Wolke_Burst

	GintoPrep(mob/User)
		var/mob/g = User.grabbed
		if(!ismob(g))
			g = User.IsGrabbed()
		if(ismob(g) && g.Grab == User)
			g.Grab_Release()
		if(User.Launched)
			LaunchEnd(User)
		if(User.Knockbacked)
			User.StopKB()
		return 1

	verb/Wolke()
		set name = "Wolke"
		set category = "Skills"
		GintoCast(usr)

/obj/Skills/Ginto/Gritz
	name = "Gritz"
	tubes_needed = 1
	Cooldown = 25
	incantation = "Zielt Krieg von Kitz Hart Vierte!"
	inner_path = /obj/Skills/Projectile/Ginto/Gritz_Film

	verb/Gritz()
		set name = "Gritz"
		set category = "Skills"
		GintoCast(usr)

/obj/Skills/AutoHit/Ginto
	SignatureTechnique = 1

/obj/Skills/AutoHit/Ginto/Heizen_Prism
	name = "Heizen"
	Area = "Strike"
	Distance = 4
	DamageMult = 2.5
	GuardBreak = 1
	Shearing = 1
	ForScaling = 1
	EndEffectiveness = 0.75
	Cooldown = 20
	Icon = 'Icons/Effects/SparkleArcane.dmi'
	ActiveMessage = "a transparent prism gouges everything it encloses!"

	adjust(mob/p)
		DamageMult = initial(DamageMult)
		var/mob/t = p.Target
		if(ismob(t) && t.HollowIsHollow())
			DamageMult *= 2

/obj/Skills/AutoHit/Ginto/Wolke_Burst
	name = "Wolke"
	Area = "Circle"
	Distance = 1
	DamageMult = 0.3
	Knockback = 2
	NoLock = 1
	NoAttackLock = 1
	Cooldown = 15
	ActiveMessage = "a green blast cushions the impact!"

/obj/Skills/Projectile/Ginto
	SignatureTechnique = 1

/obj/Skills/Projectile/Ginto/Gritz_Film
	name = "Gritz"
	Distance = 8
	Speed = 0.3
	DamageMult = 0.2
	Snaring = 3
	Stunner = 2
	Homing = 1
	IconLock = 'Icons/Effects/SparkleArcane.dmi'
	Variation = 0
	Cooldown = 25

/obj/Effects/Quincy_Gritz_Film
	Lifetime = -1
	icon = 'Icons/Effects/SparkleArcane.dmi'
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0

	New(loc)
		..()
		appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/mob/proc/QuincyGritzFilmOn()
	set waitfor = 0
	if(src.QuincyGritzFilm)
		var/obj/Effects/Quincy_Gritz_Film/old = src.QuincyGritzFilm
		src.vis_contents -= old
		src.QuincyGritzFilm = null
		del old
	var/obj/Effects/Quincy_Gritz_Film/f = new(null)
	src.vis_contents += f
	src.QuincyGritzFilm = f
	sleep(30)
	if(src && src.QuincyGritzFilm == f)
		src.vis_contents -= f
		src.QuincyGritzFilm = null
	if(f)
		del f
