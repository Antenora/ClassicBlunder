#define QUINCY_BOMB_MAX 3
#define QUINCY_BOMB_FUSE 40
#define QUINCY_BOMB_RADIUS 2
#define QUINCY_BOMB_FLOOR 0.5
#define QUINCY_BOMB_REACH 24
#define QUINCY_BOMB_NAG 20
#define QUINCY_MARK_MAX 3
#define QUINCY_MARK_LIFE 60
#define QUINCY_MARK_MULT 1
#define QUINCY_MARK_GUARD_DELAY 30
#define QUINCY_ZOFIEL_BOMB_MULT 0.5
#define QUINCY_ZOFIEL_BOMB_HEAD 30

mob/var/tmp/BombStacks = 0
mob/var/tmp/BombStampAt = 0
mob/var/tmp/mob/BombBy
mob/var/tmp/obj/Effects/Quincy_Bomb_Mark/BombMarker
mob/var/tmp/BombSerial = 0
mob/var/tmp/list/QuincyBombs
mob/var/tmp/QuincyBombNagAt = 0

/obj/Skills/Buffs/SlotlessBuffs/Autonomous/Schrift/E_The_Explode/New()
	..()
	kit_skills = list(/obj/Skills/Quincy/Detonate)

/obj/Effects/Quincy_Bomb
	name = "Bomb"
	icon = 'Icons/Blasts/LightStrike.dmi'
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	pixel_x = -19
	pixel_y = -19
	var/stored_mult = 1
	var/mob/bomber
	var/born = 0
	var/fuse = QUINCY_BOMB_FUSE
	var/radius = QUINCY_BOMB_RADIUS
	var/bang_size = 2
	var/blown = 0

	proc/Arm()
		set waitfor = 0
		while(src && !src.blown && src.loc)
			var/left = src.born + src.fuse - world.time
			if(left <= 0)
				Blow()
				return
			sleep(left)

	proc/Blow()
		if(src.blown)
			return
		src.blown = 1
		var/turf/t = get_turf(src)
		var/mob/b = src.bomber
		var/mult = max(QUINCY_BOMB_FLOOR, src.stored_mult)
		var/px = src.step_x
		var/py = src.step_y
		src.bomber = null
		if(b && b.QuincyBombs)
			b.QuincyBombs -= src
		src.loc = null
		if(t && b)
			QuincyBombBang(t, src.bang_size, px, py)
			QuincyAreaDamage(t, src.radius, mult, b)
		del src

/obj/Effects/Quincy_Bomb_Mark
	Lifetime = -1
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0
	appearance_flags = KEEP_APART | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	maptext_width = 64
	maptext_height = 16
	maptext_x = -16
	maptext_y = 36
	var/text_color = "#ffd23a"

/proc/QuincyBombBang(turf/t, size, px, py)
	var/tint = (glob && glob.ADAPTIVE_EXPLOSIONS) ? FxIconPaint('Icons/Blasts/LightStrike.dmi', null) : null
	Bang(t, Size = size, Offset = 0, PX = px, PY = py, color_override = tint)

/proc/QuincyClickPoint(atom/object, list/p)
	var/ix = text2num(p["icon-x"])
	var/iy = text2num(p["icon-y"])
	if(isnull(ix))
		ix = 16
	if(isnull(iy))
		iy = 16
	if(isturf(object))
		return list((object.x - 1) * 32 + ix, (object.y - 1) * 32 + iy)
	if(ismob(object))
		var/mob/m = object
		return list((m.x - 1) * 32 + m.step_x + m.pixel_x + ix, (m.y - 1) * 32 + m.step_y + m.pixel_y + iy)
	return null

/proc/QuincyShotGap(obj/Skills/Projectile/_Projectile/P, wx, wy)
	var/cx = P.LowerX() + P.Width() / 2 + P.vhb_ax
	var/cy = P.LowerY() + P.Height() / 2 + P.vhb_ay
	var/half = max(P.vhb_w, P.vhb_h) / 2
	return max(0, sqrt((wx - cx) ** 2 + (wy - cy) ** 2) - half)

/mob/proc/QuincyViewReach()
	return src.client ? src.client.view : world.view

/mob/proc/QuincyBombShot(obj/Skills/s)
	if(istype(s, /obj/Skills/Projectile/Quincy))
		return 1
	if(istype(s, /obj/Skills/Projectile/Gunfire) && istype(src.EquippedGun(), /obj/Items/Gun/Quincy))
		return 1
	return 0

/mob/proc/QuincyBombsLive()
	var/list/keep = list()
	for(var/obj/Effects/Quincy_Bomb/b in src.QuincyBombs)
		if(!b.blown && b.loc)
			keep += b
	src.QuincyBombs = keep
	return keep

/mob/proc/QuincyBombPlant(turf/t, mult, born, sx = 0, sy = 0)
	if(!isturf(t))
		return null
	var/obj/Effects/Quincy_Bomb/b = new(t)
	b.step_x = sx
	b.step_y = sy
	b.stored_mult = mult
	b.bomber = src
	b.born = born
	if(!src.QuincyBombs)
		src.QuincyBombs = list()
	src.QuincyBombs += b
	b.Arm()
	return b

/mob/proc/QuincyBombCanSeize(obj/Skills/Projectile/_Projectile/P, quiet = 0)
	if(!P || P.Killed || P.Distance <= 0 || !isturf(P.loc))
		return 0
	if(P.clash_lock && !P.clash_lock.ended)
		return 0
	if(src.KO || src.QuincySchrift != "E" || !src.SchriftNeeded("E"))
		return 0
	var/mob/o = P.Owner
	if(!ismob(o) || o == src || !QuincyAreaFoe(o, src))
		return 0
	if(P.z != src.z || !(P in view(QuincyViewReach(), src)))
		return 0
	if(P.Area == "Beam")
		if(!quiet)
			src << "A beam cannot be made a bomb."
		return 0
	if(QuincyBombsLive().len >= QUINCY_BOMB_MAX)
		if(!quiet)
			src << "You cannot hold more than [QUINCY_BOMB_MAX] bombs at once."
		return 0
	return 1

/mob/proc/QuincyBombSeize(obj/Skills/Projectile/_Projectile/P)
	var/obj/Effects/Quincy_Bomb/b = QuincyBombPlant(P.loc, P.DamageMult, world.time, P.step_x, P.step_y)
	if(!b)
		return 0
	P.Killed = 1
	P.ProjectileFinish()
	OMsg(src, "[src] seizes the attack. It is a bomb now.")
	return 1

/mob/proc/QuincyBombClick(atom/object, atom/location, params)
	var/list/p = params2list(params)
	if(p["right"] || p["middle"] || p["ctrl"] || p["alt"] || p["shift"])
		return 0
	if(src.KO || !src.SchriftNeeded("E"))
		return 0
	var/list/w = QuincyClickPoint(object, p)
	if(!w)
		return 0
	var/obj/Skills/Projectile/_Projectile/best
	var/bestgap = 0
	var/obj/Skills/Projectile/_Projectile/beam
	for(var/obj/Skills/Projectile/_Projectile/P in range(1, location))
		if(P.Killed || P.Distance <= 0 || !ismob(P.Owner) || P.Owner == src || !QuincyAreaFoe(P.Owner, src))
			continue
		var/gap = QuincyShotGap(P, w[1], w[2])
		if(gap > QUINCY_BOMB_REACH)
			continue
		if(P.Area == "Beam")
			beam = P
			continue
		if(!best || gap < bestgap)
			best = P
			bestgap = gap
	if(!best)
		best = beam
	if(!best)
		return 0
	var/quiet = src.QuincyBombNagAt > world.time
	if(!QuincyBombCanSeize(best, quiet))
		if(!quiet)
			src.QuincyBombNagAt = world.time + QUINCY_BOMB_NAG
		return 0
	return QuincyBombSeize(best)

/mob/proc/QuincyBombStacksNow()
	if(src.BombStacks > 0 && world.time - src.BombStampAt > QUINCY_MARK_LIFE)
		QuincyBombMarkClear()
	return src.BombStacks

/mob/proc/QuincyBombMark(mob/by)
	var/n = QuincyBombStacksNow()
	if(src.BombBy != by)
		n = 0
	src.BombStacks = min(QUINCY_MARK_MAX, n + 1)
	src.BombStampAt = world.time
	src.BombBy = by
	QuincyBombMarkShow()
	QuincyBombMarkWatch()

/mob/proc/QuincyBombMarkShow()
	if(!src.BombMarker)
		src.BombMarker = new /obj/Effects/Quincy_Bomb_Mark(null)
		src.vis_contents += src.BombMarker
	var/obj/Effects/Quincy_Bomb_Mark/o = src.BombMarker
	o.maptext = "<span style='text-align:center;color:[o.text_color]'>x[src.BombStacks]</span>"

/mob/proc/QuincyBombMarkClear()
	src.BombStacks = 0
	src.BombStampAt = 0
	src.BombBy = null
	src.BombSerial++
	if(src.BombMarker)
		var/obj/Effects/Quincy_Bomb_Mark/o = src.BombMarker
		src.vis_contents -= o
		src.BombMarker = null
		del o

/mob/proc/QuincyBombMarkWatch()
	set waitfor = 0
	var/serial = ++src.BombSerial
	sleep(QUINCY_MARK_LIFE + 1)
	if(src && src.BombSerial == serial)
		QuincyBombStacksNow()

/mob/proc/QuincyBombLate(mob/m, mult, delay)
	set waitfor = 0
	sleep(delay)
	if(!src || !m)
		return
	var/turf/t = get_turf(m)
	if(t)
		QuincyAreaDamage(t, 0, mult, src)

/mob/proc/QuincyDetonate(mark_mult, guard_delay)
	var/n = 0
	var/list/live = QuincyBombsLive()
	for(var/obj/Effects/Quincy_Bomb/b in live.Copy())
		b.Blow()
		n++
	var/list/marked = list()
	for(var/mob/m in view(QuincyViewReach(), src))
		if(m.BombBy == src)
			marked += m
	for(var/mob/m in marked)
		if(!src)
			break
		if(!m || m.QuincyBombStacksNow() <= 0)
			continue
		var/mult = m.BombStacks * mark_mult
		m.QuincyBombMarkClear()
		n++
		if(m.passive_handler && m.passive_handler["RoyalGuarding"])
			QuincyBombLate(m, mult, guard_delay)
			continue
		var/turf/t = get_turf(m)
		if(t)
			QuincyAreaDamage(t, 0, mult, src)
	return n

/mob/proc/QuincyZofielRain()
	if(!QuincyVollstandigOnNow())
		return 0
	var/mob/t = src.Target
	if(!ismob(t) || t == src || t.z != src.z)
		return 0
	var/obj/Skills/Projectile/Quincy/Zofiel_Rain/R = new
	spawn()
		if(src)
			src.UseProjectile(R, noGCD = TRUE)
	return 1

/strikeHook/quincyBombMark
	stage = "post"
	fire(strike/S)
		var/mob/a = S.attacker
		var/mob/d = S.defender
		if(!a || !d || a == d || S.dealt <= 0 || a.QuincySchrift != "E")
			return
		if(!a.QuincyBombShot(S.skill) || !a.SchriftNeeded("E"))
			return
		d.QuincyBombMark(a)

/obj/Skills/Quincy/Detonate
	name = "Detonate"
	desc = "Every bomb you made goes off at once, and every foe you marked bursts. A bomb left alone goes off on its own."
	Cooldown = 8
	Copyable = 0
	var/mark_mult = QUINCY_MARK_MULT
	var/guard_delay = QUINCY_MARK_GUARD_DELAY

	verb/Detonate()
		set name = "Detonate"
		set category = "Skills"
		var/mob/User = usr
		if(!ismob(User))
			User = src.loc
		if(!ismob(User))
			return
		DetonateFire(User)

	proc/DetonateFire(mob/User)
		if(!ismob(User) || User.KO)
			return 0
		if(!User.SchriftNeeded("E"))
			User << "Only the bearer of The Explode can set off its bombs."
			return 0
		if(User.GCDBlocked(src))
			return 0
		if(src.Using || src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return 0
		var/n = User.QuincyDetonate(src.mark_mult, src.guard_delay)
		var/rain = User ? User.QuincyZofielRain() : 0
		if(!n && !rain)
			if(User)
				User << "Nothing of yours is primed to explode."
			return 0
		src.Cooldown(1, null, User)
		return 1

/obj/Skills/Projectile/Quincy/Zofiel_Rain
	name = "Zofiel"
	ZoneAttack = 1
	ZoneAttackX = 20
	ZoneAttackY = 20
	FireFromEnemy = 1
	FireFromSelf = 0
	Blasts = 6
	Delay = 2
	Hover = 10
	StormFall = 1
	HyperHoming = 1
	ignoreBetterAim = TRUE
	Speed = 1
	Distance = 18
	DropDistance = 16
	DamageMult = 0.1
	Dodgeable = -1
	Copyable = 0
	IconLock = 'Icons/Blasts/LightStrike.dmi'
	LockX = -19
	LockY = -19
	Variation = 0
	ActiveMessage = "rains orbs of Reishi from their wings!"
