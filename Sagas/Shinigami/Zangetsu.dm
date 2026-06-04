/obj/Skills/Buffs/SlotlessBuffs/Mugetsu_Aftermath
	name = "Lost Shinigami Powers"
	Slotless = 1

	adjust(mob/p)
		if(altered) return
		passives = list(
			"ManaLeak"   = 5,
			"EnergyLeak" = 5
		)
		StrMult = 0.7
		EndMult = 0.7
		ForMult = 0.7
		SpdMult = 0.5
		OffMult = 0.5
		DefMult = 0.5

/obj/Skills/Projectile/True_Getsuga_Tenshou
	name = "True Getsuga Tenshou"
	Cooldown = 180
	ManaCost=25
	NeedsSword = 1
	StrRate = 1
	ForRate = 1
	DamageMult = 35
	AccMult = 1.3
	Distance = 20
	Homing = 1
	Instinct = 2
	Explode = 1
	BypassTempHP = 1
	SkillDeicide = 20

	IconLock = 'Big Getsuga Shikai.dmi'
	LockX = -65
	LockY = -65
	Variation = 0

	ActiveMessage = "releases the true essence of Getsuga!"

	proc/FireTrue(mob/p)
		if(!p || !p.loc) return
		if(!p.Target || p.Target == p)
			p << "You need a target to use True Getsuga Tenshou."
			return
		if(Using || cooldown_remaining) return

		src.Cooldown(1, null, p)
		OMsg(p, "<b><font color='#1a1a2e'>[p] [ActiveMessage]</font></b>")
		p.Blast(src, p, 1, 'Big Getsuga Shikai.dmi')

	verb/True_Getsuga_Tenshou()
		set name = "True Getsuga Tenshou"
		set category = "Skills"
		if(!usr.CheckSlotless("Tensa Zangetsu"))
			usr << "True Getsuga Tenshou can only be used in Bankai."
			return
		FireTrue(usr)

/obj/Skills/Buffs/SlotlessBuffs/Zangetsu
	name = "Zangetsu"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Zornhau"        = 1 + SL,
			"HybridStrike"   = 0.5 + (SL/2),
			"Half-Sword"     = 1 + SL,
			"Instinct"       = 1 + SL,
			"HeavyHitter" 	 = 1 + (0.25 * SL),
			"PureDamage"     = 1 + SL
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		if(SL >= 7)
			passives["DoubleStrike"] = 5
		if(SL >= 7)
			StrMult = 1.15 + (0.15 * SL)
			ForMult = 1.15 + (0.15 * SL)
			SpdMult = 1.15 + (0.15 * SL)
		else
			StrMult = 1.1 + (0.1 * SL)
			ForMult = 1.1 + (0.1 * SL)
			OffMult = 1.1 + (0.1 * SL)

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
			if(!locate(/obj/Skills/Projectile/Getsuga_Tenshou, usr))
				usr.AddSkill(new/obj/Skills/Projectile/Getsuga_Tenshou)
		else
			src.Trigger(usr)

/obj/Skills/Buffs/SlotlessBuffs/Tensa_Zangetsu
	name = "Tensa Zangetsu"
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1
	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"Flicker"         = 1 + SL,
			"BlurringStrikes" = 1 + SL,
			"Afterimages"     = 1,
			"Godspeed"        = 1 + SL,
			"Warping"         = 0.5 + (SL/2),
			"HybridStrike"    = 1.5 + (SL/2),
			"EmptyFlashStep"  = 1,
			"PureDamage"      = 1 + SL,
			"SwordAscension"  = SL,
			"Steady"          = 1 + SL
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		if(SL >= 7)
			passives["Deicide"]  = 15
			passives["EndlessNine"]  = 0.5
		if(SL >= 7)
			StrMult = 1.4 + (0.15 * SL)
			ForMult = 1.4 + (0.15 * SL)
			SpdMult = 1.15 + (0.15 * SL)
			OffMult = 1.15 + (0.15 * SL)
		else
			StrMult = 1.3 + (0.1 * SL)
			ForMult = 1.3 + (0.1 * SL)
			SpdMult = 1.3 + (0.1 * SL)

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)
			if(sf) sf.revertShihakushoIcon(user)
			if(istype(user.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Sword/Getsuga_Tenshou_Clad))
				user.SpecialBuff.Trigger(user)
			if(istype(user.SpecialBuff, /obj/Skills/Buffs/SpecialBuffs/Sword/Final_Getsuga_Tenshou))
				user.SpecialBuff.Trigger(user)

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
			// Visual activation sequence
			var/mob/M = usr
			spawn()
				if(!M || !M.loc) return
				// Screen shake for the full effect duration
				M.Quake(70)
				// Apply gold glow for the duration of the visual sequence
				src.ManaGlow = "#FFD700"
				src.ManaGlowSize = 2
				M.AppearanceOff()
				M.AppearanceOn()
				// shockwaves
				sleep(5)
				if(!M || !M.loc) return
				var/ShockSize = 5
				for(var/wav = 5, wav > 0, wav--)
					KenShockwave(M, 'Icons/Effects/KenShockwaveGold.dmi', ShockSize, 0, 0, 2, 15)
					ShockSize /= 2
				// Wait until ~3 seconds from activation
				sleep(25)
				if(!M || !M.loc) return
				// Spawn dust cloud ring around player
				var/list/dusts = list()
				var/list/dust_dx = list()
				var/list/dust_dy = list()
				var/list/d_offs = list(
					list(0,3), list(0,-3), list(3,0), list(-3,0),
					list(2,2), list(-2,2), list(2,-2), list(-2,-2)
				)
				for(var/L in d_offs)
					var/list/od = L
					var/turf/T = locate(M.x + od[1], M.y + od[2], M.z)
					if(!T) continue
					var/obj/Effects/Dust/D = new/obj/Effects/Dust()
					D.loc = T
					D.layer = EFFECTS_LAYER
					animate(D, transform=matrix()*2, time=4)
					dusts += D
					dust_dx += od[1]
					dust_dy += od[2]
				Dust(M.loc, 2)
				Dust(M.loc, 2)
				// Hover for ~2 seconds
				sleep(20)
				if(!M || !M.loc)
					for(var/obj/Effects/Dust/D in dusts) if(D) del D
					return
				// Suck the dust clouds in toward the player
				for(var/i = 1 to dusts.len)
					var/obj/Effects/Dust/D = dusts[i]
					var/dx = dust_dx[i]
					var/dy = dust_dy[i]
					if(!D || !D.loc) continue
					animate(D, pixel_x = -(dx*32), pixel_y = -(dy*32), time=6, easing=CUBIC_EASING)
				sleep(6)
				// delete spawn fresh dust objects at
				// the player's tile so transition is clean
				for(var/obj/Effects/Dust/D in dusts) if(D) del D
				// Expel outward
				var/list/expel_objs = list()
				var/list/expel_offs = list(
					list(0, 96),    // N
					list(0, -96),   // S
					list(96, 0),    // E
					list(-96, 0),   // W
					list(64, 64),   // NE
					list(-64, 64),  // NW
					list(64, -64),  // SE
					list(-64, -64)  // SW
				)
				for(var/L in expel_offs)
					var/list/ep = L
					var/obj/Effects/Dust/E = new/obj/Effects/Dust()
					E.loc = M.loc
					E.layer = EFFECTS_LAYER
					E.transform = matrix() * 2
					animate(E, alpha=0, pixel_x=ep[1], pixel_y=ep[2], time=10, easing=SINE_EASING)
					expel_objs += E
				sleep(12)
				// Clean up expulsion dust
				for(var/obj/Effects/Dust/E in expel_objs) if(E) del E
				// Glow fades as Bankai is called
				src.ManaGlow = null
				src.ManaGlowSize = 0
				M.AppearanceOff()
				M.AppearanceOn()
				OMsg(M, "<b>[M] calls out, \"Bankai... [M.BankaiPrefix] [M.AsauchiName]!\"</b>")
		else
			src.Trigger(usr)
