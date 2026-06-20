//The Zanpakuto of Isshin Kurosaki/Shiba
//The Shikai is confirmed, but the Bankai is not. So the bankai is fanon.
//But I love Daddy Isshin, so I'm coding this as a pet-project. This is not meant to be included in the game right now.
//Isshin's Bankai is meant to be difficult to activate when injured, as it puts serious strain on his body. I'll be giving it mechanics like that.
//Yamamoto won't be the only Fire Zanpakuto if i have anything to say about it.
//I REPEAT, THIS IS A NEXT-WIPE THING, DO NOT INCLUDE IT IN THE GAME THIS WIPE.

//To DO:
//Phoenix Wings default icon when Bankai is active.
//Balance testing.

/obj/Skills/Buffs/SlotlessBuffs/Zanpakuto/Shikai/Engetsu
	name = "Engetsu"
	Slotless = 1
	ManaThreshold = 2
	IsShikaiForm = 1

	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		passives = list(
			"BladeFisting"   = 1, //Isshin has been shown to be just as talented, if not more so with Hand-to-hand as he is with a sword.
			"HybridStrike"   = 0.5 + (SL/2), //Sword on fire, should be self explanatory why it gets this.
			"Scorching"      = 2 * SL, // Fire sword burns you when it touches you, who would've thought.
			"Combustion"     = 7.5 * SL, // BOOM.
			"CriticalChance" = 5 * SL, // Exists to proc DemonicInfusion. This release does not get bonus crit damage.
			"DemonicInfusion"= 1, // Causes a field of Fire on Crit. The same as Shirayuki's Ice Herald.
			"SweepingStrike" = 0.5 * SL, //The flames get FUCKING BIG the better you are at being a Shinigami.
			"PureDamage"     = 1 + SL
		)
		if(SL < 3)
			passives["ManaLeak"] = 2
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
			if(!locate(/obj/Skills/Projectile/Blazing_Getsuga_Tenshou, usr))
				usr.AddSkill(new/obj/Skills/Projectile/Blazing_Getsuga_Tenshou)
		else
			src.Trigger(usr)

//This Bankai is meant to be Gorked, because of it's draw backs. Mainly the taxes once it falls off, that scale with it's main mechanics of self-burn and it falling off automatically at low HP.
//Engetsu is a 'I am fighting to End my Opponent' type of Bankai, you do not use this shit unless you're in a lethal, or you wanna Aura Farm at the cost of insane taxes.
//There was a reason Aizen was scared of Isshin's Bankai enough to sneak attack him and stop him from entering it against White, so I wanted to give the Bankai that energy.
/obj/Skills/Buffs/SlotlessBuffs/Zanpakuto/Bankai/Hisho_Engetsu
	name = "Hisho Engetsu"// Hisho translates to Flying. Phoenix thematics.
	Slotless = 1
	ManaThreshold = 2
	IsBankaiForm = 1
	adjust(mob/p)
		if(altered) return
		var/SL = p.SagaLevel
		if(SL < 7)
			HealthThreshold = 35 - (SL * 5) //Forces you out of Bankai if your health drops too low.
		else
			HealthThreshold = 0
		passives = list(
			"BladeFisting"    = 1, //Isshin has been shown to be just as talented, if not more so with Hand-to-hand as he is with a sword.
			"HybridStrike"    = 1.5 + (SL/2), //Sword on fire, should be self explanatory why it gets this.
			"Scorching"       = 4 * SL, // Fire sword burns you when it touches you, who would've thought.
			"Combustion"      = 10 + (10 * SL), // BOOM.
			"CriticalChance"  = 10 * SL, // Exists as a Proc for Demonic Infusion. This release does not get bonus crit damage.
			"DemonicInfusion" = 1, // Crits cause fire AoEs
			"SweepingStrike"  = 1.5 + (0.5 * SL), //The flames get FUCKING BIG the better you are at being a Shinigami.
			"PureDamage"      = 1.5 * SL,
			"PureReduction"   = 1.5 * SL,
			"BurningShot"     = 1, // Causes you to burn yourself but increases your stats.
			"BurnHit"         = 2 - (0.25 * SL), //Self-burning when dealing damage. IDK if this is needed with BurningShot just yet.
			"UnderDog"        = 2.5 * (SL - 3),  // Increases PureDamage/PureReduction by Injury amount.
			"Skimming"        = 1 // Phoenix goes Fly, Brrrr...
		)
		if(SL < 5)
			passives["ManaLeak"] = 4
		if(SL > 4)
			passives["Skimming"] = 2 // Fly Betterer
			passives["Persistence"] = 2.5 * (SL - 3) //Chance that HP Damage is converted into Injury instead.
		if(SL >= 7)
			passives["Unbreakable"] = -0.1 + (p.AscensionsAcquired * 0.1) //At max Saga Level, you can ignore some of your Taxes while in Bankai. up to 50% at Asc 6.
		StrMult = 1.3 + (0.15 * SL)
		ForMult = 1.3 + (0.15 * SL)
		OffMult = 1.3 + (0.15 * SL)
		EndMult = 1.1 + (0.05 * SL)
		SpdMult = 1.1 + (0.05 * SL)
		DefMult = 1.1 + (0.05 * SL)
		//Before you yell at me about the stats Reminder that this Bankai gets forced-shut-off at low HP, and when it shuts off, gives you omni-stat taxes.

	Trigger(mob/user)
		var/wasOn = src.SlotlessOn
		..()
		if(wasOn && !src.SlotlessOn)
			var/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form/sf = user.FindSkill(/obj/Skills/Buffs/SlotlessBuffs/Shinigami_Form)
			if(sf) sf.revertZanpakutoIcon(user)
			if(sf) sf.revertShihakushoIcon(user)
			//Forces you to take Taxes once the Bankai drops, to all Stats, relative to your Burn amount.
			if(usr.SagaLevel < 6)
				usr.AddOmniTax(usr.Burn/100)
			else // At Saga Level 6, Taxes become a bit less Egregious when you fall out of Bankai.
				usr.AddOmniTax(usr.Burn/200)

	verb/Bankai()
		set name = "Bankai"
		set category = "Skills"
		if(!src.SlotlessOn)
			if(usr.SagaLevel < 7 && usr.Health < 90 - (usr.SagaLevel * 10)) // Checks to see if your HP is high enough to activate this gorked-ass-fucking-bankai.
				src<<"You are to injured to enter your Bankai."
				return
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
				// Apply orange glow for the duration of the visual sequence
				src.ManaGlow = "#FF8800"
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

//SKILLS HERE.

//A variant of Getsuga Tenshou. Instead of Charging, this variant becomes stronger the more Burn the user has on them.
//I like charge skills but I don't think it plays well with the playstyle of this particular Zanpakuto, which is very high-risk-high-reward.
/obj/Skills/Projectile/Blazing_Getsuga_Tenshou //Given at T2
	name = "Blazing Getsuga Tenshou"
	ElementalClass="Fire"
	SignatureTechnique=3
	SagaSignature=1
	ManaCost=5
	Cooldown = 30// Shares cooldown with regular Getsuga Tenshou. Justified here by the fact it burns you and it's mana cost.
	NeedsSword=1
	StrRate = 1
	ForRate = 1
	Scorching = 1
	DamageMult = 5
	AccMult = 1.2
	Distance = 20
	Homing = 1
	Instinct = 2
	Explode = 1
	IconLock = 'Blast - Dual Fire Blast.dmi' //Placeholder.
	ActiveMessage = "releases a blazing wave of Getsuga!"
	adjust(mob/p)
		DamageMult = 5 + (p.SagaLevel * 0.25) + (p.Burn/20)
		Scorching = 1 + (p.Burn/20)// 100 Burn on the user = 6 Scorching

	verb/Blazing_Getsuga_Tenshou()
		set category = "Skills"
		if(!usr.InShikai() && !usr.InBankai())
			usr << "Getsuga Tenshou can only be used in Shikai or Bankai."
			return
		else
			usr.AddBurn(usr.SagaLevel)// Burns the user on activation.
			usr.UseProjectile(src)

/obj/Skills/AutoHit//Given at T3
	BloodFireBurst// This is the technique that Isshin uses when he mixes someone of his blood and explodes
		name = "Blood Fire Burst"
		SignatureTechnique=3
		SagaSignature=1
		StrOffense=1
		ForOffense=1
		DamageMult=10
		Area="Circle"
		ElementalClass="Fire"
		FlickAttack=1
		Distance=5
		Scorching=20
		WoundCost=5
		Launcher=5
		ComboMaster = 1
		GuardBreak = 1
		Rush=5
		ControlledRush=1
		WindUp = 0.1
		ActiveMessage="blends their blood into their flames, letting off a powerful burst!"
		HitSparkIcon='fire.dmi'
		HitSparkX=0
		HitSparkY=0
		Cooldown=45// The Cooldown for a sig is low, but that's because it Injures and Burns you to use it. due to the activation Burn and WoundCost
		ManaCost=10
		TurfStrike=1
		TurfShift='LavaRock2.dmi'
		TurfShiftDuration=3
		adjust(mob/p)//This shit FUCKS the more banged up you are. High risk, high reward shenanigans.
			DamageMult = 10 + (0.25 * p.SagaLevel) + ((100-p.Health)/20) + (p.TotalInjury/20)
			Scorching = 20 + (5 * p.SagaLevel)
			Rush = 5 + (p.Burn/20)
			Distance = 5 + ((100-p.Health)/20)
			if(p.SagaLevel > 3)
				MortalBlow = 1 + (p.Burn/25)
				Earthshaking=5
			if(p.InBankai() && p.TotalInjury >=25)
				MaimStrike = 1 + (p.Burn/25) //God Help You if this procs. This ONLY HAPPENS in Bankai. But if it happens, you're getting a part of you incinerated on the spot.
		verb/BloodFireBurst()
			set category="Skills"
			if(!usr.InShikai() && !usr.InBankai())
				usr << "You can only use this technique in Shikai or Bankai!"
				return
			else
				usr.AddBurn(usr.SagaLevel) // Burns the user on activation.
				usr.Activate(src)

/obj/Skills/Utility
	PhoenixDown//Given at T4, when you get Bankai, may lower to T3. Phoenix Healing.
		Teachable=0
		SignatureTechnique=3
		SagaSignature=1
		Cooldown=30
		verb/Phoenix_Down()
			set category = "Utility"
			name = "Phoenix Down"
			var/list/who=list("Cancel")
			for(var/mob/Players/M in oview(5,usr))
				who.Add(M)
			if(usr.SagaLevel<6 && usr.TotalInjury >= 50)
				usr<<"You're too exhausted to manifest the healing powers of the Phoenix."
				return
			if(src.Using==1) return
			src.Using=1
			var/mob/selector=input("Who do you want to Heal?","Phoenix Healing")in who||null
			if(selector=="Cancel")
				return
			else
				if(selector.BPPoisonTimer>1&&selector.BPPoison<1)
					selector.BPPoison=1
					selector.BPPoisonTimer=1
					usr<<"You removed [selector]'s serious injuries!"
					selector<<"[usr] removed your serious injuries!"
				if(selector.MortallyWounded>0)
					selector.MortallyWounded-=1
					if(selector.MortallyWounded<0)
						selector.MortallyWounded=0
					usr<<"You lessened [selector]'s bleeding!"
					selector<<"[usr] lessened your bleeding!"
				if(selector.TotalInjury) //
					usr.TotalInjury += selector.TotalInjury/2
					selector.TotalInjury=0
					usr<<"You absorbed [selector]'s injuries!"
					selector<<"[usr] absorbed injuries!"
					src.Using=0
					return
				if(selector.TotalFatigue)
					usr.TotalInjury += selector.TotalFatigue/2
					selector.TotalFatigue=0
					usr<<"You absorbed [selector]'s fatigue!"
					selector<<"[usr] absorbed your fatigue!"
					src.Using=0
					return
				if(usr.SagaLevel>5)//At Level 6, you can heal maims. But it Omni-taxes. May lower this to level 5, but with harsher taxes.
					if(selector.Maimed)
						usr.Maimed-=1
						if(usr.Maimed<0)
							usr.Maimed=0
						usr.AddOmniTax(0.25)
						selector.AddOmniTax(0.25)
						usr<<"You regenerated a part of [selector]'s body with the power of the Phoenix... but not without cost."
						selector<<"[usr] regenerated a part of your body with the power of the Phoenix... but not without cost."
						src.Using=0
						return

/obj/Skills/Projectile
	BrilliantFireworks//Given at T4-T5, Bankai Ultimate move. Basically a Suped up Homing Finisher. It's a once per-battle move.
		name="100 Brilliant Fireworks"
		SignatureTechnique=3
		SagaSignature=1
		IconLock = 'FireBlast.dmi' //Placeholder
		ManaCost=25
		Speed = 1 // This actually is half the default which is 0.5.
		Blasts=100
		StrRate=1
		ForRate=1
		DamageMult=0.5 //I considered making this lower but considering BulletKill and Deflection are Things People Can Get, I left it as is.
		Scorching=2
		Instinct=1
		AccMult=1
		Explode=1
		Distance=100
		ComboMaster=1
		ZoneAttackX=25
		ZoneAttackY=25
		Hover=10
		Variation=0
		Homing=3
		HyperHoming=1
		ActiveMessage="sends 100 brilliant flowers raining down on their target, making them explode like fireworks!"
		Cooldown=-1
		adjust(mob/p)
			AccMult = 1 + (0.15 * p.SagaLevel)
			Scorching = p.SagaLevel/2
			Distance = 100 + (10 * p.SagaLevel)
			Instinct = p.SagaLevel
		verb/BrilliantFireworks()
			set category="Skills"
			if(!usr.InBankai())
				usr << "You can only use this technique in Bankai!"
				return
			else
				usr.UseProjectile(src)