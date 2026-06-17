/obj/Skills/Projectile/Air_Blades
	name = "Air Blades"
	ManaCost = 5
	Cooldown = 5
	StrRate = 2
	ForRate = 0
	DamageMult = 10
	AccMult = 1.2
	Homing = 0
	Instinct = 2
	IconLock = 'Air Slash.dmi'
	LockX = -16
	LockY = -16
	ActiveMessage = "carves through the air with Air Blades!"

	verb/Air_Blades()
		set name = "Air Blades"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Air Blades can only be used in Shikai."
			return
		usr.UseProjectile(src)

/obj/Skills/Buffs/SlotlessBuffs/Tachikaze
	name = "Tachikaze"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Instinct"        = 1 + SL,
			"BlurringStrikes" = 0.5 + (SL * 0.5),
			"Flow"            = 1 + SL,
			"BladeFisting"    = 1,
			"Momentum"        = 0.5 + (0.5 * SL),
			"Fury"            = 0.5 + (0.5 * SL),
			"WindRelease"     = 1.25 + (0.25 * SL)
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		OffMult = 1.2 + (0.15 * SL)
		StrMult = 1.2 + (0.15 * SL)
		SpdMult = 1.2 + (0.15 * SL)

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

/obj/Skills/Projectile/Bakudantsuki
	name = "Bakudantsuki"
	Distance = 20
	DamageMult = 15
	AccMult = 1.15
	Blasts = 1
	ManaCost = 15
	Cooldown = 30
	Radius = 2
	Charge = 2
	Explode = 1
	Homing = 1
	Knockback = 1
	LosesHoming = 0
	Speed = 0.8
	Delay = 1.45
	IconLock = 'Blast12.dmi'
	IconSize = 3.4

	verb/Bakudantsuki()
		set name = "Bakudantsuki"
		set category = "Skills"
		if(!usr.InShikai())
			usr << "Bakudantsuki can only be used in Shikai."
			return
		usr.UseProjectile(src)

/obj/Skills/Buffs/SlotlessBuffs/Tekken_Tachikaze
	name = "Tekken Tachikaze"
	Slotless = 1
	IsBankaiForm = 1
	ManaThreshold = 2

	var/tmp/obj/Items/Sword/stored_zanpakuto

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"LikeWater"       = 1 + SL,
			"BlurringStrikes" = 2.5 + (SL * 0.5),
			"Fa Jin"          = 1.25 + (0.25 * SL),
			"SpiritHand"      = 4 + (1.25 * SL),
			"Momentum"        = 0.5 + (0.5 * SL),
			"Fury"            = 0.5 + (0.5 * SL),
			"Scorching"       = 1 + SL,
			"Combustion"      = 50,
			"UnarmedDamage"   = 1 + SL,
			"EruptingBlows"   = 1
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		OffMult = 1.4 + (0.15 * SL)
		StrMult = 1.4 + (0.15 * SL)
		SpdMult = 1.4 + (0.15 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(!wasOn && src.SlotlessOn)
			disarmForBankai(user)
		else if(wasOn && !src.SlotlessOn)
			rearmAfterBankai(user)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)

	// While Tekken Tachikaze is active the wielder fights unarmed
	proc/disarmForBankai(mob/user)
		var/obj/Items/Sword/z = user.EquippedSword()
		stored_zanpakuto = z ? z : null
		user.equippedSword = null

	proc/rearmAfterBankai(mob/user)
		if(stored_zanpakuto && stored_zanpakuto.loc == user && stored_zanpakuto.suffix && findtext(stored_zanpakuto.suffix, "Equipped"))
			user.equippedSword = stored_zanpakuto
		stored_zanpakuto = null

	Del()
		if(stored_zanpakuto && ismob(stored_zanpakuto.loc))
			var/mob/m = stored_zanpakuto.loc
			if(!m.equippedSword && stored_zanpakuto.suffix && findtext(stored_zanpakuto.suffix, "Equipped"))
				m.equippedSword = stored_zanpakuto
		stored_zanpakuto = null
		..()

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
			OMsg(usr, "<b>[usr] calls out, \"Bankai... [usr.BankaiPrefix] [usr.AsauchiName]!\"</b>")
		else
			src.Trigger(usr)

/obj/Skills/Queue/Enhanced_Sandbag_Beat
	name = "Enhanced Sandbag Beat"
	DamageMult = 1.5
	AccuracyMult = 1.3
	Warp = 5
	Combo = 25
	Rapid = 1
	Instinct = 2
	Duration = 10
	Cooldown = 60
	ManaCost = 20

	verb/Enhanced_Sandbag_Beat()
		set name = "Enhanced Sandbag Beat"
		set category = "Skills"
		usr.SetQueue(src)
