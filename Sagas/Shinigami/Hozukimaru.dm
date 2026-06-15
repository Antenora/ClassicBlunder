/obj/Skills/Buffs/SlotlessBuffs/Hozukimaru
	name = "Hozukimaru"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Extend"         = 1.25 + (0.25 * SL),
			"SweepingStrike" = 1,
			"Instinct"       = 1 + SL,
			"PhysPleroma"    = 0.5 + (0.5 * SL),
			"Fury"           = 0.5 + (0.5 * SL),
			"Momentum"       = 0.5 + (0.5 * SL),
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		StrMult = 1.2 + (0.15 * SL)
		EndMult = 1.2 + (0.15 * SL)
		OffMult = 1.2 + (0.15 * SL)

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


/obj/Skills/Buffs/SlotlessBuffs/Ryumon_Hozukimaru
	name = "Ryumon Hozukimaru"
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Extend"         = 1.25 + (0.25 * SL),
			"SweepingStrike" = 1,
			"Instinct"       = 1 + SL,
			"PhysPleroma"    = 0.5 + (0.5 * SL),
			"Fury"           = 0.5 + (0.5 * SL),
			"Momentum"       = 0.5 + (0.5 * SL),
			"Harden"         = 1.5 + (0.5 * SL),
			"WarmingUp"      = 1
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		StrMult = 1.4 + (0.15 * SL)
		EndMult = 1.4 + (0.15 * SL)
		OffMult = 1.4 + (0.15 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)
			if(sf) sf.revertShihakushoIcon(user)
			user.WarmingUpBonus = 0

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
			var/mob/M = usr
			spawn()
				if(!M || !M.loc) return
				for(var/i = 1 to 10)
					if(!M || !M.loc) return
					KKTShockwave(M, icon='Icons/Effects/fevKiai.dmi', Size=1.5)
					sleep(2)
				for(var/i = 1 to 8)
					if(!M || !M.loc) return
					LightningStrikeBlackPurple(M, Offset=2)
					sleep(5)
				if(!M || !M.loc) return
				OMsg(M, "<b>[M] calls out, \"Bankai... [M.BankaiPrefix] [M.AsauchiName]!\"</b>")
		else
			src.Trigger(usr)
