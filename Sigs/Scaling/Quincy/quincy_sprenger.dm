#define QUINCY_SPRENGER_WINDOW 300
#define QUINCY_SPRENGER_RANGE 6
#define QUINCY_SPRENGER_STAKES 5
#define QUINCY_SPRENGER_SNARE 4
#define QUINCY_SPRENGER_RADIUS 3
#define QUINCY_SPRENGER_MULT 6
#define QUINCY_SPRENGER_MULT_TOP 8

mob/var/tmp/SprengerPlacing = 0
mob/var/tmp/list/SprengerStakes
mob/var/tmp/SprengerSerial = 0

/proc/QuincyAreaFoe(mob/m, mob/owner)
	if(!ismob(m) || !ismob(owner) || m == owner)
		return 0
	if(!m.passive_handler)
		return 0
	if(owner.ai_followers && (m in owner.ai_followers))
		return 0
	if(istype(m, /mob/Player/AI))
		var/mob/Player/AI/c = m
		if(c.ai_owner == owner)
			return 0
	if(m.ckey && owner.inParty(m.ckey))
		return 0
	if(istype(owner, /mob/Player/AI))
		var/mob/Player/AI/a = owner
		if(!a.ai_team_fire && a.AllianceCheck(m))
			return 0
	return 1

/proc/QuincyAreaHit(mob/owner, mob/m, mult)
	var/dp = m.Power
	if(dp <= 0)
		dp = 1
	var/powerDif = owner.Power / dp
	if(glob.CLAMP_POWER && !owner.ignoresPowerClamp(m))
		powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)
	var/endScale = 1
	if(owner.isSuperCharged(owner))
		endScale -= clamp(glob.SUPERCHARGERATE * owner.passive_handler["SuperCharge"], 0, 1)
	if(owner.passive_handler["Atomizer"])
		endScale = clamp(endScale - (endScale * (owner.passive_handler["Atomizer"] * glob.ATOMIZERRATE)), 0.0001, 2)
	var/dmg = strikeCoreDamage(powerDif, owner.GetFor(1), m.getEndStat(1) * endScale)
	dmg *= mult
	dmg = ProjectileDamage(dmg)
	dmg *= m.ccProrationMult(owner, 0, 0)
	dmg *= m.getRangedResistValue()
	if(dmg <= 0)
		return 0
	var/was = owner.ProjectileAttacking
	owner.ProjectileAttacking = TRUE
	var/strike/S = new(owner, m, dmg)
	S.spirit = 1
	. = S.resolve()
	if(owner)
		owner.ProjectileAttacking = was
	if(m)
		m.ccCountHit()

/proc/QuincyAreaDamage(turf/center, radius, mult, mob/owner)
	if(!isturf(center) || !ismob(owner) || mult <= 0)
		return 0
	radius = max(0, round(radius))
	var/list/victims = list()
	for(var/mob/m in view(radius, center))
		if(QuincyAreaFoe(m, owner))
			victims += m
	var/hits = 0
	for(var/mob/m in victims)
		if(!owner)
			break
		if(!m || m.z != center.z)
			continue
		QuincyAreaHit(owner, m, mult)
		hits++
	return hits

/obj/Effects/Schneider_Stake
	name = "Seele Schneider"
	icon = 'Icons/Blasts/LightStrike.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	pixel_x = -19
	pixel_y = -19

	New(loc)
		..()
		spawn(QUINCY_SPRENGER_WINDOW + 10)
			if(src)
				del src

/mob/proc/QuincySprengerLive()
	if(!src.SprengerStakes)
		return 0
	var/list/keep = list()
	for(var/obj/Effects/Schneider_Stake/k in src.SprengerStakes)
		keep += k
	src.SprengerStakes = keep
	return keep.len

/mob/proc/QuincySprengerPlacingNow()
	if(!src.SprengerStakes || src.SprengerPlacing <= world.time)
		return 0
	return QuincySprengerLive() < QUINCY_SPRENGER_STAKES

/mob/proc/QuincySprengerArmed()
	if(!src.SprengerStakes || src.SprengerPlacing <= world.time)
		return 0
	return QuincySprengerLive() >= QUINCY_SPRENGER_STAKES

/mob/proc/QuincySprengerClear()
	src.SprengerSerial++
	src.SprengerPlacing = 0
	var/list/L = src.SprengerStakes
	src.SprengerStakes = null
	if(L)
		for(var/obj/Effects/Schneider_Stake/k in L)
			del k

/mob/proc/QuincySprengerWatch()
	set waitfor = 0
	var/serial = ++src.SprengerSerial
	while(src && src.SprengerSerial == serial)
		sleep(10)
		if(!src || src.SprengerSerial != serial || !src.SprengerStakes)
			return
		if(src.SprengerPlacing <= world.time)
			src << "<font color=yellow>Your Seele Schneider fade.</font>"
			QuincySprengerClear()
			return
		if(src.icon_state == "Meditate")
			src << "<font color=yellow>You let your Seele Schneider fade.</font>"
			QuincySprengerClear()
			return

/mob/proc/QuincySprengerCenter()
	var/n = QuincySprengerLive()
	if(!n)
		return null
	var/sx = 0
	var/sy = 0
	var/sz = 0
	for(var/obj/Effects/Schneider_Stake/k in src.SprengerStakes)
		sx += k.x
		sy += k.y
		sz = k.z
	return locate(round(sx / n, 1), round(sy / n, 1), sz)

/mob/proc/QuincySprengerSnare()
	var/minx = 0
	var/maxx = 0
	var/miny = 0
	var/maxy = 0
	var/sz = 0
	var/first = 1
	for(var/obj/Effects/Schneider_Stake/k in src.SprengerStakes)
		if(first)
			minx = k.x
			maxx = k.x
			miny = k.y
			maxy = k.y
			sz = k.z
			first = 0
			continue
		minx = min(minx, k.x)
		maxx = max(maxx, k.x)
		miny = min(miny, k.y)
		maxy = max(maxy, k.y)
	if(first)
		return 0
	var/caught = 0
	for(var/turf/t in block(locate(minx, miny, sz), locate(maxx, maxy, sz)))
		for(var/mob/m in t)
			if(QuincyAreaFoe(m, src))
				m.applySnare(QUINCY_SPRENGER_SNARE)
				caught++
	return caught

/mob/proc/QuincySprengerPlace(turf/t)
	for(var/obj/Effects/Schneider_Stake/k in src.SprengerStakes)
		if(k.loc == t)
			src << "A Seele Schneider already stands there."
			return
	var/obj/Effects/Schneider_Stake/s = new(t)
	src.SprengerStakes += s
	var/n = QuincySprengerLive()
	if(n < QUINCY_SPRENGER_STAKES)
		src << "<font color=#9fd8ff>Seele Schneider [n] of [QUINCY_SPRENGER_STAKES] set.</font>"
		return
	QuincySprengerSnare()
	OMsg(src, "The pentagon is set.")

/obj/Skills/Ginto/Sprenger
	name = "Sprenger"
	tubes_needed = 1
	Cooldown = 90
	incantation = "Sprenger!"
	var/ExplodeSize = 2

	verb/Sprenger()
		set name = "Sprenger"
		set category = "Skills"
		SprengerUse(usr)

	proc/SprengerUse(mob/User)
		if(!ismob(User))
			return
		if(User.QuincySprengerArmed())
			SprengerDetonate(User)
			return
		if(User.QuincySprengerPlacingNow())
			User << "Set [QUINCY_SPRENGER_STAKES - User.QuincySprengerLive()] more Seele Schneider ([round((User.SprengerPlacing - world.time) / 10)] s left)."
			return
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		if(!User.QuincyWeaponDrawn())
			User << "Draw your Spirit Weapon first."
			return
		User.QuincySprengerClear()
		User.SprengerPlacing = world.time + QUINCY_SPRENGER_WINDOW
		User.SprengerStakes = list()
		User << "<font color=#9fd8ff>Click [QUINCY_SPRENGER_STAKES] tiles within [QUINCY_SPRENGER_RANGE] tiles to set your Seele Schneider. You have [QUINCY_SPRENGER_WINDOW / 10] seconds.</font>"
		User.QuincySprengerWatch()

	proc/SprengerDetonate(mob/User)
		if(User.GCDBlocked(src))
			return
		if(!User.QuincyWeaponDrawn())
			User << "Draw your Spirit Weapon first."
			return
		User.QuincyGintoRefill()
		if(User.GintoTubes < src.tubes_needed)
			User << "You have [User.GintoTubes] silver tubes; [src.name] needs [src.tubes_needed]."
			return
		var/turf/center = User.QuincySprengerCenter()
		if(!center)
			User.QuincySprengerClear()
			return
		User.GintoTubes -= src.tubes_needed
		OMsg(User, "[User] calls: <i>[src.incantation]</i>")
		var/tint = (glob && glob.ADAPTIVE_EXPLOSIONS) ? FxIconPaint('Icons/Blasts/LightStrike.dmi', null) : null
		Bang(center, Size = src.ExplodeSize, Offset = 0, color_override = tint)
		var/mult = User.QuincyLevel >= 7 ? QUINCY_SPRENGER_MULT_TOP : QUINCY_SPRENGER_MULT
		QuincyAreaDamage(center, QUINCY_SPRENGER_RADIUS, mult, User)
		if(User)
			User.QuincySprengerClear()
		src.Cooldown(1, null, User)

turf/Click(turf/T)
	if(!usr || !usr.client || !usr.QuincySprengerPlacingNow())
		return ..()
	if(src.density || usr.z != src.z || get_dist(usr, src) > QUINCY_SPRENGER_RANGE)
		return ..()
	usr.QuincySprengerPlace(src)
