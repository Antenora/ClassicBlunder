/*Rukia's Zanpakuto.
It's meant to be an Ice/chill themed release.
A new passive needs to be made for it, that I am just going to name 'Shirayuki' after the release itself.
This passive will make it so Chill functions differently for the user. When in Shikai/Bankai, Chill will act similar to PU spike, but do HP/Injury damage instead of energy/fatigue drain.
But it will also cause the user to harm themselves if they have too many chill stacks.
Shirayuki passive will make it so when Powering Up, you give yourself Chill-stacks.

TODO:
Add the Shirayuki passive.
Great-Deluge-like ice effect on Bankai release.
Finish Bankai.
Add unlocking/progression to the Saga Unlock code.
Make it so that Bankai actually turns your sprite all white. Might need someone else to do that. I hate vfx code.
*/

/obj/Skills/Buffs/SlotlessBuffs/Zanpakuto/Shikai/SodenoShirayuki
	name = "Sode-no-Shirayuki"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"PureDamage"     = 1 + SL, //I feel all Shikai should get this.
			"ChillResist"    = 0.5 * SL, // This should make it so that Chill hurts you less.
			"Freezing"       = 2 * SL, // This should be pretty self-explanatory, Rukia's release is an ice release. Brrr.
			"SpiritSword"    = 0.25 * SL, //Rukia always comes off as a proper hybrid as a Shinigami should be, so give users of her release soem Spirit Sword.
			"CriticalChance" = 5 * SL,
			"CriticalDamage" = 0.05 * SL,
			"Shirayuki"      = 1 //This currently does nothing but it's meant to give you Chill Stacks when you power up, and Bonuses based on chill-stacks.
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
		if(SL > 3)
			passives["IceHerald"] = 1 // Enhances the potency of the Shikai once you obtain baseline Bankai by giving your crits more OOMPH.
			passives["IceAge"] = 7.5 * SL // This is Combustion but for Chill. Seems pretty thematic.

		EndMult = 1.1 + (0.1 * SL) // I feel like ICE IS HARD makes a lot of sense here. Someone else can do the stats if they want somethign more thematic.
		ForMult = 1.1 + (0.1 * SL)
		SpdMult = 1.1 + (0.1 * SL) // Both to offset the chill nerf you give yourself while powering up with Shirayuki

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

// Bankai. It's basically a straight upgrade with some cave-ats to the Shikai. It's STRONG but comes with costs, namely hurting yourself with Bleedhit and making you slower.
/obj/Skills/Buffs/SlotlessBuffs/Zanpakuto/Bankai/HakkanoTogame
	name = "Hakka-no-Togame"
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1
	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"PureDamage"     = 1.5 * SL, //Made this a multiplier instead of an additive, Because Rukia's bankai is INCREDIBLY strong in what it does.
			"ChillResist"    = 0.5 * SL, // This should make it so that Chill hurts you less.
			"Freezing"       = 4 * SL, // This should be pretty self-explanatory, Rukia's release is an ice release. Brrr.
			"SpiritSword"    = 0.5 * SL, //Rukia always comes off as a proper hybrid as a Shinigami should be, so give users of her release soem Spirit Sword.
			"CriticalChance" = 10 * SL,
			"CriticalDamage" = 0.1 * SL,
			"AbsoluteZero"   = 1, // This gives other debuffs scaling off Chill stacks.
			"IceHerald"      = 1, // Lets you use IceHerald in Bankai, Always.
			"IceAge"         = 10 + (10 * SL), // This is Combustion but for Chill. Seems pretty thematic.
			"AttackSpeed"    = -5 + (0.5 * SL), //Ice makes you cold. Rukia is shown having difficulty moving in her Bankai, may need it's numbers tweaked.
			"Godspeed"       = -5 + (0.5 * SL), //Same Reason as above.
			"Shirayuki"      = 1 //This currently does nothing but it's meant to give you Chill Stacks when you power up, and Bonuses based on chill-stacks.
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		StrMult = 1.3 + (0.1 * SL)
		ForMult = 1.3 + (0.1 * SL)
		EndMult = 1.3 + (0.1 * SL)

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
			// Visual activation sequence
			var/mob/M = usr
			spawn()
				if(!M || !M.loc) return
				// Screen shake for the full effect duration
				M.Quake(70)
				// Apply gold glow for the duration of the visual sequence
				src.ManaGlow = "#FFFFFF"
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
				OMsg(M, "<b>[M] calls out, \"Bankai... [M.BankaiPrefix]!\"</b>")
		else
			src.Trigger(usr)


// PUT SKILLS HERE. The Shikai ones should probably feel somewhere around the potency of a T1 Sig, but with some scaling.
obj/Skills/AutoHit
	Tsukishiro
		SignatureTechnique=3
		SagaSignature=1
		StrOffense=0
		ForOffense=1
		Rounds=10
		DamageMult=0.5
		Area="Around Target"
		ElementalClass="Water"
		FlickAttack=1
		Distance=5
		Freezing=5
		Slow=1
		DistanceAround=4
		ComboMaster = 1
		ActiveMessage="Some no mai, Tsukishiro!"
		HitSparkIcon='SnowBurst.dmi'
		HitSparkX=0
		HitSparkY=0
		Cooldown=120
		ManaCost=10
		TurfStrike=1
		TurfShift='IceGround.dmi'
		TurfShiftDuration=3
		adjust(mob/p)
			Rounds = 10 + (2 * p.SagaLevel)
			DamageMult = 0.5 + (0.05 * p.SagaLevel)
			Chilling = 5 + p.SagaLevel
		verb/Tsukishiro()
			set category="Skills"
			if(!usr.InShikai() && !usr.InBankai())
				usr << "You can only use this technique in Shikai or Bankai!"
				return
			else
				usr.Activate(src)
	Hakuren
		SignatureTechnique=3
		SagaSignature=1
		StrOffense=0
		ForOffense=1
		DamageMult=10
		Area="Wave"
		ElementalClass="Water"
		FlickAttack=1
		Distance=10
		Freezing=20
		Stunner=5
		ComboMaster = 1
		WindUp = 2
		ActiveMessage="Tsugi no mai, Hakuren!"
		HitSparkIcon='SnowRing.dmi'
		HitSparkX=0
		HitSparkY=0
		Cooldown=120
		ManaCost=10
		TurfStrike=1
		TurfShift='IceGround.dmi'
		TurfShiftDuration=3
		adjust(mob/p)
			DamageMult = 10 + (0.75 * p.SagaLevel)
			Freezing = 20 + (5 * p.SagaLevel)
			WindUp = 2 - (0.25 * p.SagaLevel)
			if(p.SagaLevel > 3)
				Area="Wide Wave"
		verb/Hakuren()
			set category="Skills"
			if(!usr.InShikai() && !usr.InBankai())
				usr << "You can only use this technique in Shikai or Bankai!"
				return
			else
				usr.Activate(src)
	Hakusen // Given at T4, Bankai Exclusive
		name="Hakusen"
		ForOffense=1
		StrOffense=0
		Area="Circle"
		ElementalClass="Water"
		TurfShift='SnowFloor.dmi'
		TurfShiftDuration=60
		Distance=12
		WindUp=2
		ComboMaster=1
		GuardBreak=1
		DamageMult=10
		SpecialAttack=1
		Freezing=100
		HitSparkIcon='SnowBurst.dmi'
		HitSparkX=-32
		HitSparkY=-32
		HitSparkTurns=1
		HitSparkSize=6
		TurfStrike=1
		WindupMessage="Daishi no mai, Hakusen..."
		ActiveMessage="drops their surroundings to Absolute Zero!"
		Slow=1
		NoLock=1
		Cooldown=240
		adjust(mob/p)
			DamageMult = 10 + (3 * p.SagaLevel)
			Distance = 12 + (1 * p.SagaLevel)
		verb/Hakusen()
			set category="Skills"
			if(!usr.InBankai())
				usr << "You can only use this technique in Bankai!"
				return
			else
				usr.Activate(src)


obj/Skills/Buffs/ActiveBuffs
	Shirafune // Old Version that is an oversight. Delete this in the code after the new version is given to anyone who has the old version. This version doesn't allow stacking with PU, teehee.
		name = "Shirafune"
		SignatureTechnique=3
		SagaSignature=1
		TimerLimit=30
		Cooldown=120
		ManaCost=10
		ManaDrain=0.01
		ForMult=1.1
		StrMult=1.1
		passives=list("Extend" = 1, "SweepingStrike" = 1, "Freezing" = 3, "ManaLeak" = 2)
		ActiveMessage="San no mai, Shirafune!"
		OffMessage="lets their ice melt..."
		adjust(mob/p)
			if(!altered)
				passives=list("Extend" = 1 + (p.SagaLevel/2), "SweepingStrike" = 1 + (p.SagaLevel/2), "Freezing" = 3 * p.SagaLevel, "ManaLeak" = 2)

		verb/Shirafune()
			set category="Skills"
			usr<<"Giving you the new skill. If the new version doesn't work blame Marlon."
			usr.AddSkill(new/obj/Skills/Buffs/SlotlessBuffs/Shirafune)
			del src

obj/Skills/Buffs/SlotlessBuffs
	Shirafune // Unlocks at T3
		name = "Shirafune"
		SignatureTechnique=3
		SagaSignature=1
		TimerLimit=30
		Cooldown=120
		ManaCost=10
		ManaDrain=0.01
		ForMult=1.1
		StrMult=1.1
		passives=list("Extend" = 1, "SweepingStrike" = 1, "Freezing" = 3, "ManaLeak" = 2)
		ActiveMessage="San no mai, Shirafune!"
		OffMessage="lets their ice melt..."
		adjust(mob/p)
			if(!altered)
				passives=list("Extend" = 1 + (p.SagaLevel/2), "SweepingStrike" = 1 + (p.SagaLevel/2), "Freezing" = 3 * p.SagaLevel, "ManaLeak" = 2)

		verb/Shirafune()
			set category="Skills"
			adjust(usr)
			if(!usr.InShikai() && !usr.InBankai())
				usr << "You can only use this technique in Shikai or Bankai!"
				return
			else
				src.Trigger(usr)


/* Placeholdering this for now, for when I design the skills. Keeping this here for scaling purposes.
/obj/Skills/Projectile/True_Getsuga_Tenshou
	name = "True Getsuga Tenshou"
	Cooldown = 180
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
		FireTrue(usr)*/