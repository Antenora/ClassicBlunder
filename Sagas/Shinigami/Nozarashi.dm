mob/var/tmp/LeapAttackSweetSpotActive = FALSE

/obj/Skills/Buffs/SlotlessBuffs/Unleash_Spiritual_Pressure
	name = "Unleash Spiritual Pressure"
	Slotless = 1
	ManaThreshold = 3

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"PureDamage"     = 1 + SL,
			"PureReduction"  = 1 + SL,
			"Persistence"    = 1 + SL,
			"NoDodge"        = 1,
			"KillerInstinct" = 0.15 + (0.1 * SL),
			"Instinct"       = 1 + SL,
			"ManaStats"      = 1 + SL,
			"Pressure"       = 1 + SL,
			"ManaLeak"       = 4,
			"ZenkaiPower"    = 0.15
		)
		StrMult = 1.15 + (0.1 * SL)
		EndMult = 1.15 + (0.1 * SL)
		DefMult = 1.15 + (0.1 * SL)
		OffMult = 1.15 + (0.1 * SL)
		SpdMult = 1.15 + (0.1 * SL)

	verb/Unleash_Spiritual_Pressure()
		set category = "Skills"
		set name = "Unleash Spiritual Pressure"
		if(!src.SlotlessOn)
			if(!usr.InShinigamiForm)
				usr << "You must be in Shinigami Form to unleash your Spiritual Pressure."
				return
			if(usr.InShikai())
				usr << "You cannot unleash your Spiritual Pressure while in Shikai."
				return
			if(usr.InBankai())
				usr << "You cannot unleash your Spiritual Pressure while in Bankai."
				return
			adjust(usr)
			OMsg(usr, "<b>[usr]'s Spiritual Pressure surges!</b>")
			src.Trigger(usr)
		else
			src.Trigger(usr)

/obj/Skills/Queue/Two_Hands
	name = "Two Hands"
	HitMessage = "swings with both hands!"
	DamageMult = 15
	AccuracyMult = 1.175
	Duration = 15
	KBMult = 20
	KBAdd = 20
	PushOut = 3
	PushOutWaves = 2
	Finisher = 1
	Quaking = 5
	Cooldown = 60
	EnergyCost = 4
	Determinator = 1
	Delayer = 0.15

	verb/Two_Hands()
		set category = "Skills"
		set name = "Two Hands"
		usr.SetQueue(src)

/obj/Skills/Buffs/SlotlessBuffs/Nozarashi
	name = "Nozarashi"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"PureDamage"    = 1 + SL,
			"PureReduction" = 1 + SL,
			"Persistence"   = 1 + (SL/2),
			"BulletKill"    = 1,
			"NoDodge"       = 1,
			"Brutalize"     = 0.5 + (0.5 * SL),
			"Zornhau"       = 1 + SL,
			"Inevitable"    = 1 + SL,
			"Instinct"      = 1 + SL,
			"UnderDog"      = 1 + (SL*1.25),
			"ZenkaiPower" = 0.25
		)
		if(SL < 5)
			passives["ManaLeak"] = 2
		StrMult = 1.35 + (0.15 * SL)
		EndMult = 1.35 + (0.15 * SL)
		OffMult = 1.35 + (0.15 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)

	verb/Shikai()
		set name = "Shikai"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(!usr.InShinigamiForm)
				usr << "You must be in Shinigami Form to use Shikai."
				return
			if(usr.InBankai())
				usr << "You cannot use Shikai while in Bankai."
				return
			var/obj/Skills/Buffs/SlotlessBuffs/Unleash_Spiritual_Pressure/usp = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Unleash_Spiritual_Pressure)
			if(usp && usp.SlotlessOn)
				usr << "You cannot use Shikai while Unleashing your Spiritual Pressure."
				return
			var/hasZanpakuto = FALSE
			for(var/obj/Items/i in usr)
				if(i.IsZanpakuto && i.suffix)
					hasZanpakuto = TRUE
					break
			if(!hasZanpakuto)
				usr << "You must have your Zanpakutō equipped to use Shikai."
				return
			adjust(usr)
			OMsg(usr, "<b>[usr] calls out, \"[usr.ShikaiCall], [usr.AsauchiName]!\"</b>")
			src.Trigger(usr)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.applyShikaiIcon(usr)
		else
			src.Trigger(usr)

/obj/Skills/AutoHit/Leap_Attack
	name = "Leap Attack"
	HeldSkill = TRUE
	ChargePeriod = 3
	SweetSpot = 1.5
	Cooldown = 5

	verb/Leap_Attack()
		set category = "Skills"
		set name = "Leap Attack"
		if(!usr.InShikai() && !usr.InBankai())
			usr << "You can only use Leap Attack while in Shikai or Bankai."
			return
		if(!usr.Target || usr.Target == usr)
			usr << "You need a target to use Leap Attack."
			return
		if(get_dist(usr, usr.Target) > 15)
			usr << "Your target is too far away to leap to."
			return
		usr.BeginHeldSkill(src)

	OnHeldRelease(mob/p, benefit, sweet_spot_hit)
		var/mob/target = p.Target
		if(!target || target == p || !target.loc || target.z != p.z)
			return

		var/turf/landing = get_step(get_turf(target), get_dir(get_turf(target), p))
		if(!landing || !landing.loc)
			landing = get_turf(target)

		var/dmg = 1 + (0.5 * benefit)

		if(sweet_spot_hit)
			p.LeapAttackSweetSpotActive = TRUE

		p.LeapAnimation(landing)

		// Teleport and clean up visual offsets
		p.loc = landing
		p.pixel_x = 0
		p.pixel_y = 0
		animate(p)
		if(p.client)
			p.client.pixel_x = 0
			p.client.pixel_y = 0
			animate(p.client)

		p.Quake(20)
		for(var/turf/t in range(1, get_turf(p)))
			TurfShift('Dirt1.dmi', t, 30, p)

		// Only strike if original target is still within 2 tiles of landing
		if(target && target.loc && get_dist(p, target) <= 2)
			p.Melee1(forcedTarget = target, dmgmulti = dmg)
		else
			p.LeapAttackSweetSpotActive = FALSE

		Cooldown(1, null, p)

/mob/proc/LeapAnimation(turf/target_turf)
	var/saved_pz = pixel_z
	var/jump_time = max(2, 2 * get_dist(src, target_turf))
	var/half = max(1, round(jump_time / 2))

	var/px_dest = round(1 + ((x - target_turf.x) * -32), 16)
	var/py_dest = round(1 + ((y - target_turf.y) * -32), 16)

	dir = get_dir(src, target_turf)

	var/old_am = animate_movement
	animate_movement = 0

	animate(src, pixel_z = saved_pz + 80, time = half, easing = QUAD_EASING|EASE_OUT)
	animate(pixel_z = saved_pz, time = half, easing = QUAD_EASING|EASE_IN)

	animate(src, pixel_x = px_dest, pixel_y = py_dest, time = jump_time, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	if(client)
		animate(client, pixel_x = px_dest, pixel_y = py_dest, time = jump_time, easing = LINEAR_EASING)

	sleep(jump_time)

	pixel_z = saved_pz
	spawn(1) animate_movement = old_am

/obj/Skills/Buffs/SlotlessBuffs/Nozarashi_Bankai
	name = "Nozarashi"
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Duelist"           = 0.5 + (SL * 1.5),
			"Persistence"       = 3 + (SL/2),
			"PridefulRage"      = 1,
			"BulletKill"        = 1,
			"NoDodge"           = 1,
			"Half-Sword"        = 1 + SL,
			"Instinct"          = 1 + SL,
			"DemonicDurability" = 1 + SL,
			"HellRisen"         = 0.25 + (0.25 * SL),
			"Juggernaut"        = 1 + SL,
			"UnderDog"          = 1 + (SL*2),
			"ZenkaiPower"       = 0.5
		)
		if(SL < 7)
			passives["BleedHit"] = 2
		StrMult = 1.5 + (0.15 * SL)
		EndMult = 1.5 + (0.15 * SL)
		OffMult = 1.5 + (0.15 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)
			if(sf) sf.revertShihakushoIcon(user)

	verb/Bankai()
		set name = "Bankai"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(!usr.InShinigamiForm)
				usr << "You must be in Shinigami Form to use Bankai."
				return
			if(usr.InShikai())
				usr << "You must end Shikai before entering Bankai."
				return
			var/obj/Skills/Buffs/SlotlessBuffs/Unleash_Spiritual_Pressure/usp = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Unleash_Spiritual_Pressure)
			if(usp && usp.SlotlessOn)
				usr << "You cannot use Bankai while unleashing your Spiritual Pressure."
				return
			var/hasZanpakuto = FALSE
			for(var/obj/Items/i in usr)
				if(i.IsZanpakuto && i.suffix)
					hasZanpakuto = TRUE
					break
			if(!hasZanpakuto)
				usr << "You must have your Zanpakutō equipped to use Bankai."
				return
			adjust(usr)
			src.Trigger(usr)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = usr.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.applyBankaiIcon(usr)
			if(sf) sf.applyBankaiShihakushoIcon(usr)
			var/mob/M = usr
			spawn()
				if(!M || !M.loc) return
				for(var/i = 1 to 10)
					if(!M || !M.loc) return
					KKTShockwave(M, icon='Icons/Effects/fevKiai.dmi', Size=1.5)
					sleep(2)
				if(!M || !M.loc) return
				OMsg(M, "<b>[M] calls out, \"Bankai... [M.BankaiPrefix] [M.AsauchiName]!\"</b>")
		else
			src.Trigger(usr)
