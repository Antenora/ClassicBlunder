/proc/QuincyClickMoveArmed(mob/u)
	var/obj/Skills/Arrancar/Sonido/so = locate(/obj/Skills/Arrancar/Sonido) in u.contents
	if(so && so.SonidoToggle)
		return 1
	if(("LightningJumpArmed" in u.vars) && u.vars["LightningJumpArmed"])
		return 1
	if(u.QuincySprengerPlacingNow())
		return 0
	var/obj/Skills/Hoho/Hirenkyaku/hi = locate(/obj/Skills/Hoho/Hirenkyaku) in u.contents
	if(hi && hi.HirenkyakuToggle)
		return 1
	if(SlamWaveLeapArmed(u))
		return 0
	if(locate(/obj/Skills/Teleport/Instant_Transmission) in u.contents)
		return 1
	var/obj/Skills/Hoho/Shunpo/sh = locate(/obj/Skills/Hoho/Shunpo) in u.contents
	if(sh && sh.ShunpoToggle)
		return 1
	for(var/obj/Skills/Blink/W in u.contents)
		if(W.BuffUsing == 1)
			return 1
	return 0

/proc/QuincyClickMoveCould(mob/u, turf/dest)
	if(!ismob(u) || !u.client || !isturf(dest))
		return 0
	if(u.Admin >= 4 && u.AdminOverwatchActive)
		return 0
	if(u.Target && istype(u.Target, /obj/Others/Build))
		return 0
	if(u.client.macros && u.client.macros.IsPressed("Ctrl"))
		return 0
	if(!u.Move_Requirements() || u.KO)
		return 0
	if(get_turf(u) == dest)
		return 0
	return QuincyClickMoveArmed(u)

turf/Click(turf/T)
	var/mob/u = usr
	if(QuincyGateSealers.len && QuincyClickMoveCould(u, src) && u.GateRefuses(src))
		return
	return ..()

/obj/Skills/Teleport/QuincyTeleportAllowed(mob/User)
	if(ismob(User) && User.GateRefuses(null))
		return 0
	return ..()

/obj/Effects/GargantaRift/Crossed(atom/movable/O)
	if(ismob(O))
		var/mob/M = O
		var/turf/dest = (src.target && isturf(src.target.loc)) ? src.target.loc : null
		if(M.client && M.GateRefuses(dest))
			return
	return ..()

/obj/AutoHitter/QuincyDamage(mob/m)
	if(ismob(m) && QuincyJailSeals(src.Owner, m))
		return
	return ..()

obj/Skills/Projectile/_Projectile/QuincyHitJailWind(atom/a, MultDamage=1)
	if(src.WindBent && (ismob(a) || istype(a, /obj/Skills/Projectile/_Projectile)))
		return
	if(!ismob(a))
		return ..()
	var/mob/m = a
	var/mob/o = src.Owner
	if(ismob(o) && o != m && o.JailedUntil > world.time && m != o.JailedBy)
		return
	var/sure = 0
	var/had = 0
	if(ismob(o) && o.QuincySchrift == "B" && o.BalanceOwed(m))
		sure = 1
		had = o.SureHit
		o.SureHit = 1
	var/before = src.QuincyAbsorbedBy
	. = ..()
	if(sure && o)
		o.SureHit = had
	if(m && src.QuincyAbsorbedBy == m && before != m)
		m.PiskielDrink(o)
