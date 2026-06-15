mob/var/tmp/ButouActive = FALSE

/obj/Skills/Buffs/SlotlessBuffs/Shinso
	name = "Shinso"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"SweepingStrike"  = 3 + SL,
			"GiantSwings"     = 3 + SL,
			"Sniper"          = 1 + SL,
			"Brutalize"       = 0.5 + (0.5 * SL),
			"BlurringStrikes" = 0.5 + (0.5 * SL),
			"Extend"          = 1.5 + (0.5 * SL)
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		StrMult = 1.2 + (0.15 * SL)
		SpdMult = 1.2 + (0.15 * SL)
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


/obj/Skills/Buffs/SlotlessBuffs/Kamishini_no_Yari
	name = "Kamishini no Yari"
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"SweepingStrike"  = 5 + SL,
			"GiantSwings"     = 5 + SL,
			"Sniper"          = 1 + SL,
			"Brutalize"       = 1.5 + (0.5 * SL),
			"BlurringStrikes" = 2.5 + (0.5 * SL),
			"Extend"          = 3 + (0.5 * SL)
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		if(SL >= 7)
			passives["Toxic"]        = 3 + SL
			passives["SilentPoison"] = 1
		StrMult = 1.4 + (0.15 * SL)
		SpdMult = 1.4 + (0.15 * SL)
		OffMult = 1.4 + (0.15 * SL)

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
				OMsg(M, "<b>[M] calls out, \"Bankai... [M.BankaiPrefix]!\"</b>")
		else
			src.Trigger(usr)


/obj/Skills/Butou
	name = "Butou"
	Cooldown = 30

	verb/Butou()
		set name = "Butou"
		set category = "Skills"
		if(!usr.CheckSlotless("Kamishini no Yari"))
			usr << "You can only use Butou in Bankai."
			return
		if(Using || cooldown_remaining)
			return
		if(!usr.Target || usr.Target == usr)
			usr << "You need a target to use Butou."
			return
		Cooldown(1, null, usr)
		OMsg(usr, "<b>[usr]'s blade extends in an instant!</b>")
		usr.ButouActive = TRUE
		usr.Melee1(forcedTarget = usr.Target)
		usr.ButouActive = FALSE


/obj/Skills/Butou_Renjin
	name = "Butou: Renjin"
	Cooldown = 90

	verb/Butou_Renjin()
		set name = "Butou: Renjin"
		set category = "Skills"
		if(!usr.CheckSlotless("Kamishini no Yari"))
			usr << "You can only use Butou: Renjin in Bankai."
			return
		if(Using || cooldown_remaining)
			return
		if(!usr.Target || usr.Target == usr)
			usr << "You need a target to use Butou: Renjin."
			return
		var/mob/M = usr
		var/mob/T = usr.Target
		Cooldown(1, null, usr)
		OMsg(M, "<b>[M]'s blade becomes a blur of piercing thrusts!</b>")
		M.ButouActive = TRUE
		spawn()
			for(var/i = 1 to 5)
				if(!M || !M.loc || !T || !T.loc) break
				M.Melee1(forcedTarget = T, BreakAttackRate = 1)
				sleep(2)
			if(M) M.ButouActive = FALSE


/obj/Skills/Korose
	name = "Korose"
	Cooldown = -1

	verb/Korose()
		set name = "Korose"
		set category = "Skills"
		if(!usr.CheckSlotless("Kamishini no Yari"))
			usr << "You can only use Korose in Bankai."
			return
		if(Using || cooldown_remaining)
			return
		if(!usr.Target || usr.Target == usr)
			usr << "You need a target to use Korose."
			return
		var/mob/target = usr.Target
		if(get_dist(usr, target) > 1)
			usr << "You must be within one tile of your target to use Korose."
			return
		if(!target.Poison || target.Poison <= 0)
			usr << "Your target has no poison stacks."
			return
		var/damage = target.Poison / 10
		Cooldown(1, null, usr)
		OMsg(usr, "<b>[usr] activates the poison hidden within [target].</b>")
		target.Poison = 0
		target.SilentPoisonAmount = 0
		target.Health -= damage
		if(target.Health <= 0 && !target.KO)
			target.Unconscious(usr, "having their body eaten away at from within by [usr]'s poison!")
