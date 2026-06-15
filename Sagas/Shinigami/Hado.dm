// TIER 1

/obj/Skills/Projectile/Hado/Sho
	name = "Sho"
	DamageMult = 5
	Knockback = 5
	Homing = 0
	Distance = 10
	IconLock = 'ArcaneDischarge.dmi'
	ManaCost = 3
	Cooldown = 15

	verb/Sho()
		set name = "Sho"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Hado/Byakurai
	name = "Byakurai"
	Area = "Beam"
	ChargeRate = 0.5
	BeamTime = 50
	DamageMult = 10
	Shocking = 10
	Piercing = 1
	Distance = 50
	Variation = 0
	IconSize = 1
	AccMult = 1.175
	Knockback = 0
	Deflectable = -1
	density = 0
	IconLock = 'LightningWave.dmi'
	LockY = -24
	LockX = -24
	ManaCost = 5
	Cooldown = 30

	verb/Byakurai()
		set name = "Byakurai"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Buffs/ActiveBuffs/Hado/Tsuzuri_Raiden
	name = "Tsuzuri Raiden"
	ActiveSlot = 0
	Slotless = 1
	TimerLimit = 15
	Cooldown = 30
	ManaCost = 5
	ElementalOffense = "Wind"
	ElementalDefense = "Wind"
	passives = list("Shocking"=3, "ThunderHerald"=1, "CriticalChance"=5, "CriticalDamage"=0.05)
	ActiveMessage = "conducts lightning through their body — Tsuzuri Raiden!"
	OffMessage = "releases the conducted lightning."

	verb/Tsuzuri_Raiden()
		set name = "Tsuzuri Raiden"
		set category = "Skills"
		src.Trigger(usr)

// TIER 2

/obj/Skills/Projectile/Hado/Shakkahou
	name = "Shakkahou"
	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 15
	ManaCost = 10
	Homing = 1
	Cooldown = 45
	DamageMult = 6
	Distance = 20
	Explode = 1
	Instinct = 1
	Piercing = 1
	IconLock = 'Shakkahou.dmi'
	LockX = -16
	LockY = -16
	ActiveMessage = "starts chanting..."
	var/tmp/ChantNumber = 0

	OnHeldStart(mob/p)

	OnHeldTick(mob/p)
		if(ChantNumber == 0)
			src.ActiveMessage = "chants: <b>Ye lord!</b>"
			src.DamageMult = 8
		if(ChantNumber == 1)
			src.ActiveMessage = "chants: <b>Mask of blood and flesh, all creation, flutter of wings...</b>"
			src.DamageMult = 10
		if(ChantNumber == 2)
			src.ActiveMessage = "chants: <b>...ye who bears the name of Man!</b>"
			src.DamageMult = 12
		if(ChantNumber == 3)
			src.ActiveMessage = "chants: <b>Inferno and pandemonium...</b>"
			src.DamageMult = 14
		if(ChantNumber == 4)
			src.ActiveMessage = "chants: <b>The sea barrier surges, march on to the south!</b>"
			src.DamageMult = 20
		if(ChantNumber == 5)
			src.ActiveMessage = "chants: <b>Hadō Number 31...</b>"
			src.DamageMult = 30
		if(ChantNumber <= 5)
			src.IconSize = 1 + (0.05 * (ChantNumber + 1))
			OMsg(p, "<b>[p] [src.ActiveMessage]</b>")
		ChantNumber += 1

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		src.ActiveMessage = "chants: <b><font size=+1>Shakkahō!</font></b>"
		ChantNumber = 0
		p.UseProjectile(src)
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 6
		src.IconSize = 1

	OnHeldFizzle(mob/p)
		ChantNumber = 0
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 6
		src.IconSize = 1

	verb/Shakkahou()
		set name = "Shakkahou"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.BeginHeldSkill(src)

/obj/Skills/Projectile/Hado/Oukasen
	name = "Oukasen"
	Area = "Beam"
	ChargeRate = 1
	BeamTime = 50
	DamageMult = 15
	Distance = 50
	Variation = 0
	IconSize = 1
	AccMult = 1.175
	Knockback = 1
	Deflectable = -1
	density = 0
	IconLock = 'BeamFKH.dmi'
	ManaCost = 10
	Cooldown = 45
	ActiveMessage = "releases a burst of golden energy with Hadō #32: Ōkasen!"
	verb/Oukasen()
		set name = "Oukasen"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Hado/Soukatsui
	name = "Soukatsui"
	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 15
	Homing = 0
	ManaCost = 10
	Cooldown = 45
	DamageMult = 5
	Scorching = 10
	Combustion = 0
	Distance = 20
	IconLock = 'Blast12.dmi'
	ActiveMessage = "starts chanting..."

	var/tmp/ChantNumber = 0

	OnHeldStart(mob/p)

	OnHeldTick(mob/p)
		if(ChantNumber == 0)
			src.ActiveMessage = "chants: <b>Ye lord!</b>"
			src.DamageMult = 7
			src.Scorching = 13
		if(ChantNumber == 1)
			src.ActiveMessage = "chants: <b>Mask of flesh and bone, all creation, flutter of wings...</b>"
			src.DamageMult = 10
			src.Scorching = 16
		if(ChantNumber == 2)
			src.ActiveMessage = "chants: <b>...ye who bears the name of Man!</b>"
			src.DamageMult = 14
			src.Scorching = 19
		if(ChantNumber == 3)
			src.ActiveMessage = "chants: <b>Truth and temperance...</b>"
			src.DamageMult = 17
			src.Scorching = 22
		if(ChantNumber == 4)
			src.ActiveMessage = "chants: <b>...upon this sinless wall of dreams, unleash but slightly the wrath of your claws!!</b>"
			src.DamageMult = 20
			src.Scorching = 25
			src.Combustion = 30
		if(ChantNumber == 5)
			src.ActiveMessage = "chants: <b>Hadō Number 33...</b>"
			src.Scorching = 28
			src.Combustion = 40
		if(ChantNumber <= 5)
			src.IconSize = 1 + (0.05 * (ChantNumber + 1))
			OMsg(p, "<b>[p] [src.ActiveMessage]</b>")
		ChantNumber += 1

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		src.ActiveMessage = "chants: <b><font size=+1>Sōkatsui!</font></b>"
		ChantNumber = 0
		p.UseProjectile(src)
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 5
		src.Scorching = 10
		src.Combustion = 0
		src.IconSize = 1

	OnHeldFizzle(mob/p)
		ChantNumber = 0
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 5
		src.Scorching = 10
		src.Combustion = 0
		src.IconSize = 1

	verb/Soukatsui()
		set name = "Soukatsui"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.BeginHeldSkill(src)

// TIER 3

/obj/Skills/Projectile/Hado/Haien
	name = "Haien"
	Homing = 1
	DamageMult = 20
	Scorching = 20
	Combustion = 40
	Distance = 20
	IconLock = 'Blast8.dmi'
	ManaCost = 15
	Cooldown = 60
	ActiveMessage = "hurls a violet blast of flames with Hadō #54: Haien!"
	verb/Haien()
		set name = "Haien"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Hado/Tenran
	name = "Tenran"
	Area = "Beam"
	ChargeRate = 1
	BeamTime = 50
	DamageMult = 25
	Distance = 50
	Variation = 0
	IconSize = 1
	AccMult = 1.175
	Knockback = 1
	Deflectable = -1
	density = 0
	IconLock = 'Tenran.dmi'
	ManaCost = 20
	Cooldown = 60
	ActiveMessage = "calls forth a fierce tempest with Hadō #58: Tenran!"
	verb/Tenran()
		set name = "Tenran"
		set category = "Skills"
		usr.UseProjectile(src)

// TIER 4

/obj/Skills/AutoHit/Hado/Raikouhou
	name = "Raikouhou"
	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 15
	Area = "Target"
	Distance = 20
	DamageMult = 30
	ForOffense = 1
	Bolt = 4
	BoltOffset = 0
	Paralyzing = 10
	ElementalClass = "Wind"
	HitSparkIcon = 'BLANK.dmi'
	HitSparkX = 0
	HitSparkY = 0
	ManaCost = 30
	Cooldown = 90
	ActiveMessage = "starts chanting..."

	var/tmp/ChantNumber = 0

	OnHeldStart(mob/p)

	OnHeldTick(mob/p)
		if(ChantNumber == 0)
			src.ActiveMessage = "chants: <b>Sprinkled on the bones of the beast!</b>"
			src.DamageMult = 36
			src.Paralyzing = 18
		if(ChantNumber == 1)
			src.ActiveMessage = "chants: <b>Sharp tower, red crystal, steel ring.</b>"
			src.DamageMult = 43
			src.Paralyzing = 25
		if(ChantNumber == 2)
			src.ActiveMessage = "chants: <b>Move and become the wind, stop and become the calm.</b>"
			src.DamageMult = 46
			src.Paralyzing = 33
		if(ChantNumber == 3)
			src.ActiveMessage = "chants: <b>The sound of warring spears fills the empty castle!</b>"
			src.DamageMult = 49
			src.Paralyzing = 40
		if(ChantNumber == 4)
			src.ActiveMessage = "chants: <b>Hadō Number 63...</b>"
			src.DamageMult = 52
			src.Paralyzing = 45
		if(ChantNumber <= 4)
			OMsg(p, "<b>[p] [src.ActiveMessage]</b>")
		ChantNumber += 1

	proc/RaikouhouJump(mob/p)
		var/saved_pz = p.pixel_z
		var/old_am = p.animate_movement
		p.animate_movement = 0

		// Smooth ascent to peak
		animate(p, pixel_z = saved_pz + 96, time = 8, easing = QUAD_EASING|EASE_OUT)
		sleep(8)

		// Fire at the apex
		p.Activate(src)

		// Quick descent
		animate(p, pixel_z = saved_pz, time = 4, easing = QUAD_EASING|EASE_IN)
		sleep(4)

		p.pixel_z = saved_pz
		spawn(1) p.animate_movement = old_am

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		src.DamageMult = 55
		src.Paralyzing = 50
		src.ActiveMessage = "chants: <b><font size=+2>Raikōhō!</font></b>"
		ChantNumber = 0
		RaikouhouJump(p)
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 30
		src.Paralyzing = 10

	OnHeldFizzle(mob/p)
		ChantNumber = 0
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 30
		src.Paralyzing = 10

	verb/Raikouhou()
		set name = "Raikouhou"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.BeginHeldSkill(src)

/obj/Skills/Projectile/Hado/Souren_Soukatsui
	name = "Souren Soukatsui"
	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 15
	ManaCost = 40
	Cooldown = 90
	DamageMult = 30
	Scorching = 50
	Combustion = 0
	Radius = 0
	Distance = 20
	IconLock = 'Blast12.dmi'
	ActiveMessage = "starts chanting..."

	var/tmp/ChantNumber = 0

	OnHeldStart(mob/p)

	OnHeldTick(mob/p)
		if(ChantNumber == 0)
			src.ActiveMessage = "chants: <b>Ye lord!</b>"
			src.DamageMult = 34
			src.Scorching = 60
			src.Radius = 1
		if(ChantNumber == 1)
			src.ActiveMessage = "chants: <b>Mask of blood and flesh, all creation, flutter of wings...</b>"
			src.DamageMult = 38
			src.Scorching = 70
			src.Radius = 2
		if(ChantNumber == 2)
			src.ActiveMessage = "chants: <b>...ye who bears the name of Man!</b>"
			src.DamageMult = 42
			src.Scorching = 80
			src.Radius = 3
		if(ChantNumber == 3)
			src.ActiveMessage = "chants: <b>On the wall of blue flame, inscribe a twin lotus.</b>"
			src.DamageMult = 46
			src.Scorching = 90
			src.Radius = 4
		if(ChantNumber == 4)
			src.ActiveMessage = "chants: <b>In the abyss of conflagration, wait at the far heavens.</b>"
			src.DamageMult = 50
			src.Scorching = 100
			src.Radius = 5
			src.Combustion = 60
		if(ChantNumber == 5)
			src.ActiveMessage = "chants: <b>Hadō Number 73...</b>"
			src.Radius = 6
			src.Combustion = 80
		if(ChantNumber <= 5)
			src.IconSize = 1 + (0.25 * (ChantNumber + 1))
			OMsg(p, "<b>[p] [src.ActiveMessage]</b>")
		ChantNumber += 1

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		src.ActiveMessage = "chants: <b><font size=+2>Sōren Sōkatsui!</font></b>"
		src.Radius = 7
		src.Combustion = 100
		ChantNumber = 0
		p.UseProjectile(src)
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 30
		src.Scorching = 50
		src.Combustion = 0
		src.Radius = 0
		src.IconSize = 1

	OnHeldFizzle(mob/p)
		ChantNumber = 0
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 30
		src.Scorching = 50
		src.Combustion = 0
		src.Radius = 0
		src.IconSize = 1

	verb/Souren_Soukatsui()
		set name = "Souren Soukatsui"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.BeginHeldSkill(src)

/obj/Skills/AutoHit/Hado/Zangerin
	name = "Zangerin"
	StrOffense = 2
	ManaCost = 30
	Cooldown = 75

	verb/Zangerin()
		set name = "Zangerin"
		set category = "Skills"
		var/mob/User = usr
		if(src.cooldown_remaining > 0)
			User << "[src] is on cooldown."
			return
		var/obj/Effects/ZangerinWave/W = new(User.loc)
		W.owner = User
		W.DamageMult = 40
		W.StrOffense = 2
		User.OMessage(1, null, "[User] sweeps their blade in a crescent arc with Hadō #78: Zangerin!")
		src.Cooldown(1, null, User)

/obj/Effects/ZangerinWave
	icon = 'KenShockwaveGold.dmi'
	pixel_x = -105
	pixel_y = -105
	Grabbable = 0
	mouse_opacity = 0
	layer = EFFECTS_LAYER
	var/max_size = 4.0
	var/wave_lifetime = 20
	var/tmp/mob/Players/owner
	var/DamageMult = 7
	var/StrOffense = 2
	var/EndRes = 1
	var/list/hitList = list()

	New()
		animate(src)
		transform = matrix() * 0.1
		alpha = 255
		spawn(0)
			hitDetectLoop()

	proc/hitDetectLoop()
		set waitfor = FALSE
		var/start_time = world.time
		var/prev_radius_tiles = 0.0
		var/list/outsideSet = list()
		while(src)
			var/tick_begin = world.time
			if(!owner || !owner.loc) break
			if(owner.PureRPMode)
				sleep(1)
				start_time += (world.time - tick_begin)
				continue

			var/elapsed = world.time - start_time
			if(elapsed >= wave_lifetime)
				EffectFinish()
				break

			var/t = elapsed / wave_lifetime
			var/scale = 0.1 + (max_size - 0.1) * t
			var/curr_radius_tiles = (scale * 121.0) / 32.0
			src.transform = matrix() * scale
			src.alpha = round(255 * (1 - t))

			for(var/mob/Players/P in players)
				if(!P.client) continue
				if(P == owner) continue
				if(P.z != owner.z) continue
				if(owner.inParty(P.ckey)) continue

				var/dx = P.x - owner.x
				var/dy = P.y - owner.y
				var/dist = sqrt(dx * dx + dy * dy)

				if(dist > curr_radius_tiles)
					if(!(P in outsideSet))
						outsideSet += P
				else
					if(P in outsideSet)
						outsideSet -= P
						if(!(P in hitList))
							if(dist > prev_radius_tiles)
								hitList += P
								dealWaveDamage(P)

			prev_radius_tiles = curr_radius_tiles
			sleep(1)

	proc/dealWaveDamage(mob/Players/target)
		if(!owner || !target) return
		if(owner.PureRPMode) return

		var/powerDif = owner.Power / target.Power
		if(glob.CLAMP_POWER && !owner.ignoresPowerClamp())
			powerDif = clamp(powerDif, glob.MIN_POWER_DIFF, glob.MAX_POWER_DIFF)

		var/atk = owner.GetStr(StrOffense)
		if(atk <= 0) atk = 0.01

		var/def = target.getEndStat(1) * EndRes
		if(def <= 0) def = 0.01

		var/FinalDmg = (clamp(powerDif, 0.1, 100000) ** glob.DMG_POWER_EXPONENT) * \
		               (glob.CONSTANT_DAMAGE_EXPONENT + glob.AUTOHIT_EFFECTIVNESS) ** \
		               -(def ** glob.DMG_END_EXPONENT / atk ** glob.DMG_STR_EXPONENT)
		FinalDmg *= DamageMult
		FinalDmg *= owner.GetDamageMod()
		FinalDmg *= glob.AUTOHIT_GLOBAL_DAMAGE

		if(FinalDmg <= 0) return
		target.LoseHealth(FinalDmg)

// TIER 5

/obj/Skills/Projectile/Hado/Hiryu
	name = "Hiryu Gekizoku Shinten Raihou"
	Area = "Beam"
	Radius = 1
	Variation = 0
	IconSize = 1
	AccMult = 1.175
	Knockback = 1
	Deflectable = -1
	AllOutAttack = 1
	Dodgeable = -1
	ComboMaster = 1
	density = 0
	ChargeRate = 1
	BeamTime = 50
	DamageMult = 50
	Distance = 50
	IconLock = 'BeamBig5.dmi'
	ManaCost = 50
	Cooldown = 120

	verb/Hiryu()
		set name = "Hiryu Gekizoku Shinten Raihou"
		set category = "Skills"
		usr.UseProjectile(src)

/obj/Skills/Projectile/Hado/Senju_Kouten_Taihou
	name = "Senju Kouten Taihou"
	HeldSkill = TRUE
	InfiniteHold = TRUE
	FireRate = 15
	ManaCost = 60
	Cooldown = 120
	DamageMult = 6
	Blasts = 10
	Homing = 3
	Explode = 1
	Hover = 7
	Speed = 0.25
	ZoneAttack = 1
	ZoneAttackX=3
	ZoneAttackY=3
	Distance = 20
	IconLock = 'NebulaStorm.dmi'
	ActiveMessage = "starts chanting..."

	var/tmp/ChantNumber = 0

	OnHeldStart(mob/p)

	OnHeldTick(mob/p)
		if(ChantNumber == 0)
			src.ActiveMessage = "chants: <b>Limit of the thousands hands, respectful hands, unable to touch the darkness.</b>"
			src.DamageMult = 7.5
		if(ChantNumber == 1)
			src.ActiveMessage = "chants: <b>Shooting hands unable to reflect the blue sky.</b>"
			src.DamageMult = 8
		if(ChantNumber == 2)
			src.ActiveMessage = "chants: <b>The road that basks in light, the wind that ignited the embers...</b>"
			src.DamageMult = 8.5
		if(ChantNumber == 3)
			src.ActiveMessage = "chants: <b>...time that gathers when both are together, there is no need to be hesitant, obey my orders.</b>"
			src.DamageMult = 10
		if(ChantNumber == 4)
			src.ActiveMessage = "chants: <b>Light bullets, eight bodies, nine items, book of heaven, diseased treasure, great wheel, grey fortress tower.</b>"
			src.DamageMult = 10.5
		if(ChantNumber == 5)
			src.ActiveMessage = "chants: <b>Aim far away, scatter brightly and cleanly when fired.</b>"
			src.DamageMult = 11
		if(ChantNumber == 6)
			src.ActiveMessage = "chants: <b>Hadō Number 91...</b>"
			src.DamageMult = 11.5
		if(ChantNumber <= 6)
			OMsg(p, "<b>[p] [src.ActiveMessage]</b>")
		ChantNumber += 1

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		src.ActiveMessage = "chants: <b><font size=+2>Senju Kōten Taihō!</font></b>"
		src.DamageMult = 12
		ChantNumber = 0
		p.UseProjectile(src)
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 6

	OnHeldFizzle(mob/p)
		ChantNumber = 0
		src.ActiveMessage = "starts chanting..."
		src.DamageMult = 6

	verb/Senju_Kouten_Taihou()
		set name = "Senju Kouten Taihou"
		set category = "Skills"
		if(src.ManaCost && usr.ManaAmount < src.ManaCost)
			usr << "You don't have enough mana to use [src.name]."
			return
		usr.BeginHeldSkill(src)

/obj/Skills/AutoHit/Hado/Itto_Kaso
	name = "Itto Kaso"
	WoundCost = 25
	Cooldown = -1
	DamageMult = 75
	StrOffense = 0
	ForOffense = 1
	Area = "Circle"
	Distance = 10
	TurfErupt = 2
	TurfEruptOffset = 3
	Slow = 1
	WindUp = 1.5
	WindupIcon = 'Ripple Radiance.dmi'
	WindupIconUnder = 1
	WindupIconX = -32
	WindupIconY = -32
	WindupIconSize = 1.3
	Divide = 1
	PullIn = 20
	WindupMessage = "inscribes a seal upon themselves..."
	ActiveMessage = "detonates the sacrificial flame with Hadō #96: Ittō Kasō!"
	HitSparkIcon = 'BLANK.dmi'
	HitSparkX = 0
	HitSparkY = 0
	Earthshaking = 15
	PreQuake = 1

	verb/Itto_Kaso()
		set name = "Itto Kaso"
		set category = "Skills"
		var/mob/User = usr
		if(src.Using)
			User << "[src] is on cooldown."
			return
		User.Maimed += 1
		User.recordMaim(User, "Ittō Kasō")
		User << "The sacrificial flame brands you — you are maimed!"
		User.Activate(src)
