obj/Skills/Projectile/Getsuga_Tenshou
	name = "Getsuga Tenshou"
	ManaCost=5
	Cooldown = 3
	NeedsSword=1
	StrRate = 1
	ForRate = 1
	DamageMult = 5
	AccMult = 1.2
	Distance = 20
	Homing = 1
	Instinct = 2
	Explode = 1

	IconLock = 'Small Getsuga.dmi'
	Variation = 0

	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 1.5
	SweetSpotBenefit = 2
	ChargeOverlay='DarkShock.dmi'
	ChargeWaveIcon='KenShockwaveBloodlust.dmi'

	ActiveMessage = "releases a wave of Getsuga!"

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		var/icon_used
		var/baseDmg = initial(DamageMult)
		var/bonus = p.CheckSlotless("Tensa Zangetsu") ? 5 : 0
		DamageMult = (baseDmg + bonus) * benefit
		var/inBankai = p.CheckSlotless("Tensa Zangetsu")
		if(sweet_spot_hit)
			icon_used = inBankai ? 'Big Getsuga.dmi' : 'Big Getsuga Shikai.dmi'
			LockX = -65
			LockY = -65
		else
			icon_used = inBankai ? 'Small Getsuga.dmi' : 'Small Getsuga Shikai.dmi'
		p.Blast(src, p, 1, icon_used)
		src.Cooldown(1, null, p)
		ResetHeldConfig()

	verb/Getsuga_Tenshou()
		set category = "Skills"
		if(!usr.InShikai() && !usr.InBankai())
			usr << "Getsuga Tenshou can only be used in Shikai or Bankai."
			return
		if(usr.InBankai())
			ChargeWaveIcon = 'KenShockwaveBloodlust.dmi'
			ChargeOverlay = 'DarkShock.dmi'
		else
			ChargeWaveIcon = 'KenShockwaveGold.dmi'
			ChargeOverlay = 'Dimension Aura.dmi'
		usr.BeginHeldSkill(src)

obj/Skills/Projectile/Getsuga_Jujisho
	name = "Getsuga Jujisho"
	Cooldown = 120
	ManaCost=20
	NeedsSword=1
	StrRate = 1
	ForRate = 1
	DamageMult = 25
	AccMult = 1.3
	Distance = 20
	Homing = 1
	Instinct = 1

	IconLock = 'Slash - Vampire Gold.dmi'
	LockX = -16
	LockY = -16
	Variation = 0

	GrowingLife = 1
	IconSizeGrowTo = 3

	Overpowering = 1

	Explode = 12
	Radius = 1

	ActiveMessage = "focuses their Getsuga into a devastating cross-shaped strike!"

	proc/FireJujisho(mob/p)
		if(!p || !p.loc) return
		if(!p.Target || p.Target == p)
			p << "You need a target to use Getsuga Jujisho."
			return
		if(Using || cooldown_remaining) return

		var/client/C = p.client
		if(!C) return

		src.Cooldown(1, null, p)
		OMsg(p, "<b><font color='#ffcc00'>[p] [ActiveMessage]</font></b>")

		var/ox = -16
		var/oy = -16
		switch(p.dir)
			if(NORTH)
				oy += 32
			if(SOUTH)
				oy -= 32
			if(EAST)
				ox += 32
			if(WEST)
				ox -= 32
			if(NORTHEAST)
				ox += 24
				oy += 24
			if(NORTHWEST)
				ox -= 24
				oy += 24
			if(SOUTHEAST)
				ox += 24
				oy -= 24
			if(SOUTHWEST)
				ox -= 24
				oy -= 24

		// First slash
		var/image/img1 = image('Slash - Vampire Gold.dmi', p)
		img1.icon_state = ""
		img1.pixel_x = ox
		img1.pixel_y = oy
		img1.layer = MOB_LAYER + 0.5
		C.images += img1

		sleep(4)

		img1.icon_state = "slash1" // freeze on the static end-frame

		sleep(10)

		// Second slash
		var/image/img2 = image('Slash - Vampire Gold.dmi', p)
		img2.icon_state = "other"
		img2.pixel_x = ox
		img2.pixel_y = oy
		img2.layer = MOB_LAYER + 0.5
		C.images += img2

		sleep(4)

		img2.icon_state = "slash2"

		sleep(5) // brief hold before firing

		// Remove animation icons then fire
		C.images -= img1
		C.images -= img2

		if(!p || !p.loc) return

		var/list/before = p.active_projectiles.Copy()
		p.Blast(src, p, 0, 'Slash - Vampire Gold.dmi')

		// switches animation icons to final icon
		var/obj/Skills/Projectile/_Projectile/proj = null
		for(var/pr in p.active_projectiles)
			if(!(pr in before))
				proj = pr
				break

		if(proj)
			proj.icon_state = "slash3"
			proj.transform = matrix()
			animate(proj, transform = matrix() * IconSizeGrowTo, time = 5, easing = CUBIC_EASING)

	verb/Getsuga_Jujisho()
		set category = "Skills"
		if(!usr.InShikai() && !usr.InBankai())
			usr << "Getsuga Jujisho can only be used in Shikai or Bankai."
			return
		FireJujisho(usr)
